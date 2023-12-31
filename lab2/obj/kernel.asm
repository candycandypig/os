
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	01e31313          	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000c:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200010:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200014:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200018:	03f31313          	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc020001c:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200020:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200024:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200028:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	00006517          	auipc	a0,0x6
ffffffffc020003a:	fda50513          	addi	a0,a0,-38 # ffffffffc0206010 <edata>
ffffffffc020003e:	00006617          	auipc	a2,0x6
ffffffffc0200042:	43260613          	addi	a2,a2,1074 # ffffffffc0206470 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	568010ef          	jal	ra,ffffffffc02015b6 <memset>
    cons_init();  // init the console
ffffffffc0200052:	3fe000ef          	jal	ra,ffffffffc0200450 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00002517          	auipc	a0,0x2
ffffffffc020005a:	a8250513          	addi	a0,a0,-1406 # ffffffffc0201ad8 <etext+0x4>
ffffffffc020005e:	090000ef          	jal	ra,ffffffffc02000ee <cputs>

    print_kerninfo();
ffffffffc0200062:	13c000ef          	jal	ra,ffffffffc020019e <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	404000ef          	jal	ra,ffffffffc020046a <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	08b000ef          	jal	ra,ffffffffc02008f4 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006e:	3fc000ef          	jal	ra,ffffffffc020046a <idt_init>

    clock_init();   // init clock interrupt
ffffffffc0200072:	39a000ef          	jal	ra,ffffffffc020040c <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200076:	3e8000ef          	jal	ra,ffffffffc020045e <intr_enable>



    /* do nothing */
    while (1)
        ;
ffffffffc020007a:	a001                	j	ffffffffc020007a <kern_init+0x44>

ffffffffc020007c <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc020007c:	1141                	addi	sp,sp,-16
ffffffffc020007e:	e022                	sd	s0,0(sp)
ffffffffc0200080:	e406                	sd	ra,8(sp)
ffffffffc0200082:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200084:	3ce000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200088:	401c                	lw	a5,0(s0)
}
ffffffffc020008a:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc020008c:	2785                	addiw	a5,a5,1
ffffffffc020008e:	c01c                	sw	a5,0(s0)
}
ffffffffc0200090:	6402                	ld	s0,0(sp)
ffffffffc0200092:	0141                	addi	sp,sp,16
ffffffffc0200094:	8082                	ret

ffffffffc0200096 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200096:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	86ae                	mv	a3,a1
ffffffffc020009a:	862a                	mv	a2,a0
ffffffffc020009c:	006c                	addi	a1,sp,12
ffffffffc020009e:	00000517          	auipc	a0,0x0
ffffffffc02000a2:	fde50513          	addi	a0,a0,-34 # ffffffffc020007c <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a6:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a8:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000aa:	58a010ef          	jal	ra,ffffffffc0201634 <vprintfmt>
    return cnt;
}
ffffffffc02000ae:	60e2                	ld	ra,24(sp)
ffffffffc02000b0:	4532                	lw	a0,12(sp)
ffffffffc02000b2:	6105                	addi	sp,sp,32
ffffffffc02000b4:	8082                	ret

ffffffffc02000b6 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b6:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b8:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000bc:	f42e                	sd	a1,40(sp)
ffffffffc02000be:	f832                	sd	a2,48(sp)
ffffffffc02000c0:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c2:	862a                	mv	a2,a0
ffffffffc02000c4:	004c                	addi	a1,sp,4
ffffffffc02000c6:	00000517          	auipc	a0,0x0
ffffffffc02000ca:	fb650513          	addi	a0,a0,-74 # ffffffffc020007c <cputch>
ffffffffc02000ce:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d0:	ec06                	sd	ra,24(sp)
ffffffffc02000d2:	e0ba                	sd	a4,64(sp)
ffffffffc02000d4:	e4be                	sd	a5,72(sp)
ffffffffc02000d6:	e8c2                	sd	a6,80(sp)
ffffffffc02000d8:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000da:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000dc:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000de:	556010ef          	jal	ra,ffffffffc0201634 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e2:	60e2                	ld	ra,24(sp)
ffffffffc02000e4:	4512                	lw	a0,4(sp)
ffffffffc02000e6:	6125                	addi	sp,sp,96
ffffffffc02000e8:	8082                	ret

ffffffffc02000ea <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000ea:	3680006f          	j	ffffffffc0200452 <cons_putc>

ffffffffc02000ee <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ee:	1101                	addi	sp,sp,-32
ffffffffc02000f0:	e822                	sd	s0,16(sp)
ffffffffc02000f2:	ec06                	sd	ra,24(sp)
ffffffffc02000f4:	e426                	sd	s1,8(sp)
ffffffffc02000f6:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f8:	00054503          	lbu	a0,0(a0)
ffffffffc02000fc:	c51d                	beqz	a0,ffffffffc020012a <cputs+0x3c>
ffffffffc02000fe:	0405                	addi	s0,s0,1
ffffffffc0200100:	4485                	li	s1,1
ffffffffc0200102:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200104:	34e000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200112:	f96d                	bnez	a0,ffffffffc0200104 <cputs+0x16>
ffffffffc0200114:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200118:	4529                	li	a0,10
ffffffffc020011a:	338000ef          	jal	ra,ffffffffc0200452 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011e:	8522                	mv	a0,s0
ffffffffc0200120:	60e2                	ld	ra,24(sp)
ffffffffc0200122:	6442                	ld	s0,16(sp)
ffffffffc0200124:	64a2                	ld	s1,8(sp)
ffffffffc0200126:	6105                	addi	sp,sp,32
ffffffffc0200128:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc020012a:	4405                	li	s0,1
ffffffffc020012c:	b7f5                	j	ffffffffc0200118 <cputs+0x2a>

ffffffffc020012e <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012e:	1141                	addi	sp,sp,-16
ffffffffc0200130:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200132:	328000ef          	jal	ra,ffffffffc020045a <cons_getc>
ffffffffc0200136:	dd75                	beqz	a0,ffffffffc0200132 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200138:	60a2                	ld	ra,8(sp)
ffffffffc020013a:	0141                	addi	sp,sp,16
ffffffffc020013c:	8082                	ret

ffffffffc020013e <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc020013e:	00006317          	auipc	t1,0x6
ffffffffc0200142:	2d230313          	addi	t1,t1,722 # ffffffffc0206410 <is_panic>
ffffffffc0200146:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc020014a:	715d                	addi	sp,sp,-80
ffffffffc020014c:	ec06                	sd	ra,24(sp)
ffffffffc020014e:	e822                	sd	s0,16(sp)
ffffffffc0200150:	f436                	sd	a3,40(sp)
ffffffffc0200152:	f83a                	sd	a4,48(sp)
ffffffffc0200154:	fc3e                	sd	a5,56(sp)
ffffffffc0200156:	e0c2                	sd	a6,64(sp)
ffffffffc0200158:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020015a:	02031c63          	bnez	t1,ffffffffc0200192 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc020015e:	4785                	li	a5,1
ffffffffc0200160:	8432                	mv	s0,a2
ffffffffc0200162:	00006717          	auipc	a4,0x6
ffffffffc0200166:	2af72723          	sw	a5,686(a4) # ffffffffc0206410 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020016a:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc020016c:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020016e:	85aa                	mv	a1,a0
ffffffffc0200170:	00002517          	auipc	a0,0x2
ffffffffc0200174:	98850513          	addi	a0,a0,-1656 # ffffffffc0201af8 <etext+0x24>
    va_start(ap, fmt);
ffffffffc0200178:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020017a:	f3dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    vcprintf(fmt, ap);
ffffffffc020017e:	65a2                	ld	a1,8(sp)
ffffffffc0200180:	8522                	mv	a0,s0
ffffffffc0200182:	f15ff0ef          	jal	ra,ffffffffc0200096 <vcprintf>
    cprintf("\n");
ffffffffc0200186:	00002517          	auipc	a0,0x2
ffffffffc020018a:	a8a50513          	addi	a0,a0,-1398 # ffffffffc0201c10 <etext+0x13c>
ffffffffc020018e:	f29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200192:	2d2000ef          	jal	ra,ffffffffc0200464 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200196:	4501                	li	a0,0
ffffffffc0200198:	132000ef          	jal	ra,ffffffffc02002ca <kmonitor>
ffffffffc020019c:	bfed                	j	ffffffffc0200196 <__panic+0x58>

ffffffffc020019e <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020019e:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02001a0:	00002517          	auipc	a0,0x2
ffffffffc02001a4:	9a850513          	addi	a0,a0,-1624 # ffffffffc0201b48 <etext+0x74>
void print_kerninfo(void) {
ffffffffc02001a8:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001aa:	f0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc02001ae:	00000597          	auipc	a1,0x0
ffffffffc02001b2:	e8858593          	addi	a1,a1,-376 # ffffffffc0200036 <kern_init>
ffffffffc02001b6:	00002517          	auipc	a0,0x2
ffffffffc02001ba:	9b250513          	addi	a0,a0,-1614 # ffffffffc0201b68 <etext+0x94>
ffffffffc02001be:	ef9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc02001c2:	00002597          	auipc	a1,0x2
ffffffffc02001c6:	91258593          	addi	a1,a1,-1774 # ffffffffc0201ad4 <etext>
ffffffffc02001ca:	00002517          	auipc	a0,0x2
ffffffffc02001ce:	9be50513          	addi	a0,a0,-1602 # ffffffffc0201b88 <etext+0xb4>
ffffffffc02001d2:	ee5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc02001d6:	00006597          	auipc	a1,0x6
ffffffffc02001da:	e3a58593          	addi	a1,a1,-454 # ffffffffc0206010 <edata>
ffffffffc02001de:	00002517          	auipc	a0,0x2
ffffffffc02001e2:	9ca50513          	addi	a0,a0,-1590 # ffffffffc0201ba8 <etext+0xd4>
ffffffffc02001e6:	ed1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc02001ea:	00006597          	auipc	a1,0x6
ffffffffc02001ee:	28658593          	addi	a1,a1,646 # ffffffffc0206470 <end>
ffffffffc02001f2:	00002517          	auipc	a0,0x2
ffffffffc02001f6:	9d650513          	addi	a0,a0,-1578 # ffffffffc0201bc8 <etext+0xf4>
ffffffffc02001fa:	ebdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001fe:	00006597          	auipc	a1,0x6
ffffffffc0200202:	67158593          	addi	a1,a1,1649 # ffffffffc020686f <end+0x3ff>
ffffffffc0200206:	00000797          	auipc	a5,0x0
ffffffffc020020a:	e3078793          	addi	a5,a5,-464 # ffffffffc0200036 <kern_init>
ffffffffc020020e:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200212:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200216:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200218:	3ff5f593          	andi	a1,a1,1023
ffffffffc020021c:	95be                	add	a1,a1,a5
ffffffffc020021e:	85a9                	srai	a1,a1,0xa
ffffffffc0200220:	00002517          	auipc	a0,0x2
ffffffffc0200224:	9c850513          	addi	a0,a0,-1592 # ffffffffc0201be8 <etext+0x114>
}
ffffffffc0200228:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020022a:	e8dff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020022e <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc020022e:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc0200230:	00002617          	auipc	a2,0x2
ffffffffc0200234:	8e860613          	addi	a2,a2,-1816 # ffffffffc0201b18 <etext+0x44>
ffffffffc0200238:	04e00593          	li	a1,78
ffffffffc020023c:	00002517          	auipc	a0,0x2
ffffffffc0200240:	8f450513          	addi	a0,a0,-1804 # ffffffffc0201b30 <etext+0x5c>
void print_stackframe(void) {
ffffffffc0200244:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc0200246:	ef9ff0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc020024a <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020024a:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020024c:	00002617          	auipc	a2,0x2
ffffffffc0200250:	aac60613          	addi	a2,a2,-1364 # ffffffffc0201cf8 <commands+0xe0>
ffffffffc0200254:	00002597          	auipc	a1,0x2
ffffffffc0200258:	ac458593          	addi	a1,a1,-1340 # ffffffffc0201d18 <commands+0x100>
ffffffffc020025c:	00002517          	auipc	a0,0x2
ffffffffc0200260:	ac450513          	addi	a0,a0,-1340 # ffffffffc0201d20 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200264:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200266:	e51ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020026a:	00002617          	auipc	a2,0x2
ffffffffc020026e:	ac660613          	addi	a2,a2,-1338 # ffffffffc0201d30 <commands+0x118>
ffffffffc0200272:	00002597          	auipc	a1,0x2
ffffffffc0200276:	ae658593          	addi	a1,a1,-1306 # ffffffffc0201d58 <commands+0x140>
ffffffffc020027a:	00002517          	auipc	a0,0x2
ffffffffc020027e:	aa650513          	addi	a0,a0,-1370 # ffffffffc0201d20 <commands+0x108>
ffffffffc0200282:	e35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200286:	00002617          	auipc	a2,0x2
ffffffffc020028a:	ae260613          	addi	a2,a2,-1310 # ffffffffc0201d68 <commands+0x150>
ffffffffc020028e:	00002597          	auipc	a1,0x2
ffffffffc0200292:	afa58593          	addi	a1,a1,-1286 # ffffffffc0201d88 <commands+0x170>
ffffffffc0200296:	00002517          	auipc	a0,0x2
ffffffffc020029a:	a8a50513          	addi	a0,a0,-1398 # ffffffffc0201d20 <commands+0x108>
ffffffffc020029e:	e19ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    }
    return 0;
}
ffffffffc02002a2:	60a2                	ld	ra,8(sp)
ffffffffc02002a4:	4501                	li	a0,0
ffffffffc02002a6:	0141                	addi	sp,sp,16
ffffffffc02002a8:	8082                	ret

ffffffffc02002aa <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002aa:	1141                	addi	sp,sp,-16
ffffffffc02002ac:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02002ae:	ef1ff0ef          	jal	ra,ffffffffc020019e <print_kerninfo>
    return 0;
}
ffffffffc02002b2:	60a2                	ld	ra,8(sp)
ffffffffc02002b4:	4501                	li	a0,0
ffffffffc02002b6:	0141                	addi	sp,sp,16
ffffffffc02002b8:	8082                	ret

ffffffffc02002ba <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002ba:	1141                	addi	sp,sp,-16
ffffffffc02002bc:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02002be:	f71ff0ef          	jal	ra,ffffffffc020022e <print_stackframe>
    return 0;
}
ffffffffc02002c2:	60a2                	ld	ra,8(sp)
ffffffffc02002c4:	4501                	li	a0,0
ffffffffc02002c6:	0141                	addi	sp,sp,16
ffffffffc02002c8:	8082                	ret

ffffffffc02002ca <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02002ca:	7115                	addi	sp,sp,-224
ffffffffc02002cc:	e962                	sd	s8,144(sp)
ffffffffc02002ce:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002d0:	00002517          	auipc	a0,0x2
ffffffffc02002d4:	99050513          	addi	a0,a0,-1648 # ffffffffc0201c60 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc02002d8:	ed86                	sd	ra,216(sp)
ffffffffc02002da:	e9a2                	sd	s0,208(sp)
ffffffffc02002dc:	e5a6                	sd	s1,200(sp)
ffffffffc02002de:	e1ca                	sd	s2,192(sp)
ffffffffc02002e0:	fd4e                	sd	s3,184(sp)
ffffffffc02002e2:	f952                	sd	s4,176(sp)
ffffffffc02002e4:	f556                	sd	s5,168(sp)
ffffffffc02002e6:	f15a                	sd	s6,160(sp)
ffffffffc02002e8:	ed5e                	sd	s7,152(sp)
ffffffffc02002ea:	e566                	sd	s9,136(sp)
ffffffffc02002ec:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002ee:	dc9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc02002f2:	00002517          	auipc	a0,0x2
ffffffffc02002f6:	99650513          	addi	a0,a0,-1642 # ffffffffc0201c88 <commands+0x70>
ffffffffc02002fa:	dbdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc02002fe:	000c0563          	beqz	s8,ffffffffc0200308 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200302:	8562                	mv	a0,s8
ffffffffc0200304:	346000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc0200308:	00002c97          	auipc	s9,0x2
ffffffffc020030c:	910c8c93          	addi	s9,s9,-1776 # ffffffffc0201c18 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200310:	00002997          	auipc	s3,0x2
ffffffffc0200314:	9a098993          	addi	s3,s3,-1632 # ffffffffc0201cb0 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200318:	00002917          	auipc	s2,0x2
ffffffffc020031c:	9a090913          	addi	s2,s2,-1632 # ffffffffc0201cb8 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200320:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200322:	00002b17          	auipc	s6,0x2
ffffffffc0200326:	99eb0b13          	addi	s6,s6,-1634 # ffffffffc0201cc0 <commands+0xa8>
    if (argc == 0) {
ffffffffc020032a:	00002a97          	auipc	s5,0x2
ffffffffc020032e:	9eea8a93          	addi	s5,s5,-1554 # ffffffffc0201d18 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200332:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200334:	854e                	mv	a0,s3
ffffffffc0200336:	68a010ef          	jal	ra,ffffffffc02019c0 <readline>
ffffffffc020033a:	842a                	mv	s0,a0
ffffffffc020033c:	dd65                	beqz	a0,ffffffffc0200334 <kmonitor+0x6a>
ffffffffc020033e:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200342:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200344:	c999                	beqz	a1,ffffffffc020035a <kmonitor+0x90>
ffffffffc0200346:	854a                	mv	a0,s2
ffffffffc0200348:	250010ef          	jal	ra,ffffffffc0201598 <strchr>
ffffffffc020034c:	c925                	beqz	a0,ffffffffc02003bc <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc020034e:	00144583          	lbu	a1,1(s0)
ffffffffc0200352:	00040023          	sb	zero,0(s0)
ffffffffc0200356:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200358:	f5fd                	bnez	a1,ffffffffc0200346 <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc020035a:	dce9                	beqz	s1,ffffffffc0200334 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020035c:	6582                	ld	a1,0(sp)
ffffffffc020035e:	00002d17          	auipc	s10,0x2
ffffffffc0200362:	8bad0d13          	addi	s10,s10,-1862 # ffffffffc0201c18 <commands>
    if (argc == 0) {
ffffffffc0200366:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200368:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020036a:	0d61                	addi	s10,s10,24
ffffffffc020036c:	202010ef          	jal	ra,ffffffffc020156e <strcmp>
ffffffffc0200370:	c919                	beqz	a0,ffffffffc0200386 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200372:	2405                	addiw	s0,s0,1
ffffffffc0200374:	09740463          	beq	s0,s7,ffffffffc02003fc <kmonitor+0x132>
ffffffffc0200378:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020037c:	6582                	ld	a1,0(sp)
ffffffffc020037e:	0d61                	addi	s10,s10,24
ffffffffc0200380:	1ee010ef          	jal	ra,ffffffffc020156e <strcmp>
ffffffffc0200384:	f57d                	bnez	a0,ffffffffc0200372 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200386:	00141793          	slli	a5,s0,0x1
ffffffffc020038a:	97a2                	add	a5,a5,s0
ffffffffc020038c:	078e                	slli	a5,a5,0x3
ffffffffc020038e:	97e6                	add	a5,a5,s9
ffffffffc0200390:	6b9c                	ld	a5,16(a5)
ffffffffc0200392:	8662                	mv	a2,s8
ffffffffc0200394:	002c                	addi	a1,sp,8
ffffffffc0200396:	fff4851b          	addiw	a0,s1,-1
ffffffffc020039a:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020039c:	f8055ce3          	bgez	a0,ffffffffc0200334 <kmonitor+0x6a>
}
ffffffffc02003a0:	60ee                	ld	ra,216(sp)
ffffffffc02003a2:	644e                	ld	s0,208(sp)
ffffffffc02003a4:	64ae                	ld	s1,200(sp)
ffffffffc02003a6:	690e                	ld	s2,192(sp)
ffffffffc02003a8:	79ea                	ld	s3,184(sp)
ffffffffc02003aa:	7a4a                	ld	s4,176(sp)
ffffffffc02003ac:	7aaa                	ld	s5,168(sp)
ffffffffc02003ae:	7b0a                	ld	s6,160(sp)
ffffffffc02003b0:	6bea                	ld	s7,152(sp)
ffffffffc02003b2:	6c4a                	ld	s8,144(sp)
ffffffffc02003b4:	6caa                	ld	s9,136(sp)
ffffffffc02003b6:	6d0a                	ld	s10,128(sp)
ffffffffc02003b8:	612d                	addi	sp,sp,224
ffffffffc02003ba:	8082                	ret
        if (*buf == '\0') {
ffffffffc02003bc:	00044783          	lbu	a5,0(s0)
ffffffffc02003c0:	dfc9                	beqz	a5,ffffffffc020035a <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc02003c2:	03448863          	beq	s1,s4,ffffffffc02003f2 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc02003c6:	00349793          	slli	a5,s1,0x3
ffffffffc02003ca:	0118                	addi	a4,sp,128
ffffffffc02003cc:	97ba                	add	a5,a5,a4
ffffffffc02003ce:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003d2:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02003d6:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003d8:	e591                	bnez	a1,ffffffffc02003e4 <kmonitor+0x11a>
ffffffffc02003da:	b749                	j	ffffffffc020035c <kmonitor+0x92>
            buf ++;
ffffffffc02003dc:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003de:	00044583          	lbu	a1,0(s0)
ffffffffc02003e2:	ddad                	beqz	a1,ffffffffc020035c <kmonitor+0x92>
ffffffffc02003e4:	854a                	mv	a0,s2
ffffffffc02003e6:	1b2010ef          	jal	ra,ffffffffc0201598 <strchr>
ffffffffc02003ea:	d96d                	beqz	a0,ffffffffc02003dc <kmonitor+0x112>
ffffffffc02003ec:	00044583          	lbu	a1,0(s0)
ffffffffc02003f0:	bf91                	j	ffffffffc0200344 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003f2:	45c1                	li	a1,16
ffffffffc02003f4:	855a                	mv	a0,s6
ffffffffc02003f6:	cc1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02003fa:	b7f1                	j	ffffffffc02003c6 <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003fc:	6582                	ld	a1,0(sp)
ffffffffc02003fe:	00002517          	auipc	a0,0x2
ffffffffc0200402:	8e250513          	addi	a0,a0,-1822 # ffffffffc0201ce0 <commands+0xc8>
ffffffffc0200406:	cb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    return 0;
ffffffffc020040a:	b72d                	j	ffffffffc0200334 <kmonitor+0x6a>

ffffffffc020040c <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc020040c:	1141                	addi	sp,sp,-16
ffffffffc020040e:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc0200410:	02000793          	li	a5,32
ffffffffc0200414:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200418:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020041c:	67e1                	lui	a5,0x18
ffffffffc020041e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc0200422:	953e                	add	a0,a0,a5
ffffffffc0200424:	676010ef          	jal	ra,ffffffffc0201a9a <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00006797          	auipc	a5,0x6
ffffffffc020042e:	0007b323          	sd	zero,6(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00002517          	auipc	a0,0x2
ffffffffc0200436:	96650513          	addi	a0,a0,-1690 # ffffffffc0201d98 <commands+0x180>
}
ffffffffc020043a:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc020043c:	c7bff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc0200440 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200440:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200444:	67e1                	lui	a5,0x18
ffffffffc0200446:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc020044a:	953e                	add	a0,a0,a5
ffffffffc020044c:	64e0106f          	j	ffffffffc0201a9a <sbi_set_timer>

ffffffffc0200450 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200450:	8082                	ret

ffffffffc0200452 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200452:	0ff57513          	andi	a0,a0,255
ffffffffc0200456:	6280106f          	j	ffffffffc0201a7e <sbi_console_putchar>

ffffffffc020045a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045a:	65c0106f          	j	ffffffffc0201ab6 <sbi_console_getchar>

ffffffffc020045e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200464:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200468:	8082                	ret

ffffffffc020046a <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020046a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020046e:	00000797          	auipc	a5,0x0
ffffffffc0200472:	30678793          	addi	a5,a5,774 # ffffffffc0200774 <__alltraps>
ffffffffc0200476:	10579073          	csrw	stvec,a5
}
ffffffffc020047a:	8082                	ret

ffffffffc020047c <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020047e:	1141                	addi	sp,sp,-16
ffffffffc0200480:	e022                	sd	s0,0(sp)
ffffffffc0200482:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200484:	00002517          	auipc	a0,0x2
ffffffffc0200488:	a2c50513          	addi	a0,a0,-1492 # ffffffffc0201eb0 <commands+0x298>
void print_regs(struct pushregs *gpr) {
ffffffffc020048c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048e:	c29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200492:	640c                	ld	a1,8(s0)
ffffffffc0200494:	00002517          	auipc	a0,0x2
ffffffffc0200498:	a3450513          	addi	a0,a0,-1484 # ffffffffc0201ec8 <commands+0x2b0>
ffffffffc020049c:	c1bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a0:	680c                	ld	a1,16(s0)
ffffffffc02004a2:	00002517          	auipc	a0,0x2
ffffffffc02004a6:	a3e50513          	addi	a0,a0,-1474 # ffffffffc0201ee0 <commands+0x2c8>
ffffffffc02004aa:	c0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ae:	6c0c                	ld	a1,24(s0)
ffffffffc02004b0:	00002517          	auipc	a0,0x2
ffffffffc02004b4:	a4850513          	addi	a0,a0,-1464 # ffffffffc0201ef8 <commands+0x2e0>
ffffffffc02004b8:	bffff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004bc:	700c                	ld	a1,32(s0)
ffffffffc02004be:	00002517          	auipc	a0,0x2
ffffffffc02004c2:	a5250513          	addi	a0,a0,-1454 # ffffffffc0201f10 <commands+0x2f8>
ffffffffc02004c6:	bf1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004ca:	740c                	ld	a1,40(s0)
ffffffffc02004cc:	00002517          	auipc	a0,0x2
ffffffffc02004d0:	a5c50513          	addi	a0,a0,-1444 # ffffffffc0201f28 <commands+0x310>
ffffffffc02004d4:	be3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d8:	780c                	ld	a1,48(s0)
ffffffffc02004da:	00002517          	auipc	a0,0x2
ffffffffc02004de:	a6650513          	addi	a0,a0,-1434 # ffffffffc0201f40 <commands+0x328>
ffffffffc02004e2:	bd5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e6:	7c0c                	ld	a1,56(s0)
ffffffffc02004e8:	00002517          	auipc	a0,0x2
ffffffffc02004ec:	a7050513          	addi	a0,a0,-1424 # ffffffffc0201f58 <commands+0x340>
ffffffffc02004f0:	bc7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f4:	602c                	ld	a1,64(s0)
ffffffffc02004f6:	00002517          	auipc	a0,0x2
ffffffffc02004fa:	a7a50513          	addi	a0,a0,-1414 # ffffffffc0201f70 <commands+0x358>
ffffffffc02004fe:	bb9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200502:	642c                	ld	a1,72(s0)
ffffffffc0200504:	00002517          	auipc	a0,0x2
ffffffffc0200508:	a8450513          	addi	a0,a0,-1404 # ffffffffc0201f88 <commands+0x370>
ffffffffc020050c:	babff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200510:	682c                	ld	a1,80(s0)
ffffffffc0200512:	00002517          	auipc	a0,0x2
ffffffffc0200516:	a8e50513          	addi	a0,a0,-1394 # ffffffffc0201fa0 <commands+0x388>
ffffffffc020051a:	b9dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051e:	6c2c                	ld	a1,88(s0)
ffffffffc0200520:	00002517          	auipc	a0,0x2
ffffffffc0200524:	a9850513          	addi	a0,a0,-1384 # ffffffffc0201fb8 <commands+0x3a0>
ffffffffc0200528:	b8fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052c:	702c                	ld	a1,96(s0)
ffffffffc020052e:	00002517          	auipc	a0,0x2
ffffffffc0200532:	aa250513          	addi	a0,a0,-1374 # ffffffffc0201fd0 <commands+0x3b8>
ffffffffc0200536:	b81ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053a:	742c                	ld	a1,104(s0)
ffffffffc020053c:	00002517          	auipc	a0,0x2
ffffffffc0200540:	aac50513          	addi	a0,a0,-1364 # ffffffffc0201fe8 <commands+0x3d0>
ffffffffc0200544:	b73ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200548:	782c                	ld	a1,112(s0)
ffffffffc020054a:	00002517          	auipc	a0,0x2
ffffffffc020054e:	ab650513          	addi	a0,a0,-1354 # ffffffffc0202000 <commands+0x3e8>
ffffffffc0200552:	b65ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200556:	7c2c                	ld	a1,120(s0)
ffffffffc0200558:	00002517          	auipc	a0,0x2
ffffffffc020055c:	ac050513          	addi	a0,a0,-1344 # ffffffffc0202018 <commands+0x400>
ffffffffc0200560:	b57ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200564:	604c                	ld	a1,128(s0)
ffffffffc0200566:	00002517          	auipc	a0,0x2
ffffffffc020056a:	aca50513          	addi	a0,a0,-1334 # ffffffffc0202030 <commands+0x418>
ffffffffc020056e:	b49ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200572:	644c                	ld	a1,136(s0)
ffffffffc0200574:	00002517          	auipc	a0,0x2
ffffffffc0200578:	ad450513          	addi	a0,a0,-1324 # ffffffffc0202048 <commands+0x430>
ffffffffc020057c:	b3bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200580:	684c                	ld	a1,144(s0)
ffffffffc0200582:	00002517          	auipc	a0,0x2
ffffffffc0200586:	ade50513          	addi	a0,a0,-1314 # ffffffffc0202060 <commands+0x448>
ffffffffc020058a:	b2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058e:	6c4c                	ld	a1,152(s0)
ffffffffc0200590:	00002517          	auipc	a0,0x2
ffffffffc0200594:	ae850513          	addi	a0,a0,-1304 # ffffffffc0202078 <commands+0x460>
ffffffffc0200598:	b1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059c:	704c                	ld	a1,160(s0)
ffffffffc020059e:	00002517          	auipc	a0,0x2
ffffffffc02005a2:	af250513          	addi	a0,a0,-1294 # ffffffffc0202090 <commands+0x478>
ffffffffc02005a6:	b11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005aa:	744c                	ld	a1,168(s0)
ffffffffc02005ac:	00002517          	auipc	a0,0x2
ffffffffc02005b0:	afc50513          	addi	a0,a0,-1284 # ffffffffc02020a8 <commands+0x490>
ffffffffc02005b4:	b03ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b8:	784c                	ld	a1,176(s0)
ffffffffc02005ba:	00002517          	auipc	a0,0x2
ffffffffc02005be:	b0650513          	addi	a0,a0,-1274 # ffffffffc02020c0 <commands+0x4a8>
ffffffffc02005c2:	af5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c6:	7c4c                	ld	a1,184(s0)
ffffffffc02005c8:	00002517          	auipc	a0,0x2
ffffffffc02005cc:	b1050513          	addi	a0,a0,-1264 # ffffffffc02020d8 <commands+0x4c0>
ffffffffc02005d0:	ae7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d4:	606c                	ld	a1,192(s0)
ffffffffc02005d6:	00002517          	auipc	a0,0x2
ffffffffc02005da:	b1a50513          	addi	a0,a0,-1254 # ffffffffc02020f0 <commands+0x4d8>
ffffffffc02005de:	ad9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e2:	646c                	ld	a1,200(s0)
ffffffffc02005e4:	00002517          	auipc	a0,0x2
ffffffffc02005e8:	b2450513          	addi	a0,a0,-1244 # ffffffffc0202108 <commands+0x4f0>
ffffffffc02005ec:	acbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f0:	686c                	ld	a1,208(s0)
ffffffffc02005f2:	00002517          	auipc	a0,0x2
ffffffffc02005f6:	b2e50513          	addi	a0,a0,-1234 # ffffffffc0202120 <commands+0x508>
ffffffffc02005fa:	abdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200600:	00002517          	auipc	a0,0x2
ffffffffc0200604:	b3850513          	addi	a0,a0,-1224 # ffffffffc0202138 <commands+0x520>
ffffffffc0200608:	aafff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060c:	706c                	ld	a1,224(s0)
ffffffffc020060e:	00002517          	auipc	a0,0x2
ffffffffc0200612:	b4250513          	addi	a0,a0,-1214 # ffffffffc0202150 <commands+0x538>
ffffffffc0200616:	aa1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061a:	746c                	ld	a1,232(s0)
ffffffffc020061c:	00002517          	auipc	a0,0x2
ffffffffc0200620:	b4c50513          	addi	a0,a0,-1204 # ffffffffc0202168 <commands+0x550>
ffffffffc0200624:	a93ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200628:	786c                	ld	a1,240(s0)
ffffffffc020062a:	00002517          	auipc	a0,0x2
ffffffffc020062e:	b5650513          	addi	a0,a0,-1194 # ffffffffc0202180 <commands+0x568>
ffffffffc0200632:	a85ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200638:	6402                	ld	s0,0(sp)
ffffffffc020063a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	00002517          	auipc	a0,0x2
ffffffffc0200640:	b5c50513          	addi	a0,a0,-1188 # ffffffffc0202198 <commands+0x580>
}
ffffffffc0200644:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200646:	a71ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020064a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020064a:	1141                	addi	sp,sp,-16
ffffffffc020064c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020064e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200650:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200652:	00002517          	auipc	a0,0x2
ffffffffc0200656:	b5e50513          	addi	a0,a0,-1186 # ffffffffc02021b0 <commands+0x598>
void print_trapframe(struct trapframe *tf) {
ffffffffc020065a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020065c:	a5bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200660:	8522                	mv	a0,s0
ffffffffc0200662:	e1bff0ef          	jal	ra,ffffffffc020047c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200666:	10043583          	ld	a1,256(s0)
ffffffffc020066a:	00002517          	auipc	a0,0x2
ffffffffc020066e:	b5e50513          	addi	a0,a0,-1186 # ffffffffc02021c8 <commands+0x5b0>
ffffffffc0200672:	a45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00002517          	auipc	a0,0x2
ffffffffc020067e:	b6650513          	addi	a0,a0,-1178 # ffffffffc02021e0 <commands+0x5c8>
ffffffffc0200682:	a35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00002517          	auipc	a0,0x2
ffffffffc020068e:	b6e50513          	addi	a0,a0,-1170 # ffffffffc02021f8 <commands+0x5e0>
ffffffffc0200692:	a25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00002517          	auipc	a0,0x2
ffffffffc02006a2:	b7250513          	addi	a0,a0,-1166 # ffffffffc0202210 <commands+0x5f8>
}
ffffffffc02006a6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a8:	a0fff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02006ac <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006ac:	11853783          	ld	a5,280(a0)
ffffffffc02006b0:	577d                	li	a4,-1
ffffffffc02006b2:	8305                	srli	a4,a4,0x1
ffffffffc02006b4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02006b6:	472d                	li	a4,11
ffffffffc02006b8:	08f76563          	bltu	a4,a5,ffffffffc0200742 <interrupt_handler+0x96>
ffffffffc02006bc:	00001717          	auipc	a4,0x1
ffffffffc02006c0:	6f870713          	addi	a4,a4,1784 # ffffffffc0201db4 <commands+0x19c>
ffffffffc02006c4:	078a                	slli	a5,a5,0x2
ffffffffc02006c6:	97ba                	add	a5,a5,a4
ffffffffc02006c8:	439c                	lw	a5,0(a5)
ffffffffc02006ca:	97ba                	add	a5,a5,a4
ffffffffc02006cc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006ce:	00001517          	auipc	a0,0x1
ffffffffc02006d2:	77a50513          	addi	a0,a0,1914 # ffffffffc0201e48 <commands+0x230>
ffffffffc02006d6:	9e1ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006da:	00001517          	auipc	a0,0x1
ffffffffc02006de:	74e50513          	addi	a0,a0,1870 # ffffffffc0201e28 <commands+0x210>
ffffffffc02006e2:	9d5ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006e6:	00001517          	auipc	a0,0x1
ffffffffc02006ea:	70250513          	addi	a0,a0,1794 # ffffffffc0201de8 <commands+0x1d0>
ffffffffc02006ee:	9c9ff06f          	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006f2:	00001517          	auipc	a0,0x1
ffffffffc02006f6:	77650513          	addi	a0,a0,1910 # ffffffffc0201e68 <commands+0x250>
ffffffffc02006fa:	9bdff06f          	j	ffffffffc02000b6 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006fe:	1141                	addi	sp,sp,-16
ffffffffc0200700:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200702:	d3fff0ef          	jal	ra,ffffffffc0200440 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200706:	00006797          	auipc	a5,0x6
ffffffffc020070a:	d2a78793          	addi	a5,a5,-726 # ffffffffc0206430 <ticks>
ffffffffc020070e:	639c                	ld	a5,0(a5)
ffffffffc0200710:	06400713          	li	a4,100
ffffffffc0200714:	0785                	addi	a5,a5,1
ffffffffc0200716:	02e7f733          	remu	a4,a5,a4
ffffffffc020071a:	00006697          	auipc	a3,0x6
ffffffffc020071e:	d0f6bb23          	sd	a5,-746(a3) # ffffffffc0206430 <ticks>
ffffffffc0200722:	c315                	beqz	a4,ffffffffc0200746 <interrupt_handler+0x9a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200724:	60a2                	ld	ra,8(sp)
ffffffffc0200726:	0141                	addi	sp,sp,16
ffffffffc0200728:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc020072a:	00001517          	auipc	a0,0x1
ffffffffc020072e:	76650513          	addi	a0,a0,1894 # ffffffffc0201e90 <commands+0x278>
ffffffffc0200732:	985ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200736:	00001517          	auipc	a0,0x1
ffffffffc020073a:	6d250513          	addi	a0,a0,1746 # ffffffffc0201e08 <commands+0x1f0>
ffffffffc020073e:	979ff06f          	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc0200742:	f09ff06f          	j	ffffffffc020064a <print_trapframe>
}
ffffffffc0200746:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200748:	06400593          	li	a1,100
ffffffffc020074c:	00001517          	auipc	a0,0x1
ffffffffc0200750:	73450513          	addi	a0,a0,1844 # ffffffffc0201e80 <commands+0x268>
}
ffffffffc0200754:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200756:	961ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020075a <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc020075a:	11853783          	ld	a5,280(a0)
ffffffffc020075e:	0007c863          	bltz	a5,ffffffffc020076e <trap+0x14>
    switch (tf->cause) {
ffffffffc0200762:	472d                	li	a4,11
ffffffffc0200764:	00f76363          	bltu	a4,a5,ffffffffc020076a <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200768:	8082                	ret
            print_trapframe(tf);
ffffffffc020076a:	ee1ff06f          	j	ffffffffc020064a <print_trapframe>
        interrupt_handler(tf);
ffffffffc020076e:	f3fff06f          	j	ffffffffc02006ac <interrupt_handler>
	...

ffffffffc0200774 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200774:	14011073          	csrw	sscratch,sp
ffffffffc0200778:	712d                	addi	sp,sp,-288
ffffffffc020077a:	e002                	sd	zero,0(sp)
ffffffffc020077c:	e406                	sd	ra,8(sp)
ffffffffc020077e:	ec0e                	sd	gp,24(sp)
ffffffffc0200780:	f012                	sd	tp,32(sp)
ffffffffc0200782:	f416                	sd	t0,40(sp)
ffffffffc0200784:	f81a                	sd	t1,48(sp)
ffffffffc0200786:	fc1e                	sd	t2,56(sp)
ffffffffc0200788:	e0a2                	sd	s0,64(sp)
ffffffffc020078a:	e4a6                	sd	s1,72(sp)
ffffffffc020078c:	e8aa                	sd	a0,80(sp)
ffffffffc020078e:	ecae                	sd	a1,88(sp)
ffffffffc0200790:	f0b2                	sd	a2,96(sp)
ffffffffc0200792:	f4b6                	sd	a3,104(sp)
ffffffffc0200794:	f8ba                	sd	a4,112(sp)
ffffffffc0200796:	fcbe                	sd	a5,120(sp)
ffffffffc0200798:	e142                	sd	a6,128(sp)
ffffffffc020079a:	e546                	sd	a7,136(sp)
ffffffffc020079c:	e94a                	sd	s2,144(sp)
ffffffffc020079e:	ed4e                	sd	s3,152(sp)
ffffffffc02007a0:	f152                	sd	s4,160(sp)
ffffffffc02007a2:	f556                	sd	s5,168(sp)
ffffffffc02007a4:	f95a                	sd	s6,176(sp)
ffffffffc02007a6:	fd5e                	sd	s7,184(sp)
ffffffffc02007a8:	e1e2                	sd	s8,192(sp)
ffffffffc02007aa:	e5e6                	sd	s9,200(sp)
ffffffffc02007ac:	e9ea                	sd	s10,208(sp)
ffffffffc02007ae:	edee                	sd	s11,216(sp)
ffffffffc02007b0:	f1f2                	sd	t3,224(sp)
ffffffffc02007b2:	f5f6                	sd	t4,232(sp)
ffffffffc02007b4:	f9fa                	sd	t5,240(sp)
ffffffffc02007b6:	fdfe                	sd	t6,248(sp)
ffffffffc02007b8:	14001473          	csrrw	s0,sscratch,zero
ffffffffc02007bc:	100024f3          	csrr	s1,sstatus
ffffffffc02007c0:	14102973          	csrr	s2,sepc
ffffffffc02007c4:	143029f3          	csrr	s3,stval
ffffffffc02007c8:	14202a73          	csrr	s4,scause
ffffffffc02007cc:	e822                	sd	s0,16(sp)
ffffffffc02007ce:	e226                	sd	s1,256(sp)
ffffffffc02007d0:	e64a                	sd	s2,264(sp)
ffffffffc02007d2:	ea4e                	sd	s3,272(sp)
ffffffffc02007d4:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007d6:	850a                	mv	a0,sp
    jal trap
ffffffffc02007d8:	f83ff0ef          	jal	ra,ffffffffc020075a <trap>

ffffffffc02007dc <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007dc:	6492                	ld	s1,256(sp)
ffffffffc02007de:	6932                	ld	s2,264(sp)
ffffffffc02007e0:	10049073          	csrw	sstatus,s1
ffffffffc02007e4:	14191073          	csrw	sepc,s2
ffffffffc02007e8:	60a2                	ld	ra,8(sp)
ffffffffc02007ea:	61e2                	ld	gp,24(sp)
ffffffffc02007ec:	7202                	ld	tp,32(sp)
ffffffffc02007ee:	72a2                	ld	t0,40(sp)
ffffffffc02007f0:	7342                	ld	t1,48(sp)
ffffffffc02007f2:	73e2                	ld	t2,56(sp)
ffffffffc02007f4:	6406                	ld	s0,64(sp)
ffffffffc02007f6:	64a6                	ld	s1,72(sp)
ffffffffc02007f8:	6546                	ld	a0,80(sp)
ffffffffc02007fa:	65e6                	ld	a1,88(sp)
ffffffffc02007fc:	7606                	ld	a2,96(sp)
ffffffffc02007fe:	76a6                	ld	a3,104(sp)
ffffffffc0200800:	7746                	ld	a4,112(sp)
ffffffffc0200802:	77e6                	ld	a5,120(sp)
ffffffffc0200804:	680a                	ld	a6,128(sp)
ffffffffc0200806:	68aa                	ld	a7,136(sp)
ffffffffc0200808:	694a                	ld	s2,144(sp)
ffffffffc020080a:	69ea                	ld	s3,152(sp)
ffffffffc020080c:	7a0a                	ld	s4,160(sp)
ffffffffc020080e:	7aaa                	ld	s5,168(sp)
ffffffffc0200810:	7b4a                	ld	s6,176(sp)
ffffffffc0200812:	7bea                	ld	s7,184(sp)
ffffffffc0200814:	6c0e                	ld	s8,192(sp)
ffffffffc0200816:	6cae                	ld	s9,200(sp)
ffffffffc0200818:	6d4e                	ld	s10,208(sp)
ffffffffc020081a:	6dee                	ld	s11,216(sp)
ffffffffc020081c:	7e0e                	ld	t3,224(sp)
ffffffffc020081e:	7eae                	ld	t4,232(sp)
ffffffffc0200820:	7f4e                	ld	t5,240(sp)
ffffffffc0200822:	7fee                	ld	t6,248(sp)
ffffffffc0200824:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200826:	10200073          	sret

ffffffffc020082a <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020082a:	100027f3          	csrr	a5,sstatus
ffffffffc020082e:	8b89                	andi	a5,a5,2
ffffffffc0200830:	eb89                	bnez	a5,ffffffffc0200842 <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0200832:	00006797          	auipc	a5,0x6
ffffffffc0200836:	c0e78793          	addi	a5,a5,-1010 # ffffffffc0206440 <pmm_manager>
ffffffffc020083a:	639c                	ld	a5,0(a5)
ffffffffc020083c:	0187b303          	ld	t1,24(a5)
ffffffffc0200840:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc0200842:	1141                	addi	sp,sp,-16
ffffffffc0200844:	e406                	sd	ra,8(sp)
ffffffffc0200846:	e022                	sd	s0,0(sp)
ffffffffc0200848:	842a                	mv	s0,a0
        intr_disable();
ffffffffc020084a:	c1bff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020084e:	00006797          	auipc	a5,0x6
ffffffffc0200852:	bf278793          	addi	a5,a5,-1038 # ffffffffc0206440 <pmm_manager>
ffffffffc0200856:	639c                	ld	a5,0(a5)
ffffffffc0200858:	8522                	mv	a0,s0
ffffffffc020085a:	6f9c                	ld	a5,24(a5)
ffffffffc020085c:	9782                	jalr	a5
ffffffffc020085e:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0200860:	bffff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0200864:	8522                	mv	a0,s0
ffffffffc0200866:	60a2                	ld	ra,8(sp)
ffffffffc0200868:	6402                	ld	s0,0(sp)
ffffffffc020086a:	0141                	addi	sp,sp,16
ffffffffc020086c:	8082                	ret

ffffffffc020086e <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020086e:	100027f3          	csrr	a5,sstatus
ffffffffc0200872:	8b89                	andi	a5,a5,2
ffffffffc0200874:	eb89                	bnez	a5,ffffffffc0200886 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200876:	00006797          	auipc	a5,0x6
ffffffffc020087a:	bca78793          	addi	a5,a5,-1078 # ffffffffc0206440 <pmm_manager>
ffffffffc020087e:	639c                	ld	a5,0(a5)
ffffffffc0200880:	0207b303          	ld	t1,32(a5)
ffffffffc0200884:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0200886:	1101                	addi	sp,sp,-32
ffffffffc0200888:	ec06                	sd	ra,24(sp)
ffffffffc020088a:	e822                	sd	s0,16(sp)
ffffffffc020088c:	e426                	sd	s1,8(sp)
ffffffffc020088e:	842a                	mv	s0,a0
ffffffffc0200890:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200892:	bd3ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200896:	00006797          	auipc	a5,0x6
ffffffffc020089a:	baa78793          	addi	a5,a5,-1110 # ffffffffc0206440 <pmm_manager>
ffffffffc020089e:	639c                	ld	a5,0(a5)
ffffffffc02008a0:	85a6                	mv	a1,s1
ffffffffc02008a2:	8522                	mv	a0,s0
ffffffffc02008a4:	739c                	ld	a5,32(a5)
ffffffffc02008a6:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc02008a8:	6442                	ld	s0,16(sp)
ffffffffc02008aa:	60e2                	ld	ra,24(sp)
ffffffffc02008ac:	64a2                	ld	s1,8(sp)
ffffffffc02008ae:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02008b0:	bafff06f          	j	ffffffffc020045e <intr_enable>

ffffffffc02008b4 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02008b4:	100027f3          	csrr	a5,sstatus
ffffffffc02008b8:	8b89                	andi	a5,a5,2
ffffffffc02008ba:	eb89                	bnez	a5,ffffffffc02008cc <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc02008bc:	00006797          	auipc	a5,0x6
ffffffffc02008c0:	b8478793          	addi	a5,a5,-1148 # ffffffffc0206440 <pmm_manager>
ffffffffc02008c4:	639c                	ld	a5,0(a5)
ffffffffc02008c6:	0287b303          	ld	t1,40(a5)
ffffffffc02008ca:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc02008cc:	1141                	addi	sp,sp,-16
ffffffffc02008ce:	e406                	sd	ra,8(sp)
ffffffffc02008d0:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02008d2:	b93ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02008d6:	00006797          	auipc	a5,0x6
ffffffffc02008da:	b6a78793          	addi	a5,a5,-1174 # ffffffffc0206440 <pmm_manager>
ffffffffc02008de:	639c                	ld	a5,0(a5)
ffffffffc02008e0:	779c                	ld	a5,40(a5)
ffffffffc02008e2:	9782                	jalr	a5
ffffffffc02008e4:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02008e6:	b79ff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02008ea:	8522                	mv	a0,s0
ffffffffc02008ec:	60a2                	ld	ra,8(sp)
ffffffffc02008ee:	6402                	ld	s0,0(sp)
ffffffffc02008f0:	0141                	addi	sp,sp,16
ffffffffc02008f2:	8082                	ret

ffffffffc02008f4 <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02008f4:	00002797          	auipc	a5,0x2
ffffffffc02008f8:	d9478793          	addi	a5,a5,-620 # ffffffffc0202688 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02008fc:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02008fe:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200900:	00002517          	auipc	a0,0x2
ffffffffc0200904:	92850513          	addi	a0,a0,-1752 # ffffffffc0202228 <commands+0x610>
void pmm_init(void) {
ffffffffc0200908:	ec06                	sd	ra,24(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc020090a:	00006717          	auipc	a4,0x6
ffffffffc020090e:	b2f73b23          	sd	a5,-1226(a4) # ffffffffc0206440 <pmm_manager>
void pmm_init(void) {
ffffffffc0200912:	e822                	sd	s0,16(sp)
ffffffffc0200914:	e426                	sd	s1,8(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc0200916:	00006417          	auipc	s0,0x6
ffffffffc020091a:	b2a40413          	addi	s0,s0,-1238 # ffffffffc0206440 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020091e:	f98ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc0200922:	601c                	ld	a5,0(s0)
ffffffffc0200924:	679c                	ld	a5,8(a5)
ffffffffc0200926:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200928:	57f5                	li	a5,-3
ffffffffc020092a:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020092c:	00002517          	auipc	a0,0x2
ffffffffc0200930:	91450513          	addi	a0,a0,-1772 # ffffffffc0202240 <commands+0x628>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200934:	00006717          	auipc	a4,0x6
ffffffffc0200938:	b0f73a23          	sd	a5,-1260(a4) # ffffffffc0206448 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc020093c:	f7aff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200940:	46c5                	li	a3,17
ffffffffc0200942:	06ee                	slli	a3,a3,0x1b
ffffffffc0200944:	40100613          	li	a2,1025
ffffffffc0200948:	16fd                	addi	a3,a3,-1
ffffffffc020094a:	0656                	slli	a2,a2,0x15
ffffffffc020094c:	07e005b7          	lui	a1,0x7e00
ffffffffc0200950:	00002517          	auipc	a0,0x2
ffffffffc0200954:	90850513          	addi	a0,a0,-1784 # ffffffffc0202258 <commands+0x640>
ffffffffc0200958:	f5eff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020095c:	777d                	lui	a4,0xfffff
ffffffffc020095e:	00007797          	auipc	a5,0x7
ffffffffc0200962:	b1178793          	addi	a5,a5,-1263 # ffffffffc020746f <end+0xfff>
ffffffffc0200966:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200968:	00088737          	lui	a4,0x88
ffffffffc020096c:	00006697          	auipc	a3,0x6
ffffffffc0200970:	aae6b623          	sd	a4,-1364(a3) # ffffffffc0206418 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200974:	4601                	li	a2,0
ffffffffc0200976:	00006717          	auipc	a4,0x6
ffffffffc020097a:	acf73d23          	sd	a5,-1318(a4) # ffffffffc0206450 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020097e:	4681                	li	a3,0
ffffffffc0200980:	00006897          	auipc	a7,0x6
ffffffffc0200984:	a9888893          	addi	a7,a7,-1384 # ffffffffc0206418 <npage>
ffffffffc0200988:	00006597          	auipc	a1,0x6
ffffffffc020098c:	ac858593          	addi	a1,a1,-1336 # ffffffffc0206450 <pages>
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200990:	4805                	li	a6,1
ffffffffc0200992:	fff80537          	lui	a0,0xfff80
ffffffffc0200996:	a011                	j	ffffffffc020099a <pmm_init+0xa6>
ffffffffc0200998:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc020099a:	97b2                	add	a5,a5,a2
ffffffffc020099c:	07a1                	addi	a5,a5,8
ffffffffc020099e:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02009a2:	0008b703          	ld	a4,0(a7)
ffffffffc02009a6:	0685                	addi	a3,a3,1
ffffffffc02009a8:	02860613          	addi	a2,a2,40
ffffffffc02009ac:	00a707b3          	add	a5,a4,a0
ffffffffc02009b0:	fef6e4e3          	bltu	a3,a5,ffffffffc0200998 <pmm_init+0xa4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02009b4:	6190                	ld	a2,0(a1)
ffffffffc02009b6:	00271793          	slli	a5,a4,0x2
ffffffffc02009ba:	97ba                	add	a5,a5,a4
ffffffffc02009bc:	fec006b7          	lui	a3,0xfec00
ffffffffc02009c0:	078e                	slli	a5,a5,0x3
ffffffffc02009c2:	96b2                	add	a3,a3,a2
ffffffffc02009c4:	96be                	add	a3,a3,a5
ffffffffc02009c6:	c02007b7          	lui	a5,0xc0200
ffffffffc02009ca:	08f6e863          	bltu	a3,a5,ffffffffc0200a5a <pmm_init+0x166>
ffffffffc02009ce:	00006497          	auipc	s1,0x6
ffffffffc02009d2:	a7a48493          	addi	s1,s1,-1414 # ffffffffc0206448 <va_pa_offset>
ffffffffc02009d6:	609c                	ld	a5,0(s1)
    if (freemem < mem_end) {
ffffffffc02009d8:	45c5                	li	a1,17
ffffffffc02009da:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02009dc:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc02009de:	04b6e963          	bltu	a3,a1,ffffffffc0200a30 <pmm_init+0x13c>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02009e2:	601c                	ld	a5,0(s0)
ffffffffc02009e4:	7b9c                	ld	a5,48(a5)
ffffffffc02009e6:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02009e8:	00002517          	auipc	a0,0x2
ffffffffc02009ec:	90850513          	addi	a0,a0,-1784 # ffffffffc02022f0 <commands+0x6d8>
ffffffffc02009f0:	ec6ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02009f4:	00004697          	auipc	a3,0x4
ffffffffc02009f8:	60c68693          	addi	a3,a3,1548 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02009fc:	00006797          	auipc	a5,0x6
ffffffffc0200a00:	a2d7b223          	sd	a3,-1500(a5) # ffffffffc0206420 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200a04:	c02007b7          	lui	a5,0xc0200
ffffffffc0200a08:	06f6e563          	bltu	a3,a5,ffffffffc0200a72 <pmm_init+0x17e>
ffffffffc0200a0c:	609c                	ld	a5,0(s1)
}
ffffffffc0200a0e:	6442                	ld	s0,16(sp)
ffffffffc0200a10:	60e2                	ld	ra,24(sp)
ffffffffc0200a12:	64a2                	ld	s1,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200a14:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc0200a16:	8e9d                	sub	a3,a3,a5
ffffffffc0200a18:	00006797          	auipc	a5,0x6
ffffffffc0200a1c:	a2d7b023          	sd	a3,-1504(a5) # ffffffffc0206438 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200a20:	00002517          	auipc	a0,0x2
ffffffffc0200a24:	8f050513          	addi	a0,a0,-1808 # ffffffffc0202310 <commands+0x6f8>
ffffffffc0200a28:	8636                	mv	a2,a3
}
ffffffffc0200a2a:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200a2c:	e8aff06f          	j	ffffffffc02000b6 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200a30:	6785                	lui	a5,0x1
ffffffffc0200a32:	17fd                	addi	a5,a5,-1
ffffffffc0200a34:	96be                	add	a3,a3,a5
ffffffffc0200a36:	77fd                	lui	a5,0xfffff
ffffffffc0200a38:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200a3a:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200a3e:	04e7f663          	bleu	a4,a5,ffffffffc0200a8a <pmm_init+0x196>
    pmm_manager->init_memmap(base, n);
ffffffffc0200a42:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200a44:	97aa                	add	a5,a5,a0
ffffffffc0200a46:	00279513          	slli	a0,a5,0x2
ffffffffc0200a4a:	953e                	add	a0,a0,a5
ffffffffc0200a4c:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200a4e:	8d95                	sub	a1,a1,a3
ffffffffc0200a50:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200a52:	81b1                	srli	a1,a1,0xc
ffffffffc0200a54:	9532                	add	a0,a0,a2
ffffffffc0200a56:	9782                	jalr	a5
ffffffffc0200a58:	b769                	j	ffffffffc02009e2 <pmm_init+0xee>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200a5a:	00002617          	auipc	a2,0x2
ffffffffc0200a5e:	82e60613          	addi	a2,a2,-2002 # ffffffffc0202288 <commands+0x670>
ffffffffc0200a62:	06e00593          	li	a1,110
ffffffffc0200a66:	00002517          	auipc	a0,0x2
ffffffffc0200a6a:	84a50513          	addi	a0,a0,-1974 # ffffffffc02022b0 <commands+0x698>
ffffffffc0200a6e:	ed0ff0ef          	jal	ra,ffffffffc020013e <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200a72:	00002617          	auipc	a2,0x2
ffffffffc0200a76:	81660613          	addi	a2,a2,-2026 # ffffffffc0202288 <commands+0x670>
ffffffffc0200a7a:	08900593          	li	a1,137
ffffffffc0200a7e:	00002517          	auipc	a0,0x2
ffffffffc0200a82:	83250513          	addi	a0,a0,-1998 # ffffffffc02022b0 <commands+0x698>
ffffffffc0200a86:	eb8ff0ef          	jal	ra,ffffffffc020013e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0200a8a:	00002617          	auipc	a2,0x2
ffffffffc0200a8e:	83660613          	addi	a2,a2,-1994 # ffffffffc02022c0 <commands+0x6a8>
ffffffffc0200a92:	06b00593          	li	a1,107
ffffffffc0200a96:	00002517          	auipc	a0,0x2
ffffffffc0200a9a:	84a50513          	addi	a0,a0,-1974 # ffffffffc02022e0 <commands+0x6c8>
ffffffffc0200a9e:	ea0ff0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc0200aa2 <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200aa2:	00006797          	auipc	a5,0x6
ffffffffc0200aa6:	9b678793          	addi	a5,a5,-1610 # ffffffffc0206458 <free_area>
ffffffffc0200aaa:	e79c                	sd	a5,8(a5)
ffffffffc0200aac:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200aae:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200ab2:	8082                	ret

ffffffffc0200ab4 <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200ab4:	00006517          	auipc	a0,0x6
ffffffffc0200ab8:	9b456503          	lwu	a0,-1612(a0) # ffffffffc0206468 <free_area+0x10>
ffffffffc0200abc:	8082                	ret

ffffffffc0200abe <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc0200abe:	c545                	beqz	a0,ffffffffc0200b66 <best_fit_alloc_pages+0xa8>
    if (n > nr_free) {
ffffffffc0200ac0:	00006597          	auipc	a1,0x6
ffffffffc0200ac4:	99858593          	addi	a1,a1,-1640 # ffffffffc0206458 <free_area>
ffffffffc0200ac8:	0105a883          	lw	a7,16(a1)
ffffffffc0200acc:	862a                	mv	a2,a0
ffffffffc0200ace:	02089793          	slli	a5,a7,0x20
ffffffffc0200ad2:	9381                	srli	a5,a5,0x20
ffffffffc0200ad4:	08a7e763          	bltu	a5,a0,ffffffffc0200b62 <best_fit_alloc_pages+0xa4>
    unsigned int min_size = nr_free + 1;
ffffffffc0200ad8:	0018881b          	addiw	a6,a7,1
    list_entry_t *le = &free_list;
ffffffffc0200adc:	87ae                	mv	a5,a1
    struct Page *page = NULL;
ffffffffc0200ade:	4501                	li	a0,0
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200ae0:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ae2:	02b78163          	beq	a5,a1,ffffffffc0200b04 <best_fit_alloc_pages+0x46>
         if ((p->property >= n) && (p->property < min_size)) {
ffffffffc0200ae6:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200aea:	02071693          	slli	a3,a4,0x20
ffffffffc0200aee:	9281                	srli	a3,a3,0x20
ffffffffc0200af0:	fec6e8e3          	bltu	a3,a2,ffffffffc0200ae0 <best_fit_alloc_pages+0x22>
ffffffffc0200af4:	ff0776e3          	bleu	a6,a4,ffffffffc0200ae0 <best_fit_alloc_pages+0x22>
        struct Page *p = le2page(le, page_link);
ffffffffc0200af8:	fe878513          	addi	a0,a5,-24
ffffffffc0200afc:	679c                	ld	a5,8(a5)
ffffffffc0200afe:	883a                	mv	a6,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b00:	feb793e3          	bne	a5,a1,ffffffffc0200ae6 <best_fit_alloc_pages+0x28>
    if (page != NULL) {
ffffffffc0200b04:	c125                	beqz	a0,ffffffffc0200b64 <best_fit_alloc_pages+0xa6>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200b06:	7118                	ld	a4,32(a0)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc0200b08:	6d14                	ld	a3,24(a0)
        if (page->property > n) {
ffffffffc0200b0a:	490c                	lw	a1,16(a0)
ffffffffc0200b0c:	0006081b          	sext.w	a6,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200b10:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0200b12:	e314                	sd	a3,0(a4)
ffffffffc0200b14:	02059713          	slli	a4,a1,0x20
ffffffffc0200b18:	9301                	srli	a4,a4,0x20
ffffffffc0200b1a:	02e67863          	bleu	a4,a2,ffffffffc0200b4a <best_fit_alloc_pages+0x8c>
            struct Page *p = page + n;
ffffffffc0200b1e:	00261713          	slli	a4,a2,0x2
ffffffffc0200b22:	9732                	add	a4,a4,a2
ffffffffc0200b24:	070e                	slli	a4,a4,0x3
ffffffffc0200b26:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0200b28:	410585bb          	subw	a1,a1,a6
ffffffffc0200b2c:	cb0c                	sw	a1,16(a4)
ffffffffc0200b2e:	4609                	li	a2,2
ffffffffc0200b30:	00870593          	addi	a1,a4,8
ffffffffc0200b34:	40c5b02f          	amoor.d	zero,a2,(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200b38:	6690                	ld	a2,8(a3)
            list_add(prev, &(p->page_link));
ffffffffc0200b3a:	01870593          	addi	a1,a4,24
    prev->next = next->prev = elm;
ffffffffc0200b3e:	0107a883          	lw	a7,16(a5)
ffffffffc0200b42:	e20c                	sd	a1,0(a2)
ffffffffc0200b44:	e68c                	sd	a1,8(a3)
    elm->next = next;
ffffffffc0200b46:	f310                	sd	a2,32(a4)
    elm->prev = prev;
ffffffffc0200b48:	ef14                	sd	a3,24(a4)
        nr_free -= n;
ffffffffc0200b4a:	410888bb          	subw	a7,a7,a6
ffffffffc0200b4e:	00006797          	auipc	a5,0x6
ffffffffc0200b52:	9117ad23          	sw	a7,-1766(a5) # ffffffffc0206468 <free_area+0x10>
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200b56:	57f5                	li	a5,-3
ffffffffc0200b58:	00850713          	addi	a4,a0,8
ffffffffc0200b5c:	60f7302f          	amoand.d	zero,a5,(a4)
ffffffffc0200b60:	8082                	ret
        return NULL;
ffffffffc0200b62:	4501                	li	a0,0
}
ffffffffc0200b64:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc0200b66:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200b68:	00001697          	auipc	a3,0x1
ffffffffc0200b6c:	7e868693          	addi	a3,a3,2024 # ffffffffc0202350 <commands+0x738>
ffffffffc0200b70:	00001617          	auipc	a2,0x1
ffffffffc0200b74:	7e860613          	addi	a2,a2,2024 # ffffffffc0202358 <commands+0x740>
ffffffffc0200b78:	06900593          	li	a1,105
ffffffffc0200b7c:	00001517          	auipc	a0,0x1
ffffffffc0200b80:	7f450513          	addi	a0,a0,2036 # ffffffffc0202370 <commands+0x758>
best_fit_alloc_pages(size_t n) {
ffffffffc0200b84:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200b86:	db8ff0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc0200b8a <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc0200b8a:	715d                	addi	sp,sp,-80
ffffffffc0200b8c:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc0200b8e:	00006917          	auipc	s2,0x6
ffffffffc0200b92:	8ca90913          	addi	s2,s2,-1846 # ffffffffc0206458 <free_area>
ffffffffc0200b96:	00893783          	ld	a5,8(s2)
ffffffffc0200b9a:	e486                	sd	ra,72(sp)
ffffffffc0200b9c:	e0a2                	sd	s0,64(sp)
ffffffffc0200b9e:	fc26                	sd	s1,56(sp)
ffffffffc0200ba0:	f44e                	sd	s3,40(sp)
ffffffffc0200ba2:	f052                	sd	s4,32(sp)
ffffffffc0200ba4:	ec56                	sd	s5,24(sp)
ffffffffc0200ba6:	e85a                	sd	s6,16(sp)
ffffffffc0200ba8:	e45e                	sd	s7,8(sp)
ffffffffc0200baa:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bac:	2d278363          	beq	a5,s2,ffffffffc0200e72 <best_fit_check+0x2e8>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200bb0:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200bb4:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200bb6:	8b05                	andi	a4,a4,1
ffffffffc0200bb8:	2c070163          	beqz	a4,ffffffffc0200e7a <best_fit_check+0x2f0>
    int count = 0, total = 0;
ffffffffc0200bbc:	4401                	li	s0,0
ffffffffc0200bbe:	4481                	li	s1,0
ffffffffc0200bc0:	a031                	j	ffffffffc0200bcc <best_fit_check+0x42>
ffffffffc0200bc2:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200bc6:	8b09                	andi	a4,a4,2
ffffffffc0200bc8:	2a070963          	beqz	a4,ffffffffc0200e7a <best_fit_check+0x2f0>
        count ++, total += p->property;
ffffffffc0200bcc:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200bd0:	679c                	ld	a5,8(a5)
ffffffffc0200bd2:	2485                	addiw	s1,s1,1
ffffffffc0200bd4:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bd6:	ff2796e3          	bne	a5,s2,ffffffffc0200bc2 <best_fit_check+0x38>
ffffffffc0200bda:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200bdc:	cd9ff0ef          	jal	ra,ffffffffc02008b4 <nr_free_pages>
ffffffffc0200be0:	37351d63          	bne	a0,s3,ffffffffc0200f5a <best_fit_check+0x3d0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200be4:	4505                	li	a0,1
ffffffffc0200be6:	c45ff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200bea:	8a2a                	mv	s4,a0
ffffffffc0200bec:	3a050763          	beqz	a0,ffffffffc0200f9a <best_fit_check+0x410>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200bf0:	4505                	li	a0,1
ffffffffc0200bf2:	c39ff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200bf6:	89aa                	mv	s3,a0
ffffffffc0200bf8:	38050163          	beqz	a0,ffffffffc0200f7a <best_fit_check+0x3f0>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200bfc:	4505                	li	a0,1
ffffffffc0200bfe:	c2dff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200c02:	8aaa                	mv	s5,a0
ffffffffc0200c04:	30050b63          	beqz	a0,ffffffffc0200f1a <best_fit_check+0x390>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200c08:	293a0963          	beq	s4,s3,ffffffffc0200e9a <best_fit_check+0x310>
ffffffffc0200c0c:	28aa0763          	beq	s4,a0,ffffffffc0200e9a <best_fit_check+0x310>
ffffffffc0200c10:	28a98563          	beq	s3,a0,ffffffffc0200e9a <best_fit_check+0x310>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200c14:	000a2783          	lw	a5,0(s4)
ffffffffc0200c18:	2a079163          	bnez	a5,ffffffffc0200eba <best_fit_check+0x330>
ffffffffc0200c1c:	0009a783          	lw	a5,0(s3)
ffffffffc0200c20:	28079d63          	bnez	a5,ffffffffc0200eba <best_fit_check+0x330>
ffffffffc0200c24:	411c                	lw	a5,0(a0)
ffffffffc0200c26:	28079a63          	bnez	a5,ffffffffc0200eba <best_fit_check+0x330>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c2a:	00006797          	auipc	a5,0x6
ffffffffc0200c2e:	82678793          	addi	a5,a5,-2010 # ffffffffc0206450 <pages>
ffffffffc0200c32:	639c                	ld	a5,0(a5)
ffffffffc0200c34:	00001717          	auipc	a4,0x1
ffffffffc0200c38:	75470713          	addi	a4,a4,1876 # ffffffffc0202388 <commands+0x770>
ffffffffc0200c3c:	630c                	ld	a1,0(a4)
ffffffffc0200c3e:	40fa0733          	sub	a4,s4,a5
ffffffffc0200c42:	870d                	srai	a4,a4,0x3
ffffffffc0200c44:	02b70733          	mul	a4,a4,a1
ffffffffc0200c48:	00002697          	auipc	a3,0x2
ffffffffc0200c4c:	cd868693          	addi	a3,a3,-808 # ffffffffc0202920 <nbase>
ffffffffc0200c50:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200c52:	00005697          	auipc	a3,0x5
ffffffffc0200c56:	7c668693          	addi	a3,a3,1990 # ffffffffc0206418 <npage>
ffffffffc0200c5a:	6294                	ld	a3,0(a3)
ffffffffc0200c5c:	06b2                	slli	a3,a3,0xc
ffffffffc0200c5e:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c60:	0732                	slli	a4,a4,0xc
ffffffffc0200c62:	26d77c63          	bleu	a3,a4,ffffffffc0200eda <best_fit_check+0x350>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c66:	40f98733          	sub	a4,s3,a5
ffffffffc0200c6a:	870d                	srai	a4,a4,0x3
ffffffffc0200c6c:	02b70733          	mul	a4,a4,a1
ffffffffc0200c70:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c72:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200c74:	42d77363          	bleu	a3,a4,ffffffffc020109a <best_fit_check+0x510>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c78:	40f507b3          	sub	a5,a0,a5
ffffffffc0200c7c:	878d                	srai	a5,a5,0x3
ffffffffc0200c7e:	02b787b3          	mul	a5,a5,a1
ffffffffc0200c82:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c84:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200c86:	3ed7fa63          	bleu	a3,a5,ffffffffc020107a <best_fit_check+0x4f0>
    assert(alloc_page() == NULL);
ffffffffc0200c8a:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200c8c:	00093c03          	ld	s8,0(s2)
ffffffffc0200c90:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200c94:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200c98:	00005797          	auipc	a5,0x5
ffffffffc0200c9c:	7d27b423          	sd	s2,1992(a5) # ffffffffc0206460 <free_area+0x8>
ffffffffc0200ca0:	00005797          	auipc	a5,0x5
ffffffffc0200ca4:	7b27bc23          	sd	s2,1976(a5) # ffffffffc0206458 <free_area>
    nr_free = 0;
ffffffffc0200ca8:	00005797          	auipc	a5,0x5
ffffffffc0200cac:	7c07a023          	sw	zero,1984(a5) # ffffffffc0206468 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200cb0:	b7bff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200cb4:	3a051363          	bnez	a0,ffffffffc020105a <best_fit_check+0x4d0>
    free_page(p0);
ffffffffc0200cb8:	4585                	li	a1,1
ffffffffc0200cba:	8552                	mv	a0,s4
ffffffffc0200cbc:	bb3ff0ef          	jal	ra,ffffffffc020086e <free_pages>
    free_page(p1);
ffffffffc0200cc0:	4585                	li	a1,1
ffffffffc0200cc2:	854e                	mv	a0,s3
ffffffffc0200cc4:	babff0ef          	jal	ra,ffffffffc020086e <free_pages>
    free_page(p2);
ffffffffc0200cc8:	4585                	li	a1,1
ffffffffc0200cca:	8556                	mv	a0,s5
ffffffffc0200ccc:	ba3ff0ef          	jal	ra,ffffffffc020086e <free_pages>
    assert(nr_free == 3);
ffffffffc0200cd0:	01092703          	lw	a4,16(s2)
ffffffffc0200cd4:	478d                	li	a5,3
ffffffffc0200cd6:	36f71263          	bne	a4,a5,ffffffffc020103a <best_fit_check+0x4b0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200cda:	4505                	li	a0,1
ffffffffc0200cdc:	b4fff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200ce0:	89aa                	mv	s3,a0
ffffffffc0200ce2:	32050c63          	beqz	a0,ffffffffc020101a <best_fit_check+0x490>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200ce6:	4505                	li	a0,1
ffffffffc0200ce8:	b43ff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200cec:	8aaa                	mv	s5,a0
ffffffffc0200cee:	30050663          	beqz	a0,ffffffffc0200ffa <best_fit_check+0x470>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200cf2:	4505                	li	a0,1
ffffffffc0200cf4:	b37ff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200cf8:	8a2a                	mv	s4,a0
ffffffffc0200cfa:	2e050063          	beqz	a0,ffffffffc0200fda <best_fit_check+0x450>
    assert(alloc_page() == NULL);
ffffffffc0200cfe:	4505                	li	a0,1
ffffffffc0200d00:	b2bff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200d04:	2a051b63          	bnez	a0,ffffffffc0200fba <best_fit_check+0x430>
    free_page(p0);
ffffffffc0200d08:	4585                	li	a1,1
ffffffffc0200d0a:	854e                	mv	a0,s3
ffffffffc0200d0c:	b63ff0ef          	jal	ra,ffffffffc020086e <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200d10:	00893783          	ld	a5,8(s2)
ffffffffc0200d14:	1f278363          	beq	a5,s2,ffffffffc0200efa <best_fit_check+0x370>
    assert((p = alloc_page()) == p0);
ffffffffc0200d18:	4505                	li	a0,1
ffffffffc0200d1a:	b11ff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200d1e:	54a99e63          	bne	s3,a0,ffffffffc020127a <best_fit_check+0x6f0>
    assert(alloc_page() == NULL);
ffffffffc0200d22:	4505                	li	a0,1
ffffffffc0200d24:	b07ff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200d28:	52051963          	bnez	a0,ffffffffc020125a <best_fit_check+0x6d0>
    assert(nr_free == 0);
ffffffffc0200d2c:	01092783          	lw	a5,16(s2)
ffffffffc0200d30:	50079563          	bnez	a5,ffffffffc020123a <best_fit_check+0x6b0>
    free_page(p);
ffffffffc0200d34:	854e                	mv	a0,s3
ffffffffc0200d36:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200d38:	00005797          	auipc	a5,0x5
ffffffffc0200d3c:	7387b023          	sd	s8,1824(a5) # ffffffffc0206458 <free_area>
ffffffffc0200d40:	00005797          	auipc	a5,0x5
ffffffffc0200d44:	7377b023          	sd	s7,1824(a5) # ffffffffc0206460 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200d48:	00005797          	auipc	a5,0x5
ffffffffc0200d4c:	7367a023          	sw	s6,1824(a5) # ffffffffc0206468 <free_area+0x10>
    free_page(p);
ffffffffc0200d50:	b1fff0ef          	jal	ra,ffffffffc020086e <free_pages>
    free_page(p1);
ffffffffc0200d54:	4585                	li	a1,1
ffffffffc0200d56:	8556                	mv	a0,s5
ffffffffc0200d58:	b17ff0ef          	jal	ra,ffffffffc020086e <free_pages>
    free_page(p2);
ffffffffc0200d5c:	4585                	li	a1,1
ffffffffc0200d5e:	8552                	mv	a0,s4
ffffffffc0200d60:	b0fff0ef          	jal	ra,ffffffffc020086e <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200d64:	4515                	li	a0,5
ffffffffc0200d66:	ac5ff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200d6a:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200d6c:	4a050763          	beqz	a0,ffffffffc020121a <best_fit_check+0x690>
ffffffffc0200d70:	651c                	ld	a5,8(a0)
ffffffffc0200d72:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200d74:	8b85                	andi	a5,a5,1
ffffffffc0200d76:	48079263          	bnez	a5,ffffffffc02011fa <best_fit_check+0x670>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200d7a:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200d7c:	00093b03          	ld	s6,0(s2)
ffffffffc0200d80:	00893a83          	ld	s5,8(s2)
ffffffffc0200d84:	00005797          	auipc	a5,0x5
ffffffffc0200d88:	6d27ba23          	sd	s2,1748(a5) # ffffffffc0206458 <free_area>
ffffffffc0200d8c:	00005797          	auipc	a5,0x5
ffffffffc0200d90:	6d27ba23          	sd	s2,1748(a5) # ffffffffc0206460 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200d94:	a97ff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200d98:	44051163          	bnez	a0,ffffffffc02011da <best_fit_check+0x650>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc0200d9c:	4589                	li	a1,2
ffffffffc0200d9e:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc0200da2:	01092b83          	lw	s7,16(s2)
    free_pages(p0 + 4, 1);
ffffffffc0200da6:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc0200daa:	00005797          	auipc	a5,0x5
ffffffffc0200dae:	6a07af23          	sw	zero,1726(a5) # ffffffffc0206468 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200db2:	abdff0ef          	jal	ra,ffffffffc020086e <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200db6:	8562                	mv	a0,s8
ffffffffc0200db8:	4585                	li	a1,1
ffffffffc0200dba:	ab5ff0ef          	jal	ra,ffffffffc020086e <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200dbe:	4511                	li	a0,4
ffffffffc0200dc0:	a6bff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200dc4:	3e051b63          	bnez	a0,ffffffffc02011ba <best_fit_check+0x630>
ffffffffc0200dc8:	0309b783          	ld	a5,48(s3)
ffffffffc0200dcc:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200dce:	8b85                	andi	a5,a5,1
ffffffffc0200dd0:	3c078563          	beqz	a5,ffffffffc020119a <best_fit_check+0x610>
ffffffffc0200dd4:	0389a703          	lw	a4,56(s3)
ffffffffc0200dd8:	4789                	li	a5,2
ffffffffc0200dda:	3cf71063          	bne	a4,a5,ffffffffc020119a <best_fit_check+0x610>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200dde:	4505                	li	a0,1
ffffffffc0200de0:	a4bff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200de4:	8a2a                	mv	s4,a0
ffffffffc0200de6:	38050a63          	beqz	a0,ffffffffc020117a <best_fit_check+0x5f0>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200dea:	4509                	li	a0,2
ffffffffc0200dec:	a3fff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200df0:	36050563          	beqz	a0,ffffffffc020115a <best_fit_check+0x5d0>
    assert(p0 + 4 == p1);
ffffffffc0200df4:	354c1363          	bne	s8,s4,ffffffffc020113a <best_fit_check+0x5b0>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0200df8:	854e                	mv	a0,s3
ffffffffc0200dfa:	4595                	li	a1,5
ffffffffc0200dfc:	a73ff0ef          	jal	ra,ffffffffc020086e <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200e00:	4515                	li	a0,5
ffffffffc0200e02:	a29ff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200e06:	89aa                	mv	s3,a0
ffffffffc0200e08:	30050963          	beqz	a0,ffffffffc020111a <best_fit_check+0x590>
    assert(alloc_page() == NULL);
ffffffffc0200e0c:	4505                	li	a0,1
ffffffffc0200e0e:	a1dff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200e12:	2e051463          	bnez	a0,ffffffffc02010fa <best_fit_check+0x570>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0200e16:	01092783          	lw	a5,16(s2)
ffffffffc0200e1a:	2c079063          	bnez	a5,ffffffffc02010da <best_fit_check+0x550>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200e1e:	4595                	li	a1,5
ffffffffc0200e20:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200e22:	00005797          	auipc	a5,0x5
ffffffffc0200e26:	6577a323          	sw	s7,1606(a5) # ffffffffc0206468 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200e2a:	00005797          	auipc	a5,0x5
ffffffffc0200e2e:	6367b723          	sd	s6,1582(a5) # ffffffffc0206458 <free_area>
ffffffffc0200e32:	00005797          	auipc	a5,0x5
ffffffffc0200e36:	6357b723          	sd	s5,1582(a5) # ffffffffc0206460 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200e3a:	a35ff0ef          	jal	ra,ffffffffc020086e <free_pages>
    return listelm->next;
ffffffffc0200e3e:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e42:	01278963          	beq	a5,s2,ffffffffc0200e54 <best_fit_check+0x2ca>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200e46:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e4a:	679c                	ld	a5,8(a5)
ffffffffc0200e4c:	34fd                	addiw	s1,s1,-1
ffffffffc0200e4e:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e50:	ff279be3          	bne	a5,s2,ffffffffc0200e46 <best_fit_check+0x2bc>
    }
    assert(count == 0);
ffffffffc0200e54:	26049363          	bnez	s1,ffffffffc02010ba <best_fit_check+0x530>
    assert(total == 0);
ffffffffc0200e58:	e06d                	bnez	s0,ffffffffc0200f3a <best_fit_check+0x3b0>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc0200e5a:	60a6                	ld	ra,72(sp)
ffffffffc0200e5c:	6406                	ld	s0,64(sp)
ffffffffc0200e5e:	74e2                	ld	s1,56(sp)
ffffffffc0200e60:	7942                	ld	s2,48(sp)
ffffffffc0200e62:	79a2                	ld	s3,40(sp)
ffffffffc0200e64:	7a02                	ld	s4,32(sp)
ffffffffc0200e66:	6ae2                	ld	s5,24(sp)
ffffffffc0200e68:	6b42                	ld	s6,16(sp)
ffffffffc0200e6a:	6ba2                	ld	s7,8(sp)
ffffffffc0200e6c:	6c02                	ld	s8,0(sp)
ffffffffc0200e6e:	6161                	addi	sp,sp,80
ffffffffc0200e70:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e72:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200e74:	4401                	li	s0,0
ffffffffc0200e76:	4481                	li	s1,0
ffffffffc0200e78:	b395                	j	ffffffffc0200bdc <best_fit_check+0x52>
        assert(PageProperty(p));
ffffffffc0200e7a:	00001697          	auipc	a3,0x1
ffffffffc0200e7e:	51668693          	addi	a3,a3,1302 # ffffffffc0202390 <commands+0x778>
ffffffffc0200e82:	00001617          	auipc	a2,0x1
ffffffffc0200e86:	4d660613          	addi	a2,a2,1238 # ffffffffc0202358 <commands+0x740>
ffffffffc0200e8a:	10a00593          	li	a1,266
ffffffffc0200e8e:	00001517          	auipc	a0,0x1
ffffffffc0200e92:	4e250513          	addi	a0,a0,1250 # ffffffffc0202370 <commands+0x758>
ffffffffc0200e96:	aa8ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200e9a:	00001697          	auipc	a3,0x1
ffffffffc0200e9e:	58668693          	addi	a3,a3,1414 # ffffffffc0202420 <commands+0x808>
ffffffffc0200ea2:	00001617          	auipc	a2,0x1
ffffffffc0200ea6:	4b660613          	addi	a2,a2,1206 # ffffffffc0202358 <commands+0x740>
ffffffffc0200eaa:	0d600593          	li	a1,214
ffffffffc0200eae:	00001517          	auipc	a0,0x1
ffffffffc0200eb2:	4c250513          	addi	a0,a0,1218 # ffffffffc0202370 <commands+0x758>
ffffffffc0200eb6:	a88ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200eba:	00001697          	auipc	a3,0x1
ffffffffc0200ebe:	58e68693          	addi	a3,a3,1422 # ffffffffc0202448 <commands+0x830>
ffffffffc0200ec2:	00001617          	auipc	a2,0x1
ffffffffc0200ec6:	49660613          	addi	a2,a2,1174 # ffffffffc0202358 <commands+0x740>
ffffffffc0200eca:	0d700593          	li	a1,215
ffffffffc0200ece:	00001517          	auipc	a0,0x1
ffffffffc0200ed2:	4a250513          	addi	a0,a0,1186 # ffffffffc0202370 <commands+0x758>
ffffffffc0200ed6:	a68ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200eda:	00001697          	auipc	a3,0x1
ffffffffc0200ede:	5ae68693          	addi	a3,a3,1454 # ffffffffc0202488 <commands+0x870>
ffffffffc0200ee2:	00001617          	auipc	a2,0x1
ffffffffc0200ee6:	47660613          	addi	a2,a2,1142 # ffffffffc0202358 <commands+0x740>
ffffffffc0200eea:	0d900593          	li	a1,217
ffffffffc0200eee:	00001517          	auipc	a0,0x1
ffffffffc0200ef2:	48250513          	addi	a0,a0,1154 # ffffffffc0202370 <commands+0x758>
ffffffffc0200ef6:	a48ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200efa:	00001697          	auipc	a3,0x1
ffffffffc0200efe:	61668693          	addi	a3,a3,1558 # ffffffffc0202510 <commands+0x8f8>
ffffffffc0200f02:	00001617          	auipc	a2,0x1
ffffffffc0200f06:	45660613          	addi	a2,a2,1110 # ffffffffc0202358 <commands+0x740>
ffffffffc0200f0a:	0f200593          	li	a1,242
ffffffffc0200f0e:	00001517          	auipc	a0,0x1
ffffffffc0200f12:	46250513          	addi	a0,a0,1122 # ffffffffc0202370 <commands+0x758>
ffffffffc0200f16:	a28ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200f1a:	00001697          	auipc	a3,0x1
ffffffffc0200f1e:	4e668693          	addi	a3,a3,1254 # ffffffffc0202400 <commands+0x7e8>
ffffffffc0200f22:	00001617          	auipc	a2,0x1
ffffffffc0200f26:	43660613          	addi	a2,a2,1078 # ffffffffc0202358 <commands+0x740>
ffffffffc0200f2a:	0d400593          	li	a1,212
ffffffffc0200f2e:	00001517          	auipc	a0,0x1
ffffffffc0200f32:	44250513          	addi	a0,a0,1090 # ffffffffc0202370 <commands+0x758>
ffffffffc0200f36:	a08ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(total == 0);
ffffffffc0200f3a:	00001697          	auipc	a3,0x1
ffffffffc0200f3e:	70668693          	addi	a3,a3,1798 # ffffffffc0202640 <commands+0xa28>
ffffffffc0200f42:	00001617          	auipc	a2,0x1
ffffffffc0200f46:	41660613          	addi	a2,a2,1046 # ffffffffc0202358 <commands+0x740>
ffffffffc0200f4a:	14c00593          	li	a1,332
ffffffffc0200f4e:	00001517          	auipc	a0,0x1
ffffffffc0200f52:	42250513          	addi	a0,a0,1058 # ffffffffc0202370 <commands+0x758>
ffffffffc0200f56:	9e8ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(total == nr_free_pages());
ffffffffc0200f5a:	00001697          	auipc	a3,0x1
ffffffffc0200f5e:	44668693          	addi	a3,a3,1094 # ffffffffc02023a0 <commands+0x788>
ffffffffc0200f62:	00001617          	auipc	a2,0x1
ffffffffc0200f66:	3f660613          	addi	a2,a2,1014 # ffffffffc0202358 <commands+0x740>
ffffffffc0200f6a:	10d00593          	li	a1,269
ffffffffc0200f6e:	00001517          	auipc	a0,0x1
ffffffffc0200f72:	40250513          	addi	a0,a0,1026 # ffffffffc0202370 <commands+0x758>
ffffffffc0200f76:	9c8ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200f7a:	00001697          	auipc	a3,0x1
ffffffffc0200f7e:	46668693          	addi	a3,a3,1126 # ffffffffc02023e0 <commands+0x7c8>
ffffffffc0200f82:	00001617          	auipc	a2,0x1
ffffffffc0200f86:	3d660613          	addi	a2,a2,982 # ffffffffc0202358 <commands+0x740>
ffffffffc0200f8a:	0d300593          	li	a1,211
ffffffffc0200f8e:	00001517          	auipc	a0,0x1
ffffffffc0200f92:	3e250513          	addi	a0,a0,994 # ffffffffc0202370 <commands+0x758>
ffffffffc0200f96:	9a8ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f9a:	00001697          	auipc	a3,0x1
ffffffffc0200f9e:	42668693          	addi	a3,a3,1062 # ffffffffc02023c0 <commands+0x7a8>
ffffffffc0200fa2:	00001617          	auipc	a2,0x1
ffffffffc0200fa6:	3b660613          	addi	a2,a2,950 # ffffffffc0202358 <commands+0x740>
ffffffffc0200faa:	0d200593          	li	a1,210
ffffffffc0200fae:	00001517          	auipc	a0,0x1
ffffffffc0200fb2:	3c250513          	addi	a0,a0,962 # ffffffffc0202370 <commands+0x758>
ffffffffc0200fb6:	988ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fba:	00001697          	auipc	a3,0x1
ffffffffc0200fbe:	52e68693          	addi	a3,a3,1326 # ffffffffc02024e8 <commands+0x8d0>
ffffffffc0200fc2:	00001617          	auipc	a2,0x1
ffffffffc0200fc6:	39660613          	addi	a2,a2,918 # ffffffffc0202358 <commands+0x740>
ffffffffc0200fca:	0ef00593          	li	a1,239
ffffffffc0200fce:	00001517          	auipc	a0,0x1
ffffffffc0200fd2:	3a250513          	addi	a0,a0,930 # ffffffffc0202370 <commands+0x758>
ffffffffc0200fd6:	968ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200fda:	00001697          	auipc	a3,0x1
ffffffffc0200fde:	42668693          	addi	a3,a3,1062 # ffffffffc0202400 <commands+0x7e8>
ffffffffc0200fe2:	00001617          	auipc	a2,0x1
ffffffffc0200fe6:	37660613          	addi	a2,a2,886 # ffffffffc0202358 <commands+0x740>
ffffffffc0200fea:	0ed00593          	li	a1,237
ffffffffc0200fee:	00001517          	auipc	a0,0x1
ffffffffc0200ff2:	38250513          	addi	a0,a0,898 # ffffffffc0202370 <commands+0x758>
ffffffffc0200ff6:	948ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200ffa:	00001697          	auipc	a3,0x1
ffffffffc0200ffe:	3e668693          	addi	a3,a3,998 # ffffffffc02023e0 <commands+0x7c8>
ffffffffc0201002:	00001617          	auipc	a2,0x1
ffffffffc0201006:	35660613          	addi	a2,a2,854 # ffffffffc0202358 <commands+0x740>
ffffffffc020100a:	0ec00593          	li	a1,236
ffffffffc020100e:	00001517          	auipc	a0,0x1
ffffffffc0201012:	36250513          	addi	a0,a0,866 # ffffffffc0202370 <commands+0x758>
ffffffffc0201016:	928ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020101a:	00001697          	auipc	a3,0x1
ffffffffc020101e:	3a668693          	addi	a3,a3,934 # ffffffffc02023c0 <commands+0x7a8>
ffffffffc0201022:	00001617          	auipc	a2,0x1
ffffffffc0201026:	33660613          	addi	a2,a2,822 # ffffffffc0202358 <commands+0x740>
ffffffffc020102a:	0eb00593          	li	a1,235
ffffffffc020102e:	00001517          	auipc	a0,0x1
ffffffffc0201032:	34250513          	addi	a0,a0,834 # ffffffffc0202370 <commands+0x758>
ffffffffc0201036:	908ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(nr_free == 3);
ffffffffc020103a:	00001697          	auipc	a3,0x1
ffffffffc020103e:	4c668693          	addi	a3,a3,1222 # ffffffffc0202500 <commands+0x8e8>
ffffffffc0201042:	00001617          	auipc	a2,0x1
ffffffffc0201046:	31660613          	addi	a2,a2,790 # ffffffffc0202358 <commands+0x740>
ffffffffc020104a:	0e900593          	li	a1,233
ffffffffc020104e:	00001517          	auipc	a0,0x1
ffffffffc0201052:	32250513          	addi	a0,a0,802 # ffffffffc0202370 <commands+0x758>
ffffffffc0201056:	8e8ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(alloc_page() == NULL);
ffffffffc020105a:	00001697          	auipc	a3,0x1
ffffffffc020105e:	48e68693          	addi	a3,a3,1166 # ffffffffc02024e8 <commands+0x8d0>
ffffffffc0201062:	00001617          	auipc	a2,0x1
ffffffffc0201066:	2f660613          	addi	a2,a2,758 # ffffffffc0202358 <commands+0x740>
ffffffffc020106a:	0e400593          	li	a1,228
ffffffffc020106e:	00001517          	auipc	a0,0x1
ffffffffc0201072:	30250513          	addi	a0,a0,770 # ffffffffc0202370 <commands+0x758>
ffffffffc0201076:	8c8ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc020107a:	00001697          	auipc	a3,0x1
ffffffffc020107e:	44e68693          	addi	a3,a3,1102 # ffffffffc02024c8 <commands+0x8b0>
ffffffffc0201082:	00001617          	auipc	a2,0x1
ffffffffc0201086:	2d660613          	addi	a2,a2,726 # ffffffffc0202358 <commands+0x740>
ffffffffc020108a:	0db00593          	li	a1,219
ffffffffc020108e:	00001517          	auipc	a0,0x1
ffffffffc0201092:	2e250513          	addi	a0,a0,738 # ffffffffc0202370 <commands+0x758>
ffffffffc0201096:	8a8ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020109a:	00001697          	auipc	a3,0x1
ffffffffc020109e:	40e68693          	addi	a3,a3,1038 # ffffffffc02024a8 <commands+0x890>
ffffffffc02010a2:	00001617          	auipc	a2,0x1
ffffffffc02010a6:	2b660613          	addi	a2,a2,694 # ffffffffc0202358 <commands+0x740>
ffffffffc02010aa:	0da00593          	li	a1,218
ffffffffc02010ae:	00001517          	auipc	a0,0x1
ffffffffc02010b2:	2c250513          	addi	a0,a0,706 # ffffffffc0202370 <commands+0x758>
ffffffffc02010b6:	888ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(count == 0);
ffffffffc02010ba:	00001697          	auipc	a3,0x1
ffffffffc02010be:	57668693          	addi	a3,a3,1398 # ffffffffc0202630 <commands+0xa18>
ffffffffc02010c2:	00001617          	auipc	a2,0x1
ffffffffc02010c6:	29660613          	addi	a2,a2,662 # ffffffffc0202358 <commands+0x740>
ffffffffc02010ca:	14b00593          	li	a1,331
ffffffffc02010ce:	00001517          	auipc	a0,0x1
ffffffffc02010d2:	2a250513          	addi	a0,a0,674 # ffffffffc0202370 <commands+0x758>
ffffffffc02010d6:	868ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(nr_free == 0);
ffffffffc02010da:	00001697          	auipc	a3,0x1
ffffffffc02010de:	46e68693          	addi	a3,a3,1134 # ffffffffc0202548 <commands+0x930>
ffffffffc02010e2:	00001617          	auipc	a2,0x1
ffffffffc02010e6:	27660613          	addi	a2,a2,630 # ffffffffc0202358 <commands+0x740>
ffffffffc02010ea:	14000593          	li	a1,320
ffffffffc02010ee:	00001517          	auipc	a0,0x1
ffffffffc02010f2:	28250513          	addi	a0,a0,642 # ffffffffc0202370 <commands+0x758>
ffffffffc02010f6:	848ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(alloc_page() == NULL);
ffffffffc02010fa:	00001697          	auipc	a3,0x1
ffffffffc02010fe:	3ee68693          	addi	a3,a3,1006 # ffffffffc02024e8 <commands+0x8d0>
ffffffffc0201102:	00001617          	auipc	a2,0x1
ffffffffc0201106:	25660613          	addi	a2,a2,598 # ffffffffc0202358 <commands+0x740>
ffffffffc020110a:	13a00593          	li	a1,314
ffffffffc020110e:	00001517          	auipc	a0,0x1
ffffffffc0201112:	26250513          	addi	a0,a0,610 # ffffffffc0202370 <commands+0x758>
ffffffffc0201116:	828ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020111a:	00001697          	auipc	a3,0x1
ffffffffc020111e:	4f668693          	addi	a3,a3,1270 # ffffffffc0202610 <commands+0x9f8>
ffffffffc0201122:	00001617          	auipc	a2,0x1
ffffffffc0201126:	23660613          	addi	a2,a2,566 # ffffffffc0202358 <commands+0x740>
ffffffffc020112a:	13900593          	li	a1,313
ffffffffc020112e:	00001517          	auipc	a0,0x1
ffffffffc0201132:	24250513          	addi	a0,a0,578 # ffffffffc0202370 <commands+0x758>
ffffffffc0201136:	808ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(p0 + 4 == p1);
ffffffffc020113a:	00001697          	auipc	a3,0x1
ffffffffc020113e:	4c668693          	addi	a3,a3,1222 # ffffffffc0202600 <commands+0x9e8>
ffffffffc0201142:	00001617          	auipc	a2,0x1
ffffffffc0201146:	21660613          	addi	a2,a2,534 # ffffffffc0202358 <commands+0x740>
ffffffffc020114a:	13100593          	li	a1,305
ffffffffc020114e:	00001517          	auipc	a0,0x1
ffffffffc0201152:	22250513          	addi	a0,a0,546 # ffffffffc0202370 <commands+0x758>
ffffffffc0201156:	fe9fe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc020115a:	00001697          	auipc	a3,0x1
ffffffffc020115e:	48e68693          	addi	a3,a3,1166 # ffffffffc02025e8 <commands+0x9d0>
ffffffffc0201162:	00001617          	auipc	a2,0x1
ffffffffc0201166:	1f660613          	addi	a2,a2,502 # ffffffffc0202358 <commands+0x740>
ffffffffc020116a:	13000593          	li	a1,304
ffffffffc020116e:	00001517          	auipc	a0,0x1
ffffffffc0201172:	20250513          	addi	a0,a0,514 # ffffffffc0202370 <commands+0x758>
ffffffffc0201176:	fc9fe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc020117a:	00001697          	auipc	a3,0x1
ffffffffc020117e:	44e68693          	addi	a3,a3,1102 # ffffffffc02025c8 <commands+0x9b0>
ffffffffc0201182:	00001617          	auipc	a2,0x1
ffffffffc0201186:	1d660613          	addi	a2,a2,470 # ffffffffc0202358 <commands+0x740>
ffffffffc020118a:	12f00593          	li	a1,303
ffffffffc020118e:	00001517          	auipc	a0,0x1
ffffffffc0201192:	1e250513          	addi	a0,a0,482 # ffffffffc0202370 <commands+0x758>
ffffffffc0201196:	fa9fe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc020119a:	00001697          	auipc	a3,0x1
ffffffffc020119e:	3fe68693          	addi	a3,a3,1022 # ffffffffc0202598 <commands+0x980>
ffffffffc02011a2:	00001617          	auipc	a2,0x1
ffffffffc02011a6:	1b660613          	addi	a2,a2,438 # ffffffffc0202358 <commands+0x740>
ffffffffc02011aa:	12d00593          	li	a1,301
ffffffffc02011ae:	00001517          	auipc	a0,0x1
ffffffffc02011b2:	1c250513          	addi	a0,a0,450 # ffffffffc0202370 <commands+0x758>
ffffffffc02011b6:	f89fe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02011ba:	00001697          	auipc	a3,0x1
ffffffffc02011be:	3c668693          	addi	a3,a3,966 # ffffffffc0202580 <commands+0x968>
ffffffffc02011c2:	00001617          	auipc	a2,0x1
ffffffffc02011c6:	19660613          	addi	a2,a2,406 # ffffffffc0202358 <commands+0x740>
ffffffffc02011ca:	12c00593          	li	a1,300
ffffffffc02011ce:	00001517          	auipc	a0,0x1
ffffffffc02011d2:	1a250513          	addi	a0,a0,418 # ffffffffc0202370 <commands+0x758>
ffffffffc02011d6:	f69fe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011da:	00001697          	auipc	a3,0x1
ffffffffc02011de:	30e68693          	addi	a3,a3,782 # ffffffffc02024e8 <commands+0x8d0>
ffffffffc02011e2:	00001617          	auipc	a2,0x1
ffffffffc02011e6:	17660613          	addi	a2,a2,374 # ffffffffc0202358 <commands+0x740>
ffffffffc02011ea:	12000593          	li	a1,288
ffffffffc02011ee:	00001517          	auipc	a0,0x1
ffffffffc02011f2:	18250513          	addi	a0,a0,386 # ffffffffc0202370 <commands+0x758>
ffffffffc02011f6:	f49fe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(!PageProperty(p0));
ffffffffc02011fa:	00001697          	auipc	a3,0x1
ffffffffc02011fe:	36e68693          	addi	a3,a3,878 # ffffffffc0202568 <commands+0x950>
ffffffffc0201202:	00001617          	auipc	a2,0x1
ffffffffc0201206:	15660613          	addi	a2,a2,342 # ffffffffc0202358 <commands+0x740>
ffffffffc020120a:	11700593          	li	a1,279
ffffffffc020120e:	00001517          	auipc	a0,0x1
ffffffffc0201212:	16250513          	addi	a0,a0,354 # ffffffffc0202370 <commands+0x758>
ffffffffc0201216:	f29fe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(p0 != NULL);
ffffffffc020121a:	00001697          	auipc	a3,0x1
ffffffffc020121e:	33e68693          	addi	a3,a3,830 # ffffffffc0202558 <commands+0x940>
ffffffffc0201222:	00001617          	auipc	a2,0x1
ffffffffc0201226:	13660613          	addi	a2,a2,310 # ffffffffc0202358 <commands+0x740>
ffffffffc020122a:	11600593          	li	a1,278
ffffffffc020122e:	00001517          	auipc	a0,0x1
ffffffffc0201232:	14250513          	addi	a0,a0,322 # ffffffffc0202370 <commands+0x758>
ffffffffc0201236:	f09fe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(nr_free == 0);
ffffffffc020123a:	00001697          	auipc	a3,0x1
ffffffffc020123e:	30e68693          	addi	a3,a3,782 # ffffffffc0202548 <commands+0x930>
ffffffffc0201242:	00001617          	auipc	a2,0x1
ffffffffc0201246:	11660613          	addi	a2,a2,278 # ffffffffc0202358 <commands+0x740>
ffffffffc020124a:	0f800593          	li	a1,248
ffffffffc020124e:	00001517          	auipc	a0,0x1
ffffffffc0201252:	12250513          	addi	a0,a0,290 # ffffffffc0202370 <commands+0x758>
ffffffffc0201256:	ee9fe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(alloc_page() == NULL);
ffffffffc020125a:	00001697          	auipc	a3,0x1
ffffffffc020125e:	28e68693          	addi	a3,a3,654 # ffffffffc02024e8 <commands+0x8d0>
ffffffffc0201262:	00001617          	auipc	a2,0x1
ffffffffc0201266:	0f660613          	addi	a2,a2,246 # ffffffffc0202358 <commands+0x740>
ffffffffc020126a:	0f600593          	li	a1,246
ffffffffc020126e:	00001517          	auipc	a0,0x1
ffffffffc0201272:	10250513          	addi	a0,a0,258 # ffffffffc0202370 <commands+0x758>
ffffffffc0201276:	ec9fe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc020127a:	00001697          	auipc	a3,0x1
ffffffffc020127e:	2ae68693          	addi	a3,a3,686 # ffffffffc0202528 <commands+0x910>
ffffffffc0201282:	00001617          	auipc	a2,0x1
ffffffffc0201286:	0d660613          	addi	a2,a2,214 # ffffffffc0202358 <commands+0x740>
ffffffffc020128a:	0f500593          	li	a1,245
ffffffffc020128e:	00001517          	auipc	a0,0x1
ffffffffc0201292:	0e250513          	addi	a0,a0,226 # ffffffffc0202370 <commands+0x758>
ffffffffc0201296:	ea9fe0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc020129a <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc020129a:	1141                	addi	sp,sp,-16
ffffffffc020129c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020129e:	18058063          	beqz	a1,ffffffffc020141e <best_fit_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc02012a2:	00259693          	slli	a3,a1,0x2
ffffffffc02012a6:	96ae                	add	a3,a3,a1
ffffffffc02012a8:	068e                	slli	a3,a3,0x3
ffffffffc02012aa:	96aa                	add	a3,a3,a0
ffffffffc02012ac:	02d50d63          	beq	a0,a3,ffffffffc02012e6 <best_fit_free_pages+0x4c>
ffffffffc02012b0:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02012b2:	8b85                	andi	a5,a5,1
ffffffffc02012b4:	14079563          	bnez	a5,ffffffffc02013fe <best_fit_free_pages+0x164>
ffffffffc02012b8:	651c                	ld	a5,8(a0)
ffffffffc02012ba:	8385                	srli	a5,a5,0x1
ffffffffc02012bc:	8b85                	andi	a5,a5,1
ffffffffc02012be:	14079063          	bnez	a5,ffffffffc02013fe <best_fit_free_pages+0x164>
ffffffffc02012c2:	87aa                	mv	a5,a0
ffffffffc02012c4:	a809                	j	ffffffffc02012d6 <best_fit_free_pages+0x3c>
ffffffffc02012c6:	6798                	ld	a4,8(a5)
ffffffffc02012c8:	8b05                	andi	a4,a4,1
ffffffffc02012ca:	12071a63          	bnez	a4,ffffffffc02013fe <best_fit_free_pages+0x164>
ffffffffc02012ce:	6798                	ld	a4,8(a5)
ffffffffc02012d0:	8b09                	andi	a4,a4,2
ffffffffc02012d2:	12071663          	bnez	a4,ffffffffc02013fe <best_fit_free_pages+0x164>
        p->flags = 0;
ffffffffc02012d6:	0007b423          	sd	zero,8(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02012da:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02012de:	02878793          	addi	a5,a5,40
ffffffffc02012e2:	fed792e3          	bne	a5,a3,ffffffffc02012c6 <best_fit_free_pages+0x2c>
     base->property = n;
ffffffffc02012e6:	2581                	sext.w	a1,a1
ffffffffc02012e8:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02012ea:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02012ee:	4789                	li	a5,2
ffffffffc02012f0:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02012f4:	00005697          	auipc	a3,0x5
ffffffffc02012f8:	16468693          	addi	a3,a3,356 # ffffffffc0206458 <free_area>
ffffffffc02012fc:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02012fe:	669c                	ld	a5,8(a3)
ffffffffc0201300:	9db9                	addw	a1,a1,a4
ffffffffc0201302:	00005717          	auipc	a4,0x5
ffffffffc0201306:	16b72323          	sw	a1,358(a4) # ffffffffc0206468 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc020130a:	08d78f63          	beq	a5,a3,ffffffffc02013a8 <best_fit_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc020130e:	fe878713          	addi	a4,a5,-24
ffffffffc0201312:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201314:	4801                	li	a6,0
ffffffffc0201316:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc020131a:	00e56a63          	bltu	a0,a4,ffffffffc020132e <best_fit_free_pages+0x94>
    return listelm->next;
ffffffffc020131e:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201320:	02d70563          	beq	a4,a3,ffffffffc020134a <best_fit_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201324:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201326:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020132a:	fee57ae3          	bleu	a4,a0,ffffffffc020131e <best_fit_free_pages+0x84>
ffffffffc020132e:	00080663          	beqz	a6,ffffffffc020133a <best_fit_free_pages+0xa0>
ffffffffc0201332:	00005817          	auipc	a6,0x5
ffffffffc0201336:	12b83323          	sd	a1,294(a6) # ffffffffc0206458 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020133a:	638c                	ld	a1,0(a5)
    prev->next = next->prev = elm;
ffffffffc020133c:	e390                	sd	a2,0(a5)
ffffffffc020133e:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc0201340:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201342:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc0201344:	02d59163          	bne	a1,a3,ffffffffc0201366 <best_fit_free_pages+0xcc>
ffffffffc0201348:	a091                	j	ffffffffc020138c <best_fit_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc020134a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020134c:	f114                	sd	a3,32(a0)
ffffffffc020134e:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201350:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201352:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201354:	00d70563          	beq	a4,a3,ffffffffc020135e <best_fit_free_pages+0xc4>
ffffffffc0201358:	4805                	li	a6,1
ffffffffc020135a:	87ba                	mv	a5,a4
ffffffffc020135c:	b7e9                	j	ffffffffc0201326 <best_fit_free_pages+0x8c>
ffffffffc020135e:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc0201360:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc0201362:	02d78163          	beq	a5,a3,ffffffffc0201384 <best_fit_free_pages+0xea>
         if (p + p->property == base) {
ffffffffc0201366:	ff85a803          	lw	a6,-8(a1)
        p = le2page(le, page_link);
ffffffffc020136a:	fe858613          	addi	a2,a1,-24
         if (p + p->property == base) {
ffffffffc020136e:	02081713          	slli	a4,a6,0x20
ffffffffc0201372:	9301                	srli	a4,a4,0x20
ffffffffc0201374:	00271793          	slli	a5,a4,0x2
ffffffffc0201378:	97ba                	add	a5,a5,a4
ffffffffc020137a:	078e                	slli	a5,a5,0x3
ffffffffc020137c:	97b2                	add	a5,a5,a2
ffffffffc020137e:	02f50e63          	beq	a0,a5,ffffffffc02013ba <best_fit_free_pages+0x120>
ffffffffc0201382:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201384:	fe878713          	addi	a4,a5,-24
ffffffffc0201388:	00d78d63          	beq	a5,a3,ffffffffc02013a2 <best_fit_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc020138c:	490c                	lw	a1,16(a0)
ffffffffc020138e:	02059613          	slli	a2,a1,0x20
ffffffffc0201392:	9201                	srli	a2,a2,0x20
ffffffffc0201394:	00261693          	slli	a3,a2,0x2
ffffffffc0201398:	96b2                	add	a3,a3,a2
ffffffffc020139a:	068e                	slli	a3,a3,0x3
ffffffffc020139c:	96aa                	add	a3,a3,a0
ffffffffc020139e:	04d70063          	beq	a4,a3,ffffffffc02013de <best_fit_free_pages+0x144>
}
ffffffffc02013a2:	60a2                	ld	ra,8(sp)
ffffffffc02013a4:	0141                	addi	sp,sp,16
ffffffffc02013a6:	8082                	ret
ffffffffc02013a8:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02013aa:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc02013ae:	e398                	sd	a4,0(a5)
ffffffffc02013b0:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02013b2:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02013b4:	ed1c                	sd	a5,24(a0)
}
ffffffffc02013b6:	0141                	addi	sp,sp,16
ffffffffc02013b8:	8082                	ret
            p->property += base->property;
ffffffffc02013ba:	491c                	lw	a5,16(a0)
ffffffffc02013bc:	0107883b          	addw	a6,a5,a6
ffffffffc02013c0:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02013c4:	57f5                	li	a5,-3
ffffffffc02013c6:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02013ca:	01853803          	ld	a6,24(a0)
ffffffffc02013ce:	7118                	ld	a4,32(a0)
            base = p;
ffffffffc02013d0:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc02013d2:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc02013d6:	659c                	ld	a5,8(a1)
ffffffffc02013d8:	01073023          	sd	a6,0(a4)
ffffffffc02013dc:	b765                	j	ffffffffc0201384 <best_fit_free_pages+0xea>
            base->property += p->property;
ffffffffc02013de:	ff87a703          	lw	a4,-8(a5)
ffffffffc02013e2:	ff078693          	addi	a3,a5,-16
ffffffffc02013e6:	9db9                	addw	a1,a1,a4
ffffffffc02013e8:	c90c                	sw	a1,16(a0)
ffffffffc02013ea:	5775                	li	a4,-3
ffffffffc02013ec:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02013f0:	6398                	ld	a4,0(a5)
ffffffffc02013f2:	679c                	ld	a5,8(a5)
}
ffffffffc02013f4:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02013f6:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02013f8:	e398                	sd	a4,0(a5)
ffffffffc02013fa:	0141                	addi	sp,sp,16
ffffffffc02013fc:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02013fe:	00001697          	auipc	a3,0x1
ffffffffc0201402:	25268693          	addi	a3,a3,594 # ffffffffc0202650 <commands+0xa38>
ffffffffc0201406:	00001617          	auipc	a2,0x1
ffffffffc020140a:	f5260613          	addi	a2,a2,-174 # ffffffffc0202358 <commands+0x740>
ffffffffc020140e:	09200593          	li	a1,146
ffffffffc0201412:	00001517          	auipc	a0,0x1
ffffffffc0201416:	f5e50513          	addi	a0,a0,-162 # ffffffffc0202370 <commands+0x758>
ffffffffc020141a:	d25fe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(n > 0);
ffffffffc020141e:	00001697          	auipc	a3,0x1
ffffffffc0201422:	f3268693          	addi	a3,a3,-206 # ffffffffc0202350 <commands+0x738>
ffffffffc0201426:	00001617          	auipc	a2,0x1
ffffffffc020142a:	f3260613          	addi	a2,a2,-206 # ffffffffc0202358 <commands+0x740>
ffffffffc020142e:	08f00593          	li	a1,143
ffffffffc0201432:	00001517          	auipc	a0,0x1
ffffffffc0201436:	f3e50513          	addi	a0,a0,-194 # ffffffffc0202370 <commands+0x758>
ffffffffc020143a:	d05fe0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc020143e <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc020143e:	1141                	addi	sp,sp,-16
ffffffffc0201440:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201442:	c1fd                	beqz	a1,ffffffffc0201528 <best_fit_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc0201444:	00259693          	slli	a3,a1,0x2
ffffffffc0201448:	96ae                	add	a3,a3,a1
ffffffffc020144a:	068e                	slli	a3,a3,0x3
ffffffffc020144c:	96aa                	add	a3,a3,a0
ffffffffc020144e:	02d50463          	beq	a0,a3,ffffffffc0201476 <best_fit_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201452:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc0201454:	87aa                	mv	a5,a0
ffffffffc0201456:	8b05                	andi	a4,a4,1
ffffffffc0201458:	e709                	bnez	a4,ffffffffc0201462 <best_fit_init_memmap+0x24>
ffffffffc020145a:	a07d                	j	ffffffffc0201508 <best_fit_init_memmap+0xca>
ffffffffc020145c:	6798                	ld	a4,8(a5)
ffffffffc020145e:	8b05                	andi	a4,a4,1
ffffffffc0201460:	c745                	beqz	a4,ffffffffc0201508 <best_fit_init_memmap+0xca>
        p->flags = p->property = 0;
ffffffffc0201462:	0007a823          	sw	zero,16(a5)
ffffffffc0201466:	0007b423          	sd	zero,8(a5)
ffffffffc020146a:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020146e:	02878793          	addi	a5,a5,40
ffffffffc0201472:	fed795e3          	bne	a5,a3,ffffffffc020145c <best_fit_init_memmap+0x1e>
    base->property = n;
ffffffffc0201476:	2581                	sext.w	a1,a1
ffffffffc0201478:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020147a:	4789                	li	a5,2
ffffffffc020147c:	00850713          	addi	a4,a0,8
ffffffffc0201480:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201484:	00005697          	auipc	a3,0x5
ffffffffc0201488:	fd468693          	addi	a3,a3,-44 # ffffffffc0206458 <free_area>
ffffffffc020148c:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020148e:	669c                	ld	a5,8(a3)
ffffffffc0201490:	9db9                	addw	a1,a1,a4
ffffffffc0201492:	00005717          	auipc	a4,0x5
ffffffffc0201496:	fcb72b23          	sw	a1,-42(a4) # ffffffffc0206468 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc020149a:	04d78a63          	beq	a5,a3,ffffffffc02014ee <best_fit_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc020149e:	fe878713          	addi	a4,a5,-24
ffffffffc02014a2:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02014a4:	4801                	li	a6,0
ffffffffc02014a6:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02014aa:	00e56a63          	bltu	a0,a4,ffffffffc02014be <best_fit_init_memmap+0x80>
    return listelm->next;
ffffffffc02014ae:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02014b0:	02d70563          	beq	a4,a3,ffffffffc02014da <best_fit_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02014b4:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02014b6:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02014ba:	fee57ae3          	bleu	a4,a0,ffffffffc02014ae <best_fit_init_memmap+0x70>
ffffffffc02014be:	00080663          	beqz	a6,ffffffffc02014ca <best_fit_init_memmap+0x8c>
ffffffffc02014c2:	00005717          	auipc	a4,0x5
ffffffffc02014c6:	f8b73b23          	sd	a1,-106(a4) # ffffffffc0206458 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02014ca:	6398                	ld	a4,0(a5)
}
ffffffffc02014cc:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02014ce:	e390                	sd	a2,0(a5)
ffffffffc02014d0:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02014d2:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02014d4:	ed18                	sd	a4,24(a0)
ffffffffc02014d6:	0141                	addi	sp,sp,16
ffffffffc02014d8:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02014da:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02014dc:	f114                	sd	a3,32(a0)
ffffffffc02014de:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02014e0:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc02014e2:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02014e4:	00d70e63          	beq	a4,a3,ffffffffc0201500 <best_fit_init_memmap+0xc2>
ffffffffc02014e8:	4805                	li	a6,1
ffffffffc02014ea:	87ba                	mv	a5,a4
ffffffffc02014ec:	b7e9                	j	ffffffffc02014b6 <best_fit_init_memmap+0x78>
}
ffffffffc02014ee:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02014f0:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc02014f4:	e398                	sd	a4,0(a5)
ffffffffc02014f6:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02014f8:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02014fa:	ed1c                	sd	a5,24(a0)
}
ffffffffc02014fc:	0141                	addi	sp,sp,16
ffffffffc02014fe:	8082                	ret
ffffffffc0201500:	60a2                	ld	ra,8(sp)
ffffffffc0201502:	e290                	sd	a2,0(a3)
ffffffffc0201504:	0141                	addi	sp,sp,16
ffffffffc0201506:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201508:	00001697          	auipc	a3,0x1
ffffffffc020150c:	17068693          	addi	a3,a3,368 # ffffffffc0202678 <commands+0xa60>
ffffffffc0201510:	00001617          	auipc	a2,0x1
ffffffffc0201514:	e4860613          	addi	a2,a2,-440 # ffffffffc0202358 <commands+0x740>
ffffffffc0201518:	04a00593          	li	a1,74
ffffffffc020151c:	00001517          	auipc	a0,0x1
ffffffffc0201520:	e5450513          	addi	a0,a0,-428 # ffffffffc0202370 <commands+0x758>
ffffffffc0201524:	c1bfe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(n > 0);
ffffffffc0201528:	00001697          	auipc	a3,0x1
ffffffffc020152c:	e2868693          	addi	a3,a3,-472 # ffffffffc0202350 <commands+0x738>
ffffffffc0201530:	00001617          	auipc	a2,0x1
ffffffffc0201534:	e2860613          	addi	a2,a2,-472 # ffffffffc0202358 <commands+0x740>
ffffffffc0201538:	04700593          	li	a1,71
ffffffffc020153c:	00001517          	auipc	a0,0x1
ffffffffc0201540:	e3450513          	addi	a0,a0,-460 # ffffffffc0202370 <commands+0x758>
ffffffffc0201544:	bfbfe0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc0201548 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201548:	c185                	beqz	a1,ffffffffc0201568 <strnlen+0x20>
ffffffffc020154a:	00054783          	lbu	a5,0(a0)
ffffffffc020154e:	cf89                	beqz	a5,ffffffffc0201568 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0201550:	4781                	li	a5,0
ffffffffc0201552:	a021                	j	ffffffffc020155a <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201554:	00074703          	lbu	a4,0(a4)
ffffffffc0201558:	c711                	beqz	a4,ffffffffc0201564 <strnlen+0x1c>
        cnt ++;
ffffffffc020155a:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020155c:	00f50733          	add	a4,a0,a5
ffffffffc0201560:	fef59ae3          	bne	a1,a5,ffffffffc0201554 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0201564:	853e                	mv	a0,a5
ffffffffc0201566:	8082                	ret
    size_t cnt = 0;
ffffffffc0201568:	4781                	li	a5,0
}
ffffffffc020156a:	853e                	mv	a0,a5
ffffffffc020156c:	8082                	ret

ffffffffc020156e <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020156e:	00054783          	lbu	a5,0(a0)
ffffffffc0201572:	0005c703          	lbu	a4,0(a1)
ffffffffc0201576:	cb91                	beqz	a5,ffffffffc020158a <strcmp+0x1c>
ffffffffc0201578:	00e79c63          	bne	a5,a4,ffffffffc0201590 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc020157c:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020157e:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0201582:	0585                	addi	a1,a1,1
ffffffffc0201584:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201588:	fbe5                	bnez	a5,ffffffffc0201578 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020158a:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020158c:	9d19                	subw	a0,a0,a4
ffffffffc020158e:	8082                	ret
ffffffffc0201590:	0007851b          	sext.w	a0,a5
ffffffffc0201594:	9d19                	subw	a0,a0,a4
ffffffffc0201596:	8082                	ret

ffffffffc0201598 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201598:	00054783          	lbu	a5,0(a0)
ffffffffc020159c:	cb91                	beqz	a5,ffffffffc02015b0 <strchr+0x18>
        if (*s == c) {
ffffffffc020159e:	00b79563          	bne	a5,a1,ffffffffc02015a8 <strchr+0x10>
ffffffffc02015a2:	a809                	j	ffffffffc02015b4 <strchr+0x1c>
ffffffffc02015a4:	00b78763          	beq	a5,a1,ffffffffc02015b2 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc02015a8:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02015aa:	00054783          	lbu	a5,0(a0)
ffffffffc02015ae:	fbfd                	bnez	a5,ffffffffc02015a4 <strchr+0xc>
    }
    return NULL;
ffffffffc02015b0:	4501                	li	a0,0
}
ffffffffc02015b2:	8082                	ret
ffffffffc02015b4:	8082                	ret

ffffffffc02015b6 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02015b6:	ca01                	beqz	a2,ffffffffc02015c6 <memset+0x10>
ffffffffc02015b8:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02015ba:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02015bc:	0785                	addi	a5,a5,1
ffffffffc02015be:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02015c2:	fec79de3          	bne	a5,a2,ffffffffc02015bc <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02015c6:	8082                	ret

ffffffffc02015c8 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02015c8:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02015cc:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02015ce:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02015d2:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02015d4:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02015d8:	f022                	sd	s0,32(sp)
ffffffffc02015da:	ec26                	sd	s1,24(sp)
ffffffffc02015dc:	e84a                	sd	s2,16(sp)
ffffffffc02015de:	f406                	sd	ra,40(sp)
ffffffffc02015e0:	e44e                	sd	s3,8(sp)
ffffffffc02015e2:	84aa                	mv	s1,a0
ffffffffc02015e4:	892e                	mv	s2,a1
ffffffffc02015e6:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02015ea:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc02015ec:	03067e63          	bleu	a6,a2,ffffffffc0201628 <printnum+0x60>
ffffffffc02015f0:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02015f2:	00805763          	blez	s0,ffffffffc0201600 <printnum+0x38>
ffffffffc02015f6:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02015f8:	85ca                	mv	a1,s2
ffffffffc02015fa:	854e                	mv	a0,s3
ffffffffc02015fc:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02015fe:	fc65                	bnez	s0,ffffffffc02015f6 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201600:	1a02                	slli	s4,s4,0x20
ffffffffc0201602:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201606:	00001797          	auipc	a5,0x1
ffffffffc020160a:	26278793          	addi	a5,a5,610 # ffffffffc0202868 <error_string+0x38>
ffffffffc020160e:	9a3e                	add	s4,s4,a5
}
ffffffffc0201610:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201612:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201616:	70a2                	ld	ra,40(sp)
ffffffffc0201618:	69a2                	ld	s3,8(sp)
ffffffffc020161a:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020161c:	85ca                	mv	a1,s2
ffffffffc020161e:	8326                	mv	t1,s1
}
ffffffffc0201620:	6942                	ld	s2,16(sp)
ffffffffc0201622:	64e2                	ld	s1,24(sp)
ffffffffc0201624:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201626:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201628:	03065633          	divu	a2,a2,a6
ffffffffc020162c:	8722                	mv	a4,s0
ffffffffc020162e:	f9bff0ef          	jal	ra,ffffffffc02015c8 <printnum>
ffffffffc0201632:	b7f9                	j	ffffffffc0201600 <printnum+0x38>

ffffffffc0201634 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201634:	7119                	addi	sp,sp,-128
ffffffffc0201636:	f4a6                	sd	s1,104(sp)
ffffffffc0201638:	f0ca                	sd	s2,96(sp)
ffffffffc020163a:	e8d2                	sd	s4,80(sp)
ffffffffc020163c:	e4d6                	sd	s5,72(sp)
ffffffffc020163e:	e0da                	sd	s6,64(sp)
ffffffffc0201640:	fc5e                	sd	s7,56(sp)
ffffffffc0201642:	f862                	sd	s8,48(sp)
ffffffffc0201644:	f06a                	sd	s10,32(sp)
ffffffffc0201646:	fc86                	sd	ra,120(sp)
ffffffffc0201648:	f8a2                	sd	s0,112(sp)
ffffffffc020164a:	ecce                	sd	s3,88(sp)
ffffffffc020164c:	f466                	sd	s9,40(sp)
ffffffffc020164e:	ec6e                	sd	s11,24(sp)
ffffffffc0201650:	892a                	mv	s2,a0
ffffffffc0201652:	84ae                	mv	s1,a1
ffffffffc0201654:	8d32                	mv	s10,a2
ffffffffc0201656:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0201658:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020165a:	00001a17          	auipc	s4,0x1
ffffffffc020165e:	07ea0a13          	addi	s4,s4,126 # ffffffffc02026d8 <best_fit_pmm_manager+0x50>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201662:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201666:	00001c17          	auipc	s8,0x1
ffffffffc020166a:	1cac0c13          	addi	s8,s8,458 # ffffffffc0202830 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020166e:	000d4503          	lbu	a0,0(s10)
ffffffffc0201672:	02500793          	li	a5,37
ffffffffc0201676:	001d0413          	addi	s0,s10,1
ffffffffc020167a:	00f50e63          	beq	a0,a5,ffffffffc0201696 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc020167e:	c521                	beqz	a0,ffffffffc02016c6 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201680:	02500993          	li	s3,37
ffffffffc0201684:	a011                	j	ffffffffc0201688 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0201686:	c121                	beqz	a0,ffffffffc02016c6 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0201688:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020168a:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020168c:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020168e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201692:	ff351ae3          	bne	a0,s3,ffffffffc0201686 <vprintfmt+0x52>
ffffffffc0201696:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020169a:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020169e:	4981                	li	s3,0
ffffffffc02016a0:	4801                	li	a6,0
        width = precision = -1;
ffffffffc02016a2:	5cfd                	li	s9,-1
ffffffffc02016a4:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016a6:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc02016aa:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016ac:	fdd6069b          	addiw	a3,a2,-35
ffffffffc02016b0:	0ff6f693          	andi	a3,a3,255
ffffffffc02016b4:	00140d13          	addi	s10,s0,1
ffffffffc02016b8:	20d5e563          	bltu	a1,a3,ffffffffc02018c2 <vprintfmt+0x28e>
ffffffffc02016bc:	068a                	slli	a3,a3,0x2
ffffffffc02016be:	96d2                	add	a3,a3,s4
ffffffffc02016c0:	4294                	lw	a3,0(a3)
ffffffffc02016c2:	96d2                	add	a3,a3,s4
ffffffffc02016c4:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02016c6:	70e6                	ld	ra,120(sp)
ffffffffc02016c8:	7446                	ld	s0,112(sp)
ffffffffc02016ca:	74a6                	ld	s1,104(sp)
ffffffffc02016cc:	7906                	ld	s2,96(sp)
ffffffffc02016ce:	69e6                	ld	s3,88(sp)
ffffffffc02016d0:	6a46                	ld	s4,80(sp)
ffffffffc02016d2:	6aa6                	ld	s5,72(sp)
ffffffffc02016d4:	6b06                	ld	s6,64(sp)
ffffffffc02016d6:	7be2                	ld	s7,56(sp)
ffffffffc02016d8:	7c42                	ld	s8,48(sp)
ffffffffc02016da:	7ca2                	ld	s9,40(sp)
ffffffffc02016dc:	7d02                	ld	s10,32(sp)
ffffffffc02016de:	6de2                	ld	s11,24(sp)
ffffffffc02016e0:	6109                	addi	sp,sp,128
ffffffffc02016e2:	8082                	ret
    if (lflag >= 2) {
ffffffffc02016e4:	4705                	li	a4,1
ffffffffc02016e6:	008a8593          	addi	a1,s5,8
ffffffffc02016ea:	01074463          	blt	a4,a6,ffffffffc02016f2 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc02016ee:	26080363          	beqz	a6,ffffffffc0201954 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc02016f2:	000ab603          	ld	a2,0(s5)
ffffffffc02016f6:	46c1                	li	a3,16
ffffffffc02016f8:	8aae                	mv	s5,a1
ffffffffc02016fa:	a06d                	j	ffffffffc02017a4 <vprintfmt+0x170>
            goto reswitch;
ffffffffc02016fc:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201700:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201702:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201704:	b765                	j	ffffffffc02016ac <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0201706:	000aa503          	lw	a0,0(s5)
ffffffffc020170a:	85a6                	mv	a1,s1
ffffffffc020170c:	0aa1                	addi	s5,s5,8
ffffffffc020170e:	9902                	jalr	s2
            break;
ffffffffc0201710:	bfb9                	j	ffffffffc020166e <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201712:	4705                	li	a4,1
ffffffffc0201714:	008a8993          	addi	s3,s5,8
ffffffffc0201718:	01074463          	blt	a4,a6,ffffffffc0201720 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc020171c:	22080463          	beqz	a6,ffffffffc0201944 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0201720:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0201724:	24044463          	bltz	s0,ffffffffc020196c <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0201728:	8622                	mv	a2,s0
ffffffffc020172a:	8ace                	mv	s5,s3
ffffffffc020172c:	46a9                	li	a3,10
ffffffffc020172e:	a89d                	j	ffffffffc02017a4 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0201730:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201734:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201736:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0201738:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc020173c:	8fb5                	xor	a5,a5,a3
ffffffffc020173e:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201742:	1ad74363          	blt	a4,a3,ffffffffc02018e8 <vprintfmt+0x2b4>
ffffffffc0201746:	00369793          	slli	a5,a3,0x3
ffffffffc020174a:	97e2                	add	a5,a5,s8
ffffffffc020174c:	639c                	ld	a5,0(a5)
ffffffffc020174e:	18078d63          	beqz	a5,ffffffffc02018e8 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201752:	86be                	mv	a3,a5
ffffffffc0201754:	00001617          	auipc	a2,0x1
ffffffffc0201758:	1c460613          	addi	a2,a2,452 # ffffffffc0202918 <error_string+0xe8>
ffffffffc020175c:	85a6                	mv	a1,s1
ffffffffc020175e:	854a                	mv	a0,s2
ffffffffc0201760:	240000ef          	jal	ra,ffffffffc02019a0 <printfmt>
ffffffffc0201764:	b729                	j	ffffffffc020166e <vprintfmt+0x3a>
            lflag ++;
ffffffffc0201766:	00144603          	lbu	a2,1(s0)
ffffffffc020176a:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020176c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020176e:	bf3d                	j	ffffffffc02016ac <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0201770:	4705                	li	a4,1
ffffffffc0201772:	008a8593          	addi	a1,s5,8
ffffffffc0201776:	01074463          	blt	a4,a6,ffffffffc020177e <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc020177a:	1e080263          	beqz	a6,ffffffffc020195e <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc020177e:	000ab603          	ld	a2,0(s5)
ffffffffc0201782:	46a1                	li	a3,8
ffffffffc0201784:	8aae                	mv	s5,a1
ffffffffc0201786:	a839                	j	ffffffffc02017a4 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0201788:	03000513          	li	a0,48
ffffffffc020178c:	85a6                	mv	a1,s1
ffffffffc020178e:	e03e                	sd	a5,0(sp)
ffffffffc0201790:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201792:	85a6                	mv	a1,s1
ffffffffc0201794:	07800513          	li	a0,120
ffffffffc0201798:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020179a:	0aa1                	addi	s5,s5,8
ffffffffc020179c:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc02017a0:	6782                	ld	a5,0(sp)
ffffffffc02017a2:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02017a4:	876e                	mv	a4,s11
ffffffffc02017a6:	85a6                	mv	a1,s1
ffffffffc02017a8:	854a                	mv	a0,s2
ffffffffc02017aa:	e1fff0ef          	jal	ra,ffffffffc02015c8 <printnum>
            break;
ffffffffc02017ae:	b5c1                	j	ffffffffc020166e <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02017b0:	000ab603          	ld	a2,0(s5)
ffffffffc02017b4:	0aa1                	addi	s5,s5,8
ffffffffc02017b6:	1c060663          	beqz	a2,ffffffffc0201982 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc02017ba:	00160413          	addi	s0,a2,1
ffffffffc02017be:	17b05c63          	blez	s11,ffffffffc0201936 <vprintfmt+0x302>
ffffffffc02017c2:	02d00593          	li	a1,45
ffffffffc02017c6:	14b79263          	bne	a5,a1,ffffffffc020190a <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02017ca:	00064783          	lbu	a5,0(a2)
ffffffffc02017ce:	0007851b          	sext.w	a0,a5
ffffffffc02017d2:	c905                	beqz	a0,ffffffffc0201802 <vprintfmt+0x1ce>
ffffffffc02017d4:	000cc563          	bltz	s9,ffffffffc02017de <vprintfmt+0x1aa>
ffffffffc02017d8:	3cfd                	addiw	s9,s9,-1
ffffffffc02017da:	036c8263          	beq	s9,s6,ffffffffc02017fe <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc02017de:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02017e0:	18098463          	beqz	s3,ffffffffc0201968 <vprintfmt+0x334>
ffffffffc02017e4:	3781                	addiw	a5,a5,-32
ffffffffc02017e6:	18fbf163          	bleu	a5,s7,ffffffffc0201968 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc02017ea:	03f00513          	li	a0,63
ffffffffc02017ee:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02017f0:	0405                	addi	s0,s0,1
ffffffffc02017f2:	fff44783          	lbu	a5,-1(s0)
ffffffffc02017f6:	3dfd                	addiw	s11,s11,-1
ffffffffc02017f8:	0007851b          	sext.w	a0,a5
ffffffffc02017fc:	fd61                	bnez	a0,ffffffffc02017d4 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc02017fe:	e7b058e3          	blez	s11,ffffffffc020166e <vprintfmt+0x3a>
ffffffffc0201802:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201804:	85a6                	mv	a1,s1
ffffffffc0201806:	02000513          	li	a0,32
ffffffffc020180a:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020180c:	e60d81e3          	beqz	s11,ffffffffc020166e <vprintfmt+0x3a>
ffffffffc0201810:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201812:	85a6                	mv	a1,s1
ffffffffc0201814:	02000513          	li	a0,32
ffffffffc0201818:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020181a:	fe0d94e3          	bnez	s11,ffffffffc0201802 <vprintfmt+0x1ce>
ffffffffc020181e:	bd81                	j	ffffffffc020166e <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201820:	4705                	li	a4,1
ffffffffc0201822:	008a8593          	addi	a1,s5,8
ffffffffc0201826:	01074463          	blt	a4,a6,ffffffffc020182e <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc020182a:	12080063          	beqz	a6,ffffffffc020194a <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc020182e:	000ab603          	ld	a2,0(s5)
ffffffffc0201832:	46a9                	li	a3,10
ffffffffc0201834:	8aae                	mv	s5,a1
ffffffffc0201836:	b7bd                	j	ffffffffc02017a4 <vprintfmt+0x170>
ffffffffc0201838:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc020183c:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201840:	846a                	mv	s0,s10
ffffffffc0201842:	b5ad                	j	ffffffffc02016ac <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0201844:	85a6                	mv	a1,s1
ffffffffc0201846:	02500513          	li	a0,37
ffffffffc020184a:	9902                	jalr	s2
            break;
ffffffffc020184c:	b50d                	j	ffffffffc020166e <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc020184e:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0201852:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201856:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201858:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc020185a:	e40dd9e3          	bgez	s11,ffffffffc02016ac <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc020185e:	8de6                	mv	s11,s9
ffffffffc0201860:	5cfd                	li	s9,-1
ffffffffc0201862:	b5a9                	j	ffffffffc02016ac <vprintfmt+0x78>
            goto reswitch;
ffffffffc0201864:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0201868:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020186c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020186e:	bd3d                	j	ffffffffc02016ac <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0201870:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0201874:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201878:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020187a:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020187e:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201882:	fcd56ce3          	bltu	a0,a3,ffffffffc020185a <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0201886:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201888:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc020188c:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201890:	0196873b          	addw	a4,a3,s9
ffffffffc0201894:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201898:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc020189c:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc02018a0:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc02018a4:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02018a8:	fcd57fe3          	bleu	a3,a0,ffffffffc0201886 <vprintfmt+0x252>
ffffffffc02018ac:	b77d                	j	ffffffffc020185a <vprintfmt+0x226>
            if (width < 0)
ffffffffc02018ae:	fffdc693          	not	a3,s11
ffffffffc02018b2:	96fd                	srai	a3,a3,0x3f
ffffffffc02018b4:	00ddfdb3          	and	s11,s11,a3
ffffffffc02018b8:	00144603          	lbu	a2,1(s0)
ffffffffc02018bc:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02018be:	846a                	mv	s0,s10
ffffffffc02018c0:	b3f5                	j	ffffffffc02016ac <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc02018c2:	85a6                	mv	a1,s1
ffffffffc02018c4:	02500513          	li	a0,37
ffffffffc02018c8:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02018ca:	fff44703          	lbu	a4,-1(s0)
ffffffffc02018ce:	02500793          	li	a5,37
ffffffffc02018d2:	8d22                	mv	s10,s0
ffffffffc02018d4:	d8f70de3          	beq	a4,a5,ffffffffc020166e <vprintfmt+0x3a>
ffffffffc02018d8:	02500713          	li	a4,37
ffffffffc02018dc:	1d7d                	addi	s10,s10,-1
ffffffffc02018de:	fffd4783          	lbu	a5,-1(s10)
ffffffffc02018e2:	fee79de3          	bne	a5,a4,ffffffffc02018dc <vprintfmt+0x2a8>
ffffffffc02018e6:	b361                	j	ffffffffc020166e <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02018e8:	00001617          	auipc	a2,0x1
ffffffffc02018ec:	02060613          	addi	a2,a2,32 # ffffffffc0202908 <error_string+0xd8>
ffffffffc02018f0:	85a6                	mv	a1,s1
ffffffffc02018f2:	854a                	mv	a0,s2
ffffffffc02018f4:	0ac000ef          	jal	ra,ffffffffc02019a0 <printfmt>
ffffffffc02018f8:	bb9d                	j	ffffffffc020166e <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02018fa:	00001617          	auipc	a2,0x1
ffffffffc02018fe:	00660613          	addi	a2,a2,6 # ffffffffc0202900 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0201902:	00001417          	auipc	s0,0x1
ffffffffc0201906:	fff40413          	addi	s0,s0,-1 # ffffffffc0202901 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020190a:	8532                	mv	a0,a2
ffffffffc020190c:	85e6                	mv	a1,s9
ffffffffc020190e:	e032                	sd	a2,0(sp)
ffffffffc0201910:	e43e                	sd	a5,8(sp)
ffffffffc0201912:	c37ff0ef          	jal	ra,ffffffffc0201548 <strnlen>
ffffffffc0201916:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020191a:	6602                	ld	a2,0(sp)
ffffffffc020191c:	01b05d63          	blez	s11,ffffffffc0201936 <vprintfmt+0x302>
ffffffffc0201920:	67a2                	ld	a5,8(sp)
ffffffffc0201922:	2781                	sext.w	a5,a5
ffffffffc0201924:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0201926:	6522                	ld	a0,8(sp)
ffffffffc0201928:	85a6                	mv	a1,s1
ffffffffc020192a:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020192c:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020192e:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201930:	6602                	ld	a2,0(sp)
ffffffffc0201932:	fe0d9ae3          	bnez	s11,ffffffffc0201926 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201936:	00064783          	lbu	a5,0(a2)
ffffffffc020193a:	0007851b          	sext.w	a0,a5
ffffffffc020193e:	e8051be3          	bnez	a0,ffffffffc02017d4 <vprintfmt+0x1a0>
ffffffffc0201942:	b335                	j	ffffffffc020166e <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0201944:	000aa403          	lw	s0,0(s5)
ffffffffc0201948:	bbf1                	j	ffffffffc0201724 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc020194a:	000ae603          	lwu	a2,0(s5)
ffffffffc020194e:	46a9                	li	a3,10
ffffffffc0201950:	8aae                	mv	s5,a1
ffffffffc0201952:	bd89                	j	ffffffffc02017a4 <vprintfmt+0x170>
ffffffffc0201954:	000ae603          	lwu	a2,0(s5)
ffffffffc0201958:	46c1                	li	a3,16
ffffffffc020195a:	8aae                	mv	s5,a1
ffffffffc020195c:	b5a1                	j	ffffffffc02017a4 <vprintfmt+0x170>
ffffffffc020195e:	000ae603          	lwu	a2,0(s5)
ffffffffc0201962:	46a1                	li	a3,8
ffffffffc0201964:	8aae                	mv	s5,a1
ffffffffc0201966:	bd3d                	j	ffffffffc02017a4 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0201968:	9902                	jalr	s2
ffffffffc020196a:	b559                	j	ffffffffc02017f0 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc020196c:	85a6                	mv	a1,s1
ffffffffc020196e:	02d00513          	li	a0,45
ffffffffc0201972:	e03e                	sd	a5,0(sp)
ffffffffc0201974:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201976:	8ace                	mv	s5,s3
ffffffffc0201978:	40800633          	neg	a2,s0
ffffffffc020197c:	46a9                	li	a3,10
ffffffffc020197e:	6782                	ld	a5,0(sp)
ffffffffc0201980:	b515                	j	ffffffffc02017a4 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0201982:	01b05663          	blez	s11,ffffffffc020198e <vprintfmt+0x35a>
ffffffffc0201986:	02d00693          	li	a3,45
ffffffffc020198a:	f6d798e3          	bne	a5,a3,ffffffffc02018fa <vprintfmt+0x2c6>
ffffffffc020198e:	00001417          	auipc	s0,0x1
ffffffffc0201992:	f7340413          	addi	s0,s0,-141 # ffffffffc0202901 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201996:	02800513          	li	a0,40
ffffffffc020199a:	02800793          	li	a5,40
ffffffffc020199e:	bd1d                	j	ffffffffc02017d4 <vprintfmt+0x1a0>

ffffffffc02019a0 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02019a0:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02019a2:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02019a6:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02019a8:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02019aa:	ec06                	sd	ra,24(sp)
ffffffffc02019ac:	f83a                	sd	a4,48(sp)
ffffffffc02019ae:	fc3e                	sd	a5,56(sp)
ffffffffc02019b0:	e0c2                	sd	a6,64(sp)
ffffffffc02019b2:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02019b4:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02019b6:	c7fff0ef          	jal	ra,ffffffffc0201634 <vprintfmt>
}
ffffffffc02019ba:	60e2                	ld	ra,24(sp)
ffffffffc02019bc:	6161                	addi	sp,sp,80
ffffffffc02019be:	8082                	ret

ffffffffc02019c0 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02019c0:	715d                	addi	sp,sp,-80
ffffffffc02019c2:	e486                	sd	ra,72(sp)
ffffffffc02019c4:	e0a2                	sd	s0,64(sp)
ffffffffc02019c6:	fc26                	sd	s1,56(sp)
ffffffffc02019c8:	f84a                	sd	s2,48(sp)
ffffffffc02019ca:	f44e                	sd	s3,40(sp)
ffffffffc02019cc:	f052                	sd	s4,32(sp)
ffffffffc02019ce:	ec56                	sd	s5,24(sp)
ffffffffc02019d0:	e85a                	sd	s6,16(sp)
ffffffffc02019d2:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc02019d4:	c901                	beqz	a0,ffffffffc02019e4 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc02019d6:	85aa                	mv	a1,a0
ffffffffc02019d8:	00001517          	auipc	a0,0x1
ffffffffc02019dc:	f4050513          	addi	a0,a0,-192 # ffffffffc0202918 <error_string+0xe8>
ffffffffc02019e0:	ed6fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc02019e4:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02019e6:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02019e8:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02019ea:	4aa9                	li	s5,10
ffffffffc02019ec:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02019ee:	00004b97          	auipc	s7,0x4
ffffffffc02019f2:	622b8b93          	addi	s7,s7,1570 # ffffffffc0206010 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02019f6:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02019fa:	f34fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc02019fe:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201a00:	00054b63          	bltz	a0,ffffffffc0201a16 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201a04:	00a95b63          	ble	a0,s2,ffffffffc0201a1a <readline+0x5a>
ffffffffc0201a08:	029a5463          	ble	s1,s4,ffffffffc0201a30 <readline+0x70>
        c = getchar();
ffffffffc0201a0c:	f22fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201a10:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201a12:	fe0559e3          	bgez	a0,ffffffffc0201a04 <readline+0x44>
            return NULL;
ffffffffc0201a16:	4501                	li	a0,0
ffffffffc0201a18:	a099                	j	ffffffffc0201a5e <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0201a1a:	03341463          	bne	s0,s3,ffffffffc0201a42 <readline+0x82>
ffffffffc0201a1e:	e8b9                	bnez	s1,ffffffffc0201a74 <readline+0xb4>
        c = getchar();
ffffffffc0201a20:	f0efe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201a24:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201a26:	fe0548e3          	bltz	a0,ffffffffc0201a16 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201a2a:	fea958e3          	ble	a0,s2,ffffffffc0201a1a <readline+0x5a>
ffffffffc0201a2e:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201a30:	8522                	mv	a0,s0
ffffffffc0201a32:	eb8fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc0201a36:	009b87b3          	add	a5,s7,s1
ffffffffc0201a3a:	00878023          	sb	s0,0(a5)
ffffffffc0201a3e:	2485                	addiw	s1,s1,1
ffffffffc0201a40:	bf6d                	j	ffffffffc02019fa <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0201a42:	01540463          	beq	s0,s5,ffffffffc0201a4a <readline+0x8a>
ffffffffc0201a46:	fb641ae3          	bne	s0,s6,ffffffffc02019fa <readline+0x3a>
            cputchar(c);
ffffffffc0201a4a:	8522                	mv	a0,s0
ffffffffc0201a4c:	e9efe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc0201a50:	00004517          	auipc	a0,0x4
ffffffffc0201a54:	5c050513          	addi	a0,a0,1472 # ffffffffc0206010 <edata>
ffffffffc0201a58:	94aa                	add	s1,s1,a0
ffffffffc0201a5a:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201a5e:	60a6                	ld	ra,72(sp)
ffffffffc0201a60:	6406                	ld	s0,64(sp)
ffffffffc0201a62:	74e2                	ld	s1,56(sp)
ffffffffc0201a64:	7942                	ld	s2,48(sp)
ffffffffc0201a66:	79a2                	ld	s3,40(sp)
ffffffffc0201a68:	7a02                	ld	s4,32(sp)
ffffffffc0201a6a:	6ae2                	ld	s5,24(sp)
ffffffffc0201a6c:	6b42                	ld	s6,16(sp)
ffffffffc0201a6e:	6ba2                	ld	s7,8(sp)
ffffffffc0201a70:	6161                	addi	sp,sp,80
ffffffffc0201a72:	8082                	ret
            cputchar(c);
ffffffffc0201a74:	4521                	li	a0,8
ffffffffc0201a76:	e74fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc0201a7a:	34fd                	addiw	s1,s1,-1
ffffffffc0201a7c:	bfbd                	j	ffffffffc02019fa <readline+0x3a>

ffffffffc0201a7e <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc0201a7e:	00004797          	auipc	a5,0x4
ffffffffc0201a82:	58a78793          	addi	a5,a5,1418 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc0201a86:	6398                	ld	a4,0(a5)
ffffffffc0201a88:	4781                	li	a5,0
ffffffffc0201a8a:	88ba                	mv	a7,a4
ffffffffc0201a8c:	852a                	mv	a0,a0
ffffffffc0201a8e:	85be                	mv	a1,a5
ffffffffc0201a90:	863e                	mv	a2,a5
ffffffffc0201a92:	00000073          	ecall
ffffffffc0201a96:	87aa                	mv	a5,a0
}
ffffffffc0201a98:	8082                	ret

ffffffffc0201a9a <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc0201a9a:	00005797          	auipc	a5,0x5
ffffffffc0201a9e:	98e78793          	addi	a5,a5,-1650 # ffffffffc0206428 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc0201aa2:	6398                	ld	a4,0(a5)
ffffffffc0201aa4:	4781                	li	a5,0
ffffffffc0201aa6:	88ba                	mv	a7,a4
ffffffffc0201aa8:	852a                	mv	a0,a0
ffffffffc0201aaa:	85be                	mv	a1,a5
ffffffffc0201aac:	863e                	mv	a2,a5
ffffffffc0201aae:	00000073          	ecall
ffffffffc0201ab2:	87aa                	mv	a5,a0
}
ffffffffc0201ab4:	8082                	ret

ffffffffc0201ab6 <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201ab6:	00004797          	auipc	a5,0x4
ffffffffc0201aba:	54a78793          	addi	a5,a5,1354 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc0201abe:	639c                	ld	a5,0(a5)
ffffffffc0201ac0:	4501                	li	a0,0
ffffffffc0201ac2:	88be                	mv	a7,a5
ffffffffc0201ac4:	852a                	mv	a0,a0
ffffffffc0201ac6:	85aa                	mv	a1,a0
ffffffffc0201ac8:	862a                	mv	a2,a0
ffffffffc0201aca:	00000073          	ecall
ffffffffc0201ace:	852a                	mv	a0,a0
ffffffffc0201ad0:	2501                	sext.w	a0,a0
ffffffffc0201ad2:	8082                	ret
