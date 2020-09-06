
obj/user/dumbfork.debug:     file format elf32-i386


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
  80002c:	e8 a3 01 00 00       	call   8001d4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80003e:	83 ec 04             	sub    $0x4,%esp
  800041:	6a 07                	push   $0x7
  800043:	53                   	push   %ebx
  800044:	56                   	push   %esi
  800045:	e8 dd 0c 00 00       	call   800d27 <sys_page_alloc>
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	78 4a                	js     80009b <duppage+0x68>
		panic("sys_page_alloc: %e", r);
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800051:	83 ec 0c             	sub    $0xc,%esp
  800054:	6a 07                	push   $0x7
  800056:	68 00 00 40 00       	push   $0x400000
  80005b:	6a 00                	push   $0x0
  80005d:	53                   	push   %ebx
  80005e:	56                   	push   %esi
  80005f:	e8 06 0d 00 00       	call   800d6a <sys_page_map>
  800064:	83 c4 20             	add    $0x20,%esp
  800067:	85 c0                	test   %eax,%eax
  800069:	78 42                	js     8000ad <duppage+0x7a>
		panic("sys_page_map: %e", r);
	memmove(UTEMP, addr, PGSIZE);
  80006b:	83 ec 04             	sub    $0x4,%esp
  80006e:	68 00 10 00 00       	push   $0x1000
  800073:	53                   	push   %ebx
  800074:	68 00 00 40 00       	push   $0x400000
  800079:	e8 3e 0a 00 00       	call   800abc <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80007e:	83 c4 08             	add    $0x8,%esp
  800081:	68 00 00 40 00       	push   $0x400000
  800086:	6a 00                	push   $0x0
  800088:	e8 1f 0d 00 00       	call   800dac <sys_page_unmap>
  80008d:	83 c4 10             	add    $0x10,%esp
  800090:	85 c0                	test   %eax,%eax
  800092:	78 2b                	js     8000bf <duppage+0x8c>
		panic("sys_page_unmap: %e", r);
}
  800094:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800097:	5b                   	pop    %ebx
  800098:	5e                   	pop    %esi
  800099:	5d                   	pop    %ebp
  80009a:	c3                   	ret    
		panic("sys_page_alloc: %e", r);
  80009b:	50                   	push   %eax
  80009c:	68 60 1f 80 00       	push   $0x801f60
  8000a1:	6a 20                	push   $0x20
  8000a3:	68 73 1f 80 00       	push   $0x801f73
  8000a8:	e8 87 01 00 00       	call   800234 <_panic>
		panic("sys_page_map: %e", r);
  8000ad:	50                   	push   %eax
  8000ae:	68 83 1f 80 00       	push   $0x801f83
  8000b3:	6a 22                	push   $0x22
  8000b5:	68 73 1f 80 00       	push   $0x801f73
  8000ba:	e8 75 01 00 00       	call   800234 <_panic>
		panic("sys_page_unmap: %e", r);
  8000bf:	50                   	push   %eax
  8000c0:	68 94 1f 80 00       	push   $0x801f94
  8000c5:	6a 25                	push   $0x25
  8000c7:	68 73 1f 80 00       	push   $0x801f73
  8000cc:	e8 63 01 00 00       	call   800234 <_panic>

008000d1 <dumbfork>:

envid_t
dumbfork(void)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	56                   	push   %esi
  8000d5:	53                   	push   %ebx
  8000d6:	83 ec 10             	sub    $0x10,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8000d9:	b8 07 00 00 00       	mov    $0x7,%eax
  8000de:	cd 30                	int    $0x30
  8000e0:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  8000e2:	85 c0                	test   %eax,%eax
  8000e4:	78 0f                	js     8000f5 <dumbfork+0x24>
  8000e6:	89 c6                	mov    %eax,%esi
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  8000e8:	85 c0                	test   %eax,%eax
  8000ea:	74 1b                	je     800107 <dumbfork+0x36>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  8000ec:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  8000f3:	eb 3f                	jmp    800134 <dumbfork+0x63>
		panic("sys_exofork: %e", envid);
  8000f5:	50                   	push   %eax
  8000f6:	68 a7 1f 80 00       	push   $0x801fa7
  8000fb:	6a 37                	push   $0x37
  8000fd:	68 73 1f 80 00       	push   $0x801f73
  800102:	e8 2d 01 00 00       	call   800234 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
  800107:	e8 dd 0b 00 00       	call   800ce9 <sys_getenvid>
  80010c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800111:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800114:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800119:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  80011e:	eb 43                	jmp    800163 <dumbfork+0x92>
		duppage(envid, addr);
  800120:	83 ec 08             	sub    $0x8,%esp
  800123:	52                   	push   %edx
  800124:	56                   	push   %esi
  800125:	e8 09 ff ff ff       	call   800033 <duppage>
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80012a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  800131:	83 c4 10             	add    $0x10,%esp
  800134:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800137:	81 fa 00 60 80 00    	cmp    $0x806000,%edx
  80013d:	72 e1                	jb     800120 <dumbfork+0x4f>

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  80013f:	83 ec 08             	sub    $0x8,%esp
  800142:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800145:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80014a:	50                   	push   %eax
  80014b:	53                   	push   %ebx
  80014c:	e8 e2 fe ff ff       	call   800033 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800151:	83 c4 08             	add    $0x8,%esp
  800154:	6a 02                	push   $0x2
  800156:	53                   	push   %ebx
  800157:	e8 92 0c 00 00       	call   800dee <sys_env_set_status>
  80015c:	83 c4 10             	add    $0x10,%esp
  80015f:	85 c0                	test   %eax,%eax
  800161:	78 09                	js     80016c <dumbfork+0x9b>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  800163:	89 d8                	mov    %ebx,%eax
  800165:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800168:	5b                   	pop    %ebx
  800169:	5e                   	pop    %esi
  80016a:	5d                   	pop    %ebp
  80016b:	c3                   	ret    
		panic("sys_env_set_status: %e", r);
  80016c:	50                   	push   %eax
  80016d:	68 b7 1f 80 00       	push   $0x801fb7
  800172:	6a 4c                	push   $0x4c
  800174:	68 73 1f 80 00       	push   $0x801f73
  800179:	e8 b6 00 00 00       	call   800234 <_panic>

0080017e <umain>:
{
  80017e:	55                   	push   %ebp
  80017f:	89 e5                	mov    %esp,%ebp
  800181:	57                   	push   %edi
  800182:	56                   	push   %esi
  800183:	53                   	push   %ebx
  800184:	83 ec 0c             	sub    $0xc,%esp
	who = dumbfork();
  800187:	e8 45 ff ff ff       	call   8000d1 <dumbfork>
  80018c:	89 c7                	mov    %eax,%edi
  80018e:	85 c0                	test   %eax,%eax
  800190:	be ce 1f 80 00       	mov    $0x801fce,%esi
  800195:	b8 d5 1f 80 00       	mov    $0x801fd5,%eax
  80019a:	0f 44 f0             	cmove  %eax,%esi
	for (i = 0; i < (who ? 10 : 20); i++) {
  80019d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001a2:	eb 1f                	jmp    8001c3 <umain+0x45>
  8001a4:	83 fb 13             	cmp    $0x13,%ebx
  8001a7:	7f 23                	jg     8001cc <umain+0x4e>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001a9:	83 ec 04             	sub    $0x4,%esp
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	68 db 1f 80 00       	push   $0x801fdb
  8001b3:	e8 57 01 00 00       	call   80030f <cprintf>
		sys_yield();
  8001b8:	e8 4b 0b 00 00       	call   800d08 <sys_yield>
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001bd:	83 c3 01             	add    $0x1,%ebx
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 ff                	test   %edi,%edi
  8001c5:	74 dd                	je     8001a4 <umain+0x26>
  8001c7:	83 fb 09             	cmp    $0x9,%ebx
  8001ca:	7e dd                	jle    8001a9 <umain+0x2b>
}
  8001cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001cf:	5b                   	pop    %ebx
  8001d0:	5e                   	pop    %esi
  8001d1:	5f                   	pop    %edi
  8001d2:	5d                   	pop    %ebp
  8001d3:	c3                   	ret    

008001d4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	56                   	push   %esi
  8001d8:	53                   	push   %ebx
  8001d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001dc:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001df:	e8 05 0b 00 00       	call   800ce9 <sys_getenvid>
  8001e4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001e9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001ec:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001f1:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f6:	85 db                	test   %ebx,%ebx
  8001f8:	7e 07                	jle    800201 <libmain+0x2d>
		binaryname = argv[0];
  8001fa:	8b 06                	mov    (%esi),%eax
  8001fc:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800201:	83 ec 08             	sub    $0x8,%esp
  800204:	56                   	push   %esi
  800205:	53                   	push   %ebx
  800206:	e8 73 ff ff ff       	call   80017e <umain>

	// exit gracefully
	exit();
  80020b:	e8 0a 00 00 00       	call   80021a <exit>
}
  800210:	83 c4 10             	add    $0x10,%esp
  800213:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800216:	5b                   	pop    %ebx
  800217:	5e                   	pop    %esi
  800218:	5d                   	pop    %ebp
  800219:	c3                   	ret    

0080021a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80021a:	55                   	push   %ebp
  80021b:	89 e5                	mov    %esp,%ebp
  80021d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800220:	e8 c9 0e 00 00       	call   8010ee <close_all>
	sys_env_destroy(0);
  800225:	83 ec 0c             	sub    $0xc,%esp
  800228:	6a 00                	push   $0x0
  80022a:	e8 79 0a 00 00       	call   800ca8 <sys_env_destroy>
}
  80022f:	83 c4 10             	add    $0x10,%esp
  800232:	c9                   	leave  
  800233:	c3                   	ret    

00800234 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	56                   	push   %esi
  800238:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800239:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80023c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800242:	e8 a2 0a 00 00       	call   800ce9 <sys_getenvid>
  800247:	83 ec 0c             	sub    $0xc,%esp
  80024a:	ff 75 0c             	pushl  0xc(%ebp)
  80024d:	ff 75 08             	pushl  0x8(%ebp)
  800250:	56                   	push   %esi
  800251:	50                   	push   %eax
  800252:	68 f8 1f 80 00       	push   $0x801ff8
  800257:	e8 b3 00 00 00       	call   80030f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80025c:	83 c4 18             	add    $0x18,%esp
  80025f:	53                   	push   %ebx
  800260:	ff 75 10             	pushl  0x10(%ebp)
  800263:	e8 56 00 00 00       	call   8002be <vcprintf>
	cprintf("\n");
  800268:	c7 04 24 eb 1f 80 00 	movl   $0x801feb,(%esp)
  80026f:	e8 9b 00 00 00       	call   80030f <cprintf>
  800274:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800277:	cc                   	int3   
  800278:	eb fd                	jmp    800277 <_panic+0x43>

0080027a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80027a:	55                   	push   %ebp
  80027b:	89 e5                	mov    %esp,%ebp
  80027d:	53                   	push   %ebx
  80027e:	83 ec 04             	sub    $0x4,%esp
  800281:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800284:	8b 13                	mov    (%ebx),%edx
  800286:	8d 42 01             	lea    0x1(%edx),%eax
  800289:	89 03                	mov    %eax,(%ebx)
  80028b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80028e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800292:	3d ff 00 00 00       	cmp    $0xff,%eax
  800297:	74 09                	je     8002a2 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800299:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80029d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002a0:	c9                   	leave  
  8002a1:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8002a2:	83 ec 08             	sub    $0x8,%esp
  8002a5:	68 ff 00 00 00       	push   $0xff
  8002aa:	8d 43 08             	lea    0x8(%ebx),%eax
  8002ad:	50                   	push   %eax
  8002ae:	e8 b8 09 00 00       	call   800c6b <sys_cputs>
		b->idx = 0;
  8002b3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b9:	83 c4 10             	add    $0x10,%esp
  8002bc:	eb db                	jmp    800299 <putch+0x1f>

008002be <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002c7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002ce:	00 00 00 
	b.cnt = 0;
  8002d1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002db:	ff 75 0c             	pushl  0xc(%ebp)
  8002de:	ff 75 08             	pushl  0x8(%ebp)
  8002e1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002e7:	50                   	push   %eax
  8002e8:	68 7a 02 80 00       	push   $0x80027a
  8002ed:	e8 1a 01 00 00       	call   80040c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002f2:	83 c4 08             	add    $0x8,%esp
  8002f5:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002fb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800301:	50                   	push   %eax
  800302:	e8 64 09 00 00       	call   800c6b <sys_cputs>

	return b.cnt;
}
  800307:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80030d:	c9                   	leave  
  80030e:	c3                   	ret    

0080030f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800315:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800318:	50                   	push   %eax
  800319:	ff 75 08             	pushl  0x8(%ebp)
  80031c:	e8 9d ff ff ff       	call   8002be <vcprintf>
	va_end(ap);

	return cnt;
}
  800321:	c9                   	leave  
  800322:	c3                   	ret    

00800323 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	57                   	push   %edi
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
  800329:	83 ec 1c             	sub    $0x1c,%esp
  80032c:	89 c7                	mov    %eax,%edi
  80032e:	89 d6                	mov    %edx,%esi
  800330:	8b 45 08             	mov    0x8(%ebp),%eax
  800333:	8b 55 0c             	mov    0xc(%ebp),%edx
  800336:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800339:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80033c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80033f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800344:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800347:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80034a:	39 d3                	cmp    %edx,%ebx
  80034c:	72 05                	jb     800353 <printnum+0x30>
  80034e:	39 45 10             	cmp    %eax,0x10(%ebp)
  800351:	77 7a                	ja     8003cd <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800353:	83 ec 0c             	sub    $0xc,%esp
  800356:	ff 75 18             	pushl  0x18(%ebp)
  800359:	8b 45 14             	mov    0x14(%ebp),%eax
  80035c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80035f:	53                   	push   %ebx
  800360:	ff 75 10             	pushl  0x10(%ebp)
  800363:	83 ec 08             	sub    $0x8,%esp
  800366:	ff 75 e4             	pushl  -0x1c(%ebp)
  800369:	ff 75 e0             	pushl  -0x20(%ebp)
  80036c:	ff 75 dc             	pushl  -0x24(%ebp)
  80036f:	ff 75 d8             	pushl  -0x28(%ebp)
  800372:	e8 a9 19 00 00       	call   801d20 <__udivdi3>
  800377:	83 c4 18             	add    $0x18,%esp
  80037a:	52                   	push   %edx
  80037b:	50                   	push   %eax
  80037c:	89 f2                	mov    %esi,%edx
  80037e:	89 f8                	mov    %edi,%eax
  800380:	e8 9e ff ff ff       	call   800323 <printnum>
  800385:	83 c4 20             	add    $0x20,%esp
  800388:	eb 13                	jmp    80039d <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80038a:	83 ec 08             	sub    $0x8,%esp
  80038d:	56                   	push   %esi
  80038e:	ff 75 18             	pushl  0x18(%ebp)
  800391:	ff d7                	call   *%edi
  800393:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800396:	83 eb 01             	sub    $0x1,%ebx
  800399:	85 db                	test   %ebx,%ebx
  80039b:	7f ed                	jg     80038a <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80039d:	83 ec 08             	sub    $0x8,%esp
  8003a0:	56                   	push   %esi
  8003a1:	83 ec 04             	sub    $0x4,%esp
  8003a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003a7:	ff 75 e0             	pushl  -0x20(%ebp)
  8003aa:	ff 75 dc             	pushl  -0x24(%ebp)
  8003ad:	ff 75 d8             	pushl  -0x28(%ebp)
  8003b0:	e8 8b 1a 00 00       	call   801e40 <__umoddi3>
  8003b5:	83 c4 14             	add    $0x14,%esp
  8003b8:	0f be 80 1b 20 80 00 	movsbl 0x80201b(%eax),%eax
  8003bf:	50                   	push   %eax
  8003c0:	ff d7                	call   *%edi
}
  8003c2:	83 c4 10             	add    $0x10,%esp
  8003c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003c8:	5b                   	pop    %ebx
  8003c9:	5e                   	pop    %esi
  8003ca:	5f                   	pop    %edi
  8003cb:	5d                   	pop    %ebp
  8003cc:	c3                   	ret    
  8003cd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003d0:	eb c4                	jmp    800396 <printnum+0x73>

008003d2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003d2:	55                   	push   %ebp
  8003d3:	89 e5                	mov    %esp,%ebp
  8003d5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003d8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003dc:	8b 10                	mov    (%eax),%edx
  8003de:	3b 50 04             	cmp    0x4(%eax),%edx
  8003e1:	73 0a                	jae    8003ed <sprintputch+0x1b>
		*b->buf++ = ch;
  8003e3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003e6:	89 08                	mov    %ecx,(%eax)
  8003e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003eb:	88 02                	mov    %al,(%edx)
}
  8003ed:	5d                   	pop    %ebp
  8003ee:	c3                   	ret    

008003ef <printfmt>:
{
  8003ef:	55                   	push   %ebp
  8003f0:	89 e5                	mov    %esp,%ebp
  8003f2:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8003f5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003f8:	50                   	push   %eax
  8003f9:	ff 75 10             	pushl  0x10(%ebp)
  8003fc:	ff 75 0c             	pushl  0xc(%ebp)
  8003ff:	ff 75 08             	pushl  0x8(%ebp)
  800402:	e8 05 00 00 00       	call   80040c <vprintfmt>
}
  800407:	83 c4 10             	add    $0x10,%esp
  80040a:	c9                   	leave  
  80040b:	c3                   	ret    

0080040c <vprintfmt>:
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	57                   	push   %edi
  800410:	56                   	push   %esi
  800411:	53                   	push   %ebx
  800412:	83 ec 2c             	sub    $0x2c,%esp
  800415:	8b 75 08             	mov    0x8(%ebp),%esi
  800418:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80041b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80041e:	e9 c1 03 00 00       	jmp    8007e4 <vprintfmt+0x3d8>
		padc = ' ';
  800423:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800427:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80042e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800435:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80043c:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800441:	8d 47 01             	lea    0x1(%edi),%eax
  800444:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800447:	0f b6 17             	movzbl (%edi),%edx
  80044a:	8d 42 dd             	lea    -0x23(%edx),%eax
  80044d:	3c 55                	cmp    $0x55,%al
  80044f:	0f 87 12 04 00 00    	ja     800867 <vprintfmt+0x45b>
  800455:	0f b6 c0             	movzbl %al,%eax
  800458:	ff 24 85 60 21 80 00 	jmp    *0x802160(,%eax,4)
  80045f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800462:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800466:	eb d9                	jmp    800441 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800468:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80046b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80046f:	eb d0                	jmp    800441 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800471:	0f b6 d2             	movzbl %dl,%edx
  800474:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800477:	b8 00 00 00 00       	mov    $0x0,%eax
  80047c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80047f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800482:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800486:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800489:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80048c:	83 f9 09             	cmp    $0x9,%ecx
  80048f:	77 55                	ja     8004e6 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800491:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800494:	eb e9                	jmp    80047f <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800496:	8b 45 14             	mov    0x14(%ebp),%eax
  800499:	8b 00                	mov    (%eax),%eax
  80049b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80049e:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a1:	8d 40 04             	lea    0x4(%eax),%eax
  8004a4:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8004aa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ae:	79 91                	jns    800441 <vprintfmt+0x35>
				width = precision, precision = -1;
  8004b0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004bd:	eb 82                	jmp    800441 <vprintfmt+0x35>
  8004bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004c2:	85 c0                	test   %eax,%eax
  8004c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c9:	0f 49 d0             	cmovns %eax,%edx
  8004cc:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d2:	e9 6a ff ff ff       	jmp    800441 <vprintfmt+0x35>
  8004d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8004da:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004e1:	e9 5b ff ff ff       	jmp    800441 <vprintfmt+0x35>
  8004e6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004e9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004ec:	eb bc                	jmp    8004aa <vprintfmt+0x9e>
			lflag++;
  8004ee:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004f4:	e9 48 ff ff ff       	jmp    800441 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8004f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fc:	8d 78 04             	lea    0x4(%eax),%edi
  8004ff:	83 ec 08             	sub    $0x8,%esp
  800502:	53                   	push   %ebx
  800503:	ff 30                	pushl  (%eax)
  800505:	ff d6                	call   *%esi
			break;
  800507:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80050a:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80050d:	e9 cf 02 00 00       	jmp    8007e1 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800512:	8b 45 14             	mov    0x14(%ebp),%eax
  800515:	8d 78 04             	lea    0x4(%eax),%edi
  800518:	8b 00                	mov    (%eax),%eax
  80051a:	99                   	cltd   
  80051b:	31 d0                	xor    %edx,%eax
  80051d:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80051f:	83 f8 0f             	cmp    $0xf,%eax
  800522:	7f 23                	jg     800547 <vprintfmt+0x13b>
  800524:	8b 14 85 c0 22 80 00 	mov    0x8022c0(,%eax,4),%edx
  80052b:	85 d2                	test   %edx,%edx
  80052d:	74 18                	je     800547 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  80052f:	52                   	push   %edx
  800530:	68 f5 23 80 00       	push   $0x8023f5
  800535:	53                   	push   %ebx
  800536:	56                   	push   %esi
  800537:	e8 b3 fe ff ff       	call   8003ef <printfmt>
  80053c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80053f:	89 7d 14             	mov    %edi,0x14(%ebp)
  800542:	e9 9a 02 00 00       	jmp    8007e1 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800547:	50                   	push   %eax
  800548:	68 33 20 80 00       	push   $0x802033
  80054d:	53                   	push   %ebx
  80054e:	56                   	push   %esi
  80054f:	e8 9b fe ff ff       	call   8003ef <printfmt>
  800554:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800557:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80055a:	e9 82 02 00 00       	jmp    8007e1 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  80055f:	8b 45 14             	mov    0x14(%ebp),%eax
  800562:	83 c0 04             	add    $0x4,%eax
  800565:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80056d:	85 ff                	test   %edi,%edi
  80056f:	b8 2c 20 80 00       	mov    $0x80202c,%eax
  800574:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800577:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80057b:	0f 8e bd 00 00 00    	jle    80063e <vprintfmt+0x232>
  800581:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800585:	75 0e                	jne    800595 <vprintfmt+0x189>
  800587:	89 75 08             	mov    %esi,0x8(%ebp)
  80058a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80058d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800590:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800593:	eb 6d                	jmp    800602 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800595:	83 ec 08             	sub    $0x8,%esp
  800598:	ff 75 d0             	pushl  -0x30(%ebp)
  80059b:	57                   	push   %edi
  80059c:	e8 6e 03 00 00       	call   80090f <strnlen>
  8005a1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005a4:	29 c1                	sub    %eax,%ecx
  8005a6:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8005a9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005ac:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005b3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005b6:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b8:	eb 0f                	jmp    8005c9 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	53                   	push   %ebx
  8005be:	ff 75 e0             	pushl  -0x20(%ebp)
  8005c1:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c3:	83 ef 01             	sub    $0x1,%edi
  8005c6:	83 c4 10             	add    $0x10,%esp
  8005c9:	85 ff                	test   %edi,%edi
  8005cb:	7f ed                	jg     8005ba <vprintfmt+0x1ae>
  8005cd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005d0:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005d3:	85 c9                	test   %ecx,%ecx
  8005d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8005da:	0f 49 c1             	cmovns %ecx,%eax
  8005dd:	29 c1                	sub    %eax,%ecx
  8005df:	89 75 08             	mov    %esi,0x8(%ebp)
  8005e2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005e5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e8:	89 cb                	mov    %ecx,%ebx
  8005ea:	eb 16                	jmp    800602 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8005ec:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005f0:	75 31                	jne    800623 <vprintfmt+0x217>
					putch(ch, putdat);
  8005f2:	83 ec 08             	sub    $0x8,%esp
  8005f5:	ff 75 0c             	pushl  0xc(%ebp)
  8005f8:	50                   	push   %eax
  8005f9:	ff 55 08             	call   *0x8(%ebp)
  8005fc:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ff:	83 eb 01             	sub    $0x1,%ebx
  800602:	83 c7 01             	add    $0x1,%edi
  800605:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800609:	0f be c2             	movsbl %dl,%eax
  80060c:	85 c0                	test   %eax,%eax
  80060e:	74 59                	je     800669 <vprintfmt+0x25d>
  800610:	85 f6                	test   %esi,%esi
  800612:	78 d8                	js     8005ec <vprintfmt+0x1e0>
  800614:	83 ee 01             	sub    $0x1,%esi
  800617:	79 d3                	jns    8005ec <vprintfmt+0x1e0>
  800619:	89 df                	mov    %ebx,%edi
  80061b:	8b 75 08             	mov    0x8(%ebp),%esi
  80061e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800621:	eb 37                	jmp    80065a <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800623:	0f be d2             	movsbl %dl,%edx
  800626:	83 ea 20             	sub    $0x20,%edx
  800629:	83 fa 5e             	cmp    $0x5e,%edx
  80062c:	76 c4                	jbe    8005f2 <vprintfmt+0x1e6>
					putch('?', putdat);
  80062e:	83 ec 08             	sub    $0x8,%esp
  800631:	ff 75 0c             	pushl  0xc(%ebp)
  800634:	6a 3f                	push   $0x3f
  800636:	ff 55 08             	call   *0x8(%ebp)
  800639:	83 c4 10             	add    $0x10,%esp
  80063c:	eb c1                	jmp    8005ff <vprintfmt+0x1f3>
  80063e:	89 75 08             	mov    %esi,0x8(%ebp)
  800641:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800644:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800647:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80064a:	eb b6                	jmp    800602 <vprintfmt+0x1f6>
				putch(' ', putdat);
  80064c:	83 ec 08             	sub    $0x8,%esp
  80064f:	53                   	push   %ebx
  800650:	6a 20                	push   $0x20
  800652:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800654:	83 ef 01             	sub    $0x1,%edi
  800657:	83 c4 10             	add    $0x10,%esp
  80065a:	85 ff                	test   %edi,%edi
  80065c:	7f ee                	jg     80064c <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80065e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800661:	89 45 14             	mov    %eax,0x14(%ebp)
  800664:	e9 78 01 00 00       	jmp    8007e1 <vprintfmt+0x3d5>
  800669:	89 df                	mov    %ebx,%edi
  80066b:	8b 75 08             	mov    0x8(%ebp),%esi
  80066e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800671:	eb e7                	jmp    80065a <vprintfmt+0x24e>
	if (lflag >= 2)
  800673:	83 f9 01             	cmp    $0x1,%ecx
  800676:	7e 3f                	jle    8006b7 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800678:	8b 45 14             	mov    0x14(%ebp),%eax
  80067b:	8b 50 04             	mov    0x4(%eax),%edx
  80067e:	8b 00                	mov    (%eax),%eax
  800680:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800683:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800686:	8b 45 14             	mov    0x14(%ebp),%eax
  800689:	8d 40 08             	lea    0x8(%eax),%eax
  80068c:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80068f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800693:	79 5c                	jns    8006f1 <vprintfmt+0x2e5>
				putch('-', putdat);
  800695:	83 ec 08             	sub    $0x8,%esp
  800698:	53                   	push   %ebx
  800699:	6a 2d                	push   $0x2d
  80069b:	ff d6                	call   *%esi
				num = -(long long) num;
  80069d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006a0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006a3:	f7 da                	neg    %edx
  8006a5:	83 d1 00             	adc    $0x0,%ecx
  8006a8:	f7 d9                	neg    %ecx
  8006aa:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006ad:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006b2:	e9 10 01 00 00       	jmp    8007c7 <vprintfmt+0x3bb>
	else if (lflag)
  8006b7:	85 c9                	test   %ecx,%ecx
  8006b9:	75 1b                	jne    8006d6 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8006bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006be:	8b 00                	mov    (%eax),%eax
  8006c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c3:	89 c1                	mov    %eax,%ecx
  8006c5:	c1 f9 1f             	sar    $0x1f,%ecx
  8006c8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ce:	8d 40 04             	lea    0x4(%eax),%eax
  8006d1:	89 45 14             	mov    %eax,0x14(%ebp)
  8006d4:	eb b9                	jmp    80068f <vprintfmt+0x283>
		return va_arg(*ap, long);
  8006d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d9:	8b 00                	mov    (%eax),%eax
  8006db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006de:	89 c1                	mov    %eax,%ecx
  8006e0:	c1 f9 1f             	sar    $0x1f,%ecx
  8006e3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e9:	8d 40 04             	lea    0x4(%eax),%eax
  8006ec:	89 45 14             	mov    %eax,0x14(%ebp)
  8006ef:	eb 9e                	jmp    80068f <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8006f1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006f4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8006f7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006fc:	e9 c6 00 00 00       	jmp    8007c7 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800701:	83 f9 01             	cmp    $0x1,%ecx
  800704:	7e 18                	jle    80071e <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  800706:	8b 45 14             	mov    0x14(%ebp),%eax
  800709:	8b 10                	mov    (%eax),%edx
  80070b:	8b 48 04             	mov    0x4(%eax),%ecx
  80070e:	8d 40 08             	lea    0x8(%eax),%eax
  800711:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800714:	b8 0a 00 00 00       	mov    $0xa,%eax
  800719:	e9 a9 00 00 00       	jmp    8007c7 <vprintfmt+0x3bb>
	else if (lflag)
  80071e:	85 c9                	test   %ecx,%ecx
  800720:	75 1a                	jne    80073c <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800722:	8b 45 14             	mov    0x14(%ebp),%eax
  800725:	8b 10                	mov    (%eax),%edx
  800727:	b9 00 00 00 00       	mov    $0x0,%ecx
  80072c:	8d 40 04             	lea    0x4(%eax),%eax
  80072f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800732:	b8 0a 00 00 00       	mov    $0xa,%eax
  800737:	e9 8b 00 00 00       	jmp    8007c7 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80073c:	8b 45 14             	mov    0x14(%ebp),%eax
  80073f:	8b 10                	mov    (%eax),%edx
  800741:	b9 00 00 00 00       	mov    $0x0,%ecx
  800746:	8d 40 04             	lea    0x4(%eax),%eax
  800749:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80074c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800751:	eb 74                	jmp    8007c7 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800753:	83 f9 01             	cmp    $0x1,%ecx
  800756:	7e 15                	jle    80076d <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800758:	8b 45 14             	mov    0x14(%ebp),%eax
  80075b:	8b 10                	mov    (%eax),%edx
  80075d:	8b 48 04             	mov    0x4(%eax),%ecx
  800760:	8d 40 08             	lea    0x8(%eax),%eax
  800763:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800766:	b8 08 00 00 00       	mov    $0x8,%eax
  80076b:	eb 5a                	jmp    8007c7 <vprintfmt+0x3bb>
	else if (lflag)
  80076d:	85 c9                	test   %ecx,%ecx
  80076f:	75 17                	jne    800788 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800771:	8b 45 14             	mov    0x14(%ebp),%eax
  800774:	8b 10                	mov    (%eax),%edx
  800776:	b9 00 00 00 00       	mov    $0x0,%ecx
  80077b:	8d 40 04             	lea    0x4(%eax),%eax
  80077e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800781:	b8 08 00 00 00       	mov    $0x8,%eax
  800786:	eb 3f                	jmp    8007c7 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800788:	8b 45 14             	mov    0x14(%ebp),%eax
  80078b:	8b 10                	mov    (%eax),%edx
  80078d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800792:	8d 40 04             	lea    0x4(%eax),%eax
  800795:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800798:	b8 08 00 00 00       	mov    $0x8,%eax
  80079d:	eb 28                	jmp    8007c7 <vprintfmt+0x3bb>
			putch('0', putdat);
  80079f:	83 ec 08             	sub    $0x8,%esp
  8007a2:	53                   	push   %ebx
  8007a3:	6a 30                	push   $0x30
  8007a5:	ff d6                	call   *%esi
			putch('x', putdat);
  8007a7:	83 c4 08             	add    $0x8,%esp
  8007aa:	53                   	push   %ebx
  8007ab:	6a 78                	push   $0x78
  8007ad:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007af:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b2:	8b 10                	mov    (%eax),%edx
  8007b4:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007b9:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8007bc:	8d 40 04             	lea    0x4(%eax),%eax
  8007bf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007c2:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8007c7:	83 ec 0c             	sub    $0xc,%esp
  8007ca:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007ce:	57                   	push   %edi
  8007cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8007d2:	50                   	push   %eax
  8007d3:	51                   	push   %ecx
  8007d4:	52                   	push   %edx
  8007d5:	89 da                	mov    %ebx,%edx
  8007d7:	89 f0                	mov    %esi,%eax
  8007d9:	e8 45 fb ff ff       	call   800323 <printnum>
			break;
  8007de:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8007e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007e4:	83 c7 01             	add    $0x1,%edi
  8007e7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007eb:	83 f8 25             	cmp    $0x25,%eax
  8007ee:	0f 84 2f fc ff ff    	je     800423 <vprintfmt+0x17>
			if (ch == '\0')
  8007f4:	85 c0                	test   %eax,%eax
  8007f6:	0f 84 8b 00 00 00    	je     800887 <vprintfmt+0x47b>
			putch(ch, putdat);
  8007fc:	83 ec 08             	sub    $0x8,%esp
  8007ff:	53                   	push   %ebx
  800800:	50                   	push   %eax
  800801:	ff d6                	call   *%esi
  800803:	83 c4 10             	add    $0x10,%esp
  800806:	eb dc                	jmp    8007e4 <vprintfmt+0x3d8>
	if (lflag >= 2)
  800808:	83 f9 01             	cmp    $0x1,%ecx
  80080b:	7e 15                	jle    800822 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  80080d:	8b 45 14             	mov    0x14(%ebp),%eax
  800810:	8b 10                	mov    (%eax),%edx
  800812:	8b 48 04             	mov    0x4(%eax),%ecx
  800815:	8d 40 08             	lea    0x8(%eax),%eax
  800818:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80081b:	b8 10 00 00 00       	mov    $0x10,%eax
  800820:	eb a5                	jmp    8007c7 <vprintfmt+0x3bb>
	else if (lflag)
  800822:	85 c9                	test   %ecx,%ecx
  800824:	75 17                	jne    80083d <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  800826:	8b 45 14             	mov    0x14(%ebp),%eax
  800829:	8b 10                	mov    (%eax),%edx
  80082b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800830:	8d 40 04             	lea    0x4(%eax),%eax
  800833:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800836:	b8 10 00 00 00       	mov    $0x10,%eax
  80083b:	eb 8a                	jmp    8007c7 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80083d:	8b 45 14             	mov    0x14(%ebp),%eax
  800840:	8b 10                	mov    (%eax),%edx
  800842:	b9 00 00 00 00       	mov    $0x0,%ecx
  800847:	8d 40 04             	lea    0x4(%eax),%eax
  80084a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80084d:	b8 10 00 00 00       	mov    $0x10,%eax
  800852:	e9 70 ff ff ff       	jmp    8007c7 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800857:	83 ec 08             	sub    $0x8,%esp
  80085a:	53                   	push   %ebx
  80085b:	6a 25                	push   $0x25
  80085d:	ff d6                	call   *%esi
			break;
  80085f:	83 c4 10             	add    $0x10,%esp
  800862:	e9 7a ff ff ff       	jmp    8007e1 <vprintfmt+0x3d5>
			putch('%', putdat);
  800867:	83 ec 08             	sub    $0x8,%esp
  80086a:	53                   	push   %ebx
  80086b:	6a 25                	push   $0x25
  80086d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80086f:	83 c4 10             	add    $0x10,%esp
  800872:	89 f8                	mov    %edi,%eax
  800874:	eb 03                	jmp    800879 <vprintfmt+0x46d>
  800876:	83 e8 01             	sub    $0x1,%eax
  800879:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80087d:	75 f7                	jne    800876 <vprintfmt+0x46a>
  80087f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800882:	e9 5a ff ff ff       	jmp    8007e1 <vprintfmt+0x3d5>
}
  800887:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80088a:	5b                   	pop    %ebx
  80088b:	5e                   	pop    %esi
  80088c:	5f                   	pop    %edi
  80088d:	5d                   	pop    %ebp
  80088e:	c3                   	ret    

0080088f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80088f:	55                   	push   %ebp
  800890:	89 e5                	mov    %esp,%ebp
  800892:	83 ec 18             	sub    $0x18,%esp
  800895:	8b 45 08             	mov    0x8(%ebp),%eax
  800898:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80089b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80089e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008a2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008a5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008ac:	85 c0                	test   %eax,%eax
  8008ae:	74 26                	je     8008d6 <vsnprintf+0x47>
  8008b0:	85 d2                	test   %edx,%edx
  8008b2:	7e 22                	jle    8008d6 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008b4:	ff 75 14             	pushl  0x14(%ebp)
  8008b7:	ff 75 10             	pushl  0x10(%ebp)
  8008ba:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008bd:	50                   	push   %eax
  8008be:	68 d2 03 80 00       	push   $0x8003d2
  8008c3:	e8 44 fb ff ff       	call   80040c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008cb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008d1:	83 c4 10             	add    $0x10,%esp
}
  8008d4:	c9                   	leave  
  8008d5:	c3                   	ret    
		return -E_INVAL;
  8008d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008db:	eb f7                	jmp    8008d4 <vsnprintf+0x45>

008008dd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008e3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008e6:	50                   	push   %eax
  8008e7:	ff 75 10             	pushl  0x10(%ebp)
  8008ea:	ff 75 0c             	pushl  0xc(%ebp)
  8008ed:	ff 75 08             	pushl  0x8(%ebp)
  8008f0:	e8 9a ff ff ff       	call   80088f <vsnprintf>
	va_end(ap);

	return rc;
}
  8008f5:	c9                   	leave  
  8008f6:	c3                   	ret    

008008f7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800902:	eb 03                	jmp    800907 <strlen+0x10>
		n++;
  800904:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800907:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80090b:	75 f7                	jne    800904 <strlen+0xd>
	return n;
}
  80090d:	5d                   	pop    %ebp
  80090e:	c3                   	ret    

0080090f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800915:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800918:	b8 00 00 00 00       	mov    $0x0,%eax
  80091d:	eb 03                	jmp    800922 <strnlen+0x13>
		n++;
  80091f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800922:	39 d0                	cmp    %edx,%eax
  800924:	74 06                	je     80092c <strnlen+0x1d>
  800926:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80092a:	75 f3                	jne    80091f <strnlen+0x10>
	return n;
}
  80092c:	5d                   	pop    %ebp
  80092d:	c3                   	ret    

0080092e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	53                   	push   %ebx
  800932:	8b 45 08             	mov    0x8(%ebp),%eax
  800935:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800938:	89 c2                	mov    %eax,%edx
  80093a:	83 c1 01             	add    $0x1,%ecx
  80093d:	83 c2 01             	add    $0x1,%edx
  800940:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800944:	88 5a ff             	mov    %bl,-0x1(%edx)
  800947:	84 db                	test   %bl,%bl
  800949:	75 ef                	jne    80093a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80094b:	5b                   	pop    %ebx
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	53                   	push   %ebx
  800952:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800955:	53                   	push   %ebx
  800956:	e8 9c ff ff ff       	call   8008f7 <strlen>
  80095b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80095e:	ff 75 0c             	pushl  0xc(%ebp)
  800961:	01 d8                	add    %ebx,%eax
  800963:	50                   	push   %eax
  800964:	e8 c5 ff ff ff       	call   80092e <strcpy>
	return dst;
}
  800969:	89 d8                	mov    %ebx,%eax
  80096b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80096e:	c9                   	leave  
  80096f:	c3                   	ret    

00800970 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	56                   	push   %esi
  800974:	53                   	push   %ebx
  800975:	8b 75 08             	mov    0x8(%ebp),%esi
  800978:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80097b:	89 f3                	mov    %esi,%ebx
  80097d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800980:	89 f2                	mov    %esi,%edx
  800982:	eb 0f                	jmp    800993 <strncpy+0x23>
		*dst++ = *src;
  800984:	83 c2 01             	add    $0x1,%edx
  800987:	0f b6 01             	movzbl (%ecx),%eax
  80098a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80098d:	80 39 01             	cmpb   $0x1,(%ecx)
  800990:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800993:	39 da                	cmp    %ebx,%edx
  800995:	75 ed                	jne    800984 <strncpy+0x14>
	}
	return ret;
}
  800997:	89 f0                	mov    %esi,%eax
  800999:	5b                   	pop    %ebx
  80099a:	5e                   	pop    %esi
  80099b:	5d                   	pop    %ebp
  80099c:	c3                   	ret    

0080099d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	56                   	push   %esi
  8009a1:	53                   	push   %ebx
  8009a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8009a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009ab:	89 f0                	mov    %esi,%eax
  8009ad:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009b1:	85 c9                	test   %ecx,%ecx
  8009b3:	75 0b                	jne    8009c0 <strlcpy+0x23>
  8009b5:	eb 17                	jmp    8009ce <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009b7:	83 c2 01             	add    $0x1,%edx
  8009ba:	83 c0 01             	add    $0x1,%eax
  8009bd:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8009c0:	39 d8                	cmp    %ebx,%eax
  8009c2:	74 07                	je     8009cb <strlcpy+0x2e>
  8009c4:	0f b6 0a             	movzbl (%edx),%ecx
  8009c7:	84 c9                	test   %cl,%cl
  8009c9:	75 ec                	jne    8009b7 <strlcpy+0x1a>
		*dst = '\0';
  8009cb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009ce:	29 f0                	sub    %esi,%eax
}
  8009d0:	5b                   	pop    %ebx
  8009d1:	5e                   	pop    %esi
  8009d2:	5d                   	pop    %ebp
  8009d3:	c3                   	ret    

008009d4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009da:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009dd:	eb 06                	jmp    8009e5 <strcmp+0x11>
		p++, q++;
  8009df:	83 c1 01             	add    $0x1,%ecx
  8009e2:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009e5:	0f b6 01             	movzbl (%ecx),%eax
  8009e8:	84 c0                	test   %al,%al
  8009ea:	74 04                	je     8009f0 <strcmp+0x1c>
  8009ec:	3a 02                	cmp    (%edx),%al
  8009ee:	74 ef                	je     8009df <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009f0:	0f b6 c0             	movzbl %al,%eax
  8009f3:	0f b6 12             	movzbl (%edx),%edx
  8009f6:	29 d0                	sub    %edx,%eax
}
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	53                   	push   %ebx
  8009fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800a01:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a04:	89 c3                	mov    %eax,%ebx
  800a06:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a09:	eb 06                	jmp    800a11 <strncmp+0x17>
		n--, p++, q++;
  800a0b:	83 c0 01             	add    $0x1,%eax
  800a0e:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a11:	39 d8                	cmp    %ebx,%eax
  800a13:	74 16                	je     800a2b <strncmp+0x31>
  800a15:	0f b6 08             	movzbl (%eax),%ecx
  800a18:	84 c9                	test   %cl,%cl
  800a1a:	74 04                	je     800a20 <strncmp+0x26>
  800a1c:	3a 0a                	cmp    (%edx),%cl
  800a1e:	74 eb                	je     800a0b <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a20:	0f b6 00             	movzbl (%eax),%eax
  800a23:	0f b6 12             	movzbl (%edx),%edx
  800a26:	29 d0                	sub    %edx,%eax
}
  800a28:	5b                   	pop    %ebx
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    
		return 0;
  800a2b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a30:	eb f6                	jmp    800a28 <strncmp+0x2e>

00800a32 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a32:	55                   	push   %ebp
  800a33:	89 e5                	mov    %esp,%ebp
  800a35:	8b 45 08             	mov    0x8(%ebp),%eax
  800a38:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a3c:	0f b6 10             	movzbl (%eax),%edx
  800a3f:	84 d2                	test   %dl,%dl
  800a41:	74 09                	je     800a4c <strchr+0x1a>
		if (*s == c)
  800a43:	38 ca                	cmp    %cl,%dl
  800a45:	74 0a                	je     800a51 <strchr+0x1f>
	for (; *s; s++)
  800a47:	83 c0 01             	add    $0x1,%eax
  800a4a:	eb f0                	jmp    800a3c <strchr+0xa>
			return (char *) s;
	return 0;
  800a4c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a51:	5d                   	pop    %ebp
  800a52:	c3                   	ret    

00800a53 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a53:	55                   	push   %ebp
  800a54:	89 e5                	mov    %esp,%ebp
  800a56:	8b 45 08             	mov    0x8(%ebp),%eax
  800a59:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a5d:	eb 03                	jmp    800a62 <strfind+0xf>
  800a5f:	83 c0 01             	add    $0x1,%eax
  800a62:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a65:	38 ca                	cmp    %cl,%dl
  800a67:	74 04                	je     800a6d <strfind+0x1a>
  800a69:	84 d2                	test   %dl,%dl
  800a6b:	75 f2                	jne    800a5f <strfind+0xc>
			break;
	return (char *) s;
}
  800a6d:	5d                   	pop    %ebp
  800a6e:	c3                   	ret    

00800a6f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	57                   	push   %edi
  800a73:	56                   	push   %esi
  800a74:	53                   	push   %ebx
  800a75:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a78:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a7b:	85 c9                	test   %ecx,%ecx
  800a7d:	74 13                	je     800a92 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a7f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a85:	75 05                	jne    800a8c <memset+0x1d>
  800a87:	f6 c1 03             	test   $0x3,%cl
  800a8a:	74 0d                	je     800a99 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8f:	fc                   	cld    
  800a90:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a92:	89 f8                	mov    %edi,%eax
  800a94:	5b                   	pop    %ebx
  800a95:	5e                   	pop    %esi
  800a96:	5f                   	pop    %edi
  800a97:	5d                   	pop    %ebp
  800a98:	c3                   	ret    
		c &= 0xFF;
  800a99:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a9d:	89 d3                	mov    %edx,%ebx
  800a9f:	c1 e3 08             	shl    $0x8,%ebx
  800aa2:	89 d0                	mov    %edx,%eax
  800aa4:	c1 e0 18             	shl    $0x18,%eax
  800aa7:	89 d6                	mov    %edx,%esi
  800aa9:	c1 e6 10             	shl    $0x10,%esi
  800aac:	09 f0                	or     %esi,%eax
  800aae:	09 c2                	or     %eax,%edx
  800ab0:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800ab2:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ab5:	89 d0                	mov    %edx,%eax
  800ab7:	fc                   	cld    
  800ab8:	f3 ab                	rep stos %eax,%es:(%edi)
  800aba:	eb d6                	jmp    800a92 <memset+0x23>

00800abc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	57                   	push   %edi
  800ac0:	56                   	push   %esi
  800ac1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aca:	39 c6                	cmp    %eax,%esi
  800acc:	73 35                	jae    800b03 <memmove+0x47>
  800ace:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ad1:	39 c2                	cmp    %eax,%edx
  800ad3:	76 2e                	jbe    800b03 <memmove+0x47>
		s += n;
		d += n;
  800ad5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad8:	89 d6                	mov    %edx,%esi
  800ada:	09 fe                	or     %edi,%esi
  800adc:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ae2:	74 0c                	je     800af0 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ae4:	83 ef 01             	sub    $0x1,%edi
  800ae7:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800aea:	fd                   	std    
  800aeb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aed:	fc                   	cld    
  800aee:	eb 21                	jmp    800b11 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af0:	f6 c1 03             	test   $0x3,%cl
  800af3:	75 ef                	jne    800ae4 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800af5:	83 ef 04             	sub    $0x4,%edi
  800af8:	8d 72 fc             	lea    -0x4(%edx),%esi
  800afb:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800afe:	fd                   	std    
  800aff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b01:	eb ea                	jmp    800aed <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b03:	89 f2                	mov    %esi,%edx
  800b05:	09 c2                	or     %eax,%edx
  800b07:	f6 c2 03             	test   $0x3,%dl
  800b0a:	74 09                	je     800b15 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b0c:	89 c7                	mov    %eax,%edi
  800b0e:	fc                   	cld    
  800b0f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b11:	5e                   	pop    %esi
  800b12:	5f                   	pop    %edi
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b15:	f6 c1 03             	test   $0x3,%cl
  800b18:	75 f2                	jne    800b0c <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b1a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b1d:	89 c7                	mov    %eax,%edi
  800b1f:	fc                   	cld    
  800b20:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b22:	eb ed                	jmp    800b11 <memmove+0x55>

00800b24 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b27:	ff 75 10             	pushl  0x10(%ebp)
  800b2a:	ff 75 0c             	pushl  0xc(%ebp)
  800b2d:	ff 75 08             	pushl  0x8(%ebp)
  800b30:	e8 87 ff ff ff       	call   800abc <memmove>
}
  800b35:	c9                   	leave  
  800b36:	c3                   	ret    

00800b37 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	56                   	push   %esi
  800b3b:	53                   	push   %ebx
  800b3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b42:	89 c6                	mov    %eax,%esi
  800b44:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b47:	39 f0                	cmp    %esi,%eax
  800b49:	74 1c                	je     800b67 <memcmp+0x30>
		if (*s1 != *s2)
  800b4b:	0f b6 08             	movzbl (%eax),%ecx
  800b4e:	0f b6 1a             	movzbl (%edx),%ebx
  800b51:	38 d9                	cmp    %bl,%cl
  800b53:	75 08                	jne    800b5d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b55:	83 c0 01             	add    $0x1,%eax
  800b58:	83 c2 01             	add    $0x1,%edx
  800b5b:	eb ea                	jmp    800b47 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b5d:	0f b6 c1             	movzbl %cl,%eax
  800b60:	0f b6 db             	movzbl %bl,%ebx
  800b63:	29 d8                	sub    %ebx,%eax
  800b65:	eb 05                	jmp    800b6c <memcmp+0x35>
	}

	return 0;
  800b67:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b6c:	5b                   	pop    %ebx
  800b6d:	5e                   	pop    %esi
  800b6e:	5d                   	pop    %ebp
  800b6f:	c3                   	ret    

00800b70 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	8b 45 08             	mov    0x8(%ebp),%eax
  800b76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b79:	89 c2                	mov    %eax,%edx
  800b7b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b7e:	39 d0                	cmp    %edx,%eax
  800b80:	73 09                	jae    800b8b <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b82:	38 08                	cmp    %cl,(%eax)
  800b84:	74 05                	je     800b8b <memfind+0x1b>
	for (; s < ends; s++)
  800b86:	83 c0 01             	add    $0x1,%eax
  800b89:	eb f3                	jmp    800b7e <memfind+0xe>
			break;
	return (void *) s;
}
  800b8b:	5d                   	pop    %ebp
  800b8c:	c3                   	ret    

00800b8d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	57                   	push   %edi
  800b91:	56                   	push   %esi
  800b92:	53                   	push   %ebx
  800b93:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b96:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b99:	eb 03                	jmp    800b9e <strtol+0x11>
		s++;
  800b9b:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b9e:	0f b6 01             	movzbl (%ecx),%eax
  800ba1:	3c 20                	cmp    $0x20,%al
  800ba3:	74 f6                	je     800b9b <strtol+0xe>
  800ba5:	3c 09                	cmp    $0x9,%al
  800ba7:	74 f2                	je     800b9b <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800ba9:	3c 2b                	cmp    $0x2b,%al
  800bab:	74 2e                	je     800bdb <strtol+0x4e>
	int neg = 0;
  800bad:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800bb2:	3c 2d                	cmp    $0x2d,%al
  800bb4:	74 2f                	je     800be5 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bb6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bbc:	75 05                	jne    800bc3 <strtol+0x36>
  800bbe:	80 39 30             	cmpb   $0x30,(%ecx)
  800bc1:	74 2c                	je     800bef <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bc3:	85 db                	test   %ebx,%ebx
  800bc5:	75 0a                	jne    800bd1 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bc7:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800bcc:	80 39 30             	cmpb   $0x30,(%ecx)
  800bcf:	74 28                	je     800bf9 <strtol+0x6c>
		base = 10;
  800bd1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd6:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bd9:	eb 50                	jmp    800c2b <strtol+0x9e>
		s++;
  800bdb:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bde:	bf 00 00 00 00       	mov    $0x0,%edi
  800be3:	eb d1                	jmp    800bb6 <strtol+0x29>
		s++, neg = 1;
  800be5:	83 c1 01             	add    $0x1,%ecx
  800be8:	bf 01 00 00 00       	mov    $0x1,%edi
  800bed:	eb c7                	jmp    800bb6 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bef:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bf3:	74 0e                	je     800c03 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bf5:	85 db                	test   %ebx,%ebx
  800bf7:	75 d8                	jne    800bd1 <strtol+0x44>
		s++, base = 8;
  800bf9:	83 c1 01             	add    $0x1,%ecx
  800bfc:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c01:	eb ce                	jmp    800bd1 <strtol+0x44>
		s += 2, base = 16;
  800c03:	83 c1 02             	add    $0x2,%ecx
  800c06:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c0b:	eb c4                	jmp    800bd1 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c0d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c10:	89 f3                	mov    %esi,%ebx
  800c12:	80 fb 19             	cmp    $0x19,%bl
  800c15:	77 29                	ja     800c40 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c17:	0f be d2             	movsbl %dl,%edx
  800c1a:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c1d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c20:	7d 30                	jge    800c52 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c22:	83 c1 01             	add    $0x1,%ecx
  800c25:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c29:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c2b:	0f b6 11             	movzbl (%ecx),%edx
  800c2e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c31:	89 f3                	mov    %esi,%ebx
  800c33:	80 fb 09             	cmp    $0x9,%bl
  800c36:	77 d5                	ja     800c0d <strtol+0x80>
			dig = *s - '0';
  800c38:	0f be d2             	movsbl %dl,%edx
  800c3b:	83 ea 30             	sub    $0x30,%edx
  800c3e:	eb dd                	jmp    800c1d <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800c40:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c43:	89 f3                	mov    %esi,%ebx
  800c45:	80 fb 19             	cmp    $0x19,%bl
  800c48:	77 08                	ja     800c52 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c4a:	0f be d2             	movsbl %dl,%edx
  800c4d:	83 ea 37             	sub    $0x37,%edx
  800c50:	eb cb                	jmp    800c1d <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c52:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c56:	74 05                	je     800c5d <strtol+0xd0>
		*endptr = (char *) s;
  800c58:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c5b:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c5d:	89 c2                	mov    %eax,%edx
  800c5f:	f7 da                	neg    %edx
  800c61:	85 ff                	test   %edi,%edi
  800c63:	0f 45 c2             	cmovne %edx,%eax
}
  800c66:	5b                   	pop    %ebx
  800c67:	5e                   	pop    %esi
  800c68:	5f                   	pop    %edi
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	57                   	push   %edi
  800c6f:	56                   	push   %esi
  800c70:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c71:	b8 00 00 00 00       	mov    $0x0,%eax
  800c76:	8b 55 08             	mov    0x8(%ebp),%edx
  800c79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7c:	89 c3                	mov    %eax,%ebx
  800c7e:	89 c7                	mov    %eax,%edi
  800c80:	89 c6                	mov    %eax,%esi
  800c82:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c84:	5b                   	pop    %ebx
  800c85:	5e                   	pop    %esi
  800c86:	5f                   	pop    %edi
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    

00800c89 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	57                   	push   %edi
  800c8d:	56                   	push   %esi
  800c8e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c8f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c94:	b8 01 00 00 00       	mov    $0x1,%eax
  800c99:	89 d1                	mov    %edx,%ecx
  800c9b:	89 d3                	mov    %edx,%ebx
  800c9d:	89 d7                	mov    %edx,%edi
  800c9f:	89 d6                	mov    %edx,%esi
  800ca1:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ca3:	5b                   	pop    %ebx
  800ca4:	5e                   	pop    %esi
  800ca5:	5f                   	pop    %edi
  800ca6:	5d                   	pop    %ebp
  800ca7:	c3                   	ret    

00800ca8 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	57                   	push   %edi
  800cac:	56                   	push   %esi
  800cad:	53                   	push   %ebx
  800cae:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cb1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb9:	b8 03 00 00 00       	mov    $0x3,%eax
  800cbe:	89 cb                	mov    %ecx,%ebx
  800cc0:	89 cf                	mov    %ecx,%edi
  800cc2:	89 ce                	mov    %ecx,%esi
  800cc4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cc6:	85 c0                	test   %eax,%eax
  800cc8:	7f 08                	jg     800cd2 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccd:	5b                   	pop    %ebx
  800cce:	5e                   	pop    %esi
  800ccf:	5f                   	pop    %edi
  800cd0:	5d                   	pop    %ebp
  800cd1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd2:	83 ec 0c             	sub    $0xc,%esp
  800cd5:	50                   	push   %eax
  800cd6:	6a 03                	push   $0x3
  800cd8:	68 1f 23 80 00       	push   $0x80231f
  800cdd:	6a 23                	push   $0x23
  800cdf:	68 3c 23 80 00       	push   $0x80233c
  800ce4:	e8 4b f5 ff ff       	call   800234 <_panic>

00800ce9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	57                   	push   %edi
  800ced:	56                   	push   %esi
  800cee:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cef:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf4:	b8 02 00 00 00       	mov    $0x2,%eax
  800cf9:	89 d1                	mov    %edx,%ecx
  800cfb:	89 d3                	mov    %edx,%ebx
  800cfd:	89 d7                	mov    %edx,%edi
  800cff:	89 d6                	mov    %edx,%esi
  800d01:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d03:	5b                   	pop    %ebx
  800d04:	5e                   	pop    %esi
  800d05:	5f                   	pop    %edi
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    

00800d08 <sys_yield>:

void
sys_yield(void)
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	57                   	push   %edi
  800d0c:	56                   	push   %esi
  800d0d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d13:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d18:	89 d1                	mov    %edx,%ecx
  800d1a:	89 d3                	mov    %edx,%ebx
  800d1c:	89 d7                	mov    %edx,%edi
  800d1e:	89 d6                	mov    %edx,%esi
  800d20:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d22:	5b                   	pop    %ebx
  800d23:	5e                   	pop    %esi
  800d24:	5f                   	pop    %edi
  800d25:	5d                   	pop    %ebp
  800d26:	c3                   	ret    

00800d27 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	57                   	push   %edi
  800d2b:	56                   	push   %esi
  800d2c:	53                   	push   %ebx
  800d2d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d30:	be 00 00 00 00       	mov    $0x0,%esi
  800d35:	8b 55 08             	mov    0x8(%ebp),%edx
  800d38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3b:	b8 04 00 00 00       	mov    $0x4,%eax
  800d40:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d43:	89 f7                	mov    %esi,%edi
  800d45:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d47:	85 c0                	test   %eax,%eax
  800d49:	7f 08                	jg     800d53 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4e:	5b                   	pop    %ebx
  800d4f:	5e                   	pop    %esi
  800d50:	5f                   	pop    %edi
  800d51:	5d                   	pop    %ebp
  800d52:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d53:	83 ec 0c             	sub    $0xc,%esp
  800d56:	50                   	push   %eax
  800d57:	6a 04                	push   $0x4
  800d59:	68 1f 23 80 00       	push   $0x80231f
  800d5e:	6a 23                	push   $0x23
  800d60:	68 3c 23 80 00       	push   $0x80233c
  800d65:	e8 ca f4 ff ff       	call   800234 <_panic>

00800d6a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d6a:	55                   	push   %ebp
  800d6b:	89 e5                	mov    %esp,%ebp
  800d6d:	57                   	push   %edi
  800d6e:	56                   	push   %esi
  800d6f:	53                   	push   %ebx
  800d70:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d73:	8b 55 08             	mov    0x8(%ebp),%edx
  800d76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d79:	b8 05 00 00 00       	mov    $0x5,%eax
  800d7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d81:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d84:	8b 75 18             	mov    0x18(%ebp),%esi
  800d87:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d89:	85 c0                	test   %eax,%eax
  800d8b:	7f 08                	jg     800d95 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d90:	5b                   	pop    %ebx
  800d91:	5e                   	pop    %esi
  800d92:	5f                   	pop    %edi
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d95:	83 ec 0c             	sub    $0xc,%esp
  800d98:	50                   	push   %eax
  800d99:	6a 05                	push   $0x5
  800d9b:	68 1f 23 80 00       	push   $0x80231f
  800da0:	6a 23                	push   $0x23
  800da2:	68 3c 23 80 00       	push   $0x80233c
  800da7:	e8 88 f4 ff ff       	call   800234 <_panic>

00800dac <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	57                   	push   %edi
  800db0:	56                   	push   %esi
  800db1:	53                   	push   %ebx
  800db2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800db5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dba:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc0:	b8 06 00 00 00       	mov    $0x6,%eax
  800dc5:	89 df                	mov    %ebx,%edi
  800dc7:	89 de                	mov    %ebx,%esi
  800dc9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dcb:	85 c0                	test   %eax,%eax
  800dcd:	7f 08                	jg     800dd7 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dcf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd2:	5b                   	pop    %ebx
  800dd3:	5e                   	pop    %esi
  800dd4:	5f                   	pop    %edi
  800dd5:	5d                   	pop    %ebp
  800dd6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd7:	83 ec 0c             	sub    $0xc,%esp
  800dda:	50                   	push   %eax
  800ddb:	6a 06                	push   $0x6
  800ddd:	68 1f 23 80 00       	push   $0x80231f
  800de2:	6a 23                	push   $0x23
  800de4:	68 3c 23 80 00       	push   $0x80233c
  800de9:	e8 46 f4 ff ff       	call   800234 <_panic>

00800dee <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dee:	55                   	push   %ebp
  800def:	89 e5                	mov    %esp,%ebp
  800df1:	57                   	push   %edi
  800df2:	56                   	push   %esi
  800df3:	53                   	push   %ebx
  800df4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800df7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e02:	b8 08 00 00 00       	mov    $0x8,%eax
  800e07:	89 df                	mov    %ebx,%edi
  800e09:	89 de                	mov    %ebx,%esi
  800e0b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e0d:	85 c0                	test   %eax,%eax
  800e0f:	7f 08                	jg     800e19 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e14:	5b                   	pop    %ebx
  800e15:	5e                   	pop    %esi
  800e16:	5f                   	pop    %edi
  800e17:	5d                   	pop    %ebp
  800e18:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e19:	83 ec 0c             	sub    $0xc,%esp
  800e1c:	50                   	push   %eax
  800e1d:	6a 08                	push   $0x8
  800e1f:	68 1f 23 80 00       	push   $0x80231f
  800e24:	6a 23                	push   $0x23
  800e26:	68 3c 23 80 00       	push   $0x80233c
  800e2b:	e8 04 f4 ff ff       	call   800234 <_panic>

00800e30 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e30:	55                   	push   %ebp
  800e31:	89 e5                	mov    %esp,%ebp
  800e33:	57                   	push   %edi
  800e34:	56                   	push   %esi
  800e35:	53                   	push   %ebx
  800e36:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e39:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e44:	b8 09 00 00 00       	mov    $0x9,%eax
  800e49:	89 df                	mov    %ebx,%edi
  800e4b:	89 de                	mov    %ebx,%esi
  800e4d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e4f:	85 c0                	test   %eax,%eax
  800e51:	7f 08                	jg     800e5b <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e56:	5b                   	pop    %ebx
  800e57:	5e                   	pop    %esi
  800e58:	5f                   	pop    %edi
  800e59:	5d                   	pop    %ebp
  800e5a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e5b:	83 ec 0c             	sub    $0xc,%esp
  800e5e:	50                   	push   %eax
  800e5f:	6a 09                	push   $0x9
  800e61:	68 1f 23 80 00       	push   $0x80231f
  800e66:	6a 23                	push   $0x23
  800e68:	68 3c 23 80 00       	push   $0x80233c
  800e6d:	e8 c2 f3 ff ff       	call   800234 <_panic>

00800e72 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e72:	55                   	push   %ebp
  800e73:	89 e5                	mov    %esp,%ebp
  800e75:	57                   	push   %edi
  800e76:	56                   	push   %esi
  800e77:	53                   	push   %ebx
  800e78:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e7b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e80:	8b 55 08             	mov    0x8(%ebp),%edx
  800e83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e86:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e8b:	89 df                	mov    %ebx,%edi
  800e8d:	89 de                	mov    %ebx,%esi
  800e8f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e91:	85 c0                	test   %eax,%eax
  800e93:	7f 08                	jg     800e9d <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e98:	5b                   	pop    %ebx
  800e99:	5e                   	pop    %esi
  800e9a:	5f                   	pop    %edi
  800e9b:	5d                   	pop    %ebp
  800e9c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e9d:	83 ec 0c             	sub    $0xc,%esp
  800ea0:	50                   	push   %eax
  800ea1:	6a 0a                	push   $0xa
  800ea3:	68 1f 23 80 00       	push   $0x80231f
  800ea8:	6a 23                	push   $0x23
  800eaa:	68 3c 23 80 00       	push   $0x80233c
  800eaf:	e8 80 f3 ff ff       	call   800234 <_panic>

00800eb4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	57                   	push   %edi
  800eb8:	56                   	push   %esi
  800eb9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800eba:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec0:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ec5:	be 00 00 00 00       	mov    $0x0,%esi
  800eca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ecd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ed0:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ed2:	5b                   	pop    %ebx
  800ed3:	5e                   	pop    %esi
  800ed4:	5f                   	pop    %edi
  800ed5:	5d                   	pop    %ebp
  800ed6:	c3                   	ret    

00800ed7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ed7:	55                   	push   %ebp
  800ed8:	89 e5                	mov    %esp,%ebp
  800eda:	57                   	push   %edi
  800edb:	56                   	push   %esi
  800edc:	53                   	push   %ebx
  800edd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ee0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ee5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee8:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eed:	89 cb                	mov    %ecx,%ebx
  800eef:	89 cf                	mov    %ecx,%edi
  800ef1:	89 ce                	mov    %ecx,%esi
  800ef3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ef5:	85 c0                	test   %eax,%eax
  800ef7:	7f 08                	jg     800f01 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ef9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800efc:	5b                   	pop    %ebx
  800efd:	5e                   	pop    %esi
  800efe:	5f                   	pop    %edi
  800eff:	5d                   	pop    %ebp
  800f00:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f01:	83 ec 0c             	sub    $0xc,%esp
  800f04:	50                   	push   %eax
  800f05:	6a 0d                	push   $0xd
  800f07:	68 1f 23 80 00       	push   $0x80231f
  800f0c:	6a 23                	push   $0x23
  800f0e:	68 3c 23 80 00       	push   $0x80233c
  800f13:	e8 1c f3 ff ff       	call   800234 <_panic>

00800f18 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f18:	55                   	push   %ebp
  800f19:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1e:	05 00 00 00 30       	add    $0x30000000,%eax
  800f23:	c1 e8 0c             	shr    $0xc,%eax
}
  800f26:	5d                   	pop    %ebp
  800f27:	c3                   	ret    

00800f28 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f28:	55                   	push   %ebp
  800f29:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2e:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800f33:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f38:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f3d:	5d                   	pop    %ebp
  800f3e:	c3                   	ret    

00800f3f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f3f:	55                   	push   %ebp
  800f40:	89 e5                	mov    %esp,%ebp
  800f42:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f45:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f4a:	89 c2                	mov    %eax,%edx
  800f4c:	c1 ea 16             	shr    $0x16,%edx
  800f4f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f56:	f6 c2 01             	test   $0x1,%dl
  800f59:	74 2a                	je     800f85 <fd_alloc+0x46>
  800f5b:	89 c2                	mov    %eax,%edx
  800f5d:	c1 ea 0c             	shr    $0xc,%edx
  800f60:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f67:	f6 c2 01             	test   $0x1,%dl
  800f6a:	74 19                	je     800f85 <fd_alloc+0x46>
  800f6c:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800f71:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f76:	75 d2                	jne    800f4a <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f78:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f7e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800f83:	eb 07                	jmp    800f8c <fd_alloc+0x4d>
			*fd_store = fd;
  800f85:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f87:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f8c:	5d                   	pop    %ebp
  800f8d:	c3                   	ret    

00800f8e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f8e:	55                   	push   %ebp
  800f8f:	89 e5                	mov    %esp,%ebp
  800f91:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f94:	83 f8 1f             	cmp    $0x1f,%eax
  800f97:	77 36                	ja     800fcf <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f99:	c1 e0 0c             	shl    $0xc,%eax
  800f9c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fa1:	89 c2                	mov    %eax,%edx
  800fa3:	c1 ea 16             	shr    $0x16,%edx
  800fa6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fad:	f6 c2 01             	test   $0x1,%dl
  800fb0:	74 24                	je     800fd6 <fd_lookup+0x48>
  800fb2:	89 c2                	mov    %eax,%edx
  800fb4:	c1 ea 0c             	shr    $0xc,%edx
  800fb7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fbe:	f6 c2 01             	test   $0x1,%dl
  800fc1:	74 1a                	je     800fdd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fc3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fc6:	89 02                	mov    %eax,(%edx)
	return 0;
  800fc8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fcd:	5d                   	pop    %ebp
  800fce:	c3                   	ret    
		return -E_INVAL;
  800fcf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fd4:	eb f7                	jmp    800fcd <fd_lookup+0x3f>
		return -E_INVAL;
  800fd6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fdb:	eb f0                	jmp    800fcd <fd_lookup+0x3f>
  800fdd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fe2:	eb e9                	jmp    800fcd <fd_lookup+0x3f>

00800fe4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
  800fe7:	83 ec 08             	sub    $0x8,%esp
  800fea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fed:	ba cc 23 80 00       	mov    $0x8023cc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ff2:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800ff7:	39 08                	cmp    %ecx,(%eax)
  800ff9:	74 33                	je     80102e <dev_lookup+0x4a>
  800ffb:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800ffe:	8b 02                	mov    (%edx),%eax
  801000:	85 c0                	test   %eax,%eax
  801002:	75 f3                	jne    800ff7 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801004:	a1 04 40 80 00       	mov    0x804004,%eax
  801009:	8b 40 48             	mov    0x48(%eax),%eax
  80100c:	83 ec 04             	sub    $0x4,%esp
  80100f:	51                   	push   %ecx
  801010:	50                   	push   %eax
  801011:	68 4c 23 80 00       	push   $0x80234c
  801016:	e8 f4 f2 ff ff       	call   80030f <cprintf>
	*dev = 0;
  80101b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80101e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801024:	83 c4 10             	add    $0x10,%esp
  801027:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80102c:	c9                   	leave  
  80102d:	c3                   	ret    
			*dev = devtab[i];
  80102e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801031:	89 01                	mov    %eax,(%ecx)
			return 0;
  801033:	b8 00 00 00 00       	mov    $0x0,%eax
  801038:	eb f2                	jmp    80102c <dev_lookup+0x48>

0080103a <fd_close>:
{
  80103a:	55                   	push   %ebp
  80103b:	89 e5                	mov    %esp,%ebp
  80103d:	57                   	push   %edi
  80103e:	56                   	push   %esi
  80103f:	53                   	push   %ebx
  801040:	83 ec 1c             	sub    $0x1c,%esp
  801043:	8b 75 08             	mov    0x8(%ebp),%esi
  801046:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801049:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80104c:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80104d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801053:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801056:	50                   	push   %eax
  801057:	e8 32 ff ff ff       	call   800f8e <fd_lookup>
  80105c:	89 c3                	mov    %eax,%ebx
  80105e:	83 c4 08             	add    $0x8,%esp
  801061:	85 c0                	test   %eax,%eax
  801063:	78 05                	js     80106a <fd_close+0x30>
	    || fd != fd2)
  801065:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801068:	74 16                	je     801080 <fd_close+0x46>
		return (must_exist ? r : 0);
  80106a:	89 f8                	mov    %edi,%eax
  80106c:	84 c0                	test   %al,%al
  80106e:	b8 00 00 00 00       	mov    $0x0,%eax
  801073:	0f 44 d8             	cmove  %eax,%ebx
}
  801076:	89 d8                	mov    %ebx,%eax
  801078:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80107b:	5b                   	pop    %ebx
  80107c:	5e                   	pop    %esi
  80107d:	5f                   	pop    %edi
  80107e:	5d                   	pop    %ebp
  80107f:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801080:	83 ec 08             	sub    $0x8,%esp
  801083:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801086:	50                   	push   %eax
  801087:	ff 36                	pushl  (%esi)
  801089:	e8 56 ff ff ff       	call   800fe4 <dev_lookup>
  80108e:	89 c3                	mov    %eax,%ebx
  801090:	83 c4 10             	add    $0x10,%esp
  801093:	85 c0                	test   %eax,%eax
  801095:	78 15                	js     8010ac <fd_close+0x72>
		if (dev->dev_close)
  801097:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80109a:	8b 40 10             	mov    0x10(%eax),%eax
  80109d:	85 c0                	test   %eax,%eax
  80109f:	74 1b                	je     8010bc <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8010a1:	83 ec 0c             	sub    $0xc,%esp
  8010a4:	56                   	push   %esi
  8010a5:	ff d0                	call   *%eax
  8010a7:	89 c3                	mov    %eax,%ebx
  8010a9:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8010ac:	83 ec 08             	sub    $0x8,%esp
  8010af:	56                   	push   %esi
  8010b0:	6a 00                	push   $0x0
  8010b2:	e8 f5 fc ff ff       	call   800dac <sys_page_unmap>
	return r;
  8010b7:	83 c4 10             	add    $0x10,%esp
  8010ba:	eb ba                	jmp    801076 <fd_close+0x3c>
			r = 0;
  8010bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010c1:	eb e9                	jmp    8010ac <fd_close+0x72>

008010c3 <close>:

int
close(int fdnum)
{
  8010c3:	55                   	push   %ebp
  8010c4:	89 e5                	mov    %esp,%ebp
  8010c6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010cc:	50                   	push   %eax
  8010cd:	ff 75 08             	pushl  0x8(%ebp)
  8010d0:	e8 b9 fe ff ff       	call   800f8e <fd_lookup>
  8010d5:	83 c4 08             	add    $0x8,%esp
  8010d8:	85 c0                	test   %eax,%eax
  8010da:	78 10                	js     8010ec <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8010dc:	83 ec 08             	sub    $0x8,%esp
  8010df:	6a 01                	push   $0x1
  8010e1:	ff 75 f4             	pushl  -0xc(%ebp)
  8010e4:	e8 51 ff ff ff       	call   80103a <fd_close>
  8010e9:	83 c4 10             	add    $0x10,%esp
}
  8010ec:	c9                   	leave  
  8010ed:	c3                   	ret    

008010ee <close_all>:

void
close_all(void)
{
  8010ee:	55                   	push   %ebp
  8010ef:	89 e5                	mov    %esp,%ebp
  8010f1:	53                   	push   %ebx
  8010f2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010f5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010fa:	83 ec 0c             	sub    $0xc,%esp
  8010fd:	53                   	push   %ebx
  8010fe:	e8 c0 ff ff ff       	call   8010c3 <close>
	for (i = 0; i < MAXFD; i++)
  801103:	83 c3 01             	add    $0x1,%ebx
  801106:	83 c4 10             	add    $0x10,%esp
  801109:	83 fb 20             	cmp    $0x20,%ebx
  80110c:	75 ec                	jne    8010fa <close_all+0xc>
}
  80110e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801111:	c9                   	leave  
  801112:	c3                   	ret    

00801113 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801113:	55                   	push   %ebp
  801114:	89 e5                	mov    %esp,%ebp
  801116:	57                   	push   %edi
  801117:	56                   	push   %esi
  801118:	53                   	push   %ebx
  801119:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80111c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80111f:	50                   	push   %eax
  801120:	ff 75 08             	pushl  0x8(%ebp)
  801123:	e8 66 fe ff ff       	call   800f8e <fd_lookup>
  801128:	89 c3                	mov    %eax,%ebx
  80112a:	83 c4 08             	add    $0x8,%esp
  80112d:	85 c0                	test   %eax,%eax
  80112f:	0f 88 81 00 00 00    	js     8011b6 <dup+0xa3>
		return r;
	close(newfdnum);
  801135:	83 ec 0c             	sub    $0xc,%esp
  801138:	ff 75 0c             	pushl  0xc(%ebp)
  80113b:	e8 83 ff ff ff       	call   8010c3 <close>

	newfd = INDEX2FD(newfdnum);
  801140:	8b 75 0c             	mov    0xc(%ebp),%esi
  801143:	c1 e6 0c             	shl    $0xc,%esi
  801146:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80114c:	83 c4 04             	add    $0x4,%esp
  80114f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801152:	e8 d1 fd ff ff       	call   800f28 <fd2data>
  801157:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801159:	89 34 24             	mov    %esi,(%esp)
  80115c:	e8 c7 fd ff ff       	call   800f28 <fd2data>
  801161:	83 c4 10             	add    $0x10,%esp
  801164:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801166:	89 d8                	mov    %ebx,%eax
  801168:	c1 e8 16             	shr    $0x16,%eax
  80116b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801172:	a8 01                	test   $0x1,%al
  801174:	74 11                	je     801187 <dup+0x74>
  801176:	89 d8                	mov    %ebx,%eax
  801178:	c1 e8 0c             	shr    $0xc,%eax
  80117b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801182:	f6 c2 01             	test   $0x1,%dl
  801185:	75 39                	jne    8011c0 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801187:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80118a:	89 d0                	mov    %edx,%eax
  80118c:	c1 e8 0c             	shr    $0xc,%eax
  80118f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801196:	83 ec 0c             	sub    $0xc,%esp
  801199:	25 07 0e 00 00       	and    $0xe07,%eax
  80119e:	50                   	push   %eax
  80119f:	56                   	push   %esi
  8011a0:	6a 00                	push   $0x0
  8011a2:	52                   	push   %edx
  8011a3:	6a 00                	push   $0x0
  8011a5:	e8 c0 fb ff ff       	call   800d6a <sys_page_map>
  8011aa:	89 c3                	mov    %eax,%ebx
  8011ac:	83 c4 20             	add    $0x20,%esp
  8011af:	85 c0                	test   %eax,%eax
  8011b1:	78 31                	js     8011e4 <dup+0xd1>
		goto err;

	return newfdnum;
  8011b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8011b6:	89 d8                	mov    %ebx,%eax
  8011b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011bb:	5b                   	pop    %ebx
  8011bc:	5e                   	pop    %esi
  8011bd:	5f                   	pop    %edi
  8011be:	5d                   	pop    %ebp
  8011bf:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011c0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011c7:	83 ec 0c             	sub    $0xc,%esp
  8011ca:	25 07 0e 00 00       	and    $0xe07,%eax
  8011cf:	50                   	push   %eax
  8011d0:	57                   	push   %edi
  8011d1:	6a 00                	push   $0x0
  8011d3:	53                   	push   %ebx
  8011d4:	6a 00                	push   $0x0
  8011d6:	e8 8f fb ff ff       	call   800d6a <sys_page_map>
  8011db:	89 c3                	mov    %eax,%ebx
  8011dd:	83 c4 20             	add    $0x20,%esp
  8011e0:	85 c0                	test   %eax,%eax
  8011e2:	79 a3                	jns    801187 <dup+0x74>
	sys_page_unmap(0, newfd);
  8011e4:	83 ec 08             	sub    $0x8,%esp
  8011e7:	56                   	push   %esi
  8011e8:	6a 00                	push   $0x0
  8011ea:	e8 bd fb ff ff       	call   800dac <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011ef:	83 c4 08             	add    $0x8,%esp
  8011f2:	57                   	push   %edi
  8011f3:	6a 00                	push   $0x0
  8011f5:	e8 b2 fb ff ff       	call   800dac <sys_page_unmap>
	return r;
  8011fa:	83 c4 10             	add    $0x10,%esp
  8011fd:	eb b7                	jmp    8011b6 <dup+0xa3>

008011ff <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011ff:	55                   	push   %ebp
  801200:	89 e5                	mov    %esp,%ebp
  801202:	53                   	push   %ebx
  801203:	83 ec 14             	sub    $0x14,%esp
  801206:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801209:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80120c:	50                   	push   %eax
  80120d:	53                   	push   %ebx
  80120e:	e8 7b fd ff ff       	call   800f8e <fd_lookup>
  801213:	83 c4 08             	add    $0x8,%esp
  801216:	85 c0                	test   %eax,%eax
  801218:	78 3f                	js     801259 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80121a:	83 ec 08             	sub    $0x8,%esp
  80121d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801220:	50                   	push   %eax
  801221:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801224:	ff 30                	pushl  (%eax)
  801226:	e8 b9 fd ff ff       	call   800fe4 <dev_lookup>
  80122b:	83 c4 10             	add    $0x10,%esp
  80122e:	85 c0                	test   %eax,%eax
  801230:	78 27                	js     801259 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801232:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801235:	8b 42 08             	mov    0x8(%edx),%eax
  801238:	83 e0 03             	and    $0x3,%eax
  80123b:	83 f8 01             	cmp    $0x1,%eax
  80123e:	74 1e                	je     80125e <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801240:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801243:	8b 40 08             	mov    0x8(%eax),%eax
  801246:	85 c0                	test   %eax,%eax
  801248:	74 35                	je     80127f <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80124a:	83 ec 04             	sub    $0x4,%esp
  80124d:	ff 75 10             	pushl  0x10(%ebp)
  801250:	ff 75 0c             	pushl  0xc(%ebp)
  801253:	52                   	push   %edx
  801254:	ff d0                	call   *%eax
  801256:	83 c4 10             	add    $0x10,%esp
}
  801259:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80125c:	c9                   	leave  
  80125d:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80125e:	a1 04 40 80 00       	mov    0x804004,%eax
  801263:	8b 40 48             	mov    0x48(%eax),%eax
  801266:	83 ec 04             	sub    $0x4,%esp
  801269:	53                   	push   %ebx
  80126a:	50                   	push   %eax
  80126b:	68 90 23 80 00       	push   $0x802390
  801270:	e8 9a f0 ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  801275:	83 c4 10             	add    $0x10,%esp
  801278:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80127d:	eb da                	jmp    801259 <read+0x5a>
		return -E_NOT_SUPP;
  80127f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801284:	eb d3                	jmp    801259 <read+0x5a>

00801286 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801286:	55                   	push   %ebp
  801287:	89 e5                	mov    %esp,%ebp
  801289:	57                   	push   %edi
  80128a:	56                   	push   %esi
  80128b:	53                   	push   %ebx
  80128c:	83 ec 0c             	sub    $0xc,%esp
  80128f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801292:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801295:	bb 00 00 00 00       	mov    $0x0,%ebx
  80129a:	39 f3                	cmp    %esi,%ebx
  80129c:	73 25                	jae    8012c3 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80129e:	83 ec 04             	sub    $0x4,%esp
  8012a1:	89 f0                	mov    %esi,%eax
  8012a3:	29 d8                	sub    %ebx,%eax
  8012a5:	50                   	push   %eax
  8012a6:	89 d8                	mov    %ebx,%eax
  8012a8:	03 45 0c             	add    0xc(%ebp),%eax
  8012ab:	50                   	push   %eax
  8012ac:	57                   	push   %edi
  8012ad:	e8 4d ff ff ff       	call   8011ff <read>
		if (m < 0)
  8012b2:	83 c4 10             	add    $0x10,%esp
  8012b5:	85 c0                	test   %eax,%eax
  8012b7:	78 08                	js     8012c1 <readn+0x3b>
			return m;
		if (m == 0)
  8012b9:	85 c0                	test   %eax,%eax
  8012bb:	74 06                	je     8012c3 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  8012bd:	01 c3                	add    %eax,%ebx
  8012bf:	eb d9                	jmp    80129a <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012c1:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8012c3:	89 d8                	mov    %ebx,%eax
  8012c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c8:	5b                   	pop    %ebx
  8012c9:	5e                   	pop    %esi
  8012ca:	5f                   	pop    %edi
  8012cb:	5d                   	pop    %ebp
  8012cc:	c3                   	ret    

008012cd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012cd:	55                   	push   %ebp
  8012ce:	89 e5                	mov    %esp,%ebp
  8012d0:	53                   	push   %ebx
  8012d1:	83 ec 14             	sub    $0x14,%esp
  8012d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012da:	50                   	push   %eax
  8012db:	53                   	push   %ebx
  8012dc:	e8 ad fc ff ff       	call   800f8e <fd_lookup>
  8012e1:	83 c4 08             	add    $0x8,%esp
  8012e4:	85 c0                	test   %eax,%eax
  8012e6:	78 3a                	js     801322 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e8:	83 ec 08             	sub    $0x8,%esp
  8012eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ee:	50                   	push   %eax
  8012ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f2:	ff 30                	pushl  (%eax)
  8012f4:	e8 eb fc ff ff       	call   800fe4 <dev_lookup>
  8012f9:	83 c4 10             	add    $0x10,%esp
  8012fc:	85 c0                	test   %eax,%eax
  8012fe:	78 22                	js     801322 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801300:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801303:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801307:	74 1e                	je     801327 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801309:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80130c:	8b 52 0c             	mov    0xc(%edx),%edx
  80130f:	85 d2                	test   %edx,%edx
  801311:	74 35                	je     801348 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801313:	83 ec 04             	sub    $0x4,%esp
  801316:	ff 75 10             	pushl  0x10(%ebp)
  801319:	ff 75 0c             	pushl  0xc(%ebp)
  80131c:	50                   	push   %eax
  80131d:	ff d2                	call   *%edx
  80131f:	83 c4 10             	add    $0x10,%esp
}
  801322:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801325:	c9                   	leave  
  801326:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801327:	a1 04 40 80 00       	mov    0x804004,%eax
  80132c:	8b 40 48             	mov    0x48(%eax),%eax
  80132f:	83 ec 04             	sub    $0x4,%esp
  801332:	53                   	push   %ebx
  801333:	50                   	push   %eax
  801334:	68 ac 23 80 00       	push   $0x8023ac
  801339:	e8 d1 ef ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  80133e:	83 c4 10             	add    $0x10,%esp
  801341:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801346:	eb da                	jmp    801322 <write+0x55>
		return -E_NOT_SUPP;
  801348:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80134d:	eb d3                	jmp    801322 <write+0x55>

0080134f <seek>:

int
seek(int fdnum, off_t offset)
{
  80134f:	55                   	push   %ebp
  801350:	89 e5                	mov    %esp,%ebp
  801352:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801355:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801358:	50                   	push   %eax
  801359:	ff 75 08             	pushl  0x8(%ebp)
  80135c:	e8 2d fc ff ff       	call   800f8e <fd_lookup>
  801361:	83 c4 08             	add    $0x8,%esp
  801364:	85 c0                	test   %eax,%eax
  801366:	78 0e                	js     801376 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801368:	8b 55 0c             	mov    0xc(%ebp),%edx
  80136b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80136e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801371:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801376:	c9                   	leave  
  801377:	c3                   	ret    

00801378 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801378:	55                   	push   %ebp
  801379:	89 e5                	mov    %esp,%ebp
  80137b:	53                   	push   %ebx
  80137c:	83 ec 14             	sub    $0x14,%esp
  80137f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801382:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801385:	50                   	push   %eax
  801386:	53                   	push   %ebx
  801387:	e8 02 fc ff ff       	call   800f8e <fd_lookup>
  80138c:	83 c4 08             	add    $0x8,%esp
  80138f:	85 c0                	test   %eax,%eax
  801391:	78 37                	js     8013ca <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801393:	83 ec 08             	sub    $0x8,%esp
  801396:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801399:	50                   	push   %eax
  80139a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80139d:	ff 30                	pushl  (%eax)
  80139f:	e8 40 fc ff ff       	call   800fe4 <dev_lookup>
  8013a4:	83 c4 10             	add    $0x10,%esp
  8013a7:	85 c0                	test   %eax,%eax
  8013a9:	78 1f                	js     8013ca <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ae:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013b2:	74 1b                	je     8013cf <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8013b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013b7:	8b 52 18             	mov    0x18(%edx),%edx
  8013ba:	85 d2                	test   %edx,%edx
  8013bc:	74 32                	je     8013f0 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013be:	83 ec 08             	sub    $0x8,%esp
  8013c1:	ff 75 0c             	pushl  0xc(%ebp)
  8013c4:	50                   	push   %eax
  8013c5:	ff d2                	call   *%edx
  8013c7:	83 c4 10             	add    $0x10,%esp
}
  8013ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013cd:	c9                   	leave  
  8013ce:	c3                   	ret    
			thisenv->env_id, fdnum);
  8013cf:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013d4:	8b 40 48             	mov    0x48(%eax),%eax
  8013d7:	83 ec 04             	sub    $0x4,%esp
  8013da:	53                   	push   %ebx
  8013db:	50                   	push   %eax
  8013dc:	68 6c 23 80 00       	push   $0x80236c
  8013e1:	e8 29 ef ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  8013e6:	83 c4 10             	add    $0x10,%esp
  8013e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013ee:	eb da                	jmp    8013ca <ftruncate+0x52>
		return -E_NOT_SUPP;
  8013f0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013f5:	eb d3                	jmp    8013ca <ftruncate+0x52>

008013f7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013f7:	55                   	push   %ebp
  8013f8:	89 e5                	mov    %esp,%ebp
  8013fa:	53                   	push   %ebx
  8013fb:	83 ec 14             	sub    $0x14,%esp
  8013fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801401:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801404:	50                   	push   %eax
  801405:	ff 75 08             	pushl  0x8(%ebp)
  801408:	e8 81 fb ff ff       	call   800f8e <fd_lookup>
  80140d:	83 c4 08             	add    $0x8,%esp
  801410:	85 c0                	test   %eax,%eax
  801412:	78 4b                	js     80145f <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801414:	83 ec 08             	sub    $0x8,%esp
  801417:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80141a:	50                   	push   %eax
  80141b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80141e:	ff 30                	pushl  (%eax)
  801420:	e8 bf fb ff ff       	call   800fe4 <dev_lookup>
  801425:	83 c4 10             	add    $0x10,%esp
  801428:	85 c0                	test   %eax,%eax
  80142a:	78 33                	js     80145f <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  80142c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80142f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801433:	74 2f                	je     801464 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801435:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801438:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80143f:	00 00 00 
	stat->st_isdir = 0;
  801442:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801449:	00 00 00 
	stat->st_dev = dev;
  80144c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801452:	83 ec 08             	sub    $0x8,%esp
  801455:	53                   	push   %ebx
  801456:	ff 75 f0             	pushl  -0x10(%ebp)
  801459:	ff 50 14             	call   *0x14(%eax)
  80145c:	83 c4 10             	add    $0x10,%esp
}
  80145f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801462:	c9                   	leave  
  801463:	c3                   	ret    
		return -E_NOT_SUPP;
  801464:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801469:	eb f4                	jmp    80145f <fstat+0x68>

0080146b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80146b:	55                   	push   %ebp
  80146c:	89 e5                	mov    %esp,%ebp
  80146e:	56                   	push   %esi
  80146f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801470:	83 ec 08             	sub    $0x8,%esp
  801473:	6a 00                	push   $0x0
  801475:	ff 75 08             	pushl  0x8(%ebp)
  801478:	e8 e7 01 00 00       	call   801664 <open>
  80147d:	89 c3                	mov    %eax,%ebx
  80147f:	83 c4 10             	add    $0x10,%esp
  801482:	85 c0                	test   %eax,%eax
  801484:	78 1b                	js     8014a1 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801486:	83 ec 08             	sub    $0x8,%esp
  801489:	ff 75 0c             	pushl  0xc(%ebp)
  80148c:	50                   	push   %eax
  80148d:	e8 65 ff ff ff       	call   8013f7 <fstat>
  801492:	89 c6                	mov    %eax,%esi
	close(fd);
  801494:	89 1c 24             	mov    %ebx,(%esp)
  801497:	e8 27 fc ff ff       	call   8010c3 <close>
	return r;
  80149c:	83 c4 10             	add    $0x10,%esp
  80149f:	89 f3                	mov    %esi,%ebx
}
  8014a1:	89 d8                	mov    %ebx,%eax
  8014a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014a6:	5b                   	pop    %ebx
  8014a7:	5e                   	pop    %esi
  8014a8:	5d                   	pop    %ebp
  8014a9:	c3                   	ret    

008014aa <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014aa:	55                   	push   %ebp
  8014ab:	89 e5                	mov    %esp,%ebp
  8014ad:	56                   	push   %esi
  8014ae:	53                   	push   %ebx
  8014af:	89 c6                	mov    %eax,%esi
  8014b1:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8014b3:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014ba:	74 27                	je     8014e3 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014bc:	6a 07                	push   $0x7
  8014be:	68 00 50 80 00       	push   $0x805000
  8014c3:	56                   	push   %esi
  8014c4:	ff 35 00 40 80 00    	pushl  0x804000
  8014ca:	e8 79 07 00 00       	call   801c48 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014cf:	83 c4 0c             	add    $0xc,%esp
  8014d2:	6a 00                	push   $0x0
  8014d4:	53                   	push   %ebx
  8014d5:	6a 00                	push   $0x0
  8014d7:	e8 f7 06 00 00       	call   801bd3 <ipc_recv>
}
  8014dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014df:	5b                   	pop    %ebx
  8014e0:	5e                   	pop    %esi
  8014e1:	5d                   	pop    %ebp
  8014e2:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014e3:	83 ec 0c             	sub    $0xc,%esp
  8014e6:	6a 01                	push   $0x1
  8014e8:	e8 b1 07 00 00       	call   801c9e <ipc_find_env>
  8014ed:	a3 00 40 80 00       	mov    %eax,0x804000
  8014f2:	83 c4 10             	add    $0x10,%esp
  8014f5:	eb c5                	jmp    8014bc <fsipc+0x12>

008014f7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014f7:	55                   	push   %ebp
  8014f8:	89 e5                	mov    %esp,%ebp
  8014fa:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801500:	8b 40 0c             	mov    0xc(%eax),%eax
  801503:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801508:	8b 45 0c             	mov    0xc(%ebp),%eax
  80150b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801510:	ba 00 00 00 00       	mov    $0x0,%edx
  801515:	b8 02 00 00 00       	mov    $0x2,%eax
  80151a:	e8 8b ff ff ff       	call   8014aa <fsipc>
}
  80151f:	c9                   	leave  
  801520:	c3                   	ret    

00801521 <devfile_flush>:
{
  801521:	55                   	push   %ebp
  801522:	89 e5                	mov    %esp,%ebp
  801524:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801527:	8b 45 08             	mov    0x8(%ebp),%eax
  80152a:	8b 40 0c             	mov    0xc(%eax),%eax
  80152d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801532:	ba 00 00 00 00       	mov    $0x0,%edx
  801537:	b8 06 00 00 00       	mov    $0x6,%eax
  80153c:	e8 69 ff ff ff       	call   8014aa <fsipc>
}
  801541:	c9                   	leave  
  801542:	c3                   	ret    

00801543 <devfile_stat>:
{
  801543:	55                   	push   %ebp
  801544:	89 e5                	mov    %esp,%ebp
  801546:	53                   	push   %ebx
  801547:	83 ec 04             	sub    $0x4,%esp
  80154a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80154d:	8b 45 08             	mov    0x8(%ebp),%eax
  801550:	8b 40 0c             	mov    0xc(%eax),%eax
  801553:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801558:	ba 00 00 00 00       	mov    $0x0,%edx
  80155d:	b8 05 00 00 00       	mov    $0x5,%eax
  801562:	e8 43 ff ff ff       	call   8014aa <fsipc>
  801567:	85 c0                	test   %eax,%eax
  801569:	78 2c                	js     801597 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80156b:	83 ec 08             	sub    $0x8,%esp
  80156e:	68 00 50 80 00       	push   $0x805000
  801573:	53                   	push   %ebx
  801574:	e8 b5 f3 ff ff       	call   80092e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801579:	a1 80 50 80 00       	mov    0x805080,%eax
  80157e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801584:	a1 84 50 80 00       	mov    0x805084,%eax
  801589:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80158f:	83 c4 10             	add    $0x10,%esp
  801592:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801597:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80159a:	c9                   	leave  
  80159b:	c3                   	ret    

0080159c <devfile_write>:
{
  80159c:	55                   	push   %ebp
  80159d:	89 e5                	mov    %esp,%ebp
  80159f:	83 ec 0c             	sub    $0xc,%esp
  8015a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8015a5:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8015aa:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8015af:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8015b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8015b5:	8b 52 0c             	mov    0xc(%edx),%edx
  8015b8:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8015be:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf,buf,n);
  8015c3:	50                   	push   %eax
  8015c4:	ff 75 0c             	pushl  0xc(%ebp)
  8015c7:	68 08 50 80 00       	push   $0x805008
  8015cc:	e8 eb f4 ff ff       	call   800abc <memmove>
	if((r = fsipc(FSREQ_WRITE,NULL))<0)
  8015d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d6:	b8 04 00 00 00       	mov    $0x4,%eax
  8015db:	e8 ca fe ff ff       	call   8014aa <fsipc>
}
  8015e0:	c9                   	leave  
  8015e1:	c3                   	ret    

008015e2 <devfile_read>:
{
  8015e2:	55                   	push   %ebp
  8015e3:	89 e5                	mov    %esp,%ebp
  8015e5:	56                   	push   %esi
  8015e6:	53                   	push   %ebx
  8015e7:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8015f0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015f5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801600:	b8 03 00 00 00       	mov    $0x3,%eax
  801605:	e8 a0 fe ff ff       	call   8014aa <fsipc>
  80160a:	89 c3                	mov    %eax,%ebx
  80160c:	85 c0                	test   %eax,%eax
  80160e:	78 1f                	js     80162f <devfile_read+0x4d>
	assert(r <= n);
  801610:	39 f0                	cmp    %esi,%eax
  801612:	77 24                	ja     801638 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801614:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801619:	7f 33                	jg     80164e <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80161b:	83 ec 04             	sub    $0x4,%esp
  80161e:	50                   	push   %eax
  80161f:	68 00 50 80 00       	push   $0x805000
  801624:	ff 75 0c             	pushl  0xc(%ebp)
  801627:	e8 90 f4 ff ff       	call   800abc <memmove>
	return r;
  80162c:	83 c4 10             	add    $0x10,%esp
}
  80162f:	89 d8                	mov    %ebx,%eax
  801631:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801634:	5b                   	pop    %ebx
  801635:	5e                   	pop    %esi
  801636:	5d                   	pop    %ebp
  801637:	c3                   	ret    
	assert(r <= n);
  801638:	68 dc 23 80 00       	push   $0x8023dc
  80163d:	68 e3 23 80 00       	push   $0x8023e3
  801642:	6a 7c                	push   $0x7c
  801644:	68 f8 23 80 00       	push   $0x8023f8
  801649:	e8 e6 eb ff ff       	call   800234 <_panic>
	assert(r <= PGSIZE);
  80164e:	68 03 24 80 00       	push   $0x802403
  801653:	68 e3 23 80 00       	push   $0x8023e3
  801658:	6a 7d                	push   $0x7d
  80165a:	68 f8 23 80 00       	push   $0x8023f8
  80165f:	e8 d0 eb ff ff       	call   800234 <_panic>

00801664 <open>:
{
  801664:	55                   	push   %ebp
  801665:	89 e5                	mov    %esp,%ebp
  801667:	56                   	push   %esi
  801668:	53                   	push   %ebx
  801669:	83 ec 1c             	sub    $0x1c,%esp
  80166c:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80166f:	56                   	push   %esi
  801670:	e8 82 f2 ff ff       	call   8008f7 <strlen>
  801675:	83 c4 10             	add    $0x10,%esp
  801678:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80167d:	7f 6c                	jg     8016eb <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  80167f:	83 ec 0c             	sub    $0xc,%esp
  801682:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801685:	50                   	push   %eax
  801686:	e8 b4 f8 ff ff       	call   800f3f <fd_alloc>
  80168b:	89 c3                	mov    %eax,%ebx
  80168d:	83 c4 10             	add    $0x10,%esp
  801690:	85 c0                	test   %eax,%eax
  801692:	78 3c                	js     8016d0 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801694:	83 ec 08             	sub    $0x8,%esp
  801697:	56                   	push   %esi
  801698:	68 00 50 80 00       	push   $0x805000
  80169d:	e8 8c f2 ff ff       	call   80092e <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016a5:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016ad:	b8 01 00 00 00       	mov    $0x1,%eax
  8016b2:	e8 f3 fd ff ff       	call   8014aa <fsipc>
  8016b7:	89 c3                	mov    %eax,%ebx
  8016b9:	83 c4 10             	add    $0x10,%esp
  8016bc:	85 c0                	test   %eax,%eax
  8016be:	78 19                	js     8016d9 <open+0x75>
	return fd2num(fd);
  8016c0:	83 ec 0c             	sub    $0xc,%esp
  8016c3:	ff 75 f4             	pushl  -0xc(%ebp)
  8016c6:	e8 4d f8 ff ff       	call   800f18 <fd2num>
  8016cb:	89 c3                	mov    %eax,%ebx
  8016cd:	83 c4 10             	add    $0x10,%esp
}
  8016d0:	89 d8                	mov    %ebx,%eax
  8016d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016d5:	5b                   	pop    %ebx
  8016d6:	5e                   	pop    %esi
  8016d7:	5d                   	pop    %ebp
  8016d8:	c3                   	ret    
		fd_close(fd, 0);
  8016d9:	83 ec 08             	sub    $0x8,%esp
  8016dc:	6a 00                	push   $0x0
  8016de:	ff 75 f4             	pushl  -0xc(%ebp)
  8016e1:	e8 54 f9 ff ff       	call   80103a <fd_close>
		return r;
  8016e6:	83 c4 10             	add    $0x10,%esp
  8016e9:	eb e5                	jmp    8016d0 <open+0x6c>
		return -E_BAD_PATH;
  8016eb:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8016f0:	eb de                	jmp    8016d0 <open+0x6c>

008016f2 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016f2:	55                   	push   %ebp
  8016f3:	89 e5                	mov    %esp,%ebp
  8016f5:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8016fd:	b8 08 00 00 00       	mov    $0x8,%eax
  801702:	e8 a3 fd ff ff       	call   8014aa <fsipc>
}
  801707:	c9                   	leave  
  801708:	c3                   	ret    

00801709 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801709:	55                   	push   %ebp
  80170a:	89 e5                	mov    %esp,%ebp
  80170c:	56                   	push   %esi
  80170d:	53                   	push   %ebx
  80170e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801711:	83 ec 0c             	sub    $0xc,%esp
  801714:	ff 75 08             	pushl  0x8(%ebp)
  801717:	e8 0c f8 ff ff       	call   800f28 <fd2data>
  80171c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80171e:	83 c4 08             	add    $0x8,%esp
  801721:	68 0f 24 80 00       	push   $0x80240f
  801726:	53                   	push   %ebx
  801727:	e8 02 f2 ff ff       	call   80092e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80172c:	8b 46 04             	mov    0x4(%esi),%eax
  80172f:	2b 06                	sub    (%esi),%eax
  801731:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801737:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80173e:	00 00 00 
	stat->st_dev = &devpipe;
  801741:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801748:	30 80 00 
	return 0;
}
  80174b:	b8 00 00 00 00       	mov    $0x0,%eax
  801750:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801753:	5b                   	pop    %ebx
  801754:	5e                   	pop    %esi
  801755:	5d                   	pop    %ebp
  801756:	c3                   	ret    

00801757 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801757:	55                   	push   %ebp
  801758:	89 e5                	mov    %esp,%ebp
  80175a:	53                   	push   %ebx
  80175b:	83 ec 0c             	sub    $0xc,%esp
  80175e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801761:	53                   	push   %ebx
  801762:	6a 00                	push   $0x0
  801764:	e8 43 f6 ff ff       	call   800dac <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801769:	89 1c 24             	mov    %ebx,(%esp)
  80176c:	e8 b7 f7 ff ff       	call   800f28 <fd2data>
  801771:	83 c4 08             	add    $0x8,%esp
  801774:	50                   	push   %eax
  801775:	6a 00                	push   $0x0
  801777:	e8 30 f6 ff ff       	call   800dac <sys_page_unmap>
}
  80177c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80177f:	c9                   	leave  
  801780:	c3                   	ret    

00801781 <_pipeisclosed>:
{
  801781:	55                   	push   %ebp
  801782:	89 e5                	mov    %esp,%ebp
  801784:	57                   	push   %edi
  801785:	56                   	push   %esi
  801786:	53                   	push   %ebx
  801787:	83 ec 1c             	sub    $0x1c,%esp
  80178a:	89 c7                	mov    %eax,%edi
  80178c:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80178e:	a1 04 40 80 00       	mov    0x804004,%eax
  801793:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801796:	83 ec 0c             	sub    $0xc,%esp
  801799:	57                   	push   %edi
  80179a:	e8 38 05 00 00       	call   801cd7 <pageref>
  80179f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8017a2:	89 34 24             	mov    %esi,(%esp)
  8017a5:	e8 2d 05 00 00       	call   801cd7 <pageref>
		nn = thisenv->env_runs;
  8017aa:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8017b0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8017b3:	83 c4 10             	add    $0x10,%esp
  8017b6:	39 cb                	cmp    %ecx,%ebx
  8017b8:	74 1b                	je     8017d5 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8017ba:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8017bd:	75 cf                	jne    80178e <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8017bf:	8b 42 58             	mov    0x58(%edx),%eax
  8017c2:	6a 01                	push   $0x1
  8017c4:	50                   	push   %eax
  8017c5:	53                   	push   %ebx
  8017c6:	68 16 24 80 00       	push   $0x802416
  8017cb:	e8 3f eb ff ff       	call   80030f <cprintf>
  8017d0:	83 c4 10             	add    $0x10,%esp
  8017d3:	eb b9                	jmp    80178e <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8017d5:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8017d8:	0f 94 c0             	sete   %al
  8017db:	0f b6 c0             	movzbl %al,%eax
}
  8017de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017e1:	5b                   	pop    %ebx
  8017e2:	5e                   	pop    %esi
  8017e3:	5f                   	pop    %edi
  8017e4:	5d                   	pop    %ebp
  8017e5:	c3                   	ret    

008017e6 <devpipe_write>:
{
  8017e6:	55                   	push   %ebp
  8017e7:	89 e5                	mov    %esp,%ebp
  8017e9:	57                   	push   %edi
  8017ea:	56                   	push   %esi
  8017eb:	53                   	push   %ebx
  8017ec:	83 ec 28             	sub    $0x28,%esp
  8017ef:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8017f2:	56                   	push   %esi
  8017f3:	e8 30 f7 ff ff       	call   800f28 <fd2data>
  8017f8:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8017fa:	83 c4 10             	add    $0x10,%esp
  8017fd:	bf 00 00 00 00       	mov    $0x0,%edi
  801802:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801805:	74 4f                	je     801856 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801807:	8b 43 04             	mov    0x4(%ebx),%eax
  80180a:	8b 0b                	mov    (%ebx),%ecx
  80180c:	8d 51 20             	lea    0x20(%ecx),%edx
  80180f:	39 d0                	cmp    %edx,%eax
  801811:	72 14                	jb     801827 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801813:	89 da                	mov    %ebx,%edx
  801815:	89 f0                	mov    %esi,%eax
  801817:	e8 65 ff ff ff       	call   801781 <_pipeisclosed>
  80181c:	85 c0                	test   %eax,%eax
  80181e:	75 3a                	jne    80185a <devpipe_write+0x74>
			sys_yield();
  801820:	e8 e3 f4 ff ff       	call   800d08 <sys_yield>
  801825:	eb e0                	jmp    801807 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801827:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80182a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80182e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801831:	89 c2                	mov    %eax,%edx
  801833:	c1 fa 1f             	sar    $0x1f,%edx
  801836:	89 d1                	mov    %edx,%ecx
  801838:	c1 e9 1b             	shr    $0x1b,%ecx
  80183b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80183e:	83 e2 1f             	and    $0x1f,%edx
  801841:	29 ca                	sub    %ecx,%edx
  801843:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801847:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80184b:	83 c0 01             	add    $0x1,%eax
  80184e:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801851:	83 c7 01             	add    $0x1,%edi
  801854:	eb ac                	jmp    801802 <devpipe_write+0x1c>
	return i;
  801856:	89 f8                	mov    %edi,%eax
  801858:	eb 05                	jmp    80185f <devpipe_write+0x79>
				return 0;
  80185a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80185f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801862:	5b                   	pop    %ebx
  801863:	5e                   	pop    %esi
  801864:	5f                   	pop    %edi
  801865:	5d                   	pop    %ebp
  801866:	c3                   	ret    

00801867 <devpipe_read>:
{
  801867:	55                   	push   %ebp
  801868:	89 e5                	mov    %esp,%ebp
  80186a:	57                   	push   %edi
  80186b:	56                   	push   %esi
  80186c:	53                   	push   %ebx
  80186d:	83 ec 18             	sub    $0x18,%esp
  801870:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801873:	57                   	push   %edi
  801874:	e8 af f6 ff ff       	call   800f28 <fd2data>
  801879:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80187b:	83 c4 10             	add    $0x10,%esp
  80187e:	be 00 00 00 00       	mov    $0x0,%esi
  801883:	3b 75 10             	cmp    0x10(%ebp),%esi
  801886:	74 47                	je     8018cf <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801888:	8b 03                	mov    (%ebx),%eax
  80188a:	3b 43 04             	cmp    0x4(%ebx),%eax
  80188d:	75 22                	jne    8018b1 <devpipe_read+0x4a>
			if (i > 0)
  80188f:	85 f6                	test   %esi,%esi
  801891:	75 14                	jne    8018a7 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801893:	89 da                	mov    %ebx,%edx
  801895:	89 f8                	mov    %edi,%eax
  801897:	e8 e5 fe ff ff       	call   801781 <_pipeisclosed>
  80189c:	85 c0                	test   %eax,%eax
  80189e:	75 33                	jne    8018d3 <devpipe_read+0x6c>
			sys_yield();
  8018a0:	e8 63 f4 ff ff       	call   800d08 <sys_yield>
  8018a5:	eb e1                	jmp    801888 <devpipe_read+0x21>
				return i;
  8018a7:	89 f0                	mov    %esi,%eax
}
  8018a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018ac:	5b                   	pop    %ebx
  8018ad:	5e                   	pop    %esi
  8018ae:	5f                   	pop    %edi
  8018af:	5d                   	pop    %ebp
  8018b0:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8018b1:	99                   	cltd   
  8018b2:	c1 ea 1b             	shr    $0x1b,%edx
  8018b5:	01 d0                	add    %edx,%eax
  8018b7:	83 e0 1f             	and    $0x1f,%eax
  8018ba:	29 d0                	sub    %edx,%eax
  8018bc:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8018c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018c4:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8018c7:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8018ca:	83 c6 01             	add    $0x1,%esi
  8018cd:	eb b4                	jmp    801883 <devpipe_read+0x1c>
	return i;
  8018cf:	89 f0                	mov    %esi,%eax
  8018d1:	eb d6                	jmp    8018a9 <devpipe_read+0x42>
				return 0;
  8018d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d8:	eb cf                	jmp    8018a9 <devpipe_read+0x42>

008018da <pipe>:
{
  8018da:	55                   	push   %ebp
  8018db:	89 e5                	mov    %esp,%ebp
  8018dd:	56                   	push   %esi
  8018de:	53                   	push   %ebx
  8018df:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8018e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018e5:	50                   	push   %eax
  8018e6:	e8 54 f6 ff ff       	call   800f3f <fd_alloc>
  8018eb:	89 c3                	mov    %eax,%ebx
  8018ed:	83 c4 10             	add    $0x10,%esp
  8018f0:	85 c0                	test   %eax,%eax
  8018f2:	78 5b                	js     80194f <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018f4:	83 ec 04             	sub    $0x4,%esp
  8018f7:	68 07 04 00 00       	push   $0x407
  8018fc:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ff:	6a 00                	push   $0x0
  801901:	e8 21 f4 ff ff       	call   800d27 <sys_page_alloc>
  801906:	89 c3                	mov    %eax,%ebx
  801908:	83 c4 10             	add    $0x10,%esp
  80190b:	85 c0                	test   %eax,%eax
  80190d:	78 40                	js     80194f <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  80190f:	83 ec 0c             	sub    $0xc,%esp
  801912:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801915:	50                   	push   %eax
  801916:	e8 24 f6 ff ff       	call   800f3f <fd_alloc>
  80191b:	89 c3                	mov    %eax,%ebx
  80191d:	83 c4 10             	add    $0x10,%esp
  801920:	85 c0                	test   %eax,%eax
  801922:	78 1b                	js     80193f <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801924:	83 ec 04             	sub    $0x4,%esp
  801927:	68 07 04 00 00       	push   $0x407
  80192c:	ff 75 f0             	pushl  -0x10(%ebp)
  80192f:	6a 00                	push   $0x0
  801931:	e8 f1 f3 ff ff       	call   800d27 <sys_page_alloc>
  801936:	89 c3                	mov    %eax,%ebx
  801938:	83 c4 10             	add    $0x10,%esp
  80193b:	85 c0                	test   %eax,%eax
  80193d:	79 19                	jns    801958 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  80193f:	83 ec 08             	sub    $0x8,%esp
  801942:	ff 75 f4             	pushl  -0xc(%ebp)
  801945:	6a 00                	push   $0x0
  801947:	e8 60 f4 ff ff       	call   800dac <sys_page_unmap>
  80194c:	83 c4 10             	add    $0x10,%esp
}
  80194f:	89 d8                	mov    %ebx,%eax
  801951:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801954:	5b                   	pop    %ebx
  801955:	5e                   	pop    %esi
  801956:	5d                   	pop    %ebp
  801957:	c3                   	ret    
	va = fd2data(fd0);
  801958:	83 ec 0c             	sub    $0xc,%esp
  80195b:	ff 75 f4             	pushl  -0xc(%ebp)
  80195e:	e8 c5 f5 ff ff       	call   800f28 <fd2data>
  801963:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801965:	83 c4 0c             	add    $0xc,%esp
  801968:	68 07 04 00 00       	push   $0x407
  80196d:	50                   	push   %eax
  80196e:	6a 00                	push   $0x0
  801970:	e8 b2 f3 ff ff       	call   800d27 <sys_page_alloc>
  801975:	89 c3                	mov    %eax,%ebx
  801977:	83 c4 10             	add    $0x10,%esp
  80197a:	85 c0                	test   %eax,%eax
  80197c:	0f 88 8c 00 00 00    	js     801a0e <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801982:	83 ec 0c             	sub    $0xc,%esp
  801985:	ff 75 f0             	pushl  -0x10(%ebp)
  801988:	e8 9b f5 ff ff       	call   800f28 <fd2data>
  80198d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801994:	50                   	push   %eax
  801995:	6a 00                	push   $0x0
  801997:	56                   	push   %esi
  801998:	6a 00                	push   $0x0
  80199a:	e8 cb f3 ff ff       	call   800d6a <sys_page_map>
  80199f:	89 c3                	mov    %eax,%ebx
  8019a1:	83 c4 20             	add    $0x20,%esp
  8019a4:	85 c0                	test   %eax,%eax
  8019a6:	78 58                	js     801a00 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  8019a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ab:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019b1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8019b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  8019bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019c0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019c6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8019c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019cb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8019d2:	83 ec 0c             	sub    $0xc,%esp
  8019d5:	ff 75 f4             	pushl  -0xc(%ebp)
  8019d8:	e8 3b f5 ff ff       	call   800f18 <fd2num>
  8019dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019e0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8019e2:	83 c4 04             	add    $0x4,%esp
  8019e5:	ff 75 f0             	pushl  -0x10(%ebp)
  8019e8:	e8 2b f5 ff ff       	call   800f18 <fd2num>
  8019ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019f0:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8019f3:	83 c4 10             	add    $0x10,%esp
  8019f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019fb:	e9 4f ff ff ff       	jmp    80194f <pipe+0x75>
	sys_page_unmap(0, va);
  801a00:	83 ec 08             	sub    $0x8,%esp
  801a03:	56                   	push   %esi
  801a04:	6a 00                	push   $0x0
  801a06:	e8 a1 f3 ff ff       	call   800dac <sys_page_unmap>
  801a0b:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801a0e:	83 ec 08             	sub    $0x8,%esp
  801a11:	ff 75 f0             	pushl  -0x10(%ebp)
  801a14:	6a 00                	push   $0x0
  801a16:	e8 91 f3 ff ff       	call   800dac <sys_page_unmap>
  801a1b:	83 c4 10             	add    $0x10,%esp
  801a1e:	e9 1c ff ff ff       	jmp    80193f <pipe+0x65>

00801a23 <pipeisclosed>:
{
  801a23:	55                   	push   %ebp
  801a24:	89 e5                	mov    %esp,%ebp
  801a26:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a29:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a2c:	50                   	push   %eax
  801a2d:	ff 75 08             	pushl  0x8(%ebp)
  801a30:	e8 59 f5 ff ff       	call   800f8e <fd_lookup>
  801a35:	83 c4 10             	add    $0x10,%esp
  801a38:	85 c0                	test   %eax,%eax
  801a3a:	78 18                	js     801a54 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801a3c:	83 ec 0c             	sub    $0xc,%esp
  801a3f:	ff 75 f4             	pushl  -0xc(%ebp)
  801a42:	e8 e1 f4 ff ff       	call   800f28 <fd2data>
	return _pipeisclosed(fd, p);
  801a47:	89 c2                	mov    %eax,%edx
  801a49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a4c:	e8 30 fd ff ff       	call   801781 <_pipeisclosed>
  801a51:	83 c4 10             	add    $0x10,%esp
}
  801a54:	c9                   	leave  
  801a55:	c3                   	ret    

00801a56 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a56:	55                   	push   %ebp
  801a57:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801a59:	b8 00 00 00 00       	mov    $0x0,%eax
  801a5e:	5d                   	pop    %ebp
  801a5f:	c3                   	ret    

00801a60 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a60:	55                   	push   %ebp
  801a61:	89 e5                	mov    %esp,%ebp
  801a63:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a66:	68 2e 24 80 00       	push   $0x80242e
  801a6b:	ff 75 0c             	pushl  0xc(%ebp)
  801a6e:	e8 bb ee ff ff       	call   80092e <strcpy>
	return 0;
}
  801a73:	b8 00 00 00 00       	mov    $0x0,%eax
  801a78:	c9                   	leave  
  801a79:	c3                   	ret    

00801a7a <devcons_write>:
{
  801a7a:	55                   	push   %ebp
  801a7b:	89 e5                	mov    %esp,%ebp
  801a7d:	57                   	push   %edi
  801a7e:	56                   	push   %esi
  801a7f:	53                   	push   %ebx
  801a80:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801a86:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801a8b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801a91:	eb 2f                	jmp    801ac2 <devcons_write+0x48>
		m = n - tot;
  801a93:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a96:	29 f3                	sub    %esi,%ebx
  801a98:	83 fb 7f             	cmp    $0x7f,%ebx
  801a9b:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801aa0:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801aa3:	83 ec 04             	sub    $0x4,%esp
  801aa6:	53                   	push   %ebx
  801aa7:	89 f0                	mov    %esi,%eax
  801aa9:	03 45 0c             	add    0xc(%ebp),%eax
  801aac:	50                   	push   %eax
  801aad:	57                   	push   %edi
  801aae:	e8 09 f0 ff ff       	call   800abc <memmove>
		sys_cputs(buf, m);
  801ab3:	83 c4 08             	add    $0x8,%esp
  801ab6:	53                   	push   %ebx
  801ab7:	57                   	push   %edi
  801ab8:	e8 ae f1 ff ff       	call   800c6b <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801abd:	01 de                	add    %ebx,%esi
  801abf:	83 c4 10             	add    $0x10,%esp
  801ac2:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ac5:	72 cc                	jb     801a93 <devcons_write+0x19>
}
  801ac7:	89 f0                	mov    %esi,%eax
  801ac9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801acc:	5b                   	pop    %ebx
  801acd:	5e                   	pop    %esi
  801ace:	5f                   	pop    %edi
  801acf:	5d                   	pop    %ebp
  801ad0:	c3                   	ret    

00801ad1 <devcons_read>:
{
  801ad1:	55                   	push   %ebp
  801ad2:	89 e5                	mov    %esp,%ebp
  801ad4:	83 ec 08             	sub    $0x8,%esp
  801ad7:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801adc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ae0:	75 07                	jne    801ae9 <devcons_read+0x18>
}
  801ae2:	c9                   	leave  
  801ae3:	c3                   	ret    
		sys_yield();
  801ae4:	e8 1f f2 ff ff       	call   800d08 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801ae9:	e8 9b f1 ff ff       	call   800c89 <sys_cgetc>
  801aee:	85 c0                	test   %eax,%eax
  801af0:	74 f2                	je     801ae4 <devcons_read+0x13>
	if (c < 0)
  801af2:	85 c0                	test   %eax,%eax
  801af4:	78 ec                	js     801ae2 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801af6:	83 f8 04             	cmp    $0x4,%eax
  801af9:	74 0c                	je     801b07 <devcons_read+0x36>
	*(char*)vbuf = c;
  801afb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801afe:	88 02                	mov    %al,(%edx)
	return 1;
  801b00:	b8 01 00 00 00       	mov    $0x1,%eax
  801b05:	eb db                	jmp    801ae2 <devcons_read+0x11>
		return 0;
  801b07:	b8 00 00 00 00       	mov    $0x0,%eax
  801b0c:	eb d4                	jmp    801ae2 <devcons_read+0x11>

00801b0e <cputchar>:
{
  801b0e:	55                   	push   %ebp
  801b0f:	89 e5                	mov    %esp,%ebp
  801b11:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b14:	8b 45 08             	mov    0x8(%ebp),%eax
  801b17:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801b1a:	6a 01                	push   $0x1
  801b1c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b1f:	50                   	push   %eax
  801b20:	e8 46 f1 ff ff       	call   800c6b <sys_cputs>
}
  801b25:	83 c4 10             	add    $0x10,%esp
  801b28:	c9                   	leave  
  801b29:	c3                   	ret    

00801b2a <getchar>:
{
  801b2a:	55                   	push   %ebp
  801b2b:	89 e5                	mov    %esp,%ebp
  801b2d:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801b30:	6a 01                	push   $0x1
  801b32:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b35:	50                   	push   %eax
  801b36:	6a 00                	push   $0x0
  801b38:	e8 c2 f6 ff ff       	call   8011ff <read>
	if (r < 0)
  801b3d:	83 c4 10             	add    $0x10,%esp
  801b40:	85 c0                	test   %eax,%eax
  801b42:	78 08                	js     801b4c <getchar+0x22>
	if (r < 1)
  801b44:	85 c0                	test   %eax,%eax
  801b46:	7e 06                	jle    801b4e <getchar+0x24>
	return c;
  801b48:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801b4c:	c9                   	leave  
  801b4d:	c3                   	ret    
		return -E_EOF;
  801b4e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801b53:	eb f7                	jmp    801b4c <getchar+0x22>

00801b55 <iscons>:
{
  801b55:	55                   	push   %ebp
  801b56:	89 e5                	mov    %esp,%ebp
  801b58:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b5b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b5e:	50                   	push   %eax
  801b5f:	ff 75 08             	pushl  0x8(%ebp)
  801b62:	e8 27 f4 ff ff       	call   800f8e <fd_lookup>
  801b67:	83 c4 10             	add    $0x10,%esp
  801b6a:	85 c0                	test   %eax,%eax
  801b6c:	78 11                	js     801b7f <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801b6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b71:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b77:	39 10                	cmp    %edx,(%eax)
  801b79:	0f 94 c0             	sete   %al
  801b7c:	0f b6 c0             	movzbl %al,%eax
}
  801b7f:	c9                   	leave  
  801b80:	c3                   	ret    

00801b81 <opencons>:
{
  801b81:	55                   	push   %ebp
  801b82:	89 e5                	mov    %esp,%ebp
  801b84:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801b87:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b8a:	50                   	push   %eax
  801b8b:	e8 af f3 ff ff       	call   800f3f <fd_alloc>
  801b90:	83 c4 10             	add    $0x10,%esp
  801b93:	85 c0                	test   %eax,%eax
  801b95:	78 3a                	js     801bd1 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b97:	83 ec 04             	sub    $0x4,%esp
  801b9a:	68 07 04 00 00       	push   $0x407
  801b9f:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba2:	6a 00                	push   $0x0
  801ba4:	e8 7e f1 ff ff       	call   800d27 <sys_page_alloc>
  801ba9:	83 c4 10             	add    $0x10,%esp
  801bac:	85 c0                	test   %eax,%eax
  801bae:	78 21                	js     801bd1 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801bb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bb3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bb9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801bbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bbe:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801bc5:	83 ec 0c             	sub    $0xc,%esp
  801bc8:	50                   	push   %eax
  801bc9:	e8 4a f3 ff ff       	call   800f18 <fd2num>
  801bce:	83 c4 10             	add    $0x10,%esp
}
  801bd1:	c9                   	leave  
  801bd2:	c3                   	ret    

00801bd3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801bd3:	55                   	push   %ebp
  801bd4:	89 e5                	mov    %esp,%ebp
  801bd6:	56                   	push   %esi
  801bd7:	53                   	push   %ebx
  801bd8:	8b 75 08             	mov    0x8(%ebp),%esi
  801bdb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bde:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        //	panic("ipc_recv not implemented");
        int r;
       	if(pg!=NULL){
  801be1:	85 c0                	test   %eax,%eax
  801be3:	74 3b                	je     801c20 <ipc_recv+0x4d>
	  r = sys_ipc_recv(pg);
  801be5:	83 ec 0c             	sub    $0xc,%esp
  801be8:	50                   	push   %eax
  801be9:	e8 e9 f2 ff ff       	call   800ed7 <sys_ipc_recv>
  801bee:	83 c4 10             	add    $0x10,%esp
	}else
	  r = sys_ipc_recv((void *)UTOP);
	if(r<0){
  801bf1:	85 c0                	test   %eax,%eax
  801bf3:	78 3d                	js     801c32 <ipc_recv+0x5f>
	if(perm_store!=NULL){
		*perm_store = 0;
            }
        	return r;
           }else{
	     if(from_env_store!=NULL)
  801bf5:	85 f6                	test   %esi,%esi
  801bf7:	74 0a                	je     801c03 <ipc_recv+0x30>
		     *from_env_store = thisenv->env_ipc_from;
  801bf9:	a1 04 40 80 00       	mov    0x804004,%eax
  801bfe:	8b 40 74             	mov    0x74(%eax),%eax
  801c01:	89 06                	mov    %eax,(%esi)
	     if(perm_store != NULL)
  801c03:	85 db                	test   %ebx,%ebx
  801c05:	74 0a                	je     801c11 <ipc_recv+0x3e>
		     *perm_store = thisenv->env_ipc_perm;
  801c07:	a1 04 40 80 00       	mov    0x804004,%eax
  801c0c:	8b 40 78             	mov    0x78(%eax),%eax
  801c0f:	89 03                	mov    %eax,(%ebx)
	     return thisenv->env_ipc_value;
  801c11:	a1 04 40 80 00       	mov    0x804004,%eax
  801c16:	8b 40 70             	mov    0x70(%eax),%eax
	   }

}
  801c19:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c1c:	5b                   	pop    %ebx
  801c1d:	5e                   	pop    %esi
  801c1e:	5d                   	pop    %ebp
  801c1f:	c3                   	ret    
	  r = sys_ipc_recv((void *)UTOP);
  801c20:	83 ec 0c             	sub    $0xc,%esp
  801c23:	68 00 00 c0 ee       	push   $0xeec00000
  801c28:	e8 aa f2 ff ff       	call   800ed7 <sys_ipc_recv>
  801c2d:	83 c4 10             	add    $0x10,%esp
  801c30:	eb bf                	jmp    801bf1 <ipc_recv+0x1e>
	if(from_env_store!=NULL){
  801c32:	85 f6                	test   %esi,%esi
  801c34:	74 06                	je     801c3c <ipc_recv+0x69>
	  *from_env_store = 0;
  801c36:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(perm_store!=NULL){
  801c3c:	85 db                	test   %ebx,%ebx
  801c3e:	74 d9                	je     801c19 <ipc_recv+0x46>
		*perm_store = 0;
  801c40:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801c46:	eb d1                	jmp    801c19 <ipc_recv+0x46>

00801c48 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c48:	55                   	push   %ebp
  801c49:	89 e5                	mov    %esp,%ebp
  801c4b:	57                   	push   %edi
  801c4c:	56                   	push   %esi
  801c4d:	53                   	push   %ebx
  801c4e:	83 ec 0c             	sub    $0xc,%esp
  801c51:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c54:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if(pg==NULL) pg = (void *)UTOP;
  801c5a:	85 db                	test   %ebx,%ebx
  801c5c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801c61:	0f 44 d8             	cmove  %eax,%ebx
	while((r=sys_ipc_try_send(to_env,val,pg,perm))<0){
  801c64:	ff 75 14             	pushl  0x14(%ebp)
  801c67:	53                   	push   %ebx
  801c68:	56                   	push   %esi
  801c69:	57                   	push   %edi
  801c6a:	e8 45 f2 ff ff       	call   800eb4 <sys_ipc_try_send>
  801c6f:	83 c4 10             	add    $0x10,%esp
  801c72:	85 c0                	test   %eax,%eax
  801c74:	79 20                	jns    801c96 <ipc_send+0x4e>
	    if(r!=-E_IPC_NOT_RECV){
  801c76:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c79:	75 07                	jne    801c82 <ipc_send+0x3a>
		    panic("ipc_send:send message failed\n");
	    }
	    sys_yield();
  801c7b:	e8 88 f0 ff ff       	call   800d08 <sys_yield>
  801c80:	eb e2                	jmp    801c64 <ipc_send+0x1c>
		    panic("ipc_send:send message failed\n");
  801c82:	83 ec 04             	sub    $0x4,%esp
  801c85:	68 3a 24 80 00       	push   $0x80243a
  801c8a:	6a 43                	push   $0x43
  801c8c:	68 58 24 80 00       	push   $0x802458
  801c91:	e8 9e e5 ff ff       	call   800234 <_panic>
	}

}
  801c96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c99:	5b                   	pop    %ebx
  801c9a:	5e                   	pop    %esi
  801c9b:	5f                   	pop    %edi
  801c9c:	5d                   	pop    %ebp
  801c9d:	c3                   	ret    

00801c9e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c9e:	55                   	push   %ebp
  801c9f:	89 e5                	mov    %esp,%ebp
  801ca1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ca4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ca9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801cac:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801cb2:	8b 52 50             	mov    0x50(%edx),%edx
  801cb5:	39 ca                	cmp    %ecx,%edx
  801cb7:	74 11                	je     801cca <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801cb9:	83 c0 01             	add    $0x1,%eax
  801cbc:	3d 00 04 00 00       	cmp    $0x400,%eax
  801cc1:	75 e6                	jne    801ca9 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801cc3:	b8 00 00 00 00       	mov    $0x0,%eax
  801cc8:	eb 0b                	jmp    801cd5 <ipc_find_env+0x37>
			return envs[i].env_id;
  801cca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ccd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801cd2:	8b 40 48             	mov    0x48(%eax),%eax
}
  801cd5:	5d                   	pop    %ebp
  801cd6:	c3                   	ret    

00801cd7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801cd7:	55                   	push   %ebp
  801cd8:	89 e5                	mov    %esp,%ebp
  801cda:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801cdd:	89 d0                	mov    %edx,%eax
  801cdf:	c1 e8 16             	shr    $0x16,%eax
  801ce2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ce9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801cee:	f6 c1 01             	test   $0x1,%cl
  801cf1:	74 1d                	je     801d10 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801cf3:	c1 ea 0c             	shr    $0xc,%edx
  801cf6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801cfd:	f6 c2 01             	test   $0x1,%dl
  801d00:	74 0e                	je     801d10 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d02:	c1 ea 0c             	shr    $0xc,%edx
  801d05:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d0c:	ef 
  801d0d:	0f b7 c0             	movzwl %ax,%eax
}
  801d10:	5d                   	pop    %ebp
  801d11:	c3                   	ret    
  801d12:	66 90                	xchg   %ax,%ax
  801d14:	66 90                	xchg   %ax,%ax
  801d16:	66 90                	xchg   %ax,%ax
  801d18:	66 90                	xchg   %ax,%ax
  801d1a:	66 90                	xchg   %ax,%ax
  801d1c:	66 90                	xchg   %ax,%ax
  801d1e:	66 90                	xchg   %ax,%ax

00801d20 <__udivdi3>:
  801d20:	55                   	push   %ebp
  801d21:	57                   	push   %edi
  801d22:	56                   	push   %esi
  801d23:	53                   	push   %ebx
  801d24:	83 ec 1c             	sub    $0x1c,%esp
  801d27:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d2b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801d2f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d33:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801d37:	85 d2                	test   %edx,%edx
  801d39:	75 35                	jne    801d70 <__udivdi3+0x50>
  801d3b:	39 f3                	cmp    %esi,%ebx
  801d3d:	0f 87 bd 00 00 00    	ja     801e00 <__udivdi3+0xe0>
  801d43:	85 db                	test   %ebx,%ebx
  801d45:	89 d9                	mov    %ebx,%ecx
  801d47:	75 0b                	jne    801d54 <__udivdi3+0x34>
  801d49:	b8 01 00 00 00       	mov    $0x1,%eax
  801d4e:	31 d2                	xor    %edx,%edx
  801d50:	f7 f3                	div    %ebx
  801d52:	89 c1                	mov    %eax,%ecx
  801d54:	31 d2                	xor    %edx,%edx
  801d56:	89 f0                	mov    %esi,%eax
  801d58:	f7 f1                	div    %ecx
  801d5a:	89 c6                	mov    %eax,%esi
  801d5c:	89 e8                	mov    %ebp,%eax
  801d5e:	89 f7                	mov    %esi,%edi
  801d60:	f7 f1                	div    %ecx
  801d62:	89 fa                	mov    %edi,%edx
  801d64:	83 c4 1c             	add    $0x1c,%esp
  801d67:	5b                   	pop    %ebx
  801d68:	5e                   	pop    %esi
  801d69:	5f                   	pop    %edi
  801d6a:	5d                   	pop    %ebp
  801d6b:	c3                   	ret    
  801d6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d70:	39 f2                	cmp    %esi,%edx
  801d72:	77 7c                	ja     801df0 <__udivdi3+0xd0>
  801d74:	0f bd fa             	bsr    %edx,%edi
  801d77:	83 f7 1f             	xor    $0x1f,%edi
  801d7a:	0f 84 98 00 00 00    	je     801e18 <__udivdi3+0xf8>
  801d80:	89 f9                	mov    %edi,%ecx
  801d82:	b8 20 00 00 00       	mov    $0x20,%eax
  801d87:	29 f8                	sub    %edi,%eax
  801d89:	d3 e2                	shl    %cl,%edx
  801d8b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d8f:	89 c1                	mov    %eax,%ecx
  801d91:	89 da                	mov    %ebx,%edx
  801d93:	d3 ea                	shr    %cl,%edx
  801d95:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801d99:	09 d1                	or     %edx,%ecx
  801d9b:	89 f2                	mov    %esi,%edx
  801d9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801da1:	89 f9                	mov    %edi,%ecx
  801da3:	d3 e3                	shl    %cl,%ebx
  801da5:	89 c1                	mov    %eax,%ecx
  801da7:	d3 ea                	shr    %cl,%edx
  801da9:	89 f9                	mov    %edi,%ecx
  801dab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801daf:	d3 e6                	shl    %cl,%esi
  801db1:	89 eb                	mov    %ebp,%ebx
  801db3:	89 c1                	mov    %eax,%ecx
  801db5:	d3 eb                	shr    %cl,%ebx
  801db7:	09 de                	or     %ebx,%esi
  801db9:	89 f0                	mov    %esi,%eax
  801dbb:	f7 74 24 08          	divl   0x8(%esp)
  801dbf:	89 d6                	mov    %edx,%esi
  801dc1:	89 c3                	mov    %eax,%ebx
  801dc3:	f7 64 24 0c          	mull   0xc(%esp)
  801dc7:	39 d6                	cmp    %edx,%esi
  801dc9:	72 0c                	jb     801dd7 <__udivdi3+0xb7>
  801dcb:	89 f9                	mov    %edi,%ecx
  801dcd:	d3 e5                	shl    %cl,%ebp
  801dcf:	39 c5                	cmp    %eax,%ebp
  801dd1:	73 5d                	jae    801e30 <__udivdi3+0x110>
  801dd3:	39 d6                	cmp    %edx,%esi
  801dd5:	75 59                	jne    801e30 <__udivdi3+0x110>
  801dd7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801dda:	31 ff                	xor    %edi,%edi
  801ddc:	89 fa                	mov    %edi,%edx
  801dde:	83 c4 1c             	add    $0x1c,%esp
  801de1:	5b                   	pop    %ebx
  801de2:	5e                   	pop    %esi
  801de3:	5f                   	pop    %edi
  801de4:	5d                   	pop    %ebp
  801de5:	c3                   	ret    
  801de6:	8d 76 00             	lea    0x0(%esi),%esi
  801de9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801df0:	31 ff                	xor    %edi,%edi
  801df2:	31 c0                	xor    %eax,%eax
  801df4:	89 fa                	mov    %edi,%edx
  801df6:	83 c4 1c             	add    $0x1c,%esp
  801df9:	5b                   	pop    %ebx
  801dfa:	5e                   	pop    %esi
  801dfb:	5f                   	pop    %edi
  801dfc:	5d                   	pop    %ebp
  801dfd:	c3                   	ret    
  801dfe:	66 90                	xchg   %ax,%ax
  801e00:	31 ff                	xor    %edi,%edi
  801e02:	89 e8                	mov    %ebp,%eax
  801e04:	89 f2                	mov    %esi,%edx
  801e06:	f7 f3                	div    %ebx
  801e08:	89 fa                	mov    %edi,%edx
  801e0a:	83 c4 1c             	add    $0x1c,%esp
  801e0d:	5b                   	pop    %ebx
  801e0e:	5e                   	pop    %esi
  801e0f:	5f                   	pop    %edi
  801e10:	5d                   	pop    %ebp
  801e11:	c3                   	ret    
  801e12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e18:	39 f2                	cmp    %esi,%edx
  801e1a:	72 06                	jb     801e22 <__udivdi3+0x102>
  801e1c:	31 c0                	xor    %eax,%eax
  801e1e:	39 eb                	cmp    %ebp,%ebx
  801e20:	77 d2                	ja     801df4 <__udivdi3+0xd4>
  801e22:	b8 01 00 00 00       	mov    $0x1,%eax
  801e27:	eb cb                	jmp    801df4 <__udivdi3+0xd4>
  801e29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e30:	89 d8                	mov    %ebx,%eax
  801e32:	31 ff                	xor    %edi,%edi
  801e34:	eb be                	jmp    801df4 <__udivdi3+0xd4>
  801e36:	66 90                	xchg   %ax,%ax
  801e38:	66 90                	xchg   %ax,%ax
  801e3a:	66 90                	xchg   %ax,%ax
  801e3c:	66 90                	xchg   %ax,%ax
  801e3e:	66 90                	xchg   %ax,%ax

00801e40 <__umoddi3>:
  801e40:	55                   	push   %ebp
  801e41:	57                   	push   %edi
  801e42:	56                   	push   %esi
  801e43:	53                   	push   %ebx
  801e44:	83 ec 1c             	sub    $0x1c,%esp
  801e47:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801e4b:	8b 74 24 30          	mov    0x30(%esp),%esi
  801e4f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801e53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e57:	85 ed                	test   %ebp,%ebp
  801e59:	89 f0                	mov    %esi,%eax
  801e5b:	89 da                	mov    %ebx,%edx
  801e5d:	75 19                	jne    801e78 <__umoddi3+0x38>
  801e5f:	39 df                	cmp    %ebx,%edi
  801e61:	0f 86 b1 00 00 00    	jbe    801f18 <__umoddi3+0xd8>
  801e67:	f7 f7                	div    %edi
  801e69:	89 d0                	mov    %edx,%eax
  801e6b:	31 d2                	xor    %edx,%edx
  801e6d:	83 c4 1c             	add    $0x1c,%esp
  801e70:	5b                   	pop    %ebx
  801e71:	5e                   	pop    %esi
  801e72:	5f                   	pop    %edi
  801e73:	5d                   	pop    %ebp
  801e74:	c3                   	ret    
  801e75:	8d 76 00             	lea    0x0(%esi),%esi
  801e78:	39 dd                	cmp    %ebx,%ebp
  801e7a:	77 f1                	ja     801e6d <__umoddi3+0x2d>
  801e7c:	0f bd cd             	bsr    %ebp,%ecx
  801e7f:	83 f1 1f             	xor    $0x1f,%ecx
  801e82:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801e86:	0f 84 b4 00 00 00    	je     801f40 <__umoddi3+0x100>
  801e8c:	b8 20 00 00 00       	mov    $0x20,%eax
  801e91:	89 c2                	mov    %eax,%edx
  801e93:	8b 44 24 04          	mov    0x4(%esp),%eax
  801e97:	29 c2                	sub    %eax,%edx
  801e99:	89 c1                	mov    %eax,%ecx
  801e9b:	89 f8                	mov    %edi,%eax
  801e9d:	d3 e5                	shl    %cl,%ebp
  801e9f:	89 d1                	mov    %edx,%ecx
  801ea1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801ea5:	d3 e8                	shr    %cl,%eax
  801ea7:	09 c5                	or     %eax,%ebp
  801ea9:	8b 44 24 04          	mov    0x4(%esp),%eax
  801ead:	89 c1                	mov    %eax,%ecx
  801eaf:	d3 e7                	shl    %cl,%edi
  801eb1:	89 d1                	mov    %edx,%ecx
  801eb3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801eb7:	89 df                	mov    %ebx,%edi
  801eb9:	d3 ef                	shr    %cl,%edi
  801ebb:	89 c1                	mov    %eax,%ecx
  801ebd:	89 f0                	mov    %esi,%eax
  801ebf:	d3 e3                	shl    %cl,%ebx
  801ec1:	89 d1                	mov    %edx,%ecx
  801ec3:	89 fa                	mov    %edi,%edx
  801ec5:	d3 e8                	shr    %cl,%eax
  801ec7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801ecc:	09 d8                	or     %ebx,%eax
  801ece:	f7 f5                	div    %ebp
  801ed0:	d3 e6                	shl    %cl,%esi
  801ed2:	89 d1                	mov    %edx,%ecx
  801ed4:	f7 64 24 08          	mull   0x8(%esp)
  801ed8:	39 d1                	cmp    %edx,%ecx
  801eda:	89 c3                	mov    %eax,%ebx
  801edc:	89 d7                	mov    %edx,%edi
  801ede:	72 06                	jb     801ee6 <__umoddi3+0xa6>
  801ee0:	75 0e                	jne    801ef0 <__umoddi3+0xb0>
  801ee2:	39 c6                	cmp    %eax,%esi
  801ee4:	73 0a                	jae    801ef0 <__umoddi3+0xb0>
  801ee6:	2b 44 24 08          	sub    0x8(%esp),%eax
  801eea:	19 ea                	sbb    %ebp,%edx
  801eec:	89 d7                	mov    %edx,%edi
  801eee:	89 c3                	mov    %eax,%ebx
  801ef0:	89 ca                	mov    %ecx,%edx
  801ef2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801ef7:	29 de                	sub    %ebx,%esi
  801ef9:	19 fa                	sbb    %edi,%edx
  801efb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  801eff:	89 d0                	mov    %edx,%eax
  801f01:	d3 e0                	shl    %cl,%eax
  801f03:	89 d9                	mov    %ebx,%ecx
  801f05:	d3 ee                	shr    %cl,%esi
  801f07:	d3 ea                	shr    %cl,%edx
  801f09:	09 f0                	or     %esi,%eax
  801f0b:	83 c4 1c             	add    $0x1c,%esp
  801f0e:	5b                   	pop    %ebx
  801f0f:	5e                   	pop    %esi
  801f10:	5f                   	pop    %edi
  801f11:	5d                   	pop    %ebp
  801f12:	c3                   	ret    
  801f13:	90                   	nop
  801f14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f18:	85 ff                	test   %edi,%edi
  801f1a:	89 f9                	mov    %edi,%ecx
  801f1c:	75 0b                	jne    801f29 <__umoddi3+0xe9>
  801f1e:	b8 01 00 00 00       	mov    $0x1,%eax
  801f23:	31 d2                	xor    %edx,%edx
  801f25:	f7 f7                	div    %edi
  801f27:	89 c1                	mov    %eax,%ecx
  801f29:	89 d8                	mov    %ebx,%eax
  801f2b:	31 d2                	xor    %edx,%edx
  801f2d:	f7 f1                	div    %ecx
  801f2f:	89 f0                	mov    %esi,%eax
  801f31:	f7 f1                	div    %ecx
  801f33:	e9 31 ff ff ff       	jmp    801e69 <__umoddi3+0x29>
  801f38:	90                   	nop
  801f39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f40:	39 dd                	cmp    %ebx,%ebp
  801f42:	72 08                	jb     801f4c <__umoddi3+0x10c>
  801f44:	39 f7                	cmp    %esi,%edi
  801f46:	0f 87 21 ff ff ff    	ja     801e6d <__umoddi3+0x2d>
  801f4c:	89 da                	mov    %ebx,%edx
  801f4e:	89 f0                	mov    %esi,%eax
  801f50:	29 f8                	sub    %edi,%eax
  801f52:	19 ea                	sbb    %ebp,%edx
  801f54:	e9 14 ff ff ff       	jmp    801e6d <__umoddi3+0x2d>
