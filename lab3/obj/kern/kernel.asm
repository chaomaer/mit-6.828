
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
f0100015:	b8 00 90 11 00       	mov    $0x119000,%eax
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
f0100034:	bc 00 90 11 f0       	mov    $0xf0119000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 58 00 00 00       	call   f0100096 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/env.h>
#include <kern/trap.h>

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
f010004b:	68 00 49 10 f0       	push   $0xf0104900
f0100050:	e8 98 30 00 00       	call   f01030ed <cprintf>
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
		mon_backtrace(0, 0, 0);
f010006d:	83 ec 04             	sub    $0x4,%esp
f0100070:	6a 00                	push   $0x0
f0100072:	6a 00                	push   $0x0
f0100074:	6a 00                	push   $0x0
f0100076:	e8 d7 07 00 00       	call   f0100852 <mon_backtrace>
f010007b:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007e:	83 ec 08             	sub    $0x8,%esp
f0100081:	53                   	push   %ebx
f0100082:	68 1c 49 10 f0       	push   $0xf010491c
f0100087:	e8 61 30 00 00       	call   f01030ed <cprintf>
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
f010009c:	b8 50 2c 17 f0       	mov    $0xf0172c50,%eax
f01000a1:	2d 26 1d 17 f0       	sub    $0xf0171d26,%eax
f01000a6:	50                   	push   %eax
f01000a7:	6a 00                	push   $0x0
f01000a9:	68 26 1d 17 f0       	push   $0xf0171d26
f01000ae:	e8 b3 43 00 00       	call   f0104466 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b3:	e8 ab 04 00 00       	call   f0100563 <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b8:	83 c4 08             	add    $0x8,%esp
f01000bb:	68 ac 1a 00 00       	push   $0x1aac
f01000c0:	68 37 49 10 f0       	push   $0xf0104937
f01000c5:	e8 23 30 00 00       	call   f01030ed <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000ca:	e8 3c 11 00 00       	call   f010120b <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000cf:	e8 68 2a 00 00       	call   f0102b3c <env_init>
	trap_init();
f01000d4:	e8 85 30 00 00       	call   f010315e <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01000d9:	83 c4 08             	add    $0x8,%esp
f01000dc:	6a 00                	push   $0x0
f01000de:	68 c6 fb 12 f0       	push   $0xf012fbc6
f01000e3:	e8 1a 2c 00 00       	call   f0102d02 <env_create>
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000e8:	83 c4 04             	add    $0x4,%esp
f01000eb:	ff 35 8c 1f 17 f0    	pushl  0xf0171f8c
f01000f1:	e8 30 2f 00 00       	call   f0103026 <env_run>

f01000f6 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000f6:	55                   	push   %ebp
f01000f7:	89 e5                	mov    %esp,%ebp
f01000f9:	56                   	push   %esi
f01000fa:	53                   	push   %ebx
f01000fb:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000fe:	83 3d 40 2c 17 f0 00 	cmpl   $0x0,0xf0172c40
f0100105:	75 37                	jne    f010013e <_panic+0x48>
		goto dead;
	panicstr = fmt;
f0100107:	89 35 40 2c 17 f0    	mov    %esi,0xf0172c40

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f010010d:	fa                   	cli    
f010010e:	fc                   	cld    

	va_start(ap, fmt);
f010010f:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100112:	83 ec 04             	sub    $0x4,%esp
f0100115:	ff 75 0c             	pushl  0xc(%ebp)
f0100118:	ff 75 08             	pushl  0x8(%ebp)
f010011b:	68 52 49 10 f0       	push   $0xf0104952
f0100120:	e8 c8 2f 00 00       	call   f01030ed <cprintf>
	vcprintf(fmt, ap);
f0100125:	83 c4 08             	add    $0x8,%esp
f0100128:	53                   	push   %ebx
f0100129:	56                   	push   %esi
f010012a:	e8 98 2f 00 00       	call   f01030c7 <vcprintf>
	cprintf("\n");
f010012f:	c7 04 24 48 5a 10 f0 	movl   $0xf0105a48,(%esp)
f0100136:	e8 b2 2f 00 00       	call   f01030ed <cprintf>
	va_end(ap);
f010013b:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010013e:	83 ec 0c             	sub    $0xc,%esp
f0100141:	6a 00                	push   $0x0
f0100143:	e8 ad 07 00 00       	call   f01008f5 <monitor>
f0100148:	83 c4 10             	add    $0x10,%esp
f010014b:	eb f1                	jmp    f010013e <_panic+0x48>

f010014d <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010014d:	55                   	push   %ebp
f010014e:	89 e5                	mov    %esp,%ebp
f0100150:	53                   	push   %ebx
f0100151:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100154:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100157:	ff 75 0c             	pushl  0xc(%ebp)
f010015a:	ff 75 08             	pushl  0x8(%ebp)
f010015d:	68 6a 49 10 f0       	push   $0xf010496a
f0100162:	e8 86 2f 00 00       	call   f01030ed <cprintf>
	vcprintf(fmt, ap);
f0100167:	83 c4 08             	add    $0x8,%esp
f010016a:	53                   	push   %ebx
f010016b:	ff 75 10             	pushl  0x10(%ebp)
f010016e:	e8 54 2f 00 00       	call   f01030c7 <vcprintf>
	cprintf("\n");
f0100173:	c7 04 24 48 5a 10 f0 	movl   $0xf0105a48,(%esp)
f010017a:	e8 6e 2f 00 00       	call   f01030ed <cprintf>
	va_end(ap);
}
f010017f:	83 c4 10             	add    $0x10,%esp
f0100182:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100185:	c9                   	leave  
f0100186:	c3                   	ret    

f0100187 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100187:	55                   	push   %ebp
f0100188:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010018a:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010018f:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100190:	a8 01                	test   $0x1,%al
f0100192:	74 0b                	je     f010019f <serial_proc_data+0x18>
f0100194:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100199:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010019a:	0f b6 c0             	movzbl %al,%eax
f010019d:	eb 05                	jmp    f01001a4 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010019f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01001a4:	5d                   	pop    %ebp
f01001a5:	c3                   	ret    

f01001a6 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001a6:	55                   	push   %ebp
f01001a7:	89 e5                	mov    %esp,%ebp
f01001a9:	53                   	push   %ebx
f01001aa:	83 ec 04             	sub    $0x4,%esp
f01001ad:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01001af:	eb 2b                	jmp    f01001dc <cons_intr+0x36>
		if (c == 0)
f01001b1:	85 c0                	test   %eax,%eax
f01001b3:	74 27                	je     f01001dc <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01001b5:	8b 0d 64 1f 17 f0    	mov    0xf0171f64,%ecx
f01001bb:	8d 51 01             	lea    0x1(%ecx),%edx
f01001be:	89 15 64 1f 17 f0    	mov    %edx,0xf0171f64
f01001c4:	88 81 60 1d 17 f0    	mov    %al,-0xfe8e2a0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01001ca:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001d0:	75 0a                	jne    f01001dc <cons_intr+0x36>
			cons.wpos = 0;
f01001d2:	c7 05 64 1f 17 f0 00 	movl   $0x0,0xf0171f64
f01001d9:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001dc:	ff d3                	call   *%ebx
f01001de:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001e1:	75 ce                	jne    f01001b1 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001e3:	83 c4 04             	add    $0x4,%esp
f01001e6:	5b                   	pop    %ebx
f01001e7:	5d                   	pop    %ebp
f01001e8:	c3                   	ret    

f01001e9 <kbd_proc_data>:
f01001e9:	ba 64 00 00 00       	mov    $0x64,%edx
f01001ee:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f01001ef:	a8 01                	test   $0x1,%al
f01001f1:	0f 84 f8 00 00 00    	je     f01002ef <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01001f7:	a8 20                	test   $0x20,%al
f01001f9:	0f 85 f6 00 00 00    	jne    f01002f5 <kbd_proc_data+0x10c>
f01001ff:	ba 60 00 00 00       	mov    $0x60,%edx
f0100204:	ec                   	in     (%dx),%al
f0100205:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100207:	3c e0                	cmp    $0xe0,%al
f0100209:	75 0d                	jne    f0100218 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f010020b:	83 0d 40 1d 17 f0 40 	orl    $0x40,0xf0171d40
		return 0;
f0100212:	b8 00 00 00 00       	mov    $0x0,%eax
f0100217:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100218:	55                   	push   %ebp
f0100219:	89 e5                	mov    %esp,%ebp
f010021b:	53                   	push   %ebx
f010021c:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f010021f:	84 c0                	test   %al,%al
f0100221:	79 36                	jns    f0100259 <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100223:	8b 0d 40 1d 17 f0    	mov    0xf0171d40,%ecx
f0100229:	89 cb                	mov    %ecx,%ebx
f010022b:	83 e3 40             	and    $0x40,%ebx
f010022e:	83 e0 7f             	and    $0x7f,%eax
f0100231:	85 db                	test   %ebx,%ebx
f0100233:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100236:	0f b6 d2             	movzbl %dl,%edx
f0100239:	0f b6 82 e0 4a 10 f0 	movzbl -0xfefb520(%edx),%eax
f0100240:	83 c8 40             	or     $0x40,%eax
f0100243:	0f b6 c0             	movzbl %al,%eax
f0100246:	f7 d0                	not    %eax
f0100248:	21 c8                	and    %ecx,%eax
f010024a:	a3 40 1d 17 f0       	mov    %eax,0xf0171d40
		return 0;
f010024f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100254:	e9 a4 00 00 00       	jmp    f01002fd <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f0100259:	8b 0d 40 1d 17 f0    	mov    0xf0171d40,%ecx
f010025f:	f6 c1 40             	test   $0x40,%cl
f0100262:	74 0e                	je     f0100272 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100264:	83 c8 80             	or     $0xffffff80,%eax
f0100267:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100269:	83 e1 bf             	and    $0xffffffbf,%ecx
f010026c:	89 0d 40 1d 17 f0    	mov    %ecx,0xf0171d40
	}

	shift |= shiftcode[data];
f0100272:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100275:	0f b6 82 e0 4a 10 f0 	movzbl -0xfefb520(%edx),%eax
f010027c:	0b 05 40 1d 17 f0    	or     0xf0171d40,%eax
f0100282:	0f b6 8a e0 49 10 f0 	movzbl -0xfefb620(%edx),%ecx
f0100289:	31 c8                	xor    %ecx,%eax
f010028b:	a3 40 1d 17 f0       	mov    %eax,0xf0171d40

	c = charcode[shift & (CTL | SHIFT)][data];
f0100290:	89 c1                	mov    %eax,%ecx
f0100292:	83 e1 03             	and    $0x3,%ecx
f0100295:	8b 0c 8d c0 49 10 f0 	mov    -0xfefb640(,%ecx,4),%ecx
f010029c:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002a0:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01002a3:	a8 08                	test   $0x8,%al
f01002a5:	74 1b                	je     f01002c2 <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f01002a7:	89 da                	mov    %ebx,%edx
f01002a9:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01002ac:	83 f9 19             	cmp    $0x19,%ecx
f01002af:	77 05                	ja     f01002b6 <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f01002b1:	83 eb 20             	sub    $0x20,%ebx
f01002b4:	eb 0c                	jmp    f01002c2 <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f01002b6:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002b9:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01002bc:	83 fa 19             	cmp    $0x19,%edx
f01002bf:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002c2:	f7 d0                	not    %eax
f01002c4:	a8 06                	test   $0x6,%al
f01002c6:	75 33                	jne    f01002fb <kbd_proc_data+0x112>
f01002c8:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002ce:	75 2b                	jne    f01002fb <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f01002d0:	83 ec 0c             	sub    $0xc,%esp
f01002d3:	68 84 49 10 f0       	push   $0xf0104984
f01002d8:	e8 10 2e 00 00       	call   f01030ed <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002dd:	ba 92 00 00 00       	mov    $0x92,%edx
f01002e2:	b8 03 00 00 00       	mov    $0x3,%eax
f01002e7:	ee                   	out    %al,(%dx)
f01002e8:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002eb:	89 d8                	mov    %ebx,%eax
f01002ed:	eb 0e                	jmp    f01002fd <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f01002ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01002f4:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01002f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002fa:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002fb:	89 d8                	mov    %ebx,%eax
}
f01002fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100300:	c9                   	leave  
f0100301:	c3                   	ret    

f0100302 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100302:	55                   	push   %ebp
f0100303:	89 e5                	mov    %esp,%ebp
f0100305:	57                   	push   %edi
f0100306:	56                   	push   %esi
f0100307:	53                   	push   %ebx
f0100308:	83 ec 1c             	sub    $0x1c,%esp
f010030b:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010030d:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100312:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100317:	b9 84 00 00 00       	mov    $0x84,%ecx
f010031c:	eb 09                	jmp    f0100327 <cons_putc+0x25>
f010031e:	89 ca                	mov    %ecx,%edx
f0100320:	ec                   	in     (%dx),%al
f0100321:	ec                   	in     (%dx),%al
f0100322:	ec                   	in     (%dx),%al
f0100323:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100324:	83 c3 01             	add    $0x1,%ebx
f0100327:	89 f2                	mov    %esi,%edx
f0100329:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010032a:	a8 20                	test   $0x20,%al
f010032c:	75 08                	jne    f0100336 <cons_putc+0x34>
f010032e:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100334:	7e e8                	jle    f010031e <cons_putc+0x1c>
f0100336:	89 f8                	mov    %edi,%eax
f0100338:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010033b:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100340:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100341:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100346:	be 79 03 00 00       	mov    $0x379,%esi
f010034b:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100350:	eb 09                	jmp    f010035b <cons_putc+0x59>
f0100352:	89 ca                	mov    %ecx,%edx
f0100354:	ec                   	in     (%dx),%al
f0100355:	ec                   	in     (%dx),%al
f0100356:	ec                   	in     (%dx),%al
f0100357:	ec                   	in     (%dx),%al
f0100358:	83 c3 01             	add    $0x1,%ebx
f010035b:	89 f2                	mov    %esi,%edx
f010035d:	ec                   	in     (%dx),%al
f010035e:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100364:	7f 04                	jg     f010036a <cons_putc+0x68>
f0100366:	84 c0                	test   %al,%al
f0100368:	79 e8                	jns    f0100352 <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010036a:	ba 78 03 00 00       	mov    $0x378,%edx
f010036f:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100373:	ee                   	out    %al,(%dx)
f0100374:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100379:	b8 0d 00 00 00       	mov    $0xd,%eax
f010037e:	ee                   	out    %al,(%dx)
f010037f:	b8 08 00 00 00       	mov    $0x8,%eax
f0100384:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100385:	89 fa                	mov    %edi,%edx
f0100387:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f010038d:	89 f8                	mov    %edi,%eax
f010038f:	80 cc 07             	or     $0x7,%ah
f0100392:	85 d2                	test   %edx,%edx
f0100394:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100397:	89 f8                	mov    %edi,%eax
f0100399:	0f b6 c0             	movzbl %al,%eax
f010039c:	83 f8 09             	cmp    $0x9,%eax
f010039f:	74 74                	je     f0100415 <cons_putc+0x113>
f01003a1:	83 f8 09             	cmp    $0x9,%eax
f01003a4:	7f 0a                	jg     f01003b0 <cons_putc+0xae>
f01003a6:	83 f8 08             	cmp    $0x8,%eax
f01003a9:	74 14                	je     f01003bf <cons_putc+0xbd>
f01003ab:	e9 99 00 00 00       	jmp    f0100449 <cons_putc+0x147>
f01003b0:	83 f8 0a             	cmp    $0xa,%eax
f01003b3:	74 3a                	je     f01003ef <cons_putc+0xed>
f01003b5:	83 f8 0d             	cmp    $0xd,%eax
f01003b8:	74 3d                	je     f01003f7 <cons_putc+0xf5>
f01003ba:	e9 8a 00 00 00       	jmp    f0100449 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f01003bf:	0f b7 05 68 1f 17 f0 	movzwl 0xf0171f68,%eax
f01003c6:	66 85 c0             	test   %ax,%ax
f01003c9:	0f 84 e6 00 00 00    	je     f01004b5 <cons_putc+0x1b3>
			crt_pos--;
f01003cf:	83 e8 01             	sub    $0x1,%eax
f01003d2:	66 a3 68 1f 17 f0    	mov    %ax,0xf0171f68
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003d8:	0f b7 c0             	movzwl %ax,%eax
f01003db:	66 81 e7 00 ff       	and    $0xff00,%di
f01003e0:	83 cf 20             	or     $0x20,%edi
f01003e3:	8b 15 6c 1f 17 f0    	mov    0xf0171f6c,%edx
f01003e9:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003ed:	eb 78                	jmp    f0100467 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003ef:	66 83 05 68 1f 17 f0 	addw   $0x50,0xf0171f68
f01003f6:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003f7:	0f b7 05 68 1f 17 f0 	movzwl 0xf0171f68,%eax
f01003fe:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100404:	c1 e8 16             	shr    $0x16,%eax
f0100407:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010040a:	c1 e0 04             	shl    $0x4,%eax
f010040d:	66 a3 68 1f 17 f0    	mov    %ax,0xf0171f68
f0100413:	eb 52                	jmp    f0100467 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f0100415:	b8 20 00 00 00       	mov    $0x20,%eax
f010041a:	e8 e3 fe ff ff       	call   f0100302 <cons_putc>
		cons_putc(' ');
f010041f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100424:	e8 d9 fe ff ff       	call   f0100302 <cons_putc>
		cons_putc(' ');
f0100429:	b8 20 00 00 00       	mov    $0x20,%eax
f010042e:	e8 cf fe ff ff       	call   f0100302 <cons_putc>
		cons_putc(' ');
f0100433:	b8 20 00 00 00       	mov    $0x20,%eax
f0100438:	e8 c5 fe ff ff       	call   f0100302 <cons_putc>
		cons_putc(' ');
f010043d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100442:	e8 bb fe ff ff       	call   f0100302 <cons_putc>
f0100447:	eb 1e                	jmp    f0100467 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100449:	0f b7 05 68 1f 17 f0 	movzwl 0xf0171f68,%eax
f0100450:	8d 50 01             	lea    0x1(%eax),%edx
f0100453:	66 89 15 68 1f 17 f0 	mov    %dx,0xf0171f68
f010045a:	0f b7 c0             	movzwl %ax,%eax
f010045d:	8b 15 6c 1f 17 f0    	mov    0xf0171f6c,%edx
f0100463:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100467:	66 81 3d 68 1f 17 f0 	cmpw   $0x7cf,0xf0171f68
f010046e:	cf 07 
f0100470:	76 43                	jbe    f01004b5 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100472:	a1 6c 1f 17 f0       	mov    0xf0171f6c,%eax
f0100477:	83 ec 04             	sub    $0x4,%esp
f010047a:	68 00 0f 00 00       	push   $0xf00
f010047f:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100485:	52                   	push   %edx
f0100486:	50                   	push   %eax
f0100487:	e8 27 40 00 00       	call   f01044b3 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010048c:	8b 15 6c 1f 17 f0    	mov    0xf0171f6c,%edx
f0100492:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100498:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010049e:	83 c4 10             	add    $0x10,%esp
f01004a1:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01004a6:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004a9:	39 d0                	cmp    %edx,%eax
f01004ab:	75 f4                	jne    f01004a1 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01004ad:	66 83 2d 68 1f 17 f0 	subw   $0x50,0xf0171f68
f01004b4:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004b5:	8b 0d 70 1f 17 f0    	mov    0xf0171f70,%ecx
f01004bb:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004c0:	89 ca                	mov    %ecx,%edx
f01004c2:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004c3:	0f b7 1d 68 1f 17 f0 	movzwl 0xf0171f68,%ebx
f01004ca:	8d 71 01             	lea    0x1(%ecx),%esi
f01004cd:	89 d8                	mov    %ebx,%eax
f01004cf:	66 c1 e8 08          	shr    $0x8,%ax
f01004d3:	89 f2                	mov    %esi,%edx
f01004d5:	ee                   	out    %al,(%dx)
f01004d6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004db:	89 ca                	mov    %ecx,%edx
f01004dd:	ee                   	out    %al,(%dx)
f01004de:	89 d8                	mov    %ebx,%eax
f01004e0:	89 f2                	mov    %esi,%edx
f01004e2:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004e6:	5b                   	pop    %ebx
f01004e7:	5e                   	pop    %esi
f01004e8:	5f                   	pop    %edi
f01004e9:	5d                   	pop    %ebp
f01004ea:	c3                   	ret    

f01004eb <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004eb:	80 3d 74 1f 17 f0 00 	cmpb   $0x0,0xf0171f74
f01004f2:	74 11                	je     f0100505 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004f4:	55                   	push   %ebp
f01004f5:	89 e5                	mov    %esp,%ebp
f01004f7:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004fa:	b8 87 01 10 f0       	mov    $0xf0100187,%eax
f01004ff:	e8 a2 fc ff ff       	call   f01001a6 <cons_intr>
}
f0100504:	c9                   	leave  
f0100505:	f3 c3                	repz ret 

f0100507 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100507:	55                   	push   %ebp
f0100508:	89 e5                	mov    %esp,%ebp
f010050a:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f010050d:	b8 e9 01 10 f0       	mov    $0xf01001e9,%eax
f0100512:	e8 8f fc ff ff       	call   f01001a6 <cons_intr>
}
f0100517:	c9                   	leave  
f0100518:	c3                   	ret    

f0100519 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100519:	55                   	push   %ebp
f010051a:	89 e5                	mov    %esp,%ebp
f010051c:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010051f:	e8 c7 ff ff ff       	call   f01004eb <serial_intr>
	kbd_intr();
f0100524:	e8 de ff ff ff       	call   f0100507 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100529:	a1 60 1f 17 f0       	mov    0xf0171f60,%eax
f010052e:	3b 05 64 1f 17 f0    	cmp    0xf0171f64,%eax
f0100534:	74 26                	je     f010055c <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100536:	8d 50 01             	lea    0x1(%eax),%edx
f0100539:	89 15 60 1f 17 f0    	mov    %edx,0xf0171f60
f010053f:	0f b6 88 60 1d 17 f0 	movzbl -0xfe8e2a0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100546:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100548:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010054e:	75 11                	jne    f0100561 <cons_getc+0x48>
			cons.rpos = 0;
f0100550:	c7 05 60 1f 17 f0 00 	movl   $0x0,0xf0171f60
f0100557:	00 00 00 
f010055a:	eb 05                	jmp    f0100561 <cons_getc+0x48>
		return c;
	}
	return 0;
f010055c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100561:	c9                   	leave  
f0100562:	c3                   	ret    

f0100563 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100563:	55                   	push   %ebp
f0100564:	89 e5                	mov    %esp,%ebp
f0100566:	57                   	push   %edi
f0100567:	56                   	push   %esi
f0100568:	53                   	push   %ebx
f0100569:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010056c:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100573:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010057a:	5a a5 
	if (*cp != 0xA55A) {
f010057c:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100583:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100587:	74 11                	je     f010059a <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100589:	c7 05 70 1f 17 f0 b4 	movl   $0x3b4,0xf0171f70
f0100590:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100593:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100598:	eb 16                	jmp    f01005b0 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010059a:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01005a1:	c7 05 70 1f 17 f0 d4 	movl   $0x3d4,0xf0171f70
f01005a8:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01005ab:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01005b0:	8b 3d 70 1f 17 f0    	mov    0xf0171f70,%edi
f01005b6:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005bb:	89 fa                	mov    %edi,%edx
f01005bd:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005be:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005c1:	89 da                	mov    %ebx,%edx
f01005c3:	ec                   	in     (%dx),%al
f01005c4:	0f b6 c8             	movzbl %al,%ecx
f01005c7:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005ca:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005cf:	89 fa                	mov    %edi,%edx
f01005d1:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005d2:	89 da                	mov    %ebx,%edx
f01005d4:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005d5:	89 35 6c 1f 17 f0    	mov    %esi,0xf0171f6c
	crt_pos = pos;
f01005db:	0f b6 c0             	movzbl %al,%eax
f01005de:	09 c8                	or     %ecx,%eax
f01005e0:	66 a3 68 1f 17 f0    	mov    %ax,0xf0171f68
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005e6:	be fa 03 00 00       	mov    $0x3fa,%esi
f01005eb:	b8 00 00 00 00       	mov    $0x0,%eax
f01005f0:	89 f2                	mov    %esi,%edx
f01005f2:	ee                   	out    %al,(%dx)
f01005f3:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005f8:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005fd:	ee                   	out    %al,(%dx)
f01005fe:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100603:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100608:	89 da                	mov    %ebx,%edx
f010060a:	ee                   	out    %al,(%dx)
f010060b:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100610:	b8 00 00 00 00       	mov    $0x0,%eax
f0100615:	ee                   	out    %al,(%dx)
f0100616:	ba fb 03 00 00       	mov    $0x3fb,%edx
f010061b:	b8 03 00 00 00       	mov    $0x3,%eax
f0100620:	ee                   	out    %al,(%dx)
f0100621:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100626:	b8 00 00 00 00       	mov    $0x0,%eax
f010062b:	ee                   	out    %al,(%dx)
f010062c:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100631:	b8 01 00 00 00       	mov    $0x1,%eax
f0100636:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100637:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010063c:	ec                   	in     (%dx),%al
f010063d:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010063f:	3c ff                	cmp    $0xff,%al
f0100641:	0f 95 05 74 1f 17 f0 	setne  0xf0171f74
f0100648:	89 f2                	mov    %esi,%edx
f010064a:	ec                   	in     (%dx),%al
f010064b:	89 da                	mov    %ebx,%edx
f010064d:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010064e:	80 f9 ff             	cmp    $0xff,%cl
f0100651:	75 10                	jne    f0100663 <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f0100653:	83 ec 0c             	sub    $0xc,%esp
f0100656:	68 90 49 10 f0       	push   $0xf0104990
f010065b:	e8 8d 2a 00 00       	call   f01030ed <cprintf>
f0100660:	83 c4 10             	add    $0x10,%esp
}
f0100663:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100666:	5b                   	pop    %ebx
f0100667:	5e                   	pop    %esi
f0100668:	5f                   	pop    %edi
f0100669:	5d                   	pop    %ebp
f010066a:	c3                   	ret    

f010066b <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010066b:	55                   	push   %ebp
f010066c:	89 e5                	mov    %esp,%ebp
f010066e:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100671:	8b 45 08             	mov    0x8(%ebp),%eax
f0100674:	e8 89 fc ff ff       	call   f0100302 <cons_putc>
}
f0100679:	c9                   	leave  
f010067a:	c3                   	ret    

f010067b <getchar>:

int
getchar(void)
{
f010067b:	55                   	push   %ebp
f010067c:	89 e5                	mov    %esp,%ebp
f010067e:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100681:	e8 93 fe ff ff       	call   f0100519 <cons_getc>
f0100686:	85 c0                	test   %eax,%eax
f0100688:	74 f7                	je     f0100681 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010068a:	c9                   	leave  
f010068b:	c3                   	ret    

f010068c <iscons>:

int
iscons(int fdnum)
{
f010068c:	55                   	push   %ebp
f010068d:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010068f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100694:	5d                   	pop    %ebp
f0100695:	c3                   	ret    

f0100696 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100696:	55                   	push   %ebp
f0100697:	89 e5                	mov    %esp,%ebp
f0100699:	56                   	push   %esi
f010069a:	53                   	push   %ebx
f010069b:	bb 00 4f 10 f0       	mov    $0xf0104f00,%ebx
f01006a0:	be 30 4f 10 f0       	mov    $0xf0104f30,%esi
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01006a5:	83 ec 04             	sub    $0x4,%esp
f01006a8:	ff 73 04             	pushl  0x4(%ebx)
f01006ab:	ff 33                	pushl  (%ebx)
f01006ad:	68 e0 4b 10 f0       	push   $0xf0104be0
f01006b2:	e8 36 2a 00 00       	call   f01030ed <cprintf>
f01006b7:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
f01006ba:	83 c4 10             	add    $0x10,%esp
f01006bd:	39 f3                	cmp    %esi,%ebx
f01006bf:	75 e4                	jne    f01006a5 <mon_help+0xf>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01006c1:	b8 00 00 00 00       	mov    $0x0,%eax
f01006c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01006c9:	5b                   	pop    %ebx
f01006ca:	5e                   	pop    %esi
f01006cb:	5d                   	pop    %ebp
f01006cc:	c3                   	ret    

f01006cd <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006cd:	55                   	push   %ebp
f01006ce:	89 e5                	mov    %esp,%ebp
f01006d0:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006d3:	68 e9 4b 10 f0       	push   $0xf0104be9
f01006d8:	e8 10 2a 00 00       	call   f01030ed <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006dd:	83 c4 08             	add    $0x8,%esp
f01006e0:	68 0c 00 10 00       	push   $0x10000c
f01006e5:	68 dc 4c 10 f0       	push   $0xf0104cdc
f01006ea:	e8 fe 29 00 00       	call   f01030ed <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006ef:	83 c4 0c             	add    $0xc,%esp
f01006f2:	68 0c 00 10 00       	push   $0x10000c
f01006f7:	68 0c 00 10 f0       	push   $0xf010000c
f01006fc:	68 04 4d 10 f0       	push   $0xf0104d04
f0100701:	e8 e7 29 00 00       	call   f01030ed <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100706:	83 c4 0c             	add    $0xc,%esp
f0100709:	68 f1 48 10 00       	push   $0x1048f1
f010070e:	68 f1 48 10 f0       	push   $0xf01048f1
f0100713:	68 28 4d 10 f0       	push   $0xf0104d28
f0100718:	e8 d0 29 00 00       	call   f01030ed <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010071d:	83 c4 0c             	add    $0xc,%esp
f0100720:	68 26 1d 17 00       	push   $0x171d26
f0100725:	68 26 1d 17 f0       	push   $0xf0171d26
f010072a:	68 4c 4d 10 f0       	push   $0xf0104d4c
f010072f:	e8 b9 29 00 00       	call   f01030ed <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100734:	83 c4 0c             	add    $0xc,%esp
f0100737:	68 50 2c 17 00       	push   $0x172c50
f010073c:	68 50 2c 17 f0       	push   $0xf0172c50
f0100741:	68 70 4d 10 f0       	push   $0xf0104d70
f0100746:	e8 a2 29 00 00       	call   f01030ed <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010074b:	b8 4f 30 17 f0       	mov    $0xf017304f,%eax
f0100750:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100755:	83 c4 08             	add    $0x8,%esp
f0100758:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f010075d:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100763:	85 c0                	test   %eax,%eax
f0100765:	0f 48 c2             	cmovs  %edx,%eax
f0100768:	c1 f8 0a             	sar    $0xa,%eax
f010076b:	50                   	push   %eax
f010076c:	68 94 4d 10 f0       	push   $0xf0104d94
f0100771:	e8 77 29 00 00       	call   f01030ed <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100776:	b8 00 00 00 00       	mov    $0x0,%eax
f010077b:	c9                   	leave  
f010077c:	c3                   	ret    

f010077d <showmappings>:
int
showmappings(int argc, char **argv, struct Trapframe *tf)
{
f010077d:	55                   	push   %ebp
f010077e:	89 e5                	mov    %esp,%ebp
f0100780:	56                   	push   %esi
f0100781:	53                   	push   %ebx
f0100782:	8b 75 0c             	mov    0xc(%ebp),%esi
	// check arg;
	if(argc != 3){
f0100785:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100789:	74 1a                	je     f01007a5 <showmappings+0x28>
		cprintf("error: must have three args, like: showmappings addr1 addr2\n");
f010078b:	83 ec 0c             	sub    $0xc,%esp
f010078e:	68 c0 4d 10 f0       	push   $0xf0104dc0
f0100793:	e8 55 29 00 00       	call   f01030ed <cprintf>
        return -1;
f0100798:	83 c4 10             	add    $0x10,%esp
f010079b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01007a0:	e9 a6 00 00 00       	jmp    f010084b <showmappings+0xce>
	}

	int start = strtol(argv[1], 0, 16);
f01007a5:	83 ec 04             	sub    $0x4,%esp
f01007a8:	6a 10                	push   $0x10
f01007aa:	6a 00                	push   $0x0
f01007ac:	ff 76 04             	pushl  0x4(%esi)
f01007af:	e8 d6 3d 00 00       	call   f010458a <strtol>
f01007b4:	89 c3                	mov    %eax,%ebx
	int end = strtol(argv[2], 0, 16);
f01007b6:	83 c4 0c             	add    $0xc,%esp
f01007b9:	6a 10                	push   $0x10
f01007bb:	6a 00                	push   $0x0
f01007bd:	ff 76 08             	pushl  0x8(%esi)
f01007c0:	e8 c5 3d 00 00       	call   f010458a <strtol>

	// align
	start = ROUNDDOWN(start, PGSIZE);
f01007c5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	end = ROUNDDOWN(end, PGSIZE);
f01007cb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01007d0:	89 c6                	mov    %eax,%esi

	int i = start;
	for (; i <= end; i += PGSIZE) {
f01007d2:	83 c4 10             	add    $0x10,%esp
f01007d5:	eb 6b                	jmp    f0100842 <showmappings+0xc5>
		cprintf("vaddr is %08x. ", i);
f01007d7:	83 ec 08             	sub    $0x8,%esp
f01007da:	53                   	push   %ebx
f01007db:	68 02 4c 10 f0       	push   $0xf0104c02
f01007e0:	e8 08 29 00 00       	call   f01030ed <cprintf>
		pte_t *pt_entry = 0;
		pt_entry = pgdir_walk(kern_pgdir, (void*)i, 1);
f01007e5:	83 c4 0c             	add    $0xc,%esp
f01007e8:	6a 01                	push   $0x1
f01007ea:	53                   	push   %ebx
f01007eb:	ff 35 48 2c 17 f0    	pushl  0xf0172c48
f01007f1:	e8 de 07 00 00       	call   f0100fd4 <pgdir_walk>
		if (pt_entry==NULL||!(*pt_entry&PTE_P)){
f01007f6:	83 c4 10             	add    $0x10,%esp
f01007f9:	85 c0                	test   %eax,%eax
f01007fb:	74 09                	je     f0100806 <showmappings+0x89>
f01007fd:	8b 10                	mov    (%eax),%edx
f01007ff:	89 d0                	mov    %edx,%eax
f0100801:	83 e0 01             	and    $0x1,%eax
f0100804:	75 12                	jne    f0100818 <showmappings+0x9b>
			cprintf("not mapped\n");
f0100806:	83 ec 0c             	sub    $0xc,%esp
f0100809:	68 12 4c 10 f0       	push   $0xf0104c12
f010080e:	e8 da 28 00 00       	call   f01030ed <cprintf>
			continue;
f0100813:	83 c4 10             	add    $0x10,%esp
f0100816:	eb 24                	jmp    f010083c <showmappings+0xbf>
		}
		int pyadd = PTE_ADDR(*pt_entry);
		cprintf("paddr is %08x, PTE_W is %d,PTE_U is %d,PTE_P is %d\n", pyadd, *pt_entry&PTE_W, *pt_entry&PTE_U, *pt_entry&PTE_P);
f0100818:	83 ec 0c             	sub    $0xc,%esp
f010081b:	50                   	push   %eax
f010081c:	89 d0                	mov    %edx,%eax
f010081e:	83 e0 04             	and    $0x4,%eax
f0100821:	50                   	push   %eax
f0100822:	89 d0                	mov    %edx,%eax
f0100824:	83 e0 02             	and    $0x2,%eax
f0100827:	50                   	push   %eax
f0100828:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010082e:	52                   	push   %edx
f010082f:	68 00 4e 10 f0       	push   $0xf0104e00
f0100834:	e8 b4 28 00 00       	call   f01030ed <cprintf>
f0100839:	83 c4 20             	add    $0x20,%esp
	// align
	start = ROUNDDOWN(start, PGSIZE);
	end = ROUNDDOWN(end, PGSIZE);

	int i = start;
	for (; i <= end; i += PGSIZE) {
f010083c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100842:	39 f3                	cmp    %esi,%ebx
f0100844:	7e 91                	jle    f01007d7 <showmappings+0x5a>
			continue;
		}
		int pyadd = PTE_ADDR(*pt_entry);
		cprintf("paddr is %08x, PTE_W is %d,PTE_U is %d,PTE_P is %d\n", pyadd, *pt_entry&PTE_W, *pt_entry&PTE_U, *pt_entry&PTE_P);
	}
	return 0;
f0100846:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010084b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010084e:	5b                   	pop    %ebx
f010084f:	5e                   	pop    %esi
f0100850:	5d                   	pop    %ebp
f0100851:	c3                   	ret    

f0100852 <mon_backtrace>:
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100852:	55                   	push   %ebp
f0100853:	89 e5                	mov    %esp,%ebp
f0100855:	57                   	push   %edi
f0100856:	56                   	push   %esi
f0100857:	53                   	push   %ebx
f0100858:	83 ec 48             	sub    $0x48,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f010085b:	89 ee                	mov    %ebp,%esi
  uint32_t* ebp = (uint32_t*) read_ebp();
  cprintf("Stack backtrace:\n");
f010085d:	68 1e 4c 10 f0       	push   $0xf0104c1e
f0100862:	e8 86 28 00 00       	call   f01030ed <cprintf>
  while (ebp) {
f0100867:	83 c4 10             	add    $0x10,%esp
f010086a:	eb 78                	jmp    f01008e4 <mon_backtrace+0x92>
    uint32_t eip = ebp[1];
f010086c:	8b 46 04             	mov    0x4(%esi),%eax
f010086f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    cprintf("ebp %x  eip %x  args", ebp, eip);
f0100872:	83 ec 04             	sub    $0x4,%esp
f0100875:	50                   	push   %eax
f0100876:	56                   	push   %esi
f0100877:	68 30 4c 10 f0       	push   $0xf0104c30
f010087c:	e8 6c 28 00 00       	call   f01030ed <cprintf>
f0100881:	8d 5e 08             	lea    0x8(%esi),%ebx
f0100884:	8d 7e 1c             	lea    0x1c(%esi),%edi
f0100887:	83 c4 10             	add    $0x10,%esp
    int i;
    for (i = 2; i <= 6; ++i)
      cprintf(" %08.x", ebp[i]);
f010088a:	83 ec 08             	sub    $0x8,%esp
f010088d:	ff 33                	pushl  (%ebx)
f010088f:	68 45 4c 10 f0       	push   $0xf0104c45
f0100894:	e8 54 28 00 00       	call   f01030ed <cprintf>
f0100899:	83 c3 04             	add    $0x4,%ebx
  cprintf("Stack backtrace:\n");
  while (ebp) {
    uint32_t eip = ebp[1];
    cprintf("ebp %x  eip %x  args", ebp, eip);
    int i;
    for (i = 2; i <= 6; ++i)
f010089c:	83 c4 10             	add    $0x10,%esp
f010089f:	39 fb                	cmp    %edi,%ebx
f01008a1:	75 e7                	jne    f010088a <mon_backtrace+0x38>
      cprintf(" %08.x", ebp[i]);
    cprintf("\n");
f01008a3:	83 ec 0c             	sub    $0xc,%esp
f01008a6:	68 48 5a 10 f0       	push   $0xf0105a48
f01008ab:	e8 3d 28 00 00       	call   f01030ed <cprintf>
    struct Eipdebuginfo info;
    debuginfo_eip(eip, &info);
f01008b0:	83 c4 08             	add    $0x8,%esp
f01008b3:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008b6:	50                   	push   %eax
f01008b7:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01008ba:	57                   	push   %edi
f01008bb:	e8 4c 31 00 00       	call   f0103a0c <debuginfo_eip>
    cprintf("\t%s:%d: %.*s+%d\n", 
f01008c0:	83 c4 08             	add    $0x8,%esp
f01008c3:	89 f8                	mov    %edi,%eax
f01008c5:	2b 45 e0             	sub    -0x20(%ebp),%eax
f01008c8:	50                   	push   %eax
f01008c9:	ff 75 d8             	pushl  -0x28(%ebp)
f01008cc:	ff 75 dc             	pushl  -0x24(%ebp)
f01008cf:	ff 75 d4             	pushl  -0x2c(%ebp)
f01008d2:	ff 75 d0             	pushl  -0x30(%ebp)
f01008d5:	68 4c 4c 10 f0       	push   $0xf0104c4c
f01008da:	e8 0e 28 00 00       	call   f01030ed <cprintf>
      info.eip_file, info.eip_line,
      info.eip_fn_namelen, info.eip_fn_name,
      eip-info.eip_fn_addr);
//         kern/monitor.c:143: monitor+106
    ebp = (uint32_t*) *ebp;
f01008df:	8b 36                	mov    (%esi),%esi
f01008e1:	83 c4 20             	add    $0x20,%esp
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
  uint32_t* ebp = (uint32_t*) read_ebp();
  cprintf("Stack backtrace:\n");
  while (ebp) {
f01008e4:	85 f6                	test   %esi,%esi
f01008e6:	75 84                	jne    f010086c <mon_backtrace+0x1a>
      eip-info.eip_fn_addr);
//         kern/monitor.c:143: monitor+106
    ebp = (uint32_t*) *ebp;
  }
  return 0;
}
f01008e8:	b8 00 00 00 00       	mov    $0x0,%eax
f01008ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008f0:	5b                   	pop    %ebx
f01008f1:	5e                   	pop    %esi
f01008f2:	5f                   	pop    %edi
f01008f3:	5d                   	pop    %ebp
f01008f4:	c3                   	ret    

f01008f5 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01008f5:	55                   	push   %ebp
f01008f6:	89 e5                	mov    %esp,%ebp
f01008f8:	57                   	push   %edi
f01008f9:	56                   	push   %esi
f01008fa:	53                   	push   %ebx
f01008fb:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01008fe:	68 34 4e 10 f0       	push   $0xf0104e34
f0100903:	e8 e5 27 00 00       	call   f01030ed <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100908:	c7 04 24 58 4e 10 f0 	movl   $0xf0104e58,(%esp)
f010090f:	e8 d9 27 00 00       	call   f01030ed <cprintf>

	if (tf != NULL)
f0100914:	83 c4 10             	add    $0x10,%esp
f0100917:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010091b:	74 0e                	je     f010092b <monitor+0x36>
		print_trapframe(tf);
f010091d:	83 ec 0c             	sub    $0xc,%esp
f0100920:	ff 75 08             	pushl  0x8(%ebp)
f0100923:	e8 7e 2b 00 00       	call   f01034a6 <print_trapframe>
f0100928:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f010092b:	83 ec 0c             	sub    $0xc,%esp
f010092e:	68 5d 4c 10 f0       	push   $0xf0104c5d
f0100933:	e8 d7 38 00 00       	call   f010420f <readline>
f0100938:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010093a:	83 c4 10             	add    $0x10,%esp
f010093d:	85 c0                	test   %eax,%eax
f010093f:	74 ea                	je     f010092b <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100941:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100948:	be 00 00 00 00       	mov    $0x0,%esi
f010094d:	eb 0a                	jmp    f0100959 <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f010094f:	c6 03 00             	movb   $0x0,(%ebx)
f0100952:	89 f7                	mov    %esi,%edi
f0100954:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100957:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100959:	0f b6 03             	movzbl (%ebx),%eax
f010095c:	84 c0                	test   %al,%al
f010095e:	74 63                	je     f01009c3 <monitor+0xce>
f0100960:	83 ec 08             	sub    $0x8,%esp
f0100963:	0f be c0             	movsbl %al,%eax
f0100966:	50                   	push   %eax
f0100967:	68 61 4c 10 f0       	push   $0xf0104c61
f010096c:	e8 b8 3a 00 00       	call   f0104429 <strchr>
f0100971:	83 c4 10             	add    $0x10,%esp
f0100974:	85 c0                	test   %eax,%eax
f0100976:	75 d7                	jne    f010094f <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f0100978:	80 3b 00             	cmpb   $0x0,(%ebx)
f010097b:	74 46                	je     f01009c3 <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010097d:	83 fe 0f             	cmp    $0xf,%esi
f0100980:	75 14                	jne    f0100996 <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100982:	83 ec 08             	sub    $0x8,%esp
f0100985:	6a 10                	push   $0x10
f0100987:	68 66 4c 10 f0       	push   $0xf0104c66
f010098c:	e8 5c 27 00 00       	call   f01030ed <cprintf>
f0100991:	83 c4 10             	add    $0x10,%esp
f0100994:	eb 95                	jmp    f010092b <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f0100996:	8d 7e 01             	lea    0x1(%esi),%edi
f0100999:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010099d:	eb 03                	jmp    f01009a2 <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f010099f:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01009a2:	0f b6 03             	movzbl (%ebx),%eax
f01009a5:	84 c0                	test   %al,%al
f01009a7:	74 ae                	je     f0100957 <monitor+0x62>
f01009a9:	83 ec 08             	sub    $0x8,%esp
f01009ac:	0f be c0             	movsbl %al,%eax
f01009af:	50                   	push   %eax
f01009b0:	68 61 4c 10 f0       	push   $0xf0104c61
f01009b5:	e8 6f 3a 00 00       	call   f0104429 <strchr>
f01009ba:	83 c4 10             	add    $0x10,%esp
f01009bd:	85 c0                	test   %eax,%eax
f01009bf:	74 de                	je     f010099f <monitor+0xaa>
f01009c1:	eb 94                	jmp    f0100957 <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f01009c3:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01009ca:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01009cb:	85 f6                	test   %esi,%esi
f01009cd:	0f 84 58 ff ff ff    	je     f010092b <monitor+0x36>
f01009d3:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01009d8:	83 ec 08             	sub    $0x8,%esp
f01009db:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01009de:	ff 34 85 00 4f 10 f0 	pushl  -0xfefb100(,%eax,4)
f01009e5:	ff 75 a8             	pushl  -0x58(%ebp)
f01009e8:	e8 de 39 00 00       	call   f01043cb <strcmp>
f01009ed:	83 c4 10             	add    $0x10,%esp
f01009f0:	85 c0                	test   %eax,%eax
f01009f2:	75 21                	jne    f0100a15 <monitor+0x120>
			return commands[i].func(argc, argv, tf);
f01009f4:	83 ec 04             	sub    $0x4,%esp
f01009f7:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01009fa:	ff 75 08             	pushl  0x8(%ebp)
f01009fd:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a00:	52                   	push   %edx
f0100a01:	56                   	push   %esi
f0100a02:	ff 14 85 08 4f 10 f0 	call   *-0xfefb0f8(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a09:	83 c4 10             	add    $0x10,%esp
f0100a0c:	85 c0                	test   %eax,%eax
f0100a0e:	78 25                	js     f0100a35 <monitor+0x140>
f0100a10:	e9 16 ff ff ff       	jmp    f010092b <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a15:	83 c3 01             	add    $0x1,%ebx
f0100a18:	83 fb 04             	cmp    $0x4,%ebx
f0100a1b:	75 bb                	jne    f01009d8 <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a1d:	83 ec 08             	sub    $0x8,%esp
f0100a20:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a23:	68 83 4c 10 f0       	push   $0xf0104c83
f0100a28:	e8 c0 26 00 00       	call   f01030ed <cprintf>
f0100a2d:	83 c4 10             	add    $0x10,%esp
f0100a30:	e9 f6 fe ff ff       	jmp    f010092b <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a35:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a38:	5b                   	pop    %ebx
f0100a39:	5e                   	pop    %esi
f0100a3a:	5f                   	pop    %edi
f0100a3b:	5d                   	pop    %ebp
f0100a3c:	c3                   	ret    

f0100a3d <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100a3d:	55                   	push   %ebp
f0100a3e:	89 e5                	mov    %esp,%ebp
f0100a40:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a42:	83 3d 78 1f 17 f0 00 	cmpl   $0x0,0xf0171f78
f0100a49:	75 0f                	jne    f0100a5a <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100a4b:	b8 4f 3c 17 f0       	mov    $0xf0173c4f,%eax
f0100a50:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a55:	a3 78 1f 17 f0       	mov    %eax,0xf0171f78
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
f0100a5a:	a1 78 1f 17 f0       	mov    0xf0171f78,%eax
	nextfree += ROUNDUP(n, PGSIZE);
f0100a5f:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f0100a65:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a6b:	01 c2                	add    %eax,%edx
f0100a6d:	89 15 78 1f 17 f0    	mov    %edx,0xf0171f78

	return result;
}
f0100a73:	5d                   	pop    %ebp
f0100a74:	c3                   	ret    

f0100a75 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100a75:	55                   	push   %ebp
f0100a76:	89 e5                	mov    %esp,%ebp
f0100a78:	56                   	push   %esi
f0100a79:	53                   	push   %ebx
f0100a7a:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100a7c:	83 ec 0c             	sub    $0xc,%esp
f0100a7f:	50                   	push   %eax
f0100a80:	e8 01 26 00 00       	call   f0103086 <mc146818_read>
f0100a85:	89 c6                	mov    %eax,%esi
f0100a87:	83 c3 01             	add    $0x1,%ebx
f0100a8a:	89 1c 24             	mov    %ebx,(%esp)
f0100a8d:	e8 f4 25 00 00       	call   f0103086 <mc146818_read>
f0100a92:	c1 e0 08             	shl    $0x8,%eax
f0100a95:	09 f0                	or     %esi,%eax
}
f0100a97:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100a9a:	5b                   	pop    %ebx
f0100a9b:	5e                   	pop    %esi
f0100a9c:	5d                   	pop    %ebp
f0100a9d:	c3                   	ret    

f0100a9e <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100a9e:	89 d1                	mov    %edx,%ecx
f0100aa0:	c1 e9 16             	shr    $0x16,%ecx
f0100aa3:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100aa6:	a8 01                	test   $0x1,%al
f0100aa8:	74 52                	je     f0100afc <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100aaa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100aaf:	89 c1                	mov    %eax,%ecx
f0100ab1:	c1 e9 0c             	shr    $0xc,%ecx
f0100ab4:	3b 0d 44 2c 17 f0    	cmp    0xf0172c44,%ecx
f0100aba:	72 1b                	jb     f0100ad7 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100abc:	55                   	push   %ebp
f0100abd:	89 e5                	mov    %esp,%ebp
f0100abf:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ac2:	50                   	push   %eax
f0100ac3:	68 30 4f 10 f0       	push   $0xf0104f30
f0100ac8:	68 2c 03 00 00       	push   $0x32c
f0100acd:	68 7d 57 10 f0       	push   $0xf010577d
f0100ad2:	e8 1f f6 ff ff       	call   f01000f6 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100ad7:	c1 ea 0c             	shr    $0xc,%edx
f0100ada:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100ae0:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100ae7:	89 c2                	mov    %eax,%edx
f0100ae9:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100aec:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100af1:	85 d2                	test   %edx,%edx
f0100af3:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100af8:	0f 44 c2             	cmove  %edx,%eax
f0100afb:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100afc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100b01:	c3                   	ret    

f0100b02 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100b02:	55                   	push   %ebp
f0100b03:	89 e5                	mov    %esp,%ebp
f0100b05:	57                   	push   %edi
f0100b06:	56                   	push   %esi
f0100b07:	53                   	push   %ebx
f0100b08:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b0b:	84 c0                	test   %al,%al
f0100b0d:	0f 85 81 02 00 00    	jne    f0100d94 <check_page_free_list+0x292>
f0100b13:	e9 8e 02 00 00       	jmp    f0100da6 <check_page_free_list+0x2a4>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100b18:	83 ec 04             	sub    $0x4,%esp
f0100b1b:	68 54 4f 10 f0       	push   $0xf0104f54
f0100b20:	68 68 02 00 00       	push   $0x268
f0100b25:	68 7d 57 10 f0       	push   $0xf010577d
f0100b2a:	e8 c7 f5 ff ff       	call   f01000f6 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100b2f:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100b32:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100b35:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b38:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100b3b:	89 c2                	mov    %eax,%edx
f0100b3d:	2b 15 4c 2c 17 f0    	sub    0xf0172c4c,%edx
f0100b43:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100b49:	0f 95 c2             	setne  %dl
f0100b4c:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100b4f:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100b53:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100b55:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b59:	8b 00                	mov    (%eax),%eax
f0100b5b:	85 c0                	test   %eax,%eax
f0100b5d:	75 dc                	jne    f0100b3b <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100b5f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b62:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100b68:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b6b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100b6e:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100b70:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100b73:	a3 80 1f 17 f0       	mov    %eax,0xf0171f80
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b78:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b7d:	8b 1d 80 1f 17 f0    	mov    0xf0171f80,%ebx
f0100b83:	eb 53                	jmp    f0100bd8 <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b85:	89 d8                	mov    %ebx,%eax
f0100b87:	2b 05 4c 2c 17 f0    	sub    0xf0172c4c,%eax
f0100b8d:	c1 f8 03             	sar    $0x3,%eax
f0100b90:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100b93:	89 c2                	mov    %eax,%edx
f0100b95:	c1 ea 16             	shr    $0x16,%edx
f0100b98:	39 f2                	cmp    %esi,%edx
f0100b9a:	73 3a                	jae    f0100bd6 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b9c:	89 c2                	mov    %eax,%edx
f0100b9e:	c1 ea 0c             	shr    $0xc,%edx
f0100ba1:	3b 15 44 2c 17 f0    	cmp    0xf0172c44,%edx
f0100ba7:	72 12                	jb     f0100bbb <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ba9:	50                   	push   %eax
f0100baa:	68 30 4f 10 f0       	push   $0xf0104f30
f0100baf:	6a 56                	push   $0x56
f0100bb1:	68 89 57 10 f0       	push   $0xf0105789
f0100bb6:	e8 3b f5 ff ff       	call   f01000f6 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100bbb:	83 ec 04             	sub    $0x4,%esp
f0100bbe:	68 80 00 00 00       	push   $0x80
f0100bc3:	68 97 00 00 00       	push   $0x97
f0100bc8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100bcd:	50                   	push   %eax
f0100bce:	e8 93 38 00 00       	call   f0104466 <memset>
f0100bd3:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bd6:	8b 1b                	mov    (%ebx),%ebx
f0100bd8:	85 db                	test   %ebx,%ebx
f0100bda:	75 a9                	jne    f0100b85 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100bdc:	b8 00 00 00 00       	mov    $0x0,%eax
f0100be1:	e8 57 fe ff ff       	call   f0100a3d <boot_alloc>
f0100be6:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100be9:	8b 15 80 1f 17 f0    	mov    0xf0171f80,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100bef:	8b 0d 4c 2c 17 f0    	mov    0xf0172c4c,%ecx
		assert(pp < pages + npages);
f0100bf5:	a1 44 2c 17 f0       	mov    0xf0172c44,%eax
f0100bfa:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100bfd:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c00:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c03:	be 00 00 00 00       	mov    $0x0,%esi
f0100c08:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c0b:	e9 30 01 00 00       	jmp    f0100d40 <check_page_free_list+0x23e>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c10:	39 ca                	cmp    %ecx,%edx
f0100c12:	73 19                	jae    f0100c2d <check_page_free_list+0x12b>
f0100c14:	68 97 57 10 f0       	push   $0xf0105797
f0100c19:	68 a3 57 10 f0       	push   $0xf01057a3
f0100c1e:	68 82 02 00 00       	push   $0x282
f0100c23:	68 7d 57 10 f0       	push   $0xf010577d
f0100c28:	e8 c9 f4 ff ff       	call   f01000f6 <_panic>
		assert(pp < pages + npages);
f0100c2d:	39 fa                	cmp    %edi,%edx
f0100c2f:	72 19                	jb     f0100c4a <check_page_free_list+0x148>
f0100c31:	68 b8 57 10 f0       	push   $0xf01057b8
f0100c36:	68 a3 57 10 f0       	push   $0xf01057a3
f0100c3b:	68 83 02 00 00       	push   $0x283
f0100c40:	68 7d 57 10 f0       	push   $0xf010577d
f0100c45:	e8 ac f4 ff ff       	call   f01000f6 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c4a:	89 d0                	mov    %edx,%eax
f0100c4c:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100c4f:	a8 07                	test   $0x7,%al
f0100c51:	74 19                	je     f0100c6c <check_page_free_list+0x16a>
f0100c53:	68 78 4f 10 f0       	push   $0xf0104f78
f0100c58:	68 a3 57 10 f0       	push   $0xf01057a3
f0100c5d:	68 84 02 00 00       	push   $0x284
f0100c62:	68 7d 57 10 f0       	push   $0xf010577d
f0100c67:	e8 8a f4 ff ff       	call   f01000f6 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c6c:	c1 f8 03             	sar    $0x3,%eax
f0100c6f:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100c72:	85 c0                	test   %eax,%eax
f0100c74:	75 19                	jne    f0100c8f <check_page_free_list+0x18d>
f0100c76:	68 cc 57 10 f0       	push   $0xf01057cc
f0100c7b:	68 a3 57 10 f0       	push   $0xf01057a3
f0100c80:	68 87 02 00 00       	push   $0x287
f0100c85:	68 7d 57 10 f0       	push   $0xf010577d
f0100c8a:	e8 67 f4 ff ff       	call   f01000f6 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c8f:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100c94:	75 19                	jne    f0100caf <check_page_free_list+0x1ad>
f0100c96:	68 dd 57 10 f0       	push   $0xf01057dd
f0100c9b:	68 a3 57 10 f0       	push   $0xf01057a3
f0100ca0:	68 88 02 00 00       	push   $0x288
f0100ca5:	68 7d 57 10 f0       	push   $0xf010577d
f0100caa:	e8 47 f4 ff ff       	call   f01000f6 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100caf:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100cb4:	75 19                	jne    f0100ccf <check_page_free_list+0x1cd>
f0100cb6:	68 ac 4f 10 f0       	push   $0xf0104fac
f0100cbb:	68 a3 57 10 f0       	push   $0xf01057a3
f0100cc0:	68 89 02 00 00       	push   $0x289
f0100cc5:	68 7d 57 10 f0       	push   $0xf010577d
f0100cca:	e8 27 f4 ff ff       	call   f01000f6 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100ccf:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100cd4:	75 19                	jne    f0100cef <check_page_free_list+0x1ed>
f0100cd6:	68 f6 57 10 f0       	push   $0xf01057f6
f0100cdb:	68 a3 57 10 f0       	push   $0xf01057a3
f0100ce0:	68 8a 02 00 00       	push   $0x28a
f0100ce5:	68 7d 57 10 f0       	push   $0xf010577d
f0100cea:	e8 07 f4 ff ff       	call   f01000f6 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100cef:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100cf4:	76 3f                	jbe    f0100d35 <check_page_free_list+0x233>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100cf6:	89 c3                	mov    %eax,%ebx
f0100cf8:	c1 eb 0c             	shr    $0xc,%ebx
f0100cfb:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0100cfe:	77 12                	ja     f0100d12 <check_page_free_list+0x210>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d00:	50                   	push   %eax
f0100d01:	68 30 4f 10 f0       	push   $0xf0104f30
f0100d06:	6a 56                	push   $0x56
f0100d08:	68 89 57 10 f0       	push   $0xf0105789
f0100d0d:	e8 e4 f3 ff ff       	call   f01000f6 <_panic>
f0100d12:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100d17:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100d1a:	76 1e                	jbe    f0100d3a <check_page_free_list+0x238>
f0100d1c:	68 d0 4f 10 f0       	push   $0xf0104fd0
f0100d21:	68 a3 57 10 f0       	push   $0xf01057a3
f0100d26:	68 8b 02 00 00       	push   $0x28b
f0100d2b:	68 7d 57 10 f0       	push   $0xf010577d
f0100d30:	e8 c1 f3 ff ff       	call   f01000f6 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100d35:	83 c6 01             	add    $0x1,%esi
f0100d38:	eb 04                	jmp    f0100d3e <check_page_free_list+0x23c>
		else
			++nfree_extmem;
f0100d3a:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d3e:	8b 12                	mov    (%edx),%edx
f0100d40:	85 d2                	test   %edx,%edx
f0100d42:	0f 85 c8 fe ff ff    	jne    f0100c10 <check_page_free_list+0x10e>
f0100d48:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100d4b:	85 f6                	test   %esi,%esi
f0100d4d:	7f 19                	jg     f0100d68 <check_page_free_list+0x266>
f0100d4f:	68 10 58 10 f0       	push   $0xf0105810
f0100d54:	68 a3 57 10 f0       	push   $0xf01057a3
f0100d59:	68 93 02 00 00       	push   $0x293
f0100d5e:	68 7d 57 10 f0       	push   $0xf010577d
f0100d63:	e8 8e f3 ff ff       	call   f01000f6 <_panic>
	assert(nfree_extmem > 0);
f0100d68:	85 db                	test   %ebx,%ebx
f0100d6a:	7f 19                	jg     f0100d85 <check_page_free_list+0x283>
f0100d6c:	68 22 58 10 f0       	push   $0xf0105822
f0100d71:	68 a3 57 10 f0       	push   $0xf01057a3
f0100d76:	68 94 02 00 00       	push   $0x294
f0100d7b:	68 7d 57 10 f0       	push   $0xf010577d
f0100d80:	e8 71 f3 ff ff       	call   f01000f6 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100d85:	83 ec 0c             	sub    $0xc,%esp
f0100d88:	68 18 50 10 f0       	push   $0xf0105018
f0100d8d:	e8 5b 23 00 00       	call   f01030ed <cprintf>
}
f0100d92:	eb 29                	jmp    f0100dbd <check_page_free_list+0x2bb>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100d94:	a1 80 1f 17 f0       	mov    0xf0171f80,%eax
f0100d99:	85 c0                	test   %eax,%eax
f0100d9b:	0f 85 8e fd ff ff    	jne    f0100b2f <check_page_free_list+0x2d>
f0100da1:	e9 72 fd ff ff       	jmp    f0100b18 <check_page_free_list+0x16>
f0100da6:	83 3d 80 1f 17 f0 00 	cmpl   $0x0,0xf0171f80
f0100dad:	0f 84 65 fd ff ff    	je     f0100b18 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100db3:	be 00 04 00 00       	mov    $0x400,%esi
f0100db8:	e9 c0 fd ff ff       	jmp    f0100b7d <check_page_free_list+0x7b>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f0100dbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100dc0:	5b                   	pop    %ebx
f0100dc1:	5e                   	pop    %esi
f0100dc2:	5f                   	pop    %edi
f0100dc3:	5d                   	pop    %ebp
f0100dc4:	c3                   	ret    

f0100dc5 <page_init>:
// After this is done, NEVER use boot_alloc again.  ONLY use the page
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void) {
f0100dc5:	55                   	push   %ebp
f0100dc6:	89 e5                	mov    %esp,%ebp
f0100dc8:	56                   	push   %esi
f0100dc9:	53                   	push   %ebx
	// The example code here marks all physical pages as free.
	// However this is not truly the case.  What memory is free?
	//  1) Mark physical page 0 as in use.
	//     This way we preserve the real-mode IDT and BIOS structures
	//     in case we ever need them.  (Currently we don't, but...)
	pages[0].pp_ref = 1;
f0100dca:	a1 4c 2c 17 f0       	mov    0xf0172c4c,%eax
f0100dcf:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages[0].pp_link = 0;
f0100dd5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	//  2) The rest of base memory, [PGSIZE, npages_basemem * PGSIZE)
	//     is free.
	int i = 1;
	for (; i < npages_basemem; i++) {
f0100ddb:	8b 35 84 1f 17 f0    	mov    0xf0171f84,%esi
f0100de1:	8b 1d 80 1f 17 f0    	mov    0xf0171f80,%ebx
f0100de7:	ba 00 00 00 00       	mov    $0x0,%edx
	//     in case we ever need them.  (Currently we don't, but...)
	pages[0].pp_ref = 1;
	pages[0].pp_link = 0;
	//  2) The rest of base memory, [PGSIZE, npages_basemem * PGSIZE)
	//     is free.
	int i = 1;
f0100dec:	b8 01 00 00 00       	mov    $0x1,%eax
	for (; i < npages_basemem; i++) {
f0100df1:	eb 27                	jmp    f0100e1a <page_init+0x55>
f0100df3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f0100dfa:	89 d1                	mov    %edx,%ecx
f0100dfc:	03 0d 4c 2c 17 f0    	add    0xf0172c4c,%ecx
f0100e02:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100e08:	89 19                	mov    %ebx,(%ecx)
	pages[0].pp_ref = 1;
	pages[0].pp_link = 0;
	//  2) The rest of base memory, [PGSIZE, npages_basemem * PGSIZE)
	//     is free.
	int i = 1;
	for (; i < npages_basemem; i++) {
f0100e0a:	83 c0 01             	add    $0x1,%eax
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
f0100e0d:	89 d3                	mov    %edx,%ebx
f0100e0f:	03 1d 4c 2c 17 f0    	add    0xf0172c4c,%ebx
f0100e15:	ba 01 00 00 00       	mov    $0x1,%edx
	pages[0].pp_ref = 1;
	pages[0].pp_link = 0;
	//  2) The rest of base memory, [PGSIZE, npages_basemem * PGSIZE)
	//     is free.
	int i = 1;
	for (; i < npages_basemem; i++) {
f0100e1a:	39 c6                	cmp    %eax,%esi
f0100e1c:	77 d5                	ja     f0100df3 <page_init+0x2e>
f0100e1e:	84 d2                	test   %dl,%dl
f0100e20:	74 06                	je     f0100e28 <page_init+0x63>
f0100e22:	89 1d 80 1f 17 f0    	mov    %ebx,0xf0171f80
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	//  3) Then comes the IO hole [IOPHYSMEM, EXTPHYSMEM), which must
	//     never be allocated.
	assert(npages_basemem==IOPHYSMEM/PGSIZE);
f0100e28:	81 fe a0 00 00 00    	cmp    $0xa0,%esi
f0100e2e:	74 19                	je     f0100e49 <page_init+0x84>
f0100e30:	68 3c 50 10 f0       	push   $0xf010503c
f0100e35:	68 a3 57 10 f0       	push   $0xf01057a3
f0100e3a:	68 19 01 00 00       	push   $0x119
f0100e3f:	68 7d 57 10 f0       	push   $0xf010577d
f0100e44:	e8 ad f2 ff ff       	call   f01000f6 <_panic>
f0100e49:	b8 00 05 00 00       	mov    $0x500,%eax
	for (i = IOPHYSMEM / PGSIZE; i < EXTPHYSMEM / PGSIZE; i++) {
		pages[i].pp_ref = 1;
f0100e4e:	89 c2                	mov    %eax,%edx
f0100e50:	03 15 4c 2c 17 f0    	add    0xf0172c4c,%edx
f0100e56:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
		pages[i].pp_link = 0;
f0100e5c:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
f0100e62:	83 c0 08             	add    $0x8,%eax
		page_free_list = &pages[i];
	}
	//  3) Then comes the IO hole [IOPHYSMEM, EXTPHYSMEM), which must
	//     never be allocated.
	assert(npages_basemem==IOPHYSMEM/PGSIZE);
	for (i = IOPHYSMEM / PGSIZE; i < EXTPHYSMEM / PGSIZE; i++) {
f0100e65:	3d 00 08 00 00       	cmp    $0x800,%eax
f0100e6a:	75 e2                	jne    f0100e4e <page_init+0x89>
f0100e6c:	bb 00 01 00 00       	mov    $0x100,%ebx
f0100e71:	eb 17                	jmp    f0100e8a <page_init+0xc5>
	//     in physical memory?  Which pages are already in use for
	//     page tables and other data structures?
	//
	// from pages to kernbase is in use, else is free
	for (i = EXTPHYSMEM / PGSIZE; i < ((uint32_t) boot_alloc(0) - KERNBASE) >> PGSHIFT; i++) {
		pages[i].pp_ref = 1;
f0100e73:	a1 4c 2c 17 f0       	mov    0xf0172c4c,%eax
f0100e78:	8d 04 d8             	lea    (%eax,%ebx,8),%eax
f0100e7b:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
		pages[i].pp_link = 0;
f0100e81:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	//     Some of it is in use, some is free. Where is the kernel
	//     in physical memory?  Which pages are already in use for
	//     page tables and other data structures?
	//
	// from pages to kernbase is in use, else is free
	for (i = EXTPHYSMEM / PGSIZE; i < ((uint32_t) boot_alloc(0) - KERNBASE) >> PGSHIFT; i++) {
f0100e87:	83 c3 01             	add    $0x1,%ebx
f0100e8a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e8f:	e8 a9 fb ff ff       	call   f0100a3d <boot_alloc>
f0100e94:	05 00 00 00 10       	add    $0x10000000,%eax
f0100e99:	c1 e8 0c             	shr    $0xc,%eax
f0100e9c:	39 d8                	cmp    %ebx,%eax
f0100e9e:	77 d3                	ja     f0100e73 <page_init+0xae>
		pages[i].pp_ref = 1;
		pages[i].pp_link = 0;
	}

	for (i = ((uint32_t) boot_alloc(0) - KERNBASE) >> PGSHIFT; i < npages; i++) {
f0100ea0:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ea5:	e8 93 fb ff ff       	call   f0100a3d <boot_alloc>
f0100eaa:	05 00 00 00 10       	add    $0x10000000,%eax
f0100eaf:	c1 e8 0c             	shr    $0xc,%eax
f0100eb2:	89 c2                	mov    %eax,%edx
f0100eb4:	8b 1d 80 1f 17 f0    	mov    0xf0171f80,%ebx
f0100eba:	c1 e0 03             	shl    $0x3,%eax
f0100ebd:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100ec2:	eb 23                	jmp    f0100ee7 <page_init+0x122>
		pages[i].pp_ref = 0;
f0100ec4:	89 c1                	mov    %eax,%ecx
f0100ec6:	03 0d 4c 2c 17 f0    	add    0xf0172c4c,%ecx
f0100ecc:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100ed2:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f0100ed4:	89 c3                	mov    %eax,%ebx
f0100ed6:	03 1d 4c 2c 17 f0    	add    0xf0172c4c,%ebx
	for (i = EXTPHYSMEM / PGSIZE; i < ((uint32_t) boot_alloc(0) - KERNBASE) >> PGSHIFT; i++) {
		pages[i].pp_ref = 1;
		pages[i].pp_link = 0;
	}

	for (i = ((uint32_t) boot_alloc(0) - KERNBASE) >> PGSHIFT; i < npages; i++) {
f0100edc:	83 c2 01             	add    $0x1,%edx
f0100edf:	83 c0 08             	add    $0x8,%eax
f0100ee2:	b9 01 00 00 00       	mov    $0x1,%ecx
f0100ee7:	3b 15 44 2c 17 f0    	cmp    0xf0172c44,%edx
f0100eed:	72 d5                	jb     f0100ec4 <page_init+0xff>
f0100eef:	84 c9                	test   %cl,%cl
f0100ef1:	74 06                	je     f0100ef9 <page_init+0x134>
f0100ef3:	89 1d 80 1f 17 f0    	mov    %ebx,0xf0171f80
		page_free_list = &pages[i];
	}
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
}
f0100ef9:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100efc:	5b                   	pop    %ebx
f0100efd:	5e                   	pop    %esi
f0100efe:	5d                   	pop    %ebp
f0100eff:	c3                   	ret    

f0100f00 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100f00:	55                   	push   %ebp
f0100f01:	89 e5                	mov    %esp,%ebp
f0100f03:	53                   	push   %ebx
f0100f04:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
	if(page_free_list==0) return 0;
f0100f07:	8b 1d 80 1f 17 f0    	mov    0xf0171f80,%ebx
f0100f0d:	85 db                	test   %ebx,%ebx
f0100f0f:	74 58                	je     f0100f69 <page_alloc+0x69>

	struct PageInfo * alloc_page = page_free_list;
	page_free_list = page_free_list->pp_link;
f0100f11:	8b 03                	mov    (%ebx),%eax
f0100f13:	a3 80 1f 17 f0       	mov    %eax,0xf0171f80
	alloc_page->pp_link = 0;
f0100f18:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if(alloc_flags&ALLOC_ZERO)
f0100f1e:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100f22:	74 45                	je     f0100f69 <page_alloc+0x69>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f24:	89 d8                	mov    %ebx,%eax
f0100f26:	2b 05 4c 2c 17 f0    	sub    0xf0172c4c,%eax
f0100f2c:	c1 f8 03             	sar    $0x3,%eax
f0100f2f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f32:	89 c2                	mov    %eax,%edx
f0100f34:	c1 ea 0c             	shr    $0xc,%edx
f0100f37:	3b 15 44 2c 17 f0    	cmp    0xf0172c44,%edx
f0100f3d:	72 12                	jb     f0100f51 <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f3f:	50                   	push   %eax
f0100f40:	68 30 4f 10 f0       	push   $0xf0104f30
f0100f45:	6a 56                	push   $0x56
f0100f47:	68 89 57 10 f0       	push   $0xf0105789
f0100f4c:	e8 a5 f1 ff ff       	call   f01000f6 <_panic>
		memset(page2kva(alloc_page), 0, PGSIZE);
f0100f51:	83 ec 04             	sub    $0x4,%esp
f0100f54:	68 00 10 00 00       	push   $0x1000
f0100f59:	6a 00                	push   $0x0
f0100f5b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100f60:	50                   	push   %eax
f0100f61:	e8 00 35 00 00       	call   f0104466 <memset>
f0100f66:	83 c4 10             	add    $0x10,%esp
	return alloc_page;
}
f0100f69:	89 d8                	mov    %ebx,%eax
f0100f6b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f6e:	c9                   	leave  
f0100f6f:	c3                   	ret    

f0100f70 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100f70:	55                   	push   %ebp
f0100f71:	89 e5                	mov    %esp,%ebp
f0100f73:	83 ec 08             	sub    $0x8,%esp
f0100f76:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	assert(!pp->pp_ref||!pp->pp_link);
f0100f79:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100f7e:	74 1e                	je     f0100f9e <page_free+0x2e>
f0100f80:	83 38 00             	cmpl   $0x0,(%eax)
f0100f83:	74 19                	je     f0100f9e <page_free+0x2e>
f0100f85:	68 33 58 10 f0       	push   $0xf0105833
f0100f8a:	68 a3 57 10 f0       	push   $0xf01057a3
f0100f8f:	68 57 01 00 00       	push   $0x157
f0100f94:	68 7d 57 10 f0       	push   $0xf010577d
f0100f99:	e8 58 f1 ff ff       	call   f01000f6 <_panic>
	pp->pp_link = page_free_list;
f0100f9e:	8b 15 80 1f 17 f0    	mov    0xf0171f80,%edx
f0100fa4:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100fa6:	a3 80 1f 17 f0       	mov    %eax,0xf0171f80
}
f0100fab:	c9                   	leave  
f0100fac:	c3                   	ret    

f0100fad <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100fad:	55                   	push   %ebp
f0100fae:	89 e5                	mov    %esp,%ebp
f0100fb0:	83 ec 08             	sub    $0x8,%esp
f0100fb3:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100fb6:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100fba:	83 e8 01             	sub    $0x1,%eax
f0100fbd:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100fc1:	66 85 c0             	test   %ax,%ax
f0100fc4:	75 0c                	jne    f0100fd2 <page_decref+0x25>
		page_free(pp);
f0100fc6:	83 ec 0c             	sub    $0xc,%esp
f0100fc9:	52                   	push   %edx
f0100fca:	e8 a1 ff ff ff       	call   f0100f70 <page_free>
f0100fcf:	83 c4 10             	add    $0x10,%esp
}
f0100fd2:	c9                   	leave  
f0100fd3:	c3                   	ret    

f0100fd4 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100fd4:	55                   	push   %ebp
f0100fd5:	89 e5                	mov    %esp,%ebp
f0100fd7:	56                   	push   %esi
f0100fd8:	53                   	push   %ebx
f0100fd9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	// from from pgdir get pgdir_entry;
	uint32_t dir_inx = PDX(va);
	uint32_t table_inx = PTX(va);
f0100fdc:	89 de                	mov    %ebx,%esi
f0100fde:	c1 ee 0c             	shr    $0xc,%esi
f0100fe1:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	// from pgdir get pd_entry
	pde_t pd_entry = 0;
    pd_entry = pgdir[dir_inx];
f0100fe7:	c1 eb 16             	shr    $0x16,%ebx
f0100fea:	c1 e3 02             	shl    $0x2,%ebx
f0100fed:	03 5d 08             	add    0x8(%ebp),%ebx
f0100ff0:	8b 03                	mov    (%ebx),%eax
	pte_t *pgtable = 0;
	//if present0;
	if(pd_entry&PTE_P){
f0100ff2:	a8 01                	test   $0x1,%al
f0100ff4:	74 2e                	je     f0101024 <pgdir_walk+0x50>
		// from pd_entry get pg_table
		pgtable = KADDR(PTE_ADDR(pd_entry));
f0100ff6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ffb:	89 c2                	mov    %eax,%edx
f0100ffd:	c1 ea 0c             	shr    $0xc,%edx
f0101000:	39 15 44 2c 17 f0    	cmp    %edx,0xf0172c44
f0101006:	77 15                	ja     f010101d <pgdir_walk+0x49>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101008:	50                   	push   %eax
f0101009:	68 30 4f 10 f0       	push   $0xf0104f30
f010100e:	68 8b 01 00 00       	push   $0x18b
f0101013:	68 7d 57 10 f0       	push   $0xf010577d
f0101018:	e8 d9 f0 ff ff       	call   f01000f6 <_panic>
	return (void *)(pa + KERNBASE);
f010101d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101022:	eb 64                	jmp    f0101088 <pgdir_walk+0xb4>
	uint32_t dir_inx = PDX(va);
	uint32_t table_inx = PTX(va);
	// from pgdir get pd_entry
	pde_t pd_entry = 0;
    pd_entry = pgdir[dir_inx];
	pte_t *pgtable = 0;
f0101024:	b8 00 00 00 00       	mov    $0x0,%eax
	//if present0;
	if(pd_entry&PTE_P){
		// from pd_entry get pg_table
		pgtable = KADDR(PTE_ADDR(pd_entry));
	} else if (create){
f0101029:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010102d:	74 59                	je     f0101088 <pgdir_walk+0xb4>
		struct PageInfo * allo_page = page_alloc(ALLOC_ZERO);
f010102f:	83 ec 0c             	sub    $0xc,%esp
f0101032:	6a 01                	push   $0x1
f0101034:	e8 c7 fe ff ff       	call   f0100f00 <page_alloc>
		if(!allo_page) return NULL;
f0101039:	83 c4 10             	add    $0x10,%esp
f010103c:	85 c0                	test   %eax,%eax
f010103e:	74 4d                	je     f010108d <pgdir_walk+0xb9>
		allo_page->pp_ref++;
f0101040:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
		pgdir[dir_inx] = page2pa(allo_page)| PTE_P | PTE_W | PTE_U;
f0101045:	89 c2                	mov    %eax,%edx
f0101047:	2b 15 4c 2c 17 f0    	sub    0xf0172c4c,%edx
f010104d:	c1 fa 03             	sar    $0x3,%edx
f0101050:	c1 e2 0c             	shl    $0xc,%edx
f0101053:	83 ca 07             	or     $0x7,%edx
f0101056:	89 13                	mov    %edx,(%ebx)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101058:	2b 05 4c 2c 17 f0    	sub    0xf0172c4c,%eax
f010105e:	c1 f8 03             	sar    $0x3,%eax
f0101061:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101064:	89 c2                	mov    %eax,%edx
f0101066:	c1 ea 0c             	shr    $0xc,%edx
f0101069:	3b 15 44 2c 17 f0    	cmp    0xf0172c44,%edx
f010106f:	72 12                	jb     f0101083 <pgdir_walk+0xaf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101071:	50                   	push   %eax
f0101072:	68 30 4f 10 f0       	push   $0xf0104f30
f0101077:	6a 56                	push   $0x56
f0101079:	68 89 57 10 f0       	push   $0xf0105789
f010107e:	e8 73 f0 ff ff       	call   f01000f6 <_panic>
	return (void *)(pa + KERNBASE);
f0101083:	2d 00 00 00 10       	sub    $0x10000000,%eax
		pgtable = page2kva(allo_page);
	}
	return  &pgtable[table_inx];
f0101088:	8d 04 b0             	lea    (%eax,%esi,4),%eax
f010108b:	eb 05                	jmp    f0101092 <pgdir_walk+0xbe>
	if(pd_entry&PTE_P){
		// from pd_entry get pg_table
		pgtable = KADDR(PTE_ADDR(pd_entry));
	} else if (create){
		struct PageInfo * allo_page = page_alloc(ALLOC_ZERO);
		if(!allo_page) return NULL;
f010108d:	b8 00 00 00 00       	mov    $0x0,%eax
		allo_page->pp_ref++;
		pgdir[dir_inx] = page2pa(allo_page)| PTE_P | PTE_W | PTE_U;
		pgtable = page2kva(allo_page);
	}
	return  &pgtable[table_inx];
}
f0101092:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101095:	5b                   	pop    %ebx
f0101096:	5e                   	pop    %esi
f0101097:	5d                   	pop    %ebp
f0101098:	c3                   	ret    

f0101099 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101099:	55                   	push   %ebp
f010109a:	89 e5                	mov    %esp,%ebp
f010109c:	57                   	push   %edi
f010109d:	56                   	push   %esi
f010109e:	53                   	push   %ebx
f010109f:	83 ec 1c             	sub    $0x1c,%esp
f01010a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01010a5:	89 cf                	mov    %ecx,%edi
	// Fill this function in
    // per pagetable_entry manage a page(PAGESIZE);
    // per pgdirtable entry manage a page*2^10 (4M)
    while (size){
f01010a7:	89 d3                	mov    %edx,%ebx
f01010a9:	8b 45 08             	mov    0x8(%ebp),%eax
f01010ac:	29 d0                	sub    %edx,%eax
f01010ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        pte_t *pt_entry = pgdir_walk(pgdir, (void *)va, 1);
        if(pt_entry==0) return;

        *pt_entry = pa|perm|PTE_P;
f01010b1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01010b4:	83 c8 01             	or     $0x1,%eax
f01010b7:	89 45 dc             	mov    %eax,-0x24(%ebp)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
    // per pagetable_entry manage a page(PAGESIZE);
    // per pgdirtable entry manage a page*2^10 (4M)
    while (size){
f01010ba:	eb 26                	jmp    f01010e2 <boot_map_region+0x49>
        pte_t *pt_entry = pgdir_walk(pgdir, (void *)va, 1);
f01010bc:	83 ec 04             	sub    $0x4,%esp
f01010bf:	6a 01                	push   $0x1
f01010c1:	53                   	push   %ebx
f01010c2:	ff 75 e0             	pushl  -0x20(%ebp)
f01010c5:	e8 0a ff ff ff       	call   f0100fd4 <pgdir_walk>
        if(pt_entry==0) return;
f01010ca:	83 c4 10             	add    $0x10,%esp
f01010cd:	85 c0                	test   %eax,%eax
f01010cf:	74 1b                	je     f01010ec <boot_map_region+0x53>

        *pt_entry = pa|perm|PTE_P;
f01010d1:	0b 75 dc             	or     -0x24(%ebp),%esi
f01010d4:	89 30                	mov    %esi,(%eax)
        size -= PGSIZE;
f01010d6:	81 ef 00 10 00 00    	sub    $0x1000,%edi
        va += PGSIZE;
f01010dc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01010e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01010e5:	8d 34 18             	lea    (%eax,%ebx,1),%esi
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
    // per pagetable_entry manage a page(PAGESIZE);
    // per pgdirtable entry manage a page*2^10 (4M)
    while (size){
f01010e8:	85 ff                	test   %edi,%edi
f01010ea:	75 d0                	jne    f01010bc <boot_map_region+0x23>
        size -= PGSIZE;
        va += PGSIZE;
        pa += PGSIZE;
    }

}
f01010ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010ef:	5b                   	pop    %ebx
f01010f0:	5e                   	pop    %esi
f01010f1:	5f                   	pop    %edi
f01010f2:	5d                   	pop    %ebp
f01010f3:	c3                   	ret    

f01010f4 <page_lookup>:
// Hint: the TA solution uses pgdir_walk and pa2page.
//
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01010f4:	55                   	push   %ebp
f01010f5:	89 e5                	mov    %esp,%ebp
f01010f7:	53                   	push   %ebx
f01010f8:	83 ec 08             	sub    $0x8,%esp
f01010fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
    pte_t *pt_entry = pgdir_walk(pgdir, va, 0);
f01010fe:	6a 00                	push   $0x0
f0101100:	ff 75 0c             	pushl  0xc(%ebp)
f0101103:	ff 75 08             	pushl  0x8(%ebp)
f0101106:	e8 c9 fe ff ff       	call   f0100fd4 <pgdir_walk>
    if (pt_entry==NULL) return NULL;
f010110b:	83 c4 10             	add    $0x10,%esp
f010110e:	85 c0                	test   %eax,%eax
f0101110:	74 3a                	je     f010114c <page_lookup+0x58>
    physaddr_t addr = PTE_ADDR(*pt_entry);
f0101112:	8b 10                	mov    (%eax),%edx
f0101114:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
    if (pte_store!=0) *pte_store = pt_entry;
f010111a:	85 db                	test   %ebx,%ebx
f010111c:	74 02                	je     f0101120 <page_lookup+0x2c>
f010111e:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101120:	89 d0                	mov    %edx,%eax
f0101122:	c1 e8 0c             	shr    $0xc,%eax
f0101125:	3b 05 44 2c 17 f0    	cmp    0xf0172c44,%eax
f010112b:	72 14                	jb     f0101141 <page_lookup+0x4d>
		panic("pa2page called with invalid pa");
f010112d:	83 ec 04             	sub    $0x4,%esp
f0101130:	68 60 50 10 f0       	push   $0xf0105060
f0101135:	6a 4f                	push   $0x4f
f0101137:	68 89 57 10 f0       	push   $0xf0105789
f010113c:	e8 b5 ef ff ff       	call   f01000f6 <_panic>
	return &pages[PGNUM(pa)];
f0101141:	8b 15 4c 2c 17 f0    	mov    0xf0172c4c,%edx
f0101147:	8d 04 c2             	lea    (%edx,%eax,8),%eax

	return pa2page(addr);
f010114a:	eb 05                	jmp    f0101151 <page_lookup+0x5d>
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	// Fill this function in
    pte_t *pt_entry = pgdir_walk(pgdir, va, 0);
    if (pt_entry==NULL) return NULL;
f010114c:	b8 00 00 00 00       	mov    $0x0,%eax
    physaddr_t addr = PTE_ADDR(*pt_entry);
    if (pte_store!=0) *pte_store = pt_entry;

	return pa2page(addr);
}
f0101151:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101154:	c9                   	leave  
f0101155:	c3                   	ret    

f0101156 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101156:	55                   	push   %ebp
f0101157:	89 e5                	mov    %esp,%ebp
f0101159:	53                   	push   %ebx
f010115a:	83 ec 18             	sub    $0x18,%esp
f010115d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
    pte_t *pte_store;
    struct PageInfo * pageInfo = 0;
    pageInfo = page_lookup(pgdir, va, &pte_store);
f0101160:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101163:	50                   	push   %eax
f0101164:	53                   	push   %ebx
f0101165:	ff 75 08             	pushl  0x8(%ebp)
f0101168:	e8 87 ff ff ff       	call   f01010f4 <page_lookup>
    if (pageInfo==NULL) return;
f010116d:	83 c4 10             	add    $0x10,%esp
f0101170:	85 c0                	test   %eax,%eax
f0101172:	74 29                	je     f010119d <page_remove+0x47>

    pageInfo->pp_ref--;
f0101174:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
f0101178:	8d 51 ff             	lea    -0x1(%ecx),%edx
f010117b:	66 89 50 04          	mov    %dx,0x4(%eax)
    if (pageInfo->pp_ref==0){
f010117f:	66 85 d2             	test   %dx,%dx
f0101182:	75 0d                	jne    f0101191 <page_remove+0x3b>
        pageInfo->pp_link = page_free_list;
f0101184:	8b 15 80 1f 17 f0    	mov    0xf0171f80,%edx
f010118a:	89 10                	mov    %edx,(%eax)
        page_free_list = pageInfo;
f010118c:	a3 80 1f 17 f0       	mov    %eax,0xf0171f80
    }
    *pte_store = 0;
f0101191:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101194:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010119a:	0f 01 3b             	invlpg (%ebx)
    tlb_invalidate(pgdir, va);


}
f010119d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01011a0:	c9                   	leave  
f01011a1:	c3                   	ret    

f01011a2 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01011a2:	55                   	push   %ebp
f01011a3:	89 e5                	mov    %esp,%ebp
f01011a5:	57                   	push   %edi
f01011a6:	56                   	push   %esi
f01011a7:	53                   	push   %ebx
f01011a8:	83 ec 10             	sub    $0x10,%esp
f01011ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01011ae:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
    // check wheather va is mapped;
    pte_t *pte_entry = pgdir_walk(pgdir, va, 1);
f01011b1:	6a 01                	push   $0x1
f01011b3:	57                   	push   %edi
f01011b4:	ff 75 08             	pushl  0x8(%ebp)
f01011b7:	e8 18 fe ff ff       	call   f0100fd4 <pgdir_walk>
    if (pte_entry==0) return -E_NO_MEM;
f01011bc:	83 c4 10             	add    $0x10,%esp
f01011bf:	85 c0                	test   %eax,%eax
f01011c1:	74 3b                	je     f01011fe <page_insert+0x5c>
f01011c3:	89 c6                	mov    %eax,%esi
    pp->pp_ref++;  // important
f01011c5:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
    // has no mem
    if (*pte_entry&PTE_P){
f01011ca:	f6 00 01             	testb  $0x1,(%eax)
f01011cd:	74 0f                	je     f01011de <page_insert+0x3c>
        page_remove(pgdir, va);
f01011cf:	83 ec 08             	sub    $0x8,%esp
f01011d2:	57                   	push   %edi
f01011d3:	ff 75 08             	pushl  0x8(%ebp)
f01011d6:	e8 7b ff ff ff       	call   f0101156 <page_remove>
f01011db:	83 c4 10             	add    $0x10,%esp
    }
    *pte_entry = page2pa(pp)|perm|PTE_P;
f01011de:	2b 1d 4c 2c 17 f0    	sub    0xf0172c4c,%ebx
f01011e4:	c1 fb 03             	sar    $0x3,%ebx
f01011e7:	c1 e3 0c             	shl    $0xc,%ebx
f01011ea:	8b 45 14             	mov    0x14(%ebp),%eax
f01011ed:	83 c8 01             	or     $0x1,%eax
f01011f0:	09 c3                	or     %eax,%ebx
f01011f2:	89 1e                	mov    %ebx,(%esi)
f01011f4:	0f 01 3f             	invlpg (%edi)
    tlb_invalidate(pgdir, va);
	return 0;
f01011f7:	b8 00 00 00 00       	mov    $0x0,%eax
f01011fc:	eb 05                	jmp    f0101203 <page_insert+0x61>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	// Fill this function in
    // check wheather va is mapped;
    pte_t *pte_entry = pgdir_walk(pgdir, va, 1);
    if (pte_entry==0) return -E_NO_MEM;
f01011fe:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
        page_remove(pgdir, va);
    }
    *pte_entry = page2pa(pp)|perm|PTE_P;
    tlb_invalidate(pgdir, va);
	return 0;
}
f0101203:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101206:	5b                   	pop    %ebx
f0101207:	5e                   	pop    %esi
f0101208:	5f                   	pop    %edi
f0101209:	5d                   	pop    %ebp
f010120a:	c3                   	ret    

f010120b <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010120b:	55                   	push   %ebp
f010120c:	89 e5                	mov    %esp,%ebp
f010120e:	57                   	push   %edi
f010120f:	56                   	push   %esi
f0101210:	53                   	push   %ebx
f0101211:	83 ec 2c             	sub    $0x2c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0101214:	b8 15 00 00 00       	mov    $0x15,%eax
f0101219:	e8 57 f8 ff ff       	call   f0100a75 <nvram_read>
f010121e:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101220:	b8 17 00 00 00       	mov    $0x17,%eax
f0101225:	e8 4b f8 ff ff       	call   f0100a75 <nvram_read>
f010122a:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010122c:	b8 34 00 00 00       	mov    $0x34,%eax
f0101231:	e8 3f f8 ff ff       	call   f0100a75 <nvram_read>
f0101236:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f0101239:	85 c0                	test   %eax,%eax
f010123b:	74 07                	je     f0101244 <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f010123d:	05 00 40 00 00       	add    $0x4000,%eax
f0101242:	eb 0b                	jmp    f010124f <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f0101244:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f010124a:	85 f6                	test   %esi,%esi
f010124c:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f010124f:	89 c2                	mov    %eax,%edx
f0101251:	c1 ea 02             	shr    $0x2,%edx
f0101254:	89 15 44 2c 17 f0    	mov    %edx,0xf0172c44
	npages_basemem = basemem / (PGSIZE / 1024);
f010125a:	89 da                	mov    %ebx,%edx
f010125c:	c1 ea 02             	shr    $0x2,%edx
f010125f:	89 15 84 1f 17 f0    	mov    %edx,0xf0171f84

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101265:	89 c2                	mov    %eax,%edx
f0101267:	29 da                	sub    %ebx,%edx
f0101269:	52                   	push   %edx
f010126a:	53                   	push   %ebx
f010126b:	50                   	push   %eax
f010126c:	68 80 50 10 f0       	push   $0xf0105080
f0101271:	e8 77 1e 00 00       	call   f01030ed <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101276:	b8 00 10 00 00       	mov    $0x1000,%eax
f010127b:	e8 bd f7 ff ff       	call   f0100a3d <boot_alloc>
f0101280:	a3 48 2c 17 f0       	mov    %eax,0xf0172c48
	memset(kern_pgdir, 0, PGSIZE);
f0101285:	83 c4 0c             	add    $0xc,%esp
f0101288:	68 00 10 00 00       	push   $0x1000
f010128d:	6a 00                	push   $0x0
f010128f:	50                   	push   %eax
f0101290:	e8 d1 31 00 00       	call   f0104466 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101295:	a1 48 2c 17 f0       	mov    0xf0172c48,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010129a:	83 c4 10             	add    $0x10,%esp
f010129d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01012a2:	77 15                	ja     f01012b9 <mem_init+0xae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01012a4:	50                   	push   %eax
f01012a5:	68 bc 50 10 f0       	push   $0xf01050bc
f01012aa:	68 92 00 00 00       	push   $0x92
f01012af:	68 7d 57 10 f0       	push   $0xf010577d
f01012b4:	e8 3d ee ff ff       	call   f01000f6 <_panic>
f01012b9:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01012bf:	83 ca 05             	or     $0x5,%edx
f01012c2:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo* )boot_alloc(sizeof(struct PageInfo)*npages);
f01012c8:	a1 44 2c 17 f0       	mov    0xf0172c44,%eax
f01012cd:	c1 e0 03             	shl    $0x3,%eax
f01012d0:	e8 68 f7 ff ff       	call   f0100a3d <boot_alloc>
f01012d5:	a3 4c 2c 17 f0       	mov    %eax,0xf0172c4c
	memset(pages, 0, sizeof(struct PageInfo)*npages);
f01012da:	83 ec 04             	sub    $0x4,%esp
f01012dd:	8b 3d 44 2c 17 f0    	mov    0xf0172c44,%edi
f01012e3:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f01012ea:	52                   	push   %edx
f01012eb:	6a 00                	push   $0x0
f01012ed:	50                   	push   %eax
f01012ee:	e8 73 31 00 00       	call   f0104466 <memset>


	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
    envs = boot_alloc(sizeof(struct Env)*NENV);
f01012f3:	b8 00 80 01 00       	mov    $0x18000,%eax
f01012f8:	e8 40 f7 ff ff       	call   f0100a3d <boot_alloc>
f01012fd:	a3 8c 1f 17 f0       	mov    %eax,0xf0171f8c
    memset(envs, 0, sizeof(struct Env)*NENV);
f0101302:	83 c4 0c             	add    $0xc,%esp
f0101305:	68 00 80 01 00       	push   $0x18000
f010130a:	6a 00                	push   $0x0
f010130c:	50                   	push   %eax
f010130d:	e8 54 31 00 00       	call   f0104466 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101312:	e8 ae fa ff ff       	call   f0100dc5 <page_init>

	check_page_free_list(1);
f0101317:	b8 01 00 00 00       	mov    $0x1,%eax
f010131c:	e8 e1 f7 ff ff       	call   f0100b02 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101321:	83 c4 10             	add    $0x10,%esp
f0101324:	83 3d 4c 2c 17 f0 00 	cmpl   $0x0,0xf0172c4c
f010132b:	75 17                	jne    f0101344 <mem_init+0x139>
		panic("'pages' is a null pointer!");
f010132d:	83 ec 04             	sub    $0x4,%esp
f0101330:	68 4d 58 10 f0       	push   $0xf010584d
f0101335:	68 a7 02 00 00       	push   $0x2a7
f010133a:	68 7d 57 10 f0       	push   $0xf010577d
f010133f:	e8 b2 ed ff ff       	call   f01000f6 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101344:	a1 80 1f 17 f0       	mov    0xf0171f80,%eax
f0101349:	bb 00 00 00 00       	mov    $0x0,%ebx
f010134e:	eb 05                	jmp    f0101355 <mem_init+0x14a>
		++nfree;
f0101350:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101353:	8b 00                	mov    (%eax),%eax
f0101355:	85 c0                	test   %eax,%eax
f0101357:	75 f7                	jne    f0101350 <mem_init+0x145>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101359:	83 ec 0c             	sub    $0xc,%esp
f010135c:	6a 00                	push   $0x0
f010135e:	e8 9d fb ff ff       	call   f0100f00 <page_alloc>
f0101363:	89 c7                	mov    %eax,%edi
f0101365:	83 c4 10             	add    $0x10,%esp
f0101368:	85 c0                	test   %eax,%eax
f010136a:	75 19                	jne    f0101385 <mem_init+0x17a>
f010136c:	68 68 58 10 f0       	push   $0xf0105868
f0101371:	68 a3 57 10 f0       	push   $0xf01057a3
f0101376:	68 af 02 00 00       	push   $0x2af
f010137b:	68 7d 57 10 f0       	push   $0xf010577d
f0101380:	e8 71 ed ff ff       	call   f01000f6 <_panic>
	assert((pp1 = page_alloc(0)));
f0101385:	83 ec 0c             	sub    $0xc,%esp
f0101388:	6a 00                	push   $0x0
f010138a:	e8 71 fb ff ff       	call   f0100f00 <page_alloc>
f010138f:	89 c6                	mov    %eax,%esi
f0101391:	83 c4 10             	add    $0x10,%esp
f0101394:	85 c0                	test   %eax,%eax
f0101396:	75 19                	jne    f01013b1 <mem_init+0x1a6>
f0101398:	68 7e 58 10 f0       	push   $0xf010587e
f010139d:	68 a3 57 10 f0       	push   $0xf01057a3
f01013a2:	68 b0 02 00 00       	push   $0x2b0
f01013a7:	68 7d 57 10 f0       	push   $0xf010577d
f01013ac:	e8 45 ed ff ff       	call   f01000f6 <_panic>
	assert((pp2 = page_alloc(0)));
f01013b1:	83 ec 0c             	sub    $0xc,%esp
f01013b4:	6a 00                	push   $0x0
f01013b6:	e8 45 fb ff ff       	call   f0100f00 <page_alloc>
f01013bb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01013be:	83 c4 10             	add    $0x10,%esp
f01013c1:	85 c0                	test   %eax,%eax
f01013c3:	75 19                	jne    f01013de <mem_init+0x1d3>
f01013c5:	68 94 58 10 f0       	push   $0xf0105894
f01013ca:	68 a3 57 10 f0       	push   $0xf01057a3
f01013cf:	68 b1 02 00 00       	push   $0x2b1
f01013d4:	68 7d 57 10 f0       	push   $0xf010577d
f01013d9:	e8 18 ed ff ff       	call   f01000f6 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01013de:	39 f7                	cmp    %esi,%edi
f01013e0:	75 19                	jne    f01013fb <mem_init+0x1f0>
f01013e2:	68 aa 58 10 f0       	push   $0xf01058aa
f01013e7:	68 a3 57 10 f0       	push   $0xf01057a3
f01013ec:	68 b4 02 00 00       	push   $0x2b4
f01013f1:	68 7d 57 10 f0       	push   $0xf010577d
f01013f6:	e8 fb ec ff ff       	call   f01000f6 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01013fb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01013fe:	39 c6                	cmp    %eax,%esi
f0101400:	74 04                	je     f0101406 <mem_init+0x1fb>
f0101402:	39 c7                	cmp    %eax,%edi
f0101404:	75 19                	jne    f010141f <mem_init+0x214>
f0101406:	68 e0 50 10 f0       	push   $0xf01050e0
f010140b:	68 a3 57 10 f0       	push   $0xf01057a3
f0101410:	68 b5 02 00 00       	push   $0x2b5
f0101415:	68 7d 57 10 f0       	push   $0xf010577d
f010141a:	e8 d7 ec ff ff       	call   f01000f6 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010141f:	8b 0d 4c 2c 17 f0    	mov    0xf0172c4c,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101425:	8b 15 44 2c 17 f0    	mov    0xf0172c44,%edx
f010142b:	c1 e2 0c             	shl    $0xc,%edx
f010142e:	89 f8                	mov    %edi,%eax
f0101430:	29 c8                	sub    %ecx,%eax
f0101432:	c1 f8 03             	sar    $0x3,%eax
f0101435:	c1 e0 0c             	shl    $0xc,%eax
f0101438:	39 d0                	cmp    %edx,%eax
f010143a:	72 19                	jb     f0101455 <mem_init+0x24a>
f010143c:	68 bc 58 10 f0       	push   $0xf01058bc
f0101441:	68 a3 57 10 f0       	push   $0xf01057a3
f0101446:	68 b6 02 00 00       	push   $0x2b6
f010144b:	68 7d 57 10 f0       	push   $0xf010577d
f0101450:	e8 a1 ec ff ff       	call   f01000f6 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101455:	89 f0                	mov    %esi,%eax
f0101457:	29 c8                	sub    %ecx,%eax
f0101459:	c1 f8 03             	sar    $0x3,%eax
f010145c:	c1 e0 0c             	shl    $0xc,%eax
f010145f:	39 c2                	cmp    %eax,%edx
f0101461:	77 19                	ja     f010147c <mem_init+0x271>
f0101463:	68 d9 58 10 f0       	push   $0xf01058d9
f0101468:	68 a3 57 10 f0       	push   $0xf01057a3
f010146d:	68 b7 02 00 00       	push   $0x2b7
f0101472:	68 7d 57 10 f0       	push   $0xf010577d
f0101477:	e8 7a ec ff ff       	call   f01000f6 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010147c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010147f:	29 c8                	sub    %ecx,%eax
f0101481:	c1 f8 03             	sar    $0x3,%eax
f0101484:	c1 e0 0c             	shl    $0xc,%eax
f0101487:	39 c2                	cmp    %eax,%edx
f0101489:	77 19                	ja     f01014a4 <mem_init+0x299>
f010148b:	68 f6 58 10 f0       	push   $0xf01058f6
f0101490:	68 a3 57 10 f0       	push   $0xf01057a3
f0101495:	68 b8 02 00 00       	push   $0x2b8
f010149a:	68 7d 57 10 f0       	push   $0xf010577d
f010149f:	e8 52 ec ff ff       	call   f01000f6 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01014a4:	a1 80 1f 17 f0       	mov    0xf0171f80,%eax
f01014a9:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01014ac:	c7 05 80 1f 17 f0 00 	movl   $0x0,0xf0171f80
f01014b3:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01014b6:	83 ec 0c             	sub    $0xc,%esp
f01014b9:	6a 00                	push   $0x0
f01014bb:	e8 40 fa ff ff       	call   f0100f00 <page_alloc>
f01014c0:	83 c4 10             	add    $0x10,%esp
f01014c3:	85 c0                	test   %eax,%eax
f01014c5:	74 19                	je     f01014e0 <mem_init+0x2d5>
f01014c7:	68 13 59 10 f0       	push   $0xf0105913
f01014cc:	68 a3 57 10 f0       	push   $0xf01057a3
f01014d1:	68 bf 02 00 00       	push   $0x2bf
f01014d6:	68 7d 57 10 f0       	push   $0xf010577d
f01014db:	e8 16 ec ff ff       	call   f01000f6 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01014e0:	83 ec 0c             	sub    $0xc,%esp
f01014e3:	57                   	push   %edi
f01014e4:	e8 87 fa ff ff       	call   f0100f70 <page_free>
	page_free(pp1);
f01014e9:	89 34 24             	mov    %esi,(%esp)
f01014ec:	e8 7f fa ff ff       	call   f0100f70 <page_free>
	page_free(pp2);
f01014f1:	83 c4 04             	add    $0x4,%esp
f01014f4:	ff 75 d4             	pushl  -0x2c(%ebp)
f01014f7:	e8 74 fa ff ff       	call   f0100f70 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01014fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101503:	e8 f8 f9 ff ff       	call   f0100f00 <page_alloc>
f0101508:	89 c6                	mov    %eax,%esi
f010150a:	83 c4 10             	add    $0x10,%esp
f010150d:	85 c0                	test   %eax,%eax
f010150f:	75 19                	jne    f010152a <mem_init+0x31f>
f0101511:	68 68 58 10 f0       	push   $0xf0105868
f0101516:	68 a3 57 10 f0       	push   $0xf01057a3
f010151b:	68 c6 02 00 00       	push   $0x2c6
f0101520:	68 7d 57 10 f0       	push   $0xf010577d
f0101525:	e8 cc eb ff ff       	call   f01000f6 <_panic>
	assert((pp1 = page_alloc(0)));
f010152a:	83 ec 0c             	sub    $0xc,%esp
f010152d:	6a 00                	push   $0x0
f010152f:	e8 cc f9 ff ff       	call   f0100f00 <page_alloc>
f0101534:	89 c7                	mov    %eax,%edi
f0101536:	83 c4 10             	add    $0x10,%esp
f0101539:	85 c0                	test   %eax,%eax
f010153b:	75 19                	jne    f0101556 <mem_init+0x34b>
f010153d:	68 7e 58 10 f0       	push   $0xf010587e
f0101542:	68 a3 57 10 f0       	push   $0xf01057a3
f0101547:	68 c7 02 00 00       	push   $0x2c7
f010154c:	68 7d 57 10 f0       	push   $0xf010577d
f0101551:	e8 a0 eb ff ff       	call   f01000f6 <_panic>
	assert((pp2 = page_alloc(0)));
f0101556:	83 ec 0c             	sub    $0xc,%esp
f0101559:	6a 00                	push   $0x0
f010155b:	e8 a0 f9 ff ff       	call   f0100f00 <page_alloc>
f0101560:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101563:	83 c4 10             	add    $0x10,%esp
f0101566:	85 c0                	test   %eax,%eax
f0101568:	75 19                	jne    f0101583 <mem_init+0x378>
f010156a:	68 94 58 10 f0       	push   $0xf0105894
f010156f:	68 a3 57 10 f0       	push   $0xf01057a3
f0101574:	68 c8 02 00 00       	push   $0x2c8
f0101579:	68 7d 57 10 f0       	push   $0xf010577d
f010157e:	e8 73 eb ff ff       	call   f01000f6 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101583:	39 fe                	cmp    %edi,%esi
f0101585:	75 19                	jne    f01015a0 <mem_init+0x395>
f0101587:	68 aa 58 10 f0       	push   $0xf01058aa
f010158c:	68 a3 57 10 f0       	push   $0xf01057a3
f0101591:	68 ca 02 00 00       	push   $0x2ca
f0101596:	68 7d 57 10 f0       	push   $0xf010577d
f010159b:	e8 56 eb ff ff       	call   f01000f6 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015a0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01015a3:	39 c7                	cmp    %eax,%edi
f01015a5:	74 04                	je     f01015ab <mem_init+0x3a0>
f01015a7:	39 c6                	cmp    %eax,%esi
f01015a9:	75 19                	jne    f01015c4 <mem_init+0x3b9>
f01015ab:	68 e0 50 10 f0       	push   $0xf01050e0
f01015b0:	68 a3 57 10 f0       	push   $0xf01057a3
f01015b5:	68 cb 02 00 00       	push   $0x2cb
f01015ba:	68 7d 57 10 f0       	push   $0xf010577d
f01015bf:	e8 32 eb ff ff       	call   f01000f6 <_panic>
	assert(!page_alloc(0));
f01015c4:	83 ec 0c             	sub    $0xc,%esp
f01015c7:	6a 00                	push   $0x0
f01015c9:	e8 32 f9 ff ff       	call   f0100f00 <page_alloc>
f01015ce:	83 c4 10             	add    $0x10,%esp
f01015d1:	85 c0                	test   %eax,%eax
f01015d3:	74 19                	je     f01015ee <mem_init+0x3e3>
f01015d5:	68 13 59 10 f0       	push   $0xf0105913
f01015da:	68 a3 57 10 f0       	push   $0xf01057a3
f01015df:	68 cc 02 00 00       	push   $0x2cc
f01015e4:	68 7d 57 10 f0       	push   $0xf010577d
f01015e9:	e8 08 eb ff ff       	call   f01000f6 <_panic>
f01015ee:	89 f0                	mov    %esi,%eax
f01015f0:	2b 05 4c 2c 17 f0    	sub    0xf0172c4c,%eax
f01015f6:	c1 f8 03             	sar    $0x3,%eax
f01015f9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015fc:	89 c2                	mov    %eax,%edx
f01015fe:	c1 ea 0c             	shr    $0xc,%edx
f0101601:	3b 15 44 2c 17 f0    	cmp    0xf0172c44,%edx
f0101607:	72 12                	jb     f010161b <mem_init+0x410>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101609:	50                   	push   %eax
f010160a:	68 30 4f 10 f0       	push   $0xf0104f30
f010160f:	6a 56                	push   $0x56
f0101611:	68 89 57 10 f0       	push   $0xf0105789
f0101616:	e8 db ea ff ff       	call   f01000f6 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f010161b:	83 ec 04             	sub    $0x4,%esp
f010161e:	68 00 10 00 00       	push   $0x1000
f0101623:	6a 01                	push   $0x1
f0101625:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010162a:	50                   	push   %eax
f010162b:	e8 36 2e 00 00       	call   f0104466 <memset>
	page_free(pp0);
f0101630:	89 34 24             	mov    %esi,(%esp)
f0101633:	e8 38 f9 ff ff       	call   f0100f70 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101638:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010163f:	e8 bc f8 ff ff       	call   f0100f00 <page_alloc>
f0101644:	83 c4 10             	add    $0x10,%esp
f0101647:	85 c0                	test   %eax,%eax
f0101649:	75 19                	jne    f0101664 <mem_init+0x459>
f010164b:	68 22 59 10 f0       	push   $0xf0105922
f0101650:	68 a3 57 10 f0       	push   $0xf01057a3
f0101655:	68 d1 02 00 00       	push   $0x2d1
f010165a:	68 7d 57 10 f0       	push   $0xf010577d
f010165f:	e8 92 ea ff ff       	call   f01000f6 <_panic>
	assert(pp && pp0 == pp);
f0101664:	39 c6                	cmp    %eax,%esi
f0101666:	74 19                	je     f0101681 <mem_init+0x476>
f0101668:	68 40 59 10 f0       	push   $0xf0105940
f010166d:	68 a3 57 10 f0       	push   $0xf01057a3
f0101672:	68 d2 02 00 00       	push   $0x2d2
f0101677:	68 7d 57 10 f0       	push   $0xf010577d
f010167c:	e8 75 ea ff ff       	call   f01000f6 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101681:	89 f0                	mov    %esi,%eax
f0101683:	2b 05 4c 2c 17 f0    	sub    0xf0172c4c,%eax
f0101689:	c1 f8 03             	sar    $0x3,%eax
f010168c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010168f:	89 c2                	mov    %eax,%edx
f0101691:	c1 ea 0c             	shr    $0xc,%edx
f0101694:	3b 15 44 2c 17 f0    	cmp    0xf0172c44,%edx
f010169a:	72 12                	jb     f01016ae <mem_init+0x4a3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010169c:	50                   	push   %eax
f010169d:	68 30 4f 10 f0       	push   $0xf0104f30
f01016a2:	6a 56                	push   $0x56
f01016a4:	68 89 57 10 f0       	push   $0xf0105789
f01016a9:	e8 48 ea ff ff       	call   f01000f6 <_panic>
f01016ae:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f01016b4:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01016ba:	80 38 00             	cmpb   $0x0,(%eax)
f01016bd:	74 19                	je     f01016d8 <mem_init+0x4cd>
f01016bf:	68 50 59 10 f0       	push   $0xf0105950
f01016c4:	68 a3 57 10 f0       	push   $0xf01057a3
f01016c9:	68 d5 02 00 00       	push   $0x2d5
f01016ce:	68 7d 57 10 f0       	push   $0xf010577d
f01016d3:	e8 1e ea ff ff       	call   f01000f6 <_panic>
f01016d8:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01016db:	39 d0                	cmp    %edx,%eax
f01016dd:	75 db                	jne    f01016ba <mem_init+0x4af>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01016df:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01016e2:	a3 80 1f 17 f0       	mov    %eax,0xf0171f80

	// free the pages we took
	page_free(pp0);
f01016e7:	83 ec 0c             	sub    $0xc,%esp
f01016ea:	56                   	push   %esi
f01016eb:	e8 80 f8 ff ff       	call   f0100f70 <page_free>
	page_free(pp1);
f01016f0:	89 3c 24             	mov    %edi,(%esp)
f01016f3:	e8 78 f8 ff ff       	call   f0100f70 <page_free>
	page_free(pp2);
f01016f8:	83 c4 04             	add    $0x4,%esp
f01016fb:	ff 75 d4             	pushl  -0x2c(%ebp)
f01016fe:	e8 6d f8 ff ff       	call   f0100f70 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101703:	a1 80 1f 17 f0       	mov    0xf0171f80,%eax
f0101708:	83 c4 10             	add    $0x10,%esp
f010170b:	eb 05                	jmp    f0101712 <mem_init+0x507>
		--nfree;
f010170d:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101710:	8b 00                	mov    (%eax),%eax
f0101712:	85 c0                	test   %eax,%eax
f0101714:	75 f7                	jne    f010170d <mem_init+0x502>
		--nfree;
	assert(nfree == 0);
f0101716:	85 db                	test   %ebx,%ebx
f0101718:	74 19                	je     f0101733 <mem_init+0x528>
f010171a:	68 5a 59 10 f0       	push   $0xf010595a
f010171f:	68 a3 57 10 f0       	push   $0xf01057a3
f0101724:	68 e2 02 00 00       	push   $0x2e2
f0101729:	68 7d 57 10 f0       	push   $0xf010577d
f010172e:	e8 c3 e9 ff ff       	call   f01000f6 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101733:	83 ec 0c             	sub    $0xc,%esp
f0101736:	68 00 51 10 f0       	push   $0xf0105100
f010173b:	e8 ad 19 00 00       	call   f01030ed <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101740:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101747:	e8 b4 f7 ff ff       	call   f0100f00 <page_alloc>
f010174c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010174f:	83 c4 10             	add    $0x10,%esp
f0101752:	85 c0                	test   %eax,%eax
f0101754:	75 19                	jne    f010176f <mem_init+0x564>
f0101756:	68 68 58 10 f0       	push   $0xf0105868
f010175b:	68 a3 57 10 f0       	push   $0xf01057a3
f0101760:	68 40 03 00 00       	push   $0x340
f0101765:	68 7d 57 10 f0       	push   $0xf010577d
f010176a:	e8 87 e9 ff ff       	call   f01000f6 <_panic>
	assert((pp1 = page_alloc(0)));
f010176f:	83 ec 0c             	sub    $0xc,%esp
f0101772:	6a 00                	push   $0x0
f0101774:	e8 87 f7 ff ff       	call   f0100f00 <page_alloc>
f0101779:	89 c3                	mov    %eax,%ebx
f010177b:	83 c4 10             	add    $0x10,%esp
f010177e:	85 c0                	test   %eax,%eax
f0101780:	75 19                	jne    f010179b <mem_init+0x590>
f0101782:	68 7e 58 10 f0       	push   $0xf010587e
f0101787:	68 a3 57 10 f0       	push   $0xf01057a3
f010178c:	68 41 03 00 00       	push   $0x341
f0101791:	68 7d 57 10 f0       	push   $0xf010577d
f0101796:	e8 5b e9 ff ff       	call   f01000f6 <_panic>
	assert((pp2 = page_alloc(0)));
f010179b:	83 ec 0c             	sub    $0xc,%esp
f010179e:	6a 00                	push   $0x0
f01017a0:	e8 5b f7 ff ff       	call   f0100f00 <page_alloc>
f01017a5:	89 c6                	mov    %eax,%esi
f01017a7:	83 c4 10             	add    $0x10,%esp
f01017aa:	85 c0                	test   %eax,%eax
f01017ac:	75 19                	jne    f01017c7 <mem_init+0x5bc>
f01017ae:	68 94 58 10 f0       	push   $0xf0105894
f01017b3:	68 a3 57 10 f0       	push   $0xf01057a3
f01017b8:	68 42 03 00 00       	push   $0x342
f01017bd:	68 7d 57 10 f0       	push   $0xf010577d
f01017c2:	e8 2f e9 ff ff       	call   f01000f6 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01017c7:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01017ca:	75 19                	jne    f01017e5 <mem_init+0x5da>
f01017cc:	68 aa 58 10 f0       	push   $0xf01058aa
f01017d1:	68 a3 57 10 f0       	push   $0xf01057a3
f01017d6:	68 45 03 00 00       	push   $0x345
f01017db:	68 7d 57 10 f0       	push   $0xf010577d
f01017e0:	e8 11 e9 ff ff       	call   f01000f6 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017e5:	39 c3                	cmp    %eax,%ebx
f01017e7:	74 05                	je     f01017ee <mem_init+0x5e3>
f01017e9:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01017ec:	75 19                	jne    f0101807 <mem_init+0x5fc>
f01017ee:	68 e0 50 10 f0       	push   $0xf01050e0
f01017f3:	68 a3 57 10 f0       	push   $0xf01057a3
f01017f8:	68 46 03 00 00       	push   $0x346
f01017fd:	68 7d 57 10 f0       	push   $0xf010577d
f0101802:	e8 ef e8 ff ff       	call   f01000f6 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101807:	a1 80 1f 17 f0       	mov    0xf0171f80,%eax
f010180c:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010180f:	c7 05 80 1f 17 f0 00 	movl   $0x0,0xf0171f80
f0101816:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101819:	83 ec 0c             	sub    $0xc,%esp
f010181c:	6a 00                	push   $0x0
f010181e:	e8 dd f6 ff ff       	call   f0100f00 <page_alloc>
f0101823:	83 c4 10             	add    $0x10,%esp
f0101826:	85 c0                	test   %eax,%eax
f0101828:	74 19                	je     f0101843 <mem_init+0x638>
f010182a:	68 13 59 10 f0       	push   $0xf0105913
f010182f:	68 a3 57 10 f0       	push   $0xf01057a3
f0101834:	68 4d 03 00 00       	push   $0x34d
f0101839:	68 7d 57 10 f0       	push   $0xf010577d
f010183e:	e8 b3 e8 ff ff       	call   f01000f6 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101843:	83 ec 04             	sub    $0x4,%esp
f0101846:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101849:	50                   	push   %eax
f010184a:	6a 00                	push   $0x0
f010184c:	ff 35 48 2c 17 f0    	pushl  0xf0172c48
f0101852:	e8 9d f8 ff ff       	call   f01010f4 <page_lookup>
f0101857:	83 c4 10             	add    $0x10,%esp
f010185a:	85 c0                	test   %eax,%eax
f010185c:	74 19                	je     f0101877 <mem_init+0x66c>
f010185e:	68 20 51 10 f0       	push   $0xf0105120
f0101863:	68 a3 57 10 f0       	push   $0xf01057a3
f0101868:	68 50 03 00 00       	push   $0x350
f010186d:	68 7d 57 10 f0       	push   $0xf010577d
f0101872:	e8 7f e8 ff ff       	call   f01000f6 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101877:	6a 02                	push   $0x2
f0101879:	6a 00                	push   $0x0
f010187b:	53                   	push   %ebx
f010187c:	ff 35 48 2c 17 f0    	pushl  0xf0172c48
f0101882:	e8 1b f9 ff ff       	call   f01011a2 <page_insert>
f0101887:	83 c4 10             	add    $0x10,%esp
f010188a:	85 c0                	test   %eax,%eax
f010188c:	78 19                	js     f01018a7 <mem_init+0x69c>
f010188e:	68 58 51 10 f0       	push   $0xf0105158
f0101893:	68 a3 57 10 f0       	push   $0xf01057a3
f0101898:	68 53 03 00 00       	push   $0x353
f010189d:	68 7d 57 10 f0       	push   $0xf010577d
f01018a2:	e8 4f e8 ff ff       	call   f01000f6 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01018a7:	83 ec 0c             	sub    $0xc,%esp
f01018aa:	ff 75 d4             	pushl  -0x2c(%ebp)
f01018ad:	e8 be f6 ff ff       	call   f0100f70 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01018b2:	6a 02                	push   $0x2
f01018b4:	6a 00                	push   $0x0
f01018b6:	53                   	push   %ebx
f01018b7:	ff 35 48 2c 17 f0    	pushl  0xf0172c48
f01018bd:	e8 e0 f8 ff ff       	call   f01011a2 <page_insert>
f01018c2:	83 c4 20             	add    $0x20,%esp
f01018c5:	85 c0                	test   %eax,%eax
f01018c7:	74 19                	je     f01018e2 <mem_init+0x6d7>
f01018c9:	68 88 51 10 f0       	push   $0xf0105188
f01018ce:	68 a3 57 10 f0       	push   $0xf01057a3
f01018d3:	68 57 03 00 00       	push   $0x357
f01018d8:	68 7d 57 10 f0       	push   $0xf010577d
f01018dd:	e8 14 e8 ff ff       	call   f01000f6 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01018e2:	8b 3d 48 2c 17 f0    	mov    0xf0172c48,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01018e8:	a1 4c 2c 17 f0       	mov    0xf0172c4c,%eax
f01018ed:	89 c1                	mov    %eax,%ecx
f01018ef:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01018f2:	8b 17                	mov    (%edi),%edx
f01018f4:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01018fa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01018fd:	29 c8                	sub    %ecx,%eax
f01018ff:	c1 f8 03             	sar    $0x3,%eax
f0101902:	c1 e0 0c             	shl    $0xc,%eax
f0101905:	39 c2                	cmp    %eax,%edx
f0101907:	74 19                	je     f0101922 <mem_init+0x717>
f0101909:	68 b8 51 10 f0       	push   $0xf01051b8
f010190e:	68 a3 57 10 f0       	push   $0xf01057a3
f0101913:	68 58 03 00 00       	push   $0x358
f0101918:	68 7d 57 10 f0       	push   $0xf010577d
f010191d:	e8 d4 e7 ff ff       	call   f01000f6 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101922:	ba 00 00 00 00       	mov    $0x0,%edx
f0101927:	89 f8                	mov    %edi,%eax
f0101929:	e8 70 f1 ff ff       	call   f0100a9e <check_va2pa>
f010192e:	89 da                	mov    %ebx,%edx
f0101930:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101933:	c1 fa 03             	sar    $0x3,%edx
f0101936:	c1 e2 0c             	shl    $0xc,%edx
f0101939:	39 d0                	cmp    %edx,%eax
f010193b:	74 19                	je     f0101956 <mem_init+0x74b>
f010193d:	68 e0 51 10 f0       	push   $0xf01051e0
f0101942:	68 a3 57 10 f0       	push   $0xf01057a3
f0101947:	68 59 03 00 00       	push   $0x359
f010194c:	68 7d 57 10 f0       	push   $0xf010577d
f0101951:	e8 a0 e7 ff ff       	call   f01000f6 <_panic>
	assert(pp1->pp_ref == 1);
f0101956:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010195b:	74 19                	je     f0101976 <mem_init+0x76b>
f010195d:	68 65 59 10 f0       	push   $0xf0105965
f0101962:	68 a3 57 10 f0       	push   $0xf01057a3
f0101967:	68 5a 03 00 00       	push   $0x35a
f010196c:	68 7d 57 10 f0       	push   $0xf010577d
f0101971:	e8 80 e7 ff ff       	call   f01000f6 <_panic>
	assert(pp0->pp_ref == 1);
f0101976:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101979:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010197e:	74 19                	je     f0101999 <mem_init+0x78e>
f0101980:	68 76 59 10 f0       	push   $0xf0105976
f0101985:	68 a3 57 10 f0       	push   $0xf01057a3
f010198a:	68 5b 03 00 00       	push   $0x35b
f010198f:	68 7d 57 10 f0       	push   $0xf010577d
f0101994:	e8 5d e7 ff ff       	call   f01000f6 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101999:	6a 02                	push   $0x2
f010199b:	68 00 10 00 00       	push   $0x1000
f01019a0:	56                   	push   %esi
f01019a1:	57                   	push   %edi
f01019a2:	e8 fb f7 ff ff       	call   f01011a2 <page_insert>
f01019a7:	83 c4 10             	add    $0x10,%esp
f01019aa:	85 c0                	test   %eax,%eax
f01019ac:	74 19                	je     f01019c7 <mem_init+0x7bc>
f01019ae:	68 10 52 10 f0       	push   $0xf0105210
f01019b3:	68 a3 57 10 f0       	push   $0xf01057a3
f01019b8:	68 5e 03 00 00       	push   $0x35e
f01019bd:	68 7d 57 10 f0       	push   $0xf010577d
f01019c2:	e8 2f e7 ff ff       	call   f01000f6 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01019c7:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019cc:	a1 48 2c 17 f0       	mov    0xf0172c48,%eax
f01019d1:	e8 c8 f0 ff ff       	call   f0100a9e <check_va2pa>
f01019d6:	89 f2                	mov    %esi,%edx
f01019d8:	2b 15 4c 2c 17 f0    	sub    0xf0172c4c,%edx
f01019de:	c1 fa 03             	sar    $0x3,%edx
f01019e1:	c1 e2 0c             	shl    $0xc,%edx
f01019e4:	39 d0                	cmp    %edx,%eax
f01019e6:	74 19                	je     f0101a01 <mem_init+0x7f6>
f01019e8:	68 4c 52 10 f0       	push   $0xf010524c
f01019ed:	68 a3 57 10 f0       	push   $0xf01057a3
f01019f2:	68 5f 03 00 00       	push   $0x35f
f01019f7:	68 7d 57 10 f0       	push   $0xf010577d
f01019fc:	e8 f5 e6 ff ff       	call   f01000f6 <_panic>
	assert(pp2->pp_ref == 1);
f0101a01:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a06:	74 19                	je     f0101a21 <mem_init+0x816>
f0101a08:	68 87 59 10 f0       	push   $0xf0105987
f0101a0d:	68 a3 57 10 f0       	push   $0xf01057a3
f0101a12:	68 60 03 00 00       	push   $0x360
f0101a17:	68 7d 57 10 f0       	push   $0xf010577d
f0101a1c:	e8 d5 e6 ff ff       	call   f01000f6 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101a21:	83 ec 0c             	sub    $0xc,%esp
f0101a24:	6a 00                	push   $0x0
f0101a26:	e8 d5 f4 ff ff       	call   f0100f00 <page_alloc>
f0101a2b:	83 c4 10             	add    $0x10,%esp
f0101a2e:	85 c0                	test   %eax,%eax
f0101a30:	74 19                	je     f0101a4b <mem_init+0x840>
f0101a32:	68 13 59 10 f0       	push   $0xf0105913
f0101a37:	68 a3 57 10 f0       	push   $0xf01057a3
f0101a3c:	68 63 03 00 00       	push   $0x363
f0101a41:	68 7d 57 10 f0       	push   $0xf010577d
f0101a46:	e8 ab e6 ff ff       	call   f01000f6 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a4b:	6a 02                	push   $0x2
f0101a4d:	68 00 10 00 00       	push   $0x1000
f0101a52:	56                   	push   %esi
f0101a53:	ff 35 48 2c 17 f0    	pushl  0xf0172c48
f0101a59:	e8 44 f7 ff ff       	call   f01011a2 <page_insert>
f0101a5e:	83 c4 10             	add    $0x10,%esp
f0101a61:	85 c0                	test   %eax,%eax
f0101a63:	74 19                	je     f0101a7e <mem_init+0x873>
f0101a65:	68 10 52 10 f0       	push   $0xf0105210
f0101a6a:	68 a3 57 10 f0       	push   $0xf01057a3
f0101a6f:	68 66 03 00 00       	push   $0x366
f0101a74:	68 7d 57 10 f0       	push   $0xf010577d
f0101a79:	e8 78 e6 ff ff       	call   f01000f6 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a7e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a83:	a1 48 2c 17 f0       	mov    0xf0172c48,%eax
f0101a88:	e8 11 f0 ff ff       	call   f0100a9e <check_va2pa>
f0101a8d:	89 f2                	mov    %esi,%edx
f0101a8f:	2b 15 4c 2c 17 f0    	sub    0xf0172c4c,%edx
f0101a95:	c1 fa 03             	sar    $0x3,%edx
f0101a98:	c1 e2 0c             	shl    $0xc,%edx
f0101a9b:	39 d0                	cmp    %edx,%eax
f0101a9d:	74 19                	je     f0101ab8 <mem_init+0x8ad>
f0101a9f:	68 4c 52 10 f0       	push   $0xf010524c
f0101aa4:	68 a3 57 10 f0       	push   $0xf01057a3
f0101aa9:	68 67 03 00 00       	push   $0x367
f0101aae:	68 7d 57 10 f0       	push   $0xf010577d
f0101ab3:	e8 3e e6 ff ff       	call   f01000f6 <_panic>
	assert(pp2->pp_ref == 1);
f0101ab8:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101abd:	74 19                	je     f0101ad8 <mem_init+0x8cd>
f0101abf:	68 87 59 10 f0       	push   $0xf0105987
f0101ac4:	68 a3 57 10 f0       	push   $0xf01057a3
f0101ac9:	68 68 03 00 00       	push   $0x368
f0101ace:	68 7d 57 10 f0       	push   $0xf010577d
f0101ad3:	e8 1e e6 ff ff       	call   f01000f6 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101ad8:	83 ec 0c             	sub    $0xc,%esp
f0101adb:	6a 00                	push   $0x0
f0101add:	e8 1e f4 ff ff       	call   f0100f00 <page_alloc>
f0101ae2:	83 c4 10             	add    $0x10,%esp
f0101ae5:	85 c0                	test   %eax,%eax
f0101ae7:	74 19                	je     f0101b02 <mem_init+0x8f7>
f0101ae9:	68 13 59 10 f0       	push   $0xf0105913
f0101aee:	68 a3 57 10 f0       	push   $0xf01057a3
f0101af3:	68 6c 03 00 00       	push   $0x36c
f0101af8:	68 7d 57 10 f0       	push   $0xf010577d
f0101afd:	e8 f4 e5 ff ff       	call   f01000f6 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101b02:	8b 15 48 2c 17 f0    	mov    0xf0172c48,%edx
f0101b08:	8b 02                	mov    (%edx),%eax
f0101b0a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101b0f:	89 c1                	mov    %eax,%ecx
f0101b11:	c1 e9 0c             	shr    $0xc,%ecx
f0101b14:	3b 0d 44 2c 17 f0    	cmp    0xf0172c44,%ecx
f0101b1a:	72 15                	jb     f0101b31 <mem_init+0x926>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101b1c:	50                   	push   %eax
f0101b1d:	68 30 4f 10 f0       	push   $0xf0104f30
f0101b22:	68 6f 03 00 00       	push   $0x36f
f0101b27:	68 7d 57 10 f0       	push   $0xf010577d
f0101b2c:	e8 c5 e5 ff ff       	call   f01000f6 <_panic>
f0101b31:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101b36:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101b39:	83 ec 04             	sub    $0x4,%esp
f0101b3c:	6a 00                	push   $0x0
f0101b3e:	68 00 10 00 00       	push   $0x1000
f0101b43:	52                   	push   %edx
f0101b44:	e8 8b f4 ff ff       	call   f0100fd4 <pgdir_walk>
f0101b49:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101b4c:	8d 57 04             	lea    0x4(%edi),%edx
f0101b4f:	83 c4 10             	add    $0x10,%esp
f0101b52:	39 d0                	cmp    %edx,%eax
f0101b54:	74 19                	je     f0101b6f <mem_init+0x964>
f0101b56:	68 7c 52 10 f0       	push   $0xf010527c
f0101b5b:	68 a3 57 10 f0       	push   $0xf01057a3
f0101b60:	68 70 03 00 00       	push   $0x370
f0101b65:	68 7d 57 10 f0       	push   $0xf010577d
f0101b6a:	e8 87 e5 ff ff       	call   f01000f6 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101b6f:	6a 06                	push   $0x6
f0101b71:	68 00 10 00 00       	push   $0x1000
f0101b76:	56                   	push   %esi
f0101b77:	ff 35 48 2c 17 f0    	pushl  0xf0172c48
f0101b7d:	e8 20 f6 ff ff       	call   f01011a2 <page_insert>
f0101b82:	83 c4 10             	add    $0x10,%esp
f0101b85:	85 c0                	test   %eax,%eax
f0101b87:	74 19                	je     f0101ba2 <mem_init+0x997>
f0101b89:	68 bc 52 10 f0       	push   $0xf01052bc
f0101b8e:	68 a3 57 10 f0       	push   $0xf01057a3
f0101b93:	68 73 03 00 00       	push   $0x373
f0101b98:	68 7d 57 10 f0       	push   $0xf010577d
f0101b9d:	e8 54 e5 ff ff       	call   f01000f6 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ba2:	8b 3d 48 2c 17 f0    	mov    0xf0172c48,%edi
f0101ba8:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bad:	89 f8                	mov    %edi,%eax
f0101baf:	e8 ea ee ff ff       	call   f0100a9e <check_va2pa>
f0101bb4:	89 f2                	mov    %esi,%edx
f0101bb6:	2b 15 4c 2c 17 f0    	sub    0xf0172c4c,%edx
f0101bbc:	c1 fa 03             	sar    $0x3,%edx
f0101bbf:	c1 e2 0c             	shl    $0xc,%edx
f0101bc2:	39 d0                	cmp    %edx,%eax
f0101bc4:	74 19                	je     f0101bdf <mem_init+0x9d4>
f0101bc6:	68 4c 52 10 f0       	push   $0xf010524c
f0101bcb:	68 a3 57 10 f0       	push   $0xf01057a3
f0101bd0:	68 74 03 00 00       	push   $0x374
f0101bd5:	68 7d 57 10 f0       	push   $0xf010577d
f0101bda:	e8 17 e5 ff ff       	call   f01000f6 <_panic>
	assert(pp2->pp_ref == 1);
f0101bdf:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101be4:	74 19                	je     f0101bff <mem_init+0x9f4>
f0101be6:	68 87 59 10 f0       	push   $0xf0105987
f0101beb:	68 a3 57 10 f0       	push   $0xf01057a3
f0101bf0:	68 75 03 00 00       	push   $0x375
f0101bf5:	68 7d 57 10 f0       	push   $0xf010577d
f0101bfa:	e8 f7 e4 ff ff       	call   f01000f6 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101bff:	83 ec 04             	sub    $0x4,%esp
f0101c02:	6a 00                	push   $0x0
f0101c04:	68 00 10 00 00       	push   $0x1000
f0101c09:	57                   	push   %edi
f0101c0a:	e8 c5 f3 ff ff       	call   f0100fd4 <pgdir_walk>
f0101c0f:	83 c4 10             	add    $0x10,%esp
f0101c12:	f6 00 04             	testb  $0x4,(%eax)
f0101c15:	75 19                	jne    f0101c30 <mem_init+0xa25>
f0101c17:	68 fc 52 10 f0       	push   $0xf01052fc
f0101c1c:	68 a3 57 10 f0       	push   $0xf01057a3
f0101c21:	68 76 03 00 00       	push   $0x376
f0101c26:	68 7d 57 10 f0       	push   $0xf010577d
f0101c2b:	e8 c6 e4 ff ff       	call   f01000f6 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101c30:	a1 48 2c 17 f0       	mov    0xf0172c48,%eax
f0101c35:	f6 00 04             	testb  $0x4,(%eax)
f0101c38:	75 19                	jne    f0101c53 <mem_init+0xa48>
f0101c3a:	68 98 59 10 f0       	push   $0xf0105998
f0101c3f:	68 a3 57 10 f0       	push   $0xf01057a3
f0101c44:	68 77 03 00 00       	push   $0x377
f0101c49:	68 7d 57 10 f0       	push   $0xf010577d
f0101c4e:	e8 a3 e4 ff ff       	call   f01000f6 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c53:	6a 02                	push   $0x2
f0101c55:	68 00 10 00 00       	push   $0x1000
f0101c5a:	56                   	push   %esi
f0101c5b:	50                   	push   %eax
f0101c5c:	e8 41 f5 ff ff       	call   f01011a2 <page_insert>
f0101c61:	83 c4 10             	add    $0x10,%esp
f0101c64:	85 c0                	test   %eax,%eax
f0101c66:	74 19                	je     f0101c81 <mem_init+0xa76>
f0101c68:	68 10 52 10 f0       	push   $0xf0105210
f0101c6d:	68 a3 57 10 f0       	push   $0xf01057a3
f0101c72:	68 7a 03 00 00       	push   $0x37a
f0101c77:	68 7d 57 10 f0       	push   $0xf010577d
f0101c7c:	e8 75 e4 ff ff       	call   f01000f6 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101c81:	83 ec 04             	sub    $0x4,%esp
f0101c84:	6a 00                	push   $0x0
f0101c86:	68 00 10 00 00       	push   $0x1000
f0101c8b:	ff 35 48 2c 17 f0    	pushl  0xf0172c48
f0101c91:	e8 3e f3 ff ff       	call   f0100fd4 <pgdir_walk>
f0101c96:	83 c4 10             	add    $0x10,%esp
f0101c99:	f6 00 02             	testb  $0x2,(%eax)
f0101c9c:	75 19                	jne    f0101cb7 <mem_init+0xaac>
f0101c9e:	68 30 53 10 f0       	push   $0xf0105330
f0101ca3:	68 a3 57 10 f0       	push   $0xf01057a3
f0101ca8:	68 7b 03 00 00       	push   $0x37b
f0101cad:	68 7d 57 10 f0       	push   $0xf010577d
f0101cb2:	e8 3f e4 ff ff       	call   f01000f6 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101cb7:	83 ec 04             	sub    $0x4,%esp
f0101cba:	6a 00                	push   $0x0
f0101cbc:	68 00 10 00 00       	push   $0x1000
f0101cc1:	ff 35 48 2c 17 f0    	pushl  0xf0172c48
f0101cc7:	e8 08 f3 ff ff       	call   f0100fd4 <pgdir_walk>
f0101ccc:	83 c4 10             	add    $0x10,%esp
f0101ccf:	f6 00 04             	testb  $0x4,(%eax)
f0101cd2:	74 19                	je     f0101ced <mem_init+0xae2>
f0101cd4:	68 64 53 10 f0       	push   $0xf0105364
f0101cd9:	68 a3 57 10 f0       	push   $0xf01057a3
f0101cde:	68 7c 03 00 00       	push   $0x37c
f0101ce3:	68 7d 57 10 f0       	push   $0xf010577d
f0101ce8:	e8 09 e4 ff ff       	call   f01000f6 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101ced:	6a 02                	push   $0x2
f0101cef:	68 00 00 40 00       	push   $0x400000
f0101cf4:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101cf7:	ff 35 48 2c 17 f0    	pushl  0xf0172c48
f0101cfd:	e8 a0 f4 ff ff       	call   f01011a2 <page_insert>
f0101d02:	83 c4 10             	add    $0x10,%esp
f0101d05:	85 c0                	test   %eax,%eax
f0101d07:	78 19                	js     f0101d22 <mem_init+0xb17>
f0101d09:	68 9c 53 10 f0       	push   $0xf010539c
f0101d0e:	68 a3 57 10 f0       	push   $0xf01057a3
f0101d13:	68 7f 03 00 00       	push   $0x37f
f0101d18:	68 7d 57 10 f0       	push   $0xf010577d
f0101d1d:	e8 d4 e3 ff ff       	call   f01000f6 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101d22:	6a 02                	push   $0x2
f0101d24:	68 00 10 00 00       	push   $0x1000
f0101d29:	53                   	push   %ebx
f0101d2a:	ff 35 48 2c 17 f0    	pushl  0xf0172c48
f0101d30:	e8 6d f4 ff ff       	call   f01011a2 <page_insert>
f0101d35:	83 c4 10             	add    $0x10,%esp
f0101d38:	85 c0                	test   %eax,%eax
f0101d3a:	74 19                	je     f0101d55 <mem_init+0xb4a>
f0101d3c:	68 d4 53 10 f0       	push   $0xf01053d4
f0101d41:	68 a3 57 10 f0       	push   $0xf01057a3
f0101d46:	68 82 03 00 00       	push   $0x382
f0101d4b:	68 7d 57 10 f0       	push   $0xf010577d
f0101d50:	e8 a1 e3 ff ff       	call   f01000f6 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101d55:	83 ec 04             	sub    $0x4,%esp
f0101d58:	6a 00                	push   $0x0
f0101d5a:	68 00 10 00 00       	push   $0x1000
f0101d5f:	ff 35 48 2c 17 f0    	pushl  0xf0172c48
f0101d65:	e8 6a f2 ff ff       	call   f0100fd4 <pgdir_walk>
f0101d6a:	83 c4 10             	add    $0x10,%esp
f0101d6d:	f6 00 04             	testb  $0x4,(%eax)
f0101d70:	74 19                	je     f0101d8b <mem_init+0xb80>
f0101d72:	68 64 53 10 f0       	push   $0xf0105364
f0101d77:	68 a3 57 10 f0       	push   $0xf01057a3
f0101d7c:	68 83 03 00 00       	push   $0x383
f0101d81:	68 7d 57 10 f0       	push   $0xf010577d
f0101d86:	e8 6b e3 ff ff       	call   f01000f6 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101d8b:	8b 3d 48 2c 17 f0    	mov    0xf0172c48,%edi
f0101d91:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d96:	89 f8                	mov    %edi,%eax
f0101d98:	e8 01 ed ff ff       	call   f0100a9e <check_va2pa>
f0101d9d:	89 c1                	mov    %eax,%ecx
f0101d9f:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101da2:	89 d8                	mov    %ebx,%eax
f0101da4:	2b 05 4c 2c 17 f0    	sub    0xf0172c4c,%eax
f0101daa:	c1 f8 03             	sar    $0x3,%eax
f0101dad:	c1 e0 0c             	shl    $0xc,%eax
f0101db0:	39 c1                	cmp    %eax,%ecx
f0101db2:	74 19                	je     f0101dcd <mem_init+0xbc2>
f0101db4:	68 10 54 10 f0       	push   $0xf0105410
f0101db9:	68 a3 57 10 f0       	push   $0xf01057a3
f0101dbe:	68 86 03 00 00       	push   $0x386
f0101dc3:	68 7d 57 10 f0       	push   $0xf010577d
f0101dc8:	e8 29 e3 ff ff       	call   f01000f6 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101dcd:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101dd2:	89 f8                	mov    %edi,%eax
f0101dd4:	e8 c5 ec ff ff       	call   f0100a9e <check_va2pa>
f0101dd9:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101ddc:	74 19                	je     f0101df7 <mem_init+0xbec>
f0101dde:	68 3c 54 10 f0       	push   $0xf010543c
f0101de3:	68 a3 57 10 f0       	push   $0xf01057a3
f0101de8:	68 87 03 00 00       	push   $0x387
f0101ded:	68 7d 57 10 f0       	push   $0xf010577d
f0101df2:	e8 ff e2 ff ff       	call   f01000f6 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101df7:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101dfc:	74 19                	je     f0101e17 <mem_init+0xc0c>
f0101dfe:	68 ae 59 10 f0       	push   $0xf01059ae
f0101e03:	68 a3 57 10 f0       	push   $0xf01057a3
f0101e08:	68 89 03 00 00       	push   $0x389
f0101e0d:	68 7d 57 10 f0       	push   $0xf010577d
f0101e12:	e8 df e2 ff ff       	call   f01000f6 <_panic>
	assert(pp2->pp_ref == 0);
f0101e17:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101e1c:	74 19                	je     f0101e37 <mem_init+0xc2c>
f0101e1e:	68 bf 59 10 f0       	push   $0xf01059bf
f0101e23:	68 a3 57 10 f0       	push   $0xf01057a3
f0101e28:	68 8a 03 00 00       	push   $0x38a
f0101e2d:	68 7d 57 10 f0       	push   $0xf010577d
f0101e32:	e8 bf e2 ff ff       	call   f01000f6 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101e37:	83 ec 0c             	sub    $0xc,%esp
f0101e3a:	6a 00                	push   $0x0
f0101e3c:	e8 bf f0 ff ff       	call   f0100f00 <page_alloc>
f0101e41:	83 c4 10             	add    $0x10,%esp
f0101e44:	85 c0                	test   %eax,%eax
f0101e46:	74 04                	je     f0101e4c <mem_init+0xc41>
f0101e48:	39 c6                	cmp    %eax,%esi
f0101e4a:	74 19                	je     f0101e65 <mem_init+0xc5a>
f0101e4c:	68 6c 54 10 f0       	push   $0xf010546c
f0101e51:	68 a3 57 10 f0       	push   $0xf01057a3
f0101e56:	68 8d 03 00 00       	push   $0x38d
f0101e5b:	68 7d 57 10 f0       	push   $0xf010577d
f0101e60:	e8 91 e2 ff ff       	call   f01000f6 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101e65:	83 ec 08             	sub    $0x8,%esp
f0101e68:	6a 00                	push   $0x0
f0101e6a:	ff 35 48 2c 17 f0    	pushl  0xf0172c48
f0101e70:	e8 e1 f2 ff ff       	call   f0101156 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101e75:	8b 3d 48 2c 17 f0    	mov    0xf0172c48,%edi
f0101e7b:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e80:	89 f8                	mov    %edi,%eax
f0101e82:	e8 17 ec ff ff       	call   f0100a9e <check_va2pa>
f0101e87:	83 c4 10             	add    $0x10,%esp
f0101e8a:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e8d:	74 19                	je     f0101ea8 <mem_init+0xc9d>
f0101e8f:	68 90 54 10 f0       	push   $0xf0105490
f0101e94:	68 a3 57 10 f0       	push   $0xf01057a3
f0101e99:	68 91 03 00 00       	push   $0x391
f0101e9e:	68 7d 57 10 f0       	push   $0xf010577d
f0101ea3:	e8 4e e2 ff ff       	call   f01000f6 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101ea8:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ead:	89 f8                	mov    %edi,%eax
f0101eaf:	e8 ea eb ff ff       	call   f0100a9e <check_va2pa>
f0101eb4:	89 da                	mov    %ebx,%edx
f0101eb6:	2b 15 4c 2c 17 f0    	sub    0xf0172c4c,%edx
f0101ebc:	c1 fa 03             	sar    $0x3,%edx
f0101ebf:	c1 e2 0c             	shl    $0xc,%edx
f0101ec2:	39 d0                	cmp    %edx,%eax
f0101ec4:	74 19                	je     f0101edf <mem_init+0xcd4>
f0101ec6:	68 3c 54 10 f0       	push   $0xf010543c
f0101ecb:	68 a3 57 10 f0       	push   $0xf01057a3
f0101ed0:	68 92 03 00 00       	push   $0x392
f0101ed5:	68 7d 57 10 f0       	push   $0xf010577d
f0101eda:	e8 17 e2 ff ff       	call   f01000f6 <_panic>
	assert(pp1->pp_ref == 1);
f0101edf:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ee4:	74 19                	je     f0101eff <mem_init+0xcf4>
f0101ee6:	68 65 59 10 f0       	push   $0xf0105965
f0101eeb:	68 a3 57 10 f0       	push   $0xf01057a3
f0101ef0:	68 93 03 00 00       	push   $0x393
f0101ef5:	68 7d 57 10 f0       	push   $0xf010577d
f0101efa:	e8 f7 e1 ff ff       	call   f01000f6 <_panic>
	assert(pp2->pp_ref == 0);
f0101eff:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101f04:	74 19                	je     f0101f1f <mem_init+0xd14>
f0101f06:	68 bf 59 10 f0       	push   $0xf01059bf
f0101f0b:	68 a3 57 10 f0       	push   $0xf01057a3
f0101f10:	68 94 03 00 00       	push   $0x394
f0101f15:	68 7d 57 10 f0       	push   $0xf010577d
f0101f1a:	e8 d7 e1 ff ff       	call   f01000f6 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101f1f:	6a 00                	push   $0x0
f0101f21:	68 00 10 00 00       	push   $0x1000
f0101f26:	53                   	push   %ebx
f0101f27:	57                   	push   %edi
f0101f28:	e8 75 f2 ff ff       	call   f01011a2 <page_insert>
f0101f2d:	83 c4 10             	add    $0x10,%esp
f0101f30:	85 c0                	test   %eax,%eax
f0101f32:	74 19                	je     f0101f4d <mem_init+0xd42>
f0101f34:	68 b4 54 10 f0       	push   $0xf01054b4
f0101f39:	68 a3 57 10 f0       	push   $0xf01057a3
f0101f3e:	68 97 03 00 00       	push   $0x397
f0101f43:	68 7d 57 10 f0       	push   $0xf010577d
f0101f48:	e8 a9 e1 ff ff       	call   f01000f6 <_panic>
	assert(pp1->pp_ref);
f0101f4d:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101f52:	75 19                	jne    f0101f6d <mem_init+0xd62>
f0101f54:	68 d0 59 10 f0       	push   $0xf01059d0
f0101f59:	68 a3 57 10 f0       	push   $0xf01057a3
f0101f5e:	68 98 03 00 00       	push   $0x398
f0101f63:	68 7d 57 10 f0       	push   $0xf010577d
f0101f68:	e8 89 e1 ff ff       	call   f01000f6 <_panic>
	assert(pp1->pp_link == NULL);
f0101f6d:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101f70:	74 19                	je     f0101f8b <mem_init+0xd80>
f0101f72:	68 dc 59 10 f0       	push   $0xf01059dc
f0101f77:	68 a3 57 10 f0       	push   $0xf01057a3
f0101f7c:	68 99 03 00 00       	push   $0x399
f0101f81:	68 7d 57 10 f0       	push   $0xf010577d
f0101f86:	e8 6b e1 ff ff       	call   f01000f6 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101f8b:	83 ec 08             	sub    $0x8,%esp
f0101f8e:	68 00 10 00 00       	push   $0x1000
f0101f93:	ff 35 48 2c 17 f0    	pushl  0xf0172c48
f0101f99:	e8 b8 f1 ff ff       	call   f0101156 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101f9e:	8b 3d 48 2c 17 f0    	mov    0xf0172c48,%edi
f0101fa4:	ba 00 00 00 00       	mov    $0x0,%edx
f0101fa9:	89 f8                	mov    %edi,%eax
f0101fab:	e8 ee ea ff ff       	call   f0100a9e <check_va2pa>
f0101fb0:	83 c4 10             	add    $0x10,%esp
f0101fb3:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fb6:	74 19                	je     f0101fd1 <mem_init+0xdc6>
f0101fb8:	68 90 54 10 f0       	push   $0xf0105490
f0101fbd:	68 a3 57 10 f0       	push   $0xf01057a3
f0101fc2:	68 9d 03 00 00       	push   $0x39d
f0101fc7:	68 7d 57 10 f0       	push   $0xf010577d
f0101fcc:	e8 25 e1 ff ff       	call   f01000f6 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101fd1:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fd6:	89 f8                	mov    %edi,%eax
f0101fd8:	e8 c1 ea ff ff       	call   f0100a9e <check_va2pa>
f0101fdd:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fe0:	74 19                	je     f0101ffb <mem_init+0xdf0>
f0101fe2:	68 ec 54 10 f0       	push   $0xf01054ec
f0101fe7:	68 a3 57 10 f0       	push   $0xf01057a3
f0101fec:	68 9e 03 00 00       	push   $0x39e
f0101ff1:	68 7d 57 10 f0       	push   $0xf010577d
f0101ff6:	e8 fb e0 ff ff       	call   f01000f6 <_panic>
	assert(pp1->pp_ref == 0);
f0101ffb:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102000:	74 19                	je     f010201b <mem_init+0xe10>
f0102002:	68 f1 59 10 f0       	push   $0xf01059f1
f0102007:	68 a3 57 10 f0       	push   $0xf01057a3
f010200c:	68 9f 03 00 00       	push   $0x39f
f0102011:	68 7d 57 10 f0       	push   $0xf010577d
f0102016:	e8 db e0 ff ff       	call   f01000f6 <_panic>
	assert(pp2->pp_ref == 0);
f010201b:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102020:	74 19                	je     f010203b <mem_init+0xe30>
f0102022:	68 bf 59 10 f0       	push   $0xf01059bf
f0102027:	68 a3 57 10 f0       	push   $0xf01057a3
f010202c:	68 a0 03 00 00       	push   $0x3a0
f0102031:	68 7d 57 10 f0       	push   $0xf010577d
f0102036:	e8 bb e0 ff ff       	call   f01000f6 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010203b:	83 ec 0c             	sub    $0xc,%esp
f010203e:	6a 00                	push   $0x0
f0102040:	e8 bb ee ff ff       	call   f0100f00 <page_alloc>
f0102045:	83 c4 10             	add    $0x10,%esp
f0102048:	39 c3                	cmp    %eax,%ebx
f010204a:	75 04                	jne    f0102050 <mem_init+0xe45>
f010204c:	85 c0                	test   %eax,%eax
f010204e:	75 19                	jne    f0102069 <mem_init+0xe5e>
f0102050:	68 14 55 10 f0       	push   $0xf0105514
f0102055:	68 a3 57 10 f0       	push   $0xf01057a3
f010205a:	68 a3 03 00 00       	push   $0x3a3
f010205f:	68 7d 57 10 f0       	push   $0xf010577d
f0102064:	e8 8d e0 ff ff       	call   f01000f6 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102069:	83 ec 0c             	sub    $0xc,%esp
f010206c:	6a 00                	push   $0x0
f010206e:	e8 8d ee ff ff       	call   f0100f00 <page_alloc>
f0102073:	83 c4 10             	add    $0x10,%esp
f0102076:	85 c0                	test   %eax,%eax
f0102078:	74 19                	je     f0102093 <mem_init+0xe88>
f010207a:	68 13 59 10 f0       	push   $0xf0105913
f010207f:	68 a3 57 10 f0       	push   $0xf01057a3
f0102084:	68 a6 03 00 00       	push   $0x3a6
f0102089:	68 7d 57 10 f0       	push   $0xf010577d
f010208e:	e8 63 e0 ff ff       	call   f01000f6 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102093:	8b 0d 48 2c 17 f0    	mov    0xf0172c48,%ecx
f0102099:	8b 11                	mov    (%ecx),%edx
f010209b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01020a1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020a4:	2b 05 4c 2c 17 f0    	sub    0xf0172c4c,%eax
f01020aa:	c1 f8 03             	sar    $0x3,%eax
f01020ad:	c1 e0 0c             	shl    $0xc,%eax
f01020b0:	39 c2                	cmp    %eax,%edx
f01020b2:	74 19                	je     f01020cd <mem_init+0xec2>
f01020b4:	68 b8 51 10 f0       	push   $0xf01051b8
f01020b9:	68 a3 57 10 f0       	push   $0xf01057a3
f01020be:	68 a9 03 00 00       	push   $0x3a9
f01020c3:	68 7d 57 10 f0       	push   $0xf010577d
f01020c8:	e8 29 e0 ff ff       	call   f01000f6 <_panic>
	kern_pgdir[0] = 0;
f01020cd:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01020d3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020d6:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01020db:	74 19                	je     f01020f6 <mem_init+0xeeb>
f01020dd:	68 76 59 10 f0       	push   $0xf0105976
f01020e2:	68 a3 57 10 f0       	push   $0xf01057a3
f01020e7:	68 ab 03 00 00       	push   $0x3ab
f01020ec:	68 7d 57 10 f0       	push   $0xf010577d
f01020f1:	e8 00 e0 ff ff       	call   f01000f6 <_panic>
	pp0->pp_ref = 0;
f01020f6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020f9:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01020ff:	83 ec 0c             	sub    $0xc,%esp
f0102102:	50                   	push   %eax
f0102103:	e8 68 ee ff ff       	call   f0100f70 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102108:	83 c4 0c             	add    $0xc,%esp
f010210b:	6a 01                	push   $0x1
f010210d:	68 00 10 40 00       	push   $0x401000
f0102112:	ff 35 48 2c 17 f0    	pushl  0xf0172c48
f0102118:	e8 b7 ee ff ff       	call   f0100fd4 <pgdir_walk>
f010211d:	89 c7                	mov    %eax,%edi
f010211f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102122:	a1 48 2c 17 f0       	mov    0xf0172c48,%eax
f0102127:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010212a:	8b 40 04             	mov    0x4(%eax),%eax
f010212d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102132:	8b 0d 44 2c 17 f0    	mov    0xf0172c44,%ecx
f0102138:	89 c2                	mov    %eax,%edx
f010213a:	c1 ea 0c             	shr    $0xc,%edx
f010213d:	83 c4 10             	add    $0x10,%esp
f0102140:	39 ca                	cmp    %ecx,%edx
f0102142:	72 15                	jb     f0102159 <mem_init+0xf4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102144:	50                   	push   %eax
f0102145:	68 30 4f 10 f0       	push   $0xf0104f30
f010214a:	68 b2 03 00 00       	push   $0x3b2
f010214f:	68 7d 57 10 f0       	push   $0xf010577d
f0102154:	e8 9d df ff ff       	call   f01000f6 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102159:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f010215e:	39 c7                	cmp    %eax,%edi
f0102160:	74 19                	je     f010217b <mem_init+0xf70>
f0102162:	68 02 5a 10 f0       	push   $0xf0105a02
f0102167:	68 a3 57 10 f0       	push   $0xf01057a3
f010216c:	68 b3 03 00 00       	push   $0x3b3
f0102171:	68 7d 57 10 f0       	push   $0xf010577d
f0102176:	e8 7b df ff ff       	call   f01000f6 <_panic>
	kern_pgdir[PDX(va)] = 0;
f010217b:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010217e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102185:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102188:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010218e:	2b 05 4c 2c 17 f0    	sub    0xf0172c4c,%eax
f0102194:	c1 f8 03             	sar    $0x3,%eax
f0102197:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010219a:	89 c2                	mov    %eax,%edx
f010219c:	c1 ea 0c             	shr    $0xc,%edx
f010219f:	39 d1                	cmp    %edx,%ecx
f01021a1:	77 12                	ja     f01021b5 <mem_init+0xfaa>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01021a3:	50                   	push   %eax
f01021a4:	68 30 4f 10 f0       	push   $0xf0104f30
f01021a9:	6a 56                	push   $0x56
f01021ab:	68 89 57 10 f0       	push   $0xf0105789
f01021b0:	e8 41 df ff ff       	call   f01000f6 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01021b5:	83 ec 04             	sub    $0x4,%esp
f01021b8:	68 00 10 00 00       	push   $0x1000
f01021bd:	68 ff 00 00 00       	push   $0xff
f01021c2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01021c7:	50                   	push   %eax
f01021c8:	e8 99 22 00 00       	call   f0104466 <memset>
	page_free(pp0);
f01021cd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01021d0:	89 3c 24             	mov    %edi,(%esp)
f01021d3:	e8 98 ed ff ff       	call   f0100f70 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01021d8:	83 c4 0c             	add    $0xc,%esp
f01021db:	6a 01                	push   $0x1
f01021dd:	6a 00                	push   $0x0
f01021df:	ff 35 48 2c 17 f0    	pushl  0xf0172c48
f01021e5:	e8 ea ed ff ff       	call   f0100fd4 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01021ea:	89 fa                	mov    %edi,%edx
f01021ec:	2b 15 4c 2c 17 f0    	sub    0xf0172c4c,%edx
f01021f2:	c1 fa 03             	sar    $0x3,%edx
f01021f5:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01021f8:	89 d0                	mov    %edx,%eax
f01021fa:	c1 e8 0c             	shr    $0xc,%eax
f01021fd:	83 c4 10             	add    $0x10,%esp
f0102200:	3b 05 44 2c 17 f0    	cmp    0xf0172c44,%eax
f0102206:	72 12                	jb     f010221a <mem_init+0x100f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102208:	52                   	push   %edx
f0102209:	68 30 4f 10 f0       	push   $0xf0104f30
f010220e:	6a 56                	push   $0x56
f0102210:	68 89 57 10 f0       	push   $0xf0105789
f0102215:	e8 dc de ff ff       	call   f01000f6 <_panic>
	return (void *)(pa + KERNBASE);
f010221a:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102220:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102223:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102229:	f6 00 01             	testb  $0x1,(%eax)
f010222c:	74 19                	je     f0102247 <mem_init+0x103c>
f010222e:	68 1a 5a 10 f0       	push   $0xf0105a1a
f0102233:	68 a3 57 10 f0       	push   $0xf01057a3
f0102238:	68 bd 03 00 00       	push   $0x3bd
f010223d:	68 7d 57 10 f0       	push   $0xf010577d
f0102242:	e8 af de ff ff       	call   f01000f6 <_panic>
f0102247:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f010224a:	39 c2                	cmp    %eax,%edx
f010224c:	75 db                	jne    f0102229 <mem_init+0x101e>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f010224e:	a1 48 2c 17 f0       	mov    0xf0172c48,%eax
f0102253:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102259:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010225c:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102262:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0102265:	89 3d 80 1f 17 f0    	mov    %edi,0xf0171f80

	// free the pages we took
	page_free(pp0);
f010226b:	83 ec 0c             	sub    $0xc,%esp
f010226e:	50                   	push   %eax
f010226f:	e8 fc ec ff ff       	call   f0100f70 <page_free>
	page_free(pp1);
f0102274:	89 1c 24             	mov    %ebx,(%esp)
f0102277:	e8 f4 ec ff ff       	call   f0100f70 <page_free>
	page_free(pp2);
f010227c:	89 34 24             	mov    %esi,(%esp)
f010227f:	e8 ec ec ff ff       	call   f0100f70 <page_free>

	cprintf("check_page() succeeded!\n");
f0102284:	c7 04 24 31 5a 10 f0 	movl   $0xf0105a31,(%esp)
f010228b:	e8 5d 0e 00 00       	call   f01030ed <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
      boot_map_region(kern_pgdir,
f0102290:	a1 4c 2c 17 f0       	mov    0xf0172c4c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102295:	83 c4 10             	add    $0x10,%esp
f0102298:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010229d:	77 15                	ja     f01022b4 <mem_init+0x10a9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010229f:	50                   	push   %eax
f01022a0:	68 bc 50 10 f0       	push   $0xf01050bc
f01022a5:	68 bd 00 00 00       	push   $0xbd
f01022aa:	68 7d 57 10 f0       	push   $0xf010577d
f01022af:	e8 42 de ff ff       	call   f01000f6 <_panic>
                    UPAGES,
                    ROUNDUP(sizeof(struct PageInfo)*npages, PGSIZE),
f01022b4:	8b 15 44 2c 17 f0    	mov    0xf0172c44,%edx
f01022ba:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
      boot_map_region(kern_pgdir,
f01022c1:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01022c7:	83 ec 08             	sub    $0x8,%esp
f01022ca:	6a 04                	push   $0x4
f01022cc:	05 00 00 00 10       	add    $0x10000000,%eax
f01022d1:	50                   	push   %eax
f01022d2:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01022d7:	a1 48 2c 17 f0       	mov    0xf0172c48,%eax
f01022dc:	e8 b8 ed ff ff       	call   f0101099 <boot_map_region>
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.

    boot_map_region(kern_pgdir, UENVS, ROUNDUP(sizeof(struct Env)*NENV, PGSIZE), PADDR(envs), PTE_P|PTE_U);
f01022e1:	a1 8c 1f 17 f0       	mov    0xf0171f8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01022e6:	83 c4 10             	add    $0x10,%esp
f01022e9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01022ee:	77 15                	ja     f0102305 <mem_init+0x10fa>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01022f0:	50                   	push   %eax
f01022f1:	68 bc 50 10 f0       	push   $0xf01050bc
f01022f6:	68 c7 00 00 00       	push   $0xc7
f01022fb:	68 7d 57 10 f0       	push   $0xf010577d
f0102300:	e8 f1 dd ff ff       	call   f01000f6 <_panic>
f0102305:	83 ec 08             	sub    $0x8,%esp
f0102308:	6a 05                	push   $0x5
f010230a:	05 00 00 00 10       	add    $0x10000000,%eax
f010230f:	50                   	push   %eax
f0102310:	b9 00 80 01 00       	mov    $0x18000,%ecx
f0102315:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010231a:	a1 48 2c 17 f0       	mov    0xf0172c48,%eax
f010231f:	e8 75 ed ff ff       	call   f0101099 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102324:	83 c4 10             	add    $0x10,%esp
f0102327:	b8 00 10 11 f0       	mov    $0xf0111000,%eax
f010232c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102331:	77 15                	ja     f0102348 <mem_init+0x113d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102333:	50                   	push   %eax
f0102334:	68 bc 50 10 f0       	push   $0xf01050bc
f0102339:	68 d6 00 00 00       	push   $0xd6
f010233e:	68 7d 57 10 f0       	push   $0xf010577d
f0102343:	e8 ae dd ff ff       	call   f01000f6 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f0102348:	83 ec 08             	sub    $0x8,%esp
f010234b:	6a 03                	push   $0x3
f010234d:	68 00 10 11 00       	push   $0x111000
f0102352:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102357:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010235c:	a1 48 2c 17 f0       	mov    0xf0172c48,%eax
f0102361:	e8 33 ed ff ff       	call   f0101099 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	 boot_map_region(kern_pgdir, KERNBASE, ROUNDUP(~0-KERNBASE+1, PGSIZE), 0, PTE_P|PTE_W);
f0102366:	83 c4 08             	add    $0x8,%esp
f0102369:	6a 03                	push   $0x3
f010236b:	6a 00                	push   $0x0
f010236d:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102372:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102377:	a1 48 2c 17 f0       	mov    0xf0172c48,%eax
f010237c:	e8 18 ed ff ff       	call   f0101099 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102381:	8b 1d 48 2c 17 f0    	mov    0xf0172c48,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102387:	a1 44 2c 17 f0       	mov    0xf0172c44,%eax
f010238c:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010238f:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102396:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010239b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010239e:	8b 3d 4c 2c 17 f0    	mov    0xf0172c4c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01023a4:	89 7d d0             	mov    %edi,-0x30(%ebp)
f01023a7:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01023aa:	be 00 00 00 00       	mov    $0x0,%esi
f01023af:	eb 55                	jmp    f0102406 <mem_init+0x11fb>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01023b1:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f01023b7:	89 d8                	mov    %ebx,%eax
f01023b9:	e8 e0 e6 ff ff       	call   f0100a9e <check_va2pa>
f01023be:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01023c5:	77 15                	ja     f01023dc <mem_init+0x11d1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01023c7:	57                   	push   %edi
f01023c8:	68 bc 50 10 f0       	push   $0xf01050bc
f01023cd:	68 fa 02 00 00       	push   $0x2fa
f01023d2:	68 7d 57 10 f0       	push   $0xf010577d
f01023d7:	e8 1a dd ff ff       	call   f01000f6 <_panic>
f01023dc:	8d 94 37 00 00 00 10 	lea    0x10000000(%edi,%esi,1),%edx
f01023e3:	39 d0                	cmp    %edx,%eax
f01023e5:	74 19                	je     f0102400 <mem_init+0x11f5>
f01023e7:	68 38 55 10 f0       	push   $0xf0105538
f01023ec:	68 a3 57 10 f0       	push   $0xf01057a3
f01023f1:	68 fa 02 00 00       	push   $0x2fa
f01023f6:	68 7d 57 10 f0       	push   $0xf010577d
f01023fb:	e8 f6 dc ff ff       	call   f01000f6 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102400:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102406:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f0102409:	77 a6                	ja     f01023b1 <mem_init+0x11a6>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010240b:	8b 3d 8c 1f 17 f0    	mov    0xf0171f8c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102411:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0102414:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
f0102419:	89 f2                	mov    %esi,%edx
f010241b:	89 d8                	mov    %ebx,%eax
f010241d:	e8 7c e6 ff ff       	call   f0100a9e <check_va2pa>
f0102422:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102429:	77 15                	ja     f0102440 <mem_init+0x1235>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010242b:	57                   	push   %edi
f010242c:	68 bc 50 10 f0       	push   $0xf01050bc
f0102431:	68 ff 02 00 00       	push   $0x2ff
f0102436:	68 7d 57 10 f0       	push   $0xf010577d
f010243b:	e8 b6 dc ff ff       	call   f01000f6 <_panic>
f0102440:	8d 94 37 00 00 40 21 	lea    0x21400000(%edi,%esi,1),%edx
f0102447:	39 c2                	cmp    %eax,%edx
f0102449:	74 19                	je     f0102464 <mem_init+0x1259>
f010244b:	68 6c 55 10 f0       	push   $0xf010556c
f0102450:	68 a3 57 10 f0       	push   $0xf01057a3
f0102455:	68 ff 02 00 00       	push   $0x2ff
f010245a:	68 7d 57 10 f0       	push   $0xf010577d
f010245f:	e8 92 dc ff ff       	call   f01000f6 <_panic>
f0102464:	81 c6 00 10 00 00    	add    $0x1000,%esi
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010246a:	81 fe 00 80 c1 ee    	cmp    $0xeec18000,%esi
f0102470:	75 a7                	jne    f0102419 <mem_init+0x120e>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102472:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0102475:	c1 e7 0c             	shl    $0xc,%edi
f0102478:	be 00 00 00 00       	mov    $0x0,%esi
f010247d:	eb 30                	jmp    f01024af <mem_init+0x12a4>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010247f:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f0102485:	89 d8                	mov    %ebx,%eax
f0102487:	e8 12 e6 ff ff       	call   f0100a9e <check_va2pa>
f010248c:	39 c6                	cmp    %eax,%esi
f010248e:	74 19                	je     f01024a9 <mem_init+0x129e>
f0102490:	68 a0 55 10 f0       	push   $0xf01055a0
f0102495:	68 a3 57 10 f0       	push   $0xf01057a3
f010249a:	68 03 03 00 00       	push   $0x303
f010249f:	68 7d 57 10 f0       	push   $0xf010577d
f01024a4:	e8 4d dc ff ff       	call   f01000f6 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01024a9:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01024af:	39 fe                	cmp    %edi,%esi
f01024b1:	72 cc                	jb     f010247f <mem_init+0x1274>
f01024b3:	be 00 80 ff ef       	mov    $0xefff8000,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01024b8:	89 f2                	mov    %esi,%edx
f01024ba:	89 d8                	mov    %ebx,%eax
f01024bc:	e8 dd e5 ff ff       	call   f0100a9e <check_va2pa>
f01024c1:	8d 96 00 90 11 10    	lea    0x10119000(%esi),%edx
f01024c7:	39 c2                	cmp    %eax,%edx
f01024c9:	74 19                	je     f01024e4 <mem_init+0x12d9>
f01024cb:	68 c8 55 10 f0       	push   $0xf01055c8
f01024d0:	68 a3 57 10 f0       	push   $0xf01057a3
f01024d5:	68 07 03 00 00       	push   $0x307
f01024da:	68 7d 57 10 f0       	push   $0xf010577d
f01024df:	e8 12 dc ff ff       	call   f01000f6 <_panic>
f01024e4:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01024ea:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f01024f0:	75 c6                	jne    f01024b8 <mem_init+0x12ad>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01024f2:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01024f7:	89 d8                	mov    %ebx,%eax
f01024f9:	e8 a0 e5 ff ff       	call   f0100a9e <check_va2pa>
f01024fe:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102501:	74 51                	je     f0102554 <mem_init+0x1349>
f0102503:	68 10 56 10 f0       	push   $0xf0105610
f0102508:	68 a3 57 10 f0       	push   $0xf01057a3
f010250d:	68 08 03 00 00       	push   $0x308
f0102512:	68 7d 57 10 f0       	push   $0xf010577d
f0102517:	e8 da db ff ff       	call   f01000f6 <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f010251c:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102521:	72 36                	jb     f0102559 <mem_init+0x134e>
f0102523:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102528:	76 07                	jbe    f0102531 <mem_init+0x1326>
f010252a:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010252f:	75 28                	jne    f0102559 <mem_init+0x134e>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f0102531:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102535:	0f 85 83 00 00 00    	jne    f01025be <mem_init+0x13b3>
f010253b:	68 4a 5a 10 f0       	push   $0xf0105a4a
f0102540:	68 a3 57 10 f0       	push   $0xf01057a3
f0102545:	68 11 03 00 00       	push   $0x311
f010254a:	68 7d 57 10 f0       	push   $0xf010577d
f010254f:	e8 a2 db ff ff       	call   f01000f6 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102554:	b8 00 00 00 00       	mov    $0x0,%eax
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102559:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010255e:	76 3f                	jbe    f010259f <mem_init+0x1394>
				assert(pgdir[i] & PTE_P);
f0102560:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0102563:	f6 c2 01             	test   $0x1,%dl
f0102566:	75 19                	jne    f0102581 <mem_init+0x1376>
f0102568:	68 4a 5a 10 f0       	push   $0xf0105a4a
f010256d:	68 a3 57 10 f0       	push   $0xf01057a3
f0102572:	68 15 03 00 00       	push   $0x315
f0102577:	68 7d 57 10 f0       	push   $0xf010577d
f010257c:	e8 75 db ff ff       	call   f01000f6 <_panic>
				assert(pgdir[i] & PTE_W);
f0102581:	f6 c2 02             	test   $0x2,%dl
f0102584:	75 38                	jne    f01025be <mem_init+0x13b3>
f0102586:	68 5b 5a 10 f0       	push   $0xf0105a5b
f010258b:	68 a3 57 10 f0       	push   $0xf01057a3
f0102590:	68 16 03 00 00       	push   $0x316
f0102595:	68 7d 57 10 f0       	push   $0xf010577d
f010259a:	e8 57 db ff ff       	call   f01000f6 <_panic>
			} else
				assert(pgdir[i] == 0);
f010259f:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f01025a3:	74 19                	je     f01025be <mem_init+0x13b3>
f01025a5:	68 6c 5a 10 f0       	push   $0xf0105a6c
f01025aa:	68 a3 57 10 f0       	push   $0xf01057a3
f01025af:	68 18 03 00 00       	push   $0x318
f01025b4:	68 7d 57 10 f0       	push   $0xf010577d
f01025b9:	e8 38 db ff ff       	call   f01000f6 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01025be:	83 c0 01             	add    $0x1,%eax
f01025c1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f01025c6:	0f 86 50 ff ff ff    	jbe    f010251c <mem_init+0x1311>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01025cc:	83 ec 0c             	sub    $0xc,%esp
f01025cf:	68 40 56 10 f0       	push   $0xf0105640
f01025d4:	e8 14 0b 00 00       	call   f01030ed <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01025d9:	a1 48 2c 17 f0       	mov    0xf0172c48,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025de:	83 c4 10             	add    $0x10,%esp
f01025e1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025e6:	77 15                	ja     f01025fd <mem_init+0x13f2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01025e8:	50                   	push   %eax
f01025e9:	68 bc 50 10 f0       	push   $0xf01050bc
f01025ee:	68 eb 00 00 00       	push   $0xeb
f01025f3:	68 7d 57 10 f0       	push   $0xf010577d
f01025f8:	e8 f9 da ff ff       	call   f01000f6 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01025fd:	05 00 00 00 10       	add    $0x10000000,%eax
f0102602:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102605:	b8 00 00 00 00       	mov    $0x0,%eax
f010260a:	e8 f3 e4 ff ff       	call   f0100b02 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f010260f:	0f 20 c0             	mov    %cr0,%eax
f0102612:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102615:	0d 23 00 05 80       	or     $0x80050023,%eax
f010261a:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010261d:	83 ec 0c             	sub    $0xc,%esp
f0102620:	6a 00                	push   $0x0
f0102622:	e8 d9 e8 ff ff       	call   f0100f00 <page_alloc>
f0102627:	89 c3                	mov    %eax,%ebx
f0102629:	83 c4 10             	add    $0x10,%esp
f010262c:	85 c0                	test   %eax,%eax
f010262e:	75 19                	jne    f0102649 <mem_init+0x143e>
f0102630:	68 68 58 10 f0       	push   $0xf0105868
f0102635:	68 a3 57 10 f0       	push   $0xf01057a3
f010263a:	68 d8 03 00 00       	push   $0x3d8
f010263f:	68 7d 57 10 f0       	push   $0xf010577d
f0102644:	e8 ad da ff ff       	call   f01000f6 <_panic>
	assert((pp1 = page_alloc(0)));
f0102649:	83 ec 0c             	sub    $0xc,%esp
f010264c:	6a 00                	push   $0x0
f010264e:	e8 ad e8 ff ff       	call   f0100f00 <page_alloc>
f0102653:	89 c7                	mov    %eax,%edi
f0102655:	83 c4 10             	add    $0x10,%esp
f0102658:	85 c0                	test   %eax,%eax
f010265a:	75 19                	jne    f0102675 <mem_init+0x146a>
f010265c:	68 7e 58 10 f0       	push   $0xf010587e
f0102661:	68 a3 57 10 f0       	push   $0xf01057a3
f0102666:	68 d9 03 00 00       	push   $0x3d9
f010266b:	68 7d 57 10 f0       	push   $0xf010577d
f0102670:	e8 81 da ff ff       	call   f01000f6 <_panic>
	assert((pp2 = page_alloc(0)));
f0102675:	83 ec 0c             	sub    $0xc,%esp
f0102678:	6a 00                	push   $0x0
f010267a:	e8 81 e8 ff ff       	call   f0100f00 <page_alloc>
f010267f:	89 c6                	mov    %eax,%esi
f0102681:	83 c4 10             	add    $0x10,%esp
f0102684:	85 c0                	test   %eax,%eax
f0102686:	75 19                	jne    f01026a1 <mem_init+0x1496>
f0102688:	68 94 58 10 f0       	push   $0xf0105894
f010268d:	68 a3 57 10 f0       	push   $0xf01057a3
f0102692:	68 da 03 00 00       	push   $0x3da
f0102697:	68 7d 57 10 f0       	push   $0xf010577d
f010269c:	e8 55 da ff ff       	call   f01000f6 <_panic>
	page_free(pp0);
f01026a1:	83 ec 0c             	sub    $0xc,%esp
f01026a4:	53                   	push   %ebx
f01026a5:	e8 c6 e8 ff ff       	call   f0100f70 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01026aa:	89 f8                	mov    %edi,%eax
f01026ac:	2b 05 4c 2c 17 f0    	sub    0xf0172c4c,%eax
f01026b2:	c1 f8 03             	sar    $0x3,%eax
f01026b5:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01026b8:	89 c2                	mov    %eax,%edx
f01026ba:	c1 ea 0c             	shr    $0xc,%edx
f01026bd:	83 c4 10             	add    $0x10,%esp
f01026c0:	3b 15 44 2c 17 f0    	cmp    0xf0172c44,%edx
f01026c6:	72 12                	jb     f01026da <mem_init+0x14cf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01026c8:	50                   	push   %eax
f01026c9:	68 30 4f 10 f0       	push   $0xf0104f30
f01026ce:	6a 56                	push   $0x56
f01026d0:	68 89 57 10 f0       	push   $0xf0105789
f01026d5:	e8 1c da ff ff       	call   f01000f6 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f01026da:	83 ec 04             	sub    $0x4,%esp
f01026dd:	68 00 10 00 00       	push   $0x1000
f01026e2:	6a 01                	push   $0x1
f01026e4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01026e9:	50                   	push   %eax
f01026ea:	e8 77 1d 00 00       	call   f0104466 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01026ef:	89 f0                	mov    %esi,%eax
f01026f1:	2b 05 4c 2c 17 f0    	sub    0xf0172c4c,%eax
f01026f7:	c1 f8 03             	sar    $0x3,%eax
f01026fa:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01026fd:	89 c2                	mov    %eax,%edx
f01026ff:	c1 ea 0c             	shr    $0xc,%edx
f0102702:	83 c4 10             	add    $0x10,%esp
f0102705:	3b 15 44 2c 17 f0    	cmp    0xf0172c44,%edx
f010270b:	72 12                	jb     f010271f <mem_init+0x1514>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010270d:	50                   	push   %eax
f010270e:	68 30 4f 10 f0       	push   $0xf0104f30
f0102713:	6a 56                	push   $0x56
f0102715:	68 89 57 10 f0       	push   $0xf0105789
f010271a:	e8 d7 d9 ff ff       	call   f01000f6 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f010271f:	83 ec 04             	sub    $0x4,%esp
f0102722:	68 00 10 00 00       	push   $0x1000
f0102727:	6a 02                	push   $0x2
f0102729:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010272e:	50                   	push   %eax
f010272f:	e8 32 1d 00 00       	call   f0104466 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102734:	6a 02                	push   $0x2
f0102736:	68 00 10 00 00       	push   $0x1000
f010273b:	57                   	push   %edi
f010273c:	ff 35 48 2c 17 f0    	pushl  0xf0172c48
f0102742:	e8 5b ea ff ff       	call   f01011a2 <page_insert>
	assert(pp1->pp_ref == 1);
f0102747:	83 c4 20             	add    $0x20,%esp
f010274a:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010274f:	74 19                	je     f010276a <mem_init+0x155f>
f0102751:	68 65 59 10 f0       	push   $0xf0105965
f0102756:	68 a3 57 10 f0       	push   $0xf01057a3
f010275b:	68 df 03 00 00       	push   $0x3df
f0102760:	68 7d 57 10 f0       	push   $0xf010577d
f0102765:	e8 8c d9 ff ff       	call   f01000f6 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010276a:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102771:	01 01 01 
f0102774:	74 19                	je     f010278f <mem_init+0x1584>
f0102776:	68 60 56 10 f0       	push   $0xf0105660
f010277b:	68 a3 57 10 f0       	push   $0xf01057a3
f0102780:	68 e0 03 00 00       	push   $0x3e0
f0102785:	68 7d 57 10 f0       	push   $0xf010577d
f010278a:	e8 67 d9 ff ff       	call   f01000f6 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f010278f:	6a 02                	push   $0x2
f0102791:	68 00 10 00 00       	push   $0x1000
f0102796:	56                   	push   %esi
f0102797:	ff 35 48 2c 17 f0    	pushl  0xf0172c48
f010279d:	e8 00 ea ff ff       	call   f01011a2 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01027a2:	83 c4 10             	add    $0x10,%esp
f01027a5:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01027ac:	02 02 02 
f01027af:	74 19                	je     f01027ca <mem_init+0x15bf>
f01027b1:	68 84 56 10 f0       	push   $0xf0105684
f01027b6:	68 a3 57 10 f0       	push   $0xf01057a3
f01027bb:	68 e2 03 00 00       	push   $0x3e2
f01027c0:	68 7d 57 10 f0       	push   $0xf010577d
f01027c5:	e8 2c d9 ff ff       	call   f01000f6 <_panic>
	assert(pp2->pp_ref == 1);
f01027ca:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01027cf:	74 19                	je     f01027ea <mem_init+0x15df>
f01027d1:	68 87 59 10 f0       	push   $0xf0105987
f01027d6:	68 a3 57 10 f0       	push   $0xf01057a3
f01027db:	68 e3 03 00 00       	push   $0x3e3
f01027e0:	68 7d 57 10 f0       	push   $0xf010577d
f01027e5:	e8 0c d9 ff ff       	call   f01000f6 <_panic>
	assert(pp1->pp_ref == 0);
f01027ea:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01027ef:	74 19                	je     f010280a <mem_init+0x15ff>
f01027f1:	68 f1 59 10 f0       	push   $0xf01059f1
f01027f6:	68 a3 57 10 f0       	push   $0xf01057a3
f01027fb:	68 e4 03 00 00       	push   $0x3e4
f0102800:	68 7d 57 10 f0       	push   $0xf010577d
f0102805:	e8 ec d8 ff ff       	call   f01000f6 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f010280a:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102811:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102814:	89 f0                	mov    %esi,%eax
f0102816:	2b 05 4c 2c 17 f0    	sub    0xf0172c4c,%eax
f010281c:	c1 f8 03             	sar    $0x3,%eax
f010281f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102822:	89 c2                	mov    %eax,%edx
f0102824:	c1 ea 0c             	shr    $0xc,%edx
f0102827:	3b 15 44 2c 17 f0    	cmp    0xf0172c44,%edx
f010282d:	72 12                	jb     f0102841 <mem_init+0x1636>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010282f:	50                   	push   %eax
f0102830:	68 30 4f 10 f0       	push   $0xf0104f30
f0102835:	6a 56                	push   $0x56
f0102837:	68 89 57 10 f0       	push   $0xf0105789
f010283c:	e8 b5 d8 ff ff       	call   f01000f6 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102841:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102848:	03 03 03 
f010284b:	74 19                	je     f0102866 <mem_init+0x165b>
f010284d:	68 a8 56 10 f0       	push   $0xf01056a8
f0102852:	68 a3 57 10 f0       	push   $0xf01057a3
f0102857:	68 e6 03 00 00       	push   $0x3e6
f010285c:	68 7d 57 10 f0       	push   $0xf010577d
f0102861:	e8 90 d8 ff ff       	call   f01000f6 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102866:	83 ec 08             	sub    $0x8,%esp
f0102869:	68 00 10 00 00       	push   $0x1000
f010286e:	ff 35 48 2c 17 f0    	pushl  0xf0172c48
f0102874:	e8 dd e8 ff ff       	call   f0101156 <page_remove>
	assert(pp2->pp_ref == 0);
f0102879:	83 c4 10             	add    $0x10,%esp
f010287c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102881:	74 19                	je     f010289c <mem_init+0x1691>
f0102883:	68 bf 59 10 f0       	push   $0xf01059bf
f0102888:	68 a3 57 10 f0       	push   $0xf01057a3
f010288d:	68 e8 03 00 00       	push   $0x3e8
f0102892:	68 7d 57 10 f0       	push   $0xf010577d
f0102897:	e8 5a d8 ff ff       	call   f01000f6 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010289c:	8b 0d 48 2c 17 f0    	mov    0xf0172c48,%ecx
f01028a2:	8b 11                	mov    (%ecx),%edx
f01028a4:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01028aa:	89 d8                	mov    %ebx,%eax
f01028ac:	2b 05 4c 2c 17 f0    	sub    0xf0172c4c,%eax
f01028b2:	c1 f8 03             	sar    $0x3,%eax
f01028b5:	c1 e0 0c             	shl    $0xc,%eax
f01028b8:	39 c2                	cmp    %eax,%edx
f01028ba:	74 19                	je     f01028d5 <mem_init+0x16ca>
f01028bc:	68 b8 51 10 f0       	push   $0xf01051b8
f01028c1:	68 a3 57 10 f0       	push   $0xf01057a3
f01028c6:	68 eb 03 00 00       	push   $0x3eb
f01028cb:	68 7d 57 10 f0       	push   $0xf010577d
f01028d0:	e8 21 d8 ff ff       	call   f01000f6 <_panic>
	kern_pgdir[0] = 0;
f01028d5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01028db:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01028e0:	74 19                	je     f01028fb <mem_init+0x16f0>
f01028e2:	68 76 59 10 f0       	push   $0xf0105976
f01028e7:	68 a3 57 10 f0       	push   $0xf01057a3
f01028ec:	68 ed 03 00 00       	push   $0x3ed
f01028f1:	68 7d 57 10 f0       	push   $0xf010577d
f01028f6:	e8 fb d7 ff ff       	call   f01000f6 <_panic>
	pp0->pp_ref = 0;
f01028fb:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102901:	83 ec 0c             	sub    $0xc,%esp
f0102904:	53                   	push   %ebx
f0102905:	e8 66 e6 ff ff       	call   f0100f70 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f010290a:	c7 04 24 d4 56 10 f0 	movl   $0xf01056d4,(%esp)
f0102911:	e8 d7 07 00 00       	call   f01030ed <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102916:	83 c4 10             	add    $0x10,%esp
f0102919:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010291c:	5b                   	pop    %ebx
f010291d:	5e                   	pop    %esi
f010291e:	5f                   	pop    %edi
f010291f:	5d                   	pop    %ebp
f0102920:	c3                   	ret    

f0102921 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0102921:	55                   	push   %ebp
f0102922:	89 e5                	mov    %esp,%ebp
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102924:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102927:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f010292a:	5d                   	pop    %ebp
f010292b:	c3                   	ret    

f010292c <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f010292c:	55                   	push   %ebp
f010292d:	89 e5                	mov    %esp,%ebp
f010292f:	57                   	push   %edi
f0102930:	56                   	push   %esi
f0102931:	53                   	push   %ebx
f0102932:	83 ec 20             	sub    $0x20,%esp
f0102935:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102938:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 3: Your code here.
	cprintf("user_mem_check va: %x, len: %x\n", va, len);
f010293b:	ff 75 10             	pushl  0x10(%ebp)
f010293e:	ff 75 0c             	pushl  0xc(%ebp)
f0102941:	68 00 57 10 f0       	push   $0xf0105700
f0102946:	e8 a2 07 00 00       	call   f01030ed <cprintf>
	uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
f010294b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010294e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t end = (uint32_t) ROUNDUP(va+len, PGSIZE);
f0102954:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102957:	8b 55 10             	mov    0x10(%ebp),%edx
f010295a:	8d 84 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%eax
f0102961:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102966:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t i;
	for (i = (uint32_t)begin; i < end; i+=PGSIZE) {
f0102969:	83 c4 10             	add    $0x10,%esp
f010296c:	eb 43                	jmp    f01029b1 <user_mem_check+0x85>
		pte_t *pte = pgdir_walk(env->env_pgdir, (void*)i, 0);
f010296e:	83 ec 04             	sub    $0x4,%esp
f0102971:	6a 00                	push   $0x0
f0102973:	53                   	push   %ebx
f0102974:	ff 77 5c             	pushl  0x5c(%edi)
f0102977:	e8 58 e6 ff ff       	call   f0100fd4 <pgdir_walk>
		if ((i>=ULIM) || !pte || !(*pte & PTE_P) || ((*pte & perm) != perm)) {
f010297c:	83 c4 10             	add    $0x10,%esp
f010297f:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102985:	77 10                	ja     f0102997 <user_mem_check+0x6b>
f0102987:	85 c0                	test   %eax,%eax
f0102989:	74 0c                	je     f0102997 <user_mem_check+0x6b>
f010298b:	8b 00                	mov    (%eax),%eax
f010298d:	a8 01                	test   $0x1,%al
f010298f:	74 06                	je     f0102997 <user_mem_check+0x6b>
f0102991:	21 f0                	and    %esi,%eax
f0102993:	39 c6                	cmp    %eax,%esi
f0102995:	74 14                	je     f01029ab <user_mem_check+0x7f>
			user_mem_check_addr = (i<(uint32_t)va?(uint32_t)va:i);
f0102997:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f010299a:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
f010299e:	89 1d 7c 1f 17 f0    	mov    %ebx,0xf0171f7c
			return -E_FAULT;
f01029a4:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01029a9:	eb 26                	jmp    f01029d1 <user_mem_check+0xa5>
	// LAB 3: Your code here.
	cprintf("user_mem_check va: %x, len: %x\n", va, len);
	uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
	uint32_t end = (uint32_t) ROUNDUP(va+len, PGSIZE);
	uint32_t i;
	for (i = (uint32_t)begin; i < end; i+=PGSIZE) {
f01029ab:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01029b1:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f01029b4:	72 b8                	jb     f010296e <user_mem_check+0x42>
		if ((i>=ULIM) || !pte || !(*pte & PTE_P) || ((*pte & perm) != perm)) {
			user_mem_check_addr = (i<(uint32_t)va?(uint32_t)va:i);
			return -E_FAULT;
		}
	}
	cprintf("user_mem_check success va: %x, len: %x\n", va, len);
f01029b6:	83 ec 04             	sub    $0x4,%esp
f01029b9:	ff 75 10             	pushl  0x10(%ebp)
f01029bc:	ff 75 0c             	pushl  0xc(%ebp)
f01029bf:	68 20 57 10 f0       	push   $0xf0105720
f01029c4:	e8 24 07 00 00       	call   f01030ed <cprintf>
	return 0;
f01029c9:	83 c4 10             	add    $0x10,%esp
f01029cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01029d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01029d4:	5b                   	pop    %ebx
f01029d5:	5e                   	pop    %esi
f01029d6:	5f                   	pop    %edi
f01029d7:	5d                   	pop    %ebp
f01029d8:	c3                   	ret    

f01029d9 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f01029d9:	55                   	push   %ebp
f01029da:	89 e5                	mov    %esp,%ebp
f01029dc:	53                   	push   %ebx
f01029dd:	83 ec 04             	sub    $0x4,%esp
f01029e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01029e3:	8b 45 14             	mov    0x14(%ebp),%eax
f01029e6:	83 c8 04             	or     $0x4,%eax
f01029e9:	50                   	push   %eax
f01029ea:	ff 75 10             	pushl  0x10(%ebp)
f01029ed:	ff 75 0c             	pushl  0xc(%ebp)
f01029f0:	53                   	push   %ebx
f01029f1:	e8 36 ff ff ff       	call   f010292c <user_mem_check>
f01029f6:	83 c4 10             	add    $0x10,%esp
f01029f9:	85 c0                	test   %eax,%eax
f01029fb:	79 21                	jns    f0102a1e <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f01029fd:	83 ec 04             	sub    $0x4,%esp
f0102a00:	ff 35 7c 1f 17 f0    	pushl  0xf0171f7c
f0102a06:	ff 73 48             	pushl  0x48(%ebx)
f0102a09:	68 48 57 10 f0       	push   $0xf0105748
f0102a0e:	e8 da 06 00 00       	call   f01030ed <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102a13:	89 1c 24             	mov    %ebx,(%esp)
f0102a16:	e8 bb 05 00 00       	call   f0102fd6 <env_destroy>
f0102a1b:	83 c4 10             	add    $0x10,%esp
	}
}
f0102a1e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102a21:	c9                   	leave  
f0102a22:	c3                   	ret    

f0102a23 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102a23:	55                   	push   %ebp
f0102a24:	89 e5                	mov    %esp,%ebp
f0102a26:	57                   	push   %edi
f0102a27:	56                   	push   %esi
f0102a28:	53                   	push   %ebx
f0102a29:	83 ec 0c             	sub    $0xc,%esp
f0102a2c:	89 c7                	mov    %eax,%edi
	// LAB 3: Your code here.
	void *begin = ROUNDDOWN(va, PGSIZE), *end = ROUNDUP(va+len, PGSIZE);
f0102a2e:	89 d3                	mov    %edx,%ebx
f0102a30:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102a36:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102a3d:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	for (; begin < end; begin += PGSIZE) {
f0102a43:	eb 3d                	jmp    f0102a82 <region_alloc+0x5f>
		struct PageInfo *pg = page_alloc(0);
f0102a45:	83 ec 0c             	sub    $0xc,%esp
f0102a48:	6a 00                	push   $0x0
f0102a4a:	e8 b1 e4 ff ff       	call   f0100f00 <page_alloc>
		if (!pg) panic("region_alloc failed!");
f0102a4f:	83 c4 10             	add    $0x10,%esp
f0102a52:	85 c0                	test   %eax,%eax
f0102a54:	75 17                	jne    f0102a6d <region_alloc+0x4a>
f0102a56:	83 ec 04             	sub    $0x4,%esp
f0102a59:	68 7a 5a 10 f0       	push   $0xf0105a7a
f0102a5e:	68 14 01 00 00       	push   $0x114
f0102a63:	68 8f 5a 10 f0       	push   $0xf0105a8f
f0102a68:	e8 89 d6 ff ff       	call   f01000f6 <_panic>
		page_insert(e->env_pgdir, pg, begin, PTE_W | PTE_U);
f0102a6d:	6a 06                	push   $0x6
f0102a6f:	53                   	push   %ebx
f0102a70:	50                   	push   %eax
f0102a71:	ff 77 5c             	pushl  0x5c(%edi)
f0102a74:	e8 29 e7 ff ff       	call   f01011a2 <page_insert>
static void
region_alloc(struct Env *e, void *va, size_t len)
{
	// LAB 3: Your code here.
	void *begin = ROUNDDOWN(va, PGSIZE), *end = ROUNDUP(va+len, PGSIZE);
	for (; begin < end; begin += PGSIZE) {
f0102a79:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102a7f:	83 c4 10             	add    $0x10,%esp
f0102a82:	39 f3                	cmp    %esi,%ebx
f0102a84:	72 bf                	jb     f0102a45 <region_alloc+0x22>
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}
f0102a86:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102a89:	5b                   	pop    %ebx
f0102a8a:	5e                   	pop    %esi
f0102a8b:	5f                   	pop    %edi
f0102a8c:	5d                   	pop    %ebp
f0102a8d:	c3                   	ret    

f0102a8e <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102a8e:	55                   	push   %ebp
f0102a8f:	89 e5                	mov    %esp,%ebp
f0102a91:	8b 55 08             	mov    0x8(%ebp),%edx
f0102a94:	8b 4d 10             	mov    0x10(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102a97:	85 d2                	test   %edx,%edx
f0102a99:	75 11                	jne    f0102aac <envid2env+0x1e>
		*env_store = curenv;
f0102a9b:	a1 88 1f 17 f0       	mov    0xf0171f88,%eax
f0102aa0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102aa3:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102aa5:	b8 00 00 00 00       	mov    $0x0,%eax
f0102aaa:	eb 5e                	jmp    f0102b0a <envid2env+0x7c>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102aac:	89 d0                	mov    %edx,%eax
f0102aae:	25 ff 03 00 00       	and    $0x3ff,%eax
f0102ab3:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0102ab6:	c1 e0 05             	shl    $0x5,%eax
f0102ab9:	03 05 8c 1f 17 f0    	add    0xf0171f8c,%eax
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102abf:	83 78 54 00          	cmpl   $0x0,0x54(%eax)
f0102ac3:	74 05                	je     f0102aca <envid2env+0x3c>
f0102ac5:	3b 50 48             	cmp    0x48(%eax),%edx
f0102ac8:	74 10                	je     f0102ada <envid2env+0x4c>
		*env_store = 0;
f0102aca:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102acd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102ad3:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102ad8:	eb 30                	jmp    f0102b0a <envid2env+0x7c>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102ada:	84 c9                	test   %cl,%cl
f0102adc:	74 22                	je     f0102b00 <envid2env+0x72>
f0102ade:	8b 15 88 1f 17 f0    	mov    0xf0171f88,%edx
f0102ae4:	39 d0                	cmp    %edx,%eax
f0102ae6:	74 18                	je     f0102b00 <envid2env+0x72>
f0102ae8:	8b 4a 48             	mov    0x48(%edx),%ecx
f0102aeb:	39 48 4c             	cmp    %ecx,0x4c(%eax)
f0102aee:	74 10                	je     f0102b00 <envid2env+0x72>
		*env_store = 0;
f0102af0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102af3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102af9:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102afe:	eb 0a                	jmp    f0102b0a <envid2env+0x7c>
	}

	*env_store = e;
f0102b00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102b03:	89 01                	mov    %eax,(%ecx)
	return 0;
f0102b05:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102b0a:	5d                   	pop    %ebp
f0102b0b:	c3                   	ret    

f0102b0c <env_init_percpu>:

}
// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102b0c:	55                   	push   %ebp
f0102b0d:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f0102b0f:	b8 00 b3 11 f0       	mov    $0xf011b300,%eax
f0102b14:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102b17:	b8 23 00 00 00       	mov    $0x23,%eax
f0102b1c:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0102b1e:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0102b20:	b8 10 00 00 00       	mov    $0x10,%eax
f0102b25:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0102b27:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0102b29:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0102b2b:	ea 32 2b 10 f0 08 00 	ljmp   $0x8,$0xf0102b32
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f0102b32:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b37:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102b3a:	5d                   	pop    %ebp
f0102b3b:	c3                   	ret    

f0102b3c <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102b3c:	55                   	push   %ebp
f0102b3d:	89 e5                	mov    %esp,%ebp
f0102b3f:	56                   	push   %esi
f0102b40:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
    int i = NENV-1;
    for (; i>=0; i--) {
        envs[i].env_id = 0;
f0102b41:	8b 35 8c 1f 17 f0    	mov    0xf0171f8c,%esi
f0102b47:	8b 15 90 1f 17 f0    	mov    0xf0171f90,%edx
f0102b4d:	8d 86 a0 7f 01 00    	lea    0x17fa0(%esi),%eax
f0102b53:	8d 5e a0             	lea    -0x60(%esi),%ebx
f0102b56:	89 c1                	mov    %eax,%ecx
f0102b58:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
        envs[i].env_link = env_free_list;
f0102b5f:	89 50 44             	mov    %edx,0x44(%eax)
f0102b62:	83 e8 60             	sub    $0x60,%eax
        env_free_list = envs+i;
f0102b65:	89 ca                	mov    %ecx,%edx
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
    int i = NENV-1;
    for (; i>=0; i--) {
f0102b67:	39 d8                	cmp    %ebx,%eax
f0102b69:	75 eb                	jne    f0102b56 <env_init+0x1a>
f0102b6b:	89 35 90 1f 17 f0    	mov    %esi,0xf0171f90
        envs[i].env_id = 0;
        envs[i].env_link = env_free_list;
        env_free_list = envs+i;
    }
	// Per-CPU part of the initialization
	env_init_percpu();
f0102b71:	e8 96 ff ff ff       	call   f0102b0c <env_init_percpu>

}
f0102b76:	5b                   	pop    %ebx
f0102b77:	5e                   	pop    %esi
f0102b78:	5d                   	pop    %ebp
f0102b79:	c3                   	ret    

f0102b7a <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102b7a:	55                   	push   %ebp
f0102b7b:	89 e5                	mov    %esp,%ebp
f0102b7d:	53                   	push   %ebx
f0102b7e:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102b81:	8b 1d 90 1f 17 f0    	mov    0xf0171f90,%ebx
f0102b87:	85 db                	test   %ebx,%ebx
f0102b89:	0f 84 62 01 00 00    	je     f0102cf1 <env_alloc+0x177>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102b8f:	83 ec 0c             	sub    $0xc,%esp
f0102b92:	6a 01                	push   $0x1
f0102b94:	e8 67 e3 ff ff       	call   f0100f00 <page_alloc>
f0102b99:	83 c4 10             	add    $0x10,%esp
f0102b9c:	85 c0                	test   %eax,%eax
f0102b9e:	0f 84 54 01 00 00    	je     f0102cf8 <env_alloc+0x17e>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	p->pp_ref++;
f0102ba4:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102ba9:	2b 05 4c 2c 17 f0    	sub    0xf0172c4c,%eax
f0102baf:	c1 f8 03             	sar    $0x3,%eax
f0102bb2:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102bb5:	89 c2                	mov    %eax,%edx
f0102bb7:	c1 ea 0c             	shr    $0xc,%edx
f0102bba:	3b 15 44 2c 17 f0    	cmp    0xf0172c44,%edx
f0102bc0:	72 12                	jb     f0102bd4 <env_alloc+0x5a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102bc2:	50                   	push   %eax
f0102bc3:	68 30 4f 10 f0       	push   $0xf0104f30
f0102bc8:	6a 56                	push   $0x56
f0102bca:	68 89 57 10 f0       	push   $0xf0105789
f0102bcf:	e8 22 d5 ff ff       	call   f01000f6 <_panic>
	return (void *)(pa + KERNBASE);
f0102bd4:	2d 00 00 00 10       	sub    $0x10000000,%eax
    e->env_pgdir = page2kva(p);
f0102bd9:	89 43 5c             	mov    %eax,0x5c(%ebx)
    memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0102bdc:	83 ec 04             	sub    $0x4,%esp
f0102bdf:	68 00 10 00 00       	push   $0x1000
f0102be4:	ff 35 48 2c 17 f0    	pushl  0xf0172c48
f0102bea:	50                   	push   %eax
f0102beb:	e8 2b 19 00 00       	call   f010451b <memcpy>
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102bf0:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102bf3:	83 c4 10             	add    $0x10,%esp
f0102bf6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102bfb:	77 15                	ja     f0102c12 <env_alloc+0x98>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102bfd:	50                   	push   %eax
f0102bfe:	68 bc 50 10 f0       	push   $0xf01050bc
f0102c03:	68 c0 00 00 00       	push   $0xc0
f0102c08:	68 8f 5a 10 f0       	push   $0xf0105a8f
f0102c0d:	e8 e4 d4 ff ff       	call   f01000f6 <_panic>
f0102c12:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102c18:	83 ca 05             	or     $0x5,%edx
f0102c1b:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102c21:	8b 43 48             	mov    0x48(%ebx),%eax
f0102c24:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102c29:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0102c2e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102c33:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0102c36:	8b 0d 8c 1f 17 f0    	mov    0xf0171f8c,%ecx
f0102c3c:	89 da                	mov    %ebx,%edx
f0102c3e:	29 ca                	sub    %ecx,%edx
f0102c40:	c1 fa 05             	sar    $0x5,%edx
f0102c43:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0102c49:	09 d0                	or     %edx,%eax
f0102c4b:	89 43 48             	mov    %eax,0x48(%ebx)
	cprintf("envs: %x, e: %x, e->env_id: %x\n", envs, e, e->env_id);
f0102c4e:	50                   	push   %eax
f0102c4f:	53                   	push   %ebx
f0102c50:	51                   	push   %ecx
f0102c51:	68 08 5b 10 f0       	push   $0xf0105b08
f0102c56:	e8 92 04 00 00       	call   f01030ed <cprintf>

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102c5b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102c5e:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0102c61:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0102c68:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0102c6f:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102c76:	83 c4 0c             	add    $0xc,%esp
f0102c79:	6a 44                	push   $0x44
f0102c7b:	6a 00                	push   $0x0
f0102c7d:	53                   	push   %ebx
f0102c7e:	e8 e3 17 00 00       	call   f0104466 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0102c83:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0102c89:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102c8f:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0102c95:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102c9c:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f0102ca2:	8b 43 44             	mov    0x44(%ebx),%eax
f0102ca5:	a3 90 1f 17 f0       	mov    %eax,0xf0171f90
	*newenv_store = e;
f0102caa:	8b 45 08             	mov    0x8(%ebp),%eax
f0102cad:	89 18                	mov    %ebx,(%eax)

	cprintf("env_id, %x\n", e->env_id);
f0102caf:	83 c4 08             	add    $0x8,%esp
f0102cb2:	ff 73 48             	pushl  0x48(%ebx)
f0102cb5:	68 9a 5a 10 f0       	push   $0xf0105a9a
f0102cba:	e8 2e 04 00 00       	call   f01030ed <cprintf>
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102cbf:	8b 53 48             	mov    0x48(%ebx),%edx
f0102cc2:	a1 88 1f 17 f0       	mov    0xf0171f88,%eax
f0102cc7:	83 c4 10             	add    $0x10,%esp
f0102cca:	85 c0                	test   %eax,%eax
f0102ccc:	74 05                	je     f0102cd3 <env_alloc+0x159>
f0102cce:	8b 40 48             	mov    0x48(%eax),%eax
f0102cd1:	eb 05                	jmp    f0102cd8 <env_alloc+0x15e>
f0102cd3:	b8 00 00 00 00       	mov    $0x0,%eax
f0102cd8:	83 ec 04             	sub    $0x4,%esp
f0102cdb:	52                   	push   %edx
f0102cdc:	50                   	push   %eax
f0102cdd:	68 a6 5a 10 f0       	push   $0xf0105aa6
f0102ce2:	e8 06 04 00 00       	call   f01030ed <cprintf>
	return 0;
f0102ce7:	83 c4 10             	add    $0x10,%esp
f0102cea:	b8 00 00 00 00       	mov    $0x0,%eax
f0102cef:	eb 0c                	jmp    f0102cfd <env_alloc+0x183>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0102cf1:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0102cf6:	eb 05                	jmp    f0102cfd <env_alloc+0x183>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0102cf8:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	*newenv_store = e;

	cprintf("env_id, %x\n", e->env_id);
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0102cfd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102d00:	c9                   	leave  
f0102d01:	c3                   	ret    

f0102d02 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0102d02:	55                   	push   %ebp
f0102d03:	89 e5                	mov    %esp,%ebp
f0102d05:	57                   	push   %edi
f0102d06:	56                   	push   %esi
f0102d07:	53                   	push   %ebx
f0102d08:	83 ec 34             	sub    $0x34,%esp
f0102d0b:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *penv;
	env_alloc(&penv, 0);
f0102d0e:	6a 00                	push   $0x0
f0102d10:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102d13:	50                   	push   %eax
f0102d14:	e8 61 fe ff ff       	call   f0102b7a <env_alloc>
	load_icode(penv, binary);
f0102d19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102d1c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	// LAB 3: Your code here.
	struct Elf *ELFHDR = (struct Elf *) binary;
	struct Proghdr *ph, *eph;

	if (ELFHDR->e_magic != ELF_MAGIC)
f0102d1f:	83 c4 10             	add    $0x10,%esp
f0102d22:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0102d28:	74 17                	je     f0102d41 <env_create+0x3f>
		panic("Not executable!");
f0102d2a:	83 ec 04             	sub    $0x4,%esp
f0102d2d:	68 bb 5a 10 f0       	push   $0xf0105abb
f0102d32:	68 51 01 00 00       	push   $0x151
f0102d37:	68 8f 5a 10 f0       	push   $0xf0105a8f
f0102d3c:	e8 b5 d3 ff ff       	call   f01000f6 <_panic>
	
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
f0102d41:	89 fb                	mov    %edi,%ebx
f0102d43:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + ELFHDR->e_phnum;
f0102d46:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0102d4a:	c1 e6 05             	shl    $0x5,%esi
f0102d4d:	01 de                	add    %ebx,%esi
	//  The ph->p_filesz bytes from the ELF binary, starting at
	//  'binary + ph->p_offset', should be copied to virtual address
	//  ph->p_va.  Any remaining memory bytes should be cleared to zero.
	//  (The ELF header should have ph->p_filesz <= ph->p_memsz.)
	//  Use functions from the previous lab to allocate and map pages.
	lcr3(PADDR(e->env_pgdir));
f0102d4f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102d52:	8b 40 5c             	mov    0x5c(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d55:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d5a:	77 15                	ja     f0102d71 <env_create+0x6f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d5c:	50                   	push   %eax
f0102d5d:	68 bc 50 10 f0       	push   $0xf01050bc
f0102d62:	68 5d 01 00 00       	push   $0x15d
f0102d67:	68 8f 5a 10 f0       	push   $0xf0105a8f
f0102d6c:	e8 85 d3 ff ff       	call   f01000f6 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102d71:	05 00 00 00 10       	add    $0x10000000,%eax
f0102d76:	0f 22 d8             	mov    %eax,%cr3
f0102d79:	eb 50                	jmp    f0102dcb <env_create+0xc9>
	//it's silly to use kern_pgdir here.
	for (; ph < eph; ph++)
		if (ph->p_type == ELF_PROG_LOAD) {
f0102d7b:	83 3b 01             	cmpl   $0x1,(%ebx)
f0102d7e:	75 48                	jne    f0102dc8 <env_create+0xc6>
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0102d80:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0102d83:	8b 53 08             	mov    0x8(%ebx),%edx
f0102d86:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102d89:	e8 95 fc ff ff       	call   f0102a23 <region_alloc>
			memset((void *)ph->p_va, 0, ph->p_memsz);
f0102d8e:	83 ec 04             	sub    $0x4,%esp
f0102d91:	ff 73 14             	pushl  0x14(%ebx)
f0102d94:	6a 00                	push   $0x0
f0102d96:	ff 73 08             	pushl  0x8(%ebx)
f0102d99:	e8 c8 16 00 00       	call   f0104466 <memset>
			memcpy((void *)ph->p_va, binary+ph->p_offset, ph->p_filesz);
f0102d9e:	83 c4 0c             	add    $0xc,%esp
f0102da1:	ff 73 10             	pushl  0x10(%ebx)
f0102da4:	89 f8                	mov    %edi,%eax
f0102da6:	03 43 04             	add    0x4(%ebx),%eax
f0102da9:	50                   	push   %eax
f0102daa:	ff 73 08             	pushl  0x8(%ebx)
f0102dad:	e8 69 17 00 00       	call   f010451b <memcpy>
			//but I'm curious about how exactly p_memsz and p_filesz differs
			cprintf("p_memsz: %x, p_filesz: %x\n", ph->p_memsz, ph->p_filesz);
f0102db2:	83 c4 0c             	add    $0xc,%esp
f0102db5:	ff 73 10             	pushl  0x10(%ebx)
f0102db8:	ff 73 14             	pushl  0x14(%ebx)
f0102dbb:	68 cb 5a 10 f0       	push   $0xf0105acb
f0102dc0:	e8 28 03 00 00       	call   f01030ed <cprintf>
f0102dc5:	83 c4 10             	add    $0x10,%esp
	//  ph->p_va.  Any remaining memory bytes should be cleared to zero.
	//  (The ELF header should have ph->p_filesz <= ph->p_memsz.)
	//  Use functions from the previous lab to allocate and map pages.
	lcr3(PADDR(e->env_pgdir));
	//it's silly to use kern_pgdir here.
	for (; ph < eph; ph++)
f0102dc8:	83 c3 20             	add    $0x20,%ebx
f0102dcb:	39 de                	cmp    %ebx,%esi
f0102dcd:	77 ac                	ja     f0102d7b <env_create+0x79>
			memcpy((void *)ph->p_va, binary+ph->p_offset, ph->p_filesz);
			//but I'm curious about how exactly p_memsz and p_filesz differs
			cprintf("p_memsz: %x, p_filesz: %x\n", ph->p_memsz, ph->p_filesz);
		}
	//we can use this because kern_pgdir is a subset of e->env_pgdir
	lcr3(PADDR(kern_pgdir));
f0102dcf:	a1 48 2c 17 f0       	mov    0xf0172c48,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102dd4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102dd9:	77 15                	ja     f0102df0 <env_create+0xee>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ddb:	50                   	push   %eax
f0102ddc:	68 bc 50 10 f0       	push   $0xf01050bc
f0102de1:	68 68 01 00 00       	push   $0x168
f0102de6:	68 8f 5a 10 f0       	push   $0xf0105a8f
f0102deb:	e8 06 d3 ff ff       	call   f01000f6 <_panic>
f0102df0:	05 00 00 00 10       	add    $0x10000000,%eax
f0102df5:	0f 22 d8             	mov    %eax,%cr3
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	// LAB 3: Your code here.
	e->env_tf.tf_eip = ELFHDR->e_entry;
f0102df8:	8b 47 18             	mov    0x18(%edi),%eax
f0102dfb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102dfe:	89 47 30             	mov    %eax,0x30(%edi)
	region_alloc(e, (void *) (USTACKTOP - PGSIZE), PGSIZE);
f0102e01:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0102e06:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0102e0b:	89 f8                	mov    %edi,%eax
f0102e0d:	e8 11 fc ff ff       	call   f0102a23 <region_alloc>
{
	// LAB 3: Your code here.
	struct Env *penv;
	env_alloc(&penv, 0);
	load_icode(penv, binary);
}
f0102e12:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e15:	5b                   	pop    %ebx
f0102e16:	5e                   	pop    %esi
f0102e17:	5f                   	pop    %edi
f0102e18:	5d                   	pop    %ebp
f0102e19:	c3                   	ret    

f0102e1a <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0102e1a:	55                   	push   %ebp
f0102e1b:	89 e5                	mov    %esp,%ebp
f0102e1d:	57                   	push   %edi
f0102e1e:	56                   	push   %esi
f0102e1f:	53                   	push   %ebx
f0102e20:	83 ec 1c             	sub    $0x1c,%esp
f0102e23:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0102e26:	8b 15 88 1f 17 f0    	mov    0xf0171f88,%edx
f0102e2c:	39 fa                	cmp    %edi,%edx
f0102e2e:	75 29                	jne    f0102e59 <env_free+0x3f>
		lcr3(PADDR(kern_pgdir));
f0102e30:	a1 48 2c 17 f0       	mov    0xf0172c48,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e35:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102e3a:	77 15                	ja     f0102e51 <env_free+0x37>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e3c:	50                   	push   %eax
f0102e3d:	68 bc 50 10 f0       	push   $0xf01050bc
f0102e42:	68 8e 01 00 00       	push   $0x18e
f0102e47:	68 8f 5a 10 f0       	push   $0xf0105a8f
f0102e4c:	e8 a5 d2 ff ff       	call   f01000f6 <_panic>
f0102e51:	05 00 00 00 10       	add    $0x10000000,%eax
f0102e56:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102e59:	8b 4f 48             	mov    0x48(%edi),%ecx
f0102e5c:	85 d2                	test   %edx,%edx
f0102e5e:	74 05                	je     f0102e65 <env_free+0x4b>
f0102e60:	8b 42 48             	mov    0x48(%edx),%eax
f0102e63:	eb 05                	jmp    f0102e6a <env_free+0x50>
f0102e65:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e6a:	83 ec 04             	sub    $0x4,%esp
f0102e6d:	51                   	push   %ecx
f0102e6e:	50                   	push   %eax
f0102e6f:	68 e6 5a 10 f0       	push   $0xf0105ae6
f0102e74:	e8 74 02 00 00       	call   f01030ed <cprintf>
f0102e79:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102e7c:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0102e83:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102e86:	89 d0                	mov    %edx,%eax
f0102e88:	c1 e0 02             	shl    $0x2,%eax
f0102e8b:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0102e8e:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102e91:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0102e94:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0102e9a:	0f 84 a8 00 00 00    	je     f0102f48 <env_free+0x12e>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0102ea0:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ea6:	89 f0                	mov    %esi,%eax
f0102ea8:	c1 e8 0c             	shr    $0xc,%eax
f0102eab:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102eae:	39 05 44 2c 17 f0    	cmp    %eax,0xf0172c44
f0102eb4:	77 15                	ja     f0102ecb <env_free+0xb1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102eb6:	56                   	push   %esi
f0102eb7:	68 30 4f 10 f0       	push   $0xf0104f30
f0102ebc:	68 9d 01 00 00       	push   $0x19d
f0102ec1:	68 8f 5a 10 f0       	push   $0xf0105a8f
f0102ec6:	e8 2b d2 ff ff       	call   f01000f6 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102ecb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102ece:	c1 e0 16             	shl    $0x16,%eax
f0102ed1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102ed4:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0102ed9:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0102ee0:	01 
f0102ee1:	74 17                	je     f0102efa <env_free+0xe0>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102ee3:	83 ec 08             	sub    $0x8,%esp
f0102ee6:	89 d8                	mov    %ebx,%eax
f0102ee8:	c1 e0 0c             	shl    $0xc,%eax
f0102eeb:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0102eee:	50                   	push   %eax
f0102eef:	ff 77 5c             	pushl  0x5c(%edi)
f0102ef2:	e8 5f e2 ff ff       	call   f0101156 <page_remove>
f0102ef7:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102efa:	83 c3 01             	add    $0x1,%ebx
f0102efd:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0102f03:	75 d4                	jne    f0102ed9 <env_free+0xbf>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0102f05:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102f08:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102f0b:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102f12:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102f15:	3b 05 44 2c 17 f0    	cmp    0xf0172c44,%eax
f0102f1b:	72 14                	jb     f0102f31 <env_free+0x117>
		panic("pa2page called with invalid pa");
f0102f1d:	83 ec 04             	sub    $0x4,%esp
f0102f20:	68 60 50 10 f0       	push   $0xf0105060
f0102f25:	6a 4f                	push   $0x4f
f0102f27:	68 89 57 10 f0       	push   $0xf0105789
f0102f2c:	e8 c5 d1 ff ff       	call   f01000f6 <_panic>
		page_decref(pa2page(pa));
f0102f31:	83 ec 0c             	sub    $0xc,%esp
f0102f34:	a1 4c 2c 17 f0       	mov    0xf0172c4c,%eax
f0102f39:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102f3c:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0102f3f:	50                   	push   %eax
f0102f40:	e8 68 e0 ff ff       	call   f0100fad <page_decref>
f0102f45:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102f48:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0102f4c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102f4f:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102f54:	0f 85 29 ff ff ff    	jne    f0102e83 <env_free+0x69>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0102f5a:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102f5d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102f62:	77 15                	ja     f0102f79 <env_free+0x15f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f64:	50                   	push   %eax
f0102f65:	68 bc 50 10 f0       	push   $0xf01050bc
f0102f6a:	68 ab 01 00 00       	push   $0x1ab
f0102f6f:	68 8f 5a 10 f0       	push   $0xf0105a8f
f0102f74:	e8 7d d1 ff ff       	call   f01000f6 <_panic>
	e->env_pgdir = 0;
f0102f79:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102f80:	05 00 00 00 10       	add    $0x10000000,%eax
f0102f85:	c1 e8 0c             	shr    $0xc,%eax
f0102f88:	3b 05 44 2c 17 f0    	cmp    0xf0172c44,%eax
f0102f8e:	72 14                	jb     f0102fa4 <env_free+0x18a>
		panic("pa2page called with invalid pa");
f0102f90:	83 ec 04             	sub    $0x4,%esp
f0102f93:	68 60 50 10 f0       	push   $0xf0105060
f0102f98:	6a 4f                	push   $0x4f
f0102f9a:	68 89 57 10 f0       	push   $0xf0105789
f0102f9f:	e8 52 d1 ff ff       	call   f01000f6 <_panic>
	page_decref(pa2page(pa));
f0102fa4:	83 ec 0c             	sub    $0xc,%esp
f0102fa7:	8b 15 4c 2c 17 f0    	mov    0xf0172c4c,%edx
f0102fad:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0102fb0:	50                   	push   %eax
f0102fb1:	e8 f7 df ff ff       	call   f0100fad <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0102fb6:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0102fbd:	a1 90 1f 17 f0       	mov    0xf0171f90,%eax
f0102fc2:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0102fc5:	89 3d 90 1f 17 f0    	mov    %edi,0xf0171f90
}
f0102fcb:	83 c4 10             	add    $0x10,%esp
f0102fce:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102fd1:	5b                   	pop    %ebx
f0102fd2:	5e                   	pop    %esi
f0102fd3:	5f                   	pop    %edi
f0102fd4:	5d                   	pop    %ebp
f0102fd5:	c3                   	ret    

f0102fd6 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f0102fd6:	55                   	push   %ebp
f0102fd7:	89 e5                	mov    %esp,%ebp
f0102fd9:	83 ec 14             	sub    $0x14,%esp
	env_free(e);
f0102fdc:	ff 75 08             	pushl  0x8(%ebp)
f0102fdf:	e8 36 fe ff ff       	call   f0102e1a <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0102fe4:	c7 04 24 28 5b 10 f0 	movl   $0xf0105b28,(%esp)
f0102feb:	e8 fd 00 00 00       	call   f01030ed <cprintf>
f0102ff0:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f0102ff3:	83 ec 0c             	sub    $0xc,%esp
f0102ff6:	6a 00                	push   $0x0
f0102ff8:	e8 f8 d8 ff ff       	call   f01008f5 <monitor>
f0102ffd:	83 c4 10             	add    $0x10,%esp
f0103000:	eb f1                	jmp    f0102ff3 <env_destroy+0x1d>

f0103002 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103002:	55                   	push   %ebp
f0103003:	89 e5                	mov    %esp,%ebp
f0103005:	83 ec 0c             	sub    $0xc,%esp
	__asm __volatile("movl %0,%%esp\n"
f0103008:	8b 65 08             	mov    0x8(%ebp),%esp
f010300b:	61                   	popa   
f010300c:	07                   	pop    %es
f010300d:	1f                   	pop    %ds
f010300e:	83 c4 08             	add    $0x8,%esp
f0103011:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103012:	68 fc 5a 10 f0       	push   $0xf0105afc
f0103017:	68 d3 01 00 00       	push   $0x1d3
f010301c:	68 8f 5a 10 f0       	push   $0xf0105a8f
f0103021:	e8 d0 d0 ff ff       	call   f01000f6 <_panic>

f0103026 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103026:	55                   	push   %ebp
f0103027:	89 e5                	mov    %esp,%ebp
f0103029:	53                   	push   %ebx
f010302a:	83 ec 10             	sub    $0x10,%esp
f010302d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	// cprintf("curenv: %x, e: %x\n", curenv, e);
	cprintf("\n");
f0103030:	68 48 5a 10 f0       	push   $0xf0105a48
f0103035:	e8 b3 00 00 00       	call   f01030ed <cprintf>
	if (curenv != e) {
f010303a:	83 c4 10             	add    $0x10,%esp
f010303d:	39 1d 88 1f 17 f0    	cmp    %ebx,0xf0171f88
f0103043:	74 38                	je     f010307d <env_run+0x57>
		// if (curenv->env_status == ENV_RUNNING)
		// 	curenv->env_status = ENV_RUNNABLE;
		curenv = e;
f0103045:	89 1d 88 1f 17 f0    	mov    %ebx,0xf0171f88
		e->env_status = ENV_RUNNING;
f010304b:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
		e->env_runs++;
f0103052:	83 43 58 01          	addl   $0x1,0x58(%ebx)
		lcr3(PADDR(e->env_pgdir));
f0103056:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103059:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010305e:	77 15                	ja     f0103075 <env_run+0x4f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103060:	50                   	push   %eax
f0103061:	68 bc 50 10 f0       	push   $0xf01050bc
f0103066:	68 f9 01 00 00       	push   $0x1f9
f010306b:	68 8f 5a 10 f0       	push   $0xf0105a8f
f0103070:	e8 81 d0 ff ff       	call   f01000f6 <_panic>
f0103075:	05 00 00 00 10       	add    $0x10000000,%eax
f010307a:	0f 22 d8             	mov    %eax,%cr3
	}
	env_pop_tf(&e->env_tf);
f010307d:	83 ec 0c             	sub    $0xc,%esp
f0103080:	53                   	push   %ebx
f0103081:	e8 7c ff ff ff       	call   f0103002 <env_pop_tf>

f0103086 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103086:	55                   	push   %ebp
f0103087:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103089:	ba 70 00 00 00       	mov    $0x70,%edx
f010308e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103091:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103092:	ba 71 00 00 00       	mov    $0x71,%edx
f0103097:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103098:	0f b6 c0             	movzbl %al,%eax
}
f010309b:	5d                   	pop    %ebp
f010309c:	c3                   	ret    

f010309d <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010309d:	55                   	push   %ebp
f010309e:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01030a0:	ba 70 00 00 00       	mov    $0x70,%edx
f01030a5:	8b 45 08             	mov    0x8(%ebp),%eax
f01030a8:	ee                   	out    %al,(%dx)
f01030a9:	ba 71 00 00 00       	mov    $0x71,%edx
f01030ae:	8b 45 0c             	mov    0xc(%ebp),%eax
f01030b1:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01030b2:	5d                   	pop    %ebp
f01030b3:	c3                   	ret    

f01030b4 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01030b4:	55                   	push   %ebp
f01030b5:	89 e5                	mov    %esp,%ebp
f01030b7:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01030ba:	ff 75 08             	pushl  0x8(%ebp)
f01030bd:	e8 a9 d5 ff ff       	call   f010066b <cputchar>
	*cnt++;
}
f01030c2:	83 c4 10             	add    $0x10,%esp
f01030c5:	c9                   	leave  
f01030c6:	c3                   	ret    

f01030c7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01030c7:	55                   	push   %ebp
f01030c8:	89 e5                	mov    %esp,%ebp
f01030ca:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01030cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01030d4:	ff 75 0c             	pushl  0xc(%ebp)
f01030d7:	ff 75 08             	pushl  0x8(%ebp)
f01030da:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01030dd:	50                   	push   %eax
f01030de:	68 b4 30 10 f0       	push   $0xf01030b4
f01030e3:	e8 11 0d 00 00       	call   f0103df9 <vprintfmt>
	return cnt;
}
f01030e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01030eb:	c9                   	leave  
f01030ec:	c3                   	ret    

f01030ed <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01030ed:	55                   	push   %ebp
f01030ee:	89 e5                	mov    %esp,%ebp
f01030f0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01030f3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01030f6:	50                   	push   %eax
f01030f7:	ff 75 08             	pushl  0x8(%ebp)
f01030fa:	e8 c8 ff ff ff       	call   f01030c7 <vcprintf>
	va_end(ap);

	return cnt;
}
f01030ff:	c9                   	leave  
f0103100:	c3                   	ret    

f0103101 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103101:	55                   	push   %ebp
f0103102:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103104:	b8 c0 27 17 f0       	mov    $0xf01727c0,%eax
f0103109:	c7 05 c4 27 17 f0 00 	movl   $0xf0000000,0xf01727c4
f0103110:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0103113:	66 c7 05 c8 27 17 f0 	movw   $0x10,0xf01727c8
f010311a:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f010311c:	66 c7 05 48 b3 11 f0 	movw   $0x68,0xf011b348
f0103123:	68 00 
f0103125:	66 a3 4a b3 11 f0    	mov    %ax,0xf011b34a
f010312b:	89 c2                	mov    %eax,%edx
f010312d:	c1 ea 10             	shr    $0x10,%edx
f0103130:	88 15 4c b3 11 f0    	mov    %dl,0xf011b34c
f0103136:	c6 05 4e b3 11 f0 40 	movb   $0x40,0xf011b34e
f010313d:	c1 e8 18             	shr    $0x18,%eax
f0103140:	a2 4f b3 11 f0       	mov    %al,0xf011b34f
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103145:	c6 05 4d b3 11 f0 89 	movb   $0x89,0xf011b34d
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f010314c:	b8 28 00 00 00       	mov    $0x28,%eax
f0103151:	0f 00 d8             	ltr    %ax
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f0103154:	b8 50 b3 11 f0       	mov    $0xf011b350,%eax
f0103159:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f010315c:	5d                   	pop    %ebp
f010315d:	c3                   	ret    

f010315e <trap_init>:



void
trap_init(void)
{
f010315e:	55                   	push   %ebp
f010315f:	89 e5                	mov    %esp,%ebp
	void th12();
	void th13();
	void th14();
	void th16();
    void th48();
	SETGATE(idt[0], 0, GD_KT, th0, 0);
f0103161:	b8 d8 37 10 f0       	mov    $0xf01037d8,%eax
f0103166:	66 a3 a0 1f 17 f0    	mov    %ax,0xf0171fa0
f010316c:	66 c7 05 a2 1f 17 f0 	movw   $0x8,0xf0171fa2
f0103173:	08 00 
f0103175:	c6 05 a4 1f 17 f0 00 	movb   $0x0,0xf0171fa4
f010317c:	c6 05 a5 1f 17 f0 8e 	movb   $0x8e,0xf0171fa5
f0103183:	c1 e8 10             	shr    $0x10,%eax
f0103186:	66 a3 a6 1f 17 f0    	mov    %ax,0xf0171fa6
	SETGATE(idt[1], 0, GD_KT, th1, 0);
f010318c:	b8 de 37 10 f0       	mov    $0xf01037de,%eax
f0103191:	66 a3 a8 1f 17 f0    	mov    %ax,0xf0171fa8
f0103197:	66 c7 05 aa 1f 17 f0 	movw   $0x8,0xf0171faa
f010319e:	08 00 
f01031a0:	c6 05 ac 1f 17 f0 00 	movb   $0x0,0xf0171fac
f01031a7:	c6 05 ad 1f 17 f0 8e 	movb   $0x8e,0xf0171fad
f01031ae:	c1 e8 10             	shr    $0x10,%eax
f01031b1:	66 a3 ae 1f 17 f0    	mov    %ax,0xf0171fae
    /////////////////////DPL = 3; breakpoint;
	SETGATE(idt[3], 0, GD_KT, th3, 3);
f01031b7:	b8 e4 37 10 f0       	mov    $0xf01037e4,%eax
f01031bc:	66 a3 b8 1f 17 f0    	mov    %ax,0xf0171fb8
f01031c2:	66 c7 05 ba 1f 17 f0 	movw   $0x8,0xf0171fba
f01031c9:	08 00 
f01031cb:	c6 05 bc 1f 17 f0 00 	movb   $0x0,0xf0171fbc
f01031d2:	c6 05 bd 1f 17 f0 ee 	movb   $0xee,0xf0171fbd
f01031d9:	c1 e8 10             	shr    $0x10,%eax
f01031dc:	66 a3 be 1f 17 f0    	mov    %ax,0xf0171fbe
	SETGATE(idt[4], 0, GD_KT, th4, 0);
f01031e2:	b8 ea 37 10 f0       	mov    $0xf01037ea,%eax
f01031e7:	66 a3 c0 1f 17 f0    	mov    %ax,0xf0171fc0
f01031ed:	66 c7 05 c2 1f 17 f0 	movw   $0x8,0xf0171fc2
f01031f4:	08 00 
f01031f6:	c6 05 c4 1f 17 f0 00 	movb   $0x0,0xf0171fc4
f01031fd:	c6 05 c5 1f 17 f0 8e 	movb   $0x8e,0xf0171fc5
f0103204:	c1 e8 10             	shr    $0x10,%eax
f0103207:	66 a3 c6 1f 17 f0    	mov    %ax,0xf0171fc6
	SETGATE(idt[5], 0, GD_KT, th5, 0);
f010320d:	b8 f0 37 10 f0       	mov    $0xf01037f0,%eax
f0103212:	66 a3 c8 1f 17 f0    	mov    %ax,0xf0171fc8
f0103218:	66 c7 05 ca 1f 17 f0 	movw   $0x8,0xf0171fca
f010321f:	08 00 
f0103221:	c6 05 cc 1f 17 f0 00 	movb   $0x0,0xf0171fcc
f0103228:	c6 05 cd 1f 17 f0 8e 	movb   $0x8e,0xf0171fcd
f010322f:	c1 e8 10             	shr    $0x10,%eax
f0103232:	66 a3 ce 1f 17 f0    	mov    %ax,0xf0171fce
	SETGATE(idt[6], 0, GD_KT, th6, 0);
f0103238:	b8 f6 37 10 f0       	mov    $0xf01037f6,%eax
f010323d:	66 a3 d0 1f 17 f0    	mov    %ax,0xf0171fd0
f0103243:	66 c7 05 d2 1f 17 f0 	movw   $0x8,0xf0171fd2
f010324a:	08 00 
f010324c:	c6 05 d4 1f 17 f0 00 	movb   $0x0,0xf0171fd4
f0103253:	c6 05 d5 1f 17 f0 8e 	movb   $0x8e,0xf0171fd5
f010325a:	c1 e8 10             	shr    $0x10,%eax
f010325d:	66 a3 d6 1f 17 f0    	mov    %ax,0xf0171fd6
	SETGATE(idt[7], 0, GD_KT, th7, 0);
f0103263:	b8 fc 37 10 f0       	mov    $0xf01037fc,%eax
f0103268:	66 a3 d8 1f 17 f0    	mov    %ax,0xf0171fd8
f010326e:	66 c7 05 da 1f 17 f0 	movw   $0x8,0xf0171fda
f0103275:	08 00 
f0103277:	c6 05 dc 1f 17 f0 00 	movb   $0x0,0xf0171fdc
f010327e:	c6 05 dd 1f 17 f0 8e 	movb   $0x8e,0xf0171fdd
f0103285:	c1 e8 10             	shr    $0x10,%eax
f0103288:	66 a3 de 1f 17 f0    	mov    %ax,0xf0171fde
	SETGATE(idt[8], 0, GD_KT, th8, 0);
f010328e:	b8 02 38 10 f0       	mov    $0xf0103802,%eax
f0103293:	66 a3 e0 1f 17 f0    	mov    %ax,0xf0171fe0
f0103299:	66 c7 05 e2 1f 17 f0 	movw   $0x8,0xf0171fe2
f01032a0:	08 00 
f01032a2:	c6 05 e4 1f 17 f0 00 	movb   $0x0,0xf0171fe4
f01032a9:	c6 05 e5 1f 17 f0 8e 	movb   $0x8e,0xf0171fe5
f01032b0:	c1 e8 10             	shr    $0x10,%eax
f01032b3:	66 a3 e6 1f 17 f0    	mov    %ax,0xf0171fe6
	SETGATE(idt[9], 0, GD_KT, th9, 0);
f01032b9:	b8 06 38 10 f0       	mov    $0xf0103806,%eax
f01032be:	66 a3 e8 1f 17 f0    	mov    %ax,0xf0171fe8
f01032c4:	66 c7 05 ea 1f 17 f0 	movw   $0x8,0xf0171fea
f01032cb:	08 00 
f01032cd:	c6 05 ec 1f 17 f0 00 	movb   $0x0,0xf0171fec
f01032d4:	c6 05 ed 1f 17 f0 8e 	movb   $0x8e,0xf0171fed
f01032db:	c1 e8 10             	shr    $0x10,%eax
f01032de:	66 a3 ee 1f 17 f0    	mov    %ax,0xf0171fee
	SETGATE(idt[10], 0, GD_KT, th10, 0);
f01032e4:	b8 0c 38 10 f0       	mov    $0xf010380c,%eax
f01032e9:	66 a3 f0 1f 17 f0    	mov    %ax,0xf0171ff0
f01032ef:	66 c7 05 f2 1f 17 f0 	movw   $0x8,0xf0171ff2
f01032f6:	08 00 
f01032f8:	c6 05 f4 1f 17 f0 00 	movb   $0x0,0xf0171ff4
f01032ff:	c6 05 f5 1f 17 f0 8e 	movb   $0x8e,0xf0171ff5
f0103306:	c1 e8 10             	shr    $0x10,%eax
f0103309:	66 a3 f6 1f 17 f0    	mov    %ax,0xf0171ff6
	SETGATE(idt[11], 0, GD_KT, th11, 0);
f010330f:	b8 10 38 10 f0       	mov    $0xf0103810,%eax
f0103314:	66 a3 f8 1f 17 f0    	mov    %ax,0xf0171ff8
f010331a:	66 c7 05 fa 1f 17 f0 	movw   $0x8,0xf0171ffa
f0103321:	08 00 
f0103323:	c6 05 fc 1f 17 f0 00 	movb   $0x0,0xf0171ffc
f010332a:	c6 05 fd 1f 17 f0 8e 	movb   $0x8e,0xf0171ffd
f0103331:	c1 e8 10             	shr    $0x10,%eax
f0103334:	66 a3 fe 1f 17 f0    	mov    %ax,0xf0171ffe
	SETGATE(idt[12], 0, GD_KT, th12, 0);
f010333a:	b8 14 38 10 f0       	mov    $0xf0103814,%eax
f010333f:	66 a3 00 20 17 f0    	mov    %ax,0xf0172000
f0103345:	66 c7 05 02 20 17 f0 	movw   $0x8,0xf0172002
f010334c:	08 00 
f010334e:	c6 05 04 20 17 f0 00 	movb   $0x0,0xf0172004
f0103355:	c6 05 05 20 17 f0 8e 	movb   $0x8e,0xf0172005
f010335c:	c1 e8 10             	shr    $0x10,%eax
f010335f:	66 a3 06 20 17 f0    	mov    %ax,0xf0172006
	SETGATE(idt[13], 0, GD_KT, th13, 0);
f0103365:	b8 18 38 10 f0       	mov    $0xf0103818,%eax
f010336a:	66 a3 08 20 17 f0    	mov    %ax,0xf0172008
f0103370:	66 c7 05 0a 20 17 f0 	movw   $0x8,0xf017200a
f0103377:	08 00 
f0103379:	c6 05 0c 20 17 f0 00 	movb   $0x0,0xf017200c
f0103380:	c6 05 0d 20 17 f0 8e 	movb   $0x8e,0xf017200d
f0103387:	c1 e8 10             	shr    $0x10,%eax
f010338a:	66 a3 0e 20 17 f0    	mov    %ax,0xf017200e
	SETGATE(idt[14], 0, GD_KT, th14, 0);
f0103390:	b8 1c 38 10 f0       	mov    $0xf010381c,%eax
f0103395:	66 a3 10 20 17 f0    	mov    %ax,0xf0172010
f010339b:	66 c7 05 12 20 17 f0 	movw   $0x8,0xf0172012
f01033a2:	08 00 
f01033a4:	c6 05 14 20 17 f0 00 	movb   $0x0,0xf0172014
f01033ab:	c6 05 15 20 17 f0 8e 	movb   $0x8e,0xf0172015
f01033b2:	c1 e8 10             	shr    $0x10,%eax
f01033b5:	66 a3 16 20 17 f0    	mov    %ax,0xf0172016
	SETGATE(idt[16], 0, GD_KT, th16, 0);
f01033bb:	b8 20 38 10 f0       	mov    $0xf0103820,%eax
f01033c0:	66 a3 20 20 17 f0    	mov    %ax,0xf0172020
f01033c6:	66 c7 05 22 20 17 f0 	movw   $0x8,0xf0172022
f01033cd:	08 00 
f01033cf:	c6 05 24 20 17 f0 00 	movb   $0x0,0xf0172024
f01033d6:	c6 05 25 20 17 f0 8e 	movb   $0x8e,0xf0172025
f01033dd:	c1 e8 10             	shr    $0x10,%eax
f01033e0:	66 a3 26 20 17 f0    	mov    %ax,0xf0172026
	SETGATE(idt[48], 0, GD_KT, th48, 3);
f01033e6:	b8 26 38 10 f0       	mov    $0xf0103826,%eax
f01033eb:	66 a3 20 21 17 f0    	mov    %ax,0xf0172120
f01033f1:	66 c7 05 22 21 17 f0 	movw   $0x8,0xf0172122
f01033f8:	08 00 
f01033fa:	c6 05 24 21 17 f0 00 	movb   $0x0,0xf0172124
f0103401:	c6 05 25 21 17 f0 ee 	movb   $0xee,0xf0172125
f0103408:	c1 e8 10             	shr    $0x10,%eax
f010340b:	66 a3 26 21 17 f0    	mov    %ax,0xf0172126
		else if (i!=2 && i!=15) {
			SETGATE(idt[i], 0, GD_KT, funs[i], 0);
		}
	SETGATE(idt[48], 0, GD_KT, funs[48], 3);*/
	// Per-CPU setup 
	trap_init_percpu();
f0103411:	e8 eb fc ff ff       	call   f0103101 <trap_init_percpu>
}
f0103416:	5d                   	pop    %ebp
f0103417:	c3                   	ret    

f0103418 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103418:	55                   	push   %ebp
f0103419:	89 e5                	mov    %esp,%ebp
f010341b:	53                   	push   %ebx
f010341c:	83 ec 0c             	sub    $0xc,%esp
f010341f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103422:	ff 33                	pushl  (%ebx)
f0103424:	68 5e 5b 10 f0       	push   $0xf0105b5e
f0103429:	e8 bf fc ff ff       	call   f01030ed <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f010342e:	83 c4 08             	add    $0x8,%esp
f0103431:	ff 73 04             	pushl  0x4(%ebx)
f0103434:	68 6d 5b 10 f0       	push   $0xf0105b6d
f0103439:	e8 af fc ff ff       	call   f01030ed <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010343e:	83 c4 08             	add    $0x8,%esp
f0103441:	ff 73 08             	pushl  0x8(%ebx)
f0103444:	68 7c 5b 10 f0       	push   $0xf0105b7c
f0103449:	e8 9f fc ff ff       	call   f01030ed <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f010344e:	83 c4 08             	add    $0x8,%esp
f0103451:	ff 73 0c             	pushl  0xc(%ebx)
f0103454:	68 8b 5b 10 f0       	push   $0xf0105b8b
f0103459:	e8 8f fc ff ff       	call   f01030ed <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f010345e:	83 c4 08             	add    $0x8,%esp
f0103461:	ff 73 10             	pushl  0x10(%ebx)
f0103464:	68 9a 5b 10 f0       	push   $0xf0105b9a
f0103469:	e8 7f fc ff ff       	call   f01030ed <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f010346e:	83 c4 08             	add    $0x8,%esp
f0103471:	ff 73 14             	pushl  0x14(%ebx)
f0103474:	68 a9 5b 10 f0       	push   $0xf0105ba9
f0103479:	e8 6f fc ff ff       	call   f01030ed <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010347e:	83 c4 08             	add    $0x8,%esp
f0103481:	ff 73 18             	pushl  0x18(%ebx)
f0103484:	68 b8 5b 10 f0       	push   $0xf0105bb8
f0103489:	e8 5f fc ff ff       	call   f01030ed <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010348e:	83 c4 08             	add    $0x8,%esp
f0103491:	ff 73 1c             	pushl  0x1c(%ebx)
f0103494:	68 c7 5b 10 f0       	push   $0xf0105bc7
f0103499:	e8 4f fc ff ff       	call   f01030ed <cprintf>
}
f010349e:	83 c4 10             	add    $0x10,%esp
f01034a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01034a4:	c9                   	leave  
f01034a5:	c3                   	ret    

f01034a6 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f01034a6:	55                   	push   %ebp
f01034a7:	89 e5                	mov    %esp,%ebp
f01034a9:	56                   	push   %esi
f01034aa:	53                   	push   %ebx
f01034ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f01034ae:	83 ec 08             	sub    $0x8,%esp
f01034b1:	53                   	push   %ebx
f01034b2:	68 10 5d 10 f0       	push   $0xf0105d10
f01034b7:	e8 31 fc ff ff       	call   f01030ed <cprintf>
	print_regs(&tf->tf_regs);
f01034bc:	89 1c 24             	mov    %ebx,(%esp)
f01034bf:	e8 54 ff ff ff       	call   f0103418 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01034c4:	83 c4 08             	add    $0x8,%esp
f01034c7:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01034cb:	50                   	push   %eax
f01034cc:	68 18 5c 10 f0       	push   $0xf0105c18
f01034d1:	e8 17 fc ff ff       	call   f01030ed <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01034d6:	83 c4 08             	add    $0x8,%esp
f01034d9:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01034dd:	50                   	push   %eax
f01034de:	68 2b 5c 10 f0       	push   $0xf0105c2b
f01034e3:	e8 05 fc ff ff       	call   f01030ed <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01034e8:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01034eb:	83 c4 10             	add    $0x10,%esp
f01034ee:	83 f8 13             	cmp    $0x13,%eax
f01034f1:	77 09                	ja     f01034fc <print_trapframe+0x56>
		return excnames[trapno];
f01034f3:	8b 14 85 00 5f 10 f0 	mov    -0xfefa100(,%eax,4),%edx
f01034fa:	eb 10                	jmp    f010350c <print_trapframe+0x66>
	if (trapno == T_SYSCALL)
		return "System call";
	return "(unknown trap)";
f01034fc:	83 f8 30             	cmp    $0x30,%eax
f01034ff:	b9 e2 5b 10 f0       	mov    $0xf0105be2,%ecx
f0103504:	ba d6 5b 10 f0       	mov    $0xf0105bd6,%edx
f0103509:	0f 45 d1             	cmovne %ecx,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010350c:	83 ec 04             	sub    $0x4,%esp
f010350f:	52                   	push   %edx
f0103510:	50                   	push   %eax
f0103511:	68 3e 5c 10 f0       	push   $0xf0105c3e
f0103516:	e8 d2 fb ff ff       	call   f01030ed <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010351b:	83 c4 10             	add    $0x10,%esp
f010351e:	3b 1d a0 27 17 f0    	cmp    0xf01727a0,%ebx
f0103524:	75 1a                	jne    f0103540 <print_trapframe+0x9a>
f0103526:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010352a:	75 14                	jne    f0103540 <print_trapframe+0x9a>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f010352c:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010352f:	83 ec 08             	sub    $0x8,%esp
f0103532:	50                   	push   %eax
f0103533:	68 50 5c 10 f0       	push   $0xf0105c50
f0103538:	e8 b0 fb ff ff       	call   f01030ed <cprintf>
f010353d:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103540:	83 ec 08             	sub    $0x8,%esp
f0103543:	ff 73 2c             	pushl  0x2c(%ebx)
f0103546:	68 5f 5c 10 f0       	push   $0xf0105c5f
f010354b:	e8 9d fb ff ff       	call   f01030ed <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103550:	83 c4 10             	add    $0x10,%esp
f0103553:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103557:	75 49                	jne    f01035a2 <print_trapframe+0xfc>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103559:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f010355c:	89 c2                	mov    %eax,%edx
f010355e:	83 e2 01             	and    $0x1,%edx
f0103561:	ba fc 5b 10 f0       	mov    $0xf0105bfc,%edx
f0103566:	b9 f1 5b 10 f0       	mov    $0xf0105bf1,%ecx
f010356b:	0f 44 ca             	cmove  %edx,%ecx
f010356e:	89 c2                	mov    %eax,%edx
f0103570:	83 e2 02             	and    $0x2,%edx
f0103573:	ba 0e 5c 10 f0       	mov    $0xf0105c0e,%edx
f0103578:	be 08 5c 10 f0       	mov    $0xf0105c08,%esi
f010357d:	0f 45 d6             	cmovne %esi,%edx
f0103580:	83 e0 04             	and    $0x4,%eax
f0103583:	be 61 5d 10 f0       	mov    $0xf0105d61,%esi
f0103588:	b8 13 5c 10 f0       	mov    $0xf0105c13,%eax
f010358d:	0f 44 c6             	cmove  %esi,%eax
f0103590:	51                   	push   %ecx
f0103591:	52                   	push   %edx
f0103592:	50                   	push   %eax
f0103593:	68 6d 5c 10 f0       	push   $0xf0105c6d
f0103598:	e8 50 fb ff ff       	call   f01030ed <cprintf>
f010359d:	83 c4 10             	add    $0x10,%esp
f01035a0:	eb 10                	jmp    f01035b2 <print_trapframe+0x10c>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01035a2:	83 ec 0c             	sub    $0xc,%esp
f01035a5:	68 48 5a 10 f0       	push   $0xf0105a48
f01035aa:	e8 3e fb ff ff       	call   f01030ed <cprintf>
f01035af:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01035b2:	83 ec 08             	sub    $0x8,%esp
f01035b5:	ff 73 30             	pushl  0x30(%ebx)
f01035b8:	68 7c 5c 10 f0       	push   $0xf0105c7c
f01035bd:	e8 2b fb ff ff       	call   f01030ed <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01035c2:	83 c4 08             	add    $0x8,%esp
f01035c5:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01035c9:	50                   	push   %eax
f01035ca:	68 8b 5c 10 f0       	push   $0xf0105c8b
f01035cf:	e8 19 fb ff ff       	call   f01030ed <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01035d4:	83 c4 08             	add    $0x8,%esp
f01035d7:	ff 73 38             	pushl  0x38(%ebx)
f01035da:	68 9e 5c 10 f0       	push   $0xf0105c9e
f01035df:	e8 09 fb ff ff       	call   f01030ed <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01035e4:	83 c4 10             	add    $0x10,%esp
f01035e7:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01035eb:	74 25                	je     f0103612 <print_trapframe+0x16c>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01035ed:	83 ec 08             	sub    $0x8,%esp
f01035f0:	ff 73 3c             	pushl  0x3c(%ebx)
f01035f3:	68 ad 5c 10 f0       	push   $0xf0105cad
f01035f8:	e8 f0 fa ff ff       	call   f01030ed <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01035fd:	83 c4 08             	add    $0x8,%esp
f0103600:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103604:	50                   	push   %eax
f0103605:	68 bc 5c 10 f0       	push   $0xf0105cbc
f010360a:	e8 de fa ff ff       	call   f01030ed <cprintf>
f010360f:	83 c4 10             	add    $0x10,%esp
	}
}
f0103612:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103615:	5b                   	pop    %ebx
f0103616:	5e                   	pop    %esi
f0103617:	5d                   	pop    %ebp
f0103618:	c3                   	ret    

f0103619 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103619:	55                   	push   %ebp
f010361a:	89 e5                	mov    %esp,%ebp
f010361c:	53                   	push   %ebx
f010361d:	83 ec 04             	sub    $0x4,%esp
f0103620:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103623:	0f 20 d0             	mov    %cr2,%eax
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs&3) == 0)
f0103626:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f010362a:	75 17                	jne    f0103643 <page_fault_handler+0x2a>
		panic("Kernel page fault!");
f010362c:	83 ec 04             	sub    $0x4,%esp
f010362f:	68 cf 5c 10 f0       	push   $0xf0105ccf
f0103634:	68 0d 01 00 00       	push   $0x10d
f0103639:	68 e2 5c 10 f0       	push   $0xf0105ce2
f010363e:	e8 b3 ca ff ff       	call   f01000f6 <_panic>

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103643:	ff 73 30             	pushl  0x30(%ebx)
f0103646:	50                   	push   %eax
f0103647:	a1 88 1f 17 f0       	mov    0xf0171f88,%eax
f010364c:	ff 70 48             	pushl  0x48(%eax)
f010364f:	68 ac 5e 10 f0       	push   $0xf0105eac
f0103654:	e8 94 fa ff ff       	call   f01030ed <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103659:	89 1c 24             	mov    %ebx,(%esp)
f010365c:	e8 45 fe ff ff       	call   f01034a6 <print_trapframe>
	env_destroy(curenv);
f0103661:	83 c4 04             	add    $0x4,%esp
f0103664:	ff 35 88 1f 17 f0    	pushl  0xf0171f88
f010366a:	e8 67 f9 ff ff       	call   f0102fd6 <env_destroy>
}
f010366f:	83 c4 10             	add    $0x10,%esp
f0103672:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103675:	c9                   	leave  
f0103676:	c3                   	ret    

f0103677 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103677:	55                   	push   %ebp
f0103678:	89 e5                	mov    %esp,%ebp
f010367a:	57                   	push   %edi
f010367b:	56                   	push   %esi
f010367c:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f010367f:	fc                   	cld    

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0103680:	9c                   	pushf  
f0103681:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103682:	f6 c4 02             	test   $0x2,%ah
f0103685:	74 19                	je     f01036a0 <trap+0x29>
f0103687:	68 ee 5c 10 f0       	push   $0xf0105cee
f010368c:	68 a3 57 10 f0       	push   $0xf01057a3
f0103691:	68 e4 00 00 00       	push   $0xe4
f0103696:	68 e2 5c 10 f0       	push   $0xf0105ce2
f010369b:	e8 56 ca ff ff       	call   f01000f6 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f01036a0:	83 ec 08             	sub    $0x8,%esp
f01036a3:	56                   	push   %esi
f01036a4:	68 07 5d 10 f0       	push   $0xf0105d07
f01036a9:	e8 3f fa ff ff       	call   f01030ed <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f01036ae:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01036b2:	83 e0 03             	and    $0x3,%eax
f01036b5:	83 c4 10             	add    $0x10,%esp
f01036b8:	66 83 f8 03          	cmp    $0x3,%ax
f01036bc:	75 31                	jne    f01036ef <trap+0x78>
		// Trapped from user mode.
		assert(curenv);
f01036be:	a1 88 1f 17 f0       	mov    0xf0171f88,%eax
f01036c3:	85 c0                	test   %eax,%eax
f01036c5:	75 19                	jne    f01036e0 <trap+0x69>
f01036c7:	68 22 5d 10 f0       	push   $0xf0105d22
f01036cc:	68 a3 57 10 f0       	push   $0xf01057a3
f01036d1:	68 ea 00 00 00       	push   $0xea
f01036d6:	68 e2 5c 10 f0       	push   $0xf0105ce2
f01036db:	e8 16 ca ff ff       	call   f01000f6 <_panic>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01036e0:	b9 11 00 00 00       	mov    $0x11,%ecx
f01036e5:	89 c7                	mov    %eax,%edi
f01036e7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01036e9:	8b 35 88 1f 17 f0    	mov    0xf0171f88,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01036ef:	89 35 a0 27 17 f0    	mov    %esi,0xf01727a0
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	if (tf->tf_trapno == T_PGFLT) {
f01036f5:	8b 46 28             	mov    0x28(%esi),%eax
f01036f8:	83 f8 0e             	cmp    $0xe,%eax
f01036fb:	75 1d                	jne    f010371a <trap+0xa3>
		cprintf("PAGE FAULT\n");
f01036fd:	83 ec 0c             	sub    $0xc,%esp
f0103700:	68 29 5d 10 f0       	push   $0xf0105d29
f0103705:	e8 e3 f9 ff ff       	call   f01030ed <cprintf>
		page_fault_handler(tf);
f010370a:	89 34 24             	mov    %esi,(%esp)
f010370d:	e8 07 ff ff ff       	call   f0103619 <page_fault_handler>
f0103712:	83 c4 10             	add    $0x10,%esp
f0103715:	e9 8d 00 00 00       	jmp    f01037a7 <trap+0x130>
		return;
	}
	if (tf->tf_trapno == T_BRKPT) {
f010371a:	83 f8 03             	cmp    $0x3,%eax
f010371d:	75 1a                	jne    f0103739 <trap+0xc2>
		cprintf("BREAK POINT\n");
f010371f:	83 ec 0c             	sub    $0xc,%esp
f0103722:	68 35 5d 10 f0       	push   $0xf0105d35
f0103727:	e8 c1 f9 ff ff       	call   f01030ed <cprintf>
		monitor(tf);
f010372c:	89 34 24             	mov    %esi,(%esp)
f010372f:	e8 c1 d1 ff ff       	call   f01008f5 <monitor>
f0103734:	83 c4 10             	add    $0x10,%esp
f0103737:	eb 6e                	jmp    f01037a7 <trap+0x130>
		return;
	}
	if (tf->tf_trapno == T_SYSCALL) {
f0103739:	83 f8 30             	cmp    $0x30,%eax
f010373c:	75 2e                	jne    f010376c <trap+0xf5>
		cprintf("SYSTEM CALL\n");
f010373e:	83 ec 0c             	sub    $0xc,%esp
f0103741:	68 42 5d 10 f0       	push   $0xf0105d42
f0103746:	e8 a2 f9 ff ff       	call   f01030ed <cprintf>
		tf->tf_regs.reg_eax = 
			syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f010374b:	83 c4 08             	add    $0x8,%esp
f010374e:	ff 76 04             	pushl  0x4(%esi)
f0103751:	ff 36                	pushl  (%esi)
f0103753:	ff 76 10             	pushl  0x10(%esi)
f0103756:	ff 76 18             	pushl  0x18(%esi)
f0103759:	ff 76 14             	pushl  0x14(%esi)
f010375c:	ff 76 1c             	pushl  0x1c(%esi)
f010375f:	e8 d7 00 00 00       	call   f010383b <syscall>
		monitor(tf);
		return;
	}
	if (tf->tf_trapno == T_SYSCALL) {
		cprintf("SYSTEM CALL\n");
		tf->tf_regs.reg_eax = 
f0103764:	89 46 1c             	mov    %eax,0x1c(%esi)
f0103767:	83 c4 20             	add    $0x20,%esp
f010376a:	eb 3b                	jmp    f01037a7 <trap+0x130>
			syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
				tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
		return;
	}
	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f010376c:	83 ec 0c             	sub    $0xc,%esp
f010376f:	56                   	push   %esi
f0103770:	e8 31 fd ff ff       	call   f01034a6 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103775:	83 c4 10             	add    $0x10,%esp
f0103778:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010377d:	75 17                	jne    f0103796 <trap+0x11f>
		panic("unhandled trap in kernel");
f010377f:	83 ec 04             	sub    $0x4,%esp
f0103782:	68 4f 5d 10 f0       	push   $0xf0105d4f
f0103787:	68 d3 00 00 00       	push   $0xd3
f010378c:	68 e2 5c 10 f0       	push   $0xf0105ce2
f0103791:	e8 60 c9 ff ff       	call   f01000f6 <_panic>
	else {
		env_destroy(curenv);
f0103796:	83 ec 0c             	sub    $0xc,%esp
f0103799:	ff 35 88 1f 17 f0    	pushl  0xf0171f88
f010379f:	e8 32 f8 ff ff       	call   f0102fd6 <env_destroy>
f01037a4:	83 c4 10             	add    $0x10,%esp

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f01037a7:	a1 88 1f 17 f0       	mov    0xf0171f88,%eax
f01037ac:	85 c0                	test   %eax,%eax
f01037ae:	74 06                	je     f01037b6 <trap+0x13f>
f01037b0:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01037b4:	74 19                	je     f01037cf <trap+0x158>
f01037b6:	68 d0 5e 10 f0       	push   $0xf0105ed0
f01037bb:	68 a3 57 10 f0       	push   $0xf01057a3
f01037c0:	68 fc 00 00 00       	push   $0xfc
f01037c5:	68 e2 5c 10 f0       	push   $0xf0105ce2
f01037ca:	e8 27 c9 ff ff       	call   f01000f6 <_panic>
	env_run(curenv);
f01037cf:	83 ec 0c             	sub    $0xc,%esp
f01037d2:	50                   	push   %eax
f01037d3:	e8 4e f8 ff ff       	call   f0103026 <env_run>

f01037d8 <th0>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
    TRAPHANDLER_NOEC(th0, 0)
f01037d8:	6a 00                	push   $0x0
f01037da:	6a 00                	push   $0x0
f01037dc:	eb 4e                	jmp    f010382c <_alltraps>

f01037de <th1>:
	TRAPHANDLER_NOEC(th1, 1)
f01037de:	6a 00                	push   $0x0
f01037e0:	6a 01                	push   $0x1
f01037e2:	eb 48                	jmp    f010382c <_alltraps>

f01037e4 <th3>:
	TRAPHANDLER_NOEC(th3, 3)
f01037e4:	6a 00                	push   $0x0
f01037e6:	6a 03                	push   $0x3
f01037e8:	eb 42                	jmp    f010382c <_alltraps>

f01037ea <th4>:
	TRAPHANDLER_NOEC(th4, 4)
f01037ea:	6a 00                	push   $0x0
f01037ec:	6a 04                	push   $0x4
f01037ee:	eb 3c                	jmp    f010382c <_alltraps>

f01037f0 <th5>:
	TRAPHANDLER_NOEC(th5, 5)
f01037f0:	6a 00                	push   $0x0
f01037f2:	6a 05                	push   $0x5
f01037f4:	eb 36                	jmp    f010382c <_alltraps>

f01037f6 <th6>:
	TRAPHANDLER_NOEC(th6, 6)
f01037f6:	6a 00                	push   $0x0
f01037f8:	6a 06                	push   $0x6
f01037fa:	eb 30                	jmp    f010382c <_alltraps>

f01037fc <th7>:
	TRAPHANDLER_NOEC(th7, 7)
f01037fc:	6a 00                	push   $0x0
f01037fe:	6a 07                	push   $0x7
f0103800:	eb 2a                	jmp    f010382c <_alltraps>

f0103802 <th8>:
	TRAPHANDLER(th8, 8)
f0103802:	6a 08                	push   $0x8
f0103804:	eb 26                	jmp    f010382c <_alltraps>

f0103806 <th9>:
	TRAPHANDLER_NOEC(th9, 9)
f0103806:	6a 00                	push   $0x0
f0103808:	6a 09                	push   $0x9
f010380a:	eb 20                	jmp    f010382c <_alltraps>

f010380c <th10>:
	TRAPHANDLER(th10, 10)
f010380c:	6a 0a                	push   $0xa
f010380e:	eb 1c                	jmp    f010382c <_alltraps>

f0103810 <th11>:
	TRAPHANDLER(th11, 11)
f0103810:	6a 0b                	push   $0xb
f0103812:	eb 18                	jmp    f010382c <_alltraps>

f0103814 <th12>:
	TRAPHANDLER(th12, 12)
f0103814:	6a 0c                	push   $0xc
f0103816:	eb 14                	jmp    f010382c <_alltraps>

f0103818 <th13>:
	TRAPHANDLER(th13, 13)
f0103818:	6a 0d                	push   $0xd
f010381a:	eb 10                	jmp    f010382c <_alltraps>

f010381c <th14>:
	TRAPHANDLER(th14, 14)
f010381c:	6a 0e                	push   $0xe
f010381e:	eb 0c                	jmp    f010382c <_alltraps>

f0103820 <th16>:
	TRAPHANDLER_NOEC(th16, 16)
f0103820:	6a 00                	push   $0x0
f0103822:	6a 10                	push   $0x10
f0103824:	eb 06                	jmp    f010382c <_alltraps>

f0103826 <th48>:
	TRAPHANDLER_NOEC(th48, 48)
f0103826:	6a 00                	push   $0x0
f0103828:	6a 30                	push   $0x30
f010382a:	eb 00                	jmp    f010382c <_alltraps>

f010382c <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
    	pushl %ds
f010382c:	1e                   	push   %ds
    	pushl %es
f010382d:	06                   	push   %es
    	pushal
f010382e:	60                   	pusha  
    	pushl $GD_KD
f010382f:	6a 10                	push   $0x10
    	popl %ds
f0103831:	1f                   	pop    %ds
    	pushl $GD_KD
f0103832:	6a 10                	push   $0x10
    	popl %es
f0103834:	07                   	pop    %es
    	pushl %esp
f0103835:	54                   	push   %esp
    	call trap
f0103836:	e8 3c fe ff ff       	call   f0103677 <trap>

f010383b <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f010383b:	55                   	push   %ebp
f010383c:	89 e5                	mov    %esp,%ebp
f010383e:	83 ec 18             	sub    $0x18,%esp
f0103841:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	switch (syscallno) {
f0103844:	83 f8 01             	cmp    $0x1,%eax
f0103847:	74 18                	je     f0103861 <syscall+0x26>
f0103849:	83 f8 01             	cmp    $0x1,%eax
f010384c:	72 22                	jb     f0103870 <syscall+0x35>
f010384e:	83 f8 02             	cmp    $0x2,%eax
f0103851:	0f 84 ae 00 00 00    	je     f0103905 <syscall+0xca>
f0103857:	83 f8 03             	cmp    $0x3,%eax
f010385a:	74 44                	je     f01038a0 <syscall+0x65>
f010385c:	e9 ae 00 00 00       	jmp    f010390f <syscall+0xd4>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0103861:	e8 b3 cc ff ff       	call   f0100519 <cons_getc>
	// LAB 3: Your code here.

	switch (syscallno) {
		case SYS_cgetc:
			sys_cgetc();
			return 0;
f0103866:	b8 00 00 00 00       	mov    $0x0,%eax
f010386b:	e9 a4 00 00 00       	jmp    f0103914 <syscall+0xd9>
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
    user_mem_assert(curenv, s, len, 0);
f0103870:	6a 00                	push   $0x0
f0103872:	ff 75 10             	pushl  0x10(%ebp)
f0103875:	ff 75 0c             	pushl  0xc(%ebp)
f0103878:	ff 35 88 1f 17 f0    	pushl  0xf0171f88
f010387e:	e8 56 f1 ff ff       	call   f01029d9 <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0103883:	83 c4 0c             	add    $0xc,%esp
f0103886:	ff 75 0c             	pushl  0xc(%ebp)
f0103889:	ff 75 10             	pushl  0x10(%ebp)
f010388c:	68 50 5f 10 f0       	push   $0xf0105f50
f0103891:	e8 57 f8 ff ff       	call   f01030ed <cprintf>
f0103896:	83 c4 10             	add    $0x10,%esp
		case SYS_cgetc:
			sys_cgetc();
			return 0;
		case SYS_cputs:
			sys_cputs((char*)a1, a2);
			return 0;
f0103899:	b8 00 00 00 00       	mov    $0x0,%eax
f010389e:	eb 74                	jmp    f0103914 <syscall+0xd9>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01038a0:	83 ec 04             	sub    $0x4,%esp
f01038a3:	6a 01                	push   $0x1
f01038a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01038a8:	50                   	push   %eax
f01038a9:	ff 75 0c             	pushl  0xc(%ebp)
f01038ac:	e8 dd f1 ff ff       	call   f0102a8e <envid2env>
f01038b1:	83 c4 10             	add    $0x10,%esp
f01038b4:	85 c0                	test   %eax,%eax
f01038b6:	78 5c                	js     f0103914 <syscall+0xd9>
		return r;
	if (e == curenv)
f01038b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01038bb:	8b 15 88 1f 17 f0    	mov    0xf0171f88,%edx
f01038c1:	39 d0                	cmp    %edx,%eax
f01038c3:	75 15                	jne    f01038da <syscall+0x9f>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f01038c5:	83 ec 08             	sub    $0x8,%esp
f01038c8:	ff 70 48             	pushl  0x48(%eax)
f01038cb:	68 55 5f 10 f0       	push   $0xf0105f55
f01038d0:	e8 18 f8 ff ff       	call   f01030ed <cprintf>
f01038d5:	83 c4 10             	add    $0x10,%esp
f01038d8:	eb 16                	jmp    f01038f0 <syscall+0xb5>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f01038da:	83 ec 04             	sub    $0x4,%esp
f01038dd:	ff 70 48             	pushl  0x48(%eax)
f01038e0:	ff 72 48             	pushl  0x48(%edx)
f01038e3:	68 70 5f 10 f0       	push   $0xf0105f70
f01038e8:	e8 00 f8 ff ff       	call   f01030ed <cprintf>
f01038ed:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f01038f0:	83 ec 0c             	sub    $0xc,%esp
f01038f3:	ff 75 f4             	pushl  -0xc(%ebp)
f01038f6:	e8 db f6 ff ff       	call   f0102fd6 <env_destroy>
f01038fb:	83 c4 10             	add    $0x10,%esp
	return 0;
f01038fe:	b8 00 00 00 00       	mov    $0x0,%eax
f0103903:	eb 0f                	jmp    f0103914 <syscall+0xd9>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0103905:	a1 88 1f 17 f0       	mov    0xf0171f88,%eax
f010390a:	8b 40 48             	mov    0x48(%eax),%eax
			sys_cputs((char*)a1, a2);
			return 0;
		case SYS_env_destroy:
			return sys_env_destroy(a1);
		case SYS_getenvid:
			return sys_getenvid();
f010390d:	eb 05                	jmp    f0103914 <syscall+0xd9>
		default:
			return -E_INVAL;
f010390f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
}
f0103914:	c9                   	leave  
f0103915:	c3                   	ret    

f0103916 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0103916:	55                   	push   %ebp
f0103917:	89 e5                	mov    %esp,%ebp
f0103919:	57                   	push   %edi
f010391a:	56                   	push   %esi
f010391b:	53                   	push   %ebx
f010391c:	83 ec 14             	sub    $0x14,%esp
f010391f:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103922:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103925:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103928:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f010392b:	8b 1a                	mov    (%edx),%ebx
f010392d:	8b 01                	mov    (%ecx),%eax
f010392f:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103932:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0103939:	eb 7f                	jmp    f01039ba <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f010393b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010393e:	01 d8                	add    %ebx,%eax
f0103940:	89 c6                	mov    %eax,%esi
f0103942:	c1 ee 1f             	shr    $0x1f,%esi
f0103945:	01 c6                	add    %eax,%esi
f0103947:	d1 fe                	sar    %esi
f0103949:	8d 04 76             	lea    (%esi,%esi,2),%eax
f010394c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010394f:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0103952:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103954:	eb 03                	jmp    f0103959 <stab_binsearch+0x43>
			m--;
f0103956:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103959:	39 c3                	cmp    %eax,%ebx
f010395b:	7f 0d                	jg     f010396a <stab_binsearch+0x54>
f010395d:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0103961:	83 ea 0c             	sub    $0xc,%edx
f0103964:	39 f9                	cmp    %edi,%ecx
f0103966:	75 ee                	jne    f0103956 <stab_binsearch+0x40>
f0103968:	eb 05                	jmp    f010396f <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010396a:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f010396d:	eb 4b                	jmp    f01039ba <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010396f:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103972:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103975:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103979:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010397c:	76 11                	jbe    f010398f <stab_binsearch+0x79>
			*region_left = m;
f010397e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103981:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0103983:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103986:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010398d:	eb 2b                	jmp    f01039ba <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f010398f:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0103992:	73 14                	jae    f01039a8 <stab_binsearch+0x92>
			*region_right = m - 1;
f0103994:	83 e8 01             	sub    $0x1,%eax
f0103997:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010399a:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010399d:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010399f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01039a6:	eb 12                	jmp    f01039ba <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01039a8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01039ab:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f01039ad:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01039b1:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01039b3:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01039ba:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01039bd:	0f 8e 78 ff ff ff    	jle    f010393b <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01039c3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01039c7:	75 0f                	jne    f01039d8 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f01039c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01039cc:	8b 00                	mov    (%eax),%eax
f01039ce:	83 e8 01             	sub    $0x1,%eax
f01039d1:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01039d4:	89 06                	mov    %eax,(%esi)
f01039d6:	eb 2c                	jmp    f0103a04 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01039d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01039db:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01039dd:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01039e0:	8b 0e                	mov    (%esi),%ecx
f01039e2:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01039e5:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01039e8:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01039eb:	eb 03                	jmp    f01039f0 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01039ed:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01039f0:	39 c8                	cmp    %ecx,%eax
f01039f2:	7e 0b                	jle    f01039ff <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f01039f4:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01039f8:	83 ea 0c             	sub    $0xc,%edx
f01039fb:	39 df                	cmp    %ebx,%edi
f01039fd:	75 ee                	jne    f01039ed <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f01039ff:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103a02:	89 06                	mov    %eax,(%esi)
	}
}
f0103a04:	83 c4 14             	add    $0x14,%esp
f0103a07:	5b                   	pop    %ebx
f0103a08:	5e                   	pop    %esi
f0103a09:	5f                   	pop    %edi
f0103a0a:	5d                   	pop    %ebp
f0103a0b:	c3                   	ret    

f0103a0c <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103a0c:	55                   	push   %ebp
f0103a0d:	89 e5                	mov    %esp,%ebp
f0103a0f:	57                   	push   %edi
f0103a10:	56                   	push   %esi
f0103a11:	53                   	push   %ebx
f0103a12:	83 ec 3c             	sub    $0x3c,%esp
f0103a15:	8b 75 08             	mov    0x8(%ebp),%esi
f0103a18:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103a1b:	c7 03 88 5f 10 f0    	movl   $0xf0105f88,(%ebx)
	info->eip_line = 0;
f0103a21:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0103a28:	c7 43 08 88 5f 10 f0 	movl   $0xf0105f88,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0103a2f:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0103a36:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0103a39:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103a40:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0103a46:	0f 87 8a 00 00 00    	ja     f0103ad6 <debuginfo_eip+0xca>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f0103a4c:	6a 04                	push   $0x4
f0103a4e:	6a 10                	push   $0x10
f0103a50:	68 00 00 20 00       	push   $0x200000
f0103a55:	ff 35 88 1f 17 f0    	pushl  0xf0171f88
f0103a5b:	e8 cc ee ff ff       	call   f010292c <user_mem_check>
f0103a60:	83 c4 10             	add    $0x10,%esp
f0103a63:	85 c0                	test   %eax,%eax
f0103a65:	0f 85 2d 02 00 00    	jne    f0103c98 <debuginfo_eip+0x28c>
			return -1;
		stabs = usd->stabs;
f0103a6b:	a1 00 00 20 00       	mov    0x200000,%eax
f0103a70:	89 c1                	mov    %eax,%ecx
f0103a72:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f0103a75:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f0103a7b:	a1 08 00 20 00       	mov    0x200008,%eax
f0103a80:	89 45 b8             	mov    %eax,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f0103a83:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0103a89:	89 55 bc             	mov    %edx,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *) stabs, stab_end - stabs, 0) < 0 || user_mem_check(curenv, (void *) stabstr, stabstr_end - stabstr, 0) < 0) {
f0103a8c:	6a 00                	push   $0x0
f0103a8e:	89 f8                	mov    %edi,%eax
f0103a90:	29 c8                	sub    %ecx,%eax
f0103a92:	c1 f8 02             	sar    $0x2,%eax
f0103a95:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0103a9b:	50                   	push   %eax
f0103a9c:	51                   	push   %ecx
f0103a9d:	ff 35 88 1f 17 f0    	pushl  0xf0171f88
f0103aa3:	e8 84 ee ff ff       	call   f010292c <user_mem_check>
f0103aa8:	83 c4 10             	add    $0x10,%esp
f0103aab:	85 c0                	test   %eax,%eax
f0103aad:	0f 88 ec 01 00 00    	js     f0103c9f <debuginfo_eip+0x293>
f0103ab3:	6a 00                	push   $0x0
f0103ab5:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0103ab8:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0103abb:	29 ca                	sub    %ecx,%edx
f0103abd:	52                   	push   %edx
f0103abe:	51                   	push   %ecx
f0103abf:	ff 35 88 1f 17 f0    	pushl  0xf0171f88
f0103ac5:	e8 62 ee ff ff       	call   f010292c <user_mem_check>
f0103aca:	83 c4 10             	add    $0x10,%esp
f0103acd:	85 c0                	test   %eax,%eax
f0103acf:	79 1f                	jns    f0103af0 <debuginfo_eip+0xe4>
f0103ad1:	e9 d0 01 00 00       	jmp    f0103ca6 <debuginfo_eip+0x29a>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0103ad6:	c7 45 bc cb 07 11 f0 	movl   $0xf01107cb,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0103add:	c7 45 b8 ad dc 10 f0 	movl   $0xf010dcad,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0103ae4:	bf ac dc 10 f0       	mov    $0xf010dcac,%edi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0103ae9:	c7 45 c0 a0 61 10 f0 	movl   $0xf01061a0,-0x40(%ebp)
    return -1;
}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103af0:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0103af3:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f0103af6:	0f 83 b1 01 00 00    	jae    f0103cad <debuginfo_eip+0x2a1>
f0103afc:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0103b00:	0f 85 ae 01 00 00    	jne    f0103cb4 <debuginfo_eip+0x2a8>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103b06:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103b0d:	2b 7d c0             	sub    -0x40(%ebp),%edi
f0103b10:	c1 ff 02             	sar    $0x2,%edi
f0103b13:	69 c7 ab aa aa aa    	imul   $0xaaaaaaab,%edi,%eax
f0103b19:	83 e8 01             	sub    $0x1,%eax
f0103b1c:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103b1f:	83 ec 08             	sub    $0x8,%esp
f0103b22:	56                   	push   %esi
f0103b23:	6a 64                	push   $0x64
f0103b25:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0103b28:	89 d1                	mov    %edx,%ecx
f0103b2a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103b2d:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103b30:	89 f8                	mov    %edi,%eax
f0103b32:	e8 df fd ff ff       	call   f0103916 <stab_binsearch>
	if (lfile == 0)
f0103b37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103b3a:	83 c4 10             	add    $0x10,%esp
f0103b3d:	85 c0                	test   %eax,%eax
f0103b3f:	0f 84 76 01 00 00    	je     f0103cbb <debuginfo_eip+0x2af>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103b45:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0103b48:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b4b:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103b4e:	83 ec 08             	sub    $0x8,%esp
f0103b51:	56                   	push   %esi
f0103b52:	6a 24                	push   $0x24
f0103b54:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0103b57:	89 d1                	mov    %edx,%ecx
f0103b59:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103b5c:	89 f8                	mov    %edi,%eax
f0103b5e:	e8 b3 fd ff ff       	call   f0103916 <stab_binsearch>

	if (lfun <= rfun) {
f0103b63:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103b66:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103b69:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0103b6c:	83 c4 10             	add    $0x10,%esp
f0103b6f:	39 d0                	cmp    %edx,%eax
f0103b71:	7f 2b                	jg     f0103b9e <debuginfo_eip+0x192>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103b73:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103b76:	8d 0c 97             	lea    (%edi,%edx,4),%ecx
f0103b79:	8b 11                	mov    (%ecx),%edx
f0103b7b:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0103b7e:	2b 7d b8             	sub    -0x48(%ebp),%edi
f0103b81:	39 fa                	cmp    %edi,%edx
f0103b83:	73 06                	jae    f0103b8b <debuginfo_eip+0x17f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103b85:	03 55 b8             	add    -0x48(%ebp),%edx
f0103b88:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103b8b:	8b 51 08             	mov    0x8(%ecx),%edx
f0103b8e:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0103b91:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0103b93:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0103b96:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0103b99:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103b9c:	eb 0f                	jmp    f0103bad <debuginfo_eip+0x1a1>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0103b9e:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0103ba1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103ba4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0103ba7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103baa:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103bad:	83 ec 08             	sub    $0x8,%esp
f0103bb0:	6a 3a                	push   $0x3a
f0103bb2:	ff 73 08             	pushl  0x8(%ebx)
f0103bb5:	e8 90 08 00 00       	call   f010444a <strfind>
f0103bba:	2b 43 08             	sub    0x8(%ebx),%eax
f0103bbd:	89 43 0c             	mov    %eax,0xc(%ebx)


	// Search within [lline, rline] for the line number stab.
	// If found, set info->eip_line to the right line number.
	// If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0103bc0:	83 c4 08             	add    $0x8,%esp
f0103bc3:	56                   	push   %esi
f0103bc4:	6a 44                	push   $0x44
f0103bc6:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0103bc9:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0103bcc:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103bcf:	89 f8                	mov    %edi,%eax
f0103bd1:	e8 40 fd ff ff       	call   f0103916 <stab_binsearch>
	if(lline > rline) return -1;
f0103bd6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103bd9:	83 c4 10             	add    $0x10,%esp
f0103bdc:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0103bdf:	0f 8f dd 00 00 00    	jg     f0103cc2 <debuginfo_eip+0x2b6>
	else info->eip_line = stabs[lline].n_desc;
f0103be5:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103be8:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0103beb:	0f b7 4a 06          	movzwl 0x6(%edx),%ecx
f0103bef:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103bf2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103bf5:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0103bf9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103bfc:	eb 0a                	jmp    f0103c08 <debuginfo_eip+0x1fc>
f0103bfe:	83 e8 01             	sub    $0x1,%eax
f0103c01:	83 ea 0c             	sub    $0xc,%edx
f0103c04:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0103c08:	39 c7                	cmp    %eax,%edi
f0103c0a:	7e 05                	jle    f0103c11 <debuginfo_eip+0x205>
f0103c0c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103c0f:	eb 47                	jmp    f0103c58 <debuginfo_eip+0x24c>
	       && stabs[lline].n_type != N_SOL
f0103c11:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0103c15:	80 f9 84             	cmp    $0x84,%cl
f0103c18:	75 0e                	jne    f0103c28 <debuginfo_eip+0x21c>
f0103c1a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103c1d:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0103c21:	74 1c                	je     f0103c3f <debuginfo_eip+0x233>
f0103c23:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103c26:	eb 17                	jmp    f0103c3f <debuginfo_eip+0x233>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103c28:	80 f9 64             	cmp    $0x64,%cl
f0103c2b:	75 d1                	jne    f0103bfe <debuginfo_eip+0x1f2>
f0103c2d:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0103c31:	74 cb                	je     f0103bfe <debuginfo_eip+0x1f2>
f0103c33:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103c36:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0103c3a:	74 03                	je     f0103c3f <debuginfo_eip+0x233>
f0103c3c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103c3f:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0103c42:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103c45:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0103c48:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0103c4b:	8b 75 b8             	mov    -0x48(%ebp),%esi
f0103c4e:	29 f0                	sub    %esi,%eax
f0103c50:	39 c2                	cmp    %eax,%edx
f0103c52:	73 04                	jae    f0103c58 <debuginfo_eip+0x24c>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103c54:	01 f2                	add    %esi,%edx
f0103c56:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103c58:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103c5b:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103c5e:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103c63:	39 f2                	cmp    %esi,%edx
f0103c65:	7d 67                	jge    f0103cce <debuginfo_eip+0x2c2>
		for (lline = lfun + 1;
f0103c67:	83 c2 01             	add    $0x1,%edx
f0103c6a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0103c6d:	89 d0                	mov    %edx,%eax
f0103c6f:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0103c72:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103c75:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0103c78:	eb 04                	jmp    f0103c7e <debuginfo_eip+0x272>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0103c7a:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103c7e:	39 c6                	cmp    %eax,%esi
f0103c80:	7e 47                	jle    f0103cc9 <debuginfo_eip+0x2bd>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103c82:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0103c86:	83 c0 01             	add    $0x1,%eax
f0103c89:	83 c2 0c             	add    $0xc,%edx
f0103c8c:	80 f9 a0             	cmp    $0xa0,%cl
f0103c8f:	74 e9                	je     f0103c7a <debuginfo_eip+0x26e>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103c91:	b8 00 00 00 00       	mov    $0x0,%eax
f0103c96:	eb 36                	jmp    f0103cce <debuginfo_eip+0x2c2>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
			return -1;
f0103c98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103c9d:	eb 2f                	jmp    f0103cce <debuginfo_eip+0x2c2>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *) stabs, stab_end - stabs, 0) < 0 || user_mem_check(curenv, (void *) stabstr, stabstr_end - stabstr, 0) < 0) {
    return -1;
f0103c9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103ca4:	eb 28                	jmp    f0103cce <debuginfo_eip+0x2c2>
f0103ca6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103cab:	eb 21                	jmp    f0103cce <debuginfo_eip+0x2c2>
}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0103cad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103cb2:	eb 1a                	jmp    f0103cce <debuginfo_eip+0x2c2>
f0103cb4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103cb9:	eb 13                	jmp    f0103cce <debuginfo_eip+0x2c2>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0103cbb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103cc0:	eb 0c                	jmp    f0103cce <debuginfo_eip+0x2c2>

	// Search within [lline, rline] for the line number stab.
	// If found, set info->eip_line to the right line number.
	// If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if(lline > rline) return -1;
f0103cc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103cc7:	eb 05                	jmp    f0103cce <debuginfo_eip+0x2c2>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103cc9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103cce:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103cd1:	5b                   	pop    %ebx
f0103cd2:	5e                   	pop    %esi
f0103cd3:	5f                   	pop    %edi
f0103cd4:	5d                   	pop    %ebp
f0103cd5:	c3                   	ret    

f0103cd6 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103cd6:	55                   	push   %ebp
f0103cd7:	89 e5                	mov    %esp,%ebp
f0103cd9:	57                   	push   %edi
f0103cda:	56                   	push   %esi
f0103cdb:	53                   	push   %ebx
f0103cdc:	83 ec 1c             	sub    $0x1c,%esp
f0103cdf:	89 c7                	mov    %eax,%edi
f0103ce1:	89 d6                	mov    %edx,%esi
f0103ce3:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ce6:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103ce9:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103cec:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103cef:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0103cf2:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103cf7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103cfa:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0103cfd:	39 d3                	cmp    %edx,%ebx
f0103cff:	72 05                	jb     f0103d06 <printnum+0x30>
f0103d01:	39 45 10             	cmp    %eax,0x10(%ebp)
f0103d04:	77 45                	ja     f0103d4b <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103d06:	83 ec 0c             	sub    $0xc,%esp
f0103d09:	ff 75 18             	pushl  0x18(%ebp)
f0103d0c:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d0f:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0103d12:	53                   	push   %ebx
f0103d13:	ff 75 10             	pushl  0x10(%ebp)
f0103d16:	83 ec 08             	sub    $0x8,%esp
f0103d19:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103d1c:	ff 75 e0             	pushl  -0x20(%ebp)
f0103d1f:	ff 75 dc             	pushl  -0x24(%ebp)
f0103d22:	ff 75 d8             	pushl  -0x28(%ebp)
f0103d25:	e8 46 09 00 00       	call   f0104670 <__udivdi3>
f0103d2a:	83 c4 18             	add    $0x18,%esp
f0103d2d:	52                   	push   %edx
f0103d2e:	50                   	push   %eax
f0103d2f:	89 f2                	mov    %esi,%edx
f0103d31:	89 f8                	mov    %edi,%eax
f0103d33:	e8 9e ff ff ff       	call   f0103cd6 <printnum>
f0103d38:	83 c4 20             	add    $0x20,%esp
f0103d3b:	eb 18                	jmp    f0103d55 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103d3d:	83 ec 08             	sub    $0x8,%esp
f0103d40:	56                   	push   %esi
f0103d41:	ff 75 18             	pushl  0x18(%ebp)
f0103d44:	ff d7                	call   *%edi
f0103d46:	83 c4 10             	add    $0x10,%esp
f0103d49:	eb 03                	jmp    f0103d4e <printnum+0x78>
f0103d4b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103d4e:	83 eb 01             	sub    $0x1,%ebx
f0103d51:	85 db                	test   %ebx,%ebx
f0103d53:	7f e8                	jg     f0103d3d <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103d55:	83 ec 08             	sub    $0x8,%esp
f0103d58:	56                   	push   %esi
f0103d59:	83 ec 04             	sub    $0x4,%esp
f0103d5c:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103d5f:	ff 75 e0             	pushl  -0x20(%ebp)
f0103d62:	ff 75 dc             	pushl  -0x24(%ebp)
f0103d65:	ff 75 d8             	pushl  -0x28(%ebp)
f0103d68:	e8 33 0a 00 00       	call   f01047a0 <__umoddi3>
f0103d6d:	83 c4 14             	add    $0x14,%esp
f0103d70:	0f be 80 92 5f 10 f0 	movsbl -0xfefa06e(%eax),%eax
f0103d77:	50                   	push   %eax
f0103d78:	ff d7                	call   *%edi
}
f0103d7a:	83 c4 10             	add    $0x10,%esp
f0103d7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103d80:	5b                   	pop    %ebx
f0103d81:	5e                   	pop    %esi
f0103d82:	5f                   	pop    %edi
f0103d83:	5d                   	pop    %ebp
f0103d84:	c3                   	ret    

f0103d85 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0103d85:	55                   	push   %ebp
f0103d86:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103d88:	83 fa 01             	cmp    $0x1,%edx
f0103d8b:	7e 0e                	jle    f0103d9b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0103d8d:	8b 10                	mov    (%eax),%edx
f0103d8f:	8d 4a 08             	lea    0x8(%edx),%ecx
f0103d92:	89 08                	mov    %ecx,(%eax)
f0103d94:	8b 02                	mov    (%edx),%eax
f0103d96:	8b 52 04             	mov    0x4(%edx),%edx
f0103d99:	eb 22                	jmp    f0103dbd <getuint+0x38>
	else if (lflag)
f0103d9b:	85 d2                	test   %edx,%edx
f0103d9d:	74 10                	je     f0103daf <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0103d9f:	8b 10                	mov    (%eax),%edx
f0103da1:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103da4:	89 08                	mov    %ecx,(%eax)
f0103da6:	8b 02                	mov    (%edx),%eax
f0103da8:	ba 00 00 00 00       	mov    $0x0,%edx
f0103dad:	eb 0e                	jmp    f0103dbd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0103daf:	8b 10                	mov    (%eax),%edx
f0103db1:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103db4:	89 08                	mov    %ecx,(%eax)
f0103db6:	8b 02                	mov    (%edx),%eax
f0103db8:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0103dbd:	5d                   	pop    %ebp
f0103dbe:	c3                   	ret    

f0103dbf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103dbf:	55                   	push   %ebp
f0103dc0:	89 e5                	mov    %esp,%ebp
f0103dc2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103dc5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0103dc9:	8b 10                	mov    (%eax),%edx
f0103dcb:	3b 50 04             	cmp    0x4(%eax),%edx
f0103dce:	73 0a                	jae    f0103dda <sprintputch+0x1b>
		*b->buf++ = ch;
f0103dd0:	8d 4a 01             	lea    0x1(%edx),%ecx
f0103dd3:	89 08                	mov    %ecx,(%eax)
f0103dd5:	8b 45 08             	mov    0x8(%ebp),%eax
f0103dd8:	88 02                	mov    %al,(%edx)
}
f0103dda:	5d                   	pop    %ebp
f0103ddb:	c3                   	ret    

f0103ddc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0103ddc:	55                   	push   %ebp
f0103ddd:	89 e5                	mov    %esp,%ebp
f0103ddf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0103de2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103de5:	50                   	push   %eax
f0103de6:	ff 75 10             	pushl  0x10(%ebp)
f0103de9:	ff 75 0c             	pushl  0xc(%ebp)
f0103dec:	ff 75 08             	pushl  0x8(%ebp)
f0103def:	e8 05 00 00 00       	call   f0103df9 <vprintfmt>
	va_end(ap);
}
f0103df4:	83 c4 10             	add    $0x10,%esp
f0103df7:	c9                   	leave  
f0103df8:	c3                   	ret    

f0103df9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0103df9:	55                   	push   %ebp
f0103dfa:	89 e5                	mov    %esp,%ebp
f0103dfc:	57                   	push   %edi
f0103dfd:	56                   	push   %esi
f0103dfe:	53                   	push   %ebx
f0103dff:	83 ec 2c             	sub    $0x2c,%esp
f0103e02:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
    int color = 0;
f0103e05:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0103e0c:	eb 17                	jmp    f0103e25 <vprintfmt+0x2c>
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0103e0e:	85 c0                	test   %eax,%eax
f0103e10:	0f 84 89 03 00 00    	je     f010419f <vprintfmt+0x3a6>
				return;
			putch(ch, putdat);
f0103e16:	83 ec 08             	sub    $0x8,%esp
f0103e19:	ff 75 0c             	pushl  0xc(%ebp)
f0103e1c:	50                   	push   %eax
f0103e1d:	ff 55 08             	call   *0x8(%ebp)
f0103e20:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
    int color = 0;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103e23:	89 f3                	mov    %esi,%ebx
f0103e25:	8d 73 01             	lea    0x1(%ebx),%esi
f0103e28:	0f b6 03             	movzbl (%ebx),%eax
f0103e2b:	83 f8 25             	cmp    $0x25,%eax
f0103e2e:	75 de                	jne    f0103e0e <vprintfmt+0x15>
f0103e30:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f0103e34:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0103e3b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0103e40:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0103e47:	ba 00 00 00 00       	mov    $0x0,%edx
f0103e4c:	eb 0d                	jmp    f0103e5b <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e4e:	89 de                	mov    %ebx,%esi
f0103e50:	eb 09                	jmp    f0103e5b <vprintfmt+0x62>
f0103e52:	89 de                	mov    %ebx,%esi
			break;
        case 'C': 
        //自己补充的控制颜色的代码
            switch(va_arg(ap,int)){
                case 0:
                    color = 0x0c00;
f0103e54:	c7 45 d8 00 0c 00 00 	movl   $0xc00,-0x28(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e5b:	8d 5e 01             	lea    0x1(%esi),%ebx
f0103e5e:	0f b6 06             	movzbl (%esi),%eax
f0103e61:	0f b6 c8             	movzbl %al,%ecx
f0103e64:	83 e8 23             	sub    $0x23,%eax
f0103e67:	3c 55                	cmp    $0x55,%al
f0103e69:	0f 87 10 03 00 00    	ja     f010417f <vprintfmt+0x386>
f0103e6f:	0f b6 c0             	movzbl %al,%eax
f0103e72:	ff 24 85 1c 60 10 f0 	jmp    *-0xfef9fe4(,%eax,4)
f0103e79:	89 de                	mov    %ebx,%esi
		case '-':
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103e7b:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f0103e7f:	eb da                	jmp    f0103e5b <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e81:	89 de                	mov    %ebx,%esi
f0103e83:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0103e88:	8d 04 bf             	lea    (%edi,%edi,4),%eax
f0103e8b:	8d 7c 41 d0          	lea    -0x30(%ecx,%eax,2),%edi
				ch = *fmt;
f0103e8f:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
f0103e92:	8d 41 d0             	lea    -0x30(%ecx),%eax
f0103e95:	83 f8 09             	cmp    $0x9,%eax
f0103e98:	77 33                	ja     f0103ecd <vprintfmt+0xd4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103e9a:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0103e9d:	eb e9                	jmp    f0103e88 <vprintfmt+0x8f>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103e9f:	8b 45 14             	mov    0x14(%ebp),%eax
f0103ea2:	8d 48 04             	lea    0x4(%eax),%ecx
f0103ea5:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0103ea8:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103eaa:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0103eac:	eb 1f                	jmp    f0103ecd <vprintfmt+0xd4>
f0103eae:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103eb1:	85 c0                	test   %eax,%eax
f0103eb3:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103eb8:	0f 49 c8             	cmovns %eax,%ecx
f0103ebb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103ebe:	89 de                	mov    %ebx,%esi
f0103ec0:	eb 99                	jmp    f0103e5b <vprintfmt+0x62>
f0103ec2:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0103ec4:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
f0103ecb:	eb 8e                	jmp    f0103e5b <vprintfmt+0x62>

		process_precision:
			if (width < 0)
f0103ecd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103ed1:	79 88                	jns    f0103e5b <vprintfmt+0x62>
				width = precision, precision = -1;
f0103ed3:	89 7d e0             	mov    %edi,-0x20(%ebp)
f0103ed6:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0103edb:	e9 7b ff ff ff       	jmp    f0103e5b <vprintfmt+0x62>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0103ee0:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103ee3:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0103ee5:	e9 71 ff ff ff       	jmp    f0103e5b <vprintfmt+0x62>

		case 'c':
            ch = va_arg(ap,int)+color;
f0103eea:	8b 45 14             	mov    0x14(%ebp),%eax
f0103eed:	8d 50 04             	lea    0x4(%eax),%edx
f0103ef0:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
f0103ef3:	83 ec 08             	sub    $0x8,%esp
f0103ef6:	ff 75 0c             	pushl  0xc(%ebp)
f0103ef9:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0103efc:	03 08                	add    (%eax),%ecx
f0103efe:	51                   	push   %ecx
f0103eff:	ff 55 08             	call   *0x8(%ebp)
            color = 0;
			break;
f0103f02:	83 c4 10             	add    $0x10,%esp
			goto reswitch;

		case 'c':
            ch = va_arg(ap,int)+color;
			putch(ch, putdat);
            color = 0;
f0103f05:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
			break;
f0103f0c:	e9 14 ff ff ff       	jmp    f0103e25 <vprintfmt+0x2c>
        case 'C': 
        //自己补充的控制颜色的代码
            switch(va_arg(ap,int)){
f0103f11:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f14:	8d 48 04             	lea    0x4(%eax),%ecx
f0103f17:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0103f1a:	8b 00                	mov    (%eax),%eax
f0103f1c:	85 c0                	test   %eax,%eax
f0103f1e:	0f 84 2e ff ff ff    	je     f0103e52 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103f24:	89 de                	mov    %ebx,%esi
f0103f26:	83 f8 01             	cmp    $0x1,%eax
f0103f29:	b8 00 00 00 00       	mov    $0x0,%eax
f0103f2e:	b9 00 0a 00 00       	mov    $0xa00,%ecx
f0103f33:	0f 44 c1             	cmove  %ecx,%eax
f0103f36:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103f39:	e9 1d ff ff ff       	jmp    f0103e5b <vprintfmt+0x62>
            }

            goto reswitch;
		// error message
		case 'e':
			err = va_arg(ap, int);
f0103f3e:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f41:	8d 50 04             	lea    0x4(%eax),%edx
f0103f44:	89 55 14             	mov    %edx,0x14(%ebp)
f0103f47:	8b 00                	mov    (%eax),%eax
f0103f49:	99                   	cltd   
f0103f4a:	31 d0                	xor    %edx,%eax
f0103f4c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103f4e:	83 f8 06             	cmp    $0x6,%eax
f0103f51:	7f 0b                	jg     f0103f5e <vprintfmt+0x165>
f0103f53:	8b 14 85 74 61 10 f0 	mov    -0xfef9e8c(,%eax,4),%edx
f0103f5a:	85 d2                	test   %edx,%edx
f0103f5c:	75 19                	jne    f0103f77 <vprintfmt+0x17e>
				printfmt(putch, putdat, "error %d", err);
f0103f5e:	50                   	push   %eax
f0103f5f:	68 aa 5f 10 f0       	push   $0xf0105faa
f0103f64:	ff 75 0c             	pushl  0xc(%ebp)
f0103f67:	ff 75 08             	pushl  0x8(%ebp)
f0103f6a:	e8 6d fe ff ff       	call   f0103ddc <printfmt>
f0103f6f:	83 c4 10             	add    $0x10,%esp
f0103f72:	e9 ae fe ff ff       	jmp    f0103e25 <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
f0103f77:	52                   	push   %edx
f0103f78:	68 b5 57 10 f0       	push   $0xf01057b5
f0103f7d:	ff 75 0c             	pushl  0xc(%ebp)
f0103f80:	ff 75 08             	pushl  0x8(%ebp)
f0103f83:	e8 54 fe ff ff       	call   f0103ddc <printfmt>
f0103f88:	83 c4 10             	add    $0x10,%esp
f0103f8b:	e9 95 fe ff ff       	jmp    f0103e25 <vprintfmt+0x2c>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103f90:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f93:	8d 50 04             	lea    0x4(%eax),%edx
f0103f96:	89 55 14             	mov    %edx,0x14(%ebp)
f0103f99:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f0103f9b:	85 f6                	test   %esi,%esi
f0103f9d:	b8 a3 5f 10 f0       	mov    $0xf0105fa3,%eax
f0103fa2:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
f0103fa5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103fa9:	0f 8e 89 00 00 00    	jle    f0104038 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103faf:	83 ec 08             	sub    $0x8,%esp
f0103fb2:	57                   	push   %edi
f0103fb3:	56                   	push   %esi
f0103fb4:	e8 47 03 00 00       	call   f0104300 <strnlen>
f0103fb9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103fbc:	29 c1                	sub    %eax,%ecx
f0103fbe:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103fc1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0103fc4:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
f0103fc8:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0103fcb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103fce:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103fd1:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0103fd4:	89 cb                	mov    %ecx,%ebx
f0103fd6:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103fd8:	eb 0e                	jmp    f0103fe8 <vprintfmt+0x1ef>
					putch(padc, putdat);
f0103fda:	83 ec 08             	sub    $0x8,%esp
f0103fdd:	56                   	push   %esi
f0103fde:	57                   	push   %edi
f0103fdf:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103fe2:	83 eb 01             	sub    $0x1,%ebx
f0103fe5:	83 c4 10             	add    $0x10,%esp
f0103fe8:	85 db                	test   %ebx,%ebx
f0103fea:	7f ee                	jg     f0103fda <vprintfmt+0x1e1>
f0103fec:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0103fef:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103ff2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103ff5:	85 c9                	test   %ecx,%ecx
f0103ff7:	b8 00 00 00 00       	mov    $0x0,%eax
f0103ffc:	0f 49 c1             	cmovns %ecx,%eax
f0103fff:	29 c1                	sub    %eax,%ecx
f0104001:	89 cb                	mov    %ecx,%ebx
f0104003:	eb 39                	jmp    f010403e <vprintfmt+0x245>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0104005:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104009:	74 1b                	je     f0104026 <vprintfmt+0x22d>
f010400b:	0f be c0             	movsbl %al,%eax
f010400e:	83 e8 20             	sub    $0x20,%eax
f0104011:	83 f8 5e             	cmp    $0x5e,%eax
f0104014:	76 10                	jbe    f0104026 <vprintfmt+0x22d>
					putch('?', putdat);
f0104016:	83 ec 08             	sub    $0x8,%esp
f0104019:	ff 75 0c             	pushl  0xc(%ebp)
f010401c:	6a 3f                	push   $0x3f
f010401e:	ff 55 08             	call   *0x8(%ebp)
f0104021:	83 c4 10             	add    $0x10,%esp
f0104024:	eb 0d                	jmp    f0104033 <vprintfmt+0x23a>
				else
					putch(ch, putdat);
f0104026:	83 ec 08             	sub    $0x8,%esp
f0104029:	ff 75 0c             	pushl  0xc(%ebp)
f010402c:	52                   	push   %edx
f010402d:	ff 55 08             	call   *0x8(%ebp)
f0104030:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104033:	83 eb 01             	sub    $0x1,%ebx
f0104036:	eb 06                	jmp    f010403e <vprintfmt+0x245>
f0104038:	89 5d 10             	mov    %ebx,0x10(%ebp)
f010403b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010403e:	83 c6 01             	add    $0x1,%esi
f0104041:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
f0104045:	0f be d0             	movsbl %al,%edx
f0104048:	85 d2                	test   %edx,%edx
f010404a:	74 25                	je     f0104071 <vprintfmt+0x278>
f010404c:	85 ff                	test   %edi,%edi
f010404e:	78 b5                	js     f0104005 <vprintfmt+0x20c>
f0104050:	83 ef 01             	sub    $0x1,%edi
f0104053:	79 b0                	jns    f0104005 <vprintfmt+0x20c>
f0104055:	89 d8                	mov    %ebx,%eax
f0104057:	8b 75 08             	mov    0x8(%ebp),%esi
f010405a:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010405d:	89 c3                	mov    %eax,%ebx
f010405f:	eb 16                	jmp    f0104077 <vprintfmt+0x27e>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0104061:	83 ec 08             	sub    $0x8,%esp
f0104064:	57                   	push   %edi
f0104065:	6a 20                	push   $0x20
f0104067:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104069:	83 eb 01             	sub    $0x1,%ebx
f010406c:	83 c4 10             	add    $0x10,%esp
f010406f:	eb 06                	jmp    f0104077 <vprintfmt+0x27e>
f0104071:	8b 75 08             	mov    0x8(%ebp),%esi
f0104074:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104077:	85 db                	test   %ebx,%ebx
f0104079:	7f e6                	jg     f0104061 <vprintfmt+0x268>
f010407b:	89 75 08             	mov    %esi,0x8(%ebp)
f010407e:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0104081:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0104084:	e9 9c fd ff ff       	jmp    f0103e25 <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104089:	83 fa 01             	cmp    $0x1,%edx
f010408c:	7e 10                	jle    f010409e <vprintfmt+0x2a5>
		return va_arg(*ap, long long);
f010408e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104091:	8d 50 08             	lea    0x8(%eax),%edx
f0104094:	89 55 14             	mov    %edx,0x14(%ebp)
f0104097:	8b 30                	mov    (%eax),%esi
f0104099:	8b 78 04             	mov    0x4(%eax),%edi
f010409c:	eb 26                	jmp    f01040c4 <vprintfmt+0x2cb>
	else if (lflag)
f010409e:	85 d2                	test   %edx,%edx
f01040a0:	74 12                	je     f01040b4 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f01040a2:	8b 45 14             	mov    0x14(%ebp),%eax
f01040a5:	8d 50 04             	lea    0x4(%eax),%edx
f01040a8:	89 55 14             	mov    %edx,0x14(%ebp)
f01040ab:	8b 30                	mov    (%eax),%esi
f01040ad:	89 f7                	mov    %esi,%edi
f01040af:	c1 ff 1f             	sar    $0x1f,%edi
f01040b2:	eb 10                	jmp    f01040c4 <vprintfmt+0x2cb>
	else
		return va_arg(*ap, int);
f01040b4:	8b 45 14             	mov    0x14(%ebp),%eax
f01040b7:	8d 50 04             	lea    0x4(%eax),%edx
f01040ba:	89 55 14             	mov    %edx,0x14(%ebp)
f01040bd:	8b 30                	mov    (%eax),%esi
f01040bf:	89 f7                	mov    %esi,%edi
f01040c1:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01040c4:	89 f0                	mov    %esi,%eax
f01040c6:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01040c8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01040cd:	85 ff                	test   %edi,%edi
f01040cf:	79 7b                	jns    f010414c <vprintfmt+0x353>
				putch('-', putdat);
f01040d1:	83 ec 08             	sub    $0x8,%esp
f01040d4:	ff 75 0c             	pushl  0xc(%ebp)
f01040d7:	6a 2d                	push   $0x2d
f01040d9:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f01040dc:	89 f0                	mov    %esi,%eax
f01040de:	89 fa                	mov    %edi,%edx
f01040e0:	f7 d8                	neg    %eax
f01040e2:	83 d2 00             	adc    $0x0,%edx
f01040e5:	f7 da                	neg    %edx
f01040e7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f01040ea:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01040ef:	eb 5b                	jmp    f010414c <vprintfmt+0x353>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01040f1:	8d 45 14             	lea    0x14(%ebp),%eax
f01040f4:	e8 8c fc ff ff       	call   f0103d85 <getuint>
			base = 10;
f01040f9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f01040fe:	eb 4c                	jmp    f010414c <vprintfmt+0x353>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f0104100:	8d 45 14             	lea    0x14(%ebp),%eax
f0104103:	e8 7d fc ff ff       	call   f0103d85 <getuint>
			base = 8;
f0104108:	b9 08 00 00 00       	mov    $0x8,%ecx
            goto number;
f010410d:	eb 3d                	jmp    f010414c <vprintfmt+0x353>
		// pointer
		case 'p':
			putch('0', putdat);
f010410f:	83 ec 08             	sub    $0x8,%esp
f0104112:	ff 75 0c             	pushl  0xc(%ebp)
f0104115:	6a 30                	push   $0x30
f0104117:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f010411a:	83 c4 08             	add    $0x8,%esp
f010411d:	ff 75 0c             	pushl  0xc(%ebp)
f0104120:	6a 78                	push   $0x78
f0104122:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0104125:	8b 45 14             	mov    0x14(%ebp),%eax
f0104128:	8d 50 04             	lea    0x4(%eax),%edx
f010412b:	89 55 14             	mov    %edx,0x14(%ebp)
            goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010412e:	8b 00                	mov    (%eax),%eax
f0104130:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0104135:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0104138:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f010413d:	eb 0d                	jmp    f010414c <vprintfmt+0x353>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010413f:	8d 45 14             	lea    0x14(%ebp),%eax
f0104142:	e8 3e fc ff ff       	call   f0103d85 <getuint>
			base = 16;
f0104147:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f010414c:	83 ec 0c             	sub    $0xc,%esp
f010414f:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
f0104153:	56                   	push   %esi
f0104154:	ff 75 e0             	pushl  -0x20(%ebp)
f0104157:	51                   	push   %ecx
f0104158:	52                   	push   %edx
f0104159:	50                   	push   %eax
f010415a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010415d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104160:	e8 71 fb ff ff       	call   f0103cd6 <printnum>
			break;
f0104165:	83 c4 20             	add    $0x20,%esp
f0104168:	e9 b8 fc ff ff       	jmp    f0103e25 <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010416d:	83 ec 08             	sub    $0x8,%esp
f0104170:	ff 75 0c             	pushl  0xc(%ebp)
f0104173:	51                   	push   %ecx
f0104174:	ff 55 08             	call   *0x8(%ebp)
			break;
f0104177:	83 c4 10             	add    $0x10,%esp
f010417a:	e9 a6 fc ff ff       	jmp    f0103e25 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010417f:	83 ec 08             	sub    $0x8,%esp
f0104182:	ff 75 0c             	pushl  0xc(%ebp)
f0104185:	6a 25                	push   $0x25
f0104187:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f010418a:	83 c4 10             	add    $0x10,%esp
f010418d:	89 f3                	mov    %esi,%ebx
f010418f:	eb 03                	jmp    f0104194 <vprintfmt+0x39b>
f0104191:	83 eb 01             	sub    $0x1,%ebx
f0104194:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f0104198:	75 f7                	jne    f0104191 <vprintfmt+0x398>
f010419a:	e9 86 fc ff ff       	jmp    f0103e25 <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
f010419f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01041a2:	5b                   	pop    %ebx
f01041a3:	5e                   	pop    %esi
f01041a4:	5f                   	pop    %edi
f01041a5:	5d                   	pop    %ebp
f01041a6:	c3                   	ret    

f01041a7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01041a7:	55                   	push   %ebp
f01041a8:	89 e5                	mov    %esp,%ebp
f01041aa:	83 ec 18             	sub    $0x18,%esp
f01041ad:	8b 45 08             	mov    0x8(%ebp),%eax
f01041b0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01041b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01041b6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01041ba:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01041bd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01041c4:	85 c0                	test   %eax,%eax
f01041c6:	74 26                	je     f01041ee <vsnprintf+0x47>
f01041c8:	85 d2                	test   %edx,%edx
f01041ca:	7e 22                	jle    f01041ee <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01041cc:	ff 75 14             	pushl  0x14(%ebp)
f01041cf:	ff 75 10             	pushl  0x10(%ebp)
f01041d2:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01041d5:	50                   	push   %eax
f01041d6:	68 bf 3d 10 f0       	push   $0xf0103dbf
f01041db:	e8 19 fc ff ff       	call   f0103df9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01041e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01041e3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01041e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01041e9:	83 c4 10             	add    $0x10,%esp
f01041ec:	eb 05                	jmp    f01041f3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01041ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01041f3:	c9                   	leave  
f01041f4:	c3                   	ret    

f01041f5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01041f5:	55                   	push   %ebp
f01041f6:	89 e5                	mov    %esp,%ebp
f01041f8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01041fb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01041fe:	50                   	push   %eax
f01041ff:	ff 75 10             	pushl  0x10(%ebp)
f0104202:	ff 75 0c             	pushl  0xc(%ebp)
f0104205:	ff 75 08             	pushl  0x8(%ebp)
f0104208:	e8 9a ff ff ff       	call   f01041a7 <vsnprintf>
	va_end(ap);

	return rc;
}
f010420d:	c9                   	leave  
f010420e:	c3                   	ret    

f010420f <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f010420f:	55                   	push   %ebp
f0104210:	89 e5                	mov    %esp,%ebp
f0104212:	57                   	push   %edi
f0104213:	56                   	push   %esi
f0104214:	53                   	push   %ebx
f0104215:	83 ec 0c             	sub    $0xc,%esp
f0104218:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010421b:	85 c0                	test   %eax,%eax
f010421d:	74 11                	je     f0104230 <readline+0x21>
		cprintf("%s", prompt);
f010421f:	83 ec 08             	sub    $0x8,%esp
f0104222:	50                   	push   %eax
f0104223:	68 b5 57 10 f0       	push   $0xf01057b5
f0104228:	e8 c0 ee ff ff       	call   f01030ed <cprintf>
f010422d:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0104230:	83 ec 0c             	sub    $0xc,%esp
f0104233:	6a 00                	push   $0x0
f0104235:	e8 52 c4 ff ff       	call   f010068c <iscons>
f010423a:	89 c7                	mov    %eax,%edi
f010423c:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010423f:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0104244:	e8 32 c4 ff ff       	call   f010067b <getchar>
f0104249:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010424b:	85 c0                	test   %eax,%eax
f010424d:	79 18                	jns    f0104267 <readline+0x58>
			cprintf("read error: %e\n", c);
f010424f:	83 ec 08             	sub    $0x8,%esp
f0104252:	50                   	push   %eax
f0104253:	68 90 61 10 f0       	push   $0xf0106190
f0104258:	e8 90 ee ff ff       	call   f01030ed <cprintf>
			return NULL;
f010425d:	83 c4 10             	add    $0x10,%esp
f0104260:	b8 00 00 00 00       	mov    $0x0,%eax
f0104265:	eb 79                	jmp    f01042e0 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104267:	83 f8 08             	cmp    $0x8,%eax
f010426a:	0f 94 c2             	sete   %dl
f010426d:	83 f8 7f             	cmp    $0x7f,%eax
f0104270:	0f 94 c0             	sete   %al
f0104273:	08 c2                	or     %al,%dl
f0104275:	74 1a                	je     f0104291 <readline+0x82>
f0104277:	85 f6                	test   %esi,%esi
f0104279:	7e 16                	jle    f0104291 <readline+0x82>
			if (echoing)
f010427b:	85 ff                	test   %edi,%edi
f010427d:	74 0d                	je     f010428c <readline+0x7d>
				cputchar('\b');
f010427f:	83 ec 0c             	sub    $0xc,%esp
f0104282:	6a 08                	push   $0x8
f0104284:	e8 e2 c3 ff ff       	call   f010066b <cputchar>
f0104289:	83 c4 10             	add    $0x10,%esp
			i--;
f010428c:	83 ee 01             	sub    $0x1,%esi
f010428f:	eb b3                	jmp    f0104244 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104291:	83 fb 1f             	cmp    $0x1f,%ebx
f0104294:	7e 23                	jle    f01042b9 <readline+0xaa>
f0104296:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010429c:	7f 1b                	jg     f01042b9 <readline+0xaa>
			if (echoing)
f010429e:	85 ff                	test   %edi,%edi
f01042a0:	74 0c                	je     f01042ae <readline+0x9f>
				cputchar(c);
f01042a2:	83 ec 0c             	sub    $0xc,%esp
f01042a5:	53                   	push   %ebx
f01042a6:	e8 c0 c3 ff ff       	call   f010066b <cputchar>
f01042ab:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01042ae:	88 9e 40 28 17 f0    	mov    %bl,-0xfe8d7c0(%esi)
f01042b4:	8d 76 01             	lea    0x1(%esi),%esi
f01042b7:	eb 8b                	jmp    f0104244 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01042b9:	83 fb 0a             	cmp    $0xa,%ebx
f01042bc:	74 05                	je     f01042c3 <readline+0xb4>
f01042be:	83 fb 0d             	cmp    $0xd,%ebx
f01042c1:	75 81                	jne    f0104244 <readline+0x35>
			if (echoing)
f01042c3:	85 ff                	test   %edi,%edi
f01042c5:	74 0d                	je     f01042d4 <readline+0xc5>
				cputchar('\n');
f01042c7:	83 ec 0c             	sub    $0xc,%esp
f01042ca:	6a 0a                	push   $0xa
f01042cc:	e8 9a c3 ff ff       	call   f010066b <cputchar>
f01042d1:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01042d4:	c6 86 40 28 17 f0 00 	movb   $0x0,-0xfe8d7c0(%esi)
			return buf;
f01042db:	b8 40 28 17 f0       	mov    $0xf0172840,%eax
		}
	}
}
f01042e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01042e3:	5b                   	pop    %ebx
f01042e4:	5e                   	pop    %esi
f01042e5:	5f                   	pop    %edi
f01042e6:	5d                   	pop    %ebp
f01042e7:	c3                   	ret    

f01042e8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01042e8:	55                   	push   %ebp
f01042e9:	89 e5                	mov    %esp,%ebp
f01042eb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01042ee:	b8 00 00 00 00       	mov    $0x0,%eax
f01042f3:	eb 03                	jmp    f01042f8 <strlen+0x10>
		n++;
f01042f5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01042f8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01042fc:	75 f7                	jne    f01042f5 <strlen+0xd>
		n++;
	return n;
}
f01042fe:	5d                   	pop    %ebp
f01042ff:	c3                   	ret    

f0104300 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104300:	55                   	push   %ebp
f0104301:	89 e5                	mov    %esp,%ebp
f0104303:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104306:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104309:	ba 00 00 00 00       	mov    $0x0,%edx
f010430e:	eb 03                	jmp    f0104313 <strnlen+0x13>
		n++;
f0104310:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104313:	39 c2                	cmp    %eax,%edx
f0104315:	74 08                	je     f010431f <strnlen+0x1f>
f0104317:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f010431b:	75 f3                	jne    f0104310 <strnlen+0x10>
f010431d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f010431f:	5d                   	pop    %ebp
f0104320:	c3                   	ret    

f0104321 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104321:	55                   	push   %ebp
f0104322:	89 e5                	mov    %esp,%ebp
f0104324:	53                   	push   %ebx
f0104325:	8b 45 08             	mov    0x8(%ebp),%eax
f0104328:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010432b:	89 c2                	mov    %eax,%edx
f010432d:	83 c2 01             	add    $0x1,%edx
f0104330:	83 c1 01             	add    $0x1,%ecx
f0104333:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0104337:	88 5a ff             	mov    %bl,-0x1(%edx)
f010433a:	84 db                	test   %bl,%bl
f010433c:	75 ef                	jne    f010432d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010433e:	5b                   	pop    %ebx
f010433f:	5d                   	pop    %ebp
f0104340:	c3                   	ret    

f0104341 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104341:	55                   	push   %ebp
f0104342:	89 e5                	mov    %esp,%ebp
f0104344:	53                   	push   %ebx
f0104345:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104348:	53                   	push   %ebx
f0104349:	e8 9a ff ff ff       	call   f01042e8 <strlen>
f010434e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0104351:	ff 75 0c             	pushl  0xc(%ebp)
f0104354:	01 d8                	add    %ebx,%eax
f0104356:	50                   	push   %eax
f0104357:	e8 c5 ff ff ff       	call   f0104321 <strcpy>
	return dst;
}
f010435c:	89 d8                	mov    %ebx,%eax
f010435e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104361:	c9                   	leave  
f0104362:	c3                   	ret    

f0104363 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104363:	55                   	push   %ebp
f0104364:	89 e5                	mov    %esp,%ebp
f0104366:	56                   	push   %esi
f0104367:	53                   	push   %ebx
f0104368:	8b 75 08             	mov    0x8(%ebp),%esi
f010436b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010436e:	89 f3                	mov    %esi,%ebx
f0104370:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104373:	89 f2                	mov    %esi,%edx
f0104375:	eb 0f                	jmp    f0104386 <strncpy+0x23>
		*dst++ = *src;
f0104377:	83 c2 01             	add    $0x1,%edx
f010437a:	0f b6 01             	movzbl (%ecx),%eax
f010437d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104380:	80 39 01             	cmpb   $0x1,(%ecx)
f0104383:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104386:	39 da                	cmp    %ebx,%edx
f0104388:	75 ed                	jne    f0104377 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010438a:	89 f0                	mov    %esi,%eax
f010438c:	5b                   	pop    %ebx
f010438d:	5e                   	pop    %esi
f010438e:	5d                   	pop    %ebp
f010438f:	c3                   	ret    

f0104390 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104390:	55                   	push   %ebp
f0104391:	89 e5                	mov    %esp,%ebp
f0104393:	56                   	push   %esi
f0104394:	53                   	push   %ebx
f0104395:	8b 75 08             	mov    0x8(%ebp),%esi
f0104398:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010439b:	8b 55 10             	mov    0x10(%ebp),%edx
f010439e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01043a0:	85 d2                	test   %edx,%edx
f01043a2:	74 21                	je     f01043c5 <strlcpy+0x35>
f01043a4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01043a8:	89 f2                	mov    %esi,%edx
f01043aa:	eb 09                	jmp    f01043b5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01043ac:	83 c2 01             	add    $0x1,%edx
f01043af:	83 c1 01             	add    $0x1,%ecx
f01043b2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01043b5:	39 c2                	cmp    %eax,%edx
f01043b7:	74 09                	je     f01043c2 <strlcpy+0x32>
f01043b9:	0f b6 19             	movzbl (%ecx),%ebx
f01043bc:	84 db                	test   %bl,%bl
f01043be:	75 ec                	jne    f01043ac <strlcpy+0x1c>
f01043c0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01043c2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01043c5:	29 f0                	sub    %esi,%eax
}
f01043c7:	5b                   	pop    %ebx
f01043c8:	5e                   	pop    %esi
f01043c9:	5d                   	pop    %ebp
f01043ca:	c3                   	ret    

f01043cb <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01043cb:	55                   	push   %ebp
f01043cc:	89 e5                	mov    %esp,%ebp
f01043ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01043d1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01043d4:	eb 06                	jmp    f01043dc <strcmp+0x11>
		p++, q++;
f01043d6:	83 c1 01             	add    $0x1,%ecx
f01043d9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01043dc:	0f b6 01             	movzbl (%ecx),%eax
f01043df:	84 c0                	test   %al,%al
f01043e1:	74 04                	je     f01043e7 <strcmp+0x1c>
f01043e3:	3a 02                	cmp    (%edx),%al
f01043e5:	74 ef                	je     f01043d6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01043e7:	0f b6 c0             	movzbl %al,%eax
f01043ea:	0f b6 12             	movzbl (%edx),%edx
f01043ed:	29 d0                	sub    %edx,%eax
}
f01043ef:	5d                   	pop    %ebp
f01043f0:	c3                   	ret    

f01043f1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01043f1:	55                   	push   %ebp
f01043f2:	89 e5                	mov    %esp,%ebp
f01043f4:	53                   	push   %ebx
f01043f5:	8b 45 08             	mov    0x8(%ebp),%eax
f01043f8:	8b 55 0c             	mov    0xc(%ebp),%edx
f01043fb:	89 c3                	mov    %eax,%ebx
f01043fd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0104400:	eb 06                	jmp    f0104408 <strncmp+0x17>
		n--, p++, q++;
f0104402:	83 c0 01             	add    $0x1,%eax
f0104405:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0104408:	39 d8                	cmp    %ebx,%eax
f010440a:	74 15                	je     f0104421 <strncmp+0x30>
f010440c:	0f b6 08             	movzbl (%eax),%ecx
f010440f:	84 c9                	test   %cl,%cl
f0104411:	74 04                	je     f0104417 <strncmp+0x26>
f0104413:	3a 0a                	cmp    (%edx),%cl
f0104415:	74 eb                	je     f0104402 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104417:	0f b6 00             	movzbl (%eax),%eax
f010441a:	0f b6 12             	movzbl (%edx),%edx
f010441d:	29 d0                	sub    %edx,%eax
f010441f:	eb 05                	jmp    f0104426 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0104421:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0104426:	5b                   	pop    %ebx
f0104427:	5d                   	pop    %ebp
f0104428:	c3                   	ret    

f0104429 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104429:	55                   	push   %ebp
f010442a:	89 e5                	mov    %esp,%ebp
f010442c:	8b 45 08             	mov    0x8(%ebp),%eax
f010442f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104433:	eb 07                	jmp    f010443c <strchr+0x13>
		if (*s == c)
f0104435:	38 ca                	cmp    %cl,%dl
f0104437:	74 0f                	je     f0104448 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0104439:	83 c0 01             	add    $0x1,%eax
f010443c:	0f b6 10             	movzbl (%eax),%edx
f010443f:	84 d2                	test   %dl,%dl
f0104441:	75 f2                	jne    f0104435 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0104443:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104448:	5d                   	pop    %ebp
f0104449:	c3                   	ret    

f010444a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010444a:	55                   	push   %ebp
f010444b:	89 e5                	mov    %esp,%ebp
f010444d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104450:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104454:	eb 03                	jmp    f0104459 <strfind+0xf>
f0104456:	83 c0 01             	add    $0x1,%eax
f0104459:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010445c:	38 ca                	cmp    %cl,%dl
f010445e:	74 04                	je     f0104464 <strfind+0x1a>
f0104460:	84 d2                	test   %dl,%dl
f0104462:	75 f2                	jne    f0104456 <strfind+0xc>
			break;
	return (char *) s;
}
f0104464:	5d                   	pop    %ebp
f0104465:	c3                   	ret    

f0104466 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104466:	55                   	push   %ebp
f0104467:	89 e5                	mov    %esp,%ebp
f0104469:	57                   	push   %edi
f010446a:	56                   	push   %esi
f010446b:	53                   	push   %ebx
f010446c:	8b 7d 08             	mov    0x8(%ebp),%edi
f010446f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104472:	85 c9                	test   %ecx,%ecx
f0104474:	74 36                	je     f01044ac <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104476:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010447c:	75 28                	jne    f01044a6 <memset+0x40>
f010447e:	f6 c1 03             	test   $0x3,%cl
f0104481:	75 23                	jne    f01044a6 <memset+0x40>
		c &= 0xFF;
f0104483:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104487:	89 d3                	mov    %edx,%ebx
f0104489:	c1 e3 08             	shl    $0x8,%ebx
f010448c:	89 d6                	mov    %edx,%esi
f010448e:	c1 e6 18             	shl    $0x18,%esi
f0104491:	89 d0                	mov    %edx,%eax
f0104493:	c1 e0 10             	shl    $0x10,%eax
f0104496:	09 f0                	or     %esi,%eax
f0104498:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f010449a:	89 d8                	mov    %ebx,%eax
f010449c:	09 d0                	or     %edx,%eax
f010449e:	c1 e9 02             	shr    $0x2,%ecx
f01044a1:	fc                   	cld    
f01044a2:	f3 ab                	rep stos %eax,%es:(%edi)
f01044a4:	eb 06                	jmp    f01044ac <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01044a6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01044a9:	fc                   	cld    
f01044aa:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01044ac:	89 f8                	mov    %edi,%eax
f01044ae:	5b                   	pop    %ebx
f01044af:	5e                   	pop    %esi
f01044b0:	5f                   	pop    %edi
f01044b1:	5d                   	pop    %ebp
f01044b2:	c3                   	ret    

f01044b3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01044b3:	55                   	push   %ebp
f01044b4:	89 e5                	mov    %esp,%ebp
f01044b6:	57                   	push   %edi
f01044b7:	56                   	push   %esi
f01044b8:	8b 45 08             	mov    0x8(%ebp),%eax
f01044bb:	8b 75 0c             	mov    0xc(%ebp),%esi
f01044be:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01044c1:	39 c6                	cmp    %eax,%esi
f01044c3:	73 35                	jae    f01044fa <memmove+0x47>
f01044c5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01044c8:	39 d0                	cmp    %edx,%eax
f01044ca:	73 2e                	jae    f01044fa <memmove+0x47>
		s += n;
		d += n;
f01044cc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01044cf:	89 d6                	mov    %edx,%esi
f01044d1:	09 fe                	or     %edi,%esi
f01044d3:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01044d9:	75 13                	jne    f01044ee <memmove+0x3b>
f01044db:	f6 c1 03             	test   $0x3,%cl
f01044de:	75 0e                	jne    f01044ee <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01044e0:	83 ef 04             	sub    $0x4,%edi
f01044e3:	8d 72 fc             	lea    -0x4(%edx),%esi
f01044e6:	c1 e9 02             	shr    $0x2,%ecx
f01044e9:	fd                   	std    
f01044ea:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01044ec:	eb 09                	jmp    f01044f7 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01044ee:	83 ef 01             	sub    $0x1,%edi
f01044f1:	8d 72 ff             	lea    -0x1(%edx),%esi
f01044f4:	fd                   	std    
f01044f5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01044f7:	fc                   	cld    
f01044f8:	eb 1d                	jmp    f0104517 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01044fa:	89 f2                	mov    %esi,%edx
f01044fc:	09 c2                	or     %eax,%edx
f01044fe:	f6 c2 03             	test   $0x3,%dl
f0104501:	75 0f                	jne    f0104512 <memmove+0x5f>
f0104503:	f6 c1 03             	test   $0x3,%cl
f0104506:	75 0a                	jne    f0104512 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0104508:	c1 e9 02             	shr    $0x2,%ecx
f010450b:	89 c7                	mov    %eax,%edi
f010450d:	fc                   	cld    
f010450e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104510:	eb 05                	jmp    f0104517 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0104512:	89 c7                	mov    %eax,%edi
f0104514:	fc                   	cld    
f0104515:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104517:	5e                   	pop    %esi
f0104518:	5f                   	pop    %edi
f0104519:	5d                   	pop    %ebp
f010451a:	c3                   	ret    

f010451b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010451b:	55                   	push   %ebp
f010451c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010451e:	ff 75 10             	pushl  0x10(%ebp)
f0104521:	ff 75 0c             	pushl  0xc(%ebp)
f0104524:	ff 75 08             	pushl  0x8(%ebp)
f0104527:	e8 87 ff ff ff       	call   f01044b3 <memmove>
}
f010452c:	c9                   	leave  
f010452d:	c3                   	ret    

f010452e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010452e:	55                   	push   %ebp
f010452f:	89 e5                	mov    %esp,%ebp
f0104531:	56                   	push   %esi
f0104532:	53                   	push   %ebx
f0104533:	8b 45 08             	mov    0x8(%ebp),%eax
f0104536:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104539:	89 c6                	mov    %eax,%esi
f010453b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010453e:	eb 1a                	jmp    f010455a <memcmp+0x2c>
		if (*s1 != *s2)
f0104540:	0f b6 08             	movzbl (%eax),%ecx
f0104543:	0f b6 1a             	movzbl (%edx),%ebx
f0104546:	38 d9                	cmp    %bl,%cl
f0104548:	74 0a                	je     f0104554 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f010454a:	0f b6 c1             	movzbl %cl,%eax
f010454d:	0f b6 db             	movzbl %bl,%ebx
f0104550:	29 d8                	sub    %ebx,%eax
f0104552:	eb 0f                	jmp    f0104563 <memcmp+0x35>
		s1++, s2++;
f0104554:	83 c0 01             	add    $0x1,%eax
f0104557:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010455a:	39 f0                	cmp    %esi,%eax
f010455c:	75 e2                	jne    f0104540 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010455e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104563:	5b                   	pop    %ebx
f0104564:	5e                   	pop    %esi
f0104565:	5d                   	pop    %ebp
f0104566:	c3                   	ret    

f0104567 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104567:	55                   	push   %ebp
f0104568:	89 e5                	mov    %esp,%ebp
f010456a:	53                   	push   %ebx
f010456b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010456e:	89 c1                	mov    %eax,%ecx
f0104570:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0104573:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104577:	eb 0a                	jmp    f0104583 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104579:	0f b6 10             	movzbl (%eax),%edx
f010457c:	39 da                	cmp    %ebx,%edx
f010457e:	74 07                	je     f0104587 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104580:	83 c0 01             	add    $0x1,%eax
f0104583:	39 c8                	cmp    %ecx,%eax
f0104585:	72 f2                	jb     f0104579 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0104587:	5b                   	pop    %ebx
f0104588:	5d                   	pop    %ebp
f0104589:	c3                   	ret    

f010458a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010458a:	55                   	push   %ebp
f010458b:	89 e5                	mov    %esp,%ebp
f010458d:	57                   	push   %edi
f010458e:	56                   	push   %esi
f010458f:	53                   	push   %ebx
f0104590:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104593:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104596:	eb 03                	jmp    f010459b <strtol+0x11>
		s++;
f0104598:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010459b:	0f b6 01             	movzbl (%ecx),%eax
f010459e:	3c 20                	cmp    $0x20,%al
f01045a0:	74 f6                	je     f0104598 <strtol+0xe>
f01045a2:	3c 09                	cmp    $0x9,%al
f01045a4:	74 f2                	je     f0104598 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01045a6:	3c 2b                	cmp    $0x2b,%al
f01045a8:	75 0a                	jne    f01045b4 <strtol+0x2a>
		s++;
f01045aa:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01045ad:	bf 00 00 00 00       	mov    $0x0,%edi
f01045b2:	eb 11                	jmp    f01045c5 <strtol+0x3b>
f01045b4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01045b9:	3c 2d                	cmp    $0x2d,%al
f01045bb:	75 08                	jne    f01045c5 <strtol+0x3b>
		s++, neg = 1;
f01045bd:	83 c1 01             	add    $0x1,%ecx
f01045c0:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01045c5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01045cb:	75 15                	jne    f01045e2 <strtol+0x58>
f01045cd:	80 39 30             	cmpb   $0x30,(%ecx)
f01045d0:	75 10                	jne    f01045e2 <strtol+0x58>
f01045d2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01045d6:	75 7c                	jne    f0104654 <strtol+0xca>
		s += 2, base = 16;
f01045d8:	83 c1 02             	add    $0x2,%ecx
f01045db:	bb 10 00 00 00       	mov    $0x10,%ebx
f01045e0:	eb 16                	jmp    f01045f8 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01045e2:	85 db                	test   %ebx,%ebx
f01045e4:	75 12                	jne    f01045f8 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01045e6:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01045eb:	80 39 30             	cmpb   $0x30,(%ecx)
f01045ee:	75 08                	jne    f01045f8 <strtol+0x6e>
		s++, base = 8;
f01045f0:	83 c1 01             	add    $0x1,%ecx
f01045f3:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01045f8:	b8 00 00 00 00       	mov    $0x0,%eax
f01045fd:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0104600:	0f b6 11             	movzbl (%ecx),%edx
f0104603:	8d 72 d0             	lea    -0x30(%edx),%esi
f0104606:	89 f3                	mov    %esi,%ebx
f0104608:	80 fb 09             	cmp    $0x9,%bl
f010460b:	77 08                	ja     f0104615 <strtol+0x8b>
			dig = *s - '0';
f010460d:	0f be d2             	movsbl %dl,%edx
f0104610:	83 ea 30             	sub    $0x30,%edx
f0104613:	eb 22                	jmp    f0104637 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0104615:	8d 72 9f             	lea    -0x61(%edx),%esi
f0104618:	89 f3                	mov    %esi,%ebx
f010461a:	80 fb 19             	cmp    $0x19,%bl
f010461d:	77 08                	ja     f0104627 <strtol+0x9d>
			dig = *s - 'a' + 10;
f010461f:	0f be d2             	movsbl %dl,%edx
f0104622:	83 ea 57             	sub    $0x57,%edx
f0104625:	eb 10                	jmp    f0104637 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0104627:	8d 72 bf             	lea    -0x41(%edx),%esi
f010462a:	89 f3                	mov    %esi,%ebx
f010462c:	80 fb 19             	cmp    $0x19,%bl
f010462f:	77 16                	ja     f0104647 <strtol+0xbd>
			dig = *s - 'A' + 10;
f0104631:	0f be d2             	movsbl %dl,%edx
f0104634:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0104637:	3b 55 10             	cmp    0x10(%ebp),%edx
f010463a:	7d 0b                	jge    f0104647 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f010463c:	83 c1 01             	add    $0x1,%ecx
f010463f:	0f af 45 10          	imul   0x10(%ebp),%eax
f0104643:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0104645:	eb b9                	jmp    f0104600 <strtol+0x76>

	if (endptr)
f0104647:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010464b:	74 0d                	je     f010465a <strtol+0xd0>
		*endptr = (char *) s;
f010464d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104650:	89 0e                	mov    %ecx,(%esi)
f0104652:	eb 06                	jmp    f010465a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104654:	85 db                	test   %ebx,%ebx
f0104656:	74 98                	je     f01045f0 <strtol+0x66>
f0104658:	eb 9e                	jmp    f01045f8 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f010465a:	89 c2                	mov    %eax,%edx
f010465c:	f7 da                	neg    %edx
f010465e:	85 ff                	test   %edi,%edi
f0104660:	0f 45 c2             	cmovne %edx,%eax
}
f0104663:	5b                   	pop    %ebx
f0104664:	5e                   	pop    %esi
f0104665:	5f                   	pop    %edi
f0104666:	5d                   	pop    %ebp
f0104667:	c3                   	ret    
f0104668:	66 90                	xchg   %ax,%ax
f010466a:	66 90                	xchg   %ax,%ax
f010466c:	66 90                	xchg   %ax,%ax
f010466e:	66 90                	xchg   %ax,%ax

f0104670 <__udivdi3>:
f0104670:	55                   	push   %ebp
f0104671:	57                   	push   %edi
f0104672:	56                   	push   %esi
f0104673:	53                   	push   %ebx
f0104674:	83 ec 1c             	sub    $0x1c,%esp
f0104677:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010467b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010467f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0104683:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0104687:	85 f6                	test   %esi,%esi
f0104689:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010468d:	89 ca                	mov    %ecx,%edx
f010468f:	89 f8                	mov    %edi,%eax
f0104691:	75 3d                	jne    f01046d0 <__udivdi3+0x60>
f0104693:	39 cf                	cmp    %ecx,%edi
f0104695:	0f 87 c5 00 00 00    	ja     f0104760 <__udivdi3+0xf0>
f010469b:	85 ff                	test   %edi,%edi
f010469d:	89 fd                	mov    %edi,%ebp
f010469f:	75 0b                	jne    f01046ac <__udivdi3+0x3c>
f01046a1:	b8 01 00 00 00       	mov    $0x1,%eax
f01046a6:	31 d2                	xor    %edx,%edx
f01046a8:	f7 f7                	div    %edi
f01046aa:	89 c5                	mov    %eax,%ebp
f01046ac:	89 c8                	mov    %ecx,%eax
f01046ae:	31 d2                	xor    %edx,%edx
f01046b0:	f7 f5                	div    %ebp
f01046b2:	89 c1                	mov    %eax,%ecx
f01046b4:	89 d8                	mov    %ebx,%eax
f01046b6:	89 cf                	mov    %ecx,%edi
f01046b8:	f7 f5                	div    %ebp
f01046ba:	89 c3                	mov    %eax,%ebx
f01046bc:	89 d8                	mov    %ebx,%eax
f01046be:	89 fa                	mov    %edi,%edx
f01046c0:	83 c4 1c             	add    $0x1c,%esp
f01046c3:	5b                   	pop    %ebx
f01046c4:	5e                   	pop    %esi
f01046c5:	5f                   	pop    %edi
f01046c6:	5d                   	pop    %ebp
f01046c7:	c3                   	ret    
f01046c8:	90                   	nop
f01046c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01046d0:	39 ce                	cmp    %ecx,%esi
f01046d2:	77 74                	ja     f0104748 <__udivdi3+0xd8>
f01046d4:	0f bd fe             	bsr    %esi,%edi
f01046d7:	83 f7 1f             	xor    $0x1f,%edi
f01046da:	0f 84 98 00 00 00    	je     f0104778 <__udivdi3+0x108>
f01046e0:	bb 20 00 00 00       	mov    $0x20,%ebx
f01046e5:	89 f9                	mov    %edi,%ecx
f01046e7:	89 c5                	mov    %eax,%ebp
f01046e9:	29 fb                	sub    %edi,%ebx
f01046eb:	d3 e6                	shl    %cl,%esi
f01046ed:	89 d9                	mov    %ebx,%ecx
f01046ef:	d3 ed                	shr    %cl,%ebp
f01046f1:	89 f9                	mov    %edi,%ecx
f01046f3:	d3 e0                	shl    %cl,%eax
f01046f5:	09 ee                	or     %ebp,%esi
f01046f7:	89 d9                	mov    %ebx,%ecx
f01046f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01046fd:	89 d5                	mov    %edx,%ebp
f01046ff:	8b 44 24 08          	mov    0x8(%esp),%eax
f0104703:	d3 ed                	shr    %cl,%ebp
f0104705:	89 f9                	mov    %edi,%ecx
f0104707:	d3 e2                	shl    %cl,%edx
f0104709:	89 d9                	mov    %ebx,%ecx
f010470b:	d3 e8                	shr    %cl,%eax
f010470d:	09 c2                	or     %eax,%edx
f010470f:	89 d0                	mov    %edx,%eax
f0104711:	89 ea                	mov    %ebp,%edx
f0104713:	f7 f6                	div    %esi
f0104715:	89 d5                	mov    %edx,%ebp
f0104717:	89 c3                	mov    %eax,%ebx
f0104719:	f7 64 24 0c          	mull   0xc(%esp)
f010471d:	39 d5                	cmp    %edx,%ebp
f010471f:	72 10                	jb     f0104731 <__udivdi3+0xc1>
f0104721:	8b 74 24 08          	mov    0x8(%esp),%esi
f0104725:	89 f9                	mov    %edi,%ecx
f0104727:	d3 e6                	shl    %cl,%esi
f0104729:	39 c6                	cmp    %eax,%esi
f010472b:	73 07                	jae    f0104734 <__udivdi3+0xc4>
f010472d:	39 d5                	cmp    %edx,%ebp
f010472f:	75 03                	jne    f0104734 <__udivdi3+0xc4>
f0104731:	83 eb 01             	sub    $0x1,%ebx
f0104734:	31 ff                	xor    %edi,%edi
f0104736:	89 d8                	mov    %ebx,%eax
f0104738:	89 fa                	mov    %edi,%edx
f010473a:	83 c4 1c             	add    $0x1c,%esp
f010473d:	5b                   	pop    %ebx
f010473e:	5e                   	pop    %esi
f010473f:	5f                   	pop    %edi
f0104740:	5d                   	pop    %ebp
f0104741:	c3                   	ret    
f0104742:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104748:	31 ff                	xor    %edi,%edi
f010474a:	31 db                	xor    %ebx,%ebx
f010474c:	89 d8                	mov    %ebx,%eax
f010474e:	89 fa                	mov    %edi,%edx
f0104750:	83 c4 1c             	add    $0x1c,%esp
f0104753:	5b                   	pop    %ebx
f0104754:	5e                   	pop    %esi
f0104755:	5f                   	pop    %edi
f0104756:	5d                   	pop    %ebp
f0104757:	c3                   	ret    
f0104758:	90                   	nop
f0104759:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104760:	89 d8                	mov    %ebx,%eax
f0104762:	f7 f7                	div    %edi
f0104764:	31 ff                	xor    %edi,%edi
f0104766:	89 c3                	mov    %eax,%ebx
f0104768:	89 d8                	mov    %ebx,%eax
f010476a:	89 fa                	mov    %edi,%edx
f010476c:	83 c4 1c             	add    $0x1c,%esp
f010476f:	5b                   	pop    %ebx
f0104770:	5e                   	pop    %esi
f0104771:	5f                   	pop    %edi
f0104772:	5d                   	pop    %ebp
f0104773:	c3                   	ret    
f0104774:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104778:	39 ce                	cmp    %ecx,%esi
f010477a:	72 0c                	jb     f0104788 <__udivdi3+0x118>
f010477c:	31 db                	xor    %ebx,%ebx
f010477e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0104782:	0f 87 34 ff ff ff    	ja     f01046bc <__udivdi3+0x4c>
f0104788:	bb 01 00 00 00       	mov    $0x1,%ebx
f010478d:	e9 2a ff ff ff       	jmp    f01046bc <__udivdi3+0x4c>
f0104792:	66 90                	xchg   %ax,%ax
f0104794:	66 90                	xchg   %ax,%ax
f0104796:	66 90                	xchg   %ax,%ax
f0104798:	66 90                	xchg   %ax,%ax
f010479a:	66 90                	xchg   %ax,%ax
f010479c:	66 90                	xchg   %ax,%ax
f010479e:	66 90                	xchg   %ax,%ax

f01047a0 <__umoddi3>:
f01047a0:	55                   	push   %ebp
f01047a1:	57                   	push   %edi
f01047a2:	56                   	push   %esi
f01047a3:	53                   	push   %ebx
f01047a4:	83 ec 1c             	sub    $0x1c,%esp
f01047a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01047ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f01047af:	8b 74 24 34          	mov    0x34(%esp),%esi
f01047b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01047b7:	85 d2                	test   %edx,%edx
f01047b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01047bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01047c1:	89 f3                	mov    %esi,%ebx
f01047c3:	89 3c 24             	mov    %edi,(%esp)
f01047c6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01047ca:	75 1c                	jne    f01047e8 <__umoddi3+0x48>
f01047cc:	39 f7                	cmp    %esi,%edi
f01047ce:	76 50                	jbe    f0104820 <__umoddi3+0x80>
f01047d0:	89 c8                	mov    %ecx,%eax
f01047d2:	89 f2                	mov    %esi,%edx
f01047d4:	f7 f7                	div    %edi
f01047d6:	89 d0                	mov    %edx,%eax
f01047d8:	31 d2                	xor    %edx,%edx
f01047da:	83 c4 1c             	add    $0x1c,%esp
f01047dd:	5b                   	pop    %ebx
f01047de:	5e                   	pop    %esi
f01047df:	5f                   	pop    %edi
f01047e0:	5d                   	pop    %ebp
f01047e1:	c3                   	ret    
f01047e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01047e8:	39 f2                	cmp    %esi,%edx
f01047ea:	89 d0                	mov    %edx,%eax
f01047ec:	77 52                	ja     f0104840 <__umoddi3+0xa0>
f01047ee:	0f bd ea             	bsr    %edx,%ebp
f01047f1:	83 f5 1f             	xor    $0x1f,%ebp
f01047f4:	75 5a                	jne    f0104850 <__umoddi3+0xb0>
f01047f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
f01047fa:	0f 82 e0 00 00 00    	jb     f01048e0 <__umoddi3+0x140>
f0104800:	39 0c 24             	cmp    %ecx,(%esp)
f0104803:	0f 86 d7 00 00 00    	jbe    f01048e0 <__umoddi3+0x140>
f0104809:	8b 44 24 08          	mov    0x8(%esp),%eax
f010480d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0104811:	83 c4 1c             	add    $0x1c,%esp
f0104814:	5b                   	pop    %ebx
f0104815:	5e                   	pop    %esi
f0104816:	5f                   	pop    %edi
f0104817:	5d                   	pop    %ebp
f0104818:	c3                   	ret    
f0104819:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104820:	85 ff                	test   %edi,%edi
f0104822:	89 fd                	mov    %edi,%ebp
f0104824:	75 0b                	jne    f0104831 <__umoddi3+0x91>
f0104826:	b8 01 00 00 00       	mov    $0x1,%eax
f010482b:	31 d2                	xor    %edx,%edx
f010482d:	f7 f7                	div    %edi
f010482f:	89 c5                	mov    %eax,%ebp
f0104831:	89 f0                	mov    %esi,%eax
f0104833:	31 d2                	xor    %edx,%edx
f0104835:	f7 f5                	div    %ebp
f0104837:	89 c8                	mov    %ecx,%eax
f0104839:	f7 f5                	div    %ebp
f010483b:	89 d0                	mov    %edx,%eax
f010483d:	eb 99                	jmp    f01047d8 <__umoddi3+0x38>
f010483f:	90                   	nop
f0104840:	89 c8                	mov    %ecx,%eax
f0104842:	89 f2                	mov    %esi,%edx
f0104844:	83 c4 1c             	add    $0x1c,%esp
f0104847:	5b                   	pop    %ebx
f0104848:	5e                   	pop    %esi
f0104849:	5f                   	pop    %edi
f010484a:	5d                   	pop    %ebp
f010484b:	c3                   	ret    
f010484c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104850:	8b 34 24             	mov    (%esp),%esi
f0104853:	bf 20 00 00 00       	mov    $0x20,%edi
f0104858:	89 e9                	mov    %ebp,%ecx
f010485a:	29 ef                	sub    %ebp,%edi
f010485c:	d3 e0                	shl    %cl,%eax
f010485e:	89 f9                	mov    %edi,%ecx
f0104860:	89 f2                	mov    %esi,%edx
f0104862:	d3 ea                	shr    %cl,%edx
f0104864:	89 e9                	mov    %ebp,%ecx
f0104866:	09 c2                	or     %eax,%edx
f0104868:	89 d8                	mov    %ebx,%eax
f010486a:	89 14 24             	mov    %edx,(%esp)
f010486d:	89 f2                	mov    %esi,%edx
f010486f:	d3 e2                	shl    %cl,%edx
f0104871:	89 f9                	mov    %edi,%ecx
f0104873:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104877:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010487b:	d3 e8                	shr    %cl,%eax
f010487d:	89 e9                	mov    %ebp,%ecx
f010487f:	89 c6                	mov    %eax,%esi
f0104881:	d3 e3                	shl    %cl,%ebx
f0104883:	89 f9                	mov    %edi,%ecx
f0104885:	89 d0                	mov    %edx,%eax
f0104887:	d3 e8                	shr    %cl,%eax
f0104889:	89 e9                	mov    %ebp,%ecx
f010488b:	09 d8                	or     %ebx,%eax
f010488d:	89 d3                	mov    %edx,%ebx
f010488f:	89 f2                	mov    %esi,%edx
f0104891:	f7 34 24             	divl   (%esp)
f0104894:	89 d6                	mov    %edx,%esi
f0104896:	d3 e3                	shl    %cl,%ebx
f0104898:	f7 64 24 04          	mull   0x4(%esp)
f010489c:	39 d6                	cmp    %edx,%esi
f010489e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01048a2:	89 d1                	mov    %edx,%ecx
f01048a4:	89 c3                	mov    %eax,%ebx
f01048a6:	72 08                	jb     f01048b0 <__umoddi3+0x110>
f01048a8:	75 11                	jne    f01048bb <__umoddi3+0x11b>
f01048aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01048ae:	73 0b                	jae    f01048bb <__umoddi3+0x11b>
f01048b0:	2b 44 24 04          	sub    0x4(%esp),%eax
f01048b4:	1b 14 24             	sbb    (%esp),%edx
f01048b7:	89 d1                	mov    %edx,%ecx
f01048b9:	89 c3                	mov    %eax,%ebx
f01048bb:	8b 54 24 08          	mov    0x8(%esp),%edx
f01048bf:	29 da                	sub    %ebx,%edx
f01048c1:	19 ce                	sbb    %ecx,%esi
f01048c3:	89 f9                	mov    %edi,%ecx
f01048c5:	89 f0                	mov    %esi,%eax
f01048c7:	d3 e0                	shl    %cl,%eax
f01048c9:	89 e9                	mov    %ebp,%ecx
f01048cb:	d3 ea                	shr    %cl,%edx
f01048cd:	89 e9                	mov    %ebp,%ecx
f01048cf:	d3 ee                	shr    %cl,%esi
f01048d1:	09 d0                	or     %edx,%eax
f01048d3:	89 f2                	mov    %esi,%edx
f01048d5:	83 c4 1c             	add    $0x1c,%esp
f01048d8:	5b                   	pop    %ebx
f01048d9:	5e                   	pop    %esi
f01048da:	5f                   	pop    %edi
f01048db:	5d                   	pop    %ebp
f01048dc:	c3                   	ret    
f01048dd:	8d 76 00             	lea    0x0(%esi),%esi
f01048e0:	29 f9                	sub    %edi,%ecx
f01048e2:	19 d6                	sbb    %edx,%esi
f01048e4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01048e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01048ec:	e9 18 ff ff ff       	jmp    f0104809 <__umoddi3+0x69>
