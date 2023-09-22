
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp

    tail kern_init
    80200008:	0040006f          	j	8020000c <kern_init>

000000008020000c <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000c:	00004517          	auipc	a0,0x4
    80200010:	00450513          	addi	a0,a0,4 # 80204010 <edata>
    80200014:	00004617          	auipc	a2,0x4
    80200018:	01460613          	addi	a2,a2,20 # 80204028 <end>
int kern_init(void) {
    8020001c:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8020001e:	8e09                	sub	a2,a2,a0
    80200020:	4581                	li	a1,0
int kern_init(void) {
    80200022:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200024:	2a9000ef          	jal	ra,80200acc <memset>

    cons_init();  // init the console
    80200028:	14e000ef          	jal	ra,80200176 <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002c:	00001597          	auipc	a1,0x1
    80200030:	ab458593          	addi	a1,a1,-1356 # 80200ae0 <etext+0x2>
    80200034:	00001517          	auipc	a0,0x1
    80200038:	acc50513          	addi	a0,a0,-1332 # 80200b00 <etext+0x22>
    8020003c:	032000ef          	jal	ra,8020006e <cprintf>

    print_kerninfo();
    80200040:	062000ef          	jal	ra,802000a2 <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200044:	142000ef          	jal	ra,80200186 <idt_init>

    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    80200048:	0ea000ef          	jal	ra,80200132 <clock_init>

    intr_enable();  // enable irq interrupt
    8020004c:	134000ef          	jal	ra,80200180 <intr_enable>
    
   
 __asm__ __volatile__("ebreak");
    80200050:	9002                	ebreak
    while (1)
        ;
    80200052:	a001                	j	80200052 <kern_init+0x46>

0000000080200054 <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    80200054:	1141                	addi	sp,sp,-16
    80200056:	e022                	sd	s0,0(sp)
    80200058:	e406                	sd	ra,8(sp)
    8020005a:	842e                	mv	s0,a1
    cons_putc(c);
    8020005c:	11c000ef          	jal	ra,80200178 <cons_putc>
    (*cnt)++;
    80200060:	401c                	lw	a5,0(s0)
}
    80200062:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    80200064:	2785                	addiw	a5,a5,1
    80200066:	c01c                	sw	a5,0(s0)
}
    80200068:	6402                	ld	s0,0(sp)
    8020006a:	0141                	addi	sp,sp,16
    8020006c:	8082                	ret

000000008020006e <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    8020006e:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    80200070:	02810313          	addi	t1,sp,40 # 80204028 <end>
int cprintf(const char *fmt, ...) {
    80200074:	f42e                	sd	a1,40(sp)
    80200076:	f832                	sd	a2,48(sp)
    80200078:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    8020007a:	862a                	mv	a2,a0
    8020007c:	004c                	addi	a1,sp,4
    8020007e:	00000517          	auipc	a0,0x0
    80200082:	fd650513          	addi	a0,a0,-42 # 80200054 <cputch>
    80200086:	869a                	mv	a3,t1
int cprintf(const char *fmt, ...) {
    80200088:	ec06                	sd	ra,24(sp)
    8020008a:	e0ba                	sd	a4,64(sp)
    8020008c:	e4be                	sd	a5,72(sp)
    8020008e:	e8c2                	sd	a6,80(sp)
    80200090:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    80200092:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    80200094:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200096:	630000ef          	jal	ra,802006c6 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    8020009a:	60e2                	ld	ra,24(sp)
    8020009c:	4512                	lw	a0,4(sp)
    8020009e:	6125                	addi	sp,sp,96
    802000a0:	8082                	ret

00000000802000a2 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
    802000a2:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000a4:	00001517          	auipc	a0,0x1
    802000a8:	a6450513          	addi	a0,a0,-1436 # 80200b08 <etext+0x2a>
void print_kerninfo(void) {
    802000ac:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000ae:	fc1ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000b2:	00000597          	auipc	a1,0x0
    802000b6:	f5a58593          	addi	a1,a1,-166 # 8020000c <kern_init>
    802000ba:	00001517          	auipc	a0,0x1
    802000be:	a6e50513          	addi	a0,a0,-1426 # 80200b28 <etext+0x4a>
    802000c2:	fadff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000c6:	00001597          	auipc	a1,0x1
    802000ca:	a1858593          	addi	a1,a1,-1512 # 80200ade <etext>
    802000ce:	00001517          	auipc	a0,0x1
    802000d2:	a7a50513          	addi	a0,a0,-1414 # 80200b48 <etext+0x6a>
    802000d6:	f99ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000da:	00004597          	auipc	a1,0x4
    802000de:	f3658593          	addi	a1,a1,-202 # 80204010 <edata>
    802000e2:	00001517          	auipc	a0,0x1
    802000e6:	a8650513          	addi	a0,a0,-1402 # 80200b68 <etext+0x8a>
    802000ea:	f85ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000ee:	00004597          	auipc	a1,0x4
    802000f2:	f3a58593          	addi	a1,a1,-198 # 80204028 <end>
    802000f6:	00001517          	auipc	a0,0x1
    802000fa:	a9250513          	addi	a0,a0,-1390 # 80200b88 <etext+0xaa>
    802000fe:	f71ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    80200102:	00004597          	auipc	a1,0x4
    80200106:	32558593          	addi	a1,a1,805 # 80204427 <end+0x3ff>
    8020010a:	00000797          	auipc	a5,0x0
    8020010e:	f0278793          	addi	a5,a5,-254 # 8020000c <kern_init>
    80200112:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200116:	43f7d593          	srai	a1,a5,0x3f
}
    8020011a:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020011c:	3ff5f593          	andi	a1,a1,1023
    80200120:	95be                	add	a1,a1,a5
    80200122:	85a9                	srai	a1,a1,0xa
    80200124:	00001517          	auipc	a0,0x1
    80200128:	a8450513          	addi	a0,a0,-1404 # 80200ba8 <etext+0xca>
}
    8020012c:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020012e:	f41ff06f          	j	8020006e <cprintf>

0000000080200132 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    80200132:	1141                	addi	sp,sp,-16
    80200134:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    80200136:	02000793          	li	a5,32
    8020013a:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    8020013e:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200142:	67e1                	lui	a5,0x18
    80200144:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    80200148:	953e                	add	a0,a0,a5
    8020014a:	125000ef          	jal	ra,80200a6e <sbi_set_timer>
}
    8020014e:	60a2                	ld	ra,8(sp)
    ticks = 0;
    80200150:	00004797          	auipc	a5,0x4
    80200154:	ec07b823          	sd	zero,-304(a5) # 80204020 <ticks>
    cprintf("++ setup timer interrupts\n");
    80200158:	00001517          	auipc	a0,0x1
    8020015c:	a8050513          	addi	a0,a0,-1408 # 80200bd8 <etext+0xfa>
}
    80200160:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    80200162:	f0dff06f          	j	8020006e <cprintf>

0000000080200166 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200166:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    8020016a:	67e1                	lui	a5,0x18
    8020016c:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    80200170:	953e                	add	a0,a0,a5
    80200172:	0fd0006f          	j	80200a6e <sbi_set_timer>

0000000080200176 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    80200176:	8082                	ret

0000000080200178 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    80200178:	0ff57513          	andi	a0,a0,255
    8020017c:	0d70006f          	j	80200a52 <sbi_console_putchar>

0000000080200180 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    80200180:	100167f3          	csrrsi	a5,sstatus,2
    80200184:	8082                	ret

0000000080200186 <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    80200186:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    8020018a:	00000797          	auipc	a5,0x0
    8020018e:	41a78793          	addi	a5,a5,1050 # 802005a4 <__alltraps>
    80200192:	10579073          	csrw	stvec,a5
}
    80200196:	8082                	ret

0000000080200198 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200198:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    8020019a:	1141                	addi	sp,sp,-16
    8020019c:	e022                	sd	s0,0(sp)
    8020019e:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a0:	00001517          	auipc	a0,0x1
    802001a4:	bc850513          	addi	a0,a0,-1080 # 80200d68 <etext+0x28a>
void print_regs(struct pushregs *gpr) {
    802001a8:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001aa:	ec5ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001ae:	640c                	ld	a1,8(s0)
    802001b0:	00001517          	auipc	a0,0x1
    802001b4:	bd050513          	addi	a0,a0,-1072 # 80200d80 <etext+0x2a2>
    802001b8:	eb7ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001bc:	680c                	ld	a1,16(s0)
    802001be:	00001517          	auipc	a0,0x1
    802001c2:	bda50513          	addi	a0,a0,-1062 # 80200d98 <etext+0x2ba>
    802001c6:	ea9ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001ca:	6c0c                	ld	a1,24(s0)
    802001cc:	00001517          	auipc	a0,0x1
    802001d0:	be450513          	addi	a0,a0,-1052 # 80200db0 <etext+0x2d2>
    802001d4:	e9bff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001d8:	700c                	ld	a1,32(s0)
    802001da:	00001517          	auipc	a0,0x1
    802001de:	bee50513          	addi	a0,a0,-1042 # 80200dc8 <etext+0x2ea>
    802001e2:	e8dff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001e6:	740c                	ld	a1,40(s0)
    802001e8:	00001517          	auipc	a0,0x1
    802001ec:	bf850513          	addi	a0,a0,-1032 # 80200de0 <etext+0x302>
    802001f0:	e7fff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001f4:	780c                	ld	a1,48(s0)
    802001f6:	00001517          	auipc	a0,0x1
    802001fa:	c0250513          	addi	a0,a0,-1022 # 80200df8 <etext+0x31a>
    802001fe:	e71ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    80200202:	7c0c                	ld	a1,56(s0)
    80200204:	00001517          	auipc	a0,0x1
    80200208:	c0c50513          	addi	a0,a0,-1012 # 80200e10 <etext+0x332>
    8020020c:	e63ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    80200210:	602c                	ld	a1,64(s0)
    80200212:	00001517          	auipc	a0,0x1
    80200216:	c1650513          	addi	a0,a0,-1002 # 80200e28 <etext+0x34a>
    8020021a:	e55ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    8020021e:	642c                	ld	a1,72(s0)
    80200220:	00001517          	auipc	a0,0x1
    80200224:	c2050513          	addi	a0,a0,-992 # 80200e40 <etext+0x362>
    80200228:	e47ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    8020022c:	682c                	ld	a1,80(s0)
    8020022e:	00001517          	auipc	a0,0x1
    80200232:	c2a50513          	addi	a0,a0,-982 # 80200e58 <etext+0x37a>
    80200236:	e39ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    8020023a:	6c2c                	ld	a1,88(s0)
    8020023c:	00001517          	auipc	a0,0x1
    80200240:	c3450513          	addi	a0,a0,-972 # 80200e70 <etext+0x392>
    80200244:	e2bff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    80200248:	702c                	ld	a1,96(s0)
    8020024a:	00001517          	auipc	a0,0x1
    8020024e:	c3e50513          	addi	a0,a0,-962 # 80200e88 <etext+0x3aa>
    80200252:	e1dff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    80200256:	742c                	ld	a1,104(s0)
    80200258:	00001517          	auipc	a0,0x1
    8020025c:	c4850513          	addi	a0,a0,-952 # 80200ea0 <etext+0x3c2>
    80200260:	e0fff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    80200264:	782c                	ld	a1,112(s0)
    80200266:	00001517          	auipc	a0,0x1
    8020026a:	c5250513          	addi	a0,a0,-942 # 80200eb8 <etext+0x3da>
    8020026e:	e01ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    80200272:	7c2c                	ld	a1,120(s0)
    80200274:	00001517          	auipc	a0,0x1
    80200278:	c5c50513          	addi	a0,a0,-932 # 80200ed0 <etext+0x3f2>
    8020027c:	df3ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    80200280:	604c                	ld	a1,128(s0)
    80200282:	00001517          	auipc	a0,0x1
    80200286:	c6650513          	addi	a0,a0,-922 # 80200ee8 <etext+0x40a>
    8020028a:	de5ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    8020028e:	644c                	ld	a1,136(s0)
    80200290:	00001517          	auipc	a0,0x1
    80200294:	c7050513          	addi	a0,a0,-912 # 80200f00 <etext+0x422>
    80200298:	dd7ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    8020029c:	684c                	ld	a1,144(s0)
    8020029e:	00001517          	auipc	a0,0x1
    802002a2:	c7a50513          	addi	a0,a0,-902 # 80200f18 <etext+0x43a>
    802002a6:	dc9ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002aa:	6c4c                	ld	a1,152(s0)
    802002ac:	00001517          	auipc	a0,0x1
    802002b0:	c8450513          	addi	a0,a0,-892 # 80200f30 <etext+0x452>
    802002b4:	dbbff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002b8:	704c                	ld	a1,160(s0)
    802002ba:	00001517          	auipc	a0,0x1
    802002be:	c8e50513          	addi	a0,a0,-882 # 80200f48 <etext+0x46a>
    802002c2:	dadff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002c6:	744c                	ld	a1,168(s0)
    802002c8:	00001517          	auipc	a0,0x1
    802002cc:	c9850513          	addi	a0,a0,-872 # 80200f60 <etext+0x482>
    802002d0:	d9fff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002d4:	784c                	ld	a1,176(s0)
    802002d6:	00001517          	auipc	a0,0x1
    802002da:	ca250513          	addi	a0,a0,-862 # 80200f78 <etext+0x49a>
    802002de:	d91ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002e2:	7c4c                	ld	a1,184(s0)
    802002e4:	00001517          	auipc	a0,0x1
    802002e8:	cac50513          	addi	a0,a0,-852 # 80200f90 <etext+0x4b2>
    802002ec:	d83ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002f0:	606c                	ld	a1,192(s0)
    802002f2:	00001517          	auipc	a0,0x1
    802002f6:	cb650513          	addi	a0,a0,-842 # 80200fa8 <etext+0x4ca>
    802002fa:	d75ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    802002fe:	646c                	ld	a1,200(s0)
    80200300:	00001517          	auipc	a0,0x1
    80200304:	cc050513          	addi	a0,a0,-832 # 80200fc0 <etext+0x4e2>
    80200308:	d67ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    8020030c:	686c                	ld	a1,208(s0)
    8020030e:	00001517          	auipc	a0,0x1
    80200312:	cca50513          	addi	a0,a0,-822 # 80200fd8 <etext+0x4fa>
    80200316:	d59ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    8020031a:	6c6c                	ld	a1,216(s0)
    8020031c:	00001517          	auipc	a0,0x1
    80200320:	cd450513          	addi	a0,a0,-812 # 80200ff0 <etext+0x512>
    80200324:	d4bff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    80200328:	706c                	ld	a1,224(s0)
    8020032a:	00001517          	auipc	a0,0x1
    8020032e:	cde50513          	addi	a0,a0,-802 # 80201008 <etext+0x52a>
    80200332:	d3dff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    80200336:	746c                	ld	a1,232(s0)
    80200338:	00001517          	auipc	a0,0x1
    8020033c:	ce850513          	addi	a0,a0,-792 # 80201020 <etext+0x542>
    80200340:	d2fff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    80200344:	786c                	ld	a1,240(s0)
    80200346:	00001517          	auipc	a0,0x1
    8020034a:	cf250513          	addi	a0,a0,-782 # 80201038 <etext+0x55a>
    8020034e:	d21ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200352:	7c6c                	ld	a1,248(s0)
}
    80200354:	6402                	ld	s0,0(sp)
    80200356:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200358:	00001517          	auipc	a0,0x1
    8020035c:	cf850513          	addi	a0,a0,-776 # 80201050 <etext+0x572>
}
    80200360:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200362:	d0dff06f          	j	8020006e <cprintf>

0000000080200366 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    80200366:	1141                	addi	sp,sp,-16
    80200368:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    8020036a:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    8020036c:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    8020036e:	00001517          	auipc	a0,0x1
    80200372:	cfa50513          	addi	a0,a0,-774 # 80201068 <etext+0x58a>
void print_trapframe(struct trapframe *tf) {
    80200376:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    80200378:	cf7ff0ef          	jal	ra,8020006e <cprintf>
    print_regs(&tf->gpr);
    8020037c:	8522                	mv	a0,s0
    8020037e:	e1bff0ef          	jal	ra,80200198 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    80200382:	10043583          	ld	a1,256(s0)
    80200386:	00001517          	auipc	a0,0x1
    8020038a:	cfa50513          	addi	a0,a0,-774 # 80201080 <etext+0x5a2>
    8020038e:	ce1ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    80200392:	10843583          	ld	a1,264(s0)
    80200396:	00001517          	auipc	a0,0x1
    8020039a:	d0250513          	addi	a0,a0,-766 # 80201098 <etext+0x5ba>
    8020039e:	cd1ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    802003a2:	11043583          	ld	a1,272(s0)
    802003a6:	00001517          	auipc	a0,0x1
    802003aa:	d0a50513          	addi	a0,a0,-758 # 802010b0 <etext+0x5d2>
    802003ae:	cc1ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b2:	11843583          	ld	a1,280(s0)
}
    802003b6:	6402                	ld	s0,0(sp)
    802003b8:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003ba:	00001517          	auipc	a0,0x1
    802003be:	d0e50513          	addi	a0,a0,-754 # 802010c8 <etext+0x5ea>
}
    802003c2:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003c4:	cabff06f          	j	8020006e <cprintf>

00000000802003c8 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003c8:	11853783          	ld	a5,280(a0)
    802003cc:	577d                	li	a4,-1
    802003ce:	8305                	srli	a4,a4,0x1
    802003d0:	8ff9                	and	a5,a5,a4
    switch (cause) {
    802003d2:	472d                	li	a4,11
    802003d4:	08f76963          	bltu	a4,a5,80200466 <interrupt_handler+0x9e>
    802003d8:	00001717          	auipc	a4,0x1
    802003dc:	81c70713          	addi	a4,a4,-2020 # 80200bf4 <etext+0x116>
    802003e0:	078a                	slli	a5,a5,0x2
    802003e2:	97ba                	add	a5,a5,a4
    802003e4:	439c                	lw	a5,0(a5)
    802003e6:	97ba                	add	a5,a5,a4
    802003e8:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003ea:	00001517          	auipc	a0,0x1
    802003ee:	92e50513          	addi	a0,a0,-1746 # 80200d18 <etext+0x23a>
    802003f2:	c7dff06f          	j	8020006e <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003f6:	00001517          	auipc	a0,0x1
    802003fa:	90250513          	addi	a0,a0,-1790 # 80200cf8 <etext+0x21a>
    802003fe:	c71ff06f          	j	8020006e <cprintf>
            cprintf("User software interrupt\n");
    80200402:	00001517          	auipc	a0,0x1
    80200406:	8b650513          	addi	a0,a0,-1866 # 80200cb8 <etext+0x1da>
    8020040a:	c65ff06f          	j	8020006e <cprintf>
            cprintf("Supervisor software interrupt\n");
    8020040e:	00001517          	auipc	a0,0x1
    80200412:	8ca50513          	addi	a0,a0,-1846 # 80200cd8 <etext+0x1fa>
    80200416:	c59ff06f          	j	8020006e <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
    8020041a:	00001517          	auipc	a0,0x1
    8020041e:	92e50513          	addi	a0,a0,-1746 # 80200d48 <etext+0x26a>
    80200422:	c4dff06f          	j	8020006e <cprintf>
void interrupt_handler(struct trapframe *tf) {
    80200426:	1141                	addi	sp,sp,-16
    80200428:	e022                	sd	s0,0(sp)
    8020042a:	e406                	sd	ra,8(sp)
            clock_set_next_event();
    8020042c:	d3bff0ef          	jal	ra,80200166 <clock_set_next_event>
            ticks++;
    80200430:	00004717          	auipc	a4,0x4
    80200434:	bf070713          	addi	a4,a4,-1040 # 80204020 <ticks>
    80200438:	631c                	ld	a5,0(a4)
            if(TICK_NUM==ticks){
    8020043a:	06400693          	li	a3,100
    8020043e:	00004417          	auipc	s0,0x4
    80200442:	bd240413          	addi	s0,s0,-1070 # 80204010 <edata>
            ticks++;
    80200446:	0785                	addi	a5,a5,1
    80200448:	00004617          	auipc	a2,0x4
    8020044c:	bcf63c23          	sd	a5,-1064(a2) # 80204020 <ticks>
            if(TICK_NUM==ticks){
    80200450:	631c                	ld	a5,0(a4)
    80200452:	00d78c63          	beq	a5,a3,8020046a <interrupt_handler+0xa2>
            if(num==10){
    80200456:	6018                	ld	a4,0(s0)
    80200458:	47a9                	li	a5,10
    8020045a:	02f70b63          	beq	a4,a5,80200490 <interrupt_handler+0xc8>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    8020045e:	60a2                	ld	ra,8(sp)
    80200460:	6402                	ld	s0,0(sp)
    80200462:	0141                	addi	sp,sp,16
    80200464:	8082                	ret
            print_trapframe(tf);
    80200466:	f01ff06f          	j	80200366 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
    8020046a:	06400593          	li	a1,100
    8020046e:	00001517          	auipc	a0,0x1
    80200472:	8ca50513          	addi	a0,a0,-1846 # 80200d38 <etext+0x25a>
            ticks=0;
    80200476:	00004797          	auipc	a5,0x4
    8020047a:	ba07b523          	sd	zero,-1110(a5) # 80204020 <ticks>
    cprintf("%d ticks\n", TICK_NUM);
    8020047e:	bf1ff0ef          	jal	ra,8020006e <cprintf>
            num++;
    80200482:	601c                	ld	a5,0(s0)
    80200484:	0785                	addi	a5,a5,1
    80200486:	00004717          	auipc	a4,0x4
    8020048a:	b8f73523          	sd	a5,-1142(a4) # 80204010 <edata>
    8020048e:	b7e1                	j	80200456 <interrupt_handler+0x8e>
}
    80200490:	6402                	ld	s0,0(sp)
    80200492:	60a2                	ld	ra,8(sp)
    80200494:	0141                	addi	sp,sp,16
            sbi_shutdown();
    80200496:	5f40006f          	j	80200a8a <sbi_shutdown>

000000008020049a <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    8020049a:	11853783          	ld	a5,280(a0)
    8020049e:	472d                	li	a4,11
    802004a0:	02f76863          	bltu	a4,a5,802004d0 <exception_handler+0x36>
    802004a4:	4705                	li	a4,1
    802004a6:	00f71733          	sll	a4,a4,a5
    802004aa:	6785                	lui	a5,0x1
    802004ac:	17cd                	addi	a5,a5,-13
    802004ae:	8ff9                	and	a5,a5,a4
    802004b0:	ef99                	bnez	a5,802004ce <exception_handler+0x34>
void exception_handler(struct trapframe *tf) {
    802004b2:	1141                	addi	sp,sp,-16
    802004b4:	e022                	sd	s0,0(sp)
    802004b6:	e406                	sd	ra,8(sp)
    802004b8:	00877793          	andi	a5,a4,8
    802004bc:	842a                	mv	s0,a0
    802004be:	e3b1                	bnez	a5,80200502 <exception_handler+0x68>
    802004c0:	8b11                	andi	a4,a4,4
    802004c2:	eb09                	bnez	a4,802004d4 <exception_handler+0x3a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    802004c4:	6402                	ld	s0,0(sp)
    802004c6:	60a2                	ld	ra,8(sp)
    802004c8:	0141                	addi	sp,sp,16
            print_trapframe(tf);
    802004ca:	e9dff06f          	j	80200366 <print_trapframe>
    802004ce:	8082                	ret
    802004d0:	e97ff06f          	j	80200366 <print_trapframe>
            cprintf("Exception type: Illegal instruction\n"); 
    802004d4:	00000517          	auipc	a0,0x0
    802004d8:	75450513          	addi	a0,a0,1876 # 80200c28 <etext+0x14a>
    802004dc:	b93ff0ef          	jal	ra,8020006e <cprintf>
             cprintf("Illegal instruction caught at 0x%08x\n", tf->epc);
    802004e0:	10843583          	ld	a1,264(s0)
    802004e4:	00000517          	auipc	a0,0x0
    802004e8:	76c50513          	addi	a0,a0,1900 # 80200c50 <etext+0x172>
    802004ec:	b83ff0ef          	jal	ra,8020006e <cprintf>
            tf->epc += 4;/* LAB1 CHALLENGE3   YOUR CODE 2112849 :  */
    802004f0:	10843783          	ld	a5,264(s0)
}
    802004f4:	60a2                	ld	ra,8(sp)
            tf->epc += 4;/* LAB1 CHALLENGE3   YOUR CODE 2112849 :  */
    802004f6:	0791                	addi	a5,a5,4
    802004f8:	10f43423          	sd	a5,264(s0)
}
    802004fc:	6402                	ld	s0,0(sp)
    802004fe:	0141                	addi	sp,sp,16
    80200500:	8082                	ret
            cprintf("Exception type: breakpoint\n");
    80200502:	00000517          	auipc	a0,0x0
    80200506:	77650513          	addi	a0,a0,1910 # 80200c78 <etext+0x19a>
    8020050a:	b65ff0ef          	jal	ra,8020006e <cprintf>
            cprintf("ebreak caught at 0x%08x\n", tf->epc);
    8020050e:	10843583          	ld	a1,264(s0)
}
    80200512:	6402                	ld	s0,0(sp)
    80200514:	60a2                	ld	ra,8(sp)
            cprintf("ebreak caught at 0x%08x\n", tf->epc);
    80200516:	00000517          	auipc	a0,0x0
    8020051a:	78250513          	addi	a0,a0,1922 # 80200c98 <etext+0x1ba>
}
    8020051e:	0141                	addi	sp,sp,16
            cprintf("ebreak caught at 0x%08x\n", tf->epc);
    80200520:	b4fff06f          	j	8020006e <cprintf>

0000000080200524 <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    80200524:	11853783          	ld	a5,280(a0)
 * trap - handles or dispatches an exception/interrupt. if and when trap()
 * returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) { 
    80200528:	1141                	addi	sp,sp,-16
    8020052a:	e406                	sd	ra,8(sp)
    8020052c:	e022                	sd	s0,0(sp)
    if ((intptr_t)tf->cause < 0) {
    8020052e:	0207cf63          	bltz	a5,8020056c <trap+0x48>
        exception_handler(tf);
    80200532:	f69ff0ef          	jal	ra,8020049a <exception_handler>
trap_dispatch(tf);
ticks++;
    80200536:	00004717          	auipc	a4,0x4
    8020053a:	aea70713          	addi	a4,a4,-1302 # 80204020 <ticks>
    8020053e:	631c                	ld	a5,0(a4)
if(TICK_NUM==ticks){
    80200540:	06400693          	li	a3,100
    80200544:	00004417          	auipc	s0,0x4
    80200548:	acc40413          	addi	s0,s0,-1332 # 80204010 <edata>
ticks++;
    8020054c:	0785                	addi	a5,a5,1
    8020054e:	00004617          	auipc	a2,0x4
    80200552:	acf63923          	sd	a5,-1326(a2) # 80204020 <ticks>
if(TICK_NUM==ticks){
    80200556:	631c                	ld	a5,0(a4)
    80200558:	02d78263          	beq	a5,a3,8020057c <trap+0x58>
num++;


}

if(num==10){
    8020055c:	6018                	ld	a4,0(s0)
    8020055e:	47a9                	li	a5,10
    80200560:	00f70963          	beq	a4,a5,80200572 <trap+0x4e>
sbi_shutdown();
}

 }
    80200564:	60a2                	ld	ra,8(sp)
    80200566:	6402                	ld	s0,0(sp)
    80200568:	0141                	addi	sp,sp,16
    8020056a:	8082                	ret
        interrupt_handler(tf);
    8020056c:	e5dff0ef          	jal	ra,802003c8 <interrupt_handler>
    80200570:	b7d9                	j	80200536 <trap+0x12>
 }
    80200572:	6402                	ld	s0,0(sp)
    80200574:	60a2                	ld	ra,8(sp)
    80200576:	0141                	addi	sp,sp,16
sbi_shutdown();
    80200578:	5120006f          	j	80200a8a <sbi_shutdown>
    cprintf("%d ticks\n", TICK_NUM);
    8020057c:	06400593          	li	a1,100
    80200580:	00000517          	auipc	a0,0x0
    80200584:	7b850513          	addi	a0,a0,1976 # 80200d38 <etext+0x25a>
ticks=0;
    80200588:	00004797          	auipc	a5,0x4
    8020058c:	a807bc23          	sd	zero,-1384(a5) # 80204020 <ticks>
    cprintf("%d ticks\n", TICK_NUM);
    80200590:	adfff0ef          	jal	ra,8020006e <cprintf>
num++;
    80200594:	601c                	ld	a5,0(s0)
    80200596:	0785                	addi	a5,a5,1
    80200598:	00004717          	auipc	a4,0x4
    8020059c:	a6f73c23          	sd	a5,-1416(a4) # 80204010 <edata>
    802005a0:	bf75                	j	8020055c <trap+0x38>
	...

00000000802005a4 <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    802005a4:	14011073          	csrw	sscratch,sp
    802005a8:	712d                	addi	sp,sp,-288
    802005aa:	e002                	sd	zero,0(sp)
    802005ac:	e406                	sd	ra,8(sp)
    802005ae:	ec0e                	sd	gp,24(sp)
    802005b0:	f012                	sd	tp,32(sp)
    802005b2:	f416                	sd	t0,40(sp)
    802005b4:	f81a                	sd	t1,48(sp)
    802005b6:	fc1e                	sd	t2,56(sp)
    802005b8:	e0a2                	sd	s0,64(sp)
    802005ba:	e4a6                	sd	s1,72(sp)
    802005bc:	e8aa                	sd	a0,80(sp)
    802005be:	ecae                	sd	a1,88(sp)
    802005c0:	f0b2                	sd	a2,96(sp)
    802005c2:	f4b6                	sd	a3,104(sp)
    802005c4:	f8ba                	sd	a4,112(sp)
    802005c6:	fcbe                	sd	a5,120(sp)
    802005c8:	e142                	sd	a6,128(sp)
    802005ca:	e546                	sd	a7,136(sp)
    802005cc:	e94a                	sd	s2,144(sp)
    802005ce:	ed4e                	sd	s3,152(sp)
    802005d0:	f152                	sd	s4,160(sp)
    802005d2:	f556                	sd	s5,168(sp)
    802005d4:	f95a                	sd	s6,176(sp)
    802005d6:	fd5e                	sd	s7,184(sp)
    802005d8:	e1e2                	sd	s8,192(sp)
    802005da:	e5e6                	sd	s9,200(sp)
    802005dc:	e9ea                	sd	s10,208(sp)
    802005de:	edee                	sd	s11,216(sp)
    802005e0:	f1f2                	sd	t3,224(sp)
    802005e2:	f5f6                	sd	t4,232(sp)
    802005e4:	f9fa                	sd	t5,240(sp)
    802005e6:	fdfe                	sd	t6,248(sp)
    802005e8:	14001473          	csrrw	s0,sscratch,zero
    802005ec:	100024f3          	csrr	s1,sstatus
    802005f0:	14102973          	csrr	s2,sepc
    802005f4:	143029f3          	csrr	s3,stval
    802005f8:	14202a73          	csrr	s4,scause
    802005fc:	e822                	sd	s0,16(sp)
    802005fe:	e226                	sd	s1,256(sp)
    80200600:	e64a                	sd	s2,264(sp)
    80200602:	ea4e                	sd	s3,272(sp)
    80200604:	ee52                	sd	s4,280(sp)

    move  a0, sp
    80200606:	850a                	mv	a0,sp
    jal trap
    80200608:	f1dff0ef          	jal	ra,80200524 <trap>

000000008020060c <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    8020060c:	6492                	ld	s1,256(sp)
    8020060e:	6932                	ld	s2,264(sp)
    80200610:	10049073          	csrw	sstatus,s1
    80200614:	14191073          	csrw	sepc,s2
    80200618:	60a2                	ld	ra,8(sp)
    8020061a:	61e2                	ld	gp,24(sp)
    8020061c:	7202                	ld	tp,32(sp)
    8020061e:	72a2                	ld	t0,40(sp)
    80200620:	7342                	ld	t1,48(sp)
    80200622:	73e2                	ld	t2,56(sp)
    80200624:	6406                	ld	s0,64(sp)
    80200626:	64a6                	ld	s1,72(sp)
    80200628:	6546                	ld	a0,80(sp)
    8020062a:	65e6                	ld	a1,88(sp)
    8020062c:	7606                	ld	a2,96(sp)
    8020062e:	76a6                	ld	a3,104(sp)
    80200630:	7746                	ld	a4,112(sp)
    80200632:	77e6                	ld	a5,120(sp)
    80200634:	680a                	ld	a6,128(sp)
    80200636:	68aa                	ld	a7,136(sp)
    80200638:	694a                	ld	s2,144(sp)
    8020063a:	69ea                	ld	s3,152(sp)
    8020063c:	7a0a                	ld	s4,160(sp)
    8020063e:	7aaa                	ld	s5,168(sp)
    80200640:	7b4a                	ld	s6,176(sp)
    80200642:	7bea                	ld	s7,184(sp)
    80200644:	6c0e                	ld	s8,192(sp)
    80200646:	6cae                	ld	s9,200(sp)
    80200648:	6d4e                	ld	s10,208(sp)
    8020064a:	6dee                	ld	s11,216(sp)
    8020064c:	7e0e                	ld	t3,224(sp)
    8020064e:	7eae                	ld	t4,232(sp)
    80200650:	7f4e                	ld	t5,240(sp)
    80200652:	7fee                	ld	t6,248(sp)
    80200654:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    80200656:	10200073          	sret

000000008020065a <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    8020065a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    8020065e:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    80200660:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    80200664:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    80200666:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    8020066a:	f022                	sd	s0,32(sp)
    8020066c:	ec26                	sd	s1,24(sp)
    8020066e:	e84a                	sd	s2,16(sp)
    80200670:	f406                	sd	ra,40(sp)
    80200672:	e44e                	sd	s3,8(sp)
    80200674:	84aa                	mv	s1,a0
    80200676:	892e                	mv	s2,a1
    80200678:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    8020067c:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
    8020067e:	03067e63          	bleu	a6,a2,802006ba <printnum+0x60>
    80200682:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    80200684:	00805763          	blez	s0,80200692 <printnum+0x38>
    80200688:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    8020068a:	85ca                	mv	a1,s2
    8020068c:	854e                	mv	a0,s3
    8020068e:	9482                	jalr	s1
        while (-- width > 0)
    80200690:	fc65                	bnez	s0,80200688 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    80200692:	1a02                	slli	s4,s4,0x20
    80200694:	020a5a13          	srli	s4,s4,0x20
    80200698:	00001797          	auipc	a5,0x1
    8020069c:	bd878793          	addi	a5,a5,-1064 # 80201270 <error_string+0x38>
    802006a0:	9a3e                	add	s4,s4,a5
}
    802006a2:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    802006a4:	000a4503          	lbu	a0,0(s4)
}
    802006a8:	70a2                	ld	ra,40(sp)
    802006aa:	69a2                	ld	s3,8(sp)
    802006ac:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    802006ae:	85ca                	mv	a1,s2
    802006b0:	8326                	mv	t1,s1
}
    802006b2:	6942                	ld	s2,16(sp)
    802006b4:	64e2                	ld	s1,24(sp)
    802006b6:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    802006b8:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
    802006ba:	03065633          	divu	a2,a2,a6
    802006be:	8722                	mv	a4,s0
    802006c0:	f9bff0ef          	jal	ra,8020065a <printnum>
    802006c4:	b7f9                	j	80200692 <printnum+0x38>

00000000802006c6 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    802006c6:	7119                	addi	sp,sp,-128
    802006c8:	f4a6                	sd	s1,104(sp)
    802006ca:	f0ca                	sd	s2,96(sp)
    802006cc:	e8d2                	sd	s4,80(sp)
    802006ce:	e4d6                	sd	s5,72(sp)
    802006d0:	e0da                	sd	s6,64(sp)
    802006d2:	fc5e                	sd	s7,56(sp)
    802006d4:	f862                	sd	s8,48(sp)
    802006d6:	f06a                	sd	s10,32(sp)
    802006d8:	fc86                	sd	ra,120(sp)
    802006da:	f8a2                	sd	s0,112(sp)
    802006dc:	ecce                	sd	s3,88(sp)
    802006de:	f466                	sd	s9,40(sp)
    802006e0:	ec6e                	sd	s11,24(sp)
    802006e2:	892a                	mv	s2,a0
    802006e4:	84ae                	mv	s1,a1
    802006e6:	8d32                	mv	s10,a2
    802006e8:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    802006ea:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
    802006ec:	00001a17          	auipc	s4,0x1
    802006f0:	9f0a0a13          	addi	s4,s4,-1552 # 802010dc <etext+0x5fe>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
    802006f4:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802006f8:	00001c17          	auipc	s8,0x1
    802006fc:	b40c0c13          	addi	s8,s8,-1216 # 80201238 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200700:	000d4503          	lbu	a0,0(s10)
    80200704:	02500793          	li	a5,37
    80200708:	001d0413          	addi	s0,s10,1
    8020070c:	00f50e63          	beq	a0,a5,80200728 <vprintfmt+0x62>
            if (ch == '\0') {
    80200710:	c521                	beqz	a0,80200758 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200712:	02500993          	li	s3,37
    80200716:	a011                	j	8020071a <vprintfmt+0x54>
            if (ch == '\0') {
    80200718:	c121                	beqz	a0,80200758 <vprintfmt+0x92>
            putch(ch, putdat);
    8020071a:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    8020071c:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    8020071e:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200720:	fff44503          	lbu	a0,-1(s0)
    80200724:	ff351ae3          	bne	a0,s3,80200718 <vprintfmt+0x52>
    80200728:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    8020072c:	02000793          	li	a5,32
        lflag = altflag = 0;
    80200730:	4981                	li	s3,0
    80200732:	4801                	li	a6,0
        width = precision = -1;
    80200734:	5cfd                	li	s9,-1
    80200736:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
    80200738:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
    8020073c:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
    8020073e:	fdd6069b          	addiw	a3,a2,-35
    80200742:	0ff6f693          	andi	a3,a3,255
    80200746:	00140d13          	addi	s10,s0,1
    8020074a:	20d5e563          	bltu	a1,a3,80200954 <vprintfmt+0x28e>
    8020074e:	068a                	slli	a3,a3,0x2
    80200750:	96d2                	add	a3,a3,s4
    80200752:	4294                	lw	a3,0(a3)
    80200754:	96d2                	add	a3,a3,s4
    80200756:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    80200758:	70e6                	ld	ra,120(sp)
    8020075a:	7446                	ld	s0,112(sp)
    8020075c:	74a6                	ld	s1,104(sp)
    8020075e:	7906                	ld	s2,96(sp)
    80200760:	69e6                	ld	s3,88(sp)
    80200762:	6a46                	ld	s4,80(sp)
    80200764:	6aa6                	ld	s5,72(sp)
    80200766:	6b06                	ld	s6,64(sp)
    80200768:	7be2                	ld	s7,56(sp)
    8020076a:	7c42                	ld	s8,48(sp)
    8020076c:	7ca2                	ld	s9,40(sp)
    8020076e:	7d02                	ld	s10,32(sp)
    80200770:	6de2                	ld	s11,24(sp)
    80200772:	6109                	addi	sp,sp,128
    80200774:	8082                	ret
    if (lflag >= 2) {
    80200776:	4705                	li	a4,1
    80200778:	008a8593          	addi	a1,s5,8
    8020077c:	01074463          	blt	a4,a6,80200784 <vprintfmt+0xbe>
    else if (lflag) {
    80200780:	26080363          	beqz	a6,802009e6 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
    80200784:	000ab603          	ld	a2,0(s5)
    80200788:	46c1                	li	a3,16
    8020078a:	8aae                	mv	s5,a1
    8020078c:	a06d                	j	80200836 <vprintfmt+0x170>
            goto reswitch;
    8020078e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    80200792:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200794:	846a                	mv	s0,s10
            goto reswitch;
    80200796:	b765                	j	8020073e <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
    80200798:	000aa503          	lw	a0,0(s5)
    8020079c:	85a6                	mv	a1,s1
    8020079e:	0aa1                	addi	s5,s5,8
    802007a0:	9902                	jalr	s2
            break;
    802007a2:	bfb9                	j	80200700 <vprintfmt+0x3a>
    if (lflag >= 2) {
    802007a4:	4705                	li	a4,1
    802007a6:	008a8993          	addi	s3,s5,8
    802007aa:	01074463          	blt	a4,a6,802007b2 <vprintfmt+0xec>
    else if (lflag) {
    802007ae:	22080463          	beqz	a6,802009d6 <vprintfmt+0x310>
        return va_arg(*ap, long);
    802007b2:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
    802007b6:	24044463          	bltz	s0,802009fe <vprintfmt+0x338>
            num = getint(&ap, lflag);
    802007ba:	8622                	mv	a2,s0
    802007bc:	8ace                	mv	s5,s3
    802007be:	46a9                	li	a3,10
    802007c0:	a89d                	j	80200836 <vprintfmt+0x170>
            err = va_arg(ap, int);
    802007c2:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802007c6:	4719                	li	a4,6
            err = va_arg(ap, int);
    802007c8:	0aa1                	addi	s5,s5,8
            if (err < 0) {
    802007ca:	41f7d69b          	sraiw	a3,a5,0x1f
    802007ce:	8fb5                	xor	a5,a5,a3
    802007d0:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802007d4:	1ad74363          	blt	a4,a3,8020097a <vprintfmt+0x2b4>
    802007d8:	00369793          	slli	a5,a3,0x3
    802007dc:	97e2                	add	a5,a5,s8
    802007de:	639c                	ld	a5,0(a5)
    802007e0:	18078d63          	beqz	a5,8020097a <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
    802007e4:	86be                	mv	a3,a5
    802007e6:	00001617          	auipc	a2,0x1
    802007ea:	b3a60613          	addi	a2,a2,-1222 # 80201320 <error_string+0xe8>
    802007ee:	85a6                	mv	a1,s1
    802007f0:	854a                	mv	a0,s2
    802007f2:	240000ef          	jal	ra,80200a32 <printfmt>
    802007f6:	b729                	j	80200700 <vprintfmt+0x3a>
            lflag ++;
    802007f8:	00144603          	lbu	a2,1(s0)
    802007fc:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
    802007fe:	846a                	mv	s0,s10
            goto reswitch;
    80200800:	bf3d                	j	8020073e <vprintfmt+0x78>
    if (lflag >= 2) {
    80200802:	4705                	li	a4,1
    80200804:	008a8593          	addi	a1,s5,8
    80200808:	01074463          	blt	a4,a6,80200810 <vprintfmt+0x14a>
    else if (lflag) {
    8020080c:	1e080263          	beqz	a6,802009f0 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
    80200810:	000ab603          	ld	a2,0(s5)
    80200814:	46a1                	li	a3,8
    80200816:	8aae                	mv	s5,a1
    80200818:	a839                	j	80200836 <vprintfmt+0x170>
            putch('0', putdat);
    8020081a:	03000513          	li	a0,48
    8020081e:	85a6                	mv	a1,s1
    80200820:	e03e                	sd	a5,0(sp)
    80200822:	9902                	jalr	s2
            putch('x', putdat);
    80200824:	85a6                	mv	a1,s1
    80200826:	07800513          	li	a0,120
    8020082a:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    8020082c:	0aa1                	addi	s5,s5,8
    8020082e:	ff8ab603          	ld	a2,-8(s5)
            goto number;
    80200832:	6782                	ld	a5,0(sp)
    80200834:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
    80200836:	876e                	mv	a4,s11
    80200838:	85a6                	mv	a1,s1
    8020083a:	854a                	mv	a0,s2
    8020083c:	e1fff0ef          	jal	ra,8020065a <printnum>
            break;
    80200840:	b5c1                	j	80200700 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
    80200842:	000ab603          	ld	a2,0(s5)
    80200846:	0aa1                	addi	s5,s5,8
    80200848:	1c060663          	beqz	a2,80200a14 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
    8020084c:	00160413          	addi	s0,a2,1
    80200850:	17b05c63          	blez	s11,802009c8 <vprintfmt+0x302>
    80200854:	02d00593          	li	a1,45
    80200858:	14b79263          	bne	a5,a1,8020099c <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020085c:	00064783          	lbu	a5,0(a2)
    80200860:	0007851b          	sext.w	a0,a5
    80200864:	c905                	beqz	a0,80200894 <vprintfmt+0x1ce>
    80200866:	000cc563          	bltz	s9,80200870 <vprintfmt+0x1aa>
    8020086a:	3cfd                	addiw	s9,s9,-1
    8020086c:	036c8263          	beq	s9,s6,80200890 <vprintfmt+0x1ca>
                    putch('?', putdat);
    80200870:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200872:	18098463          	beqz	s3,802009fa <vprintfmt+0x334>
    80200876:	3781                	addiw	a5,a5,-32
    80200878:	18fbf163          	bleu	a5,s7,802009fa <vprintfmt+0x334>
                    putch('?', putdat);
    8020087c:	03f00513          	li	a0,63
    80200880:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200882:	0405                	addi	s0,s0,1
    80200884:	fff44783          	lbu	a5,-1(s0)
    80200888:	3dfd                	addiw	s11,s11,-1
    8020088a:	0007851b          	sext.w	a0,a5
    8020088e:	fd61                	bnez	a0,80200866 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
    80200890:	e7b058e3          	blez	s11,80200700 <vprintfmt+0x3a>
    80200894:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    80200896:	85a6                	mv	a1,s1
    80200898:	02000513          	li	a0,32
    8020089c:	9902                	jalr	s2
            for (; width > 0; width --) {
    8020089e:	e60d81e3          	beqz	s11,80200700 <vprintfmt+0x3a>
    802008a2:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    802008a4:	85a6                	mv	a1,s1
    802008a6:	02000513          	li	a0,32
    802008aa:	9902                	jalr	s2
            for (; width > 0; width --) {
    802008ac:	fe0d94e3          	bnez	s11,80200894 <vprintfmt+0x1ce>
    802008b0:	bd81                	j	80200700 <vprintfmt+0x3a>
    if (lflag >= 2) {
    802008b2:	4705                	li	a4,1
    802008b4:	008a8593          	addi	a1,s5,8
    802008b8:	01074463          	blt	a4,a6,802008c0 <vprintfmt+0x1fa>
    else if (lflag) {
    802008bc:	12080063          	beqz	a6,802009dc <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
    802008c0:	000ab603          	ld	a2,0(s5)
    802008c4:	46a9                	li	a3,10
    802008c6:	8aae                	mv	s5,a1
    802008c8:	b7bd                	j	80200836 <vprintfmt+0x170>
    802008ca:	00144603          	lbu	a2,1(s0)
            padc = '-';
    802008ce:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
    802008d2:	846a                	mv	s0,s10
    802008d4:	b5ad                	j	8020073e <vprintfmt+0x78>
            putch(ch, putdat);
    802008d6:	85a6                	mv	a1,s1
    802008d8:	02500513          	li	a0,37
    802008dc:	9902                	jalr	s2
            break;
    802008de:	b50d                	j	80200700 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
    802008e0:	000aac83          	lw	s9,0(s5)
            goto process_precision;
    802008e4:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    802008e8:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
    802008ea:	846a                	mv	s0,s10
            if (width < 0)
    802008ec:	e40dd9e3          	bgez	s11,8020073e <vprintfmt+0x78>
                width = precision, precision = -1;
    802008f0:	8de6                	mv	s11,s9
    802008f2:	5cfd                	li	s9,-1
    802008f4:	b5a9                	j	8020073e <vprintfmt+0x78>
            goto reswitch;
    802008f6:	00144603          	lbu	a2,1(s0)
            padc = '0';
    802008fa:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
    802008fe:	846a                	mv	s0,s10
            goto reswitch;
    80200900:	bd3d                	j	8020073e <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
    80200902:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
    80200906:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    8020090a:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    8020090c:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    80200910:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    80200914:	fcd56ce3          	bltu	a0,a3,802008ec <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
    80200918:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    8020091a:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
    8020091e:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
    80200922:	0196873b          	addw	a4,a3,s9
    80200926:	0017171b          	slliw	a4,a4,0x1
    8020092a:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
    8020092e:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
    80200932:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
    80200936:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    8020093a:	fcd57fe3          	bleu	a3,a0,80200918 <vprintfmt+0x252>
    8020093e:	b77d                	j	802008ec <vprintfmt+0x226>
            if (width < 0)
    80200940:	fffdc693          	not	a3,s11
    80200944:	96fd                	srai	a3,a3,0x3f
    80200946:	00ddfdb3          	and	s11,s11,a3
    8020094a:	00144603          	lbu	a2,1(s0)
    8020094e:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
    80200950:	846a                	mv	s0,s10
    80200952:	b3f5                	j	8020073e <vprintfmt+0x78>
            putch('%', putdat);
    80200954:	85a6                	mv	a1,s1
    80200956:	02500513          	li	a0,37
    8020095a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    8020095c:	fff44703          	lbu	a4,-1(s0)
    80200960:	02500793          	li	a5,37
    80200964:	8d22                	mv	s10,s0
    80200966:	d8f70de3          	beq	a4,a5,80200700 <vprintfmt+0x3a>
    8020096a:	02500713          	li	a4,37
    8020096e:	1d7d                	addi	s10,s10,-1
    80200970:	fffd4783          	lbu	a5,-1(s10)
    80200974:	fee79de3          	bne	a5,a4,8020096e <vprintfmt+0x2a8>
    80200978:	b361                	j	80200700 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    8020097a:	00001617          	auipc	a2,0x1
    8020097e:	99660613          	addi	a2,a2,-1642 # 80201310 <error_string+0xd8>
    80200982:	85a6                	mv	a1,s1
    80200984:	854a                	mv	a0,s2
    80200986:	0ac000ef          	jal	ra,80200a32 <printfmt>
    8020098a:	bb9d                	j	80200700 <vprintfmt+0x3a>
                p = "(null)";
    8020098c:	00001617          	auipc	a2,0x1
    80200990:	97c60613          	addi	a2,a2,-1668 # 80201308 <error_string+0xd0>
            if (width > 0 && padc != '-') {
    80200994:	00001417          	auipc	s0,0x1
    80200998:	97540413          	addi	s0,s0,-1675 # 80201309 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020099c:	8532                	mv	a0,a2
    8020099e:	85e6                	mv	a1,s9
    802009a0:	e032                	sd	a2,0(sp)
    802009a2:	e43e                	sd	a5,8(sp)
    802009a4:	102000ef          	jal	ra,80200aa6 <strnlen>
    802009a8:	40ad8dbb          	subw	s11,s11,a0
    802009ac:	6602                	ld	a2,0(sp)
    802009ae:	01b05d63          	blez	s11,802009c8 <vprintfmt+0x302>
    802009b2:	67a2                	ld	a5,8(sp)
    802009b4:	2781                	sext.w	a5,a5
    802009b6:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
    802009b8:	6522                	ld	a0,8(sp)
    802009ba:	85a6                	mv	a1,s1
    802009bc:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
    802009be:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    802009c0:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    802009c2:	6602                	ld	a2,0(sp)
    802009c4:	fe0d9ae3          	bnez	s11,802009b8 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802009c8:	00064783          	lbu	a5,0(a2)
    802009cc:	0007851b          	sext.w	a0,a5
    802009d0:	e8051be3          	bnez	a0,80200866 <vprintfmt+0x1a0>
    802009d4:	b335                	j	80200700 <vprintfmt+0x3a>
        return va_arg(*ap, int);
    802009d6:	000aa403          	lw	s0,0(s5)
    802009da:	bbf1                	j	802007b6 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
    802009dc:	000ae603          	lwu	a2,0(s5)
    802009e0:	46a9                	li	a3,10
    802009e2:	8aae                	mv	s5,a1
    802009e4:	bd89                	j	80200836 <vprintfmt+0x170>
    802009e6:	000ae603          	lwu	a2,0(s5)
    802009ea:	46c1                	li	a3,16
    802009ec:	8aae                	mv	s5,a1
    802009ee:	b5a1                	j	80200836 <vprintfmt+0x170>
    802009f0:	000ae603          	lwu	a2,0(s5)
    802009f4:	46a1                	li	a3,8
    802009f6:	8aae                	mv	s5,a1
    802009f8:	bd3d                	j	80200836 <vprintfmt+0x170>
                    putch(ch, putdat);
    802009fa:	9902                	jalr	s2
    802009fc:	b559                	j	80200882 <vprintfmt+0x1bc>
                putch('-', putdat);
    802009fe:	85a6                	mv	a1,s1
    80200a00:	02d00513          	li	a0,45
    80200a04:	e03e                	sd	a5,0(sp)
    80200a06:	9902                	jalr	s2
                num = -(long long)num;
    80200a08:	8ace                	mv	s5,s3
    80200a0a:	40800633          	neg	a2,s0
    80200a0e:	46a9                	li	a3,10
    80200a10:	6782                	ld	a5,0(sp)
    80200a12:	b515                	j	80200836 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
    80200a14:	01b05663          	blez	s11,80200a20 <vprintfmt+0x35a>
    80200a18:	02d00693          	li	a3,45
    80200a1c:	f6d798e3          	bne	a5,a3,8020098c <vprintfmt+0x2c6>
    80200a20:	00001417          	auipc	s0,0x1
    80200a24:	8e940413          	addi	s0,s0,-1815 # 80201309 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200a28:	02800513          	li	a0,40
    80200a2c:	02800793          	li	a5,40
    80200a30:	bd1d                	j	80200866 <vprintfmt+0x1a0>

0000000080200a32 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200a32:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    80200a34:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200a38:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200a3a:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200a3c:	ec06                	sd	ra,24(sp)
    80200a3e:	f83a                	sd	a4,48(sp)
    80200a40:	fc3e                	sd	a5,56(sp)
    80200a42:	e0c2                	sd	a6,64(sp)
    80200a44:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    80200a46:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200a48:	c7fff0ef          	jal	ra,802006c6 <vprintfmt>
}
    80200a4c:	60e2                	ld	ra,24(sp)
    80200a4e:	6161                	addi	sp,sp,80
    80200a50:	8082                	ret

0000000080200a52 <sbi_console_putchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
    80200a52:	00003797          	auipc	a5,0x3
    80200a56:	5ae78793          	addi	a5,a5,1454 # 80204000 <bootstacktop>
    __asm__ volatile (
    80200a5a:	6398                	ld	a4,0(a5)
    80200a5c:	4781                	li	a5,0
    80200a5e:	88ba                	mv	a7,a4
    80200a60:	852a                	mv	a0,a0
    80200a62:	85be                	mv	a1,a5
    80200a64:	863e                	mv	a2,a5
    80200a66:	00000073          	ecall
    80200a6a:	87aa                	mv	a5,a0
}
    80200a6c:	8082                	ret

0000000080200a6e <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
    80200a6e:	00003797          	auipc	a5,0x3
    80200a72:	5aa78793          	addi	a5,a5,1450 # 80204018 <SBI_SET_TIMER>
    __asm__ volatile (
    80200a76:	6398                	ld	a4,0(a5)
    80200a78:	4781                	li	a5,0
    80200a7a:	88ba                	mv	a7,a4
    80200a7c:	852a                	mv	a0,a0
    80200a7e:	85be                	mv	a1,a5
    80200a80:	863e                	mv	a2,a5
    80200a82:	00000073          	ecall
    80200a86:	87aa                	mv	a5,a0
}
    80200a88:	8082                	ret

0000000080200a8a <sbi_shutdown>:


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    80200a8a:	00003797          	auipc	a5,0x3
    80200a8e:	57e78793          	addi	a5,a5,1406 # 80204008 <SBI_SHUTDOWN>
    __asm__ volatile (
    80200a92:	6398                	ld	a4,0(a5)
    80200a94:	4781                	li	a5,0
    80200a96:	88ba                	mv	a7,a4
    80200a98:	853e                	mv	a0,a5
    80200a9a:	85be                	mv	a1,a5
    80200a9c:	863e                	mv	a2,a5
    80200a9e:	00000073          	ecall
    80200aa2:	87aa                	mv	a5,a0
    80200aa4:	8082                	ret

0000000080200aa6 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
    80200aa6:	c185                	beqz	a1,80200ac6 <strnlen+0x20>
    80200aa8:	00054783          	lbu	a5,0(a0)
    80200aac:	cf89                	beqz	a5,80200ac6 <strnlen+0x20>
    size_t cnt = 0;
    80200aae:	4781                	li	a5,0
    80200ab0:	a021                	j	80200ab8 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
    80200ab2:	00074703          	lbu	a4,0(a4)
    80200ab6:	c711                	beqz	a4,80200ac2 <strnlen+0x1c>
        cnt ++;
    80200ab8:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    80200aba:	00f50733          	add	a4,a0,a5
    80200abe:	fef59ae3          	bne	a1,a5,80200ab2 <strnlen+0xc>
    }
    return cnt;
}
    80200ac2:	853e                	mv	a0,a5
    80200ac4:	8082                	ret
    size_t cnt = 0;
    80200ac6:	4781                	li	a5,0
}
    80200ac8:	853e                	mv	a0,a5
    80200aca:	8082                	ret

0000000080200acc <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    80200acc:	ca01                	beqz	a2,80200adc <memset+0x10>
    80200ace:	962a                	add	a2,a2,a0
    char *p = s;
    80200ad0:	87aa                	mv	a5,a0
        *p ++ = c;
    80200ad2:	0785                	addi	a5,a5,1
    80200ad4:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    80200ad8:	fec79de3          	bne	a5,a2,80200ad2 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    80200adc:	8082                	ret
