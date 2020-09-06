
obj/user/idle.debug:     file format elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  800039:	c7 05 00 30 80 00 e0 	movl   $0x801de0,0x803000
  800040:	1d 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800043:	e8 ff 00 00 00       	call   800147 <sys_yield>
  800048:	eb f9                	jmp    800043 <umain+0x10>

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800055:	e8 ce 00 00 00       	call   800128 <sys_getenvid>
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x2d>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800077:	83 ec 08             	sub    $0x8,%esp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	e8 b2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800081:	e8 0a 00 00 00       	call   800090 <exit>
}
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800096:	e8 92 04 00 00       	call   80052d <close_all>
	sys_env_destroy(0);
  80009b:	83 ec 0c             	sub    $0xc,%esp
  80009e:	6a 00                	push   $0x0
  8000a0:	e8 42 00 00 00       	call   8000e7 <sys_env_destroy>
}
  8000a5:	83 c4 10             	add    $0x10,%esp
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    

008000aa <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	57                   	push   %edi
  8000ae:	56                   	push   %esi
  8000af:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bb:	89 c3                	mov    %eax,%ebx
  8000bd:	89 c7                	mov    %eax,%edi
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c3:	5b                   	pop    %ebx
  8000c4:	5e                   	pop    %esi
  8000c5:	5f                   	pop    %edi
  8000c6:	5d                   	pop    %ebp
  8000c7:	c3                   	ret    

008000c8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	57                   	push   %edi
  8000cc:	56                   	push   %esi
  8000cd:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d8:	89 d1                	mov    %edx,%ecx
  8000da:	89 d3                	mov    %edx,%ebx
  8000dc:	89 d7                	mov    %edx,%edi
  8000de:	89 d6                	mov    %edx,%esi
  8000e0:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e2:	5b                   	pop    %ebx
  8000e3:	5e                   	pop    %esi
  8000e4:	5f                   	pop    %edi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	57                   	push   %edi
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
  8000ed:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f8:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fd:	89 cb                	mov    %ecx,%ebx
  8000ff:	89 cf                	mov    %ecx,%edi
  800101:	89 ce                	mov    %ecx,%esi
  800103:	cd 30                	int    $0x30
	if(check && ret > 0)
  800105:	85 c0                	test   %eax,%eax
  800107:	7f 08                	jg     800111 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800109:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5e                   	pop    %esi
  80010e:	5f                   	pop    %edi
  80010f:	5d                   	pop    %ebp
  800110:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800111:	83 ec 0c             	sub    $0xc,%esp
  800114:	50                   	push   %eax
  800115:	6a 03                	push   $0x3
  800117:	68 ef 1d 80 00       	push   $0x801def
  80011c:	6a 23                	push   $0x23
  80011e:	68 0c 1e 80 00       	push   $0x801e0c
  800123:	e8 ea 0e 00 00       	call   801012 <_panic>

00800128 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	57                   	push   %edi
  80012c:	56                   	push   %esi
  80012d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80012e:	ba 00 00 00 00       	mov    $0x0,%edx
  800133:	b8 02 00 00 00       	mov    $0x2,%eax
  800138:	89 d1                	mov    %edx,%ecx
  80013a:	89 d3                	mov    %edx,%ebx
  80013c:	89 d7                	mov    %edx,%edi
  80013e:	89 d6                	mov    %edx,%esi
  800140:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <sys_yield>:

void
sys_yield(void)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	57                   	push   %edi
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80014d:	ba 00 00 00 00       	mov    $0x0,%edx
  800152:	b8 0b 00 00 00       	mov    $0xb,%eax
  800157:	89 d1                	mov    %edx,%ecx
  800159:	89 d3                	mov    %edx,%ebx
  80015b:	89 d7                	mov    %edx,%edi
  80015d:	89 d6                	mov    %edx,%esi
  80015f:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800161:	5b                   	pop    %ebx
  800162:	5e                   	pop    %esi
  800163:	5f                   	pop    %edi
  800164:	5d                   	pop    %ebp
  800165:	c3                   	ret    

00800166 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	57                   	push   %edi
  80016a:	56                   	push   %esi
  80016b:	53                   	push   %ebx
  80016c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80016f:	be 00 00 00 00       	mov    $0x0,%esi
  800174:	8b 55 08             	mov    0x8(%ebp),%edx
  800177:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017a:	b8 04 00 00 00       	mov    $0x4,%eax
  80017f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800182:	89 f7                	mov    %esi,%edi
  800184:	cd 30                	int    $0x30
	if(check && ret > 0)
  800186:	85 c0                	test   %eax,%eax
  800188:	7f 08                	jg     800192 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80018a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80018d:	5b                   	pop    %ebx
  80018e:	5e                   	pop    %esi
  80018f:	5f                   	pop    %edi
  800190:	5d                   	pop    %ebp
  800191:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800192:	83 ec 0c             	sub    $0xc,%esp
  800195:	50                   	push   %eax
  800196:	6a 04                	push   $0x4
  800198:	68 ef 1d 80 00       	push   $0x801def
  80019d:	6a 23                	push   $0x23
  80019f:	68 0c 1e 80 00       	push   $0x801e0c
  8001a4:	e8 69 0e 00 00       	call   801012 <_panic>

008001a9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	57                   	push   %edi
  8001ad:	56                   	push   %esi
  8001ae:	53                   	push   %ebx
  8001af:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b8:	b8 05 00 00 00       	mov    $0x5,%eax
  8001bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c6:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001c8:	85 c0                	test   %eax,%eax
  8001ca:	7f 08                	jg     8001d4 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001cf:	5b                   	pop    %ebx
  8001d0:	5e                   	pop    %esi
  8001d1:	5f                   	pop    %edi
  8001d2:	5d                   	pop    %ebp
  8001d3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d4:	83 ec 0c             	sub    $0xc,%esp
  8001d7:	50                   	push   %eax
  8001d8:	6a 05                	push   $0x5
  8001da:	68 ef 1d 80 00       	push   $0x801def
  8001df:	6a 23                	push   $0x23
  8001e1:	68 0c 1e 80 00       	push   $0x801e0c
  8001e6:	e8 27 0e 00 00       	call   801012 <_panic>

008001eb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001eb:	55                   	push   %ebp
  8001ec:	89 e5                	mov    %esp,%ebp
  8001ee:	57                   	push   %edi
  8001ef:	56                   	push   %esi
  8001f0:	53                   	push   %ebx
  8001f1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ff:	b8 06 00 00 00       	mov    $0x6,%eax
  800204:	89 df                	mov    %ebx,%edi
  800206:	89 de                	mov    %ebx,%esi
  800208:	cd 30                	int    $0x30
	if(check && ret > 0)
  80020a:	85 c0                	test   %eax,%eax
  80020c:	7f 08                	jg     800216 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80020e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800211:	5b                   	pop    %ebx
  800212:	5e                   	pop    %esi
  800213:	5f                   	pop    %edi
  800214:	5d                   	pop    %ebp
  800215:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800216:	83 ec 0c             	sub    $0xc,%esp
  800219:	50                   	push   %eax
  80021a:	6a 06                	push   $0x6
  80021c:	68 ef 1d 80 00       	push   $0x801def
  800221:	6a 23                	push   $0x23
  800223:	68 0c 1e 80 00       	push   $0x801e0c
  800228:	e8 e5 0d 00 00       	call   801012 <_panic>

0080022d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	57                   	push   %edi
  800231:	56                   	push   %esi
  800232:	53                   	push   %ebx
  800233:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800236:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023b:	8b 55 08             	mov    0x8(%ebp),%edx
  80023e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800241:	b8 08 00 00 00       	mov    $0x8,%eax
  800246:	89 df                	mov    %ebx,%edi
  800248:	89 de                	mov    %ebx,%esi
  80024a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80024c:	85 c0                	test   %eax,%eax
  80024e:	7f 08                	jg     800258 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800250:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800253:	5b                   	pop    %ebx
  800254:	5e                   	pop    %esi
  800255:	5f                   	pop    %edi
  800256:	5d                   	pop    %ebp
  800257:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800258:	83 ec 0c             	sub    $0xc,%esp
  80025b:	50                   	push   %eax
  80025c:	6a 08                	push   $0x8
  80025e:	68 ef 1d 80 00       	push   $0x801def
  800263:	6a 23                	push   $0x23
  800265:	68 0c 1e 80 00       	push   $0x801e0c
  80026a:	e8 a3 0d 00 00       	call   801012 <_panic>

0080026f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	57                   	push   %edi
  800273:	56                   	push   %esi
  800274:	53                   	push   %ebx
  800275:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800278:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027d:	8b 55 08             	mov    0x8(%ebp),%edx
  800280:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800283:	b8 09 00 00 00       	mov    $0x9,%eax
  800288:	89 df                	mov    %ebx,%edi
  80028a:	89 de                	mov    %ebx,%esi
  80028c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80028e:	85 c0                	test   %eax,%eax
  800290:	7f 08                	jg     80029a <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800292:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800295:	5b                   	pop    %ebx
  800296:	5e                   	pop    %esi
  800297:	5f                   	pop    %edi
  800298:	5d                   	pop    %ebp
  800299:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80029a:	83 ec 0c             	sub    $0xc,%esp
  80029d:	50                   	push   %eax
  80029e:	6a 09                	push   $0x9
  8002a0:	68 ef 1d 80 00       	push   $0x801def
  8002a5:	6a 23                	push   $0x23
  8002a7:	68 0c 1e 80 00       	push   $0x801e0c
  8002ac:	e8 61 0d 00 00       	call   801012 <_panic>

008002b1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	57                   	push   %edi
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002ca:	89 df                	mov    %ebx,%edi
  8002cc:	89 de                	mov    %ebx,%esi
  8002ce:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002d0:	85 c0                	test   %eax,%eax
  8002d2:	7f 08                	jg     8002dc <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d7:	5b                   	pop    %ebx
  8002d8:	5e                   	pop    %esi
  8002d9:	5f                   	pop    %edi
  8002da:	5d                   	pop    %ebp
  8002db:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002dc:	83 ec 0c             	sub    $0xc,%esp
  8002df:	50                   	push   %eax
  8002e0:	6a 0a                	push   $0xa
  8002e2:	68 ef 1d 80 00       	push   $0x801def
  8002e7:	6a 23                	push   $0x23
  8002e9:	68 0c 1e 80 00       	push   $0x801e0c
  8002ee:	e8 1f 0d 00 00       	call   801012 <_panic>

008002f3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	57                   	push   %edi
  8002f7:	56                   	push   %esi
  8002f8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ff:	b8 0c 00 00 00       	mov    $0xc,%eax
  800304:	be 00 00 00 00       	mov    $0x0,%esi
  800309:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80030c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030f:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800311:	5b                   	pop    %ebx
  800312:	5e                   	pop    %esi
  800313:	5f                   	pop    %edi
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    

00800316 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
  800319:	57                   	push   %edi
  80031a:	56                   	push   %esi
  80031b:	53                   	push   %ebx
  80031c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80031f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800324:	8b 55 08             	mov    0x8(%ebp),%edx
  800327:	b8 0d 00 00 00       	mov    $0xd,%eax
  80032c:	89 cb                	mov    %ecx,%ebx
  80032e:	89 cf                	mov    %ecx,%edi
  800330:	89 ce                	mov    %ecx,%esi
  800332:	cd 30                	int    $0x30
	if(check && ret > 0)
  800334:	85 c0                	test   %eax,%eax
  800336:	7f 08                	jg     800340 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800338:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80033b:	5b                   	pop    %ebx
  80033c:	5e                   	pop    %esi
  80033d:	5f                   	pop    %edi
  80033e:	5d                   	pop    %ebp
  80033f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800340:	83 ec 0c             	sub    $0xc,%esp
  800343:	50                   	push   %eax
  800344:	6a 0d                	push   $0xd
  800346:	68 ef 1d 80 00       	push   $0x801def
  80034b:	6a 23                	push   $0x23
  80034d:	68 0c 1e 80 00       	push   $0x801e0c
  800352:	e8 bb 0c 00 00       	call   801012 <_panic>

00800357 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035a:	8b 45 08             	mov    0x8(%ebp),%eax
  80035d:	05 00 00 00 30       	add    $0x30000000,%eax
  800362:	c1 e8 0c             	shr    $0xc,%eax
}
  800365:	5d                   	pop    %ebp
  800366:	c3                   	ret    

00800367 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800367:	55                   	push   %ebp
  800368:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80036a:	8b 45 08             	mov    0x8(%ebp),%eax
  80036d:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800372:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800377:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80037c:	5d                   	pop    %ebp
  80037d:	c3                   	ret    

0080037e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
  800381:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800384:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800389:	89 c2                	mov    %eax,%edx
  80038b:	c1 ea 16             	shr    $0x16,%edx
  80038e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800395:	f6 c2 01             	test   $0x1,%dl
  800398:	74 2a                	je     8003c4 <fd_alloc+0x46>
  80039a:	89 c2                	mov    %eax,%edx
  80039c:	c1 ea 0c             	shr    $0xc,%edx
  80039f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003a6:	f6 c2 01             	test   $0x1,%dl
  8003a9:	74 19                	je     8003c4 <fd_alloc+0x46>
  8003ab:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8003b0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003b5:	75 d2                	jne    800389 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003b7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003bd:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8003c2:	eb 07                	jmp    8003cb <fd_alloc+0x4d>
			*fd_store = fd;
  8003c4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003cb:	5d                   	pop    %ebp
  8003cc:	c3                   	ret    

008003cd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d3:	83 f8 1f             	cmp    $0x1f,%eax
  8003d6:	77 36                	ja     80040e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d8:	c1 e0 0c             	shl    $0xc,%eax
  8003db:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003e0:	89 c2                	mov    %eax,%edx
  8003e2:	c1 ea 16             	shr    $0x16,%edx
  8003e5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003ec:	f6 c2 01             	test   $0x1,%dl
  8003ef:	74 24                	je     800415 <fd_lookup+0x48>
  8003f1:	89 c2                	mov    %eax,%edx
  8003f3:	c1 ea 0c             	shr    $0xc,%edx
  8003f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003fd:	f6 c2 01             	test   $0x1,%dl
  800400:	74 1a                	je     80041c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800402:	8b 55 0c             	mov    0xc(%ebp),%edx
  800405:	89 02                	mov    %eax,(%edx)
	return 0;
  800407:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80040c:	5d                   	pop    %ebp
  80040d:	c3                   	ret    
		return -E_INVAL;
  80040e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800413:	eb f7                	jmp    80040c <fd_lookup+0x3f>
		return -E_INVAL;
  800415:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80041a:	eb f0                	jmp    80040c <fd_lookup+0x3f>
  80041c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800421:	eb e9                	jmp    80040c <fd_lookup+0x3f>

00800423 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800423:	55                   	push   %ebp
  800424:	89 e5                	mov    %esp,%ebp
  800426:	83 ec 08             	sub    $0x8,%esp
  800429:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80042c:	ba 98 1e 80 00       	mov    $0x801e98,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800431:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800436:	39 08                	cmp    %ecx,(%eax)
  800438:	74 33                	je     80046d <dev_lookup+0x4a>
  80043a:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80043d:	8b 02                	mov    (%edx),%eax
  80043f:	85 c0                	test   %eax,%eax
  800441:	75 f3                	jne    800436 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800443:	a1 04 40 80 00       	mov    0x804004,%eax
  800448:	8b 40 48             	mov    0x48(%eax),%eax
  80044b:	83 ec 04             	sub    $0x4,%esp
  80044e:	51                   	push   %ecx
  80044f:	50                   	push   %eax
  800450:	68 1c 1e 80 00       	push   $0x801e1c
  800455:	e8 93 0c 00 00       	call   8010ed <cprintf>
	*dev = 0;
  80045a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80045d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800463:	83 c4 10             	add    $0x10,%esp
  800466:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80046b:	c9                   	leave  
  80046c:	c3                   	ret    
			*dev = devtab[i];
  80046d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800470:	89 01                	mov    %eax,(%ecx)
			return 0;
  800472:	b8 00 00 00 00       	mov    $0x0,%eax
  800477:	eb f2                	jmp    80046b <dev_lookup+0x48>

00800479 <fd_close>:
{
  800479:	55                   	push   %ebp
  80047a:	89 e5                	mov    %esp,%ebp
  80047c:	57                   	push   %edi
  80047d:	56                   	push   %esi
  80047e:	53                   	push   %ebx
  80047f:	83 ec 1c             	sub    $0x1c,%esp
  800482:	8b 75 08             	mov    0x8(%ebp),%esi
  800485:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800488:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80048b:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80048c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800492:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800495:	50                   	push   %eax
  800496:	e8 32 ff ff ff       	call   8003cd <fd_lookup>
  80049b:	89 c3                	mov    %eax,%ebx
  80049d:	83 c4 08             	add    $0x8,%esp
  8004a0:	85 c0                	test   %eax,%eax
  8004a2:	78 05                	js     8004a9 <fd_close+0x30>
	    || fd != fd2)
  8004a4:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8004a7:	74 16                	je     8004bf <fd_close+0x46>
		return (must_exist ? r : 0);
  8004a9:	89 f8                	mov    %edi,%eax
  8004ab:	84 c0                	test   %al,%al
  8004ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b2:	0f 44 d8             	cmove  %eax,%ebx
}
  8004b5:	89 d8                	mov    %ebx,%eax
  8004b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004ba:	5b                   	pop    %ebx
  8004bb:	5e                   	pop    %esi
  8004bc:	5f                   	pop    %edi
  8004bd:	5d                   	pop    %ebp
  8004be:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004bf:	83 ec 08             	sub    $0x8,%esp
  8004c2:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8004c5:	50                   	push   %eax
  8004c6:	ff 36                	pushl  (%esi)
  8004c8:	e8 56 ff ff ff       	call   800423 <dev_lookup>
  8004cd:	89 c3                	mov    %eax,%ebx
  8004cf:	83 c4 10             	add    $0x10,%esp
  8004d2:	85 c0                	test   %eax,%eax
  8004d4:	78 15                	js     8004eb <fd_close+0x72>
		if (dev->dev_close)
  8004d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004d9:	8b 40 10             	mov    0x10(%eax),%eax
  8004dc:	85 c0                	test   %eax,%eax
  8004de:	74 1b                	je     8004fb <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8004e0:	83 ec 0c             	sub    $0xc,%esp
  8004e3:	56                   	push   %esi
  8004e4:	ff d0                	call   *%eax
  8004e6:	89 c3                	mov    %eax,%ebx
  8004e8:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004eb:	83 ec 08             	sub    $0x8,%esp
  8004ee:	56                   	push   %esi
  8004ef:	6a 00                	push   $0x0
  8004f1:	e8 f5 fc ff ff       	call   8001eb <sys_page_unmap>
	return r;
  8004f6:	83 c4 10             	add    $0x10,%esp
  8004f9:	eb ba                	jmp    8004b5 <fd_close+0x3c>
			r = 0;
  8004fb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800500:	eb e9                	jmp    8004eb <fd_close+0x72>

00800502 <close>:

int
close(int fdnum)
{
  800502:	55                   	push   %ebp
  800503:	89 e5                	mov    %esp,%ebp
  800505:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800508:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80050b:	50                   	push   %eax
  80050c:	ff 75 08             	pushl  0x8(%ebp)
  80050f:	e8 b9 fe ff ff       	call   8003cd <fd_lookup>
  800514:	83 c4 08             	add    $0x8,%esp
  800517:	85 c0                	test   %eax,%eax
  800519:	78 10                	js     80052b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80051b:	83 ec 08             	sub    $0x8,%esp
  80051e:	6a 01                	push   $0x1
  800520:	ff 75 f4             	pushl  -0xc(%ebp)
  800523:	e8 51 ff ff ff       	call   800479 <fd_close>
  800528:	83 c4 10             	add    $0x10,%esp
}
  80052b:	c9                   	leave  
  80052c:	c3                   	ret    

0080052d <close_all>:

void
close_all(void)
{
  80052d:	55                   	push   %ebp
  80052e:	89 e5                	mov    %esp,%ebp
  800530:	53                   	push   %ebx
  800531:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800534:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800539:	83 ec 0c             	sub    $0xc,%esp
  80053c:	53                   	push   %ebx
  80053d:	e8 c0 ff ff ff       	call   800502 <close>
	for (i = 0; i < MAXFD; i++)
  800542:	83 c3 01             	add    $0x1,%ebx
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	83 fb 20             	cmp    $0x20,%ebx
  80054b:	75 ec                	jne    800539 <close_all+0xc>
}
  80054d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800550:	c9                   	leave  
  800551:	c3                   	ret    

00800552 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800552:	55                   	push   %ebp
  800553:	89 e5                	mov    %esp,%ebp
  800555:	57                   	push   %edi
  800556:	56                   	push   %esi
  800557:	53                   	push   %ebx
  800558:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80055b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80055e:	50                   	push   %eax
  80055f:	ff 75 08             	pushl  0x8(%ebp)
  800562:	e8 66 fe ff ff       	call   8003cd <fd_lookup>
  800567:	89 c3                	mov    %eax,%ebx
  800569:	83 c4 08             	add    $0x8,%esp
  80056c:	85 c0                	test   %eax,%eax
  80056e:	0f 88 81 00 00 00    	js     8005f5 <dup+0xa3>
		return r;
	close(newfdnum);
  800574:	83 ec 0c             	sub    $0xc,%esp
  800577:	ff 75 0c             	pushl  0xc(%ebp)
  80057a:	e8 83 ff ff ff       	call   800502 <close>

	newfd = INDEX2FD(newfdnum);
  80057f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800582:	c1 e6 0c             	shl    $0xc,%esi
  800585:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80058b:	83 c4 04             	add    $0x4,%esp
  80058e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800591:	e8 d1 fd ff ff       	call   800367 <fd2data>
  800596:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800598:	89 34 24             	mov    %esi,(%esp)
  80059b:	e8 c7 fd ff ff       	call   800367 <fd2data>
  8005a0:	83 c4 10             	add    $0x10,%esp
  8005a3:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005a5:	89 d8                	mov    %ebx,%eax
  8005a7:	c1 e8 16             	shr    $0x16,%eax
  8005aa:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005b1:	a8 01                	test   $0x1,%al
  8005b3:	74 11                	je     8005c6 <dup+0x74>
  8005b5:	89 d8                	mov    %ebx,%eax
  8005b7:	c1 e8 0c             	shr    $0xc,%eax
  8005ba:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005c1:	f6 c2 01             	test   $0x1,%dl
  8005c4:	75 39                	jne    8005ff <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005c6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005c9:	89 d0                	mov    %edx,%eax
  8005cb:	c1 e8 0c             	shr    $0xc,%eax
  8005ce:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005d5:	83 ec 0c             	sub    $0xc,%esp
  8005d8:	25 07 0e 00 00       	and    $0xe07,%eax
  8005dd:	50                   	push   %eax
  8005de:	56                   	push   %esi
  8005df:	6a 00                	push   $0x0
  8005e1:	52                   	push   %edx
  8005e2:	6a 00                	push   $0x0
  8005e4:	e8 c0 fb ff ff       	call   8001a9 <sys_page_map>
  8005e9:	89 c3                	mov    %eax,%ebx
  8005eb:	83 c4 20             	add    $0x20,%esp
  8005ee:	85 c0                	test   %eax,%eax
  8005f0:	78 31                	js     800623 <dup+0xd1>
		goto err;

	return newfdnum;
  8005f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005f5:	89 d8                	mov    %ebx,%eax
  8005f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005fa:	5b                   	pop    %ebx
  8005fb:	5e                   	pop    %esi
  8005fc:	5f                   	pop    %edi
  8005fd:	5d                   	pop    %ebp
  8005fe:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ff:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800606:	83 ec 0c             	sub    $0xc,%esp
  800609:	25 07 0e 00 00       	and    $0xe07,%eax
  80060e:	50                   	push   %eax
  80060f:	57                   	push   %edi
  800610:	6a 00                	push   $0x0
  800612:	53                   	push   %ebx
  800613:	6a 00                	push   $0x0
  800615:	e8 8f fb ff ff       	call   8001a9 <sys_page_map>
  80061a:	89 c3                	mov    %eax,%ebx
  80061c:	83 c4 20             	add    $0x20,%esp
  80061f:	85 c0                	test   %eax,%eax
  800621:	79 a3                	jns    8005c6 <dup+0x74>
	sys_page_unmap(0, newfd);
  800623:	83 ec 08             	sub    $0x8,%esp
  800626:	56                   	push   %esi
  800627:	6a 00                	push   $0x0
  800629:	e8 bd fb ff ff       	call   8001eb <sys_page_unmap>
	sys_page_unmap(0, nva);
  80062e:	83 c4 08             	add    $0x8,%esp
  800631:	57                   	push   %edi
  800632:	6a 00                	push   $0x0
  800634:	e8 b2 fb ff ff       	call   8001eb <sys_page_unmap>
	return r;
  800639:	83 c4 10             	add    $0x10,%esp
  80063c:	eb b7                	jmp    8005f5 <dup+0xa3>

0080063e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80063e:	55                   	push   %ebp
  80063f:	89 e5                	mov    %esp,%ebp
  800641:	53                   	push   %ebx
  800642:	83 ec 14             	sub    $0x14,%esp
  800645:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800648:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80064b:	50                   	push   %eax
  80064c:	53                   	push   %ebx
  80064d:	e8 7b fd ff ff       	call   8003cd <fd_lookup>
  800652:	83 c4 08             	add    $0x8,%esp
  800655:	85 c0                	test   %eax,%eax
  800657:	78 3f                	js     800698 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800659:	83 ec 08             	sub    $0x8,%esp
  80065c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80065f:	50                   	push   %eax
  800660:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800663:	ff 30                	pushl  (%eax)
  800665:	e8 b9 fd ff ff       	call   800423 <dev_lookup>
  80066a:	83 c4 10             	add    $0x10,%esp
  80066d:	85 c0                	test   %eax,%eax
  80066f:	78 27                	js     800698 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800671:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800674:	8b 42 08             	mov    0x8(%edx),%eax
  800677:	83 e0 03             	and    $0x3,%eax
  80067a:	83 f8 01             	cmp    $0x1,%eax
  80067d:	74 1e                	je     80069d <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80067f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800682:	8b 40 08             	mov    0x8(%eax),%eax
  800685:	85 c0                	test   %eax,%eax
  800687:	74 35                	je     8006be <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800689:	83 ec 04             	sub    $0x4,%esp
  80068c:	ff 75 10             	pushl  0x10(%ebp)
  80068f:	ff 75 0c             	pushl  0xc(%ebp)
  800692:	52                   	push   %edx
  800693:	ff d0                	call   *%eax
  800695:	83 c4 10             	add    $0x10,%esp
}
  800698:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80069b:	c9                   	leave  
  80069c:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80069d:	a1 04 40 80 00       	mov    0x804004,%eax
  8006a2:	8b 40 48             	mov    0x48(%eax),%eax
  8006a5:	83 ec 04             	sub    $0x4,%esp
  8006a8:	53                   	push   %ebx
  8006a9:	50                   	push   %eax
  8006aa:	68 5d 1e 80 00       	push   $0x801e5d
  8006af:	e8 39 0a 00 00       	call   8010ed <cprintf>
		return -E_INVAL;
  8006b4:	83 c4 10             	add    $0x10,%esp
  8006b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006bc:	eb da                	jmp    800698 <read+0x5a>
		return -E_NOT_SUPP;
  8006be:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006c3:	eb d3                	jmp    800698 <read+0x5a>

008006c5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c5:	55                   	push   %ebp
  8006c6:	89 e5                	mov    %esp,%ebp
  8006c8:	57                   	push   %edi
  8006c9:	56                   	push   %esi
  8006ca:	53                   	push   %ebx
  8006cb:	83 ec 0c             	sub    $0xc,%esp
  8006ce:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006d1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d9:	39 f3                	cmp    %esi,%ebx
  8006db:	73 25                	jae    800702 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006dd:	83 ec 04             	sub    $0x4,%esp
  8006e0:	89 f0                	mov    %esi,%eax
  8006e2:	29 d8                	sub    %ebx,%eax
  8006e4:	50                   	push   %eax
  8006e5:	89 d8                	mov    %ebx,%eax
  8006e7:	03 45 0c             	add    0xc(%ebp),%eax
  8006ea:	50                   	push   %eax
  8006eb:	57                   	push   %edi
  8006ec:	e8 4d ff ff ff       	call   80063e <read>
		if (m < 0)
  8006f1:	83 c4 10             	add    $0x10,%esp
  8006f4:	85 c0                	test   %eax,%eax
  8006f6:	78 08                	js     800700 <readn+0x3b>
			return m;
		if (m == 0)
  8006f8:	85 c0                	test   %eax,%eax
  8006fa:	74 06                	je     800702 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  8006fc:	01 c3                	add    %eax,%ebx
  8006fe:	eb d9                	jmp    8006d9 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800700:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  800702:	89 d8                	mov    %ebx,%eax
  800704:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800707:	5b                   	pop    %ebx
  800708:	5e                   	pop    %esi
  800709:	5f                   	pop    %edi
  80070a:	5d                   	pop    %ebp
  80070b:	c3                   	ret    

0080070c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80070c:	55                   	push   %ebp
  80070d:	89 e5                	mov    %esp,%ebp
  80070f:	53                   	push   %ebx
  800710:	83 ec 14             	sub    $0x14,%esp
  800713:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800716:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800719:	50                   	push   %eax
  80071a:	53                   	push   %ebx
  80071b:	e8 ad fc ff ff       	call   8003cd <fd_lookup>
  800720:	83 c4 08             	add    $0x8,%esp
  800723:	85 c0                	test   %eax,%eax
  800725:	78 3a                	js     800761 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800727:	83 ec 08             	sub    $0x8,%esp
  80072a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80072d:	50                   	push   %eax
  80072e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800731:	ff 30                	pushl  (%eax)
  800733:	e8 eb fc ff ff       	call   800423 <dev_lookup>
  800738:	83 c4 10             	add    $0x10,%esp
  80073b:	85 c0                	test   %eax,%eax
  80073d:	78 22                	js     800761 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80073f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800742:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800746:	74 1e                	je     800766 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800748:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80074b:	8b 52 0c             	mov    0xc(%edx),%edx
  80074e:	85 d2                	test   %edx,%edx
  800750:	74 35                	je     800787 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800752:	83 ec 04             	sub    $0x4,%esp
  800755:	ff 75 10             	pushl  0x10(%ebp)
  800758:	ff 75 0c             	pushl  0xc(%ebp)
  80075b:	50                   	push   %eax
  80075c:	ff d2                	call   *%edx
  80075e:	83 c4 10             	add    $0x10,%esp
}
  800761:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800764:	c9                   	leave  
  800765:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800766:	a1 04 40 80 00       	mov    0x804004,%eax
  80076b:	8b 40 48             	mov    0x48(%eax),%eax
  80076e:	83 ec 04             	sub    $0x4,%esp
  800771:	53                   	push   %ebx
  800772:	50                   	push   %eax
  800773:	68 79 1e 80 00       	push   $0x801e79
  800778:	e8 70 09 00 00       	call   8010ed <cprintf>
		return -E_INVAL;
  80077d:	83 c4 10             	add    $0x10,%esp
  800780:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800785:	eb da                	jmp    800761 <write+0x55>
		return -E_NOT_SUPP;
  800787:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80078c:	eb d3                	jmp    800761 <write+0x55>

0080078e <seek>:

int
seek(int fdnum, off_t offset)
{
  80078e:	55                   	push   %ebp
  80078f:	89 e5                	mov    %esp,%ebp
  800791:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800794:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800797:	50                   	push   %eax
  800798:	ff 75 08             	pushl  0x8(%ebp)
  80079b:	e8 2d fc ff ff       	call   8003cd <fd_lookup>
  8007a0:	83 c4 08             	add    $0x8,%esp
  8007a3:	85 c0                	test   %eax,%eax
  8007a5:	78 0e                	js     8007b5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007ad:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b5:	c9                   	leave  
  8007b6:	c3                   	ret    

008007b7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	53                   	push   %ebx
  8007bb:	83 ec 14             	sub    $0x14,%esp
  8007be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007c4:	50                   	push   %eax
  8007c5:	53                   	push   %ebx
  8007c6:	e8 02 fc ff ff       	call   8003cd <fd_lookup>
  8007cb:	83 c4 08             	add    $0x8,%esp
  8007ce:	85 c0                	test   %eax,%eax
  8007d0:	78 37                	js     800809 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d2:	83 ec 08             	sub    $0x8,%esp
  8007d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d8:	50                   	push   %eax
  8007d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007dc:	ff 30                	pushl  (%eax)
  8007de:	e8 40 fc ff ff       	call   800423 <dev_lookup>
  8007e3:	83 c4 10             	add    $0x10,%esp
  8007e6:	85 c0                	test   %eax,%eax
  8007e8:	78 1f                	js     800809 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ed:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007f1:	74 1b                	je     80080e <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007f6:	8b 52 18             	mov    0x18(%edx),%edx
  8007f9:	85 d2                	test   %edx,%edx
  8007fb:	74 32                	je     80082f <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007fd:	83 ec 08             	sub    $0x8,%esp
  800800:	ff 75 0c             	pushl  0xc(%ebp)
  800803:	50                   	push   %eax
  800804:	ff d2                	call   *%edx
  800806:	83 c4 10             	add    $0x10,%esp
}
  800809:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80080c:	c9                   	leave  
  80080d:	c3                   	ret    
			thisenv->env_id, fdnum);
  80080e:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800813:	8b 40 48             	mov    0x48(%eax),%eax
  800816:	83 ec 04             	sub    $0x4,%esp
  800819:	53                   	push   %ebx
  80081a:	50                   	push   %eax
  80081b:	68 3c 1e 80 00       	push   $0x801e3c
  800820:	e8 c8 08 00 00       	call   8010ed <cprintf>
		return -E_INVAL;
  800825:	83 c4 10             	add    $0x10,%esp
  800828:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80082d:	eb da                	jmp    800809 <ftruncate+0x52>
		return -E_NOT_SUPP;
  80082f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800834:	eb d3                	jmp    800809 <ftruncate+0x52>

00800836 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	53                   	push   %ebx
  80083a:	83 ec 14             	sub    $0x14,%esp
  80083d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800840:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800843:	50                   	push   %eax
  800844:	ff 75 08             	pushl  0x8(%ebp)
  800847:	e8 81 fb ff ff       	call   8003cd <fd_lookup>
  80084c:	83 c4 08             	add    $0x8,%esp
  80084f:	85 c0                	test   %eax,%eax
  800851:	78 4b                	js     80089e <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800853:	83 ec 08             	sub    $0x8,%esp
  800856:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800859:	50                   	push   %eax
  80085a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80085d:	ff 30                	pushl  (%eax)
  80085f:	e8 bf fb ff ff       	call   800423 <dev_lookup>
  800864:	83 c4 10             	add    $0x10,%esp
  800867:	85 c0                	test   %eax,%eax
  800869:	78 33                	js     80089e <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  80086b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80086e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800872:	74 2f                	je     8008a3 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800874:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800877:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80087e:	00 00 00 
	stat->st_isdir = 0;
  800881:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800888:	00 00 00 
	stat->st_dev = dev;
  80088b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800891:	83 ec 08             	sub    $0x8,%esp
  800894:	53                   	push   %ebx
  800895:	ff 75 f0             	pushl  -0x10(%ebp)
  800898:	ff 50 14             	call   *0x14(%eax)
  80089b:	83 c4 10             	add    $0x10,%esp
}
  80089e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008a1:	c9                   	leave  
  8008a2:	c3                   	ret    
		return -E_NOT_SUPP;
  8008a3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008a8:	eb f4                	jmp    80089e <fstat+0x68>

008008aa <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	56                   	push   %esi
  8008ae:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008af:	83 ec 08             	sub    $0x8,%esp
  8008b2:	6a 00                	push   $0x0
  8008b4:	ff 75 08             	pushl  0x8(%ebp)
  8008b7:	e8 e7 01 00 00       	call   800aa3 <open>
  8008bc:	89 c3                	mov    %eax,%ebx
  8008be:	83 c4 10             	add    $0x10,%esp
  8008c1:	85 c0                	test   %eax,%eax
  8008c3:	78 1b                	js     8008e0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008c5:	83 ec 08             	sub    $0x8,%esp
  8008c8:	ff 75 0c             	pushl  0xc(%ebp)
  8008cb:	50                   	push   %eax
  8008cc:	e8 65 ff ff ff       	call   800836 <fstat>
  8008d1:	89 c6                	mov    %eax,%esi
	close(fd);
  8008d3:	89 1c 24             	mov    %ebx,(%esp)
  8008d6:	e8 27 fc ff ff       	call   800502 <close>
	return r;
  8008db:	83 c4 10             	add    $0x10,%esp
  8008de:	89 f3                	mov    %esi,%ebx
}
  8008e0:	89 d8                	mov    %ebx,%eax
  8008e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008e5:	5b                   	pop    %ebx
  8008e6:	5e                   	pop    %esi
  8008e7:	5d                   	pop    %ebp
  8008e8:	c3                   	ret    

008008e9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	56                   	push   %esi
  8008ed:	53                   	push   %ebx
  8008ee:	89 c6                	mov    %eax,%esi
  8008f0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008f2:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008f9:	74 27                	je     800922 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008fb:	6a 07                	push   $0x7
  8008fd:	68 00 50 80 00       	push   $0x805000
  800902:	56                   	push   %esi
  800903:	ff 35 00 40 80 00    	pushl  0x804000
  800909:	e8 b0 11 00 00       	call   801abe <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80090e:	83 c4 0c             	add    $0xc,%esp
  800911:	6a 00                	push   $0x0
  800913:	53                   	push   %ebx
  800914:	6a 00                	push   $0x0
  800916:	e8 2e 11 00 00       	call   801a49 <ipc_recv>
}
  80091b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80091e:	5b                   	pop    %ebx
  80091f:	5e                   	pop    %esi
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800922:	83 ec 0c             	sub    $0xc,%esp
  800925:	6a 01                	push   $0x1
  800927:	e8 e8 11 00 00       	call   801b14 <ipc_find_env>
  80092c:	a3 00 40 80 00       	mov    %eax,0x804000
  800931:	83 c4 10             	add    $0x10,%esp
  800934:	eb c5                	jmp    8008fb <fsipc+0x12>

00800936 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80093c:	8b 45 08             	mov    0x8(%ebp),%eax
  80093f:	8b 40 0c             	mov    0xc(%eax),%eax
  800942:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800947:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80094f:	ba 00 00 00 00       	mov    $0x0,%edx
  800954:	b8 02 00 00 00       	mov    $0x2,%eax
  800959:	e8 8b ff ff ff       	call   8008e9 <fsipc>
}
  80095e:	c9                   	leave  
  80095f:	c3                   	ret    

00800960 <devfile_flush>:
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800966:	8b 45 08             	mov    0x8(%ebp),%eax
  800969:	8b 40 0c             	mov    0xc(%eax),%eax
  80096c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800971:	ba 00 00 00 00       	mov    $0x0,%edx
  800976:	b8 06 00 00 00       	mov    $0x6,%eax
  80097b:	e8 69 ff ff ff       	call   8008e9 <fsipc>
}
  800980:	c9                   	leave  
  800981:	c3                   	ret    

00800982 <devfile_stat>:
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	53                   	push   %ebx
  800986:	83 ec 04             	sub    $0x4,%esp
  800989:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80098c:	8b 45 08             	mov    0x8(%ebp),%eax
  80098f:	8b 40 0c             	mov    0xc(%eax),%eax
  800992:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800997:	ba 00 00 00 00       	mov    $0x0,%edx
  80099c:	b8 05 00 00 00       	mov    $0x5,%eax
  8009a1:	e8 43 ff ff ff       	call   8008e9 <fsipc>
  8009a6:	85 c0                	test   %eax,%eax
  8009a8:	78 2c                	js     8009d6 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009aa:	83 ec 08             	sub    $0x8,%esp
  8009ad:	68 00 50 80 00       	push   $0x805000
  8009b2:	53                   	push   %ebx
  8009b3:	e8 54 0d 00 00       	call   80170c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009b8:	a1 80 50 80 00       	mov    0x805080,%eax
  8009bd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009c3:	a1 84 50 80 00       	mov    0x805084,%eax
  8009c8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009ce:	83 c4 10             	add    $0x10,%esp
  8009d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009d9:	c9                   	leave  
  8009da:	c3                   	ret    

008009db <devfile_write>:
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	83 ec 0c             	sub    $0xc,%esp
  8009e1:	8b 45 10             	mov    0x10(%ebp),%eax
  8009e4:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009e9:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8009ee:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f4:	8b 52 0c             	mov    0xc(%edx),%edx
  8009f7:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8009fd:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf,buf,n);
  800a02:	50                   	push   %eax
  800a03:	ff 75 0c             	pushl  0xc(%ebp)
  800a06:	68 08 50 80 00       	push   $0x805008
  800a0b:	e8 8a 0e 00 00       	call   80189a <memmove>
	if((r = fsipc(FSREQ_WRITE,NULL))<0)
  800a10:	ba 00 00 00 00       	mov    $0x0,%edx
  800a15:	b8 04 00 00 00       	mov    $0x4,%eax
  800a1a:	e8 ca fe ff ff       	call   8008e9 <fsipc>
}
  800a1f:	c9                   	leave  
  800a20:	c3                   	ret    

00800a21 <devfile_read>:
{
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	56                   	push   %esi
  800a25:	53                   	push   %ebx
  800a26:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a29:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2c:	8b 40 0c             	mov    0xc(%eax),%eax
  800a2f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a34:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a3f:	b8 03 00 00 00       	mov    $0x3,%eax
  800a44:	e8 a0 fe ff ff       	call   8008e9 <fsipc>
  800a49:	89 c3                	mov    %eax,%ebx
  800a4b:	85 c0                	test   %eax,%eax
  800a4d:	78 1f                	js     800a6e <devfile_read+0x4d>
	assert(r <= n);
  800a4f:	39 f0                	cmp    %esi,%eax
  800a51:	77 24                	ja     800a77 <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a53:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a58:	7f 33                	jg     800a8d <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a5a:	83 ec 04             	sub    $0x4,%esp
  800a5d:	50                   	push   %eax
  800a5e:	68 00 50 80 00       	push   $0x805000
  800a63:	ff 75 0c             	pushl  0xc(%ebp)
  800a66:	e8 2f 0e 00 00       	call   80189a <memmove>
	return r;
  800a6b:	83 c4 10             	add    $0x10,%esp
}
  800a6e:	89 d8                	mov    %ebx,%eax
  800a70:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a73:	5b                   	pop    %ebx
  800a74:	5e                   	pop    %esi
  800a75:	5d                   	pop    %ebp
  800a76:	c3                   	ret    
	assert(r <= n);
  800a77:	68 a8 1e 80 00       	push   $0x801ea8
  800a7c:	68 af 1e 80 00       	push   $0x801eaf
  800a81:	6a 7c                	push   $0x7c
  800a83:	68 c4 1e 80 00       	push   $0x801ec4
  800a88:	e8 85 05 00 00       	call   801012 <_panic>
	assert(r <= PGSIZE);
  800a8d:	68 cf 1e 80 00       	push   $0x801ecf
  800a92:	68 af 1e 80 00       	push   $0x801eaf
  800a97:	6a 7d                	push   $0x7d
  800a99:	68 c4 1e 80 00       	push   $0x801ec4
  800a9e:	e8 6f 05 00 00       	call   801012 <_panic>

00800aa3 <open>:
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	56                   	push   %esi
  800aa7:	53                   	push   %ebx
  800aa8:	83 ec 1c             	sub    $0x1c,%esp
  800aab:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800aae:	56                   	push   %esi
  800aaf:	e8 21 0c 00 00       	call   8016d5 <strlen>
  800ab4:	83 c4 10             	add    $0x10,%esp
  800ab7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800abc:	7f 6c                	jg     800b2a <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800abe:	83 ec 0c             	sub    $0xc,%esp
  800ac1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ac4:	50                   	push   %eax
  800ac5:	e8 b4 f8 ff ff       	call   80037e <fd_alloc>
  800aca:	89 c3                	mov    %eax,%ebx
  800acc:	83 c4 10             	add    $0x10,%esp
  800acf:	85 c0                	test   %eax,%eax
  800ad1:	78 3c                	js     800b0f <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800ad3:	83 ec 08             	sub    $0x8,%esp
  800ad6:	56                   	push   %esi
  800ad7:	68 00 50 80 00       	push   $0x805000
  800adc:	e8 2b 0c 00 00       	call   80170c <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ae1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae4:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ae9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800aec:	b8 01 00 00 00       	mov    $0x1,%eax
  800af1:	e8 f3 fd ff ff       	call   8008e9 <fsipc>
  800af6:	89 c3                	mov    %eax,%ebx
  800af8:	83 c4 10             	add    $0x10,%esp
  800afb:	85 c0                	test   %eax,%eax
  800afd:	78 19                	js     800b18 <open+0x75>
	return fd2num(fd);
  800aff:	83 ec 0c             	sub    $0xc,%esp
  800b02:	ff 75 f4             	pushl  -0xc(%ebp)
  800b05:	e8 4d f8 ff ff       	call   800357 <fd2num>
  800b0a:	89 c3                	mov    %eax,%ebx
  800b0c:	83 c4 10             	add    $0x10,%esp
}
  800b0f:	89 d8                	mov    %ebx,%eax
  800b11:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b14:	5b                   	pop    %ebx
  800b15:	5e                   	pop    %esi
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    
		fd_close(fd, 0);
  800b18:	83 ec 08             	sub    $0x8,%esp
  800b1b:	6a 00                	push   $0x0
  800b1d:	ff 75 f4             	pushl  -0xc(%ebp)
  800b20:	e8 54 f9 ff ff       	call   800479 <fd_close>
		return r;
  800b25:	83 c4 10             	add    $0x10,%esp
  800b28:	eb e5                	jmp    800b0f <open+0x6c>
		return -E_BAD_PATH;
  800b2a:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b2f:	eb de                	jmp    800b0f <open+0x6c>

00800b31 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b37:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3c:	b8 08 00 00 00       	mov    $0x8,%eax
  800b41:	e8 a3 fd ff ff       	call   8008e9 <fsipc>
}
  800b46:	c9                   	leave  
  800b47:	c3                   	ret    

00800b48 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	56                   	push   %esi
  800b4c:	53                   	push   %ebx
  800b4d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b50:	83 ec 0c             	sub    $0xc,%esp
  800b53:	ff 75 08             	pushl  0x8(%ebp)
  800b56:	e8 0c f8 ff ff       	call   800367 <fd2data>
  800b5b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b5d:	83 c4 08             	add    $0x8,%esp
  800b60:	68 db 1e 80 00       	push   $0x801edb
  800b65:	53                   	push   %ebx
  800b66:	e8 a1 0b 00 00       	call   80170c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b6b:	8b 46 04             	mov    0x4(%esi),%eax
  800b6e:	2b 06                	sub    (%esi),%eax
  800b70:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b76:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b7d:	00 00 00 
	stat->st_dev = &devpipe;
  800b80:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b87:	30 80 00 
	return 0;
}
  800b8a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b92:	5b                   	pop    %ebx
  800b93:	5e                   	pop    %esi
  800b94:	5d                   	pop    %ebp
  800b95:	c3                   	ret    

00800b96 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	53                   	push   %ebx
  800b9a:	83 ec 0c             	sub    $0xc,%esp
  800b9d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800ba0:	53                   	push   %ebx
  800ba1:	6a 00                	push   $0x0
  800ba3:	e8 43 f6 ff ff       	call   8001eb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800ba8:	89 1c 24             	mov    %ebx,(%esp)
  800bab:	e8 b7 f7 ff ff       	call   800367 <fd2data>
  800bb0:	83 c4 08             	add    $0x8,%esp
  800bb3:	50                   	push   %eax
  800bb4:	6a 00                	push   $0x0
  800bb6:	e8 30 f6 ff ff       	call   8001eb <sys_page_unmap>
}
  800bbb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bbe:	c9                   	leave  
  800bbf:	c3                   	ret    

00800bc0 <_pipeisclosed>:
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	57                   	push   %edi
  800bc4:	56                   	push   %esi
  800bc5:	53                   	push   %ebx
  800bc6:	83 ec 1c             	sub    $0x1c,%esp
  800bc9:	89 c7                	mov    %eax,%edi
  800bcb:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800bcd:	a1 04 40 80 00       	mov    0x804004,%eax
  800bd2:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800bd5:	83 ec 0c             	sub    $0xc,%esp
  800bd8:	57                   	push   %edi
  800bd9:	e8 6f 0f 00 00       	call   801b4d <pageref>
  800bde:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800be1:	89 34 24             	mov    %esi,(%esp)
  800be4:	e8 64 0f 00 00       	call   801b4d <pageref>
		nn = thisenv->env_runs;
  800be9:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bef:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bf2:	83 c4 10             	add    $0x10,%esp
  800bf5:	39 cb                	cmp    %ecx,%ebx
  800bf7:	74 1b                	je     800c14 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800bf9:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800bfc:	75 cf                	jne    800bcd <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800bfe:	8b 42 58             	mov    0x58(%edx),%eax
  800c01:	6a 01                	push   $0x1
  800c03:	50                   	push   %eax
  800c04:	53                   	push   %ebx
  800c05:	68 e2 1e 80 00       	push   $0x801ee2
  800c0a:	e8 de 04 00 00       	call   8010ed <cprintf>
  800c0f:	83 c4 10             	add    $0x10,%esp
  800c12:	eb b9                	jmp    800bcd <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c14:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c17:	0f 94 c0             	sete   %al
  800c1a:	0f b6 c0             	movzbl %al,%eax
}
  800c1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c20:	5b                   	pop    %ebx
  800c21:	5e                   	pop    %esi
  800c22:	5f                   	pop    %edi
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    

00800c25 <devpipe_write>:
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	57                   	push   %edi
  800c29:	56                   	push   %esi
  800c2a:	53                   	push   %ebx
  800c2b:	83 ec 28             	sub    $0x28,%esp
  800c2e:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c31:	56                   	push   %esi
  800c32:	e8 30 f7 ff ff       	call   800367 <fd2data>
  800c37:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c39:	83 c4 10             	add    $0x10,%esp
  800c3c:	bf 00 00 00 00       	mov    $0x0,%edi
  800c41:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c44:	74 4f                	je     800c95 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c46:	8b 43 04             	mov    0x4(%ebx),%eax
  800c49:	8b 0b                	mov    (%ebx),%ecx
  800c4b:	8d 51 20             	lea    0x20(%ecx),%edx
  800c4e:	39 d0                	cmp    %edx,%eax
  800c50:	72 14                	jb     800c66 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  800c52:	89 da                	mov    %ebx,%edx
  800c54:	89 f0                	mov    %esi,%eax
  800c56:	e8 65 ff ff ff       	call   800bc0 <_pipeisclosed>
  800c5b:	85 c0                	test   %eax,%eax
  800c5d:	75 3a                	jne    800c99 <devpipe_write+0x74>
			sys_yield();
  800c5f:	e8 e3 f4 ff ff       	call   800147 <sys_yield>
  800c64:	eb e0                	jmp    800c46 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c69:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c6d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c70:	89 c2                	mov    %eax,%edx
  800c72:	c1 fa 1f             	sar    $0x1f,%edx
  800c75:	89 d1                	mov    %edx,%ecx
  800c77:	c1 e9 1b             	shr    $0x1b,%ecx
  800c7a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c7d:	83 e2 1f             	and    $0x1f,%edx
  800c80:	29 ca                	sub    %ecx,%edx
  800c82:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c86:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c8a:	83 c0 01             	add    $0x1,%eax
  800c8d:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800c90:	83 c7 01             	add    $0x1,%edi
  800c93:	eb ac                	jmp    800c41 <devpipe_write+0x1c>
	return i;
  800c95:	89 f8                	mov    %edi,%eax
  800c97:	eb 05                	jmp    800c9e <devpipe_write+0x79>
				return 0;
  800c99:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca1:	5b                   	pop    %ebx
  800ca2:	5e                   	pop    %esi
  800ca3:	5f                   	pop    %edi
  800ca4:	5d                   	pop    %ebp
  800ca5:	c3                   	ret    

00800ca6 <devpipe_read>:
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	57                   	push   %edi
  800caa:	56                   	push   %esi
  800cab:	53                   	push   %ebx
  800cac:	83 ec 18             	sub    $0x18,%esp
  800caf:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800cb2:	57                   	push   %edi
  800cb3:	e8 af f6 ff ff       	call   800367 <fd2data>
  800cb8:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800cba:	83 c4 10             	add    $0x10,%esp
  800cbd:	be 00 00 00 00       	mov    $0x0,%esi
  800cc2:	3b 75 10             	cmp    0x10(%ebp),%esi
  800cc5:	74 47                	je     800d0e <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  800cc7:	8b 03                	mov    (%ebx),%eax
  800cc9:	3b 43 04             	cmp    0x4(%ebx),%eax
  800ccc:	75 22                	jne    800cf0 <devpipe_read+0x4a>
			if (i > 0)
  800cce:	85 f6                	test   %esi,%esi
  800cd0:	75 14                	jne    800ce6 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  800cd2:	89 da                	mov    %ebx,%edx
  800cd4:	89 f8                	mov    %edi,%eax
  800cd6:	e8 e5 fe ff ff       	call   800bc0 <_pipeisclosed>
  800cdb:	85 c0                	test   %eax,%eax
  800cdd:	75 33                	jne    800d12 <devpipe_read+0x6c>
			sys_yield();
  800cdf:	e8 63 f4 ff ff       	call   800147 <sys_yield>
  800ce4:	eb e1                	jmp    800cc7 <devpipe_read+0x21>
				return i;
  800ce6:	89 f0                	mov    %esi,%eax
}
  800ce8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ceb:	5b                   	pop    %ebx
  800cec:	5e                   	pop    %esi
  800ced:	5f                   	pop    %edi
  800cee:	5d                   	pop    %ebp
  800cef:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cf0:	99                   	cltd   
  800cf1:	c1 ea 1b             	shr    $0x1b,%edx
  800cf4:	01 d0                	add    %edx,%eax
  800cf6:	83 e0 1f             	and    $0x1f,%eax
  800cf9:	29 d0                	sub    %edx,%eax
  800cfb:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d03:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d06:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d09:	83 c6 01             	add    $0x1,%esi
  800d0c:	eb b4                	jmp    800cc2 <devpipe_read+0x1c>
	return i;
  800d0e:	89 f0                	mov    %esi,%eax
  800d10:	eb d6                	jmp    800ce8 <devpipe_read+0x42>
				return 0;
  800d12:	b8 00 00 00 00       	mov    $0x0,%eax
  800d17:	eb cf                	jmp    800ce8 <devpipe_read+0x42>

00800d19 <pipe>:
{
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	56                   	push   %esi
  800d1d:	53                   	push   %ebx
  800d1e:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d24:	50                   	push   %eax
  800d25:	e8 54 f6 ff ff       	call   80037e <fd_alloc>
  800d2a:	89 c3                	mov    %eax,%ebx
  800d2c:	83 c4 10             	add    $0x10,%esp
  800d2f:	85 c0                	test   %eax,%eax
  800d31:	78 5b                	js     800d8e <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d33:	83 ec 04             	sub    $0x4,%esp
  800d36:	68 07 04 00 00       	push   $0x407
  800d3b:	ff 75 f4             	pushl  -0xc(%ebp)
  800d3e:	6a 00                	push   $0x0
  800d40:	e8 21 f4 ff ff       	call   800166 <sys_page_alloc>
  800d45:	89 c3                	mov    %eax,%ebx
  800d47:	83 c4 10             	add    $0x10,%esp
  800d4a:	85 c0                	test   %eax,%eax
  800d4c:	78 40                	js     800d8e <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  800d4e:	83 ec 0c             	sub    $0xc,%esp
  800d51:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d54:	50                   	push   %eax
  800d55:	e8 24 f6 ff ff       	call   80037e <fd_alloc>
  800d5a:	89 c3                	mov    %eax,%ebx
  800d5c:	83 c4 10             	add    $0x10,%esp
  800d5f:	85 c0                	test   %eax,%eax
  800d61:	78 1b                	js     800d7e <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d63:	83 ec 04             	sub    $0x4,%esp
  800d66:	68 07 04 00 00       	push   $0x407
  800d6b:	ff 75 f0             	pushl  -0x10(%ebp)
  800d6e:	6a 00                	push   $0x0
  800d70:	e8 f1 f3 ff ff       	call   800166 <sys_page_alloc>
  800d75:	89 c3                	mov    %eax,%ebx
  800d77:	83 c4 10             	add    $0x10,%esp
  800d7a:	85 c0                	test   %eax,%eax
  800d7c:	79 19                	jns    800d97 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  800d7e:	83 ec 08             	sub    $0x8,%esp
  800d81:	ff 75 f4             	pushl  -0xc(%ebp)
  800d84:	6a 00                	push   $0x0
  800d86:	e8 60 f4 ff ff       	call   8001eb <sys_page_unmap>
  800d8b:	83 c4 10             	add    $0x10,%esp
}
  800d8e:	89 d8                	mov    %ebx,%eax
  800d90:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d93:	5b                   	pop    %ebx
  800d94:	5e                   	pop    %esi
  800d95:	5d                   	pop    %ebp
  800d96:	c3                   	ret    
	va = fd2data(fd0);
  800d97:	83 ec 0c             	sub    $0xc,%esp
  800d9a:	ff 75 f4             	pushl  -0xc(%ebp)
  800d9d:	e8 c5 f5 ff ff       	call   800367 <fd2data>
  800da2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da4:	83 c4 0c             	add    $0xc,%esp
  800da7:	68 07 04 00 00       	push   $0x407
  800dac:	50                   	push   %eax
  800dad:	6a 00                	push   $0x0
  800daf:	e8 b2 f3 ff ff       	call   800166 <sys_page_alloc>
  800db4:	89 c3                	mov    %eax,%ebx
  800db6:	83 c4 10             	add    $0x10,%esp
  800db9:	85 c0                	test   %eax,%eax
  800dbb:	0f 88 8c 00 00 00    	js     800e4d <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc1:	83 ec 0c             	sub    $0xc,%esp
  800dc4:	ff 75 f0             	pushl  -0x10(%ebp)
  800dc7:	e8 9b f5 ff ff       	call   800367 <fd2data>
  800dcc:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dd3:	50                   	push   %eax
  800dd4:	6a 00                	push   $0x0
  800dd6:	56                   	push   %esi
  800dd7:	6a 00                	push   $0x0
  800dd9:	e8 cb f3 ff ff       	call   8001a9 <sys_page_map>
  800dde:	89 c3                	mov    %eax,%ebx
  800de0:	83 c4 20             	add    $0x20,%esp
  800de3:	85 c0                	test   %eax,%eax
  800de5:	78 58                	js     800e3f <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  800de7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dea:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800df0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800df2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800df5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  800dfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dff:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e05:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e07:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e0a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e11:	83 ec 0c             	sub    $0xc,%esp
  800e14:	ff 75 f4             	pushl  -0xc(%ebp)
  800e17:	e8 3b f5 ff ff       	call   800357 <fd2num>
  800e1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e1f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e21:	83 c4 04             	add    $0x4,%esp
  800e24:	ff 75 f0             	pushl  -0x10(%ebp)
  800e27:	e8 2b f5 ff ff       	call   800357 <fd2num>
  800e2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e2f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e32:	83 c4 10             	add    $0x10,%esp
  800e35:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3a:	e9 4f ff ff ff       	jmp    800d8e <pipe+0x75>
	sys_page_unmap(0, va);
  800e3f:	83 ec 08             	sub    $0x8,%esp
  800e42:	56                   	push   %esi
  800e43:	6a 00                	push   $0x0
  800e45:	e8 a1 f3 ff ff       	call   8001eb <sys_page_unmap>
  800e4a:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e4d:	83 ec 08             	sub    $0x8,%esp
  800e50:	ff 75 f0             	pushl  -0x10(%ebp)
  800e53:	6a 00                	push   $0x0
  800e55:	e8 91 f3 ff ff       	call   8001eb <sys_page_unmap>
  800e5a:	83 c4 10             	add    $0x10,%esp
  800e5d:	e9 1c ff ff ff       	jmp    800d7e <pipe+0x65>

00800e62 <pipeisclosed>:
{
  800e62:	55                   	push   %ebp
  800e63:	89 e5                	mov    %esp,%ebp
  800e65:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e68:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e6b:	50                   	push   %eax
  800e6c:	ff 75 08             	pushl  0x8(%ebp)
  800e6f:	e8 59 f5 ff ff       	call   8003cd <fd_lookup>
  800e74:	83 c4 10             	add    $0x10,%esp
  800e77:	85 c0                	test   %eax,%eax
  800e79:	78 18                	js     800e93 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  800e7b:	83 ec 0c             	sub    $0xc,%esp
  800e7e:	ff 75 f4             	pushl  -0xc(%ebp)
  800e81:	e8 e1 f4 ff ff       	call   800367 <fd2data>
	return _pipeisclosed(fd, p);
  800e86:	89 c2                	mov    %eax,%edx
  800e88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e8b:	e8 30 fd ff ff       	call   800bc0 <_pipeisclosed>
  800e90:	83 c4 10             	add    $0x10,%esp
}
  800e93:	c9                   	leave  
  800e94:	c3                   	ret    

00800e95 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e95:	55                   	push   %ebp
  800e96:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e98:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9d:	5d                   	pop    %ebp
  800e9e:	c3                   	ret    

00800e9f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e9f:	55                   	push   %ebp
  800ea0:	89 e5                	mov    %esp,%ebp
  800ea2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ea5:	68 fa 1e 80 00       	push   $0x801efa
  800eaa:	ff 75 0c             	pushl  0xc(%ebp)
  800ead:	e8 5a 08 00 00       	call   80170c <strcpy>
	return 0;
}
  800eb2:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb7:	c9                   	leave  
  800eb8:	c3                   	ret    

00800eb9 <devcons_write>:
{
  800eb9:	55                   	push   %ebp
  800eba:	89 e5                	mov    %esp,%ebp
  800ebc:	57                   	push   %edi
  800ebd:	56                   	push   %esi
  800ebe:	53                   	push   %ebx
  800ebf:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800ec5:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800eca:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800ed0:	eb 2f                	jmp    800f01 <devcons_write+0x48>
		m = n - tot;
  800ed2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ed5:	29 f3                	sub    %esi,%ebx
  800ed7:	83 fb 7f             	cmp    $0x7f,%ebx
  800eda:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800edf:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800ee2:	83 ec 04             	sub    $0x4,%esp
  800ee5:	53                   	push   %ebx
  800ee6:	89 f0                	mov    %esi,%eax
  800ee8:	03 45 0c             	add    0xc(%ebp),%eax
  800eeb:	50                   	push   %eax
  800eec:	57                   	push   %edi
  800eed:	e8 a8 09 00 00       	call   80189a <memmove>
		sys_cputs(buf, m);
  800ef2:	83 c4 08             	add    $0x8,%esp
  800ef5:	53                   	push   %ebx
  800ef6:	57                   	push   %edi
  800ef7:	e8 ae f1 ff ff       	call   8000aa <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800efc:	01 de                	add    %ebx,%esi
  800efe:	83 c4 10             	add    $0x10,%esp
  800f01:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f04:	72 cc                	jb     800ed2 <devcons_write+0x19>
}
  800f06:	89 f0                	mov    %esi,%eax
  800f08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f0b:	5b                   	pop    %ebx
  800f0c:	5e                   	pop    %esi
  800f0d:	5f                   	pop    %edi
  800f0e:	5d                   	pop    %ebp
  800f0f:	c3                   	ret    

00800f10 <devcons_read>:
{
  800f10:	55                   	push   %ebp
  800f11:	89 e5                	mov    %esp,%ebp
  800f13:	83 ec 08             	sub    $0x8,%esp
  800f16:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f1b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f1f:	75 07                	jne    800f28 <devcons_read+0x18>
}
  800f21:	c9                   	leave  
  800f22:	c3                   	ret    
		sys_yield();
  800f23:	e8 1f f2 ff ff       	call   800147 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  800f28:	e8 9b f1 ff ff       	call   8000c8 <sys_cgetc>
  800f2d:	85 c0                	test   %eax,%eax
  800f2f:	74 f2                	je     800f23 <devcons_read+0x13>
	if (c < 0)
  800f31:	85 c0                	test   %eax,%eax
  800f33:	78 ec                	js     800f21 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  800f35:	83 f8 04             	cmp    $0x4,%eax
  800f38:	74 0c                	je     800f46 <devcons_read+0x36>
	*(char*)vbuf = c;
  800f3a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f3d:	88 02                	mov    %al,(%edx)
	return 1;
  800f3f:	b8 01 00 00 00       	mov    $0x1,%eax
  800f44:	eb db                	jmp    800f21 <devcons_read+0x11>
		return 0;
  800f46:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4b:	eb d4                	jmp    800f21 <devcons_read+0x11>

00800f4d <cputchar>:
{
  800f4d:	55                   	push   %ebp
  800f4e:	89 e5                	mov    %esp,%ebp
  800f50:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f53:	8b 45 08             	mov    0x8(%ebp),%eax
  800f56:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800f59:	6a 01                	push   $0x1
  800f5b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f5e:	50                   	push   %eax
  800f5f:	e8 46 f1 ff ff       	call   8000aa <sys_cputs>
}
  800f64:	83 c4 10             	add    $0x10,%esp
  800f67:	c9                   	leave  
  800f68:	c3                   	ret    

00800f69 <getchar>:
{
  800f69:	55                   	push   %ebp
  800f6a:	89 e5                	mov    %esp,%ebp
  800f6c:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800f6f:	6a 01                	push   $0x1
  800f71:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f74:	50                   	push   %eax
  800f75:	6a 00                	push   $0x0
  800f77:	e8 c2 f6 ff ff       	call   80063e <read>
	if (r < 0)
  800f7c:	83 c4 10             	add    $0x10,%esp
  800f7f:	85 c0                	test   %eax,%eax
  800f81:	78 08                	js     800f8b <getchar+0x22>
	if (r < 1)
  800f83:	85 c0                	test   %eax,%eax
  800f85:	7e 06                	jle    800f8d <getchar+0x24>
	return c;
  800f87:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800f8b:	c9                   	leave  
  800f8c:	c3                   	ret    
		return -E_EOF;
  800f8d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800f92:	eb f7                	jmp    800f8b <getchar+0x22>

00800f94 <iscons>:
{
  800f94:	55                   	push   %ebp
  800f95:	89 e5                	mov    %esp,%ebp
  800f97:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f9a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f9d:	50                   	push   %eax
  800f9e:	ff 75 08             	pushl  0x8(%ebp)
  800fa1:	e8 27 f4 ff ff       	call   8003cd <fd_lookup>
  800fa6:	83 c4 10             	add    $0x10,%esp
  800fa9:	85 c0                	test   %eax,%eax
  800fab:	78 11                	js     800fbe <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  800fad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fb0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fb6:	39 10                	cmp    %edx,(%eax)
  800fb8:	0f 94 c0             	sete   %al
  800fbb:	0f b6 c0             	movzbl %al,%eax
}
  800fbe:	c9                   	leave  
  800fbf:	c3                   	ret    

00800fc0 <opencons>:
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800fc6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc9:	50                   	push   %eax
  800fca:	e8 af f3 ff ff       	call   80037e <fd_alloc>
  800fcf:	83 c4 10             	add    $0x10,%esp
  800fd2:	85 c0                	test   %eax,%eax
  800fd4:	78 3a                	js     801010 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fd6:	83 ec 04             	sub    $0x4,%esp
  800fd9:	68 07 04 00 00       	push   $0x407
  800fde:	ff 75 f4             	pushl  -0xc(%ebp)
  800fe1:	6a 00                	push   $0x0
  800fe3:	e8 7e f1 ff ff       	call   800166 <sys_page_alloc>
  800fe8:	83 c4 10             	add    $0x10,%esp
  800feb:	85 c0                	test   %eax,%eax
  800fed:	78 21                	js     801010 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  800fef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800ff8:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800ffa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ffd:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801004:	83 ec 0c             	sub    $0xc,%esp
  801007:	50                   	push   %eax
  801008:	e8 4a f3 ff ff       	call   800357 <fd2num>
  80100d:	83 c4 10             	add    $0x10,%esp
}
  801010:	c9                   	leave  
  801011:	c3                   	ret    

00801012 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801012:	55                   	push   %ebp
  801013:	89 e5                	mov    %esp,%ebp
  801015:	56                   	push   %esi
  801016:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801017:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80101a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801020:	e8 03 f1 ff ff       	call   800128 <sys_getenvid>
  801025:	83 ec 0c             	sub    $0xc,%esp
  801028:	ff 75 0c             	pushl  0xc(%ebp)
  80102b:	ff 75 08             	pushl  0x8(%ebp)
  80102e:	56                   	push   %esi
  80102f:	50                   	push   %eax
  801030:	68 08 1f 80 00       	push   $0x801f08
  801035:	e8 b3 00 00 00       	call   8010ed <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80103a:	83 c4 18             	add    $0x18,%esp
  80103d:	53                   	push   %ebx
  80103e:	ff 75 10             	pushl  0x10(%ebp)
  801041:	e8 56 00 00 00       	call   80109c <vcprintf>
	cprintf("\n");
  801046:	c7 04 24 f3 1e 80 00 	movl   $0x801ef3,(%esp)
  80104d:	e8 9b 00 00 00       	call   8010ed <cprintf>
  801052:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801055:	cc                   	int3   
  801056:	eb fd                	jmp    801055 <_panic+0x43>

00801058 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	53                   	push   %ebx
  80105c:	83 ec 04             	sub    $0x4,%esp
  80105f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801062:	8b 13                	mov    (%ebx),%edx
  801064:	8d 42 01             	lea    0x1(%edx),%eax
  801067:	89 03                	mov    %eax,(%ebx)
  801069:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80106c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801070:	3d ff 00 00 00       	cmp    $0xff,%eax
  801075:	74 09                	je     801080 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801077:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80107b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80107e:	c9                   	leave  
  80107f:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801080:	83 ec 08             	sub    $0x8,%esp
  801083:	68 ff 00 00 00       	push   $0xff
  801088:	8d 43 08             	lea    0x8(%ebx),%eax
  80108b:	50                   	push   %eax
  80108c:	e8 19 f0 ff ff       	call   8000aa <sys_cputs>
		b->idx = 0;
  801091:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801097:	83 c4 10             	add    $0x10,%esp
  80109a:	eb db                	jmp    801077 <putch+0x1f>

0080109c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010a5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010ac:	00 00 00 
	b.cnt = 0;
  8010af:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010b6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010b9:	ff 75 0c             	pushl  0xc(%ebp)
  8010bc:	ff 75 08             	pushl  0x8(%ebp)
  8010bf:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010c5:	50                   	push   %eax
  8010c6:	68 58 10 80 00       	push   $0x801058
  8010cb:	e8 1a 01 00 00       	call   8011ea <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010d0:	83 c4 08             	add    $0x8,%esp
  8010d3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010d9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010df:	50                   	push   %eax
  8010e0:	e8 c5 ef ff ff       	call   8000aa <sys_cputs>

	return b.cnt;
}
  8010e5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010eb:	c9                   	leave  
  8010ec:	c3                   	ret    

008010ed <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010ed:	55                   	push   %ebp
  8010ee:	89 e5                	mov    %esp,%ebp
  8010f0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010f3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010f6:	50                   	push   %eax
  8010f7:	ff 75 08             	pushl  0x8(%ebp)
  8010fa:	e8 9d ff ff ff       	call   80109c <vcprintf>
	va_end(ap);

	return cnt;
}
  8010ff:	c9                   	leave  
  801100:	c3                   	ret    

00801101 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801101:	55                   	push   %ebp
  801102:	89 e5                	mov    %esp,%ebp
  801104:	57                   	push   %edi
  801105:	56                   	push   %esi
  801106:	53                   	push   %ebx
  801107:	83 ec 1c             	sub    $0x1c,%esp
  80110a:	89 c7                	mov    %eax,%edi
  80110c:	89 d6                	mov    %edx,%esi
  80110e:	8b 45 08             	mov    0x8(%ebp),%eax
  801111:	8b 55 0c             	mov    0xc(%ebp),%edx
  801114:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801117:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80111a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80111d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801122:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801125:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801128:	39 d3                	cmp    %edx,%ebx
  80112a:	72 05                	jb     801131 <printnum+0x30>
  80112c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80112f:	77 7a                	ja     8011ab <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801131:	83 ec 0c             	sub    $0xc,%esp
  801134:	ff 75 18             	pushl  0x18(%ebp)
  801137:	8b 45 14             	mov    0x14(%ebp),%eax
  80113a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80113d:	53                   	push   %ebx
  80113e:	ff 75 10             	pushl  0x10(%ebp)
  801141:	83 ec 08             	sub    $0x8,%esp
  801144:	ff 75 e4             	pushl  -0x1c(%ebp)
  801147:	ff 75 e0             	pushl  -0x20(%ebp)
  80114a:	ff 75 dc             	pushl  -0x24(%ebp)
  80114d:	ff 75 d8             	pushl  -0x28(%ebp)
  801150:	e8 3b 0a 00 00       	call   801b90 <__udivdi3>
  801155:	83 c4 18             	add    $0x18,%esp
  801158:	52                   	push   %edx
  801159:	50                   	push   %eax
  80115a:	89 f2                	mov    %esi,%edx
  80115c:	89 f8                	mov    %edi,%eax
  80115e:	e8 9e ff ff ff       	call   801101 <printnum>
  801163:	83 c4 20             	add    $0x20,%esp
  801166:	eb 13                	jmp    80117b <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801168:	83 ec 08             	sub    $0x8,%esp
  80116b:	56                   	push   %esi
  80116c:	ff 75 18             	pushl  0x18(%ebp)
  80116f:	ff d7                	call   *%edi
  801171:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801174:	83 eb 01             	sub    $0x1,%ebx
  801177:	85 db                	test   %ebx,%ebx
  801179:	7f ed                	jg     801168 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80117b:	83 ec 08             	sub    $0x8,%esp
  80117e:	56                   	push   %esi
  80117f:	83 ec 04             	sub    $0x4,%esp
  801182:	ff 75 e4             	pushl  -0x1c(%ebp)
  801185:	ff 75 e0             	pushl  -0x20(%ebp)
  801188:	ff 75 dc             	pushl  -0x24(%ebp)
  80118b:	ff 75 d8             	pushl  -0x28(%ebp)
  80118e:	e8 1d 0b 00 00       	call   801cb0 <__umoddi3>
  801193:	83 c4 14             	add    $0x14,%esp
  801196:	0f be 80 2b 1f 80 00 	movsbl 0x801f2b(%eax),%eax
  80119d:	50                   	push   %eax
  80119e:	ff d7                	call   *%edi
}
  8011a0:	83 c4 10             	add    $0x10,%esp
  8011a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a6:	5b                   	pop    %ebx
  8011a7:	5e                   	pop    %esi
  8011a8:	5f                   	pop    %edi
  8011a9:	5d                   	pop    %ebp
  8011aa:	c3                   	ret    
  8011ab:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8011ae:	eb c4                	jmp    801174 <printnum+0x73>

008011b0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011b0:	55                   	push   %ebp
  8011b1:	89 e5                	mov    %esp,%ebp
  8011b3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011b6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011ba:	8b 10                	mov    (%eax),%edx
  8011bc:	3b 50 04             	cmp    0x4(%eax),%edx
  8011bf:	73 0a                	jae    8011cb <sprintputch+0x1b>
		*b->buf++ = ch;
  8011c1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011c4:	89 08                	mov    %ecx,(%eax)
  8011c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c9:	88 02                	mov    %al,(%edx)
}
  8011cb:	5d                   	pop    %ebp
  8011cc:	c3                   	ret    

008011cd <printfmt>:
{
  8011cd:	55                   	push   %ebp
  8011ce:	89 e5                	mov    %esp,%ebp
  8011d0:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8011d3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011d6:	50                   	push   %eax
  8011d7:	ff 75 10             	pushl  0x10(%ebp)
  8011da:	ff 75 0c             	pushl  0xc(%ebp)
  8011dd:	ff 75 08             	pushl  0x8(%ebp)
  8011e0:	e8 05 00 00 00       	call   8011ea <vprintfmt>
}
  8011e5:	83 c4 10             	add    $0x10,%esp
  8011e8:	c9                   	leave  
  8011e9:	c3                   	ret    

008011ea <vprintfmt>:
{
  8011ea:	55                   	push   %ebp
  8011eb:	89 e5                	mov    %esp,%ebp
  8011ed:	57                   	push   %edi
  8011ee:	56                   	push   %esi
  8011ef:	53                   	push   %ebx
  8011f0:	83 ec 2c             	sub    $0x2c,%esp
  8011f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8011f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011f9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8011fc:	e9 c1 03 00 00       	jmp    8015c2 <vprintfmt+0x3d8>
		padc = ' ';
  801201:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  801205:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80120c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  801213:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80121a:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80121f:	8d 47 01             	lea    0x1(%edi),%eax
  801222:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801225:	0f b6 17             	movzbl (%edi),%edx
  801228:	8d 42 dd             	lea    -0x23(%edx),%eax
  80122b:	3c 55                	cmp    $0x55,%al
  80122d:	0f 87 12 04 00 00    	ja     801645 <vprintfmt+0x45b>
  801233:	0f b6 c0             	movzbl %al,%eax
  801236:	ff 24 85 60 20 80 00 	jmp    *0x802060(,%eax,4)
  80123d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801240:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  801244:	eb d9                	jmp    80121f <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801246:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  801249:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80124d:	eb d0                	jmp    80121f <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80124f:	0f b6 d2             	movzbl %dl,%edx
  801252:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801255:	b8 00 00 00 00       	mov    $0x0,%eax
  80125a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80125d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801260:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801264:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801267:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80126a:	83 f9 09             	cmp    $0x9,%ecx
  80126d:	77 55                	ja     8012c4 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80126f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801272:	eb e9                	jmp    80125d <vprintfmt+0x73>
			precision = va_arg(ap, int);
  801274:	8b 45 14             	mov    0x14(%ebp),%eax
  801277:	8b 00                	mov    (%eax),%eax
  801279:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80127c:	8b 45 14             	mov    0x14(%ebp),%eax
  80127f:	8d 40 04             	lea    0x4(%eax),%eax
  801282:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801285:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801288:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80128c:	79 91                	jns    80121f <vprintfmt+0x35>
				width = precision, precision = -1;
  80128e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801291:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801294:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80129b:	eb 82                	jmp    80121f <vprintfmt+0x35>
  80129d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012a0:	85 c0                	test   %eax,%eax
  8012a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8012a7:	0f 49 d0             	cmovns %eax,%edx
  8012aa:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8012ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012b0:	e9 6a ff ff ff       	jmp    80121f <vprintfmt+0x35>
  8012b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8012b8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012bf:	e9 5b ff ff ff       	jmp    80121f <vprintfmt+0x35>
  8012c4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012c7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012ca:	eb bc                	jmp    801288 <vprintfmt+0x9e>
			lflag++;
  8012cc:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8012d2:	e9 48 ff ff ff       	jmp    80121f <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8012d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8012da:	8d 78 04             	lea    0x4(%eax),%edi
  8012dd:	83 ec 08             	sub    $0x8,%esp
  8012e0:	53                   	push   %ebx
  8012e1:	ff 30                	pushl  (%eax)
  8012e3:	ff d6                	call   *%esi
			break;
  8012e5:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8012e8:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8012eb:	e9 cf 02 00 00       	jmp    8015bf <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8012f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8012f3:	8d 78 04             	lea    0x4(%eax),%edi
  8012f6:	8b 00                	mov    (%eax),%eax
  8012f8:	99                   	cltd   
  8012f9:	31 d0                	xor    %edx,%eax
  8012fb:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8012fd:	83 f8 0f             	cmp    $0xf,%eax
  801300:	7f 23                	jg     801325 <vprintfmt+0x13b>
  801302:	8b 14 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%edx
  801309:	85 d2                	test   %edx,%edx
  80130b:	74 18                	je     801325 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  80130d:	52                   	push   %edx
  80130e:	68 c1 1e 80 00       	push   $0x801ec1
  801313:	53                   	push   %ebx
  801314:	56                   	push   %esi
  801315:	e8 b3 fe ff ff       	call   8011cd <printfmt>
  80131a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80131d:	89 7d 14             	mov    %edi,0x14(%ebp)
  801320:	e9 9a 02 00 00       	jmp    8015bf <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  801325:	50                   	push   %eax
  801326:	68 43 1f 80 00       	push   $0x801f43
  80132b:	53                   	push   %ebx
  80132c:	56                   	push   %esi
  80132d:	e8 9b fe ff ff       	call   8011cd <printfmt>
  801332:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801335:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801338:	e9 82 02 00 00       	jmp    8015bf <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  80133d:	8b 45 14             	mov    0x14(%ebp),%eax
  801340:	83 c0 04             	add    $0x4,%eax
  801343:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801346:	8b 45 14             	mov    0x14(%ebp),%eax
  801349:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80134b:	85 ff                	test   %edi,%edi
  80134d:	b8 3c 1f 80 00       	mov    $0x801f3c,%eax
  801352:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801355:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801359:	0f 8e bd 00 00 00    	jle    80141c <vprintfmt+0x232>
  80135f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801363:	75 0e                	jne    801373 <vprintfmt+0x189>
  801365:	89 75 08             	mov    %esi,0x8(%ebp)
  801368:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80136b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80136e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801371:	eb 6d                	jmp    8013e0 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  801373:	83 ec 08             	sub    $0x8,%esp
  801376:	ff 75 d0             	pushl  -0x30(%ebp)
  801379:	57                   	push   %edi
  80137a:	e8 6e 03 00 00       	call   8016ed <strnlen>
  80137f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801382:	29 c1                	sub    %eax,%ecx
  801384:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  801387:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80138a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80138e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801391:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801394:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  801396:	eb 0f                	jmp    8013a7 <vprintfmt+0x1bd>
					putch(padc, putdat);
  801398:	83 ec 08             	sub    $0x8,%esp
  80139b:	53                   	push   %ebx
  80139c:	ff 75 e0             	pushl  -0x20(%ebp)
  80139f:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8013a1:	83 ef 01             	sub    $0x1,%edi
  8013a4:	83 c4 10             	add    $0x10,%esp
  8013a7:	85 ff                	test   %edi,%edi
  8013a9:	7f ed                	jg     801398 <vprintfmt+0x1ae>
  8013ab:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013ae:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8013b1:	85 c9                	test   %ecx,%ecx
  8013b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b8:	0f 49 c1             	cmovns %ecx,%eax
  8013bb:	29 c1                	sub    %eax,%ecx
  8013bd:	89 75 08             	mov    %esi,0x8(%ebp)
  8013c0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8013c3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8013c6:	89 cb                	mov    %ecx,%ebx
  8013c8:	eb 16                	jmp    8013e0 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8013ca:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013ce:	75 31                	jne    801401 <vprintfmt+0x217>
					putch(ch, putdat);
  8013d0:	83 ec 08             	sub    $0x8,%esp
  8013d3:	ff 75 0c             	pushl  0xc(%ebp)
  8013d6:	50                   	push   %eax
  8013d7:	ff 55 08             	call   *0x8(%ebp)
  8013da:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013dd:	83 eb 01             	sub    $0x1,%ebx
  8013e0:	83 c7 01             	add    $0x1,%edi
  8013e3:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8013e7:	0f be c2             	movsbl %dl,%eax
  8013ea:	85 c0                	test   %eax,%eax
  8013ec:	74 59                	je     801447 <vprintfmt+0x25d>
  8013ee:	85 f6                	test   %esi,%esi
  8013f0:	78 d8                	js     8013ca <vprintfmt+0x1e0>
  8013f2:	83 ee 01             	sub    $0x1,%esi
  8013f5:	79 d3                	jns    8013ca <vprintfmt+0x1e0>
  8013f7:	89 df                	mov    %ebx,%edi
  8013f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8013fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8013ff:	eb 37                	jmp    801438 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  801401:	0f be d2             	movsbl %dl,%edx
  801404:	83 ea 20             	sub    $0x20,%edx
  801407:	83 fa 5e             	cmp    $0x5e,%edx
  80140a:	76 c4                	jbe    8013d0 <vprintfmt+0x1e6>
					putch('?', putdat);
  80140c:	83 ec 08             	sub    $0x8,%esp
  80140f:	ff 75 0c             	pushl  0xc(%ebp)
  801412:	6a 3f                	push   $0x3f
  801414:	ff 55 08             	call   *0x8(%ebp)
  801417:	83 c4 10             	add    $0x10,%esp
  80141a:	eb c1                	jmp    8013dd <vprintfmt+0x1f3>
  80141c:	89 75 08             	mov    %esi,0x8(%ebp)
  80141f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801422:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801425:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801428:	eb b6                	jmp    8013e0 <vprintfmt+0x1f6>
				putch(' ', putdat);
  80142a:	83 ec 08             	sub    $0x8,%esp
  80142d:	53                   	push   %ebx
  80142e:	6a 20                	push   $0x20
  801430:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801432:	83 ef 01             	sub    $0x1,%edi
  801435:	83 c4 10             	add    $0x10,%esp
  801438:	85 ff                	test   %edi,%edi
  80143a:	7f ee                	jg     80142a <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80143c:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80143f:	89 45 14             	mov    %eax,0x14(%ebp)
  801442:	e9 78 01 00 00       	jmp    8015bf <vprintfmt+0x3d5>
  801447:	89 df                	mov    %ebx,%edi
  801449:	8b 75 08             	mov    0x8(%ebp),%esi
  80144c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80144f:	eb e7                	jmp    801438 <vprintfmt+0x24e>
	if (lflag >= 2)
  801451:	83 f9 01             	cmp    $0x1,%ecx
  801454:	7e 3f                	jle    801495 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  801456:	8b 45 14             	mov    0x14(%ebp),%eax
  801459:	8b 50 04             	mov    0x4(%eax),%edx
  80145c:	8b 00                	mov    (%eax),%eax
  80145e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801461:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801464:	8b 45 14             	mov    0x14(%ebp),%eax
  801467:	8d 40 08             	lea    0x8(%eax),%eax
  80146a:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80146d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801471:	79 5c                	jns    8014cf <vprintfmt+0x2e5>
				putch('-', putdat);
  801473:	83 ec 08             	sub    $0x8,%esp
  801476:	53                   	push   %ebx
  801477:	6a 2d                	push   $0x2d
  801479:	ff d6                	call   *%esi
				num = -(long long) num;
  80147b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80147e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801481:	f7 da                	neg    %edx
  801483:	83 d1 00             	adc    $0x0,%ecx
  801486:	f7 d9                	neg    %ecx
  801488:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80148b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801490:	e9 10 01 00 00       	jmp    8015a5 <vprintfmt+0x3bb>
	else if (lflag)
  801495:	85 c9                	test   %ecx,%ecx
  801497:	75 1b                	jne    8014b4 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  801499:	8b 45 14             	mov    0x14(%ebp),%eax
  80149c:	8b 00                	mov    (%eax),%eax
  80149e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014a1:	89 c1                	mov    %eax,%ecx
  8014a3:	c1 f9 1f             	sar    $0x1f,%ecx
  8014a6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ac:	8d 40 04             	lea    0x4(%eax),%eax
  8014af:	89 45 14             	mov    %eax,0x14(%ebp)
  8014b2:	eb b9                	jmp    80146d <vprintfmt+0x283>
		return va_arg(*ap, long);
  8014b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b7:	8b 00                	mov    (%eax),%eax
  8014b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014bc:	89 c1                	mov    %eax,%ecx
  8014be:	c1 f9 1f             	sar    $0x1f,%ecx
  8014c1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c7:	8d 40 04             	lea    0x4(%eax),%eax
  8014ca:	89 45 14             	mov    %eax,0x14(%ebp)
  8014cd:	eb 9e                	jmp    80146d <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8014cf:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014d2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8014d5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014da:	e9 c6 00 00 00       	jmp    8015a5 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8014df:	83 f9 01             	cmp    $0x1,%ecx
  8014e2:	7e 18                	jle    8014fc <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8014e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e7:	8b 10                	mov    (%eax),%edx
  8014e9:	8b 48 04             	mov    0x4(%eax),%ecx
  8014ec:	8d 40 08             	lea    0x8(%eax),%eax
  8014ef:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014f2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014f7:	e9 a9 00 00 00       	jmp    8015a5 <vprintfmt+0x3bb>
	else if (lflag)
  8014fc:	85 c9                	test   %ecx,%ecx
  8014fe:	75 1a                	jne    80151a <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  801500:	8b 45 14             	mov    0x14(%ebp),%eax
  801503:	8b 10                	mov    (%eax),%edx
  801505:	b9 00 00 00 00       	mov    $0x0,%ecx
  80150a:	8d 40 04             	lea    0x4(%eax),%eax
  80150d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801510:	b8 0a 00 00 00       	mov    $0xa,%eax
  801515:	e9 8b 00 00 00       	jmp    8015a5 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80151a:	8b 45 14             	mov    0x14(%ebp),%eax
  80151d:	8b 10                	mov    (%eax),%edx
  80151f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801524:	8d 40 04             	lea    0x4(%eax),%eax
  801527:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80152a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80152f:	eb 74                	jmp    8015a5 <vprintfmt+0x3bb>
	if (lflag >= 2)
  801531:	83 f9 01             	cmp    $0x1,%ecx
  801534:	7e 15                	jle    80154b <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  801536:	8b 45 14             	mov    0x14(%ebp),%eax
  801539:	8b 10                	mov    (%eax),%edx
  80153b:	8b 48 04             	mov    0x4(%eax),%ecx
  80153e:	8d 40 08             	lea    0x8(%eax),%eax
  801541:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801544:	b8 08 00 00 00       	mov    $0x8,%eax
  801549:	eb 5a                	jmp    8015a5 <vprintfmt+0x3bb>
	else if (lflag)
  80154b:	85 c9                	test   %ecx,%ecx
  80154d:	75 17                	jne    801566 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80154f:	8b 45 14             	mov    0x14(%ebp),%eax
  801552:	8b 10                	mov    (%eax),%edx
  801554:	b9 00 00 00 00       	mov    $0x0,%ecx
  801559:	8d 40 04             	lea    0x4(%eax),%eax
  80155c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80155f:	b8 08 00 00 00       	mov    $0x8,%eax
  801564:	eb 3f                	jmp    8015a5 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801566:	8b 45 14             	mov    0x14(%ebp),%eax
  801569:	8b 10                	mov    (%eax),%edx
  80156b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801570:	8d 40 04             	lea    0x4(%eax),%eax
  801573:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801576:	b8 08 00 00 00       	mov    $0x8,%eax
  80157b:	eb 28                	jmp    8015a5 <vprintfmt+0x3bb>
			putch('0', putdat);
  80157d:	83 ec 08             	sub    $0x8,%esp
  801580:	53                   	push   %ebx
  801581:	6a 30                	push   $0x30
  801583:	ff d6                	call   *%esi
			putch('x', putdat);
  801585:	83 c4 08             	add    $0x8,%esp
  801588:	53                   	push   %ebx
  801589:	6a 78                	push   $0x78
  80158b:	ff d6                	call   *%esi
			num = (unsigned long long)
  80158d:	8b 45 14             	mov    0x14(%ebp),%eax
  801590:	8b 10                	mov    (%eax),%edx
  801592:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801597:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80159a:	8d 40 04             	lea    0x4(%eax),%eax
  80159d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015a0:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8015a5:	83 ec 0c             	sub    $0xc,%esp
  8015a8:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015ac:	57                   	push   %edi
  8015ad:	ff 75 e0             	pushl  -0x20(%ebp)
  8015b0:	50                   	push   %eax
  8015b1:	51                   	push   %ecx
  8015b2:	52                   	push   %edx
  8015b3:	89 da                	mov    %ebx,%edx
  8015b5:	89 f0                	mov    %esi,%eax
  8015b7:	e8 45 fb ff ff       	call   801101 <printnum>
			break;
  8015bc:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8015bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015c2:	83 c7 01             	add    $0x1,%edi
  8015c5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015c9:	83 f8 25             	cmp    $0x25,%eax
  8015cc:	0f 84 2f fc ff ff    	je     801201 <vprintfmt+0x17>
			if (ch == '\0')
  8015d2:	85 c0                	test   %eax,%eax
  8015d4:	0f 84 8b 00 00 00    	je     801665 <vprintfmt+0x47b>
			putch(ch, putdat);
  8015da:	83 ec 08             	sub    $0x8,%esp
  8015dd:	53                   	push   %ebx
  8015de:	50                   	push   %eax
  8015df:	ff d6                	call   *%esi
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	eb dc                	jmp    8015c2 <vprintfmt+0x3d8>
	if (lflag >= 2)
  8015e6:	83 f9 01             	cmp    $0x1,%ecx
  8015e9:	7e 15                	jle    801600 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8015eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8015ee:	8b 10                	mov    (%eax),%edx
  8015f0:	8b 48 04             	mov    0x4(%eax),%ecx
  8015f3:	8d 40 08             	lea    0x8(%eax),%eax
  8015f6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015f9:	b8 10 00 00 00       	mov    $0x10,%eax
  8015fe:	eb a5                	jmp    8015a5 <vprintfmt+0x3bb>
	else if (lflag)
  801600:	85 c9                	test   %ecx,%ecx
  801602:	75 17                	jne    80161b <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  801604:	8b 45 14             	mov    0x14(%ebp),%eax
  801607:	8b 10                	mov    (%eax),%edx
  801609:	b9 00 00 00 00       	mov    $0x0,%ecx
  80160e:	8d 40 04             	lea    0x4(%eax),%eax
  801611:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801614:	b8 10 00 00 00       	mov    $0x10,%eax
  801619:	eb 8a                	jmp    8015a5 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80161b:	8b 45 14             	mov    0x14(%ebp),%eax
  80161e:	8b 10                	mov    (%eax),%edx
  801620:	b9 00 00 00 00       	mov    $0x0,%ecx
  801625:	8d 40 04             	lea    0x4(%eax),%eax
  801628:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80162b:	b8 10 00 00 00       	mov    $0x10,%eax
  801630:	e9 70 ff ff ff       	jmp    8015a5 <vprintfmt+0x3bb>
			putch(ch, putdat);
  801635:	83 ec 08             	sub    $0x8,%esp
  801638:	53                   	push   %ebx
  801639:	6a 25                	push   $0x25
  80163b:	ff d6                	call   *%esi
			break;
  80163d:	83 c4 10             	add    $0x10,%esp
  801640:	e9 7a ff ff ff       	jmp    8015bf <vprintfmt+0x3d5>
			putch('%', putdat);
  801645:	83 ec 08             	sub    $0x8,%esp
  801648:	53                   	push   %ebx
  801649:	6a 25                	push   $0x25
  80164b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80164d:	83 c4 10             	add    $0x10,%esp
  801650:	89 f8                	mov    %edi,%eax
  801652:	eb 03                	jmp    801657 <vprintfmt+0x46d>
  801654:	83 e8 01             	sub    $0x1,%eax
  801657:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80165b:	75 f7                	jne    801654 <vprintfmt+0x46a>
  80165d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801660:	e9 5a ff ff ff       	jmp    8015bf <vprintfmt+0x3d5>
}
  801665:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801668:	5b                   	pop    %ebx
  801669:	5e                   	pop    %esi
  80166a:	5f                   	pop    %edi
  80166b:	5d                   	pop    %ebp
  80166c:	c3                   	ret    

0080166d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80166d:	55                   	push   %ebp
  80166e:	89 e5                	mov    %esp,%ebp
  801670:	83 ec 18             	sub    $0x18,%esp
  801673:	8b 45 08             	mov    0x8(%ebp),%eax
  801676:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801679:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80167c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801680:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801683:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80168a:	85 c0                	test   %eax,%eax
  80168c:	74 26                	je     8016b4 <vsnprintf+0x47>
  80168e:	85 d2                	test   %edx,%edx
  801690:	7e 22                	jle    8016b4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801692:	ff 75 14             	pushl  0x14(%ebp)
  801695:	ff 75 10             	pushl  0x10(%ebp)
  801698:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80169b:	50                   	push   %eax
  80169c:	68 b0 11 80 00       	push   $0x8011b0
  8016a1:	e8 44 fb ff ff       	call   8011ea <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016a9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016af:	83 c4 10             	add    $0x10,%esp
}
  8016b2:	c9                   	leave  
  8016b3:	c3                   	ret    
		return -E_INVAL;
  8016b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016b9:	eb f7                	jmp    8016b2 <vsnprintf+0x45>

008016bb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016bb:	55                   	push   %ebp
  8016bc:	89 e5                	mov    %esp,%ebp
  8016be:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016c1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016c4:	50                   	push   %eax
  8016c5:	ff 75 10             	pushl  0x10(%ebp)
  8016c8:	ff 75 0c             	pushl  0xc(%ebp)
  8016cb:	ff 75 08             	pushl  0x8(%ebp)
  8016ce:	e8 9a ff ff ff       	call   80166d <vsnprintf>
	va_end(ap);

	return rc;
}
  8016d3:	c9                   	leave  
  8016d4:	c3                   	ret    

008016d5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016d5:	55                   	push   %ebp
  8016d6:	89 e5                	mov    %esp,%ebp
  8016d8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016db:	b8 00 00 00 00       	mov    $0x0,%eax
  8016e0:	eb 03                	jmp    8016e5 <strlen+0x10>
		n++;
  8016e2:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8016e5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016e9:	75 f7                	jne    8016e2 <strlen+0xd>
	return n;
}
  8016eb:	5d                   	pop    %ebp
  8016ec:	c3                   	ret    

008016ed <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016ed:	55                   	push   %ebp
  8016ee:	89 e5                	mov    %esp,%ebp
  8016f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016f3:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8016fb:	eb 03                	jmp    801700 <strnlen+0x13>
		n++;
  8016fd:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801700:	39 d0                	cmp    %edx,%eax
  801702:	74 06                	je     80170a <strnlen+0x1d>
  801704:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801708:	75 f3                	jne    8016fd <strnlen+0x10>
	return n;
}
  80170a:	5d                   	pop    %ebp
  80170b:	c3                   	ret    

0080170c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80170c:	55                   	push   %ebp
  80170d:	89 e5                	mov    %esp,%ebp
  80170f:	53                   	push   %ebx
  801710:	8b 45 08             	mov    0x8(%ebp),%eax
  801713:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801716:	89 c2                	mov    %eax,%edx
  801718:	83 c1 01             	add    $0x1,%ecx
  80171b:	83 c2 01             	add    $0x1,%edx
  80171e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801722:	88 5a ff             	mov    %bl,-0x1(%edx)
  801725:	84 db                	test   %bl,%bl
  801727:	75 ef                	jne    801718 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801729:	5b                   	pop    %ebx
  80172a:	5d                   	pop    %ebp
  80172b:	c3                   	ret    

0080172c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80172c:	55                   	push   %ebp
  80172d:	89 e5                	mov    %esp,%ebp
  80172f:	53                   	push   %ebx
  801730:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801733:	53                   	push   %ebx
  801734:	e8 9c ff ff ff       	call   8016d5 <strlen>
  801739:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80173c:	ff 75 0c             	pushl  0xc(%ebp)
  80173f:	01 d8                	add    %ebx,%eax
  801741:	50                   	push   %eax
  801742:	e8 c5 ff ff ff       	call   80170c <strcpy>
	return dst;
}
  801747:	89 d8                	mov    %ebx,%eax
  801749:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80174c:	c9                   	leave  
  80174d:	c3                   	ret    

0080174e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80174e:	55                   	push   %ebp
  80174f:	89 e5                	mov    %esp,%ebp
  801751:	56                   	push   %esi
  801752:	53                   	push   %ebx
  801753:	8b 75 08             	mov    0x8(%ebp),%esi
  801756:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801759:	89 f3                	mov    %esi,%ebx
  80175b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80175e:	89 f2                	mov    %esi,%edx
  801760:	eb 0f                	jmp    801771 <strncpy+0x23>
		*dst++ = *src;
  801762:	83 c2 01             	add    $0x1,%edx
  801765:	0f b6 01             	movzbl (%ecx),%eax
  801768:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80176b:	80 39 01             	cmpb   $0x1,(%ecx)
  80176e:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  801771:	39 da                	cmp    %ebx,%edx
  801773:	75 ed                	jne    801762 <strncpy+0x14>
	}
	return ret;
}
  801775:	89 f0                	mov    %esi,%eax
  801777:	5b                   	pop    %ebx
  801778:	5e                   	pop    %esi
  801779:	5d                   	pop    %ebp
  80177a:	c3                   	ret    

0080177b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80177b:	55                   	push   %ebp
  80177c:	89 e5                	mov    %esp,%ebp
  80177e:	56                   	push   %esi
  80177f:	53                   	push   %ebx
  801780:	8b 75 08             	mov    0x8(%ebp),%esi
  801783:	8b 55 0c             	mov    0xc(%ebp),%edx
  801786:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801789:	89 f0                	mov    %esi,%eax
  80178b:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80178f:	85 c9                	test   %ecx,%ecx
  801791:	75 0b                	jne    80179e <strlcpy+0x23>
  801793:	eb 17                	jmp    8017ac <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801795:	83 c2 01             	add    $0x1,%edx
  801798:	83 c0 01             	add    $0x1,%eax
  80179b:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80179e:	39 d8                	cmp    %ebx,%eax
  8017a0:	74 07                	je     8017a9 <strlcpy+0x2e>
  8017a2:	0f b6 0a             	movzbl (%edx),%ecx
  8017a5:	84 c9                	test   %cl,%cl
  8017a7:	75 ec                	jne    801795 <strlcpy+0x1a>
		*dst = '\0';
  8017a9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017ac:	29 f0                	sub    %esi,%eax
}
  8017ae:	5b                   	pop    %ebx
  8017af:	5e                   	pop    %esi
  8017b0:	5d                   	pop    %ebp
  8017b1:	c3                   	ret    

008017b2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017b2:	55                   	push   %ebp
  8017b3:	89 e5                	mov    %esp,%ebp
  8017b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017b8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017bb:	eb 06                	jmp    8017c3 <strcmp+0x11>
		p++, q++;
  8017bd:	83 c1 01             	add    $0x1,%ecx
  8017c0:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8017c3:	0f b6 01             	movzbl (%ecx),%eax
  8017c6:	84 c0                	test   %al,%al
  8017c8:	74 04                	je     8017ce <strcmp+0x1c>
  8017ca:	3a 02                	cmp    (%edx),%al
  8017cc:	74 ef                	je     8017bd <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017ce:	0f b6 c0             	movzbl %al,%eax
  8017d1:	0f b6 12             	movzbl (%edx),%edx
  8017d4:	29 d0                	sub    %edx,%eax
}
  8017d6:	5d                   	pop    %ebp
  8017d7:	c3                   	ret    

008017d8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017d8:	55                   	push   %ebp
  8017d9:	89 e5                	mov    %esp,%ebp
  8017db:	53                   	push   %ebx
  8017dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017e2:	89 c3                	mov    %eax,%ebx
  8017e4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017e7:	eb 06                	jmp    8017ef <strncmp+0x17>
		n--, p++, q++;
  8017e9:	83 c0 01             	add    $0x1,%eax
  8017ec:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8017ef:	39 d8                	cmp    %ebx,%eax
  8017f1:	74 16                	je     801809 <strncmp+0x31>
  8017f3:	0f b6 08             	movzbl (%eax),%ecx
  8017f6:	84 c9                	test   %cl,%cl
  8017f8:	74 04                	je     8017fe <strncmp+0x26>
  8017fa:	3a 0a                	cmp    (%edx),%cl
  8017fc:	74 eb                	je     8017e9 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017fe:	0f b6 00             	movzbl (%eax),%eax
  801801:	0f b6 12             	movzbl (%edx),%edx
  801804:	29 d0                	sub    %edx,%eax
}
  801806:	5b                   	pop    %ebx
  801807:	5d                   	pop    %ebp
  801808:	c3                   	ret    
		return 0;
  801809:	b8 00 00 00 00       	mov    $0x0,%eax
  80180e:	eb f6                	jmp    801806 <strncmp+0x2e>

00801810 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801810:	55                   	push   %ebp
  801811:	89 e5                	mov    %esp,%ebp
  801813:	8b 45 08             	mov    0x8(%ebp),%eax
  801816:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80181a:	0f b6 10             	movzbl (%eax),%edx
  80181d:	84 d2                	test   %dl,%dl
  80181f:	74 09                	je     80182a <strchr+0x1a>
		if (*s == c)
  801821:	38 ca                	cmp    %cl,%dl
  801823:	74 0a                	je     80182f <strchr+0x1f>
	for (; *s; s++)
  801825:	83 c0 01             	add    $0x1,%eax
  801828:	eb f0                	jmp    80181a <strchr+0xa>
			return (char *) s;
	return 0;
  80182a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80182f:	5d                   	pop    %ebp
  801830:	c3                   	ret    

00801831 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801831:	55                   	push   %ebp
  801832:	89 e5                	mov    %esp,%ebp
  801834:	8b 45 08             	mov    0x8(%ebp),%eax
  801837:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80183b:	eb 03                	jmp    801840 <strfind+0xf>
  80183d:	83 c0 01             	add    $0x1,%eax
  801840:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801843:	38 ca                	cmp    %cl,%dl
  801845:	74 04                	je     80184b <strfind+0x1a>
  801847:	84 d2                	test   %dl,%dl
  801849:	75 f2                	jne    80183d <strfind+0xc>
			break;
	return (char *) s;
}
  80184b:	5d                   	pop    %ebp
  80184c:	c3                   	ret    

0080184d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80184d:	55                   	push   %ebp
  80184e:	89 e5                	mov    %esp,%ebp
  801850:	57                   	push   %edi
  801851:	56                   	push   %esi
  801852:	53                   	push   %ebx
  801853:	8b 7d 08             	mov    0x8(%ebp),%edi
  801856:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801859:	85 c9                	test   %ecx,%ecx
  80185b:	74 13                	je     801870 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80185d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801863:	75 05                	jne    80186a <memset+0x1d>
  801865:	f6 c1 03             	test   $0x3,%cl
  801868:	74 0d                	je     801877 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80186a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80186d:	fc                   	cld    
  80186e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801870:	89 f8                	mov    %edi,%eax
  801872:	5b                   	pop    %ebx
  801873:	5e                   	pop    %esi
  801874:	5f                   	pop    %edi
  801875:	5d                   	pop    %ebp
  801876:	c3                   	ret    
		c &= 0xFF;
  801877:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80187b:	89 d3                	mov    %edx,%ebx
  80187d:	c1 e3 08             	shl    $0x8,%ebx
  801880:	89 d0                	mov    %edx,%eax
  801882:	c1 e0 18             	shl    $0x18,%eax
  801885:	89 d6                	mov    %edx,%esi
  801887:	c1 e6 10             	shl    $0x10,%esi
  80188a:	09 f0                	or     %esi,%eax
  80188c:	09 c2                	or     %eax,%edx
  80188e:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  801890:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801893:	89 d0                	mov    %edx,%eax
  801895:	fc                   	cld    
  801896:	f3 ab                	rep stos %eax,%es:(%edi)
  801898:	eb d6                	jmp    801870 <memset+0x23>

0080189a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80189a:	55                   	push   %ebp
  80189b:	89 e5                	mov    %esp,%ebp
  80189d:	57                   	push   %edi
  80189e:	56                   	push   %esi
  80189f:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018a5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018a8:	39 c6                	cmp    %eax,%esi
  8018aa:	73 35                	jae    8018e1 <memmove+0x47>
  8018ac:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018af:	39 c2                	cmp    %eax,%edx
  8018b1:	76 2e                	jbe    8018e1 <memmove+0x47>
		s += n;
		d += n;
  8018b3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018b6:	89 d6                	mov    %edx,%esi
  8018b8:	09 fe                	or     %edi,%esi
  8018ba:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018c0:	74 0c                	je     8018ce <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018c2:	83 ef 01             	sub    $0x1,%edi
  8018c5:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8018c8:	fd                   	std    
  8018c9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018cb:	fc                   	cld    
  8018cc:	eb 21                	jmp    8018ef <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018ce:	f6 c1 03             	test   $0x3,%cl
  8018d1:	75 ef                	jne    8018c2 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8018d3:	83 ef 04             	sub    $0x4,%edi
  8018d6:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018d9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8018dc:	fd                   	std    
  8018dd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018df:	eb ea                	jmp    8018cb <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018e1:	89 f2                	mov    %esi,%edx
  8018e3:	09 c2                	or     %eax,%edx
  8018e5:	f6 c2 03             	test   $0x3,%dl
  8018e8:	74 09                	je     8018f3 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018ea:	89 c7                	mov    %eax,%edi
  8018ec:	fc                   	cld    
  8018ed:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018ef:	5e                   	pop    %esi
  8018f0:	5f                   	pop    %edi
  8018f1:	5d                   	pop    %ebp
  8018f2:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018f3:	f6 c1 03             	test   $0x3,%cl
  8018f6:	75 f2                	jne    8018ea <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018f8:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8018fb:	89 c7                	mov    %eax,%edi
  8018fd:	fc                   	cld    
  8018fe:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801900:	eb ed                	jmp    8018ef <memmove+0x55>

00801902 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801902:	55                   	push   %ebp
  801903:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801905:	ff 75 10             	pushl  0x10(%ebp)
  801908:	ff 75 0c             	pushl  0xc(%ebp)
  80190b:	ff 75 08             	pushl  0x8(%ebp)
  80190e:	e8 87 ff ff ff       	call   80189a <memmove>
}
  801913:	c9                   	leave  
  801914:	c3                   	ret    

00801915 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801915:	55                   	push   %ebp
  801916:	89 e5                	mov    %esp,%ebp
  801918:	56                   	push   %esi
  801919:	53                   	push   %ebx
  80191a:	8b 45 08             	mov    0x8(%ebp),%eax
  80191d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801920:	89 c6                	mov    %eax,%esi
  801922:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801925:	39 f0                	cmp    %esi,%eax
  801927:	74 1c                	je     801945 <memcmp+0x30>
		if (*s1 != *s2)
  801929:	0f b6 08             	movzbl (%eax),%ecx
  80192c:	0f b6 1a             	movzbl (%edx),%ebx
  80192f:	38 d9                	cmp    %bl,%cl
  801931:	75 08                	jne    80193b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801933:	83 c0 01             	add    $0x1,%eax
  801936:	83 c2 01             	add    $0x1,%edx
  801939:	eb ea                	jmp    801925 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  80193b:	0f b6 c1             	movzbl %cl,%eax
  80193e:	0f b6 db             	movzbl %bl,%ebx
  801941:	29 d8                	sub    %ebx,%eax
  801943:	eb 05                	jmp    80194a <memcmp+0x35>
	}

	return 0;
  801945:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80194a:	5b                   	pop    %ebx
  80194b:	5e                   	pop    %esi
  80194c:	5d                   	pop    %ebp
  80194d:	c3                   	ret    

0080194e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80194e:	55                   	push   %ebp
  80194f:	89 e5                	mov    %esp,%ebp
  801951:	8b 45 08             	mov    0x8(%ebp),%eax
  801954:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801957:	89 c2                	mov    %eax,%edx
  801959:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80195c:	39 d0                	cmp    %edx,%eax
  80195e:	73 09                	jae    801969 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  801960:	38 08                	cmp    %cl,(%eax)
  801962:	74 05                	je     801969 <memfind+0x1b>
	for (; s < ends; s++)
  801964:	83 c0 01             	add    $0x1,%eax
  801967:	eb f3                	jmp    80195c <memfind+0xe>
			break;
	return (void *) s;
}
  801969:	5d                   	pop    %ebp
  80196a:	c3                   	ret    

0080196b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80196b:	55                   	push   %ebp
  80196c:	89 e5                	mov    %esp,%ebp
  80196e:	57                   	push   %edi
  80196f:	56                   	push   %esi
  801970:	53                   	push   %ebx
  801971:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801974:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801977:	eb 03                	jmp    80197c <strtol+0x11>
		s++;
  801979:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  80197c:	0f b6 01             	movzbl (%ecx),%eax
  80197f:	3c 20                	cmp    $0x20,%al
  801981:	74 f6                	je     801979 <strtol+0xe>
  801983:	3c 09                	cmp    $0x9,%al
  801985:	74 f2                	je     801979 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801987:	3c 2b                	cmp    $0x2b,%al
  801989:	74 2e                	je     8019b9 <strtol+0x4e>
	int neg = 0;
  80198b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801990:	3c 2d                	cmp    $0x2d,%al
  801992:	74 2f                	je     8019c3 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801994:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80199a:	75 05                	jne    8019a1 <strtol+0x36>
  80199c:	80 39 30             	cmpb   $0x30,(%ecx)
  80199f:	74 2c                	je     8019cd <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019a1:	85 db                	test   %ebx,%ebx
  8019a3:	75 0a                	jne    8019af <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019a5:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  8019aa:	80 39 30             	cmpb   $0x30,(%ecx)
  8019ad:	74 28                	je     8019d7 <strtol+0x6c>
		base = 10;
  8019af:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b4:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8019b7:	eb 50                	jmp    801a09 <strtol+0x9e>
		s++;
  8019b9:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8019bc:	bf 00 00 00 00       	mov    $0x0,%edi
  8019c1:	eb d1                	jmp    801994 <strtol+0x29>
		s++, neg = 1;
  8019c3:	83 c1 01             	add    $0x1,%ecx
  8019c6:	bf 01 00 00 00       	mov    $0x1,%edi
  8019cb:	eb c7                	jmp    801994 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019cd:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019d1:	74 0e                	je     8019e1 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8019d3:	85 db                	test   %ebx,%ebx
  8019d5:	75 d8                	jne    8019af <strtol+0x44>
		s++, base = 8;
  8019d7:	83 c1 01             	add    $0x1,%ecx
  8019da:	bb 08 00 00 00       	mov    $0x8,%ebx
  8019df:	eb ce                	jmp    8019af <strtol+0x44>
		s += 2, base = 16;
  8019e1:	83 c1 02             	add    $0x2,%ecx
  8019e4:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019e9:	eb c4                	jmp    8019af <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  8019eb:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019ee:	89 f3                	mov    %esi,%ebx
  8019f0:	80 fb 19             	cmp    $0x19,%bl
  8019f3:	77 29                	ja     801a1e <strtol+0xb3>
			dig = *s - 'a' + 10;
  8019f5:	0f be d2             	movsbl %dl,%edx
  8019f8:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019fb:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019fe:	7d 30                	jge    801a30 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801a00:	83 c1 01             	add    $0x1,%ecx
  801a03:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a07:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801a09:	0f b6 11             	movzbl (%ecx),%edx
  801a0c:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a0f:	89 f3                	mov    %esi,%ebx
  801a11:	80 fb 09             	cmp    $0x9,%bl
  801a14:	77 d5                	ja     8019eb <strtol+0x80>
			dig = *s - '0';
  801a16:	0f be d2             	movsbl %dl,%edx
  801a19:	83 ea 30             	sub    $0x30,%edx
  801a1c:	eb dd                	jmp    8019fb <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  801a1e:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a21:	89 f3                	mov    %esi,%ebx
  801a23:	80 fb 19             	cmp    $0x19,%bl
  801a26:	77 08                	ja     801a30 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801a28:	0f be d2             	movsbl %dl,%edx
  801a2b:	83 ea 37             	sub    $0x37,%edx
  801a2e:	eb cb                	jmp    8019fb <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  801a30:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a34:	74 05                	je     801a3b <strtol+0xd0>
		*endptr = (char *) s;
  801a36:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a39:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a3b:	89 c2                	mov    %eax,%edx
  801a3d:	f7 da                	neg    %edx
  801a3f:	85 ff                	test   %edi,%edi
  801a41:	0f 45 c2             	cmovne %edx,%eax
}
  801a44:	5b                   	pop    %ebx
  801a45:	5e                   	pop    %esi
  801a46:	5f                   	pop    %edi
  801a47:	5d                   	pop    %ebp
  801a48:	c3                   	ret    

00801a49 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a49:	55                   	push   %ebp
  801a4a:	89 e5                	mov    %esp,%ebp
  801a4c:	56                   	push   %esi
  801a4d:	53                   	push   %ebx
  801a4e:	8b 75 08             	mov    0x8(%ebp),%esi
  801a51:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a54:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        //	panic("ipc_recv not implemented");
        int r;
       	if(pg!=NULL){
  801a57:	85 c0                	test   %eax,%eax
  801a59:	74 3b                	je     801a96 <ipc_recv+0x4d>
	  r = sys_ipc_recv(pg);
  801a5b:	83 ec 0c             	sub    $0xc,%esp
  801a5e:	50                   	push   %eax
  801a5f:	e8 b2 e8 ff ff       	call   800316 <sys_ipc_recv>
  801a64:	83 c4 10             	add    $0x10,%esp
	}else
	  r = sys_ipc_recv((void *)UTOP);
	if(r<0){
  801a67:	85 c0                	test   %eax,%eax
  801a69:	78 3d                	js     801aa8 <ipc_recv+0x5f>
	if(perm_store!=NULL){
		*perm_store = 0;
            }
        	return r;
           }else{
	     if(from_env_store!=NULL)
  801a6b:	85 f6                	test   %esi,%esi
  801a6d:	74 0a                	je     801a79 <ipc_recv+0x30>
		     *from_env_store = thisenv->env_ipc_from;
  801a6f:	a1 04 40 80 00       	mov    0x804004,%eax
  801a74:	8b 40 74             	mov    0x74(%eax),%eax
  801a77:	89 06                	mov    %eax,(%esi)
	     if(perm_store != NULL)
  801a79:	85 db                	test   %ebx,%ebx
  801a7b:	74 0a                	je     801a87 <ipc_recv+0x3e>
		     *perm_store = thisenv->env_ipc_perm;
  801a7d:	a1 04 40 80 00       	mov    0x804004,%eax
  801a82:	8b 40 78             	mov    0x78(%eax),%eax
  801a85:	89 03                	mov    %eax,(%ebx)
	     return thisenv->env_ipc_value;
  801a87:	a1 04 40 80 00       	mov    0x804004,%eax
  801a8c:	8b 40 70             	mov    0x70(%eax),%eax
	   }

}
  801a8f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a92:	5b                   	pop    %ebx
  801a93:	5e                   	pop    %esi
  801a94:	5d                   	pop    %ebp
  801a95:	c3                   	ret    
	  r = sys_ipc_recv((void *)UTOP);
  801a96:	83 ec 0c             	sub    $0xc,%esp
  801a99:	68 00 00 c0 ee       	push   $0xeec00000
  801a9e:	e8 73 e8 ff ff       	call   800316 <sys_ipc_recv>
  801aa3:	83 c4 10             	add    $0x10,%esp
  801aa6:	eb bf                	jmp    801a67 <ipc_recv+0x1e>
	if(from_env_store!=NULL){
  801aa8:	85 f6                	test   %esi,%esi
  801aaa:	74 06                	je     801ab2 <ipc_recv+0x69>
	  *from_env_store = 0;
  801aac:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(perm_store!=NULL){
  801ab2:	85 db                	test   %ebx,%ebx
  801ab4:	74 d9                	je     801a8f <ipc_recv+0x46>
		*perm_store = 0;
  801ab6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801abc:	eb d1                	jmp    801a8f <ipc_recv+0x46>

00801abe <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801abe:	55                   	push   %ebp
  801abf:	89 e5                	mov    %esp,%ebp
  801ac1:	57                   	push   %edi
  801ac2:	56                   	push   %esi
  801ac3:	53                   	push   %ebx
  801ac4:	83 ec 0c             	sub    $0xc,%esp
  801ac7:	8b 7d 08             	mov    0x8(%ebp),%edi
  801aca:	8b 75 0c             	mov    0xc(%ebp),%esi
  801acd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if(pg==NULL) pg = (void *)UTOP;
  801ad0:	85 db                	test   %ebx,%ebx
  801ad2:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ad7:	0f 44 d8             	cmove  %eax,%ebx
	while((r=sys_ipc_try_send(to_env,val,pg,perm))<0){
  801ada:	ff 75 14             	pushl  0x14(%ebp)
  801add:	53                   	push   %ebx
  801ade:	56                   	push   %esi
  801adf:	57                   	push   %edi
  801ae0:	e8 0e e8 ff ff       	call   8002f3 <sys_ipc_try_send>
  801ae5:	83 c4 10             	add    $0x10,%esp
  801ae8:	85 c0                	test   %eax,%eax
  801aea:	79 20                	jns    801b0c <ipc_send+0x4e>
	    if(r!=-E_IPC_NOT_RECV){
  801aec:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801aef:	75 07                	jne    801af8 <ipc_send+0x3a>
		    panic("ipc_send:send message failed\n");
	    }
	    sys_yield();
  801af1:	e8 51 e6 ff ff       	call   800147 <sys_yield>
  801af6:	eb e2                	jmp    801ada <ipc_send+0x1c>
		    panic("ipc_send:send message failed\n");
  801af8:	83 ec 04             	sub    $0x4,%esp
  801afb:	68 20 22 80 00       	push   $0x802220
  801b00:	6a 43                	push   $0x43
  801b02:	68 3e 22 80 00       	push   $0x80223e
  801b07:	e8 06 f5 ff ff       	call   801012 <_panic>
	}

}
  801b0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b0f:	5b                   	pop    %ebx
  801b10:	5e                   	pop    %esi
  801b11:	5f                   	pop    %edi
  801b12:	5d                   	pop    %ebp
  801b13:	c3                   	ret    

00801b14 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b14:	55                   	push   %ebp
  801b15:	89 e5                	mov    %esp,%ebp
  801b17:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b1a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b1f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b22:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b28:	8b 52 50             	mov    0x50(%edx),%edx
  801b2b:	39 ca                	cmp    %ecx,%edx
  801b2d:	74 11                	je     801b40 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801b2f:	83 c0 01             	add    $0x1,%eax
  801b32:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b37:	75 e6                	jne    801b1f <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801b39:	b8 00 00 00 00       	mov    $0x0,%eax
  801b3e:	eb 0b                	jmp    801b4b <ipc_find_env+0x37>
			return envs[i].env_id;
  801b40:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b43:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b48:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b4b:	5d                   	pop    %ebp
  801b4c:	c3                   	ret    

00801b4d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b4d:	55                   	push   %ebp
  801b4e:	89 e5                	mov    %esp,%ebp
  801b50:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b53:	89 d0                	mov    %edx,%eax
  801b55:	c1 e8 16             	shr    $0x16,%eax
  801b58:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b5f:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801b64:	f6 c1 01             	test   $0x1,%cl
  801b67:	74 1d                	je     801b86 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801b69:	c1 ea 0c             	shr    $0xc,%edx
  801b6c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b73:	f6 c2 01             	test   $0x1,%dl
  801b76:	74 0e                	je     801b86 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b78:	c1 ea 0c             	shr    $0xc,%edx
  801b7b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b82:	ef 
  801b83:	0f b7 c0             	movzwl %ax,%eax
}
  801b86:	5d                   	pop    %ebp
  801b87:	c3                   	ret    
  801b88:	66 90                	xchg   %ax,%ax
  801b8a:	66 90                	xchg   %ax,%ax
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
