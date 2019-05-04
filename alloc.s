/*
ENTRY STRUCTURE
	TYPE    DESCRIPTION     OFFSET
	entry*  next            0
	u64     flags           8
	u32     size            16
	u32     capacity        20
	u8[]    data            24

FLAGS
	BIT     DESCRIPTION
	0       used
*/

.data
	.align 16
	.type initial, STT_OBJECT
	.type first, STT_OBJECT

initial: .long 0
first: .long 0

.text
	.align 16
	.global init, kill, alloc, dealloc, defragment
	.type init, STT_FUNC
	.type kill, STT_FUNC
	.type alloc, STT_FUNC
	.type dealloc, STT_FUNC
	.type defragment, STT_FUNC

	.macro brk
		mov     $12, %rax
		syscall
	.endm

init:
	brk
	mov     %rax, initial(%rip)
	ret

kill:
	mov     initial(%rip), %rdi
	brk
	andq    $0, initial(%rip)
	ret

alloc:
	push    %rbx
	push    %r12

	/* ensure size > 0 */
	test	%rdi, %rdi
	jz		.Lalloc_fail

	mov     first(%rip), %rbx /* first */

	.Lalloc_find_entry:
	/* no entries left */
	test    %rbx, %rbx
	je      .Lalloc_no_entry

	/* ensure availability */
	and     $1, 8(%rbx)
	jnz     .Lalloc_next_entry

	/* ensure capacity */
	cmp     20(%rbx), %rdi
	ja      .Lalloc_next_entry

	/* update entry */
	orq     $1, 8(%rbx) /* mark used */
	mov     %rdi, 16(%rbx) /* update size */

	/* return address */
	lea     24(%rbx), %rax
	jmp     .Lalloc_end

	.Lalloc_next_entry:
	mov     0(%rbx), %rbx
	jmp     .Lalloc_find_entry

	/* create a new entry */
	.Lalloc_no_entry:
	mov     %rdi, %rbx /* rbx = size */

	/* blk(0) */
	xor     %rdi, %rdi
	brk

	/* blk(blk(0) + 24 + size) */
	mov     %rax, %r12 /* r12 = blk(0) */
	mov     %rax, %rdi
	add     $24, %rdi
	add     %rbx, %rdi /* rdi = blk(0) + 24 + size */
	brk

	/* allocation successful */
	cmp     %r12, %rax
	jbe    .Lalloc_fail

	/* create entry */
	sub     %rbx, %rax
	sub     $24, %rax /* rax = entry */
	mov     first(%rip), %rdi
	mov     %rdi, 0(%rax) /* entry.next = first */
	movq    $1, 8(%rax) /* entry.flags = 0x00000001 */
	mov     %rbx, 16(%rax) /* entry.size = size */
	mov     %rbx, 20(%rax) /* entry.capacity = size */
	mov     %rax, first(%rip) /* first = entry */
	add     $24, %rax
	jmp     .Lalloc_end

	.Lalloc_fail:
	xor     %rax, %rax

	.Lalloc_end:
	pop     %r12
	pop     %rbx
	ret

dealloc:
	mov     first(%rip), %rax

	.Lfind_entry:
	/* no entries left */
	test    %rax, %rax
	jz      .Ldealloc_end

	/* check if used */
	and     $1, 8(%rax)
	jz      .Ldealloc_next_entry

	/* update entry */
	andq    $-2, 8(%rax) /* mark available */
	je      .Ldealloc_end

	.Ldealloc_next_entry:
	mov     0(%rbx), %rbx
	jmp     .Lfind_entry

	.Ldealloc_end:
	ret
