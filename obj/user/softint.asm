
obj/user/softint.debug:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800042:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800045:	e8 ce 00 00 00       	call   800118 <sys_getenvid>
  80004a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800052:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800057:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005c:	85 db                	test   %ebx,%ebx
  80005e:	7e 07                	jle    800067 <libmain+0x2d>
		binaryname = argv[0];
  800060:	8b 06                	mov    (%esi),%eax
  800062:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800067:	83 ec 08             	sub    $0x8,%esp
  80006a:	56                   	push   %esi
  80006b:	53                   	push   %ebx
  80006c:	e8 c2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800071:	e8 0a 00 00 00       	call   800080 <exit>
}
  800076:	83 c4 10             	add    $0x10,%esp
  800079:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007c:	5b                   	pop    %ebx
  80007d:	5e                   	pop    %esi
  80007e:	5d                   	pop    %ebp
  80007f:	c3                   	ret    

00800080 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800086:	e8 92 04 00 00       	call   80051d <close_all>
	sys_env_destroy(0);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	6a 00                	push   $0x0
  800090:	e8 42 00 00 00       	call   8000d7 <sys_env_destroy>
}
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	57                   	push   %edi
  80009e:	56                   	push   %esi
  80009f:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ab:	89 c3                	mov    %eax,%ebx
  8000ad:	89 c7                	mov    %eax,%edi
  8000af:	89 c6                	mov    %eax,%esi
  8000b1:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b3:	5b                   	pop    %ebx
  8000b4:	5e                   	pop    %esi
  8000b5:	5f                   	pop    %edi
  8000b6:	5d                   	pop    %ebp
  8000b7:	c3                   	ret    

008000b8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	57                   	push   %edi
  8000bc:	56                   	push   %esi
  8000bd:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000be:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c8:	89 d1                	mov    %edx,%ecx
  8000ca:	89 d3                	mov    %edx,%ebx
  8000cc:	89 d7                	mov    %edx,%edi
  8000ce:	89 d6                	mov    %edx,%esi
  8000d0:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d2:	5b                   	pop    %ebx
  8000d3:	5e                   	pop    %esi
  8000d4:	5f                   	pop    %edi
  8000d5:	5d                   	pop    %ebp
  8000d6:	c3                   	ret    

008000d7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d7:	55                   	push   %ebp
  8000d8:	89 e5                	mov    %esp,%ebp
  8000da:	57                   	push   %edi
  8000db:	56                   	push   %esi
  8000dc:	53                   	push   %ebx
  8000dd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e8:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ed:	89 cb                	mov    %ecx,%ebx
  8000ef:	89 cf                	mov    %ecx,%edi
  8000f1:	89 ce                	mov    %ecx,%esi
  8000f3:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000f5:	85 c0                	test   %eax,%eax
  8000f7:	7f 08                	jg     800101 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000fc:	5b                   	pop    %ebx
  8000fd:	5e                   	pop    %esi
  8000fe:	5f                   	pop    %edi
  8000ff:	5d                   	pop    %ebp
  800100:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800101:	83 ec 0c             	sub    $0xc,%esp
  800104:	50                   	push   %eax
  800105:	6a 03                	push   $0x3
  800107:	68 ca 1d 80 00       	push   $0x801dca
  80010c:	6a 23                	push   $0x23
  80010e:	68 e7 1d 80 00       	push   $0x801de7
  800113:	e8 ea 0e 00 00       	call   801002 <_panic>

00800118 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	57                   	push   %edi
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80011e:	ba 00 00 00 00       	mov    $0x0,%edx
  800123:	b8 02 00 00 00       	mov    $0x2,%eax
  800128:	89 d1                	mov    %edx,%ecx
  80012a:	89 d3                	mov    %edx,%ebx
  80012c:	89 d7                	mov    %edx,%edi
  80012e:	89 d6                	mov    %edx,%esi
  800130:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800132:	5b                   	pop    %ebx
  800133:	5e                   	pop    %esi
  800134:	5f                   	pop    %edi
  800135:	5d                   	pop    %ebp
  800136:	c3                   	ret    

00800137 <sys_yield>:

void
sys_yield(void)
{
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	57                   	push   %edi
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80013d:	ba 00 00 00 00       	mov    $0x0,%edx
  800142:	b8 0b 00 00 00       	mov    $0xb,%eax
  800147:	89 d1                	mov    %edx,%ecx
  800149:	89 d3                	mov    %edx,%ebx
  80014b:	89 d7                	mov    %edx,%edi
  80014d:	89 d6                	mov    %edx,%esi
  80014f:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800151:	5b                   	pop    %ebx
  800152:	5e                   	pop    %esi
  800153:	5f                   	pop    %edi
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    

00800156 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	57                   	push   %edi
  80015a:	56                   	push   %esi
  80015b:	53                   	push   %ebx
  80015c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80015f:	be 00 00 00 00       	mov    $0x0,%esi
  800164:	8b 55 08             	mov    0x8(%ebp),%edx
  800167:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016a:	b8 04 00 00 00       	mov    $0x4,%eax
  80016f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800172:	89 f7                	mov    %esi,%edi
  800174:	cd 30                	int    $0x30
	if(check && ret > 0)
  800176:	85 c0                	test   %eax,%eax
  800178:	7f 08                	jg     800182 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80017a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80017d:	5b                   	pop    %ebx
  80017e:	5e                   	pop    %esi
  80017f:	5f                   	pop    %edi
  800180:	5d                   	pop    %ebp
  800181:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800182:	83 ec 0c             	sub    $0xc,%esp
  800185:	50                   	push   %eax
  800186:	6a 04                	push   $0x4
  800188:	68 ca 1d 80 00       	push   $0x801dca
  80018d:	6a 23                	push   $0x23
  80018f:	68 e7 1d 80 00       	push   $0x801de7
  800194:	e8 69 0e 00 00       	call   801002 <_panic>

00800199 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	57                   	push   %edi
  80019d:	56                   	push   %esi
  80019e:	53                   	push   %ebx
  80019f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a8:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b6:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001b8:	85 c0                	test   %eax,%eax
  8001ba:	7f 08                	jg     8001c4 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001bf:	5b                   	pop    %ebx
  8001c0:	5e                   	pop    %esi
  8001c1:	5f                   	pop    %edi
  8001c2:	5d                   	pop    %ebp
  8001c3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c4:	83 ec 0c             	sub    $0xc,%esp
  8001c7:	50                   	push   %eax
  8001c8:	6a 05                	push   $0x5
  8001ca:	68 ca 1d 80 00       	push   $0x801dca
  8001cf:	6a 23                	push   $0x23
  8001d1:	68 e7 1d 80 00       	push   $0x801de7
  8001d6:	e8 27 0e 00 00       	call   801002 <_panic>

008001db <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	57                   	push   %edi
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
  8001e1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ef:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f4:	89 df                	mov    %ebx,%edi
  8001f6:	89 de                	mov    %ebx,%esi
  8001f8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001fa:	85 c0                	test   %eax,%eax
  8001fc:	7f 08                	jg     800206 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8001fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800201:	5b                   	pop    %ebx
  800202:	5e                   	pop    %esi
  800203:	5f                   	pop    %edi
  800204:	5d                   	pop    %ebp
  800205:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800206:	83 ec 0c             	sub    $0xc,%esp
  800209:	50                   	push   %eax
  80020a:	6a 06                	push   $0x6
  80020c:	68 ca 1d 80 00       	push   $0x801dca
  800211:	6a 23                	push   $0x23
  800213:	68 e7 1d 80 00       	push   $0x801de7
  800218:	e8 e5 0d 00 00       	call   801002 <_panic>

0080021d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	57                   	push   %edi
  800221:	56                   	push   %esi
  800222:	53                   	push   %ebx
  800223:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800226:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022b:	8b 55 08             	mov    0x8(%ebp),%edx
  80022e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800231:	b8 08 00 00 00       	mov    $0x8,%eax
  800236:	89 df                	mov    %ebx,%edi
  800238:	89 de                	mov    %ebx,%esi
  80023a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80023c:	85 c0                	test   %eax,%eax
  80023e:	7f 08                	jg     800248 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800240:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800243:	5b                   	pop    %ebx
  800244:	5e                   	pop    %esi
  800245:	5f                   	pop    %edi
  800246:	5d                   	pop    %ebp
  800247:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800248:	83 ec 0c             	sub    $0xc,%esp
  80024b:	50                   	push   %eax
  80024c:	6a 08                	push   $0x8
  80024e:	68 ca 1d 80 00       	push   $0x801dca
  800253:	6a 23                	push   $0x23
  800255:	68 e7 1d 80 00       	push   $0x801de7
  80025a:	e8 a3 0d 00 00       	call   801002 <_panic>

0080025f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	57                   	push   %edi
  800263:	56                   	push   %esi
  800264:	53                   	push   %ebx
  800265:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800268:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026d:	8b 55 08             	mov    0x8(%ebp),%edx
  800270:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800273:	b8 09 00 00 00       	mov    $0x9,%eax
  800278:	89 df                	mov    %ebx,%edi
  80027a:	89 de                	mov    %ebx,%esi
  80027c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80027e:	85 c0                	test   %eax,%eax
  800280:	7f 08                	jg     80028a <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800282:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800285:	5b                   	pop    %ebx
  800286:	5e                   	pop    %esi
  800287:	5f                   	pop    %edi
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80028a:	83 ec 0c             	sub    $0xc,%esp
  80028d:	50                   	push   %eax
  80028e:	6a 09                	push   $0x9
  800290:	68 ca 1d 80 00       	push   $0x801dca
  800295:	6a 23                	push   $0x23
  800297:	68 e7 1d 80 00       	push   $0x801de7
  80029c:	e8 61 0d 00 00       	call   801002 <_panic>

008002a1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	57                   	push   %edi
  8002a5:	56                   	push   %esi
  8002a6:	53                   	push   %ebx
  8002a7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002af:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002ba:	89 df                	mov    %ebx,%edi
  8002bc:	89 de                	mov    %ebx,%esi
  8002be:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002c0:	85 c0                	test   %eax,%eax
  8002c2:	7f 08                	jg     8002cc <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c7:	5b                   	pop    %ebx
  8002c8:	5e                   	pop    %esi
  8002c9:	5f                   	pop    %edi
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002cc:	83 ec 0c             	sub    $0xc,%esp
  8002cf:	50                   	push   %eax
  8002d0:	6a 0a                	push   $0xa
  8002d2:	68 ca 1d 80 00       	push   $0x801dca
  8002d7:	6a 23                	push   $0x23
  8002d9:	68 e7 1d 80 00       	push   $0x801de7
  8002de:	e8 1f 0d 00 00       	call   801002 <_panic>

008002e3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	57                   	push   %edi
  8002e7:	56                   	push   %esi
  8002e8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ef:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f4:	be 00 00 00 00       	mov    $0x0,%esi
  8002f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002ff:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800301:	5b                   	pop    %ebx
  800302:	5e                   	pop    %esi
  800303:	5f                   	pop    %edi
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    

00800306 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	57                   	push   %edi
  80030a:	56                   	push   %esi
  80030b:	53                   	push   %ebx
  80030c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80030f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800314:	8b 55 08             	mov    0x8(%ebp),%edx
  800317:	b8 0d 00 00 00       	mov    $0xd,%eax
  80031c:	89 cb                	mov    %ecx,%ebx
  80031e:	89 cf                	mov    %ecx,%edi
  800320:	89 ce                	mov    %ecx,%esi
  800322:	cd 30                	int    $0x30
	if(check && ret > 0)
  800324:	85 c0                	test   %eax,%eax
  800326:	7f 08                	jg     800330 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800328:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032b:	5b                   	pop    %ebx
  80032c:	5e                   	pop    %esi
  80032d:	5f                   	pop    %edi
  80032e:	5d                   	pop    %ebp
  80032f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	50                   	push   %eax
  800334:	6a 0d                	push   $0xd
  800336:	68 ca 1d 80 00       	push   $0x801dca
  80033b:	6a 23                	push   $0x23
  80033d:	68 e7 1d 80 00       	push   $0x801de7
  800342:	e8 bb 0c 00 00       	call   801002 <_panic>

00800347 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80034a:	8b 45 08             	mov    0x8(%ebp),%eax
  80034d:	05 00 00 00 30       	add    $0x30000000,%eax
  800352:	c1 e8 0c             	shr    $0xc,%eax
}
  800355:	5d                   	pop    %ebp
  800356:	c3                   	ret    

00800357 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035a:	8b 45 08             	mov    0x8(%ebp),%eax
  80035d:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800362:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800367:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80036c:	5d                   	pop    %ebp
  80036d:	c3                   	ret    

0080036e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
  800371:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800374:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800379:	89 c2                	mov    %eax,%edx
  80037b:	c1 ea 16             	shr    $0x16,%edx
  80037e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800385:	f6 c2 01             	test   $0x1,%dl
  800388:	74 2a                	je     8003b4 <fd_alloc+0x46>
  80038a:	89 c2                	mov    %eax,%edx
  80038c:	c1 ea 0c             	shr    $0xc,%edx
  80038f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800396:	f6 c2 01             	test   $0x1,%dl
  800399:	74 19                	je     8003b4 <fd_alloc+0x46>
  80039b:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8003a0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003a5:	75 d2                	jne    800379 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003a7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003ad:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8003b2:	eb 07                	jmp    8003bb <fd_alloc+0x4d>
			*fd_store = fd;
  8003b4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003bb:	5d                   	pop    %ebp
  8003bc:	c3                   	ret    

008003bd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c3:	83 f8 1f             	cmp    $0x1f,%eax
  8003c6:	77 36                	ja     8003fe <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003c8:	c1 e0 0c             	shl    $0xc,%eax
  8003cb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003d0:	89 c2                	mov    %eax,%edx
  8003d2:	c1 ea 16             	shr    $0x16,%edx
  8003d5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003dc:	f6 c2 01             	test   $0x1,%dl
  8003df:	74 24                	je     800405 <fd_lookup+0x48>
  8003e1:	89 c2                	mov    %eax,%edx
  8003e3:	c1 ea 0c             	shr    $0xc,%edx
  8003e6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003ed:	f6 c2 01             	test   $0x1,%dl
  8003f0:	74 1a                	je     80040c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f5:	89 02                	mov    %eax,(%edx)
	return 0;
  8003f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003fc:	5d                   	pop    %ebp
  8003fd:	c3                   	ret    
		return -E_INVAL;
  8003fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800403:	eb f7                	jmp    8003fc <fd_lookup+0x3f>
		return -E_INVAL;
  800405:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040a:	eb f0                	jmp    8003fc <fd_lookup+0x3f>
  80040c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800411:	eb e9                	jmp    8003fc <fd_lookup+0x3f>

00800413 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800413:	55                   	push   %ebp
  800414:	89 e5                	mov    %esp,%ebp
  800416:	83 ec 08             	sub    $0x8,%esp
  800419:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80041c:	ba 74 1e 80 00       	mov    $0x801e74,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800421:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800426:	39 08                	cmp    %ecx,(%eax)
  800428:	74 33                	je     80045d <dev_lookup+0x4a>
  80042a:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80042d:	8b 02                	mov    (%edx),%eax
  80042f:	85 c0                	test   %eax,%eax
  800431:	75 f3                	jne    800426 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800433:	a1 04 40 80 00       	mov    0x804004,%eax
  800438:	8b 40 48             	mov    0x48(%eax),%eax
  80043b:	83 ec 04             	sub    $0x4,%esp
  80043e:	51                   	push   %ecx
  80043f:	50                   	push   %eax
  800440:	68 f8 1d 80 00       	push   $0x801df8
  800445:	e8 93 0c 00 00       	call   8010dd <cprintf>
	*dev = 0;
  80044a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80044d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800453:	83 c4 10             	add    $0x10,%esp
  800456:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80045b:	c9                   	leave  
  80045c:	c3                   	ret    
			*dev = devtab[i];
  80045d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800460:	89 01                	mov    %eax,(%ecx)
			return 0;
  800462:	b8 00 00 00 00       	mov    $0x0,%eax
  800467:	eb f2                	jmp    80045b <dev_lookup+0x48>

00800469 <fd_close>:
{
  800469:	55                   	push   %ebp
  80046a:	89 e5                	mov    %esp,%ebp
  80046c:	57                   	push   %edi
  80046d:	56                   	push   %esi
  80046e:	53                   	push   %ebx
  80046f:	83 ec 1c             	sub    $0x1c,%esp
  800472:	8b 75 08             	mov    0x8(%ebp),%esi
  800475:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800478:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80047b:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80047c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800482:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800485:	50                   	push   %eax
  800486:	e8 32 ff ff ff       	call   8003bd <fd_lookup>
  80048b:	89 c3                	mov    %eax,%ebx
  80048d:	83 c4 08             	add    $0x8,%esp
  800490:	85 c0                	test   %eax,%eax
  800492:	78 05                	js     800499 <fd_close+0x30>
	    || fd != fd2)
  800494:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800497:	74 16                	je     8004af <fd_close+0x46>
		return (must_exist ? r : 0);
  800499:	89 f8                	mov    %edi,%eax
  80049b:	84 c0                	test   %al,%al
  80049d:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a2:	0f 44 d8             	cmove  %eax,%ebx
}
  8004a5:	89 d8                	mov    %ebx,%eax
  8004a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004aa:	5b                   	pop    %ebx
  8004ab:	5e                   	pop    %esi
  8004ac:	5f                   	pop    %edi
  8004ad:	5d                   	pop    %ebp
  8004ae:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8004b5:	50                   	push   %eax
  8004b6:	ff 36                	pushl  (%esi)
  8004b8:	e8 56 ff ff ff       	call   800413 <dev_lookup>
  8004bd:	89 c3                	mov    %eax,%ebx
  8004bf:	83 c4 10             	add    $0x10,%esp
  8004c2:	85 c0                	test   %eax,%eax
  8004c4:	78 15                	js     8004db <fd_close+0x72>
		if (dev->dev_close)
  8004c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004c9:	8b 40 10             	mov    0x10(%eax),%eax
  8004cc:	85 c0                	test   %eax,%eax
  8004ce:	74 1b                	je     8004eb <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8004d0:	83 ec 0c             	sub    $0xc,%esp
  8004d3:	56                   	push   %esi
  8004d4:	ff d0                	call   *%eax
  8004d6:	89 c3                	mov    %eax,%ebx
  8004d8:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004db:	83 ec 08             	sub    $0x8,%esp
  8004de:	56                   	push   %esi
  8004df:	6a 00                	push   $0x0
  8004e1:	e8 f5 fc ff ff       	call   8001db <sys_page_unmap>
	return r;
  8004e6:	83 c4 10             	add    $0x10,%esp
  8004e9:	eb ba                	jmp    8004a5 <fd_close+0x3c>
			r = 0;
  8004eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004f0:	eb e9                	jmp    8004db <fd_close+0x72>

008004f2 <close>:

int
close(int fdnum)
{
  8004f2:	55                   	push   %ebp
  8004f3:	89 e5                	mov    %esp,%ebp
  8004f5:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004fb:	50                   	push   %eax
  8004fc:	ff 75 08             	pushl  0x8(%ebp)
  8004ff:	e8 b9 fe ff ff       	call   8003bd <fd_lookup>
  800504:	83 c4 08             	add    $0x8,%esp
  800507:	85 c0                	test   %eax,%eax
  800509:	78 10                	js     80051b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80050b:	83 ec 08             	sub    $0x8,%esp
  80050e:	6a 01                	push   $0x1
  800510:	ff 75 f4             	pushl  -0xc(%ebp)
  800513:	e8 51 ff ff ff       	call   800469 <fd_close>
  800518:	83 c4 10             	add    $0x10,%esp
}
  80051b:	c9                   	leave  
  80051c:	c3                   	ret    

0080051d <close_all>:

void
close_all(void)
{
  80051d:	55                   	push   %ebp
  80051e:	89 e5                	mov    %esp,%ebp
  800520:	53                   	push   %ebx
  800521:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800524:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800529:	83 ec 0c             	sub    $0xc,%esp
  80052c:	53                   	push   %ebx
  80052d:	e8 c0 ff ff ff       	call   8004f2 <close>
	for (i = 0; i < MAXFD; i++)
  800532:	83 c3 01             	add    $0x1,%ebx
  800535:	83 c4 10             	add    $0x10,%esp
  800538:	83 fb 20             	cmp    $0x20,%ebx
  80053b:	75 ec                	jne    800529 <close_all+0xc>
}
  80053d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800540:	c9                   	leave  
  800541:	c3                   	ret    

00800542 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800542:	55                   	push   %ebp
  800543:	89 e5                	mov    %esp,%ebp
  800545:	57                   	push   %edi
  800546:	56                   	push   %esi
  800547:	53                   	push   %ebx
  800548:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80054b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80054e:	50                   	push   %eax
  80054f:	ff 75 08             	pushl  0x8(%ebp)
  800552:	e8 66 fe ff ff       	call   8003bd <fd_lookup>
  800557:	89 c3                	mov    %eax,%ebx
  800559:	83 c4 08             	add    $0x8,%esp
  80055c:	85 c0                	test   %eax,%eax
  80055e:	0f 88 81 00 00 00    	js     8005e5 <dup+0xa3>
		return r;
	close(newfdnum);
  800564:	83 ec 0c             	sub    $0xc,%esp
  800567:	ff 75 0c             	pushl  0xc(%ebp)
  80056a:	e8 83 ff ff ff       	call   8004f2 <close>

	newfd = INDEX2FD(newfdnum);
  80056f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800572:	c1 e6 0c             	shl    $0xc,%esi
  800575:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80057b:	83 c4 04             	add    $0x4,%esp
  80057e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800581:	e8 d1 fd ff ff       	call   800357 <fd2data>
  800586:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800588:	89 34 24             	mov    %esi,(%esp)
  80058b:	e8 c7 fd ff ff       	call   800357 <fd2data>
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800595:	89 d8                	mov    %ebx,%eax
  800597:	c1 e8 16             	shr    $0x16,%eax
  80059a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a1:	a8 01                	test   $0x1,%al
  8005a3:	74 11                	je     8005b6 <dup+0x74>
  8005a5:	89 d8                	mov    %ebx,%eax
  8005a7:	c1 e8 0c             	shr    $0xc,%eax
  8005aa:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b1:	f6 c2 01             	test   $0x1,%dl
  8005b4:	75 39                	jne    8005ef <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005b6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005b9:	89 d0                	mov    %edx,%eax
  8005bb:	c1 e8 0c             	shr    $0xc,%eax
  8005be:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c5:	83 ec 0c             	sub    $0xc,%esp
  8005c8:	25 07 0e 00 00       	and    $0xe07,%eax
  8005cd:	50                   	push   %eax
  8005ce:	56                   	push   %esi
  8005cf:	6a 00                	push   $0x0
  8005d1:	52                   	push   %edx
  8005d2:	6a 00                	push   $0x0
  8005d4:	e8 c0 fb ff ff       	call   800199 <sys_page_map>
  8005d9:	89 c3                	mov    %eax,%ebx
  8005db:	83 c4 20             	add    $0x20,%esp
  8005de:	85 c0                	test   %eax,%eax
  8005e0:	78 31                	js     800613 <dup+0xd1>
		goto err;

	return newfdnum;
  8005e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005e5:	89 d8                	mov    %ebx,%eax
  8005e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005ea:	5b                   	pop    %ebx
  8005eb:	5e                   	pop    %esi
  8005ec:	5f                   	pop    %edi
  8005ed:	5d                   	pop    %ebp
  8005ee:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ef:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005f6:	83 ec 0c             	sub    $0xc,%esp
  8005f9:	25 07 0e 00 00       	and    $0xe07,%eax
  8005fe:	50                   	push   %eax
  8005ff:	57                   	push   %edi
  800600:	6a 00                	push   $0x0
  800602:	53                   	push   %ebx
  800603:	6a 00                	push   $0x0
  800605:	e8 8f fb ff ff       	call   800199 <sys_page_map>
  80060a:	89 c3                	mov    %eax,%ebx
  80060c:	83 c4 20             	add    $0x20,%esp
  80060f:	85 c0                	test   %eax,%eax
  800611:	79 a3                	jns    8005b6 <dup+0x74>
	sys_page_unmap(0, newfd);
  800613:	83 ec 08             	sub    $0x8,%esp
  800616:	56                   	push   %esi
  800617:	6a 00                	push   $0x0
  800619:	e8 bd fb ff ff       	call   8001db <sys_page_unmap>
	sys_page_unmap(0, nva);
  80061e:	83 c4 08             	add    $0x8,%esp
  800621:	57                   	push   %edi
  800622:	6a 00                	push   $0x0
  800624:	e8 b2 fb ff ff       	call   8001db <sys_page_unmap>
	return r;
  800629:	83 c4 10             	add    $0x10,%esp
  80062c:	eb b7                	jmp    8005e5 <dup+0xa3>

0080062e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80062e:	55                   	push   %ebp
  80062f:	89 e5                	mov    %esp,%ebp
  800631:	53                   	push   %ebx
  800632:	83 ec 14             	sub    $0x14,%esp
  800635:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800638:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80063b:	50                   	push   %eax
  80063c:	53                   	push   %ebx
  80063d:	e8 7b fd ff ff       	call   8003bd <fd_lookup>
  800642:	83 c4 08             	add    $0x8,%esp
  800645:	85 c0                	test   %eax,%eax
  800647:	78 3f                	js     800688 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800649:	83 ec 08             	sub    $0x8,%esp
  80064c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80064f:	50                   	push   %eax
  800650:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800653:	ff 30                	pushl  (%eax)
  800655:	e8 b9 fd ff ff       	call   800413 <dev_lookup>
  80065a:	83 c4 10             	add    $0x10,%esp
  80065d:	85 c0                	test   %eax,%eax
  80065f:	78 27                	js     800688 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800661:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800664:	8b 42 08             	mov    0x8(%edx),%eax
  800667:	83 e0 03             	and    $0x3,%eax
  80066a:	83 f8 01             	cmp    $0x1,%eax
  80066d:	74 1e                	je     80068d <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80066f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800672:	8b 40 08             	mov    0x8(%eax),%eax
  800675:	85 c0                	test   %eax,%eax
  800677:	74 35                	je     8006ae <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800679:	83 ec 04             	sub    $0x4,%esp
  80067c:	ff 75 10             	pushl  0x10(%ebp)
  80067f:	ff 75 0c             	pushl  0xc(%ebp)
  800682:	52                   	push   %edx
  800683:	ff d0                	call   *%eax
  800685:	83 c4 10             	add    $0x10,%esp
}
  800688:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80068b:	c9                   	leave  
  80068c:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80068d:	a1 04 40 80 00       	mov    0x804004,%eax
  800692:	8b 40 48             	mov    0x48(%eax),%eax
  800695:	83 ec 04             	sub    $0x4,%esp
  800698:	53                   	push   %ebx
  800699:	50                   	push   %eax
  80069a:	68 39 1e 80 00       	push   $0x801e39
  80069f:	e8 39 0a 00 00       	call   8010dd <cprintf>
		return -E_INVAL;
  8006a4:	83 c4 10             	add    $0x10,%esp
  8006a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006ac:	eb da                	jmp    800688 <read+0x5a>
		return -E_NOT_SUPP;
  8006ae:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006b3:	eb d3                	jmp    800688 <read+0x5a>

008006b5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006b5:	55                   	push   %ebp
  8006b6:	89 e5                	mov    %esp,%ebp
  8006b8:	57                   	push   %edi
  8006b9:	56                   	push   %esi
  8006ba:	53                   	push   %ebx
  8006bb:	83 ec 0c             	sub    $0xc,%esp
  8006be:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006c9:	39 f3                	cmp    %esi,%ebx
  8006cb:	73 25                	jae    8006f2 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006cd:	83 ec 04             	sub    $0x4,%esp
  8006d0:	89 f0                	mov    %esi,%eax
  8006d2:	29 d8                	sub    %ebx,%eax
  8006d4:	50                   	push   %eax
  8006d5:	89 d8                	mov    %ebx,%eax
  8006d7:	03 45 0c             	add    0xc(%ebp),%eax
  8006da:	50                   	push   %eax
  8006db:	57                   	push   %edi
  8006dc:	e8 4d ff ff ff       	call   80062e <read>
		if (m < 0)
  8006e1:	83 c4 10             	add    $0x10,%esp
  8006e4:	85 c0                	test   %eax,%eax
  8006e6:	78 08                	js     8006f0 <readn+0x3b>
			return m;
		if (m == 0)
  8006e8:	85 c0                	test   %eax,%eax
  8006ea:	74 06                	je     8006f2 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  8006ec:	01 c3                	add    %eax,%ebx
  8006ee:	eb d9                	jmp    8006c9 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f0:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006f2:	89 d8                	mov    %ebx,%eax
  8006f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f7:	5b                   	pop    %ebx
  8006f8:	5e                   	pop    %esi
  8006f9:	5f                   	pop    %edi
  8006fa:	5d                   	pop    %ebp
  8006fb:	c3                   	ret    

008006fc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
  8006ff:	53                   	push   %ebx
  800700:	83 ec 14             	sub    $0x14,%esp
  800703:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800706:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800709:	50                   	push   %eax
  80070a:	53                   	push   %ebx
  80070b:	e8 ad fc ff ff       	call   8003bd <fd_lookup>
  800710:	83 c4 08             	add    $0x8,%esp
  800713:	85 c0                	test   %eax,%eax
  800715:	78 3a                	js     800751 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800717:	83 ec 08             	sub    $0x8,%esp
  80071a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80071d:	50                   	push   %eax
  80071e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800721:	ff 30                	pushl  (%eax)
  800723:	e8 eb fc ff ff       	call   800413 <dev_lookup>
  800728:	83 c4 10             	add    $0x10,%esp
  80072b:	85 c0                	test   %eax,%eax
  80072d:	78 22                	js     800751 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80072f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800732:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800736:	74 1e                	je     800756 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800738:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80073b:	8b 52 0c             	mov    0xc(%edx),%edx
  80073e:	85 d2                	test   %edx,%edx
  800740:	74 35                	je     800777 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800742:	83 ec 04             	sub    $0x4,%esp
  800745:	ff 75 10             	pushl  0x10(%ebp)
  800748:	ff 75 0c             	pushl  0xc(%ebp)
  80074b:	50                   	push   %eax
  80074c:	ff d2                	call   *%edx
  80074e:	83 c4 10             	add    $0x10,%esp
}
  800751:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800754:	c9                   	leave  
  800755:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800756:	a1 04 40 80 00       	mov    0x804004,%eax
  80075b:	8b 40 48             	mov    0x48(%eax),%eax
  80075e:	83 ec 04             	sub    $0x4,%esp
  800761:	53                   	push   %ebx
  800762:	50                   	push   %eax
  800763:	68 55 1e 80 00       	push   $0x801e55
  800768:	e8 70 09 00 00       	call   8010dd <cprintf>
		return -E_INVAL;
  80076d:	83 c4 10             	add    $0x10,%esp
  800770:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800775:	eb da                	jmp    800751 <write+0x55>
		return -E_NOT_SUPP;
  800777:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80077c:	eb d3                	jmp    800751 <write+0x55>

0080077e <seek>:

int
seek(int fdnum, off_t offset)
{
  80077e:	55                   	push   %ebp
  80077f:	89 e5                	mov    %esp,%ebp
  800781:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800784:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800787:	50                   	push   %eax
  800788:	ff 75 08             	pushl  0x8(%ebp)
  80078b:	e8 2d fc ff ff       	call   8003bd <fd_lookup>
  800790:	83 c4 08             	add    $0x8,%esp
  800793:	85 c0                	test   %eax,%eax
  800795:	78 0e                	js     8007a5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800797:	8b 55 0c             	mov    0xc(%ebp),%edx
  80079a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80079d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007a5:	c9                   	leave  
  8007a6:	c3                   	ret    

008007a7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	53                   	push   %ebx
  8007ab:	83 ec 14             	sub    $0x14,%esp
  8007ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007b4:	50                   	push   %eax
  8007b5:	53                   	push   %ebx
  8007b6:	e8 02 fc ff ff       	call   8003bd <fd_lookup>
  8007bb:	83 c4 08             	add    $0x8,%esp
  8007be:	85 c0                	test   %eax,%eax
  8007c0:	78 37                	js     8007f9 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007c2:	83 ec 08             	sub    $0x8,%esp
  8007c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007c8:	50                   	push   %eax
  8007c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007cc:	ff 30                	pushl  (%eax)
  8007ce:	e8 40 fc ff ff       	call   800413 <dev_lookup>
  8007d3:	83 c4 10             	add    $0x10,%esp
  8007d6:	85 c0                	test   %eax,%eax
  8007d8:	78 1f                	js     8007f9 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007dd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007e1:	74 1b                	je     8007fe <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007e6:	8b 52 18             	mov    0x18(%edx),%edx
  8007e9:	85 d2                	test   %edx,%edx
  8007eb:	74 32                	je     80081f <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007ed:	83 ec 08             	sub    $0x8,%esp
  8007f0:	ff 75 0c             	pushl  0xc(%ebp)
  8007f3:	50                   	push   %eax
  8007f4:	ff d2                	call   *%edx
  8007f6:	83 c4 10             	add    $0x10,%esp
}
  8007f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007fc:	c9                   	leave  
  8007fd:	c3                   	ret    
			thisenv->env_id, fdnum);
  8007fe:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800803:	8b 40 48             	mov    0x48(%eax),%eax
  800806:	83 ec 04             	sub    $0x4,%esp
  800809:	53                   	push   %ebx
  80080a:	50                   	push   %eax
  80080b:	68 18 1e 80 00       	push   $0x801e18
  800810:	e8 c8 08 00 00       	call   8010dd <cprintf>
		return -E_INVAL;
  800815:	83 c4 10             	add    $0x10,%esp
  800818:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80081d:	eb da                	jmp    8007f9 <ftruncate+0x52>
		return -E_NOT_SUPP;
  80081f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800824:	eb d3                	jmp    8007f9 <ftruncate+0x52>

00800826 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800826:	55                   	push   %ebp
  800827:	89 e5                	mov    %esp,%ebp
  800829:	53                   	push   %ebx
  80082a:	83 ec 14             	sub    $0x14,%esp
  80082d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800830:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800833:	50                   	push   %eax
  800834:	ff 75 08             	pushl  0x8(%ebp)
  800837:	e8 81 fb ff ff       	call   8003bd <fd_lookup>
  80083c:	83 c4 08             	add    $0x8,%esp
  80083f:	85 c0                	test   %eax,%eax
  800841:	78 4b                	js     80088e <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800843:	83 ec 08             	sub    $0x8,%esp
  800846:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800849:	50                   	push   %eax
  80084a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80084d:	ff 30                	pushl  (%eax)
  80084f:	e8 bf fb ff ff       	call   800413 <dev_lookup>
  800854:	83 c4 10             	add    $0x10,%esp
  800857:	85 c0                	test   %eax,%eax
  800859:	78 33                	js     80088e <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  80085b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80085e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800862:	74 2f                	je     800893 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800864:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800867:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80086e:	00 00 00 
	stat->st_isdir = 0;
  800871:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800878:	00 00 00 
	stat->st_dev = dev;
  80087b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800881:	83 ec 08             	sub    $0x8,%esp
  800884:	53                   	push   %ebx
  800885:	ff 75 f0             	pushl  -0x10(%ebp)
  800888:	ff 50 14             	call   *0x14(%eax)
  80088b:	83 c4 10             	add    $0x10,%esp
}
  80088e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800891:	c9                   	leave  
  800892:	c3                   	ret    
		return -E_NOT_SUPP;
  800893:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800898:	eb f4                	jmp    80088e <fstat+0x68>

0080089a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	56                   	push   %esi
  80089e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80089f:	83 ec 08             	sub    $0x8,%esp
  8008a2:	6a 00                	push   $0x0
  8008a4:	ff 75 08             	pushl  0x8(%ebp)
  8008a7:	e8 e7 01 00 00       	call   800a93 <open>
  8008ac:	89 c3                	mov    %eax,%ebx
  8008ae:	83 c4 10             	add    $0x10,%esp
  8008b1:	85 c0                	test   %eax,%eax
  8008b3:	78 1b                	js     8008d0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008b5:	83 ec 08             	sub    $0x8,%esp
  8008b8:	ff 75 0c             	pushl  0xc(%ebp)
  8008bb:	50                   	push   %eax
  8008bc:	e8 65 ff ff ff       	call   800826 <fstat>
  8008c1:	89 c6                	mov    %eax,%esi
	close(fd);
  8008c3:	89 1c 24             	mov    %ebx,(%esp)
  8008c6:	e8 27 fc ff ff       	call   8004f2 <close>
	return r;
  8008cb:	83 c4 10             	add    $0x10,%esp
  8008ce:	89 f3                	mov    %esi,%ebx
}
  8008d0:	89 d8                	mov    %ebx,%eax
  8008d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008d5:	5b                   	pop    %ebx
  8008d6:	5e                   	pop    %esi
  8008d7:	5d                   	pop    %ebp
  8008d8:	c3                   	ret    

008008d9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008d9:	55                   	push   %ebp
  8008da:	89 e5                	mov    %esp,%ebp
  8008dc:	56                   	push   %esi
  8008dd:	53                   	push   %ebx
  8008de:	89 c6                	mov    %eax,%esi
  8008e0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008e2:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008e9:	74 27                	je     800912 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008eb:	6a 07                	push   $0x7
  8008ed:	68 00 50 80 00       	push   $0x805000
  8008f2:	56                   	push   %esi
  8008f3:	ff 35 00 40 80 00    	pushl  0x804000
  8008f9:	e8 b0 11 00 00       	call   801aae <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8008fe:	83 c4 0c             	add    $0xc,%esp
  800901:	6a 00                	push   $0x0
  800903:	53                   	push   %ebx
  800904:	6a 00                	push   $0x0
  800906:	e8 2e 11 00 00       	call   801a39 <ipc_recv>
}
  80090b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80090e:	5b                   	pop    %ebx
  80090f:	5e                   	pop    %esi
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800912:	83 ec 0c             	sub    $0xc,%esp
  800915:	6a 01                	push   $0x1
  800917:	e8 e8 11 00 00       	call   801b04 <ipc_find_env>
  80091c:	a3 00 40 80 00       	mov    %eax,0x804000
  800921:	83 c4 10             	add    $0x10,%esp
  800924:	eb c5                	jmp    8008eb <fsipc+0x12>

00800926 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80092c:	8b 45 08             	mov    0x8(%ebp),%eax
  80092f:	8b 40 0c             	mov    0xc(%eax),%eax
  800932:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800937:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80093f:	ba 00 00 00 00       	mov    $0x0,%edx
  800944:	b8 02 00 00 00       	mov    $0x2,%eax
  800949:	e8 8b ff ff ff       	call   8008d9 <fsipc>
}
  80094e:	c9                   	leave  
  80094f:	c3                   	ret    

00800950 <devfile_flush>:
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800956:	8b 45 08             	mov    0x8(%ebp),%eax
  800959:	8b 40 0c             	mov    0xc(%eax),%eax
  80095c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800961:	ba 00 00 00 00       	mov    $0x0,%edx
  800966:	b8 06 00 00 00       	mov    $0x6,%eax
  80096b:	e8 69 ff ff ff       	call   8008d9 <fsipc>
}
  800970:	c9                   	leave  
  800971:	c3                   	ret    

00800972 <devfile_stat>:
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	53                   	push   %ebx
  800976:	83 ec 04             	sub    $0x4,%esp
  800979:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80097c:	8b 45 08             	mov    0x8(%ebp),%eax
  80097f:	8b 40 0c             	mov    0xc(%eax),%eax
  800982:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800987:	ba 00 00 00 00       	mov    $0x0,%edx
  80098c:	b8 05 00 00 00       	mov    $0x5,%eax
  800991:	e8 43 ff ff ff       	call   8008d9 <fsipc>
  800996:	85 c0                	test   %eax,%eax
  800998:	78 2c                	js     8009c6 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80099a:	83 ec 08             	sub    $0x8,%esp
  80099d:	68 00 50 80 00       	push   $0x805000
  8009a2:	53                   	push   %ebx
  8009a3:	e8 54 0d 00 00       	call   8016fc <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009a8:	a1 80 50 80 00       	mov    0x805080,%eax
  8009ad:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009b3:	a1 84 50 80 00       	mov    0x805084,%eax
  8009b8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009be:	83 c4 10             	add    $0x10,%esp
  8009c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009c9:	c9                   	leave  
  8009ca:	c3                   	ret    

008009cb <devfile_write>:
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	83 ec 0c             	sub    $0xc,%esp
  8009d1:	8b 45 10             	mov    0x10(%ebp),%eax
  8009d4:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009d9:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8009de:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8009e4:	8b 52 0c             	mov    0xc(%edx),%edx
  8009e7:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8009ed:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf,buf,n);
  8009f2:	50                   	push   %eax
  8009f3:	ff 75 0c             	pushl  0xc(%ebp)
  8009f6:	68 08 50 80 00       	push   $0x805008
  8009fb:	e8 8a 0e 00 00       	call   80188a <memmove>
	if((r = fsipc(FSREQ_WRITE,NULL))<0)
  800a00:	ba 00 00 00 00       	mov    $0x0,%edx
  800a05:	b8 04 00 00 00       	mov    $0x4,%eax
  800a0a:	e8 ca fe ff ff       	call   8008d9 <fsipc>
}
  800a0f:	c9                   	leave  
  800a10:	c3                   	ret    

00800a11 <devfile_read>:
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	56                   	push   %esi
  800a15:	53                   	push   %ebx
  800a16:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a19:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1c:	8b 40 0c             	mov    0xc(%eax),%eax
  800a1f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a24:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2f:	b8 03 00 00 00       	mov    $0x3,%eax
  800a34:	e8 a0 fe ff ff       	call   8008d9 <fsipc>
  800a39:	89 c3                	mov    %eax,%ebx
  800a3b:	85 c0                	test   %eax,%eax
  800a3d:	78 1f                	js     800a5e <devfile_read+0x4d>
	assert(r <= n);
  800a3f:	39 f0                	cmp    %esi,%eax
  800a41:	77 24                	ja     800a67 <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a43:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a48:	7f 33                	jg     800a7d <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a4a:	83 ec 04             	sub    $0x4,%esp
  800a4d:	50                   	push   %eax
  800a4e:	68 00 50 80 00       	push   $0x805000
  800a53:	ff 75 0c             	pushl  0xc(%ebp)
  800a56:	e8 2f 0e 00 00       	call   80188a <memmove>
	return r;
  800a5b:	83 c4 10             	add    $0x10,%esp
}
  800a5e:	89 d8                	mov    %ebx,%eax
  800a60:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a63:	5b                   	pop    %ebx
  800a64:	5e                   	pop    %esi
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    
	assert(r <= n);
  800a67:	68 84 1e 80 00       	push   $0x801e84
  800a6c:	68 8b 1e 80 00       	push   $0x801e8b
  800a71:	6a 7c                	push   $0x7c
  800a73:	68 a0 1e 80 00       	push   $0x801ea0
  800a78:	e8 85 05 00 00       	call   801002 <_panic>
	assert(r <= PGSIZE);
  800a7d:	68 ab 1e 80 00       	push   $0x801eab
  800a82:	68 8b 1e 80 00       	push   $0x801e8b
  800a87:	6a 7d                	push   $0x7d
  800a89:	68 a0 1e 80 00       	push   $0x801ea0
  800a8e:	e8 6f 05 00 00       	call   801002 <_panic>

00800a93 <open>:
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	56                   	push   %esi
  800a97:	53                   	push   %ebx
  800a98:	83 ec 1c             	sub    $0x1c,%esp
  800a9b:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800a9e:	56                   	push   %esi
  800a9f:	e8 21 0c 00 00       	call   8016c5 <strlen>
  800aa4:	83 c4 10             	add    $0x10,%esp
  800aa7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800aac:	7f 6c                	jg     800b1a <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800aae:	83 ec 0c             	sub    $0xc,%esp
  800ab1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ab4:	50                   	push   %eax
  800ab5:	e8 b4 f8 ff ff       	call   80036e <fd_alloc>
  800aba:	89 c3                	mov    %eax,%ebx
  800abc:	83 c4 10             	add    $0x10,%esp
  800abf:	85 c0                	test   %eax,%eax
  800ac1:	78 3c                	js     800aff <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800ac3:	83 ec 08             	sub    $0x8,%esp
  800ac6:	56                   	push   %esi
  800ac7:	68 00 50 80 00       	push   $0x805000
  800acc:	e8 2b 0c 00 00       	call   8016fc <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ad1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad4:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ad9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800adc:	b8 01 00 00 00       	mov    $0x1,%eax
  800ae1:	e8 f3 fd ff ff       	call   8008d9 <fsipc>
  800ae6:	89 c3                	mov    %eax,%ebx
  800ae8:	83 c4 10             	add    $0x10,%esp
  800aeb:	85 c0                	test   %eax,%eax
  800aed:	78 19                	js     800b08 <open+0x75>
	return fd2num(fd);
  800aef:	83 ec 0c             	sub    $0xc,%esp
  800af2:	ff 75 f4             	pushl  -0xc(%ebp)
  800af5:	e8 4d f8 ff ff       	call   800347 <fd2num>
  800afa:	89 c3                	mov    %eax,%ebx
  800afc:	83 c4 10             	add    $0x10,%esp
}
  800aff:	89 d8                	mov    %ebx,%eax
  800b01:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b04:	5b                   	pop    %ebx
  800b05:	5e                   	pop    %esi
  800b06:	5d                   	pop    %ebp
  800b07:	c3                   	ret    
		fd_close(fd, 0);
  800b08:	83 ec 08             	sub    $0x8,%esp
  800b0b:	6a 00                	push   $0x0
  800b0d:	ff 75 f4             	pushl  -0xc(%ebp)
  800b10:	e8 54 f9 ff ff       	call   800469 <fd_close>
		return r;
  800b15:	83 c4 10             	add    $0x10,%esp
  800b18:	eb e5                	jmp    800aff <open+0x6c>
		return -E_BAD_PATH;
  800b1a:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b1f:	eb de                	jmp    800aff <open+0x6c>

00800b21 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b27:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2c:	b8 08 00 00 00       	mov    $0x8,%eax
  800b31:	e8 a3 fd ff ff       	call   8008d9 <fsipc>
}
  800b36:	c9                   	leave  
  800b37:	c3                   	ret    

00800b38 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	56                   	push   %esi
  800b3c:	53                   	push   %ebx
  800b3d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b40:	83 ec 0c             	sub    $0xc,%esp
  800b43:	ff 75 08             	pushl  0x8(%ebp)
  800b46:	e8 0c f8 ff ff       	call   800357 <fd2data>
  800b4b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b4d:	83 c4 08             	add    $0x8,%esp
  800b50:	68 b7 1e 80 00       	push   $0x801eb7
  800b55:	53                   	push   %ebx
  800b56:	e8 a1 0b 00 00       	call   8016fc <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b5b:	8b 46 04             	mov    0x4(%esi),%eax
  800b5e:	2b 06                	sub    (%esi),%eax
  800b60:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b66:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b6d:	00 00 00 
	stat->st_dev = &devpipe;
  800b70:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b77:	30 80 00 
	return 0;
}
  800b7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b82:	5b                   	pop    %ebx
  800b83:	5e                   	pop    %esi
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    

00800b86 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	53                   	push   %ebx
  800b8a:	83 ec 0c             	sub    $0xc,%esp
  800b8d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b90:	53                   	push   %ebx
  800b91:	6a 00                	push   $0x0
  800b93:	e8 43 f6 ff ff       	call   8001db <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b98:	89 1c 24             	mov    %ebx,(%esp)
  800b9b:	e8 b7 f7 ff ff       	call   800357 <fd2data>
  800ba0:	83 c4 08             	add    $0x8,%esp
  800ba3:	50                   	push   %eax
  800ba4:	6a 00                	push   $0x0
  800ba6:	e8 30 f6 ff ff       	call   8001db <sys_page_unmap>
}
  800bab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bae:	c9                   	leave  
  800baf:	c3                   	ret    

00800bb0 <_pipeisclosed>:
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	57                   	push   %edi
  800bb4:	56                   	push   %esi
  800bb5:	53                   	push   %ebx
  800bb6:	83 ec 1c             	sub    $0x1c,%esp
  800bb9:	89 c7                	mov    %eax,%edi
  800bbb:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800bbd:	a1 04 40 80 00       	mov    0x804004,%eax
  800bc2:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800bc5:	83 ec 0c             	sub    $0xc,%esp
  800bc8:	57                   	push   %edi
  800bc9:	e8 6f 0f 00 00       	call   801b3d <pageref>
  800bce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800bd1:	89 34 24             	mov    %esi,(%esp)
  800bd4:	e8 64 0f 00 00       	call   801b3d <pageref>
		nn = thisenv->env_runs;
  800bd9:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bdf:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800be2:	83 c4 10             	add    $0x10,%esp
  800be5:	39 cb                	cmp    %ecx,%ebx
  800be7:	74 1b                	je     800c04 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800be9:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800bec:	75 cf                	jne    800bbd <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800bee:	8b 42 58             	mov    0x58(%edx),%eax
  800bf1:	6a 01                	push   $0x1
  800bf3:	50                   	push   %eax
  800bf4:	53                   	push   %ebx
  800bf5:	68 be 1e 80 00       	push   $0x801ebe
  800bfa:	e8 de 04 00 00       	call   8010dd <cprintf>
  800bff:	83 c4 10             	add    $0x10,%esp
  800c02:	eb b9                	jmp    800bbd <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c04:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c07:	0f 94 c0             	sete   %al
  800c0a:	0f b6 c0             	movzbl %al,%eax
}
  800c0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5f                   	pop    %edi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    

00800c15 <devpipe_write>:
{
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	57                   	push   %edi
  800c19:	56                   	push   %esi
  800c1a:	53                   	push   %ebx
  800c1b:	83 ec 28             	sub    $0x28,%esp
  800c1e:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c21:	56                   	push   %esi
  800c22:	e8 30 f7 ff ff       	call   800357 <fd2data>
  800c27:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c29:	83 c4 10             	add    $0x10,%esp
  800c2c:	bf 00 00 00 00       	mov    $0x0,%edi
  800c31:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c34:	74 4f                	je     800c85 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c36:	8b 43 04             	mov    0x4(%ebx),%eax
  800c39:	8b 0b                	mov    (%ebx),%ecx
  800c3b:	8d 51 20             	lea    0x20(%ecx),%edx
  800c3e:	39 d0                	cmp    %edx,%eax
  800c40:	72 14                	jb     800c56 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  800c42:	89 da                	mov    %ebx,%edx
  800c44:	89 f0                	mov    %esi,%eax
  800c46:	e8 65 ff ff ff       	call   800bb0 <_pipeisclosed>
  800c4b:	85 c0                	test   %eax,%eax
  800c4d:	75 3a                	jne    800c89 <devpipe_write+0x74>
			sys_yield();
  800c4f:	e8 e3 f4 ff ff       	call   800137 <sys_yield>
  800c54:	eb e0                	jmp    800c36 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c59:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c5d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c60:	89 c2                	mov    %eax,%edx
  800c62:	c1 fa 1f             	sar    $0x1f,%edx
  800c65:	89 d1                	mov    %edx,%ecx
  800c67:	c1 e9 1b             	shr    $0x1b,%ecx
  800c6a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c6d:	83 e2 1f             	and    $0x1f,%edx
  800c70:	29 ca                	sub    %ecx,%edx
  800c72:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c76:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c7a:	83 c0 01             	add    $0x1,%eax
  800c7d:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800c80:	83 c7 01             	add    $0x1,%edi
  800c83:	eb ac                	jmp    800c31 <devpipe_write+0x1c>
	return i;
  800c85:	89 f8                	mov    %edi,%eax
  800c87:	eb 05                	jmp    800c8e <devpipe_write+0x79>
				return 0;
  800c89:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c91:	5b                   	pop    %ebx
  800c92:	5e                   	pop    %esi
  800c93:	5f                   	pop    %edi
  800c94:	5d                   	pop    %ebp
  800c95:	c3                   	ret    

00800c96 <devpipe_read>:
{
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	57                   	push   %edi
  800c9a:	56                   	push   %esi
  800c9b:	53                   	push   %ebx
  800c9c:	83 ec 18             	sub    $0x18,%esp
  800c9f:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800ca2:	57                   	push   %edi
  800ca3:	e8 af f6 ff ff       	call   800357 <fd2data>
  800ca8:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800caa:	83 c4 10             	add    $0x10,%esp
  800cad:	be 00 00 00 00       	mov    $0x0,%esi
  800cb2:	3b 75 10             	cmp    0x10(%ebp),%esi
  800cb5:	74 47                	je     800cfe <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  800cb7:	8b 03                	mov    (%ebx),%eax
  800cb9:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cbc:	75 22                	jne    800ce0 <devpipe_read+0x4a>
			if (i > 0)
  800cbe:	85 f6                	test   %esi,%esi
  800cc0:	75 14                	jne    800cd6 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  800cc2:	89 da                	mov    %ebx,%edx
  800cc4:	89 f8                	mov    %edi,%eax
  800cc6:	e8 e5 fe ff ff       	call   800bb0 <_pipeisclosed>
  800ccb:	85 c0                	test   %eax,%eax
  800ccd:	75 33                	jne    800d02 <devpipe_read+0x6c>
			sys_yield();
  800ccf:	e8 63 f4 ff ff       	call   800137 <sys_yield>
  800cd4:	eb e1                	jmp    800cb7 <devpipe_read+0x21>
				return i;
  800cd6:	89 f0                	mov    %esi,%eax
}
  800cd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5f                   	pop    %edi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800ce0:	99                   	cltd   
  800ce1:	c1 ea 1b             	shr    $0x1b,%edx
  800ce4:	01 d0                	add    %edx,%eax
  800ce6:	83 e0 1f             	and    $0x1f,%eax
  800ce9:	29 d0                	sub    %edx,%eax
  800ceb:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800cf0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf3:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800cf6:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800cf9:	83 c6 01             	add    $0x1,%esi
  800cfc:	eb b4                	jmp    800cb2 <devpipe_read+0x1c>
	return i;
  800cfe:	89 f0                	mov    %esi,%eax
  800d00:	eb d6                	jmp    800cd8 <devpipe_read+0x42>
				return 0;
  800d02:	b8 00 00 00 00       	mov    $0x0,%eax
  800d07:	eb cf                	jmp    800cd8 <devpipe_read+0x42>

00800d09 <pipe>:
{
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	56                   	push   %esi
  800d0d:	53                   	push   %ebx
  800d0e:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d11:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d14:	50                   	push   %eax
  800d15:	e8 54 f6 ff ff       	call   80036e <fd_alloc>
  800d1a:	89 c3                	mov    %eax,%ebx
  800d1c:	83 c4 10             	add    $0x10,%esp
  800d1f:	85 c0                	test   %eax,%eax
  800d21:	78 5b                	js     800d7e <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d23:	83 ec 04             	sub    $0x4,%esp
  800d26:	68 07 04 00 00       	push   $0x407
  800d2b:	ff 75 f4             	pushl  -0xc(%ebp)
  800d2e:	6a 00                	push   $0x0
  800d30:	e8 21 f4 ff ff       	call   800156 <sys_page_alloc>
  800d35:	89 c3                	mov    %eax,%ebx
  800d37:	83 c4 10             	add    $0x10,%esp
  800d3a:	85 c0                	test   %eax,%eax
  800d3c:	78 40                	js     800d7e <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  800d3e:	83 ec 0c             	sub    $0xc,%esp
  800d41:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d44:	50                   	push   %eax
  800d45:	e8 24 f6 ff ff       	call   80036e <fd_alloc>
  800d4a:	89 c3                	mov    %eax,%ebx
  800d4c:	83 c4 10             	add    $0x10,%esp
  800d4f:	85 c0                	test   %eax,%eax
  800d51:	78 1b                	js     800d6e <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d53:	83 ec 04             	sub    $0x4,%esp
  800d56:	68 07 04 00 00       	push   $0x407
  800d5b:	ff 75 f0             	pushl  -0x10(%ebp)
  800d5e:	6a 00                	push   $0x0
  800d60:	e8 f1 f3 ff ff       	call   800156 <sys_page_alloc>
  800d65:	89 c3                	mov    %eax,%ebx
  800d67:	83 c4 10             	add    $0x10,%esp
  800d6a:	85 c0                	test   %eax,%eax
  800d6c:	79 19                	jns    800d87 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  800d6e:	83 ec 08             	sub    $0x8,%esp
  800d71:	ff 75 f4             	pushl  -0xc(%ebp)
  800d74:	6a 00                	push   $0x0
  800d76:	e8 60 f4 ff ff       	call   8001db <sys_page_unmap>
  800d7b:	83 c4 10             	add    $0x10,%esp
}
  800d7e:	89 d8                	mov    %ebx,%eax
  800d80:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d83:	5b                   	pop    %ebx
  800d84:	5e                   	pop    %esi
  800d85:	5d                   	pop    %ebp
  800d86:	c3                   	ret    
	va = fd2data(fd0);
  800d87:	83 ec 0c             	sub    $0xc,%esp
  800d8a:	ff 75 f4             	pushl  -0xc(%ebp)
  800d8d:	e8 c5 f5 ff ff       	call   800357 <fd2data>
  800d92:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d94:	83 c4 0c             	add    $0xc,%esp
  800d97:	68 07 04 00 00       	push   $0x407
  800d9c:	50                   	push   %eax
  800d9d:	6a 00                	push   $0x0
  800d9f:	e8 b2 f3 ff ff       	call   800156 <sys_page_alloc>
  800da4:	89 c3                	mov    %eax,%ebx
  800da6:	83 c4 10             	add    $0x10,%esp
  800da9:	85 c0                	test   %eax,%eax
  800dab:	0f 88 8c 00 00 00    	js     800e3d <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800db1:	83 ec 0c             	sub    $0xc,%esp
  800db4:	ff 75 f0             	pushl  -0x10(%ebp)
  800db7:	e8 9b f5 ff ff       	call   800357 <fd2data>
  800dbc:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dc3:	50                   	push   %eax
  800dc4:	6a 00                	push   $0x0
  800dc6:	56                   	push   %esi
  800dc7:	6a 00                	push   $0x0
  800dc9:	e8 cb f3 ff ff       	call   800199 <sys_page_map>
  800dce:	89 c3                	mov    %eax,%ebx
  800dd0:	83 c4 20             	add    $0x20,%esp
  800dd3:	85 c0                	test   %eax,%eax
  800dd5:	78 58                	js     800e2f <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  800dd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dda:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800de0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800de2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800de5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  800dec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800def:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800df5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800df7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dfa:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e01:	83 ec 0c             	sub    $0xc,%esp
  800e04:	ff 75 f4             	pushl  -0xc(%ebp)
  800e07:	e8 3b f5 ff ff       	call   800347 <fd2num>
  800e0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e0f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e11:	83 c4 04             	add    $0x4,%esp
  800e14:	ff 75 f0             	pushl  -0x10(%ebp)
  800e17:	e8 2b f5 ff ff       	call   800347 <fd2num>
  800e1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e1f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e22:	83 c4 10             	add    $0x10,%esp
  800e25:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e2a:	e9 4f ff ff ff       	jmp    800d7e <pipe+0x75>
	sys_page_unmap(0, va);
  800e2f:	83 ec 08             	sub    $0x8,%esp
  800e32:	56                   	push   %esi
  800e33:	6a 00                	push   $0x0
  800e35:	e8 a1 f3 ff ff       	call   8001db <sys_page_unmap>
  800e3a:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e3d:	83 ec 08             	sub    $0x8,%esp
  800e40:	ff 75 f0             	pushl  -0x10(%ebp)
  800e43:	6a 00                	push   $0x0
  800e45:	e8 91 f3 ff ff       	call   8001db <sys_page_unmap>
  800e4a:	83 c4 10             	add    $0x10,%esp
  800e4d:	e9 1c ff ff ff       	jmp    800d6e <pipe+0x65>

00800e52 <pipeisclosed>:
{
  800e52:	55                   	push   %ebp
  800e53:	89 e5                	mov    %esp,%ebp
  800e55:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e58:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e5b:	50                   	push   %eax
  800e5c:	ff 75 08             	pushl  0x8(%ebp)
  800e5f:	e8 59 f5 ff ff       	call   8003bd <fd_lookup>
  800e64:	83 c4 10             	add    $0x10,%esp
  800e67:	85 c0                	test   %eax,%eax
  800e69:	78 18                	js     800e83 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  800e6b:	83 ec 0c             	sub    $0xc,%esp
  800e6e:	ff 75 f4             	pushl  -0xc(%ebp)
  800e71:	e8 e1 f4 ff ff       	call   800357 <fd2data>
	return _pipeisclosed(fd, p);
  800e76:	89 c2                	mov    %eax,%edx
  800e78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e7b:	e8 30 fd ff ff       	call   800bb0 <_pipeisclosed>
  800e80:	83 c4 10             	add    $0x10,%esp
}
  800e83:	c9                   	leave  
  800e84:	c3                   	ret    

00800e85 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e88:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8d:	5d                   	pop    %ebp
  800e8e:	c3                   	ret    

00800e8f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e8f:	55                   	push   %ebp
  800e90:	89 e5                	mov    %esp,%ebp
  800e92:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e95:	68 d6 1e 80 00       	push   $0x801ed6
  800e9a:	ff 75 0c             	pushl  0xc(%ebp)
  800e9d:	e8 5a 08 00 00       	call   8016fc <strcpy>
	return 0;
}
  800ea2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea7:	c9                   	leave  
  800ea8:	c3                   	ret    

00800ea9 <devcons_write>:
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	57                   	push   %edi
  800ead:	56                   	push   %esi
  800eae:	53                   	push   %ebx
  800eaf:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800eb5:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800eba:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800ec0:	eb 2f                	jmp    800ef1 <devcons_write+0x48>
		m = n - tot;
  800ec2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec5:	29 f3                	sub    %esi,%ebx
  800ec7:	83 fb 7f             	cmp    $0x7f,%ebx
  800eca:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800ecf:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800ed2:	83 ec 04             	sub    $0x4,%esp
  800ed5:	53                   	push   %ebx
  800ed6:	89 f0                	mov    %esi,%eax
  800ed8:	03 45 0c             	add    0xc(%ebp),%eax
  800edb:	50                   	push   %eax
  800edc:	57                   	push   %edi
  800edd:	e8 a8 09 00 00       	call   80188a <memmove>
		sys_cputs(buf, m);
  800ee2:	83 c4 08             	add    $0x8,%esp
  800ee5:	53                   	push   %ebx
  800ee6:	57                   	push   %edi
  800ee7:	e8 ae f1 ff ff       	call   80009a <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800eec:	01 de                	add    %ebx,%esi
  800eee:	83 c4 10             	add    $0x10,%esp
  800ef1:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ef4:	72 cc                	jb     800ec2 <devcons_write+0x19>
}
  800ef6:	89 f0                	mov    %esi,%eax
  800ef8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800efb:	5b                   	pop    %ebx
  800efc:	5e                   	pop    %esi
  800efd:	5f                   	pop    %edi
  800efe:	5d                   	pop    %ebp
  800eff:	c3                   	ret    

00800f00 <devcons_read>:
{
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	83 ec 08             	sub    $0x8,%esp
  800f06:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f0b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f0f:	75 07                	jne    800f18 <devcons_read+0x18>
}
  800f11:	c9                   	leave  
  800f12:	c3                   	ret    
		sys_yield();
  800f13:	e8 1f f2 ff ff       	call   800137 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  800f18:	e8 9b f1 ff ff       	call   8000b8 <sys_cgetc>
  800f1d:	85 c0                	test   %eax,%eax
  800f1f:	74 f2                	je     800f13 <devcons_read+0x13>
	if (c < 0)
  800f21:	85 c0                	test   %eax,%eax
  800f23:	78 ec                	js     800f11 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  800f25:	83 f8 04             	cmp    $0x4,%eax
  800f28:	74 0c                	je     800f36 <devcons_read+0x36>
	*(char*)vbuf = c;
  800f2a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f2d:	88 02                	mov    %al,(%edx)
	return 1;
  800f2f:	b8 01 00 00 00       	mov    $0x1,%eax
  800f34:	eb db                	jmp    800f11 <devcons_read+0x11>
		return 0;
  800f36:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3b:	eb d4                	jmp    800f11 <devcons_read+0x11>

00800f3d <cputchar>:
{
  800f3d:	55                   	push   %ebp
  800f3e:	89 e5                	mov    %esp,%ebp
  800f40:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f43:	8b 45 08             	mov    0x8(%ebp),%eax
  800f46:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800f49:	6a 01                	push   $0x1
  800f4b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f4e:	50                   	push   %eax
  800f4f:	e8 46 f1 ff ff       	call   80009a <sys_cputs>
}
  800f54:	83 c4 10             	add    $0x10,%esp
  800f57:	c9                   	leave  
  800f58:	c3                   	ret    

00800f59 <getchar>:
{
  800f59:	55                   	push   %ebp
  800f5a:	89 e5                	mov    %esp,%ebp
  800f5c:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800f5f:	6a 01                	push   $0x1
  800f61:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f64:	50                   	push   %eax
  800f65:	6a 00                	push   $0x0
  800f67:	e8 c2 f6 ff ff       	call   80062e <read>
	if (r < 0)
  800f6c:	83 c4 10             	add    $0x10,%esp
  800f6f:	85 c0                	test   %eax,%eax
  800f71:	78 08                	js     800f7b <getchar+0x22>
	if (r < 1)
  800f73:	85 c0                	test   %eax,%eax
  800f75:	7e 06                	jle    800f7d <getchar+0x24>
	return c;
  800f77:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800f7b:	c9                   	leave  
  800f7c:	c3                   	ret    
		return -E_EOF;
  800f7d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800f82:	eb f7                	jmp    800f7b <getchar+0x22>

00800f84 <iscons>:
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f8d:	50                   	push   %eax
  800f8e:	ff 75 08             	pushl  0x8(%ebp)
  800f91:	e8 27 f4 ff ff       	call   8003bd <fd_lookup>
  800f96:	83 c4 10             	add    $0x10,%esp
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	78 11                	js     800fae <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  800f9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fa0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fa6:	39 10                	cmp    %edx,(%eax)
  800fa8:	0f 94 c0             	sete   %al
  800fab:	0f b6 c0             	movzbl %al,%eax
}
  800fae:	c9                   	leave  
  800faf:	c3                   	ret    

00800fb0 <opencons>:
{
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800fb6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb9:	50                   	push   %eax
  800fba:	e8 af f3 ff ff       	call   80036e <fd_alloc>
  800fbf:	83 c4 10             	add    $0x10,%esp
  800fc2:	85 c0                	test   %eax,%eax
  800fc4:	78 3a                	js     801000 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fc6:	83 ec 04             	sub    $0x4,%esp
  800fc9:	68 07 04 00 00       	push   $0x407
  800fce:	ff 75 f4             	pushl  -0xc(%ebp)
  800fd1:	6a 00                	push   $0x0
  800fd3:	e8 7e f1 ff ff       	call   800156 <sys_page_alloc>
  800fd8:	83 c4 10             	add    $0x10,%esp
  800fdb:	85 c0                	test   %eax,%eax
  800fdd:	78 21                	js     801000 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  800fdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fe8:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fed:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800ff4:	83 ec 0c             	sub    $0xc,%esp
  800ff7:	50                   	push   %eax
  800ff8:	e8 4a f3 ff ff       	call   800347 <fd2num>
  800ffd:	83 c4 10             	add    $0x10,%esp
}
  801000:	c9                   	leave  
  801001:	c3                   	ret    

00801002 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801002:	55                   	push   %ebp
  801003:	89 e5                	mov    %esp,%ebp
  801005:	56                   	push   %esi
  801006:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801007:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80100a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801010:	e8 03 f1 ff ff       	call   800118 <sys_getenvid>
  801015:	83 ec 0c             	sub    $0xc,%esp
  801018:	ff 75 0c             	pushl  0xc(%ebp)
  80101b:	ff 75 08             	pushl  0x8(%ebp)
  80101e:	56                   	push   %esi
  80101f:	50                   	push   %eax
  801020:	68 e4 1e 80 00       	push   $0x801ee4
  801025:	e8 b3 00 00 00       	call   8010dd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80102a:	83 c4 18             	add    $0x18,%esp
  80102d:	53                   	push   %ebx
  80102e:	ff 75 10             	pushl  0x10(%ebp)
  801031:	e8 56 00 00 00       	call   80108c <vcprintf>
	cprintf("\n");
  801036:	c7 04 24 cf 1e 80 00 	movl   $0x801ecf,(%esp)
  80103d:	e8 9b 00 00 00       	call   8010dd <cprintf>
  801042:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801045:	cc                   	int3   
  801046:	eb fd                	jmp    801045 <_panic+0x43>

00801048 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801048:	55                   	push   %ebp
  801049:	89 e5                	mov    %esp,%ebp
  80104b:	53                   	push   %ebx
  80104c:	83 ec 04             	sub    $0x4,%esp
  80104f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801052:	8b 13                	mov    (%ebx),%edx
  801054:	8d 42 01             	lea    0x1(%edx),%eax
  801057:	89 03                	mov    %eax,(%ebx)
  801059:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80105c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801060:	3d ff 00 00 00       	cmp    $0xff,%eax
  801065:	74 09                	je     801070 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801067:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80106b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80106e:	c9                   	leave  
  80106f:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801070:	83 ec 08             	sub    $0x8,%esp
  801073:	68 ff 00 00 00       	push   $0xff
  801078:	8d 43 08             	lea    0x8(%ebx),%eax
  80107b:	50                   	push   %eax
  80107c:	e8 19 f0 ff ff       	call   80009a <sys_cputs>
		b->idx = 0;
  801081:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801087:	83 c4 10             	add    $0x10,%esp
  80108a:	eb db                	jmp    801067 <putch+0x1f>

0080108c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80108c:	55                   	push   %ebp
  80108d:	89 e5                	mov    %esp,%ebp
  80108f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801095:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80109c:	00 00 00 
	b.cnt = 0;
  80109f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010a6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010a9:	ff 75 0c             	pushl  0xc(%ebp)
  8010ac:	ff 75 08             	pushl  0x8(%ebp)
  8010af:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010b5:	50                   	push   %eax
  8010b6:	68 48 10 80 00       	push   $0x801048
  8010bb:	e8 1a 01 00 00       	call   8011da <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010c0:	83 c4 08             	add    $0x8,%esp
  8010c3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010c9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010cf:	50                   	push   %eax
  8010d0:	e8 c5 ef ff ff       	call   80009a <sys_cputs>

	return b.cnt;
}
  8010d5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010db:	c9                   	leave  
  8010dc:	c3                   	ret    

008010dd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010dd:	55                   	push   %ebp
  8010de:	89 e5                	mov    %esp,%ebp
  8010e0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010e3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010e6:	50                   	push   %eax
  8010e7:	ff 75 08             	pushl  0x8(%ebp)
  8010ea:	e8 9d ff ff ff       	call   80108c <vcprintf>
	va_end(ap);

	return cnt;
}
  8010ef:	c9                   	leave  
  8010f0:	c3                   	ret    

008010f1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010f1:	55                   	push   %ebp
  8010f2:	89 e5                	mov    %esp,%ebp
  8010f4:	57                   	push   %edi
  8010f5:	56                   	push   %esi
  8010f6:	53                   	push   %ebx
  8010f7:	83 ec 1c             	sub    $0x1c,%esp
  8010fa:	89 c7                	mov    %eax,%edi
  8010fc:	89 d6                	mov    %edx,%esi
  8010fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801101:	8b 55 0c             	mov    0xc(%ebp),%edx
  801104:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801107:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80110a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80110d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801112:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801115:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801118:	39 d3                	cmp    %edx,%ebx
  80111a:	72 05                	jb     801121 <printnum+0x30>
  80111c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80111f:	77 7a                	ja     80119b <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801121:	83 ec 0c             	sub    $0xc,%esp
  801124:	ff 75 18             	pushl  0x18(%ebp)
  801127:	8b 45 14             	mov    0x14(%ebp),%eax
  80112a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80112d:	53                   	push   %ebx
  80112e:	ff 75 10             	pushl  0x10(%ebp)
  801131:	83 ec 08             	sub    $0x8,%esp
  801134:	ff 75 e4             	pushl  -0x1c(%ebp)
  801137:	ff 75 e0             	pushl  -0x20(%ebp)
  80113a:	ff 75 dc             	pushl  -0x24(%ebp)
  80113d:	ff 75 d8             	pushl  -0x28(%ebp)
  801140:	e8 3b 0a 00 00       	call   801b80 <__udivdi3>
  801145:	83 c4 18             	add    $0x18,%esp
  801148:	52                   	push   %edx
  801149:	50                   	push   %eax
  80114a:	89 f2                	mov    %esi,%edx
  80114c:	89 f8                	mov    %edi,%eax
  80114e:	e8 9e ff ff ff       	call   8010f1 <printnum>
  801153:	83 c4 20             	add    $0x20,%esp
  801156:	eb 13                	jmp    80116b <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801158:	83 ec 08             	sub    $0x8,%esp
  80115b:	56                   	push   %esi
  80115c:	ff 75 18             	pushl  0x18(%ebp)
  80115f:	ff d7                	call   *%edi
  801161:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801164:	83 eb 01             	sub    $0x1,%ebx
  801167:	85 db                	test   %ebx,%ebx
  801169:	7f ed                	jg     801158 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80116b:	83 ec 08             	sub    $0x8,%esp
  80116e:	56                   	push   %esi
  80116f:	83 ec 04             	sub    $0x4,%esp
  801172:	ff 75 e4             	pushl  -0x1c(%ebp)
  801175:	ff 75 e0             	pushl  -0x20(%ebp)
  801178:	ff 75 dc             	pushl  -0x24(%ebp)
  80117b:	ff 75 d8             	pushl  -0x28(%ebp)
  80117e:	e8 1d 0b 00 00       	call   801ca0 <__umoddi3>
  801183:	83 c4 14             	add    $0x14,%esp
  801186:	0f be 80 07 1f 80 00 	movsbl 0x801f07(%eax),%eax
  80118d:	50                   	push   %eax
  80118e:	ff d7                	call   *%edi
}
  801190:	83 c4 10             	add    $0x10,%esp
  801193:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801196:	5b                   	pop    %ebx
  801197:	5e                   	pop    %esi
  801198:	5f                   	pop    %edi
  801199:	5d                   	pop    %ebp
  80119a:	c3                   	ret    
  80119b:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80119e:	eb c4                	jmp    801164 <printnum+0x73>

008011a0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
  8011a3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011a6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011aa:	8b 10                	mov    (%eax),%edx
  8011ac:	3b 50 04             	cmp    0x4(%eax),%edx
  8011af:	73 0a                	jae    8011bb <sprintputch+0x1b>
		*b->buf++ = ch;
  8011b1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011b4:	89 08                	mov    %ecx,(%eax)
  8011b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b9:	88 02                	mov    %al,(%edx)
}
  8011bb:	5d                   	pop    %ebp
  8011bc:	c3                   	ret    

008011bd <printfmt>:
{
  8011bd:	55                   	push   %ebp
  8011be:	89 e5                	mov    %esp,%ebp
  8011c0:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8011c3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011c6:	50                   	push   %eax
  8011c7:	ff 75 10             	pushl  0x10(%ebp)
  8011ca:	ff 75 0c             	pushl  0xc(%ebp)
  8011cd:	ff 75 08             	pushl  0x8(%ebp)
  8011d0:	e8 05 00 00 00       	call   8011da <vprintfmt>
}
  8011d5:	83 c4 10             	add    $0x10,%esp
  8011d8:	c9                   	leave  
  8011d9:	c3                   	ret    

008011da <vprintfmt>:
{
  8011da:	55                   	push   %ebp
  8011db:	89 e5                	mov    %esp,%ebp
  8011dd:	57                   	push   %edi
  8011de:	56                   	push   %esi
  8011df:	53                   	push   %ebx
  8011e0:	83 ec 2c             	sub    $0x2c,%esp
  8011e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8011e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011e9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8011ec:	e9 c1 03 00 00       	jmp    8015b2 <vprintfmt+0x3d8>
		padc = ' ';
  8011f1:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8011f5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8011fc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  801203:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80120a:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80120f:	8d 47 01             	lea    0x1(%edi),%eax
  801212:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801215:	0f b6 17             	movzbl (%edi),%edx
  801218:	8d 42 dd             	lea    -0x23(%edx),%eax
  80121b:	3c 55                	cmp    $0x55,%al
  80121d:	0f 87 12 04 00 00    	ja     801635 <vprintfmt+0x45b>
  801223:	0f b6 c0             	movzbl %al,%eax
  801226:	ff 24 85 40 20 80 00 	jmp    *0x802040(,%eax,4)
  80122d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801230:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  801234:	eb d9                	jmp    80120f <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801236:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  801239:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80123d:	eb d0                	jmp    80120f <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80123f:	0f b6 d2             	movzbl %dl,%edx
  801242:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801245:	b8 00 00 00 00       	mov    $0x0,%eax
  80124a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80124d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801250:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801254:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801257:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80125a:	83 f9 09             	cmp    $0x9,%ecx
  80125d:	77 55                	ja     8012b4 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80125f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801262:	eb e9                	jmp    80124d <vprintfmt+0x73>
			precision = va_arg(ap, int);
  801264:	8b 45 14             	mov    0x14(%ebp),%eax
  801267:	8b 00                	mov    (%eax),%eax
  801269:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80126c:	8b 45 14             	mov    0x14(%ebp),%eax
  80126f:	8d 40 04             	lea    0x4(%eax),%eax
  801272:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801275:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801278:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80127c:	79 91                	jns    80120f <vprintfmt+0x35>
				width = precision, precision = -1;
  80127e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801281:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801284:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80128b:	eb 82                	jmp    80120f <vprintfmt+0x35>
  80128d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801290:	85 c0                	test   %eax,%eax
  801292:	ba 00 00 00 00       	mov    $0x0,%edx
  801297:	0f 49 d0             	cmovns %eax,%edx
  80129a:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80129d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012a0:	e9 6a ff ff ff       	jmp    80120f <vprintfmt+0x35>
  8012a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8012a8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012af:	e9 5b ff ff ff       	jmp    80120f <vprintfmt+0x35>
  8012b4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012b7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012ba:	eb bc                	jmp    801278 <vprintfmt+0x9e>
			lflag++;
  8012bc:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8012c2:	e9 48 ff ff ff       	jmp    80120f <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8012c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8012ca:	8d 78 04             	lea    0x4(%eax),%edi
  8012cd:	83 ec 08             	sub    $0x8,%esp
  8012d0:	53                   	push   %ebx
  8012d1:	ff 30                	pushl  (%eax)
  8012d3:	ff d6                	call   *%esi
			break;
  8012d5:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8012d8:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8012db:	e9 cf 02 00 00       	jmp    8015af <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8012e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8012e3:	8d 78 04             	lea    0x4(%eax),%edi
  8012e6:	8b 00                	mov    (%eax),%eax
  8012e8:	99                   	cltd   
  8012e9:	31 d0                	xor    %edx,%eax
  8012eb:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8012ed:	83 f8 0f             	cmp    $0xf,%eax
  8012f0:	7f 23                	jg     801315 <vprintfmt+0x13b>
  8012f2:	8b 14 85 a0 21 80 00 	mov    0x8021a0(,%eax,4),%edx
  8012f9:	85 d2                	test   %edx,%edx
  8012fb:	74 18                	je     801315 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8012fd:	52                   	push   %edx
  8012fe:	68 9d 1e 80 00       	push   $0x801e9d
  801303:	53                   	push   %ebx
  801304:	56                   	push   %esi
  801305:	e8 b3 fe ff ff       	call   8011bd <printfmt>
  80130a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80130d:	89 7d 14             	mov    %edi,0x14(%ebp)
  801310:	e9 9a 02 00 00       	jmp    8015af <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  801315:	50                   	push   %eax
  801316:	68 1f 1f 80 00       	push   $0x801f1f
  80131b:	53                   	push   %ebx
  80131c:	56                   	push   %esi
  80131d:	e8 9b fe ff ff       	call   8011bd <printfmt>
  801322:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801325:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801328:	e9 82 02 00 00       	jmp    8015af <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  80132d:	8b 45 14             	mov    0x14(%ebp),%eax
  801330:	83 c0 04             	add    $0x4,%eax
  801333:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801336:	8b 45 14             	mov    0x14(%ebp),%eax
  801339:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80133b:	85 ff                	test   %edi,%edi
  80133d:	b8 18 1f 80 00       	mov    $0x801f18,%eax
  801342:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801345:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801349:	0f 8e bd 00 00 00    	jle    80140c <vprintfmt+0x232>
  80134f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801353:	75 0e                	jne    801363 <vprintfmt+0x189>
  801355:	89 75 08             	mov    %esi,0x8(%ebp)
  801358:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80135b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80135e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801361:	eb 6d                	jmp    8013d0 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  801363:	83 ec 08             	sub    $0x8,%esp
  801366:	ff 75 d0             	pushl  -0x30(%ebp)
  801369:	57                   	push   %edi
  80136a:	e8 6e 03 00 00       	call   8016dd <strnlen>
  80136f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801372:	29 c1                	sub    %eax,%ecx
  801374:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  801377:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80137a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80137e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801381:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801384:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  801386:	eb 0f                	jmp    801397 <vprintfmt+0x1bd>
					putch(padc, putdat);
  801388:	83 ec 08             	sub    $0x8,%esp
  80138b:	53                   	push   %ebx
  80138c:	ff 75 e0             	pushl  -0x20(%ebp)
  80138f:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  801391:	83 ef 01             	sub    $0x1,%edi
  801394:	83 c4 10             	add    $0x10,%esp
  801397:	85 ff                	test   %edi,%edi
  801399:	7f ed                	jg     801388 <vprintfmt+0x1ae>
  80139b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80139e:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8013a1:	85 c9                	test   %ecx,%ecx
  8013a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a8:	0f 49 c1             	cmovns %ecx,%eax
  8013ab:	29 c1                	sub    %eax,%ecx
  8013ad:	89 75 08             	mov    %esi,0x8(%ebp)
  8013b0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8013b3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8013b6:	89 cb                	mov    %ecx,%ebx
  8013b8:	eb 16                	jmp    8013d0 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8013ba:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013be:	75 31                	jne    8013f1 <vprintfmt+0x217>
					putch(ch, putdat);
  8013c0:	83 ec 08             	sub    $0x8,%esp
  8013c3:	ff 75 0c             	pushl  0xc(%ebp)
  8013c6:	50                   	push   %eax
  8013c7:	ff 55 08             	call   *0x8(%ebp)
  8013ca:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013cd:	83 eb 01             	sub    $0x1,%ebx
  8013d0:	83 c7 01             	add    $0x1,%edi
  8013d3:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8013d7:	0f be c2             	movsbl %dl,%eax
  8013da:	85 c0                	test   %eax,%eax
  8013dc:	74 59                	je     801437 <vprintfmt+0x25d>
  8013de:	85 f6                	test   %esi,%esi
  8013e0:	78 d8                	js     8013ba <vprintfmt+0x1e0>
  8013e2:	83 ee 01             	sub    $0x1,%esi
  8013e5:	79 d3                	jns    8013ba <vprintfmt+0x1e0>
  8013e7:	89 df                	mov    %ebx,%edi
  8013e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8013ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8013ef:	eb 37                	jmp    801428 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8013f1:	0f be d2             	movsbl %dl,%edx
  8013f4:	83 ea 20             	sub    $0x20,%edx
  8013f7:	83 fa 5e             	cmp    $0x5e,%edx
  8013fa:	76 c4                	jbe    8013c0 <vprintfmt+0x1e6>
					putch('?', putdat);
  8013fc:	83 ec 08             	sub    $0x8,%esp
  8013ff:	ff 75 0c             	pushl  0xc(%ebp)
  801402:	6a 3f                	push   $0x3f
  801404:	ff 55 08             	call   *0x8(%ebp)
  801407:	83 c4 10             	add    $0x10,%esp
  80140a:	eb c1                	jmp    8013cd <vprintfmt+0x1f3>
  80140c:	89 75 08             	mov    %esi,0x8(%ebp)
  80140f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801412:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801415:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801418:	eb b6                	jmp    8013d0 <vprintfmt+0x1f6>
				putch(' ', putdat);
  80141a:	83 ec 08             	sub    $0x8,%esp
  80141d:	53                   	push   %ebx
  80141e:	6a 20                	push   $0x20
  801420:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801422:	83 ef 01             	sub    $0x1,%edi
  801425:	83 c4 10             	add    $0x10,%esp
  801428:	85 ff                	test   %edi,%edi
  80142a:	7f ee                	jg     80141a <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80142c:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80142f:	89 45 14             	mov    %eax,0x14(%ebp)
  801432:	e9 78 01 00 00       	jmp    8015af <vprintfmt+0x3d5>
  801437:	89 df                	mov    %ebx,%edi
  801439:	8b 75 08             	mov    0x8(%ebp),%esi
  80143c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80143f:	eb e7                	jmp    801428 <vprintfmt+0x24e>
	if (lflag >= 2)
  801441:	83 f9 01             	cmp    $0x1,%ecx
  801444:	7e 3f                	jle    801485 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  801446:	8b 45 14             	mov    0x14(%ebp),%eax
  801449:	8b 50 04             	mov    0x4(%eax),%edx
  80144c:	8b 00                	mov    (%eax),%eax
  80144e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801451:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801454:	8b 45 14             	mov    0x14(%ebp),%eax
  801457:	8d 40 08             	lea    0x8(%eax),%eax
  80145a:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80145d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801461:	79 5c                	jns    8014bf <vprintfmt+0x2e5>
				putch('-', putdat);
  801463:	83 ec 08             	sub    $0x8,%esp
  801466:	53                   	push   %ebx
  801467:	6a 2d                	push   $0x2d
  801469:	ff d6                	call   *%esi
				num = -(long long) num;
  80146b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80146e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801471:	f7 da                	neg    %edx
  801473:	83 d1 00             	adc    $0x0,%ecx
  801476:	f7 d9                	neg    %ecx
  801478:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80147b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801480:	e9 10 01 00 00       	jmp    801595 <vprintfmt+0x3bb>
	else if (lflag)
  801485:	85 c9                	test   %ecx,%ecx
  801487:	75 1b                	jne    8014a4 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  801489:	8b 45 14             	mov    0x14(%ebp),%eax
  80148c:	8b 00                	mov    (%eax),%eax
  80148e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801491:	89 c1                	mov    %eax,%ecx
  801493:	c1 f9 1f             	sar    $0x1f,%ecx
  801496:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801499:	8b 45 14             	mov    0x14(%ebp),%eax
  80149c:	8d 40 04             	lea    0x4(%eax),%eax
  80149f:	89 45 14             	mov    %eax,0x14(%ebp)
  8014a2:	eb b9                	jmp    80145d <vprintfmt+0x283>
		return va_arg(*ap, long);
  8014a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8014a7:	8b 00                	mov    (%eax),%eax
  8014a9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014ac:	89 c1                	mov    %eax,%ecx
  8014ae:	c1 f9 1f             	sar    $0x1f,%ecx
  8014b1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b7:	8d 40 04             	lea    0x4(%eax),%eax
  8014ba:	89 45 14             	mov    %eax,0x14(%ebp)
  8014bd:	eb 9e                	jmp    80145d <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8014bf:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014c2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8014c5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014ca:	e9 c6 00 00 00       	jmp    801595 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8014cf:	83 f9 01             	cmp    $0x1,%ecx
  8014d2:	7e 18                	jle    8014ec <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8014d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d7:	8b 10                	mov    (%eax),%edx
  8014d9:	8b 48 04             	mov    0x4(%eax),%ecx
  8014dc:	8d 40 08             	lea    0x8(%eax),%eax
  8014df:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014e2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014e7:	e9 a9 00 00 00       	jmp    801595 <vprintfmt+0x3bb>
	else if (lflag)
  8014ec:	85 c9                	test   %ecx,%ecx
  8014ee:	75 1a                	jne    80150a <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8014f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f3:	8b 10                	mov    (%eax),%edx
  8014f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014fa:	8d 40 04             	lea    0x4(%eax),%eax
  8014fd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801500:	b8 0a 00 00 00       	mov    $0xa,%eax
  801505:	e9 8b 00 00 00       	jmp    801595 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80150a:	8b 45 14             	mov    0x14(%ebp),%eax
  80150d:	8b 10                	mov    (%eax),%edx
  80150f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801514:	8d 40 04             	lea    0x4(%eax),%eax
  801517:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80151a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80151f:	eb 74                	jmp    801595 <vprintfmt+0x3bb>
	if (lflag >= 2)
  801521:	83 f9 01             	cmp    $0x1,%ecx
  801524:	7e 15                	jle    80153b <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  801526:	8b 45 14             	mov    0x14(%ebp),%eax
  801529:	8b 10                	mov    (%eax),%edx
  80152b:	8b 48 04             	mov    0x4(%eax),%ecx
  80152e:	8d 40 08             	lea    0x8(%eax),%eax
  801531:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801534:	b8 08 00 00 00       	mov    $0x8,%eax
  801539:	eb 5a                	jmp    801595 <vprintfmt+0x3bb>
	else if (lflag)
  80153b:	85 c9                	test   %ecx,%ecx
  80153d:	75 17                	jne    801556 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80153f:	8b 45 14             	mov    0x14(%ebp),%eax
  801542:	8b 10                	mov    (%eax),%edx
  801544:	b9 00 00 00 00       	mov    $0x0,%ecx
  801549:	8d 40 04             	lea    0x4(%eax),%eax
  80154c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80154f:	b8 08 00 00 00       	mov    $0x8,%eax
  801554:	eb 3f                	jmp    801595 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801556:	8b 45 14             	mov    0x14(%ebp),%eax
  801559:	8b 10                	mov    (%eax),%edx
  80155b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801560:	8d 40 04             	lea    0x4(%eax),%eax
  801563:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801566:	b8 08 00 00 00       	mov    $0x8,%eax
  80156b:	eb 28                	jmp    801595 <vprintfmt+0x3bb>
			putch('0', putdat);
  80156d:	83 ec 08             	sub    $0x8,%esp
  801570:	53                   	push   %ebx
  801571:	6a 30                	push   $0x30
  801573:	ff d6                	call   *%esi
			putch('x', putdat);
  801575:	83 c4 08             	add    $0x8,%esp
  801578:	53                   	push   %ebx
  801579:	6a 78                	push   $0x78
  80157b:	ff d6                	call   *%esi
			num = (unsigned long long)
  80157d:	8b 45 14             	mov    0x14(%ebp),%eax
  801580:	8b 10                	mov    (%eax),%edx
  801582:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801587:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80158a:	8d 40 04             	lea    0x4(%eax),%eax
  80158d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801590:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  801595:	83 ec 0c             	sub    $0xc,%esp
  801598:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80159c:	57                   	push   %edi
  80159d:	ff 75 e0             	pushl  -0x20(%ebp)
  8015a0:	50                   	push   %eax
  8015a1:	51                   	push   %ecx
  8015a2:	52                   	push   %edx
  8015a3:	89 da                	mov    %ebx,%edx
  8015a5:	89 f0                	mov    %esi,%eax
  8015a7:	e8 45 fb ff ff       	call   8010f1 <printnum>
			break;
  8015ac:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8015af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015b2:	83 c7 01             	add    $0x1,%edi
  8015b5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015b9:	83 f8 25             	cmp    $0x25,%eax
  8015bc:	0f 84 2f fc ff ff    	je     8011f1 <vprintfmt+0x17>
			if (ch == '\0')
  8015c2:	85 c0                	test   %eax,%eax
  8015c4:	0f 84 8b 00 00 00    	je     801655 <vprintfmt+0x47b>
			putch(ch, putdat);
  8015ca:	83 ec 08             	sub    $0x8,%esp
  8015cd:	53                   	push   %ebx
  8015ce:	50                   	push   %eax
  8015cf:	ff d6                	call   *%esi
  8015d1:	83 c4 10             	add    $0x10,%esp
  8015d4:	eb dc                	jmp    8015b2 <vprintfmt+0x3d8>
	if (lflag >= 2)
  8015d6:	83 f9 01             	cmp    $0x1,%ecx
  8015d9:	7e 15                	jle    8015f0 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8015db:	8b 45 14             	mov    0x14(%ebp),%eax
  8015de:	8b 10                	mov    (%eax),%edx
  8015e0:	8b 48 04             	mov    0x4(%eax),%ecx
  8015e3:	8d 40 08             	lea    0x8(%eax),%eax
  8015e6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015e9:	b8 10 00 00 00       	mov    $0x10,%eax
  8015ee:	eb a5                	jmp    801595 <vprintfmt+0x3bb>
	else if (lflag)
  8015f0:	85 c9                	test   %ecx,%ecx
  8015f2:	75 17                	jne    80160b <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8015f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8015f7:	8b 10                	mov    (%eax),%edx
  8015f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015fe:	8d 40 04             	lea    0x4(%eax),%eax
  801601:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801604:	b8 10 00 00 00       	mov    $0x10,%eax
  801609:	eb 8a                	jmp    801595 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80160b:	8b 45 14             	mov    0x14(%ebp),%eax
  80160e:	8b 10                	mov    (%eax),%edx
  801610:	b9 00 00 00 00       	mov    $0x0,%ecx
  801615:	8d 40 04             	lea    0x4(%eax),%eax
  801618:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80161b:	b8 10 00 00 00       	mov    $0x10,%eax
  801620:	e9 70 ff ff ff       	jmp    801595 <vprintfmt+0x3bb>
			putch(ch, putdat);
  801625:	83 ec 08             	sub    $0x8,%esp
  801628:	53                   	push   %ebx
  801629:	6a 25                	push   $0x25
  80162b:	ff d6                	call   *%esi
			break;
  80162d:	83 c4 10             	add    $0x10,%esp
  801630:	e9 7a ff ff ff       	jmp    8015af <vprintfmt+0x3d5>
			putch('%', putdat);
  801635:	83 ec 08             	sub    $0x8,%esp
  801638:	53                   	push   %ebx
  801639:	6a 25                	push   $0x25
  80163b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80163d:	83 c4 10             	add    $0x10,%esp
  801640:	89 f8                	mov    %edi,%eax
  801642:	eb 03                	jmp    801647 <vprintfmt+0x46d>
  801644:	83 e8 01             	sub    $0x1,%eax
  801647:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80164b:	75 f7                	jne    801644 <vprintfmt+0x46a>
  80164d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801650:	e9 5a ff ff ff       	jmp    8015af <vprintfmt+0x3d5>
}
  801655:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801658:	5b                   	pop    %ebx
  801659:	5e                   	pop    %esi
  80165a:	5f                   	pop    %edi
  80165b:	5d                   	pop    %ebp
  80165c:	c3                   	ret    

0080165d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80165d:	55                   	push   %ebp
  80165e:	89 e5                	mov    %esp,%ebp
  801660:	83 ec 18             	sub    $0x18,%esp
  801663:	8b 45 08             	mov    0x8(%ebp),%eax
  801666:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801669:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80166c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801670:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801673:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80167a:	85 c0                	test   %eax,%eax
  80167c:	74 26                	je     8016a4 <vsnprintf+0x47>
  80167e:	85 d2                	test   %edx,%edx
  801680:	7e 22                	jle    8016a4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801682:	ff 75 14             	pushl  0x14(%ebp)
  801685:	ff 75 10             	pushl  0x10(%ebp)
  801688:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80168b:	50                   	push   %eax
  80168c:	68 a0 11 80 00       	push   $0x8011a0
  801691:	e8 44 fb ff ff       	call   8011da <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801696:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801699:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80169c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80169f:	83 c4 10             	add    $0x10,%esp
}
  8016a2:	c9                   	leave  
  8016a3:	c3                   	ret    
		return -E_INVAL;
  8016a4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016a9:	eb f7                	jmp    8016a2 <vsnprintf+0x45>

008016ab <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016b1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016b4:	50                   	push   %eax
  8016b5:	ff 75 10             	pushl  0x10(%ebp)
  8016b8:	ff 75 0c             	pushl  0xc(%ebp)
  8016bb:	ff 75 08             	pushl  0x8(%ebp)
  8016be:	e8 9a ff ff ff       	call   80165d <vsnprintf>
	va_end(ap);

	return rc;
}
  8016c3:	c9                   	leave  
  8016c4:	c3                   	ret    

008016c5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016c5:	55                   	push   %ebp
  8016c6:	89 e5                	mov    %esp,%ebp
  8016c8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8016d0:	eb 03                	jmp    8016d5 <strlen+0x10>
		n++;
  8016d2:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8016d5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016d9:	75 f7                	jne    8016d2 <strlen+0xd>
	return n;
}
  8016db:	5d                   	pop    %ebp
  8016dc:	c3                   	ret    

008016dd <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016dd:	55                   	push   %ebp
  8016de:	89 e5                	mov    %esp,%ebp
  8016e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016e3:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8016eb:	eb 03                	jmp    8016f0 <strnlen+0x13>
		n++;
  8016ed:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016f0:	39 d0                	cmp    %edx,%eax
  8016f2:	74 06                	je     8016fa <strnlen+0x1d>
  8016f4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8016f8:	75 f3                	jne    8016ed <strnlen+0x10>
	return n;
}
  8016fa:	5d                   	pop    %ebp
  8016fb:	c3                   	ret    

008016fc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016fc:	55                   	push   %ebp
  8016fd:	89 e5                	mov    %esp,%ebp
  8016ff:	53                   	push   %ebx
  801700:	8b 45 08             	mov    0x8(%ebp),%eax
  801703:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801706:	89 c2                	mov    %eax,%edx
  801708:	83 c1 01             	add    $0x1,%ecx
  80170b:	83 c2 01             	add    $0x1,%edx
  80170e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801712:	88 5a ff             	mov    %bl,-0x1(%edx)
  801715:	84 db                	test   %bl,%bl
  801717:	75 ef                	jne    801708 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801719:	5b                   	pop    %ebx
  80171a:	5d                   	pop    %ebp
  80171b:	c3                   	ret    

0080171c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80171c:	55                   	push   %ebp
  80171d:	89 e5                	mov    %esp,%ebp
  80171f:	53                   	push   %ebx
  801720:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801723:	53                   	push   %ebx
  801724:	e8 9c ff ff ff       	call   8016c5 <strlen>
  801729:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80172c:	ff 75 0c             	pushl  0xc(%ebp)
  80172f:	01 d8                	add    %ebx,%eax
  801731:	50                   	push   %eax
  801732:	e8 c5 ff ff ff       	call   8016fc <strcpy>
	return dst;
}
  801737:	89 d8                	mov    %ebx,%eax
  801739:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80173c:	c9                   	leave  
  80173d:	c3                   	ret    

0080173e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80173e:	55                   	push   %ebp
  80173f:	89 e5                	mov    %esp,%ebp
  801741:	56                   	push   %esi
  801742:	53                   	push   %ebx
  801743:	8b 75 08             	mov    0x8(%ebp),%esi
  801746:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801749:	89 f3                	mov    %esi,%ebx
  80174b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80174e:	89 f2                	mov    %esi,%edx
  801750:	eb 0f                	jmp    801761 <strncpy+0x23>
		*dst++ = *src;
  801752:	83 c2 01             	add    $0x1,%edx
  801755:	0f b6 01             	movzbl (%ecx),%eax
  801758:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80175b:	80 39 01             	cmpb   $0x1,(%ecx)
  80175e:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  801761:	39 da                	cmp    %ebx,%edx
  801763:	75 ed                	jne    801752 <strncpy+0x14>
	}
	return ret;
}
  801765:	89 f0                	mov    %esi,%eax
  801767:	5b                   	pop    %ebx
  801768:	5e                   	pop    %esi
  801769:	5d                   	pop    %ebp
  80176a:	c3                   	ret    

0080176b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80176b:	55                   	push   %ebp
  80176c:	89 e5                	mov    %esp,%ebp
  80176e:	56                   	push   %esi
  80176f:	53                   	push   %ebx
  801770:	8b 75 08             	mov    0x8(%ebp),%esi
  801773:	8b 55 0c             	mov    0xc(%ebp),%edx
  801776:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801779:	89 f0                	mov    %esi,%eax
  80177b:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80177f:	85 c9                	test   %ecx,%ecx
  801781:	75 0b                	jne    80178e <strlcpy+0x23>
  801783:	eb 17                	jmp    80179c <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801785:	83 c2 01             	add    $0x1,%edx
  801788:	83 c0 01             	add    $0x1,%eax
  80178b:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80178e:	39 d8                	cmp    %ebx,%eax
  801790:	74 07                	je     801799 <strlcpy+0x2e>
  801792:	0f b6 0a             	movzbl (%edx),%ecx
  801795:	84 c9                	test   %cl,%cl
  801797:	75 ec                	jne    801785 <strlcpy+0x1a>
		*dst = '\0';
  801799:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80179c:	29 f0                	sub    %esi,%eax
}
  80179e:	5b                   	pop    %ebx
  80179f:	5e                   	pop    %esi
  8017a0:	5d                   	pop    %ebp
  8017a1:	c3                   	ret    

008017a2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017a2:	55                   	push   %ebp
  8017a3:	89 e5                	mov    %esp,%ebp
  8017a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017ab:	eb 06                	jmp    8017b3 <strcmp+0x11>
		p++, q++;
  8017ad:	83 c1 01             	add    $0x1,%ecx
  8017b0:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8017b3:	0f b6 01             	movzbl (%ecx),%eax
  8017b6:	84 c0                	test   %al,%al
  8017b8:	74 04                	je     8017be <strcmp+0x1c>
  8017ba:	3a 02                	cmp    (%edx),%al
  8017bc:	74 ef                	je     8017ad <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017be:	0f b6 c0             	movzbl %al,%eax
  8017c1:	0f b6 12             	movzbl (%edx),%edx
  8017c4:	29 d0                	sub    %edx,%eax
}
  8017c6:	5d                   	pop    %ebp
  8017c7:	c3                   	ret    

008017c8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017c8:	55                   	push   %ebp
  8017c9:	89 e5                	mov    %esp,%ebp
  8017cb:	53                   	push   %ebx
  8017cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017d2:	89 c3                	mov    %eax,%ebx
  8017d4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017d7:	eb 06                	jmp    8017df <strncmp+0x17>
		n--, p++, q++;
  8017d9:	83 c0 01             	add    $0x1,%eax
  8017dc:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8017df:	39 d8                	cmp    %ebx,%eax
  8017e1:	74 16                	je     8017f9 <strncmp+0x31>
  8017e3:	0f b6 08             	movzbl (%eax),%ecx
  8017e6:	84 c9                	test   %cl,%cl
  8017e8:	74 04                	je     8017ee <strncmp+0x26>
  8017ea:	3a 0a                	cmp    (%edx),%cl
  8017ec:	74 eb                	je     8017d9 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017ee:	0f b6 00             	movzbl (%eax),%eax
  8017f1:	0f b6 12             	movzbl (%edx),%edx
  8017f4:	29 d0                	sub    %edx,%eax
}
  8017f6:	5b                   	pop    %ebx
  8017f7:	5d                   	pop    %ebp
  8017f8:	c3                   	ret    
		return 0;
  8017f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8017fe:	eb f6                	jmp    8017f6 <strncmp+0x2e>

00801800 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	8b 45 08             	mov    0x8(%ebp),%eax
  801806:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80180a:	0f b6 10             	movzbl (%eax),%edx
  80180d:	84 d2                	test   %dl,%dl
  80180f:	74 09                	je     80181a <strchr+0x1a>
		if (*s == c)
  801811:	38 ca                	cmp    %cl,%dl
  801813:	74 0a                	je     80181f <strchr+0x1f>
	for (; *s; s++)
  801815:	83 c0 01             	add    $0x1,%eax
  801818:	eb f0                	jmp    80180a <strchr+0xa>
			return (char *) s;
	return 0;
  80181a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80181f:	5d                   	pop    %ebp
  801820:	c3                   	ret    

00801821 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801821:	55                   	push   %ebp
  801822:	89 e5                	mov    %esp,%ebp
  801824:	8b 45 08             	mov    0x8(%ebp),%eax
  801827:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80182b:	eb 03                	jmp    801830 <strfind+0xf>
  80182d:	83 c0 01             	add    $0x1,%eax
  801830:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801833:	38 ca                	cmp    %cl,%dl
  801835:	74 04                	je     80183b <strfind+0x1a>
  801837:	84 d2                	test   %dl,%dl
  801839:	75 f2                	jne    80182d <strfind+0xc>
			break;
	return (char *) s;
}
  80183b:	5d                   	pop    %ebp
  80183c:	c3                   	ret    

0080183d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80183d:	55                   	push   %ebp
  80183e:	89 e5                	mov    %esp,%ebp
  801840:	57                   	push   %edi
  801841:	56                   	push   %esi
  801842:	53                   	push   %ebx
  801843:	8b 7d 08             	mov    0x8(%ebp),%edi
  801846:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801849:	85 c9                	test   %ecx,%ecx
  80184b:	74 13                	je     801860 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80184d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801853:	75 05                	jne    80185a <memset+0x1d>
  801855:	f6 c1 03             	test   $0x3,%cl
  801858:	74 0d                	je     801867 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80185a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80185d:	fc                   	cld    
  80185e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801860:	89 f8                	mov    %edi,%eax
  801862:	5b                   	pop    %ebx
  801863:	5e                   	pop    %esi
  801864:	5f                   	pop    %edi
  801865:	5d                   	pop    %ebp
  801866:	c3                   	ret    
		c &= 0xFF;
  801867:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80186b:	89 d3                	mov    %edx,%ebx
  80186d:	c1 e3 08             	shl    $0x8,%ebx
  801870:	89 d0                	mov    %edx,%eax
  801872:	c1 e0 18             	shl    $0x18,%eax
  801875:	89 d6                	mov    %edx,%esi
  801877:	c1 e6 10             	shl    $0x10,%esi
  80187a:	09 f0                	or     %esi,%eax
  80187c:	09 c2                	or     %eax,%edx
  80187e:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  801880:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801883:	89 d0                	mov    %edx,%eax
  801885:	fc                   	cld    
  801886:	f3 ab                	rep stos %eax,%es:(%edi)
  801888:	eb d6                	jmp    801860 <memset+0x23>

0080188a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80188a:	55                   	push   %ebp
  80188b:	89 e5                	mov    %esp,%ebp
  80188d:	57                   	push   %edi
  80188e:	56                   	push   %esi
  80188f:	8b 45 08             	mov    0x8(%ebp),%eax
  801892:	8b 75 0c             	mov    0xc(%ebp),%esi
  801895:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801898:	39 c6                	cmp    %eax,%esi
  80189a:	73 35                	jae    8018d1 <memmove+0x47>
  80189c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80189f:	39 c2                	cmp    %eax,%edx
  8018a1:	76 2e                	jbe    8018d1 <memmove+0x47>
		s += n;
		d += n;
  8018a3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018a6:	89 d6                	mov    %edx,%esi
  8018a8:	09 fe                	or     %edi,%esi
  8018aa:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018b0:	74 0c                	je     8018be <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018b2:	83 ef 01             	sub    $0x1,%edi
  8018b5:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8018b8:	fd                   	std    
  8018b9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018bb:	fc                   	cld    
  8018bc:	eb 21                	jmp    8018df <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018be:	f6 c1 03             	test   $0x3,%cl
  8018c1:	75 ef                	jne    8018b2 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8018c3:	83 ef 04             	sub    $0x4,%edi
  8018c6:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018c9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8018cc:	fd                   	std    
  8018cd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018cf:	eb ea                	jmp    8018bb <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018d1:	89 f2                	mov    %esi,%edx
  8018d3:	09 c2                	or     %eax,%edx
  8018d5:	f6 c2 03             	test   $0x3,%dl
  8018d8:	74 09                	je     8018e3 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018da:	89 c7                	mov    %eax,%edi
  8018dc:	fc                   	cld    
  8018dd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018df:	5e                   	pop    %esi
  8018e0:	5f                   	pop    %edi
  8018e1:	5d                   	pop    %ebp
  8018e2:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018e3:	f6 c1 03             	test   $0x3,%cl
  8018e6:	75 f2                	jne    8018da <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018e8:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8018eb:	89 c7                	mov    %eax,%edi
  8018ed:	fc                   	cld    
  8018ee:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018f0:	eb ed                	jmp    8018df <memmove+0x55>

008018f2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018f2:	55                   	push   %ebp
  8018f3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018f5:	ff 75 10             	pushl  0x10(%ebp)
  8018f8:	ff 75 0c             	pushl  0xc(%ebp)
  8018fb:	ff 75 08             	pushl  0x8(%ebp)
  8018fe:	e8 87 ff ff ff       	call   80188a <memmove>
}
  801903:	c9                   	leave  
  801904:	c3                   	ret    

00801905 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801905:	55                   	push   %ebp
  801906:	89 e5                	mov    %esp,%ebp
  801908:	56                   	push   %esi
  801909:	53                   	push   %ebx
  80190a:	8b 45 08             	mov    0x8(%ebp),%eax
  80190d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801910:	89 c6                	mov    %eax,%esi
  801912:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801915:	39 f0                	cmp    %esi,%eax
  801917:	74 1c                	je     801935 <memcmp+0x30>
		if (*s1 != *s2)
  801919:	0f b6 08             	movzbl (%eax),%ecx
  80191c:	0f b6 1a             	movzbl (%edx),%ebx
  80191f:	38 d9                	cmp    %bl,%cl
  801921:	75 08                	jne    80192b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801923:	83 c0 01             	add    $0x1,%eax
  801926:	83 c2 01             	add    $0x1,%edx
  801929:	eb ea                	jmp    801915 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  80192b:	0f b6 c1             	movzbl %cl,%eax
  80192e:	0f b6 db             	movzbl %bl,%ebx
  801931:	29 d8                	sub    %ebx,%eax
  801933:	eb 05                	jmp    80193a <memcmp+0x35>
	}

	return 0;
  801935:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80193a:	5b                   	pop    %ebx
  80193b:	5e                   	pop    %esi
  80193c:	5d                   	pop    %ebp
  80193d:	c3                   	ret    

0080193e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80193e:	55                   	push   %ebp
  80193f:	89 e5                	mov    %esp,%ebp
  801941:	8b 45 08             	mov    0x8(%ebp),%eax
  801944:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801947:	89 c2                	mov    %eax,%edx
  801949:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80194c:	39 d0                	cmp    %edx,%eax
  80194e:	73 09                	jae    801959 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  801950:	38 08                	cmp    %cl,(%eax)
  801952:	74 05                	je     801959 <memfind+0x1b>
	for (; s < ends; s++)
  801954:	83 c0 01             	add    $0x1,%eax
  801957:	eb f3                	jmp    80194c <memfind+0xe>
			break;
	return (void *) s;
}
  801959:	5d                   	pop    %ebp
  80195a:	c3                   	ret    

0080195b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80195b:	55                   	push   %ebp
  80195c:	89 e5                	mov    %esp,%ebp
  80195e:	57                   	push   %edi
  80195f:	56                   	push   %esi
  801960:	53                   	push   %ebx
  801961:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801964:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801967:	eb 03                	jmp    80196c <strtol+0x11>
		s++;
  801969:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  80196c:	0f b6 01             	movzbl (%ecx),%eax
  80196f:	3c 20                	cmp    $0x20,%al
  801971:	74 f6                	je     801969 <strtol+0xe>
  801973:	3c 09                	cmp    $0x9,%al
  801975:	74 f2                	je     801969 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801977:	3c 2b                	cmp    $0x2b,%al
  801979:	74 2e                	je     8019a9 <strtol+0x4e>
	int neg = 0;
  80197b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801980:	3c 2d                	cmp    $0x2d,%al
  801982:	74 2f                	je     8019b3 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801984:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80198a:	75 05                	jne    801991 <strtol+0x36>
  80198c:	80 39 30             	cmpb   $0x30,(%ecx)
  80198f:	74 2c                	je     8019bd <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801991:	85 db                	test   %ebx,%ebx
  801993:	75 0a                	jne    80199f <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801995:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  80199a:	80 39 30             	cmpb   $0x30,(%ecx)
  80199d:	74 28                	je     8019c7 <strtol+0x6c>
		base = 10;
  80199f:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a4:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8019a7:	eb 50                	jmp    8019f9 <strtol+0x9e>
		s++;
  8019a9:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8019ac:	bf 00 00 00 00       	mov    $0x0,%edi
  8019b1:	eb d1                	jmp    801984 <strtol+0x29>
		s++, neg = 1;
  8019b3:	83 c1 01             	add    $0x1,%ecx
  8019b6:	bf 01 00 00 00       	mov    $0x1,%edi
  8019bb:	eb c7                	jmp    801984 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019bd:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019c1:	74 0e                	je     8019d1 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8019c3:	85 db                	test   %ebx,%ebx
  8019c5:	75 d8                	jne    80199f <strtol+0x44>
		s++, base = 8;
  8019c7:	83 c1 01             	add    $0x1,%ecx
  8019ca:	bb 08 00 00 00       	mov    $0x8,%ebx
  8019cf:	eb ce                	jmp    80199f <strtol+0x44>
		s += 2, base = 16;
  8019d1:	83 c1 02             	add    $0x2,%ecx
  8019d4:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019d9:	eb c4                	jmp    80199f <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  8019db:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019de:	89 f3                	mov    %esi,%ebx
  8019e0:	80 fb 19             	cmp    $0x19,%bl
  8019e3:	77 29                	ja     801a0e <strtol+0xb3>
			dig = *s - 'a' + 10;
  8019e5:	0f be d2             	movsbl %dl,%edx
  8019e8:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019eb:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019ee:	7d 30                	jge    801a20 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8019f0:	83 c1 01             	add    $0x1,%ecx
  8019f3:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019f7:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8019f9:	0f b6 11             	movzbl (%ecx),%edx
  8019fc:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019ff:	89 f3                	mov    %esi,%ebx
  801a01:	80 fb 09             	cmp    $0x9,%bl
  801a04:	77 d5                	ja     8019db <strtol+0x80>
			dig = *s - '0';
  801a06:	0f be d2             	movsbl %dl,%edx
  801a09:	83 ea 30             	sub    $0x30,%edx
  801a0c:	eb dd                	jmp    8019eb <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  801a0e:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a11:	89 f3                	mov    %esi,%ebx
  801a13:	80 fb 19             	cmp    $0x19,%bl
  801a16:	77 08                	ja     801a20 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801a18:	0f be d2             	movsbl %dl,%edx
  801a1b:	83 ea 37             	sub    $0x37,%edx
  801a1e:	eb cb                	jmp    8019eb <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  801a20:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a24:	74 05                	je     801a2b <strtol+0xd0>
		*endptr = (char *) s;
  801a26:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a29:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a2b:	89 c2                	mov    %eax,%edx
  801a2d:	f7 da                	neg    %edx
  801a2f:	85 ff                	test   %edi,%edi
  801a31:	0f 45 c2             	cmovne %edx,%eax
}
  801a34:	5b                   	pop    %ebx
  801a35:	5e                   	pop    %esi
  801a36:	5f                   	pop    %edi
  801a37:	5d                   	pop    %ebp
  801a38:	c3                   	ret    

00801a39 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a39:	55                   	push   %ebp
  801a3a:	89 e5                	mov    %esp,%ebp
  801a3c:	56                   	push   %esi
  801a3d:	53                   	push   %ebx
  801a3e:	8b 75 08             	mov    0x8(%ebp),%esi
  801a41:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a44:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        //	panic("ipc_recv not implemented");
        int r;
       	if(pg!=NULL){
  801a47:	85 c0                	test   %eax,%eax
  801a49:	74 3b                	je     801a86 <ipc_recv+0x4d>
	  r = sys_ipc_recv(pg);
  801a4b:	83 ec 0c             	sub    $0xc,%esp
  801a4e:	50                   	push   %eax
  801a4f:	e8 b2 e8 ff ff       	call   800306 <sys_ipc_recv>
  801a54:	83 c4 10             	add    $0x10,%esp
	}else
	  r = sys_ipc_recv((void *)UTOP);
	if(r<0){
  801a57:	85 c0                	test   %eax,%eax
  801a59:	78 3d                	js     801a98 <ipc_recv+0x5f>
	if(perm_store!=NULL){
		*perm_store = 0;
            }
        	return r;
           }else{
	     if(from_env_store!=NULL)
  801a5b:	85 f6                	test   %esi,%esi
  801a5d:	74 0a                	je     801a69 <ipc_recv+0x30>
		     *from_env_store = thisenv->env_ipc_from;
  801a5f:	a1 04 40 80 00       	mov    0x804004,%eax
  801a64:	8b 40 74             	mov    0x74(%eax),%eax
  801a67:	89 06                	mov    %eax,(%esi)
	     if(perm_store != NULL)
  801a69:	85 db                	test   %ebx,%ebx
  801a6b:	74 0a                	je     801a77 <ipc_recv+0x3e>
		     *perm_store = thisenv->env_ipc_perm;
  801a6d:	a1 04 40 80 00       	mov    0x804004,%eax
  801a72:	8b 40 78             	mov    0x78(%eax),%eax
  801a75:	89 03                	mov    %eax,(%ebx)
	     return thisenv->env_ipc_value;
  801a77:	a1 04 40 80 00       	mov    0x804004,%eax
  801a7c:	8b 40 70             	mov    0x70(%eax),%eax
	   }

}
  801a7f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a82:	5b                   	pop    %ebx
  801a83:	5e                   	pop    %esi
  801a84:	5d                   	pop    %ebp
  801a85:	c3                   	ret    
	  r = sys_ipc_recv((void *)UTOP);
  801a86:	83 ec 0c             	sub    $0xc,%esp
  801a89:	68 00 00 c0 ee       	push   $0xeec00000
  801a8e:	e8 73 e8 ff ff       	call   800306 <sys_ipc_recv>
  801a93:	83 c4 10             	add    $0x10,%esp
  801a96:	eb bf                	jmp    801a57 <ipc_recv+0x1e>
	if(from_env_store!=NULL){
  801a98:	85 f6                	test   %esi,%esi
  801a9a:	74 06                	je     801aa2 <ipc_recv+0x69>
	  *from_env_store = 0;
  801a9c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(perm_store!=NULL){
  801aa2:	85 db                	test   %ebx,%ebx
  801aa4:	74 d9                	je     801a7f <ipc_recv+0x46>
		*perm_store = 0;
  801aa6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801aac:	eb d1                	jmp    801a7f <ipc_recv+0x46>

00801aae <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801aae:	55                   	push   %ebp
  801aaf:	89 e5                	mov    %esp,%ebp
  801ab1:	57                   	push   %edi
  801ab2:	56                   	push   %esi
  801ab3:	53                   	push   %ebx
  801ab4:	83 ec 0c             	sub    $0xc,%esp
  801ab7:	8b 7d 08             	mov    0x8(%ebp),%edi
  801aba:	8b 75 0c             	mov    0xc(%ebp),%esi
  801abd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if(pg==NULL) pg = (void *)UTOP;
  801ac0:	85 db                	test   %ebx,%ebx
  801ac2:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ac7:	0f 44 d8             	cmove  %eax,%ebx
	while((r=sys_ipc_try_send(to_env,val,pg,perm))<0){
  801aca:	ff 75 14             	pushl  0x14(%ebp)
  801acd:	53                   	push   %ebx
  801ace:	56                   	push   %esi
  801acf:	57                   	push   %edi
  801ad0:	e8 0e e8 ff ff       	call   8002e3 <sys_ipc_try_send>
  801ad5:	83 c4 10             	add    $0x10,%esp
  801ad8:	85 c0                	test   %eax,%eax
  801ada:	79 20                	jns    801afc <ipc_send+0x4e>
	    if(r!=-E_IPC_NOT_RECV){
  801adc:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801adf:	75 07                	jne    801ae8 <ipc_send+0x3a>
		    panic("ipc_send:send message failed\n");
	    }
	    sys_yield();
  801ae1:	e8 51 e6 ff ff       	call   800137 <sys_yield>
  801ae6:	eb e2                	jmp    801aca <ipc_send+0x1c>
		    panic("ipc_send:send message failed\n");
  801ae8:	83 ec 04             	sub    $0x4,%esp
  801aeb:	68 00 22 80 00       	push   $0x802200
  801af0:	6a 43                	push   $0x43
  801af2:	68 1e 22 80 00       	push   $0x80221e
  801af7:	e8 06 f5 ff ff       	call   801002 <_panic>
	}

}
  801afc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aff:	5b                   	pop    %ebx
  801b00:	5e                   	pop    %esi
  801b01:	5f                   	pop    %edi
  801b02:	5d                   	pop    %ebp
  801b03:	c3                   	ret    

00801b04 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b04:	55                   	push   %ebp
  801b05:	89 e5                	mov    %esp,%ebp
  801b07:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b0a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b0f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b12:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b18:	8b 52 50             	mov    0x50(%edx),%edx
  801b1b:	39 ca                	cmp    %ecx,%edx
  801b1d:	74 11                	je     801b30 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801b1f:	83 c0 01             	add    $0x1,%eax
  801b22:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b27:	75 e6                	jne    801b0f <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801b29:	b8 00 00 00 00       	mov    $0x0,%eax
  801b2e:	eb 0b                	jmp    801b3b <ipc_find_env+0x37>
			return envs[i].env_id;
  801b30:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b33:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b38:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b3b:	5d                   	pop    %ebp
  801b3c:	c3                   	ret    

00801b3d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b3d:	55                   	push   %ebp
  801b3e:	89 e5                	mov    %esp,%ebp
  801b40:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b43:	89 d0                	mov    %edx,%eax
  801b45:	c1 e8 16             	shr    $0x16,%eax
  801b48:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b4f:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801b54:	f6 c1 01             	test   $0x1,%cl
  801b57:	74 1d                	je     801b76 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801b59:	c1 ea 0c             	shr    $0xc,%edx
  801b5c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b63:	f6 c2 01             	test   $0x1,%dl
  801b66:	74 0e                	je     801b76 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b68:	c1 ea 0c             	shr    $0xc,%edx
  801b6b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b72:	ef 
  801b73:	0f b7 c0             	movzwl %ax,%eax
}
  801b76:	5d                   	pop    %ebp
  801b77:	c3                   	ret    
  801b78:	66 90                	xchg   %ax,%ax
  801b7a:	66 90                	xchg   %ax,%ax
  801b7c:	66 90                	xchg   %ax,%ax
  801b7e:	66 90                	xchg   %ax,%ax

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
