
obj/user/forktree:     file format elf32-i386


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
  80002c:	e8 b0 00 00 00       	call   8000e1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003d:	e8 d4 0a 00 00       	call   800b16 <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 00 13 80 00       	push   $0x801300
  80004c:	e8 7b 01 00 00       	call   8001cc <cprintf>

	forkchild(cur, '0');
  800051:	83 c4 08             	add    $0x8,%esp
  800054:	6a 30                	push   $0x30
  800056:	53                   	push   %ebx
  800057:	e8 13 00 00 00       	call   80006f <forkchild>
	forkchild(cur, '1');
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	6a 31                	push   $0x31
  800061:	53                   	push   %ebx
  800062:	e8 08 00 00 00       	call   80006f <forkchild>
}
  800067:	83 c4 10             	add    $0x10,%esp
  80006a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80006d:	c9                   	leave  
  80006e:	c3                   	ret    

0080006f <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  80006f:	55                   	push   %ebp
  800070:	89 e5                	mov    %esp,%ebp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	83 ec 1c             	sub    $0x1c,%esp
  800077:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80007a:	8b 75 0c             	mov    0xc(%ebp),%esi
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  80007d:	53                   	push   %ebx
  80007e:	e8 95 06 00 00       	call   800718 <strlen>
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	83 f8 02             	cmp    $0x2,%eax
  800089:	7f 3a                	jg     8000c5 <forkchild+0x56>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	89 f0                	mov    %esi,%eax
  800090:	0f be f0             	movsbl %al,%esi
  800093:	56                   	push   %esi
  800094:	53                   	push   %ebx
  800095:	68 11 13 80 00       	push   $0x801311
  80009a:	6a 04                	push   $0x4
  80009c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80009f:	50                   	push   %eax
  8000a0:	e8 59 06 00 00       	call   8006fe <snprintf>
	if (fork() == 0) {
  8000a5:	83 c4 20             	add    $0x20,%esp
  8000a8:	e8 33 0d 00 00       	call   800de0 <fork>
  8000ad:	85 c0                	test   %eax,%eax
  8000af:	75 14                	jne    8000c5 <forkchild+0x56>
		forktree(nxt);
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b7:	50                   	push   %eax
  8000b8:	e8 76 ff ff ff       	call   800033 <forktree>
		exit();
  8000bd:	e8 65 00 00 00       	call   800127 <exit>
  8000c2:	83 c4 10             	add    $0x10,%esp
	}
}
  8000c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c8:	5b                   	pop    %ebx
  8000c9:	5e                   	pop    %esi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000d2:	68 10 13 80 00       	push   $0x801310
  8000d7:	e8 57 ff ff ff       	call   800033 <forktree>
}
  8000dc:	83 c4 10             	add    $0x10,%esp
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    

008000e1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	56                   	push   %esi
  8000e5:	53                   	push   %ebx
  8000e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	envid_t envid = sys_getenvid();
  8000ec:	e8 25 0a 00 00       	call   800b16 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000f1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fe:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800103:	85 db                	test   %ebx,%ebx
  800105:	7e 07                	jle    80010e <libmain+0x2d>
		binaryname = argv[0];
  800107:	8b 06                	mov    (%esi),%eax
  800109:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80010e:	83 ec 08             	sub    $0x8,%esp
  800111:	56                   	push   %esi
  800112:	53                   	push   %ebx
  800113:	e8 b4 ff ff ff       	call   8000cc <umain>

	// exit gracefully
	exit();
  800118:	e8 0a 00 00 00       	call   800127 <exit>
}
  80011d:	83 c4 10             	add    $0x10,%esp
  800120:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5d                   	pop    %ebp
  800126:	c3                   	ret    

00800127 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80012d:	6a 00                	push   $0x0
  80012f:	e8 a1 09 00 00       	call   800ad5 <sys_env_destroy>
}
  800134:	83 c4 10             	add    $0x10,%esp
  800137:	c9                   	leave  
  800138:	c3                   	ret    

00800139 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	53                   	push   %ebx
  80013d:	83 ec 04             	sub    $0x4,%esp
  800140:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800143:	8b 13                	mov    (%ebx),%edx
  800145:	8d 42 01             	lea    0x1(%edx),%eax
  800148:	89 03                	mov    %eax,(%ebx)
  80014a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80014d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800151:	3d ff 00 00 00       	cmp    $0xff,%eax
  800156:	75 1a                	jne    800172 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800158:	83 ec 08             	sub    $0x8,%esp
  80015b:	68 ff 00 00 00       	push   $0xff
  800160:	8d 43 08             	lea    0x8(%ebx),%eax
  800163:	50                   	push   %eax
  800164:	e8 2f 09 00 00       	call   800a98 <sys_cputs>
		b->idx = 0;
  800169:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80016f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800172:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800176:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800179:	c9                   	leave  
  80017a:	c3                   	ret    

0080017b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80017b:	55                   	push   %ebp
  80017c:	89 e5                	mov    %esp,%ebp
  80017e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800184:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80018b:	00 00 00 
	b.cnt = 0;
  80018e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800195:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800198:	ff 75 0c             	pushl  0xc(%ebp)
  80019b:	ff 75 08             	pushl  0x8(%ebp)
  80019e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001a4:	50                   	push   %eax
  8001a5:	68 39 01 80 00       	push   $0x800139
  8001aa:	e8 54 01 00 00       	call   800303 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001af:	83 c4 08             	add    $0x8,%esp
  8001b2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001b8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001be:	50                   	push   %eax
  8001bf:	e8 d4 08 00 00       	call   800a98 <sys_cputs>

	return b.cnt;
}
  8001c4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ca:	c9                   	leave  
  8001cb:	c3                   	ret    

008001cc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001d2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001d5:	50                   	push   %eax
  8001d6:	ff 75 08             	pushl  0x8(%ebp)
  8001d9:	e8 9d ff ff ff       	call   80017b <vcprintf>
	va_end(ap);

	return cnt;
}
  8001de:	c9                   	leave  
  8001df:	c3                   	ret    

008001e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	57                   	push   %edi
  8001e4:	56                   	push   %esi
  8001e5:	53                   	push   %ebx
  8001e6:	83 ec 1c             	sub    $0x1c,%esp
  8001e9:	89 c7                	mov    %eax,%edi
  8001eb:	89 d6                	mov    %edx,%esi
  8001ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001f6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001f9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001fc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800201:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800204:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800207:	39 d3                	cmp    %edx,%ebx
  800209:	72 05                	jb     800210 <printnum+0x30>
  80020b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80020e:	77 45                	ja     800255 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800210:	83 ec 0c             	sub    $0xc,%esp
  800213:	ff 75 18             	pushl  0x18(%ebp)
  800216:	8b 45 14             	mov    0x14(%ebp),%eax
  800219:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80021c:	53                   	push   %ebx
  80021d:	ff 75 10             	pushl  0x10(%ebp)
  800220:	83 ec 08             	sub    $0x8,%esp
  800223:	ff 75 e4             	pushl  -0x1c(%ebp)
  800226:	ff 75 e0             	pushl  -0x20(%ebp)
  800229:	ff 75 dc             	pushl  -0x24(%ebp)
  80022c:	ff 75 d8             	pushl  -0x28(%ebp)
  80022f:	e8 2c 0e 00 00       	call   801060 <__udivdi3>
  800234:	83 c4 18             	add    $0x18,%esp
  800237:	52                   	push   %edx
  800238:	50                   	push   %eax
  800239:	89 f2                	mov    %esi,%edx
  80023b:	89 f8                	mov    %edi,%eax
  80023d:	e8 9e ff ff ff       	call   8001e0 <printnum>
  800242:	83 c4 20             	add    $0x20,%esp
  800245:	eb 18                	jmp    80025f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800247:	83 ec 08             	sub    $0x8,%esp
  80024a:	56                   	push   %esi
  80024b:	ff 75 18             	pushl  0x18(%ebp)
  80024e:	ff d7                	call   *%edi
  800250:	83 c4 10             	add    $0x10,%esp
  800253:	eb 03                	jmp    800258 <printnum+0x78>
  800255:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800258:	83 eb 01             	sub    $0x1,%ebx
  80025b:	85 db                	test   %ebx,%ebx
  80025d:	7f e8                	jg     800247 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80025f:	83 ec 08             	sub    $0x8,%esp
  800262:	56                   	push   %esi
  800263:	83 ec 04             	sub    $0x4,%esp
  800266:	ff 75 e4             	pushl  -0x1c(%ebp)
  800269:	ff 75 e0             	pushl  -0x20(%ebp)
  80026c:	ff 75 dc             	pushl  -0x24(%ebp)
  80026f:	ff 75 d8             	pushl  -0x28(%ebp)
  800272:	e8 19 0f 00 00       	call   801190 <__umoddi3>
  800277:	83 c4 14             	add    $0x14,%esp
  80027a:	0f be 80 20 13 80 00 	movsbl 0x801320(%eax),%eax
  800281:	50                   	push   %eax
  800282:	ff d7                	call   *%edi
}
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028a:	5b                   	pop    %ebx
  80028b:	5e                   	pop    %esi
  80028c:	5f                   	pop    %edi
  80028d:	5d                   	pop    %ebp
  80028e:	c3                   	ret    

0080028f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80028f:	55                   	push   %ebp
  800290:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800292:	83 fa 01             	cmp    $0x1,%edx
  800295:	7e 0e                	jle    8002a5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800297:	8b 10                	mov    (%eax),%edx
  800299:	8d 4a 08             	lea    0x8(%edx),%ecx
  80029c:	89 08                	mov    %ecx,(%eax)
  80029e:	8b 02                	mov    (%edx),%eax
  8002a0:	8b 52 04             	mov    0x4(%edx),%edx
  8002a3:	eb 22                	jmp    8002c7 <getuint+0x38>
	else if (lflag)
  8002a5:	85 d2                	test   %edx,%edx
  8002a7:	74 10                	je     8002b9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002a9:	8b 10                	mov    (%eax),%edx
  8002ab:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ae:	89 08                	mov    %ecx,(%eax)
  8002b0:	8b 02                	mov    (%edx),%eax
  8002b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b7:	eb 0e                	jmp    8002c7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002b9:	8b 10                	mov    (%eax),%edx
  8002bb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002be:	89 08                	mov    %ecx,(%eax)
  8002c0:	8b 02                	mov    (%edx),%eax
  8002c2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002c7:	5d                   	pop    %ebp
  8002c8:	c3                   	ret    

008002c9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
  8002cc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002cf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002d3:	8b 10                	mov    (%eax),%edx
  8002d5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d8:	73 0a                	jae    8002e4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002da:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002dd:	89 08                	mov    %ecx,(%eax)
  8002df:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e2:	88 02                	mov    %al,(%edx)
}
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    

008002e6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ec:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ef:	50                   	push   %eax
  8002f0:	ff 75 10             	pushl  0x10(%ebp)
  8002f3:	ff 75 0c             	pushl  0xc(%ebp)
  8002f6:	ff 75 08             	pushl  0x8(%ebp)
  8002f9:	e8 05 00 00 00       	call   800303 <vprintfmt>
	va_end(ap);
}
  8002fe:	83 c4 10             	add    $0x10,%esp
  800301:	c9                   	leave  
  800302:	c3                   	ret    

00800303 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800303:	55                   	push   %ebp
  800304:	89 e5                	mov    %esp,%ebp
  800306:	57                   	push   %edi
  800307:	56                   	push   %esi
  800308:	53                   	push   %ebx
  800309:	83 ec 2c             	sub    $0x2c,%esp
  80030c:	8b 75 08             	mov    0x8(%ebp),%esi
  80030f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800312:	8b 7d 10             	mov    0x10(%ebp),%edi
  800315:	eb 12                	jmp    800329 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800317:	85 c0                	test   %eax,%eax
  800319:	0f 84 89 03 00 00    	je     8006a8 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80031f:	83 ec 08             	sub    $0x8,%esp
  800322:	53                   	push   %ebx
  800323:	50                   	push   %eax
  800324:	ff d6                	call   *%esi
  800326:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800329:	83 c7 01             	add    $0x1,%edi
  80032c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800330:	83 f8 25             	cmp    $0x25,%eax
  800333:	75 e2                	jne    800317 <vprintfmt+0x14>
  800335:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800339:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800340:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800347:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80034e:	ba 00 00 00 00       	mov    $0x0,%edx
  800353:	eb 07                	jmp    80035c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800355:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800358:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035c:	8d 47 01             	lea    0x1(%edi),%eax
  80035f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800362:	0f b6 07             	movzbl (%edi),%eax
  800365:	0f b6 c8             	movzbl %al,%ecx
  800368:	83 e8 23             	sub    $0x23,%eax
  80036b:	3c 55                	cmp    $0x55,%al
  80036d:	0f 87 1a 03 00 00    	ja     80068d <vprintfmt+0x38a>
  800373:	0f b6 c0             	movzbl %al,%eax
  800376:	ff 24 85 e0 13 80 00 	jmp    *0x8013e0(,%eax,4)
  80037d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800380:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800384:	eb d6                	jmp    80035c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800386:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800389:	b8 00 00 00 00       	mov    $0x0,%eax
  80038e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800391:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800394:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800398:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80039b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80039e:	83 fa 09             	cmp    $0x9,%edx
  8003a1:	77 39                	ja     8003dc <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003a6:	eb e9                	jmp    800391 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ab:	8d 48 04             	lea    0x4(%eax),%ecx
  8003ae:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003b1:	8b 00                	mov    (%eax),%eax
  8003b3:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003b9:	eb 27                	jmp    8003e2 <vprintfmt+0xdf>
  8003bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003be:	85 c0                	test   %eax,%eax
  8003c0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c5:	0f 49 c8             	cmovns %eax,%ecx
  8003c8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ce:	eb 8c                	jmp    80035c <vprintfmt+0x59>
  8003d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003d3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003da:	eb 80                	jmp    80035c <vprintfmt+0x59>
  8003dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003df:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003e2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e6:	0f 89 70 ff ff ff    	jns    80035c <vprintfmt+0x59>
				width = precision, precision = -1;
  8003ec:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003f9:	e9 5e ff ff ff       	jmp    80035c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003fe:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800401:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800404:	e9 53 ff ff ff       	jmp    80035c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800409:	8b 45 14             	mov    0x14(%ebp),%eax
  80040c:	8d 50 04             	lea    0x4(%eax),%edx
  80040f:	89 55 14             	mov    %edx,0x14(%ebp)
  800412:	83 ec 08             	sub    $0x8,%esp
  800415:	53                   	push   %ebx
  800416:	ff 30                	pushl  (%eax)
  800418:	ff d6                	call   *%esi
			break;
  80041a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800420:	e9 04 ff ff ff       	jmp    800329 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800425:	8b 45 14             	mov    0x14(%ebp),%eax
  800428:	8d 50 04             	lea    0x4(%eax),%edx
  80042b:	89 55 14             	mov    %edx,0x14(%ebp)
  80042e:	8b 00                	mov    (%eax),%eax
  800430:	99                   	cltd   
  800431:	31 d0                	xor    %edx,%eax
  800433:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800435:	83 f8 09             	cmp    $0x9,%eax
  800438:	7f 0b                	jg     800445 <vprintfmt+0x142>
  80043a:	8b 14 85 40 15 80 00 	mov    0x801540(,%eax,4),%edx
  800441:	85 d2                	test   %edx,%edx
  800443:	75 18                	jne    80045d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800445:	50                   	push   %eax
  800446:	68 38 13 80 00       	push   $0x801338
  80044b:	53                   	push   %ebx
  80044c:	56                   	push   %esi
  80044d:	e8 94 fe ff ff       	call   8002e6 <printfmt>
  800452:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800455:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800458:	e9 cc fe ff ff       	jmp    800329 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80045d:	52                   	push   %edx
  80045e:	68 41 13 80 00       	push   $0x801341
  800463:	53                   	push   %ebx
  800464:	56                   	push   %esi
  800465:	e8 7c fe ff ff       	call   8002e6 <printfmt>
  80046a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800470:	e9 b4 fe ff ff       	jmp    800329 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800475:	8b 45 14             	mov    0x14(%ebp),%eax
  800478:	8d 50 04             	lea    0x4(%eax),%edx
  80047b:	89 55 14             	mov    %edx,0x14(%ebp)
  80047e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800480:	85 ff                	test   %edi,%edi
  800482:	b8 31 13 80 00       	mov    $0x801331,%eax
  800487:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80048a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80048e:	0f 8e 94 00 00 00    	jle    800528 <vprintfmt+0x225>
  800494:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800498:	0f 84 98 00 00 00    	je     800536 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80049e:	83 ec 08             	sub    $0x8,%esp
  8004a1:	ff 75 d0             	pushl  -0x30(%ebp)
  8004a4:	57                   	push   %edi
  8004a5:	e8 86 02 00 00       	call   800730 <strnlen>
  8004aa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ad:	29 c1                	sub    %eax,%ecx
  8004af:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004b2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004b5:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004bc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004bf:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c1:	eb 0f                	jmp    8004d2 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	53                   	push   %ebx
  8004c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ca:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cc:	83 ef 01             	sub    $0x1,%edi
  8004cf:	83 c4 10             	add    $0x10,%esp
  8004d2:	85 ff                	test   %edi,%edi
  8004d4:	7f ed                	jg     8004c3 <vprintfmt+0x1c0>
  8004d6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004d9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004dc:	85 c9                	test   %ecx,%ecx
  8004de:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e3:	0f 49 c1             	cmovns %ecx,%eax
  8004e6:	29 c1                	sub    %eax,%ecx
  8004e8:	89 75 08             	mov    %esi,0x8(%ebp)
  8004eb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ee:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f1:	89 cb                	mov    %ecx,%ebx
  8004f3:	eb 4d                	jmp    800542 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004f5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004f9:	74 1b                	je     800516 <vprintfmt+0x213>
  8004fb:	0f be c0             	movsbl %al,%eax
  8004fe:	83 e8 20             	sub    $0x20,%eax
  800501:	83 f8 5e             	cmp    $0x5e,%eax
  800504:	76 10                	jbe    800516 <vprintfmt+0x213>
					putch('?', putdat);
  800506:	83 ec 08             	sub    $0x8,%esp
  800509:	ff 75 0c             	pushl  0xc(%ebp)
  80050c:	6a 3f                	push   $0x3f
  80050e:	ff 55 08             	call   *0x8(%ebp)
  800511:	83 c4 10             	add    $0x10,%esp
  800514:	eb 0d                	jmp    800523 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800516:	83 ec 08             	sub    $0x8,%esp
  800519:	ff 75 0c             	pushl  0xc(%ebp)
  80051c:	52                   	push   %edx
  80051d:	ff 55 08             	call   *0x8(%ebp)
  800520:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800523:	83 eb 01             	sub    $0x1,%ebx
  800526:	eb 1a                	jmp    800542 <vprintfmt+0x23f>
  800528:	89 75 08             	mov    %esi,0x8(%ebp)
  80052b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80052e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800531:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800534:	eb 0c                	jmp    800542 <vprintfmt+0x23f>
  800536:	89 75 08             	mov    %esi,0x8(%ebp)
  800539:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80053c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80053f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800542:	83 c7 01             	add    $0x1,%edi
  800545:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800549:	0f be d0             	movsbl %al,%edx
  80054c:	85 d2                	test   %edx,%edx
  80054e:	74 23                	je     800573 <vprintfmt+0x270>
  800550:	85 f6                	test   %esi,%esi
  800552:	78 a1                	js     8004f5 <vprintfmt+0x1f2>
  800554:	83 ee 01             	sub    $0x1,%esi
  800557:	79 9c                	jns    8004f5 <vprintfmt+0x1f2>
  800559:	89 df                	mov    %ebx,%edi
  80055b:	8b 75 08             	mov    0x8(%ebp),%esi
  80055e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800561:	eb 18                	jmp    80057b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800563:	83 ec 08             	sub    $0x8,%esp
  800566:	53                   	push   %ebx
  800567:	6a 20                	push   $0x20
  800569:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80056b:	83 ef 01             	sub    $0x1,%edi
  80056e:	83 c4 10             	add    $0x10,%esp
  800571:	eb 08                	jmp    80057b <vprintfmt+0x278>
  800573:	89 df                	mov    %ebx,%edi
  800575:	8b 75 08             	mov    0x8(%ebp),%esi
  800578:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80057b:	85 ff                	test   %edi,%edi
  80057d:	7f e4                	jg     800563 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800582:	e9 a2 fd ff ff       	jmp    800329 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800587:	83 fa 01             	cmp    $0x1,%edx
  80058a:	7e 16                	jle    8005a2 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	8d 50 08             	lea    0x8(%eax),%edx
  800592:	89 55 14             	mov    %edx,0x14(%ebp)
  800595:	8b 50 04             	mov    0x4(%eax),%edx
  800598:	8b 00                	mov    (%eax),%eax
  80059a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a0:	eb 32                	jmp    8005d4 <vprintfmt+0x2d1>
	else if (lflag)
  8005a2:	85 d2                	test   %edx,%edx
  8005a4:	74 18                	je     8005be <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8005af:	8b 00                	mov    (%eax),%eax
  8005b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b4:	89 c1                	mov    %eax,%ecx
  8005b6:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005bc:	eb 16                	jmp    8005d4 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005be:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c1:	8d 50 04             	lea    0x4(%eax),%edx
  8005c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c7:	8b 00                	mov    (%eax),%eax
  8005c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005cc:	89 c1                	mov    %eax,%ecx
  8005ce:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005d4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d7:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005da:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005df:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005e3:	79 74                	jns    800659 <vprintfmt+0x356>
				putch('-', putdat);
  8005e5:	83 ec 08             	sub    $0x8,%esp
  8005e8:	53                   	push   %ebx
  8005e9:	6a 2d                	push   $0x2d
  8005eb:	ff d6                	call   *%esi
				num = -(long long) num;
  8005ed:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005f0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005f3:	f7 d8                	neg    %eax
  8005f5:	83 d2 00             	adc    $0x0,%edx
  8005f8:	f7 da                	neg    %edx
  8005fa:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005fd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800602:	eb 55                	jmp    800659 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800604:	8d 45 14             	lea    0x14(%ebp),%eax
  800607:	e8 83 fc ff ff       	call   80028f <getuint>
			base = 10;
  80060c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800611:	eb 46                	jmp    800659 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800613:	8d 45 14             	lea    0x14(%ebp),%eax
  800616:	e8 74 fc ff ff       	call   80028f <getuint>
			base = 8;
  80061b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800620:	eb 37                	jmp    800659 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800622:	83 ec 08             	sub    $0x8,%esp
  800625:	53                   	push   %ebx
  800626:	6a 30                	push   $0x30
  800628:	ff d6                	call   *%esi
			putch('x', putdat);
  80062a:	83 c4 08             	add    $0x8,%esp
  80062d:	53                   	push   %ebx
  80062e:	6a 78                	push   $0x78
  800630:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8d 50 04             	lea    0x4(%eax),%edx
  800638:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80063b:	8b 00                	mov    (%eax),%eax
  80063d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800642:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800645:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80064a:	eb 0d                	jmp    800659 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80064c:	8d 45 14             	lea    0x14(%ebp),%eax
  80064f:	e8 3b fc ff ff       	call   80028f <getuint>
			base = 16;
  800654:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800659:	83 ec 0c             	sub    $0xc,%esp
  80065c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800660:	57                   	push   %edi
  800661:	ff 75 e0             	pushl  -0x20(%ebp)
  800664:	51                   	push   %ecx
  800665:	52                   	push   %edx
  800666:	50                   	push   %eax
  800667:	89 da                	mov    %ebx,%edx
  800669:	89 f0                	mov    %esi,%eax
  80066b:	e8 70 fb ff ff       	call   8001e0 <printnum>
			break;
  800670:	83 c4 20             	add    $0x20,%esp
  800673:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800676:	e9 ae fc ff ff       	jmp    800329 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80067b:	83 ec 08             	sub    $0x8,%esp
  80067e:	53                   	push   %ebx
  80067f:	51                   	push   %ecx
  800680:	ff d6                	call   *%esi
			break;
  800682:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800685:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800688:	e9 9c fc ff ff       	jmp    800329 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80068d:	83 ec 08             	sub    $0x8,%esp
  800690:	53                   	push   %ebx
  800691:	6a 25                	push   $0x25
  800693:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800695:	83 c4 10             	add    $0x10,%esp
  800698:	eb 03                	jmp    80069d <vprintfmt+0x39a>
  80069a:	83 ef 01             	sub    $0x1,%edi
  80069d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006a1:	75 f7                	jne    80069a <vprintfmt+0x397>
  8006a3:	e9 81 fc ff ff       	jmp    800329 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ab:	5b                   	pop    %ebx
  8006ac:	5e                   	pop    %esi
  8006ad:	5f                   	pop    %edi
  8006ae:	5d                   	pop    %ebp
  8006af:	c3                   	ret    

008006b0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006b0:	55                   	push   %ebp
  8006b1:	89 e5                	mov    %esp,%ebp
  8006b3:	83 ec 18             	sub    $0x18,%esp
  8006b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006bf:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006c3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006cd:	85 c0                	test   %eax,%eax
  8006cf:	74 26                	je     8006f7 <vsnprintf+0x47>
  8006d1:	85 d2                	test   %edx,%edx
  8006d3:	7e 22                	jle    8006f7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006d5:	ff 75 14             	pushl  0x14(%ebp)
  8006d8:	ff 75 10             	pushl  0x10(%ebp)
  8006db:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006de:	50                   	push   %eax
  8006df:	68 c9 02 80 00       	push   $0x8002c9
  8006e4:	e8 1a fc ff ff       	call   800303 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ec:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f2:	83 c4 10             	add    $0x10,%esp
  8006f5:	eb 05                	jmp    8006fc <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006fc:	c9                   	leave  
  8006fd:	c3                   	ret    

008006fe <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006fe:	55                   	push   %ebp
  8006ff:	89 e5                	mov    %esp,%ebp
  800701:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800704:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800707:	50                   	push   %eax
  800708:	ff 75 10             	pushl  0x10(%ebp)
  80070b:	ff 75 0c             	pushl  0xc(%ebp)
  80070e:	ff 75 08             	pushl  0x8(%ebp)
  800711:	e8 9a ff ff ff       	call   8006b0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800716:	c9                   	leave  
  800717:	c3                   	ret    

00800718 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80071e:	b8 00 00 00 00       	mov    $0x0,%eax
  800723:	eb 03                	jmp    800728 <strlen+0x10>
		n++;
  800725:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800728:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80072c:	75 f7                	jne    800725 <strlen+0xd>
		n++;
	return n;
}
  80072e:	5d                   	pop    %ebp
  80072f:	c3                   	ret    

00800730 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800736:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800739:	ba 00 00 00 00       	mov    $0x0,%edx
  80073e:	eb 03                	jmp    800743 <strnlen+0x13>
		n++;
  800740:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800743:	39 c2                	cmp    %eax,%edx
  800745:	74 08                	je     80074f <strnlen+0x1f>
  800747:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80074b:	75 f3                	jne    800740 <strnlen+0x10>
  80074d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80074f:	5d                   	pop    %ebp
  800750:	c3                   	ret    

00800751 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800751:	55                   	push   %ebp
  800752:	89 e5                	mov    %esp,%ebp
  800754:	53                   	push   %ebx
  800755:	8b 45 08             	mov    0x8(%ebp),%eax
  800758:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80075b:	89 c2                	mov    %eax,%edx
  80075d:	83 c2 01             	add    $0x1,%edx
  800760:	83 c1 01             	add    $0x1,%ecx
  800763:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800767:	88 5a ff             	mov    %bl,-0x1(%edx)
  80076a:	84 db                	test   %bl,%bl
  80076c:	75 ef                	jne    80075d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80076e:	5b                   	pop    %ebx
  80076f:	5d                   	pop    %ebp
  800770:	c3                   	ret    

00800771 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800771:	55                   	push   %ebp
  800772:	89 e5                	mov    %esp,%ebp
  800774:	53                   	push   %ebx
  800775:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800778:	53                   	push   %ebx
  800779:	e8 9a ff ff ff       	call   800718 <strlen>
  80077e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800781:	ff 75 0c             	pushl  0xc(%ebp)
  800784:	01 d8                	add    %ebx,%eax
  800786:	50                   	push   %eax
  800787:	e8 c5 ff ff ff       	call   800751 <strcpy>
	return dst;
}
  80078c:	89 d8                	mov    %ebx,%eax
  80078e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800791:	c9                   	leave  
  800792:	c3                   	ret    

00800793 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	56                   	push   %esi
  800797:	53                   	push   %ebx
  800798:	8b 75 08             	mov    0x8(%ebp),%esi
  80079b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80079e:	89 f3                	mov    %esi,%ebx
  8007a0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a3:	89 f2                	mov    %esi,%edx
  8007a5:	eb 0f                	jmp    8007b6 <strncpy+0x23>
		*dst++ = *src;
  8007a7:	83 c2 01             	add    $0x1,%edx
  8007aa:	0f b6 01             	movzbl (%ecx),%eax
  8007ad:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007b0:	80 39 01             	cmpb   $0x1,(%ecx)
  8007b3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b6:	39 da                	cmp    %ebx,%edx
  8007b8:	75 ed                	jne    8007a7 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007ba:	89 f0                	mov    %esi,%eax
  8007bc:	5b                   	pop    %ebx
  8007bd:	5e                   	pop    %esi
  8007be:	5d                   	pop    %ebp
  8007bf:	c3                   	ret    

008007c0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	56                   	push   %esi
  8007c4:	53                   	push   %ebx
  8007c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007cb:	8b 55 10             	mov    0x10(%ebp),%edx
  8007ce:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d0:	85 d2                	test   %edx,%edx
  8007d2:	74 21                	je     8007f5 <strlcpy+0x35>
  8007d4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007d8:	89 f2                	mov    %esi,%edx
  8007da:	eb 09                	jmp    8007e5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007dc:	83 c2 01             	add    $0x1,%edx
  8007df:	83 c1 01             	add    $0x1,%ecx
  8007e2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007e5:	39 c2                	cmp    %eax,%edx
  8007e7:	74 09                	je     8007f2 <strlcpy+0x32>
  8007e9:	0f b6 19             	movzbl (%ecx),%ebx
  8007ec:	84 db                	test   %bl,%bl
  8007ee:	75 ec                	jne    8007dc <strlcpy+0x1c>
  8007f0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007f2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007f5:	29 f0                	sub    %esi,%eax
}
  8007f7:	5b                   	pop    %ebx
  8007f8:	5e                   	pop    %esi
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800801:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800804:	eb 06                	jmp    80080c <strcmp+0x11>
		p++, q++;
  800806:	83 c1 01             	add    $0x1,%ecx
  800809:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80080c:	0f b6 01             	movzbl (%ecx),%eax
  80080f:	84 c0                	test   %al,%al
  800811:	74 04                	je     800817 <strcmp+0x1c>
  800813:	3a 02                	cmp    (%edx),%al
  800815:	74 ef                	je     800806 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800817:	0f b6 c0             	movzbl %al,%eax
  80081a:	0f b6 12             	movzbl (%edx),%edx
  80081d:	29 d0                	sub    %edx,%eax
}
  80081f:	5d                   	pop    %ebp
  800820:	c3                   	ret    

00800821 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	53                   	push   %ebx
  800825:	8b 45 08             	mov    0x8(%ebp),%eax
  800828:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082b:	89 c3                	mov    %eax,%ebx
  80082d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800830:	eb 06                	jmp    800838 <strncmp+0x17>
		n--, p++, q++;
  800832:	83 c0 01             	add    $0x1,%eax
  800835:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800838:	39 d8                	cmp    %ebx,%eax
  80083a:	74 15                	je     800851 <strncmp+0x30>
  80083c:	0f b6 08             	movzbl (%eax),%ecx
  80083f:	84 c9                	test   %cl,%cl
  800841:	74 04                	je     800847 <strncmp+0x26>
  800843:	3a 0a                	cmp    (%edx),%cl
  800845:	74 eb                	je     800832 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800847:	0f b6 00             	movzbl (%eax),%eax
  80084a:	0f b6 12             	movzbl (%edx),%edx
  80084d:	29 d0                	sub    %edx,%eax
  80084f:	eb 05                	jmp    800856 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800851:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800856:	5b                   	pop    %ebx
  800857:	5d                   	pop    %ebp
  800858:	c3                   	ret    

00800859 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	8b 45 08             	mov    0x8(%ebp),%eax
  80085f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800863:	eb 07                	jmp    80086c <strchr+0x13>
		if (*s == c)
  800865:	38 ca                	cmp    %cl,%dl
  800867:	74 0f                	je     800878 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800869:	83 c0 01             	add    $0x1,%eax
  80086c:	0f b6 10             	movzbl (%eax),%edx
  80086f:	84 d2                	test   %dl,%dl
  800871:	75 f2                	jne    800865 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800873:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800878:	5d                   	pop    %ebp
  800879:	c3                   	ret    

0080087a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	8b 45 08             	mov    0x8(%ebp),%eax
  800880:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800884:	eb 03                	jmp    800889 <strfind+0xf>
  800886:	83 c0 01             	add    $0x1,%eax
  800889:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80088c:	38 ca                	cmp    %cl,%dl
  80088e:	74 04                	je     800894 <strfind+0x1a>
  800890:	84 d2                	test   %dl,%dl
  800892:	75 f2                	jne    800886 <strfind+0xc>
			break;
	return (char *) s;
}
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	57                   	push   %edi
  80089a:	56                   	push   %esi
  80089b:	53                   	push   %ebx
  80089c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80089f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008a2:	85 c9                	test   %ecx,%ecx
  8008a4:	74 36                	je     8008dc <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008a6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ac:	75 28                	jne    8008d6 <memset+0x40>
  8008ae:	f6 c1 03             	test   $0x3,%cl
  8008b1:	75 23                	jne    8008d6 <memset+0x40>
		c &= 0xFF;
  8008b3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008b7:	89 d3                	mov    %edx,%ebx
  8008b9:	c1 e3 08             	shl    $0x8,%ebx
  8008bc:	89 d6                	mov    %edx,%esi
  8008be:	c1 e6 18             	shl    $0x18,%esi
  8008c1:	89 d0                	mov    %edx,%eax
  8008c3:	c1 e0 10             	shl    $0x10,%eax
  8008c6:	09 f0                	or     %esi,%eax
  8008c8:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008ca:	89 d8                	mov    %ebx,%eax
  8008cc:	09 d0                	or     %edx,%eax
  8008ce:	c1 e9 02             	shr    $0x2,%ecx
  8008d1:	fc                   	cld    
  8008d2:	f3 ab                	rep stos %eax,%es:(%edi)
  8008d4:	eb 06                	jmp    8008dc <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d9:	fc                   	cld    
  8008da:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008dc:	89 f8                	mov    %edi,%eax
  8008de:	5b                   	pop    %ebx
  8008df:	5e                   	pop    %esi
  8008e0:	5f                   	pop    %edi
  8008e1:	5d                   	pop    %ebp
  8008e2:	c3                   	ret    

008008e3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	57                   	push   %edi
  8008e7:	56                   	push   %esi
  8008e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008eb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008f1:	39 c6                	cmp    %eax,%esi
  8008f3:	73 35                	jae    80092a <memmove+0x47>
  8008f5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008f8:	39 d0                	cmp    %edx,%eax
  8008fa:	73 2e                	jae    80092a <memmove+0x47>
		s += n;
		d += n;
  8008fc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ff:	89 d6                	mov    %edx,%esi
  800901:	09 fe                	or     %edi,%esi
  800903:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800909:	75 13                	jne    80091e <memmove+0x3b>
  80090b:	f6 c1 03             	test   $0x3,%cl
  80090e:	75 0e                	jne    80091e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800910:	83 ef 04             	sub    $0x4,%edi
  800913:	8d 72 fc             	lea    -0x4(%edx),%esi
  800916:	c1 e9 02             	shr    $0x2,%ecx
  800919:	fd                   	std    
  80091a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80091c:	eb 09                	jmp    800927 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80091e:	83 ef 01             	sub    $0x1,%edi
  800921:	8d 72 ff             	lea    -0x1(%edx),%esi
  800924:	fd                   	std    
  800925:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800927:	fc                   	cld    
  800928:	eb 1d                	jmp    800947 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092a:	89 f2                	mov    %esi,%edx
  80092c:	09 c2                	or     %eax,%edx
  80092e:	f6 c2 03             	test   $0x3,%dl
  800931:	75 0f                	jne    800942 <memmove+0x5f>
  800933:	f6 c1 03             	test   $0x3,%cl
  800936:	75 0a                	jne    800942 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800938:	c1 e9 02             	shr    $0x2,%ecx
  80093b:	89 c7                	mov    %eax,%edi
  80093d:	fc                   	cld    
  80093e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800940:	eb 05                	jmp    800947 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800942:	89 c7                	mov    %eax,%edi
  800944:	fc                   	cld    
  800945:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800947:	5e                   	pop    %esi
  800948:	5f                   	pop    %edi
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80094e:	ff 75 10             	pushl  0x10(%ebp)
  800951:	ff 75 0c             	pushl  0xc(%ebp)
  800954:	ff 75 08             	pushl  0x8(%ebp)
  800957:	e8 87 ff ff ff       	call   8008e3 <memmove>
}
  80095c:	c9                   	leave  
  80095d:	c3                   	ret    

0080095e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	56                   	push   %esi
  800962:	53                   	push   %ebx
  800963:	8b 45 08             	mov    0x8(%ebp),%eax
  800966:	8b 55 0c             	mov    0xc(%ebp),%edx
  800969:	89 c6                	mov    %eax,%esi
  80096b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80096e:	eb 1a                	jmp    80098a <memcmp+0x2c>
		if (*s1 != *s2)
  800970:	0f b6 08             	movzbl (%eax),%ecx
  800973:	0f b6 1a             	movzbl (%edx),%ebx
  800976:	38 d9                	cmp    %bl,%cl
  800978:	74 0a                	je     800984 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80097a:	0f b6 c1             	movzbl %cl,%eax
  80097d:	0f b6 db             	movzbl %bl,%ebx
  800980:	29 d8                	sub    %ebx,%eax
  800982:	eb 0f                	jmp    800993 <memcmp+0x35>
		s1++, s2++;
  800984:	83 c0 01             	add    $0x1,%eax
  800987:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80098a:	39 f0                	cmp    %esi,%eax
  80098c:	75 e2                	jne    800970 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80098e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800993:	5b                   	pop    %ebx
  800994:	5e                   	pop    %esi
  800995:	5d                   	pop    %ebp
  800996:	c3                   	ret    

00800997 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	53                   	push   %ebx
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80099e:	89 c1                	mov    %eax,%ecx
  8009a0:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009a3:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009a7:	eb 0a                	jmp    8009b3 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009a9:	0f b6 10             	movzbl (%eax),%edx
  8009ac:	39 da                	cmp    %ebx,%edx
  8009ae:	74 07                	je     8009b7 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b0:	83 c0 01             	add    $0x1,%eax
  8009b3:	39 c8                	cmp    %ecx,%eax
  8009b5:	72 f2                	jb     8009a9 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009b7:	5b                   	pop    %ebx
  8009b8:	5d                   	pop    %ebp
  8009b9:	c3                   	ret    

008009ba <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
  8009bd:	57                   	push   %edi
  8009be:	56                   	push   %esi
  8009bf:	53                   	push   %ebx
  8009c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c6:	eb 03                	jmp    8009cb <strtol+0x11>
		s++;
  8009c8:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009cb:	0f b6 01             	movzbl (%ecx),%eax
  8009ce:	3c 20                	cmp    $0x20,%al
  8009d0:	74 f6                	je     8009c8 <strtol+0xe>
  8009d2:	3c 09                	cmp    $0x9,%al
  8009d4:	74 f2                	je     8009c8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009d6:	3c 2b                	cmp    $0x2b,%al
  8009d8:	75 0a                	jne    8009e4 <strtol+0x2a>
		s++;
  8009da:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009dd:	bf 00 00 00 00       	mov    $0x0,%edi
  8009e2:	eb 11                	jmp    8009f5 <strtol+0x3b>
  8009e4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009e9:	3c 2d                	cmp    $0x2d,%al
  8009eb:	75 08                	jne    8009f5 <strtol+0x3b>
		s++, neg = 1;
  8009ed:	83 c1 01             	add    $0x1,%ecx
  8009f0:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009f5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009fb:	75 15                	jne    800a12 <strtol+0x58>
  8009fd:	80 39 30             	cmpb   $0x30,(%ecx)
  800a00:	75 10                	jne    800a12 <strtol+0x58>
  800a02:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a06:	75 7c                	jne    800a84 <strtol+0xca>
		s += 2, base = 16;
  800a08:	83 c1 02             	add    $0x2,%ecx
  800a0b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a10:	eb 16                	jmp    800a28 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a12:	85 db                	test   %ebx,%ebx
  800a14:	75 12                	jne    800a28 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a16:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a1b:	80 39 30             	cmpb   $0x30,(%ecx)
  800a1e:	75 08                	jne    800a28 <strtol+0x6e>
		s++, base = 8;
  800a20:	83 c1 01             	add    $0x1,%ecx
  800a23:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a28:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a30:	0f b6 11             	movzbl (%ecx),%edx
  800a33:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a36:	89 f3                	mov    %esi,%ebx
  800a38:	80 fb 09             	cmp    $0x9,%bl
  800a3b:	77 08                	ja     800a45 <strtol+0x8b>
			dig = *s - '0';
  800a3d:	0f be d2             	movsbl %dl,%edx
  800a40:	83 ea 30             	sub    $0x30,%edx
  800a43:	eb 22                	jmp    800a67 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a45:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a48:	89 f3                	mov    %esi,%ebx
  800a4a:	80 fb 19             	cmp    $0x19,%bl
  800a4d:	77 08                	ja     800a57 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a4f:	0f be d2             	movsbl %dl,%edx
  800a52:	83 ea 57             	sub    $0x57,%edx
  800a55:	eb 10                	jmp    800a67 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a57:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a5a:	89 f3                	mov    %esi,%ebx
  800a5c:	80 fb 19             	cmp    $0x19,%bl
  800a5f:	77 16                	ja     800a77 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a61:	0f be d2             	movsbl %dl,%edx
  800a64:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a67:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a6a:	7d 0b                	jge    800a77 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a6c:	83 c1 01             	add    $0x1,%ecx
  800a6f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a73:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a75:	eb b9                	jmp    800a30 <strtol+0x76>

	if (endptr)
  800a77:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a7b:	74 0d                	je     800a8a <strtol+0xd0>
		*endptr = (char *) s;
  800a7d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a80:	89 0e                	mov    %ecx,(%esi)
  800a82:	eb 06                	jmp    800a8a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a84:	85 db                	test   %ebx,%ebx
  800a86:	74 98                	je     800a20 <strtol+0x66>
  800a88:	eb 9e                	jmp    800a28 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a8a:	89 c2                	mov    %eax,%edx
  800a8c:	f7 da                	neg    %edx
  800a8e:	85 ff                	test   %edi,%edi
  800a90:	0f 45 c2             	cmovne %edx,%eax
}
  800a93:	5b                   	pop    %ebx
  800a94:	5e                   	pop    %esi
  800a95:	5f                   	pop    %edi
  800a96:	5d                   	pop    %ebp
  800a97:	c3                   	ret    

00800a98 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a98:	55                   	push   %ebp
  800a99:	89 e5                	mov    %esp,%ebp
  800a9b:	57                   	push   %edi
  800a9c:	56                   	push   %esi
  800a9d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a9e:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aa6:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa9:	89 c3                	mov    %eax,%ebx
  800aab:	89 c7                	mov    %eax,%edi
  800aad:	89 c6                	mov    %eax,%esi
  800aaf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ab1:	5b                   	pop    %ebx
  800ab2:	5e                   	pop    %esi
  800ab3:	5f                   	pop    %edi
  800ab4:	5d                   	pop    %ebp
  800ab5:	c3                   	ret    

00800ab6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ab6:	55                   	push   %ebp
  800ab7:	89 e5                	mov    %esp,%ebp
  800ab9:	57                   	push   %edi
  800aba:	56                   	push   %esi
  800abb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800abc:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ac6:	89 d1                	mov    %edx,%ecx
  800ac8:	89 d3                	mov    %edx,%ebx
  800aca:	89 d7                	mov    %edx,%edi
  800acc:	89 d6                	mov    %edx,%esi
  800ace:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ad0:	5b                   	pop    %ebx
  800ad1:	5e                   	pop    %esi
  800ad2:	5f                   	pop    %edi
  800ad3:	5d                   	pop    %ebp
  800ad4:	c3                   	ret    

00800ad5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ad5:	55                   	push   %ebp
  800ad6:	89 e5                	mov    %esp,%ebp
  800ad8:	57                   	push   %edi
  800ad9:	56                   	push   %esi
  800ada:	53                   	push   %ebx
  800adb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ade:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ae3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ae8:	8b 55 08             	mov    0x8(%ebp),%edx
  800aeb:	89 cb                	mov    %ecx,%ebx
  800aed:	89 cf                	mov    %ecx,%edi
  800aef:	89 ce                	mov    %ecx,%esi
  800af1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800af3:	85 c0                	test   %eax,%eax
  800af5:	7e 17                	jle    800b0e <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800af7:	83 ec 0c             	sub    $0xc,%esp
  800afa:	50                   	push   %eax
  800afb:	6a 03                	push   $0x3
  800afd:	68 68 15 80 00       	push   $0x801568
  800b02:	6a 23                	push   $0x23
  800b04:	68 85 15 80 00       	push   $0x801585
  800b09:	e8 6c 04 00 00       	call   800f7a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b11:	5b                   	pop    %ebx
  800b12:	5e                   	pop    %esi
  800b13:	5f                   	pop    %edi
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    

00800b16 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	57                   	push   %edi
  800b1a:	56                   	push   %esi
  800b1b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b21:	b8 02 00 00 00       	mov    $0x2,%eax
  800b26:	89 d1                	mov    %edx,%ecx
  800b28:	89 d3                	mov    %edx,%ebx
  800b2a:	89 d7                	mov    %edx,%edi
  800b2c:	89 d6                	mov    %edx,%esi
  800b2e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b30:	5b                   	pop    %ebx
  800b31:	5e                   	pop    %esi
  800b32:	5f                   	pop    %edi
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    

00800b35 <sys_yield>:

void
sys_yield(void)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	57                   	push   %edi
  800b39:	56                   	push   %esi
  800b3a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b40:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b45:	89 d1                	mov    %edx,%ecx
  800b47:	89 d3                	mov    %edx,%ebx
  800b49:	89 d7                	mov    %edx,%edi
  800b4b:	89 d6                	mov    %edx,%esi
  800b4d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b4f:	5b                   	pop    %ebx
  800b50:	5e                   	pop    %esi
  800b51:	5f                   	pop    %edi
  800b52:	5d                   	pop    %ebp
  800b53:	c3                   	ret    

00800b54 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	57                   	push   %edi
  800b58:	56                   	push   %esi
  800b59:	53                   	push   %ebx
  800b5a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5d:	be 00 00 00 00       	mov    $0x0,%esi
  800b62:	b8 04 00 00 00       	mov    $0x4,%eax
  800b67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b70:	89 f7                	mov    %esi,%edi
  800b72:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b74:	85 c0                	test   %eax,%eax
  800b76:	7e 17                	jle    800b8f <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b78:	83 ec 0c             	sub    $0xc,%esp
  800b7b:	50                   	push   %eax
  800b7c:	6a 04                	push   $0x4
  800b7e:	68 68 15 80 00       	push   $0x801568
  800b83:	6a 23                	push   $0x23
  800b85:	68 85 15 80 00       	push   $0x801585
  800b8a:	e8 eb 03 00 00       	call   800f7a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b92:	5b                   	pop    %ebx
  800b93:	5e                   	pop    %esi
  800b94:	5f                   	pop    %edi
  800b95:	5d                   	pop    %ebp
  800b96:	c3                   	ret    

00800b97 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	57                   	push   %edi
  800b9b:	56                   	push   %esi
  800b9c:	53                   	push   %ebx
  800b9d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba0:	b8 05 00 00 00       	mov    $0x5,%eax
  800ba5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bae:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bb1:	8b 75 18             	mov    0x18(%ebp),%esi
  800bb4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bb6:	85 c0                	test   %eax,%eax
  800bb8:	7e 17                	jle    800bd1 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bba:	83 ec 0c             	sub    $0xc,%esp
  800bbd:	50                   	push   %eax
  800bbe:	6a 05                	push   $0x5
  800bc0:	68 68 15 80 00       	push   $0x801568
  800bc5:	6a 23                	push   $0x23
  800bc7:	68 85 15 80 00       	push   $0x801585
  800bcc:	e8 a9 03 00 00       	call   800f7a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd4:	5b                   	pop    %ebx
  800bd5:	5e                   	pop    %esi
  800bd6:	5f                   	pop    %edi
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    

00800bd9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	57                   	push   %edi
  800bdd:	56                   	push   %esi
  800bde:	53                   	push   %ebx
  800bdf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800be7:	b8 06 00 00 00       	mov    $0x6,%eax
  800bec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bef:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf2:	89 df                	mov    %ebx,%edi
  800bf4:	89 de                	mov    %ebx,%esi
  800bf6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bf8:	85 c0                	test   %eax,%eax
  800bfa:	7e 17                	jle    800c13 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfc:	83 ec 0c             	sub    $0xc,%esp
  800bff:	50                   	push   %eax
  800c00:	6a 06                	push   $0x6
  800c02:	68 68 15 80 00       	push   $0x801568
  800c07:	6a 23                	push   $0x23
  800c09:	68 85 15 80 00       	push   $0x801585
  800c0e:	e8 67 03 00 00       	call   800f7a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c16:	5b                   	pop    %ebx
  800c17:	5e                   	pop    %esi
  800c18:	5f                   	pop    %edi
  800c19:	5d                   	pop    %ebp
  800c1a:	c3                   	ret    

00800c1b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	57                   	push   %edi
  800c1f:	56                   	push   %esi
  800c20:	53                   	push   %ebx
  800c21:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c24:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c29:	b8 08 00 00 00       	mov    $0x8,%eax
  800c2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c31:	8b 55 08             	mov    0x8(%ebp),%edx
  800c34:	89 df                	mov    %ebx,%edi
  800c36:	89 de                	mov    %ebx,%esi
  800c38:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c3a:	85 c0                	test   %eax,%eax
  800c3c:	7e 17                	jle    800c55 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3e:	83 ec 0c             	sub    $0xc,%esp
  800c41:	50                   	push   %eax
  800c42:	6a 08                	push   $0x8
  800c44:	68 68 15 80 00       	push   $0x801568
  800c49:	6a 23                	push   $0x23
  800c4b:	68 85 15 80 00       	push   $0x801585
  800c50:	e8 25 03 00 00       	call   800f7a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c58:	5b                   	pop    %ebx
  800c59:	5e                   	pop    %esi
  800c5a:	5f                   	pop    %edi
  800c5b:	5d                   	pop    %ebp
  800c5c:	c3                   	ret    

00800c5d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c5d:	55                   	push   %ebp
  800c5e:	89 e5                	mov    %esp,%ebp
  800c60:	57                   	push   %edi
  800c61:	56                   	push   %esi
  800c62:	53                   	push   %ebx
  800c63:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c66:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6b:	b8 09 00 00 00       	mov    $0x9,%eax
  800c70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c73:	8b 55 08             	mov    0x8(%ebp),%edx
  800c76:	89 df                	mov    %ebx,%edi
  800c78:	89 de                	mov    %ebx,%esi
  800c7a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c7c:	85 c0                	test   %eax,%eax
  800c7e:	7e 17                	jle    800c97 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c80:	83 ec 0c             	sub    $0xc,%esp
  800c83:	50                   	push   %eax
  800c84:	6a 09                	push   $0x9
  800c86:	68 68 15 80 00       	push   $0x801568
  800c8b:	6a 23                	push   $0x23
  800c8d:	68 85 15 80 00       	push   $0x801585
  800c92:	e8 e3 02 00 00       	call   800f7a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9a:	5b                   	pop    %ebx
  800c9b:	5e                   	pop    %esi
  800c9c:	5f                   	pop    %edi
  800c9d:	5d                   	pop    %ebp
  800c9e:	c3                   	ret    

00800c9f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c9f:	55                   	push   %ebp
  800ca0:	89 e5                	mov    %esp,%ebp
  800ca2:	57                   	push   %edi
  800ca3:	56                   	push   %esi
  800ca4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca5:	be 00 00 00 00       	mov    $0x0,%esi
  800caa:	b8 0b 00 00 00       	mov    $0xb,%eax
  800caf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cbb:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    

00800cc2 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	57                   	push   %edi
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
  800cc8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd0:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd8:	89 cb                	mov    %ecx,%ebx
  800cda:	89 cf                	mov    %ecx,%edi
  800cdc:	89 ce                	mov    %ecx,%esi
  800cde:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	7e 17                	jle    800cfb <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce4:	83 ec 0c             	sub    $0xc,%esp
  800ce7:	50                   	push   %eax
  800ce8:	6a 0c                	push   $0xc
  800cea:	68 68 15 80 00       	push   $0x801568
  800cef:	6a 23                	push   $0x23
  800cf1:	68 85 15 80 00       	push   $0x801585
  800cf6:	e8 7f 02 00 00       	call   800f7a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfe:	5b                   	pop    %ebx
  800cff:	5e                   	pop    %esi
  800d00:	5f                   	pop    %edi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    

00800d03 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	53                   	push   %ebx
  800d07:	83 ec 04             	sub    $0x4,%esp
  800d0a:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
	void *fault_va = ROUNDDOWN(addr, PGSIZE);
  800d0d:	8b 18                	mov    (%eax),%ebx
  800d0f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	if (!(err & FEC_WR) || (uvpt[PGNUM(fault_va)] & perm) != perm)
  800d15:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d19:	74 18                	je     800d33 <pgfault+0x30>
  800d1b:	89 d8                	mov    %ebx,%eax
  800d1d:	c1 e8 0c             	shr    $0xc,%eax
  800d20:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d27:	25 05 08 00 00       	and    $0x805,%eax
  800d2c:	3d 05 08 00 00       	cmp    $0x805,%eax
  800d31:	74 14                	je     800d47 <pgfault+0x44>
		panic("invalid faulting access");
  800d33:	83 ec 04             	sub    $0x4,%esp
  800d36:	68 93 15 80 00       	push   $0x801593
  800d3b:	6a 1d                	push   $0x1d
  800d3d:	68 ab 15 80 00       	push   $0x8015ab
  800d42:	e8 33 02 00 00       	call   800f7a <_panic>
	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	if ((r = sys_page_alloc(0, (void *) PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800d47:	83 ec 04             	sub    $0x4,%esp
  800d4a:	6a 07                	push   $0x7
  800d4c:	68 00 f0 7f 00       	push   $0x7ff000
  800d51:	6a 00                	push   $0x0
  800d53:	e8 fc fd ff ff       	call   800b54 <sys_page_alloc>
  800d58:	83 c4 10             	add    $0x10,%esp
  800d5b:	85 c0                	test   %eax,%eax
  800d5d:	79 12                	jns    800d71 <pgfault+0x6e>
		panic("sys_page_alloc: %e", r);
  800d5f:	50                   	push   %eax
  800d60:	68 b6 15 80 00       	push   $0x8015b6
  800d65:	6a 25                	push   $0x25
  800d67:	68 ab 15 80 00       	push   $0x8015ab
  800d6c:	e8 09 02 00 00       	call   800f7a <_panic>
	memmove((void *) PFTEMP, fault_va, PGSIZE);
  800d71:	83 ec 04             	sub    $0x4,%esp
  800d74:	68 00 10 00 00       	push   $0x1000
  800d79:	53                   	push   %ebx
  800d7a:	68 00 f0 7f 00       	push   $0x7ff000
  800d7f:	e8 5f fb ff ff       	call   8008e3 <memmove>
	if ((r = sys_page_map(0, (void *) PFTEMP, 0, fault_va, PTE_P|PTE_U|PTE_W)) < 0)
  800d84:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800d8b:	53                   	push   %ebx
  800d8c:	6a 00                	push   $0x0
  800d8e:	68 00 f0 7f 00       	push   $0x7ff000
  800d93:	6a 00                	push   $0x0
  800d95:	e8 fd fd ff ff       	call   800b97 <sys_page_map>
  800d9a:	83 c4 20             	add    $0x20,%esp
  800d9d:	85 c0                	test   %eax,%eax
  800d9f:	79 12                	jns    800db3 <pgfault+0xb0>
		panic("sys_page_map: %e", r);
  800da1:	50                   	push   %eax
  800da2:	68 c9 15 80 00       	push   $0x8015c9
  800da7:	6a 28                	push   $0x28
  800da9:	68 ab 15 80 00       	push   $0x8015ab
  800dae:	e8 c7 01 00 00       	call   800f7a <_panic>
	if ((r = sys_page_unmap(0, (void *) PFTEMP)) < 0)
  800db3:	83 ec 08             	sub    $0x8,%esp
  800db6:	68 00 f0 7f 00       	push   $0x7ff000
  800dbb:	6a 00                	push   $0x0
  800dbd:	e8 17 fe ff ff       	call   800bd9 <sys_page_unmap>
  800dc2:	83 c4 10             	add    $0x10,%esp
  800dc5:	85 c0                	test   %eax,%eax
  800dc7:	79 12                	jns    800ddb <pgfault+0xd8>
		panic("sys_page_unmap: %e", r);
  800dc9:	50                   	push   %eax
  800dca:	68 da 15 80 00       	push   $0x8015da
  800dcf:	6a 2a                	push   $0x2a
  800dd1:	68 ab 15 80 00       	push   $0x8015ab
  800dd6:	e8 9f 01 00 00       	call   800f7a <_panic>
}
  800ddb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dde:	c9                   	leave  
  800ddf:	c3                   	ret    

00800de0 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{	
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	57                   	push   %edi
  800de4:	56                   	push   %esi
  800de5:	53                   	push   %ebx
  800de6:	83 ec 28             	sub    $0x28,%esp
	envid_t envid;
	uint8_t *addr, *end_addr;
	int ret;

	set_pgfault_handler(&pgfault);
  800de9:	68 03 0d 80 00       	push   $0x800d03
  800dee:	e8 cd 01 00 00       	call   800fc0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800df3:	b8 07 00 00 00       	mov    $0x7,%eax
  800df8:	cd 30                	int    $0x30
  800dfa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	
	envid = sys_exofork();
	if (envid < 0) 
  800dfd:	83 c4 10             	add    $0x10,%esp
  800e00:	85 c0                	test   %eax,%eax
  800e02:	0f 88 ed 00 00 00    	js     800ef5 <fork+0x115>
  800e08:	89 c7                	mov    %eax,%edi
  800e0a:	bb 00 00 00 00       	mov    $0x0,%ebx
		return envid;
	if (envid == 0) {
  800e0f:	85 c0                	test   %eax,%eax
  800e11:	75 21                	jne    800e34 <fork+0x54>
		// We are the child
		thisenv = &envs[ENVX(sys_getenvid())];
  800e13:	e8 fe fc ff ff       	call   800b16 <sys_getenvid>
  800e18:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e1d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e20:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e25:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800e2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e2f:	e9 22 01 00 00       	jmp    800f56 <fork+0x176>
	}
	
	end_addr = (uint8_t *) (UXSTACKTOP - PGSIZE);
	for (addr = 0; addr < end_addr; addr += PGSIZE) {	
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
  800e34:	89 d8                	mov    %ebx,%eax
  800e36:	c1 e8 16             	shr    $0x16,%eax
  800e39:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e40:	a8 01                	test   $0x1,%al
  800e42:	74 51                	je     800e95 <fork+0xb5>
  800e44:	89 d8                	mov    %ebx,%eax
  800e46:	c1 e8 0c             	shr    $0xc,%eax
  800e49:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e50:	f6 c2 01             	test   $0x1,%dl
  800e53:	74 40                	je     800e95 <fork+0xb5>
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
	void *addr = (void *) (pn * PGSIZE);
  800e55:	89 c6                	mov    %eax,%esi
  800e57:	c1 e6 0c             	shl    $0xc,%esi
	uint32_t perm = PTE_U | PTE_P;
	int r;

	if (uvpt[pn] & (PTE_W | PTE_COW)) 
  800e5a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e61:	a9 02 08 00 00       	test   $0x802,%eax
  800e66:	0f 85 cc 00 00 00    	jne    800f38 <fork+0x158>
  800e6c:	e9 89 00 00 00       	jmp    800efa <fork+0x11a>
		perm |= PTE_COW;
	
	if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
		panic("sys_page_map: %e", r);
  800e71:	50                   	push   %eax
  800e72:	68 c9 15 80 00       	push   $0x8015c9
  800e77:	6a 43                	push   $0x43
  800e79:	68 ab 15 80 00       	push   $0x8015ab
  800e7e:	e8 f7 00 00 00       	call   800f7a <_panic>
	
	if (!(perm & PTE_COW))
		return 0;
	
	if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0)
		panic("sys_page_map: %e", r);
  800e83:	50                   	push   %eax
  800e84:	68 c9 15 80 00       	push   $0x8015c9
  800e89:	6a 49                	push   $0x49
  800e8b:	68 ab 15 80 00       	push   $0x8015ab
  800e90:	e8 e5 00 00 00       	call   800f7a <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	end_addr = (uint8_t *) (UXSTACKTOP - PGSIZE);
	for (addr = 0; addr < end_addr; addr += PGSIZE) {	
  800e95:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800e9b:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800ea1:	75 91                	jne    800e34 <fork+0x54>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
			duppage(envid, PGNUM(addr));
	}

	ret = sys_page_alloc(envid, 
  800ea3:	83 ec 04             	sub    $0x4,%esp
  800ea6:	6a 07                	push   $0x7
  800ea8:	68 00 f0 bf ee       	push   $0xeebff000
  800ead:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800eb0:	57                   	push   %edi
  800eb1:	e8 9e fc ff ff       	call   800b54 <sys_page_alloc>
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
  800eb6:	83 c4 10             	add    $0x10,%esp
		return ret;
  800eb9:	89 c2                	mov    %eax,%edx
			duppage(envid, PGNUM(addr));
	}

	ret = sys_page_alloc(envid, 
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
  800ebb:	85 c0                	test   %eax,%eax
  800ebd:	0f 88 93 00 00 00    	js     800f56 <fork+0x176>
		return ret;
		
	if ((ret = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  800ec3:	a1 04 20 80 00       	mov    0x802004,%eax
  800ec8:	8b 40 64             	mov    0x64(%eax),%eax
  800ecb:	83 ec 08             	sub    $0x8,%esp
  800ece:	50                   	push   %eax
  800ecf:	57                   	push   %edi
  800ed0:	e8 88 fd ff ff       	call   800c5d <sys_env_set_pgfault_upcall>
  800ed5:	83 c4 10             	add    $0x10,%esp
		return ret;
  800ed8:	89 c2                	mov    %eax,%edx
	ret = sys_page_alloc(envid, 
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
		return ret;
		
	if ((ret = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  800eda:	85 c0                	test   %eax,%eax
  800edc:	78 78                	js     800f56 <fork+0x176>
		return ret;
	
	if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800ede:	83 ec 08             	sub    $0x8,%esp
  800ee1:	6a 02                	push   $0x2
  800ee3:	57                   	push   %edi
  800ee4:	e8 32 fd ff ff       	call   800c1b <sys_env_set_status>
  800ee9:	83 c4 10             	add    $0x10,%esp
		return ret;

	return envid;
  800eec:	85 c0                	test   %eax,%eax
  800eee:	89 fa                	mov    %edi,%edx
  800ef0:	0f 48 d0             	cmovs  %eax,%edx
  800ef3:	eb 61                	jmp    800f56 <fork+0x176>

	set_pgfault_handler(&pgfault);
	
	envid = sys_exofork();
	if (envid < 0) 
		return envid;
  800ef5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800ef8:	eb 5c                	jmp    800f56 <fork+0x176>
	int r;

	if (uvpt[pn] & (PTE_W | PTE_COW)) 
		perm |= PTE_COW;
	
	if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800efa:	83 ec 0c             	sub    $0xc,%esp
  800efd:	6a 05                	push   $0x5
  800eff:	56                   	push   %esi
  800f00:	57                   	push   %edi
  800f01:	56                   	push   %esi
  800f02:	6a 00                	push   $0x0
  800f04:	e8 8e fc ff ff       	call   800b97 <sys_page_map>
  800f09:	83 c4 20             	add    $0x20,%esp
  800f0c:	85 c0                	test   %eax,%eax
  800f0e:	79 85                	jns    800e95 <fork+0xb5>
  800f10:	e9 5c ff ff ff       	jmp    800e71 <fork+0x91>
		panic("sys_page_map: %e", r);
	
	if (!(perm & PTE_COW))
		return 0;
	
	if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0)
  800f15:	83 ec 0c             	sub    $0xc,%esp
  800f18:	68 05 08 00 00       	push   $0x805
  800f1d:	56                   	push   %esi
  800f1e:	6a 00                	push   $0x0
  800f20:	56                   	push   %esi
  800f21:	6a 00                	push   $0x0
  800f23:	e8 6f fc ff ff       	call   800b97 <sys_page_map>
  800f28:	83 c4 20             	add    $0x20,%esp
  800f2b:	85 c0                	test   %eax,%eax
  800f2d:	0f 89 62 ff ff ff    	jns    800e95 <fork+0xb5>
  800f33:	e9 4b ff ff ff       	jmp    800e83 <fork+0xa3>
	int r;

	if (uvpt[pn] & (PTE_W | PTE_COW)) 
		perm |= PTE_COW;
	
	if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800f38:	83 ec 0c             	sub    $0xc,%esp
  800f3b:	68 05 08 00 00       	push   $0x805
  800f40:	56                   	push   %esi
  800f41:	57                   	push   %edi
  800f42:	56                   	push   %esi
  800f43:	6a 00                	push   $0x0
  800f45:	e8 4d fc ff ff       	call   800b97 <sys_page_map>
  800f4a:	83 c4 20             	add    $0x20,%esp
  800f4d:	85 c0                	test   %eax,%eax
  800f4f:	79 c4                	jns    800f15 <fork+0x135>
  800f51:	e9 1b ff ff ff       	jmp    800e71 <fork+0x91>
	
	if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
		return ret;

	return envid;
}
  800f56:	89 d0                	mov    %edx,%eax
  800f58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f5b:	5b                   	pop    %ebx
  800f5c:	5e                   	pop    %esi
  800f5d:	5f                   	pop    %edi
  800f5e:	5d                   	pop    %ebp
  800f5f:	c3                   	ret    

00800f60 <sfork>:

// Challenge!
int
sfork(void)
{
  800f60:	55                   	push   %ebp
  800f61:	89 e5                	mov    %esp,%ebp
  800f63:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800f66:	68 ed 15 80 00       	push   $0x8015ed
  800f6b:	68 88 00 00 00       	push   $0x88
  800f70:	68 ab 15 80 00       	push   $0x8015ab
  800f75:	e8 00 00 00 00       	call   800f7a <_panic>

00800f7a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f7a:	55                   	push   %ebp
  800f7b:	89 e5                	mov    %esp,%ebp
  800f7d:	56                   	push   %esi
  800f7e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800f7f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f82:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800f88:	e8 89 fb ff ff       	call   800b16 <sys_getenvid>
  800f8d:	83 ec 0c             	sub    $0xc,%esp
  800f90:	ff 75 0c             	pushl  0xc(%ebp)
  800f93:	ff 75 08             	pushl  0x8(%ebp)
  800f96:	56                   	push   %esi
  800f97:	50                   	push   %eax
  800f98:	68 04 16 80 00       	push   $0x801604
  800f9d:	e8 2a f2 ff ff       	call   8001cc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800fa2:	83 c4 18             	add    $0x18,%esp
  800fa5:	53                   	push   %ebx
  800fa6:	ff 75 10             	pushl  0x10(%ebp)
  800fa9:	e8 cd f1 ff ff       	call   80017b <vcprintf>
	cprintf("\n");
  800fae:	c7 04 24 0f 13 80 00 	movl   $0x80130f,(%esp)
  800fb5:	e8 12 f2 ff ff       	call   8001cc <cprintf>
  800fba:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800fbd:	cc                   	int3   
  800fbe:	eb fd                	jmp    800fbd <_panic+0x43>

00800fc0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800fc6:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800fcd:	75 52                	jne    801021 <set_pgfault_handler+0x61>
		// First time through!
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
  800fcf:	83 ec 04             	sub    $0x4,%esp
  800fd2:	6a 07                	push   $0x7
  800fd4:	68 00 f0 bf ee       	push   $0xeebff000
  800fd9:	6a 00                	push   $0x0
  800fdb:	e8 74 fb ff ff       	call   800b54 <sys_page_alloc>
		if (r < 0)
  800fe0:	83 c4 10             	add    $0x10,%esp
  800fe3:	85 c0                	test   %eax,%eax
  800fe5:	79 12                	jns    800ff9 <set_pgfault_handler+0x39>
			panic("sys_page_alloc: %e", r);
  800fe7:	50                   	push   %eax
  800fe8:	68 b6 15 80 00       	push   $0x8015b6
  800fed:	6a 21                	push   $0x21
  800fef:	68 27 16 80 00       	push   $0x801627
  800ff4:	e8 81 ff ff ff       	call   800f7a <_panic>
		if ((r = sys_env_set_pgfault_upcall(0, _pgfault_upcall)) < 0)
  800ff9:	83 ec 08             	sub    $0x8,%esp
  800ffc:	68 2b 10 80 00       	push   $0x80102b
  801001:	6a 00                	push   $0x0
  801003:	e8 55 fc ff ff       	call   800c5d <sys_env_set_pgfault_upcall>
  801008:	83 c4 10             	add    $0x10,%esp
  80100b:	85 c0                	test   %eax,%eax
  80100d:	79 12                	jns    801021 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall: %e", r);
  80100f:	50                   	push   %eax
  801010:	68 38 16 80 00       	push   $0x801638
  801015:	6a 23                	push   $0x23
  801017:	68 27 16 80 00       	push   $0x801627
  80101c:	e8 59 ff ff ff       	call   800f7a <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801021:	8b 45 08             	mov    0x8(%ebp),%eax
  801024:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801029:	c9                   	leave  
  80102a:	c3                   	ret    

0080102b <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80102b:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80102c:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801031:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801033:	83 c4 04             	add    $0x4,%esp
	// Throughout the remaining code, think carefully about what
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	movl 48(%esp), %eax
  801036:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  80103a:	83 e8 04             	sub    $0x4,%eax
	movl 40(%esp), %edx
  80103d:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  801041:	89 10                	mov    %edx,(%eax)
	movl %eax, 48(%esp)
  801043:	89 44 24 30          	mov    %eax,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	addl $8, %esp
  801047:	83 c4 08             	add    $0x8,%esp
	popal
  80104a:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	addl $4, %esp
  80104b:	83 c4 04             	add    $0x4,%esp
	popfl
  80104e:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	popl %esp
  80104f:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	ret
  801050:	c3                   	ret    
  801051:	66 90                	xchg   %ax,%ax
  801053:	66 90                	xchg   %ax,%ax
  801055:	66 90                	xchg   %ax,%ax
  801057:	66 90                	xchg   %ax,%ax
  801059:	66 90                	xchg   %ax,%ax
  80105b:	66 90                	xchg   %ax,%ax
  80105d:	66 90                	xchg   %ax,%ax
  80105f:	90                   	nop

00801060 <__udivdi3>:
  801060:	55                   	push   %ebp
  801061:	57                   	push   %edi
  801062:	56                   	push   %esi
  801063:	53                   	push   %ebx
  801064:	83 ec 1c             	sub    $0x1c,%esp
  801067:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80106b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80106f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801073:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801077:	85 f6                	test   %esi,%esi
  801079:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80107d:	89 ca                	mov    %ecx,%edx
  80107f:	89 f8                	mov    %edi,%eax
  801081:	75 3d                	jne    8010c0 <__udivdi3+0x60>
  801083:	39 cf                	cmp    %ecx,%edi
  801085:	0f 87 c5 00 00 00    	ja     801150 <__udivdi3+0xf0>
  80108b:	85 ff                	test   %edi,%edi
  80108d:	89 fd                	mov    %edi,%ebp
  80108f:	75 0b                	jne    80109c <__udivdi3+0x3c>
  801091:	b8 01 00 00 00       	mov    $0x1,%eax
  801096:	31 d2                	xor    %edx,%edx
  801098:	f7 f7                	div    %edi
  80109a:	89 c5                	mov    %eax,%ebp
  80109c:	89 c8                	mov    %ecx,%eax
  80109e:	31 d2                	xor    %edx,%edx
  8010a0:	f7 f5                	div    %ebp
  8010a2:	89 c1                	mov    %eax,%ecx
  8010a4:	89 d8                	mov    %ebx,%eax
  8010a6:	89 cf                	mov    %ecx,%edi
  8010a8:	f7 f5                	div    %ebp
  8010aa:	89 c3                	mov    %eax,%ebx
  8010ac:	89 d8                	mov    %ebx,%eax
  8010ae:	89 fa                	mov    %edi,%edx
  8010b0:	83 c4 1c             	add    $0x1c,%esp
  8010b3:	5b                   	pop    %ebx
  8010b4:	5e                   	pop    %esi
  8010b5:	5f                   	pop    %edi
  8010b6:	5d                   	pop    %ebp
  8010b7:	c3                   	ret    
  8010b8:	90                   	nop
  8010b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010c0:	39 ce                	cmp    %ecx,%esi
  8010c2:	77 74                	ja     801138 <__udivdi3+0xd8>
  8010c4:	0f bd fe             	bsr    %esi,%edi
  8010c7:	83 f7 1f             	xor    $0x1f,%edi
  8010ca:	0f 84 98 00 00 00    	je     801168 <__udivdi3+0x108>
  8010d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8010d5:	89 f9                	mov    %edi,%ecx
  8010d7:	89 c5                	mov    %eax,%ebp
  8010d9:	29 fb                	sub    %edi,%ebx
  8010db:	d3 e6                	shl    %cl,%esi
  8010dd:	89 d9                	mov    %ebx,%ecx
  8010df:	d3 ed                	shr    %cl,%ebp
  8010e1:	89 f9                	mov    %edi,%ecx
  8010e3:	d3 e0                	shl    %cl,%eax
  8010e5:	09 ee                	or     %ebp,%esi
  8010e7:	89 d9                	mov    %ebx,%ecx
  8010e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010ed:	89 d5                	mov    %edx,%ebp
  8010ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8010f3:	d3 ed                	shr    %cl,%ebp
  8010f5:	89 f9                	mov    %edi,%ecx
  8010f7:	d3 e2                	shl    %cl,%edx
  8010f9:	89 d9                	mov    %ebx,%ecx
  8010fb:	d3 e8                	shr    %cl,%eax
  8010fd:	09 c2                	or     %eax,%edx
  8010ff:	89 d0                	mov    %edx,%eax
  801101:	89 ea                	mov    %ebp,%edx
  801103:	f7 f6                	div    %esi
  801105:	89 d5                	mov    %edx,%ebp
  801107:	89 c3                	mov    %eax,%ebx
  801109:	f7 64 24 0c          	mull   0xc(%esp)
  80110d:	39 d5                	cmp    %edx,%ebp
  80110f:	72 10                	jb     801121 <__udivdi3+0xc1>
  801111:	8b 74 24 08          	mov    0x8(%esp),%esi
  801115:	89 f9                	mov    %edi,%ecx
  801117:	d3 e6                	shl    %cl,%esi
  801119:	39 c6                	cmp    %eax,%esi
  80111b:	73 07                	jae    801124 <__udivdi3+0xc4>
  80111d:	39 d5                	cmp    %edx,%ebp
  80111f:	75 03                	jne    801124 <__udivdi3+0xc4>
  801121:	83 eb 01             	sub    $0x1,%ebx
  801124:	31 ff                	xor    %edi,%edi
  801126:	89 d8                	mov    %ebx,%eax
  801128:	89 fa                	mov    %edi,%edx
  80112a:	83 c4 1c             	add    $0x1c,%esp
  80112d:	5b                   	pop    %ebx
  80112e:	5e                   	pop    %esi
  80112f:	5f                   	pop    %edi
  801130:	5d                   	pop    %ebp
  801131:	c3                   	ret    
  801132:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801138:	31 ff                	xor    %edi,%edi
  80113a:	31 db                	xor    %ebx,%ebx
  80113c:	89 d8                	mov    %ebx,%eax
  80113e:	89 fa                	mov    %edi,%edx
  801140:	83 c4 1c             	add    $0x1c,%esp
  801143:	5b                   	pop    %ebx
  801144:	5e                   	pop    %esi
  801145:	5f                   	pop    %edi
  801146:	5d                   	pop    %ebp
  801147:	c3                   	ret    
  801148:	90                   	nop
  801149:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801150:	89 d8                	mov    %ebx,%eax
  801152:	f7 f7                	div    %edi
  801154:	31 ff                	xor    %edi,%edi
  801156:	89 c3                	mov    %eax,%ebx
  801158:	89 d8                	mov    %ebx,%eax
  80115a:	89 fa                	mov    %edi,%edx
  80115c:	83 c4 1c             	add    $0x1c,%esp
  80115f:	5b                   	pop    %ebx
  801160:	5e                   	pop    %esi
  801161:	5f                   	pop    %edi
  801162:	5d                   	pop    %ebp
  801163:	c3                   	ret    
  801164:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801168:	39 ce                	cmp    %ecx,%esi
  80116a:	72 0c                	jb     801178 <__udivdi3+0x118>
  80116c:	31 db                	xor    %ebx,%ebx
  80116e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801172:	0f 87 34 ff ff ff    	ja     8010ac <__udivdi3+0x4c>
  801178:	bb 01 00 00 00       	mov    $0x1,%ebx
  80117d:	e9 2a ff ff ff       	jmp    8010ac <__udivdi3+0x4c>
  801182:	66 90                	xchg   %ax,%ax
  801184:	66 90                	xchg   %ax,%ax
  801186:	66 90                	xchg   %ax,%ax
  801188:	66 90                	xchg   %ax,%ax
  80118a:	66 90                	xchg   %ax,%ax
  80118c:	66 90                	xchg   %ax,%ax
  80118e:	66 90                	xchg   %ax,%ax

00801190 <__umoddi3>:
  801190:	55                   	push   %ebp
  801191:	57                   	push   %edi
  801192:	56                   	push   %esi
  801193:	53                   	push   %ebx
  801194:	83 ec 1c             	sub    $0x1c,%esp
  801197:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80119b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80119f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8011a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8011a7:	85 d2                	test   %edx,%edx
  8011a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8011ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011b1:	89 f3                	mov    %esi,%ebx
  8011b3:	89 3c 24             	mov    %edi,(%esp)
  8011b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011ba:	75 1c                	jne    8011d8 <__umoddi3+0x48>
  8011bc:	39 f7                	cmp    %esi,%edi
  8011be:	76 50                	jbe    801210 <__umoddi3+0x80>
  8011c0:	89 c8                	mov    %ecx,%eax
  8011c2:	89 f2                	mov    %esi,%edx
  8011c4:	f7 f7                	div    %edi
  8011c6:	89 d0                	mov    %edx,%eax
  8011c8:	31 d2                	xor    %edx,%edx
  8011ca:	83 c4 1c             	add    $0x1c,%esp
  8011cd:	5b                   	pop    %ebx
  8011ce:	5e                   	pop    %esi
  8011cf:	5f                   	pop    %edi
  8011d0:	5d                   	pop    %ebp
  8011d1:	c3                   	ret    
  8011d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011d8:	39 f2                	cmp    %esi,%edx
  8011da:	89 d0                	mov    %edx,%eax
  8011dc:	77 52                	ja     801230 <__umoddi3+0xa0>
  8011de:	0f bd ea             	bsr    %edx,%ebp
  8011e1:	83 f5 1f             	xor    $0x1f,%ebp
  8011e4:	75 5a                	jne    801240 <__umoddi3+0xb0>
  8011e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8011ea:	0f 82 e0 00 00 00    	jb     8012d0 <__umoddi3+0x140>
  8011f0:	39 0c 24             	cmp    %ecx,(%esp)
  8011f3:	0f 86 d7 00 00 00    	jbe    8012d0 <__umoddi3+0x140>
  8011f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8011fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801201:	83 c4 1c             	add    $0x1c,%esp
  801204:	5b                   	pop    %ebx
  801205:	5e                   	pop    %esi
  801206:	5f                   	pop    %edi
  801207:	5d                   	pop    %ebp
  801208:	c3                   	ret    
  801209:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801210:	85 ff                	test   %edi,%edi
  801212:	89 fd                	mov    %edi,%ebp
  801214:	75 0b                	jne    801221 <__umoddi3+0x91>
  801216:	b8 01 00 00 00       	mov    $0x1,%eax
  80121b:	31 d2                	xor    %edx,%edx
  80121d:	f7 f7                	div    %edi
  80121f:	89 c5                	mov    %eax,%ebp
  801221:	89 f0                	mov    %esi,%eax
  801223:	31 d2                	xor    %edx,%edx
  801225:	f7 f5                	div    %ebp
  801227:	89 c8                	mov    %ecx,%eax
  801229:	f7 f5                	div    %ebp
  80122b:	89 d0                	mov    %edx,%eax
  80122d:	eb 99                	jmp    8011c8 <__umoddi3+0x38>
  80122f:	90                   	nop
  801230:	89 c8                	mov    %ecx,%eax
  801232:	89 f2                	mov    %esi,%edx
  801234:	83 c4 1c             	add    $0x1c,%esp
  801237:	5b                   	pop    %ebx
  801238:	5e                   	pop    %esi
  801239:	5f                   	pop    %edi
  80123a:	5d                   	pop    %ebp
  80123b:	c3                   	ret    
  80123c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801240:	8b 34 24             	mov    (%esp),%esi
  801243:	bf 20 00 00 00       	mov    $0x20,%edi
  801248:	89 e9                	mov    %ebp,%ecx
  80124a:	29 ef                	sub    %ebp,%edi
  80124c:	d3 e0                	shl    %cl,%eax
  80124e:	89 f9                	mov    %edi,%ecx
  801250:	89 f2                	mov    %esi,%edx
  801252:	d3 ea                	shr    %cl,%edx
  801254:	89 e9                	mov    %ebp,%ecx
  801256:	09 c2                	or     %eax,%edx
  801258:	89 d8                	mov    %ebx,%eax
  80125a:	89 14 24             	mov    %edx,(%esp)
  80125d:	89 f2                	mov    %esi,%edx
  80125f:	d3 e2                	shl    %cl,%edx
  801261:	89 f9                	mov    %edi,%ecx
  801263:	89 54 24 04          	mov    %edx,0x4(%esp)
  801267:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80126b:	d3 e8                	shr    %cl,%eax
  80126d:	89 e9                	mov    %ebp,%ecx
  80126f:	89 c6                	mov    %eax,%esi
  801271:	d3 e3                	shl    %cl,%ebx
  801273:	89 f9                	mov    %edi,%ecx
  801275:	89 d0                	mov    %edx,%eax
  801277:	d3 e8                	shr    %cl,%eax
  801279:	89 e9                	mov    %ebp,%ecx
  80127b:	09 d8                	or     %ebx,%eax
  80127d:	89 d3                	mov    %edx,%ebx
  80127f:	89 f2                	mov    %esi,%edx
  801281:	f7 34 24             	divl   (%esp)
  801284:	89 d6                	mov    %edx,%esi
  801286:	d3 e3                	shl    %cl,%ebx
  801288:	f7 64 24 04          	mull   0x4(%esp)
  80128c:	39 d6                	cmp    %edx,%esi
  80128e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801292:	89 d1                	mov    %edx,%ecx
  801294:	89 c3                	mov    %eax,%ebx
  801296:	72 08                	jb     8012a0 <__umoddi3+0x110>
  801298:	75 11                	jne    8012ab <__umoddi3+0x11b>
  80129a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80129e:	73 0b                	jae    8012ab <__umoddi3+0x11b>
  8012a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8012a4:	1b 14 24             	sbb    (%esp),%edx
  8012a7:	89 d1                	mov    %edx,%ecx
  8012a9:	89 c3                	mov    %eax,%ebx
  8012ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8012af:	29 da                	sub    %ebx,%edx
  8012b1:	19 ce                	sbb    %ecx,%esi
  8012b3:	89 f9                	mov    %edi,%ecx
  8012b5:	89 f0                	mov    %esi,%eax
  8012b7:	d3 e0                	shl    %cl,%eax
  8012b9:	89 e9                	mov    %ebp,%ecx
  8012bb:	d3 ea                	shr    %cl,%edx
  8012bd:	89 e9                	mov    %ebp,%ecx
  8012bf:	d3 ee                	shr    %cl,%esi
  8012c1:	09 d0                	or     %edx,%eax
  8012c3:	89 f2                	mov    %esi,%edx
  8012c5:	83 c4 1c             	add    $0x1c,%esp
  8012c8:	5b                   	pop    %ebx
  8012c9:	5e                   	pop    %esi
  8012ca:	5f                   	pop    %edi
  8012cb:	5d                   	pop    %ebp
  8012cc:	c3                   	ret    
  8012cd:	8d 76 00             	lea    0x0(%esi),%esi
  8012d0:	29 f9                	sub    %edi,%ecx
  8012d2:	19 d6                	sbb    %edx,%esi
  8012d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012dc:	e9 18 ff ff ff       	jmp    8011f9 <__umoddi3+0x69>
