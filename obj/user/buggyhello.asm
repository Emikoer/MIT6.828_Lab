
obj/user/buggyhello.debug:     file format elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 65 00 00 00       	call   8000a7 <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800052:	e8 ce 00 00 00       	call   800125 <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 db                	test   %ebx,%ebx
  80006b:	7e 07                	jle    800074 <libmain+0x2d>
		binaryname = argv[0];
  80006d:	8b 06                	mov    (%esi),%eax
  80006f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800074:	83 ec 08             	sub    $0x8,%esp
  800077:	56                   	push   %esi
  800078:	53                   	push   %ebx
  800079:	e8 b5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007e:	e8 0a 00 00 00       	call   80008d <exit>
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800089:	5b                   	pop    %ebx
  80008a:	5e                   	pop    %esi
  80008b:	5d                   	pop    %ebp
  80008c:	c3                   	ret    

0080008d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008d:	55                   	push   %ebp
  80008e:	89 e5                	mov    %esp,%ebp
  800090:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800093:	e8 92 04 00 00       	call   80052a <close_all>
	sys_env_destroy(0);
  800098:	83 ec 0c             	sub    $0xc,%esp
  80009b:	6a 00                	push   $0x0
  80009d:	e8 42 00 00 00       	call   8000e4 <sys_env_destroy>
}
  8000a2:	83 c4 10             	add    $0x10,%esp
  8000a5:	c9                   	leave  
  8000a6:	c3                   	ret    

008000a7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a7:	55                   	push   %ebp
  8000a8:	89 e5                	mov    %esp,%ebp
  8000aa:	57                   	push   %edi
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b8:	89 c3                	mov    %eax,%ebx
  8000ba:	89 c7                	mov    %eax,%edi
  8000bc:	89 c6                	mov    %eax,%esi
  8000be:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c0:	5b                   	pop    %ebx
  8000c1:	5e                   	pop    %esi
  8000c2:	5f                   	pop    %edi
  8000c3:	5d                   	pop    %ebp
  8000c4:	c3                   	ret    

008000c5 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	57                   	push   %edi
  8000c9:	56                   	push   %esi
  8000ca:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d5:	89 d1                	mov    %edx,%ecx
  8000d7:	89 d3                	mov    %edx,%ebx
  8000d9:	89 d7                	mov    %edx,%edi
  8000db:	89 d6                	mov    %edx,%esi
  8000dd:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000df:	5b                   	pop    %ebx
  8000e0:	5e                   	pop    %esi
  8000e1:	5f                   	pop    %edi
  8000e2:	5d                   	pop    %ebp
  8000e3:	c3                   	ret    

008000e4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	57                   	push   %edi
  8000e8:	56                   	push   %esi
  8000e9:	53                   	push   %ebx
  8000ea:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fa:	89 cb                	mov    %ecx,%ebx
  8000fc:	89 cf                	mov    %ecx,%edi
  8000fe:	89 ce                	mov    %ecx,%esi
  800100:	cd 30                	int    $0x30
	if(check && ret > 0)
  800102:	85 c0                	test   %eax,%eax
  800104:	7f 08                	jg     80010e <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800106:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800109:	5b                   	pop    %ebx
  80010a:	5e                   	pop    %esi
  80010b:	5f                   	pop    %edi
  80010c:	5d                   	pop    %ebp
  80010d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80010e:	83 ec 0c             	sub    $0xc,%esp
  800111:	50                   	push   %eax
  800112:	6a 03                	push   $0x3
  800114:	68 ea 1d 80 00       	push   $0x801dea
  800119:	6a 23                	push   $0x23
  80011b:	68 07 1e 80 00       	push   $0x801e07
  800120:	e8 ea 0e 00 00       	call   80100f <_panic>

00800125 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	57                   	push   %edi
  800129:	56                   	push   %esi
  80012a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80012b:	ba 00 00 00 00       	mov    $0x0,%edx
  800130:	b8 02 00 00 00       	mov    $0x2,%eax
  800135:	89 d1                	mov    %edx,%ecx
  800137:	89 d3                	mov    %edx,%ebx
  800139:	89 d7                	mov    %edx,%edi
  80013b:	89 d6                	mov    %edx,%esi
  80013d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013f:	5b                   	pop    %ebx
  800140:	5e                   	pop    %esi
  800141:	5f                   	pop    %edi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <sys_yield>:

void
sys_yield(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	57                   	push   %edi
  800148:	56                   	push   %esi
  800149:	53                   	push   %ebx
	asm volatile("int %1\n"
  80014a:	ba 00 00 00 00       	mov    $0x0,%edx
  80014f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800154:	89 d1                	mov    %edx,%ecx
  800156:	89 d3                	mov    %edx,%ebx
  800158:	89 d7                	mov    %edx,%edi
  80015a:	89 d6                	mov    %edx,%esi
  80015c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015e:	5b                   	pop    %ebx
  80015f:	5e                   	pop    %esi
  800160:	5f                   	pop    %edi
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    

00800163 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	57                   	push   %edi
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80016c:	be 00 00 00 00       	mov    $0x0,%esi
  800171:	8b 55 08             	mov    0x8(%ebp),%edx
  800174:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800177:	b8 04 00 00 00       	mov    $0x4,%eax
  80017c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017f:	89 f7                	mov    %esi,%edi
  800181:	cd 30                	int    $0x30
	if(check && ret > 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	7f 08                	jg     80018f <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800187:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80018a:	5b                   	pop    %ebx
  80018b:	5e                   	pop    %esi
  80018c:	5f                   	pop    %edi
  80018d:	5d                   	pop    %ebp
  80018e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80018f:	83 ec 0c             	sub    $0xc,%esp
  800192:	50                   	push   %eax
  800193:	6a 04                	push   $0x4
  800195:	68 ea 1d 80 00       	push   $0x801dea
  80019a:	6a 23                	push   $0x23
  80019c:	68 07 1e 80 00       	push   $0x801e07
  8001a1:	e8 69 0e 00 00       	call   80100f <_panic>

008001a6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	57                   	push   %edi
  8001aa:	56                   	push   %esi
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001af:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b5:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c0:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c3:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001c5:	85 c0                	test   %eax,%eax
  8001c7:	7f 08                	jg     8001d1 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001cc:	5b                   	pop    %ebx
  8001cd:	5e                   	pop    %esi
  8001ce:	5f                   	pop    %edi
  8001cf:	5d                   	pop    %ebp
  8001d0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d1:	83 ec 0c             	sub    $0xc,%esp
  8001d4:	50                   	push   %eax
  8001d5:	6a 05                	push   $0x5
  8001d7:	68 ea 1d 80 00       	push   $0x801dea
  8001dc:	6a 23                	push   $0x23
  8001de:	68 07 1e 80 00       	push   $0x801e07
  8001e3:	e8 27 0e 00 00       	call   80100f <_panic>

008001e8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fc:	b8 06 00 00 00       	mov    $0x6,%eax
  800201:	89 df                	mov    %ebx,%edi
  800203:	89 de                	mov    %ebx,%esi
  800205:	cd 30                	int    $0x30
	if(check && ret > 0)
  800207:	85 c0                	test   %eax,%eax
  800209:	7f 08                	jg     800213 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80020b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020e:	5b                   	pop    %ebx
  80020f:	5e                   	pop    %esi
  800210:	5f                   	pop    %edi
  800211:	5d                   	pop    %ebp
  800212:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800213:	83 ec 0c             	sub    $0xc,%esp
  800216:	50                   	push   %eax
  800217:	6a 06                	push   $0x6
  800219:	68 ea 1d 80 00       	push   $0x801dea
  80021e:	6a 23                	push   $0x23
  800220:	68 07 1e 80 00       	push   $0x801e07
  800225:	e8 e5 0d 00 00       	call   80100f <_panic>

0080022a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	57                   	push   %edi
  80022e:	56                   	push   %esi
  80022f:	53                   	push   %ebx
  800230:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800233:	bb 00 00 00 00       	mov    $0x0,%ebx
  800238:	8b 55 08             	mov    0x8(%ebp),%edx
  80023b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023e:	b8 08 00 00 00       	mov    $0x8,%eax
  800243:	89 df                	mov    %ebx,%edi
  800245:	89 de                	mov    %ebx,%esi
  800247:	cd 30                	int    $0x30
	if(check && ret > 0)
  800249:	85 c0                	test   %eax,%eax
  80024b:	7f 08                	jg     800255 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80024d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800250:	5b                   	pop    %ebx
  800251:	5e                   	pop    %esi
  800252:	5f                   	pop    %edi
  800253:	5d                   	pop    %ebp
  800254:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800255:	83 ec 0c             	sub    $0xc,%esp
  800258:	50                   	push   %eax
  800259:	6a 08                	push   $0x8
  80025b:	68 ea 1d 80 00       	push   $0x801dea
  800260:	6a 23                	push   $0x23
  800262:	68 07 1e 80 00       	push   $0x801e07
  800267:	e8 a3 0d 00 00       	call   80100f <_panic>

0080026c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	57                   	push   %edi
  800270:	56                   	push   %esi
  800271:	53                   	push   %ebx
  800272:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800275:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027a:	8b 55 08             	mov    0x8(%ebp),%edx
  80027d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800280:	b8 09 00 00 00       	mov    $0x9,%eax
  800285:	89 df                	mov    %ebx,%edi
  800287:	89 de                	mov    %ebx,%esi
  800289:	cd 30                	int    $0x30
	if(check && ret > 0)
  80028b:	85 c0                	test   %eax,%eax
  80028d:	7f 08                	jg     800297 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80028f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800292:	5b                   	pop    %ebx
  800293:	5e                   	pop    %esi
  800294:	5f                   	pop    %edi
  800295:	5d                   	pop    %ebp
  800296:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800297:	83 ec 0c             	sub    $0xc,%esp
  80029a:	50                   	push   %eax
  80029b:	6a 09                	push   $0x9
  80029d:	68 ea 1d 80 00       	push   $0x801dea
  8002a2:	6a 23                	push   $0x23
  8002a4:	68 07 1e 80 00       	push   $0x801e07
  8002a9:	e8 61 0d 00 00       	call   80100f <_panic>

008002ae <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	57                   	push   %edi
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c7:	89 df                	mov    %ebx,%edi
  8002c9:	89 de                	mov    %ebx,%esi
  8002cb:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002cd:	85 c0                	test   %eax,%eax
  8002cf:	7f 08                	jg     8002d9 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d4:	5b                   	pop    %ebx
  8002d5:	5e                   	pop    %esi
  8002d6:	5f                   	pop    %edi
  8002d7:	5d                   	pop    %ebp
  8002d8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d9:	83 ec 0c             	sub    $0xc,%esp
  8002dc:	50                   	push   %eax
  8002dd:	6a 0a                	push   $0xa
  8002df:	68 ea 1d 80 00       	push   $0x801dea
  8002e4:	6a 23                	push   $0x23
  8002e6:	68 07 1e 80 00       	push   $0x801e07
  8002eb:	e8 1f 0d 00 00       	call   80100f <_panic>

008002f0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fc:	b8 0c 00 00 00       	mov    $0xc,%eax
  800301:	be 00 00 00 00       	mov    $0x0,%esi
  800306:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800309:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030c:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80030e:	5b                   	pop    %ebx
  80030f:	5e                   	pop    %esi
  800310:	5f                   	pop    %edi
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	57                   	push   %edi
  800317:	56                   	push   %esi
  800318:	53                   	push   %ebx
  800319:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80031c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	b8 0d 00 00 00       	mov    $0xd,%eax
  800329:	89 cb                	mov    %ecx,%ebx
  80032b:	89 cf                	mov    %ecx,%edi
  80032d:	89 ce                	mov    %ecx,%esi
  80032f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800331:	85 c0                	test   %eax,%eax
  800333:	7f 08                	jg     80033d <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800335:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800338:	5b                   	pop    %ebx
  800339:	5e                   	pop    %esi
  80033a:	5f                   	pop    %edi
  80033b:	5d                   	pop    %ebp
  80033c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80033d:	83 ec 0c             	sub    $0xc,%esp
  800340:	50                   	push   %eax
  800341:	6a 0d                	push   $0xd
  800343:	68 ea 1d 80 00       	push   $0x801dea
  800348:	6a 23                	push   $0x23
  80034a:	68 07 1e 80 00       	push   $0x801e07
  80034f:	e8 bb 0c 00 00       	call   80100f <_panic>

00800354 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800357:	8b 45 08             	mov    0x8(%ebp),%eax
  80035a:	05 00 00 00 30       	add    $0x30000000,%eax
  80035f:	c1 e8 0c             	shr    $0xc,%eax
}
  800362:	5d                   	pop    %ebp
  800363:	c3                   	ret    

00800364 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800367:	8b 45 08             	mov    0x8(%ebp),%eax
  80036a:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80036f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800374:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800379:	5d                   	pop    %ebp
  80037a:	c3                   	ret    

0080037b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80037b:	55                   	push   %ebp
  80037c:	89 e5                	mov    %esp,%ebp
  80037e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800381:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800386:	89 c2                	mov    %eax,%edx
  800388:	c1 ea 16             	shr    $0x16,%edx
  80038b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800392:	f6 c2 01             	test   $0x1,%dl
  800395:	74 2a                	je     8003c1 <fd_alloc+0x46>
  800397:	89 c2                	mov    %eax,%edx
  800399:	c1 ea 0c             	shr    $0xc,%edx
  80039c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003a3:	f6 c2 01             	test   $0x1,%dl
  8003a6:	74 19                	je     8003c1 <fd_alloc+0x46>
  8003a8:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8003ad:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003b2:	75 d2                	jne    800386 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003b4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003ba:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8003bf:	eb 07                	jmp    8003c8 <fd_alloc+0x4d>
			*fd_store = fd;
  8003c1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003c8:	5d                   	pop    %ebp
  8003c9:	c3                   	ret    

008003ca <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d0:	83 f8 1f             	cmp    $0x1f,%eax
  8003d3:	77 36                	ja     80040b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d5:	c1 e0 0c             	shl    $0xc,%eax
  8003d8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003dd:	89 c2                	mov    %eax,%edx
  8003df:	c1 ea 16             	shr    $0x16,%edx
  8003e2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e9:	f6 c2 01             	test   $0x1,%dl
  8003ec:	74 24                	je     800412 <fd_lookup+0x48>
  8003ee:	89 c2                	mov    %eax,%edx
  8003f0:	c1 ea 0c             	shr    $0xc,%edx
  8003f3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003fa:	f6 c2 01             	test   $0x1,%dl
  8003fd:	74 1a                	je     800419 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800402:	89 02                	mov    %eax,(%edx)
	return 0;
  800404:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800409:	5d                   	pop    %ebp
  80040a:	c3                   	ret    
		return -E_INVAL;
  80040b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800410:	eb f7                	jmp    800409 <fd_lookup+0x3f>
		return -E_INVAL;
  800412:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800417:	eb f0                	jmp    800409 <fd_lookup+0x3f>
  800419:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80041e:	eb e9                	jmp    800409 <fd_lookup+0x3f>

00800420 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	83 ec 08             	sub    $0x8,%esp
  800426:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800429:	ba 94 1e 80 00       	mov    $0x801e94,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80042e:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800433:	39 08                	cmp    %ecx,(%eax)
  800435:	74 33                	je     80046a <dev_lookup+0x4a>
  800437:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80043a:	8b 02                	mov    (%edx),%eax
  80043c:	85 c0                	test   %eax,%eax
  80043e:	75 f3                	jne    800433 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800440:	a1 04 40 80 00       	mov    0x804004,%eax
  800445:	8b 40 48             	mov    0x48(%eax),%eax
  800448:	83 ec 04             	sub    $0x4,%esp
  80044b:	51                   	push   %ecx
  80044c:	50                   	push   %eax
  80044d:	68 18 1e 80 00       	push   $0x801e18
  800452:	e8 93 0c 00 00       	call   8010ea <cprintf>
	*dev = 0;
  800457:	8b 45 0c             	mov    0xc(%ebp),%eax
  80045a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800460:	83 c4 10             	add    $0x10,%esp
  800463:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800468:	c9                   	leave  
  800469:	c3                   	ret    
			*dev = devtab[i];
  80046a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80046d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80046f:	b8 00 00 00 00       	mov    $0x0,%eax
  800474:	eb f2                	jmp    800468 <dev_lookup+0x48>

00800476 <fd_close>:
{
  800476:	55                   	push   %ebp
  800477:	89 e5                	mov    %esp,%ebp
  800479:	57                   	push   %edi
  80047a:	56                   	push   %esi
  80047b:	53                   	push   %ebx
  80047c:	83 ec 1c             	sub    $0x1c,%esp
  80047f:	8b 75 08             	mov    0x8(%ebp),%esi
  800482:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800485:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800488:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800489:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80048f:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800492:	50                   	push   %eax
  800493:	e8 32 ff ff ff       	call   8003ca <fd_lookup>
  800498:	89 c3                	mov    %eax,%ebx
  80049a:	83 c4 08             	add    $0x8,%esp
  80049d:	85 c0                	test   %eax,%eax
  80049f:	78 05                	js     8004a6 <fd_close+0x30>
	    || fd != fd2)
  8004a1:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8004a4:	74 16                	je     8004bc <fd_close+0x46>
		return (must_exist ? r : 0);
  8004a6:	89 f8                	mov    %edi,%eax
  8004a8:	84 c0                	test   %al,%al
  8004aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8004af:	0f 44 d8             	cmove  %eax,%ebx
}
  8004b2:	89 d8                	mov    %ebx,%eax
  8004b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004b7:	5b                   	pop    %ebx
  8004b8:	5e                   	pop    %esi
  8004b9:	5f                   	pop    %edi
  8004ba:	5d                   	pop    %ebp
  8004bb:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004bc:	83 ec 08             	sub    $0x8,%esp
  8004bf:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8004c2:	50                   	push   %eax
  8004c3:	ff 36                	pushl  (%esi)
  8004c5:	e8 56 ff ff ff       	call   800420 <dev_lookup>
  8004ca:	89 c3                	mov    %eax,%ebx
  8004cc:	83 c4 10             	add    $0x10,%esp
  8004cf:	85 c0                	test   %eax,%eax
  8004d1:	78 15                	js     8004e8 <fd_close+0x72>
		if (dev->dev_close)
  8004d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004d6:	8b 40 10             	mov    0x10(%eax),%eax
  8004d9:	85 c0                	test   %eax,%eax
  8004db:	74 1b                	je     8004f8 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8004dd:	83 ec 0c             	sub    $0xc,%esp
  8004e0:	56                   	push   %esi
  8004e1:	ff d0                	call   *%eax
  8004e3:	89 c3                	mov    %eax,%ebx
  8004e5:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004e8:	83 ec 08             	sub    $0x8,%esp
  8004eb:	56                   	push   %esi
  8004ec:	6a 00                	push   $0x0
  8004ee:	e8 f5 fc ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  8004f3:	83 c4 10             	add    $0x10,%esp
  8004f6:	eb ba                	jmp    8004b2 <fd_close+0x3c>
			r = 0;
  8004f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004fd:	eb e9                	jmp    8004e8 <fd_close+0x72>

008004ff <close>:

int
close(int fdnum)
{
  8004ff:	55                   	push   %ebp
  800500:	89 e5                	mov    %esp,%ebp
  800502:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800505:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800508:	50                   	push   %eax
  800509:	ff 75 08             	pushl  0x8(%ebp)
  80050c:	e8 b9 fe ff ff       	call   8003ca <fd_lookup>
  800511:	83 c4 08             	add    $0x8,%esp
  800514:	85 c0                	test   %eax,%eax
  800516:	78 10                	js     800528 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800518:	83 ec 08             	sub    $0x8,%esp
  80051b:	6a 01                	push   $0x1
  80051d:	ff 75 f4             	pushl  -0xc(%ebp)
  800520:	e8 51 ff ff ff       	call   800476 <fd_close>
  800525:	83 c4 10             	add    $0x10,%esp
}
  800528:	c9                   	leave  
  800529:	c3                   	ret    

0080052a <close_all>:

void
close_all(void)
{
  80052a:	55                   	push   %ebp
  80052b:	89 e5                	mov    %esp,%ebp
  80052d:	53                   	push   %ebx
  80052e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800531:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800536:	83 ec 0c             	sub    $0xc,%esp
  800539:	53                   	push   %ebx
  80053a:	e8 c0 ff ff ff       	call   8004ff <close>
	for (i = 0; i < MAXFD; i++)
  80053f:	83 c3 01             	add    $0x1,%ebx
  800542:	83 c4 10             	add    $0x10,%esp
  800545:	83 fb 20             	cmp    $0x20,%ebx
  800548:	75 ec                	jne    800536 <close_all+0xc>
}
  80054a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80054d:	c9                   	leave  
  80054e:	c3                   	ret    

0080054f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80054f:	55                   	push   %ebp
  800550:	89 e5                	mov    %esp,%ebp
  800552:	57                   	push   %edi
  800553:	56                   	push   %esi
  800554:	53                   	push   %ebx
  800555:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800558:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80055b:	50                   	push   %eax
  80055c:	ff 75 08             	pushl  0x8(%ebp)
  80055f:	e8 66 fe ff ff       	call   8003ca <fd_lookup>
  800564:	89 c3                	mov    %eax,%ebx
  800566:	83 c4 08             	add    $0x8,%esp
  800569:	85 c0                	test   %eax,%eax
  80056b:	0f 88 81 00 00 00    	js     8005f2 <dup+0xa3>
		return r;
	close(newfdnum);
  800571:	83 ec 0c             	sub    $0xc,%esp
  800574:	ff 75 0c             	pushl  0xc(%ebp)
  800577:	e8 83 ff ff ff       	call   8004ff <close>

	newfd = INDEX2FD(newfdnum);
  80057c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80057f:	c1 e6 0c             	shl    $0xc,%esi
  800582:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800588:	83 c4 04             	add    $0x4,%esp
  80058b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80058e:	e8 d1 fd ff ff       	call   800364 <fd2data>
  800593:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800595:	89 34 24             	mov    %esi,(%esp)
  800598:	e8 c7 fd ff ff       	call   800364 <fd2data>
  80059d:	83 c4 10             	add    $0x10,%esp
  8005a0:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005a2:	89 d8                	mov    %ebx,%eax
  8005a4:	c1 e8 16             	shr    $0x16,%eax
  8005a7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005ae:	a8 01                	test   $0x1,%al
  8005b0:	74 11                	je     8005c3 <dup+0x74>
  8005b2:	89 d8                	mov    %ebx,%eax
  8005b4:	c1 e8 0c             	shr    $0xc,%eax
  8005b7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005be:	f6 c2 01             	test   $0x1,%dl
  8005c1:	75 39                	jne    8005fc <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005c3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005c6:	89 d0                	mov    %edx,%eax
  8005c8:	c1 e8 0c             	shr    $0xc,%eax
  8005cb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005d2:	83 ec 0c             	sub    $0xc,%esp
  8005d5:	25 07 0e 00 00       	and    $0xe07,%eax
  8005da:	50                   	push   %eax
  8005db:	56                   	push   %esi
  8005dc:	6a 00                	push   $0x0
  8005de:	52                   	push   %edx
  8005df:	6a 00                	push   $0x0
  8005e1:	e8 c0 fb ff ff       	call   8001a6 <sys_page_map>
  8005e6:	89 c3                	mov    %eax,%ebx
  8005e8:	83 c4 20             	add    $0x20,%esp
  8005eb:	85 c0                	test   %eax,%eax
  8005ed:	78 31                	js     800620 <dup+0xd1>
		goto err;

	return newfdnum;
  8005ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005f2:	89 d8                	mov    %ebx,%eax
  8005f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005f7:	5b                   	pop    %ebx
  8005f8:	5e                   	pop    %esi
  8005f9:	5f                   	pop    %edi
  8005fa:	5d                   	pop    %ebp
  8005fb:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005fc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800603:	83 ec 0c             	sub    $0xc,%esp
  800606:	25 07 0e 00 00       	and    $0xe07,%eax
  80060b:	50                   	push   %eax
  80060c:	57                   	push   %edi
  80060d:	6a 00                	push   $0x0
  80060f:	53                   	push   %ebx
  800610:	6a 00                	push   $0x0
  800612:	e8 8f fb ff ff       	call   8001a6 <sys_page_map>
  800617:	89 c3                	mov    %eax,%ebx
  800619:	83 c4 20             	add    $0x20,%esp
  80061c:	85 c0                	test   %eax,%eax
  80061e:	79 a3                	jns    8005c3 <dup+0x74>
	sys_page_unmap(0, newfd);
  800620:	83 ec 08             	sub    $0x8,%esp
  800623:	56                   	push   %esi
  800624:	6a 00                	push   $0x0
  800626:	e8 bd fb ff ff       	call   8001e8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80062b:	83 c4 08             	add    $0x8,%esp
  80062e:	57                   	push   %edi
  80062f:	6a 00                	push   $0x0
  800631:	e8 b2 fb ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  800636:	83 c4 10             	add    $0x10,%esp
  800639:	eb b7                	jmp    8005f2 <dup+0xa3>

0080063b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80063b:	55                   	push   %ebp
  80063c:	89 e5                	mov    %esp,%ebp
  80063e:	53                   	push   %ebx
  80063f:	83 ec 14             	sub    $0x14,%esp
  800642:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800645:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800648:	50                   	push   %eax
  800649:	53                   	push   %ebx
  80064a:	e8 7b fd ff ff       	call   8003ca <fd_lookup>
  80064f:	83 c4 08             	add    $0x8,%esp
  800652:	85 c0                	test   %eax,%eax
  800654:	78 3f                	js     800695 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800656:	83 ec 08             	sub    $0x8,%esp
  800659:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80065c:	50                   	push   %eax
  80065d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800660:	ff 30                	pushl  (%eax)
  800662:	e8 b9 fd ff ff       	call   800420 <dev_lookup>
  800667:	83 c4 10             	add    $0x10,%esp
  80066a:	85 c0                	test   %eax,%eax
  80066c:	78 27                	js     800695 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80066e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800671:	8b 42 08             	mov    0x8(%edx),%eax
  800674:	83 e0 03             	and    $0x3,%eax
  800677:	83 f8 01             	cmp    $0x1,%eax
  80067a:	74 1e                	je     80069a <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80067c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80067f:	8b 40 08             	mov    0x8(%eax),%eax
  800682:	85 c0                	test   %eax,%eax
  800684:	74 35                	je     8006bb <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800686:	83 ec 04             	sub    $0x4,%esp
  800689:	ff 75 10             	pushl  0x10(%ebp)
  80068c:	ff 75 0c             	pushl  0xc(%ebp)
  80068f:	52                   	push   %edx
  800690:	ff d0                	call   *%eax
  800692:	83 c4 10             	add    $0x10,%esp
}
  800695:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800698:	c9                   	leave  
  800699:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80069a:	a1 04 40 80 00       	mov    0x804004,%eax
  80069f:	8b 40 48             	mov    0x48(%eax),%eax
  8006a2:	83 ec 04             	sub    $0x4,%esp
  8006a5:	53                   	push   %ebx
  8006a6:	50                   	push   %eax
  8006a7:	68 59 1e 80 00       	push   $0x801e59
  8006ac:	e8 39 0a 00 00       	call   8010ea <cprintf>
		return -E_INVAL;
  8006b1:	83 c4 10             	add    $0x10,%esp
  8006b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006b9:	eb da                	jmp    800695 <read+0x5a>
		return -E_NOT_SUPP;
  8006bb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006c0:	eb d3                	jmp    800695 <read+0x5a>

008006c2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c2:	55                   	push   %ebp
  8006c3:	89 e5                	mov    %esp,%ebp
  8006c5:	57                   	push   %edi
  8006c6:	56                   	push   %esi
  8006c7:	53                   	push   %ebx
  8006c8:	83 ec 0c             	sub    $0xc,%esp
  8006cb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006ce:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d6:	39 f3                	cmp    %esi,%ebx
  8006d8:	73 25                	jae    8006ff <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006da:	83 ec 04             	sub    $0x4,%esp
  8006dd:	89 f0                	mov    %esi,%eax
  8006df:	29 d8                	sub    %ebx,%eax
  8006e1:	50                   	push   %eax
  8006e2:	89 d8                	mov    %ebx,%eax
  8006e4:	03 45 0c             	add    0xc(%ebp),%eax
  8006e7:	50                   	push   %eax
  8006e8:	57                   	push   %edi
  8006e9:	e8 4d ff ff ff       	call   80063b <read>
		if (m < 0)
  8006ee:	83 c4 10             	add    $0x10,%esp
  8006f1:	85 c0                	test   %eax,%eax
  8006f3:	78 08                	js     8006fd <readn+0x3b>
			return m;
		if (m == 0)
  8006f5:	85 c0                	test   %eax,%eax
  8006f7:	74 06                	je     8006ff <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  8006f9:	01 c3                	add    %eax,%ebx
  8006fb:	eb d9                	jmp    8006d6 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006fd:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006ff:	89 d8                	mov    %ebx,%eax
  800701:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800704:	5b                   	pop    %ebx
  800705:	5e                   	pop    %esi
  800706:	5f                   	pop    %edi
  800707:	5d                   	pop    %ebp
  800708:	c3                   	ret    

00800709 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800709:	55                   	push   %ebp
  80070a:	89 e5                	mov    %esp,%ebp
  80070c:	53                   	push   %ebx
  80070d:	83 ec 14             	sub    $0x14,%esp
  800710:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800713:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800716:	50                   	push   %eax
  800717:	53                   	push   %ebx
  800718:	e8 ad fc ff ff       	call   8003ca <fd_lookup>
  80071d:	83 c4 08             	add    $0x8,%esp
  800720:	85 c0                	test   %eax,%eax
  800722:	78 3a                	js     80075e <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800724:	83 ec 08             	sub    $0x8,%esp
  800727:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80072a:	50                   	push   %eax
  80072b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80072e:	ff 30                	pushl  (%eax)
  800730:	e8 eb fc ff ff       	call   800420 <dev_lookup>
  800735:	83 c4 10             	add    $0x10,%esp
  800738:	85 c0                	test   %eax,%eax
  80073a:	78 22                	js     80075e <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80073c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80073f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800743:	74 1e                	je     800763 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800745:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800748:	8b 52 0c             	mov    0xc(%edx),%edx
  80074b:	85 d2                	test   %edx,%edx
  80074d:	74 35                	je     800784 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80074f:	83 ec 04             	sub    $0x4,%esp
  800752:	ff 75 10             	pushl  0x10(%ebp)
  800755:	ff 75 0c             	pushl  0xc(%ebp)
  800758:	50                   	push   %eax
  800759:	ff d2                	call   *%edx
  80075b:	83 c4 10             	add    $0x10,%esp
}
  80075e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800761:	c9                   	leave  
  800762:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800763:	a1 04 40 80 00       	mov    0x804004,%eax
  800768:	8b 40 48             	mov    0x48(%eax),%eax
  80076b:	83 ec 04             	sub    $0x4,%esp
  80076e:	53                   	push   %ebx
  80076f:	50                   	push   %eax
  800770:	68 75 1e 80 00       	push   $0x801e75
  800775:	e8 70 09 00 00       	call   8010ea <cprintf>
		return -E_INVAL;
  80077a:	83 c4 10             	add    $0x10,%esp
  80077d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800782:	eb da                	jmp    80075e <write+0x55>
		return -E_NOT_SUPP;
  800784:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800789:	eb d3                	jmp    80075e <write+0x55>

0080078b <seek>:

int
seek(int fdnum, off_t offset)
{
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800791:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800794:	50                   	push   %eax
  800795:	ff 75 08             	pushl  0x8(%ebp)
  800798:	e8 2d fc ff ff       	call   8003ca <fd_lookup>
  80079d:	83 c4 08             	add    $0x8,%esp
  8007a0:	85 c0                	test   %eax,%eax
  8007a2:	78 0e                	js     8007b2 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007aa:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b2:	c9                   	leave  
  8007b3:	c3                   	ret    

008007b4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	53                   	push   %ebx
  8007b8:	83 ec 14             	sub    $0x14,%esp
  8007bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007c1:	50                   	push   %eax
  8007c2:	53                   	push   %ebx
  8007c3:	e8 02 fc ff ff       	call   8003ca <fd_lookup>
  8007c8:	83 c4 08             	add    $0x8,%esp
  8007cb:	85 c0                	test   %eax,%eax
  8007cd:	78 37                	js     800806 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007cf:	83 ec 08             	sub    $0x8,%esp
  8007d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d5:	50                   	push   %eax
  8007d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d9:	ff 30                	pushl  (%eax)
  8007db:	e8 40 fc ff ff       	call   800420 <dev_lookup>
  8007e0:	83 c4 10             	add    $0x10,%esp
  8007e3:	85 c0                	test   %eax,%eax
  8007e5:	78 1f                	js     800806 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ea:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007ee:	74 1b                	je     80080b <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007f3:	8b 52 18             	mov    0x18(%edx),%edx
  8007f6:	85 d2                	test   %edx,%edx
  8007f8:	74 32                	je     80082c <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007fa:	83 ec 08             	sub    $0x8,%esp
  8007fd:	ff 75 0c             	pushl  0xc(%ebp)
  800800:	50                   	push   %eax
  800801:	ff d2                	call   *%edx
  800803:	83 c4 10             	add    $0x10,%esp
}
  800806:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800809:	c9                   	leave  
  80080a:	c3                   	ret    
			thisenv->env_id, fdnum);
  80080b:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800810:	8b 40 48             	mov    0x48(%eax),%eax
  800813:	83 ec 04             	sub    $0x4,%esp
  800816:	53                   	push   %ebx
  800817:	50                   	push   %eax
  800818:	68 38 1e 80 00       	push   $0x801e38
  80081d:	e8 c8 08 00 00       	call   8010ea <cprintf>
		return -E_INVAL;
  800822:	83 c4 10             	add    $0x10,%esp
  800825:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80082a:	eb da                	jmp    800806 <ftruncate+0x52>
		return -E_NOT_SUPP;
  80082c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800831:	eb d3                	jmp    800806 <ftruncate+0x52>

00800833 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	53                   	push   %ebx
  800837:	83 ec 14             	sub    $0x14,%esp
  80083a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80083d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800840:	50                   	push   %eax
  800841:	ff 75 08             	pushl  0x8(%ebp)
  800844:	e8 81 fb ff ff       	call   8003ca <fd_lookup>
  800849:	83 c4 08             	add    $0x8,%esp
  80084c:	85 c0                	test   %eax,%eax
  80084e:	78 4b                	js     80089b <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800850:	83 ec 08             	sub    $0x8,%esp
  800853:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800856:	50                   	push   %eax
  800857:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80085a:	ff 30                	pushl  (%eax)
  80085c:	e8 bf fb ff ff       	call   800420 <dev_lookup>
  800861:	83 c4 10             	add    $0x10,%esp
  800864:	85 c0                	test   %eax,%eax
  800866:	78 33                	js     80089b <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  800868:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80086b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80086f:	74 2f                	je     8008a0 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800871:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800874:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80087b:	00 00 00 
	stat->st_isdir = 0;
  80087e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800885:	00 00 00 
	stat->st_dev = dev;
  800888:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80088e:	83 ec 08             	sub    $0x8,%esp
  800891:	53                   	push   %ebx
  800892:	ff 75 f0             	pushl  -0x10(%ebp)
  800895:	ff 50 14             	call   *0x14(%eax)
  800898:	83 c4 10             	add    $0x10,%esp
}
  80089b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80089e:	c9                   	leave  
  80089f:	c3                   	ret    
		return -E_NOT_SUPP;
  8008a0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008a5:	eb f4                	jmp    80089b <fstat+0x68>

008008a7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	56                   	push   %esi
  8008ab:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008ac:	83 ec 08             	sub    $0x8,%esp
  8008af:	6a 00                	push   $0x0
  8008b1:	ff 75 08             	pushl  0x8(%ebp)
  8008b4:	e8 e7 01 00 00       	call   800aa0 <open>
  8008b9:	89 c3                	mov    %eax,%ebx
  8008bb:	83 c4 10             	add    $0x10,%esp
  8008be:	85 c0                	test   %eax,%eax
  8008c0:	78 1b                	js     8008dd <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008c2:	83 ec 08             	sub    $0x8,%esp
  8008c5:	ff 75 0c             	pushl  0xc(%ebp)
  8008c8:	50                   	push   %eax
  8008c9:	e8 65 ff ff ff       	call   800833 <fstat>
  8008ce:	89 c6                	mov    %eax,%esi
	close(fd);
  8008d0:	89 1c 24             	mov    %ebx,(%esp)
  8008d3:	e8 27 fc ff ff       	call   8004ff <close>
	return r;
  8008d8:	83 c4 10             	add    $0x10,%esp
  8008db:	89 f3                	mov    %esi,%ebx
}
  8008dd:	89 d8                	mov    %ebx,%eax
  8008df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008e2:	5b                   	pop    %ebx
  8008e3:	5e                   	pop    %esi
  8008e4:	5d                   	pop    %ebp
  8008e5:	c3                   	ret    

008008e6 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	56                   	push   %esi
  8008ea:	53                   	push   %ebx
  8008eb:	89 c6                	mov    %eax,%esi
  8008ed:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008ef:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008f6:	74 27                	je     80091f <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008f8:	6a 07                	push   $0x7
  8008fa:	68 00 50 80 00       	push   $0x805000
  8008ff:	56                   	push   %esi
  800900:	ff 35 00 40 80 00    	pushl  0x804000
  800906:	e8 b0 11 00 00       	call   801abb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80090b:	83 c4 0c             	add    $0xc,%esp
  80090e:	6a 00                	push   $0x0
  800910:	53                   	push   %ebx
  800911:	6a 00                	push   $0x0
  800913:	e8 2e 11 00 00       	call   801a46 <ipc_recv>
}
  800918:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80091b:	5b                   	pop    %ebx
  80091c:	5e                   	pop    %esi
  80091d:	5d                   	pop    %ebp
  80091e:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80091f:	83 ec 0c             	sub    $0xc,%esp
  800922:	6a 01                	push   $0x1
  800924:	e8 e8 11 00 00       	call   801b11 <ipc_find_env>
  800929:	a3 00 40 80 00       	mov    %eax,0x804000
  80092e:	83 c4 10             	add    $0x10,%esp
  800931:	eb c5                	jmp    8008f8 <fsipc+0x12>

00800933 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800939:	8b 45 08             	mov    0x8(%ebp),%eax
  80093c:	8b 40 0c             	mov    0xc(%eax),%eax
  80093f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800944:	8b 45 0c             	mov    0xc(%ebp),%eax
  800947:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80094c:	ba 00 00 00 00       	mov    $0x0,%edx
  800951:	b8 02 00 00 00       	mov    $0x2,%eax
  800956:	e8 8b ff ff ff       	call   8008e6 <fsipc>
}
  80095b:	c9                   	leave  
  80095c:	c3                   	ret    

0080095d <devfile_flush>:
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800963:	8b 45 08             	mov    0x8(%ebp),%eax
  800966:	8b 40 0c             	mov    0xc(%eax),%eax
  800969:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80096e:	ba 00 00 00 00       	mov    $0x0,%edx
  800973:	b8 06 00 00 00       	mov    $0x6,%eax
  800978:	e8 69 ff ff ff       	call   8008e6 <fsipc>
}
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    

0080097f <devfile_stat>:
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	53                   	push   %ebx
  800983:	83 ec 04             	sub    $0x4,%esp
  800986:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	8b 40 0c             	mov    0xc(%eax),%eax
  80098f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800994:	ba 00 00 00 00       	mov    $0x0,%edx
  800999:	b8 05 00 00 00       	mov    $0x5,%eax
  80099e:	e8 43 ff ff ff       	call   8008e6 <fsipc>
  8009a3:	85 c0                	test   %eax,%eax
  8009a5:	78 2c                	js     8009d3 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009a7:	83 ec 08             	sub    $0x8,%esp
  8009aa:	68 00 50 80 00       	push   $0x805000
  8009af:	53                   	push   %ebx
  8009b0:	e8 54 0d 00 00       	call   801709 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009b5:	a1 80 50 80 00       	mov    0x805080,%eax
  8009ba:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009c0:	a1 84 50 80 00       	mov    0x805084,%eax
  8009c5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009cb:	83 c4 10             	add    $0x10,%esp
  8009ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009d6:	c9                   	leave  
  8009d7:	c3                   	ret    

008009d8 <devfile_write>:
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	83 ec 0c             	sub    $0xc,%esp
  8009de:	8b 45 10             	mov    0x10(%ebp),%eax
  8009e1:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009e6:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8009eb:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f1:	8b 52 0c             	mov    0xc(%edx),%edx
  8009f4:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8009fa:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf,buf,n);
  8009ff:	50                   	push   %eax
  800a00:	ff 75 0c             	pushl  0xc(%ebp)
  800a03:	68 08 50 80 00       	push   $0x805008
  800a08:	e8 8a 0e 00 00       	call   801897 <memmove>
	if((r = fsipc(FSREQ_WRITE,NULL))<0)
  800a0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a12:	b8 04 00 00 00       	mov    $0x4,%eax
  800a17:	e8 ca fe ff ff       	call   8008e6 <fsipc>
}
  800a1c:	c9                   	leave  
  800a1d:	c3                   	ret    

00800a1e <devfile_read>:
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	56                   	push   %esi
  800a22:	53                   	push   %ebx
  800a23:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a26:	8b 45 08             	mov    0x8(%ebp),%eax
  800a29:	8b 40 0c             	mov    0xc(%eax),%eax
  800a2c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a31:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a37:	ba 00 00 00 00       	mov    $0x0,%edx
  800a3c:	b8 03 00 00 00       	mov    $0x3,%eax
  800a41:	e8 a0 fe ff ff       	call   8008e6 <fsipc>
  800a46:	89 c3                	mov    %eax,%ebx
  800a48:	85 c0                	test   %eax,%eax
  800a4a:	78 1f                	js     800a6b <devfile_read+0x4d>
	assert(r <= n);
  800a4c:	39 f0                	cmp    %esi,%eax
  800a4e:	77 24                	ja     800a74 <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a50:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a55:	7f 33                	jg     800a8a <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a57:	83 ec 04             	sub    $0x4,%esp
  800a5a:	50                   	push   %eax
  800a5b:	68 00 50 80 00       	push   $0x805000
  800a60:	ff 75 0c             	pushl  0xc(%ebp)
  800a63:	e8 2f 0e 00 00       	call   801897 <memmove>
	return r;
  800a68:	83 c4 10             	add    $0x10,%esp
}
  800a6b:	89 d8                	mov    %ebx,%eax
  800a6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a70:	5b                   	pop    %ebx
  800a71:	5e                   	pop    %esi
  800a72:	5d                   	pop    %ebp
  800a73:	c3                   	ret    
	assert(r <= n);
  800a74:	68 a4 1e 80 00       	push   $0x801ea4
  800a79:	68 ab 1e 80 00       	push   $0x801eab
  800a7e:	6a 7c                	push   $0x7c
  800a80:	68 c0 1e 80 00       	push   $0x801ec0
  800a85:	e8 85 05 00 00       	call   80100f <_panic>
	assert(r <= PGSIZE);
  800a8a:	68 cb 1e 80 00       	push   $0x801ecb
  800a8f:	68 ab 1e 80 00       	push   $0x801eab
  800a94:	6a 7d                	push   $0x7d
  800a96:	68 c0 1e 80 00       	push   $0x801ec0
  800a9b:	e8 6f 05 00 00       	call   80100f <_panic>

00800aa0 <open>:
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	56                   	push   %esi
  800aa4:	53                   	push   %ebx
  800aa5:	83 ec 1c             	sub    $0x1c,%esp
  800aa8:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800aab:	56                   	push   %esi
  800aac:	e8 21 0c 00 00       	call   8016d2 <strlen>
  800ab1:	83 c4 10             	add    $0x10,%esp
  800ab4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ab9:	7f 6c                	jg     800b27 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800abb:	83 ec 0c             	sub    $0xc,%esp
  800abe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ac1:	50                   	push   %eax
  800ac2:	e8 b4 f8 ff ff       	call   80037b <fd_alloc>
  800ac7:	89 c3                	mov    %eax,%ebx
  800ac9:	83 c4 10             	add    $0x10,%esp
  800acc:	85 c0                	test   %eax,%eax
  800ace:	78 3c                	js     800b0c <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800ad0:	83 ec 08             	sub    $0x8,%esp
  800ad3:	56                   	push   %esi
  800ad4:	68 00 50 80 00       	push   $0x805000
  800ad9:	e8 2b 0c 00 00       	call   801709 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ade:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae1:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ae6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ae9:	b8 01 00 00 00       	mov    $0x1,%eax
  800aee:	e8 f3 fd ff ff       	call   8008e6 <fsipc>
  800af3:	89 c3                	mov    %eax,%ebx
  800af5:	83 c4 10             	add    $0x10,%esp
  800af8:	85 c0                	test   %eax,%eax
  800afa:	78 19                	js     800b15 <open+0x75>
	return fd2num(fd);
  800afc:	83 ec 0c             	sub    $0xc,%esp
  800aff:	ff 75 f4             	pushl  -0xc(%ebp)
  800b02:	e8 4d f8 ff ff       	call   800354 <fd2num>
  800b07:	89 c3                	mov    %eax,%ebx
  800b09:	83 c4 10             	add    $0x10,%esp
}
  800b0c:	89 d8                	mov    %ebx,%eax
  800b0e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b11:	5b                   	pop    %ebx
  800b12:	5e                   	pop    %esi
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    
		fd_close(fd, 0);
  800b15:	83 ec 08             	sub    $0x8,%esp
  800b18:	6a 00                	push   $0x0
  800b1a:	ff 75 f4             	pushl  -0xc(%ebp)
  800b1d:	e8 54 f9 ff ff       	call   800476 <fd_close>
		return r;
  800b22:	83 c4 10             	add    $0x10,%esp
  800b25:	eb e5                	jmp    800b0c <open+0x6c>
		return -E_BAD_PATH;
  800b27:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b2c:	eb de                	jmp    800b0c <open+0x6c>

00800b2e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b34:	ba 00 00 00 00       	mov    $0x0,%edx
  800b39:	b8 08 00 00 00       	mov    $0x8,%eax
  800b3e:	e8 a3 fd ff ff       	call   8008e6 <fsipc>
}
  800b43:	c9                   	leave  
  800b44:	c3                   	ret    

00800b45 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	56                   	push   %esi
  800b49:	53                   	push   %ebx
  800b4a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b4d:	83 ec 0c             	sub    $0xc,%esp
  800b50:	ff 75 08             	pushl  0x8(%ebp)
  800b53:	e8 0c f8 ff ff       	call   800364 <fd2data>
  800b58:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b5a:	83 c4 08             	add    $0x8,%esp
  800b5d:	68 d7 1e 80 00       	push   $0x801ed7
  800b62:	53                   	push   %ebx
  800b63:	e8 a1 0b 00 00       	call   801709 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b68:	8b 46 04             	mov    0x4(%esi),%eax
  800b6b:	2b 06                	sub    (%esi),%eax
  800b6d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b73:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b7a:	00 00 00 
	stat->st_dev = &devpipe;
  800b7d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b84:	30 80 00 
	return 0;
}
  800b87:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b8f:	5b                   	pop    %ebx
  800b90:	5e                   	pop    %esi
  800b91:	5d                   	pop    %ebp
  800b92:	c3                   	ret    

00800b93 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b93:	55                   	push   %ebp
  800b94:	89 e5                	mov    %esp,%ebp
  800b96:	53                   	push   %ebx
  800b97:	83 ec 0c             	sub    $0xc,%esp
  800b9a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b9d:	53                   	push   %ebx
  800b9e:	6a 00                	push   $0x0
  800ba0:	e8 43 f6 ff ff       	call   8001e8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800ba5:	89 1c 24             	mov    %ebx,(%esp)
  800ba8:	e8 b7 f7 ff ff       	call   800364 <fd2data>
  800bad:	83 c4 08             	add    $0x8,%esp
  800bb0:	50                   	push   %eax
  800bb1:	6a 00                	push   $0x0
  800bb3:	e8 30 f6 ff ff       	call   8001e8 <sys_page_unmap>
}
  800bb8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bbb:	c9                   	leave  
  800bbc:	c3                   	ret    

00800bbd <_pipeisclosed>:
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	57                   	push   %edi
  800bc1:	56                   	push   %esi
  800bc2:	53                   	push   %ebx
  800bc3:	83 ec 1c             	sub    $0x1c,%esp
  800bc6:	89 c7                	mov    %eax,%edi
  800bc8:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800bca:	a1 04 40 80 00       	mov    0x804004,%eax
  800bcf:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800bd2:	83 ec 0c             	sub    $0xc,%esp
  800bd5:	57                   	push   %edi
  800bd6:	e8 6f 0f 00 00       	call   801b4a <pageref>
  800bdb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800bde:	89 34 24             	mov    %esi,(%esp)
  800be1:	e8 64 0f 00 00       	call   801b4a <pageref>
		nn = thisenv->env_runs;
  800be6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bec:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bef:	83 c4 10             	add    $0x10,%esp
  800bf2:	39 cb                	cmp    %ecx,%ebx
  800bf4:	74 1b                	je     800c11 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800bf6:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800bf9:	75 cf                	jne    800bca <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800bfb:	8b 42 58             	mov    0x58(%edx),%eax
  800bfe:	6a 01                	push   $0x1
  800c00:	50                   	push   %eax
  800c01:	53                   	push   %ebx
  800c02:	68 de 1e 80 00       	push   $0x801ede
  800c07:	e8 de 04 00 00       	call   8010ea <cprintf>
  800c0c:	83 c4 10             	add    $0x10,%esp
  800c0f:	eb b9                	jmp    800bca <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c11:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c14:	0f 94 c0             	sete   %al
  800c17:	0f b6 c0             	movzbl %al,%eax
}
  800c1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1d:	5b                   	pop    %ebx
  800c1e:	5e                   	pop    %esi
  800c1f:	5f                   	pop    %edi
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    

00800c22 <devpipe_write>:
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	57                   	push   %edi
  800c26:	56                   	push   %esi
  800c27:	53                   	push   %ebx
  800c28:	83 ec 28             	sub    $0x28,%esp
  800c2b:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c2e:	56                   	push   %esi
  800c2f:	e8 30 f7 ff ff       	call   800364 <fd2data>
  800c34:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c36:	83 c4 10             	add    $0x10,%esp
  800c39:	bf 00 00 00 00       	mov    $0x0,%edi
  800c3e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c41:	74 4f                	je     800c92 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c43:	8b 43 04             	mov    0x4(%ebx),%eax
  800c46:	8b 0b                	mov    (%ebx),%ecx
  800c48:	8d 51 20             	lea    0x20(%ecx),%edx
  800c4b:	39 d0                	cmp    %edx,%eax
  800c4d:	72 14                	jb     800c63 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  800c4f:	89 da                	mov    %ebx,%edx
  800c51:	89 f0                	mov    %esi,%eax
  800c53:	e8 65 ff ff ff       	call   800bbd <_pipeisclosed>
  800c58:	85 c0                	test   %eax,%eax
  800c5a:	75 3a                	jne    800c96 <devpipe_write+0x74>
			sys_yield();
  800c5c:	e8 e3 f4 ff ff       	call   800144 <sys_yield>
  800c61:	eb e0                	jmp    800c43 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c66:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c6a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c6d:	89 c2                	mov    %eax,%edx
  800c6f:	c1 fa 1f             	sar    $0x1f,%edx
  800c72:	89 d1                	mov    %edx,%ecx
  800c74:	c1 e9 1b             	shr    $0x1b,%ecx
  800c77:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c7a:	83 e2 1f             	and    $0x1f,%edx
  800c7d:	29 ca                	sub    %ecx,%edx
  800c7f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c83:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c87:	83 c0 01             	add    $0x1,%eax
  800c8a:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800c8d:	83 c7 01             	add    $0x1,%edi
  800c90:	eb ac                	jmp    800c3e <devpipe_write+0x1c>
	return i;
  800c92:	89 f8                	mov    %edi,%eax
  800c94:	eb 05                	jmp    800c9b <devpipe_write+0x79>
				return 0;
  800c96:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9e:	5b                   	pop    %ebx
  800c9f:	5e                   	pop    %esi
  800ca0:	5f                   	pop    %edi
  800ca1:	5d                   	pop    %ebp
  800ca2:	c3                   	ret    

00800ca3 <devpipe_read>:
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	57                   	push   %edi
  800ca7:	56                   	push   %esi
  800ca8:	53                   	push   %ebx
  800ca9:	83 ec 18             	sub    $0x18,%esp
  800cac:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800caf:	57                   	push   %edi
  800cb0:	e8 af f6 ff ff       	call   800364 <fd2data>
  800cb5:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800cb7:	83 c4 10             	add    $0x10,%esp
  800cba:	be 00 00 00 00       	mov    $0x0,%esi
  800cbf:	3b 75 10             	cmp    0x10(%ebp),%esi
  800cc2:	74 47                	je     800d0b <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  800cc4:	8b 03                	mov    (%ebx),%eax
  800cc6:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cc9:	75 22                	jne    800ced <devpipe_read+0x4a>
			if (i > 0)
  800ccb:	85 f6                	test   %esi,%esi
  800ccd:	75 14                	jne    800ce3 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  800ccf:	89 da                	mov    %ebx,%edx
  800cd1:	89 f8                	mov    %edi,%eax
  800cd3:	e8 e5 fe ff ff       	call   800bbd <_pipeisclosed>
  800cd8:	85 c0                	test   %eax,%eax
  800cda:	75 33                	jne    800d0f <devpipe_read+0x6c>
			sys_yield();
  800cdc:	e8 63 f4 ff ff       	call   800144 <sys_yield>
  800ce1:	eb e1                	jmp    800cc4 <devpipe_read+0x21>
				return i;
  800ce3:	89 f0                	mov    %esi,%eax
}
  800ce5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce8:	5b                   	pop    %ebx
  800ce9:	5e                   	pop    %esi
  800cea:	5f                   	pop    %edi
  800ceb:	5d                   	pop    %ebp
  800cec:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800ced:	99                   	cltd   
  800cee:	c1 ea 1b             	shr    $0x1b,%edx
  800cf1:	01 d0                	add    %edx,%eax
  800cf3:	83 e0 1f             	and    $0x1f,%eax
  800cf6:	29 d0                	sub    %edx,%eax
  800cf8:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800cfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d00:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d03:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d06:	83 c6 01             	add    $0x1,%esi
  800d09:	eb b4                	jmp    800cbf <devpipe_read+0x1c>
	return i;
  800d0b:	89 f0                	mov    %esi,%eax
  800d0d:	eb d6                	jmp    800ce5 <devpipe_read+0x42>
				return 0;
  800d0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d14:	eb cf                	jmp    800ce5 <devpipe_read+0x42>

00800d16 <pipe>:
{
  800d16:	55                   	push   %ebp
  800d17:	89 e5                	mov    %esp,%ebp
  800d19:	56                   	push   %esi
  800d1a:	53                   	push   %ebx
  800d1b:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d1e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d21:	50                   	push   %eax
  800d22:	e8 54 f6 ff ff       	call   80037b <fd_alloc>
  800d27:	89 c3                	mov    %eax,%ebx
  800d29:	83 c4 10             	add    $0x10,%esp
  800d2c:	85 c0                	test   %eax,%eax
  800d2e:	78 5b                	js     800d8b <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d30:	83 ec 04             	sub    $0x4,%esp
  800d33:	68 07 04 00 00       	push   $0x407
  800d38:	ff 75 f4             	pushl  -0xc(%ebp)
  800d3b:	6a 00                	push   $0x0
  800d3d:	e8 21 f4 ff ff       	call   800163 <sys_page_alloc>
  800d42:	89 c3                	mov    %eax,%ebx
  800d44:	83 c4 10             	add    $0x10,%esp
  800d47:	85 c0                	test   %eax,%eax
  800d49:	78 40                	js     800d8b <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  800d4b:	83 ec 0c             	sub    $0xc,%esp
  800d4e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d51:	50                   	push   %eax
  800d52:	e8 24 f6 ff ff       	call   80037b <fd_alloc>
  800d57:	89 c3                	mov    %eax,%ebx
  800d59:	83 c4 10             	add    $0x10,%esp
  800d5c:	85 c0                	test   %eax,%eax
  800d5e:	78 1b                	js     800d7b <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d60:	83 ec 04             	sub    $0x4,%esp
  800d63:	68 07 04 00 00       	push   $0x407
  800d68:	ff 75 f0             	pushl  -0x10(%ebp)
  800d6b:	6a 00                	push   $0x0
  800d6d:	e8 f1 f3 ff ff       	call   800163 <sys_page_alloc>
  800d72:	89 c3                	mov    %eax,%ebx
  800d74:	83 c4 10             	add    $0x10,%esp
  800d77:	85 c0                	test   %eax,%eax
  800d79:	79 19                	jns    800d94 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  800d7b:	83 ec 08             	sub    $0x8,%esp
  800d7e:	ff 75 f4             	pushl  -0xc(%ebp)
  800d81:	6a 00                	push   $0x0
  800d83:	e8 60 f4 ff ff       	call   8001e8 <sys_page_unmap>
  800d88:	83 c4 10             	add    $0x10,%esp
}
  800d8b:	89 d8                	mov    %ebx,%eax
  800d8d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d90:	5b                   	pop    %ebx
  800d91:	5e                   	pop    %esi
  800d92:	5d                   	pop    %ebp
  800d93:	c3                   	ret    
	va = fd2data(fd0);
  800d94:	83 ec 0c             	sub    $0xc,%esp
  800d97:	ff 75 f4             	pushl  -0xc(%ebp)
  800d9a:	e8 c5 f5 ff ff       	call   800364 <fd2data>
  800d9f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da1:	83 c4 0c             	add    $0xc,%esp
  800da4:	68 07 04 00 00       	push   $0x407
  800da9:	50                   	push   %eax
  800daa:	6a 00                	push   $0x0
  800dac:	e8 b2 f3 ff ff       	call   800163 <sys_page_alloc>
  800db1:	89 c3                	mov    %eax,%ebx
  800db3:	83 c4 10             	add    $0x10,%esp
  800db6:	85 c0                	test   %eax,%eax
  800db8:	0f 88 8c 00 00 00    	js     800e4a <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dbe:	83 ec 0c             	sub    $0xc,%esp
  800dc1:	ff 75 f0             	pushl  -0x10(%ebp)
  800dc4:	e8 9b f5 ff ff       	call   800364 <fd2data>
  800dc9:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dd0:	50                   	push   %eax
  800dd1:	6a 00                	push   $0x0
  800dd3:	56                   	push   %esi
  800dd4:	6a 00                	push   $0x0
  800dd6:	e8 cb f3 ff ff       	call   8001a6 <sys_page_map>
  800ddb:	89 c3                	mov    %eax,%ebx
  800ddd:	83 c4 20             	add    $0x20,%esp
  800de0:	85 c0                	test   %eax,%eax
  800de2:	78 58                	js     800e3c <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  800de4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800de7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800ded:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800def:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800df2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  800df9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dfc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e02:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e04:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e07:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e0e:	83 ec 0c             	sub    $0xc,%esp
  800e11:	ff 75 f4             	pushl  -0xc(%ebp)
  800e14:	e8 3b f5 ff ff       	call   800354 <fd2num>
  800e19:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e1c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e1e:	83 c4 04             	add    $0x4,%esp
  800e21:	ff 75 f0             	pushl  -0x10(%ebp)
  800e24:	e8 2b f5 ff ff       	call   800354 <fd2num>
  800e29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e2c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e2f:	83 c4 10             	add    $0x10,%esp
  800e32:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e37:	e9 4f ff ff ff       	jmp    800d8b <pipe+0x75>
	sys_page_unmap(0, va);
  800e3c:	83 ec 08             	sub    $0x8,%esp
  800e3f:	56                   	push   %esi
  800e40:	6a 00                	push   $0x0
  800e42:	e8 a1 f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e47:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e4a:	83 ec 08             	sub    $0x8,%esp
  800e4d:	ff 75 f0             	pushl  -0x10(%ebp)
  800e50:	6a 00                	push   $0x0
  800e52:	e8 91 f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e57:	83 c4 10             	add    $0x10,%esp
  800e5a:	e9 1c ff ff ff       	jmp    800d7b <pipe+0x65>

00800e5f <pipeisclosed>:
{
  800e5f:	55                   	push   %ebp
  800e60:	89 e5                	mov    %esp,%ebp
  800e62:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e65:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e68:	50                   	push   %eax
  800e69:	ff 75 08             	pushl  0x8(%ebp)
  800e6c:	e8 59 f5 ff ff       	call   8003ca <fd_lookup>
  800e71:	83 c4 10             	add    $0x10,%esp
  800e74:	85 c0                	test   %eax,%eax
  800e76:	78 18                	js     800e90 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  800e78:	83 ec 0c             	sub    $0xc,%esp
  800e7b:	ff 75 f4             	pushl  -0xc(%ebp)
  800e7e:	e8 e1 f4 ff ff       	call   800364 <fd2data>
	return _pipeisclosed(fd, p);
  800e83:	89 c2                	mov    %eax,%edx
  800e85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e88:	e8 30 fd ff ff       	call   800bbd <_pipeisclosed>
  800e8d:	83 c4 10             	add    $0x10,%esp
}
  800e90:	c9                   	leave  
  800e91:	c3                   	ret    

00800e92 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e92:	55                   	push   %ebp
  800e93:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e95:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    

00800e9c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ea2:	68 f6 1e 80 00       	push   $0x801ef6
  800ea7:	ff 75 0c             	pushl  0xc(%ebp)
  800eaa:	e8 5a 08 00 00       	call   801709 <strcpy>
	return 0;
}
  800eaf:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb4:	c9                   	leave  
  800eb5:	c3                   	ret    

00800eb6 <devcons_write>:
{
  800eb6:	55                   	push   %ebp
  800eb7:	89 e5                	mov    %esp,%ebp
  800eb9:	57                   	push   %edi
  800eba:	56                   	push   %esi
  800ebb:	53                   	push   %ebx
  800ebc:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800ec2:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800ec7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800ecd:	eb 2f                	jmp    800efe <devcons_write+0x48>
		m = n - tot;
  800ecf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ed2:	29 f3                	sub    %esi,%ebx
  800ed4:	83 fb 7f             	cmp    $0x7f,%ebx
  800ed7:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800edc:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800edf:	83 ec 04             	sub    $0x4,%esp
  800ee2:	53                   	push   %ebx
  800ee3:	89 f0                	mov    %esi,%eax
  800ee5:	03 45 0c             	add    0xc(%ebp),%eax
  800ee8:	50                   	push   %eax
  800ee9:	57                   	push   %edi
  800eea:	e8 a8 09 00 00       	call   801897 <memmove>
		sys_cputs(buf, m);
  800eef:	83 c4 08             	add    $0x8,%esp
  800ef2:	53                   	push   %ebx
  800ef3:	57                   	push   %edi
  800ef4:	e8 ae f1 ff ff       	call   8000a7 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800ef9:	01 de                	add    %ebx,%esi
  800efb:	83 c4 10             	add    $0x10,%esp
  800efe:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f01:	72 cc                	jb     800ecf <devcons_write+0x19>
}
  800f03:	89 f0                	mov    %esi,%eax
  800f05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f08:	5b                   	pop    %ebx
  800f09:	5e                   	pop    %esi
  800f0a:	5f                   	pop    %edi
  800f0b:	5d                   	pop    %ebp
  800f0c:	c3                   	ret    

00800f0d <devcons_read>:
{
  800f0d:	55                   	push   %ebp
  800f0e:	89 e5                	mov    %esp,%ebp
  800f10:	83 ec 08             	sub    $0x8,%esp
  800f13:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f18:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f1c:	75 07                	jne    800f25 <devcons_read+0x18>
}
  800f1e:	c9                   	leave  
  800f1f:	c3                   	ret    
		sys_yield();
  800f20:	e8 1f f2 ff ff       	call   800144 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  800f25:	e8 9b f1 ff ff       	call   8000c5 <sys_cgetc>
  800f2a:	85 c0                	test   %eax,%eax
  800f2c:	74 f2                	je     800f20 <devcons_read+0x13>
	if (c < 0)
  800f2e:	85 c0                	test   %eax,%eax
  800f30:	78 ec                	js     800f1e <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  800f32:	83 f8 04             	cmp    $0x4,%eax
  800f35:	74 0c                	je     800f43 <devcons_read+0x36>
	*(char*)vbuf = c;
  800f37:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f3a:	88 02                	mov    %al,(%edx)
	return 1;
  800f3c:	b8 01 00 00 00       	mov    $0x1,%eax
  800f41:	eb db                	jmp    800f1e <devcons_read+0x11>
		return 0;
  800f43:	b8 00 00 00 00       	mov    $0x0,%eax
  800f48:	eb d4                	jmp    800f1e <devcons_read+0x11>

00800f4a <cputchar>:
{
  800f4a:	55                   	push   %ebp
  800f4b:	89 e5                	mov    %esp,%ebp
  800f4d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f50:	8b 45 08             	mov    0x8(%ebp),%eax
  800f53:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800f56:	6a 01                	push   $0x1
  800f58:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f5b:	50                   	push   %eax
  800f5c:	e8 46 f1 ff ff       	call   8000a7 <sys_cputs>
}
  800f61:	83 c4 10             	add    $0x10,%esp
  800f64:	c9                   	leave  
  800f65:	c3                   	ret    

00800f66 <getchar>:
{
  800f66:	55                   	push   %ebp
  800f67:	89 e5                	mov    %esp,%ebp
  800f69:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800f6c:	6a 01                	push   $0x1
  800f6e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f71:	50                   	push   %eax
  800f72:	6a 00                	push   $0x0
  800f74:	e8 c2 f6 ff ff       	call   80063b <read>
	if (r < 0)
  800f79:	83 c4 10             	add    $0x10,%esp
  800f7c:	85 c0                	test   %eax,%eax
  800f7e:	78 08                	js     800f88 <getchar+0x22>
	if (r < 1)
  800f80:	85 c0                	test   %eax,%eax
  800f82:	7e 06                	jle    800f8a <getchar+0x24>
	return c;
  800f84:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800f88:	c9                   	leave  
  800f89:	c3                   	ret    
		return -E_EOF;
  800f8a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800f8f:	eb f7                	jmp    800f88 <getchar+0x22>

00800f91 <iscons>:
{
  800f91:	55                   	push   %ebp
  800f92:	89 e5                	mov    %esp,%ebp
  800f94:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f97:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f9a:	50                   	push   %eax
  800f9b:	ff 75 08             	pushl  0x8(%ebp)
  800f9e:	e8 27 f4 ff ff       	call   8003ca <fd_lookup>
  800fa3:	83 c4 10             	add    $0x10,%esp
  800fa6:	85 c0                	test   %eax,%eax
  800fa8:	78 11                	js     800fbb <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  800faa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fad:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fb3:	39 10                	cmp    %edx,(%eax)
  800fb5:	0f 94 c0             	sete   %al
  800fb8:	0f b6 c0             	movzbl %al,%eax
}
  800fbb:	c9                   	leave  
  800fbc:	c3                   	ret    

00800fbd <opencons>:
{
  800fbd:	55                   	push   %ebp
  800fbe:	89 e5                	mov    %esp,%ebp
  800fc0:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800fc3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc6:	50                   	push   %eax
  800fc7:	e8 af f3 ff ff       	call   80037b <fd_alloc>
  800fcc:	83 c4 10             	add    $0x10,%esp
  800fcf:	85 c0                	test   %eax,%eax
  800fd1:	78 3a                	js     80100d <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fd3:	83 ec 04             	sub    $0x4,%esp
  800fd6:	68 07 04 00 00       	push   $0x407
  800fdb:	ff 75 f4             	pushl  -0xc(%ebp)
  800fde:	6a 00                	push   $0x0
  800fe0:	e8 7e f1 ff ff       	call   800163 <sys_page_alloc>
  800fe5:	83 c4 10             	add    $0x10,%esp
  800fe8:	85 c0                	test   %eax,%eax
  800fea:	78 21                	js     80100d <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  800fec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fef:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800ff5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800ff7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ffa:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801001:	83 ec 0c             	sub    $0xc,%esp
  801004:	50                   	push   %eax
  801005:	e8 4a f3 ff ff       	call   800354 <fd2num>
  80100a:	83 c4 10             	add    $0x10,%esp
}
  80100d:	c9                   	leave  
  80100e:	c3                   	ret    

0080100f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80100f:	55                   	push   %ebp
  801010:	89 e5                	mov    %esp,%ebp
  801012:	56                   	push   %esi
  801013:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801014:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801017:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80101d:	e8 03 f1 ff ff       	call   800125 <sys_getenvid>
  801022:	83 ec 0c             	sub    $0xc,%esp
  801025:	ff 75 0c             	pushl  0xc(%ebp)
  801028:	ff 75 08             	pushl  0x8(%ebp)
  80102b:	56                   	push   %esi
  80102c:	50                   	push   %eax
  80102d:	68 04 1f 80 00       	push   $0x801f04
  801032:	e8 b3 00 00 00       	call   8010ea <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801037:	83 c4 18             	add    $0x18,%esp
  80103a:	53                   	push   %ebx
  80103b:	ff 75 10             	pushl  0x10(%ebp)
  80103e:	e8 56 00 00 00       	call   801099 <vcprintf>
	cprintf("\n");
  801043:	c7 04 24 ef 1e 80 00 	movl   $0x801eef,(%esp)
  80104a:	e8 9b 00 00 00       	call   8010ea <cprintf>
  80104f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801052:	cc                   	int3   
  801053:	eb fd                	jmp    801052 <_panic+0x43>

00801055 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801055:	55                   	push   %ebp
  801056:	89 e5                	mov    %esp,%ebp
  801058:	53                   	push   %ebx
  801059:	83 ec 04             	sub    $0x4,%esp
  80105c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80105f:	8b 13                	mov    (%ebx),%edx
  801061:	8d 42 01             	lea    0x1(%edx),%eax
  801064:	89 03                	mov    %eax,(%ebx)
  801066:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801069:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80106d:	3d ff 00 00 00       	cmp    $0xff,%eax
  801072:	74 09                	je     80107d <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801074:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801078:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80107b:	c9                   	leave  
  80107c:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80107d:	83 ec 08             	sub    $0x8,%esp
  801080:	68 ff 00 00 00       	push   $0xff
  801085:	8d 43 08             	lea    0x8(%ebx),%eax
  801088:	50                   	push   %eax
  801089:	e8 19 f0 ff ff       	call   8000a7 <sys_cputs>
		b->idx = 0;
  80108e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801094:	83 c4 10             	add    $0x10,%esp
  801097:	eb db                	jmp    801074 <putch+0x1f>

00801099 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801099:	55                   	push   %ebp
  80109a:	89 e5                	mov    %esp,%ebp
  80109c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010a2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010a9:	00 00 00 
	b.cnt = 0;
  8010ac:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010b3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010b6:	ff 75 0c             	pushl  0xc(%ebp)
  8010b9:	ff 75 08             	pushl  0x8(%ebp)
  8010bc:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010c2:	50                   	push   %eax
  8010c3:	68 55 10 80 00       	push   $0x801055
  8010c8:	e8 1a 01 00 00       	call   8011e7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010cd:	83 c4 08             	add    $0x8,%esp
  8010d0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010d6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010dc:	50                   	push   %eax
  8010dd:	e8 c5 ef ff ff       	call   8000a7 <sys_cputs>

	return b.cnt;
}
  8010e2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010e8:	c9                   	leave  
  8010e9:	c3                   	ret    

008010ea <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010ea:	55                   	push   %ebp
  8010eb:	89 e5                	mov    %esp,%ebp
  8010ed:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010f0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010f3:	50                   	push   %eax
  8010f4:	ff 75 08             	pushl  0x8(%ebp)
  8010f7:	e8 9d ff ff ff       	call   801099 <vcprintf>
	va_end(ap);

	return cnt;
}
  8010fc:	c9                   	leave  
  8010fd:	c3                   	ret    

008010fe <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010fe:	55                   	push   %ebp
  8010ff:	89 e5                	mov    %esp,%ebp
  801101:	57                   	push   %edi
  801102:	56                   	push   %esi
  801103:	53                   	push   %ebx
  801104:	83 ec 1c             	sub    $0x1c,%esp
  801107:	89 c7                	mov    %eax,%edi
  801109:	89 d6                	mov    %edx,%esi
  80110b:	8b 45 08             	mov    0x8(%ebp),%eax
  80110e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801111:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801114:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801117:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80111a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80111f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801122:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801125:	39 d3                	cmp    %edx,%ebx
  801127:	72 05                	jb     80112e <printnum+0x30>
  801129:	39 45 10             	cmp    %eax,0x10(%ebp)
  80112c:	77 7a                	ja     8011a8 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80112e:	83 ec 0c             	sub    $0xc,%esp
  801131:	ff 75 18             	pushl  0x18(%ebp)
  801134:	8b 45 14             	mov    0x14(%ebp),%eax
  801137:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80113a:	53                   	push   %ebx
  80113b:	ff 75 10             	pushl  0x10(%ebp)
  80113e:	83 ec 08             	sub    $0x8,%esp
  801141:	ff 75 e4             	pushl  -0x1c(%ebp)
  801144:	ff 75 e0             	pushl  -0x20(%ebp)
  801147:	ff 75 dc             	pushl  -0x24(%ebp)
  80114a:	ff 75 d8             	pushl  -0x28(%ebp)
  80114d:	e8 3e 0a 00 00       	call   801b90 <__udivdi3>
  801152:	83 c4 18             	add    $0x18,%esp
  801155:	52                   	push   %edx
  801156:	50                   	push   %eax
  801157:	89 f2                	mov    %esi,%edx
  801159:	89 f8                	mov    %edi,%eax
  80115b:	e8 9e ff ff ff       	call   8010fe <printnum>
  801160:	83 c4 20             	add    $0x20,%esp
  801163:	eb 13                	jmp    801178 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801165:	83 ec 08             	sub    $0x8,%esp
  801168:	56                   	push   %esi
  801169:	ff 75 18             	pushl  0x18(%ebp)
  80116c:	ff d7                	call   *%edi
  80116e:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801171:	83 eb 01             	sub    $0x1,%ebx
  801174:	85 db                	test   %ebx,%ebx
  801176:	7f ed                	jg     801165 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801178:	83 ec 08             	sub    $0x8,%esp
  80117b:	56                   	push   %esi
  80117c:	83 ec 04             	sub    $0x4,%esp
  80117f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801182:	ff 75 e0             	pushl  -0x20(%ebp)
  801185:	ff 75 dc             	pushl  -0x24(%ebp)
  801188:	ff 75 d8             	pushl  -0x28(%ebp)
  80118b:	e8 20 0b 00 00       	call   801cb0 <__umoddi3>
  801190:	83 c4 14             	add    $0x14,%esp
  801193:	0f be 80 27 1f 80 00 	movsbl 0x801f27(%eax),%eax
  80119a:	50                   	push   %eax
  80119b:	ff d7                	call   *%edi
}
  80119d:	83 c4 10             	add    $0x10,%esp
  8011a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a3:	5b                   	pop    %ebx
  8011a4:	5e                   	pop    %esi
  8011a5:	5f                   	pop    %edi
  8011a6:	5d                   	pop    %ebp
  8011a7:	c3                   	ret    
  8011a8:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8011ab:	eb c4                	jmp    801171 <printnum+0x73>

008011ad <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011ad:	55                   	push   %ebp
  8011ae:	89 e5                	mov    %esp,%ebp
  8011b0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011b3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011b7:	8b 10                	mov    (%eax),%edx
  8011b9:	3b 50 04             	cmp    0x4(%eax),%edx
  8011bc:	73 0a                	jae    8011c8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8011be:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011c1:	89 08                	mov    %ecx,(%eax)
  8011c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c6:	88 02                	mov    %al,(%edx)
}
  8011c8:	5d                   	pop    %ebp
  8011c9:	c3                   	ret    

008011ca <printfmt>:
{
  8011ca:	55                   	push   %ebp
  8011cb:	89 e5                	mov    %esp,%ebp
  8011cd:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8011d0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011d3:	50                   	push   %eax
  8011d4:	ff 75 10             	pushl  0x10(%ebp)
  8011d7:	ff 75 0c             	pushl  0xc(%ebp)
  8011da:	ff 75 08             	pushl  0x8(%ebp)
  8011dd:	e8 05 00 00 00       	call   8011e7 <vprintfmt>
}
  8011e2:	83 c4 10             	add    $0x10,%esp
  8011e5:	c9                   	leave  
  8011e6:	c3                   	ret    

008011e7 <vprintfmt>:
{
  8011e7:	55                   	push   %ebp
  8011e8:	89 e5                	mov    %esp,%ebp
  8011ea:	57                   	push   %edi
  8011eb:	56                   	push   %esi
  8011ec:	53                   	push   %ebx
  8011ed:	83 ec 2c             	sub    $0x2c,%esp
  8011f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8011f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011f6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8011f9:	e9 c1 03 00 00       	jmp    8015bf <vprintfmt+0x3d8>
		padc = ' ';
  8011fe:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  801202:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  801209:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  801210:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801217:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80121c:	8d 47 01             	lea    0x1(%edi),%eax
  80121f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801222:	0f b6 17             	movzbl (%edi),%edx
  801225:	8d 42 dd             	lea    -0x23(%edx),%eax
  801228:	3c 55                	cmp    $0x55,%al
  80122a:	0f 87 12 04 00 00    	ja     801642 <vprintfmt+0x45b>
  801230:	0f b6 c0             	movzbl %al,%eax
  801233:	ff 24 85 60 20 80 00 	jmp    *0x802060(,%eax,4)
  80123a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80123d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  801241:	eb d9                	jmp    80121c <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801243:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  801246:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80124a:	eb d0                	jmp    80121c <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80124c:	0f b6 d2             	movzbl %dl,%edx
  80124f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801252:	b8 00 00 00 00       	mov    $0x0,%eax
  801257:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80125a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80125d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801261:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801264:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801267:	83 f9 09             	cmp    $0x9,%ecx
  80126a:	77 55                	ja     8012c1 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80126c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80126f:	eb e9                	jmp    80125a <vprintfmt+0x73>
			precision = va_arg(ap, int);
  801271:	8b 45 14             	mov    0x14(%ebp),%eax
  801274:	8b 00                	mov    (%eax),%eax
  801276:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801279:	8b 45 14             	mov    0x14(%ebp),%eax
  80127c:	8d 40 04             	lea    0x4(%eax),%eax
  80127f:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801282:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801285:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801289:	79 91                	jns    80121c <vprintfmt+0x35>
				width = precision, precision = -1;
  80128b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80128e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801291:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801298:	eb 82                	jmp    80121c <vprintfmt+0x35>
  80129a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80129d:	85 c0                	test   %eax,%eax
  80129f:	ba 00 00 00 00       	mov    $0x0,%edx
  8012a4:	0f 49 d0             	cmovns %eax,%edx
  8012a7:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8012aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012ad:	e9 6a ff ff ff       	jmp    80121c <vprintfmt+0x35>
  8012b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8012b5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012bc:	e9 5b ff ff ff       	jmp    80121c <vprintfmt+0x35>
  8012c1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012c4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012c7:	eb bc                	jmp    801285 <vprintfmt+0x9e>
			lflag++;
  8012c9:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8012cf:	e9 48 ff ff ff       	jmp    80121c <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8012d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8012d7:	8d 78 04             	lea    0x4(%eax),%edi
  8012da:	83 ec 08             	sub    $0x8,%esp
  8012dd:	53                   	push   %ebx
  8012de:	ff 30                	pushl  (%eax)
  8012e0:	ff d6                	call   *%esi
			break;
  8012e2:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8012e5:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8012e8:	e9 cf 02 00 00       	jmp    8015bc <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8012ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8012f0:	8d 78 04             	lea    0x4(%eax),%edi
  8012f3:	8b 00                	mov    (%eax),%eax
  8012f5:	99                   	cltd   
  8012f6:	31 d0                	xor    %edx,%eax
  8012f8:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8012fa:	83 f8 0f             	cmp    $0xf,%eax
  8012fd:	7f 23                	jg     801322 <vprintfmt+0x13b>
  8012ff:	8b 14 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%edx
  801306:	85 d2                	test   %edx,%edx
  801308:	74 18                	je     801322 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  80130a:	52                   	push   %edx
  80130b:	68 bd 1e 80 00       	push   $0x801ebd
  801310:	53                   	push   %ebx
  801311:	56                   	push   %esi
  801312:	e8 b3 fe ff ff       	call   8011ca <printfmt>
  801317:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80131a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80131d:	e9 9a 02 00 00       	jmp    8015bc <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  801322:	50                   	push   %eax
  801323:	68 3f 1f 80 00       	push   $0x801f3f
  801328:	53                   	push   %ebx
  801329:	56                   	push   %esi
  80132a:	e8 9b fe ff ff       	call   8011ca <printfmt>
  80132f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801332:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801335:	e9 82 02 00 00       	jmp    8015bc <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  80133a:	8b 45 14             	mov    0x14(%ebp),%eax
  80133d:	83 c0 04             	add    $0x4,%eax
  801340:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801343:	8b 45 14             	mov    0x14(%ebp),%eax
  801346:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801348:	85 ff                	test   %edi,%edi
  80134a:	b8 38 1f 80 00       	mov    $0x801f38,%eax
  80134f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801352:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801356:	0f 8e bd 00 00 00    	jle    801419 <vprintfmt+0x232>
  80135c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801360:	75 0e                	jne    801370 <vprintfmt+0x189>
  801362:	89 75 08             	mov    %esi,0x8(%ebp)
  801365:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801368:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80136b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80136e:	eb 6d                	jmp    8013dd <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  801370:	83 ec 08             	sub    $0x8,%esp
  801373:	ff 75 d0             	pushl  -0x30(%ebp)
  801376:	57                   	push   %edi
  801377:	e8 6e 03 00 00       	call   8016ea <strnlen>
  80137c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80137f:	29 c1                	sub    %eax,%ecx
  801381:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  801384:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801387:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80138b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80138e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801391:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  801393:	eb 0f                	jmp    8013a4 <vprintfmt+0x1bd>
					putch(padc, putdat);
  801395:	83 ec 08             	sub    $0x8,%esp
  801398:	53                   	push   %ebx
  801399:	ff 75 e0             	pushl  -0x20(%ebp)
  80139c:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80139e:	83 ef 01             	sub    $0x1,%edi
  8013a1:	83 c4 10             	add    $0x10,%esp
  8013a4:	85 ff                	test   %edi,%edi
  8013a6:	7f ed                	jg     801395 <vprintfmt+0x1ae>
  8013a8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013ab:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8013ae:	85 c9                	test   %ecx,%ecx
  8013b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b5:	0f 49 c1             	cmovns %ecx,%eax
  8013b8:	29 c1                	sub    %eax,%ecx
  8013ba:	89 75 08             	mov    %esi,0x8(%ebp)
  8013bd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8013c0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8013c3:	89 cb                	mov    %ecx,%ebx
  8013c5:	eb 16                	jmp    8013dd <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8013c7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013cb:	75 31                	jne    8013fe <vprintfmt+0x217>
					putch(ch, putdat);
  8013cd:	83 ec 08             	sub    $0x8,%esp
  8013d0:	ff 75 0c             	pushl  0xc(%ebp)
  8013d3:	50                   	push   %eax
  8013d4:	ff 55 08             	call   *0x8(%ebp)
  8013d7:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013da:	83 eb 01             	sub    $0x1,%ebx
  8013dd:	83 c7 01             	add    $0x1,%edi
  8013e0:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8013e4:	0f be c2             	movsbl %dl,%eax
  8013e7:	85 c0                	test   %eax,%eax
  8013e9:	74 59                	je     801444 <vprintfmt+0x25d>
  8013eb:	85 f6                	test   %esi,%esi
  8013ed:	78 d8                	js     8013c7 <vprintfmt+0x1e0>
  8013ef:	83 ee 01             	sub    $0x1,%esi
  8013f2:	79 d3                	jns    8013c7 <vprintfmt+0x1e0>
  8013f4:	89 df                	mov    %ebx,%edi
  8013f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8013f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8013fc:	eb 37                	jmp    801435 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8013fe:	0f be d2             	movsbl %dl,%edx
  801401:	83 ea 20             	sub    $0x20,%edx
  801404:	83 fa 5e             	cmp    $0x5e,%edx
  801407:	76 c4                	jbe    8013cd <vprintfmt+0x1e6>
					putch('?', putdat);
  801409:	83 ec 08             	sub    $0x8,%esp
  80140c:	ff 75 0c             	pushl  0xc(%ebp)
  80140f:	6a 3f                	push   $0x3f
  801411:	ff 55 08             	call   *0x8(%ebp)
  801414:	83 c4 10             	add    $0x10,%esp
  801417:	eb c1                	jmp    8013da <vprintfmt+0x1f3>
  801419:	89 75 08             	mov    %esi,0x8(%ebp)
  80141c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80141f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801422:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801425:	eb b6                	jmp    8013dd <vprintfmt+0x1f6>
				putch(' ', putdat);
  801427:	83 ec 08             	sub    $0x8,%esp
  80142a:	53                   	push   %ebx
  80142b:	6a 20                	push   $0x20
  80142d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80142f:	83 ef 01             	sub    $0x1,%edi
  801432:	83 c4 10             	add    $0x10,%esp
  801435:	85 ff                	test   %edi,%edi
  801437:	7f ee                	jg     801427 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  801439:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80143c:	89 45 14             	mov    %eax,0x14(%ebp)
  80143f:	e9 78 01 00 00       	jmp    8015bc <vprintfmt+0x3d5>
  801444:	89 df                	mov    %ebx,%edi
  801446:	8b 75 08             	mov    0x8(%ebp),%esi
  801449:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80144c:	eb e7                	jmp    801435 <vprintfmt+0x24e>
	if (lflag >= 2)
  80144e:	83 f9 01             	cmp    $0x1,%ecx
  801451:	7e 3f                	jle    801492 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  801453:	8b 45 14             	mov    0x14(%ebp),%eax
  801456:	8b 50 04             	mov    0x4(%eax),%edx
  801459:	8b 00                	mov    (%eax),%eax
  80145b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80145e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801461:	8b 45 14             	mov    0x14(%ebp),%eax
  801464:	8d 40 08             	lea    0x8(%eax),%eax
  801467:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80146a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80146e:	79 5c                	jns    8014cc <vprintfmt+0x2e5>
				putch('-', putdat);
  801470:	83 ec 08             	sub    $0x8,%esp
  801473:	53                   	push   %ebx
  801474:	6a 2d                	push   $0x2d
  801476:	ff d6                	call   *%esi
				num = -(long long) num;
  801478:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80147b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80147e:	f7 da                	neg    %edx
  801480:	83 d1 00             	adc    $0x0,%ecx
  801483:	f7 d9                	neg    %ecx
  801485:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801488:	b8 0a 00 00 00       	mov    $0xa,%eax
  80148d:	e9 10 01 00 00       	jmp    8015a2 <vprintfmt+0x3bb>
	else if (lflag)
  801492:	85 c9                	test   %ecx,%ecx
  801494:	75 1b                	jne    8014b1 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  801496:	8b 45 14             	mov    0x14(%ebp),%eax
  801499:	8b 00                	mov    (%eax),%eax
  80149b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80149e:	89 c1                	mov    %eax,%ecx
  8014a0:	c1 f9 1f             	sar    $0x1f,%ecx
  8014a3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8014a9:	8d 40 04             	lea    0x4(%eax),%eax
  8014ac:	89 45 14             	mov    %eax,0x14(%ebp)
  8014af:	eb b9                	jmp    80146a <vprintfmt+0x283>
		return va_arg(*ap, long);
  8014b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b4:	8b 00                	mov    (%eax),%eax
  8014b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014b9:	89 c1                	mov    %eax,%ecx
  8014bb:	c1 f9 1f             	sar    $0x1f,%ecx
  8014be:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c4:	8d 40 04             	lea    0x4(%eax),%eax
  8014c7:	89 45 14             	mov    %eax,0x14(%ebp)
  8014ca:	eb 9e                	jmp    80146a <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8014cc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014cf:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8014d2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014d7:	e9 c6 00 00 00       	jmp    8015a2 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8014dc:	83 f9 01             	cmp    $0x1,%ecx
  8014df:	7e 18                	jle    8014f9 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8014e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e4:	8b 10                	mov    (%eax),%edx
  8014e6:	8b 48 04             	mov    0x4(%eax),%ecx
  8014e9:	8d 40 08             	lea    0x8(%eax),%eax
  8014ec:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014ef:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014f4:	e9 a9 00 00 00       	jmp    8015a2 <vprintfmt+0x3bb>
	else if (lflag)
  8014f9:	85 c9                	test   %ecx,%ecx
  8014fb:	75 1a                	jne    801517 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8014fd:	8b 45 14             	mov    0x14(%ebp),%eax
  801500:	8b 10                	mov    (%eax),%edx
  801502:	b9 00 00 00 00       	mov    $0x0,%ecx
  801507:	8d 40 04             	lea    0x4(%eax),%eax
  80150a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80150d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801512:	e9 8b 00 00 00       	jmp    8015a2 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801517:	8b 45 14             	mov    0x14(%ebp),%eax
  80151a:	8b 10                	mov    (%eax),%edx
  80151c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801521:	8d 40 04             	lea    0x4(%eax),%eax
  801524:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801527:	b8 0a 00 00 00       	mov    $0xa,%eax
  80152c:	eb 74                	jmp    8015a2 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80152e:	83 f9 01             	cmp    $0x1,%ecx
  801531:	7e 15                	jle    801548 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  801533:	8b 45 14             	mov    0x14(%ebp),%eax
  801536:	8b 10                	mov    (%eax),%edx
  801538:	8b 48 04             	mov    0x4(%eax),%ecx
  80153b:	8d 40 08             	lea    0x8(%eax),%eax
  80153e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801541:	b8 08 00 00 00       	mov    $0x8,%eax
  801546:	eb 5a                	jmp    8015a2 <vprintfmt+0x3bb>
	else if (lflag)
  801548:	85 c9                	test   %ecx,%ecx
  80154a:	75 17                	jne    801563 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80154c:	8b 45 14             	mov    0x14(%ebp),%eax
  80154f:	8b 10                	mov    (%eax),%edx
  801551:	b9 00 00 00 00       	mov    $0x0,%ecx
  801556:	8d 40 04             	lea    0x4(%eax),%eax
  801559:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80155c:	b8 08 00 00 00       	mov    $0x8,%eax
  801561:	eb 3f                	jmp    8015a2 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801563:	8b 45 14             	mov    0x14(%ebp),%eax
  801566:	8b 10                	mov    (%eax),%edx
  801568:	b9 00 00 00 00       	mov    $0x0,%ecx
  80156d:	8d 40 04             	lea    0x4(%eax),%eax
  801570:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801573:	b8 08 00 00 00       	mov    $0x8,%eax
  801578:	eb 28                	jmp    8015a2 <vprintfmt+0x3bb>
			putch('0', putdat);
  80157a:	83 ec 08             	sub    $0x8,%esp
  80157d:	53                   	push   %ebx
  80157e:	6a 30                	push   $0x30
  801580:	ff d6                	call   *%esi
			putch('x', putdat);
  801582:	83 c4 08             	add    $0x8,%esp
  801585:	53                   	push   %ebx
  801586:	6a 78                	push   $0x78
  801588:	ff d6                	call   *%esi
			num = (unsigned long long)
  80158a:	8b 45 14             	mov    0x14(%ebp),%eax
  80158d:	8b 10                	mov    (%eax),%edx
  80158f:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801594:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801597:	8d 40 04             	lea    0x4(%eax),%eax
  80159a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80159d:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8015a2:	83 ec 0c             	sub    $0xc,%esp
  8015a5:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015a9:	57                   	push   %edi
  8015aa:	ff 75 e0             	pushl  -0x20(%ebp)
  8015ad:	50                   	push   %eax
  8015ae:	51                   	push   %ecx
  8015af:	52                   	push   %edx
  8015b0:	89 da                	mov    %ebx,%edx
  8015b2:	89 f0                	mov    %esi,%eax
  8015b4:	e8 45 fb ff ff       	call   8010fe <printnum>
			break;
  8015b9:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8015bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015bf:	83 c7 01             	add    $0x1,%edi
  8015c2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015c6:	83 f8 25             	cmp    $0x25,%eax
  8015c9:	0f 84 2f fc ff ff    	je     8011fe <vprintfmt+0x17>
			if (ch == '\0')
  8015cf:	85 c0                	test   %eax,%eax
  8015d1:	0f 84 8b 00 00 00    	je     801662 <vprintfmt+0x47b>
			putch(ch, putdat);
  8015d7:	83 ec 08             	sub    $0x8,%esp
  8015da:	53                   	push   %ebx
  8015db:	50                   	push   %eax
  8015dc:	ff d6                	call   *%esi
  8015de:	83 c4 10             	add    $0x10,%esp
  8015e1:	eb dc                	jmp    8015bf <vprintfmt+0x3d8>
	if (lflag >= 2)
  8015e3:	83 f9 01             	cmp    $0x1,%ecx
  8015e6:	7e 15                	jle    8015fd <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8015e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8015eb:	8b 10                	mov    (%eax),%edx
  8015ed:	8b 48 04             	mov    0x4(%eax),%ecx
  8015f0:	8d 40 08             	lea    0x8(%eax),%eax
  8015f3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015f6:	b8 10 00 00 00       	mov    $0x10,%eax
  8015fb:	eb a5                	jmp    8015a2 <vprintfmt+0x3bb>
	else if (lflag)
  8015fd:	85 c9                	test   %ecx,%ecx
  8015ff:	75 17                	jne    801618 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  801601:	8b 45 14             	mov    0x14(%ebp),%eax
  801604:	8b 10                	mov    (%eax),%edx
  801606:	b9 00 00 00 00       	mov    $0x0,%ecx
  80160b:	8d 40 04             	lea    0x4(%eax),%eax
  80160e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801611:	b8 10 00 00 00       	mov    $0x10,%eax
  801616:	eb 8a                	jmp    8015a2 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801618:	8b 45 14             	mov    0x14(%ebp),%eax
  80161b:	8b 10                	mov    (%eax),%edx
  80161d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801622:	8d 40 04             	lea    0x4(%eax),%eax
  801625:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801628:	b8 10 00 00 00       	mov    $0x10,%eax
  80162d:	e9 70 ff ff ff       	jmp    8015a2 <vprintfmt+0x3bb>
			putch(ch, putdat);
  801632:	83 ec 08             	sub    $0x8,%esp
  801635:	53                   	push   %ebx
  801636:	6a 25                	push   $0x25
  801638:	ff d6                	call   *%esi
			break;
  80163a:	83 c4 10             	add    $0x10,%esp
  80163d:	e9 7a ff ff ff       	jmp    8015bc <vprintfmt+0x3d5>
			putch('%', putdat);
  801642:	83 ec 08             	sub    $0x8,%esp
  801645:	53                   	push   %ebx
  801646:	6a 25                	push   $0x25
  801648:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80164a:	83 c4 10             	add    $0x10,%esp
  80164d:	89 f8                	mov    %edi,%eax
  80164f:	eb 03                	jmp    801654 <vprintfmt+0x46d>
  801651:	83 e8 01             	sub    $0x1,%eax
  801654:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801658:	75 f7                	jne    801651 <vprintfmt+0x46a>
  80165a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80165d:	e9 5a ff ff ff       	jmp    8015bc <vprintfmt+0x3d5>
}
  801662:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801665:	5b                   	pop    %ebx
  801666:	5e                   	pop    %esi
  801667:	5f                   	pop    %edi
  801668:	5d                   	pop    %ebp
  801669:	c3                   	ret    

0080166a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80166a:	55                   	push   %ebp
  80166b:	89 e5                	mov    %esp,%ebp
  80166d:	83 ec 18             	sub    $0x18,%esp
  801670:	8b 45 08             	mov    0x8(%ebp),%eax
  801673:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801676:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801679:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80167d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801680:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801687:	85 c0                	test   %eax,%eax
  801689:	74 26                	je     8016b1 <vsnprintf+0x47>
  80168b:	85 d2                	test   %edx,%edx
  80168d:	7e 22                	jle    8016b1 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80168f:	ff 75 14             	pushl  0x14(%ebp)
  801692:	ff 75 10             	pushl  0x10(%ebp)
  801695:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801698:	50                   	push   %eax
  801699:	68 ad 11 80 00       	push   $0x8011ad
  80169e:	e8 44 fb ff ff       	call   8011e7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016a6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ac:	83 c4 10             	add    $0x10,%esp
}
  8016af:	c9                   	leave  
  8016b0:	c3                   	ret    
		return -E_INVAL;
  8016b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016b6:	eb f7                	jmp    8016af <vsnprintf+0x45>

008016b8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016b8:	55                   	push   %ebp
  8016b9:	89 e5                	mov    %esp,%ebp
  8016bb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016be:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016c1:	50                   	push   %eax
  8016c2:	ff 75 10             	pushl  0x10(%ebp)
  8016c5:	ff 75 0c             	pushl  0xc(%ebp)
  8016c8:	ff 75 08             	pushl  0x8(%ebp)
  8016cb:	e8 9a ff ff ff       	call   80166a <vsnprintf>
	va_end(ap);

	return rc;
}
  8016d0:	c9                   	leave  
  8016d1:	c3                   	ret    

008016d2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016d2:	55                   	push   %ebp
  8016d3:	89 e5                	mov    %esp,%ebp
  8016d5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8016dd:	eb 03                	jmp    8016e2 <strlen+0x10>
		n++;
  8016df:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8016e2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016e6:	75 f7                	jne    8016df <strlen+0xd>
	return n;
}
  8016e8:	5d                   	pop    %ebp
  8016e9:	c3                   	ret    

008016ea <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016ea:	55                   	push   %ebp
  8016eb:	89 e5                	mov    %esp,%ebp
  8016ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016f0:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8016f8:	eb 03                	jmp    8016fd <strnlen+0x13>
		n++;
  8016fa:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016fd:	39 d0                	cmp    %edx,%eax
  8016ff:	74 06                	je     801707 <strnlen+0x1d>
  801701:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801705:	75 f3                	jne    8016fa <strnlen+0x10>
	return n;
}
  801707:	5d                   	pop    %ebp
  801708:	c3                   	ret    

00801709 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801709:	55                   	push   %ebp
  80170a:	89 e5                	mov    %esp,%ebp
  80170c:	53                   	push   %ebx
  80170d:	8b 45 08             	mov    0x8(%ebp),%eax
  801710:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801713:	89 c2                	mov    %eax,%edx
  801715:	83 c1 01             	add    $0x1,%ecx
  801718:	83 c2 01             	add    $0x1,%edx
  80171b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80171f:	88 5a ff             	mov    %bl,-0x1(%edx)
  801722:	84 db                	test   %bl,%bl
  801724:	75 ef                	jne    801715 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801726:	5b                   	pop    %ebx
  801727:	5d                   	pop    %ebp
  801728:	c3                   	ret    

00801729 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801729:	55                   	push   %ebp
  80172a:	89 e5                	mov    %esp,%ebp
  80172c:	53                   	push   %ebx
  80172d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801730:	53                   	push   %ebx
  801731:	e8 9c ff ff ff       	call   8016d2 <strlen>
  801736:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801739:	ff 75 0c             	pushl  0xc(%ebp)
  80173c:	01 d8                	add    %ebx,%eax
  80173e:	50                   	push   %eax
  80173f:	e8 c5 ff ff ff       	call   801709 <strcpy>
	return dst;
}
  801744:	89 d8                	mov    %ebx,%eax
  801746:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801749:	c9                   	leave  
  80174a:	c3                   	ret    

0080174b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80174b:	55                   	push   %ebp
  80174c:	89 e5                	mov    %esp,%ebp
  80174e:	56                   	push   %esi
  80174f:	53                   	push   %ebx
  801750:	8b 75 08             	mov    0x8(%ebp),%esi
  801753:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801756:	89 f3                	mov    %esi,%ebx
  801758:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80175b:	89 f2                	mov    %esi,%edx
  80175d:	eb 0f                	jmp    80176e <strncpy+0x23>
		*dst++ = *src;
  80175f:	83 c2 01             	add    $0x1,%edx
  801762:	0f b6 01             	movzbl (%ecx),%eax
  801765:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801768:	80 39 01             	cmpb   $0x1,(%ecx)
  80176b:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80176e:	39 da                	cmp    %ebx,%edx
  801770:	75 ed                	jne    80175f <strncpy+0x14>
	}
	return ret;
}
  801772:	89 f0                	mov    %esi,%eax
  801774:	5b                   	pop    %ebx
  801775:	5e                   	pop    %esi
  801776:	5d                   	pop    %ebp
  801777:	c3                   	ret    

00801778 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801778:	55                   	push   %ebp
  801779:	89 e5                	mov    %esp,%ebp
  80177b:	56                   	push   %esi
  80177c:	53                   	push   %ebx
  80177d:	8b 75 08             	mov    0x8(%ebp),%esi
  801780:	8b 55 0c             	mov    0xc(%ebp),%edx
  801783:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801786:	89 f0                	mov    %esi,%eax
  801788:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80178c:	85 c9                	test   %ecx,%ecx
  80178e:	75 0b                	jne    80179b <strlcpy+0x23>
  801790:	eb 17                	jmp    8017a9 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801792:	83 c2 01             	add    $0x1,%edx
  801795:	83 c0 01             	add    $0x1,%eax
  801798:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80179b:	39 d8                	cmp    %ebx,%eax
  80179d:	74 07                	je     8017a6 <strlcpy+0x2e>
  80179f:	0f b6 0a             	movzbl (%edx),%ecx
  8017a2:	84 c9                	test   %cl,%cl
  8017a4:	75 ec                	jne    801792 <strlcpy+0x1a>
		*dst = '\0';
  8017a6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017a9:	29 f0                	sub    %esi,%eax
}
  8017ab:	5b                   	pop    %ebx
  8017ac:	5e                   	pop    %esi
  8017ad:	5d                   	pop    %ebp
  8017ae:	c3                   	ret    

008017af <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017af:	55                   	push   %ebp
  8017b0:	89 e5                	mov    %esp,%ebp
  8017b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017b5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017b8:	eb 06                	jmp    8017c0 <strcmp+0x11>
		p++, q++;
  8017ba:	83 c1 01             	add    $0x1,%ecx
  8017bd:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8017c0:	0f b6 01             	movzbl (%ecx),%eax
  8017c3:	84 c0                	test   %al,%al
  8017c5:	74 04                	je     8017cb <strcmp+0x1c>
  8017c7:	3a 02                	cmp    (%edx),%al
  8017c9:	74 ef                	je     8017ba <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017cb:	0f b6 c0             	movzbl %al,%eax
  8017ce:	0f b6 12             	movzbl (%edx),%edx
  8017d1:	29 d0                	sub    %edx,%eax
}
  8017d3:	5d                   	pop    %ebp
  8017d4:	c3                   	ret    

008017d5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017d5:	55                   	push   %ebp
  8017d6:	89 e5                	mov    %esp,%ebp
  8017d8:	53                   	push   %ebx
  8017d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017df:	89 c3                	mov    %eax,%ebx
  8017e1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017e4:	eb 06                	jmp    8017ec <strncmp+0x17>
		n--, p++, q++;
  8017e6:	83 c0 01             	add    $0x1,%eax
  8017e9:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8017ec:	39 d8                	cmp    %ebx,%eax
  8017ee:	74 16                	je     801806 <strncmp+0x31>
  8017f0:	0f b6 08             	movzbl (%eax),%ecx
  8017f3:	84 c9                	test   %cl,%cl
  8017f5:	74 04                	je     8017fb <strncmp+0x26>
  8017f7:	3a 0a                	cmp    (%edx),%cl
  8017f9:	74 eb                	je     8017e6 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017fb:	0f b6 00             	movzbl (%eax),%eax
  8017fe:	0f b6 12             	movzbl (%edx),%edx
  801801:	29 d0                	sub    %edx,%eax
}
  801803:	5b                   	pop    %ebx
  801804:	5d                   	pop    %ebp
  801805:	c3                   	ret    
		return 0;
  801806:	b8 00 00 00 00       	mov    $0x0,%eax
  80180b:	eb f6                	jmp    801803 <strncmp+0x2e>

0080180d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80180d:	55                   	push   %ebp
  80180e:	89 e5                	mov    %esp,%ebp
  801810:	8b 45 08             	mov    0x8(%ebp),%eax
  801813:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801817:	0f b6 10             	movzbl (%eax),%edx
  80181a:	84 d2                	test   %dl,%dl
  80181c:	74 09                	je     801827 <strchr+0x1a>
		if (*s == c)
  80181e:	38 ca                	cmp    %cl,%dl
  801820:	74 0a                	je     80182c <strchr+0x1f>
	for (; *s; s++)
  801822:	83 c0 01             	add    $0x1,%eax
  801825:	eb f0                	jmp    801817 <strchr+0xa>
			return (char *) s;
	return 0;
  801827:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80182c:	5d                   	pop    %ebp
  80182d:	c3                   	ret    

0080182e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80182e:	55                   	push   %ebp
  80182f:	89 e5                	mov    %esp,%ebp
  801831:	8b 45 08             	mov    0x8(%ebp),%eax
  801834:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801838:	eb 03                	jmp    80183d <strfind+0xf>
  80183a:	83 c0 01             	add    $0x1,%eax
  80183d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801840:	38 ca                	cmp    %cl,%dl
  801842:	74 04                	je     801848 <strfind+0x1a>
  801844:	84 d2                	test   %dl,%dl
  801846:	75 f2                	jne    80183a <strfind+0xc>
			break;
	return (char *) s;
}
  801848:	5d                   	pop    %ebp
  801849:	c3                   	ret    

0080184a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80184a:	55                   	push   %ebp
  80184b:	89 e5                	mov    %esp,%ebp
  80184d:	57                   	push   %edi
  80184e:	56                   	push   %esi
  80184f:	53                   	push   %ebx
  801850:	8b 7d 08             	mov    0x8(%ebp),%edi
  801853:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801856:	85 c9                	test   %ecx,%ecx
  801858:	74 13                	je     80186d <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80185a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801860:	75 05                	jne    801867 <memset+0x1d>
  801862:	f6 c1 03             	test   $0x3,%cl
  801865:	74 0d                	je     801874 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801867:	8b 45 0c             	mov    0xc(%ebp),%eax
  80186a:	fc                   	cld    
  80186b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80186d:	89 f8                	mov    %edi,%eax
  80186f:	5b                   	pop    %ebx
  801870:	5e                   	pop    %esi
  801871:	5f                   	pop    %edi
  801872:	5d                   	pop    %ebp
  801873:	c3                   	ret    
		c &= 0xFF;
  801874:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801878:	89 d3                	mov    %edx,%ebx
  80187a:	c1 e3 08             	shl    $0x8,%ebx
  80187d:	89 d0                	mov    %edx,%eax
  80187f:	c1 e0 18             	shl    $0x18,%eax
  801882:	89 d6                	mov    %edx,%esi
  801884:	c1 e6 10             	shl    $0x10,%esi
  801887:	09 f0                	or     %esi,%eax
  801889:	09 c2                	or     %eax,%edx
  80188b:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  80188d:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801890:	89 d0                	mov    %edx,%eax
  801892:	fc                   	cld    
  801893:	f3 ab                	rep stos %eax,%es:(%edi)
  801895:	eb d6                	jmp    80186d <memset+0x23>

00801897 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801897:	55                   	push   %ebp
  801898:	89 e5                	mov    %esp,%ebp
  80189a:	57                   	push   %edi
  80189b:	56                   	push   %esi
  80189c:	8b 45 08             	mov    0x8(%ebp),%eax
  80189f:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018a5:	39 c6                	cmp    %eax,%esi
  8018a7:	73 35                	jae    8018de <memmove+0x47>
  8018a9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018ac:	39 c2                	cmp    %eax,%edx
  8018ae:	76 2e                	jbe    8018de <memmove+0x47>
		s += n;
		d += n;
  8018b0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018b3:	89 d6                	mov    %edx,%esi
  8018b5:	09 fe                	or     %edi,%esi
  8018b7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018bd:	74 0c                	je     8018cb <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018bf:	83 ef 01             	sub    $0x1,%edi
  8018c2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8018c5:	fd                   	std    
  8018c6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018c8:	fc                   	cld    
  8018c9:	eb 21                	jmp    8018ec <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018cb:	f6 c1 03             	test   $0x3,%cl
  8018ce:	75 ef                	jne    8018bf <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8018d0:	83 ef 04             	sub    $0x4,%edi
  8018d3:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018d6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8018d9:	fd                   	std    
  8018da:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018dc:	eb ea                	jmp    8018c8 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018de:	89 f2                	mov    %esi,%edx
  8018e0:	09 c2                	or     %eax,%edx
  8018e2:	f6 c2 03             	test   $0x3,%dl
  8018e5:	74 09                	je     8018f0 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018e7:	89 c7                	mov    %eax,%edi
  8018e9:	fc                   	cld    
  8018ea:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018ec:	5e                   	pop    %esi
  8018ed:	5f                   	pop    %edi
  8018ee:	5d                   	pop    %ebp
  8018ef:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018f0:	f6 c1 03             	test   $0x3,%cl
  8018f3:	75 f2                	jne    8018e7 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018f5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8018f8:	89 c7                	mov    %eax,%edi
  8018fa:	fc                   	cld    
  8018fb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018fd:	eb ed                	jmp    8018ec <memmove+0x55>

008018ff <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018ff:	55                   	push   %ebp
  801900:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801902:	ff 75 10             	pushl  0x10(%ebp)
  801905:	ff 75 0c             	pushl  0xc(%ebp)
  801908:	ff 75 08             	pushl  0x8(%ebp)
  80190b:	e8 87 ff ff ff       	call   801897 <memmove>
}
  801910:	c9                   	leave  
  801911:	c3                   	ret    

00801912 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801912:	55                   	push   %ebp
  801913:	89 e5                	mov    %esp,%ebp
  801915:	56                   	push   %esi
  801916:	53                   	push   %ebx
  801917:	8b 45 08             	mov    0x8(%ebp),%eax
  80191a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80191d:	89 c6                	mov    %eax,%esi
  80191f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801922:	39 f0                	cmp    %esi,%eax
  801924:	74 1c                	je     801942 <memcmp+0x30>
		if (*s1 != *s2)
  801926:	0f b6 08             	movzbl (%eax),%ecx
  801929:	0f b6 1a             	movzbl (%edx),%ebx
  80192c:	38 d9                	cmp    %bl,%cl
  80192e:	75 08                	jne    801938 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801930:	83 c0 01             	add    $0x1,%eax
  801933:	83 c2 01             	add    $0x1,%edx
  801936:	eb ea                	jmp    801922 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  801938:	0f b6 c1             	movzbl %cl,%eax
  80193b:	0f b6 db             	movzbl %bl,%ebx
  80193e:	29 d8                	sub    %ebx,%eax
  801940:	eb 05                	jmp    801947 <memcmp+0x35>
	}

	return 0;
  801942:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801947:	5b                   	pop    %ebx
  801948:	5e                   	pop    %esi
  801949:	5d                   	pop    %ebp
  80194a:	c3                   	ret    

0080194b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80194b:	55                   	push   %ebp
  80194c:	89 e5                	mov    %esp,%ebp
  80194e:	8b 45 08             	mov    0x8(%ebp),%eax
  801951:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801954:	89 c2                	mov    %eax,%edx
  801956:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801959:	39 d0                	cmp    %edx,%eax
  80195b:	73 09                	jae    801966 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80195d:	38 08                	cmp    %cl,(%eax)
  80195f:	74 05                	je     801966 <memfind+0x1b>
	for (; s < ends; s++)
  801961:	83 c0 01             	add    $0x1,%eax
  801964:	eb f3                	jmp    801959 <memfind+0xe>
			break;
	return (void *) s;
}
  801966:	5d                   	pop    %ebp
  801967:	c3                   	ret    

00801968 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801968:	55                   	push   %ebp
  801969:	89 e5                	mov    %esp,%ebp
  80196b:	57                   	push   %edi
  80196c:	56                   	push   %esi
  80196d:	53                   	push   %ebx
  80196e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801971:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801974:	eb 03                	jmp    801979 <strtol+0x11>
		s++;
  801976:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801979:	0f b6 01             	movzbl (%ecx),%eax
  80197c:	3c 20                	cmp    $0x20,%al
  80197e:	74 f6                	je     801976 <strtol+0xe>
  801980:	3c 09                	cmp    $0x9,%al
  801982:	74 f2                	je     801976 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801984:	3c 2b                	cmp    $0x2b,%al
  801986:	74 2e                	je     8019b6 <strtol+0x4e>
	int neg = 0;
  801988:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  80198d:	3c 2d                	cmp    $0x2d,%al
  80198f:	74 2f                	je     8019c0 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801991:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801997:	75 05                	jne    80199e <strtol+0x36>
  801999:	80 39 30             	cmpb   $0x30,(%ecx)
  80199c:	74 2c                	je     8019ca <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80199e:	85 db                	test   %ebx,%ebx
  8019a0:	75 0a                	jne    8019ac <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019a2:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  8019a7:	80 39 30             	cmpb   $0x30,(%ecx)
  8019aa:	74 28                	je     8019d4 <strtol+0x6c>
		base = 10;
  8019ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b1:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8019b4:	eb 50                	jmp    801a06 <strtol+0x9e>
		s++;
  8019b6:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8019b9:	bf 00 00 00 00       	mov    $0x0,%edi
  8019be:	eb d1                	jmp    801991 <strtol+0x29>
		s++, neg = 1;
  8019c0:	83 c1 01             	add    $0x1,%ecx
  8019c3:	bf 01 00 00 00       	mov    $0x1,%edi
  8019c8:	eb c7                	jmp    801991 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019ca:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019ce:	74 0e                	je     8019de <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8019d0:	85 db                	test   %ebx,%ebx
  8019d2:	75 d8                	jne    8019ac <strtol+0x44>
		s++, base = 8;
  8019d4:	83 c1 01             	add    $0x1,%ecx
  8019d7:	bb 08 00 00 00       	mov    $0x8,%ebx
  8019dc:	eb ce                	jmp    8019ac <strtol+0x44>
		s += 2, base = 16;
  8019de:	83 c1 02             	add    $0x2,%ecx
  8019e1:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019e6:	eb c4                	jmp    8019ac <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  8019e8:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019eb:	89 f3                	mov    %esi,%ebx
  8019ed:	80 fb 19             	cmp    $0x19,%bl
  8019f0:	77 29                	ja     801a1b <strtol+0xb3>
			dig = *s - 'a' + 10;
  8019f2:	0f be d2             	movsbl %dl,%edx
  8019f5:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019f8:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019fb:	7d 30                	jge    801a2d <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8019fd:	83 c1 01             	add    $0x1,%ecx
  801a00:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a04:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801a06:	0f b6 11             	movzbl (%ecx),%edx
  801a09:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a0c:	89 f3                	mov    %esi,%ebx
  801a0e:	80 fb 09             	cmp    $0x9,%bl
  801a11:	77 d5                	ja     8019e8 <strtol+0x80>
			dig = *s - '0';
  801a13:	0f be d2             	movsbl %dl,%edx
  801a16:	83 ea 30             	sub    $0x30,%edx
  801a19:	eb dd                	jmp    8019f8 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  801a1b:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a1e:	89 f3                	mov    %esi,%ebx
  801a20:	80 fb 19             	cmp    $0x19,%bl
  801a23:	77 08                	ja     801a2d <strtol+0xc5>
			dig = *s - 'A' + 10;
  801a25:	0f be d2             	movsbl %dl,%edx
  801a28:	83 ea 37             	sub    $0x37,%edx
  801a2b:	eb cb                	jmp    8019f8 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  801a2d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a31:	74 05                	je     801a38 <strtol+0xd0>
		*endptr = (char *) s;
  801a33:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a36:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a38:	89 c2                	mov    %eax,%edx
  801a3a:	f7 da                	neg    %edx
  801a3c:	85 ff                	test   %edi,%edi
  801a3e:	0f 45 c2             	cmovne %edx,%eax
}
  801a41:	5b                   	pop    %ebx
  801a42:	5e                   	pop    %esi
  801a43:	5f                   	pop    %edi
  801a44:	5d                   	pop    %ebp
  801a45:	c3                   	ret    

00801a46 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a46:	55                   	push   %ebp
  801a47:	89 e5                	mov    %esp,%ebp
  801a49:	56                   	push   %esi
  801a4a:	53                   	push   %ebx
  801a4b:	8b 75 08             	mov    0x8(%ebp),%esi
  801a4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a51:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        //	panic("ipc_recv not implemented");
        int r;
       	if(pg!=NULL){
  801a54:	85 c0                	test   %eax,%eax
  801a56:	74 3b                	je     801a93 <ipc_recv+0x4d>
	  r = sys_ipc_recv(pg);
  801a58:	83 ec 0c             	sub    $0xc,%esp
  801a5b:	50                   	push   %eax
  801a5c:	e8 b2 e8 ff ff       	call   800313 <sys_ipc_recv>
  801a61:	83 c4 10             	add    $0x10,%esp
	}else
	  r = sys_ipc_recv((void *)UTOP);
	if(r<0){
  801a64:	85 c0                	test   %eax,%eax
  801a66:	78 3d                	js     801aa5 <ipc_recv+0x5f>
	if(perm_store!=NULL){
		*perm_store = 0;
            }
        	return r;
           }else{
	     if(from_env_store!=NULL)
  801a68:	85 f6                	test   %esi,%esi
  801a6a:	74 0a                	je     801a76 <ipc_recv+0x30>
		     *from_env_store = thisenv->env_ipc_from;
  801a6c:	a1 04 40 80 00       	mov    0x804004,%eax
  801a71:	8b 40 74             	mov    0x74(%eax),%eax
  801a74:	89 06                	mov    %eax,(%esi)
	     if(perm_store != NULL)
  801a76:	85 db                	test   %ebx,%ebx
  801a78:	74 0a                	je     801a84 <ipc_recv+0x3e>
		     *perm_store = thisenv->env_ipc_perm;
  801a7a:	a1 04 40 80 00       	mov    0x804004,%eax
  801a7f:	8b 40 78             	mov    0x78(%eax),%eax
  801a82:	89 03                	mov    %eax,(%ebx)
	     return thisenv->env_ipc_value;
  801a84:	a1 04 40 80 00       	mov    0x804004,%eax
  801a89:	8b 40 70             	mov    0x70(%eax),%eax
	   }

}
  801a8c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a8f:	5b                   	pop    %ebx
  801a90:	5e                   	pop    %esi
  801a91:	5d                   	pop    %ebp
  801a92:	c3                   	ret    
	  r = sys_ipc_recv((void *)UTOP);
  801a93:	83 ec 0c             	sub    $0xc,%esp
  801a96:	68 00 00 c0 ee       	push   $0xeec00000
  801a9b:	e8 73 e8 ff ff       	call   800313 <sys_ipc_recv>
  801aa0:	83 c4 10             	add    $0x10,%esp
  801aa3:	eb bf                	jmp    801a64 <ipc_recv+0x1e>
	if(from_env_store!=NULL){
  801aa5:	85 f6                	test   %esi,%esi
  801aa7:	74 06                	je     801aaf <ipc_recv+0x69>
	  *from_env_store = 0;
  801aa9:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(perm_store!=NULL){
  801aaf:	85 db                	test   %ebx,%ebx
  801ab1:	74 d9                	je     801a8c <ipc_recv+0x46>
		*perm_store = 0;
  801ab3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ab9:	eb d1                	jmp    801a8c <ipc_recv+0x46>

00801abb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801abb:	55                   	push   %ebp
  801abc:	89 e5                	mov    %esp,%ebp
  801abe:	57                   	push   %edi
  801abf:	56                   	push   %esi
  801ac0:	53                   	push   %ebx
  801ac1:	83 ec 0c             	sub    $0xc,%esp
  801ac4:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ac7:	8b 75 0c             	mov    0xc(%ebp),%esi
  801aca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if(pg==NULL) pg = (void *)UTOP;
  801acd:	85 db                	test   %ebx,%ebx
  801acf:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ad4:	0f 44 d8             	cmove  %eax,%ebx
	while((r=sys_ipc_try_send(to_env,val,pg,perm))<0){
  801ad7:	ff 75 14             	pushl  0x14(%ebp)
  801ada:	53                   	push   %ebx
  801adb:	56                   	push   %esi
  801adc:	57                   	push   %edi
  801add:	e8 0e e8 ff ff       	call   8002f0 <sys_ipc_try_send>
  801ae2:	83 c4 10             	add    $0x10,%esp
  801ae5:	85 c0                	test   %eax,%eax
  801ae7:	79 20                	jns    801b09 <ipc_send+0x4e>
	    if(r!=-E_IPC_NOT_RECV){
  801ae9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801aec:	75 07                	jne    801af5 <ipc_send+0x3a>
		    panic("ipc_send:send message failed\n");
	    }
	    sys_yield();
  801aee:	e8 51 e6 ff ff       	call   800144 <sys_yield>
  801af3:	eb e2                	jmp    801ad7 <ipc_send+0x1c>
		    panic("ipc_send:send message failed\n");
  801af5:	83 ec 04             	sub    $0x4,%esp
  801af8:	68 20 22 80 00       	push   $0x802220
  801afd:	6a 43                	push   $0x43
  801aff:	68 3e 22 80 00       	push   $0x80223e
  801b04:	e8 06 f5 ff ff       	call   80100f <_panic>
	}

}
  801b09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b0c:	5b                   	pop    %ebx
  801b0d:	5e                   	pop    %esi
  801b0e:	5f                   	pop    %edi
  801b0f:	5d                   	pop    %ebp
  801b10:	c3                   	ret    

00801b11 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b11:	55                   	push   %ebp
  801b12:	89 e5                	mov    %esp,%ebp
  801b14:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b17:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b1c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b1f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b25:	8b 52 50             	mov    0x50(%edx),%edx
  801b28:	39 ca                	cmp    %ecx,%edx
  801b2a:	74 11                	je     801b3d <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801b2c:	83 c0 01             	add    $0x1,%eax
  801b2f:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b34:	75 e6                	jne    801b1c <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801b36:	b8 00 00 00 00       	mov    $0x0,%eax
  801b3b:	eb 0b                	jmp    801b48 <ipc_find_env+0x37>
			return envs[i].env_id;
  801b3d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b40:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b45:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b48:	5d                   	pop    %ebp
  801b49:	c3                   	ret    

00801b4a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b4a:	55                   	push   %ebp
  801b4b:	89 e5                	mov    %esp,%ebp
  801b4d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b50:	89 d0                	mov    %edx,%eax
  801b52:	c1 e8 16             	shr    $0x16,%eax
  801b55:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b5c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801b61:	f6 c1 01             	test   $0x1,%cl
  801b64:	74 1d                	je     801b83 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801b66:	c1 ea 0c             	shr    $0xc,%edx
  801b69:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b70:	f6 c2 01             	test   $0x1,%dl
  801b73:	74 0e                	je     801b83 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b75:	c1 ea 0c             	shr    $0xc,%edx
  801b78:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b7f:	ef 
  801b80:	0f b7 c0             	movzwl %ax,%eax
}
  801b83:	5d                   	pop    %ebp
  801b84:	c3                   	ret    
  801b85:	66 90                	xchg   %ax,%ax
  801b87:	66 90                	xchg   %ax,%ax
  801b89:	66 90                	xchg   %ax,%ax
  801b8b:	66 90                	xchg   %ax,%ax
  801b8d:	66 90                	xchg   %ax,%ax
  801b8f:	90                   	nop

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
