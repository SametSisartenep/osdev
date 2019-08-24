BITS 16

start:
	MOV AX, 0x7C0	; 0x7c00/16
	MOV DS, AX
	MOV AX, 0x9E0	; (0x7c00 + 8k + 512)/16
	MOV SS, AX
	MOV SP, 8192	; allocate an 8k stack
	CALL clear
	PUSH 0x0000
	CALL initcursor
	ADD SP, 2
	PUSH bootmsg
	CALL print
	ADD SP, 2
	CLI
	HLT

clear:
	PUSH BP
	MOV BP, SP
	PUSHA
	MOV AH, 0x7	; BIOS scroll down window
	MOV AL, 0x0	; clear entire window
	MOV BH, 0x7	; white-on-black
	MOV CX, 0x0	; screen->r.min at (0,0)
	MOV DH, 24	; rows
	MOV DL, 79	; cols
	INT 0x10	; video int
	POPA
	MOV SP, BP
	POP BP
	RET

initcursor:
	PUSH BP
	MOV BP, SP
	PUSHA
	MOV AH, 0x2	; BIOS set cursor position
	MOV BH, 0x0	; graphics mode (page #0)
	MOV DX, [BP+4]	; position from first fn arg
	INT 0x10
	POPA
	MOV SP, BP
	POP BP
	RET

print:
	PUSH BP
	MOV BP, SP
	PUSHA
	MOV AH, 0xE	; tty output
	MOV BH, 0	; graphics mode (page #0)
	MOV BL, 0	; fg color (IGNORED)
	MOV SI, [BP+4]	; char* to print
_putc:
	MOV AL, [SI]
	CMP AL, 0
	JE _doneprinting
	INC SI
	INT 0x10
	JMP _putc
_doneprinting:
	POPA
	MOV SP, BP
	POP BP
	RET

bootmsg: db "ATL NK-33 boot...", 0

; padding so the sentinel ends up at 512 bytes from origin
TIMES 510-($-$$) db 0
dw 0xAA55
