
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
f0100015:	b8 00 50 11 00       	mov    $0x115000,%eax
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
f0100034:	bc 00 50 11 f0       	mov    $0xf0115000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 58 00 00 00       	call   f0100096 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/pmap.h>
#include <kern/kclock.h>

// Test the stack backtrace function (lab 1 only)
int test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 0c             	sub    $0xc,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	53                   	push   %ebx
f010004b:	68 20 38 10 f0       	push   $0xf0103820
f0100050:	e8 63 28 00 00       	call   f01028b8 <cprintf>
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
f0100076:	e8 d9 07 00 00       	call   f0100854 <backtrace>
f010007b:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007e:	83 ec 08             	sub    $0x8,%esp
f0100081:	53                   	push   %ebx
f0100082:	68 3c 38 10 f0       	push   $0xf010383c
f0100087:	e8 2c 28 00 00       	call   f01028b8 <cprintf>
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
f010009c:	b8 70 79 11 f0       	mov    $0xf0117970,%eax
f01000a1:	2d 00 73 11 f0       	sub    $0xf0117300,%eax
f01000a6:	50                   	push   %eax
f01000a7:	6a 00                	push   $0x0
f01000a9:	68 00 73 11 f0       	push   $0xf0117300
f01000ae:	e8 bf 32 00 00       	call   f0103372 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b3:	e8 ad 04 00 00       	call   f0100565 <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b8:	83 c4 08             	add    $0x8,%esp
f01000bb:	68 ac 1a 00 00       	push   $0x1aac
f01000c0:	68 57 38 10 f0       	push   $0xf0103857
f01000c5:	e8 ee 27 00 00       	call   f01028b8 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000ca:	e8 2a 11 00 00       	call   f01011f9 <mem_init>

    cprintf("Welcome to %Cc%Ccaomaer's minimal OS\n",0,67,1,104);
f01000cf:	c7 04 24 68 00 00 00 	movl   $0x68,(%esp)
f01000d6:	6a 01                	push   $0x1
f01000d8:	6a 43                	push   $0x43
f01000da:	6a 00                	push   $0x0
f01000dc:	68 a4 38 10 f0       	push   $0xf01038a4
f01000e1:	e8 d2 27 00 00       	call   f01028b8 <cprintf>
f01000e6:	83 c4 20             	add    $0x20,%esp
	// Test the stack backtrace function (lab 1 only)
	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000e9:	83 ec 0c             	sub    $0xc,%esp
f01000ec:	6a 00                	push   $0x0
f01000ee:	e8 04 08 00 00       	call   f01008f7 <monitor>
f01000f3:	83 c4 10             	add    $0x10,%esp
f01000f6:	eb f1                	jmp    f01000e9 <i386_init+0x53>

f01000f8 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000f8:	55                   	push   %ebp
f01000f9:	89 e5                	mov    %esp,%ebp
f01000fb:	56                   	push   %esi
f01000fc:	53                   	push   %ebx
f01000fd:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100100:	83 3d 60 79 11 f0 00 	cmpl   $0x0,0xf0117960
f0100107:	75 37                	jne    f0100140 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f0100109:	89 35 60 79 11 f0    	mov    %esi,0xf0117960

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f010010f:	fa                   	cli    
f0100110:	fc                   	cld    

	va_start(ap, fmt);
f0100111:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100114:	83 ec 04             	sub    $0x4,%esp
f0100117:	ff 75 0c             	pushl  0xc(%ebp)
f010011a:	ff 75 08             	pushl  0x8(%ebp)
f010011d:	68 72 38 10 f0       	push   $0xf0103872
f0100122:	e8 91 27 00 00       	call   f01028b8 <cprintf>
	vcprintf(fmt, ap);
f0100127:	83 c4 08             	add    $0x8,%esp
f010012a:	53                   	push   %ebx
f010012b:	56                   	push   %esi
f010012c:	e8 61 27 00 00       	call   f0102892 <vcprintf>
	cprintf("\n");
f0100131:	c7 04 24 d7 48 10 f0 	movl   $0xf01048d7,(%esp)
f0100138:	e8 7b 27 00 00       	call   f01028b8 <cprintf>
	va_end(ap);
f010013d:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100140:	83 ec 0c             	sub    $0xc,%esp
f0100143:	6a 00                	push   $0x0
f0100145:	e8 ad 07 00 00       	call   f01008f7 <monitor>
f010014a:	83 c4 10             	add    $0x10,%esp
f010014d:	eb f1                	jmp    f0100140 <_panic+0x48>

f010014f <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010014f:	55                   	push   %ebp
f0100150:	89 e5                	mov    %esp,%ebp
f0100152:	53                   	push   %ebx
f0100153:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100156:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100159:	ff 75 0c             	pushl  0xc(%ebp)
f010015c:	ff 75 08             	pushl  0x8(%ebp)
f010015f:	68 8a 38 10 f0       	push   $0xf010388a
f0100164:	e8 4f 27 00 00       	call   f01028b8 <cprintf>
	vcprintf(fmt, ap);
f0100169:	83 c4 08             	add    $0x8,%esp
f010016c:	53                   	push   %ebx
f010016d:	ff 75 10             	pushl  0x10(%ebp)
f0100170:	e8 1d 27 00 00       	call   f0102892 <vcprintf>
	cprintf("\n");
f0100175:	c7 04 24 d7 48 10 f0 	movl   $0xf01048d7,(%esp)
f010017c:	e8 37 27 00 00       	call   f01028b8 <cprintf>
	va_end(ap);
}
f0100181:	83 c4 10             	add    $0x10,%esp
f0100184:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100187:	c9                   	leave  
f0100188:	c3                   	ret    

f0100189 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100189:	55                   	push   %ebp
f010018a:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010018c:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100191:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100192:	a8 01                	test   $0x1,%al
f0100194:	74 0b                	je     f01001a1 <serial_proc_data+0x18>
f0100196:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010019b:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010019c:	0f b6 c0             	movzbl %al,%eax
f010019f:	eb 05                	jmp    f01001a6 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01001a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01001a6:	5d                   	pop    %ebp
f01001a7:	c3                   	ret    

f01001a8 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001a8:	55                   	push   %ebp
f01001a9:	89 e5                	mov    %esp,%ebp
f01001ab:	53                   	push   %ebx
f01001ac:	83 ec 04             	sub    $0x4,%esp
f01001af:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01001b1:	eb 2b                	jmp    f01001de <cons_intr+0x36>
		if (c == 0)
f01001b3:	85 c0                	test   %eax,%eax
f01001b5:	74 27                	je     f01001de <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01001b7:	8b 0d 24 75 11 f0    	mov    0xf0117524,%ecx
f01001bd:	8d 51 01             	lea    0x1(%ecx),%edx
f01001c0:	89 15 24 75 11 f0    	mov    %edx,0xf0117524
f01001c6:	88 81 20 73 11 f0    	mov    %al,-0xfee8ce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01001cc:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001d2:	75 0a                	jne    f01001de <cons_intr+0x36>
			cons.wpos = 0;
f01001d4:	c7 05 24 75 11 f0 00 	movl   $0x0,0xf0117524
f01001db:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001de:	ff d3                	call   *%ebx
f01001e0:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001e3:	75 ce                	jne    f01001b3 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001e5:	83 c4 04             	add    $0x4,%esp
f01001e8:	5b                   	pop    %ebx
f01001e9:	5d                   	pop    %ebp
f01001ea:	c3                   	ret    

f01001eb <kbd_proc_data>:
f01001eb:	ba 64 00 00 00       	mov    $0x64,%edx
f01001f0:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f01001f1:	a8 01                	test   $0x1,%al
f01001f3:	0f 84 f8 00 00 00    	je     f01002f1 <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01001f9:	a8 20                	test   $0x20,%al
f01001fb:	0f 85 f6 00 00 00    	jne    f01002f7 <kbd_proc_data+0x10c>
f0100201:	ba 60 00 00 00       	mov    $0x60,%edx
f0100206:	ec                   	in     (%dx),%al
f0100207:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100209:	3c e0                	cmp    $0xe0,%al
f010020b:	75 0d                	jne    f010021a <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f010020d:	83 0d 00 73 11 f0 40 	orl    $0x40,0xf0117300
		return 0;
f0100214:	b8 00 00 00 00       	mov    $0x0,%eax
f0100219:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010021a:	55                   	push   %ebp
f010021b:	89 e5                	mov    %esp,%ebp
f010021d:	53                   	push   %ebx
f010021e:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f0100221:	84 c0                	test   %al,%al
f0100223:	79 36                	jns    f010025b <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100225:	8b 0d 00 73 11 f0    	mov    0xf0117300,%ecx
f010022b:	89 cb                	mov    %ecx,%ebx
f010022d:	83 e3 40             	and    $0x40,%ebx
f0100230:	83 e0 7f             	and    $0x7f,%eax
f0100233:	85 db                	test   %ebx,%ebx
f0100235:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100238:	0f b6 d2             	movzbl %dl,%edx
f010023b:	0f b6 82 20 3a 10 f0 	movzbl -0xfefc5e0(%edx),%eax
f0100242:	83 c8 40             	or     $0x40,%eax
f0100245:	0f b6 c0             	movzbl %al,%eax
f0100248:	f7 d0                	not    %eax
f010024a:	21 c8                	and    %ecx,%eax
f010024c:	a3 00 73 11 f0       	mov    %eax,0xf0117300
		return 0;
f0100251:	b8 00 00 00 00       	mov    $0x0,%eax
f0100256:	e9 a4 00 00 00       	jmp    f01002ff <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f010025b:	8b 0d 00 73 11 f0    	mov    0xf0117300,%ecx
f0100261:	f6 c1 40             	test   $0x40,%cl
f0100264:	74 0e                	je     f0100274 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100266:	83 c8 80             	or     $0xffffff80,%eax
f0100269:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010026b:	83 e1 bf             	and    $0xffffffbf,%ecx
f010026e:	89 0d 00 73 11 f0    	mov    %ecx,0xf0117300
	}

	shift |= shiftcode[data];
f0100274:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100277:	0f b6 82 20 3a 10 f0 	movzbl -0xfefc5e0(%edx),%eax
f010027e:	0b 05 00 73 11 f0    	or     0xf0117300,%eax
f0100284:	0f b6 8a 20 39 10 f0 	movzbl -0xfefc6e0(%edx),%ecx
f010028b:	31 c8                	xor    %ecx,%eax
f010028d:	a3 00 73 11 f0       	mov    %eax,0xf0117300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100292:	89 c1                	mov    %eax,%ecx
f0100294:	83 e1 03             	and    $0x3,%ecx
f0100297:	8b 0c 8d 00 39 10 f0 	mov    -0xfefc700(,%ecx,4),%ecx
f010029e:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002a2:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01002a5:	a8 08                	test   $0x8,%al
f01002a7:	74 1b                	je     f01002c4 <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f01002a9:	89 da                	mov    %ebx,%edx
f01002ab:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01002ae:	83 f9 19             	cmp    $0x19,%ecx
f01002b1:	77 05                	ja     f01002b8 <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f01002b3:	83 eb 20             	sub    $0x20,%ebx
f01002b6:	eb 0c                	jmp    f01002c4 <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f01002b8:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002bb:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01002be:	83 fa 19             	cmp    $0x19,%edx
f01002c1:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002c4:	f7 d0                	not    %eax
f01002c6:	a8 06                	test   $0x6,%al
f01002c8:	75 33                	jne    f01002fd <kbd_proc_data+0x112>
f01002ca:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002d0:	75 2b                	jne    f01002fd <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f01002d2:	83 ec 0c             	sub    $0xc,%esp
f01002d5:	68 ca 38 10 f0       	push   $0xf01038ca
f01002da:	e8 d9 25 00 00       	call   f01028b8 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002df:	ba 92 00 00 00       	mov    $0x92,%edx
f01002e4:	b8 03 00 00 00       	mov    $0x3,%eax
f01002e9:	ee                   	out    %al,(%dx)
f01002ea:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002ed:	89 d8                	mov    %ebx,%eax
f01002ef:	eb 0e                	jmp    f01002ff <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f01002f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01002f6:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01002f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002fc:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002fd:	89 d8                	mov    %ebx,%eax
}
f01002ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100302:	c9                   	leave  
f0100303:	c3                   	ret    

f0100304 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100304:	55                   	push   %ebp
f0100305:	89 e5                	mov    %esp,%ebp
f0100307:	57                   	push   %edi
f0100308:	56                   	push   %esi
f0100309:	53                   	push   %ebx
f010030a:	83 ec 1c             	sub    $0x1c,%esp
f010030d:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010030f:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100314:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100319:	b9 84 00 00 00       	mov    $0x84,%ecx
f010031e:	eb 09                	jmp    f0100329 <cons_putc+0x25>
f0100320:	89 ca                	mov    %ecx,%edx
f0100322:	ec                   	in     (%dx),%al
f0100323:	ec                   	in     (%dx),%al
f0100324:	ec                   	in     (%dx),%al
f0100325:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100326:	83 c3 01             	add    $0x1,%ebx
f0100329:	89 f2                	mov    %esi,%edx
f010032b:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010032c:	a8 20                	test   $0x20,%al
f010032e:	75 08                	jne    f0100338 <cons_putc+0x34>
f0100330:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100336:	7e e8                	jle    f0100320 <cons_putc+0x1c>
f0100338:	89 f8                	mov    %edi,%eax
f010033a:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010033d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100342:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100343:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100348:	be 79 03 00 00       	mov    $0x379,%esi
f010034d:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100352:	eb 09                	jmp    f010035d <cons_putc+0x59>
f0100354:	89 ca                	mov    %ecx,%edx
f0100356:	ec                   	in     (%dx),%al
f0100357:	ec                   	in     (%dx),%al
f0100358:	ec                   	in     (%dx),%al
f0100359:	ec                   	in     (%dx),%al
f010035a:	83 c3 01             	add    $0x1,%ebx
f010035d:	89 f2                	mov    %esi,%edx
f010035f:	ec                   	in     (%dx),%al
f0100360:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100366:	7f 04                	jg     f010036c <cons_putc+0x68>
f0100368:	84 c0                	test   %al,%al
f010036a:	79 e8                	jns    f0100354 <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010036c:	ba 78 03 00 00       	mov    $0x378,%edx
f0100371:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100375:	ee                   	out    %al,(%dx)
f0100376:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010037b:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100380:	ee                   	out    %al,(%dx)
f0100381:	b8 08 00 00 00       	mov    $0x8,%eax
f0100386:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100387:	89 fa                	mov    %edi,%edx
f0100389:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f010038f:	89 f8                	mov    %edi,%eax
f0100391:	80 cc 07             	or     $0x7,%ah
f0100394:	85 d2                	test   %edx,%edx
f0100396:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100399:	89 f8                	mov    %edi,%eax
f010039b:	0f b6 c0             	movzbl %al,%eax
f010039e:	83 f8 09             	cmp    $0x9,%eax
f01003a1:	74 74                	je     f0100417 <cons_putc+0x113>
f01003a3:	83 f8 09             	cmp    $0x9,%eax
f01003a6:	7f 0a                	jg     f01003b2 <cons_putc+0xae>
f01003a8:	83 f8 08             	cmp    $0x8,%eax
f01003ab:	74 14                	je     f01003c1 <cons_putc+0xbd>
f01003ad:	e9 99 00 00 00       	jmp    f010044b <cons_putc+0x147>
f01003b2:	83 f8 0a             	cmp    $0xa,%eax
f01003b5:	74 3a                	je     f01003f1 <cons_putc+0xed>
f01003b7:	83 f8 0d             	cmp    $0xd,%eax
f01003ba:	74 3d                	je     f01003f9 <cons_putc+0xf5>
f01003bc:	e9 8a 00 00 00       	jmp    f010044b <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f01003c1:	0f b7 05 28 75 11 f0 	movzwl 0xf0117528,%eax
f01003c8:	66 85 c0             	test   %ax,%ax
f01003cb:	0f 84 e6 00 00 00    	je     f01004b7 <cons_putc+0x1b3>
			crt_pos--;
f01003d1:	83 e8 01             	sub    $0x1,%eax
f01003d4:	66 a3 28 75 11 f0    	mov    %ax,0xf0117528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003da:	0f b7 c0             	movzwl %ax,%eax
f01003dd:	66 81 e7 00 ff       	and    $0xff00,%di
f01003e2:	83 cf 20             	or     $0x20,%edi
f01003e5:	8b 15 2c 75 11 f0    	mov    0xf011752c,%edx
f01003eb:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003ef:	eb 78                	jmp    f0100469 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003f1:	66 83 05 28 75 11 f0 	addw   $0x50,0xf0117528
f01003f8:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003f9:	0f b7 05 28 75 11 f0 	movzwl 0xf0117528,%eax
f0100400:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100406:	c1 e8 16             	shr    $0x16,%eax
f0100409:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010040c:	c1 e0 04             	shl    $0x4,%eax
f010040f:	66 a3 28 75 11 f0    	mov    %ax,0xf0117528
f0100415:	eb 52                	jmp    f0100469 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f0100417:	b8 20 00 00 00       	mov    $0x20,%eax
f010041c:	e8 e3 fe ff ff       	call   f0100304 <cons_putc>
		cons_putc(' ');
f0100421:	b8 20 00 00 00       	mov    $0x20,%eax
f0100426:	e8 d9 fe ff ff       	call   f0100304 <cons_putc>
		cons_putc(' ');
f010042b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100430:	e8 cf fe ff ff       	call   f0100304 <cons_putc>
		cons_putc(' ');
f0100435:	b8 20 00 00 00       	mov    $0x20,%eax
f010043a:	e8 c5 fe ff ff       	call   f0100304 <cons_putc>
		cons_putc(' ');
f010043f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100444:	e8 bb fe ff ff       	call   f0100304 <cons_putc>
f0100449:	eb 1e                	jmp    f0100469 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010044b:	0f b7 05 28 75 11 f0 	movzwl 0xf0117528,%eax
f0100452:	8d 50 01             	lea    0x1(%eax),%edx
f0100455:	66 89 15 28 75 11 f0 	mov    %dx,0xf0117528
f010045c:	0f b7 c0             	movzwl %ax,%eax
f010045f:	8b 15 2c 75 11 f0    	mov    0xf011752c,%edx
f0100465:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100469:	66 81 3d 28 75 11 f0 	cmpw   $0x7cf,0xf0117528
f0100470:	cf 07 
f0100472:	76 43                	jbe    f01004b7 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100474:	a1 2c 75 11 f0       	mov    0xf011752c,%eax
f0100479:	83 ec 04             	sub    $0x4,%esp
f010047c:	68 00 0f 00 00       	push   $0xf00
f0100481:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100487:	52                   	push   %edx
f0100488:	50                   	push   %eax
f0100489:	e8 31 2f 00 00       	call   f01033bf <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010048e:	8b 15 2c 75 11 f0    	mov    0xf011752c,%edx
f0100494:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010049a:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01004a0:	83 c4 10             	add    $0x10,%esp
f01004a3:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01004a8:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004ab:	39 d0                	cmp    %edx,%eax
f01004ad:	75 f4                	jne    f01004a3 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01004af:	66 83 2d 28 75 11 f0 	subw   $0x50,0xf0117528
f01004b6:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004b7:	8b 0d 30 75 11 f0    	mov    0xf0117530,%ecx
f01004bd:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004c2:	89 ca                	mov    %ecx,%edx
f01004c4:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004c5:	0f b7 1d 28 75 11 f0 	movzwl 0xf0117528,%ebx
f01004cc:	8d 71 01             	lea    0x1(%ecx),%esi
f01004cf:	89 d8                	mov    %ebx,%eax
f01004d1:	66 c1 e8 08          	shr    $0x8,%ax
f01004d5:	89 f2                	mov    %esi,%edx
f01004d7:	ee                   	out    %al,(%dx)
f01004d8:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004dd:	89 ca                	mov    %ecx,%edx
f01004df:	ee                   	out    %al,(%dx)
f01004e0:	89 d8                	mov    %ebx,%eax
f01004e2:	89 f2                	mov    %esi,%edx
f01004e4:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004e8:	5b                   	pop    %ebx
f01004e9:	5e                   	pop    %esi
f01004ea:	5f                   	pop    %edi
f01004eb:	5d                   	pop    %ebp
f01004ec:	c3                   	ret    

f01004ed <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004ed:	80 3d 34 75 11 f0 00 	cmpb   $0x0,0xf0117534
f01004f4:	74 11                	je     f0100507 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004f6:	55                   	push   %ebp
f01004f7:	89 e5                	mov    %esp,%ebp
f01004f9:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004fc:	b8 89 01 10 f0       	mov    $0xf0100189,%eax
f0100501:	e8 a2 fc ff ff       	call   f01001a8 <cons_intr>
}
f0100506:	c9                   	leave  
f0100507:	f3 c3                	repz ret 

f0100509 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100509:	55                   	push   %ebp
f010050a:	89 e5                	mov    %esp,%ebp
f010050c:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f010050f:	b8 eb 01 10 f0       	mov    $0xf01001eb,%eax
f0100514:	e8 8f fc ff ff       	call   f01001a8 <cons_intr>
}
f0100519:	c9                   	leave  
f010051a:	c3                   	ret    

f010051b <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f010051b:	55                   	push   %ebp
f010051c:	89 e5                	mov    %esp,%ebp
f010051e:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100521:	e8 c7 ff ff ff       	call   f01004ed <serial_intr>
	kbd_intr();
f0100526:	e8 de ff ff ff       	call   f0100509 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010052b:	a1 20 75 11 f0       	mov    0xf0117520,%eax
f0100530:	3b 05 24 75 11 f0    	cmp    0xf0117524,%eax
f0100536:	74 26                	je     f010055e <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100538:	8d 50 01             	lea    0x1(%eax),%edx
f010053b:	89 15 20 75 11 f0    	mov    %edx,0xf0117520
f0100541:	0f b6 88 20 73 11 f0 	movzbl -0xfee8ce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100548:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f010054a:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100550:	75 11                	jne    f0100563 <cons_getc+0x48>
			cons.rpos = 0;
f0100552:	c7 05 20 75 11 f0 00 	movl   $0x0,0xf0117520
f0100559:	00 00 00 
f010055c:	eb 05                	jmp    f0100563 <cons_getc+0x48>
		return c;
	}
	return 0;
f010055e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100563:	c9                   	leave  
f0100564:	c3                   	ret    

f0100565 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100565:	55                   	push   %ebp
f0100566:	89 e5                	mov    %esp,%ebp
f0100568:	57                   	push   %edi
f0100569:	56                   	push   %esi
f010056a:	53                   	push   %ebx
f010056b:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010056e:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100575:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010057c:	5a a5 
	if (*cp != 0xA55A) {
f010057e:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100585:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100589:	74 11                	je     f010059c <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010058b:	c7 05 30 75 11 f0 b4 	movl   $0x3b4,0xf0117530
f0100592:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100595:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010059a:	eb 16                	jmp    f01005b2 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010059c:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01005a3:	c7 05 30 75 11 f0 d4 	movl   $0x3d4,0xf0117530
f01005aa:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01005ad:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01005b2:	8b 3d 30 75 11 f0    	mov    0xf0117530,%edi
f01005b8:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005bd:	89 fa                	mov    %edi,%edx
f01005bf:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005c0:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005c3:	89 da                	mov    %ebx,%edx
f01005c5:	ec                   	in     (%dx),%al
f01005c6:	0f b6 c8             	movzbl %al,%ecx
f01005c9:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005cc:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005d1:	89 fa                	mov    %edi,%edx
f01005d3:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005d4:	89 da                	mov    %ebx,%edx
f01005d6:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005d7:	89 35 2c 75 11 f0    	mov    %esi,0xf011752c
	crt_pos = pos;
f01005dd:	0f b6 c0             	movzbl %al,%eax
f01005e0:	09 c8                	or     %ecx,%eax
f01005e2:	66 a3 28 75 11 f0    	mov    %ax,0xf0117528
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005e8:	be fa 03 00 00       	mov    $0x3fa,%esi
f01005ed:	b8 00 00 00 00       	mov    $0x0,%eax
f01005f2:	89 f2                	mov    %esi,%edx
f01005f4:	ee                   	out    %al,(%dx)
f01005f5:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005fa:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005ff:	ee                   	out    %al,(%dx)
f0100600:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100605:	b8 0c 00 00 00       	mov    $0xc,%eax
f010060a:	89 da                	mov    %ebx,%edx
f010060c:	ee                   	out    %al,(%dx)
f010060d:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100612:	b8 00 00 00 00       	mov    $0x0,%eax
f0100617:	ee                   	out    %al,(%dx)
f0100618:	ba fb 03 00 00       	mov    $0x3fb,%edx
f010061d:	b8 03 00 00 00       	mov    $0x3,%eax
f0100622:	ee                   	out    %al,(%dx)
f0100623:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100628:	b8 00 00 00 00       	mov    $0x0,%eax
f010062d:	ee                   	out    %al,(%dx)
f010062e:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100633:	b8 01 00 00 00       	mov    $0x1,%eax
f0100638:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100639:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010063e:	ec                   	in     (%dx),%al
f010063f:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100641:	3c ff                	cmp    $0xff,%al
f0100643:	0f 95 05 34 75 11 f0 	setne  0xf0117534
f010064a:	89 f2                	mov    %esi,%edx
f010064c:	ec                   	in     (%dx),%al
f010064d:	89 da                	mov    %ebx,%edx
f010064f:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100650:	80 f9 ff             	cmp    $0xff,%cl
f0100653:	75 10                	jne    f0100665 <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f0100655:	83 ec 0c             	sub    $0xc,%esp
f0100658:	68 d6 38 10 f0       	push   $0xf01038d6
f010065d:	e8 56 22 00 00       	call   f01028b8 <cprintf>
f0100662:	83 c4 10             	add    $0x10,%esp
}
f0100665:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100668:	5b                   	pop    %ebx
f0100669:	5e                   	pop    %esi
f010066a:	5f                   	pop    %edi
f010066b:	5d                   	pop    %ebp
f010066c:	c3                   	ret    

f010066d <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010066d:	55                   	push   %ebp
f010066e:	89 e5                	mov    %esp,%ebp
f0100670:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100673:	8b 45 08             	mov    0x8(%ebp),%eax
f0100676:	e8 89 fc ff ff       	call   f0100304 <cons_putc>
}
f010067b:	c9                   	leave  
f010067c:	c3                   	ret    

f010067d <getchar>:

int
getchar(void)
{
f010067d:	55                   	push   %ebp
f010067e:	89 e5                	mov    %esp,%ebp
f0100680:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100683:	e8 93 fe ff ff       	call   f010051b <cons_getc>
f0100688:	85 c0                	test   %eax,%eax
f010068a:	74 f7                	je     f0100683 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010068c:	c9                   	leave  
f010068d:	c3                   	ret    

f010068e <iscons>:

int
iscons(int fdnum)
{
f010068e:	55                   	push   %ebp
f010068f:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100691:	b8 01 00 00 00       	mov    $0x1,%eax
f0100696:	5d                   	pop    %ebp
f0100697:	c3                   	ret    

f0100698 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100698:	55                   	push   %ebp
f0100699:	89 e5                	mov    %esp,%ebp
f010069b:	56                   	push   %esi
f010069c:	53                   	push   %ebx
f010069d:	bb 40 3e 10 f0       	mov    $0xf0103e40,%ebx
f01006a2:	be 70 3e 10 f0       	mov    $0xf0103e70,%esi
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01006a7:	83 ec 04             	sub    $0x4,%esp
f01006aa:	ff 73 04             	pushl  0x4(%ebx)
f01006ad:	ff 33                	pushl  (%ebx)
f01006af:	68 20 3b 10 f0       	push   $0xf0103b20
f01006b4:	e8 ff 21 00 00       	call   f01028b8 <cprintf>
f01006b9:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
f01006bc:	83 c4 10             	add    $0x10,%esp
f01006bf:	39 f3                	cmp    %esi,%ebx
f01006c1:	75 e4                	jne    f01006a7 <mon_help+0xf>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01006c3:	b8 00 00 00 00       	mov    $0x0,%eax
f01006c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01006cb:	5b                   	pop    %ebx
f01006cc:	5e                   	pop    %esi
f01006cd:	5d                   	pop    %ebp
f01006ce:	c3                   	ret    

f01006cf <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006cf:	55                   	push   %ebp
f01006d0:	89 e5                	mov    %esp,%ebp
f01006d2:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006d5:	68 29 3b 10 f0       	push   $0xf0103b29
f01006da:	e8 d9 21 00 00       	call   f01028b8 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006df:	83 c4 08             	add    $0x8,%esp
f01006e2:	68 0c 00 10 00       	push   $0x10000c
f01006e7:	68 1c 3c 10 f0       	push   $0xf0103c1c
f01006ec:	e8 c7 21 00 00       	call   f01028b8 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006f1:	83 c4 0c             	add    $0xc,%esp
f01006f4:	68 0c 00 10 00       	push   $0x10000c
f01006f9:	68 0c 00 10 f0       	push   $0xf010000c
f01006fe:	68 44 3c 10 f0       	push   $0xf0103c44
f0100703:	e8 b0 21 00 00       	call   f01028b8 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100708:	83 c4 0c             	add    $0xc,%esp
f010070b:	68 01 38 10 00       	push   $0x103801
f0100710:	68 01 38 10 f0       	push   $0xf0103801
f0100715:	68 68 3c 10 f0       	push   $0xf0103c68
f010071a:	e8 99 21 00 00       	call   f01028b8 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010071f:	83 c4 0c             	add    $0xc,%esp
f0100722:	68 00 73 11 00       	push   $0x117300
f0100727:	68 00 73 11 f0       	push   $0xf0117300
f010072c:	68 8c 3c 10 f0       	push   $0xf0103c8c
f0100731:	e8 82 21 00 00       	call   f01028b8 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100736:	83 c4 0c             	add    $0xc,%esp
f0100739:	68 70 79 11 00       	push   $0x117970
f010073e:	68 70 79 11 f0       	push   $0xf0117970
f0100743:	68 b0 3c 10 f0       	push   $0xf0103cb0
f0100748:	e8 6b 21 00 00       	call   f01028b8 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010074d:	b8 6f 7d 11 f0       	mov    $0xf0117d6f,%eax
f0100752:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100757:	83 c4 08             	add    $0x8,%esp
f010075a:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f010075f:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100765:	85 c0                	test   %eax,%eax
f0100767:	0f 48 c2             	cmovs  %edx,%eax
f010076a:	c1 f8 0a             	sar    $0xa,%eax
f010076d:	50                   	push   %eax
f010076e:	68 d4 3c 10 f0       	push   $0xf0103cd4
f0100773:	e8 40 21 00 00       	call   f01028b8 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100778:	b8 00 00 00 00       	mov    $0x0,%eax
f010077d:	c9                   	leave  
f010077e:	c3                   	ret    

f010077f <showmappings>:
int
showmappings(int argc, char **argv, struct Trapframe *tf)
{
f010077f:	55                   	push   %ebp
f0100780:	89 e5                	mov    %esp,%ebp
f0100782:	56                   	push   %esi
f0100783:	53                   	push   %ebx
f0100784:	8b 75 0c             	mov    0xc(%ebp),%esi
	// check arg;
	if(argc != 3){
f0100787:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f010078b:	74 1a                	je     f01007a7 <showmappings+0x28>
		cprintf("error: must have three args, like: showmappings addr1 addr2\n");
f010078d:	83 ec 0c             	sub    $0xc,%esp
f0100790:	68 00 3d 10 f0       	push   $0xf0103d00
f0100795:	e8 1e 21 00 00       	call   f01028b8 <cprintf>
        return -1;
f010079a:	83 c4 10             	add    $0x10,%esp
f010079d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01007a2:	e9 a6 00 00 00       	jmp    f010084d <showmappings+0xce>
	}

	int start = strtol(argv[1], 0, 16);
f01007a7:	83 ec 04             	sub    $0x4,%esp
f01007aa:	6a 10                	push   $0x10
f01007ac:	6a 00                	push   $0x0
f01007ae:	ff 76 04             	pushl  0x4(%esi)
f01007b1:	e8 e0 2c 00 00       	call   f0103496 <strtol>
f01007b6:	89 c3                	mov    %eax,%ebx
	int end = strtol(argv[2], 0, 16);
f01007b8:	83 c4 0c             	add    $0xc,%esp
f01007bb:	6a 10                	push   $0x10
f01007bd:	6a 00                	push   $0x0
f01007bf:	ff 76 08             	pushl  0x8(%esi)
f01007c2:	e8 cf 2c 00 00       	call   f0103496 <strtol>

	// align
	start = ROUNDDOWN(start, PGSIZE);
f01007c7:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	end = ROUNDDOWN(end, PGSIZE);
f01007cd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01007d2:	89 c6                	mov    %eax,%esi

	int i = start;
	for (; i <= end; i += PGSIZE) {
f01007d4:	83 c4 10             	add    $0x10,%esp
f01007d7:	eb 6b                	jmp    f0100844 <showmappings+0xc5>
		cprintf("vaddr is %08x. ", i);
f01007d9:	83 ec 08             	sub    $0x8,%esp
f01007dc:	53                   	push   %ebx
f01007dd:	68 42 3b 10 f0       	push   $0xf0103b42
f01007e2:	e8 d1 20 00 00       	call   f01028b8 <cprintf>
		pte_t *pt_entry = 0;
		pt_entry = pgdir_walk(kern_pgdir, (void*)i, 1);
f01007e7:	83 c4 0c             	add    $0xc,%esp
f01007ea:	6a 01                	push   $0x1
f01007ec:	53                   	push   %ebx
f01007ed:	ff 35 68 79 11 f0    	pushl  0xf0117968
f01007f3:	e8 ca 07 00 00       	call   f0100fc2 <pgdir_walk>
		if (pt_entry==NULL||!(*pt_entry&PTE_P)){
f01007f8:	83 c4 10             	add    $0x10,%esp
f01007fb:	85 c0                	test   %eax,%eax
f01007fd:	74 09                	je     f0100808 <showmappings+0x89>
f01007ff:	8b 10                	mov    (%eax),%edx
f0100801:	89 d0                	mov    %edx,%eax
f0100803:	83 e0 01             	and    $0x1,%eax
f0100806:	75 12                	jne    f010081a <showmappings+0x9b>
			cprintf("not mapped\n");
f0100808:	83 ec 0c             	sub    $0xc,%esp
f010080b:	68 52 3b 10 f0       	push   $0xf0103b52
f0100810:	e8 a3 20 00 00       	call   f01028b8 <cprintf>
			continue;
f0100815:	83 c4 10             	add    $0x10,%esp
f0100818:	eb 24                	jmp    f010083e <showmappings+0xbf>
		}
		int pyadd = PTE_ADDR(*pt_entry);
		cprintf("paddr is %08x, PTE_W is %d,PTE_U is %d,PTE_P is %d\n", pyadd, *pt_entry&PTE_W, *pt_entry&PTE_U, *pt_entry&PTE_P);
f010081a:	83 ec 0c             	sub    $0xc,%esp
f010081d:	50                   	push   %eax
f010081e:	89 d0                	mov    %edx,%eax
f0100820:	83 e0 04             	and    $0x4,%eax
f0100823:	50                   	push   %eax
f0100824:	89 d0                	mov    %edx,%eax
f0100826:	83 e0 02             	and    $0x2,%eax
f0100829:	50                   	push   %eax
f010082a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100830:	52                   	push   %edx
f0100831:	68 40 3d 10 f0       	push   $0xf0103d40
f0100836:	e8 7d 20 00 00       	call   f01028b8 <cprintf>
f010083b:	83 c4 20             	add    $0x20,%esp
	// align
	start = ROUNDDOWN(start, PGSIZE);
	end = ROUNDDOWN(end, PGSIZE);

	int i = start;
	for (; i <= end; i += PGSIZE) {
f010083e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100844:	39 f3                	cmp    %esi,%ebx
f0100846:	7e 91                	jle    f01007d9 <showmappings+0x5a>
			continue;
		}
		int pyadd = PTE_ADDR(*pt_entry);
		cprintf("paddr is %08x, PTE_W is %d,PTE_U is %d,PTE_P is %d\n", pyadd, *pt_entry&PTE_W, *pt_entry&PTE_U, *pt_entry&PTE_P);
	}
	return 0;
f0100848:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010084d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100850:	5b                   	pop    %ebx
f0100851:	5e                   	pop    %esi
f0100852:	5d                   	pop    %ebp
f0100853:	c3                   	ret    

f0100854 <backtrace>:
int
backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100854:	55                   	push   %ebp
f0100855:	89 e5                	mov    %esp,%ebp
f0100857:	57                   	push   %edi
f0100858:	56                   	push   %esi
f0100859:	53                   	push   %ebx
f010085a:	83 ec 48             	sub    $0x48,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f010085d:	89 ee                	mov    %ebp,%esi
  uint32_t* ebp = (uint32_t*) read_ebp();
  cprintf("Stack backtrace:\n");
f010085f:	68 5e 3b 10 f0       	push   $0xf0103b5e
f0100864:	e8 4f 20 00 00       	call   f01028b8 <cprintf>
  while (ebp) {
f0100869:	83 c4 10             	add    $0x10,%esp
f010086c:	eb 78                	jmp    f01008e6 <backtrace+0x92>
    uint32_t eip = ebp[1];
f010086e:	8b 46 04             	mov    0x4(%esi),%eax
f0100871:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    cprintf("ebp %x  eip %x  args", ebp, eip);
f0100874:	83 ec 04             	sub    $0x4,%esp
f0100877:	50                   	push   %eax
f0100878:	56                   	push   %esi
f0100879:	68 70 3b 10 f0       	push   $0xf0103b70
f010087e:	e8 35 20 00 00       	call   f01028b8 <cprintf>
f0100883:	8d 5e 08             	lea    0x8(%esi),%ebx
f0100886:	8d 7e 1c             	lea    0x1c(%esi),%edi
f0100889:	83 c4 10             	add    $0x10,%esp
    int i;
    for (i = 2; i <= 6; ++i)
      cprintf(" %08.x", ebp[i]);
f010088c:	83 ec 08             	sub    $0x8,%esp
f010088f:	ff 33                	pushl  (%ebx)
f0100891:	68 85 3b 10 f0       	push   $0xf0103b85
f0100896:	e8 1d 20 00 00       	call   f01028b8 <cprintf>
f010089b:	83 c3 04             	add    $0x4,%ebx
  cprintf("Stack backtrace:\n");
  while (ebp) {
    uint32_t eip = ebp[1];
    cprintf("ebp %x  eip %x  args", ebp, eip);
    int i;
    for (i = 2; i <= 6; ++i)
f010089e:	83 c4 10             	add    $0x10,%esp
f01008a1:	39 fb                	cmp    %edi,%ebx
f01008a3:	75 e7                	jne    f010088c <backtrace+0x38>
      cprintf(" %08.x", ebp[i]);
    cprintf("\n");
f01008a5:	83 ec 0c             	sub    $0xc,%esp
f01008a8:	68 d7 48 10 f0       	push   $0xf01048d7
f01008ad:	e8 06 20 00 00       	call   f01028b8 <cprintf>
    struct Eipdebuginfo info;
    debuginfo_eip(eip, &info);
f01008b2:	83 c4 08             	add    $0x8,%esp
f01008b5:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008b8:	50                   	push   %eax
f01008b9:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01008bc:	57                   	push   %edi
f01008bd:	e8 00 21 00 00       	call   f01029c2 <debuginfo_eip>
    cprintf("\t%s:%d: %.*s+%d\n", 
f01008c2:	83 c4 08             	add    $0x8,%esp
f01008c5:	89 f8                	mov    %edi,%eax
f01008c7:	2b 45 e0             	sub    -0x20(%ebp),%eax
f01008ca:	50                   	push   %eax
f01008cb:	ff 75 d8             	pushl  -0x28(%ebp)
f01008ce:	ff 75 dc             	pushl  -0x24(%ebp)
f01008d1:	ff 75 d4             	pushl  -0x2c(%ebp)
f01008d4:	ff 75 d0             	pushl  -0x30(%ebp)
f01008d7:	68 8c 3b 10 f0       	push   $0xf0103b8c
f01008dc:	e8 d7 1f 00 00       	call   f01028b8 <cprintf>
      info.eip_file, info.eip_line,
      info.eip_fn_namelen, info.eip_fn_name,
      eip-info.eip_fn_addr);
//         kern/monitor.c:143: monitor+106
    ebp = (uint32_t*) *ebp;
f01008e1:	8b 36                	mov    (%esi),%esi
f01008e3:	83 c4 20             	add    $0x20,%esp
int
backtrace(int argc, char **argv, struct Trapframe *tf)
{
  uint32_t* ebp = (uint32_t*) read_ebp();
  cprintf("Stack backtrace:\n");
  while (ebp) {
f01008e6:	85 f6                	test   %esi,%esi
f01008e8:	75 84                	jne    f010086e <backtrace+0x1a>
      eip-info.eip_fn_addr);
//         kern/monitor.c:143: monitor+106
    ebp = (uint32_t*) *ebp;
  }
  return 0;
}
f01008ea:	b8 00 00 00 00       	mov    $0x0,%eax
f01008ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008f2:	5b                   	pop    %ebx
f01008f3:	5e                   	pop    %esi
f01008f4:	5f                   	pop    %edi
f01008f5:	5d                   	pop    %ebp
f01008f6:	c3                   	ret    

f01008f7 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01008f7:	55                   	push   %ebp
f01008f8:	89 e5                	mov    %esp,%ebp
f01008fa:	57                   	push   %edi
f01008fb:	56                   	push   %esi
f01008fc:	53                   	push   %ebx
f01008fd:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100900:	68 74 3d 10 f0       	push   $0xf0103d74
f0100905:	e8 ae 1f 00 00       	call   f01028b8 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010090a:	c7 04 24 98 3d 10 f0 	movl   $0xf0103d98,(%esp)
f0100911:	e8 a2 1f 00 00       	call   f01028b8 <cprintf>
f0100916:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100919:	83 ec 0c             	sub    $0xc,%esp
f010091c:	68 9d 3b 10 f0       	push   $0xf0103b9d
f0100921:	e8 f5 27 00 00       	call   f010311b <readline>
f0100926:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100928:	83 c4 10             	add    $0x10,%esp
f010092b:	85 c0                	test   %eax,%eax
f010092d:	74 ea                	je     f0100919 <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010092f:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100936:	be 00 00 00 00       	mov    $0x0,%esi
f010093b:	eb 0a                	jmp    f0100947 <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f010093d:	c6 03 00             	movb   $0x0,(%ebx)
f0100940:	89 f7                	mov    %esi,%edi
f0100942:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100945:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100947:	0f b6 03             	movzbl (%ebx),%eax
f010094a:	84 c0                	test   %al,%al
f010094c:	74 63                	je     f01009b1 <monitor+0xba>
f010094e:	83 ec 08             	sub    $0x8,%esp
f0100951:	0f be c0             	movsbl %al,%eax
f0100954:	50                   	push   %eax
f0100955:	68 a1 3b 10 f0       	push   $0xf0103ba1
f010095a:	e8 d6 29 00 00       	call   f0103335 <strchr>
f010095f:	83 c4 10             	add    $0x10,%esp
f0100962:	85 c0                	test   %eax,%eax
f0100964:	75 d7                	jne    f010093d <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f0100966:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100969:	74 46                	je     f01009b1 <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010096b:	83 fe 0f             	cmp    $0xf,%esi
f010096e:	75 14                	jne    f0100984 <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100970:	83 ec 08             	sub    $0x8,%esp
f0100973:	6a 10                	push   $0x10
f0100975:	68 a6 3b 10 f0       	push   $0xf0103ba6
f010097a:	e8 39 1f 00 00       	call   f01028b8 <cprintf>
f010097f:	83 c4 10             	add    $0x10,%esp
f0100982:	eb 95                	jmp    f0100919 <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f0100984:	8d 7e 01             	lea    0x1(%esi),%edi
f0100987:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010098b:	eb 03                	jmp    f0100990 <monitor+0x99>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f010098d:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100990:	0f b6 03             	movzbl (%ebx),%eax
f0100993:	84 c0                	test   %al,%al
f0100995:	74 ae                	je     f0100945 <monitor+0x4e>
f0100997:	83 ec 08             	sub    $0x8,%esp
f010099a:	0f be c0             	movsbl %al,%eax
f010099d:	50                   	push   %eax
f010099e:	68 a1 3b 10 f0       	push   $0xf0103ba1
f01009a3:	e8 8d 29 00 00       	call   f0103335 <strchr>
f01009a8:	83 c4 10             	add    $0x10,%esp
f01009ab:	85 c0                	test   %eax,%eax
f01009ad:	74 de                	je     f010098d <monitor+0x96>
f01009af:	eb 94                	jmp    f0100945 <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f01009b1:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01009b8:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01009b9:	85 f6                	test   %esi,%esi
f01009bb:	0f 84 58 ff ff ff    	je     f0100919 <monitor+0x22>
f01009c1:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01009c6:	83 ec 08             	sub    $0x8,%esp
f01009c9:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01009cc:	ff 34 85 40 3e 10 f0 	pushl  -0xfefc1c0(,%eax,4)
f01009d3:	ff 75 a8             	pushl  -0x58(%ebp)
f01009d6:	e8 fc 28 00 00       	call   f01032d7 <strcmp>
f01009db:	83 c4 10             	add    $0x10,%esp
f01009de:	85 c0                	test   %eax,%eax
f01009e0:	75 21                	jne    f0100a03 <monitor+0x10c>
			return commands[i].func(argc, argv, tf);
f01009e2:	83 ec 04             	sub    $0x4,%esp
f01009e5:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01009e8:	ff 75 08             	pushl  0x8(%ebp)
f01009eb:	8d 55 a8             	lea    -0x58(%ebp),%edx
f01009ee:	52                   	push   %edx
f01009ef:	56                   	push   %esi
f01009f0:	ff 14 85 48 3e 10 f0 	call   *-0xfefc1b8(,%eax,4)
	cprintf("Type 'help' for a list of commands.\n");

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01009f7:	83 c4 10             	add    $0x10,%esp
f01009fa:	85 c0                	test   %eax,%eax
f01009fc:	78 25                	js     f0100a23 <monitor+0x12c>
f01009fe:	e9 16 ff ff ff       	jmp    f0100919 <monitor+0x22>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a03:	83 c3 01             	add    $0x1,%ebx
f0100a06:	83 fb 04             	cmp    $0x4,%ebx
f0100a09:	75 bb                	jne    f01009c6 <monitor+0xcf>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a0b:	83 ec 08             	sub    $0x8,%esp
f0100a0e:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a11:	68 c3 3b 10 f0       	push   $0xf0103bc3
f0100a16:	e8 9d 1e 00 00       	call   f01028b8 <cprintf>
f0100a1b:	83 c4 10             	add    $0x10,%esp
f0100a1e:	e9 f6 fe ff ff       	jmp    f0100919 <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a23:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a26:	5b                   	pop    %ebx
f0100a27:	5e                   	pop    %esi
f0100a28:	5f                   	pop    %edi
f0100a29:	5d                   	pop    %ebp
f0100a2a:	c3                   	ret    

f0100a2b <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100a2b:	55                   	push   %ebp
f0100a2c:	89 e5                	mov    %esp,%ebp
f0100a2e:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a30:	83 3d 38 75 11 f0 00 	cmpl   $0x0,0xf0117538
f0100a37:	75 0f                	jne    f0100a48 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100a39:	b8 6f 89 11 f0       	mov    $0xf011896f,%eax
f0100a3e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a43:	a3 38 75 11 f0       	mov    %eax,0xf0117538
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
f0100a48:	a1 38 75 11 f0       	mov    0xf0117538,%eax
	nextfree += ROUNDUP(n, PGSIZE);
f0100a4d:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f0100a53:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a59:	01 c2                	add    %eax,%edx
f0100a5b:	89 15 38 75 11 f0    	mov    %edx,0xf0117538

	return result;
}
f0100a61:	5d                   	pop    %ebp
f0100a62:	c3                   	ret    

f0100a63 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100a63:	55                   	push   %ebp
f0100a64:	89 e5                	mov    %esp,%ebp
f0100a66:	56                   	push   %esi
f0100a67:	53                   	push   %ebx
f0100a68:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100a6a:	83 ec 0c             	sub    $0xc,%esp
f0100a6d:	50                   	push   %eax
f0100a6e:	e8 de 1d 00 00       	call   f0102851 <mc146818_read>
f0100a73:	89 c6                	mov    %eax,%esi
f0100a75:	83 c3 01             	add    $0x1,%ebx
f0100a78:	89 1c 24             	mov    %ebx,(%esp)
f0100a7b:	e8 d1 1d 00 00       	call   f0102851 <mc146818_read>
f0100a80:	c1 e0 08             	shl    $0x8,%eax
f0100a83:	09 f0                	or     %esi,%eax
}
f0100a85:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100a88:	5b                   	pop    %ebx
f0100a89:	5e                   	pop    %esi
f0100a8a:	5d                   	pop    %ebp
f0100a8b:	c3                   	ret    

f0100a8c <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100a8c:	89 d1                	mov    %edx,%ecx
f0100a8e:	c1 e9 16             	shr    $0x16,%ecx
f0100a91:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100a94:	a8 01                	test   $0x1,%al
f0100a96:	74 52                	je     f0100aea <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100a98:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a9d:	89 c1                	mov    %eax,%ecx
f0100a9f:	c1 e9 0c             	shr    $0xc,%ecx
f0100aa2:	3b 0d 64 79 11 f0    	cmp    0xf0117964,%ecx
f0100aa8:	72 1b                	jb     f0100ac5 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100aaa:	55                   	push   %ebp
f0100aab:	89 e5                	mov    %esp,%ebp
f0100aad:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ab0:	50                   	push   %eax
f0100ab1:	68 70 3e 10 f0       	push   $0xf0103e70
f0100ab6:	68 e1 02 00 00       	push   $0x2e1
f0100abb:	68 0c 46 10 f0       	push   $0xf010460c
f0100ac0:	e8 33 f6 ff ff       	call   f01000f8 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100ac5:	c1 ea 0c             	shr    $0xc,%edx
f0100ac8:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100ace:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100ad5:	89 c2                	mov    %eax,%edx
f0100ad7:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100ada:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100adf:	85 d2                	test   %edx,%edx
f0100ae1:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100ae6:	0f 44 c2             	cmove  %edx,%eax
f0100ae9:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100aea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100aef:	c3                   	ret    

f0100af0 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100af0:	55                   	push   %ebp
f0100af1:	89 e5                	mov    %esp,%ebp
f0100af3:	57                   	push   %edi
f0100af4:	56                   	push   %esi
f0100af5:	53                   	push   %ebx
f0100af6:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100af9:	84 c0                	test   %al,%al
f0100afb:	0f 85 81 02 00 00    	jne    f0100d82 <check_page_free_list+0x292>
f0100b01:	e9 8e 02 00 00       	jmp    f0100d94 <check_page_free_list+0x2a4>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100b06:	83 ec 04             	sub    $0x4,%esp
f0100b09:	68 94 3e 10 f0       	push   $0xf0103e94
f0100b0e:	68 22 02 00 00       	push   $0x222
f0100b13:	68 0c 46 10 f0       	push   $0xf010460c
f0100b18:	e8 db f5 ff ff       	call   f01000f8 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100b1d:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100b20:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100b23:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b26:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100b29:	89 c2                	mov    %eax,%edx
f0100b2b:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0100b31:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100b37:	0f 95 c2             	setne  %dl
f0100b3a:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100b3d:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100b41:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100b43:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b47:	8b 00                	mov    (%eax),%eax
f0100b49:	85 c0                	test   %eax,%eax
f0100b4b:	75 dc                	jne    f0100b29 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100b4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b50:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100b56:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b59:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100b5c:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100b5e:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100b61:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b66:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b6b:	8b 1d 3c 75 11 f0    	mov    0xf011753c,%ebx
f0100b71:	eb 53                	jmp    f0100bc6 <check_page_free_list+0xd6>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b73:	89 d8                	mov    %ebx,%eax
f0100b75:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0100b7b:	c1 f8 03             	sar    $0x3,%eax
f0100b7e:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100b81:	89 c2                	mov    %eax,%edx
f0100b83:	c1 ea 16             	shr    $0x16,%edx
f0100b86:	39 f2                	cmp    %esi,%edx
f0100b88:	73 3a                	jae    f0100bc4 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b8a:	89 c2                	mov    %eax,%edx
f0100b8c:	c1 ea 0c             	shr    $0xc,%edx
f0100b8f:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0100b95:	72 12                	jb     f0100ba9 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b97:	50                   	push   %eax
f0100b98:	68 70 3e 10 f0       	push   $0xf0103e70
f0100b9d:	6a 52                	push   $0x52
f0100b9f:	68 18 46 10 f0       	push   $0xf0104618
f0100ba4:	e8 4f f5 ff ff       	call   f01000f8 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100ba9:	83 ec 04             	sub    $0x4,%esp
f0100bac:	68 80 00 00 00       	push   $0x80
f0100bb1:	68 97 00 00 00       	push   $0x97
f0100bb6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100bbb:	50                   	push   %eax
f0100bbc:	e8 b1 27 00 00       	call   f0103372 <memset>
f0100bc1:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bc4:	8b 1b                	mov    (%ebx),%ebx
f0100bc6:	85 db                	test   %ebx,%ebx
f0100bc8:	75 a9                	jne    f0100b73 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100bca:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bcf:	e8 57 fe ff ff       	call   f0100a2b <boot_alloc>
f0100bd4:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bd7:	8b 15 3c 75 11 f0    	mov    0xf011753c,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100bdd:	8b 0d 6c 79 11 f0    	mov    0xf011796c,%ecx
		assert(pp < pages + npages);
f0100be3:	a1 64 79 11 f0       	mov    0xf0117964,%eax
f0100be8:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100beb:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100bee:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100bf1:	be 00 00 00 00       	mov    $0x0,%esi
f0100bf6:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bf9:	e9 30 01 00 00       	jmp    f0100d2e <check_page_free_list+0x23e>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100bfe:	39 ca                	cmp    %ecx,%edx
f0100c00:	73 19                	jae    f0100c1b <check_page_free_list+0x12b>
f0100c02:	68 26 46 10 f0       	push   $0xf0104626
f0100c07:	68 32 46 10 f0       	push   $0xf0104632
f0100c0c:	68 3c 02 00 00       	push   $0x23c
f0100c11:	68 0c 46 10 f0       	push   $0xf010460c
f0100c16:	e8 dd f4 ff ff       	call   f01000f8 <_panic>
		assert(pp < pages + npages);
f0100c1b:	39 fa                	cmp    %edi,%edx
f0100c1d:	72 19                	jb     f0100c38 <check_page_free_list+0x148>
f0100c1f:	68 47 46 10 f0       	push   $0xf0104647
f0100c24:	68 32 46 10 f0       	push   $0xf0104632
f0100c29:	68 3d 02 00 00       	push   $0x23d
f0100c2e:	68 0c 46 10 f0       	push   $0xf010460c
f0100c33:	e8 c0 f4 ff ff       	call   f01000f8 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c38:	89 d0                	mov    %edx,%eax
f0100c3a:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100c3d:	a8 07                	test   $0x7,%al
f0100c3f:	74 19                	je     f0100c5a <check_page_free_list+0x16a>
f0100c41:	68 b8 3e 10 f0       	push   $0xf0103eb8
f0100c46:	68 32 46 10 f0       	push   $0xf0104632
f0100c4b:	68 3e 02 00 00       	push   $0x23e
f0100c50:	68 0c 46 10 f0       	push   $0xf010460c
f0100c55:	e8 9e f4 ff ff       	call   f01000f8 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c5a:	c1 f8 03             	sar    $0x3,%eax
f0100c5d:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100c60:	85 c0                	test   %eax,%eax
f0100c62:	75 19                	jne    f0100c7d <check_page_free_list+0x18d>
f0100c64:	68 5b 46 10 f0       	push   $0xf010465b
f0100c69:	68 32 46 10 f0       	push   $0xf0104632
f0100c6e:	68 41 02 00 00       	push   $0x241
f0100c73:	68 0c 46 10 f0       	push   $0xf010460c
f0100c78:	e8 7b f4 ff ff       	call   f01000f8 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c7d:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100c82:	75 19                	jne    f0100c9d <check_page_free_list+0x1ad>
f0100c84:	68 6c 46 10 f0       	push   $0xf010466c
f0100c89:	68 32 46 10 f0       	push   $0xf0104632
f0100c8e:	68 42 02 00 00       	push   $0x242
f0100c93:	68 0c 46 10 f0       	push   $0xf010460c
f0100c98:	e8 5b f4 ff ff       	call   f01000f8 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c9d:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100ca2:	75 19                	jne    f0100cbd <check_page_free_list+0x1cd>
f0100ca4:	68 ec 3e 10 f0       	push   $0xf0103eec
f0100ca9:	68 32 46 10 f0       	push   $0xf0104632
f0100cae:	68 43 02 00 00       	push   $0x243
f0100cb3:	68 0c 46 10 f0       	push   $0xf010460c
f0100cb8:	e8 3b f4 ff ff       	call   f01000f8 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100cbd:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100cc2:	75 19                	jne    f0100cdd <check_page_free_list+0x1ed>
f0100cc4:	68 85 46 10 f0       	push   $0xf0104685
f0100cc9:	68 32 46 10 f0       	push   $0xf0104632
f0100cce:	68 44 02 00 00       	push   $0x244
f0100cd3:	68 0c 46 10 f0       	push   $0xf010460c
f0100cd8:	e8 1b f4 ff ff       	call   f01000f8 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100cdd:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100ce2:	76 3f                	jbe    f0100d23 <check_page_free_list+0x233>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ce4:	89 c3                	mov    %eax,%ebx
f0100ce6:	c1 eb 0c             	shr    $0xc,%ebx
f0100ce9:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0100cec:	77 12                	ja     f0100d00 <check_page_free_list+0x210>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100cee:	50                   	push   %eax
f0100cef:	68 70 3e 10 f0       	push   $0xf0103e70
f0100cf4:	6a 52                	push   $0x52
f0100cf6:	68 18 46 10 f0       	push   $0xf0104618
f0100cfb:	e8 f8 f3 ff ff       	call   f01000f8 <_panic>
f0100d00:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100d05:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100d08:	76 1e                	jbe    f0100d28 <check_page_free_list+0x238>
f0100d0a:	68 10 3f 10 f0       	push   $0xf0103f10
f0100d0f:	68 32 46 10 f0       	push   $0xf0104632
f0100d14:	68 45 02 00 00       	push   $0x245
f0100d19:	68 0c 46 10 f0       	push   $0xf010460c
f0100d1e:	e8 d5 f3 ff ff       	call   f01000f8 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100d23:	83 c6 01             	add    $0x1,%esi
f0100d26:	eb 04                	jmp    f0100d2c <check_page_free_list+0x23c>
		else
			++nfree_extmem;
f0100d28:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d2c:	8b 12                	mov    (%edx),%edx
f0100d2e:	85 d2                	test   %edx,%edx
f0100d30:	0f 85 c8 fe ff ff    	jne    f0100bfe <check_page_free_list+0x10e>
f0100d36:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100d39:	85 f6                	test   %esi,%esi
f0100d3b:	7f 19                	jg     f0100d56 <check_page_free_list+0x266>
f0100d3d:	68 9f 46 10 f0       	push   $0xf010469f
f0100d42:	68 32 46 10 f0       	push   $0xf0104632
f0100d47:	68 4d 02 00 00       	push   $0x24d
f0100d4c:	68 0c 46 10 f0       	push   $0xf010460c
f0100d51:	e8 a2 f3 ff ff       	call   f01000f8 <_panic>
	assert(nfree_extmem > 0);
f0100d56:	85 db                	test   %ebx,%ebx
f0100d58:	7f 19                	jg     f0100d73 <check_page_free_list+0x283>
f0100d5a:	68 b1 46 10 f0       	push   $0xf01046b1
f0100d5f:	68 32 46 10 f0       	push   $0xf0104632
f0100d64:	68 4e 02 00 00       	push   $0x24e
f0100d69:	68 0c 46 10 f0       	push   $0xf010460c
f0100d6e:	e8 85 f3 ff ff       	call   f01000f8 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100d73:	83 ec 0c             	sub    $0xc,%esp
f0100d76:	68 58 3f 10 f0       	push   $0xf0103f58
f0100d7b:	e8 38 1b 00 00       	call   f01028b8 <cprintf>
}
f0100d80:	eb 29                	jmp    f0100dab <check_page_free_list+0x2bb>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100d82:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f0100d87:	85 c0                	test   %eax,%eax
f0100d89:	0f 85 8e fd ff ff    	jne    f0100b1d <check_page_free_list+0x2d>
f0100d8f:	e9 72 fd ff ff       	jmp    f0100b06 <check_page_free_list+0x16>
f0100d94:	83 3d 3c 75 11 f0 00 	cmpl   $0x0,0xf011753c
f0100d9b:	0f 84 65 fd ff ff    	je     f0100b06 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100da1:	be 00 04 00 00       	mov    $0x400,%esi
f0100da6:	e9 c0 fd ff ff       	jmp    f0100b6b <check_page_free_list+0x7b>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f0100dab:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100dae:	5b                   	pop    %ebx
f0100daf:	5e                   	pop    %esi
f0100db0:	5f                   	pop    %edi
f0100db1:	5d                   	pop    %ebp
f0100db2:	c3                   	ret    

f0100db3 <page_init>:
// After this is done, NEVER use boot_alloc again.  ONLY use the page
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void) {
f0100db3:	55                   	push   %ebp
f0100db4:	89 e5                	mov    %esp,%ebp
f0100db6:	56                   	push   %esi
f0100db7:	53                   	push   %ebx
	// The example code here marks all physical pages as free.
	// However this is not truly the case.  What memory is free?
	//  1) Mark physical page 0 as in use.
	//     This way we preserve the real-mode IDT and BIOS structures
	//     in case we ever need them.  (Currently we don't, but...)
	pages[0].pp_ref = 1;
f0100db8:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f0100dbd:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages[0].pp_link = 0;
f0100dc3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	//  2) The rest of base memory, [PGSIZE, npages_basemem * PGSIZE)
	//     is free.
	int i = 1;
	for (; i < npages_basemem; i++) {
f0100dc9:	8b 35 40 75 11 f0    	mov    0xf0117540,%esi
f0100dcf:	8b 1d 3c 75 11 f0    	mov    0xf011753c,%ebx
f0100dd5:	ba 00 00 00 00       	mov    $0x0,%edx
	//     in case we ever need them.  (Currently we don't, but...)
	pages[0].pp_ref = 1;
	pages[0].pp_link = 0;
	//  2) The rest of base memory, [PGSIZE, npages_basemem * PGSIZE)
	//     is free.
	int i = 1;
f0100dda:	b8 01 00 00 00       	mov    $0x1,%eax
	for (; i < npages_basemem; i++) {
f0100ddf:	eb 27                	jmp    f0100e08 <page_init+0x55>
f0100de1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f0100de8:	89 d1                	mov    %edx,%ecx
f0100dea:	03 0d 6c 79 11 f0    	add    0xf011796c,%ecx
f0100df0:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100df6:	89 19                	mov    %ebx,(%ecx)
	pages[0].pp_ref = 1;
	pages[0].pp_link = 0;
	//  2) The rest of base memory, [PGSIZE, npages_basemem * PGSIZE)
	//     is free.
	int i = 1;
	for (; i < npages_basemem; i++) {
f0100df8:	83 c0 01             	add    $0x1,%eax
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
f0100dfb:	89 d3                	mov    %edx,%ebx
f0100dfd:	03 1d 6c 79 11 f0    	add    0xf011796c,%ebx
f0100e03:	ba 01 00 00 00       	mov    $0x1,%edx
	pages[0].pp_ref = 1;
	pages[0].pp_link = 0;
	//  2) The rest of base memory, [PGSIZE, npages_basemem * PGSIZE)
	//     is free.
	int i = 1;
	for (; i < npages_basemem; i++) {
f0100e08:	39 c6                	cmp    %eax,%esi
f0100e0a:	77 d5                	ja     f0100de1 <page_init+0x2e>
f0100e0c:	84 d2                	test   %dl,%dl
f0100e0e:	74 06                	je     f0100e16 <page_init+0x63>
f0100e10:	89 1d 3c 75 11 f0    	mov    %ebx,0xf011753c
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	//  3) Then comes the IO hole [IOPHYSMEM, EXTPHYSMEM), which must
	//     never be allocated.
	assert(npages_basemem==IOPHYSMEM/PGSIZE);
f0100e16:	81 fe a0 00 00 00    	cmp    $0xa0,%esi
f0100e1c:	74 19                	je     f0100e37 <page_init+0x84>
f0100e1e:	68 7c 3f 10 f0       	push   $0xf0103f7c
f0100e23:	68 32 46 10 f0       	push   $0xf0104632
f0100e28:	68 0a 01 00 00       	push   $0x10a
f0100e2d:	68 0c 46 10 f0       	push   $0xf010460c
f0100e32:	e8 c1 f2 ff ff       	call   f01000f8 <_panic>
f0100e37:	b8 00 05 00 00       	mov    $0x500,%eax
	for (i = IOPHYSMEM / PGSIZE; i < EXTPHYSMEM / PGSIZE; i++) {
		pages[i].pp_ref = 1;
f0100e3c:	89 c2                	mov    %eax,%edx
f0100e3e:	03 15 6c 79 11 f0    	add    0xf011796c,%edx
f0100e44:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
		pages[i].pp_link = 0;
f0100e4a:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
f0100e50:	83 c0 08             	add    $0x8,%eax
		page_free_list = &pages[i];
	}
	//  3) Then comes the IO hole [IOPHYSMEM, EXTPHYSMEM), which must
	//     never be allocated.
	assert(npages_basemem==IOPHYSMEM/PGSIZE);
	for (i = IOPHYSMEM / PGSIZE; i < EXTPHYSMEM / PGSIZE; i++) {
f0100e53:	3d 00 08 00 00       	cmp    $0x800,%eax
f0100e58:	75 e2                	jne    f0100e3c <page_init+0x89>
f0100e5a:	bb 00 01 00 00       	mov    $0x100,%ebx
f0100e5f:	eb 17                	jmp    f0100e78 <page_init+0xc5>
	//     in physical memory?  Which pages are already in use for
	//     page tables and other data structures?
	//
	// from pages to kernbase is in use, else is free
	for (i = EXTPHYSMEM / PGSIZE; i < ((uint32_t) boot_alloc(0) - KERNBASE) >> PGSHIFT; i++) {
		pages[i].pp_ref = 1;
f0100e61:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f0100e66:	8d 04 d8             	lea    (%eax,%ebx,8),%eax
f0100e69:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
		pages[i].pp_link = 0;
f0100e6f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	//     Some of it is in use, some is free. Where is the kernel
	//     in physical memory?  Which pages are already in use for
	//     page tables and other data structures?
	//
	// from pages to kernbase is in use, else is free
	for (i = EXTPHYSMEM / PGSIZE; i < ((uint32_t) boot_alloc(0) - KERNBASE) >> PGSHIFT; i++) {
f0100e75:	83 c3 01             	add    $0x1,%ebx
f0100e78:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e7d:	e8 a9 fb ff ff       	call   f0100a2b <boot_alloc>
f0100e82:	05 00 00 00 10       	add    $0x10000000,%eax
f0100e87:	c1 e8 0c             	shr    $0xc,%eax
f0100e8a:	39 d8                	cmp    %ebx,%eax
f0100e8c:	77 d3                	ja     f0100e61 <page_init+0xae>
		pages[i].pp_ref = 1;
		pages[i].pp_link = 0;
	}

	for (i = ((uint32_t) boot_alloc(0) - KERNBASE) >> PGSHIFT; i < npages; i++) {
f0100e8e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e93:	e8 93 fb ff ff       	call   f0100a2b <boot_alloc>
f0100e98:	05 00 00 00 10       	add    $0x10000000,%eax
f0100e9d:	c1 e8 0c             	shr    $0xc,%eax
f0100ea0:	89 c2                	mov    %eax,%edx
f0100ea2:	8b 1d 3c 75 11 f0    	mov    0xf011753c,%ebx
f0100ea8:	c1 e0 03             	shl    $0x3,%eax
f0100eab:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100eb0:	eb 23                	jmp    f0100ed5 <page_init+0x122>
		pages[i].pp_ref = 0;
f0100eb2:	89 c1                	mov    %eax,%ecx
f0100eb4:	03 0d 6c 79 11 f0    	add    0xf011796c,%ecx
f0100eba:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100ec0:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f0100ec2:	89 c3                	mov    %eax,%ebx
f0100ec4:	03 1d 6c 79 11 f0    	add    0xf011796c,%ebx
	for (i = EXTPHYSMEM / PGSIZE; i < ((uint32_t) boot_alloc(0) - KERNBASE) >> PGSHIFT; i++) {
		pages[i].pp_ref = 1;
		pages[i].pp_link = 0;
	}

	for (i = ((uint32_t) boot_alloc(0) - KERNBASE) >> PGSHIFT; i < npages; i++) {
f0100eca:	83 c2 01             	add    $0x1,%edx
f0100ecd:	83 c0 08             	add    $0x8,%eax
f0100ed0:	b9 01 00 00 00       	mov    $0x1,%ecx
f0100ed5:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0100edb:	72 d5                	jb     f0100eb2 <page_init+0xff>
f0100edd:	84 c9                	test   %cl,%cl
f0100edf:	74 06                	je     f0100ee7 <page_init+0x134>
f0100ee1:	89 1d 3c 75 11 f0    	mov    %ebx,0xf011753c
		page_free_list = &pages[i];
	}
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
}
f0100ee7:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100eea:	5b                   	pop    %ebx
f0100eeb:	5e                   	pop    %esi
f0100eec:	5d                   	pop    %ebp
f0100eed:	c3                   	ret    

f0100eee <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100eee:	55                   	push   %ebp
f0100eef:	89 e5                	mov    %esp,%ebp
f0100ef1:	53                   	push   %ebx
f0100ef2:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
	if(page_free_list==0) return 0;
f0100ef5:	8b 1d 3c 75 11 f0    	mov    0xf011753c,%ebx
f0100efb:	85 db                	test   %ebx,%ebx
f0100efd:	74 58                	je     f0100f57 <page_alloc+0x69>

	struct PageInfo * alloc_page = page_free_list;
	page_free_list = page_free_list->pp_link;
f0100eff:	8b 03                	mov    (%ebx),%eax
f0100f01:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
	alloc_page->pp_link = 0;
f0100f06:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if(alloc_flags&ALLOC_ZERO)
f0100f0c:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100f10:	74 45                	je     f0100f57 <page_alloc+0x69>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f12:	89 d8                	mov    %ebx,%eax
f0100f14:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0100f1a:	c1 f8 03             	sar    $0x3,%eax
f0100f1d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f20:	89 c2                	mov    %eax,%edx
f0100f22:	c1 ea 0c             	shr    $0xc,%edx
f0100f25:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0100f2b:	72 12                	jb     f0100f3f <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f2d:	50                   	push   %eax
f0100f2e:	68 70 3e 10 f0       	push   $0xf0103e70
f0100f33:	6a 52                	push   $0x52
f0100f35:	68 18 46 10 f0       	push   $0xf0104618
f0100f3a:	e8 b9 f1 ff ff       	call   f01000f8 <_panic>
		memset(page2kva(alloc_page), 0, PGSIZE);
f0100f3f:	83 ec 04             	sub    $0x4,%esp
f0100f42:	68 00 10 00 00       	push   $0x1000
f0100f47:	6a 00                	push   $0x0
f0100f49:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100f4e:	50                   	push   %eax
f0100f4f:	e8 1e 24 00 00       	call   f0103372 <memset>
f0100f54:	83 c4 10             	add    $0x10,%esp
	return alloc_page;
}
f0100f57:	89 d8                	mov    %ebx,%eax
f0100f59:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f5c:	c9                   	leave  
f0100f5d:	c3                   	ret    

f0100f5e <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100f5e:	55                   	push   %ebp
f0100f5f:	89 e5                	mov    %esp,%ebp
f0100f61:	83 ec 08             	sub    $0x8,%esp
f0100f64:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	assert(!pp->pp_ref||!pp->pp_link);
f0100f67:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100f6c:	74 1e                	je     f0100f8c <page_free+0x2e>
f0100f6e:	83 38 00             	cmpl   $0x0,(%eax)
f0100f71:	74 19                	je     f0100f8c <page_free+0x2e>
f0100f73:	68 c2 46 10 f0       	push   $0xf01046c2
f0100f78:	68 32 46 10 f0       	push   $0xf0104632
f0100f7d:	68 48 01 00 00       	push   $0x148
f0100f82:	68 0c 46 10 f0       	push   $0xf010460c
f0100f87:	e8 6c f1 ff ff       	call   f01000f8 <_panic>
	pp->pp_link = page_free_list;
f0100f8c:	8b 15 3c 75 11 f0    	mov    0xf011753c,%edx
f0100f92:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100f94:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
}
f0100f99:	c9                   	leave  
f0100f9a:	c3                   	ret    

f0100f9b <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100f9b:	55                   	push   %ebp
f0100f9c:	89 e5                	mov    %esp,%ebp
f0100f9e:	83 ec 08             	sub    $0x8,%esp
f0100fa1:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100fa4:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100fa8:	83 e8 01             	sub    $0x1,%eax
f0100fab:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100faf:	66 85 c0             	test   %ax,%ax
f0100fb2:	75 0c                	jne    f0100fc0 <page_decref+0x25>
		page_free(pp);
f0100fb4:	83 ec 0c             	sub    $0xc,%esp
f0100fb7:	52                   	push   %edx
f0100fb8:	e8 a1 ff ff ff       	call   f0100f5e <page_free>
f0100fbd:	83 c4 10             	add    $0x10,%esp
}
f0100fc0:	c9                   	leave  
f0100fc1:	c3                   	ret    

f0100fc2 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100fc2:	55                   	push   %ebp
f0100fc3:	89 e5                	mov    %esp,%ebp
f0100fc5:	56                   	push   %esi
f0100fc6:	53                   	push   %ebx
f0100fc7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	// from from pgdir get pgdir_entry;
	uint32_t dir_inx = PDX(va);
	uint32_t table_inx = PTX(va);
f0100fca:	89 de                	mov    %ebx,%esi
f0100fcc:	c1 ee 0c             	shr    $0xc,%esi
f0100fcf:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	// from pgdir get pd_entry
	pde_t pd_entry = 0;
    pd_entry = pgdir[dir_inx];
f0100fd5:	c1 eb 16             	shr    $0x16,%ebx
f0100fd8:	c1 e3 02             	shl    $0x2,%ebx
f0100fdb:	03 5d 08             	add    0x8(%ebp),%ebx
f0100fde:	8b 03                	mov    (%ebx),%eax
	pte_t *pgtable = 0;
	//if present0;
	if(pd_entry&PTE_P){
f0100fe0:	a8 01                	test   $0x1,%al
f0100fe2:	74 2e                	je     f0101012 <pgdir_walk+0x50>
		// from pd_entry get pg_table
		pgtable = KADDR(PTE_ADDR(pd_entry));
f0100fe4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fe9:	89 c2                	mov    %eax,%edx
f0100feb:	c1 ea 0c             	shr    $0xc,%edx
f0100fee:	39 15 64 79 11 f0    	cmp    %edx,0xf0117964
f0100ff4:	77 15                	ja     f010100b <pgdir_walk+0x49>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ff6:	50                   	push   %eax
f0100ff7:	68 70 3e 10 f0       	push   $0xf0103e70
f0100ffc:	68 7c 01 00 00       	push   $0x17c
f0101001:	68 0c 46 10 f0       	push   $0xf010460c
f0101006:	e8 ed f0 ff ff       	call   f01000f8 <_panic>
	return (void *)(pa + KERNBASE);
f010100b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101010:	eb 64                	jmp    f0101076 <pgdir_walk+0xb4>
	uint32_t dir_inx = PDX(va);
	uint32_t table_inx = PTX(va);
	// from pgdir get pd_entry
	pde_t pd_entry = 0;
    pd_entry = pgdir[dir_inx];
	pte_t *pgtable = 0;
f0101012:	b8 00 00 00 00       	mov    $0x0,%eax
	//if present0;
	if(pd_entry&PTE_P){
		// from pd_entry get pg_table
		pgtable = KADDR(PTE_ADDR(pd_entry));
	} else if (create){
f0101017:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010101b:	74 59                	je     f0101076 <pgdir_walk+0xb4>
		struct PageInfo * allo_page = page_alloc(ALLOC_ZERO);
f010101d:	83 ec 0c             	sub    $0xc,%esp
f0101020:	6a 01                	push   $0x1
f0101022:	e8 c7 fe ff ff       	call   f0100eee <page_alloc>
		if(!allo_page) return NULL;
f0101027:	83 c4 10             	add    $0x10,%esp
f010102a:	85 c0                	test   %eax,%eax
f010102c:	74 4d                	je     f010107b <pgdir_walk+0xb9>
		allo_page->pp_ref++;
f010102e:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
		pgdir[dir_inx] = page2pa(allo_page)| PTE_P | PTE_W | PTE_U;
f0101033:	89 c2                	mov    %eax,%edx
f0101035:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f010103b:	c1 fa 03             	sar    $0x3,%edx
f010103e:	c1 e2 0c             	shl    $0xc,%edx
f0101041:	83 ca 07             	or     $0x7,%edx
f0101044:	89 13                	mov    %edx,(%ebx)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101046:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f010104c:	c1 f8 03             	sar    $0x3,%eax
f010104f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101052:	89 c2                	mov    %eax,%edx
f0101054:	c1 ea 0c             	shr    $0xc,%edx
f0101057:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f010105d:	72 12                	jb     f0101071 <pgdir_walk+0xaf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010105f:	50                   	push   %eax
f0101060:	68 70 3e 10 f0       	push   $0xf0103e70
f0101065:	6a 52                	push   $0x52
f0101067:	68 18 46 10 f0       	push   $0xf0104618
f010106c:	e8 87 f0 ff ff       	call   f01000f8 <_panic>
	return (void *)(pa + KERNBASE);
f0101071:	2d 00 00 00 10       	sub    $0x10000000,%eax
		pgtable = page2kva(allo_page);
	}
	return  &pgtable[table_inx];
f0101076:	8d 04 b0             	lea    (%eax,%esi,4),%eax
f0101079:	eb 05                	jmp    f0101080 <pgdir_walk+0xbe>
	if(pd_entry&PTE_P){
		// from pd_entry get pg_table
		pgtable = KADDR(PTE_ADDR(pd_entry));
	} else if (create){
		struct PageInfo * allo_page = page_alloc(ALLOC_ZERO);
		if(!allo_page) return NULL;
f010107b:	b8 00 00 00 00       	mov    $0x0,%eax
		allo_page->pp_ref++;
		pgdir[dir_inx] = page2pa(allo_page)| PTE_P | PTE_W | PTE_U;
		pgtable = page2kva(allo_page);
	}
	return  &pgtable[table_inx];
}
f0101080:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101083:	5b                   	pop    %ebx
f0101084:	5e                   	pop    %esi
f0101085:	5d                   	pop    %ebp
f0101086:	c3                   	ret    

f0101087 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101087:	55                   	push   %ebp
f0101088:	89 e5                	mov    %esp,%ebp
f010108a:	57                   	push   %edi
f010108b:	56                   	push   %esi
f010108c:	53                   	push   %ebx
f010108d:	83 ec 1c             	sub    $0x1c,%esp
f0101090:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101093:	89 cf                	mov    %ecx,%edi
	// Fill this function in
    // per pagetable_entry manage a page(PAGESIZE);
    // per pgdirtable entry manage a page*2^10 (4M)
    while (size){
f0101095:	89 d3                	mov    %edx,%ebx
f0101097:	8b 45 08             	mov    0x8(%ebp),%eax
f010109a:	29 d0                	sub    %edx,%eax
f010109c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        pte_t *pt_entry = pgdir_walk(pgdir, (void *)va, 1);
        if(pt_entry==0) return;

        *pt_entry = pa|perm|PTE_P;
f010109f:	8b 45 0c             	mov    0xc(%ebp),%eax
f01010a2:	83 c8 01             	or     $0x1,%eax
f01010a5:	89 45 dc             	mov    %eax,-0x24(%ebp)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
    // per pagetable_entry manage a page(PAGESIZE);
    // per pgdirtable entry manage a page*2^10 (4M)
    while (size){
f01010a8:	eb 26                	jmp    f01010d0 <boot_map_region+0x49>
        pte_t *pt_entry = pgdir_walk(pgdir, (void *)va, 1);
f01010aa:	83 ec 04             	sub    $0x4,%esp
f01010ad:	6a 01                	push   $0x1
f01010af:	53                   	push   %ebx
f01010b0:	ff 75 e0             	pushl  -0x20(%ebp)
f01010b3:	e8 0a ff ff ff       	call   f0100fc2 <pgdir_walk>
        if(pt_entry==0) return;
f01010b8:	83 c4 10             	add    $0x10,%esp
f01010bb:	85 c0                	test   %eax,%eax
f01010bd:	74 1b                	je     f01010da <boot_map_region+0x53>

        *pt_entry = pa|perm|PTE_P;
f01010bf:	0b 75 dc             	or     -0x24(%ebp),%esi
f01010c2:	89 30                	mov    %esi,(%eax)
        size -= PGSIZE;
f01010c4:	81 ef 00 10 00 00    	sub    $0x1000,%edi
        va += PGSIZE;
f01010ca:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01010d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01010d3:	8d 34 18             	lea    (%eax,%ebx,1),%esi
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
    // per pagetable_entry manage a page(PAGESIZE);
    // per pgdirtable entry manage a page*2^10 (4M)
    while (size){
f01010d6:	85 ff                	test   %edi,%edi
f01010d8:	75 d0                	jne    f01010aa <boot_map_region+0x23>
        size -= PGSIZE;
        va += PGSIZE;
        pa += PGSIZE;
    }

}
f01010da:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010dd:	5b                   	pop    %ebx
f01010de:	5e                   	pop    %esi
f01010df:	5f                   	pop    %edi
f01010e0:	5d                   	pop    %ebp
f01010e1:	c3                   	ret    

f01010e2 <page_lookup>:
// Hint: the TA solution uses pgdir_walk and pa2page.
//
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01010e2:	55                   	push   %ebp
f01010e3:	89 e5                	mov    %esp,%ebp
f01010e5:	53                   	push   %ebx
f01010e6:	83 ec 08             	sub    $0x8,%esp
f01010e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
    pte_t *pt_entry = pgdir_walk(pgdir, va, 0);
f01010ec:	6a 00                	push   $0x0
f01010ee:	ff 75 0c             	pushl  0xc(%ebp)
f01010f1:	ff 75 08             	pushl  0x8(%ebp)
f01010f4:	e8 c9 fe ff ff       	call   f0100fc2 <pgdir_walk>
    if (pt_entry==NULL) return NULL;
f01010f9:	83 c4 10             	add    $0x10,%esp
f01010fc:	85 c0                	test   %eax,%eax
f01010fe:	74 3a                	je     f010113a <page_lookup+0x58>
    physaddr_t addr = PTE_ADDR(*pt_entry);
f0101100:	8b 10                	mov    (%eax),%edx
f0101102:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
    if (pte_store!=0) *pte_store = pt_entry;
f0101108:	85 db                	test   %ebx,%ebx
f010110a:	74 02                	je     f010110e <page_lookup+0x2c>
f010110c:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010110e:	89 d0                	mov    %edx,%eax
f0101110:	c1 e8 0c             	shr    $0xc,%eax
f0101113:	3b 05 64 79 11 f0    	cmp    0xf0117964,%eax
f0101119:	72 14                	jb     f010112f <page_lookup+0x4d>
		panic("pa2page called with invalid pa");
f010111b:	83 ec 04             	sub    $0x4,%esp
f010111e:	68 a0 3f 10 f0       	push   $0xf0103fa0
f0101123:	6a 4b                	push   $0x4b
f0101125:	68 18 46 10 f0       	push   $0xf0104618
f010112a:	e8 c9 ef ff ff       	call   f01000f8 <_panic>
	return &pages[PGNUM(pa)];
f010112f:	8b 15 6c 79 11 f0    	mov    0xf011796c,%edx
f0101135:	8d 04 c2             	lea    (%edx,%eax,8),%eax

	return pa2page(addr);
f0101138:	eb 05                	jmp    f010113f <page_lookup+0x5d>
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	// Fill this function in
    pte_t *pt_entry = pgdir_walk(pgdir, va, 0);
    if (pt_entry==NULL) return NULL;
f010113a:	b8 00 00 00 00       	mov    $0x0,%eax
    physaddr_t addr = PTE_ADDR(*pt_entry);
    if (pte_store!=0) *pte_store = pt_entry;

	return pa2page(addr);
}
f010113f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101142:	c9                   	leave  
f0101143:	c3                   	ret    

f0101144 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101144:	55                   	push   %ebp
f0101145:	89 e5                	mov    %esp,%ebp
f0101147:	53                   	push   %ebx
f0101148:	83 ec 18             	sub    $0x18,%esp
f010114b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
    pte_t *pte_store;
    struct PageInfo * pageInfo = 0;
    pageInfo = page_lookup(pgdir, va, &pte_store);
f010114e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101151:	50                   	push   %eax
f0101152:	53                   	push   %ebx
f0101153:	ff 75 08             	pushl  0x8(%ebp)
f0101156:	e8 87 ff ff ff       	call   f01010e2 <page_lookup>
    if (pageInfo==NULL) return;
f010115b:	83 c4 10             	add    $0x10,%esp
f010115e:	85 c0                	test   %eax,%eax
f0101160:	74 29                	je     f010118b <page_remove+0x47>

    pageInfo->pp_ref--;
f0101162:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
f0101166:	8d 51 ff             	lea    -0x1(%ecx),%edx
f0101169:	66 89 50 04          	mov    %dx,0x4(%eax)
    if (pageInfo->pp_ref==0){
f010116d:	66 85 d2             	test   %dx,%dx
f0101170:	75 0d                	jne    f010117f <page_remove+0x3b>
        pageInfo->pp_link = page_free_list;
f0101172:	8b 15 3c 75 11 f0    	mov    0xf011753c,%edx
f0101178:	89 10                	mov    %edx,(%eax)
        page_free_list = pageInfo;
f010117a:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
    }
    *pte_store = 0;
f010117f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101182:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101188:	0f 01 3b             	invlpg (%ebx)
    tlb_invalidate(pgdir, va);


}
f010118b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010118e:	c9                   	leave  
f010118f:	c3                   	ret    

f0101190 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101190:	55                   	push   %ebp
f0101191:	89 e5                	mov    %esp,%ebp
f0101193:	57                   	push   %edi
f0101194:	56                   	push   %esi
f0101195:	53                   	push   %ebx
f0101196:	83 ec 10             	sub    $0x10,%esp
f0101199:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010119c:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
    // check wheather va is mapped;
    pte_t *pte_entry = pgdir_walk(pgdir, va, 1);
f010119f:	6a 01                	push   $0x1
f01011a1:	57                   	push   %edi
f01011a2:	ff 75 08             	pushl  0x8(%ebp)
f01011a5:	e8 18 fe ff ff       	call   f0100fc2 <pgdir_walk>
    if (pte_entry==0) return -E_NO_MEM;
f01011aa:	83 c4 10             	add    $0x10,%esp
f01011ad:	85 c0                	test   %eax,%eax
f01011af:	74 3b                	je     f01011ec <page_insert+0x5c>
f01011b1:	89 c6                	mov    %eax,%esi
    pp->pp_ref++;  // important
f01011b3:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
    // has no mem
    if (*pte_entry&PTE_P){
f01011b8:	f6 00 01             	testb  $0x1,(%eax)
f01011bb:	74 0f                	je     f01011cc <page_insert+0x3c>
        page_remove(pgdir, va);
f01011bd:	83 ec 08             	sub    $0x8,%esp
f01011c0:	57                   	push   %edi
f01011c1:	ff 75 08             	pushl  0x8(%ebp)
f01011c4:	e8 7b ff ff ff       	call   f0101144 <page_remove>
f01011c9:	83 c4 10             	add    $0x10,%esp
    }
    *pte_entry = page2pa(pp)|perm|PTE_P;
f01011cc:	2b 1d 6c 79 11 f0    	sub    0xf011796c,%ebx
f01011d2:	c1 fb 03             	sar    $0x3,%ebx
f01011d5:	c1 e3 0c             	shl    $0xc,%ebx
f01011d8:	8b 45 14             	mov    0x14(%ebp),%eax
f01011db:	83 c8 01             	or     $0x1,%eax
f01011de:	09 c3                	or     %eax,%ebx
f01011e0:	89 1e                	mov    %ebx,(%esi)
f01011e2:	0f 01 3f             	invlpg (%edi)
    tlb_invalidate(pgdir, va);
	return 0;
f01011e5:	b8 00 00 00 00       	mov    $0x0,%eax
f01011ea:	eb 05                	jmp    f01011f1 <page_insert+0x61>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	// Fill this function in
    // check wheather va is mapped;
    pte_t *pte_entry = pgdir_walk(pgdir, va, 1);
    if (pte_entry==0) return -E_NO_MEM;
f01011ec:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
        page_remove(pgdir, va);
    }
    *pte_entry = page2pa(pp)|perm|PTE_P;
    tlb_invalidate(pgdir, va);
	return 0;
}
f01011f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011f4:	5b                   	pop    %ebx
f01011f5:	5e                   	pop    %esi
f01011f6:	5f                   	pop    %edi
f01011f7:	5d                   	pop    %ebp
f01011f8:	c3                   	ret    

f01011f9 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01011f9:	55                   	push   %ebp
f01011fa:	89 e5                	mov    %esp,%ebp
f01011fc:	57                   	push   %edi
f01011fd:	56                   	push   %esi
f01011fe:	53                   	push   %ebx
f01011ff:	83 ec 2c             	sub    $0x2c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0101202:	b8 15 00 00 00       	mov    $0x15,%eax
f0101207:	e8 57 f8 ff ff       	call   f0100a63 <nvram_read>
f010120c:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f010120e:	b8 17 00 00 00       	mov    $0x17,%eax
f0101213:	e8 4b f8 ff ff       	call   f0100a63 <nvram_read>
f0101218:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010121a:	b8 34 00 00 00       	mov    $0x34,%eax
f010121f:	e8 3f f8 ff ff       	call   f0100a63 <nvram_read>
f0101224:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f0101227:	85 c0                	test   %eax,%eax
f0101229:	74 07                	je     f0101232 <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f010122b:	05 00 40 00 00       	add    $0x4000,%eax
f0101230:	eb 0b                	jmp    f010123d <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f0101232:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101238:	85 f6                	test   %esi,%esi
f010123a:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f010123d:	89 c2                	mov    %eax,%edx
f010123f:	c1 ea 02             	shr    $0x2,%edx
f0101242:	89 15 64 79 11 f0    	mov    %edx,0xf0117964
	npages_basemem = basemem / (PGSIZE / 1024);
f0101248:	89 da                	mov    %ebx,%edx
f010124a:	c1 ea 02             	shr    $0x2,%edx
f010124d:	89 15 40 75 11 f0    	mov    %edx,0xf0117540

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101253:	89 c2                	mov    %eax,%edx
f0101255:	29 da                	sub    %ebx,%edx
f0101257:	52                   	push   %edx
f0101258:	53                   	push   %ebx
f0101259:	50                   	push   %eax
f010125a:	68 c0 3f 10 f0       	push   $0xf0103fc0
f010125f:	e8 54 16 00 00       	call   f01028b8 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101264:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101269:	e8 bd f7 ff ff       	call   f0100a2b <boot_alloc>
f010126e:	a3 68 79 11 f0       	mov    %eax,0xf0117968
	memset(kern_pgdir, 0, PGSIZE);
f0101273:	83 c4 0c             	add    $0xc,%esp
f0101276:	68 00 10 00 00       	push   $0x1000
f010127b:	6a 00                	push   $0x0
f010127d:	50                   	push   %eax
f010127e:	e8 ef 20 00 00       	call   f0103372 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101283:	a1 68 79 11 f0       	mov    0xf0117968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101288:	83 c4 10             	add    $0x10,%esp
f010128b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101290:	77 15                	ja     f01012a7 <mem_init+0xae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101292:	50                   	push   %eax
f0101293:	68 fc 3f 10 f0       	push   $0xf0103ffc
f0101298:	68 91 00 00 00       	push   $0x91
f010129d:	68 0c 46 10 f0       	push   $0xf010460c
f01012a2:	e8 51 ee ff ff       	call   f01000f8 <_panic>
f01012a7:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01012ad:	83 ca 05             	or     $0x5,%edx
f01012b0:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo* )boot_alloc(sizeof(struct PageInfo)*npages);
f01012b6:	a1 64 79 11 f0       	mov    0xf0117964,%eax
f01012bb:	c1 e0 03             	shl    $0x3,%eax
f01012be:	e8 68 f7 ff ff       	call   f0100a2b <boot_alloc>
f01012c3:	a3 6c 79 11 f0       	mov    %eax,0xf011796c
	memset(pages, 0, sizeof(struct PageInfo)*npages);
f01012c8:	83 ec 04             	sub    $0x4,%esp
f01012cb:	8b 0d 64 79 11 f0    	mov    0xf0117964,%ecx
f01012d1:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f01012d8:	52                   	push   %edx
f01012d9:	6a 00                	push   $0x0
f01012db:	50                   	push   %eax
f01012dc:	e8 91 20 00 00       	call   f0103372 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01012e1:	e8 cd fa ff ff       	call   f0100db3 <page_init>

	check_page_free_list(1);
f01012e6:	b8 01 00 00 00       	mov    $0x1,%eax
f01012eb:	e8 00 f8 ff ff       	call   f0100af0 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01012f0:	83 c4 10             	add    $0x10,%esp
f01012f3:	83 3d 6c 79 11 f0 00 	cmpl   $0x0,0xf011796c
f01012fa:	75 17                	jne    f0101313 <mem_init+0x11a>
		panic("'pages' is a null pointer!");
f01012fc:	83 ec 04             	sub    $0x4,%esp
f01012ff:	68 dc 46 10 f0       	push   $0xf01046dc
f0101304:	68 61 02 00 00       	push   $0x261
f0101309:	68 0c 46 10 f0       	push   $0xf010460c
f010130e:	e8 e5 ed ff ff       	call   f01000f8 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101313:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f0101318:	bb 00 00 00 00       	mov    $0x0,%ebx
f010131d:	eb 05                	jmp    f0101324 <mem_init+0x12b>
		++nfree;
f010131f:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101322:	8b 00                	mov    (%eax),%eax
f0101324:	85 c0                	test   %eax,%eax
f0101326:	75 f7                	jne    f010131f <mem_init+0x126>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101328:	83 ec 0c             	sub    $0xc,%esp
f010132b:	6a 00                	push   $0x0
f010132d:	e8 bc fb ff ff       	call   f0100eee <page_alloc>
f0101332:	89 c7                	mov    %eax,%edi
f0101334:	83 c4 10             	add    $0x10,%esp
f0101337:	85 c0                	test   %eax,%eax
f0101339:	75 19                	jne    f0101354 <mem_init+0x15b>
f010133b:	68 f7 46 10 f0       	push   $0xf01046f7
f0101340:	68 32 46 10 f0       	push   $0xf0104632
f0101345:	68 69 02 00 00       	push   $0x269
f010134a:	68 0c 46 10 f0       	push   $0xf010460c
f010134f:	e8 a4 ed ff ff       	call   f01000f8 <_panic>
	assert((pp1 = page_alloc(0)));
f0101354:	83 ec 0c             	sub    $0xc,%esp
f0101357:	6a 00                	push   $0x0
f0101359:	e8 90 fb ff ff       	call   f0100eee <page_alloc>
f010135e:	89 c6                	mov    %eax,%esi
f0101360:	83 c4 10             	add    $0x10,%esp
f0101363:	85 c0                	test   %eax,%eax
f0101365:	75 19                	jne    f0101380 <mem_init+0x187>
f0101367:	68 0d 47 10 f0       	push   $0xf010470d
f010136c:	68 32 46 10 f0       	push   $0xf0104632
f0101371:	68 6a 02 00 00       	push   $0x26a
f0101376:	68 0c 46 10 f0       	push   $0xf010460c
f010137b:	e8 78 ed ff ff       	call   f01000f8 <_panic>
	assert((pp2 = page_alloc(0)));
f0101380:	83 ec 0c             	sub    $0xc,%esp
f0101383:	6a 00                	push   $0x0
f0101385:	e8 64 fb ff ff       	call   f0100eee <page_alloc>
f010138a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010138d:	83 c4 10             	add    $0x10,%esp
f0101390:	85 c0                	test   %eax,%eax
f0101392:	75 19                	jne    f01013ad <mem_init+0x1b4>
f0101394:	68 23 47 10 f0       	push   $0xf0104723
f0101399:	68 32 46 10 f0       	push   $0xf0104632
f010139e:	68 6b 02 00 00       	push   $0x26b
f01013a3:	68 0c 46 10 f0       	push   $0xf010460c
f01013a8:	e8 4b ed ff ff       	call   f01000f8 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01013ad:	39 f7                	cmp    %esi,%edi
f01013af:	75 19                	jne    f01013ca <mem_init+0x1d1>
f01013b1:	68 39 47 10 f0       	push   $0xf0104739
f01013b6:	68 32 46 10 f0       	push   $0xf0104632
f01013bb:	68 6e 02 00 00       	push   $0x26e
f01013c0:	68 0c 46 10 f0       	push   $0xf010460c
f01013c5:	e8 2e ed ff ff       	call   f01000f8 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01013ca:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01013cd:	39 c6                	cmp    %eax,%esi
f01013cf:	74 04                	je     f01013d5 <mem_init+0x1dc>
f01013d1:	39 c7                	cmp    %eax,%edi
f01013d3:	75 19                	jne    f01013ee <mem_init+0x1f5>
f01013d5:	68 20 40 10 f0       	push   $0xf0104020
f01013da:	68 32 46 10 f0       	push   $0xf0104632
f01013df:	68 6f 02 00 00       	push   $0x26f
f01013e4:	68 0c 46 10 f0       	push   $0xf010460c
f01013e9:	e8 0a ed ff ff       	call   f01000f8 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01013ee:	8b 0d 6c 79 11 f0    	mov    0xf011796c,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01013f4:	8b 15 64 79 11 f0    	mov    0xf0117964,%edx
f01013fa:	c1 e2 0c             	shl    $0xc,%edx
f01013fd:	89 f8                	mov    %edi,%eax
f01013ff:	29 c8                	sub    %ecx,%eax
f0101401:	c1 f8 03             	sar    $0x3,%eax
f0101404:	c1 e0 0c             	shl    $0xc,%eax
f0101407:	39 d0                	cmp    %edx,%eax
f0101409:	72 19                	jb     f0101424 <mem_init+0x22b>
f010140b:	68 4b 47 10 f0       	push   $0xf010474b
f0101410:	68 32 46 10 f0       	push   $0xf0104632
f0101415:	68 70 02 00 00       	push   $0x270
f010141a:	68 0c 46 10 f0       	push   $0xf010460c
f010141f:	e8 d4 ec ff ff       	call   f01000f8 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101424:	89 f0                	mov    %esi,%eax
f0101426:	29 c8                	sub    %ecx,%eax
f0101428:	c1 f8 03             	sar    $0x3,%eax
f010142b:	c1 e0 0c             	shl    $0xc,%eax
f010142e:	39 c2                	cmp    %eax,%edx
f0101430:	77 19                	ja     f010144b <mem_init+0x252>
f0101432:	68 68 47 10 f0       	push   $0xf0104768
f0101437:	68 32 46 10 f0       	push   $0xf0104632
f010143c:	68 71 02 00 00       	push   $0x271
f0101441:	68 0c 46 10 f0       	push   $0xf010460c
f0101446:	e8 ad ec ff ff       	call   f01000f8 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010144b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010144e:	29 c8                	sub    %ecx,%eax
f0101450:	c1 f8 03             	sar    $0x3,%eax
f0101453:	c1 e0 0c             	shl    $0xc,%eax
f0101456:	39 c2                	cmp    %eax,%edx
f0101458:	77 19                	ja     f0101473 <mem_init+0x27a>
f010145a:	68 85 47 10 f0       	push   $0xf0104785
f010145f:	68 32 46 10 f0       	push   $0xf0104632
f0101464:	68 72 02 00 00       	push   $0x272
f0101469:	68 0c 46 10 f0       	push   $0xf010460c
f010146e:	e8 85 ec ff ff       	call   f01000f8 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101473:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f0101478:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010147b:	c7 05 3c 75 11 f0 00 	movl   $0x0,0xf011753c
f0101482:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101485:	83 ec 0c             	sub    $0xc,%esp
f0101488:	6a 00                	push   $0x0
f010148a:	e8 5f fa ff ff       	call   f0100eee <page_alloc>
f010148f:	83 c4 10             	add    $0x10,%esp
f0101492:	85 c0                	test   %eax,%eax
f0101494:	74 19                	je     f01014af <mem_init+0x2b6>
f0101496:	68 a2 47 10 f0       	push   $0xf01047a2
f010149b:	68 32 46 10 f0       	push   $0xf0104632
f01014a0:	68 79 02 00 00       	push   $0x279
f01014a5:	68 0c 46 10 f0       	push   $0xf010460c
f01014aa:	e8 49 ec ff ff       	call   f01000f8 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01014af:	83 ec 0c             	sub    $0xc,%esp
f01014b2:	57                   	push   %edi
f01014b3:	e8 a6 fa ff ff       	call   f0100f5e <page_free>
	page_free(pp1);
f01014b8:	89 34 24             	mov    %esi,(%esp)
f01014bb:	e8 9e fa ff ff       	call   f0100f5e <page_free>
	page_free(pp2);
f01014c0:	83 c4 04             	add    $0x4,%esp
f01014c3:	ff 75 d4             	pushl  -0x2c(%ebp)
f01014c6:	e8 93 fa ff ff       	call   f0100f5e <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01014cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014d2:	e8 17 fa ff ff       	call   f0100eee <page_alloc>
f01014d7:	89 c6                	mov    %eax,%esi
f01014d9:	83 c4 10             	add    $0x10,%esp
f01014dc:	85 c0                	test   %eax,%eax
f01014de:	75 19                	jne    f01014f9 <mem_init+0x300>
f01014e0:	68 f7 46 10 f0       	push   $0xf01046f7
f01014e5:	68 32 46 10 f0       	push   $0xf0104632
f01014ea:	68 80 02 00 00       	push   $0x280
f01014ef:	68 0c 46 10 f0       	push   $0xf010460c
f01014f4:	e8 ff eb ff ff       	call   f01000f8 <_panic>
	assert((pp1 = page_alloc(0)));
f01014f9:	83 ec 0c             	sub    $0xc,%esp
f01014fc:	6a 00                	push   $0x0
f01014fe:	e8 eb f9 ff ff       	call   f0100eee <page_alloc>
f0101503:	89 c7                	mov    %eax,%edi
f0101505:	83 c4 10             	add    $0x10,%esp
f0101508:	85 c0                	test   %eax,%eax
f010150a:	75 19                	jne    f0101525 <mem_init+0x32c>
f010150c:	68 0d 47 10 f0       	push   $0xf010470d
f0101511:	68 32 46 10 f0       	push   $0xf0104632
f0101516:	68 81 02 00 00       	push   $0x281
f010151b:	68 0c 46 10 f0       	push   $0xf010460c
f0101520:	e8 d3 eb ff ff       	call   f01000f8 <_panic>
	assert((pp2 = page_alloc(0)));
f0101525:	83 ec 0c             	sub    $0xc,%esp
f0101528:	6a 00                	push   $0x0
f010152a:	e8 bf f9 ff ff       	call   f0100eee <page_alloc>
f010152f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101532:	83 c4 10             	add    $0x10,%esp
f0101535:	85 c0                	test   %eax,%eax
f0101537:	75 19                	jne    f0101552 <mem_init+0x359>
f0101539:	68 23 47 10 f0       	push   $0xf0104723
f010153e:	68 32 46 10 f0       	push   $0xf0104632
f0101543:	68 82 02 00 00       	push   $0x282
f0101548:	68 0c 46 10 f0       	push   $0xf010460c
f010154d:	e8 a6 eb ff ff       	call   f01000f8 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101552:	39 fe                	cmp    %edi,%esi
f0101554:	75 19                	jne    f010156f <mem_init+0x376>
f0101556:	68 39 47 10 f0       	push   $0xf0104739
f010155b:	68 32 46 10 f0       	push   $0xf0104632
f0101560:	68 84 02 00 00       	push   $0x284
f0101565:	68 0c 46 10 f0       	push   $0xf010460c
f010156a:	e8 89 eb ff ff       	call   f01000f8 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010156f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101572:	39 c7                	cmp    %eax,%edi
f0101574:	74 04                	je     f010157a <mem_init+0x381>
f0101576:	39 c6                	cmp    %eax,%esi
f0101578:	75 19                	jne    f0101593 <mem_init+0x39a>
f010157a:	68 20 40 10 f0       	push   $0xf0104020
f010157f:	68 32 46 10 f0       	push   $0xf0104632
f0101584:	68 85 02 00 00       	push   $0x285
f0101589:	68 0c 46 10 f0       	push   $0xf010460c
f010158e:	e8 65 eb ff ff       	call   f01000f8 <_panic>
	assert(!page_alloc(0));
f0101593:	83 ec 0c             	sub    $0xc,%esp
f0101596:	6a 00                	push   $0x0
f0101598:	e8 51 f9 ff ff       	call   f0100eee <page_alloc>
f010159d:	83 c4 10             	add    $0x10,%esp
f01015a0:	85 c0                	test   %eax,%eax
f01015a2:	74 19                	je     f01015bd <mem_init+0x3c4>
f01015a4:	68 a2 47 10 f0       	push   $0xf01047a2
f01015a9:	68 32 46 10 f0       	push   $0xf0104632
f01015ae:	68 86 02 00 00       	push   $0x286
f01015b3:	68 0c 46 10 f0       	push   $0xf010460c
f01015b8:	e8 3b eb ff ff       	call   f01000f8 <_panic>
f01015bd:	89 f0                	mov    %esi,%eax
f01015bf:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f01015c5:	c1 f8 03             	sar    $0x3,%eax
f01015c8:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015cb:	89 c2                	mov    %eax,%edx
f01015cd:	c1 ea 0c             	shr    $0xc,%edx
f01015d0:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f01015d6:	72 12                	jb     f01015ea <mem_init+0x3f1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01015d8:	50                   	push   %eax
f01015d9:	68 70 3e 10 f0       	push   $0xf0103e70
f01015de:	6a 52                	push   $0x52
f01015e0:	68 18 46 10 f0       	push   $0xf0104618
f01015e5:	e8 0e eb ff ff       	call   f01000f8 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01015ea:	83 ec 04             	sub    $0x4,%esp
f01015ed:	68 00 10 00 00       	push   $0x1000
f01015f2:	6a 01                	push   $0x1
f01015f4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01015f9:	50                   	push   %eax
f01015fa:	e8 73 1d 00 00       	call   f0103372 <memset>
	page_free(pp0);
f01015ff:	89 34 24             	mov    %esi,(%esp)
f0101602:	e8 57 f9 ff ff       	call   f0100f5e <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101607:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010160e:	e8 db f8 ff ff       	call   f0100eee <page_alloc>
f0101613:	83 c4 10             	add    $0x10,%esp
f0101616:	85 c0                	test   %eax,%eax
f0101618:	75 19                	jne    f0101633 <mem_init+0x43a>
f010161a:	68 b1 47 10 f0       	push   $0xf01047b1
f010161f:	68 32 46 10 f0       	push   $0xf0104632
f0101624:	68 8b 02 00 00       	push   $0x28b
f0101629:	68 0c 46 10 f0       	push   $0xf010460c
f010162e:	e8 c5 ea ff ff       	call   f01000f8 <_panic>
	assert(pp && pp0 == pp);
f0101633:	39 c6                	cmp    %eax,%esi
f0101635:	74 19                	je     f0101650 <mem_init+0x457>
f0101637:	68 cf 47 10 f0       	push   $0xf01047cf
f010163c:	68 32 46 10 f0       	push   $0xf0104632
f0101641:	68 8c 02 00 00       	push   $0x28c
f0101646:	68 0c 46 10 f0       	push   $0xf010460c
f010164b:	e8 a8 ea ff ff       	call   f01000f8 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101650:	89 f0                	mov    %esi,%eax
f0101652:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0101658:	c1 f8 03             	sar    $0x3,%eax
f010165b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010165e:	89 c2                	mov    %eax,%edx
f0101660:	c1 ea 0c             	shr    $0xc,%edx
f0101663:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0101669:	72 12                	jb     f010167d <mem_init+0x484>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010166b:	50                   	push   %eax
f010166c:	68 70 3e 10 f0       	push   $0xf0103e70
f0101671:	6a 52                	push   $0x52
f0101673:	68 18 46 10 f0       	push   $0xf0104618
f0101678:	e8 7b ea ff ff       	call   f01000f8 <_panic>
f010167d:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101683:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101689:	80 38 00             	cmpb   $0x0,(%eax)
f010168c:	74 19                	je     f01016a7 <mem_init+0x4ae>
f010168e:	68 df 47 10 f0       	push   $0xf01047df
f0101693:	68 32 46 10 f0       	push   $0xf0104632
f0101698:	68 8f 02 00 00       	push   $0x28f
f010169d:	68 0c 46 10 f0       	push   $0xf010460c
f01016a2:	e8 51 ea ff ff       	call   f01000f8 <_panic>
f01016a7:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01016aa:	39 d0                	cmp    %edx,%eax
f01016ac:	75 db                	jne    f0101689 <mem_init+0x490>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01016ae:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01016b1:	a3 3c 75 11 f0       	mov    %eax,0xf011753c

	// free the pages we took
	page_free(pp0);
f01016b6:	83 ec 0c             	sub    $0xc,%esp
f01016b9:	56                   	push   %esi
f01016ba:	e8 9f f8 ff ff       	call   f0100f5e <page_free>
	page_free(pp1);
f01016bf:	89 3c 24             	mov    %edi,(%esp)
f01016c2:	e8 97 f8 ff ff       	call   f0100f5e <page_free>
	page_free(pp2);
f01016c7:	83 c4 04             	add    $0x4,%esp
f01016ca:	ff 75 d4             	pushl  -0x2c(%ebp)
f01016cd:	e8 8c f8 ff ff       	call   f0100f5e <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01016d2:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f01016d7:	83 c4 10             	add    $0x10,%esp
f01016da:	eb 05                	jmp    f01016e1 <mem_init+0x4e8>
		--nfree;
f01016dc:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01016df:	8b 00                	mov    (%eax),%eax
f01016e1:	85 c0                	test   %eax,%eax
f01016e3:	75 f7                	jne    f01016dc <mem_init+0x4e3>
		--nfree;
	assert(nfree == 0);
f01016e5:	85 db                	test   %ebx,%ebx
f01016e7:	74 19                	je     f0101702 <mem_init+0x509>
f01016e9:	68 e9 47 10 f0       	push   $0xf01047e9
f01016ee:	68 32 46 10 f0       	push   $0xf0104632
f01016f3:	68 9c 02 00 00       	push   $0x29c
f01016f8:	68 0c 46 10 f0       	push   $0xf010460c
f01016fd:	e8 f6 e9 ff ff       	call   f01000f8 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101702:	83 ec 0c             	sub    $0xc,%esp
f0101705:	68 40 40 10 f0       	push   $0xf0104040
f010170a:	e8 a9 11 00 00       	call   f01028b8 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010170f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101716:	e8 d3 f7 ff ff       	call   f0100eee <page_alloc>
f010171b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010171e:	83 c4 10             	add    $0x10,%esp
f0101721:	85 c0                	test   %eax,%eax
f0101723:	75 19                	jne    f010173e <mem_init+0x545>
f0101725:	68 f7 46 10 f0       	push   $0xf01046f7
f010172a:	68 32 46 10 f0       	push   $0xf0104632
f010172f:	68 f5 02 00 00       	push   $0x2f5
f0101734:	68 0c 46 10 f0       	push   $0xf010460c
f0101739:	e8 ba e9 ff ff       	call   f01000f8 <_panic>
	assert((pp1 = page_alloc(0)));
f010173e:	83 ec 0c             	sub    $0xc,%esp
f0101741:	6a 00                	push   $0x0
f0101743:	e8 a6 f7 ff ff       	call   f0100eee <page_alloc>
f0101748:	89 c3                	mov    %eax,%ebx
f010174a:	83 c4 10             	add    $0x10,%esp
f010174d:	85 c0                	test   %eax,%eax
f010174f:	75 19                	jne    f010176a <mem_init+0x571>
f0101751:	68 0d 47 10 f0       	push   $0xf010470d
f0101756:	68 32 46 10 f0       	push   $0xf0104632
f010175b:	68 f6 02 00 00       	push   $0x2f6
f0101760:	68 0c 46 10 f0       	push   $0xf010460c
f0101765:	e8 8e e9 ff ff       	call   f01000f8 <_panic>
	assert((pp2 = page_alloc(0)));
f010176a:	83 ec 0c             	sub    $0xc,%esp
f010176d:	6a 00                	push   $0x0
f010176f:	e8 7a f7 ff ff       	call   f0100eee <page_alloc>
f0101774:	89 c6                	mov    %eax,%esi
f0101776:	83 c4 10             	add    $0x10,%esp
f0101779:	85 c0                	test   %eax,%eax
f010177b:	75 19                	jne    f0101796 <mem_init+0x59d>
f010177d:	68 23 47 10 f0       	push   $0xf0104723
f0101782:	68 32 46 10 f0       	push   $0xf0104632
f0101787:	68 f7 02 00 00       	push   $0x2f7
f010178c:	68 0c 46 10 f0       	push   $0xf010460c
f0101791:	e8 62 e9 ff ff       	call   f01000f8 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101796:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101799:	75 19                	jne    f01017b4 <mem_init+0x5bb>
f010179b:	68 39 47 10 f0       	push   $0xf0104739
f01017a0:	68 32 46 10 f0       	push   $0xf0104632
f01017a5:	68 fa 02 00 00       	push   $0x2fa
f01017aa:	68 0c 46 10 f0       	push   $0xf010460c
f01017af:	e8 44 e9 ff ff       	call   f01000f8 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017b4:	39 c3                	cmp    %eax,%ebx
f01017b6:	74 05                	je     f01017bd <mem_init+0x5c4>
f01017b8:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01017bb:	75 19                	jne    f01017d6 <mem_init+0x5dd>
f01017bd:	68 20 40 10 f0       	push   $0xf0104020
f01017c2:	68 32 46 10 f0       	push   $0xf0104632
f01017c7:	68 fb 02 00 00       	push   $0x2fb
f01017cc:	68 0c 46 10 f0       	push   $0xf010460c
f01017d1:	e8 22 e9 ff ff       	call   f01000f8 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01017d6:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f01017db:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01017de:	c7 05 3c 75 11 f0 00 	movl   $0x0,0xf011753c
f01017e5:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01017e8:	83 ec 0c             	sub    $0xc,%esp
f01017eb:	6a 00                	push   $0x0
f01017ed:	e8 fc f6 ff ff       	call   f0100eee <page_alloc>
f01017f2:	83 c4 10             	add    $0x10,%esp
f01017f5:	85 c0                	test   %eax,%eax
f01017f7:	74 19                	je     f0101812 <mem_init+0x619>
f01017f9:	68 a2 47 10 f0       	push   $0xf01047a2
f01017fe:	68 32 46 10 f0       	push   $0xf0104632
f0101803:	68 02 03 00 00       	push   $0x302
f0101808:	68 0c 46 10 f0       	push   $0xf010460c
f010180d:	e8 e6 e8 ff ff       	call   f01000f8 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101812:	83 ec 04             	sub    $0x4,%esp
f0101815:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101818:	50                   	push   %eax
f0101819:	6a 00                	push   $0x0
f010181b:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0101821:	e8 bc f8 ff ff       	call   f01010e2 <page_lookup>
f0101826:	83 c4 10             	add    $0x10,%esp
f0101829:	85 c0                	test   %eax,%eax
f010182b:	74 19                	je     f0101846 <mem_init+0x64d>
f010182d:	68 60 40 10 f0       	push   $0xf0104060
f0101832:	68 32 46 10 f0       	push   $0xf0104632
f0101837:	68 05 03 00 00       	push   $0x305
f010183c:	68 0c 46 10 f0       	push   $0xf010460c
f0101841:	e8 b2 e8 ff ff       	call   f01000f8 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101846:	6a 02                	push   $0x2
f0101848:	6a 00                	push   $0x0
f010184a:	53                   	push   %ebx
f010184b:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0101851:	e8 3a f9 ff ff       	call   f0101190 <page_insert>
f0101856:	83 c4 10             	add    $0x10,%esp
f0101859:	85 c0                	test   %eax,%eax
f010185b:	78 19                	js     f0101876 <mem_init+0x67d>
f010185d:	68 98 40 10 f0       	push   $0xf0104098
f0101862:	68 32 46 10 f0       	push   $0xf0104632
f0101867:	68 08 03 00 00       	push   $0x308
f010186c:	68 0c 46 10 f0       	push   $0xf010460c
f0101871:	e8 82 e8 ff ff       	call   f01000f8 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101876:	83 ec 0c             	sub    $0xc,%esp
f0101879:	ff 75 d4             	pushl  -0x2c(%ebp)
f010187c:	e8 dd f6 ff ff       	call   f0100f5e <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101881:	6a 02                	push   $0x2
f0101883:	6a 00                	push   $0x0
f0101885:	53                   	push   %ebx
f0101886:	ff 35 68 79 11 f0    	pushl  0xf0117968
f010188c:	e8 ff f8 ff ff       	call   f0101190 <page_insert>
f0101891:	83 c4 20             	add    $0x20,%esp
f0101894:	85 c0                	test   %eax,%eax
f0101896:	74 19                	je     f01018b1 <mem_init+0x6b8>
f0101898:	68 c8 40 10 f0       	push   $0xf01040c8
f010189d:	68 32 46 10 f0       	push   $0xf0104632
f01018a2:	68 0c 03 00 00       	push   $0x30c
f01018a7:	68 0c 46 10 f0       	push   $0xf010460c
f01018ac:	e8 47 e8 ff ff       	call   f01000f8 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01018b1:	8b 3d 68 79 11 f0    	mov    0xf0117968,%edi
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01018b7:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f01018bc:	89 c1                	mov    %eax,%ecx
f01018be:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01018c1:	8b 17                	mov    (%edi),%edx
f01018c3:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01018c9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01018cc:	29 c8                	sub    %ecx,%eax
f01018ce:	c1 f8 03             	sar    $0x3,%eax
f01018d1:	c1 e0 0c             	shl    $0xc,%eax
f01018d4:	39 c2                	cmp    %eax,%edx
f01018d6:	74 19                	je     f01018f1 <mem_init+0x6f8>
f01018d8:	68 f8 40 10 f0       	push   $0xf01040f8
f01018dd:	68 32 46 10 f0       	push   $0xf0104632
f01018e2:	68 0d 03 00 00       	push   $0x30d
f01018e7:	68 0c 46 10 f0       	push   $0xf010460c
f01018ec:	e8 07 e8 ff ff       	call   f01000f8 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01018f1:	ba 00 00 00 00       	mov    $0x0,%edx
f01018f6:	89 f8                	mov    %edi,%eax
f01018f8:	e8 8f f1 ff ff       	call   f0100a8c <check_va2pa>
f01018fd:	89 da                	mov    %ebx,%edx
f01018ff:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101902:	c1 fa 03             	sar    $0x3,%edx
f0101905:	c1 e2 0c             	shl    $0xc,%edx
f0101908:	39 d0                	cmp    %edx,%eax
f010190a:	74 19                	je     f0101925 <mem_init+0x72c>
f010190c:	68 20 41 10 f0       	push   $0xf0104120
f0101911:	68 32 46 10 f0       	push   $0xf0104632
f0101916:	68 0e 03 00 00       	push   $0x30e
f010191b:	68 0c 46 10 f0       	push   $0xf010460c
f0101920:	e8 d3 e7 ff ff       	call   f01000f8 <_panic>
	assert(pp1->pp_ref == 1);
f0101925:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010192a:	74 19                	je     f0101945 <mem_init+0x74c>
f010192c:	68 f4 47 10 f0       	push   $0xf01047f4
f0101931:	68 32 46 10 f0       	push   $0xf0104632
f0101936:	68 0f 03 00 00       	push   $0x30f
f010193b:	68 0c 46 10 f0       	push   $0xf010460c
f0101940:	e8 b3 e7 ff ff       	call   f01000f8 <_panic>
	assert(pp0->pp_ref == 1);
f0101945:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101948:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010194d:	74 19                	je     f0101968 <mem_init+0x76f>
f010194f:	68 05 48 10 f0       	push   $0xf0104805
f0101954:	68 32 46 10 f0       	push   $0xf0104632
f0101959:	68 10 03 00 00       	push   $0x310
f010195e:	68 0c 46 10 f0       	push   $0xf010460c
f0101963:	e8 90 e7 ff ff       	call   f01000f8 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101968:	6a 02                	push   $0x2
f010196a:	68 00 10 00 00       	push   $0x1000
f010196f:	56                   	push   %esi
f0101970:	57                   	push   %edi
f0101971:	e8 1a f8 ff ff       	call   f0101190 <page_insert>
f0101976:	83 c4 10             	add    $0x10,%esp
f0101979:	85 c0                	test   %eax,%eax
f010197b:	74 19                	je     f0101996 <mem_init+0x79d>
f010197d:	68 50 41 10 f0       	push   $0xf0104150
f0101982:	68 32 46 10 f0       	push   $0xf0104632
f0101987:	68 13 03 00 00       	push   $0x313
f010198c:	68 0c 46 10 f0       	push   $0xf010460c
f0101991:	e8 62 e7 ff ff       	call   f01000f8 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101996:	ba 00 10 00 00       	mov    $0x1000,%edx
f010199b:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f01019a0:	e8 e7 f0 ff ff       	call   f0100a8c <check_va2pa>
f01019a5:	89 f2                	mov    %esi,%edx
f01019a7:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f01019ad:	c1 fa 03             	sar    $0x3,%edx
f01019b0:	c1 e2 0c             	shl    $0xc,%edx
f01019b3:	39 d0                	cmp    %edx,%eax
f01019b5:	74 19                	je     f01019d0 <mem_init+0x7d7>
f01019b7:	68 8c 41 10 f0       	push   $0xf010418c
f01019bc:	68 32 46 10 f0       	push   $0xf0104632
f01019c1:	68 14 03 00 00       	push   $0x314
f01019c6:	68 0c 46 10 f0       	push   $0xf010460c
f01019cb:	e8 28 e7 ff ff       	call   f01000f8 <_panic>
	assert(pp2->pp_ref == 1);
f01019d0:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01019d5:	74 19                	je     f01019f0 <mem_init+0x7f7>
f01019d7:	68 16 48 10 f0       	push   $0xf0104816
f01019dc:	68 32 46 10 f0       	push   $0xf0104632
f01019e1:	68 15 03 00 00       	push   $0x315
f01019e6:	68 0c 46 10 f0       	push   $0xf010460c
f01019eb:	e8 08 e7 ff ff       	call   f01000f8 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01019f0:	83 ec 0c             	sub    $0xc,%esp
f01019f3:	6a 00                	push   $0x0
f01019f5:	e8 f4 f4 ff ff       	call   f0100eee <page_alloc>
f01019fa:	83 c4 10             	add    $0x10,%esp
f01019fd:	85 c0                	test   %eax,%eax
f01019ff:	74 19                	je     f0101a1a <mem_init+0x821>
f0101a01:	68 a2 47 10 f0       	push   $0xf01047a2
f0101a06:	68 32 46 10 f0       	push   $0xf0104632
f0101a0b:	68 18 03 00 00       	push   $0x318
f0101a10:	68 0c 46 10 f0       	push   $0xf010460c
f0101a15:	e8 de e6 ff ff       	call   f01000f8 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a1a:	6a 02                	push   $0x2
f0101a1c:	68 00 10 00 00       	push   $0x1000
f0101a21:	56                   	push   %esi
f0101a22:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0101a28:	e8 63 f7 ff ff       	call   f0101190 <page_insert>
f0101a2d:	83 c4 10             	add    $0x10,%esp
f0101a30:	85 c0                	test   %eax,%eax
f0101a32:	74 19                	je     f0101a4d <mem_init+0x854>
f0101a34:	68 50 41 10 f0       	push   $0xf0104150
f0101a39:	68 32 46 10 f0       	push   $0xf0104632
f0101a3e:	68 1b 03 00 00       	push   $0x31b
f0101a43:	68 0c 46 10 f0       	push   $0xf010460c
f0101a48:	e8 ab e6 ff ff       	call   f01000f8 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a4d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a52:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101a57:	e8 30 f0 ff ff       	call   f0100a8c <check_va2pa>
f0101a5c:	89 f2                	mov    %esi,%edx
f0101a5e:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0101a64:	c1 fa 03             	sar    $0x3,%edx
f0101a67:	c1 e2 0c             	shl    $0xc,%edx
f0101a6a:	39 d0                	cmp    %edx,%eax
f0101a6c:	74 19                	je     f0101a87 <mem_init+0x88e>
f0101a6e:	68 8c 41 10 f0       	push   $0xf010418c
f0101a73:	68 32 46 10 f0       	push   $0xf0104632
f0101a78:	68 1c 03 00 00       	push   $0x31c
f0101a7d:	68 0c 46 10 f0       	push   $0xf010460c
f0101a82:	e8 71 e6 ff ff       	call   f01000f8 <_panic>
	assert(pp2->pp_ref == 1);
f0101a87:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a8c:	74 19                	je     f0101aa7 <mem_init+0x8ae>
f0101a8e:	68 16 48 10 f0       	push   $0xf0104816
f0101a93:	68 32 46 10 f0       	push   $0xf0104632
f0101a98:	68 1d 03 00 00       	push   $0x31d
f0101a9d:	68 0c 46 10 f0       	push   $0xf010460c
f0101aa2:	e8 51 e6 ff ff       	call   f01000f8 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101aa7:	83 ec 0c             	sub    $0xc,%esp
f0101aaa:	6a 00                	push   $0x0
f0101aac:	e8 3d f4 ff ff       	call   f0100eee <page_alloc>
f0101ab1:	83 c4 10             	add    $0x10,%esp
f0101ab4:	85 c0                	test   %eax,%eax
f0101ab6:	74 19                	je     f0101ad1 <mem_init+0x8d8>
f0101ab8:	68 a2 47 10 f0       	push   $0xf01047a2
f0101abd:	68 32 46 10 f0       	push   $0xf0104632
f0101ac2:	68 21 03 00 00       	push   $0x321
f0101ac7:	68 0c 46 10 f0       	push   $0xf010460c
f0101acc:	e8 27 e6 ff ff       	call   f01000f8 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101ad1:	8b 15 68 79 11 f0    	mov    0xf0117968,%edx
f0101ad7:	8b 02                	mov    (%edx),%eax
f0101ad9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101ade:	89 c1                	mov    %eax,%ecx
f0101ae0:	c1 e9 0c             	shr    $0xc,%ecx
f0101ae3:	3b 0d 64 79 11 f0    	cmp    0xf0117964,%ecx
f0101ae9:	72 15                	jb     f0101b00 <mem_init+0x907>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101aeb:	50                   	push   %eax
f0101aec:	68 70 3e 10 f0       	push   $0xf0103e70
f0101af1:	68 24 03 00 00       	push   $0x324
f0101af6:	68 0c 46 10 f0       	push   $0xf010460c
f0101afb:	e8 f8 e5 ff ff       	call   f01000f8 <_panic>
f0101b00:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101b05:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101b08:	83 ec 04             	sub    $0x4,%esp
f0101b0b:	6a 00                	push   $0x0
f0101b0d:	68 00 10 00 00       	push   $0x1000
f0101b12:	52                   	push   %edx
f0101b13:	e8 aa f4 ff ff       	call   f0100fc2 <pgdir_walk>
f0101b18:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101b1b:	8d 51 04             	lea    0x4(%ecx),%edx
f0101b1e:	83 c4 10             	add    $0x10,%esp
f0101b21:	39 d0                	cmp    %edx,%eax
f0101b23:	74 19                	je     f0101b3e <mem_init+0x945>
f0101b25:	68 bc 41 10 f0       	push   $0xf01041bc
f0101b2a:	68 32 46 10 f0       	push   $0xf0104632
f0101b2f:	68 25 03 00 00       	push   $0x325
f0101b34:	68 0c 46 10 f0       	push   $0xf010460c
f0101b39:	e8 ba e5 ff ff       	call   f01000f8 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101b3e:	6a 06                	push   $0x6
f0101b40:	68 00 10 00 00       	push   $0x1000
f0101b45:	56                   	push   %esi
f0101b46:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0101b4c:	e8 3f f6 ff ff       	call   f0101190 <page_insert>
f0101b51:	83 c4 10             	add    $0x10,%esp
f0101b54:	85 c0                	test   %eax,%eax
f0101b56:	74 19                	je     f0101b71 <mem_init+0x978>
f0101b58:	68 fc 41 10 f0       	push   $0xf01041fc
f0101b5d:	68 32 46 10 f0       	push   $0xf0104632
f0101b62:	68 28 03 00 00       	push   $0x328
f0101b67:	68 0c 46 10 f0       	push   $0xf010460c
f0101b6c:	e8 87 e5 ff ff       	call   f01000f8 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b71:	8b 3d 68 79 11 f0    	mov    0xf0117968,%edi
f0101b77:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b7c:	89 f8                	mov    %edi,%eax
f0101b7e:	e8 09 ef ff ff       	call   f0100a8c <check_va2pa>
f0101b83:	89 f2                	mov    %esi,%edx
f0101b85:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0101b8b:	c1 fa 03             	sar    $0x3,%edx
f0101b8e:	c1 e2 0c             	shl    $0xc,%edx
f0101b91:	39 d0                	cmp    %edx,%eax
f0101b93:	74 19                	je     f0101bae <mem_init+0x9b5>
f0101b95:	68 8c 41 10 f0       	push   $0xf010418c
f0101b9a:	68 32 46 10 f0       	push   $0xf0104632
f0101b9f:	68 29 03 00 00       	push   $0x329
f0101ba4:	68 0c 46 10 f0       	push   $0xf010460c
f0101ba9:	e8 4a e5 ff ff       	call   f01000f8 <_panic>
	assert(pp2->pp_ref == 1);
f0101bae:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101bb3:	74 19                	je     f0101bce <mem_init+0x9d5>
f0101bb5:	68 16 48 10 f0       	push   $0xf0104816
f0101bba:	68 32 46 10 f0       	push   $0xf0104632
f0101bbf:	68 2a 03 00 00       	push   $0x32a
f0101bc4:	68 0c 46 10 f0       	push   $0xf010460c
f0101bc9:	e8 2a e5 ff ff       	call   f01000f8 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101bce:	83 ec 04             	sub    $0x4,%esp
f0101bd1:	6a 00                	push   $0x0
f0101bd3:	68 00 10 00 00       	push   $0x1000
f0101bd8:	57                   	push   %edi
f0101bd9:	e8 e4 f3 ff ff       	call   f0100fc2 <pgdir_walk>
f0101bde:	83 c4 10             	add    $0x10,%esp
f0101be1:	f6 00 04             	testb  $0x4,(%eax)
f0101be4:	75 19                	jne    f0101bff <mem_init+0xa06>
f0101be6:	68 3c 42 10 f0       	push   $0xf010423c
f0101beb:	68 32 46 10 f0       	push   $0xf0104632
f0101bf0:	68 2b 03 00 00       	push   $0x32b
f0101bf5:	68 0c 46 10 f0       	push   $0xf010460c
f0101bfa:	e8 f9 e4 ff ff       	call   f01000f8 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101bff:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101c04:	f6 00 04             	testb  $0x4,(%eax)
f0101c07:	75 19                	jne    f0101c22 <mem_init+0xa29>
f0101c09:	68 27 48 10 f0       	push   $0xf0104827
f0101c0e:	68 32 46 10 f0       	push   $0xf0104632
f0101c13:	68 2c 03 00 00       	push   $0x32c
f0101c18:	68 0c 46 10 f0       	push   $0xf010460c
f0101c1d:	e8 d6 e4 ff ff       	call   f01000f8 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c22:	6a 02                	push   $0x2
f0101c24:	68 00 10 00 00       	push   $0x1000
f0101c29:	56                   	push   %esi
f0101c2a:	50                   	push   %eax
f0101c2b:	e8 60 f5 ff ff       	call   f0101190 <page_insert>
f0101c30:	83 c4 10             	add    $0x10,%esp
f0101c33:	85 c0                	test   %eax,%eax
f0101c35:	74 19                	je     f0101c50 <mem_init+0xa57>
f0101c37:	68 50 41 10 f0       	push   $0xf0104150
f0101c3c:	68 32 46 10 f0       	push   $0xf0104632
f0101c41:	68 2f 03 00 00       	push   $0x32f
f0101c46:	68 0c 46 10 f0       	push   $0xf010460c
f0101c4b:	e8 a8 e4 ff ff       	call   f01000f8 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101c50:	83 ec 04             	sub    $0x4,%esp
f0101c53:	6a 00                	push   $0x0
f0101c55:	68 00 10 00 00       	push   $0x1000
f0101c5a:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0101c60:	e8 5d f3 ff ff       	call   f0100fc2 <pgdir_walk>
f0101c65:	83 c4 10             	add    $0x10,%esp
f0101c68:	f6 00 02             	testb  $0x2,(%eax)
f0101c6b:	75 19                	jne    f0101c86 <mem_init+0xa8d>
f0101c6d:	68 70 42 10 f0       	push   $0xf0104270
f0101c72:	68 32 46 10 f0       	push   $0xf0104632
f0101c77:	68 30 03 00 00       	push   $0x330
f0101c7c:	68 0c 46 10 f0       	push   $0xf010460c
f0101c81:	e8 72 e4 ff ff       	call   f01000f8 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c86:	83 ec 04             	sub    $0x4,%esp
f0101c89:	6a 00                	push   $0x0
f0101c8b:	68 00 10 00 00       	push   $0x1000
f0101c90:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0101c96:	e8 27 f3 ff ff       	call   f0100fc2 <pgdir_walk>
f0101c9b:	83 c4 10             	add    $0x10,%esp
f0101c9e:	f6 00 04             	testb  $0x4,(%eax)
f0101ca1:	74 19                	je     f0101cbc <mem_init+0xac3>
f0101ca3:	68 a4 42 10 f0       	push   $0xf01042a4
f0101ca8:	68 32 46 10 f0       	push   $0xf0104632
f0101cad:	68 31 03 00 00       	push   $0x331
f0101cb2:	68 0c 46 10 f0       	push   $0xf010460c
f0101cb7:	e8 3c e4 ff ff       	call   f01000f8 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101cbc:	6a 02                	push   $0x2
f0101cbe:	68 00 00 40 00       	push   $0x400000
f0101cc3:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101cc6:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0101ccc:	e8 bf f4 ff ff       	call   f0101190 <page_insert>
f0101cd1:	83 c4 10             	add    $0x10,%esp
f0101cd4:	85 c0                	test   %eax,%eax
f0101cd6:	78 19                	js     f0101cf1 <mem_init+0xaf8>
f0101cd8:	68 dc 42 10 f0       	push   $0xf01042dc
f0101cdd:	68 32 46 10 f0       	push   $0xf0104632
f0101ce2:	68 34 03 00 00       	push   $0x334
f0101ce7:	68 0c 46 10 f0       	push   $0xf010460c
f0101cec:	e8 07 e4 ff ff       	call   f01000f8 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101cf1:	6a 02                	push   $0x2
f0101cf3:	68 00 10 00 00       	push   $0x1000
f0101cf8:	53                   	push   %ebx
f0101cf9:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0101cff:	e8 8c f4 ff ff       	call   f0101190 <page_insert>
f0101d04:	83 c4 10             	add    $0x10,%esp
f0101d07:	85 c0                	test   %eax,%eax
f0101d09:	74 19                	je     f0101d24 <mem_init+0xb2b>
f0101d0b:	68 14 43 10 f0       	push   $0xf0104314
f0101d10:	68 32 46 10 f0       	push   $0xf0104632
f0101d15:	68 37 03 00 00       	push   $0x337
f0101d1a:	68 0c 46 10 f0       	push   $0xf010460c
f0101d1f:	e8 d4 e3 ff ff       	call   f01000f8 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101d24:	83 ec 04             	sub    $0x4,%esp
f0101d27:	6a 00                	push   $0x0
f0101d29:	68 00 10 00 00       	push   $0x1000
f0101d2e:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0101d34:	e8 89 f2 ff ff       	call   f0100fc2 <pgdir_walk>
f0101d39:	83 c4 10             	add    $0x10,%esp
f0101d3c:	f6 00 04             	testb  $0x4,(%eax)
f0101d3f:	74 19                	je     f0101d5a <mem_init+0xb61>
f0101d41:	68 a4 42 10 f0       	push   $0xf01042a4
f0101d46:	68 32 46 10 f0       	push   $0xf0104632
f0101d4b:	68 38 03 00 00       	push   $0x338
f0101d50:	68 0c 46 10 f0       	push   $0xf010460c
f0101d55:	e8 9e e3 ff ff       	call   f01000f8 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101d5a:	8b 3d 68 79 11 f0    	mov    0xf0117968,%edi
f0101d60:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d65:	89 f8                	mov    %edi,%eax
f0101d67:	e8 20 ed ff ff       	call   f0100a8c <check_va2pa>
f0101d6c:	89 c1                	mov    %eax,%ecx
f0101d6e:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101d71:	89 d8                	mov    %ebx,%eax
f0101d73:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0101d79:	c1 f8 03             	sar    $0x3,%eax
f0101d7c:	c1 e0 0c             	shl    $0xc,%eax
f0101d7f:	39 c1                	cmp    %eax,%ecx
f0101d81:	74 19                	je     f0101d9c <mem_init+0xba3>
f0101d83:	68 50 43 10 f0       	push   $0xf0104350
f0101d88:	68 32 46 10 f0       	push   $0xf0104632
f0101d8d:	68 3b 03 00 00       	push   $0x33b
f0101d92:	68 0c 46 10 f0       	push   $0xf010460c
f0101d97:	e8 5c e3 ff ff       	call   f01000f8 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101d9c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101da1:	89 f8                	mov    %edi,%eax
f0101da3:	e8 e4 ec ff ff       	call   f0100a8c <check_va2pa>
f0101da8:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101dab:	74 19                	je     f0101dc6 <mem_init+0xbcd>
f0101dad:	68 7c 43 10 f0       	push   $0xf010437c
f0101db2:	68 32 46 10 f0       	push   $0xf0104632
f0101db7:	68 3c 03 00 00       	push   $0x33c
f0101dbc:	68 0c 46 10 f0       	push   $0xf010460c
f0101dc1:	e8 32 e3 ff ff       	call   f01000f8 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101dc6:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101dcb:	74 19                	je     f0101de6 <mem_init+0xbed>
f0101dcd:	68 3d 48 10 f0       	push   $0xf010483d
f0101dd2:	68 32 46 10 f0       	push   $0xf0104632
f0101dd7:	68 3e 03 00 00       	push   $0x33e
f0101ddc:	68 0c 46 10 f0       	push   $0xf010460c
f0101de1:	e8 12 e3 ff ff       	call   f01000f8 <_panic>
	assert(pp2->pp_ref == 0);
f0101de6:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101deb:	74 19                	je     f0101e06 <mem_init+0xc0d>
f0101ded:	68 4e 48 10 f0       	push   $0xf010484e
f0101df2:	68 32 46 10 f0       	push   $0xf0104632
f0101df7:	68 3f 03 00 00       	push   $0x33f
f0101dfc:	68 0c 46 10 f0       	push   $0xf010460c
f0101e01:	e8 f2 e2 ff ff       	call   f01000f8 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101e06:	83 ec 0c             	sub    $0xc,%esp
f0101e09:	6a 00                	push   $0x0
f0101e0b:	e8 de f0 ff ff       	call   f0100eee <page_alloc>
f0101e10:	83 c4 10             	add    $0x10,%esp
f0101e13:	85 c0                	test   %eax,%eax
f0101e15:	74 04                	je     f0101e1b <mem_init+0xc22>
f0101e17:	39 c6                	cmp    %eax,%esi
f0101e19:	74 19                	je     f0101e34 <mem_init+0xc3b>
f0101e1b:	68 ac 43 10 f0       	push   $0xf01043ac
f0101e20:	68 32 46 10 f0       	push   $0xf0104632
f0101e25:	68 42 03 00 00       	push   $0x342
f0101e2a:	68 0c 46 10 f0       	push   $0xf010460c
f0101e2f:	e8 c4 e2 ff ff       	call   f01000f8 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101e34:	83 ec 08             	sub    $0x8,%esp
f0101e37:	6a 00                	push   $0x0
f0101e39:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0101e3f:	e8 00 f3 ff ff       	call   f0101144 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101e44:	8b 3d 68 79 11 f0    	mov    0xf0117968,%edi
f0101e4a:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e4f:	89 f8                	mov    %edi,%eax
f0101e51:	e8 36 ec ff ff       	call   f0100a8c <check_va2pa>
f0101e56:	83 c4 10             	add    $0x10,%esp
f0101e59:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e5c:	74 19                	je     f0101e77 <mem_init+0xc7e>
f0101e5e:	68 d0 43 10 f0       	push   $0xf01043d0
f0101e63:	68 32 46 10 f0       	push   $0xf0104632
f0101e68:	68 46 03 00 00       	push   $0x346
f0101e6d:	68 0c 46 10 f0       	push   $0xf010460c
f0101e72:	e8 81 e2 ff ff       	call   f01000f8 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101e77:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e7c:	89 f8                	mov    %edi,%eax
f0101e7e:	e8 09 ec ff ff       	call   f0100a8c <check_va2pa>
f0101e83:	89 da                	mov    %ebx,%edx
f0101e85:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0101e8b:	c1 fa 03             	sar    $0x3,%edx
f0101e8e:	c1 e2 0c             	shl    $0xc,%edx
f0101e91:	39 d0                	cmp    %edx,%eax
f0101e93:	74 19                	je     f0101eae <mem_init+0xcb5>
f0101e95:	68 7c 43 10 f0       	push   $0xf010437c
f0101e9a:	68 32 46 10 f0       	push   $0xf0104632
f0101e9f:	68 47 03 00 00       	push   $0x347
f0101ea4:	68 0c 46 10 f0       	push   $0xf010460c
f0101ea9:	e8 4a e2 ff ff       	call   f01000f8 <_panic>
	assert(pp1->pp_ref == 1);
f0101eae:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101eb3:	74 19                	je     f0101ece <mem_init+0xcd5>
f0101eb5:	68 f4 47 10 f0       	push   $0xf01047f4
f0101eba:	68 32 46 10 f0       	push   $0xf0104632
f0101ebf:	68 48 03 00 00       	push   $0x348
f0101ec4:	68 0c 46 10 f0       	push   $0xf010460c
f0101ec9:	e8 2a e2 ff ff       	call   f01000f8 <_panic>
	assert(pp2->pp_ref == 0);
f0101ece:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101ed3:	74 19                	je     f0101eee <mem_init+0xcf5>
f0101ed5:	68 4e 48 10 f0       	push   $0xf010484e
f0101eda:	68 32 46 10 f0       	push   $0xf0104632
f0101edf:	68 49 03 00 00       	push   $0x349
f0101ee4:	68 0c 46 10 f0       	push   $0xf010460c
f0101ee9:	e8 0a e2 ff ff       	call   f01000f8 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101eee:	6a 00                	push   $0x0
f0101ef0:	68 00 10 00 00       	push   $0x1000
f0101ef5:	53                   	push   %ebx
f0101ef6:	57                   	push   %edi
f0101ef7:	e8 94 f2 ff ff       	call   f0101190 <page_insert>
f0101efc:	83 c4 10             	add    $0x10,%esp
f0101eff:	85 c0                	test   %eax,%eax
f0101f01:	74 19                	je     f0101f1c <mem_init+0xd23>
f0101f03:	68 f4 43 10 f0       	push   $0xf01043f4
f0101f08:	68 32 46 10 f0       	push   $0xf0104632
f0101f0d:	68 4c 03 00 00       	push   $0x34c
f0101f12:	68 0c 46 10 f0       	push   $0xf010460c
f0101f17:	e8 dc e1 ff ff       	call   f01000f8 <_panic>
	assert(pp1->pp_ref);
f0101f1c:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101f21:	75 19                	jne    f0101f3c <mem_init+0xd43>
f0101f23:	68 5f 48 10 f0       	push   $0xf010485f
f0101f28:	68 32 46 10 f0       	push   $0xf0104632
f0101f2d:	68 4d 03 00 00       	push   $0x34d
f0101f32:	68 0c 46 10 f0       	push   $0xf010460c
f0101f37:	e8 bc e1 ff ff       	call   f01000f8 <_panic>
	assert(pp1->pp_link == NULL);
f0101f3c:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101f3f:	74 19                	je     f0101f5a <mem_init+0xd61>
f0101f41:	68 6b 48 10 f0       	push   $0xf010486b
f0101f46:	68 32 46 10 f0       	push   $0xf0104632
f0101f4b:	68 4e 03 00 00       	push   $0x34e
f0101f50:	68 0c 46 10 f0       	push   $0xf010460c
f0101f55:	e8 9e e1 ff ff       	call   f01000f8 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101f5a:	83 ec 08             	sub    $0x8,%esp
f0101f5d:	68 00 10 00 00       	push   $0x1000
f0101f62:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0101f68:	e8 d7 f1 ff ff       	call   f0101144 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101f6d:	8b 3d 68 79 11 f0    	mov    0xf0117968,%edi
f0101f73:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f78:	89 f8                	mov    %edi,%eax
f0101f7a:	e8 0d eb ff ff       	call   f0100a8c <check_va2pa>
f0101f7f:	83 c4 10             	add    $0x10,%esp
f0101f82:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f85:	74 19                	je     f0101fa0 <mem_init+0xda7>
f0101f87:	68 d0 43 10 f0       	push   $0xf01043d0
f0101f8c:	68 32 46 10 f0       	push   $0xf0104632
f0101f91:	68 52 03 00 00       	push   $0x352
f0101f96:	68 0c 46 10 f0       	push   $0xf010460c
f0101f9b:	e8 58 e1 ff ff       	call   f01000f8 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101fa0:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fa5:	89 f8                	mov    %edi,%eax
f0101fa7:	e8 e0 ea ff ff       	call   f0100a8c <check_va2pa>
f0101fac:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101faf:	74 19                	je     f0101fca <mem_init+0xdd1>
f0101fb1:	68 2c 44 10 f0       	push   $0xf010442c
f0101fb6:	68 32 46 10 f0       	push   $0xf0104632
f0101fbb:	68 53 03 00 00       	push   $0x353
f0101fc0:	68 0c 46 10 f0       	push   $0xf010460c
f0101fc5:	e8 2e e1 ff ff       	call   f01000f8 <_panic>
	assert(pp1->pp_ref == 0);
f0101fca:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101fcf:	74 19                	je     f0101fea <mem_init+0xdf1>
f0101fd1:	68 80 48 10 f0       	push   $0xf0104880
f0101fd6:	68 32 46 10 f0       	push   $0xf0104632
f0101fdb:	68 54 03 00 00       	push   $0x354
f0101fe0:	68 0c 46 10 f0       	push   $0xf010460c
f0101fe5:	e8 0e e1 ff ff       	call   f01000f8 <_panic>
	assert(pp2->pp_ref == 0);
f0101fea:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101fef:	74 19                	je     f010200a <mem_init+0xe11>
f0101ff1:	68 4e 48 10 f0       	push   $0xf010484e
f0101ff6:	68 32 46 10 f0       	push   $0xf0104632
f0101ffb:	68 55 03 00 00       	push   $0x355
f0102000:	68 0c 46 10 f0       	push   $0xf010460c
f0102005:	e8 ee e0 ff ff       	call   f01000f8 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010200a:	83 ec 0c             	sub    $0xc,%esp
f010200d:	6a 00                	push   $0x0
f010200f:	e8 da ee ff ff       	call   f0100eee <page_alloc>
f0102014:	83 c4 10             	add    $0x10,%esp
f0102017:	39 c3                	cmp    %eax,%ebx
f0102019:	75 04                	jne    f010201f <mem_init+0xe26>
f010201b:	85 c0                	test   %eax,%eax
f010201d:	75 19                	jne    f0102038 <mem_init+0xe3f>
f010201f:	68 54 44 10 f0       	push   $0xf0104454
f0102024:	68 32 46 10 f0       	push   $0xf0104632
f0102029:	68 58 03 00 00       	push   $0x358
f010202e:	68 0c 46 10 f0       	push   $0xf010460c
f0102033:	e8 c0 e0 ff ff       	call   f01000f8 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102038:	83 ec 0c             	sub    $0xc,%esp
f010203b:	6a 00                	push   $0x0
f010203d:	e8 ac ee ff ff       	call   f0100eee <page_alloc>
f0102042:	83 c4 10             	add    $0x10,%esp
f0102045:	85 c0                	test   %eax,%eax
f0102047:	74 19                	je     f0102062 <mem_init+0xe69>
f0102049:	68 a2 47 10 f0       	push   $0xf01047a2
f010204e:	68 32 46 10 f0       	push   $0xf0104632
f0102053:	68 5b 03 00 00       	push   $0x35b
f0102058:	68 0c 46 10 f0       	push   $0xf010460c
f010205d:	e8 96 e0 ff ff       	call   f01000f8 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102062:	8b 0d 68 79 11 f0    	mov    0xf0117968,%ecx
f0102068:	8b 11                	mov    (%ecx),%edx
f010206a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102070:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102073:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0102079:	c1 f8 03             	sar    $0x3,%eax
f010207c:	c1 e0 0c             	shl    $0xc,%eax
f010207f:	39 c2                	cmp    %eax,%edx
f0102081:	74 19                	je     f010209c <mem_init+0xea3>
f0102083:	68 f8 40 10 f0       	push   $0xf01040f8
f0102088:	68 32 46 10 f0       	push   $0xf0104632
f010208d:	68 5e 03 00 00       	push   $0x35e
f0102092:	68 0c 46 10 f0       	push   $0xf010460c
f0102097:	e8 5c e0 ff ff       	call   f01000f8 <_panic>
	kern_pgdir[0] = 0;
f010209c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01020a2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020a5:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01020aa:	74 19                	je     f01020c5 <mem_init+0xecc>
f01020ac:	68 05 48 10 f0       	push   $0xf0104805
f01020b1:	68 32 46 10 f0       	push   $0xf0104632
f01020b6:	68 60 03 00 00       	push   $0x360
f01020bb:	68 0c 46 10 f0       	push   $0xf010460c
f01020c0:	e8 33 e0 ff ff       	call   f01000f8 <_panic>
	pp0->pp_ref = 0;
f01020c5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020c8:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01020ce:	83 ec 0c             	sub    $0xc,%esp
f01020d1:	50                   	push   %eax
f01020d2:	e8 87 ee ff ff       	call   f0100f5e <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01020d7:	83 c4 0c             	add    $0xc,%esp
f01020da:	6a 01                	push   $0x1
f01020dc:	68 00 10 40 00       	push   $0x401000
f01020e1:	ff 35 68 79 11 f0    	pushl  0xf0117968
f01020e7:	e8 d6 ee ff ff       	call   f0100fc2 <pgdir_walk>
f01020ec:	89 c7                	mov    %eax,%edi
f01020ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01020f1:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f01020f6:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01020f9:	8b 40 04             	mov    0x4(%eax),%eax
f01020fc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102101:	8b 0d 64 79 11 f0    	mov    0xf0117964,%ecx
f0102107:	89 c2                	mov    %eax,%edx
f0102109:	c1 ea 0c             	shr    $0xc,%edx
f010210c:	83 c4 10             	add    $0x10,%esp
f010210f:	39 ca                	cmp    %ecx,%edx
f0102111:	72 15                	jb     f0102128 <mem_init+0xf2f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102113:	50                   	push   %eax
f0102114:	68 70 3e 10 f0       	push   $0xf0103e70
f0102119:	68 67 03 00 00       	push   $0x367
f010211e:	68 0c 46 10 f0       	push   $0xf010460c
f0102123:	e8 d0 df ff ff       	call   f01000f8 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102128:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f010212d:	39 c7                	cmp    %eax,%edi
f010212f:	74 19                	je     f010214a <mem_init+0xf51>
f0102131:	68 91 48 10 f0       	push   $0xf0104891
f0102136:	68 32 46 10 f0       	push   $0xf0104632
f010213b:	68 68 03 00 00       	push   $0x368
f0102140:	68 0c 46 10 f0       	push   $0xf010460c
f0102145:	e8 ae df ff ff       	call   f01000f8 <_panic>
	kern_pgdir[PDX(va)] = 0;
f010214a:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010214d:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102154:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102157:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010215d:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0102163:	c1 f8 03             	sar    $0x3,%eax
f0102166:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102169:	89 c2                	mov    %eax,%edx
f010216b:	c1 ea 0c             	shr    $0xc,%edx
f010216e:	39 d1                	cmp    %edx,%ecx
f0102170:	77 12                	ja     f0102184 <mem_init+0xf8b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102172:	50                   	push   %eax
f0102173:	68 70 3e 10 f0       	push   $0xf0103e70
f0102178:	6a 52                	push   $0x52
f010217a:	68 18 46 10 f0       	push   $0xf0104618
f010217f:	e8 74 df ff ff       	call   f01000f8 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102184:	83 ec 04             	sub    $0x4,%esp
f0102187:	68 00 10 00 00       	push   $0x1000
f010218c:	68 ff 00 00 00       	push   $0xff
f0102191:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102196:	50                   	push   %eax
f0102197:	e8 d6 11 00 00       	call   f0103372 <memset>
	page_free(pp0);
f010219c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010219f:	89 3c 24             	mov    %edi,(%esp)
f01021a2:	e8 b7 ed ff ff       	call   f0100f5e <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01021a7:	83 c4 0c             	add    $0xc,%esp
f01021aa:	6a 01                	push   $0x1
f01021ac:	6a 00                	push   $0x0
f01021ae:	ff 35 68 79 11 f0    	pushl  0xf0117968
f01021b4:	e8 09 ee ff ff       	call   f0100fc2 <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01021b9:	89 fa                	mov    %edi,%edx
f01021bb:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f01021c1:	c1 fa 03             	sar    $0x3,%edx
f01021c4:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01021c7:	89 d0                	mov    %edx,%eax
f01021c9:	c1 e8 0c             	shr    $0xc,%eax
f01021cc:	83 c4 10             	add    $0x10,%esp
f01021cf:	3b 05 64 79 11 f0    	cmp    0xf0117964,%eax
f01021d5:	72 12                	jb     f01021e9 <mem_init+0xff0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01021d7:	52                   	push   %edx
f01021d8:	68 70 3e 10 f0       	push   $0xf0103e70
f01021dd:	6a 52                	push   $0x52
f01021df:	68 18 46 10 f0       	push   $0xf0104618
f01021e4:	e8 0f df ff ff       	call   f01000f8 <_panic>
	return (void *)(pa + KERNBASE);
f01021e9:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01021ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01021f2:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01021f8:	f6 00 01             	testb  $0x1,(%eax)
f01021fb:	74 19                	je     f0102216 <mem_init+0x101d>
f01021fd:	68 a9 48 10 f0       	push   $0xf01048a9
f0102202:	68 32 46 10 f0       	push   $0xf0104632
f0102207:	68 72 03 00 00       	push   $0x372
f010220c:	68 0c 46 10 f0       	push   $0xf010460c
f0102211:	e8 e2 de ff ff       	call   f01000f8 <_panic>
f0102216:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102219:	39 d0                	cmp    %edx,%eax
f010221b:	75 db                	jne    f01021f8 <mem_init+0xfff>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f010221d:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0102222:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102228:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010222b:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102231:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102234:	89 0d 3c 75 11 f0    	mov    %ecx,0xf011753c

	// free the pages we took
	page_free(pp0);
f010223a:	83 ec 0c             	sub    $0xc,%esp
f010223d:	50                   	push   %eax
f010223e:	e8 1b ed ff ff       	call   f0100f5e <page_free>
	page_free(pp1);
f0102243:	89 1c 24             	mov    %ebx,(%esp)
f0102246:	e8 13 ed ff ff       	call   f0100f5e <page_free>
	page_free(pp2);
f010224b:	89 34 24             	mov    %esi,(%esp)
f010224e:	e8 0b ed ff ff       	call   f0100f5e <page_free>

	cprintf("check_page() succeeded!\n");
f0102253:	c7 04 24 c0 48 10 f0 	movl   $0xf01048c0,(%esp)
f010225a:	e8 59 06 00 00       	call   f01028b8 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
      boot_map_region(kern_pgdir,
f010225f:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102264:	83 c4 10             	add    $0x10,%esp
f0102267:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010226c:	77 15                	ja     f0102283 <mem_init+0x108a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010226e:	50                   	push   %eax
f010226f:	68 fc 3f 10 f0       	push   $0xf0103ffc
f0102274:	68 b7 00 00 00       	push   $0xb7
f0102279:	68 0c 46 10 f0       	push   $0xf010460c
f010227e:	e8 75 de ff ff       	call   f01000f8 <_panic>
                    UPAGES,
                    ROUNDUP(sizeof(struct PageInfo)*npages, PGSIZE),
f0102283:	8b 15 64 79 11 f0    	mov    0xf0117964,%edx
f0102289:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
      boot_map_region(kern_pgdir,
f0102290:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102296:	83 ec 08             	sub    $0x8,%esp
f0102299:	6a 04                	push   $0x4
f010229b:	05 00 00 00 10       	add    $0x10000000,%eax
f01022a0:	50                   	push   %eax
f01022a1:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01022a6:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f01022ab:	e8 d7 ed ff ff       	call   f0101087 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01022b0:	83 c4 10             	add    $0x10,%esp
f01022b3:	b8 00 d0 10 f0       	mov    $0xf010d000,%eax
f01022b8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01022bd:	77 15                	ja     f01022d4 <mem_init+0x10db>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01022bf:	50                   	push   %eax
f01022c0:	68 fc 3f 10 f0       	push   $0xf0103ffc
f01022c5:	68 c7 00 00 00       	push   $0xc7
f01022ca:	68 0c 46 10 f0       	push   $0xf010460c
f01022cf:	e8 24 de ff ff       	call   f01000f8 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f01022d4:	83 ec 08             	sub    $0x8,%esp
f01022d7:	6a 03                	push   $0x3
f01022d9:	68 00 d0 10 00       	push   $0x10d000
f01022de:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01022e3:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01022e8:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f01022ed:	e8 95 ed ff ff       	call   f0101087 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	 boot_map_region(kern_pgdir, KERNBASE, ROUNDUP(~0-KERNBASE+1, PGSIZE), 0, PTE_P|PTE_W);
f01022f2:	83 c4 08             	add    $0x8,%esp
f01022f5:	6a 03                	push   $0x3
f01022f7:	6a 00                	push   $0x0
f01022f9:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01022fe:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102303:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0102308:	e8 7a ed ff ff       	call   f0101087 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f010230d:	8b 35 68 79 11 f0    	mov    0xf0117968,%esi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102313:	a1 64 79 11 f0       	mov    0xf0117964,%eax
f0102318:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010231b:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102322:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102327:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010232a:	8b 3d 6c 79 11 f0    	mov    0xf011796c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102330:	89 7d d0             	mov    %edi,-0x30(%ebp)
f0102333:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102336:	bb 00 00 00 00       	mov    $0x0,%ebx
f010233b:	eb 55                	jmp    f0102392 <mem_init+0x1199>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010233d:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102343:	89 f0                	mov    %esi,%eax
f0102345:	e8 42 e7 ff ff       	call   f0100a8c <check_va2pa>
f010234a:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102351:	77 15                	ja     f0102368 <mem_init+0x116f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102353:	57                   	push   %edi
f0102354:	68 fc 3f 10 f0       	push   $0xf0103ffc
f0102359:	68 b4 02 00 00       	push   $0x2b4
f010235e:	68 0c 46 10 f0       	push   $0xf010460c
f0102363:	e8 90 dd ff ff       	call   f01000f8 <_panic>
f0102368:	8d 94 1f 00 00 00 10 	lea    0x10000000(%edi,%ebx,1),%edx
f010236f:	39 c2                	cmp    %eax,%edx
f0102371:	74 19                	je     f010238c <mem_init+0x1193>
f0102373:	68 78 44 10 f0       	push   $0xf0104478
f0102378:	68 32 46 10 f0       	push   $0xf0104632
f010237d:	68 b4 02 00 00       	push   $0x2b4
f0102382:	68 0c 46 10 f0       	push   $0xf010460c
f0102387:	e8 6c dd ff ff       	call   f01000f8 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010238c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102392:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102395:	77 a6                	ja     f010233d <mem_init+0x1144>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102397:	8b 7d cc             	mov    -0x34(%ebp),%edi
f010239a:	c1 e7 0c             	shl    $0xc,%edi
f010239d:	bb 00 00 00 00       	mov    $0x0,%ebx
f01023a2:	eb 30                	jmp    f01023d4 <mem_init+0x11db>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01023a4:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f01023aa:	89 f0                	mov    %esi,%eax
f01023ac:	e8 db e6 ff ff       	call   f0100a8c <check_va2pa>
f01023b1:	39 c3                	cmp    %eax,%ebx
f01023b3:	74 19                	je     f01023ce <mem_init+0x11d5>
f01023b5:	68 ac 44 10 f0       	push   $0xf01044ac
f01023ba:	68 32 46 10 f0       	push   $0xf0104632
f01023bf:	68 b9 02 00 00       	push   $0x2b9
f01023c4:	68 0c 46 10 f0       	push   $0xf010460c
f01023c9:	e8 2a dd ff ff       	call   f01000f8 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01023ce:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01023d4:	39 fb                	cmp    %edi,%ebx
f01023d6:	72 cc                	jb     f01023a4 <mem_init+0x11ab>
f01023d8:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01023dd:	89 da                	mov    %ebx,%edx
f01023df:	89 f0                	mov    %esi,%eax
f01023e1:	e8 a6 e6 ff ff       	call   f0100a8c <check_va2pa>
f01023e6:	8d 93 00 50 11 10    	lea    0x10115000(%ebx),%edx
f01023ec:	39 c2                	cmp    %eax,%edx
f01023ee:	74 19                	je     f0102409 <mem_init+0x1210>
f01023f0:	68 d4 44 10 f0       	push   $0xf01044d4
f01023f5:	68 32 46 10 f0       	push   $0xf0104632
f01023fa:	68 bd 02 00 00       	push   $0x2bd
f01023ff:	68 0c 46 10 f0       	push   $0xf010460c
f0102404:	e8 ef dc ff ff       	call   f01000f8 <_panic>
f0102409:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010240f:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f0102415:	75 c6                	jne    f01023dd <mem_init+0x11e4>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102417:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f010241c:	89 f0                	mov    %esi,%eax
f010241e:	e8 69 e6 ff ff       	call   f0100a8c <check_va2pa>
f0102423:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102426:	74 51                	je     f0102479 <mem_init+0x1280>
f0102428:	68 1c 45 10 f0       	push   $0xf010451c
f010242d:	68 32 46 10 f0       	push   $0xf0104632
f0102432:	68 be 02 00 00       	push   $0x2be
f0102437:	68 0c 46 10 f0       	push   $0xf010460c
f010243c:	e8 b7 dc ff ff       	call   f01000f8 <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102441:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f0102446:	72 36                	jb     f010247e <mem_init+0x1285>
f0102448:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f010244d:	76 07                	jbe    f0102456 <mem_init+0x125d>
f010244f:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102454:	75 28                	jne    f010247e <mem_init+0x1285>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f0102456:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f010245a:	0f 85 83 00 00 00    	jne    f01024e3 <mem_init+0x12ea>
f0102460:	68 d9 48 10 f0       	push   $0xf01048d9
f0102465:	68 32 46 10 f0       	push   $0xf0104632
f010246a:	68 c6 02 00 00       	push   $0x2c6
f010246f:	68 0c 46 10 f0       	push   $0xf010460c
f0102474:	e8 7f dc ff ff       	call   f01000f8 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102479:	b8 00 00 00 00       	mov    $0x0,%eax
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010247e:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102483:	76 3f                	jbe    f01024c4 <mem_init+0x12cb>
				assert(pgdir[i] & PTE_P);
f0102485:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0102488:	f6 c2 01             	test   $0x1,%dl
f010248b:	75 19                	jne    f01024a6 <mem_init+0x12ad>
f010248d:	68 d9 48 10 f0       	push   $0xf01048d9
f0102492:	68 32 46 10 f0       	push   $0xf0104632
f0102497:	68 ca 02 00 00       	push   $0x2ca
f010249c:	68 0c 46 10 f0       	push   $0xf010460c
f01024a1:	e8 52 dc ff ff       	call   f01000f8 <_panic>
				assert(pgdir[i] & PTE_W);
f01024a6:	f6 c2 02             	test   $0x2,%dl
f01024a9:	75 38                	jne    f01024e3 <mem_init+0x12ea>
f01024ab:	68 ea 48 10 f0       	push   $0xf01048ea
f01024b0:	68 32 46 10 f0       	push   $0xf0104632
f01024b5:	68 cb 02 00 00       	push   $0x2cb
f01024ba:	68 0c 46 10 f0       	push   $0xf010460c
f01024bf:	e8 34 dc ff ff       	call   f01000f8 <_panic>
			} else
				assert(pgdir[i] == 0);
f01024c4:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f01024c8:	74 19                	je     f01024e3 <mem_init+0x12ea>
f01024ca:	68 fb 48 10 f0       	push   $0xf01048fb
f01024cf:	68 32 46 10 f0       	push   $0xf0104632
f01024d4:	68 cd 02 00 00       	push   $0x2cd
f01024d9:	68 0c 46 10 f0       	push   $0xf010460c
f01024de:	e8 15 dc ff ff       	call   f01000f8 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01024e3:	83 c0 01             	add    $0x1,%eax
f01024e6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f01024eb:	0f 86 50 ff ff ff    	jbe    f0102441 <mem_init+0x1248>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01024f1:	83 ec 0c             	sub    $0xc,%esp
f01024f4:	68 4c 45 10 f0       	push   $0xf010454c
f01024f9:	e8 ba 03 00 00       	call   f01028b8 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01024fe:	a1 68 79 11 f0       	mov    0xf0117968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102503:	83 c4 10             	add    $0x10,%esp
f0102506:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010250b:	77 15                	ja     f0102522 <mem_init+0x1329>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010250d:	50                   	push   %eax
f010250e:	68 fc 3f 10 f0       	push   $0xf0103ffc
f0102513:	68 dc 00 00 00       	push   $0xdc
f0102518:	68 0c 46 10 f0       	push   $0xf010460c
f010251d:	e8 d6 db ff ff       	call   f01000f8 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102522:	05 00 00 00 10       	add    $0x10000000,%eax
f0102527:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f010252a:	b8 00 00 00 00       	mov    $0x0,%eax
f010252f:	e8 bc e5 ff ff       	call   f0100af0 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102534:	0f 20 c0             	mov    %cr0,%eax
f0102537:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f010253a:	0d 23 00 05 80       	or     $0x80050023,%eax
f010253f:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102542:	83 ec 0c             	sub    $0xc,%esp
f0102545:	6a 00                	push   $0x0
f0102547:	e8 a2 e9 ff ff       	call   f0100eee <page_alloc>
f010254c:	89 c3                	mov    %eax,%ebx
f010254e:	83 c4 10             	add    $0x10,%esp
f0102551:	85 c0                	test   %eax,%eax
f0102553:	75 19                	jne    f010256e <mem_init+0x1375>
f0102555:	68 f7 46 10 f0       	push   $0xf01046f7
f010255a:	68 32 46 10 f0       	push   $0xf0104632
f010255f:	68 8d 03 00 00       	push   $0x38d
f0102564:	68 0c 46 10 f0       	push   $0xf010460c
f0102569:	e8 8a db ff ff       	call   f01000f8 <_panic>
	assert((pp1 = page_alloc(0)));
f010256e:	83 ec 0c             	sub    $0xc,%esp
f0102571:	6a 00                	push   $0x0
f0102573:	e8 76 e9 ff ff       	call   f0100eee <page_alloc>
f0102578:	89 c7                	mov    %eax,%edi
f010257a:	83 c4 10             	add    $0x10,%esp
f010257d:	85 c0                	test   %eax,%eax
f010257f:	75 19                	jne    f010259a <mem_init+0x13a1>
f0102581:	68 0d 47 10 f0       	push   $0xf010470d
f0102586:	68 32 46 10 f0       	push   $0xf0104632
f010258b:	68 8e 03 00 00       	push   $0x38e
f0102590:	68 0c 46 10 f0       	push   $0xf010460c
f0102595:	e8 5e db ff ff       	call   f01000f8 <_panic>
	assert((pp2 = page_alloc(0)));
f010259a:	83 ec 0c             	sub    $0xc,%esp
f010259d:	6a 00                	push   $0x0
f010259f:	e8 4a e9 ff ff       	call   f0100eee <page_alloc>
f01025a4:	89 c6                	mov    %eax,%esi
f01025a6:	83 c4 10             	add    $0x10,%esp
f01025a9:	85 c0                	test   %eax,%eax
f01025ab:	75 19                	jne    f01025c6 <mem_init+0x13cd>
f01025ad:	68 23 47 10 f0       	push   $0xf0104723
f01025b2:	68 32 46 10 f0       	push   $0xf0104632
f01025b7:	68 8f 03 00 00       	push   $0x38f
f01025bc:	68 0c 46 10 f0       	push   $0xf010460c
f01025c1:	e8 32 db ff ff       	call   f01000f8 <_panic>
	page_free(pp0);
f01025c6:	83 ec 0c             	sub    $0xc,%esp
f01025c9:	53                   	push   %ebx
f01025ca:	e8 8f e9 ff ff       	call   f0100f5e <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01025cf:	89 f8                	mov    %edi,%eax
f01025d1:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f01025d7:	c1 f8 03             	sar    $0x3,%eax
f01025da:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01025dd:	89 c2                	mov    %eax,%edx
f01025df:	c1 ea 0c             	shr    $0xc,%edx
f01025e2:	83 c4 10             	add    $0x10,%esp
f01025e5:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f01025eb:	72 12                	jb     f01025ff <mem_init+0x1406>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01025ed:	50                   	push   %eax
f01025ee:	68 70 3e 10 f0       	push   $0xf0103e70
f01025f3:	6a 52                	push   $0x52
f01025f5:	68 18 46 10 f0       	push   $0xf0104618
f01025fa:	e8 f9 da ff ff       	call   f01000f8 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f01025ff:	83 ec 04             	sub    $0x4,%esp
f0102602:	68 00 10 00 00       	push   $0x1000
f0102607:	6a 01                	push   $0x1
f0102609:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010260e:	50                   	push   %eax
f010260f:	e8 5e 0d 00 00       	call   f0103372 <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102614:	89 f0                	mov    %esi,%eax
f0102616:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f010261c:	c1 f8 03             	sar    $0x3,%eax
f010261f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102622:	89 c2                	mov    %eax,%edx
f0102624:	c1 ea 0c             	shr    $0xc,%edx
f0102627:	83 c4 10             	add    $0x10,%esp
f010262a:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0102630:	72 12                	jb     f0102644 <mem_init+0x144b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102632:	50                   	push   %eax
f0102633:	68 70 3e 10 f0       	push   $0xf0103e70
f0102638:	6a 52                	push   $0x52
f010263a:	68 18 46 10 f0       	push   $0xf0104618
f010263f:	e8 b4 da ff ff       	call   f01000f8 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102644:	83 ec 04             	sub    $0x4,%esp
f0102647:	68 00 10 00 00       	push   $0x1000
f010264c:	6a 02                	push   $0x2
f010264e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102653:	50                   	push   %eax
f0102654:	e8 19 0d 00 00       	call   f0103372 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102659:	6a 02                	push   $0x2
f010265b:	68 00 10 00 00       	push   $0x1000
f0102660:	57                   	push   %edi
f0102661:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0102667:	e8 24 eb ff ff       	call   f0101190 <page_insert>
	assert(pp1->pp_ref == 1);
f010266c:	83 c4 20             	add    $0x20,%esp
f010266f:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102674:	74 19                	je     f010268f <mem_init+0x1496>
f0102676:	68 f4 47 10 f0       	push   $0xf01047f4
f010267b:	68 32 46 10 f0       	push   $0xf0104632
f0102680:	68 94 03 00 00       	push   $0x394
f0102685:	68 0c 46 10 f0       	push   $0xf010460c
f010268a:	e8 69 da ff ff       	call   f01000f8 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010268f:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102696:	01 01 01 
f0102699:	74 19                	je     f01026b4 <mem_init+0x14bb>
f010269b:	68 6c 45 10 f0       	push   $0xf010456c
f01026a0:	68 32 46 10 f0       	push   $0xf0104632
f01026a5:	68 95 03 00 00       	push   $0x395
f01026aa:	68 0c 46 10 f0       	push   $0xf010460c
f01026af:	e8 44 da ff ff       	call   f01000f8 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01026b4:	6a 02                	push   $0x2
f01026b6:	68 00 10 00 00       	push   $0x1000
f01026bb:	56                   	push   %esi
f01026bc:	ff 35 68 79 11 f0    	pushl  0xf0117968
f01026c2:	e8 c9 ea ff ff       	call   f0101190 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01026c7:	83 c4 10             	add    $0x10,%esp
f01026ca:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01026d1:	02 02 02 
f01026d4:	74 19                	je     f01026ef <mem_init+0x14f6>
f01026d6:	68 90 45 10 f0       	push   $0xf0104590
f01026db:	68 32 46 10 f0       	push   $0xf0104632
f01026e0:	68 97 03 00 00       	push   $0x397
f01026e5:	68 0c 46 10 f0       	push   $0xf010460c
f01026ea:	e8 09 da ff ff       	call   f01000f8 <_panic>
	assert(pp2->pp_ref == 1);
f01026ef:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01026f4:	74 19                	je     f010270f <mem_init+0x1516>
f01026f6:	68 16 48 10 f0       	push   $0xf0104816
f01026fb:	68 32 46 10 f0       	push   $0xf0104632
f0102700:	68 98 03 00 00       	push   $0x398
f0102705:	68 0c 46 10 f0       	push   $0xf010460c
f010270a:	e8 e9 d9 ff ff       	call   f01000f8 <_panic>
	assert(pp1->pp_ref == 0);
f010270f:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102714:	74 19                	je     f010272f <mem_init+0x1536>
f0102716:	68 80 48 10 f0       	push   $0xf0104880
f010271b:	68 32 46 10 f0       	push   $0xf0104632
f0102720:	68 99 03 00 00       	push   $0x399
f0102725:	68 0c 46 10 f0       	push   $0xf010460c
f010272a:	e8 c9 d9 ff ff       	call   f01000f8 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f010272f:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102736:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102739:	89 f0                	mov    %esi,%eax
f010273b:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0102741:	c1 f8 03             	sar    $0x3,%eax
f0102744:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102747:	89 c2                	mov    %eax,%edx
f0102749:	c1 ea 0c             	shr    $0xc,%edx
f010274c:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0102752:	72 12                	jb     f0102766 <mem_init+0x156d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102754:	50                   	push   %eax
f0102755:	68 70 3e 10 f0       	push   $0xf0103e70
f010275a:	6a 52                	push   $0x52
f010275c:	68 18 46 10 f0       	push   $0xf0104618
f0102761:	e8 92 d9 ff ff       	call   f01000f8 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102766:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f010276d:	03 03 03 
f0102770:	74 19                	je     f010278b <mem_init+0x1592>
f0102772:	68 b4 45 10 f0       	push   $0xf01045b4
f0102777:	68 32 46 10 f0       	push   $0xf0104632
f010277c:	68 9b 03 00 00       	push   $0x39b
f0102781:	68 0c 46 10 f0       	push   $0xf010460c
f0102786:	e8 6d d9 ff ff       	call   f01000f8 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f010278b:	83 ec 08             	sub    $0x8,%esp
f010278e:	68 00 10 00 00       	push   $0x1000
f0102793:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0102799:	e8 a6 e9 ff ff       	call   f0101144 <page_remove>
	assert(pp2->pp_ref == 0);
f010279e:	83 c4 10             	add    $0x10,%esp
f01027a1:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01027a6:	74 19                	je     f01027c1 <mem_init+0x15c8>
f01027a8:	68 4e 48 10 f0       	push   $0xf010484e
f01027ad:	68 32 46 10 f0       	push   $0xf0104632
f01027b2:	68 9d 03 00 00       	push   $0x39d
f01027b7:	68 0c 46 10 f0       	push   $0xf010460c
f01027bc:	e8 37 d9 ff ff       	call   f01000f8 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01027c1:	8b 0d 68 79 11 f0    	mov    0xf0117968,%ecx
f01027c7:	8b 11                	mov    (%ecx),%edx
f01027c9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01027cf:	89 d8                	mov    %ebx,%eax
f01027d1:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f01027d7:	c1 f8 03             	sar    $0x3,%eax
f01027da:	c1 e0 0c             	shl    $0xc,%eax
f01027dd:	39 c2                	cmp    %eax,%edx
f01027df:	74 19                	je     f01027fa <mem_init+0x1601>
f01027e1:	68 f8 40 10 f0       	push   $0xf01040f8
f01027e6:	68 32 46 10 f0       	push   $0xf0104632
f01027eb:	68 a0 03 00 00       	push   $0x3a0
f01027f0:	68 0c 46 10 f0       	push   $0xf010460c
f01027f5:	e8 fe d8 ff ff       	call   f01000f8 <_panic>
	kern_pgdir[0] = 0;
f01027fa:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102800:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102805:	74 19                	je     f0102820 <mem_init+0x1627>
f0102807:	68 05 48 10 f0       	push   $0xf0104805
f010280c:	68 32 46 10 f0       	push   $0xf0104632
f0102811:	68 a2 03 00 00       	push   $0x3a2
f0102816:	68 0c 46 10 f0       	push   $0xf010460c
f010281b:	e8 d8 d8 ff ff       	call   f01000f8 <_panic>
	pp0->pp_ref = 0;
f0102820:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102826:	83 ec 0c             	sub    $0xc,%esp
f0102829:	53                   	push   %ebx
f010282a:	e8 2f e7 ff ff       	call   f0100f5e <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f010282f:	c7 04 24 e0 45 10 f0 	movl   $0xf01045e0,(%esp)
f0102836:	e8 7d 00 00 00       	call   f01028b8 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f010283b:	83 c4 10             	add    $0x10,%esp
f010283e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102841:	5b                   	pop    %ebx
f0102842:	5e                   	pop    %esi
f0102843:	5f                   	pop    %edi
f0102844:	5d                   	pop    %ebp
f0102845:	c3                   	ret    

f0102846 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0102846:	55                   	push   %ebp
f0102847:	89 e5                	mov    %esp,%ebp
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102849:	8b 45 0c             	mov    0xc(%ebp),%eax
f010284c:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f010284f:	5d                   	pop    %ebp
f0102850:	c3                   	ret    

f0102851 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102851:	55                   	push   %ebp
f0102852:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102854:	ba 70 00 00 00       	mov    $0x70,%edx
f0102859:	8b 45 08             	mov    0x8(%ebp),%eax
f010285c:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010285d:	ba 71 00 00 00       	mov    $0x71,%edx
f0102862:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102863:	0f b6 c0             	movzbl %al,%eax
}
f0102866:	5d                   	pop    %ebp
f0102867:	c3                   	ret    

f0102868 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102868:	55                   	push   %ebp
f0102869:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010286b:	ba 70 00 00 00       	mov    $0x70,%edx
f0102870:	8b 45 08             	mov    0x8(%ebp),%eax
f0102873:	ee                   	out    %al,(%dx)
f0102874:	ba 71 00 00 00       	mov    $0x71,%edx
f0102879:	8b 45 0c             	mov    0xc(%ebp),%eax
f010287c:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010287d:	5d                   	pop    %ebp
f010287e:	c3                   	ret    

f010287f <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010287f:	55                   	push   %ebp
f0102880:	89 e5                	mov    %esp,%ebp
f0102882:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102885:	ff 75 08             	pushl  0x8(%ebp)
f0102888:	e8 e0 dd ff ff       	call   f010066d <cputchar>
	*cnt++;
}
f010288d:	83 c4 10             	add    $0x10,%esp
f0102890:	c9                   	leave  
f0102891:	c3                   	ret    

f0102892 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102892:	55                   	push   %ebp
f0102893:	89 e5                	mov    %esp,%ebp
f0102895:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0102898:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010289f:	ff 75 0c             	pushl  0xc(%ebp)
f01028a2:	ff 75 08             	pushl  0x8(%ebp)
f01028a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01028a8:	50                   	push   %eax
f01028a9:	68 7f 28 10 f0       	push   $0xf010287f
f01028ae:	e8 52 04 00 00       	call   f0102d05 <vprintfmt>
	return cnt;
}
f01028b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01028b6:	c9                   	leave  
f01028b7:	c3                   	ret    

f01028b8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01028b8:	55                   	push   %ebp
f01028b9:	89 e5                	mov    %esp,%ebp
f01028bb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01028be:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01028c1:	50                   	push   %eax
f01028c2:	ff 75 08             	pushl  0x8(%ebp)
f01028c5:	e8 c8 ff ff ff       	call   f0102892 <vcprintf>
	va_end(ap);

	return cnt;
}
f01028ca:	c9                   	leave  
f01028cb:	c3                   	ret    

f01028cc <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01028cc:	55                   	push   %ebp
f01028cd:	89 e5                	mov    %esp,%ebp
f01028cf:	57                   	push   %edi
f01028d0:	56                   	push   %esi
f01028d1:	53                   	push   %ebx
f01028d2:	83 ec 14             	sub    $0x14,%esp
f01028d5:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01028d8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01028db:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01028de:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01028e1:	8b 1a                	mov    (%edx),%ebx
f01028e3:	8b 01                	mov    (%ecx),%eax
f01028e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01028e8:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01028ef:	eb 7f                	jmp    f0102970 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f01028f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01028f4:	01 d8                	add    %ebx,%eax
f01028f6:	89 c6                	mov    %eax,%esi
f01028f8:	c1 ee 1f             	shr    $0x1f,%esi
f01028fb:	01 c6                	add    %eax,%esi
f01028fd:	d1 fe                	sar    %esi
f01028ff:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0102902:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0102905:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0102908:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010290a:	eb 03                	jmp    f010290f <stab_binsearch+0x43>
			m--;
f010290c:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010290f:	39 c3                	cmp    %eax,%ebx
f0102911:	7f 0d                	jg     f0102920 <stab_binsearch+0x54>
f0102913:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0102917:	83 ea 0c             	sub    $0xc,%edx
f010291a:	39 f9                	cmp    %edi,%ecx
f010291c:	75 ee                	jne    f010290c <stab_binsearch+0x40>
f010291e:	eb 05                	jmp    f0102925 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0102920:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0102923:	eb 4b                	jmp    f0102970 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0102925:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102928:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010292b:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010292f:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0102932:	76 11                	jbe    f0102945 <stab_binsearch+0x79>
			*region_left = m;
f0102934:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0102937:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0102939:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010293c:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0102943:	eb 2b                	jmp    f0102970 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0102945:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0102948:	73 14                	jae    f010295e <stab_binsearch+0x92>
			*region_right = m - 1;
f010294a:	83 e8 01             	sub    $0x1,%eax
f010294d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102950:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0102953:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102955:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010295c:	eb 12                	jmp    f0102970 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010295e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102961:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0102963:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0102967:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102969:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0102970:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0102973:	0f 8e 78 ff ff ff    	jle    f01028f1 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0102979:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010297d:	75 0f                	jne    f010298e <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f010297f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102982:	8b 00                	mov    (%eax),%eax
f0102984:	83 e8 01             	sub    $0x1,%eax
f0102987:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010298a:	89 06                	mov    %eax,(%esi)
f010298c:	eb 2c                	jmp    f01029ba <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010298e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102991:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0102993:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102996:	8b 0e                	mov    (%esi),%ecx
f0102998:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010299b:	8b 75 ec             	mov    -0x14(%ebp),%esi
f010299e:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01029a1:	eb 03                	jmp    f01029a6 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01029a3:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01029a6:	39 c8                	cmp    %ecx,%eax
f01029a8:	7e 0b                	jle    f01029b5 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f01029aa:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01029ae:	83 ea 0c             	sub    $0xc,%edx
f01029b1:	39 df                	cmp    %ebx,%edi
f01029b3:	75 ee                	jne    f01029a3 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f01029b5:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01029b8:	89 06                	mov    %eax,(%esi)
	}
}
f01029ba:	83 c4 14             	add    $0x14,%esp
f01029bd:	5b                   	pop    %ebx
f01029be:	5e                   	pop    %esi
f01029bf:	5f                   	pop    %edi
f01029c0:	5d                   	pop    %ebp
f01029c1:	c3                   	ret    

f01029c2 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01029c2:	55                   	push   %ebp
f01029c3:	89 e5                	mov    %esp,%ebp
f01029c5:	57                   	push   %edi
f01029c6:	56                   	push   %esi
f01029c7:	53                   	push   %ebx
f01029c8:	83 ec 3c             	sub    $0x3c,%esp
f01029cb:	8b 75 08             	mov    0x8(%ebp),%esi
f01029ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01029d1:	c7 03 09 49 10 f0    	movl   $0xf0104909,(%ebx)
	info->eip_line = 0;
f01029d7:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01029de:	c7 43 08 09 49 10 f0 	movl   $0xf0104909,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01029e5:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01029ec:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01029ef:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01029f6:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01029fc:	76 11                	jbe    f0102a0f <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01029fe:	b8 b5 c5 10 f0       	mov    $0xf010c5b5,%eax
f0102a03:	3d 41 a7 10 f0       	cmp    $0xf010a741,%eax
f0102a08:	77 19                	ja     f0102a23 <debuginfo_eip+0x61>
f0102a0a:	e9 aa 01 00 00       	jmp    f0102bb9 <debuginfo_eip+0x1f7>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0102a0f:	83 ec 04             	sub    $0x4,%esp
f0102a12:	68 13 49 10 f0       	push   $0xf0104913
f0102a17:	6a 7f                	push   $0x7f
f0102a19:	68 20 49 10 f0       	push   $0xf0104920
f0102a1e:	e8 d5 d6 ff ff       	call   f01000f8 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102a23:	80 3d b4 c5 10 f0 00 	cmpb   $0x0,0xf010c5b4
f0102a2a:	0f 85 90 01 00 00    	jne    f0102bc0 <debuginfo_eip+0x1fe>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0102a30:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0102a37:	b8 40 a7 10 f0       	mov    $0xf010a740,%eax
f0102a3c:	2d 3c 4b 10 f0       	sub    $0xf0104b3c,%eax
f0102a41:	c1 f8 02             	sar    $0x2,%eax
f0102a44:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0102a4a:	83 e8 01             	sub    $0x1,%eax
f0102a4d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0102a50:	83 ec 08             	sub    $0x8,%esp
f0102a53:	56                   	push   %esi
f0102a54:	6a 64                	push   $0x64
f0102a56:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0102a59:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0102a5c:	b8 3c 4b 10 f0       	mov    $0xf0104b3c,%eax
f0102a61:	e8 66 fe ff ff       	call   f01028cc <stab_binsearch>
	if (lfile == 0)
f0102a66:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102a69:	83 c4 10             	add    $0x10,%esp
f0102a6c:	85 c0                	test   %eax,%eax
f0102a6e:	0f 84 53 01 00 00    	je     f0102bc7 <debuginfo_eip+0x205>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0102a74:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0102a77:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102a7a:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0102a7d:	83 ec 08             	sub    $0x8,%esp
f0102a80:	56                   	push   %esi
f0102a81:	6a 24                	push   $0x24
f0102a83:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0102a86:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0102a89:	b8 3c 4b 10 f0       	mov    $0xf0104b3c,%eax
f0102a8e:	e8 39 fe ff ff       	call   f01028cc <stab_binsearch>

	if (lfun <= rfun) {
f0102a93:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102a96:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102a99:	83 c4 10             	add    $0x10,%esp
f0102a9c:	39 d0                	cmp    %edx,%eax
f0102a9e:	7f 40                	jg     f0102ae0 <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0102aa0:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0102aa3:	c1 e1 02             	shl    $0x2,%ecx
f0102aa6:	8d b9 3c 4b 10 f0    	lea    -0xfefb4c4(%ecx),%edi
f0102aac:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0102aaf:	8b b9 3c 4b 10 f0    	mov    -0xfefb4c4(%ecx),%edi
f0102ab5:	b9 b5 c5 10 f0       	mov    $0xf010c5b5,%ecx
f0102aba:	81 e9 41 a7 10 f0    	sub    $0xf010a741,%ecx
f0102ac0:	39 cf                	cmp    %ecx,%edi
f0102ac2:	73 09                	jae    f0102acd <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0102ac4:	81 c7 41 a7 10 f0    	add    $0xf010a741,%edi
f0102aca:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0102acd:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0102ad0:	8b 4f 08             	mov    0x8(%edi),%ecx
f0102ad3:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0102ad6:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0102ad8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0102adb:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0102ade:	eb 0f                	jmp    f0102aef <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0102ae0:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0102ae3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102ae6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0102ae9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102aec:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0102aef:	83 ec 08             	sub    $0x8,%esp
f0102af2:	6a 3a                	push   $0x3a
f0102af4:	ff 73 08             	pushl  0x8(%ebx)
f0102af7:	e8 5a 08 00 00       	call   f0103356 <strfind>
f0102afc:	2b 43 08             	sub    0x8(%ebx),%eax
f0102aff:	89 43 0c             	mov    %eax,0xc(%ebx)


	// Search within [lline, rline] for the line number stab.
	// If found, set info->eip_line to the right line number.
	// If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0102b02:	83 c4 08             	add    $0x8,%esp
f0102b05:	56                   	push   %esi
f0102b06:	6a 44                	push   $0x44
f0102b08:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0102b0b:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0102b0e:	b8 3c 4b 10 f0       	mov    $0xf0104b3c,%eax
f0102b13:	e8 b4 fd ff ff       	call   f01028cc <stab_binsearch>
	if(lline > rline) return -1;
f0102b18:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102b1b:	83 c4 10             	add    $0x10,%esp
f0102b1e:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0102b21:	0f 8f a7 00 00 00    	jg     f0102bce <debuginfo_eip+0x20c>
	else info->eip_line = stabs[lline].n_desc;
f0102b27:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0102b2a:	8d 04 85 3c 4b 10 f0 	lea    -0xfefb4c4(,%eax,4),%eax
f0102b31:	0f b7 48 06          	movzwl 0x6(%eax),%ecx
f0102b35:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102b38:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102b3b:	eb 06                	jmp    f0102b43 <debuginfo_eip+0x181>
f0102b3d:	83 ea 01             	sub    $0x1,%edx
f0102b40:	83 e8 0c             	sub    $0xc,%eax
f0102b43:	39 d6                	cmp    %edx,%esi
f0102b45:	7f 34                	jg     f0102b7b <debuginfo_eip+0x1b9>
	       && stabs[lline].n_type != N_SOL
f0102b47:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f0102b4b:	80 f9 84             	cmp    $0x84,%cl
f0102b4e:	74 0b                	je     f0102b5b <debuginfo_eip+0x199>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0102b50:	80 f9 64             	cmp    $0x64,%cl
f0102b53:	75 e8                	jne    f0102b3d <debuginfo_eip+0x17b>
f0102b55:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0102b59:	74 e2                	je     f0102b3d <debuginfo_eip+0x17b>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0102b5b:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0102b5e:	8b 14 85 3c 4b 10 f0 	mov    -0xfefb4c4(,%eax,4),%edx
f0102b65:	b8 b5 c5 10 f0       	mov    $0xf010c5b5,%eax
f0102b6a:	2d 41 a7 10 f0       	sub    $0xf010a741,%eax
f0102b6f:	39 c2                	cmp    %eax,%edx
f0102b71:	73 08                	jae    f0102b7b <debuginfo_eip+0x1b9>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0102b73:	81 c2 41 a7 10 f0    	add    $0xf010a741,%edx
f0102b79:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102b7b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102b7e:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102b81:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102b86:	39 f2                	cmp    %esi,%edx
f0102b88:	7d 50                	jge    f0102bda <debuginfo_eip+0x218>
		for (lline = lfun + 1;
f0102b8a:	83 c2 01             	add    $0x1,%edx
f0102b8d:	89 d0                	mov    %edx,%eax
f0102b8f:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102b92:	8d 14 95 3c 4b 10 f0 	lea    -0xfefb4c4(,%edx,4),%edx
f0102b99:	eb 04                	jmp    f0102b9f <debuginfo_eip+0x1dd>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0102b9b:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0102b9f:	39 c6                	cmp    %eax,%esi
f0102ba1:	7e 32                	jle    f0102bd5 <debuginfo_eip+0x213>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0102ba3:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0102ba7:	83 c0 01             	add    $0x1,%eax
f0102baa:	83 c2 0c             	add    $0xc,%edx
f0102bad:	80 f9 a0             	cmp    $0xa0,%cl
f0102bb0:	74 e9                	je     f0102b9b <debuginfo_eip+0x1d9>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102bb2:	b8 00 00 00 00       	mov    $0x0,%eax
f0102bb7:	eb 21                	jmp    f0102bda <debuginfo_eip+0x218>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0102bb9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102bbe:	eb 1a                	jmp    f0102bda <debuginfo_eip+0x218>
f0102bc0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102bc5:	eb 13                	jmp    f0102bda <debuginfo_eip+0x218>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0102bc7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102bcc:	eb 0c                	jmp    f0102bda <debuginfo_eip+0x218>

	// Search within [lline, rline] for the line number stab.
	// If found, set info->eip_line to the right line number.
	// If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if(lline > rline) return -1;
f0102bce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102bd3:	eb 05                	jmp    f0102bda <debuginfo_eip+0x218>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102bd5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102bda:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102bdd:	5b                   	pop    %ebx
f0102bde:	5e                   	pop    %esi
f0102bdf:	5f                   	pop    %edi
f0102be0:	5d                   	pop    %ebp
f0102be1:	c3                   	ret    

f0102be2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0102be2:	55                   	push   %ebp
f0102be3:	89 e5                	mov    %esp,%ebp
f0102be5:	57                   	push   %edi
f0102be6:	56                   	push   %esi
f0102be7:	53                   	push   %ebx
f0102be8:	83 ec 1c             	sub    $0x1c,%esp
f0102beb:	89 c7                	mov    %eax,%edi
f0102bed:	89 d6                	mov    %edx,%esi
f0102bef:	8b 45 08             	mov    0x8(%ebp),%eax
f0102bf2:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102bf5:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102bf8:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0102bfb:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0102bfe:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102c03:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102c06:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0102c09:	39 d3                	cmp    %edx,%ebx
f0102c0b:	72 05                	jb     f0102c12 <printnum+0x30>
f0102c0d:	39 45 10             	cmp    %eax,0x10(%ebp)
f0102c10:	77 45                	ja     f0102c57 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0102c12:	83 ec 0c             	sub    $0xc,%esp
f0102c15:	ff 75 18             	pushl  0x18(%ebp)
f0102c18:	8b 45 14             	mov    0x14(%ebp),%eax
f0102c1b:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0102c1e:	53                   	push   %ebx
f0102c1f:	ff 75 10             	pushl  0x10(%ebp)
f0102c22:	83 ec 08             	sub    $0x8,%esp
f0102c25:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102c28:	ff 75 e0             	pushl  -0x20(%ebp)
f0102c2b:	ff 75 dc             	pushl  -0x24(%ebp)
f0102c2e:	ff 75 d8             	pushl  -0x28(%ebp)
f0102c31:	e8 4a 09 00 00       	call   f0103580 <__udivdi3>
f0102c36:	83 c4 18             	add    $0x18,%esp
f0102c39:	52                   	push   %edx
f0102c3a:	50                   	push   %eax
f0102c3b:	89 f2                	mov    %esi,%edx
f0102c3d:	89 f8                	mov    %edi,%eax
f0102c3f:	e8 9e ff ff ff       	call   f0102be2 <printnum>
f0102c44:	83 c4 20             	add    $0x20,%esp
f0102c47:	eb 18                	jmp    f0102c61 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0102c49:	83 ec 08             	sub    $0x8,%esp
f0102c4c:	56                   	push   %esi
f0102c4d:	ff 75 18             	pushl  0x18(%ebp)
f0102c50:	ff d7                	call   *%edi
f0102c52:	83 c4 10             	add    $0x10,%esp
f0102c55:	eb 03                	jmp    f0102c5a <printnum+0x78>
f0102c57:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0102c5a:	83 eb 01             	sub    $0x1,%ebx
f0102c5d:	85 db                	test   %ebx,%ebx
f0102c5f:	7f e8                	jg     f0102c49 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0102c61:	83 ec 08             	sub    $0x8,%esp
f0102c64:	56                   	push   %esi
f0102c65:	83 ec 04             	sub    $0x4,%esp
f0102c68:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102c6b:	ff 75 e0             	pushl  -0x20(%ebp)
f0102c6e:	ff 75 dc             	pushl  -0x24(%ebp)
f0102c71:	ff 75 d8             	pushl  -0x28(%ebp)
f0102c74:	e8 37 0a 00 00       	call   f01036b0 <__umoddi3>
f0102c79:	83 c4 14             	add    $0x14,%esp
f0102c7c:	0f be 80 2e 49 10 f0 	movsbl -0xfefb6d2(%eax),%eax
f0102c83:	50                   	push   %eax
f0102c84:	ff d7                	call   *%edi
}
f0102c86:	83 c4 10             	add    $0x10,%esp
f0102c89:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102c8c:	5b                   	pop    %ebx
f0102c8d:	5e                   	pop    %esi
f0102c8e:	5f                   	pop    %edi
f0102c8f:	5d                   	pop    %ebp
f0102c90:	c3                   	ret    

f0102c91 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0102c91:	55                   	push   %ebp
f0102c92:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0102c94:	83 fa 01             	cmp    $0x1,%edx
f0102c97:	7e 0e                	jle    f0102ca7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0102c99:	8b 10                	mov    (%eax),%edx
f0102c9b:	8d 4a 08             	lea    0x8(%edx),%ecx
f0102c9e:	89 08                	mov    %ecx,(%eax)
f0102ca0:	8b 02                	mov    (%edx),%eax
f0102ca2:	8b 52 04             	mov    0x4(%edx),%edx
f0102ca5:	eb 22                	jmp    f0102cc9 <getuint+0x38>
	else if (lflag)
f0102ca7:	85 d2                	test   %edx,%edx
f0102ca9:	74 10                	je     f0102cbb <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0102cab:	8b 10                	mov    (%eax),%edx
f0102cad:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102cb0:	89 08                	mov    %ecx,(%eax)
f0102cb2:	8b 02                	mov    (%edx),%eax
f0102cb4:	ba 00 00 00 00       	mov    $0x0,%edx
f0102cb9:	eb 0e                	jmp    f0102cc9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0102cbb:	8b 10                	mov    (%eax),%edx
f0102cbd:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102cc0:	89 08                	mov    %ecx,(%eax)
f0102cc2:	8b 02                	mov    (%edx),%eax
f0102cc4:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0102cc9:	5d                   	pop    %ebp
f0102cca:	c3                   	ret    

f0102ccb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0102ccb:	55                   	push   %ebp
f0102ccc:	89 e5                	mov    %esp,%ebp
f0102cce:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0102cd1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0102cd5:	8b 10                	mov    (%eax),%edx
f0102cd7:	3b 50 04             	cmp    0x4(%eax),%edx
f0102cda:	73 0a                	jae    f0102ce6 <sprintputch+0x1b>
		*b->buf++ = ch;
f0102cdc:	8d 4a 01             	lea    0x1(%edx),%ecx
f0102cdf:	89 08                	mov    %ecx,(%eax)
f0102ce1:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ce4:	88 02                	mov    %al,(%edx)
}
f0102ce6:	5d                   	pop    %ebp
f0102ce7:	c3                   	ret    

f0102ce8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0102ce8:	55                   	push   %ebp
f0102ce9:	89 e5                	mov    %esp,%ebp
f0102ceb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0102cee:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0102cf1:	50                   	push   %eax
f0102cf2:	ff 75 10             	pushl  0x10(%ebp)
f0102cf5:	ff 75 0c             	pushl  0xc(%ebp)
f0102cf8:	ff 75 08             	pushl  0x8(%ebp)
f0102cfb:	e8 05 00 00 00       	call   f0102d05 <vprintfmt>
	va_end(ap);
}
f0102d00:	83 c4 10             	add    $0x10,%esp
f0102d03:	c9                   	leave  
f0102d04:	c3                   	ret    

f0102d05 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0102d05:	55                   	push   %ebp
f0102d06:	89 e5                	mov    %esp,%ebp
f0102d08:	57                   	push   %edi
f0102d09:	56                   	push   %esi
f0102d0a:	53                   	push   %ebx
f0102d0b:	83 ec 2c             	sub    $0x2c,%esp
f0102d0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
    int color = 0;
f0102d11:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0102d18:	eb 17                	jmp    f0102d31 <vprintfmt+0x2c>
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0102d1a:	85 c0                	test   %eax,%eax
f0102d1c:	0f 84 89 03 00 00    	je     f01030ab <vprintfmt+0x3a6>
				return;
			putch(ch, putdat);
f0102d22:	83 ec 08             	sub    $0x8,%esp
f0102d25:	ff 75 0c             	pushl  0xc(%ebp)
f0102d28:	50                   	push   %eax
f0102d29:	ff 55 08             	call   *0x8(%ebp)
f0102d2c:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
    int color = 0;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0102d2f:	89 f3                	mov    %esi,%ebx
f0102d31:	8d 73 01             	lea    0x1(%ebx),%esi
f0102d34:	0f b6 03             	movzbl (%ebx),%eax
f0102d37:	83 f8 25             	cmp    $0x25,%eax
f0102d3a:	75 de                	jne    f0102d1a <vprintfmt+0x15>
f0102d3c:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f0102d40:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0102d47:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0102d4c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0102d53:	ba 00 00 00 00       	mov    $0x0,%edx
f0102d58:	eb 0d                	jmp    f0102d67 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102d5a:	89 de                	mov    %ebx,%esi
f0102d5c:	eb 09                	jmp    f0102d67 <vprintfmt+0x62>
f0102d5e:	89 de                	mov    %ebx,%esi
			break;
        case 'C': 
        //自己补充的控制颜色的代码
            switch(va_arg(ap,int)){
                case 0:
                    color = 0x0c00;
f0102d60:	c7 45 d8 00 0c 00 00 	movl   $0xc00,-0x28(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102d67:	8d 5e 01             	lea    0x1(%esi),%ebx
f0102d6a:	0f b6 06             	movzbl (%esi),%eax
f0102d6d:	0f b6 c8             	movzbl %al,%ecx
f0102d70:	83 e8 23             	sub    $0x23,%eax
f0102d73:	3c 55                	cmp    $0x55,%al
f0102d75:	0f 87 10 03 00 00    	ja     f010308b <vprintfmt+0x386>
f0102d7b:	0f b6 c0             	movzbl %al,%eax
f0102d7e:	ff 24 85 b8 49 10 f0 	jmp    *-0xfefb648(,%eax,4)
f0102d85:	89 de                	mov    %ebx,%esi
		case '-':
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0102d87:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f0102d8b:	eb da                	jmp    f0102d67 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102d8d:	89 de                	mov    %ebx,%esi
f0102d8f:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0102d94:	8d 04 bf             	lea    (%edi,%edi,4),%eax
f0102d97:	8d 7c 41 d0          	lea    -0x30(%ecx,%eax,2),%edi
				ch = *fmt;
f0102d9b:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
f0102d9e:	8d 41 d0             	lea    -0x30(%ecx),%eax
f0102da1:	83 f8 09             	cmp    $0x9,%eax
f0102da4:	77 33                	ja     f0102dd9 <vprintfmt+0xd4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0102da6:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0102da9:	eb e9                	jmp    f0102d94 <vprintfmt+0x8f>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0102dab:	8b 45 14             	mov    0x14(%ebp),%eax
f0102dae:	8d 48 04             	lea    0x4(%eax),%ecx
f0102db1:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0102db4:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102db6:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0102db8:	eb 1f                	jmp    f0102dd9 <vprintfmt+0xd4>
f0102dba:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102dbd:	85 c0                	test   %eax,%eax
f0102dbf:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102dc4:	0f 49 c8             	cmovns %eax,%ecx
f0102dc7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102dca:	89 de                	mov    %ebx,%esi
f0102dcc:	eb 99                	jmp    f0102d67 <vprintfmt+0x62>
f0102dce:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0102dd0:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
f0102dd7:	eb 8e                	jmp    f0102d67 <vprintfmt+0x62>

		process_precision:
			if (width < 0)
f0102dd9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102ddd:	79 88                	jns    f0102d67 <vprintfmt+0x62>
				width = precision, precision = -1;
f0102ddf:	89 7d e0             	mov    %edi,-0x20(%ebp)
f0102de2:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0102de7:	e9 7b ff ff ff       	jmp    f0102d67 <vprintfmt+0x62>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0102dec:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102def:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0102df1:	e9 71 ff ff ff       	jmp    f0102d67 <vprintfmt+0x62>

		case 'c':
            ch = va_arg(ap,int)+color;
f0102df6:	8b 45 14             	mov    0x14(%ebp),%eax
f0102df9:	8d 50 04             	lea    0x4(%eax),%edx
f0102dfc:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
f0102dff:	83 ec 08             	sub    $0x8,%esp
f0102e02:	ff 75 0c             	pushl  0xc(%ebp)
f0102e05:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0102e08:	03 08                	add    (%eax),%ecx
f0102e0a:	51                   	push   %ecx
f0102e0b:	ff 55 08             	call   *0x8(%ebp)
            color = 0;
			break;
f0102e0e:	83 c4 10             	add    $0x10,%esp
			goto reswitch;

		case 'c':
            ch = va_arg(ap,int)+color;
			putch(ch, putdat);
            color = 0;
f0102e11:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
			break;
f0102e18:	e9 14 ff ff ff       	jmp    f0102d31 <vprintfmt+0x2c>
        case 'C': 
        //自己补充的控制颜色的代码
            switch(va_arg(ap,int)){
f0102e1d:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e20:	8d 48 04             	lea    0x4(%eax),%ecx
f0102e23:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0102e26:	8b 00                	mov    (%eax),%eax
f0102e28:	85 c0                	test   %eax,%eax
f0102e2a:	0f 84 2e ff ff ff    	je     f0102d5e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102e30:	89 de                	mov    %ebx,%esi
f0102e32:	83 f8 01             	cmp    $0x1,%eax
f0102e35:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e3a:	b9 00 0a 00 00       	mov    $0xa00,%ecx
f0102e3f:	0f 44 c1             	cmove  %ecx,%eax
f0102e42:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102e45:	e9 1d ff ff ff       	jmp    f0102d67 <vprintfmt+0x62>
            }

            goto reswitch;
		// error message
		case 'e':
			err = va_arg(ap, int);
f0102e4a:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e4d:	8d 50 04             	lea    0x4(%eax),%edx
f0102e50:	89 55 14             	mov    %edx,0x14(%ebp)
f0102e53:	8b 00                	mov    (%eax),%eax
f0102e55:	99                   	cltd   
f0102e56:	31 d0                	xor    %edx,%eax
f0102e58:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0102e5a:	83 f8 06             	cmp    $0x6,%eax
f0102e5d:	7f 0b                	jg     f0102e6a <vprintfmt+0x165>
f0102e5f:	8b 14 85 10 4b 10 f0 	mov    -0xfefb4f0(,%eax,4),%edx
f0102e66:	85 d2                	test   %edx,%edx
f0102e68:	75 19                	jne    f0102e83 <vprintfmt+0x17e>
				printfmt(putch, putdat, "error %d", err);
f0102e6a:	50                   	push   %eax
f0102e6b:	68 46 49 10 f0       	push   $0xf0104946
f0102e70:	ff 75 0c             	pushl  0xc(%ebp)
f0102e73:	ff 75 08             	pushl  0x8(%ebp)
f0102e76:	e8 6d fe ff ff       	call   f0102ce8 <printfmt>
f0102e7b:	83 c4 10             	add    $0x10,%esp
f0102e7e:	e9 ae fe ff ff       	jmp    f0102d31 <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
f0102e83:	52                   	push   %edx
f0102e84:	68 44 46 10 f0       	push   $0xf0104644
f0102e89:	ff 75 0c             	pushl  0xc(%ebp)
f0102e8c:	ff 75 08             	pushl  0x8(%ebp)
f0102e8f:	e8 54 fe ff ff       	call   f0102ce8 <printfmt>
f0102e94:	83 c4 10             	add    $0x10,%esp
f0102e97:	e9 95 fe ff ff       	jmp    f0102d31 <vprintfmt+0x2c>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0102e9c:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e9f:	8d 50 04             	lea    0x4(%eax),%edx
f0102ea2:	89 55 14             	mov    %edx,0x14(%ebp)
f0102ea5:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f0102ea7:	85 f6                	test   %esi,%esi
f0102ea9:	b8 3f 49 10 f0       	mov    $0xf010493f,%eax
f0102eae:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
f0102eb1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102eb5:	0f 8e 89 00 00 00    	jle    f0102f44 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
f0102ebb:	83 ec 08             	sub    $0x8,%esp
f0102ebe:	57                   	push   %edi
f0102ebf:	56                   	push   %esi
f0102ec0:	e8 47 03 00 00       	call   f010320c <strnlen>
f0102ec5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102ec8:	29 c1                	sub    %eax,%ecx
f0102eca:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102ecd:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0102ed0:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
f0102ed4:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0102ed7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0102eda:	8b 75 0c             	mov    0xc(%ebp),%esi
f0102edd:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0102ee0:	89 cb                	mov    %ecx,%ebx
f0102ee2:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102ee4:	eb 0e                	jmp    f0102ef4 <vprintfmt+0x1ef>
					putch(padc, putdat);
f0102ee6:	83 ec 08             	sub    $0x8,%esp
f0102ee9:	56                   	push   %esi
f0102eea:	57                   	push   %edi
f0102eeb:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102eee:	83 eb 01             	sub    $0x1,%ebx
f0102ef1:	83 c4 10             	add    $0x10,%esp
f0102ef4:	85 db                	test   %ebx,%ebx
f0102ef6:	7f ee                	jg     f0102ee6 <vprintfmt+0x1e1>
f0102ef8:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0102efb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102efe:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102f01:	85 c9                	test   %ecx,%ecx
f0102f03:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f08:	0f 49 c1             	cmovns %ecx,%eax
f0102f0b:	29 c1                	sub    %eax,%ecx
f0102f0d:	89 cb                	mov    %ecx,%ebx
f0102f0f:	eb 39                	jmp    f0102f4a <vprintfmt+0x245>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0102f11:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0102f15:	74 1b                	je     f0102f32 <vprintfmt+0x22d>
f0102f17:	0f be c0             	movsbl %al,%eax
f0102f1a:	83 e8 20             	sub    $0x20,%eax
f0102f1d:	83 f8 5e             	cmp    $0x5e,%eax
f0102f20:	76 10                	jbe    f0102f32 <vprintfmt+0x22d>
					putch('?', putdat);
f0102f22:	83 ec 08             	sub    $0x8,%esp
f0102f25:	ff 75 0c             	pushl  0xc(%ebp)
f0102f28:	6a 3f                	push   $0x3f
f0102f2a:	ff 55 08             	call   *0x8(%ebp)
f0102f2d:	83 c4 10             	add    $0x10,%esp
f0102f30:	eb 0d                	jmp    f0102f3f <vprintfmt+0x23a>
				else
					putch(ch, putdat);
f0102f32:	83 ec 08             	sub    $0x8,%esp
f0102f35:	ff 75 0c             	pushl  0xc(%ebp)
f0102f38:	52                   	push   %edx
f0102f39:	ff 55 08             	call   *0x8(%ebp)
f0102f3c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0102f3f:	83 eb 01             	sub    $0x1,%ebx
f0102f42:	eb 06                	jmp    f0102f4a <vprintfmt+0x245>
f0102f44:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0102f47:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102f4a:	83 c6 01             	add    $0x1,%esi
f0102f4d:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
f0102f51:	0f be d0             	movsbl %al,%edx
f0102f54:	85 d2                	test   %edx,%edx
f0102f56:	74 25                	je     f0102f7d <vprintfmt+0x278>
f0102f58:	85 ff                	test   %edi,%edi
f0102f5a:	78 b5                	js     f0102f11 <vprintfmt+0x20c>
f0102f5c:	83 ef 01             	sub    $0x1,%edi
f0102f5f:	79 b0                	jns    f0102f11 <vprintfmt+0x20c>
f0102f61:	89 d8                	mov    %ebx,%eax
f0102f63:	8b 75 08             	mov    0x8(%ebp),%esi
f0102f66:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0102f69:	89 c3                	mov    %eax,%ebx
f0102f6b:	eb 16                	jmp    f0102f83 <vprintfmt+0x27e>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0102f6d:	83 ec 08             	sub    $0x8,%esp
f0102f70:	57                   	push   %edi
f0102f71:	6a 20                	push   $0x20
f0102f73:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0102f75:	83 eb 01             	sub    $0x1,%ebx
f0102f78:	83 c4 10             	add    $0x10,%esp
f0102f7b:	eb 06                	jmp    f0102f83 <vprintfmt+0x27e>
f0102f7d:	8b 75 08             	mov    0x8(%ebp),%esi
f0102f80:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0102f83:	85 db                	test   %ebx,%ebx
f0102f85:	7f e6                	jg     f0102f6d <vprintfmt+0x268>
f0102f87:	89 75 08             	mov    %esi,0x8(%ebp)
f0102f8a:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0102f8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0102f90:	e9 9c fd ff ff       	jmp    f0102d31 <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0102f95:	83 fa 01             	cmp    $0x1,%edx
f0102f98:	7e 10                	jle    f0102faa <vprintfmt+0x2a5>
		return va_arg(*ap, long long);
f0102f9a:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f9d:	8d 50 08             	lea    0x8(%eax),%edx
f0102fa0:	89 55 14             	mov    %edx,0x14(%ebp)
f0102fa3:	8b 30                	mov    (%eax),%esi
f0102fa5:	8b 78 04             	mov    0x4(%eax),%edi
f0102fa8:	eb 26                	jmp    f0102fd0 <vprintfmt+0x2cb>
	else if (lflag)
f0102faa:	85 d2                	test   %edx,%edx
f0102fac:	74 12                	je     f0102fc0 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0102fae:	8b 45 14             	mov    0x14(%ebp),%eax
f0102fb1:	8d 50 04             	lea    0x4(%eax),%edx
f0102fb4:	89 55 14             	mov    %edx,0x14(%ebp)
f0102fb7:	8b 30                	mov    (%eax),%esi
f0102fb9:	89 f7                	mov    %esi,%edi
f0102fbb:	c1 ff 1f             	sar    $0x1f,%edi
f0102fbe:	eb 10                	jmp    f0102fd0 <vprintfmt+0x2cb>
	else
		return va_arg(*ap, int);
f0102fc0:	8b 45 14             	mov    0x14(%ebp),%eax
f0102fc3:	8d 50 04             	lea    0x4(%eax),%edx
f0102fc6:	89 55 14             	mov    %edx,0x14(%ebp)
f0102fc9:	8b 30                	mov    (%eax),%esi
f0102fcb:	89 f7                	mov    %esi,%edi
f0102fcd:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0102fd0:	89 f0                	mov    %esi,%eax
f0102fd2:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0102fd4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0102fd9:	85 ff                	test   %edi,%edi
f0102fdb:	79 7b                	jns    f0103058 <vprintfmt+0x353>
				putch('-', putdat);
f0102fdd:	83 ec 08             	sub    $0x8,%esp
f0102fe0:	ff 75 0c             	pushl  0xc(%ebp)
f0102fe3:	6a 2d                	push   $0x2d
f0102fe5:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0102fe8:	89 f0                	mov    %esi,%eax
f0102fea:	89 fa                	mov    %edi,%edx
f0102fec:	f7 d8                	neg    %eax
f0102fee:	83 d2 00             	adc    $0x0,%edx
f0102ff1:	f7 da                	neg    %edx
f0102ff3:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0102ff6:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0102ffb:	eb 5b                	jmp    f0103058 <vprintfmt+0x353>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0102ffd:	8d 45 14             	lea    0x14(%ebp),%eax
f0103000:	e8 8c fc ff ff       	call   f0102c91 <getuint>
			base = 10;
f0103005:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f010300a:	eb 4c                	jmp    f0103058 <vprintfmt+0x353>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f010300c:	8d 45 14             	lea    0x14(%ebp),%eax
f010300f:	e8 7d fc ff ff       	call   f0102c91 <getuint>
			base = 8;
f0103014:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
f0103019:	eb 3d                	jmp    f0103058 <vprintfmt+0x353>
		// pointer
		case 'p':
			putch('0', putdat);
f010301b:	83 ec 08             	sub    $0x8,%esp
f010301e:	ff 75 0c             	pushl  0xc(%ebp)
f0103021:	6a 30                	push   $0x30
f0103023:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0103026:	83 c4 08             	add    $0x8,%esp
f0103029:	ff 75 0c             	pushl  0xc(%ebp)
f010302c:	6a 78                	push   $0x78
f010302e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0103031:	8b 45 14             	mov    0x14(%ebp),%eax
f0103034:	8d 50 04             	lea    0x4(%eax),%edx
f0103037:	89 55 14             	mov    %edx,0x14(%ebp)
            goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010303a:	8b 00                	mov    (%eax),%eax
f010303c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0103041:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0103044:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0103049:	eb 0d                	jmp    f0103058 <vprintfmt+0x353>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010304b:	8d 45 14             	lea    0x14(%ebp),%eax
f010304e:	e8 3e fc ff ff       	call   f0102c91 <getuint>
			base = 16;
f0103053:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0103058:	83 ec 0c             	sub    $0xc,%esp
f010305b:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
f010305f:	56                   	push   %esi
f0103060:	ff 75 e0             	pushl  -0x20(%ebp)
f0103063:	51                   	push   %ecx
f0103064:	52                   	push   %edx
f0103065:	50                   	push   %eax
f0103066:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103069:	8b 45 08             	mov    0x8(%ebp),%eax
f010306c:	e8 71 fb ff ff       	call   f0102be2 <printnum>
			break;
f0103071:	83 c4 20             	add    $0x20,%esp
f0103074:	e9 b8 fc ff ff       	jmp    f0102d31 <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0103079:	83 ec 08             	sub    $0x8,%esp
f010307c:	ff 75 0c             	pushl  0xc(%ebp)
f010307f:	51                   	push   %ecx
f0103080:	ff 55 08             	call   *0x8(%ebp)
			break;
f0103083:	83 c4 10             	add    $0x10,%esp
f0103086:	e9 a6 fc ff ff       	jmp    f0102d31 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010308b:	83 ec 08             	sub    $0x8,%esp
f010308e:	ff 75 0c             	pushl  0xc(%ebp)
f0103091:	6a 25                	push   $0x25
f0103093:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103096:	83 c4 10             	add    $0x10,%esp
f0103099:	89 f3                	mov    %esi,%ebx
f010309b:	eb 03                	jmp    f01030a0 <vprintfmt+0x39b>
f010309d:	83 eb 01             	sub    $0x1,%ebx
f01030a0:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f01030a4:	75 f7                	jne    f010309d <vprintfmt+0x398>
f01030a6:	e9 86 fc ff ff       	jmp    f0102d31 <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
f01030ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01030ae:	5b                   	pop    %ebx
f01030af:	5e                   	pop    %esi
f01030b0:	5f                   	pop    %edi
f01030b1:	5d                   	pop    %ebp
f01030b2:	c3                   	ret    

f01030b3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01030b3:	55                   	push   %ebp
f01030b4:	89 e5                	mov    %esp,%ebp
f01030b6:	83 ec 18             	sub    $0x18,%esp
f01030b9:	8b 45 08             	mov    0x8(%ebp),%eax
f01030bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01030bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01030c2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01030c6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01030c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01030d0:	85 c0                	test   %eax,%eax
f01030d2:	74 26                	je     f01030fa <vsnprintf+0x47>
f01030d4:	85 d2                	test   %edx,%edx
f01030d6:	7e 22                	jle    f01030fa <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01030d8:	ff 75 14             	pushl  0x14(%ebp)
f01030db:	ff 75 10             	pushl  0x10(%ebp)
f01030de:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01030e1:	50                   	push   %eax
f01030e2:	68 cb 2c 10 f0       	push   $0xf0102ccb
f01030e7:	e8 19 fc ff ff       	call   f0102d05 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01030ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01030ef:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01030f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01030f5:	83 c4 10             	add    $0x10,%esp
f01030f8:	eb 05                	jmp    f01030ff <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01030fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01030ff:	c9                   	leave  
f0103100:	c3                   	ret    

f0103101 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103101:	55                   	push   %ebp
f0103102:	89 e5                	mov    %esp,%ebp
f0103104:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0103107:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010310a:	50                   	push   %eax
f010310b:	ff 75 10             	pushl  0x10(%ebp)
f010310e:	ff 75 0c             	pushl  0xc(%ebp)
f0103111:	ff 75 08             	pushl  0x8(%ebp)
f0103114:	e8 9a ff ff ff       	call   f01030b3 <vsnprintf>
	va_end(ap);

	return rc;
}
f0103119:	c9                   	leave  
f010311a:	c3                   	ret    

f010311b <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f010311b:	55                   	push   %ebp
f010311c:	89 e5                	mov    %esp,%ebp
f010311e:	57                   	push   %edi
f010311f:	56                   	push   %esi
f0103120:	53                   	push   %ebx
f0103121:	83 ec 0c             	sub    $0xc,%esp
f0103124:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0103127:	85 c0                	test   %eax,%eax
f0103129:	74 11                	je     f010313c <readline+0x21>
		cprintf("%s", prompt);
f010312b:	83 ec 08             	sub    $0x8,%esp
f010312e:	50                   	push   %eax
f010312f:	68 44 46 10 f0       	push   $0xf0104644
f0103134:	e8 7f f7 ff ff       	call   f01028b8 <cprintf>
f0103139:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f010313c:	83 ec 0c             	sub    $0xc,%esp
f010313f:	6a 00                	push   $0x0
f0103141:	e8 48 d5 ff ff       	call   f010068e <iscons>
f0103146:	89 c7                	mov    %eax,%edi
f0103148:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010314b:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0103150:	e8 28 d5 ff ff       	call   f010067d <getchar>
f0103155:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0103157:	85 c0                	test   %eax,%eax
f0103159:	79 18                	jns    f0103173 <readline+0x58>
			cprintf("read error: %e\n", c);
f010315b:	83 ec 08             	sub    $0x8,%esp
f010315e:	50                   	push   %eax
f010315f:	68 2c 4b 10 f0       	push   $0xf0104b2c
f0103164:	e8 4f f7 ff ff       	call   f01028b8 <cprintf>
			return NULL;
f0103169:	83 c4 10             	add    $0x10,%esp
f010316c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103171:	eb 79                	jmp    f01031ec <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103173:	83 f8 08             	cmp    $0x8,%eax
f0103176:	0f 94 c2             	sete   %dl
f0103179:	83 f8 7f             	cmp    $0x7f,%eax
f010317c:	0f 94 c0             	sete   %al
f010317f:	08 c2                	or     %al,%dl
f0103181:	74 1a                	je     f010319d <readline+0x82>
f0103183:	85 f6                	test   %esi,%esi
f0103185:	7e 16                	jle    f010319d <readline+0x82>
			if (echoing)
f0103187:	85 ff                	test   %edi,%edi
f0103189:	74 0d                	je     f0103198 <readline+0x7d>
				cputchar('\b');
f010318b:	83 ec 0c             	sub    $0xc,%esp
f010318e:	6a 08                	push   $0x8
f0103190:	e8 d8 d4 ff ff       	call   f010066d <cputchar>
f0103195:	83 c4 10             	add    $0x10,%esp
			i--;
f0103198:	83 ee 01             	sub    $0x1,%esi
f010319b:	eb b3                	jmp    f0103150 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010319d:	83 fb 1f             	cmp    $0x1f,%ebx
f01031a0:	7e 23                	jle    f01031c5 <readline+0xaa>
f01031a2:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01031a8:	7f 1b                	jg     f01031c5 <readline+0xaa>
			if (echoing)
f01031aa:	85 ff                	test   %edi,%edi
f01031ac:	74 0c                	je     f01031ba <readline+0x9f>
				cputchar(c);
f01031ae:	83 ec 0c             	sub    $0xc,%esp
f01031b1:	53                   	push   %ebx
f01031b2:	e8 b6 d4 ff ff       	call   f010066d <cputchar>
f01031b7:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01031ba:	88 9e 60 75 11 f0    	mov    %bl,-0xfee8aa0(%esi)
f01031c0:	8d 76 01             	lea    0x1(%esi),%esi
f01031c3:	eb 8b                	jmp    f0103150 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01031c5:	83 fb 0a             	cmp    $0xa,%ebx
f01031c8:	74 05                	je     f01031cf <readline+0xb4>
f01031ca:	83 fb 0d             	cmp    $0xd,%ebx
f01031cd:	75 81                	jne    f0103150 <readline+0x35>
			if (echoing)
f01031cf:	85 ff                	test   %edi,%edi
f01031d1:	74 0d                	je     f01031e0 <readline+0xc5>
				cputchar('\n');
f01031d3:	83 ec 0c             	sub    $0xc,%esp
f01031d6:	6a 0a                	push   $0xa
f01031d8:	e8 90 d4 ff ff       	call   f010066d <cputchar>
f01031dd:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01031e0:	c6 86 60 75 11 f0 00 	movb   $0x0,-0xfee8aa0(%esi)
			return buf;
f01031e7:	b8 60 75 11 f0       	mov    $0xf0117560,%eax
		}
	}
}
f01031ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01031ef:	5b                   	pop    %ebx
f01031f0:	5e                   	pop    %esi
f01031f1:	5f                   	pop    %edi
f01031f2:	5d                   	pop    %ebp
f01031f3:	c3                   	ret    

f01031f4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01031f4:	55                   	push   %ebp
f01031f5:	89 e5                	mov    %esp,%ebp
f01031f7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01031fa:	b8 00 00 00 00       	mov    $0x0,%eax
f01031ff:	eb 03                	jmp    f0103204 <strlen+0x10>
		n++;
f0103201:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0103204:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103208:	75 f7                	jne    f0103201 <strlen+0xd>
		n++;
	return n;
}
f010320a:	5d                   	pop    %ebp
f010320b:	c3                   	ret    

f010320c <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010320c:	55                   	push   %ebp
f010320d:	89 e5                	mov    %esp,%ebp
f010320f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103212:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103215:	ba 00 00 00 00       	mov    $0x0,%edx
f010321a:	eb 03                	jmp    f010321f <strnlen+0x13>
		n++;
f010321c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010321f:	39 c2                	cmp    %eax,%edx
f0103221:	74 08                	je     f010322b <strnlen+0x1f>
f0103223:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0103227:	75 f3                	jne    f010321c <strnlen+0x10>
f0103229:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f010322b:	5d                   	pop    %ebp
f010322c:	c3                   	ret    

f010322d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010322d:	55                   	push   %ebp
f010322e:	89 e5                	mov    %esp,%ebp
f0103230:	53                   	push   %ebx
f0103231:	8b 45 08             	mov    0x8(%ebp),%eax
f0103234:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103237:	89 c2                	mov    %eax,%edx
f0103239:	83 c2 01             	add    $0x1,%edx
f010323c:	83 c1 01             	add    $0x1,%ecx
f010323f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0103243:	88 5a ff             	mov    %bl,-0x1(%edx)
f0103246:	84 db                	test   %bl,%bl
f0103248:	75 ef                	jne    f0103239 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010324a:	5b                   	pop    %ebx
f010324b:	5d                   	pop    %ebp
f010324c:	c3                   	ret    

f010324d <strcat>:

char *
strcat(char *dst, const char *src)
{
f010324d:	55                   	push   %ebp
f010324e:	89 e5                	mov    %esp,%ebp
f0103250:	53                   	push   %ebx
f0103251:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103254:	53                   	push   %ebx
f0103255:	e8 9a ff ff ff       	call   f01031f4 <strlen>
f010325a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010325d:	ff 75 0c             	pushl  0xc(%ebp)
f0103260:	01 d8                	add    %ebx,%eax
f0103262:	50                   	push   %eax
f0103263:	e8 c5 ff ff ff       	call   f010322d <strcpy>
	return dst;
}
f0103268:	89 d8                	mov    %ebx,%eax
f010326a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010326d:	c9                   	leave  
f010326e:	c3                   	ret    

f010326f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010326f:	55                   	push   %ebp
f0103270:	89 e5                	mov    %esp,%ebp
f0103272:	56                   	push   %esi
f0103273:	53                   	push   %ebx
f0103274:	8b 75 08             	mov    0x8(%ebp),%esi
f0103277:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010327a:	89 f3                	mov    %esi,%ebx
f010327c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010327f:	89 f2                	mov    %esi,%edx
f0103281:	eb 0f                	jmp    f0103292 <strncpy+0x23>
		*dst++ = *src;
f0103283:	83 c2 01             	add    $0x1,%edx
f0103286:	0f b6 01             	movzbl (%ecx),%eax
f0103289:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010328c:	80 39 01             	cmpb   $0x1,(%ecx)
f010328f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103292:	39 da                	cmp    %ebx,%edx
f0103294:	75 ed                	jne    f0103283 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0103296:	89 f0                	mov    %esi,%eax
f0103298:	5b                   	pop    %ebx
f0103299:	5e                   	pop    %esi
f010329a:	5d                   	pop    %ebp
f010329b:	c3                   	ret    

f010329c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010329c:	55                   	push   %ebp
f010329d:	89 e5                	mov    %esp,%ebp
f010329f:	56                   	push   %esi
f01032a0:	53                   	push   %ebx
f01032a1:	8b 75 08             	mov    0x8(%ebp),%esi
f01032a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01032a7:	8b 55 10             	mov    0x10(%ebp),%edx
f01032aa:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01032ac:	85 d2                	test   %edx,%edx
f01032ae:	74 21                	je     f01032d1 <strlcpy+0x35>
f01032b0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01032b4:	89 f2                	mov    %esi,%edx
f01032b6:	eb 09                	jmp    f01032c1 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01032b8:	83 c2 01             	add    $0x1,%edx
f01032bb:	83 c1 01             	add    $0x1,%ecx
f01032be:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01032c1:	39 c2                	cmp    %eax,%edx
f01032c3:	74 09                	je     f01032ce <strlcpy+0x32>
f01032c5:	0f b6 19             	movzbl (%ecx),%ebx
f01032c8:	84 db                	test   %bl,%bl
f01032ca:	75 ec                	jne    f01032b8 <strlcpy+0x1c>
f01032cc:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01032ce:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01032d1:	29 f0                	sub    %esi,%eax
}
f01032d3:	5b                   	pop    %ebx
f01032d4:	5e                   	pop    %esi
f01032d5:	5d                   	pop    %ebp
f01032d6:	c3                   	ret    

f01032d7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01032d7:	55                   	push   %ebp
f01032d8:	89 e5                	mov    %esp,%ebp
f01032da:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01032dd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01032e0:	eb 06                	jmp    f01032e8 <strcmp+0x11>
		p++, q++;
f01032e2:	83 c1 01             	add    $0x1,%ecx
f01032e5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01032e8:	0f b6 01             	movzbl (%ecx),%eax
f01032eb:	84 c0                	test   %al,%al
f01032ed:	74 04                	je     f01032f3 <strcmp+0x1c>
f01032ef:	3a 02                	cmp    (%edx),%al
f01032f1:	74 ef                	je     f01032e2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01032f3:	0f b6 c0             	movzbl %al,%eax
f01032f6:	0f b6 12             	movzbl (%edx),%edx
f01032f9:	29 d0                	sub    %edx,%eax
}
f01032fb:	5d                   	pop    %ebp
f01032fc:	c3                   	ret    

f01032fd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01032fd:	55                   	push   %ebp
f01032fe:	89 e5                	mov    %esp,%ebp
f0103300:	53                   	push   %ebx
f0103301:	8b 45 08             	mov    0x8(%ebp),%eax
f0103304:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103307:	89 c3                	mov    %eax,%ebx
f0103309:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010330c:	eb 06                	jmp    f0103314 <strncmp+0x17>
		n--, p++, q++;
f010330e:	83 c0 01             	add    $0x1,%eax
f0103311:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0103314:	39 d8                	cmp    %ebx,%eax
f0103316:	74 15                	je     f010332d <strncmp+0x30>
f0103318:	0f b6 08             	movzbl (%eax),%ecx
f010331b:	84 c9                	test   %cl,%cl
f010331d:	74 04                	je     f0103323 <strncmp+0x26>
f010331f:	3a 0a                	cmp    (%edx),%cl
f0103321:	74 eb                	je     f010330e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103323:	0f b6 00             	movzbl (%eax),%eax
f0103326:	0f b6 12             	movzbl (%edx),%edx
f0103329:	29 d0                	sub    %edx,%eax
f010332b:	eb 05                	jmp    f0103332 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f010332d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0103332:	5b                   	pop    %ebx
f0103333:	5d                   	pop    %ebp
f0103334:	c3                   	ret    

f0103335 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103335:	55                   	push   %ebp
f0103336:	89 e5                	mov    %esp,%ebp
f0103338:	8b 45 08             	mov    0x8(%ebp),%eax
f010333b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010333f:	eb 07                	jmp    f0103348 <strchr+0x13>
		if (*s == c)
f0103341:	38 ca                	cmp    %cl,%dl
f0103343:	74 0f                	je     f0103354 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0103345:	83 c0 01             	add    $0x1,%eax
f0103348:	0f b6 10             	movzbl (%eax),%edx
f010334b:	84 d2                	test   %dl,%dl
f010334d:	75 f2                	jne    f0103341 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f010334f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103354:	5d                   	pop    %ebp
f0103355:	c3                   	ret    

f0103356 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103356:	55                   	push   %ebp
f0103357:	89 e5                	mov    %esp,%ebp
f0103359:	8b 45 08             	mov    0x8(%ebp),%eax
f010335c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103360:	eb 03                	jmp    f0103365 <strfind+0xf>
f0103362:	83 c0 01             	add    $0x1,%eax
f0103365:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0103368:	38 ca                	cmp    %cl,%dl
f010336a:	74 04                	je     f0103370 <strfind+0x1a>
f010336c:	84 d2                	test   %dl,%dl
f010336e:	75 f2                	jne    f0103362 <strfind+0xc>
			break;
	return (char *) s;
}
f0103370:	5d                   	pop    %ebp
f0103371:	c3                   	ret    

f0103372 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103372:	55                   	push   %ebp
f0103373:	89 e5                	mov    %esp,%ebp
f0103375:	57                   	push   %edi
f0103376:	56                   	push   %esi
f0103377:	53                   	push   %ebx
f0103378:	8b 7d 08             	mov    0x8(%ebp),%edi
f010337b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010337e:	85 c9                	test   %ecx,%ecx
f0103380:	74 36                	je     f01033b8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103382:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0103388:	75 28                	jne    f01033b2 <memset+0x40>
f010338a:	f6 c1 03             	test   $0x3,%cl
f010338d:	75 23                	jne    f01033b2 <memset+0x40>
		c &= 0xFF;
f010338f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103393:	89 d3                	mov    %edx,%ebx
f0103395:	c1 e3 08             	shl    $0x8,%ebx
f0103398:	89 d6                	mov    %edx,%esi
f010339a:	c1 e6 18             	shl    $0x18,%esi
f010339d:	89 d0                	mov    %edx,%eax
f010339f:	c1 e0 10             	shl    $0x10,%eax
f01033a2:	09 f0                	or     %esi,%eax
f01033a4:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f01033a6:	89 d8                	mov    %ebx,%eax
f01033a8:	09 d0                	or     %edx,%eax
f01033aa:	c1 e9 02             	shr    $0x2,%ecx
f01033ad:	fc                   	cld    
f01033ae:	f3 ab                	rep stos %eax,%es:(%edi)
f01033b0:	eb 06                	jmp    f01033b8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01033b2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01033b5:	fc                   	cld    
f01033b6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01033b8:	89 f8                	mov    %edi,%eax
f01033ba:	5b                   	pop    %ebx
f01033bb:	5e                   	pop    %esi
f01033bc:	5f                   	pop    %edi
f01033bd:	5d                   	pop    %ebp
f01033be:	c3                   	ret    

f01033bf <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01033bf:	55                   	push   %ebp
f01033c0:	89 e5                	mov    %esp,%ebp
f01033c2:	57                   	push   %edi
f01033c3:	56                   	push   %esi
f01033c4:	8b 45 08             	mov    0x8(%ebp),%eax
f01033c7:	8b 75 0c             	mov    0xc(%ebp),%esi
f01033ca:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01033cd:	39 c6                	cmp    %eax,%esi
f01033cf:	73 35                	jae    f0103406 <memmove+0x47>
f01033d1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01033d4:	39 d0                	cmp    %edx,%eax
f01033d6:	73 2e                	jae    f0103406 <memmove+0x47>
		s += n;
		d += n;
f01033d8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01033db:	89 d6                	mov    %edx,%esi
f01033dd:	09 fe                	or     %edi,%esi
f01033df:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01033e5:	75 13                	jne    f01033fa <memmove+0x3b>
f01033e7:	f6 c1 03             	test   $0x3,%cl
f01033ea:	75 0e                	jne    f01033fa <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01033ec:	83 ef 04             	sub    $0x4,%edi
f01033ef:	8d 72 fc             	lea    -0x4(%edx),%esi
f01033f2:	c1 e9 02             	shr    $0x2,%ecx
f01033f5:	fd                   	std    
f01033f6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01033f8:	eb 09                	jmp    f0103403 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01033fa:	83 ef 01             	sub    $0x1,%edi
f01033fd:	8d 72 ff             	lea    -0x1(%edx),%esi
f0103400:	fd                   	std    
f0103401:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0103403:	fc                   	cld    
f0103404:	eb 1d                	jmp    f0103423 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103406:	89 f2                	mov    %esi,%edx
f0103408:	09 c2                	or     %eax,%edx
f010340a:	f6 c2 03             	test   $0x3,%dl
f010340d:	75 0f                	jne    f010341e <memmove+0x5f>
f010340f:	f6 c1 03             	test   $0x3,%cl
f0103412:	75 0a                	jne    f010341e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0103414:	c1 e9 02             	shr    $0x2,%ecx
f0103417:	89 c7                	mov    %eax,%edi
f0103419:	fc                   	cld    
f010341a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010341c:	eb 05                	jmp    f0103423 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010341e:	89 c7                	mov    %eax,%edi
f0103420:	fc                   	cld    
f0103421:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0103423:	5e                   	pop    %esi
f0103424:	5f                   	pop    %edi
f0103425:	5d                   	pop    %ebp
f0103426:	c3                   	ret    

f0103427 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0103427:	55                   	push   %ebp
f0103428:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010342a:	ff 75 10             	pushl  0x10(%ebp)
f010342d:	ff 75 0c             	pushl  0xc(%ebp)
f0103430:	ff 75 08             	pushl  0x8(%ebp)
f0103433:	e8 87 ff ff ff       	call   f01033bf <memmove>
}
f0103438:	c9                   	leave  
f0103439:	c3                   	ret    

f010343a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010343a:	55                   	push   %ebp
f010343b:	89 e5                	mov    %esp,%ebp
f010343d:	56                   	push   %esi
f010343e:	53                   	push   %ebx
f010343f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103442:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103445:	89 c6                	mov    %eax,%esi
f0103447:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010344a:	eb 1a                	jmp    f0103466 <memcmp+0x2c>
		if (*s1 != *s2)
f010344c:	0f b6 08             	movzbl (%eax),%ecx
f010344f:	0f b6 1a             	movzbl (%edx),%ebx
f0103452:	38 d9                	cmp    %bl,%cl
f0103454:	74 0a                	je     f0103460 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0103456:	0f b6 c1             	movzbl %cl,%eax
f0103459:	0f b6 db             	movzbl %bl,%ebx
f010345c:	29 d8                	sub    %ebx,%eax
f010345e:	eb 0f                	jmp    f010346f <memcmp+0x35>
		s1++, s2++;
f0103460:	83 c0 01             	add    $0x1,%eax
f0103463:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103466:	39 f0                	cmp    %esi,%eax
f0103468:	75 e2                	jne    f010344c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010346a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010346f:	5b                   	pop    %ebx
f0103470:	5e                   	pop    %esi
f0103471:	5d                   	pop    %ebp
f0103472:	c3                   	ret    

f0103473 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103473:	55                   	push   %ebp
f0103474:	89 e5                	mov    %esp,%ebp
f0103476:	53                   	push   %ebx
f0103477:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010347a:	89 c1                	mov    %eax,%ecx
f010347c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f010347f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0103483:	eb 0a                	jmp    f010348f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103485:	0f b6 10             	movzbl (%eax),%edx
f0103488:	39 da                	cmp    %ebx,%edx
f010348a:	74 07                	je     f0103493 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010348c:	83 c0 01             	add    $0x1,%eax
f010348f:	39 c8                	cmp    %ecx,%eax
f0103491:	72 f2                	jb     f0103485 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0103493:	5b                   	pop    %ebx
f0103494:	5d                   	pop    %ebp
f0103495:	c3                   	ret    

f0103496 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103496:	55                   	push   %ebp
f0103497:	89 e5                	mov    %esp,%ebp
f0103499:	57                   	push   %edi
f010349a:	56                   	push   %esi
f010349b:	53                   	push   %ebx
f010349c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010349f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01034a2:	eb 03                	jmp    f01034a7 <strtol+0x11>
		s++;
f01034a4:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01034a7:	0f b6 01             	movzbl (%ecx),%eax
f01034aa:	3c 20                	cmp    $0x20,%al
f01034ac:	74 f6                	je     f01034a4 <strtol+0xe>
f01034ae:	3c 09                	cmp    $0x9,%al
f01034b0:	74 f2                	je     f01034a4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01034b2:	3c 2b                	cmp    $0x2b,%al
f01034b4:	75 0a                	jne    f01034c0 <strtol+0x2a>
		s++;
f01034b6:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01034b9:	bf 00 00 00 00       	mov    $0x0,%edi
f01034be:	eb 11                	jmp    f01034d1 <strtol+0x3b>
f01034c0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01034c5:	3c 2d                	cmp    $0x2d,%al
f01034c7:	75 08                	jne    f01034d1 <strtol+0x3b>
		s++, neg = 1;
f01034c9:	83 c1 01             	add    $0x1,%ecx
f01034cc:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01034d1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01034d7:	75 15                	jne    f01034ee <strtol+0x58>
f01034d9:	80 39 30             	cmpb   $0x30,(%ecx)
f01034dc:	75 10                	jne    f01034ee <strtol+0x58>
f01034de:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01034e2:	75 7c                	jne    f0103560 <strtol+0xca>
		s += 2, base = 16;
f01034e4:	83 c1 02             	add    $0x2,%ecx
f01034e7:	bb 10 00 00 00       	mov    $0x10,%ebx
f01034ec:	eb 16                	jmp    f0103504 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01034ee:	85 db                	test   %ebx,%ebx
f01034f0:	75 12                	jne    f0103504 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01034f2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01034f7:	80 39 30             	cmpb   $0x30,(%ecx)
f01034fa:	75 08                	jne    f0103504 <strtol+0x6e>
		s++, base = 8;
f01034fc:	83 c1 01             	add    $0x1,%ecx
f01034ff:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0103504:	b8 00 00 00 00       	mov    $0x0,%eax
f0103509:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010350c:	0f b6 11             	movzbl (%ecx),%edx
f010350f:	8d 72 d0             	lea    -0x30(%edx),%esi
f0103512:	89 f3                	mov    %esi,%ebx
f0103514:	80 fb 09             	cmp    $0x9,%bl
f0103517:	77 08                	ja     f0103521 <strtol+0x8b>
			dig = *s - '0';
f0103519:	0f be d2             	movsbl %dl,%edx
f010351c:	83 ea 30             	sub    $0x30,%edx
f010351f:	eb 22                	jmp    f0103543 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0103521:	8d 72 9f             	lea    -0x61(%edx),%esi
f0103524:	89 f3                	mov    %esi,%ebx
f0103526:	80 fb 19             	cmp    $0x19,%bl
f0103529:	77 08                	ja     f0103533 <strtol+0x9d>
			dig = *s - 'a' + 10;
f010352b:	0f be d2             	movsbl %dl,%edx
f010352e:	83 ea 57             	sub    $0x57,%edx
f0103531:	eb 10                	jmp    f0103543 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0103533:	8d 72 bf             	lea    -0x41(%edx),%esi
f0103536:	89 f3                	mov    %esi,%ebx
f0103538:	80 fb 19             	cmp    $0x19,%bl
f010353b:	77 16                	ja     f0103553 <strtol+0xbd>
			dig = *s - 'A' + 10;
f010353d:	0f be d2             	movsbl %dl,%edx
f0103540:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0103543:	3b 55 10             	cmp    0x10(%ebp),%edx
f0103546:	7d 0b                	jge    f0103553 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0103548:	83 c1 01             	add    $0x1,%ecx
f010354b:	0f af 45 10          	imul   0x10(%ebp),%eax
f010354f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0103551:	eb b9                	jmp    f010350c <strtol+0x76>

	if (endptr)
f0103553:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103557:	74 0d                	je     f0103566 <strtol+0xd0>
		*endptr = (char *) s;
f0103559:	8b 75 0c             	mov    0xc(%ebp),%esi
f010355c:	89 0e                	mov    %ecx,(%esi)
f010355e:	eb 06                	jmp    f0103566 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103560:	85 db                	test   %ebx,%ebx
f0103562:	74 98                	je     f01034fc <strtol+0x66>
f0103564:	eb 9e                	jmp    f0103504 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0103566:	89 c2                	mov    %eax,%edx
f0103568:	f7 da                	neg    %edx
f010356a:	85 ff                	test   %edi,%edi
f010356c:	0f 45 c2             	cmovne %edx,%eax
}
f010356f:	5b                   	pop    %ebx
f0103570:	5e                   	pop    %esi
f0103571:	5f                   	pop    %edi
f0103572:	5d                   	pop    %ebp
f0103573:	c3                   	ret    
f0103574:	66 90                	xchg   %ax,%ax
f0103576:	66 90                	xchg   %ax,%ax
f0103578:	66 90                	xchg   %ax,%ax
f010357a:	66 90                	xchg   %ax,%ax
f010357c:	66 90                	xchg   %ax,%ax
f010357e:	66 90                	xchg   %ax,%ax

f0103580 <__udivdi3>:
f0103580:	55                   	push   %ebp
f0103581:	57                   	push   %edi
f0103582:	56                   	push   %esi
f0103583:	53                   	push   %ebx
f0103584:	83 ec 1c             	sub    $0x1c,%esp
f0103587:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010358b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010358f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0103593:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0103597:	85 f6                	test   %esi,%esi
f0103599:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010359d:	89 ca                	mov    %ecx,%edx
f010359f:	89 f8                	mov    %edi,%eax
f01035a1:	75 3d                	jne    f01035e0 <__udivdi3+0x60>
f01035a3:	39 cf                	cmp    %ecx,%edi
f01035a5:	0f 87 c5 00 00 00    	ja     f0103670 <__udivdi3+0xf0>
f01035ab:	85 ff                	test   %edi,%edi
f01035ad:	89 fd                	mov    %edi,%ebp
f01035af:	75 0b                	jne    f01035bc <__udivdi3+0x3c>
f01035b1:	b8 01 00 00 00       	mov    $0x1,%eax
f01035b6:	31 d2                	xor    %edx,%edx
f01035b8:	f7 f7                	div    %edi
f01035ba:	89 c5                	mov    %eax,%ebp
f01035bc:	89 c8                	mov    %ecx,%eax
f01035be:	31 d2                	xor    %edx,%edx
f01035c0:	f7 f5                	div    %ebp
f01035c2:	89 c1                	mov    %eax,%ecx
f01035c4:	89 d8                	mov    %ebx,%eax
f01035c6:	89 cf                	mov    %ecx,%edi
f01035c8:	f7 f5                	div    %ebp
f01035ca:	89 c3                	mov    %eax,%ebx
f01035cc:	89 d8                	mov    %ebx,%eax
f01035ce:	89 fa                	mov    %edi,%edx
f01035d0:	83 c4 1c             	add    $0x1c,%esp
f01035d3:	5b                   	pop    %ebx
f01035d4:	5e                   	pop    %esi
f01035d5:	5f                   	pop    %edi
f01035d6:	5d                   	pop    %ebp
f01035d7:	c3                   	ret    
f01035d8:	90                   	nop
f01035d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01035e0:	39 ce                	cmp    %ecx,%esi
f01035e2:	77 74                	ja     f0103658 <__udivdi3+0xd8>
f01035e4:	0f bd fe             	bsr    %esi,%edi
f01035e7:	83 f7 1f             	xor    $0x1f,%edi
f01035ea:	0f 84 98 00 00 00    	je     f0103688 <__udivdi3+0x108>
f01035f0:	bb 20 00 00 00       	mov    $0x20,%ebx
f01035f5:	89 f9                	mov    %edi,%ecx
f01035f7:	89 c5                	mov    %eax,%ebp
f01035f9:	29 fb                	sub    %edi,%ebx
f01035fb:	d3 e6                	shl    %cl,%esi
f01035fd:	89 d9                	mov    %ebx,%ecx
f01035ff:	d3 ed                	shr    %cl,%ebp
f0103601:	89 f9                	mov    %edi,%ecx
f0103603:	d3 e0                	shl    %cl,%eax
f0103605:	09 ee                	or     %ebp,%esi
f0103607:	89 d9                	mov    %ebx,%ecx
f0103609:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010360d:	89 d5                	mov    %edx,%ebp
f010360f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0103613:	d3 ed                	shr    %cl,%ebp
f0103615:	89 f9                	mov    %edi,%ecx
f0103617:	d3 e2                	shl    %cl,%edx
f0103619:	89 d9                	mov    %ebx,%ecx
f010361b:	d3 e8                	shr    %cl,%eax
f010361d:	09 c2                	or     %eax,%edx
f010361f:	89 d0                	mov    %edx,%eax
f0103621:	89 ea                	mov    %ebp,%edx
f0103623:	f7 f6                	div    %esi
f0103625:	89 d5                	mov    %edx,%ebp
f0103627:	89 c3                	mov    %eax,%ebx
f0103629:	f7 64 24 0c          	mull   0xc(%esp)
f010362d:	39 d5                	cmp    %edx,%ebp
f010362f:	72 10                	jb     f0103641 <__udivdi3+0xc1>
f0103631:	8b 74 24 08          	mov    0x8(%esp),%esi
f0103635:	89 f9                	mov    %edi,%ecx
f0103637:	d3 e6                	shl    %cl,%esi
f0103639:	39 c6                	cmp    %eax,%esi
f010363b:	73 07                	jae    f0103644 <__udivdi3+0xc4>
f010363d:	39 d5                	cmp    %edx,%ebp
f010363f:	75 03                	jne    f0103644 <__udivdi3+0xc4>
f0103641:	83 eb 01             	sub    $0x1,%ebx
f0103644:	31 ff                	xor    %edi,%edi
f0103646:	89 d8                	mov    %ebx,%eax
f0103648:	89 fa                	mov    %edi,%edx
f010364a:	83 c4 1c             	add    $0x1c,%esp
f010364d:	5b                   	pop    %ebx
f010364e:	5e                   	pop    %esi
f010364f:	5f                   	pop    %edi
f0103650:	5d                   	pop    %ebp
f0103651:	c3                   	ret    
f0103652:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103658:	31 ff                	xor    %edi,%edi
f010365a:	31 db                	xor    %ebx,%ebx
f010365c:	89 d8                	mov    %ebx,%eax
f010365e:	89 fa                	mov    %edi,%edx
f0103660:	83 c4 1c             	add    $0x1c,%esp
f0103663:	5b                   	pop    %ebx
f0103664:	5e                   	pop    %esi
f0103665:	5f                   	pop    %edi
f0103666:	5d                   	pop    %ebp
f0103667:	c3                   	ret    
f0103668:	90                   	nop
f0103669:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103670:	89 d8                	mov    %ebx,%eax
f0103672:	f7 f7                	div    %edi
f0103674:	31 ff                	xor    %edi,%edi
f0103676:	89 c3                	mov    %eax,%ebx
f0103678:	89 d8                	mov    %ebx,%eax
f010367a:	89 fa                	mov    %edi,%edx
f010367c:	83 c4 1c             	add    $0x1c,%esp
f010367f:	5b                   	pop    %ebx
f0103680:	5e                   	pop    %esi
f0103681:	5f                   	pop    %edi
f0103682:	5d                   	pop    %ebp
f0103683:	c3                   	ret    
f0103684:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103688:	39 ce                	cmp    %ecx,%esi
f010368a:	72 0c                	jb     f0103698 <__udivdi3+0x118>
f010368c:	31 db                	xor    %ebx,%ebx
f010368e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0103692:	0f 87 34 ff ff ff    	ja     f01035cc <__udivdi3+0x4c>
f0103698:	bb 01 00 00 00       	mov    $0x1,%ebx
f010369d:	e9 2a ff ff ff       	jmp    f01035cc <__udivdi3+0x4c>
f01036a2:	66 90                	xchg   %ax,%ax
f01036a4:	66 90                	xchg   %ax,%ax
f01036a6:	66 90                	xchg   %ax,%ax
f01036a8:	66 90                	xchg   %ax,%ax
f01036aa:	66 90                	xchg   %ax,%ax
f01036ac:	66 90                	xchg   %ax,%ax
f01036ae:	66 90                	xchg   %ax,%ax

f01036b0 <__umoddi3>:
f01036b0:	55                   	push   %ebp
f01036b1:	57                   	push   %edi
f01036b2:	56                   	push   %esi
f01036b3:	53                   	push   %ebx
f01036b4:	83 ec 1c             	sub    $0x1c,%esp
f01036b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01036bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f01036bf:	8b 74 24 34          	mov    0x34(%esp),%esi
f01036c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01036c7:	85 d2                	test   %edx,%edx
f01036c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01036cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01036d1:	89 f3                	mov    %esi,%ebx
f01036d3:	89 3c 24             	mov    %edi,(%esp)
f01036d6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01036da:	75 1c                	jne    f01036f8 <__umoddi3+0x48>
f01036dc:	39 f7                	cmp    %esi,%edi
f01036de:	76 50                	jbe    f0103730 <__umoddi3+0x80>
f01036e0:	89 c8                	mov    %ecx,%eax
f01036e2:	89 f2                	mov    %esi,%edx
f01036e4:	f7 f7                	div    %edi
f01036e6:	89 d0                	mov    %edx,%eax
f01036e8:	31 d2                	xor    %edx,%edx
f01036ea:	83 c4 1c             	add    $0x1c,%esp
f01036ed:	5b                   	pop    %ebx
f01036ee:	5e                   	pop    %esi
f01036ef:	5f                   	pop    %edi
f01036f0:	5d                   	pop    %ebp
f01036f1:	c3                   	ret    
f01036f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01036f8:	39 f2                	cmp    %esi,%edx
f01036fa:	89 d0                	mov    %edx,%eax
f01036fc:	77 52                	ja     f0103750 <__umoddi3+0xa0>
f01036fe:	0f bd ea             	bsr    %edx,%ebp
f0103701:	83 f5 1f             	xor    $0x1f,%ebp
f0103704:	75 5a                	jne    f0103760 <__umoddi3+0xb0>
f0103706:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010370a:	0f 82 e0 00 00 00    	jb     f01037f0 <__umoddi3+0x140>
f0103710:	39 0c 24             	cmp    %ecx,(%esp)
f0103713:	0f 86 d7 00 00 00    	jbe    f01037f0 <__umoddi3+0x140>
f0103719:	8b 44 24 08          	mov    0x8(%esp),%eax
f010371d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0103721:	83 c4 1c             	add    $0x1c,%esp
f0103724:	5b                   	pop    %ebx
f0103725:	5e                   	pop    %esi
f0103726:	5f                   	pop    %edi
f0103727:	5d                   	pop    %ebp
f0103728:	c3                   	ret    
f0103729:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103730:	85 ff                	test   %edi,%edi
f0103732:	89 fd                	mov    %edi,%ebp
f0103734:	75 0b                	jne    f0103741 <__umoddi3+0x91>
f0103736:	b8 01 00 00 00       	mov    $0x1,%eax
f010373b:	31 d2                	xor    %edx,%edx
f010373d:	f7 f7                	div    %edi
f010373f:	89 c5                	mov    %eax,%ebp
f0103741:	89 f0                	mov    %esi,%eax
f0103743:	31 d2                	xor    %edx,%edx
f0103745:	f7 f5                	div    %ebp
f0103747:	89 c8                	mov    %ecx,%eax
f0103749:	f7 f5                	div    %ebp
f010374b:	89 d0                	mov    %edx,%eax
f010374d:	eb 99                	jmp    f01036e8 <__umoddi3+0x38>
f010374f:	90                   	nop
f0103750:	89 c8                	mov    %ecx,%eax
f0103752:	89 f2                	mov    %esi,%edx
f0103754:	83 c4 1c             	add    $0x1c,%esp
f0103757:	5b                   	pop    %ebx
f0103758:	5e                   	pop    %esi
f0103759:	5f                   	pop    %edi
f010375a:	5d                   	pop    %ebp
f010375b:	c3                   	ret    
f010375c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103760:	8b 34 24             	mov    (%esp),%esi
f0103763:	bf 20 00 00 00       	mov    $0x20,%edi
f0103768:	89 e9                	mov    %ebp,%ecx
f010376a:	29 ef                	sub    %ebp,%edi
f010376c:	d3 e0                	shl    %cl,%eax
f010376e:	89 f9                	mov    %edi,%ecx
f0103770:	89 f2                	mov    %esi,%edx
f0103772:	d3 ea                	shr    %cl,%edx
f0103774:	89 e9                	mov    %ebp,%ecx
f0103776:	09 c2                	or     %eax,%edx
f0103778:	89 d8                	mov    %ebx,%eax
f010377a:	89 14 24             	mov    %edx,(%esp)
f010377d:	89 f2                	mov    %esi,%edx
f010377f:	d3 e2                	shl    %cl,%edx
f0103781:	89 f9                	mov    %edi,%ecx
f0103783:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103787:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010378b:	d3 e8                	shr    %cl,%eax
f010378d:	89 e9                	mov    %ebp,%ecx
f010378f:	89 c6                	mov    %eax,%esi
f0103791:	d3 e3                	shl    %cl,%ebx
f0103793:	89 f9                	mov    %edi,%ecx
f0103795:	89 d0                	mov    %edx,%eax
f0103797:	d3 e8                	shr    %cl,%eax
f0103799:	89 e9                	mov    %ebp,%ecx
f010379b:	09 d8                	or     %ebx,%eax
f010379d:	89 d3                	mov    %edx,%ebx
f010379f:	89 f2                	mov    %esi,%edx
f01037a1:	f7 34 24             	divl   (%esp)
f01037a4:	89 d6                	mov    %edx,%esi
f01037a6:	d3 e3                	shl    %cl,%ebx
f01037a8:	f7 64 24 04          	mull   0x4(%esp)
f01037ac:	39 d6                	cmp    %edx,%esi
f01037ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01037b2:	89 d1                	mov    %edx,%ecx
f01037b4:	89 c3                	mov    %eax,%ebx
f01037b6:	72 08                	jb     f01037c0 <__umoddi3+0x110>
f01037b8:	75 11                	jne    f01037cb <__umoddi3+0x11b>
f01037ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01037be:	73 0b                	jae    f01037cb <__umoddi3+0x11b>
f01037c0:	2b 44 24 04          	sub    0x4(%esp),%eax
f01037c4:	1b 14 24             	sbb    (%esp),%edx
f01037c7:	89 d1                	mov    %edx,%ecx
f01037c9:	89 c3                	mov    %eax,%ebx
f01037cb:	8b 54 24 08          	mov    0x8(%esp),%edx
f01037cf:	29 da                	sub    %ebx,%edx
f01037d1:	19 ce                	sbb    %ecx,%esi
f01037d3:	89 f9                	mov    %edi,%ecx
f01037d5:	89 f0                	mov    %esi,%eax
f01037d7:	d3 e0                	shl    %cl,%eax
f01037d9:	89 e9                	mov    %ebp,%ecx
f01037db:	d3 ea                	shr    %cl,%edx
f01037dd:	89 e9                	mov    %ebp,%ecx
f01037df:	d3 ee                	shr    %cl,%esi
f01037e1:	09 d0                	or     %edx,%eax
f01037e3:	89 f2                	mov    %esi,%edx
f01037e5:	83 c4 1c             	add    $0x1c,%esp
f01037e8:	5b                   	pop    %ebx
f01037e9:	5e                   	pop    %esi
f01037ea:	5f                   	pop    %edi
f01037eb:	5d                   	pop    %ebp
f01037ec:	c3                   	ret    
f01037ed:	8d 76 00             	lea    0x0(%esi),%esi
f01037f0:	29 f9                	sub    %edi,%ecx
f01037f2:	19 d6                	sbb    %edx,%esi
f01037f4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01037f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01037fc:	e9 18 ff ff ff       	jmp    f0103719 <__umoddi3+0x69>
