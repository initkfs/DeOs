;authors: initkfs

global lower_half_start

extern kmain		; kernel.d

section .text
bits 64
lower_half_start:
	mov rax, QWORD kmain ;call kernel
	call rax
.hang:
	hlt
	jmp .hang
