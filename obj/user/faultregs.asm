
obj/user/faultregs.debug:     file format elf32-i386


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
  80002c:	e8 ae 05 00 00       	call   8005df <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	ff 75 08             	pushl  0x8(%ebp)
  800043:	52                   	push   %edx
  800044:	68 31 24 80 00       	push   $0x802431
  800049:	68 00 24 80 00       	push   $0x802400
  80004e:	e8 c7 06 00 00       	call   80071a <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 10 24 80 00       	push   $0x802410
  80005c:	68 14 24 80 00       	push   $0x802414
  800061:	e8 b4 06 00 00       	call   80071a <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	0f 84 31 02 00 00    	je     8002a4 <check_regs+0x271>
  800073:	83 ec 0c             	sub    $0xc,%esp
  800076:	68 28 24 80 00       	push   $0x802428
  80007b:	e8 9a 06 00 00       	call   80071a <cprintf>
  800080:	83 c4 10             	add    $0x10,%esp
  800083:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  800088:	ff 73 04             	pushl  0x4(%ebx)
  80008b:	ff 76 04             	pushl  0x4(%esi)
  80008e:	68 32 24 80 00       	push   $0x802432
  800093:	68 14 24 80 00       	push   $0x802414
  800098:	e8 7d 06 00 00       	call   80071a <cprintf>
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	8b 43 04             	mov    0x4(%ebx),%eax
  8000a3:	39 46 04             	cmp    %eax,0x4(%esi)
  8000a6:	0f 84 12 02 00 00    	je     8002be <check_regs+0x28b>
  8000ac:	83 ec 0c             	sub    $0xc,%esp
  8000af:	68 28 24 80 00       	push   $0x802428
  8000b4:	e8 61 06 00 00       	call   80071a <cprintf>
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000c1:	ff 73 08             	pushl  0x8(%ebx)
  8000c4:	ff 76 08             	pushl  0x8(%esi)
  8000c7:	68 36 24 80 00       	push   $0x802436
  8000cc:	68 14 24 80 00       	push   $0x802414
  8000d1:	e8 44 06 00 00       	call   80071a <cprintf>
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	8b 43 08             	mov    0x8(%ebx),%eax
  8000dc:	39 46 08             	cmp    %eax,0x8(%esi)
  8000df:	0f 84 ee 01 00 00    	je     8002d3 <check_regs+0x2a0>
  8000e5:	83 ec 0c             	sub    $0xc,%esp
  8000e8:	68 28 24 80 00       	push   $0x802428
  8000ed:	e8 28 06 00 00       	call   80071a <cprintf>
  8000f2:	83 c4 10             	add    $0x10,%esp
  8000f5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  8000fa:	ff 73 10             	pushl  0x10(%ebx)
  8000fd:	ff 76 10             	pushl  0x10(%esi)
  800100:	68 3a 24 80 00       	push   $0x80243a
  800105:	68 14 24 80 00       	push   $0x802414
  80010a:	e8 0b 06 00 00       	call   80071a <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	8b 43 10             	mov    0x10(%ebx),%eax
  800115:	39 46 10             	cmp    %eax,0x10(%esi)
  800118:	0f 84 ca 01 00 00    	je     8002e8 <check_regs+0x2b5>
  80011e:	83 ec 0c             	sub    $0xc,%esp
  800121:	68 28 24 80 00       	push   $0x802428
  800126:	e8 ef 05 00 00       	call   80071a <cprintf>
  80012b:	83 c4 10             	add    $0x10,%esp
  80012e:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800133:	ff 73 14             	pushl  0x14(%ebx)
  800136:	ff 76 14             	pushl  0x14(%esi)
  800139:	68 3e 24 80 00       	push   $0x80243e
  80013e:	68 14 24 80 00       	push   $0x802414
  800143:	e8 d2 05 00 00       	call   80071a <cprintf>
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	8b 43 14             	mov    0x14(%ebx),%eax
  80014e:	39 46 14             	cmp    %eax,0x14(%esi)
  800151:	0f 84 a6 01 00 00    	je     8002fd <check_regs+0x2ca>
  800157:	83 ec 0c             	sub    $0xc,%esp
  80015a:	68 28 24 80 00       	push   $0x802428
  80015f:	e8 b6 05 00 00       	call   80071a <cprintf>
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  80016c:	ff 73 18             	pushl  0x18(%ebx)
  80016f:	ff 76 18             	pushl  0x18(%esi)
  800172:	68 42 24 80 00       	push   $0x802442
  800177:	68 14 24 80 00       	push   $0x802414
  80017c:	e8 99 05 00 00       	call   80071a <cprintf>
  800181:	83 c4 10             	add    $0x10,%esp
  800184:	8b 43 18             	mov    0x18(%ebx),%eax
  800187:	39 46 18             	cmp    %eax,0x18(%esi)
  80018a:	0f 84 82 01 00 00    	je     800312 <check_regs+0x2df>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 28 24 80 00       	push   $0x802428
  800198:	e8 7d 05 00 00       	call   80071a <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001a5:	ff 73 1c             	pushl  0x1c(%ebx)
  8001a8:	ff 76 1c             	pushl  0x1c(%esi)
  8001ab:	68 46 24 80 00       	push   $0x802446
  8001b0:	68 14 24 80 00       	push   $0x802414
  8001b5:	e8 60 05 00 00       	call   80071a <cprintf>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	8b 43 1c             	mov    0x1c(%ebx),%eax
  8001c0:	39 46 1c             	cmp    %eax,0x1c(%esi)
  8001c3:	0f 84 5e 01 00 00    	je     800327 <check_regs+0x2f4>
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	68 28 24 80 00       	push   $0x802428
  8001d1:	e8 44 05 00 00       	call   80071a <cprintf>
  8001d6:	83 c4 10             	add    $0x10,%esp
  8001d9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  8001de:	ff 73 20             	pushl  0x20(%ebx)
  8001e1:	ff 76 20             	pushl  0x20(%esi)
  8001e4:	68 4a 24 80 00       	push   $0x80244a
  8001e9:	68 14 24 80 00       	push   $0x802414
  8001ee:	e8 27 05 00 00       	call   80071a <cprintf>
  8001f3:	83 c4 10             	add    $0x10,%esp
  8001f6:	8b 43 20             	mov    0x20(%ebx),%eax
  8001f9:	39 46 20             	cmp    %eax,0x20(%esi)
  8001fc:	0f 84 3a 01 00 00    	je     80033c <check_regs+0x309>
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	68 28 24 80 00       	push   $0x802428
  80020a:	e8 0b 05 00 00       	call   80071a <cprintf>
  80020f:	83 c4 10             	add    $0x10,%esp
  800212:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  800217:	ff 73 24             	pushl  0x24(%ebx)
  80021a:	ff 76 24             	pushl  0x24(%esi)
  80021d:	68 4e 24 80 00       	push   $0x80244e
  800222:	68 14 24 80 00       	push   $0x802414
  800227:	e8 ee 04 00 00       	call   80071a <cprintf>
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	8b 43 24             	mov    0x24(%ebx),%eax
  800232:	39 46 24             	cmp    %eax,0x24(%esi)
  800235:	0f 84 16 01 00 00    	je     800351 <check_regs+0x31e>
  80023b:	83 ec 0c             	sub    $0xc,%esp
  80023e:	68 28 24 80 00       	push   $0x802428
  800243:	e8 d2 04 00 00       	call   80071a <cprintf>
	CHECK(esp, esp);
  800248:	ff 73 28             	pushl  0x28(%ebx)
  80024b:	ff 76 28             	pushl  0x28(%esi)
  80024e:	68 55 24 80 00       	push   $0x802455
  800253:	68 14 24 80 00       	push   $0x802414
  800258:	e8 bd 04 00 00       	call   80071a <cprintf>
  80025d:	83 c4 20             	add    $0x20,%esp
  800260:	8b 43 28             	mov    0x28(%ebx),%eax
  800263:	39 46 28             	cmp    %eax,0x28(%esi)
  800266:	0f 84 53 01 00 00    	je     8003bf <check_regs+0x38c>
  80026c:	83 ec 0c             	sub    $0xc,%esp
  80026f:	68 28 24 80 00       	push   $0x802428
  800274:	e8 a1 04 00 00       	call   80071a <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800279:	83 c4 08             	add    $0x8,%esp
  80027c:	ff 75 0c             	pushl  0xc(%ebp)
  80027f:	68 59 24 80 00       	push   $0x802459
  800284:	e8 91 04 00 00       	call   80071a <cprintf>
  800289:	83 c4 10             	add    $0x10,%esp
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
  80028c:	83 ec 0c             	sub    $0xc,%esp
  80028f:	68 28 24 80 00       	push   $0x802428
  800294:	e8 81 04 00 00       	call   80071a <cprintf>
  800299:	83 c4 10             	add    $0x10,%esp
}
  80029c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029f:	5b                   	pop    %ebx
  8002a0:	5e                   	pop    %esi
  8002a1:	5f                   	pop    %edi
  8002a2:	5d                   	pop    %ebp
  8002a3:	c3                   	ret    
	CHECK(edi, regs.reg_edi);
  8002a4:	83 ec 0c             	sub    $0xc,%esp
  8002a7:	68 24 24 80 00       	push   $0x802424
  8002ac:	e8 69 04 00 00       	call   80071a <cprintf>
  8002b1:	83 c4 10             	add    $0x10,%esp
	int mismatch = 0;
  8002b4:	bf 00 00 00 00       	mov    $0x0,%edi
  8002b9:	e9 ca fd ff ff       	jmp    800088 <check_regs+0x55>
	CHECK(esi, regs.reg_esi);
  8002be:	83 ec 0c             	sub    $0xc,%esp
  8002c1:	68 24 24 80 00       	push   $0x802424
  8002c6:	e8 4f 04 00 00       	call   80071a <cprintf>
  8002cb:	83 c4 10             	add    $0x10,%esp
  8002ce:	e9 ee fd ff ff       	jmp    8000c1 <check_regs+0x8e>
	CHECK(ebp, regs.reg_ebp);
  8002d3:	83 ec 0c             	sub    $0xc,%esp
  8002d6:	68 24 24 80 00       	push   $0x802424
  8002db:	e8 3a 04 00 00       	call   80071a <cprintf>
  8002e0:	83 c4 10             	add    $0x10,%esp
  8002e3:	e9 12 fe ff ff       	jmp    8000fa <check_regs+0xc7>
	CHECK(ebx, regs.reg_ebx);
  8002e8:	83 ec 0c             	sub    $0xc,%esp
  8002eb:	68 24 24 80 00       	push   $0x802424
  8002f0:	e8 25 04 00 00       	call   80071a <cprintf>
  8002f5:	83 c4 10             	add    $0x10,%esp
  8002f8:	e9 36 fe ff ff       	jmp    800133 <check_regs+0x100>
	CHECK(edx, regs.reg_edx);
  8002fd:	83 ec 0c             	sub    $0xc,%esp
  800300:	68 24 24 80 00       	push   $0x802424
  800305:	e8 10 04 00 00       	call   80071a <cprintf>
  80030a:	83 c4 10             	add    $0x10,%esp
  80030d:	e9 5a fe ff ff       	jmp    80016c <check_regs+0x139>
	CHECK(ecx, regs.reg_ecx);
  800312:	83 ec 0c             	sub    $0xc,%esp
  800315:	68 24 24 80 00       	push   $0x802424
  80031a:	e8 fb 03 00 00       	call   80071a <cprintf>
  80031f:	83 c4 10             	add    $0x10,%esp
  800322:	e9 7e fe ff ff       	jmp    8001a5 <check_regs+0x172>
	CHECK(eax, regs.reg_eax);
  800327:	83 ec 0c             	sub    $0xc,%esp
  80032a:	68 24 24 80 00       	push   $0x802424
  80032f:	e8 e6 03 00 00       	call   80071a <cprintf>
  800334:	83 c4 10             	add    $0x10,%esp
  800337:	e9 a2 fe ff ff       	jmp    8001de <check_regs+0x1ab>
	CHECK(eip, eip);
  80033c:	83 ec 0c             	sub    $0xc,%esp
  80033f:	68 24 24 80 00       	push   $0x802424
  800344:	e8 d1 03 00 00       	call   80071a <cprintf>
  800349:	83 c4 10             	add    $0x10,%esp
  80034c:	e9 c6 fe ff ff       	jmp    800217 <check_regs+0x1e4>
	CHECK(eflags, eflags);
  800351:	83 ec 0c             	sub    $0xc,%esp
  800354:	68 24 24 80 00       	push   $0x802424
  800359:	e8 bc 03 00 00       	call   80071a <cprintf>
	CHECK(esp, esp);
  80035e:	ff 73 28             	pushl  0x28(%ebx)
  800361:	ff 76 28             	pushl  0x28(%esi)
  800364:	68 55 24 80 00       	push   $0x802455
  800369:	68 14 24 80 00       	push   $0x802414
  80036e:	e8 a7 03 00 00       	call   80071a <cprintf>
  800373:	83 c4 20             	add    $0x20,%esp
  800376:	8b 43 28             	mov    0x28(%ebx),%eax
  800379:	39 46 28             	cmp    %eax,0x28(%esi)
  80037c:	0f 85 ea fe ff ff    	jne    80026c <check_regs+0x239>
  800382:	83 ec 0c             	sub    $0xc,%esp
  800385:	68 24 24 80 00       	push   $0x802424
  80038a:	e8 8b 03 00 00       	call   80071a <cprintf>
	cprintf("Registers %s ", testname);
  80038f:	83 c4 08             	add    $0x8,%esp
  800392:	ff 75 0c             	pushl  0xc(%ebp)
  800395:	68 59 24 80 00       	push   $0x802459
  80039a:	e8 7b 03 00 00       	call   80071a <cprintf>
	if (!mismatch)
  80039f:	83 c4 10             	add    $0x10,%esp
  8003a2:	85 ff                	test   %edi,%edi
  8003a4:	0f 85 e2 fe ff ff    	jne    80028c <check_regs+0x259>
		cprintf("OK\n");
  8003aa:	83 ec 0c             	sub    $0xc,%esp
  8003ad:	68 24 24 80 00       	push   $0x802424
  8003b2:	e8 63 03 00 00       	call   80071a <cprintf>
  8003b7:	83 c4 10             	add    $0x10,%esp
  8003ba:	e9 dd fe ff ff       	jmp    80029c <check_regs+0x269>
	CHECK(esp, esp);
  8003bf:	83 ec 0c             	sub    $0xc,%esp
  8003c2:	68 24 24 80 00       	push   $0x802424
  8003c7:	e8 4e 03 00 00       	call   80071a <cprintf>
	cprintf("Registers %s ", testname);
  8003cc:	83 c4 08             	add    $0x8,%esp
  8003cf:	ff 75 0c             	pushl  0xc(%ebp)
  8003d2:	68 59 24 80 00       	push   $0x802459
  8003d7:	e8 3e 03 00 00       	call   80071a <cprintf>
  8003dc:	83 c4 10             	add    $0x10,%esp
  8003df:	e9 a8 fe ff ff       	jmp    80028c <check_regs+0x259>

008003e4 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  8003e4:	55                   	push   %ebp
  8003e5:	89 e5                	mov    %esp,%ebp
  8003e7:	83 ec 08             	sub    $0x8,%esp
  8003ea:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8003ed:	8b 10                	mov    (%eax),%edx
  8003ef:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8003f5:	0f 85 a3 00 00 00    	jne    80049e <pgfault+0xba>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003fb:	8b 50 08             	mov    0x8(%eax),%edx
  8003fe:	89 15 40 40 80 00    	mov    %edx,0x804040
  800404:	8b 50 0c             	mov    0xc(%eax),%edx
  800407:	89 15 44 40 80 00    	mov    %edx,0x804044
  80040d:	8b 50 10             	mov    0x10(%eax),%edx
  800410:	89 15 48 40 80 00    	mov    %edx,0x804048
  800416:	8b 50 14             	mov    0x14(%eax),%edx
  800419:	89 15 4c 40 80 00    	mov    %edx,0x80404c
  80041f:	8b 50 18             	mov    0x18(%eax),%edx
  800422:	89 15 50 40 80 00    	mov    %edx,0x804050
  800428:	8b 50 1c             	mov    0x1c(%eax),%edx
  80042b:	89 15 54 40 80 00    	mov    %edx,0x804054
  800431:	8b 50 20             	mov    0x20(%eax),%edx
  800434:	89 15 58 40 80 00    	mov    %edx,0x804058
  80043a:	8b 50 24             	mov    0x24(%eax),%edx
  80043d:	89 15 5c 40 80 00    	mov    %edx,0x80405c
	during.eip = utf->utf_eip;
  800443:	8b 50 28             	mov    0x28(%eax),%edx
  800446:	89 15 60 40 80 00    	mov    %edx,0x804060
	during.eflags = utf->utf_eflags & ~FL_RF;
  80044c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80044f:	81 e2 ff ff fe ff    	and    $0xfffeffff,%edx
  800455:	89 15 64 40 80 00    	mov    %edx,0x804064
	during.esp = utf->utf_esp;
  80045b:	8b 40 30             	mov    0x30(%eax),%eax
  80045e:	a3 68 40 80 00       	mov    %eax,0x804068
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  800463:	83 ec 08             	sub    $0x8,%esp
  800466:	68 7f 24 80 00       	push   $0x80247f
  80046b:	68 8d 24 80 00       	push   $0x80248d
  800470:	b9 40 40 80 00       	mov    $0x804040,%ecx
  800475:	ba 78 24 80 00       	mov    $0x802478,%edx
  80047a:	b8 80 40 80 00       	mov    $0x804080,%eax
  80047f:	e8 af fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800484:	83 c4 0c             	add    $0xc,%esp
  800487:	6a 07                	push   $0x7
  800489:	68 00 00 40 00       	push   $0x400000
  80048e:	6a 00                	push   $0x0
  800490:	e8 9d 0c 00 00       	call   801132 <sys_page_alloc>
  800495:	83 c4 10             	add    $0x10,%esp
  800498:	85 c0                	test   %eax,%eax
  80049a:	78 1a                	js     8004b6 <pgfault+0xd2>
		panic("sys_page_alloc: %e", r);
}
  80049c:	c9                   	leave  
  80049d:	c3                   	ret    
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  80049e:	83 ec 0c             	sub    $0xc,%esp
  8004a1:	ff 70 28             	pushl  0x28(%eax)
  8004a4:	52                   	push   %edx
  8004a5:	68 c0 24 80 00       	push   $0x8024c0
  8004aa:	6a 51                	push   $0x51
  8004ac:	68 67 24 80 00       	push   $0x802467
  8004b1:	e8 89 01 00 00       	call   80063f <_panic>
		panic("sys_page_alloc: %e", r);
  8004b6:	50                   	push   %eax
  8004b7:	68 94 24 80 00       	push   $0x802494
  8004bc:	6a 5c                	push   $0x5c
  8004be:	68 67 24 80 00       	push   $0x802467
  8004c3:	e8 77 01 00 00       	call   80063f <_panic>

008004c8 <umain>:

void
umain(int argc, char **argv)
{
  8004c8:	55                   	push   %ebp
  8004c9:	89 e5                	mov    %esp,%ebp
  8004cb:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  8004ce:	68 e4 03 80 00       	push   $0x8003e4
  8004d3:	e8 4b 0e 00 00       	call   801323 <set_pgfault_handler>

	asm volatile(
  8004d8:	50                   	push   %eax
  8004d9:	9c                   	pushf  
  8004da:	58                   	pop    %eax
  8004db:	0d d5 08 00 00       	or     $0x8d5,%eax
  8004e0:	50                   	push   %eax
  8004e1:	9d                   	popf   
  8004e2:	a3 a4 40 80 00       	mov    %eax,0x8040a4
  8004e7:	8d 05 22 05 80 00    	lea    0x800522,%eax
  8004ed:	a3 a0 40 80 00       	mov    %eax,0x8040a0
  8004f2:	58                   	pop    %eax
  8004f3:	89 3d 80 40 80 00    	mov    %edi,0x804080
  8004f9:	89 35 84 40 80 00    	mov    %esi,0x804084
  8004ff:	89 2d 88 40 80 00    	mov    %ebp,0x804088
  800505:	89 1d 90 40 80 00    	mov    %ebx,0x804090
  80050b:	89 15 94 40 80 00    	mov    %edx,0x804094
  800511:	89 0d 98 40 80 00    	mov    %ecx,0x804098
  800517:	a3 9c 40 80 00       	mov    %eax,0x80409c
  80051c:	89 25 a8 40 80 00    	mov    %esp,0x8040a8
  800522:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  800529:	00 00 00 
  80052c:	89 3d 00 40 80 00    	mov    %edi,0x804000
  800532:	89 35 04 40 80 00    	mov    %esi,0x804004
  800538:	89 2d 08 40 80 00    	mov    %ebp,0x804008
  80053e:	89 1d 10 40 80 00    	mov    %ebx,0x804010
  800544:	89 15 14 40 80 00    	mov    %edx,0x804014
  80054a:	89 0d 18 40 80 00    	mov    %ecx,0x804018
  800550:	a3 1c 40 80 00       	mov    %eax,0x80401c
  800555:	89 25 28 40 80 00    	mov    %esp,0x804028
  80055b:	8b 3d 80 40 80 00    	mov    0x804080,%edi
  800561:	8b 35 84 40 80 00    	mov    0x804084,%esi
  800567:	8b 2d 88 40 80 00    	mov    0x804088,%ebp
  80056d:	8b 1d 90 40 80 00    	mov    0x804090,%ebx
  800573:	8b 15 94 40 80 00    	mov    0x804094,%edx
  800579:	8b 0d 98 40 80 00    	mov    0x804098,%ecx
  80057f:	a1 9c 40 80 00       	mov    0x80409c,%eax
  800584:	8b 25 a8 40 80 00    	mov    0x8040a8,%esp
  80058a:	50                   	push   %eax
  80058b:	9c                   	pushf  
  80058c:	58                   	pop    %eax
  80058d:	a3 24 40 80 00       	mov    %eax,0x804024
  800592:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  80059d:	74 10                	je     8005af <umain+0xe7>
		cprintf("EIP after page-fault MISMATCH\n");
  80059f:	83 ec 0c             	sub    $0xc,%esp
  8005a2:	68 f4 24 80 00       	push   $0x8024f4
  8005a7:	e8 6e 01 00 00       	call   80071a <cprintf>
  8005ac:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  8005af:	a1 a0 40 80 00       	mov    0x8040a0,%eax
  8005b4:	a3 20 40 80 00       	mov    %eax,0x804020

	check_regs(&before, "before", &after, "after", "after page-fault");
  8005b9:	83 ec 08             	sub    $0x8,%esp
  8005bc:	68 a7 24 80 00       	push   $0x8024a7
  8005c1:	68 b8 24 80 00       	push   $0x8024b8
  8005c6:	b9 00 40 80 00       	mov    $0x804000,%ecx
  8005cb:	ba 78 24 80 00       	mov    $0x802478,%edx
  8005d0:	b8 80 40 80 00       	mov    $0x804080,%eax
  8005d5:	e8 59 fa ff ff       	call   800033 <check_regs>
}
  8005da:	83 c4 10             	add    $0x10,%esp
  8005dd:	c9                   	leave  
  8005de:	c3                   	ret    

008005df <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8005df:	55                   	push   %ebp
  8005e0:	89 e5                	mov    %esp,%ebp
  8005e2:	56                   	push   %esi
  8005e3:	53                   	push   %ebx
  8005e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8005e7:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8005ea:	e8 05 0b 00 00       	call   8010f4 <sys_getenvid>
  8005ef:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005f4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005f7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005fc:	a3 b0 40 80 00       	mov    %eax,0x8040b0
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800601:	85 db                	test   %ebx,%ebx
  800603:	7e 07                	jle    80060c <libmain+0x2d>
		binaryname = argv[0];
  800605:	8b 06                	mov    (%esi),%eax
  800607:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80060c:	83 ec 08             	sub    $0x8,%esp
  80060f:	56                   	push   %esi
  800610:	53                   	push   %ebx
  800611:	e8 b2 fe ff ff       	call   8004c8 <umain>

	// exit gracefully
	exit();
  800616:	e8 0a 00 00 00       	call   800625 <exit>
}
  80061b:	83 c4 10             	add    $0x10,%esp
  80061e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800621:	5b                   	pop    %ebx
  800622:	5e                   	pop    %esi
  800623:	5d                   	pop    %ebp
  800624:	c3                   	ret    

00800625 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800625:	55                   	push   %ebp
  800626:	89 e5                	mov    %esp,%ebp
  800628:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80062b:	e8 55 0f 00 00       	call   801585 <close_all>
	sys_env_destroy(0);
  800630:	83 ec 0c             	sub    $0xc,%esp
  800633:	6a 00                	push   $0x0
  800635:	e8 79 0a 00 00       	call   8010b3 <sys_env_destroy>
}
  80063a:	83 c4 10             	add    $0x10,%esp
  80063d:	c9                   	leave  
  80063e:	c3                   	ret    

0080063f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80063f:	55                   	push   %ebp
  800640:	89 e5                	mov    %esp,%ebp
  800642:	56                   	push   %esi
  800643:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800644:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800647:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80064d:	e8 a2 0a 00 00       	call   8010f4 <sys_getenvid>
  800652:	83 ec 0c             	sub    $0xc,%esp
  800655:	ff 75 0c             	pushl  0xc(%ebp)
  800658:	ff 75 08             	pushl  0x8(%ebp)
  80065b:	56                   	push   %esi
  80065c:	50                   	push   %eax
  80065d:	68 20 25 80 00       	push   $0x802520
  800662:	e8 b3 00 00 00       	call   80071a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800667:	83 c4 18             	add    $0x18,%esp
  80066a:	53                   	push   %ebx
  80066b:	ff 75 10             	pushl  0x10(%ebp)
  80066e:	e8 56 00 00 00       	call   8006c9 <vcprintf>
	cprintf("\n");
  800673:	c7 04 24 30 24 80 00 	movl   $0x802430,(%esp)
  80067a:	e8 9b 00 00 00       	call   80071a <cprintf>
  80067f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800682:	cc                   	int3   
  800683:	eb fd                	jmp    800682 <_panic+0x43>

00800685 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800685:	55                   	push   %ebp
  800686:	89 e5                	mov    %esp,%ebp
  800688:	53                   	push   %ebx
  800689:	83 ec 04             	sub    $0x4,%esp
  80068c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80068f:	8b 13                	mov    (%ebx),%edx
  800691:	8d 42 01             	lea    0x1(%edx),%eax
  800694:	89 03                	mov    %eax,(%ebx)
  800696:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800699:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80069d:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006a2:	74 09                	je     8006ad <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8006a4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8006a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006ab:	c9                   	leave  
  8006ac:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8006ad:	83 ec 08             	sub    $0x8,%esp
  8006b0:	68 ff 00 00 00       	push   $0xff
  8006b5:	8d 43 08             	lea    0x8(%ebx),%eax
  8006b8:	50                   	push   %eax
  8006b9:	e8 b8 09 00 00       	call   801076 <sys_cputs>
		b->idx = 0;
  8006be:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8006c4:	83 c4 10             	add    $0x10,%esp
  8006c7:	eb db                	jmp    8006a4 <putch+0x1f>

008006c9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8006c9:	55                   	push   %ebp
  8006ca:	89 e5                	mov    %esp,%ebp
  8006cc:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8006d2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8006d9:	00 00 00 
	b.cnt = 0;
  8006dc:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8006e3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8006e6:	ff 75 0c             	pushl  0xc(%ebp)
  8006e9:	ff 75 08             	pushl  0x8(%ebp)
  8006ec:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006f2:	50                   	push   %eax
  8006f3:	68 85 06 80 00       	push   $0x800685
  8006f8:	e8 1a 01 00 00       	call   800817 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006fd:	83 c4 08             	add    $0x8,%esp
  800700:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800706:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80070c:	50                   	push   %eax
  80070d:	e8 64 09 00 00       	call   801076 <sys_cputs>

	return b.cnt;
}
  800712:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800718:	c9                   	leave  
  800719:	c3                   	ret    

0080071a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80071a:	55                   	push   %ebp
  80071b:	89 e5                	mov    %esp,%ebp
  80071d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800720:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800723:	50                   	push   %eax
  800724:	ff 75 08             	pushl  0x8(%ebp)
  800727:	e8 9d ff ff ff       	call   8006c9 <vcprintf>
	va_end(ap);

	return cnt;
}
  80072c:	c9                   	leave  
  80072d:	c3                   	ret    

0080072e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80072e:	55                   	push   %ebp
  80072f:	89 e5                	mov    %esp,%ebp
  800731:	57                   	push   %edi
  800732:	56                   	push   %esi
  800733:	53                   	push   %ebx
  800734:	83 ec 1c             	sub    $0x1c,%esp
  800737:	89 c7                	mov    %eax,%edi
  800739:	89 d6                	mov    %edx,%esi
  80073b:	8b 45 08             	mov    0x8(%ebp),%eax
  80073e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800741:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800744:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800747:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80074a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80074f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800752:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800755:	39 d3                	cmp    %edx,%ebx
  800757:	72 05                	jb     80075e <printnum+0x30>
  800759:	39 45 10             	cmp    %eax,0x10(%ebp)
  80075c:	77 7a                	ja     8007d8 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80075e:	83 ec 0c             	sub    $0xc,%esp
  800761:	ff 75 18             	pushl  0x18(%ebp)
  800764:	8b 45 14             	mov    0x14(%ebp),%eax
  800767:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80076a:	53                   	push   %ebx
  80076b:	ff 75 10             	pushl  0x10(%ebp)
  80076e:	83 ec 08             	sub    $0x8,%esp
  800771:	ff 75 e4             	pushl  -0x1c(%ebp)
  800774:	ff 75 e0             	pushl  -0x20(%ebp)
  800777:	ff 75 dc             	pushl  -0x24(%ebp)
  80077a:	ff 75 d8             	pushl  -0x28(%ebp)
  80077d:	e8 2e 1a 00 00       	call   8021b0 <__udivdi3>
  800782:	83 c4 18             	add    $0x18,%esp
  800785:	52                   	push   %edx
  800786:	50                   	push   %eax
  800787:	89 f2                	mov    %esi,%edx
  800789:	89 f8                	mov    %edi,%eax
  80078b:	e8 9e ff ff ff       	call   80072e <printnum>
  800790:	83 c4 20             	add    $0x20,%esp
  800793:	eb 13                	jmp    8007a8 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800795:	83 ec 08             	sub    $0x8,%esp
  800798:	56                   	push   %esi
  800799:	ff 75 18             	pushl  0x18(%ebp)
  80079c:	ff d7                	call   *%edi
  80079e:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8007a1:	83 eb 01             	sub    $0x1,%ebx
  8007a4:	85 db                	test   %ebx,%ebx
  8007a6:	7f ed                	jg     800795 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007a8:	83 ec 08             	sub    $0x8,%esp
  8007ab:	56                   	push   %esi
  8007ac:	83 ec 04             	sub    $0x4,%esp
  8007af:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8007b5:	ff 75 dc             	pushl  -0x24(%ebp)
  8007b8:	ff 75 d8             	pushl  -0x28(%ebp)
  8007bb:	e8 10 1b 00 00       	call   8022d0 <__umoddi3>
  8007c0:	83 c4 14             	add    $0x14,%esp
  8007c3:	0f be 80 43 25 80 00 	movsbl 0x802543(%eax),%eax
  8007ca:	50                   	push   %eax
  8007cb:	ff d7                	call   *%edi
}
  8007cd:	83 c4 10             	add    $0x10,%esp
  8007d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007d3:	5b                   	pop    %ebx
  8007d4:	5e                   	pop    %esi
  8007d5:	5f                   	pop    %edi
  8007d6:	5d                   	pop    %ebp
  8007d7:	c3                   	ret    
  8007d8:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8007db:	eb c4                	jmp    8007a1 <printnum+0x73>

008007dd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007e3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007e7:	8b 10                	mov    (%eax),%edx
  8007e9:	3b 50 04             	cmp    0x4(%eax),%edx
  8007ec:	73 0a                	jae    8007f8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8007ee:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007f1:	89 08                	mov    %ecx,(%eax)
  8007f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f6:	88 02                	mov    %al,(%edx)
}
  8007f8:	5d                   	pop    %ebp
  8007f9:	c3                   	ret    

008007fa <printfmt>:
{
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800800:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800803:	50                   	push   %eax
  800804:	ff 75 10             	pushl  0x10(%ebp)
  800807:	ff 75 0c             	pushl  0xc(%ebp)
  80080a:	ff 75 08             	pushl  0x8(%ebp)
  80080d:	e8 05 00 00 00       	call   800817 <vprintfmt>
}
  800812:	83 c4 10             	add    $0x10,%esp
  800815:	c9                   	leave  
  800816:	c3                   	ret    

00800817 <vprintfmt>:
{
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	57                   	push   %edi
  80081b:	56                   	push   %esi
  80081c:	53                   	push   %ebx
  80081d:	83 ec 2c             	sub    $0x2c,%esp
  800820:	8b 75 08             	mov    0x8(%ebp),%esi
  800823:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800826:	8b 7d 10             	mov    0x10(%ebp),%edi
  800829:	e9 c1 03 00 00       	jmp    800bef <vprintfmt+0x3d8>
		padc = ' ';
  80082e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800832:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800839:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800840:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800847:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80084c:	8d 47 01             	lea    0x1(%edi),%eax
  80084f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800852:	0f b6 17             	movzbl (%edi),%edx
  800855:	8d 42 dd             	lea    -0x23(%edx),%eax
  800858:	3c 55                	cmp    $0x55,%al
  80085a:	0f 87 12 04 00 00    	ja     800c72 <vprintfmt+0x45b>
  800860:	0f b6 c0             	movzbl %al,%eax
  800863:	ff 24 85 80 26 80 00 	jmp    *0x802680(,%eax,4)
  80086a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80086d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800871:	eb d9                	jmp    80084c <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800873:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800876:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80087a:	eb d0                	jmp    80084c <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80087c:	0f b6 d2             	movzbl %dl,%edx
  80087f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800882:	b8 00 00 00 00       	mov    $0x0,%eax
  800887:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80088a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80088d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800891:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800894:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800897:	83 f9 09             	cmp    $0x9,%ecx
  80089a:	77 55                	ja     8008f1 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80089c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80089f:	eb e9                	jmp    80088a <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8008a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a4:	8b 00                	mov    (%eax),%eax
  8008a6:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ac:	8d 40 04             	lea    0x4(%eax),%eax
  8008af:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8008b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8008b5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008b9:	79 91                	jns    80084c <vprintfmt+0x35>
				width = precision, precision = -1;
  8008bb:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008be:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008c1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008c8:	eb 82                	jmp    80084c <vprintfmt+0x35>
  8008ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008cd:	85 c0                	test   %eax,%eax
  8008cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8008d4:	0f 49 d0             	cmovns %eax,%edx
  8008d7:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8008da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008dd:	e9 6a ff ff ff       	jmp    80084c <vprintfmt+0x35>
  8008e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8008e5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008ec:	e9 5b ff ff ff       	jmp    80084c <vprintfmt+0x35>
  8008f1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8008f4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008f7:	eb bc                	jmp    8008b5 <vprintfmt+0x9e>
			lflag++;
  8008f9:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8008fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8008ff:	e9 48 ff ff ff       	jmp    80084c <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800904:	8b 45 14             	mov    0x14(%ebp),%eax
  800907:	8d 78 04             	lea    0x4(%eax),%edi
  80090a:	83 ec 08             	sub    $0x8,%esp
  80090d:	53                   	push   %ebx
  80090e:	ff 30                	pushl  (%eax)
  800910:	ff d6                	call   *%esi
			break;
  800912:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800915:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800918:	e9 cf 02 00 00       	jmp    800bec <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  80091d:	8b 45 14             	mov    0x14(%ebp),%eax
  800920:	8d 78 04             	lea    0x4(%eax),%edi
  800923:	8b 00                	mov    (%eax),%eax
  800925:	99                   	cltd   
  800926:	31 d0                	xor    %edx,%eax
  800928:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80092a:	83 f8 0f             	cmp    $0xf,%eax
  80092d:	7f 23                	jg     800952 <vprintfmt+0x13b>
  80092f:	8b 14 85 e0 27 80 00 	mov    0x8027e0(,%eax,4),%edx
  800936:	85 d2                	test   %edx,%edx
  800938:	74 18                	je     800952 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  80093a:	52                   	push   %edx
  80093b:	68 39 29 80 00       	push   $0x802939
  800940:	53                   	push   %ebx
  800941:	56                   	push   %esi
  800942:	e8 b3 fe ff ff       	call   8007fa <printfmt>
  800947:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80094a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80094d:	e9 9a 02 00 00       	jmp    800bec <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800952:	50                   	push   %eax
  800953:	68 5b 25 80 00       	push   $0x80255b
  800958:	53                   	push   %ebx
  800959:	56                   	push   %esi
  80095a:	e8 9b fe ff ff       	call   8007fa <printfmt>
  80095f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800962:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800965:	e9 82 02 00 00       	jmp    800bec <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  80096a:	8b 45 14             	mov    0x14(%ebp),%eax
  80096d:	83 c0 04             	add    $0x4,%eax
  800970:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800973:	8b 45 14             	mov    0x14(%ebp),%eax
  800976:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800978:	85 ff                	test   %edi,%edi
  80097a:	b8 54 25 80 00       	mov    $0x802554,%eax
  80097f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800982:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800986:	0f 8e bd 00 00 00    	jle    800a49 <vprintfmt+0x232>
  80098c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800990:	75 0e                	jne    8009a0 <vprintfmt+0x189>
  800992:	89 75 08             	mov    %esi,0x8(%ebp)
  800995:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800998:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80099b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80099e:	eb 6d                	jmp    800a0d <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009a0:	83 ec 08             	sub    $0x8,%esp
  8009a3:	ff 75 d0             	pushl  -0x30(%ebp)
  8009a6:	57                   	push   %edi
  8009a7:	e8 6e 03 00 00       	call   800d1a <strnlen>
  8009ac:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8009af:	29 c1                	sub    %eax,%ecx
  8009b1:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8009b4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8009b7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8009bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009be:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8009c1:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8009c3:	eb 0f                	jmp    8009d4 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8009c5:	83 ec 08             	sub    $0x8,%esp
  8009c8:	53                   	push   %ebx
  8009c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8009cc:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8009ce:	83 ef 01             	sub    $0x1,%edi
  8009d1:	83 c4 10             	add    $0x10,%esp
  8009d4:	85 ff                	test   %edi,%edi
  8009d6:	7f ed                	jg     8009c5 <vprintfmt+0x1ae>
  8009d8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8009db:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8009de:	85 c9                	test   %ecx,%ecx
  8009e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e5:	0f 49 c1             	cmovns %ecx,%eax
  8009e8:	29 c1                	sub    %eax,%ecx
  8009ea:	89 75 08             	mov    %esi,0x8(%ebp)
  8009ed:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8009f0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009f3:	89 cb                	mov    %ecx,%ebx
  8009f5:	eb 16                	jmp    800a0d <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8009f7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8009fb:	75 31                	jne    800a2e <vprintfmt+0x217>
					putch(ch, putdat);
  8009fd:	83 ec 08             	sub    $0x8,%esp
  800a00:	ff 75 0c             	pushl  0xc(%ebp)
  800a03:	50                   	push   %eax
  800a04:	ff 55 08             	call   *0x8(%ebp)
  800a07:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a0a:	83 eb 01             	sub    $0x1,%ebx
  800a0d:	83 c7 01             	add    $0x1,%edi
  800a10:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800a14:	0f be c2             	movsbl %dl,%eax
  800a17:	85 c0                	test   %eax,%eax
  800a19:	74 59                	je     800a74 <vprintfmt+0x25d>
  800a1b:	85 f6                	test   %esi,%esi
  800a1d:	78 d8                	js     8009f7 <vprintfmt+0x1e0>
  800a1f:	83 ee 01             	sub    $0x1,%esi
  800a22:	79 d3                	jns    8009f7 <vprintfmt+0x1e0>
  800a24:	89 df                	mov    %ebx,%edi
  800a26:	8b 75 08             	mov    0x8(%ebp),%esi
  800a29:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a2c:	eb 37                	jmp    800a65 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800a2e:	0f be d2             	movsbl %dl,%edx
  800a31:	83 ea 20             	sub    $0x20,%edx
  800a34:	83 fa 5e             	cmp    $0x5e,%edx
  800a37:	76 c4                	jbe    8009fd <vprintfmt+0x1e6>
					putch('?', putdat);
  800a39:	83 ec 08             	sub    $0x8,%esp
  800a3c:	ff 75 0c             	pushl  0xc(%ebp)
  800a3f:	6a 3f                	push   $0x3f
  800a41:	ff 55 08             	call   *0x8(%ebp)
  800a44:	83 c4 10             	add    $0x10,%esp
  800a47:	eb c1                	jmp    800a0a <vprintfmt+0x1f3>
  800a49:	89 75 08             	mov    %esi,0x8(%ebp)
  800a4c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a4f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a52:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a55:	eb b6                	jmp    800a0d <vprintfmt+0x1f6>
				putch(' ', putdat);
  800a57:	83 ec 08             	sub    $0x8,%esp
  800a5a:	53                   	push   %ebx
  800a5b:	6a 20                	push   $0x20
  800a5d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800a5f:	83 ef 01             	sub    $0x1,%edi
  800a62:	83 c4 10             	add    $0x10,%esp
  800a65:	85 ff                	test   %edi,%edi
  800a67:	7f ee                	jg     800a57 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800a69:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800a6c:	89 45 14             	mov    %eax,0x14(%ebp)
  800a6f:	e9 78 01 00 00       	jmp    800bec <vprintfmt+0x3d5>
  800a74:	89 df                	mov    %ebx,%edi
  800a76:	8b 75 08             	mov    0x8(%ebp),%esi
  800a79:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a7c:	eb e7                	jmp    800a65 <vprintfmt+0x24e>
	if (lflag >= 2)
  800a7e:	83 f9 01             	cmp    $0x1,%ecx
  800a81:	7e 3f                	jle    800ac2 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800a83:	8b 45 14             	mov    0x14(%ebp),%eax
  800a86:	8b 50 04             	mov    0x4(%eax),%edx
  800a89:	8b 00                	mov    (%eax),%eax
  800a8b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a8e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800a91:	8b 45 14             	mov    0x14(%ebp),%eax
  800a94:	8d 40 08             	lea    0x8(%eax),%eax
  800a97:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800a9a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800a9e:	79 5c                	jns    800afc <vprintfmt+0x2e5>
				putch('-', putdat);
  800aa0:	83 ec 08             	sub    $0x8,%esp
  800aa3:	53                   	push   %ebx
  800aa4:	6a 2d                	push   $0x2d
  800aa6:	ff d6                	call   *%esi
				num = -(long long) num;
  800aa8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800aab:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800aae:	f7 da                	neg    %edx
  800ab0:	83 d1 00             	adc    $0x0,%ecx
  800ab3:	f7 d9                	neg    %ecx
  800ab5:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800ab8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800abd:	e9 10 01 00 00       	jmp    800bd2 <vprintfmt+0x3bb>
	else if (lflag)
  800ac2:	85 c9                	test   %ecx,%ecx
  800ac4:	75 1b                	jne    800ae1 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800ac6:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac9:	8b 00                	mov    (%eax),%eax
  800acb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ace:	89 c1                	mov    %eax,%ecx
  800ad0:	c1 f9 1f             	sar    $0x1f,%ecx
  800ad3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800ad6:	8b 45 14             	mov    0x14(%ebp),%eax
  800ad9:	8d 40 04             	lea    0x4(%eax),%eax
  800adc:	89 45 14             	mov    %eax,0x14(%ebp)
  800adf:	eb b9                	jmp    800a9a <vprintfmt+0x283>
		return va_arg(*ap, long);
  800ae1:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae4:	8b 00                	mov    (%eax),%eax
  800ae6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ae9:	89 c1                	mov    %eax,%ecx
  800aeb:	c1 f9 1f             	sar    $0x1f,%ecx
  800aee:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800af1:	8b 45 14             	mov    0x14(%ebp),%eax
  800af4:	8d 40 04             	lea    0x4(%eax),%eax
  800af7:	89 45 14             	mov    %eax,0x14(%ebp)
  800afa:	eb 9e                	jmp    800a9a <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800afc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800aff:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800b02:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b07:	e9 c6 00 00 00       	jmp    800bd2 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800b0c:	83 f9 01             	cmp    $0x1,%ecx
  800b0f:	7e 18                	jle    800b29 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  800b11:	8b 45 14             	mov    0x14(%ebp),%eax
  800b14:	8b 10                	mov    (%eax),%edx
  800b16:	8b 48 04             	mov    0x4(%eax),%ecx
  800b19:	8d 40 08             	lea    0x8(%eax),%eax
  800b1c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b1f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b24:	e9 a9 00 00 00       	jmp    800bd2 <vprintfmt+0x3bb>
	else if (lflag)
  800b29:	85 c9                	test   %ecx,%ecx
  800b2b:	75 1a                	jne    800b47 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800b2d:	8b 45 14             	mov    0x14(%ebp),%eax
  800b30:	8b 10                	mov    (%eax),%edx
  800b32:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b37:	8d 40 04             	lea    0x4(%eax),%eax
  800b3a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b3d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b42:	e9 8b 00 00 00       	jmp    800bd2 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800b47:	8b 45 14             	mov    0x14(%ebp),%eax
  800b4a:	8b 10                	mov    (%eax),%edx
  800b4c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b51:	8d 40 04             	lea    0x4(%eax),%eax
  800b54:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b57:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b5c:	eb 74                	jmp    800bd2 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800b5e:	83 f9 01             	cmp    $0x1,%ecx
  800b61:	7e 15                	jle    800b78 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800b63:	8b 45 14             	mov    0x14(%ebp),%eax
  800b66:	8b 10                	mov    (%eax),%edx
  800b68:	8b 48 04             	mov    0x4(%eax),%ecx
  800b6b:	8d 40 08             	lea    0x8(%eax),%eax
  800b6e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800b71:	b8 08 00 00 00       	mov    $0x8,%eax
  800b76:	eb 5a                	jmp    800bd2 <vprintfmt+0x3bb>
	else if (lflag)
  800b78:	85 c9                	test   %ecx,%ecx
  800b7a:	75 17                	jne    800b93 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800b7c:	8b 45 14             	mov    0x14(%ebp),%eax
  800b7f:	8b 10                	mov    (%eax),%edx
  800b81:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b86:	8d 40 04             	lea    0x4(%eax),%eax
  800b89:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800b8c:	b8 08 00 00 00       	mov    $0x8,%eax
  800b91:	eb 3f                	jmp    800bd2 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800b93:	8b 45 14             	mov    0x14(%ebp),%eax
  800b96:	8b 10                	mov    (%eax),%edx
  800b98:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b9d:	8d 40 04             	lea    0x4(%eax),%eax
  800ba0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800ba3:	b8 08 00 00 00       	mov    $0x8,%eax
  800ba8:	eb 28                	jmp    800bd2 <vprintfmt+0x3bb>
			putch('0', putdat);
  800baa:	83 ec 08             	sub    $0x8,%esp
  800bad:	53                   	push   %ebx
  800bae:	6a 30                	push   $0x30
  800bb0:	ff d6                	call   *%esi
			putch('x', putdat);
  800bb2:	83 c4 08             	add    $0x8,%esp
  800bb5:	53                   	push   %ebx
  800bb6:	6a 78                	push   $0x78
  800bb8:	ff d6                	call   *%esi
			num = (unsigned long long)
  800bba:	8b 45 14             	mov    0x14(%ebp),%eax
  800bbd:	8b 10                	mov    (%eax),%edx
  800bbf:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800bc4:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800bc7:	8d 40 04             	lea    0x4(%eax),%eax
  800bca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800bcd:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800bd2:	83 ec 0c             	sub    $0xc,%esp
  800bd5:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800bd9:	57                   	push   %edi
  800bda:	ff 75 e0             	pushl  -0x20(%ebp)
  800bdd:	50                   	push   %eax
  800bde:	51                   	push   %ecx
  800bdf:	52                   	push   %edx
  800be0:	89 da                	mov    %ebx,%edx
  800be2:	89 f0                	mov    %esi,%eax
  800be4:	e8 45 fb ff ff       	call   80072e <printnum>
			break;
  800be9:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800bec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800bef:	83 c7 01             	add    $0x1,%edi
  800bf2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800bf6:	83 f8 25             	cmp    $0x25,%eax
  800bf9:	0f 84 2f fc ff ff    	je     80082e <vprintfmt+0x17>
			if (ch == '\0')
  800bff:	85 c0                	test   %eax,%eax
  800c01:	0f 84 8b 00 00 00    	je     800c92 <vprintfmt+0x47b>
			putch(ch, putdat);
  800c07:	83 ec 08             	sub    $0x8,%esp
  800c0a:	53                   	push   %ebx
  800c0b:	50                   	push   %eax
  800c0c:	ff d6                	call   *%esi
  800c0e:	83 c4 10             	add    $0x10,%esp
  800c11:	eb dc                	jmp    800bef <vprintfmt+0x3d8>
	if (lflag >= 2)
  800c13:	83 f9 01             	cmp    $0x1,%ecx
  800c16:	7e 15                	jle    800c2d <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800c18:	8b 45 14             	mov    0x14(%ebp),%eax
  800c1b:	8b 10                	mov    (%eax),%edx
  800c1d:	8b 48 04             	mov    0x4(%eax),%ecx
  800c20:	8d 40 08             	lea    0x8(%eax),%eax
  800c23:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c26:	b8 10 00 00 00       	mov    $0x10,%eax
  800c2b:	eb a5                	jmp    800bd2 <vprintfmt+0x3bb>
	else if (lflag)
  800c2d:	85 c9                	test   %ecx,%ecx
  800c2f:	75 17                	jne    800c48 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  800c31:	8b 45 14             	mov    0x14(%ebp),%eax
  800c34:	8b 10                	mov    (%eax),%edx
  800c36:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c3b:	8d 40 04             	lea    0x4(%eax),%eax
  800c3e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c41:	b8 10 00 00 00       	mov    $0x10,%eax
  800c46:	eb 8a                	jmp    800bd2 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800c48:	8b 45 14             	mov    0x14(%ebp),%eax
  800c4b:	8b 10                	mov    (%eax),%edx
  800c4d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c52:	8d 40 04             	lea    0x4(%eax),%eax
  800c55:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c58:	b8 10 00 00 00       	mov    $0x10,%eax
  800c5d:	e9 70 ff ff ff       	jmp    800bd2 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800c62:	83 ec 08             	sub    $0x8,%esp
  800c65:	53                   	push   %ebx
  800c66:	6a 25                	push   $0x25
  800c68:	ff d6                	call   *%esi
			break;
  800c6a:	83 c4 10             	add    $0x10,%esp
  800c6d:	e9 7a ff ff ff       	jmp    800bec <vprintfmt+0x3d5>
			putch('%', putdat);
  800c72:	83 ec 08             	sub    $0x8,%esp
  800c75:	53                   	push   %ebx
  800c76:	6a 25                	push   $0x25
  800c78:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c7a:	83 c4 10             	add    $0x10,%esp
  800c7d:	89 f8                	mov    %edi,%eax
  800c7f:	eb 03                	jmp    800c84 <vprintfmt+0x46d>
  800c81:	83 e8 01             	sub    $0x1,%eax
  800c84:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800c88:	75 f7                	jne    800c81 <vprintfmt+0x46a>
  800c8a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c8d:	e9 5a ff ff ff       	jmp    800bec <vprintfmt+0x3d5>
}
  800c92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c95:	5b                   	pop    %ebx
  800c96:	5e                   	pop    %esi
  800c97:	5f                   	pop    %edi
  800c98:	5d                   	pop    %ebp
  800c99:	c3                   	ret    

00800c9a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	83 ec 18             	sub    $0x18,%esp
  800ca0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ca6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ca9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800cad:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800cb0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800cb7:	85 c0                	test   %eax,%eax
  800cb9:	74 26                	je     800ce1 <vsnprintf+0x47>
  800cbb:	85 d2                	test   %edx,%edx
  800cbd:	7e 22                	jle    800ce1 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800cbf:	ff 75 14             	pushl  0x14(%ebp)
  800cc2:	ff 75 10             	pushl  0x10(%ebp)
  800cc5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800cc8:	50                   	push   %eax
  800cc9:	68 dd 07 80 00       	push   $0x8007dd
  800cce:	e8 44 fb ff ff       	call   800817 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800cd3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cd6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800cd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cdc:	83 c4 10             	add    $0x10,%esp
}
  800cdf:	c9                   	leave  
  800ce0:	c3                   	ret    
		return -E_INVAL;
  800ce1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ce6:	eb f7                	jmp    800cdf <vsnprintf+0x45>

00800ce8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800cee:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800cf1:	50                   	push   %eax
  800cf2:	ff 75 10             	pushl  0x10(%ebp)
  800cf5:	ff 75 0c             	pushl  0xc(%ebp)
  800cf8:	ff 75 08             	pushl  0x8(%ebp)
  800cfb:	e8 9a ff ff ff       	call   800c9a <vsnprintf>
	va_end(ap);

	return rc;
}
  800d00:	c9                   	leave  
  800d01:	c3                   	ret    

00800d02 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d02:	55                   	push   %ebp
  800d03:	89 e5                	mov    %esp,%ebp
  800d05:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d08:	b8 00 00 00 00       	mov    $0x0,%eax
  800d0d:	eb 03                	jmp    800d12 <strlen+0x10>
		n++;
  800d0f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800d12:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d16:	75 f7                	jne    800d0f <strlen+0xd>
	return n;
}
  800d18:	5d                   	pop    %ebp
  800d19:	c3                   	ret    

00800d1a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d20:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d23:	b8 00 00 00 00       	mov    $0x0,%eax
  800d28:	eb 03                	jmp    800d2d <strnlen+0x13>
		n++;
  800d2a:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d2d:	39 d0                	cmp    %edx,%eax
  800d2f:	74 06                	je     800d37 <strnlen+0x1d>
  800d31:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800d35:	75 f3                	jne    800d2a <strnlen+0x10>
	return n;
}
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    

00800d39 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
  800d3c:	53                   	push   %ebx
  800d3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d43:	89 c2                	mov    %eax,%edx
  800d45:	83 c1 01             	add    $0x1,%ecx
  800d48:	83 c2 01             	add    $0x1,%edx
  800d4b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d4f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d52:	84 db                	test   %bl,%bl
  800d54:	75 ef                	jne    800d45 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d56:	5b                   	pop    %ebx
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    

00800d59 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	53                   	push   %ebx
  800d5d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d60:	53                   	push   %ebx
  800d61:	e8 9c ff ff ff       	call   800d02 <strlen>
  800d66:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800d69:	ff 75 0c             	pushl  0xc(%ebp)
  800d6c:	01 d8                	add    %ebx,%eax
  800d6e:	50                   	push   %eax
  800d6f:	e8 c5 ff ff ff       	call   800d39 <strcpy>
	return dst;
}
  800d74:	89 d8                	mov    %ebx,%eax
  800d76:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d79:	c9                   	leave  
  800d7a:	c3                   	ret    

00800d7b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	56                   	push   %esi
  800d7f:	53                   	push   %ebx
  800d80:	8b 75 08             	mov    0x8(%ebp),%esi
  800d83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d86:	89 f3                	mov    %esi,%ebx
  800d88:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d8b:	89 f2                	mov    %esi,%edx
  800d8d:	eb 0f                	jmp    800d9e <strncpy+0x23>
		*dst++ = *src;
  800d8f:	83 c2 01             	add    $0x1,%edx
  800d92:	0f b6 01             	movzbl (%ecx),%eax
  800d95:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d98:	80 39 01             	cmpb   $0x1,(%ecx)
  800d9b:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800d9e:	39 da                	cmp    %ebx,%edx
  800da0:	75 ed                	jne    800d8f <strncpy+0x14>
	}
	return ret;
}
  800da2:	89 f0                	mov    %esi,%eax
  800da4:	5b                   	pop    %ebx
  800da5:	5e                   	pop    %esi
  800da6:	5d                   	pop    %ebp
  800da7:	c3                   	ret    

00800da8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	56                   	push   %esi
  800dac:	53                   	push   %ebx
  800dad:	8b 75 08             	mov    0x8(%ebp),%esi
  800db0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800db3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800db6:	89 f0                	mov    %esi,%eax
  800db8:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800dbc:	85 c9                	test   %ecx,%ecx
  800dbe:	75 0b                	jne    800dcb <strlcpy+0x23>
  800dc0:	eb 17                	jmp    800dd9 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800dc2:	83 c2 01             	add    $0x1,%edx
  800dc5:	83 c0 01             	add    $0x1,%eax
  800dc8:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800dcb:	39 d8                	cmp    %ebx,%eax
  800dcd:	74 07                	je     800dd6 <strlcpy+0x2e>
  800dcf:	0f b6 0a             	movzbl (%edx),%ecx
  800dd2:	84 c9                	test   %cl,%cl
  800dd4:	75 ec                	jne    800dc2 <strlcpy+0x1a>
		*dst = '\0';
  800dd6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800dd9:	29 f0                	sub    %esi,%eax
}
  800ddb:	5b                   	pop    %ebx
  800ddc:	5e                   	pop    %esi
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    

00800ddf <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800de8:	eb 06                	jmp    800df0 <strcmp+0x11>
		p++, q++;
  800dea:	83 c1 01             	add    $0x1,%ecx
  800ded:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800df0:	0f b6 01             	movzbl (%ecx),%eax
  800df3:	84 c0                	test   %al,%al
  800df5:	74 04                	je     800dfb <strcmp+0x1c>
  800df7:	3a 02                	cmp    (%edx),%al
  800df9:	74 ef                	je     800dea <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800dfb:	0f b6 c0             	movzbl %al,%eax
  800dfe:	0f b6 12             	movzbl (%edx),%edx
  800e01:	29 d0                	sub    %edx,%eax
}
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	53                   	push   %ebx
  800e09:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e0f:	89 c3                	mov    %eax,%ebx
  800e11:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800e14:	eb 06                	jmp    800e1c <strncmp+0x17>
		n--, p++, q++;
  800e16:	83 c0 01             	add    $0x1,%eax
  800e19:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800e1c:	39 d8                	cmp    %ebx,%eax
  800e1e:	74 16                	je     800e36 <strncmp+0x31>
  800e20:	0f b6 08             	movzbl (%eax),%ecx
  800e23:	84 c9                	test   %cl,%cl
  800e25:	74 04                	je     800e2b <strncmp+0x26>
  800e27:	3a 0a                	cmp    (%edx),%cl
  800e29:	74 eb                	je     800e16 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e2b:	0f b6 00             	movzbl (%eax),%eax
  800e2e:	0f b6 12             	movzbl (%edx),%edx
  800e31:	29 d0                	sub    %edx,%eax
}
  800e33:	5b                   	pop    %ebx
  800e34:	5d                   	pop    %ebp
  800e35:	c3                   	ret    
		return 0;
  800e36:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3b:	eb f6                	jmp    800e33 <strncmp+0x2e>

00800e3d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e3d:	55                   	push   %ebp
  800e3e:	89 e5                	mov    %esp,%ebp
  800e40:	8b 45 08             	mov    0x8(%ebp),%eax
  800e43:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e47:	0f b6 10             	movzbl (%eax),%edx
  800e4a:	84 d2                	test   %dl,%dl
  800e4c:	74 09                	je     800e57 <strchr+0x1a>
		if (*s == c)
  800e4e:	38 ca                	cmp    %cl,%dl
  800e50:	74 0a                	je     800e5c <strchr+0x1f>
	for (; *s; s++)
  800e52:	83 c0 01             	add    $0x1,%eax
  800e55:	eb f0                	jmp    800e47 <strchr+0xa>
			return (char *) s;
	return 0;
  800e57:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e5c:	5d                   	pop    %ebp
  800e5d:	c3                   	ret    

00800e5e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e5e:	55                   	push   %ebp
  800e5f:	89 e5                	mov    %esp,%ebp
  800e61:	8b 45 08             	mov    0x8(%ebp),%eax
  800e64:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e68:	eb 03                	jmp    800e6d <strfind+0xf>
  800e6a:	83 c0 01             	add    $0x1,%eax
  800e6d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800e70:	38 ca                	cmp    %cl,%dl
  800e72:	74 04                	je     800e78 <strfind+0x1a>
  800e74:	84 d2                	test   %dl,%dl
  800e76:	75 f2                	jne    800e6a <strfind+0xc>
			break;
	return (char *) s;
}
  800e78:	5d                   	pop    %ebp
  800e79:	c3                   	ret    

00800e7a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e7a:	55                   	push   %ebp
  800e7b:	89 e5                	mov    %esp,%ebp
  800e7d:	57                   	push   %edi
  800e7e:	56                   	push   %esi
  800e7f:	53                   	push   %ebx
  800e80:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e83:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e86:	85 c9                	test   %ecx,%ecx
  800e88:	74 13                	je     800e9d <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e8a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e90:	75 05                	jne    800e97 <memset+0x1d>
  800e92:	f6 c1 03             	test   $0x3,%cl
  800e95:	74 0d                	je     800ea4 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e97:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e9a:	fc                   	cld    
  800e9b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e9d:	89 f8                	mov    %edi,%eax
  800e9f:	5b                   	pop    %ebx
  800ea0:	5e                   	pop    %esi
  800ea1:	5f                   	pop    %edi
  800ea2:	5d                   	pop    %ebp
  800ea3:	c3                   	ret    
		c &= 0xFF;
  800ea4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ea8:	89 d3                	mov    %edx,%ebx
  800eaa:	c1 e3 08             	shl    $0x8,%ebx
  800ead:	89 d0                	mov    %edx,%eax
  800eaf:	c1 e0 18             	shl    $0x18,%eax
  800eb2:	89 d6                	mov    %edx,%esi
  800eb4:	c1 e6 10             	shl    $0x10,%esi
  800eb7:	09 f0                	or     %esi,%eax
  800eb9:	09 c2                	or     %eax,%edx
  800ebb:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800ebd:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ec0:	89 d0                	mov    %edx,%eax
  800ec2:	fc                   	cld    
  800ec3:	f3 ab                	rep stos %eax,%es:(%edi)
  800ec5:	eb d6                	jmp    800e9d <memset+0x23>

00800ec7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	57                   	push   %edi
  800ecb:	56                   	push   %esi
  800ecc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ed2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ed5:	39 c6                	cmp    %eax,%esi
  800ed7:	73 35                	jae    800f0e <memmove+0x47>
  800ed9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800edc:	39 c2                	cmp    %eax,%edx
  800ede:	76 2e                	jbe    800f0e <memmove+0x47>
		s += n;
		d += n;
  800ee0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ee3:	89 d6                	mov    %edx,%esi
  800ee5:	09 fe                	or     %edi,%esi
  800ee7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800eed:	74 0c                	je     800efb <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800eef:	83 ef 01             	sub    $0x1,%edi
  800ef2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ef5:	fd                   	std    
  800ef6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ef8:	fc                   	cld    
  800ef9:	eb 21                	jmp    800f1c <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800efb:	f6 c1 03             	test   $0x3,%cl
  800efe:	75 ef                	jne    800eef <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f00:	83 ef 04             	sub    $0x4,%edi
  800f03:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f06:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800f09:	fd                   	std    
  800f0a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f0c:	eb ea                	jmp    800ef8 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f0e:	89 f2                	mov    %esi,%edx
  800f10:	09 c2                	or     %eax,%edx
  800f12:	f6 c2 03             	test   $0x3,%dl
  800f15:	74 09                	je     800f20 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f17:	89 c7                	mov    %eax,%edi
  800f19:	fc                   	cld    
  800f1a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f1c:	5e                   	pop    %esi
  800f1d:	5f                   	pop    %edi
  800f1e:	5d                   	pop    %ebp
  800f1f:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f20:	f6 c1 03             	test   $0x3,%cl
  800f23:	75 f2                	jne    800f17 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f25:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800f28:	89 c7                	mov    %eax,%edi
  800f2a:	fc                   	cld    
  800f2b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f2d:	eb ed                	jmp    800f1c <memmove+0x55>

00800f2f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f2f:	55                   	push   %ebp
  800f30:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800f32:	ff 75 10             	pushl  0x10(%ebp)
  800f35:	ff 75 0c             	pushl  0xc(%ebp)
  800f38:	ff 75 08             	pushl  0x8(%ebp)
  800f3b:	e8 87 ff ff ff       	call   800ec7 <memmove>
}
  800f40:	c9                   	leave  
  800f41:	c3                   	ret    

00800f42 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f42:	55                   	push   %ebp
  800f43:	89 e5                	mov    %esp,%ebp
  800f45:	56                   	push   %esi
  800f46:	53                   	push   %ebx
  800f47:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f4d:	89 c6                	mov    %eax,%esi
  800f4f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f52:	39 f0                	cmp    %esi,%eax
  800f54:	74 1c                	je     800f72 <memcmp+0x30>
		if (*s1 != *s2)
  800f56:	0f b6 08             	movzbl (%eax),%ecx
  800f59:	0f b6 1a             	movzbl (%edx),%ebx
  800f5c:	38 d9                	cmp    %bl,%cl
  800f5e:	75 08                	jne    800f68 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800f60:	83 c0 01             	add    $0x1,%eax
  800f63:	83 c2 01             	add    $0x1,%edx
  800f66:	eb ea                	jmp    800f52 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800f68:	0f b6 c1             	movzbl %cl,%eax
  800f6b:	0f b6 db             	movzbl %bl,%ebx
  800f6e:	29 d8                	sub    %ebx,%eax
  800f70:	eb 05                	jmp    800f77 <memcmp+0x35>
	}

	return 0;
  800f72:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f77:	5b                   	pop    %ebx
  800f78:	5e                   	pop    %esi
  800f79:	5d                   	pop    %ebp
  800f7a:	c3                   	ret    

00800f7b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f7b:	55                   	push   %ebp
  800f7c:	89 e5                	mov    %esp,%ebp
  800f7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800f84:	89 c2                	mov    %eax,%edx
  800f86:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800f89:	39 d0                	cmp    %edx,%eax
  800f8b:	73 09                	jae    800f96 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f8d:	38 08                	cmp    %cl,(%eax)
  800f8f:	74 05                	je     800f96 <memfind+0x1b>
	for (; s < ends; s++)
  800f91:	83 c0 01             	add    $0x1,%eax
  800f94:	eb f3                	jmp    800f89 <memfind+0xe>
			break;
	return (void *) s;
}
  800f96:	5d                   	pop    %ebp
  800f97:	c3                   	ret    

00800f98 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f98:	55                   	push   %ebp
  800f99:	89 e5                	mov    %esp,%ebp
  800f9b:	57                   	push   %edi
  800f9c:	56                   	push   %esi
  800f9d:	53                   	push   %ebx
  800f9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fa1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fa4:	eb 03                	jmp    800fa9 <strtol+0x11>
		s++;
  800fa6:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800fa9:	0f b6 01             	movzbl (%ecx),%eax
  800fac:	3c 20                	cmp    $0x20,%al
  800fae:	74 f6                	je     800fa6 <strtol+0xe>
  800fb0:	3c 09                	cmp    $0x9,%al
  800fb2:	74 f2                	je     800fa6 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800fb4:	3c 2b                	cmp    $0x2b,%al
  800fb6:	74 2e                	je     800fe6 <strtol+0x4e>
	int neg = 0;
  800fb8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800fbd:	3c 2d                	cmp    $0x2d,%al
  800fbf:	74 2f                	je     800ff0 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800fc1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800fc7:	75 05                	jne    800fce <strtol+0x36>
  800fc9:	80 39 30             	cmpb   $0x30,(%ecx)
  800fcc:	74 2c                	je     800ffa <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800fce:	85 db                	test   %ebx,%ebx
  800fd0:	75 0a                	jne    800fdc <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800fd2:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800fd7:	80 39 30             	cmpb   $0x30,(%ecx)
  800fda:	74 28                	je     801004 <strtol+0x6c>
		base = 10;
  800fdc:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe1:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800fe4:	eb 50                	jmp    801036 <strtol+0x9e>
		s++;
  800fe6:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800fe9:	bf 00 00 00 00       	mov    $0x0,%edi
  800fee:	eb d1                	jmp    800fc1 <strtol+0x29>
		s++, neg = 1;
  800ff0:	83 c1 01             	add    $0x1,%ecx
  800ff3:	bf 01 00 00 00       	mov    $0x1,%edi
  800ff8:	eb c7                	jmp    800fc1 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ffa:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ffe:	74 0e                	je     80100e <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801000:	85 db                	test   %ebx,%ebx
  801002:	75 d8                	jne    800fdc <strtol+0x44>
		s++, base = 8;
  801004:	83 c1 01             	add    $0x1,%ecx
  801007:	bb 08 00 00 00       	mov    $0x8,%ebx
  80100c:	eb ce                	jmp    800fdc <strtol+0x44>
		s += 2, base = 16;
  80100e:	83 c1 02             	add    $0x2,%ecx
  801011:	bb 10 00 00 00       	mov    $0x10,%ebx
  801016:	eb c4                	jmp    800fdc <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  801018:	8d 72 9f             	lea    -0x61(%edx),%esi
  80101b:	89 f3                	mov    %esi,%ebx
  80101d:	80 fb 19             	cmp    $0x19,%bl
  801020:	77 29                	ja     80104b <strtol+0xb3>
			dig = *s - 'a' + 10;
  801022:	0f be d2             	movsbl %dl,%edx
  801025:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801028:	3b 55 10             	cmp    0x10(%ebp),%edx
  80102b:	7d 30                	jge    80105d <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  80102d:	83 c1 01             	add    $0x1,%ecx
  801030:	0f af 45 10          	imul   0x10(%ebp),%eax
  801034:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801036:	0f b6 11             	movzbl (%ecx),%edx
  801039:	8d 72 d0             	lea    -0x30(%edx),%esi
  80103c:	89 f3                	mov    %esi,%ebx
  80103e:	80 fb 09             	cmp    $0x9,%bl
  801041:	77 d5                	ja     801018 <strtol+0x80>
			dig = *s - '0';
  801043:	0f be d2             	movsbl %dl,%edx
  801046:	83 ea 30             	sub    $0x30,%edx
  801049:	eb dd                	jmp    801028 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  80104b:	8d 72 bf             	lea    -0x41(%edx),%esi
  80104e:	89 f3                	mov    %esi,%ebx
  801050:	80 fb 19             	cmp    $0x19,%bl
  801053:	77 08                	ja     80105d <strtol+0xc5>
			dig = *s - 'A' + 10;
  801055:	0f be d2             	movsbl %dl,%edx
  801058:	83 ea 37             	sub    $0x37,%edx
  80105b:	eb cb                	jmp    801028 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  80105d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801061:	74 05                	je     801068 <strtol+0xd0>
		*endptr = (char *) s;
  801063:	8b 75 0c             	mov    0xc(%ebp),%esi
  801066:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801068:	89 c2                	mov    %eax,%edx
  80106a:	f7 da                	neg    %edx
  80106c:	85 ff                	test   %edi,%edi
  80106e:	0f 45 c2             	cmovne %edx,%eax
}
  801071:	5b                   	pop    %ebx
  801072:	5e                   	pop    %esi
  801073:	5f                   	pop    %edi
  801074:	5d                   	pop    %ebp
  801075:	c3                   	ret    

00801076 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
  801079:	57                   	push   %edi
  80107a:	56                   	push   %esi
  80107b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80107c:	b8 00 00 00 00       	mov    $0x0,%eax
  801081:	8b 55 08             	mov    0x8(%ebp),%edx
  801084:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801087:	89 c3                	mov    %eax,%ebx
  801089:	89 c7                	mov    %eax,%edi
  80108b:	89 c6                	mov    %eax,%esi
  80108d:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80108f:	5b                   	pop    %ebx
  801090:	5e                   	pop    %esi
  801091:	5f                   	pop    %edi
  801092:	5d                   	pop    %ebp
  801093:	c3                   	ret    

00801094 <sys_cgetc>:

int
sys_cgetc(void)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
  801097:	57                   	push   %edi
  801098:	56                   	push   %esi
  801099:	53                   	push   %ebx
	asm volatile("int %1\n"
  80109a:	ba 00 00 00 00       	mov    $0x0,%edx
  80109f:	b8 01 00 00 00       	mov    $0x1,%eax
  8010a4:	89 d1                	mov    %edx,%ecx
  8010a6:	89 d3                	mov    %edx,%ebx
  8010a8:	89 d7                	mov    %edx,%edi
  8010aa:	89 d6                	mov    %edx,%esi
  8010ac:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8010ae:	5b                   	pop    %ebx
  8010af:	5e                   	pop    %esi
  8010b0:	5f                   	pop    %edi
  8010b1:	5d                   	pop    %ebp
  8010b2:	c3                   	ret    

008010b3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8010b3:	55                   	push   %ebp
  8010b4:	89 e5                	mov    %esp,%ebp
  8010b6:	57                   	push   %edi
  8010b7:	56                   	push   %esi
  8010b8:	53                   	push   %ebx
  8010b9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8010bc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c4:	b8 03 00 00 00       	mov    $0x3,%eax
  8010c9:	89 cb                	mov    %ecx,%ebx
  8010cb:	89 cf                	mov    %ecx,%edi
  8010cd:	89 ce                	mov    %ecx,%esi
  8010cf:	cd 30                	int    $0x30
	if(check && ret > 0)
  8010d1:	85 c0                	test   %eax,%eax
  8010d3:	7f 08                	jg     8010dd <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d8:	5b                   	pop    %ebx
  8010d9:	5e                   	pop    %esi
  8010da:	5f                   	pop    %edi
  8010db:	5d                   	pop    %ebp
  8010dc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8010dd:	83 ec 0c             	sub    $0xc,%esp
  8010e0:	50                   	push   %eax
  8010e1:	6a 03                	push   $0x3
  8010e3:	68 3f 28 80 00       	push   $0x80283f
  8010e8:	6a 23                	push   $0x23
  8010ea:	68 5c 28 80 00       	push   $0x80285c
  8010ef:	e8 4b f5 ff ff       	call   80063f <_panic>

008010f4 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8010f4:	55                   	push   %ebp
  8010f5:	89 e5                	mov    %esp,%ebp
  8010f7:	57                   	push   %edi
  8010f8:	56                   	push   %esi
  8010f9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8010ff:	b8 02 00 00 00       	mov    $0x2,%eax
  801104:	89 d1                	mov    %edx,%ecx
  801106:	89 d3                	mov    %edx,%ebx
  801108:	89 d7                	mov    %edx,%edi
  80110a:	89 d6                	mov    %edx,%esi
  80110c:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80110e:	5b                   	pop    %ebx
  80110f:	5e                   	pop    %esi
  801110:	5f                   	pop    %edi
  801111:	5d                   	pop    %ebp
  801112:	c3                   	ret    

00801113 <sys_yield>:

void
sys_yield(void)
{
  801113:	55                   	push   %ebp
  801114:	89 e5                	mov    %esp,%ebp
  801116:	57                   	push   %edi
  801117:	56                   	push   %esi
  801118:	53                   	push   %ebx
	asm volatile("int %1\n"
  801119:	ba 00 00 00 00       	mov    $0x0,%edx
  80111e:	b8 0b 00 00 00       	mov    $0xb,%eax
  801123:	89 d1                	mov    %edx,%ecx
  801125:	89 d3                	mov    %edx,%ebx
  801127:	89 d7                	mov    %edx,%edi
  801129:	89 d6                	mov    %edx,%esi
  80112b:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80112d:	5b                   	pop    %ebx
  80112e:	5e                   	pop    %esi
  80112f:	5f                   	pop    %edi
  801130:	5d                   	pop    %ebp
  801131:	c3                   	ret    

00801132 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801132:	55                   	push   %ebp
  801133:	89 e5                	mov    %esp,%ebp
  801135:	57                   	push   %edi
  801136:	56                   	push   %esi
  801137:	53                   	push   %ebx
  801138:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80113b:	be 00 00 00 00       	mov    $0x0,%esi
  801140:	8b 55 08             	mov    0x8(%ebp),%edx
  801143:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801146:	b8 04 00 00 00       	mov    $0x4,%eax
  80114b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80114e:	89 f7                	mov    %esi,%edi
  801150:	cd 30                	int    $0x30
	if(check && ret > 0)
  801152:	85 c0                	test   %eax,%eax
  801154:	7f 08                	jg     80115e <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801156:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801159:	5b                   	pop    %ebx
  80115a:	5e                   	pop    %esi
  80115b:	5f                   	pop    %edi
  80115c:	5d                   	pop    %ebp
  80115d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80115e:	83 ec 0c             	sub    $0xc,%esp
  801161:	50                   	push   %eax
  801162:	6a 04                	push   $0x4
  801164:	68 3f 28 80 00       	push   $0x80283f
  801169:	6a 23                	push   $0x23
  80116b:	68 5c 28 80 00       	push   $0x80285c
  801170:	e8 ca f4 ff ff       	call   80063f <_panic>

00801175 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801175:	55                   	push   %ebp
  801176:	89 e5                	mov    %esp,%ebp
  801178:	57                   	push   %edi
  801179:	56                   	push   %esi
  80117a:	53                   	push   %ebx
  80117b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80117e:	8b 55 08             	mov    0x8(%ebp),%edx
  801181:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801184:	b8 05 00 00 00       	mov    $0x5,%eax
  801189:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80118c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80118f:	8b 75 18             	mov    0x18(%ebp),%esi
  801192:	cd 30                	int    $0x30
	if(check && ret > 0)
  801194:	85 c0                	test   %eax,%eax
  801196:	7f 08                	jg     8011a0 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801198:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119b:	5b                   	pop    %ebx
  80119c:	5e                   	pop    %esi
  80119d:	5f                   	pop    %edi
  80119e:	5d                   	pop    %ebp
  80119f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8011a0:	83 ec 0c             	sub    $0xc,%esp
  8011a3:	50                   	push   %eax
  8011a4:	6a 05                	push   $0x5
  8011a6:	68 3f 28 80 00       	push   $0x80283f
  8011ab:	6a 23                	push   $0x23
  8011ad:	68 5c 28 80 00       	push   $0x80285c
  8011b2:	e8 88 f4 ff ff       	call   80063f <_panic>

008011b7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8011b7:	55                   	push   %ebp
  8011b8:	89 e5                	mov    %esp,%ebp
  8011ba:	57                   	push   %edi
  8011bb:	56                   	push   %esi
  8011bc:	53                   	push   %ebx
  8011bd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8011c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8011c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011cb:	b8 06 00 00 00       	mov    $0x6,%eax
  8011d0:	89 df                	mov    %ebx,%edi
  8011d2:	89 de                	mov    %ebx,%esi
  8011d4:	cd 30                	int    $0x30
	if(check && ret > 0)
  8011d6:	85 c0                	test   %eax,%eax
  8011d8:	7f 08                	jg     8011e2 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8011da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011dd:	5b                   	pop    %ebx
  8011de:	5e                   	pop    %esi
  8011df:	5f                   	pop    %edi
  8011e0:	5d                   	pop    %ebp
  8011e1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8011e2:	83 ec 0c             	sub    $0xc,%esp
  8011e5:	50                   	push   %eax
  8011e6:	6a 06                	push   $0x6
  8011e8:	68 3f 28 80 00       	push   $0x80283f
  8011ed:	6a 23                	push   $0x23
  8011ef:	68 5c 28 80 00       	push   $0x80285c
  8011f4:	e8 46 f4 ff ff       	call   80063f <_panic>

008011f9 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011f9:	55                   	push   %ebp
  8011fa:	89 e5                	mov    %esp,%ebp
  8011fc:	57                   	push   %edi
  8011fd:	56                   	push   %esi
  8011fe:	53                   	push   %ebx
  8011ff:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801202:	bb 00 00 00 00       	mov    $0x0,%ebx
  801207:	8b 55 08             	mov    0x8(%ebp),%edx
  80120a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80120d:	b8 08 00 00 00       	mov    $0x8,%eax
  801212:	89 df                	mov    %ebx,%edi
  801214:	89 de                	mov    %ebx,%esi
  801216:	cd 30                	int    $0x30
	if(check && ret > 0)
  801218:	85 c0                	test   %eax,%eax
  80121a:	7f 08                	jg     801224 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80121c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80121f:	5b                   	pop    %ebx
  801220:	5e                   	pop    %esi
  801221:	5f                   	pop    %edi
  801222:	5d                   	pop    %ebp
  801223:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801224:	83 ec 0c             	sub    $0xc,%esp
  801227:	50                   	push   %eax
  801228:	6a 08                	push   $0x8
  80122a:	68 3f 28 80 00       	push   $0x80283f
  80122f:	6a 23                	push   $0x23
  801231:	68 5c 28 80 00       	push   $0x80285c
  801236:	e8 04 f4 ff ff       	call   80063f <_panic>

0080123b <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80123b:	55                   	push   %ebp
  80123c:	89 e5                	mov    %esp,%ebp
  80123e:	57                   	push   %edi
  80123f:	56                   	push   %esi
  801240:	53                   	push   %ebx
  801241:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801244:	bb 00 00 00 00       	mov    $0x0,%ebx
  801249:	8b 55 08             	mov    0x8(%ebp),%edx
  80124c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80124f:	b8 09 00 00 00       	mov    $0x9,%eax
  801254:	89 df                	mov    %ebx,%edi
  801256:	89 de                	mov    %ebx,%esi
  801258:	cd 30                	int    $0x30
	if(check && ret > 0)
  80125a:	85 c0                	test   %eax,%eax
  80125c:	7f 08                	jg     801266 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80125e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801261:	5b                   	pop    %ebx
  801262:	5e                   	pop    %esi
  801263:	5f                   	pop    %edi
  801264:	5d                   	pop    %ebp
  801265:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801266:	83 ec 0c             	sub    $0xc,%esp
  801269:	50                   	push   %eax
  80126a:	6a 09                	push   $0x9
  80126c:	68 3f 28 80 00       	push   $0x80283f
  801271:	6a 23                	push   $0x23
  801273:	68 5c 28 80 00       	push   $0x80285c
  801278:	e8 c2 f3 ff ff       	call   80063f <_panic>

0080127d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80127d:	55                   	push   %ebp
  80127e:	89 e5                	mov    %esp,%ebp
  801280:	57                   	push   %edi
  801281:	56                   	push   %esi
  801282:	53                   	push   %ebx
  801283:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801286:	bb 00 00 00 00       	mov    $0x0,%ebx
  80128b:	8b 55 08             	mov    0x8(%ebp),%edx
  80128e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801291:	b8 0a 00 00 00       	mov    $0xa,%eax
  801296:	89 df                	mov    %ebx,%edi
  801298:	89 de                	mov    %ebx,%esi
  80129a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80129c:	85 c0                	test   %eax,%eax
  80129e:	7f 08                	jg     8012a8 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8012a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012a3:	5b                   	pop    %ebx
  8012a4:	5e                   	pop    %esi
  8012a5:	5f                   	pop    %edi
  8012a6:	5d                   	pop    %ebp
  8012a7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8012a8:	83 ec 0c             	sub    $0xc,%esp
  8012ab:	50                   	push   %eax
  8012ac:	6a 0a                	push   $0xa
  8012ae:	68 3f 28 80 00       	push   $0x80283f
  8012b3:	6a 23                	push   $0x23
  8012b5:	68 5c 28 80 00       	push   $0x80285c
  8012ba:	e8 80 f3 ff ff       	call   80063f <_panic>

008012bf <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8012bf:	55                   	push   %ebp
  8012c0:	89 e5                	mov    %esp,%ebp
  8012c2:	57                   	push   %edi
  8012c3:	56                   	push   %esi
  8012c4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8012c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8012c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012cb:	b8 0c 00 00 00       	mov    $0xc,%eax
  8012d0:	be 00 00 00 00       	mov    $0x0,%esi
  8012d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012d8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8012db:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8012dd:	5b                   	pop    %ebx
  8012de:	5e                   	pop    %esi
  8012df:	5f                   	pop    %edi
  8012e0:	5d                   	pop    %ebp
  8012e1:	c3                   	ret    

008012e2 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8012e2:	55                   	push   %ebp
  8012e3:	89 e5                	mov    %esp,%ebp
  8012e5:	57                   	push   %edi
  8012e6:	56                   	push   %esi
  8012e7:	53                   	push   %ebx
  8012e8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8012eb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8012f3:	b8 0d 00 00 00       	mov    $0xd,%eax
  8012f8:	89 cb                	mov    %ecx,%ebx
  8012fa:	89 cf                	mov    %ecx,%edi
  8012fc:	89 ce                	mov    %ecx,%esi
  8012fe:	cd 30                	int    $0x30
	if(check && ret > 0)
  801300:	85 c0                	test   %eax,%eax
  801302:	7f 08                	jg     80130c <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801304:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801307:	5b                   	pop    %ebx
  801308:	5e                   	pop    %esi
  801309:	5f                   	pop    %edi
  80130a:	5d                   	pop    %ebp
  80130b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80130c:	83 ec 0c             	sub    $0xc,%esp
  80130f:	50                   	push   %eax
  801310:	6a 0d                	push   $0xd
  801312:	68 3f 28 80 00       	push   $0x80283f
  801317:	6a 23                	push   $0x23
  801319:	68 5c 28 80 00       	push   $0x80285c
  80131e:	e8 1c f3 ff ff       	call   80063f <_panic>

00801323 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801323:	55                   	push   %ebp
  801324:	89 e5                	mov    %esp,%ebp
  801326:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801329:	83 3d b4 40 80 00 00 	cmpl   $0x0,0x8040b4
  801330:	74 0a                	je     80133c <set_pgfault_handler+0x19>
			panic("set_pgfault_handler %e",r);
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
	}
       
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801332:	8b 45 08             	mov    0x8(%ebp),%eax
  801335:	a3 b4 40 80 00       	mov    %eax,0x8040b4
}
  80133a:	c9                   	leave  
  80133b:	c3                   	ret    
		if((r=sys_page_alloc(thisenv->env_id,(void *)UXSTACKTOP-PGSIZE,PTE_P|PTE_W|PTE_U))<0)
  80133c:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801341:	8b 40 48             	mov    0x48(%eax),%eax
  801344:	83 ec 04             	sub    $0x4,%esp
  801347:	6a 07                	push   $0x7
  801349:	68 00 f0 bf ee       	push   $0xeebff000
  80134e:	50                   	push   %eax
  80134f:	e8 de fd ff ff       	call   801132 <sys_page_alloc>
  801354:	83 c4 10             	add    $0x10,%esp
  801357:	85 c0                	test   %eax,%eax
  801359:	78 1b                	js     801376 <set_pgfault_handler+0x53>
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
  80135b:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801360:	8b 40 48             	mov    0x48(%eax),%eax
  801363:	83 ec 08             	sub    $0x8,%esp
  801366:	68 88 13 80 00       	push   $0x801388
  80136b:	50                   	push   %eax
  80136c:	e8 0c ff ff ff       	call   80127d <sys_env_set_pgfault_upcall>
  801371:	83 c4 10             	add    $0x10,%esp
  801374:	eb bc                	jmp    801332 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler %e",r);
  801376:	50                   	push   %eax
  801377:	68 6a 28 80 00       	push   $0x80286a
  80137c:	6a 22                	push   $0x22
  80137e:	68 81 28 80 00       	push   $0x802881
  801383:	e8 b7 f2 ff ff       	call   80063f <_panic>

00801388 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801388:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801389:	a1 b4 40 80 00       	mov    0x8040b4,%eax
	call *%eax
  80138e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801390:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 48(%esp), %ebp
  801393:	8b 6c 24 30          	mov    0x30(%esp),%ebp
        subl $4, %ebp
  801397:	83 ed 04             	sub    $0x4,%ebp
        movl %ebp, 48(%esp)
  80139a:	89 6c 24 30          	mov    %ebp,0x30(%esp)
        movl 40(%esp), %eax
  80139e:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl %eax, (%ebp)
  8013a2:	89 45 00             	mov    %eax,0x0(%ebp)
	// Restore the trap-time registers.  After you do this, you
 	// can no longer modify any general-purpose registers.
 	// LAB 4: Your code here.
        addl $8, %esp
  8013a5:	83 c4 08             	add    $0x8,%esp
        popal
  8013a8:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $4, %esp
  8013a9:	83 c4 04             	add    $0x4,%esp
        popfl
  8013ac:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  8013ad:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  8013ae:	c3                   	ret    

008013af <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013af:	55                   	push   %ebp
  8013b0:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b5:	05 00 00 00 30       	add    $0x30000000,%eax
  8013ba:	c1 e8 0c             	shr    $0xc,%eax
}
  8013bd:	5d                   	pop    %ebp
  8013be:	c3                   	ret    

008013bf <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013bf:	55                   	push   %ebp
  8013c0:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c5:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8013ca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013cf:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013d4:	5d                   	pop    %ebp
  8013d5:	c3                   	ret    

008013d6 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013d6:	55                   	push   %ebp
  8013d7:	89 e5                	mov    %esp,%ebp
  8013d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013dc:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013e1:	89 c2                	mov    %eax,%edx
  8013e3:	c1 ea 16             	shr    $0x16,%edx
  8013e6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013ed:	f6 c2 01             	test   $0x1,%dl
  8013f0:	74 2a                	je     80141c <fd_alloc+0x46>
  8013f2:	89 c2                	mov    %eax,%edx
  8013f4:	c1 ea 0c             	shr    $0xc,%edx
  8013f7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013fe:	f6 c2 01             	test   $0x1,%dl
  801401:	74 19                	je     80141c <fd_alloc+0x46>
  801403:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801408:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80140d:	75 d2                	jne    8013e1 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80140f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801415:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80141a:	eb 07                	jmp    801423 <fd_alloc+0x4d>
			*fd_store = fd;
  80141c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80141e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801423:	5d                   	pop    %ebp
  801424:	c3                   	ret    

00801425 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801425:	55                   	push   %ebp
  801426:	89 e5                	mov    %esp,%ebp
  801428:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80142b:	83 f8 1f             	cmp    $0x1f,%eax
  80142e:	77 36                	ja     801466 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801430:	c1 e0 0c             	shl    $0xc,%eax
  801433:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801438:	89 c2                	mov    %eax,%edx
  80143a:	c1 ea 16             	shr    $0x16,%edx
  80143d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801444:	f6 c2 01             	test   $0x1,%dl
  801447:	74 24                	je     80146d <fd_lookup+0x48>
  801449:	89 c2                	mov    %eax,%edx
  80144b:	c1 ea 0c             	shr    $0xc,%edx
  80144e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801455:	f6 c2 01             	test   $0x1,%dl
  801458:	74 1a                	je     801474 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80145a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80145d:	89 02                	mov    %eax,(%edx)
	return 0;
  80145f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801464:	5d                   	pop    %ebp
  801465:	c3                   	ret    
		return -E_INVAL;
  801466:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80146b:	eb f7                	jmp    801464 <fd_lookup+0x3f>
		return -E_INVAL;
  80146d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801472:	eb f0                	jmp    801464 <fd_lookup+0x3f>
  801474:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801479:	eb e9                	jmp    801464 <fd_lookup+0x3f>

0080147b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80147b:	55                   	push   %ebp
  80147c:	89 e5                	mov    %esp,%ebp
  80147e:	83 ec 08             	sub    $0x8,%esp
  801481:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801484:	ba 10 29 80 00       	mov    $0x802910,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801489:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  80148e:	39 08                	cmp    %ecx,(%eax)
  801490:	74 33                	je     8014c5 <dev_lookup+0x4a>
  801492:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801495:	8b 02                	mov    (%edx),%eax
  801497:	85 c0                	test   %eax,%eax
  801499:	75 f3                	jne    80148e <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80149b:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8014a0:	8b 40 48             	mov    0x48(%eax),%eax
  8014a3:	83 ec 04             	sub    $0x4,%esp
  8014a6:	51                   	push   %ecx
  8014a7:	50                   	push   %eax
  8014a8:	68 90 28 80 00       	push   $0x802890
  8014ad:	e8 68 f2 ff ff       	call   80071a <cprintf>
	*dev = 0;
  8014b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014b5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014bb:	83 c4 10             	add    $0x10,%esp
  8014be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014c3:	c9                   	leave  
  8014c4:	c3                   	ret    
			*dev = devtab[i];
  8014c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014c8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8014cf:	eb f2                	jmp    8014c3 <dev_lookup+0x48>

008014d1 <fd_close>:
{
  8014d1:	55                   	push   %ebp
  8014d2:	89 e5                	mov    %esp,%ebp
  8014d4:	57                   	push   %edi
  8014d5:	56                   	push   %esi
  8014d6:	53                   	push   %ebx
  8014d7:	83 ec 1c             	sub    $0x1c,%esp
  8014da:	8b 75 08             	mov    0x8(%ebp),%esi
  8014dd:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014e0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014e3:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014e4:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8014ea:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014ed:	50                   	push   %eax
  8014ee:	e8 32 ff ff ff       	call   801425 <fd_lookup>
  8014f3:	89 c3                	mov    %eax,%ebx
  8014f5:	83 c4 08             	add    $0x8,%esp
  8014f8:	85 c0                	test   %eax,%eax
  8014fa:	78 05                	js     801501 <fd_close+0x30>
	    || fd != fd2)
  8014fc:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8014ff:	74 16                	je     801517 <fd_close+0x46>
		return (must_exist ? r : 0);
  801501:	89 f8                	mov    %edi,%eax
  801503:	84 c0                	test   %al,%al
  801505:	b8 00 00 00 00       	mov    $0x0,%eax
  80150a:	0f 44 d8             	cmove  %eax,%ebx
}
  80150d:	89 d8                	mov    %ebx,%eax
  80150f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801512:	5b                   	pop    %ebx
  801513:	5e                   	pop    %esi
  801514:	5f                   	pop    %edi
  801515:	5d                   	pop    %ebp
  801516:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801517:	83 ec 08             	sub    $0x8,%esp
  80151a:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80151d:	50                   	push   %eax
  80151e:	ff 36                	pushl  (%esi)
  801520:	e8 56 ff ff ff       	call   80147b <dev_lookup>
  801525:	89 c3                	mov    %eax,%ebx
  801527:	83 c4 10             	add    $0x10,%esp
  80152a:	85 c0                	test   %eax,%eax
  80152c:	78 15                	js     801543 <fd_close+0x72>
		if (dev->dev_close)
  80152e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801531:	8b 40 10             	mov    0x10(%eax),%eax
  801534:	85 c0                	test   %eax,%eax
  801536:	74 1b                	je     801553 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  801538:	83 ec 0c             	sub    $0xc,%esp
  80153b:	56                   	push   %esi
  80153c:	ff d0                	call   *%eax
  80153e:	89 c3                	mov    %eax,%ebx
  801540:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801543:	83 ec 08             	sub    $0x8,%esp
  801546:	56                   	push   %esi
  801547:	6a 00                	push   $0x0
  801549:	e8 69 fc ff ff       	call   8011b7 <sys_page_unmap>
	return r;
  80154e:	83 c4 10             	add    $0x10,%esp
  801551:	eb ba                	jmp    80150d <fd_close+0x3c>
			r = 0;
  801553:	bb 00 00 00 00       	mov    $0x0,%ebx
  801558:	eb e9                	jmp    801543 <fd_close+0x72>

0080155a <close>:

int
close(int fdnum)
{
  80155a:	55                   	push   %ebp
  80155b:	89 e5                	mov    %esp,%ebp
  80155d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801560:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801563:	50                   	push   %eax
  801564:	ff 75 08             	pushl  0x8(%ebp)
  801567:	e8 b9 fe ff ff       	call   801425 <fd_lookup>
  80156c:	83 c4 08             	add    $0x8,%esp
  80156f:	85 c0                	test   %eax,%eax
  801571:	78 10                	js     801583 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801573:	83 ec 08             	sub    $0x8,%esp
  801576:	6a 01                	push   $0x1
  801578:	ff 75 f4             	pushl  -0xc(%ebp)
  80157b:	e8 51 ff ff ff       	call   8014d1 <fd_close>
  801580:	83 c4 10             	add    $0x10,%esp
}
  801583:	c9                   	leave  
  801584:	c3                   	ret    

00801585 <close_all>:

void
close_all(void)
{
  801585:	55                   	push   %ebp
  801586:	89 e5                	mov    %esp,%ebp
  801588:	53                   	push   %ebx
  801589:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80158c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801591:	83 ec 0c             	sub    $0xc,%esp
  801594:	53                   	push   %ebx
  801595:	e8 c0 ff ff ff       	call   80155a <close>
	for (i = 0; i < MAXFD; i++)
  80159a:	83 c3 01             	add    $0x1,%ebx
  80159d:	83 c4 10             	add    $0x10,%esp
  8015a0:	83 fb 20             	cmp    $0x20,%ebx
  8015a3:	75 ec                	jne    801591 <close_all+0xc>
}
  8015a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a8:	c9                   	leave  
  8015a9:	c3                   	ret    

008015aa <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015aa:	55                   	push   %ebp
  8015ab:	89 e5                	mov    %esp,%ebp
  8015ad:	57                   	push   %edi
  8015ae:	56                   	push   %esi
  8015af:	53                   	push   %ebx
  8015b0:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015b3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015b6:	50                   	push   %eax
  8015b7:	ff 75 08             	pushl  0x8(%ebp)
  8015ba:	e8 66 fe ff ff       	call   801425 <fd_lookup>
  8015bf:	89 c3                	mov    %eax,%ebx
  8015c1:	83 c4 08             	add    $0x8,%esp
  8015c4:	85 c0                	test   %eax,%eax
  8015c6:	0f 88 81 00 00 00    	js     80164d <dup+0xa3>
		return r;
	close(newfdnum);
  8015cc:	83 ec 0c             	sub    $0xc,%esp
  8015cf:	ff 75 0c             	pushl  0xc(%ebp)
  8015d2:	e8 83 ff ff ff       	call   80155a <close>

	newfd = INDEX2FD(newfdnum);
  8015d7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8015da:	c1 e6 0c             	shl    $0xc,%esi
  8015dd:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8015e3:	83 c4 04             	add    $0x4,%esp
  8015e6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015e9:	e8 d1 fd ff ff       	call   8013bf <fd2data>
  8015ee:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8015f0:	89 34 24             	mov    %esi,(%esp)
  8015f3:	e8 c7 fd ff ff       	call   8013bf <fd2data>
  8015f8:	83 c4 10             	add    $0x10,%esp
  8015fb:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015fd:	89 d8                	mov    %ebx,%eax
  8015ff:	c1 e8 16             	shr    $0x16,%eax
  801602:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801609:	a8 01                	test   $0x1,%al
  80160b:	74 11                	je     80161e <dup+0x74>
  80160d:	89 d8                	mov    %ebx,%eax
  80160f:	c1 e8 0c             	shr    $0xc,%eax
  801612:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801619:	f6 c2 01             	test   $0x1,%dl
  80161c:	75 39                	jne    801657 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80161e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801621:	89 d0                	mov    %edx,%eax
  801623:	c1 e8 0c             	shr    $0xc,%eax
  801626:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80162d:	83 ec 0c             	sub    $0xc,%esp
  801630:	25 07 0e 00 00       	and    $0xe07,%eax
  801635:	50                   	push   %eax
  801636:	56                   	push   %esi
  801637:	6a 00                	push   $0x0
  801639:	52                   	push   %edx
  80163a:	6a 00                	push   $0x0
  80163c:	e8 34 fb ff ff       	call   801175 <sys_page_map>
  801641:	89 c3                	mov    %eax,%ebx
  801643:	83 c4 20             	add    $0x20,%esp
  801646:	85 c0                	test   %eax,%eax
  801648:	78 31                	js     80167b <dup+0xd1>
		goto err;

	return newfdnum;
  80164a:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80164d:	89 d8                	mov    %ebx,%eax
  80164f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801652:	5b                   	pop    %ebx
  801653:	5e                   	pop    %esi
  801654:	5f                   	pop    %edi
  801655:	5d                   	pop    %ebp
  801656:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801657:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80165e:	83 ec 0c             	sub    $0xc,%esp
  801661:	25 07 0e 00 00       	and    $0xe07,%eax
  801666:	50                   	push   %eax
  801667:	57                   	push   %edi
  801668:	6a 00                	push   $0x0
  80166a:	53                   	push   %ebx
  80166b:	6a 00                	push   $0x0
  80166d:	e8 03 fb ff ff       	call   801175 <sys_page_map>
  801672:	89 c3                	mov    %eax,%ebx
  801674:	83 c4 20             	add    $0x20,%esp
  801677:	85 c0                	test   %eax,%eax
  801679:	79 a3                	jns    80161e <dup+0x74>
	sys_page_unmap(0, newfd);
  80167b:	83 ec 08             	sub    $0x8,%esp
  80167e:	56                   	push   %esi
  80167f:	6a 00                	push   $0x0
  801681:	e8 31 fb ff ff       	call   8011b7 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801686:	83 c4 08             	add    $0x8,%esp
  801689:	57                   	push   %edi
  80168a:	6a 00                	push   $0x0
  80168c:	e8 26 fb ff ff       	call   8011b7 <sys_page_unmap>
	return r;
  801691:	83 c4 10             	add    $0x10,%esp
  801694:	eb b7                	jmp    80164d <dup+0xa3>

00801696 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801696:	55                   	push   %ebp
  801697:	89 e5                	mov    %esp,%ebp
  801699:	53                   	push   %ebx
  80169a:	83 ec 14             	sub    $0x14,%esp
  80169d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016a0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016a3:	50                   	push   %eax
  8016a4:	53                   	push   %ebx
  8016a5:	e8 7b fd ff ff       	call   801425 <fd_lookup>
  8016aa:	83 c4 08             	add    $0x8,%esp
  8016ad:	85 c0                	test   %eax,%eax
  8016af:	78 3f                	js     8016f0 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b1:	83 ec 08             	sub    $0x8,%esp
  8016b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b7:	50                   	push   %eax
  8016b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016bb:	ff 30                	pushl  (%eax)
  8016bd:	e8 b9 fd ff ff       	call   80147b <dev_lookup>
  8016c2:	83 c4 10             	add    $0x10,%esp
  8016c5:	85 c0                	test   %eax,%eax
  8016c7:	78 27                	js     8016f0 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016c9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016cc:	8b 42 08             	mov    0x8(%edx),%eax
  8016cf:	83 e0 03             	and    $0x3,%eax
  8016d2:	83 f8 01             	cmp    $0x1,%eax
  8016d5:	74 1e                	je     8016f5 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8016d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016da:	8b 40 08             	mov    0x8(%eax),%eax
  8016dd:	85 c0                	test   %eax,%eax
  8016df:	74 35                	je     801716 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016e1:	83 ec 04             	sub    $0x4,%esp
  8016e4:	ff 75 10             	pushl  0x10(%ebp)
  8016e7:	ff 75 0c             	pushl  0xc(%ebp)
  8016ea:	52                   	push   %edx
  8016eb:	ff d0                	call   *%eax
  8016ed:	83 c4 10             	add    $0x10,%esp
}
  8016f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f3:	c9                   	leave  
  8016f4:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016f5:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8016fa:	8b 40 48             	mov    0x48(%eax),%eax
  8016fd:	83 ec 04             	sub    $0x4,%esp
  801700:	53                   	push   %ebx
  801701:	50                   	push   %eax
  801702:	68 d4 28 80 00       	push   $0x8028d4
  801707:	e8 0e f0 ff ff       	call   80071a <cprintf>
		return -E_INVAL;
  80170c:	83 c4 10             	add    $0x10,%esp
  80170f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801714:	eb da                	jmp    8016f0 <read+0x5a>
		return -E_NOT_SUPP;
  801716:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80171b:	eb d3                	jmp    8016f0 <read+0x5a>

0080171d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80171d:	55                   	push   %ebp
  80171e:	89 e5                	mov    %esp,%ebp
  801720:	57                   	push   %edi
  801721:	56                   	push   %esi
  801722:	53                   	push   %ebx
  801723:	83 ec 0c             	sub    $0xc,%esp
  801726:	8b 7d 08             	mov    0x8(%ebp),%edi
  801729:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80172c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801731:	39 f3                	cmp    %esi,%ebx
  801733:	73 25                	jae    80175a <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801735:	83 ec 04             	sub    $0x4,%esp
  801738:	89 f0                	mov    %esi,%eax
  80173a:	29 d8                	sub    %ebx,%eax
  80173c:	50                   	push   %eax
  80173d:	89 d8                	mov    %ebx,%eax
  80173f:	03 45 0c             	add    0xc(%ebp),%eax
  801742:	50                   	push   %eax
  801743:	57                   	push   %edi
  801744:	e8 4d ff ff ff       	call   801696 <read>
		if (m < 0)
  801749:	83 c4 10             	add    $0x10,%esp
  80174c:	85 c0                	test   %eax,%eax
  80174e:	78 08                	js     801758 <readn+0x3b>
			return m;
		if (m == 0)
  801750:	85 c0                	test   %eax,%eax
  801752:	74 06                	je     80175a <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  801754:	01 c3                	add    %eax,%ebx
  801756:	eb d9                	jmp    801731 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801758:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80175a:	89 d8                	mov    %ebx,%eax
  80175c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80175f:	5b                   	pop    %ebx
  801760:	5e                   	pop    %esi
  801761:	5f                   	pop    %edi
  801762:	5d                   	pop    %ebp
  801763:	c3                   	ret    

00801764 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801764:	55                   	push   %ebp
  801765:	89 e5                	mov    %esp,%ebp
  801767:	53                   	push   %ebx
  801768:	83 ec 14             	sub    $0x14,%esp
  80176b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80176e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801771:	50                   	push   %eax
  801772:	53                   	push   %ebx
  801773:	e8 ad fc ff ff       	call   801425 <fd_lookup>
  801778:	83 c4 08             	add    $0x8,%esp
  80177b:	85 c0                	test   %eax,%eax
  80177d:	78 3a                	js     8017b9 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80177f:	83 ec 08             	sub    $0x8,%esp
  801782:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801785:	50                   	push   %eax
  801786:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801789:	ff 30                	pushl  (%eax)
  80178b:	e8 eb fc ff ff       	call   80147b <dev_lookup>
  801790:	83 c4 10             	add    $0x10,%esp
  801793:	85 c0                	test   %eax,%eax
  801795:	78 22                	js     8017b9 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801797:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80179a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80179e:	74 1e                	je     8017be <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017a3:	8b 52 0c             	mov    0xc(%edx),%edx
  8017a6:	85 d2                	test   %edx,%edx
  8017a8:	74 35                	je     8017df <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017aa:	83 ec 04             	sub    $0x4,%esp
  8017ad:	ff 75 10             	pushl  0x10(%ebp)
  8017b0:	ff 75 0c             	pushl  0xc(%ebp)
  8017b3:	50                   	push   %eax
  8017b4:	ff d2                	call   *%edx
  8017b6:	83 c4 10             	add    $0x10,%esp
}
  8017b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017bc:	c9                   	leave  
  8017bd:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017be:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8017c3:	8b 40 48             	mov    0x48(%eax),%eax
  8017c6:	83 ec 04             	sub    $0x4,%esp
  8017c9:	53                   	push   %ebx
  8017ca:	50                   	push   %eax
  8017cb:	68 f0 28 80 00       	push   $0x8028f0
  8017d0:	e8 45 ef ff ff       	call   80071a <cprintf>
		return -E_INVAL;
  8017d5:	83 c4 10             	add    $0x10,%esp
  8017d8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017dd:	eb da                	jmp    8017b9 <write+0x55>
		return -E_NOT_SUPP;
  8017df:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017e4:	eb d3                	jmp    8017b9 <write+0x55>

008017e6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017e6:	55                   	push   %ebp
  8017e7:	89 e5                	mov    %esp,%ebp
  8017e9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017ec:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017ef:	50                   	push   %eax
  8017f0:	ff 75 08             	pushl  0x8(%ebp)
  8017f3:	e8 2d fc ff ff       	call   801425 <fd_lookup>
  8017f8:	83 c4 08             	add    $0x8,%esp
  8017fb:	85 c0                	test   %eax,%eax
  8017fd:	78 0e                	js     80180d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8017ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801802:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801805:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801808:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80180d:	c9                   	leave  
  80180e:	c3                   	ret    

0080180f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80180f:	55                   	push   %ebp
  801810:	89 e5                	mov    %esp,%ebp
  801812:	53                   	push   %ebx
  801813:	83 ec 14             	sub    $0x14,%esp
  801816:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801819:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80181c:	50                   	push   %eax
  80181d:	53                   	push   %ebx
  80181e:	e8 02 fc ff ff       	call   801425 <fd_lookup>
  801823:	83 c4 08             	add    $0x8,%esp
  801826:	85 c0                	test   %eax,%eax
  801828:	78 37                	js     801861 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80182a:	83 ec 08             	sub    $0x8,%esp
  80182d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801830:	50                   	push   %eax
  801831:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801834:	ff 30                	pushl  (%eax)
  801836:	e8 40 fc ff ff       	call   80147b <dev_lookup>
  80183b:	83 c4 10             	add    $0x10,%esp
  80183e:	85 c0                	test   %eax,%eax
  801840:	78 1f                	js     801861 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801842:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801845:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801849:	74 1b                	je     801866 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80184b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80184e:	8b 52 18             	mov    0x18(%edx),%edx
  801851:	85 d2                	test   %edx,%edx
  801853:	74 32                	je     801887 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801855:	83 ec 08             	sub    $0x8,%esp
  801858:	ff 75 0c             	pushl  0xc(%ebp)
  80185b:	50                   	push   %eax
  80185c:	ff d2                	call   *%edx
  80185e:	83 c4 10             	add    $0x10,%esp
}
  801861:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801864:	c9                   	leave  
  801865:	c3                   	ret    
			thisenv->env_id, fdnum);
  801866:	a1 b0 40 80 00       	mov    0x8040b0,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80186b:	8b 40 48             	mov    0x48(%eax),%eax
  80186e:	83 ec 04             	sub    $0x4,%esp
  801871:	53                   	push   %ebx
  801872:	50                   	push   %eax
  801873:	68 b0 28 80 00       	push   $0x8028b0
  801878:	e8 9d ee ff ff       	call   80071a <cprintf>
		return -E_INVAL;
  80187d:	83 c4 10             	add    $0x10,%esp
  801880:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801885:	eb da                	jmp    801861 <ftruncate+0x52>
		return -E_NOT_SUPP;
  801887:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80188c:	eb d3                	jmp    801861 <ftruncate+0x52>

0080188e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80188e:	55                   	push   %ebp
  80188f:	89 e5                	mov    %esp,%ebp
  801891:	53                   	push   %ebx
  801892:	83 ec 14             	sub    $0x14,%esp
  801895:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801898:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80189b:	50                   	push   %eax
  80189c:	ff 75 08             	pushl  0x8(%ebp)
  80189f:	e8 81 fb ff ff       	call   801425 <fd_lookup>
  8018a4:	83 c4 08             	add    $0x8,%esp
  8018a7:	85 c0                	test   %eax,%eax
  8018a9:	78 4b                	js     8018f6 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018ab:	83 ec 08             	sub    $0x8,%esp
  8018ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018b1:	50                   	push   %eax
  8018b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b5:	ff 30                	pushl  (%eax)
  8018b7:	e8 bf fb ff ff       	call   80147b <dev_lookup>
  8018bc:	83 c4 10             	add    $0x10,%esp
  8018bf:	85 c0                	test   %eax,%eax
  8018c1:	78 33                	js     8018f6 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  8018c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018c6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018ca:	74 2f                	je     8018fb <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018cc:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018cf:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018d6:	00 00 00 
	stat->st_isdir = 0;
  8018d9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018e0:	00 00 00 
	stat->st_dev = dev;
  8018e3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018e9:	83 ec 08             	sub    $0x8,%esp
  8018ec:	53                   	push   %ebx
  8018ed:	ff 75 f0             	pushl  -0x10(%ebp)
  8018f0:	ff 50 14             	call   *0x14(%eax)
  8018f3:	83 c4 10             	add    $0x10,%esp
}
  8018f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f9:	c9                   	leave  
  8018fa:	c3                   	ret    
		return -E_NOT_SUPP;
  8018fb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801900:	eb f4                	jmp    8018f6 <fstat+0x68>

00801902 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801902:	55                   	push   %ebp
  801903:	89 e5                	mov    %esp,%ebp
  801905:	56                   	push   %esi
  801906:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801907:	83 ec 08             	sub    $0x8,%esp
  80190a:	6a 00                	push   $0x0
  80190c:	ff 75 08             	pushl  0x8(%ebp)
  80190f:	e8 e7 01 00 00       	call   801afb <open>
  801914:	89 c3                	mov    %eax,%ebx
  801916:	83 c4 10             	add    $0x10,%esp
  801919:	85 c0                	test   %eax,%eax
  80191b:	78 1b                	js     801938 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80191d:	83 ec 08             	sub    $0x8,%esp
  801920:	ff 75 0c             	pushl  0xc(%ebp)
  801923:	50                   	push   %eax
  801924:	e8 65 ff ff ff       	call   80188e <fstat>
  801929:	89 c6                	mov    %eax,%esi
	close(fd);
  80192b:	89 1c 24             	mov    %ebx,(%esp)
  80192e:	e8 27 fc ff ff       	call   80155a <close>
	return r;
  801933:	83 c4 10             	add    $0x10,%esp
  801936:	89 f3                	mov    %esi,%ebx
}
  801938:	89 d8                	mov    %ebx,%eax
  80193a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80193d:	5b                   	pop    %ebx
  80193e:	5e                   	pop    %esi
  80193f:	5d                   	pop    %ebp
  801940:	c3                   	ret    

00801941 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801941:	55                   	push   %ebp
  801942:	89 e5                	mov    %esp,%ebp
  801944:	56                   	push   %esi
  801945:	53                   	push   %ebx
  801946:	89 c6                	mov    %eax,%esi
  801948:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80194a:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  801951:	74 27                	je     80197a <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801953:	6a 07                	push   $0x7
  801955:	68 00 50 80 00       	push   $0x805000
  80195a:	56                   	push   %esi
  80195b:	ff 35 ac 40 80 00    	pushl  0x8040ac
  801961:	e8 79 07 00 00       	call   8020df <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801966:	83 c4 0c             	add    $0xc,%esp
  801969:	6a 00                	push   $0x0
  80196b:	53                   	push   %ebx
  80196c:	6a 00                	push   $0x0
  80196e:	e8 f7 06 00 00       	call   80206a <ipc_recv>
}
  801973:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801976:	5b                   	pop    %ebx
  801977:	5e                   	pop    %esi
  801978:	5d                   	pop    %ebp
  801979:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80197a:	83 ec 0c             	sub    $0xc,%esp
  80197d:	6a 01                	push   $0x1
  80197f:	e8 b1 07 00 00       	call   802135 <ipc_find_env>
  801984:	a3 ac 40 80 00       	mov    %eax,0x8040ac
  801989:	83 c4 10             	add    $0x10,%esp
  80198c:	eb c5                	jmp    801953 <fsipc+0x12>

0080198e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80198e:	55                   	push   %ebp
  80198f:	89 e5                	mov    %esp,%ebp
  801991:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801994:	8b 45 08             	mov    0x8(%ebp),%eax
  801997:	8b 40 0c             	mov    0xc(%eax),%eax
  80199a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80199f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ac:	b8 02 00 00 00       	mov    $0x2,%eax
  8019b1:	e8 8b ff ff ff       	call   801941 <fsipc>
}
  8019b6:	c9                   	leave  
  8019b7:	c3                   	ret    

008019b8 <devfile_flush>:
{
  8019b8:	55                   	push   %ebp
  8019b9:	89 e5                	mov    %esp,%ebp
  8019bb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019be:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c1:	8b 40 0c             	mov    0xc(%eax),%eax
  8019c4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ce:	b8 06 00 00 00       	mov    $0x6,%eax
  8019d3:	e8 69 ff ff ff       	call   801941 <fsipc>
}
  8019d8:	c9                   	leave  
  8019d9:	c3                   	ret    

008019da <devfile_stat>:
{
  8019da:	55                   	push   %ebp
  8019db:	89 e5                	mov    %esp,%ebp
  8019dd:	53                   	push   %ebx
  8019de:	83 ec 04             	sub    $0x4,%esp
  8019e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e7:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ea:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f4:	b8 05 00 00 00       	mov    $0x5,%eax
  8019f9:	e8 43 ff ff ff       	call   801941 <fsipc>
  8019fe:	85 c0                	test   %eax,%eax
  801a00:	78 2c                	js     801a2e <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a02:	83 ec 08             	sub    $0x8,%esp
  801a05:	68 00 50 80 00       	push   $0x805000
  801a0a:	53                   	push   %ebx
  801a0b:	e8 29 f3 ff ff       	call   800d39 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a10:	a1 80 50 80 00       	mov    0x805080,%eax
  801a15:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a1b:	a1 84 50 80 00       	mov    0x805084,%eax
  801a20:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a26:	83 c4 10             	add    $0x10,%esp
  801a29:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a2e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a31:	c9                   	leave  
  801a32:	c3                   	ret    

00801a33 <devfile_write>:
{
  801a33:	55                   	push   %ebp
  801a34:	89 e5                	mov    %esp,%ebp
  801a36:	83 ec 0c             	sub    $0xc,%esp
  801a39:	8b 45 10             	mov    0x10(%ebp),%eax
  801a3c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a41:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a46:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a49:	8b 55 08             	mov    0x8(%ebp),%edx
  801a4c:	8b 52 0c             	mov    0xc(%edx),%edx
  801a4f:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801a55:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf,buf,n);
  801a5a:	50                   	push   %eax
  801a5b:	ff 75 0c             	pushl  0xc(%ebp)
  801a5e:	68 08 50 80 00       	push   $0x805008
  801a63:	e8 5f f4 ff ff       	call   800ec7 <memmove>
	if((r = fsipc(FSREQ_WRITE,NULL))<0)
  801a68:	ba 00 00 00 00       	mov    $0x0,%edx
  801a6d:	b8 04 00 00 00       	mov    $0x4,%eax
  801a72:	e8 ca fe ff ff       	call   801941 <fsipc>
}
  801a77:	c9                   	leave  
  801a78:	c3                   	ret    

00801a79 <devfile_read>:
{
  801a79:	55                   	push   %ebp
  801a7a:	89 e5                	mov    %esp,%ebp
  801a7c:	56                   	push   %esi
  801a7d:	53                   	push   %ebx
  801a7e:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a81:	8b 45 08             	mov    0x8(%ebp),%eax
  801a84:	8b 40 0c             	mov    0xc(%eax),%eax
  801a87:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a8c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a92:	ba 00 00 00 00       	mov    $0x0,%edx
  801a97:	b8 03 00 00 00       	mov    $0x3,%eax
  801a9c:	e8 a0 fe ff ff       	call   801941 <fsipc>
  801aa1:	89 c3                	mov    %eax,%ebx
  801aa3:	85 c0                	test   %eax,%eax
  801aa5:	78 1f                	js     801ac6 <devfile_read+0x4d>
	assert(r <= n);
  801aa7:	39 f0                	cmp    %esi,%eax
  801aa9:	77 24                	ja     801acf <devfile_read+0x56>
	assert(r <= PGSIZE);
  801aab:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ab0:	7f 33                	jg     801ae5 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801ab2:	83 ec 04             	sub    $0x4,%esp
  801ab5:	50                   	push   %eax
  801ab6:	68 00 50 80 00       	push   $0x805000
  801abb:	ff 75 0c             	pushl  0xc(%ebp)
  801abe:	e8 04 f4 ff ff       	call   800ec7 <memmove>
	return r;
  801ac3:	83 c4 10             	add    $0x10,%esp
}
  801ac6:	89 d8                	mov    %ebx,%eax
  801ac8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801acb:	5b                   	pop    %ebx
  801acc:	5e                   	pop    %esi
  801acd:	5d                   	pop    %ebp
  801ace:	c3                   	ret    
	assert(r <= n);
  801acf:	68 20 29 80 00       	push   $0x802920
  801ad4:	68 27 29 80 00       	push   $0x802927
  801ad9:	6a 7c                	push   $0x7c
  801adb:	68 3c 29 80 00       	push   $0x80293c
  801ae0:	e8 5a eb ff ff       	call   80063f <_panic>
	assert(r <= PGSIZE);
  801ae5:	68 47 29 80 00       	push   $0x802947
  801aea:	68 27 29 80 00       	push   $0x802927
  801aef:	6a 7d                	push   $0x7d
  801af1:	68 3c 29 80 00       	push   $0x80293c
  801af6:	e8 44 eb ff ff       	call   80063f <_panic>

00801afb <open>:
{
  801afb:	55                   	push   %ebp
  801afc:	89 e5                	mov    %esp,%ebp
  801afe:	56                   	push   %esi
  801aff:	53                   	push   %ebx
  801b00:	83 ec 1c             	sub    $0x1c,%esp
  801b03:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801b06:	56                   	push   %esi
  801b07:	e8 f6 f1 ff ff       	call   800d02 <strlen>
  801b0c:	83 c4 10             	add    $0x10,%esp
  801b0f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b14:	7f 6c                	jg     801b82 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801b16:	83 ec 0c             	sub    $0xc,%esp
  801b19:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b1c:	50                   	push   %eax
  801b1d:	e8 b4 f8 ff ff       	call   8013d6 <fd_alloc>
  801b22:	89 c3                	mov    %eax,%ebx
  801b24:	83 c4 10             	add    $0x10,%esp
  801b27:	85 c0                	test   %eax,%eax
  801b29:	78 3c                	js     801b67 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801b2b:	83 ec 08             	sub    $0x8,%esp
  801b2e:	56                   	push   %esi
  801b2f:	68 00 50 80 00       	push   $0x805000
  801b34:	e8 00 f2 ff ff       	call   800d39 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b39:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b3c:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b41:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b44:	b8 01 00 00 00       	mov    $0x1,%eax
  801b49:	e8 f3 fd ff ff       	call   801941 <fsipc>
  801b4e:	89 c3                	mov    %eax,%ebx
  801b50:	83 c4 10             	add    $0x10,%esp
  801b53:	85 c0                	test   %eax,%eax
  801b55:	78 19                	js     801b70 <open+0x75>
	return fd2num(fd);
  801b57:	83 ec 0c             	sub    $0xc,%esp
  801b5a:	ff 75 f4             	pushl  -0xc(%ebp)
  801b5d:	e8 4d f8 ff ff       	call   8013af <fd2num>
  801b62:	89 c3                	mov    %eax,%ebx
  801b64:	83 c4 10             	add    $0x10,%esp
}
  801b67:	89 d8                	mov    %ebx,%eax
  801b69:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b6c:	5b                   	pop    %ebx
  801b6d:	5e                   	pop    %esi
  801b6e:	5d                   	pop    %ebp
  801b6f:	c3                   	ret    
		fd_close(fd, 0);
  801b70:	83 ec 08             	sub    $0x8,%esp
  801b73:	6a 00                	push   $0x0
  801b75:	ff 75 f4             	pushl  -0xc(%ebp)
  801b78:	e8 54 f9 ff ff       	call   8014d1 <fd_close>
		return r;
  801b7d:	83 c4 10             	add    $0x10,%esp
  801b80:	eb e5                	jmp    801b67 <open+0x6c>
		return -E_BAD_PATH;
  801b82:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801b87:	eb de                	jmp    801b67 <open+0x6c>

00801b89 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b89:	55                   	push   %ebp
  801b8a:	89 e5                	mov    %esp,%ebp
  801b8c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b8f:	ba 00 00 00 00       	mov    $0x0,%edx
  801b94:	b8 08 00 00 00       	mov    $0x8,%eax
  801b99:	e8 a3 fd ff ff       	call   801941 <fsipc>
}
  801b9e:	c9                   	leave  
  801b9f:	c3                   	ret    

00801ba0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ba0:	55                   	push   %ebp
  801ba1:	89 e5                	mov    %esp,%ebp
  801ba3:	56                   	push   %esi
  801ba4:	53                   	push   %ebx
  801ba5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ba8:	83 ec 0c             	sub    $0xc,%esp
  801bab:	ff 75 08             	pushl  0x8(%ebp)
  801bae:	e8 0c f8 ff ff       	call   8013bf <fd2data>
  801bb3:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801bb5:	83 c4 08             	add    $0x8,%esp
  801bb8:	68 53 29 80 00       	push   $0x802953
  801bbd:	53                   	push   %ebx
  801bbe:	e8 76 f1 ff ff       	call   800d39 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801bc3:	8b 46 04             	mov    0x4(%esi),%eax
  801bc6:	2b 06                	sub    (%esi),%eax
  801bc8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801bce:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bd5:	00 00 00 
	stat->st_dev = &devpipe;
  801bd8:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801bdf:	30 80 00 
	return 0;
}
  801be2:	b8 00 00 00 00       	mov    $0x0,%eax
  801be7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bea:	5b                   	pop    %ebx
  801beb:	5e                   	pop    %esi
  801bec:	5d                   	pop    %ebp
  801bed:	c3                   	ret    

00801bee <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bee:	55                   	push   %ebp
  801bef:	89 e5                	mov    %esp,%ebp
  801bf1:	53                   	push   %ebx
  801bf2:	83 ec 0c             	sub    $0xc,%esp
  801bf5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bf8:	53                   	push   %ebx
  801bf9:	6a 00                	push   $0x0
  801bfb:	e8 b7 f5 ff ff       	call   8011b7 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c00:	89 1c 24             	mov    %ebx,(%esp)
  801c03:	e8 b7 f7 ff ff       	call   8013bf <fd2data>
  801c08:	83 c4 08             	add    $0x8,%esp
  801c0b:	50                   	push   %eax
  801c0c:	6a 00                	push   $0x0
  801c0e:	e8 a4 f5 ff ff       	call   8011b7 <sys_page_unmap>
}
  801c13:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c16:	c9                   	leave  
  801c17:	c3                   	ret    

00801c18 <_pipeisclosed>:
{
  801c18:	55                   	push   %ebp
  801c19:	89 e5                	mov    %esp,%ebp
  801c1b:	57                   	push   %edi
  801c1c:	56                   	push   %esi
  801c1d:	53                   	push   %ebx
  801c1e:	83 ec 1c             	sub    $0x1c,%esp
  801c21:	89 c7                	mov    %eax,%edi
  801c23:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801c25:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801c2a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c2d:	83 ec 0c             	sub    $0xc,%esp
  801c30:	57                   	push   %edi
  801c31:	e8 38 05 00 00       	call   80216e <pageref>
  801c36:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801c39:	89 34 24             	mov    %esi,(%esp)
  801c3c:	e8 2d 05 00 00       	call   80216e <pageref>
		nn = thisenv->env_runs;
  801c41:	8b 15 b0 40 80 00    	mov    0x8040b0,%edx
  801c47:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c4a:	83 c4 10             	add    $0x10,%esp
  801c4d:	39 cb                	cmp    %ecx,%ebx
  801c4f:	74 1b                	je     801c6c <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801c51:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c54:	75 cf                	jne    801c25 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c56:	8b 42 58             	mov    0x58(%edx),%eax
  801c59:	6a 01                	push   $0x1
  801c5b:	50                   	push   %eax
  801c5c:	53                   	push   %ebx
  801c5d:	68 5a 29 80 00       	push   $0x80295a
  801c62:	e8 b3 ea ff ff       	call   80071a <cprintf>
  801c67:	83 c4 10             	add    $0x10,%esp
  801c6a:	eb b9                	jmp    801c25 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801c6c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c6f:	0f 94 c0             	sete   %al
  801c72:	0f b6 c0             	movzbl %al,%eax
}
  801c75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c78:	5b                   	pop    %ebx
  801c79:	5e                   	pop    %esi
  801c7a:	5f                   	pop    %edi
  801c7b:	5d                   	pop    %ebp
  801c7c:	c3                   	ret    

00801c7d <devpipe_write>:
{
  801c7d:	55                   	push   %ebp
  801c7e:	89 e5                	mov    %esp,%ebp
  801c80:	57                   	push   %edi
  801c81:	56                   	push   %esi
  801c82:	53                   	push   %ebx
  801c83:	83 ec 28             	sub    $0x28,%esp
  801c86:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801c89:	56                   	push   %esi
  801c8a:	e8 30 f7 ff ff       	call   8013bf <fd2data>
  801c8f:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c91:	83 c4 10             	add    $0x10,%esp
  801c94:	bf 00 00 00 00       	mov    $0x0,%edi
  801c99:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c9c:	74 4f                	je     801ced <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c9e:	8b 43 04             	mov    0x4(%ebx),%eax
  801ca1:	8b 0b                	mov    (%ebx),%ecx
  801ca3:	8d 51 20             	lea    0x20(%ecx),%edx
  801ca6:	39 d0                	cmp    %edx,%eax
  801ca8:	72 14                	jb     801cbe <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801caa:	89 da                	mov    %ebx,%edx
  801cac:	89 f0                	mov    %esi,%eax
  801cae:	e8 65 ff ff ff       	call   801c18 <_pipeisclosed>
  801cb3:	85 c0                	test   %eax,%eax
  801cb5:	75 3a                	jne    801cf1 <devpipe_write+0x74>
			sys_yield();
  801cb7:	e8 57 f4 ff ff       	call   801113 <sys_yield>
  801cbc:	eb e0                	jmp    801c9e <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cc1:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801cc5:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801cc8:	89 c2                	mov    %eax,%edx
  801cca:	c1 fa 1f             	sar    $0x1f,%edx
  801ccd:	89 d1                	mov    %edx,%ecx
  801ccf:	c1 e9 1b             	shr    $0x1b,%ecx
  801cd2:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801cd5:	83 e2 1f             	and    $0x1f,%edx
  801cd8:	29 ca                	sub    %ecx,%edx
  801cda:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801cde:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ce2:	83 c0 01             	add    $0x1,%eax
  801ce5:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801ce8:	83 c7 01             	add    $0x1,%edi
  801ceb:	eb ac                	jmp    801c99 <devpipe_write+0x1c>
	return i;
  801ced:	89 f8                	mov    %edi,%eax
  801cef:	eb 05                	jmp    801cf6 <devpipe_write+0x79>
				return 0;
  801cf1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cf9:	5b                   	pop    %ebx
  801cfa:	5e                   	pop    %esi
  801cfb:	5f                   	pop    %edi
  801cfc:	5d                   	pop    %ebp
  801cfd:	c3                   	ret    

00801cfe <devpipe_read>:
{
  801cfe:	55                   	push   %ebp
  801cff:	89 e5                	mov    %esp,%ebp
  801d01:	57                   	push   %edi
  801d02:	56                   	push   %esi
  801d03:	53                   	push   %ebx
  801d04:	83 ec 18             	sub    $0x18,%esp
  801d07:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801d0a:	57                   	push   %edi
  801d0b:	e8 af f6 ff ff       	call   8013bf <fd2data>
  801d10:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d12:	83 c4 10             	add    $0x10,%esp
  801d15:	be 00 00 00 00       	mov    $0x0,%esi
  801d1a:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d1d:	74 47                	je     801d66 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801d1f:	8b 03                	mov    (%ebx),%eax
  801d21:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d24:	75 22                	jne    801d48 <devpipe_read+0x4a>
			if (i > 0)
  801d26:	85 f6                	test   %esi,%esi
  801d28:	75 14                	jne    801d3e <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801d2a:	89 da                	mov    %ebx,%edx
  801d2c:	89 f8                	mov    %edi,%eax
  801d2e:	e8 e5 fe ff ff       	call   801c18 <_pipeisclosed>
  801d33:	85 c0                	test   %eax,%eax
  801d35:	75 33                	jne    801d6a <devpipe_read+0x6c>
			sys_yield();
  801d37:	e8 d7 f3 ff ff       	call   801113 <sys_yield>
  801d3c:	eb e1                	jmp    801d1f <devpipe_read+0x21>
				return i;
  801d3e:	89 f0                	mov    %esi,%eax
}
  801d40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d43:	5b                   	pop    %ebx
  801d44:	5e                   	pop    %esi
  801d45:	5f                   	pop    %edi
  801d46:	5d                   	pop    %ebp
  801d47:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d48:	99                   	cltd   
  801d49:	c1 ea 1b             	shr    $0x1b,%edx
  801d4c:	01 d0                	add    %edx,%eax
  801d4e:	83 e0 1f             	and    $0x1f,%eax
  801d51:	29 d0                	sub    %edx,%eax
  801d53:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801d58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d5b:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801d5e:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801d61:	83 c6 01             	add    $0x1,%esi
  801d64:	eb b4                	jmp    801d1a <devpipe_read+0x1c>
	return i;
  801d66:	89 f0                	mov    %esi,%eax
  801d68:	eb d6                	jmp    801d40 <devpipe_read+0x42>
				return 0;
  801d6a:	b8 00 00 00 00       	mov    $0x0,%eax
  801d6f:	eb cf                	jmp    801d40 <devpipe_read+0x42>

00801d71 <pipe>:
{
  801d71:	55                   	push   %ebp
  801d72:	89 e5                	mov    %esp,%ebp
  801d74:	56                   	push   %esi
  801d75:	53                   	push   %ebx
  801d76:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801d79:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d7c:	50                   	push   %eax
  801d7d:	e8 54 f6 ff ff       	call   8013d6 <fd_alloc>
  801d82:	89 c3                	mov    %eax,%ebx
  801d84:	83 c4 10             	add    $0x10,%esp
  801d87:	85 c0                	test   %eax,%eax
  801d89:	78 5b                	js     801de6 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d8b:	83 ec 04             	sub    $0x4,%esp
  801d8e:	68 07 04 00 00       	push   $0x407
  801d93:	ff 75 f4             	pushl  -0xc(%ebp)
  801d96:	6a 00                	push   $0x0
  801d98:	e8 95 f3 ff ff       	call   801132 <sys_page_alloc>
  801d9d:	89 c3                	mov    %eax,%ebx
  801d9f:	83 c4 10             	add    $0x10,%esp
  801da2:	85 c0                	test   %eax,%eax
  801da4:	78 40                	js     801de6 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801da6:	83 ec 0c             	sub    $0xc,%esp
  801da9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801dac:	50                   	push   %eax
  801dad:	e8 24 f6 ff ff       	call   8013d6 <fd_alloc>
  801db2:	89 c3                	mov    %eax,%ebx
  801db4:	83 c4 10             	add    $0x10,%esp
  801db7:	85 c0                	test   %eax,%eax
  801db9:	78 1b                	js     801dd6 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dbb:	83 ec 04             	sub    $0x4,%esp
  801dbe:	68 07 04 00 00       	push   $0x407
  801dc3:	ff 75 f0             	pushl  -0x10(%ebp)
  801dc6:	6a 00                	push   $0x0
  801dc8:	e8 65 f3 ff ff       	call   801132 <sys_page_alloc>
  801dcd:	89 c3                	mov    %eax,%ebx
  801dcf:	83 c4 10             	add    $0x10,%esp
  801dd2:	85 c0                	test   %eax,%eax
  801dd4:	79 19                	jns    801def <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801dd6:	83 ec 08             	sub    $0x8,%esp
  801dd9:	ff 75 f4             	pushl  -0xc(%ebp)
  801ddc:	6a 00                	push   $0x0
  801dde:	e8 d4 f3 ff ff       	call   8011b7 <sys_page_unmap>
  801de3:	83 c4 10             	add    $0x10,%esp
}
  801de6:	89 d8                	mov    %ebx,%eax
  801de8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801deb:	5b                   	pop    %ebx
  801dec:	5e                   	pop    %esi
  801ded:	5d                   	pop    %ebp
  801dee:	c3                   	ret    
	va = fd2data(fd0);
  801def:	83 ec 0c             	sub    $0xc,%esp
  801df2:	ff 75 f4             	pushl  -0xc(%ebp)
  801df5:	e8 c5 f5 ff ff       	call   8013bf <fd2data>
  801dfa:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dfc:	83 c4 0c             	add    $0xc,%esp
  801dff:	68 07 04 00 00       	push   $0x407
  801e04:	50                   	push   %eax
  801e05:	6a 00                	push   $0x0
  801e07:	e8 26 f3 ff ff       	call   801132 <sys_page_alloc>
  801e0c:	89 c3                	mov    %eax,%ebx
  801e0e:	83 c4 10             	add    $0x10,%esp
  801e11:	85 c0                	test   %eax,%eax
  801e13:	0f 88 8c 00 00 00    	js     801ea5 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e19:	83 ec 0c             	sub    $0xc,%esp
  801e1c:	ff 75 f0             	pushl  -0x10(%ebp)
  801e1f:	e8 9b f5 ff ff       	call   8013bf <fd2data>
  801e24:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e2b:	50                   	push   %eax
  801e2c:	6a 00                	push   $0x0
  801e2e:	56                   	push   %esi
  801e2f:	6a 00                	push   $0x0
  801e31:	e8 3f f3 ff ff       	call   801175 <sys_page_map>
  801e36:	89 c3                	mov    %eax,%ebx
  801e38:	83 c4 20             	add    $0x20,%esp
  801e3b:	85 c0                	test   %eax,%eax
  801e3d:	78 58                	js     801e97 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801e3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e42:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e48:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e4d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801e54:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e57:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e5d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e62:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801e69:	83 ec 0c             	sub    $0xc,%esp
  801e6c:	ff 75 f4             	pushl  -0xc(%ebp)
  801e6f:	e8 3b f5 ff ff       	call   8013af <fd2num>
  801e74:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e77:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e79:	83 c4 04             	add    $0x4,%esp
  801e7c:	ff 75 f0             	pushl  -0x10(%ebp)
  801e7f:	e8 2b f5 ff ff       	call   8013af <fd2num>
  801e84:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e87:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e8a:	83 c4 10             	add    $0x10,%esp
  801e8d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e92:	e9 4f ff ff ff       	jmp    801de6 <pipe+0x75>
	sys_page_unmap(0, va);
  801e97:	83 ec 08             	sub    $0x8,%esp
  801e9a:	56                   	push   %esi
  801e9b:	6a 00                	push   $0x0
  801e9d:	e8 15 f3 ff ff       	call   8011b7 <sys_page_unmap>
  801ea2:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801ea5:	83 ec 08             	sub    $0x8,%esp
  801ea8:	ff 75 f0             	pushl  -0x10(%ebp)
  801eab:	6a 00                	push   $0x0
  801ead:	e8 05 f3 ff ff       	call   8011b7 <sys_page_unmap>
  801eb2:	83 c4 10             	add    $0x10,%esp
  801eb5:	e9 1c ff ff ff       	jmp    801dd6 <pipe+0x65>

00801eba <pipeisclosed>:
{
  801eba:	55                   	push   %ebp
  801ebb:	89 e5                	mov    %esp,%ebp
  801ebd:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ec0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ec3:	50                   	push   %eax
  801ec4:	ff 75 08             	pushl  0x8(%ebp)
  801ec7:	e8 59 f5 ff ff       	call   801425 <fd_lookup>
  801ecc:	83 c4 10             	add    $0x10,%esp
  801ecf:	85 c0                	test   %eax,%eax
  801ed1:	78 18                	js     801eeb <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801ed3:	83 ec 0c             	sub    $0xc,%esp
  801ed6:	ff 75 f4             	pushl  -0xc(%ebp)
  801ed9:	e8 e1 f4 ff ff       	call   8013bf <fd2data>
	return _pipeisclosed(fd, p);
  801ede:	89 c2                	mov    %eax,%edx
  801ee0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee3:	e8 30 fd ff ff       	call   801c18 <_pipeisclosed>
  801ee8:	83 c4 10             	add    $0x10,%esp
}
  801eeb:	c9                   	leave  
  801eec:	c3                   	ret    

00801eed <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801eed:	55                   	push   %ebp
  801eee:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ef0:	b8 00 00 00 00       	mov    $0x0,%eax
  801ef5:	5d                   	pop    %ebp
  801ef6:	c3                   	ret    

00801ef7 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ef7:	55                   	push   %ebp
  801ef8:	89 e5                	mov    %esp,%ebp
  801efa:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801efd:	68 72 29 80 00       	push   $0x802972
  801f02:	ff 75 0c             	pushl  0xc(%ebp)
  801f05:	e8 2f ee ff ff       	call   800d39 <strcpy>
	return 0;
}
  801f0a:	b8 00 00 00 00       	mov    $0x0,%eax
  801f0f:	c9                   	leave  
  801f10:	c3                   	ret    

00801f11 <devcons_write>:
{
  801f11:	55                   	push   %ebp
  801f12:	89 e5                	mov    %esp,%ebp
  801f14:	57                   	push   %edi
  801f15:	56                   	push   %esi
  801f16:	53                   	push   %ebx
  801f17:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801f1d:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801f22:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801f28:	eb 2f                	jmp    801f59 <devcons_write+0x48>
		m = n - tot;
  801f2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f2d:	29 f3                	sub    %esi,%ebx
  801f2f:	83 fb 7f             	cmp    $0x7f,%ebx
  801f32:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801f37:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801f3a:	83 ec 04             	sub    $0x4,%esp
  801f3d:	53                   	push   %ebx
  801f3e:	89 f0                	mov    %esi,%eax
  801f40:	03 45 0c             	add    0xc(%ebp),%eax
  801f43:	50                   	push   %eax
  801f44:	57                   	push   %edi
  801f45:	e8 7d ef ff ff       	call   800ec7 <memmove>
		sys_cputs(buf, m);
  801f4a:	83 c4 08             	add    $0x8,%esp
  801f4d:	53                   	push   %ebx
  801f4e:	57                   	push   %edi
  801f4f:	e8 22 f1 ff ff       	call   801076 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801f54:	01 de                	add    %ebx,%esi
  801f56:	83 c4 10             	add    $0x10,%esp
  801f59:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f5c:	72 cc                	jb     801f2a <devcons_write+0x19>
}
  801f5e:	89 f0                	mov    %esi,%eax
  801f60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f63:	5b                   	pop    %ebx
  801f64:	5e                   	pop    %esi
  801f65:	5f                   	pop    %edi
  801f66:	5d                   	pop    %ebp
  801f67:	c3                   	ret    

00801f68 <devcons_read>:
{
  801f68:	55                   	push   %ebp
  801f69:	89 e5                	mov    %esp,%ebp
  801f6b:	83 ec 08             	sub    $0x8,%esp
  801f6e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801f73:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f77:	75 07                	jne    801f80 <devcons_read+0x18>
}
  801f79:	c9                   	leave  
  801f7a:	c3                   	ret    
		sys_yield();
  801f7b:	e8 93 f1 ff ff       	call   801113 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801f80:	e8 0f f1 ff ff       	call   801094 <sys_cgetc>
  801f85:	85 c0                	test   %eax,%eax
  801f87:	74 f2                	je     801f7b <devcons_read+0x13>
	if (c < 0)
  801f89:	85 c0                	test   %eax,%eax
  801f8b:	78 ec                	js     801f79 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801f8d:	83 f8 04             	cmp    $0x4,%eax
  801f90:	74 0c                	je     801f9e <devcons_read+0x36>
	*(char*)vbuf = c;
  801f92:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f95:	88 02                	mov    %al,(%edx)
	return 1;
  801f97:	b8 01 00 00 00       	mov    $0x1,%eax
  801f9c:	eb db                	jmp    801f79 <devcons_read+0x11>
		return 0;
  801f9e:	b8 00 00 00 00       	mov    $0x0,%eax
  801fa3:	eb d4                	jmp    801f79 <devcons_read+0x11>

00801fa5 <cputchar>:
{
  801fa5:	55                   	push   %ebp
  801fa6:	89 e5                	mov    %esp,%ebp
  801fa8:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801fab:	8b 45 08             	mov    0x8(%ebp),%eax
  801fae:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801fb1:	6a 01                	push   $0x1
  801fb3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fb6:	50                   	push   %eax
  801fb7:	e8 ba f0 ff ff       	call   801076 <sys_cputs>
}
  801fbc:	83 c4 10             	add    $0x10,%esp
  801fbf:	c9                   	leave  
  801fc0:	c3                   	ret    

00801fc1 <getchar>:
{
  801fc1:	55                   	push   %ebp
  801fc2:	89 e5                	mov    %esp,%ebp
  801fc4:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801fc7:	6a 01                	push   $0x1
  801fc9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fcc:	50                   	push   %eax
  801fcd:	6a 00                	push   $0x0
  801fcf:	e8 c2 f6 ff ff       	call   801696 <read>
	if (r < 0)
  801fd4:	83 c4 10             	add    $0x10,%esp
  801fd7:	85 c0                	test   %eax,%eax
  801fd9:	78 08                	js     801fe3 <getchar+0x22>
	if (r < 1)
  801fdb:	85 c0                	test   %eax,%eax
  801fdd:	7e 06                	jle    801fe5 <getchar+0x24>
	return c;
  801fdf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801fe3:	c9                   	leave  
  801fe4:	c3                   	ret    
		return -E_EOF;
  801fe5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801fea:	eb f7                	jmp    801fe3 <getchar+0x22>

00801fec <iscons>:
{
  801fec:	55                   	push   %ebp
  801fed:	89 e5                	mov    %esp,%ebp
  801fef:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ff2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ff5:	50                   	push   %eax
  801ff6:	ff 75 08             	pushl  0x8(%ebp)
  801ff9:	e8 27 f4 ff ff       	call   801425 <fd_lookup>
  801ffe:	83 c4 10             	add    $0x10,%esp
  802001:	85 c0                	test   %eax,%eax
  802003:	78 11                	js     802016 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  802005:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802008:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80200e:	39 10                	cmp    %edx,(%eax)
  802010:	0f 94 c0             	sete   %al
  802013:	0f b6 c0             	movzbl %al,%eax
}
  802016:	c9                   	leave  
  802017:	c3                   	ret    

00802018 <opencons>:
{
  802018:	55                   	push   %ebp
  802019:	89 e5                	mov    %esp,%ebp
  80201b:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80201e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802021:	50                   	push   %eax
  802022:	e8 af f3 ff ff       	call   8013d6 <fd_alloc>
  802027:	83 c4 10             	add    $0x10,%esp
  80202a:	85 c0                	test   %eax,%eax
  80202c:	78 3a                	js     802068 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80202e:	83 ec 04             	sub    $0x4,%esp
  802031:	68 07 04 00 00       	push   $0x407
  802036:	ff 75 f4             	pushl  -0xc(%ebp)
  802039:	6a 00                	push   $0x0
  80203b:	e8 f2 f0 ff ff       	call   801132 <sys_page_alloc>
  802040:	83 c4 10             	add    $0x10,%esp
  802043:	85 c0                	test   %eax,%eax
  802045:	78 21                	js     802068 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  802047:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80204a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802050:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802052:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802055:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80205c:	83 ec 0c             	sub    $0xc,%esp
  80205f:	50                   	push   %eax
  802060:	e8 4a f3 ff ff       	call   8013af <fd2num>
  802065:	83 c4 10             	add    $0x10,%esp
}
  802068:	c9                   	leave  
  802069:	c3                   	ret    

0080206a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80206a:	55                   	push   %ebp
  80206b:	89 e5                	mov    %esp,%ebp
  80206d:	56                   	push   %esi
  80206e:	53                   	push   %ebx
  80206f:	8b 75 08             	mov    0x8(%ebp),%esi
  802072:	8b 45 0c             	mov    0xc(%ebp),%eax
  802075:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        //	panic("ipc_recv not implemented");
        int r;
       	if(pg!=NULL){
  802078:	85 c0                	test   %eax,%eax
  80207a:	74 3b                	je     8020b7 <ipc_recv+0x4d>
	  r = sys_ipc_recv(pg);
  80207c:	83 ec 0c             	sub    $0xc,%esp
  80207f:	50                   	push   %eax
  802080:	e8 5d f2 ff ff       	call   8012e2 <sys_ipc_recv>
  802085:	83 c4 10             	add    $0x10,%esp
	}else
	  r = sys_ipc_recv((void *)UTOP);
	if(r<0){
  802088:	85 c0                	test   %eax,%eax
  80208a:	78 3d                	js     8020c9 <ipc_recv+0x5f>
	if(perm_store!=NULL){
		*perm_store = 0;
            }
        	return r;
           }else{
	     if(from_env_store!=NULL)
  80208c:	85 f6                	test   %esi,%esi
  80208e:	74 0a                	je     80209a <ipc_recv+0x30>
		     *from_env_store = thisenv->env_ipc_from;
  802090:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802095:	8b 40 74             	mov    0x74(%eax),%eax
  802098:	89 06                	mov    %eax,(%esi)
	     if(perm_store != NULL)
  80209a:	85 db                	test   %ebx,%ebx
  80209c:	74 0a                	je     8020a8 <ipc_recv+0x3e>
		     *perm_store = thisenv->env_ipc_perm;
  80209e:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8020a3:	8b 40 78             	mov    0x78(%eax),%eax
  8020a6:	89 03                	mov    %eax,(%ebx)
	     return thisenv->env_ipc_value;
  8020a8:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8020ad:	8b 40 70             	mov    0x70(%eax),%eax
	   }

}
  8020b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020b3:	5b                   	pop    %ebx
  8020b4:	5e                   	pop    %esi
  8020b5:	5d                   	pop    %ebp
  8020b6:	c3                   	ret    
	  r = sys_ipc_recv((void *)UTOP);
  8020b7:	83 ec 0c             	sub    $0xc,%esp
  8020ba:	68 00 00 c0 ee       	push   $0xeec00000
  8020bf:	e8 1e f2 ff ff       	call   8012e2 <sys_ipc_recv>
  8020c4:	83 c4 10             	add    $0x10,%esp
  8020c7:	eb bf                	jmp    802088 <ipc_recv+0x1e>
	if(from_env_store!=NULL){
  8020c9:	85 f6                	test   %esi,%esi
  8020cb:	74 06                	je     8020d3 <ipc_recv+0x69>
	  *from_env_store = 0;
  8020cd:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(perm_store!=NULL){
  8020d3:	85 db                	test   %ebx,%ebx
  8020d5:	74 d9                	je     8020b0 <ipc_recv+0x46>
		*perm_store = 0;
  8020d7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8020dd:	eb d1                	jmp    8020b0 <ipc_recv+0x46>

008020df <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020df:	55                   	push   %ebp
  8020e0:	89 e5                	mov    %esp,%ebp
  8020e2:	57                   	push   %edi
  8020e3:	56                   	push   %esi
  8020e4:	53                   	push   %ebx
  8020e5:	83 ec 0c             	sub    $0xc,%esp
  8020e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020eb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if(pg==NULL) pg = (void *)UTOP;
  8020f1:	85 db                	test   %ebx,%ebx
  8020f3:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8020f8:	0f 44 d8             	cmove  %eax,%ebx
	while((r=sys_ipc_try_send(to_env,val,pg,perm))<0){
  8020fb:	ff 75 14             	pushl  0x14(%ebp)
  8020fe:	53                   	push   %ebx
  8020ff:	56                   	push   %esi
  802100:	57                   	push   %edi
  802101:	e8 b9 f1 ff ff       	call   8012bf <sys_ipc_try_send>
  802106:	83 c4 10             	add    $0x10,%esp
  802109:	85 c0                	test   %eax,%eax
  80210b:	79 20                	jns    80212d <ipc_send+0x4e>
	    if(r!=-E_IPC_NOT_RECV){
  80210d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802110:	75 07                	jne    802119 <ipc_send+0x3a>
		    panic("ipc_send:send message failed\n");
	    }
	    sys_yield();
  802112:	e8 fc ef ff ff       	call   801113 <sys_yield>
  802117:	eb e2                	jmp    8020fb <ipc_send+0x1c>
		    panic("ipc_send:send message failed\n");
  802119:	83 ec 04             	sub    $0x4,%esp
  80211c:	68 7e 29 80 00       	push   $0x80297e
  802121:	6a 43                	push   $0x43
  802123:	68 9c 29 80 00       	push   $0x80299c
  802128:	e8 12 e5 ff ff       	call   80063f <_panic>
	}

}
  80212d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802130:	5b                   	pop    %ebx
  802131:	5e                   	pop    %esi
  802132:	5f                   	pop    %edi
  802133:	5d                   	pop    %ebp
  802134:	c3                   	ret    

00802135 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802135:	55                   	push   %ebp
  802136:	89 e5                	mov    %esp,%ebp
  802138:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80213b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802140:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802143:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802149:	8b 52 50             	mov    0x50(%edx),%edx
  80214c:	39 ca                	cmp    %ecx,%edx
  80214e:	74 11                	je     802161 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  802150:	83 c0 01             	add    $0x1,%eax
  802153:	3d 00 04 00 00       	cmp    $0x400,%eax
  802158:	75 e6                	jne    802140 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80215a:	b8 00 00 00 00       	mov    $0x0,%eax
  80215f:	eb 0b                	jmp    80216c <ipc_find_env+0x37>
			return envs[i].env_id;
  802161:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802164:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802169:	8b 40 48             	mov    0x48(%eax),%eax
}
  80216c:	5d                   	pop    %ebp
  80216d:	c3                   	ret    

0080216e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80216e:	55                   	push   %ebp
  80216f:	89 e5                	mov    %esp,%ebp
  802171:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802174:	89 d0                	mov    %edx,%eax
  802176:	c1 e8 16             	shr    $0x16,%eax
  802179:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802180:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  802185:	f6 c1 01             	test   $0x1,%cl
  802188:	74 1d                	je     8021a7 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  80218a:	c1 ea 0c             	shr    $0xc,%edx
  80218d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802194:	f6 c2 01             	test   $0x1,%dl
  802197:	74 0e                	je     8021a7 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802199:	c1 ea 0c             	shr    $0xc,%edx
  80219c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021a3:	ef 
  8021a4:	0f b7 c0             	movzwl %ax,%eax
}
  8021a7:	5d                   	pop    %ebp
  8021a8:	c3                   	ret    
  8021a9:	66 90                	xchg   %ax,%ax
  8021ab:	66 90                	xchg   %ax,%ax
  8021ad:	66 90                	xchg   %ax,%ax
  8021af:	90                   	nop

008021b0 <__udivdi3>:
  8021b0:	55                   	push   %ebp
  8021b1:	57                   	push   %edi
  8021b2:	56                   	push   %esi
  8021b3:	53                   	push   %ebx
  8021b4:	83 ec 1c             	sub    $0x1c,%esp
  8021b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021bb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8021bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021c3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8021c7:	85 d2                	test   %edx,%edx
  8021c9:	75 35                	jne    802200 <__udivdi3+0x50>
  8021cb:	39 f3                	cmp    %esi,%ebx
  8021cd:	0f 87 bd 00 00 00    	ja     802290 <__udivdi3+0xe0>
  8021d3:	85 db                	test   %ebx,%ebx
  8021d5:	89 d9                	mov    %ebx,%ecx
  8021d7:	75 0b                	jne    8021e4 <__udivdi3+0x34>
  8021d9:	b8 01 00 00 00       	mov    $0x1,%eax
  8021de:	31 d2                	xor    %edx,%edx
  8021e0:	f7 f3                	div    %ebx
  8021e2:	89 c1                	mov    %eax,%ecx
  8021e4:	31 d2                	xor    %edx,%edx
  8021e6:	89 f0                	mov    %esi,%eax
  8021e8:	f7 f1                	div    %ecx
  8021ea:	89 c6                	mov    %eax,%esi
  8021ec:	89 e8                	mov    %ebp,%eax
  8021ee:	89 f7                	mov    %esi,%edi
  8021f0:	f7 f1                	div    %ecx
  8021f2:	89 fa                	mov    %edi,%edx
  8021f4:	83 c4 1c             	add    $0x1c,%esp
  8021f7:	5b                   	pop    %ebx
  8021f8:	5e                   	pop    %esi
  8021f9:	5f                   	pop    %edi
  8021fa:	5d                   	pop    %ebp
  8021fb:	c3                   	ret    
  8021fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802200:	39 f2                	cmp    %esi,%edx
  802202:	77 7c                	ja     802280 <__udivdi3+0xd0>
  802204:	0f bd fa             	bsr    %edx,%edi
  802207:	83 f7 1f             	xor    $0x1f,%edi
  80220a:	0f 84 98 00 00 00    	je     8022a8 <__udivdi3+0xf8>
  802210:	89 f9                	mov    %edi,%ecx
  802212:	b8 20 00 00 00       	mov    $0x20,%eax
  802217:	29 f8                	sub    %edi,%eax
  802219:	d3 e2                	shl    %cl,%edx
  80221b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80221f:	89 c1                	mov    %eax,%ecx
  802221:	89 da                	mov    %ebx,%edx
  802223:	d3 ea                	shr    %cl,%edx
  802225:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802229:	09 d1                	or     %edx,%ecx
  80222b:	89 f2                	mov    %esi,%edx
  80222d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802231:	89 f9                	mov    %edi,%ecx
  802233:	d3 e3                	shl    %cl,%ebx
  802235:	89 c1                	mov    %eax,%ecx
  802237:	d3 ea                	shr    %cl,%edx
  802239:	89 f9                	mov    %edi,%ecx
  80223b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80223f:	d3 e6                	shl    %cl,%esi
  802241:	89 eb                	mov    %ebp,%ebx
  802243:	89 c1                	mov    %eax,%ecx
  802245:	d3 eb                	shr    %cl,%ebx
  802247:	09 de                	or     %ebx,%esi
  802249:	89 f0                	mov    %esi,%eax
  80224b:	f7 74 24 08          	divl   0x8(%esp)
  80224f:	89 d6                	mov    %edx,%esi
  802251:	89 c3                	mov    %eax,%ebx
  802253:	f7 64 24 0c          	mull   0xc(%esp)
  802257:	39 d6                	cmp    %edx,%esi
  802259:	72 0c                	jb     802267 <__udivdi3+0xb7>
  80225b:	89 f9                	mov    %edi,%ecx
  80225d:	d3 e5                	shl    %cl,%ebp
  80225f:	39 c5                	cmp    %eax,%ebp
  802261:	73 5d                	jae    8022c0 <__udivdi3+0x110>
  802263:	39 d6                	cmp    %edx,%esi
  802265:	75 59                	jne    8022c0 <__udivdi3+0x110>
  802267:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80226a:	31 ff                	xor    %edi,%edi
  80226c:	89 fa                	mov    %edi,%edx
  80226e:	83 c4 1c             	add    $0x1c,%esp
  802271:	5b                   	pop    %ebx
  802272:	5e                   	pop    %esi
  802273:	5f                   	pop    %edi
  802274:	5d                   	pop    %ebp
  802275:	c3                   	ret    
  802276:	8d 76 00             	lea    0x0(%esi),%esi
  802279:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802280:	31 ff                	xor    %edi,%edi
  802282:	31 c0                	xor    %eax,%eax
  802284:	89 fa                	mov    %edi,%edx
  802286:	83 c4 1c             	add    $0x1c,%esp
  802289:	5b                   	pop    %ebx
  80228a:	5e                   	pop    %esi
  80228b:	5f                   	pop    %edi
  80228c:	5d                   	pop    %ebp
  80228d:	c3                   	ret    
  80228e:	66 90                	xchg   %ax,%ax
  802290:	31 ff                	xor    %edi,%edi
  802292:	89 e8                	mov    %ebp,%eax
  802294:	89 f2                	mov    %esi,%edx
  802296:	f7 f3                	div    %ebx
  802298:	89 fa                	mov    %edi,%edx
  80229a:	83 c4 1c             	add    $0x1c,%esp
  80229d:	5b                   	pop    %ebx
  80229e:	5e                   	pop    %esi
  80229f:	5f                   	pop    %edi
  8022a0:	5d                   	pop    %ebp
  8022a1:	c3                   	ret    
  8022a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022a8:	39 f2                	cmp    %esi,%edx
  8022aa:	72 06                	jb     8022b2 <__udivdi3+0x102>
  8022ac:	31 c0                	xor    %eax,%eax
  8022ae:	39 eb                	cmp    %ebp,%ebx
  8022b0:	77 d2                	ja     802284 <__udivdi3+0xd4>
  8022b2:	b8 01 00 00 00       	mov    $0x1,%eax
  8022b7:	eb cb                	jmp    802284 <__udivdi3+0xd4>
  8022b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	89 d8                	mov    %ebx,%eax
  8022c2:	31 ff                	xor    %edi,%edi
  8022c4:	eb be                	jmp    802284 <__udivdi3+0xd4>
  8022c6:	66 90                	xchg   %ax,%ax
  8022c8:	66 90                	xchg   %ax,%ax
  8022ca:	66 90                	xchg   %ax,%ax
  8022cc:	66 90                	xchg   %ax,%ax
  8022ce:	66 90                	xchg   %ax,%ax

008022d0 <__umoddi3>:
  8022d0:	55                   	push   %ebp
  8022d1:	57                   	push   %edi
  8022d2:	56                   	push   %esi
  8022d3:	53                   	push   %ebx
  8022d4:	83 ec 1c             	sub    $0x1c,%esp
  8022d7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8022db:	8b 74 24 30          	mov    0x30(%esp),%esi
  8022df:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8022e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022e7:	85 ed                	test   %ebp,%ebp
  8022e9:	89 f0                	mov    %esi,%eax
  8022eb:	89 da                	mov    %ebx,%edx
  8022ed:	75 19                	jne    802308 <__umoddi3+0x38>
  8022ef:	39 df                	cmp    %ebx,%edi
  8022f1:	0f 86 b1 00 00 00    	jbe    8023a8 <__umoddi3+0xd8>
  8022f7:	f7 f7                	div    %edi
  8022f9:	89 d0                	mov    %edx,%eax
  8022fb:	31 d2                	xor    %edx,%edx
  8022fd:	83 c4 1c             	add    $0x1c,%esp
  802300:	5b                   	pop    %ebx
  802301:	5e                   	pop    %esi
  802302:	5f                   	pop    %edi
  802303:	5d                   	pop    %ebp
  802304:	c3                   	ret    
  802305:	8d 76 00             	lea    0x0(%esi),%esi
  802308:	39 dd                	cmp    %ebx,%ebp
  80230a:	77 f1                	ja     8022fd <__umoddi3+0x2d>
  80230c:	0f bd cd             	bsr    %ebp,%ecx
  80230f:	83 f1 1f             	xor    $0x1f,%ecx
  802312:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802316:	0f 84 b4 00 00 00    	je     8023d0 <__umoddi3+0x100>
  80231c:	b8 20 00 00 00       	mov    $0x20,%eax
  802321:	89 c2                	mov    %eax,%edx
  802323:	8b 44 24 04          	mov    0x4(%esp),%eax
  802327:	29 c2                	sub    %eax,%edx
  802329:	89 c1                	mov    %eax,%ecx
  80232b:	89 f8                	mov    %edi,%eax
  80232d:	d3 e5                	shl    %cl,%ebp
  80232f:	89 d1                	mov    %edx,%ecx
  802331:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802335:	d3 e8                	shr    %cl,%eax
  802337:	09 c5                	or     %eax,%ebp
  802339:	8b 44 24 04          	mov    0x4(%esp),%eax
  80233d:	89 c1                	mov    %eax,%ecx
  80233f:	d3 e7                	shl    %cl,%edi
  802341:	89 d1                	mov    %edx,%ecx
  802343:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802347:	89 df                	mov    %ebx,%edi
  802349:	d3 ef                	shr    %cl,%edi
  80234b:	89 c1                	mov    %eax,%ecx
  80234d:	89 f0                	mov    %esi,%eax
  80234f:	d3 e3                	shl    %cl,%ebx
  802351:	89 d1                	mov    %edx,%ecx
  802353:	89 fa                	mov    %edi,%edx
  802355:	d3 e8                	shr    %cl,%eax
  802357:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80235c:	09 d8                	or     %ebx,%eax
  80235e:	f7 f5                	div    %ebp
  802360:	d3 e6                	shl    %cl,%esi
  802362:	89 d1                	mov    %edx,%ecx
  802364:	f7 64 24 08          	mull   0x8(%esp)
  802368:	39 d1                	cmp    %edx,%ecx
  80236a:	89 c3                	mov    %eax,%ebx
  80236c:	89 d7                	mov    %edx,%edi
  80236e:	72 06                	jb     802376 <__umoddi3+0xa6>
  802370:	75 0e                	jne    802380 <__umoddi3+0xb0>
  802372:	39 c6                	cmp    %eax,%esi
  802374:	73 0a                	jae    802380 <__umoddi3+0xb0>
  802376:	2b 44 24 08          	sub    0x8(%esp),%eax
  80237a:	19 ea                	sbb    %ebp,%edx
  80237c:	89 d7                	mov    %edx,%edi
  80237e:	89 c3                	mov    %eax,%ebx
  802380:	89 ca                	mov    %ecx,%edx
  802382:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802387:	29 de                	sub    %ebx,%esi
  802389:	19 fa                	sbb    %edi,%edx
  80238b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80238f:	89 d0                	mov    %edx,%eax
  802391:	d3 e0                	shl    %cl,%eax
  802393:	89 d9                	mov    %ebx,%ecx
  802395:	d3 ee                	shr    %cl,%esi
  802397:	d3 ea                	shr    %cl,%edx
  802399:	09 f0                	or     %esi,%eax
  80239b:	83 c4 1c             	add    $0x1c,%esp
  80239e:	5b                   	pop    %ebx
  80239f:	5e                   	pop    %esi
  8023a0:	5f                   	pop    %edi
  8023a1:	5d                   	pop    %ebp
  8023a2:	c3                   	ret    
  8023a3:	90                   	nop
  8023a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023a8:	85 ff                	test   %edi,%edi
  8023aa:	89 f9                	mov    %edi,%ecx
  8023ac:	75 0b                	jne    8023b9 <__umoddi3+0xe9>
  8023ae:	b8 01 00 00 00       	mov    $0x1,%eax
  8023b3:	31 d2                	xor    %edx,%edx
  8023b5:	f7 f7                	div    %edi
  8023b7:	89 c1                	mov    %eax,%ecx
  8023b9:	89 d8                	mov    %ebx,%eax
  8023bb:	31 d2                	xor    %edx,%edx
  8023bd:	f7 f1                	div    %ecx
  8023bf:	89 f0                	mov    %esi,%eax
  8023c1:	f7 f1                	div    %ecx
  8023c3:	e9 31 ff ff ff       	jmp    8022f9 <__umoddi3+0x29>
  8023c8:	90                   	nop
  8023c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023d0:	39 dd                	cmp    %ebx,%ebp
  8023d2:	72 08                	jb     8023dc <__umoddi3+0x10c>
  8023d4:	39 f7                	cmp    %esi,%edi
  8023d6:	0f 87 21 ff ff ff    	ja     8022fd <__umoddi3+0x2d>
  8023dc:	89 da                	mov    %ebx,%edx
  8023de:	89 f0                	mov    %esi,%eax
  8023e0:	29 f8                	sub    %edi,%eax
  8023e2:	19 ea                	sbb    %ebp,%edx
  8023e4:	e9 14 ff ff ff       	jmp    8022fd <__umoddi3+0x2d>
