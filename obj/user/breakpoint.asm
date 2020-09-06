
obj/user/breakpoint.debug:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	56                   	push   %esi
  80003d:	53                   	push   %ebx
  80003e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800041:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800044:	e8 ce 00 00 00       	call   800117 <sys_getenvid>
  800049:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800051:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800056:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005b:	85 db                	test   %ebx,%ebx
  80005d:	7e 07                	jle    800066 <libmain+0x2d>
		binaryname = argv[0];
  80005f:	8b 06                	mov    (%esi),%eax
  800061:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800066:	83 ec 08             	sub    $0x8,%esp
  800069:	56                   	push   %esi
  80006a:	53                   	push   %ebx
  80006b:	e8 c3 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800070:	e8 0a 00 00 00       	call   80007f <exit>
}
  800075:	83 c4 10             	add    $0x10,%esp
  800078:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007b:	5b                   	pop    %ebx
  80007c:	5e                   	pop    %esi
  80007d:	5d                   	pop    %ebp
  80007e:	c3                   	ret    

0080007f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007f:	55                   	push   %ebp
  800080:	89 e5                	mov    %esp,%ebp
  800082:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800085:	e8 92 04 00 00       	call   80051c <close_all>
	sys_env_destroy(0);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	e8 42 00 00 00       	call   8000d6 <sys_env_destroy>
}
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	c9                   	leave  
  800098:	c3                   	ret    

00800099 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	57                   	push   %edi
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80009f:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000aa:	89 c3                	mov    %eax,%ebx
  8000ac:	89 c7                	mov    %eax,%edi
  8000ae:	89 c6                	mov    %eax,%esi
  8000b0:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b2:	5b                   	pop    %ebx
  8000b3:	5e                   	pop    %esi
  8000b4:	5f                   	pop    %edi
  8000b5:	5d                   	pop    %ebp
  8000b6:	c3                   	ret    

008000b7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	57                   	push   %edi
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c7:	89 d1                	mov    %edx,%ecx
  8000c9:	89 d3                	mov    %edx,%ebx
  8000cb:	89 d7                	mov    %edx,%edi
  8000cd:	89 d6                	mov    %edx,%esi
  8000cf:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5f                   	pop    %edi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    

008000d6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	57                   	push   %edi
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e7:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ec:	89 cb                	mov    %ecx,%ebx
  8000ee:	89 cf                	mov    %ecx,%edi
  8000f0:	89 ce                	mov    %ecx,%esi
  8000f2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000f4:	85 c0                	test   %eax,%eax
  8000f6:	7f 08                	jg     800100 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000fb:	5b                   	pop    %ebx
  8000fc:	5e                   	pop    %esi
  8000fd:	5f                   	pop    %edi
  8000fe:	5d                   	pop    %ebp
  8000ff:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800100:	83 ec 0c             	sub    $0xc,%esp
  800103:	50                   	push   %eax
  800104:	6a 03                	push   $0x3
  800106:	68 ca 1d 80 00       	push   $0x801dca
  80010b:	6a 23                	push   $0x23
  80010d:	68 e7 1d 80 00       	push   $0x801de7
  800112:	e8 ea 0e 00 00       	call   801001 <_panic>

00800117 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	57                   	push   %edi
  80011b:	56                   	push   %esi
  80011c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80011d:	ba 00 00 00 00       	mov    $0x0,%edx
  800122:	b8 02 00 00 00       	mov    $0x2,%eax
  800127:	89 d1                	mov    %edx,%ecx
  800129:	89 d3                	mov    %edx,%ebx
  80012b:	89 d7                	mov    %edx,%edi
  80012d:	89 d6                	mov    %edx,%esi
  80012f:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800131:	5b                   	pop    %ebx
  800132:	5e                   	pop    %esi
  800133:	5f                   	pop    %edi
  800134:	5d                   	pop    %ebp
  800135:	c3                   	ret    

00800136 <sys_yield>:

void
sys_yield(void)
{
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	57                   	push   %edi
  80013a:	56                   	push   %esi
  80013b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80013c:	ba 00 00 00 00       	mov    $0x0,%edx
  800141:	b8 0b 00 00 00       	mov    $0xb,%eax
  800146:	89 d1                	mov    %edx,%ecx
  800148:	89 d3                	mov    %edx,%ebx
  80014a:	89 d7                	mov    %edx,%edi
  80014c:	89 d6                	mov    %edx,%esi
  80014e:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800150:	5b                   	pop    %ebx
  800151:	5e                   	pop    %esi
  800152:	5f                   	pop    %edi
  800153:	5d                   	pop    %ebp
  800154:	c3                   	ret    

00800155 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	57                   	push   %edi
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
  80015b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80015e:	be 00 00 00 00       	mov    $0x0,%esi
  800163:	8b 55 08             	mov    0x8(%ebp),%edx
  800166:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800169:	b8 04 00 00 00       	mov    $0x4,%eax
  80016e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800171:	89 f7                	mov    %esi,%edi
  800173:	cd 30                	int    $0x30
	if(check && ret > 0)
  800175:	85 c0                	test   %eax,%eax
  800177:	7f 08                	jg     800181 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800179:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80017c:	5b                   	pop    %ebx
  80017d:	5e                   	pop    %esi
  80017e:	5f                   	pop    %edi
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	50                   	push   %eax
  800185:	6a 04                	push   $0x4
  800187:	68 ca 1d 80 00       	push   $0x801dca
  80018c:	6a 23                	push   $0x23
  80018e:	68 e7 1d 80 00       	push   $0x801de7
  800193:	e8 69 0e 00 00       	call   801001 <_panic>

00800198 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	57                   	push   %edi
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a7:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001af:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b2:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b5:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001b7:	85 c0                	test   %eax,%eax
  8001b9:	7f 08                	jg     8001c3 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001be:	5b                   	pop    %ebx
  8001bf:	5e                   	pop    %esi
  8001c0:	5f                   	pop    %edi
  8001c1:	5d                   	pop    %ebp
  8001c2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c3:	83 ec 0c             	sub    $0xc,%esp
  8001c6:	50                   	push   %eax
  8001c7:	6a 05                	push   $0x5
  8001c9:	68 ca 1d 80 00       	push   $0x801dca
  8001ce:	6a 23                	push   $0x23
  8001d0:	68 e7 1d 80 00       	push   $0x801de7
  8001d5:	e8 27 0e 00 00       	call   801001 <_panic>

008001da <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	57                   	push   %edi
  8001de:	56                   	push   %esi
  8001df:	53                   	push   %ebx
  8001e0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ee:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f3:	89 df                	mov    %ebx,%edi
  8001f5:	89 de                	mov    %ebx,%esi
  8001f7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001f9:	85 c0                	test   %eax,%eax
  8001fb:	7f 08                	jg     800205 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8001fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800200:	5b                   	pop    %ebx
  800201:	5e                   	pop    %esi
  800202:	5f                   	pop    %edi
  800203:	5d                   	pop    %ebp
  800204:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800205:	83 ec 0c             	sub    $0xc,%esp
  800208:	50                   	push   %eax
  800209:	6a 06                	push   $0x6
  80020b:	68 ca 1d 80 00       	push   $0x801dca
  800210:	6a 23                	push   $0x23
  800212:	68 e7 1d 80 00       	push   $0x801de7
  800217:	e8 e5 0d 00 00       	call   801001 <_panic>

0080021c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	57                   	push   %edi
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800225:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022a:	8b 55 08             	mov    0x8(%ebp),%edx
  80022d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800230:	b8 08 00 00 00       	mov    $0x8,%eax
  800235:	89 df                	mov    %ebx,%edi
  800237:	89 de                	mov    %ebx,%esi
  800239:	cd 30                	int    $0x30
	if(check && ret > 0)
  80023b:	85 c0                	test   %eax,%eax
  80023d:	7f 08                	jg     800247 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80023f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800242:	5b                   	pop    %ebx
  800243:	5e                   	pop    %esi
  800244:	5f                   	pop    %edi
  800245:	5d                   	pop    %ebp
  800246:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800247:	83 ec 0c             	sub    $0xc,%esp
  80024a:	50                   	push   %eax
  80024b:	6a 08                	push   $0x8
  80024d:	68 ca 1d 80 00       	push   $0x801dca
  800252:	6a 23                	push   $0x23
  800254:	68 e7 1d 80 00       	push   $0x801de7
  800259:	e8 a3 0d 00 00       	call   801001 <_panic>

0080025e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	57                   	push   %edi
  800262:	56                   	push   %esi
  800263:	53                   	push   %ebx
  800264:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800267:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026c:	8b 55 08             	mov    0x8(%ebp),%edx
  80026f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800272:	b8 09 00 00 00       	mov    $0x9,%eax
  800277:	89 df                	mov    %ebx,%edi
  800279:	89 de                	mov    %ebx,%esi
  80027b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80027d:	85 c0                	test   %eax,%eax
  80027f:	7f 08                	jg     800289 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800281:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800284:	5b                   	pop    %ebx
  800285:	5e                   	pop    %esi
  800286:	5f                   	pop    %edi
  800287:	5d                   	pop    %ebp
  800288:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800289:	83 ec 0c             	sub    $0xc,%esp
  80028c:	50                   	push   %eax
  80028d:	6a 09                	push   $0x9
  80028f:	68 ca 1d 80 00       	push   $0x801dca
  800294:	6a 23                	push   $0x23
  800296:	68 e7 1d 80 00       	push   $0x801de7
  80029b:	e8 61 0d 00 00       	call   801001 <_panic>

008002a0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b9:	89 df                	mov    %ebx,%edi
  8002bb:	89 de                	mov    %ebx,%esi
  8002bd:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002bf:	85 c0                	test   %eax,%eax
  8002c1:	7f 08                	jg     8002cb <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c6:	5b                   	pop    %ebx
  8002c7:	5e                   	pop    %esi
  8002c8:	5f                   	pop    %edi
  8002c9:	5d                   	pop    %ebp
  8002ca:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002cb:	83 ec 0c             	sub    $0xc,%esp
  8002ce:	50                   	push   %eax
  8002cf:	6a 0a                	push   $0xa
  8002d1:	68 ca 1d 80 00       	push   $0x801dca
  8002d6:	6a 23                	push   $0x23
  8002d8:	68 e7 1d 80 00       	push   $0x801de7
  8002dd:	e8 1f 0d 00 00       	call   801001 <_panic>

008002e2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
  8002e5:	57                   	push   %edi
  8002e6:	56                   	push   %esi
  8002e7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8002eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ee:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f3:	be 00 00 00 00       	mov    $0x0,%esi
  8002f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002fe:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800300:	5b                   	pop    %ebx
  800301:	5e                   	pop    %esi
  800302:	5f                   	pop    %edi
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    

00800305 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80030e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800313:	8b 55 08             	mov    0x8(%ebp),%edx
  800316:	b8 0d 00 00 00       	mov    $0xd,%eax
  80031b:	89 cb                	mov    %ecx,%ebx
  80031d:	89 cf                	mov    %ecx,%edi
  80031f:	89 ce                	mov    %ecx,%esi
  800321:	cd 30                	int    $0x30
	if(check && ret > 0)
  800323:	85 c0                	test   %eax,%eax
  800325:	7f 08                	jg     80032f <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800327:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032a:	5b                   	pop    %ebx
  80032b:	5e                   	pop    %esi
  80032c:	5f                   	pop    %edi
  80032d:	5d                   	pop    %ebp
  80032e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80032f:	83 ec 0c             	sub    $0xc,%esp
  800332:	50                   	push   %eax
  800333:	6a 0d                	push   $0xd
  800335:	68 ca 1d 80 00       	push   $0x801dca
  80033a:	6a 23                	push   $0x23
  80033c:	68 e7 1d 80 00       	push   $0x801de7
  800341:	e8 bb 0c 00 00       	call   801001 <_panic>

00800346 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800349:	8b 45 08             	mov    0x8(%ebp),%eax
  80034c:	05 00 00 00 30       	add    $0x30000000,%eax
  800351:	c1 e8 0c             	shr    $0xc,%eax
}
  800354:	5d                   	pop    %ebp
  800355:	c3                   	ret    

00800356 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800356:	55                   	push   %ebp
  800357:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800359:	8b 45 08             	mov    0x8(%ebp),%eax
  80035c:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800361:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800366:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80036b:	5d                   	pop    %ebp
  80036c:	c3                   	ret    

0080036d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80036d:	55                   	push   %ebp
  80036e:	89 e5                	mov    %esp,%ebp
  800370:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800373:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800378:	89 c2                	mov    %eax,%edx
  80037a:	c1 ea 16             	shr    $0x16,%edx
  80037d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800384:	f6 c2 01             	test   $0x1,%dl
  800387:	74 2a                	je     8003b3 <fd_alloc+0x46>
  800389:	89 c2                	mov    %eax,%edx
  80038b:	c1 ea 0c             	shr    $0xc,%edx
  80038e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800395:	f6 c2 01             	test   $0x1,%dl
  800398:	74 19                	je     8003b3 <fd_alloc+0x46>
  80039a:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80039f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003a4:	75 d2                	jne    800378 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003a6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003ac:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8003b1:	eb 07                	jmp    8003ba <fd_alloc+0x4d>
			*fd_store = fd;
  8003b3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003ba:	5d                   	pop    %ebp
  8003bb:	c3                   	ret    

008003bc <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
  8003bf:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c2:	83 f8 1f             	cmp    $0x1f,%eax
  8003c5:	77 36                	ja     8003fd <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003c7:	c1 e0 0c             	shl    $0xc,%eax
  8003ca:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003cf:	89 c2                	mov    %eax,%edx
  8003d1:	c1 ea 16             	shr    $0x16,%edx
  8003d4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003db:	f6 c2 01             	test   $0x1,%dl
  8003de:	74 24                	je     800404 <fd_lookup+0x48>
  8003e0:	89 c2                	mov    %eax,%edx
  8003e2:	c1 ea 0c             	shr    $0xc,%edx
  8003e5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003ec:	f6 c2 01             	test   $0x1,%dl
  8003ef:	74 1a                	je     80040b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f4:	89 02                	mov    %eax,(%edx)
	return 0;
  8003f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003fb:	5d                   	pop    %ebp
  8003fc:	c3                   	ret    
		return -E_INVAL;
  8003fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800402:	eb f7                	jmp    8003fb <fd_lookup+0x3f>
		return -E_INVAL;
  800404:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800409:	eb f0                	jmp    8003fb <fd_lookup+0x3f>
  80040b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800410:	eb e9                	jmp    8003fb <fd_lookup+0x3f>

00800412 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800412:	55                   	push   %ebp
  800413:	89 e5                	mov    %esp,%ebp
  800415:	83 ec 08             	sub    $0x8,%esp
  800418:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80041b:	ba 74 1e 80 00       	mov    $0x801e74,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800420:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800425:	39 08                	cmp    %ecx,(%eax)
  800427:	74 33                	je     80045c <dev_lookup+0x4a>
  800429:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80042c:	8b 02                	mov    (%edx),%eax
  80042e:	85 c0                	test   %eax,%eax
  800430:	75 f3                	jne    800425 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800432:	a1 04 40 80 00       	mov    0x804004,%eax
  800437:	8b 40 48             	mov    0x48(%eax),%eax
  80043a:	83 ec 04             	sub    $0x4,%esp
  80043d:	51                   	push   %ecx
  80043e:	50                   	push   %eax
  80043f:	68 f8 1d 80 00       	push   $0x801df8
  800444:	e8 93 0c 00 00       	call   8010dc <cprintf>
	*dev = 0;
  800449:	8b 45 0c             	mov    0xc(%ebp),%eax
  80044c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800452:	83 c4 10             	add    $0x10,%esp
  800455:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80045a:	c9                   	leave  
  80045b:	c3                   	ret    
			*dev = devtab[i];
  80045c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80045f:	89 01                	mov    %eax,(%ecx)
			return 0;
  800461:	b8 00 00 00 00       	mov    $0x0,%eax
  800466:	eb f2                	jmp    80045a <dev_lookup+0x48>

00800468 <fd_close>:
{
  800468:	55                   	push   %ebp
  800469:	89 e5                	mov    %esp,%ebp
  80046b:	57                   	push   %edi
  80046c:	56                   	push   %esi
  80046d:	53                   	push   %ebx
  80046e:	83 ec 1c             	sub    $0x1c,%esp
  800471:	8b 75 08             	mov    0x8(%ebp),%esi
  800474:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800477:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80047a:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80047b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800481:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800484:	50                   	push   %eax
  800485:	e8 32 ff ff ff       	call   8003bc <fd_lookup>
  80048a:	89 c3                	mov    %eax,%ebx
  80048c:	83 c4 08             	add    $0x8,%esp
  80048f:	85 c0                	test   %eax,%eax
  800491:	78 05                	js     800498 <fd_close+0x30>
	    || fd != fd2)
  800493:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800496:	74 16                	je     8004ae <fd_close+0x46>
		return (must_exist ? r : 0);
  800498:	89 f8                	mov    %edi,%eax
  80049a:	84 c0                	test   %al,%al
  80049c:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a1:	0f 44 d8             	cmove  %eax,%ebx
}
  8004a4:	89 d8                	mov    %ebx,%eax
  8004a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a9:	5b                   	pop    %ebx
  8004aa:	5e                   	pop    %esi
  8004ab:	5f                   	pop    %edi
  8004ac:	5d                   	pop    %ebp
  8004ad:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ae:	83 ec 08             	sub    $0x8,%esp
  8004b1:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8004b4:	50                   	push   %eax
  8004b5:	ff 36                	pushl  (%esi)
  8004b7:	e8 56 ff ff ff       	call   800412 <dev_lookup>
  8004bc:	89 c3                	mov    %eax,%ebx
  8004be:	83 c4 10             	add    $0x10,%esp
  8004c1:	85 c0                	test   %eax,%eax
  8004c3:	78 15                	js     8004da <fd_close+0x72>
		if (dev->dev_close)
  8004c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004c8:	8b 40 10             	mov    0x10(%eax),%eax
  8004cb:	85 c0                	test   %eax,%eax
  8004cd:	74 1b                	je     8004ea <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8004cf:	83 ec 0c             	sub    $0xc,%esp
  8004d2:	56                   	push   %esi
  8004d3:	ff d0                	call   *%eax
  8004d5:	89 c3                	mov    %eax,%ebx
  8004d7:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004da:	83 ec 08             	sub    $0x8,%esp
  8004dd:	56                   	push   %esi
  8004de:	6a 00                	push   $0x0
  8004e0:	e8 f5 fc ff ff       	call   8001da <sys_page_unmap>
	return r;
  8004e5:	83 c4 10             	add    $0x10,%esp
  8004e8:	eb ba                	jmp    8004a4 <fd_close+0x3c>
			r = 0;
  8004ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004ef:	eb e9                	jmp    8004da <fd_close+0x72>

008004f1 <close>:

int
close(int fdnum)
{
  8004f1:	55                   	push   %ebp
  8004f2:	89 e5                	mov    %esp,%ebp
  8004f4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004fa:	50                   	push   %eax
  8004fb:	ff 75 08             	pushl  0x8(%ebp)
  8004fe:	e8 b9 fe ff ff       	call   8003bc <fd_lookup>
  800503:	83 c4 08             	add    $0x8,%esp
  800506:	85 c0                	test   %eax,%eax
  800508:	78 10                	js     80051a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80050a:	83 ec 08             	sub    $0x8,%esp
  80050d:	6a 01                	push   $0x1
  80050f:	ff 75 f4             	pushl  -0xc(%ebp)
  800512:	e8 51 ff ff ff       	call   800468 <fd_close>
  800517:	83 c4 10             	add    $0x10,%esp
}
  80051a:	c9                   	leave  
  80051b:	c3                   	ret    

0080051c <close_all>:

void
close_all(void)
{
  80051c:	55                   	push   %ebp
  80051d:	89 e5                	mov    %esp,%ebp
  80051f:	53                   	push   %ebx
  800520:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800523:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800528:	83 ec 0c             	sub    $0xc,%esp
  80052b:	53                   	push   %ebx
  80052c:	e8 c0 ff ff ff       	call   8004f1 <close>
	for (i = 0; i < MAXFD; i++)
  800531:	83 c3 01             	add    $0x1,%ebx
  800534:	83 c4 10             	add    $0x10,%esp
  800537:	83 fb 20             	cmp    $0x20,%ebx
  80053a:	75 ec                	jne    800528 <close_all+0xc>
}
  80053c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80053f:	c9                   	leave  
  800540:	c3                   	ret    

00800541 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800541:	55                   	push   %ebp
  800542:	89 e5                	mov    %esp,%ebp
  800544:	57                   	push   %edi
  800545:	56                   	push   %esi
  800546:	53                   	push   %ebx
  800547:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80054a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80054d:	50                   	push   %eax
  80054e:	ff 75 08             	pushl  0x8(%ebp)
  800551:	e8 66 fe ff ff       	call   8003bc <fd_lookup>
  800556:	89 c3                	mov    %eax,%ebx
  800558:	83 c4 08             	add    $0x8,%esp
  80055b:	85 c0                	test   %eax,%eax
  80055d:	0f 88 81 00 00 00    	js     8005e4 <dup+0xa3>
		return r;
	close(newfdnum);
  800563:	83 ec 0c             	sub    $0xc,%esp
  800566:	ff 75 0c             	pushl  0xc(%ebp)
  800569:	e8 83 ff ff ff       	call   8004f1 <close>

	newfd = INDEX2FD(newfdnum);
  80056e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800571:	c1 e6 0c             	shl    $0xc,%esi
  800574:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80057a:	83 c4 04             	add    $0x4,%esp
  80057d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800580:	e8 d1 fd ff ff       	call   800356 <fd2data>
  800585:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800587:	89 34 24             	mov    %esi,(%esp)
  80058a:	e8 c7 fd ff ff       	call   800356 <fd2data>
  80058f:	83 c4 10             	add    $0x10,%esp
  800592:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800594:	89 d8                	mov    %ebx,%eax
  800596:	c1 e8 16             	shr    $0x16,%eax
  800599:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a0:	a8 01                	test   $0x1,%al
  8005a2:	74 11                	je     8005b5 <dup+0x74>
  8005a4:	89 d8                	mov    %ebx,%eax
  8005a6:	c1 e8 0c             	shr    $0xc,%eax
  8005a9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b0:	f6 c2 01             	test   $0x1,%dl
  8005b3:	75 39                	jne    8005ee <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005b5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005b8:	89 d0                	mov    %edx,%eax
  8005ba:	c1 e8 0c             	shr    $0xc,%eax
  8005bd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c4:	83 ec 0c             	sub    $0xc,%esp
  8005c7:	25 07 0e 00 00       	and    $0xe07,%eax
  8005cc:	50                   	push   %eax
  8005cd:	56                   	push   %esi
  8005ce:	6a 00                	push   $0x0
  8005d0:	52                   	push   %edx
  8005d1:	6a 00                	push   $0x0
  8005d3:	e8 c0 fb ff ff       	call   800198 <sys_page_map>
  8005d8:	89 c3                	mov    %eax,%ebx
  8005da:	83 c4 20             	add    $0x20,%esp
  8005dd:	85 c0                	test   %eax,%eax
  8005df:	78 31                	js     800612 <dup+0xd1>
		goto err;

	return newfdnum;
  8005e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005e4:	89 d8                	mov    %ebx,%eax
  8005e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005e9:	5b                   	pop    %ebx
  8005ea:	5e                   	pop    %esi
  8005eb:	5f                   	pop    %edi
  8005ec:	5d                   	pop    %ebp
  8005ed:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ee:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005f5:	83 ec 0c             	sub    $0xc,%esp
  8005f8:	25 07 0e 00 00       	and    $0xe07,%eax
  8005fd:	50                   	push   %eax
  8005fe:	57                   	push   %edi
  8005ff:	6a 00                	push   $0x0
  800601:	53                   	push   %ebx
  800602:	6a 00                	push   $0x0
  800604:	e8 8f fb ff ff       	call   800198 <sys_page_map>
  800609:	89 c3                	mov    %eax,%ebx
  80060b:	83 c4 20             	add    $0x20,%esp
  80060e:	85 c0                	test   %eax,%eax
  800610:	79 a3                	jns    8005b5 <dup+0x74>
	sys_page_unmap(0, newfd);
  800612:	83 ec 08             	sub    $0x8,%esp
  800615:	56                   	push   %esi
  800616:	6a 00                	push   $0x0
  800618:	e8 bd fb ff ff       	call   8001da <sys_page_unmap>
	sys_page_unmap(0, nva);
  80061d:	83 c4 08             	add    $0x8,%esp
  800620:	57                   	push   %edi
  800621:	6a 00                	push   $0x0
  800623:	e8 b2 fb ff ff       	call   8001da <sys_page_unmap>
	return r;
  800628:	83 c4 10             	add    $0x10,%esp
  80062b:	eb b7                	jmp    8005e4 <dup+0xa3>

0080062d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80062d:	55                   	push   %ebp
  80062e:	89 e5                	mov    %esp,%ebp
  800630:	53                   	push   %ebx
  800631:	83 ec 14             	sub    $0x14,%esp
  800634:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800637:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80063a:	50                   	push   %eax
  80063b:	53                   	push   %ebx
  80063c:	e8 7b fd ff ff       	call   8003bc <fd_lookup>
  800641:	83 c4 08             	add    $0x8,%esp
  800644:	85 c0                	test   %eax,%eax
  800646:	78 3f                	js     800687 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80064e:	50                   	push   %eax
  80064f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800652:	ff 30                	pushl  (%eax)
  800654:	e8 b9 fd ff ff       	call   800412 <dev_lookup>
  800659:	83 c4 10             	add    $0x10,%esp
  80065c:	85 c0                	test   %eax,%eax
  80065e:	78 27                	js     800687 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800660:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800663:	8b 42 08             	mov    0x8(%edx),%eax
  800666:	83 e0 03             	and    $0x3,%eax
  800669:	83 f8 01             	cmp    $0x1,%eax
  80066c:	74 1e                	je     80068c <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80066e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800671:	8b 40 08             	mov    0x8(%eax),%eax
  800674:	85 c0                	test   %eax,%eax
  800676:	74 35                	je     8006ad <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800678:	83 ec 04             	sub    $0x4,%esp
  80067b:	ff 75 10             	pushl  0x10(%ebp)
  80067e:	ff 75 0c             	pushl  0xc(%ebp)
  800681:	52                   	push   %edx
  800682:	ff d0                	call   *%eax
  800684:	83 c4 10             	add    $0x10,%esp
}
  800687:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80068a:	c9                   	leave  
  80068b:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80068c:	a1 04 40 80 00       	mov    0x804004,%eax
  800691:	8b 40 48             	mov    0x48(%eax),%eax
  800694:	83 ec 04             	sub    $0x4,%esp
  800697:	53                   	push   %ebx
  800698:	50                   	push   %eax
  800699:	68 39 1e 80 00       	push   $0x801e39
  80069e:	e8 39 0a 00 00       	call   8010dc <cprintf>
		return -E_INVAL;
  8006a3:	83 c4 10             	add    $0x10,%esp
  8006a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006ab:	eb da                	jmp    800687 <read+0x5a>
		return -E_NOT_SUPP;
  8006ad:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006b2:	eb d3                	jmp    800687 <read+0x5a>

008006b4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006b4:	55                   	push   %ebp
  8006b5:	89 e5                	mov    %esp,%ebp
  8006b7:	57                   	push   %edi
  8006b8:	56                   	push   %esi
  8006b9:	53                   	push   %ebx
  8006ba:	83 ec 0c             	sub    $0xc,%esp
  8006bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006c8:	39 f3                	cmp    %esi,%ebx
  8006ca:	73 25                	jae    8006f1 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006cc:	83 ec 04             	sub    $0x4,%esp
  8006cf:	89 f0                	mov    %esi,%eax
  8006d1:	29 d8                	sub    %ebx,%eax
  8006d3:	50                   	push   %eax
  8006d4:	89 d8                	mov    %ebx,%eax
  8006d6:	03 45 0c             	add    0xc(%ebp),%eax
  8006d9:	50                   	push   %eax
  8006da:	57                   	push   %edi
  8006db:	e8 4d ff ff ff       	call   80062d <read>
		if (m < 0)
  8006e0:	83 c4 10             	add    $0x10,%esp
  8006e3:	85 c0                	test   %eax,%eax
  8006e5:	78 08                	js     8006ef <readn+0x3b>
			return m;
		if (m == 0)
  8006e7:	85 c0                	test   %eax,%eax
  8006e9:	74 06                	je     8006f1 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  8006eb:	01 c3                	add    %eax,%ebx
  8006ed:	eb d9                	jmp    8006c8 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006ef:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006f1:	89 d8                	mov    %ebx,%eax
  8006f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f6:	5b                   	pop    %ebx
  8006f7:	5e                   	pop    %esi
  8006f8:	5f                   	pop    %edi
  8006f9:	5d                   	pop    %ebp
  8006fa:	c3                   	ret    

008006fb <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006fb:	55                   	push   %ebp
  8006fc:	89 e5                	mov    %esp,%ebp
  8006fe:	53                   	push   %ebx
  8006ff:	83 ec 14             	sub    $0x14,%esp
  800702:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800705:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800708:	50                   	push   %eax
  800709:	53                   	push   %ebx
  80070a:	e8 ad fc ff ff       	call   8003bc <fd_lookup>
  80070f:	83 c4 08             	add    $0x8,%esp
  800712:	85 c0                	test   %eax,%eax
  800714:	78 3a                	js     800750 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800716:	83 ec 08             	sub    $0x8,%esp
  800719:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80071c:	50                   	push   %eax
  80071d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800720:	ff 30                	pushl  (%eax)
  800722:	e8 eb fc ff ff       	call   800412 <dev_lookup>
  800727:	83 c4 10             	add    $0x10,%esp
  80072a:	85 c0                	test   %eax,%eax
  80072c:	78 22                	js     800750 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80072e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800731:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800735:	74 1e                	je     800755 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800737:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80073a:	8b 52 0c             	mov    0xc(%edx),%edx
  80073d:	85 d2                	test   %edx,%edx
  80073f:	74 35                	je     800776 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800741:	83 ec 04             	sub    $0x4,%esp
  800744:	ff 75 10             	pushl  0x10(%ebp)
  800747:	ff 75 0c             	pushl  0xc(%ebp)
  80074a:	50                   	push   %eax
  80074b:	ff d2                	call   *%edx
  80074d:	83 c4 10             	add    $0x10,%esp
}
  800750:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800753:	c9                   	leave  
  800754:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800755:	a1 04 40 80 00       	mov    0x804004,%eax
  80075a:	8b 40 48             	mov    0x48(%eax),%eax
  80075d:	83 ec 04             	sub    $0x4,%esp
  800760:	53                   	push   %ebx
  800761:	50                   	push   %eax
  800762:	68 55 1e 80 00       	push   $0x801e55
  800767:	e8 70 09 00 00       	call   8010dc <cprintf>
		return -E_INVAL;
  80076c:	83 c4 10             	add    $0x10,%esp
  80076f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800774:	eb da                	jmp    800750 <write+0x55>
		return -E_NOT_SUPP;
  800776:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80077b:	eb d3                	jmp    800750 <write+0x55>

0080077d <seek>:

int
seek(int fdnum, off_t offset)
{
  80077d:	55                   	push   %ebp
  80077e:	89 e5                	mov    %esp,%ebp
  800780:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800783:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800786:	50                   	push   %eax
  800787:	ff 75 08             	pushl  0x8(%ebp)
  80078a:	e8 2d fc ff ff       	call   8003bc <fd_lookup>
  80078f:	83 c4 08             	add    $0x8,%esp
  800792:	85 c0                	test   %eax,%eax
  800794:	78 0e                	js     8007a4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800796:	8b 55 0c             	mov    0xc(%ebp),%edx
  800799:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80079c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80079f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007a4:	c9                   	leave  
  8007a5:	c3                   	ret    

008007a6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007a6:	55                   	push   %ebp
  8007a7:	89 e5                	mov    %esp,%ebp
  8007a9:	53                   	push   %ebx
  8007aa:	83 ec 14             	sub    $0x14,%esp
  8007ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007b3:	50                   	push   %eax
  8007b4:	53                   	push   %ebx
  8007b5:	e8 02 fc ff ff       	call   8003bc <fd_lookup>
  8007ba:	83 c4 08             	add    $0x8,%esp
  8007bd:	85 c0                	test   %eax,%eax
  8007bf:	78 37                	js     8007f8 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007c1:	83 ec 08             	sub    $0x8,%esp
  8007c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007c7:	50                   	push   %eax
  8007c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007cb:	ff 30                	pushl  (%eax)
  8007cd:	e8 40 fc ff ff       	call   800412 <dev_lookup>
  8007d2:	83 c4 10             	add    $0x10,%esp
  8007d5:	85 c0                	test   %eax,%eax
  8007d7:	78 1f                	js     8007f8 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007dc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007e0:	74 1b                	je     8007fd <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007e5:	8b 52 18             	mov    0x18(%edx),%edx
  8007e8:	85 d2                	test   %edx,%edx
  8007ea:	74 32                	je     80081e <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007ec:	83 ec 08             	sub    $0x8,%esp
  8007ef:	ff 75 0c             	pushl  0xc(%ebp)
  8007f2:	50                   	push   %eax
  8007f3:	ff d2                	call   *%edx
  8007f5:	83 c4 10             	add    $0x10,%esp
}
  8007f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007fb:	c9                   	leave  
  8007fc:	c3                   	ret    
			thisenv->env_id, fdnum);
  8007fd:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800802:	8b 40 48             	mov    0x48(%eax),%eax
  800805:	83 ec 04             	sub    $0x4,%esp
  800808:	53                   	push   %ebx
  800809:	50                   	push   %eax
  80080a:	68 18 1e 80 00       	push   $0x801e18
  80080f:	e8 c8 08 00 00       	call   8010dc <cprintf>
		return -E_INVAL;
  800814:	83 c4 10             	add    $0x10,%esp
  800817:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80081c:	eb da                	jmp    8007f8 <ftruncate+0x52>
		return -E_NOT_SUPP;
  80081e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800823:	eb d3                	jmp    8007f8 <ftruncate+0x52>

00800825 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	53                   	push   %ebx
  800829:	83 ec 14             	sub    $0x14,%esp
  80082c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80082f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800832:	50                   	push   %eax
  800833:	ff 75 08             	pushl  0x8(%ebp)
  800836:	e8 81 fb ff ff       	call   8003bc <fd_lookup>
  80083b:	83 c4 08             	add    $0x8,%esp
  80083e:	85 c0                	test   %eax,%eax
  800840:	78 4b                	js     80088d <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800842:	83 ec 08             	sub    $0x8,%esp
  800845:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800848:	50                   	push   %eax
  800849:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80084c:	ff 30                	pushl  (%eax)
  80084e:	e8 bf fb ff ff       	call   800412 <dev_lookup>
  800853:	83 c4 10             	add    $0x10,%esp
  800856:	85 c0                	test   %eax,%eax
  800858:	78 33                	js     80088d <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  80085a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80085d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800861:	74 2f                	je     800892 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800863:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800866:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80086d:	00 00 00 
	stat->st_isdir = 0;
  800870:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800877:	00 00 00 
	stat->st_dev = dev;
  80087a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800880:	83 ec 08             	sub    $0x8,%esp
  800883:	53                   	push   %ebx
  800884:	ff 75 f0             	pushl  -0x10(%ebp)
  800887:	ff 50 14             	call   *0x14(%eax)
  80088a:	83 c4 10             	add    $0x10,%esp
}
  80088d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800890:	c9                   	leave  
  800891:	c3                   	ret    
		return -E_NOT_SUPP;
  800892:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800897:	eb f4                	jmp    80088d <fstat+0x68>

00800899 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	56                   	push   %esi
  80089d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80089e:	83 ec 08             	sub    $0x8,%esp
  8008a1:	6a 00                	push   $0x0
  8008a3:	ff 75 08             	pushl  0x8(%ebp)
  8008a6:	e8 e7 01 00 00       	call   800a92 <open>
  8008ab:	89 c3                	mov    %eax,%ebx
  8008ad:	83 c4 10             	add    $0x10,%esp
  8008b0:	85 c0                	test   %eax,%eax
  8008b2:	78 1b                	js     8008cf <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008b4:	83 ec 08             	sub    $0x8,%esp
  8008b7:	ff 75 0c             	pushl  0xc(%ebp)
  8008ba:	50                   	push   %eax
  8008bb:	e8 65 ff ff ff       	call   800825 <fstat>
  8008c0:	89 c6                	mov    %eax,%esi
	close(fd);
  8008c2:	89 1c 24             	mov    %ebx,(%esp)
  8008c5:	e8 27 fc ff ff       	call   8004f1 <close>
	return r;
  8008ca:	83 c4 10             	add    $0x10,%esp
  8008cd:	89 f3                	mov    %esi,%ebx
}
  8008cf:	89 d8                	mov    %ebx,%eax
  8008d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008d4:	5b                   	pop    %ebx
  8008d5:	5e                   	pop    %esi
  8008d6:	5d                   	pop    %ebp
  8008d7:	c3                   	ret    

008008d8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	56                   	push   %esi
  8008dc:	53                   	push   %ebx
  8008dd:	89 c6                	mov    %eax,%esi
  8008df:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008e1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008e8:	74 27                	je     800911 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008ea:	6a 07                	push   $0x7
  8008ec:	68 00 50 80 00       	push   $0x805000
  8008f1:	56                   	push   %esi
  8008f2:	ff 35 00 40 80 00    	pushl  0x804000
  8008f8:	e8 b0 11 00 00       	call   801aad <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8008fd:	83 c4 0c             	add    $0xc,%esp
  800900:	6a 00                	push   $0x0
  800902:	53                   	push   %ebx
  800903:	6a 00                	push   $0x0
  800905:	e8 2e 11 00 00       	call   801a38 <ipc_recv>
}
  80090a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80090d:	5b                   	pop    %ebx
  80090e:	5e                   	pop    %esi
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800911:	83 ec 0c             	sub    $0xc,%esp
  800914:	6a 01                	push   $0x1
  800916:	e8 e8 11 00 00       	call   801b03 <ipc_find_env>
  80091b:	a3 00 40 80 00       	mov    %eax,0x804000
  800920:	83 c4 10             	add    $0x10,%esp
  800923:	eb c5                	jmp    8008ea <fsipc+0x12>

00800925 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80092b:	8b 45 08             	mov    0x8(%ebp),%eax
  80092e:	8b 40 0c             	mov    0xc(%eax),%eax
  800931:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800936:	8b 45 0c             	mov    0xc(%ebp),%eax
  800939:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80093e:	ba 00 00 00 00       	mov    $0x0,%edx
  800943:	b8 02 00 00 00       	mov    $0x2,%eax
  800948:	e8 8b ff ff ff       	call   8008d8 <fsipc>
}
  80094d:	c9                   	leave  
  80094e:	c3                   	ret    

0080094f <devfile_flush>:
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800955:	8b 45 08             	mov    0x8(%ebp),%eax
  800958:	8b 40 0c             	mov    0xc(%eax),%eax
  80095b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800960:	ba 00 00 00 00       	mov    $0x0,%edx
  800965:	b8 06 00 00 00       	mov    $0x6,%eax
  80096a:	e8 69 ff ff ff       	call   8008d8 <fsipc>
}
  80096f:	c9                   	leave  
  800970:	c3                   	ret    

00800971 <devfile_stat>:
{
  800971:	55                   	push   %ebp
  800972:	89 e5                	mov    %esp,%ebp
  800974:	53                   	push   %ebx
  800975:	83 ec 04             	sub    $0x4,%esp
  800978:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80097b:	8b 45 08             	mov    0x8(%ebp),%eax
  80097e:	8b 40 0c             	mov    0xc(%eax),%eax
  800981:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800986:	ba 00 00 00 00       	mov    $0x0,%edx
  80098b:	b8 05 00 00 00       	mov    $0x5,%eax
  800990:	e8 43 ff ff ff       	call   8008d8 <fsipc>
  800995:	85 c0                	test   %eax,%eax
  800997:	78 2c                	js     8009c5 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800999:	83 ec 08             	sub    $0x8,%esp
  80099c:	68 00 50 80 00       	push   $0x805000
  8009a1:	53                   	push   %ebx
  8009a2:	e8 54 0d 00 00       	call   8016fb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009a7:	a1 80 50 80 00       	mov    0x805080,%eax
  8009ac:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009b2:	a1 84 50 80 00       	mov    0x805084,%eax
  8009b7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009bd:	83 c4 10             	add    $0x10,%esp
  8009c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009c8:	c9                   	leave  
  8009c9:	c3                   	ret    

008009ca <devfile_write>:
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	83 ec 0c             	sub    $0xc,%esp
  8009d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8009d3:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009d8:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8009dd:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8009e3:	8b 52 0c             	mov    0xc(%edx),%edx
  8009e6:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8009ec:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf,buf,n);
  8009f1:	50                   	push   %eax
  8009f2:	ff 75 0c             	pushl  0xc(%ebp)
  8009f5:	68 08 50 80 00       	push   $0x805008
  8009fa:	e8 8a 0e 00 00       	call   801889 <memmove>
	if((r = fsipc(FSREQ_WRITE,NULL))<0)
  8009ff:	ba 00 00 00 00       	mov    $0x0,%edx
  800a04:	b8 04 00 00 00       	mov    $0x4,%eax
  800a09:	e8 ca fe ff ff       	call   8008d8 <fsipc>
}
  800a0e:	c9                   	leave  
  800a0f:	c3                   	ret    

00800a10 <devfile_read>:
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	56                   	push   %esi
  800a14:	53                   	push   %ebx
  800a15:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a18:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1b:	8b 40 0c             	mov    0xc(%eax),%eax
  800a1e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a23:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a29:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2e:	b8 03 00 00 00       	mov    $0x3,%eax
  800a33:	e8 a0 fe ff ff       	call   8008d8 <fsipc>
  800a38:	89 c3                	mov    %eax,%ebx
  800a3a:	85 c0                	test   %eax,%eax
  800a3c:	78 1f                	js     800a5d <devfile_read+0x4d>
	assert(r <= n);
  800a3e:	39 f0                	cmp    %esi,%eax
  800a40:	77 24                	ja     800a66 <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a42:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a47:	7f 33                	jg     800a7c <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a49:	83 ec 04             	sub    $0x4,%esp
  800a4c:	50                   	push   %eax
  800a4d:	68 00 50 80 00       	push   $0x805000
  800a52:	ff 75 0c             	pushl  0xc(%ebp)
  800a55:	e8 2f 0e 00 00       	call   801889 <memmove>
	return r;
  800a5a:	83 c4 10             	add    $0x10,%esp
}
  800a5d:	89 d8                	mov    %ebx,%eax
  800a5f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a62:	5b                   	pop    %ebx
  800a63:	5e                   	pop    %esi
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    
	assert(r <= n);
  800a66:	68 84 1e 80 00       	push   $0x801e84
  800a6b:	68 8b 1e 80 00       	push   $0x801e8b
  800a70:	6a 7c                	push   $0x7c
  800a72:	68 a0 1e 80 00       	push   $0x801ea0
  800a77:	e8 85 05 00 00       	call   801001 <_panic>
	assert(r <= PGSIZE);
  800a7c:	68 ab 1e 80 00       	push   $0x801eab
  800a81:	68 8b 1e 80 00       	push   $0x801e8b
  800a86:	6a 7d                	push   $0x7d
  800a88:	68 a0 1e 80 00       	push   $0x801ea0
  800a8d:	e8 6f 05 00 00       	call   801001 <_panic>

00800a92 <open>:
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	56                   	push   %esi
  800a96:	53                   	push   %ebx
  800a97:	83 ec 1c             	sub    $0x1c,%esp
  800a9a:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800a9d:	56                   	push   %esi
  800a9e:	e8 21 0c 00 00       	call   8016c4 <strlen>
  800aa3:	83 c4 10             	add    $0x10,%esp
  800aa6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800aab:	7f 6c                	jg     800b19 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800aad:	83 ec 0c             	sub    $0xc,%esp
  800ab0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ab3:	50                   	push   %eax
  800ab4:	e8 b4 f8 ff ff       	call   80036d <fd_alloc>
  800ab9:	89 c3                	mov    %eax,%ebx
  800abb:	83 c4 10             	add    $0x10,%esp
  800abe:	85 c0                	test   %eax,%eax
  800ac0:	78 3c                	js     800afe <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800ac2:	83 ec 08             	sub    $0x8,%esp
  800ac5:	56                   	push   %esi
  800ac6:	68 00 50 80 00       	push   $0x805000
  800acb:	e8 2b 0c 00 00       	call   8016fb <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ad0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad3:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ad8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800adb:	b8 01 00 00 00       	mov    $0x1,%eax
  800ae0:	e8 f3 fd ff ff       	call   8008d8 <fsipc>
  800ae5:	89 c3                	mov    %eax,%ebx
  800ae7:	83 c4 10             	add    $0x10,%esp
  800aea:	85 c0                	test   %eax,%eax
  800aec:	78 19                	js     800b07 <open+0x75>
	return fd2num(fd);
  800aee:	83 ec 0c             	sub    $0xc,%esp
  800af1:	ff 75 f4             	pushl  -0xc(%ebp)
  800af4:	e8 4d f8 ff ff       	call   800346 <fd2num>
  800af9:	89 c3                	mov    %eax,%ebx
  800afb:	83 c4 10             	add    $0x10,%esp
}
  800afe:	89 d8                	mov    %ebx,%eax
  800b00:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b03:	5b                   	pop    %ebx
  800b04:	5e                   	pop    %esi
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    
		fd_close(fd, 0);
  800b07:	83 ec 08             	sub    $0x8,%esp
  800b0a:	6a 00                	push   $0x0
  800b0c:	ff 75 f4             	pushl  -0xc(%ebp)
  800b0f:	e8 54 f9 ff ff       	call   800468 <fd_close>
		return r;
  800b14:	83 c4 10             	add    $0x10,%esp
  800b17:	eb e5                	jmp    800afe <open+0x6c>
		return -E_BAD_PATH;
  800b19:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b1e:	eb de                	jmp    800afe <open+0x6c>

00800b20 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b26:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2b:	b8 08 00 00 00       	mov    $0x8,%eax
  800b30:	e8 a3 fd ff ff       	call   8008d8 <fsipc>
}
  800b35:	c9                   	leave  
  800b36:	c3                   	ret    

00800b37 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	56                   	push   %esi
  800b3b:	53                   	push   %ebx
  800b3c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b3f:	83 ec 0c             	sub    $0xc,%esp
  800b42:	ff 75 08             	pushl  0x8(%ebp)
  800b45:	e8 0c f8 ff ff       	call   800356 <fd2data>
  800b4a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b4c:	83 c4 08             	add    $0x8,%esp
  800b4f:	68 b7 1e 80 00       	push   $0x801eb7
  800b54:	53                   	push   %ebx
  800b55:	e8 a1 0b 00 00       	call   8016fb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b5a:	8b 46 04             	mov    0x4(%esi),%eax
  800b5d:	2b 06                	sub    (%esi),%eax
  800b5f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b65:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b6c:	00 00 00 
	stat->st_dev = &devpipe;
  800b6f:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b76:	30 80 00 
	return 0;
}
  800b79:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b81:	5b                   	pop    %ebx
  800b82:	5e                   	pop    %esi
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	53                   	push   %ebx
  800b89:	83 ec 0c             	sub    $0xc,%esp
  800b8c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b8f:	53                   	push   %ebx
  800b90:	6a 00                	push   $0x0
  800b92:	e8 43 f6 ff ff       	call   8001da <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b97:	89 1c 24             	mov    %ebx,(%esp)
  800b9a:	e8 b7 f7 ff ff       	call   800356 <fd2data>
  800b9f:	83 c4 08             	add    $0x8,%esp
  800ba2:	50                   	push   %eax
  800ba3:	6a 00                	push   $0x0
  800ba5:	e8 30 f6 ff ff       	call   8001da <sys_page_unmap>
}
  800baa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bad:	c9                   	leave  
  800bae:	c3                   	ret    

00800baf <_pipeisclosed>:
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	57                   	push   %edi
  800bb3:	56                   	push   %esi
  800bb4:	53                   	push   %ebx
  800bb5:	83 ec 1c             	sub    $0x1c,%esp
  800bb8:	89 c7                	mov    %eax,%edi
  800bba:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800bbc:	a1 04 40 80 00       	mov    0x804004,%eax
  800bc1:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800bc4:	83 ec 0c             	sub    $0xc,%esp
  800bc7:	57                   	push   %edi
  800bc8:	e8 6f 0f 00 00       	call   801b3c <pageref>
  800bcd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800bd0:	89 34 24             	mov    %esi,(%esp)
  800bd3:	e8 64 0f 00 00       	call   801b3c <pageref>
		nn = thisenv->env_runs;
  800bd8:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bde:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800be1:	83 c4 10             	add    $0x10,%esp
  800be4:	39 cb                	cmp    %ecx,%ebx
  800be6:	74 1b                	je     800c03 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800be8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800beb:	75 cf                	jne    800bbc <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800bed:	8b 42 58             	mov    0x58(%edx),%eax
  800bf0:	6a 01                	push   $0x1
  800bf2:	50                   	push   %eax
  800bf3:	53                   	push   %ebx
  800bf4:	68 be 1e 80 00       	push   $0x801ebe
  800bf9:	e8 de 04 00 00       	call   8010dc <cprintf>
  800bfe:	83 c4 10             	add    $0x10,%esp
  800c01:	eb b9                	jmp    800bbc <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c03:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c06:	0f 94 c0             	sete   %al
  800c09:	0f b6 c0             	movzbl %al,%eax
}
  800c0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <devpipe_write>:
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	57                   	push   %edi
  800c18:	56                   	push   %esi
  800c19:	53                   	push   %ebx
  800c1a:	83 ec 28             	sub    $0x28,%esp
  800c1d:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c20:	56                   	push   %esi
  800c21:	e8 30 f7 ff ff       	call   800356 <fd2data>
  800c26:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c28:	83 c4 10             	add    $0x10,%esp
  800c2b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c30:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c33:	74 4f                	je     800c84 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c35:	8b 43 04             	mov    0x4(%ebx),%eax
  800c38:	8b 0b                	mov    (%ebx),%ecx
  800c3a:	8d 51 20             	lea    0x20(%ecx),%edx
  800c3d:	39 d0                	cmp    %edx,%eax
  800c3f:	72 14                	jb     800c55 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  800c41:	89 da                	mov    %ebx,%edx
  800c43:	89 f0                	mov    %esi,%eax
  800c45:	e8 65 ff ff ff       	call   800baf <_pipeisclosed>
  800c4a:	85 c0                	test   %eax,%eax
  800c4c:	75 3a                	jne    800c88 <devpipe_write+0x74>
			sys_yield();
  800c4e:	e8 e3 f4 ff ff       	call   800136 <sys_yield>
  800c53:	eb e0                	jmp    800c35 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c58:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c5c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c5f:	89 c2                	mov    %eax,%edx
  800c61:	c1 fa 1f             	sar    $0x1f,%edx
  800c64:	89 d1                	mov    %edx,%ecx
  800c66:	c1 e9 1b             	shr    $0x1b,%ecx
  800c69:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c6c:	83 e2 1f             	and    $0x1f,%edx
  800c6f:	29 ca                	sub    %ecx,%edx
  800c71:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c75:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c79:	83 c0 01             	add    $0x1,%eax
  800c7c:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800c7f:	83 c7 01             	add    $0x1,%edi
  800c82:	eb ac                	jmp    800c30 <devpipe_write+0x1c>
	return i;
  800c84:	89 f8                	mov    %edi,%eax
  800c86:	eb 05                	jmp    800c8d <devpipe_write+0x79>
				return 0;
  800c88:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c90:	5b                   	pop    %ebx
  800c91:	5e                   	pop    %esi
  800c92:	5f                   	pop    %edi
  800c93:	5d                   	pop    %ebp
  800c94:	c3                   	ret    

00800c95 <devpipe_read>:
{
  800c95:	55                   	push   %ebp
  800c96:	89 e5                	mov    %esp,%ebp
  800c98:	57                   	push   %edi
  800c99:	56                   	push   %esi
  800c9a:	53                   	push   %ebx
  800c9b:	83 ec 18             	sub    $0x18,%esp
  800c9e:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800ca1:	57                   	push   %edi
  800ca2:	e8 af f6 ff ff       	call   800356 <fd2data>
  800ca7:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800ca9:	83 c4 10             	add    $0x10,%esp
  800cac:	be 00 00 00 00       	mov    $0x0,%esi
  800cb1:	3b 75 10             	cmp    0x10(%ebp),%esi
  800cb4:	74 47                	je     800cfd <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  800cb6:	8b 03                	mov    (%ebx),%eax
  800cb8:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cbb:	75 22                	jne    800cdf <devpipe_read+0x4a>
			if (i > 0)
  800cbd:	85 f6                	test   %esi,%esi
  800cbf:	75 14                	jne    800cd5 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  800cc1:	89 da                	mov    %ebx,%edx
  800cc3:	89 f8                	mov    %edi,%eax
  800cc5:	e8 e5 fe ff ff       	call   800baf <_pipeisclosed>
  800cca:	85 c0                	test   %eax,%eax
  800ccc:	75 33                	jne    800d01 <devpipe_read+0x6c>
			sys_yield();
  800cce:	e8 63 f4 ff ff       	call   800136 <sys_yield>
  800cd3:	eb e1                	jmp    800cb6 <devpipe_read+0x21>
				return i;
  800cd5:	89 f0                	mov    %esi,%eax
}
  800cd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cda:	5b                   	pop    %ebx
  800cdb:	5e                   	pop    %esi
  800cdc:	5f                   	pop    %edi
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cdf:	99                   	cltd   
  800ce0:	c1 ea 1b             	shr    $0x1b,%edx
  800ce3:	01 d0                	add    %edx,%eax
  800ce5:	83 e0 1f             	and    $0x1f,%eax
  800ce8:	29 d0                	sub    %edx,%eax
  800cea:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800cef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf2:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800cf5:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800cf8:	83 c6 01             	add    $0x1,%esi
  800cfb:	eb b4                	jmp    800cb1 <devpipe_read+0x1c>
	return i;
  800cfd:	89 f0                	mov    %esi,%eax
  800cff:	eb d6                	jmp    800cd7 <devpipe_read+0x42>
				return 0;
  800d01:	b8 00 00 00 00       	mov    $0x0,%eax
  800d06:	eb cf                	jmp    800cd7 <devpipe_read+0x42>

00800d08 <pipe>:
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	56                   	push   %esi
  800d0c:	53                   	push   %ebx
  800d0d:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d10:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d13:	50                   	push   %eax
  800d14:	e8 54 f6 ff ff       	call   80036d <fd_alloc>
  800d19:	89 c3                	mov    %eax,%ebx
  800d1b:	83 c4 10             	add    $0x10,%esp
  800d1e:	85 c0                	test   %eax,%eax
  800d20:	78 5b                	js     800d7d <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d22:	83 ec 04             	sub    $0x4,%esp
  800d25:	68 07 04 00 00       	push   $0x407
  800d2a:	ff 75 f4             	pushl  -0xc(%ebp)
  800d2d:	6a 00                	push   $0x0
  800d2f:	e8 21 f4 ff ff       	call   800155 <sys_page_alloc>
  800d34:	89 c3                	mov    %eax,%ebx
  800d36:	83 c4 10             	add    $0x10,%esp
  800d39:	85 c0                	test   %eax,%eax
  800d3b:	78 40                	js     800d7d <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  800d3d:	83 ec 0c             	sub    $0xc,%esp
  800d40:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d43:	50                   	push   %eax
  800d44:	e8 24 f6 ff ff       	call   80036d <fd_alloc>
  800d49:	89 c3                	mov    %eax,%ebx
  800d4b:	83 c4 10             	add    $0x10,%esp
  800d4e:	85 c0                	test   %eax,%eax
  800d50:	78 1b                	js     800d6d <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d52:	83 ec 04             	sub    $0x4,%esp
  800d55:	68 07 04 00 00       	push   $0x407
  800d5a:	ff 75 f0             	pushl  -0x10(%ebp)
  800d5d:	6a 00                	push   $0x0
  800d5f:	e8 f1 f3 ff ff       	call   800155 <sys_page_alloc>
  800d64:	89 c3                	mov    %eax,%ebx
  800d66:	83 c4 10             	add    $0x10,%esp
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	79 19                	jns    800d86 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  800d6d:	83 ec 08             	sub    $0x8,%esp
  800d70:	ff 75 f4             	pushl  -0xc(%ebp)
  800d73:	6a 00                	push   $0x0
  800d75:	e8 60 f4 ff ff       	call   8001da <sys_page_unmap>
  800d7a:	83 c4 10             	add    $0x10,%esp
}
  800d7d:	89 d8                	mov    %ebx,%eax
  800d7f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d82:	5b                   	pop    %ebx
  800d83:	5e                   	pop    %esi
  800d84:	5d                   	pop    %ebp
  800d85:	c3                   	ret    
	va = fd2data(fd0);
  800d86:	83 ec 0c             	sub    $0xc,%esp
  800d89:	ff 75 f4             	pushl  -0xc(%ebp)
  800d8c:	e8 c5 f5 ff ff       	call   800356 <fd2data>
  800d91:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d93:	83 c4 0c             	add    $0xc,%esp
  800d96:	68 07 04 00 00       	push   $0x407
  800d9b:	50                   	push   %eax
  800d9c:	6a 00                	push   $0x0
  800d9e:	e8 b2 f3 ff ff       	call   800155 <sys_page_alloc>
  800da3:	89 c3                	mov    %eax,%ebx
  800da5:	83 c4 10             	add    $0x10,%esp
  800da8:	85 c0                	test   %eax,%eax
  800daa:	0f 88 8c 00 00 00    	js     800e3c <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800db0:	83 ec 0c             	sub    $0xc,%esp
  800db3:	ff 75 f0             	pushl  -0x10(%ebp)
  800db6:	e8 9b f5 ff ff       	call   800356 <fd2data>
  800dbb:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dc2:	50                   	push   %eax
  800dc3:	6a 00                	push   $0x0
  800dc5:	56                   	push   %esi
  800dc6:	6a 00                	push   $0x0
  800dc8:	e8 cb f3 ff ff       	call   800198 <sys_page_map>
  800dcd:	89 c3                	mov    %eax,%ebx
  800dcf:	83 c4 20             	add    $0x20,%esp
  800dd2:	85 c0                	test   %eax,%eax
  800dd4:	78 58                	js     800e2e <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  800dd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dd9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800ddf:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800de1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800de4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  800deb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dee:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800df4:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800df6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800df9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e00:	83 ec 0c             	sub    $0xc,%esp
  800e03:	ff 75 f4             	pushl  -0xc(%ebp)
  800e06:	e8 3b f5 ff ff       	call   800346 <fd2num>
  800e0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e0e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e10:	83 c4 04             	add    $0x4,%esp
  800e13:	ff 75 f0             	pushl  -0x10(%ebp)
  800e16:	e8 2b f5 ff ff       	call   800346 <fd2num>
  800e1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e1e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e21:	83 c4 10             	add    $0x10,%esp
  800e24:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e29:	e9 4f ff ff ff       	jmp    800d7d <pipe+0x75>
	sys_page_unmap(0, va);
  800e2e:	83 ec 08             	sub    $0x8,%esp
  800e31:	56                   	push   %esi
  800e32:	6a 00                	push   $0x0
  800e34:	e8 a1 f3 ff ff       	call   8001da <sys_page_unmap>
  800e39:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e3c:	83 ec 08             	sub    $0x8,%esp
  800e3f:	ff 75 f0             	pushl  -0x10(%ebp)
  800e42:	6a 00                	push   $0x0
  800e44:	e8 91 f3 ff ff       	call   8001da <sys_page_unmap>
  800e49:	83 c4 10             	add    $0x10,%esp
  800e4c:	e9 1c ff ff ff       	jmp    800d6d <pipe+0x65>

00800e51 <pipeisclosed>:
{
  800e51:	55                   	push   %ebp
  800e52:	89 e5                	mov    %esp,%ebp
  800e54:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e57:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e5a:	50                   	push   %eax
  800e5b:	ff 75 08             	pushl  0x8(%ebp)
  800e5e:	e8 59 f5 ff ff       	call   8003bc <fd_lookup>
  800e63:	83 c4 10             	add    $0x10,%esp
  800e66:	85 c0                	test   %eax,%eax
  800e68:	78 18                	js     800e82 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  800e6a:	83 ec 0c             	sub    $0xc,%esp
  800e6d:	ff 75 f4             	pushl  -0xc(%ebp)
  800e70:	e8 e1 f4 ff ff       	call   800356 <fd2data>
	return _pipeisclosed(fd, p);
  800e75:	89 c2                	mov    %eax,%edx
  800e77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e7a:	e8 30 fd ff ff       	call   800baf <_pipeisclosed>
  800e7f:	83 c4 10             	add    $0x10,%esp
}
  800e82:	c9                   	leave  
  800e83:	c3                   	ret    

00800e84 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e87:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8c:	5d                   	pop    %ebp
  800e8d:	c3                   	ret    

00800e8e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e94:	68 d6 1e 80 00       	push   $0x801ed6
  800e99:	ff 75 0c             	pushl  0xc(%ebp)
  800e9c:	e8 5a 08 00 00       	call   8016fb <strcpy>
	return 0;
}
  800ea1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea6:	c9                   	leave  
  800ea7:	c3                   	ret    

00800ea8 <devcons_write>:
{
  800ea8:	55                   	push   %ebp
  800ea9:	89 e5                	mov    %esp,%ebp
  800eab:	57                   	push   %edi
  800eac:	56                   	push   %esi
  800ead:	53                   	push   %ebx
  800eae:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800eb4:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800eb9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800ebf:	eb 2f                	jmp    800ef0 <devcons_write+0x48>
		m = n - tot;
  800ec1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec4:	29 f3                	sub    %esi,%ebx
  800ec6:	83 fb 7f             	cmp    $0x7f,%ebx
  800ec9:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800ece:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800ed1:	83 ec 04             	sub    $0x4,%esp
  800ed4:	53                   	push   %ebx
  800ed5:	89 f0                	mov    %esi,%eax
  800ed7:	03 45 0c             	add    0xc(%ebp),%eax
  800eda:	50                   	push   %eax
  800edb:	57                   	push   %edi
  800edc:	e8 a8 09 00 00       	call   801889 <memmove>
		sys_cputs(buf, m);
  800ee1:	83 c4 08             	add    $0x8,%esp
  800ee4:	53                   	push   %ebx
  800ee5:	57                   	push   %edi
  800ee6:	e8 ae f1 ff ff       	call   800099 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800eeb:	01 de                	add    %ebx,%esi
  800eed:	83 c4 10             	add    $0x10,%esp
  800ef0:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ef3:	72 cc                	jb     800ec1 <devcons_write+0x19>
}
  800ef5:	89 f0                	mov    %esi,%eax
  800ef7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800efa:	5b                   	pop    %ebx
  800efb:	5e                   	pop    %esi
  800efc:	5f                   	pop    %edi
  800efd:	5d                   	pop    %ebp
  800efe:	c3                   	ret    

00800eff <devcons_read>:
{
  800eff:	55                   	push   %ebp
  800f00:	89 e5                	mov    %esp,%ebp
  800f02:	83 ec 08             	sub    $0x8,%esp
  800f05:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f0a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f0e:	75 07                	jne    800f17 <devcons_read+0x18>
}
  800f10:	c9                   	leave  
  800f11:	c3                   	ret    
		sys_yield();
  800f12:	e8 1f f2 ff ff       	call   800136 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  800f17:	e8 9b f1 ff ff       	call   8000b7 <sys_cgetc>
  800f1c:	85 c0                	test   %eax,%eax
  800f1e:	74 f2                	je     800f12 <devcons_read+0x13>
	if (c < 0)
  800f20:	85 c0                	test   %eax,%eax
  800f22:	78 ec                	js     800f10 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  800f24:	83 f8 04             	cmp    $0x4,%eax
  800f27:	74 0c                	je     800f35 <devcons_read+0x36>
	*(char*)vbuf = c;
  800f29:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f2c:	88 02                	mov    %al,(%edx)
	return 1;
  800f2e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f33:	eb db                	jmp    800f10 <devcons_read+0x11>
		return 0;
  800f35:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3a:	eb d4                	jmp    800f10 <devcons_read+0x11>

00800f3c <cputchar>:
{
  800f3c:	55                   	push   %ebp
  800f3d:	89 e5                	mov    %esp,%ebp
  800f3f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f42:	8b 45 08             	mov    0x8(%ebp),%eax
  800f45:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800f48:	6a 01                	push   $0x1
  800f4a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f4d:	50                   	push   %eax
  800f4e:	e8 46 f1 ff ff       	call   800099 <sys_cputs>
}
  800f53:	83 c4 10             	add    $0x10,%esp
  800f56:	c9                   	leave  
  800f57:	c3                   	ret    

00800f58 <getchar>:
{
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800f5e:	6a 01                	push   $0x1
  800f60:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f63:	50                   	push   %eax
  800f64:	6a 00                	push   $0x0
  800f66:	e8 c2 f6 ff ff       	call   80062d <read>
	if (r < 0)
  800f6b:	83 c4 10             	add    $0x10,%esp
  800f6e:	85 c0                	test   %eax,%eax
  800f70:	78 08                	js     800f7a <getchar+0x22>
	if (r < 1)
  800f72:	85 c0                	test   %eax,%eax
  800f74:	7e 06                	jle    800f7c <getchar+0x24>
	return c;
  800f76:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800f7a:	c9                   	leave  
  800f7b:	c3                   	ret    
		return -E_EOF;
  800f7c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800f81:	eb f7                	jmp    800f7a <getchar+0x22>

00800f83 <iscons>:
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f89:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f8c:	50                   	push   %eax
  800f8d:	ff 75 08             	pushl  0x8(%ebp)
  800f90:	e8 27 f4 ff ff       	call   8003bc <fd_lookup>
  800f95:	83 c4 10             	add    $0x10,%esp
  800f98:	85 c0                	test   %eax,%eax
  800f9a:	78 11                	js     800fad <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  800f9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f9f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fa5:	39 10                	cmp    %edx,(%eax)
  800fa7:	0f 94 c0             	sete   %al
  800faa:	0f b6 c0             	movzbl %al,%eax
}
  800fad:	c9                   	leave  
  800fae:	c3                   	ret    

00800faf <opencons>:
{
  800faf:	55                   	push   %ebp
  800fb0:	89 e5                	mov    %esp,%ebp
  800fb2:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800fb5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb8:	50                   	push   %eax
  800fb9:	e8 af f3 ff ff       	call   80036d <fd_alloc>
  800fbe:	83 c4 10             	add    $0x10,%esp
  800fc1:	85 c0                	test   %eax,%eax
  800fc3:	78 3a                	js     800fff <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fc5:	83 ec 04             	sub    $0x4,%esp
  800fc8:	68 07 04 00 00       	push   $0x407
  800fcd:	ff 75 f4             	pushl  -0xc(%ebp)
  800fd0:	6a 00                	push   $0x0
  800fd2:	e8 7e f1 ff ff       	call   800155 <sys_page_alloc>
  800fd7:	83 c4 10             	add    $0x10,%esp
  800fda:	85 c0                	test   %eax,%eax
  800fdc:	78 21                	js     800fff <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  800fde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fe7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fe9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fec:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800ff3:	83 ec 0c             	sub    $0xc,%esp
  800ff6:	50                   	push   %eax
  800ff7:	e8 4a f3 ff ff       	call   800346 <fd2num>
  800ffc:	83 c4 10             	add    $0x10,%esp
}
  800fff:	c9                   	leave  
  801000:	c3                   	ret    

00801001 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801001:	55                   	push   %ebp
  801002:	89 e5                	mov    %esp,%ebp
  801004:	56                   	push   %esi
  801005:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801006:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801009:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80100f:	e8 03 f1 ff ff       	call   800117 <sys_getenvid>
  801014:	83 ec 0c             	sub    $0xc,%esp
  801017:	ff 75 0c             	pushl  0xc(%ebp)
  80101a:	ff 75 08             	pushl  0x8(%ebp)
  80101d:	56                   	push   %esi
  80101e:	50                   	push   %eax
  80101f:	68 e4 1e 80 00       	push   $0x801ee4
  801024:	e8 b3 00 00 00       	call   8010dc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801029:	83 c4 18             	add    $0x18,%esp
  80102c:	53                   	push   %ebx
  80102d:	ff 75 10             	pushl  0x10(%ebp)
  801030:	e8 56 00 00 00       	call   80108b <vcprintf>
	cprintf("\n");
  801035:	c7 04 24 cf 1e 80 00 	movl   $0x801ecf,(%esp)
  80103c:	e8 9b 00 00 00       	call   8010dc <cprintf>
  801041:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801044:	cc                   	int3   
  801045:	eb fd                	jmp    801044 <_panic+0x43>

00801047 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801047:	55                   	push   %ebp
  801048:	89 e5                	mov    %esp,%ebp
  80104a:	53                   	push   %ebx
  80104b:	83 ec 04             	sub    $0x4,%esp
  80104e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801051:	8b 13                	mov    (%ebx),%edx
  801053:	8d 42 01             	lea    0x1(%edx),%eax
  801056:	89 03                	mov    %eax,(%ebx)
  801058:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80105b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80105f:	3d ff 00 00 00       	cmp    $0xff,%eax
  801064:	74 09                	je     80106f <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801066:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80106a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80106d:	c9                   	leave  
  80106e:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80106f:	83 ec 08             	sub    $0x8,%esp
  801072:	68 ff 00 00 00       	push   $0xff
  801077:	8d 43 08             	lea    0x8(%ebx),%eax
  80107a:	50                   	push   %eax
  80107b:	e8 19 f0 ff ff       	call   800099 <sys_cputs>
		b->idx = 0;
  801080:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801086:	83 c4 10             	add    $0x10,%esp
  801089:	eb db                	jmp    801066 <putch+0x1f>

0080108b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80108b:	55                   	push   %ebp
  80108c:	89 e5                	mov    %esp,%ebp
  80108e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801094:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80109b:	00 00 00 
	b.cnt = 0;
  80109e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010a5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010a8:	ff 75 0c             	pushl  0xc(%ebp)
  8010ab:	ff 75 08             	pushl  0x8(%ebp)
  8010ae:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010b4:	50                   	push   %eax
  8010b5:	68 47 10 80 00       	push   $0x801047
  8010ba:	e8 1a 01 00 00       	call   8011d9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010bf:	83 c4 08             	add    $0x8,%esp
  8010c2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010c8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010ce:	50                   	push   %eax
  8010cf:	e8 c5 ef ff ff       	call   800099 <sys_cputs>

	return b.cnt;
}
  8010d4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010da:	c9                   	leave  
  8010db:	c3                   	ret    

008010dc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010e2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010e5:	50                   	push   %eax
  8010e6:	ff 75 08             	pushl  0x8(%ebp)
  8010e9:	e8 9d ff ff ff       	call   80108b <vcprintf>
	va_end(ap);

	return cnt;
}
  8010ee:	c9                   	leave  
  8010ef:	c3                   	ret    

008010f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
  8010f3:	57                   	push   %edi
  8010f4:	56                   	push   %esi
  8010f5:	53                   	push   %ebx
  8010f6:	83 ec 1c             	sub    $0x1c,%esp
  8010f9:	89 c7                	mov    %eax,%edi
  8010fb:	89 d6                	mov    %edx,%esi
  8010fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801100:	8b 55 0c             	mov    0xc(%ebp),%edx
  801103:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801106:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801109:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80110c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801111:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801114:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801117:	39 d3                	cmp    %edx,%ebx
  801119:	72 05                	jb     801120 <printnum+0x30>
  80111b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80111e:	77 7a                	ja     80119a <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801120:	83 ec 0c             	sub    $0xc,%esp
  801123:	ff 75 18             	pushl  0x18(%ebp)
  801126:	8b 45 14             	mov    0x14(%ebp),%eax
  801129:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80112c:	53                   	push   %ebx
  80112d:	ff 75 10             	pushl  0x10(%ebp)
  801130:	83 ec 08             	sub    $0x8,%esp
  801133:	ff 75 e4             	pushl  -0x1c(%ebp)
  801136:	ff 75 e0             	pushl  -0x20(%ebp)
  801139:	ff 75 dc             	pushl  -0x24(%ebp)
  80113c:	ff 75 d8             	pushl  -0x28(%ebp)
  80113f:	e8 3c 0a 00 00       	call   801b80 <__udivdi3>
  801144:	83 c4 18             	add    $0x18,%esp
  801147:	52                   	push   %edx
  801148:	50                   	push   %eax
  801149:	89 f2                	mov    %esi,%edx
  80114b:	89 f8                	mov    %edi,%eax
  80114d:	e8 9e ff ff ff       	call   8010f0 <printnum>
  801152:	83 c4 20             	add    $0x20,%esp
  801155:	eb 13                	jmp    80116a <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801157:	83 ec 08             	sub    $0x8,%esp
  80115a:	56                   	push   %esi
  80115b:	ff 75 18             	pushl  0x18(%ebp)
  80115e:	ff d7                	call   *%edi
  801160:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801163:	83 eb 01             	sub    $0x1,%ebx
  801166:	85 db                	test   %ebx,%ebx
  801168:	7f ed                	jg     801157 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80116a:	83 ec 08             	sub    $0x8,%esp
  80116d:	56                   	push   %esi
  80116e:	83 ec 04             	sub    $0x4,%esp
  801171:	ff 75 e4             	pushl  -0x1c(%ebp)
  801174:	ff 75 e0             	pushl  -0x20(%ebp)
  801177:	ff 75 dc             	pushl  -0x24(%ebp)
  80117a:	ff 75 d8             	pushl  -0x28(%ebp)
  80117d:	e8 1e 0b 00 00       	call   801ca0 <__umoddi3>
  801182:	83 c4 14             	add    $0x14,%esp
  801185:	0f be 80 07 1f 80 00 	movsbl 0x801f07(%eax),%eax
  80118c:	50                   	push   %eax
  80118d:	ff d7                	call   *%edi
}
  80118f:	83 c4 10             	add    $0x10,%esp
  801192:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801195:	5b                   	pop    %ebx
  801196:	5e                   	pop    %esi
  801197:	5f                   	pop    %edi
  801198:	5d                   	pop    %ebp
  801199:	c3                   	ret    
  80119a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80119d:	eb c4                	jmp    801163 <printnum+0x73>

0080119f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80119f:	55                   	push   %ebp
  8011a0:	89 e5                	mov    %esp,%ebp
  8011a2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011a5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011a9:	8b 10                	mov    (%eax),%edx
  8011ab:	3b 50 04             	cmp    0x4(%eax),%edx
  8011ae:	73 0a                	jae    8011ba <sprintputch+0x1b>
		*b->buf++ = ch;
  8011b0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011b3:	89 08                	mov    %ecx,(%eax)
  8011b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b8:	88 02                	mov    %al,(%edx)
}
  8011ba:	5d                   	pop    %ebp
  8011bb:	c3                   	ret    

008011bc <printfmt>:
{
  8011bc:	55                   	push   %ebp
  8011bd:	89 e5                	mov    %esp,%ebp
  8011bf:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8011c2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011c5:	50                   	push   %eax
  8011c6:	ff 75 10             	pushl  0x10(%ebp)
  8011c9:	ff 75 0c             	pushl  0xc(%ebp)
  8011cc:	ff 75 08             	pushl  0x8(%ebp)
  8011cf:	e8 05 00 00 00       	call   8011d9 <vprintfmt>
}
  8011d4:	83 c4 10             	add    $0x10,%esp
  8011d7:	c9                   	leave  
  8011d8:	c3                   	ret    

008011d9 <vprintfmt>:
{
  8011d9:	55                   	push   %ebp
  8011da:	89 e5                	mov    %esp,%ebp
  8011dc:	57                   	push   %edi
  8011dd:	56                   	push   %esi
  8011de:	53                   	push   %ebx
  8011df:	83 ec 2c             	sub    $0x2c,%esp
  8011e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8011e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011e8:	8b 7d 10             	mov    0x10(%ebp),%edi
  8011eb:	e9 c1 03 00 00       	jmp    8015b1 <vprintfmt+0x3d8>
		padc = ' ';
  8011f0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8011f4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8011fb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  801202:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801209:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80120e:	8d 47 01             	lea    0x1(%edi),%eax
  801211:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801214:	0f b6 17             	movzbl (%edi),%edx
  801217:	8d 42 dd             	lea    -0x23(%edx),%eax
  80121a:	3c 55                	cmp    $0x55,%al
  80121c:	0f 87 12 04 00 00    	ja     801634 <vprintfmt+0x45b>
  801222:	0f b6 c0             	movzbl %al,%eax
  801225:	ff 24 85 40 20 80 00 	jmp    *0x802040(,%eax,4)
  80122c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80122f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  801233:	eb d9                	jmp    80120e <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801235:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  801238:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80123c:	eb d0                	jmp    80120e <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80123e:	0f b6 d2             	movzbl %dl,%edx
  801241:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801244:	b8 00 00 00 00       	mov    $0x0,%eax
  801249:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80124c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80124f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801253:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801256:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801259:	83 f9 09             	cmp    $0x9,%ecx
  80125c:	77 55                	ja     8012b3 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80125e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801261:	eb e9                	jmp    80124c <vprintfmt+0x73>
			precision = va_arg(ap, int);
  801263:	8b 45 14             	mov    0x14(%ebp),%eax
  801266:	8b 00                	mov    (%eax),%eax
  801268:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80126b:	8b 45 14             	mov    0x14(%ebp),%eax
  80126e:	8d 40 04             	lea    0x4(%eax),%eax
  801271:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801274:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801277:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80127b:	79 91                	jns    80120e <vprintfmt+0x35>
				width = precision, precision = -1;
  80127d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801280:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801283:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80128a:	eb 82                	jmp    80120e <vprintfmt+0x35>
  80128c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80128f:	85 c0                	test   %eax,%eax
  801291:	ba 00 00 00 00       	mov    $0x0,%edx
  801296:	0f 49 d0             	cmovns %eax,%edx
  801299:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80129c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80129f:	e9 6a ff ff ff       	jmp    80120e <vprintfmt+0x35>
  8012a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8012a7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012ae:	e9 5b ff ff ff       	jmp    80120e <vprintfmt+0x35>
  8012b3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012b6:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012b9:	eb bc                	jmp    801277 <vprintfmt+0x9e>
			lflag++;
  8012bb:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8012c1:	e9 48 ff ff ff       	jmp    80120e <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8012c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8012c9:	8d 78 04             	lea    0x4(%eax),%edi
  8012cc:	83 ec 08             	sub    $0x8,%esp
  8012cf:	53                   	push   %ebx
  8012d0:	ff 30                	pushl  (%eax)
  8012d2:	ff d6                	call   *%esi
			break;
  8012d4:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8012d7:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8012da:	e9 cf 02 00 00       	jmp    8015ae <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8012df:	8b 45 14             	mov    0x14(%ebp),%eax
  8012e2:	8d 78 04             	lea    0x4(%eax),%edi
  8012e5:	8b 00                	mov    (%eax),%eax
  8012e7:	99                   	cltd   
  8012e8:	31 d0                	xor    %edx,%eax
  8012ea:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8012ec:	83 f8 0f             	cmp    $0xf,%eax
  8012ef:	7f 23                	jg     801314 <vprintfmt+0x13b>
  8012f1:	8b 14 85 a0 21 80 00 	mov    0x8021a0(,%eax,4),%edx
  8012f8:	85 d2                	test   %edx,%edx
  8012fa:	74 18                	je     801314 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8012fc:	52                   	push   %edx
  8012fd:	68 9d 1e 80 00       	push   $0x801e9d
  801302:	53                   	push   %ebx
  801303:	56                   	push   %esi
  801304:	e8 b3 fe ff ff       	call   8011bc <printfmt>
  801309:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80130c:	89 7d 14             	mov    %edi,0x14(%ebp)
  80130f:	e9 9a 02 00 00       	jmp    8015ae <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  801314:	50                   	push   %eax
  801315:	68 1f 1f 80 00       	push   $0x801f1f
  80131a:	53                   	push   %ebx
  80131b:	56                   	push   %esi
  80131c:	e8 9b fe ff ff       	call   8011bc <printfmt>
  801321:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801324:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801327:	e9 82 02 00 00       	jmp    8015ae <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  80132c:	8b 45 14             	mov    0x14(%ebp),%eax
  80132f:	83 c0 04             	add    $0x4,%eax
  801332:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801335:	8b 45 14             	mov    0x14(%ebp),%eax
  801338:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80133a:	85 ff                	test   %edi,%edi
  80133c:	b8 18 1f 80 00       	mov    $0x801f18,%eax
  801341:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801344:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801348:	0f 8e bd 00 00 00    	jle    80140b <vprintfmt+0x232>
  80134e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801352:	75 0e                	jne    801362 <vprintfmt+0x189>
  801354:	89 75 08             	mov    %esi,0x8(%ebp)
  801357:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80135a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80135d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801360:	eb 6d                	jmp    8013cf <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  801362:	83 ec 08             	sub    $0x8,%esp
  801365:	ff 75 d0             	pushl  -0x30(%ebp)
  801368:	57                   	push   %edi
  801369:	e8 6e 03 00 00       	call   8016dc <strnlen>
  80136e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801371:	29 c1                	sub    %eax,%ecx
  801373:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  801376:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801379:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80137d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801380:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801383:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  801385:	eb 0f                	jmp    801396 <vprintfmt+0x1bd>
					putch(padc, putdat);
  801387:	83 ec 08             	sub    $0x8,%esp
  80138a:	53                   	push   %ebx
  80138b:	ff 75 e0             	pushl  -0x20(%ebp)
  80138e:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  801390:	83 ef 01             	sub    $0x1,%edi
  801393:	83 c4 10             	add    $0x10,%esp
  801396:	85 ff                	test   %edi,%edi
  801398:	7f ed                	jg     801387 <vprintfmt+0x1ae>
  80139a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80139d:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8013a0:	85 c9                	test   %ecx,%ecx
  8013a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a7:	0f 49 c1             	cmovns %ecx,%eax
  8013aa:	29 c1                	sub    %eax,%ecx
  8013ac:	89 75 08             	mov    %esi,0x8(%ebp)
  8013af:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8013b2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8013b5:	89 cb                	mov    %ecx,%ebx
  8013b7:	eb 16                	jmp    8013cf <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8013b9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013bd:	75 31                	jne    8013f0 <vprintfmt+0x217>
					putch(ch, putdat);
  8013bf:	83 ec 08             	sub    $0x8,%esp
  8013c2:	ff 75 0c             	pushl  0xc(%ebp)
  8013c5:	50                   	push   %eax
  8013c6:	ff 55 08             	call   *0x8(%ebp)
  8013c9:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013cc:	83 eb 01             	sub    $0x1,%ebx
  8013cf:	83 c7 01             	add    $0x1,%edi
  8013d2:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8013d6:	0f be c2             	movsbl %dl,%eax
  8013d9:	85 c0                	test   %eax,%eax
  8013db:	74 59                	je     801436 <vprintfmt+0x25d>
  8013dd:	85 f6                	test   %esi,%esi
  8013df:	78 d8                	js     8013b9 <vprintfmt+0x1e0>
  8013e1:	83 ee 01             	sub    $0x1,%esi
  8013e4:	79 d3                	jns    8013b9 <vprintfmt+0x1e0>
  8013e6:	89 df                	mov    %ebx,%edi
  8013e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8013eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8013ee:	eb 37                	jmp    801427 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8013f0:	0f be d2             	movsbl %dl,%edx
  8013f3:	83 ea 20             	sub    $0x20,%edx
  8013f6:	83 fa 5e             	cmp    $0x5e,%edx
  8013f9:	76 c4                	jbe    8013bf <vprintfmt+0x1e6>
					putch('?', putdat);
  8013fb:	83 ec 08             	sub    $0x8,%esp
  8013fe:	ff 75 0c             	pushl  0xc(%ebp)
  801401:	6a 3f                	push   $0x3f
  801403:	ff 55 08             	call   *0x8(%ebp)
  801406:	83 c4 10             	add    $0x10,%esp
  801409:	eb c1                	jmp    8013cc <vprintfmt+0x1f3>
  80140b:	89 75 08             	mov    %esi,0x8(%ebp)
  80140e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801411:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801414:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801417:	eb b6                	jmp    8013cf <vprintfmt+0x1f6>
				putch(' ', putdat);
  801419:	83 ec 08             	sub    $0x8,%esp
  80141c:	53                   	push   %ebx
  80141d:	6a 20                	push   $0x20
  80141f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801421:	83 ef 01             	sub    $0x1,%edi
  801424:	83 c4 10             	add    $0x10,%esp
  801427:	85 ff                	test   %edi,%edi
  801429:	7f ee                	jg     801419 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80142b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80142e:	89 45 14             	mov    %eax,0x14(%ebp)
  801431:	e9 78 01 00 00       	jmp    8015ae <vprintfmt+0x3d5>
  801436:	89 df                	mov    %ebx,%edi
  801438:	8b 75 08             	mov    0x8(%ebp),%esi
  80143b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80143e:	eb e7                	jmp    801427 <vprintfmt+0x24e>
	if (lflag >= 2)
  801440:	83 f9 01             	cmp    $0x1,%ecx
  801443:	7e 3f                	jle    801484 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  801445:	8b 45 14             	mov    0x14(%ebp),%eax
  801448:	8b 50 04             	mov    0x4(%eax),%edx
  80144b:	8b 00                	mov    (%eax),%eax
  80144d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801450:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801453:	8b 45 14             	mov    0x14(%ebp),%eax
  801456:	8d 40 08             	lea    0x8(%eax),%eax
  801459:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80145c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801460:	79 5c                	jns    8014be <vprintfmt+0x2e5>
				putch('-', putdat);
  801462:	83 ec 08             	sub    $0x8,%esp
  801465:	53                   	push   %ebx
  801466:	6a 2d                	push   $0x2d
  801468:	ff d6                	call   *%esi
				num = -(long long) num;
  80146a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80146d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801470:	f7 da                	neg    %edx
  801472:	83 d1 00             	adc    $0x0,%ecx
  801475:	f7 d9                	neg    %ecx
  801477:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80147a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80147f:	e9 10 01 00 00       	jmp    801594 <vprintfmt+0x3bb>
	else if (lflag)
  801484:	85 c9                	test   %ecx,%ecx
  801486:	75 1b                	jne    8014a3 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  801488:	8b 45 14             	mov    0x14(%ebp),%eax
  80148b:	8b 00                	mov    (%eax),%eax
  80148d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801490:	89 c1                	mov    %eax,%ecx
  801492:	c1 f9 1f             	sar    $0x1f,%ecx
  801495:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801498:	8b 45 14             	mov    0x14(%ebp),%eax
  80149b:	8d 40 04             	lea    0x4(%eax),%eax
  80149e:	89 45 14             	mov    %eax,0x14(%ebp)
  8014a1:	eb b9                	jmp    80145c <vprintfmt+0x283>
		return va_arg(*ap, long);
  8014a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8014a6:	8b 00                	mov    (%eax),%eax
  8014a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014ab:	89 c1                	mov    %eax,%ecx
  8014ad:	c1 f9 1f             	sar    $0x1f,%ecx
  8014b0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b6:	8d 40 04             	lea    0x4(%eax),%eax
  8014b9:	89 45 14             	mov    %eax,0x14(%ebp)
  8014bc:	eb 9e                	jmp    80145c <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8014be:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014c1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8014c4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014c9:	e9 c6 00 00 00       	jmp    801594 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8014ce:	83 f9 01             	cmp    $0x1,%ecx
  8014d1:	7e 18                	jle    8014eb <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8014d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d6:	8b 10                	mov    (%eax),%edx
  8014d8:	8b 48 04             	mov    0x4(%eax),%ecx
  8014db:	8d 40 08             	lea    0x8(%eax),%eax
  8014de:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014e1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014e6:	e9 a9 00 00 00       	jmp    801594 <vprintfmt+0x3bb>
	else if (lflag)
  8014eb:	85 c9                	test   %ecx,%ecx
  8014ed:	75 1a                	jne    801509 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8014ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f2:	8b 10                	mov    (%eax),%edx
  8014f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014f9:	8d 40 04             	lea    0x4(%eax),%eax
  8014fc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014ff:	b8 0a 00 00 00       	mov    $0xa,%eax
  801504:	e9 8b 00 00 00       	jmp    801594 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801509:	8b 45 14             	mov    0x14(%ebp),%eax
  80150c:	8b 10                	mov    (%eax),%edx
  80150e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801513:	8d 40 04             	lea    0x4(%eax),%eax
  801516:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801519:	b8 0a 00 00 00       	mov    $0xa,%eax
  80151e:	eb 74                	jmp    801594 <vprintfmt+0x3bb>
	if (lflag >= 2)
  801520:	83 f9 01             	cmp    $0x1,%ecx
  801523:	7e 15                	jle    80153a <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  801525:	8b 45 14             	mov    0x14(%ebp),%eax
  801528:	8b 10                	mov    (%eax),%edx
  80152a:	8b 48 04             	mov    0x4(%eax),%ecx
  80152d:	8d 40 08             	lea    0x8(%eax),%eax
  801530:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801533:	b8 08 00 00 00       	mov    $0x8,%eax
  801538:	eb 5a                	jmp    801594 <vprintfmt+0x3bb>
	else if (lflag)
  80153a:	85 c9                	test   %ecx,%ecx
  80153c:	75 17                	jne    801555 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80153e:	8b 45 14             	mov    0x14(%ebp),%eax
  801541:	8b 10                	mov    (%eax),%edx
  801543:	b9 00 00 00 00       	mov    $0x0,%ecx
  801548:	8d 40 04             	lea    0x4(%eax),%eax
  80154b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80154e:	b8 08 00 00 00       	mov    $0x8,%eax
  801553:	eb 3f                	jmp    801594 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801555:	8b 45 14             	mov    0x14(%ebp),%eax
  801558:	8b 10                	mov    (%eax),%edx
  80155a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80155f:	8d 40 04             	lea    0x4(%eax),%eax
  801562:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801565:	b8 08 00 00 00       	mov    $0x8,%eax
  80156a:	eb 28                	jmp    801594 <vprintfmt+0x3bb>
			putch('0', putdat);
  80156c:	83 ec 08             	sub    $0x8,%esp
  80156f:	53                   	push   %ebx
  801570:	6a 30                	push   $0x30
  801572:	ff d6                	call   *%esi
			putch('x', putdat);
  801574:	83 c4 08             	add    $0x8,%esp
  801577:	53                   	push   %ebx
  801578:	6a 78                	push   $0x78
  80157a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80157c:	8b 45 14             	mov    0x14(%ebp),%eax
  80157f:	8b 10                	mov    (%eax),%edx
  801581:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801586:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801589:	8d 40 04             	lea    0x4(%eax),%eax
  80158c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80158f:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  801594:	83 ec 0c             	sub    $0xc,%esp
  801597:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80159b:	57                   	push   %edi
  80159c:	ff 75 e0             	pushl  -0x20(%ebp)
  80159f:	50                   	push   %eax
  8015a0:	51                   	push   %ecx
  8015a1:	52                   	push   %edx
  8015a2:	89 da                	mov    %ebx,%edx
  8015a4:	89 f0                	mov    %esi,%eax
  8015a6:	e8 45 fb ff ff       	call   8010f0 <printnum>
			break;
  8015ab:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8015ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015b1:	83 c7 01             	add    $0x1,%edi
  8015b4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015b8:	83 f8 25             	cmp    $0x25,%eax
  8015bb:	0f 84 2f fc ff ff    	je     8011f0 <vprintfmt+0x17>
			if (ch == '\0')
  8015c1:	85 c0                	test   %eax,%eax
  8015c3:	0f 84 8b 00 00 00    	je     801654 <vprintfmt+0x47b>
			putch(ch, putdat);
  8015c9:	83 ec 08             	sub    $0x8,%esp
  8015cc:	53                   	push   %ebx
  8015cd:	50                   	push   %eax
  8015ce:	ff d6                	call   *%esi
  8015d0:	83 c4 10             	add    $0x10,%esp
  8015d3:	eb dc                	jmp    8015b1 <vprintfmt+0x3d8>
	if (lflag >= 2)
  8015d5:	83 f9 01             	cmp    $0x1,%ecx
  8015d8:	7e 15                	jle    8015ef <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8015da:	8b 45 14             	mov    0x14(%ebp),%eax
  8015dd:	8b 10                	mov    (%eax),%edx
  8015df:	8b 48 04             	mov    0x4(%eax),%ecx
  8015e2:	8d 40 08             	lea    0x8(%eax),%eax
  8015e5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015e8:	b8 10 00 00 00       	mov    $0x10,%eax
  8015ed:	eb a5                	jmp    801594 <vprintfmt+0x3bb>
	else if (lflag)
  8015ef:	85 c9                	test   %ecx,%ecx
  8015f1:	75 17                	jne    80160a <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8015f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8015f6:	8b 10                	mov    (%eax),%edx
  8015f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015fd:	8d 40 04             	lea    0x4(%eax),%eax
  801600:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801603:	b8 10 00 00 00       	mov    $0x10,%eax
  801608:	eb 8a                	jmp    801594 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80160a:	8b 45 14             	mov    0x14(%ebp),%eax
  80160d:	8b 10                	mov    (%eax),%edx
  80160f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801614:	8d 40 04             	lea    0x4(%eax),%eax
  801617:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80161a:	b8 10 00 00 00       	mov    $0x10,%eax
  80161f:	e9 70 ff ff ff       	jmp    801594 <vprintfmt+0x3bb>
			putch(ch, putdat);
  801624:	83 ec 08             	sub    $0x8,%esp
  801627:	53                   	push   %ebx
  801628:	6a 25                	push   $0x25
  80162a:	ff d6                	call   *%esi
			break;
  80162c:	83 c4 10             	add    $0x10,%esp
  80162f:	e9 7a ff ff ff       	jmp    8015ae <vprintfmt+0x3d5>
			putch('%', putdat);
  801634:	83 ec 08             	sub    $0x8,%esp
  801637:	53                   	push   %ebx
  801638:	6a 25                	push   $0x25
  80163a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80163c:	83 c4 10             	add    $0x10,%esp
  80163f:	89 f8                	mov    %edi,%eax
  801641:	eb 03                	jmp    801646 <vprintfmt+0x46d>
  801643:	83 e8 01             	sub    $0x1,%eax
  801646:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80164a:	75 f7                	jne    801643 <vprintfmt+0x46a>
  80164c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80164f:	e9 5a ff ff ff       	jmp    8015ae <vprintfmt+0x3d5>
}
  801654:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801657:	5b                   	pop    %ebx
  801658:	5e                   	pop    %esi
  801659:	5f                   	pop    %edi
  80165a:	5d                   	pop    %ebp
  80165b:	c3                   	ret    

0080165c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	83 ec 18             	sub    $0x18,%esp
  801662:	8b 45 08             	mov    0x8(%ebp),%eax
  801665:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801668:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80166b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80166f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801672:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801679:	85 c0                	test   %eax,%eax
  80167b:	74 26                	je     8016a3 <vsnprintf+0x47>
  80167d:	85 d2                	test   %edx,%edx
  80167f:	7e 22                	jle    8016a3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801681:	ff 75 14             	pushl  0x14(%ebp)
  801684:	ff 75 10             	pushl  0x10(%ebp)
  801687:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80168a:	50                   	push   %eax
  80168b:	68 9f 11 80 00       	push   $0x80119f
  801690:	e8 44 fb ff ff       	call   8011d9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801695:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801698:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80169b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80169e:	83 c4 10             	add    $0x10,%esp
}
  8016a1:	c9                   	leave  
  8016a2:	c3                   	ret    
		return -E_INVAL;
  8016a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016a8:	eb f7                	jmp    8016a1 <vsnprintf+0x45>

008016aa <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016aa:	55                   	push   %ebp
  8016ab:	89 e5                	mov    %esp,%ebp
  8016ad:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016b0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016b3:	50                   	push   %eax
  8016b4:	ff 75 10             	pushl  0x10(%ebp)
  8016b7:	ff 75 0c             	pushl  0xc(%ebp)
  8016ba:	ff 75 08             	pushl  0x8(%ebp)
  8016bd:	e8 9a ff ff ff       	call   80165c <vsnprintf>
	va_end(ap);

	return rc;
}
  8016c2:	c9                   	leave  
  8016c3:	c3                   	ret    

008016c4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016c4:	55                   	push   %ebp
  8016c5:	89 e5                	mov    %esp,%ebp
  8016c7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8016cf:	eb 03                	jmp    8016d4 <strlen+0x10>
		n++;
  8016d1:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8016d4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016d8:	75 f7                	jne    8016d1 <strlen+0xd>
	return n;
}
  8016da:	5d                   	pop    %ebp
  8016db:	c3                   	ret    

008016dc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016dc:	55                   	push   %ebp
  8016dd:	89 e5                	mov    %esp,%ebp
  8016df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016e2:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8016ea:	eb 03                	jmp    8016ef <strnlen+0x13>
		n++;
  8016ec:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016ef:	39 d0                	cmp    %edx,%eax
  8016f1:	74 06                	je     8016f9 <strnlen+0x1d>
  8016f3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8016f7:	75 f3                	jne    8016ec <strnlen+0x10>
	return n;
}
  8016f9:	5d                   	pop    %ebp
  8016fa:	c3                   	ret    

008016fb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016fb:	55                   	push   %ebp
  8016fc:	89 e5                	mov    %esp,%ebp
  8016fe:	53                   	push   %ebx
  8016ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801702:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801705:	89 c2                	mov    %eax,%edx
  801707:	83 c1 01             	add    $0x1,%ecx
  80170a:	83 c2 01             	add    $0x1,%edx
  80170d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801711:	88 5a ff             	mov    %bl,-0x1(%edx)
  801714:	84 db                	test   %bl,%bl
  801716:	75 ef                	jne    801707 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801718:	5b                   	pop    %ebx
  801719:	5d                   	pop    %ebp
  80171a:	c3                   	ret    

0080171b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80171b:	55                   	push   %ebp
  80171c:	89 e5                	mov    %esp,%ebp
  80171e:	53                   	push   %ebx
  80171f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801722:	53                   	push   %ebx
  801723:	e8 9c ff ff ff       	call   8016c4 <strlen>
  801728:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80172b:	ff 75 0c             	pushl  0xc(%ebp)
  80172e:	01 d8                	add    %ebx,%eax
  801730:	50                   	push   %eax
  801731:	e8 c5 ff ff ff       	call   8016fb <strcpy>
	return dst;
}
  801736:	89 d8                	mov    %ebx,%eax
  801738:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80173b:	c9                   	leave  
  80173c:	c3                   	ret    

0080173d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80173d:	55                   	push   %ebp
  80173e:	89 e5                	mov    %esp,%ebp
  801740:	56                   	push   %esi
  801741:	53                   	push   %ebx
  801742:	8b 75 08             	mov    0x8(%ebp),%esi
  801745:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801748:	89 f3                	mov    %esi,%ebx
  80174a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80174d:	89 f2                	mov    %esi,%edx
  80174f:	eb 0f                	jmp    801760 <strncpy+0x23>
		*dst++ = *src;
  801751:	83 c2 01             	add    $0x1,%edx
  801754:	0f b6 01             	movzbl (%ecx),%eax
  801757:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80175a:	80 39 01             	cmpb   $0x1,(%ecx)
  80175d:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  801760:	39 da                	cmp    %ebx,%edx
  801762:	75 ed                	jne    801751 <strncpy+0x14>
	}
	return ret;
}
  801764:	89 f0                	mov    %esi,%eax
  801766:	5b                   	pop    %ebx
  801767:	5e                   	pop    %esi
  801768:	5d                   	pop    %ebp
  801769:	c3                   	ret    

0080176a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80176a:	55                   	push   %ebp
  80176b:	89 e5                	mov    %esp,%ebp
  80176d:	56                   	push   %esi
  80176e:	53                   	push   %ebx
  80176f:	8b 75 08             	mov    0x8(%ebp),%esi
  801772:	8b 55 0c             	mov    0xc(%ebp),%edx
  801775:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801778:	89 f0                	mov    %esi,%eax
  80177a:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80177e:	85 c9                	test   %ecx,%ecx
  801780:	75 0b                	jne    80178d <strlcpy+0x23>
  801782:	eb 17                	jmp    80179b <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801784:	83 c2 01             	add    $0x1,%edx
  801787:	83 c0 01             	add    $0x1,%eax
  80178a:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80178d:	39 d8                	cmp    %ebx,%eax
  80178f:	74 07                	je     801798 <strlcpy+0x2e>
  801791:	0f b6 0a             	movzbl (%edx),%ecx
  801794:	84 c9                	test   %cl,%cl
  801796:	75 ec                	jne    801784 <strlcpy+0x1a>
		*dst = '\0';
  801798:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80179b:	29 f0                	sub    %esi,%eax
}
  80179d:	5b                   	pop    %ebx
  80179e:	5e                   	pop    %esi
  80179f:	5d                   	pop    %ebp
  8017a0:	c3                   	ret    

008017a1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017a1:	55                   	push   %ebp
  8017a2:	89 e5                	mov    %esp,%ebp
  8017a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017a7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017aa:	eb 06                	jmp    8017b2 <strcmp+0x11>
		p++, q++;
  8017ac:	83 c1 01             	add    $0x1,%ecx
  8017af:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8017b2:	0f b6 01             	movzbl (%ecx),%eax
  8017b5:	84 c0                	test   %al,%al
  8017b7:	74 04                	je     8017bd <strcmp+0x1c>
  8017b9:	3a 02                	cmp    (%edx),%al
  8017bb:	74 ef                	je     8017ac <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017bd:	0f b6 c0             	movzbl %al,%eax
  8017c0:	0f b6 12             	movzbl (%edx),%edx
  8017c3:	29 d0                	sub    %edx,%eax
}
  8017c5:	5d                   	pop    %ebp
  8017c6:	c3                   	ret    

008017c7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017c7:	55                   	push   %ebp
  8017c8:	89 e5                	mov    %esp,%ebp
  8017ca:	53                   	push   %ebx
  8017cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017d1:	89 c3                	mov    %eax,%ebx
  8017d3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017d6:	eb 06                	jmp    8017de <strncmp+0x17>
		n--, p++, q++;
  8017d8:	83 c0 01             	add    $0x1,%eax
  8017db:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8017de:	39 d8                	cmp    %ebx,%eax
  8017e0:	74 16                	je     8017f8 <strncmp+0x31>
  8017e2:	0f b6 08             	movzbl (%eax),%ecx
  8017e5:	84 c9                	test   %cl,%cl
  8017e7:	74 04                	je     8017ed <strncmp+0x26>
  8017e9:	3a 0a                	cmp    (%edx),%cl
  8017eb:	74 eb                	je     8017d8 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017ed:	0f b6 00             	movzbl (%eax),%eax
  8017f0:	0f b6 12             	movzbl (%edx),%edx
  8017f3:	29 d0                	sub    %edx,%eax
}
  8017f5:	5b                   	pop    %ebx
  8017f6:	5d                   	pop    %ebp
  8017f7:	c3                   	ret    
		return 0;
  8017f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8017fd:	eb f6                	jmp    8017f5 <strncmp+0x2e>

008017ff <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017ff:	55                   	push   %ebp
  801800:	89 e5                	mov    %esp,%ebp
  801802:	8b 45 08             	mov    0x8(%ebp),%eax
  801805:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801809:	0f b6 10             	movzbl (%eax),%edx
  80180c:	84 d2                	test   %dl,%dl
  80180e:	74 09                	je     801819 <strchr+0x1a>
		if (*s == c)
  801810:	38 ca                	cmp    %cl,%dl
  801812:	74 0a                	je     80181e <strchr+0x1f>
	for (; *s; s++)
  801814:	83 c0 01             	add    $0x1,%eax
  801817:	eb f0                	jmp    801809 <strchr+0xa>
			return (char *) s;
	return 0;
  801819:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80181e:	5d                   	pop    %ebp
  80181f:	c3                   	ret    

00801820 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	8b 45 08             	mov    0x8(%ebp),%eax
  801826:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80182a:	eb 03                	jmp    80182f <strfind+0xf>
  80182c:	83 c0 01             	add    $0x1,%eax
  80182f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801832:	38 ca                	cmp    %cl,%dl
  801834:	74 04                	je     80183a <strfind+0x1a>
  801836:	84 d2                	test   %dl,%dl
  801838:	75 f2                	jne    80182c <strfind+0xc>
			break;
	return (char *) s;
}
  80183a:	5d                   	pop    %ebp
  80183b:	c3                   	ret    

0080183c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80183c:	55                   	push   %ebp
  80183d:	89 e5                	mov    %esp,%ebp
  80183f:	57                   	push   %edi
  801840:	56                   	push   %esi
  801841:	53                   	push   %ebx
  801842:	8b 7d 08             	mov    0x8(%ebp),%edi
  801845:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801848:	85 c9                	test   %ecx,%ecx
  80184a:	74 13                	je     80185f <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80184c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801852:	75 05                	jne    801859 <memset+0x1d>
  801854:	f6 c1 03             	test   $0x3,%cl
  801857:	74 0d                	je     801866 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801859:	8b 45 0c             	mov    0xc(%ebp),%eax
  80185c:	fc                   	cld    
  80185d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80185f:	89 f8                	mov    %edi,%eax
  801861:	5b                   	pop    %ebx
  801862:	5e                   	pop    %esi
  801863:	5f                   	pop    %edi
  801864:	5d                   	pop    %ebp
  801865:	c3                   	ret    
		c &= 0xFF;
  801866:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80186a:	89 d3                	mov    %edx,%ebx
  80186c:	c1 e3 08             	shl    $0x8,%ebx
  80186f:	89 d0                	mov    %edx,%eax
  801871:	c1 e0 18             	shl    $0x18,%eax
  801874:	89 d6                	mov    %edx,%esi
  801876:	c1 e6 10             	shl    $0x10,%esi
  801879:	09 f0                	or     %esi,%eax
  80187b:	09 c2                	or     %eax,%edx
  80187d:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  80187f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801882:	89 d0                	mov    %edx,%eax
  801884:	fc                   	cld    
  801885:	f3 ab                	rep stos %eax,%es:(%edi)
  801887:	eb d6                	jmp    80185f <memset+0x23>

00801889 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801889:	55                   	push   %ebp
  80188a:	89 e5                	mov    %esp,%ebp
  80188c:	57                   	push   %edi
  80188d:	56                   	push   %esi
  80188e:	8b 45 08             	mov    0x8(%ebp),%eax
  801891:	8b 75 0c             	mov    0xc(%ebp),%esi
  801894:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801897:	39 c6                	cmp    %eax,%esi
  801899:	73 35                	jae    8018d0 <memmove+0x47>
  80189b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80189e:	39 c2                	cmp    %eax,%edx
  8018a0:	76 2e                	jbe    8018d0 <memmove+0x47>
		s += n;
		d += n;
  8018a2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018a5:	89 d6                	mov    %edx,%esi
  8018a7:	09 fe                	or     %edi,%esi
  8018a9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018af:	74 0c                	je     8018bd <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018b1:	83 ef 01             	sub    $0x1,%edi
  8018b4:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8018b7:	fd                   	std    
  8018b8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018ba:	fc                   	cld    
  8018bb:	eb 21                	jmp    8018de <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018bd:	f6 c1 03             	test   $0x3,%cl
  8018c0:	75 ef                	jne    8018b1 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8018c2:	83 ef 04             	sub    $0x4,%edi
  8018c5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018c8:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8018cb:	fd                   	std    
  8018cc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018ce:	eb ea                	jmp    8018ba <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018d0:	89 f2                	mov    %esi,%edx
  8018d2:	09 c2                	or     %eax,%edx
  8018d4:	f6 c2 03             	test   $0x3,%dl
  8018d7:	74 09                	je     8018e2 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018d9:	89 c7                	mov    %eax,%edi
  8018db:	fc                   	cld    
  8018dc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018de:	5e                   	pop    %esi
  8018df:	5f                   	pop    %edi
  8018e0:	5d                   	pop    %ebp
  8018e1:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018e2:	f6 c1 03             	test   $0x3,%cl
  8018e5:	75 f2                	jne    8018d9 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018e7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8018ea:	89 c7                	mov    %eax,%edi
  8018ec:	fc                   	cld    
  8018ed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018ef:	eb ed                	jmp    8018de <memmove+0x55>

008018f1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018f1:	55                   	push   %ebp
  8018f2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018f4:	ff 75 10             	pushl  0x10(%ebp)
  8018f7:	ff 75 0c             	pushl  0xc(%ebp)
  8018fa:	ff 75 08             	pushl  0x8(%ebp)
  8018fd:	e8 87 ff ff ff       	call   801889 <memmove>
}
  801902:	c9                   	leave  
  801903:	c3                   	ret    

00801904 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801904:	55                   	push   %ebp
  801905:	89 e5                	mov    %esp,%ebp
  801907:	56                   	push   %esi
  801908:	53                   	push   %ebx
  801909:	8b 45 08             	mov    0x8(%ebp),%eax
  80190c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80190f:	89 c6                	mov    %eax,%esi
  801911:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801914:	39 f0                	cmp    %esi,%eax
  801916:	74 1c                	je     801934 <memcmp+0x30>
		if (*s1 != *s2)
  801918:	0f b6 08             	movzbl (%eax),%ecx
  80191b:	0f b6 1a             	movzbl (%edx),%ebx
  80191e:	38 d9                	cmp    %bl,%cl
  801920:	75 08                	jne    80192a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801922:	83 c0 01             	add    $0x1,%eax
  801925:	83 c2 01             	add    $0x1,%edx
  801928:	eb ea                	jmp    801914 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  80192a:	0f b6 c1             	movzbl %cl,%eax
  80192d:	0f b6 db             	movzbl %bl,%ebx
  801930:	29 d8                	sub    %ebx,%eax
  801932:	eb 05                	jmp    801939 <memcmp+0x35>
	}

	return 0;
  801934:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801939:	5b                   	pop    %ebx
  80193a:	5e                   	pop    %esi
  80193b:	5d                   	pop    %ebp
  80193c:	c3                   	ret    

0080193d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80193d:	55                   	push   %ebp
  80193e:	89 e5                	mov    %esp,%ebp
  801940:	8b 45 08             	mov    0x8(%ebp),%eax
  801943:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801946:	89 c2                	mov    %eax,%edx
  801948:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80194b:	39 d0                	cmp    %edx,%eax
  80194d:	73 09                	jae    801958 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80194f:	38 08                	cmp    %cl,(%eax)
  801951:	74 05                	je     801958 <memfind+0x1b>
	for (; s < ends; s++)
  801953:	83 c0 01             	add    $0x1,%eax
  801956:	eb f3                	jmp    80194b <memfind+0xe>
			break;
	return (void *) s;
}
  801958:	5d                   	pop    %ebp
  801959:	c3                   	ret    

0080195a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80195a:	55                   	push   %ebp
  80195b:	89 e5                	mov    %esp,%ebp
  80195d:	57                   	push   %edi
  80195e:	56                   	push   %esi
  80195f:	53                   	push   %ebx
  801960:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801963:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801966:	eb 03                	jmp    80196b <strtol+0x11>
		s++;
  801968:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  80196b:	0f b6 01             	movzbl (%ecx),%eax
  80196e:	3c 20                	cmp    $0x20,%al
  801970:	74 f6                	je     801968 <strtol+0xe>
  801972:	3c 09                	cmp    $0x9,%al
  801974:	74 f2                	je     801968 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801976:	3c 2b                	cmp    $0x2b,%al
  801978:	74 2e                	je     8019a8 <strtol+0x4e>
	int neg = 0;
  80197a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  80197f:	3c 2d                	cmp    $0x2d,%al
  801981:	74 2f                	je     8019b2 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801983:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801989:	75 05                	jne    801990 <strtol+0x36>
  80198b:	80 39 30             	cmpb   $0x30,(%ecx)
  80198e:	74 2c                	je     8019bc <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801990:	85 db                	test   %ebx,%ebx
  801992:	75 0a                	jne    80199e <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801994:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  801999:	80 39 30             	cmpb   $0x30,(%ecx)
  80199c:	74 28                	je     8019c6 <strtol+0x6c>
		base = 10;
  80199e:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a3:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8019a6:	eb 50                	jmp    8019f8 <strtol+0x9e>
		s++;
  8019a8:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8019ab:	bf 00 00 00 00       	mov    $0x0,%edi
  8019b0:	eb d1                	jmp    801983 <strtol+0x29>
		s++, neg = 1;
  8019b2:	83 c1 01             	add    $0x1,%ecx
  8019b5:	bf 01 00 00 00       	mov    $0x1,%edi
  8019ba:	eb c7                	jmp    801983 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019bc:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019c0:	74 0e                	je     8019d0 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8019c2:	85 db                	test   %ebx,%ebx
  8019c4:	75 d8                	jne    80199e <strtol+0x44>
		s++, base = 8;
  8019c6:	83 c1 01             	add    $0x1,%ecx
  8019c9:	bb 08 00 00 00       	mov    $0x8,%ebx
  8019ce:	eb ce                	jmp    80199e <strtol+0x44>
		s += 2, base = 16;
  8019d0:	83 c1 02             	add    $0x2,%ecx
  8019d3:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019d8:	eb c4                	jmp    80199e <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  8019da:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019dd:	89 f3                	mov    %esi,%ebx
  8019df:	80 fb 19             	cmp    $0x19,%bl
  8019e2:	77 29                	ja     801a0d <strtol+0xb3>
			dig = *s - 'a' + 10;
  8019e4:	0f be d2             	movsbl %dl,%edx
  8019e7:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019ea:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019ed:	7d 30                	jge    801a1f <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8019ef:	83 c1 01             	add    $0x1,%ecx
  8019f2:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019f6:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8019f8:	0f b6 11             	movzbl (%ecx),%edx
  8019fb:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019fe:	89 f3                	mov    %esi,%ebx
  801a00:	80 fb 09             	cmp    $0x9,%bl
  801a03:	77 d5                	ja     8019da <strtol+0x80>
			dig = *s - '0';
  801a05:	0f be d2             	movsbl %dl,%edx
  801a08:	83 ea 30             	sub    $0x30,%edx
  801a0b:	eb dd                	jmp    8019ea <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  801a0d:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a10:	89 f3                	mov    %esi,%ebx
  801a12:	80 fb 19             	cmp    $0x19,%bl
  801a15:	77 08                	ja     801a1f <strtol+0xc5>
			dig = *s - 'A' + 10;
  801a17:	0f be d2             	movsbl %dl,%edx
  801a1a:	83 ea 37             	sub    $0x37,%edx
  801a1d:	eb cb                	jmp    8019ea <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  801a1f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a23:	74 05                	je     801a2a <strtol+0xd0>
		*endptr = (char *) s;
  801a25:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a28:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a2a:	89 c2                	mov    %eax,%edx
  801a2c:	f7 da                	neg    %edx
  801a2e:	85 ff                	test   %edi,%edi
  801a30:	0f 45 c2             	cmovne %edx,%eax
}
  801a33:	5b                   	pop    %ebx
  801a34:	5e                   	pop    %esi
  801a35:	5f                   	pop    %edi
  801a36:	5d                   	pop    %ebp
  801a37:	c3                   	ret    

00801a38 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a38:	55                   	push   %ebp
  801a39:	89 e5                	mov    %esp,%ebp
  801a3b:	56                   	push   %esi
  801a3c:	53                   	push   %ebx
  801a3d:	8b 75 08             	mov    0x8(%ebp),%esi
  801a40:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a43:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        //	panic("ipc_recv not implemented");
        int r;
       	if(pg!=NULL){
  801a46:	85 c0                	test   %eax,%eax
  801a48:	74 3b                	je     801a85 <ipc_recv+0x4d>
	  r = sys_ipc_recv(pg);
  801a4a:	83 ec 0c             	sub    $0xc,%esp
  801a4d:	50                   	push   %eax
  801a4e:	e8 b2 e8 ff ff       	call   800305 <sys_ipc_recv>
  801a53:	83 c4 10             	add    $0x10,%esp
	}else
	  r = sys_ipc_recv((void *)UTOP);
	if(r<0){
  801a56:	85 c0                	test   %eax,%eax
  801a58:	78 3d                	js     801a97 <ipc_recv+0x5f>
	if(perm_store!=NULL){
		*perm_store = 0;
            }
        	return r;
           }else{
	     if(from_env_store!=NULL)
  801a5a:	85 f6                	test   %esi,%esi
  801a5c:	74 0a                	je     801a68 <ipc_recv+0x30>
		     *from_env_store = thisenv->env_ipc_from;
  801a5e:	a1 04 40 80 00       	mov    0x804004,%eax
  801a63:	8b 40 74             	mov    0x74(%eax),%eax
  801a66:	89 06                	mov    %eax,(%esi)
	     if(perm_store != NULL)
  801a68:	85 db                	test   %ebx,%ebx
  801a6a:	74 0a                	je     801a76 <ipc_recv+0x3e>
		     *perm_store = thisenv->env_ipc_perm;
  801a6c:	a1 04 40 80 00       	mov    0x804004,%eax
  801a71:	8b 40 78             	mov    0x78(%eax),%eax
  801a74:	89 03                	mov    %eax,(%ebx)
	     return thisenv->env_ipc_value;
  801a76:	a1 04 40 80 00       	mov    0x804004,%eax
  801a7b:	8b 40 70             	mov    0x70(%eax),%eax
	   }

}
  801a7e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a81:	5b                   	pop    %ebx
  801a82:	5e                   	pop    %esi
  801a83:	5d                   	pop    %ebp
  801a84:	c3                   	ret    
	  r = sys_ipc_recv((void *)UTOP);
  801a85:	83 ec 0c             	sub    $0xc,%esp
  801a88:	68 00 00 c0 ee       	push   $0xeec00000
  801a8d:	e8 73 e8 ff ff       	call   800305 <sys_ipc_recv>
  801a92:	83 c4 10             	add    $0x10,%esp
  801a95:	eb bf                	jmp    801a56 <ipc_recv+0x1e>
	if(from_env_store!=NULL){
  801a97:	85 f6                	test   %esi,%esi
  801a99:	74 06                	je     801aa1 <ipc_recv+0x69>
	  *from_env_store = 0;
  801a9b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(perm_store!=NULL){
  801aa1:	85 db                	test   %ebx,%ebx
  801aa3:	74 d9                	je     801a7e <ipc_recv+0x46>
		*perm_store = 0;
  801aa5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801aab:	eb d1                	jmp    801a7e <ipc_recv+0x46>

00801aad <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801aad:	55                   	push   %ebp
  801aae:	89 e5                	mov    %esp,%ebp
  801ab0:	57                   	push   %edi
  801ab1:	56                   	push   %esi
  801ab2:	53                   	push   %ebx
  801ab3:	83 ec 0c             	sub    $0xc,%esp
  801ab6:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ab9:	8b 75 0c             	mov    0xc(%ebp),%esi
  801abc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if(pg==NULL) pg = (void *)UTOP;
  801abf:	85 db                	test   %ebx,%ebx
  801ac1:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ac6:	0f 44 d8             	cmove  %eax,%ebx
	while((r=sys_ipc_try_send(to_env,val,pg,perm))<0){
  801ac9:	ff 75 14             	pushl  0x14(%ebp)
  801acc:	53                   	push   %ebx
  801acd:	56                   	push   %esi
  801ace:	57                   	push   %edi
  801acf:	e8 0e e8 ff ff       	call   8002e2 <sys_ipc_try_send>
  801ad4:	83 c4 10             	add    $0x10,%esp
  801ad7:	85 c0                	test   %eax,%eax
  801ad9:	79 20                	jns    801afb <ipc_send+0x4e>
	    if(r!=-E_IPC_NOT_RECV){
  801adb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ade:	75 07                	jne    801ae7 <ipc_send+0x3a>
		    panic("ipc_send:send message failed\n");
	    }
	    sys_yield();
  801ae0:	e8 51 e6 ff ff       	call   800136 <sys_yield>
  801ae5:	eb e2                	jmp    801ac9 <ipc_send+0x1c>
		    panic("ipc_send:send message failed\n");
  801ae7:	83 ec 04             	sub    $0x4,%esp
  801aea:	68 00 22 80 00       	push   $0x802200
  801aef:	6a 43                	push   $0x43
  801af1:	68 1e 22 80 00       	push   $0x80221e
  801af6:	e8 06 f5 ff ff       	call   801001 <_panic>
	}

}
  801afb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801afe:	5b                   	pop    %ebx
  801aff:	5e                   	pop    %esi
  801b00:	5f                   	pop    %edi
  801b01:	5d                   	pop    %ebp
  801b02:	c3                   	ret    

00801b03 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b03:	55                   	push   %ebp
  801b04:	89 e5                	mov    %esp,%ebp
  801b06:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b09:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b0e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b11:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b17:	8b 52 50             	mov    0x50(%edx),%edx
  801b1a:	39 ca                	cmp    %ecx,%edx
  801b1c:	74 11                	je     801b2f <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801b1e:	83 c0 01             	add    $0x1,%eax
  801b21:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b26:	75 e6                	jne    801b0e <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801b28:	b8 00 00 00 00       	mov    $0x0,%eax
  801b2d:	eb 0b                	jmp    801b3a <ipc_find_env+0x37>
			return envs[i].env_id;
  801b2f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b32:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b37:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b3a:	5d                   	pop    %ebp
  801b3b:	c3                   	ret    

00801b3c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b3c:	55                   	push   %ebp
  801b3d:	89 e5                	mov    %esp,%ebp
  801b3f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b42:	89 d0                	mov    %edx,%eax
  801b44:	c1 e8 16             	shr    $0x16,%eax
  801b47:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b4e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801b53:	f6 c1 01             	test   $0x1,%cl
  801b56:	74 1d                	je     801b75 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801b58:	c1 ea 0c             	shr    $0xc,%edx
  801b5b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b62:	f6 c2 01             	test   $0x1,%dl
  801b65:	74 0e                	je     801b75 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b67:	c1 ea 0c             	shr    $0xc,%edx
  801b6a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b71:	ef 
  801b72:	0f b7 c0             	movzwl %ax,%eax
}
  801b75:	5d                   	pop    %ebp
  801b76:	c3                   	ret    
  801b77:	66 90                	xchg   %ax,%ax
  801b79:	66 90                	xchg   %ax,%ax
  801b7b:	66 90                	xchg   %ax,%ax
  801b7d:	66 90                	xchg   %ax,%ax
  801b7f:	90                   	nop

00801b80 <__udivdi3>:
  801b80:	55                   	push   %ebp
  801b81:	57                   	push   %edi
  801b82:	56                   	push   %esi
  801b83:	53                   	push   %ebx
  801b84:	83 ec 1c             	sub    $0x1c,%esp
  801b87:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801b8b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801b8f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801b93:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801b97:	85 d2                	test   %edx,%edx
  801b99:	75 35                	jne    801bd0 <__udivdi3+0x50>
  801b9b:	39 f3                	cmp    %esi,%ebx
  801b9d:	0f 87 bd 00 00 00    	ja     801c60 <__udivdi3+0xe0>
  801ba3:	85 db                	test   %ebx,%ebx
  801ba5:	89 d9                	mov    %ebx,%ecx
  801ba7:	75 0b                	jne    801bb4 <__udivdi3+0x34>
  801ba9:	b8 01 00 00 00       	mov    $0x1,%eax
  801bae:	31 d2                	xor    %edx,%edx
  801bb0:	f7 f3                	div    %ebx
  801bb2:	89 c1                	mov    %eax,%ecx
  801bb4:	31 d2                	xor    %edx,%edx
  801bb6:	89 f0                	mov    %esi,%eax
  801bb8:	f7 f1                	div    %ecx
  801bba:	89 c6                	mov    %eax,%esi
  801bbc:	89 e8                	mov    %ebp,%eax
  801bbe:	89 f7                	mov    %esi,%edi
  801bc0:	f7 f1                	div    %ecx
  801bc2:	89 fa                	mov    %edi,%edx
  801bc4:	83 c4 1c             	add    $0x1c,%esp
  801bc7:	5b                   	pop    %ebx
  801bc8:	5e                   	pop    %esi
  801bc9:	5f                   	pop    %edi
  801bca:	5d                   	pop    %ebp
  801bcb:	c3                   	ret    
  801bcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801bd0:	39 f2                	cmp    %esi,%edx
  801bd2:	77 7c                	ja     801c50 <__udivdi3+0xd0>
  801bd4:	0f bd fa             	bsr    %edx,%edi
  801bd7:	83 f7 1f             	xor    $0x1f,%edi
  801bda:	0f 84 98 00 00 00    	je     801c78 <__udivdi3+0xf8>
  801be0:	89 f9                	mov    %edi,%ecx
  801be2:	b8 20 00 00 00       	mov    $0x20,%eax
  801be7:	29 f8                	sub    %edi,%eax
  801be9:	d3 e2                	shl    %cl,%edx
  801beb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801bef:	89 c1                	mov    %eax,%ecx
  801bf1:	89 da                	mov    %ebx,%edx
  801bf3:	d3 ea                	shr    %cl,%edx
  801bf5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801bf9:	09 d1                	or     %edx,%ecx
  801bfb:	89 f2                	mov    %esi,%edx
  801bfd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c01:	89 f9                	mov    %edi,%ecx
  801c03:	d3 e3                	shl    %cl,%ebx
  801c05:	89 c1                	mov    %eax,%ecx
  801c07:	d3 ea                	shr    %cl,%edx
  801c09:	89 f9                	mov    %edi,%ecx
  801c0b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c0f:	d3 e6                	shl    %cl,%esi
  801c11:	89 eb                	mov    %ebp,%ebx
  801c13:	89 c1                	mov    %eax,%ecx
  801c15:	d3 eb                	shr    %cl,%ebx
  801c17:	09 de                	or     %ebx,%esi
  801c19:	89 f0                	mov    %esi,%eax
  801c1b:	f7 74 24 08          	divl   0x8(%esp)
  801c1f:	89 d6                	mov    %edx,%esi
  801c21:	89 c3                	mov    %eax,%ebx
  801c23:	f7 64 24 0c          	mull   0xc(%esp)
  801c27:	39 d6                	cmp    %edx,%esi
  801c29:	72 0c                	jb     801c37 <__udivdi3+0xb7>
  801c2b:	89 f9                	mov    %edi,%ecx
  801c2d:	d3 e5                	shl    %cl,%ebp
  801c2f:	39 c5                	cmp    %eax,%ebp
  801c31:	73 5d                	jae    801c90 <__udivdi3+0x110>
  801c33:	39 d6                	cmp    %edx,%esi
  801c35:	75 59                	jne    801c90 <__udivdi3+0x110>
  801c37:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801c3a:	31 ff                	xor    %edi,%edi
  801c3c:	89 fa                	mov    %edi,%edx
  801c3e:	83 c4 1c             	add    $0x1c,%esp
  801c41:	5b                   	pop    %ebx
  801c42:	5e                   	pop    %esi
  801c43:	5f                   	pop    %edi
  801c44:	5d                   	pop    %ebp
  801c45:	c3                   	ret    
  801c46:	8d 76 00             	lea    0x0(%esi),%esi
  801c49:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801c50:	31 ff                	xor    %edi,%edi
  801c52:	31 c0                	xor    %eax,%eax
  801c54:	89 fa                	mov    %edi,%edx
  801c56:	83 c4 1c             	add    $0x1c,%esp
  801c59:	5b                   	pop    %ebx
  801c5a:	5e                   	pop    %esi
  801c5b:	5f                   	pop    %edi
  801c5c:	5d                   	pop    %ebp
  801c5d:	c3                   	ret    
  801c5e:	66 90                	xchg   %ax,%ax
  801c60:	31 ff                	xor    %edi,%edi
  801c62:	89 e8                	mov    %ebp,%eax
  801c64:	89 f2                	mov    %esi,%edx
  801c66:	f7 f3                	div    %ebx
  801c68:	89 fa                	mov    %edi,%edx
  801c6a:	83 c4 1c             	add    $0x1c,%esp
  801c6d:	5b                   	pop    %ebx
  801c6e:	5e                   	pop    %esi
  801c6f:	5f                   	pop    %edi
  801c70:	5d                   	pop    %ebp
  801c71:	c3                   	ret    
  801c72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c78:	39 f2                	cmp    %esi,%edx
  801c7a:	72 06                	jb     801c82 <__udivdi3+0x102>
  801c7c:	31 c0                	xor    %eax,%eax
  801c7e:	39 eb                	cmp    %ebp,%ebx
  801c80:	77 d2                	ja     801c54 <__udivdi3+0xd4>
  801c82:	b8 01 00 00 00       	mov    $0x1,%eax
  801c87:	eb cb                	jmp    801c54 <__udivdi3+0xd4>
  801c89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c90:	89 d8                	mov    %ebx,%eax
  801c92:	31 ff                	xor    %edi,%edi
  801c94:	eb be                	jmp    801c54 <__udivdi3+0xd4>
  801c96:	66 90                	xchg   %ax,%ax
  801c98:	66 90                	xchg   %ax,%ax
  801c9a:	66 90                	xchg   %ax,%ax
  801c9c:	66 90                	xchg   %ax,%ax
  801c9e:	66 90                	xchg   %ax,%ax

00801ca0 <__umoddi3>:
  801ca0:	55                   	push   %ebp
  801ca1:	57                   	push   %edi
  801ca2:	56                   	push   %esi
  801ca3:	53                   	push   %ebx
  801ca4:	83 ec 1c             	sub    $0x1c,%esp
  801ca7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801cab:	8b 74 24 30          	mov    0x30(%esp),%esi
  801caf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801cb3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cb7:	85 ed                	test   %ebp,%ebp
  801cb9:	89 f0                	mov    %esi,%eax
  801cbb:	89 da                	mov    %ebx,%edx
  801cbd:	75 19                	jne    801cd8 <__umoddi3+0x38>
  801cbf:	39 df                	cmp    %ebx,%edi
  801cc1:	0f 86 b1 00 00 00    	jbe    801d78 <__umoddi3+0xd8>
  801cc7:	f7 f7                	div    %edi
  801cc9:	89 d0                	mov    %edx,%eax
  801ccb:	31 d2                	xor    %edx,%edx
  801ccd:	83 c4 1c             	add    $0x1c,%esp
  801cd0:	5b                   	pop    %ebx
  801cd1:	5e                   	pop    %esi
  801cd2:	5f                   	pop    %edi
  801cd3:	5d                   	pop    %ebp
  801cd4:	c3                   	ret    
  801cd5:	8d 76 00             	lea    0x0(%esi),%esi
  801cd8:	39 dd                	cmp    %ebx,%ebp
  801cda:	77 f1                	ja     801ccd <__umoddi3+0x2d>
  801cdc:	0f bd cd             	bsr    %ebp,%ecx
  801cdf:	83 f1 1f             	xor    $0x1f,%ecx
  801ce2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801ce6:	0f 84 b4 00 00 00    	je     801da0 <__umoddi3+0x100>
  801cec:	b8 20 00 00 00       	mov    $0x20,%eax
  801cf1:	89 c2                	mov    %eax,%edx
  801cf3:	8b 44 24 04          	mov    0x4(%esp),%eax
  801cf7:	29 c2                	sub    %eax,%edx
  801cf9:	89 c1                	mov    %eax,%ecx
  801cfb:	89 f8                	mov    %edi,%eax
  801cfd:	d3 e5                	shl    %cl,%ebp
  801cff:	89 d1                	mov    %edx,%ecx
  801d01:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801d05:	d3 e8                	shr    %cl,%eax
  801d07:	09 c5                	or     %eax,%ebp
  801d09:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d0d:	89 c1                	mov    %eax,%ecx
  801d0f:	d3 e7                	shl    %cl,%edi
  801d11:	89 d1                	mov    %edx,%ecx
  801d13:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801d17:	89 df                	mov    %ebx,%edi
  801d19:	d3 ef                	shr    %cl,%edi
  801d1b:	89 c1                	mov    %eax,%ecx
  801d1d:	89 f0                	mov    %esi,%eax
  801d1f:	d3 e3                	shl    %cl,%ebx
  801d21:	89 d1                	mov    %edx,%ecx
  801d23:	89 fa                	mov    %edi,%edx
  801d25:	d3 e8                	shr    %cl,%eax
  801d27:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801d2c:	09 d8                	or     %ebx,%eax
  801d2e:	f7 f5                	div    %ebp
  801d30:	d3 e6                	shl    %cl,%esi
  801d32:	89 d1                	mov    %edx,%ecx
  801d34:	f7 64 24 08          	mull   0x8(%esp)
  801d38:	39 d1                	cmp    %edx,%ecx
  801d3a:	89 c3                	mov    %eax,%ebx
  801d3c:	89 d7                	mov    %edx,%edi
  801d3e:	72 06                	jb     801d46 <__umoddi3+0xa6>
  801d40:	75 0e                	jne    801d50 <__umoddi3+0xb0>
  801d42:	39 c6                	cmp    %eax,%esi
  801d44:	73 0a                	jae    801d50 <__umoddi3+0xb0>
  801d46:	2b 44 24 08          	sub    0x8(%esp),%eax
  801d4a:	19 ea                	sbb    %ebp,%edx
  801d4c:	89 d7                	mov    %edx,%edi
  801d4e:	89 c3                	mov    %eax,%ebx
  801d50:	89 ca                	mov    %ecx,%edx
  801d52:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801d57:	29 de                	sub    %ebx,%esi
  801d59:	19 fa                	sbb    %edi,%edx
  801d5b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  801d5f:	89 d0                	mov    %edx,%eax
  801d61:	d3 e0                	shl    %cl,%eax
  801d63:	89 d9                	mov    %ebx,%ecx
  801d65:	d3 ee                	shr    %cl,%esi
  801d67:	d3 ea                	shr    %cl,%edx
  801d69:	09 f0                	or     %esi,%eax
  801d6b:	83 c4 1c             	add    $0x1c,%esp
  801d6e:	5b                   	pop    %ebx
  801d6f:	5e                   	pop    %esi
  801d70:	5f                   	pop    %edi
  801d71:	5d                   	pop    %ebp
  801d72:	c3                   	ret    
  801d73:	90                   	nop
  801d74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d78:	85 ff                	test   %edi,%edi
  801d7a:	89 f9                	mov    %edi,%ecx
  801d7c:	75 0b                	jne    801d89 <__umoddi3+0xe9>
  801d7e:	b8 01 00 00 00       	mov    $0x1,%eax
  801d83:	31 d2                	xor    %edx,%edx
  801d85:	f7 f7                	div    %edi
  801d87:	89 c1                	mov    %eax,%ecx
  801d89:	89 d8                	mov    %ebx,%eax
  801d8b:	31 d2                	xor    %edx,%edx
  801d8d:	f7 f1                	div    %ecx
  801d8f:	89 f0                	mov    %esi,%eax
  801d91:	f7 f1                	div    %ecx
  801d93:	e9 31 ff ff ff       	jmp    801cc9 <__umoddi3+0x29>
  801d98:	90                   	nop
  801d99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801da0:	39 dd                	cmp    %ebx,%ebp
  801da2:	72 08                	jb     801dac <__umoddi3+0x10c>
  801da4:	39 f7                	cmp    %esi,%edi
  801da6:	0f 87 21 ff ff ff    	ja     801ccd <__umoddi3+0x2d>
  801dac:	89 da                	mov    %ebx,%edx
  801dae:	89 f0                	mov    %esi,%eax
  801db0:	29 f8                	sub    %edi,%eax
  801db2:	19 ea                	sbb    %ebp,%edx
  801db4:	e9 14 ff ff ff       	jmp    801ccd <__umoddi3+0x2d>
