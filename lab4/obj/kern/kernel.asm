
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
f0100015:	b8 00 00 12 00       	mov    $0x120000,%eax
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
f0100034:	bc 00 00 12 f0       	mov    $0xf0120000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5c 00 00 00       	call   f010009a <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100048:	83 3d 80 1e 23 f0 00 	cmpl   $0x0,0xf0231e80
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 80 1e 23 f0    	mov    %esi,0xf0231e80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 75 65 00 00       	call   f01065d6 <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 60 6c 10 f0       	push   $0xf0106c60
f010006d:	e8 ec 3a 00 00       	call   f0103b5e <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 bc 3a 00 00       	call   f0103b38 <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 28 80 10 f0 	movl   $0xf0108028,(%esp)
f0100083:	e8 d6 3a 00 00       	call   f0103b5e <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 ed 0c 00 00       	call   f0100d82 <monitor>
f0100095:	83 c4 10             	add    $0x10,%esp
f0100098:	eb f1                	jmp    f010008b <_panic+0x4b>

f010009a <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f010009a:	55                   	push   %ebp
f010009b:	89 e5                	mov    %esp,%ebp
f010009d:	53                   	push   %ebx
f010009e:	83 ec 08             	sub    $0x8,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000a1:	b8 08 30 27 f0       	mov    $0xf0273008,%eax
f01000a6:	2d 10 0d 23 f0       	sub    $0xf0230d10,%eax
f01000ab:	50                   	push   %eax
f01000ac:	6a 00                	push   $0x0
f01000ae:	68 10 0d 23 f0       	push   $0xf0230d10
f01000b3:	e8 fe 5e 00 00       	call   f0105fb6 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b8:	e8 74 05 00 00       	call   f0100631 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000bd:	83 c4 08             	add    $0x8,%esp
f01000c0:	68 ac 1a 00 00       	push   $0x1aac
f01000c5:	68 cc 6c 10 f0       	push   $0xf0106ccc
f01000ca:	e8 8f 3a 00 00       	call   f0103b5e <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000cf:	e8 03 16 00 00       	call   f01016d7 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000d4:	e8 b4 32 00 00       	call   f010338d <env_init>
	trap_init();
f01000d9:	e8 4b 3b 00 00       	call   f0103c29 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000de:	e8 e9 61 00 00       	call   f01062cc <mp_init>
	lapic_init();
f01000e3:	e8 09 65 00 00       	call   f01065f1 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000e8:	e8 98 39 00 00       	call   f0103a85 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000ed:	c7 04 24 c0 27 12 f0 	movl   $0xf01227c0,(%esp)
f01000f4:	e8 4b 67 00 00       	call   f0106844 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000f9:	83 c4 10             	add    $0x10,%esp
f01000fc:	83 3d 88 1e 23 f0 07 	cmpl   $0x7,0xf0231e88
f0100103:	77 16                	ja     f010011b <i386_init+0x81>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100105:	68 00 70 00 00       	push   $0x7000
f010010a:	68 84 6c 10 f0       	push   $0xf0106c84
f010010f:	6a 56                	push   $0x56
f0100111:	68 e7 6c 10 f0       	push   $0xf0106ce7
f0100116:	e8 25 ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010011b:	83 ec 04             	sub    $0x4,%esp
f010011e:	b8 32 62 10 f0       	mov    $0xf0106232,%eax
f0100123:	2d b8 61 10 f0       	sub    $0xf01061b8,%eax
f0100128:	50                   	push   %eax
f0100129:	68 b8 61 10 f0       	push   $0xf01061b8
f010012e:	68 00 70 00 f0       	push   $0xf0007000
f0100133:	e8 cb 5e 00 00       	call   f0106003 <memmove>
f0100138:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010013b:	bb 20 20 23 f0       	mov    $0xf0232020,%ebx
f0100140:	eb 4d                	jmp    f010018f <i386_init+0xf5>
		if (c == cpus + cpunum())  // We've started already.
f0100142:	e8 8f 64 00 00       	call   f01065d6 <cpunum>
f0100147:	6b c0 74             	imul   $0x74,%eax,%eax
f010014a:	05 20 20 23 f0       	add    $0xf0232020,%eax
f010014f:	39 c3                	cmp    %eax,%ebx
f0100151:	74 39                	je     f010018c <i386_init+0xf2>
			continue;
		
		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100153:	89 d8                	mov    %ebx,%eax
f0100155:	2d 20 20 23 f0       	sub    $0xf0232020,%eax
f010015a:	c1 f8 02             	sar    $0x2,%eax
f010015d:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100163:	c1 e0 0f             	shl    $0xf,%eax
f0100166:	05 00 b0 23 f0       	add    $0xf023b000,%eax
f010016b:	a3 84 1e 23 f0       	mov    %eax,0xf0231e84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100170:	83 ec 08             	sub    $0x8,%esp
f0100173:	68 00 70 00 00       	push   $0x7000
f0100178:	0f b6 03             	movzbl (%ebx),%eax
f010017b:	50                   	push   %eax
f010017c:	e8 be 65 00 00       	call   f010673f <lapic_startap>
f0100181:	83 c4 10             	add    $0x10,%esp
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f0100184:	8b 43 04             	mov    0x4(%ebx),%eax
f0100187:	83 f8 01             	cmp    $0x1,%eax
f010018a:	75 f8                	jne    f0100184 <i386_init+0xea>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010018c:	83 c3 74             	add    $0x74,%ebx
f010018f:	6b 05 c4 23 23 f0 74 	imul   $0x74,0xf02323c4,%eax
f0100196:	05 20 20 23 f0       	add    $0xf0232020,%eax
f010019b:	39 c3                	cmp    %eax,%ebx
f010019d:	72 a3                	jb     f0100142 <i386_init+0xa8>
	// Starting non-boot CPUs
	boot_aps();

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f010019f:	83 ec 08             	sub    $0x8,%esp
f01001a2:	6a 00                	push   $0x0
f01001a4:	68 cc 72 22 f0       	push   $0xf02272cc
f01001a9:	e8 bd 33 00 00       	call   f010356b <env_create>
	ENV_CREATE(user_yield, ENV_TYPE_USER);
	ENV_CREATE(user_yield, ENV_TYPE_USER);
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f01001ae:	e8 b1 4c 00 00       	call   f0104e64 <sched_yield>

f01001b3 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01001b3:	55                   	push   %ebp
f01001b4:	89 e5                	mov    %esp,%ebp
f01001b6:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01001b9:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001be:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001c3:	77 12                	ja     f01001d7 <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001c5:	50                   	push   %eax
f01001c6:	68 a8 6c 10 f0       	push   $0xf0106ca8
f01001cb:	6a 6d                	push   $0x6d
f01001cd:	68 e7 6c 10 f0       	push   $0xf0106ce7
f01001d2:	e8 69 fe ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01001d7:	05 00 00 00 10       	add    $0x10000000,%eax
f01001dc:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001df:	e8 f2 63 00 00       	call   f01065d6 <cpunum>
f01001e4:	83 ec 08             	sub    $0x8,%esp
f01001e7:	50                   	push   %eax
f01001e8:	68 f3 6c 10 f0       	push   $0xf0106cf3
f01001ed:	e8 6c 39 00 00       	call   f0103b5e <cprintf>

	lapic_init();
f01001f2:	e8 fa 63 00 00       	call   f01065f1 <lapic_init>
	env_init_percpu();
f01001f7:	e8 61 31 00 00       	call   f010335d <env_init_percpu>
	trap_init_percpu();
f01001fc:	e8 71 39 00 00       	call   f0103b72 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100201:	e8 d0 63 00 00       	call   f01065d6 <cpunum>
f0100206:	6b d0 74             	imul   $0x74,%eax,%edx
f0100209:	81 c2 20 20 23 f0    	add    $0xf0232020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010020f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100214:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0100218:	c7 04 24 c0 27 12 f0 	movl   $0xf01227c0,(%esp)
f010021f:	e8 20 66 00 00       	call   f0106844 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	lock_kernel();

	sched_yield();
f0100224:	e8 3b 4c 00 00       	call   f0104e64 <sched_yield>

f0100229 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100229:	55                   	push   %ebp
f010022a:	89 e5                	mov    %esp,%ebp
f010022c:	53                   	push   %ebx
f010022d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100230:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100233:	ff 75 0c             	pushl  0xc(%ebp)
f0100236:	ff 75 08             	pushl  0x8(%ebp)
f0100239:	68 09 6d 10 f0       	push   $0xf0106d09
f010023e:	e8 1b 39 00 00       	call   f0103b5e <cprintf>
	vcprintf(fmt, ap);
f0100243:	83 c4 08             	add    $0x8,%esp
f0100246:	53                   	push   %ebx
f0100247:	ff 75 10             	pushl  0x10(%ebp)
f010024a:	e8 e9 38 00 00       	call   f0103b38 <vcprintf>
	cprintf("\n");
f010024f:	c7 04 24 28 80 10 f0 	movl   $0xf0108028,(%esp)
f0100256:	e8 03 39 00 00       	call   f0103b5e <cprintf>
	va_end(ap);
}
f010025b:	83 c4 10             	add    $0x10,%esp
f010025e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100261:	c9                   	leave  
f0100262:	c3                   	ret    

f0100263 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100263:	55                   	push   %ebp
f0100264:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100266:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010026b:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010026c:	a8 01                	test   $0x1,%al
f010026e:	74 0b                	je     f010027b <serial_proc_data+0x18>
f0100270:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100275:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100276:	0f b6 c0             	movzbl %al,%eax
f0100279:	eb 05                	jmp    f0100280 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010027b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100280:	5d                   	pop    %ebp
f0100281:	c3                   	ret    

f0100282 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100282:	55                   	push   %ebp
f0100283:	89 e5                	mov    %esp,%ebp
f0100285:	53                   	push   %ebx
f0100286:	83 ec 04             	sub    $0x4,%esp
f0100289:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010028b:	eb 2b                	jmp    f01002b8 <cons_intr+0x36>
		if (c == 0)
f010028d:	85 c0                	test   %eax,%eax
f010028f:	74 27                	je     f01002b8 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f0100291:	8b 0d 24 12 23 f0    	mov    0xf0231224,%ecx
f0100297:	8d 51 01             	lea    0x1(%ecx),%edx
f010029a:	89 15 24 12 23 f0    	mov    %edx,0xf0231224
f01002a0:	88 81 20 10 23 f0    	mov    %al,-0xfdcefe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002a6:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01002ac:	75 0a                	jne    f01002b8 <cons_intr+0x36>
			cons.wpos = 0;
f01002ae:	c7 05 24 12 23 f0 00 	movl   $0x0,0xf0231224
f01002b5:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002b8:	ff d3                	call   *%ebx
f01002ba:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002bd:	75 ce                	jne    f010028d <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002bf:	83 c4 04             	add    $0x4,%esp
f01002c2:	5b                   	pop    %ebx
f01002c3:	5d                   	pop    %ebp
f01002c4:	c3                   	ret    

f01002c5 <kbd_proc_data>:
f01002c5:	ba 64 00 00 00       	mov    $0x64,%edx
f01002ca:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01002cb:	a8 01                	test   $0x1,%al
f01002cd:	0f 84 f0 00 00 00    	je     f01003c3 <kbd_proc_data+0xfe>
f01002d3:	ba 60 00 00 00       	mov    $0x60,%edx
f01002d8:	ec                   	in     (%dx),%al
f01002d9:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01002db:	3c e0                	cmp    $0xe0,%al
f01002dd:	75 0d                	jne    f01002ec <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f01002df:	83 0d 00 10 23 f0 40 	orl    $0x40,0xf0231000
		return 0;
f01002e6:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01002eb:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01002ec:	55                   	push   %ebp
f01002ed:	89 e5                	mov    %esp,%ebp
f01002ef:	53                   	push   %ebx
f01002f0:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01002f3:	84 c0                	test   %al,%al
f01002f5:	79 36                	jns    f010032d <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01002f7:	8b 0d 00 10 23 f0    	mov    0xf0231000,%ecx
f01002fd:	89 cb                	mov    %ecx,%ebx
f01002ff:	83 e3 40             	and    $0x40,%ebx
f0100302:	83 e0 7f             	and    $0x7f,%eax
f0100305:	85 db                	test   %ebx,%ebx
f0100307:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010030a:	0f b6 d2             	movzbl %dl,%edx
f010030d:	0f b6 82 80 6e 10 f0 	movzbl -0xfef9180(%edx),%eax
f0100314:	83 c8 40             	or     $0x40,%eax
f0100317:	0f b6 c0             	movzbl %al,%eax
f010031a:	f7 d0                	not    %eax
f010031c:	21 c8                	and    %ecx,%eax
f010031e:	a3 00 10 23 f0       	mov    %eax,0xf0231000
		return 0;
f0100323:	b8 00 00 00 00       	mov    $0x0,%eax
f0100328:	e9 9e 00 00 00       	jmp    f01003cb <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f010032d:	8b 0d 00 10 23 f0    	mov    0xf0231000,%ecx
f0100333:	f6 c1 40             	test   $0x40,%cl
f0100336:	74 0e                	je     f0100346 <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100338:	83 c8 80             	or     $0xffffff80,%eax
f010033b:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010033d:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100340:	89 0d 00 10 23 f0    	mov    %ecx,0xf0231000
	}

	shift |= shiftcode[data];
f0100346:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100349:	0f b6 82 80 6e 10 f0 	movzbl -0xfef9180(%edx),%eax
f0100350:	0b 05 00 10 23 f0    	or     0xf0231000,%eax
f0100356:	0f b6 8a 80 6d 10 f0 	movzbl -0xfef9280(%edx),%ecx
f010035d:	31 c8                	xor    %ecx,%eax
f010035f:	a3 00 10 23 f0       	mov    %eax,0xf0231000

	c = charcode[shift & (CTL | SHIFT)][data];
f0100364:	89 c1                	mov    %eax,%ecx
f0100366:	83 e1 03             	and    $0x3,%ecx
f0100369:	8b 0c 8d 60 6d 10 f0 	mov    -0xfef92a0(,%ecx,4),%ecx
f0100370:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100374:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100377:	a8 08                	test   $0x8,%al
f0100379:	74 1b                	je     f0100396 <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f010037b:	89 da                	mov    %ebx,%edx
f010037d:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100380:	83 f9 19             	cmp    $0x19,%ecx
f0100383:	77 05                	ja     f010038a <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f0100385:	83 eb 20             	sub    $0x20,%ebx
f0100388:	eb 0c                	jmp    f0100396 <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f010038a:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010038d:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100390:	83 fa 19             	cmp    $0x19,%edx
f0100393:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100396:	f7 d0                	not    %eax
f0100398:	a8 06                	test   $0x6,%al
f010039a:	75 2d                	jne    f01003c9 <kbd_proc_data+0x104>
f010039c:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003a2:	75 25                	jne    f01003c9 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f01003a4:	83 ec 0c             	sub    $0xc,%esp
f01003a7:	68 23 6d 10 f0       	push   $0xf0106d23
f01003ac:	e8 ad 37 00 00       	call   f0103b5e <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003b1:	ba 92 00 00 00       	mov    $0x92,%edx
f01003b6:	b8 03 00 00 00       	mov    $0x3,%eax
f01003bb:	ee                   	out    %al,(%dx)
f01003bc:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003bf:	89 d8                	mov    %ebx,%eax
f01003c1:	eb 08                	jmp    f01003cb <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01003c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01003c8:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003c9:	89 d8                	mov    %ebx,%eax
}
f01003cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003ce:	c9                   	leave  
f01003cf:	c3                   	ret    

f01003d0 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003d0:	55                   	push   %ebp
f01003d1:	89 e5                	mov    %esp,%ebp
f01003d3:	57                   	push   %edi
f01003d4:	56                   	push   %esi
f01003d5:	53                   	push   %ebx
f01003d6:	83 ec 1c             	sub    $0x1c,%esp
f01003d9:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01003db:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003e0:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003e5:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003ea:	eb 09                	jmp    f01003f5 <cons_putc+0x25>
f01003ec:	89 ca                	mov    %ecx,%edx
f01003ee:	ec                   	in     (%dx),%al
f01003ef:	ec                   	in     (%dx),%al
f01003f0:	ec                   	in     (%dx),%al
f01003f1:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01003f2:	83 c3 01             	add    $0x1,%ebx
f01003f5:	89 f2                	mov    %esi,%edx
f01003f7:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003f8:	a8 20                	test   $0x20,%al
f01003fa:	75 08                	jne    f0100404 <cons_putc+0x34>
f01003fc:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100402:	7e e8                	jle    f01003ec <cons_putc+0x1c>
f0100404:	89 f8                	mov    %edi,%eax
f0100406:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100409:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010040e:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010040f:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100414:	be 79 03 00 00       	mov    $0x379,%esi
f0100419:	b9 84 00 00 00       	mov    $0x84,%ecx
f010041e:	eb 09                	jmp    f0100429 <cons_putc+0x59>
f0100420:	89 ca                	mov    %ecx,%edx
f0100422:	ec                   	in     (%dx),%al
f0100423:	ec                   	in     (%dx),%al
f0100424:	ec                   	in     (%dx),%al
f0100425:	ec                   	in     (%dx),%al
f0100426:	83 c3 01             	add    $0x1,%ebx
f0100429:	89 f2                	mov    %esi,%edx
f010042b:	ec                   	in     (%dx),%al
f010042c:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100432:	7f 04                	jg     f0100438 <cons_putc+0x68>
f0100434:	84 c0                	test   %al,%al
f0100436:	79 e8                	jns    f0100420 <cons_putc+0x50>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100438:	ba 78 03 00 00       	mov    $0x378,%edx
f010043d:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100441:	ee                   	out    %al,(%dx)
f0100442:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100447:	b8 0d 00 00 00       	mov    $0xd,%eax
f010044c:	ee                   	out    %al,(%dx)
f010044d:	b8 08 00 00 00       	mov    $0x8,%eax
f0100452:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100453:	89 fa                	mov    %edi,%edx
f0100455:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f010045b:	89 f8                	mov    %edi,%eax
f010045d:	80 cc 07             	or     $0x7,%ah
f0100460:	85 d2                	test   %edx,%edx
f0100462:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100465:	89 f8                	mov    %edi,%eax
f0100467:	0f b6 c0             	movzbl %al,%eax
f010046a:	83 f8 09             	cmp    $0x9,%eax
f010046d:	74 74                	je     f01004e3 <cons_putc+0x113>
f010046f:	83 f8 09             	cmp    $0x9,%eax
f0100472:	7f 0a                	jg     f010047e <cons_putc+0xae>
f0100474:	83 f8 08             	cmp    $0x8,%eax
f0100477:	74 14                	je     f010048d <cons_putc+0xbd>
f0100479:	e9 99 00 00 00       	jmp    f0100517 <cons_putc+0x147>
f010047e:	83 f8 0a             	cmp    $0xa,%eax
f0100481:	74 3a                	je     f01004bd <cons_putc+0xed>
f0100483:	83 f8 0d             	cmp    $0xd,%eax
f0100486:	74 3d                	je     f01004c5 <cons_putc+0xf5>
f0100488:	e9 8a 00 00 00       	jmp    f0100517 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f010048d:	0f b7 05 28 12 23 f0 	movzwl 0xf0231228,%eax
f0100494:	66 85 c0             	test   %ax,%ax
f0100497:	0f 84 e6 00 00 00    	je     f0100583 <cons_putc+0x1b3>
			crt_pos--;
f010049d:	83 e8 01             	sub    $0x1,%eax
f01004a0:	66 a3 28 12 23 f0    	mov    %ax,0xf0231228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004a6:	0f b7 c0             	movzwl %ax,%eax
f01004a9:	66 81 e7 00 ff       	and    $0xff00,%di
f01004ae:	83 cf 20             	or     $0x20,%edi
f01004b1:	8b 15 2c 12 23 f0    	mov    0xf023122c,%edx
f01004b7:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004bb:	eb 78                	jmp    f0100535 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004bd:	66 83 05 28 12 23 f0 	addw   $0x50,0xf0231228
f01004c4:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004c5:	0f b7 05 28 12 23 f0 	movzwl 0xf0231228,%eax
f01004cc:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004d2:	c1 e8 16             	shr    $0x16,%eax
f01004d5:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004d8:	c1 e0 04             	shl    $0x4,%eax
f01004db:	66 a3 28 12 23 f0    	mov    %ax,0xf0231228
f01004e1:	eb 52                	jmp    f0100535 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01004e3:	b8 20 00 00 00       	mov    $0x20,%eax
f01004e8:	e8 e3 fe ff ff       	call   f01003d0 <cons_putc>
		cons_putc(' ');
f01004ed:	b8 20 00 00 00       	mov    $0x20,%eax
f01004f2:	e8 d9 fe ff ff       	call   f01003d0 <cons_putc>
		cons_putc(' ');
f01004f7:	b8 20 00 00 00       	mov    $0x20,%eax
f01004fc:	e8 cf fe ff ff       	call   f01003d0 <cons_putc>
		cons_putc(' ');
f0100501:	b8 20 00 00 00       	mov    $0x20,%eax
f0100506:	e8 c5 fe ff ff       	call   f01003d0 <cons_putc>
		cons_putc(' ');
f010050b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100510:	e8 bb fe ff ff       	call   f01003d0 <cons_putc>
f0100515:	eb 1e                	jmp    f0100535 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100517:	0f b7 05 28 12 23 f0 	movzwl 0xf0231228,%eax
f010051e:	8d 50 01             	lea    0x1(%eax),%edx
f0100521:	66 89 15 28 12 23 f0 	mov    %dx,0xf0231228
f0100528:	0f b7 c0             	movzwl %ax,%eax
f010052b:	8b 15 2c 12 23 f0    	mov    0xf023122c,%edx
f0100531:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100535:	66 81 3d 28 12 23 f0 	cmpw   $0x7cf,0xf0231228
f010053c:	cf 07 
f010053e:	76 43                	jbe    f0100583 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100540:	a1 2c 12 23 f0       	mov    0xf023122c,%eax
f0100545:	83 ec 04             	sub    $0x4,%esp
f0100548:	68 00 0f 00 00       	push   $0xf00
f010054d:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100553:	52                   	push   %edx
f0100554:	50                   	push   %eax
f0100555:	e8 a9 5a 00 00       	call   f0106003 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010055a:	8b 15 2c 12 23 f0    	mov    0xf023122c,%edx
f0100560:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100566:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010056c:	83 c4 10             	add    $0x10,%esp
f010056f:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100574:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100577:	39 d0                	cmp    %edx,%eax
f0100579:	75 f4                	jne    f010056f <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010057b:	66 83 2d 28 12 23 f0 	subw   $0x50,0xf0231228
f0100582:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100583:	8b 0d 30 12 23 f0    	mov    0xf0231230,%ecx
f0100589:	b8 0e 00 00 00       	mov    $0xe,%eax
f010058e:	89 ca                	mov    %ecx,%edx
f0100590:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100591:	0f b7 1d 28 12 23 f0 	movzwl 0xf0231228,%ebx
f0100598:	8d 71 01             	lea    0x1(%ecx),%esi
f010059b:	89 d8                	mov    %ebx,%eax
f010059d:	66 c1 e8 08          	shr    $0x8,%ax
f01005a1:	89 f2                	mov    %esi,%edx
f01005a3:	ee                   	out    %al,(%dx)
f01005a4:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005a9:	89 ca                	mov    %ecx,%edx
f01005ab:	ee                   	out    %al,(%dx)
f01005ac:	89 d8                	mov    %ebx,%eax
f01005ae:	89 f2                	mov    %esi,%edx
f01005b0:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005b4:	5b                   	pop    %ebx
f01005b5:	5e                   	pop    %esi
f01005b6:	5f                   	pop    %edi
f01005b7:	5d                   	pop    %ebp
f01005b8:	c3                   	ret    

f01005b9 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01005b9:	80 3d 34 12 23 f0 00 	cmpb   $0x0,0xf0231234
f01005c0:	74 11                	je     f01005d3 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005c2:	55                   	push   %ebp
f01005c3:	89 e5                	mov    %esp,%ebp
f01005c5:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01005c8:	b8 63 02 10 f0       	mov    $0xf0100263,%eax
f01005cd:	e8 b0 fc ff ff       	call   f0100282 <cons_intr>
}
f01005d2:	c9                   	leave  
f01005d3:	f3 c3                	repz ret 

f01005d5 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01005d5:	55                   	push   %ebp
f01005d6:	89 e5                	mov    %esp,%ebp
f01005d8:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005db:	b8 c5 02 10 f0       	mov    $0xf01002c5,%eax
f01005e0:	e8 9d fc ff ff       	call   f0100282 <cons_intr>
}
f01005e5:	c9                   	leave  
f01005e6:	c3                   	ret    

f01005e7 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01005e7:	55                   	push   %ebp
f01005e8:	89 e5                	mov    %esp,%ebp
f01005ea:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01005ed:	e8 c7 ff ff ff       	call   f01005b9 <serial_intr>
	kbd_intr();
f01005f2:	e8 de ff ff ff       	call   f01005d5 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01005f7:	a1 20 12 23 f0       	mov    0xf0231220,%eax
f01005fc:	3b 05 24 12 23 f0    	cmp    0xf0231224,%eax
f0100602:	74 26                	je     f010062a <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100604:	8d 50 01             	lea    0x1(%eax),%edx
f0100607:	89 15 20 12 23 f0    	mov    %edx,0xf0231220
f010060d:	0f b6 88 20 10 23 f0 	movzbl -0xfdcefe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100614:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100616:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010061c:	75 11                	jne    f010062f <cons_getc+0x48>
			cons.rpos = 0;
f010061e:	c7 05 20 12 23 f0 00 	movl   $0x0,0xf0231220
f0100625:	00 00 00 
f0100628:	eb 05                	jmp    f010062f <cons_getc+0x48>
		return c;
	}
	return 0;
f010062a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010062f:	c9                   	leave  
f0100630:	c3                   	ret    

f0100631 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100631:	55                   	push   %ebp
f0100632:	89 e5                	mov    %esp,%ebp
f0100634:	57                   	push   %edi
f0100635:	56                   	push   %esi
f0100636:	53                   	push   %ebx
f0100637:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010063a:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100641:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100648:	5a a5 
	if (*cp != 0xA55A) {
f010064a:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100651:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100655:	74 11                	je     f0100668 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100657:	c7 05 30 12 23 f0 b4 	movl   $0x3b4,0xf0231230
f010065e:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100661:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100666:	eb 16                	jmp    f010067e <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100668:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010066f:	c7 05 30 12 23 f0 d4 	movl   $0x3d4,0xf0231230
f0100676:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100679:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010067e:	8b 3d 30 12 23 f0    	mov    0xf0231230,%edi
f0100684:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100689:	89 fa                	mov    %edi,%edx
f010068b:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010068c:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010068f:	89 da                	mov    %ebx,%edx
f0100691:	ec                   	in     (%dx),%al
f0100692:	0f b6 c8             	movzbl %al,%ecx
f0100695:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100698:	b8 0f 00 00 00       	mov    $0xf,%eax
f010069d:	89 fa                	mov    %edi,%edx
f010069f:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006a0:	89 da                	mov    %ebx,%edx
f01006a2:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006a3:	89 35 2c 12 23 f0    	mov    %esi,0xf023122c
	crt_pos = pos;
f01006a9:	0f b6 c0             	movzbl %al,%eax
f01006ac:	09 c8                	or     %ecx,%eax
f01006ae:	66 a3 28 12 23 f0    	mov    %ax,0xf0231228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006b4:	e8 1c ff ff ff       	call   f01005d5 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f01006b9:	83 ec 0c             	sub    $0xc,%esp
f01006bc:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f01006c3:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006c8:	50                   	push   %eax
f01006c9:	e8 3f 33 00 00       	call   f0103a0d <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006ce:	be fa 03 00 00       	mov    $0x3fa,%esi
f01006d3:	b8 00 00 00 00       	mov    $0x0,%eax
f01006d8:	89 f2                	mov    %esi,%edx
f01006da:	ee                   	out    %al,(%dx)
f01006db:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01006e0:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006e5:	ee                   	out    %al,(%dx)
f01006e6:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01006eb:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006f0:	89 da                	mov    %ebx,%edx
f01006f2:	ee                   	out    %al,(%dx)
f01006f3:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01006f8:	b8 00 00 00 00       	mov    $0x0,%eax
f01006fd:	ee                   	out    %al,(%dx)
f01006fe:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100703:	b8 03 00 00 00       	mov    $0x3,%eax
f0100708:	ee                   	out    %al,(%dx)
f0100709:	ba fc 03 00 00       	mov    $0x3fc,%edx
f010070e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100713:	ee                   	out    %al,(%dx)
f0100714:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100719:	b8 01 00 00 00       	mov    $0x1,%eax
f010071e:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010071f:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100724:	ec                   	in     (%dx),%al
f0100725:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100727:	83 c4 10             	add    $0x10,%esp
f010072a:	3c ff                	cmp    $0xff,%al
f010072c:	0f 95 05 34 12 23 f0 	setne  0xf0231234
f0100733:	89 f2                	mov    %esi,%edx
f0100735:	ec                   	in     (%dx),%al
f0100736:	89 da                	mov    %ebx,%edx
f0100738:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100739:	80 f9 ff             	cmp    $0xff,%cl
f010073c:	75 10                	jne    f010074e <cons_init+0x11d>
		cprintf("Serial port does not exist!\n");
f010073e:	83 ec 0c             	sub    $0xc,%esp
f0100741:	68 2f 6d 10 f0       	push   $0xf0106d2f
f0100746:	e8 13 34 00 00       	call   f0103b5e <cprintf>
f010074b:	83 c4 10             	add    $0x10,%esp
}
f010074e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100751:	5b                   	pop    %ebx
f0100752:	5e                   	pop    %esi
f0100753:	5f                   	pop    %edi
f0100754:	5d                   	pop    %ebp
f0100755:	c3                   	ret    

f0100756 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100756:	55                   	push   %ebp
f0100757:	89 e5                	mov    %esp,%ebp
f0100759:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010075c:	8b 45 08             	mov    0x8(%ebp),%eax
f010075f:	e8 6c fc ff ff       	call   f01003d0 <cons_putc>
}
f0100764:	c9                   	leave  
f0100765:	c3                   	ret    

f0100766 <getchar>:

int
getchar(void)
{
f0100766:	55                   	push   %ebp
f0100767:	89 e5                	mov    %esp,%ebp
f0100769:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010076c:	e8 76 fe ff ff       	call   f01005e7 <cons_getc>
f0100771:	85 c0                	test   %eax,%eax
f0100773:	74 f7                	je     f010076c <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100775:	c9                   	leave  
f0100776:	c3                   	ret    

f0100777 <iscons>:

int
iscons(int fdnum)
{
f0100777:	55                   	push   %ebp
f0100778:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010077a:	b8 01 00 00 00       	mov    $0x1,%eax
f010077f:	5d                   	pop    %ebp
f0100780:	c3                   	ret    

f0100781 <mon_exit>:
}


int 
mon_exit(int argc, char **argv, struct Trapframe *tf)
{
f0100781:	55                   	push   %ebp
f0100782:	89 e5                	mov    %esp,%ebp
	return -1;
}
f0100784:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100789:	5d                   	pop    %ebp
f010078a:	c3                   	ret    

f010078b <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010078b:	55                   	push   %ebp
f010078c:	89 e5                	mov    %esp,%ebp
f010078e:	56                   	push   %esi
f010078f:	53                   	push   %ebx
f0100790:	bb a4 73 10 f0       	mov    $0xf01073a4,%ebx
f0100795:	be f8 73 10 f0       	mov    $0xf01073f8,%esi
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010079a:	83 ec 04             	sub    $0x4,%esp
f010079d:	ff 33                	pushl  (%ebx)
f010079f:	ff 73 fc             	pushl  -0x4(%ebx)
f01007a2:	68 80 6f 10 f0       	push   $0xf0106f80
f01007a7:	e8 b2 33 00 00       	call   f0103b5e <cprintf>
f01007ac:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f01007af:	83 c4 10             	add    $0x10,%esp
f01007b2:	39 f3                	cmp    %esi,%ebx
f01007b4:	75 e4                	jne    f010079a <mon_help+0xf>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01007b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01007bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007be:	5b                   	pop    %ebx
f01007bf:	5e                   	pop    %esi
f01007c0:	5d                   	pop    %ebp
f01007c1:	c3                   	ret    

f01007c2 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007c2:	55                   	push   %ebp
f01007c3:	89 e5                	mov    %esp,%ebp
f01007c5:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007c8:	68 89 6f 10 f0       	push   $0xf0106f89
f01007cd:	e8 8c 33 00 00       	call   f0103b5e <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007d2:	83 c4 08             	add    $0x8,%esp
f01007d5:	68 0c 00 10 00       	push   $0x10000c
f01007da:	68 e0 70 10 f0       	push   $0xf01070e0
f01007df:	e8 7a 33 00 00       	call   f0103b5e <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007e4:	83 c4 0c             	add    $0xc,%esp
f01007e7:	68 0c 00 10 00       	push   $0x10000c
f01007ec:	68 0c 00 10 f0       	push   $0xf010000c
f01007f1:	68 08 71 10 f0       	push   $0xf0107108
f01007f6:	e8 63 33 00 00       	call   f0103b5e <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007fb:	83 c4 0c             	add    $0xc,%esp
f01007fe:	68 51 6c 10 00       	push   $0x106c51
f0100803:	68 51 6c 10 f0       	push   $0xf0106c51
f0100808:	68 2c 71 10 f0       	push   $0xf010712c
f010080d:	e8 4c 33 00 00       	call   f0103b5e <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100812:	83 c4 0c             	add    $0xc,%esp
f0100815:	68 10 0d 23 00       	push   $0x230d10
f010081a:	68 10 0d 23 f0       	push   $0xf0230d10
f010081f:	68 50 71 10 f0       	push   $0xf0107150
f0100824:	e8 35 33 00 00       	call   f0103b5e <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100829:	83 c4 0c             	add    $0xc,%esp
f010082c:	68 08 30 27 00       	push   $0x273008
f0100831:	68 08 30 27 f0       	push   $0xf0273008
f0100836:	68 74 71 10 f0       	push   $0xf0107174
f010083b:	e8 1e 33 00 00       	call   f0103b5e <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100840:	b8 07 34 27 f0       	mov    $0xf0273407,%eax
f0100845:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010084a:	83 c4 08             	add    $0x8,%esp
f010084d:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100852:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100858:	85 c0                	test   %eax,%eax
f010085a:	0f 48 c2             	cmovs  %edx,%eax
f010085d:	c1 f8 0a             	sar    $0xa,%eax
f0100860:	50                   	push   %eax
f0100861:	68 98 71 10 f0       	push   $0xf0107198
f0100866:	e8 f3 32 00 00       	call   f0103b5e <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f010086b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100870:	c9                   	leave  
f0100871:	c3                   	ret    

f0100872 <dump_contents_v>:
	return 0;
}

static void 
dump_contents_v(void* va1, void* va2) 
{
f0100872:	55                   	push   %ebp
f0100873:	89 e5                	mov    %esp,%ebp
f0100875:	57                   	push   %edi
f0100876:	56                   	push   %esi
f0100877:	53                   	push   %ebx
f0100878:	83 ec 0c             	sub    $0xc,%esp
f010087b:	89 c3                	mov    %eax,%ebx
f010087d:	89 d7                	mov    %edx,%edi
	typedef unsigned char byte;

	int count = 0;
f010087f:	be 00 00 00 00       	mov    $0x0,%esi
	byte *va;

	for (va = (byte *) va1; va < (byte *) va2; va++) {
f0100884:	eb 61                	jmp    f01008e7 <dump_contents_v+0x75>
		if (count == 0) 
f0100886:	85 f6                	test   %esi,%esi
f0100888:	75 29                	jne    f01008b3 <dump_contents_v+0x41>
			cprintf("%08p:", va);
f010088a:	83 ec 08             	sub    $0x8,%esp
f010088d:	53                   	push   %ebx
f010088e:	68 a2 6f 10 f0       	push   $0xf0106fa2
f0100893:	e8 c6 32 00 00       	call   f0103b5e <cprintf>

		cprintf(" %02x", *va);
f0100898:	83 c4 08             	add    $0x8,%esp
f010089b:	0f b6 03             	movzbl (%ebx),%eax
f010089e:	50                   	push   %eax
f010089f:	68 a8 6f 10 f0       	push   $0xf0106fa8
f01008a4:	e8 b5 32 00 00       	call   f0103b5e <cprintf>
f01008a9:	83 c4 10             	add    $0x10,%esp

		if (++count == 16) {
f01008ac:	be 01 00 00 00       	mov    $0x1,%esi
f01008b1:	eb 31                	jmp    f01008e4 <dump_contents_v+0x72>

	for (va = (byte *) va1; va < (byte *) va2; va++) {
		if (count == 0) 
			cprintf("%08p:", va);

		cprintf(" %02x", *va);
f01008b3:	83 ec 08             	sub    $0x8,%esp
f01008b6:	0f b6 03             	movzbl (%ebx),%eax
f01008b9:	50                   	push   %eax
f01008ba:	68 a8 6f 10 f0       	push   $0xf0106fa8
f01008bf:	e8 9a 32 00 00       	call   f0103b5e <cprintf>

		if (++count == 16) {
f01008c4:	83 c6 01             	add    $0x1,%esi
f01008c7:	83 c4 10             	add    $0x10,%esp
f01008ca:	83 fe 10             	cmp    $0x10,%esi
f01008cd:	75 15                	jne    f01008e4 <dump_contents_v+0x72>
			count = 0;
			cprintf("\n");
f01008cf:	83 ec 0c             	sub    $0xc,%esp
f01008d2:	68 28 80 10 f0       	push   $0xf0108028
f01008d7:	e8 82 32 00 00       	call   f0103b5e <cprintf>
f01008dc:	83 c4 10             	add    $0x10,%esp
			cprintf("%08p:", va);

		cprintf(" %02x", *va);

		if (++count == 16) {
			count = 0;
f01008df:	be 00 00 00 00       	mov    $0x0,%esi
	typedef unsigned char byte;

	int count = 0;
	byte *va;

	for (va = (byte *) va1; va < (byte *) va2; va++) {
f01008e4:	83 c3 01             	add    $0x1,%ebx
f01008e7:	39 fb                	cmp    %edi,%ebx
f01008e9:	72 9b                	jb     f0100886 <dump_contents_v+0x14>
		if (++count == 16) {
			count = 0;
			cprintf("\n");
		}
	}
	if (count != 0)
f01008eb:	85 f6                	test   %esi,%esi
f01008ed:	74 10                	je     f01008ff <dump_contents_v+0x8d>
		cprintf("\n");
f01008ef:	83 ec 0c             	sub    $0xc,%esp
f01008f2:	68 28 80 10 f0       	push   $0xf0108028
f01008f7:	e8 62 32 00 00       	call   f0103b5e <cprintf>
f01008fc:	83 c4 10             	add    $0x10,%esp
}
f01008ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100902:	5b                   	pop    %ebx
f0100903:	5e                   	pop    %esi
f0100904:	5f                   	pop    %edi
f0100905:	5d                   	pop    %ebp
f0100906:	c3                   	ret    

f0100907 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100907:	55                   	push   %ebp
f0100908:	89 e5                	mov    %esp,%ebp
f010090a:	57                   	push   %edi
f010090b:	56                   	push   %esi
f010090c:	53                   	push   %ebx
f010090d:	83 ec 48             	sub    $0x48,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100910:	89 ee                	mov    %ebp,%esi
	uint32_t *stack_top = (uint32_t *) read_ebp();
	uint32_t *args, argi, argn = 5;
	
	struct Eipdebuginfo info;
	
	cprintf("Stack backtrace:\n");
f0100912:	68 ae 6f 10 f0       	push   $0xf0106fae
f0100917:	e8 42 32 00 00       	call   f0103b5e <cprintf>
	while (stack_top) {
f010091c:	83 c4 10             	add    $0x10,%esp
f010091f:	eb 78                	jmp    f0100999 <mon_backtrace+0x92>
		uint32_t eip = *(stack_top + 1);
f0100921:	8b 46 04             	mov    0x4(%esi),%eax
f0100924:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		cprintf("  ebp %08x  eip %08x  args", (uint32_t)stack_top, *(stack_top + 1));
f0100927:	83 ec 04             	sub    $0x4,%esp
f010092a:	50                   	push   %eax
f010092b:	56                   	push   %esi
f010092c:	68 c0 6f 10 f0       	push   $0xf0106fc0
f0100931:	e8 28 32 00 00       	call   f0103b5e <cprintf>
f0100936:	8d 5e 08             	lea    0x8(%esi),%ebx
f0100939:	8d 7e 1c             	lea    0x1c(%esi),%edi
f010093c:	83 c4 10             	add    $0x10,%esp
		args = stack_top + 2;
		for (argi = 0; argi < argn; argi++) 
			cprintf(" %08x", args[argi]);
f010093f:	83 ec 08             	sub    $0x8,%esp
f0100942:	ff 33                	pushl  (%ebx)
f0100944:	68 db 6f 10 f0       	push   $0xf0106fdb
f0100949:	e8 10 32 00 00       	call   f0103b5e <cprintf>
f010094e:	83 c3 04             	add    $0x4,%ebx
	cprintf("Stack backtrace:\n");
	while (stack_top) {
		uint32_t eip = *(stack_top + 1);
		cprintf("  ebp %08x  eip %08x  args", (uint32_t)stack_top, *(stack_top + 1));
		args = stack_top + 2;
		for (argi = 0; argi < argn; argi++) 
f0100951:	83 c4 10             	add    $0x10,%esp
f0100954:	39 fb                	cmp    %edi,%ebx
f0100956:	75 e7                	jne    f010093f <mon_backtrace+0x38>
			cprintf(" %08x", args[argi]);
		cprintf("\n");
f0100958:	83 ec 0c             	sub    $0xc,%esp
f010095b:	68 28 80 10 f0       	push   $0xf0108028
f0100960:	e8 f9 31 00 00       	call   f0103b5e <cprintf>
		debuginfo_eip(eip, &info);
f0100965:	83 c4 08             	add    $0x8,%esp
f0100968:	8d 45 d0             	lea    -0x30(%ebp),%eax
f010096b:	50                   	push   %eax
f010096c:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010096f:	57                   	push   %edi
f0100970:	e8 d8 4b 00 00       	call   f010554d <debuginfo_eip>
		cprintf("         %s:%d: %.*s+%u\n", 
f0100975:	83 c4 08             	add    $0x8,%esp
f0100978:	89 f8                	mov    %edi,%eax
f010097a:	2b 45 e0             	sub    -0x20(%ebp),%eax
f010097d:	50                   	push   %eax
f010097e:	ff 75 d8             	pushl  -0x28(%ebp)
f0100981:	ff 75 dc             	pushl  -0x24(%ebp)
f0100984:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100987:	ff 75 d0             	pushl  -0x30(%ebp)
f010098a:	68 e1 6f 10 f0       	push   $0xf0106fe1
f010098f:	e8 ca 31 00 00       	call   f0103b5e <cprintf>
			info.eip_file, info.eip_line, 
			info.eip_fn_namelen, info.eip_fn_name, 
			eip - info.eip_fn_addr);
		stack_top = (uint32_t *)(*stack_top);
f0100994:	8b 36                	mov    (%esi),%esi
f0100996:	83 c4 20             	add    $0x20,%esp
	uint32_t *args, argi, argn = 5;
	
	struct Eipdebuginfo info;
	
	cprintf("Stack backtrace:\n");
	while (stack_top) {
f0100999:	85 f6                	test   %esi,%esi
f010099b:	75 84                	jne    f0100921 <mon_backtrace+0x1a>
			info.eip_fn_namelen, info.eip_fn_name, 
			eip - info.eip_fn_addr);
		stack_top = (uint32_t *)(*stack_top);
	}
	return 0;
}
f010099d:	b8 00 00 00 00       	mov    $0x0,%eax
f01009a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009a5:	5b                   	pop    %ebx
f01009a6:	5e                   	pop    %esi
f01009a7:	5f                   	pop    %edi
f01009a8:	5d                   	pop    %ebp
f01009a9:	c3                   	ret    

f01009aa <str2addr>:

static int
str2addr(char *str, void **result) {
f01009aa:	55                   	push   %ebp
f01009ab:	89 e5                	mov    %esp,%ebp
f01009ad:	56                   	push   %esi
f01009ae:	53                   	push   %ebx
f01009af:	83 ec 14             	sub    $0x14,%esp
f01009b2:	89 c3                	mov    %eax,%ebx
f01009b4:	89 d6                	mov    %edx,%esi
	char *end = str;
f01009b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	*result = (void *)strtol(str, &end, 16);
f01009b9:	6a 10                	push   $0x10
f01009bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01009be:	50                   	push   %eax
f01009bf:	53                   	push   %ebx
f01009c0:	e8 15 57 00 00       	call   f01060da <strtol>
f01009c5:	89 06                	mov    %eax,(%esi)
	if (strlen(str) != (int)(end - str)) 
f01009c7:	89 1c 24             	mov    %ebx,(%esp)
f01009ca:	e8 69 54 00 00       	call   f0105e38 <strlen>
		return 	0;
f01009cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01009d2:	29 da                	sub    %ebx,%edx
f01009d4:	83 c4 10             	add    $0x10,%esp
f01009d7:	39 c2                	cmp    %eax,%edx
f01009d9:	0f 94 c0             	sete   %al
f01009dc:	0f b6 c0             	movzbl %al,%eax
	return 1;
}
f01009df:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01009e2:	5b                   	pop    %ebx
f01009e3:	5e                   	pop    %esi
f01009e4:	5d                   	pop    %ebp
f01009e5:	c3                   	ret    

f01009e6 <show_mapping>:
	return 0;
}

static void
show_mapping(void *vaddr)
{
f01009e6:	55                   	push   %ebp
f01009e7:	89 e5                	mov    %esp,%ebp
f01009e9:	53                   	push   %ebx
f01009ea:	83 ec 18             	sub    $0x18,%esp
f01009ed:	89 c3                	mov    %eax,%ebx
	pte_t *pte;
	if (page_lookup(kern_pgdir, vaddr, &pte)) { 
f01009ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01009f2:	50                   	push   %eax
f01009f3:	53                   	push   %ebx
f01009f4:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f01009fa:	e8 24 0b 00 00       	call   f0101523 <page_lookup>
f01009ff:	83 c4 10             	add    $0x10,%esp
f0100a02:	85 c0                	test   %eax,%eax
f0100a04:	0f 84 d8 00 00 00    	je     f0100ae2 <show_mapping+0xfc>
		void *paddr = (void *)PTE_ADDR(*pte);
		cprintf("va: %08p  pa (of page): %08p  perms: ", vaddr, paddr);
f0100a0a:	83 ec 04             	sub    $0x4,%esp
static void
show_mapping(void *vaddr)
{
	pte_t *pte;
	if (page_lookup(kern_pgdir, vaddr, &pte)) { 
		void *paddr = (void *)PTE_ADDR(*pte);
f0100a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
		cprintf("va: %08p  pa (of page): %08p  perms: ", vaddr, paddr);
f0100a10:	8b 00                	mov    (%eax),%eax
f0100a12:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a17:	50                   	push   %eax
f0100a18:	53                   	push   %ebx
f0100a19:	68 c4 71 10 f0       	push   $0xf01071c4
f0100a1e:	e8 3b 31 00 00       	call   f0103b5e <cprintf>
		/* PTE_P ommitted */
		if (*pte & PTE_W)    cprintf("W ");
f0100a23:	83 c4 10             	add    $0x10,%esp
f0100a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100a29:	f6 00 02             	testb  $0x2,(%eax)
f0100a2c:	74 10                	je     f0100a3e <show_mapping+0x58>
f0100a2e:	83 ec 0c             	sub    $0xc,%esp
f0100a31:	68 fa 6f 10 f0       	push   $0xf0106ffa
f0100a36:	e8 23 31 00 00       	call   f0103b5e <cprintf>
f0100a3b:	83 c4 10             	add    $0x10,%esp
		if (*pte & PTE_U)    cprintf("U ");
f0100a3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100a41:	f6 00 04             	testb  $0x4,(%eax)
f0100a44:	74 10                	je     f0100a56 <show_mapping+0x70>
f0100a46:	83 ec 0c             	sub    $0xc,%esp
f0100a49:	68 fd 6f 10 f0       	push   $0xf0106ffd
f0100a4e:	e8 0b 31 00 00       	call   f0103b5e <cprintf>
f0100a53:	83 c4 10             	add    $0x10,%esp
		if (*pte & PTE_PWT)  cprintf("WT ");
f0100a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100a59:	f6 00 08             	testb  $0x8,(%eax)
f0100a5c:	74 10                	je     f0100a6e <show_mapping+0x88>
f0100a5e:	83 ec 0c             	sub    $0xc,%esp
f0100a61:	68 00 70 10 f0       	push   $0xf0107000
f0100a66:	e8 f3 30 00 00       	call   f0103b5e <cprintf>
f0100a6b:	83 c4 10             	add    $0x10,%esp
		if (*pte & PTE_PCD)  cprintf("CD ");
f0100a6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100a71:	f6 00 10             	testb  $0x10,(%eax)
f0100a74:	74 10                	je     f0100a86 <show_mapping+0xa0>
f0100a76:	83 ec 0c             	sub    $0xc,%esp
f0100a79:	68 04 70 10 f0       	push   $0xf0107004
f0100a7e:	e8 db 30 00 00       	call   f0103b5e <cprintf>
f0100a83:	83 c4 10             	add    $0x10,%esp
		if (*pte & PTE_A)    cprintf("A ");
f0100a86:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100a89:	f6 00 20             	testb  $0x20,(%eax)
f0100a8c:	74 10                	je     f0100a9e <show_mapping+0xb8>
f0100a8e:	83 ec 0c             	sub    $0xc,%esp
f0100a91:	68 08 70 10 f0       	push   $0xf0107008
f0100a96:	e8 c3 30 00 00       	call   f0103b5e <cprintf>
f0100a9b:	83 c4 10             	add    $0x10,%esp
		if (*pte & PTE_D)    cprintf("D ");
f0100a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100aa1:	f6 00 40             	testb  $0x40,(%eax)
f0100aa4:	74 10                	je     f0100ab6 <show_mapping+0xd0>
f0100aa6:	83 ec 0c             	sub    $0xc,%esp
f0100aa9:	68 05 70 10 f0       	push   $0xf0107005
f0100aae:	e8 ab 30 00 00       	call   f0103b5e <cprintf>
f0100ab3:	83 c4 10             	add    $0x10,%esp
		/* PTE_PS ommitted */
		if (*pte & PTE_G)    cprintf("G ");
f0100ab6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100ab9:	8b 00                	mov    (%eax),%eax
f0100abb:	f6 c4 01             	test   $0x1,%ah
f0100abe:	74 10                	je     f0100ad0 <show_mapping+0xea>
f0100ac0:	83 ec 0c             	sub    $0xc,%esp
f0100ac3:	68 0b 70 10 f0       	push   $0xf010700b
f0100ac8:	e8 91 30 00 00       	call   f0103b5e <cprintf>
f0100acd:	83 c4 10             	add    $0x10,%esp
		cprintf("\n");
f0100ad0:	83 ec 0c             	sub    $0xc,%esp
f0100ad3:	68 28 80 10 f0       	push   $0xf0108028
f0100ad8:	e8 81 30 00 00       	call   f0103b5e <cprintf>
f0100add:	83 c4 10             	add    $0x10,%esp
f0100ae0:	eb 11                	jmp    f0100af3 <show_mapping+0x10d>
	} else {
		cprintf("No physical page mapping at %08p\n", vaddr);
f0100ae2:	83 ec 08             	sub    $0x8,%esp
f0100ae5:	53                   	push   %ebx
f0100ae6:	68 ec 71 10 f0       	push   $0xf01071ec
f0100aeb:	e8 6e 30 00 00       	call   f0103b5e <cprintf>
f0100af0:	83 c4 10             	add    $0x10,%esp
	}
}
f0100af3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100af6:	c9                   	leave  
f0100af7:	c3                   	ret    

f0100af8 <mon_showmappings>:

int
mon_showmappings(int argc, char** argv, struct Trapframe *tf) 
{	
f0100af8:	55                   	push   %ebp
f0100af9:	89 e5                	mov    %esp,%ebp
f0100afb:	53                   	push   %ebx
f0100afc:	83 ec 14             	sub    $0x14,%esp
f0100aff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	const char *usage = "Usage: showmappings vaddr1 [vaddr2]\n";
	void *vaddr1, *vaddr2;

	if (argc < 2 || argc > 3) 	
f0100b02:	8d 43 fe             	lea    -0x2(%ebx),%eax
f0100b05:	83 f8 01             	cmp    $0x1,%eax
f0100b08:	76 12                	jbe    f0100b1c <mon_showmappings+0x24>
}

inline static int 
usage_exit(const char *usage) 
{
	cprintf(usage);
f0100b0a:	83 ec 0c             	sub    $0xc,%esp
f0100b0d:	68 10 72 10 f0       	push   $0xf0107210
f0100b12:	e8 47 30 00 00       	call   f0103b5e <cprintf>
{	
	const char *usage = "Usage: showmappings vaddr1 [vaddr2]\n";
	void *vaddr1, *vaddr2;

	if (argc < 2 || argc > 3) 	
		return usage_exit(usage);
f0100b17:	83 c4 10             	add    $0x10,%esp
f0100b1a:	eb 6c                	jmp    f0100b88 <mon_showmappings+0x90>

	if (!str2addr(argv[1], &vaddr1)) 
f0100b1c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100b1f:	8b 40 04             	mov    0x4(%eax),%eax
f0100b22:	8d 55 f4             	lea    -0xc(%ebp),%edx
f0100b25:	e8 80 fe ff ff       	call   f01009aa <str2addr>
f0100b2a:	85 c0                	test   %eax,%eax
f0100b2c:	75 12                	jne    f0100b40 <mon_showmappings+0x48>
}

inline static int 
usage_exit(const char *usage) 
{
	cprintf(usage);
f0100b2e:	83 ec 0c             	sub    $0xc,%esp
f0100b31:	68 10 72 10 f0       	push   $0xf0107210
f0100b36:	e8 23 30 00 00       	call   f0103b5e <cprintf>

	if (argc < 2 || argc > 3) 	
		return usage_exit(usage);

	if (!str2addr(argv[1], &vaddr1)) 
		return usage_exit(usage);
f0100b3b:	83 c4 10             	add    $0x10,%esp
f0100b3e:	eb 48                	jmp    f0100b88 <mon_showmappings+0x90>
	
			
	if (argc == 2) {
f0100b40:	83 fb 02             	cmp    $0x2,%ebx
f0100b43:	75 0a                	jne    f0100b4f <mon_showmappings+0x57>
		show_mapping(vaddr1);
f0100b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100b48:	e8 99 fe ff ff       	call   f01009e6 <show_mapping>
f0100b4d:	eb 39                	jmp    f0100b88 <mon_showmappings+0x90>
	} else { // argc == 3
		char* vaddr;

		if (!str2addr(argv[2], &vaddr2)) 
f0100b4f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100b52:	8b 40 08             	mov    0x8(%eax),%eax
f0100b55:	8d 55 f0             	lea    -0x10(%ebp),%edx
f0100b58:	e8 4d fe ff ff       	call   f01009aa <str2addr>
			return usage_exit(usage);
		
		for (vaddr = (char *) vaddr1; vaddr < (char *) vaddr2; vaddr += PGSIZE) 
f0100b5d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
	if (argc == 2) {
		show_mapping(vaddr1);
	} else { // argc == 3
		char* vaddr;

		if (!str2addr(argv[2], &vaddr2)) 
f0100b60:	85 c0                	test   %eax,%eax
f0100b62:	75 1f                	jne    f0100b83 <mon_showmappings+0x8b>
}

inline static int 
usage_exit(const char *usage) 
{
	cprintf(usage);
f0100b64:	83 ec 0c             	sub    $0xc,%esp
f0100b67:	68 10 72 10 f0       	push   $0xf0107210
f0100b6c:	e8 ed 2f 00 00       	call   f0103b5e <cprintf>
		show_mapping(vaddr1);
	} else { // argc == 3
		char* vaddr;

		if (!str2addr(argv[2], &vaddr2)) 
			return usage_exit(usage);
f0100b71:	83 c4 10             	add    $0x10,%esp
f0100b74:	eb 12                	jmp    f0100b88 <mon_showmappings+0x90>
		
		for (vaddr = (char *) vaddr1; vaddr < (char *) vaddr2; vaddr += PGSIZE) 
			show_mapping((void *) vaddr);
f0100b76:	89 d8                	mov    %ebx,%eax
f0100b78:	e8 69 fe ff ff       	call   f01009e6 <show_mapping>
		char* vaddr;

		if (!str2addr(argv[2], &vaddr2)) 
			return usage_exit(usage);
		
		for (vaddr = (char *) vaddr1; vaddr < (char *) vaddr2; vaddr += PGSIZE) 
f0100b7d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100b83:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100b86:	72 ee                	jb     f0100b76 <mon_showmappings+0x7e>
			show_mapping((void *) vaddr);
	}
	return 0;
}
f0100b88:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b8d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b90:	c9                   	leave  
f0100b91:	c3                   	ret    

f0100b92 <mon_changeperms>:
	return -1;
}

int 
mon_changeperms(int argc, char** argv, struct Trapframe *tf) 
{
f0100b92:	55                   	push   %ebp
f0100b93:	89 e5                	mov    %esp,%ebp
f0100b95:	57                   	push   %edi
f0100b96:	56                   	push   %esi
f0100b97:	53                   	push   %ebx
f0100b98:	83 ec 1c             	sub    $0x1c,%esp
	void *vaddr;
	pte_t *pte;
	int perms = PTE_P;
	int i;
	
	if (argc < 3) 
f0100b9b:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100b9f:	7f 15                	jg     f0100bb6 <mon_changeperms+0x24>
}

inline static int 
usage_exit(const char *usage) 
{
	cprintf(usage);
f0100ba1:	83 ec 0c             	sub    $0xc,%esp
f0100ba4:	68 38 72 10 f0       	push   $0xf0107238
f0100ba9:	e8 b0 2f 00 00       	call   f0103b5e <cprintf>
	pte_t *pte;
	int perms = PTE_P;
	int i;
	
	if (argc < 3) 
		return usage_exit(usage);
f0100bae:	83 c4 10             	add    $0x10,%esp
f0100bb1:	e9 ca 00 00 00       	jmp    f0100c80 <mon_changeperms+0xee>
	
	if (!str2addr(argv[1], &vaddr))
f0100bb6:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100bb9:	8b 40 04             	mov    0x4(%eax),%eax
f0100bbc:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100bbf:	e8 e6 fd ff ff       	call   f01009aa <str2addr>
f0100bc4:	85 c0                	test   %eax,%eax
f0100bc6:	75 15                	jne    f0100bdd <mon_changeperms+0x4b>
}

inline static int 
usage_exit(const char *usage) 
{
	cprintf(usage);
f0100bc8:	83 ec 0c             	sub    $0xc,%esp
f0100bcb:	68 38 72 10 f0       	push   $0xf0107238
f0100bd0:	e8 89 2f 00 00       	call   f0103b5e <cprintf>
	
	if (argc < 3) 
		return usage_exit(usage);
	
	if (!str2addr(argv[1], &vaddr))
		return usage_exit(usage);
f0100bd5:	83 c4 10             	add    $0x10,%esp
f0100bd8:	e9 a3 00 00 00       	jmp    f0100c80 <mon_changeperms+0xee>
	
	if (!page_lookup(kern_pgdir, vaddr, &pte)) {
f0100bdd:	83 ec 04             	sub    $0x4,%esp
f0100be0:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0100be3:	50                   	push   %eax
f0100be4:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100be7:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0100bed:	e8 31 09 00 00       	call   f0101523 <page_lookup>
f0100bf2:	83 c4 10             	add    $0x10,%esp
f0100bf5:	bb 02 00 00 00       	mov    $0x2,%ebx
f0100bfa:	bf 01 00 00 00       	mov    $0x1,%edi
f0100bff:	85 c0                	test   %eax,%eax
f0100c01:	75 15                	jne    f0100c18 <mon_changeperms+0x86>
		cprintf("No physical page mapping at %08p\n", vaddr);
f0100c03:	83 ec 08             	sub    $0x8,%esp
f0100c06:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100c09:	68 ec 71 10 f0       	push   $0xf01071ec
f0100c0e:	e8 4b 2f 00 00       	call   f0103b5e <cprintf>
		return 0;
f0100c13:	83 c4 10             	add    $0x10,%esp
f0100c16:	eb 68                	jmp    f0100c80 <mon_changeperms+0xee>
	}

	for (i = 2; i < argc; i++) {
		int perm = str2perm(argv[i]);
f0100c18:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100c1b:	8b 34 98             	mov    (%eax,%ebx,4),%esi
	return 0;
}

static int 
str2perm(const char* s) {
	if (!strcmp(s, "W"))
f0100c1e:	83 ec 08             	sub    $0x8,%esp
f0100c21:	68 4a 80 10 f0       	push   $0xf010804a
f0100c26:	56                   	push   %esi
f0100c27:	e8 ef 52 00 00       	call   f0105f1b <strcmp>
f0100c2c:	83 c4 10             	add    $0x10,%esp
		return PTE_W;
f0100c2f:	ba 02 00 00 00       	mov    $0x2,%edx
	return 0;
}

static int 
str2perm(const char* s) {
	if (!strcmp(s, "W"))
f0100c34:	85 c0                	test   %eax,%eax
f0100c36:	74 2c                	je     f0100c64 <mon_changeperms+0xd2>
		return PTE_W;
	if (!strcmp(s, "U"))
f0100c38:	83 ec 08             	sub    $0x8,%esp
f0100c3b:	68 7a 7f 10 f0       	push   $0xf0107f7a
f0100c40:	56                   	push   %esi
f0100c41:	e8 d5 52 00 00       	call   f0105f1b <strcmp>
f0100c46:	83 c4 10             	add    $0x10,%esp
f0100c49:	85 c0                	test   %eax,%eax
f0100c4b:	74 12                	je     f0100c5f <mon_changeperms+0xcd>
f0100c4d:	eb 21                	jmp    f0100c70 <mon_changeperms+0xde>
		if (perm < 0) 
			return usage_exit(usage);
		perms |= perm;
	}
	
	*pte = (*pte & (~0xFFF)) | perms;
f0100c4f:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100c52:	8b 02                	mov    (%edx),%eax
f0100c54:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100c59:	09 c7                	or     %eax,%edi
f0100c5b:	89 3a                	mov    %edi,(%edx)
		
	return 0;
f0100c5d:	eb 21                	jmp    f0100c80 <mon_changeperms+0xee>
static int 
str2perm(const char* s) {
	if (!strcmp(s, "W"))
		return PTE_W;
	if (!strcmp(s, "U"))
		return PTE_U;
f0100c5f:	ba 04 00 00 00       	mov    $0x4,%edx

	for (i = 2; i < argc; i++) {
		int perm = str2perm(argv[i]);
		if (perm < 0) 
			return usage_exit(usage);
		perms |= perm;
f0100c64:	09 d7                	or     %edx,%edi
	if (!page_lookup(kern_pgdir, vaddr, &pte)) {
		cprintf("No physical page mapping at %08p\n", vaddr);
		return 0;
	}

	for (i = 2; i < argc; i++) {
f0100c66:	83 c3 01             	add    $0x1,%ebx
f0100c69:	39 5d 08             	cmp    %ebx,0x8(%ebp)
f0100c6c:	75 aa                	jne    f0100c18 <mon_changeperms+0x86>
f0100c6e:	eb df                	jmp    f0100c4f <mon_changeperms+0xbd>
}

inline static int 
usage_exit(const char *usage) 
{
	cprintf(usage);
f0100c70:	83 ec 0c             	sub    $0xc,%esp
f0100c73:	68 38 72 10 f0       	push   $0xf0107238
f0100c78:	e8 e1 2e 00 00       	call   f0103b5e <cprintf>
	}

	for (i = 2; i < argc; i++) {
		int perm = str2perm(argv[i]);
		if (perm < 0) 
			return usage_exit(usage);
f0100c7d:	83 c4 10             	add    $0x10,%esp
	}
	
	*pte = (*pte & (~0xFFF)) | perms;
		
	return 0;
}
f0100c80:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c85:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c88:	5b                   	pop    %ebx
f0100c89:	5e                   	pop    %esi
f0100c8a:	5f                   	pop    %edi
f0100c8b:	5d                   	pop    %ebp
f0100c8c:	c3                   	ret    

f0100c8d <mon_dumpcontents>:
	dump_contents_v(KADDR(pa1), KADDR(pa2));
}

int 
mon_dumpcontents(int argc, char **argv, struct Trapframe *tf) 
{
f0100c8d:	55                   	push   %ebp
f0100c8e:	89 e5                	mov    %esp,%ebp
f0100c90:	53                   	push   %ebx
f0100c91:	83 ec 14             	sub    $0x14,%esp
f0100c94:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const char *usage = "Usage: dumpcontents v vaddr1 vaddr2\n"
	                    "       dumpcontents p paddr1 paddr2\n";
	void *addr1, *addr2;
	if (argc != 4)
f0100c97:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100c9b:	74 15                	je     f0100cb2 <mon_dumpcontents+0x25>
}

inline static int 
usage_exit(const char *usage) 
{
	cprintf(usage);
f0100c9d:	83 ec 0c             	sub    $0xc,%esp
f0100ca0:	68 5c 72 10 f0       	push   $0xf010725c
f0100ca5:	e8 b4 2e 00 00       	call   f0103b5e <cprintf>
{
	const char *usage = "Usage: dumpcontents v vaddr1 vaddr2\n"
	                    "       dumpcontents p paddr1 paddr2\n";
	void *addr1, *addr2;
	if (argc != 4)
		return usage_exit(usage);
f0100caa:	83 c4 10             	add    $0x10,%esp
f0100cad:	e9 c6 00 00 00       	jmp    f0100d78 <mon_dumpcontents+0xeb>
	
	if (!str2addr(argv[2], &addr1) || !str2addr(argv[3], &addr2))
f0100cb2:	8b 43 08             	mov    0x8(%ebx),%eax
f0100cb5:	8d 55 f4             	lea    -0xc(%ebp),%edx
f0100cb8:	e8 ed fc ff ff       	call   f01009aa <str2addr>
f0100cbd:	85 c0                	test   %eax,%eax
f0100cbf:	74 0f                	je     f0100cd0 <mon_dumpcontents+0x43>
f0100cc1:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100cc4:	8d 55 f0             	lea    -0x10(%ebp),%edx
f0100cc7:	e8 de fc ff ff       	call   f01009aa <str2addr>
f0100ccc:	85 c0                	test   %eax,%eax
f0100cce:	75 15                	jne    f0100ce5 <mon_dumpcontents+0x58>
}

inline static int 
usage_exit(const char *usage) 
{
	cprintf(usage);
f0100cd0:	83 ec 0c             	sub    $0xc,%esp
f0100cd3:	68 5c 72 10 f0       	push   $0xf010725c
f0100cd8:	e8 81 2e 00 00       	call   f0103b5e <cprintf>
	void *addr1, *addr2;
	if (argc != 4)
		return usage_exit(usage);
	
	if (!str2addr(argv[2], &addr1) || !str2addr(argv[3], &addr2))
		return usage_exit(usage);	
f0100cdd:	83 c4 10             	add    $0x10,%esp
f0100ce0:	e9 93 00 00 00       	jmp    f0100d78 <mon_dumpcontents+0xeb>

	if (argv[1][0] == 'v' && argv[1][1] == '\0') 
f0100ce5:	8b 43 04             	mov    0x4(%ebx),%eax
f0100ce8:	0f b6 10             	movzbl (%eax),%edx
f0100ceb:	80 fa 76             	cmp    $0x76,%dl
f0100cee:	75 13                	jne    f0100d03 <mon_dumpcontents+0x76>
f0100cf0:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
f0100cf4:	75 72                	jne    f0100d68 <mon_dumpcontents+0xdb>
		dump_contents_v(addr1, addr2);
f0100cf6:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0100cf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100cfc:	e8 71 fb ff ff       	call   f0100872 <dump_contents_v>
f0100d01:	eb 75                	jmp    f0100d78 <mon_dumpcontents+0xeb>
	else if (argv[1][0] == 'p' && argv[1][1] == '\0')
f0100d03:	80 fa 70             	cmp    $0x70,%dl
f0100d06:	75 60                	jne    f0100d68 <mon_dumpcontents+0xdb>
f0100d08:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
f0100d0c:	75 5a                	jne    f0100d68 <mon_dumpcontents+0xdb>
		dump_contents_p((physaddr_t)addr1, (physaddr_t)addr2); 
f0100d0e:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0100d11:	8b 45 f4             	mov    -0xc(%ebp),%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d14:	8b 0d 88 1e 23 f0    	mov    0xf0231e88,%ecx
f0100d1a:	89 d3                	mov    %edx,%ebx
f0100d1c:	c1 eb 0c             	shr    $0xc,%ebx
f0100d1f:	39 cb                	cmp    %ecx,%ebx
f0100d21:	72 15                	jb     f0100d38 <mon_dumpcontents+0xab>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d23:	52                   	push   %edx
f0100d24:	68 84 6c 10 f0       	push   $0xf0106c84
f0100d29:	68 e0 00 00 00       	push   $0xe0
f0100d2e:	68 0e 70 10 f0       	push   $0xf010700e
f0100d33:	e8 08 f3 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100d38:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d3e:	89 c3                	mov    %eax,%ebx
f0100d40:	c1 eb 0c             	shr    $0xc,%ebx
f0100d43:	39 d9                	cmp    %ebx,%ecx
f0100d45:	77 15                	ja     f0100d5c <mon_dumpcontents+0xcf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d47:	50                   	push   %eax
f0100d48:	68 84 6c 10 f0       	push   $0xf0106c84
f0100d4d:	68 e0 00 00 00       	push   $0xe0
f0100d52:	68 0e 70 10 f0       	push   $0xf010700e
f0100d57:	e8 e4 f2 ff ff       	call   f0100040 <_panic>

static void
dump_contents_p(physaddr_t pa1, physaddr_t pa2) 
{
	//panic("dump_contents_p is not implemented");	
	dump_contents_v(KADDR(pa1), KADDR(pa2));
f0100d5c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100d61:	e8 0c fb ff ff       	call   f0100872 <dump_contents_v>
f0100d66:	eb 10                	jmp    f0100d78 <mon_dumpcontents+0xeb>
}

inline static int 
usage_exit(const char *usage) 
{
	cprintf(usage);
f0100d68:	83 ec 0c             	sub    $0xc,%esp
f0100d6b:	68 5c 72 10 f0       	push   $0xf010725c
f0100d70:	e8 e9 2d 00 00       	call   f0103b5e <cprintf>
	if (argv[1][0] == 'v' && argv[1][1] == '\0') 
		dump_contents_v(addr1, addr2);
	else if (argv[1][0] == 'p' && argv[1][1] == '\0')
		dump_contents_p((physaddr_t)addr1, (physaddr_t)addr2); 
	else 
		return usage_exit(usage);
f0100d75:	83 c4 10             	add    $0x10,%esp

	return 0;	
}
f0100d78:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100d80:	c9                   	leave  
f0100d81:	c3                   	ret    

f0100d82 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100d82:	55                   	push   %ebp
f0100d83:	89 e5                	mov    %esp,%ebp
f0100d85:	57                   	push   %edi
f0100d86:	56                   	push   %esi
f0100d87:	53                   	push   %ebx
f0100d88:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100d8b:	68 a8 72 10 f0       	push   $0xf01072a8
f0100d90:	e8 c9 2d 00 00       	call   f0103b5e <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100d95:	c7 04 24 cc 72 10 f0 	movl   $0xf01072cc,(%esp)
f0100d9c:	e8 bd 2d 00 00       	call   f0103b5e <cprintf>

	if (tf != NULL)
f0100da1:	83 c4 10             	add    $0x10,%esp
f0100da4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100da8:	74 0e                	je     f0100db8 <monitor+0x36>
		print_trapframe(tf);
f0100daa:	83 ec 0c             	sub    $0xc,%esp
f0100dad:	ff 75 08             	pushl  0x8(%ebp)
f0100db0:	e8 a8 2f 00 00       	call   f0103d5d <print_trapframe>
f0100db5:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100db8:	83 ec 0c             	sub    $0xc,%esp
f0100dbb:	68 1d 70 10 f0       	push   $0xf010701d
f0100dc0:	e8 9a 4f 00 00       	call   f0105d5f <readline>
f0100dc5:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100dc7:	83 c4 10             	add    $0x10,%esp
f0100dca:	85 c0                	test   %eax,%eax
f0100dcc:	74 ea                	je     f0100db8 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100dce:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100dd5:	be 00 00 00 00       	mov    $0x0,%esi
f0100dda:	eb 0a                	jmp    f0100de6 <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100ddc:	c6 03 00             	movb   $0x0,(%ebx)
f0100ddf:	89 f7                	mov    %esi,%edi
f0100de1:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100de4:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100de6:	0f b6 03             	movzbl (%ebx),%eax
f0100de9:	84 c0                	test   %al,%al
f0100deb:	74 63                	je     f0100e50 <monitor+0xce>
f0100ded:	83 ec 08             	sub    $0x8,%esp
f0100df0:	0f be c0             	movsbl %al,%eax
f0100df3:	50                   	push   %eax
f0100df4:	68 21 70 10 f0       	push   $0xf0107021
f0100df9:	e8 7b 51 00 00       	call   f0105f79 <strchr>
f0100dfe:	83 c4 10             	add    $0x10,%esp
f0100e01:	85 c0                	test   %eax,%eax
f0100e03:	75 d7                	jne    f0100ddc <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f0100e05:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100e08:	74 46                	je     f0100e50 <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100e0a:	83 fe 0f             	cmp    $0xf,%esi
f0100e0d:	75 14                	jne    f0100e23 <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100e0f:	83 ec 08             	sub    $0x8,%esp
f0100e12:	6a 10                	push   $0x10
f0100e14:	68 26 70 10 f0       	push   $0xf0107026
f0100e19:	e8 40 2d 00 00       	call   f0103b5e <cprintf>
f0100e1e:	83 c4 10             	add    $0x10,%esp
f0100e21:	eb 95                	jmp    f0100db8 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f0100e23:	8d 7e 01             	lea    0x1(%esi),%edi
f0100e26:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100e2a:	eb 03                	jmp    f0100e2f <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100e2c:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100e2f:	0f b6 03             	movzbl (%ebx),%eax
f0100e32:	84 c0                	test   %al,%al
f0100e34:	74 ae                	je     f0100de4 <monitor+0x62>
f0100e36:	83 ec 08             	sub    $0x8,%esp
f0100e39:	0f be c0             	movsbl %al,%eax
f0100e3c:	50                   	push   %eax
f0100e3d:	68 21 70 10 f0       	push   $0xf0107021
f0100e42:	e8 32 51 00 00       	call   f0105f79 <strchr>
f0100e47:	83 c4 10             	add    $0x10,%esp
f0100e4a:	85 c0                	test   %eax,%eax
f0100e4c:	74 de                	je     f0100e2c <monitor+0xaa>
f0100e4e:	eb 94                	jmp    f0100de4 <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f0100e50:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100e57:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100e58:	85 f6                	test   %esi,%esi
f0100e5a:	0f 84 58 ff ff ff    	je     f0100db8 <monitor+0x36>
f0100e60:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100e65:	83 ec 08             	sub    $0x8,%esp
f0100e68:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100e6b:	ff 34 85 a0 73 10 f0 	pushl  -0xfef8c60(,%eax,4)
f0100e72:	ff 75 a8             	pushl  -0x58(%ebp)
f0100e75:	e8 a1 50 00 00       	call   f0105f1b <strcmp>
f0100e7a:	83 c4 10             	add    $0x10,%esp
f0100e7d:	85 c0                	test   %eax,%eax
f0100e7f:	75 21                	jne    f0100ea2 <monitor+0x120>
			return commands[i].func(argc, argv, tf);
f0100e81:	83 ec 04             	sub    $0x4,%esp
f0100e84:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100e87:	ff 75 08             	pushl  0x8(%ebp)
f0100e8a:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100e8d:	52                   	push   %edx
f0100e8e:	56                   	push   %esi
f0100e8f:	ff 14 85 a8 73 10 f0 	call   *-0xfef8c58(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100e96:	83 c4 10             	add    $0x10,%esp
f0100e99:	85 c0                	test   %eax,%eax
f0100e9b:	78 25                	js     f0100ec2 <monitor+0x140>
f0100e9d:	e9 16 ff ff ff       	jmp    f0100db8 <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100ea2:	83 c3 01             	add    $0x1,%ebx
f0100ea5:	83 fb 07             	cmp    $0x7,%ebx
f0100ea8:	75 bb                	jne    f0100e65 <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100eaa:	83 ec 08             	sub    $0x8,%esp
f0100ead:	ff 75 a8             	pushl  -0x58(%ebp)
f0100eb0:	68 43 70 10 f0       	push   $0xf0107043
f0100eb5:	e8 a4 2c 00 00       	call   f0103b5e <cprintf>
f0100eba:	83 c4 10             	add    $0x10,%esp
f0100ebd:	e9 f6 fe ff ff       	jmp    f0100db8 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100ec2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ec5:	5b                   	pop    %ebx
f0100ec6:	5e                   	pop    %esi
f0100ec7:	5f                   	pop    %edi
f0100ec8:	5d                   	pop    %ebp
f0100ec9:	c3                   	ret    

f0100eca <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100eca:	89 d1                	mov    %edx,%ecx
f0100ecc:	c1 e9 16             	shr    $0x16,%ecx
f0100ecf:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100ed2:	a8 01                	test   $0x1,%al
f0100ed4:	74 52                	je     f0100f28 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100ed6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100edb:	89 c1                	mov    %eax,%ecx
f0100edd:	c1 e9 0c             	shr    $0xc,%ecx
f0100ee0:	3b 0d 88 1e 23 f0    	cmp    0xf0231e88,%ecx
f0100ee6:	72 1b                	jb     f0100f03 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100ee8:	55                   	push   %ebp
f0100ee9:	89 e5                	mov    %esp,%ebp
f0100eeb:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100eee:	50                   	push   %eax
f0100eef:	68 84 6c 10 f0       	push   $0xf0106c84
f0100ef4:	68 64 03 00 00       	push   $0x364
f0100ef9:	68 19 7d 10 f0       	push   $0xf0107d19
f0100efe:	e8 3d f1 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100f03:	c1 ea 0c             	shr    $0xc,%edx
f0100f06:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100f0c:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100f13:	89 c2                	mov    %eax,%edx
f0100f15:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100f18:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100f1d:	85 d2                	test   %edx,%edx
f0100f1f:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100f24:	0f 44 c2             	cmove  %edx,%eax
f0100f27:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100f28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100f2d:	c3                   	ret    

f0100f2e <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100f2e:	55                   	push   %ebp
f0100f2f:	89 e5                	mov    %esp,%ebp
f0100f31:	53                   	push   %ebx
f0100f32:	83 ec 04             	sub    $0x4,%esp
f0100f35:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100f37:	83 3d 38 12 23 f0 00 	cmpl   $0x0,0xf0231238
f0100f3e:	75 0f                	jne    f0100f4f <boot_alloc+0x21>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100f40:	b8 07 40 27 f0       	mov    $0xf0274007,%eax
f0100f45:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100f4a:	a3 38 12 23 f0       	mov    %eax,0xf0231238
	}

	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	result = KADDR(PADDR(nextfree));
f0100f4f:	a1 38 12 23 f0       	mov    0xf0231238,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100f54:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100f59:	77 12                	ja     f0100f6d <boot_alloc+0x3f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f5b:	50                   	push   %eax
f0100f5c:	68 a8 6c 10 f0       	push   $0xf0106ca8
f0100f61:	6a 66                	push   $0x66
f0100f63:	68 19 7d 10 f0       	push   $0xf0107d19
f0100f68:	e8 d3 f0 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100f6d:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f73:	89 cb                	mov    %ecx,%ebx
f0100f75:	c1 eb 0c             	shr    $0xc,%ebx
f0100f78:	39 1d 88 1e 23 f0    	cmp    %ebx,0xf0231e88
f0100f7e:	77 12                	ja     f0100f92 <boot_alloc+0x64>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f80:	51                   	push   %ecx
f0100f81:	68 84 6c 10 f0       	push   $0xf0106c84
f0100f86:	6a 66                	push   $0x66
f0100f88:	68 19 7d 10 f0       	push   $0xf0107d19
f0100f8d:	e8 ae f0 ff ff       	call   f0100040 <_panic>
	nextfree += ROUNDUP(n, PGSIZE);
f0100f92:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f0100f98:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100f9e:	01 c2                	add    %eax,%edx
f0100fa0:	89 15 38 12 23 f0    	mov    %edx,0xf0231238

	return result;
}
f0100fa6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100fa9:	c9                   	leave  
f0100faa:	c3                   	ret    

f0100fab <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100fab:	55                   	push   %ebp
f0100fac:	89 e5                	mov    %esp,%ebp
f0100fae:	57                   	push   %edi
f0100faf:	56                   	push   %esi
f0100fb0:	53                   	push   %ebx
f0100fb1:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100fb4:	84 c0                	test   %al,%al
f0100fb6:	0f 85 91 02 00 00    	jne    f010124d <check_page_free_list+0x2a2>
f0100fbc:	e9 9e 02 00 00       	jmp    f010125f <check_page_free_list+0x2b4>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100fc1:	83 ec 04             	sub    $0x4,%esp
f0100fc4:	68 f4 73 10 f0       	push   $0xf01073f4
f0100fc9:	68 99 02 00 00       	push   $0x299
f0100fce:	68 19 7d 10 f0       	push   $0xf0107d19
f0100fd3:	e8 68 f0 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100fd8:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100fdb:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100fde:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100fe1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100fe4:	89 c2                	mov    %eax,%edx
f0100fe6:	2b 15 90 1e 23 f0    	sub    0xf0231e90,%edx
f0100fec:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100ff2:	0f 95 c2             	setne  %dl
f0100ff5:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100ff8:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100ffc:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100ffe:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101002:	8b 00                	mov    (%eax),%eax
f0101004:	85 c0                	test   %eax,%eax
f0101006:	75 dc                	jne    f0100fe4 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0101008:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010100b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0101011:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101014:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101017:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101019:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010101c:	a3 40 12 23 f0       	mov    %eax,0xf0231240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101021:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101026:	8b 1d 40 12 23 f0    	mov    0xf0231240,%ebx
f010102c:	eb 53                	jmp    f0101081 <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010102e:	89 d8                	mov    %ebx,%eax
f0101030:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0101036:	c1 f8 03             	sar    $0x3,%eax
f0101039:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f010103c:	89 c2                	mov    %eax,%edx
f010103e:	c1 ea 16             	shr    $0x16,%edx
f0101041:	39 f2                	cmp    %esi,%edx
f0101043:	73 3a                	jae    f010107f <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101045:	89 c2                	mov    %eax,%edx
f0101047:	c1 ea 0c             	shr    $0xc,%edx
f010104a:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f0101050:	72 12                	jb     f0101064 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101052:	50                   	push   %eax
f0101053:	68 84 6c 10 f0       	push   $0xf0106c84
f0101058:	6a 58                	push   $0x58
f010105a:	68 25 7d 10 f0       	push   $0xf0107d25
f010105f:	e8 dc ef ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0101064:	83 ec 04             	sub    $0x4,%esp
f0101067:	68 80 00 00 00       	push   $0x80
f010106c:	68 97 00 00 00       	push   $0x97
f0101071:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101076:	50                   	push   %eax
f0101077:	e8 3a 4f 00 00       	call   f0105fb6 <memset>
f010107c:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010107f:	8b 1b                	mov    (%ebx),%ebx
f0101081:	85 db                	test   %ebx,%ebx
f0101083:	75 a9                	jne    f010102e <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0101085:	b8 00 00 00 00       	mov    $0x0,%eax
f010108a:	e8 9f fe ff ff       	call   f0100f2e <boot_alloc>
f010108f:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101092:	8b 15 40 12 23 f0    	mov    0xf0231240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101098:	8b 0d 90 1e 23 f0    	mov    0xf0231e90,%ecx
		assert(pp < pages + npages);
f010109e:	a1 88 1e 23 f0       	mov    0xf0231e88,%eax
f01010a3:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01010a6:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f01010a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01010ac:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f01010af:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01010b4:	e9 52 01 00 00       	jmp    f010120b <check_page_free_list+0x260>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f01010b9:	39 ca                	cmp    %ecx,%edx
f01010bb:	73 19                	jae    f01010d6 <check_page_free_list+0x12b>
f01010bd:	68 33 7d 10 f0       	push   $0xf0107d33
f01010c2:	68 3f 7d 10 f0       	push   $0xf0107d3f
f01010c7:	68 b3 02 00 00       	push   $0x2b3
f01010cc:	68 19 7d 10 f0       	push   $0xf0107d19
f01010d1:	e8 6a ef ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f01010d6:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f01010d9:	72 19                	jb     f01010f4 <check_page_free_list+0x149>
f01010db:	68 54 7d 10 f0       	push   $0xf0107d54
f01010e0:	68 3f 7d 10 f0       	push   $0xf0107d3f
f01010e5:	68 b4 02 00 00       	push   $0x2b4
f01010ea:	68 19 7d 10 f0       	push   $0xf0107d19
f01010ef:	e8 4c ef ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01010f4:	89 d0                	mov    %edx,%eax
f01010f6:	2b 45 d0             	sub    -0x30(%ebp),%eax
f01010f9:	a8 07                	test   $0x7,%al
f01010fb:	74 19                	je     f0101116 <check_page_free_list+0x16b>
f01010fd:	68 18 74 10 f0       	push   $0xf0107418
f0101102:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0101107:	68 b5 02 00 00       	push   $0x2b5
f010110c:	68 19 7d 10 f0       	push   $0xf0107d19
f0101111:	e8 2a ef ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101116:	c1 f8 03             	sar    $0x3,%eax
f0101119:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f010111c:	85 c0                	test   %eax,%eax
f010111e:	75 19                	jne    f0101139 <check_page_free_list+0x18e>
f0101120:	68 68 7d 10 f0       	push   $0xf0107d68
f0101125:	68 3f 7d 10 f0       	push   $0xf0107d3f
f010112a:	68 b8 02 00 00       	push   $0x2b8
f010112f:	68 19 7d 10 f0       	push   $0xf0107d19
f0101134:	e8 07 ef ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0101139:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f010113e:	75 19                	jne    f0101159 <check_page_free_list+0x1ae>
f0101140:	68 79 7d 10 f0       	push   $0xf0107d79
f0101145:	68 3f 7d 10 f0       	push   $0xf0107d3f
f010114a:	68 b9 02 00 00       	push   $0x2b9
f010114f:	68 19 7d 10 f0       	push   $0xf0107d19
f0101154:	e8 e7 ee ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101159:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f010115e:	75 19                	jne    f0101179 <check_page_free_list+0x1ce>
f0101160:	68 4c 74 10 f0       	push   $0xf010744c
f0101165:	68 3f 7d 10 f0       	push   $0xf0107d3f
f010116a:	68 ba 02 00 00       	push   $0x2ba
f010116f:	68 19 7d 10 f0       	push   $0xf0107d19
f0101174:	e8 c7 ee ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101179:	3d 00 00 10 00       	cmp    $0x100000,%eax
f010117e:	75 19                	jne    f0101199 <check_page_free_list+0x1ee>
f0101180:	68 92 7d 10 f0       	push   $0xf0107d92
f0101185:	68 3f 7d 10 f0       	push   $0xf0107d3f
f010118a:	68 bb 02 00 00       	push   $0x2bb
f010118f:	68 19 7d 10 f0       	push   $0xf0107d19
f0101194:	e8 a7 ee ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101199:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f010119e:	0f 86 de 00 00 00    	jbe    f0101282 <check_page_free_list+0x2d7>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011a4:	89 c7                	mov    %eax,%edi
f01011a6:	c1 ef 0c             	shr    $0xc,%edi
f01011a9:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f01011ac:	77 12                	ja     f01011c0 <check_page_free_list+0x215>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011ae:	50                   	push   %eax
f01011af:	68 84 6c 10 f0       	push   $0xf0106c84
f01011b4:	6a 58                	push   $0x58
f01011b6:	68 25 7d 10 f0       	push   $0xf0107d25
f01011bb:	e8 80 ee ff ff       	call   f0100040 <_panic>
f01011c0:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f01011c6:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f01011c9:	0f 86 a7 00 00 00    	jbe    f0101276 <check_page_free_list+0x2cb>
f01011cf:	68 70 74 10 f0       	push   $0xf0107470
f01011d4:	68 3f 7d 10 f0       	push   $0xf0107d3f
f01011d9:	68 bc 02 00 00       	push   $0x2bc
f01011de:	68 19 7d 10 f0       	push   $0xf0107d19
f01011e3:	e8 58 ee ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f01011e8:	68 ac 7d 10 f0       	push   $0xf0107dac
f01011ed:	68 3f 7d 10 f0       	push   $0xf0107d3f
f01011f2:	68 be 02 00 00       	push   $0x2be
f01011f7:	68 19 7d 10 f0       	push   $0xf0107d19
f01011fc:	e8 3f ee ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0101201:	83 c6 01             	add    $0x1,%esi
f0101204:	eb 03                	jmp    f0101209 <check_page_free_list+0x25e>
		else
			++nfree_extmem;
f0101206:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101209:	8b 12                	mov    (%edx),%edx
f010120b:	85 d2                	test   %edx,%edx
f010120d:	0f 85 a6 fe ff ff    	jne    f01010b9 <check_page_free_list+0x10e>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0101213:	85 f6                	test   %esi,%esi
f0101215:	7f 19                	jg     f0101230 <check_page_free_list+0x285>
f0101217:	68 c9 7d 10 f0       	push   $0xf0107dc9
f010121c:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0101221:	68 c6 02 00 00       	push   $0x2c6
f0101226:	68 19 7d 10 f0       	push   $0xf0107d19
f010122b:	e8 10 ee ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0101230:	85 db                	test   %ebx,%ebx
f0101232:	7f 5e                	jg     f0101292 <check_page_free_list+0x2e7>
f0101234:	68 db 7d 10 f0       	push   $0xf0107ddb
f0101239:	68 3f 7d 10 f0       	push   $0xf0107d3f
f010123e:	68 c7 02 00 00       	push   $0x2c7
f0101243:	68 19 7d 10 f0       	push   $0xf0107d19
f0101248:	e8 f3 ed ff ff       	call   f0100040 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f010124d:	a1 40 12 23 f0       	mov    0xf0231240,%eax
f0101252:	85 c0                	test   %eax,%eax
f0101254:	0f 85 7e fd ff ff    	jne    f0100fd8 <check_page_free_list+0x2d>
f010125a:	e9 62 fd ff ff       	jmp    f0100fc1 <check_page_free_list+0x16>
f010125f:	83 3d 40 12 23 f0 00 	cmpl   $0x0,0xf0231240
f0101266:	0f 84 55 fd ff ff    	je     f0100fc1 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010126c:	be 00 04 00 00       	mov    $0x400,%esi
f0101271:	e9 b0 fd ff ff       	jmp    f0101026 <check_page_free_list+0x7b>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0101276:	3d 00 70 00 00       	cmp    $0x7000,%eax
f010127b:	75 89                	jne    f0101206 <check_page_free_list+0x25b>
f010127d:	e9 66 ff ff ff       	jmp    f01011e8 <check_page_free_list+0x23d>
f0101282:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101287:	0f 85 74 ff ff ff    	jne    f0101201 <check_page_free_list+0x256>
f010128d:	e9 56 ff ff ff       	jmp    f01011e8 <check_page_free_list+0x23d>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0101292:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101295:	5b                   	pop    %ebx
f0101296:	5e                   	pop    %esi
f0101297:	5f                   	pop    %edi
f0101298:	5d                   	pop    %ebp
f0101299:	c3                   	ret    

f010129a <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f010129a:	55                   	push   %ebp
f010129b:	89 e5                	mov    %esp,%ebp
f010129d:	57                   	push   %edi
f010129e:	56                   	push   %esi
f010129f:	53                   	push   %ebx
f01012a0:	83 ec 0c             	sub    $0xc,%esp
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	size_t pgnum = PGNUM(PADDR(boot_alloc(0)));
f01012a3:	b8 00 00 00 00       	mov    $0x0,%eax
f01012a8:	e8 81 fc ff ff       	call   f0100f2e <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01012ad:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01012b2:	77 15                	ja     f01012c9 <page_init+0x2f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01012b4:	50                   	push   %eax
f01012b5:	68 a8 6c 10 f0       	push   $0xf0106ca8
f01012ba:	68 36 01 00 00       	push   $0x136
f01012bf:	68 19 7d 10 f0       	push   $0xf0107d19
f01012c4:	e8 77 ed ff ff       	call   f0100040 <_panic>
f01012c9:	05 00 00 00 10       	add    $0x10000000,%eax
f01012ce:	c1 e8 0c             	shr    $0xc,%eax
	for (i = 1; i < npages; i++) {
		if ((i >= npages_basemem && i < pgnum) || (i == PGNUM(MPENTRY_PADDR)))
f01012d1:	8b 3d 44 12 23 f0    	mov    0xf0231244,%edi
f01012d7:	8b 35 40 12 23 f0    	mov    0xf0231240,%esi
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	size_t pgnum = PGNUM(PADDR(boot_alloc(0)));
	for (i = 1; i < npages; i++) {
f01012dd:	b9 00 00 00 00       	mov    $0x0,%ecx
f01012e2:	ba 01 00 00 00       	mov    $0x1,%edx
f01012e7:	eb 34                	jmp    f010131d <page_init+0x83>
		if ((i >= npages_basemem && i < pgnum) || (i == PGNUM(MPENTRY_PADDR)))
f01012e9:	39 c2                	cmp    %eax,%edx
f01012eb:	73 04                	jae    f01012f1 <page_init+0x57>
f01012ed:	39 fa                	cmp    %edi,%edx
f01012ef:	73 29                	jae    f010131a <page_init+0x80>
f01012f1:	83 fa 07             	cmp    $0x7,%edx
f01012f4:	74 24                	je     f010131a <page_init+0x80>
			continue;
		pages[i].pp_ref = 0;
f01012f6:	8d 0c d5 00 00 00 00 	lea    0x0(,%edx,8),%ecx
f01012fd:	89 cb                	mov    %ecx,%ebx
f01012ff:	03 1d 90 1e 23 f0    	add    0xf0231e90,%ebx
f0101305:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
		pages[i].pp_link = page_free_list;
f010130b:	89 33                	mov    %esi,(%ebx)
		page_free_list = &pages[i];
f010130d:	89 ce                	mov    %ecx,%esi
f010130f:	03 35 90 1e 23 f0    	add    0xf0231e90,%esi
f0101315:	b9 01 00 00 00       	mov    $0x1,%ecx
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	size_t pgnum = PGNUM(PADDR(boot_alloc(0)));
	for (i = 1; i < npages; i++) {
f010131a:	83 c2 01             	add    $0x1,%edx
f010131d:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f0101323:	72 c4                	jb     f01012e9 <page_init+0x4f>
f0101325:	84 c9                	test   %cl,%cl
f0101327:	74 06                	je     f010132f <page_init+0x95>
f0101329:	89 35 40 12 23 f0    	mov    %esi,0xf0231240
			continue;
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f010132f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101332:	5b                   	pop    %ebx
f0101333:	5e                   	pop    %esi
f0101334:	5f                   	pop    %edi
f0101335:	5d                   	pop    %ebp
f0101336:	c3                   	ret    

f0101337 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0101337:	55                   	push   %ebp
f0101338:	89 e5                	mov    %esp,%ebp
f010133a:	53                   	push   %ebx
f010133b:	83 ec 04             	sub    $0x4,%esp
	struct PageInfo *result = NULL;
	if (page_free_list) {
f010133e:	8b 1d 40 12 23 f0    	mov    0xf0231240,%ebx
f0101344:	85 db                	test   %ebx,%ebx
f0101346:	74 58                	je     f01013a0 <page_alloc+0x69>
		result = page_free_list;
		page_free_list = page_free_list->pp_link;
f0101348:	8b 03                	mov    (%ebx),%eax
f010134a:	a3 40 12 23 f0       	mov    %eax,0xf0231240
		result->pp_link = NULL;
f010134f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (alloc_flags & ALLOC_ZERO)
f0101355:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101359:	74 45                	je     f01013a0 <page_alloc+0x69>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010135b:	89 d8                	mov    %ebx,%eax
f010135d:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0101363:	c1 f8 03             	sar    $0x3,%eax
f0101366:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101369:	89 c2                	mov    %eax,%edx
f010136b:	c1 ea 0c             	shr    $0xc,%edx
f010136e:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f0101374:	72 12                	jb     f0101388 <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101376:	50                   	push   %eax
f0101377:	68 84 6c 10 f0       	push   $0xf0106c84
f010137c:	6a 58                	push   $0x58
f010137e:	68 25 7d 10 f0       	push   $0xf0107d25
f0101383:	e8 b8 ec ff ff       	call   f0100040 <_panic>
			memset(page2kva(result), 0, PGSIZE);
f0101388:	83 ec 04             	sub    $0x4,%esp
f010138b:	68 00 10 00 00       	push   $0x1000
f0101390:	6a 00                	push   $0x0
f0101392:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101397:	50                   	push   %eax
f0101398:	e8 19 4c 00 00       	call   f0105fb6 <memset>
f010139d:	83 c4 10             	add    $0x10,%esp
	}
	return result;
}
f01013a0:	89 d8                	mov    %ebx,%eax
f01013a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01013a5:	c9                   	leave  
f01013a6:	c3                   	ret    

f01013a7 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f01013a7:	55                   	push   %ebp
f01013a8:	89 e5                	mov    %esp,%ebp
f01013aa:	83 ec 08             	sub    $0x8,%esp
f01013ad:	8b 45 08             	mov    0x8(%ebp),%eax
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	assert(pp != NULL);
f01013b0:	85 c0                	test   %eax,%eax
f01013b2:	75 19                	jne    f01013cd <page_free+0x26>
f01013b4:	68 ec 7d 10 f0       	push   $0xf0107dec
f01013b9:	68 3f 7d 10 f0       	push   $0xf0107d3f
f01013be:	68 63 01 00 00       	push   $0x163
f01013c3:	68 19 7d 10 f0       	push   $0xf0107d19
f01013c8:	e8 73 ec ff ff       	call   f0100040 <_panic>
	assert(pp->pp_ref == 0);
f01013cd:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01013d2:	74 19                	je     f01013ed <page_free+0x46>
f01013d4:	68 f7 7d 10 f0       	push   $0xf0107df7
f01013d9:	68 3f 7d 10 f0       	push   $0xf0107d3f
f01013de:	68 64 01 00 00       	push   $0x164
f01013e3:	68 19 7d 10 f0       	push   $0xf0107d19
f01013e8:	e8 53 ec ff ff       	call   f0100040 <_panic>
	assert(pp->pp_link == NULL);
f01013ed:	83 38 00             	cmpl   $0x0,(%eax)
f01013f0:	74 19                	je     f010140b <page_free+0x64>
f01013f2:	68 07 7e 10 f0       	push   $0xf0107e07
f01013f7:	68 3f 7d 10 f0       	push   $0xf0107d3f
f01013fc:	68 65 01 00 00       	push   $0x165
f0101401:	68 19 7d 10 f0       	push   $0xf0107d19
f0101406:	e8 35 ec ff ff       	call   f0100040 <_panic>

	pp->pp_link = page_free_list;
f010140b:	8b 15 40 12 23 f0    	mov    0xf0231240,%edx
f0101411:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101413:	a3 40 12 23 f0       	mov    %eax,0xf0231240
}
f0101418:	c9                   	leave  
f0101419:	c3                   	ret    

f010141a <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f010141a:	55                   	push   %ebp
f010141b:	89 e5                	mov    %esp,%ebp
f010141d:	83 ec 08             	sub    $0x8,%esp
f0101420:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101423:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101427:	83 e8 01             	sub    $0x1,%eax
f010142a:	66 89 42 04          	mov    %ax,0x4(%edx)
f010142e:	66 85 c0             	test   %ax,%ax
f0101431:	75 0c                	jne    f010143f <page_decref+0x25>
		page_free(pp);
f0101433:	83 ec 0c             	sub    $0xc,%esp
f0101436:	52                   	push   %edx
f0101437:	e8 6b ff ff ff       	call   f01013a7 <page_free>
f010143c:	83 c4 10             	add    $0x10,%esp
}
f010143f:	c9                   	leave  
f0101440:	c3                   	ret    

f0101441 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101441:	55                   	push   %ebp
f0101442:	89 e5                	mov    %esp,%ebp
f0101444:	56                   	push   %esi
f0101445:	53                   	push   %ebx
f0101446:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	size_t pdx = PDX(va), ptx = PTX(va);
f0101449:	89 de                	mov    %ebx,%esi
f010144b:	c1 ee 0c             	shr    $0xc,%esi
f010144e:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	struct PageInfo *pp = NULL;
	pte_t *pgtbl = NULL;

	if (!(pgdir[pdx] & PTE_P)) {
f0101454:	c1 eb 16             	shr    $0x16,%ebx
f0101457:	c1 e3 02             	shl    $0x2,%ebx
f010145a:	03 5d 08             	add    0x8(%ebp),%ebx
f010145d:	f6 03 01             	testb  $0x1,(%ebx)
f0101460:	75 2d                	jne    f010148f <pgdir_walk+0x4e>
		if (!create) return NULL;
f0101462:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101466:	74 59                	je     f01014c1 <pgdir_walk+0x80>
		pp = page_alloc(ALLOC_ZERO);
f0101468:	83 ec 0c             	sub    $0xc,%esp
f010146b:	6a 01                	push   $0x1
f010146d:	e8 c5 fe ff ff       	call   f0101337 <page_alloc>
		if (pp == NULL) return NULL;
f0101472:	83 c4 10             	add    $0x10,%esp
f0101475:	85 c0                	test   %eax,%eax
f0101477:	74 4f                	je     f01014c8 <pgdir_walk+0x87>
		pp->pp_ref++;
f0101479:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
		
		pgdir[pdx] = page2pa(pp) | PTE_W | PTE_U | PTE_P; 
f010147e:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0101484:	c1 f8 03             	sar    $0x3,%eax
f0101487:	c1 e0 0c             	shl    $0xc,%eax
f010148a:	83 c8 07             	or     $0x7,%eax
f010148d:	89 03                	mov    %eax,(%ebx)
	} 
	pgtbl = (pte_t *) KADDR(PTE_ADDR(pgdir[pdx]));
f010148f:	8b 03                	mov    (%ebx),%eax
f0101491:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101496:	89 c2                	mov    %eax,%edx
f0101498:	c1 ea 0c             	shr    $0xc,%edx
f010149b:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f01014a1:	72 15                	jb     f01014b8 <pgdir_walk+0x77>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01014a3:	50                   	push   %eax
f01014a4:	68 84 6c 10 f0       	push   $0xf0106c84
f01014a9:	68 9b 01 00 00       	push   $0x19b
f01014ae:	68 19 7d 10 f0       	push   $0xf0107d19
f01014b3:	e8 88 eb ff ff       	call   f0100040 <_panic>
	return &pgtbl[ptx];
f01014b8:	8d 84 b0 00 00 00 f0 	lea    -0x10000000(%eax,%esi,4),%eax
f01014bf:	eb 0c                	jmp    f01014cd <pgdir_walk+0x8c>
	size_t pdx = PDX(va), ptx = PTX(va);
	struct PageInfo *pp = NULL;
	pte_t *pgtbl = NULL;

	if (!(pgdir[pdx] & PTE_P)) {
		if (!create) return NULL;
f01014c1:	b8 00 00 00 00       	mov    $0x0,%eax
f01014c6:	eb 05                	jmp    f01014cd <pgdir_walk+0x8c>
		pp = page_alloc(ALLOC_ZERO);
		if (pp == NULL) return NULL;
f01014c8:	b8 00 00 00 00       	mov    $0x0,%eax
		
		pgdir[pdx] = page2pa(pp) | PTE_W | PTE_U | PTE_P; 
	} 
	pgtbl = (pte_t *) KADDR(PTE_ADDR(pgdir[pdx]));
	return &pgtbl[ptx];
}
f01014cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01014d0:	5b                   	pop    %ebx
f01014d1:	5e                   	pop    %esi
f01014d2:	5d                   	pop    %ebp
f01014d3:	c3                   	ret    

f01014d4 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01014d4:	55                   	push   %ebp
f01014d5:	89 e5                	mov    %esp,%ebp
f01014d7:	57                   	push   %edi
f01014d8:	56                   	push   %esi
f01014d9:	53                   	push   %ebx
f01014da:	83 ec 1c             	sub    $0x1c,%esp
f01014dd:	89 c7                	mov    %eax,%edi
f01014df:	89 d6                	mov    %edx,%esi
f01014e1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	size_t i;
	for (i = 0; i < size; i += PGSIZE) {
f01014e4:	bb 00 00 00 00       	mov    $0x0,%ebx
		pte_t *pte = pgdir_walk(pgdir, (void *)(va + i), 1);
		*pte = (pa + i) | perm | PTE_P;
f01014e9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01014ec:	83 c8 01             	or     $0x1,%eax
f01014ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	size_t i;
	for (i = 0; i < size; i += PGSIZE) {
f01014f2:	eb 22                	jmp    f0101516 <boot_map_region+0x42>
		pte_t *pte = pgdir_walk(pgdir, (void *)(va + i), 1);
f01014f4:	83 ec 04             	sub    $0x4,%esp
f01014f7:	6a 01                	push   $0x1
f01014f9:	8d 04 33             	lea    (%ebx,%esi,1),%eax
f01014fc:	50                   	push   %eax
f01014fd:	57                   	push   %edi
f01014fe:	e8 3e ff ff ff       	call   f0101441 <pgdir_walk>
		*pte = (pa + i) | perm | PTE_P;
f0101503:	89 da                	mov    %ebx,%edx
f0101505:	03 55 08             	add    0x8(%ebp),%edx
f0101508:	0b 55 e0             	or     -0x20(%ebp),%edx
f010150b:	89 10                	mov    %edx,(%eax)
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	size_t i;
	for (i = 0; i < size; i += PGSIZE) {
f010150d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101513:	83 c4 10             	add    $0x10,%esp
f0101516:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0101519:	72 d9                	jb     f01014f4 <boot_map_region+0x20>
		pte_t *pte = pgdir_walk(pgdir, (void *)(va + i), 1);
		*pte = (pa + i) | perm | PTE_P;
	}
}
f010151b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010151e:	5b                   	pop    %ebx
f010151f:	5e                   	pop    %esi
f0101520:	5f                   	pop    %edi
f0101521:	5d                   	pop    %ebp
f0101522:	c3                   	ret    

f0101523 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101523:	55                   	push   %ebp
f0101524:	89 e5                	mov    %esp,%ebp
f0101526:	53                   	push   %ebx
f0101527:	83 ec 08             	sub    $0x8,%esp
f010152a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *pte = pgdir_walk(pgdir, va, 0);
f010152d:	6a 00                	push   $0x0
f010152f:	ff 75 0c             	pushl  0xc(%ebp)
f0101532:	ff 75 08             	pushl  0x8(%ebp)
f0101535:	e8 07 ff ff ff       	call   f0101441 <pgdir_walk>
	if (pte_store)
f010153a:	83 c4 10             	add    $0x10,%esp
f010153d:	85 db                	test   %ebx,%ebx
f010153f:	74 02                	je     f0101543 <page_lookup+0x20>
		*pte_store = pte;
f0101541:	89 03                	mov    %eax,(%ebx)
	if (pte == NULL || !(*pte & PTE_P)) return NULL;
f0101543:	85 c0                	test   %eax,%eax
f0101545:	74 30                	je     f0101577 <page_lookup+0x54>
f0101547:	8b 00                	mov    (%eax),%eax
f0101549:	a8 01                	test   $0x1,%al
f010154b:	74 31                	je     f010157e <page_lookup+0x5b>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010154d:	c1 e8 0c             	shr    $0xc,%eax
f0101550:	3b 05 88 1e 23 f0    	cmp    0xf0231e88,%eax
f0101556:	72 14                	jb     f010156c <page_lookup+0x49>
		panic("pa2page called with invalid pa");
f0101558:	83 ec 04             	sub    $0x4,%esp
f010155b:	68 b8 74 10 f0       	push   $0xf01074b8
f0101560:	6a 51                	push   $0x51
f0101562:	68 25 7d 10 f0       	push   $0xf0107d25
f0101567:	e8 d4 ea ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f010156c:	8b 15 90 1e 23 f0    	mov    0xf0231e90,%edx
f0101572:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	return pa2page(PTE_ADDR(*pte));
f0101575:	eb 0c                	jmp    f0101583 <page_lookup+0x60>
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	pte_t *pte = pgdir_walk(pgdir, va, 0);
	if (pte_store)
		*pte_store = pte;
	if (pte == NULL || !(*pte & PTE_P)) return NULL;
f0101577:	b8 00 00 00 00       	mov    $0x0,%eax
f010157c:	eb 05                	jmp    f0101583 <page_lookup+0x60>
f010157e:	b8 00 00 00 00       	mov    $0x0,%eax
	return pa2page(PTE_ADDR(*pte));
}
f0101583:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101586:	c9                   	leave  
f0101587:	c3                   	ret    

f0101588 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101588:	55                   	push   %ebp
f0101589:	89 e5                	mov    %esp,%ebp
f010158b:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f010158e:	e8 43 50 00 00       	call   f01065d6 <cpunum>
f0101593:	6b c0 74             	imul   $0x74,%eax,%eax
f0101596:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f010159d:	74 16                	je     f01015b5 <tlb_invalidate+0x2d>
f010159f:	e8 32 50 00 00       	call   f01065d6 <cpunum>
f01015a4:	6b c0 74             	imul   $0x74,%eax,%eax
f01015a7:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f01015ad:	8b 55 08             	mov    0x8(%ebp),%edx
f01015b0:	39 50 60             	cmp    %edx,0x60(%eax)
f01015b3:	75 06                	jne    f01015bb <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01015b5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01015b8:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f01015bb:	c9                   	leave  
f01015bc:	c3                   	ret    

f01015bd <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01015bd:	55                   	push   %ebp
f01015be:	89 e5                	mov    %esp,%ebp
f01015c0:	57                   	push   %edi
f01015c1:	56                   	push   %esi
f01015c2:	53                   	push   %ebx
f01015c3:	83 ec 20             	sub    $0x20,%esp
f01015c6:	8b 75 08             	mov    0x8(%ebp),%esi
f01015c9:	8b 7d 0c             	mov    0xc(%ebp),%edi
	pte_t *pte = NULL;
f01015cc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	struct PageInfo *pp = page_lookup(pgdir, va, &pte);
f01015d3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01015d6:	50                   	push   %eax
f01015d7:	57                   	push   %edi
f01015d8:	56                   	push   %esi
f01015d9:	e8 45 ff ff ff       	call   f0101523 <page_lookup>
	if (pp == NULL) return;
f01015de:	83 c4 10             	add    $0x10,%esp
f01015e1:	85 c0                	test   %eax,%eax
f01015e3:	74 20                	je     f0101605 <page_remove+0x48>
f01015e5:	89 c3                	mov    %eax,%ebx

	*pte = (pte_t) 0;
f01015e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01015ea:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir, va);
f01015f0:	83 ec 08             	sub    $0x8,%esp
f01015f3:	57                   	push   %edi
f01015f4:	56                   	push   %esi
f01015f5:	e8 8e ff ff ff       	call   f0101588 <tlb_invalidate>
	page_decref(pp);
f01015fa:	89 1c 24             	mov    %ebx,(%esp)
f01015fd:	e8 18 fe ff ff       	call   f010141a <page_decref>
f0101602:	83 c4 10             	add    $0x10,%esp
}
f0101605:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101608:	5b                   	pop    %ebx
f0101609:	5e                   	pop    %esi
f010160a:	5f                   	pop    %edi
f010160b:	5d                   	pop    %ebp
f010160c:	c3                   	ret    

f010160d <page_insert>:
//
// Ref: https://github.com/Clann24/jos/blob/master/lab2/README.md
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010160d:	55                   	push   %ebp
f010160e:	89 e5                	mov    %esp,%ebp
f0101610:	57                   	push   %edi
f0101611:	56                   	push   %esi
f0101612:	53                   	push   %ebx
f0101613:	83 ec 10             	sub    $0x10,%esp
f0101616:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101619:	8b 7d 10             	mov    0x10(%ebp),%edi
        pte_t *pte = pgdir_walk(pgdir, va, 1);
f010161c:	6a 01                	push   $0x1
f010161e:	57                   	push   %edi
f010161f:	ff 75 08             	pushl  0x8(%ebp)
f0101622:	e8 1a fe ff ff       	call   f0101441 <pgdir_walk>
        if (pte == NULL)  return -E_NO_MEM;
f0101627:	83 c4 10             	add    $0x10,%esp
f010162a:	85 c0                	test   %eax,%eax
f010162c:	74 38                	je     f0101666 <page_insert+0x59>
f010162e:	89 c6                	mov    %eax,%esi

        pp->pp_ref++;
f0101630:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
        if (*pte & PTE_P)
f0101635:	f6 00 01             	testb  $0x1,(%eax)
f0101638:	74 0f                	je     f0101649 <page_insert+0x3c>
                page_remove(pgdir, va);
f010163a:	83 ec 08             	sub    $0x8,%esp
f010163d:	57                   	push   %edi
f010163e:	ff 75 08             	pushl  0x8(%ebp)
f0101641:	e8 77 ff ff ff       	call   f01015bd <page_remove>
f0101646:	83 c4 10             	add    $0x10,%esp
        *pte = page2pa(pp) | perm | PTE_P;
f0101649:	2b 1d 90 1e 23 f0    	sub    0xf0231e90,%ebx
f010164f:	c1 fb 03             	sar    $0x3,%ebx
f0101652:	c1 e3 0c             	shl    $0xc,%ebx
f0101655:	8b 45 14             	mov    0x14(%ebp),%eax
f0101658:	83 c8 01             	or     $0x1,%eax
f010165b:	09 c3                	or     %eax,%ebx
f010165d:	89 1e                	mov    %ebx,(%esi)

        return 0;
f010165f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101664:	eb 05                	jmp    f010166b <page_insert+0x5e>
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
        pte_t *pte = pgdir_walk(pgdir, va, 1);
        if (pte == NULL)  return -E_NO_MEM;
f0101666:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
        if (*pte & PTE_P)
                page_remove(pgdir, va);
        *pte = page2pa(pp) | perm | PTE_P;

        return 0;
}
f010166b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010166e:	5b                   	pop    %ebx
f010166f:	5e                   	pop    %esi
f0101670:	5f                   	pop    %edi
f0101671:	5d                   	pop    %ebp
f0101672:	c3                   	ret    

f0101673 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101673:	55                   	push   %ebp
f0101674:	89 e5                	mov    %esp,%ebp
f0101676:	53                   	push   %ebx
f0101677:	83 ec 04             	sub    $0x4,%esp
	// Be sure to round size up to a multiple of PGSIZE and to
	// handle if this reservation would overflow MMIOLIM (it's
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	uintptr_t va_start = base, va_end;
f010167a:	8b 1d 00 23 12 f0    	mov    0xf0122300,%ebx

	size = ROUNDUP(size, PGSIZE);
f0101680:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101683:	8d 88 ff 0f 00 00    	lea    0xfff(%eax),%ecx
f0101689:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	va_end = base + size;
f010168f:	8d 04 0b             	lea    (%ebx,%ecx,1),%eax

	if (!(va_end >= MMIOBASE && va_end <= MMIOLIM))
f0101692:	8d 90 00 00 80 10    	lea    0x10800000(%eax),%edx
f0101698:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
f010169e:	76 17                	jbe    f01016b7 <mmio_map_region+0x44>
		panic("mmio_map_region: MMIO space overflow");
f01016a0:	83 ec 04             	sub    $0x4,%esp
f01016a3:	68 d8 74 10 f0       	push   $0xf01074d8
f01016a8:	68 3d 02 00 00       	push   $0x23d
f01016ad:	68 19 7d 10 f0       	push   $0xf0107d19
f01016b2:	e8 89 e9 ff ff       	call   f0100040 <_panic>

	base = va_end;
f01016b7:	a3 00 23 12 f0       	mov    %eax,0xf0122300

	boot_map_region(kern_pgdir, va_start, size, pa, PTE_W | PTE_PCD | PTE_PWT);
f01016bc:	83 ec 08             	sub    $0x8,%esp
f01016bf:	6a 1a                	push   $0x1a
f01016c1:	ff 75 08             	pushl  0x8(%ebp)
f01016c4:	89 da                	mov    %ebx,%edx
f01016c6:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f01016cb:	e8 04 fe ff ff       	call   f01014d4 <boot_map_region>
	
	return (void *) va_start;
}
f01016d0:	89 d8                	mov    %ebx,%eax
f01016d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01016d5:	c9                   	leave  
f01016d6:	c3                   	ret    

f01016d7 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01016d7:	55                   	push   %ebp
f01016d8:	89 e5                	mov    %esp,%ebp
f01016da:	57                   	push   %edi
f01016db:	56                   	push   %esi
f01016dc:	53                   	push   %ebx
f01016dd:	83 ec 48             	sub    $0x48,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01016e0:	6a 15                	push   $0x15
f01016e2:	e8 f8 22 00 00       	call   f01039df <mc146818_read>
f01016e7:	89 c3                	mov    %eax,%ebx
f01016e9:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f01016f0:	e8 ea 22 00 00       	call   f01039df <mc146818_read>
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01016f5:	c1 e0 08             	shl    $0x8,%eax
f01016f8:	09 d8                	or     %ebx,%eax
f01016fa:	c1 e0 0a             	shl    $0xa,%eax
f01016fd:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101703:	85 c0                	test   %eax,%eax
f0101705:	0f 48 c2             	cmovs  %edx,%eax
f0101708:	c1 f8 0c             	sar    $0xc,%eax
f010170b:	a3 44 12 23 f0       	mov    %eax,0xf0231244
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101710:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0101717:	e8 c3 22 00 00       	call   f01039df <mc146818_read>
f010171c:	89 c3                	mov    %eax,%ebx
f010171e:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101725:	e8 b5 22 00 00       	call   f01039df <mc146818_read>
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f010172a:	c1 e0 08             	shl    $0x8,%eax
f010172d:	09 d8                	or     %ebx,%eax
f010172f:	c1 e0 0a             	shl    $0xa,%eax
f0101732:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101738:	83 c4 10             	add    $0x10,%esp
f010173b:	85 c0                	test   %eax,%eax
f010173d:	0f 48 c2             	cmovs  %edx,%eax
f0101740:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101743:	85 c0                	test   %eax,%eax
f0101745:	74 0e                	je     f0101755 <mem_init+0x7e>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101747:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f010174d:	89 15 88 1e 23 f0    	mov    %edx,0xf0231e88
f0101753:	eb 0c                	jmp    f0101761 <mem_init+0x8a>
	else
		npages = npages_basemem;
f0101755:	8b 15 44 12 23 f0    	mov    0xf0231244,%edx
f010175b:	89 15 88 1e 23 f0    	mov    %edx,0xf0231e88

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101761:	c1 e0 0c             	shl    $0xc,%eax
f0101764:	c1 e8 0a             	shr    $0xa,%eax
f0101767:	50                   	push   %eax
f0101768:	a1 44 12 23 f0       	mov    0xf0231244,%eax
f010176d:	c1 e0 0c             	shl    $0xc,%eax
f0101770:	c1 e8 0a             	shr    $0xa,%eax
f0101773:	50                   	push   %eax
f0101774:	a1 88 1e 23 f0       	mov    0xf0231e88,%eax
f0101779:	c1 e0 0c             	shl    $0xc,%eax
f010177c:	c1 e8 0a             	shr    $0xa,%eax
f010177f:	50                   	push   %eax
f0101780:	68 00 75 10 f0       	push   $0xf0107500
f0101785:	e8 d4 23 00 00       	call   f0103b5e <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010178a:	b8 00 10 00 00       	mov    $0x1000,%eax
f010178f:	e8 9a f7 ff ff       	call   f0100f2e <boot_alloc>
f0101794:	a3 8c 1e 23 f0       	mov    %eax,0xf0231e8c
	memset(kern_pgdir, 0, PGSIZE);
f0101799:	83 c4 0c             	add    $0xc,%esp
f010179c:	68 00 10 00 00       	push   $0x1000
f01017a1:	6a 00                	push   $0x0
f01017a3:	50                   	push   %eax
f01017a4:	e8 0d 48 00 00       	call   f0105fb6 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01017a9:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01017ae:	83 c4 10             	add    $0x10,%esp
f01017b1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01017b6:	77 15                	ja     f01017cd <mem_init+0xf6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01017b8:	50                   	push   %eax
f01017b9:	68 a8 6c 10 f0       	push   $0xf0106ca8
f01017be:	68 8d 00 00 00       	push   $0x8d
f01017c3:	68 19 7d 10 f0       	push   $0xf0107d19
f01017c8:	e8 73 e8 ff ff       	call   f0100040 <_panic>
f01017cd:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01017d3:	83 ca 05             	or     $0x5,%edx
f01017d6:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	n = npages * sizeof(struct PageInfo);
f01017dc:	a1 88 1e 23 f0       	mov    0xf0231e88,%eax
f01017e1:	8d 1c c5 00 00 00 00 	lea    0x0(,%eax,8),%ebx
	pages = (struct PageInfo *) boot_alloc(n);
f01017e8:	89 d8                	mov    %ebx,%eax
f01017ea:	e8 3f f7 ff ff       	call   f0100f2e <boot_alloc>
f01017ef:	a3 90 1e 23 f0       	mov    %eax,0xf0231e90
	memset(pages, 0, n);
f01017f4:	83 ec 04             	sub    $0x4,%esp
f01017f7:	53                   	push   %ebx
f01017f8:	6a 00                	push   $0x0
f01017fa:	50                   	push   %eax
f01017fb:	e8 b6 47 00 00       	call   f0105fb6 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	n = NENV * sizeof(struct Env);
	envs = (struct Env*) boot_alloc(n);
f0101800:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101805:	e8 24 f7 ff ff       	call   f0100f2e <boot_alloc>
f010180a:	a3 48 12 23 f0       	mov    %eax,0xf0231248
	memset(envs, 0, n);
f010180f:	83 c4 0c             	add    $0xc,%esp
f0101812:	68 00 f0 01 00       	push   $0x1f000
f0101817:	6a 00                	push   $0x0
f0101819:	50                   	push   %eax
f010181a:	e8 97 47 00 00       	call   f0105fb6 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010181f:	e8 76 fa ff ff       	call   f010129a <page_init>

	check_page_free_list(1);
f0101824:	b8 01 00 00 00       	mov    $0x1,%eax
f0101829:	e8 7d f7 ff ff       	call   f0100fab <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010182e:	83 c4 10             	add    $0x10,%esp
f0101831:	83 3d 90 1e 23 f0 00 	cmpl   $0x0,0xf0231e90
f0101838:	75 17                	jne    f0101851 <mem_init+0x17a>
		panic("'pages' is a null pointer!");
f010183a:	83 ec 04             	sub    $0x4,%esp
f010183d:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0101842:	68 d8 02 00 00       	push   $0x2d8
f0101847:	68 19 7d 10 f0       	push   $0xf0107d19
f010184c:	e8 ef e7 ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101851:	a1 40 12 23 f0       	mov    0xf0231240,%eax
f0101856:	bb 00 00 00 00       	mov    $0x0,%ebx
f010185b:	eb 05                	jmp    f0101862 <mem_init+0x18b>
		++nfree;
f010185d:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101860:	8b 00                	mov    (%eax),%eax
f0101862:	85 c0                	test   %eax,%eax
f0101864:	75 f7                	jne    f010185d <mem_init+0x186>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101866:	83 ec 0c             	sub    $0xc,%esp
f0101869:	6a 00                	push   $0x0
f010186b:	e8 c7 fa ff ff       	call   f0101337 <page_alloc>
f0101870:	89 c7                	mov    %eax,%edi
f0101872:	83 c4 10             	add    $0x10,%esp
f0101875:	85 c0                	test   %eax,%eax
f0101877:	75 19                	jne    f0101892 <mem_init+0x1bb>
f0101879:	68 36 7e 10 f0       	push   $0xf0107e36
f010187e:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0101883:	68 e0 02 00 00       	push   $0x2e0
f0101888:	68 19 7d 10 f0       	push   $0xf0107d19
f010188d:	e8 ae e7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101892:	83 ec 0c             	sub    $0xc,%esp
f0101895:	6a 00                	push   $0x0
f0101897:	e8 9b fa ff ff       	call   f0101337 <page_alloc>
f010189c:	89 c6                	mov    %eax,%esi
f010189e:	83 c4 10             	add    $0x10,%esp
f01018a1:	85 c0                	test   %eax,%eax
f01018a3:	75 19                	jne    f01018be <mem_init+0x1e7>
f01018a5:	68 4c 7e 10 f0       	push   $0xf0107e4c
f01018aa:	68 3f 7d 10 f0       	push   $0xf0107d3f
f01018af:	68 e1 02 00 00       	push   $0x2e1
f01018b4:	68 19 7d 10 f0       	push   $0xf0107d19
f01018b9:	e8 82 e7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01018be:	83 ec 0c             	sub    $0xc,%esp
f01018c1:	6a 00                	push   $0x0
f01018c3:	e8 6f fa ff ff       	call   f0101337 <page_alloc>
f01018c8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01018cb:	83 c4 10             	add    $0x10,%esp
f01018ce:	85 c0                	test   %eax,%eax
f01018d0:	75 19                	jne    f01018eb <mem_init+0x214>
f01018d2:	68 62 7e 10 f0       	push   $0xf0107e62
f01018d7:	68 3f 7d 10 f0       	push   $0xf0107d3f
f01018dc:	68 e2 02 00 00       	push   $0x2e2
f01018e1:	68 19 7d 10 f0       	push   $0xf0107d19
f01018e6:	e8 55 e7 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01018eb:	39 f7                	cmp    %esi,%edi
f01018ed:	75 19                	jne    f0101908 <mem_init+0x231>
f01018ef:	68 78 7e 10 f0       	push   $0xf0107e78
f01018f4:	68 3f 7d 10 f0       	push   $0xf0107d3f
f01018f9:	68 e5 02 00 00       	push   $0x2e5
f01018fe:	68 19 7d 10 f0       	push   $0xf0107d19
f0101903:	e8 38 e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101908:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010190b:	39 c6                	cmp    %eax,%esi
f010190d:	74 04                	je     f0101913 <mem_init+0x23c>
f010190f:	39 c7                	cmp    %eax,%edi
f0101911:	75 19                	jne    f010192c <mem_init+0x255>
f0101913:	68 3c 75 10 f0       	push   $0xf010753c
f0101918:	68 3f 7d 10 f0       	push   $0xf0107d3f
f010191d:	68 e6 02 00 00       	push   $0x2e6
f0101922:	68 19 7d 10 f0       	push   $0xf0107d19
f0101927:	e8 14 e7 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010192c:	8b 0d 90 1e 23 f0    	mov    0xf0231e90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101932:	8b 15 88 1e 23 f0    	mov    0xf0231e88,%edx
f0101938:	c1 e2 0c             	shl    $0xc,%edx
f010193b:	89 f8                	mov    %edi,%eax
f010193d:	29 c8                	sub    %ecx,%eax
f010193f:	c1 f8 03             	sar    $0x3,%eax
f0101942:	c1 e0 0c             	shl    $0xc,%eax
f0101945:	39 d0                	cmp    %edx,%eax
f0101947:	72 19                	jb     f0101962 <mem_init+0x28b>
f0101949:	68 8a 7e 10 f0       	push   $0xf0107e8a
f010194e:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0101953:	68 e7 02 00 00       	push   $0x2e7
f0101958:	68 19 7d 10 f0       	push   $0xf0107d19
f010195d:	e8 de e6 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101962:	89 f0                	mov    %esi,%eax
f0101964:	29 c8                	sub    %ecx,%eax
f0101966:	c1 f8 03             	sar    $0x3,%eax
f0101969:	c1 e0 0c             	shl    $0xc,%eax
f010196c:	39 c2                	cmp    %eax,%edx
f010196e:	77 19                	ja     f0101989 <mem_init+0x2b2>
f0101970:	68 a7 7e 10 f0       	push   $0xf0107ea7
f0101975:	68 3f 7d 10 f0       	push   $0xf0107d3f
f010197a:	68 e8 02 00 00       	push   $0x2e8
f010197f:	68 19 7d 10 f0       	push   $0xf0107d19
f0101984:	e8 b7 e6 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101989:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010198c:	29 c8                	sub    %ecx,%eax
f010198e:	c1 f8 03             	sar    $0x3,%eax
f0101991:	c1 e0 0c             	shl    $0xc,%eax
f0101994:	39 c2                	cmp    %eax,%edx
f0101996:	77 19                	ja     f01019b1 <mem_init+0x2da>
f0101998:	68 c4 7e 10 f0       	push   $0xf0107ec4
f010199d:	68 3f 7d 10 f0       	push   $0xf0107d3f
f01019a2:	68 e9 02 00 00       	push   $0x2e9
f01019a7:	68 19 7d 10 f0       	push   $0xf0107d19
f01019ac:	e8 8f e6 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01019b1:	a1 40 12 23 f0       	mov    0xf0231240,%eax
f01019b6:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01019b9:	c7 05 40 12 23 f0 00 	movl   $0x0,0xf0231240
f01019c0:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01019c3:	83 ec 0c             	sub    $0xc,%esp
f01019c6:	6a 00                	push   $0x0
f01019c8:	e8 6a f9 ff ff       	call   f0101337 <page_alloc>
f01019cd:	83 c4 10             	add    $0x10,%esp
f01019d0:	85 c0                	test   %eax,%eax
f01019d2:	74 19                	je     f01019ed <mem_init+0x316>
f01019d4:	68 e1 7e 10 f0       	push   $0xf0107ee1
f01019d9:	68 3f 7d 10 f0       	push   $0xf0107d3f
f01019de:	68 f0 02 00 00       	push   $0x2f0
f01019e3:	68 19 7d 10 f0       	push   $0xf0107d19
f01019e8:	e8 53 e6 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01019ed:	83 ec 0c             	sub    $0xc,%esp
f01019f0:	57                   	push   %edi
f01019f1:	e8 b1 f9 ff ff       	call   f01013a7 <page_free>
	page_free(pp1);
f01019f6:	89 34 24             	mov    %esi,(%esp)
f01019f9:	e8 a9 f9 ff ff       	call   f01013a7 <page_free>
	page_free(pp2);
f01019fe:	83 c4 04             	add    $0x4,%esp
f0101a01:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101a04:	e8 9e f9 ff ff       	call   f01013a7 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101a09:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a10:	e8 22 f9 ff ff       	call   f0101337 <page_alloc>
f0101a15:	89 c6                	mov    %eax,%esi
f0101a17:	83 c4 10             	add    $0x10,%esp
f0101a1a:	85 c0                	test   %eax,%eax
f0101a1c:	75 19                	jne    f0101a37 <mem_init+0x360>
f0101a1e:	68 36 7e 10 f0       	push   $0xf0107e36
f0101a23:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0101a28:	68 f7 02 00 00       	push   $0x2f7
f0101a2d:	68 19 7d 10 f0       	push   $0xf0107d19
f0101a32:	e8 09 e6 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101a37:	83 ec 0c             	sub    $0xc,%esp
f0101a3a:	6a 00                	push   $0x0
f0101a3c:	e8 f6 f8 ff ff       	call   f0101337 <page_alloc>
f0101a41:	89 c7                	mov    %eax,%edi
f0101a43:	83 c4 10             	add    $0x10,%esp
f0101a46:	85 c0                	test   %eax,%eax
f0101a48:	75 19                	jne    f0101a63 <mem_init+0x38c>
f0101a4a:	68 4c 7e 10 f0       	push   $0xf0107e4c
f0101a4f:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0101a54:	68 f8 02 00 00       	push   $0x2f8
f0101a59:	68 19 7d 10 f0       	push   $0xf0107d19
f0101a5e:	e8 dd e5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101a63:	83 ec 0c             	sub    $0xc,%esp
f0101a66:	6a 00                	push   $0x0
f0101a68:	e8 ca f8 ff ff       	call   f0101337 <page_alloc>
f0101a6d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101a70:	83 c4 10             	add    $0x10,%esp
f0101a73:	85 c0                	test   %eax,%eax
f0101a75:	75 19                	jne    f0101a90 <mem_init+0x3b9>
f0101a77:	68 62 7e 10 f0       	push   $0xf0107e62
f0101a7c:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0101a81:	68 f9 02 00 00       	push   $0x2f9
f0101a86:	68 19 7d 10 f0       	push   $0xf0107d19
f0101a8b:	e8 b0 e5 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a90:	39 fe                	cmp    %edi,%esi
f0101a92:	75 19                	jne    f0101aad <mem_init+0x3d6>
f0101a94:	68 78 7e 10 f0       	push   $0xf0107e78
f0101a99:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0101a9e:	68 fb 02 00 00       	push   $0x2fb
f0101aa3:	68 19 7d 10 f0       	push   $0xf0107d19
f0101aa8:	e8 93 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101aad:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ab0:	39 c7                	cmp    %eax,%edi
f0101ab2:	74 04                	je     f0101ab8 <mem_init+0x3e1>
f0101ab4:	39 c6                	cmp    %eax,%esi
f0101ab6:	75 19                	jne    f0101ad1 <mem_init+0x3fa>
f0101ab8:	68 3c 75 10 f0       	push   $0xf010753c
f0101abd:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0101ac2:	68 fc 02 00 00       	push   $0x2fc
f0101ac7:	68 19 7d 10 f0       	push   $0xf0107d19
f0101acc:	e8 6f e5 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101ad1:	83 ec 0c             	sub    $0xc,%esp
f0101ad4:	6a 00                	push   $0x0
f0101ad6:	e8 5c f8 ff ff       	call   f0101337 <page_alloc>
f0101adb:	83 c4 10             	add    $0x10,%esp
f0101ade:	85 c0                	test   %eax,%eax
f0101ae0:	74 19                	je     f0101afb <mem_init+0x424>
f0101ae2:	68 e1 7e 10 f0       	push   $0xf0107ee1
f0101ae7:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0101aec:	68 fd 02 00 00       	push   $0x2fd
f0101af1:	68 19 7d 10 f0       	push   $0xf0107d19
f0101af6:	e8 45 e5 ff ff       	call   f0100040 <_panic>
f0101afb:	89 f0                	mov    %esi,%eax
f0101afd:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0101b03:	c1 f8 03             	sar    $0x3,%eax
f0101b06:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101b09:	89 c2                	mov    %eax,%edx
f0101b0b:	c1 ea 0c             	shr    $0xc,%edx
f0101b0e:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f0101b14:	72 12                	jb     f0101b28 <mem_init+0x451>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101b16:	50                   	push   %eax
f0101b17:	68 84 6c 10 f0       	push   $0xf0106c84
f0101b1c:	6a 58                	push   $0x58
f0101b1e:	68 25 7d 10 f0       	push   $0xf0107d25
f0101b23:	e8 18 e5 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101b28:	83 ec 04             	sub    $0x4,%esp
f0101b2b:	68 00 10 00 00       	push   $0x1000
f0101b30:	6a 01                	push   $0x1
f0101b32:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101b37:	50                   	push   %eax
f0101b38:	e8 79 44 00 00       	call   f0105fb6 <memset>
	page_free(pp0);
f0101b3d:	89 34 24             	mov    %esi,(%esp)
f0101b40:	e8 62 f8 ff ff       	call   f01013a7 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101b45:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101b4c:	e8 e6 f7 ff ff       	call   f0101337 <page_alloc>
f0101b51:	83 c4 10             	add    $0x10,%esp
f0101b54:	85 c0                	test   %eax,%eax
f0101b56:	75 19                	jne    f0101b71 <mem_init+0x49a>
f0101b58:	68 f0 7e 10 f0       	push   $0xf0107ef0
f0101b5d:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0101b62:	68 02 03 00 00       	push   $0x302
f0101b67:	68 19 7d 10 f0       	push   $0xf0107d19
f0101b6c:	e8 cf e4 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101b71:	39 c6                	cmp    %eax,%esi
f0101b73:	74 19                	je     f0101b8e <mem_init+0x4b7>
f0101b75:	68 0e 7f 10 f0       	push   $0xf0107f0e
f0101b7a:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0101b7f:	68 03 03 00 00       	push   $0x303
f0101b84:	68 19 7d 10 f0       	push   $0xf0107d19
f0101b89:	e8 b2 e4 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b8e:	89 f0                	mov    %esi,%eax
f0101b90:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0101b96:	c1 f8 03             	sar    $0x3,%eax
f0101b99:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101b9c:	89 c2                	mov    %eax,%edx
f0101b9e:	c1 ea 0c             	shr    $0xc,%edx
f0101ba1:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f0101ba7:	72 12                	jb     f0101bbb <mem_init+0x4e4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101ba9:	50                   	push   %eax
f0101baa:	68 84 6c 10 f0       	push   $0xf0106c84
f0101baf:	6a 58                	push   $0x58
f0101bb1:	68 25 7d 10 f0       	push   $0xf0107d25
f0101bb6:	e8 85 e4 ff ff       	call   f0100040 <_panic>
f0101bbb:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101bc1:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101bc7:	80 38 00             	cmpb   $0x0,(%eax)
f0101bca:	74 19                	je     f0101be5 <mem_init+0x50e>
f0101bcc:	68 1e 7f 10 f0       	push   $0xf0107f1e
f0101bd1:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0101bd6:	68 06 03 00 00       	push   $0x306
f0101bdb:	68 19 7d 10 f0       	push   $0xf0107d19
f0101be0:	e8 5b e4 ff ff       	call   f0100040 <_panic>
f0101be5:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101be8:	39 d0                	cmp    %edx,%eax
f0101bea:	75 db                	jne    f0101bc7 <mem_init+0x4f0>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101bec:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101bef:	a3 40 12 23 f0       	mov    %eax,0xf0231240

	// free the pages we took
	page_free(pp0);
f0101bf4:	83 ec 0c             	sub    $0xc,%esp
f0101bf7:	56                   	push   %esi
f0101bf8:	e8 aa f7 ff ff       	call   f01013a7 <page_free>
	page_free(pp1);
f0101bfd:	89 3c 24             	mov    %edi,(%esp)
f0101c00:	e8 a2 f7 ff ff       	call   f01013a7 <page_free>
	page_free(pp2);
f0101c05:	83 c4 04             	add    $0x4,%esp
f0101c08:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101c0b:	e8 97 f7 ff ff       	call   f01013a7 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101c10:	a1 40 12 23 f0       	mov    0xf0231240,%eax
f0101c15:	83 c4 10             	add    $0x10,%esp
f0101c18:	eb 05                	jmp    f0101c1f <mem_init+0x548>
		--nfree;
f0101c1a:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101c1d:	8b 00                	mov    (%eax),%eax
f0101c1f:	85 c0                	test   %eax,%eax
f0101c21:	75 f7                	jne    f0101c1a <mem_init+0x543>
		--nfree;
	assert(nfree == 0);
f0101c23:	85 db                	test   %ebx,%ebx
f0101c25:	74 19                	je     f0101c40 <mem_init+0x569>
f0101c27:	68 28 7f 10 f0       	push   $0xf0107f28
f0101c2c:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0101c31:	68 13 03 00 00       	push   $0x313
f0101c36:	68 19 7d 10 f0       	push   $0xf0107d19
f0101c3b:	e8 00 e4 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101c40:	83 ec 0c             	sub    $0xc,%esp
f0101c43:	68 5c 75 10 f0       	push   $0xf010755c
f0101c48:	e8 11 1f 00 00       	call   f0103b5e <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101c4d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c54:	e8 de f6 ff ff       	call   f0101337 <page_alloc>
f0101c59:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101c5c:	83 c4 10             	add    $0x10,%esp
f0101c5f:	85 c0                	test   %eax,%eax
f0101c61:	75 19                	jne    f0101c7c <mem_init+0x5a5>
f0101c63:	68 36 7e 10 f0       	push   $0xf0107e36
f0101c68:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0101c6d:	68 79 03 00 00       	push   $0x379
f0101c72:	68 19 7d 10 f0       	push   $0xf0107d19
f0101c77:	e8 c4 e3 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101c7c:	83 ec 0c             	sub    $0xc,%esp
f0101c7f:	6a 00                	push   $0x0
f0101c81:	e8 b1 f6 ff ff       	call   f0101337 <page_alloc>
f0101c86:	89 c3                	mov    %eax,%ebx
f0101c88:	83 c4 10             	add    $0x10,%esp
f0101c8b:	85 c0                	test   %eax,%eax
f0101c8d:	75 19                	jne    f0101ca8 <mem_init+0x5d1>
f0101c8f:	68 4c 7e 10 f0       	push   $0xf0107e4c
f0101c94:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0101c99:	68 7a 03 00 00       	push   $0x37a
f0101c9e:	68 19 7d 10 f0       	push   $0xf0107d19
f0101ca3:	e8 98 e3 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101ca8:	83 ec 0c             	sub    $0xc,%esp
f0101cab:	6a 00                	push   $0x0
f0101cad:	e8 85 f6 ff ff       	call   f0101337 <page_alloc>
f0101cb2:	89 c6                	mov    %eax,%esi
f0101cb4:	83 c4 10             	add    $0x10,%esp
f0101cb7:	85 c0                	test   %eax,%eax
f0101cb9:	75 19                	jne    f0101cd4 <mem_init+0x5fd>
f0101cbb:	68 62 7e 10 f0       	push   $0xf0107e62
f0101cc0:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0101cc5:	68 7b 03 00 00       	push   $0x37b
f0101cca:	68 19 7d 10 f0       	push   $0xf0107d19
f0101ccf:	e8 6c e3 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101cd4:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101cd7:	75 19                	jne    f0101cf2 <mem_init+0x61b>
f0101cd9:	68 78 7e 10 f0       	push   $0xf0107e78
f0101cde:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0101ce3:	68 7e 03 00 00       	push   $0x37e
f0101ce8:	68 19 7d 10 f0       	push   $0xf0107d19
f0101ced:	e8 4e e3 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101cf2:	39 c3                	cmp    %eax,%ebx
f0101cf4:	74 05                	je     f0101cfb <mem_init+0x624>
f0101cf6:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101cf9:	75 19                	jne    f0101d14 <mem_init+0x63d>
f0101cfb:	68 3c 75 10 f0       	push   $0xf010753c
f0101d00:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0101d05:	68 7f 03 00 00       	push   $0x37f
f0101d0a:	68 19 7d 10 f0       	push   $0xf0107d19
f0101d0f:	e8 2c e3 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101d14:	a1 40 12 23 f0       	mov    0xf0231240,%eax
f0101d19:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101d1c:	c7 05 40 12 23 f0 00 	movl   $0x0,0xf0231240
f0101d23:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101d26:	83 ec 0c             	sub    $0xc,%esp
f0101d29:	6a 00                	push   $0x0
f0101d2b:	e8 07 f6 ff ff       	call   f0101337 <page_alloc>
f0101d30:	83 c4 10             	add    $0x10,%esp
f0101d33:	85 c0                	test   %eax,%eax
f0101d35:	74 19                	je     f0101d50 <mem_init+0x679>
f0101d37:	68 e1 7e 10 f0       	push   $0xf0107ee1
f0101d3c:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0101d41:	68 86 03 00 00       	push   $0x386
f0101d46:	68 19 7d 10 f0       	push   $0xf0107d19
f0101d4b:	e8 f0 e2 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101d50:	83 ec 04             	sub    $0x4,%esp
f0101d53:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101d56:	50                   	push   %eax
f0101d57:	6a 00                	push   $0x0
f0101d59:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0101d5f:	e8 bf f7 ff ff       	call   f0101523 <page_lookup>
f0101d64:	83 c4 10             	add    $0x10,%esp
f0101d67:	85 c0                	test   %eax,%eax
f0101d69:	74 19                	je     f0101d84 <mem_init+0x6ad>
f0101d6b:	68 7c 75 10 f0       	push   $0xf010757c
f0101d70:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0101d75:	68 89 03 00 00       	push   $0x389
f0101d7a:	68 19 7d 10 f0       	push   $0xf0107d19
f0101d7f:	e8 bc e2 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101d84:	6a 02                	push   $0x2
f0101d86:	6a 00                	push   $0x0
f0101d88:	53                   	push   %ebx
f0101d89:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0101d8f:	e8 79 f8 ff ff       	call   f010160d <page_insert>
f0101d94:	83 c4 10             	add    $0x10,%esp
f0101d97:	85 c0                	test   %eax,%eax
f0101d99:	78 19                	js     f0101db4 <mem_init+0x6dd>
f0101d9b:	68 b4 75 10 f0       	push   $0xf01075b4
f0101da0:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0101da5:	68 8c 03 00 00       	push   $0x38c
f0101daa:	68 19 7d 10 f0       	push   $0xf0107d19
f0101daf:	e8 8c e2 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101db4:	83 ec 0c             	sub    $0xc,%esp
f0101db7:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101dba:	e8 e8 f5 ff ff       	call   f01013a7 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101dbf:	6a 02                	push   $0x2
f0101dc1:	6a 00                	push   $0x0
f0101dc3:	53                   	push   %ebx
f0101dc4:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0101dca:	e8 3e f8 ff ff       	call   f010160d <page_insert>
f0101dcf:	83 c4 20             	add    $0x20,%esp
f0101dd2:	85 c0                	test   %eax,%eax
f0101dd4:	74 19                	je     f0101def <mem_init+0x718>
f0101dd6:	68 e4 75 10 f0       	push   $0xf01075e4
f0101ddb:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0101de0:	68 90 03 00 00       	push   $0x390
f0101de5:	68 19 7d 10 f0       	push   $0xf0107d19
f0101dea:	e8 51 e2 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101def:	8b 3d 8c 1e 23 f0    	mov    0xf0231e8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101df5:	a1 90 1e 23 f0       	mov    0xf0231e90,%eax
f0101dfa:	89 c1                	mov    %eax,%ecx
f0101dfc:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101dff:	8b 17                	mov    (%edi),%edx
f0101e01:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101e07:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e0a:	29 c8                	sub    %ecx,%eax
f0101e0c:	c1 f8 03             	sar    $0x3,%eax
f0101e0f:	c1 e0 0c             	shl    $0xc,%eax
f0101e12:	39 c2                	cmp    %eax,%edx
f0101e14:	74 19                	je     f0101e2f <mem_init+0x758>
f0101e16:	68 14 76 10 f0       	push   $0xf0107614
f0101e1b:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0101e20:	68 91 03 00 00       	push   $0x391
f0101e25:	68 19 7d 10 f0       	push   $0xf0107d19
f0101e2a:	e8 11 e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101e2f:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e34:	89 f8                	mov    %edi,%eax
f0101e36:	e8 8f f0 ff ff       	call   f0100eca <check_va2pa>
f0101e3b:	89 da                	mov    %ebx,%edx
f0101e3d:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101e40:	c1 fa 03             	sar    $0x3,%edx
f0101e43:	c1 e2 0c             	shl    $0xc,%edx
f0101e46:	39 d0                	cmp    %edx,%eax
f0101e48:	74 19                	je     f0101e63 <mem_init+0x78c>
f0101e4a:	68 3c 76 10 f0       	push   $0xf010763c
f0101e4f:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0101e54:	68 92 03 00 00       	push   $0x392
f0101e59:	68 19 7d 10 f0       	push   $0xf0107d19
f0101e5e:	e8 dd e1 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101e63:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e68:	74 19                	je     f0101e83 <mem_init+0x7ac>
f0101e6a:	68 33 7f 10 f0       	push   $0xf0107f33
f0101e6f:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0101e74:	68 93 03 00 00       	push   $0x393
f0101e79:	68 19 7d 10 f0       	push   $0xf0107d19
f0101e7e:	e8 bd e1 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101e83:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e86:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101e8b:	74 19                	je     f0101ea6 <mem_init+0x7cf>
f0101e8d:	68 44 7f 10 f0       	push   $0xf0107f44
f0101e92:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0101e97:	68 94 03 00 00       	push   $0x394
f0101e9c:	68 19 7d 10 f0       	push   $0xf0107d19
f0101ea1:	e8 9a e1 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ea6:	6a 02                	push   $0x2
f0101ea8:	68 00 10 00 00       	push   $0x1000
f0101ead:	56                   	push   %esi
f0101eae:	57                   	push   %edi
f0101eaf:	e8 59 f7 ff ff       	call   f010160d <page_insert>
f0101eb4:	83 c4 10             	add    $0x10,%esp
f0101eb7:	85 c0                	test   %eax,%eax
f0101eb9:	74 19                	je     f0101ed4 <mem_init+0x7fd>
f0101ebb:	68 6c 76 10 f0       	push   $0xf010766c
f0101ec0:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0101ec5:	68 97 03 00 00       	push   $0x397
f0101eca:	68 19 7d 10 f0       	push   $0xf0107d19
f0101ecf:	e8 6c e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ed4:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ed9:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0101ede:	e8 e7 ef ff ff       	call   f0100eca <check_va2pa>
f0101ee3:	89 f2                	mov    %esi,%edx
f0101ee5:	2b 15 90 1e 23 f0    	sub    0xf0231e90,%edx
f0101eeb:	c1 fa 03             	sar    $0x3,%edx
f0101eee:	c1 e2 0c             	shl    $0xc,%edx
f0101ef1:	39 d0                	cmp    %edx,%eax
f0101ef3:	74 19                	je     f0101f0e <mem_init+0x837>
f0101ef5:	68 a8 76 10 f0       	push   $0xf01076a8
f0101efa:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0101eff:	68 98 03 00 00       	push   $0x398
f0101f04:	68 19 7d 10 f0       	push   $0xf0107d19
f0101f09:	e8 32 e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101f0e:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101f13:	74 19                	je     f0101f2e <mem_init+0x857>
f0101f15:	68 55 7f 10 f0       	push   $0xf0107f55
f0101f1a:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0101f1f:	68 99 03 00 00       	push   $0x399
f0101f24:	68 19 7d 10 f0       	push   $0xf0107d19
f0101f29:	e8 12 e1 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101f2e:	83 ec 0c             	sub    $0xc,%esp
f0101f31:	6a 00                	push   $0x0
f0101f33:	e8 ff f3 ff ff       	call   f0101337 <page_alloc>
f0101f38:	83 c4 10             	add    $0x10,%esp
f0101f3b:	85 c0                	test   %eax,%eax
f0101f3d:	74 19                	je     f0101f58 <mem_init+0x881>
f0101f3f:	68 e1 7e 10 f0       	push   $0xf0107ee1
f0101f44:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0101f49:	68 9c 03 00 00       	push   $0x39c
f0101f4e:	68 19 7d 10 f0       	push   $0xf0107d19
f0101f53:	e8 e8 e0 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101f58:	6a 02                	push   $0x2
f0101f5a:	68 00 10 00 00       	push   $0x1000
f0101f5f:	56                   	push   %esi
f0101f60:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0101f66:	e8 a2 f6 ff ff       	call   f010160d <page_insert>
f0101f6b:	83 c4 10             	add    $0x10,%esp
f0101f6e:	85 c0                	test   %eax,%eax
f0101f70:	74 19                	je     f0101f8b <mem_init+0x8b4>
f0101f72:	68 6c 76 10 f0       	push   $0xf010766c
f0101f77:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0101f7c:	68 9f 03 00 00       	push   $0x39f
f0101f81:	68 19 7d 10 f0       	push   $0xf0107d19
f0101f86:	e8 b5 e0 ff ff       	call   f0100040 <_panic>
	
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f8b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f90:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0101f95:	e8 30 ef ff ff       	call   f0100eca <check_va2pa>
f0101f9a:	89 f2                	mov    %esi,%edx
f0101f9c:	2b 15 90 1e 23 f0    	sub    0xf0231e90,%edx
f0101fa2:	c1 fa 03             	sar    $0x3,%edx
f0101fa5:	c1 e2 0c             	shl    $0xc,%edx
f0101fa8:	39 d0                	cmp    %edx,%eax
f0101faa:	74 19                	je     f0101fc5 <mem_init+0x8ee>
f0101fac:	68 a8 76 10 f0       	push   $0xf01076a8
f0101fb1:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0101fb6:	68 a1 03 00 00       	push   $0x3a1
f0101fbb:	68 19 7d 10 f0       	push   $0xf0107d19
f0101fc0:	e8 7b e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101fc5:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101fca:	74 19                	je     f0101fe5 <mem_init+0x90e>
f0101fcc:	68 55 7f 10 f0       	push   $0xf0107f55
f0101fd1:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0101fd6:	68 a2 03 00 00       	push   $0x3a2
f0101fdb:	68 19 7d 10 f0       	push   $0xf0107d19
f0101fe0:	e8 5b e0 ff ff       	call   f0100040 <_panic>
	
	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101fe5:	83 ec 0c             	sub    $0xc,%esp
f0101fe8:	6a 00                	push   $0x0
f0101fea:	e8 48 f3 ff ff       	call   f0101337 <page_alloc>
f0101fef:	83 c4 10             	add    $0x10,%esp
f0101ff2:	85 c0                	test   %eax,%eax
f0101ff4:	74 19                	je     f010200f <mem_init+0x938>
f0101ff6:	68 e1 7e 10 f0       	push   $0xf0107ee1
f0101ffb:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102000:	68 a6 03 00 00       	push   $0x3a6
f0102005:	68 19 7d 10 f0       	push   $0xf0107d19
f010200a:	e8 31 e0 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f010200f:	8b 15 8c 1e 23 f0    	mov    0xf0231e8c,%edx
f0102015:	8b 02                	mov    (%edx),%eax
f0102017:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010201c:	89 c1                	mov    %eax,%ecx
f010201e:	c1 e9 0c             	shr    $0xc,%ecx
f0102021:	3b 0d 88 1e 23 f0    	cmp    0xf0231e88,%ecx
f0102027:	72 15                	jb     f010203e <mem_init+0x967>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102029:	50                   	push   %eax
f010202a:	68 84 6c 10 f0       	push   $0xf0106c84
f010202f:	68 a9 03 00 00       	push   $0x3a9
f0102034:	68 19 7d 10 f0       	push   $0xf0107d19
f0102039:	e8 02 e0 ff ff       	call   f0100040 <_panic>
f010203e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102043:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102046:	83 ec 04             	sub    $0x4,%esp
f0102049:	6a 00                	push   $0x0
f010204b:	68 00 10 00 00       	push   $0x1000
f0102050:	52                   	push   %edx
f0102051:	e8 eb f3 ff ff       	call   f0101441 <pgdir_walk>
f0102056:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102059:	8d 51 04             	lea    0x4(%ecx),%edx
f010205c:	83 c4 10             	add    $0x10,%esp
f010205f:	39 d0                	cmp    %edx,%eax
f0102061:	74 19                	je     f010207c <mem_init+0x9a5>
f0102063:	68 d8 76 10 f0       	push   $0xf01076d8
f0102068:	68 3f 7d 10 f0       	push   $0xf0107d3f
f010206d:	68 aa 03 00 00       	push   $0x3aa
f0102072:	68 19 7d 10 f0       	push   $0xf0107d19
f0102077:	e8 c4 df ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f010207c:	6a 06                	push   $0x6
f010207e:	68 00 10 00 00       	push   $0x1000
f0102083:	56                   	push   %esi
f0102084:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f010208a:	e8 7e f5 ff ff       	call   f010160d <page_insert>
f010208f:	83 c4 10             	add    $0x10,%esp
f0102092:	85 c0                	test   %eax,%eax
f0102094:	74 19                	je     f01020af <mem_init+0x9d8>
f0102096:	68 18 77 10 f0       	push   $0xf0107718
f010209b:	68 3f 7d 10 f0       	push   $0xf0107d3f
f01020a0:	68 ad 03 00 00       	push   $0x3ad
f01020a5:	68 19 7d 10 f0       	push   $0xf0107d19
f01020aa:	e8 91 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01020af:	8b 3d 8c 1e 23 f0    	mov    0xf0231e8c,%edi
f01020b5:	ba 00 10 00 00       	mov    $0x1000,%edx
f01020ba:	89 f8                	mov    %edi,%eax
f01020bc:	e8 09 ee ff ff       	call   f0100eca <check_va2pa>
f01020c1:	89 f2                	mov    %esi,%edx
f01020c3:	2b 15 90 1e 23 f0    	sub    0xf0231e90,%edx
f01020c9:	c1 fa 03             	sar    $0x3,%edx
f01020cc:	c1 e2 0c             	shl    $0xc,%edx
f01020cf:	39 d0                	cmp    %edx,%eax
f01020d1:	74 19                	je     f01020ec <mem_init+0xa15>
f01020d3:	68 a8 76 10 f0       	push   $0xf01076a8
f01020d8:	68 3f 7d 10 f0       	push   $0xf0107d3f
f01020dd:	68 ae 03 00 00       	push   $0x3ae
f01020e2:	68 19 7d 10 f0       	push   $0xf0107d19
f01020e7:	e8 54 df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01020ec:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01020f1:	74 19                	je     f010210c <mem_init+0xa35>
f01020f3:	68 55 7f 10 f0       	push   $0xf0107f55
f01020f8:	68 3f 7d 10 f0       	push   $0xf0107d3f
f01020fd:	68 af 03 00 00       	push   $0x3af
f0102102:	68 19 7d 10 f0       	push   $0xf0107d19
f0102107:	e8 34 df ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010210c:	83 ec 04             	sub    $0x4,%esp
f010210f:	6a 00                	push   $0x0
f0102111:	68 00 10 00 00       	push   $0x1000
f0102116:	57                   	push   %edi
f0102117:	e8 25 f3 ff ff       	call   f0101441 <pgdir_walk>
f010211c:	83 c4 10             	add    $0x10,%esp
f010211f:	f6 00 04             	testb  $0x4,(%eax)
f0102122:	75 19                	jne    f010213d <mem_init+0xa66>
f0102124:	68 58 77 10 f0       	push   $0xf0107758
f0102129:	68 3f 7d 10 f0       	push   $0xf0107d3f
f010212e:	68 b0 03 00 00       	push   $0x3b0
f0102133:	68 19 7d 10 f0       	push   $0xf0107d19
f0102138:	e8 03 df ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f010213d:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102142:	f6 00 04             	testb  $0x4,(%eax)
f0102145:	75 19                	jne    f0102160 <mem_init+0xa89>
f0102147:	68 66 7f 10 f0       	push   $0xf0107f66
f010214c:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102151:	68 b1 03 00 00       	push   $0x3b1
f0102156:	68 19 7d 10 f0       	push   $0xf0107d19
f010215b:	e8 e0 de ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102160:	6a 02                	push   $0x2
f0102162:	68 00 10 00 00       	push   $0x1000
f0102167:	56                   	push   %esi
f0102168:	50                   	push   %eax
f0102169:	e8 9f f4 ff ff       	call   f010160d <page_insert>
f010216e:	83 c4 10             	add    $0x10,%esp
f0102171:	85 c0                	test   %eax,%eax
f0102173:	74 19                	je     f010218e <mem_init+0xab7>
f0102175:	68 6c 76 10 f0       	push   $0xf010766c
f010217a:	68 3f 7d 10 f0       	push   $0xf0107d3f
f010217f:	68 b4 03 00 00       	push   $0x3b4
f0102184:	68 19 7d 10 f0       	push   $0xf0107d19
f0102189:	e8 b2 de ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f010218e:	83 ec 04             	sub    $0x4,%esp
f0102191:	6a 00                	push   $0x0
f0102193:	68 00 10 00 00       	push   $0x1000
f0102198:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f010219e:	e8 9e f2 ff ff       	call   f0101441 <pgdir_walk>
f01021a3:	83 c4 10             	add    $0x10,%esp
f01021a6:	f6 00 02             	testb  $0x2,(%eax)
f01021a9:	75 19                	jne    f01021c4 <mem_init+0xaed>
f01021ab:	68 8c 77 10 f0       	push   $0xf010778c
f01021b0:	68 3f 7d 10 f0       	push   $0xf0107d3f
f01021b5:	68 b5 03 00 00       	push   $0x3b5
f01021ba:	68 19 7d 10 f0       	push   $0xf0107d19
f01021bf:	e8 7c de ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01021c4:	83 ec 04             	sub    $0x4,%esp
f01021c7:	6a 00                	push   $0x0
f01021c9:	68 00 10 00 00       	push   $0x1000
f01021ce:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f01021d4:	e8 68 f2 ff ff       	call   f0101441 <pgdir_walk>
f01021d9:	83 c4 10             	add    $0x10,%esp
f01021dc:	f6 00 04             	testb  $0x4,(%eax)
f01021df:	74 19                	je     f01021fa <mem_init+0xb23>
f01021e1:	68 c0 77 10 f0       	push   $0xf01077c0
f01021e6:	68 3f 7d 10 f0       	push   $0xf0107d3f
f01021eb:	68 b6 03 00 00       	push   $0x3b6
f01021f0:	68 19 7d 10 f0       	push   $0xf0107d19
f01021f5:	e8 46 de ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01021fa:	6a 02                	push   $0x2
f01021fc:	68 00 00 40 00       	push   $0x400000
f0102201:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102204:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f010220a:	e8 fe f3 ff ff       	call   f010160d <page_insert>
f010220f:	83 c4 10             	add    $0x10,%esp
f0102212:	85 c0                	test   %eax,%eax
f0102214:	78 19                	js     f010222f <mem_init+0xb58>
f0102216:	68 f8 77 10 f0       	push   $0xf01077f8
f010221b:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102220:	68 b9 03 00 00       	push   $0x3b9
f0102225:	68 19 7d 10 f0       	push   $0xf0107d19
f010222a:	e8 11 de ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010222f:	6a 02                	push   $0x2
f0102231:	68 00 10 00 00       	push   $0x1000
f0102236:	53                   	push   %ebx
f0102237:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f010223d:	e8 cb f3 ff ff       	call   f010160d <page_insert>
f0102242:	83 c4 10             	add    $0x10,%esp
f0102245:	85 c0                	test   %eax,%eax
f0102247:	74 19                	je     f0102262 <mem_init+0xb8b>
f0102249:	68 30 78 10 f0       	push   $0xf0107830
f010224e:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102253:	68 bc 03 00 00       	push   $0x3bc
f0102258:	68 19 7d 10 f0       	push   $0xf0107d19
f010225d:	e8 de dd ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102262:	83 ec 04             	sub    $0x4,%esp
f0102265:	6a 00                	push   $0x0
f0102267:	68 00 10 00 00       	push   $0x1000
f010226c:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0102272:	e8 ca f1 ff ff       	call   f0101441 <pgdir_walk>
f0102277:	83 c4 10             	add    $0x10,%esp
f010227a:	f6 00 04             	testb  $0x4,(%eax)
f010227d:	74 19                	je     f0102298 <mem_init+0xbc1>
f010227f:	68 c0 77 10 f0       	push   $0xf01077c0
f0102284:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102289:	68 bd 03 00 00       	push   $0x3bd
f010228e:	68 19 7d 10 f0       	push   $0xf0107d19
f0102293:	e8 a8 dd ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102298:	8b 3d 8c 1e 23 f0    	mov    0xf0231e8c,%edi
f010229e:	ba 00 00 00 00       	mov    $0x0,%edx
f01022a3:	89 f8                	mov    %edi,%eax
f01022a5:	e8 20 ec ff ff       	call   f0100eca <check_va2pa>
f01022aa:	89 c1                	mov    %eax,%ecx
f01022ac:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01022af:	89 d8                	mov    %ebx,%eax
f01022b1:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f01022b7:	c1 f8 03             	sar    $0x3,%eax
f01022ba:	c1 e0 0c             	shl    $0xc,%eax
f01022bd:	39 c1                	cmp    %eax,%ecx
f01022bf:	74 19                	je     f01022da <mem_init+0xc03>
f01022c1:	68 6c 78 10 f0       	push   $0xf010786c
f01022c6:	68 3f 7d 10 f0       	push   $0xf0107d3f
f01022cb:	68 c0 03 00 00       	push   $0x3c0
f01022d0:	68 19 7d 10 f0       	push   $0xf0107d19
f01022d5:	e8 66 dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01022da:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022df:	89 f8                	mov    %edi,%eax
f01022e1:	e8 e4 eb ff ff       	call   f0100eca <check_va2pa>
f01022e6:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f01022e9:	74 19                	je     f0102304 <mem_init+0xc2d>
f01022eb:	68 98 78 10 f0       	push   $0xf0107898
f01022f0:	68 3f 7d 10 f0       	push   $0xf0107d3f
f01022f5:	68 c1 03 00 00       	push   $0x3c1
f01022fa:	68 19 7d 10 f0       	push   $0xf0107d19
f01022ff:	e8 3c dd ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102304:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0102309:	74 19                	je     f0102324 <mem_init+0xc4d>
f010230b:	68 7c 7f 10 f0       	push   $0xf0107f7c
f0102310:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102315:	68 c3 03 00 00       	push   $0x3c3
f010231a:	68 19 7d 10 f0       	push   $0xf0107d19
f010231f:	e8 1c dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102324:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102329:	74 19                	je     f0102344 <mem_init+0xc6d>
f010232b:	68 8d 7f 10 f0       	push   $0xf0107f8d
f0102330:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102335:	68 c4 03 00 00       	push   $0x3c4
f010233a:	68 19 7d 10 f0       	push   $0xf0107d19
f010233f:	e8 fc dc ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102344:	83 ec 0c             	sub    $0xc,%esp
f0102347:	6a 00                	push   $0x0
f0102349:	e8 e9 ef ff ff       	call   f0101337 <page_alloc>
f010234e:	83 c4 10             	add    $0x10,%esp
f0102351:	85 c0                	test   %eax,%eax
f0102353:	74 04                	je     f0102359 <mem_init+0xc82>
f0102355:	39 c6                	cmp    %eax,%esi
f0102357:	74 19                	je     f0102372 <mem_init+0xc9b>
f0102359:	68 c8 78 10 f0       	push   $0xf01078c8
f010235e:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102363:	68 c7 03 00 00       	push   $0x3c7
f0102368:	68 19 7d 10 f0       	push   $0xf0107d19
f010236d:	e8 ce dc ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102372:	83 ec 08             	sub    $0x8,%esp
f0102375:	6a 00                	push   $0x0
f0102377:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f010237d:	e8 3b f2 ff ff       	call   f01015bd <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102382:	8b 3d 8c 1e 23 f0    	mov    0xf0231e8c,%edi
f0102388:	ba 00 00 00 00       	mov    $0x0,%edx
f010238d:	89 f8                	mov    %edi,%eax
f010238f:	e8 36 eb ff ff       	call   f0100eca <check_va2pa>
f0102394:	83 c4 10             	add    $0x10,%esp
f0102397:	83 f8 ff             	cmp    $0xffffffff,%eax
f010239a:	74 19                	je     f01023b5 <mem_init+0xcde>
f010239c:	68 ec 78 10 f0       	push   $0xf01078ec
f01023a1:	68 3f 7d 10 f0       	push   $0xf0107d3f
f01023a6:	68 cb 03 00 00       	push   $0x3cb
f01023ab:	68 19 7d 10 f0       	push   $0xf0107d19
f01023b0:	e8 8b dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01023b5:	ba 00 10 00 00       	mov    $0x1000,%edx
f01023ba:	89 f8                	mov    %edi,%eax
f01023bc:	e8 09 eb ff ff       	call   f0100eca <check_va2pa>
f01023c1:	89 da                	mov    %ebx,%edx
f01023c3:	2b 15 90 1e 23 f0    	sub    0xf0231e90,%edx
f01023c9:	c1 fa 03             	sar    $0x3,%edx
f01023cc:	c1 e2 0c             	shl    $0xc,%edx
f01023cf:	39 d0                	cmp    %edx,%eax
f01023d1:	74 19                	je     f01023ec <mem_init+0xd15>
f01023d3:	68 98 78 10 f0       	push   $0xf0107898
f01023d8:	68 3f 7d 10 f0       	push   $0xf0107d3f
f01023dd:	68 cc 03 00 00       	push   $0x3cc
f01023e2:	68 19 7d 10 f0       	push   $0xf0107d19
f01023e7:	e8 54 dc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01023ec:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01023f1:	74 19                	je     f010240c <mem_init+0xd35>
f01023f3:	68 33 7f 10 f0       	push   $0xf0107f33
f01023f8:	68 3f 7d 10 f0       	push   $0xf0107d3f
f01023fd:	68 cd 03 00 00       	push   $0x3cd
f0102402:	68 19 7d 10 f0       	push   $0xf0107d19
f0102407:	e8 34 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010240c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102411:	74 19                	je     f010242c <mem_init+0xd55>
f0102413:	68 8d 7f 10 f0       	push   $0xf0107f8d
f0102418:	68 3f 7d 10 f0       	push   $0xf0107d3f
f010241d:	68 ce 03 00 00       	push   $0x3ce
f0102422:	68 19 7d 10 f0       	push   $0xf0107d19
f0102427:	e8 14 dc ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f010242c:	6a 00                	push   $0x0
f010242e:	68 00 10 00 00       	push   $0x1000
f0102433:	53                   	push   %ebx
f0102434:	57                   	push   %edi
f0102435:	e8 d3 f1 ff ff       	call   f010160d <page_insert>
f010243a:	83 c4 10             	add    $0x10,%esp
f010243d:	85 c0                	test   %eax,%eax
f010243f:	74 19                	je     f010245a <mem_init+0xd83>
f0102441:	68 10 79 10 f0       	push   $0xf0107910
f0102446:	68 3f 7d 10 f0       	push   $0xf0107d3f
f010244b:	68 d1 03 00 00       	push   $0x3d1
f0102450:	68 19 7d 10 f0       	push   $0xf0107d19
f0102455:	e8 e6 db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f010245a:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010245f:	75 19                	jne    f010247a <mem_init+0xda3>
f0102461:	68 9e 7f 10 f0       	push   $0xf0107f9e
f0102466:	68 3f 7d 10 f0       	push   $0xf0107d3f
f010246b:	68 d2 03 00 00       	push   $0x3d2
f0102470:	68 19 7d 10 f0       	push   $0xf0107d19
f0102475:	e8 c6 db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f010247a:	83 3b 00             	cmpl   $0x0,(%ebx)
f010247d:	74 19                	je     f0102498 <mem_init+0xdc1>
f010247f:	68 aa 7f 10 f0       	push   $0xf0107faa
f0102484:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102489:	68 d3 03 00 00       	push   $0x3d3
f010248e:	68 19 7d 10 f0       	push   $0xf0107d19
f0102493:	e8 a8 db ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102498:	83 ec 08             	sub    $0x8,%esp
f010249b:	68 00 10 00 00       	push   $0x1000
f01024a0:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f01024a6:	e8 12 f1 ff ff       	call   f01015bd <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01024ab:	8b 3d 8c 1e 23 f0    	mov    0xf0231e8c,%edi
f01024b1:	ba 00 00 00 00       	mov    $0x0,%edx
f01024b6:	89 f8                	mov    %edi,%eax
f01024b8:	e8 0d ea ff ff       	call   f0100eca <check_va2pa>
f01024bd:	83 c4 10             	add    $0x10,%esp
f01024c0:	83 f8 ff             	cmp    $0xffffffff,%eax
f01024c3:	74 19                	je     f01024de <mem_init+0xe07>
f01024c5:	68 ec 78 10 f0       	push   $0xf01078ec
f01024ca:	68 3f 7d 10 f0       	push   $0xf0107d3f
f01024cf:	68 d7 03 00 00       	push   $0x3d7
f01024d4:	68 19 7d 10 f0       	push   $0xf0107d19
f01024d9:	e8 62 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01024de:	ba 00 10 00 00       	mov    $0x1000,%edx
f01024e3:	89 f8                	mov    %edi,%eax
f01024e5:	e8 e0 e9 ff ff       	call   f0100eca <check_va2pa>
f01024ea:	83 f8 ff             	cmp    $0xffffffff,%eax
f01024ed:	74 19                	je     f0102508 <mem_init+0xe31>
f01024ef:	68 48 79 10 f0       	push   $0xf0107948
f01024f4:	68 3f 7d 10 f0       	push   $0xf0107d3f
f01024f9:	68 d8 03 00 00       	push   $0x3d8
f01024fe:	68 19 7d 10 f0       	push   $0xf0107d19
f0102503:	e8 38 db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102508:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010250d:	74 19                	je     f0102528 <mem_init+0xe51>
f010250f:	68 bf 7f 10 f0       	push   $0xf0107fbf
f0102514:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102519:	68 d9 03 00 00       	push   $0x3d9
f010251e:	68 19 7d 10 f0       	push   $0xf0107d19
f0102523:	e8 18 db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102528:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010252d:	74 19                	je     f0102548 <mem_init+0xe71>
f010252f:	68 8d 7f 10 f0       	push   $0xf0107f8d
f0102534:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102539:	68 da 03 00 00       	push   $0x3da
f010253e:	68 19 7d 10 f0       	push   $0xf0107d19
f0102543:	e8 f8 da ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102548:	83 ec 0c             	sub    $0xc,%esp
f010254b:	6a 00                	push   $0x0
f010254d:	e8 e5 ed ff ff       	call   f0101337 <page_alloc>
f0102552:	83 c4 10             	add    $0x10,%esp
f0102555:	39 c3                	cmp    %eax,%ebx
f0102557:	75 04                	jne    f010255d <mem_init+0xe86>
f0102559:	85 c0                	test   %eax,%eax
f010255b:	75 19                	jne    f0102576 <mem_init+0xe9f>
f010255d:	68 70 79 10 f0       	push   $0xf0107970
f0102562:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102567:	68 dd 03 00 00       	push   $0x3dd
f010256c:	68 19 7d 10 f0       	push   $0xf0107d19
f0102571:	e8 ca da ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102576:	83 ec 0c             	sub    $0xc,%esp
f0102579:	6a 00                	push   $0x0
f010257b:	e8 b7 ed ff ff       	call   f0101337 <page_alloc>
f0102580:	83 c4 10             	add    $0x10,%esp
f0102583:	85 c0                	test   %eax,%eax
f0102585:	74 19                	je     f01025a0 <mem_init+0xec9>
f0102587:	68 e1 7e 10 f0       	push   $0xf0107ee1
f010258c:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102591:	68 e0 03 00 00       	push   $0x3e0
f0102596:	68 19 7d 10 f0       	push   $0xf0107d19
f010259b:	e8 a0 da ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01025a0:	8b 0d 8c 1e 23 f0    	mov    0xf0231e8c,%ecx
f01025a6:	8b 11                	mov    (%ecx),%edx
f01025a8:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01025ae:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01025b1:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f01025b7:	c1 f8 03             	sar    $0x3,%eax
f01025ba:	c1 e0 0c             	shl    $0xc,%eax
f01025bd:	39 c2                	cmp    %eax,%edx
f01025bf:	74 19                	je     f01025da <mem_init+0xf03>
f01025c1:	68 14 76 10 f0       	push   $0xf0107614
f01025c6:	68 3f 7d 10 f0       	push   $0xf0107d3f
f01025cb:	68 e3 03 00 00       	push   $0x3e3
f01025d0:	68 19 7d 10 f0       	push   $0xf0107d19
f01025d5:	e8 66 da ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f01025da:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01025e0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01025e3:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01025e8:	74 19                	je     f0102603 <mem_init+0xf2c>
f01025ea:	68 44 7f 10 f0       	push   $0xf0107f44
f01025ef:	68 3f 7d 10 f0       	push   $0xf0107d3f
f01025f4:	68 e5 03 00 00       	push   $0x3e5
f01025f9:	68 19 7d 10 f0       	push   $0xf0107d19
f01025fe:	e8 3d da ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102603:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102606:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010260c:	83 ec 0c             	sub    $0xc,%esp
f010260f:	50                   	push   %eax
f0102610:	e8 92 ed ff ff       	call   f01013a7 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102615:	83 c4 0c             	add    $0xc,%esp
f0102618:	6a 01                	push   $0x1
f010261a:	68 00 10 40 00       	push   $0x401000
f010261f:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0102625:	e8 17 ee ff ff       	call   f0101441 <pgdir_walk>
f010262a:	89 c7                	mov    %eax,%edi
f010262c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010262f:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102634:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102637:	8b 40 04             	mov    0x4(%eax),%eax
f010263a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010263f:	8b 0d 88 1e 23 f0    	mov    0xf0231e88,%ecx
f0102645:	89 c2                	mov    %eax,%edx
f0102647:	c1 ea 0c             	shr    $0xc,%edx
f010264a:	83 c4 10             	add    $0x10,%esp
f010264d:	39 ca                	cmp    %ecx,%edx
f010264f:	72 15                	jb     f0102666 <mem_init+0xf8f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102651:	50                   	push   %eax
f0102652:	68 84 6c 10 f0       	push   $0xf0106c84
f0102657:	68 ec 03 00 00       	push   $0x3ec
f010265c:	68 19 7d 10 f0       	push   $0xf0107d19
f0102661:	e8 da d9 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102666:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f010266b:	39 c7                	cmp    %eax,%edi
f010266d:	74 19                	je     f0102688 <mem_init+0xfb1>
f010266f:	68 d0 7f 10 f0       	push   $0xf0107fd0
f0102674:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102679:	68 ed 03 00 00       	push   $0x3ed
f010267e:	68 19 7d 10 f0       	push   $0xf0107d19
f0102683:	e8 b8 d9 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102688:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010268b:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102692:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102695:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010269b:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f01026a1:	c1 f8 03             	sar    $0x3,%eax
f01026a4:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01026a7:	89 c2                	mov    %eax,%edx
f01026a9:	c1 ea 0c             	shr    $0xc,%edx
f01026ac:	39 d1                	cmp    %edx,%ecx
f01026ae:	77 12                	ja     f01026c2 <mem_init+0xfeb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01026b0:	50                   	push   %eax
f01026b1:	68 84 6c 10 f0       	push   $0xf0106c84
f01026b6:	6a 58                	push   $0x58
f01026b8:	68 25 7d 10 f0       	push   $0xf0107d25
f01026bd:	e8 7e d9 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01026c2:	83 ec 04             	sub    $0x4,%esp
f01026c5:	68 00 10 00 00       	push   $0x1000
f01026ca:	68 ff 00 00 00       	push   $0xff
f01026cf:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01026d4:	50                   	push   %eax
f01026d5:	e8 dc 38 00 00       	call   f0105fb6 <memset>
	page_free(pp0);
f01026da:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01026dd:	89 3c 24             	mov    %edi,(%esp)
f01026e0:	e8 c2 ec ff ff       	call   f01013a7 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01026e5:	83 c4 0c             	add    $0xc,%esp
f01026e8:	6a 01                	push   $0x1
f01026ea:	6a 00                	push   $0x0
f01026ec:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f01026f2:	e8 4a ed ff ff       	call   f0101441 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01026f7:	89 fa                	mov    %edi,%edx
f01026f9:	2b 15 90 1e 23 f0    	sub    0xf0231e90,%edx
f01026ff:	c1 fa 03             	sar    $0x3,%edx
f0102702:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102705:	89 d0                	mov    %edx,%eax
f0102707:	c1 e8 0c             	shr    $0xc,%eax
f010270a:	83 c4 10             	add    $0x10,%esp
f010270d:	3b 05 88 1e 23 f0    	cmp    0xf0231e88,%eax
f0102713:	72 12                	jb     f0102727 <mem_init+0x1050>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102715:	52                   	push   %edx
f0102716:	68 84 6c 10 f0       	push   $0xf0106c84
f010271b:	6a 58                	push   $0x58
f010271d:	68 25 7d 10 f0       	push   $0xf0107d25
f0102722:	e8 19 d9 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102727:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010272d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102730:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102736:	f6 00 01             	testb  $0x1,(%eax)
f0102739:	74 19                	je     f0102754 <mem_init+0x107d>
f010273b:	68 e8 7f 10 f0       	push   $0xf0107fe8
f0102740:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102745:	68 f7 03 00 00       	push   $0x3f7
f010274a:	68 19 7d 10 f0       	push   $0xf0107d19
f010274f:	e8 ec d8 ff ff       	call   f0100040 <_panic>
f0102754:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102757:	39 c2                	cmp    %eax,%edx
f0102759:	75 db                	jne    f0102736 <mem_init+0x105f>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f010275b:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102760:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102766:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102769:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f010276f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102772:	89 0d 40 12 23 f0    	mov    %ecx,0xf0231240

	// free the pages we took
	page_free(pp0);
f0102778:	83 ec 0c             	sub    $0xc,%esp
f010277b:	50                   	push   %eax
f010277c:	e8 26 ec ff ff       	call   f01013a7 <page_free>
	page_free(pp1);
f0102781:	89 1c 24             	mov    %ebx,(%esp)
f0102784:	e8 1e ec ff ff       	call   f01013a7 <page_free>
	page_free(pp2);
f0102789:	89 34 24             	mov    %esi,(%esp)
f010278c:	e8 16 ec ff ff       	call   f01013a7 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102791:	83 c4 08             	add    $0x8,%esp
f0102794:	68 01 10 00 00       	push   $0x1001
f0102799:	6a 00                	push   $0x0
f010279b:	e8 d3 ee ff ff       	call   f0101673 <mmio_map_region>
f01027a0:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f01027a2:	83 c4 08             	add    $0x8,%esp
f01027a5:	68 00 10 00 00       	push   $0x1000
f01027aa:	6a 00                	push   $0x0
f01027ac:	e8 c2 ee ff ff       	call   f0101673 <mmio_map_region>
f01027b1:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f01027b3:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f01027b9:	83 c4 10             	add    $0x10,%esp
f01027bc:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01027c2:	76 07                	jbe    f01027cb <mem_init+0x10f4>
f01027c4:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f01027c9:	76 19                	jbe    f01027e4 <mem_init+0x110d>
f01027cb:	68 94 79 10 f0       	push   $0xf0107994
f01027d0:	68 3f 7d 10 f0       	push   $0xf0107d3f
f01027d5:	68 07 04 00 00       	push   $0x407
f01027da:	68 19 7d 10 f0       	push   $0xf0107d19
f01027df:	e8 5c d8 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f01027e4:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f01027ea:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01027f0:	77 08                	ja     f01027fa <mem_init+0x1123>
f01027f2:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01027f8:	77 19                	ja     f0102813 <mem_init+0x113c>
f01027fa:	68 bc 79 10 f0       	push   $0xf01079bc
f01027ff:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102804:	68 08 04 00 00       	push   $0x408
f0102809:	68 19 7d 10 f0       	push   $0xf0107d19
f010280e:	e8 2d d8 ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102813:	89 da                	mov    %ebx,%edx
f0102815:	09 f2                	or     %esi,%edx
f0102817:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f010281d:	74 19                	je     f0102838 <mem_init+0x1161>
f010281f:	68 e4 79 10 f0       	push   $0xf01079e4
f0102824:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102829:	68 0a 04 00 00       	push   $0x40a
f010282e:	68 19 7d 10 f0       	push   $0xf0107d19
f0102833:	e8 08 d8 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102838:	39 c6                	cmp    %eax,%esi
f010283a:	73 19                	jae    f0102855 <mem_init+0x117e>
f010283c:	68 ff 7f 10 f0       	push   $0xf0107fff
f0102841:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102846:	68 0c 04 00 00       	push   $0x40c
f010284b:	68 19 7d 10 f0       	push   $0xf0107d19
f0102850:	e8 eb d7 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102855:	8b 3d 8c 1e 23 f0    	mov    0xf0231e8c,%edi
f010285b:	89 da                	mov    %ebx,%edx
f010285d:	89 f8                	mov    %edi,%eax
f010285f:	e8 66 e6 ff ff       	call   f0100eca <check_va2pa>
f0102864:	85 c0                	test   %eax,%eax
f0102866:	74 19                	je     f0102881 <mem_init+0x11aa>
f0102868:	68 0c 7a 10 f0       	push   $0xf0107a0c
f010286d:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102872:	68 0e 04 00 00       	push   $0x40e
f0102877:	68 19 7d 10 f0       	push   $0xf0107d19
f010287c:	e8 bf d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102881:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102887:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010288a:	89 c2                	mov    %eax,%edx
f010288c:	89 f8                	mov    %edi,%eax
f010288e:	e8 37 e6 ff ff       	call   f0100eca <check_va2pa>
f0102893:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102898:	74 19                	je     f01028b3 <mem_init+0x11dc>
f010289a:	68 30 7a 10 f0       	push   $0xf0107a30
f010289f:	68 3f 7d 10 f0       	push   $0xf0107d3f
f01028a4:	68 0f 04 00 00       	push   $0x40f
f01028a9:	68 19 7d 10 f0       	push   $0xf0107d19
f01028ae:	e8 8d d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f01028b3:	89 f2                	mov    %esi,%edx
f01028b5:	89 f8                	mov    %edi,%eax
f01028b7:	e8 0e e6 ff ff       	call   f0100eca <check_va2pa>
f01028bc:	85 c0                	test   %eax,%eax
f01028be:	74 19                	je     f01028d9 <mem_init+0x1202>
f01028c0:	68 60 7a 10 f0       	push   $0xf0107a60
f01028c5:	68 3f 7d 10 f0       	push   $0xf0107d3f
f01028ca:	68 10 04 00 00       	push   $0x410
f01028cf:	68 19 7d 10 f0       	push   $0xf0107d19
f01028d4:	e8 67 d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f01028d9:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f01028df:	89 f8                	mov    %edi,%eax
f01028e1:	e8 e4 e5 ff ff       	call   f0100eca <check_va2pa>
f01028e6:	83 f8 ff             	cmp    $0xffffffff,%eax
f01028e9:	74 19                	je     f0102904 <mem_init+0x122d>
f01028eb:	68 84 7a 10 f0       	push   $0xf0107a84
f01028f0:	68 3f 7d 10 f0       	push   $0xf0107d3f
f01028f5:	68 11 04 00 00       	push   $0x411
f01028fa:	68 19 7d 10 f0       	push   $0xf0107d19
f01028ff:	e8 3c d7 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102904:	83 ec 04             	sub    $0x4,%esp
f0102907:	6a 00                	push   $0x0
f0102909:	53                   	push   %ebx
f010290a:	57                   	push   %edi
f010290b:	e8 31 eb ff ff       	call   f0101441 <pgdir_walk>
f0102910:	83 c4 10             	add    $0x10,%esp
f0102913:	f6 00 1a             	testb  $0x1a,(%eax)
f0102916:	75 19                	jne    f0102931 <mem_init+0x125a>
f0102918:	68 b0 7a 10 f0       	push   $0xf0107ab0
f010291d:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102922:	68 13 04 00 00       	push   $0x413
f0102927:	68 19 7d 10 f0       	push   $0xf0107d19
f010292c:	e8 0f d7 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102931:	83 ec 04             	sub    $0x4,%esp
f0102934:	6a 00                	push   $0x0
f0102936:	53                   	push   %ebx
f0102937:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f010293d:	e8 ff ea ff ff       	call   f0101441 <pgdir_walk>
f0102942:	8b 00                	mov    (%eax),%eax
f0102944:	83 c4 10             	add    $0x10,%esp
f0102947:	83 e0 04             	and    $0x4,%eax
f010294a:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010294d:	74 19                	je     f0102968 <mem_init+0x1291>
f010294f:	68 f4 7a 10 f0       	push   $0xf0107af4
f0102954:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102959:	68 14 04 00 00       	push   $0x414
f010295e:	68 19 7d 10 f0       	push   $0xf0107d19
f0102963:	e8 d8 d6 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102968:	83 ec 04             	sub    $0x4,%esp
f010296b:	6a 00                	push   $0x0
f010296d:	53                   	push   %ebx
f010296e:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0102974:	e8 c8 ea ff ff       	call   f0101441 <pgdir_walk>
f0102979:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f010297f:	83 c4 0c             	add    $0xc,%esp
f0102982:	6a 00                	push   $0x0
f0102984:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102987:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f010298d:	e8 af ea ff ff       	call   f0101441 <pgdir_walk>
f0102992:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102998:	83 c4 0c             	add    $0xc,%esp
f010299b:	6a 00                	push   $0x0
f010299d:	56                   	push   %esi
f010299e:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f01029a4:	e8 98 ea ff ff       	call   f0101441 <pgdir_walk>
f01029a9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f01029af:	c7 04 24 11 80 10 f0 	movl   $0xf0108011,(%esp)
f01029b6:	e8 a3 11 00 00       	call   f0103b5e <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	n = npages * sizeof(struct PageInfo);
	n = ROUNDUP(n, PGSIZE);
f01029bb:	a1 88 1e 23 f0       	mov    0xf0231e88,%eax
f01029c0:	8d 0c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ecx
f01029c7:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	boot_map_region(kern_pgdir, UPAGES, n, PADDR(pages), PTE_U | PTE_P);
f01029cd:	a1 90 1e 23 f0       	mov    0xf0231e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01029d2:	83 c4 10             	add    $0x10,%esp
f01029d5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01029da:	77 15                	ja     f01029f1 <mem_init+0x131a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029dc:	50                   	push   %eax
f01029dd:	68 a8 6c 10 f0       	push   $0xf0106ca8
f01029e2:	68 b6 00 00 00       	push   $0xb6
f01029e7:	68 19 7d 10 f0       	push   $0xf0107d19
f01029ec:	e8 4f d6 ff ff       	call   f0100040 <_panic>
f01029f1:	83 ec 08             	sub    $0x8,%esp
f01029f4:	6a 05                	push   $0x5
f01029f6:	05 00 00 00 10       	add    $0x10000000,%eax
f01029fb:	50                   	push   %eax
f01029fc:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102a01:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102a06:	e8 c9 ea ff ff       	call   f01014d4 <boot_map_region>
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	n = NENV * sizeof(struct Env);
	n = ROUNDUP(n, PGSIZE);
	boot_map_region(kern_pgdir, UENVS, n, PADDR(envs), PTE_U | PTE_P);
f0102a0b:	a1 48 12 23 f0       	mov    0xf0231248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a10:	83 c4 10             	add    $0x10,%esp
f0102a13:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a18:	77 15                	ja     f0102a2f <mem_init+0x1358>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a1a:	50                   	push   %eax
f0102a1b:	68 a8 6c 10 f0       	push   $0xf0106ca8
f0102a20:	68 c0 00 00 00       	push   $0xc0
f0102a25:	68 19 7d 10 f0       	push   $0xf0107d19
f0102a2a:	e8 11 d6 ff ff       	call   f0100040 <_panic>
f0102a2f:	83 ec 08             	sub    $0x8,%esp
f0102a32:	6a 05                	push   $0x5
f0102a34:	05 00 00 00 10       	add    $0x10000000,%eax
f0102a39:	50                   	push   %eax
f0102a3a:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102a3f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102a44:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102a49:	e8 86 ea ff ff       	call   f01014d4 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a4e:	83 c4 10             	add    $0x10,%esp
f0102a51:	b8 00 80 11 f0       	mov    $0xf0118000,%eax
f0102a56:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a5b:	77 15                	ja     f0102a72 <mem_init+0x139b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a5d:	50                   	push   %eax
f0102a5e:	68 a8 6c 10 f0       	push   $0xf0106ca8
f0102a63:	68 cd 00 00 00       	push   $0xcd
f0102a68:	68 19 7d 10 f0       	push   $0xf0107d19
f0102a6d:	e8 ce d5 ff ff       	call   f0100040 <_panic>
	//     * [KSTACKTOP-KSTKSIZE, KSTACKTOP) -- backed by physical memory
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, 
f0102a72:	83 ec 08             	sub    $0x8,%esp
f0102a75:	6a 03                	push   $0x3
f0102a77:	68 00 80 11 00       	push   $0x118000
f0102a7c:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102a81:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102a86:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102a8b:	e8 44 ea ff ff       	call   f01014d4 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	n = (uint32_t)(-1) - KERNBASE + 1;
	boot_map_region(kern_pgdir, KERNBASE, n, 0, PTE_W | PTE_P);
f0102a90:	83 c4 08             	add    $0x8,%esp
f0102a93:	6a 03                	push   $0x3
f0102a95:	6a 00                	push   $0x0
f0102a97:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102a9c:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102aa1:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102aa6:	e8 29 ea ff ff       	call   f01014d4 <boot_map_region>
f0102aab:	c7 45 c4 00 30 23 f0 	movl   $0xf0233000,-0x3c(%ebp)
f0102ab2:	83 c4 10             	add    $0x10,%esp
f0102ab5:	bb 00 30 23 f0       	mov    $0xf0233000,%ebx
f0102aba:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102abf:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102ac5:	77 15                	ja     f0102adc <mem_init+0x1405>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ac7:	53                   	push   %ebx
f0102ac8:	68 a8 6c 10 f0       	push   $0xf0106ca8
f0102acd:	68 0d 01 00 00       	push   $0x10d
f0102ad2:	68 19 7d 10 f0       	push   $0xf0107d19
f0102ad7:	e8 64 d5 ff ff       	call   f0100040 <_panic>
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	int i;
	for (i = 0; i < NCPU; i++) {
		intptr_t kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
		boot_map_region(kern_pgdir, kstacktop_i - KSTKSIZE, KSTKSIZE, 
f0102adc:	83 ec 08             	sub    $0x8,%esp
f0102adf:	6a 03                	push   $0x3
f0102ae1:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102ae7:	50                   	push   %eax
f0102ae8:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102aed:	89 f2                	mov    %esi,%edx
f0102aef:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102af4:	e8 db e9 ff ff       	call   f01014d4 <boot_map_region>
f0102af9:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102aff:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//          -- not backed; so if the kernel overflows its stack,
	//             it will fault rather than overwrite another CPU's stack.
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	int i;
	for (i = 0; i < NCPU; i++) {
f0102b05:	83 c4 10             	add    $0x10,%esp
f0102b08:	b8 00 30 27 f0       	mov    $0xf0273000,%eax
f0102b0d:	39 d8                	cmp    %ebx,%eax
f0102b0f:	75 ae                	jne    f0102abf <mem_init+0x13e8>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102b11:	8b 3d 8c 1e 23 f0    	mov    0xf0231e8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102b17:	a1 88 1e 23 f0       	mov    0xf0231e88,%eax
f0102b1c:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102b1f:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102b26:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102b2b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102b2e:	8b 35 90 1e 23 f0    	mov    0xf0231e90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b34:	89 75 d0             	mov    %esi,-0x30(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102b37:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102b3c:	eb 55                	jmp    f0102b93 <mem_init+0x14bc>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102b3e:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102b44:	89 f8                	mov    %edi,%eax
f0102b46:	e8 7f e3 ff ff       	call   f0100eca <check_va2pa>
f0102b4b:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102b52:	77 15                	ja     f0102b69 <mem_init+0x1492>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b54:	56                   	push   %esi
f0102b55:	68 a8 6c 10 f0       	push   $0xf0106ca8
f0102b5a:	68 2b 03 00 00       	push   $0x32b
f0102b5f:	68 19 7d 10 f0       	push   $0xf0107d19
f0102b64:	e8 d7 d4 ff ff       	call   f0100040 <_panic>
f0102b69:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f0102b70:	39 c2                	cmp    %eax,%edx
f0102b72:	74 19                	je     f0102b8d <mem_init+0x14b6>
f0102b74:	68 28 7b 10 f0       	push   $0xf0107b28
f0102b79:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102b7e:	68 2b 03 00 00       	push   $0x32b
f0102b83:	68 19 7d 10 f0       	push   $0xf0107d19
f0102b88:	e8 b3 d4 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102b8d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102b93:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102b96:	77 a6                	ja     f0102b3e <mem_init+0x1467>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102b98:	8b 35 48 12 23 f0    	mov    0xf0231248,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b9e:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102ba1:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102ba6:	89 da                	mov    %ebx,%edx
f0102ba8:	89 f8                	mov    %edi,%eax
f0102baa:	e8 1b e3 ff ff       	call   f0100eca <check_va2pa>
f0102baf:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102bb6:	77 15                	ja     f0102bcd <mem_init+0x14f6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102bb8:	56                   	push   %esi
f0102bb9:	68 a8 6c 10 f0       	push   $0xf0106ca8
f0102bbe:	68 30 03 00 00       	push   $0x330
f0102bc3:	68 19 7d 10 f0       	push   $0xf0107d19
f0102bc8:	e8 73 d4 ff ff       	call   f0100040 <_panic>
f0102bcd:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f0102bd4:	39 d0                	cmp    %edx,%eax
f0102bd6:	74 19                	je     f0102bf1 <mem_init+0x151a>
f0102bd8:	68 5c 7b 10 f0       	push   $0xf0107b5c
f0102bdd:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102be2:	68 30 03 00 00       	push   $0x330
f0102be7:	68 19 7d 10 f0       	push   $0xf0107d19
f0102bec:	e8 4f d4 ff ff       	call   f0100040 <_panic>
f0102bf1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102bf7:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102bfd:	75 a7                	jne    f0102ba6 <mem_init+0x14cf>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102bff:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102c02:	c1 e6 0c             	shl    $0xc,%esi
f0102c05:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102c0a:	eb 30                	jmp    f0102c3c <mem_init+0x1565>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102c0c:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102c12:	89 f8                	mov    %edi,%eax
f0102c14:	e8 b1 e2 ff ff       	call   f0100eca <check_va2pa>
f0102c19:	39 c3                	cmp    %eax,%ebx
f0102c1b:	74 19                	je     f0102c36 <mem_init+0x155f>
f0102c1d:	68 90 7b 10 f0       	push   $0xf0107b90
f0102c22:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102c27:	68 34 03 00 00       	push   $0x334
f0102c2c:	68 19 7d 10 f0       	push   $0xf0107d19
f0102c31:	e8 0a d4 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102c36:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102c3c:	39 f3                	cmp    %esi,%ebx
f0102c3e:	72 cc                	jb     f0102c0c <mem_init+0x1535>
f0102c40:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102c45:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0102c48:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0102c4b:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102c4e:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f0102c54:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0102c57:	89 c3                	mov    %eax,%ebx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102c59:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102c5c:	05 00 80 00 20       	add    $0x20008000,%eax
f0102c61:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102c64:	89 da                	mov    %ebx,%edx
f0102c66:	89 f8                	mov    %edi,%eax
f0102c68:	e8 5d e2 ff ff       	call   f0100eca <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c6d:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102c73:	77 15                	ja     f0102c8a <mem_init+0x15b3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c75:	56                   	push   %esi
f0102c76:	68 a8 6c 10 f0       	push   $0xf0106ca8
f0102c7b:	68 3c 03 00 00       	push   $0x33c
f0102c80:	68 19 7d 10 f0       	push   $0xf0107d19
f0102c85:	e8 b6 d3 ff ff       	call   f0100040 <_panic>
f0102c8a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102c8d:	8d 94 0b 00 30 23 f0 	lea    -0xfdcd000(%ebx,%ecx,1),%edx
f0102c94:	39 d0                	cmp    %edx,%eax
f0102c96:	74 19                	je     f0102cb1 <mem_init+0x15da>
f0102c98:	68 b8 7b 10 f0       	push   $0xf0107bb8
f0102c9d:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102ca2:	68 3c 03 00 00       	push   $0x33c
f0102ca7:	68 19 7d 10 f0       	push   $0xf0107d19
f0102cac:	e8 8f d3 ff ff       	call   f0100040 <_panic>
f0102cb1:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102cb7:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0102cba:	75 a8                	jne    f0102c64 <mem_init+0x158d>
f0102cbc:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102cbf:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f0102cc5:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102cc8:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102cca:	89 da                	mov    %ebx,%edx
f0102ccc:	89 f8                	mov    %edi,%eax
f0102cce:	e8 f7 e1 ff ff       	call   f0100eca <check_va2pa>
f0102cd3:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102cd6:	74 19                	je     f0102cf1 <mem_init+0x161a>
f0102cd8:	68 00 7c 10 f0       	push   $0xf0107c00
f0102cdd:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102ce2:	68 3e 03 00 00       	push   $0x33e
f0102ce7:	68 19 7d 10 f0       	push   $0xf0107d19
f0102cec:	e8 4f d3 ff ff       	call   f0100040 <_panic>
f0102cf1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102cf7:	39 de                	cmp    %ebx,%esi
f0102cf9:	75 cf                	jne    f0102cca <mem_init+0x15f3>
f0102cfb:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102cfe:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f0102d05:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f0102d0c:	81 c6 00 80 00 00    	add    $0x8000,%esi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102d12:	81 fe 00 30 27 f0    	cmp    $0xf0273000,%esi
f0102d18:	0f 85 2d ff ff ff    	jne    f0102c4b <mem_init+0x1574>
f0102d1e:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d23:	eb 2a                	jmp    f0102d4f <mem_init+0x1678>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102d25:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102d2b:	83 fa 04             	cmp    $0x4,%edx
f0102d2e:	77 1f                	ja     f0102d4f <mem_init+0x1678>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102d30:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102d34:	75 7e                	jne    f0102db4 <mem_init+0x16dd>
f0102d36:	68 2a 80 10 f0       	push   $0xf010802a
f0102d3b:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102d40:	68 49 03 00 00       	push   $0x349
f0102d45:	68 19 7d 10 f0       	push   $0xf0107d19
f0102d4a:	e8 f1 d2 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102d4f:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102d54:	76 3f                	jbe    f0102d95 <mem_init+0x16be>
				assert(pgdir[i] & PTE_P);
f0102d56:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102d59:	f6 c2 01             	test   $0x1,%dl
f0102d5c:	75 19                	jne    f0102d77 <mem_init+0x16a0>
f0102d5e:	68 2a 80 10 f0       	push   $0xf010802a
f0102d63:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102d68:	68 4d 03 00 00       	push   $0x34d
f0102d6d:	68 19 7d 10 f0       	push   $0xf0107d19
f0102d72:	e8 c9 d2 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102d77:	f6 c2 02             	test   $0x2,%dl
f0102d7a:	75 38                	jne    f0102db4 <mem_init+0x16dd>
f0102d7c:	68 3b 80 10 f0       	push   $0xf010803b
f0102d81:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102d86:	68 4e 03 00 00       	push   $0x34e
f0102d8b:	68 19 7d 10 f0       	push   $0xf0107d19
f0102d90:	e8 ab d2 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102d95:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102d99:	74 19                	je     f0102db4 <mem_init+0x16dd>
f0102d9b:	68 4c 80 10 f0       	push   $0xf010804c
f0102da0:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102da5:	68 50 03 00 00       	push   $0x350
f0102daa:	68 19 7d 10 f0       	push   $0xf0107d19
f0102daf:	e8 8c d2 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102db4:	83 c0 01             	add    $0x1,%eax
f0102db7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102dbc:	0f 86 63 ff ff ff    	jbe    f0102d25 <mem_init+0x164e>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102dc2:	83 ec 0c             	sub    $0xc,%esp
f0102dc5:	68 24 7c 10 f0       	push   $0xf0107c24
f0102dca:	e8 8f 0d 00 00       	call   f0103b5e <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102dcf:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102dd4:	83 c4 10             	add    $0x10,%esp
f0102dd7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ddc:	77 15                	ja     f0102df3 <mem_init+0x171c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102dde:	50                   	push   %eax
f0102ddf:	68 a8 6c 10 f0       	push   $0xf0106ca8
f0102de4:	68 e6 00 00 00       	push   $0xe6
f0102de9:	68 19 7d 10 f0       	push   $0xf0107d19
f0102dee:	e8 4d d2 ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102df3:	05 00 00 00 10       	add    $0x10000000,%eax
f0102df8:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102dfb:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e00:	e8 a6 e1 ff ff       	call   f0100fab <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102e05:	0f 20 c0             	mov    %cr0,%eax
f0102e08:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102e0b:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102e10:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102e13:	83 ec 0c             	sub    $0xc,%esp
f0102e16:	6a 00                	push   $0x0
f0102e18:	e8 1a e5 ff ff       	call   f0101337 <page_alloc>
f0102e1d:	89 c3                	mov    %eax,%ebx
f0102e1f:	83 c4 10             	add    $0x10,%esp
f0102e22:	85 c0                	test   %eax,%eax
f0102e24:	75 19                	jne    f0102e3f <mem_init+0x1768>
f0102e26:	68 36 7e 10 f0       	push   $0xf0107e36
f0102e2b:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102e30:	68 29 04 00 00       	push   $0x429
f0102e35:	68 19 7d 10 f0       	push   $0xf0107d19
f0102e3a:	e8 01 d2 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102e3f:	83 ec 0c             	sub    $0xc,%esp
f0102e42:	6a 00                	push   $0x0
f0102e44:	e8 ee e4 ff ff       	call   f0101337 <page_alloc>
f0102e49:	89 c7                	mov    %eax,%edi
f0102e4b:	83 c4 10             	add    $0x10,%esp
f0102e4e:	85 c0                	test   %eax,%eax
f0102e50:	75 19                	jne    f0102e6b <mem_init+0x1794>
f0102e52:	68 4c 7e 10 f0       	push   $0xf0107e4c
f0102e57:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102e5c:	68 2a 04 00 00       	push   $0x42a
f0102e61:	68 19 7d 10 f0       	push   $0xf0107d19
f0102e66:	e8 d5 d1 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102e6b:	83 ec 0c             	sub    $0xc,%esp
f0102e6e:	6a 00                	push   $0x0
f0102e70:	e8 c2 e4 ff ff       	call   f0101337 <page_alloc>
f0102e75:	89 c6                	mov    %eax,%esi
f0102e77:	83 c4 10             	add    $0x10,%esp
f0102e7a:	85 c0                	test   %eax,%eax
f0102e7c:	75 19                	jne    f0102e97 <mem_init+0x17c0>
f0102e7e:	68 62 7e 10 f0       	push   $0xf0107e62
f0102e83:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102e88:	68 2b 04 00 00       	push   $0x42b
f0102e8d:	68 19 7d 10 f0       	push   $0xf0107d19
f0102e92:	e8 a9 d1 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0102e97:	83 ec 0c             	sub    $0xc,%esp
f0102e9a:	53                   	push   %ebx
f0102e9b:	e8 07 e5 ff ff       	call   f01013a7 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102ea0:	89 f8                	mov    %edi,%eax
f0102ea2:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0102ea8:	c1 f8 03             	sar    $0x3,%eax
f0102eab:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102eae:	89 c2                	mov    %eax,%edx
f0102eb0:	c1 ea 0c             	shr    $0xc,%edx
f0102eb3:	83 c4 10             	add    $0x10,%esp
f0102eb6:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f0102ebc:	72 12                	jb     f0102ed0 <mem_init+0x17f9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102ebe:	50                   	push   %eax
f0102ebf:	68 84 6c 10 f0       	push   $0xf0106c84
f0102ec4:	6a 58                	push   $0x58
f0102ec6:	68 25 7d 10 f0       	push   $0xf0107d25
f0102ecb:	e8 70 d1 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102ed0:	83 ec 04             	sub    $0x4,%esp
f0102ed3:	68 00 10 00 00       	push   $0x1000
f0102ed8:	6a 01                	push   $0x1
f0102eda:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102edf:	50                   	push   %eax
f0102ee0:	e8 d1 30 00 00       	call   f0105fb6 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102ee5:	89 f0                	mov    %esi,%eax
f0102ee7:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0102eed:	c1 f8 03             	sar    $0x3,%eax
f0102ef0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ef3:	89 c2                	mov    %eax,%edx
f0102ef5:	c1 ea 0c             	shr    $0xc,%edx
f0102ef8:	83 c4 10             	add    $0x10,%esp
f0102efb:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f0102f01:	72 12                	jb     f0102f15 <mem_init+0x183e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102f03:	50                   	push   %eax
f0102f04:	68 84 6c 10 f0       	push   $0xf0106c84
f0102f09:	6a 58                	push   $0x58
f0102f0b:	68 25 7d 10 f0       	push   $0xf0107d25
f0102f10:	e8 2b d1 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102f15:	83 ec 04             	sub    $0x4,%esp
f0102f18:	68 00 10 00 00       	push   $0x1000
f0102f1d:	6a 02                	push   $0x2
f0102f1f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102f24:	50                   	push   %eax
f0102f25:	e8 8c 30 00 00       	call   f0105fb6 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102f2a:	6a 02                	push   $0x2
f0102f2c:	68 00 10 00 00       	push   $0x1000
f0102f31:	57                   	push   %edi
f0102f32:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0102f38:	e8 d0 e6 ff ff       	call   f010160d <page_insert>
	assert(pp1->pp_ref == 1);
f0102f3d:	83 c4 20             	add    $0x20,%esp
f0102f40:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102f45:	74 19                	je     f0102f60 <mem_init+0x1889>
f0102f47:	68 33 7f 10 f0       	push   $0xf0107f33
f0102f4c:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102f51:	68 30 04 00 00       	push   $0x430
f0102f56:	68 19 7d 10 f0       	push   $0xf0107d19
f0102f5b:	e8 e0 d0 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102f60:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102f67:	01 01 01 
f0102f6a:	74 19                	je     f0102f85 <mem_init+0x18ae>
f0102f6c:	68 44 7c 10 f0       	push   $0xf0107c44
f0102f71:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102f76:	68 31 04 00 00       	push   $0x431
f0102f7b:	68 19 7d 10 f0       	push   $0xf0107d19
f0102f80:	e8 bb d0 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102f85:	6a 02                	push   $0x2
f0102f87:	68 00 10 00 00       	push   $0x1000
f0102f8c:	56                   	push   %esi
f0102f8d:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f0102f93:	e8 75 e6 ff ff       	call   f010160d <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102f98:	83 c4 10             	add    $0x10,%esp
f0102f9b:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102fa2:	02 02 02 
f0102fa5:	74 19                	je     f0102fc0 <mem_init+0x18e9>
f0102fa7:	68 68 7c 10 f0       	push   $0xf0107c68
f0102fac:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102fb1:	68 33 04 00 00       	push   $0x433
f0102fb6:	68 19 7d 10 f0       	push   $0xf0107d19
f0102fbb:	e8 80 d0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102fc0:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102fc5:	74 19                	je     f0102fe0 <mem_init+0x1909>
f0102fc7:	68 55 7f 10 f0       	push   $0xf0107f55
f0102fcc:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102fd1:	68 34 04 00 00       	push   $0x434
f0102fd6:	68 19 7d 10 f0       	push   $0xf0107d19
f0102fdb:	e8 60 d0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102fe0:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102fe5:	74 19                	je     f0103000 <mem_init+0x1929>
f0102fe7:	68 bf 7f 10 f0       	push   $0xf0107fbf
f0102fec:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102ff1:	68 35 04 00 00       	push   $0x435
f0102ff6:	68 19 7d 10 f0       	push   $0xf0107d19
f0102ffb:	e8 40 d0 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0103000:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0103007:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010300a:	89 f0                	mov    %esi,%eax
f010300c:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0103012:	c1 f8 03             	sar    $0x3,%eax
f0103015:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103018:	89 c2                	mov    %eax,%edx
f010301a:	c1 ea 0c             	shr    $0xc,%edx
f010301d:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f0103023:	72 12                	jb     f0103037 <mem_init+0x1960>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103025:	50                   	push   %eax
f0103026:	68 84 6c 10 f0       	push   $0xf0106c84
f010302b:	6a 58                	push   $0x58
f010302d:	68 25 7d 10 f0       	push   $0xf0107d25
f0103032:	e8 09 d0 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103037:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f010303e:	03 03 03 
f0103041:	74 19                	je     f010305c <mem_init+0x1985>
f0103043:	68 8c 7c 10 f0       	push   $0xf0107c8c
f0103048:	68 3f 7d 10 f0       	push   $0xf0107d3f
f010304d:	68 37 04 00 00       	push   $0x437
f0103052:	68 19 7d 10 f0       	push   $0xf0107d19
f0103057:	e8 e4 cf ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f010305c:	83 ec 08             	sub    $0x8,%esp
f010305f:	68 00 10 00 00       	push   $0x1000
f0103064:	ff 35 8c 1e 23 f0    	pushl  0xf0231e8c
f010306a:	e8 4e e5 ff ff       	call   f01015bd <page_remove>
	assert(pp2->pp_ref == 0);
f010306f:	83 c4 10             	add    $0x10,%esp
f0103072:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0103077:	74 19                	je     f0103092 <mem_init+0x19bb>
f0103079:	68 8d 7f 10 f0       	push   $0xf0107f8d
f010307e:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0103083:	68 39 04 00 00       	push   $0x439
f0103088:	68 19 7d 10 f0       	push   $0xf0107d19
f010308d:	e8 ae cf ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103092:	8b 0d 8c 1e 23 f0    	mov    0xf0231e8c,%ecx
f0103098:	8b 11                	mov    (%ecx),%edx
f010309a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01030a0:	89 d8                	mov    %ebx,%eax
f01030a2:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f01030a8:	c1 f8 03             	sar    $0x3,%eax
f01030ab:	c1 e0 0c             	shl    $0xc,%eax
f01030ae:	39 c2                	cmp    %eax,%edx
f01030b0:	74 19                	je     f01030cb <mem_init+0x19f4>
f01030b2:	68 14 76 10 f0       	push   $0xf0107614
f01030b7:	68 3f 7d 10 f0       	push   $0xf0107d3f
f01030bc:	68 3c 04 00 00       	push   $0x43c
f01030c1:	68 19 7d 10 f0       	push   $0xf0107d19
f01030c6:	e8 75 cf ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f01030cb:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01030d1:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01030d6:	74 19                	je     f01030f1 <mem_init+0x1a1a>
f01030d8:	68 44 7f 10 f0       	push   $0xf0107f44
f01030dd:	68 3f 7d 10 f0       	push   $0xf0107d3f
f01030e2:	68 3e 04 00 00       	push   $0x43e
f01030e7:	68 19 7d 10 f0       	push   $0xf0107d19
f01030ec:	e8 4f cf ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f01030f1:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f01030f7:	83 ec 0c             	sub    $0xc,%esp
f01030fa:	53                   	push   %ebx
f01030fb:	e8 a7 e2 ff ff       	call   f01013a7 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103100:	c7 04 24 b8 7c 10 f0 	movl   $0xf0107cb8,(%esp)
f0103107:	e8 52 0a 00 00       	call   f0103b5e <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f010310c:	83 c4 10             	add    $0x10,%esp
f010310f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103112:	5b                   	pop    %ebx
f0103113:	5e                   	pop    %esi
f0103114:	5f                   	pop    %edi
f0103115:	5d                   	pop    %ebp
f0103116:	c3                   	ret    

f0103117 <user_mem_check>:
	return 0;
}

int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0103117:	55                   	push   %ebp
f0103118:	89 e5                	mov    %esp,%ebp
f010311a:	57                   	push   %edi
f010311b:	56                   	push   %esi
f010311c:	53                   	push   %ebx
f010311d:	83 ec 20             	sub    $0x20,%esp
f0103120:	8b 7d 08             	mov    0x8(%ebp),%edi
	uintptr_t va_begin = (uintptr_t) va, va_end = va_begin + len;
f0103123:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103126:	03 45 10             	add    0x10(%ebp),%eax
f0103129:	89 45 e4             	mov    %eax,-0x1c(%ebp)
//

static inline int
_user_mem_check(struct Env *env, const void* va, int perm)
{
	pte_t *pte = pgdir_walk(env->env_pgdir, va, 0);
f010312c:	6a 00                	push   $0x0
f010312e:	ff 75 0c             	pushl  0xc(%ebp)
f0103131:	ff 77 60             	pushl  0x60(%edi)
f0103134:	e8 08 e3 ff ff       	call   f0101441 <pgdir_walk>
	if (pte == NULL || (*pte & (perm | PTE_P)) != (perm | PTE_P)) {
f0103139:	83 c4 10             	add    $0x10,%esp
f010313c:	85 c0                	test   %eax,%eax
f010313e:	74 1f                	je     f010315f <user_mem_check+0x48>
f0103140:	8b 75 14             	mov    0x14(%ebp),%esi
f0103143:	83 ce 01             	or     $0x1,%esi
f0103146:	89 f1                	mov    %esi,%ecx
f0103148:	23 08                	and    (%eax),%ecx
f010314a:	89 c8                	mov    %ecx,%eax
	
	int ret = _user_mem_check(env, va, perm);
	if (ret < 0) 
		return ret;
	
	va_begin = ROUNDUP(va_begin, PGSIZE);
f010314c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010314f:	8d 99 ff 0f 00 00    	lea    0xfff(%ecx),%ebx
f0103155:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx

static inline int
_user_mem_check(struct Env *env, const void* va, int perm)
{
	pte_t *pte = pgdir_walk(env->env_pgdir, va, 0);
	if (pte == NULL || (*pte & (perm | PTE_P)) != (perm | PTE_P)) {
f010315b:	39 c6                	cmp    %eax,%esi
f010315d:	74 39                	je     f0103198 <user_mem_check+0x81>
		user_mem_check_addr = (uintptr_t) va;
f010315f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103162:	a3 3c 12 23 f0       	mov    %eax,0xf023123c
		return -E_FAULT;
f0103167:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010316c:	eb 3e                	jmp    f01031ac <user_mem_check+0x95>
//

static inline int
_user_mem_check(struct Env *env, const void* va, int perm)
{
	pte_t *pte = pgdir_walk(env->env_pgdir, va, 0);
f010316e:	83 ec 04             	sub    $0x4,%esp
f0103171:	6a 00                	push   $0x0
f0103173:	53                   	push   %ebx
f0103174:	ff 77 60             	pushl  0x60(%edi)
f0103177:	e8 c5 e2 ff ff       	call   f0101441 <pgdir_walk>
	if (pte == NULL || (*pte & (perm | PTE_P)) != (perm | PTE_P)) {
f010317c:	83 c4 10             	add    $0x10,%esp
f010317f:	85 c0                	test   %eax,%eax
f0103181:	74 08                	je     f010318b <user_mem_check+0x74>
f0103183:	89 f2                	mov    %esi,%edx
f0103185:	23 10                	and    (%eax),%edx
f0103187:	39 d6                	cmp    %edx,%esi
f0103189:	74 19                	je     f01031a4 <user_mem_check+0x8d>
		user_mem_check_addr = (uintptr_t) va;
f010318b:	89 1d 3c 12 23 f0    	mov    %ebx,0xf023123c
		return -E_FAULT;
f0103191:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103196:	eb 14                	jmp    f01031ac <user_mem_check+0x95>
	int ret = _user_mem_check(env, va, perm);
	if (ret < 0) 
		return ret;
	
	va_begin = ROUNDUP(va_begin, PGSIZE);
	for (; va_begin < va_end; va_begin += PGSIZE)
f0103198:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f010319b:	72 d1                	jb     f010316e <user_mem_check+0x57>
		if ((ret = _user_mem_check(env, (void *) va_begin, perm)) < 0)
			return ret;

	return ret;
f010319d:	b8 00 00 00 00       	mov    $0x0,%eax
f01031a2:	eb 08                	jmp    f01031ac <user_mem_check+0x95>
	int ret = _user_mem_check(env, va, perm);
	if (ret < 0) 
		return ret;
	
	va_begin = ROUNDUP(va_begin, PGSIZE);
	for (; va_begin < va_end; va_begin += PGSIZE)
f01031a4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01031aa:	eb ec                	jmp    f0103198 <user_mem_check+0x81>
		if ((ret = _user_mem_check(env, (void *) va_begin, perm)) < 0)
			return ret;

	return ret;
}
f01031ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01031af:	5b                   	pop    %ebx
f01031b0:	5e                   	pop    %esi
f01031b1:	5f                   	pop    %edi
f01031b2:	5d                   	pop    %ebp
f01031b3:	c3                   	ret    

f01031b4 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f01031b4:	55                   	push   %ebp
f01031b5:	89 e5                	mov    %esp,%ebp
f01031b7:	53                   	push   %ebx
f01031b8:	83 ec 04             	sub    $0x4,%esp
f01031bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01031be:	8b 45 14             	mov    0x14(%ebp),%eax
f01031c1:	83 c8 04             	or     $0x4,%eax
f01031c4:	50                   	push   %eax
f01031c5:	ff 75 10             	pushl  0x10(%ebp)
f01031c8:	ff 75 0c             	pushl  0xc(%ebp)
f01031cb:	53                   	push   %ebx
f01031cc:	e8 46 ff ff ff       	call   f0103117 <user_mem_check>
f01031d1:	83 c4 10             	add    $0x10,%esp
f01031d4:	85 c0                	test   %eax,%eax
f01031d6:	79 21                	jns    f01031f9 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f01031d8:	83 ec 04             	sub    $0x4,%esp
f01031db:	ff 35 3c 12 23 f0    	pushl  0xf023123c
f01031e1:	ff 73 48             	pushl  0x48(%ebx)
f01031e4:	68 e4 7c 10 f0       	push   $0xf0107ce4
f01031e9:	e8 70 09 00 00       	call   f0103b5e <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f01031ee:	89 1c 24             	mov    %ebx,(%esp)
f01031f1:	e8 78 06 00 00       	call   f010386e <env_destroy>
f01031f6:	83 c4 10             	add    $0x10,%esp
	}
}
f01031f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01031fc:	c9                   	leave  
f01031fd:	c3                   	ret    

f01031fe <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01031fe:	55                   	push   %ebp
f01031ff:	89 e5                	mov    %esp,%ebp
f0103201:	57                   	push   %edi
f0103202:	56                   	push   %esi
f0103203:	53                   	push   %ebx
f0103204:	83 ec 2c             	sub    $0x2c,%esp
f0103207:	89 c6                	mov    %eax,%esi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	char *sa = (char *) ROUNDDOWN(va, PGSIZE);
f0103209:	89 d3                	mov    %edx,%ebx
f010320b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	char *ea = (char *) ROUNDUP((char *) va + len, PGSIZE);
f0103211:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f0103218:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010321d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	
	if (ea > (char *) UTOP)
f0103220:	3d 00 00 c0 ee       	cmp    $0xeec00000,%eax
f0103225:	0f 86 85 00 00 00    	jbe    f01032b0 <region_alloc+0xb2>
		panic("region_alloc: attempting to alloc phys mem for vaddr above UTOP");
f010322b:	83 ec 04             	sub    $0x4,%esp
f010322e:	68 5c 80 10 f0       	push   $0xf010805c
f0103233:	68 26 01 00 00       	push   $0x126
f0103238:	68 16 81 10 f0       	push   $0xf0108116
f010323d:	e8 fe cd ff ff       	call   f0100040 <_panic>
	
	for (; sa < ea; sa += PGSIZE) {
		pte_t *pte;
		struct PageInfo *pp = page_lookup(e->env_pgdir, sa, &pte);
f0103242:	83 ec 04             	sub    $0x4,%esp
f0103245:	57                   	push   %edi
f0103246:	53                   	push   %ebx
f0103247:	ff 76 60             	pushl  0x60(%esi)
f010324a:	e8 d4 e2 ff ff       	call   f0101523 <page_lookup>
		if (pp != NULL)  
f010324f:	83 c4 10             	add    $0x10,%esp
f0103252:	85 c0                	test   %eax,%eax
f0103254:	75 52                	jne    f01032a8 <region_alloc+0xaa>
			continue; // panic("region_alloc: invalid address 0x%08p", sa);
		
		pp = page_alloc(0);
f0103256:	83 ec 0c             	sub    $0xc,%esp
f0103259:	6a 00                	push   $0x0
f010325b:	e8 d7 e0 ff ff       	call   f0101337 <page_alloc>
		if (pp == NULL)  
f0103260:	83 c4 10             	add    $0x10,%esp
f0103263:	85 c0                	test   %eax,%eax
f0103265:	75 17                	jne    f010327e <region_alloc+0x80>
			panic("region_alloc: out of memory for PG");
f0103267:	83 ec 04             	sub    $0x4,%esp
f010326a:	68 9c 80 10 f0       	push   $0xf010809c
f010326f:	68 30 01 00 00       	push   $0x130
f0103274:	68 16 81 10 f0       	push   $0xf0108116
f0103279:	e8 c2 cd ff ff       	call   f0100040 <_panic>
		
		if (page_insert(e->env_pgdir, pp, sa, PTE_W | PTE_U | PTE_P) < 0)
f010327e:	6a 07                	push   $0x7
f0103280:	53                   	push   %ebx
f0103281:	50                   	push   %eax
f0103282:	ff 76 60             	pushl  0x60(%esi)
f0103285:	e8 83 e3 ff ff       	call   f010160d <page_insert>
f010328a:	83 c4 10             	add    $0x10,%esp
f010328d:	85 c0                	test   %eax,%eax
f010328f:	79 17                	jns    f01032a8 <region_alloc+0xaa>
			panic("region_alloc: out of memory for PT");
f0103291:	83 ec 04             	sub    $0x4,%esp
f0103294:	68 c0 80 10 f0       	push   $0xf01080c0
f0103299:	68 33 01 00 00       	push   $0x133
f010329e:	68 16 81 10 f0       	push   $0xf0108116
f01032a3:	e8 98 cd ff ff       	call   f0100040 <_panic>
	char *ea = (char *) ROUNDUP((char *) va + len, PGSIZE);
	
	if (ea > (char *) UTOP)
		panic("region_alloc: attempting to alloc phys mem for vaddr above UTOP");
	
	for (; sa < ea; sa += PGSIZE) {
f01032a8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01032ae:	eb 03                	jmp    f01032b3 <region_alloc+0xb5>
		pte_t *pte;
		struct PageInfo *pp = page_lookup(e->env_pgdir, sa, &pte);
f01032b0:	8d 7d e4             	lea    -0x1c(%ebp),%edi
	char *ea = (char *) ROUNDUP((char *) va + len, PGSIZE);
	
	if (ea > (char *) UTOP)
		panic("region_alloc: attempting to alloc phys mem for vaddr above UTOP");
	
	for (; sa < ea; sa += PGSIZE) {
f01032b3:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f01032b6:	72 8a                	jb     f0103242 <region_alloc+0x44>
			panic("region_alloc: out of memory for PG");
		
		if (page_insert(e->env_pgdir, pp, sa, PTE_W | PTE_U | PTE_P) < 0)
			panic("region_alloc: out of memory for PT");
	}
}
f01032b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01032bb:	5b                   	pop    %ebx
f01032bc:	5e                   	pop    %esi
f01032bd:	5f                   	pop    %edi
f01032be:	5d                   	pop    %ebp
f01032bf:	c3                   	ret    

f01032c0 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01032c0:	55                   	push   %ebp
f01032c1:	89 e5                	mov    %esp,%ebp
f01032c3:	56                   	push   %esi
f01032c4:	53                   	push   %ebx
f01032c5:	8b 45 08             	mov    0x8(%ebp),%eax
f01032c8:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f01032cb:	85 c0                	test   %eax,%eax
f01032cd:	75 1a                	jne    f01032e9 <envid2env+0x29>
		*env_store = curenv;
f01032cf:	e8 02 33 00 00       	call   f01065d6 <cpunum>
f01032d4:	6b c0 74             	imul   $0x74,%eax,%eax
f01032d7:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f01032dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01032e0:	89 01                	mov    %eax,(%ecx)
		return 0;
f01032e2:	b8 00 00 00 00       	mov    $0x0,%eax
f01032e7:	eb 70                	jmp    f0103359 <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f01032e9:	89 c3                	mov    %eax,%ebx
f01032eb:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f01032f1:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f01032f4:	03 1d 48 12 23 f0    	add    0xf0231248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01032fa:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f01032fe:	74 05                	je     f0103305 <envid2env+0x45>
f0103300:	3b 43 48             	cmp    0x48(%ebx),%eax
f0103303:	74 10                	je     f0103315 <envid2env+0x55>
		*env_store = 0;
f0103305:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103308:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010330e:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103313:	eb 44                	jmp    f0103359 <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103315:	84 d2                	test   %dl,%dl
f0103317:	74 36                	je     f010334f <envid2env+0x8f>
f0103319:	e8 b8 32 00 00       	call   f01065d6 <cpunum>
f010331e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103321:	3b 98 28 20 23 f0    	cmp    -0xfdcdfd8(%eax),%ebx
f0103327:	74 26                	je     f010334f <envid2env+0x8f>
f0103329:	8b 73 4c             	mov    0x4c(%ebx),%esi
f010332c:	e8 a5 32 00 00       	call   f01065d6 <cpunum>
f0103331:	6b c0 74             	imul   $0x74,%eax,%eax
f0103334:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f010333a:	3b 70 48             	cmp    0x48(%eax),%esi
f010333d:	74 10                	je     f010334f <envid2env+0x8f>
		*env_store = 0;
f010333f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103342:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103348:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010334d:	eb 0a                	jmp    f0103359 <envid2env+0x99>
	}

	*env_store = e;
f010334f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103352:	89 18                	mov    %ebx,(%eax)
	return 0;
f0103354:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103359:	5b                   	pop    %ebx
f010335a:	5e                   	pop    %esi
f010335b:	5d                   	pop    %ebp
f010335c:	c3                   	ret    

f010335d <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f010335d:	55                   	push   %ebp
f010335e:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0103360:	b8 20 23 12 f0       	mov    $0xf0122320,%eax
f0103365:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0103368:	b8 23 00 00 00       	mov    $0x23,%eax
f010336d:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f010336f:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0103371:	b8 10 00 00 00       	mov    $0x10,%eax
f0103376:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0103378:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f010337a:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f010337c:	ea 83 33 10 f0 08 00 	ljmp   $0x8,$0xf0103383
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0103383:	b8 00 00 00 00       	mov    $0x0,%eax
f0103388:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f010338b:	5d                   	pop    %ebp
f010338c:	c3                   	ret    

f010338d <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f010338d:	55                   	push   %ebp
f010338e:	89 e5                	mov    %esp,%ebp
f0103390:	56                   	push   %esi
f0103391:	53                   	push   %ebx
	// Set up envs array
	int i;
	for (i = NENV; i >= 0; i--) {
		envs[i].env_id = 0;
f0103392:	8b 35 48 12 23 f0    	mov    0xf0231248,%esi
f0103398:	8b 15 4c 12 23 f0    	mov    0xf023124c,%edx
f010339e:	8d 86 00 f0 01 00    	lea    0x1f000(%esi),%eax
f01033a4:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f01033a7:	89 c1                	mov    %eax,%ecx
f01033a9:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_status = ENV_FREE;
f01033b0:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_link = env_free_list;
f01033b7:	89 50 44             	mov    %edx,0x44(%eax)
f01033ba:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = &envs[i];
f01033bd:	89 ca                	mov    %ecx,%edx
void
env_init(void)
{
	// Set up envs array
	int i;
	for (i = NENV; i >= 0; i--) {
f01033bf:	39 d8                	cmp    %ebx,%eax
f01033c1:	75 e4                	jne    f01033a7 <env_init+0x1a>
f01033c3:	89 35 4c 12 23 f0    	mov    %esi,0xf023124c
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}

	// Per-CPU part of the initialization
	env_init_percpu();
f01033c9:	e8 8f ff ff ff       	call   f010335d <env_init_percpu>
}
f01033ce:	5b                   	pop    %ebx
f01033cf:	5e                   	pop    %esi
f01033d0:	5d                   	pop    %ebp
f01033d1:	c3                   	ret    

f01033d2 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f01033d2:	55                   	push   %ebp
f01033d3:	89 e5                	mov    %esp,%ebp
f01033d5:	53                   	push   %ebx
f01033d6:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f01033d9:	8b 1d 4c 12 23 f0    	mov    0xf023124c,%ebx
f01033df:	85 db                	test   %ebx,%ebx
f01033e1:	0f 84 73 01 00 00    	je     f010355a <env_alloc+0x188>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f01033e7:	83 ec 0c             	sub    $0xc,%esp
f01033ea:	6a 01                	push   $0x1
f01033ec:	e8 46 df ff ff       	call   f0101337 <page_alloc>
f01033f1:	83 c4 10             	add    $0x10,%esp
f01033f4:	85 c0                	test   %eax,%eax
f01033f6:	0f 84 65 01 00 00    	je     f0103561 <env_alloc+0x18f>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01033fc:	89 c2                	mov    %eax,%edx
f01033fe:	2b 15 90 1e 23 f0    	sub    0xf0231e90,%edx
f0103404:	c1 fa 03             	sar    $0x3,%edx
f0103407:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010340a:	89 d1                	mov    %edx,%ecx
f010340c:	c1 e9 0c             	shr    $0xc,%ecx
f010340f:	3b 0d 88 1e 23 f0    	cmp    0xf0231e88,%ecx
f0103415:	72 12                	jb     f0103429 <env_alloc+0x57>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103417:	52                   	push   %edx
f0103418:	68 84 6c 10 f0       	push   $0xf0106c84
f010341d:	6a 58                	push   $0x58
f010341f:	68 25 7d 10 f0       	push   $0xf0107d25
f0103424:	e8 17 cc ff ff       	call   f0100040 <_panic>
	//    - Note: In general, pp_ref is not maintained for
	//	physical pages mapped only above UTOP, but env_pgdir
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.
	e->env_pgdir = (pde_t *) page2kva(p);
f0103429:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010342f:	89 53 60             	mov    %edx,0x60(%ebx)
	p->pp_ref++;
f0103432:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f0103437:	b8 ec 0e 00 00       	mov    $0xeec,%eax
	
	for (i = PDX(UTOP); i < NPDENTRIES; i++)
		e->env_pgdir[i] = kern_pgdir[i];
f010343c:	8b 15 8c 1e 23 f0    	mov    0xf0231e8c,%edx
f0103442:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0103445:	8b 53 60             	mov    0x60(%ebx),%edx
f0103448:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f010344b:	83 c0 04             	add    $0x4,%eax
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.
	e->env_pgdir = (pde_t *) page2kva(p);
	p->pp_ref++;
	
	for (i = PDX(UTOP); i < NPDENTRIES; i++)
f010344e:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0103453:	75 e7                	jne    f010343c <env_alloc+0x6a>
		e->env_pgdir[i] = kern_pgdir[i];

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103455:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103458:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010345d:	77 15                	ja     f0103474 <env_alloc+0xa2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010345f:	50                   	push   %eax
f0103460:	68 a8 6c 10 f0       	push   $0xf0106ca8
f0103465:	68 c5 00 00 00       	push   $0xc5
f010346a:	68 16 81 10 f0       	push   $0xf0108116
f010346f:	e8 cc cb ff ff       	call   f0100040 <_panic>
f0103474:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010347a:	83 ca 05             	or     $0x5,%edx
f010347d:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103483:	8b 43 48             	mov    0x48(%ebx),%eax
f0103486:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f010348b:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103490:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103495:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103498:	89 da                	mov    %ebx,%edx
f010349a:	2b 15 48 12 23 f0    	sub    0xf0231248,%edx
f01034a0:	c1 fa 02             	sar    $0x2,%edx
f01034a3:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f01034a9:	09 d0                	or     %edx,%eax
f01034ab:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01034ae:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034b1:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01034b4:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01034bb:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01034c2:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01034c9:	83 ec 04             	sub    $0x4,%esp
f01034cc:	6a 44                	push   $0x44
f01034ce:	6a 00                	push   $0x0
f01034d0:	53                   	push   %ebx
f01034d1:	e8 e0 2a 00 00       	call   f0105fb6 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01034d6:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01034dc:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01034e2:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01034e8:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01034ef:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	e->env_tf.tf_eflags = FL_IF;
f01034f5:	c7 43 38 00 02 00 00 	movl   $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01034fc:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103503:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103507:	8b 43 44             	mov    0x44(%ebx),%eax
f010350a:	a3 4c 12 23 f0       	mov    %eax,0xf023124c
	*newenv_store = e;
f010350f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103512:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103514:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103517:	e8 ba 30 00 00       	call   f01065d6 <cpunum>
f010351c:	6b c0 74             	imul   $0x74,%eax,%eax
f010351f:	83 c4 10             	add    $0x10,%esp
f0103522:	ba 00 00 00 00       	mov    $0x0,%edx
f0103527:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f010352e:	74 11                	je     f0103541 <env_alloc+0x16f>
f0103530:	e8 a1 30 00 00       	call   f01065d6 <cpunum>
f0103535:	6b c0 74             	imul   $0x74,%eax,%eax
f0103538:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f010353e:	8b 50 48             	mov    0x48(%eax),%edx
f0103541:	83 ec 04             	sub    $0x4,%esp
f0103544:	53                   	push   %ebx
f0103545:	52                   	push   %edx
f0103546:	68 21 81 10 f0       	push   $0xf0108121
f010354b:	e8 0e 06 00 00       	call   f0103b5e <cprintf>
	return 0;
f0103550:	83 c4 10             	add    $0x10,%esp
f0103553:	b8 00 00 00 00       	mov    $0x0,%eax
f0103558:	eb 0c                	jmp    f0103566 <env_alloc+0x194>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f010355a:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010355f:	eb 05                	jmp    f0103566 <env_alloc+0x194>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103561:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103566:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103569:	c9                   	leave  
f010356a:	c3                   	ret    

f010356b <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f010356b:	55                   	push   %ebp
f010356c:	89 e5                	mov    %esp,%ebp
f010356e:	57                   	push   %edi
f010356f:	56                   	push   %esi
f0103570:	53                   	push   %ebx
f0103571:	83 ec 34             	sub    $0x34,%esp
f0103574:	8b 7d 08             	mov    0x8(%ebp),%edi
	struct Env *e;
	if (env_alloc(&e, 0) < 0 || e == NULL) 
f0103577:	6a 00                	push   $0x0
f0103579:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010357c:	50                   	push   %eax
f010357d:	e8 50 fe ff ff       	call   f01033d2 <env_alloc>
f0103582:	83 c4 10             	add    $0x10,%esp
f0103585:	85 c0                	test   %eax,%eax
f0103587:	78 0a                	js     f0103593 <env_create+0x28>
f0103589:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010358c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010358f:	85 c0                	test   %eax,%eax
f0103591:	75 17                	jne    f01035aa <env_create+0x3f>
		panic("env_create: fatal error when allocating a new env");
f0103593:	83 ec 04             	sub    $0x4,%esp
f0103596:	68 e4 80 10 f0       	push   $0xf01080e4
f010359b:	68 9a 01 00 00       	push   $0x19a
f01035a0:	68 16 81 10 f0       	push   $0xf0108116
f01035a5:	e8 96 ca ff ff       	call   f0100040 <_panic>
	e->env_type = type;
f01035aa:	8b 45 0c             	mov    0xc(%ebp),%eax
f01035ad:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01035b0:	89 41 50             	mov    %eax,0x50(%ecx)
	
	struct Elf *elf_hdr;
	struct Proghdr *ph, *eph;
	int i;

	lcr3(PADDR(e->env_pgdir));
f01035b3:	8b 41 60             	mov    0x60(%ecx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01035b6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01035bb:	77 15                	ja     f01035d2 <env_create+0x67>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01035bd:	50                   	push   %eax
f01035be:	68 a8 6c 10 f0       	push   $0xf0106ca8
f01035c3:	68 70 01 00 00       	push   $0x170
f01035c8:	68 16 81 10 f0       	push   $0xf0108116
f01035cd:	e8 6e ca ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01035d2:	05 00 00 00 10       	add    $0x10000000,%eax
f01035d7:	0f 22 d8             	mov    %eax,%cr3

	elf_hdr = (struct Elf *) binary;
	
	assert(elf_hdr->e_magic == ELF_MAGIC);
f01035da:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f01035e0:	74 19                	je     f01035fb <env_create+0x90>
f01035e2:	68 36 81 10 f0       	push   $0xf0108136
f01035e7:	68 3f 7d 10 f0       	push   $0xf0107d3f
f01035ec:	68 74 01 00 00       	push   $0x174
f01035f1:	68 16 81 10 f0       	push   $0xf0108116
f01035f6:	e8 45 ca ff ff       	call   f0100040 <_panic>
	
	ph = (struct Proghdr *) ((char *) elf_hdr + elf_hdr->e_phoff); 
f01035fb:	89 fb                	mov    %edi,%ebx
f01035fd:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + elf_hdr->e_phnum;
f0103600:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0103604:	c1 e6 05             	shl    $0x5,%esi
f0103607:	01 de                	add    %ebx,%esi
f0103609:	eb 62                	jmp    f010366d <env_create+0x102>

	for (; ph < eph; ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
f010360b:	83 3b 01             	cmpl   $0x1,(%ebx)
f010360e:	75 5a                	jne    f010366a <env_create+0xff>
			continue;
		
		assert(ph->p_filesz <= ph->p_memsz);
f0103610:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103613:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f0103616:	76 19                	jbe    f0103631 <env_create+0xc6>
f0103618:	68 54 81 10 f0       	push   $0xf0108154
f010361d:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0103622:	68 7d 01 00 00       	push   $0x17d
f0103627:	68 16 81 10 f0       	push   $0xf0108116
f010362c:	e8 0f ca ff ff       	call   f0100040 <_panic>
		
		region_alloc(e, (void *) ph->p_va, ph->p_memsz);
f0103631:	8b 53 08             	mov    0x8(%ebx),%edx
f0103634:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103637:	e8 c2 fb ff ff       	call   f01031fe <region_alloc>

		// current page directory should be e->env_pgdir
		memcpy((void *) ph->p_va, (char *) binary + ph->p_offset, ph->p_filesz);
f010363c:	83 ec 04             	sub    $0x4,%esp
f010363f:	ff 73 10             	pushl  0x10(%ebx)
f0103642:	89 f8                	mov    %edi,%eax
f0103644:	03 43 04             	add    0x4(%ebx),%eax
f0103647:	50                   	push   %eax
f0103648:	ff 73 08             	pushl  0x8(%ebx)
f010364b:	e8 1b 2a 00 00       	call   f010606b <memcpy>
		memset((void *) (ph->p_va + ph->p_filesz), 0, ph->p_memsz - ph->p_filesz);
f0103650:	8b 43 10             	mov    0x10(%ebx),%eax
f0103653:	83 c4 0c             	add    $0xc,%esp
f0103656:	8b 53 14             	mov    0x14(%ebx),%edx
f0103659:	29 c2                	sub    %eax,%edx
f010365b:	52                   	push   %edx
f010365c:	6a 00                	push   $0x0
f010365e:	03 43 08             	add    0x8(%ebx),%eax
f0103661:	50                   	push   %eax
f0103662:	e8 4f 29 00 00       	call   f0105fb6 <memset>
f0103667:	83 c4 10             	add    $0x10,%esp
	assert(elf_hdr->e_magic == ELF_MAGIC);
	
	ph = (struct Proghdr *) ((char *) elf_hdr + elf_hdr->e_phoff); 
	eph = ph + elf_hdr->e_phnum;

	for (; ph < eph; ph++) {
f010366a:	83 c3 20             	add    $0x20,%ebx
f010366d:	39 de                	cmp    %ebx,%esi
f010366f:	77 9a                	ja     f010360b <env_create+0xa0>
		memcpy((void *) ph->p_va, (char *) binary + ph->p_offset, ph->p_filesz);
		memset((void *) (ph->p_va + ph->p_filesz), 0, ph->p_memsz - ph->p_filesz);
	} 
	
	// set up entry point of the program
	e->env_tf.tf_eip = elf_hdr->e_entry;
f0103671:	8b 47 18             	mov    0x18(%edi),%eax
f0103674:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103677:	89 47 30             	mov    %eax,0x30(%edi)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f010367a:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010367f:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103684:	89 f8                	mov    %edi,%eax
f0103686:	e8 73 fb ff ff       	call   f01031fe <region_alloc>
	struct Env *e;
	if (env_alloc(&e, 0) < 0 || e == NULL) 
		panic("env_create: fatal error when allocating a new env");
	e->env_type = type;
	load_icode(e, binary);
}
f010368b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010368e:	5b                   	pop    %ebx
f010368f:	5e                   	pop    %esi
f0103690:	5f                   	pop    %edi
f0103691:	5d                   	pop    %ebp
f0103692:	c3                   	ret    

f0103693 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103693:	55                   	push   %ebp
f0103694:	89 e5                	mov    %esp,%ebp
f0103696:	57                   	push   %edi
f0103697:	56                   	push   %esi
f0103698:	53                   	push   %ebx
f0103699:	83 ec 1c             	sub    $0x1c,%esp
f010369c:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f010369f:	e8 32 2f 00 00       	call   f01065d6 <cpunum>
f01036a4:	6b c0 74             	imul   $0x74,%eax,%eax
f01036a7:	39 b8 28 20 23 f0    	cmp    %edi,-0xfdcdfd8(%eax)
f01036ad:	75 29                	jne    f01036d8 <env_free+0x45>
		lcr3(PADDR(kern_pgdir));
f01036af:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01036b4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01036b9:	77 15                	ja     f01036d0 <env_free+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036bb:	50                   	push   %eax
f01036bc:	68 a8 6c 10 f0       	push   $0xf0106ca8
f01036c1:	68 ad 01 00 00       	push   $0x1ad
f01036c6:	68 16 81 10 f0       	push   $0xf0108116
f01036cb:	e8 70 c9 ff ff       	call   f0100040 <_panic>
f01036d0:	05 00 00 00 10       	add    $0x10000000,%eax
f01036d5:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01036d8:	8b 5f 48             	mov    0x48(%edi),%ebx
f01036db:	e8 f6 2e 00 00       	call   f01065d6 <cpunum>
f01036e0:	6b c0 74             	imul   $0x74,%eax,%eax
f01036e3:	ba 00 00 00 00       	mov    $0x0,%edx
f01036e8:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f01036ef:	74 11                	je     f0103702 <env_free+0x6f>
f01036f1:	e8 e0 2e 00 00       	call   f01065d6 <cpunum>
f01036f6:	6b c0 74             	imul   $0x74,%eax,%eax
f01036f9:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f01036ff:	8b 50 48             	mov    0x48(%eax),%edx
f0103702:	83 ec 04             	sub    $0x4,%esp
f0103705:	53                   	push   %ebx
f0103706:	52                   	push   %edx
f0103707:	68 70 81 10 f0       	push   $0xf0108170
f010370c:	e8 4d 04 00 00       	call   f0103b5e <cprintf>
f0103711:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103714:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010371b:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010371e:	89 d0                	mov    %edx,%eax
f0103720:	c1 e0 02             	shl    $0x2,%eax
f0103723:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103726:	8b 47 60             	mov    0x60(%edi),%eax
f0103729:	8b 34 90             	mov    (%eax,%edx,4),%esi
f010372c:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103732:	0f 84 a8 00 00 00    	je     f01037e0 <env_free+0x14d>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103738:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010373e:	89 f0                	mov    %esi,%eax
f0103740:	c1 e8 0c             	shr    $0xc,%eax
f0103743:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103746:	39 05 88 1e 23 f0    	cmp    %eax,0xf0231e88
f010374c:	77 15                	ja     f0103763 <env_free+0xd0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010374e:	56                   	push   %esi
f010374f:	68 84 6c 10 f0       	push   $0xf0106c84
f0103754:	68 bc 01 00 00       	push   $0x1bc
f0103759:	68 16 81 10 f0       	push   $0xf0108116
f010375e:	e8 dd c8 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103763:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103766:	c1 e0 16             	shl    $0x16,%eax
f0103769:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010376c:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103771:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103778:	01 
f0103779:	74 17                	je     f0103792 <env_free+0xff>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010377b:	83 ec 08             	sub    $0x8,%esp
f010377e:	89 d8                	mov    %ebx,%eax
f0103780:	c1 e0 0c             	shl    $0xc,%eax
f0103783:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103786:	50                   	push   %eax
f0103787:	ff 77 60             	pushl  0x60(%edi)
f010378a:	e8 2e de ff ff       	call   f01015bd <page_remove>
f010378f:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103792:	83 c3 01             	add    $0x1,%ebx
f0103795:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f010379b:	75 d4                	jne    f0103771 <env_free+0xde>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f010379d:	8b 47 60             	mov    0x60(%edi),%eax
f01037a0:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01037a3:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01037aa:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01037ad:	3b 05 88 1e 23 f0    	cmp    0xf0231e88,%eax
f01037b3:	72 14                	jb     f01037c9 <env_free+0x136>
		panic("pa2page called with invalid pa");
f01037b5:	83 ec 04             	sub    $0x4,%esp
f01037b8:	68 b8 74 10 f0       	push   $0xf01074b8
f01037bd:	6a 51                	push   $0x51
f01037bf:	68 25 7d 10 f0       	push   $0xf0107d25
f01037c4:	e8 77 c8 ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f01037c9:	83 ec 0c             	sub    $0xc,%esp
f01037cc:	a1 90 1e 23 f0       	mov    0xf0231e90,%eax
f01037d1:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01037d4:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01037d7:	50                   	push   %eax
f01037d8:	e8 3d dc ff ff       	call   f010141a <page_decref>
f01037dd:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01037e0:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f01037e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01037e7:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f01037ec:	0f 85 29 ff ff ff    	jne    f010371b <env_free+0x88>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01037f2:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01037f5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01037fa:	77 15                	ja     f0103811 <env_free+0x17e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037fc:	50                   	push   %eax
f01037fd:	68 a8 6c 10 f0       	push   $0xf0106ca8
f0103802:	68 ca 01 00 00       	push   $0x1ca
f0103807:	68 16 81 10 f0       	push   $0xf0108116
f010380c:	e8 2f c8 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103811:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103818:	05 00 00 00 10       	add    $0x10000000,%eax
f010381d:	c1 e8 0c             	shr    $0xc,%eax
f0103820:	3b 05 88 1e 23 f0    	cmp    0xf0231e88,%eax
f0103826:	72 14                	jb     f010383c <env_free+0x1a9>
		panic("pa2page called with invalid pa");
f0103828:	83 ec 04             	sub    $0x4,%esp
f010382b:	68 b8 74 10 f0       	push   $0xf01074b8
f0103830:	6a 51                	push   $0x51
f0103832:	68 25 7d 10 f0       	push   $0xf0107d25
f0103837:	e8 04 c8 ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f010383c:	83 ec 0c             	sub    $0xc,%esp
f010383f:	8b 15 90 1e 23 f0    	mov    0xf0231e90,%edx
f0103845:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103848:	50                   	push   %eax
f0103849:	e8 cc db ff ff       	call   f010141a <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010384e:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103855:	a1 4c 12 23 f0       	mov    0xf023124c,%eax
f010385a:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f010385d:	89 3d 4c 12 23 f0    	mov    %edi,0xf023124c
}
f0103863:	83 c4 10             	add    $0x10,%esp
f0103866:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103869:	5b                   	pop    %ebx
f010386a:	5e                   	pop    %esi
f010386b:	5f                   	pop    %edi
f010386c:	5d                   	pop    %ebp
f010386d:	c3                   	ret    

f010386e <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f010386e:	55                   	push   %ebp
f010386f:	89 e5                	mov    %esp,%ebp
f0103871:	53                   	push   %ebx
f0103872:	83 ec 04             	sub    $0x4,%esp
f0103875:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103878:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f010387c:	75 19                	jne    f0103897 <env_destroy+0x29>
f010387e:	e8 53 2d 00 00       	call   f01065d6 <cpunum>
f0103883:	6b c0 74             	imul   $0x74,%eax,%eax
f0103886:	3b 98 28 20 23 f0    	cmp    -0xfdcdfd8(%eax),%ebx
f010388c:	74 09                	je     f0103897 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f010388e:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103895:	eb 33                	jmp    f01038ca <env_destroy+0x5c>
	}

	env_free(e);
f0103897:	83 ec 0c             	sub    $0xc,%esp
f010389a:	53                   	push   %ebx
f010389b:	e8 f3 fd ff ff       	call   f0103693 <env_free>

	if (curenv == e) {
f01038a0:	e8 31 2d 00 00       	call   f01065d6 <cpunum>
f01038a5:	6b c0 74             	imul   $0x74,%eax,%eax
f01038a8:	83 c4 10             	add    $0x10,%esp
f01038ab:	3b 98 28 20 23 f0    	cmp    -0xfdcdfd8(%eax),%ebx
f01038b1:	75 17                	jne    f01038ca <env_destroy+0x5c>
		curenv = NULL;
f01038b3:	e8 1e 2d 00 00       	call   f01065d6 <cpunum>
f01038b8:	6b c0 74             	imul   $0x74,%eax,%eax
f01038bb:	c7 80 28 20 23 f0 00 	movl   $0x0,-0xfdcdfd8(%eax)
f01038c2:	00 00 00 
		sched_yield();
f01038c5:	e8 9a 15 00 00       	call   f0104e64 <sched_yield>
	}
}
f01038ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01038cd:	c9                   	leave  
f01038ce:	c3                   	ret    

f01038cf <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01038cf:	55                   	push   %ebp
f01038d0:	89 e5                	mov    %esp,%ebp
f01038d2:	53                   	push   %ebx
f01038d3:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01038d6:	e8 fb 2c 00 00       	call   f01065d6 <cpunum>
f01038db:	6b c0 74             	imul   $0x74,%eax,%eax
f01038de:	8b 98 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%ebx
f01038e4:	e8 ed 2c 00 00       	call   f01065d6 <cpunum>
f01038e9:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f01038ec:	8b 65 08             	mov    0x8(%ebp),%esp
f01038ef:	61                   	popa   
f01038f0:	07                   	pop    %es
f01038f1:	1f                   	pop    %ds
f01038f2:	83 c4 08             	add    $0x8,%esp
f01038f5:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01038f6:	83 ec 04             	sub    $0x4,%esp
f01038f9:	68 86 81 10 f0       	push   $0xf0108186
f01038fe:	68 00 02 00 00       	push   $0x200
f0103903:	68 16 81 10 f0       	push   $0xf0108116
f0103908:	e8 33 c7 ff ff       	call   f0100040 <_panic>

f010390d <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f010390d:	55                   	push   %ebp
f010390e:	89 e5                	mov    %esp,%ebp
f0103910:	83 ec 08             	sub    $0x8,%esp
	// Hint: This function loads the new environment's state from
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	if (curenv != NULL && curenv->env_status == ENV_RUNNING)
f0103913:	e8 be 2c 00 00       	call   f01065d6 <cpunum>
f0103918:	6b c0 74             	imul   $0x74,%eax,%eax
f010391b:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f0103922:	74 29                	je     f010394d <env_run+0x40>
f0103924:	e8 ad 2c 00 00       	call   f01065d6 <cpunum>
f0103929:	6b c0 74             	imul   $0x74,%eax,%eax
f010392c:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103932:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103936:	75 15                	jne    f010394d <env_run+0x40>
		curenv->env_status = ENV_RUNNABLE;
f0103938:	e8 99 2c 00 00       	call   f01065d6 <cpunum>
f010393d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103940:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103946:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	curenv = e;
f010394d:	e8 84 2c 00 00       	call   f01065d6 <cpunum>
f0103952:	6b c0 74             	imul   $0x74,%eax,%eax
f0103955:	8b 55 08             	mov    0x8(%ebp),%edx
f0103958:	89 90 28 20 23 f0    	mov    %edx,-0xfdcdfd8(%eax)
	curenv->env_status = ENV_RUNNING;
f010395e:	e8 73 2c 00 00       	call   f01065d6 <cpunum>
f0103963:	6b c0 74             	imul   $0x74,%eax,%eax
f0103966:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f010396c:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0103973:	e8 5e 2c 00 00       	call   f01065d6 <cpunum>
f0103978:	6b c0 74             	imul   $0x74,%eax,%eax
f010397b:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103981:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir));
f0103985:	e8 4c 2c 00 00       	call   f01065d6 <cpunum>
f010398a:	6b c0 74             	imul   $0x74,%eax,%eax
f010398d:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103993:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103996:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010399b:	77 15                	ja     f01039b2 <env_run+0xa5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010399d:	50                   	push   %eax
f010399e:	68 a8 6c 10 f0       	push   $0xf0106ca8
f01039a3:	68 22 02 00 00       	push   $0x222
f01039a8:	68 16 81 10 f0       	push   $0xf0108116
f01039ad:	e8 8e c6 ff ff       	call   f0100040 <_panic>
f01039b2:	05 00 00 00 10       	add    $0x10000000,%eax
f01039b7:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01039ba:	83 ec 0c             	sub    $0xc,%esp
f01039bd:	68 c0 27 12 f0       	push   $0xf01227c0
f01039c2:	e8 1a 2f 00 00       	call   f01068e1 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01039c7:	f3 90                	pause  

	unlock_kernel();
	env_pop_tf(&curenv->env_tf);
f01039c9:	e8 08 2c 00 00       	call   f01065d6 <cpunum>
f01039ce:	83 c4 04             	add    $0x4,%esp
f01039d1:	6b c0 74             	imul   $0x74,%eax,%eax
f01039d4:	ff b0 28 20 23 f0    	pushl  -0xfdcdfd8(%eax)
f01039da:	e8 f0 fe ff ff       	call   f01038cf <env_pop_tf>

f01039df <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01039df:	55                   	push   %ebp
f01039e0:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01039e2:	ba 70 00 00 00       	mov    $0x70,%edx
f01039e7:	8b 45 08             	mov    0x8(%ebp),%eax
f01039ea:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01039eb:	ba 71 00 00 00       	mov    $0x71,%edx
f01039f0:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01039f1:	0f b6 c0             	movzbl %al,%eax
}
f01039f4:	5d                   	pop    %ebp
f01039f5:	c3                   	ret    

f01039f6 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01039f6:	55                   	push   %ebp
f01039f7:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01039f9:	ba 70 00 00 00       	mov    $0x70,%edx
f01039fe:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a01:	ee                   	out    %al,(%dx)
f0103a02:	ba 71 00 00 00       	mov    $0x71,%edx
f0103a07:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a0a:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103a0b:	5d                   	pop    %ebp
f0103a0c:	c3                   	ret    

f0103a0d <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103a0d:	55                   	push   %ebp
f0103a0e:	89 e5                	mov    %esp,%ebp
f0103a10:	56                   	push   %esi
f0103a11:	53                   	push   %ebx
f0103a12:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103a15:	66 a3 a8 23 12 f0    	mov    %ax,0xf01223a8
	if (!didinit)
f0103a1b:	80 3d 50 12 23 f0 00 	cmpb   $0x0,0xf0231250
f0103a22:	74 5a                	je     f0103a7e <irq_setmask_8259A+0x71>
f0103a24:	89 c6                	mov    %eax,%esi
f0103a26:	ba 21 00 00 00       	mov    $0x21,%edx
f0103a2b:	ee                   	out    %al,(%dx)
f0103a2c:	66 c1 e8 08          	shr    $0x8,%ax
f0103a30:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103a35:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0103a36:	83 ec 0c             	sub    $0xc,%esp
f0103a39:	68 92 81 10 f0       	push   $0xf0108192
f0103a3e:	e8 1b 01 00 00       	call   f0103b5e <cprintf>
f0103a43:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103a46:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103a4b:	0f b7 f6             	movzwl %si,%esi
f0103a4e:	f7 d6                	not    %esi
f0103a50:	0f a3 de             	bt     %ebx,%esi
f0103a53:	73 11                	jae    f0103a66 <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f0103a55:	83 ec 08             	sub    $0x8,%esp
f0103a58:	53                   	push   %ebx
f0103a59:	68 7b 86 10 f0       	push   $0xf010867b
f0103a5e:	e8 fb 00 00 00       	call   f0103b5e <cprintf>
f0103a63:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103a66:	83 c3 01             	add    $0x1,%ebx
f0103a69:	83 fb 10             	cmp    $0x10,%ebx
f0103a6c:	75 e2                	jne    f0103a50 <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103a6e:	83 ec 0c             	sub    $0xc,%esp
f0103a71:	68 28 80 10 f0       	push   $0xf0108028
f0103a76:	e8 e3 00 00 00       	call   f0103b5e <cprintf>
f0103a7b:	83 c4 10             	add    $0x10,%esp
}
f0103a7e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103a81:	5b                   	pop    %ebx
f0103a82:	5e                   	pop    %esi
f0103a83:	5d                   	pop    %ebp
f0103a84:	c3                   	ret    

f0103a85 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f0103a85:	c6 05 50 12 23 f0 01 	movb   $0x1,0xf0231250
f0103a8c:	ba 21 00 00 00       	mov    $0x21,%edx
f0103a91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103a96:	ee                   	out    %al,(%dx)
f0103a97:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103a9c:	ee                   	out    %al,(%dx)
f0103a9d:	ba 20 00 00 00       	mov    $0x20,%edx
f0103aa2:	b8 11 00 00 00       	mov    $0x11,%eax
f0103aa7:	ee                   	out    %al,(%dx)
f0103aa8:	ba 21 00 00 00       	mov    $0x21,%edx
f0103aad:	b8 20 00 00 00       	mov    $0x20,%eax
f0103ab2:	ee                   	out    %al,(%dx)
f0103ab3:	b8 04 00 00 00       	mov    $0x4,%eax
f0103ab8:	ee                   	out    %al,(%dx)
f0103ab9:	b8 03 00 00 00       	mov    $0x3,%eax
f0103abe:	ee                   	out    %al,(%dx)
f0103abf:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103ac4:	b8 11 00 00 00       	mov    $0x11,%eax
f0103ac9:	ee                   	out    %al,(%dx)
f0103aca:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103acf:	b8 28 00 00 00       	mov    $0x28,%eax
f0103ad4:	ee                   	out    %al,(%dx)
f0103ad5:	b8 02 00 00 00       	mov    $0x2,%eax
f0103ada:	ee                   	out    %al,(%dx)
f0103adb:	b8 01 00 00 00       	mov    $0x1,%eax
f0103ae0:	ee                   	out    %al,(%dx)
f0103ae1:	ba 20 00 00 00       	mov    $0x20,%edx
f0103ae6:	b8 68 00 00 00       	mov    $0x68,%eax
f0103aeb:	ee                   	out    %al,(%dx)
f0103aec:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103af1:	ee                   	out    %al,(%dx)
f0103af2:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103af7:	b8 68 00 00 00       	mov    $0x68,%eax
f0103afc:	ee                   	out    %al,(%dx)
f0103afd:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103b02:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103b03:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f0103b0a:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103b0e:	74 13                	je     f0103b23 <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103b10:	55                   	push   %ebp
f0103b11:	89 e5                	mov    %esp,%ebp
f0103b13:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103b16:	0f b7 c0             	movzwl %ax,%eax
f0103b19:	50                   	push   %eax
f0103b1a:	e8 ee fe ff ff       	call   f0103a0d <irq_setmask_8259A>
f0103b1f:	83 c4 10             	add    $0x10,%esp
}
f0103b22:	c9                   	leave  
f0103b23:	f3 c3                	repz ret 

f0103b25 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103b25:	55                   	push   %ebp
f0103b26:	89 e5                	mov    %esp,%ebp
f0103b28:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch); // lib/stdio.c
f0103b2b:	ff 75 08             	pushl  0x8(%ebp)
f0103b2e:	e8 23 cc ff ff       	call   f0100756 <cputchar>
	*cnt++;
}
f0103b33:	83 c4 10             	add    $0x10,%esp
f0103b36:	c9                   	leave  
f0103b37:	c3                   	ret    

f0103b38 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103b38:	55                   	push   %ebp
f0103b39:	89 e5                	mov    %esp,%ebp
f0103b3b:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103b3e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	// lib/printfmt.c
	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103b45:	ff 75 0c             	pushl  0xc(%ebp)
f0103b48:	ff 75 08             	pushl  0x8(%ebp)
f0103b4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103b4e:	50                   	push   %eax
f0103b4f:	68 25 3b 10 f0       	push   $0xf0103b25
f0103b54:	e8 f1 1d 00 00       	call   f010594a <vprintfmt>
	return cnt;
}
f0103b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103b5c:	c9                   	leave  
f0103b5d:	c3                   	ret    

f0103b5e <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103b5e:	55                   	push   %ebp
f0103b5f:	89 e5                	mov    %esp,%ebp
f0103b61:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103b64:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103b67:	50                   	push   %eax
f0103b68:	ff 75 08             	pushl  0x8(%ebp)
f0103b6b:	e8 c8 ff ff ff       	call   f0103b38 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103b70:	c9                   	leave  
f0103b71:	c3                   	ret    

f0103b72 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103b72:	55                   	push   %ebp
f0103b73:	89 e5                	mov    %esp,%ebp
f0103b75:	57                   	push   %edi
f0103b76:	56                   	push   %esi
f0103b77:	53                   	push   %ebx
f0103b78:	83 ec 0c             	sub    $0xc,%esp
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.

	// We assume that BSP is CPU 0; cpunum() returns 0 here on BSP in 
	// our current implementation
	int i = cpunum();
f0103b7b:	e8 56 2a 00 00       	call   f01065d6 <cpunum>
f0103b80:	89 c3                	mov    %eax,%ebx

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
f0103b82:	e8 4f 2a 00 00       	call   f01065d6 <cpunum>
f0103b87:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b8a:	89 d9                	mov    %ebx,%ecx
f0103b8c:	c1 e1 10             	shl    $0x10,%ecx
f0103b8f:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0103b94:	29 ca                	sub    %ecx,%edx
f0103b96:	89 90 30 20 23 f0    	mov    %edx,-0xfdcdfd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;		
f0103b9c:	e8 35 2a 00 00       	call   f01065d6 <cpunum>
f0103ba1:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ba4:	66 c7 80 34 20 23 f0 	movw   $0x10,-0xfdcdfcc(%eax)
f0103bab:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + i] = SEG16(STS_T32A, (uint32_t)(&(thiscpu->cpu_ts)), 
f0103bad:	83 c3 05             	add    $0x5,%ebx
f0103bb0:	e8 21 2a 00 00       	call   f01065d6 <cpunum>
f0103bb5:	89 c7                	mov    %eax,%edi
f0103bb7:	e8 1a 2a 00 00       	call   f01065d6 <cpunum>
f0103bbc:	89 c6                	mov    %eax,%esi
f0103bbe:	e8 13 2a 00 00       	call   f01065d6 <cpunum>
f0103bc3:	66 c7 04 dd 40 23 12 	movw   $0x67,-0xfeddcc0(,%ebx,8)
f0103bca:	f0 67 00 
f0103bcd:	6b ff 74             	imul   $0x74,%edi,%edi
f0103bd0:	81 c7 2c 20 23 f0    	add    $0xf023202c,%edi
f0103bd6:	66 89 3c dd 42 23 12 	mov    %di,-0xfeddcbe(,%ebx,8)
f0103bdd:	f0 
f0103bde:	6b d6 74             	imul   $0x74,%esi,%edx
f0103be1:	81 c2 2c 20 23 f0    	add    $0xf023202c,%edx
f0103be7:	c1 ea 10             	shr    $0x10,%edx
f0103bea:	88 14 dd 44 23 12 f0 	mov    %dl,-0xfeddcbc(,%ebx,8)
f0103bf1:	c6 04 dd 46 23 12 f0 	movb   $0x40,-0xfeddcba(,%ebx,8)
f0103bf8:	40 
f0103bf9:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bfc:	05 2c 20 23 f0       	add    $0xf023202c,%eax
f0103c01:	c1 e8 18             	shr    $0x18,%eax
f0103c04:	88 04 dd 47 23 12 f0 	mov    %al,-0xfeddcb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + i].sd_s = 0;
f0103c0b:	c6 04 dd 45 23 12 f0 	movb   $0x89,-0xfeddcbb(,%ebx,8)
f0103c12:	89 
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103c13:	c1 e3 03             	shl    $0x3,%ebx
f0103c16:	0f 00 db             	ltr    %bx
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103c19:	b8 ac 23 12 f0       	mov    $0xf01223ac,%eax
f0103c1e:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + 8 * i);

	// Load the IDT
	lidt(&idt_pd);
}
f0103c21:	83 c4 0c             	add    $0xc,%esp
f0103c24:	5b                   	pop    %ebx
f0103c25:	5e                   	pop    %esi
f0103c26:	5f                   	pop    %edi
f0103c27:	5d                   	pop    %ebp
f0103c28:	c3                   	ret    

f0103c29 <trap_init>:
trap_init(void)
{
	extern struct Segdesc gdt[];
	int i;

	for (i = 0; i < 256; i++)
f0103c29:	b8 00 00 00 00       	mov    $0x0,%eax
		SETGATE(idt[i], 0, GD_KT, vectors[i], 0);
f0103c2e:	8b 14 85 b2 23 12 f0 	mov    -0xfeddc4e(,%eax,4),%edx
f0103c35:	66 89 14 c5 60 12 23 	mov    %dx,-0xfdceda0(,%eax,8)
f0103c3c:	f0 
f0103c3d:	66 c7 04 c5 62 12 23 	movw   $0x8,-0xfdced9e(,%eax,8)
f0103c44:	f0 08 00 
f0103c47:	c6 04 c5 64 12 23 f0 	movb   $0x0,-0xfdced9c(,%eax,8)
f0103c4e:	00 
f0103c4f:	c6 04 c5 65 12 23 f0 	movb   $0x8e,-0xfdced9b(,%eax,8)
f0103c56:	8e 
f0103c57:	c1 ea 10             	shr    $0x10,%edx
f0103c5a:	66 89 14 c5 66 12 23 	mov    %dx,-0xfdced9a(,%eax,8)
f0103c61:	f0 
trap_init(void)
{
	extern struct Segdesc gdt[];
	int i;

	for (i = 0; i < 256; i++)
f0103c62:	83 c0 01             	add    $0x1,%eax
f0103c65:	3d 00 01 00 00       	cmp    $0x100,%eax
f0103c6a:	75 c2                	jne    f0103c2e <trap_init+0x5>
}


void
trap_init(void)
{
f0103c6c:	55                   	push   %ebp
f0103c6d:	89 e5                	mov    %esp,%ebp
f0103c6f:	83 ec 08             	sub    $0x8,%esp
	int i;

	for (i = 0; i < 256; i++)
		SETGATE(idt[i], 0, GD_KT, vectors[i], 0);
	
	SETGATE(idt[T_BRKPT],   0, GD_KT, vectors[T_BRKPT],   DPL_USER);
f0103c72:	a1 be 23 12 f0       	mov    0xf01223be,%eax
f0103c77:	66 a3 78 12 23 f0    	mov    %ax,0xf0231278
f0103c7d:	66 c7 05 7a 12 23 f0 	movw   $0x8,0xf023127a
f0103c84:	08 00 
f0103c86:	c6 05 7c 12 23 f0 00 	movb   $0x0,0xf023127c
f0103c8d:	c6 05 7d 12 23 f0 ee 	movb   $0xee,0xf023127d
f0103c94:	c1 e8 10             	shr    $0x10,%eax
f0103c97:	66 a3 7e 12 23 f0    	mov    %ax,0xf023127e
	SETGATE(idt[T_SYSCALL], 0, GD_KT, vectors[T_SYSCALL], DPL_USER);
f0103c9d:	a1 72 24 12 f0       	mov    0xf0122472,%eax
f0103ca2:	66 a3 e0 13 23 f0    	mov    %ax,0xf02313e0
f0103ca8:	66 c7 05 e2 13 23 f0 	movw   $0x8,0xf02313e2
f0103caf:	08 00 
f0103cb1:	c6 05 e4 13 23 f0 00 	movb   $0x0,0xf02313e4
f0103cb8:	c6 05 e5 13 23 f0 ee 	movb   $0xee,0xf02313e5
f0103cbf:	c1 e8 10             	shr    $0x10,%eax
f0103cc2:	66 a3 e6 13 23 f0    	mov    %ax,0xf02313e6

	// Per-CPU setup 
	trap_init_percpu();
f0103cc8:	e8 a5 fe ff ff       	call   f0103b72 <trap_init_percpu>
}
f0103ccd:	c9                   	leave  
f0103cce:	c3                   	ret    

f0103ccf <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103ccf:	55                   	push   %ebp
f0103cd0:	89 e5                	mov    %esp,%ebp
f0103cd2:	53                   	push   %ebx
f0103cd3:	83 ec 0c             	sub    $0xc,%esp
f0103cd6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103cd9:	ff 33                	pushl  (%ebx)
f0103cdb:	68 a6 81 10 f0       	push   $0xf01081a6
f0103ce0:	e8 79 fe ff ff       	call   f0103b5e <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103ce5:	83 c4 08             	add    $0x8,%esp
f0103ce8:	ff 73 04             	pushl  0x4(%ebx)
f0103ceb:	68 b5 81 10 f0       	push   $0xf01081b5
f0103cf0:	e8 69 fe ff ff       	call   f0103b5e <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103cf5:	83 c4 08             	add    $0x8,%esp
f0103cf8:	ff 73 08             	pushl  0x8(%ebx)
f0103cfb:	68 c4 81 10 f0       	push   $0xf01081c4
f0103d00:	e8 59 fe ff ff       	call   f0103b5e <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103d05:	83 c4 08             	add    $0x8,%esp
f0103d08:	ff 73 0c             	pushl  0xc(%ebx)
f0103d0b:	68 d3 81 10 f0       	push   $0xf01081d3
f0103d10:	e8 49 fe ff ff       	call   f0103b5e <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103d15:	83 c4 08             	add    $0x8,%esp
f0103d18:	ff 73 10             	pushl  0x10(%ebx)
f0103d1b:	68 e2 81 10 f0       	push   $0xf01081e2
f0103d20:	e8 39 fe ff ff       	call   f0103b5e <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103d25:	83 c4 08             	add    $0x8,%esp
f0103d28:	ff 73 14             	pushl  0x14(%ebx)
f0103d2b:	68 f1 81 10 f0       	push   $0xf01081f1
f0103d30:	e8 29 fe ff ff       	call   f0103b5e <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103d35:	83 c4 08             	add    $0x8,%esp
f0103d38:	ff 73 18             	pushl  0x18(%ebx)
f0103d3b:	68 00 82 10 f0       	push   $0xf0108200
f0103d40:	e8 19 fe ff ff       	call   f0103b5e <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103d45:	83 c4 08             	add    $0x8,%esp
f0103d48:	ff 73 1c             	pushl  0x1c(%ebx)
f0103d4b:	68 0f 82 10 f0       	push   $0xf010820f
f0103d50:	e8 09 fe ff ff       	call   f0103b5e <cprintf>
}
f0103d55:	83 c4 10             	add    $0x10,%esp
f0103d58:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103d5b:	c9                   	leave  
f0103d5c:	c3                   	ret    

f0103d5d <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103d5d:	55                   	push   %ebp
f0103d5e:	89 e5                	mov    %esp,%ebp
f0103d60:	56                   	push   %esi
f0103d61:	53                   	push   %ebx
f0103d62:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103d65:	e8 6c 28 00 00       	call   f01065d6 <cpunum>
f0103d6a:	83 ec 04             	sub    $0x4,%esp
f0103d6d:	50                   	push   %eax
f0103d6e:	53                   	push   %ebx
f0103d6f:	68 73 82 10 f0       	push   $0xf0108273
f0103d74:	e8 e5 fd ff ff       	call   f0103b5e <cprintf>
	print_regs(&tf->tf_regs);
f0103d79:	89 1c 24             	mov    %ebx,(%esp)
f0103d7c:	e8 4e ff ff ff       	call   f0103ccf <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103d81:	83 c4 08             	add    $0x8,%esp
f0103d84:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103d88:	50                   	push   %eax
f0103d89:	68 91 82 10 f0       	push   $0xf0108291
f0103d8e:	e8 cb fd ff ff       	call   f0103b5e <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103d93:	83 c4 08             	add    $0x8,%esp
f0103d96:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103d9a:	50                   	push   %eax
f0103d9b:	68 a4 82 10 f0       	push   $0xf01082a4
f0103da0:	e8 b9 fd ff ff       	call   f0103b5e <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103da5:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103da8:	83 c4 10             	add    $0x10,%esp
f0103dab:	83 f8 13             	cmp    $0x13,%eax
f0103dae:	77 09                	ja     f0103db9 <print_trapframe+0x5c>
		return excnames[trapno];
f0103db0:	8b 14 85 60 85 10 f0 	mov    -0xfef7aa0(,%eax,4),%edx
f0103db7:	eb 1f                	jmp    f0103dd8 <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0103db9:	83 f8 30             	cmp    $0x30,%eax
f0103dbc:	74 15                	je     f0103dd3 <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103dbe:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103dc1:	83 fa 10             	cmp    $0x10,%edx
f0103dc4:	b9 3d 82 10 f0       	mov    $0xf010823d,%ecx
f0103dc9:	ba 2a 82 10 f0       	mov    $0xf010822a,%edx
f0103dce:	0f 43 d1             	cmovae %ecx,%edx
f0103dd1:	eb 05                	jmp    f0103dd8 <print_trapframe+0x7b>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103dd3:	ba 1e 82 10 f0       	mov    $0xf010821e,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103dd8:	83 ec 04             	sub    $0x4,%esp
f0103ddb:	52                   	push   %edx
f0103ddc:	50                   	push   %eax
f0103ddd:	68 b7 82 10 f0       	push   $0xf01082b7
f0103de2:	e8 77 fd ff ff       	call   f0103b5e <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103de7:	83 c4 10             	add    $0x10,%esp
f0103dea:	3b 1d 60 1a 23 f0    	cmp    0xf0231a60,%ebx
f0103df0:	75 1a                	jne    f0103e0c <print_trapframe+0xaf>
f0103df2:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103df6:	75 14                	jne    f0103e0c <print_trapframe+0xaf>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103df8:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103dfb:	83 ec 08             	sub    $0x8,%esp
f0103dfe:	50                   	push   %eax
f0103dff:	68 c9 82 10 f0       	push   $0xf01082c9
f0103e04:	e8 55 fd ff ff       	call   f0103b5e <cprintf>
f0103e09:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103e0c:	83 ec 08             	sub    $0x8,%esp
f0103e0f:	ff 73 2c             	pushl  0x2c(%ebx)
f0103e12:	68 d8 82 10 f0       	push   $0xf01082d8
f0103e17:	e8 42 fd ff ff       	call   f0103b5e <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103e1c:	83 c4 10             	add    $0x10,%esp
f0103e1f:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103e23:	75 49                	jne    f0103e6e <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103e25:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103e28:	89 c2                	mov    %eax,%edx
f0103e2a:	83 e2 01             	and    $0x1,%edx
f0103e2d:	ba 57 82 10 f0       	mov    $0xf0108257,%edx
f0103e32:	b9 4c 82 10 f0       	mov    $0xf010824c,%ecx
f0103e37:	0f 44 ca             	cmove  %edx,%ecx
f0103e3a:	89 c2                	mov    %eax,%edx
f0103e3c:	83 e2 02             	and    $0x2,%edx
f0103e3f:	ba 69 82 10 f0       	mov    $0xf0108269,%edx
f0103e44:	be 63 82 10 f0       	mov    $0xf0108263,%esi
f0103e49:	0f 45 d6             	cmovne %esi,%edx
f0103e4c:	83 e0 04             	and    $0x4,%eax
f0103e4f:	be a3 83 10 f0       	mov    $0xf01083a3,%esi
f0103e54:	b8 6e 82 10 f0       	mov    $0xf010826e,%eax
f0103e59:	0f 44 c6             	cmove  %esi,%eax
f0103e5c:	51                   	push   %ecx
f0103e5d:	52                   	push   %edx
f0103e5e:	50                   	push   %eax
f0103e5f:	68 e6 82 10 f0       	push   $0xf01082e6
f0103e64:	e8 f5 fc ff ff       	call   f0103b5e <cprintf>
f0103e69:	83 c4 10             	add    $0x10,%esp
f0103e6c:	eb 10                	jmp    f0103e7e <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103e6e:	83 ec 0c             	sub    $0xc,%esp
f0103e71:	68 28 80 10 f0       	push   $0xf0108028
f0103e76:	e8 e3 fc ff ff       	call   f0103b5e <cprintf>
f0103e7b:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103e7e:	83 ec 08             	sub    $0x8,%esp
f0103e81:	ff 73 30             	pushl  0x30(%ebx)
f0103e84:	68 f5 82 10 f0       	push   $0xf01082f5
f0103e89:	e8 d0 fc ff ff       	call   f0103b5e <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103e8e:	83 c4 08             	add    $0x8,%esp
f0103e91:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103e95:	50                   	push   %eax
f0103e96:	68 04 83 10 f0       	push   $0xf0108304
f0103e9b:	e8 be fc ff ff       	call   f0103b5e <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103ea0:	83 c4 08             	add    $0x8,%esp
f0103ea3:	ff 73 38             	pushl  0x38(%ebx)
f0103ea6:	68 17 83 10 f0       	push   $0xf0108317
f0103eab:	e8 ae fc ff ff       	call   f0103b5e <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103eb0:	83 c4 10             	add    $0x10,%esp
f0103eb3:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103eb7:	74 25                	je     f0103ede <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103eb9:	83 ec 08             	sub    $0x8,%esp
f0103ebc:	ff 73 3c             	pushl  0x3c(%ebx)
f0103ebf:	68 26 83 10 f0       	push   $0xf0108326
f0103ec4:	e8 95 fc ff ff       	call   f0103b5e <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103ec9:	83 c4 08             	add    $0x8,%esp
f0103ecc:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103ed0:	50                   	push   %eax
f0103ed1:	68 35 83 10 f0       	push   $0xf0108335
f0103ed6:	e8 83 fc ff ff       	call   f0103b5e <cprintf>
f0103edb:	83 c4 10             	add    $0x10,%esp
	}
}
f0103ede:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103ee1:	5b                   	pop    %ebx
f0103ee2:	5e                   	pop    %esi
f0103ee3:	5d                   	pop    %ebp
f0103ee4:	c3                   	ret    

f0103ee5 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103ee5:	55                   	push   %ebp
f0103ee6:	89 e5                	mov    %esp,%ebp
f0103ee8:	57                   	push   %edi
f0103ee9:	56                   	push   %esi
f0103eea:	53                   	push   %ebx
f0103eeb:	83 ec 3c             	sub    $0x3c,%esp
f0103eee:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103ef1:	0f 20 d6             	mov    %cr2,%esi

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	// Handle kernel-mode page faults.
	if ((tf->tf_cs & 0x3) == 0) 
f0103ef4:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103ef8:	75 17                	jne    f0103f11 <page_fault_handler+0x2c>
		panic("page_fault_handler: page fault in kernel mode");
f0103efa:	83 ec 04             	sub    $0x4,%esp
f0103efd:	68 f0 84 10 f0       	push   $0xf01084f0
f0103f02:	68 31 01 00 00       	push   $0x131
f0103f07:	68 48 83 10 f0       	push   $0xf0108348
f0103f0c:	e8 2f c1 ff ff       	call   f0100040 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').
	//monitor(tf);

	if (curenv->env_pgfault_upcall != NULL) {
f0103f11:	e8 c0 26 00 00       	call   f01065d6 <cpunum>
f0103f16:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f19:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103f1f:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0103f23:	0f 84 fa 00 00 00    	je     f0104023 <page_fault_handler+0x13e>
		struct UTrapframe utf;
		
		utf.utf_fault_va = fault_va;
		utf.utf_err = tf->tf_err;
f0103f29:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0103f2c:	89 45 dc             	mov    %eax,-0x24(%ebp)
		utf.utf_regs = tf->tf_regs;
f0103f2f:	8b 03                	mov    (%ebx),%eax
f0103f31:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0103f34:	8b 43 04             	mov    0x4(%ebx),%eax
f0103f37:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103f3a:	8b 43 08             	mov    0x8(%ebx),%eax
f0103f3d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103f40:	8b 43 0c             	mov    0xc(%ebx),%eax
f0103f43:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103f46:	8b 43 10             	mov    0x10(%ebx),%eax
f0103f49:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103f4c:	8b 43 14             	mov    0x14(%ebx),%eax
f0103f4f:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0103f52:	8b 43 18             	mov    0x18(%ebx),%eax
f0103f55:	89 45 bc             	mov    %eax,-0x44(%ebp)
f0103f58:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0103f5b:	89 45 b8             	mov    %eax,-0x48(%ebp)
		utf.utf_eip = tf->tf_eip;
f0103f5e:	8b 43 30             	mov    0x30(%ebx),%eax
f0103f61:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		utf.utf_eflags = tf->tf_eflags;
f0103f64:	8b 43 38             	mov    0x38(%ebx),%eax
f0103f67:	89 45 cc             	mov    %eax,-0x34(%ebp)
		utf.utf_esp = tf->tf_esp;
f0103f6a:	8b 7b 3c             	mov    0x3c(%ebx),%edi

		// if tf->tf_esp is already on the user level exception stack
		if (tf->tf_esp >= UXSTACKTOP - PGSIZE && tf->tf_esp < UXSTACKTOP)
f0103f6d:	8d 87 00 10 40 11    	lea    0x11401000(%edi),%eax
f0103f73:	3d ff 0f 00 00       	cmp    $0xfff,%eax
f0103f78:	77 08                	ja     f0103f82 <page_fault_handler+0x9d>
			tf->tf_esp -= 4;
f0103f7a:	8d 47 fc             	lea    -0x4(%edi),%eax
f0103f7d:	89 43 3c             	mov    %eax,0x3c(%ebx)
f0103f80:	eb 07                	jmp    f0103f89 <page_fault_handler+0xa4>
		else  
			tf->tf_esp = UXSTACKTOP;
f0103f82:	c7 43 3c 00 00 c0 ee 	movl   $0xeec00000,0x3c(%ebx)
		
		tf->tf_esp -= sizeof(utf);
f0103f89:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103f8c:	83 e8 34             	sub    $0x34,%eax
f0103f8f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0103f92:	89 43 3c             	mov    %eax,0x3c(%ebx)
		user_mem_assert(curenv, (void *) tf->tf_esp, sizeof(utf), PTE_U|PTE_W|PTE_P);
f0103f95:	e8 3c 26 00 00       	call   f01065d6 <cpunum>
f0103f9a:	6a 07                	push   $0x7
f0103f9c:	6a 34                	push   $0x34
f0103f9e:	ff 75 c4             	pushl  -0x3c(%ebp)
f0103fa1:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fa4:	ff b0 28 20 23 f0    	pushl  -0xfdcdfd8(%eax)
f0103faa:	e8 05 f2 ff ff       	call   f01031b4 <user_mem_assert>
		*((struct UTrapframe *) tf->tf_esp) = utf;
f0103faf:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103fb2:	89 30                	mov    %esi,(%eax)
f0103fb4:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103fb7:	89 50 04             	mov    %edx,0x4(%eax)
f0103fba:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0103fbd:	89 48 08             	mov    %ecx,0x8(%eax)
f0103fc0:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0103fc3:	89 50 0c             	mov    %edx,0xc(%eax)
f0103fc6:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0103fc9:	89 48 10             	mov    %ecx,0x10(%eax)
f0103fcc:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103fcf:	89 50 14             	mov    %edx,0x14(%eax)
f0103fd2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103fd5:	89 48 18             	mov    %ecx,0x18(%eax)
f0103fd8:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0103fdb:	89 50 1c             	mov    %edx,0x1c(%eax)
f0103fde:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0103fe1:	89 48 20             	mov    %ecx,0x20(%eax)
f0103fe4:	8b 55 b8             	mov    -0x48(%ebp),%edx
f0103fe7:	89 50 24             	mov    %edx,0x24(%eax)
f0103fea:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0103fed:	89 48 28             	mov    %ecx,0x28(%eax)
f0103ff0:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0103ff3:	89 50 2c             	mov    %edx,0x2c(%eax)
f0103ff6:	89 78 30             	mov    %edi,0x30(%eax)

		tf->tf_eip = (uintptr_t) curenv->env_pgfault_upcall;
f0103ff9:	e8 d8 25 00 00       	call   f01065d6 <cpunum>
f0103ffe:	6b c0 74             	imul   $0x74,%eax,%eax
f0104001:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0104007:	8b 40 64             	mov    0x64(%eax),%eax
f010400a:	89 43 30             	mov    %eax,0x30(%ebx)

		env_run(curenv);
f010400d:	e8 c4 25 00 00       	call   f01065d6 <cpunum>
f0104012:	83 c4 04             	add    $0x4,%esp
f0104015:	6b c0 74             	imul   $0x74,%eax,%eax
f0104018:	ff b0 28 20 23 f0    	pushl  -0xfdcdfd8(%eax)
f010401e:	e8 ea f8 ff ff       	call   f010390d <env_run>
	} 
	
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104023:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0104026:	e8 ab 25 00 00       	call   f01065d6 <cpunum>

		env_run(curenv);
	} 
	
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010402b:	57                   	push   %edi
f010402c:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f010402d:	6b c0 74             	imul   $0x74,%eax,%eax

		env_run(curenv);
	} 
	
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104030:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0104036:	ff 70 48             	pushl  0x48(%eax)
f0104039:	68 20 85 10 f0       	push   $0xf0108520
f010403e:	e8 1b fb ff ff       	call   f0103b5e <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104043:	89 1c 24             	mov    %ebx,(%esp)
f0104046:	e8 12 fd ff ff       	call   f0103d5d <print_trapframe>
	env_destroy(curenv);
f010404b:	e8 86 25 00 00       	call   f01065d6 <cpunum>
f0104050:	83 c4 04             	add    $0x4,%esp
f0104053:	6b c0 74             	imul   $0x74,%eax,%eax
f0104056:	ff b0 28 20 23 f0    	pushl  -0xfdcdfd8(%eax)
f010405c:	e8 0d f8 ff ff       	call   f010386e <env_destroy>
}
f0104061:	83 c4 10             	add    $0x10,%esp
f0104064:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104067:	5b                   	pop    %ebx
f0104068:	5e                   	pop    %esi
f0104069:	5f                   	pop    %edi
f010406a:	5d                   	pop    %ebp
f010406b:	c3                   	ret    

f010406c <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f010406c:	55                   	push   %ebp
f010406d:	89 e5                	mov    %esp,%ebp
f010406f:	57                   	push   %edi
f0104070:	56                   	push   %esi
f0104071:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104074:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104075:	83 3d 80 1e 23 f0 00 	cmpl   $0x0,0xf0231e80
f010407c:	74 01                	je     f010407f <trap+0x13>
		asm volatile("hlt");
f010407e:	f4                   	hlt    
	
	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f010407f:	e8 52 25 00 00       	call   f01065d6 <cpunum>
f0104084:	6b d0 74             	imul   $0x74,%eax,%edx
f0104087:	81 c2 20 20 23 f0    	add    $0xf0232020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010408d:	b8 01 00 00 00       	mov    $0x1,%eax
f0104092:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0104096:	83 f8 02             	cmp    $0x2,%eax
f0104099:	75 10                	jne    f01040ab <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010409b:	83 ec 0c             	sub    $0xc,%esp
f010409e:	68 c0 27 12 f0       	push   $0xf01227c0
f01040a3:	e8 9c 27 00 00       	call   f0106844 <spin_lock>
f01040a8:	83 c4 10             	add    $0x10,%esp

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f01040ab:	9c                   	pushf  
f01040ac:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f01040ad:	f6 c4 02             	test   $0x2,%ah
f01040b0:	74 19                	je     f01040cb <trap+0x5f>
f01040b2:	68 54 83 10 f0       	push   $0xf0108354
f01040b7:	68 3f 7d 10 f0       	push   $0xf0107d3f
f01040bc:	68 fd 00 00 00       	push   $0xfd
f01040c1:	68 48 83 10 f0       	push   $0xf0108348
f01040c6:	e8 75 bf ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f01040cb:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01040cf:	83 e0 03             	and    $0x3,%eax
f01040d2:	66 83 f8 03          	cmp    $0x3,%ax
f01040d6:	0f 85 a0 00 00 00    	jne    f010417c <trap+0x110>
f01040dc:	83 ec 0c             	sub    $0xc,%esp
f01040df:	68 c0 27 12 f0       	push   $0xf01227c0
f01040e4:	e8 5b 27 00 00       	call   f0106844 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		lock_kernel();

		assert(curenv);
f01040e9:	e8 e8 24 00 00       	call   f01065d6 <cpunum>
f01040ee:	6b c0 74             	imul   $0x74,%eax,%eax
f01040f1:	83 c4 10             	add    $0x10,%esp
f01040f4:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f01040fb:	75 19                	jne    f0104116 <trap+0xaa>
f01040fd:	68 6d 83 10 f0       	push   $0xf010836d
f0104102:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0104107:	68 05 01 00 00       	push   $0x105
f010410c:	68 48 83 10 f0       	push   $0xf0108348
f0104111:	e8 2a bf ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0104116:	e8 bb 24 00 00       	call   f01065d6 <cpunum>
f010411b:	6b c0 74             	imul   $0x74,%eax,%eax
f010411e:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0104124:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104128:	75 2d                	jne    f0104157 <trap+0xeb>
			env_free(curenv);
f010412a:	e8 a7 24 00 00       	call   f01065d6 <cpunum>
f010412f:	83 ec 0c             	sub    $0xc,%esp
f0104132:	6b c0 74             	imul   $0x74,%eax,%eax
f0104135:	ff b0 28 20 23 f0    	pushl  -0xfdcdfd8(%eax)
f010413b:	e8 53 f5 ff ff       	call   f0103693 <env_free>
			curenv = NULL;
f0104140:	e8 91 24 00 00       	call   f01065d6 <cpunum>
f0104145:	6b c0 74             	imul   $0x74,%eax,%eax
f0104148:	c7 80 28 20 23 f0 00 	movl   $0x0,-0xfdcdfd8(%eax)
f010414f:	00 00 00 
			sched_yield();
f0104152:	e8 0d 0d 00 00       	call   f0104e64 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104157:	e8 7a 24 00 00       	call   f01065d6 <cpunum>
f010415c:	6b c0 74             	imul   $0x74,%eax,%eax
f010415f:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0104165:	b9 11 00 00 00       	mov    $0x11,%ecx
f010416a:	89 c7                	mov    %eax,%edi
f010416c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f010416e:	e8 63 24 00 00       	call   f01065d6 <cpunum>
f0104173:	6b c0 74             	imul   $0x74,%eax,%eax
f0104176:	8b b0 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f010417c:	89 35 60 1a 23 f0    	mov    %esi,0xf0231a60

static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	switch (tf->tf_trapno) {
f0104182:	8b 46 28             	mov    0x28(%esi),%eax
f0104185:	83 f8 03             	cmp    $0x3,%eax
f0104188:	74 29                	je     f01041b3 <trap+0x147>
f010418a:	83 f8 03             	cmp    $0x3,%eax
f010418d:	77 07                	ja     f0104196 <trap+0x12a>
f010418f:	83 f8 01             	cmp    $0x1,%eax
f0104192:	74 30                	je     f01041c4 <trap+0x158>
f0104194:	eb 60                	jmp    f01041f6 <trap+0x18a>
f0104196:	83 f8 0e             	cmp    $0xe,%eax
f0104199:	74 07                	je     f01041a2 <trap+0x136>
f010419b:	83 f8 30             	cmp    $0x30,%eax
f010419e:	74 35                	je     f01041d5 <trap+0x169>
f01041a0:	eb 54                	jmp    f01041f6 <trap+0x18a>
	case T_PGFLT:
		page_fault_handler(tf);
f01041a2:	83 ec 0c             	sub    $0xc,%esp
f01041a5:	56                   	push   %esi
f01041a6:	e8 3a fd ff ff       	call   f0103ee5 <page_fault_handler>
f01041ab:	83 c4 10             	add    $0x10,%esp
f01041ae:	e9 b4 00 00 00       	jmp    f0104267 <trap+0x1fb>
		return;
	case T_BRKPT:
		monitor(tf);
f01041b3:	83 ec 0c             	sub    $0xc,%esp
f01041b6:	56                   	push   %esi
f01041b7:	e8 c6 cb ff ff       	call   f0100d82 <monitor>
f01041bc:	83 c4 10             	add    $0x10,%esp
f01041bf:	e9 a3 00 00 00       	jmp    f0104267 <trap+0x1fb>
		return;
	case T_DEBUG: // interrupt of type-1
		monitor(tf);
f01041c4:	83 ec 0c             	sub    $0xc,%esp
f01041c7:	56                   	push   %esi
f01041c8:	e8 b5 cb ff ff       	call   f0100d82 <monitor>
f01041cd:	83 c4 10             	add    $0x10,%esp
f01041d0:	e9 92 00 00 00       	jmp    f0104267 <trap+0x1fb>
		return;
	case T_SYSCALL:
		tf->tf_regs.reg_eax = syscall(
f01041d5:	83 ec 08             	sub    $0x8,%esp
f01041d8:	ff 76 04             	pushl  0x4(%esi)
f01041db:	ff 36                	pushl  (%esi)
f01041dd:	ff 76 10             	pushl  0x10(%esi)
f01041e0:	ff 76 18             	pushl  0x18(%esi)
f01041e3:	ff 76 14             	pushl  0x14(%esi)
f01041e6:	ff 76 1c             	pushl  0x1c(%esi)
f01041e9:	e8 29 0d 00 00       	call   f0104f17 <syscall>
f01041ee:	89 46 1c             	mov    %eax,0x1c(%esi)
f01041f1:	83 c4 20             	add    $0x20,%esp
f01041f4:	eb 71                	jmp    f0104267 <trap+0x1fb>
	}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f01041f6:	83 f8 27             	cmp    $0x27,%eax
f01041f9:	75 1a                	jne    f0104215 <trap+0x1a9>
		cprintf("Spurious interrupt on irq 7\n");
f01041fb:	83 ec 0c             	sub    $0xc,%esp
f01041fe:	68 74 83 10 f0       	push   $0xf0108374
f0104203:	e8 56 f9 ff ff       	call   f0103b5e <cprintf>
		print_trapframe(tf);
f0104208:	89 34 24             	mov    %esi,(%esp)
f010420b:	e8 4d fb ff ff       	call   f0103d5d <print_trapframe>
f0104210:	83 c4 10             	add    $0x10,%esp
f0104213:	eb 52                	jmp    f0104267 <trap+0x1fb>
		return;
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f0104215:	83 f8 20             	cmp    $0x20,%eax
f0104218:	75 0a                	jne    f0104224 <trap+0x1b8>
		lapic_eoi();
f010421a:	e8 02 25 00 00       	call   f0106721 <lapic_eoi>
		sched_yield(); // should never return
f010421f:	e8 40 0c 00 00       	call   f0104e64 <sched_yield>
		panic("sched_yield returns to trap_dispatch");
	}

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104224:	83 ec 0c             	sub    $0xc,%esp
f0104227:	56                   	push   %esi
f0104228:	e8 30 fb ff ff       	call   f0103d5d <print_trapframe>
	if (tf->tf_cs == GD_KT)
f010422d:	83 c4 10             	add    $0x10,%esp
f0104230:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104235:	75 17                	jne    f010424e <trap+0x1e2>
		panic("unhandled trap in kernel");
f0104237:	83 ec 04             	sub    $0x4,%esp
f010423a:	68 91 83 10 f0       	push   $0xf0108391
f010423f:	68 e3 00 00 00       	push   $0xe3
f0104244:	68 48 83 10 f0       	push   $0xf0108348
f0104249:	e8 f2 bd ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f010424e:	e8 83 23 00 00       	call   f01065d6 <cpunum>
f0104253:	83 ec 0c             	sub    $0xc,%esp
f0104256:	6b c0 74             	imul   $0x74,%eax,%eax
f0104259:	ff b0 28 20 23 f0    	pushl  -0xfdcdfd8(%eax)
f010425f:	e8 0a f6 ff ff       	call   f010386e <env_destroy>
f0104264:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104267:	e8 6a 23 00 00       	call   f01065d6 <cpunum>
f010426c:	6b c0 74             	imul   $0x74,%eax,%eax
f010426f:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f0104276:	74 2a                	je     f01042a2 <trap+0x236>
f0104278:	e8 59 23 00 00       	call   f01065d6 <cpunum>
f010427d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104280:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0104286:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010428a:	75 16                	jne    f01042a2 <trap+0x236>
		env_run(curenv);
f010428c:	e8 45 23 00 00       	call   f01065d6 <cpunum>
f0104291:	83 ec 0c             	sub    $0xc,%esp
f0104294:	6b c0 74             	imul   $0x74,%eax,%eax
f0104297:	ff b0 28 20 23 f0    	pushl  -0xfdcdfd8(%eax)
f010429d:	e8 6b f6 ff ff       	call   f010390d <env_run>
	else
		sched_yield();
f01042a2:	e8 bd 0b 00 00       	call   f0104e64 <sched_yield>
f01042a7:	90                   	nop

f01042a8 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.text
.globl _alltraps
TRAPHANDLER_NOEC(vector0, 0)
f01042a8:	6a 00                	push   $0x0
f01042aa:	6a 00                	push   $0x0
f01042ac:	e9 ce 0a 00 00       	jmp    f0104d7f <_alltraps>
f01042b1:	90                   	nop

f01042b2 <vector1>:
TRAPHANDLER_NOEC(vector1, 1)
f01042b2:	6a 00                	push   $0x0
f01042b4:	6a 01                	push   $0x1
f01042b6:	e9 c4 0a 00 00       	jmp    f0104d7f <_alltraps>
f01042bb:	90                   	nop

f01042bc <vector2>:
TRAPHANDLER_NOEC(vector2, 2)
f01042bc:	6a 00                	push   $0x0
f01042be:	6a 02                	push   $0x2
f01042c0:	e9 ba 0a 00 00       	jmp    f0104d7f <_alltraps>
f01042c5:	90                   	nop

f01042c6 <vector3>:
TRAPHANDLER_NOEC(vector3, 3)
f01042c6:	6a 00                	push   $0x0
f01042c8:	6a 03                	push   $0x3
f01042ca:	e9 b0 0a 00 00       	jmp    f0104d7f <_alltraps>
f01042cf:	90                   	nop

f01042d0 <vector4>:
TRAPHANDLER_NOEC(vector4, 4)
f01042d0:	6a 00                	push   $0x0
f01042d2:	6a 04                	push   $0x4
f01042d4:	e9 a6 0a 00 00       	jmp    f0104d7f <_alltraps>
f01042d9:	90                   	nop

f01042da <vector5>:
TRAPHANDLER_NOEC(vector5, 5)
f01042da:	6a 00                	push   $0x0
f01042dc:	6a 05                	push   $0x5
f01042de:	e9 9c 0a 00 00       	jmp    f0104d7f <_alltraps>
f01042e3:	90                   	nop

f01042e4 <vector6>:
TRAPHANDLER_NOEC(vector6, 6)
f01042e4:	6a 00                	push   $0x0
f01042e6:	6a 06                	push   $0x6
f01042e8:	e9 92 0a 00 00       	jmp    f0104d7f <_alltraps>
f01042ed:	90                   	nop

f01042ee <vector7>:
TRAPHANDLER_NOEC(vector7, 7)
f01042ee:	6a 00                	push   $0x0
f01042f0:	6a 07                	push   $0x7
f01042f2:	e9 88 0a 00 00       	jmp    f0104d7f <_alltraps>
f01042f7:	90                   	nop

f01042f8 <vector8>:
TRAPHANDLER(vector8, 8)
f01042f8:	6a 08                	push   $0x8
f01042fa:	e9 80 0a 00 00       	jmp    f0104d7f <_alltraps>
f01042ff:	90                   	nop

f0104300 <vector9>:
TRAPHANDLER_NOEC(vector9, 9)
f0104300:	6a 00                	push   $0x0
f0104302:	6a 09                	push   $0x9
f0104304:	e9 76 0a 00 00       	jmp    f0104d7f <_alltraps>
f0104309:	90                   	nop

f010430a <vector10>:
TRAPHANDLER(vector10, 10)
f010430a:	6a 0a                	push   $0xa
f010430c:	e9 6e 0a 00 00       	jmp    f0104d7f <_alltraps>
f0104311:	90                   	nop

f0104312 <vector11>:
TRAPHANDLER(vector11, 11)
f0104312:	6a 0b                	push   $0xb
f0104314:	e9 66 0a 00 00       	jmp    f0104d7f <_alltraps>
f0104319:	90                   	nop

f010431a <vector12>:
TRAPHANDLER(vector12, 12)
f010431a:	6a 0c                	push   $0xc
f010431c:	e9 5e 0a 00 00       	jmp    f0104d7f <_alltraps>
f0104321:	90                   	nop

f0104322 <vector13>:
TRAPHANDLER(vector13, 13)
f0104322:	6a 0d                	push   $0xd
f0104324:	e9 56 0a 00 00       	jmp    f0104d7f <_alltraps>
f0104329:	90                   	nop

f010432a <vector14>:
TRAPHANDLER(vector14, 14)
f010432a:	6a 0e                	push   $0xe
f010432c:	e9 4e 0a 00 00       	jmp    f0104d7f <_alltraps>
f0104331:	90                   	nop

f0104332 <vector15>:
TRAPHANDLER_NOEC(vector15, 15)
f0104332:	6a 00                	push   $0x0
f0104334:	6a 0f                	push   $0xf
f0104336:	e9 44 0a 00 00       	jmp    f0104d7f <_alltraps>
f010433b:	90                   	nop

f010433c <vector16>:
TRAPHANDLER_NOEC(vector16, 16)
f010433c:	6a 00                	push   $0x0
f010433e:	6a 10                	push   $0x10
f0104340:	e9 3a 0a 00 00       	jmp    f0104d7f <_alltraps>
f0104345:	90                   	nop

f0104346 <vector17>:
TRAPHANDLER(vector17, 17)
f0104346:	6a 11                	push   $0x11
f0104348:	e9 32 0a 00 00       	jmp    f0104d7f <_alltraps>
f010434d:	90                   	nop

f010434e <vector18>:
TRAPHANDLER_NOEC(vector18, 18)
f010434e:	6a 00                	push   $0x0
f0104350:	6a 12                	push   $0x12
f0104352:	e9 28 0a 00 00       	jmp    f0104d7f <_alltraps>
f0104357:	90                   	nop

f0104358 <vector19>:
TRAPHANDLER_NOEC(vector19, 19)
f0104358:	6a 00                	push   $0x0
f010435a:	6a 13                	push   $0x13
f010435c:	e9 1e 0a 00 00       	jmp    f0104d7f <_alltraps>
f0104361:	90                   	nop

f0104362 <vector20>:
TRAPHANDLER_NOEC(vector20, 20)
f0104362:	6a 00                	push   $0x0
f0104364:	6a 14                	push   $0x14
f0104366:	e9 14 0a 00 00       	jmp    f0104d7f <_alltraps>
f010436b:	90                   	nop

f010436c <vector21>:
TRAPHANDLER_NOEC(vector21, 21)
f010436c:	6a 00                	push   $0x0
f010436e:	6a 15                	push   $0x15
f0104370:	e9 0a 0a 00 00       	jmp    f0104d7f <_alltraps>
f0104375:	90                   	nop

f0104376 <vector22>:
TRAPHANDLER_NOEC(vector22, 22)
f0104376:	6a 00                	push   $0x0
f0104378:	6a 16                	push   $0x16
f010437a:	e9 00 0a 00 00       	jmp    f0104d7f <_alltraps>
f010437f:	90                   	nop

f0104380 <vector23>:
TRAPHANDLER_NOEC(vector23, 23)
f0104380:	6a 00                	push   $0x0
f0104382:	6a 17                	push   $0x17
f0104384:	e9 f6 09 00 00       	jmp    f0104d7f <_alltraps>
f0104389:	90                   	nop

f010438a <vector24>:
TRAPHANDLER_NOEC(vector24, 24)
f010438a:	6a 00                	push   $0x0
f010438c:	6a 18                	push   $0x18
f010438e:	e9 ec 09 00 00       	jmp    f0104d7f <_alltraps>
f0104393:	90                   	nop

f0104394 <vector25>:
TRAPHANDLER_NOEC(vector25, 25)
f0104394:	6a 00                	push   $0x0
f0104396:	6a 19                	push   $0x19
f0104398:	e9 e2 09 00 00       	jmp    f0104d7f <_alltraps>
f010439d:	90                   	nop

f010439e <vector26>:
TRAPHANDLER_NOEC(vector26, 26)
f010439e:	6a 00                	push   $0x0
f01043a0:	6a 1a                	push   $0x1a
f01043a2:	e9 d8 09 00 00       	jmp    f0104d7f <_alltraps>
f01043a7:	90                   	nop

f01043a8 <vector27>:
TRAPHANDLER_NOEC(vector27, 27)
f01043a8:	6a 00                	push   $0x0
f01043aa:	6a 1b                	push   $0x1b
f01043ac:	e9 ce 09 00 00       	jmp    f0104d7f <_alltraps>
f01043b1:	90                   	nop

f01043b2 <vector28>:
TRAPHANDLER_NOEC(vector28, 28)
f01043b2:	6a 00                	push   $0x0
f01043b4:	6a 1c                	push   $0x1c
f01043b6:	e9 c4 09 00 00       	jmp    f0104d7f <_alltraps>
f01043bb:	90                   	nop

f01043bc <vector29>:
TRAPHANDLER_NOEC(vector29, 29)
f01043bc:	6a 00                	push   $0x0
f01043be:	6a 1d                	push   $0x1d
f01043c0:	e9 ba 09 00 00       	jmp    f0104d7f <_alltraps>
f01043c5:	90                   	nop

f01043c6 <vector30>:
TRAPHANDLER_NOEC(vector30, 30)
f01043c6:	6a 00                	push   $0x0
f01043c8:	6a 1e                	push   $0x1e
f01043ca:	e9 b0 09 00 00       	jmp    f0104d7f <_alltraps>
f01043cf:	90                   	nop

f01043d0 <vector31>:
TRAPHANDLER_NOEC(vector31, 31)
f01043d0:	6a 00                	push   $0x0
f01043d2:	6a 1f                	push   $0x1f
f01043d4:	e9 a6 09 00 00       	jmp    f0104d7f <_alltraps>
f01043d9:	90                   	nop

f01043da <vector32>:
TRAPHANDLER_NOEC(vector32, 32)
f01043da:	6a 00                	push   $0x0
f01043dc:	6a 20                	push   $0x20
f01043de:	e9 9c 09 00 00       	jmp    f0104d7f <_alltraps>
f01043e3:	90                   	nop

f01043e4 <vector33>:
TRAPHANDLER_NOEC(vector33, 33)
f01043e4:	6a 00                	push   $0x0
f01043e6:	6a 21                	push   $0x21
f01043e8:	e9 92 09 00 00       	jmp    f0104d7f <_alltraps>
f01043ed:	90                   	nop

f01043ee <vector34>:
TRAPHANDLER_NOEC(vector34, 34)
f01043ee:	6a 00                	push   $0x0
f01043f0:	6a 22                	push   $0x22
f01043f2:	e9 88 09 00 00       	jmp    f0104d7f <_alltraps>
f01043f7:	90                   	nop

f01043f8 <vector35>:
TRAPHANDLER_NOEC(vector35, 35)
f01043f8:	6a 00                	push   $0x0
f01043fa:	6a 23                	push   $0x23
f01043fc:	e9 7e 09 00 00       	jmp    f0104d7f <_alltraps>
f0104401:	90                   	nop

f0104402 <vector36>:
TRAPHANDLER_NOEC(vector36, 36)
f0104402:	6a 00                	push   $0x0
f0104404:	6a 24                	push   $0x24
f0104406:	e9 74 09 00 00       	jmp    f0104d7f <_alltraps>
f010440b:	90                   	nop

f010440c <vector37>:
TRAPHANDLER_NOEC(vector37, 37)
f010440c:	6a 00                	push   $0x0
f010440e:	6a 25                	push   $0x25
f0104410:	e9 6a 09 00 00       	jmp    f0104d7f <_alltraps>
f0104415:	90                   	nop

f0104416 <vector38>:
TRAPHANDLER_NOEC(vector38, 38)
f0104416:	6a 00                	push   $0x0
f0104418:	6a 26                	push   $0x26
f010441a:	e9 60 09 00 00       	jmp    f0104d7f <_alltraps>
f010441f:	90                   	nop

f0104420 <vector39>:
TRAPHANDLER_NOEC(vector39, 39)
f0104420:	6a 00                	push   $0x0
f0104422:	6a 27                	push   $0x27
f0104424:	e9 56 09 00 00       	jmp    f0104d7f <_alltraps>
f0104429:	90                   	nop

f010442a <vector40>:
TRAPHANDLER_NOEC(vector40, 40)
f010442a:	6a 00                	push   $0x0
f010442c:	6a 28                	push   $0x28
f010442e:	e9 4c 09 00 00       	jmp    f0104d7f <_alltraps>
f0104433:	90                   	nop

f0104434 <vector41>:
TRAPHANDLER_NOEC(vector41, 41)
f0104434:	6a 00                	push   $0x0
f0104436:	6a 29                	push   $0x29
f0104438:	e9 42 09 00 00       	jmp    f0104d7f <_alltraps>
f010443d:	90                   	nop

f010443e <vector42>:
TRAPHANDLER_NOEC(vector42, 42)
f010443e:	6a 00                	push   $0x0
f0104440:	6a 2a                	push   $0x2a
f0104442:	e9 38 09 00 00       	jmp    f0104d7f <_alltraps>
f0104447:	90                   	nop

f0104448 <vector43>:
TRAPHANDLER_NOEC(vector43, 43)
f0104448:	6a 00                	push   $0x0
f010444a:	6a 2b                	push   $0x2b
f010444c:	e9 2e 09 00 00       	jmp    f0104d7f <_alltraps>
f0104451:	90                   	nop

f0104452 <vector44>:
TRAPHANDLER_NOEC(vector44, 44)
f0104452:	6a 00                	push   $0x0
f0104454:	6a 2c                	push   $0x2c
f0104456:	e9 24 09 00 00       	jmp    f0104d7f <_alltraps>
f010445b:	90                   	nop

f010445c <vector45>:
TRAPHANDLER_NOEC(vector45, 45)
f010445c:	6a 00                	push   $0x0
f010445e:	6a 2d                	push   $0x2d
f0104460:	e9 1a 09 00 00       	jmp    f0104d7f <_alltraps>
f0104465:	90                   	nop

f0104466 <vector46>:
TRAPHANDLER_NOEC(vector46, 46)
f0104466:	6a 00                	push   $0x0
f0104468:	6a 2e                	push   $0x2e
f010446a:	e9 10 09 00 00       	jmp    f0104d7f <_alltraps>
f010446f:	90                   	nop

f0104470 <vector47>:
TRAPHANDLER_NOEC(vector47, 47)
f0104470:	6a 00                	push   $0x0
f0104472:	6a 2f                	push   $0x2f
f0104474:	e9 06 09 00 00       	jmp    f0104d7f <_alltraps>
f0104479:	90                   	nop

f010447a <vector48>:
TRAPHANDLER_NOEC(vector48, 48)
f010447a:	6a 00                	push   $0x0
f010447c:	6a 30                	push   $0x30
f010447e:	e9 fc 08 00 00       	jmp    f0104d7f <_alltraps>
f0104483:	90                   	nop

f0104484 <vector49>:
TRAPHANDLER_NOEC(vector49, 49)
f0104484:	6a 00                	push   $0x0
f0104486:	6a 31                	push   $0x31
f0104488:	e9 f2 08 00 00       	jmp    f0104d7f <_alltraps>
f010448d:	90                   	nop

f010448e <vector50>:
TRAPHANDLER_NOEC(vector50, 50)
f010448e:	6a 00                	push   $0x0
f0104490:	6a 32                	push   $0x32
f0104492:	e9 e8 08 00 00       	jmp    f0104d7f <_alltraps>
f0104497:	90                   	nop

f0104498 <vector51>:
TRAPHANDLER_NOEC(vector51, 51)
f0104498:	6a 00                	push   $0x0
f010449a:	6a 33                	push   $0x33
f010449c:	e9 de 08 00 00       	jmp    f0104d7f <_alltraps>
f01044a1:	90                   	nop

f01044a2 <vector52>:
TRAPHANDLER_NOEC(vector52, 52)
f01044a2:	6a 00                	push   $0x0
f01044a4:	6a 34                	push   $0x34
f01044a6:	e9 d4 08 00 00       	jmp    f0104d7f <_alltraps>
f01044ab:	90                   	nop

f01044ac <vector53>:
TRAPHANDLER_NOEC(vector53, 53)
f01044ac:	6a 00                	push   $0x0
f01044ae:	6a 35                	push   $0x35
f01044b0:	e9 ca 08 00 00       	jmp    f0104d7f <_alltraps>
f01044b5:	90                   	nop

f01044b6 <vector54>:
TRAPHANDLER_NOEC(vector54, 54)
f01044b6:	6a 00                	push   $0x0
f01044b8:	6a 36                	push   $0x36
f01044ba:	e9 c0 08 00 00       	jmp    f0104d7f <_alltraps>
f01044bf:	90                   	nop

f01044c0 <vector55>:
TRAPHANDLER_NOEC(vector55, 55)
f01044c0:	6a 00                	push   $0x0
f01044c2:	6a 37                	push   $0x37
f01044c4:	e9 b6 08 00 00       	jmp    f0104d7f <_alltraps>
f01044c9:	90                   	nop

f01044ca <vector56>:
TRAPHANDLER_NOEC(vector56, 56)
f01044ca:	6a 00                	push   $0x0
f01044cc:	6a 38                	push   $0x38
f01044ce:	e9 ac 08 00 00       	jmp    f0104d7f <_alltraps>
f01044d3:	90                   	nop

f01044d4 <vector57>:
TRAPHANDLER_NOEC(vector57, 57)
f01044d4:	6a 00                	push   $0x0
f01044d6:	6a 39                	push   $0x39
f01044d8:	e9 a2 08 00 00       	jmp    f0104d7f <_alltraps>
f01044dd:	90                   	nop

f01044de <vector58>:
TRAPHANDLER_NOEC(vector58, 58)
f01044de:	6a 00                	push   $0x0
f01044e0:	6a 3a                	push   $0x3a
f01044e2:	e9 98 08 00 00       	jmp    f0104d7f <_alltraps>
f01044e7:	90                   	nop

f01044e8 <vector59>:
TRAPHANDLER_NOEC(vector59, 59)
f01044e8:	6a 00                	push   $0x0
f01044ea:	6a 3b                	push   $0x3b
f01044ec:	e9 8e 08 00 00       	jmp    f0104d7f <_alltraps>
f01044f1:	90                   	nop

f01044f2 <vector60>:
TRAPHANDLER_NOEC(vector60, 60)
f01044f2:	6a 00                	push   $0x0
f01044f4:	6a 3c                	push   $0x3c
f01044f6:	e9 84 08 00 00       	jmp    f0104d7f <_alltraps>
f01044fb:	90                   	nop

f01044fc <vector61>:
TRAPHANDLER_NOEC(vector61, 61)
f01044fc:	6a 00                	push   $0x0
f01044fe:	6a 3d                	push   $0x3d
f0104500:	e9 7a 08 00 00       	jmp    f0104d7f <_alltraps>
f0104505:	90                   	nop

f0104506 <vector62>:
TRAPHANDLER_NOEC(vector62, 62)
f0104506:	6a 00                	push   $0x0
f0104508:	6a 3e                	push   $0x3e
f010450a:	e9 70 08 00 00       	jmp    f0104d7f <_alltraps>
f010450f:	90                   	nop

f0104510 <vector63>:
TRAPHANDLER_NOEC(vector63, 63)
f0104510:	6a 00                	push   $0x0
f0104512:	6a 3f                	push   $0x3f
f0104514:	e9 66 08 00 00       	jmp    f0104d7f <_alltraps>
f0104519:	90                   	nop

f010451a <vector64>:
TRAPHANDLER_NOEC(vector64, 64)
f010451a:	6a 00                	push   $0x0
f010451c:	6a 40                	push   $0x40
f010451e:	e9 5c 08 00 00       	jmp    f0104d7f <_alltraps>
f0104523:	90                   	nop

f0104524 <vector65>:
TRAPHANDLER_NOEC(vector65, 65)
f0104524:	6a 00                	push   $0x0
f0104526:	6a 41                	push   $0x41
f0104528:	e9 52 08 00 00       	jmp    f0104d7f <_alltraps>
f010452d:	90                   	nop

f010452e <vector66>:
TRAPHANDLER_NOEC(vector66, 66)
f010452e:	6a 00                	push   $0x0
f0104530:	6a 42                	push   $0x42
f0104532:	e9 48 08 00 00       	jmp    f0104d7f <_alltraps>
f0104537:	90                   	nop

f0104538 <vector67>:
TRAPHANDLER_NOEC(vector67, 67)
f0104538:	6a 00                	push   $0x0
f010453a:	6a 43                	push   $0x43
f010453c:	e9 3e 08 00 00       	jmp    f0104d7f <_alltraps>
f0104541:	90                   	nop

f0104542 <vector68>:
TRAPHANDLER_NOEC(vector68, 68)
f0104542:	6a 00                	push   $0x0
f0104544:	6a 44                	push   $0x44
f0104546:	e9 34 08 00 00       	jmp    f0104d7f <_alltraps>
f010454b:	90                   	nop

f010454c <vector69>:
TRAPHANDLER_NOEC(vector69, 69)
f010454c:	6a 00                	push   $0x0
f010454e:	6a 45                	push   $0x45
f0104550:	e9 2a 08 00 00       	jmp    f0104d7f <_alltraps>
f0104555:	90                   	nop

f0104556 <vector70>:
TRAPHANDLER_NOEC(vector70, 70)
f0104556:	6a 00                	push   $0x0
f0104558:	6a 46                	push   $0x46
f010455a:	e9 20 08 00 00       	jmp    f0104d7f <_alltraps>
f010455f:	90                   	nop

f0104560 <vector71>:
TRAPHANDLER_NOEC(vector71, 71)
f0104560:	6a 00                	push   $0x0
f0104562:	6a 47                	push   $0x47
f0104564:	e9 16 08 00 00       	jmp    f0104d7f <_alltraps>
f0104569:	90                   	nop

f010456a <vector72>:
TRAPHANDLER_NOEC(vector72, 72)
f010456a:	6a 00                	push   $0x0
f010456c:	6a 48                	push   $0x48
f010456e:	e9 0c 08 00 00       	jmp    f0104d7f <_alltraps>
f0104573:	90                   	nop

f0104574 <vector73>:
TRAPHANDLER_NOEC(vector73, 73)
f0104574:	6a 00                	push   $0x0
f0104576:	6a 49                	push   $0x49
f0104578:	e9 02 08 00 00       	jmp    f0104d7f <_alltraps>
f010457d:	90                   	nop

f010457e <vector74>:
TRAPHANDLER_NOEC(vector74, 74)
f010457e:	6a 00                	push   $0x0
f0104580:	6a 4a                	push   $0x4a
f0104582:	e9 f8 07 00 00       	jmp    f0104d7f <_alltraps>
f0104587:	90                   	nop

f0104588 <vector75>:
TRAPHANDLER_NOEC(vector75, 75)
f0104588:	6a 00                	push   $0x0
f010458a:	6a 4b                	push   $0x4b
f010458c:	e9 ee 07 00 00       	jmp    f0104d7f <_alltraps>
f0104591:	90                   	nop

f0104592 <vector76>:
TRAPHANDLER_NOEC(vector76, 76)
f0104592:	6a 00                	push   $0x0
f0104594:	6a 4c                	push   $0x4c
f0104596:	e9 e4 07 00 00       	jmp    f0104d7f <_alltraps>
f010459b:	90                   	nop

f010459c <vector77>:
TRAPHANDLER_NOEC(vector77, 77)
f010459c:	6a 00                	push   $0x0
f010459e:	6a 4d                	push   $0x4d
f01045a0:	e9 da 07 00 00       	jmp    f0104d7f <_alltraps>
f01045a5:	90                   	nop

f01045a6 <vector78>:
TRAPHANDLER_NOEC(vector78, 78)
f01045a6:	6a 00                	push   $0x0
f01045a8:	6a 4e                	push   $0x4e
f01045aa:	e9 d0 07 00 00       	jmp    f0104d7f <_alltraps>
f01045af:	90                   	nop

f01045b0 <vector79>:
TRAPHANDLER_NOEC(vector79, 79)
f01045b0:	6a 00                	push   $0x0
f01045b2:	6a 4f                	push   $0x4f
f01045b4:	e9 c6 07 00 00       	jmp    f0104d7f <_alltraps>
f01045b9:	90                   	nop

f01045ba <vector80>:
TRAPHANDLER_NOEC(vector80, 80)
f01045ba:	6a 00                	push   $0x0
f01045bc:	6a 50                	push   $0x50
f01045be:	e9 bc 07 00 00       	jmp    f0104d7f <_alltraps>
f01045c3:	90                   	nop

f01045c4 <vector81>:
TRAPHANDLER_NOEC(vector81, 81)
f01045c4:	6a 00                	push   $0x0
f01045c6:	6a 51                	push   $0x51
f01045c8:	e9 b2 07 00 00       	jmp    f0104d7f <_alltraps>
f01045cd:	90                   	nop

f01045ce <vector82>:
TRAPHANDLER_NOEC(vector82, 82)
f01045ce:	6a 00                	push   $0x0
f01045d0:	6a 52                	push   $0x52
f01045d2:	e9 a8 07 00 00       	jmp    f0104d7f <_alltraps>
f01045d7:	90                   	nop

f01045d8 <vector83>:
TRAPHANDLER_NOEC(vector83, 83)
f01045d8:	6a 00                	push   $0x0
f01045da:	6a 53                	push   $0x53
f01045dc:	e9 9e 07 00 00       	jmp    f0104d7f <_alltraps>
f01045e1:	90                   	nop

f01045e2 <vector84>:
TRAPHANDLER_NOEC(vector84, 84)
f01045e2:	6a 00                	push   $0x0
f01045e4:	6a 54                	push   $0x54
f01045e6:	e9 94 07 00 00       	jmp    f0104d7f <_alltraps>
f01045eb:	90                   	nop

f01045ec <vector85>:
TRAPHANDLER_NOEC(vector85, 85)
f01045ec:	6a 00                	push   $0x0
f01045ee:	6a 55                	push   $0x55
f01045f0:	e9 8a 07 00 00       	jmp    f0104d7f <_alltraps>
f01045f5:	90                   	nop

f01045f6 <vector86>:
TRAPHANDLER_NOEC(vector86, 86)
f01045f6:	6a 00                	push   $0x0
f01045f8:	6a 56                	push   $0x56
f01045fa:	e9 80 07 00 00       	jmp    f0104d7f <_alltraps>
f01045ff:	90                   	nop

f0104600 <vector87>:
TRAPHANDLER_NOEC(vector87, 87)
f0104600:	6a 00                	push   $0x0
f0104602:	6a 57                	push   $0x57
f0104604:	e9 76 07 00 00       	jmp    f0104d7f <_alltraps>
f0104609:	90                   	nop

f010460a <vector88>:
TRAPHANDLER_NOEC(vector88, 88)
f010460a:	6a 00                	push   $0x0
f010460c:	6a 58                	push   $0x58
f010460e:	e9 6c 07 00 00       	jmp    f0104d7f <_alltraps>
f0104613:	90                   	nop

f0104614 <vector89>:
TRAPHANDLER_NOEC(vector89, 89)
f0104614:	6a 00                	push   $0x0
f0104616:	6a 59                	push   $0x59
f0104618:	e9 62 07 00 00       	jmp    f0104d7f <_alltraps>
f010461d:	90                   	nop

f010461e <vector90>:
TRAPHANDLER_NOEC(vector90, 90)
f010461e:	6a 00                	push   $0x0
f0104620:	6a 5a                	push   $0x5a
f0104622:	e9 58 07 00 00       	jmp    f0104d7f <_alltraps>
f0104627:	90                   	nop

f0104628 <vector91>:
TRAPHANDLER_NOEC(vector91, 91)
f0104628:	6a 00                	push   $0x0
f010462a:	6a 5b                	push   $0x5b
f010462c:	e9 4e 07 00 00       	jmp    f0104d7f <_alltraps>
f0104631:	90                   	nop

f0104632 <vector92>:
TRAPHANDLER_NOEC(vector92, 92)
f0104632:	6a 00                	push   $0x0
f0104634:	6a 5c                	push   $0x5c
f0104636:	e9 44 07 00 00       	jmp    f0104d7f <_alltraps>
f010463b:	90                   	nop

f010463c <vector93>:
TRAPHANDLER_NOEC(vector93, 93)
f010463c:	6a 00                	push   $0x0
f010463e:	6a 5d                	push   $0x5d
f0104640:	e9 3a 07 00 00       	jmp    f0104d7f <_alltraps>
f0104645:	90                   	nop

f0104646 <vector94>:
TRAPHANDLER_NOEC(vector94, 94)
f0104646:	6a 00                	push   $0x0
f0104648:	6a 5e                	push   $0x5e
f010464a:	e9 30 07 00 00       	jmp    f0104d7f <_alltraps>
f010464f:	90                   	nop

f0104650 <vector95>:
TRAPHANDLER_NOEC(vector95, 95)
f0104650:	6a 00                	push   $0x0
f0104652:	6a 5f                	push   $0x5f
f0104654:	e9 26 07 00 00       	jmp    f0104d7f <_alltraps>
f0104659:	90                   	nop

f010465a <vector96>:
TRAPHANDLER_NOEC(vector96, 96)
f010465a:	6a 00                	push   $0x0
f010465c:	6a 60                	push   $0x60
f010465e:	e9 1c 07 00 00       	jmp    f0104d7f <_alltraps>
f0104663:	90                   	nop

f0104664 <vector97>:
TRAPHANDLER_NOEC(vector97, 97)
f0104664:	6a 00                	push   $0x0
f0104666:	6a 61                	push   $0x61
f0104668:	e9 12 07 00 00       	jmp    f0104d7f <_alltraps>
f010466d:	90                   	nop

f010466e <vector98>:
TRAPHANDLER_NOEC(vector98, 98)
f010466e:	6a 00                	push   $0x0
f0104670:	6a 62                	push   $0x62
f0104672:	e9 08 07 00 00       	jmp    f0104d7f <_alltraps>
f0104677:	90                   	nop

f0104678 <vector99>:
TRAPHANDLER_NOEC(vector99, 99)
f0104678:	6a 00                	push   $0x0
f010467a:	6a 63                	push   $0x63
f010467c:	e9 fe 06 00 00       	jmp    f0104d7f <_alltraps>
f0104681:	90                   	nop

f0104682 <vector100>:
TRAPHANDLER_NOEC(vector100, 100)
f0104682:	6a 00                	push   $0x0
f0104684:	6a 64                	push   $0x64
f0104686:	e9 f4 06 00 00       	jmp    f0104d7f <_alltraps>
f010468b:	90                   	nop

f010468c <vector101>:
TRAPHANDLER_NOEC(vector101, 101)
f010468c:	6a 00                	push   $0x0
f010468e:	6a 65                	push   $0x65
f0104690:	e9 ea 06 00 00       	jmp    f0104d7f <_alltraps>
f0104695:	90                   	nop

f0104696 <vector102>:
TRAPHANDLER_NOEC(vector102, 102)
f0104696:	6a 00                	push   $0x0
f0104698:	6a 66                	push   $0x66
f010469a:	e9 e0 06 00 00       	jmp    f0104d7f <_alltraps>
f010469f:	90                   	nop

f01046a0 <vector103>:
TRAPHANDLER_NOEC(vector103, 103)
f01046a0:	6a 00                	push   $0x0
f01046a2:	6a 67                	push   $0x67
f01046a4:	e9 d6 06 00 00       	jmp    f0104d7f <_alltraps>
f01046a9:	90                   	nop

f01046aa <vector104>:
TRAPHANDLER_NOEC(vector104, 104)
f01046aa:	6a 00                	push   $0x0
f01046ac:	6a 68                	push   $0x68
f01046ae:	e9 cc 06 00 00       	jmp    f0104d7f <_alltraps>
f01046b3:	90                   	nop

f01046b4 <vector105>:
TRAPHANDLER_NOEC(vector105, 105)
f01046b4:	6a 00                	push   $0x0
f01046b6:	6a 69                	push   $0x69
f01046b8:	e9 c2 06 00 00       	jmp    f0104d7f <_alltraps>
f01046bd:	90                   	nop

f01046be <vector106>:
TRAPHANDLER_NOEC(vector106, 106)
f01046be:	6a 00                	push   $0x0
f01046c0:	6a 6a                	push   $0x6a
f01046c2:	e9 b8 06 00 00       	jmp    f0104d7f <_alltraps>
f01046c7:	90                   	nop

f01046c8 <vector107>:
TRAPHANDLER_NOEC(vector107, 107)
f01046c8:	6a 00                	push   $0x0
f01046ca:	6a 6b                	push   $0x6b
f01046cc:	e9 ae 06 00 00       	jmp    f0104d7f <_alltraps>
f01046d1:	90                   	nop

f01046d2 <vector108>:
TRAPHANDLER_NOEC(vector108, 108)
f01046d2:	6a 00                	push   $0x0
f01046d4:	6a 6c                	push   $0x6c
f01046d6:	e9 a4 06 00 00       	jmp    f0104d7f <_alltraps>
f01046db:	90                   	nop

f01046dc <vector109>:
TRAPHANDLER_NOEC(vector109, 109)
f01046dc:	6a 00                	push   $0x0
f01046de:	6a 6d                	push   $0x6d
f01046e0:	e9 9a 06 00 00       	jmp    f0104d7f <_alltraps>
f01046e5:	90                   	nop

f01046e6 <vector110>:
TRAPHANDLER_NOEC(vector110, 110)
f01046e6:	6a 00                	push   $0x0
f01046e8:	6a 6e                	push   $0x6e
f01046ea:	e9 90 06 00 00       	jmp    f0104d7f <_alltraps>
f01046ef:	90                   	nop

f01046f0 <vector111>:
TRAPHANDLER_NOEC(vector111, 111)
f01046f0:	6a 00                	push   $0x0
f01046f2:	6a 6f                	push   $0x6f
f01046f4:	e9 86 06 00 00       	jmp    f0104d7f <_alltraps>
f01046f9:	90                   	nop

f01046fa <vector112>:
TRAPHANDLER_NOEC(vector112, 112)
f01046fa:	6a 00                	push   $0x0
f01046fc:	6a 70                	push   $0x70
f01046fe:	e9 7c 06 00 00       	jmp    f0104d7f <_alltraps>
f0104703:	90                   	nop

f0104704 <vector113>:
TRAPHANDLER_NOEC(vector113, 113)
f0104704:	6a 00                	push   $0x0
f0104706:	6a 71                	push   $0x71
f0104708:	e9 72 06 00 00       	jmp    f0104d7f <_alltraps>
f010470d:	90                   	nop

f010470e <vector114>:
TRAPHANDLER_NOEC(vector114, 114)
f010470e:	6a 00                	push   $0x0
f0104710:	6a 72                	push   $0x72
f0104712:	e9 68 06 00 00       	jmp    f0104d7f <_alltraps>
f0104717:	90                   	nop

f0104718 <vector115>:
TRAPHANDLER_NOEC(vector115, 115)
f0104718:	6a 00                	push   $0x0
f010471a:	6a 73                	push   $0x73
f010471c:	e9 5e 06 00 00       	jmp    f0104d7f <_alltraps>
f0104721:	90                   	nop

f0104722 <vector116>:
TRAPHANDLER_NOEC(vector116, 116)
f0104722:	6a 00                	push   $0x0
f0104724:	6a 74                	push   $0x74
f0104726:	e9 54 06 00 00       	jmp    f0104d7f <_alltraps>
f010472b:	90                   	nop

f010472c <vector117>:
TRAPHANDLER_NOEC(vector117, 117)
f010472c:	6a 00                	push   $0x0
f010472e:	6a 75                	push   $0x75
f0104730:	e9 4a 06 00 00       	jmp    f0104d7f <_alltraps>
f0104735:	90                   	nop

f0104736 <vector118>:
TRAPHANDLER_NOEC(vector118, 118)
f0104736:	6a 00                	push   $0x0
f0104738:	6a 76                	push   $0x76
f010473a:	e9 40 06 00 00       	jmp    f0104d7f <_alltraps>
f010473f:	90                   	nop

f0104740 <vector119>:
TRAPHANDLER_NOEC(vector119, 119)
f0104740:	6a 00                	push   $0x0
f0104742:	6a 77                	push   $0x77
f0104744:	e9 36 06 00 00       	jmp    f0104d7f <_alltraps>
f0104749:	90                   	nop

f010474a <vector120>:
TRAPHANDLER_NOEC(vector120, 120)
f010474a:	6a 00                	push   $0x0
f010474c:	6a 78                	push   $0x78
f010474e:	e9 2c 06 00 00       	jmp    f0104d7f <_alltraps>
f0104753:	90                   	nop

f0104754 <vector121>:
TRAPHANDLER_NOEC(vector121, 121)
f0104754:	6a 00                	push   $0x0
f0104756:	6a 79                	push   $0x79
f0104758:	e9 22 06 00 00       	jmp    f0104d7f <_alltraps>
f010475d:	90                   	nop

f010475e <vector122>:
TRAPHANDLER_NOEC(vector122, 122)
f010475e:	6a 00                	push   $0x0
f0104760:	6a 7a                	push   $0x7a
f0104762:	e9 18 06 00 00       	jmp    f0104d7f <_alltraps>
f0104767:	90                   	nop

f0104768 <vector123>:
TRAPHANDLER_NOEC(vector123, 123)
f0104768:	6a 00                	push   $0x0
f010476a:	6a 7b                	push   $0x7b
f010476c:	e9 0e 06 00 00       	jmp    f0104d7f <_alltraps>
f0104771:	90                   	nop

f0104772 <vector124>:
TRAPHANDLER_NOEC(vector124, 124)
f0104772:	6a 00                	push   $0x0
f0104774:	6a 7c                	push   $0x7c
f0104776:	e9 04 06 00 00       	jmp    f0104d7f <_alltraps>
f010477b:	90                   	nop

f010477c <vector125>:
TRAPHANDLER_NOEC(vector125, 125)
f010477c:	6a 00                	push   $0x0
f010477e:	6a 7d                	push   $0x7d
f0104780:	e9 fa 05 00 00       	jmp    f0104d7f <_alltraps>
f0104785:	90                   	nop

f0104786 <vector126>:
TRAPHANDLER_NOEC(vector126, 126)
f0104786:	6a 00                	push   $0x0
f0104788:	6a 7e                	push   $0x7e
f010478a:	e9 f0 05 00 00       	jmp    f0104d7f <_alltraps>
f010478f:	90                   	nop

f0104790 <vector127>:
TRAPHANDLER_NOEC(vector127, 127)
f0104790:	6a 00                	push   $0x0
f0104792:	6a 7f                	push   $0x7f
f0104794:	e9 e6 05 00 00       	jmp    f0104d7f <_alltraps>
f0104799:	90                   	nop

f010479a <vector128>:
TRAPHANDLER_NOEC(vector128, 128)
f010479a:	6a 00                	push   $0x0
f010479c:	68 80 00 00 00       	push   $0x80
f01047a1:	e9 d9 05 00 00       	jmp    f0104d7f <_alltraps>

f01047a6 <vector129>:
TRAPHANDLER_NOEC(vector129, 129)
f01047a6:	6a 00                	push   $0x0
f01047a8:	68 81 00 00 00       	push   $0x81
f01047ad:	e9 cd 05 00 00       	jmp    f0104d7f <_alltraps>

f01047b2 <vector130>:
TRAPHANDLER_NOEC(vector130, 130)
f01047b2:	6a 00                	push   $0x0
f01047b4:	68 82 00 00 00       	push   $0x82
f01047b9:	e9 c1 05 00 00       	jmp    f0104d7f <_alltraps>

f01047be <vector131>:
TRAPHANDLER_NOEC(vector131, 131)
f01047be:	6a 00                	push   $0x0
f01047c0:	68 83 00 00 00       	push   $0x83
f01047c5:	e9 b5 05 00 00       	jmp    f0104d7f <_alltraps>

f01047ca <vector132>:
TRAPHANDLER_NOEC(vector132, 132)
f01047ca:	6a 00                	push   $0x0
f01047cc:	68 84 00 00 00       	push   $0x84
f01047d1:	e9 a9 05 00 00       	jmp    f0104d7f <_alltraps>

f01047d6 <vector133>:
TRAPHANDLER_NOEC(vector133, 133)
f01047d6:	6a 00                	push   $0x0
f01047d8:	68 85 00 00 00       	push   $0x85
f01047dd:	e9 9d 05 00 00       	jmp    f0104d7f <_alltraps>

f01047e2 <vector134>:
TRAPHANDLER_NOEC(vector134, 134)
f01047e2:	6a 00                	push   $0x0
f01047e4:	68 86 00 00 00       	push   $0x86
f01047e9:	e9 91 05 00 00       	jmp    f0104d7f <_alltraps>

f01047ee <vector135>:
TRAPHANDLER_NOEC(vector135, 135)
f01047ee:	6a 00                	push   $0x0
f01047f0:	68 87 00 00 00       	push   $0x87
f01047f5:	e9 85 05 00 00       	jmp    f0104d7f <_alltraps>

f01047fa <vector136>:
TRAPHANDLER_NOEC(vector136, 136)
f01047fa:	6a 00                	push   $0x0
f01047fc:	68 88 00 00 00       	push   $0x88
f0104801:	e9 79 05 00 00       	jmp    f0104d7f <_alltraps>

f0104806 <vector137>:
TRAPHANDLER_NOEC(vector137, 137)
f0104806:	6a 00                	push   $0x0
f0104808:	68 89 00 00 00       	push   $0x89
f010480d:	e9 6d 05 00 00       	jmp    f0104d7f <_alltraps>

f0104812 <vector138>:
TRAPHANDLER_NOEC(vector138, 138)
f0104812:	6a 00                	push   $0x0
f0104814:	68 8a 00 00 00       	push   $0x8a
f0104819:	e9 61 05 00 00       	jmp    f0104d7f <_alltraps>

f010481e <vector139>:
TRAPHANDLER_NOEC(vector139, 139)
f010481e:	6a 00                	push   $0x0
f0104820:	68 8b 00 00 00       	push   $0x8b
f0104825:	e9 55 05 00 00       	jmp    f0104d7f <_alltraps>

f010482a <vector140>:
TRAPHANDLER_NOEC(vector140, 140)
f010482a:	6a 00                	push   $0x0
f010482c:	68 8c 00 00 00       	push   $0x8c
f0104831:	e9 49 05 00 00       	jmp    f0104d7f <_alltraps>

f0104836 <vector141>:
TRAPHANDLER_NOEC(vector141, 141)
f0104836:	6a 00                	push   $0x0
f0104838:	68 8d 00 00 00       	push   $0x8d
f010483d:	e9 3d 05 00 00       	jmp    f0104d7f <_alltraps>

f0104842 <vector142>:
TRAPHANDLER_NOEC(vector142, 142)
f0104842:	6a 00                	push   $0x0
f0104844:	68 8e 00 00 00       	push   $0x8e
f0104849:	e9 31 05 00 00       	jmp    f0104d7f <_alltraps>

f010484e <vector143>:
TRAPHANDLER_NOEC(vector143, 143)
f010484e:	6a 00                	push   $0x0
f0104850:	68 8f 00 00 00       	push   $0x8f
f0104855:	e9 25 05 00 00       	jmp    f0104d7f <_alltraps>

f010485a <vector144>:
TRAPHANDLER_NOEC(vector144, 144)
f010485a:	6a 00                	push   $0x0
f010485c:	68 90 00 00 00       	push   $0x90
f0104861:	e9 19 05 00 00       	jmp    f0104d7f <_alltraps>

f0104866 <vector145>:
TRAPHANDLER_NOEC(vector145, 145)
f0104866:	6a 00                	push   $0x0
f0104868:	68 91 00 00 00       	push   $0x91
f010486d:	e9 0d 05 00 00       	jmp    f0104d7f <_alltraps>

f0104872 <vector146>:
TRAPHANDLER_NOEC(vector146, 146)
f0104872:	6a 00                	push   $0x0
f0104874:	68 92 00 00 00       	push   $0x92
f0104879:	e9 01 05 00 00       	jmp    f0104d7f <_alltraps>

f010487e <vector147>:
TRAPHANDLER_NOEC(vector147, 147)
f010487e:	6a 00                	push   $0x0
f0104880:	68 93 00 00 00       	push   $0x93
f0104885:	e9 f5 04 00 00       	jmp    f0104d7f <_alltraps>

f010488a <vector148>:
TRAPHANDLER_NOEC(vector148, 148)
f010488a:	6a 00                	push   $0x0
f010488c:	68 94 00 00 00       	push   $0x94
f0104891:	e9 e9 04 00 00       	jmp    f0104d7f <_alltraps>

f0104896 <vector149>:
TRAPHANDLER_NOEC(vector149, 149)
f0104896:	6a 00                	push   $0x0
f0104898:	68 95 00 00 00       	push   $0x95
f010489d:	e9 dd 04 00 00       	jmp    f0104d7f <_alltraps>

f01048a2 <vector150>:
TRAPHANDLER_NOEC(vector150, 150)
f01048a2:	6a 00                	push   $0x0
f01048a4:	68 96 00 00 00       	push   $0x96
f01048a9:	e9 d1 04 00 00       	jmp    f0104d7f <_alltraps>

f01048ae <vector151>:
TRAPHANDLER_NOEC(vector151, 151)
f01048ae:	6a 00                	push   $0x0
f01048b0:	68 97 00 00 00       	push   $0x97
f01048b5:	e9 c5 04 00 00       	jmp    f0104d7f <_alltraps>

f01048ba <vector152>:
TRAPHANDLER_NOEC(vector152, 152)
f01048ba:	6a 00                	push   $0x0
f01048bc:	68 98 00 00 00       	push   $0x98
f01048c1:	e9 b9 04 00 00       	jmp    f0104d7f <_alltraps>

f01048c6 <vector153>:
TRAPHANDLER_NOEC(vector153, 153)
f01048c6:	6a 00                	push   $0x0
f01048c8:	68 99 00 00 00       	push   $0x99
f01048cd:	e9 ad 04 00 00       	jmp    f0104d7f <_alltraps>

f01048d2 <vector154>:
TRAPHANDLER_NOEC(vector154, 154)
f01048d2:	6a 00                	push   $0x0
f01048d4:	68 9a 00 00 00       	push   $0x9a
f01048d9:	e9 a1 04 00 00       	jmp    f0104d7f <_alltraps>

f01048de <vector155>:
TRAPHANDLER_NOEC(vector155, 155)
f01048de:	6a 00                	push   $0x0
f01048e0:	68 9b 00 00 00       	push   $0x9b
f01048e5:	e9 95 04 00 00       	jmp    f0104d7f <_alltraps>

f01048ea <vector156>:
TRAPHANDLER_NOEC(vector156, 156)
f01048ea:	6a 00                	push   $0x0
f01048ec:	68 9c 00 00 00       	push   $0x9c
f01048f1:	e9 89 04 00 00       	jmp    f0104d7f <_alltraps>

f01048f6 <vector157>:
TRAPHANDLER_NOEC(vector157, 157)
f01048f6:	6a 00                	push   $0x0
f01048f8:	68 9d 00 00 00       	push   $0x9d
f01048fd:	e9 7d 04 00 00       	jmp    f0104d7f <_alltraps>

f0104902 <vector158>:
TRAPHANDLER_NOEC(vector158, 158)
f0104902:	6a 00                	push   $0x0
f0104904:	68 9e 00 00 00       	push   $0x9e
f0104909:	e9 71 04 00 00       	jmp    f0104d7f <_alltraps>

f010490e <vector159>:
TRAPHANDLER_NOEC(vector159, 159)
f010490e:	6a 00                	push   $0x0
f0104910:	68 9f 00 00 00       	push   $0x9f
f0104915:	e9 65 04 00 00       	jmp    f0104d7f <_alltraps>

f010491a <vector160>:
TRAPHANDLER_NOEC(vector160, 160)
f010491a:	6a 00                	push   $0x0
f010491c:	68 a0 00 00 00       	push   $0xa0
f0104921:	e9 59 04 00 00       	jmp    f0104d7f <_alltraps>

f0104926 <vector161>:
TRAPHANDLER_NOEC(vector161, 161)
f0104926:	6a 00                	push   $0x0
f0104928:	68 a1 00 00 00       	push   $0xa1
f010492d:	e9 4d 04 00 00       	jmp    f0104d7f <_alltraps>

f0104932 <vector162>:
TRAPHANDLER_NOEC(vector162, 162)
f0104932:	6a 00                	push   $0x0
f0104934:	68 a2 00 00 00       	push   $0xa2
f0104939:	e9 41 04 00 00       	jmp    f0104d7f <_alltraps>

f010493e <vector163>:
TRAPHANDLER_NOEC(vector163, 163)
f010493e:	6a 00                	push   $0x0
f0104940:	68 a3 00 00 00       	push   $0xa3
f0104945:	e9 35 04 00 00       	jmp    f0104d7f <_alltraps>

f010494a <vector164>:
TRAPHANDLER_NOEC(vector164, 164)
f010494a:	6a 00                	push   $0x0
f010494c:	68 a4 00 00 00       	push   $0xa4
f0104951:	e9 29 04 00 00       	jmp    f0104d7f <_alltraps>

f0104956 <vector165>:
TRAPHANDLER_NOEC(vector165, 165)
f0104956:	6a 00                	push   $0x0
f0104958:	68 a5 00 00 00       	push   $0xa5
f010495d:	e9 1d 04 00 00       	jmp    f0104d7f <_alltraps>

f0104962 <vector166>:
TRAPHANDLER_NOEC(vector166, 166)
f0104962:	6a 00                	push   $0x0
f0104964:	68 a6 00 00 00       	push   $0xa6
f0104969:	e9 11 04 00 00       	jmp    f0104d7f <_alltraps>

f010496e <vector167>:
TRAPHANDLER_NOEC(vector167, 167)
f010496e:	6a 00                	push   $0x0
f0104970:	68 a7 00 00 00       	push   $0xa7
f0104975:	e9 05 04 00 00       	jmp    f0104d7f <_alltraps>

f010497a <vector168>:
TRAPHANDLER_NOEC(vector168, 168)
f010497a:	6a 00                	push   $0x0
f010497c:	68 a8 00 00 00       	push   $0xa8
f0104981:	e9 f9 03 00 00       	jmp    f0104d7f <_alltraps>

f0104986 <vector169>:
TRAPHANDLER_NOEC(vector169, 169)
f0104986:	6a 00                	push   $0x0
f0104988:	68 a9 00 00 00       	push   $0xa9
f010498d:	e9 ed 03 00 00       	jmp    f0104d7f <_alltraps>

f0104992 <vector170>:
TRAPHANDLER_NOEC(vector170, 170)
f0104992:	6a 00                	push   $0x0
f0104994:	68 aa 00 00 00       	push   $0xaa
f0104999:	e9 e1 03 00 00       	jmp    f0104d7f <_alltraps>

f010499e <vector171>:
TRAPHANDLER_NOEC(vector171, 171)
f010499e:	6a 00                	push   $0x0
f01049a0:	68 ab 00 00 00       	push   $0xab
f01049a5:	e9 d5 03 00 00       	jmp    f0104d7f <_alltraps>

f01049aa <vector172>:
TRAPHANDLER_NOEC(vector172, 172)
f01049aa:	6a 00                	push   $0x0
f01049ac:	68 ac 00 00 00       	push   $0xac
f01049b1:	e9 c9 03 00 00       	jmp    f0104d7f <_alltraps>

f01049b6 <vector173>:
TRAPHANDLER_NOEC(vector173, 173)
f01049b6:	6a 00                	push   $0x0
f01049b8:	68 ad 00 00 00       	push   $0xad
f01049bd:	e9 bd 03 00 00       	jmp    f0104d7f <_alltraps>

f01049c2 <vector174>:
TRAPHANDLER_NOEC(vector174, 174)
f01049c2:	6a 00                	push   $0x0
f01049c4:	68 ae 00 00 00       	push   $0xae
f01049c9:	e9 b1 03 00 00       	jmp    f0104d7f <_alltraps>

f01049ce <vector175>:
TRAPHANDLER_NOEC(vector175, 175)
f01049ce:	6a 00                	push   $0x0
f01049d0:	68 af 00 00 00       	push   $0xaf
f01049d5:	e9 a5 03 00 00       	jmp    f0104d7f <_alltraps>

f01049da <vector176>:
TRAPHANDLER_NOEC(vector176, 176)
f01049da:	6a 00                	push   $0x0
f01049dc:	68 b0 00 00 00       	push   $0xb0
f01049e1:	e9 99 03 00 00       	jmp    f0104d7f <_alltraps>

f01049e6 <vector177>:
TRAPHANDLER_NOEC(vector177, 177)
f01049e6:	6a 00                	push   $0x0
f01049e8:	68 b1 00 00 00       	push   $0xb1
f01049ed:	e9 8d 03 00 00       	jmp    f0104d7f <_alltraps>

f01049f2 <vector178>:
TRAPHANDLER_NOEC(vector178, 178)
f01049f2:	6a 00                	push   $0x0
f01049f4:	68 b2 00 00 00       	push   $0xb2
f01049f9:	e9 81 03 00 00       	jmp    f0104d7f <_alltraps>

f01049fe <vector179>:
TRAPHANDLER_NOEC(vector179, 179)
f01049fe:	6a 00                	push   $0x0
f0104a00:	68 b3 00 00 00       	push   $0xb3
f0104a05:	e9 75 03 00 00       	jmp    f0104d7f <_alltraps>

f0104a0a <vector180>:
TRAPHANDLER_NOEC(vector180, 180)
f0104a0a:	6a 00                	push   $0x0
f0104a0c:	68 b4 00 00 00       	push   $0xb4
f0104a11:	e9 69 03 00 00       	jmp    f0104d7f <_alltraps>

f0104a16 <vector181>:
TRAPHANDLER_NOEC(vector181, 181)
f0104a16:	6a 00                	push   $0x0
f0104a18:	68 b5 00 00 00       	push   $0xb5
f0104a1d:	e9 5d 03 00 00       	jmp    f0104d7f <_alltraps>

f0104a22 <vector182>:
TRAPHANDLER_NOEC(vector182, 182)
f0104a22:	6a 00                	push   $0x0
f0104a24:	68 b6 00 00 00       	push   $0xb6
f0104a29:	e9 51 03 00 00       	jmp    f0104d7f <_alltraps>

f0104a2e <vector183>:
TRAPHANDLER_NOEC(vector183, 183)
f0104a2e:	6a 00                	push   $0x0
f0104a30:	68 b7 00 00 00       	push   $0xb7
f0104a35:	e9 45 03 00 00       	jmp    f0104d7f <_alltraps>

f0104a3a <vector184>:
TRAPHANDLER_NOEC(vector184, 184)
f0104a3a:	6a 00                	push   $0x0
f0104a3c:	68 b8 00 00 00       	push   $0xb8
f0104a41:	e9 39 03 00 00       	jmp    f0104d7f <_alltraps>

f0104a46 <vector185>:
TRAPHANDLER_NOEC(vector185, 185)
f0104a46:	6a 00                	push   $0x0
f0104a48:	68 b9 00 00 00       	push   $0xb9
f0104a4d:	e9 2d 03 00 00       	jmp    f0104d7f <_alltraps>

f0104a52 <vector186>:
TRAPHANDLER_NOEC(vector186, 186)
f0104a52:	6a 00                	push   $0x0
f0104a54:	68 ba 00 00 00       	push   $0xba
f0104a59:	e9 21 03 00 00       	jmp    f0104d7f <_alltraps>

f0104a5e <vector187>:
TRAPHANDLER_NOEC(vector187, 187)
f0104a5e:	6a 00                	push   $0x0
f0104a60:	68 bb 00 00 00       	push   $0xbb
f0104a65:	e9 15 03 00 00       	jmp    f0104d7f <_alltraps>

f0104a6a <vector188>:
TRAPHANDLER_NOEC(vector188, 188)
f0104a6a:	6a 00                	push   $0x0
f0104a6c:	68 bc 00 00 00       	push   $0xbc
f0104a71:	e9 09 03 00 00       	jmp    f0104d7f <_alltraps>

f0104a76 <vector189>:
TRAPHANDLER_NOEC(vector189, 189)
f0104a76:	6a 00                	push   $0x0
f0104a78:	68 bd 00 00 00       	push   $0xbd
f0104a7d:	e9 fd 02 00 00       	jmp    f0104d7f <_alltraps>

f0104a82 <vector190>:
TRAPHANDLER_NOEC(vector190, 190)
f0104a82:	6a 00                	push   $0x0
f0104a84:	68 be 00 00 00       	push   $0xbe
f0104a89:	e9 f1 02 00 00       	jmp    f0104d7f <_alltraps>

f0104a8e <vector191>:
TRAPHANDLER_NOEC(vector191, 191)
f0104a8e:	6a 00                	push   $0x0
f0104a90:	68 bf 00 00 00       	push   $0xbf
f0104a95:	e9 e5 02 00 00       	jmp    f0104d7f <_alltraps>

f0104a9a <vector192>:
TRAPHANDLER_NOEC(vector192, 192)
f0104a9a:	6a 00                	push   $0x0
f0104a9c:	68 c0 00 00 00       	push   $0xc0
f0104aa1:	e9 d9 02 00 00       	jmp    f0104d7f <_alltraps>

f0104aa6 <vector193>:
TRAPHANDLER_NOEC(vector193, 193)
f0104aa6:	6a 00                	push   $0x0
f0104aa8:	68 c1 00 00 00       	push   $0xc1
f0104aad:	e9 cd 02 00 00       	jmp    f0104d7f <_alltraps>

f0104ab2 <vector194>:
TRAPHANDLER_NOEC(vector194, 194)
f0104ab2:	6a 00                	push   $0x0
f0104ab4:	68 c2 00 00 00       	push   $0xc2
f0104ab9:	e9 c1 02 00 00       	jmp    f0104d7f <_alltraps>

f0104abe <vector195>:
TRAPHANDLER_NOEC(vector195, 195)
f0104abe:	6a 00                	push   $0x0
f0104ac0:	68 c3 00 00 00       	push   $0xc3
f0104ac5:	e9 b5 02 00 00       	jmp    f0104d7f <_alltraps>

f0104aca <vector196>:
TRAPHANDLER_NOEC(vector196, 196)
f0104aca:	6a 00                	push   $0x0
f0104acc:	68 c4 00 00 00       	push   $0xc4
f0104ad1:	e9 a9 02 00 00       	jmp    f0104d7f <_alltraps>

f0104ad6 <vector197>:
TRAPHANDLER_NOEC(vector197, 197)
f0104ad6:	6a 00                	push   $0x0
f0104ad8:	68 c5 00 00 00       	push   $0xc5
f0104add:	e9 9d 02 00 00       	jmp    f0104d7f <_alltraps>

f0104ae2 <vector198>:
TRAPHANDLER_NOEC(vector198, 198)
f0104ae2:	6a 00                	push   $0x0
f0104ae4:	68 c6 00 00 00       	push   $0xc6
f0104ae9:	e9 91 02 00 00       	jmp    f0104d7f <_alltraps>

f0104aee <vector199>:
TRAPHANDLER_NOEC(vector199, 199)
f0104aee:	6a 00                	push   $0x0
f0104af0:	68 c7 00 00 00       	push   $0xc7
f0104af5:	e9 85 02 00 00       	jmp    f0104d7f <_alltraps>

f0104afa <vector200>:
TRAPHANDLER_NOEC(vector200, 200)
f0104afa:	6a 00                	push   $0x0
f0104afc:	68 c8 00 00 00       	push   $0xc8
f0104b01:	e9 79 02 00 00       	jmp    f0104d7f <_alltraps>

f0104b06 <vector201>:
TRAPHANDLER_NOEC(vector201, 201)
f0104b06:	6a 00                	push   $0x0
f0104b08:	68 c9 00 00 00       	push   $0xc9
f0104b0d:	e9 6d 02 00 00       	jmp    f0104d7f <_alltraps>

f0104b12 <vector202>:
TRAPHANDLER_NOEC(vector202, 202)
f0104b12:	6a 00                	push   $0x0
f0104b14:	68 ca 00 00 00       	push   $0xca
f0104b19:	e9 61 02 00 00       	jmp    f0104d7f <_alltraps>

f0104b1e <vector203>:
TRAPHANDLER_NOEC(vector203, 203)
f0104b1e:	6a 00                	push   $0x0
f0104b20:	68 cb 00 00 00       	push   $0xcb
f0104b25:	e9 55 02 00 00       	jmp    f0104d7f <_alltraps>

f0104b2a <vector204>:
TRAPHANDLER_NOEC(vector204, 204)
f0104b2a:	6a 00                	push   $0x0
f0104b2c:	68 cc 00 00 00       	push   $0xcc
f0104b31:	e9 49 02 00 00       	jmp    f0104d7f <_alltraps>

f0104b36 <vector205>:
TRAPHANDLER_NOEC(vector205, 205)
f0104b36:	6a 00                	push   $0x0
f0104b38:	68 cd 00 00 00       	push   $0xcd
f0104b3d:	e9 3d 02 00 00       	jmp    f0104d7f <_alltraps>

f0104b42 <vector206>:
TRAPHANDLER_NOEC(vector206, 206)
f0104b42:	6a 00                	push   $0x0
f0104b44:	68 ce 00 00 00       	push   $0xce
f0104b49:	e9 31 02 00 00       	jmp    f0104d7f <_alltraps>

f0104b4e <vector207>:
TRAPHANDLER_NOEC(vector207, 207)
f0104b4e:	6a 00                	push   $0x0
f0104b50:	68 cf 00 00 00       	push   $0xcf
f0104b55:	e9 25 02 00 00       	jmp    f0104d7f <_alltraps>

f0104b5a <vector208>:
TRAPHANDLER_NOEC(vector208, 208)
f0104b5a:	6a 00                	push   $0x0
f0104b5c:	68 d0 00 00 00       	push   $0xd0
f0104b61:	e9 19 02 00 00       	jmp    f0104d7f <_alltraps>

f0104b66 <vector209>:
TRAPHANDLER_NOEC(vector209, 209)
f0104b66:	6a 00                	push   $0x0
f0104b68:	68 d1 00 00 00       	push   $0xd1
f0104b6d:	e9 0d 02 00 00       	jmp    f0104d7f <_alltraps>

f0104b72 <vector210>:
TRAPHANDLER_NOEC(vector210, 210)
f0104b72:	6a 00                	push   $0x0
f0104b74:	68 d2 00 00 00       	push   $0xd2
f0104b79:	e9 01 02 00 00       	jmp    f0104d7f <_alltraps>

f0104b7e <vector211>:
TRAPHANDLER_NOEC(vector211, 211)
f0104b7e:	6a 00                	push   $0x0
f0104b80:	68 d3 00 00 00       	push   $0xd3
f0104b85:	e9 f5 01 00 00       	jmp    f0104d7f <_alltraps>

f0104b8a <vector212>:
TRAPHANDLER_NOEC(vector212, 212)
f0104b8a:	6a 00                	push   $0x0
f0104b8c:	68 d4 00 00 00       	push   $0xd4
f0104b91:	e9 e9 01 00 00       	jmp    f0104d7f <_alltraps>

f0104b96 <vector213>:
TRAPHANDLER_NOEC(vector213, 213)
f0104b96:	6a 00                	push   $0x0
f0104b98:	68 d5 00 00 00       	push   $0xd5
f0104b9d:	e9 dd 01 00 00       	jmp    f0104d7f <_alltraps>

f0104ba2 <vector214>:
TRAPHANDLER_NOEC(vector214, 214)
f0104ba2:	6a 00                	push   $0x0
f0104ba4:	68 d6 00 00 00       	push   $0xd6
f0104ba9:	e9 d1 01 00 00       	jmp    f0104d7f <_alltraps>

f0104bae <vector215>:
TRAPHANDLER_NOEC(vector215, 215)
f0104bae:	6a 00                	push   $0x0
f0104bb0:	68 d7 00 00 00       	push   $0xd7
f0104bb5:	e9 c5 01 00 00       	jmp    f0104d7f <_alltraps>

f0104bba <vector216>:
TRAPHANDLER_NOEC(vector216, 216)
f0104bba:	6a 00                	push   $0x0
f0104bbc:	68 d8 00 00 00       	push   $0xd8
f0104bc1:	e9 b9 01 00 00       	jmp    f0104d7f <_alltraps>

f0104bc6 <vector217>:
TRAPHANDLER_NOEC(vector217, 217)
f0104bc6:	6a 00                	push   $0x0
f0104bc8:	68 d9 00 00 00       	push   $0xd9
f0104bcd:	e9 ad 01 00 00       	jmp    f0104d7f <_alltraps>

f0104bd2 <vector218>:
TRAPHANDLER_NOEC(vector218, 218)
f0104bd2:	6a 00                	push   $0x0
f0104bd4:	68 da 00 00 00       	push   $0xda
f0104bd9:	e9 a1 01 00 00       	jmp    f0104d7f <_alltraps>

f0104bde <vector219>:
TRAPHANDLER_NOEC(vector219, 219)
f0104bde:	6a 00                	push   $0x0
f0104be0:	68 db 00 00 00       	push   $0xdb
f0104be5:	e9 95 01 00 00       	jmp    f0104d7f <_alltraps>

f0104bea <vector220>:
TRAPHANDLER_NOEC(vector220, 220)
f0104bea:	6a 00                	push   $0x0
f0104bec:	68 dc 00 00 00       	push   $0xdc
f0104bf1:	e9 89 01 00 00       	jmp    f0104d7f <_alltraps>

f0104bf6 <vector221>:
TRAPHANDLER_NOEC(vector221, 221)
f0104bf6:	6a 00                	push   $0x0
f0104bf8:	68 dd 00 00 00       	push   $0xdd
f0104bfd:	e9 7d 01 00 00       	jmp    f0104d7f <_alltraps>

f0104c02 <vector222>:
TRAPHANDLER_NOEC(vector222, 222)
f0104c02:	6a 00                	push   $0x0
f0104c04:	68 de 00 00 00       	push   $0xde
f0104c09:	e9 71 01 00 00       	jmp    f0104d7f <_alltraps>

f0104c0e <vector223>:
TRAPHANDLER_NOEC(vector223, 223)
f0104c0e:	6a 00                	push   $0x0
f0104c10:	68 df 00 00 00       	push   $0xdf
f0104c15:	e9 65 01 00 00       	jmp    f0104d7f <_alltraps>

f0104c1a <vector224>:
TRAPHANDLER_NOEC(vector224, 224)
f0104c1a:	6a 00                	push   $0x0
f0104c1c:	68 e0 00 00 00       	push   $0xe0
f0104c21:	e9 59 01 00 00       	jmp    f0104d7f <_alltraps>

f0104c26 <vector225>:
TRAPHANDLER_NOEC(vector225, 225)
f0104c26:	6a 00                	push   $0x0
f0104c28:	68 e1 00 00 00       	push   $0xe1
f0104c2d:	e9 4d 01 00 00       	jmp    f0104d7f <_alltraps>

f0104c32 <vector226>:
TRAPHANDLER_NOEC(vector226, 226)
f0104c32:	6a 00                	push   $0x0
f0104c34:	68 e2 00 00 00       	push   $0xe2
f0104c39:	e9 41 01 00 00       	jmp    f0104d7f <_alltraps>

f0104c3e <vector227>:
TRAPHANDLER_NOEC(vector227, 227)
f0104c3e:	6a 00                	push   $0x0
f0104c40:	68 e3 00 00 00       	push   $0xe3
f0104c45:	e9 35 01 00 00       	jmp    f0104d7f <_alltraps>

f0104c4a <vector228>:
TRAPHANDLER_NOEC(vector228, 228)
f0104c4a:	6a 00                	push   $0x0
f0104c4c:	68 e4 00 00 00       	push   $0xe4
f0104c51:	e9 29 01 00 00       	jmp    f0104d7f <_alltraps>

f0104c56 <vector229>:
TRAPHANDLER_NOEC(vector229, 229)
f0104c56:	6a 00                	push   $0x0
f0104c58:	68 e5 00 00 00       	push   $0xe5
f0104c5d:	e9 1d 01 00 00       	jmp    f0104d7f <_alltraps>

f0104c62 <vector230>:
TRAPHANDLER_NOEC(vector230, 230)
f0104c62:	6a 00                	push   $0x0
f0104c64:	68 e6 00 00 00       	push   $0xe6
f0104c69:	e9 11 01 00 00       	jmp    f0104d7f <_alltraps>

f0104c6e <vector231>:
TRAPHANDLER_NOEC(vector231, 231)
f0104c6e:	6a 00                	push   $0x0
f0104c70:	68 e7 00 00 00       	push   $0xe7
f0104c75:	e9 05 01 00 00       	jmp    f0104d7f <_alltraps>

f0104c7a <vector232>:
TRAPHANDLER_NOEC(vector232, 232)
f0104c7a:	6a 00                	push   $0x0
f0104c7c:	68 e8 00 00 00       	push   $0xe8
f0104c81:	e9 f9 00 00 00       	jmp    f0104d7f <_alltraps>

f0104c86 <vector233>:
TRAPHANDLER_NOEC(vector233, 233)
f0104c86:	6a 00                	push   $0x0
f0104c88:	68 e9 00 00 00       	push   $0xe9
f0104c8d:	e9 ed 00 00 00       	jmp    f0104d7f <_alltraps>

f0104c92 <vector234>:
TRAPHANDLER_NOEC(vector234, 234)
f0104c92:	6a 00                	push   $0x0
f0104c94:	68 ea 00 00 00       	push   $0xea
f0104c99:	e9 e1 00 00 00       	jmp    f0104d7f <_alltraps>

f0104c9e <vector235>:
TRAPHANDLER_NOEC(vector235, 235)
f0104c9e:	6a 00                	push   $0x0
f0104ca0:	68 eb 00 00 00       	push   $0xeb
f0104ca5:	e9 d5 00 00 00       	jmp    f0104d7f <_alltraps>

f0104caa <vector236>:
TRAPHANDLER_NOEC(vector236, 236)
f0104caa:	6a 00                	push   $0x0
f0104cac:	68 ec 00 00 00       	push   $0xec
f0104cb1:	e9 c9 00 00 00       	jmp    f0104d7f <_alltraps>

f0104cb6 <vector237>:
TRAPHANDLER_NOEC(vector237, 237)
f0104cb6:	6a 00                	push   $0x0
f0104cb8:	68 ed 00 00 00       	push   $0xed
f0104cbd:	e9 bd 00 00 00       	jmp    f0104d7f <_alltraps>

f0104cc2 <vector238>:
TRAPHANDLER_NOEC(vector238, 238)
f0104cc2:	6a 00                	push   $0x0
f0104cc4:	68 ee 00 00 00       	push   $0xee
f0104cc9:	e9 b1 00 00 00       	jmp    f0104d7f <_alltraps>

f0104cce <vector239>:
TRAPHANDLER_NOEC(vector239, 239)
f0104cce:	6a 00                	push   $0x0
f0104cd0:	68 ef 00 00 00       	push   $0xef
f0104cd5:	e9 a5 00 00 00       	jmp    f0104d7f <_alltraps>

f0104cda <vector240>:
TRAPHANDLER_NOEC(vector240, 240)
f0104cda:	6a 00                	push   $0x0
f0104cdc:	68 f0 00 00 00       	push   $0xf0
f0104ce1:	e9 99 00 00 00       	jmp    f0104d7f <_alltraps>

f0104ce6 <vector241>:
TRAPHANDLER_NOEC(vector241, 241)
f0104ce6:	6a 00                	push   $0x0
f0104ce8:	68 f1 00 00 00       	push   $0xf1
f0104ced:	e9 8d 00 00 00       	jmp    f0104d7f <_alltraps>

f0104cf2 <vector242>:
TRAPHANDLER_NOEC(vector242, 242)
f0104cf2:	6a 00                	push   $0x0
f0104cf4:	68 f2 00 00 00       	push   $0xf2
f0104cf9:	e9 81 00 00 00       	jmp    f0104d7f <_alltraps>

f0104cfe <vector243>:
TRAPHANDLER_NOEC(vector243, 243)
f0104cfe:	6a 00                	push   $0x0
f0104d00:	68 f3 00 00 00       	push   $0xf3
f0104d05:	eb 78                	jmp    f0104d7f <_alltraps>
f0104d07:	90                   	nop

f0104d08 <vector244>:
TRAPHANDLER_NOEC(vector244, 244)
f0104d08:	6a 00                	push   $0x0
f0104d0a:	68 f4 00 00 00       	push   $0xf4
f0104d0f:	eb 6e                	jmp    f0104d7f <_alltraps>
f0104d11:	90                   	nop

f0104d12 <vector245>:
TRAPHANDLER_NOEC(vector245, 245)
f0104d12:	6a 00                	push   $0x0
f0104d14:	68 f5 00 00 00       	push   $0xf5
f0104d19:	eb 64                	jmp    f0104d7f <_alltraps>
f0104d1b:	90                   	nop

f0104d1c <vector246>:
TRAPHANDLER_NOEC(vector246, 246)
f0104d1c:	6a 00                	push   $0x0
f0104d1e:	68 f6 00 00 00       	push   $0xf6
f0104d23:	eb 5a                	jmp    f0104d7f <_alltraps>
f0104d25:	90                   	nop

f0104d26 <vector247>:
TRAPHANDLER_NOEC(vector247, 247)
f0104d26:	6a 00                	push   $0x0
f0104d28:	68 f7 00 00 00       	push   $0xf7
f0104d2d:	eb 50                	jmp    f0104d7f <_alltraps>
f0104d2f:	90                   	nop

f0104d30 <vector248>:
TRAPHANDLER_NOEC(vector248, 248)
f0104d30:	6a 00                	push   $0x0
f0104d32:	68 f8 00 00 00       	push   $0xf8
f0104d37:	eb 46                	jmp    f0104d7f <_alltraps>
f0104d39:	90                   	nop

f0104d3a <vector249>:
TRAPHANDLER_NOEC(vector249, 249)
f0104d3a:	6a 00                	push   $0x0
f0104d3c:	68 f9 00 00 00       	push   $0xf9
f0104d41:	eb 3c                	jmp    f0104d7f <_alltraps>
f0104d43:	90                   	nop

f0104d44 <vector250>:
TRAPHANDLER_NOEC(vector250, 250)
f0104d44:	6a 00                	push   $0x0
f0104d46:	68 fa 00 00 00       	push   $0xfa
f0104d4b:	eb 32                	jmp    f0104d7f <_alltraps>
f0104d4d:	90                   	nop

f0104d4e <vector251>:
TRAPHANDLER_NOEC(vector251, 251)
f0104d4e:	6a 00                	push   $0x0
f0104d50:	68 fb 00 00 00       	push   $0xfb
f0104d55:	eb 28                	jmp    f0104d7f <_alltraps>
f0104d57:	90                   	nop

f0104d58 <vector252>:
TRAPHANDLER_NOEC(vector252, 252)
f0104d58:	6a 00                	push   $0x0
f0104d5a:	68 fc 00 00 00       	push   $0xfc
f0104d5f:	eb 1e                	jmp    f0104d7f <_alltraps>
f0104d61:	90                   	nop

f0104d62 <vector253>:
TRAPHANDLER_NOEC(vector253, 253)
f0104d62:	6a 00                	push   $0x0
f0104d64:	68 fd 00 00 00       	push   $0xfd
f0104d69:	eb 14                	jmp    f0104d7f <_alltraps>
f0104d6b:	90                   	nop

f0104d6c <vector254>:
TRAPHANDLER_NOEC(vector254, 254)
f0104d6c:	6a 00                	push   $0x0
f0104d6e:	68 fe 00 00 00       	push   $0xfe
f0104d73:	eb 0a                	jmp    f0104d7f <_alltraps>
f0104d75:	90                   	nop

f0104d76 <vector255>:
TRAPHANDLER_NOEC(vector255, 255)
f0104d76:	6a 00                	push   $0x0
f0104d78:	68 ff 00 00 00       	push   $0xff
f0104d7d:	eb 00                	jmp    f0104d7f <_alltraps>

f0104d7f <_alltraps>:

.text
.globl _alltraps
_alltraps:
	# Build trap frame.
	pushl %ds
f0104d7f:	1e                   	push   %ds
	pushl %es
f0104d80:	06                   	push   %es
	pushal 
f0104d81:	60                   	pusha  
	# Set up data segments.
	movw $GD_KD, %ax
f0104d82:	66 b8 10 00          	mov    $0x10,%ax
	movw %ax, %ds
f0104d86:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0104d88:	8e c0                	mov    %eax,%es

	# Call trap(tf), where tf=%esp
	pushl %esp
f0104d8a:	54                   	push   %esp
	call trap
f0104d8b:	e8 dc f2 ff ff       	call   f010406c <trap>

f0104d90 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104d90:	55                   	push   %ebp
f0104d91:	89 e5                	mov    %esp,%ebp
f0104d93:	83 ec 08             	sub    $0x8,%esp
f0104d96:	a1 48 12 23 f0       	mov    0xf0231248,%eax
f0104d9b:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104d9e:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104da3:	8b 02                	mov    (%edx),%eax
f0104da5:	83 e8 01             	sub    $0x1,%eax
f0104da8:	83 f8 02             	cmp    $0x2,%eax
f0104dab:	76 10                	jbe    f0104dbd <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104dad:	83 c1 01             	add    $0x1,%ecx
f0104db0:	83 c2 7c             	add    $0x7c,%edx
f0104db3:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104db9:	75 e8                	jne    f0104da3 <sched_halt+0x13>
f0104dbb:	eb 08                	jmp    f0104dc5 <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104dbd:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104dc3:	75 1f                	jne    f0104de4 <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f0104dc5:	83 ec 0c             	sub    $0xc,%esp
f0104dc8:	68 b0 85 10 f0       	push   $0xf01085b0
f0104dcd:	e8 8c ed ff ff       	call   f0103b5e <cprintf>
f0104dd2:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0104dd5:	83 ec 0c             	sub    $0xc,%esp
f0104dd8:	6a 00                	push   $0x0
f0104dda:	e8 a3 bf ff ff       	call   f0100d82 <monitor>
f0104ddf:	83 c4 10             	add    $0x10,%esp
f0104de2:	eb f1                	jmp    f0104dd5 <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104de4:	e8 ed 17 00 00       	call   f01065d6 <cpunum>
f0104de9:	6b c0 74             	imul   $0x74,%eax,%eax
f0104dec:	c7 80 28 20 23 f0 00 	movl   $0x0,-0xfdcdfd8(%eax)
f0104df3:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104df6:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104dfb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104e00:	77 12                	ja     f0104e14 <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104e02:	50                   	push   %eax
f0104e03:	68 a8 6c 10 f0       	push   $0xf0106ca8
f0104e08:	6a 47                	push   $0x47
f0104e0a:	68 d9 85 10 f0       	push   $0xf01085d9
f0104e0f:	e8 2c b2 ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104e14:	05 00 00 00 10       	add    $0x10000000,%eax
f0104e19:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104e1c:	e8 b5 17 00 00       	call   f01065d6 <cpunum>
f0104e21:	6b d0 74             	imul   $0x74,%eax,%edx
f0104e24:	81 c2 20 20 23 f0    	add    $0xf0232020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104e2a:	b8 02 00 00 00       	mov    $0x2,%eax
f0104e2f:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104e33:	83 ec 0c             	sub    $0xc,%esp
f0104e36:	68 c0 27 12 f0       	push   $0xf01227c0
f0104e3b:	e8 a1 1a 00 00       	call   f01068e1 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104e40:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104e42:	e8 8f 17 00 00       	call   f01065d6 <cpunum>
f0104e47:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104e4a:	8b 80 30 20 23 f0    	mov    -0xfdcdfd0(%eax),%eax
f0104e50:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104e55:	89 c4                	mov    %eax,%esp
f0104e57:	6a 00                	push   $0x0
f0104e59:	6a 00                	push   $0x0
f0104e5b:	fb                   	sti    
f0104e5c:	f4                   	hlt    
f0104e5d:	eb fd                	jmp    f0104e5c <sched_halt+0xcc>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104e5f:	83 c4 10             	add    $0x10,%esp
f0104e62:	c9                   	leave  
f0104e63:	c3                   	ret    

f0104e64 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104e64:	55                   	push   %ebp
f0104e65:	89 e5                	mov    %esp,%ebp
f0104e67:	53                   	push   %ebx
f0104e68:	83 ec 04             	sub    $0x4,%esp
	// Never choose an environment that's currently running on
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.
	int i, nexti = 0;
	if (curenv != NULL)
f0104e6b:	e8 66 17 00 00       	call   f01065d6 <cpunum>
f0104e70:	6b d0 74             	imul   $0x74,%eax,%edx
	//
	// Never choose an environment that's currently running on
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.
	int i, nexti = 0;
f0104e73:	b8 00 00 00 00       	mov    $0x0,%eax
	if (curenv != NULL)
f0104e78:	83 ba 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%edx)
f0104e7f:	74 19                	je     f0104e9a <sched_yield+0x36>
		nexti = (ENVX(curenv->env_id) + 1) % NENV;
f0104e81:	e8 50 17 00 00       	call   f01065d6 <cpunum>
f0104e86:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e89:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0104e8f:	8b 40 48             	mov    0x48(%eax),%eax
f0104e92:	8d 40 01             	lea    0x1(%eax),%eax
f0104e95:	25 ff 03 00 00       	and    $0x3ff,%eax
	
	for (i = 0; i < NENV; i++) {
		if (envs[nexti].env_status == ENV_RUNNABLE) 
f0104e9a:	8b 0d 48 12 23 f0    	mov    0xf0231248,%ecx
f0104ea0:	ba 00 04 00 00       	mov    $0x400,%edx
f0104ea5:	6b d8 7c             	imul   $0x7c,%eax,%ebx
f0104ea8:	01 cb                	add    %ecx,%ebx
f0104eaa:	83 7b 54 02          	cmpl   $0x2,0x54(%ebx)
f0104eae:	75 09                	jne    f0104eb9 <sched_yield+0x55>
			env_run(&envs[nexti]);
f0104eb0:	83 ec 0c             	sub    $0xc,%esp
f0104eb3:	53                   	push   %ebx
f0104eb4:	e8 54 ea ff ff       	call   f010390d <env_run>
		nexti = (nexti + 1) % NENV;
f0104eb9:	83 c0 01             	add    $0x1,%eax
f0104ebc:	89 c3                	mov    %eax,%ebx
f0104ebe:	c1 fb 1f             	sar    $0x1f,%ebx
f0104ec1:	c1 eb 16             	shr    $0x16,%ebx
f0104ec4:	01 d8                	add    %ebx,%eax
f0104ec6:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104ecb:	29 d8                	sub    %ebx,%eax
	// below to halt the cpu.
	int i, nexti = 0;
	if (curenv != NULL)
		nexti = (ENVX(curenv->env_id) + 1) % NENV;
	
	for (i = 0; i < NENV; i++) {
f0104ecd:	83 ea 01             	sub    $0x1,%edx
f0104ed0:	75 d3                	jne    f0104ea5 <sched_yield+0x41>
		if (envs[nexti].env_status == ENV_RUNNABLE) 
			env_run(&envs[nexti]);
		nexti = (nexti + 1) % NENV;
	}

	if (curenv != NULL && curenv->env_status == ENV_RUNNING)
f0104ed2:	e8 ff 16 00 00       	call   f01065d6 <cpunum>
f0104ed7:	6b c0 74             	imul   $0x74,%eax,%eax
f0104eda:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f0104ee1:	74 2a                	je     f0104f0d <sched_yield+0xa9>
f0104ee3:	e8 ee 16 00 00       	call   f01065d6 <cpunum>
f0104ee8:	6b c0 74             	imul   $0x74,%eax,%eax
f0104eeb:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0104ef1:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104ef5:	75 16                	jne    f0104f0d <sched_yield+0xa9>
		env_run(curenv);
f0104ef7:	e8 da 16 00 00       	call   f01065d6 <cpunum>
f0104efc:	83 ec 0c             	sub    $0xc,%esp
f0104eff:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f02:	ff b0 28 20 23 f0    	pushl  -0xfdcdfd8(%eax)
f0104f08:	e8 00 ea ff ff       	call   f010390d <env_run>
	
	// sched_halt never returns
	sched_halt();
f0104f0d:	e8 7e fe ff ff       	call   f0104d90 <sched_halt>
}
f0104f12:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104f15:	c9                   	leave  
f0104f16:	c3                   	ret    

f0104f17 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104f17:	55                   	push   %ebp
f0104f18:	89 e5                	mov    %esp,%ebp
f0104f1a:	57                   	push   %edi
f0104f1b:	56                   	push   %esi
f0104f1c:	53                   	push   %ebx
f0104f1d:	83 ec 1c             	sub    $0x1c,%esp
f0104f20:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	
	switch (syscallno) {
f0104f23:	83 f8 0c             	cmp    $0xc,%eax
f0104f26:	0f 87 17 05 00 00    	ja     f0105443 <syscall+0x52c>
f0104f2c:	ff 24 85 20 86 10 f0 	jmp    *-0xfef79e0(,%eax,4)
static void
sys_cputs(const char *s, size_t len)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.
	user_mem_assert(curenv, s, len, PTE_U | PTE_P);	
f0104f33:	e8 9e 16 00 00       	call   f01065d6 <cpunum>
f0104f38:	6a 05                	push   $0x5
f0104f3a:	ff 75 10             	pushl  0x10(%ebp)
f0104f3d:	ff 75 0c             	pushl  0xc(%ebp)
f0104f40:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f43:	ff b0 28 20 23 f0    	pushl  -0xfdcdfd8(%eax)
f0104f49:	e8 66 e2 ff ff       	call   f01031b4 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104f4e:	83 c4 0c             	add    $0xc,%esp
f0104f51:	ff 75 0c             	pushl  0xc(%ebp)
f0104f54:	ff 75 10             	pushl  0x10(%ebp)
f0104f57:	68 e6 85 10 f0       	push   $0xf01085e6
f0104f5c:	e8 fd eb ff ff       	call   f0103b5e <cprintf>
f0104f61:	83 c4 10             	add    $0x10,%esp
	// Return any appropriate return value.
	
	switch (syscallno) {
	case SYS_cputs:
		sys_cputs((char *) a1, a2);
		return 0;
f0104f64:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f69:	e9 e1 04 00 00       	jmp    f010544f <syscall+0x538>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104f6e:	e8 74 b6 ff ff       	call   f01005e7 <cons_getc>
	switch (syscallno) {
	case SYS_cputs:
		sys_cputs((char *) a1, a2);
		return 0;
	case SYS_cgetc:
		return sys_cgetc();
f0104f73:	e9 d7 04 00 00       	jmp    f010544f <syscall+0x538>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104f78:	83 ec 04             	sub    $0x4,%esp
f0104f7b:	6a 01                	push   $0x1
f0104f7d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104f80:	50                   	push   %eax
f0104f81:	ff 75 0c             	pushl  0xc(%ebp)
f0104f84:	e8 37 e3 ff ff       	call   f01032c0 <envid2env>
f0104f89:	83 c4 10             	add    $0x10,%esp
f0104f8c:	85 c0                	test   %eax,%eax
f0104f8e:	0f 88 bb 04 00 00    	js     f010544f <syscall+0x538>
		return r;
	if (e == curenv)
f0104f94:	e8 3d 16 00 00       	call   f01065d6 <cpunum>
f0104f99:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104f9c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f9f:	39 90 28 20 23 f0    	cmp    %edx,-0xfdcdfd8(%eax)
f0104fa5:	75 23                	jne    f0104fca <syscall+0xb3>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104fa7:	e8 2a 16 00 00       	call   f01065d6 <cpunum>
f0104fac:	83 ec 08             	sub    $0x8,%esp
f0104faf:	6b c0 74             	imul   $0x74,%eax,%eax
f0104fb2:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0104fb8:	ff 70 48             	pushl  0x48(%eax)
f0104fbb:	68 eb 85 10 f0       	push   $0xf01085eb
f0104fc0:	e8 99 eb ff ff       	call   f0103b5e <cprintf>
f0104fc5:	83 c4 10             	add    $0x10,%esp
f0104fc8:	eb 25                	jmp    f0104fef <syscall+0xd8>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104fca:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104fcd:	e8 04 16 00 00       	call   f01065d6 <cpunum>
f0104fd2:	83 ec 04             	sub    $0x4,%esp
f0104fd5:	53                   	push   %ebx
f0104fd6:	6b c0 74             	imul   $0x74,%eax,%eax
f0104fd9:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0104fdf:	ff 70 48             	pushl  0x48(%eax)
f0104fe2:	68 06 86 10 f0       	push   $0xf0108606
f0104fe7:	e8 72 eb ff ff       	call   f0103b5e <cprintf>
f0104fec:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104fef:	83 ec 0c             	sub    $0xc,%esp
f0104ff2:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104ff5:	e8 74 e8 ff ff       	call   f010386e <env_destroy>
f0104ffa:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104ffd:	b8 00 00 00 00       	mov    $0x0,%eax
f0105002:	e9 48 04 00 00       	jmp    f010544f <syscall+0x538>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0105007:	e8 ca 15 00 00       	call   f01065d6 <cpunum>
f010500c:	6b c0 74             	imul   $0x74,%eax,%eax
f010500f:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0105015:	8b 40 48             	mov    0x48(%eax),%eax
	case SYS_cgetc:
		return sys_cgetc();
	case SYS_env_destroy:
		return sys_env_destroy(a1);
	case SYS_getenvid:
		return sys_getenvid();
f0105018:	e9 32 04 00 00       	jmp    f010544f <syscall+0x538>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f010501d:	e8 42 fe ff ff       	call   f0104e64 <sched_yield>

	struct Env *e;
	struct PageInfo *pp;
	int ret;

	if ((ret = envid2env(envid, &e, 1)) < 0)
f0105022:	83 ec 04             	sub    $0x4,%esp
f0105025:	6a 01                	push   $0x1
f0105027:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010502a:	50                   	push   %eax
f010502b:	ff 75 0c             	pushl  0xc(%ebp)
f010502e:	e8 8d e2 ff ff       	call   f01032c0 <envid2env>
f0105033:	83 c4 10             	add    $0x10,%esp
f0105036:	85 c0                	test   %eax,%eax
f0105038:	0f 88 11 04 00 00    	js     f010544f <syscall+0x538>
		return ret;

	if (va >= (void *)UTOP || PGOFF(va) != 0)
f010503e:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0105045:	77 60                	ja     f01050a7 <syscall+0x190>
f0105047:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010504e:	75 61                	jne    f01050b1 <syscall+0x19a>
		return -E_INVAL;

	if ((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P) || (perm & ~PTE_SYSCALL) != 0)
f0105050:	8b 45 14             	mov    0x14(%ebp),%eax
f0105053:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f0105058:	83 f8 05             	cmp    $0x5,%eax
f010505b:	75 5e                	jne    f01050bb <syscall+0x1a4>
		return -E_INVAL;

	if ((pp = page_alloc(ALLOC_ZERO)) == NULL)
f010505d:	83 ec 0c             	sub    $0xc,%esp
f0105060:	6a 01                	push   $0x1
f0105062:	e8 d0 c2 ff ff       	call   f0101337 <page_alloc>
f0105067:	89 c3                	mov    %eax,%ebx
f0105069:	83 c4 10             	add    $0x10,%esp
f010506c:	85 c0                	test   %eax,%eax
f010506e:	74 55                	je     f01050c5 <syscall+0x1ae>
		return -E_NO_MEM;

	if ((ret = page_insert(e->env_pgdir, pp, va, perm)) < 0) {
f0105070:	ff 75 14             	pushl  0x14(%ebp)
f0105073:	ff 75 10             	pushl  0x10(%ebp)
f0105076:	50                   	push   %eax
f0105077:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010507a:	ff 70 60             	pushl  0x60(%eax)
f010507d:	e8 8b c5 ff ff       	call   f010160d <page_insert>
f0105082:	89 c6                	mov    %eax,%esi
f0105084:	83 c4 10             	add    $0x10,%esp
		page_free(pp);		
		return ret;
	}

	return 0;
f0105087:	b8 00 00 00 00       	mov    $0x0,%eax
		return -E_INVAL;

	if ((pp = page_alloc(ALLOC_ZERO)) == NULL)
		return -E_NO_MEM;

	if ((ret = page_insert(e->env_pgdir, pp, va, perm)) < 0) {
f010508c:	85 f6                	test   %esi,%esi
f010508e:	0f 89 bb 03 00 00    	jns    f010544f <syscall+0x538>
		page_free(pp);		
f0105094:	83 ec 0c             	sub    $0xc,%esp
f0105097:	53                   	push   %ebx
f0105098:	e8 0a c3 ff ff       	call   f01013a7 <page_free>
f010509d:	83 c4 10             	add    $0x10,%esp
		return ret;
f01050a0:	89 f0                	mov    %esi,%eax
f01050a2:	e9 a8 03 00 00       	jmp    f010544f <syscall+0x538>

	if ((ret = envid2env(envid, &e, 1)) < 0)
		return ret;

	if (va >= (void *)UTOP || PGOFF(va) != 0)
		return -E_INVAL;
f01050a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01050ac:	e9 9e 03 00 00       	jmp    f010544f <syscall+0x538>
f01050b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01050b6:	e9 94 03 00 00       	jmp    f010544f <syscall+0x538>

	if ((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P) || (perm & ~PTE_SYSCALL) != 0)
		return -E_INVAL;
f01050bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01050c0:	e9 8a 03 00 00       	jmp    f010544f <syscall+0x538>

	if ((pp = page_alloc(ALLOC_ZERO)) == NULL)
		return -E_NO_MEM;
f01050c5:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01050ca:	e9 80 03 00 00       	jmp    f010544f <syscall+0x538>
	struct Env *srcenv, *dstenv;
	struct PageInfo *pp;
	pte_t *pte;
	int ret;
	
	if ((ret = envid2env(srcenvid, &srcenv, 1)) < 0)
f01050cf:	83 ec 04             	sub    $0x4,%esp
f01050d2:	6a 01                	push   $0x1
f01050d4:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01050d7:	50                   	push   %eax
f01050d8:	ff 75 0c             	pushl  0xc(%ebp)
f01050db:	e8 e0 e1 ff ff       	call   f01032c0 <envid2env>
f01050e0:	83 c4 10             	add    $0x10,%esp
f01050e3:	85 c0                	test   %eax,%eax
f01050e5:	0f 88 64 03 00 00    	js     f010544f <syscall+0x538>
		return ret;
	if ((ret = envid2env(dstenvid, &dstenv, 1)) < 0)
f01050eb:	83 ec 04             	sub    $0x4,%esp
f01050ee:	6a 01                	push   $0x1
f01050f0:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01050f3:	50                   	push   %eax
f01050f4:	ff 75 14             	pushl  0x14(%ebp)
f01050f7:	e8 c4 e1 ff ff       	call   f01032c0 <envid2env>
f01050fc:	83 c4 10             	add    $0x10,%esp
f01050ff:	85 c0                	test   %eax,%eax
f0105101:	0f 88 48 03 00 00    	js     f010544f <syscall+0x538>
		return ret;

	if (srcva >= (void *) UTOP || PGOFF(srcva) != 0)
f0105107:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010510e:	77 75                	ja     f0105185 <syscall+0x26e>
		sys_yield();
		return 0;
	case SYS_page_alloc:
		return sys_page_alloc(a1, (void *) a2, a3);
	case SYS_page_map:
		return sys_page_map(a1, (void *) a2, a3, (void *) a4, a5);
f0105110:	8b 5d 18             	mov    0x18(%ebp),%ebx
	if ((ret = envid2env(dstenvid, &dstenv, 1)) < 0)
		return ret;

	if (srcva >= (void *) UTOP || PGOFF(srcva) != 0)
		return -E_INVAL;
	if (dstva >= (void *) UTOP || PGOFF(dstva) != 0)
f0105113:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010511a:	75 73                	jne    f010518f <syscall+0x278>
f010511c:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0105122:	77 6b                	ja     f010518f <syscall+0x278>
f0105124:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f010512a:	75 6d                	jne    f0105199 <syscall+0x282>
		return -E_INVAL;
	
	if ((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P) || (perm & ~PTE_SYSCALL) != 0)
f010512c:	8b 45 1c             	mov    0x1c(%ebp),%eax
f010512f:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f0105134:	83 f8 05             	cmp    $0x5,%eax
f0105137:	75 6a                	jne    f01051a3 <syscall+0x28c>
		return -E_INVAL;

	if ((pp = page_lookup(srcenv->env_pgdir, srcva, &pte)) == NULL)
f0105139:	83 ec 04             	sub    $0x4,%esp
f010513c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010513f:	50                   	push   %eax
f0105140:	ff 75 10             	pushl  0x10(%ebp)
f0105143:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105146:	ff 70 60             	pushl  0x60(%eax)
f0105149:	e8 d5 c3 ff ff       	call   f0101523 <page_lookup>
f010514e:	83 c4 10             	add    $0x10,%esp
f0105151:	85 c0                	test   %eax,%eax
f0105153:	74 58                	je     f01051ad <syscall+0x296>
		return -E_INVAL;

	if ((perm & PTE_W) && !(*pte & PTE_W))
f0105155:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0105159:	74 08                	je     f0105163 <syscall+0x24c>
f010515b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010515e:	f6 02 02             	testb  $0x2,(%edx)
f0105161:	74 54                	je     f01051b7 <syscall+0x2a0>
		return -E_INVAL;

	if ((ret = page_insert(dstenv->env_pgdir, pp, dstva, perm)) < 0)
f0105163:	ff 75 1c             	pushl  0x1c(%ebp)
f0105166:	53                   	push   %ebx
f0105167:	50                   	push   %eax
f0105168:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010516b:	ff 70 60             	pushl  0x60(%eax)
f010516e:	e8 9a c4 ff ff       	call   f010160d <page_insert>
f0105173:	83 c4 10             	add    $0x10,%esp
f0105176:	85 c0                	test   %eax,%eax
f0105178:	ba 00 00 00 00       	mov    $0x0,%edx
f010517d:	0f 4f c2             	cmovg  %edx,%eax
f0105180:	e9 ca 02 00 00       	jmp    f010544f <syscall+0x538>
		return ret;
	if ((ret = envid2env(dstenvid, &dstenv, 1)) < 0)
		return ret;

	if (srcva >= (void *) UTOP || PGOFF(srcva) != 0)
		return -E_INVAL;
f0105185:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010518a:	e9 c0 02 00 00       	jmp    f010544f <syscall+0x538>
	if (dstva >= (void *) UTOP || PGOFF(dstva) != 0)
		return -E_INVAL;
f010518f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105194:	e9 b6 02 00 00       	jmp    f010544f <syscall+0x538>
f0105199:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010519e:	e9 ac 02 00 00       	jmp    f010544f <syscall+0x538>
	
	if ((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P) || (perm & ~PTE_SYSCALL) != 0)
		return -E_INVAL;
f01051a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01051a8:	e9 a2 02 00 00       	jmp    f010544f <syscall+0x538>

	if ((pp = page_lookup(srcenv->env_pgdir, srcva, &pte)) == NULL)
		return -E_INVAL;
f01051ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01051b2:	e9 98 02 00 00       	jmp    f010544f <syscall+0x538>

	if ((perm & PTE_W) && !(*pte & PTE_W))
		return -E_INVAL;
f01051b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		sys_yield();
		return 0;
	case SYS_page_alloc:
		return sys_page_alloc(a1, (void *) a2, a3);
	case SYS_page_map:
		return sys_page_map(a1, (void *) a2, a3, (void *) a4, a5);
f01051bc:	e9 8e 02 00 00       	jmp    f010544f <syscall+0x538>
{
	// Hint: This function is a wrapper around page_remove().
	struct Env* e;
	int ret;

	if ((ret = envid2env(envid, &e, 1)) < 0)
f01051c1:	83 ec 04             	sub    $0x4,%esp
f01051c4:	6a 01                	push   $0x1
f01051c6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01051c9:	50                   	push   %eax
f01051ca:	ff 75 0c             	pushl  0xc(%ebp)
f01051cd:	e8 ee e0 ff ff       	call   f01032c0 <envid2env>
f01051d2:	83 c4 10             	add    $0x10,%esp
f01051d5:	85 c0                	test   %eax,%eax
f01051d7:	0f 88 72 02 00 00    	js     f010544f <syscall+0x538>
		return ret;

	if (va >= (void *) UTOP || PGOFF(va) != 0)
f01051dd:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01051e4:	77 27                	ja     f010520d <syscall+0x2f6>
f01051e6:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01051ed:	75 28                	jne    f0105217 <syscall+0x300>
		return -E_INVAL;
	
	page_remove(e->env_pgdir, va);
f01051ef:	83 ec 08             	sub    $0x8,%esp
f01051f2:	ff 75 10             	pushl  0x10(%ebp)
f01051f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01051f8:	ff 70 60             	pushl  0x60(%eax)
f01051fb:	e8 bd c3 ff ff       	call   f01015bd <page_remove>
f0105200:	83 c4 10             	add    $0x10,%esp

	return 0;
f0105203:	b8 00 00 00 00       	mov    $0x0,%eax
f0105208:	e9 42 02 00 00       	jmp    f010544f <syscall+0x538>

	if ((ret = envid2env(envid, &e, 1)) < 0)
		return ret;

	if (va >= (void *) UTOP || PGOFF(va) != 0)
		return -E_INVAL;
f010520d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105212:	e9 38 02 00 00       	jmp    f010544f <syscall+0x538>
f0105217:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	case SYS_page_alloc:
		return sys_page_alloc(a1, (void *) a2, a3);
	case SYS_page_map:
		return sys_page_map(a1, (void *) a2, a3, (void *) a4, a5);
	case SYS_page_unmap:
		return sys_page_unmap(a1, (void *) a2);
f010521c:	e9 2e 02 00 00       	jmp    f010544f <syscall+0x538>
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	struct Env *e;
	int ret = env_alloc(&e, curenv->env_id);
f0105221:	e8 b0 13 00 00       	call   f01065d6 <cpunum>
f0105226:	83 ec 08             	sub    $0x8,%esp
f0105229:	6b c0 74             	imul   $0x74,%eax,%eax
f010522c:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0105232:	ff 70 48             	pushl  0x48(%eax)
f0105235:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105238:	50                   	push   %eax
f0105239:	e8 94 e1 ff ff       	call   f01033d2 <env_alloc>
	if (ret < 0) 
f010523e:	83 c4 10             	add    $0x10,%esp
f0105241:	85 c0                	test   %eax,%eax
f0105243:	0f 88 06 02 00 00    	js     f010544f <syscall+0x538>
		return ret;

	e->env_status = ENV_NOT_RUNNABLE;
f0105249:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010524c:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
	e->env_tf = curenv->env_tf;
f0105253:	e8 7e 13 00 00       	call   f01065d6 <cpunum>
f0105258:	6b c0 74             	imul   $0x74,%eax,%eax
f010525b:	8b b0 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%esi
f0105261:	b9 11 00 00 00       	mov    $0x11,%ecx
f0105266:	89 df                	mov    %ebx,%edi
f0105268:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_tf.tf_regs.reg_eax = 0;
f010526a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010526d:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	return e->env_id;
f0105274:	8b 40 48             	mov    0x48(%eax),%eax
f0105277:	e9 d3 01 00 00       	jmp    f010544f <syscall+0x538>
	// envid's status.

	struct Env *e;
	int ret;

	if ((ret = envid2env(envid, &e, 1)) < 0)
f010527c:	83 ec 04             	sub    $0x4,%esp
f010527f:	6a 01                	push   $0x1
f0105281:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105284:	50                   	push   %eax
f0105285:	ff 75 0c             	pushl  0xc(%ebp)
f0105288:	e8 33 e0 ff ff       	call   f01032c0 <envid2env>
f010528d:	83 c4 10             	add    $0x10,%esp
f0105290:	85 c0                	test   %eax,%eax
f0105292:	0f 88 b7 01 00 00    	js     f010544f <syscall+0x538>
		return ret;

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f0105298:	8b 45 10             	mov    0x10(%ebp),%eax
f010529b:	83 e8 02             	sub    $0x2,%eax
f010529e:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f01052a3:	75 13                	jne    f01052b8 <syscall+0x3a1>
		return -E_INVAL;

	e->env_status = status;
f01052a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01052a8:	8b 7d 10             	mov    0x10(%ebp),%edi
f01052ab:	89 78 54             	mov    %edi,0x54(%eax)

	return 0;
f01052ae:	b8 00 00 00 00       	mov    $0x0,%eax
f01052b3:	e9 97 01 00 00       	jmp    f010544f <syscall+0x538>

	if ((ret = envid2env(envid, &e, 1)) < 0)
		return ret;

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
		return -E_INVAL;
f01052b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	case SYS_page_unmap:
		return sys_page_unmap(a1, (void *) a2);
	case SYS_exofork:
		return sys_exofork();
	case SYS_env_set_status:
		return sys_env_set_status(a1, a2);
f01052bd:	e9 8d 01 00 00       	jmp    f010544f <syscall+0x538>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	struct Env *e;
	int ret;
	
	if ((ret = envid2env(envid, &e, 1)) < 0)
f01052c2:	83 ec 04             	sub    $0x4,%esp
f01052c5:	6a 01                	push   $0x1
f01052c7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01052ca:	50                   	push   %eax
f01052cb:	ff 75 0c             	pushl  0xc(%ebp)
f01052ce:	e8 ed df ff ff       	call   f01032c0 <envid2env>
f01052d3:	83 c4 10             	add    $0x10,%esp
f01052d6:	85 c0                	test   %eax,%eax
f01052d8:	0f 88 71 01 00 00    	js     f010544f <syscall+0x538>
		return ret;

	e->env_pgfault_upcall = func;
f01052de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01052e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01052e4:	89 48 64             	mov    %ecx,0x64(%eax)
	return 0;
f01052e7:	b8 00 00 00 00       	mov    $0x0,%eax
f01052ec:	e9 5e 01 00 00       	jmp    f010544f <syscall+0x538>
	struct Env *e;
	struct PageInfo *pp;
	pte_t *pte;
	int ret;

	if ((ret = envid2env(envid, &e, 0)) < 0)
f01052f1:	83 ec 04             	sub    $0x4,%esp
f01052f4:	6a 00                	push   $0x0
f01052f6:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01052f9:	50                   	push   %eax
f01052fa:	ff 75 0c             	pushl  0xc(%ebp)
f01052fd:	e8 be df ff ff       	call   f01032c0 <envid2env>
f0105302:	83 c4 10             	add    $0x10,%esp
f0105305:	85 c0                	test   %eax,%eax
f0105307:	0f 88 42 01 00 00    	js     f010544f <syscall+0x538>
		return ret;

	if (!e->env_ipc_recving)
f010530d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105310:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0105314:	0f 84 bb 00 00 00    	je     f01053d5 <syscall+0x4be>
	if (!(e->env_ipc_dstva < (void *) UTOP)) {
		perm = 0;
		goto _update_ipc_fields;
	}

	if (srcva < (void *) UTOP) {
f010531a:	81 78 6c ff ff bf ee 	cmpl   $0xeebfffff,0x6c(%eax)
f0105321:	77 6c                	ja     f010538f <syscall+0x478>
f0105323:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f010532a:	77 63                	ja     f010538f <syscall+0x478>
		if (PGOFF(srcva) != 0) 
f010532c:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0105333:	0f 85 a3 00 00 00    	jne    f01053dc <syscall+0x4c5>
			return -E_INVAL;

		if ((perm & (PTE_U|PTE_P)) != (PTE_U|PTE_P) || (perm & ~PTE_SYSCALL) != 0)
f0105339:	8b 45 18             	mov    0x18(%ebp),%eax
f010533c:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f0105341:	83 f8 05             	cmp    $0x5,%eax
f0105344:	0f 85 99 00 00 00    	jne    f01053e3 <syscall+0x4cc>
			return -E_INVAL;

		if ((pp = page_lookup(curenv->env_pgdir, srcva, &pte)) == NULL)
f010534a:	e8 87 12 00 00       	call   f01065d6 <cpunum>
f010534f:	83 ec 04             	sub    $0x4,%esp
f0105352:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105355:	52                   	push   %edx
f0105356:	ff 75 14             	pushl  0x14(%ebp)
f0105359:	6b c0 74             	imul   $0x74,%eax,%eax
f010535c:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0105362:	ff 70 60             	pushl  0x60(%eax)
f0105365:	e8 b9 c1 ff ff       	call   f0101523 <page_lookup>
f010536a:	83 c4 10             	add    $0x10,%esp
f010536d:	85 c0                	test   %eax,%eax
f010536f:	74 79                	je     f01053ea <syscall+0x4d3>
			return -E_INVAL;

		if ((perm & PTE_W) && !(*pte | PTE_W))
			return -E_INVAL;

		if ((ret = page_insert(e->env_pgdir, pp, e->env_ipc_dstva, perm)) < 0)
f0105371:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105374:	ff 75 18             	pushl  0x18(%ebp)
f0105377:	ff 72 6c             	pushl  0x6c(%edx)
f010537a:	50                   	push   %eax
f010537b:	ff 72 60             	pushl  0x60(%edx)
f010537e:	e8 8a c2 ff ff       	call   f010160d <page_insert>
f0105383:	83 c4 10             	add    $0x10,%esp
f0105386:	85 c0                	test   %eax,%eax
f0105388:	79 0c                	jns    f0105396 <syscall+0x47f>
f010538a:	e9 c0 00 00 00       	jmp    f010544f <syscall+0x538>
			return ret;
	} else 
		perm = 0; // no page sent
f010538f:	c7 45 18 00 00 00 00 	movl   $0x0,0x18(%ebp)

_update_ipc_fields:
	e->env_ipc_recving = 0;
f0105396:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105399:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	e->env_ipc_from = curenv->env_id;
f010539d:	e8 34 12 00 00       	call   f01065d6 <cpunum>
f01053a2:	6b c0 74             	imul   $0x74,%eax,%eax
f01053a5:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f01053ab:	8b 40 48             	mov    0x48(%eax),%eax
f01053ae:	89 43 74             	mov    %eax,0x74(%ebx)
	e->env_ipc_value = value;
f01053b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01053b4:	8b 7d 10             	mov    0x10(%ebp),%edi
f01053b7:	89 78 70             	mov    %edi,0x70(%eax)
	e->env_ipc_perm = perm;
f01053ba:	8b 4d 18             	mov    0x18(%ebp),%ecx
f01053bd:	89 48 78             	mov    %ecx,0x78(%eax)
	
	e->env_status = ENV_RUNNABLE;
f01053c0:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	e->env_tf.tf_regs.reg_eax = 0;
f01053c7:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	return 0;
f01053ce:	b8 00 00 00 00       	mov    $0x0,%eax
f01053d3:	eb 7a                	jmp    f010544f <syscall+0x538>

	if ((ret = envid2env(envid, &e, 0)) < 0)
		return ret;

	if (!e->env_ipc_recving)
		return -E_IPC_NOT_RECV;
f01053d5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
f01053da:	eb 73                	jmp    f010544f <syscall+0x538>
		goto _update_ipc_fields;
	}

	if (srcva < (void *) UTOP) {
		if (PGOFF(srcva) != 0) 
			return -E_INVAL;
f01053dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01053e1:	eb 6c                	jmp    f010544f <syscall+0x538>

		if ((perm & (PTE_U|PTE_P)) != (PTE_U|PTE_P) || (perm & ~PTE_SYSCALL) != 0)
			return -E_INVAL;
f01053e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01053e8:	eb 65                	jmp    f010544f <syscall+0x538>

		if ((pp = page_lookup(curenv->env_pgdir, srcva, &pte)) == NULL)
			return -E_INVAL;
f01053ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01053ef:	eb 5e                	jmp    f010544f <syscall+0x538>
// Return < 0 on error.  Errors are:
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	if (dstva < (void *) UTOP && PGOFF(dstva) != 0)
f01053f1:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f01053f8:	77 09                	ja     f0105403 <syscall+0x4ec>
f01053fa:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0105401:	75 47                	jne    f010544a <syscall+0x533>
		return -E_INVAL;

	curenv->env_ipc_recving = 1;
f0105403:	e8 ce 11 00 00       	call   f01065d6 <cpunum>
f0105408:	6b c0 74             	imul   $0x74,%eax,%eax
f010540b:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0105411:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva = dstva;
f0105415:	e8 bc 11 00 00       	call   f01065d6 <cpunum>
f010541a:	6b c0 74             	imul   $0x74,%eax,%eax
f010541d:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0105423:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105426:	89 70 6c             	mov    %esi,0x6c(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0105429:	e8 a8 11 00 00       	call   f01065d6 <cpunum>
f010542e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105431:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0105437:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)

	sched_yield();
f010543e:	e8 21 fa ff ff       	call   f0104e64 <sched_yield>
	case SYS_ipc_try_send:
		return sys_ipc_try_send(a1, a2, (void *) a3, a4);
	case SYS_ipc_recv:
		return sys_ipc_recv((void *) a1);
	default:
		return -E_NO_SYS;
f0105443:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
f0105448:	eb 05                	jmp    f010544f <syscall+0x538>
	case SYS_env_set_pgfault_upcall:
		return sys_env_set_pgfault_upcall(a1, (void *) a2);	
	case SYS_ipc_try_send:
		return sys_ipc_try_send(a1, a2, (void *) a3, a4);
	case SYS_ipc_recv:
		return sys_ipc_recv((void *) a1);
f010544a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	default:
		return -E_NO_SYS;
	}
}
f010544f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105452:	5b                   	pop    %ebx
f0105453:	5e                   	pop    %esi
f0105454:	5f                   	pop    %edi
f0105455:	5d                   	pop    %ebp
f0105456:	c3                   	ret    

f0105457 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0105457:	55                   	push   %ebp
f0105458:	89 e5                	mov    %esp,%ebp
f010545a:	57                   	push   %edi
f010545b:	56                   	push   %esi
f010545c:	53                   	push   %ebx
f010545d:	83 ec 14             	sub    $0x14,%esp
f0105460:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105463:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0105466:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105469:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f010546c:	8b 1a                	mov    (%edx),%ebx
f010546e:	8b 01                	mov    (%ecx),%eax
f0105470:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105473:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f010547a:	eb 7f                	jmp    f01054fb <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f010547c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010547f:	01 d8                	add    %ebx,%eax
f0105481:	89 c6                	mov    %eax,%esi
f0105483:	c1 ee 1f             	shr    $0x1f,%esi
f0105486:	01 c6                	add    %eax,%esi
f0105488:	d1 fe                	sar    %esi
f010548a:	8d 04 76             	lea    (%esi,%esi,2),%eax
f010548d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105490:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0105493:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105495:	eb 03                	jmp    f010549a <stab_binsearch+0x43>
			m--;
f0105497:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010549a:	39 c3                	cmp    %eax,%ebx
f010549c:	7f 0d                	jg     f01054ab <stab_binsearch+0x54>
f010549e:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01054a2:	83 ea 0c             	sub    $0xc,%edx
f01054a5:	39 f9                	cmp    %edi,%ecx
f01054a7:	75 ee                	jne    f0105497 <stab_binsearch+0x40>
f01054a9:	eb 05                	jmp    f01054b0 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01054ab:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f01054ae:	eb 4b                	jmp    f01054fb <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01054b0:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01054b3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01054b6:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01054ba:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01054bd:	76 11                	jbe    f01054d0 <stab_binsearch+0x79>
			*region_left = m;
f01054bf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01054c2:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01054c4:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01054c7:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01054ce:	eb 2b                	jmp    f01054fb <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01054d0:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01054d3:	73 14                	jae    f01054e9 <stab_binsearch+0x92>
			*region_right = m - 1;
f01054d5:	83 e8 01             	sub    $0x1,%eax
f01054d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01054db:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01054de:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01054e0:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01054e7:	eb 12                	jmp    f01054fb <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01054e9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01054ec:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f01054ee:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01054f2:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01054f4:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01054fb:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01054fe:	0f 8e 78 ff ff ff    	jle    f010547c <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0105504:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0105508:	75 0f                	jne    f0105519 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f010550a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010550d:	8b 00                	mov    (%eax),%eax
f010550f:	83 e8 01             	sub    $0x1,%eax
f0105512:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105515:	89 06                	mov    %eax,(%esi)
f0105517:	eb 2c                	jmp    f0105545 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105519:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010551c:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f010551e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105521:	8b 0e                	mov    (%esi),%ecx
f0105523:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105526:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0105529:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010552c:	eb 03                	jmp    f0105531 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f010552e:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105531:	39 c8                	cmp    %ecx,%eax
f0105533:	7e 0b                	jle    f0105540 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0105535:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0105539:	83 ea 0c             	sub    $0xc,%edx
f010553c:	39 df                	cmp    %ebx,%edi
f010553e:	75 ee                	jne    f010552e <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0105540:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105543:	89 06                	mov    %eax,(%esi)
	}
}
f0105545:	83 c4 14             	add    $0x14,%esp
f0105548:	5b                   	pop    %ebx
f0105549:	5e                   	pop    %esi
f010554a:	5f                   	pop    %edi
f010554b:	5d                   	pop    %ebp
f010554c:	c3                   	ret    

f010554d <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010554d:	55                   	push   %ebp
f010554e:	89 e5                	mov    %esp,%ebp
f0105550:	57                   	push   %edi
f0105551:	56                   	push   %esi
f0105552:	53                   	push   %ebx
f0105553:	83 ec 3c             	sub    $0x3c,%esp
f0105556:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105559:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f010555c:	c7 03 54 86 10 f0    	movl   $0xf0108654,(%ebx)
	info->eip_line = 0;
f0105562:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0105569:	c7 43 08 54 86 10 f0 	movl   $0xf0108654,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0105570:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0105577:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f010557a:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0105581:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0105587:	0f 87 9a 00 00 00    	ja     f0105627 <debuginfo_eip+0xda>
		// USTABDATA.
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		if (user_mem_check(curenv, usd, sizeof(*usd), PTE_U | PTE_P) < 0)
f010558d:	e8 44 10 00 00       	call   f01065d6 <cpunum>
f0105592:	6a 05                	push   $0x5
f0105594:	6a 10                	push   $0x10
f0105596:	68 00 00 20 00       	push   $0x200000
f010559b:	6b c0 74             	imul   $0x74,%eax,%eax
f010559e:	ff b0 28 20 23 f0    	pushl  -0xfdcdfd8(%eax)
f01055a4:	e8 6e db ff ff       	call   f0103117 <user_mem_check>
f01055a9:	83 c4 10             	add    $0x10,%esp
f01055ac:	85 c0                	test   %eax,%eax
f01055ae:	0f 88 35 02 00 00    	js     f01057e9 <debuginfo_eip+0x29c>
			return -1;

		stabs = usd->stabs;
f01055b4:	a1 00 00 20 00       	mov    0x200000,%eax
f01055b9:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f01055bc:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f01055c2:	8b 15 08 00 20 00    	mov    0x200008,%edx
f01055c8:	89 55 b8             	mov    %edx,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f01055cb:	a1 0c 00 20 00       	mov    0x20000c,%eax
f01055d0:	89 45 bc             	mov    %eax,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		if (user_mem_check(curenv, stabs, (stab_end - stabs) * sizeof(*stabs), PTE_U | PTE_P) < 0)
f01055d3:	e8 fe 0f 00 00       	call   f01065d6 <cpunum>
f01055d8:	6a 05                	push   $0x5
f01055da:	89 f2                	mov    %esi,%edx
f01055dc:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01055df:	29 ca                	sub    %ecx,%edx
f01055e1:	52                   	push   %edx
f01055e2:	51                   	push   %ecx
f01055e3:	6b c0 74             	imul   $0x74,%eax,%eax
f01055e6:	ff b0 28 20 23 f0    	pushl  -0xfdcdfd8(%eax)
f01055ec:	e8 26 db ff ff       	call   f0103117 <user_mem_check>
f01055f1:	83 c4 10             	add    $0x10,%esp
f01055f4:	85 c0                	test   %eax,%eax
f01055f6:	0f 88 f4 01 00 00    	js     f01057f0 <debuginfo_eip+0x2a3>
			return -1;
		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U | PTE_P) < 0)
f01055fc:	e8 d5 0f 00 00       	call   f01065d6 <cpunum>
f0105601:	6a 05                	push   $0x5
f0105603:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0105606:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0105609:	29 ca                	sub    %ecx,%edx
f010560b:	52                   	push   %edx
f010560c:	51                   	push   %ecx
f010560d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105610:	ff b0 28 20 23 f0    	pushl  -0xfdcdfd8(%eax)
f0105616:	e8 fc da ff ff       	call   f0103117 <user_mem_check>
f010561b:	83 c4 10             	add    $0x10,%esp
f010561e:	85 c0                	test   %eax,%eax
f0105620:	79 1f                	jns    f0105641 <debuginfo_eip+0xf4>
f0105622:	e9 d0 01 00 00       	jmp    f01057f7 <debuginfo_eip+0x2aa>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0105627:	c7 45 bc 72 74 11 f0 	movl   $0xf0117472,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f010562e:	c7 45 b8 69 3c 11 f0 	movl   $0xf0113c69,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0105635:	be 68 3c 11 f0       	mov    $0xf0113c68,%esi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f010563a:	c7 45 c0 38 8b 10 f0 	movl   $0xf0108b38,-0x40(%ebp)
		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U | PTE_P) < 0)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0105641:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0105644:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f0105647:	0f 83 b1 01 00 00    	jae    f01057fe <debuginfo_eip+0x2b1>
f010564d:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0105651:	0f 85 ae 01 00 00    	jne    f0105805 <debuginfo_eip+0x2b8>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0105657:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010565e:	2b 75 c0             	sub    -0x40(%ebp),%esi
f0105661:	c1 fe 02             	sar    $0x2,%esi
f0105664:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f010566a:	83 e8 01             	sub    $0x1,%eax
f010566d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0105670:	83 ec 08             	sub    $0x8,%esp
f0105673:	57                   	push   %edi
f0105674:	6a 64                	push   $0x64
f0105676:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0105679:	89 d1                	mov    %edx,%ecx
f010567b:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010567e:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0105681:	89 f0                	mov    %esi,%eax
f0105683:	e8 cf fd ff ff       	call   f0105457 <stab_binsearch>
	if (lfile == 0)
f0105688:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010568b:	83 c4 10             	add    $0x10,%esp
f010568e:	85 c0                	test   %eax,%eax
f0105690:	0f 84 76 01 00 00    	je     f010580c <debuginfo_eip+0x2bf>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105696:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0105699:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010569c:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010569f:	83 ec 08             	sub    $0x8,%esp
f01056a2:	57                   	push   %edi
f01056a3:	6a 24                	push   $0x24
f01056a5:	8d 55 d8             	lea    -0x28(%ebp),%edx
f01056a8:	89 d1                	mov    %edx,%ecx
f01056aa:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01056ad:	89 f0                	mov    %esi,%eax
f01056af:	e8 a3 fd ff ff       	call   f0105457 <stab_binsearch>

	if (lfun <= rfun) {
f01056b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01056b7:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01056ba:	83 c4 10             	add    $0x10,%esp
f01056bd:	39 d0                	cmp    %edx,%eax
f01056bf:	7f 2e                	jg     f01056ef <debuginfo_eip+0x1a2>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01056c1:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f01056c4:	8d 34 8e             	lea    (%esi,%ecx,4),%esi
f01056c7:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f01056ca:	8b 36                	mov    (%esi),%esi
f01056cc:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f01056cf:	2b 4d b8             	sub    -0x48(%ebp),%ecx
f01056d2:	39 ce                	cmp    %ecx,%esi
f01056d4:	73 06                	jae    f01056dc <debuginfo_eip+0x18f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01056d6:	03 75 b8             	add    -0x48(%ebp),%esi
f01056d9:	89 73 08             	mov    %esi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01056dc:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01056df:	8b 4e 08             	mov    0x8(%esi),%ecx
f01056e2:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01056e5:	29 cf                	sub    %ecx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f01056e7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01056ea:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01056ed:	eb 0f                	jmp    f01056fe <debuginfo_eip+0x1b1>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01056ef:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f01056f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01056f5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01056f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01056fb:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01056fe:	83 ec 08             	sub    $0x8,%esp
f0105701:	6a 3a                	push   $0x3a
f0105703:	ff 73 08             	pushl  0x8(%ebx)
f0105706:	e8 8f 08 00 00       	call   f0105f9a <strfind>
f010570b:	2b 43 08             	sub    0x8(%ebx),%eax
f010570e:	89 43 0c             	mov    %eax,0xc(%ebx)
	//
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0105711:	83 c4 08             	add    $0x8,%esp
f0105714:	57                   	push   %edi
f0105715:	6a 44                	push   $0x44
f0105717:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f010571a:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f010571d:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0105720:	89 f8                	mov    %edi,%eax
f0105722:	e8 30 fd ff ff       	call   f0105457 <stab_binsearch>
	
	if (lline <= rline) {
f0105727:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010572a:	83 c4 10             	add    $0x10,%esp
f010572d:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0105730:	0f 8f dd 00 00 00    	jg     f0105813 <debuginfo_eip+0x2c6>
		info->eip_line = stabs[lline].n_desc;
f0105736:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105739:	8d 14 97             	lea    (%edi,%edx,4),%edx
f010573c:	0f b7 4a 06          	movzwl 0x6(%edx),%ecx
f0105740:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105743:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105746:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f010574a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010574d:	eb 0a                	jmp    f0105759 <debuginfo_eip+0x20c>
f010574f:	83 e8 01             	sub    $0x1,%eax
f0105752:	83 ea 0c             	sub    $0xc,%edx
f0105755:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0105759:	39 c7                	cmp    %eax,%edi
f010575b:	7e 05                	jle    f0105762 <debuginfo_eip+0x215>
f010575d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105760:	eb 47                	jmp    f01057a9 <debuginfo_eip+0x25c>
	       && stabs[lline].n_type != N_SOL
f0105762:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0105766:	80 f9 84             	cmp    $0x84,%cl
f0105769:	75 0e                	jne    f0105779 <debuginfo_eip+0x22c>
f010576b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010576e:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0105772:	74 1c                	je     f0105790 <debuginfo_eip+0x243>
f0105774:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105777:	eb 17                	jmp    f0105790 <debuginfo_eip+0x243>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105779:	80 f9 64             	cmp    $0x64,%cl
f010577c:	75 d1                	jne    f010574f <debuginfo_eip+0x202>
f010577e:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0105782:	74 cb                	je     f010574f <debuginfo_eip+0x202>
f0105784:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105787:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f010578b:	74 03                	je     f0105790 <debuginfo_eip+0x243>
f010578d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105790:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105793:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0105796:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0105799:	8b 45 bc             	mov    -0x44(%ebp),%eax
f010579c:	8b 7d b8             	mov    -0x48(%ebp),%edi
f010579f:	29 f8                	sub    %edi,%eax
f01057a1:	39 c2                	cmp    %eax,%edx
f01057a3:	73 04                	jae    f01057a9 <debuginfo_eip+0x25c>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01057a5:	01 fa                	add    %edi,%edx
f01057a7:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01057a9:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01057ac:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01057af:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01057b4:	39 f2                	cmp    %esi,%edx
f01057b6:	7d 67                	jge    f010581f <debuginfo_eip+0x2d2>
		for (lline = lfun + 1;
f01057b8:	83 c2 01             	add    $0x1,%edx
f01057bb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01057be:	89 d0                	mov    %edx,%eax
f01057c0:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01057c3:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01057c6:	8d 14 97             	lea    (%edi,%edx,4),%edx
f01057c9:	eb 04                	jmp    f01057cf <debuginfo_eip+0x282>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01057cb:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01057cf:	39 c6                	cmp    %eax,%esi
f01057d1:	7e 47                	jle    f010581a <debuginfo_eip+0x2cd>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01057d3:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01057d7:	83 c0 01             	add    $0x1,%eax
f01057da:	83 c2 0c             	add    $0xc,%edx
f01057dd:	80 f9 a0             	cmp    $0xa0,%cl
f01057e0:	74 e9                	je     f01057cb <debuginfo_eip+0x27e>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01057e2:	b8 00 00 00 00       	mov    $0x0,%eax
f01057e7:	eb 36                	jmp    f010581f <debuginfo_eip+0x2d2>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		if (user_mem_check(curenv, usd, sizeof(*usd), PTE_U | PTE_P) < 0)
			return -1;
f01057e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01057ee:	eb 2f                	jmp    f010581f <debuginfo_eip+0x2d2>
		stabstr = usd->stabstr;
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		if (user_mem_check(curenv, stabs, (stab_end - stabs) * sizeof(*stabs), PTE_U | PTE_P) < 0)
			return -1;
f01057f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01057f5:	eb 28                	jmp    f010581f <debuginfo_eip+0x2d2>
		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U | PTE_P) < 0)
			return -1;
f01057f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01057fc:	eb 21                	jmp    f010581f <debuginfo_eip+0x2d2>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01057fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105803:	eb 1a                	jmp    f010581f <debuginfo_eip+0x2d2>
f0105805:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010580a:	eb 13                	jmp    f010581f <debuginfo_eip+0x2d2>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f010580c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105811:	eb 0c                	jmp    f010581f <debuginfo_eip+0x2d2>
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	
	if (lline <= rline) {
		info->eip_line = stabs[lline].n_desc;
	} else return -1;
f0105813:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105818:	eb 05                	jmp    f010581f <debuginfo_eip+0x2d2>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010581a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010581f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105822:	5b                   	pop    %ebx
f0105823:	5e                   	pop    %esi
f0105824:	5f                   	pop    %edi
f0105825:	5d                   	pop    %ebp
f0105826:	c3                   	ret    

f0105827 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105827:	55                   	push   %ebp
f0105828:	89 e5                	mov    %esp,%ebp
f010582a:	57                   	push   %edi
f010582b:	56                   	push   %esi
f010582c:	53                   	push   %ebx
f010582d:	83 ec 1c             	sub    $0x1c,%esp
f0105830:	89 c7                	mov    %eax,%edi
f0105832:	89 d6                	mov    %edx,%esi
f0105834:	8b 45 08             	mov    0x8(%ebp),%eax
f0105837:	8b 55 0c             	mov    0xc(%ebp),%edx
f010583a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010583d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105840:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0105843:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105848:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010584b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f010584e:	39 d3                	cmp    %edx,%ebx
f0105850:	72 05                	jb     f0105857 <printnum+0x30>
f0105852:	39 45 10             	cmp    %eax,0x10(%ebp)
f0105855:	77 45                	ja     f010589c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105857:	83 ec 0c             	sub    $0xc,%esp
f010585a:	ff 75 18             	pushl  0x18(%ebp)
f010585d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105860:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0105863:	53                   	push   %ebx
f0105864:	ff 75 10             	pushl  0x10(%ebp)
f0105867:	83 ec 08             	sub    $0x8,%esp
f010586a:	ff 75 e4             	pushl  -0x1c(%ebp)
f010586d:	ff 75 e0             	pushl  -0x20(%ebp)
f0105870:	ff 75 dc             	pushl  -0x24(%ebp)
f0105873:	ff 75 d8             	pushl  -0x28(%ebp)
f0105876:	e8 55 11 00 00       	call   f01069d0 <__udivdi3>
f010587b:	83 c4 18             	add    $0x18,%esp
f010587e:	52                   	push   %edx
f010587f:	50                   	push   %eax
f0105880:	89 f2                	mov    %esi,%edx
f0105882:	89 f8                	mov    %edi,%eax
f0105884:	e8 9e ff ff ff       	call   f0105827 <printnum>
f0105889:	83 c4 20             	add    $0x20,%esp
f010588c:	eb 18                	jmp    f01058a6 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f010588e:	83 ec 08             	sub    $0x8,%esp
f0105891:	56                   	push   %esi
f0105892:	ff 75 18             	pushl  0x18(%ebp)
f0105895:	ff d7                	call   *%edi
f0105897:	83 c4 10             	add    $0x10,%esp
f010589a:	eb 03                	jmp    f010589f <printnum+0x78>
f010589c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f010589f:	83 eb 01             	sub    $0x1,%ebx
f01058a2:	85 db                	test   %ebx,%ebx
f01058a4:	7f e8                	jg     f010588e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01058a6:	83 ec 08             	sub    $0x8,%esp
f01058a9:	56                   	push   %esi
f01058aa:	83 ec 04             	sub    $0x4,%esp
f01058ad:	ff 75 e4             	pushl  -0x1c(%ebp)
f01058b0:	ff 75 e0             	pushl  -0x20(%ebp)
f01058b3:	ff 75 dc             	pushl  -0x24(%ebp)
f01058b6:	ff 75 d8             	pushl  -0x28(%ebp)
f01058b9:	e8 42 12 00 00       	call   f0106b00 <__umoddi3>
f01058be:	83 c4 14             	add    $0x14,%esp
f01058c1:	0f be 80 5e 86 10 f0 	movsbl -0xfef79a2(%eax),%eax
f01058c8:	50                   	push   %eax
f01058c9:	ff d7                	call   *%edi
}
f01058cb:	83 c4 10             	add    $0x10,%esp
f01058ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01058d1:	5b                   	pop    %ebx
f01058d2:	5e                   	pop    %esi
f01058d3:	5f                   	pop    %edi
f01058d4:	5d                   	pop    %ebp
f01058d5:	c3                   	ret    

f01058d6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01058d6:	55                   	push   %ebp
f01058d7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01058d9:	83 fa 01             	cmp    $0x1,%edx
f01058dc:	7e 0e                	jle    f01058ec <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01058de:	8b 10                	mov    (%eax),%edx
f01058e0:	8d 4a 08             	lea    0x8(%edx),%ecx
f01058e3:	89 08                	mov    %ecx,(%eax)
f01058e5:	8b 02                	mov    (%edx),%eax
f01058e7:	8b 52 04             	mov    0x4(%edx),%edx
f01058ea:	eb 22                	jmp    f010590e <getuint+0x38>
	else if (lflag)
f01058ec:	85 d2                	test   %edx,%edx
f01058ee:	74 10                	je     f0105900 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f01058f0:	8b 10                	mov    (%eax),%edx
f01058f2:	8d 4a 04             	lea    0x4(%edx),%ecx
f01058f5:	89 08                	mov    %ecx,(%eax)
f01058f7:	8b 02                	mov    (%edx),%eax
f01058f9:	ba 00 00 00 00       	mov    $0x0,%edx
f01058fe:	eb 0e                	jmp    f010590e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105900:	8b 10                	mov    (%eax),%edx
f0105902:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105905:	89 08                	mov    %ecx,(%eax)
f0105907:	8b 02                	mov    (%edx),%eax
f0105909:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010590e:	5d                   	pop    %ebp
f010590f:	c3                   	ret    

f0105910 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105910:	55                   	push   %ebp
f0105911:	89 e5                	mov    %esp,%ebp
f0105913:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105916:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010591a:	8b 10                	mov    (%eax),%edx
f010591c:	3b 50 04             	cmp    0x4(%eax),%edx
f010591f:	73 0a                	jae    f010592b <sprintputch+0x1b>
		*b->buf++ = ch;
f0105921:	8d 4a 01             	lea    0x1(%edx),%ecx
f0105924:	89 08                	mov    %ecx,(%eax)
f0105926:	8b 45 08             	mov    0x8(%ebp),%eax
f0105929:	88 02                	mov    %al,(%edx)
}
f010592b:	5d                   	pop    %ebp
f010592c:	c3                   	ret    

f010592d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f010592d:	55                   	push   %ebp
f010592e:	89 e5                	mov    %esp,%ebp
f0105930:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0105933:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105936:	50                   	push   %eax
f0105937:	ff 75 10             	pushl  0x10(%ebp)
f010593a:	ff 75 0c             	pushl  0xc(%ebp)
f010593d:	ff 75 08             	pushl  0x8(%ebp)
f0105940:	e8 05 00 00 00       	call   f010594a <vprintfmt>
	va_end(ap);
}
f0105945:	83 c4 10             	add    $0x10,%esp
f0105948:	c9                   	leave  
f0105949:	c3                   	ret    

f010594a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010594a:	55                   	push   %ebp
f010594b:	89 e5                	mov    %esp,%ebp
f010594d:	57                   	push   %edi
f010594e:	56                   	push   %esi
f010594f:	53                   	push   %ebx
f0105950:	83 ec 2c             	sub    $0x2c,%esp
f0105953:	8b 75 08             	mov    0x8(%ebp),%esi
f0105956:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105959:	8b 7d 10             	mov    0x10(%ebp),%edi
f010595c:	eb 12                	jmp    f0105970 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f010595e:	85 c0                	test   %eax,%eax
f0105960:	0f 84 89 03 00 00    	je     f0105cef <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0105966:	83 ec 08             	sub    $0x8,%esp
f0105969:	53                   	push   %ebx
f010596a:	50                   	push   %eax
f010596b:	ff d6                	call   *%esi
f010596d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105970:	83 c7 01             	add    $0x1,%edi
f0105973:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105977:	83 f8 25             	cmp    $0x25,%eax
f010597a:	75 e2                	jne    f010595e <vprintfmt+0x14>
f010597c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0105980:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0105987:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f010598e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0105995:	ba 00 00 00 00       	mov    $0x0,%edx
f010599a:	eb 07                	jmp    f01059a3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010599c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f010599f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01059a3:	8d 47 01             	lea    0x1(%edi),%eax
f01059a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01059a9:	0f b6 07             	movzbl (%edi),%eax
f01059ac:	0f b6 c8             	movzbl %al,%ecx
f01059af:	83 e8 23             	sub    $0x23,%eax
f01059b2:	3c 55                	cmp    $0x55,%al
f01059b4:	0f 87 1a 03 00 00    	ja     f0105cd4 <vprintfmt+0x38a>
f01059ba:	0f b6 c0             	movzbl %al,%eax
f01059bd:	ff 24 85 20 87 10 f0 	jmp    *-0xfef78e0(,%eax,4)
f01059c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01059c7:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f01059cb:	eb d6                	jmp    f01059a3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01059cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01059d0:	b8 00 00 00 00       	mov    $0x0,%eax
f01059d5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01059d8:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01059db:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f01059df:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f01059e2:	8d 51 d0             	lea    -0x30(%ecx),%edx
f01059e5:	83 fa 09             	cmp    $0x9,%edx
f01059e8:	77 39                	ja     f0105a23 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01059ea:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f01059ed:	eb e9                	jmp    f01059d8 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01059ef:	8b 45 14             	mov    0x14(%ebp),%eax
f01059f2:	8d 48 04             	lea    0x4(%eax),%ecx
f01059f5:	89 4d 14             	mov    %ecx,0x14(%ebp)
f01059f8:	8b 00                	mov    (%eax),%eax
f01059fa:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01059fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0105a00:	eb 27                	jmp    f0105a29 <vprintfmt+0xdf>
f0105a02:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105a05:	85 c0                	test   %eax,%eax
f0105a07:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105a0c:	0f 49 c8             	cmovns %eax,%ecx
f0105a0f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105a12:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105a15:	eb 8c                	jmp    f01059a3 <vprintfmt+0x59>
f0105a17:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105a1a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0105a21:	eb 80                	jmp    f01059a3 <vprintfmt+0x59>
f0105a23:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105a26:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0105a29:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105a2d:	0f 89 70 ff ff ff    	jns    f01059a3 <vprintfmt+0x59>
				width = precision, precision = -1;
f0105a33:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105a36:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105a39:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0105a40:	e9 5e ff ff ff       	jmp    f01059a3 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105a45:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105a48:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0105a4b:	e9 53 ff ff ff       	jmp    f01059a3 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105a50:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a53:	8d 50 04             	lea    0x4(%eax),%edx
f0105a56:	89 55 14             	mov    %edx,0x14(%ebp)
f0105a59:	83 ec 08             	sub    $0x8,%esp
f0105a5c:	53                   	push   %ebx
f0105a5d:	ff 30                	pushl  (%eax)
f0105a5f:	ff d6                	call   *%esi
			break;
f0105a61:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105a64:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105a67:	e9 04 ff ff ff       	jmp    f0105970 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105a6c:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a6f:	8d 50 04             	lea    0x4(%eax),%edx
f0105a72:	89 55 14             	mov    %edx,0x14(%ebp)
f0105a75:	8b 00                	mov    (%eax),%eax
f0105a77:	99                   	cltd   
f0105a78:	31 d0                	xor    %edx,%eax
f0105a7a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105a7c:	83 f8 09             	cmp    $0x9,%eax
f0105a7f:	7f 0b                	jg     f0105a8c <vprintfmt+0x142>
f0105a81:	8b 14 85 80 88 10 f0 	mov    -0xfef7780(,%eax,4),%edx
f0105a88:	85 d2                	test   %edx,%edx
f0105a8a:	75 18                	jne    f0105aa4 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0105a8c:	50                   	push   %eax
f0105a8d:	68 76 86 10 f0       	push   $0xf0108676
f0105a92:	53                   	push   %ebx
f0105a93:	56                   	push   %esi
f0105a94:	e8 94 fe ff ff       	call   f010592d <printfmt>
f0105a99:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105a9c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0105a9f:	e9 cc fe ff ff       	jmp    f0105970 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0105aa4:	52                   	push   %edx
f0105aa5:	68 51 7d 10 f0       	push   $0xf0107d51
f0105aaa:	53                   	push   %ebx
f0105aab:	56                   	push   %esi
f0105aac:	e8 7c fe ff ff       	call   f010592d <printfmt>
f0105ab1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105ab4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105ab7:	e9 b4 fe ff ff       	jmp    f0105970 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105abc:	8b 45 14             	mov    0x14(%ebp),%eax
f0105abf:	8d 50 04             	lea    0x4(%eax),%edx
f0105ac2:	89 55 14             	mov    %edx,0x14(%ebp)
f0105ac5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0105ac7:	85 ff                	test   %edi,%edi
f0105ac9:	b8 6f 86 10 f0       	mov    $0xf010866f,%eax
f0105ace:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0105ad1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105ad5:	0f 8e 94 00 00 00    	jle    f0105b6f <vprintfmt+0x225>
f0105adb:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0105adf:	0f 84 98 00 00 00    	je     f0105b7d <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105ae5:	83 ec 08             	sub    $0x8,%esp
f0105ae8:	ff 75 d0             	pushl  -0x30(%ebp)
f0105aeb:	57                   	push   %edi
f0105aec:	e8 5f 03 00 00       	call   f0105e50 <strnlen>
f0105af1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105af4:	29 c1                	sub    %eax,%ecx
f0105af6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0105af9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0105afc:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0105b00:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105b03:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105b06:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105b08:	eb 0f                	jmp    f0105b19 <vprintfmt+0x1cf>
					putch(padc, putdat);
f0105b0a:	83 ec 08             	sub    $0x8,%esp
f0105b0d:	53                   	push   %ebx
f0105b0e:	ff 75 e0             	pushl  -0x20(%ebp)
f0105b11:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105b13:	83 ef 01             	sub    $0x1,%edi
f0105b16:	83 c4 10             	add    $0x10,%esp
f0105b19:	85 ff                	test   %edi,%edi
f0105b1b:	7f ed                	jg     f0105b0a <vprintfmt+0x1c0>
f0105b1d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0105b20:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0105b23:	85 c9                	test   %ecx,%ecx
f0105b25:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b2a:	0f 49 c1             	cmovns %ecx,%eax
f0105b2d:	29 c1                	sub    %eax,%ecx
f0105b2f:	89 75 08             	mov    %esi,0x8(%ebp)
f0105b32:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105b35:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105b38:	89 cb                	mov    %ecx,%ebx
f0105b3a:	eb 4d                	jmp    f0105b89 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105b3c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105b40:	74 1b                	je     f0105b5d <vprintfmt+0x213>
f0105b42:	0f be c0             	movsbl %al,%eax
f0105b45:	83 e8 20             	sub    $0x20,%eax
f0105b48:	83 f8 5e             	cmp    $0x5e,%eax
f0105b4b:	76 10                	jbe    f0105b5d <vprintfmt+0x213>
					putch('?', putdat);
f0105b4d:	83 ec 08             	sub    $0x8,%esp
f0105b50:	ff 75 0c             	pushl  0xc(%ebp)
f0105b53:	6a 3f                	push   $0x3f
f0105b55:	ff 55 08             	call   *0x8(%ebp)
f0105b58:	83 c4 10             	add    $0x10,%esp
f0105b5b:	eb 0d                	jmp    f0105b6a <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0105b5d:	83 ec 08             	sub    $0x8,%esp
f0105b60:	ff 75 0c             	pushl  0xc(%ebp)
f0105b63:	52                   	push   %edx
f0105b64:	ff 55 08             	call   *0x8(%ebp)
f0105b67:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105b6a:	83 eb 01             	sub    $0x1,%ebx
f0105b6d:	eb 1a                	jmp    f0105b89 <vprintfmt+0x23f>
f0105b6f:	89 75 08             	mov    %esi,0x8(%ebp)
f0105b72:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105b75:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105b78:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105b7b:	eb 0c                	jmp    f0105b89 <vprintfmt+0x23f>
f0105b7d:	89 75 08             	mov    %esi,0x8(%ebp)
f0105b80:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105b83:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105b86:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105b89:	83 c7 01             	add    $0x1,%edi
f0105b8c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105b90:	0f be d0             	movsbl %al,%edx
f0105b93:	85 d2                	test   %edx,%edx
f0105b95:	74 23                	je     f0105bba <vprintfmt+0x270>
f0105b97:	85 f6                	test   %esi,%esi
f0105b99:	78 a1                	js     f0105b3c <vprintfmt+0x1f2>
f0105b9b:	83 ee 01             	sub    $0x1,%esi
f0105b9e:	79 9c                	jns    f0105b3c <vprintfmt+0x1f2>
f0105ba0:	89 df                	mov    %ebx,%edi
f0105ba2:	8b 75 08             	mov    0x8(%ebp),%esi
f0105ba5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105ba8:	eb 18                	jmp    f0105bc2 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0105baa:	83 ec 08             	sub    $0x8,%esp
f0105bad:	53                   	push   %ebx
f0105bae:	6a 20                	push   $0x20
f0105bb0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105bb2:	83 ef 01             	sub    $0x1,%edi
f0105bb5:	83 c4 10             	add    $0x10,%esp
f0105bb8:	eb 08                	jmp    f0105bc2 <vprintfmt+0x278>
f0105bba:	89 df                	mov    %ebx,%edi
f0105bbc:	8b 75 08             	mov    0x8(%ebp),%esi
f0105bbf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105bc2:	85 ff                	test   %edi,%edi
f0105bc4:	7f e4                	jg     f0105baa <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105bc6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105bc9:	e9 a2 fd ff ff       	jmp    f0105970 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105bce:	83 fa 01             	cmp    $0x1,%edx
f0105bd1:	7e 16                	jle    f0105be9 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0105bd3:	8b 45 14             	mov    0x14(%ebp),%eax
f0105bd6:	8d 50 08             	lea    0x8(%eax),%edx
f0105bd9:	89 55 14             	mov    %edx,0x14(%ebp)
f0105bdc:	8b 50 04             	mov    0x4(%eax),%edx
f0105bdf:	8b 00                	mov    (%eax),%eax
f0105be1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105be4:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105be7:	eb 32                	jmp    f0105c1b <vprintfmt+0x2d1>
	else if (lflag)
f0105be9:	85 d2                	test   %edx,%edx
f0105beb:	74 18                	je     f0105c05 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0105bed:	8b 45 14             	mov    0x14(%ebp),%eax
f0105bf0:	8d 50 04             	lea    0x4(%eax),%edx
f0105bf3:	89 55 14             	mov    %edx,0x14(%ebp)
f0105bf6:	8b 00                	mov    (%eax),%eax
f0105bf8:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105bfb:	89 c1                	mov    %eax,%ecx
f0105bfd:	c1 f9 1f             	sar    $0x1f,%ecx
f0105c00:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105c03:	eb 16                	jmp    f0105c1b <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0105c05:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c08:	8d 50 04             	lea    0x4(%eax),%edx
f0105c0b:	89 55 14             	mov    %edx,0x14(%ebp)
f0105c0e:	8b 00                	mov    (%eax),%eax
f0105c10:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105c13:	89 c1                	mov    %eax,%ecx
f0105c15:	c1 f9 1f             	sar    $0x1f,%ecx
f0105c18:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105c1b:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105c1e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105c21:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0105c26:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105c2a:	79 74                	jns    f0105ca0 <vprintfmt+0x356>
				putch('-', putdat);
f0105c2c:	83 ec 08             	sub    $0x8,%esp
f0105c2f:	53                   	push   %ebx
f0105c30:	6a 2d                	push   $0x2d
f0105c32:	ff d6                	call   *%esi
				num = -(long long) num;
f0105c34:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105c37:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105c3a:	f7 d8                	neg    %eax
f0105c3c:	83 d2 00             	adc    $0x0,%edx
f0105c3f:	f7 da                	neg    %edx
f0105c41:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0105c44:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0105c49:	eb 55                	jmp    f0105ca0 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0105c4b:	8d 45 14             	lea    0x14(%ebp),%eax
f0105c4e:	e8 83 fc ff ff       	call   f01058d6 <getuint>
			base = 10;
f0105c53:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0105c58:	eb 46                	jmp    f0105ca0 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f0105c5a:	8d 45 14             	lea    0x14(%ebp),%eax
f0105c5d:	e8 74 fc ff ff       	call   f01058d6 <getuint>
			base = 8;
f0105c62:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0105c67:	eb 37                	jmp    f0105ca0 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f0105c69:	83 ec 08             	sub    $0x8,%esp
f0105c6c:	53                   	push   %ebx
f0105c6d:	6a 30                	push   $0x30
f0105c6f:	ff d6                	call   *%esi
			putch('x', putdat);
f0105c71:	83 c4 08             	add    $0x8,%esp
f0105c74:	53                   	push   %ebx
f0105c75:	6a 78                	push   $0x78
f0105c77:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0105c79:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c7c:	8d 50 04             	lea    0x4(%eax),%edx
f0105c7f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0105c82:	8b 00                	mov    (%eax),%eax
f0105c84:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0105c89:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0105c8c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0105c91:	eb 0d                	jmp    f0105ca0 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105c93:	8d 45 14             	lea    0x14(%ebp),%eax
f0105c96:	e8 3b fc ff ff       	call   f01058d6 <getuint>
			base = 16;
f0105c9b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105ca0:	83 ec 0c             	sub    $0xc,%esp
f0105ca3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0105ca7:	57                   	push   %edi
f0105ca8:	ff 75 e0             	pushl  -0x20(%ebp)
f0105cab:	51                   	push   %ecx
f0105cac:	52                   	push   %edx
f0105cad:	50                   	push   %eax
f0105cae:	89 da                	mov    %ebx,%edx
f0105cb0:	89 f0                	mov    %esi,%eax
f0105cb2:	e8 70 fb ff ff       	call   f0105827 <printnum>
			break;
f0105cb7:	83 c4 20             	add    $0x20,%esp
f0105cba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105cbd:	e9 ae fc ff ff       	jmp    f0105970 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105cc2:	83 ec 08             	sub    $0x8,%esp
f0105cc5:	53                   	push   %ebx
f0105cc6:	51                   	push   %ecx
f0105cc7:	ff d6                	call   *%esi
			break;
f0105cc9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105ccc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0105ccf:	e9 9c fc ff ff       	jmp    f0105970 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105cd4:	83 ec 08             	sub    $0x8,%esp
f0105cd7:	53                   	push   %ebx
f0105cd8:	6a 25                	push   $0x25
f0105cda:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105cdc:	83 c4 10             	add    $0x10,%esp
f0105cdf:	eb 03                	jmp    f0105ce4 <vprintfmt+0x39a>
f0105ce1:	83 ef 01             	sub    $0x1,%edi
f0105ce4:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0105ce8:	75 f7                	jne    f0105ce1 <vprintfmt+0x397>
f0105cea:	e9 81 fc ff ff       	jmp    f0105970 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0105cef:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105cf2:	5b                   	pop    %ebx
f0105cf3:	5e                   	pop    %esi
f0105cf4:	5f                   	pop    %edi
f0105cf5:	5d                   	pop    %ebp
f0105cf6:	c3                   	ret    

f0105cf7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105cf7:	55                   	push   %ebp
f0105cf8:	89 e5                	mov    %esp,%ebp
f0105cfa:	83 ec 18             	sub    $0x18,%esp
f0105cfd:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d00:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105d03:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105d06:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105d0a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105d0d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105d14:	85 c0                	test   %eax,%eax
f0105d16:	74 26                	je     f0105d3e <vsnprintf+0x47>
f0105d18:	85 d2                	test   %edx,%edx
f0105d1a:	7e 22                	jle    f0105d3e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105d1c:	ff 75 14             	pushl  0x14(%ebp)
f0105d1f:	ff 75 10             	pushl  0x10(%ebp)
f0105d22:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105d25:	50                   	push   %eax
f0105d26:	68 10 59 10 f0       	push   $0xf0105910
f0105d2b:	e8 1a fc ff ff       	call   f010594a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105d30:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105d33:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105d36:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105d39:	83 c4 10             	add    $0x10,%esp
f0105d3c:	eb 05                	jmp    f0105d43 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105d3e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105d43:	c9                   	leave  
f0105d44:	c3                   	ret    

f0105d45 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105d45:	55                   	push   %ebp
f0105d46:	89 e5                	mov    %esp,%ebp
f0105d48:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105d4b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105d4e:	50                   	push   %eax
f0105d4f:	ff 75 10             	pushl  0x10(%ebp)
f0105d52:	ff 75 0c             	pushl  0xc(%ebp)
f0105d55:	ff 75 08             	pushl  0x8(%ebp)
f0105d58:	e8 9a ff ff ff       	call   f0105cf7 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105d5d:	c9                   	leave  
f0105d5e:	c3                   	ret    

f0105d5f <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105d5f:	55                   	push   %ebp
f0105d60:	89 e5                	mov    %esp,%ebp
f0105d62:	57                   	push   %edi
f0105d63:	56                   	push   %esi
f0105d64:	53                   	push   %ebx
f0105d65:	83 ec 0c             	sub    $0xc,%esp
f0105d68:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0105d6b:	85 c0                	test   %eax,%eax
f0105d6d:	74 11                	je     f0105d80 <readline+0x21>
		cprintf("%s", prompt);
f0105d6f:	83 ec 08             	sub    $0x8,%esp
f0105d72:	50                   	push   %eax
f0105d73:	68 51 7d 10 f0       	push   $0xf0107d51
f0105d78:	e8 e1 dd ff ff       	call   f0103b5e <cprintf>
f0105d7d:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0105d80:	83 ec 0c             	sub    $0xc,%esp
f0105d83:	6a 00                	push   $0x0
f0105d85:	e8 ed a9 ff ff       	call   f0100777 <iscons>
f0105d8a:	89 c7                	mov    %eax,%edi
f0105d8c:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0105d8f:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105d94:	e8 cd a9 ff ff       	call   f0100766 <getchar>
f0105d99:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105d9b:	85 c0                	test   %eax,%eax
f0105d9d:	79 18                	jns    f0105db7 <readline+0x58>
			cprintf("read error: %e\n", c);
f0105d9f:	83 ec 08             	sub    $0x8,%esp
f0105da2:	50                   	push   %eax
f0105da3:	68 a8 88 10 f0       	push   $0xf01088a8
f0105da8:	e8 b1 dd ff ff       	call   f0103b5e <cprintf>
			return NULL;
f0105dad:	83 c4 10             	add    $0x10,%esp
f0105db0:	b8 00 00 00 00       	mov    $0x0,%eax
f0105db5:	eb 79                	jmp    f0105e30 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105db7:	83 f8 08             	cmp    $0x8,%eax
f0105dba:	0f 94 c2             	sete   %dl
f0105dbd:	83 f8 7f             	cmp    $0x7f,%eax
f0105dc0:	0f 94 c0             	sete   %al
f0105dc3:	08 c2                	or     %al,%dl
f0105dc5:	74 1a                	je     f0105de1 <readline+0x82>
f0105dc7:	85 f6                	test   %esi,%esi
f0105dc9:	7e 16                	jle    f0105de1 <readline+0x82>
			if (echoing)
f0105dcb:	85 ff                	test   %edi,%edi
f0105dcd:	74 0d                	je     f0105ddc <readline+0x7d>
				cputchar('\b');
f0105dcf:	83 ec 0c             	sub    $0xc,%esp
f0105dd2:	6a 08                	push   $0x8
f0105dd4:	e8 7d a9 ff ff       	call   f0100756 <cputchar>
f0105dd9:	83 c4 10             	add    $0x10,%esp
			i--;
f0105ddc:	83 ee 01             	sub    $0x1,%esi
f0105ddf:	eb b3                	jmp    f0105d94 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105de1:	83 fb 1f             	cmp    $0x1f,%ebx
f0105de4:	7e 23                	jle    f0105e09 <readline+0xaa>
f0105de6:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105dec:	7f 1b                	jg     f0105e09 <readline+0xaa>
			if (echoing)
f0105dee:	85 ff                	test   %edi,%edi
f0105df0:	74 0c                	je     f0105dfe <readline+0x9f>
				cputchar(c);
f0105df2:	83 ec 0c             	sub    $0xc,%esp
f0105df5:	53                   	push   %ebx
f0105df6:	e8 5b a9 ff ff       	call   f0100756 <cputchar>
f0105dfb:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0105dfe:	88 9e 80 1a 23 f0    	mov    %bl,-0xfdce580(%esi)
f0105e04:	8d 76 01             	lea    0x1(%esi),%esi
f0105e07:	eb 8b                	jmp    f0105d94 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0105e09:	83 fb 0a             	cmp    $0xa,%ebx
f0105e0c:	74 05                	je     f0105e13 <readline+0xb4>
f0105e0e:	83 fb 0d             	cmp    $0xd,%ebx
f0105e11:	75 81                	jne    f0105d94 <readline+0x35>
			if (echoing)
f0105e13:	85 ff                	test   %edi,%edi
f0105e15:	74 0d                	je     f0105e24 <readline+0xc5>
				cputchar('\n');
f0105e17:	83 ec 0c             	sub    $0xc,%esp
f0105e1a:	6a 0a                	push   $0xa
f0105e1c:	e8 35 a9 ff ff       	call   f0100756 <cputchar>
f0105e21:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0105e24:	c6 86 80 1a 23 f0 00 	movb   $0x0,-0xfdce580(%esi)
			return buf;
f0105e2b:	b8 80 1a 23 f0       	mov    $0xf0231a80,%eax
		}
	}
}
f0105e30:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105e33:	5b                   	pop    %ebx
f0105e34:	5e                   	pop    %esi
f0105e35:	5f                   	pop    %edi
f0105e36:	5d                   	pop    %ebp
f0105e37:	c3                   	ret    

f0105e38 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105e38:	55                   	push   %ebp
f0105e39:	89 e5                	mov    %esp,%ebp
f0105e3b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105e3e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105e43:	eb 03                	jmp    f0105e48 <strlen+0x10>
		n++;
f0105e45:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105e48:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105e4c:	75 f7                	jne    f0105e45 <strlen+0xd>
		n++;
	return n;
}
f0105e4e:	5d                   	pop    %ebp
f0105e4f:	c3                   	ret    

f0105e50 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105e50:	55                   	push   %ebp
f0105e51:	89 e5                	mov    %esp,%ebp
f0105e53:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105e56:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105e59:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e5e:	eb 03                	jmp    f0105e63 <strnlen+0x13>
		n++;
f0105e60:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105e63:	39 c2                	cmp    %eax,%edx
f0105e65:	74 08                	je     f0105e6f <strnlen+0x1f>
f0105e67:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0105e6b:	75 f3                	jne    f0105e60 <strnlen+0x10>
f0105e6d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0105e6f:	5d                   	pop    %ebp
f0105e70:	c3                   	ret    

f0105e71 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105e71:	55                   	push   %ebp
f0105e72:	89 e5                	mov    %esp,%ebp
f0105e74:	53                   	push   %ebx
f0105e75:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105e7b:	89 c2                	mov    %eax,%edx
f0105e7d:	83 c2 01             	add    $0x1,%edx
f0105e80:	83 c1 01             	add    $0x1,%ecx
f0105e83:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105e87:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105e8a:	84 db                	test   %bl,%bl
f0105e8c:	75 ef                	jne    f0105e7d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105e8e:	5b                   	pop    %ebx
f0105e8f:	5d                   	pop    %ebp
f0105e90:	c3                   	ret    

f0105e91 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105e91:	55                   	push   %ebp
f0105e92:	89 e5                	mov    %esp,%ebp
f0105e94:	53                   	push   %ebx
f0105e95:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105e98:	53                   	push   %ebx
f0105e99:	e8 9a ff ff ff       	call   f0105e38 <strlen>
f0105e9e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0105ea1:	ff 75 0c             	pushl  0xc(%ebp)
f0105ea4:	01 d8                	add    %ebx,%eax
f0105ea6:	50                   	push   %eax
f0105ea7:	e8 c5 ff ff ff       	call   f0105e71 <strcpy>
	return dst;
}
f0105eac:	89 d8                	mov    %ebx,%eax
f0105eae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105eb1:	c9                   	leave  
f0105eb2:	c3                   	ret    

f0105eb3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105eb3:	55                   	push   %ebp
f0105eb4:	89 e5                	mov    %esp,%ebp
f0105eb6:	56                   	push   %esi
f0105eb7:	53                   	push   %ebx
f0105eb8:	8b 75 08             	mov    0x8(%ebp),%esi
f0105ebb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105ebe:	89 f3                	mov    %esi,%ebx
f0105ec0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105ec3:	89 f2                	mov    %esi,%edx
f0105ec5:	eb 0f                	jmp    f0105ed6 <strncpy+0x23>
		*dst++ = *src;
f0105ec7:	83 c2 01             	add    $0x1,%edx
f0105eca:	0f b6 01             	movzbl (%ecx),%eax
f0105ecd:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105ed0:	80 39 01             	cmpb   $0x1,(%ecx)
f0105ed3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105ed6:	39 da                	cmp    %ebx,%edx
f0105ed8:	75 ed                	jne    f0105ec7 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105eda:	89 f0                	mov    %esi,%eax
f0105edc:	5b                   	pop    %ebx
f0105edd:	5e                   	pop    %esi
f0105ede:	5d                   	pop    %ebp
f0105edf:	c3                   	ret    

f0105ee0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105ee0:	55                   	push   %ebp
f0105ee1:	89 e5                	mov    %esp,%ebp
f0105ee3:	56                   	push   %esi
f0105ee4:	53                   	push   %ebx
f0105ee5:	8b 75 08             	mov    0x8(%ebp),%esi
f0105ee8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105eeb:	8b 55 10             	mov    0x10(%ebp),%edx
f0105eee:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105ef0:	85 d2                	test   %edx,%edx
f0105ef2:	74 21                	je     f0105f15 <strlcpy+0x35>
f0105ef4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105ef8:	89 f2                	mov    %esi,%edx
f0105efa:	eb 09                	jmp    f0105f05 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105efc:	83 c2 01             	add    $0x1,%edx
f0105eff:	83 c1 01             	add    $0x1,%ecx
f0105f02:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105f05:	39 c2                	cmp    %eax,%edx
f0105f07:	74 09                	je     f0105f12 <strlcpy+0x32>
f0105f09:	0f b6 19             	movzbl (%ecx),%ebx
f0105f0c:	84 db                	test   %bl,%bl
f0105f0e:	75 ec                	jne    f0105efc <strlcpy+0x1c>
f0105f10:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0105f12:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105f15:	29 f0                	sub    %esi,%eax
}
f0105f17:	5b                   	pop    %ebx
f0105f18:	5e                   	pop    %esi
f0105f19:	5d                   	pop    %ebp
f0105f1a:	c3                   	ret    

f0105f1b <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105f1b:	55                   	push   %ebp
f0105f1c:	89 e5                	mov    %esp,%ebp
f0105f1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105f21:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105f24:	eb 06                	jmp    f0105f2c <strcmp+0x11>
		p++, q++;
f0105f26:	83 c1 01             	add    $0x1,%ecx
f0105f29:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105f2c:	0f b6 01             	movzbl (%ecx),%eax
f0105f2f:	84 c0                	test   %al,%al
f0105f31:	74 04                	je     f0105f37 <strcmp+0x1c>
f0105f33:	3a 02                	cmp    (%edx),%al
f0105f35:	74 ef                	je     f0105f26 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105f37:	0f b6 c0             	movzbl %al,%eax
f0105f3a:	0f b6 12             	movzbl (%edx),%edx
f0105f3d:	29 d0                	sub    %edx,%eax
}
f0105f3f:	5d                   	pop    %ebp
f0105f40:	c3                   	ret    

f0105f41 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105f41:	55                   	push   %ebp
f0105f42:	89 e5                	mov    %esp,%ebp
f0105f44:	53                   	push   %ebx
f0105f45:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f48:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105f4b:	89 c3                	mov    %eax,%ebx
f0105f4d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105f50:	eb 06                	jmp    f0105f58 <strncmp+0x17>
		n--, p++, q++;
f0105f52:	83 c0 01             	add    $0x1,%eax
f0105f55:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105f58:	39 d8                	cmp    %ebx,%eax
f0105f5a:	74 15                	je     f0105f71 <strncmp+0x30>
f0105f5c:	0f b6 08             	movzbl (%eax),%ecx
f0105f5f:	84 c9                	test   %cl,%cl
f0105f61:	74 04                	je     f0105f67 <strncmp+0x26>
f0105f63:	3a 0a                	cmp    (%edx),%cl
f0105f65:	74 eb                	je     f0105f52 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105f67:	0f b6 00             	movzbl (%eax),%eax
f0105f6a:	0f b6 12             	movzbl (%edx),%edx
f0105f6d:	29 d0                	sub    %edx,%eax
f0105f6f:	eb 05                	jmp    f0105f76 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105f71:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105f76:	5b                   	pop    %ebx
f0105f77:	5d                   	pop    %ebp
f0105f78:	c3                   	ret    

f0105f79 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105f79:	55                   	push   %ebp
f0105f7a:	89 e5                	mov    %esp,%ebp
f0105f7c:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f7f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105f83:	eb 07                	jmp    f0105f8c <strchr+0x13>
		if (*s == c)
f0105f85:	38 ca                	cmp    %cl,%dl
f0105f87:	74 0f                	je     f0105f98 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105f89:	83 c0 01             	add    $0x1,%eax
f0105f8c:	0f b6 10             	movzbl (%eax),%edx
f0105f8f:	84 d2                	test   %dl,%dl
f0105f91:	75 f2                	jne    f0105f85 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0105f93:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105f98:	5d                   	pop    %ebp
f0105f99:	c3                   	ret    

f0105f9a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105f9a:	55                   	push   %ebp
f0105f9b:	89 e5                	mov    %esp,%ebp
f0105f9d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fa0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105fa4:	eb 03                	jmp    f0105fa9 <strfind+0xf>
f0105fa6:	83 c0 01             	add    $0x1,%eax
f0105fa9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105fac:	38 ca                	cmp    %cl,%dl
f0105fae:	74 04                	je     f0105fb4 <strfind+0x1a>
f0105fb0:	84 d2                	test   %dl,%dl
f0105fb2:	75 f2                	jne    f0105fa6 <strfind+0xc>
			break;
	return (char *) s;
}
f0105fb4:	5d                   	pop    %ebp
f0105fb5:	c3                   	ret    

f0105fb6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105fb6:	55                   	push   %ebp
f0105fb7:	89 e5                	mov    %esp,%ebp
f0105fb9:	57                   	push   %edi
f0105fba:	56                   	push   %esi
f0105fbb:	53                   	push   %ebx
f0105fbc:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105fbf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105fc2:	85 c9                	test   %ecx,%ecx
f0105fc4:	74 36                	je     f0105ffc <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105fc6:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105fcc:	75 28                	jne    f0105ff6 <memset+0x40>
f0105fce:	f6 c1 03             	test   $0x3,%cl
f0105fd1:	75 23                	jne    f0105ff6 <memset+0x40>
		c &= 0xFF;
f0105fd3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105fd7:	89 d3                	mov    %edx,%ebx
f0105fd9:	c1 e3 08             	shl    $0x8,%ebx
f0105fdc:	89 d6                	mov    %edx,%esi
f0105fde:	c1 e6 18             	shl    $0x18,%esi
f0105fe1:	89 d0                	mov    %edx,%eax
f0105fe3:	c1 e0 10             	shl    $0x10,%eax
f0105fe6:	09 f0                	or     %esi,%eax
f0105fe8:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0105fea:	89 d8                	mov    %ebx,%eax
f0105fec:	09 d0                	or     %edx,%eax
f0105fee:	c1 e9 02             	shr    $0x2,%ecx
f0105ff1:	fc                   	cld    
f0105ff2:	f3 ab                	rep stos %eax,%es:(%edi)
f0105ff4:	eb 06                	jmp    f0105ffc <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105ff6:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105ff9:	fc                   	cld    
f0105ffa:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105ffc:	89 f8                	mov    %edi,%eax
f0105ffe:	5b                   	pop    %ebx
f0105fff:	5e                   	pop    %esi
f0106000:	5f                   	pop    %edi
f0106001:	5d                   	pop    %ebp
f0106002:	c3                   	ret    

f0106003 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0106003:	55                   	push   %ebp
f0106004:	89 e5                	mov    %esp,%ebp
f0106006:	57                   	push   %edi
f0106007:	56                   	push   %esi
f0106008:	8b 45 08             	mov    0x8(%ebp),%eax
f010600b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010600e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0106011:	39 c6                	cmp    %eax,%esi
f0106013:	73 35                	jae    f010604a <memmove+0x47>
f0106015:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0106018:	39 d0                	cmp    %edx,%eax
f010601a:	73 2e                	jae    f010604a <memmove+0x47>
		s += n;
		d += n;
f010601c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010601f:	89 d6                	mov    %edx,%esi
f0106021:	09 fe                	or     %edi,%esi
f0106023:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0106029:	75 13                	jne    f010603e <memmove+0x3b>
f010602b:	f6 c1 03             	test   $0x3,%cl
f010602e:	75 0e                	jne    f010603e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0106030:	83 ef 04             	sub    $0x4,%edi
f0106033:	8d 72 fc             	lea    -0x4(%edx),%esi
f0106036:	c1 e9 02             	shr    $0x2,%ecx
f0106039:	fd                   	std    
f010603a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010603c:	eb 09                	jmp    f0106047 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010603e:	83 ef 01             	sub    $0x1,%edi
f0106041:	8d 72 ff             	lea    -0x1(%edx),%esi
f0106044:	fd                   	std    
f0106045:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0106047:	fc                   	cld    
f0106048:	eb 1d                	jmp    f0106067 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010604a:	89 f2                	mov    %esi,%edx
f010604c:	09 c2                	or     %eax,%edx
f010604e:	f6 c2 03             	test   $0x3,%dl
f0106051:	75 0f                	jne    f0106062 <memmove+0x5f>
f0106053:	f6 c1 03             	test   $0x3,%cl
f0106056:	75 0a                	jne    f0106062 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0106058:	c1 e9 02             	shr    $0x2,%ecx
f010605b:	89 c7                	mov    %eax,%edi
f010605d:	fc                   	cld    
f010605e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0106060:	eb 05                	jmp    f0106067 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0106062:	89 c7                	mov    %eax,%edi
f0106064:	fc                   	cld    
f0106065:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0106067:	5e                   	pop    %esi
f0106068:	5f                   	pop    %edi
f0106069:	5d                   	pop    %ebp
f010606a:	c3                   	ret    

f010606b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010606b:	55                   	push   %ebp
f010606c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010606e:	ff 75 10             	pushl  0x10(%ebp)
f0106071:	ff 75 0c             	pushl  0xc(%ebp)
f0106074:	ff 75 08             	pushl  0x8(%ebp)
f0106077:	e8 87 ff ff ff       	call   f0106003 <memmove>
}
f010607c:	c9                   	leave  
f010607d:	c3                   	ret    

f010607e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010607e:	55                   	push   %ebp
f010607f:	89 e5                	mov    %esp,%ebp
f0106081:	56                   	push   %esi
f0106082:	53                   	push   %ebx
f0106083:	8b 45 08             	mov    0x8(%ebp),%eax
f0106086:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106089:	89 c6                	mov    %eax,%esi
f010608b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010608e:	eb 1a                	jmp    f01060aa <memcmp+0x2c>
		if (*s1 != *s2)
f0106090:	0f b6 08             	movzbl (%eax),%ecx
f0106093:	0f b6 1a             	movzbl (%edx),%ebx
f0106096:	38 d9                	cmp    %bl,%cl
f0106098:	74 0a                	je     f01060a4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f010609a:	0f b6 c1             	movzbl %cl,%eax
f010609d:	0f b6 db             	movzbl %bl,%ebx
f01060a0:	29 d8                	sub    %ebx,%eax
f01060a2:	eb 0f                	jmp    f01060b3 <memcmp+0x35>
		s1++, s2++;
f01060a4:	83 c0 01             	add    $0x1,%eax
f01060a7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01060aa:	39 f0                	cmp    %esi,%eax
f01060ac:	75 e2                	jne    f0106090 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01060ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01060b3:	5b                   	pop    %ebx
f01060b4:	5e                   	pop    %esi
f01060b5:	5d                   	pop    %ebp
f01060b6:	c3                   	ret    

f01060b7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01060b7:	55                   	push   %ebp
f01060b8:	89 e5                	mov    %esp,%ebp
f01060ba:	53                   	push   %ebx
f01060bb:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01060be:	89 c1                	mov    %eax,%ecx
f01060c0:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f01060c3:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01060c7:	eb 0a                	jmp    f01060d3 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f01060c9:	0f b6 10             	movzbl (%eax),%edx
f01060cc:	39 da                	cmp    %ebx,%edx
f01060ce:	74 07                	je     f01060d7 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01060d0:	83 c0 01             	add    $0x1,%eax
f01060d3:	39 c8                	cmp    %ecx,%eax
f01060d5:	72 f2                	jb     f01060c9 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01060d7:	5b                   	pop    %ebx
f01060d8:	5d                   	pop    %ebp
f01060d9:	c3                   	ret    

f01060da <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01060da:	55                   	push   %ebp
f01060db:	89 e5                	mov    %esp,%ebp
f01060dd:	57                   	push   %edi
f01060de:	56                   	push   %esi
f01060df:	53                   	push   %ebx
f01060e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01060e3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01060e6:	eb 03                	jmp    f01060eb <strtol+0x11>
		s++;
f01060e8:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01060eb:	0f b6 01             	movzbl (%ecx),%eax
f01060ee:	3c 20                	cmp    $0x20,%al
f01060f0:	74 f6                	je     f01060e8 <strtol+0xe>
f01060f2:	3c 09                	cmp    $0x9,%al
f01060f4:	74 f2                	je     f01060e8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01060f6:	3c 2b                	cmp    $0x2b,%al
f01060f8:	75 0a                	jne    f0106104 <strtol+0x2a>
		s++;
f01060fa:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01060fd:	bf 00 00 00 00       	mov    $0x0,%edi
f0106102:	eb 11                	jmp    f0106115 <strtol+0x3b>
f0106104:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0106109:	3c 2d                	cmp    $0x2d,%al
f010610b:	75 08                	jne    f0106115 <strtol+0x3b>
		s++, neg = 1;
f010610d:	83 c1 01             	add    $0x1,%ecx
f0106110:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0106115:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010611b:	75 15                	jne    f0106132 <strtol+0x58>
f010611d:	80 39 30             	cmpb   $0x30,(%ecx)
f0106120:	75 10                	jne    f0106132 <strtol+0x58>
f0106122:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0106126:	75 7c                	jne    f01061a4 <strtol+0xca>
		s += 2, base = 16;
f0106128:	83 c1 02             	add    $0x2,%ecx
f010612b:	bb 10 00 00 00       	mov    $0x10,%ebx
f0106130:	eb 16                	jmp    f0106148 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0106132:	85 db                	test   %ebx,%ebx
f0106134:	75 12                	jne    f0106148 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0106136:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010613b:	80 39 30             	cmpb   $0x30,(%ecx)
f010613e:	75 08                	jne    f0106148 <strtol+0x6e>
		s++, base = 8;
f0106140:	83 c1 01             	add    $0x1,%ecx
f0106143:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0106148:	b8 00 00 00 00       	mov    $0x0,%eax
f010614d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0106150:	0f b6 11             	movzbl (%ecx),%edx
f0106153:	8d 72 d0             	lea    -0x30(%edx),%esi
f0106156:	89 f3                	mov    %esi,%ebx
f0106158:	80 fb 09             	cmp    $0x9,%bl
f010615b:	77 08                	ja     f0106165 <strtol+0x8b>
			dig = *s - '0';
f010615d:	0f be d2             	movsbl %dl,%edx
f0106160:	83 ea 30             	sub    $0x30,%edx
f0106163:	eb 22                	jmp    f0106187 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0106165:	8d 72 9f             	lea    -0x61(%edx),%esi
f0106168:	89 f3                	mov    %esi,%ebx
f010616a:	80 fb 19             	cmp    $0x19,%bl
f010616d:	77 08                	ja     f0106177 <strtol+0x9d>
			dig = *s - 'a' + 10;
f010616f:	0f be d2             	movsbl %dl,%edx
f0106172:	83 ea 57             	sub    $0x57,%edx
f0106175:	eb 10                	jmp    f0106187 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0106177:	8d 72 bf             	lea    -0x41(%edx),%esi
f010617a:	89 f3                	mov    %esi,%ebx
f010617c:	80 fb 19             	cmp    $0x19,%bl
f010617f:	77 16                	ja     f0106197 <strtol+0xbd>
			dig = *s - 'A' + 10;
f0106181:	0f be d2             	movsbl %dl,%edx
f0106184:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0106187:	3b 55 10             	cmp    0x10(%ebp),%edx
f010618a:	7d 0b                	jge    f0106197 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f010618c:	83 c1 01             	add    $0x1,%ecx
f010618f:	0f af 45 10          	imul   0x10(%ebp),%eax
f0106193:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0106195:	eb b9                	jmp    f0106150 <strtol+0x76>

	if (endptr)
f0106197:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010619b:	74 0d                	je     f01061aa <strtol+0xd0>
		*endptr = (char *) s;
f010619d:	8b 75 0c             	mov    0xc(%ebp),%esi
f01061a0:	89 0e                	mov    %ecx,(%esi)
f01061a2:	eb 06                	jmp    f01061aa <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01061a4:	85 db                	test   %ebx,%ebx
f01061a6:	74 98                	je     f0106140 <strtol+0x66>
f01061a8:	eb 9e                	jmp    f0106148 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01061aa:	89 c2                	mov    %eax,%edx
f01061ac:	f7 da                	neg    %edx
f01061ae:	85 ff                	test   %edi,%edi
f01061b0:	0f 45 c2             	cmovne %edx,%eax
}
f01061b3:	5b                   	pop    %ebx
f01061b4:	5e                   	pop    %esi
f01061b5:	5f                   	pop    %edi
f01061b6:	5d                   	pop    %ebp
f01061b7:	c3                   	ret    

f01061b8 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01061b8:	fa                   	cli    

	xorw    %ax, %ax
f01061b9:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01061bb:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01061bd:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01061bf:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01061c1:	0f 01 16             	lgdtl  (%esi)
f01061c4:	74 70                	je     f0106236 <mpsearch1+0x3>
	movl    %cr0, %eax
f01061c6:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01061c9:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01061cd:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01061d0:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f01061d6:	08 00                	or     %al,(%eax)

f01061d8 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f01061d8:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f01061dc:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01061de:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01061e0:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f01061e2:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f01061e6:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f01061e8:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f01061ea:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl    %eax, %cr3
f01061ef:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f01061f2:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f01061f5:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f01061fa:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f01061fd:	8b 25 84 1e 23 f0    	mov    0xf0231e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0106203:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0106208:	b8 b3 01 10 f0       	mov    $0xf01001b3,%eax
	call    *%eax
f010620d:	ff d0                	call   *%eax

f010620f <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f010620f:	eb fe                	jmp    f010620f <spin>
f0106211:	8d 76 00             	lea    0x0(%esi),%esi

f0106214 <gdt>:
	...
f010621c:	ff                   	(bad)  
f010621d:	ff 00                	incl   (%eax)
f010621f:	00 00                	add    %al,(%eax)
f0106221:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0106228:	00                   	.byte 0x0
f0106229:	92                   	xchg   %eax,%edx
f010622a:	cf                   	iret   
	...

f010622c <gdtdesc>:
f010622c:	17                   	pop    %ss
f010622d:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0106232 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0106232:	90                   	nop

f0106233 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0106233:	55                   	push   %ebp
f0106234:	89 e5                	mov    %esp,%ebp
f0106236:	57                   	push   %edi
f0106237:	56                   	push   %esi
f0106238:	53                   	push   %ebx
f0106239:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010623c:	8b 0d 88 1e 23 f0    	mov    0xf0231e88,%ecx
f0106242:	89 c3                	mov    %eax,%ebx
f0106244:	c1 eb 0c             	shr    $0xc,%ebx
f0106247:	39 cb                	cmp    %ecx,%ebx
f0106249:	72 12                	jb     f010625d <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010624b:	50                   	push   %eax
f010624c:	68 84 6c 10 f0       	push   $0xf0106c84
f0106251:	6a 57                	push   $0x57
f0106253:	68 45 8a 10 f0       	push   $0xf0108a45
f0106258:	e8 e3 9d ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010625d:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0106263:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106265:	89 c2                	mov    %eax,%edx
f0106267:	c1 ea 0c             	shr    $0xc,%edx
f010626a:	39 ca                	cmp    %ecx,%edx
f010626c:	72 12                	jb     f0106280 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010626e:	50                   	push   %eax
f010626f:	68 84 6c 10 f0       	push   $0xf0106c84
f0106274:	6a 57                	push   $0x57
f0106276:	68 45 8a 10 f0       	push   $0xf0108a45
f010627b:	e8 c0 9d ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106280:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f0106286:	eb 2f                	jmp    f01062b7 <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106288:	83 ec 04             	sub    $0x4,%esp
f010628b:	6a 04                	push   $0x4
f010628d:	68 55 8a 10 f0       	push   $0xf0108a55
f0106292:	53                   	push   %ebx
f0106293:	e8 e6 fd ff ff       	call   f010607e <memcmp>
f0106298:	83 c4 10             	add    $0x10,%esp
f010629b:	85 c0                	test   %eax,%eax
f010629d:	75 15                	jne    f01062b4 <mpsearch1+0x81>
f010629f:	89 da                	mov    %ebx,%edx
f01062a1:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f01062a4:	0f b6 0a             	movzbl (%edx),%ecx
f01062a7:	01 c8                	add    %ecx,%eax
f01062a9:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01062ac:	39 d7                	cmp    %edx,%edi
f01062ae:	75 f4                	jne    f01062a4 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01062b0:	84 c0                	test   %al,%al
f01062b2:	74 0e                	je     f01062c2 <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f01062b4:	83 c3 10             	add    $0x10,%ebx
f01062b7:	39 f3                	cmp    %esi,%ebx
f01062b9:	72 cd                	jb     f0106288 <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f01062bb:	b8 00 00 00 00       	mov    $0x0,%eax
f01062c0:	eb 02                	jmp    f01062c4 <mpsearch1+0x91>
f01062c2:	89 d8                	mov    %ebx,%eax
}
f01062c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01062c7:	5b                   	pop    %ebx
f01062c8:	5e                   	pop    %esi
f01062c9:	5f                   	pop    %edi
f01062ca:	5d                   	pop    %ebp
f01062cb:	c3                   	ret    

f01062cc <mp_init>:
	return conf;
}

void
mp_init(void)
{
f01062cc:	55                   	push   %ebp
f01062cd:	89 e5                	mov    %esp,%ebp
f01062cf:	57                   	push   %edi
f01062d0:	56                   	push   %esi
f01062d1:	53                   	push   %ebx
f01062d2:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f01062d5:	c7 05 c0 23 23 f0 20 	movl   $0xf0232020,0xf02323c0
f01062dc:	20 23 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01062df:	83 3d 88 1e 23 f0 00 	cmpl   $0x0,0xf0231e88
f01062e6:	75 16                	jne    f01062fe <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01062e8:	68 00 04 00 00       	push   $0x400
f01062ed:	68 84 6c 10 f0       	push   $0xf0106c84
f01062f2:	6a 6f                	push   $0x6f
f01062f4:	68 45 8a 10 f0       	push   $0xf0108a45
f01062f9:	e8 42 9d ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f01062fe:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0106305:	85 c0                	test   %eax,%eax
f0106307:	74 16                	je     f010631f <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0106309:	c1 e0 04             	shl    $0x4,%eax
f010630c:	ba 00 04 00 00       	mov    $0x400,%edx
f0106311:	e8 1d ff ff ff       	call   f0106233 <mpsearch1>
f0106316:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106319:	85 c0                	test   %eax,%eax
f010631b:	75 3c                	jne    f0106359 <mp_init+0x8d>
f010631d:	eb 20                	jmp    f010633f <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f010631f:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0106326:	c1 e0 0a             	shl    $0xa,%eax
f0106329:	2d 00 04 00 00       	sub    $0x400,%eax
f010632e:	ba 00 04 00 00       	mov    $0x400,%edx
f0106333:	e8 fb fe ff ff       	call   f0106233 <mpsearch1>
f0106338:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010633b:	85 c0                	test   %eax,%eax
f010633d:	75 1a                	jne    f0106359 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f010633f:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106344:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0106349:	e8 e5 fe ff ff       	call   f0106233 <mpsearch1>
f010634e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0106351:	85 c0                	test   %eax,%eax
f0106353:	0f 84 5d 02 00 00    	je     f01065b6 <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0106359:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010635c:	8b 70 04             	mov    0x4(%eax),%esi
f010635f:	85 f6                	test   %esi,%esi
f0106361:	74 06                	je     f0106369 <mp_init+0x9d>
f0106363:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0106367:	74 15                	je     f010637e <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0106369:	83 ec 0c             	sub    $0xc,%esp
f010636c:	68 b8 88 10 f0       	push   $0xf01088b8
f0106371:	e8 e8 d7 ff ff       	call   f0103b5e <cprintf>
f0106376:	83 c4 10             	add    $0x10,%esp
f0106379:	e9 38 02 00 00       	jmp    f01065b6 <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010637e:	89 f0                	mov    %esi,%eax
f0106380:	c1 e8 0c             	shr    $0xc,%eax
f0106383:	3b 05 88 1e 23 f0    	cmp    0xf0231e88,%eax
f0106389:	72 15                	jb     f01063a0 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010638b:	56                   	push   %esi
f010638c:	68 84 6c 10 f0       	push   $0xf0106c84
f0106391:	68 90 00 00 00       	push   $0x90
f0106396:	68 45 8a 10 f0       	push   $0xf0108a45
f010639b:	e8 a0 9c ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01063a0:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f01063a6:	83 ec 04             	sub    $0x4,%esp
f01063a9:	6a 04                	push   $0x4
f01063ab:	68 5a 8a 10 f0       	push   $0xf0108a5a
f01063b0:	53                   	push   %ebx
f01063b1:	e8 c8 fc ff ff       	call   f010607e <memcmp>
f01063b6:	83 c4 10             	add    $0x10,%esp
f01063b9:	85 c0                	test   %eax,%eax
f01063bb:	74 15                	je     f01063d2 <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f01063bd:	83 ec 0c             	sub    $0xc,%esp
f01063c0:	68 e8 88 10 f0       	push   $0xf01088e8
f01063c5:	e8 94 d7 ff ff       	call   f0103b5e <cprintf>
f01063ca:	83 c4 10             	add    $0x10,%esp
f01063cd:	e9 e4 01 00 00       	jmp    f01065b6 <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01063d2:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f01063d6:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f01063da:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f01063dd:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f01063e2:	b8 00 00 00 00       	mov    $0x0,%eax
f01063e7:	eb 0d                	jmp    f01063f6 <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f01063e9:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f01063f0:	f0 
f01063f1:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01063f3:	83 c0 01             	add    $0x1,%eax
f01063f6:	39 c7                	cmp    %eax,%edi
f01063f8:	75 ef                	jne    f01063e9 <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01063fa:	84 d2                	test   %dl,%dl
f01063fc:	74 15                	je     f0106413 <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f01063fe:	83 ec 0c             	sub    $0xc,%esp
f0106401:	68 1c 89 10 f0       	push   $0xf010891c
f0106406:	e8 53 d7 ff ff       	call   f0103b5e <cprintf>
f010640b:	83 c4 10             	add    $0x10,%esp
f010640e:	e9 a3 01 00 00       	jmp    f01065b6 <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0106413:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0106417:	3c 01                	cmp    $0x1,%al
f0106419:	74 1d                	je     f0106438 <mp_init+0x16c>
f010641b:	3c 04                	cmp    $0x4,%al
f010641d:	74 19                	je     f0106438 <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f010641f:	83 ec 08             	sub    $0x8,%esp
f0106422:	0f b6 c0             	movzbl %al,%eax
f0106425:	50                   	push   %eax
f0106426:	68 40 89 10 f0       	push   $0xf0108940
f010642b:	e8 2e d7 ff ff       	call   f0103b5e <cprintf>
f0106430:	83 c4 10             	add    $0x10,%esp
f0106433:	e9 7e 01 00 00       	jmp    f01065b6 <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0106438:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f010643c:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0106440:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0106445:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f010644a:	01 ce                	add    %ecx,%esi
f010644c:	eb 0d                	jmp    f010645b <mp_init+0x18f>
f010644e:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0106455:	f0 
f0106456:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106458:	83 c0 01             	add    $0x1,%eax
f010645b:	39 c7                	cmp    %eax,%edi
f010645d:	75 ef                	jne    f010644e <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f010645f:	89 d0                	mov    %edx,%eax
f0106461:	02 43 2a             	add    0x2a(%ebx),%al
f0106464:	74 15                	je     f010647b <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0106466:	83 ec 0c             	sub    $0xc,%esp
f0106469:	68 60 89 10 f0       	push   $0xf0108960
f010646e:	e8 eb d6 ff ff       	call   f0103b5e <cprintf>
f0106473:	83 c4 10             	add    $0x10,%esp
f0106476:	e9 3b 01 00 00       	jmp    f01065b6 <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f010647b:	85 db                	test   %ebx,%ebx
f010647d:	0f 84 33 01 00 00    	je     f01065b6 <mp_init+0x2ea>
		return;
	ismp = 1;
f0106483:	c7 05 00 20 23 f0 01 	movl   $0x1,0xf0232000
f010648a:	00 00 00 
	lapicaddr = conf->lapicaddr;
f010648d:	8b 43 24             	mov    0x24(%ebx),%eax
f0106490:	a3 00 30 27 f0       	mov    %eax,0xf0273000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106495:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0106498:	be 00 00 00 00       	mov    $0x0,%esi
f010649d:	e9 85 00 00 00       	jmp    f0106527 <mp_init+0x25b>
		switch (*p) {
f01064a2:	0f b6 07             	movzbl (%edi),%eax
f01064a5:	84 c0                	test   %al,%al
f01064a7:	74 06                	je     f01064af <mp_init+0x1e3>
f01064a9:	3c 04                	cmp    $0x4,%al
f01064ab:	77 55                	ja     f0106502 <mp_init+0x236>
f01064ad:	eb 4e                	jmp    f01064fd <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f01064af:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f01064b3:	74 11                	je     f01064c6 <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f01064b5:	6b 05 c4 23 23 f0 74 	imul   $0x74,0xf02323c4,%eax
f01064bc:	05 20 20 23 f0       	add    $0xf0232020,%eax
f01064c1:	a3 c0 23 23 f0       	mov    %eax,0xf02323c0
			if (ncpu < NCPU) {
f01064c6:	a1 c4 23 23 f0       	mov    0xf02323c4,%eax
f01064cb:	83 f8 07             	cmp    $0x7,%eax
f01064ce:	7f 13                	jg     f01064e3 <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f01064d0:	6b d0 74             	imul   $0x74,%eax,%edx
f01064d3:	88 82 20 20 23 f0    	mov    %al,-0xfdcdfe0(%edx)
				ncpu++;
f01064d9:	83 c0 01             	add    $0x1,%eax
f01064dc:	a3 c4 23 23 f0       	mov    %eax,0xf02323c4
f01064e1:	eb 15                	jmp    f01064f8 <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f01064e3:	83 ec 08             	sub    $0x8,%esp
f01064e6:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f01064ea:	50                   	push   %eax
f01064eb:	68 90 89 10 f0       	push   $0xf0108990
f01064f0:	e8 69 d6 ff ff       	call   f0103b5e <cprintf>
f01064f5:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f01064f8:	83 c7 14             	add    $0x14,%edi
			continue;
f01064fb:	eb 27                	jmp    f0106524 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f01064fd:	83 c7 08             	add    $0x8,%edi
			continue;
f0106500:	eb 22                	jmp    f0106524 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0106502:	83 ec 08             	sub    $0x8,%esp
f0106505:	0f b6 c0             	movzbl %al,%eax
f0106508:	50                   	push   %eax
f0106509:	68 b8 89 10 f0       	push   $0xf01089b8
f010650e:	e8 4b d6 ff ff       	call   f0103b5e <cprintf>
			ismp = 0;
f0106513:	c7 05 00 20 23 f0 00 	movl   $0x0,0xf0232000
f010651a:	00 00 00 
			i = conf->entry;
f010651d:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0106521:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106524:	83 c6 01             	add    $0x1,%esi
f0106527:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f010652b:	39 c6                	cmp    %eax,%esi
f010652d:	0f 82 6f ff ff ff    	jb     f01064a2 <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0106533:	a1 c0 23 23 f0       	mov    0xf02323c0,%eax
f0106538:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f010653f:	83 3d 00 20 23 f0 00 	cmpl   $0x0,0xf0232000
f0106546:	75 26                	jne    f010656e <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0106548:	c7 05 c4 23 23 f0 01 	movl   $0x1,0xf02323c4
f010654f:	00 00 00 
		lapicaddr = 0;
f0106552:	c7 05 00 30 27 f0 00 	movl   $0x0,0xf0273000
f0106559:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f010655c:	83 ec 0c             	sub    $0xc,%esp
f010655f:	68 d8 89 10 f0       	push   $0xf01089d8
f0106564:	e8 f5 d5 ff ff       	call   f0103b5e <cprintf>
		return;
f0106569:	83 c4 10             	add    $0x10,%esp
f010656c:	eb 48                	jmp    f01065b6 <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f010656e:	83 ec 04             	sub    $0x4,%esp
f0106571:	ff 35 c4 23 23 f0    	pushl  0xf02323c4
f0106577:	0f b6 00             	movzbl (%eax),%eax
f010657a:	50                   	push   %eax
f010657b:	68 5f 8a 10 f0       	push   $0xf0108a5f
f0106580:	e8 d9 d5 ff ff       	call   f0103b5e <cprintf>

	if (mp->imcrp) {
f0106585:	83 c4 10             	add    $0x10,%esp
f0106588:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010658b:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f010658f:	74 25                	je     f01065b6 <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0106591:	83 ec 0c             	sub    $0xc,%esp
f0106594:	68 04 8a 10 f0       	push   $0xf0108a04
f0106599:	e8 c0 d5 ff ff       	call   f0103b5e <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010659e:	ba 22 00 00 00       	mov    $0x22,%edx
f01065a3:	b8 70 00 00 00       	mov    $0x70,%eax
f01065a8:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01065a9:	ba 23 00 00 00       	mov    $0x23,%edx
f01065ae:	ec                   	in     (%dx),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01065af:	83 c8 01             	or     $0x1,%eax
f01065b2:	ee                   	out    %al,(%dx)
f01065b3:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f01065b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01065b9:	5b                   	pop    %ebx
f01065ba:	5e                   	pop    %esi
f01065bb:	5f                   	pop    %edi
f01065bc:	5d                   	pop    %ebp
f01065bd:	c3                   	ret    

f01065be <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f01065be:	55                   	push   %ebp
f01065bf:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f01065c1:	8b 0d 04 30 27 f0    	mov    0xf0273004,%ecx
f01065c7:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f01065ca:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f01065cc:	a1 04 30 27 f0       	mov    0xf0273004,%eax
f01065d1:	8b 40 20             	mov    0x20(%eax),%eax
}
f01065d4:	5d                   	pop    %ebp
f01065d5:	c3                   	ret    

f01065d6 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f01065d6:	55                   	push   %ebp
f01065d7:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01065d9:	a1 04 30 27 f0       	mov    0xf0273004,%eax
f01065de:	85 c0                	test   %eax,%eax
f01065e0:	74 08                	je     f01065ea <cpunum+0x14>
		return lapic[ID] >> 24;
f01065e2:	8b 40 20             	mov    0x20(%eax),%eax
f01065e5:	c1 e8 18             	shr    $0x18,%eax
f01065e8:	eb 05                	jmp    f01065ef <cpunum+0x19>
	return 0;
f01065ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01065ef:	5d                   	pop    %ebp
f01065f0:	c3                   	ret    

f01065f1 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f01065f1:	a1 00 30 27 f0       	mov    0xf0273000,%eax
f01065f6:	85 c0                	test   %eax,%eax
f01065f8:	0f 84 21 01 00 00    	je     f010671f <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f01065fe:	55                   	push   %ebp
f01065ff:	89 e5                	mov    %esp,%ebp
f0106601:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0106604:	68 00 10 00 00       	push   $0x1000
f0106609:	50                   	push   %eax
f010660a:	e8 64 b0 ff ff       	call   f0101673 <mmio_map_region>
f010660f:	a3 04 30 27 f0       	mov    %eax,0xf0273004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0106614:	ba 27 01 00 00       	mov    $0x127,%edx
f0106619:	b8 3c 00 00 00       	mov    $0x3c,%eax
f010661e:	e8 9b ff ff ff       	call   f01065be <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0106623:	ba 0b 00 00 00       	mov    $0xb,%edx
f0106628:	b8 f8 00 00 00       	mov    $0xf8,%eax
f010662d:	e8 8c ff ff ff       	call   f01065be <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0106632:	ba 20 00 02 00       	mov    $0x20020,%edx
f0106637:	b8 c8 00 00 00       	mov    $0xc8,%eax
f010663c:	e8 7d ff ff ff       	call   f01065be <lapicw>
	lapicw(TICR, 10000000); 
f0106641:	ba 80 96 98 00       	mov    $0x989680,%edx
f0106646:	b8 e0 00 00 00       	mov    $0xe0,%eax
f010664b:	e8 6e ff ff ff       	call   f01065be <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0106650:	e8 81 ff ff ff       	call   f01065d6 <cpunum>
f0106655:	6b c0 74             	imul   $0x74,%eax,%eax
f0106658:	05 20 20 23 f0       	add    $0xf0232020,%eax
f010665d:	83 c4 10             	add    $0x10,%esp
f0106660:	39 05 c0 23 23 f0    	cmp    %eax,0xf02323c0
f0106666:	74 0f                	je     f0106677 <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0106668:	ba 00 00 01 00       	mov    $0x10000,%edx
f010666d:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0106672:	e8 47 ff ff ff       	call   f01065be <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0106677:	ba 00 00 01 00       	mov    $0x10000,%edx
f010667c:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0106681:	e8 38 ff ff ff       	call   f01065be <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0106686:	a1 04 30 27 f0       	mov    0xf0273004,%eax
f010668b:	8b 40 30             	mov    0x30(%eax),%eax
f010668e:	c1 e8 10             	shr    $0x10,%eax
f0106691:	3c 03                	cmp    $0x3,%al
f0106693:	76 0f                	jbe    f01066a4 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0106695:	ba 00 00 01 00       	mov    $0x10000,%edx
f010669a:	b8 d0 00 00 00       	mov    $0xd0,%eax
f010669f:	e8 1a ff ff ff       	call   f01065be <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f01066a4:	ba 33 00 00 00       	mov    $0x33,%edx
f01066a9:	b8 dc 00 00 00       	mov    $0xdc,%eax
f01066ae:	e8 0b ff ff ff       	call   f01065be <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f01066b3:	ba 00 00 00 00       	mov    $0x0,%edx
f01066b8:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01066bd:	e8 fc fe ff ff       	call   f01065be <lapicw>
	lapicw(ESR, 0);
f01066c2:	ba 00 00 00 00       	mov    $0x0,%edx
f01066c7:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01066cc:	e8 ed fe ff ff       	call   f01065be <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f01066d1:	ba 00 00 00 00       	mov    $0x0,%edx
f01066d6:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01066db:	e8 de fe ff ff       	call   f01065be <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f01066e0:	ba 00 00 00 00       	mov    $0x0,%edx
f01066e5:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01066ea:	e8 cf fe ff ff       	call   f01065be <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f01066ef:	ba 00 85 08 00       	mov    $0x88500,%edx
f01066f4:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01066f9:	e8 c0 fe ff ff       	call   f01065be <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01066fe:	8b 15 04 30 27 f0    	mov    0xf0273004,%edx
f0106704:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010670a:	f6 c4 10             	test   $0x10,%ah
f010670d:	75 f5                	jne    f0106704 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f010670f:	ba 00 00 00 00       	mov    $0x0,%edx
f0106714:	b8 20 00 00 00       	mov    $0x20,%eax
f0106719:	e8 a0 fe ff ff       	call   f01065be <lapicw>
}
f010671e:	c9                   	leave  
f010671f:	f3 c3                	repz ret 

f0106721 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0106721:	83 3d 04 30 27 f0 00 	cmpl   $0x0,0xf0273004
f0106728:	74 13                	je     f010673d <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f010672a:	55                   	push   %ebp
f010672b:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f010672d:	ba 00 00 00 00       	mov    $0x0,%edx
f0106732:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106737:	e8 82 fe ff ff       	call   f01065be <lapicw>
}
f010673c:	5d                   	pop    %ebp
f010673d:	f3 c3                	repz ret 

f010673f <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f010673f:	55                   	push   %ebp
f0106740:	89 e5                	mov    %esp,%ebp
f0106742:	56                   	push   %esi
f0106743:	53                   	push   %ebx
f0106744:	8b 75 08             	mov    0x8(%ebp),%esi
f0106747:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010674a:	ba 70 00 00 00       	mov    $0x70,%edx
f010674f:	b8 0f 00 00 00       	mov    $0xf,%eax
f0106754:	ee                   	out    %al,(%dx)
f0106755:	ba 71 00 00 00       	mov    $0x71,%edx
f010675a:	b8 0a 00 00 00       	mov    $0xa,%eax
f010675f:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106760:	83 3d 88 1e 23 f0 00 	cmpl   $0x0,0xf0231e88
f0106767:	75 19                	jne    f0106782 <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106769:	68 67 04 00 00       	push   $0x467
f010676e:	68 84 6c 10 f0       	push   $0xf0106c84
f0106773:	68 98 00 00 00       	push   $0x98
f0106778:	68 7c 8a 10 f0       	push   $0xf0108a7c
f010677d:	e8 be 98 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0106782:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0106789:	00 00 
	wrv[1] = addr >> 4;
f010678b:	89 d8                	mov    %ebx,%eax
f010678d:	c1 e8 04             	shr    $0x4,%eax
f0106790:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106796:	c1 e6 18             	shl    $0x18,%esi
f0106799:	89 f2                	mov    %esi,%edx
f010679b:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01067a0:	e8 19 fe ff ff       	call   f01065be <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f01067a5:	ba 00 c5 00 00       	mov    $0xc500,%edx
f01067aa:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01067af:	e8 0a fe ff ff       	call   f01065be <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f01067b4:	ba 00 85 00 00       	mov    $0x8500,%edx
f01067b9:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01067be:	e8 fb fd ff ff       	call   f01065be <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01067c3:	c1 eb 0c             	shr    $0xc,%ebx
f01067c6:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f01067c9:	89 f2                	mov    %esi,%edx
f01067cb:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01067d0:	e8 e9 fd ff ff       	call   f01065be <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01067d5:	89 da                	mov    %ebx,%edx
f01067d7:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01067dc:	e8 dd fd ff ff       	call   f01065be <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f01067e1:	89 f2                	mov    %esi,%edx
f01067e3:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01067e8:	e8 d1 fd ff ff       	call   f01065be <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01067ed:	89 da                	mov    %ebx,%edx
f01067ef:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01067f4:	e8 c5 fd ff ff       	call   f01065be <lapicw>
		microdelay(200);
	}
}
f01067f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01067fc:	5b                   	pop    %ebx
f01067fd:	5e                   	pop    %esi
f01067fe:	5d                   	pop    %ebp
f01067ff:	c3                   	ret    

f0106800 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106800:	55                   	push   %ebp
f0106801:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106803:	8b 55 08             	mov    0x8(%ebp),%edx
f0106806:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f010680c:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106811:	e8 a8 fd ff ff       	call   f01065be <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106816:	8b 15 04 30 27 f0    	mov    0xf0273004,%edx
f010681c:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106822:	f6 c4 10             	test   $0x10,%ah
f0106825:	75 f5                	jne    f010681c <lapic_ipi+0x1c>
		;
}
f0106827:	5d                   	pop    %ebp
f0106828:	c3                   	ret    

f0106829 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106829:	55                   	push   %ebp
f010682a:	89 e5                	mov    %esp,%ebp
f010682c:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f010682f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106835:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106838:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f010683b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106842:	5d                   	pop    %ebp
f0106843:	c3                   	ret    

f0106844 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106844:	55                   	push   %ebp
f0106845:	89 e5                	mov    %esp,%ebp
f0106847:	56                   	push   %esi
f0106848:	53                   	push   %ebx
f0106849:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f010684c:	83 3b 00             	cmpl   $0x0,(%ebx)
f010684f:	74 14                	je     f0106865 <spin_lock+0x21>
f0106851:	8b 73 08             	mov    0x8(%ebx),%esi
f0106854:	e8 7d fd ff ff       	call   f01065d6 <cpunum>
f0106859:	6b c0 74             	imul   $0x74,%eax,%eax
f010685c:	05 20 20 23 f0       	add    $0xf0232020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106861:	39 c6                	cmp    %eax,%esi
f0106863:	74 07                	je     f010686c <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106865:	ba 01 00 00 00       	mov    $0x1,%edx
f010686a:	eb 20                	jmp    f010688c <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f010686c:	8b 5b 04             	mov    0x4(%ebx),%ebx
f010686f:	e8 62 fd ff ff       	call   f01065d6 <cpunum>
f0106874:	83 ec 0c             	sub    $0xc,%esp
f0106877:	53                   	push   %ebx
f0106878:	50                   	push   %eax
f0106879:	68 8c 8a 10 f0       	push   $0xf0108a8c
f010687e:	6a 41                	push   $0x41
f0106880:	68 f0 8a 10 f0       	push   $0xf0108af0
f0106885:	e8 b6 97 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f010688a:	f3 90                	pause  
f010688c:	89 d0                	mov    %edx,%eax
f010688e:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106891:	85 c0                	test   %eax,%eax
f0106893:	75 f5                	jne    f010688a <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106895:	e8 3c fd ff ff       	call   f01065d6 <cpunum>
f010689a:	6b c0 74             	imul   $0x74,%eax,%eax
f010689d:	05 20 20 23 f0       	add    $0xf0232020,%eax
f01068a2:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f01068a5:	83 c3 0c             	add    $0xc,%ebx

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f01068a8:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01068aa:	b8 00 00 00 00       	mov    $0x0,%eax
f01068af:	eb 0b                	jmp    f01068bc <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f01068b1:	8b 4a 04             	mov    0x4(%edx),%ecx
f01068b4:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01068b7:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01068b9:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f01068bc:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f01068c2:	76 11                	jbe    f01068d5 <spin_lock+0x91>
f01068c4:	83 f8 09             	cmp    $0x9,%eax
f01068c7:	7e e8                	jle    f01068b1 <spin_lock+0x6d>
f01068c9:	eb 0a                	jmp    f01068d5 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f01068cb:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f01068d2:	83 c0 01             	add    $0x1,%eax
f01068d5:	83 f8 09             	cmp    $0x9,%eax
f01068d8:	7e f1                	jle    f01068cb <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f01068da:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01068dd:	5b                   	pop    %ebx
f01068de:	5e                   	pop    %esi
f01068df:	5d                   	pop    %ebp
f01068e0:	c3                   	ret    

f01068e1 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01068e1:	55                   	push   %ebp
f01068e2:	89 e5                	mov    %esp,%ebp
f01068e4:	57                   	push   %edi
f01068e5:	56                   	push   %esi
f01068e6:	53                   	push   %ebx
f01068e7:	83 ec 4c             	sub    $0x4c,%esp
f01068ea:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f01068ed:	83 3e 00             	cmpl   $0x0,(%esi)
f01068f0:	74 18                	je     f010690a <spin_unlock+0x29>
f01068f2:	8b 5e 08             	mov    0x8(%esi),%ebx
f01068f5:	e8 dc fc ff ff       	call   f01065d6 <cpunum>
f01068fa:	6b c0 74             	imul   $0x74,%eax,%eax
f01068fd:	05 20 20 23 f0       	add    $0xf0232020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106902:	39 c3                	cmp    %eax,%ebx
f0106904:	0f 84 a5 00 00 00    	je     f01069af <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f010690a:	83 ec 04             	sub    $0x4,%esp
f010690d:	6a 28                	push   $0x28
f010690f:	8d 46 0c             	lea    0xc(%esi),%eax
f0106912:	50                   	push   %eax
f0106913:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0106916:	53                   	push   %ebx
f0106917:	e8 e7 f6 ff ff       	call   f0106003 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f010691c:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f010691f:	0f b6 38             	movzbl (%eax),%edi
f0106922:	8b 76 04             	mov    0x4(%esi),%esi
f0106925:	e8 ac fc ff ff       	call   f01065d6 <cpunum>
f010692a:	57                   	push   %edi
f010692b:	56                   	push   %esi
f010692c:	50                   	push   %eax
f010692d:	68 b8 8a 10 f0       	push   $0xf0108ab8
f0106932:	e8 27 d2 ff ff       	call   f0103b5e <cprintf>
f0106937:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010693a:	8d 7d a8             	lea    -0x58(%ebp),%edi
f010693d:	eb 54                	jmp    f0106993 <spin_unlock+0xb2>
f010693f:	83 ec 08             	sub    $0x8,%esp
f0106942:	57                   	push   %edi
f0106943:	50                   	push   %eax
f0106944:	e8 04 ec ff ff       	call   f010554d <debuginfo_eip>
f0106949:	83 c4 10             	add    $0x10,%esp
f010694c:	85 c0                	test   %eax,%eax
f010694e:	78 27                	js     f0106977 <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106950:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106952:	83 ec 04             	sub    $0x4,%esp
f0106955:	89 c2                	mov    %eax,%edx
f0106957:	2b 55 b8             	sub    -0x48(%ebp),%edx
f010695a:	52                   	push   %edx
f010695b:	ff 75 b0             	pushl  -0x50(%ebp)
f010695e:	ff 75 b4             	pushl  -0x4c(%ebp)
f0106961:	ff 75 ac             	pushl  -0x54(%ebp)
f0106964:	ff 75 a8             	pushl  -0x58(%ebp)
f0106967:	50                   	push   %eax
f0106968:	68 00 8b 10 f0       	push   $0xf0108b00
f010696d:	e8 ec d1 ff ff       	call   f0103b5e <cprintf>
f0106972:	83 c4 20             	add    $0x20,%esp
f0106975:	eb 12                	jmp    f0106989 <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0106977:	83 ec 08             	sub    $0x8,%esp
f010697a:	ff 36                	pushl  (%esi)
f010697c:	68 17 8b 10 f0       	push   $0xf0108b17
f0106981:	e8 d8 d1 ff ff       	call   f0103b5e <cprintf>
f0106986:	83 c4 10             	add    $0x10,%esp
f0106989:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f010698c:	8d 45 e8             	lea    -0x18(%ebp),%eax
f010698f:	39 c3                	cmp    %eax,%ebx
f0106991:	74 08                	je     f010699b <spin_unlock+0xba>
f0106993:	89 de                	mov    %ebx,%esi
f0106995:	8b 03                	mov    (%ebx),%eax
f0106997:	85 c0                	test   %eax,%eax
f0106999:	75 a4                	jne    f010693f <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f010699b:	83 ec 04             	sub    $0x4,%esp
f010699e:	68 1f 8b 10 f0       	push   $0xf0108b1f
f01069a3:	6a 67                	push   $0x67
f01069a5:	68 f0 8a 10 f0       	push   $0xf0108af0
f01069aa:	e8 91 96 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f01069af:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f01069b6:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01069bd:	b8 00 00 00 00       	mov    $0x0,%eax
f01069c2:	f0 87 06             	lock xchg %eax,(%esi)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f01069c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01069c8:	5b                   	pop    %ebx
f01069c9:	5e                   	pop    %esi
f01069ca:	5f                   	pop    %edi
f01069cb:	5d                   	pop    %ebp
f01069cc:	c3                   	ret    
f01069cd:	66 90                	xchg   %ax,%ax
f01069cf:	90                   	nop

f01069d0 <__udivdi3>:
f01069d0:	55                   	push   %ebp
f01069d1:	57                   	push   %edi
f01069d2:	56                   	push   %esi
f01069d3:	53                   	push   %ebx
f01069d4:	83 ec 1c             	sub    $0x1c,%esp
f01069d7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f01069db:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f01069df:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f01069e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01069e7:	85 f6                	test   %esi,%esi
f01069e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01069ed:	89 ca                	mov    %ecx,%edx
f01069ef:	89 f8                	mov    %edi,%eax
f01069f1:	75 3d                	jne    f0106a30 <__udivdi3+0x60>
f01069f3:	39 cf                	cmp    %ecx,%edi
f01069f5:	0f 87 c5 00 00 00    	ja     f0106ac0 <__udivdi3+0xf0>
f01069fb:	85 ff                	test   %edi,%edi
f01069fd:	89 fd                	mov    %edi,%ebp
f01069ff:	75 0b                	jne    f0106a0c <__udivdi3+0x3c>
f0106a01:	b8 01 00 00 00       	mov    $0x1,%eax
f0106a06:	31 d2                	xor    %edx,%edx
f0106a08:	f7 f7                	div    %edi
f0106a0a:	89 c5                	mov    %eax,%ebp
f0106a0c:	89 c8                	mov    %ecx,%eax
f0106a0e:	31 d2                	xor    %edx,%edx
f0106a10:	f7 f5                	div    %ebp
f0106a12:	89 c1                	mov    %eax,%ecx
f0106a14:	89 d8                	mov    %ebx,%eax
f0106a16:	89 cf                	mov    %ecx,%edi
f0106a18:	f7 f5                	div    %ebp
f0106a1a:	89 c3                	mov    %eax,%ebx
f0106a1c:	89 d8                	mov    %ebx,%eax
f0106a1e:	89 fa                	mov    %edi,%edx
f0106a20:	83 c4 1c             	add    $0x1c,%esp
f0106a23:	5b                   	pop    %ebx
f0106a24:	5e                   	pop    %esi
f0106a25:	5f                   	pop    %edi
f0106a26:	5d                   	pop    %ebp
f0106a27:	c3                   	ret    
f0106a28:	90                   	nop
f0106a29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106a30:	39 ce                	cmp    %ecx,%esi
f0106a32:	77 74                	ja     f0106aa8 <__udivdi3+0xd8>
f0106a34:	0f bd fe             	bsr    %esi,%edi
f0106a37:	83 f7 1f             	xor    $0x1f,%edi
f0106a3a:	0f 84 98 00 00 00    	je     f0106ad8 <__udivdi3+0x108>
f0106a40:	bb 20 00 00 00       	mov    $0x20,%ebx
f0106a45:	89 f9                	mov    %edi,%ecx
f0106a47:	89 c5                	mov    %eax,%ebp
f0106a49:	29 fb                	sub    %edi,%ebx
f0106a4b:	d3 e6                	shl    %cl,%esi
f0106a4d:	89 d9                	mov    %ebx,%ecx
f0106a4f:	d3 ed                	shr    %cl,%ebp
f0106a51:	89 f9                	mov    %edi,%ecx
f0106a53:	d3 e0                	shl    %cl,%eax
f0106a55:	09 ee                	or     %ebp,%esi
f0106a57:	89 d9                	mov    %ebx,%ecx
f0106a59:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106a5d:	89 d5                	mov    %edx,%ebp
f0106a5f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106a63:	d3 ed                	shr    %cl,%ebp
f0106a65:	89 f9                	mov    %edi,%ecx
f0106a67:	d3 e2                	shl    %cl,%edx
f0106a69:	89 d9                	mov    %ebx,%ecx
f0106a6b:	d3 e8                	shr    %cl,%eax
f0106a6d:	09 c2                	or     %eax,%edx
f0106a6f:	89 d0                	mov    %edx,%eax
f0106a71:	89 ea                	mov    %ebp,%edx
f0106a73:	f7 f6                	div    %esi
f0106a75:	89 d5                	mov    %edx,%ebp
f0106a77:	89 c3                	mov    %eax,%ebx
f0106a79:	f7 64 24 0c          	mull   0xc(%esp)
f0106a7d:	39 d5                	cmp    %edx,%ebp
f0106a7f:	72 10                	jb     f0106a91 <__udivdi3+0xc1>
f0106a81:	8b 74 24 08          	mov    0x8(%esp),%esi
f0106a85:	89 f9                	mov    %edi,%ecx
f0106a87:	d3 e6                	shl    %cl,%esi
f0106a89:	39 c6                	cmp    %eax,%esi
f0106a8b:	73 07                	jae    f0106a94 <__udivdi3+0xc4>
f0106a8d:	39 d5                	cmp    %edx,%ebp
f0106a8f:	75 03                	jne    f0106a94 <__udivdi3+0xc4>
f0106a91:	83 eb 01             	sub    $0x1,%ebx
f0106a94:	31 ff                	xor    %edi,%edi
f0106a96:	89 d8                	mov    %ebx,%eax
f0106a98:	89 fa                	mov    %edi,%edx
f0106a9a:	83 c4 1c             	add    $0x1c,%esp
f0106a9d:	5b                   	pop    %ebx
f0106a9e:	5e                   	pop    %esi
f0106a9f:	5f                   	pop    %edi
f0106aa0:	5d                   	pop    %ebp
f0106aa1:	c3                   	ret    
f0106aa2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106aa8:	31 ff                	xor    %edi,%edi
f0106aaa:	31 db                	xor    %ebx,%ebx
f0106aac:	89 d8                	mov    %ebx,%eax
f0106aae:	89 fa                	mov    %edi,%edx
f0106ab0:	83 c4 1c             	add    $0x1c,%esp
f0106ab3:	5b                   	pop    %ebx
f0106ab4:	5e                   	pop    %esi
f0106ab5:	5f                   	pop    %edi
f0106ab6:	5d                   	pop    %ebp
f0106ab7:	c3                   	ret    
f0106ab8:	90                   	nop
f0106ab9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106ac0:	89 d8                	mov    %ebx,%eax
f0106ac2:	f7 f7                	div    %edi
f0106ac4:	31 ff                	xor    %edi,%edi
f0106ac6:	89 c3                	mov    %eax,%ebx
f0106ac8:	89 d8                	mov    %ebx,%eax
f0106aca:	89 fa                	mov    %edi,%edx
f0106acc:	83 c4 1c             	add    $0x1c,%esp
f0106acf:	5b                   	pop    %ebx
f0106ad0:	5e                   	pop    %esi
f0106ad1:	5f                   	pop    %edi
f0106ad2:	5d                   	pop    %ebp
f0106ad3:	c3                   	ret    
f0106ad4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106ad8:	39 ce                	cmp    %ecx,%esi
f0106ada:	72 0c                	jb     f0106ae8 <__udivdi3+0x118>
f0106adc:	31 db                	xor    %ebx,%ebx
f0106ade:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0106ae2:	0f 87 34 ff ff ff    	ja     f0106a1c <__udivdi3+0x4c>
f0106ae8:	bb 01 00 00 00       	mov    $0x1,%ebx
f0106aed:	e9 2a ff ff ff       	jmp    f0106a1c <__udivdi3+0x4c>
f0106af2:	66 90                	xchg   %ax,%ax
f0106af4:	66 90                	xchg   %ax,%ax
f0106af6:	66 90                	xchg   %ax,%ax
f0106af8:	66 90                	xchg   %ax,%ax
f0106afa:	66 90                	xchg   %ax,%ax
f0106afc:	66 90                	xchg   %ax,%ax
f0106afe:	66 90                	xchg   %ax,%ax

f0106b00 <__umoddi3>:
f0106b00:	55                   	push   %ebp
f0106b01:	57                   	push   %edi
f0106b02:	56                   	push   %esi
f0106b03:	53                   	push   %ebx
f0106b04:	83 ec 1c             	sub    $0x1c,%esp
f0106b07:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0106b0b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f0106b0f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106b13:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106b17:	85 d2                	test   %edx,%edx
f0106b19:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0106b1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106b21:	89 f3                	mov    %esi,%ebx
f0106b23:	89 3c 24             	mov    %edi,(%esp)
f0106b26:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106b2a:	75 1c                	jne    f0106b48 <__umoddi3+0x48>
f0106b2c:	39 f7                	cmp    %esi,%edi
f0106b2e:	76 50                	jbe    f0106b80 <__umoddi3+0x80>
f0106b30:	89 c8                	mov    %ecx,%eax
f0106b32:	89 f2                	mov    %esi,%edx
f0106b34:	f7 f7                	div    %edi
f0106b36:	89 d0                	mov    %edx,%eax
f0106b38:	31 d2                	xor    %edx,%edx
f0106b3a:	83 c4 1c             	add    $0x1c,%esp
f0106b3d:	5b                   	pop    %ebx
f0106b3e:	5e                   	pop    %esi
f0106b3f:	5f                   	pop    %edi
f0106b40:	5d                   	pop    %ebp
f0106b41:	c3                   	ret    
f0106b42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106b48:	39 f2                	cmp    %esi,%edx
f0106b4a:	89 d0                	mov    %edx,%eax
f0106b4c:	77 52                	ja     f0106ba0 <__umoddi3+0xa0>
f0106b4e:	0f bd ea             	bsr    %edx,%ebp
f0106b51:	83 f5 1f             	xor    $0x1f,%ebp
f0106b54:	75 5a                	jne    f0106bb0 <__umoddi3+0xb0>
f0106b56:	3b 54 24 04          	cmp    0x4(%esp),%edx
f0106b5a:	0f 82 e0 00 00 00    	jb     f0106c40 <__umoddi3+0x140>
f0106b60:	39 0c 24             	cmp    %ecx,(%esp)
f0106b63:	0f 86 d7 00 00 00    	jbe    f0106c40 <__umoddi3+0x140>
f0106b69:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106b6d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106b71:	83 c4 1c             	add    $0x1c,%esp
f0106b74:	5b                   	pop    %ebx
f0106b75:	5e                   	pop    %esi
f0106b76:	5f                   	pop    %edi
f0106b77:	5d                   	pop    %ebp
f0106b78:	c3                   	ret    
f0106b79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106b80:	85 ff                	test   %edi,%edi
f0106b82:	89 fd                	mov    %edi,%ebp
f0106b84:	75 0b                	jne    f0106b91 <__umoddi3+0x91>
f0106b86:	b8 01 00 00 00       	mov    $0x1,%eax
f0106b8b:	31 d2                	xor    %edx,%edx
f0106b8d:	f7 f7                	div    %edi
f0106b8f:	89 c5                	mov    %eax,%ebp
f0106b91:	89 f0                	mov    %esi,%eax
f0106b93:	31 d2                	xor    %edx,%edx
f0106b95:	f7 f5                	div    %ebp
f0106b97:	89 c8                	mov    %ecx,%eax
f0106b99:	f7 f5                	div    %ebp
f0106b9b:	89 d0                	mov    %edx,%eax
f0106b9d:	eb 99                	jmp    f0106b38 <__umoddi3+0x38>
f0106b9f:	90                   	nop
f0106ba0:	89 c8                	mov    %ecx,%eax
f0106ba2:	89 f2                	mov    %esi,%edx
f0106ba4:	83 c4 1c             	add    $0x1c,%esp
f0106ba7:	5b                   	pop    %ebx
f0106ba8:	5e                   	pop    %esi
f0106ba9:	5f                   	pop    %edi
f0106baa:	5d                   	pop    %ebp
f0106bab:	c3                   	ret    
f0106bac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106bb0:	8b 34 24             	mov    (%esp),%esi
f0106bb3:	bf 20 00 00 00       	mov    $0x20,%edi
f0106bb8:	89 e9                	mov    %ebp,%ecx
f0106bba:	29 ef                	sub    %ebp,%edi
f0106bbc:	d3 e0                	shl    %cl,%eax
f0106bbe:	89 f9                	mov    %edi,%ecx
f0106bc0:	89 f2                	mov    %esi,%edx
f0106bc2:	d3 ea                	shr    %cl,%edx
f0106bc4:	89 e9                	mov    %ebp,%ecx
f0106bc6:	09 c2                	or     %eax,%edx
f0106bc8:	89 d8                	mov    %ebx,%eax
f0106bca:	89 14 24             	mov    %edx,(%esp)
f0106bcd:	89 f2                	mov    %esi,%edx
f0106bcf:	d3 e2                	shl    %cl,%edx
f0106bd1:	89 f9                	mov    %edi,%ecx
f0106bd3:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106bd7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0106bdb:	d3 e8                	shr    %cl,%eax
f0106bdd:	89 e9                	mov    %ebp,%ecx
f0106bdf:	89 c6                	mov    %eax,%esi
f0106be1:	d3 e3                	shl    %cl,%ebx
f0106be3:	89 f9                	mov    %edi,%ecx
f0106be5:	89 d0                	mov    %edx,%eax
f0106be7:	d3 e8                	shr    %cl,%eax
f0106be9:	89 e9                	mov    %ebp,%ecx
f0106beb:	09 d8                	or     %ebx,%eax
f0106bed:	89 d3                	mov    %edx,%ebx
f0106bef:	89 f2                	mov    %esi,%edx
f0106bf1:	f7 34 24             	divl   (%esp)
f0106bf4:	89 d6                	mov    %edx,%esi
f0106bf6:	d3 e3                	shl    %cl,%ebx
f0106bf8:	f7 64 24 04          	mull   0x4(%esp)
f0106bfc:	39 d6                	cmp    %edx,%esi
f0106bfe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106c02:	89 d1                	mov    %edx,%ecx
f0106c04:	89 c3                	mov    %eax,%ebx
f0106c06:	72 08                	jb     f0106c10 <__umoddi3+0x110>
f0106c08:	75 11                	jne    f0106c1b <__umoddi3+0x11b>
f0106c0a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0106c0e:	73 0b                	jae    f0106c1b <__umoddi3+0x11b>
f0106c10:	2b 44 24 04          	sub    0x4(%esp),%eax
f0106c14:	1b 14 24             	sbb    (%esp),%edx
f0106c17:	89 d1                	mov    %edx,%ecx
f0106c19:	89 c3                	mov    %eax,%ebx
f0106c1b:	8b 54 24 08          	mov    0x8(%esp),%edx
f0106c1f:	29 da                	sub    %ebx,%edx
f0106c21:	19 ce                	sbb    %ecx,%esi
f0106c23:	89 f9                	mov    %edi,%ecx
f0106c25:	89 f0                	mov    %esi,%eax
f0106c27:	d3 e0                	shl    %cl,%eax
f0106c29:	89 e9                	mov    %ebp,%ecx
f0106c2b:	d3 ea                	shr    %cl,%edx
f0106c2d:	89 e9                	mov    %ebp,%ecx
f0106c2f:	d3 ee                	shr    %cl,%esi
f0106c31:	09 d0                	or     %edx,%eax
f0106c33:	89 f2                	mov    %esi,%edx
f0106c35:	83 c4 1c             	add    $0x1c,%esp
f0106c38:	5b                   	pop    %ebx
f0106c39:	5e                   	pop    %esi
f0106c3a:	5f                   	pop    %edi
f0106c3b:	5d                   	pop    %ebp
f0106c3c:	c3                   	ret    
f0106c3d:	8d 76 00             	lea    0x0(%esi),%esi
f0106c40:	29 f9                	sub    %edi,%ecx
f0106c42:	19 d6                	sbb    %edx,%esi
f0106c44:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106c48:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106c4c:	e9 18 ff ff ff       	jmp    f0106b69 <__umoddi3+0x69>
