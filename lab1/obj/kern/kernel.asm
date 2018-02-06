
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 00 11 00       	mov    $0x110000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 58 00 00 00       	call   f0100096 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:

// Test the stack backtrace function (lab 1 only)
extern const char __STABSTR_BEGIN__[];      // Beginning of string
extern const char __STABSTR_END__[];        // End of string table
int test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 0c             	sub    $0xc,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	53                   	push   %ebx
f010004b:	68 00 19 10 f0       	push   $0xf0101900
f0100050:	e8 57 09 00 00       	call   f01009ac <cprintf>
	if (x > 0)
f0100055:	83 c4 10             	add    $0x10,%esp
f0100058:	85 db                	test   %ebx,%ebx
f010005a:	7e 11                	jle    f010006d <test_backtrace+0x2d>
		test_backtrace(x-1);
f010005c:	83 ec 0c             	sub    $0xc,%esp
f010005f:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100062:	50                   	push   %eax
f0100063:	e8 d8 ff ff ff       	call   f0100040 <test_backtrace>
f0100068:	83 c4 10             	add    $0x10,%esp
f010006b:	eb 11                	jmp    f010007e <test_backtrace+0x3e>
	else
		backtrace(0, 0, 0);
f010006d:	83 ec 04             	sub    $0x4,%esp
f0100070:	6a 00                	push   $0x0
f0100072:	6a 00                	push   $0x0
f0100074:	6a 00                	push   $0x0
f0100076:	e8 21 07 00 00       	call   f010079c <backtrace>
f010007b:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007e:	83 ec 08             	sub    $0x8,%esp
f0100081:	53                   	push   %ebx
f0100082:	68 1c 19 10 f0       	push   $0xf010191c
f0100087:	e8 20 09 00 00       	call   f01009ac <cprintf>
    return 0;
}
f010008c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100091:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100094:	c9                   	leave  
f0100095:	c3                   	ret    

f0100096 <i386_init>:

void
i386_init(void)
{
f0100096:	55                   	push   %ebp
f0100097:	89 e5                	mov    %esp,%ebp
f0100099:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f010009c:	b8 44 29 11 f0       	mov    $0xf0112944,%eax
f01000a1:	2d 00 23 11 f0       	sub    $0xf0112300,%eax
f01000a6:	50                   	push   %eax
f01000a7:	6a 00                	push   $0x0
f01000a9:	68 00 23 11 f0       	push   $0xf0112300
f01000ae:	e8 b3 13 00 00       	call   f0101466 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b3:	e8 b2 04 00 00       	call   f010056a <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b8:	83 c4 08             	add    $0x8,%esp
f01000bb:	68 ac 1a 00 00       	push   $0x1aac
f01000c0:	68 37 19 10 f0       	push   $0xf0101937
f01000c5:	e8 e2 08 00 00       	call   f01009ac <cprintf>
    cprintf("Welcome to %Cc%Ccaomaer's minimal OS\n",0,67,1,104);
f01000ca:	c7 04 24 68 00 00 00 	movl   $0x68,(%esp)
f01000d1:	6a 01                	push   $0x1
f01000d3:	6a 43                	push   $0x43
f01000d5:	6a 00                	push   $0x0
f01000d7:	68 84 19 10 f0       	push   $0xf0101984
f01000dc:	e8 cb 08 00 00       	call   f01009ac <cprintf>
	// Test the stack backtrace function (lab 1 only)
    test_backtrace(5);
f01000e1:	83 c4 14             	add    $0x14,%esp
f01000e4:	6a 05                	push   $0x5
f01000e6:	e8 55 ff ff ff       	call   f0100040 <test_backtrace>
f01000eb:	83 c4 10             	add    $0x10,%esp
	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000ee:	83 ec 0c             	sub    $0xc,%esp
f01000f1:	6a 00                	push   $0x0
f01000f3:	e8 47 07 00 00       	call   f010083f <monitor>
f01000f8:	83 c4 10             	add    $0x10,%esp
f01000fb:	eb f1                	jmp    f01000ee <i386_init+0x58>

f01000fd <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000fd:	55                   	push   %ebp
f01000fe:	89 e5                	mov    %esp,%ebp
f0100100:	56                   	push   %esi
f0100101:	53                   	push   %ebx
f0100102:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100105:	83 3d 40 29 11 f0 00 	cmpl   $0x0,0xf0112940
f010010c:	75 37                	jne    f0100145 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f010010e:	89 35 40 29 11 f0    	mov    %esi,0xf0112940

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f0100114:	fa                   	cli    
f0100115:	fc                   	cld    

	va_start(ap, fmt);
f0100116:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100119:	83 ec 04             	sub    $0x4,%esp
f010011c:	ff 75 0c             	pushl  0xc(%ebp)
f010011f:	ff 75 08             	pushl  0x8(%ebp)
f0100122:	68 52 19 10 f0       	push   $0xf0101952
f0100127:	e8 80 08 00 00       	call   f01009ac <cprintf>
	vcprintf(fmt, ap);
f010012c:	83 c4 08             	add    $0x8,%esp
f010012f:	53                   	push   %ebx
f0100130:	56                   	push   %esi
f0100131:	e8 50 08 00 00       	call   f0100986 <vcprintf>
	cprintf("\n");
f0100136:	c7 04 24 b4 19 10 f0 	movl   $0xf01019b4,(%esp)
f010013d:	e8 6a 08 00 00       	call   f01009ac <cprintf>
	va_end(ap);
f0100142:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100145:	83 ec 0c             	sub    $0xc,%esp
f0100148:	6a 00                	push   $0x0
f010014a:	e8 f0 06 00 00       	call   f010083f <monitor>
f010014f:	83 c4 10             	add    $0x10,%esp
f0100152:	eb f1                	jmp    f0100145 <_panic+0x48>

f0100154 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100154:	55                   	push   %ebp
f0100155:	89 e5                	mov    %esp,%ebp
f0100157:	53                   	push   %ebx
f0100158:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010015b:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010015e:	ff 75 0c             	pushl  0xc(%ebp)
f0100161:	ff 75 08             	pushl  0x8(%ebp)
f0100164:	68 6a 19 10 f0       	push   $0xf010196a
f0100169:	e8 3e 08 00 00       	call   f01009ac <cprintf>
	vcprintf(fmt, ap);
f010016e:	83 c4 08             	add    $0x8,%esp
f0100171:	53                   	push   %ebx
f0100172:	ff 75 10             	pushl  0x10(%ebp)
f0100175:	e8 0c 08 00 00       	call   f0100986 <vcprintf>
	cprintf("\n");
f010017a:	c7 04 24 b4 19 10 f0 	movl   $0xf01019b4,(%esp)
f0100181:	e8 26 08 00 00       	call   f01009ac <cprintf>
	va_end(ap);
}
f0100186:	83 c4 10             	add    $0x10,%esp
f0100189:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010018c:	c9                   	leave  
f010018d:	c3                   	ret    

f010018e <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010018e:	55                   	push   %ebp
f010018f:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100191:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100196:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100197:	a8 01                	test   $0x1,%al
f0100199:	74 0b                	je     f01001a6 <serial_proc_data+0x18>
f010019b:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001a0:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001a1:	0f b6 c0             	movzbl %al,%eax
f01001a4:	eb 05                	jmp    f01001ab <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01001a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01001ab:	5d                   	pop    %ebp
f01001ac:	c3                   	ret    

f01001ad <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001ad:	55                   	push   %ebp
f01001ae:	89 e5                	mov    %esp,%ebp
f01001b0:	53                   	push   %ebx
f01001b1:	83 ec 04             	sub    $0x4,%esp
f01001b4:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01001b6:	eb 2b                	jmp    f01001e3 <cons_intr+0x36>
		if (c == 0)
f01001b8:	85 c0                	test   %eax,%eax
f01001ba:	74 27                	je     f01001e3 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01001bc:	8b 0d 24 25 11 f0    	mov    0xf0112524,%ecx
f01001c2:	8d 51 01             	lea    0x1(%ecx),%edx
f01001c5:	89 15 24 25 11 f0    	mov    %edx,0xf0112524
f01001cb:	88 81 20 23 11 f0    	mov    %al,-0xfeedce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01001d1:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001d7:	75 0a                	jne    f01001e3 <cons_intr+0x36>
			cons.wpos = 0;
f01001d9:	c7 05 24 25 11 f0 00 	movl   $0x0,0xf0112524
f01001e0:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001e3:	ff d3                	call   *%ebx
f01001e5:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001e8:	75 ce                	jne    f01001b8 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001ea:	83 c4 04             	add    $0x4,%esp
f01001ed:	5b                   	pop    %ebx
f01001ee:	5d                   	pop    %ebp
f01001ef:	c3                   	ret    

f01001f0 <kbd_proc_data>:
f01001f0:	ba 64 00 00 00       	mov    $0x64,%edx
f01001f5:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f01001f6:	a8 01                	test   $0x1,%al
f01001f8:	0f 84 f8 00 00 00    	je     f01002f6 <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01001fe:	a8 20                	test   $0x20,%al
f0100200:	0f 85 f6 00 00 00    	jne    f01002fc <kbd_proc_data+0x10c>
f0100206:	ba 60 00 00 00       	mov    $0x60,%edx
f010020b:	ec                   	in     (%dx),%al
f010020c:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010020e:	3c e0                	cmp    $0xe0,%al
f0100210:	75 0d                	jne    f010021f <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f0100212:	83 0d 00 23 11 f0 40 	orl    $0x40,0xf0112300
		return 0;
f0100219:	b8 00 00 00 00       	mov    $0x0,%eax
f010021e:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010021f:	55                   	push   %ebp
f0100220:	89 e5                	mov    %esp,%ebp
f0100222:	53                   	push   %ebx
f0100223:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f0100226:	84 c0                	test   %al,%al
f0100228:	79 36                	jns    f0100260 <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010022a:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f0100230:	89 cb                	mov    %ecx,%ebx
f0100232:	83 e3 40             	and    $0x40,%ebx
f0100235:	83 e0 7f             	and    $0x7f,%eax
f0100238:	85 db                	test   %ebx,%ebx
f010023a:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010023d:	0f b6 d2             	movzbl %dl,%edx
f0100240:	0f b6 82 00 1b 10 f0 	movzbl -0xfefe500(%edx),%eax
f0100247:	83 c8 40             	or     $0x40,%eax
f010024a:	0f b6 c0             	movzbl %al,%eax
f010024d:	f7 d0                	not    %eax
f010024f:	21 c8                	and    %ecx,%eax
f0100251:	a3 00 23 11 f0       	mov    %eax,0xf0112300
		return 0;
f0100256:	b8 00 00 00 00       	mov    $0x0,%eax
f010025b:	e9 a4 00 00 00       	jmp    f0100304 <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f0100260:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f0100266:	f6 c1 40             	test   $0x40,%cl
f0100269:	74 0e                	je     f0100279 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010026b:	83 c8 80             	or     $0xffffff80,%eax
f010026e:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100270:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100273:	89 0d 00 23 11 f0    	mov    %ecx,0xf0112300
	}

	shift |= shiftcode[data];
f0100279:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f010027c:	0f b6 82 00 1b 10 f0 	movzbl -0xfefe500(%edx),%eax
f0100283:	0b 05 00 23 11 f0    	or     0xf0112300,%eax
f0100289:	0f b6 8a 00 1a 10 f0 	movzbl -0xfefe600(%edx),%ecx
f0100290:	31 c8                	xor    %ecx,%eax
f0100292:	a3 00 23 11 f0       	mov    %eax,0xf0112300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100297:	89 c1                	mov    %eax,%ecx
f0100299:	83 e1 03             	and    $0x3,%ecx
f010029c:	8b 0c 8d e0 19 10 f0 	mov    -0xfefe620(,%ecx,4),%ecx
f01002a3:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002a7:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01002aa:	a8 08                	test   $0x8,%al
f01002ac:	74 1b                	je     f01002c9 <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f01002ae:	89 da                	mov    %ebx,%edx
f01002b0:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01002b3:	83 f9 19             	cmp    $0x19,%ecx
f01002b6:	77 05                	ja     f01002bd <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f01002b8:	83 eb 20             	sub    $0x20,%ebx
f01002bb:	eb 0c                	jmp    f01002c9 <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f01002bd:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002c0:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01002c3:	83 fa 19             	cmp    $0x19,%edx
f01002c6:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002c9:	f7 d0                	not    %eax
f01002cb:	a8 06                	test   $0x6,%al
f01002cd:	75 33                	jne    f0100302 <kbd_proc_data+0x112>
f01002cf:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002d5:	75 2b                	jne    f0100302 <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f01002d7:	83 ec 0c             	sub    $0xc,%esp
f01002da:	68 aa 19 10 f0       	push   $0xf01019aa
f01002df:	e8 c8 06 00 00       	call   f01009ac <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002e4:	ba 92 00 00 00       	mov    $0x92,%edx
f01002e9:	b8 03 00 00 00       	mov    $0x3,%eax
f01002ee:	ee                   	out    %al,(%dx)
f01002ef:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002f2:	89 d8                	mov    %ebx,%eax
f01002f4:	eb 0e                	jmp    f0100304 <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f01002f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01002fb:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01002fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100301:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100302:	89 d8                	mov    %ebx,%eax
}
f0100304:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100307:	c9                   	leave  
f0100308:	c3                   	ret    

f0100309 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100309:	55                   	push   %ebp
f010030a:	89 e5                	mov    %esp,%ebp
f010030c:	57                   	push   %edi
f010030d:	56                   	push   %esi
f010030e:	53                   	push   %ebx
f010030f:	83 ec 1c             	sub    $0x1c,%esp
f0100312:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100314:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100319:	be fd 03 00 00       	mov    $0x3fd,%esi
f010031e:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100323:	eb 09                	jmp    f010032e <cons_putc+0x25>
f0100325:	89 ca                	mov    %ecx,%edx
f0100327:	ec                   	in     (%dx),%al
f0100328:	ec                   	in     (%dx),%al
f0100329:	ec                   	in     (%dx),%al
f010032a:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f010032b:	83 c3 01             	add    $0x1,%ebx
f010032e:	89 f2                	mov    %esi,%edx
f0100330:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100331:	a8 20                	test   $0x20,%al
f0100333:	75 08                	jne    f010033d <cons_putc+0x34>
f0100335:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010033b:	7e e8                	jle    f0100325 <cons_putc+0x1c>
f010033d:	89 f8                	mov    %edi,%eax
f010033f:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100342:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100347:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100348:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010034d:	be 79 03 00 00       	mov    $0x379,%esi
f0100352:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100357:	eb 09                	jmp    f0100362 <cons_putc+0x59>
f0100359:	89 ca                	mov    %ecx,%edx
f010035b:	ec                   	in     (%dx),%al
f010035c:	ec                   	in     (%dx),%al
f010035d:	ec                   	in     (%dx),%al
f010035e:	ec                   	in     (%dx),%al
f010035f:	83 c3 01             	add    $0x1,%ebx
f0100362:	89 f2                	mov    %esi,%edx
f0100364:	ec                   	in     (%dx),%al
f0100365:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010036b:	7f 04                	jg     f0100371 <cons_putc+0x68>
f010036d:	84 c0                	test   %al,%al
f010036f:	79 e8                	jns    f0100359 <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100371:	ba 78 03 00 00       	mov    $0x378,%edx
f0100376:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010037a:	ee                   	out    %al,(%dx)
f010037b:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100380:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100385:	ee                   	out    %al,(%dx)
f0100386:	b8 08 00 00 00       	mov    $0x8,%eax
f010038b:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010038c:	89 fa                	mov    %edi,%edx
f010038e:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100394:	89 f8                	mov    %edi,%eax
f0100396:	80 cc 07             	or     $0x7,%ah
f0100399:	85 d2                	test   %edx,%edx
f010039b:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f010039e:	89 f8                	mov    %edi,%eax
f01003a0:	0f b6 c0             	movzbl %al,%eax
f01003a3:	83 f8 09             	cmp    $0x9,%eax
f01003a6:	74 74                	je     f010041c <cons_putc+0x113>
f01003a8:	83 f8 09             	cmp    $0x9,%eax
f01003ab:	7f 0a                	jg     f01003b7 <cons_putc+0xae>
f01003ad:	83 f8 08             	cmp    $0x8,%eax
f01003b0:	74 14                	je     f01003c6 <cons_putc+0xbd>
f01003b2:	e9 99 00 00 00       	jmp    f0100450 <cons_putc+0x147>
f01003b7:	83 f8 0a             	cmp    $0xa,%eax
f01003ba:	74 3a                	je     f01003f6 <cons_putc+0xed>
f01003bc:	83 f8 0d             	cmp    $0xd,%eax
f01003bf:	74 3d                	je     f01003fe <cons_putc+0xf5>
f01003c1:	e9 8a 00 00 00       	jmp    f0100450 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f01003c6:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f01003cd:	66 85 c0             	test   %ax,%ax
f01003d0:	0f 84 e6 00 00 00    	je     f01004bc <cons_putc+0x1b3>
			crt_pos--;
f01003d6:	83 e8 01             	sub    $0x1,%eax
f01003d9:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003df:	0f b7 c0             	movzwl %ax,%eax
f01003e2:	66 81 e7 00 ff       	and    $0xff00,%di
f01003e7:	83 cf 20             	or     $0x20,%edi
f01003ea:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f01003f0:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003f4:	eb 78                	jmp    f010046e <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003f6:	66 83 05 28 25 11 f0 	addw   $0x50,0xf0112528
f01003fd:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003fe:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f0100405:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010040b:	c1 e8 16             	shr    $0x16,%eax
f010040e:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100411:	c1 e0 04             	shl    $0x4,%eax
f0100414:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
f010041a:	eb 52                	jmp    f010046e <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f010041c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100421:	e8 e3 fe ff ff       	call   f0100309 <cons_putc>
		cons_putc(' ');
f0100426:	b8 20 00 00 00       	mov    $0x20,%eax
f010042b:	e8 d9 fe ff ff       	call   f0100309 <cons_putc>
		cons_putc(' ');
f0100430:	b8 20 00 00 00       	mov    $0x20,%eax
f0100435:	e8 cf fe ff ff       	call   f0100309 <cons_putc>
		cons_putc(' ');
f010043a:	b8 20 00 00 00       	mov    $0x20,%eax
f010043f:	e8 c5 fe ff ff       	call   f0100309 <cons_putc>
		cons_putc(' ');
f0100444:	b8 20 00 00 00       	mov    $0x20,%eax
f0100449:	e8 bb fe ff ff       	call   f0100309 <cons_putc>
f010044e:	eb 1e                	jmp    f010046e <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100450:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f0100457:	8d 50 01             	lea    0x1(%eax),%edx
f010045a:	66 89 15 28 25 11 f0 	mov    %dx,0xf0112528
f0100461:	0f b7 c0             	movzwl %ax,%eax
f0100464:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f010046a:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010046e:	66 81 3d 28 25 11 f0 	cmpw   $0x7cf,0xf0112528
f0100475:	cf 07 
f0100477:	76 43                	jbe    f01004bc <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100479:	a1 2c 25 11 f0       	mov    0xf011252c,%eax
f010047e:	83 ec 04             	sub    $0x4,%esp
f0100481:	68 00 0f 00 00       	push   $0xf00
f0100486:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010048c:	52                   	push   %edx
f010048d:	50                   	push   %eax
f010048e:	e8 20 10 00 00       	call   f01014b3 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100493:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100499:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010049f:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01004a5:	83 c4 10             	add    $0x10,%esp
f01004a8:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01004ad:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004b0:	39 d0                	cmp    %edx,%eax
f01004b2:	75 f4                	jne    f01004a8 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01004b4:	66 83 2d 28 25 11 f0 	subw   $0x50,0xf0112528
f01004bb:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004bc:	8b 0d 30 25 11 f0    	mov    0xf0112530,%ecx
f01004c2:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004c7:	89 ca                	mov    %ecx,%edx
f01004c9:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004ca:	0f b7 1d 28 25 11 f0 	movzwl 0xf0112528,%ebx
f01004d1:	8d 71 01             	lea    0x1(%ecx),%esi
f01004d4:	89 d8                	mov    %ebx,%eax
f01004d6:	66 c1 e8 08          	shr    $0x8,%ax
f01004da:	89 f2                	mov    %esi,%edx
f01004dc:	ee                   	out    %al,(%dx)
f01004dd:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004e2:	89 ca                	mov    %ecx,%edx
f01004e4:	ee                   	out    %al,(%dx)
f01004e5:	89 d8                	mov    %ebx,%eax
f01004e7:	89 f2                	mov    %esi,%edx
f01004e9:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004ed:	5b                   	pop    %ebx
f01004ee:	5e                   	pop    %esi
f01004ef:	5f                   	pop    %edi
f01004f0:	5d                   	pop    %ebp
f01004f1:	c3                   	ret    

f01004f2 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004f2:	80 3d 34 25 11 f0 00 	cmpb   $0x0,0xf0112534
f01004f9:	74 11                	je     f010050c <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004fb:	55                   	push   %ebp
f01004fc:	89 e5                	mov    %esp,%ebp
f01004fe:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100501:	b8 8e 01 10 f0       	mov    $0xf010018e,%eax
f0100506:	e8 a2 fc ff ff       	call   f01001ad <cons_intr>
}
f010050b:	c9                   	leave  
f010050c:	f3 c3                	repz ret 

f010050e <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010050e:	55                   	push   %ebp
f010050f:	89 e5                	mov    %esp,%ebp
f0100511:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100514:	b8 f0 01 10 f0       	mov    $0xf01001f0,%eax
f0100519:	e8 8f fc ff ff       	call   f01001ad <cons_intr>
}
f010051e:	c9                   	leave  
f010051f:	c3                   	ret    

f0100520 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100520:	55                   	push   %ebp
f0100521:	89 e5                	mov    %esp,%ebp
f0100523:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100526:	e8 c7 ff ff ff       	call   f01004f2 <serial_intr>
	kbd_intr();
f010052b:	e8 de ff ff ff       	call   f010050e <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100530:	a1 20 25 11 f0       	mov    0xf0112520,%eax
f0100535:	3b 05 24 25 11 f0    	cmp    0xf0112524,%eax
f010053b:	74 26                	je     f0100563 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f010053d:	8d 50 01             	lea    0x1(%eax),%edx
f0100540:	89 15 20 25 11 f0    	mov    %edx,0xf0112520
f0100546:	0f b6 88 20 23 11 f0 	movzbl -0xfeedce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f010054d:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f010054f:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100555:	75 11                	jne    f0100568 <cons_getc+0x48>
			cons.rpos = 0;
f0100557:	c7 05 20 25 11 f0 00 	movl   $0x0,0xf0112520
f010055e:	00 00 00 
f0100561:	eb 05                	jmp    f0100568 <cons_getc+0x48>
		return c;
	}
	return 0;
f0100563:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100568:	c9                   	leave  
f0100569:	c3                   	ret    

f010056a <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010056a:	55                   	push   %ebp
f010056b:	89 e5                	mov    %esp,%ebp
f010056d:	57                   	push   %edi
f010056e:	56                   	push   %esi
f010056f:	53                   	push   %ebx
f0100570:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100573:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010057a:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100581:	5a a5 
	if (*cp != 0xA55A) {
f0100583:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010058a:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010058e:	74 11                	je     f01005a1 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100590:	c7 05 30 25 11 f0 b4 	movl   $0x3b4,0xf0112530
f0100597:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010059a:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010059f:	eb 16                	jmp    f01005b7 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01005a1:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01005a8:	c7 05 30 25 11 f0 d4 	movl   $0x3d4,0xf0112530
f01005af:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01005b2:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01005b7:	8b 3d 30 25 11 f0    	mov    0xf0112530,%edi
f01005bd:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005c2:	89 fa                	mov    %edi,%edx
f01005c4:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005c5:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005c8:	89 da                	mov    %ebx,%edx
f01005ca:	ec                   	in     (%dx),%al
f01005cb:	0f b6 c8             	movzbl %al,%ecx
f01005ce:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005d1:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005d6:	89 fa                	mov    %edi,%edx
f01005d8:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005d9:	89 da                	mov    %ebx,%edx
f01005db:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005dc:	89 35 2c 25 11 f0    	mov    %esi,0xf011252c
	crt_pos = pos;
f01005e2:	0f b6 c0             	movzbl %al,%eax
f01005e5:	09 c8                	or     %ecx,%eax
f01005e7:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005ed:	be fa 03 00 00       	mov    $0x3fa,%esi
f01005f2:	b8 00 00 00 00       	mov    $0x0,%eax
f01005f7:	89 f2                	mov    %esi,%edx
f01005f9:	ee                   	out    %al,(%dx)
f01005fa:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005ff:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100604:	ee                   	out    %al,(%dx)
f0100605:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f010060a:	b8 0c 00 00 00       	mov    $0xc,%eax
f010060f:	89 da                	mov    %ebx,%edx
f0100611:	ee                   	out    %al,(%dx)
f0100612:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100617:	b8 00 00 00 00       	mov    $0x0,%eax
f010061c:	ee                   	out    %al,(%dx)
f010061d:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100622:	b8 03 00 00 00       	mov    $0x3,%eax
f0100627:	ee                   	out    %al,(%dx)
f0100628:	ba fc 03 00 00       	mov    $0x3fc,%edx
f010062d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100632:	ee                   	out    %al,(%dx)
f0100633:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100638:	b8 01 00 00 00       	mov    $0x1,%eax
f010063d:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010063e:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100643:	ec                   	in     (%dx),%al
f0100644:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100646:	3c ff                	cmp    $0xff,%al
f0100648:	0f 95 05 34 25 11 f0 	setne  0xf0112534
f010064f:	89 f2                	mov    %esi,%edx
f0100651:	ec                   	in     (%dx),%al
f0100652:	89 da                	mov    %ebx,%edx
f0100654:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100655:	80 f9 ff             	cmp    $0xff,%cl
f0100658:	75 10                	jne    f010066a <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f010065a:	83 ec 0c             	sub    $0xc,%esp
f010065d:	68 b6 19 10 f0       	push   $0xf01019b6
f0100662:	e8 45 03 00 00       	call   f01009ac <cprintf>
f0100667:	83 c4 10             	add    $0x10,%esp
}
f010066a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010066d:	5b                   	pop    %ebx
f010066e:	5e                   	pop    %esi
f010066f:	5f                   	pop    %edi
f0100670:	5d                   	pop    %ebp
f0100671:	c3                   	ret    

f0100672 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100672:	55                   	push   %ebp
f0100673:	89 e5                	mov    %esp,%ebp
f0100675:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100678:	8b 45 08             	mov    0x8(%ebp),%eax
f010067b:	e8 89 fc ff ff       	call   f0100309 <cons_putc>
}
f0100680:	c9                   	leave  
f0100681:	c3                   	ret    

f0100682 <getchar>:

int
getchar(void)
{
f0100682:	55                   	push   %ebp
f0100683:	89 e5                	mov    %esp,%ebp
f0100685:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100688:	e8 93 fe ff ff       	call   f0100520 <cons_getc>
f010068d:	85 c0                	test   %eax,%eax
f010068f:	74 f7                	je     f0100688 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100691:	c9                   	leave  
f0100692:	c3                   	ret    

f0100693 <iscons>:

int
iscons(int fdnum)
{
f0100693:	55                   	push   %ebp
f0100694:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100696:	b8 01 00 00 00       	mov    $0x1,%eax
f010069b:	5d                   	pop    %ebp
f010069c:	c3                   	ret    

f010069d <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010069d:	55                   	push   %ebp
f010069e:	89 e5                	mov    %esp,%ebp
f01006a0:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01006a3:	68 00 1c 10 f0       	push   $0xf0101c00
f01006a8:	68 1e 1c 10 f0       	push   $0xf0101c1e
f01006ad:	68 23 1c 10 f0       	push   $0xf0101c23
f01006b2:	e8 f5 02 00 00       	call   f01009ac <cprintf>
f01006b7:	83 c4 0c             	add    $0xc,%esp
f01006ba:	68 d4 1c 10 f0       	push   $0xf0101cd4
f01006bf:	68 2c 1c 10 f0       	push   $0xf0101c2c
f01006c4:	68 23 1c 10 f0       	push   $0xf0101c23
f01006c9:	e8 de 02 00 00       	call   f01009ac <cprintf>
f01006ce:	83 c4 0c             	add    $0xc,%esp
f01006d1:	68 fc 1c 10 f0       	push   $0xf0101cfc
f01006d6:	68 35 1c 10 f0       	push   $0xf0101c35
f01006db:	68 23 1c 10 f0       	push   $0xf0101c23
f01006e0:	e8 c7 02 00 00       	call   f01009ac <cprintf>
	return 0;
}
f01006e5:	b8 00 00 00 00       	mov    $0x0,%eax
f01006ea:	c9                   	leave  
f01006eb:	c3                   	ret    

f01006ec <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006ec:	55                   	push   %ebp
f01006ed:	89 e5                	mov    %esp,%ebp
f01006ef:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006f2:	68 3f 1c 10 f0       	push   $0xf0101c3f
f01006f7:	e8 b0 02 00 00       	call   f01009ac <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006fc:	83 c4 08             	add    $0x8,%esp
f01006ff:	68 0c 00 10 00       	push   $0x10000c
f0100704:	68 1c 1d 10 f0       	push   $0xf0101d1c
f0100709:	e8 9e 02 00 00       	call   f01009ac <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010070e:	83 c4 0c             	add    $0xc,%esp
f0100711:	68 0c 00 10 00       	push   $0x10000c
f0100716:	68 0c 00 10 f0       	push   $0xf010000c
f010071b:	68 44 1d 10 f0       	push   $0xf0101d44
f0100720:	e8 87 02 00 00       	call   f01009ac <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100725:	83 c4 0c             	add    $0xc,%esp
f0100728:	68 f1 18 10 00       	push   $0x1018f1
f010072d:	68 f1 18 10 f0       	push   $0xf01018f1
f0100732:	68 68 1d 10 f0       	push   $0xf0101d68
f0100737:	e8 70 02 00 00       	call   f01009ac <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010073c:	83 c4 0c             	add    $0xc,%esp
f010073f:	68 00 23 11 00       	push   $0x112300
f0100744:	68 00 23 11 f0       	push   $0xf0112300
f0100749:	68 8c 1d 10 f0       	push   $0xf0101d8c
f010074e:	e8 59 02 00 00       	call   f01009ac <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100753:	83 c4 0c             	add    $0xc,%esp
f0100756:	68 44 29 11 00       	push   $0x112944
f010075b:	68 44 29 11 f0       	push   $0xf0112944
f0100760:	68 b0 1d 10 f0       	push   $0xf0101db0
f0100765:	e8 42 02 00 00       	call   f01009ac <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010076a:	b8 43 2d 11 f0       	mov    $0xf0112d43,%eax
f010076f:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100774:	83 c4 08             	add    $0x8,%esp
f0100777:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f010077c:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100782:	85 c0                	test   %eax,%eax
f0100784:	0f 48 c2             	cmovs  %edx,%eax
f0100787:	c1 f8 0a             	sar    $0xa,%eax
f010078a:	50                   	push   %eax
f010078b:	68 d4 1d 10 f0       	push   $0xf0101dd4
f0100790:	e8 17 02 00 00       	call   f01009ac <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100795:	b8 00 00 00 00       	mov    $0x0,%eax
f010079a:	c9                   	leave  
f010079b:	c3                   	ret    

f010079c <backtrace>:
int
backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010079c:	55                   	push   %ebp
f010079d:	89 e5                	mov    %esp,%ebp
f010079f:	57                   	push   %edi
f01007a0:	56                   	push   %esi
f01007a1:	53                   	push   %ebx
f01007a2:	83 ec 48             	sub    $0x48,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01007a5:	89 ee                	mov    %ebp,%esi
  uint32_t* ebp = (uint32_t*) read_ebp();
  cprintf("Stack backtrace:\n");
f01007a7:	68 58 1c 10 f0       	push   $0xf0101c58
f01007ac:	e8 fb 01 00 00       	call   f01009ac <cprintf>
  while (ebp) {
f01007b1:	83 c4 10             	add    $0x10,%esp
f01007b4:	eb 78                	jmp    f010082e <backtrace+0x92>
    uint32_t eip = ebp[1];
f01007b6:	8b 46 04             	mov    0x4(%esi),%eax
f01007b9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    cprintf("ebp %x  eip %x  args", ebp, eip);
f01007bc:	83 ec 04             	sub    $0x4,%esp
f01007bf:	50                   	push   %eax
f01007c0:	56                   	push   %esi
f01007c1:	68 6a 1c 10 f0       	push   $0xf0101c6a
f01007c6:	e8 e1 01 00 00       	call   f01009ac <cprintf>
f01007cb:	8d 5e 08             	lea    0x8(%esi),%ebx
f01007ce:	8d 7e 1c             	lea    0x1c(%esi),%edi
f01007d1:	83 c4 10             	add    $0x10,%esp
    int i;
    for (i = 2; i <= 6; ++i)
      cprintf(" %08.x", ebp[i]);
f01007d4:	83 ec 08             	sub    $0x8,%esp
f01007d7:	ff 33                	pushl  (%ebx)
f01007d9:	68 7f 1c 10 f0       	push   $0xf0101c7f
f01007de:	e8 c9 01 00 00       	call   f01009ac <cprintf>
f01007e3:	83 c3 04             	add    $0x4,%ebx
  cprintf("Stack backtrace:\n");
  while (ebp) {
    uint32_t eip = ebp[1];
    cprintf("ebp %x  eip %x  args", ebp, eip);
    int i;
    for (i = 2; i <= 6; ++i)
f01007e6:	83 c4 10             	add    $0x10,%esp
f01007e9:	39 fb                	cmp    %edi,%ebx
f01007eb:	75 e7                	jne    f01007d4 <backtrace+0x38>
      cprintf(" %08.x", ebp[i]);
    cprintf("\n");
f01007ed:	83 ec 0c             	sub    $0xc,%esp
f01007f0:	68 b4 19 10 f0       	push   $0xf01019b4
f01007f5:	e8 b2 01 00 00       	call   f01009ac <cprintf>
    struct Eipdebuginfo info;
    debuginfo_eip(eip, &info);
f01007fa:	83 c4 08             	add    $0x8,%esp
f01007fd:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100800:	50                   	push   %eax
f0100801:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100804:	57                   	push   %edi
f0100805:	e8 ac 02 00 00       	call   f0100ab6 <debuginfo_eip>
    cprintf("\t%s:%d: %.*s+%d\n", 
f010080a:	83 c4 08             	add    $0x8,%esp
f010080d:	89 f8                	mov    %edi,%eax
f010080f:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100812:	50                   	push   %eax
f0100813:	ff 75 d8             	pushl  -0x28(%ebp)
f0100816:	ff 75 dc             	pushl  -0x24(%ebp)
f0100819:	ff 75 d4             	pushl  -0x2c(%ebp)
f010081c:	ff 75 d0             	pushl  -0x30(%ebp)
f010081f:	68 86 1c 10 f0       	push   $0xf0101c86
f0100824:	e8 83 01 00 00       	call   f01009ac <cprintf>
      info.eip_file, info.eip_line,
      info.eip_fn_namelen, info.eip_fn_name,
      eip-info.eip_fn_addr);
//         kern/monitor.c:143: monitor+106
    ebp = (uint32_t*) *ebp;
f0100829:	8b 36                	mov    (%esi),%esi
f010082b:	83 c4 20             	add    $0x20,%esp
int
backtrace(int argc, char **argv, struct Trapframe *tf)
{
  uint32_t* ebp = (uint32_t*) read_ebp();
  cprintf("Stack backtrace:\n");
  while (ebp) {
f010082e:	85 f6                	test   %esi,%esi
f0100830:	75 84                	jne    f01007b6 <backtrace+0x1a>
      eip-info.eip_fn_addr);
//         kern/monitor.c:143: monitor+106
    ebp = (uint32_t*) *ebp;
  }
  return 0;
}
f0100832:	b8 00 00 00 00       	mov    $0x0,%eax
f0100837:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010083a:	5b                   	pop    %ebx
f010083b:	5e                   	pop    %esi
f010083c:	5f                   	pop    %edi
f010083d:	5d                   	pop    %ebp
f010083e:	c3                   	ret    

f010083f <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010083f:	55                   	push   %ebp
f0100840:	89 e5                	mov    %esp,%ebp
f0100842:	57                   	push   %edi
f0100843:	56                   	push   %esi
f0100844:	53                   	push   %ebx
f0100845:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100848:	68 00 1e 10 f0       	push   $0xf0101e00
f010084d:	e8 5a 01 00 00       	call   f01009ac <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100852:	c7 04 24 24 1e 10 f0 	movl   $0xf0101e24,(%esp)
f0100859:	e8 4e 01 00 00       	call   f01009ac <cprintf>
f010085e:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100861:	83 ec 0c             	sub    $0xc,%esp
f0100864:	68 97 1c 10 f0       	push   $0xf0101c97
f0100869:	e8 a1 09 00 00       	call   f010120f <readline>
f010086e:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100870:	83 c4 10             	add    $0x10,%esp
f0100873:	85 c0                	test   %eax,%eax
f0100875:	74 ea                	je     f0100861 <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100877:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010087e:	be 00 00 00 00       	mov    $0x0,%esi
f0100883:	eb 0a                	jmp    f010088f <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100885:	c6 03 00             	movb   $0x0,(%ebx)
f0100888:	89 f7                	mov    %esi,%edi
f010088a:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010088d:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010088f:	0f b6 03             	movzbl (%ebx),%eax
f0100892:	84 c0                	test   %al,%al
f0100894:	74 63                	je     f01008f9 <monitor+0xba>
f0100896:	83 ec 08             	sub    $0x8,%esp
f0100899:	0f be c0             	movsbl %al,%eax
f010089c:	50                   	push   %eax
f010089d:	68 9b 1c 10 f0       	push   $0xf0101c9b
f01008a2:	e8 82 0b 00 00       	call   f0101429 <strchr>
f01008a7:	83 c4 10             	add    $0x10,%esp
f01008aa:	85 c0                	test   %eax,%eax
f01008ac:	75 d7                	jne    f0100885 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f01008ae:	80 3b 00             	cmpb   $0x0,(%ebx)
f01008b1:	74 46                	je     f01008f9 <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01008b3:	83 fe 0f             	cmp    $0xf,%esi
f01008b6:	75 14                	jne    f01008cc <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01008b8:	83 ec 08             	sub    $0x8,%esp
f01008bb:	6a 10                	push   $0x10
f01008bd:	68 a0 1c 10 f0       	push   $0xf0101ca0
f01008c2:	e8 e5 00 00 00       	call   f01009ac <cprintf>
f01008c7:	83 c4 10             	add    $0x10,%esp
f01008ca:	eb 95                	jmp    f0100861 <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f01008cc:	8d 7e 01             	lea    0x1(%esi),%edi
f01008cf:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01008d3:	eb 03                	jmp    f01008d8 <monitor+0x99>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01008d5:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01008d8:	0f b6 03             	movzbl (%ebx),%eax
f01008db:	84 c0                	test   %al,%al
f01008dd:	74 ae                	je     f010088d <monitor+0x4e>
f01008df:	83 ec 08             	sub    $0x8,%esp
f01008e2:	0f be c0             	movsbl %al,%eax
f01008e5:	50                   	push   %eax
f01008e6:	68 9b 1c 10 f0       	push   $0xf0101c9b
f01008eb:	e8 39 0b 00 00       	call   f0101429 <strchr>
f01008f0:	83 c4 10             	add    $0x10,%esp
f01008f3:	85 c0                	test   %eax,%eax
f01008f5:	74 de                	je     f01008d5 <monitor+0x96>
f01008f7:	eb 94                	jmp    f010088d <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f01008f9:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100900:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100901:	85 f6                	test   %esi,%esi
f0100903:	0f 84 58 ff ff ff    	je     f0100861 <monitor+0x22>
f0100909:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010090e:	83 ec 08             	sub    $0x8,%esp
f0100911:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100914:	ff 34 85 60 1e 10 f0 	pushl  -0xfefe1a0(,%eax,4)
f010091b:	ff 75 a8             	pushl  -0x58(%ebp)
f010091e:	e8 a8 0a 00 00       	call   f01013cb <strcmp>
f0100923:	83 c4 10             	add    $0x10,%esp
f0100926:	85 c0                	test   %eax,%eax
f0100928:	75 21                	jne    f010094b <monitor+0x10c>
			return commands[i].func(argc, argv, tf);
f010092a:	83 ec 04             	sub    $0x4,%esp
f010092d:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100930:	ff 75 08             	pushl  0x8(%ebp)
f0100933:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100936:	52                   	push   %edx
f0100937:	56                   	push   %esi
f0100938:	ff 14 85 68 1e 10 f0 	call   *-0xfefe198(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f010093f:	83 c4 10             	add    $0x10,%esp
f0100942:	85 c0                	test   %eax,%eax
f0100944:	78 25                	js     f010096b <monitor+0x12c>
f0100946:	e9 16 ff ff ff       	jmp    f0100861 <monitor+0x22>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f010094b:	83 c3 01             	add    $0x1,%ebx
f010094e:	83 fb 03             	cmp    $0x3,%ebx
f0100951:	75 bb                	jne    f010090e <monitor+0xcf>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100953:	83 ec 08             	sub    $0x8,%esp
f0100956:	ff 75 a8             	pushl  -0x58(%ebp)
f0100959:	68 bd 1c 10 f0       	push   $0xf0101cbd
f010095e:	e8 49 00 00 00       	call   f01009ac <cprintf>
f0100963:	83 c4 10             	add    $0x10,%esp
f0100966:	e9 f6 fe ff ff       	jmp    f0100861 <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010096b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010096e:	5b                   	pop    %ebx
f010096f:	5e                   	pop    %esi
f0100970:	5f                   	pop    %edi
f0100971:	5d                   	pop    %ebp
f0100972:	c3                   	ret    

f0100973 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100973:	55                   	push   %ebp
f0100974:	89 e5                	mov    %esp,%ebp
f0100976:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0100979:	ff 75 08             	pushl  0x8(%ebp)
f010097c:	e8 f1 fc ff ff       	call   f0100672 <cputchar>
	*cnt++;
}
f0100981:	83 c4 10             	add    $0x10,%esp
f0100984:	c9                   	leave  
f0100985:	c3                   	ret    

f0100986 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100986:	55                   	push   %ebp
f0100987:	89 e5                	mov    %esp,%ebp
f0100989:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010098c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100993:	ff 75 0c             	pushl  0xc(%ebp)
f0100996:	ff 75 08             	pushl  0x8(%ebp)
f0100999:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010099c:	50                   	push   %eax
f010099d:	68 73 09 10 f0       	push   $0xf0100973
f01009a2:	e8 52 04 00 00       	call   f0100df9 <vprintfmt>
	return cnt;
}
f01009a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01009aa:	c9                   	leave  
f01009ab:	c3                   	ret    

f01009ac <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01009ac:	55                   	push   %ebp
f01009ad:	89 e5                	mov    %esp,%ebp
f01009af:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01009b2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01009b5:	50                   	push   %eax
f01009b6:	ff 75 08             	pushl  0x8(%ebp)
f01009b9:	e8 c8 ff ff ff       	call   f0100986 <vcprintf>
	va_end(ap);

	return cnt;
}
f01009be:	c9                   	leave  
f01009bf:	c3                   	ret    

f01009c0 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01009c0:	55                   	push   %ebp
f01009c1:	89 e5                	mov    %esp,%ebp
f01009c3:	57                   	push   %edi
f01009c4:	56                   	push   %esi
f01009c5:	53                   	push   %ebx
f01009c6:	83 ec 14             	sub    $0x14,%esp
f01009c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01009cc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01009cf:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01009d2:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01009d5:	8b 1a                	mov    (%edx),%ebx
f01009d7:	8b 01                	mov    (%ecx),%eax
f01009d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01009dc:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01009e3:	eb 7f                	jmp    f0100a64 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f01009e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01009e8:	01 d8                	add    %ebx,%eax
f01009ea:	89 c6                	mov    %eax,%esi
f01009ec:	c1 ee 1f             	shr    $0x1f,%esi
f01009ef:	01 c6                	add    %eax,%esi
f01009f1:	d1 fe                	sar    %esi
f01009f3:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01009f6:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01009f9:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01009fc:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01009fe:	eb 03                	jmp    f0100a03 <stab_binsearch+0x43>
			m--;
f0100a00:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100a03:	39 c3                	cmp    %eax,%ebx
f0100a05:	7f 0d                	jg     f0100a14 <stab_binsearch+0x54>
f0100a07:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100a0b:	83 ea 0c             	sub    $0xc,%edx
f0100a0e:	39 f9                	cmp    %edi,%ecx
f0100a10:	75 ee                	jne    f0100a00 <stab_binsearch+0x40>
f0100a12:	eb 05                	jmp    f0100a19 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100a14:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0100a17:	eb 4b                	jmp    f0100a64 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100a19:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100a1c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100a1f:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100a23:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100a26:	76 11                	jbe    f0100a39 <stab_binsearch+0x79>
			*region_left = m;
f0100a28:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100a2b:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100a2d:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a30:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a37:	eb 2b                	jmp    f0100a64 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100a39:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100a3c:	73 14                	jae    f0100a52 <stab_binsearch+0x92>
			*region_right = m - 1;
f0100a3e:	83 e8 01             	sub    $0x1,%eax
f0100a41:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a44:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100a47:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a49:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a50:	eb 12                	jmp    f0100a64 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100a52:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a55:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100a57:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100a5b:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a5d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100a64:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100a67:	0f 8e 78 ff ff ff    	jle    f01009e5 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100a6d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100a71:	75 0f                	jne    f0100a82 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0100a73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a76:	8b 00                	mov    (%eax),%eax
f0100a78:	83 e8 01             	sub    $0x1,%eax
f0100a7b:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100a7e:	89 06                	mov    %eax,(%esi)
f0100a80:	eb 2c                	jmp    f0100aae <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a82:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a85:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100a87:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a8a:	8b 0e                	mov    (%esi),%ecx
f0100a8c:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100a8f:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100a92:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a95:	eb 03                	jmp    f0100a9a <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100a97:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a9a:	39 c8                	cmp    %ecx,%eax
f0100a9c:	7e 0b                	jle    f0100aa9 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0100a9e:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0100aa2:	83 ea 0c             	sub    $0xc,%edx
f0100aa5:	39 df                	cmp    %ebx,%edi
f0100aa7:	75 ee                	jne    f0100a97 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100aa9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100aac:	89 06                	mov    %eax,(%esi)
	}
}
f0100aae:	83 c4 14             	add    $0x14,%esp
f0100ab1:	5b                   	pop    %ebx
f0100ab2:	5e                   	pop    %esi
f0100ab3:	5f                   	pop    %edi
f0100ab4:	5d                   	pop    %ebp
f0100ab5:	c3                   	ret    

f0100ab6 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100ab6:	55                   	push   %ebp
f0100ab7:	89 e5                	mov    %esp,%ebp
f0100ab9:	57                   	push   %edi
f0100aba:	56                   	push   %esi
f0100abb:	53                   	push   %ebx
f0100abc:	83 ec 3c             	sub    $0x3c,%esp
f0100abf:	8b 75 08             	mov    0x8(%ebp),%esi
f0100ac2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100ac5:	c7 03 84 1e 10 f0    	movl   $0xf0101e84,(%ebx)
	info->eip_line = 0;
f0100acb:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100ad2:	c7 43 08 84 1e 10 f0 	movl   $0xf0101e84,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100ad9:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100ae0:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100ae3:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100aea:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100af0:	76 11                	jbe    f0100b03 <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100af2:	b8 3d 73 10 f0       	mov    $0xf010733d,%eax
f0100af7:	3d 41 5a 10 f0       	cmp    $0xf0105a41,%eax
f0100afc:	77 19                	ja     f0100b17 <debuginfo_eip+0x61>
f0100afe:	e9 aa 01 00 00       	jmp    f0100cad <debuginfo_eip+0x1f7>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100b03:	83 ec 04             	sub    $0x4,%esp
f0100b06:	68 8e 1e 10 f0       	push   $0xf0101e8e
f0100b0b:	6a 7f                	push   $0x7f
f0100b0d:	68 9b 1e 10 f0       	push   $0xf0101e9b
f0100b12:	e8 e6 f5 ff ff       	call   f01000fd <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100b17:	80 3d 3c 73 10 f0 00 	cmpb   $0x0,0xf010733c
f0100b1e:	0f 85 90 01 00 00    	jne    f0100cb4 <debuginfo_eip+0x1fe>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100b24:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100b2b:	b8 40 5a 10 f0       	mov    $0xf0105a40,%eax
f0100b30:	2d bc 20 10 f0       	sub    $0xf01020bc,%eax
f0100b35:	c1 f8 02             	sar    $0x2,%eax
f0100b38:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100b3e:	83 e8 01             	sub    $0x1,%eax
f0100b41:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100b44:	83 ec 08             	sub    $0x8,%esp
f0100b47:	56                   	push   %esi
f0100b48:	6a 64                	push   $0x64
f0100b4a:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100b4d:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100b50:	b8 bc 20 10 f0       	mov    $0xf01020bc,%eax
f0100b55:	e8 66 fe ff ff       	call   f01009c0 <stab_binsearch>
	if (lfile == 0)
f0100b5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b5d:	83 c4 10             	add    $0x10,%esp
f0100b60:	85 c0                	test   %eax,%eax
f0100b62:	0f 84 53 01 00 00    	je     f0100cbb <debuginfo_eip+0x205>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100b68:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100b6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b6e:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100b71:	83 ec 08             	sub    $0x8,%esp
f0100b74:	56                   	push   %esi
f0100b75:	6a 24                	push   $0x24
f0100b77:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100b7a:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b7d:	b8 bc 20 10 f0       	mov    $0xf01020bc,%eax
f0100b82:	e8 39 fe ff ff       	call   f01009c0 <stab_binsearch>

	if (lfun <= rfun) {
f0100b87:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100b8a:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100b8d:	83 c4 10             	add    $0x10,%esp
f0100b90:	39 d0                	cmp    %edx,%eax
f0100b92:	7f 40                	jg     f0100bd4 <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100b94:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100b97:	c1 e1 02             	shl    $0x2,%ecx
f0100b9a:	8d b9 bc 20 10 f0    	lea    -0xfefdf44(%ecx),%edi
f0100ba0:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0100ba3:	8b b9 bc 20 10 f0    	mov    -0xfefdf44(%ecx),%edi
f0100ba9:	b9 3d 73 10 f0       	mov    $0xf010733d,%ecx
f0100bae:	81 e9 41 5a 10 f0    	sub    $0xf0105a41,%ecx
f0100bb4:	39 cf                	cmp    %ecx,%edi
f0100bb6:	73 09                	jae    f0100bc1 <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100bb8:	81 c7 41 5a 10 f0    	add    $0xf0105a41,%edi
f0100bbe:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100bc1:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100bc4:	8b 4f 08             	mov    0x8(%edi),%ecx
f0100bc7:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100bca:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0100bcc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100bcf:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100bd2:	eb 0f                	jmp    f0100be3 <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100bd4:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100bd7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bda:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100bdd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100be0:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100be3:	83 ec 08             	sub    $0x8,%esp
f0100be6:	6a 3a                	push   $0x3a
f0100be8:	ff 73 08             	pushl  0x8(%ebx)
f0100beb:	e8 5a 08 00 00       	call   f010144a <strfind>
f0100bf0:	2b 43 08             	sub    0x8(%ebx),%eax
f0100bf3:	89 43 0c             	mov    %eax,0xc(%ebx)


	// Search within [lline, rline] for the line number stab.
	// If found, set info->eip_line to the right line number.
	// If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100bf6:	83 c4 08             	add    $0x8,%esp
f0100bf9:	56                   	push   %esi
f0100bfa:	6a 44                	push   $0x44
f0100bfc:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100bff:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100c02:	b8 bc 20 10 f0       	mov    $0xf01020bc,%eax
f0100c07:	e8 b4 fd ff ff       	call   f01009c0 <stab_binsearch>
	if(lline > rline) return -1;
f0100c0c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100c0f:	83 c4 10             	add    $0x10,%esp
f0100c12:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0100c15:	0f 8f a7 00 00 00    	jg     f0100cc2 <debuginfo_eip+0x20c>
	else info->eip_line = stabs[lline].n_desc;
f0100c1b:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0100c1e:	8d 04 85 bc 20 10 f0 	lea    -0xfefdf44(,%eax,4),%eax
f0100c25:	0f b7 48 06          	movzwl 0x6(%eax),%ecx
f0100c29:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100c2c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100c2f:	eb 06                	jmp    f0100c37 <debuginfo_eip+0x181>
f0100c31:	83 ea 01             	sub    $0x1,%edx
f0100c34:	83 e8 0c             	sub    $0xc,%eax
f0100c37:	39 d6                	cmp    %edx,%esi
f0100c39:	7f 34                	jg     f0100c6f <debuginfo_eip+0x1b9>
	       && stabs[lline].n_type != N_SOL
f0100c3b:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f0100c3f:	80 f9 84             	cmp    $0x84,%cl
f0100c42:	74 0b                	je     f0100c4f <debuginfo_eip+0x199>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100c44:	80 f9 64             	cmp    $0x64,%cl
f0100c47:	75 e8                	jne    f0100c31 <debuginfo_eip+0x17b>
f0100c49:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0100c4d:	74 e2                	je     f0100c31 <debuginfo_eip+0x17b>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100c4f:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0100c52:	8b 14 85 bc 20 10 f0 	mov    -0xfefdf44(,%eax,4),%edx
f0100c59:	b8 3d 73 10 f0       	mov    $0xf010733d,%eax
f0100c5e:	2d 41 5a 10 f0       	sub    $0xf0105a41,%eax
f0100c63:	39 c2                	cmp    %eax,%edx
f0100c65:	73 08                	jae    f0100c6f <debuginfo_eip+0x1b9>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100c67:	81 c2 41 5a 10 f0    	add    $0xf0105a41,%edx
f0100c6d:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c6f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100c72:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c75:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c7a:	39 f2                	cmp    %esi,%edx
f0100c7c:	7d 50                	jge    f0100cce <debuginfo_eip+0x218>
		for (lline = lfun + 1;
f0100c7e:	83 c2 01             	add    $0x1,%edx
f0100c81:	89 d0                	mov    %edx,%eax
f0100c83:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100c86:	8d 14 95 bc 20 10 f0 	lea    -0xfefdf44(,%edx,4),%edx
f0100c8d:	eb 04                	jmp    f0100c93 <debuginfo_eip+0x1dd>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100c8f:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100c93:	39 c6                	cmp    %eax,%esi
f0100c95:	7e 32                	jle    f0100cc9 <debuginfo_eip+0x213>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100c97:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100c9b:	83 c0 01             	add    $0x1,%eax
f0100c9e:	83 c2 0c             	add    $0xc,%edx
f0100ca1:	80 f9 a0             	cmp    $0xa0,%cl
f0100ca4:	74 e9                	je     f0100c8f <debuginfo_eip+0x1d9>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100ca6:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cab:	eb 21                	jmp    f0100cce <debuginfo_eip+0x218>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100cad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100cb2:	eb 1a                	jmp    f0100cce <debuginfo_eip+0x218>
f0100cb4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100cb9:	eb 13                	jmp    f0100cce <debuginfo_eip+0x218>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0100cbb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100cc0:	eb 0c                	jmp    f0100cce <debuginfo_eip+0x218>

	// Search within [lline, rline] for the line number stab.
	// If found, set info->eip_line to the right line number.
	// If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if(lline > rline) return -1;
f0100cc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100cc7:	eb 05                	jmp    f0100cce <debuginfo_eip+0x218>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100cc9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100cce:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100cd1:	5b                   	pop    %ebx
f0100cd2:	5e                   	pop    %esi
f0100cd3:	5f                   	pop    %edi
f0100cd4:	5d                   	pop    %ebp
f0100cd5:	c3                   	ret    

f0100cd6 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100cd6:	55                   	push   %ebp
f0100cd7:	89 e5                	mov    %esp,%ebp
f0100cd9:	57                   	push   %edi
f0100cda:	56                   	push   %esi
f0100cdb:	53                   	push   %ebx
f0100cdc:	83 ec 1c             	sub    $0x1c,%esp
f0100cdf:	89 c7                	mov    %eax,%edi
f0100ce1:	89 d6                	mov    %edx,%esi
f0100ce3:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ce6:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100ce9:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100cec:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100cef:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100cf2:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100cf7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100cfa:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0100cfd:	39 d3                	cmp    %edx,%ebx
f0100cff:	72 05                	jb     f0100d06 <printnum+0x30>
f0100d01:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100d04:	77 45                	ja     f0100d4b <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100d06:	83 ec 0c             	sub    $0xc,%esp
f0100d09:	ff 75 18             	pushl  0x18(%ebp)
f0100d0c:	8b 45 14             	mov    0x14(%ebp),%eax
f0100d0f:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100d12:	53                   	push   %ebx
f0100d13:	ff 75 10             	pushl  0x10(%ebp)
f0100d16:	83 ec 08             	sub    $0x8,%esp
f0100d19:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100d1c:	ff 75 e0             	pushl  -0x20(%ebp)
f0100d1f:	ff 75 dc             	pushl  -0x24(%ebp)
f0100d22:	ff 75 d8             	pushl  -0x28(%ebp)
f0100d25:	e8 46 09 00 00       	call   f0101670 <__udivdi3>
f0100d2a:	83 c4 18             	add    $0x18,%esp
f0100d2d:	52                   	push   %edx
f0100d2e:	50                   	push   %eax
f0100d2f:	89 f2                	mov    %esi,%edx
f0100d31:	89 f8                	mov    %edi,%eax
f0100d33:	e8 9e ff ff ff       	call   f0100cd6 <printnum>
f0100d38:	83 c4 20             	add    $0x20,%esp
f0100d3b:	eb 18                	jmp    f0100d55 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100d3d:	83 ec 08             	sub    $0x8,%esp
f0100d40:	56                   	push   %esi
f0100d41:	ff 75 18             	pushl  0x18(%ebp)
f0100d44:	ff d7                	call   *%edi
f0100d46:	83 c4 10             	add    $0x10,%esp
f0100d49:	eb 03                	jmp    f0100d4e <printnum+0x78>
f0100d4b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100d4e:	83 eb 01             	sub    $0x1,%ebx
f0100d51:	85 db                	test   %ebx,%ebx
f0100d53:	7f e8                	jg     f0100d3d <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100d55:	83 ec 08             	sub    $0x8,%esp
f0100d58:	56                   	push   %esi
f0100d59:	83 ec 04             	sub    $0x4,%esp
f0100d5c:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100d5f:	ff 75 e0             	pushl  -0x20(%ebp)
f0100d62:	ff 75 dc             	pushl  -0x24(%ebp)
f0100d65:	ff 75 d8             	pushl  -0x28(%ebp)
f0100d68:	e8 33 0a 00 00       	call   f01017a0 <__umoddi3>
f0100d6d:	83 c4 14             	add    $0x14,%esp
f0100d70:	0f be 80 a9 1e 10 f0 	movsbl -0xfefe157(%eax),%eax
f0100d77:	50                   	push   %eax
f0100d78:	ff d7                	call   *%edi
}
f0100d7a:	83 c4 10             	add    $0x10,%esp
f0100d7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d80:	5b                   	pop    %ebx
f0100d81:	5e                   	pop    %esi
f0100d82:	5f                   	pop    %edi
f0100d83:	5d                   	pop    %ebp
f0100d84:	c3                   	ret    

f0100d85 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100d85:	55                   	push   %ebp
f0100d86:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100d88:	83 fa 01             	cmp    $0x1,%edx
f0100d8b:	7e 0e                	jle    f0100d9b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100d8d:	8b 10                	mov    (%eax),%edx
f0100d8f:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100d92:	89 08                	mov    %ecx,(%eax)
f0100d94:	8b 02                	mov    (%edx),%eax
f0100d96:	8b 52 04             	mov    0x4(%edx),%edx
f0100d99:	eb 22                	jmp    f0100dbd <getuint+0x38>
	else if (lflag)
f0100d9b:	85 d2                	test   %edx,%edx
f0100d9d:	74 10                	je     f0100daf <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100d9f:	8b 10                	mov    (%eax),%edx
f0100da1:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100da4:	89 08                	mov    %ecx,(%eax)
f0100da6:	8b 02                	mov    (%edx),%eax
f0100da8:	ba 00 00 00 00       	mov    $0x0,%edx
f0100dad:	eb 0e                	jmp    f0100dbd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100daf:	8b 10                	mov    (%eax),%edx
f0100db1:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100db4:	89 08                	mov    %ecx,(%eax)
f0100db6:	8b 02                	mov    (%edx),%eax
f0100db8:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100dbd:	5d                   	pop    %ebp
f0100dbe:	c3                   	ret    

f0100dbf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100dbf:	55                   	push   %ebp
f0100dc0:	89 e5                	mov    %esp,%ebp
f0100dc2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100dc5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100dc9:	8b 10                	mov    (%eax),%edx
f0100dcb:	3b 50 04             	cmp    0x4(%eax),%edx
f0100dce:	73 0a                	jae    f0100dda <sprintputch+0x1b>
		*b->buf++ = ch;
f0100dd0:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100dd3:	89 08                	mov    %ecx,(%eax)
f0100dd5:	8b 45 08             	mov    0x8(%ebp),%eax
f0100dd8:	88 02                	mov    %al,(%edx)
}
f0100dda:	5d                   	pop    %ebp
f0100ddb:	c3                   	ret    

f0100ddc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100ddc:	55                   	push   %ebp
f0100ddd:	89 e5                	mov    %esp,%ebp
f0100ddf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100de2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100de5:	50                   	push   %eax
f0100de6:	ff 75 10             	pushl  0x10(%ebp)
f0100de9:	ff 75 0c             	pushl  0xc(%ebp)
f0100dec:	ff 75 08             	pushl  0x8(%ebp)
f0100def:	e8 05 00 00 00       	call   f0100df9 <vprintfmt>
	va_end(ap);
}
f0100df4:	83 c4 10             	add    $0x10,%esp
f0100df7:	c9                   	leave  
f0100df8:	c3                   	ret    

f0100df9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100df9:	55                   	push   %ebp
f0100dfa:	89 e5                	mov    %esp,%ebp
f0100dfc:	57                   	push   %edi
f0100dfd:	56                   	push   %esi
f0100dfe:	53                   	push   %ebx
f0100dff:	83 ec 2c             	sub    $0x2c,%esp
f0100e02:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
    int color = 0;
f0100e05:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100e0c:	eb 17                	jmp    f0100e25 <vprintfmt+0x2c>
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100e0e:	85 c0                	test   %eax,%eax
f0100e10:	0f 84 89 03 00 00    	je     f010119f <vprintfmt+0x3a6>
				return;
			putch(ch, putdat);
f0100e16:	83 ec 08             	sub    $0x8,%esp
f0100e19:	ff 75 0c             	pushl  0xc(%ebp)
f0100e1c:	50                   	push   %eax
f0100e1d:	ff 55 08             	call   *0x8(%ebp)
f0100e20:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
    int color = 0;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100e23:	89 f3                	mov    %esi,%ebx
f0100e25:	8d 73 01             	lea    0x1(%ebx),%esi
f0100e28:	0f b6 03             	movzbl (%ebx),%eax
f0100e2b:	83 f8 25             	cmp    $0x25,%eax
f0100e2e:	75 de                	jne    f0100e0e <vprintfmt+0x15>
f0100e30:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f0100e34:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100e3b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0100e40:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0100e47:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e4c:	eb 0d                	jmp    f0100e5b <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e4e:	89 de                	mov    %ebx,%esi
f0100e50:	eb 09                	jmp    f0100e5b <vprintfmt+0x62>
f0100e52:	89 de                	mov    %ebx,%esi
			break;
        case 'C': 
        //自己补充的控制颜色的代码
            switch(va_arg(ap,int)){
                case 0:
                    color = 0x0c00;
f0100e54:	c7 45 d8 00 0c 00 00 	movl   $0xc00,-0x28(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e5b:	8d 5e 01             	lea    0x1(%esi),%ebx
f0100e5e:	0f b6 06             	movzbl (%esi),%eax
f0100e61:	0f b6 c8             	movzbl %al,%ecx
f0100e64:	83 e8 23             	sub    $0x23,%eax
f0100e67:	3c 55                	cmp    $0x55,%al
f0100e69:	0f 87 10 03 00 00    	ja     f010117f <vprintfmt+0x386>
f0100e6f:	0f b6 c0             	movzbl %al,%eax
f0100e72:	ff 24 85 38 1f 10 f0 	jmp    *-0xfefe0c8(,%eax,4)
f0100e79:	89 de                	mov    %ebx,%esi
		case '-':
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100e7b:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f0100e7f:	eb da                	jmp    f0100e5b <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e81:	89 de                	mov    %ebx,%esi
f0100e83:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100e88:	8d 04 bf             	lea    (%edi,%edi,4),%eax
f0100e8b:	8d 7c 41 d0          	lea    -0x30(%ecx,%eax,2),%edi
				ch = *fmt;
f0100e8f:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
f0100e92:	8d 41 d0             	lea    -0x30(%ecx),%eax
f0100e95:	83 f8 09             	cmp    $0x9,%eax
f0100e98:	77 33                	ja     f0100ecd <vprintfmt+0xd4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100e9a:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0100e9d:	eb e9                	jmp    f0100e88 <vprintfmt+0x8f>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100e9f:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ea2:	8d 48 04             	lea    0x4(%eax),%ecx
f0100ea5:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0100ea8:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100eaa:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0100eac:	eb 1f                	jmp    f0100ecd <vprintfmt+0xd4>
f0100eae:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100eb1:	85 c0                	test   %eax,%eax
f0100eb3:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100eb8:	0f 49 c8             	cmovns %eax,%ecx
f0100ebb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ebe:	89 de                	mov    %ebx,%esi
f0100ec0:	eb 99                	jmp    f0100e5b <vprintfmt+0x62>
f0100ec2:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0100ec4:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
f0100ecb:	eb 8e                	jmp    f0100e5b <vprintfmt+0x62>

		process_precision:
			if (width < 0)
f0100ecd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100ed1:	79 88                	jns    f0100e5b <vprintfmt+0x62>
				width = precision, precision = -1;
f0100ed3:	89 7d e0             	mov    %edi,-0x20(%ebp)
f0100ed6:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0100edb:	e9 7b ff ff ff       	jmp    f0100e5b <vprintfmt+0x62>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100ee0:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ee3:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0100ee5:	e9 71 ff ff ff       	jmp    f0100e5b <vprintfmt+0x62>

		case 'c':
            ch = va_arg(ap,int)+color;
f0100eea:	8b 45 14             	mov    0x14(%ebp),%eax
f0100eed:	8d 50 04             	lea    0x4(%eax),%edx
f0100ef0:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
f0100ef3:	83 ec 08             	sub    $0x8,%esp
f0100ef6:	ff 75 0c             	pushl  0xc(%ebp)
f0100ef9:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100efc:	03 08                	add    (%eax),%ecx
f0100efe:	51                   	push   %ecx
f0100eff:	ff 55 08             	call   *0x8(%ebp)
            color = 0;
			break;
f0100f02:	83 c4 10             	add    $0x10,%esp
			goto reswitch;

		case 'c':
            ch = va_arg(ap,int)+color;
			putch(ch, putdat);
            color = 0;
f0100f05:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
			break;
f0100f0c:	e9 14 ff ff ff       	jmp    f0100e25 <vprintfmt+0x2c>
        case 'C': 
        //自己补充的控制颜色的代码
            switch(va_arg(ap,int)){
f0100f11:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f14:	8d 48 04             	lea    0x4(%eax),%ecx
f0100f17:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0100f1a:	8b 00                	mov    (%eax),%eax
f0100f1c:	85 c0                	test   %eax,%eax
f0100f1e:	0f 84 2e ff ff ff    	je     f0100e52 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f24:	89 de                	mov    %ebx,%esi
f0100f26:	83 f8 01             	cmp    $0x1,%eax
f0100f29:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f2e:	b9 00 0a 00 00       	mov    $0xa00,%ecx
f0100f33:	0f 44 c1             	cmove  %ecx,%eax
f0100f36:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100f39:	e9 1d ff ff ff       	jmp    f0100e5b <vprintfmt+0x62>
            }

            goto reswitch;
		// error message
		case 'e':
			err = va_arg(ap, int);
f0100f3e:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f41:	8d 50 04             	lea    0x4(%eax),%edx
f0100f44:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f47:	8b 00                	mov    (%eax),%eax
f0100f49:	99                   	cltd   
f0100f4a:	31 d0                	xor    %edx,%eax
f0100f4c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100f4e:	83 f8 06             	cmp    $0x6,%eax
f0100f51:	7f 0b                	jg     f0100f5e <vprintfmt+0x165>
f0100f53:	8b 14 85 90 20 10 f0 	mov    -0xfefdf70(,%eax,4),%edx
f0100f5a:	85 d2                	test   %edx,%edx
f0100f5c:	75 19                	jne    f0100f77 <vprintfmt+0x17e>
				printfmt(putch, putdat, "error %d", err);
f0100f5e:	50                   	push   %eax
f0100f5f:	68 c1 1e 10 f0       	push   $0xf0101ec1
f0100f64:	ff 75 0c             	pushl  0xc(%ebp)
f0100f67:	ff 75 08             	pushl  0x8(%ebp)
f0100f6a:	e8 6d fe ff ff       	call   f0100ddc <printfmt>
f0100f6f:	83 c4 10             	add    $0x10,%esp
f0100f72:	e9 ae fe ff ff       	jmp    f0100e25 <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
f0100f77:	52                   	push   %edx
f0100f78:	68 ca 1e 10 f0       	push   $0xf0101eca
f0100f7d:	ff 75 0c             	pushl  0xc(%ebp)
f0100f80:	ff 75 08             	pushl  0x8(%ebp)
f0100f83:	e8 54 fe ff ff       	call   f0100ddc <printfmt>
f0100f88:	83 c4 10             	add    $0x10,%esp
f0100f8b:	e9 95 fe ff ff       	jmp    f0100e25 <vprintfmt+0x2c>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100f90:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f93:	8d 50 04             	lea    0x4(%eax),%edx
f0100f96:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f99:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f0100f9b:	85 f6                	test   %esi,%esi
f0100f9d:	b8 ba 1e 10 f0       	mov    $0xf0101eba,%eax
f0100fa2:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
f0100fa5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100fa9:	0f 8e 89 00 00 00    	jle    f0101038 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100faf:	83 ec 08             	sub    $0x8,%esp
f0100fb2:	57                   	push   %edi
f0100fb3:	56                   	push   %esi
f0100fb4:	e8 47 03 00 00       	call   f0101300 <strnlen>
f0100fb9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100fbc:	29 c1                	sub    %eax,%ecx
f0100fbe:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100fc1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0100fc4:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
f0100fc8:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0100fcb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100fce:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100fd1:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0100fd4:	89 cb                	mov    %ecx,%ebx
f0100fd6:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100fd8:	eb 0e                	jmp    f0100fe8 <vprintfmt+0x1ef>
					putch(padc, putdat);
f0100fda:	83 ec 08             	sub    $0x8,%esp
f0100fdd:	56                   	push   %esi
f0100fde:	57                   	push   %edi
f0100fdf:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100fe2:	83 eb 01             	sub    $0x1,%ebx
f0100fe5:	83 c4 10             	add    $0x10,%esp
f0100fe8:	85 db                	test   %ebx,%ebx
f0100fea:	7f ee                	jg     f0100fda <vprintfmt+0x1e1>
f0100fec:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0100fef:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100ff2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100ff5:	85 c9                	test   %ecx,%ecx
f0100ff7:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ffc:	0f 49 c1             	cmovns %ecx,%eax
f0100fff:	29 c1                	sub    %eax,%ecx
f0101001:	89 cb                	mov    %ecx,%ebx
f0101003:	eb 39                	jmp    f010103e <vprintfmt+0x245>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0101005:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101009:	74 1b                	je     f0101026 <vprintfmt+0x22d>
f010100b:	0f be c0             	movsbl %al,%eax
f010100e:	83 e8 20             	sub    $0x20,%eax
f0101011:	83 f8 5e             	cmp    $0x5e,%eax
f0101014:	76 10                	jbe    f0101026 <vprintfmt+0x22d>
					putch('?', putdat);
f0101016:	83 ec 08             	sub    $0x8,%esp
f0101019:	ff 75 0c             	pushl  0xc(%ebp)
f010101c:	6a 3f                	push   $0x3f
f010101e:	ff 55 08             	call   *0x8(%ebp)
f0101021:	83 c4 10             	add    $0x10,%esp
f0101024:	eb 0d                	jmp    f0101033 <vprintfmt+0x23a>
				else
					putch(ch, putdat);
f0101026:	83 ec 08             	sub    $0x8,%esp
f0101029:	ff 75 0c             	pushl  0xc(%ebp)
f010102c:	52                   	push   %edx
f010102d:	ff 55 08             	call   *0x8(%ebp)
f0101030:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101033:	83 eb 01             	sub    $0x1,%ebx
f0101036:	eb 06                	jmp    f010103e <vprintfmt+0x245>
f0101038:	89 5d 10             	mov    %ebx,0x10(%ebp)
f010103b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010103e:	83 c6 01             	add    $0x1,%esi
f0101041:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
f0101045:	0f be d0             	movsbl %al,%edx
f0101048:	85 d2                	test   %edx,%edx
f010104a:	74 25                	je     f0101071 <vprintfmt+0x278>
f010104c:	85 ff                	test   %edi,%edi
f010104e:	78 b5                	js     f0101005 <vprintfmt+0x20c>
f0101050:	83 ef 01             	sub    $0x1,%edi
f0101053:	79 b0                	jns    f0101005 <vprintfmt+0x20c>
f0101055:	89 d8                	mov    %ebx,%eax
f0101057:	8b 75 08             	mov    0x8(%ebp),%esi
f010105a:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010105d:	89 c3                	mov    %eax,%ebx
f010105f:	eb 16                	jmp    f0101077 <vprintfmt+0x27e>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0101061:	83 ec 08             	sub    $0x8,%esp
f0101064:	57                   	push   %edi
f0101065:	6a 20                	push   $0x20
f0101067:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0101069:	83 eb 01             	sub    $0x1,%ebx
f010106c:	83 c4 10             	add    $0x10,%esp
f010106f:	eb 06                	jmp    f0101077 <vprintfmt+0x27e>
f0101071:	8b 75 08             	mov    0x8(%ebp),%esi
f0101074:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101077:	85 db                	test   %ebx,%ebx
f0101079:	7f e6                	jg     f0101061 <vprintfmt+0x268>
f010107b:	89 75 08             	mov    %esi,0x8(%ebp)
f010107e:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0101081:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0101084:	e9 9c fd ff ff       	jmp    f0100e25 <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0101089:	83 fa 01             	cmp    $0x1,%edx
f010108c:	7e 10                	jle    f010109e <vprintfmt+0x2a5>
		return va_arg(*ap, long long);
f010108e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101091:	8d 50 08             	lea    0x8(%eax),%edx
f0101094:	89 55 14             	mov    %edx,0x14(%ebp)
f0101097:	8b 30                	mov    (%eax),%esi
f0101099:	8b 78 04             	mov    0x4(%eax),%edi
f010109c:	eb 26                	jmp    f01010c4 <vprintfmt+0x2cb>
	else if (lflag)
f010109e:	85 d2                	test   %edx,%edx
f01010a0:	74 12                	je     f01010b4 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f01010a2:	8b 45 14             	mov    0x14(%ebp),%eax
f01010a5:	8d 50 04             	lea    0x4(%eax),%edx
f01010a8:	89 55 14             	mov    %edx,0x14(%ebp)
f01010ab:	8b 30                	mov    (%eax),%esi
f01010ad:	89 f7                	mov    %esi,%edi
f01010af:	c1 ff 1f             	sar    $0x1f,%edi
f01010b2:	eb 10                	jmp    f01010c4 <vprintfmt+0x2cb>
	else
		return va_arg(*ap, int);
f01010b4:	8b 45 14             	mov    0x14(%ebp),%eax
f01010b7:	8d 50 04             	lea    0x4(%eax),%edx
f01010ba:	89 55 14             	mov    %edx,0x14(%ebp)
f01010bd:	8b 30                	mov    (%eax),%esi
f01010bf:	89 f7                	mov    %esi,%edi
f01010c1:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01010c4:	89 f0                	mov    %esi,%eax
f01010c6:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01010c8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01010cd:	85 ff                	test   %edi,%edi
f01010cf:	79 7b                	jns    f010114c <vprintfmt+0x353>
				putch('-', putdat);
f01010d1:	83 ec 08             	sub    $0x8,%esp
f01010d4:	ff 75 0c             	pushl  0xc(%ebp)
f01010d7:	6a 2d                	push   $0x2d
f01010d9:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f01010dc:	89 f0                	mov    %esi,%eax
f01010de:	89 fa                	mov    %edi,%edx
f01010e0:	f7 d8                	neg    %eax
f01010e2:	83 d2 00             	adc    $0x0,%edx
f01010e5:	f7 da                	neg    %edx
f01010e7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f01010ea:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01010ef:	eb 5b                	jmp    f010114c <vprintfmt+0x353>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01010f1:	8d 45 14             	lea    0x14(%ebp),%eax
f01010f4:	e8 8c fc ff ff       	call   f0100d85 <getuint>
			base = 10;
f01010f9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f01010fe:	eb 4c                	jmp    f010114c <vprintfmt+0x353>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f0101100:	8d 45 14             	lea    0x14(%ebp),%eax
f0101103:	e8 7d fc ff ff       	call   f0100d85 <getuint>
			base = 8;
f0101108:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
f010110d:	eb 3d                	jmp    f010114c <vprintfmt+0x353>
		// pointer
		case 'p':
			putch('0', putdat);
f010110f:	83 ec 08             	sub    $0x8,%esp
f0101112:	ff 75 0c             	pushl  0xc(%ebp)
f0101115:	6a 30                	push   $0x30
f0101117:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f010111a:	83 c4 08             	add    $0x8,%esp
f010111d:	ff 75 0c             	pushl  0xc(%ebp)
f0101120:	6a 78                	push   $0x78
f0101122:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0101125:	8b 45 14             	mov    0x14(%ebp),%eax
f0101128:	8d 50 04             	lea    0x4(%eax),%edx
f010112b:	89 55 14             	mov    %edx,0x14(%ebp)
            goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010112e:	8b 00                	mov    (%eax),%eax
f0101130:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0101135:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0101138:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f010113d:	eb 0d                	jmp    f010114c <vprintfmt+0x353>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010113f:	8d 45 14             	lea    0x14(%ebp),%eax
f0101142:	e8 3e fc ff ff       	call   f0100d85 <getuint>
			base = 16;
f0101147:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f010114c:	83 ec 0c             	sub    $0xc,%esp
f010114f:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
f0101153:	56                   	push   %esi
f0101154:	ff 75 e0             	pushl  -0x20(%ebp)
f0101157:	51                   	push   %ecx
f0101158:	52                   	push   %edx
f0101159:	50                   	push   %eax
f010115a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010115d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101160:	e8 71 fb ff ff       	call   f0100cd6 <printnum>
			break;
f0101165:	83 c4 20             	add    $0x20,%esp
f0101168:	e9 b8 fc ff ff       	jmp    f0100e25 <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010116d:	83 ec 08             	sub    $0x8,%esp
f0101170:	ff 75 0c             	pushl  0xc(%ebp)
f0101173:	51                   	push   %ecx
f0101174:	ff 55 08             	call   *0x8(%ebp)
			break;
f0101177:	83 c4 10             	add    $0x10,%esp
f010117a:	e9 a6 fc ff ff       	jmp    f0100e25 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010117f:	83 ec 08             	sub    $0x8,%esp
f0101182:	ff 75 0c             	pushl  0xc(%ebp)
f0101185:	6a 25                	push   $0x25
f0101187:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f010118a:	83 c4 10             	add    $0x10,%esp
f010118d:	89 f3                	mov    %esi,%ebx
f010118f:	eb 03                	jmp    f0101194 <vprintfmt+0x39b>
f0101191:	83 eb 01             	sub    $0x1,%ebx
f0101194:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f0101198:	75 f7                	jne    f0101191 <vprintfmt+0x398>
f010119a:	e9 86 fc ff ff       	jmp    f0100e25 <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
f010119f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011a2:	5b                   	pop    %ebx
f01011a3:	5e                   	pop    %esi
f01011a4:	5f                   	pop    %edi
f01011a5:	5d                   	pop    %ebp
f01011a6:	c3                   	ret    

f01011a7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01011a7:	55                   	push   %ebp
f01011a8:	89 e5                	mov    %esp,%ebp
f01011aa:	83 ec 18             	sub    $0x18,%esp
f01011ad:	8b 45 08             	mov    0x8(%ebp),%eax
f01011b0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01011b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01011b6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01011ba:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01011bd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01011c4:	85 c0                	test   %eax,%eax
f01011c6:	74 26                	je     f01011ee <vsnprintf+0x47>
f01011c8:	85 d2                	test   %edx,%edx
f01011ca:	7e 22                	jle    f01011ee <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01011cc:	ff 75 14             	pushl  0x14(%ebp)
f01011cf:	ff 75 10             	pushl  0x10(%ebp)
f01011d2:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01011d5:	50                   	push   %eax
f01011d6:	68 bf 0d 10 f0       	push   $0xf0100dbf
f01011db:	e8 19 fc ff ff       	call   f0100df9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01011e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01011e3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01011e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01011e9:	83 c4 10             	add    $0x10,%esp
f01011ec:	eb 05                	jmp    f01011f3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01011ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01011f3:	c9                   	leave  
f01011f4:	c3                   	ret    

f01011f5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01011f5:	55                   	push   %ebp
f01011f6:	89 e5                	mov    %esp,%ebp
f01011f8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01011fb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01011fe:	50                   	push   %eax
f01011ff:	ff 75 10             	pushl  0x10(%ebp)
f0101202:	ff 75 0c             	pushl  0xc(%ebp)
f0101205:	ff 75 08             	pushl  0x8(%ebp)
f0101208:	e8 9a ff ff ff       	call   f01011a7 <vsnprintf>
	va_end(ap);

	return rc;
}
f010120d:	c9                   	leave  
f010120e:	c3                   	ret    

f010120f <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f010120f:	55                   	push   %ebp
f0101210:	89 e5                	mov    %esp,%ebp
f0101212:	57                   	push   %edi
f0101213:	56                   	push   %esi
f0101214:	53                   	push   %ebx
f0101215:	83 ec 0c             	sub    $0xc,%esp
f0101218:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010121b:	85 c0                	test   %eax,%eax
f010121d:	74 11                	je     f0101230 <readline+0x21>
		cprintf("%s", prompt);
f010121f:	83 ec 08             	sub    $0x8,%esp
f0101222:	50                   	push   %eax
f0101223:	68 ca 1e 10 f0       	push   $0xf0101eca
f0101228:	e8 7f f7 ff ff       	call   f01009ac <cprintf>
f010122d:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0101230:	83 ec 0c             	sub    $0xc,%esp
f0101233:	6a 00                	push   $0x0
f0101235:	e8 59 f4 ff ff       	call   f0100693 <iscons>
f010123a:	89 c7                	mov    %eax,%edi
f010123c:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010123f:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0101244:	e8 39 f4 ff ff       	call   f0100682 <getchar>
f0101249:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010124b:	85 c0                	test   %eax,%eax
f010124d:	79 18                	jns    f0101267 <readline+0x58>
			cprintf("read error: %e\n", c);
f010124f:	83 ec 08             	sub    $0x8,%esp
f0101252:	50                   	push   %eax
f0101253:	68 ac 20 10 f0       	push   $0xf01020ac
f0101258:	e8 4f f7 ff ff       	call   f01009ac <cprintf>
			return NULL;
f010125d:	83 c4 10             	add    $0x10,%esp
f0101260:	b8 00 00 00 00       	mov    $0x0,%eax
f0101265:	eb 79                	jmp    f01012e0 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101267:	83 f8 08             	cmp    $0x8,%eax
f010126a:	0f 94 c2             	sete   %dl
f010126d:	83 f8 7f             	cmp    $0x7f,%eax
f0101270:	0f 94 c0             	sete   %al
f0101273:	08 c2                	or     %al,%dl
f0101275:	74 1a                	je     f0101291 <readline+0x82>
f0101277:	85 f6                	test   %esi,%esi
f0101279:	7e 16                	jle    f0101291 <readline+0x82>
			if (echoing)
f010127b:	85 ff                	test   %edi,%edi
f010127d:	74 0d                	je     f010128c <readline+0x7d>
				cputchar('\b');
f010127f:	83 ec 0c             	sub    $0xc,%esp
f0101282:	6a 08                	push   $0x8
f0101284:	e8 e9 f3 ff ff       	call   f0100672 <cputchar>
f0101289:	83 c4 10             	add    $0x10,%esp
			i--;
f010128c:	83 ee 01             	sub    $0x1,%esi
f010128f:	eb b3                	jmp    f0101244 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101291:	83 fb 1f             	cmp    $0x1f,%ebx
f0101294:	7e 23                	jle    f01012b9 <readline+0xaa>
f0101296:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010129c:	7f 1b                	jg     f01012b9 <readline+0xaa>
			if (echoing)
f010129e:	85 ff                	test   %edi,%edi
f01012a0:	74 0c                	je     f01012ae <readline+0x9f>
				cputchar(c);
f01012a2:	83 ec 0c             	sub    $0xc,%esp
f01012a5:	53                   	push   %ebx
f01012a6:	e8 c7 f3 ff ff       	call   f0100672 <cputchar>
f01012ab:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01012ae:	88 9e 40 25 11 f0    	mov    %bl,-0xfeedac0(%esi)
f01012b4:	8d 76 01             	lea    0x1(%esi),%esi
f01012b7:	eb 8b                	jmp    f0101244 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01012b9:	83 fb 0a             	cmp    $0xa,%ebx
f01012bc:	74 05                	je     f01012c3 <readline+0xb4>
f01012be:	83 fb 0d             	cmp    $0xd,%ebx
f01012c1:	75 81                	jne    f0101244 <readline+0x35>
			if (echoing)
f01012c3:	85 ff                	test   %edi,%edi
f01012c5:	74 0d                	je     f01012d4 <readline+0xc5>
				cputchar('\n');
f01012c7:	83 ec 0c             	sub    $0xc,%esp
f01012ca:	6a 0a                	push   $0xa
f01012cc:	e8 a1 f3 ff ff       	call   f0100672 <cputchar>
f01012d1:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01012d4:	c6 86 40 25 11 f0 00 	movb   $0x0,-0xfeedac0(%esi)
			return buf;
f01012db:	b8 40 25 11 f0       	mov    $0xf0112540,%eax
		}
	}
}
f01012e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012e3:	5b                   	pop    %ebx
f01012e4:	5e                   	pop    %esi
f01012e5:	5f                   	pop    %edi
f01012e6:	5d                   	pop    %ebp
f01012e7:	c3                   	ret    

f01012e8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01012e8:	55                   	push   %ebp
f01012e9:	89 e5                	mov    %esp,%ebp
f01012eb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01012ee:	b8 00 00 00 00       	mov    $0x0,%eax
f01012f3:	eb 03                	jmp    f01012f8 <strlen+0x10>
		n++;
f01012f5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01012f8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01012fc:	75 f7                	jne    f01012f5 <strlen+0xd>
		n++;
	return n;
}
f01012fe:	5d                   	pop    %ebp
f01012ff:	c3                   	ret    

f0101300 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101300:	55                   	push   %ebp
f0101301:	89 e5                	mov    %esp,%ebp
f0101303:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101306:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101309:	ba 00 00 00 00       	mov    $0x0,%edx
f010130e:	eb 03                	jmp    f0101313 <strnlen+0x13>
		n++;
f0101310:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101313:	39 c2                	cmp    %eax,%edx
f0101315:	74 08                	je     f010131f <strnlen+0x1f>
f0101317:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f010131b:	75 f3                	jne    f0101310 <strnlen+0x10>
f010131d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f010131f:	5d                   	pop    %ebp
f0101320:	c3                   	ret    

f0101321 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101321:	55                   	push   %ebp
f0101322:	89 e5                	mov    %esp,%ebp
f0101324:	53                   	push   %ebx
f0101325:	8b 45 08             	mov    0x8(%ebp),%eax
f0101328:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010132b:	89 c2                	mov    %eax,%edx
f010132d:	83 c2 01             	add    $0x1,%edx
f0101330:	83 c1 01             	add    $0x1,%ecx
f0101333:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0101337:	88 5a ff             	mov    %bl,-0x1(%edx)
f010133a:	84 db                	test   %bl,%bl
f010133c:	75 ef                	jne    f010132d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010133e:	5b                   	pop    %ebx
f010133f:	5d                   	pop    %ebp
f0101340:	c3                   	ret    

f0101341 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0101341:	55                   	push   %ebp
f0101342:	89 e5                	mov    %esp,%ebp
f0101344:	53                   	push   %ebx
f0101345:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101348:	53                   	push   %ebx
f0101349:	e8 9a ff ff ff       	call   f01012e8 <strlen>
f010134e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0101351:	ff 75 0c             	pushl  0xc(%ebp)
f0101354:	01 d8                	add    %ebx,%eax
f0101356:	50                   	push   %eax
f0101357:	e8 c5 ff ff ff       	call   f0101321 <strcpy>
	return dst;
}
f010135c:	89 d8                	mov    %ebx,%eax
f010135e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101361:	c9                   	leave  
f0101362:	c3                   	ret    

f0101363 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101363:	55                   	push   %ebp
f0101364:	89 e5                	mov    %esp,%ebp
f0101366:	56                   	push   %esi
f0101367:	53                   	push   %ebx
f0101368:	8b 75 08             	mov    0x8(%ebp),%esi
f010136b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010136e:	89 f3                	mov    %esi,%ebx
f0101370:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101373:	89 f2                	mov    %esi,%edx
f0101375:	eb 0f                	jmp    f0101386 <strncpy+0x23>
		*dst++ = *src;
f0101377:	83 c2 01             	add    $0x1,%edx
f010137a:	0f b6 01             	movzbl (%ecx),%eax
f010137d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101380:	80 39 01             	cmpb   $0x1,(%ecx)
f0101383:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101386:	39 da                	cmp    %ebx,%edx
f0101388:	75 ed                	jne    f0101377 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010138a:	89 f0                	mov    %esi,%eax
f010138c:	5b                   	pop    %ebx
f010138d:	5e                   	pop    %esi
f010138e:	5d                   	pop    %ebp
f010138f:	c3                   	ret    

f0101390 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101390:	55                   	push   %ebp
f0101391:	89 e5                	mov    %esp,%ebp
f0101393:	56                   	push   %esi
f0101394:	53                   	push   %ebx
f0101395:	8b 75 08             	mov    0x8(%ebp),%esi
f0101398:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010139b:	8b 55 10             	mov    0x10(%ebp),%edx
f010139e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01013a0:	85 d2                	test   %edx,%edx
f01013a2:	74 21                	je     f01013c5 <strlcpy+0x35>
f01013a4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01013a8:	89 f2                	mov    %esi,%edx
f01013aa:	eb 09                	jmp    f01013b5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01013ac:	83 c2 01             	add    $0x1,%edx
f01013af:	83 c1 01             	add    $0x1,%ecx
f01013b2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01013b5:	39 c2                	cmp    %eax,%edx
f01013b7:	74 09                	je     f01013c2 <strlcpy+0x32>
f01013b9:	0f b6 19             	movzbl (%ecx),%ebx
f01013bc:	84 db                	test   %bl,%bl
f01013be:	75 ec                	jne    f01013ac <strlcpy+0x1c>
f01013c0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01013c2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01013c5:	29 f0                	sub    %esi,%eax
}
f01013c7:	5b                   	pop    %ebx
f01013c8:	5e                   	pop    %esi
f01013c9:	5d                   	pop    %ebp
f01013ca:	c3                   	ret    

f01013cb <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01013cb:	55                   	push   %ebp
f01013cc:	89 e5                	mov    %esp,%ebp
f01013ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01013d1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01013d4:	eb 06                	jmp    f01013dc <strcmp+0x11>
		p++, q++;
f01013d6:	83 c1 01             	add    $0x1,%ecx
f01013d9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01013dc:	0f b6 01             	movzbl (%ecx),%eax
f01013df:	84 c0                	test   %al,%al
f01013e1:	74 04                	je     f01013e7 <strcmp+0x1c>
f01013e3:	3a 02                	cmp    (%edx),%al
f01013e5:	74 ef                	je     f01013d6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01013e7:	0f b6 c0             	movzbl %al,%eax
f01013ea:	0f b6 12             	movzbl (%edx),%edx
f01013ed:	29 d0                	sub    %edx,%eax
}
f01013ef:	5d                   	pop    %ebp
f01013f0:	c3                   	ret    

f01013f1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01013f1:	55                   	push   %ebp
f01013f2:	89 e5                	mov    %esp,%ebp
f01013f4:	53                   	push   %ebx
f01013f5:	8b 45 08             	mov    0x8(%ebp),%eax
f01013f8:	8b 55 0c             	mov    0xc(%ebp),%edx
f01013fb:	89 c3                	mov    %eax,%ebx
f01013fd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0101400:	eb 06                	jmp    f0101408 <strncmp+0x17>
		n--, p++, q++;
f0101402:	83 c0 01             	add    $0x1,%eax
f0101405:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0101408:	39 d8                	cmp    %ebx,%eax
f010140a:	74 15                	je     f0101421 <strncmp+0x30>
f010140c:	0f b6 08             	movzbl (%eax),%ecx
f010140f:	84 c9                	test   %cl,%cl
f0101411:	74 04                	je     f0101417 <strncmp+0x26>
f0101413:	3a 0a                	cmp    (%edx),%cl
f0101415:	74 eb                	je     f0101402 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101417:	0f b6 00             	movzbl (%eax),%eax
f010141a:	0f b6 12             	movzbl (%edx),%edx
f010141d:	29 d0                	sub    %edx,%eax
f010141f:	eb 05                	jmp    f0101426 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0101421:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101426:	5b                   	pop    %ebx
f0101427:	5d                   	pop    %ebp
f0101428:	c3                   	ret    

f0101429 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101429:	55                   	push   %ebp
f010142a:	89 e5                	mov    %esp,%ebp
f010142c:	8b 45 08             	mov    0x8(%ebp),%eax
f010142f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101433:	eb 07                	jmp    f010143c <strchr+0x13>
		if (*s == c)
f0101435:	38 ca                	cmp    %cl,%dl
f0101437:	74 0f                	je     f0101448 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0101439:	83 c0 01             	add    $0x1,%eax
f010143c:	0f b6 10             	movzbl (%eax),%edx
f010143f:	84 d2                	test   %dl,%dl
f0101441:	75 f2                	jne    f0101435 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0101443:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101448:	5d                   	pop    %ebp
f0101449:	c3                   	ret    

f010144a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010144a:	55                   	push   %ebp
f010144b:	89 e5                	mov    %esp,%ebp
f010144d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101450:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101454:	eb 03                	jmp    f0101459 <strfind+0xf>
f0101456:	83 c0 01             	add    $0x1,%eax
f0101459:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010145c:	38 ca                	cmp    %cl,%dl
f010145e:	74 04                	je     f0101464 <strfind+0x1a>
f0101460:	84 d2                	test   %dl,%dl
f0101462:	75 f2                	jne    f0101456 <strfind+0xc>
			break;
	return (char *) s;
}
f0101464:	5d                   	pop    %ebp
f0101465:	c3                   	ret    

f0101466 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101466:	55                   	push   %ebp
f0101467:	89 e5                	mov    %esp,%ebp
f0101469:	57                   	push   %edi
f010146a:	56                   	push   %esi
f010146b:	53                   	push   %ebx
f010146c:	8b 7d 08             	mov    0x8(%ebp),%edi
f010146f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101472:	85 c9                	test   %ecx,%ecx
f0101474:	74 36                	je     f01014ac <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101476:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010147c:	75 28                	jne    f01014a6 <memset+0x40>
f010147e:	f6 c1 03             	test   $0x3,%cl
f0101481:	75 23                	jne    f01014a6 <memset+0x40>
		c &= 0xFF;
f0101483:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101487:	89 d3                	mov    %edx,%ebx
f0101489:	c1 e3 08             	shl    $0x8,%ebx
f010148c:	89 d6                	mov    %edx,%esi
f010148e:	c1 e6 18             	shl    $0x18,%esi
f0101491:	89 d0                	mov    %edx,%eax
f0101493:	c1 e0 10             	shl    $0x10,%eax
f0101496:	09 f0                	or     %esi,%eax
f0101498:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f010149a:	89 d8                	mov    %ebx,%eax
f010149c:	09 d0                	or     %edx,%eax
f010149e:	c1 e9 02             	shr    $0x2,%ecx
f01014a1:	fc                   	cld    
f01014a2:	f3 ab                	rep stos %eax,%es:(%edi)
f01014a4:	eb 06                	jmp    f01014ac <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01014a6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01014a9:	fc                   	cld    
f01014aa:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01014ac:	89 f8                	mov    %edi,%eax
f01014ae:	5b                   	pop    %ebx
f01014af:	5e                   	pop    %esi
f01014b0:	5f                   	pop    %edi
f01014b1:	5d                   	pop    %ebp
f01014b2:	c3                   	ret    

f01014b3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01014b3:	55                   	push   %ebp
f01014b4:	89 e5                	mov    %esp,%ebp
f01014b6:	57                   	push   %edi
f01014b7:	56                   	push   %esi
f01014b8:	8b 45 08             	mov    0x8(%ebp),%eax
f01014bb:	8b 75 0c             	mov    0xc(%ebp),%esi
f01014be:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01014c1:	39 c6                	cmp    %eax,%esi
f01014c3:	73 35                	jae    f01014fa <memmove+0x47>
f01014c5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01014c8:	39 d0                	cmp    %edx,%eax
f01014ca:	73 2e                	jae    f01014fa <memmove+0x47>
		s += n;
		d += n;
f01014cc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01014cf:	89 d6                	mov    %edx,%esi
f01014d1:	09 fe                	or     %edi,%esi
f01014d3:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01014d9:	75 13                	jne    f01014ee <memmove+0x3b>
f01014db:	f6 c1 03             	test   $0x3,%cl
f01014de:	75 0e                	jne    f01014ee <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01014e0:	83 ef 04             	sub    $0x4,%edi
f01014e3:	8d 72 fc             	lea    -0x4(%edx),%esi
f01014e6:	c1 e9 02             	shr    $0x2,%ecx
f01014e9:	fd                   	std    
f01014ea:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01014ec:	eb 09                	jmp    f01014f7 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01014ee:	83 ef 01             	sub    $0x1,%edi
f01014f1:	8d 72 ff             	lea    -0x1(%edx),%esi
f01014f4:	fd                   	std    
f01014f5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01014f7:	fc                   	cld    
f01014f8:	eb 1d                	jmp    f0101517 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01014fa:	89 f2                	mov    %esi,%edx
f01014fc:	09 c2                	or     %eax,%edx
f01014fe:	f6 c2 03             	test   $0x3,%dl
f0101501:	75 0f                	jne    f0101512 <memmove+0x5f>
f0101503:	f6 c1 03             	test   $0x3,%cl
f0101506:	75 0a                	jne    f0101512 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0101508:	c1 e9 02             	shr    $0x2,%ecx
f010150b:	89 c7                	mov    %eax,%edi
f010150d:	fc                   	cld    
f010150e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101510:	eb 05                	jmp    f0101517 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101512:	89 c7                	mov    %eax,%edi
f0101514:	fc                   	cld    
f0101515:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101517:	5e                   	pop    %esi
f0101518:	5f                   	pop    %edi
f0101519:	5d                   	pop    %ebp
f010151a:	c3                   	ret    

f010151b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010151b:	55                   	push   %ebp
f010151c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010151e:	ff 75 10             	pushl  0x10(%ebp)
f0101521:	ff 75 0c             	pushl  0xc(%ebp)
f0101524:	ff 75 08             	pushl  0x8(%ebp)
f0101527:	e8 87 ff ff ff       	call   f01014b3 <memmove>
}
f010152c:	c9                   	leave  
f010152d:	c3                   	ret    

f010152e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010152e:	55                   	push   %ebp
f010152f:	89 e5                	mov    %esp,%ebp
f0101531:	56                   	push   %esi
f0101532:	53                   	push   %ebx
f0101533:	8b 45 08             	mov    0x8(%ebp),%eax
f0101536:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101539:	89 c6                	mov    %eax,%esi
f010153b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010153e:	eb 1a                	jmp    f010155a <memcmp+0x2c>
		if (*s1 != *s2)
f0101540:	0f b6 08             	movzbl (%eax),%ecx
f0101543:	0f b6 1a             	movzbl (%edx),%ebx
f0101546:	38 d9                	cmp    %bl,%cl
f0101548:	74 0a                	je     f0101554 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f010154a:	0f b6 c1             	movzbl %cl,%eax
f010154d:	0f b6 db             	movzbl %bl,%ebx
f0101550:	29 d8                	sub    %ebx,%eax
f0101552:	eb 0f                	jmp    f0101563 <memcmp+0x35>
		s1++, s2++;
f0101554:	83 c0 01             	add    $0x1,%eax
f0101557:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010155a:	39 f0                	cmp    %esi,%eax
f010155c:	75 e2                	jne    f0101540 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010155e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101563:	5b                   	pop    %ebx
f0101564:	5e                   	pop    %esi
f0101565:	5d                   	pop    %ebp
f0101566:	c3                   	ret    

f0101567 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101567:	55                   	push   %ebp
f0101568:	89 e5                	mov    %esp,%ebp
f010156a:	53                   	push   %ebx
f010156b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010156e:	89 c1                	mov    %eax,%ecx
f0101570:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0101573:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101577:	eb 0a                	jmp    f0101583 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101579:	0f b6 10             	movzbl (%eax),%edx
f010157c:	39 da                	cmp    %ebx,%edx
f010157e:	74 07                	je     f0101587 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101580:	83 c0 01             	add    $0x1,%eax
f0101583:	39 c8                	cmp    %ecx,%eax
f0101585:	72 f2                	jb     f0101579 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101587:	5b                   	pop    %ebx
f0101588:	5d                   	pop    %ebp
f0101589:	c3                   	ret    

f010158a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010158a:	55                   	push   %ebp
f010158b:	89 e5                	mov    %esp,%ebp
f010158d:	57                   	push   %edi
f010158e:	56                   	push   %esi
f010158f:	53                   	push   %ebx
f0101590:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101593:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101596:	eb 03                	jmp    f010159b <strtol+0x11>
		s++;
f0101598:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010159b:	0f b6 01             	movzbl (%ecx),%eax
f010159e:	3c 20                	cmp    $0x20,%al
f01015a0:	74 f6                	je     f0101598 <strtol+0xe>
f01015a2:	3c 09                	cmp    $0x9,%al
f01015a4:	74 f2                	je     f0101598 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01015a6:	3c 2b                	cmp    $0x2b,%al
f01015a8:	75 0a                	jne    f01015b4 <strtol+0x2a>
		s++;
f01015aa:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01015ad:	bf 00 00 00 00       	mov    $0x0,%edi
f01015b2:	eb 11                	jmp    f01015c5 <strtol+0x3b>
f01015b4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01015b9:	3c 2d                	cmp    $0x2d,%al
f01015bb:	75 08                	jne    f01015c5 <strtol+0x3b>
		s++, neg = 1;
f01015bd:	83 c1 01             	add    $0x1,%ecx
f01015c0:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01015c5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01015cb:	75 15                	jne    f01015e2 <strtol+0x58>
f01015cd:	80 39 30             	cmpb   $0x30,(%ecx)
f01015d0:	75 10                	jne    f01015e2 <strtol+0x58>
f01015d2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01015d6:	75 7c                	jne    f0101654 <strtol+0xca>
		s += 2, base = 16;
f01015d8:	83 c1 02             	add    $0x2,%ecx
f01015db:	bb 10 00 00 00       	mov    $0x10,%ebx
f01015e0:	eb 16                	jmp    f01015f8 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01015e2:	85 db                	test   %ebx,%ebx
f01015e4:	75 12                	jne    f01015f8 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01015e6:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01015eb:	80 39 30             	cmpb   $0x30,(%ecx)
f01015ee:	75 08                	jne    f01015f8 <strtol+0x6e>
		s++, base = 8;
f01015f0:	83 c1 01             	add    $0x1,%ecx
f01015f3:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01015f8:	b8 00 00 00 00       	mov    $0x0,%eax
f01015fd:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0101600:	0f b6 11             	movzbl (%ecx),%edx
f0101603:	8d 72 d0             	lea    -0x30(%edx),%esi
f0101606:	89 f3                	mov    %esi,%ebx
f0101608:	80 fb 09             	cmp    $0x9,%bl
f010160b:	77 08                	ja     f0101615 <strtol+0x8b>
			dig = *s - '0';
f010160d:	0f be d2             	movsbl %dl,%edx
f0101610:	83 ea 30             	sub    $0x30,%edx
f0101613:	eb 22                	jmp    f0101637 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0101615:	8d 72 9f             	lea    -0x61(%edx),%esi
f0101618:	89 f3                	mov    %esi,%ebx
f010161a:	80 fb 19             	cmp    $0x19,%bl
f010161d:	77 08                	ja     f0101627 <strtol+0x9d>
			dig = *s - 'a' + 10;
f010161f:	0f be d2             	movsbl %dl,%edx
f0101622:	83 ea 57             	sub    $0x57,%edx
f0101625:	eb 10                	jmp    f0101637 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0101627:	8d 72 bf             	lea    -0x41(%edx),%esi
f010162a:	89 f3                	mov    %esi,%ebx
f010162c:	80 fb 19             	cmp    $0x19,%bl
f010162f:	77 16                	ja     f0101647 <strtol+0xbd>
			dig = *s - 'A' + 10;
f0101631:	0f be d2             	movsbl %dl,%edx
f0101634:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0101637:	3b 55 10             	cmp    0x10(%ebp),%edx
f010163a:	7d 0b                	jge    f0101647 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f010163c:	83 c1 01             	add    $0x1,%ecx
f010163f:	0f af 45 10          	imul   0x10(%ebp),%eax
f0101643:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0101645:	eb b9                	jmp    f0101600 <strtol+0x76>

	if (endptr)
f0101647:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010164b:	74 0d                	je     f010165a <strtol+0xd0>
		*endptr = (char *) s;
f010164d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101650:	89 0e                	mov    %ecx,(%esi)
f0101652:	eb 06                	jmp    f010165a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101654:	85 db                	test   %ebx,%ebx
f0101656:	74 98                	je     f01015f0 <strtol+0x66>
f0101658:	eb 9e                	jmp    f01015f8 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f010165a:	89 c2                	mov    %eax,%edx
f010165c:	f7 da                	neg    %edx
f010165e:	85 ff                	test   %edi,%edi
f0101660:	0f 45 c2             	cmovne %edx,%eax
}
f0101663:	5b                   	pop    %ebx
f0101664:	5e                   	pop    %esi
f0101665:	5f                   	pop    %edi
f0101666:	5d                   	pop    %ebp
f0101667:	c3                   	ret    
f0101668:	66 90                	xchg   %ax,%ax
f010166a:	66 90                	xchg   %ax,%ax
f010166c:	66 90                	xchg   %ax,%ax
f010166e:	66 90                	xchg   %ax,%ax

f0101670 <__udivdi3>:
f0101670:	55                   	push   %ebp
f0101671:	57                   	push   %edi
f0101672:	56                   	push   %esi
f0101673:	53                   	push   %ebx
f0101674:	83 ec 1c             	sub    $0x1c,%esp
f0101677:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010167b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010167f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0101683:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101687:	85 f6                	test   %esi,%esi
f0101689:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010168d:	89 ca                	mov    %ecx,%edx
f010168f:	89 f8                	mov    %edi,%eax
f0101691:	75 3d                	jne    f01016d0 <__udivdi3+0x60>
f0101693:	39 cf                	cmp    %ecx,%edi
f0101695:	0f 87 c5 00 00 00    	ja     f0101760 <__udivdi3+0xf0>
f010169b:	85 ff                	test   %edi,%edi
f010169d:	89 fd                	mov    %edi,%ebp
f010169f:	75 0b                	jne    f01016ac <__udivdi3+0x3c>
f01016a1:	b8 01 00 00 00       	mov    $0x1,%eax
f01016a6:	31 d2                	xor    %edx,%edx
f01016a8:	f7 f7                	div    %edi
f01016aa:	89 c5                	mov    %eax,%ebp
f01016ac:	89 c8                	mov    %ecx,%eax
f01016ae:	31 d2                	xor    %edx,%edx
f01016b0:	f7 f5                	div    %ebp
f01016b2:	89 c1                	mov    %eax,%ecx
f01016b4:	89 d8                	mov    %ebx,%eax
f01016b6:	89 cf                	mov    %ecx,%edi
f01016b8:	f7 f5                	div    %ebp
f01016ba:	89 c3                	mov    %eax,%ebx
f01016bc:	89 d8                	mov    %ebx,%eax
f01016be:	89 fa                	mov    %edi,%edx
f01016c0:	83 c4 1c             	add    $0x1c,%esp
f01016c3:	5b                   	pop    %ebx
f01016c4:	5e                   	pop    %esi
f01016c5:	5f                   	pop    %edi
f01016c6:	5d                   	pop    %ebp
f01016c7:	c3                   	ret    
f01016c8:	90                   	nop
f01016c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01016d0:	39 ce                	cmp    %ecx,%esi
f01016d2:	77 74                	ja     f0101748 <__udivdi3+0xd8>
f01016d4:	0f bd fe             	bsr    %esi,%edi
f01016d7:	83 f7 1f             	xor    $0x1f,%edi
f01016da:	0f 84 98 00 00 00    	je     f0101778 <__udivdi3+0x108>
f01016e0:	bb 20 00 00 00       	mov    $0x20,%ebx
f01016e5:	89 f9                	mov    %edi,%ecx
f01016e7:	89 c5                	mov    %eax,%ebp
f01016e9:	29 fb                	sub    %edi,%ebx
f01016eb:	d3 e6                	shl    %cl,%esi
f01016ed:	89 d9                	mov    %ebx,%ecx
f01016ef:	d3 ed                	shr    %cl,%ebp
f01016f1:	89 f9                	mov    %edi,%ecx
f01016f3:	d3 e0                	shl    %cl,%eax
f01016f5:	09 ee                	or     %ebp,%esi
f01016f7:	89 d9                	mov    %ebx,%ecx
f01016f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01016fd:	89 d5                	mov    %edx,%ebp
f01016ff:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101703:	d3 ed                	shr    %cl,%ebp
f0101705:	89 f9                	mov    %edi,%ecx
f0101707:	d3 e2                	shl    %cl,%edx
f0101709:	89 d9                	mov    %ebx,%ecx
f010170b:	d3 e8                	shr    %cl,%eax
f010170d:	09 c2                	or     %eax,%edx
f010170f:	89 d0                	mov    %edx,%eax
f0101711:	89 ea                	mov    %ebp,%edx
f0101713:	f7 f6                	div    %esi
f0101715:	89 d5                	mov    %edx,%ebp
f0101717:	89 c3                	mov    %eax,%ebx
f0101719:	f7 64 24 0c          	mull   0xc(%esp)
f010171d:	39 d5                	cmp    %edx,%ebp
f010171f:	72 10                	jb     f0101731 <__udivdi3+0xc1>
f0101721:	8b 74 24 08          	mov    0x8(%esp),%esi
f0101725:	89 f9                	mov    %edi,%ecx
f0101727:	d3 e6                	shl    %cl,%esi
f0101729:	39 c6                	cmp    %eax,%esi
f010172b:	73 07                	jae    f0101734 <__udivdi3+0xc4>
f010172d:	39 d5                	cmp    %edx,%ebp
f010172f:	75 03                	jne    f0101734 <__udivdi3+0xc4>
f0101731:	83 eb 01             	sub    $0x1,%ebx
f0101734:	31 ff                	xor    %edi,%edi
f0101736:	89 d8                	mov    %ebx,%eax
f0101738:	89 fa                	mov    %edi,%edx
f010173a:	83 c4 1c             	add    $0x1c,%esp
f010173d:	5b                   	pop    %ebx
f010173e:	5e                   	pop    %esi
f010173f:	5f                   	pop    %edi
f0101740:	5d                   	pop    %ebp
f0101741:	c3                   	ret    
f0101742:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101748:	31 ff                	xor    %edi,%edi
f010174a:	31 db                	xor    %ebx,%ebx
f010174c:	89 d8                	mov    %ebx,%eax
f010174e:	89 fa                	mov    %edi,%edx
f0101750:	83 c4 1c             	add    $0x1c,%esp
f0101753:	5b                   	pop    %ebx
f0101754:	5e                   	pop    %esi
f0101755:	5f                   	pop    %edi
f0101756:	5d                   	pop    %ebp
f0101757:	c3                   	ret    
f0101758:	90                   	nop
f0101759:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101760:	89 d8                	mov    %ebx,%eax
f0101762:	f7 f7                	div    %edi
f0101764:	31 ff                	xor    %edi,%edi
f0101766:	89 c3                	mov    %eax,%ebx
f0101768:	89 d8                	mov    %ebx,%eax
f010176a:	89 fa                	mov    %edi,%edx
f010176c:	83 c4 1c             	add    $0x1c,%esp
f010176f:	5b                   	pop    %ebx
f0101770:	5e                   	pop    %esi
f0101771:	5f                   	pop    %edi
f0101772:	5d                   	pop    %ebp
f0101773:	c3                   	ret    
f0101774:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101778:	39 ce                	cmp    %ecx,%esi
f010177a:	72 0c                	jb     f0101788 <__udivdi3+0x118>
f010177c:	31 db                	xor    %ebx,%ebx
f010177e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0101782:	0f 87 34 ff ff ff    	ja     f01016bc <__udivdi3+0x4c>
f0101788:	bb 01 00 00 00       	mov    $0x1,%ebx
f010178d:	e9 2a ff ff ff       	jmp    f01016bc <__udivdi3+0x4c>
f0101792:	66 90                	xchg   %ax,%ax
f0101794:	66 90                	xchg   %ax,%ax
f0101796:	66 90                	xchg   %ax,%ax
f0101798:	66 90                	xchg   %ax,%ax
f010179a:	66 90                	xchg   %ax,%ax
f010179c:	66 90                	xchg   %ax,%ax
f010179e:	66 90                	xchg   %ax,%ax

f01017a0 <__umoddi3>:
f01017a0:	55                   	push   %ebp
f01017a1:	57                   	push   %edi
f01017a2:	56                   	push   %esi
f01017a3:	53                   	push   %ebx
f01017a4:	83 ec 1c             	sub    $0x1c,%esp
f01017a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01017ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f01017af:	8b 74 24 34          	mov    0x34(%esp),%esi
f01017b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01017b7:	85 d2                	test   %edx,%edx
f01017b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01017bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01017c1:	89 f3                	mov    %esi,%ebx
f01017c3:	89 3c 24             	mov    %edi,(%esp)
f01017c6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01017ca:	75 1c                	jne    f01017e8 <__umoddi3+0x48>
f01017cc:	39 f7                	cmp    %esi,%edi
f01017ce:	76 50                	jbe    f0101820 <__umoddi3+0x80>
f01017d0:	89 c8                	mov    %ecx,%eax
f01017d2:	89 f2                	mov    %esi,%edx
f01017d4:	f7 f7                	div    %edi
f01017d6:	89 d0                	mov    %edx,%eax
f01017d8:	31 d2                	xor    %edx,%edx
f01017da:	83 c4 1c             	add    $0x1c,%esp
f01017dd:	5b                   	pop    %ebx
f01017de:	5e                   	pop    %esi
f01017df:	5f                   	pop    %edi
f01017e0:	5d                   	pop    %ebp
f01017e1:	c3                   	ret    
f01017e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01017e8:	39 f2                	cmp    %esi,%edx
f01017ea:	89 d0                	mov    %edx,%eax
f01017ec:	77 52                	ja     f0101840 <__umoddi3+0xa0>
f01017ee:	0f bd ea             	bsr    %edx,%ebp
f01017f1:	83 f5 1f             	xor    $0x1f,%ebp
f01017f4:	75 5a                	jne    f0101850 <__umoddi3+0xb0>
f01017f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
f01017fa:	0f 82 e0 00 00 00    	jb     f01018e0 <__umoddi3+0x140>
f0101800:	39 0c 24             	cmp    %ecx,(%esp)
f0101803:	0f 86 d7 00 00 00    	jbe    f01018e0 <__umoddi3+0x140>
f0101809:	8b 44 24 08          	mov    0x8(%esp),%eax
f010180d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101811:	83 c4 1c             	add    $0x1c,%esp
f0101814:	5b                   	pop    %ebx
f0101815:	5e                   	pop    %esi
f0101816:	5f                   	pop    %edi
f0101817:	5d                   	pop    %ebp
f0101818:	c3                   	ret    
f0101819:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101820:	85 ff                	test   %edi,%edi
f0101822:	89 fd                	mov    %edi,%ebp
f0101824:	75 0b                	jne    f0101831 <__umoddi3+0x91>
f0101826:	b8 01 00 00 00       	mov    $0x1,%eax
f010182b:	31 d2                	xor    %edx,%edx
f010182d:	f7 f7                	div    %edi
f010182f:	89 c5                	mov    %eax,%ebp
f0101831:	89 f0                	mov    %esi,%eax
f0101833:	31 d2                	xor    %edx,%edx
f0101835:	f7 f5                	div    %ebp
f0101837:	89 c8                	mov    %ecx,%eax
f0101839:	f7 f5                	div    %ebp
f010183b:	89 d0                	mov    %edx,%eax
f010183d:	eb 99                	jmp    f01017d8 <__umoddi3+0x38>
f010183f:	90                   	nop
f0101840:	89 c8                	mov    %ecx,%eax
f0101842:	89 f2                	mov    %esi,%edx
f0101844:	83 c4 1c             	add    $0x1c,%esp
f0101847:	5b                   	pop    %ebx
f0101848:	5e                   	pop    %esi
f0101849:	5f                   	pop    %edi
f010184a:	5d                   	pop    %ebp
f010184b:	c3                   	ret    
f010184c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101850:	8b 34 24             	mov    (%esp),%esi
f0101853:	bf 20 00 00 00       	mov    $0x20,%edi
f0101858:	89 e9                	mov    %ebp,%ecx
f010185a:	29 ef                	sub    %ebp,%edi
f010185c:	d3 e0                	shl    %cl,%eax
f010185e:	89 f9                	mov    %edi,%ecx
f0101860:	89 f2                	mov    %esi,%edx
f0101862:	d3 ea                	shr    %cl,%edx
f0101864:	89 e9                	mov    %ebp,%ecx
f0101866:	09 c2                	or     %eax,%edx
f0101868:	89 d8                	mov    %ebx,%eax
f010186a:	89 14 24             	mov    %edx,(%esp)
f010186d:	89 f2                	mov    %esi,%edx
f010186f:	d3 e2                	shl    %cl,%edx
f0101871:	89 f9                	mov    %edi,%ecx
f0101873:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101877:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010187b:	d3 e8                	shr    %cl,%eax
f010187d:	89 e9                	mov    %ebp,%ecx
f010187f:	89 c6                	mov    %eax,%esi
f0101881:	d3 e3                	shl    %cl,%ebx
f0101883:	89 f9                	mov    %edi,%ecx
f0101885:	89 d0                	mov    %edx,%eax
f0101887:	d3 e8                	shr    %cl,%eax
f0101889:	89 e9                	mov    %ebp,%ecx
f010188b:	09 d8                	or     %ebx,%eax
f010188d:	89 d3                	mov    %edx,%ebx
f010188f:	89 f2                	mov    %esi,%edx
f0101891:	f7 34 24             	divl   (%esp)
f0101894:	89 d6                	mov    %edx,%esi
f0101896:	d3 e3                	shl    %cl,%ebx
f0101898:	f7 64 24 04          	mull   0x4(%esp)
f010189c:	39 d6                	cmp    %edx,%esi
f010189e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01018a2:	89 d1                	mov    %edx,%ecx
f01018a4:	89 c3                	mov    %eax,%ebx
f01018a6:	72 08                	jb     f01018b0 <__umoddi3+0x110>
f01018a8:	75 11                	jne    f01018bb <__umoddi3+0x11b>
f01018aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01018ae:	73 0b                	jae    f01018bb <__umoddi3+0x11b>
f01018b0:	2b 44 24 04          	sub    0x4(%esp),%eax
f01018b4:	1b 14 24             	sbb    (%esp),%edx
f01018b7:	89 d1                	mov    %edx,%ecx
f01018b9:	89 c3                	mov    %eax,%ebx
f01018bb:	8b 54 24 08          	mov    0x8(%esp),%edx
f01018bf:	29 da                	sub    %ebx,%edx
f01018c1:	19 ce                	sbb    %ecx,%esi
f01018c3:	89 f9                	mov    %edi,%ecx
f01018c5:	89 f0                	mov    %esi,%eax
f01018c7:	d3 e0                	shl    %cl,%eax
f01018c9:	89 e9                	mov    %ebp,%ecx
f01018cb:	d3 ea                	shr    %cl,%edx
f01018cd:	89 e9                	mov    %ebp,%ecx
f01018cf:	d3 ee                	shr    %cl,%esi
f01018d1:	09 d0                	or     %edx,%eax
f01018d3:	89 f2                	mov    %esi,%edx
f01018d5:	83 c4 1c             	add    $0x1c,%esp
f01018d8:	5b                   	pop    %ebx
f01018d9:	5e                   	pop    %esi
f01018da:	5f                   	pop    %edi
f01018db:	5d                   	pop    %ebp
f01018dc:	c3                   	ret    
f01018dd:	8d 76 00             	lea    0x0(%esi),%esi
f01018e0:	29 f9                	sub    %edi,%ecx
f01018e2:	19 d6                	sbb    %edx,%esi
f01018e4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01018e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01018ec:	e9 18 ff ff ff       	jmp    f0101809 <__umoddi3+0x69>
