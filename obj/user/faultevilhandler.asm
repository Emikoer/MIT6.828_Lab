
obj/user/faultevilhandler.debug:     file format elf32-i386


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
  80002c:	e8 34 00 00 00       	call   800065 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	6a 07                	push   $0x7
  80003b:	68 00 f0 bf ee       	push   $0xeebff000
  800040:	6a 00                	push   $0x0
  800042:	e8 3a 01 00 00       	call   800181 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 20 00 10 f0       	push   $0xf0100020
  80004f:	6a 00                	push   $0x0
  800051:	e8 76 02 00 00       	call   8002cc <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800056:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005d:	00 00 00 
}
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
  800068:	56                   	push   %esi
  800069:	53                   	push   %ebx
  80006a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800070:	e8 ce 00 00 00       	call   800143 <sys_getenvid>
  800075:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800082:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800087:	85 db                	test   %ebx,%ebx
  800089:	7e 07                	jle    800092 <libmain+0x2d>
		binaryname = argv[0];
  80008b:	8b 06                	mov    (%esi),%eax
  80008d:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800092:	83 ec 08             	sub    $0x8,%esp
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
  800097:	e8 97 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009c:	e8 0a 00 00 00       	call   8000ab <exit>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b1:	e8 92 04 00 00       	call   800548 <close_all>
	sys_env_destroy(0);
  8000b6:	83 ec 0c             	sub    $0xc,%esp
  8000b9:	6a 00                	push   $0x0
  8000bb:	e8 42 00 00 00       	call   800102 <sys_env_destroy>
}
  8000c0:	83 c4 10             	add    $0x10,%esp
  8000c3:	c9                   	leave  
  8000c4:	c3                   	ret    

008000c5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	57                   	push   %edi
  8000c9:	56                   	push   %esi
  8000ca:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d6:	89 c3                	mov    %eax,%ebx
  8000d8:	89 c7                	mov    %eax,%edi
  8000da:	89 c6                	mov    %eax,%esi
  8000dc:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f3:	89 d1                	mov    %edx,%ecx
  8000f5:	89 d3                	mov    %edx,%ebx
  8000f7:	89 d7                	mov    %edx,%edi
  8000f9:	89 d6                	mov    %edx,%esi
  8000fb:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fd:	5b                   	pop    %ebx
  8000fe:	5e                   	pop    %esi
  8000ff:	5f                   	pop    %edi
  800100:	5d                   	pop    %ebp
  800101:	c3                   	ret    

00800102 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	57                   	push   %edi
  800106:	56                   	push   %esi
  800107:	53                   	push   %ebx
  800108:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80010b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800110:	8b 55 08             	mov    0x8(%ebp),%edx
  800113:	b8 03 00 00 00       	mov    $0x3,%eax
  800118:	89 cb                	mov    %ecx,%ebx
  80011a:	89 cf                	mov    %ecx,%edi
  80011c:	89 ce                	mov    %ecx,%esi
  80011e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800120:	85 c0                	test   %eax,%eax
  800122:	7f 08                	jg     80012c <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800124:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800127:	5b                   	pop    %ebx
  800128:	5e                   	pop    %esi
  800129:	5f                   	pop    %edi
  80012a:	5d                   	pop    %ebp
  80012b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80012c:	83 ec 0c             	sub    $0xc,%esp
  80012f:	50                   	push   %eax
  800130:	6a 03                	push   $0x3
  800132:	68 0a 1e 80 00       	push   $0x801e0a
  800137:	6a 23                	push   $0x23
  800139:	68 27 1e 80 00       	push   $0x801e27
  80013e:	e8 ea 0e 00 00       	call   80102d <_panic>

00800143 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	asm volatile("int %1\n"
  800149:	ba 00 00 00 00       	mov    $0x0,%edx
  80014e:	b8 02 00 00 00       	mov    $0x2,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_yield>:

void
sys_yield(void)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
	asm volatile("int %1\n"
  800168:	ba 00 00 00 00       	mov    $0x0,%edx
  80016d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800172:	89 d1                	mov    %edx,%ecx
  800174:	89 d3                	mov    %edx,%ebx
  800176:	89 d7                	mov    %edx,%edi
  800178:	89 d6                	mov    %edx,%esi
  80017a:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017c:	5b                   	pop    %ebx
  80017d:	5e                   	pop    %esi
  80017e:	5f                   	pop    %edi
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    

00800181 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	57                   	push   %edi
  800185:	56                   	push   %esi
  800186:	53                   	push   %ebx
  800187:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80018a:	be 00 00 00 00       	mov    $0x0,%esi
  80018f:	8b 55 08             	mov    0x8(%ebp),%edx
  800192:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800195:	b8 04 00 00 00       	mov    $0x4,%eax
  80019a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019d:	89 f7                	mov    %esi,%edi
  80019f:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001a1:	85 c0                	test   %eax,%eax
  8001a3:	7f 08                	jg     8001ad <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a8:	5b                   	pop    %ebx
  8001a9:	5e                   	pop    %esi
  8001aa:	5f                   	pop    %edi
  8001ab:	5d                   	pop    %ebp
  8001ac:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ad:	83 ec 0c             	sub    $0xc,%esp
  8001b0:	50                   	push   %eax
  8001b1:	6a 04                	push   $0x4
  8001b3:	68 0a 1e 80 00       	push   $0x801e0a
  8001b8:	6a 23                	push   $0x23
  8001ba:	68 27 1e 80 00       	push   $0x801e27
  8001bf:	e8 69 0e 00 00       	call   80102d <_panic>

008001c4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	57                   	push   %edi
  8001c8:	56                   	push   %esi
  8001c9:	53                   	push   %ebx
  8001ca:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d3:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001db:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001de:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e1:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001e3:	85 c0                	test   %eax,%eax
  8001e5:	7f 08                	jg     8001ef <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ea:	5b                   	pop    %ebx
  8001eb:	5e                   	pop    %esi
  8001ec:	5f                   	pop    %edi
  8001ed:	5d                   	pop    %ebp
  8001ee:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ef:	83 ec 0c             	sub    $0xc,%esp
  8001f2:	50                   	push   %eax
  8001f3:	6a 05                	push   $0x5
  8001f5:	68 0a 1e 80 00       	push   $0x801e0a
  8001fa:	6a 23                	push   $0x23
  8001fc:	68 27 1e 80 00       	push   $0x801e27
  800201:	e8 27 0e 00 00       	call   80102d <_panic>

00800206 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	57                   	push   %edi
  80020a:	56                   	push   %esi
  80020b:	53                   	push   %ebx
  80020c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80020f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800214:	8b 55 08             	mov    0x8(%ebp),%edx
  800217:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021a:	b8 06 00 00 00       	mov    $0x6,%eax
  80021f:	89 df                	mov    %ebx,%edi
  800221:	89 de                	mov    %ebx,%esi
  800223:	cd 30                	int    $0x30
	if(check && ret > 0)
  800225:	85 c0                	test   %eax,%eax
  800227:	7f 08                	jg     800231 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800229:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022c:	5b                   	pop    %ebx
  80022d:	5e                   	pop    %esi
  80022e:	5f                   	pop    %edi
  80022f:	5d                   	pop    %ebp
  800230:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800231:	83 ec 0c             	sub    $0xc,%esp
  800234:	50                   	push   %eax
  800235:	6a 06                	push   $0x6
  800237:	68 0a 1e 80 00       	push   $0x801e0a
  80023c:	6a 23                	push   $0x23
  80023e:	68 27 1e 80 00       	push   $0x801e27
  800243:	e8 e5 0d 00 00       	call   80102d <_panic>

00800248 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	57                   	push   %edi
  80024c:	56                   	push   %esi
  80024d:	53                   	push   %ebx
  80024e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800251:	bb 00 00 00 00       	mov    $0x0,%ebx
  800256:	8b 55 08             	mov    0x8(%ebp),%edx
  800259:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025c:	b8 08 00 00 00       	mov    $0x8,%eax
  800261:	89 df                	mov    %ebx,%edi
  800263:	89 de                	mov    %ebx,%esi
  800265:	cd 30                	int    $0x30
	if(check && ret > 0)
  800267:	85 c0                	test   %eax,%eax
  800269:	7f 08                	jg     800273 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80026b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5e                   	pop    %esi
  800270:	5f                   	pop    %edi
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800273:	83 ec 0c             	sub    $0xc,%esp
  800276:	50                   	push   %eax
  800277:	6a 08                	push   $0x8
  800279:	68 0a 1e 80 00       	push   $0x801e0a
  80027e:	6a 23                	push   $0x23
  800280:	68 27 1e 80 00       	push   $0x801e27
  800285:	e8 a3 0d 00 00       	call   80102d <_panic>

0080028a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	57                   	push   %edi
  80028e:	56                   	push   %esi
  80028f:	53                   	push   %ebx
  800290:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800293:	bb 00 00 00 00       	mov    $0x0,%ebx
  800298:	8b 55 08             	mov    0x8(%ebp),%edx
  80029b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80029e:	b8 09 00 00 00       	mov    $0x9,%eax
  8002a3:	89 df                	mov    %ebx,%edi
  8002a5:	89 de                	mov    %ebx,%esi
  8002a7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002a9:	85 c0                	test   %eax,%eax
  8002ab:	7f 08                	jg     8002b5 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b0:	5b                   	pop    %ebx
  8002b1:	5e                   	pop    %esi
  8002b2:	5f                   	pop    %edi
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b5:	83 ec 0c             	sub    $0xc,%esp
  8002b8:	50                   	push   %eax
  8002b9:	6a 09                	push   $0x9
  8002bb:	68 0a 1e 80 00       	push   $0x801e0a
  8002c0:	6a 23                	push   $0x23
  8002c2:	68 27 1e 80 00       	push   $0x801e27
  8002c7:	e8 61 0d 00 00       	call   80102d <_panic>

008002cc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	57                   	push   %edi
  8002d0:	56                   	push   %esi
  8002d1:	53                   	push   %ebx
  8002d2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002da:	8b 55 08             	mov    0x8(%ebp),%edx
  8002dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002e5:	89 df                	mov    %ebx,%edi
  8002e7:	89 de                	mov    %ebx,%esi
  8002e9:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002eb:	85 c0                	test   %eax,%eax
  8002ed:	7f 08                	jg     8002f7 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f2:	5b                   	pop    %ebx
  8002f3:	5e                   	pop    %esi
  8002f4:	5f                   	pop    %edi
  8002f5:	5d                   	pop    %ebp
  8002f6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f7:	83 ec 0c             	sub    $0xc,%esp
  8002fa:	50                   	push   %eax
  8002fb:	6a 0a                	push   $0xa
  8002fd:	68 0a 1e 80 00       	push   $0x801e0a
  800302:	6a 23                	push   $0x23
  800304:	68 27 1e 80 00       	push   $0x801e27
  800309:	e8 1f 0d 00 00       	call   80102d <_panic>

0080030e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
	asm volatile("int %1\n"
  800314:	8b 55 08             	mov    0x8(%ebp),%edx
  800317:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80031a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80031f:	be 00 00 00 00       	mov    $0x0,%esi
  800324:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800327:	8b 7d 14             	mov    0x14(%ebp),%edi
  80032a:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80032c:	5b                   	pop    %ebx
  80032d:	5e                   	pop    %esi
  80032e:	5f                   	pop    %edi
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    

00800331 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80033a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033f:	8b 55 08             	mov    0x8(%ebp),%edx
  800342:	b8 0d 00 00 00       	mov    $0xd,%eax
  800347:	89 cb                	mov    %ecx,%ebx
  800349:	89 cf                	mov    %ecx,%edi
  80034b:	89 ce                	mov    %ecx,%esi
  80034d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80034f:	85 c0                	test   %eax,%eax
  800351:	7f 08                	jg     80035b <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800353:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800356:	5b                   	pop    %ebx
  800357:	5e                   	pop    %esi
  800358:	5f                   	pop    %edi
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80035b:	83 ec 0c             	sub    $0xc,%esp
  80035e:	50                   	push   %eax
  80035f:	6a 0d                	push   $0xd
  800361:	68 0a 1e 80 00       	push   $0x801e0a
  800366:	6a 23                	push   $0x23
  800368:	68 27 1e 80 00       	push   $0x801e27
  80036d:	e8 bb 0c 00 00       	call   80102d <_panic>

00800372 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800375:	8b 45 08             	mov    0x8(%ebp),%eax
  800378:	05 00 00 00 30       	add    $0x30000000,%eax
  80037d:	c1 e8 0c             	shr    $0xc,%eax
}
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800385:	8b 45 08             	mov    0x8(%ebp),%eax
  800388:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80038d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800392:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800397:	5d                   	pop    %ebp
  800398:	c3                   	ret    

00800399 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800399:	55                   	push   %ebp
  80039a:	89 e5                	mov    %esp,%ebp
  80039c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80039f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003a4:	89 c2                	mov    %eax,%edx
  8003a6:	c1 ea 16             	shr    $0x16,%edx
  8003a9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003b0:	f6 c2 01             	test   $0x1,%dl
  8003b3:	74 2a                	je     8003df <fd_alloc+0x46>
  8003b5:	89 c2                	mov    %eax,%edx
  8003b7:	c1 ea 0c             	shr    $0xc,%edx
  8003ba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003c1:	f6 c2 01             	test   $0x1,%dl
  8003c4:	74 19                	je     8003df <fd_alloc+0x46>
  8003c6:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8003cb:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003d0:	75 d2                	jne    8003a4 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003d2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003d8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8003dd:	eb 07                	jmp    8003e6 <fd_alloc+0x4d>
			*fd_store = fd;
  8003df:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003e6:	5d                   	pop    %ebp
  8003e7:	c3                   	ret    

008003e8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003ee:	83 f8 1f             	cmp    $0x1f,%eax
  8003f1:	77 36                	ja     800429 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003f3:	c1 e0 0c             	shl    $0xc,%eax
  8003f6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003fb:	89 c2                	mov    %eax,%edx
  8003fd:	c1 ea 16             	shr    $0x16,%edx
  800400:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800407:	f6 c2 01             	test   $0x1,%dl
  80040a:	74 24                	je     800430 <fd_lookup+0x48>
  80040c:	89 c2                	mov    %eax,%edx
  80040e:	c1 ea 0c             	shr    $0xc,%edx
  800411:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800418:	f6 c2 01             	test   $0x1,%dl
  80041b:	74 1a                	je     800437 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80041d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800420:	89 02                	mov    %eax,(%edx)
	return 0;
  800422:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800427:	5d                   	pop    %ebp
  800428:	c3                   	ret    
		return -E_INVAL;
  800429:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80042e:	eb f7                	jmp    800427 <fd_lookup+0x3f>
		return -E_INVAL;
  800430:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800435:	eb f0                	jmp    800427 <fd_lookup+0x3f>
  800437:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80043c:	eb e9                	jmp    800427 <fd_lookup+0x3f>

0080043e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80043e:	55                   	push   %ebp
  80043f:	89 e5                	mov    %esp,%ebp
  800441:	83 ec 08             	sub    $0x8,%esp
  800444:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800447:	ba b4 1e 80 00       	mov    $0x801eb4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80044c:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800451:	39 08                	cmp    %ecx,(%eax)
  800453:	74 33                	je     800488 <dev_lookup+0x4a>
  800455:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800458:	8b 02                	mov    (%edx),%eax
  80045a:	85 c0                	test   %eax,%eax
  80045c:	75 f3                	jne    800451 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80045e:	a1 04 40 80 00       	mov    0x804004,%eax
  800463:	8b 40 48             	mov    0x48(%eax),%eax
  800466:	83 ec 04             	sub    $0x4,%esp
  800469:	51                   	push   %ecx
  80046a:	50                   	push   %eax
  80046b:	68 38 1e 80 00       	push   $0x801e38
  800470:	e8 93 0c 00 00       	call   801108 <cprintf>
	*dev = 0;
  800475:	8b 45 0c             	mov    0xc(%ebp),%eax
  800478:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80047e:	83 c4 10             	add    $0x10,%esp
  800481:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800486:	c9                   	leave  
  800487:	c3                   	ret    
			*dev = devtab[i];
  800488:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80048b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80048d:	b8 00 00 00 00       	mov    $0x0,%eax
  800492:	eb f2                	jmp    800486 <dev_lookup+0x48>

00800494 <fd_close>:
{
  800494:	55                   	push   %ebp
  800495:	89 e5                	mov    %esp,%ebp
  800497:	57                   	push   %edi
  800498:	56                   	push   %esi
  800499:	53                   	push   %ebx
  80049a:	83 ec 1c             	sub    $0x1c,%esp
  80049d:	8b 75 08             	mov    0x8(%ebp),%esi
  8004a0:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004a3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004a6:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004a7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004ad:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004b0:	50                   	push   %eax
  8004b1:	e8 32 ff ff ff       	call   8003e8 <fd_lookup>
  8004b6:	89 c3                	mov    %eax,%ebx
  8004b8:	83 c4 08             	add    $0x8,%esp
  8004bb:	85 c0                	test   %eax,%eax
  8004bd:	78 05                	js     8004c4 <fd_close+0x30>
	    || fd != fd2)
  8004bf:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8004c2:	74 16                	je     8004da <fd_close+0x46>
		return (must_exist ? r : 0);
  8004c4:	89 f8                	mov    %edi,%eax
  8004c6:	84 c0                	test   %al,%al
  8004c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004cd:	0f 44 d8             	cmove  %eax,%ebx
}
  8004d0:	89 d8                	mov    %ebx,%eax
  8004d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004d5:	5b                   	pop    %ebx
  8004d6:	5e                   	pop    %esi
  8004d7:	5f                   	pop    %edi
  8004d8:	5d                   	pop    %ebp
  8004d9:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004da:	83 ec 08             	sub    $0x8,%esp
  8004dd:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8004e0:	50                   	push   %eax
  8004e1:	ff 36                	pushl  (%esi)
  8004e3:	e8 56 ff ff ff       	call   80043e <dev_lookup>
  8004e8:	89 c3                	mov    %eax,%ebx
  8004ea:	83 c4 10             	add    $0x10,%esp
  8004ed:	85 c0                	test   %eax,%eax
  8004ef:	78 15                	js     800506 <fd_close+0x72>
		if (dev->dev_close)
  8004f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004f4:	8b 40 10             	mov    0x10(%eax),%eax
  8004f7:	85 c0                	test   %eax,%eax
  8004f9:	74 1b                	je     800516 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8004fb:	83 ec 0c             	sub    $0xc,%esp
  8004fe:	56                   	push   %esi
  8004ff:	ff d0                	call   *%eax
  800501:	89 c3                	mov    %eax,%ebx
  800503:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800506:	83 ec 08             	sub    $0x8,%esp
  800509:	56                   	push   %esi
  80050a:	6a 00                	push   $0x0
  80050c:	e8 f5 fc ff ff       	call   800206 <sys_page_unmap>
	return r;
  800511:	83 c4 10             	add    $0x10,%esp
  800514:	eb ba                	jmp    8004d0 <fd_close+0x3c>
			r = 0;
  800516:	bb 00 00 00 00       	mov    $0x0,%ebx
  80051b:	eb e9                	jmp    800506 <fd_close+0x72>

0080051d <close>:

int
close(int fdnum)
{
  80051d:	55                   	push   %ebp
  80051e:	89 e5                	mov    %esp,%ebp
  800520:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800523:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800526:	50                   	push   %eax
  800527:	ff 75 08             	pushl  0x8(%ebp)
  80052a:	e8 b9 fe ff ff       	call   8003e8 <fd_lookup>
  80052f:	83 c4 08             	add    $0x8,%esp
  800532:	85 c0                	test   %eax,%eax
  800534:	78 10                	js     800546 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800536:	83 ec 08             	sub    $0x8,%esp
  800539:	6a 01                	push   $0x1
  80053b:	ff 75 f4             	pushl  -0xc(%ebp)
  80053e:	e8 51 ff ff ff       	call   800494 <fd_close>
  800543:	83 c4 10             	add    $0x10,%esp
}
  800546:	c9                   	leave  
  800547:	c3                   	ret    

00800548 <close_all>:

void
close_all(void)
{
  800548:	55                   	push   %ebp
  800549:	89 e5                	mov    %esp,%ebp
  80054b:	53                   	push   %ebx
  80054c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80054f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800554:	83 ec 0c             	sub    $0xc,%esp
  800557:	53                   	push   %ebx
  800558:	e8 c0 ff ff ff       	call   80051d <close>
	for (i = 0; i < MAXFD; i++)
  80055d:	83 c3 01             	add    $0x1,%ebx
  800560:	83 c4 10             	add    $0x10,%esp
  800563:	83 fb 20             	cmp    $0x20,%ebx
  800566:	75 ec                	jne    800554 <close_all+0xc>
}
  800568:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80056b:	c9                   	leave  
  80056c:	c3                   	ret    

0080056d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80056d:	55                   	push   %ebp
  80056e:	89 e5                	mov    %esp,%ebp
  800570:	57                   	push   %edi
  800571:	56                   	push   %esi
  800572:	53                   	push   %ebx
  800573:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800576:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800579:	50                   	push   %eax
  80057a:	ff 75 08             	pushl  0x8(%ebp)
  80057d:	e8 66 fe ff ff       	call   8003e8 <fd_lookup>
  800582:	89 c3                	mov    %eax,%ebx
  800584:	83 c4 08             	add    $0x8,%esp
  800587:	85 c0                	test   %eax,%eax
  800589:	0f 88 81 00 00 00    	js     800610 <dup+0xa3>
		return r;
	close(newfdnum);
  80058f:	83 ec 0c             	sub    $0xc,%esp
  800592:	ff 75 0c             	pushl  0xc(%ebp)
  800595:	e8 83 ff ff ff       	call   80051d <close>

	newfd = INDEX2FD(newfdnum);
  80059a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80059d:	c1 e6 0c             	shl    $0xc,%esi
  8005a0:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8005a6:	83 c4 04             	add    $0x4,%esp
  8005a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005ac:	e8 d1 fd ff ff       	call   800382 <fd2data>
  8005b1:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8005b3:	89 34 24             	mov    %esi,(%esp)
  8005b6:	e8 c7 fd ff ff       	call   800382 <fd2data>
  8005bb:	83 c4 10             	add    $0x10,%esp
  8005be:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005c0:	89 d8                	mov    %ebx,%eax
  8005c2:	c1 e8 16             	shr    $0x16,%eax
  8005c5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005cc:	a8 01                	test   $0x1,%al
  8005ce:	74 11                	je     8005e1 <dup+0x74>
  8005d0:	89 d8                	mov    %ebx,%eax
  8005d2:	c1 e8 0c             	shr    $0xc,%eax
  8005d5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005dc:	f6 c2 01             	test   $0x1,%dl
  8005df:	75 39                	jne    80061a <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005e1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e4:	89 d0                	mov    %edx,%eax
  8005e6:	c1 e8 0c             	shr    $0xc,%eax
  8005e9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005f0:	83 ec 0c             	sub    $0xc,%esp
  8005f3:	25 07 0e 00 00       	and    $0xe07,%eax
  8005f8:	50                   	push   %eax
  8005f9:	56                   	push   %esi
  8005fa:	6a 00                	push   $0x0
  8005fc:	52                   	push   %edx
  8005fd:	6a 00                	push   $0x0
  8005ff:	e8 c0 fb ff ff       	call   8001c4 <sys_page_map>
  800604:	89 c3                	mov    %eax,%ebx
  800606:	83 c4 20             	add    $0x20,%esp
  800609:	85 c0                	test   %eax,%eax
  80060b:	78 31                	js     80063e <dup+0xd1>
		goto err;

	return newfdnum;
  80060d:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800610:	89 d8                	mov    %ebx,%eax
  800612:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800615:	5b                   	pop    %ebx
  800616:	5e                   	pop    %esi
  800617:	5f                   	pop    %edi
  800618:	5d                   	pop    %ebp
  800619:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80061a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800621:	83 ec 0c             	sub    $0xc,%esp
  800624:	25 07 0e 00 00       	and    $0xe07,%eax
  800629:	50                   	push   %eax
  80062a:	57                   	push   %edi
  80062b:	6a 00                	push   $0x0
  80062d:	53                   	push   %ebx
  80062e:	6a 00                	push   $0x0
  800630:	e8 8f fb ff ff       	call   8001c4 <sys_page_map>
  800635:	89 c3                	mov    %eax,%ebx
  800637:	83 c4 20             	add    $0x20,%esp
  80063a:	85 c0                	test   %eax,%eax
  80063c:	79 a3                	jns    8005e1 <dup+0x74>
	sys_page_unmap(0, newfd);
  80063e:	83 ec 08             	sub    $0x8,%esp
  800641:	56                   	push   %esi
  800642:	6a 00                	push   $0x0
  800644:	e8 bd fb ff ff       	call   800206 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800649:	83 c4 08             	add    $0x8,%esp
  80064c:	57                   	push   %edi
  80064d:	6a 00                	push   $0x0
  80064f:	e8 b2 fb ff ff       	call   800206 <sys_page_unmap>
	return r;
  800654:	83 c4 10             	add    $0x10,%esp
  800657:	eb b7                	jmp    800610 <dup+0xa3>

00800659 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800659:	55                   	push   %ebp
  80065a:	89 e5                	mov    %esp,%ebp
  80065c:	53                   	push   %ebx
  80065d:	83 ec 14             	sub    $0x14,%esp
  800660:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800663:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800666:	50                   	push   %eax
  800667:	53                   	push   %ebx
  800668:	e8 7b fd ff ff       	call   8003e8 <fd_lookup>
  80066d:	83 c4 08             	add    $0x8,%esp
  800670:	85 c0                	test   %eax,%eax
  800672:	78 3f                	js     8006b3 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800674:	83 ec 08             	sub    $0x8,%esp
  800677:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80067a:	50                   	push   %eax
  80067b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80067e:	ff 30                	pushl  (%eax)
  800680:	e8 b9 fd ff ff       	call   80043e <dev_lookup>
  800685:	83 c4 10             	add    $0x10,%esp
  800688:	85 c0                	test   %eax,%eax
  80068a:	78 27                	js     8006b3 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80068c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80068f:	8b 42 08             	mov    0x8(%edx),%eax
  800692:	83 e0 03             	and    $0x3,%eax
  800695:	83 f8 01             	cmp    $0x1,%eax
  800698:	74 1e                	je     8006b8 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80069a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80069d:	8b 40 08             	mov    0x8(%eax),%eax
  8006a0:	85 c0                	test   %eax,%eax
  8006a2:	74 35                	je     8006d9 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006a4:	83 ec 04             	sub    $0x4,%esp
  8006a7:	ff 75 10             	pushl  0x10(%ebp)
  8006aa:	ff 75 0c             	pushl  0xc(%ebp)
  8006ad:	52                   	push   %edx
  8006ae:	ff d0                	call   *%eax
  8006b0:	83 c4 10             	add    $0x10,%esp
}
  8006b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006b6:	c9                   	leave  
  8006b7:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006b8:	a1 04 40 80 00       	mov    0x804004,%eax
  8006bd:	8b 40 48             	mov    0x48(%eax),%eax
  8006c0:	83 ec 04             	sub    $0x4,%esp
  8006c3:	53                   	push   %ebx
  8006c4:	50                   	push   %eax
  8006c5:	68 79 1e 80 00       	push   $0x801e79
  8006ca:	e8 39 0a 00 00       	call   801108 <cprintf>
		return -E_INVAL;
  8006cf:	83 c4 10             	add    $0x10,%esp
  8006d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006d7:	eb da                	jmp    8006b3 <read+0x5a>
		return -E_NOT_SUPP;
  8006d9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006de:	eb d3                	jmp    8006b3 <read+0x5a>

008006e0 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006e0:	55                   	push   %ebp
  8006e1:	89 e5                	mov    %esp,%ebp
  8006e3:	57                   	push   %edi
  8006e4:	56                   	push   %esi
  8006e5:	53                   	push   %ebx
  8006e6:	83 ec 0c             	sub    $0xc,%esp
  8006e9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006ec:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006ef:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006f4:	39 f3                	cmp    %esi,%ebx
  8006f6:	73 25                	jae    80071d <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f8:	83 ec 04             	sub    $0x4,%esp
  8006fb:	89 f0                	mov    %esi,%eax
  8006fd:	29 d8                	sub    %ebx,%eax
  8006ff:	50                   	push   %eax
  800700:	89 d8                	mov    %ebx,%eax
  800702:	03 45 0c             	add    0xc(%ebp),%eax
  800705:	50                   	push   %eax
  800706:	57                   	push   %edi
  800707:	e8 4d ff ff ff       	call   800659 <read>
		if (m < 0)
  80070c:	83 c4 10             	add    $0x10,%esp
  80070f:	85 c0                	test   %eax,%eax
  800711:	78 08                	js     80071b <readn+0x3b>
			return m;
		if (m == 0)
  800713:	85 c0                	test   %eax,%eax
  800715:	74 06                	je     80071d <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  800717:	01 c3                	add    %eax,%ebx
  800719:	eb d9                	jmp    8006f4 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80071b:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80071d:	89 d8                	mov    %ebx,%eax
  80071f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800722:	5b                   	pop    %ebx
  800723:	5e                   	pop    %esi
  800724:	5f                   	pop    %edi
  800725:	5d                   	pop    %ebp
  800726:	c3                   	ret    

00800727 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800727:	55                   	push   %ebp
  800728:	89 e5                	mov    %esp,%ebp
  80072a:	53                   	push   %ebx
  80072b:	83 ec 14             	sub    $0x14,%esp
  80072e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800731:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800734:	50                   	push   %eax
  800735:	53                   	push   %ebx
  800736:	e8 ad fc ff ff       	call   8003e8 <fd_lookup>
  80073b:	83 c4 08             	add    $0x8,%esp
  80073e:	85 c0                	test   %eax,%eax
  800740:	78 3a                	js     80077c <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800742:	83 ec 08             	sub    $0x8,%esp
  800745:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800748:	50                   	push   %eax
  800749:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80074c:	ff 30                	pushl  (%eax)
  80074e:	e8 eb fc ff ff       	call   80043e <dev_lookup>
  800753:	83 c4 10             	add    $0x10,%esp
  800756:	85 c0                	test   %eax,%eax
  800758:	78 22                	js     80077c <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80075a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80075d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800761:	74 1e                	je     800781 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800763:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800766:	8b 52 0c             	mov    0xc(%edx),%edx
  800769:	85 d2                	test   %edx,%edx
  80076b:	74 35                	je     8007a2 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80076d:	83 ec 04             	sub    $0x4,%esp
  800770:	ff 75 10             	pushl  0x10(%ebp)
  800773:	ff 75 0c             	pushl  0xc(%ebp)
  800776:	50                   	push   %eax
  800777:	ff d2                	call   *%edx
  800779:	83 c4 10             	add    $0x10,%esp
}
  80077c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80077f:	c9                   	leave  
  800780:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800781:	a1 04 40 80 00       	mov    0x804004,%eax
  800786:	8b 40 48             	mov    0x48(%eax),%eax
  800789:	83 ec 04             	sub    $0x4,%esp
  80078c:	53                   	push   %ebx
  80078d:	50                   	push   %eax
  80078e:	68 95 1e 80 00       	push   $0x801e95
  800793:	e8 70 09 00 00       	call   801108 <cprintf>
		return -E_INVAL;
  800798:	83 c4 10             	add    $0x10,%esp
  80079b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a0:	eb da                	jmp    80077c <write+0x55>
		return -E_NOT_SUPP;
  8007a2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8007a7:	eb d3                	jmp    80077c <write+0x55>

008007a9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007a9:	55                   	push   %ebp
  8007aa:	89 e5                	mov    %esp,%ebp
  8007ac:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007af:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007b2:	50                   	push   %eax
  8007b3:	ff 75 08             	pushl  0x8(%ebp)
  8007b6:	e8 2d fc ff ff       	call   8003e8 <fd_lookup>
  8007bb:	83 c4 08             	add    $0x8,%esp
  8007be:	85 c0                	test   %eax,%eax
  8007c0:	78 0e                	js     8007d0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007c8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007d0:	c9                   	leave  
  8007d1:	c3                   	ret    

008007d2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	53                   	push   %ebx
  8007d6:	83 ec 14             	sub    $0x14,%esp
  8007d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007df:	50                   	push   %eax
  8007e0:	53                   	push   %ebx
  8007e1:	e8 02 fc ff ff       	call   8003e8 <fd_lookup>
  8007e6:	83 c4 08             	add    $0x8,%esp
  8007e9:	85 c0                	test   %eax,%eax
  8007eb:	78 37                	js     800824 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ed:	83 ec 08             	sub    $0x8,%esp
  8007f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007f3:	50                   	push   %eax
  8007f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f7:	ff 30                	pushl  (%eax)
  8007f9:	e8 40 fc ff ff       	call   80043e <dev_lookup>
  8007fe:	83 c4 10             	add    $0x10,%esp
  800801:	85 c0                	test   %eax,%eax
  800803:	78 1f                	js     800824 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800805:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800808:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80080c:	74 1b                	je     800829 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80080e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800811:	8b 52 18             	mov    0x18(%edx),%edx
  800814:	85 d2                	test   %edx,%edx
  800816:	74 32                	je     80084a <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800818:	83 ec 08             	sub    $0x8,%esp
  80081b:	ff 75 0c             	pushl  0xc(%ebp)
  80081e:	50                   	push   %eax
  80081f:	ff d2                	call   *%edx
  800821:	83 c4 10             	add    $0x10,%esp
}
  800824:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800827:	c9                   	leave  
  800828:	c3                   	ret    
			thisenv->env_id, fdnum);
  800829:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80082e:	8b 40 48             	mov    0x48(%eax),%eax
  800831:	83 ec 04             	sub    $0x4,%esp
  800834:	53                   	push   %ebx
  800835:	50                   	push   %eax
  800836:	68 58 1e 80 00       	push   $0x801e58
  80083b:	e8 c8 08 00 00       	call   801108 <cprintf>
		return -E_INVAL;
  800840:	83 c4 10             	add    $0x10,%esp
  800843:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800848:	eb da                	jmp    800824 <ftruncate+0x52>
		return -E_NOT_SUPP;
  80084a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80084f:	eb d3                	jmp    800824 <ftruncate+0x52>

00800851 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	53                   	push   %ebx
  800855:	83 ec 14             	sub    $0x14,%esp
  800858:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80085b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80085e:	50                   	push   %eax
  80085f:	ff 75 08             	pushl  0x8(%ebp)
  800862:	e8 81 fb ff ff       	call   8003e8 <fd_lookup>
  800867:	83 c4 08             	add    $0x8,%esp
  80086a:	85 c0                	test   %eax,%eax
  80086c:	78 4b                	js     8008b9 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80086e:	83 ec 08             	sub    $0x8,%esp
  800871:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800874:	50                   	push   %eax
  800875:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800878:	ff 30                	pushl  (%eax)
  80087a:	e8 bf fb ff ff       	call   80043e <dev_lookup>
  80087f:	83 c4 10             	add    $0x10,%esp
  800882:	85 c0                	test   %eax,%eax
  800884:	78 33                	js     8008b9 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  800886:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800889:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80088d:	74 2f                	je     8008be <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80088f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800892:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800899:	00 00 00 
	stat->st_isdir = 0;
  80089c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008a3:	00 00 00 
	stat->st_dev = dev;
  8008a6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008ac:	83 ec 08             	sub    $0x8,%esp
  8008af:	53                   	push   %ebx
  8008b0:	ff 75 f0             	pushl  -0x10(%ebp)
  8008b3:	ff 50 14             	call   *0x14(%eax)
  8008b6:	83 c4 10             	add    $0x10,%esp
}
  8008b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008bc:	c9                   	leave  
  8008bd:	c3                   	ret    
		return -E_NOT_SUPP;
  8008be:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008c3:	eb f4                	jmp    8008b9 <fstat+0x68>

008008c5 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	56                   	push   %esi
  8008c9:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008ca:	83 ec 08             	sub    $0x8,%esp
  8008cd:	6a 00                	push   $0x0
  8008cf:	ff 75 08             	pushl  0x8(%ebp)
  8008d2:	e8 e7 01 00 00       	call   800abe <open>
  8008d7:	89 c3                	mov    %eax,%ebx
  8008d9:	83 c4 10             	add    $0x10,%esp
  8008dc:	85 c0                	test   %eax,%eax
  8008de:	78 1b                	js     8008fb <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008e0:	83 ec 08             	sub    $0x8,%esp
  8008e3:	ff 75 0c             	pushl  0xc(%ebp)
  8008e6:	50                   	push   %eax
  8008e7:	e8 65 ff ff ff       	call   800851 <fstat>
  8008ec:	89 c6                	mov    %eax,%esi
	close(fd);
  8008ee:	89 1c 24             	mov    %ebx,(%esp)
  8008f1:	e8 27 fc ff ff       	call   80051d <close>
	return r;
  8008f6:	83 c4 10             	add    $0x10,%esp
  8008f9:	89 f3                	mov    %esi,%ebx
}
  8008fb:	89 d8                	mov    %ebx,%eax
  8008fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800900:	5b                   	pop    %ebx
  800901:	5e                   	pop    %esi
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    

00800904 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	56                   	push   %esi
  800908:	53                   	push   %ebx
  800909:	89 c6                	mov    %eax,%esi
  80090b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80090d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800914:	74 27                	je     80093d <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800916:	6a 07                	push   $0x7
  800918:	68 00 50 80 00       	push   $0x805000
  80091d:	56                   	push   %esi
  80091e:	ff 35 00 40 80 00    	pushl  0x804000
  800924:	e8 b0 11 00 00       	call   801ad9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800929:	83 c4 0c             	add    $0xc,%esp
  80092c:	6a 00                	push   $0x0
  80092e:	53                   	push   %ebx
  80092f:	6a 00                	push   $0x0
  800931:	e8 2e 11 00 00       	call   801a64 <ipc_recv>
}
  800936:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800939:	5b                   	pop    %ebx
  80093a:	5e                   	pop    %esi
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80093d:	83 ec 0c             	sub    $0xc,%esp
  800940:	6a 01                	push   $0x1
  800942:	e8 e8 11 00 00       	call   801b2f <ipc_find_env>
  800947:	a3 00 40 80 00       	mov    %eax,0x804000
  80094c:	83 c4 10             	add    $0x10,%esp
  80094f:	eb c5                	jmp    800916 <fsipc+0x12>

00800951 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	8b 40 0c             	mov    0xc(%eax),%eax
  80095d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800962:	8b 45 0c             	mov    0xc(%ebp),%eax
  800965:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80096a:	ba 00 00 00 00       	mov    $0x0,%edx
  80096f:	b8 02 00 00 00       	mov    $0x2,%eax
  800974:	e8 8b ff ff ff       	call   800904 <fsipc>
}
  800979:	c9                   	leave  
  80097a:	c3                   	ret    

0080097b <devfile_flush>:
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	8b 40 0c             	mov    0xc(%eax),%eax
  800987:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80098c:	ba 00 00 00 00       	mov    $0x0,%edx
  800991:	b8 06 00 00 00       	mov    $0x6,%eax
  800996:	e8 69 ff ff ff       	call   800904 <fsipc>
}
  80099b:	c9                   	leave  
  80099c:	c3                   	ret    

0080099d <devfile_stat>:
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	53                   	push   %ebx
  8009a1:	83 ec 04             	sub    $0x4,%esp
  8009a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ad:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b7:	b8 05 00 00 00       	mov    $0x5,%eax
  8009bc:	e8 43 ff ff ff       	call   800904 <fsipc>
  8009c1:	85 c0                	test   %eax,%eax
  8009c3:	78 2c                	js     8009f1 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009c5:	83 ec 08             	sub    $0x8,%esp
  8009c8:	68 00 50 80 00       	push   $0x805000
  8009cd:	53                   	push   %ebx
  8009ce:	e8 54 0d 00 00       	call   801727 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009d3:	a1 80 50 80 00       	mov    0x805080,%eax
  8009d8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009de:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009e9:	83 c4 10             	add    $0x10,%esp
  8009ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f4:	c9                   	leave  
  8009f5:	c3                   	ret    

008009f6 <devfile_write>:
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	83 ec 0c             	sub    $0xc,%esp
  8009fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8009ff:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a04:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a09:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a0f:	8b 52 0c             	mov    0xc(%edx),%edx
  800a12:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a18:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf,buf,n);
  800a1d:	50                   	push   %eax
  800a1e:	ff 75 0c             	pushl  0xc(%ebp)
  800a21:	68 08 50 80 00       	push   $0x805008
  800a26:	e8 8a 0e 00 00       	call   8018b5 <memmove>
	if((r = fsipc(FSREQ_WRITE,NULL))<0)
  800a2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a30:	b8 04 00 00 00       	mov    $0x4,%eax
  800a35:	e8 ca fe ff ff       	call   800904 <fsipc>
}
  800a3a:	c9                   	leave  
  800a3b:	c3                   	ret    

00800a3c <devfile_read>:
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	56                   	push   %esi
  800a40:	53                   	push   %ebx
  800a41:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a44:	8b 45 08             	mov    0x8(%ebp),%eax
  800a47:	8b 40 0c             	mov    0xc(%eax),%eax
  800a4a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a4f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a55:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a5f:	e8 a0 fe ff ff       	call   800904 <fsipc>
  800a64:	89 c3                	mov    %eax,%ebx
  800a66:	85 c0                	test   %eax,%eax
  800a68:	78 1f                	js     800a89 <devfile_read+0x4d>
	assert(r <= n);
  800a6a:	39 f0                	cmp    %esi,%eax
  800a6c:	77 24                	ja     800a92 <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a6e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a73:	7f 33                	jg     800aa8 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a75:	83 ec 04             	sub    $0x4,%esp
  800a78:	50                   	push   %eax
  800a79:	68 00 50 80 00       	push   $0x805000
  800a7e:	ff 75 0c             	pushl  0xc(%ebp)
  800a81:	e8 2f 0e 00 00       	call   8018b5 <memmove>
	return r;
  800a86:	83 c4 10             	add    $0x10,%esp
}
  800a89:	89 d8                	mov    %ebx,%eax
  800a8b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a8e:	5b                   	pop    %ebx
  800a8f:	5e                   	pop    %esi
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    
	assert(r <= n);
  800a92:	68 c4 1e 80 00       	push   $0x801ec4
  800a97:	68 cb 1e 80 00       	push   $0x801ecb
  800a9c:	6a 7c                	push   $0x7c
  800a9e:	68 e0 1e 80 00       	push   $0x801ee0
  800aa3:	e8 85 05 00 00       	call   80102d <_panic>
	assert(r <= PGSIZE);
  800aa8:	68 eb 1e 80 00       	push   $0x801eeb
  800aad:	68 cb 1e 80 00       	push   $0x801ecb
  800ab2:	6a 7d                	push   $0x7d
  800ab4:	68 e0 1e 80 00       	push   $0x801ee0
  800ab9:	e8 6f 05 00 00       	call   80102d <_panic>

00800abe <open>:
{
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	56                   	push   %esi
  800ac2:	53                   	push   %ebx
  800ac3:	83 ec 1c             	sub    $0x1c,%esp
  800ac6:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800ac9:	56                   	push   %esi
  800aca:	e8 21 0c 00 00       	call   8016f0 <strlen>
  800acf:	83 c4 10             	add    $0x10,%esp
  800ad2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ad7:	7f 6c                	jg     800b45 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800ad9:	83 ec 0c             	sub    $0xc,%esp
  800adc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800adf:	50                   	push   %eax
  800ae0:	e8 b4 f8 ff ff       	call   800399 <fd_alloc>
  800ae5:	89 c3                	mov    %eax,%ebx
  800ae7:	83 c4 10             	add    $0x10,%esp
  800aea:	85 c0                	test   %eax,%eax
  800aec:	78 3c                	js     800b2a <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800aee:	83 ec 08             	sub    $0x8,%esp
  800af1:	56                   	push   %esi
  800af2:	68 00 50 80 00       	push   $0x805000
  800af7:	e8 2b 0c 00 00       	call   801727 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800afc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aff:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b04:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b07:	b8 01 00 00 00       	mov    $0x1,%eax
  800b0c:	e8 f3 fd ff ff       	call   800904 <fsipc>
  800b11:	89 c3                	mov    %eax,%ebx
  800b13:	83 c4 10             	add    $0x10,%esp
  800b16:	85 c0                	test   %eax,%eax
  800b18:	78 19                	js     800b33 <open+0x75>
	return fd2num(fd);
  800b1a:	83 ec 0c             	sub    $0xc,%esp
  800b1d:	ff 75 f4             	pushl  -0xc(%ebp)
  800b20:	e8 4d f8 ff ff       	call   800372 <fd2num>
  800b25:	89 c3                	mov    %eax,%ebx
  800b27:	83 c4 10             	add    $0x10,%esp
}
  800b2a:	89 d8                	mov    %ebx,%eax
  800b2c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b2f:	5b                   	pop    %ebx
  800b30:	5e                   	pop    %esi
  800b31:	5d                   	pop    %ebp
  800b32:	c3                   	ret    
		fd_close(fd, 0);
  800b33:	83 ec 08             	sub    $0x8,%esp
  800b36:	6a 00                	push   $0x0
  800b38:	ff 75 f4             	pushl  -0xc(%ebp)
  800b3b:	e8 54 f9 ff ff       	call   800494 <fd_close>
		return r;
  800b40:	83 c4 10             	add    $0x10,%esp
  800b43:	eb e5                	jmp    800b2a <open+0x6c>
		return -E_BAD_PATH;
  800b45:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b4a:	eb de                	jmp    800b2a <open+0x6c>

00800b4c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b52:	ba 00 00 00 00       	mov    $0x0,%edx
  800b57:	b8 08 00 00 00       	mov    $0x8,%eax
  800b5c:	e8 a3 fd ff ff       	call   800904 <fsipc>
}
  800b61:	c9                   	leave  
  800b62:	c3                   	ret    

00800b63 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	56                   	push   %esi
  800b67:	53                   	push   %ebx
  800b68:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b6b:	83 ec 0c             	sub    $0xc,%esp
  800b6e:	ff 75 08             	pushl  0x8(%ebp)
  800b71:	e8 0c f8 ff ff       	call   800382 <fd2data>
  800b76:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b78:	83 c4 08             	add    $0x8,%esp
  800b7b:	68 f7 1e 80 00       	push   $0x801ef7
  800b80:	53                   	push   %ebx
  800b81:	e8 a1 0b 00 00       	call   801727 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b86:	8b 46 04             	mov    0x4(%esi),%eax
  800b89:	2b 06                	sub    (%esi),%eax
  800b8b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b91:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b98:	00 00 00 
	stat->st_dev = &devpipe;
  800b9b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800ba2:	30 80 00 
	return 0;
}
  800ba5:	b8 00 00 00 00       	mov    $0x0,%eax
  800baa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bad:	5b                   	pop    %ebx
  800bae:	5e                   	pop    %esi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	53                   	push   %ebx
  800bb5:	83 ec 0c             	sub    $0xc,%esp
  800bb8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bbb:	53                   	push   %ebx
  800bbc:	6a 00                	push   $0x0
  800bbe:	e8 43 f6 ff ff       	call   800206 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bc3:	89 1c 24             	mov    %ebx,(%esp)
  800bc6:	e8 b7 f7 ff ff       	call   800382 <fd2data>
  800bcb:	83 c4 08             	add    $0x8,%esp
  800bce:	50                   	push   %eax
  800bcf:	6a 00                	push   $0x0
  800bd1:	e8 30 f6 ff ff       	call   800206 <sys_page_unmap>
}
  800bd6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bd9:	c9                   	leave  
  800bda:	c3                   	ret    

00800bdb <_pipeisclosed>:
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	57                   	push   %edi
  800bdf:	56                   	push   %esi
  800be0:	53                   	push   %ebx
  800be1:	83 ec 1c             	sub    $0x1c,%esp
  800be4:	89 c7                	mov    %eax,%edi
  800be6:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800be8:	a1 04 40 80 00       	mov    0x804004,%eax
  800bed:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800bf0:	83 ec 0c             	sub    $0xc,%esp
  800bf3:	57                   	push   %edi
  800bf4:	e8 6f 0f 00 00       	call   801b68 <pageref>
  800bf9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800bfc:	89 34 24             	mov    %esi,(%esp)
  800bff:	e8 64 0f 00 00       	call   801b68 <pageref>
		nn = thisenv->env_runs;
  800c04:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c0a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c0d:	83 c4 10             	add    $0x10,%esp
  800c10:	39 cb                	cmp    %ecx,%ebx
  800c12:	74 1b                	je     800c2f <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c14:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c17:	75 cf                	jne    800be8 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c19:	8b 42 58             	mov    0x58(%edx),%eax
  800c1c:	6a 01                	push   $0x1
  800c1e:	50                   	push   %eax
  800c1f:	53                   	push   %ebx
  800c20:	68 fe 1e 80 00       	push   $0x801efe
  800c25:	e8 de 04 00 00       	call   801108 <cprintf>
  800c2a:	83 c4 10             	add    $0x10,%esp
  800c2d:	eb b9                	jmp    800be8 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c2f:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c32:	0f 94 c0             	sete   %al
  800c35:	0f b6 c0             	movzbl %al,%eax
}
  800c38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3b:	5b                   	pop    %ebx
  800c3c:	5e                   	pop    %esi
  800c3d:	5f                   	pop    %edi
  800c3e:	5d                   	pop    %ebp
  800c3f:	c3                   	ret    

00800c40 <devpipe_write>:
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	57                   	push   %edi
  800c44:	56                   	push   %esi
  800c45:	53                   	push   %ebx
  800c46:	83 ec 28             	sub    $0x28,%esp
  800c49:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c4c:	56                   	push   %esi
  800c4d:	e8 30 f7 ff ff       	call   800382 <fd2data>
  800c52:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c54:	83 c4 10             	add    $0x10,%esp
  800c57:	bf 00 00 00 00       	mov    $0x0,%edi
  800c5c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c5f:	74 4f                	je     800cb0 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c61:	8b 43 04             	mov    0x4(%ebx),%eax
  800c64:	8b 0b                	mov    (%ebx),%ecx
  800c66:	8d 51 20             	lea    0x20(%ecx),%edx
  800c69:	39 d0                	cmp    %edx,%eax
  800c6b:	72 14                	jb     800c81 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  800c6d:	89 da                	mov    %ebx,%edx
  800c6f:	89 f0                	mov    %esi,%eax
  800c71:	e8 65 ff ff ff       	call   800bdb <_pipeisclosed>
  800c76:	85 c0                	test   %eax,%eax
  800c78:	75 3a                	jne    800cb4 <devpipe_write+0x74>
			sys_yield();
  800c7a:	e8 e3 f4 ff ff       	call   800162 <sys_yield>
  800c7f:	eb e0                	jmp    800c61 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c84:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c88:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c8b:	89 c2                	mov    %eax,%edx
  800c8d:	c1 fa 1f             	sar    $0x1f,%edx
  800c90:	89 d1                	mov    %edx,%ecx
  800c92:	c1 e9 1b             	shr    $0x1b,%ecx
  800c95:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c98:	83 e2 1f             	and    $0x1f,%edx
  800c9b:	29 ca                	sub    %ecx,%edx
  800c9d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ca1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ca5:	83 c0 01             	add    $0x1,%eax
  800ca8:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800cab:	83 c7 01             	add    $0x1,%edi
  800cae:	eb ac                	jmp    800c5c <devpipe_write+0x1c>
	return i;
  800cb0:	89 f8                	mov    %edi,%eax
  800cb2:	eb 05                	jmp    800cb9 <devpipe_write+0x79>
				return 0;
  800cb4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <devpipe_read>:
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
  800cc7:	83 ec 18             	sub    $0x18,%esp
  800cca:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800ccd:	57                   	push   %edi
  800cce:	e8 af f6 ff ff       	call   800382 <fd2data>
  800cd3:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800cd5:	83 c4 10             	add    $0x10,%esp
  800cd8:	be 00 00 00 00       	mov    $0x0,%esi
  800cdd:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ce0:	74 47                	je     800d29 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  800ce2:	8b 03                	mov    (%ebx),%eax
  800ce4:	3b 43 04             	cmp    0x4(%ebx),%eax
  800ce7:	75 22                	jne    800d0b <devpipe_read+0x4a>
			if (i > 0)
  800ce9:	85 f6                	test   %esi,%esi
  800ceb:	75 14                	jne    800d01 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  800ced:	89 da                	mov    %ebx,%edx
  800cef:	89 f8                	mov    %edi,%eax
  800cf1:	e8 e5 fe ff ff       	call   800bdb <_pipeisclosed>
  800cf6:	85 c0                	test   %eax,%eax
  800cf8:	75 33                	jne    800d2d <devpipe_read+0x6c>
			sys_yield();
  800cfa:	e8 63 f4 ff ff       	call   800162 <sys_yield>
  800cff:	eb e1                	jmp    800ce2 <devpipe_read+0x21>
				return i;
  800d01:	89 f0                	mov    %esi,%eax
}
  800d03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d06:	5b                   	pop    %ebx
  800d07:	5e                   	pop    %esi
  800d08:	5f                   	pop    %edi
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d0b:	99                   	cltd   
  800d0c:	c1 ea 1b             	shr    $0x1b,%edx
  800d0f:	01 d0                	add    %edx,%eax
  800d11:	83 e0 1f             	and    $0x1f,%eax
  800d14:	29 d0                	sub    %edx,%eax
  800d16:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1e:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d21:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d24:	83 c6 01             	add    $0x1,%esi
  800d27:	eb b4                	jmp    800cdd <devpipe_read+0x1c>
	return i;
  800d29:	89 f0                	mov    %esi,%eax
  800d2b:	eb d6                	jmp    800d03 <devpipe_read+0x42>
				return 0;
  800d2d:	b8 00 00 00 00       	mov    $0x0,%eax
  800d32:	eb cf                	jmp    800d03 <devpipe_read+0x42>

00800d34 <pipe>:
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
  800d37:	56                   	push   %esi
  800d38:	53                   	push   %ebx
  800d39:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d3c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d3f:	50                   	push   %eax
  800d40:	e8 54 f6 ff ff       	call   800399 <fd_alloc>
  800d45:	89 c3                	mov    %eax,%ebx
  800d47:	83 c4 10             	add    $0x10,%esp
  800d4a:	85 c0                	test   %eax,%eax
  800d4c:	78 5b                	js     800da9 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d4e:	83 ec 04             	sub    $0x4,%esp
  800d51:	68 07 04 00 00       	push   $0x407
  800d56:	ff 75 f4             	pushl  -0xc(%ebp)
  800d59:	6a 00                	push   $0x0
  800d5b:	e8 21 f4 ff ff       	call   800181 <sys_page_alloc>
  800d60:	89 c3                	mov    %eax,%ebx
  800d62:	83 c4 10             	add    $0x10,%esp
  800d65:	85 c0                	test   %eax,%eax
  800d67:	78 40                	js     800da9 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  800d69:	83 ec 0c             	sub    $0xc,%esp
  800d6c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d6f:	50                   	push   %eax
  800d70:	e8 24 f6 ff ff       	call   800399 <fd_alloc>
  800d75:	89 c3                	mov    %eax,%ebx
  800d77:	83 c4 10             	add    $0x10,%esp
  800d7a:	85 c0                	test   %eax,%eax
  800d7c:	78 1b                	js     800d99 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d7e:	83 ec 04             	sub    $0x4,%esp
  800d81:	68 07 04 00 00       	push   $0x407
  800d86:	ff 75 f0             	pushl  -0x10(%ebp)
  800d89:	6a 00                	push   $0x0
  800d8b:	e8 f1 f3 ff ff       	call   800181 <sys_page_alloc>
  800d90:	89 c3                	mov    %eax,%ebx
  800d92:	83 c4 10             	add    $0x10,%esp
  800d95:	85 c0                	test   %eax,%eax
  800d97:	79 19                	jns    800db2 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  800d99:	83 ec 08             	sub    $0x8,%esp
  800d9c:	ff 75 f4             	pushl  -0xc(%ebp)
  800d9f:	6a 00                	push   $0x0
  800da1:	e8 60 f4 ff ff       	call   800206 <sys_page_unmap>
  800da6:	83 c4 10             	add    $0x10,%esp
}
  800da9:	89 d8                	mov    %ebx,%eax
  800dab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800dae:	5b                   	pop    %ebx
  800daf:	5e                   	pop    %esi
  800db0:	5d                   	pop    %ebp
  800db1:	c3                   	ret    
	va = fd2data(fd0);
  800db2:	83 ec 0c             	sub    $0xc,%esp
  800db5:	ff 75 f4             	pushl  -0xc(%ebp)
  800db8:	e8 c5 f5 ff ff       	call   800382 <fd2data>
  800dbd:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dbf:	83 c4 0c             	add    $0xc,%esp
  800dc2:	68 07 04 00 00       	push   $0x407
  800dc7:	50                   	push   %eax
  800dc8:	6a 00                	push   $0x0
  800dca:	e8 b2 f3 ff ff       	call   800181 <sys_page_alloc>
  800dcf:	89 c3                	mov    %eax,%ebx
  800dd1:	83 c4 10             	add    $0x10,%esp
  800dd4:	85 c0                	test   %eax,%eax
  800dd6:	0f 88 8c 00 00 00    	js     800e68 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ddc:	83 ec 0c             	sub    $0xc,%esp
  800ddf:	ff 75 f0             	pushl  -0x10(%ebp)
  800de2:	e8 9b f5 ff ff       	call   800382 <fd2data>
  800de7:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dee:	50                   	push   %eax
  800def:	6a 00                	push   $0x0
  800df1:	56                   	push   %esi
  800df2:	6a 00                	push   $0x0
  800df4:	e8 cb f3 ff ff       	call   8001c4 <sys_page_map>
  800df9:	89 c3                	mov    %eax,%ebx
  800dfb:	83 c4 20             	add    $0x20,%esp
  800dfe:	85 c0                	test   %eax,%eax
  800e00:	78 58                	js     800e5a <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  800e02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e05:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e0b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e10:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  800e17:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e1a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e20:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e22:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e25:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e2c:	83 ec 0c             	sub    $0xc,%esp
  800e2f:	ff 75 f4             	pushl  -0xc(%ebp)
  800e32:	e8 3b f5 ff ff       	call   800372 <fd2num>
  800e37:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e3c:	83 c4 04             	add    $0x4,%esp
  800e3f:	ff 75 f0             	pushl  -0x10(%ebp)
  800e42:	e8 2b f5 ff ff       	call   800372 <fd2num>
  800e47:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e4a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e4d:	83 c4 10             	add    $0x10,%esp
  800e50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e55:	e9 4f ff ff ff       	jmp    800da9 <pipe+0x75>
	sys_page_unmap(0, va);
  800e5a:	83 ec 08             	sub    $0x8,%esp
  800e5d:	56                   	push   %esi
  800e5e:	6a 00                	push   $0x0
  800e60:	e8 a1 f3 ff ff       	call   800206 <sys_page_unmap>
  800e65:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e68:	83 ec 08             	sub    $0x8,%esp
  800e6b:	ff 75 f0             	pushl  -0x10(%ebp)
  800e6e:	6a 00                	push   $0x0
  800e70:	e8 91 f3 ff ff       	call   800206 <sys_page_unmap>
  800e75:	83 c4 10             	add    $0x10,%esp
  800e78:	e9 1c ff ff ff       	jmp    800d99 <pipe+0x65>

00800e7d <pipeisclosed>:
{
  800e7d:	55                   	push   %ebp
  800e7e:	89 e5                	mov    %esp,%ebp
  800e80:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e83:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e86:	50                   	push   %eax
  800e87:	ff 75 08             	pushl  0x8(%ebp)
  800e8a:	e8 59 f5 ff ff       	call   8003e8 <fd_lookup>
  800e8f:	83 c4 10             	add    $0x10,%esp
  800e92:	85 c0                	test   %eax,%eax
  800e94:	78 18                	js     800eae <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  800e96:	83 ec 0c             	sub    $0xc,%esp
  800e99:	ff 75 f4             	pushl  -0xc(%ebp)
  800e9c:	e8 e1 f4 ff ff       	call   800382 <fd2data>
	return _pipeisclosed(fd, p);
  800ea1:	89 c2                	mov    %eax,%edx
  800ea3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ea6:	e8 30 fd ff ff       	call   800bdb <_pipeisclosed>
  800eab:	83 c4 10             	add    $0x10,%esp
}
  800eae:	c9                   	leave  
  800eaf:	c3                   	ret    

00800eb0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800eb0:	55                   	push   %ebp
  800eb1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800eb3:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb8:	5d                   	pop    %ebp
  800eb9:	c3                   	ret    

00800eba <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800eba:	55                   	push   %ebp
  800ebb:	89 e5                	mov    %esp,%ebp
  800ebd:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ec0:	68 16 1f 80 00       	push   $0x801f16
  800ec5:	ff 75 0c             	pushl  0xc(%ebp)
  800ec8:	e8 5a 08 00 00       	call   801727 <strcpy>
	return 0;
}
  800ecd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed2:	c9                   	leave  
  800ed3:	c3                   	ret    

00800ed4 <devcons_write>:
{
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	57                   	push   %edi
  800ed8:	56                   	push   %esi
  800ed9:	53                   	push   %ebx
  800eda:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800ee0:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800ee5:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800eeb:	eb 2f                	jmp    800f1c <devcons_write+0x48>
		m = n - tot;
  800eed:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef0:	29 f3                	sub    %esi,%ebx
  800ef2:	83 fb 7f             	cmp    $0x7f,%ebx
  800ef5:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800efa:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800efd:	83 ec 04             	sub    $0x4,%esp
  800f00:	53                   	push   %ebx
  800f01:	89 f0                	mov    %esi,%eax
  800f03:	03 45 0c             	add    0xc(%ebp),%eax
  800f06:	50                   	push   %eax
  800f07:	57                   	push   %edi
  800f08:	e8 a8 09 00 00       	call   8018b5 <memmove>
		sys_cputs(buf, m);
  800f0d:	83 c4 08             	add    $0x8,%esp
  800f10:	53                   	push   %ebx
  800f11:	57                   	push   %edi
  800f12:	e8 ae f1 ff ff       	call   8000c5 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f17:	01 de                	add    %ebx,%esi
  800f19:	83 c4 10             	add    $0x10,%esp
  800f1c:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f1f:	72 cc                	jb     800eed <devcons_write+0x19>
}
  800f21:	89 f0                	mov    %esi,%eax
  800f23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f26:	5b                   	pop    %ebx
  800f27:	5e                   	pop    %esi
  800f28:	5f                   	pop    %edi
  800f29:	5d                   	pop    %ebp
  800f2a:	c3                   	ret    

00800f2b <devcons_read>:
{
  800f2b:	55                   	push   %ebp
  800f2c:	89 e5                	mov    %esp,%ebp
  800f2e:	83 ec 08             	sub    $0x8,%esp
  800f31:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f36:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f3a:	75 07                	jne    800f43 <devcons_read+0x18>
}
  800f3c:	c9                   	leave  
  800f3d:	c3                   	ret    
		sys_yield();
  800f3e:	e8 1f f2 ff ff       	call   800162 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  800f43:	e8 9b f1 ff ff       	call   8000e3 <sys_cgetc>
  800f48:	85 c0                	test   %eax,%eax
  800f4a:	74 f2                	je     800f3e <devcons_read+0x13>
	if (c < 0)
  800f4c:	85 c0                	test   %eax,%eax
  800f4e:	78 ec                	js     800f3c <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  800f50:	83 f8 04             	cmp    $0x4,%eax
  800f53:	74 0c                	je     800f61 <devcons_read+0x36>
	*(char*)vbuf = c;
  800f55:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f58:	88 02                	mov    %al,(%edx)
	return 1;
  800f5a:	b8 01 00 00 00       	mov    $0x1,%eax
  800f5f:	eb db                	jmp    800f3c <devcons_read+0x11>
		return 0;
  800f61:	b8 00 00 00 00       	mov    $0x0,%eax
  800f66:	eb d4                	jmp    800f3c <devcons_read+0x11>

00800f68 <cputchar>:
{
  800f68:	55                   	push   %ebp
  800f69:	89 e5                	mov    %esp,%ebp
  800f6b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f71:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800f74:	6a 01                	push   $0x1
  800f76:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f79:	50                   	push   %eax
  800f7a:	e8 46 f1 ff ff       	call   8000c5 <sys_cputs>
}
  800f7f:	83 c4 10             	add    $0x10,%esp
  800f82:	c9                   	leave  
  800f83:	c3                   	ret    

00800f84 <getchar>:
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800f8a:	6a 01                	push   $0x1
  800f8c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f8f:	50                   	push   %eax
  800f90:	6a 00                	push   $0x0
  800f92:	e8 c2 f6 ff ff       	call   800659 <read>
	if (r < 0)
  800f97:	83 c4 10             	add    $0x10,%esp
  800f9a:	85 c0                	test   %eax,%eax
  800f9c:	78 08                	js     800fa6 <getchar+0x22>
	if (r < 1)
  800f9e:	85 c0                	test   %eax,%eax
  800fa0:	7e 06                	jle    800fa8 <getchar+0x24>
	return c;
  800fa2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800fa6:	c9                   	leave  
  800fa7:	c3                   	ret    
		return -E_EOF;
  800fa8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800fad:	eb f7                	jmp    800fa6 <getchar+0x22>

00800faf <iscons>:
{
  800faf:	55                   	push   %ebp
  800fb0:	89 e5                	mov    %esp,%ebp
  800fb2:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fb5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb8:	50                   	push   %eax
  800fb9:	ff 75 08             	pushl  0x8(%ebp)
  800fbc:	e8 27 f4 ff ff       	call   8003e8 <fd_lookup>
  800fc1:	83 c4 10             	add    $0x10,%esp
  800fc4:	85 c0                	test   %eax,%eax
  800fc6:	78 11                	js     800fd9 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  800fc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fcb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fd1:	39 10                	cmp    %edx,(%eax)
  800fd3:	0f 94 c0             	sete   %al
  800fd6:	0f b6 c0             	movzbl %al,%eax
}
  800fd9:	c9                   	leave  
  800fda:	c3                   	ret    

00800fdb <opencons>:
{
  800fdb:	55                   	push   %ebp
  800fdc:	89 e5                	mov    %esp,%ebp
  800fde:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800fe1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe4:	50                   	push   %eax
  800fe5:	e8 af f3 ff ff       	call   800399 <fd_alloc>
  800fea:	83 c4 10             	add    $0x10,%esp
  800fed:	85 c0                	test   %eax,%eax
  800fef:	78 3a                	js     80102b <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800ff1:	83 ec 04             	sub    $0x4,%esp
  800ff4:	68 07 04 00 00       	push   $0x407
  800ff9:	ff 75 f4             	pushl  -0xc(%ebp)
  800ffc:	6a 00                	push   $0x0
  800ffe:	e8 7e f1 ff ff       	call   800181 <sys_page_alloc>
  801003:	83 c4 10             	add    $0x10,%esp
  801006:	85 c0                	test   %eax,%eax
  801008:	78 21                	js     80102b <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  80100a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80100d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801013:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801015:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801018:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80101f:	83 ec 0c             	sub    $0xc,%esp
  801022:	50                   	push   %eax
  801023:	e8 4a f3 ff ff       	call   800372 <fd2num>
  801028:	83 c4 10             	add    $0x10,%esp
}
  80102b:	c9                   	leave  
  80102c:	c3                   	ret    

0080102d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80102d:	55                   	push   %ebp
  80102e:	89 e5                	mov    %esp,%ebp
  801030:	56                   	push   %esi
  801031:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801032:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801035:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80103b:	e8 03 f1 ff ff       	call   800143 <sys_getenvid>
  801040:	83 ec 0c             	sub    $0xc,%esp
  801043:	ff 75 0c             	pushl  0xc(%ebp)
  801046:	ff 75 08             	pushl  0x8(%ebp)
  801049:	56                   	push   %esi
  80104a:	50                   	push   %eax
  80104b:	68 24 1f 80 00       	push   $0x801f24
  801050:	e8 b3 00 00 00       	call   801108 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801055:	83 c4 18             	add    $0x18,%esp
  801058:	53                   	push   %ebx
  801059:	ff 75 10             	pushl  0x10(%ebp)
  80105c:	e8 56 00 00 00       	call   8010b7 <vcprintf>
	cprintf("\n");
  801061:	c7 04 24 0f 1f 80 00 	movl   $0x801f0f,(%esp)
  801068:	e8 9b 00 00 00       	call   801108 <cprintf>
  80106d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801070:	cc                   	int3   
  801071:	eb fd                	jmp    801070 <_panic+0x43>

00801073 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801073:	55                   	push   %ebp
  801074:	89 e5                	mov    %esp,%ebp
  801076:	53                   	push   %ebx
  801077:	83 ec 04             	sub    $0x4,%esp
  80107a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80107d:	8b 13                	mov    (%ebx),%edx
  80107f:	8d 42 01             	lea    0x1(%edx),%eax
  801082:	89 03                	mov    %eax,(%ebx)
  801084:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801087:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80108b:	3d ff 00 00 00       	cmp    $0xff,%eax
  801090:	74 09                	je     80109b <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801092:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801096:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801099:	c9                   	leave  
  80109a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80109b:	83 ec 08             	sub    $0x8,%esp
  80109e:	68 ff 00 00 00       	push   $0xff
  8010a3:	8d 43 08             	lea    0x8(%ebx),%eax
  8010a6:	50                   	push   %eax
  8010a7:	e8 19 f0 ff ff       	call   8000c5 <sys_cputs>
		b->idx = 0;
  8010ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010b2:	83 c4 10             	add    $0x10,%esp
  8010b5:	eb db                	jmp    801092 <putch+0x1f>

008010b7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010b7:	55                   	push   %ebp
  8010b8:	89 e5                	mov    %esp,%ebp
  8010ba:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010c0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010c7:	00 00 00 
	b.cnt = 0;
  8010ca:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010d1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010d4:	ff 75 0c             	pushl  0xc(%ebp)
  8010d7:	ff 75 08             	pushl  0x8(%ebp)
  8010da:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010e0:	50                   	push   %eax
  8010e1:	68 73 10 80 00       	push   $0x801073
  8010e6:	e8 1a 01 00 00       	call   801205 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010eb:	83 c4 08             	add    $0x8,%esp
  8010ee:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010f4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010fa:	50                   	push   %eax
  8010fb:	e8 c5 ef ff ff       	call   8000c5 <sys_cputs>

	return b.cnt;
}
  801100:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801106:	c9                   	leave  
  801107:	c3                   	ret    

00801108 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801108:	55                   	push   %ebp
  801109:	89 e5                	mov    %esp,%ebp
  80110b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80110e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801111:	50                   	push   %eax
  801112:	ff 75 08             	pushl  0x8(%ebp)
  801115:	e8 9d ff ff ff       	call   8010b7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80111a:	c9                   	leave  
  80111b:	c3                   	ret    

0080111c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80111c:	55                   	push   %ebp
  80111d:	89 e5                	mov    %esp,%ebp
  80111f:	57                   	push   %edi
  801120:	56                   	push   %esi
  801121:	53                   	push   %ebx
  801122:	83 ec 1c             	sub    $0x1c,%esp
  801125:	89 c7                	mov    %eax,%edi
  801127:	89 d6                	mov    %edx,%esi
  801129:	8b 45 08             	mov    0x8(%ebp),%eax
  80112c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80112f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801132:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801135:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801138:	bb 00 00 00 00       	mov    $0x0,%ebx
  80113d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801140:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801143:	39 d3                	cmp    %edx,%ebx
  801145:	72 05                	jb     80114c <printnum+0x30>
  801147:	39 45 10             	cmp    %eax,0x10(%ebp)
  80114a:	77 7a                	ja     8011c6 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80114c:	83 ec 0c             	sub    $0xc,%esp
  80114f:	ff 75 18             	pushl  0x18(%ebp)
  801152:	8b 45 14             	mov    0x14(%ebp),%eax
  801155:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801158:	53                   	push   %ebx
  801159:	ff 75 10             	pushl  0x10(%ebp)
  80115c:	83 ec 08             	sub    $0x8,%esp
  80115f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801162:	ff 75 e0             	pushl  -0x20(%ebp)
  801165:	ff 75 dc             	pushl  -0x24(%ebp)
  801168:	ff 75 d8             	pushl  -0x28(%ebp)
  80116b:	e8 40 0a 00 00       	call   801bb0 <__udivdi3>
  801170:	83 c4 18             	add    $0x18,%esp
  801173:	52                   	push   %edx
  801174:	50                   	push   %eax
  801175:	89 f2                	mov    %esi,%edx
  801177:	89 f8                	mov    %edi,%eax
  801179:	e8 9e ff ff ff       	call   80111c <printnum>
  80117e:	83 c4 20             	add    $0x20,%esp
  801181:	eb 13                	jmp    801196 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801183:	83 ec 08             	sub    $0x8,%esp
  801186:	56                   	push   %esi
  801187:	ff 75 18             	pushl  0x18(%ebp)
  80118a:	ff d7                	call   *%edi
  80118c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80118f:	83 eb 01             	sub    $0x1,%ebx
  801192:	85 db                	test   %ebx,%ebx
  801194:	7f ed                	jg     801183 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801196:	83 ec 08             	sub    $0x8,%esp
  801199:	56                   	push   %esi
  80119a:	83 ec 04             	sub    $0x4,%esp
  80119d:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8011a3:	ff 75 dc             	pushl  -0x24(%ebp)
  8011a6:	ff 75 d8             	pushl  -0x28(%ebp)
  8011a9:	e8 22 0b 00 00       	call   801cd0 <__umoddi3>
  8011ae:	83 c4 14             	add    $0x14,%esp
  8011b1:	0f be 80 47 1f 80 00 	movsbl 0x801f47(%eax),%eax
  8011b8:	50                   	push   %eax
  8011b9:	ff d7                	call   *%edi
}
  8011bb:	83 c4 10             	add    $0x10,%esp
  8011be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c1:	5b                   	pop    %ebx
  8011c2:	5e                   	pop    %esi
  8011c3:	5f                   	pop    %edi
  8011c4:	5d                   	pop    %ebp
  8011c5:	c3                   	ret    
  8011c6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8011c9:	eb c4                	jmp    80118f <printnum+0x73>

008011cb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011cb:	55                   	push   %ebp
  8011cc:	89 e5                	mov    %esp,%ebp
  8011ce:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011d1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011d5:	8b 10                	mov    (%eax),%edx
  8011d7:	3b 50 04             	cmp    0x4(%eax),%edx
  8011da:	73 0a                	jae    8011e6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8011dc:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011df:	89 08                	mov    %ecx,(%eax)
  8011e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e4:	88 02                	mov    %al,(%edx)
}
  8011e6:	5d                   	pop    %ebp
  8011e7:	c3                   	ret    

008011e8 <printfmt>:
{
  8011e8:	55                   	push   %ebp
  8011e9:	89 e5                	mov    %esp,%ebp
  8011eb:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8011ee:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011f1:	50                   	push   %eax
  8011f2:	ff 75 10             	pushl  0x10(%ebp)
  8011f5:	ff 75 0c             	pushl  0xc(%ebp)
  8011f8:	ff 75 08             	pushl  0x8(%ebp)
  8011fb:	e8 05 00 00 00       	call   801205 <vprintfmt>
}
  801200:	83 c4 10             	add    $0x10,%esp
  801203:	c9                   	leave  
  801204:	c3                   	ret    

00801205 <vprintfmt>:
{
  801205:	55                   	push   %ebp
  801206:	89 e5                	mov    %esp,%ebp
  801208:	57                   	push   %edi
  801209:	56                   	push   %esi
  80120a:	53                   	push   %ebx
  80120b:	83 ec 2c             	sub    $0x2c,%esp
  80120e:	8b 75 08             	mov    0x8(%ebp),%esi
  801211:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801214:	8b 7d 10             	mov    0x10(%ebp),%edi
  801217:	e9 c1 03 00 00       	jmp    8015dd <vprintfmt+0x3d8>
		padc = ' ';
  80121c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  801220:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  801227:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80122e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801235:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80123a:	8d 47 01             	lea    0x1(%edi),%eax
  80123d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801240:	0f b6 17             	movzbl (%edi),%edx
  801243:	8d 42 dd             	lea    -0x23(%edx),%eax
  801246:	3c 55                	cmp    $0x55,%al
  801248:	0f 87 12 04 00 00    	ja     801660 <vprintfmt+0x45b>
  80124e:	0f b6 c0             	movzbl %al,%eax
  801251:	ff 24 85 80 20 80 00 	jmp    *0x802080(,%eax,4)
  801258:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80125b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80125f:	eb d9                	jmp    80123a <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801261:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  801264:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801268:	eb d0                	jmp    80123a <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80126a:	0f b6 d2             	movzbl %dl,%edx
  80126d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801270:	b8 00 00 00 00       	mov    $0x0,%eax
  801275:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801278:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80127b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80127f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801282:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801285:	83 f9 09             	cmp    $0x9,%ecx
  801288:	77 55                	ja     8012df <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80128a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80128d:	eb e9                	jmp    801278 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80128f:	8b 45 14             	mov    0x14(%ebp),%eax
  801292:	8b 00                	mov    (%eax),%eax
  801294:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801297:	8b 45 14             	mov    0x14(%ebp),%eax
  80129a:	8d 40 04             	lea    0x4(%eax),%eax
  80129d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8012a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8012a3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8012a7:	79 91                	jns    80123a <vprintfmt+0x35>
				width = precision, precision = -1;
  8012a9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8012ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8012af:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012b6:	eb 82                	jmp    80123a <vprintfmt+0x35>
  8012b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012bb:	85 c0                	test   %eax,%eax
  8012bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8012c2:	0f 49 d0             	cmovns %eax,%edx
  8012c5:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8012c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012cb:	e9 6a ff ff ff       	jmp    80123a <vprintfmt+0x35>
  8012d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8012d3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012da:	e9 5b ff ff ff       	jmp    80123a <vprintfmt+0x35>
  8012df:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012e2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012e5:	eb bc                	jmp    8012a3 <vprintfmt+0x9e>
			lflag++;
  8012e7:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8012ed:	e9 48 ff ff ff       	jmp    80123a <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8012f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8012f5:	8d 78 04             	lea    0x4(%eax),%edi
  8012f8:	83 ec 08             	sub    $0x8,%esp
  8012fb:	53                   	push   %ebx
  8012fc:	ff 30                	pushl  (%eax)
  8012fe:	ff d6                	call   *%esi
			break;
  801300:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  801303:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  801306:	e9 cf 02 00 00       	jmp    8015da <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  80130b:	8b 45 14             	mov    0x14(%ebp),%eax
  80130e:	8d 78 04             	lea    0x4(%eax),%edi
  801311:	8b 00                	mov    (%eax),%eax
  801313:	99                   	cltd   
  801314:	31 d0                	xor    %edx,%eax
  801316:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801318:	83 f8 0f             	cmp    $0xf,%eax
  80131b:	7f 23                	jg     801340 <vprintfmt+0x13b>
  80131d:	8b 14 85 e0 21 80 00 	mov    0x8021e0(,%eax,4),%edx
  801324:	85 d2                	test   %edx,%edx
  801326:	74 18                	je     801340 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  801328:	52                   	push   %edx
  801329:	68 dd 1e 80 00       	push   $0x801edd
  80132e:	53                   	push   %ebx
  80132f:	56                   	push   %esi
  801330:	e8 b3 fe ff ff       	call   8011e8 <printfmt>
  801335:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801338:	89 7d 14             	mov    %edi,0x14(%ebp)
  80133b:	e9 9a 02 00 00       	jmp    8015da <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  801340:	50                   	push   %eax
  801341:	68 5f 1f 80 00       	push   $0x801f5f
  801346:	53                   	push   %ebx
  801347:	56                   	push   %esi
  801348:	e8 9b fe ff ff       	call   8011e8 <printfmt>
  80134d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801350:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801353:	e9 82 02 00 00       	jmp    8015da <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  801358:	8b 45 14             	mov    0x14(%ebp),%eax
  80135b:	83 c0 04             	add    $0x4,%eax
  80135e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801361:	8b 45 14             	mov    0x14(%ebp),%eax
  801364:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801366:	85 ff                	test   %edi,%edi
  801368:	b8 58 1f 80 00       	mov    $0x801f58,%eax
  80136d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801370:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801374:	0f 8e bd 00 00 00    	jle    801437 <vprintfmt+0x232>
  80137a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80137e:	75 0e                	jne    80138e <vprintfmt+0x189>
  801380:	89 75 08             	mov    %esi,0x8(%ebp)
  801383:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801386:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801389:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80138c:	eb 6d                	jmp    8013fb <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80138e:	83 ec 08             	sub    $0x8,%esp
  801391:	ff 75 d0             	pushl  -0x30(%ebp)
  801394:	57                   	push   %edi
  801395:	e8 6e 03 00 00       	call   801708 <strnlen>
  80139a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80139d:	29 c1                	sub    %eax,%ecx
  80139f:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8013a2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013a5:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013ac:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013af:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8013b1:	eb 0f                	jmp    8013c2 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8013b3:	83 ec 08             	sub    $0x8,%esp
  8013b6:	53                   	push   %ebx
  8013b7:	ff 75 e0             	pushl  -0x20(%ebp)
  8013ba:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8013bc:	83 ef 01             	sub    $0x1,%edi
  8013bf:	83 c4 10             	add    $0x10,%esp
  8013c2:	85 ff                	test   %edi,%edi
  8013c4:	7f ed                	jg     8013b3 <vprintfmt+0x1ae>
  8013c6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013c9:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8013cc:	85 c9                	test   %ecx,%ecx
  8013ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8013d3:	0f 49 c1             	cmovns %ecx,%eax
  8013d6:	29 c1                	sub    %eax,%ecx
  8013d8:	89 75 08             	mov    %esi,0x8(%ebp)
  8013db:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8013de:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8013e1:	89 cb                	mov    %ecx,%ebx
  8013e3:	eb 16                	jmp    8013fb <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8013e5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013e9:	75 31                	jne    80141c <vprintfmt+0x217>
					putch(ch, putdat);
  8013eb:	83 ec 08             	sub    $0x8,%esp
  8013ee:	ff 75 0c             	pushl  0xc(%ebp)
  8013f1:	50                   	push   %eax
  8013f2:	ff 55 08             	call   *0x8(%ebp)
  8013f5:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013f8:	83 eb 01             	sub    $0x1,%ebx
  8013fb:	83 c7 01             	add    $0x1,%edi
  8013fe:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  801402:	0f be c2             	movsbl %dl,%eax
  801405:	85 c0                	test   %eax,%eax
  801407:	74 59                	je     801462 <vprintfmt+0x25d>
  801409:	85 f6                	test   %esi,%esi
  80140b:	78 d8                	js     8013e5 <vprintfmt+0x1e0>
  80140d:	83 ee 01             	sub    $0x1,%esi
  801410:	79 d3                	jns    8013e5 <vprintfmt+0x1e0>
  801412:	89 df                	mov    %ebx,%edi
  801414:	8b 75 08             	mov    0x8(%ebp),%esi
  801417:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80141a:	eb 37                	jmp    801453 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  80141c:	0f be d2             	movsbl %dl,%edx
  80141f:	83 ea 20             	sub    $0x20,%edx
  801422:	83 fa 5e             	cmp    $0x5e,%edx
  801425:	76 c4                	jbe    8013eb <vprintfmt+0x1e6>
					putch('?', putdat);
  801427:	83 ec 08             	sub    $0x8,%esp
  80142a:	ff 75 0c             	pushl  0xc(%ebp)
  80142d:	6a 3f                	push   $0x3f
  80142f:	ff 55 08             	call   *0x8(%ebp)
  801432:	83 c4 10             	add    $0x10,%esp
  801435:	eb c1                	jmp    8013f8 <vprintfmt+0x1f3>
  801437:	89 75 08             	mov    %esi,0x8(%ebp)
  80143a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80143d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801440:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801443:	eb b6                	jmp    8013fb <vprintfmt+0x1f6>
				putch(' ', putdat);
  801445:	83 ec 08             	sub    $0x8,%esp
  801448:	53                   	push   %ebx
  801449:	6a 20                	push   $0x20
  80144b:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80144d:	83 ef 01             	sub    $0x1,%edi
  801450:	83 c4 10             	add    $0x10,%esp
  801453:	85 ff                	test   %edi,%edi
  801455:	7f ee                	jg     801445 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  801457:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80145a:	89 45 14             	mov    %eax,0x14(%ebp)
  80145d:	e9 78 01 00 00       	jmp    8015da <vprintfmt+0x3d5>
  801462:	89 df                	mov    %ebx,%edi
  801464:	8b 75 08             	mov    0x8(%ebp),%esi
  801467:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80146a:	eb e7                	jmp    801453 <vprintfmt+0x24e>
	if (lflag >= 2)
  80146c:	83 f9 01             	cmp    $0x1,%ecx
  80146f:	7e 3f                	jle    8014b0 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  801471:	8b 45 14             	mov    0x14(%ebp),%eax
  801474:	8b 50 04             	mov    0x4(%eax),%edx
  801477:	8b 00                	mov    (%eax),%eax
  801479:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80147c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80147f:	8b 45 14             	mov    0x14(%ebp),%eax
  801482:	8d 40 08             	lea    0x8(%eax),%eax
  801485:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801488:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80148c:	79 5c                	jns    8014ea <vprintfmt+0x2e5>
				putch('-', putdat);
  80148e:	83 ec 08             	sub    $0x8,%esp
  801491:	53                   	push   %ebx
  801492:	6a 2d                	push   $0x2d
  801494:	ff d6                	call   *%esi
				num = -(long long) num;
  801496:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801499:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80149c:	f7 da                	neg    %edx
  80149e:	83 d1 00             	adc    $0x0,%ecx
  8014a1:	f7 d9                	neg    %ecx
  8014a3:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8014a6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014ab:	e9 10 01 00 00       	jmp    8015c0 <vprintfmt+0x3bb>
	else if (lflag)
  8014b0:	85 c9                	test   %ecx,%ecx
  8014b2:	75 1b                	jne    8014cf <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8014b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b7:	8b 00                	mov    (%eax),%eax
  8014b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014bc:	89 c1                	mov    %eax,%ecx
  8014be:	c1 f9 1f             	sar    $0x1f,%ecx
  8014c1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c7:	8d 40 04             	lea    0x4(%eax),%eax
  8014ca:	89 45 14             	mov    %eax,0x14(%ebp)
  8014cd:	eb b9                	jmp    801488 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8014cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d2:	8b 00                	mov    (%eax),%eax
  8014d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014d7:	89 c1                	mov    %eax,%ecx
  8014d9:	c1 f9 1f             	sar    $0x1f,%ecx
  8014dc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014df:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e2:	8d 40 04             	lea    0x4(%eax),%eax
  8014e5:	89 45 14             	mov    %eax,0x14(%ebp)
  8014e8:	eb 9e                	jmp    801488 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8014ea:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014ed:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8014f0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014f5:	e9 c6 00 00 00       	jmp    8015c0 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8014fa:	83 f9 01             	cmp    $0x1,%ecx
  8014fd:	7e 18                	jle    801517 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8014ff:	8b 45 14             	mov    0x14(%ebp),%eax
  801502:	8b 10                	mov    (%eax),%edx
  801504:	8b 48 04             	mov    0x4(%eax),%ecx
  801507:	8d 40 08             	lea    0x8(%eax),%eax
  80150a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80150d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801512:	e9 a9 00 00 00       	jmp    8015c0 <vprintfmt+0x3bb>
	else if (lflag)
  801517:	85 c9                	test   %ecx,%ecx
  801519:	75 1a                	jne    801535 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  80151b:	8b 45 14             	mov    0x14(%ebp),%eax
  80151e:	8b 10                	mov    (%eax),%edx
  801520:	b9 00 00 00 00       	mov    $0x0,%ecx
  801525:	8d 40 04             	lea    0x4(%eax),%eax
  801528:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80152b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801530:	e9 8b 00 00 00       	jmp    8015c0 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801535:	8b 45 14             	mov    0x14(%ebp),%eax
  801538:	8b 10                	mov    (%eax),%edx
  80153a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80153f:	8d 40 04             	lea    0x4(%eax),%eax
  801542:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801545:	b8 0a 00 00 00       	mov    $0xa,%eax
  80154a:	eb 74                	jmp    8015c0 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80154c:	83 f9 01             	cmp    $0x1,%ecx
  80154f:	7e 15                	jle    801566 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  801551:	8b 45 14             	mov    0x14(%ebp),%eax
  801554:	8b 10                	mov    (%eax),%edx
  801556:	8b 48 04             	mov    0x4(%eax),%ecx
  801559:	8d 40 08             	lea    0x8(%eax),%eax
  80155c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80155f:	b8 08 00 00 00       	mov    $0x8,%eax
  801564:	eb 5a                	jmp    8015c0 <vprintfmt+0x3bb>
	else if (lflag)
  801566:	85 c9                	test   %ecx,%ecx
  801568:	75 17                	jne    801581 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80156a:	8b 45 14             	mov    0x14(%ebp),%eax
  80156d:	8b 10                	mov    (%eax),%edx
  80156f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801574:	8d 40 04             	lea    0x4(%eax),%eax
  801577:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80157a:	b8 08 00 00 00       	mov    $0x8,%eax
  80157f:	eb 3f                	jmp    8015c0 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801581:	8b 45 14             	mov    0x14(%ebp),%eax
  801584:	8b 10                	mov    (%eax),%edx
  801586:	b9 00 00 00 00       	mov    $0x0,%ecx
  80158b:	8d 40 04             	lea    0x4(%eax),%eax
  80158e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801591:	b8 08 00 00 00       	mov    $0x8,%eax
  801596:	eb 28                	jmp    8015c0 <vprintfmt+0x3bb>
			putch('0', putdat);
  801598:	83 ec 08             	sub    $0x8,%esp
  80159b:	53                   	push   %ebx
  80159c:	6a 30                	push   $0x30
  80159e:	ff d6                	call   *%esi
			putch('x', putdat);
  8015a0:	83 c4 08             	add    $0x8,%esp
  8015a3:	53                   	push   %ebx
  8015a4:	6a 78                	push   $0x78
  8015a6:	ff d6                	call   *%esi
			num = (unsigned long long)
  8015a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8015ab:	8b 10                	mov    (%eax),%edx
  8015ad:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8015b2:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8015b5:	8d 40 04             	lea    0x4(%eax),%eax
  8015b8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015bb:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8015c0:	83 ec 0c             	sub    $0xc,%esp
  8015c3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015c7:	57                   	push   %edi
  8015c8:	ff 75 e0             	pushl  -0x20(%ebp)
  8015cb:	50                   	push   %eax
  8015cc:	51                   	push   %ecx
  8015cd:	52                   	push   %edx
  8015ce:	89 da                	mov    %ebx,%edx
  8015d0:	89 f0                	mov    %esi,%eax
  8015d2:	e8 45 fb ff ff       	call   80111c <printnum>
			break;
  8015d7:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8015da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015dd:	83 c7 01             	add    $0x1,%edi
  8015e0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015e4:	83 f8 25             	cmp    $0x25,%eax
  8015e7:	0f 84 2f fc ff ff    	je     80121c <vprintfmt+0x17>
			if (ch == '\0')
  8015ed:	85 c0                	test   %eax,%eax
  8015ef:	0f 84 8b 00 00 00    	je     801680 <vprintfmt+0x47b>
			putch(ch, putdat);
  8015f5:	83 ec 08             	sub    $0x8,%esp
  8015f8:	53                   	push   %ebx
  8015f9:	50                   	push   %eax
  8015fa:	ff d6                	call   *%esi
  8015fc:	83 c4 10             	add    $0x10,%esp
  8015ff:	eb dc                	jmp    8015dd <vprintfmt+0x3d8>
	if (lflag >= 2)
  801601:	83 f9 01             	cmp    $0x1,%ecx
  801604:	7e 15                	jle    80161b <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  801606:	8b 45 14             	mov    0x14(%ebp),%eax
  801609:	8b 10                	mov    (%eax),%edx
  80160b:	8b 48 04             	mov    0x4(%eax),%ecx
  80160e:	8d 40 08             	lea    0x8(%eax),%eax
  801611:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801614:	b8 10 00 00 00       	mov    $0x10,%eax
  801619:	eb a5                	jmp    8015c0 <vprintfmt+0x3bb>
	else if (lflag)
  80161b:	85 c9                	test   %ecx,%ecx
  80161d:	75 17                	jne    801636 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  80161f:	8b 45 14             	mov    0x14(%ebp),%eax
  801622:	8b 10                	mov    (%eax),%edx
  801624:	b9 00 00 00 00       	mov    $0x0,%ecx
  801629:	8d 40 04             	lea    0x4(%eax),%eax
  80162c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80162f:	b8 10 00 00 00       	mov    $0x10,%eax
  801634:	eb 8a                	jmp    8015c0 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801636:	8b 45 14             	mov    0x14(%ebp),%eax
  801639:	8b 10                	mov    (%eax),%edx
  80163b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801640:	8d 40 04             	lea    0x4(%eax),%eax
  801643:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801646:	b8 10 00 00 00       	mov    $0x10,%eax
  80164b:	e9 70 ff ff ff       	jmp    8015c0 <vprintfmt+0x3bb>
			putch(ch, putdat);
  801650:	83 ec 08             	sub    $0x8,%esp
  801653:	53                   	push   %ebx
  801654:	6a 25                	push   $0x25
  801656:	ff d6                	call   *%esi
			break;
  801658:	83 c4 10             	add    $0x10,%esp
  80165b:	e9 7a ff ff ff       	jmp    8015da <vprintfmt+0x3d5>
			putch('%', putdat);
  801660:	83 ec 08             	sub    $0x8,%esp
  801663:	53                   	push   %ebx
  801664:	6a 25                	push   $0x25
  801666:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801668:	83 c4 10             	add    $0x10,%esp
  80166b:	89 f8                	mov    %edi,%eax
  80166d:	eb 03                	jmp    801672 <vprintfmt+0x46d>
  80166f:	83 e8 01             	sub    $0x1,%eax
  801672:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801676:	75 f7                	jne    80166f <vprintfmt+0x46a>
  801678:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80167b:	e9 5a ff ff ff       	jmp    8015da <vprintfmt+0x3d5>
}
  801680:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801683:	5b                   	pop    %ebx
  801684:	5e                   	pop    %esi
  801685:	5f                   	pop    %edi
  801686:	5d                   	pop    %ebp
  801687:	c3                   	ret    

00801688 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801688:	55                   	push   %ebp
  801689:	89 e5                	mov    %esp,%ebp
  80168b:	83 ec 18             	sub    $0x18,%esp
  80168e:	8b 45 08             	mov    0x8(%ebp),%eax
  801691:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801694:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801697:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80169b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80169e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8016a5:	85 c0                	test   %eax,%eax
  8016a7:	74 26                	je     8016cf <vsnprintf+0x47>
  8016a9:	85 d2                	test   %edx,%edx
  8016ab:	7e 22                	jle    8016cf <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8016ad:	ff 75 14             	pushl  0x14(%ebp)
  8016b0:	ff 75 10             	pushl  0x10(%ebp)
  8016b3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8016b6:	50                   	push   %eax
  8016b7:	68 cb 11 80 00       	push   $0x8011cb
  8016bc:	e8 44 fb ff ff       	call   801205 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016c4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ca:	83 c4 10             	add    $0x10,%esp
}
  8016cd:	c9                   	leave  
  8016ce:	c3                   	ret    
		return -E_INVAL;
  8016cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016d4:	eb f7                	jmp    8016cd <vsnprintf+0x45>

008016d6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016d6:	55                   	push   %ebp
  8016d7:	89 e5                	mov    %esp,%ebp
  8016d9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016dc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016df:	50                   	push   %eax
  8016e0:	ff 75 10             	pushl  0x10(%ebp)
  8016e3:	ff 75 0c             	pushl  0xc(%ebp)
  8016e6:	ff 75 08             	pushl  0x8(%ebp)
  8016e9:	e8 9a ff ff ff       	call   801688 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016ee:	c9                   	leave  
  8016ef:	c3                   	ret    

008016f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8016fb:	eb 03                	jmp    801700 <strlen+0x10>
		n++;
  8016fd:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801700:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801704:	75 f7                	jne    8016fd <strlen+0xd>
	return n;
}
  801706:	5d                   	pop    %ebp
  801707:	c3                   	ret    

00801708 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801708:	55                   	push   %ebp
  801709:	89 e5                	mov    %esp,%ebp
  80170b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80170e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801711:	b8 00 00 00 00       	mov    $0x0,%eax
  801716:	eb 03                	jmp    80171b <strnlen+0x13>
		n++;
  801718:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80171b:	39 d0                	cmp    %edx,%eax
  80171d:	74 06                	je     801725 <strnlen+0x1d>
  80171f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801723:	75 f3                	jne    801718 <strnlen+0x10>
	return n;
}
  801725:	5d                   	pop    %ebp
  801726:	c3                   	ret    

00801727 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801727:	55                   	push   %ebp
  801728:	89 e5                	mov    %esp,%ebp
  80172a:	53                   	push   %ebx
  80172b:	8b 45 08             	mov    0x8(%ebp),%eax
  80172e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801731:	89 c2                	mov    %eax,%edx
  801733:	83 c1 01             	add    $0x1,%ecx
  801736:	83 c2 01             	add    $0x1,%edx
  801739:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80173d:	88 5a ff             	mov    %bl,-0x1(%edx)
  801740:	84 db                	test   %bl,%bl
  801742:	75 ef                	jne    801733 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801744:	5b                   	pop    %ebx
  801745:	5d                   	pop    %ebp
  801746:	c3                   	ret    

00801747 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801747:	55                   	push   %ebp
  801748:	89 e5                	mov    %esp,%ebp
  80174a:	53                   	push   %ebx
  80174b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80174e:	53                   	push   %ebx
  80174f:	e8 9c ff ff ff       	call   8016f0 <strlen>
  801754:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801757:	ff 75 0c             	pushl  0xc(%ebp)
  80175a:	01 d8                	add    %ebx,%eax
  80175c:	50                   	push   %eax
  80175d:	e8 c5 ff ff ff       	call   801727 <strcpy>
	return dst;
}
  801762:	89 d8                	mov    %ebx,%eax
  801764:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801767:	c9                   	leave  
  801768:	c3                   	ret    

00801769 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801769:	55                   	push   %ebp
  80176a:	89 e5                	mov    %esp,%ebp
  80176c:	56                   	push   %esi
  80176d:	53                   	push   %ebx
  80176e:	8b 75 08             	mov    0x8(%ebp),%esi
  801771:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801774:	89 f3                	mov    %esi,%ebx
  801776:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801779:	89 f2                	mov    %esi,%edx
  80177b:	eb 0f                	jmp    80178c <strncpy+0x23>
		*dst++ = *src;
  80177d:	83 c2 01             	add    $0x1,%edx
  801780:	0f b6 01             	movzbl (%ecx),%eax
  801783:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801786:	80 39 01             	cmpb   $0x1,(%ecx)
  801789:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80178c:	39 da                	cmp    %ebx,%edx
  80178e:	75 ed                	jne    80177d <strncpy+0x14>
	}
	return ret;
}
  801790:	89 f0                	mov    %esi,%eax
  801792:	5b                   	pop    %ebx
  801793:	5e                   	pop    %esi
  801794:	5d                   	pop    %ebp
  801795:	c3                   	ret    

00801796 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801796:	55                   	push   %ebp
  801797:	89 e5                	mov    %esp,%ebp
  801799:	56                   	push   %esi
  80179a:	53                   	push   %ebx
  80179b:	8b 75 08             	mov    0x8(%ebp),%esi
  80179e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017a1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017a4:	89 f0                	mov    %esi,%eax
  8017a6:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8017aa:	85 c9                	test   %ecx,%ecx
  8017ac:	75 0b                	jne    8017b9 <strlcpy+0x23>
  8017ae:	eb 17                	jmp    8017c7 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8017b0:	83 c2 01             	add    $0x1,%edx
  8017b3:	83 c0 01             	add    $0x1,%eax
  8017b6:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8017b9:	39 d8                	cmp    %ebx,%eax
  8017bb:	74 07                	je     8017c4 <strlcpy+0x2e>
  8017bd:	0f b6 0a             	movzbl (%edx),%ecx
  8017c0:	84 c9                	test   %cl,%cl
  8017c2:	75 ec                	jne    8017b0 <strlcpy+0x1a>
		*dst = '\0';
  8017c4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017c7:	29 f0                	sub    %esi,%eax
}
  8017c9:	5b                   	pop    %ebx
  8017ca:	5e                   	pop    %esi
  8017cb:	5d                   	pop    %ebp
  8017cc:	c3                   	ret    

008017cd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017cd:	55                   	push   %ebp
  8017ce:	89 e5                	mov    %esp,%ebp
  8017d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017d3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017d6:	eb 06                	jmp    8017de <strcmp+0x11>
		p++, q++;
  8017d8:	83 c1 01             	add    $0x1,%ecx
  8017db:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8017de:	0f b6 01             	movzbl (%ecx),%eax
  8017e1:	84 c0                	test   %al,%al
  8017e3:	74 04                	je     8017e9 <strcmp+0x1c>
  8017e5:	3a 02                	cmp    (%edx),%al
  8017e7:	74 ef                	je     8017d8 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017e9:	0f b6 c0             	movzbl %al,%eax
  8017ec:	0f b6 12             	movzbl (%edx),%edx
  8017ef:	29 d0                	sub    %edx,%eax
}
  8017f1:	5d                   	pop    %ebp
  8017f2:	c3                   	ret    

008017f3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017f3:	55                   	push   %ebp
  8017f4:	89 e5                	mov    %esp,%ebp
  8017f6:	53                   	push   %ebx
  8017f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017fd:	89 c3                	mov    %eax,%ebx
  8017ff:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801802:	eb 06                	jmp    80180a <strncmp+0x17>
		n--, p++, q++;
  801804:	83 c0 01             	add    $0x1,%eax
  801807:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80180a:	39 d8                	cmp    %ebx,%eax
  80180c:	74 16                	je     801824 <strncmp+0x31>
  80180e:	0f b6 08             	movzbl (%eax),%ecx
  801811:	84 c9                	test   %cl,%cl
  801813:	74 04                	je     801819 <strncmp+0x26>
  801815:	3a 0a                	cmp    (%edx),%cl
  801817:	74 eb                	je     801804 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801819:	0f b6 00             	movzbl (%eax),%eax
  80181c:	0f b6 12             	movzbl (%edx),%edx
  80181f:	29 d0                	sub    %edx,%eax
}
  801821:	5b                   	pop    %ebx
  801822:	5d                   	pop    %ebp
  801823:	c3                   	ret    
		return 0;
  801824:	b8 00 00 00 00       	mov    $0x0,%eax
  801829:	eb f6                	jmp    801821 <strncmp+0x2e>

0080182b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80182b:	55                   	push   %ebp
  80182c:	89 e5                	mov    %esp,%ebp
  80182e:	8b 45 08             	mov    0x8(%ebp),%eax
  801831:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801835:	0f b6 10             	movzbl (%eax),%edx
  801838:	84 d2                	test   %dl,%dl
  80183a:	74 09                	je     801845 <strchr+0x1a>
		if (*s == c)
  80183c:	38 ca                	cmp    %cl,%dl
  80183e:	74 0a                	je     80184a <strchr+0x1f>
	for (; *s; s++)
  801840:	83 c0 01             	add    $0x1,%eax
  801843:	eb f0                	jmp    801835 <strchr+0xa>
			return (char *) s;
	return 0;
  801845:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80184a:	5d                   	pop    %ebp
  80184b:	c3                   	ret    

0080184c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80184c:	55                   	push   %ebp
  80184d:	89 e5                	mov    %esp,%ebp
  80184f:	8b 45 08             	mov    0x8(%ebp),%eax
  801852:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801856:	eb 03                	jmp    80185b <strfind+0xf>
  801858:	83 c0 01             	add    $0x1,%eax
  80185b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80185e:	38 ca                	cmp    %cl,%dl
  801860:	74 04                	je     801866 <strfind+0x1a>
  801862:	84 d2                	test   %dl,%dl
  801864:	75 f2                	jne    801858 <strfind+0xc>
			break;
	return (char *) s;
}
  801866:	5d                   	pop    %ebp
  801867:	c3                   	ret    

00801868 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801868:	55                   	push   %ebp
  801869:	89 e5                	mov    %esp,%ebp
  80186b:	57                   	push   %edi
  80186c:	56                   	push   %esi
  80186d:	53                   	push   %ebx
  80186e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801871:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801874:	85 c9                	test   %ecx,%ecx
  801876:	74 13                	je     80188b <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801878:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80187e:	75 05                	jne    801885 <memset+0x1d>
  801880:	f6 c1 03             	test   $0x3,%cl
  801883:	74 0d                	je     801892 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801885:	8b 45 0c             	mov    0xc(%ebp),%eax
  801888:	fc                   	cld    
  801889:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80188b:	89 f8                	mov    %edi,%eax
  80188d:	5b                   	pop    %ebx
  80188e:	5e                   	pop    %esi
  80188f:	5f                   	pop    %edi
  801890:	5d                   	pop    %ebp
  801891:	c3                   	ret    
		c &= 0xFF;
  801892:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801896:	89 d3                	mov    %edx,%ebx
  801898:	c1 e3 08             	shl    $0x8,%ebx
  80189b:	89 d0                	mov    %edx,%eax
  80189d:	c1 e0 18             	shl    $0x18,%eax
  8018a0:	89 d6                	mov    %edx,%esi
  8018a2:	c1 e6 10             	shl    $0x10,%esi
  8018a5:	09 f0                	or     %esi,%eax
  8018a7:	09 c2                	or     %eax,%edx
  8018a9:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8018ab:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8018ae:	89 d0                	mov    %edx,%eax
  8018b0:	fc                   	cld    
  8018b1:	f3 ab                	rep stos %eax,%es:(%edi)
  8018b3:	eb d6                	jmp    80188b <memset+0x23>

008018b5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018b5:	55                   	push   %ebp
  8018b6:	89 e5                	mov    %esp,%ebp
  8018b8:	57                   	push   %edi
  8018b9:	56                   	push   %esi
  8018ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018c3:	39 c6                	cmp    %eax,%esi
  8018c5:	73 35                	jae    8018fc <memmove+0x47>
  8018c7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018ca:	39 c2                	cmp    %eax,%edx
  8018cc:	76 2e                	jbe    8018fc <memmove+0x47>
		s += n;
		d += n;
  8018ce:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018d1:	89 d6                	mov    %edx,%esi
  8018d3:	09 fe                	or     %edi,%esi
  8018d5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018db:	74 0c                	je     8018e9 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018dd:	83 ef 01             	sub    $0x1,%edi
  8018e0:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8018e3:	fd                   	std    
  8018e4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018e6:	fc                   	cld    
  8018e7:	eb 21                	jmp    80190a <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018e9:	f6 c1 03             	test   $0x3,%cl
  8018ec:	75 ef                	jne    8018dd <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8018ee:	83 ef 04             	sub    $0x4,%edi
  8018f1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018f4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8018f7:	fd                   	std    
  8018f8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018fa:	eb ea                	jmp    8018e6 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018fc:	89 f2                	mov    %esi,%edx
  8018fe:	09 c2                	or     %eax,%edx
  801900:	f6 c2 03             	test   $0x3,%dl
  801903:	74 09                	je     80190e <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801905:	89 c7                	mov    %eax,%edi
  801907:	fc                   	cld    
  801908:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80190a:	5e                   	pop    %esi
  80190b:	5f                   	pop    %edi
  80190c:	5d                   	pop    %ebp
  80190d:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80190e:	f6 c1 03             	test   $0x3,%cl
  801911:	75 f2                	jne    801905 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801913:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801916:	89 c7                	mov    %eax,%edi
  801918:	fc                   	cld    
  801919:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80191b:	eb ed                	jmp    80190a <memmove+0x55>

0080191d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80191d:	55                   	push   %ebp
  80191e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801920:	ff 75 10             	pushl  0x10(%ebp)
  801923:	ff 75 0c             	pushl  0xc(%ebp)
  801926:	ff 75 08             	pushl  0x8(%ebp)
  801929:	e8 87 ff ff ff       	call   8018b5 <memmove>
}
  80192e:	c9                   	leave  
  80192f:	c3                   	ret    

00801930 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801930:	55                   	push   %ebp
  801931:	89 e5                	mov    %esp,%ebp
  801933:	56                   	push   %esi
  801934:	53                   	push   %ebx
  801935:	8b 45 08             	mov    0x8(%ebp),%eax
  801938:	8b 55 0c             	mov    0xc(%ebp),%edx
  80193b:	89 c6                	mov    %eax,%esi
  80193d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801940:	39 f0                	cmp    %esi,%eax
  801942:	74 1c                	je     801960 <memcmp+0x30>
		if (*s1 != *s2)
  801944:	0f b6 08             	movzbl (%eax),%ecx
  801947:	0f b6 1a             	movzbl (%edx),%ebx
  80194a:	38 d9                	cmp    %bl,%cl
  80194c:	75 08                	jne    801956 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80194e:	83 c0 01             	add    $0x1,%eax
  801951:	83 c2 01             	add    $0x1,%edx
  801954:	eb ea                	jmp    801940 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  801956:	0f b6 c1             	movzbl %cl,%eax
  801959:	0f b6 db             	movzbl %bl,%ebx
  80195c:	29 d8                	sub    %ebx,%eax
  80195e:	eb 05                	jmp    801965 <memcmp+0x35>
	}

	return 0;
  801960:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801965:	5b                   	pop    %ebx
  801966:	5e                   	pop    %esi
  801967:	5d                   	pop    %ebp
  801968:	c3                   	ret    

00801969 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801969:	55                   	push   %ebp
  80196a:	89 e5                	mov    %esp,%ebp
  80196c:	8b 45 08             	mov    0x8(%ebp),%eax
  80196f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801972:	89 c2                	mov    %eax,%edx
  801974:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801977:	39 d0                	cmp    %edx,%eax
  801979:	73 09                	jae    801984 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80197b:	38 08                	cmp    %cl,(%eax)
  80197d:	74 05                	je     801984 <memfind+0x1b>
	for (; s < ends; s++)
  80197f:	83 c0 01             	add    $0x1,%eax
  801982:	eb f3                	jmp    801977 <memfind+0xe>
			break;
	return (void *) s;
}
  801984:	5d                   	pop    %ebp
  801985:	c3                   	ret    

00801986 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801986:	55                   	push   %ebp
  801987:	89 e5                	mov    %esp,%ebp
  801989:	57                   	push   %edi
  80198a:	56                   	push   %esi
  80198b:	53                   	push   %ebx
  80198c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80198f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801992:	eb 03                	jmp    801997 <strtol+0x11>
		s++;
  801994:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801997:	0f b6 01             	movzbl (%ecx),%eax
  80199a:	3c 20                	cmp    $0x20,%al
  80199c:	74 f6                	je     801994 <strtol+0xe>
  80199e:	3c 09                	cmp    $0x9,%al
  8019a0:	74 f2                	je     801994 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8019a2:	3c 2b                	cmp    $0x2b,%al
  8019a4:	74 2e                	je     8019d4 <strtol+0x4e>
	int neg = 0;
  8019a6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8019ab:	3c 2d                	cmp    $0x2d,%al
  8019ad:	74 2f                	je     8019de <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019af:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019b5:	75 05                	jne    8019bc <strtol+0x36>
  8019b7:	80 39 30             	cmpb   $0x30,(%ecx)
  8019ba:	74 2c                	je     8019e8 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019bc:	85 db                	test   %ebx,%ebx
  8019be:	75 0a                	jne    8019ca <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019c0:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  8019c5:	80 39 30             	cmpb   $0x30,(%ecx)
  8019c8:	74 28                	je     8019f2 <strtol+0x6c>
		base = 10;
  8019ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8019cf:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8019d2:	eb 50                	jmp    801a24 <strtol+0x9e>
		s++;
  8019d4:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8019d7:	bf 00 00 00 00       	mov    $0x0,%edi
  8019dc:	eb d1                	jmp    8019af <strtol+0x29>
		s++, neg = 1;
  8019de:	83 c1 01             	add    $0x1,%ecx
  8019e1:	bf 01 00 00 00       	mov    $0x1,%edi
  8019e6:	eb c7                	jmp    8019af <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019e8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019ec:	74 0e                	je     8019fc <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8019ee:	85 db                	test   %ebx,%ebx
  8019f0:	75 d8                	jne    8019ca <strtol+0x44>
		s++, base = 8;
  8019f2:	83 c1 01             	add    $0x1,%ecx
  8019f5:	bb 08 00 00 00       	mov    $0x8,%ebx
  8019fa:	eb ce                	jmp    8019ca <strtol+0x44>
		s += 2, base = 16;
  8019fc:	83 c1 02             	add    $0x2,%ecx
  8019ff:	bb 10 00 00 00       	mov    $0x10,%ebx
  801a04:	eb c4                	jmp    8019ca <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  801a06:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a09:	89 f3                	mov    %esi,%ebx
  801a0b:	80 fb 19             	cmp    $0x19,%bl
  801a0e:	77 29                	ja     801a39 <strtol+0xb3>
			dig = *s - 'a' + 10;
  801a10:	0f be d2             	movsbl %dl,%edx
  801a13:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801a16:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a19:	7d 30                	jge    801a4b <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801a1b:	83 c1 01             	add    $0x1,%ecx
  801a1e:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a22:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801a24:	0f b6 11             	movzbl (%ecx),%edx
  801a27:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a2a:	89 f3                	mov    %esi,%ebx
  801a2c:	80 fb 09             	cmp    $0x9,%bl
  801a2f:	77 d5                	ja     801a06 <strtol+0x80>
			dig = *s - '0';
  801a31:	0f be d2             	movsbl %dl,%edx
  801a34:	83 ea 30             	sub    $0x30,%edx
  801a37:	eb dd                	jmp    801a16 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  801a39:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a3c:	89 f3                	mov    %esi,%ebx
  801a3e:	80 fb 19             	cmp    $0x19,%bl
  801a41:	77 08                	ja     801a4b <strtol+0xc5>
			dig = *s - 'A' + 10;
  801a43:	0f be d2             	movsbl %dl,%edx
  801a46:	83 ea 37             	sub    $0x37,%edx
  801a49:	eb cb                	jmp    801a16 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  801a4b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a4f:	74 05                	je     801a56 <strtol+0xd0>
		*endptr = (char *) s;
  801a51:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a54:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a56:	89 c2                	mov    %eax,%edx
  801a58:	f7 da                	neg    %edx
  801a5a:	85 ff                	test   %edi,%edi
  801a5c:	0f 45 c2             	cmovne %edx,%eax
}
  801a5f:	5b                   	pop    %ebx
  801a60:	5e                   	pop    %esi
  801a61:	5f                   	pop    %edi
  801a62:	5d                   	pop    %ebp
  801a63:	c3                   	ret    

00801a64 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a64:	55                   	push   %ebp
  801a65:	89 e5                	mov    %esp,%ebp
  801a67:	56                   	push   %esi
  801a68:	53                   	push   %ebx
  801a69:	8b 75 08             	mov    0x8(%ebp),%esi
  801a6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        //	panic("ipc_recv not implemented");
        int r;
       	if(pg!=NULL){
  801a72:	85 c0                	test   %eax,%eax
  801a74:	74 3b                	je     801ab1 <ipc_recv+0x4d>
	  r = sys_ipc_recv(pg);
  801a76:	83 ec 0c             	sub    $0xc,%esp
  801a79:	50                   	push   %eax
  801a7a:	e8 b2 e8 ff ff       	call   800331 <sys_ipc_recv>
  801a7f:	83 c4 10             	add    $0x10,%esp
	}else
	  r = sys_ipc_recv((void *)UTOP);
	if(r<0){
  801a82:	85 c0                	test   %eax,%eax
  801a84:	78 3d                	js     801ac3 <ipc_recv+0x5f>
	if(perm_store!=NULL){
		*perm_store = 0;
            }
        	return r;
           }else{
	     if(from_env_store!=NULL)
  801a86:	85 f6                	test   %esi,%esi
  801a88:	74 0a                	je     801a94 <ipc_recv+0x30>
		     *from_env_store = thisenv->env_ipc_from;
  801a8a:	a1 04 40 80 00       	mov    0x804004,%eax
  801a8f:	8b 40 74             	mov    0x74(%eax),%eax
  801a92:	89 06                	mov    %eax,(%esi)
	     if(perm_store != NULL)
  801a94:	85 db                	test   %ebx,%ebx
  801a96:	74 0a                	je     801aa2 <ipc_recv+0x3e>
		     *perm_store = thisenv->env_ipc_perm;
  801a98:	a1 04 40 80 00       	mov    0x804004,%eax
  801a9d:	8b 40 78             	mov    0x78(%eax),%eax
  801aa0:	89 03                	mov    %eax,(%ebx)
	     return thisenv->env_ipc_value;
  801aa2:	a1 04 40 80 00       	mov    0x804004,%eax
  801aa7:	8b 40 70             	mov    0x70(%eax),%eax
	   }

}
  801aaa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aad:	5b                   	pop    %ebx
  801aae:	5e                   	pop    %esi
  801aaf:	5d                   	pop    %ebp
  801ab0:	c3                   	ret    
	  r = sys_ipc_recv((void *)UTOP);
  801ab1:	83 ec 0c             	sub    $0xc,%esp
  801ab4:	68 00 00 c0 ee       	push   $0xeec00000
  801ab9:	e8 73 e8 ff ff       	call   800331 <sys_ipc_recv>
  801abe:	83 c4 10             	add    $0x10,%esp
  801ac1:	eb bf                	jmp    801a82 <ipc_recv+0x1e>
	if(from_env_store!=NULL){
  801ac3:	85 f6                	test   %esi,%esi
  801ac5:	74 06                	je     801acd <ipc_recv+0x69>
	  *from_env_store = 0;
  801ac7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(perm_store!=NULL){
  801acd:	85 db                	test   %ebx,%ebx
  801acf:	74 d9                	je     801aaa <ipc_recv+0x46>
		*perm_store = 0;
  801ad1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ad7:	eb d1                	jmp    801aaa <ipc_recv+0x46>

00801ad9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ad9:	55                   	push   %ebp
  801ada:	89 e5                	mov    %esp,%ebp
  801adc:	57                   	push   %edi
  801add:	56                   	push   %esi
  801ade:	53                   	push   %ebx
  801adf:	83 ec 0c             	sub    $0xc,%esp
  801ae2:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ae5:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ae8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if(pg==NULL) pg = (void *)UTOP;
  801aeb:	85 db                	test   %ebx,%ebx
  801aed:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801af2:	0f 44 d8             	cmove  %eax,%ebx
	while((r=sys_ipc_try_send(to_env,val,pg,perm))<0){
  801af5:	ff 75 14             	pushl  0x14(%ebp)
  801af8:	53                   	push   %ebx
  801af9:	56                   	push   %esi
  801afa:	57                   	push   %edi
  801afb:	e8 0e e8 ff ff       	call   80030e <sys_ipc_try_send>
  801b00:	83 c4 10             	add    $0x10,%esp
  801b03:	85 c0                	test   %eax,%eax
  801b05:	79 20                	jns    801b27 <ipc_send+0x4e>
	    if(r!=-E_IPC_NOT_RECV){
  801b07:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b0a:	75 07                	jne    801b13 <ipc_send+0x3a>
		    panic("ipc_send:send message failed\n");
	    }
	    sys_yield();
  801b0c:	e8 51 e6 ff ff       	call   800162 <sys_yield>
  801b11:	eb e2                	jmp    801af5 <ipc_send+0x1c>
		    panic("ipc_send:send message failed\n");
  801b13:	83 ec 04             	sub    $0x4,%esp
  801b16:	68 40 22 80 00       	push   $0x802240
  801b1b:	6a 43                	push   $0x43
  801b1d:	68 5e 22 80 00       	push   $0x80225e
  801b22:	e8 06 f5 ff ff       	call   80102d <_panic>
	}

}
  801b27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b2a:	5b                   	pop    %ebx
  801b2b:	5e                   	pop    %esi
  801b2c:	5f                   	pop    %edi
  801b2d:	5d                   	pop    %ebp
  801b2e:	c3                   	ret    

00801b2f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b2f:	55                   	push   %ebp
  801b30:	89 e5                	mov    %esp,%ebp
  801b32:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b35:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b3a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b3d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b43:	8b 52 50             	mov    0x50(%edx),%edx
  801b46:	39 ca                	cmp    %ecx,%edx
  801b48:	74 11                	je     801b5b <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801b4a:	83 c0 01             	add    $0x1,%eax
  801b4d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b52:	75 e6                	jne    801b3a <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801b54:	b8 00 00 00 00       	mov    $0x0,%eax
  801b59:	eb 0b                	jmp    801b66 <ipc_find_env+0x37>
			return envs[i].env_id;
  801b5b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b5e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b63:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b66:	5d                   	pop    %ebp
  801b67:	c3                   	ret    

00801b68 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b68:	55                   	push   %ebp
  801b69:	89 e5                	mov    %esp,%ebp
  801b6b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b6e:	89 d0                	mov    %edx,%eax
  801b70:	c1 e8 16             	shr    $0x16,%eax
  801b73:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b7a:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801b7f:	f6 c1 01             	test   $0x1,%cl
  801b82:	74 1d                	je     801ba1 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801b84:	c1 ea 0c             	shr    $0xc,%edx
  801b87:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b8e:	f6 c2 01             	test   $0x1,%dl
  801b91:	74 0e                	je     801ba1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b93:	c1 ea 0c             	shr    $0xc,%edx
  801b96:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b9d:	ef 
  801b9e:	0f b7 c0             	movzwl %ax,%eax
}
  801ba1:	5d                   	pop    %ebp
  801ba2:	c3                   	ret    
  801ba3:	66 90                	xchg   %ax,%ax
  801ba5:	66 90                	xchg   %ax,%ax
  801ba7:	66 90                	xchg   %ax,%ax
  801ba9:	66 90                	xchg   %ax,%ax
  801bab:	66 90                	xchg   %ax,%ax
  801bad:	66 90                	xchg   %ax,%ax
  801baf:	90                   	nop

00801bb0 <__udivdi3>:
  801bb0:	55                   	push   %ebp
  801bb1:	57                   	push   %edi
  801bb2:	56                   	push   %esi
  801bb3:	53                   	push   %ebx
  801bb4:	83 ec 1c             	sub    $0x1c,%esp
  801bb7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801bbb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801bbf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801bc3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801bc7:	85 d2                	test   %edx,%edx
  801bc9:	75 35                	jne    801c00 <__udivdi3+0x50>
  801bcb:	39 f3                	cmp    %esi,%ebx
  801bcd:	0f 87 bd 00 00 00    	ja     801c90 <__udivdi3+0xe0>
  801bd3:	85 db                	test   %ebx,%ebx
  801bd5:	89 d9                	mov    %ebx,%ecx
  801bd7:	75 0b                	jne    801be4 <__udivdi3+0x34>
  801bd9:	b8 01 00 00 00       	mov    $0x1,%eax
  801bde:	31 d2                	xor    %edx,%edx
  801be0:	f7 f3                	div    %ebx
  801be2:	89 c1                	mov    %eax,%ecx
  801be4:	31 d2                	xor    %edx,%edx
  801be6:	89 f0                	mov    %esi,%eax
  801be8:	f7 f1                	div    %ecx
  801bea:	89 c6                	mov    %eax,%esi
  801bec:	89 e8                	mov    %ebp,%eax
  801bee:	89 f7                	mov    %esi,%edi
  801bf0:	f7 f1                	div    %ecx
  801bf2:	89 fa                	mov    %edi,%edx
  801bf4:	83 c4 1c             	add    $0x1c,%esp
  801bf7:	5b                   	pop    %ebx
  801bf8:	5e                   	pop    %esi
  801bf9:	5f                   	pop    %edi
  801bfa:	5d                   	pop    %ebp
  801bfb:	c3                   	ret    
  801bfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c00:	39 f2                	cmp    %esi,%edx
  801c02:	77 7c                	ja     801c80 <__udivdi3+0xd0>
  801c04:	0f bd fa             	bsr    %edx,%edi
  801c07:	83 f7 1f             	xor    $0x1f,%edi
  801c0a:	0f 84 98 00 00 00    	je     801ca8 <__udivdi3+0xf8>
  801c10:	89 f9                	mov    %edi,%ecx
  801c12:	b8 20 00 00 00       	mov    $0x20,%eax
  801c17:	29 f8                	sub    %edi,%eax
  801c19:	d3 e2                	shl    %cl,%edx
  801c1b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c1f:	89 c1                	mov    %eax,%ecx
  801c21:	89 da                	mov    %ebx,%edx
  801c23:	d3 ea                	shr    %cl,%edx
  801c25:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801c29:	09 d1                	or     %edx,%ecx
  801c2b:	89 f2                	mov    %esi,%edx
  801c2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c31:	89 f9                	mov    %edi,%ecx
  801c33:	d3 e3                	shl    %cl,%ebx
  801c35:	89 c1                	mov    %eax,%ecx
  801c37:	d3 ea                	shr    %cl,%edx
  801c39:	89 f9                	mov    %edi,%ecx
  801c3b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c3f:	d3 e6                	shl    %cl,%esi
  801c41:	89 eb                	mov    %ebp,%ebx
  801c43:	89 c1                	mov    %eax,%ecx
  801c45:	d3 eb                	shr    %cl,%ebx
  801c47:	09 de                	or     %ebx,%esi
  801c49:	89 f0                	mov    %esi,%eax
  801c4b:	f7 74 24 08          	divl   0x8(%esp)
  801c4f:	89 d6                	mov    %edx,%esi
  801c51:	89 c3                	mov    %eax,%ebx
  801c53:	f7 64 24 0c          	mull   0xc(%esp)
  801c57:	39 d6                	cmp    %edx,%esi
  801c59:	72 0c                	jb     801c67 <__udivdi3+0xb7>
  801c5b:	89 f9                	mov    %edi,%ecx
  801c5d:	d3 e5                	shl    %cl,%ebp
  801c5f:	39 c5                	cmp    %eax,%ebp
  801c61:	73 5d                	jae    801cc0 <__udivdi3+0x110>
  801c63:	39 d6                	cmp    %edx,%esi
  801c65:	75 59                	jne    801cc0 <__udivdi3+0x110>
  801c67:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801c6a:	31 ff                	xor    %edi,%edi
  801c6c:	89 fa                	mov    %edi,%edx
  801c6e:	83 c4 1c             	add    $0x1c,%esp
  801c71:	5b                   	pop    %ebx
  801c72:	5e                   	pop    %esi
  801c73:	5f                   	pop    %edi
  801c74:	5d                   	pop    %ebp
  801c75:	c3                   	ret    
  801c76:	8d 76 00             	lea    0x0(%esi),%esi
  801c79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801c80:	31 ff                	xor    %edi,%edi
  801c82:	31 c0                	xor    %eax,%eax
  801c84:	89 fa                	mov    %edi,%edx
  801c86:	83 c4 1c             	add    $0x1c,%esp
  801c89:	5b                   	pop    %ebx
  801c8a:	5e                   	pop    %esi
  801c8b:	5f                   	pop    %edi
  801c8c:	5d                   	pop    %ebp
  801c8d:	c3                   	ret    
  801c8e:	66 90                	xchg   %ax,%ax
  801c90:	31 ff                	xor    %edi,%edi
  801c92:	89 e8                	mov    %ebp,%eax
  801c94:	89 f2                	mov    %esi,%edx
  801c96:	f7 f3                	div    %ebx
  801c98:	89 fa                	mov    %edi,%edx
  801c9a:	83 c4 1c             	add    $0x1c,%esp
  801c9d:	5b                   	pop    %ebx
  801c9e:	5e                   	pop    %esi
  801c9f:	5f                   	pop    %edi
  801ca0:	5d                   	pop    %ebp
  801ca1:	c3                   	ret    
  801ca2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ca8:	39 f2                	cmp    %esi,%edx
  801caa:	72 06                	jb     801cb2 <__udivdi3+0x102>
  801cac:	31 c0                	xor    %eax,%eax
  801cae:	39 eb                	cmp    %ebp,%ebx
  801cb0:	77 d2                	ja     801c84 <__udivdi3+0xd4>
  801cb2:	b8 01 00 00 00       	mov    $0x1,%eax
  801cb7:	eb cb                	jmp    801c84 <__udivdi3+0xd4>
  801cb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cc0:	89 d8                	mov    %ebx,%eax
  801cc2:	31 ff                	xor    %edi,%edi
  801cc4:	eb be                	jmp    801c84 <__udivdi3+0xd4>
  801cc6:	66 90                	xchg   %ax,%ax
  801cc8:	66 90                	xchg   %ax,%ax
  801cca:	66 90                	xchg   %ax,%ax
  801ccc:	66 90                	xchg   %ax,%ax
  801cce:	66 90                	xchg   %ax,%ax

00801cd0 <__umoddi3>:
  801cd0:	55                   	push   %ebp
  801cd1:	57                   	push   %edi
  801cd2:	56                   	push   %esi
  801cd3:	53                   	push   %ebx
  801cd4:	83 ec 1c             	sub    $0x1c,%esp
  801cd7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801cdb:	8b 74 24 30          	mov    0x30(%esp),%esi
  801cdf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801ce3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ce7:	85 ed                	test   %ebp,%ebp
  801ce9:	89 f0                	mov    %esi,%eax
  801ceb:	89 da                	mov    %ebx,%edx
  801ced:	75 19                	jne    801d08 <__umoddi3+0x38>
  801cef:	39 df                	cmp    %ebx,%edi
  801cf1:	0f 86 b1 00 00 00    	jbe    801da8 <__umoddi3+0xd8>
  801cf7:	f7 f7                	div    %edi
  801cf9:	89 d0                	mov    %edx,%eax
  801cfb:	31 d2                	xor    %edx,%edx
  801cfd:	83 c4 1c             	add    $0x1c,%esp
  801d00:	5b                   	pop    %ebx
  801d01:	5e                   	pop    %esi
  801d02:	5f                   	pop    %edi
  801d03:	5d                   	pop    %ebp
  801d04:	c3                   	ret    
  801d05:	8d 76 00             	lea    0x0(%esi),%esi
  801d08:	39 dd                	cmp    %ebx,%ebp
  801d0a:	77 f1                	ja     801cfd <__umoddi3+0x2d>
  801d0c:	0f bd cd             	bsr    %ebp,%ecx
  801d0f:	83 f1 1f             	xor    $0x1f,%ecx
  801d12:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801d16:	0f 84 b4 00 00 00    	je     801dd0 <__umoddi3+0x100>
  801d1c:	b8 20 00 00 00       	mov    $0x20,%eax
  801d21:	89 c2                	mov    %eax,%edx
  801d23:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d27:	29 c2                	sub    %eax,%edx
  801d29:	89 c1                	mov    %eax,%ecx
  801d2b:	89 f8                	mov    %edi,%eax
  801d2d:	d3 e5                	shl    %cl,%ebp
  801d2f:	89 d1                	mov    %edx,%ecx
  801d31:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801d35:	d3 e8                	shr    %cl,%eax
  801d37:	09 c5                	or     %eax,%ebp
  801d39:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d3d:	89 c1                	mov    %eax,%ecx
  801d3f:	d3 e7                	shl    %cl,%edi
  801d41:	89 d1                	mov    %edx,%ecx
  801d43:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801d47:	89 df                	mov    %ebx,%edi
  801d49:	d3 ef                	shr    %cl,%edi
  801d4b:	89 c1                	mov    %eax,%ecx
  801d4d:	89 f0                	mov    %esi,%eax
  801d4f:	d3 e3                	shl    %cl,%ebx
  801d51:	89 d1                	mov    %edx,%ecx
  801d53:	89 fa                	mov    %edi,%edx
  801d55:	d3 e8                	shr    %cl,%eax
  801d57:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801d5c:	09 d8                	or     %ebx,%eax
  801d5e:	f7 f5                	div    %ebp
  801d60:	d3 e6                	shl    %cl,%esi
  801d62:	89 d1                	mov    %edx,%ecx
  801d64:	f7 64 24 08          	mull   0x8(%esp)
  801d68:	39 d1                	cmp    %edx,%ecx
  801d6a:	89 c3                	mov    %eax,%ebx
  801d6c:	89 d7                	mov    %edx,%edi
  801d6e:	72 06                	jb     801d76 <__umoddi3+0xa6>
  801d70:	75 0e                	jne    801d80 <__umoddi3+0xb0>
  801d72:	39 c6                	cmp    %eax,%esi
  801d74:	73 0a                	jae    801d80 <__umoddi3+0xb0>
  801d76:	2b 44 24 08          	sub    0x8(%esp),%eax
  801d7a:	19 ea                	sbb    %ebp,%edx
  801d7c:	89 d7                	mov    %edx,%edi
  801d7e:	89 c3                	mov    %eax,%ebx
  801d80:	89 ca                	mov    %ecx,%edx
  801d82:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801d87:	29 de                	sub    %ebx,%esi
  801d89:	19 fa                	sbb    %edi,%edx
  801d8b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  801d8f:	89 d0                	mov    %edx,%eax
  801d91:	d3 e0                	shl    %cl,%eax
  801d93:	89 d9                	mov    %ebx,%ecx
  801d95:	d3 ee                	shr    %cl,%esi
  801d97:	d3 ea                	shr    %cl,%edx
  801d99:	09 f0                	or     %esi,%eax
  801d9b:	83 c4 1c             	add    $0x1c,%esp
  801d9e:	5b                   	pop    %ebx
  801d9f:	5e                   	pop    %esi
  801da0:	5f                   	pop    %edi
  801da1:	5d                   	pop    %ebp
  801da2:	c3                   	ret    
  801da3:	90                   	nop
  801da4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801da8:	85 ff                	test   %edi,%edi
  801daa:	89 f9                	mov    %edi,%ecx
  801dac:	75 0b                	jne    801db9 <__umoddi3+0xe9>
  801dae:	b8 01 00 00 00       	mov    $0x1,%eax
  801db3:	31 d2                	xor    %edx,%edx
  801db5:	f7 f7                	div    %edi
  801db7:	89 c1                	mov    %eax,%ecx
  801db9:	89 d8                	mov    %ebx,%eax
  801dbb:	31 d2                	xor    %edx,%edx
  801dbd:	f7 f1                	div    %ecx
  801dbf:	89 f0                	mov    %esi,%eax
  801dc1:	f7 f1                	div    %ecx
  801dc3:	e9 31 ff ff ff       	jmp    801cf9 <__umoddi3+0x29>
  801dc8:	90                   	nop
  801dc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dd0:	39 dd                	cmp    %ebx,%ebp
  801dd2:	72 08                	jb     801ddc <__umoddi3+0x10c>
  801dd4:	39 f7                	cmp    %esi,%edi
  801dd6:	0f 87 21 ff ff ff    	ja     801cfd <__umoddi3+0x2d>
  801ddc:	89 da                	mov    %ebx,%edx
  801dde:	89 f0                	mov    %esi,%eax
  801de0:	29 f8                	sub    %edi,%eax
  801de2:	19 ea                	sbb    %ebp,%edx
  801de4:	e9 14 ff ff ff       	jmp    801cfd <__umoddi3+0x2d>
