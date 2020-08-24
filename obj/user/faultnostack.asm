
obj/user/faultnostack:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	68 17 03 80 00       	push   $0x800317
  80003e:	6a 00                	push   $0x0
  800040:	e8 2c 02 00 00       	call   800271 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
}
  80004f:	83 c4 10             	add    $0x10,%esp
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80005f:	e8 c6 00 00 00       	call   80012a <sys_getenvid>
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 db                	test   %ebx,%ebx
  800078:	7e 07                	jle    800081 <libmain+0x2d>
		binaryname = argv[0];
  80007a:	8b 06                	mov    (%esi),%eax
  80007c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800081:	83 ec 08             	sub    $0x8,%esp
  800084:	56                   	push   %esi
  800085:	53                   	push   %ebx
  800086:	e8 a8 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008b:	e8 0a 00 00 00       	call   80009a <exit>
}
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    

0080009a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a0:	6a 00                	push   $0x0
  8000a2:	e8 42 00 00 00       	call   8000e9 <sys_env_destroy>
}
  8000a7:	83 c4 10             	add    $0x10,%esp
  8000aa:	c9                   	leave  
  8000ab:	c3                   	ret    

008000ac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	57                   	push   %edi
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bd:	89 c3                	mov    %eax,%ebx
  8000bf:	89 c7                	mov    %eax,%edi
  8000c1:	89 c6                	mov    %eax,%esi
  8000c3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c5:	5b                   	pop    %ebx
  8000c6:	5e                   	pop    %esi
  8000c7:	5f                   	pop    %edi
  8000c8:	5d                   	pop    %ebp
  8000c9:	c3                   	ret    

008000ca <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	57                   	push   %edi
  8000ce:	56                   	push   %esi
  8000cf:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000da:	89 d1                	mov    %edx,%ecx
  8000dc:	89 d3                	mov    %edx,%ebx
  8000de:	89 d7                	mov    %edx,%edi
  8000e0:	89 d6                	mov    %edx,%esi
  8000e2:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e4:	5b                   	pop    %ebx
  8000e5:	5e                   	pop    %esi
  8000e6:	5f                   	pop    %edi
  8000e7:	5d                   	pop    %ebp
  8000e8:	c3                   	ret    

008000e9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	57                   	push   %edi
  8000ed:	56                   	push   %esi
  8000ee:	53                   	push   %ebx
  8000ef:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fa:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ff:	89 cb                	mov    %ecx,%ebx
  800101:	89 cf                	mov    %ecx,%edi
  800103:	89 ce                	mov    %ecx,%esi
  800105:	cd 30                	int    $0x30
	if(check && ret > 0)
  800107:	85 c0                	test   %eax,%eax
  800109:	7f 08                	jg     800113 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010e:	5b                   	pop    %ebx
  80010f:	5e                   	pop    %esi
  800110:	5f                   	pop    %edi
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800113:	83 ec 0c             	sub    $0xc,%esp
  800116:	50                   	push   %eax
  800117:	6a 03                	push   $0x3
  800119:	68 2a 10 80 00       	push   $0x80102a
  80011e:	6a 23                	push   $0x23
  800120:	68 47 10 80 00       	push   $0x801047
  800125:	e8 14 02 00 00       	call   80033e <_panic>

0080012a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	57                   	push   %edi
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800130:	ba 00 00 00 00       	mov    $0x0,%edx
  800135:	b8 02 00 00 00       	mov    $0x2,%eax
  80013a:	89 d1                	mov    %edx,%ecx
  80013c:	89 d3                	mov    %edx,%ebx
  80013e:	89 d7                	mov    %edx,%edi
  800140:	89 d6                	mov    %edx,%esi
  800142:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    

00800149 <sys_yield>:

void
sys_yield(void)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	57                   	push   %edi
  80014d:	56                   	push   %esi
  80014e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80014f:	ba 00 00 00 00       	mov    $0x0,%edx
  800154:	b8 0a 00 00 00       	mov    $0xa,%eax
  800159:	89 d1                	mov    %edx,%ecx
  80015b:	89 d3                	mov    %edx,%ebx
  80015d:	89 d7                	mov    %edx,%edi
  80015f:	89 d6                	mov    %edx,%esi
  800161:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800163:	5b                   	pop    %ebx
  800164:	5e                   	pop    %esi
  800165:	5f                   	pop    %edi
  800166:	5d                   	pop    %ebp
  800167:	c3                   	ret    

00800168 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	57                   	push   %edi
  80016c:	56                   	push   %esi
  80016d:	53                   	push   %ebx
  80016e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800171:	be 00 00 00 00       	mov    $0x0,%esi
  800176:	8b 55 08             	mov    0x8(%ebp),%edx
  800179:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017c:	b8 04 00 00 00       	mov    $0x4,%eax
  800181:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800184:	89 f7                	mov    %esi,%edi
  800186:	cd 30                	int    $0x30
	if(check && ret > 0)
  800188:	85 c0                	test   %eax,%eax
  80018a:	7f 08                	jg     800194 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80018c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80018f:	5b                   	pop    %ebx
  800190:	5e                   	pop    %esi
  800191:	5f                   	pop    %edi
  800192:	5d                   	pop    %ebp
  800193:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800194:	83 ec 0c             	sub    $0xc,%esp
  800197:	50                   	push   %eax
  800198:	6a 04                	push   $0x4
  80019a:	68 2a 10 80 00       	push   $0x80102a
  80019f:	6a 23                	push   $0x23
  8001a1:	68 47 10 80 00       	push   $0x801047
  8001a6:	e8 93 01 00 00       	call   80033e <_panic>

008001ab <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	57                   	push   %edi
  8001af:	56                   	push   %esi
  8001b0:	53                   	push   %ebx
  8001b1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ba:	b8 05 00 00 00       	mov    $0x5,%eax
  8001bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c5:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	7f 08                	jg     8001d6 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d1:	5b                   	pop    %ebx
  8001d2:	5e                   	pop    %esi
  8001d3:	5f                   	pop    %edi
  8001d4:	5d                   	pop    %ebp
  8001d5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d6:	83 ec 0c             	sub    $0xc,%esp
  8001d9:	50                   	push   %eax
  8001da:	6a 05                	push   $0x5
  8001dc:	68 2a 10 80 00       	push   $0x80102a
  8001e1:	6a 23                	push   $0x23
  8001e3:	68 47 10 80 00       	push   $0x801047
  8001e8:	e8 51 01 00 00       	call   80033e <_panic>

008001ed <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	57                   	push   %edi
  8001f1:	56                   	push   %esi
  8001f2:	53                   	push   %ebx
  8001f3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800201:	b8 06 00 00 00       	mov    $0x6,%eax
  800206:	89 df                	mov    %ebx,%edi
  800208:	89 de                	mov    %ebx,%esi
  80020a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80020c:	85 c0                	test   %eax,%eax
  80020e:	7f 08                	jg     800218 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800210:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800213:	5b                   	pop    %ebx
  800214:	5e                   	pop    %esi
  800215:	5f                   	pop    %edi
  800216:	5d                   	pop    %ebp
  800217:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	50                   	push   %eax
  80021c:	6a 06                	push   $0x6
  80021e:	68 2a 10 80 00       	push   $0x80102a
  800223:	6a 23                	push   $0x23
  800225:	68 47 10 80 00       	push   $0x801047
  80022a:	e8 0f 01 00 00       	call   80033e <_panic>

0080022f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	57                   	push   %edi
  800233:	56                   	push   %esi
  800234:	53                   	push   %ebx
  800235:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800238:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023d:	8b 55 08             	mov    0x8(%ebp),%edx
  800240:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800243:	b8 08 00 00 00       	mov    $0x8,%eax
  800248:	89 df                	mov    %ebx,%edi
  80024a:	89 de                	mov    %ebx,%esi
  80024c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80024e:	85 c0                	test   %eax,%eax
  800250:	7f 08                	jg     80025a <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800252:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800255:	5b                   	pop    %ebx
  800256:	5e                   	pop    %esi
  800257:	5f                   	pop    %edi
  800258:	5d                   	pop    %ebp
  800259:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	50                   	push   %eax
  80025e:	6a 08                	push   $0x8
  800260:	68 2a 10 80 00       	push   $0x80102a
  800265:	6a 23                	push   $0x23
  800267:	68 47 10 80 00       	push   $0x801047
  80026c:	e8 cd 00 00 00       	call   80033e <_panic>

00800271 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	57                   	push   %edi
  800275:	56                   	push   %esi
  800276:	53                   	push   %ebx
  800277:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80027a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027f:	8b 55 08             	mov    0x8(%ebp),%edx
  800282:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800285:	b8 09 00 00 00       	mov    $0x9,%eax
  80028a:	89 df                	mov    %ebx,%edi
  80028c:	89 de                	mov    %ebx,%esi
  80028e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800290:	85 c0                	test   %eax,%eax
  800292:	7f 08                	jg     80029c <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800294:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800297:	5b                   	pop    %ebx
  800298:	5e                   	pop    %esi
  800299:	5f                   	pop    %edi
  80029a:	5d                   	pop    %ebp
  80029b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80029c:	83 ec 0c             	sub    $0xc,%esp
  80029f:	50                   	push   %eax
  8002a0:	6a 09                	push   $0x9
  8002a2:	68 2a 10 80 00       	push   $0x80102a
  8002a7:	6a 23                	push   $0x23
  8002a9:	68 47 10 80 00       	push   $0x801047
  8002ae:	e8 8b 00 00 00       	call   80033e <_panic>

008002b3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	57                   	push   %edi
  8002b7:	56                   	push   %esi
  8002b8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bf:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002c4:	be 00 00 00 00       	mov    $0x0,%esi
  8002c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002cc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002cf:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002d1:	5b                   	pop    %ebx
  8002d2:	5e                   	pop    %esi
  8002d3:	5f                   	pop    %edi
  8002d4:	5d                   	pop    %ebp
  8002d5:	c3                   	ret    

008002d6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	57                   	push   %edi
  8002da:	56                   	push   %esi
  8002db:	53                   	push   %ebx
  8002dc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002ec:	89 cb                	mov    %ecx,%ebx
  8002ee:	89 cf                	mov    %ecx,%edi
  8002f0:	89 ce                	mov    %ecx,%esi
  8002f2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002f4:	85 c0                	test   %eax,%eax
  8002f6:	7f 08                	jg     800300 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fb:	5b                   	pop    %ebx
  8002fc:	5e                   	pop    %esi
  8002fd:	5f                   	pop    %edi
  8002fe:	5d                   	pop    %ebp
  8002ff:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800300:	83 ec 0c             	sub    $0xc,%esp
  800303:	50                   	push   %eax
  800304:	6a 0c                	push   $0xc
  800306:	68 2a 10 80 00       	push   $0x80102a
  80030b:	6a 23                	push   $0x23
  80030d:	68 47 10 80 00       	push   $0x801047
  800312:	e8 27 00 00 00       	call   80033e <_panic>

00800317 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800317:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800318:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80031d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80031f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 48(%esp), %ebp
  800322:	8b 6c 24 30          	mov    0x30(%esp),%ebp
        subl $4, %ebp
  800326:	83 ed 04             	sub    $0x4,%ebp
        movl %ebp, 48(%esp)
  800329:	89 6c 24 30          	mov    %ebp,0x30(%esp)
        movl 40(%esp), %eax
  80032d:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl %eax, (%ebp)
  800331:	89 45 00             	mov    %eax,0x0(%ebp)
	// Restore the trap-time registers.  After you do this, you
 	// can no longer modify any general-purpose registers.
 	// LAB 4: Your code here.
        addl $8, %esp
  800334:	83 c4 08             	add    $0x8,%esp
        popal
  800337:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $4, %esp
  800338:	83 c4 04             	add    $0x4,%esp
        popfl
  80033b:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  80033c:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  80033d:	c3                   	ret    

0080033e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
  800341:	56                   	push   %esi
  800342:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800343:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800346:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80034c:	e8 d9 fd ff ff       	call   80012a <sys_getenvid>
  800351:	83 ec 0c             	sub    $0xc,%esp
  800354:	ff 75 0c             	pushl  0xc(%ebp)
  800357:	ff 75 08             	pushl  0x8(%ebp)
  80035a:	56                   	push   %esi
  80035b:	50                   	push   %eax
  80035c:	68 58 10 80 00       	push   $0x801058
  800361:	e8 b3 00 00 00       	call   800419 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800366:	83 c4 18             	add    $0x18,%esp
  800369:	53                   	push   %ebx
  80036a:	ff 75 10             	pushl  0x10(%ebp)
  80036d:	e8 56 00 00 00       	call   8003c8 <vcprintf>
	cprintf("\n");
  800372:	c7 04 24 7c 10 80 00 	movl   $0x80107c,(%esp)
  800379:	e8 9b 00 00 00       	call   800419 <cprintf>
  80037e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800381:	cc                   	int3   
  800382:	eb fd                	jmp    800381 <_panic+0x43>

00800384 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	53                   	push   %ebx
  800388:	83 ec 04             	sub    $0x4,%esp
  80038b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80038e:	8b 13                	mov    (%ebx),%edx
  800390:	8d 42 01             	lea    0x1(%edx),%eax
  800393:	89 03                	mov    %eax,(%ebx)
  800395:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800398:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80039c:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003a1:	74 09                	je     8003ac <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003a3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003aa:	c9                   	leave  
  8003ab:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003ac:	83 ec 08             	sub    $0x8,%esp
  8003af:	68 ff 00 00 00       	push   $0xff
  8003b4:	8d 43 08             	lea    0x8(%ebx),%eax
  8003b7:	50                   	push   %eax
  8003b8:	e8 ef fc ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  8003bd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003c3:	83 c4 10             	add    $0x10,%esp
  8003c6:	eb db                	jmp    8003a3 <putch+0x1f>

008003c8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003c8:	55                   	push   %ebp
  8003c9:	89 e5                	mov    %esp,%ebp
  8003cb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003d1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003d8:	00 00 00 
	b.cnt = 0;
  8003db:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003e2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003e5:	ff 75 0c             	pushl  0xc(%ebp)
  8003e8:	ff 75 08             	pushl  0x8(%ebp)
  8003eb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003f1:	50                   	push   %eax
  8003f2:	68 84 03 80 00       	push   $0x800384
  8003f7:	e8 1a 01 00 00       	call   800516 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003fc:	83 c4 08             	add    $0x8,%esp
  8003ff:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800405:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80040b:	50                   	push   %eax
  80040c:	e8 9b fc ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  800411:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800417:	c9                   	leave  
  800418:	c3                   	ret    

00800419 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800419:	55                   	push   %ebp
  80041a:	89 e5                	mov    %esp,%ebp
  80041c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80041f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800422:	50                   	push   %eax
  800423:	ff 75 08             	pushl  0x8(%ebp)
  800426:	e8 9d ff ff ff       	call   8003c8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80042b:	c9                   	leave  
  80042c:	c3                   	ret    

0080042d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80042d:	55                   	push   %ebp
  80042e:	89 e5                	mov    %esp,%ebp
  800430:	57                   	push   %edi
  800431:	56                   	push   %esi
  800432:	53                   	push   %ebx
  800433:	83 ec 1c             	sub    $0x1c,%esp
  800436:	89 c7                	mov    %eax,%edi
  800438:	89 d6                	mov    %edx,%esi
  80043a:	8b 45 08             	mov    0x8(%ebp),%eax
  80043d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800440:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800443:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800446:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800449:	bb 00 00 00 00       	mov    $0x0,%ebx
  80044e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800451:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800454:	39 d3                	cmp    %edx,%ebx
  800456:	72 05                	jb     80045d <printnum+0x30>
  800458:	39 45 10             	cmp    %eax,0x10(%ebp)
  80045b:	77 7a                	ja     8004d7 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80045d:	83 ec 0c             	sub    $0xc,%esp
  800460:	ff 75 18             	pushl  0x18(%ebp)
  800463:	8b 45 14             	mov    0x14(%ebp),%eax
  800466:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800469:	53                   	push   %ebx
  80046a:	ff 75 10             	pushl  0x10(%ebp)
  80046d:	83 ec 08             	sub    $0x8,%esp
  800470:	ff 75 e4             	pushl  -0x1c(%ebp)
  800473:	ff 75 e0             	pushl  -0x20(%ebp)
  800476:	ff 75 dc             	pushl  -0x24(%ebp)
  800479:	ff 75 d8             	pushl  -0x28(%ebp)
  80047c:	e8 5f 09 00 00       	call   800de0 <__udivdi3>
  800481:	83 c4 18             	add    $0x18,%esp
  800484:	52                   	push   %edx
  800485:	50                   	push   %eax
  800486:	89 f2                	mov    %esi,%edx
  800488:	89 f8                	mov    %edi,%eax
  80048a:	e8 9e ff ff ff       	call   80042d <printnum>
  80048f:	83 c4 20             	add    $0x20,%esp
  800492:	eb 13                	jmp    8004a7 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800494:	83 ec 08             	sub    $0x8,%esp
  800497:	56                   	push   %esi
  800498:	ff 75 18             	pushl  0x18(%ebp)
  80049b:	ff d7                	call   *%edi
  80049d:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8004a0:	83 eb 01             	sub    $0x1,%ebx
  8004a3:	85 db                	test   %ebx,%ebx
  8004a5:	7f ed                	jg     800494 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004a7:	83 ec 08             	sub    $0x8,%esp
  8004aa:	56                   	push   %esi
  8004ab:	83 ec 04             	sub    $0x4,%esp
  8004ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b4:	ff 75 dc             	pushl  -0x24(%ebp)
  8004b7:	ff 75 d8             	pushl  -0x28(%ebp)
  8004ba:	e8 41 0a 00 00       	call   800f00 <__umoddi3>
  8004bf:	83 c4 14             	add    $0x14,%esp
  8004c2:	0f be 80 7e 10 80 00 	movsbl 0x80107e(%eax),%eax
  8004c9:	50                   	push   %eax
  8004ca:	ff d7                	call   *%edi
}
  8004cc:	83 c4 10             	add    $0x10,%esp
  8004cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004d2:	5b                   	pop    %ebx
  8004d3:	5e                   	pop    %esi
  8004d4:	5f                   	pop    %edi
  8004d5:	5d                   	pop    %ebp
  8004d6:	c3                   	ret    
  8004d7:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004da:	eb c4                	jmp    8004a0 <printnum+0x73>

008004dc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004dc:	55                   	push   %ebp
  8004dd:	89 e5                	mov    %esp,%ebp
  8004df:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004e2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004e6:	8b 10                	mov    (%eax),%edx
  8004e8:	3b 50 04             	cmp    0x4(%eax),%edx
  8004eb:	73 0a                	jae    8004f7 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004ed:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004f0:	89 08                	mov    %ecx,(%eax)
  8004f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f5:	88 02                	mov    %al,(%edx)
}
  8004f7:	5d                   	pop    %ebp
  8004f8:	c3                   	ret    

008004f9 <printfmt>:
{
  8004f9:	55                   	push   %ebp
  8004fa:	89 e5                	mov    %esp,%ebp
  8004fc:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004ff:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800502:	50                   	push   %eax
  800503:	ff 75 10             	pushl  0x10(%ebp)
  800506:	ff 75 0c             	pushl  0xc(%ebp)
  800509:	ff 75 08             	pushl  0x8(%ebp)
  80050c:	e8 05 00 00 00       	call   800516 <vprintfmt>
}
  800511:	83 c4 10             	add    $0x10,%esp
  800514:	c9                   	leave  
  800515:	c3                   	ret    

00800516 <vprintfmt>:
{
  800516:	55                   	push   %ebp
  800517:	89 e5                	mov    %esp,%ebp
  800519:	57                   	push   %edi
  80051a:	56                   	push   %esi
  80051b:	53                   	push   %ebx
  80051c:	83 ec 2c             	sub    $0x2c,%esp
  80051f:	8b 75 08             	mov    0x8(%ebp),%esi
  800522:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800525:	8b 7d 10             	mov    0x10(%ebp),%edi
  800528:	e9 c1 03 00 00       	jmp    8008ee <vprintfmt+0x3d8>
		padc = ' ';
  80052d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800531:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800538:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80053f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800546:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80054b:	8d 47 01             	lea    0x1(%edi),%eax
  80054e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800551:	0f b6 17             	movzbl (%edi),%edx
  800554:	8d 42 dd             	lea    -0x23(%edx),%eax
  800557:	3c 55                	cmp    $0x55,%al
  800559:	0f 87 12 04 00 00    	ja     800971 <vprintfmt+0x45b>
  80055f:	0f b6 c0             	movzbl %al,%eax
  800562:	ff 24 85 40 11 80 00 	jmp    *0x801140(,%eax,4)
  800569:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80056c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800570:	eb d9                	jmp    80054b <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800572:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800575:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800579:	eb d0                	jmp    80054b <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80057b:	0f b6 d2             	movzbl %dl,%edx
  80057e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800581:	b8 00 00 00 00       	mov    $0x0,%eax
  800586:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800589:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80058c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800590:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800593:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800596:	83 f9 09             	cmp    $0x9,%ecx
  800599:	77 55                	ja     8005f0 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80059b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80059e:	eb e9                	jmp    800589 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8005a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a3:	8b 00                	mov    (%eax),%eax
  8005a5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ab:	8d 40 04             	lea    0x4(%eax),%eax
  8005ae:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005b4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005b8:	79 91                	jns    80054b <vprintfmt+0x35>
				width = precision, precision = -1;
  8005ba:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005c0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005c7:	eb 82                	jmp    80054b <vprintfmt+0x35>
  8005c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005cc:	85 c0                	test   %eax,%eax
  8005ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8005d3:	0f 49 d0             	cmovns %eax,%edx
  8005d6:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005dc:	e9 6a ff ff ff       	jmp    80054b <vprintfmt+0x35>
  8005e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005e4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005eb:	e9 5b ff ff ff       	jmp    80054b <vprintfmt+0x35>
  8005f0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005f3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005f6:	eb bc                	jmp    8005b4 <vprintfmt+0x9e>
			lflag++;
  8005f8:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005fe:	e9 48 ff ff ff       	jmp    80054b <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800603:	8b 45 14             	mov    0x14(%ebp),%eax
  800606:	8d 78 04             	lea    0x4(%eax),%edi
  800609:	83 ec 08             	sub    $0x8,%esp
  80060c:	53                   	push   %ebx
  80060d:	ff 30                	pushl  (%eax)
  80060f:	ff d6                	call   *%esi
			break;
  800611:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800614:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800617:	e9 cf 02 00 00       	jmp    8008eb <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  80061c:	8b 45 14             	mov    0x14(%ebp),%eax
  80061f:	8d 78 04             	lea    0x4(%eax),%edi
  800622:	8b 00                	mov    (%eax),%eax
  800624:	99                   	cltd   
  800625:	31 d0                	xor    %edx,%eax
  800627:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800629:	83 f8 08             	cmp    $0x8,%eax
  80062c:	7f 23                	jg     800651 <vprintfmt+0x13b>
  80062e:	8b 14 85 a0 12 80 00 	mov    0x8012a0(,%eax,4),%edx
  800635:	85 d2                	test   %edx,%edx
  800637:	74 18                	je     800651 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800639:	52                   	push   %edx
  80063a:	68 9f 10 80 00       	push   $0x80109f
  80063f:	53                   	push   %ebx
  800640:	56                   	push   %esi
  800641:	e8 b3 fe ff ff       	call   8004f9 <printfmt>
  800646:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800649:	89 7d 14             	mov    %edi,0x14(%ebp)
  80064c:	e9 9a 02 00 00       	jmp    8008eb <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800651:	50                   	push   %eax
  800652:	68 96 10 80 00       	push   $0x801096
  800657:	53                   	push   %ebx
  800658:	56                   	push   %esi
  800659:	e8 9b fe ff ff       	call   8004f9 <printfmt>
  80065e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800661:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800664:	e9 82 02 00 00       	jmp    8008eb <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800669:	8b 45 14             	mov    0x14(%ebp),%eax
  80066c:	83 c0 04             	add    $0x4,%eax
  80066f:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800672:	8b 45 14             	mov    0x14(%ebp),%eax
  800675:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800677:	85 ff                	test   %edi,%edi
  800679:	b8 8f 10 80 00       	mov    $0x80108f,%eax
  80067e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800681:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800685:	0f 8e bd 00 00 00    	jle    800748 <vprintfmt+0x232>
  80068b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80068f:	75 0e                	jne    80069f <vprintfmt+0x189>
  800691:	89 75 08             	mov    %esi,0x8(%ebp)
  800694:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800697:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80069a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80069d:	eb 6d                	jmp    80070c <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80069f:	83 ec 08             	sub    $0x8,%esp
  8006a2:	ff 75 d0             	pushl  -0x30(%ebp)
  8006a5:	57                   	push   %edi
  8006a6:	e8 6e 03 00 00       	call   800a19 <strnlen>
  8006ab:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006ae:	29 c1                	sub    %eax,%ecx
  8006b0:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8006b3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006b6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006bd:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006c0:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c2:	eb 0f                	jmp    8006d3 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8006c4:	83 ec 08             	sub    $0x8,%esp
  8006c7:	53                   	push   %ebx
  8006c8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006cb:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cd:	83 ef 01             	sub    $0x1,%edi
  8006d0:	83 c4 10             	add    $0x10,%esp
  8006d3:	85 ff                	test   %edi,%edi
  8006d5:	7f ed                	jg     8006c4 <vprintfmt+0x1ae>
  8006d7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006da:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006dd:	85 c9                	test   %ecx,%ecx
  8006df:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e4:	0f 49 c1             	cmovns %ecx,%eax
  8006e7:	29 c1                	sub    %eax,%ecx
  8006e9:	89 75 08             	mov    %esi,0x8(%ebp)
  8006ec:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006ef:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006f2:	89 cb                	mov    %ecx,%ebx
  8006f4:	eb 16                	jmp    80070c <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8006f6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006fa:	75 31                	jne    80072d <vprintfmt+0x217>
					putch(ch, putdat);
  8006fc:	83 ec 08             	sub    $0x8,%esp
  8006ff:	ff 75 0c             	pushl  0xc(%ebp)
  800702:	50                   	push   %eax
  800703:	ff 55 08             	call   *0x8(%ebp)
  800706:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800709:	83 eb 01             	sub    $0x1,%ebx
  80070c:	83 c7 01             	add    $0x1,%edi
  80070f:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800713:	0f be c2             	movsbl %dl,%eax
  800716:	85 c0                	test   %eax,%eax
  800718:	74 59                	je     800773 <vprintfmt+0x25d>
  80071a:	85 f6                	test   %esi,%esi
  80071c:	78 d8                	js     8006f6 <vprintfmt+0x1e0>
  80071e:	83 ee 01             	sub    $0x1,%esi
  800721:	79 d3                	jns    8006f6 <vprintfmt+0x1e0>
  800723:	89 df                	mov    %ebx,%edi
  800725:	8b 75 08             	mov    0x8(%ebp),%esi
  800728:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80072b:	eb 37                	jmp    800764 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  80072d:	0f be d2             	movsbl %dl,%edx
  800730:	83 ea 20             	sub    $0x20,%edx
  800733:	83 fa 5e             	cmp    $0x5e,%edx
  800736:	76 c4                	jbe    8006fc <vprintfmt+0x1e6>
					putch('?', putdat);
  800738:	83 ec 08             	sub    $0x8,%esp
  80073b:	ff 75 0c             	pushl  0xc(%ebp)
  80073e:	6a 3f                	push   $0x3f
  800740:	ff 55 08             	call   *0x8(%ebp)
  800743:	83 c4 10             	add    $0x10,%esp
  800746:	eb c1                	jmp    800709 <vprintfmt+0x1f3>
  800748:	89 75 08             	mov    %esi,0x8(%ebp)
  80074b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80074e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800751:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800754:	eb b6                	jmp    80070c <vprintfmt+0x1f6>
				putch(' ', putdat);
  800756:	83 ec 08             	sub    $0x8,%esp
  800759:	53                   	push   %ebx
  80075a:	6a 20                	push   $0x20
  80075c:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80075e:	83 ef 01             	sub    $0x1,%edi
  800761:	83 c4 10             	add    $0x10,%esp
  800764:	85 ff                	test   %edi,%edi
  800766:	7f ee                	jg     800756 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800768:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80076b:	89 45 14             	mov    %eax,0x14(%ebp)
  80076e:	e9 78 01 00 00       	jmp    8008eb <vprintfmt+0x3d5>
  800773:	89 df                	mov    %ebx,%edi
  800775:	8b 75 08             	mov    0x8(%ebp),%esi
  800778:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80077b:	eb e7                	jmp    800764 <vprintfmt+0x24e>
	if (lflag >= 2)
  80077d:	83 f9 01             	cmp    $0x1,%ecx
  800780:	7e 3f                	jle    8007c1 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800782:	8b 45 14             	mov    0x14(%ebp),%eax
  800785:	8b 50 04             	mov    0x4(%eax),%edx
  800788:	8b 00                	mov    (%eax),%eax
  80078a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800790:	8b 45 14             	mov    0x14(%ebp),%eax
  800793:	8d 40 08             	lea    0x8(%eax),%eax
  800796:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800799:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80079d:	79 5c                	jns    8007fb <vprintfmt+0x2e5>
				putch('-', putdat);
  80079f:	83 ec 08             	sub    $0x8,%esp
  8007a2:	53                   	push   %ebx
  8007a3:	6a 2d                	push   $0x2d
  8007a5:	ff d6                	call   *%esi
				num = -(long long) num;
  8007a7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007aa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007ad:	f7 da                	neg    %edx
  8007af:	83 d1 00             	adc    $0x0,%ecx
  8007b2:	f7 d9                	neg    %ecx
  8007b4:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007bc:	e9 10 01 00 00       	jmp    8008d1 <vprintfmt+0x3bb>
	else if (lflag)
  8007c1:	85 c9                	test   %ecx,%ecx
  8007c3:	75 1b                	jne    8007e0 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8007c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c8:	8b 00                	mov    (%eax),%eax
  8007ca:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007cd:	89 c1                	mov    %eax,%ecx
  8007cf:	c1 f9 1f             	sar    $0x1f,%ecx
  8007d2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d8:	8d 40 04             	lea    0x4(%eax),%eax
  8007db:	89 45 14             	mov    %eax,0x14(%ebp)
  8007de:	eb b9                	jmp    800799 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8007e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e3:	8b 00                	mov    (%eax),%eax
  8007e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e8:	89 c1                	mov    %eax,%ecx
  8007ea:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ed:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f3:	8d 40 04             	lea    0x4(%eax),%eax
  8007f6:	89 45 14             	mov    %eax,0x14(%ebp)
  8007f9:	eb 9e                	jmp    800799 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8007fb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007fe:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800801:	b8 0a 00 00 00       	mov    $0xa,%eax
  800806:	e9 c6 00 00 00       	jmp    8008d1 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80080b:	83 f9 01             	cmp    $0x1,%ecx
  80080e:	7e 18                	jle    800828 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  800810:	8b 45 14             	mov    0x14(%ebp),%eax
  800813:	8b 10                	mov    (%eax),%edx
  800815:	8b 48 04             	mov    0x4(%eax),%ecx
  800818:	8d 40 08             	lea    0x8(%eax),%eax
  80081b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80081e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800823:	e9 a9 00 00 00       	jmp    8008d1 <vprintfmt+0x3bb>
	else if (lflag)
  800828:	85 c9                	test   %ecx,%ecx
  80082a:	75 1a                	jne    800846 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  80082c:	8b 45 14             	mov    0x14(%ebp),%eax
  80082f:	8b 10                	mov    (%eax),%edx
  800831:	b9 00 00 00 00       	mov    $0x0,%ecx
  800836:	8d 40 04             	lea    0x4(%eax),%eax
  800839:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80083c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800841:	e9 8b 00 00 00       	jmp    8008d1 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800846:	8b 45 14             	mov    0x14(%ebp),%eax
  800849:	8b 10                	mov    (%eax),%edx
  80084b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800850:	8d 40 04             	lea    0x4(%eax),%eax
  800853:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800856:	b8 0a 00 00 00       	mov    $0xa,%eax
  80085b:	eb 74                	jmp    8008d1 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80085d:	83 f9 01             	cmp    $0x1,%ecx
  800860:	7e 15                	jle    800877 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800862:	8b 45 14             	mov    0x14(%ebp),%eax
  800865:	8b 10                	mov    (%eax),%edx
  800867:	8b 48 04             	mov    0x4(%eax),%ecx
  80086a:	8d 40 08             	lea    0x8(%eax),%eax
  80086d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800870:	b8 08 00 00 00       	mov    $0x8,%eax
  800875:	eb 5a                	jmp    8008d1 <vprintfmt+0x3bb>
	else if (lflag)
  800877:	85 c9                	test   %ecx,%ecx
  800879:	75 17                	jne    800892 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80087b:	8b 45 14             	mov    0x14(%ebp),%eax
  80087e:	8b 10                	mov    (%eax),%edx
  800880:	b9 00 00 00 00       	mov    $0x0,%ecx
  800885:	8d 40 04             	lea    0x4(%eax),%eax
  800888:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80088b:	b8 08 00 00 00       	mov    $0x8,%eax
  800890:	eb 3f                	jmp    8008d1 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800892:	8b 45 14             	mov    0x14(%ebp),%eax
  800895:	8b 10                	mov    (%eax),%edx
  800897:	b9 00 00 00 00       	mov    $0x0,%ecx
  80089c:	8d 40 04             	lea    0x4(%eax),%eax
  80089f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8008a2:	b8 08 00 00 00       	mov    $0x8,%eax
  8008a7:	eb 28                	jmp    8008d1 <vprintfmt+0x3bb>
			putch('0', putdat);
  8008a9:	83 ec 08             	sub    $0x8,%esp
  8008ac:	53                   	push   %ebx
  8008ad:	6a 30                	push   $0x30
  8008af:	ff d6                	call   *%esi
			putch('x', putdat);
  8008b1:	83 c4 08             	add    $0x8,%esp
  8008b4:	53                   	push   %ebx
  8008b5:	6a 78                	push   $0x78
  8008b7:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bc:	8b 10                	mov    (%eax),%edx
  8008be:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8008c3:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008c6:	8d 40 04             	lea    0x4(%eax),%eax
  8008c9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008cc:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008d1:	83 ec 0c             	sub    $0xc,%esp
  8008d4:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008d8:	57                   	push   %edi
  8008d9:	ff 75 e0             	pushl  -0x20(%ebp)
  8008dc:	50                   	push   %eax
  8008dd:	51                   	push   %ecx
  8008de:	52                   	push   %edx
  8008df:	89 da                	mov    %ebx,%edx
  8008e1:	89 f0                	mov    %esi,%eax
  8008e3:	e8 45 fb ff ff       	call   80042d <printnum>
			break;
  8008e8:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8008eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008ee:	83 c7 01             	add    $0x1,%edi
  8008f1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008f5:	83 f8 25             	cmp    $0x25,%eax
  8008f8:	0f 84 2f fc ff ff    	je     80052d <vprintfmt+0x17>
			if (ch == '\0')
  8008fe:	85 c0                	test   %eax,%eax
  800900:	0f 84 8b 00 00 00    	je     800991 <vprintfmt+0x47b>
			putch(ch, putdat);
  800906:	83 ec 08             	sub    $0x8,%esp
  800909:	53                   	push   %ebx
  80090a:	50                   	push   %eax
  80090b:	ff d6                	call   *%esi
  80090d:	83 c4 10             	add    $0x10,%esp
  800910:	eb dc                	jmp    8008ee <vprintfmt+0x3d8>
	if (lflag >= 2)
  800912:	83 f9 01             	cmp    $0x1,%ecx
  800915:	7e 15                	jle    80092c <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800917:	8b 45 14             	mov    0x14(%ebp),%eax
  80091a:	8b 10                	mov    (%eax),%edx
  80091c:	8b 48 04             	mov    0x4(%eax),%ecx
  80091f:	8d 40 08             	lea    0x8(%eax),%eax
  800922:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800925:	b8 10 00 00 00       	mov    $0x10,%eax
  80092a:	eb a5                	jmp    8008d1 <vprintfmt+0x3bb>
	else if (lflag)
  80092c:	85 c9                	test   %ecx,%ecx
  80092e:	75 17                	jne    800947 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  800930:	8b 45 14             	mov    0x14(%ebp),%eax
  800933:	8b 10                	mov    (%eax),%edx
  800935:	b9 00 00 00 00       	mov    $0x0,%ecx
  80093a:	8d 40 04             	lea    0x4(%eax),%eax
  80093d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800940:	b8 10 00 00 00       	mov    $0x10,%eax
  800945:	eb 8a                	jmp    8008d1 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800947:	8b 45 14             	mov    0x14(%ebp),%eax
  80094a:	8b 10                	mov    (%eax),%edx
  80094c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800951:	8d 40 04             	lea    0x4(%eax),%eax
  800954:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800957:	b8 10 00 00 00       	mov    $0x10,%eax
  80095c:	e9 70 ff ff ff       	jmp    8008d1 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800961:	83 ec 08             	sub    $0x8,%esp
  800964:	53                   	push   %ebx
  800965:	6a 25                	push   $0x25
  800967:	ff d6                	call   *%esi
			break;
  800969:	83 c4 10             	add    $0x10,%esp
  80096c:	e9 7a ff ff ff       	jmp    8008eb <vprintfmt+0x3d5>
			putch('%', putdat);
  800971:	83 ec 08             	sub    $0x8,%esp
  800974:	53                   	push   %ebx
  800975:	6a 25                	push   $0x25
  800977:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800979:	83 c4 10             	add    $0x10,%esp
  80097c:	89 f8                	mov    %edi,%eax
  80097e:	eb 03                	jmp    800983 <vprintfmt+0x46d>
  800980:	83 e8 01             	sub    $0x1,%eax
  800983:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800987:	75 f7                	jne    800980 <vprintfmt+0x46a>
  800989:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80098c:	e9 5a ff ff ff       	jmp    8008eb <vprintfmt+0x3d5>
}
  800991:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800994:	5b                   	pop    %ebx
  800995:	5e                   	pop    %esi
  800996:	5f                   	pop    %edi
  800997:	5d                   	pop    %ebp
  800998:	c3                   	ret    

00800999 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	83 ec 18             	sub    $0x18,%esp
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009a8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009ac:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009b6:	85 c0                	test   %eax,%eax
  8009b8:	74 26                	je     8009e0 <vsnprintf+0x47>
  8009ba:	85 d2                	test   %edx,%edx
  8009bc:	7e 22                	jle    8009e0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009be:	ff 75 14             	pushl  0x14(%ebp)
  8009c1:	ff 75 10             	pushl  0x10(%ebp)
  8009c4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009c7:	50                   	push   %eax
  8009c8:	68 dc 04 80 00       	push   $0x8004dc
  8009cd:	e8 44 fb ff ff       	call   800516 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009d5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009db:	83 c4 10             	add    $0x10,%esp
}
  8009de:	c9                   	leave  
  8009df:	c3                   	ret    
		return -E_INVAL;
  8009e0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009e5:	eb f7                	jmp    8009de <vsnprintf+0x45>

008009e7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009ed:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009f0:	50                   	push   %eax
  8009f1:	ff 75 10             	pushl  0x10(%ebp)
  8009f4:	ff 75 0c             	pushl  0xc(%ebp)
  8009f7:	ff 75 08             	pushl  0x8(%ebp)
  8009fa:	e8 9a ff ff ff       	call   800999 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009ff:	c9                   	leave  
  800a00:	c3                   	ret    

00800a01 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
  800a04:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a07:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0c:	eb 03                	jmp    800a11 <strlen+0x10>
		n++;
  800a0e:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800a11:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a15:	75 f7                	jne    800a0e <strlen+0xd>
	return n;
}
  800a17:	5d                   	pop    %ebp
  800a18:	c3                   	ret    

00800a19 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
  800a1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a22:	b8 00 00 00 00       	mov    $0x0,%eax
  800a27:	eb 03                	jmp    800a2c <strnlen+0x13>
		n++;
  800a29:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a2c:	39 d0                	cmp    %edx,%eax
  800a2e:	74 06                	je     800a36 <strnlen+0x1d>
  800a30:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a34:	75 f3                	jne    800a29 <strnlen+0x10>
	return n;
}
  800a36:	5d                   	pop    %ebp
  800a37:	c3                   	ret    

00800a38 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	53                   	push   %ebx
  800a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a42:	89 c2                	mov    %eax,%edx
  800a44:	83 c1 01             	add    $0x1,%ecx
  800a47:	83 c2 01             	add    $0x1,%edx
  800a4a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a4e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a51:	84 db                	test   %bl,%bl
  800a53:	75 ef                	jne    800a44 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a55:	5b                   	pop    %ebx
  800a56:	5d                   	pop    %ebp
  800a57:	c3                   	ret    

00800a58 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a58:	55                   	push   %ebp
  800a59:	89 e5                	mov    %esp,%ebp
  800a5b:	53                   	push   %ebx
  800a5c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a5f:	53                   	push   %ebx
  800a60:	e8 9c ff ff ff       	call   800a01 <strlen>
  800a65:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a68:	ff 75 0c             	pushl  0xc(%ebp)
  800a6b:	01 d8                	add    %ebx,%eax
  800a6d:	50                   	push   %eax
  800a6e:	e8 c5 ff ff ff       	call   800a38 <strcpy>
	return dst;
}
  800a73:	89 d8                	mov    %ebx,%eax
  800a75:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a78:	c9                   	leave  
  800a79:	c3                   	ret    

00800a7a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	56                   	push   %esi
  800a7e:	53                   	push   %ebx
  800a7f:	8b 75 08             	mov    0x8(%ebp),%esi
  800a82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a85:	89 f3                	mov    %esi,%ebx
  800a87:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a8a:	89 f2                	mov    %esi,%edx
  800a8c:	eb 0f                	jmp    800a9d <strncpy+0x23>
		*dst++ = *src;
  800a8e:	83 c2 01             	add    $0x1,%edx
  800a91:	0f b6 01             	movzbl (%ecx),%eax
  800a94:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a97:	80 39 01             	cmpb   $0x1,(%ecx)
  800a9a:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800a9d:	39 da                	cmp    %ebx,%edx
  800a9f:	75 ed                	jne    800a8e <strncpy+0x14>
	}
	return ret;
}
  800aa1:	89 f0                	mov    %esi,%eax
  800aa3:	5b                   	pop    %ebx
  800aa4:	5e                   	pop    %esi
  800aa5:	5d                   	pop    %ebp
  800aa6:	c3                   	ret    

00800aa7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	56                   	push   %esi
  800aab:	53                   	push   %ebx
  800aac:	8b 75 08             	mov    0x8(%ebp),%esi
  800aaf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ab5:	89 f0                	mov    %esi,%eax
  800ab7:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800abb:	85 c9                	test   %ecx,%ecx
  800abd:	75 0b                	jne    800aca <strlcpy+0x23>
  800abf:	eb 17                	jmp    800ad8 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ac1:	83 c2 01             	add    $0x1,%edx
  800ac4:	83 c0 01             	add    $0x1,%eax
  800ac7:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800aca:	39 d8                	cmp    %ebx,%eax
  800acc:	74 07                	je     800ad5 <strlcpy+0x2e>
  800ace:	0f b6 0a             	movzbl (%edx),%ecx
  800ad1:	84 c9                	test   %cl,%cl
  800ad3:	75 ec                	jne    800ac1 <strlcpy+0x1a>
		*dst = '\0';
  800ad5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ad8:	29 f0                	sub    %esi,%eax
}
  800ada:	5b                   	pop    %ebx
  800adb:	5e                   	pop    %esi
  800adc:	5d                   	pop    %ebp
  800add:	c3                   	ret    

00800ade <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ae7:	eb 06                	jmp    800aef <strcmp+0x11>
		p++, q++;
  800ae9:	83 c1 01             	add    $0x1,%ecx
  800aec:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800aef:	0f b6 01             	movzbl (%ecx),%eax
  800af2:	84 c0                	test   %al,%al
  800af4:	74 04                	je     800afa <strcmp+0x1c>
  800af6:	3a 02                	cmp    (%edx),%al
  800af8:	74 ef                	je     800ae9 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800afa:	0f b6 c0             	movzbl %al,%eax
  800afd:	0f b6 12             	movzbl (%edx),%edx
  800b00:	29 d0                	sub    %edx,%eax
}
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	53                   	push   %ebx
  800b08:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b0e:	89 c3                	mov    %eax,%ebx
  800b10:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b13:	eb 06                	jmp    800b1b <strncmp+0x17>
		n--, p++, q++;
  800b15:	83 c0 01             	add    $0x1,%eax
  800b18:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b1b:	39 d8                	cmp    %ebx,%eax
  800b1d:	74 16                	je     800b35 <strncmp+0x31>
  800b1f:	0f b6 08             	movzbl (%eax),%ecx
  800b22:	84 c9                	test   %cl,%cl
  800b24:	74 04                	je     800b2a <strncmp+0x26>
  800b26:	3a 0a                	cmp    (%edx),%cl
  800b28:	74 eb                	je     800b15 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b2a:	0f b6 00             	movzbl (%eax),%eax
  800b2d:	0f b6 12             	movzbl (%edx),%edx
  800b30:	29 d0                	sub    %edx,%eax
}
  800b32:	5b                   	pop    %ebx
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    
		return 0;
  800b35:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3a:	eb f6                	jmp    800b32 <strncmp+0x2e>

00800b3c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b42:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b46:	0f b6 10             	movzbl (%eax),%edx
  800b49:	84 d2                	test   %dl,%dl
  800b4b:	74 09                	je     800b56 <strchr+0x1a>
		if (*s == c)
  800b4d:	38 ca                	cmp    %cl,%dl
  800b4f:	74 0a                	je     800b5b <strchr+0x1f>
	for (; *s; s++)
  800b51:	83 c0 01             	add    $0x1,%eax
  800b54:	eb f0                	jmp    800b46 <strchr+0xa>
			return (char *) s;
	return 0;
  800b56:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	8b 45 08             	mov    0x8(%ebp),%eax
  800b63:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b67:	eb 03                	jmp    800b6c <strfind+0xf>
  800b69:	83 c0 01             	add    $0x1,%eax
  800b6c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b6f:	38 ca                	cmp    %cl,%dl
  800b71:	74 04                	je     800b77 <strfind+0x1a>
  800b73:	84 d2                	test   %dl,%dl
  800b75:	75 f2                	jne    800b69 <strfind+0xc>
			break;
	return (char *) s;
}
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    

00800b79 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	57                   	push   %edi
  800b7d:	56                   	push   %esi
  800b7e:	53                   	push   %ebx
  800b7f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b82:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b85:	85 c9                	test   %ecx,%ecx
  800b87:	74 13                	je     800b9c <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b89:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b8f:	75 05                	jne    800b96 <memset+0x1d>
  800b91:	f6 c1 03             	test   $0x3,%cl
  800b94:	74 0d                	je     800ba3 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b96:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b99:	fc                   	cld    
  800b9a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b9c:	89 f8                	mov    %edi,%eax
  800b9e:	5b                   	pop    %ebx
  800b9f:	5e                   	pop    %esi
  800ba0:	5f                   	pop    %edi
  800ba1:	5d                   	pop    %ebp
  800ba2:	c3                   	ret    
		c &= 0xFF;
  800ba3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ba7:	89 d3                	mov    %edx,%ebx
  800ba9:	c1 e3 08             	shl    $0x8,%ebx
  800bac:	89 d0                	mov    %edx,%eax
  800bae:	c1 e0 18             	shl    $0x18,%eax
  800bb1:	89 d6                	mov    %edx,%esi
  800bb3:	c1 e6 10             	shl    $0x10,%esi
  800bb6:	09 f0                	or     %esi,%eax
  800bb8:	09 c2                	or     %eax,%edx
  800bba:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800bbc:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800bbf:	89 d0                	mov    %edx,%eax
  800bc1:	fc                   	cld    
  800bc2:	f3 ab                	rep stos %eax,%es:(%edi)
  800bc4:	eb d6                	jmp    800b9c <memset+0x23>

00800bc6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	57                   	push   %edi
  800bca:	56                   	push   %esi
  800bcb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bce:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bd1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bd4:	39 c6                	cmp    %eax,%esi
  800bd6:	73 35                	jae    800c0d <memmove+0x47>
  800bd8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bdb:	39 c2                	cmp    %eax,%edx
  800bdd:	76 2e                	jbe    800c0d <memmove+0x47>
		s += n;
		d += n;
  800bdf:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800be2:	89 d6                	mov    %edx,%esi
  800be4:	09 fe                	or     %edi,%esi
  800be6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bec:	74 0c                	je     800bfa <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bee:	83 ef 01             	sub    $0x1,%edi
  800bf1:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800bf4:	fd                   	std    
  800bf5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bf7:	fc                   	cld    
  800bf8:	eb 21                	jmp    800c1b <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bfa:	f6 c1 03             	test   $0x3,%cl
  800bfd:	75 ef                	jne    800bee <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bff:	83 ef 04             	sub    $0x4,%edi
  800c02:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c05:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c08:	fd                   	std    
  800c09:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c0b:	eb ea                	jmp    800bf7 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c0d:	89 f2                	mov    %esi,%edx
  800c0f:	09 c2                	or     %eax,%edx
  800c11:	f6 c2 03             	test   $0x3,%dl
  800c14:	74 09                	je     800c1f <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c16:	89 c7                	mov    %eax,%edi
  800c18:	fc                   	cld    
  800c19:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c1b:	5e                   	pop    %esi
  800c1c:	5f                   	pop    %edi
  800c1d:	5d                   	pop    %ebp
  800c1e:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c1f:	f6 c1 03             	test   $0x3,%cl
  800c22:	75 f2                	jne    800c16 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c24:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c27:	89 c7                	mov    %eax,%edi
  800c29:	fc                   	cld    
  800c2a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c2c:	eb ed                	jmp    800c1b <memmove+0x55>

00800c2e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c31:	ff 75 10             	pushl  0x10(%ebp)
  800c34:	ff 75 0c             	pushl  0xc(%ebp)
  800c37:	ff 75 08             	pushl  0x8(%ebp)
  800c3a:	e8 87 ff ff ff       	call   800bc6 <memmove>
}
  800c3f:	c9                   	leave  
  800c40:	c3                   	ret    

00800c41 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	56                   	push   %esi
  800c45:	53                   	push   %ebx
  800c46:	8b 45 08             	mov    0x8(%ebp),%eax
  800c49:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c4c:	89 c6                	mov    %eax,%esi
  800c4e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c51:	39 f0                	cmp    %esi,%eax
  800c53:	74 1c                	je     800c71 <memcmp+0x30>
		if (*s1 != *s2)
  800c55:	0f b6 08             	movzbl (%eax),%ecx
  800c58:	0f b6 1a             	movzbl (%edx),%ebx
  800c5b:	38 d9                	cmp    %bl,%cl
  800c5d:	75 08                	jne    800c67 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c5f:	83 c0 01             	add    $0x1,%eax
  800c62:	83 c2 01             	add    $0x1,%edx
  800c65:	eb ea                	jmp    800c51 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800c67:	0f b6 c1             	movzbl %cl,%eax
  800c6a:	0f b6 db             	movzbl %bl,%ebx
  800c6d:	29 d8                	sub    %ebx,%eax
  800c6f:	eb 05                	jmp    800c76 <memcmp+0x35>
	}

	return 0;
  800c71:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c76:	5b                   	pop    %ebx
  800c77:	5e                   	pop    %esi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c83:	89 c2                	mov    %eax,%edx
  800c85:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c88:	39 d0                	cmp    %edx,%eax
  800c8a:	73 09                	jae    800c95 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c8c:	38 08                	cmp    %cl,(%eax)
  800c8e:	74 05                	je     800c95 <memfind+0x1b>
	for (; s < ends; s++)
  800c90:	83 c0 01             	add    $0x1,%eax
  800c93:	eb f3                	jmp    800c88 <memfind+0xe>
			break;
	return (void *) s;
}
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	57                   	push   %edi
  800c9b:	56                   	push   %esi
  800c9c:	53                   	push   %ebx
  800c9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ca3:	eb 03                	jmp    800ca8 <strtol+0x11>
		s++;
  800ca5:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ca8:	0f b6 01             	movzbl (%ecx),%eax
  800cab:	3c 20                	cmp    $0x20,%al
  800cad:	74 f6                	je     800ca5 <strtol+0xe>
  800caf:	3c 09                	cmp    $0x9,%al
  800cb1:	74 f2                	je     800ca5 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800cb3:	3c 2b                	cmp    $0x2b,%al
  800cb5:	74 2e                	je     800ce5 <strtol+0x4e>
	int neg = 0;
  800cb7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800cbc:	3c 2d                	cmp    $0x2d,%al
  800cbe:	74 2f                	je     800cef <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cc0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800cc6:	75 05                	jne    800ccd <strtol+0x36>
  800cc8:	80 39 30             	cmpb   $0x30,(%ecx)
  800ccb:	74 2c                	je     800cf9 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ccd:	85 db                	test   %ebx,%ebx
  800ccf:	75 0a                	jne    800cdb <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cd1:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800cd6:	80 39 30             	cmpb   $0x30,(%ecx)
  800cd9:	74 28                	je     800d03 <strtol+0x6c>
		base = 10;
  800cdb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce0:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ce3:	eb 50                	jmp    800d35 <strtol+0x9e>
		s++;
  800ce5:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ce8:	bf 00 00 00 00       	mov    $0x0,%edi
  800ced:	eb d1                	jmp    800cc0 <strtol+0x29>
		s++, neg = 1;
  800cef:	83 c1 01             	add    $0x1,%ecx
  800cf2:	bf 01 00 00 00       	mov    $0x1,%edi
  800cf7:	eb c7                	jmp    800cc0 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cf9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cfd:	74 0e                	je     800d0d <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800cff:	85 db                	test   %ebx,%ebx
  800d01:	75 d8                	jne    800cdb <strtol+0x44>
		s++, base = 8;
  800d03:	83 c1 01             	add    $0x1,%ecx
  800d06:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d0b:	eb ce                	jmp    800cdb <strtol+0x44>
		s += 2, base = 16;
  800d0d:	83 c1 02             	add    $0x2,%ecx
  800d10:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d15:	eb c4                	jmp    800cdb <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800d17:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d1a:	89 f3                	mov    %esi,%ebx
  800d1c:	80 fb 19             	cmp    $0x19,%bl
  800d1f:	77 29                	ja     800d4a <strtol+0xb3>
			dig = *s - 'a' + 10;
  800d21:	0f be d2             	movsbl %dl,%edx
  800d24:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d27:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d2a:	7d 30                	jge    800d5c <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d2c:	83 c1 01             	add    $0x1,%ecx
  800d2f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d33:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d35:	0f b6 11             	movzbl (%ecx),%edx
  800d38:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d3b:	89 f3                	mov    %esi,%ebx
  800d3d:	80 fb 09             	cmp    $0x9,%bl
  800d40:	77 d5                	ja     800d17 <strtol+0x80>
			dig = *s - '0';
  800d42:	0f be d2             	movsbl %dl,%edx
  800d45:	83 ea 30             	sub    $0x30,%edx
  800d48:	eb dd                	jmp    800d27 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800d4a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d4d:	89 f3                	mov    %esi,%ebx
  800d4f:	80 fb 19             	cmp    $0x19,%bl
  800d52:	77 08                	ja     800d5c <strtol+0xc5>
			dig = *s - 'A' + 10;
  800d54:	0f be d2             	movsbl %dl,%edx
  800d57:	83 ea 37             	sub    $0x37,%edx
  800d5a:	eb cb                	jmp    800d27 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d5c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d60:	74 05                	je     800d67 <strtol+0xd0>
		*endptr = (char *) s;
  800d62:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d65:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800d67:	89 c2                	mov    %eax,%edx
  800d69:	f7 da                	neg    %edx
  800d6b:	85 ff                	test   %edi,%edi
  800d6d:	0f 45 c2             	cmovne %edx,%eax
}
  800d70:	5b                   	pop    %ebx
  800d71:	5e                   	pop    %esi
  800d72:	5f                   	pop    %edi
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    

00800d75 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d7b:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d82:	74 0a                	je     800d8e <set_pgfault_handler+0x19>
			panic("set_pgfault_handler %e",r);
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
	}
       
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d84:	8b 45 08             	mov    0x8(%ebp),%eax
  800d87:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800d8c:	c9                   	leave  
  800d8d:	c3                   	ret    
		if((r=sys_page_alloc(thisenv->env_id,(void *)UXSTACKTOP-PGSIZE,PTE_P|PTE_W|PTE_U))<0)
  800d8e:	a1 04 20 80 00       	mov    0x802004,%eax
  800d93:	8b 40 48             	mov    0x48(%eax),%eax
  800d96:	83 ec 04             	sub    $0x4,%esp
  800d99:	6a 07                	push   $0x7
  800d9b:	68 00 f0 bf ee       	push   $0xeebff000
  800da0:	50                   	push   %eax
  800da1:	e8 c2 f3 ff ff       	call   800168 <sys_page_alloc>
  800da6:	83 c4 10             	add    $0x10,%esp
  800da9:	85 c0                	test   %eax,%eax
  800dab:	78 1b                	js     800dc8 <set_pgfault_handler+0x53>
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
  800dad:	a1 04 20 80 00       	mov    0x802004,%eax
  800db2:	8b 40 48             	mov    0x48(%eax),%eax
  800db5:	83 ec 08             	sub    $0x8,%esp
  800db8:	68 17 03 80 00       	push   $0x800317
  800dbd:	50                   	push   %eax
  800dbe:	e8 ae f4 ff ff       	call   800271 <sys_env_set_pgfault_upcall>
  800dc3:	83 c4 10             	add    $0x10,%esp
  800dc6:	eb bc                	jmp    800d84 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler %e",r);
  800dc8:	50                   	push   %eax
  800dc9:	68 c4 12 80 00       	push   $0x8012c4
  800dce:	6a 22                	push   $0x22
  800dd0:	68 db 12 80 00       	push   $0x8012db
  800dd5:	e8 64 f5 ff ff       	call   80033e <_panic>
  800dda:	66 90                	xchg   %ax,%ax
  800ddc:	66 90                	xchg   %ax,%ax
  800dde:	66 90                	xchg   %ax,%ax

00800de0 <__udivdi3>:
  800de0:	55                   	push   %ebp
  800de1:	57                   	push   %edi
  800de2:	56                   	push   %esi
  800de3:	53                   	push   %ebx
  800de4:	83 ec 1c             	sub    $0x1c,%esp
  800de7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800deb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800def:	8b 74 24 34          	mov    0x34(%esp),%esi
  800df3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800df7:	85 d2                	test   %edx,%edx
  800df9:	75 35                	jne    800e30 <__udivdi3+0x50>
  800dfb:	39 f3                	cmp    %esi,%ebx
  800dfd:	0f 87 bd 00 00 00    	ja     800ec0 <__udivdi3+0xe0>
  800e03:	85 db                	test   %ebx,%ebx
  800e05:	89 d9                	mov    %ebx,%ecx
  800e07:	75 0b                	jne    800e14 <__udivdi3+0x34>
  800e09:	b8 01 00 00 00       	mov    $0x1,%eax
  800e0e:	31 d2                	xor    %edx,%edx
  800e10:	f7 f3                	div    %ebx
  800e12:	89 c1                	mov    %eax,%ecx
  800e14:	31 d2                	xor    %edx,%edx
  800e16:	89 f0                	mov    %esi,%eax
  800e18:	f7 f1                	div    %ecx
  800e1a:	89 c6                	mov    %eax,%esi
  800e1c:	89 e8                	mov    %ebp,%eax
  800e1e:	89 f7                	mov    %esi,%edi
  800e20:	f7 f1                	div    %ecx
  800e22:	89 fa                	mov    %edi,%edx
  800e24:	83 c4 1c             	add    $0x1c,%esp
  800e27:	5b                   	pop    %ebx
  800e28:	5e                   	pop    %esi
  800e29:	5f                   	pop    %edi
  800e2a:	5d                   	pop    %ebp
  800e2b:	c3                   	ret    
  800e2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e30:	39 f2                	cmp    %esi,%edx
  800e32:	77 7c                	ja     800eb0 <__udivdi3+0xd0>
  800e34:	0f bd fa             	bsr    %edx,%edi
  800e37:	83 f7 1f             	xor    $0x1f,%edi
  800e3a:	0f 84 98 00 00 00    	je     800ed8 <__udivdi3+0xf8>
  800e40:	89 f9                	mov    %edi,%ecx
  800e42:	b8 20 00 00 00       	mov    $0x20,%eax
  800e47:	29 f8                	sub    %edi,%eax
  800e49:	d3 e2                	shl    %cl,%edx
  800e4b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e4f:	89 c1                	mov    %eax,%ecx
  800e51:	89 da                	mov    %ebx,%edx
  800e53:	d3 ea                	shr    %cl,%edx
  800e55:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e59:	09 d1                	or     %edx,%ecx
  800e5b:	89 f2                	mov    %esi,%edx
  800e5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e61:	89 f9                	mov    %edi,%ecx
  800e63:	d3 e3                	shl    %cl,%ebx
  800e65:	89 c1                	mov    %eax,%ecx
  800e67:	d3 ea                	shr    %cl,%edx
  800e69:	89 f9                	mov    %edi,%ecx
  800e6b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e6f:	d3 e6                	shl    %cl,%esi
  800e71:	89 eb                	mov    %ebp,%ebx
  800e73:	89 c1                	mov    %eax,%ecx
  800e75:	d3 eb                	shr    %cl,%ebx
  800e77:	09 de                	or     %ebx,%esi
  800e79:	89 f0                	mov    %esi,%eax
  800e7b:	f7 74 24 08          	divl   0x8(%esp)
  800e7f:	89 d6                	mov    %edx,%esi
  800e81:	89 c3                	mov    %eax,%ebx
  800e83:	f7 64 24 0c          	mull   0xc(%esp)
  800e87:	39 d6                	cmp    %edx,%esi
  800e89:	72 0c                	jb     800e97 <__udivdi3+0xb7>
  800e8b:	89 f9                	mov    %edi,%ecx
  800e8d:	d3 e5                	shl    %cl,%ebp
  800e8f:	39 c5                	cmp    %eax,%ebp
  800e91:	73 5d                	jae    800ef0 <__udivdi3+0x110>
  800e93:	39 d6                	cmp    %edx,%esi
  800e95:	75 59                	jne    800ef0 <__udivdi3+0x110>
  800e97:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800e9a:	31 ff                	xor    %edi,%edi
  800e9c:	89 fa                	mov    %edi,%edx
  800e9e:	83 c4 1c             	add    $0x1c,%esp
  800ea1:	5b                   	pop    %ebx
  800ea2:	5e                   	pop    %esi
  800ea3:	5f                   	pop    %edi
  800ea4:	5d                   	pop    %ebp
  800ea5:	c3                   	ret    
  800ea6:	8d 76 00             	lea    0x0(%esi),%esi
  800ea9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800eb0:	31 ff                	xor    %edi,%edi
  800eb2:	31 c0                	xor    %eax,%eax
  800eb4:	89 fa                	mov    %edi,%edx
  800eb6:	83 c4 1c             	add    $0x1c,%esp
  800eb9:	5b                   	pop    %ebx
  800eba:	5e                   	pop    %esi
  800ebb:	5f                   	pop    %edi
  800ebc:	5d                   	pop    %ebp
  800ebd:	c3                   	ret    
  800ebe:	66 90                	xchg   %ax,%ax
  800ec0:	31 ff                	xor    %edi,%edi
  800ec2:	89 e8                	mov    %ebp,%eax
  800ec4:	89 f2                	mov    %esi,%edx
  800ec6:	f7 f3                	div    %ebx
  800ec8:	89 fa                	mov    %edi,%edx
  800eca:	83 c4 1c             	add    $0x1c,%esp
  800ecd:	5b                   	pop    %ebx
  800ece:	5e                   	pop    %esi
  800ecf:	5f                   	pop    %edi
  800ed0:	5d                   	pop    %ebp
  800ed1:	c3                   	ret    
  800ed2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ed8:	39 f2                	cmp    %esi,%edx
  800eda:	72 06                	jb     800ee2 <__udivdi3+0x102>
  800edc:	31 c0                	xor    %eax,%eax
  800ede:	39 eb                	cmp    %ebp,%ebx
  800ee0:	77 d2                	ja     800eb4 <__udivdi3+0xd4>
  800ee2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ee7:	eb cb                	jmp    800eb4 <__udivdi3+0xd4>
  800ee9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ef0:	89 d8                	mov    %ebx,%eax
  800ef2:	31 ff                	xor    %edi,%edi
  800ef4:	eb be                	jmp    800eb4 <__udivdi3+0xd4>
  800ef6:	66 90                	xchg   %ax,%ax
  800ef8:	66 90                	xchg   %ax,%ax
  800efa:	66 90                	xchg   %ax,%ax
  800efc:	66 90                	xchg   %ax,%ax
  800efe:	66 90                	xchg   %ax,%ax

00800f00 <__umoddi3>:
  800f00:	55                   	push   %ebp
  800f01:	57                   	push   %edi
  800f02:	56                   	push   %esi
  800f03:	53                   	push   %ebx
  800f04:	83 ec 1c             	sub    $0x1c,%esp
  800f07:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800f0b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f0f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f17:	85 ed                	test   %ebp,%ebp
  800f19:	89 f0                	mov    %esi,%eax
  800f1b:	89 da                	mov    %ebx,%edx
  800f1d:	75 19                	jne    800f38 <__umoddi3+0x38>
  800f1f:	39 df                	cmp    %ebx,%edi
  800f21:	0f 86 b1 00 00 00    	jbe    800fd8 <__umoddi3+0xd8>
  800f27:	f7 f7                	div    %edi
  800f29:	89 d0                	mov    %edx,%eax
  800f2b:	31 d2                	xor    %edx,%edx
  800f2d:	83 c4 1c             	add    $0x1c,%esp
  800f30:	5b                   	pop    %ebx
  800f31:	5e                   	pop    %esi
  800f32:	5f                   	pop    %edi
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    
  800f35:	8d 76 00             	lea    0x0(%esi),%esi
  800f38:	39 dd                	cmp    %ebx,%ebp
  800f3a:	77 f1                	ja     800f2d <__umoddi3+0x2d>
  800f3c:	0f bd cd             	bsr    %ebp,%ecx
  800f3f:	83 f1 1f             	xor    $0x1f,%ecx
  800f42:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f46:	0f 84 b4 00 00 00    	je     801000 <__umoddi3+0x100>
  800f4c:	b8 20 00 00 00       	mov    $0x20,%eax
  800f51:	89 c2                	mov    %eax,%edx
  800f53:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f57:	29 c2                	sub    %eax,%edx
  800f59:	89 c1                	mov    %eax,%ecx
  800f5b:	89 f8                	mov    %edi,%eax
  800f5d:	d3 e5                	shl    %cl,%ebp
  800f5f:	89 d1                	mov    %edx,%ecx
  800f61:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f65:	d3 e8                	shr    %cl,%eax
  800f67:	09 c5                	or     %eax,%ebp
  800f69:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f6d:	89 c1                	mov    %eax,%ecx
  800f6f:	d3 e7                	shl    %cl,%edi
  800f71:	89 d1                	mov    %edx,%ecx
  800f73:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f77:	89 df                	mov    %ebx,%edi
  800f79:	d3 ef                	shr    %cl,%edi
  800f7b:	89 c1                	mov    %eax,%ecx
  800f7d:	89 f0                	mov    %esi,%eax
  800f7f:	d3 e3                	shl    %cl,%ebx
  800f81:	89 d1                	mov    %edx,%ecx
  800f83:	89 fa                	mov    %edi,%edx
  800f85:	d3 e8                	shr    %cl,%eax
  800f87:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f8c:	09 d8                	or     %ebx,%eax
  800f8e:	f7 f5                	div    %ebp
  800f90:	d3 e6                	shl    %cl,%esi
  800f92:	89 d1                	mov    %edx,%ecx
  800f94:	f7 64 24 08          	mull   0x8(%esp)
  800f98:	39 d1                	cmp    %edx,%ecx
  800f9a:	89 c3                	mov    %eax,%ebx
  800f9c:	89 d7                	mov    %edx,%edi
  800f9e:	72 06                	jb     800fa6 <__umoddi3+0xa6>
  800fa0:	75 0e                	jne    800fb0 <__umoddi3+0xb0>
  800fa2:	39 c6                	cmp    %eax,%esi
  800fa4:	73 0a                	jae    800fb0 <__umoddi3+0xb0>
  800fa6:	2b 44 24 08          	sub    0x8(%esp),%eax
  800faa:	19 ea                	sbb    %ebp,%edx
  800fac:	89 d7                	mov    %edx,%edi
  800fae:	89 c3                	mov    %eax,%ebx
  800fb0:	89 ca                	mov    %ecx,%edx
  800fb2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800fb7:	29 de                	sub    %ebx,%esi
  800fb9:	19 fa                	sbb    %edi,%edx
  800fbb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800fbf:	89 d0                	mov    %edx,%eax
  800fc1:	d3 e0                	shl    %cl,%eax
  800fc3:	89 d9                	mov    %ebx,%ecx
  800fc5:	d3 ee                	shr    %cl,%esi
  800fc7:	d3 ea                	shr    %cl,%edx
  800fc9:	09 f0                	or     %esi,%eax
  800fcb:	83 c4 1c             	add    $0x1c,%esp
  800fce:	5b                   	pop    %ebx
  800fcf:	5e                   	pop    %esi
  800fd0:	5f                   	pop    %edi
  800fd1:	5d                   	pop    %ebp
  800fd2:	c3                   	ret    
  800fd3:	90                   	nop
  800fd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fd8:	85 ff                	test   %edi,%edi
  800fda:	89 f9                	mov    %edi,%ecx
  800fdc:	75 0b                	jne    800fe9 <__umoddi3+0xe9>
  800fde:	b8 01 00 00 00       	mov    $0x1,%eax
  800fe3:	31 d2                	xor    %edx,%edx
  800fe5:	f7 f7                	div    %edi
  800fe7:	89 c1                	mov    %eax,%ecx
  800fe9:	89 d8                	mov    %ebx,%eax
  800feb:	31 d2                	xor    %edx,%edx
  800fed:	f7 f1                	div    %ecx
  800fef:	89 f0                	mov    %esi,%eax
  800ff1:	f7 f1                	div    %ecx
  800ff3:	e9 31 ff ff ff       	jmp    800f29 <__umoddi3+0x29>
  800ff8:	90                   	nop
  800ff9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801000:	39 dd                	cmp    %ebx,%ebp
  801002:	72 08                	jb     80100c <__umoddi3+0x10c>
  801004:	39 f7                	cmp    %esi,%edi
  801006:	0f 87 21 ff ff ff    	ja     800f2d <__umoddi3+0x2d>
  80100c:	89 da                	mov    %ebx,%edx
  80100e:	89 f0                	mov    %esi,%eax
  801010:	29 f8                	sub    %edi,%eax
  801012:	19 ea                	sbb    %ebp,%edx
  801014:	e9 14 ff ff ff       	jmp    800f2d <__umoddi3+0x2d>
