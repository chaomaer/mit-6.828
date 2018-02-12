
obj/user/divzero:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  800039:	c7 05 04 10 80 00 00 	movl   $0x0,0x801004
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 84 0d 80 00       	push   $0x800d84
  800056:	e8 f3 00 00 00       	call   80014e <cprintf>
}
  80005b:	83 c4 10             	add    $0x10,%esp
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800068:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    thisenv = envs + ENVX(sys_getenvid());
  80006b:	e8 29 0a 00 00       	call   800a99 <sys_getenvid>
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800078:	c1 e0 05             	shl    $0x5,%eax
  80007b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800080:	a3 08 10 80 00       	mov    %eax,0x801008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800085:	85 db                	test   %ebx,%ebx
  800087:	7e 07                	jle    800090 <libmain+0x30>
		binaryname = argv[0];
  800089:	8b 06                	mov    (%esi),%eax
  80008b:	a3 00 10 80 00       	mov    %eax,0x801000

	// call user main routine
	umain(argc, argv);
  800090:	83 ec 08             	sub    $0x8,%esp
  800093:	56                   	push   %esi
  800094:	53                   	push   %ebx
  800095:	e8 99 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009a:	e8 0a 00 00 00       	call   8000a9 <exit>
}
  80009f:	83 c4 10             	add    $0x10,%esp
  8000a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a5:	5b                   	pop    %ebx
  8000a6:	5e                   	pop    %esi
  8000a7:	5d                   	pop    %ebp
  8000a8:	c3                   	ret    

008000a9 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a9:	55                   	push   %ebp
  8000aa:	89 e5                	mov    %esp,%ebp
  8000ac:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000af:	6a 00                	push   $0x0
  8000b1:	e8 a2 09 00 00       	call   800a58 <sys_env_destroy>
}
  8000b6:	83 c4 10             	add    $0x10,%esp
  8000b9:	c9                   	leave  
  8000ba:	c3                   	ret    

008000bb <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000bb:	55                   	push   %ebp
  8000bc:	89 e5                	mov    %esp,%ebp
  8000be:	53                   	push   %ebx
  8000bf:	83 ec 04             	sub    $0x4,%esp
  8000c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c5:	8b 13                	mov    (%ebx),%edx
  8000c7:	8d 42 01             	lea    0x1(%edx),%eax
  8000ca:	89 03                	mov    %eax,(%ebx)
  8000cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000cf:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d8:	75 1a                	jne    8000f4 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000da:	83 ec 08             	sub    $0x8,%esp
  8000dd:	68 ff 00 00 00       	push   $0xff
  8000e2:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e5:	50                   	push   %eax
  8000e6:	e8 30 09 00 00       	call   800a1b <sys_cputs>
		b->idx = 0;
  8000eb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f1:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000fb:	c9                   	leave  
  8000fc:	c3                   	ret    

008000fd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000fd:	55                   	push   %ebp
  8000fe:	89 e5                	mov    %esp,%ebp
  800100:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800106:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010d:	00 00 00 
	b.cnt = 0;
  800110:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800117:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011a:	ff 75 0c             	pushl  0xc(%ebp)
  80011d:	ff 75 08             	pushl  0x8(%ebp)
  800120:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800126:	50                   	push   %eax
  800127:	68 bb 00 80 00       	push   $0x8000bb
  80012c:	e8 54 01 00 00       	call   800285 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800131:	83 c4 08             	add    $0x8,%esp
  800134:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80013a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800140:	50                   	push   %eax
  800141:	e8 d5 08 00 00       	call   800a1b <sys_cputs>

	return b.cnt;
}
  800146:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014c:	c9                   	leave  
  80014d:	c3                   	ret    

0080014e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80014e:	55                   	push   %ebp
  80014f:	89 e5                	mov    %esp,%ebp
  800151:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800154:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800157:	50                   	push   %eax
  800158:	ff 75 08             	pushl  0x8(%ebp)
  80015b:	e8 9d ff ff ff       	call   8000fd <vcprintf>
	va_end(ap);

	return cnt;
}
  800160:	c9                   	leave  
  800161:	c3                   	ret    

00800162 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
  800168:	83 ec 1c             	sub    $0x1c,%esp
  80016b:	89 c7                	mov    %eax,%edi
  80016d:	89 d6                	mov    %edx,%esi
  80016f:	8b 45 08             	mov    0x8(%ebp),%eax
  800172:	8b 55 0c             	mov    0xc(%ebp),%edx
  800175:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800178:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80017b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80017e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800183:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800186:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800189:	39 d3                	cmp    %edx,%ebx
  80018b:	72 05                	jb     800192 <printnum+0x30>
  80018d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800190:	77 45                	ja     8001d7 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800192:	83 ec 0c             	sub    $0xc,%esp
  800195:	ff 75 18             	pushl  0x18(%ebp)
  800198:	8b 45 14             	mov    0x14(%ebp),%eax
  80019b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80019e:	53                   	push   %ebx
  80019f:	ff 75 10             	pushl  0x10(%ebp)
  8001a2:	83 ec 08             	sub    $0x8,%esp
  8001a5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001a8:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ab:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ae:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b1:	e8 4a 09 00 00       	call   800b00 <__udivdi3>
  8001b6:	83 c4 18             	add    $0x18,%esp
  8001b9:	52                   	push   %edx
  8001ba:	50                   	push   %eax
  8001bb:	89 f2                	mov    %esi,%edx
  8001bd:	89 f8                	mov    %edi,%eax
  8001bf:	e8 9e ff ff ff       	call   800162 <printnum>
  8001c4:	83 c4 20             	add    $0x20,%esp
  8001c7:	eb 18                	jmp    8001e1 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001c9:	83 ec 08             	sub    $0x8,%esp
  8001cc:	56                   	push   %esi
  8001cd:	ff 75 18             	pushl  0x18(%ebp)
  8001d0:	ff d7                	call   *%edi
  8001d2:	83 c4 10             	add    $0x10,%esp
  8001d5:	eb 03                	jmp    8001da <printnum+0x78>
  8001d7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001da:	83 eb 01             	sub    $0x1,%ebx
  8001dd:	85 db                	test   %ebx,%ebx
  8001df:	7f e8                	jg     8001c9 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e1:	83 ec 08             	sub    $0x8,%esp
  8001e4:	56                   	push   %esi
  8001e5:	83 ec 04             	sub    $0x4,%esp
  8001e8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ee:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f4:	e8 37 0a 00 00       	call   800c30 <__umoddi3>
  8001f9:	83 c4 14             	add    $0x14,%esp
  8001fc:	0f be 80 9c 0d 80 00 	movsbl 0x800d9c(%eax),%eax
  800203:	50                   	push   %eax
  800204:	ff d7                	call   *%edi
}
  800206:	83 c4 10             	add    $0x10,%esp
  800209:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020c:	5b                   	pop    %ebx
  80020d:	5e                   	pop    %esi
  80020e:	5f                   	pop    %edi
  80020f:	5d                   	pop    %ebp
  800210:	c3                   	ret    

00800211 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800211:	55                   	push   %ebp
  800212:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800214:	83 fa 01             	cmp    $0x1,%edx
  800217:	7e 0e                	jle    800227 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800219:	8b 10                	mov    (%eax),%edx
  80021b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80021e:	89 08                	mov    %ecx,(%eax)
  800220:	8b 02                	mov    (%edx),%eax
  800222:	8b 52 04             	mov    0x4(%edx),%edx
  800225:	eb 22                	jmp    800249 <getuint+0x38>
	else if (lflag)
  800227:	85 d2                	test   %edx,%edx
  800229:	74 10                	je     80023b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80022b:	8b 10                	mov    (%eax),%edx
  80022d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800230:	89 08                	mov    %ecx,(%eax)
  800232:	8b 02                	mov    (%edx),%eax
  800234:	ba 00 00 00 00       	mov    $0x0,%edx
  800239:	eb 0e                	jmp    800249 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80023b:	8b 10                	mov    (%eax),%edx
  80023d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800240:	89 08                	mov    %ecx,(%eax)
  800242:	8b 02                	mov    (%edx),%eax
  800244:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800249:	5d                   	pop    %ebp
  80024a:	c3                   	ret    

0080024b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80024b:	55                   	push   %ebp
  80024c:	89 e5                	mov    %esp,%ebp
  80024e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800251:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800255:	8b 10                	mov    (%eax),%edx
  800257:	3b 50 04             	cmp    0x4(%eax),%edx
  80025a:	73 0a                	jae    800266 <sprintputch+0x1b>
		*b->buf++ = ch;
  80025c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80025f:	89 08                	mov    %ecx,(%eax)
  800261:	8b 45 08             	mov    0x8(%ebp),%eax
  800264:	88 02                	mov    %al,(%edx)
}
  800266:	5d                   	pop    %ebp
  800267:	c3                   	ret    

00800268 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80026e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800271:	50                   	push   %eax
  800272:	ff 75 10             	pushl  0x10(%ebp)
  800275:	ff 75 0c             	pushl  0xc(%ebp)
  800278:	ff 75 08             	pushl  0x8(%ebp)
  80027b:	e8 05 00 00 00       	call   800285 <vprintfmt>
	va_end(ap);
}
  800280:	83 c4 10             	add    $0x10,%esp
  800283:	c9                   	leave  
  800284:	c3                   	ret    

00800285 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800285:	55                   	push   %ebp
  800286:	89 e5                	mov    %esp,%ebp
  800288:	57                   	push   %edi
  800289:	56                   	push   %esi
  80028a:	53                   	push   %ebx
  80028b:	83 ec 2c             	sub    $0x2c,%esp
  80028e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
    int color = 0;
  800291:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800298:	eb 17                	jmp    8002b1 <vprintfmt+0x2c>
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80029a:	85 c0                	test   %eax,%eax
  80029c:	0f 84 89 03 00 00    	je     80062b <vprintfmt+0x3a6>
				return;
			putch(ch, putdat);
  8002a2:	83 ec 08             	sub    $0x8,%esp
  8002a5:	ff 75 0c             	pushl  0xc(%ebp)
  8002a8:	50                   	push   %eax
  8002a9:	ff 55 08             	call   *0x8(%ebp)
  8002ac:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
    int color = 0;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002af:	89 f3                	mov    %esi,%ebx
  8002b1:	8d 73 01             	lea    0x1(%ebx),%esi
  8002b4:	0f b6 03             	movzbl (%ebx),%eax
  8002b7:	83 f8 25             	cmp    $0x25,%eax
  8002ba:	75 de                	jne    80029a <vprintfmt+0x15>
  8002bc:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8002c0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002c7:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8002cc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d8:	eb 0d                	jmp    8002e7 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002da:	89 de                	mov    %ebx,%esi
  8002dc:	eb 09                	jmp    8002e7 <vprintfmt+0x62>
  8002de:	89 de                	mov    %ebx,%esi
			break;
        case 'C': 
        //自己补充的控制颜色的代码
            switch(va_arg(ap,int)){
                case 0:
                    color = 0x0c00;
  8002e0:	c7 45 d8 00 0c 00 00 	movl   $0xc00,-0x28(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e7:	8d 5e 01             	lea    0x1(%esi),%ebx
  8002ea:	0f b6 06             	movzbl (%esi),%eax
  8002ed:	0f b6 c8             	movzbl %al,%ecx
  8002f0:	83 e8 23             	sub    $0x23,%eax
  8002f3:	3c 55                	cmp    $0x55,%al
  8002f5:	0f 87 10 03 00 00    	ja     80060b <vprintfmt+0x386>
  8002fb:	0f b6 c0             	movzbl %al,%eax
  8002fe:	ff 24 85 2c 0e 80 00 	jmp    *0x800e2c(,%eax,4)
  800305:	89 de                	mov    %ebx,%esi
		case '-':
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800307:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80030b:	eb da                	jmp    8002e7 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030d:	89 de                	mov    %ebx,%esi
  80030f:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800314:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  800317:	8d 7c 41 d0          	lea    -0x30(%ecx,%eax,2),%edi
				ch = *fmt;
  80031b:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
  80031e:	8d 41 d0             	lea    -0x30(%ecx),%eax
  800321:	83 f8 09             	cmp    $0x9,%eax
  800324:	77 33                	ja     800359 <vprintfmt+0xd4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800326:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800329:	eb e9                	jmp    800314 <vprintfmt+0x8f>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80032b:	8b 45 14             	mov    0x14(%ebp),%eax
  80032e:	8d 48 04             	lea    0x4(%eax),%ecx
  800331:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800334:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800336:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800338:	eb 1f                	jmp    800359 <vprintfmt+0xd4>
  80033a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80033d:	85 c0                	test   %eax,%eax
  80033f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800344:	0f 49 c8             	cmovns %eax,%ecx
  800347:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034a:	89 de                	mov    %ebx,%esi
  80034c:	eb 99                	jmp    8002e7 <vprintfmt+0x62>
  80034e:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800350:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
  800357:	eb 8e                	jmp    8002e7 <vprintfmt+0x62>

		process_precision:
			if (width < 0)
  800359:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80035d:	79 88                	jns    8002e7 <vprintfmt+0x62>
				width = precision, precision = -1;
  80035f:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800362:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800367:	e9 7b ff ff ff       	jmp    8002e7 <vprintfmt+0x62>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80036c:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036f:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800371:	e9 71 ff ff ff       	jmp    8002e7 <vprintfmt+0x62>

		case 'c':
            ch = va_arg(ap,int)+color;
  800376:	8b 45 14             	mov    0x14(%ebp),%eax
  800379:	8d 50 04             	lea    0x4(%eax),%edx
  80037c:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
  80037f:	83 ec 08             	sub    $0x8,%esp
  800382:	ff 75 0c             	pushl  0xc(%ebp)
  800385:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800388:	03 08                	add    (%eax),%ecx
  80038a:	51                   	push   %ecx
  80038b:	ff 55 08             	call   *0x8(%ebp)
            color = 0;
			break;
  80038e:	83 c4 10             	add    $0x10,%esp
			goto reswitch;

		case 'c':
            ch = va_arg(ap,int)+color;
			putch(ch, putdat);
            color = 0;
  800391:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
			break;
  800398:	e9 14 ff ff ff       	jmp    8002b1 <vprintfmt+0x2c>
        case 'C': 
        //自己补充的控制颜色的代码
            switch(va_arg(ap,int)){
  80039d:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a0:	8d 48 04             	lea    0x4(%eax),%ecx
  8003a3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003a6:	8b 00                	mov    (%eax),%eax
  8003a8:	85 c0                	test   %eax,%eax
  8003aa:	0f 84 2e ff ff ff    	je     8002de <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b0:	89 de                	mov    %ebx,%esi
  8003b2:	83 f8 01             	cmp    $0x1,%eax
  8003b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ba:	b9 00 0a 00 00       	mov    $0xa00,%ecx
  8003bf:	0f 44 c1             	cmove  %ecx,%eax
  8003c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003c5:	e9 1d ff ff ff       	jmp    8002e7 <vprintfmt+0x62>
            }

            goto reswitch;
		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cd:	8d 50 04             	lea    0x4(%eax),%edx
  8003d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d3:	8b 00                	mov    (%eax),%eax
  8003d5:	99                   	cltd   
  8003d6:	31 d0                	xor    %edx,%eax
  8003d8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003da:	83 f8 06             	cmp    $0x6,%eax
  8003dd:	7f 0b                	jg     8003ea <vprintfmt+0x165>
  8003df:	8b 14 85 84 0f 80 00 	mov    0x800f84(,%eax,4),%edx
  8003e6:	85 d2                	test   %edx,%edx
  8003e8:	75 19                	jne    800403 <vprintfmt+0x17e>
				printfmt(putch, putdat, "error %d", err);
  8003ea:	50                   	push   %eax
  8003eb:	68 b4 0d 80 00       	push   $0x800db4
  8003f0:	ff 75 0c             	pushl  0xc(%ebp)
  8003f3:	ff 75 08             	pushl  0x8(%ebp)
  8003f6:	e8 6d fe ff ff       	call   800268 <printfmt>
  8003fb:	83 c4 10             	add    $0x10,%esp
  8003fe:	e9 ae fe ff ff       	jmp    8002b1 <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
  800403:	52                   	push   %edx
  800404:	68 bd 0d 80 00       	push   $0x800dbd
  800409:	ff 75 0c             	pushl  0xc(%ebp)
  80040c:	ff 75 08             	pushl  0x8(%ebp)
  80040f:	e8 54 fe ff ff       	call   800268 <printfmt>
  800414:	83 c4 10             	add    $0x10,%esp
  800417:	e9 95 fe ff ff       	jmp    8002b1 <vprintfmt+0x2c>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80041c:	8b 45 14             	mov    0x14(%ebp),%eax
  80041f:	8d 50 04             	lea    0x4(%eax),%edx
  800422:	89 55 14             	mov    %edx,0x14(%ebp)
  800425:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800427:	85 f6                	test   %esi,%esi
  800429:	b8 ad 0d 80 00       	mov    $0x800dad,%eax
  80042e:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800431:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800435:	0f 8e 89 00 00 00    	jle    8004c4 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  80043b:	83 ec 08             	sub    $0x8,%esp
  80043e:	57                   	push   %edi
  80043f:	56                   	push   %esi
  800440:	e8 6e 02 00 00       	call   8006b3 <strnlen>
  800445:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800448:	29 c1                	sub    %eax,%ecx
  80044a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80044d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800450:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  800454:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800457:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80045a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80045d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800460:	89 cb                	mov    %ecx,%ebx
  800462:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800464:	eb 0e                	jmp    800474 <vprintfmt+0x1ef>
					putch(padc, putdat);
  800466:	83 ec 08             	sub    $0x8,%esp
  800469:	56                   	push   %esi
  80046a:	57                   	push   %edi
  80046b:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80046e:	83 eb 01             	sub    $0x1,%ebx
  800471:	83 c4 10             	add    $0x10,%esp
  800474:	85 db                	test   %ebx,%ebx
  800476:	7f ee                	jg     800466 <vprintfmt+0x1e1>
  800478:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80047b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80047e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800481:	85 c9                	test   %ecx,%ecx
  800483:	b8 00 00 00 00       	mov    $0x0,%eax
  800488:	0f 49 c1             	cmovns %ecx,%eax
  80048b:	29 c1                	sub    %eax,%ecx
  80048d:	89 cb                	mov    %ecx,%ebx
  80048f:	eb 39                	jmp    8004ca <vprintfmt+0x245>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800491:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800495:	74 1b                	je     8004b2 <vprintfmt+0x22d>
  800497:	0f be c0             	movsbl %al,%eax
  80049a:	83 e8 20             	sub    $0x20,%eax
  80049d:	83 f8 5e             	cmp    $0x5e,%eax
  8004a0:	76 10                	jbe    8004b2 <vprintfmt+0x22d>
					putch('?', putdat);
  8004a2:	83 ec 08             	sub    $0x8,%esp
  8004a5:	ff 75 0c             	pushl  0xc(%ebp)
  8004a8:	6a 3f                	push   $0x3f
  8004aa:	ff 55 08             	call   *0x8(%ebp)
  8004ad:	83 c4 10             	add    $0x10,%esp
  8004b0:	eb 0d                	jmp    8004bf <vprintfmt+0x23a>
				else
					putch(ch, putdat);
  8004b2:	83 ec 08             	sub    $0x8,%esp
  8004b5:	ff 75 0c             	pushl  0xc(%ebp)
  8004b8:	52                   	push   %edx
  8004b9:	ff 55 08             	call   *0x8(%ebp)
  8004bc:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004bf:	83 eb 01             	sub    $0x1,%ebx
  8004c2:	eb 06                	jmp    8004ca <vprintfmt+0x245>
  8004c4:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004c7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ca:	83 c6 01             	add    $0x1,%esi
  8004cd:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8004d1:	0f be d0             	movsbl %al,%edx
  8004d4:	85 d2                	test   %edx,%edx
  8004d6:	74 25                	je     8004fd <vprintfmt+0x278>
  8004d8:	85 ff                	test   %edi,%edi
  8004da:	78 b5                	js     800491 <vprintfmt+0x20c>
  8004dc:	83 ef 01             	sub    $0x1,%edi
  8004df:	79 b0                	jns    800491 <vprintfmt+0x20c>
  8004e1:	89 d8                	mov    %ebx,%eax
  8004e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004e9:	89 c3                	mov    %eax,%ebx
  8004eb:	eb 16                	jmp    800503 <vprintfmt+0x27e>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004ed:	83 ec 08             	sub    $0x8,%esp
  8004f0:	57                   	push   %edi
  8004f1:	6a 20                	push   $0x20
  8004f3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004f5:	83 eb 01             	sub    $0x1,%ebx
  8004f8:	83 c4 10             	add    $0x10,%esp
  8004fb:	eb 06                	jmp    800503 <vprintfmt+0x27e>
  8004fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800500:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800503:	85 db                	test   %ebx,%ebx
  800505:	7f e6                	jg     8004ed <vprintfmt+0x268>
  800507:	89 75 08             	mov    %esi,0x8(%ebp)
  80050a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80050d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800510:	e9 9c fd ff ff       	jmp    8002b1 <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800515:	83 fa 01             	cmp    $0x1,%edx
  800518:	7e 10                	jle    80052a <vprintfmt+0x2a5>
		return va_arg(*ap, long long);
  80051a:	8b 45 14             	mov    0x14(%ebp),%eax
  80051d:	8d 50 08             	lea    0x8(%eax),%edx
  800520:	89 55 14             	mov    %edx,0x14(%ebp)
  800523:	8b 30                	mov    (%eax),%esi
  800525:	8b 78 04             	mov    0x4(%eax),%edi
  800528:	eb 26                	jmp    800550 <vprintfmt+0x2cb>
	else if (lflag)
  80052a:	85 d2                	test   %edx,%edx
  80052c:	74 12                	je     800540 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80052e:	8b 45 14             	mov    0x14(%ebp),%eax
  800531:	8d 50 04             	lea    0x4(%eax),%edx
  800534:	89 55 14             	mov    %edx,0x14(%ebp)
  800537:	8b 30                	mov    (%eax),%esi
  800539:	89 f7                	mov    %esi,%edi
  80053b:	c1 ff 1f             	sar    $0x1f,%edi
  80053e:	eb 10                	jmp    800550 <vprintfmt+0x2cb>
	else
		return va_arg(*ap, int);
  800540:	8b 45 14             	mov    0x14(%ebp),%eax
  800543:	8d 50 04             	lea    0x4(%eax),%edx
  800546:	89 55 14             	mov    %edx,0x14(%ebp)
  800549:	8b 30                	mov    (%eax),%esi
  80054b:	89 f7                	mov    %esi,%edi
  80054d:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800550:	89 f0                	mov    %esi,%eax
  800552:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800554:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800559:	85 ff                	test   %edi,%edi
  80055b:	79 7b                	jns    8005d8 <vprintfmt+0x353>
				putch('-', putdat);
  80055d:	83 ec 08             	sub    $0x8,%esp
  800560:	ff 75 0c             	pushl  0xc(%ebp)
  800563:	6a 2d                	push   $0x2d
  800565:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800568:	89 f0                	mov    %esi,%eax
  80056a:	89 fa                	mov    %edi,%edx
  80056c:	f7 d8                	neg    %eax
  80056e:	83 d2 00             	adc    $0x0,%edx
  800571:	f7 da                	neg    %edx
  800573:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800576:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80057b:	eb 5b                	jmp    8005d8 <vprintfmt+0x353>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80057d:	8d 45 14             	lea    0x14(%ebp),%eax
  800580:	e8 8c fc ff ff       	call   800211 <getuint>
			base = 10;
  800585:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80058a:	eb 4c                	jmp    8005d8 <vprintfmt+0x353>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80058c:	8d 45 14             	lea    0x14(%ebp),%eax
  80058f:	e8 7d fc ff ff       	call   800211 <getuint>
			base = 8;
  800594:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
  800599:	eb 3d                	jmp    8005d8 <vprintfmt+0x353>
		// pointer
		case 'p':
			putch('0', putdat);
  80059b:	83 ec 08             	sub    $0x8,%esp
  80059e:	ff 75 0c             	pushl  0xc(%ebp)
  8005a1:	6a 30                	push   $0x30
  8005a3:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005a6:	83 c4 08             	add    $0x8,%esp
  8005a9:	ff 75 0c             	pushl  0xc(%ebp)
  8005ac:	6a 78                	push   $0x78
  8005ae:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b4:	8d 50 04             	lea    0x4(%eax),%edx
  8005b7:	89 55 14             	mov    %edx,0x14(%ebp)
            goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005ba:	8b 00                	mov    (%eax),%eax
  8005bc:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005c1:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005c4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005c9:	eb 0d                	jmp    8005d8 <vprintfmt+0x353>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ce:	e8 3e fc ff ff       	call   800211 <getuint>
			base = 16;
  8005d3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005d8:	83 ec 0c             	sub    $0xc,%esp
  8005db:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
  8005df:	56                   	push   %esi
  8005e0:	ff 75 e0             	pushl  -0x20(%ebp)
  8005e3:	51                   	push   %ecx
  8005e4:	52                   	push   %edx
  8005e5:	50                   	push   %eax
  8005e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ec:	e8 71 fb ff ff       	call   800162 <printnum>
			break;
  8005f1:	83 c4 20             	add    $0x20,%esp
  8005f4:	e9 b8 fc ff ff       	jmp    8002b1 <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005f9:	83 ec 08             	sub    $0x8,%esp
  8005fc:	ff 75 0c             	pushl  0xc(%ebp)
  8005ff:	51                   	push   %ecx
  800600:	ff 55 08             	call   *0x8(%ebp)
			break;
  800603:	83 c4 10             	add    $0x10,%esp
  800606:	e9 a6 fc ff ff       	jmp    8002b1 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80060b:	83 ec 08             	sub    $0x8,%esp
  80060e:	ff 75 0c             	pushl  0xc(%ebp)
  800611:	6a 25                	push   $0x25
  800613:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800616:	83 c4 10             	add    $0x10,%esp
  800619:	89 f3                	mov    %esi,%ebx
  80061b:	eb 03                	jmp    800620 <vprintfmt+0x39b>
  80061d:	83 eb 01             	sub    $0x1,%ebx
  800620:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800624:	75 f7                	jne    80061d <vprintfmt+0x398>
  800626:	e9 86 fc ff ff       	jmp    8002b1 <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
  80062b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062e:	5b                   	pop    %ebx
  80062f:	5e                   	pop    %esi
  800630:	5f                   	pop    %edi
  800631:	5d                   	pop    %ebp
  800632:	c3                   	ret    

00800633 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800633:	55                   	push   %ebp
  800634:	89 e5                	mov    %esp,%ebp
  800636:	83 ec 18             	sub    $0x18,%esp
  800639:	8b 45 08             	mov    0x8(%ebp),%eax
  80063c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80063f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800642:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800646:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800649:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800650:	85 c0                	test   %eax,%eax
  800652:	74 26                	je     80067a <vsnprintf+0x47>
  800654:	85 d2                	test   %edx,%edx
  800656:	7e 22                	jle    80067a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800658:	ff 75 14             	pushl  0x14(%ebp)
  80065b:	ff 75 10             	pushl  0x10(%ebp)
  80065e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800661:	50                   	push   %eax
  800662:	68 4b 02 80 00       	push   $0x80024b
  800667:	e8 19 fc ff ff       	call   800285 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80066c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80066f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800672:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800675:	83 c4 10             	add    $0x10,%esp
  800678:	eb 05                	jmp    80067f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80067a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80067f:	c9                   	leave  
  800680:	c3                   	ret    

00800681 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800681:	55                   	push   %ebp
  800682:	89 e5                	mov    %esp,%ebp
  800684:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800687:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80068a:	50                   	push   %eax
  80068b:	ff 75 10             	pushl  0x10(%ebp)
  80068e:	ff 75 0c             	pushl  0xc(%ebp)
  800691:	ff 75 08             	pushl  0x8(%ebp)
  800694:	e8 9a ff ff ff       	call   800633 <vsnprintf>
	va_end(ap);

	return rc;
}
  800699:	c9                   	leave  
  80069a:	c3                   	ret    

0080069b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80069b:	55                   	push   %ebp
  80069c:	89 e5                	mov    %esp,%ebp
  80069e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8006a6:	eb 03                	jmp    8006ab <strlen+0x10>
		n++;
  8006a8:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ab:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006af:	75 f7                	jne    8006a8 <strlen+0xd>
		n++;
	return n;
}
  8006b1:	5d                   	pop    %ebp
  8006b2:	c3                   	ret    

008006b3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006b3:	55                   	push   %ebp
  8006b4:	89 e5                	mov    %esp,%ebp
  8006b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006b9:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8006c1:	eb 03                	jmp    8006c6 <strnlen+0x13>
		n++;
  8006c3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006c6:	39 c2                	cmp    %eax,%edx
  8006c8:	74 08                	je     8006d2 <strnlen+0x1f>
  8006ca:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006ce:	75 f3                	jne    8006c3 <strnlen+0x10>
  8006d0:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006d2:	5d                   	pop    %ebp
  8006d3:	c3                   	ret    

008006d4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006d4:	55                   	push   %ebp
  8006d5:	89 e5                	mov    %esp,%ebp
  8006d7:	53                   	push   %ebx
  8006d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006de:	89 c2                	mov    %eax,%edx
  8006e0:	83 c2 01             	add    $0x1,%edx
  8006e3:	83 c1 01             	add    $0x1,%ecx
  8006e6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8006ea:	88 5a ff             	mov    %bl,-0x1(%edx)
  8006ed:	84 db                	test   %bl,%bl
  8006ef:	75 ef                	jne    8006e0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006f1:	5b                   	pop    %ebx
  8006f2:	5d                   	pop    %ebp
  8006f3:	c3                   	ret    

008006f4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	53                   	push   %ebx
  8006f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006fb:	53                   	push   %ebx
  8006fc:	e8 9a ff ff ff       	call   80069b <strlen>
  800701:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800704:	ff 75 0c             	pushl  0xc(%ebp)
  800707:	01 d8                	add    %ebx,%eax
  800709:	50                   	push   %eax
  80070a:	e8 c5 ff ff ff       	call   8006d4 <strcpy>
	return dst;
}
  80070f:	89 d8                	mov    %ebx,%eax
  800711:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800714:	c9                   	leave  
  800715:	c3                   	ret    

00800716 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800716:	55                   	push   %ebp
  800717:	89 e5                	mov    %esp,%ebp
  800719:	56                   	push   %esi
  80071a:	53                   	push   %ebx
  80071b:	8b 75 08             	mov    0x8(%ebp),%esi
  80071e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800721:	89 f3                	mov    %esi,%ebx
  800723:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800726:	89 f2                	mov    %esi,%edx
  800728:	eb 0f                	jmp    800739 <strncpy+0x23>
		*dst++ = *src;
  80072a:	83 c2 01             	add    $0x1,%edx
  80072d:	0f b6 01             	movzbl (%ecx),%eax
  800730:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800733:	80 39 01             	cmpb   $0x1,(%ecx)
  800736:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800739:	39 da                	cmp    %ebx,%edx
  80073b:	75 ed                	jne    80072a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80073d:	89 f0                	mov    %esi,%eax
  80073f:	5b                   	pop    %ebx
  800740:	5e                   	pop    %esi
  800741:	5d                   	pop    %ebp
  800742:	c3                   	ret    

00800743 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800743:	55                   	push   %ebp
  800744:	89 e5                	mov    %esp,%ebp
  800746:	56                   	push   %esi
  800747:	53                   	push   %ebx
  800748:	8b 75 08             	mov    0x8(%ebp),%esi
  80074b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80074e:	8b 55 10             	mov    0x10(%ebp),%edx
  800751:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800753:	85 d2                	test   %edx,%edx
  800755:	74 21                	je     800778 <strlcpy+0x35>
  800757:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80075b:	89 f2                	mov    %esi,%edx
  80075d:	eb 09                	jmp    800768 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80075f:	83 c2 01             	add    $0x1,%edx
  800762:	83 c1 01             	add    $0x1,%ecx
  800765:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800768:	39 c2                	cmp    %eax,%edx
  80076a:	74 09                	je     800775 <strlcpy+0x32>
  80076c:	0f b6 19             	movzbl (%ecx),%ebx
  80076f:	84 db                	test   %bl,%bl
  800771:	75 ec                	jne    80075f <strlcpy+0x1c>
  800773:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800775:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800778:	29 f0                	sub    %esi,%eax
}
  80077a:	5b                   	pop    %ebx
  80077b:	5e                   	pop    %esi
  80077c:	5d                   	pop    %ebp
  80077d:	c3                   	ret    

0080077e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80077e:	55                   	push   %ebp
  80077f:	89 e5                	mov    %esp,%ebp
  800781:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800784:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800787:	eb 06                	jmp    80078f <strcmp+0x11>
		p++, q++;
  800789:	83 c1 01             	add    $0x1,%ecx
  80078c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80078f:	0f b6 01             	movzbl (%ecx),%eax
  800792:	84 c0                	test   %al,%al
  800794:	74 04                	je     80079a <strcmp+0x1c>
  800796:	3a 02                	cmp    (%edx),%al
  800798:	74 ef                	je     800789 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80079a:	0f b6 c0             	movzbl %al,%eax
  80079d:	0f b6 12             	movzbl (%edx),%edx
  8007a0:	29 d0                	sub    %edx,%eax
}
  8007a2:	5d                   	pop    %ebp
  8007a3:	c3                   	ret    

008007a4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007a4:	55                   	push   %ebp
  8007a5:	89 e5                	mov    %esp,%ebp
  8007a7:	53                   	push   %ebx
  8007a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ae:	89 c3                	mov    %eax,%ebx
  8007b0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007b3:	eb 06                	jmp    8007bb <strncmp+0x17>
		n--, p++, q++;
  8007b5:	83 c0 01             	add    $0x1,%eax
  8007b8:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007bb:	39 d8                	cmp    %ebx,%eax
  8007bd:	74 15                	je     8007d4 <strncmp+0x30>
  8007bf:	0f b6 08             	movzbl (%eax),%ecx
  8007c2:	84 c9                	test   %cl,%cl
  8007c4:	74 04                	je     8007ca <strncmp+0x26>
  8007c6:	3a 0a                	cmp    (%edx),%cl
  8007c8:	74 eb                	je     8007b5 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ca:	0f b6 00             	movzbl (%eax),%eax
  8007cd:	0f b6 12             	movzbl (%edx),%edx
  8007d0:	29 d0                	sub    %edx,%eax
  8007d2:	eb 05                	jmp    8007d9 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007d4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007d9:	5b                   	pop    %ebx
  8007da:	5d                   	pop    %ebp
  8007db:	c3                   	ret    

008007dc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007e6:	eb 07                	jmp    8007ef <strchr+0x13>
		if (*s == c)
  8007e8:	38 ca                	cmp    %cl,%dl
  8007ea:	74 0f                	je     8007fb <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007ec:	83 c0 01             	add    $0x1,%eax
  8007ef:	0f b6 10             	movzbl (%eax),%edx
  8007f2:	84 d2                	test   %dl,%dl
  8007f4:	75 f2                	jne    8007e8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8007f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007fb:	5d                   	pop    %ebp
  8007fc:	c3                   	ret    

008007fd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	8b 45 08             	mov    0x8(%ebp),%eax
  800803:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800807:	eb 03                	jmp    80080c <strfind+0xf>
  800809:	83 c0 01             	add    $0x1,%eax
  80080c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80080f:	38 ca                	cmp    %cl,%dl
  800811:	74 04                	je     800817 <strfind+0x1a>
  800813:	84 d2                	test   %dl,%dl
  800815:	75 f2                	jne    800809 <strfind+0xc>
			break;
	return (char *) s;
}
  800817:	5d                   	pop    %ebp
  800818:	c3                   	ret    

00800819 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	57                   	push   %edi
  80081d:	56                   	push   %esi
  80081e:	53                   	push   %ebx
  80081f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800822:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800825:	85 c9                	test   %ecx,%ecx
  800827:	74 36                	je     80085f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800829:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80082f:	75 28                	jne    800859 <memset+0x40>
  800831:	f6 c1 03             	test   $0x3,%cl
  800834:	75 23                	jne    800859 <memset+0x40>
		c &= 0xFF;
  800836:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80083a:	89 d3                	mov    %edx,%ebx
  80083c:	c1 e3 08             	shl    $0x8,%ebx
  80083f:	89 d6                	mov    %edx,%esi
  800841:	c1 e6 18             	shl    $0x18,%esi
  800844:	89 d0                	mov    %edx,%eax
  800846:	c1 e0 10             	shl    $0x10,%eax
  800849:	09 f0                	or     %esi,%eax
  80084b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80084d:	89 d8                	mov    %ebx,%eax
  80084f:	09 d0                	or     %edx,%eax
  800851:	c1 e9 02             	shr    $0x2,%ecx
  800854:	fc                   	cld    
  800855:	f3 ab                	rep stos %eax,%es:(%edi)
  800857:	eb 06                	jmp    80085f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800859:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085c:	fc                   	cld    
  80085d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80085f:	89 f8                	mov    %edi,%eax
  800861:	5b                   	pop    %ebx
  800862:	5e                   	pop    %esi
  800863:	5f                   	pop    %edi
  800864:	5d                   	pop    %ebp
  800865:	c3                   	ret    

00800866 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	57                   	push   %edi
  80086a:	56                   	push   %esi
  80086b:	8b 45 08             	mov    0x8(%ebp),%eax
  80086e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800871:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800874:	39 c6                	cmp    %eax,%esi
  800876:	73 35                	jae    8008ad <memmove+0x47>
  800878:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80087b:	39 d0                	cmp    %edx,%eax
  80087d:	73 2e                	jae    8008ad <memmove+0x47>
		s += n;
		d += n;
  80087f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800882:	89 d6                	mov    %edx,%esi
  800884:	09 fe                	or     %edi,%esi
  800886:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80088c:	75 13                	jne    8008a1 <memmove+0x3b>
  80088e:	f6 c1 03             	test   $0x3,%cl
  800891:	75 0e                	jne    8008a1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800893:	83 ef 04             	sub    $0x4,%edi
  800896:	8d 72 fc             	lea    -0x4(%edx),%esi
  800899:	c1 e9 02             	shr    $0x2,%ecx
  80089c:	fd                   	std    
  80089d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80089f:	eb 09                	jmp    8008aa <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008a1:	83 ef 01             	sub    $0x1,%edi
  8008a4:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008a7:	fd                   	std    
  8008a8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008aa:	fc                   	cld    
  8008ab:	eb 1d                	jmp    8008ca <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ad:	89 f2                	mov    %esi,%edx
  8008af:	09 c2                	or     %eax,%edx
  8008b1:	f6 c2 03             	test   $0x3,%dl
  8008b4:	75 0f                	jne    8008c5 <memmove+0x5f>
  8008b6:	f6 c1 03             	test   $0x3,%cl
  8008b9:	75 0a                	jne    8008c5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008bb:	c1 e9 02             	shr    $0x2,%ecx
  8008be:	89 c7                	mov    %eax,%edi
  8008c0:	fc                   	cld    
  8008c1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c3:	eb 05                	jmp    8008ca <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008c5:	89 c7                	mov    %eax,%edi
  8008c7:	fc                   	cld    
  8008c8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008ca:	5e                   	pop    %esi
  8008cb:	5f                   	pop    %edi
  8008cc:	5d                   	pop    %ebp
  8008cd:	c3                   	ret    

008008ce <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008d1:	ff 75 10             	pushl  0x10(%ebp)
  8008d4:	ff 75 0c             	pushl  0xc(%ebp)
  8008d7:	ff 75 08             	pushl  0x8(%ebp)
  8008da:	e8 87 ff ff ff       	call   800866 <memmove>
}
  8008df:	c9                   	leave  
  8008e0:	c3                   	ret    

008008e1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	56                   	push   %esi
  8008e5:	53                   	push   %ebx
  8008e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ec:	89 c6                	mov    %eax,%esi
  8008ee:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008f1:	eb 1a                	jmp    80090d <memcmp+0x2c>
		if (*s1 != *s2)
  8008f3:	0f b6 08             	movzbl (%eax),%ecx
  8008f6:	0f b6 1a             	movzbl (%edx),%ebx
  8008f9:	38 d9                	cmp    %bl,%cl
  8008fb:	74 0a                	je     800907 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8008fd:	0f b6 c1             	movzbl %cl,%eax
  800900:	0f b6 db             	movzbl %bl,%ebx
  800903:	29 d8                	sub    %ebx,%eax
  800905:	eb 0f                	jmp    800916 <memcmp+0x35>
		s1++, s2++;
  800907:	83 c0 01             	add    $0x1,%eax
  80090a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80090d:	39 f0                	cmp    %esi,%eax
  80090f:	75 e2                	jne    8008f3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800911:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800916:	5b                   	pop    %ebx
  800917:	5e                   	pop    %esi
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	53                   	push   %ebx
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800921:	89 c1                	mov    %eax,%ecx
  800923:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800926:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80092a:	eb 0a                	jmp    800936 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80092c:	0f b6 10             	movzbl (%eax),%edx
  80092f:	39 da                	cmp    %ebx,%edx
  800931:	74 07                	je     80093a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800933:	83 c0 01             	add    $0x1,%eax
  800936:	39 c8                	cmp    %ecx,%eax
  800938:	72 f2                	jb     80092c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80093a:	5b                   	pop    %ebx
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    

0080093d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	57                   	push   %edi
  800941:	56                   	push   %esi
  800942:	53                   	push   %ebx
  800943:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800946:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800949:	eb 03                	jmp    80094e <strtol+0x11>
		s++;
  80094b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80094e:	0f b6 01             	movzbl (%ecx),%eax
  800951:	3c 20                	cmp    $0x20,%al
  800953:	74 f6                	je     80094b <strtol+0xe>
  800955:	3c 09                	cmp    $0x9,%al
  800957:	74 f2                	je     80094b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800959:	3c 2b                	cmp    $0x2b,%al
  80095b:	75 0a                	jne    800967 <strtol+0x2a>
		s++;
  80095d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800960:	bf 00 00 00 00       	mov    $0x0,%edi
  800965:	eb 11                	jmp    800978 <strtol+0x3b>
  800967:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80096c:	3c 2d                	cmp    $0x2d,%al
  80096e:	75 08                	jne    800978 <strtol+0x3b>
		s++, neg = 1;
  800970:	83 c1 01             	add    $0x1,%ecx
  800973:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800978:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80097e:	75 15                	jne    800995 <strtol+0x58>
  800980:	80 39 30             	cmpb   $0x30,(%ecx)
  800983:	75 10                	jne    800995 <strtol+0x58>
  800985:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800989:	75 7c                	jne    800a07 <strtol+0xca>
		s += 2, base = 16;
  80098b:	83 c1 02             	add    $0x2,%ecx
  80098e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800993:	eb 16                	jmp    8009ab <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800995:	85 db                	test   %ebx,%ebx
  800997:	75 12                	jne    8009ab <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800999:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80099e:	80 39 30             	cmpb   $0x30,(%ecx)
  8009a1:	75 08                	jne    8009ab <strtol+0x6e>
		s++, base = 8;
  8009a3:	83 c1 01             	add    $0x1,%ecx
  8009a6:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009b3:	0f b6 11             	movzbl (%ecx),%edx
  8009b6:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009b9:	89 f3                	mov    %esi,%ebx
  8009bb:	80 fb 09             	cmp    $0x9,%bl
  8009be:	77 08                	ja     8009c8 <strtol+0x8b>
			dig = *s - '0';
  8009c0:	0f be d2             	movsbl %dl,%edx
  8009c3:	83 ea 30             	sub    $0x30,%edx
  8009c6:	eb 22                	jmp    8009ea <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009c8:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009cb:	89 f3                	mov    %esi,%ebx
  8009cd:	80 fb 19             	cmp    $0x19,%bl
  8009d0:	77 08                	ja     8009da <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009d2:	0f be d2             	movsbl %dl,%edx
  8009d5:	83 ea 57             	sub    $0x57,%edx
  8009d8:	eb 10                	jmp    8009ea <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009da:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009dd:	89 f3                	mov    %esi,%ebx
  8009df:	80 fb 19             	cmp    $0x19,%bl
  8009e2:	77 16                	ja     8009fa <strtol+0xbd>
			dig = *s - 'A' + 10;
  8009e4:	0f be d2             	movsbl %dl,%edx
  8009e7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8009ea:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009ed:	7d 0b                	jge    8009fa <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8009ef:	83 c1 01             	add    $0x1,%ecx
  8009f2:	0f af 45 10          	imul   0x10(%ebp),%eax
  8009f6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8009f8:	eb b9                	jmp    8009b3 <strtol+0x76>

	if (endptr)
  8009fa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009fe:	74 0d                	je     800a0d <strtol+0xd0>
		*endptr = (char *) s;
  800a00:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a03:	89 0e                	mov    %ecx,(%esi)
  800a05:	eb 06                	jmp    800a0d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a07:	85 db                	test   %ebx,%ebx
  800a09:	74 98                	je     8009a3 <strtol+0x66>
  800a0b:	eb 9e                	jmp    8009ab <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a0d:	89 c2                	mov    %eax,%edx
  800a0f:	f7 da                	neg    %edx
  800a11:	85 ff                	test   %edi,%edi
  800a13:	0f 45 c2             	cmovne %edx,%eax
}
  800a16:	5b                   	pop    %ebx
  800a17:	5e                   	pop    %esi
  800a18:	5f                   	pop    %edi
  800a19:	5d                   	pop    %ebp
  800a1a:	c3                   	ret    

00800a1b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	57                   	push   %edi
  800a1f:	56                   	push   %esi
  800a20:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a21:	b8 00 00 00 00       	mov    $0x0,%eax
  800a26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a29:	8b 55 08             	mov    0x8(%ebp),%edx
  800a2c:	89 c3                	mov    %eax,%ebx
  800a2e:	89 c7                	mov    %eax,%edi
  800a30:	89 c6                	mov    %eax,%esi
  800a32:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a34:	5b                   	pop    %ebx
  800a35:	5e                   	pop    %esi
  800a36:	5f                   	pop    %edi
  800a37:	5d                   	pop    %ebp
  800a38:	c3                   	ret    

00800a39 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	57                   	push   %edi
  800a3d:	56                   	push   %esi
  800a3e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a3f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a44:	b8 01 00 00 00       	mov    $0x1,%eax
  800a49:	89 d1                	mov    %edx,%ecx
  800a4b:	89 d3                	mov    %edx,%ebx
  800a4d:	89 d7                	mov    %edx,%edi
  800a4f:	89 d6                	mov    %edx,%esi
  800a51:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a53:	5b                   	pop    %ebx
  800a54:	5e                   	pop    %esi
  800a55:	5f                   	pop    %edi
  800a56:	5d                   	pop    %ebp
  800a57:	c3                   	ret    

00800a58 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a58:	55                   	push   %ebp
  800a59:	89 e5                	mov    %esp,%ebp
  800a5b:	57                   	push   %edi
  800a5c:	56                   	push   %esi
  800a5d:	53                   	push   %ebx
  800a5e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a61:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a66:	b8 03 00 00 00       	mov    $0x3,%eax
  800a6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6e:	89 cb                	mov    %ecx,%ebx
  800a70:	89 cf                	mov    %ecx,%edi
  800a72:	89 ce                	mov    %ecx,%esi
  800a74:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a76:	85 c0                	test   %eax,%eax
  800a78:	7e 17                	jle    800a91 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a7a:	83 ec 0c             	sub    $0xc,%esp
  800a7d:	50                   	push   %eax
  800a7e:	6a 03                	push   $0x3
  800a80:	68 a0 0f 80 00       	push   $0x800fa0
  800a85:	6a 23                	push   $0x23
  800a87:	68 bd 0f 80 00       	push   $0x800fbd
  800a8c:	e8 27 00 00 00       	call   800ab8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a94:	5b                   	pop    %ebx
  800a95:	5e                   	pop    %esi
  800a96:	5f                   	pop    %edi
  800a97:	5d                   	pop    %ebp
  800a98:	c3                   	ret    

00800a99 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	57                   	push   %edi
  800a9d:	56                   	push   %esi
  800a9e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a9f:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa4:	b8 02 00 00 00       	mov    $0x2,%eax
  800aa9:	89 d1                	mov    %edx,%ecx
  800aab:	89 d3                	mov    %edx,%ebx
  800aad:	89 d7                	mov    %edx,%edi
  800aaf:	89 d6                	mov    %edx,%esi
  800ab1:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ab3:	5b                   	pop    %ebx
  800ab4:	5e                   	pop    %esi
  800ab5:	5f                   	pop    %edi
  800ab6:	5d                   	pop    %ebp
  800ab7:	c3                   	ret    

00800ab8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ab8:	55                   	push   %ebp
  800ab9:	89 e5                	mov    %esp,%ebp
  800abb:	56                   	push   %esi
  800abc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800abd:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ac0:	8b 35 00 10 80 00    	mov    0x801000,%esi
  800ac6:	e8 ce ff ff ff       	call   800a99 <sys_getenvid>
  800acb:	83 ec 0c             	sub    $0xc,%esp
  800ace:	ff 75 0c             	pushl  0xc(%ebp)
  800ad1:	ff 75 08             	pushl  0x8(%ebp)
  800ad4:	56                   	push   %esi
  800ad5:	50                   	push   %eax
  800ad6:	68 cc 0f 80 00       	push   $0x800fcc
  800adb:	e8 6e f6 ff ff       	call   80014e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ae0:	83 c4 18             	add    $0x18,%esp
  800ae3:	53                   	push   %ebx
  800ae4:	ff 75 10             	pushl  0x10(%ebp)
  800ae7:	e8 11 f6 ff ff       	call   8000fd <vcprintf>
	cprintf("\n");
  800aec:	c7 04 24 90 0d 80 00 	movl   $0x800d90,(%esp)
  800af3:	e8 56 f6 ff ff       	call   80014e <cprintf>
  800af8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800afb:	cc                   	int3   
  800afc:	eb fd                	jmp    800afb <_panic+0x43>
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
