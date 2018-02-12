
obj/user/buggyhello:     file format elf32-i386


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
  80003d:	e8 60 00 00 00       	call   8000a2 <sys_cputs>
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
    thisenv = envs + ENVX(sys_getenvid());
  800052:	e8 c9 00 00 00       	call   800120 <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80005f:	c1 e0 05             	shl    $0x5,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 04 10 80 00       	mov    %eax,0x801004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x30>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 10 80 00       	mov    %eax,0x801000

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
  800093:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800096:	6a 00                	push   $0x0
  800098:	e8 42 00 00 00       	call   8000df <sys_env_destroy>
}
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	57                   	push   %edi
  8000a6:	56                   	push   %esi
  8000a7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b3:	89 c3                	mov    %eax,%ebx
  8000b5:	89 c7                	mov    %eax,%edi
  8000b7:	89 c6                	mov    %eax,%esi
  8000b9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    

008000c0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d0:	89 d1                	mov    %edx,%ecx
  8000d2:	89 d3                	mov    %edx,%ebx
  8000d4:	89 d7                	mov    %edx,%edi
  8000d6:	89 d6                	mov    %edx,%esi
  8000d8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	57                   	push   %edi
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ed:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f5:	89 cb                	mov    %ecx,%ebx
  8000f7:	89 cf                	mov    %ecx,%edi
  8000f9:	89 ce                	mov    %ecx,%esi
  8000fb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000fd:	85 c0                	test   %eax,%eax
  8000ff:	7e 17                	jle    800118 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800101:	83 ec 0c             	sub    $0xc,%esp
  800104:	50                   	push   %eax
  800105:	6a 03                	push   $0x3
  800107:	68 7e 0d 80 00       	push   $0x800d7e
  80010c:	6a 23                	push   $0x23
  80010e:	68 9b 0d 80 00       	push   $0x800d9b
  800113:	e8 27 00 00 00       	call   80013f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800118:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011b:	5b                   	pop    %ebx
  80011c:	5e                   	pop    %esi
  80011d:	5f                   	pop    %edi
  80011e:	5d                   	pop    %ebp
  80011f:	c3                   	ret    

00800120 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	57                   	push   %edi
  800124:	56                   	push   %esi
  800125:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800126:	ba 00 00 00 00       	mov    $0x0,%edx
  80012b:	b8 02 00 00 00       	mov    $0x2,%eax
  800130:	89 d1                	mov    %edx,%ecx
  800132:	89 d3                	mov    %edx,%ebx
  800134:	89 d7                	mov    %edx,%edi
  800136:	89 d6                	mov    %edx,%esi
  800138:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5f                   	pop    %edi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	56                   	push   %esi
  800143:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800144:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800147:	8b 35 00 10 80 00    	mov    0x801000,%esi
  80014d:	e8 ce ff ff ff       	call   800120 <sys_getenvid>
  800152:	83 ec 0c             	sub    $0xc,%esp
  800155:	ff 75 0c             	pushl  0xc(%ebp)
  800158:	ff 75 08             	pushl  0x8(%ebp)
  80015b:	56                   	push   %esi
  80015c:	50                   	push   %eax
  80015d:	68 ac 0d 80 00       	push   $0x800dac
  800162:	e8 b1 00 00 00       	call   800218 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800167:	83 c4 18             	add    $0x18,%esp
  80016a:	53                   	push   %ebx
  80016b:	ff 75 10             	pushl  0x10(%ebp)
  80016e:	e8 54 00 00 00       	call   8001c7 <vcprintf>
	cprintf("\n");
  800173:	c7 04 24 d0 0d 80 00 	movl   $0x800dd0,(%esp)
  80017a:	e8 99 00 00 00       	call   800218 <cprintf>
  80017f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800182:	cc                   	int3   
  800183:	eb fd                	jmp    800182 <_panic+0x43>

00800185 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	53                   	push   %ebx
  800189:	83 ec 04             	sub    $0x4,%esp
  80018c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018f:	8b 13                	mov    (%ebx),%edx
  800191:	8d 42 01             	lea    0x1(%edx),%eax
  800194:	89 03                	mov    %eax,(%ebx)
  800196:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800199:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80019d:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a2:	75 1a                	jne    8001be <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001a4:	83 ec 08             	sub    $0x8,%esp
  8001a7:	68 ff 00 00 00       	push   $0xff
  8001ac:	8d 43 08             	lea    0x8(%ebx),%eax
  8001af:	50                   	push   %eax
  8001b0:	e8 ed fe ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  8001b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001bb:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001be:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c5:	c9                   	leave  
  8001c6:	c3                   	ret    

008001c7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c7:	55                   	push   %ebp
  8001c8:	89 e5                	mov    %esp,%ebp
  8001ca:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d7:	00 00 00 
	b.cnt = 0;
  8001da:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e4:	ff 75 0c             	pushl  0xc(%ebp)
  8001e7:	ff 75 08             	pushl  0x8(%ebp)
  8001ea:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f0:	50                   	push   %eax
  8001f1:	68 85 01 80 00       	push   $0x800185
  8001f6:	e8 54 01 00 00       	call   80034f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001fb:	83 c4 08             	add    $0x8,%esp
  8001fe:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800204:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80020a:	50                   	push   %eax
  80020b:	e8 92 fe ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  800210:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800216:	c9                   	leave  
  800217:	c3                   	ret    

00800218 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800221:	50                   	push   %eax
  800222:	ff 75 08             	pushl  0x8(%ebp)
  800225:	e8 9d ff ff ff       	call   8001c7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80022a:	c9                   	leave  
  80022b:	c3                   	ret    

0080022c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	57                   	push   %edi
  800230:	56                   	push   %esi
  800231:	53                   	push   %ebx
  800232:	83 ec 1c             	sub    $0x1c,%esp
  800235:	89 c7                	mov    %eax,%edi
  800237:	89 d6                	mov    %edx,%esi
  800239:	8b 45 08             	mov    0x8(%ebp),%eax
  80023c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800242:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800245:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800248:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800250:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800253:	39 d3                	cmp    %edx,%ebx
  800255:	72 05                	jb     80025c <printnum+0x30>
  800257:	39 45 10             	cmp    %eax,0x10(%ebp)
  80025a:	77 45                	ja     8002a1 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80025c:	83 ec 0c             	sub    $0xc,%esp
  80025f:	ff 75 18             	pushl  0x18(%ebp)
  800262:	8b 45 14             	mov    0x14(%ebp),%eax
  800265:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800268:	53                   	push   %ebx
  800269:	ff 75 10             	pushl  0x10(%ebp)
  80026c:	83 ec 08             	sub    $0x8,%esp
  80026f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800272:	ff 75 e0             	pushl  -0x20(%ebp)
  800275:	ff 75 dc             	pushl  -0x24(%ebp)
  800278:	ff 75 d8             	pushl  -0x28(%ebp)
  80027b:	e8 70 08 00 00       	call   800af0 <__udivdi3>
  800280:	83 c4 18             	add    $0x18,%esp
  800283:	52                   	push   %edx
  800284:	50                   	push   %eax
  800285:	89 f2                	mov    %esi,%edx
  800287:	89 f8                	mov    %edi,%eax
  800289:	e8 9e ff ff ff       	call   80022c <printnum>
  80028e:	83 c4 20             	add    $0x20,%esp
  800291:	eb 18                	jmp    8002ab <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800293:	83 ec 08             	sub    $0x8,%esp
  800296:	56                   	push   %esi
  800297:	ff 75 18             	pushl  0x18(%ebp)
  80029a:	ff d7                	call   *%edi
  80029c:	83 c4 10             	add    $0x10,%esp
  80029f:	eb 03                	jmp    8002a4 <printnum+0x78>
  8002a1:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a4:	83 eb 01             	sub    $0x1,%ebx
  8002a7:	85 db                	test   %ebx,%ebx
  8002a9:	7f e8                	jg     800293 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ab:	83 ec 08             	sub    $0x8,%esp
  8002ae:	56                   	push   %esi
  8002af:	83 ec 04             	sub    $0x4,%esp
  8002b2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b5:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b8:	ff 75 dc             	pushl  -0x24(%ebp)
  8002bb:	ff 75 d8             	pushl  -0x28(%ebp)
  8002be:	e8 5d 09 00 00       	call   800c20 <__umoddi3>
  8002c3:	83 c4 14             	add    $0x14,%esp
  8002c6:	0f be 80 d2 0d 80 00 	movsbl 0x800dd2(%eax),%eax
  8002cd:	50                   	push   %eax
  8002ce:	ff d7                	call   *%edi
}
  8002d0:	83 c4 10             	add    $0x10,%esp
  8002d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d6:	5b                   	pop    %ebx
  8002d7:	5e                   	pop    %esi
  8002d8:	5f                   	pop    %edi
  8002d9:	5d                   	pop    %ebp
  8002da:	c3                   	ret    

008002db <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002db:	55                   	push   %ebp
  8002dc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002de:	83 fa 01             	cmp    $0x1,%edx
  8002e1:	7e 0e                	jle    8002f1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002e3:	8b 10                	mov    (%eax),%edx
  8002e5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e8:	89 08                	mov    %ecx,(%eax)
  8002ea:	8b 02                	mov    (%edx),%eax
  8002ec:	8b 52 04             	mov    0x4(%edx),%edx
  8002ef:	eb 22                	jmp    800313 <getuint+0x38>
	else if (lflag)
  8002f1:	85 d2                	test   %edx,%edx
  8002f3:	74 10                	je     800305 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002f5:	8b 10                	mov    (%eax),%edx
  8002f7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002fa:	89 08                	mov    %ecx,(%eax)
  8002fc:	8b 02                	mov    (%edx),%eax
  8002fe:	ba 00 00 00 00       	mov    $0x0,%edx
  800303:	eb 0e                	jmp    800313 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800305:	8b 10                	mov    (%eax),%edx
  800307:	8d 4a 04             	lea    0x4(%edx),%ecx
  80030a:	89 08                	mov    %ecx,(%eax)
  80030c:	8b 02                	mov    (%edx),%eax
  80030e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800313:	5d                   	pop    %ebp
  800314:	c3                   	ret    

00800315 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800315:	55                   	push   %ebp
  800316:	89 e5                	mov    %esp,%ebp
  800318:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80031b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80031f:	8b 10                	mov    (%eax),%edx
  800321:	3b 50 04             	cmp    0x4(%eax),%edx
  800324:	73 0a                	jae    800330 <sprintputch+0x1b>
		*b->buf++ = ch;
  800326:	8d 4a 01             	lea    0x1(%edx),%ecx
  800329:	89 08                	mov    %ecx,(%eax)
  80032b:	8b 45 08             	mov    0x8(%ebp),%eax
  80032e:	88 02                	mov    %al,(%edx)
}
  800330:	5d                   	pop    %ebp
  800331:	c3                   	ret    

00800332 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
  800335:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800338:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80033b:	50                   	push   %eax
  80033c:	ff 75 10             	pushl  0x10(%ebp)
  80033f:	ff 75 0c             	pushl  0xc(%ebp)
  800342:	ff 75 08             	pushl  0x8(%ebp)
  800345:	e8 05 00 00 00       	call   80034f <vprintfmt>
	va_end(ap);
}
  80034a:	83 c4 10             	add    $0x10,%esp
  80034d:	c9                   	leave  
  80034e:	c3                   	ret    

0080034f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
  800352:	57                   	push   %edi
  800353:	56                   	push   %esi
  800354:	53                   	push   %ebx
  800355:	83 ec 2c             	sub    $0x2c,%esp
  800358:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
    int color = 0;
  80035b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800362:	eb 17                	jmp    80037b <vprintfmt+0x2c>
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800364:	85 c0                	test   %eax,%eax
  800366:	0f 84 89 03 00 00    	je     8006f5 <vprintfmt+0x3a6>
				return;
			putch(ch, putdat);
  80036c:	83 ec 08             	sub    $0x8,%esp
  80036f:	ff 75 0c             	pushl  0xc(%ebp)
  800372:	50                   	push   %eax
  800373:	ff 55 08             	call   *0x8(%ebp)
  800376:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
    int color = 0;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800379:	89 f3                	mov    %esi,%ebx
  80037b:	8d 73 01             	lea    0x1(%ebx),%esi
  80037e:	0f b6 03             	movzbl (%ebx),%eax
  800381:	83 f8 25             	cmp    $0x25,%eax
  800384:	75 de                	jne    800364 <vprintfmt+0x15>
  800386:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80038a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800391:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800396:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80039d:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a2:	eb 0d                	jmp    8003b1 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a4:	89 de                	mov    %ebx,%esi
  8003a6:	eb 09                	jmp    8003b1 <vprintfmt+0x62>
  8003a8:	89 de                	mov    %ebx,%esi
			break;
        case 'C': 
        //自己补充的控制颜色的代码
            switch(va_arg(ap,int)){
                case 0:
                    color = 0x0c00;
  8003aa:	c7 45 d8 00 0c 00 00 	movl   $0xc00,-0x28(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003b4:	0f b6 06             	movzbl (%esi),%eax
  8003b7:	0f b6 c8             	movzbl %al,%ecx
  8003ba:	83 e8 23             	sub    $0x23,%eax
  8003bd:	3c 55                	cmp    $0x55,%al
  8003bf:	0f 87 10 03 00 00    	ja     8006d5 <vprintfmt+0x386>
  8003c5:	0f b6 c0             	movzbl %al,%eax
  8003c8:	ff 24 85 60 0e 80 00 	jmp    *0x800e60(,%eax,4)
  8003cf:	89 de                	mov    %ebx,%esi
		case '-':
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003d1:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003d5:	eb da                	jmp    8003b1 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d7:	89 de                	mov    %ebx,%esi
  8003d9:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003de:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  8003e1:	8d 7c 41 d0          	lea    -0x30(%ecx,%eax,2),%edi
				ch = *fmt;
  8003e5:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
  8003e8:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8003eb:	83 f8 09             	cmp    $0x9,%eax
  8003ee:	77 33                	ja     800423 <vprintfmt+0xd4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003f0:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003f3:	eb e9                	jmp    8003de <vprintfmt+0x8f>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f8:	8d 48 04             	lea    0x4(%eax),%ecx
  8003fb:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003fe:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800400:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800402:	eb 1f                	jmp    800423 <vprintfmt+0xd4>
  800404:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800407:	85 c0                	test   %eax,%eax
  800409:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040e:	0f 49 c8             	cmovns %eax,%ecx
  800411:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	89 de                	mov    %ebx,%esi
  800416:	eb 99                	jmp    8003b1 <vprintfmt+0x62>
  800418:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80041a:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
  800421:	eb 8e                	jmp    8003b1 <vprintfmt+0x62>

		process_precision:
			if (width < 0)
  800423:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800427:	79 88                	jns    8003b1 <vprintfmt+0x62>
				width = precision, precision = -1;
  800429:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80042c:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800431:	e9 7b ff ff ff       	jmp    8003b1 <vprintfmt+0x62>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800436:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800439:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80043b:	e9 71 ff ff ff       	jmp    8003b1 <vprintfmt+0x62>

		case 'c':
            ch = va_arg(ap,int)+color;
  800440:	8b 45 14             	mov    0x14(%ebp),%eax
  800443:	8d 50 04             	lea    0x4(%eax),%edx
  800446:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
  800449:	83 ec 08             	sub    $0x8,%esp
  80044c:	ff 75 0c             	pushl  0xc(%ebp)
  80044f:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800452:	03 08                	add    (%eax),%ecx
  800454:	51                   	push   %ecx
  800455:	ff 55 08             	call   *0x8(%ebp)
            color = 0;
			break;
  800458:	83 c4 10             	add    $0x10,%esp
			goto reswitch;

		case 'c':
            ch = va_arg(ap,int)+color;
			putch(ch, putdat);
            color = 0;
  80045b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
			break;
  800462:	e9 14 ff ff ff       	jmp    80037b <vprintfmt+0x2c>
        case 'C': 
        //自己补充的控制颜色的代码
            switch(va_arg(ap,int)){
  800467:	8b 45 14             	mov    0x14(%ebp),%eax
  80046a:	8d 48 04             	lea    0x4(%eax),%ecx
  80046d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800470:	8b 00                	mov    (%eax),%eax
  800472:	85 c0                	test   %eax,%eax
  800474:	0f 84 2e ff ff ff    	je     8003a8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	89 de                	mov    %ebx,%esi
  80047c:	83 f8 01             	cmp    $0x1,%eax
  80047f:	b8 00 00 00 00       	mov    $0x0,%eax
  800484:	b9 00 0a 00 00       	mov    $0xa00,%ecx
  800489:	0f 44 c1             	cmove  %ecx,%eax
  80048c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80048f:	e9 1d ff ff ff       	jmp    8003b1 <vprintfmt+0x62>
            }

            goto reswitch;
		// error message
		case 'e':
			err = va_arg(ap, int);
  800494:	8b 45 14             	mov    0x14(%ebp),%eax
  800497:	8d 50 04             	lea    0x4(%eax),%edx
  80049a:	89 55 14             	mov    %edx,0x14(%ebp)
  80049d:	8b 00                	mov    (%eax),%eax
  80049f:	99                   	cltd   
  8004a0:	31 d0                	xor    %edx,%eax
  8004a2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a4:	83 f8 06             	cmp    $0x6,%eax
  8004a7:	7f 0b                	jg     8004b4 <vprintfmt+0x165>
  8004a9:	8b 14 85 b8 0f 80 00 	mov    0x800fb8(,%eax,4),%edx
  8004b0:	85 d2                	test   %edx,%edx
  8004b2:	75 19                	jne    8004cd <vprintfmt+0x17e>
				printfmt(putch, putdat, "error %d", err);
  8004b4:	50                   	push   %eax
  8004b5:	68 ea 0d 80 00       	push   $0x800dea
  8004ba:	ff 75 0c             	pushl  0xc(%ebp)
  8004bd:	ff 75 08             	pushl  0x8(%ebp)
  8004c0:	e8 6d fe ff ff       	call   800332 <printfmt>
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	e9 ae fe ff ff       	jmp    80037b <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
  8004cd:	52                   	push   %edx
  8004ce:	68 f3 0d 80 00       	push   $0x800df3
  8004d3:	ff 75 0c             	pushl  0xc(%ebp)
  8004d6:	ff 75 08             	pushl  0x8(%ebp)
  8004d9:	e8 54 fe ff ff       	call   800332 <printfmt>
  8004de:	83 c4 10             	add    $0x10,%esp
  8004e1:	e9 95 fe ff ff       	jmp    80037b <vprintfmt+0x2c>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e9:	8d 50 04             	lea    0x4(%eax),%edx
  8004ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ef:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8004f1:	85 f6                	test   %esi,%esi
  8004f3:	b8 e3 0d 80 00       	mov    $0x800de3,%eax
  8004f8:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8004fb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ff:	0f 8e 89 00 00 00    	jle    80058e <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800505:	83 ec 08             	sub    $0x8,%esp
  800508:	57                   	push   %edi
  800509:	56                   	push   %esi
  80050a:	e8 6e 02 00 00       	call   80077d <strnlen>
  80050f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800512:	29 c1                	sub    %eax,%ecx
  800514:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800517:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80051a:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  80051e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800521:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800524:	8b 75 0c             	mov    0xc(%ebp),%esi
  800527:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80052a:	89 cb                	mov    %ecx,%ebx
  80052c:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80052e:	eb 0e                	jmp    80053e <vprintfmt+0x1ef>
					putch(padc, putdat);
  800530:	83 ec 08             	sub    $0x8,%esp
  800533:	56                   	push   %esi
  800534:	57                   	push   %edi
  800535:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800538:	83 eb 01             	sub    $0x1,%ebx
  80053b:	83 c4 10             	add    $0x10,%esp
  80053e:	85 db                	test   %ebx,%ebx
  800540:	7f ee                	jg     800530 <vprintfmt+0x1e1>
  800542:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800545:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800548:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80054b:	85 c9                	test   %ecx,%ecx
  80054d:	b8 00 00 00 00       	mov    $0x0,%eax
  800552:	0f 49 c1             	cmovns %ecx,%eax
  800555:	29 c1                	sub    %eax,%ecx
  800557:	89 cb                	mov    %ecx,%ebx
  800559:	eb 39                	jmp    800594 <vprintfmt+0x245>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80055b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80055f:	74 1b                	je     80057c <vprintfmt+0x22d>
  800561:	0f be c0             	movsbl %al,%eax
  800564:	83 e8 20             	sub    $0x20,%eax
  800567:	83 f8 5e             	cmp    $0x5e,%eax
  80056a:	76 10                	jbe    80057c <vprintfmt+0x22d>
					putch('?', putdat);
  80056c:	83 ec 08             	sub    $0x8,%esp
  80056f:	ff 75 0c             	pushl  0xc(%ebp)
  800572:	6a 3f                	push   $0x3f
  800574:	ff 55 08             	call   *0x8(%ebp)
  800577:	83 c4 10             	add    $0x10,%esp
  80057a:	eb 0d                	jmp    800589 <vprintfmt+0x23a>
				else
					putch(ch, putdat);
  80057c:	83 ec 08             	sub    $0x8,%esp
  80057f:	ff 75 0c             	pushl  0xc(%ebp)
  800582:	52                   	push   %edx
  800583:	ff 55 08             	call   *0x8(%ebp)
  800586:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800589:	83 eb 01             	sub    $0x1,%ebx
  80058c:	eb 06                	jmp    800594 <vprintfmt+0x245>
  80058e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800591:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800594:	83 c6 01             	add    $0x1,%esi
  800597:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80059b:	0f be d0             	movsbl %al,%edx
  80059e:	85 d2                	test   %edx,%edx
  8005a0:	74 25                	je     8005c7 <vprintfmt+0x278>
  8005a2:	85 ff                	test   %edi,%edi
  8005a4:	78 b5                	js     80055b <vprintfmt+0x20c>
  8005a6:	83 ef 01             	sub    $0x1,%edi
  8005a9:	79 b0                	jns    80055b <vprintfmt+0x20c>
  8005ab:	89 d8                	mov    %ebx,%eax
  8005ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b0:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005b3:	89 c3                	mov    %eax,%ebx
  8005b5:	eb 16                	jmp    8005cd <vprintfmt+0x27e>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005b7:	83 ec 08             	sub    $0x8,%esp
  8005ba:	57                   	push   %edi
  8005bb:	6a 20                	push   $0x20
  8005bd:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005bf:	83 eb 01             	sub    $0x1,%ebx
  8005c2:	83 c4 10             	add    $0x10,%esp
  8005c5:	eb 06                	jmp    8005cd <vprintfmt+0x27e>
  8005c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ca:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005cd:	85 db                	test   %ebx,%ebx
  8005cf:	7f e6                	jg     8005b7 <vprintfmt+0x268>
  8005d1:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d4:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005da:	e9 9c fd ff ff       	jmp    80037b <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005df:	83 fa 01             	cmp    $0x1,%edx
  8005e2:	7e 10                	jle    8005f4 <vprintfmt+0x2a5>
		return va_arg(*ap, long long);
  8005e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e7:	8d 50 08             	lea    0x8(%eax),%edx
  8005ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ed:	8b 30                	mov    (%eax),%esi
  8005ef:	8b 78 04             	mov    0x4(%eax),%edi
  8005f2:	eb 26                	jmp    80061a <vprintfmt+0x2cb>
	else if (lflag)
  8005f4:	85 d2                	test   %edx,%edx
  8005f6:	74 12                	je     80060a <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8d 50 04             	lea    0x4(%eax),%edx
  8005fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800601:	8b 30                	mov    (%eax),%esi
  800603:	89 f7                	mov    %esi,%edi
  800605:	c1 ff 1f             	sar    $0x1f,%edi
  800608:	eb 10                	jmp    80061a <vprintfmt+0x2cb>
	else
		return va_arg(*ap, int);
  80060a:	8b 45 14             	mov    0x14(%ebp),%eax
  80060d:	8d 50 04             	lea    0x4(%eax),%edx
  800610:	89 55 14             	mov    %edx,0x14(%ebp)
  800613:	8b 30                	mov    (%eax),%esi
  800615:	89 f7                	mov    %esi,%edi
  800617:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80061a:	89 f0                	mov    %esi,%eax
  80061c:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80061e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800623:	85 ff                	test   %edi,%edi
  800625:	79 7b                	jns    8006a2 <vprintfmt+0x353>
				putch('-', putdat);
  800627:	83 ec 08             	sub    $0x8,%esp
  80062a:	ff 75 0c             	pushl  0xc(%ebp)
  80062d:	6a 2d                	push   $0x2d
  80062f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800632:	89 f0                	mov    %esi,%eax
  800634:	89 fa                	mov    %edi,%edx
  800636:	f7 d8                	neg    %eax
  800638:	83 d2 00             	adc    $0x0,%edx
  80063b:	f7 da                	neg    %edx
  80063d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800640:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800645:	eb 5b                	jmp    8006a2 <vprintfmt+0x353>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800647:	8d 45 14             	lea    0x14(%ebp),%eax
  80064a:	e8 8c fc ff ff       	call   8002db <getuint>
			base = 10;
  80064f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800654:	eb 4c                	jmp    8006a2 <vprintfmt+0x353>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800656:	8d 45 14             	lea    0x14(%ebp),%eax
  800659:	e8 7d fc ff ff       	call   8002db <getuint>
			base = 8;
  80065e:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  800663:	eb 3d                	jmp    8006a2 <vprintfmt+0x353>
		// pointer
		case 'p':
			putch('0', putdat);
  800665:	83 ec 08             	sub    $0x8,%esp
  800668:	ff 75 0c             	pushl  0xc(%ebp)
  80066b:	6a 30                	push   $0x30
  80066d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800670:	83 c4 08             	add    $0x8,%esp
  800673:	ff 75 0c             	pushl  0xc(%ebp)
  800676:	6a 78                	push   $0x78
  800678:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80067b:	8b 45 14             	mov    0x14(%ebp),%eax
  80067e:	8d 50 04             	lea    0x4(%eax),%edx
  800681:	89 55 14             	mov    %edx,0x14(%ebp)
            goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800684:	8b 00                	mov    (%eax),%eax
  800686:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80068b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80068e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800693:	eb 0d                	jmp    8006a2 <vprintfmt+0x353>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800695:	8d 45 14             	lea    0x14(%ebp),%eax
  800698:	e8 3e fc ff ff       	call   8002db <getuint>
			base = 16;
  80069d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a2:	83 ec 0c             	sub    $0xc,%esp
  8006a5:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
  8006a9:	56                   	push   %esi
  8006aa:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ad:	51                   	push   %ecx
  8006ae:	52                   	push   %edx
  8006af:	50                   	push   %eax
  8006b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b6:	e8 71 fb ff ff       	call   80022c <printnum>
			break;
  8006bb:	83 c4 20             	add    $0x20,%esp
  8006be:	e9 b8 fc ff ff       	jmp    80037b <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c3:	83 ec 08             	sub    $0x8,%esp
  8006c6:	ff 75 0c             	pushl  0xc(%ebp)
  8006c9:	51                   	push   %ecx
  8006ca:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006cd:	83 c4 10             	add    $0x10,%esp
  8006d0:	e9 a6 fc ff ff       	jmp    80037b <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d5:	83 ec 08             	sub    $0x8,%esp
  8006d8:	ff 75 0c             	pushl  0xc(%ebp)
  8006db:	6a 25                	push   $0x25
  8006dd:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e0:	83 c4 10             	add    $0x10,%esp
  8006e3:	89 f3                	mov    %esi,%ebx
  8006e5:	eb 03                	jmp    8006ea <vprintfmt+0x39b>
  8006e7:	83 eb 01             	sub    $0x1,%ebx
  8006ea:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8006ee:	75 f7                	jne    8006e7 <vprintfmt+0x398>
  8006f0:	e9 86 fc ff ff       	jmp    80037b <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
  8006f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f8:	5b                   	pop    %ebx
  8006f9:	5e                   	pop    %esi
  8006fa:	5f                   	pop    %edi
  8006fb:	5d                   	pop    %ebp
  8006fc:	c3                   	ret    

008006fd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006fd:	55                   	push   %ebp
  8006fe:	89 e5                	mov    %esp,%ebp
  800700:	83 ec 18             	sub    $0x18,%esp
  800703:	8b 45 08             	mov    0x8(%ebp),%eax
  800706:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800709:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80070c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800710:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800713:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80071a:	85 c0                	test   %eax,%eax
  80071c:	74 26                	je     800744 <vsnprintf+0x47>
  80071e:	85 d2                	test   %edx,%edx
  800720:	7e 22                	jle    800744 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800722:	ff 75 14             	pushl  0x14(%ebp)
  800725:	ff 75 10             	pushl  0x10(%ebp)
  800728:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80072b:	50                   	push   %eax
  80072c:	68 15 03 80 00       	push   $0x800315
  800731:	e8 19 fc ff ff       	call   80034f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800736:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800739:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80073c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80073f:	83 c4 10             	add    $0x10,%esp
  800742:	eb 05                	jmp    800749 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800744:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800749:	c9                   	leave  
  80074a:	c3                   	ret    

0080074b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80074b:	55                   	push   %ebp
  80074c:	89 e5                	mov    %esp,%ebp
  80074e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800751:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800754:	50                   	push   %eax
  800755:	ff 75 10             	pushl  0x10(%ebp)
  800758:	ff 75 0c             	pushl  0xc(%ebp)
  80075b:	ff 75 08             	pushl  0x8(%ebp)
  80075e:	e8 9a ff ff ff       	call   8006fd <vsnprintf>
	va_end(ap);

	return rc;
}
  800763:	c9                   	leave  
  800764:	c3                   	ret    

00800765 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800765:	55                   	push   %ebp
  800766:	89 e5                	mov    %esp,%ebp
  800768:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80076b:	b8 00 00 00 00       	mov    $0x0,%eax
  800770:	eb 03                	jmp    800775 <strlen+0x10>
		n++;
  800772:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800775:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800779:	75 f7                	jne    800772 <strlen+0xd>
		n++;
	return n;
}
  80077b:	5d                   	pop    %ebp
  80077c:	c3                   	ret    

0080077d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80077d:	55                   	push   %ebp
  80077e:	89 e5                	mov    %esp,%ebp
  800780:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800783:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800786:	ba 00 00 00 00       	mov    $0x0,%edx
  80078b:	eb 03                	jmp    800790 <strnlen+0x13>
		n++;
  80078d:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800790:	39 c2                	cmp    %eax,%edx
  800792:	74 08                	je     80079c <strnlen+0x1f>
  800794:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800798:	75 f3                	jne    80078d <strnlen+0x10>
  80079a:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80079c:	5d                   	pop    %ebp
  80079d:	c3                   	ret    

0080079e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	53                   	push   %ebx
  8007a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a8:	89 c2                	mov    %eax,%edx
  8007aa:	83 c2 01             	add    $0x1,%edx
  8007ad:	83 c1 01             	add    $0x1,%ecx
  8007b0:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007b4:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007b7:	84 db                	test   %bl,%bl
  8007b9:	75 ef                	jne    8007aa <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007bb:	5b                   	pop    %ebx
  8007bc:	5d                   	pop    %ebp
  8007bd:	c3                   	ret    

008007be <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007be:	55                   	push   %ebp
  8007bf:	89 e5                	mov    %esp,%ebp
  8007c1:	53                   	push   %ebx
  8007c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007c5:	53                   	push   %ebx
  8007c6:	e8 9a ff ff ff       	call   800765 <strlen>
  8007cb:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007ce:	ff 75 0c             	pushl  0xc(%ebp)
  8007d1:	01 d8                	add    %ebx,%eax
  8007d3:	50                   	push   %eax
  8007d4:	e8 c5 ff ff ff       	call   80079e <strcpy>
	return dst;
}
  8007d9:	89 d8                	mov    %ebx,%eax
  8007db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007de:	c9                   	leave  
  8007df:	c3                   	ret    

008007e0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	56                   	push   %esi
  8007e4:	53                   	push   %ebx
  8007e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007eb:	89 f3                	mov    %esi,%ebx
  8007ed:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f0:	89 f2                	mov    %esi,%edx
  8007f2:	eb 0f                	jmp    800803 <strncpy+0x23>
		*dst++ = *src;
  8007f4:	83 c2 01             	add    $0x1,%edx
  8007f7:	0f b6 01             	movzbl (%ecx),%eax
  8007fa:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007fd:	80 39 01             	cmpb   $0x1,(%ecx)
  800800:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800803:	39 da                	cmp    %ebx,%edx
  800805:	75 ed                	jne    8007f4 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800807:	89 f0                	mov    %esi,%eax
  800809:	5b                   	pop    %ebx
  80080a:	5e                   	pop    %esi
  80080b:	5d                   	pop    %ebp
  80080c:	c3                   	ret    

0080080d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80080d:	55                   	push   %ebp
  80080e:	89 e5                	mov    %esp,%ebp
  800810:	56                   	push   %esi
  800811:	53                   	push   %ebx
  800812:	8b 75 08             	mov    0x8(%ebp),%esi
  800815:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800818:	8b 55 10             	mov    0x10(%ebp),%edx
  80081b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80081d:	85 d2                	test   %edx,%edx
  80081f:	74 21                	je     800842 <strlcpy+0x35>
  800821:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800825:	89 f2                	mov    %esi,%edx
  800827:	eb 09                	jmp    800832 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800829:	83 c2 01             	add    $0x1,%edx
  80082c:	83 c1 01             	add    $0x1,%ecx
  80082f:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800832:	39 c2                	cmp    %eax,%edx
  800834:	74 09                	je     80083f <strlcpy+0x32>
  800836:	0f b6 19             	movzbl (%ecx),%ebx
  800839:	84 db                	test   %bl,%bl
  80083b:	75 ec                	jne    800829 <strlcpy+0x1c>
  80083d:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80083f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800842:	29 f0                	sub    %esi,%eax
}
  800844:	5b                   	pop    %ebx
  800845:	5e                   	pop    %esi
  800846:	5d                   	pop    %ebp
  800847:	c3                   	ret    

00800848 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800851:	eb 06                	jmp    800859 <strcmp+0x11>
		p++, q++;
  800853:	83 c1 01             	add    $0x1,%ecx
  800856:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800859:	0f b6 01             	movzbl (%ecx),%eax
  80085c:	84 c0                	test   %al,%al
  80085e:	74 04                	je     800864 <strcmp+0x1c>
  800860:	3a 02                	cmp    (%edx),%al
  800862:	74 ef                	je     800853 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800864:	0f b6 c0             	movzbl %al,%eax
  800867:	0f b6 12             	movzbl (%edx),%edx
  80086a:	29 d0                	sub    %edx,%eax
}
  80086c:	5d                   	pop    %ebp
  80086d:	c3                   	ret    

0080086e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	53                   	push   %ebx
  800872:	8b 45 08             	mov    0x8(%ebp),%eax
  800875:	8b 55 0c             	mov    0xc(%ebp),%edx
  800878:	89 c3                	mov    %eax,%ebx
  80087a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80087d:	eb 06                	jmp    800885 <strncmp+0x17>
		n--, p++, q++;
  80087f:	83 c0 01             	add    $0x1,%eax
  800882:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800885:	39 d8                	cmp    %ebx,%eax
  800887:	74 15                	je     80089e <strncmp+0x30>
  800889:	0f b6 08             	movzbl (%eax),%ecx
  80088c:	84 c9                	test   %cl,%cl
  80088e:	74 04                	je     800894 <strncmp+0x26>
  800890:	3a 0a                	cmp    (%edx),%cl
  800892:	74 eb                	je     80087f <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800894:	0f b6 00             	movzbl (%eax),%eax
  800897:	0f b6 12             	movzbl (%edx),%edx
  80089a:	29 d0                	sub    %edx,%eax
  80089c:	eb 05                	jmp    8008a3 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80089e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008a3:	5b                   	pop    %ebx
  8008a4:	5d                   	pop    %ebp
  8008a5:	c3                   	ret    

008008a6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ac:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b0:	eb 07                	jmp    8008b9 <strchr+0x13>
		if (*s == c)
  8008b2:	38 ca                	cmp    %cl,%dl
  8008b4:	74 0f                	je     8008c5 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b6:	83 c0 01             	add    $0x1,%eax
  8008b9:	0f b6 10             	movzbl (%eax),%edx
  8008bc:	84 d2                	test   %dl,%dl
  8008be:	75 f2                	jne    8008b2 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c5:	5d                   	pop    %ebp
  8008c6:	c3                   	ret    

008008c7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d1:	eb 03                	jmp    8008d6 <strfind+0xf>
  8008d3:	83 c0 01             	add    $0x1,%eax
  8008d6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008d9:	38 ca                	cmp    %cl,%dl
  8008db:	74 04                	je     8008e1 <strfind+0x1a>
  8008dd:	84 d2                	test   %dl,%dl
  8008df:	75 f2                	jne    8008d3 <strfind+0xc>
			break;
	return (char *) s;
}
  8008e1:	5d                   	pop    %ebp
  8008e2:	c3                   	ret    

008008e3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	57                   	push   %edi
  8008e7:	56                   	push   %esi
  8008e8:	53                   	push   %ebx
  8008e9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ec:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ef:	85 c9                	test   %ecx,%ecx
  8008f1:	74 36                	je     800929 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f3:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f9:	75 28                	jne    800923 <memset+0x40>
  8008fb:	f6 c1 03             	test   $0x3,%cl
  8008fe:	75 23                	jne    800923 <memset+0x40>
		c &= 0xFF;
  800900:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800904:	89 d3                	mov    %edx,%ebx
  800906:	c1 e3 08             	shl    $0x8,%ebx
  800909:	89 d6                	mov    %edx,%esi
  80090b:	c1 e6 18             	shl    $0x18,%esi
  80090e:	89 d0                	mov    %edx,%eax
  800910:	c1 e0 10             	shl    $0x10,%eax
  800913:	09 f0                	or     %esi,%eax
  800915:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800917:	89 d8                	mov    %ebx,%eax
  800919:	09 d0                	or     %edx,%eax
  80091b:	c1 e9 02             	shr    $0x2,%ecx
  80091e:	fc                   	cld    
  80091f:	f3 ab                	rep stos %eax,%es:(%edi)
  800921:	eb 06                	jmp    800929 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800923:	8b 45 0c             	mov    0xc(%ebp),%eax
  800926:	fc                   	cld    
  800927:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800929:	89 f8                	mov    %edi,%eax
  80092b:	5b                   	pop    %ebx
  80092c:	5e                   	pop    %esi
  80092d:	5f                   	pop    %edi
  80092e:	5d                   	pop    %ebp
  80092f:	c3                   	ret    

00800930 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	57                   	push   %edi
  800934:	56                   	push   %esi
  800935:	8b 45 08             	mov    0x8(%ebp),%eax
  800938:	8b 75 0c             	mov    0xc(%ebp),%esi
  80093b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80093e:	39 c6                	cmp    %eax,%esi
  800940:	73 35                	jae    800977 <memmove+0x47>
  800942:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800945:	39 d0                	cmp    %edx,%eax
  800947:	73 2e                	jae    800977 <memmove+0x47>
		s += n;
		d += n;
  800949:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094c:	89 d6                	mov    %edx,%esi
  80094e:	09 fe                	or     %edi,%esi
  800950:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800956:	75 13                	jne    80096b <memmove+0x3b>
  800958:	f6 c1 03             	test   $0x3,%cl
  80095b:	75 0e                	jne    80096b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80095d:	83 ef 04             	sub    $0x4,%edi
  800960:	8d 72 fc             	lea    -0x4(%edx),%esi
  800963:	c1 e9 02             	shr    $0x2,%ecx
  800966:	fd                   	std    
  800967:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800969:	eb 09                	jmp    800974 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80096b:	83 ef 01             	sub    $0x1,%edi
  80096e:	8d 72 ff             	lea    -0x1(%edx),%esi
  800971:	fd                   	std    
  800972:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800974:	fc                   	cld    
  800975:	eb 1d                	jmp    800994 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800977:	89 f2                	mov    %esi,%edx
  800979:	09 c2                	or     %eax,%edx
  80097b:	f6 c2 03             	test   $0x3,%dl
  80097e:	75 0f                	jne    80098f <memmove+0x5f>
  800980:	f6 c1 03             	test   $0x3,%cl
  800983:	75 0a                	jne    80098f <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800985:	c1 e9 02             	shr    $0x2,%ecx
  800988:	89 c7                	mov    %eax,%edi
  80098a:	fc                   	cld    
  80098b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098d:	eb 05                	jmp    800994 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80098f:	89 c7                	mov    %eax,%edi
  800991:	fc                   	cld    
  800992:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800994:	5e                   	pop    %esi
  800995:	5f                   	pop    %edi
  800996:	5d                   	pop    %ebp
  800997:	c3                   	ret    

00800998 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80099b:	ff 75 10             	pushl  0x10(%ebp)
  80099e:	ff 75 0c             	pushl  0xc(%ebp)
  8009a1:	ff 75 08             	pushl  0x8(%ebp)
  8009a4:	e8 87 ff ff ff       	call   800930 <memmove>
}
  8009a9:	c9                   	leave  
  8009aa:	c3                   	ret    

008009ab <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	56                   	push   %esi
  8009af:	53                   	push   %ebx
  8009b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b6:	89 c6                	mov    %eax,%esi
  8009b8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009bb:	eb 1a                	jmp    8009d7 <memcmp+0x2c>
		if (*s1 != *s2)
  8009bd:	0f b6 08             	movzbl (%eax),%ecx
  8009c0:	0f b6 1a             	movzbl (%edx),%ebx
  8009c3:	38 d9                	cmp    %bl,%cl
  8009c5:	74 0a                	je     8009d1 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009c7:	0f b6 c1             	movzbl %cl,%eax
  8009ca:	0f b6 db             	movzbl %bl,%ebx
  8009cd:	29 d8                	sub    %ebx,%eax
  8009cf:	eb 0f                	jmp    8009e0 <memcmp+0x35>
		s1++, s2++;
  8009d1:	83 c0 01             	add    $0x1,%eax
  8009d4:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d7:	39 f0                	cmp    %esi,%eax
  8009d9:	75 e2                	jne    8009bd <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e0:	5b                   	pop    %ebx
  8009e1:	5e                   	pop    %esi
  8009e2:	5d                   	pop    %ebp
  8009e3:	c3                   	ret    

008009e4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	53                   	push   %ebx
  8009e8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009eb:	89 c1                	mov    %eax,%ecx
  8009ed:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f0:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f4:	eb 0a                	jmp    800a00 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f6:	0f b6 10             	movzbl (%eax),%edx
  8009f9:	39 da                	cmp    %ebx,%edx
  8009fb:	74 07                	je     800a04 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009fd:	83 c0 01             	add    $0x1,%eax
  800a00:	39 c8                	cmp    %ecx,%eax
  800a02:	72 f2                	jb     8009f6 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a04:	5b                   	pop    %ebx
  800a05:	5d                   	pop    %ebp
  800a06:	c3                   	ret    

00800a07 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	57                   	push   %edi
  800a0b:	56                   	push   %esi
  800a0c:	53                   	push   %ebx
  800a0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a10:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a13:	eb 03                	jmp    800a18 <strtol+0x11>
		s++;
  800a15:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a18:	0f b6 01             	movzbl (%ecx),%eax
  800a1b:	3c 20                	cmp    $0x20,%al
  800a1d:	74 f6                	je     800a15 <strtol+0xe>
  800a1f:	3c 09                	cmp    $0x9,%al
  800a21:	74 f2                	je     800a15 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a23:	3c 2b                	cmp    $0x2b,%al
  800a25:	75 0a                	jne    800a31 <strtol+0x2a>
		s++;
  800a27:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a2a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a2f:	eb 11                	jmp    800a42 <strtol+0x3b>
  800a31:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a36:	3c 2d                	cmp    $0x2d,%al
  800a38:	75 08                	jne    800a42 <strtol+0x3b>
		s++, neg = 1;
  800a3a:	83 c1 01             	add    $0x1,%ecx
  800a3d:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a42:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a48:	75 15                	jne    800a5f <strtol+0x58>
  800a4a:	80 39 30             	cmpb   $0x30,(%ecx)
  800a4d:	75 10                	jne    800a5f <strtol+0x58>
  800a4f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a53:	75 7c                	jne    800ad1 <strtol+0xca>
		s += 2, base = 16;
  800a55:	83 c1 02             	add    $0x2,%ecx
  800a58:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a5d:	eb 16                	jmp    800a75 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a5f:	85 db                	test   %ebx,%ebx
  800a61:	75 12                	jne    800a75 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a63:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a68:	80 39 30             	cmpb   $0x30,(%ecx)
  800a6b:	75 08                	jne    800a75 <strtol+0x6e>
		s++, base = 8;
  800a6d:	83 c1 01             	add    $0x1,%ecx
  800a70:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a75:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a7d:	0f b6 11             	movzbl (%ecx),%edx
  800a80:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a83:	89 f3                	mov    %esi,%ebx
  800a85:	80 fb 09             	cmp    $0x9,%bl
  800a88:	77 08                	ja     800a92 <strtol+0x8b>
			dig = *s - '0';
  800a8a:	0f be d2             	movsbl %dl,%edx
  800a8d:	83 ea 30             	sub    $0x30,%edx
  800a90:	eb 22                	jmp    800ab4 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a92:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a95:	89 f3                	mov    %esi,%ebx
  800a97:	80 fb 19             	cmp    $0x19,%bl
  800a9a:	77 08                	ja     800aa4 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a9c:	0f be d2             	movsbl %dl,%edx
  800a9f:	83 ea 57             	sub    $0x57,%edx
  800aa2:	eb 10                	jmp    800ab4 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800aa4:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aa7:	89 f3                	mov    %esi,%ebx
  800aa9:	80 fb 19             	cmp    $0x19,%bl
  800aac:	77 16                	ja     800ac4 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aae:	0f be d2             	movsbl %dl,%edx
  800ab1:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ab4:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ab7:	7d 0b                	jge    800ac4 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ab9:	83 c1 01             	add    $0x1,%ecx
  800abc:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ac0:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ac2:	eb b9                	jmp    800a7d <strtol+0x76>

	if (endptr)
  800ac4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac8:	74 0d                	je     800ad7 <strtol+0xd0>
		*endptr = (char *) s;
  800aca:	8b 75 0c             	mov    0xc(%ebp),%esi
  800acd:	89 0e                	mov    %ecx,(%esi)
  800acf:	eb 06                	jmp    800ad7 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ad1:	85 db                	test   %ebx,%ebx
  800ad3:	74 98                	je     800a6d <strtol+0x66>
  800ad5:	eb 9e                	jmp    800a75 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ad7:	89 c2                	mov    %eax,%edx
  800ad9:	f7 da                	neg    %edx
  800adb:	85 ff                	test   %edi,%edi
  800add:	0f 45 c2             	cmovne %edx,%eax
}
  800ae0:	5b                   	pop    %ebx
  800ae1:	5e                   	pop    %esi
  800ae2:	5f                   	pop    %edi
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    
  800ae5:	66 90                	xchg   %ax,%ax
  800ae7:	66 90                	xchg   %ax,%ax
  800ae9:	66 90                	xchg   %ax,%ax
  800aeb:	66 90                	xchg   %ax,%ax
  800aed:	66 90                	xchg   %ax,%ax
  800aef:	90                   	nop

00800af0 <__udivdi3>:
  800af0:	55                   	push   %ebp
  800af1:	57                   	push   %edi
  800af2:	56                   	push   %esi
  800af3:	53                   	push   %ebx
  800af4:	83 ec 1c             	sub    $0x1c,%esp
  800af7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800afb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800aff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800b03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800b07:	85 f6                	test   %esi,%esi
  800b09:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800b0d:	89 ca                	mov    %ecx,%edx
  800b0f:	89 f8                	mov    %edi,%eax
  800b11:	75 3d                	jne    800b50 <__udivdi3+0x60>
  800b13:	39 cf                	cmp    %ecx,%edi
  800b15:	0f 87 c5 00 00 00    	ja     800be0 <__udivdi3+0xf0>
  800b1b:	85 ff                	test   %edi,%edi
  800b1d:	89 fd                	mov    %edi,%ebp
  800b1f:	75 0b                	jne    800b2c <__udivdi3+0x3c>
  800b21:	b8 01 00 00 00       	mov    $0x1,%eax
  800b26:	31 d2                	xor    %edx,%edx
  800b28:	f7 f7                	div    %edi
  800b2a:	89 c5                	mov    %eax,%ebp
  800b2c:	89 c8                	mov    %ecx,%eax
  800b2e:	31 d2                	xor    %edx,%edx
  800b30:	f7 f5                	div    %ebp
  800b32:	89 c1                	mov    %eax,%ecx
  800b34:	89 d8                	mov    %ebx,%eax
  800b36:	89 cf                	mov    %ecx,%edi
  800b38:	f7 f5                	div    %ebp
  800b3a:	89 c3                	mov    %eax,%ebx
  800b3c:	89 d8                	mov    %ebx,%eax
  800b3e:	89 fa                	mov    %edi,%edx
  800b40:	83 c4 1c             	add    $0x1c,%esp
  800b43:	5b                   	pop    %ebx
  800b44:	5e                   	pop    %esi
  800b45:	5f                   	pop    %edi
  800b46:	5d                   	pop    %ebp
  800b47:	c3                   	ret    
  800b48:	90                   	nop
  800b49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800b50:	39 ce                	cmp    %ecx,%esi
  800b52:	77 74                	ja     800bc8 <__udivdi3+0xd8>
  800b54:	0f bd fe             	bsr    %esi,%edi
  800b57:	83 f7 1f             	xor    $0x1f,%edi
  800b5a:	0f 84 98 00 00 00    	je     800bf8 <__udivdi3+0x108>
  800b60:	bb 20 00 00 00       	mov    $0x20,%ebx
  800b65:	89 f9                	mov    %edi,%ecx
  800b67:	89 c5                	mov    %eax,%ebp
  800b69:	29 fb                	sub    %edi,%ebx
  800b6b:	d3 e6                	shl    %cl,%esi
  800b6d:	89 d9                	mov    %ebx,%ecx
  800b6f:	d3 ed                	shr    %cl,%ebp
  800b71:	89 f9                	mov    %edi,%ecx
  800b73:	d3 e0                	shl    %cl,%eax
  800b75:	09 ee                	or     %ebp,%esi
  800b77:	89 d9                	mov    %ebx,%ecx
  800b79:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b7d:	89 d5                	mov    %edx,%ebp
  800b7f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800b83:	d3 ed                	shr    %cl,%ebp
  800b85:	89 f9                	mov    %edi,%ecx
  800b87:	d3 e2                	shl    %cl,%edx
  800b89:	89 d9                	mov    %ebx,%ecx
  800b8b:	d3 e8                	shr    %cl,%eax
  800b8d:	09 c2                	or     %eax,%edx
  800b8f:	89 d0                	mov    %edx,%eax
  800b91:	89 ea                	mov    %ebp,%edx
  800b93:	f7 f6                	div    %esi
  800b95:	89 d5                	mov    %edx,%ebp
  800b97:	89 c3                	mov    %eax,%ebx
  800b99:	f7 64 24 0c          	mull   0xc(%esp)
  800b9d:	39 d5                	cmp    %edx,%ebp
  800b9f:	72 10                	jb     800bb1 <__udivdi3+0xc1>
  800ba1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800ba5:	89 f9                	mov    %edi,%ecx
  800ba7:	d3 e6                	shl    %cl,%esi
  800ba9:	39 c6                	cmp    %eax,%esi
  800bab:	73 07                	jae    800bb4 <__udivdi3+0xc4>
  800bad:	39 d5                	cmp    %edx,%ebp
  800baf:	75 03                	jne    800bb4 <__udivdi3+0xc4>
  800bb1:	83 eb 01             	sub    $0x1,%ebx
  800bb4:	31 ff                	xor    %edi,%edi
  800bb6:	89 d8                	mov    %ebx,%eax
  800bb8:	89 fa                	mov    %edi,%edx
  800bba:	83 c4 1c             	add    $0x1c,%esp
  800bbd:	5b                   	pop    %ebx
  800bbe:	5e                   	pop    %esi
  800bbf:	5f                   	pop    %edi
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    
  800bc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800bc8:	31 ff                	xor    %edi,%edi
  800bca:	31 db                	xor    %ebx,%ebx
  800bcc:	89 d8                	mov    %ebx,%eax
  800bce:	89 fa                	mov    %edi,%edx
  800bd0:	83 c4 1c             	add    $0x1c,%esp
  800bd3:	5b                   	pop    %ebx
  800bd4:	5e                   	pop    %esi
  800bd5:	5f                   	pop    %edi
  800bd6:	5d                   	pop    %ebp
  800bd7:	c3                   	ret    
  800bd8:	90                   	nop
  800bd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800be0:	89 d8                	mov    %ebx,%eax
  800be2:	f7 f7                	div    %edi
  800be4:	31 ff                	xor    %edi,%edi
  800be6:	89 c3                	mov    %eax,%ebx
  800be8:	89 d8                	mov    %ebx,%eax
  800bea:	89 fa                	mov    %edi,%edx
  800bec:	83 c4 1c             	add    $0x1c,%esp
  800bef:	5b                   	pop    %ebx
  800bf0:	5e                   	pop    %esi
  800bf1:	5f                   	pop    %edi
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    
  800bf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800bf8:	39 ce                	cmp    %ecx,%esi
  800bfa:	72 0c                	jb     800c08 <__udivdi3+0x118>
  800bfc:	31 db                	xor    %ebx,%ebx
  800bfe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800c02:	0f 87 34 ff ff ff    	ja     800b3c <__udivdi3+0x4c>
  800c08:	bb 01 00 00 00       	mov    $0x1,%ebx
  800c0d:	e9 2a ff ff ff       	jmp    800b3c <__udivdi3+0x4c>
  800c12:	66 90                	xchg   %ax,%ax
  800c14:	66 90                	xchg   %ax,%ax
  800c16:	66 90                	xchg   %ax,%ax
  800c18:	66 90                	xchg   %ax,%ax
  800c1a:	66 90                	xchg   %ax,%ax
  800c1c:	66 90                	xchg   %ax,%ax
  800c1e:	66 90                	xchg   %ax,%ax

00800c20 <__umoddi3>:
  800c20:	55                   	push   %ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
  800c24:	83 ec 1c             	sub    $0x1c,%esp
  800c27:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c2b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800c2f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800c37:	85 d2                	test   %edx,%edx
  800c39:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800c3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c41:	89 f3                	mov    %esi,%ebx
  800c43:	89 3c 24             	mov    %edi,(%esp)
  800c46:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c4a:	75 1c                	jne    800c68 <__umoddi3+0x48>
  800c4c:	39 f7                	cmp    %esi,%edi
  800c4e:	76 50                	jbe    800ca0 <__umoddi3+0x80>
  800c50:	89 c8                	mov    %ecx,%eax
  800c52:	89 f2                	mov    %esi,%edx
  800c54:	f7 f7                	div    %edi
  800c56:	89 d0                	mov    %edx,%eax
  800c58:	31 d2                	xor    %edx,%edx
  800c5a:	83 c4 1c             	add    $0x1c,%esp
  800c5d:	5b                   	pop    %ebx
  800c5e:	5e                   	pop    %esi
  800c5f:	5f                   	pop    %edi
  800c60:	5d                   	pop    %ebp
  800c61:	c3                   	ret    
  800c62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c68:	39 f2                	cmp    %esi,%edx
  800c6a:	89 d0                	mov    %edx,%eax
  800c6c:	77 52                	ja     800cc0 <__umoddi3+0xa0>
  800c6e:	0f bd ea             	bsr    %edx,%ebp
  800c71:	83 f5 1f             	xor    $0x1f,%ebp
  800c74:	75 5a                	jne    800cd0 <__umoddi3+0xb0>
  800c76:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800c7a:	0f 82 e0 00 00 00    	jb     800d60 <__umoddi3+0x140>
  800c80:	39 0c 24             	cmp    %ecx,(%esp)
  800c83:	0f 86 d7 00 00 00    	jbe    800d60 <__umoddi3+0x140>
  800c89:	8b 44 24 08          	mov    0x8(%esp),%eax
  800c8d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800c91:	83 c4 1c             	add    $0x1c,%esp
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    
  800c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ca0:	85 ff                	test   %edi,%edi
  800ca2:	89 fd                	mov    %edi,%ebp
  800ca4:	75 0b                	jne    800cb1 <__umoddi3+0x91>
  800ca6:	b8 01 00 00 00       	mov    $0x1,%eax
  800cab:	31 d2                	xor    %edx,%edx
  800cad:	f7 f7                	div    %edi
  800caf:	89 c5                	mov    %eax,%ebp
  800cb1:	89 f0                	mov    %esi,%eax
  800cb3:	31 d2                	xor    %edx,%edx
  800cb5:	f7 f5                	div    %ebp
  800cb7:	89 c8                	mov    %ecx,%eax
  800cb9:	f7 f5                	div    %ebp
  800cbb:	89 d0                	mov    %edx,%eax
  800cbd:	eb 99                	jmp    800c58 <__umoddi3+0x38>
  800cbf:	90                   	nop
  800cc0:	89 c8                	mov    %ecx,%eax
  800cc2:	89 f2                	mov    %esi,%edx
  800cc4:	83 c4 1c             	add    $0x1c,%esp
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5f                   	pop    %edi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    
  800ccc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cd0:	8b 34 24             	mov    (%esp),%esi
  800cd3:	bf 20 00 00 00       	mov    $0x20,%edi
  800cd8:	89 e9                	mov    %ebp,%ecx
  800cda:	29 ef                	sub    %ebp,%edi
  800cdc:	d3 e0                	shl    %cl,%eax
  800cde:	89 f9                	mov    %edi,%ecx
  800ce0:	89 f2                	mov    %esi,%edx
  800ce2:	d3 ea                	shr    %cl,%edx
  800ce4:	89 e9                	mov    %ebp,%ecx
  800ce6:	09 c2                	or     %eax,%edx
  800ce8:	89 d8                	mov    %ebx,%eax
  800cea:	89 14 24             	mov    %edx,(%esp)
  800ced:	89 f2                	mov    %esi,%edx
  800cef:	d3 e2                	shl    %cl,%edx
  800cf1:	89 f9                	mov    %edi,%ecx
  800cf3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800cf7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800cfb:	d3 e8                	shr    %cl,%eax
  800cfd:	89 e9                	mov    %ebp,%ecx
  800cff:	89 c6                	mov    %eax,%esi
  800d01:	d3 e3                	shl    %cl,%ebx
  800d03:	89 f9                	mov    %edi,%ecx
  800d05:	89 d0                	mov    %edx,%eax
  800d07:	d3 e8                	shr    %cl,%eax
  800d09:	89 e9                	mov    %ebp,%ecx
  800d0b:	09 d8                	or     %ebx,%eax
  800d0d:	89 d3                	mov    %edx,%ebx
  800d0f:	89 f2                	mov    %esi,%edx
  800d11:	f7 34 24             	divl   (%esp)
  800d14:	89 d6                	mov    %edx,%esi
  800d16:	d3 e3                	shl    %cl,%ebx
  800d18:	f7 64 24 04          	mull   0x4(%esp)
  800d1c:	39 d6                	cmp    %edx,%esi
  800d1e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d22:	89 d1                	mov    %edx,%ecx
  800d24:	89 c3                	mov    %eax,%ebx
  800d26:	72 08                	jb     800d30 <__umoddi3+0x110>
  800d28:	75 11                	jne    800d3b <__umoddi3+0x11b>
  800d2a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800d2e:	73 0b                	jae    800d3b <__umoddi3+0x11b>
  800d30:	2b 44 24 04          	sub    0x4(%esp),%eax
  800d34:	1b 14 24             	sbb    (%esp),%edx
  800d37:	89 d1                	mov    %edx,%ecx
  800d39:	89 c3                	mov    %eax,%ebx
  800d3b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800d3f:	29 da                	sub    %ebx,%edx
  800d41:	19 ce                	sbb    %ecx,%esi
  800d43:	89 f9                	mov    %edi,%ecx
  800d45:	89 f0                	mov    %esi,%eax
  800d47:	d3 e0                	shl    %cl,%eax
  800d49:	89 e9                	mov    %ebp,%ecx
  800d4b:	d3 ea                	shr    %cl,%edx
  800d4d:	89 e9                	mov    %ebp,%ecx
  800d4f:	d3 ee                	shr    %cl,%esi
  800d51:	09 d0                	or     %edx,%eax
  800d53:	89 f2                	mov    %esi,%edx
  800d55:	83 c4 1c             	add    $0x1c,%esp
  800d58:	5b                   	pop    %ebx
  800d59:	5e                   	pop    %esi
  800d5a:	5f                   	pop    %edi
  800d5b:	5d                   	pop    %ebp
  800d5c:	c3                   	ret    
  800d5d:	8d 76 00             	lea    0x0(%esi),%esi
  800d60:	29 f9                	sub    %edi,%ecx
  800d62:	19 d6                	sbb    %edx,%esi
  800d64:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d68:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d6c:	e9 18 ff ff ff       	jmp    800c89 <__umoddi3+0x69>
