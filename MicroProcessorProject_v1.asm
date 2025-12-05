org 100h   ; Make program executable for DOS (COM format)

section .data
prompt1 db "Enter first number: $"
prompt2 db "Enter second number: $"
op_prompt db "Enter operation (1:+, 2:-, 3:*, 4:/): $"
result_msg db "Result: $"
error_msg db "Error: Division by zero!$"
newline db 13, 10, "$" ; New line

section .bss
num1 resb 16             ; input buffer for first number (DOS 0Ah format)
num2 resb 16             ; input buffer for second number
op_buf resb 4            ; buffer for operator choice
result resb 16           ; output buffer for result string

section .text
_start:
    ; Ask for first number
    mov ah, 09h          ; Print string
    lea dx, prompt1
    int 21h

    lea dx, num1
    call read_line       ; Read first number into num1 buffer

    lea si, num1+2       ; Skip length bytes (DOS 0Ah input)
    mov cl, [num1+1]     ; Character count
    call atoi            ; Convert to integer -> AX
    mov bx, ax           ; Store first number in BX

    ; Ask for second number
    mov ah, 09h
    lea dx, prompt2
    int 21h

    lea dx, num2
    call read_line       ; Read second number into num2 buffer

    lea si, num2+2
    mov cl, [num2+1]
    call atoi
    mov cx, ax           ; Store second number in CX

    ; Ask for operation
    mov ah, 09h
    lea dx, op_prompt
    int 21h

    lea dx, op_buf
    call read_line       ; Read operator selection (1-4)

    mov al, [op_buf+2]   ; First character of operator choice
    sub al, '0'          ; Convert ASCII digit to number 1-4
    mov dl, al

    ; Dispatch based on operator
    cmp dl, 1
    je add_nums
    cmp dl, 2
    je sub_nums
    cmp dl, 3
    je mul_nums
    cmp dl, 4
    je div_nums

    jmp exit             ; Invalid choice, just exit

; Arithmetic operations
add_nums:
    add bx, cx           ; BX = BX + CX
    jmp show_result

sub_nums:
    sub bx, cx           ; BX = BX - CX
    jmp show_result

mul_nums:
    mov ax, bx
    mul cx               ; AX = BX * CX (unsigned)
    mov bx, ax
    jmp show_result

div_nums:
    cmp cx, 0
    je division_error    ; Check for division by zero
    mov ax, bx
    xor dx, dx           ; Clear DX for unsigned division
    div cx               ; AX = BX / CX
    mov bx, ax
    jmp show_result

division_error:
    mov ah, 09h
    lea dx, error_msg
    int 21h
    jmp exit

show_result:
    lea di, result
    mov ax, bx
    call itoa            ; Convert AX to string at [DI]

    mov ah, 09h
    lea dx, result_msg
    int 21h

    mov ah, 09h
    lea dx, result
    int 21h

    mov ah, 09h
    lea dx, newline
    int 21h

exit:
    mov ah, 4Ch
    int 21h

; Read a line using DOS function 0Ah into buffer at DX
; Buffer must be: [max_len][filled_len][chars...]
read_line:
    mov byte [dx], 14    ; Max characters (not including CR)
    mov byte [dx+1], 0   ; Initial filled length
    mov ah, 0Ah
    int 21h
    ret

; Convert ASCII decimal string at [SI] with length in CL to integer in AX
atoi:
    xor ax, ax           ; Result accumulator
    xor bx, bx
atoi_loop:
    cmp cl, 0
    je atoi_done

    mov bl, [si]
    sub bl, '0'          ; Convert digit to value
    imul ax, 10
    add ax, bx

    inc si
    dec cl
    jmp atoi_loop

atoi_done:
    ret

; Convert unsigned integer in AX to ASCII string at [DI], terminated with '$'
itoa:
    mov cx, 0            ; Digit count
    mov bx, 10

itoa_loop:
    xor dx, dx
    div bx               ; DX = remainder, AX = quotient
    add dl, '0'          ; Convert remainder to ASCII
    push dx              ; Save digit on stack
    inc cx
    test ax, ax
    jnz itoa_loop        ; Continue until AX == 0

itoa_write:
    pop dx
    mov [di], dl
    inc di
    loop itoa_write

    mov byte [di], '$'   ; String terminator for DOS function 09h
    ret
