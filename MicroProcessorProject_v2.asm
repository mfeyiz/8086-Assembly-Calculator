.model small
.stack 100h
.data
    msg1 db 'Enter number (0 to finish): $'
    msg2 db 10,13,'Select operation (+,-,*,/) or Q to quit: $'
    msg3 db 10,13,'Result: $'
    newline db 10,13,'$'
    minus db '-$'
    numbers dw 100 dup(?)
    count dw 0
    result dw 0
    temp dw 0
    ten dw 10
    isNegative db 0

.code
main proc
    mov ax, @data
    mov ds, ax
    
main_loop:
    mov count, 0
    
input_loop:
    lea dx, msg1
    mov ah, 9
    int 21h
    
    call read_number
    
    cmp ax, 0
    je select_operation
    
    mov si, count
    mov numbers[si], ax
    add count, 2
    
    lea dx, newline
    mov ah, 9
    int 21h
    
    jmp input_loop

select_operation:
    lea dx, msg2
    mov ah, 9
    int 21h
    
    mov ah, 1
    int 21h
    
    cmp al, 'q'
    je exit_program
    cmp al, 'Q'
    je exit_program
    
    cmp al, '+'
    je add_numbers
    cmp al, '-'
    je subtract_numbers
    cmp al, '*'
    je multiply_numbers
    cmp al, '/'
    je divide_numbers

add_numbers:
    mov cx, count
    mov si, 0
    mov ax, numbers[si]
    add si, 2
    sub cx, 2
add_loop:
    cmp cx, 0
    je write_result
    add ax, numbers[si]
    add si, 2
    sub cx, 2
    jmp add_loop
    
subtract_numbers:
    mov cx, count
    mov si, 0
    mov ax, numbers[si]
    add si, 2
    sub cx, 2
sub_loop:
    cmp cx, 0
    je write_result
    sub ax, numbers[si]
    add si, 2
    sub cx, 2
    jmp sub_loop
    
multiply_numbers:
    mov cx, count
    mov si, 0
    mov ax, numbers[si]
    add si, 2
    sub cx, 2
mul_loop:
    cmp cx, 0
    je write_result
    mul word ptr numbers[si]
    add si, 2
    sub cx, 2
    jmp mul_loop
    
divide_numbers:
    mov cx, count
    mov si, 0
    mov ax, numbers[si]
    add si, 2
    sub cx, 2
    
div_loop:
    cmp cx, 0
    je write_result
    cwd
    idiv word ptr numbers[si]
    add si, 2
    sub cx, 2
    jmp div_loop
    
write_result:
    mov result, ax
    
    lea dx, msg3
    mov ah, 9
    int 21h
    
    mov ax, result
    call write_number
    
    lea dx, newline
    mov ah, 9
    int 21h
    
    jmp main_loop
    
exit_program:
    mov ah, 4ch
    int 21h
main endp

read_number proc
    mov bx, 0
    mov byte ptr [isNegative], 0
    
    mov ah, 1
    int 21h
    cmp al, '-'
    jne first_digit
    mov byte ptr [isNegative], 1
    jmp read_digits
    
first_digit:
    sub al, 30h
    mov cl, al
    mov ax, bx
    mul ten
    mov bx, ax
    add bl, cl
    
read_digits:
    mov ah, 1
    int 21h
    
    cmp al, 13
    je end_read
    
    sub al, 30h
    mov cl, al
    mov ax, bx
    mul ten
    mov bx, ax
    add bl, cl
    jmp read_digits
    
end_read:
    mov ax, bx
    cmp byte ptr [isNegative], 1
    jne positive_value
    neg ax
positive_value:
    ret
read_number endp

write_number proc
    mov bx, 0
    mov cx, 0
    
    test ax, ax
    jns convert_loop
    push ax
    mov dl, '-'
    mov ah, 2
    int 21h
    pop ax
    neg ax
    
convert_loop:
    mov dx, 0
    div ten
    push dx
    inc cx
    test ax, ax
    jnz convert_loop
    
print_loop:
    pop dx
    add dl, '0'
    mov ah, 2
    int 21h
    loop print_loop
    
    ret
write_number endp
end main
