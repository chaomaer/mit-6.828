
obj/user/faultread:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
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
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  800039:	ff 35 00 00 00 00    	pushl  0x0
  80003f:	68 74 0d 80 00       	push   $0x800d74
  800044:	e8 f3 00 00 00       	call   80013c <cprintf>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    thisenv = envs + ENVX(sys_getenvid());
  800059:	e8 29 0a 00 00       	call   800a87 <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800066:	c1 e0 05             	shl    $0x5,%eax
  800069:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006e:	a3 04 10 80 00       	mov    %eax,0x801004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800073:	85 db                	test   %ebx,%ebx
  800075:	7e 07                	jle    80007e <libmain+0x30>
		binaryname = argv[0];
  800077:	8b 06                	mov    (%esi),%eax
  800079:	a3 00 10 80 00       	mov    %eax,0x801000

	// call user main routine
	umain(argc, argv);
  80007e:	83 ec 08             	sub    $0x8,%esp
  800081:	56                   	push   %esi
  800082:	53                   	push   %ebx
  800083:	e8 ab ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800088:	e8 0a 00 00 00       	call   800097 <exit>
}
  80008d:	83 c4 10             	add    $0x10,%esp
  800090:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800093:	5b                   	pop    %ebx
  800094:	5e                   	pop    %esi
  800095:	5d                   	pop    %ebp
  800096:	c3                   	ret    

00800097 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800097:	55                   	push   %ebp
  800098:	89 e5                	mov    %esp,%ebp
  80009a:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009d:	6a 00                	push   $0x0
  80009f:	e8 a2 09 00 00       	call   800a46 <sys_env_destroy>
}
  8000a4:	83 c4 10             	add    $0x10,%esp
  8000a7:	c9                   	leave  
  8000a8:	c3                   	ret    

008000a9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000a9:	55                   	push   %ebp
  8000aa:	89 e5                	mov    %esp,%ebp
  8000ac:	53                   	push   %ebx
  8000ad:	83 ec 04             	sub    $0x4,%esp
  8000b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b3:	8b 13                	mov    (%ebx),%edx
  8000b5:	8d 42 01             	lea    0x1(%edx),%eax
  8000b8:	89 03                	mov    %eax,(%ebx)
  8000ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000bd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000c1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000c6:	75 1a                	jne    8000e2 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000c8:	83 ec 08             	sub    $0x8,%esp
  8000cb:	68 ff 00 00 00       	push   $0xff
  8000d0:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d3:	50                   	push   %eax
  8000d4:	e8 30 09 00 00       	call   800a09 <sys_cputs>
		b->idx = 0;
  8000d9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000df:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000e2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e9:	c9                   	leave  
  8000ea:	c3                   	ret    

008000eb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000f4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000fb:	00 00 00 
	b.cnt = 0;
  8000fe:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800105:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800108:	ff 75 0c             	pushl  0xc(%ebp)
  80010b:	ff 75 08             	pushl  0x8(%ebp)
  80010e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800114:	50                   	push   %eax
  800115:	68 a9 00 80 00       	push   $0x8000a9
  80011a:	e8 54 01 00 00       	call   800273 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80011f:	83 c4 08             	add    $0x8,%esp
  800122:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800128:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80012e:	50                   	push   %eax
  80012f:	e8 d5 08 00 00       	call   800a09 <sys_cputs>

	return b.cnt;
}
  800134:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800142:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800145:	50                   	push   %eax
  800146:	ff 75 08             	pushl  0x8(%ebp)
  800149:	e8 9d ff ff ff       	call   8000eb <vcprintf>
	va_end(ap);

	return cnt;
}
  80014e:	c9                   	leave  
  80014f:	c3                   	ret    

00800150 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	57                   	push   %edi
  800154:	56                   	push   %esi
  800155:	53                   	push   %ebx
  800156:	83 ec 1c             	sub    $0x1c,%esp
  800159:	89 c7                	mov    %eax,%edi
  80015b:	89 d6                	mov    %edx,%esi
  80015d:	8b 45 08             	mov    0x8(%ebp),%eax
  800160:	8b 55 0c             	mov    0xc(%ebp),%edx
  800163:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800166:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800169:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80016c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800171:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800174:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800177:	39 d3                	cmp    %edx,%ebx
  800179:	72 05                	jb     800180 <printnum+0x30>
  80017b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80017e:	77 45                	ja     8001c5 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800180:	83 ec 0c             	sub    $0xc,%esp
  800183:	ff 75 18             	pushl  0x18(%ebp)
  800186:	8b 45 14             	mov    0x14(%ebp),%eax
  800189:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80018c:	53                   	push   %ebx
  80018d:	ff 75 10             	pushl  0x10(%ebp)
  800190:	83 ec 08             	sub    $0x8,%esp
  800193:	ff 75 e4             	pushl  -0x1c(%ebp)
  800196:	ff 75 e0             	pushl  -0x20(%ebp)
  800199:	ff 75 dc             	pushl  -0x24(%ebp)
  80019c:	ff 75 d8             	pushl  -0x28(%ebp)
  80019f:	e8 4c 09 00 00       	call   800af0 <__udivdi3>
  8001a4:	83 c4 18             	add    $0x18,%esp
  8001a7:	52                   	push   %edx
  8001a8:	50                   	push   %eax
  8001a9:	89 f2                	mov    %esi,%edx
  8001ab:	89 f8                	mov    %edi,%eax
  8001ad:	e8 9e ff ff ff       	call   800150 <printnum>
  8001b2:	83 c4 20             	add    $0x20,%esp
  8001b5:	eb 18                	jmp    8001cf <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001b7:	83 ec 08             	sub    $0x8,%esp
  8001ba:	56                   	push   %esi
  8001bb:	ff 75 18             	pushl  0x18(%ebp)
  8001be:	ff d7                	call   *%edi
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	eb 03                	jmp    8001c8 <printnum+0x78>
  8001c5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001c8:	83 eb 01             	sub    $0x1,%ebx
  8001cb:	85 db                	test   %ebx,%ebx
  8001cd:	7f e8                	jg     8001b7 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001cf:	83 ec 08             	sub    $0x8,%esp
  8001d2:	56                   	push   %esi
  8001d3:	83 ec 04             	sub    $0x4,%esp
  8001d6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001d9:	ff 75 e0             	pushl  -0x20(%ebp)
  8001dc:	ff 75 dc             	pushl  -0x24(%ebp)
  8001df:	ff 75 d8             	pushl  -0x28(%ebp)
  8001e2:	e8 39 0a 00 00       	call   800c20 <__umoddi3>
  8001e7:	83 c4 14             	add    $0x14,%esp
  8001ea:	0f be 80 9c 0d 80 00 	movsbl 0x800d9c(%eax),%eax
  8001f1:	50                   	push   %eax
  8001f2:	ff d7                	call   *%edi
}
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001fa:	5b                   	pop    %ebx
  8001fb:	5e                   	pop    %esi
  8001fc:	5f                   	pop    %edi
  8001fd:	5d                   	pop    %ebp
  8001fe:	c3                   	ret    

008001ff <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8001ff:	55                   	push   %ebp
  800200:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800202:	83 fa 01             	cmp    $0x1,%edx
  800205:	7e 0e                	jle    800215 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800207:	8b 10                	mov    (%eax),%edx
  800209:	8d 4a 08             	lea    0x8(%edx),%ecx
  80020c:	89 08                	mov    %ecx,(%eax)
  80020e:	8b 02                	mov    (%edx),%eax
  800210:	8b 52 04             	mov    0x4(%edx),%edx
  800213:	eb 22                	jmp    800237 <getuint+0x38>
	else if (lflag)
  800215:	85 d2                	test   %edx,%edx
  800217:	74 10                	je     800229 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800219:	8b 10                	mov    (%eax),%edx
  80021b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80021e:	89 08                	mov    %ecx,(%eax)
  800220:	8b 02                	mov    (%edx),%eax
  800222:	ba 00 00 00 00       	mov    $0x0,%edx
  800227:	eb 0e                	jmp    800237 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800229:	8b 10                	mov    (%eax),%edx
  80022b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80022e:	89 08                	mov    %ecx,(%eax)
  800230:	8b 02                	mov    (%edx),%eax
  800232:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800237:	5d                   	pop    %ebp
  800238:	c3                   	ret    

00800239 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800239:	55                   	push   %ebp
  80023a:	89 e5                	mov    %esp,%ebp
  80023c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80023f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800243:	8b 10                	mov    (%eax),%edx
  800245:	3b 50 04             	cmp    0x4(%eax),%edx
  800248:	73 0a                	jae    800254 <sprintputch+0x1b>
		*b->buf++ = ch;
  80024a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80024d:	89 08                	mov    %ecx,(%eax)
  80024f:	8b 45 08             	mov    0x8(%ebp),%eax
  800252:	88 02                	mov    %al,(%edx)
}
  800254:	5d                   	pop    %ebp
  800255:	c3                   	ret    

00800256 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800256:	55                   	push   %ebp
  800257:	89 e5                	mov    %esp,%ebp
  800259:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80025c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80025f:	50                   	push   %eax
  800260:	ff 75 10             	pushl  0x10(%ebp)
  800263:	ff 75 0c             	pushl  0xc(%ebp)
  800266:	ff 75 08             	pushl  0x8(%ebp)
  800269:	e8 05 00 00 00       	call   800273 <vprintfmt>
	va_end(ap);
}
  80026e:	83 c4 10             	add    $0x10,%esp
  800271:	c9                   	leave  
  800272:	c3                   	ret    

00800273 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	57                   	push   %edi
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	83 ec 2c             	sub    $0x2c,%esp
  80027c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
    int color = 0;
  80027f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800286:	eb 17                	jmp    80029f <vprintfmt+0x2c>
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800288:	85 c0                	test   %eax,%eax
  80028a:	0f 84 89 03 00 00    	je     800619 <vprintfmt+0x3a6>
				return;
			putch(ch, putdat);
  800290:	83 ec 08             	sub    $0x8,%esp
  800293:	ff 75 0c             	pushl  0xc(%ebp)
  800296:	50                   	push   %eax
  800297:	ff 55 08             	call   *0x8(%ebp)
  80029a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
    int color = 0;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80029d:	89 f3                	mov    %esi,%ebx
  80029f:	8d 73 01             	lea    0x1(%ebx),%esi
  8002a2:	0f b6 03             	movzbl (%ebx),%eax
  8002a5:	83 f8 25             	cmp    $0x25,%eax
  8002a8:	75 de                	jne    800288 <vprintfmt+0x15>
  8002aa:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8002ae:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002b5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8002ba:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c6:	eb 0d                	jmp    8002d5 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002c8:	89 de                	mov    %ebx,%esi
  8002ca:	eb 09                	jmp    8002d5 <vprintfmt+0x62>
  8002cc:	89 de                	mov    %ebx,%esi
			break;
        case 'C': 
        //自己补充的控制颜色的代码
            switch(va_arg(ap,int)){
                case 0:
                    color = 0x0c00;
  8002ce:	c7 45 d8 00 0c 00 00 	movl   $0xc00,-0x28(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d5:	8d 5e 01             	lea    0x1(%esi),%ebx
  8002d8:	0f b6 06             	movzbl (%esi),%eax
  8002db:	0f b6 c8             	movzbl %al,%ecx
  8002de:	83 e8 23             	sub    $0x23,%eax
  8002e1:	3c 55                	cmp    $0x55,%al
  8002e3:	0f 87 10 03 00 00    	ja     8005f9 <vprintfmt+0x386>
  8002e9:	0f b6 c0             	movzbl %al,%eax
  8002ec:	ff 24 85 2c 0e 80 00 	jmp    *0x800e2c(,%eax,4)
  8002f3:	89 de                	mov    %ebx,%esi
		case '-':
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002f5:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8002f9:	eb da                	jmp    8002d5 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002fb:	89 de                	mov    %ebx,%esi
  8002fd:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800302:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  800305:	8d 7c 41 d0          	lea    -0x30(%ecx,%eax,2),%edi
				ch = *fmt;
  800309:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
  80030c:	8d 41 d0             	lea    -0x30(%ecx),%eax
  80030f:	83 f8 09             	cmp    $0x9,%eax
  800312:	77 33                	ja     800347 <vprintfmt+0xd4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800314:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800317:	eb e9                	jmp    800302 <vprintfmt+0x8f>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800319:	8b 45 14             	mov    0x14(%ebp),%eax
  80031c:	8d 48 04             	lea    0x4(%eax),%ecx
  80031f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800322:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800324:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800326:	eb 1f                	jmp    800347 <vprintfmt+0xd4>
  800328:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80032b:	85 c0                	test   %eax,%eax
  80032d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800332:	0f 49 c8             	cmovns %eax,%ecx
  800335:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800338:	89 de                	mov    %ebx,%esi
  80033a:	eb 99                	jmp    8002d5 <vprintfmt+0x62>
  80033c:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80033e:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
  800345:	eb 8e                	jmp    8002d5 <vprintfmt+0x62>

		process_precision:
			if (width < 0)
  800347:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80034b:	79 88                	jns    8002d5 <vprintfmt+0x62>
				width = precision, precision = -1;
  80034d:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800350:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800355:	e9 7b ff ff ff       	jmp    8002d5 <vprintfmt+0x62>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80035a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035d:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80035f:	e9 71 ff ff ff       	jmp    8002d5 <vprintfmt+0x62>

		case 'c':
            ch = va_arg(ap,int)+color;
  800364:	8b 45 14             	mov    0x14(%ebp),%eax
  800367:	8d 50 04             	lea    0x4(%eax),%edx
  80036a:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
  80036d:	83 ec 08             	sub    $0x8,%esp
  800370:	ff 75 0c             	pushl  0xc(%ebp)
  800373:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800376:	03 08                	add    (%eax),%ecx
  800378:	51                   	push   %ecx
  800379:	ff 55 08             	call   *0x8(%ebp)
            color = 0;
			break;
  80037c:	83 c4 10             	add    $0x10,%esp
			goto reswitch;

		case 'c':
            ch = va_arg(ap,int)+color;
			putch(ch, putdat);
            color = 0;
  80037f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
			break;
  800386:	e9 14 ff ff ff       	jmp    80029f <vprintfmt+0x2c>
        case 'C': 
        //自己补充的控制颜色的代码
            switch(va_arg(ap,int)){
  80038b:	8b 45 14             	mov    0x14(%ebp),%eax
  80038e:	8d 48 04             	lea    0x4(%eax),%ecx
  800391:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800394:	8b 00                	mov    (%eax),%eax
  800396:	85 c0                	test   %eax,%eax
  800398:	0f 84 2e ff ff ff    	je     8002cc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	89 de                	mov    %ebx,%esi
  8003a0:	83 f8 01             	cmp    $0x1,%eax
  8003a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a8:	b9 00 0a 00 00       	mov    $0xa00,%ecx
  8003ad:	0f 44 c1             	cmove  %ecx,%eax
  8003b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003b3:	e9 1d ff ff ff       	jmp    8002d5 <vprintfmt+0x62>
            }

            goto reswitch;
		// error message
		case 'e':
			err = va_arg(ap, int);
  8003b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bb:	8d 50 04             	lea    0x4(%eax),%edx
  8003be:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c1:	8b 00                	mov    (%eax),%eax
  8003c3:	99                   	cltd   
  8003c4:	31 d0                	xor    %edx,%eax
  8003c6:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003c8:	83 f8 06             	cmp    $0x6,%eax
  8003cb:	7f 0b                	jg     8003d8 <vprintfmt+0x165>
  8003cd:	8b 14 85 84 0f 80 00 	mov    0x800f84(,%eax,4),%edx
  8003d4:	85 d2                	test   %edx,%edx
  8003d6:	75 19                	jne    8003f1 <vprintfmt+0x17e>
				printfmt(putch, putdat, "error %d", err);
  8003d8:	50                   	push   %eax
  8003d9:	68 b4 0d 80 00       	push   $0x800db4
  8003de:	ff 75 0c             	pushl  0xc(%ebp)
  8003e1:	ff 75 08             	pushl  0x8(%ebp)
  8003e4:	e8 6d fe ff ff       	call   800256 <printfmt>
  8003e9:	83 c4 10             	add    $0x10,%esp
  8003ec:	e9 ae fe ff ff       	jmp    80029f <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
  8003f1:	52                   	push   %edx
  8003f2:	68 bd 0d 80 00       	push   $0x800dbd
  8003f7:	ff 75 0c             	pushl  0xc(%ebp)
  8003fa:	ff 75 08             	pushl  0x8(%ebp)
  8003fd:	e8 54 fe ff ff       	call   800256 <printfmt>
  800402:	83 c4 10             	add    $0x10,%esp
  800405:	e9 95 fe ff ff       	jmp    80029f <vprintfmt+0x2c>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80040a:	8b 45 14             	mov    0x14(%ebp),%eax
  80040d:	8d 50 04             	lea    0x4(%eax),%edx
  800410:	89 55 14             	mov    %edx,0x14(%ebp)
  800413:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800415:	85 f6                	test   %esi,%esi
  800417:	b8 ad 0d 80 00       	mov    $0x800dad,%eax
  80041c:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  80041f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800423:	0f 8e 89 00 00 00    	jle    8004b2 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800429:	83 ec 08             	sub    $0x8,%esp
  80042c:	57                   	push   %edi
  80042d:	56                   	push   %esi
  80042e:	e8 6e 02 00 00       	call   8006a1 <strnlen>
  800433:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800436:	29 c1                	sub    %eax,%ecx
  800438:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80043b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80043e:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  800442:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800445:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800448:	8b 75 0c             	mov    0xc(%ebp),%esi
  80044b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80044e:	89 cb                	mov    %ecx,%ebx
  800450:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800452:	eb 0e                	jmp    800462 <vprintfmt+0x1ef>
					putch(padc, putdat);
  800454:	83 ec 08             	sub    $0x8,%esp
  800457:	56                   	push   %esi
  800458:	57                   	push   %edi
  800459:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80045c:	83 eb 01             	sub    $0x1,%ebx
  80045f:	83 c4 10             	add    $0x10,%esp
  800462:	85 db                	test   %ebx,%ebx
  800464:	7f ee                	jg     800454 <vprintfmt+0x1e1>
  800466:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800469:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80046c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80046f:	85 c9                	test   %ecx,%ecx
  800471:	b8 00 00 00 00       	mov    $0x0,%eax
  800476:	0f 49 c1             	cmovns %ecx,%eax
  800479:	29 c1                	sub    %eax,%ecx
  80047b:	89 cb                	mov    %ecx,%ebx
  80047d:	eb 39                	jmp    8004b8 <vprintfmt+0x245>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80047f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800483:	74 1b                	je     8004a0 <vprintfmt+0x22d>
  800485:	0f be c0             	movsbl %al,%eax
  800488:	83 e8 20             	sub    $0x20,%eax
  80048b:	83 f8 5e             	cmp    $0x5e,%eax
  80048e:	76 10                	jbe    8004a0 <vprintfmt+0x22d>
					putch('?', putdat);
  800490:	83 ec 08             	sub    $0x8,%esp
  800493:	ff 75 0c             	pushl  0xc(%ebp)
  800496:	6a 3f                	push   $0x3f
  800498:	ff 55 08             	call   *0x8(%ebp)
  80049b:	83 c4 10             	add    $0x10,%esp
  80049e:	eb 0d                	jmp    8004ad <vprintfmt+0x23a>
				else
					putch(ch, putdat);
  8004a0:	83 ec 08             	sub    $0x8,%esp
  8004a3:	ff 75 0c             	pushl  0xc(%ebp)
  8004a6:	52                   	push   %edx
  8004a7:	ff 55 08             	call   *0x8(%ebp)
  8004aa:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ad:	83 eb 01             	sub    $0x1,%ebx
  8004b0:	eb 06                	jmp    8004b8 <vprintfmt+0x245>
  8004b2:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004b5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004b8:	83 c6 01             	add    $0x1,%esi
  8004bb:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8004bf:	0f be d0             	movsbl %al,%edx
  8004c2:	85 d2                	test   %edx,%edx
  8004c4:	74 25                	je     8004eb <vprintfmt+0x278>
  8004c6:	85 ff                	test   %edi,%edi
  8004c8:	78 b5                	js     80047f <vprintfmt+0x20c>
  8004ca:	83 ef 01             	sub    $0x1,%edi
  8004cd:	79 b0                	jns    80047f <vprintfmt+0x20c>
  8004cf:	89 d8                	mov    %ebx,%eax
  8004d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004d7:	89 c3                	mov    %eax,%ebx
  8004d9:	eb 16                	jmp    8004f1 <vprintfmt+0x27e>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004db:	83 ec 08             	sub    $0x8,%esp
  8004de:	57                   	push   %edi
  8004df:	6a 20                	push   $0x20
  8004e1:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004e3:	83 eb 01             	sub    $0x1,%ebx
  8004e6:	83 c4 10             	add    $0x10,%esp
  8004e9:	eb 06                	jmp    8004f1 <vprintfmt+0x27e>
  8004eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ee:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004f1:	85 db                	test   %ebx,%ebx
  8004f3:	7f e6                	jg     8004db <vprintfmt+0x268>
  8004f5:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f8:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8004fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8004fe:	e9 9c fd ff ff       	jmp    80029f <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800503:	83 fa 01             	cmp    $0x1,%edx
  800506:	7e 10                	jle    800518 <vprintfmt+0x2a5>
		return va_arg(*ap, long long);
  800508:	8b 45 14             	mov    0x14(%ebp),%eax
  80050b:	8d 50 08             	lea    0x8(%eax),%edx
  80050e:	89 55 14             	mov    %edx,0x14(%ebp)
  800511:	8b 30                	mov    (%eax),%esi
  800513:	8b 78 04             	mov    0x4(%eax),%edi
  800516:	eb 26                	jmp    80053e <vprintfmt+0x2cb>
	else if (lflag)
  800518:	85 d2                	test   %edx,%edx
  80051a:	74 12                	je     80052e <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80051c:	8b 45 14             	mov    0x14(%ebp),%eax
  80051f:	8d 50 04             	lea    0x4(%eax),%edx
  800522:	89 55 14             	mov    %edx,0x14(%ebp)
  800525:	8b 30                	mov    (%eax),%esi
  800527:	89 f7                	mov    %esi,%edi
  800529:	c1 ff 1f             	sar    $0x1f,%edi
  80052c:	eb 10                	jmp    80053e <vprintfmt+0x2cb>
	else
		return va_arg(*ap, int);
  80052e:	8b 45 14             	mov    0x14(%ebp),%eax
  800531:	8d 50 04             	lea    0x4(%eax),%edx
  800534:	89 55 14             	mov    %edx,0x14(%ebp)
  800537:	8b 30                	mov    (%eax),%esi
  800539:	89 f7                	mov    %esi,%edi
  80053b:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80053e:	89 f0                	mov    %esi,%eax
  800540:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800542:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800547:	85 ff                	test   %edi,%edi
  800549:	79 7b                	jns    8005c6 <vprintfmt+0x353>
				putch('-', putdat);
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	ff 75 0c             	pushl  0xc(%ebp)
  800551:	6a 2d                	push   $0x2d
  800553:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800556:	89 f0                	mov    %esi,%eax
  800558:	89 fa                	mov    %edi,%edx
  80055a:	f7 d8                	neg    %eax
  80055c:	83 d2 00             	adc    $0x0,%edx
  80055f:	f7 da                	neg    %edx
  800561:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800564:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800569:	eb 5b                	jmp    8005c6 <vprintfmt+0x353>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80056b:	8d 45 14             	lea    0x14(%ebp),%eax
  80056e:	e8 8c fc ff ff       	call   8001ff <getuint>
			base = 10;
  800573:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800578:	eb 4c                	jmp    8005c6 <vprintfmt+0x353>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80057a:	8d 45 14             	lea    0x14(%ebp),%eax
  80057d:	e8 7d fc ff ff       	call   8001ff <getuint>
			base = 8;
  800582:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  800587:	eb 3d                	jmp    8005c6 <vprintfmt+0x353>
		// pointer
		case 'p':
			putch('0', putdat);
  800589:	83 ec 08             	sub    $0x8,%esp
  80058c:	ff 75 0c             	pushl  0xc(%ebp)
  80058f:	6a 30                	push   $0x30
  800591:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800594:	83 c4 08             	add    $0x8,%esp
  800597:	ff 75 0c             	pushl  0xc(%ebp)
  80059a:	6a 78                	push   $0x78
  80059c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80059f:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a2:	8d 50 04             	lea    0x4(%eax),%edx
  8005a5:	89 55 14             	mov    %edx,0x14(%ebp)
            goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005a8:	8b 00                	mov    (%eax),%eax
  8005aa:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005af:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005b2:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005b7:	eb 0d                	jmp    8005c6 <vprintfmt+0x353>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005b9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005bc:	e8 3e fc ff ff       	call   8001ff <getuint>
			base = 16;
  8005c1:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005c6:	83 ec 0c             	sub    $0xc,%esp
  8005c9:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
  8005cd:	56                   	push   %esi
  8005ce:	ff 75 e0             	pushl  -0x20(%ebp)
  8005d1:	51                   	push   %ecx
  8005d2:	52                   	push   %edx
  8005d3:	50                   	push   %eax
  8005d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8005da:	e8 71 fb ff ff       	call   800150 <printnum>
			break;
  8005df:	83 c4 20             	add    $0x20,%esp
  8005e2:	e9 b8 fc ff ff       	jmp    80029f <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005e7:	83 ec 08             	sub    $0x8,%esp
  8005ea:	ff 75 0c             	pushl  0xc(%ebp)
  8005ed:	51                   	push   %ecx
  8005ee:	ff 55 08             	call   *0x8(%ebp)
			break;
  8005f1:	83 c4 10             	add    $0x10,%esp
  8005f4:	e9 a6 fc ff ff       	jmp    80029f <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8005f9:	83 ec 08             	sub    $0x8,%esp
  8005fc:	ff 75 0c             	pushl  0xc(%ebp)
  8005ff:	6a 25                	push   $0x25
  800601:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800604:	83 c4 10             	add    $0x10,%esp
  800607:	89 f3                	mov    %esi,%ebx
  800609:	eb 03                	jmp    80060e <vprintfmt+0x39b>
  80060b:	83 eb 01             	sub    $0x1,%ebx
  80060e:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800612:	75 f7                	jne    80060b <vprintfmt+0x398>
  800614:	e9 86 fc ff ff       	jmp    80029f <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
  800619:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80061c:	5b                   	pop    %ebx
  80061d:	5e                   	pop    %esi
  80061e:	5f                   	pop    %edi
  80061f:	5d                   	pop    %ebp
  800620:	c3                   	ret    

00800621 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800621:	55                   	push   %ebp
  800622:	89 e5                	mov    %esp,%ebp
  800624:	83 ec 18             	sub    $0x18,%esp
  800627:	8b 45 08             	mov    0x8(%ebp),%eax
  80062a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80062d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800630:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800634:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800637:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80063e:	85 c0                	test   %eax,%eax
  800640:	74 26                	je     800668 <vsnprintf+0x47>
  800642:	85 d2                	test   %edx,%edx
  800644:	7e 22                	jle    800668 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800646:	ff 75 14             	pushl  0x14(%ebp)
  800649:	ff 75 10             	pushl  0x10(%ebp)
  80064c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80064f:	50                   	push   %eax
  800650:	68 39 02 80 00       	push   $0x800239
  800655:	e8 19 fc ff ff       	call   800273 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80065a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80065d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800660:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800663:	83 c4 10             	add    $0x10,%esp
  800666:	eb 05                	jmp    80066d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800668:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80066d:	c9                   	leave  
  80066e:	c3                   	ret    

0080066f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80066f:	55                   	push   %ebp
  800670:	89 e5                	mov    %esp,%ebp
  800672:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800675:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800678:	50                   	push   %eax
  800679:	ff 75 10             	pushl  0x10(%ebp)
  80067c:	ff 75 0c             	pushl  0xc(%ebp)
  80067f:	ff 75 08             	pushl  0x8(%ebp)
  800682:	e8 9a ff ff ff       	call   800621 <vsnprintf>
	va_end(ap);

	return rc;
}
  800687:	c9                   	leave  
  800688:	c3                   	ret    

00800689 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800689:	55                   	push   %ebp
  80068a:	89 e5                	mov    %esp,%ebp
  80068c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80068f:	b8 00 00 00 00       	mov    $0x0,%eax
  800694:	eb 03                	jmp    800699 <strlen+0x10>
		n++;
  800696:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800699:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80069d:	75 f7                	jne    800696 <strlen+0xd>
		n++;
	return n;
}
  80069f:	5d                   	pop    %ebp
  8006a0:	c3                   	ret    

008006a1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006a1:	55                   	push   %ebp
  8006a2:	89 e5                	mov    %esp,%ebp
  8006a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006a7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8006af:	eb 03                	jmp    8006b4 <strnlen+0x13>
		n++;
  8006b1:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006b4:	39 c2                	cmp    %eax,%edx
  8006b6:	74 08                	je     8006c0 <strnlen+0x1f>
  8006b8:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006bc:	75 f3                	jne    8006b1 <strnlen+0x10>
  8006be:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006c0:	5d                   	pop    %ebp
  8006c1:	c3                   	ret    

008006c2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006c2:	55                   	push   %ebp
  8006c3:	89 e5                	mov    %esp,%ebp
  8006c5:	53                   	push   %ebx
  8006c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006cc:	89 c2                	mov    %eax,%edx
  8006ce:	83 c2 01             	add    $0x1,%edx
  8006d1:	83 c1 01             	add    $0x1,%ecx
  8006d4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8006d8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8006db:	84 db                	test   %bl,%bl
  8006dd:	75 ef                	jne    8006ce <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006df:	5b                   	pop    %ebx
  8006e0:	5d                   	pop    %ebp
  8006e1:	c3                   	ret    

008006e2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006e2:	55                   	push   %ebp
  8006e3:	89 e5                	mov    %esp,%ebp
  8006e5:	53                   	push   %ebx
  8006e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006e9:	53                   	push   %ebx
  8006ea:	e8 9a ff ff ff       	call   800689 <strlen>
  8006ef:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8006f2:	ff 75 0c             	pushl  0xc(%ebp)
  8006f5:	01 d8                	add    %ebx,%eax
  8006f7:	50                   	push   %eax
  8006f8:	e8 c5 ff ff ff       	call   8006c2 <strcpy>
	return dst;
}
  8006fd:	89 d8                	mov    %ebx,%eax
  8006ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800702:	c9                   	leave  
  800703:	c3                   	ret    

00800704 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
  800707:	56                   	push   %esi
  800708:	53                   	push   %ebx
  800709:	8b 75 08             	mov    0x8(%ebp),%esi
  80070c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80070f:	89 f3                	mov    %esi,%ebx
  800711:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800714:	89 f2                	mov    %esi,%edx
  800716:	eb 0f                	jmp    800727 <strncpy+0x23>
		*dst++ = *src;
  800718:	83 c2 01             	add    $0x1,%edx
  80071b:	0f b6 01             	movzbl (%ecx),%eax
  80071e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800721:	80 39 01             	cmpb   $0x1,(%ecx)
  800724:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800727:	39 da                	cmp    %ebx,%edx
  800729:	75 ed                	jne    800718 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80072b:	89 f0                	mov    %esi,%eax
  80072d:	5b                   	pop    %ebx
  80072e:	5e                   	pop    %esi
  80072f:	5d                   	pop    %ebp
  800730:	c3                   	ret    

00800731 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800731:	55                   	push   %ebp
  800732:	89 e5                	mov    %esp,%ebp
  800734:	56                   	push   %esi
  800735:	53                   	push   %ebx
  800736:	8b 75 08             	mov    0x8(%ebp),%esi
  800739:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80073c:	8b 55 10             	mov    0x10(%ebp),%edx
  80073f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800741:	85 d2                	test   %edx,%edx
  800743:	74 21                	je     800766 <strlcpy+0x35>
  800745:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800749:	89 f2                	mov    %esi,%edx
  80074b:	eb 09                	jmp    800756 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80074d:	83 c2 01             	add    $0x1,%edx
  800750:	83 c1 01             	add    $0x1,%ecx
  800753:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800756:	39 c2                	cmp    %eax,%edx
  800758:	74 09                	je     800763 <strlcpy+0x32>
  80075a:	0f b6 19             	movzbl (%ecx),%ebx
  80075d:	84 db                	test   %bl,%bl
  80075f:	75 ec                	jne    80074d <strlcpy+0x1c>
  800761:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800763:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800766:	29 f0                	sub    %esi,%eax
}
  800768:	5b                   	pop    %ebx
  800769:	5e                   	pop    %esi
  80076a:	5d                   	pop    %ebp
  80076b:	c3                   	ret    

0080076c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800772:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800775:	eb 06                	jmp    80077d <strcmp+0x11>
		p++, q++;
  800777:	83 c1 01             	add    $0x1,%ecx
  80077a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80077d:	0f b6 01             	movzbl (%ecx),%eax
  800780:	84 c0                	test   %al,%al
  800782:	74 04                	je     800788 <strcmp+0x1c>
  800784:	3a 02                	cmp    (%edx),%al
  800786:	74 ef                	je     800777 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800788:	0f b6 c0             	movzbl %al,%eax
  80078b:	0f b6 12             	movzbl (%edx),%edx
  80078e:	29 d0                	sub    %edx,%eax
}
  800790:	5d                   	pop    %ebp
  800791:	c3                   	ret    

00800792 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	53                   	push   %ebx
  800796:	8b 45 08             	mov    0x8(%ebp),%eax
  800799:	8b 55 0c             	mov    0xc(%ebp),%edx
  80079c:	89 c3                	mov    %eax,%ebx
  80079e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007a1:	eb 06                	jmp    8007a9 <strncmp+0x17>
		n--, p++, q++;
  8007a3:	83 c0 01             	add    $0x1,%eax
  8007a6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007a9:	39 d8                	cmp    %ebx,%eax
  8007ab:	74 15                	je     8007c2 <strncmp+0x30>
  8007ad:	0f b6 08             	movzbl (%eax),%ecx
  8007b0:	84 c9                	test   %cl,%cl
  8007b2:	74 04                	je     8007b8 <strncmp+0x26>
  8007b4:	3a 0a                	cmp    (%edx),%cl
  8007b6:	74 eb                	je     8007a3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007b8:	0f b6 00             	movzbl (%eax),%eax
  8007bb:	0f b6 12             	movzbl (%edx),%edx
  8007be:	29 d0                	sub    %edx,%eax
  8007c0:	eb 05                	jmp    8007c7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007c2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007c7:	5b                   	pop    %ebx
  8007c8:	5d                   	pop    %ebp
  8007c9:	c3                   	ret    

008007ca <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007ca:	55                   	push   %ebp
  8007cb:	89 e5                	mov    %esp,%ebp
  8007cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007d4:	eb 07                	jmp    8007dd <strchr+0x13>
		if (*s == c)
  8007d6:	38 ca                	cmp    %cl,%dl
  8007d8:	74 0f                	je     8007e9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007da:	83 c0 01             	add    $0x1,%eax
  8007dd:	0f b6 10             	movzbl (%eax),%edx
  8007e0:	84 d2                	test   %dl,%dl
  8007e2:	75 f2                	jne    8007d6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8007e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007e9:	5d                   	pop    %ebp
  8007ea:	c3                   	ret    

008007eb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007eb:	55                   	push   %ebp
  8007ec:	89 e5                	mov    %esp,%ebp
  8007ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007f5:	eb 03                	jmp    8007fa <strfind+0xf>
  8007f7:	83 c0 01             	add    $0x1,%eax
  8007fa:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8007fd:	38 ca                	cmp    %cl,%dl
  8007ff:	74 04                	je     800805 <strfind+0x1a>
  800801:	84 d2                	test   %dl,%dl
  800803:	75 f2                	jne    8007f7 <strfind+0xc>
			break;
	return (char *) s;
}
  800805:	5d                   	pop    %ebp
  800806:	c3                   	ret    

00800807 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	57                   	push   %edi
  80080b:	56                   	push   %esi
  80080c:	53                   	push   %ebx
  80080d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800810:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800813:	85 c9                	test   %ecx,%ecx
  800815:	74 36                	je     80084d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800817:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80081d:	75 28                	jne    800847 <memset+0x40>
  80081f:	f6 c1 03             	test   $0x3,%cl
  800822:	75 23                	jne    800847 <memset+0x40>
		c &= 0xFF;
  800824:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800828:	89 d3                	mov    %edx,%ebx
  80082a:	c1 e3 08             	shl    $0x8,%ebx
  80082d:	89 d6                	mov    %edx,%esi
  80082f:	c1 e6 18             	shl    $0x18,%esi
  800832:	89 d0                	mov    %edx,%eax
  800834:	c1 e0 10             	shl    $0x10,%eax
  800837:	09 f0                	or     %esi,%eax
  800839:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80083b:	89 d8                	mov    %ebx,%eax
  80083d:	09 d0                	or     %edx,%eax
  80083f:	c1 e9 02             	shr    $0x2,%ecx
  800842:	fc                   	cld    
  800843:	f3 ab                	rep stos %eax,%es:(%edi)
  800845:	eb 06                	jmp    80084d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800847:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084a:	fc                   	cld    
  80084b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80084d:	89 f8                	mov    %edi,%eax
  80084f:	5b                   	pop    %ebx
  800850:	5e                   	pop    %esi
  800851:	5f                   	pop    %edi
  800852:	5d                   	pop    %ebp
  800853:	c3                   	ret    

00800854 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800854:	55                   	push   %ebp
  800855:	89 e5                	mov    %esp,%ebp
  800857:	57                   	push   %edi
  800858:	56                   	push   %esi
  800859:	8b 45 08             	mov    0x8(%ebp),%eax
  80085c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80085f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800862:	39 c6                	cmp    %eax,%esi
  800864:	73 35                	jae    80089b <memmove+0x47>
  800866:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800869:	39 d0                	cmp    %edx,%eax
  80086b:	73 2e                	jae    80089b <memmove+0x47>
		s += n;
		d += n;
  80086d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800870:	89 d6                	mov    %edx,%esi
  800872:	09 fe                	or     %edi,%esi
  800874:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80087a:	75 13                	jne    80088f <memmove+0x3b>
  80087c:	f6 c1 03             	test   $0x3,%cl
  80087f:	75 0e                	jne    80088f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800881:	83 ef 04             	sub    $0x4,%edi
  800884:	8d 72 fc             	lea    -0x4(%edx),%esi
  800887:	c1 e9 02             	shr    $0x2,%ecx
  80088a:	fd                   	std    
  80088b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80088d:	eb 09                	jmp    800898 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80088f:	83 ef 01             	sub    $0x1,%edi
  800892:	8d 72 ff             	lea    -0x1(%edx),%esi
  800895:	fd                   	std    
  800896:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800898:	fc                   	cld    
  800899:	eb 1d                	jmp    8008b8 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80089b:	89 f2                	mov    %esi,%edx
  80089d:	09 c2                	or     %eax,%edx
  80089f:	f6 c2 03             	test   $0x3,%dl
  8008a2:	75 0f                	jne    8008b3 <memmove+0x5f>
  8008a4:	f6 c1 03             	test   $0x3,%cl
  8008a7:	75 0a                	jne    8008b3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008a9:	c1 e9 02             	shr    $0x2,%ecx
  8008ac:	89 c7                	mov    %eax,%edi
  8008ae:	fc                   	cld    
  8008af:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008b1:	eb 05                	jmp    8008b8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008b3:	89 c7                	mov    %eax,%edi
  8008b5:	fc                   	cld    
  8008b6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008b8:	5e                   	pop    %esi
  8008b9:	5f                   	pop    %edi
  8008ba:	5d                   	pop    %ebp
  8008bb:	c3                   	ret    

008008bc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008bf:	ff 75 10             	pushl  0x10(%ebp)
  8008c2:	ff 75 0c             	pushl  0xc(%ebp)
  8008c5:	ff 75 08             	pushl  0x8(%ebp)
  8008c8:	e8 87 ff ff ff       	call   800854 <memmove>
}
  8008cd:	c9                   	leave  
  8008ce:	c3                   	ret    

008008cf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	56                   	push   %esi
  8008d3:	53                   	push   %ebx
  8008d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008da:	89 c6                	mov    %eax,%esi
  8008dc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008df:	eb 1a                	jmp    8008fb <memcmp+0x2c>
		if (*s1 != *s2)
  8008e1:	0f b6 08             	movzbl (%eax),%ecx
  8008e4:	0f b6 1a             	movzbl (%edx),%ebx
  8008e7:	38 d9                	cmp    %bl,%cl
  8008e9:	74 0a                	je     8008f5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8008eb:	0f b6 c1             	movzbl %cl,%eax
  8008ee:	0f b6 db             	movzbl %bl,%ebx
  8008f1:	29 d8                	sub    %ebx,%eax
  8008f3:	eb 0f                	jmp    800904 <memcmp+0x35>
		s1++, s2++;
  8008f5:	83 c0 01             	add    $0x1,%eax
  8008f8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008fb:	39 f0                	cmp    %esi,%eax
  8008fd:	75 e2                	jne    8008e1 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8008ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800904:	5b                   	pop    %ebx
  800905:	5e                   	pop    %esi
  800906:	5d                   	pop    %ebp
  800907:	c3                   	ret    

00800908 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	53                   	push   %ebx
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80090f:	89 c1                	mov    %eax,%ecx
  800911:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800914:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800918:	eb 0a                	jmp    800924 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80091a:	0f b6 10             	movzbl (%eax),%edx
  80091d:	39 da                	cmp    %ebx,%edx
  80091f:	74 07                	je     800928 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800921:	83 c0 01             	add    $0x1,%eax
  800924:	39 c8                	cmp    %ecx,%eax
  800926:	72 f2                	jb     80091a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800928:	5b                   	pop    %ebx
  800929:	5d                   	pop    %ebp
  80092a:	c3                   	ret    

0080092b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	57                   	push   %edi
  80092f:	56                   	push   %esi
  800930:	53                   	push   %ebx
  800931:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800934:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800937:	eb 03                	jmp    80093c <strtol+0x11>
		s++;
  800939:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80093c:	0f b6 01             	movzbl (%ecx),%eax
  80093f:	3c 20                	cmp    $0x20,%al
  800941:	74 f6                	je     800939 <strtol+0xe>
  800943:	3c 09                	cmp    $0x9,%al
  800945:	74 f2                	je     800939 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800947:	3c 2b                	cmp    $0x2b,%al
  800949:	75 0a                	jne    800955 <strtol+0x2a>
		s++;
  80094b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80094e:	bf 00 00 00 00       	mov    $0x0,%edi
  800953:	eb 11                	jmp    800966 <strtol+0x3b>
  800955:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80095a:	3c 2d                	cmp    $0x2d,%al
  80095c:	75 08                	jne    800966 <strtol+0x3b>
		s++, neg = 1;
  80095e:	83 c1 01             	add    $0x1,%ecx
  800961:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800966:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80096c:	75 15                	jne    800983 <strtol+0x58>
  80096e:	80 39 30             	cmpb   $0x30,(%ecx)
  800971:	75 10                	jne    800983 <strtol+0x58>
  800973:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800977:	75 7c                	jne    8009f5 <strtol+0xca>
		s += 2, base = 16;
  800979:	83 c1 02             	add    $0x2,%ecx
  80097c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800981:	eb 16                	jmp    800999 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800983:	85 db                	test   %ebx,%ebx
  800985:	75 12                	jne    800999 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800987:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80098c:	80 39 30             	cmpb   $0x30,(%ecx)
  80098f:	75 08                	jne    800999 <strtol+0x6e>
		s++, base = 8;
  800991:	83 c1 01             	add    $0x1,%ecx
  800994:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800999:	b8 00 00 00 00       	mov    $0x0,%eax
  80099e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009a1:	0f b6 11             	movzbl (%ecx),%edx
  8009a4:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009a7:	89 f3                	mov    %esi,%ebx
  8009a9:	80 fb 09             	cmp    $0x9,%bl
  8009ac:	77 08                	ja     8009b6 <strtol+0x8b>
			dig = *s - '0';
  8009ae:	0f be d2             	movsbl %dl,%edx
  8009b1:	83 ea 30             	sub    $0x30,%edx
  8009b4:	eb 22                	jmp    8009d8 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009b6:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009b9:	89 f3                	mov    %esi,%ebx
  8009bb:	80 fb 19             	cmp    $0x19,%bl
  8009be:	77 08                	ja     8009c8 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009c0:	0f be d2             	movsbl %dl,%edx
  8009c3:	83 ea 57             	sub    $0x57,%edx
  8009c6:	eb 10                	jmp    8009d8 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009c8:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009cb:	89 f3                	mov    %esi,%ebx
  8009cd:	80 fb 19             	cmp    $0x19,%bl
  8009d0:	77 16                	ja     8009e8 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8009d2:	0f be d2             	movsbl %dl,%edx
  8009d5:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8009d8:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009db:	7d 0b                	jge    8009e8 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8009dd:	83 c1 01             	add    $0x1,%ecx
  8009e0:	0f af 45 10          	imul   0x10(%ebp),%eax
  8009e4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8009e6:	eb b9                	jmp    8009a1 <strtol+0x76>

	if (endptr)
  8009e8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009ec:	74 0d                	je     8009fb <strtol+0xd0>
		*endptr = (char *) s;
  8009ee:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f1:	89 0e                	mov    %ecx,(%esi)
  8009f3:	eb 06                	jmp    8009fb <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009f5:	85 db                	test   %ebx,%ebx
  8009f7:	74 98                	je     800991 <strtol+0x66>
  8009f9:	eb 9e                	jmp    800999 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8009fb:	89 c2                	mov    %eax,%edx
  8009fd:	f7 da                	neg    %edx
  8009ff:	85 ff                	test   %edi,%edi
  800a01:	0f 45 c2             	cmovne %edx,%eax
}
  800a04:	5b                   	pop    %ebx
  800a05:	5e                   	pop    %esi
  800a06:	5f                   	pop    %edi
  800a07:	5d                   	pop    %ebp
  800a08:	c3                   	ret    

00800a09 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a09:	55                   	push   %ebp
  800a0a:	89 e5                	mov    %esp,%ebp
  800a0c:	57                   	push   %edi
  800a0d:	56                   	push   %esi
  800a0e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a17:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1a:	89 c3                	mov    %eax,%ebx
  800a1c:	89 c7                	mov    %eax,%edi
  800a1e:	89 c6                	mov    %eax,%esi
  800a20:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a22:	5b                   	pop    %ebx
  800a23:	5e                   	pop    %esi
  800a24:	5f                   	pop    %edi
  800a25:	5d                   	pop    %ebp
  800a26:	c3                   	ret    

00800a27 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	57                   	push   %edi
  800a2b:	56                   	push   %esi
  800a2c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a32:	b8 01 00 00 00       	mov    $0x1,%eax
  800a37:	89 d1                	mov    %edx,%ecx
  800a39:	89 d3                	mov    %edx,%ebx
  800a3b:	89 d7                	mov    %edx,%edi
  800a3d:	89 d6                	mov    %edx,%esi
  800a3f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a41:	5b                   	pop    %ebx
  800a42:	5e                   	pop    %esi
  800a43:	5f                   	pop    %edi
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	57                   	push   %edi
  800a4a:	56                   	push   %esi
  800a4b:	53                   	push   %ebx
  800a4c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a4f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a54:	b8 03 00 00 00       	mov    $0x3,%eax
  800a59:	8b 55 08             	mov    0x8(%ebp),%edx
  800a5c:	89 cb                	mov    %ecx,%ebx
  800a5e:	89 cf                	mov    %ecx,%edi
  800a60:	89 ce                	mov    %ecx,%esi
  800a62:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a64:	85 c0                	test   %eax,%eax
  800a66:	7e 17                	jle    800a7f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a68:	83 ec 0c             	sub    $0xc,%esp
  800a6b:	50                   	push   %eax
  800a6c:	6a 03                	push   $0x3
  800a6e:	68 a0 0f 80 00       	push   $0x800fa0
  800a73:	6a 23                	push   $0x23
  800a75:	68 bd 0f 80 00       	push   $0x800fbd
  800a7a:	e8 27 00 00 00       	call   800aa6 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a82:	5b                   	pop    %ebx
  800a83:	5e                   	pop    %esi
  800a84:	5f                   	pop    %edi
  800a85:	5d                   	pop    %ebp
  800a86:	c3                   	ret    

00800a87 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	57                   	push   %edi
  800a8b:	56                   	push   %esi
  800a8c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a92:	b8 02 00 00 00       	mov    $0x2,%eax
  800a97:	89 d1                	mov    %edx,%ecx
  800a99:	89 d3                	mov    %edx,%ebx
  800a9b:	89 d7                	mov    %edx,%edi
  800a9d:	89 d6                	mov    %edx,%esi
  800a9f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800aa1:	5b                   	pop    %ebx
  800aa2:	5e                   	pop    %esi
  800aa3:	5f                   	pop    %edi
  800aa4:	5d                   	pop    %ebp
  800aa5:	c3                   	ret    

00800aa6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	56                   	push   %esi
  800aaa:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800aab:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800aae:	8b 35 00 10 80 00    	mov    0x801000,%esi
  800ab4:	e8 ce ff ff ff       	call   800a87 <sys_getenvid>
  800ab9:	83 ec 0c             	sub    $0xc,%esp
  800abc:	ff 75 0c             	pushl  0xc(%ebp)
  800abf:	ff 75 08             	pushl  0x8(%ebp)
  800ac2:	56                   	push   %esi
  800ac3:	50                   	push   %eax
  800ac4:	68 cc 0f 80 00       	push   $0x800fcc
  800ac9:	e8 6e f6 ff ff       	call   80013c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ace:	83 c4 18             	add    $0x18,%esp
  800ad1:	53                   	push   %ebx
  800ad2:	ff 75 10             	pushl  0x10(%ebp)
  800ad5:	e8 11 f6 ff ff       	call   8000eb <vcprintf>
	cprintf("\n");
  800ada:	c7 04 24 90 0d 80 00 	movl   $0x800d90,(%esp)
  800ae1:	e8 56 f6 ff ff       	call   80013c <cprintf>
  800ae6:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800ae9:	cc                   	int3   
  800aea:	eb fd                	jmp    800ae9 <_panic+0x43>
  800aec:	66 90                	xchg   %ax,%ax
  800aee:	66 90                	xchg   %ax,%ax

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
