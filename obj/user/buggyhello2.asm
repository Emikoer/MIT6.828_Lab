
obj/user/buggyhello2.debug:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 30 80 00    	pushl  0x803000
  800044:	e8 65 00 00 00       	call   8000ae <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800059:	e8 ce 00 00 00       	call   80012c <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009a:	e8 92 04 00 00       	call   800531 <close_all>
	sys_env_destroy(0);
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 42 00 00 00       	call   8000eb <sys_env_destroy>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	57                   	push   %edi
  8000b2:	56                   	push   %esi
  8000b3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bf:	89 c3                	mov    %eax,%ebx
  8000c1:	89 c7                	mov    %eax,%edi
  8000c3:	89 c6                	mov    %eax,%esi
  8000c5:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c7:	5b                   	pop    %ebx
  8000c8:	5e                   	pop    %esi
  8000c9:	5f                   	pop    %edi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	57                   	push   %edi
  8000d0:	56                   	push   %esi
  8000d1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000dc:	89 d1                	mov    %edx,%ecx
  8000de:	89 d3                	mov    %edx,%ebx
  8000e0:	89 d7                	mov    %edx,%edi
  8000e2:	89 d6                	mov    %edx,%esi
  8000e4:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fc:	b8 03 00 00 00       	mov    $0x3,%eax
  800101:	89 cb                	mov    %ecx,%ebx
  800103:	89 cf                	mov    %ecx,%edi
  800105:	89 ce                	mov    %ecx,%esi
  800107:	cd 30                	int    $0x30
	if(check && ret > 0)
  800109:	85 c0                	test   %eax,%eax
  80010b:	7f 08                	jg     800115 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800110:	5b                   	pop    %ebx
  800111:	5e                   	pop    %esi
  800112:	5f                   	pop    %edi
  800113:	5d                   	pop    %ebp
  800114:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	50                   	push   %eax
  800119:	6a 03                	push   $0x3
  80011b:	68 f8 1d 80 00       	push   $0x801df8
  800120:	6a 23                	push   $0x23
  800122:	68 15 1e 80 00       	push   $0x801e15
  800127:	e8 ea 0e 00 00       	call   801016 <_panic>

0080012c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	57                   	push   %edi
  800130:	56                   	push   %esi
  800131:	53                   	push   %ebx
	asm volatile("int %1\n"
  800132:	ba 00 00 00 00       	mov    $0x0,%edx
  800137:	b8 02 00 00 00       	mov    $0x2,%eax
  80013c:	89 d1                	mov    %edx,%ecx
  80013e:	89 d3                	mov    %edx,%ebx
  800140:	89 d7                	mov    %edx,%edi
  800142:	89 d6                	mov    %edx,%esi
  800144:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800146:	5b                   	pop    %ebx
  800147:	5e                   	pop    %esi
  800148:	5f                   	pop    %edi
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    

0080014b <sys_yield>:

void
sys_yield(void)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	57                   	push   %edi
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
	asm volatile("int %1\n"
  800151:	ba 00 00 00 00       	mov    $0x0,%edx
  800156:	b8 0b 00 00 00       	mov    $0xb,%eax
  80015b:	89 d1                	mov    %edx,%ecx
  80015d:	89 d3                	mov    %edx,%ebx
  80015f:	89 d7                	mov    %edx,%edi
  800161:	89 d6                	mov    %edx,%esi
  800163:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800165:	5b                   	pop    %ebx
  800166:	5e                   	pop    %esi
  800167:	5f                   	pop    %edi
  800168:	5d                   	pop    %ebp
  800169:	c3                   	ret    

0080016a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	57                   	push   %edi
  80016e:	56                   	push   %esi
  80016f:	53                   	push   %ebx
  800170:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800173:	be 00 00 00 00       	mov    $0x0,%esi
  800178:	8b 55 08             	mov    0x8(%ebp),%edx
  80017b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017e:	b8 04 00 00 00       	mov    $0x4,%eax
  800183:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800186:	89 f7                	mov    %esi,%edi
  800188:	cd 30                	int    $0x30
	if(check && ret > 0)
  80018a:	85 c0                	test   %eax,%eax
  80018c:	7f 08                	jg     800196 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80018e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800191:	5b                   	pop    %ebx
  800192:	5e                   	pop    %esi
  800193:	5f                   	pop    %edi
  800194:	5d                   	pop    %ebp
  800195:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800196:	83 ec 0c             	sub    $0xc,%esp
  800199:	50                   	push   %eax
  80019a:	6a 04                	push   $0x4
  80019c:	68 f8 1d 80 00       	push   $0x801df8
  8001a1:	6a 23                	push   $0x23
  8001a3:	68 15 1e 80 00       	push   $0x801e15
  8001a8:	e8 69 0e 00 00       	call   801016 <_panic>

008001ad <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ad:	55                   	push   %ebp
  8001ae:	89 e5                	mov    %esp,%ebp
  8001b0:	57                   	push   %edi
  8001b1:	56                   	push   %esi
  8001b2:	53                   	push   %ebx
  8001b3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001bc:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ca:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001cc:	85 c0                	test   %eax,%eax
  8001ce:	7f 08                	jg     8001d8 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d3:	5b                   	pop    %ebx
  8001d4:	5e                   	pop    %esi
  8001d5:	5f                   	pop    %edi
  8001d6:	5d                   	pop    %ebp
  8001d7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d8:	83 ec 0c             	sub    $0xc,%esp
  8001db:	50                   	push   %eax
  8001dc:	6a 05                	push   $0x5
  8001de:	68 f8 1d 80 00       	push   $0x801df8
  8001e3:	6a 23                	push   $0x23
  8001e5:	68 15 1e 80 00       	push   $0x801e15
  8001ea:	e8 27 0e 00 00       	call   801016 <_panic>

008001ef <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	57                   	push   %edi
  8001f3:	56                   	push   %esi
  8001f4:	53                   	push   %ebx
  8001f5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800200:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800203:	b8 06 00 00 00       	mov    $0x6,%eax
  800208:	89 df                	mov    %ebx,%edi
  80020a:	89 de                	mov    %ebx,%esi
  80020c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80020e:	85 c0                	test   %eax,%eax
  800210:	7f 08                	jg     80021a <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800212:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800215:	5b                   	pop    %ebx
  800216:	5e                   	pop    %esi
  800217:	5f                   	pop    %edi
  800218:	5d                   	pop    %ebp
  800219:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80021a:	83 ec 0c             	sub    $0xc,%esp
  80021d:	50                   	push   %eax
  80021e:	6a 06                	push   $0x6
  800220:	68 f8 1d 80 00       	push   $0x801df8
  800225:	6a 23                	push   $0x23
  800227:	68 15 1e 80 00       	push   $0x801e15
  80022c:	e8 e5 0d 00 00       	call   801016 <_panic>

00800231 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	57                   	push   %edi
  800235:	56                   	push   %esi
  800236:	53                   	push   %ebx
  800237:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80023a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023f:	8b 55 08             	mov    0x8(%ebp),%edx
  800242:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800245:	b8 08 00 00 00       	mov    $0x8,%eax
  80024a:	89 df                	mov    %ebx,%edi
  80024c:	89 de                	mov    %ebx,%esi
  80024e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800250:	85 c0                	test   %eax,%eax
  800252:	7f 08                	jg     80025c <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800254:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800257:	5b                   	pop    %ebx
  800258:	5e                   	pop    %esi
  800259:	5f                   	pop    %edi
  80025a:	5d                   	pop    %ebp
  80025b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80025c:	83 ec 0c             	sub    $0xc,%esp
  80025f:	50                   	push   %eax
  800260:	6a 08                	push   $0x8
  800262:	68 f8 1d 80 00       	push   $0x801df8
  800267:	6a 23                	push   $0x23
  800269:	68 15 1e 80 00       	push   $0x801e15
  80026e:	e8 a3 0d 00 00       	call   801016 <_panic>

00800273 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	57                   	push   %edi
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80027c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800281:	8b 55 08             	mov    0x8(%ebp),%edx
  800284:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800287:	b8 09 00 00 00       	mov    $0x9,%eax
  80028c:	89 df                	mov    %ebx,%edi
  80028e:	89 de                	mov    %ebx,%esi
  800290:	cd 30                	int    $0x30
	if(check && ret > 0)
  800292:	85 c0                	test   %eax,%eax
  800294:	7f 08                	jg     80029e <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800296:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800299:	5b                   	pop    %ebx
  80029a:	5e                   	pop    %esi
  80029b:	5f                   	pop    %edi
  80029c:	5d                   	pop    %ebp
  80029d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80029e:	83 ec 0c             	sub    $0xc,%esp
  8002a1:	50                   	push   %eax
  8002a2:	6a 09                	push   $0x9
  8002a4:	68 f8 1d 80 00       	push   $0x801df8
  8002a9:	6a 23                	push   $0x23
  8002ab:	68 15 1e 80 00       	push   $0x801e15
  8002b0:	e8 61 0d 00 00       	call   801016 <_panic>

008002b5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	57                   	push   %edi
  8002b9:	56                   	push   %esi
  8002ba:	53                   	push   %ebx
  8002bb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002ce:	89 df                	mov    %ebx,%edi
  8002d0:	89 de                	mov    %ebx,%esi
  8002d2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002d4:	85 c0                	test   %eax,%eax
  8002d6:	7f 08                	jg     8002e0 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002db:	5b                   	pop    %ebx
  8002dc:	5e                   	pop    %esi
  8002dd:	5f                   	pop    %edi
  8002de:	5d                   	pop    %ebp
  8002df:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e0:	83 ec 0c             	sub    $0xc,%esp
  8002e3:	50                   	push   %eax
  8002e4:	6a 0a                	push   $0xa
  8002e6:	68 f8 1d 80 00       	push   $0x801df8
  8002eb:	6a 23                	push   $0x23
  8002ed:	68 15 1e 80 00       	push   $0x801e15
  8002f2:	e8 1f 0d 00 00       	call   801016 <_panic>

008002f7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	57                   	push   %edi
  8002fb:	56                   	push   %esi
  8002fc:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800300:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800303:	b8 0c 00 00 00       	mov    $0xc,%eax
  800308:	be 00 00 00 00       	mov    $0x0,%esi
  80030d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800310:	8b 7d 14             	mov    0x14(%ebp),%edi
  800313:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800315:	5b                   	pop    %ebx
  800316:	5e                   	pop    %esi
  800317:	5f                   	pop    %edi
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	57                   	push   %edi
  80031e:	56                   	push   %esi
  80031f:	53                   	push   %ebx
  800320:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800323:	b9 00 00 00 00       	mov    $0x0,%ecx
  800328:	8b 55 08             	mov    0x8(%ebp),%edx
  80032b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800330:	89 cb                	mov    %ecx,%ebx
  800332:	89 cf                	mov    %ecx,%edi
  800334:	89 ce                	mov    %ecx,%esi
  800336:	cd 30                	int    $0x30
	if(check && ret > 0)
  800338:	85 c0                	test   %eax,%eax
  80033a:	7f 08                	jg     800344 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80033c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80033f:	5b                   	pop    %ebx
  800340:	5e                   	pop    %esi
  800341:	5f                   	pop    %edi
  800342:	5d                   	pop    %ebp
  800343:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800344:	83 ec 0c             	sub    $0xc,%esp
  800347:	50                   	push   %eax
  800348:	6a 0d                	push   $0xd
  80034a:	68 f8 1d 80 00       	push   $0x801df8
  80034f:	6a 23                	push   $0x23
  800351:	68 15 1e 80 00       	push   $0x801e15
  800356:	e8 bb 0c 00 00       	call   801016 <_panic>

0080035b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035e:	8b 45 08             	mov    0x8(%ebp),%eax
  800361:	05 00 00 00 30       	add    $0x30000000,%eax
  800366:	c1 e8 0c             	shr    $0xc,%eax
}
  800369:	5d                   	pop    %ebp
  80036a:	c3                   	ret    

0080036b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80036e:	8b 45 08             	mov    0x8(%ebp),%eax
  800371:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800376:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80037b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
  800385:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800388:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80038d:	89 c2                	mov    %eax,%edx
  80038f:	c1 ea 16             	shr    $0x16,%edx
  800392:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800399:	f6 c2 01             	test   $0x1,%dl
  80039c:	74 2a                	je     8003c8 <fd_alloc+0x46>
  80039e:	89 c2                	mov    %eax,%edx
  8003a0:	c1 ea 0c             	shr    $0xc,%edx
  8003a3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003aa:	f6 c2 01             	test   $0x1,%dl
  8003ad:	74 19                	je     8003c8 <fd_alloc+0x46>
  8003af:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8003b4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003b9:	75 d2                	jne    80038d <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003bb:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003c1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8003c6:	eb 07                	jmp    8003cf <fd_alloc+0x4d>
			*fd_store = fd;
  8003c8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003cf:	5d                   	pop    %ebp
  8003d0:	c3                   	ret    

008003d1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003d1:	55                   	push   %ebp
  8003d2:	89 e5                	mov    %esp,%ebp
  8003d4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d7:	83 f8 1f             	cmp    $0x1f,%eax
  8003da:	77 36                	ja     800412 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003dc:	c1 e0 0c             	shl    $0xc,%eax
  8003df:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003e4:	89 c2                	mov    %eax,%edx
  8003e6:	c1 ea 16             	shr    $0x16,%edx
  8003e9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003f0:	f6 c2 01             	test   $0x1,%dl
  8003f3:	74 24                	je     800419 <fd_lookup+0x48>
  8003f5:	89 c2                	mov    %eax,%edx
  8003f7:	c1 ea 0c             	shr    $0xc,%edx
  8003fa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800401:	f6 c2 01             	test   $0x1,%dl
  800404:	74 1a                	je     800420 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800406:	8b 55 0c             	mov    0xc(%ebp),%edx
  800409:	89 02                	mov    %eax,(%edx)
	return 0;
  80040b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800410:	5d                   	pop    %ebp
  800411:	c3                   	ret    
		return -E_INVAL;
  800412:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800417:	eb f7                	jmp    800410 <fd_lookup+0x3f>
		return -E_INVAL;
  800419:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80041e:	eb f0                	jmp    800410 <fd_lookup+0x3f>
  800420:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800425:	eb e9                	jmp    800410 <fd_lookup+0x3f>

00800427 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800427:	55                   	push   %ebp
  800428:	89 e5                	mov    %esp,%ebp
  80042a:	83 ec 08             	sub    $0x8,%esp
  80042d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800430:	ba a0 1e 80 00       	mov    $0x801ea0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800435:	b8 08 30 80 00       	mov    $0x803008,%eax
		if (devtab[i]->dev_id == dev_id) {
  80043a:	39 08                	cmp    %ecx,(%eax)
  80043c:	74 33                	je     800471 <dev_lookup+0x4a>
  80043e:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800441:	8b 02                	mov    (%edx),%eax
  800443:	85 c0                	test   %eax,%eax
  800445:	75 f3                	jne    80043a <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800447:	a1 04 40 80 00       	mov    0x804004,%eax
  80044c:	8b 40 48             	mov    0x48(%eax),%eax
  80044f:	83 ec 04             	sub    $0x4,%esp
  800452:	51                   	push   %ecx
  800453:	50                   	push   %eax
  800454:	68 24 1e 80 00       	push   $0x801e24
  800459:	e8 93 0c 00 00       	call   8010f1 <cprintf>
	*dev = 0;
  80045e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800461:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800467:	83 c4 10             	add    $0x10,%esp
  80046a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80046f:	c9                   	leave  
  800470:	c3                   	ret    
			*dev = devtab[i];
  800471:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800474:	89 01                	mov    %eax,(%ecx)
			return 0;
  800476:	b8 00 00 00 00       	mov    $0x0,%eax
  80047b:	eb f2                	jmp    80046f <dev_lookup+0x48>

0080047d <fd_close>:
{
  80047d:	55                   	push   %ebp
  80047e:	89 e5                	mov    %esp,%ebp
  800480:	57                   	push   %edi
  800481:	56                   	push   %esi
  800482:	53                   	push   %ebx
  800483:	83 ec 1c             	sub    $0x1c,%esp
  800486:	8b 75 08             	mov    0x8(%ebp),%esi
  800489:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80048c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80048f:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800490:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800496:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800499:	50                   	push   %eax
  80049a:	e8 32 ff ff ff       	call   8003d1 <fd_lookup>
  80049f:	89 c3                	mov    %eax,%ebx
  8004a1:	83 c4 08             	add    $0x8,%esp
  8004a4:	85 c0                	test   %eax,%eax
  8004a6:	78 05                	js     8004ad <fd_close+0x30>
	    || fd != fd2)
  8004a8:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8004ab:	74 16                	je     8004c3 <fd_close+0x46>
		return (must_exist ? r : 0);
  8004ad:	89 f8                	mov    %edi,%eax
  8004af:	84 c0                	test   %al,%al
  8004b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b6:	0f 44 d8             	cmove  %eax,%ebx
}
  8004b9:	89 d8                	mov    %ebx,%eax
  8004bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004be:	5b                   	pop    %ebx
  8004bf:	5e                   	pop    %esi
  8004c0:	5f                   	pop    %edi
  8004c1:	5d                   	pop    %ebp
  8004c2:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8004c9:	50                   	push   %eax
  8004ca:	ff 36                	pushl  (%esi)
  8004cc:	e8 56 ff ff ff       	call   800427 <dev_lookup>
  8004d1:	89 c3                	mov    %eax,%ebx
  8004d3:	83 c4 10             	add    $0x10,%esp
  8004d6:	85 c0                	test   %eax,%eax
  8004d8:	78 15                	js     8004ef <fd_close+0x72>
		if (dev->dev_close)
  8004da:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004dd:	8b 40 10             	mov    0x10(%eax),%eax
  8004e0:	85 c0                	test   %eax,%eax
  8004e2:	74 1b                	je     8004ff <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8004e4:	83 ec 0c             	sub    $0xc,%esp
  8004e7:	56                   	push   %esi
  8004e8:	ff d0                	call   *%eax
  8004ea:	89 c3                	mov    %eax,%ebx
  8004ec:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004ef:	83 ec 08             	sub    $0x8,%esp
  8004f2:	56                   	push   %esi
  8004f3:	6a 00                	push   $0x0
  8004f5:	e8 f5 fc ff ff       	call   8001ef <sys_page_unmap>
	return r;
  8004fa:	83 c4 10             	add    $0x10,%esp
  8004fd:	eb ba                	jmp    8004b9 <fd_close+0x3c>
			r = 0;
  8004ff:	bb 00 00 00 00       	mov    $0x0,%ebx
  800504:	eb e9                	jmp    8004ef <fd_close+0x72>

00800506 <close>:

int
close(int fdnum)
{
  800506:	55                   	push   %ebp
  800507:	89 e5                	mov    %esp,%ebp
  800509:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80050c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80050f:	50                   	push   %eax
  800510:	ff 75 08             	pushl  0x8(%ebp)
  800513:	e8 b9 fe ff ff       	call   8003d1 <fd_lookup>
  800518:	83 c4 08             	add    $0x8,%esp
  80051b:	85 c0                	test   %eax,%eax
  80051d:	78 10                	js     80052f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80051f:	83 ec 08             	sub    $0x8,%esp
  800522:	6a 01                	push   $0x1
  800524:	ff 75 f4             	pushl  -0xc(%ebp)
  800527:	e8 51 ff ff ff       	call   80047d <fd_close>
  80052c:	83 c4 10             	add    $0x10,%esp
}
  80052f:	c9                   	leave  
  800530:	c3                   	ret    

00800531 <close_all>:

void
close_all(void)
{
  800531:	55                   	push   %ebp
  800532:	89 e5                	mov    %esp,%ebp
  800534:	53                   	push   %ebx
  800535:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800538:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80053d:	83 ec 0c             	sub    $0xc,%esp
  800540:	53                   	push   %ebx
  800541:	e8 c0 ff ff ff       	call   800506 <close>
	for (i = 0; i < MAXFD; i++)
  800546:	83 c3 01             	add    $0x1,%ebx
  800549:	83 c4 10             	add    $0x10,%esp
  80054c:	83 fb 20             	cmp    $0x20,%ebx
  80054f:	75 ec                	jne    80053d <close_all+0xc>
}
  800551:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800554:	c9                   	leave  
  800555:	c3                   	ret    

00800556 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800556:	55                   	push   %ebp
  800557:	89 e5                	mov    %esp,%ebp
  800559:	57                   	push   %edi
  80055a:	56                   	push   %esi
  80055b:	53                   	push   %ebx
  80055c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80055f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800562:	50                   	push   %eax
  800563:	ff 75 08             	pushl  0x8(%ebp)
  800566:	e8 66 fe ff ff       	call   8003d1 <fd_lookup>
  80056b:	89 c3                	mov    %eax,%ebx
  80056d:	83 c4 08             	add    $0x8,%esp
  800570:	85 c0                	test   %eax,%eax
  800572:	0f 88 81 00 00 00    	js     8005f9 <dup+0xa3>
		return r;
	close(newfdnum);
  800578:	83 ec 0c             	sub    $0xc,%esp
  80057b:	ff 75 0c             	pushl  0xc(%ebp)
  80057e:	e8 83 ff ff ff       	call   800506 <close>

	newfd = INDEX2FD(newfdnum);
  800583:	8b 75 0c             	mov    0xc(%ebp),%esi
  800586:	c1 e6 0c             	shl    $0xc,%esi
  800589:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80058f:	83 c4 04             	add    $0x4,%esp
  800592:	ff 75 e4             	pushl  -0x1c(%ebp)
  800595:	e8 d1 fd ff ff       	call   80036b <fd2data>
  80059a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80059c:	89 34 24             	mov    %esi,(%esp)
  80059f:	e8 c7 fd ff ff       	call   80036b <fd2data>
  8005a4:	83 c4 10             	add    $0x10,%esp
  8005a7:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005a9:	89 d8                	mov    %ebx,%eax
  8005ab:	c1 e8 16             	shr    $0x16,%eax
  8005ae:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005b5:	a8 01                	test   $0x1,%al
  8005b7:	74 11                	je     8005ca <dup+0x74>
  8005b9:	89 d8                	mov    %ebx,%eax
  8005bb:	c1 e8 0c             	shr    $0xc,%eax
  8005be:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005c5:	f6 c2 01             	test   $0x1,%dl
  8005c8:	75 39                	jne    800603 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005ca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005cd:	89 d0                	mov    %edx,%eax
  8005cf:	c1 e8 0c             	shr    $0xc,%eax
  8005d2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005d9:	83 ec 0c             	sub    $0xc,%esp
  8005dc:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e1:	50                   	push   %eax
  8005e2:	56                   	push   %esi
  8005e3:	6a 00                	push   $0x0
  8005e5:	52                   	push   %edx
  8005e6:	6a 00                	push   $0x0
  8005e8:	e8 c0 fb ff ff       	call   8001ad <sys_page_map>
  8005ed:	89 c3                	mov    %eax,%ebx
  8005ef:	83 c4 20             	add    $0x20,%esp
  8005f2:	85 c0                	test   %eax,%eax
  8005f4:	78 31                	js     800627 <dup+0xd1>
		goto err;

	return newfdnum;
  8005f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005f9:	89 d8                	mov    %ebx,%eax
  8005fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005fe:	5b                   	pop    %ebx
  8005ff:	5e                   	pop    %esi
  800600:	5f                   	pop    %edi
  800601:	5d                   	pop    %ebp
  800602:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800603:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80060a:	83 ec 0c             	sub    $0xc,%esp
  80060d:	25 07 0e 00 00       	and    $0xe07,%eax
  800612:	50                   	push   %eax
  800613:	57                   	push   %edi
  800614:	6a 00                	push   $0x0
  800616:	53                   	push   %ebx
  800617:	6a 00                	push   $0x0
  800619:	e8 8f fb ff ff       	call   8001ad <sys_page_map>
  80061e:	89 c3                	mov    %eax,%ebx
  800620:	83 c4 20             	add    $0x20,%esp
  800623:	85 c0                	test   %eax,%eax
  800625:	79 a3                	jns    8005ca <dup+0x74>
	sys_page_unmap(0, newfd);
  800627:	83 ec 08             	sub    $0x8,%esp
  80062a:	56                   	push   %esi
  80062b:	6a 00                	push   $0x0
  80062d:	e8 bd fb ff ff       	call   8001ef <sys_page_unmap>
	sys_page_unmap(0, nva);
  800632:	83 c4 08             	add    $0x8,%esp
  800635:	57                   	push   %edi
  800636:	6a 00                	push   $0x0
  800638:	e8 b2 fb ff ff       	call   8001ef <sys_page_unmap>
	return r;
  80063d:	83 c4 10             	add    $0x10,%esp
  800640:	eb b7                	jmp    8005f9 <dup+0xa3>

00800642 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800642:	55                   	push   %ebp
  800643:	89 e5                	mov    %esp,%ebp
  800645:	53                   	push   %ebx
  800646:	83 ec 14             	sub    $0x14,%esp
  800649:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80064c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80064f:	50                   	push   %eax
  800650:	53                   	push   %ebx
  800651:	e8 7b fd ff ff       	call   8003d1 <fd_lookup>
  800656:	83 c4 08             	add    $0x8,%esp
  800659:	85 c0                	test   %eax,%eax
  80065b:	78 3f                	js     80069c <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80065d:	83 ec 08             	sub    $0x8,%esp
  800660:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800663:	50                   	push   %eax
  800664:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800667:	ff 30                	pushl  (%eax)
  800669:	e8 b9 fd ff ff       	call   800427 <dev_lookup>
  80066e:	83 c4 10             	add    $0x10,%esp
  800671:	85 c0                	test   %eax,%eax
  800673:	78 27                	js     80069c <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800675:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800678:	8b 42 08             	mov    0x8(%edx),%eax
  80067b:	83 e0 03             	and    $0x3,%eax
  80067e:	83 f8 01             	cmp    $0x1,%eax
  800681:	74 1e                	je     8006a1 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800683:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800686:	8b 40 08             	mov    0x8(%eax),%eax
  800689:	85 c0                	test   %eax,%eax
  80068b:	74 35                	je     8006c2 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80068d:	83 ec 04             	sub    $0x4,%esp
  800690:	ff 75 10             	pushl  0x10(%ebp)
  800693:	ff 75 0c             	pushl  0xc(%ebp)
  800696:	52                   	push   %edx
  800697:	ff d0                	call   *%eax
  800699:	83 c4 10             	add    $0x10,%esp
}
  80069c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80069f:	c9                   	leave  
  8006a0:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006a1:	a1 04 40 80 00       	mov    0x804004,%eax
  8006a6:	8b 40 48             	mov    0x48(%eax),%eax
  8006a9:	83 ec 04             	sub    $0x4,%esp
  8006ac:	53                   	push   %ebx
  8006ad:	50                   	push   %eax
  8006ae:	68 65 1e 80 00       	push   $0x801e65
  8006b3:	e8 39 0a 00 00       	call   8010f1 <cprintf>
		return -E_INVAL;
  8006b8:	83 c4 10             	add    $0x10,%esp
  8006bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006c0:	eb da                	jmp    80069c <read+0x5a>
		return -E_NOT_SUPP;
  8006c2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006c7:	eb d3                	jmp    80069c <read+0x5a>

008006c9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c9:	55                   	push   %ebp
  8006ca:	89 e5                	mov    %esp,%ebp
  8006cc:	57                   	push   %edi
  8006cd:	56                   	push   %esi
  8006ce:	53                   	push   %ebx
  8006cf:	83 ec 0c             	sub    $0xc,%esp
  8006d2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006d5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006dd:	39 f3                	cmp    %esi,%ebx
  8006df:	73 25                	jae    800706 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006e1:	83 ec 04             	sub    $0x4,%esp
  8006e4:	89 f0                	mov    %esi,%eax
  8006e6:	29 d8                	sub    %ebx,%eax
  8006e8:	50                   	push   %eax
  8006e9:	89 d8                	mov    %ebx,%eax
  8006eb:	03 45 0c             	add    0xc(%ebp),%eax
  8006ee:	50                   	push   %eax
  8006ef:	57                   	push   %edi
  8006f0:	e8 4d ff ff ff       	call   800642 <read>
		if (m < 0)
  8006f5:	83 c4 10             	add    $0x10,%esp
  8006f8:	85 c0                	test   %eax,%eax
  8006fa:	78 08                	js     800704 <readn+0x3b>
			return m;
		if (m == 0)
  8006fc:	85 c0                	test   %eax,%eax
  8006fe:	74 06                	je     800706 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  800700:	01 c3                	add    %eax,%ebx
  800702:	eb d9                	jmp    8006dd <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800704:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  800706:	89 d8                	mov    %ebx,%eax
  800708:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80070b:	5b                   	pop    %ebx
  80070c:	5e                   	pop    %esi
  80070d:	5f                   	pop    %edi
  80070e:	5d                   	pop    %ebp
  80070f:	c3                   	ret    

00800710 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	53                   	push   %ebx
  800714:	83 ec 14             	sub    $0x14,%esp
  800717:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80071a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80071d:	50                   	push   %eax
  80071e:	53                   	push   %ebx
  80071f:	e8 ad fc ff ff       	call   8003d1 <fd_lookup>
  800724:	83 c4 08             	add    $0x8,%esp
  800727:	85 c0                	test   %eax,%eax
  800729:	78 3a                	js     800765 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80072b:	83 ec 08             	sub    $0x8,%esp
  80072e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800731:	50                   	push   %eax
  800732:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800735:	ff 30                	pushl  (%eax)
  800737:	e8 eb fc ff ff       	call   800427 <dev_lookup>
  80073c:	83 c4 10             	add    $0x10,%esp
  80073f:	85 c0                	test   %eax,%eax
  800741:	78 22                	js     800765 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800743:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800746:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80074a:	74 1e                	je     80076a <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80074c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80074f:	8b 52 0c             	mov    0xc(%edx),%edx
  800752:	85 d2                	test   %edx,%edx
  800754:	74 35                	je     80078b <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800756:	83 ec 04             	sub    $0x4,%esp
  800759:	ff 75 10             	pushl  0x10(%ebp)
  80075c:	ff 75 0c             	pushl  0xc(%ebp)
  80075f:	50                   	push   %eax
  800760:	ff d2                	call   *%edx
  800762:	83 c4 10             	add    $0x10,%esp
}
  800765:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800768:	c9                   	leave  
  800769:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80076a:	a1 04 40 80 00       	mov    0x804004,%eax
  80076f:	8b 40 48             	mov    0x48(%eax),%eax
  800772:	83 ec 04             	sub    $0x4,%esp
  800775:	53                   	push   %ebx
  800776:	50                   	push   %eax
  800777:	68 81 1e 80 00       	push   $0x801e81
  80077c:	e8 70 09 00 00       	call   8010f1 <cprintf>
		return -E_INVAL;
  800781:	83 c4 10             	add    $0x10,%esp
  800784:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800789:	eb da                	jmp    800765 <write+0x55>
		return -E_NOT_SUPP;
  80078b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800790:	eb d3                	jmp    800765 <write+0x55>

00800792 <seek>:

int
seek(int fdnum, off_t offset)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800798:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80079b:	50                   	push   %eax
  80079c:	ff 75 08             	pushl  0x8(%ebp)
  80079f:	e8 2d fc ff ff       	call   8003d1 <fd_lookup>
  8007a4:	83 c4 08             	add    $0x8,%esp
  8007a7:	85 c0                	test   %eax,%eax
  8007a9:	78 0e                	js     8007b9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007b1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b9:	c9                   	leave  
  8007ba:	c3                   	ret    

008007bb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	53                   	push   %ebx
  8007bf:	83 ec 14             	sub    $0x14,%esp
  8007c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007c8:	50                   	push   %eax
  8007c9:	53                   	push   %ebx
  8007ca:	e8 02 fc ff ff       	call   8003d1 <fd_lookup>
  8007cf:	83 c4 08             	add    $0x8,%esp
  8007d2:	85 c0                	test   %eax,%eax
  8007d4:	78 37                	js     80080d <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d6:	83 ec 08             	sub    $0x8,%esp
  8007d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007dc:	50                   	push   %eax
  8007dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e0:	ff 30                	pushl  (%eax)
  8007e2:	e8 40 fc ff ff       	call   800427 <dev_lookup>
  8007e7:	83 c4 10             	add    $0x10,%esp
  8007ea:	85 c0                	test   %eax,%eax
  8007ec:	78 1f                	js     80080d <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007f5:	74 1b                	je     800812 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007fa:	8b 52 18             	mov    0x18(%edx),%edx
  8007fd:	85 d2                	test   %edx,%edx
  8007ff:	74 32                	je     800833 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800801:	83 ec 08             	sub    $0x8,%esp
  800804:	ff 75 0c             	pushl  0xc(%ebp)
  800807:	50                   	push   %eax
  800808:	ff d2                	call   *%edx
  80080a:	83 c4 10             	add    $0x10,%esp
}
  80080d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800810:	c9                   	leave  
  800811:	c3                   	ret    
			thisenv->env_id, fdnum);
  800812:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800817:	8b 40 48             	mov    0x48(%eax),%eax
  80081a:	83 ec 04             	sub    $0x4,%esp
  80081d:	53                   	push   %ebx
  80081e:	50                   	push   %eax
  80081f:	68 44 1e 80 00       	push   $0x801e44
  800824:	e8 c8 08 00 00       	call   8010f1 <cprintf>
		return -E_INVAL;
  800829:	83 c4 10             	add    $0x10,%esp
  80082c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800831:	eb da                	jmp    80080d <ftruncate+0x52>
		return -E_NOT_SUPP;
  800833:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800838:	eb d3                	jmp    80080d <ftruncate+0x52>

0080083a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	53                   	push   %ebx
  80083e:	83 ec 14             	sub    $0x14,%esp
  800841:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800844:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800847:	50                   	push   %eax
  800848:	ff 75 08             	pushl  0x8(%ebp)
  80084b:	e8 81 fb ff ff       	call   8003d1 <fd_lookup>
  800850:	83 c4 08             	add    $0x8,%esp
  800853:	85 c0                	test   %eax,%eax
  800855:	78 4b                	js     8008a2 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800857:	83 ec 08             	sub    $0x8,%esp
  80085a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80085d:	50                   	push   %eax
  80085e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800861:	ff 30                	pushl  (%eax)
  800863:	e8 bf fb ff ff       	call   800427 <dev_lookup>
  800868:	83 c4 10             	add    $0x10,%esp
  80086b:	85 c0                	test   %eax,%eax
  80086d:	78 33                	js     8008a2 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  80086f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800872:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800876:	74 2f                	je     8008a7 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800878:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80087b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800882:	00 00 00 
	stat->st_isdir = 0;
  800885:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80088c:	00 00 00 
	stat->st_dev = dev;
  80088f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800895:	83 ec 08             	sub    $0x8,%esp
  800898:	53                   	push   %ebx
  800899:	ff 75 f0             	pushl  -0x10(%ebp)
  80089c:	ff 50 14             	call   *0x14(%eax)
  80089f:	83 c4 10             	add    $0x10,%esp
}
  8008a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008a5:	c9                   	leave  
  8008a6:	c3                   	ret    
		return -E_NOT_SUPP;
  8008a7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008ac:	eb f4                	jmp    8008a2 <fstat+0x68>

008008ae <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	56                   	push   %esi
  8008b2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008b3:	83 ec 08             	sub    $0x8,%esp
  8008b6:	6a 00                	push   $0x0
  8008b8:	ff 75 08             	pushl  0x8(%ebp)
  8008bb:	e8 e7 01 00 00       	call   800aa7 <open>
  8008c0:	89 c3                	mov    %eax,%ebx
  8008c2:	83 c4 10             	add    $0x10,%esp
  8008c5:	85 c0                	test   %eax,%eax
  8008c7:	78 1b                	js     8008e4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008c9:	83 ec 08             	sub    $0x8,%esp
  8008cc:	ff 75 0c             	pushl  0xc(%ebp)
  8008cf:	50                   	push   %eax
  8008d0:	e8 65 ff ff ff       	call   80083a <fstat>
  8008d5:	89 c6                	mov    %eax,%esi
	close(fd);
  8008d7:	89 1c 24             	mov    %ebx,(%esp)
  8008da:	e8 27 fc ff ff       	call   800506 <close>
	return r;
  8008df:	83 c4 10             	add    $0x10,%esp
  8008e2:	89 f3                	mov    %esi,%ebx
}
  8008e4:	89 d8                	mov    %ebx,%eax
  8008e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008e9:	5b                   	pop    %ebx
  8008ea:	5e                   	pop    %esi
  8008eb:	5d                   	pop    %ebp
  8008ec:	c3                   	ret    

008008ed <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	56                   	push   %esi
  8008f1:	53                   	push   %ebx
  8008f2:	89 c6                	mov    %eax,%esi
  8008f4:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008f6:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008fd:	74 27                	je     800926 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008ff:	6a 07                	push   $0x7
  800901:	68 00 50 80 00       	push   $0x805000
  800906:	56                   	push   %esi
  800907:	ff 35 00 40 80 00    	pushl  0x804000
  80090d:	e8 b0 11 00 00       	call   801ac2 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800912:	83 c4 0c             	add    $0xc,%esp
  800915:	6a 00                	push   $0x0
  800917:	53                   	push   %ebx
  800918:	6a 00                	push   $0x0
  80091a:	e8 2e 11 00 00       	call   801a4d <ipc_recv>
}
  80091f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800922:	5b                   	pop    %ebx
  800923:	5e                   	pop    %esi
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800926:	83 ec 0c             	sub    $0xc,%esp
  800929:	6a 01                	push   $0x1
  80092b:	e8 e8 11 00 00       	call   801b18 <ipc_find_env>
  800930:	a3 00 40 80 00       	mov    %eax,0x804000
  800935:	83 c4 10             	add    $0x10,%esp
  800938:	eb c5                	jmp    8008ff <fsipc+0x12>

0080093a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800940:	8b 45 08             	mov    0x8(%ebp),%eax
  800943:	8b 40 0c             	mov    0xc(%eax),%eax
  800946:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80094b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800953:	ba 00 00 00 00       	mov    $0x0,%edx
  800958:	b8 02 00 00 00       	mov    $0x2,%eax
  80095d:	e8 8b ff ff ff       	call   8008ed <fsipc>
}
  800962:	c9                   	leave  
  800963:	c3                   	ret    

00800964 <devfile_flush>:
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80096a:	8b 45 08             	mov    0x8(%ebp),%eax
  80096d:	8b 40 0c             	mov    0xc(%eax),%eax
  800970:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800975:	ba 00 00 00 00       	mov    $0x0,%edx
  80097a:	b8 06 00 00 00       	mov    $0x6,%eax
  80097f:	e8 69 ff ff ff       	call   8008ed <fsipc>
}
  800984:	c9                   	leave  
  800985:	c3                   	ret    

00800986 <devfile_stat>:
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	53                   	push   %ebx
  80098a:	83 ec 04             	sub    $0x4,%esp
  80098d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800990:	8b 45 08             	mov    0x8(%ebp),%eax
  800993:	8b 40 0c             	mov    0xc(%eax),%eax
  800996:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80099b:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a0:	b8 05 00 00 00       	mov    $0x5,%eax
  8009a5:	e8 43 ff ff ff       	call   8008ed <fsipc>
  8009aa:	85 c0                	test   %eax,%eax
  8009ac:	78 2c                	js     8009da <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009ae:	83 ec 08             	sub    $0x8,%esp
  8009b1:	68 00 50 80 00       	push   $0x805000
  8009b6:	53                   	push   %ebx
  8009b7:	e8 54 0d 00 00       	call   801710 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009bc:	a1 80 50 80 00       	mov    0x805080,%eax
  8009c1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009c7:	a1 84 50 80 00       	mov    0x805084,%eax
  8009cc:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009d2:	83 c4 10             	add    $0x10,%esp
  8009d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009dd:	c9                   	leave  
  8009de:	c3                   	ret    

008009df <devfile_write>:
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	83 ec 0c             	sub    $0xc,%esp
  8009e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8009e8:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009ed:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8009f2:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f8:	8b 52 0c             	mov    0xc(%edx),%edx
  8009fb:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a01:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf,buf,n);
  800a06:	50                   	push   %eax
  800a07:	ff 75 0c             	pushl  0xc(%ebp)
  800a0a:	68 08 50 80 00       	push   $0x805008
  800a0f:	e8 8a 0e 00 00       	call   80189e <memmove>
	if((r = fsipc(FSREQ_WRITE,NULL))<0)
  800a14:	ba 00 00 00 00       	mov    $0x0,%edx
  800a19:	b8 04 00 00 00       	mov    $0x4,%eax
  800a1e:	e8 ca fe ff ff       	call   8008ed <fsipc>
}
  800a23:	c9                   	leave  
  800a24:	c3                   	ret    

00800a25 <devfile_read>:
{
  800a25:	55                   	push   %ebp
  800a26:	89 e5                	mov    %esp,%ebp
  800a28:	56                   	push   %esi
  800a29:	53                   	push   %ebx
  800a2a:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a30:	8b 40 0c             	mov    0xc(%eax),%eax
  800a33:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a38:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a43:	b8 03 00 00 00       	mov    $0x3,%eax
  800a48:	e8 a0 fe ff ff       	call   8008ed <fsipc>
  800a4d:	89 c3                	mov    %eax,%ebx
  800a4f:	85 c0                	test   %eax,%eax
  800a51:	78 1f                	js     800a72 <devfile_read+0x4d>
	assert(r <= n);
  800a53:	39 f0                	cmp    %esi,%eax
  800a55:	77 24                	ja     800a7b <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a57:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a5c:	7f 33                	jg     800a91 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a5e:	83 ec 04             	sub    $0x4,%esp
  800a61:	50                   	push   %eax
  800a62:	68 00 50 80 00       	push   $0x805000
  800a67:	ff 75 0c             	pushl  0xc(%ebp)
  800a6a:	e8 2f 0e 00 00       	call   80189e <memmove>
	return r;
  800a6f:	83 c4 10             	add    $0x10,%esp
}
  800a72:	89 d8                	mov    %ebx,%eax
  800a74:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a77:	5b                   	pop    %ebx
  800a78:	5e                   	pop    %esi
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    
	assert(r <= n);
  800a7b:	68 b0 1e 80 00       	push   $0x801eb0
  800a80:	68 b7 1e 80 00       	push   $0x801eb7
  800a85:	6a 7c                	push   $0x7c
  800a87:	68 cc 1e 80 00       	push   $0x801ecc
  800a8c:	e8 85 05 00 00       	call   801016 <_panic>
	assert(r <= PGSIZE);
  800a91:	68 d7 1e 80 00       	push   $0x801ed7
  800a96:	68 b7 1e 80 00       	push   $0x801eb7
  800a9b:	6a 7d                	push   $0x7d
  800a9d:	68 cc 1e 80 00       	push   $0x801ecc
  800aa2:	e8 6f 05 00 00       	call   801016 <_panic>

00800aa7 <open>:
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	56                   	push   %esi
  800aab:	53                   	push   %ebx
  800aac:	83 ec 1c             	sub    $0x1c,%esp
  800aaf:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800ab2:	56                   	push   %esi
  800ab3:	e8 21 0c 00 00       	call   8016d9 <strlen>
  800ab8:	83 c4 10             	add    $0x10,%esp
  800abb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ac0:	7f 6c                	jg     800b2e <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800ac2:	83 ec 0c             	sub    $0xc,%esp
  800ac5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ac8:	50                   	push   %eax
  800ac9:	e8 b4 f8 ff ff       	call   800382 <fd_alloc>
  800ace:	89 c3                	mov    %eax,%ebx
  800ad0:	83 c4 10             	add    $0x10,%esp
  800ad3:	85 c0                	test   %eax,%eax
  800ad5:	78 3c                	js     800b13 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800ad7:	83 ec 08             	sub    $0x8,%esp
  800ada:	56                   	push   %esi
  800adb:	68 00 50 80 00       	push   $0x805000
  800ae0:	e8 2b 0c 00 00       	call   801710 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ae5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae8:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800aed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800af0:	b8 01 00 00 00       	mov    $0x1,%eax
  800af5:	e8 f3 fd ff ff       	call   8008ed <fsipc>
  800afa:	89 c3                	mov    %eax,%ebx
  800afc:	83 c4 10             	add    $0x10,%esp
  800aff:	85 c0                	test   %eax,%eax
  800b01:	78 19                	js     800b1c <open+0x75>
	return fd2num(fd);
  800b03:	83 ec 0c             	sub    $0xc,%esp
  800b06:	ff 75 f4             	pushl  -0xc(%ebp)
  800b09:	e8 4d f8 ff ff       	call   80035b <fd2num>
  800b0e:	89 c3                	mov    %eax,%ebx
  800b10:	83 c4 10             	add    $0x10,%esp
}
  800b13:	89 d8                	mov    %ebx,%eax
  800b15:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b18:	5b                   	pop    %ebx
  800b19:	5e                   	pop    %esi
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    
		fd_close(fd, 0);
  800b1c:	83 ec 08             	sub    $0x8,%esp
  800b1f:	6a 00                	push   $0x0
  800b21:	ff 75 f4             	pushl  -0xc(%ebp)
  800b24:	e8 54 f9 ff ff       	call   80047d <fd_close>
		return r;
  800b29:	83 c4 10             	add    $0x10,%esp
  800b2c:	eb e5                	jmp    800b13 <open+0x6c>
		return -E_BAD_PATH;
  800b2e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b33:	eb de                	jmp    800b13 <open+0x6c>

00800b35 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b40:	b8 08 00 00 00       	mov    $0x8,%eax
  800b45:	e8 a3 fd ff ff       	call   8008ed <fsipc>
}
  800b4a:	c9                   	leave  
  800b4b:	c3                   	ret    

00800b4c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	56                   	push   %esi
  800b50:	53                   	push   %ebx
  800b51:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b54:	83 ec 0c             	sub    $0xc,%esp
  800b57:	ff 75 08             	pushl  0x8(%ebp)
  800b5a:	e8 0c f8 ff ff       	call   80036b <fd2data>
  800b5f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b61:	83 c4 08             	add    $0x8,%esp
  800b64:	68 e3 1e 80 00       	push   $0x801ee3
  800b69:	53                   	push   %ebx
  800b6a:	e8 a1 0b 00 00       	call   801710 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b6f:	8b 46 04             	mov    0x4(%esi),%eax
  800b72:	2b 06                	sub    (%esi),%eax
  800b74:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b7a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b81:	00 00 00 
	stat->st_dev = &devpipe;
  800b84:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  800b8b:	30 80 00 
	return 0;
}
  800b8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b93:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	53                   	push   %ebx
  800b9e:	83 ec 0c             	sub    $0xc,%esp
  800ba1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800ba4:	53                   	push   %ebx
  800ba5:	6a 00                	push   $0x0
  800ba7:	e8 43 f6 ff ff       	call   8001ef <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bac:	89 1c 24             	mov    %ebx,(%esp)
  800baf:	e8 b7 f7 ff ff       	call   80036b <fd2data>
  800bb4:	83 c4 08             	add    $0x8,%esp
  800bb7:	50                   	push   %eax
  800bb8:	6a 00                	push   $0x0
  800bba:	e8 30 f6 ff ff       	call   8001ef <sys_page_unmap>
}
  800bbf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bc2:	c9                   	leave  
  800bc3:	c3                   	ret    

00800bc4 <_pipeisclosed>:
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	57                   	push   %edi
  800bc8:	56                   	push   %esi
  800bc9:	53                   	push   %ebx
  800bca:	83 ec 1c             	sub    $0x1c,%esp
  800bcd:	89 c7                	mov    %eax,%edi
  800bcf:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800bd1:	a1 04 40 80 00       	mov    0x804004,%eax
  800bd6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800bd9:	83 ec 0c             	sub    $0xc,%esp
  800bdc:	57                   	push   %edi
  800bdd:	e8 6f 0f 00 00       	call   801b51 <pageref>
  800be2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800be5:	89 34 24             	mov    %esi,(%esp)
  800be8:	e8 64 0f 00 00       	call   801b51 <pageref>
		nn = thisenv->env_runs;
  800bed:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bf3:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bf6:	83 c4 10             	add    $0x10,%esp
  800bf9:	39 cb                	cmp    %ecx,%ebx
  800bfb:	74 1b                	je     800c18 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800bfd:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c00:	75 cf                	jne    800bd1 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c02:	8b 42 58             	mov    0x58(%edx),%eax
  800c05:	6a 01                	push   $0x1
  800c07:	50                   	push   %eax
  800c08:	53                   	push   %ebx
  800c09:	68 ea 1e 80 00       	push   $0x801eea
  800c0e:	e8 de 04 00 00       	call   8010f1 <cprintf>
  800c13:	83 c4 10             	add    $0x10,%esp
  800c16:	eb b9                	jmp    800bd1 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c18:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c1b:	0f 94 c0             	sete   %al
  800c1e:	0f b6 c0             	movzbl %al,%eax
}
  800c21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c24:	5b                   	pop    %ebx
  800c25:	5e                   	pop    %esi
  800c26:	5f                   	pop    %edi
  800c27:	5d                   	pop    %ebp
  800c28:	c3                   	ret    

00800c29 <devpipe_write>:
{
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
  800c2c:	57                   	push   %edi
  800c2d:	56                   	push   %esi
  800c2e:	53                   	push   %ebx
  800c2f:	83 ec 28             	sub    $0x28,%esp
  800c32:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c35:	56                   	push   %esi
  800c36:	e8 30 f7 ff ff       	call   80036b <fd2data>
  800c3b:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c3d:	83 c4 10             	add    $0x10,%esp
  800c40:	bf 00 00 00 00       	mov    $0x0,%edi
  800c45:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c48:	74 4f                	je     800c99 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c4a:	8b 43 04             	mov    0x4(%ebx),%eax
  800c4d:	8b 0b                	mov    (%ebx),%ecx
  800c4f:	8d 51 20             	lea    0x20(%ecx),%edx
  800c52:	39 d0                	cmp    %edx,%eax
  800c54:	72 14                	jb     800c6a <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  800c56:	89 da                	mov    %ebx,%edx
  800c58:	89 f0                	mov    %esi,%eax
  800c5a:	e8 65 ff ff ff       	call   800bc4 <_pipeisclosed>
  800c5f:	85 c0                	test   %eax,%eax
  800c61:	75 3a                	jne    800c9d <devpipe_write+0x74>
			sys_yield();
  800c63:	e8 e3 f4 ff ff       	call   80014b <sys_yield>
  800c68:	eb e0                	jmp    800c4a <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c71:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c74:	89 c2                	mov    %eax,%edx
  800c76:	c1 fa 1f             	sar    $0x1f,%edx
  800c79:	89 d1                	mov    %edx,%ecx
  800c7b:	c1 e9 1b             	shr    $0x1b,%ecx
  800c7e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c81:	83 e2 1f             	and    $0x1f,%edx
  800c84:	29 ca                	sub    %ecx,%edx
  800c86:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c8a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c8e:	83 c0 01             	add    $0x1,%eax
  800c91:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800c94:	83 c7 01             	add    $0x1,%edi
  800c97:	eb ac                	jmp    800c45 <devpipe_write+0x1c>
	return i;
  800c99:	89 f8                	mov    %edi,%eax
  800c9b:	eb 05                	jmp    800ca2 <devpipe_write+0x79>
				return 0;
  800c9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ca2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    

00800caa <devpipe_read>:
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	57                   	push   %edi
  800cae:	56                   	push   %esi
  800caf:	53                   	push   %ebx
  800cb0:	83 ec 18             	sub    $0x18,%esp
  800cb3:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800cb6:	57                   	push   %edi
  800cb7:	e8 af f6 ff ff       	call   80036b <fd2data>
  800cbc:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800cbe:	83 c4 10             	add    $0x10,%esp
  800cc1:	be 00 00 00 00       	mov    $0x0,%esi
  800cc6:	3b 75 10             	cmp    0x10(%ebp),%esi
  800cc9:	74 47                	je     800d12 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  800ccb:	8b 03                	mov    (%ebx),%eax
  800ccd:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cd0:	75 22                	jne    800cf4 <devpipe_read+0x4a>
			if (i > 0)
  800cd2:	85 f6                	test   %esi,%esi
  800cd4:	75 14                	jne    800cea <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  800cd6:	89 da                	mov    %ebx,%edx
  800cd8:	89 f8                	mov    %edi,%eax
  800cda:	e8 e5 fe ff ff       	call   800bc4 <_pipeisclosed>
  800cdf:	85 c0                	test   %eax,%eax
  800ce1:	75 33                	jne    800d16 <devpipe_read+0x6c>
			sys_yield();
  800ce3:	e8 63 f4 ff ff       	call   80014b <sys_yield>
  800ce8:	eb e1                	jmp    800ccb <devpipe_read+0x21>
				return i;
  800cea:	89 f0                	mov    %esi,%eax
}
  800cec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5f                   	pop    %edi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cf4:	99                   	cltd   
  800cf5:	c1 ea 1b             	shr    $0x1b,%edx
  800cf8:	01 d0                	add    %edx,%eax
  800cfa:	83 e0 1f             	and    $0x1f,%eax
  800cfd:	29 d0                	sub    %edx,%eax
  800cff:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d07:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d0a:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d0d:	83 c6 01             	add    $0x1,%esi
  800d10:	eb b4                	jmp    800cc6 <devpipe_read+0x1c>
	return i;
  800d12:	89 f0                	mov    %esi,%eax
  800d14:	eb d6                	jmp    800cec <devpipe_read+0x42>
				return 0;
  800d16:	b8 00 00 00 00       	mov    $0x0,%eax
  800d1b:	eb cf                	jmp    800cec <devpipe_read+0x42>

00800d1d <pipe>:
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	56                   	push   %esi
  800d21:	53                   	push   %ebx
  800d22:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d25:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d28:	50                   	push   %eax
  800d29:	e8 54 f6 ff ff       	call   800382 <fd_alloc>
  800d2e:	89 c3                	mov    %eax,%ebx
  800d30:	83 c4 10             	add    $0x10,%esp
  800d33:	85 c0                	test   %eax,%eax
  800d35:	78 5b                	js     800d92 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d37:	83 ec 04             	sub    $0x4,%esp
  800d3a:	68 07 04 00 00       	push   $0x407
  800d3f:	ff 75 f4             	pushl  -0xc(%ebp)
  800d42:	6a 00                	push   $0x0
  800d44:	e8 21 f4 ff ff       	call   80016a <sys_page_alloc>
  800d49:	89 c3                	mov    %eax,%ebx
  800d4b:	83 c4 10             	add    $0x10,%esp
  800d4e:	85 c0                	test   %eax,%eax
  800d50:	78 40                	js     800d92 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  800d52:	83 ec 0c             	sub    $0xc,%esp
  800d55:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d58:	50                   	push   %eax
  800d59:	e8 24 f6 ff ff       	call   800382 <fd_alloc>
  800d5e:	89 c3                	mov    %eax,%ebx
  800d60:	83 c4 10             	add    $0x10,%esp
  800d63:	85 c0                	test   %eax,%eax
  800d65:	78 1b                	js     800d82 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d67:	83 ec 04             	sub    $0x4,%esp
  800d6a:	68 07 04 00 00       	push   $0x407
  800d6f:	ff 75 f0             	pushl  -0x10(%ebp)
  800d72:	6a 00                	push   $0x0
  800d74:	e8 f1 f3 ff ff       	call   80016a <sys_page_alloc>
  800d79:	89 c3                	mov    %eax,%ebx
  800d7b:	83 c4 10             	add    $0x10,%esp
  800d7e:	85 c0                	test   %eax,%eax
  800d80:	79 19                	jns    800d9b <pipe+0x7e>
	sys_page_unmap(0, fd0);
  800d82:	83 ec 08             	sub    $0x8,%esp
  800d85:	ff 75 f4             	pushl  -0xc(%ebp)
  800d88:	6a 00                	push   $0x0
  800d8a:	e8 60 f4 ff ff       	call   8001ef <sys_page_unmap>
  800d8f:	83 c4 10             	add    $0x10,%esp
}
  800d92:	89 d8                	mov    %ebx,%eax
  800d94:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d97:	5b                   	pop    %ebx
  800d98:	5e                   	pop    %esi
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    
	va = fd2data(fd0);
  800d9b:	83 ec 0c             	sub    $0xc,%esp
  800d9e:	ff 75 f4             	pushl  -0xc(%ebp)
  800da1:	e8 c5 f5 ff ff       	call   80036b <fd2data>
  800da6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da8:	83 c4 0c             	add    $0xc,%esp
  800dab:	68 07 04 00 00       	push   $0x407
  800db0:	50                   	push   %eax
  800db1:	6a 00                	push   $0x0
  800db3:	e8 b2 f3 ff ff       	call   80016a <sys_page_alloc>
  800db8:	89 c3                	mov    %eax,%ebx
  800dba:	83 c4 10             	add    $0x10,%esp
  800dbd:	85 c0                	test   %eax,%eax
  800dbf:	0f 88 8c 00 00 00    	js     800e51 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc5:	83 ec 0c             	sub    $0xc,%esp
  800dc8:	ff 75 f0             	pushl  -0x10(%ebp)
  800dcb:	e8 9b f5 ff ff       	call   80036b <fd2data>
  800dd0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dd7:	50                   	push   %eax
  800dd8:	6a 00                	push   $0x0
  800dda:	56                   	push   %esi
  800ddb:	6a 00                	push   $0x0
  800ddd:	e8 cb f3 ff ff       	call   8001ad <sys_page_map>
  800de2:	89 c3                	mov    %eax,%ebx
  800de4:	83 c4 20             	add    $0x20,%esp
  800de7:	85 c0                	test   %eax,%eax
  800de9:	78 58                	js     800e43 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  800deb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dee:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800df4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800df6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800df9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  800e00:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e03:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800e09:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e0e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e15:	83 ec 0c             	sub    $0xc,%esp
  800e18:	ff 75 f4             	pushl  -0xc(%ebp)
  800e1b:	e8 3b f5 ff ff       	call   80035b <fd2num>
  800e20:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e23:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e25:	83 c4 04             	add    $0x4,%esp
  800e28:	ff 75 f0             	pushl  -0x10(%ebp)
  800e2b:	e8 2b f5 ff ff       	call   80035b <fd2num>
  800e30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e33:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e36:	83 c4 10             	add    $0x10,%esp
  800e39:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3e:	e9 4f ff ff ff       	jmp    800d92 <pipe+0x75>
	sys_page_unmap(0, va);
  800e43:	83 ec 08             	sub    $0x8,%esp
  800e46:	56                   	push   %esi
  800e47:	6a 00                	push   $0x0
  800e49:	e8 a1 f3 ff ff       	call   8001ef <sys_page_unmap>
  800e4e:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e51:	83 ec 08             	sub    $0x8,%esp
  800e54:	ff 75 f0             	pushl  -0x10(%ebp)
  800e57:	6a 00                	push   $0x0
  800e59:	e8 91 f3 ff ff       	call   8001ef <sys_page_unmap>
  800e5e:	83 c4 10             	add    $0x10,%esp
  800e61:	e9 1c ff ff ff       	jmp    800d82 <pipe+0x65>

00800e66 <pipeisclosed>:
{
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
  800e69:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e6c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e6f:	50                   	push   %eax
  800e70:	ff 75 08             	pushl  0x8(%ebp)
  800e73:	e8 59 f5 ff ff       	call   8003d1 <fd_lookup>
  800e78:	83 c4 10             	add    $0x10,%esp
  800e7b:	85 c0                	test   %eax,%eax
  800e7d:	78 18                	js     800e97 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  800e7f:	83 ec 0c             	sub    $0xc,%esp
  800e82:	ff 75 f4             	pushl  -0xc(%ebp)
  800e85:	e8 e1 f4 ff ff       	call   80036b <fd2data>
	return _pipeisclosed(fd, p);
  800e8a:	89 c2                	mov    %eax,%edx
  800e8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e8f:	e8 30 fd ff ff       	call   800bc4 <_pipeisclosed>
  800e94:	83 c4 10             	add    $0x10,%esp
}
  800e97:	c9                   	leave  
  800e98:	c3                   	ret    

00800e99 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e9c:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    

00800ea3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ea9:	68 02 1f 80 00       	push   $0x801f02
  800eae:	ff 75 0c             	pushl  0xc(%ebp)
  800eb1:	e8 5a 08 00 00       	call   801710 <strcpy>
	return 0;
}
  800eb6:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebb:	c9                   	leave  
  800ebc:	c3                   	ret    

00800ebd <devcons_write>:
{
  800ebd:	55                   	push   %ebp
  800ebe:	89 e5                	mov    %esp,%ebp
  800ec0:	57                   	push   %edi
  800ec1:	56                   	push   %esi
  800ec2:	53                   	push   %ebx
  800ec3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800ec9:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800ece:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800ed4:	eb 2f                	jmp    800f05 <devcons_write+0x48>
		m = n - tot;
  800ed6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ed9:	29 f3                	sub    %esi,%ebx
  800edb:	83 fb 7f             	cmp    $0x7f,%ebx
  800ede:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800ee3:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800ee6:	83 ec 04             	sub    $0x4,%esp
  800ee9:	53                   	push   %ebx
  800eea:	89 f0                	mov    %esi,%eax
  800eec:	03 45 0c             	add    0xc(%ebp),%eax
  800eef:	50                   	push   %eax
  800ef0:	57                   	push   %edi
  800ef1:	e8 a8 09 00 00       	call   80189e <memmove>
		sys_cputs(buf, m);
  800ef6:	83 c4 08             	add    $0x8,%esp
  800ef9:	53                   	push   %ebx
  800efa:	57                   	push   %edi
  800efb:	e8 ae f1 ff ff       	call   8000ae <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f00:	01 de                	add    %ebx,%esi
  800f02:	83 c4 10             	add    $0x10,%esp
  800f05:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f08:	72 cc                	jb     800ed6 <devcons_write+0x19>
}
  800f0a:	89 f0                	mov    %esi,%eax
  800f0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f0f:	5b                   	pop    %ebx
  800f10:	5e                   	pop    %esi
  800f11:	5f                   	pop    %edi
  800f12:	5d                   	pop    %ebp
  800f13:	c3                   	ret    

00800f14 <devcons_read>:
{
  800f14:	55                   	push   %ebp
  800f15:	89 e5                	mov    %esp,%ebp
  800f17:	83 ec 08             	sub    $0x8,%esp
  800f1a:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f1f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f23:	75 07                	jne    800f2c <devcons_read+0x18>
}
  800f25:	c9                   	leave  
  800f26:	c3                   	ret    
		sys_yield();
  800f27:	e8 1f f2 ff ff       	call   80014b <sys_yield>
	while ((c = sys_cgetc()) == 0)
  800f2c:	e8 9b f1 ff ff       	call   8000cc <sys_cgetc>
  800f31:	85 c0                	test   %eax,%eax
  800f33:	74 f2                	je     800f27 <devcons_read+0x13>
	if (c < 0)
  800f35:	85 c0                	test   %eax,%eax
  800f37:	78 ec                	js     800f25 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  800f39:	83 f8 04             	cmp    $0x4,%eax
  800f3c:	74 0c                	je     800f4a <devcons_read+0x36>
	*(char*)vbuf = c;
  800f3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f41:	88 02                	mov    %al,(%edx)
	return 1;
  800f43:	b8 01 00 00 00       	mov    $0x1,%eax
  800f48:	eb db                	jmp    800f25 <devcons_read+0x11>
		return 0;
  800f4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4f:	eb d4                	jmp    800f25 <devcons_read+0x11>

00800f51 <cputchar>:
{
  800f51:	55                   	push   %ebp
  800f52:	89 e5                	mov    %esp,%ebp
  800f54:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f57:	8b 45 08             	mov    0x8(%ebp),%eax
  800f5a:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800f5d:	6a 01                	push   $0x1
  800f5f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f62:	50                   	push   %eax
  800f63:	e8 46 f1 ff ff       	call   8000ae <sys_cputs>
}
  800f68:	83 c4 10             	add    $0x10,%esp
  800f6b:	c9                   	leave  
  800f6c:	c3                   	ret    

00800f6d <getchar>:
{
  800f6d:	55                   	push   %ebp
  800f6e:	89 e5                	mov    %esp,%ebp
  800f70:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800f73:	6a 01                	push   $0x1
  800f75:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f78:	50                   	push   %eax
  800f79:	6a 00                	push   $0x0
  800f7b:	e8 c2 f6 ff ff       	call   800642 <read>
	if (r < 0)
  800f80:	83 c4 10             	add    $0x10,%esp
  800f83:	85 c0                	test   %eax,%eax
  800f85:	78 08                	js     800f8f <getchar+0x22>
	if (r < 1)
  800f87:	85 c0                	test   %eax,%eax
  800f89:	7e 06                	jle    800f91 <getchar+0x24>
	return c;
  800f8b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800f8f:	c9                   	leave  
  800f90:	c3                   	ret    
		return -E_EOF;
  800f91:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800f96:	eb f7                	jmp    800f8f <getchar+0x22>

00800f98 <iscons>:
{
  800f98:	55                   	push   %ebp
  800f99:	89 e5                	mov    %esp,%ebp
  800f9b:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fa1:	50                   	push   %eax
  800fa2:	ff 75 08             	pushl  0x8(%ebp)
  800fa5:	e8 27 f4 ff ff       	call   8003d1 <fd_lookup>
  800faa:	83 c4 10             	add    $0x10,%esp
  800fad:	85 c0                	test   %eax,%eax
  800faf:	78 11                	js     800fc2 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  800fb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fb4:	8b 15 40 30 80 00    	mov    0x803040,%edx
  800fba:	39 10                	cmp    %edx,(%eax)
  800fbc:	0f 94 c0             	sete   %al
  800fbf:	0f b6 c0             	movzbl %al,%eax
}
  800fc2:	c9                   	leave  
  800fc3:	c3                   	ret    

00800fc4 <opencons>:
{
  800fc4:	55                   	push   %ebp
  800fc5:	89 e5                	mov    %esp,%ebp
  800fc7:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800fca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fcd:	50                   	push   %eax
  800fce:	e8 af f3 ff ff       	call   800382 <fd_alloc>
  800fd3:	83 c4 10             	add    $0x10,%esp
  800fd6:	85 c0                	test   %eax,%eax
  800fd8:	78 3a                	js     801014 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fda:	83 ec 04             	sub    $0x4,%esp
  800fdd:	68 07 04 00 00       	push   $0x407
  800fe2:	ff 75 f4             	pushl  -0xc(%ebp)
  800fe5:	6a 00                	push   $0x0
  800fe7:	e8 7e f1 ff ff       	call   80016a <sys_page_alloc>
  800fec:	83 c4 10             	add    $0x10,%esp
  800fef:	85 c0                	test   %eax,%eax
  800ff1:	78 21                	js     801014 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  800ff3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff6:	8b 15 40 30 80 00    	mov    0x803040,%edx
  800ffc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800ffe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801001:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801008:	83 ec 0c             	sub    $0xc,%esp
  80100b:	50                   	push   %eax
  80100c:	e8 4a f3 ff ff       	call   80035b <fd2num>
  801011:	83 c4 10             	add    $0x10,%esp
}
  801014:	c9                   	leave  
  801015:	c3                   	ret    

00801016 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801016:	55                   	push   %ebp
  801017:	89 e5                	mov    %esp,%ebp
  801019:	56                   	push   %esi
  80101a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80101b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80101e:	8b 35 04 30 80 00    	mov    0x803004,%esi
  801024:	e8 03 f1 ff ff       	call   80012c <sys_getenvid>
  801029:	83 ec 0c             	sub    $0xc,%esp
  80102c:	ff 75 0c             	pushl  0xc(%ebp)
  80102f:	ff 75 08             	pushl  0x8(%ebp)
  801032:	56                   	push   %esi
  801033:	50                   	push   %eax
  801034:	68 10 1f 80 00       	push   $0x801f10
  801039:	e8 b3 00 00 00       	call   8010f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80103e:	83 c4 18             	add    $0x18,%esp
  801041:	53                   	push   %ebx
  801042:	ff 75 10             	pushl  0x10(%ebp)
  801045:	e8 56 00 00 00       	call   8010a0 <vcprintf>
	cprintf("\n");
  80104a:	c7 04 24 fb 1e 80 00 	movl   $0x801efb,(%esp)
  801051:	e8 9b 00 00 00       	call   8010f1 <cprintf>
  801056:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801059:	cc                   	int3   
  80105a:	eb fd                	jmp    801059 <_panic+0x43>

0080105c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80105c:	55                   	push   %ebp
  80105d:	89 e5                	mov    %esp,%ebp
  80105f:	53                   	push   %ebx
  801060:	83 ec 04             	sub    $0x4,%esp
  801063:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801066:	8b 13                	mov    (%ebx),%edx
  801068:	8d 42 01             	lea    0x1(%edx),%eax
  80106b:	89 03                	mov    %eax,(%ebx)
  80106d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801070:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801074:	3d ff 00 00 00       	cmp    $0xff,%eax
  801079:	74 09                	je     801084 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80107b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80107f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801082:	c9                   	leave  
  801083:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801084:	83 ec 08             	sub    $0x8,%esp
  801087:	68 ff 00 00 00       	push   $0xff
  80108c:	8d 43 08             	lea    0x8(%ebx),%eax
  80108f:	50                   	push   %eax
  801090:	e8 19 f0 ff ff       	call   8000ae <sys_cputs>
		b->idx = 0;
  801095:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80109b:	83 c4 10             	add    $0x10,%esp
  80109e:	eb db                	jmp    80107b <putch+0x1f>

008010a0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
  8010a3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010a9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010b0:	00 00 00 
	b.cnt = 0;
  8010b3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010ba:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010bd:	ff 75 0c             	pushl  0xc(%ebp)
  8010c0:	ff 75 08             	pushl  0x8(%ebp)
  8010c3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010c9:	50                   	push   %eax
  8010ca:	68 5c 10 80 00       	push   $0x80105c
  8010cf:	e8 1a 01 00 00       	call   8011ee <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010d4:	83 c4 08             	add    $0x8,%esp
  8010d7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010dd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010e3:	50                   	push   %eax
  8010e4:	e8 c5 ef ff ff       	call   8000ae <sys_cputs>

	return b.cnt;
}
  8010e9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010ef:	c9                   	leave  
  8010f0:	c3                   	ret    

008010f1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010f1:	55                   	push   %ebp
  8010f2:	89 e5                	mov    %esp,%ebp
  8010f4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010f7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010fa:	50                   	push   %eax
  8010fb:	ff 75 08             	pushl  0x8(%ebp)
  8010fe:	e8 9d ff ff ff       	call   8010a0 <vcprintf>
	va_end(ap);

	return cnt;
}
  801103:	c9                   	leave  
  801104:	c3                   	ret    

00801105 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801105:	55                   	push   %ebp
  801106:	89 e5                	mov    %esp,%ebp
  801108:	57                   	push   %edi
  801109:	56                   	push   %esi
  80110a:	53                   	push   %ebx
  80110b:	83 ec 1c             	sub    $0x1c,%esp
  80110e:	89 c7                	mov    %eax,%edi
  801110:	89 d6                	mov    %edx,%esi
  801112:	8b 45 08             	mov    0x8(%ebp),%eax
  801115:	8b 55 0c             	mov    0xc(%ebp),%edx
  801118:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80111b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80111e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801121:	bb 00 00 00 00       	mov    $0x0,%ebx
  801126:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801129:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80112c:	39 d3                	cmp    %edx,%ebx
  80112e:	72 05                	jb     801135 <printnum+0x30>
  801130:	39 45 10             	cmp    %eax,0x10(%ebp)
  801133:	77 7a                	ja     8011af <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801135:	83 ec 0c             	sub    $0xc,%esp
  801138:	ff 75 18             	pushl  0x18(%ebp)
  80113b:	8b 45 14             	mov    0x14(%ebp),%eax
  80113e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801141:	53                   	push   %ebx
  801142:	ff 75 10             	pushl  0x10(%ebp)
  801145:	83 ec 08             	sub    $0x8,%esp
  801148:	ff 75 e4             	pushl  -0x1c(%ebp)
  80114b:	ff 75 e0             	pushl  -0x20(%ebp)
  80114e:	ff 75 dc             	pushl  -0x24(%ebp)
  801151:	ff 75 d8             	pushl  -0x28(%ebp)
  801154:	e8 37 0a 00 00       	call   801b90 <__udivdi3>
  801159:	83 c4 18             	add    $0x18,%esp
  80115c:	52                   	push   %edx
  80115d:	50                   	push   %eax
  80115e:	89 f2                	mov    %esi,%edx
  801160:	89 f8                	mov    %edi,%eax
  801162:	e8 9e ff ff ff       	call   801105 <printnum>
  801167:	83 c4 20             	add    $0x20,%esp
  80116a:	eb 13                	jmp    80117f <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80116c:	83 ec 08             	sub    $0x8,%esp
  80116f:	56                   	push   %esi
  801170:	ff 75 18             	pushl  0x18(%ebp)
  801173:	ff d7                	call   *%edi
  801175:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801178:	83 eb 01             	sub    $0x1,%ebx
  80117b:	85 db                	test   %ebx,%ebx
  80117d:	7f ed                	jg     80116c <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80117f:	83 ec 08             	sub    $0x8,%esp
  801182:	56                   	push   %esi
  801183:	83 ec 04             	sub    $0x4,%esp
  801186:	ff 75 e4             	pushl  -0x1c(%ebp)
  801189:	ff 75 e0             	pushl  -0x20(%ebp)
  80118c:	ff 75 dc             	pushl  -0x24(%ebp)
  80118f:	ff 75 d8             	pushl  -0x28(%ebp)
  801192:	e8 19 0b 00 00       	call   801cb0 <__umoddi3>
  801197:	83 c4 14             	add    $0x14,%esp
  80119a:	0f be 80 33 1f 80 00 	movsbl 0x801f33(%eax),%eax
  8011a1:	50                   	push   %eax
  8011a2:	ff d7                	call   *%edi
}
  8011a4:	83 c4 10             	add    $0x10,%esp
  8011a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011aa:	5b                   	pop    %ebx
  8011ab:	5e                   	pop    %esi
  8011ac:	5f                   	pop    %edi
  8011ad:	5d                   	pop    %ebp
  8011ae:	c3                   	ret    
  8011af:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8011b2:	eb c4                	jmp    801178 <printnum+0x73>

008011b4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011b4:	55                   	push   %ebp
  8011b5:	89 e5                	mov    %esp,%ebp
  8011b7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011ba:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011be:	8b 10                	mov    (%eax),%edx
  8011c0:	3b 50 04             	cmp    0x4(%eax),%edx
  8011c3:	73 0a                	jae    8011cf <sprintputch+0x1b>
		*b->buf++ = ch;
  8011c5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011c8:	89 08                	mov    %ecx,(%eax)
  8011ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8011cd:	88 02                	mov    %al,(%edx)
}
  8011cf:	5d                   	pop    %ebp
  8011d0:	c3                   	ret    

008011d1 <printfmt>:
{
  8011d1:	55                   	push   %ebp
  8011d2:	89 e5                	mov    %esp,%ebp
  8011d4:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8011d7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011da:	50                   	push   %eax
  8011db:	ff 75 10             	pushl  0x10(%ebp)
  8011de:	ff 75 0c             	pushl  0xc(%ebp)
  8011e1:	ff 75 08             	pushl  0x8(%ebp)
  8011e4:	e8 05 00 00 00       	call   8011ee <vprintfmt>
}
  8011e9:	83 c4 10             	add    $0x10,%esp
  8011ec:	c9                   	leave  
  8011ed:	c3                   	ret    

008011ee <vprintfmt>:
{
  8011ee:	55                   	push   %ebp
  8011ef:	89 e5                	mov    %esp,%ebp
  8011f1:	57                   	push   %edi
  8011f2:	56                   	push   %esi
  8011f3:	53                   	push   %ebx
  8011f4:	83 ec 2c             	sub    $0x2c,%esp
  8011f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8011fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011fd:	8b 7d 10             	mov    0x10(%ebp),%edi
  801200:	e9 c1 03 00 00       	jmp    8015c6 <vprintfmt+0x3d8>
		padc = ' ';
  801205:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  801209:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  801210:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  801217:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80121e:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801223:	8d 47 01             	lea    0x1(%edi),%eax
  801226:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801229:	0f b6 17             	movzbl (%edi),%edx
  80122c:	8d 42 dd             	lea    -0x23(%edx),%eax
  80122f:	3c 55                	cmp    $0x55,%al
  801231:	0f 87 12 04 00 00    	ja     801649 <vprintfmt+0x45b>
  801237:	0f b6 c0             	movzbl %al,%eax
  80123a:	ff 24 85 80 20 80 00 	jmp    *0x802080(,%eax,4)
  801241:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801244:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  801248:	eb d9                	jmp    801223 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80124a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80124d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801251:	eb d0                	jmp    801223 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801253:	0f b6 d2             	movzbl %dl,%edx
  801256:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801259:	b8 00 00 00 00       	mov    $0x0,%eax
  80125e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801261:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801264:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801268:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80126b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80126e:	83 f9 09             	cmp    $0x9,%ecx
  801271:	77 55                	ja     8012c8 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  801273:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801276:	eb e9                	jmp    801261 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  801278:	8b 45 14             	mov    0x14(%ebp),%eax
  80127b:	8b 00                	mov    (%eax),%eax
  80127d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801280:	8b 45 14             	mov    0x14(%ebp),%eax
  801283:	8d 40 04             	lea    0x4(%eax),%eax
  801286:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801289:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80128c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801290:	79 91                	jns    801223 <vprintfmt+0x35>
				width = precision, precision = -1;
  801292:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801295:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801298:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80129f:	eb 82                	jmp    801223 <vprintfmt+0x35>
  8012a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012a4:	85 c0                	test   %eax,%eax
  8012a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ab:	0f 49 d0             	cmovns %eax,%edx
  8012ae:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8012b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012b4:	e9 6a ff ff ff       	jmp    801223 <vprintfmt+0x35>
  8012b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8012bc:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012c3:	e9 5b ff ff ff       	jmp    801223 <vprintfmt+0x35>
  8012c8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012cb:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012ce:	eb bc                	jmp    80128c <vprintfmt+0x9e>
			lflag++;
  8012d0:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8012d6:	e9 48 ff ff ff       	jmp    801223 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8012db:	8b 45 14             	mov    0x14(%ebp),%eax
  8012de:	8d 78 04             	lea    0x4(%eax),%edi
  8012e1:	83 ec 08             	sub    $0x8,%esp
  8012e4:	53                   	push   %ebx
  8012e5:	ff 30                	pushl  (%eax)
  8012e7:	ff d6                	call   *%esi
			break;
  8012e9:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8012ec:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8012ef:	e9 cf 02 00 00       	jmp    8015c3 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8012f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8012f7:	8d 78 04             	lea    0x4(%eax),%edi
  8012fa:	8b 00                	mov    (%eax),%eax
  8012fc:	99                   	cltd   
  8012fd:	31 d0                	xor    %edx,%eax
  8012ff:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801301:	83 f8 0f             	cmp    $0xf,%eax
  801304:	7f 23                	jg     801329 <vprintfmt+0x13b>
  801306:	8b 14 85 e0 21 80 00 	mov    0x8021e0(,%eax,4),%edx
  80130d:	85 d2                	test   %edx,%edx
  80130f:	74 18                	je     801329 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  801311:	52                   	push   %edx
  801312:	68 c9 1e 80 00       	push   $0x801ec9
  801317:	53                   	push   %ebx
  801318:	56                   	push   %esi
  801319:	e8 b3 fe ff ff       	call   8011d1 <printfmt>
  80131e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801321:	89 7d 14             	mov    %edi,0x14(%ebp)
  801324:	e9 9a 02 00 00       	jmp    8015c3 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  801329:	50                   	push   %eax
  80132a:	68 4b 1f 80 00       	push   $0x801f4b
  80132f:	53                   	push   %ebx
  801330:	56                   	push   %esi
  801331:	e8 9b fe ff ff       	call   8011d1 <printfmt>
  801336:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801339:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80133c:	e9 82 02 00 00       	jmp    8015c3 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  801341:	8b 45 14             	mov    0x14(%ebp),%eax
  801344:	83 c0 04             	add    $0x4,%eax
  801347:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80134a:	8b 45 14             	mov    0x14(%ebp),%eax
  80134d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80134f:	85 ff                	test   %edi,%edi
  801351:	b8 44 1f 80 00       	mov    $0x801f44,%eax
  801356:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801359:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80135d:	0f 8e bd 00 00 00    	jle    801420 <vprintfmt+0x232>
  801363:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801367:	75 0e                	jne    801377 <vprintfmt+0x189>
  801369:	89 75 08             	mov    %esi,0x8(%ebp)
  80136c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80136f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801372:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801375:	eb 6d                	jmp    8013e4 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  801377:	83 ec 08             	sub    $0x8,%esp
  80137a:	ff 75 d0             	pushl  -0x30(%ebp)
  80137d:	57                   	push   %edi
  80137e:	e8 6e 03 00 00       	call   8016f1 <strnlen>
  801383:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801386:	29 c1                	sub    %eax,%ecx
  801388:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80138b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80138e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801392:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801395:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801398:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80139a:	eb 0f                	jmp    8013ab <vprintfmt+0x1bd>
					putch(padc, putdat);
  80139c:	83 ec 08             	sub    $0x8,%esp
  80139f:	53                   	push   %ebx
  8013a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8013a3:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8013a5:	83 ef 01             	sub    $0x1,%edi
  8013a8:	83 c4 10             	add    $0x10,%esp
  8013ab:	85 ff                	test   %edi,%edi
  8013ad:	7f ed                	jg     80139c <vprintfmt+0x1ae>
  8013af:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013b2:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8013b5:	85 c9                	test   %ecx,%ecx
  8013b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8013bc:	0f 49 c1             	cmovns %ecx,%eax
  8013bf:	29 c1                	sub    %eax,%ecx
  8013c1:	89 75 08             	mov    %esi,0x8(%ebp)
  8013c4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8013c7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8013ca:	89 cb                	mov    %ecx,%ebx
  8013cc:	eb 16                	jmp    8013e4 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8013ce:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013d2:	75 31                	jne    801405 <vprintfmt+0x217>
					putch(ch, putdat);
  8013d4:	83 ec 08             	sub    $0x8,%esp
  8013d7:	ff 75 0c             	pushl  0xc(%ebp)
  8013da:	50                   	push   %eax
  8013db:	ff 55 08             	call   *0x8(%ebp)
  8013de:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013e1:	83 eb 01             	sub    $0x1,%ebx
  8013e4:	83 c7 01             	add    $0x1,%edi
  8013e7:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8013eb:	0f be c2             	movsbl %dl,%eax
  8013ee:	85 c0                	test   %eax,%eax
  8013f0:	74 59                	je     80144b <vprintfmt+0x25d>
  8013f2:	85 f6                	test   %esi,%esi
  8013f4:	78 d8                	js     8013ce <vprintfmt+0x1e0>
  8013f6:	83 ee 01             	sub    $0x1,%esi
  8013f9:	79 d3                	jns    8013ce <vprintfmt+0x1e0>
  8013fb:	89 df                	mov    %ebx,%edi
  8013fd:	8b 75 08             	mov    0x8(%ebp),%esi
  801400:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801403:	eb 37                	jmp    80143c <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  801405:	0f be d2             	movsbl %dl,%edx
  801408:	83 ea 20             	sub    $0x20,%edx
  80140b:	83 fa 5e             	cmp    $0x5e,%edx
  80140e:	76 c4                	jbe    8013d4 <vprintfmt+0x1e6>
					putch('?', putdat);
  801410:	83 ec 08             	sub    $0x8,%esp
  801413:	ff 75 0c             	pushl  0xc(%ebp)
  801416:	6a 3f                	push   $0x3f
  801418:	ff 55 08             	call   *0x8(%ebp)
  80141b:	83 c4 10             	add    $0x10,%esp
  80141e:	eb c1                	jmp    8013e1 <vprintfmt+0x1f3>
  801420:	89 75 08             	mov    %esi,0x8(%ebp)
  801423:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801426:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801429:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80142c:	eb b6                	jmp    8013e4 <vprintfmt+0x1f6>
				putch(' ', putdat);
  80142e:	83 ec 08             	sub    $0x8,%esp
  801431:	53                   	push   %ebx
  801432:	6a 20                	push   $0x20
  801434:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801436:	83 ef 01             	sub    $0x1,%edi
  801439:	83 c4 10             	add    $0x10,%esp
  80143c:	85 ff                	test   %edi,%edi
  80143e:	7f ee                	jg     80142e <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  801440:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801443:	89 45 14             	mov    %eax,0x14(%ebp)
  801446:	e9 78 01 00 00       	jmp    8015c3 <vprintfmt+0x3d5>
  80144b:	89 df                	mov    %ebx,%edi
  80144d:	8b 75 08             	mov    0x8(%ebp),%esi
  801450:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801453:	eb e7                	jmp    80143c <vprintfmt+0x24e>
	if (lflag >= 2)
  801455:	83 f9 01             	cmp    $0x1,%ecx
  801458:	7e 3f                	jle    801499 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  80145a:	8b 45 14             	mov    0x14(%ebp),%eax
  80145d:	8b 50 04             	mov    0x4(%eax),%edx
  801460:	8b 00                	mov    (%eax),%eax
  801462:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801465:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801468:	8b 45 14             	mov    0x14(%ebp),%eax
  80146b:	8d 40 08             	lea    0x8(%eax),%eax
  80146e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801471:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801475:	79 5c                	jns    8014d3 <vprintfmt+0x2e5>
				putch('-', putdat);
  801477:	83 ec 08             	sub    $0x8,%esp
  80147a:	53                   	push   %ebx
  80147b:	6a 2d                	push   $0x2d
  80147d:	ff d6                	call   *%esi
				num = -(long long) num;
  80147f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801482:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801485:	f7 da                	neg    %edx
  801487:	83 d1 00             	adc    $0x0,%ecx
  80148a:	f7 d9                	neg    %ecx
  80148c:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80148f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801494:	e9 10 01 00 00       	jmp    8015a9 <vprintfmt+0x3bb>
	else if (lflag)
  801499:	85 c9                	test   %ecx,%ecx
  80149b:	75 1b                	jne    8014b8 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  80149d:	8b 45 14             	mov    0x14(%ebp),%eax
  8014a0:	8b 00                	mov    (%eax),%eax
  8014a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014a5:	89 c1                	mov    %eax,%ecx
  8014a7:	c1 f9 1f             	sar    $0x1f,%ecx
  8014aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b0:	8d 40 04             	lea    0x4(%eax),%eax
  8014b3:	89 45 14             	mov    %eax,0x14(%ebp)
  8014b6:	eb b9                	jmp    801471 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8014b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8014bb:	8b 00                	mov    (%eax),%eax
  8014bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014c0:	89 c1                	mov    %eax,%ecx
  8014c2:	c1 f9 1f             	sar    $0x1f,%ecx
  8014c5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8014cb:	8d 40 04             	lea    0x4(%eax),%eax
  8014ce:	89 45 14             	mov    %eax,0x14(%ebp)
  8014d1:	eb 9e                	jmp    801471 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8014d3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014d6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8014d9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014de:	e9 c6 00 00 00       	jmp    8015a9 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8014e3:	83 f9 01             	cmp    $0x1,%ecx
  8014e6:	7e 18                	jle    801500 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8014e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8014eb:	8b 10                	mov    (%eax),%edx
  8014ed:	8b 48 04             	mov    0x4(%eax),%ecx
  8014f0:	8d 40 08             	lea    0x8(%eax),%eax
  8014f3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014f6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014fb:	e9 a9 00 00 00       	jmp    8015a9 <vprintfmt+0x3bb>
	else if (lflag)
  801500:	85 c9                	test   %ecx,%ecx
  801502:	75 1a                	jne    80151e <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  801504:	8b 45 14             	mov    0x14(%ebp),%eax
  801507:	8b 10                	mov    (%eax),%edx
  801509:	b9 00 00 00 00       	mov    $0x0,%ecx
  80150e:	8d 40 04             	lea    0x4(%eax),%eax
  801511:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801514:	b8 0a 00 00 00       	mov    $0xa,%eax
  801519:	e9 8b 00 00 00       	jmp    8015a9 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80151e:	8b 45 14             	mov    0x14(%ebp),%eax
  801521:	8b 10                	mov    (%eax),%edx
  801523:	b9 00 00 00 00       	mov    $0x0,%ecx
  801528:	8d 40 04             	lea    0x4(%eax),%eax
  80152b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80152e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801533:	eb 74                	jmp    8015a9 <vprintfmt+0x3bb>
	if (lflag >= 2)
  801535:	83 f9 01             	cmp    $0x1,%ecx
  801538:	7e 15                	jle    80154f <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  80153a:	8b 45 14             	mov    0x14(%ebp),%eax
  80153d:	8b 10                	mov    (%eax),%edx
  80153f:	8b 48 04             	mov    0x4(%eax),%ecx
  801542:	8d 40 08             	lea    0x8(%eax),%eax
  801545:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801548:	b8 08 00 00 00       	mov    $0x8,%eax
  80154d:	eb 5a                	jmp    8015a9 <vprintfmt+0x3bb>
	else if (lflag)
  80154f:	85 c9                	test   %ecx,%ecx
  801551:	75 17                	jne    80156a <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  801553:	8b 45 14             	mov    0x14(%ebp),%eax
  801556:	8b 10                	mov    (%eax),%edx
  801558:	b9 00 00 00 00       	mov    $0x0,%ecx
  80155d:	8d 40 04             	lea    0x4(%eax),%eax
  801560:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801563:	b8 08 00 00 00       	mov    $0x8,%eax
  801568:	eb 3f                	jmp    8015a9 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80156a:	8b 45 14             	mov    0x14(%ebp),%eax
  80156d:	8b 10                	mov    (%eax),%edx
  80156f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801574:	8d 40 04             	lea    0x4(%eax),%eax
  801577:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80157a:	b8 08 00 00 00       	mov    $0x8,%eax
  80157f:	eb 28                	jmp    8015a9 <vprintfmt+0x3bb>
			putch('0', putdat);
  801581:	83 ec 08             	sub    $0x8,%esp
  801584:	53                   	push   %ebx
  801585:	6a 30                	push   $0x30
  801587:	ff d6                	call   *%esi
			putch('x', putdat);
  801589:	83 c4 08             	add    $0x8,%esp
  80158c:	53                   	push   %ebx
  80158d:	6a 78                	push   $0x78
  80158f:	ff d6                	call   *%esi
			num = (unsigned long long)
  801591:	8b 45 14             	mov    0x14(%ebp),%eax
  801594:	8b 10                	mov    (%eax),%edx
  801596:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80159b:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80159e:	8d 40 04             	lea    0x4(%eax),%eax
  8015a1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015a4:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8015a9:	83 ec 0c             	sub    $0xc,%esp
  8015ac:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015b0:	57                   	push   %edi
  8015b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8015b4:	50                   	push   %eax
  8015b5:	51                   	push   %ecx
  8015b6:	52                   	push   %edx
  8015b7:	89 da                	mov    %ebx,%edx
  8015b9:	89 f0                	mov    %esi,%eax
  8015bb:	e8 45 fb ff ff       	call   801105 <printnum>
			break;
  8015c0:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8015c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015c6:	83 c7 01             	add    $0x1,%edi
  8015c9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015cd:	83 f8 25             	cmp    $0x25,%eax
  8015d0:	0f 84 2f fc ff ff    	je     801205 <vprintfmt+0x17>
			if (ch == '\0')
  8015d6:	85 c0                	test   %eax,%eax
  8015d8:	0f 84 8b 00 00 00    	je     801669 <vprintfmt+0x47b>
			putch(ch, putdat);
  8015de:	83 ec 08             	sub    $0x8,%esp
  8015e1:	53                   	push   %ebx
  8015e2:	50                   	push   %eax
  8015e3:	ff d6                	call   *%esi
  8015e5:	83 c4 10             	add    $0x10,%esp
  8015e8:	eb dc                	jmp    8015c6 <vprintfmt+0x3d8>
	if (lflag >= 2)
  8015ea:	83 f9 01             	cmp    $0x1,%ecx
  8015ed:	7e 15                	jle    801604 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8015ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8015f2:	8b 10                	mov    (%eax),%edx
  8015f4:	8b 48 04             	mov    0x4(%eax),%ecx
  8015f7:	8d 40 08             	lea    0x8(%eax),%eax
  8015fa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015fd:	b8 10 00 00 00       	mov    $0x10,%eax
  801602:	eb a5                	jmp    8015a9 <vprintfmt+0x3bb>
	else if (lflag)
  801604:	85 c9                	test   %ecx,%ecx
  801606:	75 17                	jne    80161f <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  801608:	8b 45 14             	mov    0x14(%ebp),%eax
  80160b:	8b 10                	mov    (%eax),%edx
  80160d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801612:	8d 40 04             	lea    0x4(%eax),%eax
  801615:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801618:	b8 10 00 00 00       	mov    $0x10,%eax
  80161d:	eb 8a                	jmp    8015a9 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80161f:	8b 45 14             	mov    0x14(%ebp),%eax
  801622:	8b 10                	mov    (%eax),%edx
  801624:	b9 00 00 00 00       	mov    $0x0,%ecx
  801629:	8d 40 04             	lea    0x4(%eax),%eax
  80162c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80162f:	b8 10 00 00 00       	mov    $0x10,%eax
  801634:	e9 70 ff ff ff       	jmp    8015a9 <vprintfmt+0x3bb>
			putch(ch, putdat);
  801639:	83 ec 08             	sub    $0x8,%esp
  80163c:	53                   	push   %ebx
  80163d:	6a 25                	push   $0x25
  80163f:	ff d6                	call   *%esi
			break;
  801641:	83 c4 10             	add    $0x10,%esp
  801644:	e9 7a ff ff ff       	jmp    8015c3 <vprintfmt+0x3d5>
			putch('%', putdat);
  801649:	83 ec 08             	sub    $0x8,%esp
  80164c:	53                   	push   %ebx
  80164d:	6a 25                	push   $0x25
  80164f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801651:	83 c4 10             	add    $0x10,%esp
  801654:	89 f8                	mov    %edi,%eax
  801656:	eb 03                	jmp    80165b <vprintfmt+0x46d>
  801658:	83 e8 01             	sub    $0x1,%eax
  80165b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80165f:	75 f7                	jne    801658 <vprintfmt+0x46a>
  801661:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801664:	e9 5a ff ff ff       	jmp    8015c3 <vprintfmt+0x3d5>
}
  801669:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80166c:	5b                   	pop    %ebx
  80166d:	5e                   	pop    %esi
  80166e:	5f                   	pop    %edi
  80166f:	5d                   	pop    %ebp
  801670:	c3                   	ret    

00801671 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801671:	55                   	push   %ebp
  801672:	89 e5                	mov    %esp,%ebp
  801674:	83 ec 18             	sub    $0x18,%esp
  801677:	8b 45 08             	mov    0x8(%ebp),%eax
  80167a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80167d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801680:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801684:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801687:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80168e:	85 c0                	test   %eax,%eax
  801690:	74 26                	je     8016b8 <vsnprintf+0x47>
  801692:	85 d2                	test   %edx,%edx
  801694:	7e 22                	jle    8016b8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801696:	ff 75 14             	pushl  0x14(%ebp)
  801699:	ff 75 10             	pushl  0x10(%ebp)
  80169c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80169f:	50                   	push   %eax
  8016a0:	68 b4 11 80 00       	push   $0x8011b4
  8016a5:	e8 44 fb ff ff       	call   8011ee <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016ad:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b3:	83 c4 10             	add    $0x10,%esp
}
  8016b6:	c9                   	leave  
  8016b7:	c3                   	ret    
		return -E_INVAL;
  8016b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016bd:	eb f7                	jmp    8016b6 <vsnprintf+0x45>

008016bf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016bf:	55                   	push   %ebp
  8016c0:	89 e5                	mov    %esp,%ebp
  8016c2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016c5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016c8:	50                   	push   %eax
  8016c9:	ff 75 10             	pushl  0x10(%ebp)
  8016cc:	ff 75 0c             	pushl  0xc(%ebp)
  8016cf:	ff 75 08             	pushl  0x8(%ebp)
  8016d2:	e8 9a ff ff ff       	call   801671 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016d7:	c9                   	leave  
  8016d8:	c3                   	ret    

008016d9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016d9:	55                   	push   %ebp
  8016da:	89 e5                	mov    %esp,%ebp
  8016dc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016df:	b8 00 00 00 00       	mov    $0x0,%eax
  8016e4:	eb 03                	jmp    8016e9 <strlen+0x10>
		n++;
  8016e6:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8016e9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016ed:	75 f7                	jne    8016e6 <strlen+0xd>
	return n;
}
  8016ef:	5d                   	pop    %ebp
  8016f0:	c3                   	ret    

008016f1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016f1:	55                   	push   %ebp
  8016f2:	89 e5                	mov    %esp,%ebp
  8016f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016f7:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8016ff:	eb 03                	jmp    801704 <strnlen+0x13>
		n++;
  801701:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801704:	39 d0                	cmp    %edx,%eax
  801706:	74 06                	je     80170e <strnlen+0x1d>
  801708:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80170c:	75 f3                	jne    801701 <strnlen+0x10>
	return n;
}
  80170e:	5d                   	pop    %ebp
  80170f:	c3                   	ret    

00801710 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801710:	55                   	push   %ebp
  801711:	89 e5                	mov    %esp,%ebp
  801713:	53                   	push   %ebx
  801714:	8b 45 08             	mov    0x8(%ebp),%eax
  801717:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80171a:	89 c2                	mov    %eax,%edx
  80171c:	83 c1 01             	add    $0x1,%ecx
  80171f:	83 c2 01             	add    $0x1,%edx
  801722:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801726:	88 5a ff             	mov    %bl,-0x1(%edx)
  801729:	84 db                	test   %bl,%bl
  80172b:	75 ef                	jne    80171c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80172d:	5b                   	pop    %ebx
  80172e:	5d                   	pop    %ebp
  80172f:	c3                   	ret    

00801730 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801730:	55                   	push   %ebp
  801731:	89 e5                	mov    %esp,%ebp
  801733:	53                   	push   %ebx
  801734:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801737:	53                   	push   %ebx
  801738:	e8 9c ff ff ff       	call   8016d9 <strlen>
  80173d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801740:	ff 75 0c             	pushl  0xc(%ebp)
  801743:	01 d8                	add    %ebx,%eax
  801745:	50                   	push   %eax
  801746:	e8 c5 ff ff ff       	call   801710 <strcpy>
	return dst;
}
  80174b:	89 d8                	mov    %ebx,%eax
  80174d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801750:	c9                   	leave  
  801751:	c3                   	ret    

00801752 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801752:	55                   	push   %ebp
  801753:	89 e5                	mov    %esp,%ebp
  801755:	56                   	push   %esi
  801756:	53                   	push   %ebx
  801757:	8b 75 08             	mov    0x8(%ebp),%esi
  80175a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80175d:	89 f3                	mov    %esi,%ebx
  80175f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801762:	89 f2                	mov    %esi,%edx
  801764:	eb 0f                	jmp    801775 <strncpy+0x23>
		*dst++ = *src;
  801766:	83 c2 01             	add    $0x1,%edx
  801769:	0f b6 01             	movzbl (%ecx),%eax
  80176c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80176f:	80 39 01             	cmpb   $0x1,(%ecx)
  801772:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  801775:	39 da                	cmp    %ebx,%edx
  801777:	75 ed                	jne    801766 <strncpy+0x14>
	}
	return ret;
}
  801779:	89 f0                	mov    %esi,%eax
  80177b:	5b                   	pop    %ebx
  80177c:	5e                   	pop    %esi
  80177d:	5d                   	pop    %ebp
  80177e:	c3                   	ret    

0080177f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80177f:	55                   	push   %ebp
  801780:	89 e5                	mov    %esp,%ebp
  801782:	56                   	push   %esi
  801783:	53                   	push   %ebx
  801784:	8b 75 08             	mov    0x8(%ebp),%esi
  801787:	8b 55 0c             	mov    0xc(%ebp),%edx
  80178a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80178d:	89 f0                	mov    %esi,%eax
  80178f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801793:	85 c9                	test   %ecx,%ecx
  801795:	75 0b                	jne    8017a2 <strlcpy+0x23>
  801797:	eb 17                	jmp    8017b0 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801799:	83 c2 01             	add    $0x1,%edx
  80179c:	83 c0 01             	add    $0x1,%eax
  80179f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8017a2:	39 d8                	cmp    %ebx,%eax
  8017a4:	74 07                	je     8017ad <strlcpy+0x2e>
  8017a6:	0f b6 0a             	movzbl (%edx),%ecx
  8017a9:	84 c9                	test   %cl,%cl
  8017ab:	75 ec                	jne    801799 <strlcpy+0x1a>
		*dst = '\0';
  8017ad:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017b0:	29 f0                	sub    %esi,%eax
}
  8017b2:	5b                   	pop    %ebx
  8017b3:	5e                   	pop    %esi
  8017b4:	5d                   	pop    %ebp
  8017b5:	c3                   	ret    

008017b6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017b6:	55                   	push   %ebp
  8017b7:	89 e5                	mov    %esp,%ebp
  8017b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017bf:	eb 06                	jmp    8017c7 <strcmp+0x11>
		p++, q++;
  8017c1:	83 c1 01             	add    $0x1,%ecx
  8017c4:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8017c7:	0f b6 01             	movzbl (%ecx),%eax
  8017ca:	84 c0                	test   %al,%al
  8017cc:	74 04                	je     8017d2 <strcmp+0x1c>
  8017ce:	3a 02                	cmp    (%edx),%al
  8017d0:	74 ef                	je     8017c1 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017d2:	0f b6 c0             	movzbl %al,%eax
  8017d5:	0f b6 12             	movzbl (%edx),%edx
  8017d8:	29 d0                	sub    %edx,%eax
}
  8017da:	5d                   	pop    %ebp
  8017db:	c3                   	ret    

008017dc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017dc:	55                   	push   %ebp
  8017dd:	89 e5                	mov    %esp,%ebp
  8017df:	53                   	push   %ebx
  8017e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017e6:	89 c3                	mov    %eax,%ebx
  8017e8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017eb:	eb 06                	jmp    8017f3 <strncmp+0x17>
		n--, p++, q++;
  8017ed:	83 c0 01             	add    $0x1,%eax
  8017f0:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8017f3:	39 d8                	cmp    %ebx,%eax
  8017f5:	74 16                	je     80180d <strncmp+0x31>
  8017f7:	0f b6 08             	movzbl (%eax),%ecx
  8017fa:	84 c9                	test   %cl,%cl
  8017fc:	74 04                	je     801802 <strncmp+0x26>
  8017fe:	3a 0a                	cmp    (%edx),%cl
  801800:	74 eb                	je     8017ed <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801802:	0f b6 00             	movzbl (%eax),%eax
  801805:	0f b6 12             	movzbl (%edx),%edx
  801808:	29 d0                	sub    %edx,%eax
}
  80180a:	5b                   	pop    %ebx
  80180b:	5d                   	pop    %ebp
  80180c:	c3                   	ret    
		return 0;
  80180d:	b8 00 00 00 00       	mov    $0x0,%eax
  801812:	eb f6                	jmp    80180a <strncmp+0x2e>

00801814 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801814:	55                   	push   %ebp
  801815:	89 e5                	mov    %esp,%ebp
  801817:	8b 45 08             	mov    0x8(%ebp),%eax
  80181a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80181e:	0f b6 10             	movzbl (%eax),%edx
  801821:	84 d2                	test   %dl,%dl
  801823:	74 09                	je     80182e <strchr+0x1a>
		if (*s == c)
  801825:	38 ca                	cmp    %cl,%dl
  801827:	74 0a                	je     801833 <strchr+0x1f>
	for (; *s; s++)
  801829:	83 c0 01             	add    $0x1,%eax
  80182c:	eb f0                	jmp    80181e <strchr+0xa>
			return (char *) s;
	return 0;
  80182e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801833:	5d                   	pop    %ebp
  801834:	c3                   	ret    

00801835 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801835:	55                   	push   %ebp
  801836:	89 e5                	mov    %esp,%ebp
  801838:	8b 45 08             	mov    0x8(%ebp),%eax
  80183b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80183f:	eb 03                	jmp    801844 <strfind+0xf>
  801841:	83 c0 01             	add    $0x1,%eax
  801844:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801847:	38 ca                	cmp    %cl,%dl
  801849:	74 04                	je     80184f <strfind+0x1a>
  80184b:	84 d2                	test   %dl,%dl
  80184d:	75 f2                	jne    801841 <strfind+0xc>
			break;
	return (char *) s;
}
  80184f:	5d                   	pop    %ebp
  801850:	c3                   	ret    

00801851 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801851:	55                   	push   %ebp
  801852:	89 e5                	mov    %esp,%ebp
  801854:	57                   	push   %edi
  801855:	56                   	push   %esi
  801856:	53                   	push   %ebx
  801857:	8b 7d 08             	mov    0x8(%ebp),%edi
  80185a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80185d:	85 c9                	test   %ecx,%ecx
  80185f:	74 13                	je     801874 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801861:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801867:	75 05                	jne    80186e <memset+0x1d>
  801869:	f6 c1 03             	test   $0x3,%cl
  80186c:	74 0d                	je     80187b <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80186e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801871:	fc                   	cld    
  801872:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801874:	89 f8                	mov    %edi,%eax
  801876:	5b                   	pop    %ebx
  801877:	5e                   	pop    %esi
  801878:	5f                   	pop    %edi
  801879:	5d                   	pop    %ebp
  80187a:	c3                   	ret    
		c &= 0xFF;
  80187b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80187f:	89 d3                	mov    %edx,%ebx
  801881:	c1 e3 08             	shl    $0x8,%ebx
  801884:	89 d0                	mov    %edx,%eax
  801886:	c1 e0 18             	shl    $0x18,%eax
  801889:	89 d6                	mov    %edx,%esi
  80188b:	c1 e6 10             	shl    $0x10,%esi
  80188e:	09 f0                	or     %esi,%eax
  801890:	09 c2                	or     %eax,%edx
  801892:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  801894:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801897:	89 d0                	mov    %edx,%eax
  801899:	fc                   	cld    
  80189a:	f3 ab                	rep stos %eax,%es:(%edi)
  80189c:	eb d6                	jmp    801874 <memset+0x23>

0080189e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80189e:	55                   	push   %ebp
  80189f:	89 e5                	mov    %esp,%ebp
  8018a1:	57                   	push   %edi
  8018a2:	56                   	push   %esi
  8018a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018a9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018ac:	39 c6                	cmp    %eax,%esi
  8018ae:	73 35                	jae    8018e5 <memmove+0x47>
  8018b0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018b3:	39 c2                	cmp    %eax,%edx
  8018b5:	76 2e                	jbe    8018e5 <memmove+0x47>
		s += n;
		d += n;
  8018b7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018ba:	89 d6                	mov    %edx,%esi
  8018bc:	09 fe                	or     %edi,%esi
  8018be:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018c4:	74 0c                	je     8018d2 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018c6:	83 ef 01             	sub    $0x1,%edi
  8018c9:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8018cc:	fd                   	std    
  8018cd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018cf:	fc                   	cld    
  8018d0:	eb 21                	jmp    8018f3 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018d2:	f6 c1 03             	test   $0x3,%cl
  8018d5:	75 ef                	jne    8018c6 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8018d7:	83 ef 04             	sub    $0x4,%edi
  8018da:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018dd:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8018e0:	fd                   	std    
  8018e1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018e3:	eb ea                	jmp    8018cf <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018e5:	89 f2                	mov    %esi,%edx
  8018e7:	09 c2                	or     %eax,%edx
  8018e9:	f6 c2 03             	test   $0x3,%dl
  8018ec:	74 09                	je     8018f7 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018ee:	89 c7                	mov    %eax,%edi
  8018f0:	fc                   	cld    
  8018f1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018f3:	5e                   	pop    %esi
  8018f4:	5f                   	pop    %edi
  8018f5:	5d                   	pop    %ebp
  8018f6:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018f7:	f6 c1 03             	test   $0x3,%cl
  8018fa:	75 f2                	jne    8018ee <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018fc:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8018ff:	89 c7                	mov    %eax,%edi
  801901:	fc                   	cld    
  801902:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801904:	eb ed                	jmp    8018f3 <memmove+0x55>

00801906 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801906:	55                   	push   %ebp
  801907:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801909:	ff 75 10             	pushl  0x10(%ebp)
  80190c:	ff 75 0c             	pushl  0xc(%ebp)
  80190f:	ff 75 08             	pushl  0x8(%ebp)
  801912:	e8 87 ff ff ff       	call   80189e <memmove>
}
  801917:	c9                   	leave  
  801918:	c3                   	ret    

00801919 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801919:	55                   	push   %ebp
  80191a:	89 e5                	mov    %esp,%ebp
  80191c:	56                   	push   %esi
  80191d:	53                   	push   %ebx
  80191e:	8b 45 08             	mov    0x8(%ebp),%eax
  801921:	8b 55 0c             	mov    0xc(%ebp),%edx
  801924:	89 c6                	mov    %eax,%esi
  801926:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801929:	39 f0                	cmp    %esi,%eax
  80192b:	74 1c                	je     801949 <memcmp+0x30>
		if (*s1 != *s2)
  80192d:	0f b6 08             	movzbl (%eax),%ecx
  801930:	0f b6 1a             	movzbl (%edx),%ebx
  801933:	38 d9                	cmp    %bl,%cl
  801935:	75 08                	jne    80193f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801937:	83 c0 01             	add    $0x1,%eax
  80193a:	83 c2 01             	add    $0x1,%edx
  80193d:	eb ea                	jmp    801929 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  80193f:	0f b6 c1             	movzbl %cl,%eax
  801942:	0f b6 db             	movzbl %bl,%ebx
  801945:	29 d8                	sub    %ebx,%eax
  801947:	eb 05                	jmp    80194e <memcmp+0x35>
	}

	return 0;
  801949:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80194e:	5b                   	pop    %ebx
  80194f:	5e                   	pop    %esi
  801950:	5d                   	pop    %ebp
  801951:	c3                   	ret    

00801952 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801952:	55                   	push   %ebp
  801953:	89 e5                	mov    %esp,%ebp
  801955:	8b 45 08             	mov    0x8(%ebp),%eax
  801958:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80195b:	89 c2                	mov    %eax,%edx
  80195d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801960:	39 d0                	cmp    %edx,%eax
  801962:	73 09                	jae    80196d <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  801964:	38 08                	cmp    %cl,(%eax)
  801966:	74 05                	je     80196d <memfind+0x1b>
	for (; s < ends; s++)
  801968:	83 c0 01             	add    $0x1,%eax
  80196b:	eb f3                	jmp    801960 <memfind+0xe>
			break;
	return (void *) s;
}
  80196d:	5d                   	pop    %ebp
  80196e:	c3                   	ret    

0080196f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80196f:	55                   	push   %ebp
  801970:	89 e5                	mov    %esp,%ebp
  801972:	57                   	push   %edi
  801973:	56                   	push   %esi
  801974:	53                   	push   %ebx
  801975:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801978:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80197b:	eb 03                	jmp    801980 <strtol+0x11>
		s++;
  80197d:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801980:	0f b6 01             	movzbl (%ecx),%eax
  801983:	3c 20                	cmp    $0x20,%al
  801985:	74 f6                	je     80197d <strtol+0xe>
  801987:	3c 09                	cmp    $0x9,%al
  801989:	74 f2                	je     80197d <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  80198b:	3c 2b                	cmp    $0x2b,%al
  80198d:	74 2e                	je     8019bd <strtol+0x4e>
	int neg = 0;
  80198f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801994:	3c 2d                	cmp    $0x2d,%al
  801996:	74 2f                	je     8019c7 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801998:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80199e:	75 05                	jne    8019a5 <strtol+0x36>
  8019a0:	80 39 30             	cmpb   $0x30,(%ecx)
  8019a3:	74 2c                	je     8019d1 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019a5:	85 db                	test   %ebx,%ebx
  8019a7:	75 0a                	jne    8019b3 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019a9:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  8019ae:	80 39 30             	cmpb   $0x30,(%ecx)
  8019b1:	74 28                	je     8019db <strtol+0x6c>
		base = 10;
  8019b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b8:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8019bb:	eb 50                	jmp    801a0d <strtol+0x9e>
		s++;
  8019bd:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8019c0:	bf 00 00 00 00       	mov    $0x0,%edi
  8019c5:	eb d1                	jmp    801998 <strtol+0x29>
		s++, neg = 1;
  8019c7:	83 c1 01             	add    $0x1,%ecx
  8019ca:	bf 01 00 00 00       	mov    $0x1,%edi
  8019cf:	eb c7                	jmp    801998 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019d1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019d5:	74 0e                	je     8019e5 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8019d7:	85 db                	test   %ebx,%ebx
  8019d9:	75 d8                	jne    8019b3 <strtol+0x44>
		s++, base = 8;
  8019db:	83 c1 01             	add    $0x1,%ecx
  8019de:	bb 08 00 00 00       	mov    $0x8,%ebx
  8019e3:	eb ce                	jmp    8019b3 <strtol+0x44>
		s += 2, base = 16;
  8019e5:	83 c1 02             	add    $0x2,%ecx
  8019e8:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019ed:	eb c4                	jmp    8019b3 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  8019ef:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019f2:	89 f3                	mov    %esi,%ebx
  8019f4:	80 fb 19             	cmp    $0x19,%bl
  8019f7:	77 29                	ja     801a22 <strtol+0xb3>
			dig = *s - 'a' + 10;
  8019f9:	0f be d2             	movsbl %dl,%edx
  8019fc:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019ff:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a02:	7d 30                	jge    801a34 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801a04:	83 c1 01             	add    $0x1,%ecx
  801a07:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a0b:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801a0d:	0f b6 11             	movzbl (%ecx),%edx
  801a10:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a13:	89 f3                	mov    %esi,%ebx
  801a15:	80 fb 09             	cmp    $0x9,%bl
  801a18:	77 d5                	ja     8019ef <strtol+0x80>
			dig = *s - '0';
  801a1a:	0f be d2             	movsbl %dl,%edx
  801a1d:	83 ea 30             	sub    $0x30,%edx
  801a20:	eb dd                	jmp    8019ff <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  801a22:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a25:	89 f3                	mov    %esi,%ebx
  801a27:	80 fb 19             	cmp    $0x19,%bl
  801a2a:	77 08                	ja     801a34 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801a2c:	0f be d2             	movsbl %dl,%edx
  801a2f:	83 ea 37             	sub    $0x37,%edx
  801a32:	eb cb                	jmp    8019ff <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  801a34:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a38:	74 05                	je     801a3f <strtol+0xd0>
		*endptr = (char *) s;
  801a3a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a3d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a3f:	89 c2                	mov    %eax,%edx
  801a41:	f7 da                	neg    %edx
  801a43:	85 ff                	test   %edi,%edi
  801a45:	0f 45 c2             	cmovne %edx,%eax
}
  801a48:	5b                   	pop    %ebx
  801a49:	5e                   	pop    %esi
  801a4a:	5f                   	pop    %edi
  801a4b:	5d                   	pop    %ebp
  801a4c:	c3                   	ret    

00801a4d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a4d:	55                   	push   %ebp
  801a4e:	89 e5                	mov    %esp,%ebp
  801a50:	56                   	push   %esi
  801a51:	53                   	push   %ebx
  801a52:	8b 75 08             	mov    0x8(%ebp),%esi
  801a55:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a58:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        //	panic("ipc_recv not implemented");
        int r;
       	if(pg!=NULL){
  801a5b:	85 c0                	test   %eax,%eax
  801a5d:	74 3b                	je     801a9a <ipc_recv+0x4d>
	  r = sys_ipc_recv(pg);
  801a5f:	83 ec 0c             	sub    $0xc,%esp
  801a62:	50                   	push   %eax
  801a63:	e8 b2 e8 ff ff       	call   80031a <sys_ipc_recv>
  801a68:	83 c4 10             	add    $0x10,%esp
	}else
	  r = sys_ipc_recv((void *)UTOP);
	if(r<0){
  801a6b:	85 c0                	test   %eax,%eax
  801a6d:	78 3d                	js     801aac <ipc_recv+0x5f>
	if(perm_store!=NULL){
		*perm_store = 0;
            }
        	return r;
           }else{
	     if(from_env_store!=NULL)
  801a6f:	85 f6                	test   %esi,%esi
  801a71:	74 0a                	je     801a7d <ipc_recv+0x30>
		     *from_env_store = thisenv->env_ipc_from;
  801a73:	a1 04 40 80 00       	mov    0x804004,%eax
  801a78:	8b 40 74             	mov    0x74(%eax),%eax
  801a7b:	89 06                	mov    %eax,(%esi)
	     if(perm_store != NULL)
  801a7d:	85 db                	test   %ebx,%ebx
  801a7f:	74 0a                	je     801a8b <ipc_recv+0x3e>
		     *perm_store = thisenv->env_ipc_perm;
  801a81:	a1 04 40 80 00       	mov    0x804004,%eax
  801a86:	8b 40 78             	mov    0x78(%eax),%eax
  801a89:	89 03                	mov    %eax,(%ebx)
	     return thisenv->env_ipc_value;
  801a8b:	a1 04 40 80 00       	mov    0x804004,%eax
  801a90:	8b 40 70             	mov    0x70(%eax),%eax
	   }

}
  801a93:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a96:	5b                   	pop    %ebx
  801a97:	5e                   	pop    %esi
  801a98:	5d                   	pop    %ebp
  801a99:	c3                   	ret    
	  r = sys_ipc_recv((void *)UTOP);
  801a9a:	83 ec 0c             	sub    $0xc,%esp
  801a9d:	68 00 00 c0 ee       	push   $0xeec00000
  801aa2:	e8 73 e8 ff ff       	call   80031a <sys_ipc_recv>
  801aa7:	83 c4 10             	add    $0x10,%esp
  801aaa:	eb bf                	jmp    801a6b <ipc_recv+0x1e>
	if(from_env_store!=NULL){
  801aac:	85 f6                	test   %esi,%esi
  801aae:	74 06                	je     801ab6 <ipc_recv+0x69>
	  *from_env_store = 0;
  801ab0:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(perm_store!=NULL){
  801ab6:	85 db                	test   %ebx,%ebx
  801ab8:	74 d9                	je     801a93 <ipc_recv+0x46>
		*perm_store = 0;
  801aba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ac0:	eb d1                	jmp    801a93 <ipc_recv+0x46>

00801ac2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ac2:	55                   	push   %ebp
  801ac3:	89 e5                	mov    %esp,%ebp
  801ac5:	57                   	push   %edi
  801ac6:	56                   	push   %esi
  801ac7:	53                   	push   %ebx
  801ac8:	83 ec 0c             	sub    $0xc,%esp
  801acb:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ace:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ad1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if(pg==NULL) pg = (void *)UTOP;
  801ad4:	85 db                	test   %ebx,%ebx
  801ad6:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801adb:	0f 44 d8             	cmove  %eax,%ebx
	while((r=sys_ipc_try_send(to_env,val,pg,perm))<0){
  801ade:	ff 75 14             	pushl  0x14(%ebp)
  801ae1:	53                   	push   %ebx
  801ae2:	56                   	push   %esi
  801ae3:	57                   	push   %edi
  801ae4:	e8 0e e8 ff ff       	call   8002f7 <sys_ipc_try_send>
  801ae9:	83 c4 10             	add    $0x10,%esp
  801aec:	85 c0                	test   %eax,%eax
  801aee:	79 20                	jns    801b10 <ipc_send+0x4e>
	    if(r!=-E_IPC_NOT_RECV){
  801af0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801af3:	75 07                	jne    801afc <ipc_send+0x3a>
		    panic("ipc_send:send message failed\n");
	    }
	    sys_yield();
  801af5:	e8 51 e6 ff ff       	call   80014b <sys_yield>
  801afa:	eb e2                	jmp    801ade <ipc_send+0x1c>
		    panic("ipc_send:send message failed\n");
  801afc:	83 ec 04             	sub    $0x4,%esp
  801aff:	68 40 22 80 00       	push   $0x802240
  801b04:	6a 43                	push   $0x43
  801b06:	68 5e 22 80 00       	push   $0x80225e
  801b0b:	e8 06 f5 ff ff       	call   801016 <_panic>
	}

}
  801b10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b13:	5b                   	pop    %ebx
  801b14:	5e                   	pop    %esi
  801b15:	5f                   	pop    %edi
  801b16:	5d                   	pop    %ebp
  801b17:	c3                   	ret    

00801b18 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b18:	55                   	push   %ebp
  801b19:	89 e5                	mov    %esp,%ebp
  801b1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b1e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b23:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b26:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b2c:	8b 52 50             	mov    0x50(%edx),%edx
  801b2f:	39 ca                	cmp    %ecx,%edx
  801b31:	74 11                	je     801b44 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801b33:	83 c0 01             	add    $0x1,%eax
  801b36:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b3b:	75 e6                	jne    801b23 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801b3d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b42:	eb 0b                	jmp    801b4f <ipc_find_env+0x37>
			return envs[i].env_id;
  801b44:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b47:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b4c:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b4f:	5d                   	pop    %ebp
  801b50:	c3                   	ret    

00801b51 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b51:	55                   	push   %ebp
  801b52:	89 e5                	mov    %esp,%ebp
  801b54:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b57:	89 d0                	mov    %edx,%eax
  801b59:	c1 e8 16             	shr    $0x16,%eax
  801b5c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b63:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801b68:	f6 c1 01             	test   $0x1,%cl
  801b6b:	74 1d                	je     801b8a <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801b6d:	c1 ea 0c             	shr    $0xc,%edx
  801b70:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b77:	f6 c2 01             	test   $0x1,%dl
  801b7a:	74 0e                	je     801b8a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b7c:	c1 ea 0c             	shr    $0xc,%edx
  801b7f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b86:	ef 
  801b87:	0f b7 c0             	movzwl %ax,%eax
}
  801b8a:	5d                   	pop    %ebp
  801b8b:	c3                   	ret    
  801b8c:	66 90                	xchg   %ax,%ax
  801b8e:	66 90                	xchg   %ax,%ax

00801b90 <__udivdi3>:
  801b90:	55                   	push   %ebp
  801b91:	57                   	push   %edi
  801b92:	56                   	push   %esi
  801b93:	53                   	push   %ebx
  801b94:	83 ec 1c             	sub    $0x1c,%esp
  801b97:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801b9b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801b9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ba3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801ba7:	85 d2                	test   %edx,%edx
  801ba9:	75 35                	jne    801be0 <__udivdi3+0x50>
  801bab:	39 f3                	cmp    %esi,%ebx
  801bad:	0f 87 bd 00 00 00    	ja     801c70 <__udivdi3+0xe0>
  801bb3:	85 db                	test   %ebx,%ebx
  801bb5:	89 d9                	mov    %ebx,%ecx
  801bb7:	75 0b                	jne    801bc4 <__udivdi3+0x34>
  801bb9:	b8 01 00 00 00       	mov    $0x1,%eax
  801bbe:	31 d2                	xor    %edx,%edx
  801bc0:	f7 f3                	div    %ebx
  801bc2:	89 c1                	mov    %eax,%ecx
  801bc4:	31 d2                	xor    %edx,%edx
  801bc6:	89 f0                	mov    %esi,%eax
  801bc8:	f7 f1                	div    %ecx
  801bca:	89 c6                	mov    %eax,%esi
  801bcc:	89 e8                	mov    %ebp,%eax
  801bce:	89 f7                	mov    %esi,%edi
  801bd0:	f7 f1                	div    %ecx
  801bd2:	89 fa                	mov    %edi,%edx
  801bd4:	83 c4 1c             	add    $0x1c,%esp
  801bd7:	5b                   	pop    %ebx
  801bd8:	5e                   	pop    %esi
  801bd9:	5f                   	pop    %edi
  801bda:	5d                   	pop    %ebp
  801bdb:	c3                   	ret    
  801bdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801be0:	39 f2                	cmp    %esi,%edx
  801be2:	77 7c                	ja     801c60 <__udivdi3+0xd0>
  801be4:	0f bd fa             	bsr    %edx,%edi
  801be7:	83 f7 1f             	xor    $0x1f,%edi
  801bea:	0f 84 98 00 00 00    	je     801c88 <__udivdi3+0xf8>
  801bf0:	89 f9                	mov    %edi,%ecx
  801bf2:	b8 20 00 00 00       	mov    $0x20,%eax
  801bf7:	29 f8                	sub    %edi,%eax
  801bf9:	d3 e2                	shl    %cl,%edx
  801bfb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801bff:	89 c1                	mov    %eax,%ecx
  801c01:	89 da                	mov    %ebx,%edx
  801c03:	d3 ea                	shr    %cl,%edx
  801c05:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801c09:	09 d1                	or     %edx,%ecx
  801c0b:	89 f2                	mov    %esi,%edx
  801c0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c11:	89 f9                	mov    %edi,%ecx
  801c13:	d3 e3                	shl    %cl,%ebx
  801c15:	89 c1                	mov    %eax,%ecx
  801c17:	d3 ea                	shr    %cl,%edx
  801c19:	89 f9                	mov    %edi,%ecx
  801c1b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c1f:	d3 e6                	shl    %cl,%esi
  801c21:	89 eb                	mov    %ebp,%ebx
  801c23:	89 c1                	mov    %eax,%ecx
  801c25:	d3 eb                	shr    %cl,%ebx
  801c27:	09 de                	or     %ebx,%esi
  801c29:	89 f0                	mov    %esi,%eax
  801c2b:	f7 74 24 08          	divl   0x8(%esp)
  801c2f:	89 d6                	mov    %edx,%esi
  801c31:	89 c3                	mov    %eax,%ebx
  801c33:	f7 64 24 0c          	mull   0xc(%esp)
  801c37:	39 d6                	cmp    %edx,%esi
  801c39:	72 0c                	jb     801c47 <__udivdi3+0xb7>
  801c3b:	89 f9                	mov    %edi,%ecx
  801c3d:	d3 e5                	shl    %cl,%ebp
  801c3f:	39 c5                	cmp    %eax,%ebp
  801c41:	73 5d                	jae    801ca0 <__udivdi3+0x110>
  801c43:	39 d6                	cmp    %edx,%esi
  801c45:	75 59                	jne    801ca0 <__udivdi3+0x110>
  801c47:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801c4a:	31 ff                	xor    %edi,%edi
  801c4c:	89 fa                	mov    %edi,%edx
  801c4e:	83 c4 1c             	add    $0x1c,%esp
  801c51:	5b                   	pop    %ebx
  801c52:	5e                   	pop    %esi
  801c53:	5f                   	pop    %edi
  801c54:	5d                   	pop    %ebp
  801c55:	c3                   	ret    
  801c56:	8d 76 00             	lea    0x0(%esi),%esi
  801c59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801c60:	31 ff                	xor    %edi,%edi
  801c62:	31 c0                	xor    %eax,%eax
  801c64:	89 fa                	mov    %edi,%edx
  801c66:	83 c4 1c             	add    $0x1c,%esp
  801c69:	5b                   	pop    %ebx
  801c6a:	5e                   	pop    %esi
  801c6b:	5f                   	pop    %edi
  801c6c:	5d                   	pop    %ebp
  801c6d:	c3                   	ret    
  801c6e:	66 90                	xchg   %ax,%ax
  801c70:	31 ff                	xor    %edi,%edi
  801c72:	89 e8                	mov    %ebp,%eax
  801c74:	89 f2                	mov    %esi,%edx
  801c76:	f7 f3                	div    %ebx
  801c78:	89 fa                	mov    %edi,%edx
  801c7a:	83 c4 1c             	add    $0x1c,%esp
  801c7d:	5b                   	pop    %ebx
  801c7e:	5e                   	pop    %esi
  801c7f:	5f                   	pop    %edi
  801c80:	5d                   	pop    %ebp
  801c81:	c3                   	ret    
  801c82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c88:	39 f2                	cmp    %esi,%edx
  801c8a:	72 06                	jb     801c92 <__udivdi3+0x102>
  801c8c:	31 c0                	xor    %eax,%eax
  801c8e:	39 eb                	cmp    %ebp,%ebx
  801c90:	77 d2                	ja     801c64 <__udivdi3+0xd4>
  801c92:	b8 01 00 00 00       	mov    $0x1,%eax
  801c97:	eb cb                	jmp    801c64 <__udivdi3+0xd4>
  801c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ca0:	89 d8                	mov    %ebx,%eax
  801ca2:	31 ff                	xor    %edi,%edi
  801ca4:	eb be                	jmp    801c64 <__udivdi3+0xd4>
  801ca6:	66 90                	xchg   %ax,%ax
  801ca8:	66 90                	xchg   %ax,%ax
  801caa:	66 90                	xchg   %ax,%ax
  801cac:	66 90                	xchg   %ax,%ax
  801cae:	66 90                	xchg   %ax,%ax

00801cb0 <__umoddi3>:
  801cb0:	55                   	push   %ebp
  801cb1:	57                   	push   %edi
  801cb2:	56                   	push   %esi
  801cb3:	53                   	push   %ebx
  801cb4:	83 ec 1c             	sub    $0x1c,%esp
  801cb7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801cbb:	8b 74 24 30          	mov    0x30(%esp),%esi
  801cbf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801cc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cc7:	85 ed                	test   %ebp,%ebp
  801cc9:	89 f0                	mov    %esi,%eax
  801ccb:	89 da                	mov    %ebx,%edx
  801ccd:	75 19                	jne    801ce8 <__umoddi3+0x38>
  801ccf:	39 df                	cmp    %ebx,%edi
  801cd1:	0f 86 b1 00 00 00    	jbe    801d88 <__umoddi3+0xd8>
  801cd7:	f7 f7                	div    %edi
  801cd9:	89 d0                	mov    %edx,%eax
  801cdb:	31 d2                	xor    %edx,%edx
  801cdd:	83 c4 1c             	add    $0x1c,%esp
  801ce0:	5b                   	pop    %ebx
  801ce1:	5e                   	pop    %esi
  801ce2:	5f                   	pop    %edi
  801ce3:	5d                   	pop    %ebp
  801ce4:	c3                   	ret    
  801ce5:	8d 76 00             	lea    0x0(%esi),%esi
  801ce8:	39 dd                	cmp    %ebx,%ebp
  801cea:	77 f1                	ja     801cdd <__umoddi3+0x2d>
  801cec:	0f bd cd             	bsr    %ebp,%ecx
  801cef:	83 f1 1f             	xor    $0x1f,%ecx
  801cf2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801cf6:	0f 84 b4 00 00 00    	je     801db0 <__umoddi3+0x100>
  801cfc:	b8 20 00 00 00       	mov    $0x20,%eax
  801d01:	89 c2                	mov    %eax,%edx
  801d03:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d07:	29 c2                	sub    %eax,%edx
  801d09:	89 c1                	mov    %eax,%ecx
  801d0b:	89 f8                	mov    %edi,%eax
  801d0d:	d3 e5                	shl    %cl,%ebp
  801d0f:	89 d1                	mov    %edx,%ecx
  801d11:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801d15:	d3 e8                	shr    %cl,%eax
  801d17:	09 c5                	or     %eax,%ebp
  801d19:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d1d:	89 c1                	mov    %eax,%ecx
  801d1f:	d3 e7                	shl    %cl,%edi
  801d21:	89 d1                	mov    %edx,%ecx
  801d23:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801d27:	89 df                	mov    %ebx,%edi
  801d29:	d3 ef                	shr    %cl,%edi
  801d2b:	89 c1                	mov    %eax,%ecx
  801d2d:	89 f0                	mov    %esi,%eax
  801d2f:	d3 e3                	shl    %cl,%ebx
  801d31:	89 d1                	mov    %edx,%ecx
  801d33:	89 fa                	mov    %edi,%edx
  801d35:	d3 e8                	shr    %cl,%eax
  801d37:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801d3c:	09 d8                	or     %ebx,%eax
  801d3e:	f7 f5                	div    %ebp
  801d40:	d3 e6                	shl    %cl,%esi
  801d42:	89 d1                	mov    %edx,%ecx
  801d44:	f7 64 24 08          	mull   0x8(%esp)
  801d48:	39 d1                	cmp    %edx,%ecx
  801d4a:	89 c3                	mov    %eax,%ebx
  801d4c:	89 d7                	mov    %edx,%edi
  801d4e:	72 06                	jb     801d56 <__umoddi3+0xa6>
  801d50:	75 0e                	jne    801d60 <__umoddi3+0xb0>
  801d52:	39 c6                	cmp    %eax,%esi
  801d54:	73 0a                	jae    801d60 <__umoddi3+0xb0>
  801d56:	2b 44 24 08          	sub    0x8(%esp),%eax
  801d5a:	19 ea                	sbb    %ebp,%edx
  801d5c:	89 d7                	mov    %edx,%edi
  801d5e:	89 c3                	mov    %eax,%ebx
  801d60:	89 ca                	mov    %ecx,%edx
  801d62:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801d67:	29 de                	sub    %ebx,%esi
  801d69:	19 fa                	sbb    %edi,%edx
  801d6b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  801d6f:	89 d0                	mov    %edx,%eax
  801d71:	d3 e0                	shl    %cl,%eax
  801d73:	89 d9                	mov    %ebx,%ecx
  801d75:	d3 ee                	shr    %cl,%esi
  801d77:	d3 ea                	shr    %cl,%edx
  801d79:	09 f0                	or     %esi,%eax
  801d7b:	83 c4 1c             	add    $0x1c,%esp
  801d7e:	5b                   	pop    %ebx
  801d7f:	5e                   	pop    %esi
  801d80:	5f                   	pop    %edi
  801d81:	5d                   	pop    %ebp
  801d82:	c3                   	ret    
  801d83:	90                   	nop
  801d84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d88:	85 ff                	test   %edi,%edi
  801d8a:	89 f9                	mov    %edi,%ecx
  801d8c:	75 0b                	jne    801d99 <__umoddi3+0xe9>
  801d8e:	b8 01 00 00 00       	mov    $0x1,%eax
  801d93:	31 d2                	xor    %edx,%edx
  801d95:	f7 f7                	div    %edi
  801d97:	89 c1                	mov    %eax,%ecx
  801d99:	89 d8                	mov    %ebx,%eax
  801d9b:	31 d2                	xor    %edx,%edx
  801d9d:	f7 f1                	div    %ecx
  801d9f:	89 f0                	mov    %esi,%eax
  801da1:	f7 f1                	div    %ecx
  801da3:	e9 31 ff ff ff       	jmp    801cd9 <__umoddi3+0x29>
  801da8:	90                   	nop
  801da9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801db0:	39 dd                	cmp    %ebx,%ebp
  801db2:	72 08                	jb     801dbc <__umoddi3+0x10c>
  801db4:	39 f7                	cmp    %esi,%edi
  801db6:	0f 87 21 ff ff ff    	ja     801cdd <__umoddi3+0x2d>
  801dbc:	89 da                	mov    %ebx,%edx
  801dbe:	89 f0                	mov    %esi,%eax
  801dc0:	29 f8                	sub    %edi,%eax
  801dc2:	19 ea                	sbb    %ebp,%edx
  801dc4:	e9 14 ff ff ff       	jmp    801cdd <__umoddi3+0x2d>
