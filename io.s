.data
	.align 16
	.type digits, STT_OBJECT

digits: .ascii "0123456789ABCDEF"

.text
	.align 16
	.global read, write
	.global itos
	.type read, STT_FUNC
	.type write, STT_FUNC

/* size_t read(char* buffer, size_t count) */
read:
	/* read(stdin, buffer, count) */
	mov     %rsi, %rdx
	mov     %rdi, %rsi
	mov     $0, %rax
	mov     $0, %rdi
	syscall

	ret

/* size_t write(char* buffer, size_t count) */
write:
	/* write(stdout, buffer, count) */
	mov     %rsi, %rdx
	mov     %rdi, %rsi
	mov     $1, %rax
	mov     $1, %rdi
	syscall

	ret

/* char* itos(size_t value, char (*buffer[24]), size_t base) */
itos:
	push    %rbx

	/* ensure 2 <= base <= 16 */
	cmp     $2, %rdx
	jb      .Litos_bad_base
	cmp     $16, %rdx
	ja      .Litos_bad_base

	mov     %rdx, %rcx
	mov     %rdi, %rax
	mov     %rsi, %rbx

	.Litos_next_character:
	/* value / base */
	xor     %rdx, %rdx
	div     %rcx

	/* *(buffer++) = digits[value % base] */
	lea     digits(%rip), %r8
	mov     0(%r8, %rdx, 1), %dl
	mov     %dl, 0(%rsi)
	inc     %rsi

	/* value != 0 */
	test    %rax, %rax
	jnz     .Litos_next_character

	/* reverse */
	mov     %rbx, %rdi
	mov     %rsi, %rbx
	call    reverse
	mov     %rbx, %rax
	jmp     .Litos_end

	.Litos_bad_base:
	xor     %rax, %rax

	.Litos_end:
	pop      %rbx
	ret

/* void reverse(char* start, char* end) */
reverse:
	dec     %rsi

	.Lreverse_character:
	cmp     %rsi, %rdi
	jae     .Lreverse_end
	mov     0(%rdi), %al
	xchg    0(%rsi), %al
	mov     %al, 0(%rdi)
	inc     %rdi
	dec     %rsi
	jmp     .Lreverse_character

	.Lreverse_end:
	ret
