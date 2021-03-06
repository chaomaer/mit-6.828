
obj/user/pingpongs:     file format elf32-i386


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
  80002c:	e8 cd 00 00 00       	call   8000fe <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003c:	e8 3c 0f 00 00       	call   800f7d <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 42                	je     80008a <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  80004e:	e8 e0 0a 00 00       	call   800b33 <sys_getenvid>
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	53                   	push   %ebx
  800057:	50                   	push   %eax
  800058:	68 00 14 80 00       	push   $0x801400
  80005d:	e8 87 01 00 00       	call   8001e9 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 c9 0a 00 00       	call   800b33 <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 1a 14 80 00       	push   $0x80141a
  800074:	e8 70 01 00 00       	call   8001e9 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 79 0f 00 00       	call   801000 <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 fd 0e 00 00       	call   800f97 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80009a:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  8000a0:	8b 7b 48             	mov    0x48(%ebx),%edi
  8000a3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a6:	a1 04 20 80 00       	mov    0x802004,%eax
  8000ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000ae:	e8 80 0a 00 00       	call   800b33 <sys_getenvid>
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	57                   	push   %edi
  8000b7:	53                   	push   %ebx
  8000b8:	56                   	push   %esi
  8000b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8000bc:	50                   	push   %eax
  8000bd:	68 30 14 80 00       	push   $0x801430
  8000c2:	e8 22 01 00 00       	call   8001e9 <cprintf>
		if (val == 10)
  8000c7:	a1 04 20 80 00       	mov    0x802004,%eax
  8000cc:	83 c4 20             	add    $0x20,%esp
  8000cf:	83 f8 0a             	cmp    $0xa,%eax
  8000d2:	74 22                	je     8000f6 <umain+0xc3>
			return;
		++val;
  8000d4:	83 c0 01             	add    $0x1,%eax
  8000d7:	a3 04 20 80 00       	mov    %eax,0x802004
		ipc_send(who, 0, 0, 0);
  8000dc:	6a 00                	push   $0x0
  8000de:	6a 00                	push   $0x0
  8000e0:	6a 00                	push   $0x0
  8000e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e5:	e8 16 0f 00 00       	call   801000 <ipc_send>
		if (val == 10)
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	83 3d 04 20 80 00 0a 	cmpl   $0xa,0x802004
  8000f4:	75 94                	jne    80008a <umain+0x57>
			return;
	}

}
  8000f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f9:	5b                   	pop    %ebx
  8000fa:	5e                   	pop    %esi
  8000fb:	5f                   	pop    %edi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    

008000fe <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800106:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t envid = sys_getenvid();
  800109:	e8 25 0a 00 00       	call   800b33 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80010e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800113:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800116:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011b:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800120:	85 db                	test   %ebx,%ebx
  800122:	7e 07                	jle    80012b <libmain+0x2d>
		binaryname = argv[0];
  800124:	8b 06                	mov    (%esi),%eax
  800126:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80012b:	83 ec 08             	sub    $0x8,%esp
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
  800130:	e8 fe fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800135:	e8 0a 00 00 00       	call   800144 <exit>
}
  80013a:	83 c4 10             	add    $0x10,%esp
  80013d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800140:	5b                   	pop    %ebx
  800141:	5e                   	pop    %esi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80014a:	6a 00                	push   $0x0
  80014c:	e8 a1 09 00 00       	call   800af2 <sys_env_destroy>
}
  800151:	83 c4 10             	add    $0x10,%esp
  800154:	c9                   	leave  
  800155:	c3                   	ret    

00800156 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	53                   	push   %ebx
  80015a:	83 ec 04             	sub    $0x4,%esp
  80015d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800160:	8b 13                	mov    (%ebx),%edx
  800162:	8d 42 01             	lea    0x1(%edx),%eax
  800165:	89 03                	mov    %eax,(%ebx)
  800167:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80016e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800173:	75 1a                	jne    80018f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800175:	83 ec 08             	sub    $0x8,%esp
  800178:	68 ff 00 00 00       	push   $0xff
  80017d:	8d 43 08             	lea    0x8(%ebx),%eax
  800180:	50                   	push   %eax
  800181:	e8 2f 09 00 00       	call   800ab5 <sys_cputs>
		b->idx = 0;
  800186:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80018c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80018f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800193:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800196:	c9                   	leave  
  800197:	c3                   	ret    

00800198 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001a8:	00 00 00 
	b.cnt = 0;
  8001ab:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001b5:	ff 75 0c             	pushl  0xc(%ebp)
  8001b8:	ff 75 08             	pushl  0x8(%ebp)
  8001bb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c1:	50                   	push   %eax
  8001c2:	68 56 01 80 00       	push   $0x800156
  8001c7:	e8 54 01 00 00       	call   800320 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001cc:	83 c4 08             	add    $0x8,%esp
  8001cf:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001d5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001db:	50                   	push   %eax
  8001dc:	e8 d4 08 00 00       	call   800ab5 <sys_cputs>

	return b.cnt;
}
  8001e1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001e7:	c9                   	leave  
  8001e8:	c3                   	ret    

008001e9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001e9:	55                   	push   %ebp
  8001ea:	89 e5                	mov    %esp,%ebp
  8001ec:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ef:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f2:	50                   	push   %eax
  8001f3:	ff 75 08             	pushl  0x8(%ebp)
  8001f6:	e8 9d ff ff ff       	call   800198 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001fb:	c9                   	leave  
  8001fc:	c3                   	ret    

008001fd <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001fd:	55                   	push   %ebp
  8001fe:	89 e5                	mov    %esp,%ebp
  800200:	57                   	push   %edi
  800201:	56                   	push   %esi
  800202:	53                   	push   %ebx
  800203:	83 ec 1c             	sub    $0x1c,%esp
  800206:	89 c7                	mov    %eax,%edi
  800208:	89 d6                	mov    %edx,%esi
  80020a:	8b 45 08             	mov    0x8(%ebp),%eax
  80020d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800210:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800213:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800216:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800219:	bb 00 00 00 00       	mov    $0x0,%ebx
  80021e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800221:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800224:	39 d3                	cmp    %edx,%ebx
  800226:	72 05                	jb     80022d <printnum+0x30>
  800228:	39 45 10             	cmp    %eax,0x10(%ebp)
  80022b:	77 45                	ja     800272 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80022d:	83 ec 0c             	sub    $0xc,%esp
  800230:	ff 75 18             	pushl  0x18(%ebp)
  800233:	8b 45 14             	mov    0x14(%ebp),%eax
  800236:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800239:	53                   	push   %ebx
  80023a:	ff 75 10             	pushl  0x10(%ebp)
  80023d:	83 ec 08             	sub    $0x8,%esp
  800240:	ff 75 e4             	pushl  -0x1c(%ebp)
  800243:	ff 75 e0             	pushl  -0x20(%ebp)
  800246:	ff 75 dc             	pushl  -0x24(%ebp)
  800249:	ff 75 d8             	pushl  -0x28(%ebp)
  80024c:	e8 1f 0f 00 00       	call   801170 <__udivdi3>
  800251:	83 c4 18             	add    $0x18,%esp
  800254:	52                   	push   %edx
  800255:	50                   	push   %eax
  800256:	89 f2                	mov    %esi,%edx
  800258:	89 f8                	mov    %edi,%eax
  80025a:	e8 9e ff ff ff       	call   8001fd <printnum>
  80025f:	83 c4 20             	add    $0x20,%esp
  800262:	eb 18                	jmp    80027c <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800264:	83 ec 08             	sub    $0x8,%esp
  800267:	56                   	push   %esi
  800268:	ff 75 18             	pushl  0x18(%ebp)
  80026b:	ff d7                	call   *%edi
  80026d:	83 c4 10             	add    $0x10,%esp
  800270:	eb 03                	jmp    800275 <printnum+0x78>
  800272:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800275:	83 eb 01             	sub    $0x1,%ebx
  800278:	85 db                	test   %ebx,%ebx
  80027a:	7f e8                	jg     800264 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80027c:	83 ec 08             	sub    $0x8,%esp
  80027f:	56                   	push   %esi
  800280:	83 ec 04             	sub    $0x4,%esp
  800283:	ff 75 e4             	pushl  -0x1c(%ebp)
  800286:	ff 75 e0             	pushl  -0x20(%ebp)
  800289:	ff 75 dc             	pushl  -0x24(%ebp)
  80028c:	ff 75 d8             	pushl  -0x28(%ebp)
  80028f:	e8 0c 10 00 00       	call   8012a0 <__umoddi3>
  800294:	83 c4 14             	add    $0x14,%esp
  800297:	0f be 80 60 14 80 00 	movsbl 0x801460(%eax),%eax
  80029e:	50                   	push   %eax
  80029f:	ff d7                	call   *%edi
}
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a7:	5b                   	pop    %ebx
  8002a8:	5e                   	pop    %esi
  8002a9:	5f                   	pop    %edi
  8002aa:	5d                   	pop    %ebp
  8002ab:	c3                   	ret    

008002ac <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002af:	83 fa 01             	cmp    $0x1,%edx
  8002b2:	7e 0e                	jle    8002c2 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002b4:	8b 10                	mov    (%eax),%edx
  8002b6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002b9:	89 08                	mov    %ecx,(%eax)
  8002bb:	8b 02                	mov    (%edx),%eax
  8002bd:	8b 52 04             	mov    0x4(%edx),%edx
  8002c0:	eb 22                	jmp    8002e4 <getuint+0x38>
	else if (lflag)
  8002c2:	85 d2                	test   %edx,%edx
  8002c4:	74 10                	je     8002d6 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002c6:	8b 10                	mov    (%eax),%edx
  8002c8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002cb:	89 08                	mov    %ecx,(%eax)
  8002cd:	8b 02                	mov    (%edx),%eax
  8002cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d4:	eb 0e                	jmp    8002e4 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002d6:	8b 10                	mov    (%eax),%edx
  8002d8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002db:	89 08                	mov    %ecx,(%eax)
  8002dd:	8b 02                	mov    (%edx),%eax
  8002df:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    

008002e6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ec:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f0:	8b 10                	mov    (%eax),%edx
  8002f2:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f5:	73 0a                	jae    800301 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002f7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002fa:	89 08                	mov    %ecx,(%eax)
  8002fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ff:	88 02                	mov    %al,(%edx)
}
  800301:	5d                   	pop    %ebp
  800302:	c3                   	ret    

00800303 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800303:	55                   	push   %ebp
  800304:	89 e5                	mov    %esp,%ebp
  800306:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800309:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80030c:	50                   	push   %eax
  80030d:	ff 75 10             	pushl  0x10(%ebp)
  800310:	ff 75 0c             	pushl  0xc(%ebp)
  800313:	ff 75 08             	pushl  0x8(%ebp)
  800316:	e8 05 00 00 00       	call   800320 <vprintfmt>
	va_end(ap);
}
  80031b:	83 c4 10             	add    $0x10,%esp
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 2c             	sub    $0x2c,%esp
  800329:	8b 75 08             	mov    0x8(%ebp),%esi
  80032c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80032f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800332:	eb 12                	jmp    800346 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800334:	85 c0                	test   %eax,%eax
  800336:	0f 84 89 03 00 00    	je     8006c5 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80033c:	83 ec 08             	sub    $0x8,%esp
  80033f:	53                   	push   %ebx
  800340:	50                   	push   %eax
  800341:	ff d6                	call   *%esi
  800343:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800346:	83 c7 01             	add    $0x1,%edi
  800349:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80034d:	83 f8 25             	cmp    $0x25,%eax
  800350:	75 e2                	jne    800334 <vprintfmt+0x14>
  800352:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800356:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80035d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800364:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80036b:	ba 00 00 00 00       	mov    $0x0,%edx
  800370:	eb 07                	jmp    800379 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800372:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800375:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800379:	8d 47 01             	lea    0x1(%edi),%eax
  80037c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80037f:	0f b6 07             	movzbl (%edi),%eax
  800382:	0f b6 c8             	movzbl %al,%ecx
  800385:	83 e8 23             	sub    $0x23,%eax
  800388:	3c 55                	cmp    $0x55,%al
  80038a:	0f 87 1a 03 00 00    	ja     8006aa <vprintfmt+0x38a>
  800390:	0f b6 c0             	movzbl %al,%eax
  800393:	ff 24 85 20 15 80 00 	jmp    *0x801520(,%eax,4)
  80039a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80039d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003a1:	eb d6                	jmp    800379 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ab:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ae:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b1:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003b5:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003b8:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003bb:	83 fa 09             	cmp    $0x9,%edx
  8003be:	77 39                	ja     8003f9 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003c3:	eb e9                	jmp    8003ae <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c8:	8d 48 04             	lea    0x4(%eax),%ecx
  8003cb:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003ce:	8b 00                	mov    (%eax),%eax
  8003d0:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003d6:	eb 27                	jmp    8003ff <vprintfmt+0xdf>
  8003d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003db:	85 c0                	test   %eax,%eax
  8003dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e2:	0f 49 c8             	cmovns %eax,%ecx
  8003e5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003eb:	eb 8c                	jmp    800379 <vprintfmt+0x59>
  8003ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003f7:	eb 80                	jmp    800379 <vprintfmt+0x59>
  8003f9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003fc:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003ff:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800403:	0f 89 70 ff ff ff    	jns    800379 <vprintfmt+0x59>
				width = precision, precision = -1;
  800409:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80040c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80040f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800416:	e9 5e ff ff ff       	jmp    800379 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80041b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800421:	e9 53 ff ff ff       	jmp    800379 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800426:	8b 45 14             	mov    0x14(%ebp),%eax
  800429:	8d 50 04             	lea    0x4(%eax),%edx
  80042c:	89 55 14             	mov    %edx,0x14(%ebp)
  80042f:	83 ec 08             	sub    $0x8,%esp
  800432:	53                   	push   %ebx
  800433:	ff 30                	pushl  (%eax)
  800435:	ff d6                	call   *%esi
			break;
  800437:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80043d:	e9 04 ff ff ff       	jmp    800346 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800442:	8b 45 14             	mov    0x14(%ebp),%eax
  800445:	8d 50 04             	lea    0x4(%eax),%edx
  800448:	89 55 14             	mov    %edx,0x14(%ebp)
  80044b:	8b 00                	mov    (%eax),%eax
  80044d:	99                   	cltd   
  80044e:	31 d0                	xor    %edx,%eax
  800450:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800452:	83 f8 09             	cmp    $0x9,%eax
  800455:	7f 0b                	jg     800462 <vprintfmt+0x142>
  800457:	8b 14 85 80 16 80 00 	mov    0x801680(,%eax,4),%edx
  80045e:	85 d2                	test   %edx,%edx
  800460:	75 18                	jne    80047a <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800462:	50                   	push   %eax
  800463:	68 78 14 80 00       	push   $0x801478
  800468:	53                   	push   %ebx
  800469:	56                   	push   %esi
  80046a:	e8 94 fe ff ff       	call   800303 <printfmt>
  80046f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800472:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800475:	e9 cc fe ff ff       	jmp    800346 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80047a:	52                   	push   %edx
  80047b:	68 81 14 80 00       	push   $0x801481
  800480:	53                   	push   %ebx
  800481:	56                   	push   %esi
  800482:	e8 7c fe ff ff       	call   800303 <printfmt>
  800487:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80048d:	e9 b4 fe ff ff       	jmp    800346 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800492:	8b 45 14             	mov    0x14(%ebp),%eax
  800495:	8d 50 04             	lea    0x4(%eax),%edx
  800498:	89 55 14             	mov    %edx,0x14(%ebp)
  80049b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80049d:	85 ff                	test   %edi,%edi
  80049f:	b8 71 14 80 00       	mov    $0x801471,%eax
  8004a4:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004a7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ab:	0f 8e 94 00 00 00    	jle    800545 <vprintfmt+0x225>
  8004b1:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004b5:	0f 84 98 00 00 00    	je     800553 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bb:	83 ec 08             	sub    $0x8,%esp
  8004be:	ff 75 d0             	pushl  -0x30(%ebp)
  8004c1:	57                   	push   %edi
  8004c2:	e8 86 02 00 00       	call   80074d <strnlen>
  8004c7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ca:	29 c1                	sub    %eax,%ecx
  8004cc:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004cf:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004d2:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004dc:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004de:	eb 0f                	jmp    8004ef <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004e0:	83 ec 08             	sub    $0x8,%esp
  8004e3:	53                   	push   %ebx
  8004e4:	ff 75 e0             	pushl  -0x20(%ebp)
  8004e7:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e9:	83 ef 01             	sub    $0x1,%edi
  8004ec:	83 c4 10             	add    $0x10,%esp
  8004ef:	85 ff                	test   %edi,%edi
  8004f1:	7f ed                	jg     8004e0 <vprintfmt+0x1c0>
  8004f3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004f6:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004f9:	85 c9                	test   %ecx,%ecx
  8004fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800500:	0f 49 c1             	cmovns %ecx,%eax
  800503:	29 c1                	sub    %eax,%ecx
  800505:	89 75 08             	mov    %esi,0x8(%ebp)
  800508:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80050b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80050e:	89 cb                	mov    %ecx,%ebx
  800510:	eb 4d                	jmp    80055f <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800512:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800516:	74 1b                	je     800533 <vprintfmt+0x213>
  800518:	0f be c0             	movsbl %al,%eax
  80051b:	83 e8 20             	sub    $0x20,%eax
  80051e:	83 f8 5e             	cmp    $0x5e,%eax
  800521:	76 10                	jbe    800533 <vprintfmt+0x213>
					putch('?', putdat);
  800523:	83 ec 08             	sub    $0x8,%esp
  800526:	ff 75 0c             	pushl  0xc(%ebp)
  800529:	6a 3f                	push   $0x3f
  80052b:	ff 55 08             	call   *0x8(%ebp)
  80052e:	83 c4 10             	add    $0x10,%esp
  800531:	eb 0d                	jmp    800540 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800533:	83 ec 08             	sub    $0x8,%esp
  800536:	ff 75 0c             	pushl  0xc(%ebp)
  800539:	52                   	push   %edx
  80053a:	ff 55 08             	call   *0x8(%ebp)
  80053d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800540:	83 eb 01             	sub    $0x1,%ebx
  800543:	eb 1a                	jmp    80055f <vprintfmt+0x23f>
  800545:	89 75 08             	mov    %esi,0x8(%ebp)
  800548:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80054b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80054e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800551:	eb 0c                	jmp    80055f <vprintfmt+0x23f>
  800553:	89 75 08             	mov    %esi,0x8(%ebp)
  800556:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800559:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80055c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80055f:	83 c7 01             	add    $0x1,%edi
  800562:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800566:	0f be d0             	movsbl %al,%edx
  800569:	85 d2                	test   %edx,%edx
  80056b:	74 23                	je     800590 <vprintfmt+0x270>
  80056d:	85 f6                	test   %esi,%esi
  80056f:	78 a1                	js     800512 <vprintfmt+0x1f2>
  800571:	83 ee 01             	sub    $0x1,%esi
  800574:	79 9c                	jns    800512 <vprintfmt+0x1f2>
  800576:	89 df                	mov    %ebx,%edi
  800578:	8b 75 08             	mov    0x8(%ebp),%esi
  80057b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80057e:	eb 18                	jmp    800598 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800580:	83 ec 08             	sub    $0x8,%esp
  800583:	53                   	push   %ebx
  800584:	6a 20                	push   $0x20
  800586:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800588:	83 ef 01             	sub    $0x1,%edi
  80058b:	83 c4 10             	add    $0x10,%esp
  80058e:	eb 08                	jmp    800598 <vprintfmt+0x278>
  800590:	89 df                	mov    %ebx,%edi
  800592:	8b 75 08             	mov    0x8(%ebp),%esi
  800595:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800598:	85 ff                	test   %edi,%edi
  80059a:	7f e4                	jg     800580 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80059f:	e9 a2 fd ff ff       	jmp    800346 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005a4:	83 fa 01             	cmp    $0x1,%edx
  8005a7:	7e 16                	jle    8005bf <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8d 50 08             	lea    0x8(%eax),%edx
  8005af:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b2:	8b 50 04             	mov    0x4(%eax),%edx
  8005b5:	8b 00                	mov    (%eax),%eax
  8005b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ba:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005bd:	eb 32                	jmp    8005f1 <vprintfmt+0x2d1>
	else if (lflag)
  8005bf:	85 d2                	test   %edx,%edx
  8005c1:	74 18                	je     8005db <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c6:	8d 50 04             	lea    0x4(%eax),%edx
  8005c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cc:	8b 00                	mov    (%eax),%eax
  8005ce:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d1:	89 c1                	mov    %eax,%ecx
  8005d3:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005d9:	eb 16                	jmp    8005f1 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005db:	8b 45 14             	mov    0x14(%ebp),%eax
  8005de:	8d 50 04             	lea    0x4(%eax),%edx
  8005e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e4:	8b 00                	mov    (%eax),%eax
  8005e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e9:	89 c1                	mov    %eax,%ecx
  8005eb:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ee:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005f4:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005f7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005fc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800600:	79 74                	jns    800676 <vprintfmt+0x356>
				putch('-', putdat);
  800602:	83 ec 08             	sub    $0x8,%esp
  800605:	53                   	push   %ebx
  800606:	6a 2d                	push   $0x2d
  800608:	ff d6                	call   *%esi
				num = -(long long) num;
  80060a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80060d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800610:	f7 d8                	neg    %eax
  800612:	83 d2 00             	adc    $0x0,%edx
  800615:	f7 da                	neg    %edx
  800617:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80061a:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80061f:	eb 55                	jmp    800676 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800621:	8d 45 14             	lea    0x14(%ebp),%eax
  800624:	e8 83 fc ff ff       	call   8002ac <getuint>
			base = 10;
  800629:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80062e:	eb 46                	jmp    800676 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800630:	8d 45 14             	lea    0x14(%ebp),%eax
  800633:	e8 74 fc ff ff       	call   8002ac <getuint>
			base = 8;
  800638:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80063d:	eb 37                	jmp    800676 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80063f:	83 ec 08             	sub    $0x8,%esp
  800642:	53                   	push   %ebx
  800643:	6a 30                	push   $0x30
  800645:	ff d6                	call   *%esi
			putch('x', putdat);
  800647:	83 c4 08             	add    $0x8,%esp
  80064a:	53                   	push   %ebx
  80064b:	6a 78                	push   $0x78
  80064d:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80064f:	8b 45 14             	mov    0x14(%ebp),%eax
  800652:	8d 50 04             	lea    0x4(%eax),%edx
  800655:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800658:	8b 00                	mov    (%eax),%eax
  80065a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80065f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800662:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800667:	eb 0d                	jmp    800676 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800669:	8d 45 14             	lea    0x14(%ebp),%eax
  80066c:	e8 3b fc ff ff       	call   8002ac <getuint>
			base = 16;
  800671:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800676:	83 ec 0c             	sub    $0xc,%esp
  800679:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80067d:	57                   	push   %edi
  80067e:	ff 75 e0             	pushl  -0x20(%ebp)
  800681:	51                   	push   %ecx
  800682:	52                   	push   %edx
  800683:	50                   	push   %eax
  800684:	89 da                	mov    %ebx,%edx
  800686:	89 f0                	mov    %esi,%eax
  800688:	e8 70 fb ff ff       	call   8001fd <printnum>
			break;
  80068d:	83 c4 20             	add    $0x20,%esp
  800690:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800693:	e9 ae fc ff ff       	jmp    800346 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800698:	83 ec 08             	sub    $0x8,%esp
  80069b:	53                   	push   %ebx
  80069c:	51                   	push   %ecx
  80069d:	ff d6                	call   *%esi
			break;
  80069f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006a5:	e9 9c fc ff ff       	jmp    800346 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006aa:	83 ec 08             	sub    $0x8,%esp
  8006ad:	53                   	push   %ebx
  8006ae:	6a 25                	push   $0x25
  8006b0:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b2:	83 c4 10             	add    $0x10,%esp
  8006b5:	eb 03                	jmp    8006ba <vprintfmt+0x39a>
  8006b7:	83 ef 01             	sub    $0x1,%edi
  8006ba:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006be:	75 f7                	jne    8006b7 <vprintfmt+0x397>
  8006c0:	e9 81 fc ff ff       	jmp    800346 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c8:	5b                   	pop    %ebx
  8006c9:	5e                   	pop    %esi
  8006ca:	5f                   	pop    %edi
  8006cb:	5d                   	pop    %ebp
  8006cc:	c3                   	ret    

008006cd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006cd:	55                   	push   %ebp
  8006ce:	89 e5                	mov    %esp,%ebp
  8006d0:	83 ec 18             	sub    $0x18,%esp
  8006d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006dc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006ea:	85 c0                	test   %eax,%eax
  8006ec:	74 26                	je     800714 <vsnprintf+0x47>
  8006ee:	85 d2                	test   %edx,%edx
  8006f0:	7e 22                	jle    800714 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f2:	ff 75 14             	pushl  0x14(%ebp)
  8006f5:	ff 75 10             	pushl  0x10(%ebp)
  8006f8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006fb:	50                   	push   %eax
  8006fc:	68 e6 02 80 00       	push   $0x8002e6
  800701:	e8 1a fc ff ff       	call   800320 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800706:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800709:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80070c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80070f:	83 c4 10             	add    $0x10,%esp
  800712:	eb 05                	jmp    800719 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800714:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800719:	c9                   	leave  
  80071a:	c3                   	ret    

0080071b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80071b:	55                   	push   %ebp
  80071c:	89 e5                	mov    %esp,%ebp
  80071e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800721:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800724:	50                   	push   %eax
  800725:	ff 75 10             	pushl  0x10(%ebp)
  800728:	ff 75 0c             	pushl  0xc(%ebp)
  80072b:	ff 75 08             	pushl  0x8(%ebp)
  80072e:	e8 9a ff ff ff       	call   8006cd <vsnprintf>
	va_end(ap);

	return rc;
}
  800733:	c9                   	leave  
  800734:	c3                   	ret    

00800735 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800735:	55                   	push   %ebp
  800736:	89 e5                	mov    %esp,%ebp
  800738:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80073b:	b8 00 00 00 00       	mov    $0x0,%eax
  800740:	eb 03                	jmp    800745 <strlen+0x10>
		n++;
  800742:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800745:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800749:	75 f7                	jne    800742 <strlen+0xd>
		n++;
	return n;
}
  80074b:	5d                   	pop    %ebp
  80074c:	c3                   	ret    

0080074d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80074d:	55                   	push   %ebp
  80074e:	89 e5                	mov    %esp,%ebp
  800750:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800753:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800756:	ba 00 00 00 00       	mov    $0x0,%edx
  80075b:	eb 03                	jmp    800760 <strnlen+0x13>
		n++;
  80075d:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800760:	39 c2                	cmp    %eax,%edx
  800762:	74 08                	je     80076c <strnlen+0x1f>
  800764:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800768:	75 f3                	jne    80075d <strnlen+0x10>
  80076a:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80076c:	5d                   	pop    %ebp
  80076d:	c3                   	ret    

0080076e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
  800771:	53                   	push   %ebx
  800772:	8b 45 08             	mov    0x8(%ebp),%eax
  800775:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800778:	89 c2                	mov    %eax,%edx
  80077a:	83 c2 01             	add    $0x1,%edx
  80077d:	83 c1 01             	add    $0x1,%ecx
  800780:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800784:	88 5a ff             	mov    %bl,-0x1(%edx)
  800787:	84 db                	test   %bl,%bl
  800789:	75 ef                	jne    80077a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80078b:	5b                   	pop    %ebx
  80078c:	5d                   	pop    %ebp
  80078d:	c3                   	ret    

0080078e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80078e:	55                   	push   %ebp
  80078f:	89 e5                	mov    %esp,%ebp
  800791:	53                   	push   %ebx
  800792:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800795:	53                   	push   %ebx
  800796:	e8 9a ff ff ff       	call   800735 <strlen>
  80079b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80079e:	ff 75 0c             	pushl  0xc(%ebp)
  8007a1:	01 d8                	add    %ebx,%eax
  8007a3:	50                   	push   %eax
  8007a4:	e8 c5 ff ff ff       	call   80076e <strcpy>
	return dst;
}
  8007a9:	89 d8                	mov    %ebx,%eax
  8007ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ae:	c9                   	leave  
  8007af:	c3                   	ret    

008007b0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	56                   	push   %esi
  8007b4:	53                   	push   %ebx
  8007b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007bb:	89 f3                	mov    %esi,%ebx
  8007bd:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c0:	89 f2                	mov    %esi,%edx
  8007c2:	eb 0f                	jmp    8007d3 <strncpy+0x23>
		*dst++ = *src;
  8007c4:	83 c2 01             	add    $0x1,%edx
  8007c7:	0f b6 01             	movzbl (%ecx),%eax
  8007ca:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007cd:	80 39 01             	cmpb   $0x1,(%ecx)
  8007d0:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d3:	39 da                	cmp    %ebx,%edx
  8007d5:	75 ed                	jne    8007c4 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007d7:	89 f0                	mov    %esi,%eax
  8007d9:	5b                   	pop    %ebx
  8007da:	5e                   	pop    %esi
  8007db:	5d                   	pop    %ebp
  8007dc:	c3                   	ret    

008007dd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	56                   	push   %esi
  8007e1:	53                   	push   %ebx
  8007e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e8:	8b 55 10             	mov    0x10(%ebp),%edx
  8007eb:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ed:	85 d2                	test   %edx,%edx
  8007ef:	74 21                	je     800812 <strlcpy+0x35>
  8007f1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007f5:	89 f2                	mov    %esi,%edx
  8007f7:	eb 09                	jmp    800802 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007f9:	83 c2 01             	add    $0x1,%edx
  8007fc:	83 c1 01             	add    $0x1,%ecx
  8007ff:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800802:	39 c2                	cmp    %eax,%edx
  800804:	74 09                	je     80080f <strlcpy+0x32>
  800806:	0f b6 19             	movzbl (%ecx),%ebx
  800809:	84 db                	test   %bl,%bl
  80080b:	75 ec                	jne    8007f9 <strlcpy+0x1c>
  80080d:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80080f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800812:	29 f0                	sub    %esi,%eax
}
  800814:	5b                   	pop    %ebx
  800815:	5e                   	pop    %esi
  800816:	5d                   	pop    %ebp
  800817:	c3                   	ret    

00800818 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800821:	eb 06                	jmp    800829 <strcmp+0x11>
		p++, q++;
  800823:	83 c1 01             	add    $0x1,%ecx
  800826:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800829:	0f b6 01             	movzbl (%ecx),%eax
  80082c:	84 c0                	test   %al,%al
  80082e:	74 04                	je     800834 <strcmp+0x1c>
  800830:	3a 02                	cmp    (%edx),%al
  800832:	74 ef                	je     800823 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800834:	0f b6 c0             	movzbl %al,%eax
  800837:	0f b6 12             	movzbl (%edx),%edx
  80083a:	29 d0                	sub    %edx,%eax
}
  80083c:	5d                   	pop    %ebp
  80083d:	c3                   	ret    

0080083e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	53                   	push   %ebx
  800842:	8b 45 08             	mov    0x8(%ebp),%eax
  800845:	8b 55 0c             	mov    0xc(%ebp),%edx
  800848:	89 c3                	mov    %eax,%ebx
  80084a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80084d:	eb 06                	jmp    800855 <strncmp+0x17>
		n--, p++, q++;
  80084f:	83 c0 01             	add    $0x1,%eax
  800852:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800855:	39 d8                	cmp    %ebx,%eax
  800857:	74 15                	je     80086e <strncmp+0x30>
  800859:	0f b6 08             	movzbl (%eax),%ecx
  80085c:	84 c9                	test   %cl,%cl
  80085e:	74 04                	je     800864 <strncmp+0x26>
  800860:	3a 0a                	cmp    (%edx),%cl
  800862:	74 eb                	je     80084f <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800864:	0f b6 00             	movzbl (%eax),%eax
  800867:	0f b6 12             	movzbl (%edx),%edx
  80086a:	29 d0                	sub    %edx,%eax
  80086c:	eb 05                	jmp    800873 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80086e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800873:	5b                   	pop    %ebx
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	8b 45 08             	mov    0x8(%ebp),%eax
  80087c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800880:	eb 07                	jmp    800889 <strchr+0x13>
		if (*s == c)
  800882:	38 ca                	cmp    %cl,%dl
  800884:	74 0f                	je     800895 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800886:	83 c0 01             	add    $0x1,%eax
  800889:	0f b6 10             	movzbl (%eax),%edx
  80088c:	84 d2                	test   %dl,%dl
  80088e:	75 f2                	jne    800882 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800890:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800895:	5d                   	pop    %ebp
  800896:	c3                   	ret    

00800897 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	8b 45 08             	mov    0x8(%ebp),%eax
  80089d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a1:	eb 03                	jmp    8008a6 <strfind+0xf>
  8008a3:	83 c0 01             	add    $0x1,%eax
  8008a6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008a9:	38 ca                	cmp    %cl,%dl
  8008ab:	74 04                	je     8008b1 <strfind+0x1a>
  8008ad:	84 d2                	test   %dl,%dl
  8008af:	75 f2                	jne    8008a3 <strfind+0xc>
			break;
	return (char *) s;
}
  8008b1:	5d                   	pop    %ebp
  8008b2:	c3                   	ret    

008008b3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	57                   	push   %edi
  8008b7:	56                   	push   %esi
  8008b8:	53                   	push   %ebx
  8008b9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008bc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008bf:	85 c9                	test   %ecx,%ecx
  8008c1:	74 36                	je     8008f9 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008c3:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008c9:	75 28                	jne    8008f3 <memset+0x40>
  8008cb:	f6 c1 03             	test   $0x3,%cl
  8008ce:	75 23                	jne    8008f3 <memset+0x40>
		c &= 0xFF;
  8008d0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008d4:	89 d3                	mov    %edx,%ebx
  8008d6:	c1 e3 08             	shl    $0x8,%ebx
  8008d9:	89 d6                	mov    %edx,%esi
  8008db:	c1 e6 18             	shl    $0x18,%esi
  8008de:	89 d0                	mov    %edx,%eax
  8008e0:	c1 e0 10             	shl    $0x10,%eax
  8008e3:	09 f0                	or     %esi,%eax
  8008e5:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008e7:	89 d8                	mov    %ebx,%eax
  8008e9:	09 d0                	or     %edx,%eax
  8008eb:	c1 e9 02             	shr    $0x2,%ecx
  8008ee:	fc                   	cld    
  8008ef:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f1:	eb 06                	jmp    8008f9 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f6:	fc                   	cld    
  8008f7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008f9:	89 f8                	mov    %edi,%eax
  8008fb:	5b                   	pop    %ebx
  8008fc:	5e                   	pop    %esi
  8008fd:	5f                   	pop    %edi
  8008fe:	5d                   	pop    %ebp
  8008ff:	c3                   	ret    

00800900 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	57                   	push   %edi
  800904:	56                   	push   %esi
  800905:	8b 45 08             	mov    0x8(%ebp),%eax
  800908:	8b 75 0c             	mov    0xc(%ebp),%esi
  80090b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80090e:	39 c6                	cmp    %eax,%esi
  800910:	73 35                	jae    800947 <memmove+0x47>
  800912:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800915:	39 d0                	cmp    %edx,%eax
  800917:	73 2e                	jae    800947 <memmove+0x47>
		s += n;
		d += n;
  800919:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80091c:	89 d6                	mov    %edx,%esi
  80091e:	09 fe                	or     %edi,%esi
  800920:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800926:	75 13                	jne    80093b <memmove+0x3b>
  800928:	f6 c1 03             	test   $0x3,%cl
  80092b:	75 0e                	jne    80093b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80092d:	83 ef 04             	sub    $0x4,%edi
  800930:	8d 72 fc             	lea    -0x4(%edx),%esi
  800933:	c1 e9 02             	shr    $0x2,%ecx
  800936:	fd                   	std    
  800937:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800939:	eb 09                	jmp    800944 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80093b:	83 ef 01             	sub    $0x1,%edi
  80093e:	8d 72 ff             	lea    -0x1(%edx),%esi
  800941:	fd                   	std    
  800942:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800944:	fc                   	cld    
  800945:	eb 1d                	jmp    800964 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800947:	89 f2                	mov    %esi,%edx
  800949:	09 c2                	or     %eax,%edx
  80094b:	f6 c2 03             	test   $0x3,%dl
  80094e:	75 0f                	jne    80095f <memmove+0x5f>
  800950:	f6 c1 03             	test   $0x3,%cl
  800953:	75 0a                	jne    80095f <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800955:	c1 e9 02             	shr    $0x2,%ecx
  800958:	89 c7                	mov    %eax,%edi
  80095a:	fc                   	cld    
  80095b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095d:	eb 05                	jmp    800964 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80095f:	89 c7                	mov    %eax,%edi
  800961:	fc                   	cld    
  800962:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800964:	5e                   	pop    %esi
  800965:	5f                   	pop    %edi
  800966:	5d                   	pop    %ebp
  800967:	c3                   	ret    

00800968 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80096b:	ff 75 10             	pushl  0x10(%ebp)
  80096e:	ff 75 0c             	pushl  0xc(%ebp)
  800971:	ff 75 08             	pushl  0x8(%ebp)
  800974:	e8 87 ff ff ff       	call   800900 <memmove>
}
  800979:	c9                   	leave  
  80097a:	c3                   	ret    

0080097b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	56                   	push   %esi
  80097f:	53                   	push   %ebx
  800980:	8b 45 08             	mov    0x8(%ebp),%eax
  800983:	8b 55 0c             	mov    0xc(%ebp),%edx
  800986:	89 c6                	mov    %eax,%esi
  800988:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80098b:	eb 1a                	jmp    8009a7 <memcmp+0x2c>
		if (*s1 != *s2)
  80098d:	0f b6 08             	movzbl (%eax),%ecx
  800990:	0f b6 1a             	movzbl (%edx),%ebx
  800993:	38 d9                	cmp    %bl,%cl
  800995:	74 0a                	je     8009a1 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800997:	0f b6 c1             	movzbl %cl,%eax
  80099a:	0f b6 db             	movzbl %bl,%ebx
  80099d:	29 d8                	sub    %ebx,%eax
  80099f:	eb 0f                	jmp    8009b0 <memcmp+0x35>
		s1++, s2++;
  8009a1:	83 c0 01             	add    $0x1,%eax
  8009a4:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a7:	39 f0                	cmp    %esi,%eax
  8009a9:	75 e2                	jne    80098d <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b0:	5b                   	pop    %ebx
  8009b1:	5e                   	pop    %esi
  8009b2:	5d                   	pop    %ebp
  8009b3:	c3                   	ret    

008009b4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	53                   	push   %ebx
  8009b8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009bb:	89 c1                	mov    %eax,%ecx
  8009bd:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c0:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009c4:	eb 0a                	jmp    8009d0 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c6:	0f b6 10             	movzbl (%eax),%edx
  8009c9:	39 da                	cmp    %ebx,%edx
  8009cb:	74 07                	je     8009d4 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009cd:	83 c0 01             	add    $0x1,%eax
  8009d0:	39 c8                	cmp    %ecx,%eax
  8009d2:	72 f2                	jb     8009c6 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009d4:	5b                   	pop    %ebx
  8009d5:	5d                   	pop    %ebp
  8009d6:	c3                   	ret    

008009d7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	57                   	push   %edi
  8009db:	56                   	push   %esi
  8009dc:	53                   	push   %ebx
  8009dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e3:	eb 03                	jmp    8009e8 <strtol+0x11>
		s++;
  8009e5:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e8:	0f b6 01             	movzbl (%ecx),%eax
  8009eb:	3c 20                	cmp    $0x20,%al
  8009ed:	74 f6                	je     8009e5 <strtol+0xe>
  8009ef:	3c 09                	cmp    $0x9,%al
  8009f1:	74 f2                	je     8009e5 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009f3:	3c 2b                	cmp    $0x2b,%al
  8009f5:	75 0a                	jne    800a01 <strtol+0x2a>
		s++;
  8009f7:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009fa:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ff:	eb 11                	jmp    800a12 <strtol+0x3b>
  800a01:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a06:	3c 2d                	cmp    $0x2d,%al
  800a08:	75 08                	jne    800a12 <strtol+0x3b>
		s++, neg = 1;
  800a0a:	83 c1 01             	add    $0x1,%ecx
  800a0d:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a12:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a18:	75 15                	jne    800a2f <strtol+0x58>
  800a1a:	80 39 30             	cmpb   $0x30,(%ecx)
  800a1d:	75 10                	jne    800a2f <strtol+0x58>
  800a1f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a23:	75 7c                	jne    800aa1 <strtol+0xca>
		s += 2, base = 16;
  800a25:	83 c1 02             	add    $0x2,%ecx
  800a28:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a2d:	eb 16                	jmp    800a45 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a2f:	85 db                	test   %ebx,%ebx
  800a31:	75 12                	jne    800a45 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a33:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a38:	80 39 30             	cmpb   $0x30,(%ecx)
  800a3b:	75 08                	jne    800a45 <strtol+0x6e>
		s++, base = 8;
  800a3d:	83 c1 01             	add    $0x1,%ecx
  800a40:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a45:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a4d:	0f b6 11             	movzbl (%ecx),%edx
  800a50:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a53:	89 f3                	mov    %esi,%ebx
  800a55:	80 fb 09             	cmp    $0x9,%bl
  800a58:	77 08                	ja     800a62 <strtol+0x8b>
			dig = *s - '0';
  800a5a:	0f be d2             	movsbl %dl,%edx
  800a5d:	83 ea 30             	sub    $0x30,%edx
  800a60:	eb 22                	jmp    800a84 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a62:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a65:	89 f3                	mov    %esi,%ebx
  800a67:	80 fb 19             	cmp    $0x19,%bl
  800a6a:	77 08                	ja     800a74 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a6c:	0f be d2             	movsbl %dl,%edx
  800a6f:	83 ea 57             	sub    $0x57,%edx
  800a72:	eb 10                	jmp    800a84 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a74:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a77:	89 f3                	mov    %esi,%ebx
  800a79:	80 fb 19             	cmp    $0x19,%bl
  800a7c:	77 16                	ja     800a94 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a7e:	0f be d2             	movsbl %dl,%edx
  800a81:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a84:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a87:	7d 0b                	jge    800a94 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a89:	83 c1 01             	add    $0x1,%ecx
  800a8c:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a90:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a92:	eb b9                	jmp    800a4d <strtol+0x76>

	if (endptr)
  800a94:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a98:	74 0d                	je     800aa7 <strtol+0xd0>
		*endptr = (char *) s;
  800a9a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a9d:	89 0e                	mov    %ecx,(%esi)
  800a9f:	eb 06                	jmp    800aa7 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa1:	85 db                	test   %ebx,%ebx
  800aa3:	74 98                	je     800a3d <strtol+0x66>
  800aa5:	eb 9e                	jmp    800a45 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aa7:	89 c2                	mov    %eax,%edx
  800aa9:	f7 da                	neg    %edx
  800aab:	85 ff                	test   %edi,%edi
  800aad:	0f 45 c2             	cmovne %edx,%eax
}
  800ab0:	5b                   	pop    %ebx
  800ab1:	5e                   	pop    %esi
  800ab2:	5f                   	pop    %edi
  800ab3:	5d                   	pop    %ebp
  800ab4:	c3                   	ret    

00800ab5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ab5:	55                   	push   %ebp
  800ab6:	89 e5                	mov    %esp,%ebp
  800ab8:	57                   	push   %edi
  800ab9:	56                   	push   %esi
  800aba:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800abb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ac3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac6:	89 c3                	mov    %eax,%ebx
  800ac8:	89 c7                	mov    %eax,%edi
  800aca:	89 c6                	mov    %eax,%esi
  800acc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ace:	5b                   	pop    %ebx
  800acf:	5e                   	pop    %esi
  800ad0:	5f                   	pop    %edi
  800ad1:	5d                   	pop    %ebp
  800ad2:	c3                   	ret    

00800ad3 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	57                   	push   %edi
  800ad7:	56                   	push   %esi
  800ad8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad9:	ba 00 00 00 00       	mov    $0x0,%edx
  800ade:	b8 01 00 00 00       	mov    $0x1,%eax
  800ae3:	89 d1                	mov    %edx,%ecx
  800ae5:	89 d3                	mov    %edx,%ebx
  800ae7:	89 d7                	mov    %edx,%edi
  800ae9:	89 d6                	mov    %edx,%esi
  800aeb:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aed:	5b                   	pop    %ebx
  800aee:	5e                   	pop    %esi
  800aef:	5f                   	pop    %edi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	57                   	push   %edi
  800af6:	56                   	push   %esi
  800af7:	53                   	push   %ebx
  800af8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b00:	b8 03 00 00 00       	mov    $0x3,%eax
  800b05:	8b 55 08             	mov    0x8(%ebp),%edx
  800b08:	89 cb                	mov    %ecx,%ebx
  800b0a:	89 cf                	mov    %ecx,%edi
  800b0c:	89 ce                	mov    %ecx,%esi
  800b0e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b10:	85 c0                	test   %eax,%eax
  800b12:	7e 17                	jle    800b2b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b14:	83 ec 0c             	sub    $0xc,%esp
  800b17:	50                   	push   %eax
  800b18:	6a 03                	push   $0x3
  800b1a:	68 a8 16 80 00       	push   $0x8016a8
  800b1f:	6a 23                	push   $0x23
  800b21:	68 c5 16 80 00       	push   $0x8016c5
  800b26:	e8 62 05 00 00       	call   80108d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b2e:	5b                   	pop    %ebx
  800b2f:	5e                   	pop    %esi
  800b30:	5f                   	pop    %edi
  800b31:	5d                   	pop    %ebp
  800b32:	c3                   	ret    

00800b33 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b33:	55                   	push   %ebp
  800b34:	89 e5                	mov    %esp,%ebp
  800b36:	57                   	push   %edi
  800b37:	56                   	push   %esi
  800b38:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b39:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3e:	b8 02 00 00 00       	mov    $0x2,%eax
  800b43:	89 d1                	mov    %edx,%ecx
  800b45:	89 d3                	mov    %edx,%ebx
  800b47:	89 d7                	mov    %edx,%edi
  800b49:	89 d6                	mov    %edx,%esi
  800b4b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b4d:	5b                   	pop    %ebx
  800b4e:	5e                   	pop    %esi
  800b4f:	5f                   	pop    %edi
  800b50:	5d                   	pop    %ebp
  800b51:	c3                   	ret    

00800b52 <sys_yield>:

void
sys_yield(void)
{
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	57                   	push   %edi
  800b56:	56                   	push   %esi
  800b57:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b58:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b62:	89 d1                	mov    %edx,%ecx
  800b64:	89 d3                	mov    %edx,%ebx
  800b66:	89 d7                	mov    %edx,%edi
  800b68:	89 d6                	mov    %edx,%esi
  800b6a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b6c:	5b                   	pop    %ebx
  800b6d:	5e                   	pop    %esi
  800b6e:	5f                   	pop    %edi
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	57                   	push   %edi
  800b75:	56                   	push   %esi
  800b76:	53                   	push   %ebx
  800b77:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7a:	be 00 00 00 00       	mov    $0x0,%esi
  800b7f:	b8 04 00 00 00       	mov    $0x4,%eax
  800b84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b87:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b8d:	89 f7                	mov    %esi,%edi
  800b8f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b91:	85 c0                	test   %eax,%eax
  800b93:	7e 17                	jle    800bac <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b95:	83 ec 0c             	sub    $0xc,%esp
  800b98:	50                   	push   %eax
  800b99:	6a 04                	push   $0x4
  800b9b:	68 a8 16 80 00       	push   $0x8016a8
  800ba0:	6a 23                	push   $0x23
  800ba2:	68 c5 16 80 00       	push   $0x8016c5
  800ba7:	e8 e1 04 00 00       	call   80108d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800baf:	5b                   	pop    %ebx
  800bb0:	5e                   	pop    %esi
  800bb1:	5f                   	pop    %edi
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	57                   	push   %edi
  800bb8:	56                   	push   %esi
  800bb9:	53                   	push   %ebx
  800bba:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbd:	b8 05 00 00 00       	mov    $0x5,%eax
  800bc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bcb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bce:	8b 75 18             	mov    0x18(%ebp),%esi
  800bd1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bd3:	85 c0                	test   %eax,%eax
  800bd5:	7e 17                	jle    800bee <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd7:	83 ec 0c             	sub    $0xc,%esp
  800bda:	50                   	push   %eax
  800bdb:	6a 05                	push   $0x5
  800bdd:	68 a8 16 80 00       	push   $0x8016a8
  800be2:	6a 23                	push   $0x23
  800be4:	68 c5 16 80 00       	push   $0x8016c5
  800be9:	e8 9f 04 00 00       	call   80108d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	5f                   	pop    %edi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    

00800bf6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	57                   	push   %edi
  800bfa:	56                   	push   %esi
  800bfb:	53                   	push   %ebx
  800bfc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bff:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c04:	b8 06 00 00 00       	mov    $0x6,%eax
  800c09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0f:	89 df                	mov    %ebx,%edi
  800c11:	89 de                	mov    %ebx,%esi
  800c13:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c15:	85 c0                	test   %eax,%eax
  800c17:	7e 17                	jle    800c30 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c19:	83 ec 0c             	sub    $0xc,%esp
  800c1c:	50                   	push   %eax
  800c1d:	6a 06                	push   $0x6
  800c1f:	68 a8 16 80 00       	push   $0x8016a8
  800c24:	6a 23                	push   $0x23
  800c26:	68 c5 16 80 00       	push   $0x8016c5
  800c2b:	e8 5d 04 00 00       	call   80108d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c33:	5b                   	pop    %ebx
  800c34:	5e                   	pop    %esi
  800c35:	5f                   	pop    %edi
  800c36:	5d                   	pop    %ebp
  800c37:	c3                   	ret    

00800c38 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	57                   	push   %edi
  800c3c:	56                   	push   %esi
  800c3d:	53                   	push   %ebx
  800c3e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c41:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c46:	b8 08 00 00 00       	mov    $0x8,%eax
  800c4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c51:	89 df                	mov    %ebx,%edi
  800c53:	89 de                	mov    %ebx,%esi
  800c55:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c57:	85 c0                	test   %eax,%eax
  800c59:	7e 17                	jle    800c72 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5b:	83 ec 0c             	sub    $0xc,%esp
  800c5e:	50                   	push   %eax
  800c5f:	6a 08                	push   $0x8
  800c61:	68 a8 16 80 00       	push   $0x8016a8
  800c66:	6a 23                	push   $0x23
  800c68:	68 c5 16 80 00       	push   $0x8016c5
  800c6d:	e8 1b 04 00 00       	call   80108d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c75:	5b                   	pop    %ebx
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	57                   	push   %edi
  800c7e:	56                   	push   %esi
  800c7f:	53                   	push   %ebx
  800c80:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c83:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c88:	b8 09 00 00 00       	mov    $0x9,%eax
  800c8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c90:	8b 55 08             	mov    0x8(%ebp),%edx
  800c93:	89 df                	mov    %ebx,%edi
  800c95:	89 de                	mov    %ebx,%esi
  800c97:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c99:	85 c0                	test   %eax,%eax
  800c9b:	7e 17                	jle    800cb4 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9d:	83 ec 0c             	sub    $0xc,%esp
  800ca0:	50                   	push   %eax
  800ca1:	6a 09                	push   $0x9
  800ca3:	68 a8 16 80 00       	push   $0x8016a8
  800ca8:	6a 23                	push   $0x23
  800caa:	68 c5 16 80 00       	push   $0x8016c5
  800caf:	e8 d9 03 00 00       	call   80108d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5f                   	pop    %edi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	57                   	push   %edi
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc2:	be 00 00 00 00       	mov    $0x0,%esi
  800cc7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ccc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cda:	5b                   	pop    %ebx
  800cdb:	5e                   	pop    %esi
  800cdc:	5f                   	pop    %edi
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	57                   	push   %edi
  800ce3:	56                   	push   %esi
  800ce4:	53                   	push   %ebx
  800ce5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ced:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf5:	89 cb                	mov    %ecx,%ebx
  800cf7:	89 cf                	mov    %ecx,%edi
  800cf9:	89 ce                	mov    %ecx,%esi
  800cfb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cfd:	85 c0                	test   %eax,%eax
  800cff:	7e 17                	jle    800d18 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d01:	83 ec 0c             	sub    $0xc,%esp
  800d04:	50                   	push   %eax
  800d05:	6a 0c                	push   $0xc
  800d07:	68 a8 16 80 00       	push   $0x8016a8
  800d0c:	6a 23                	push   $0x23
  800d0e:	68 c5 16 80 00       	push   $0x8016c5
  800d13:	e8 75 03 00 00       	call   80108d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1b:	5b                   	pop    %ebx
  800d1c:	5e                   	pop    %esi
  800d1d:	5f                   	pop    %edi
  800d1e:	5d                   	pop    %ebp
  800d1f:	c3                   	ret    

00800d20 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	53                   	push   %ebx
  800d24:	83 ec 04             	sub    $0x4,%esp
  800d27:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
	void *fault_va = ROUNDDOWN(addr, PGSIZE);
  800d2a:	8b 18                	mov    (%eax),%ebx
  800d2c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	if (!(err & FEC_WR) || (uvpt[PGNUM(fault_va)] & perm) != perm)
  800d32:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d36:	74 18                	je     800d50 <pgfault+0x30>
  800d38:	89 d8                	mov    %ebx,%eax
  800d3a:	c1 e8 0c             	shr    $0xc,%eax
  800d3d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d44:	25 05 08 00 00       	and    $0x805,%eax
  800d49:	3d 05 08 00 00       	cmp    $0x805,%eax
  800d4e:	74 14                	je     800d64 <pgfault+0x44>
		panic("invalid faulting access");
  800d50:	83 ec 04             	sub    $0x4,%esp
  800d53:	68 d3 16 80 00       	push   $0x8016d3
  800d58:	6a 1d                	push   $0x1d
  800d5a:	68 eb 16 80 00       	push   $0x8016eb
  800d5f:	e8 29 03 00 00       	call   80108d <_panic>
	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	if ((r = sys_page_alloc(0, (void *) PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800d64:	83 ec 04             	sub    $0x4,%esp
  800d67:	6a 07                	push   $0x7
  800d69:	68 00 f0 7f 00       	push   $0x7ff000
  800d6e:	6a 00                	push   $0x0
  800d70:	e8 fc fd ff ff       	call   800b71 <sys_page_alloc>
  800d75:	83 c4 10             	add    $0x10,%esp
  800d78:	85 c0                	test   %eax,%eax
  800d7a:	79 12                	jns    800d8e <pgfault+0x6e>
		panic("sys_page_alloc: %e", r);
  800d7c:	50                   	push   %eax
  800d7d:	68 f6 16 80 00       	push   $0x8016f6
  800d82:	6a 25                	push   $0x25
  800d84:	68 eb 16 80 00       	push   $0x8016eb
  800d89:	e8 ff 02 00 00       	call   80108d <_panic>
	memmove((void *) PFTEMP, fault_va, PGSIZE);
  800d8e:	83 ec 04             	sub    $0x4,%esp
  800d91:	68 00 10 00 00       	push   $0x1000
  800d96:	53                   	push   %ebx
  800d97:	68 00 f0 7f 00       	push   $0x7ff000
  800d9c:	e8 5f fb ff ff       	call   800900 <memmove>
	if ((r = sys_page_map(0, (void *) PFTEMP, 0, fault_va, PTE_P|PTE_U|PTE_W)) < 0)
  800da1:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800da8:	53                   	push   %ebx
  800da9:	6a 00                	push   $0x0
  800dab:	68 00 f0 7f 00       	push   $0x7ff000
  800db0:	6a 00                	push   $0x0
  800db2:	e8 fd fd ff ff       	call   800bb4 <sys_page_map>
  800db7:	83 c4 20             	add    $0x20,%esp
  800dba:	85 c0                	test   %eax,%eax
  800dbc:	79 12                	jns    800dd0 <pgfault+0xb0>
		panic("sys_page_map: %e", r);
  800dbe:	50                   	push   %eax
  800dbf:	68 09 17 80 00       	push   $0x801709
  800dc4:	6a 28                	push   $0x28
  800dc6:	68 eb 16 80 00       	push   $0x8016eb
  800dcb:	e8 bd 02 00 00       	call   80108d <_panic>
	if ((r = sys_page_unmap(0, (void *) PFTEMP)) < 0)
  800dd0:	83 ec 08             	sub    $0x8,%esp
  800dd3:	68 00 f0 7f 00       	push   $0x7ff000
  800dd8:	6a 00                	push   $0x0
  800dda:	e8 17 fe ff ff       	call   800bf6 <sys_page_unmap>
  800ddf:	83 c4 10             	add    $0x10,%esp
  800de2:	85 c0                	test   %eax,%eax
  800de4:	79 12                	jns    800df8 <pgfault+0xd8>
		panic("sys_page_unmap: %e", r);
  800de6:	50                   	push   %eax
  800de7:	68 1a 17 80 00       	push   $0x80171a
  800dec:	6a 2a                	push   $0x2a
  800dee:	68 eb 16 80 00       	push   $0x8016eb
  800df3:	e8 95 02 00 00       	call   80108d <_panic>
}
  800df8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dfb:	c9                   	leave  
  800dfc:	c3                   	ret    

00800dfd <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{	
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	57                   	push   %edi
  800e01:	56                   	push   %esi
  800e02:	53                   	push   %ebx
  800e03:	83 ec 28             	sub    $0x28,%esp
	envid_t envid;
	uint8_t *addr, *end_addr;
	int ret;

	set_pgfault_handler(&pgfault);
  800e06:	68 20 0d 80 00       	push   $0x800d20
  800e0b:	e8 c3 02 00 00       	call   8010d3 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e10:	b8 07 00 00 00       	mov    $0x7,%eax
  800e15:	cd 30                	int    $0x30
  800e17:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	
	envid = sys_exofork();
	if (envid < 0) 
  800e1a:	83 c4 10             	add    $0x10,%esp
  800e1d:	85 c0                	test   %eax,%eax
  800e1f:	0f 88 ed 00 00 00    	js     800f12 <fork+0x115>
  800e25:	89 c7                	mov    %eax,%edi
  800e27:	bb 00 00 00 00       	mov    $0x0,%ebx
		return envid;
	if (envid == 0) {
  800e2c:	85 c0                	test   %eax,%eax
  800e2e:	75 21                	jne    800e51 <fork+0x54>
		// We are the child
		thisenv = &envs[ENVX(sys_getenvid())];
  800e30:	e8 fe fc ff ff       	call   800b33 <sys_getenvid>
  800e35:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e3a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e3d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e42:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  800e47:	ba 00 00 00 00       	mov    $0x0,%edx
  800e4c:	e9 22 01 00 00       	jmp    800f73 <fork+0x176>
	}
	
	end_addr = (uint8_t *) (UXSTACKTOP - PGSIZE);
	for (addr = 0; addr < end_addr; addr += PGSIZE) {	
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
  800e51:	89 d8                	mov    %ebx,%eax
  800e53:	c1 e8 16             	shr    $0x16,%eax
  800e56:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e5d:	a8 01                	test   $0x1,%al
  800e5f:	74 51                	je     800eb2 <fork+0xb5>
  800e61:	89 d8                	mov    %ebx,%eax
  800e63:	c1 e8 0c             	shr    $0xc,%eax
  800e66:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e6d:	f6 c2 01             	test   $0x1,%dl
  800e70:	74 40                	je     800eb2 <fork+0xb5>
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
	void *addr = (void *) (pn * PGSIZE);
  800e72:	89 c6                	mov    %eax,%esi
  800e74:	c1 e6 0c             	shl    $0xc,%esi
	uint32_t perm = PTE_U | PTE_P;
	int r;

	if (uvpt[pn] & (PTE_W | PTE_COW)) 
  800e77:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e7e:	a9 02 08 00 00       	test   $0x802,%eax
  800e83:	0f 85 cc 00 00 00    	jne    800f55 <fork+0x158>
  800e89:	e9 89 00 00 00       	jmp    800f17 <fork+0x11a>
		perm |= PTE_COW;
	
	if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
		panic("sys_page_map: %e", r);
  800e8e:	50                   	push   %eax
  800e8f:	68 09 17 80 00       	push   $0x801709
  800e94:	6a 43                	push   $0x43
  800e96:	68 eb 16 80 00       	push   $0x8016eb
  800e9b:	e8 ed 01 00 00       	call   80108d <_panic>
	
	if (!(perm & PTE_COW))
		return 0;
	
	if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0)
		panic("sys_page_map: %e", r);
  800ea0:	50                   	push   %eax
  800ea1:	68 09 17 80 00       	push   $0x801709
  800ea6:	6a 49                	push   $0x49
  800ea8:	68 eb 16 80 00       	push   $0x8016eb
  800ead:	e8 db 01 00 00       	call   80108d <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	end_addr = (uint8_t *) (UXSTACKTOP - PGSIZE);
	for (addr = 0; addr < end_addr; addr += PGSIZE) {	
  800eb2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800eb8:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800ebe:	75 91                	jne    800e51 <fork+0x54>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
			duppage(envid, PGNUM(addr));
	}

	ret = sys_page_alloc(envid, 
  800ec0:	83 ec 04             	sub    $0x4,%esp
  800ec3:	6a 07                	push   $0x7
  800ec5:	68 00 f0 bf ee       	push   $0xeebff000
  800eca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ecd:	57                   	push   %edi
  800ece:	e8 9e fc ff ff       	call   800b71 <sys_page_alloc>
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
  800ed3:	83 c4 10             	add    $0x10,%esp
		return ret;
  800ed6:	89 c2                	mov    %eax,%edx
			duppage(envid, PGNUM(addr));
	}

	ret = sys_page_alloc(envid, 
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
  800ed8:	85 c0                	test   %eax,%eax
  800eda:	0f 88 93 00 00 00    	js     800f73 <fork+0x176>
		return ret;
		
	if ((ret = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  800ee0:	a1 08 20 80 00       	mov    0x802008,%eax
  800ee5:	8b 40 64             	mov    0x64(%eax),%eax
  800ee8:	83 ec 08             	sub    $0x8,%esp
  800eeb:	50                   	push   %eax
  800eec:	57                   	push   %edi
  800eed:	e8 88 fd ff ff       	call   800c7a <sys_env_set_pgfault_upcall>
  800ef2:	83 c4 10             	add    $0x10,%esp
		return ret;
  800ef5:	89 c2                	mov    %eax,%edx
	ret = sys_page_alloc(envid, 
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
		return ret;
		
	if ((ret = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  800ef7:	85 c0                	test   %eax,%eax
  800ef9:	78 78                	js     800f73 <fork+0x176>
		return ret;
	
	if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800efb:	83 ec 08             	sub    $0x8,%esp
  800efe:	6a 02                	push   $0x2
  800f00:	57                   	push   %edi
  800f01:	e8 32 fd ff ff       	call   800c38 <sys_env_set_status>
  800f06:	83 c4 10             	add    $0x10,%esp
		return ret;

	return envid;
  800f09:	85 c0                	test   %eax,%eax
  800f0b:	89 fa                	mov    %edi,%edx
  800f0d:	0f 48 d0             	cmovs  %eax,%edx
  800f10:	eb 61                	jmp    800f73 <fork+0x176>

	set_pgfault_handler(&pgfault);
	
	envid = sys_exofork();
	if (envid < 0) 
		return envid;
  800f12:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f15:	eb 5c                	jmp    800f73 <fork+0x176>
	int r;

	if (uvpt[pn] & (PTE_W | PTE_COW)) 
		perm |= PTE_COW;
	
	if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800f17:	83 ec 0c             	sub    $0xc,%esp
  800f1a:	6a 05                	push   $0x5
  800f1c:	56                   	push   %esi
  800f1d:	57                   	push   %edi
  800f1e:	56                   	push   %esi
  800f1f:	6a 00                	push   $0x0
  800f21:	e8 8e fc ff ff       	call   800bb4 <sys_page_map>
  800f26:	83 c4 20             	add    $0x20,%esp
  800f29:	85 c0                	test   %eax,%eax
  800f2b:	79 85                	jns    800eb2 <fork+0xb5>
  800f2d:	e9 5c ff ff ff       	jmp    800e8e <fork+0x91>
		panic("sys_page_map: %e", r);
	
	if (!(perm & PTE_COW))
		return 0;
	
	if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0)
  800f32:	83 ec 0c             	sub    $0xc,%esp
  800f35:	68 05 08 00 00       	push   $0x805
  800f3a:	56                   	push   %esi
  800f3b:	6a 00                	push   $0x0
  800f3d:	56                   	push   %esi
  800f3e:	6a 00                	push   $0x0
  800f40:	e8 6f fc ff ff       	call   800bb4 <sys_page_map>
  800f45:	83 c4 20             	add    $0x20,%esp
  800f48:	85 c0                	test   %eax,%eax
  800f4a:	0f 89 62 ff ff ff    	jns    800eb2 <fork+0xb5>
  800f50:	e9 4b ff ff ff       	jmp    800ea0 <fork+0xa3>
	int r;

	if (uvpt[pn] & (PTE_W | PTE_COW)) 
		perm |= PTE_COW;
	
	if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800f55:	83 ec 0c             	sub    $0xc,%esp
  800f58:	68 05 08 00 00       	push   $0x805
  800f5d:	56                   	push   %esi
  800f5e:	57                   	push   %edi
  800f5f:	56                   	push   %esi
  800f60:	6a 00                	push   $0x0
  800f62:	e8 4d fc ff ff       	call   800bb4 <sys_page_map>
  800f67:	83 c4 20             	add    $0x20,%esp
  800f6a:	85 c0                	test   %eax,%eax
  800f6c:	79 c4                	jns    800f32 <fork+0x135>
  800f6e:	e9 1b ff ff ff       	jmp    800e8e <fork+0x91>
	
	if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
		return ret;

	return envid;
}
  800f73:	89 d0                	mov    %edx,%eax
  800f75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f78:	5b                   	pop    %ebx
  800f79:	5e                   	pop    %esi
  800f7a:	5f                   	pop    %edi
  800f7b:	5d                   	pop    %ebp
  800f7c:	c3                   	ret    

00800f7d <sfork>:

// Challenge!
int
sfork(void)
{
  800f7d:	55                   	push   %ebp
  800f7e:	89 e5                	mov    %esp,%ebp
  800f80:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800f83:	68 2d 17 80 00       	push   $0x80172d
  800f88:	68 88 00 00 00       	push   $0x88
  800f8d:	68 eb 16 80 00       	push   $0x8016eb
  800f92:	e8 f6 00 00 00       	call   80108d <_panic>

00800f97 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800f97:	55                   	push   %ebp
  800f98:	89 e5                	mov    %esp,%ebp
  800f9a:	56                   	push   %esi
  800f9b:	53                   	push   %ebx
  800f9c:	8b 75 08             	mov    0x8(%ebp),%esi
  800f9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fa2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	
	if (pg == NULL)
  800fa5:	85 c0                	test   %eax,%eax
		pg = (void *) UTOP;
  800fa7:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800fac:	0f 44 c2             	cmove  %edx,%eax
	
	if ((ret = sys_ipc_recv(pg)) < 0) {
  800faf:	83 ec 0c             	sub    $0xc,%esp
  800fb2:	50                   	push   %eax
  800fb3:	e8 27 fd ff ff       	call   800cdf <sys_ipc_recv>
  800fb8:	83 c4 10             	add    $0x10,%esp
  800fbb:	85 c0                	test   %eax,%eax
  800fbd:	79 16                	jns    800fd5 <ipc_recv+0x3e>
		if (from_env_store != NULL) 
  800fbf:	85 f6                	test   %esi,%esi
  800fc1:	74 06                	je     800fc9 <ipc_recv+0x32>
			*from_env_store = 0;
  800fc3:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL)
  800fc9:	85 db                	test   %ebx,%ebx
  800fcb:	74 2c                	je     800ff9 <ipc_recv+0x62>
			*perm_store = 0;
  800fcd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800fd3:	eb 24                	jmp    800ff9 <ipc_recv+0x62>
		return ret;
	}

	if (from_env_store != NULL)
  800fd5:	85 f6                	test   %esi,%esi
  800fd7:	74 0a                	je     800fe3 <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  800fd9:	a1 08 20 80 00       	mov    0x802008,%eax
  800fde:	8b 40 74             	mov    0x74(%eax),%eax
  800fe1:	89 06                	mov    %eax,(%esi)
	if (perm_store != NULL)
  800fe3:	85 db                	test   %ebx,%ebx
  800fe5:	74 0a                	je     800ff1 <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  800fe7:	a1 08 20 80 00       	mov    0x802008,%eax
  800fec:	8b 40 78             	mov    0x78(%eax),%eax
  800fef:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  800ff1:	a1 08 20 80 00       	mov    0x802008,%eax
  800ff6:	8b 40 70             	mov    0x70(%eax),%eax
}
  800ff9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ffc:	5b                   	pop    %ebx
  800ffd:	5e                   	pop    %esi
  800ffe:	5d                   	pop    %ebp
  800fff:	c3                   	ret    

00801000 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801000:	55                   	push   %ebp
  801001:	89 e5                	mov    %esp,%ebp
  801003:	57                   	push   %edi
  801004:	56                   	push   %esi
  801005:	53                   	push   %ebx
  801006:	83 ec 0c             	sub    $0xc,%esp
  801009:	8b 7d 08             	mov    0x8(%ebp),%edi
  80100c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80100f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;

	if (pg == NULL)
  801012:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  801014:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801019:	0f 44 d8             	cmove  %eax,%ebx

	while (1) {
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  80101c:	ff 75 14             	pushl  0x14(%ebp)
  80101f:	53                   	push   %ebx
  801020:	56                   	push   %esi
  801021:	57                   	push   %edi
  801022:	e8 95 fc ff ff       	call   800cbc <sys_ipc_try_send>
		if (ret == 0)
  801027:	83 c4 10             	add    $0x10,%esp
  80102a:	85 c0                	test   %eax,%eax
  80102c:	74 1e                	je     80104c <ipc_send+0x4c>
			break;
		if (ret != -E_IPC_NOT_RECV) 
  80102e:	83 f8 f8             	cmp    $0xfffffff8,%eax
  801031:	74 12                	je     801045 <ipc_send+0x45>
			panic("sys_ipc_try_send: %e", ret);
  801033:	50                   	push   %eax
  801034:	68 43 17 80 00       	push   $0x801743
  801039:	6a 43                	push   $0x43
  80103b:	68 58 17 80 00       	push   $0x801758
  801040:	e8 48 00 00 00       	call   80108d <_panic>

		sys_yield();
  801045:	e8 08 fb ff ff       	call   800b52 <sys_yield>
	}
  80104a:	eb d0                	jmp    80101c <ipc_send+0x1c>
}
  80104c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80104f:	5b                   	pop    %ebx
  801050:	5e                   	pop    %esi
  801051:	5f                   	pop    %edi
  801052:	5d                   	pop    %ebp
  801053:	c3                   	ret    

00801054 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80105a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80105f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801062:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801068:	8b 52 50             	mov    0x50(%edx),%edx
  80106b:	39 ca                	cmp    %ecx,%edx
  80106d:	75 0d                	jne    80107c <ipc_find_env+0x28>
			return envs[i].env_id;
  80106f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801072:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801077:	8b 40 48             	mov    0x48(%eax),%eax
  80107a:	eb 0f                	jmp    80108b <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80107c:	83 c0 01             	add    $0x1,%eax
  80107f:	3d 00 04 00 00       	cmp    $0x400,%eax
  801084:	75 d9                	jne    80105f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801086:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80108b:	5d                   	pop    %ebp
  80108c:	c3                   	ret    

0080108d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80108d:	55                   	push   %ebp
  80108e:	89 e5                	mov    %esp,%ebp
  801090:	56                   	push   %esi
  801091:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801092:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801095:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80109b:	e8 93 fa ff ff       	call   800b33 <sys_getenvid>
  8010a0:	83 ec 0c             	sub    $0xc,%esp
  8010a3:	ff 75 0c             	pushl  0xc(%ebp)
  8010a6:	ff 75 08             	pushl  0x8(%ebp)
  8010a9:	56                   	push   %esi
  8010aa:	50                   	push   %eax
  8010ab:	68 64 17 80 00       	push   $0x801764
  8010b0:	e8 34 f1 ff ff       	call   8001e9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010b5:	83 c4 18             	add    $0x18,%esp
  8010b8:	53                   	push   %ebx
  8010b9:	ff 75 10             	pushl  0x10(%ebp)
  8010bc:	e8 d7 f0 ff ff       	call   800198 <vcprintf>
	cprintf("\n");
  8010c1:	c7 04 24 18 14 80 00 	movl   $0x801418,(%esp)
  8010c8:	e8 1c f1 ff ff       	call   8001e9 <cprintf>
  8010cd:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010d0:	cc                   	int3   
  8010d1:	eb fd                	jmp    8010d0 <_panic+0x43>

008010d3 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8010d3:	55                   	push   %ebp
  8010d4:	89 e5                	mov    %esp,%ebp
  8010d6:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8010d9:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  8010e0:	75 52                	jne    801134 <set_pgfault_handler+0x61>
		// First time through!
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
  8010e2:	83 ec 04             	sub    $0x4,%esp
  8010e5:	6a 07                	push   $0x7
  8010e7:	68 00 f0 bf ee       	push   $0xeebff000
  8010ec:	6a 00                	push   $0x0
  8010ee:	e8 7e fa ff ff       	call   800b71 <sys_page_alloc>
		if (r < 0)
  8010f3:	83 c4 10             	add    $0x10,%esp
  8010f6:	85 c0                	test   %eax,%eax
  8010f8:	79 12                	jns    80110c <set_pgfault_handler+0x39>
			panic("sys_page_alloc: %e", r);
  8010fa:	50                   	push   %eax
  8010fb:	68 f6 16 80 00       	push   $0x8016f6
  801100:	6a 21                	push   $0x21
  801102:	68 87 17 80 00       	push   $0x801787
  801107:	e8 81 ff ff ff       	call   80108d <_panic>
		if ((r = sys_env_set_pgfault_upcall(0, _pgfault_upcall)) < 0)
  80110c:	83 ec 08             	sub    $0x8,%esp
  80110f:	68 3e 11 80 00       	push   $0x80113e
  801114:	6a 00                	push   $0x0
  801116:	e8 5f fb ff ff       	call   800c7a <sys_env_set_pgfault_upcall>
  80111b:	83 c4 10             	add    $0x10,%esp
  80111e:	85 c0                	test   %eax,%eax
  801120:	79 12                	jns    801134 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall: %e", r);
  801122:	50                   	push   %eax
  801123:	68 98 17 80 00       	push   $0x801798
  801128:	6a 23                	push   $0x23
  80112a:	68 87 17 80 00       	push   $0x801787
  80112f:	e8 59 ff ff ff       	call   80108d <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801134:	8b 45 08             	mov    0x8(%ebp),%eax
  801137:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  80113c:	c9                   	leave  
  80113d:	c3                   	ret    

0080113e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80113e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80113f:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  801144:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801146:	83 c4 04             	add    $0x4,%esp
	// Throughout the remaining code, think carefully about what
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	movl 48(%esp), %eax
  801149:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  80114d:	83 e8 04             	sub    $0x4,%eax
	movl 40(%esp), %edx
  801150:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  801154:	89 10                	mov    %edx,(%eax)
	movl %eax, 48(%esp)
  801156:	89 44 24 30          	mov    %eax,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	addl $8, %esp
  80115a:	83 c4 08             	add    $0x8,%esp
	popal
  80115d:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	addl $4, %esp
  80115e:	83 c4 04             	add    $0x4,%esp
	popfl
  801161:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	popl %esp
  801162:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	ret
  801163:	c3                   	ret    
  801164:	66 90                	xchg   %ax,%ax
  801166:	66 90                	xchg   %ax,%ax
  801168:	66 90                	xchg   %ax,%ax
  80116a:	66 90                	xchg   %ax,%ax
  80116c:	66 90                	xchg   %ax,%ax
  80116e:	66 90                	xchg   %ax,%ax

00801170 <__udivdi3>:
  801170:	55                   	push   %ebp
  801171:	57                   	push   %edi
  801172:	56                   	push   %esi
  801173:	53                   	push   %ebx
  801174:	83 ec 1c             	sub    $0x1c,%esp
  801177:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80117b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80117f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801183:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801187:	85 f6                	test   %esi,%esi
  801189:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80118d:	89 ca                	mov    %ecx,%edx
  80118f:	89 f8                	mov    %edi,%eax
  801191:	75 3d                	jne    8011d0 <__udivdi3+0x60>
  801193:	39 cf                	cmp    %ecx,%edi
  801195:	0f 87 c5 00 00 00    	ja     801260 <__udivdi3+0xf0>
  80119b:	85 ff                	test   %edi,%edi
  80119d:	89 fd                	mov    %edi,%ebp
  80119f:	75 0b                	jne    8011ac <__udivdi3+0x3c>
  8011a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8011a6:	31 d2                	xor    %edx,%edx
  8011a8:	f7 f7                	div    %edi
  8011aa:	89 c5                	mov    %eax,%ebp
  8011ac:	89 c8                	mov    %ecx,%eax
  8011ae:	31 d2                	xor    %edx,%edx
  8011b0:	f7 f5                	div    %ebp
  8011b2:	89 c1                	mov    %eax,%ecx
  8011b4:	89 d8                	mov    %ebx,%eax
  8011b6:	89 cf                	mov    %ecx,%edi
  8011b8:	f7 f5                	div    %ebp
  8011ba:	89 c3                	mov    %eax,%ebx
  8011bc:	89 d8                	mov    %ebx,%eax
  8011be:	89 fa                	mov    %edi,%edx
  8011c0:	83 c4 1c             	add    $0x1c,%esp
  8011c3:	5b                   	pop    %ebx
  8011c4:	5e                   	pop    %esi
  8011c5:	5f                   	pop    %edi
  8011c6:	5d                   	pop    %ebp
  8011c7:	c3                   	ret    
  8011c8:	90                   	nop
  8011c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011d0:	39 ce                	cmp    %ecx,%esi
  8011d2:	77 74                	ja     801248 <__udivdi3+0xd8>
  8011d4:	0f bd fe             	bsr    %esi,%edi
  8011d7:	83 f7 1f             	xor    $0x1f,%edi
  8011da:	0f 84 98 00 00 00    	je     801278 <__udivdi3+0x108>
  8011e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8011e5:	89 f9                	mov    %edi,%ecx
  8011e7:	89 c5                	mov    %eax,%ebp
  8011e9:	29 fb                	sub    %edi,%ebx
  8011eb:	d3 e6                	shl    %cl,%esi
  8011ed:	89 d9                	mov    %ebx,%ecx
  8011ef:	d3 ed                	shr    %cl,%ebp
  8011f1:	89 f9                	mov    %edi,%ecx
  8011f3:	d3 e0                	shl    %cl,%eax
  8011f5:	09 ee                	or     %ebp,%esi
  8011f7:	89 d9                	mov    %ebx,%ecx
  8011f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011fd:	89 d5                	mov    %edx,%ebp
  8011ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  801203:	d3 ed                	shr    %cl,%ebp
  801205:	89 f9                	mov    %edi,%ecx
  801207:	d3 e2                	shl    %cl,%edx
  801209:	89 d9                	mov    %ebx,%ecx
  80120b:	d3 e8                	shr    %cl,%eax
  80120d:	09 c2                	or     %eax,%edx
  80120f:	89 d0                	mov    %edx,%eax
  801211:	89 ea                	mov    %ebp,%edx
  801213:	f7 f6                	div    %esi
  801215:	89 d5                	mov    %edx,%ebp
  801217:	89 c3                	mov    %eax,%ebx
  801219:	f7 64 24 0c          	mull   0xc(%esp)
  80121d:	39 d5                	cmp    %edx,%ebp
  80121f:	72 10                	jb     801231 <__udivdi3+0xc1>
  801221:	8b 74 24 08          	mov    0x8(%esp),%esi
  801225:	89 f9                	mov    %edi,%ecx
  801227:	d3 e6                	shl    %cl,%esi
  801229:	39 c6                	cmp    %eax,%esi
  80122b:	73 07                	jae    801234 <__udivdi3+0xc4>
  80122d:	39 d5                	cmp    %edx,%ebp
  80122f:	75 03                	jne    801234 <__udivdi3+0xc4>
  801231:	83 eb 01             	sub    $0x1,%ebx
  801234:	31 ff                	xor    %edi,%edi
  801236:	89 d8                	mov    %ebx,%eax
  801238:	89 fa                	mov    %edi,%edx
  80123a:	83 c4 1c             	add    $0x1c,%esp
  80123d:	5b                   	pop    %ebx
  80123e:	5e                   	pop    %esi
  80123f:	5f                   	pop    %edi
  801240:	5d                   	pop    %ebp
  801241:	c3                   	ret    
  801242:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801248:	31 ff                	xor    %edi,%edi
  80124a:	31 db                	xor    %ebx,%ebx
  80124c:	89 d8                	mov    %ebx,%eax
  80124e:	89 fa                	mov    %edi,%edx
  801250:	83 c4 1c             	add    $0x1c,%esp
  801253:	5b                   	pop    %ebx
  801254:	5e                   	pop    %esi
  801255:	5f                   	pop    %edi
  801256:	5d                   	pop    %ebp
  801257:	c3                   	ret    
  801258:	90                   	nop
  801259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801260:	89 d8                	mov    %ebx,%eax
  801262:	f7 f7                	div    %edi
  801264:	31 ff                	xor    %edi,%edi
  801266:	89 c3                	mov    %eax,%ebx
  801268:	89 d8                	mov    %ebx,%eax
  80126a:	89 fa                	mov    %edi,%edx
  80126c:	83 c4 1c             	add    $0x1c,%esp
  80126f:	5b                   	pop    %ebx
  801270:	5e                   	pop    %esi
  801271:	5f                   	pop    %edi
  801272:	5d                   	pop    %ebp
  801273:	c3                   	ret    
  801274:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801278:	39 ce                	cmp    %ecx,%esi
  80127a:	72 0c                	jb     801288 <__udivdi3+0x118>
  80127c:	31 db                	xor    %ebx,%ebx
  80127e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801282:	0f 87 34 ff ff ff    	ja     8011bc <__udivdi3+0x4c>
  801288:	bb 01 00 00 00       	mov    $0x1,%ebx
  80128d:	e9 2a ff ff ff       	jmp    8011bc <__udivdi3+0x4c>
  801292:	66 90                	xchg   %ax,%ax
  801294:	66 90                	xchg   %ax,%ax
  801296:	66 90                	xchg   %ax,%ax
  801298:	66 90                	xchg   %ax,%ax
  80129a:	66 90                	xchg   %ax,%ax
  80129c:	66 90                	xchg   %ax,%ax
  80129e:	66 90                	xchg   %ax,%ax

008012a0 <__umoddi3>:
  8012a0:	55                   	push   %ebp
  8012a1:	57                   	push   %edi
  8012a2:	56                   	push   %esi
  8012a3:	53                   	push   %ebx
  8012a4:	83 ec 1c             	sub    $0x1c,%esp
  8012a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8012ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8012af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8012b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8012b7:	85 d2                	test   %edx,%edx
  8012b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8012bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012c1:	89 f3                	mov    %esi,%ebx
  8012c3:	89 3c 24             	mov    %edi,(%esp)
  8012c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012ca:	75 1c                	jne    8012e8 <__umoddi3+0x48>
  8012cc:	39 f7                	cmp    %esi,%edi
  8012ce:	76 50                	jbe    801320 <__umoddi3+0x80>
  8012d0:	89 c8                	mov    %ecx,%eax
  8012d2:	89 f2                	mov    %esi,%edx
  8012d4:	f7 f7                	div    %edi
  8012d6:	89 d0                	mov    %edx,%eax
  8012d8:	31 d2                	xor    %edx,%edx
  8012da:	83 c4 1c             	add    $0x1c,%esp
  8012dd:	5b                   	pop    %ebx
  8012de:	5e                   	pop    %esi
  8012df:	5f                   	pop    %edi
  8012e0:	5d                   	pop    %ebp
  8012e1:	c3                   	ret    
  8012e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012e8:	39 f2                	cmp    %esi,%edx
  8012ea:	89 d0                	mov    %edx,%eax
  8012ec:	77 52                	ja     801340 <__umoddi3+0xa0>
  8012ee:	0f bd ea             	bsr    %edx,%ebp
  8012f1:	83 f5 1f             	xor    $0x1f,%ebp
  8012f4:	75 5a                	jne    801350 <__umoddi3+0xb0>
  8012f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8012fa:	0f 82 e0 00 00 00    	jb     8013e0 <__umoddi3+0x140>
  801300:	39 0c 24             	cmp    %ecx,(%esp)
  801303:	0f 86 d7 00 00 00    	jbe    8013e0 <__umoddi3+0x140>
  801309:	8b 44 24 08          	mov    0x8(%esp),%eax
  80130d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801311:	83 c4 1c             	add    $0x1c,%esp
  801314:	5b                   	pop    %ebx
  801315:	5e                   	pop    %esi
  801316:	5f                   	pop    %edi
  801317:	5d                   	pop    %ebp
  801318:	c3                   	ret    
  801319:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801320:	85 ff                	test   %edi,%edi
  801322:	89 fd                	mov    %edi,%ebp
  801324:	75 0b                	jne    801331 <__umoddi3+0x91>
  801326:	b8 01 00 00 00       	mov    $0x1,%eax
  80132b:	31 d2                	xor    %edx,%edx
  80132d:	f7 f7                	div    %edi
  80132f:	89 c5                	mov    %eax,%ebp
  801331:	89 f0                	mov    %esi,%eax
  801333:	31 d2                	xor    %edx,%edx
  801335:	f7 f5                	div    %ebp
  801337:	89 c8                	mov    %ecx,%eax
  801339:	f7 f5                	div    %ebp
  80133b:	89 d0                	mov    %edx,%eax
  80133d:	eb 99                	jmp    8012d8 <__umoddi3+0x38>
  80133f:	90                   	nop
  801340:	89 c8                	mov    %ecx,%eax
  801342:	89 f2                	mov    %esi,%edx
  801344:	83 c4 1c             	add    $0x1c,%esp
  801347:	5b                   	pop    %ebx
  801348:	5e                   	pop    %esi
  801349:	5f                   	pop    %edi
  80134a:	5d                   	pop    %ebp
  80134b:	c3                   	ret    
  80134c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801350:	8b 34 24             	mov    (%esp),%esi
  801353:	bf 20 00 00 00       	mov    $0x20,%edi
  801358:	89 e9                	mov    %ebp,%ecx
  80135a:	29 ef                	sub    %ebp,%edi
  80135c:	d3 e0                	shl    %cl,%eax
  80135e:	89 f9                	mov    %edi,%ecx
  801360:	89 f2                	mov    %esi,%edx
  801362:	d3 ea                	shr    %cl,%edx
  801364:	89 e9                	mov    %ebp,%ecx
  801366:	09 c2                	or     %eax,%edx
  801368:	89 d8                	mov    %ebx,%eax
  80136a:	89 14 24             	mov    %edx,(%esp)
  80136d:	89 f2                	mov    %esi,%edx
  80136f:	d3 e2                	shl    %cl,%edx
  801371:	89 f9                	mov    %edi,%ecx
  801373:	89 54 24 04          	mov    %edx,0x4(%esp)
  801377:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80137b:	d3 e8                	shr    %cl,%eax
  80137d:	89 e9                	mov    %ebp,%ecx
  80137f:	89 c6                	mov    %eax,%esi
  801381:	d3 e3                	shl    %cl,%ebx
  801383:	89 f9                	mov    %edi,%ecx
  801385:	89 d0                	mov    %edx,%eax
  801387:	d3 e8                	shr    %cl,%eax
  801389:	89 e9                	mov    %ebp,%ecx
  80138b:	09 d8                	or     %ebx,%eax
  80138d:	89 d3                	mov    %edx,%ebx
  80138f:	89 f2                	mov    %esi,%edx
  801391:	f7 34 24             	divl   (%esp)
  801394:	89 d6                	mov    %edx,%esi
  801396:	d3 e3                	shl    %cl,%ebx
  801398:	f7 64 24 04          	mull   0x4(%esp)
  80139c:	39 d6                	cmp    %edx,%esi
  80139e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013a2:	89 d1                	mov    %edx,%ecx
  8013a4:	89 c3                	mov    %eax,%ebx
  8013a6:	72 08                	jb     8013b0 <__umoddi3+0x110>
  8013a8:	75 11                	jne    8013bb <__umoddi3+0x11b>
  8013aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8013ae:	73 0b                	jae    8013bb <__umoddi3+0x11b>
  8013b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8013b4:	1b 14 24             	sbb    (%esp),%edx
  8013b7:	89 d1                	mov    %edx,%ecx
  8013b9:	89 c3                	mov    %eax,%ebx
  8013bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8013bf:	29 da                	sub    %ebx,%edx
  8013c1:	19 ce                	sbb    %ecx,%esi
  8013c3:	89 f9                	mov    %edi,%ecx
  8013c5:	89 f0                	mov    %esi,%eax
  8013c7:	d3 e0                	shl    %cl,%eax
  8013c9:	89 e9                	mov    %ebp,%ecx
  8013cb:	d3 ea                	shr    %cl,%edx
  8013cd:	89 e9                	mov    %ebp,%ecx
  8013cf:	d3 ee                	shr    %cl,%esi
  8013d1:	09 d0                	or     %edx,%eax
  8013d3:	89 f2                	mov    %esi,%edx
  8013d5:	83 c4 1c             	add    $0x1c,%esp
  8013d8:	5b                   	pop    %ebx
  8013d9:	5e                   	pop    %esi
  8013da:	5f                   	pop    %edi
  8013db:	5d                   	pop    %ebp
  8013dc:	c3                   	ret    
  8013dd:	8d 76 00             	lea    0x0(%esi),%esi
  8013e0:	29 f9                	sub    %edi,%ecx
  8013e2:	19 d6                	sbb    %edx,%esi
  8013e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013ec:	e9 18 ff ff ff       	jmp    801309 <__umoddi3+0x69>
