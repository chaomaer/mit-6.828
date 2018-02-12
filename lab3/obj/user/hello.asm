
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 2d 00 00 00       	call   80005e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  800039:	68 84 0d 80 00       	push   $0x800d84
  80003e:	e8 09 01 00 00       	call   80014c <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 04 20 80 00       	mov    0x802004,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 92 0d 80 00       	push   $0x800d92
  800054:	e8 f3 00 00 00       	call   80014c <cprintf>
}
  800059:	83 c4 10             	add    $0x10,%esp
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800066:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    thisenv = envs + ENVX(sys_getenvid());
  800069:	e8 29 0a 00 00       	call   800a97 <sys_getenvid>
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800076:	c1 e0 05             	shl    $0x5,%eax
  800079:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007e:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800083:	85 db                	test   %ebx,%ebx
  800085:	7e 07                	jle    80008e <libmain+0x30>
		binaryname = argv[0];
  800087:	8b 06                	mov    (%esi),%eax
  800089:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80008e:	83 ec 08             	sub    $0x8,%esp
  800091:	56                   	push   %esi
  800092:	53                   	push   %ebx
  800093:	e8 9b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800098:	e8 0a 00 00 00       	call   8000a7 <exit>
}
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a3:	5b                   	pop    %ebx
  8000a4:	5e                   	pop    %esi
  8000a5:	5d                   	pop    %ebp
  8000a6:	c3                   	ret    

008000a7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a7:	55                   	push   %ebp
  8000a8:	89 e5                	mov    %esp,%ebp
  8000aa:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000ad:	6a 00                	push   $0x0
  8000af:	e8 a2 09 00 00       	call   800a56 <sys_env_destroy>
}
  8000b4:	83 c4 10             	add    $0x10,%esp
  8000b7:	c9                   	leave  
  8000b8:	c3                   	ret    

008000b9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b9:	55                   	push   %ebp
  8000ba:	89 e5                	mov    %esp,%ebp
  8000bc:	53                   	push   %ebx
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c3:	8b 13                	mov    (%ebx),%edx
  8000c5:	8d 42 01             	lea    0x1(%edx),%eax
  8000c8:	89 03                	mov    %eax,(%ebx)
  8000ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000cd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d6:	75 1a                	jne    8000f2 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000d8:	83 ec 08             	sub    $0x8,%esp
  8000db:	68 ff 00 00 00       	push   $0xff
  8000e0:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e3:	50                   	push   %eax
  8000e4:	e8 30 09 00 00       	call   800a19 <sys_cputs>
		b->idx = 0;
  8000e9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000ef:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f9:	c9                   	leave  
  8000fa:	c3                   	ret    

008000fb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800104:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010b:	00 00 00 
	b.cnt = 0;
  80010e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800115:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800118:	ff 75 0c             	pushl  0xc(%ebp)
  80011b:	ff 75 08             	pushl  0x8(%ebp)
  80011e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800124:	50                   	push   %eax
  800125:	68 b9 00 80 00       	push   $0x8000b9
  80012a:	e8 54 01 00 00       	call   800283 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80012f:	83 c4 08             	add    $0x8,%esp
  800132:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800138:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80013e:	50                   	push   %eax
  80013f:	e8 d5 08 00 00       	call   800a19 <sys_cputs>

	return b.cnt;
}
  800144:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014a:	c9                   	leave  
  80014b:	c3                   	ret    

0080014c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800152:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800155:	50                   	push   %eax
  800156:	ff 75 08             	pushl  0x8(%ebp)
  800159:	e8 9d ff ff ff       	call   8000fb <vcprintf>
	va_end(ap);

	return cnt;
}
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	57                   	push   %edi
  800164:	56                   	push   %esi
  800165:	53                   	push   %ebx
  800166:	83 ec 1c             	sub    $0x1c,%esp
  800169:	89 c7                	mov    %eax,%edi
  80016b:	89 d6                	mov    %edx,%esi
  80016d:	8b 45 08             	mov    0x8(%ebp),%eax
  800170:	8b 55 0c             	mov    0xc(%ebp),%edx
  800173:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800176:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800179:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80017c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800181:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800184:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800187:	39 d3                	cmp    %edx,%ebx
  800189:	72 05                	jb     800190 <printnum+0x30>
  80018b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80018e:	77 45                	ja     8001d5 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	ff 75 18             	pushl  0x18(%ebp)
  800196:	8b 45 14             	mov    0x14(%ebp),%eax
  800199:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80019c:	53                   	push   %ebx
  80019d:	ff 75 10             	pushl  0x10(%ebp)
  8001a0:	83 ec 08             	sub    $0x8,%esp
  8001a3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001a6:	ff 75 e0             	pushl  -0x20(%ebp)
  8001a9:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ac:	ff 75 d8             	pushl  -0x28(%ebp)
  8001af:	e8 4c 09 00 00       	call   800b00 <__udivdi3>
  8001b4:	83 c4 18             	add    $0x18,%esp
  8001b7:	52                   	push   %edx
  8001b8:	50                   	push   %eax
  8001b9:	89 f2                	mov    %esi,%edx
  8001bb:	89 f8                	mov    %edi,%eax
  8001bd:	e8 9e ff ff ff       	call   800160 <printnum>
  8001c2:	83 c4 20             	add    $0x20,%esp
  8001c5:	eb 18                	jmp    8001df <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001c7:	83 ec 08             	sub    $0x8,%esp
  8001ca:	56                   	push   %esi
  8001cb:	ff 75 18             	pushl  0x18(%ebp)
  8001ce:	ff d7                	call   *%edi
  8001d0:	83 c4 10             	add    $0x10,%esp
  8001d3:	eb 03                	jmp    8001d8 <printnum+0x78>
  8001d5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001d8:	83 eb 01             	sub    $0x1,%ebx
  8001db:	85 db                	test   %ebx,%ebx
  8001dd:	7f e8                	jg     8001c7 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001df:	83 ec 08             	sub    $0x8,%esp
  8001e2:	56                   	push   %esi
  8001e3:	83 ec 04             	sub    $0x4,%esp
  8001e6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e9:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ec:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ef:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f2:	e8 39 0a 00 00       	call   800c30 <__umoddi3>
  8001f7:	83 c4 14             	add    $0x14,%esp
  8001fa:	0f be 80 b3 0d 80 00 	movsbl 0x800db3(%eax),%eax
  800201:	50                   	push   %eax
  800202:	ff d7                	call   *%edi
}
  800204:	83 c4 10             	add    $0x10,%esp
  800207:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020a:	5b                   	pop    %ebx
  80020b:	5e                   	pop    %esi
  80020c:	5f                   	pop    %edi
  80020d:	5d                   	pop    %ebp
  80020e:	c3                   	ret    

0080020f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800212:	83 fa 01             	cmp    $0x1,%edx
  800215:	7e 0e                	jle    800225 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800217:	8b 10                	mov    (%eax),%edx
  800219:	8d 4a 08             	lea    0x8(%edx),%ecx
  80021c:	89 08                	mov    %ecx,(%eax)
  80021e:	8b 02                	mov    (%edx),%eax
  800220:	8b 52 04             	mov    0x4(%edx),%edx
  800223:	eb 22                	jmp    800247 <getuint+0x38>
	else if (lflag)
  800225:	85 d2                	test   %edx,%edx
  800227:	74 10                	je     800239 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800229:	8b 10                	mov    (%eax),%edx
  80022b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80022e:	89 08                	mov    %ecx,(%eax)
  800230:	8b 02                	mov    (%edx),%eax
  800232:	ba 00 00 00 00       	mov    $0x0,%edx
  800237:	eb 0e                	jmp    800247 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800239:	8b 10                	mov    (%eax),%edx
  80023b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80023e:	89 08                	mov    %ecx,(%eax)
  800240:	8b 02                	mov    (%edx),%eax
  800242:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800247:	5d                   	pop    %ebp
  800248:	c3                   	ret    

00800249 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800249:	55                   	push   %ebp
  80024a:	89 e5                	mov    %esp,%ebp
  80024c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80024f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800253:	8b 10                	mov    (%eax),%edx
  800255:	3b 50 04             	cmp    0x4(%eax),%edx
  800258:	73 0a                	jae    800264 <sprintputch+0x1b>
		*b->buf++ = ch;
  80025a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80025d:	89 08                	mov    %ecx,(%eax)
  80025f:	8b 45 08             	mov    0x8(%ebp),%eax
  800262:	88 02                	mov    %al,(%edx)
}
  800264:	5d                   	pop    %ebp
  800265:	c3                   	ret    

00800266 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800266:	55                   	push   %ebp
  800267:	89 e5                	mov    %esp,%ebp
  800269:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80026c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80026f:	50                   	push   %eax
  800270:	ff 75 10             	pushl  0x10(%ebp)
  800273:	ff 75 0c             	pushl  0xc(%ebp)
  800276:	ff 75 08             	pushl  0x8(%ebp)
  800279:	e8 05 00 00 00       	call   800283 <vprintfmt>
	va_end(ap);
}
  80027e:	83 c4 10             	add    $0x10,%esp
  800281:	c9                   	leave  
  800282:	c3                   	ret    

00800283 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800283:	55                   	push   %ebp
  800284:	89 e5                	mov    %esp,%ebp
  800286:	57                   	push   %edi
  800287:	56                   	push   %esi
  800288:	53                   	push   %ebx
  800289:	83 ec 2c             	sub    $0x2c,%esp
  80028c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
    int color = 0;
  80028f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800296:	eb 17                	jmp    8002af <vprintfmt+0x2c>
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800298:	85 c0                	test   %eax,%eax
  80029a:	0f 84 89 03 00 00    	je     800629 <vprintfmt+0x3a6>
				return;
			putch(ch, putdat);
  8002a0:	83 ec 08             	sub    $0x8,%esp
  8002a3:	ff 75 0c             	pushl  0xc(%ebp)
  8002a6:	50                   	push   %eax
  8002a7:	ff 55 08             	call   *0x8(%ebp)
  8002aa:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
    int color = 0;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ad:	89 f3                	mov    %esi,%ebx
  8002af:	8d 73 01             	lea    0x1(%ebx),%esi
  8002b2:	0f b6 03             	movzbl (%ebx),%eax
  8002b5:	83 f8 25             	cmp    $0x25,%eax
  8002b8:	75 de                	jne    800298 <vprintfmt+0x15>
  8002ba:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8002be:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002c5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8002ca:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d6:	eb 0d                	jmp    8002e5 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d8:	89 de                	mov    %ebx,%esi
  8002da:	eb 09                	jmp    8002e5 <vprintfmt+0x62>
  8002dc:	89 de                	mov    %ebx,%esi
			break;
        case 'C': 
        //自己补充的控制颜色的代码
            switch(va_arg(ap,int)){
                case 0:
                    color = 0x0c00;
  8002de:	c7 45 d8 00 0c 00 00 	movl   $0xc00,-0x28(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e5:	8d 5e 01             	lea    0x1(%esi),%ebx
  8002e8:	0f b6 06             	movzbl (%esi),%eax
  8002eb:	0f b6 c8             	movzbl %al,%ecx
  8002ee:	83 e8 23             	sub    $0x23,%eax
  8002f1:	3c 55                	cmp    $0x55,%al
  8002f3:	0f 87 10 03 00 00    	ja     800609 <vprintfmt+0x386>
  8002f9:	0f b6 c0             	movzbl %al,%eax
  8002fc:	ff 24 85 40 0e 80 00 	jmp    *0x800e40(,%eax,4)
  800303:	89 de                	mov    %ebx,%esi
		case '-':
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800305:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800309:	eb da                	jmp    8002e5 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030b:	89 de                	mov    %ebx,%esi
  80030d:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800312:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  800315:	8d 7c 41 d0          	lea    -0x30(%ecx,%eax,2),%edi
				ch = *fmt;
  800319:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
  80031c:	8d 41 d0             	lea    -0x30(%ecx),%eax
  80031f:	83 f8 09             	cmp    $0x9,%eax
  800322:	77 33                	ja     800357 <vprintfmt+0xd4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800324:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800327:	eb e9                	jmp    800312 <vprintfmt+0x8f>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800329:	8b 45 14             	mov    0x14(%ebp),%eax
  80032c:	8d 48 04             	lea    0x4(%eax),%ecx
  80032f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800332:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800334:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800336:	eb 1f                	jmp    800357 <vprintfmt+0xd4>
  800338:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80033b:	85 c0                	test   %eax,%eax
  80033d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800342:	0f 49 c8             	cmovns %eax,%ecx
  800345:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800348:	89 de                	mov    %ebx,%esi
  80034a:	eb 99                	jmp    8002e5 <vprintfmt+0x62>
  80034c:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80034e:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
  800355:	eb 8e                	jmp    8002e5 <vprintfmt+0x62>

		process_precision:
			if (width < 0)
  800357:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80035b:	79 88                	jns    8002e5 <vprintfmt+0x62>
				width = precision, precision = -1;
  80035d:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800360:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800365:	e9 7b ff ff ff       	jmp    8002e5 <vprintfmt+0x62>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80036a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036d:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80036f:	e9 71 ff ff ff       	jmp    8002e5 <vprintfmt+0x62>

		case 'c':
            ch = va_arg(ap,int)+color;
  800374:	8b 45 14             	mov    0x14(%ebp),%eax
  800377:	8d 50 04             	lea    0x4(%eax),%edx
  80037a:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
  80037d:	83 ec 08             	sub    $0x8,%esp
  800380:	ff 75 0c             	pushl  0xc(%ebp)
  800383:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800386:	03 08                	add    (%eax),%ecx
  800388:	51                   	push   %ecx
  800389:	ff 55 08             	call   *0x8(%ebp)
            color = 0;
			break;
  80038c:	83 c4 10             	add    $0x10,%esp
			goto reswitch;

		case 'c':
            ch = va_arg(ap,int)+color;
			putch(ch, putdat);
            color = 0;
  80038f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
			break;
  800396:	e9 14 ff ff ff       	jmp    8002af <vprintfmt+0x2c>
        case 'C': 
        //自己补充的控制颜色的代码
            switch(va_arg(ap,int)){
  80039b:	8b 45 14             	mov    0x14(%ebp),%eax
  80039e:	8d 48 04             	lea    0x4(%eax),%ecx
  8003a1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003a4:	8b 00                	mov    (%eax),%eax
  8003a6:	85 c0                	test   %eax,%eax
  8003a8:	0f 84 2e ff ff ff    	je     8002dc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ae:	89 de                	mov    %ebx,%esi
  8003b0:	83 f8 01             	cmp    $0x1,%eax
  8003b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b8:	b9 00 0a 00 00       	mov    $0xa00,%ecx
  8003bd:	0f 44 c1             	cmove  %ecx,%eax
  8003c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003c3:	e9 1d ff ff ff       	jmp    8002e5 <vprintfmt+0x62>
            }

            goto reswitch;
		// error message
		case 'e':
			err = va_arg(ap, int);
  8003c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cb:	8d 50 04             	lea    0x4(%eax),%edx
  8003ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d1:	8b 00                	mov    (%eax),%eax
  8003d3:	99                   	cltd   
  8003d4:	31 d0                	xor    %edx,%eax
  8003d6:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003d8:	83 f8 06             	cmp    $0x6,%eax
  8003db:	7f 0b                	jg     8003e8 <vprintfmt+0x165>
  8003dd:	8b 14 85 98 0f 80 00 	mov    0x800f98(,%eax,4),%edx
  8003e4:	85 d2                	test   %edx,%edx
  8003e6:	75 19                	jne    800401 <vprintfmt+0x17e>
				printfmt(putch, putdat, "error %d", err);
  8003e8:	50                   	push   %eax
  8003e9:	68 cb 0d 80 00       	push   $0x800dcb
  8003ee:	ff 75 0c             	pushl  0xc(%ebp)
  8003f1:	ff 75 08             	pushl  0x8(%ebp)
  8003f4:	e8 6d fe ff ff       	call   800266 <printfmt>
  8003f9:	83 c4 10             	add    $0x10,%esp
  8003fc:	e9 ae fe ff ff       	jmp    8002af <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
  800401:	52                   	push   %edx
  800402:	68 d4 0d 80 00       	push   $0x800dd4
  800407:	ff 75 0c             	pushl  0xc(%ebp)
  80040a:	ff 75 08             	pushl  0x8(%ebp)
  80040d:	e8 54 fe ff ff       	call   800266 <printfmt>
  800412:	83 c4 10             	add    $0x10,%esp
  800415:	e9 95 fe ff ff       	jmp    8002af <vprintfmt+0x2c>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80041a:	8b 45 14             	mov    0x14(%ebp),%eax
  80041d:	8d 50 04             	lea    0x4(%eax),%edx
  800420:	89 55 14             	mov    %edx,0x14(%ebp)
  800423:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800425:	85 f6                	test   %esi,%esi
  800427:	b8 c4 0d 80 00       	mov    $0x800dc4,%eax
  80042c:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  80042f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800433:	0f 8e 89 00 00 00    	jle    8004c2 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800439:	83 ec 08             	sub    $0x8,%esp
  80043c:	57                   	push   %edi
  80043d:	56                   	push   %esi
  80043e:	e8 6e 02 00 00       	call   8006b1 <strnlen>
  800443:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800446:	29 c1                	sub    %eax,%ecx
  800448:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80044b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80044e:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  800452:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800455:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800458:	8b 75 0c             	mov    0xc(%ebp),%esi
  80045b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80045e:	89 cb                	mov    %ecx,%ebx
  800460:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800462:	eb 0e                	jmp    800472 <vprintfmt+0x1ef>
					putch(padc, putdat);
  800464:	83 ec 08             	sub    $0x8,%esp
  800467:	56                   	push   %esi
  800468:	57                   	push   %edi
  800469:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80046c:	83 eb 01             	sub    $0x1,%ebx
  80046f:	83 c4 10             	add    $0x10,%esp
  800472:	85 db                	test   %ebx,%ebx
  800474:	7f ee                	jg     800464 <vprintfmt+0x1e1>
  800476:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800479:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80047c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80047f:	85 c9                	test   %ecx,%ecx
  800481:	b8 00 00 00 00       	mov    $0x0,%eax
  800486:	0f 49 c1             	cmovns %ecx,%eax
  800489:	29 c1                	sub    %eax,%ecx
  80048b:	89 cb                	mov    %ecx,%ebx
  80048d:	eb 39                	jmp    8004c8 <vprintfmt+0x245>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80048f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800493:	74 1b                	je     8004b0 <vprintfmt+0x22d>
  800495:	0f be c0             	movsbl %al,%eax
  800498:	83 e8 20             	sub    $0x20,%eax
  80049b:	83 f8 5e             	cmp    $0x5e,%eax
  80049e:	76 10                	jbe    8004b0 <vprintfmt+0x22d>
					putch('?', putdat);
  8004a0:	83 ec 08             	sub    $0x8,%esp
  8004a3:	ff 75 0c             	pushl  0xc(%ebp)
  8004a6:	6a 3f                	push   $0x3f
  8004a8:	ff 55 08             	call   *0x8(%ebp)
  8004ab:	83 c4 10             	add    $0x10,%esp
  8004ae:	eb 0d                	jmp    8004bd <vprintfmt+0x23a>
				else
					putch(ch, putdat);
  8004b0:	83 ec 08             	sub    $0x8,%esp
  8004b3:	ff 75 0c             	pushl  0xc(%ebp)
  8004b6:	52                   	push   %edx
  8004b7:	ff 55 08             	call   *0x8(%ebp)
  8004ba:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004bd:	83 eb 01             	sub    $0x1,%ebx
  8004c0:	eb 06                	jmp    8004c8 <vprintfmt+0x245>
  8004c2:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004c5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004c8:	83 c6 01             	add    $0x1,%esi
  8004cb:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8004cf:	0f be d0             	movsbl %al,%edx
  8004d2:	85 d2                	test   %edx,%edx
  8004d4:	74 25                	je     8004fb <vprintfmt+0x278>
  8004d6:	85 ff                	test   %edi,%edi
  8004d8:	78 b5                	js     80048f <vprintfmt+0x20c>
  8004da:	83 ef 01             	sub    $0x1,%edi
  8004dd:	79 b0                	jns    80048f <vprintfmt+0x20c>
  8004df:	89 d8                	mov    %ebx,%eax
  8004e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004e7:	89 c3                	mov    %eax,%ebx
  8004e9:	eb 16                	jmp    800501 <vprintfmt+0x27e>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004eb:	83 ec 08             	sub    $0x8,%esp
  8004ee:	57                   	push   %edi
  8004ef:	6a 20                	push   $0x20
  8004f1:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004f3:	83 eb 01             	sub    $0x1,%ebx
  8004f6:	83 c4 10             	add    $0x10,%esp
  8004f9:	eb 06                	jmp    800501 <vprintfmt+0x27e>
  8004fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8004fe:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800501:	85 db                	test   %ebx,%ebx
  800503:	7f e6                	jg     8004eb <vprintfmt+0x268>
  800505:	89 75 08             	mov    %esi,0x8(%ebp)
  800508:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80050b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80050e:	e9 9c fd ff ff       	jmp    8002af <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800513:	83 fa 01             	cmp    $0x1,%edx
  800516:	7e 10                	jle    800528 <vprintfmt+0x2a5>
		return va_arg(*ap, long long);
  800518:	8b 45 14             	mov    0x14(%ebp),%eax
  80051b:	8d 50 08             	lea    0x8(%eax),%edx
  80051e:	89 55 14             	mov    %edx,0x14(%ebp)
  800521:	8b 30                	mov    (%eax),%esi
  800523:	8b 78 04             	mov    0x4(%eax),%edi
  800526:	eb 26                	jmp    80054e <vprintfmt+0x2cb>
	else if (lflag)
  800528:	85 d2                	test   %edx,%edx
  80052a:	74 12                	je     80053e <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80052c:	8b 45 14             	mov    0x14(%ebp),%eax
  80052f:	8d 50 04             	lea    0x4(%eax),%edx
  800532:	89 55 14             	mov    %edx,0x14(%ebp)
  800535:	8b 30                	mov    (%eax),%esi
  800537:	89 f7                	mov    %esi,%edi
  800539:	c1 ff 1f             	sar    $0x1f,%edi
  80053c:	eb 10                	jmp    80054e <vprintfmt+0x2cb>
	else
		return va_arg(*ap, int);
  80053e:	8b 45 14             	mov    0x14(%ebp),%eax
  800541:	8d 50 04             	lea    0x4(%eax),%edx
  800544:	89 55 14             	mov    %edx,0x14(%ebp)
  800547:	8b 30                	mov    (%eax),%esi
  800549:	89 f7                	mov    %esi,%edi
  80054b:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80054e:	89 f0                	mov    %esi,%eax
  800550:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800552:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800557:	85 ff                	test   %edi,%edi
  800559:	79 7b                	jns    8005d6 <vprintfmt+0x353>
				putch('-', putdat);
  80055b:	83 ec 08             	sub    $0x8,%esp
  80055e:	ff 75 0c             	pushl  0xc(%ebp)
  800561:	6a 2d                	push   $0x2d
  800563:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800566:	89 f0                	mov    %esi,%eax
  800568:	89 fa                	mov    %edi,%edx
  80056a:	f7 d8                	neg    %eax
  80056c:	83 d2 00             	adc    $0x0,%edx
  80056f:	f7 da                	neg    %edx
  800571:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800574:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800579:	eb 5b                	jmp    8005d6 <vprintfmt+0x353>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80057b:	8d 45 14             	lea    0x14(%ebp),%eax
  80057e:	e8 8c fc ff ff       	call   80020f <getuint>
			base = 10;
  800583:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800588:	eb 4c                	jmp    8005d6 <vprintfmt+0x353>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80058a:	8d 45 14             	lea    0x14(%ebp),%eax
  80058d:	e8 7d fc ff ff       	call   80020f <getuint>
			base = 8;
  800592:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  800597:	eb 3d                	jmp    8005d6 <vprintfmt+0x353>
		// pointer
		case 'p':
			putch('0', putdat);
  800599:	83 ec 08             	sub    $0x8,%esp
  80059c:	ff 75 0c             	pushl  0xc(%ebp)
  80059f:	6a 30                	push   $0x30
  8005a1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005a4:	83 c4 08             	add    $0x8,%esp
  8005a7:	ff 75 0c             	pushl  0xc(%ebp)
  8005aa:	6a 78                	push   $0x78
  8005ac:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005af:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b2:	8d 50 04             	lea    0x4(%eax),%edx
  8005b5:	89 55 14             	mov    %edx,0x14(%ebp)
            goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005b8:	8b 00                	mov    (%eax),%eax
  8005ba:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005bf:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005c2:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005c7:	eb 0d                	jmp    8005d6 <vprintfmt+0x353>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005c9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005cc:	e8 3e fc ff ff       	call   80020f <getuint>
			base = 16;
  8005d1:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005d6:	83 ec 0c             	sub    $0xc,%esp
  8005d9:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
  8005dd:	56                   	push   %esi
  8005de:	ff 75 e0             	pushl  -0x20(%ebp)
  8005e1:	51                   	push   %ecx
  8005e2:	52                   	push   %edx
  8005e3:	50                   	push   %eax
  8005e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ea:	e8 71 fb ff ff       	call   800160 <printnum>
			break;
  8005ef:	83 c4 20             	add    $0x20,%esp
  8005f2:	e9 b8 fc ff ff       	jmp    8002af <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005f7:	83 ec 08             	sub    $0x8,%esp
  8005fa:	ff 75 0c             	pushl  0xc(%ebp)
  8005fd:	51                   	push   %ecx
  8005fe:	ff 55 08             	call   *0x8(%ebp)
			break;
  800601:	83 c4 10             	add    $0x10,%esp
  800604:	e9 a6 fc ff ff       	jmp    8002af <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800609:	83 ec 08             	sub    $0x8,%esp
  80060c:	ff 75 0c             	pushl  0xc(%ebp)
  80060f:	6a 25                	push   $0x25
  800611:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800614:	83 c4 10             	add    $0x10,%esp
  800617:	89 f3                	mov    %esi,%ebx
  800619:	eb 03                	jmp    80061e <vprintfmt+0x39b>
  80061b:	83 eb 01             	sub    $0x1,%ebx
  80061e:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800622:	75 f7                	jne    80061b <vprintfmt+0x398>
  800624:	e9 86 fc ff ff       	jmp    8002af <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
  800629:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062c:	5b                   	pop    %ebx
  80062d:	5e                   	pop    %esi
  80062e:	5f                   	pop    %edi
  80062f:	5d                   	pop    %ebp
  800630:	c3                   	ret    

00800631 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800631:	55                   	push   %ebp
  800632:	89 e5                	mov    %esp,%ebp
  800634:	83 ec 18             	sub    $0x18,%esp
  800637:	8b 45 08             	mov    0x8(%ebp),%eax
  80063a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80063d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800640:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800644:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800647:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80064e:	85 c0                	test   %eax,%eax
  800650:	74 26                	je     800678 <vsnprintf+0x47>
  800652:	85 d2                	test   %edx,%edx
  800654:	7e 22                	jle    800678 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800656:	ff 75 14             	pushl  0x14(%ebp)
  800659:	ff 75 10             	pushl  0x10(%ebp)
  80065c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80065f:	50                   	push   %eax
  800660:	68 49 02 80 00       	push   $0x800249
  800665:	e8 19 fc ff ff       	call   800283 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80066a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80066d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800670:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800673:	83 c4 10             	add    $0x10,%esp
  800676:	eb 05                	jmp    80067d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800678:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80067d:	c9                   	leave  
  80067e:	c3                   	ret    

0080067f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80067f:	55                   	push   %ebp
  800680:	89 e5                	mov    %esp,%ebp
  800682:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800685:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800688:	50                   	push   %eax
  800689:	ff 75 10             	pushl  0x10(%ebp)
  80068c:	ff 75 0c             	pushl  0xc(%ebp)
  80068f:	ff 75 08             	pushl  0x8(%ebp)
  800692:	e8 9a ff ff ff       	call   800631 <vsnprintf>
	va_end(ap);

	return rc;
}
  800697:	c9                   	leave  
  800698:	c3                   	ret    

00800699 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800699:	55                   	push   %ebp
  80069a:	89 e5                	mov    %esp,%ebp
  80069c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80069f:	b8 00 00 00 00       	mov    $0x0,%eax
  8006a4:	eb 03                	jmp    8006a9 <strlen+0x10>
		n++;
  8006a6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006a9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006ad:	75 f7                	jne    8006a6 <strlen+0xd>
		n++;
	return n;
}
  8006af:	5d                   	pop    %ebp
  8006b0:	c3                   	ret    

008006b1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006b1:	55                   	push   %ebp
  8006b2:	89 e5                	mov    %esp,%ebp
  8006b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006b7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8006bf:	eb 03                	jmp    8006c4 <strnlen+0x13>
		n++;
  8006c1:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006c4:	39 c2                	cmp    %eax,%edx
  8006c6:	74 08                	je     8006d0 <strnlen+0x1f>
  8006c8:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006cc:	75 f3                	jne    8006c1 <strnlen+0x10>
  8006ce:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006d0:	5d                   	pop    %ebp
  8006d1:	c3                   	ret    

008006d2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006d2:	55                   	push   %ebp
  8006d3:	89 e5                	mov    %esp,%ebp
  8006d5:	53                   	push   %ebx
  8006d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006dc:	89 c2                	mov    %eax,%edx
  8006de:	83 c2 01             	add    $0x1,%edx
  8006e1:	83 c1 01             	add    $0x1,%ecx
  8006e4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8006e8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8006eb:	84 db                	test   %bl,%bl
  8006ed:	75 ef                	jne    8006de <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006ef:	5b                   	pop    %ebx
  8006f0:	5d                   	pop    %ebp
  8006f1:	c3                   	ret    

008006f2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006f2:	55                   	push   %ebp
  8006f3:	89 e5                	mov    %esp,%ebp
  8006f5:	53                   	push   %ebx
  8006f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006f9:	53                   	push   %ebx
  8006fa:	e8 9a ff ff ff       	call   800699 <strlen>
  8006ff:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800702:	ff 75 0c             	pushl  0xc(%ebp)
  800705:	01 d8                	add    %ebx,%eax
  800707:	50                   	push   %eax
  800708:	e8 c5 ff ff ff       	call   8006d2 <strcpy>
	return dst;
}
  80070d:	89 d8                	mov    %ebx,%eax
  80070f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800712:	c9                   	leave  
  800713:	c3                   	ret    

00800714 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	56                   	push   %esi
  800718:	53                   	push   %ebx
  800719:	8b 75 08             	mov    0x8(%ebp),%esi
  80071c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80071f:	89 f3                	mov    %esi,%ebx
  800721:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800724:	89 f2                	mov    %esi,%edx
  800726:	eb 0f                	jmp    800737 <strncpy+0x23>
		*dst++ = *src;
  800728:	83 c2 01             	add    $0x1,%edx
  80072b:	0f b6 01             	movzbl (%ecx),%eax
  80072e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800731:	80 39 01             	cmpb   $0x1,(%ecx)
  800734:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800737:	39 da                	cmp    %ebx,%edx
  800739:	75 ed                	jne    800728 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80073b:	89 f0                	mov    %esi,%eax
  80073d:	5b                   	pop    %ebx
  80073e:	5e                   	pop    %esi
  80073f:	5d                   	pop    %ebp
  800740:	c3                   	ret    

00800741 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800741:	55                   	push   %ebp
  800742:	89 e5                	mov    %esp,%ebp
  800744:	56                   	push   %esi
  800745:	53                   	push   %ebx
  800746:	8b 75 08             	mov    0x8(%ebp),%esi
  800749:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80074c:	8b 55 10             	mov    0x10(%ebp),%edx
  80074f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800751:	85 d2                	test   %edx,%edx
  800753:	74 21                	je     800776 <strlcpy+0x35>
  800755:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800759:	89 f2                	mov    %esi,%edx
  80075b:	eb 09                	jmp    800766 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80075d:	83 c2 01             	add    $0x1,%edx
  800760:	83 c1 01             	add    $0x1,%ecx
  800763:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800766:	39 c2                	cmp    %eax,%edx
  800768:	74 09                	je     800773 <strlcpy+0x32>
  80076a:	0f b6 19             	movzbl (%ecx),%ebx
  80076d:	84 db                	test   %bl,%bl
  80076f:	75 ec                	jne    80075d <strlcpy+0x1c>
  800771:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800773:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800776:	29 f0                	sub    %esi,%eax
}
  800778:	5b                   	pop    %ebx
  800779:	5e                   	pop    %esi
  80077a:	5d                   	pop    %ebp
  80077b:	c3                   	ret    

0080077c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800782:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800785:	eb 06                	jmp    80078d <strcmp+0x11>
		p++, q++;
  800787:	83 c1 01             	add    $0x1,%ecx
  80078a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80078d:	0f b6 01             	movzbl (%ecx),%eax
  800790:	84 c0                	test   %al,%al
  800792:	74 04                	je     800798 <strcmp+0x1c>
  800794:	3a 02                	cmp    (%edx),%al
  800796:	74 ef                	je     800787 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800798:	0f b6 c0             	movzbl %al,%eax
  80079b:	0f b6 12             	movzbl (%edx),%edx
  80079e:	29 d0                	sub    %edx,%eax
}
  8007a0:	5d                   	pop    %ebp
  8007a1:	c3                   	ret    

008007a2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	53                   	push   %ebx
  8007a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ac:	89 c3                	mov    %eax,%ebx
  8007ae:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007b1:	eb 06                	jmp    8007b9 <strncmp+0x17>
		n--, p++, q++;
  8007b3:	83 c0 01             	add    $0x1,%eax
  8007b6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007b9:	39 d8                	cmp    %ebx,%eax
  8007bb:	74 15                	je     8007d2 <strncmp+0x30>
  8007bd:	0f b6 08             	movzbl (%eax),%ecx
  8007c0:	84 c9                	test   %cl,%cl
  8007c2:	74 04                	je     8007c8 <strncmp+0x26>
  8007c4:	3a 0a                	cmp    (%edx),%cl
  8007c6:	74 eb                	je     8007b3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007c8:	0f b6 00             	movzbl (%eax),%eax
  8007cb:	0f b6 12             	movzbl (%edx),%edx
  8007ce:	29 d0                	sub    %edx,%eax
  8007d0:	eb 05                	jmp    8007d7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007d2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007d7:	5b                   	pop    %ebx
  8007d8:	5d                   	pop    %ebp
  8007d9:	c3                   	ret    

008007da <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007e4:	eb 07                	jmp    8007ed <strchr+0x13>
		if (*s == c)
  8007e6:	38 ca                	cmp    %cl,%dl
  8007e8:	74 0f                	je     8007f9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007ea:	83 c0 01             	add    $0x1,%eax
  8007ed:	0f b6 10             	movzbl (%eax),%edx
  8007f0:	84 d2                	test   %dl,%dl
  8007f2:	75 f2                	jne    8007e6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8007f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800801:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800805:	eb 03                	jmp    80080a <strfind+0xf>
  800807:	83 c0 01             	add    $0x1,%eax
  80080a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80080d:	38 ca                	cmp    %cl,%dl
  80080f:	74 04                	je     800815 <strfind+0x1a>
  800811:	84 d2                	test   %dl,%dl
  800813:	75 f2                	jne    800807 <strfind+0xc>
			break;
	return (char *) s;
}
  800815:	5d                   	pop    %ebp
  800816:	c3                   	ret    

00800817 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	57                   	push   %edi
  80081b:	56                   	push   %esi
  80081c:	53                   	push   %ebx
  80081d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800820:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800823:	85 c9                	test   %ecx,%ecx
  800825:	74 36                	je     80085d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800827:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80082d:	75 28                	jne    800857 <memset+0x40>
  80082f:	f6 c1 03             	test   $0x3,%cl
  800832:	75 23                	jne    800857 <memset+0x40>
		c &= 0xFF;
  800834:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800838:	89 d3                	mov    %edx,%ebx
  80083a:	c1 e3 08             	shl    $0x8,%ebx
  80083d:	89 d6                	mov    %edx,%esi
  80083f:	c1 e6 18             	shl    $0x18,%esi
  800842:	89 d0                	mov    %edx,%eax
  800844:	c1 e0 10             	shl    $0x10,%eax
  800847:	09 f0                	or     %esi,%eax
  800849:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80084b:	89 d8                	mov    %ebx,%eax
  80084d:	09 d0                	or     %edx,%eax
  80084f:	c1 e9 02             	shr    $0x2,%ecx
  800852:	fc                   	cld    
  800853:	f3 ab                	rep stos %eax,%es:(%edi)
  800855:	eb 06                	jmp    80085d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800857:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085a:	fc                   	cld    
  80085b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80085d:	89 f8                	mov    %edi,%eax
  80085f:	5b                   	pop    %ebx
  800860:	5e                   	pop    %esi
  800861:	5f                   	pop    %edi
  800862:	5d                   	pop    %ebp
  800863:	c3                   	ret    

00800864 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	57                   	push   %edi
  800868:	56                   	push   %esi
  800869:	8b 45 08             	mov    0x8(%ebp),%eax
  80086c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80086f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800872:	39 c6                	cmp    %eax,%esi
  800874:	73 35                	jae    8008ab <memmove+0x47>
  800876:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800879:	39 d0                	cmp    %edx,%eax
  80087b:	73 2e                	jae    8008ab <memmove+0x47>
		s += n;
		d += n;
  80087d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800880:	89 d6                	mov    %edx,%esi
  800882:	09 fe                	or     %edi,%esi
  800884:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80088a:	75 13                	jne    80089f <memmove+0x3b>
  80088c:	f6 c1 03             	test   $0x3,%cl
  80088f:	75 0e                	jne    80089f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800891:	83 ef 04             	sub    $0x4,%edi
  800894:	8d 72 fc             	lea    -0x4(%edx),%esi
  800897:	c1 e9 02             	shr    $0x2,%ecx
  80089a:	fd                   	std    
  80089b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80089d:	eb 09                	jmp    8008a8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80089f:	83 ef 01             	sub    $0x1,%edi
  8008a2:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008a5:	fd                   	std    
  8008a6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008a8:	fc                   	cld    
  8008a9:	eb 1d                	jmp    8008c8 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ab:	89 f2                	mov    %esi,%edx
  8008ad:	09 c2                	or     %eax,%edx
  8008af:	f6 c2 03             	test   $0x3,%dl
  8008b2:	75 0f                	jne    8008c3 <memmove+0x5f>
  8008b4:	f6 c1 03             	test   $0x3,%cl
  8008b7:	75 0a                	jne    8008c3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008b9:	c1 e9 02             	shr    $0x2,%ecx
  8008bc:	89 c7                	mov    %eax,%edi
  8008be:	fc                   	cld    
  8008bf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c1:	eb 05                	jmp    8008c8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008c3:	89 c7                	mov    %eax,%edi
  8008c5:	fc                   	cld    
  8008c6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008c8:	5e                   	pop    %esi
  8008c9:	5f                   	pop    %edi
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    

008008cc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008cf:	ff 75 10             	pushl  0x10(%ebp)
  8008d2:	ff 75 0c             	pushl  0xc(%ebp)
  8008d5:	ff 75 08             	pushl  0x8(%ebp)
  8008d8:	e8 87 ff ff ff       	call   800864 <memmove>
}
  8008dd:	c9                   	leave  
  8008de:	c3                   	ret    

008008df <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	56                   	push   %esi
  8008e3:	53                   	push   %ebx
  8008e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ea:	89 c6                	mov    %eax,%esi
  8008ec:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008ef:	eb 1a                	jmp    80090b <memcmp+0x2c>
		if (*s1 != *s2)
  8008f1:	0f b6 08             	movzbl (%eax),%ecx
  8008f4:	0f b6 1a             	movzbl (%edx),%ebx
  8008f7:	38 d9                	cmp    %bl,%cl
  8008f9:	74 0a                	je     800905 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8008fb:	0f b6 c1             	movzbl %cl,%eax
  8008fe:	0f b6 db             	movzbl %bl,%ebx
  800901:	29 d8                	sub    %ebx,%eax
  800903:	eb 0f                	jmp    800914 <memcmp+0x35>
		s1++, s2++;
  800905:	83 c0 01             	add    $0x1,%eax
  800908:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80090b:	39 f0                	cmp    %esi,%eax
  80090d:	75 e2                	jne    8008f1 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80090f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800914:	5b                   	pop    %ebx
  800915:	5e                   	pop    %esi
  800916:	5d                   	pop    %ebp
  800917:	c3                   	ret    

00800918 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	53                   	push   %ebx
  80091c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80091f:	89 c1                	mov    %eax,%ecx
  800921:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800924:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800928:	eb 0a                	jmp    800934 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80092a:	0f b6 10             	movzbl (%eax),%edx
  80092d:	39 da                	cmp    %ebx,%edx
  80092f:	74 07                	je     800938 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800931:	83 c0 01             	add    $0x1,%eax
  800934:	39 c8                	cmp    %ecx,%eax
  800936:	72 f2                	jb     80092a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800938:	5b                   	pop    %ebx
  800939:	5d                   	pop    %ebp
  80093a:	c3                   	ret    

0080093b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	57                   	push   %edi
  80093f:	56                   	push   %esi
  800940:	53                   	push   %ebx
  800941:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800944:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800947:	eb 03                	jmp    80094c <strtol+0x11>
		s++;
  800949:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80094c:	0f b6 01             	movzbl (%ecx),%eax
  80094f:	3c 20                	cmp    $0x20,%al
  800951:	74 f6                	je     800949 <strtol+0xe>
  800953:	3c 09                	cmp    $0x9,%al
  800955:	74 f2                	je     800949 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800957:	3c 2b                	cmp    $0x2b,%al
  800959:	75 0a                	jne    800965 <strtol+0x2a>
		s++;
  80095b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80095e:	bf 00 00 00 00       	mov    $0x0,%edi
  800963:	eb 11                	jmp    800976 <strtol+0x3b>
  800965:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80096a:	3c 2d                	cmp    $0x2d,%al
  80096c:	75 08                	jne    800976 <strtol+0x3b>
		s++, neg = 1;
  80096e:	83 c1 01             	add    $0x1,%ecx
  800971:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800976:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80097c:	75 15                	jne    800993 <strtol+0x58>
  80097e:	80 39 30             	cmpb   $0x30,(%ecx)
  800981:	75 10                	jne    800993 <strtol+0x58>
  800983:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800987:	75 7c                	jne    800a05 <strtol+0xca>
		s += 2, base = 16;
  800989:	83 c1 02             	add    $0x2,%ecx
  80098c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800991:	eb 16                	jmp    8009a9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800993:	85 db                	test   %ebx,%ebx
  800995:	75 12                	jne    8009a9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800997:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80099c:	80 39 30             	cmpb   $0x30,(%ecx)
  80099f:	75 08                	jne    8009a9 <strtol+0x6e>
		s++, base = 8;
  8009a1:	83 c1 01             	add    $0x1,%ecx
  8009a4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ae:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009b1:	0f b6 11             	movzbl (%ecx),%edx
  8009b4:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009b7:	89 f3                	mov    %esi,%ebx
  8009b9:	80 fb 09             	cmp    $0x9,%bl
  8009bc:	77 08                	ja     8009c6 <strtol+0x8b>
			dig = *s - '0';
  8009be:	0f be d2             	movsbl %dl,%edx
  8009c1:	83 ea 30             	sub    $0x30,%edx
  8009c4:	eb 22                	jmp    8009e8 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009c6:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009c9:	89 f3                	mov    %esi,%ebx
  8009cb:	80 fb 19             	cmp    $0x19,%bl
  8009ce:	77 08                	ja     8009d8 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009d0:	0f be d2             	movsbl %dl,%edx
  8009d3:	83 ea 57             	sub    $0x57,%edx
  8009d6:	eb 10                	jmp    8009e8 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009d8:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009db:	89 f3                	mov    %esi,%ebx
  8009dd:	80 fb 19             	cmp    $0x19,%bl
  8009e0:	77 16                	ja     8009f8 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8009e2:	0f be d2             	movsbl %dl,%edx
  8009e5:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8009e8:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009eb:	7d 0b                	jge    8009f8 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8009ed:	83 c1 01             	add    $0x1,%ecx
  8009f0:	0f af 45 10          	imul   0x10(%ebp),%eax
  8009f4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8009f6:	eb b9                	jmp    8009b1 <strtol+0x76>

	if (endptr)
  8009f8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009fc:	74 0d                	je     800a0b <strtol+0xd0>
		*endptr = (char *) s;
  8009fe:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a01:	89 0e                	mov    %ecx,(%esi)
  800a03:	eb 06                	jmp    800a0b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a05:	85 db                	test   %ebx,%ebx
  800a07:	74 98                	je     8009a1 <strtol+0x66>
  800a09:	eb 9e                	jmp    8009a9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a0b:	89 c2                	mov    %eax,%edx
  800a0d:	f7 da                	neg    %edx
  800a0f:	85 ff                	test   %edi,%edi
  800a11:	0f 45 c2             	cmovne %edx,%eax
}
  800a14:	5b                   	pop    %ebx
  800a15:	5e                   	pop    %esi
  800a16:	5f                   	pop    %edi
  800a17:	5d                   	pop    %ebp
  800a18:	c3                   	ret    

00800a19 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
  800a1c:	57                   	push   %edi
  800a1d:	56                   	push   %esi
  800a1e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a1f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a27:	8b 55 08             	mov    0x8(%ebp),%edx
  800a2a:	89 c3                	mov    %eax,%ebx
  800a2c:	89 c7                	mov    %eax,%edi
  800a2e:	89 c6                	mov    %eax,%esi
  800a30:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a32:	5b                   	pop    %ebx
  800a33:	5e                   	pop    %esi
  800a34:	5f                   	pop    %edi
  800a35:	5d                   	pop    %ebp
  800a36:	c3                   	ret    

00800a37 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	57                   	push   %edi
  800a3b:	56                   	push   %esi
  800a3c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a42:	b8 01 00 00 00       	mov    $0x1,%eax
  800a47:	89 d1                	mov    %edx,%ecx
  800a49:	89 d3                	mov    %edx,%ebx
  800a4b:	89 d7                	mov    %edx,%edi
  800a4d:	89 d6                	mov    %edx,%esi
  800a4f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a51:	5b                   	pop    %ebx
  800a52:	5e                   	pop    %esi
  800a53:	5f                   	pop    %edi
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	57                   	push   %edi
  800a5a:	56                   	push   %esi
  800a5b:	53                   	push   %ebx
  800a5c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a5f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a64:	b8 03 00 00 00       	mov    $0x3,%eax
  800a69:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6c:	89 cb                	mov    %ecx,%ebx
  800a6e:	89 cf                	mov    %ecx,%edi
  800a70:	89 ce                	mov    %ecx,%esi
  800a72:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a74:	85 c0                	test   %eax,%eax
  800a76:	7e 17                	jle    800a8f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a78:	83 ec 0c             	sub    $0xc,%esp
  800a7b:	50                   	push   %eax
  800a7c:	6a 03                	push   $0x3
  800a7e:	68 b4 0f 80 00       	push   $0x800fb4
  800a83:	6a 23                	push   $0x23
  800a85:	68 d1 0f 80 00       	push   $0x800fd1
  800a8a:	e8 27 00 00 00       	call   800ab6 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a92:	5b                   	pop    %ebx
  800a93:	5e                   	pop    %esi
  800a94:	5f                   	pop    %edi
  800a95:	5d                   	pop    %ebp
  800a96:	c3                   	ret    

00800a97 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	57                   	push   %edi
  800a9b:	56                   	push   %esi
  800a9c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa2:	b8 02 00 00 00       	mov    $0x2,%eax
  800aa7:	89 d1                	mov    %edx,%ecx
  800aa9:	89 d3                	mov    %edx,%ebx
  800aab:	89 d7                	mov    %edx,%edi
  800aad:	89 d6                	mov    %edx,%esi
  800aaf:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ab1:	5b                   	pop    %ebx
  800ab2:	5e                   	pop    %esi
  800ab3:	5f                   	pop    %edi
  800ab4:	5d                   	pop    %ebp
  800ab5:	c3                   	ret    

00800ab6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ab6:	55                   	push   %ebp
  800ab7:	89 e5                	mov    %esp,%ebp
  800ab9:	56                   	push   %esi
  800aba:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800abb:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800abe:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800ac4:	e8 ce ff ff ff       	call   800a97 <sys_getenvid>
  800ac9:	83 ec 0c             	sub    $0xc,%esp
  800acc:	ff 75 0c             	pushl  0xc(%ebp)
  800acf:	ff 75 08             	pushl  0x8(%ebp)
  800ad2:	56                   	push   %esi
  800ad3:	50                   	push   %eax
  800ad4:	68 e0 0f 80 00       	push   $0x800fe0
  800ad9:	e8 6e f6 ff ff       	call   80014c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ade:	83 c4 18             	add    $0x18,%esp
  800ae1:	53                   	push   %ebx
  800ae2:	ff 75 10             	pushl  0x10(%ebp)
  800ae5:	e8 11 f6 ff ff       	call   8000fb <vcprintf>
	cprintf("\n");
  800aea:	c7 04 24 90 0d 80 00 	movl   $0x800d90,(%esp)
  800af1:	e8 56 f6 ff ff       	call   80014c <cprintf>
  800af6:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800af9:	cc                   	int3   
  800afa:	eb fd                	jmp    800af9 <_panic+0x43>
  800afc:	66 90                	xchg   %ax,%ax
  800afe:	66 90                	xchg   %ax,%ax

00800b00 <__udivdi3>:
  800b00:	55                   	push   %ebp
  800b01:	57                   	push   %edi
  800b02:	56                   	push   %esi
  800b03:	53                   	push   %ebx
  800b04:	83 ec 1c             	sub    $0x1c,%esp
  800b07:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800b0b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800b0f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800b13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800b17:	85 f6                	test   %esi,%esi
  800b19:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800b1d:	89 ca                	mov    %ecx,%edx
  800b1f:	89 f8                	mov    %edi,%eax
  800b21:	75 3d                	jne    800b60 <__udivdi3+0x60>
  800b23:	39 cf                	cmp    %ecx,%edi
  800b25:	0f 87 c5 00 00 00    	ja     800bf0 <__udivdi3+0xf0>
  800b2b:	85 ff                	test   %edi,%edi
  800b2d:	89 fd                	mov    %edi,%ebp
  800b2f:	75 0b                	jne    800b3c <__udivdi3+0x3c>
  800b31:	b8 01 00 00 00       	mov    $0x1,%eax
  800b36:	31 d2                	xor    %edx,%edx
  800b38:	f7 f7                	div    %edi
  800b3a:	89 c5                	mov    %eax,%ebp
  800b3c:	89 c8                	mov    %ecx,%eax
  800b3e:	31 d2                	xor    %edx,%edx
  800b40:	f7 f5                	div    %ebp
  800b42:	89 c1                	mov    %eax,%ecx
  800b44:	89 d8                	mov    %ebx,%eax
  800b46:	89 cf                	mov    %ecx,%edi
  800b48:	f7 f5                	div    %ebp
  800b4a:	89 c3                	mov    %eax,%ebx
  800b4c:	89 d8                	mov    %ebx,%eax
  800b4e:	89 fa                	mov    %edi,%edx
  800b50:	83 c4 1c             	add    $0x1c,%esp
  800b53:	5b                   	pop    %ebx
  800b54:	5e                   	pop    %esi
  800b55:	5f                   	pop    %edi
  800b56:	5d                   	pop    %ebp
  800b57:	c3                   	ret    
  800b58:	90                   	nop
  800b59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800b60:	39 ce                	cmp    %ecx,%esi
  800b62:	77 74                	ja     800bd8 <__udivdi3+0xd8>
  800b64:	0f bd fe             	bsr    %esi,%edi
  800b67:	83 f7 1f             	xor    $0x1f,%edi
  800b6a:	0f 84 98 00 00 00    	je     800c08 <__udivdi3+0x108>
  800b70:	bb 20 00 00 00       	mov    $0x20,%ebx
  800b75:	89 f9                	mov    %edi,%ecx
  800b77:	89 c5                	mov    %eax,%ebp
  800b79:	29 fb                	sub    %edi,%ebx
  800b7b:	d3 e6                	shl    %cl,%esi
  800b7d:	89 d9                	mov    %ebx,%ecx
  800b7f:	d3 ed                	shr    %cl,%ebp
  800b81:	89 f9                	mov    %edi,%ecx
  800b83:	d3 e0                	shl    %cl,%eax
  800b85:	09 ee                	or     %ebp,%esi
  800b87:	89 d9                	mov    %ebx,%ecx
  800b89:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b8d:	89 d5                	mov    %edx,%ebp
  800b8f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800b93:	d3 ed                	shr    %cl,%ebp
  800b95:	89 f9                	mov    %edi,%ecx
  800b97:	d3 e2                	shl    %cl,%edx
  800b99:	89 d9                	mov    %ebx,%ecx
  800b9b:	d3 e8                	shr    %cl,%eax
  800b9d:	09 c2                	or     %eax,%edx
  800b9f:	89 d0                	mov    %edx,%eax
  800ba1:	89 ea                	mov    %ebp,%edx
  800ba3:	f7 f6                	div    %esi
  800ba5:	89 d5                	mov    %edx,%ebp
  800ba7:	89 c3                	mov    %eax,%ebx
  800ba9:	f7 64 24 0c          	mull   0xc(%esp)
  800bad:	39 d5                	cmp    %edx,%ebp
  800baf:	72 10                	jb     800bc1 <__udivdi3+0xc1>
  800bb1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800bb5:	89 f9                	mov    %edi,%ecx
  800bb7:	d3 e6                	shl    %cl,%esi
  800bb9:	39 c6                	cmp    %eax,%esi
  800bbb:	73 07                	jae    800bc4 <__udivdi3+0xc4>
  800bbd:	39 d5                	cmp    %edx,%ebp
  800bbf:	75 03                	jne    800bc4 <__udivdi3+0xc4>
  800bc1:	83 eb 01             	sub    $0x1,%ebx
  800bc4:	31 ff                	xor    %edi,%edi
  800bc6:	89 d8                	mov    %ebx,%eax
  800bc8:	89 fa                	mov    %edi,%edx
  800bca:	83 c4 1c             	add    $0x1c,%esp
  800bcd:	5b                   	pop    %ebx
  800bce:	5e                   	pop    %esi
  800bcf:	5f                   	pop    %edi
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    
  800bd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800bd8:	31 ff                	xor    %edi,%edi
  800bda:	31 db                	xor    %ebx,%ebx
  800bdc:	89 d8                	mov    %ebx,%eax
  800bde:	89 fa                	mov    %edi,%edx
  800be0:	83 c4 1c             	add    $0x1c,%esp
  800be3:	5b                   	pop    %ebx
  800be4:	5e                   	pop    %esi
  800be5:	5f                   	pop    %edi
  800be6:	5d                   	pop    %ebp
  800be7:	c3                   	ret    
  800be8:	90                   	nop
  800be9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800bf0:	89 d8                	mov    %ebx,%eax
  800bf2:	f7 f7                	div    %edi
  800bf4:	31 ff                	xor    %edi,%edi
  800bf6:	89 c3                	mov    %eax,%ebx
  800bf8:	89 d8                	mov    %ebx,%eax
  800bfa:	89 fa                	mov    %edi,%edx
  800bfc:	83 c4 1c             	add    $0x1c,%esp
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    
  800c04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c08:	39 ce                	cmp    %ecx,%esi
  800c0a:	72 0c                	jb     800c18 <__udivdi3+0x118>
  800c0c:	31 db                	xor    %ebx,%ebx
  800c0e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800c12:	0f 87 34 ff ff ff    	ja     800b4c <__udivdi3+0x4c>
  800c18:	bb 01 00 00 00       	mov    $0x1,%ebx
  800c1d:	e9 2a ff ff ff       	jmp    800b4c <__udivdi3+0x4c>
  800c22:	66 90                	xchg   %ax,%ax
  800c24:	66 90                	xchg   %ax,%ax
  800c26:	66 90                	xchg   %ax,%ax
  800c28:	66 90                	xchg   %ax,%ax
  800c2a:	66 90                	xchg   %ax,%ax
  800c2c:	66 90                	xchg   %ax,%ax
  800c2e:	66 90                	xchg   %ax,%ax

00800c30 <__umoddi3>:
  800c30:	55                   	push   %ebp
  800c31:	57                   	push   %edi
  800c32:	56                   	push   %esi
  800c33:	53                   	push   %ebx
  800c34:	83 ec 1c             	sub    $0x1c,%esp
  800c37:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c3b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800c3f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800c47:	85 d2                	test   %edx,%edx
  800c49:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800c4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c51:	89 f3                	mov    %esi,%ebx
  800c53:	89 3c 24             	mov    %edi,(%esp)
  800c56:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c5a:	75 1c                	jne    800c78 <__umoddi3+0x48>
  800c5c:	39 f7                	cmp    %esi,%edi
  800c5e:	76 50                	jbe    800cb0 <__umoddi3+0x80>
  800c60:	89 c8                	mov    %ecx,%eax
  800c62:	89 f2                	mov    %esi,%edx
  800c64:	f7 f7                	div    %edi
  800c66:	89 d0                	mov    %edx,%eax
  800c68:	31 d2                	xor    %edx,%edx
  800c6a:	83 c4 1c             	add    $0x1c,%esp
  800c6d:	5b                   	pop    %ebx
  800c6e:	5e                   	pop    %esi
  800c6f:	5f                   	pop    %edi
  800c70:	5d                   	pop    %ebp
  800c71:	c3                   	ret    
  800c72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c78:	39 f2                	cmp    %esi,%edx
  800c7a:	89 d0                	mov    %edx,%eax
  800c7c:	77 52                	ja     800cd0 <__umoddi3+0xa0>
  800c7e:	0f bd ea             	bsr    %edx,%ebp
  800c81:	83 f5 1f             	xor    $0x1f,%ebp
  800c84:	75 5a                	jne    800ce0 <__umoddi3+0xb0>
  800c86:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800c8a:	0f 82 e0 00 00 00    	jb     800d70 <__umoddi3+0x140>
  800c90:	39 0c 24             	cmp    %ecx,(%esp)
  800c93:	0f 86 d7 00 00 00    	jbe    800d70 <__umoddi3+0x140>
  800c99:	8b 44 24 08          	mov    0x8(%esp),%eax
  800c9d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ca1:	83 c4 1c             	add    $0x1c,%esp
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    
  800ca9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800cb0:	85 ff                	test   %edi,%edi
  800cb2:	89 fd                	mov    %edi,%ebp
  800cb4:	75 0b                	jne    800cc1 <__umoddi3+0x91>
  800cb6:	b8 01 00 00 00       	mov    $0x1,%eax
  800cbb:	31 d2                	xor    %edx,%edx
  800cbd:	f7 f7                	div    %edi
  800cbf:	89 c5                	mov    %eax,%ebp
  800cc1:	89 f0                	mov    %esi,%eax
  800cc3:	31 d2                	xor    %edx,%edx
  800cc5:	f7 f5                	div    %ebp
  800cc7:	89 c8                	mov    %ecx,%eax
  800cc9:	f7 f5                	div    %ebp
  800ccb:	89 d0                	mov    %edx,%eax
  800ccd:	eb 99                	jmp    800c68 <__umoddi3+0x38>
  800ccf:	90                   	nop
  800cd0:	89 c8                	mov    %ecx,%eax
  800cd2:	89 f2                	mov    %esi,%edx
  800cd4:	83 c4 1c             	add    $0x1c,%esp
  800cd7:	5b                   	pop    %ebx
  800cd8:	5e                   	pop    %esi
  800cd9:	5f                   	pop    %edi
  800cda:	5d                   	pop    %ebp
  800cdb:	c3                   	ret    
  800cdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ce0:	8b 34 24             	mov    (%esp),%esi
  800ce3:	bf 20 00 00 00       	mov    $0x20,%edi
  800ce8:	89 e9                	mov    %ebp,%ecx
  800cea:	29 ef                	sub    %ebp,%edi
  800cec:	d3 e0                	shl    %cl,%eax
  800cee:	89 f9                	mov    %edi,%ecx
  800cf0:	89 f2                	mov    %esi,%edx
  800cf2:	d3 ea                	shr    %cl,%edx
  800cf4:	89 e9                	mov    %ebp,%ecx
  800cf6:	09 c2                	or     %eax,%edx
  800cf8:	89 d8                	mov    %ebx,%eax
  800cfa:	89 14 24             	mov    %edx,(%esp)
  800cfd:	89 f2                	mov    %esi,%edx
  800cff:	d3 e2                	shl    %cl,%edx
  800d01:	89 f9                	mov    %edi,%ecx
  800d03:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d07:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800d0b:	d3 e8                	shr    %cl,%eax
  800d0d:	89 e9                	mov    %ebp,%ecx
  800d0f:	89 c6                	mov    %eax,%esi
  800d11:	d3 e3                	shl    %cl,%ebx
  800d13:	89 f9                	mov    %edi,%ecx
  800d15:	89 d0                	mov    %edx,%eax
  800d17:	d3 e8                	shr    %cl,%eax
  800d19:	89 e9                	mov    %ebp,%ecx
  800d1b:	09 d8                	or     %ebx,%eax
  800d1d:	89 d3                	mov    %edx,%ebx
  800d1f:	89 f2                	mov    %esi,%edx
  800d21:	f7 34 24             	divl   (%esp)
  800d24:	89 d6                	mov    %edx,%esi
  800d26:	d3 e3                	shl    %cl,%ebx
  800d28:	f7 64 24 04          	mull   0x4(%esp)
  800d2c:	39 d6                	cmp    %edx,%esi
  800d2e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d32:	89 d1                	mov    %edx,%ecx
  800d34:	89 c3                	mov    %eax,%ebx
  800d36:	72 08                	jb     800d40 <__umoddi3+0x110>
  800d38:	75 11                	jne    800d4b <__umoddi3+0x11b>
  800d3a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800d3e:	73 0b                	jae    800d4b <__umoddi3+0x11b>
  800d40:	2b 44 24 04          	sub    0x4(%esp),%eax
  800d44:	1b 14 24             	sbb    (%esp),%edx
  800d47:	89 d1                	mov    %edx,%ecx
  800d49:	89 c3                	mov    %eax,%ebx
  800d4b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800d4f:	29 da                	sub    %ebx,%edx
  800d51:	19 ce                	sbb    %ecx,%esi
  800d53:	89 f9                	mov    %edi,%ecx
  800d55:	89 f0                	mov    %esi,%eax
  800d57:	d3 e0                	shl    %cl,%eax
  800d59:	89 e9                	mov    %ebp,%ecx
  800d5b:	d3 ea                	shr    %cl,%edx
  800d5d:	89 e9                	mov    %ebp,%ecx
  800d5f:	d3 ee                	shr    %cl,%esi
  800d61:	09 d0                	or     %edx,%eax
  800d63:	89 f2                	mov    %esi,%edx
  800d65:	83 c4 1c             	add    $0x1c,%esp
  800d68:	5b                   	pop    %ebx
  800d69:	5e                   	pop    %esi
  800d6a:	5f                   	pop    %edi
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    
  800d6d:	8d 76 00             	lea    0x0(%esi),%esi
  800d70:	29 f9                	sub    %edi,%ecx
  800d72:	19 d6                	sbb    %edx,%esi
  800d74:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d78:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d7c:	e9 18 ff ff ff       	jmp    800c99 <__umoddi3+0x69>
