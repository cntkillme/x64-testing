.text
	.align 16
	.global main
	.extern alloc, dealloc
	.extern itos
	.type main, STT_FUNC

main:
	sub     $24, %rsp
	mov     %rsp, %rsi
	mov     $666, %rdi /* value */
	mov     $2, %rdx /* base */
	call    itos /* expected: 1010011010 */

	sub     %rsp, %rax

	mov     %rsp, %rdi /* buffer */
	mov     %rax, %rsi /* size */
	call    write

	add     $24, %rsp
	mov     $60, %rax /* exit */
	mov     $0, %rdi
	syscall
