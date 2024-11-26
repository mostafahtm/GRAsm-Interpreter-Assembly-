grasm_interpreter:
	// begin addr state in rdi
    // len in rsi
    // begin addr prog in rdx
    
    // saving prev val of registers on the stack
    push rbx 
    push r12
    
    mov r12,0
    mov rbx,0 // counter for traversing prog
    
loop:
	mov rbx , [rdi]		//rbx = ip
    cmp rbx, rsi		//ip < len?
    jge end 
    
    // recognizing instructions
    cmp byte ptr[rdx + rbx], 0x01
    je stop
    cmp byte ptr[rdx + rbx], 0x0f
    je nop
    cmp byte ptr[rdx + rbx], 0x10
    je set
    cmp byte ptr[rdx + rbx], 0x18
    je set_rX 
    cmp byte ptr[rdx + rbx], 0x11
	je cpy_rX
    cmp byte ptr[rdx + rbx], 0x19
	je cpy_rX_rY
    cmp byte ptr[rdx + rbx], 0x20
	je addOp
    cmp byte ptr[rdx + rbx], 0x28
	je add_rX_imm
    cmp byte ptr[rdx + rbx], 0x21
	je add_rX_toAC
    cmp byte ptr[rdx + rbx], 0x29
	je add_rX_rY
    cmp byte ptr[rdx + rbx], 0x22
	je subOp
    cmp byte ptr[rdx + rbx], 0x2a
	je sub_rX_imm
    cmp byte ptr[rdx + rbx], 0x23
	je sub_rX_fromAC
    cmp byte ptr[rdx + rbx], 0x2b
	je sub_rX_rY
    cmp byte ptr[rdx + rbx], 0x24
	je mulOp
    cmp byte ptr[rdx + rbx], 0x2c
	je mul_rX_imm
    cmp byte ptr[rdx + rbx], 0x25
	je mul_rX_withAC
    cmp byte ptr[rdx + rbx], 0x2d
	je mul_rX_rY
    cmp byte ptr[rdx + rbx], 0x26
	je xchg_rX
    cmp byte ptr[rdx + rbx], 0x2e
	je xchg_rX_rY
    cmp byte ptr[rdx + rbx], 0x30
	je andOp
    cmp byte ptr[rdx + rbx], 0x31
	je and_rX_imm
    cmp byte ptr[rdx + rbx], 0x32
	je and_rX_withAC
    cmp byte ptr[rdx + rbx], 0x33
	je and_rX_rY
    cmp byte ptr[rdx + rbx], 0x34
	je orOp
    cmp byte ptr[rdx + rbx], 0x35
	je or_rX_imm
    cmp byte ptr[rdx + rbx], 0x36
	je or_rX_withAC
    cmp byte ptr[rdx + rbx], 0x37
	je or_rX_rY
    cmp byte ptr[rdx + rbx], 0x38
	je xorOp
    cmp byte ptr[rdx + rbx], 0x39
	je xor_rX_imm
    cmp byte ptr[rdx + rbx], 0x3a
	je xor_rX_withAC
    cmp byte ptr[rdx + rbx], 0x3b
	je xor_rX_rY
    cmp byte ptr[rdx + rbx], 0x3c
	je notOp
    cmp byte ptr[rdx + rbx], 0x3d
	je not_rX_inAC
    cmp byte ptr[rdx + rbx], 0x3e
	je not_rX_rY
    cmp byte ptr[rdx + rbx], 0x40
	je cmp_rX
    cmp byte ptr[rdx + rbx], 0x41
	je cmp_rX_rY
    cmp byte ptr[rdx + rbx], 0x42
	je tst_rX
    cmp byte ptr[rdx + rbx], 0x43
	je tst_rX_rY
    cmp byte ptr[rdx + rbx], 0x50
	je shrOp
    cmp byte ptr[rdx + rbx], 0x51
	je shr_rX_imm
    cmp byte ptr[rdx + rbx], 0x52
	je shr_rX_AC
    cmp byte ptr[rdx + rbx], 0x53
	je shr_rX_rY
    cmp byte ptr[rdx + rbx], 0x54
	je shlOp
    cmp byte ptr[rdx + rbx], 0x55
	je shl_rX_imm
    cmp byte ptr[rdx + rbx], 0x56
	je shl_rX_AC
    cmp byte ptr[rdx + rbx], 0x57
	je shl_rX_rY
    cmp byte ptr[rdx + rbx], 0x60
	je ld
    cmp byte ptr[rdx + rbx], 0x61
	je ld_rX_imm
    cmp byte ptr[rdx + rbx], 0x62
	je ld_rX_inAC
    cmp byte ptr[rdx + rbx], 0x63
	je ld_rX_rY
    cmp byte ptr[rdx + rbx], 0x64
	je stOp
    cmp byte ptr[rdx + rbx], 0x65
	je st_rX_imm
    cmp byte ptr[rdx + rbx], 0x66
	je st_rX_AC
    cmp byte ptr[rdx + rbx], 0x67
	je st_rX_rY
    cmp byte ptr[rdx + rbx], 0x70
	je go
    cmp byte ptr[rdx + rbx], 0x71
	je go_rX
    cmp byte ptr[rdx + rbx], 0x72
	je gr
    cmp byte ptr[rdx + rbx], 0x73
	je jzOp
    cmp byte ptr[rdx + rbx], 0x74
	je jz_rX
    cmp byte ptr[rdx + rbx], 0x75
	je jrz
    cmp byte ptr[rdx + rbx], 0x80
	je ecall
    cmp byte ptr[rdx + rbx], 0x81
	je ecall_rX
    
    // Instruction doesn't exist
    jmp unknown_Opcode
    
stop:
	jmp successful
    
nop:
	add qword ptr[rdi],1 // just go to next instr; ip +=1
    jmp loop
    
set:
	inc rbx
    mov r12, qword ptr[rdx+rbx]  //r12= imm
    add rbx,8
    mov [rdi + 8], r12		// ac = imm
    mov [rdi] , rbx	// ip=rbx
    jmp loop
    
set_rX:
	inc rbx
    movzx r12, byte ptr[rdx+rbx]
    inc rbx
    and r12b,0x0F  //upper 4 bits don't care 
    cmp r12b, 0x07	// isn't reg out of bound?
    jg out_of_bound
    
    mov r11, qword ptr[rdx+rbx]	//r11= imm
    add rbx,8	//change rbx after reading 8 byte imm
    mov [rdi + r12*8 + 16], r11		//rX = imm
    mov [rdi], rbx  // ip = rbx
    jmp loop
    
cpy_rX:
	inc rbx
    movzx r12, byte ptr[rdx+rbx]
    inc rbx
    and r12b,0x0F  //upper 4 bits don't care 
    cmp r12b, 0x07	// isn't reg out of bound?
    jg out_of_bound
    mov r10, [rdi + r12*8 + 16]		//r10 = rX
    mov [rdi + 8] , r10 // ac = rX
    mov [rdi], rbx  // ip = rbx
    jmp loop
    
cpy_rX_rY:
	inc rbx
    movzx r12, byte ptr[rdx+rbx]
    inc rbx
    mov r11,r12 //make a copy byte code referring to x&y reg
    and r12b,0x0F // r12 contains Y
    cmp r12b,0x07
    jg out_of_bound
    shr r11b,4	//r11 contains X
    cmp r11b,0x07
    jg out_of_bound
    mov r10,[rdi + r12*8 + 16] // r10 = state->rY
    mov [rdi + r11*8 + 16], r10 // rX = rY
    mov [rdi], rbx  // ip = rbx
    jmp loop
    
addOp:
	inc rbx
    mov r12, qword ptr[rdx+rbx] // r12=imm
    add rbx , 8		
    add [rdi + 8], r12 	//ac += imm
    mov [rdi], rbx	// ip = rbx
    jmp loop 
    
add_rX_imm:
	inc rbx
    movzx r12, byte ptr[rdx+rbx]
    inc rbx		//inc for reading the register
    and r12b,0x0F  //upper 4 bits don't care 
    cmp r12b, 0x07
    jg out_of_bound
    
    mov r11, qword ptr[rdx+rbx]	//r11= imm
    add rbx,8	//change rbx after reading 8 byte imm
    mov r10 ,[rdi + r12*8 + 16] //r10 =rX
	add r10, r11 // r10 = rX + imm
    mov [rdi + r12*8 + 16], r10		// rX += imm
    mov [rdi], rbx  // ip = rbx
    jmp loop
   
add_rX_toAC:
	inc rbx
    movzx r12, byte ptr[rdx+rbx]
    inc rbx		//inc for reading the reg
    and r12b,0x0F  //upper 4 bits don't care 
    cmp r12b, 0x07
    jg out_of_bound
    
    mov r10 ,[rdi + r12*8 + 16]  //r10 = rX
    add [ rdi + 8], r10		//ac += rX
    mov [rdi], rbx  // ip = rbx
    jmp loop
    
add_rX_rY:
	inc rbx
    movzx r12, byte ptr[rdx+rbx]
    inc rbx
    mov r11,r12 //make a copy byte code referring to x&y reg
    and r12b,0x0F // r12 contains Y
    cmp r12b, 0x07
    jg out_of_bound
    shr r11b,4	//r11 contains X
    cmp r11b, 0x07
    jg out_of_bound
    
	mov rcx,[rdi + r12*8 + 16] // rcx = state->rY
    add [rdi + r11*8 + 16], rcx // rX += rY
    mov [rdi], rbx  // ip = rbx
    jmp loop
    
subOp:
	inc rbx
    mov r12, qword ptr[rdx+rbx] // r12=imm
    add rbx , 8		
    sub [rdi + 8], r12 	//ac -= imm
    mov [rdi], rbx	// ip = rbx
    jmp loop 
    
sub_rX_imm:
	mov rax, rsi	// rax = len
    sub rax, rbx	// rax = len - ip(counter) => remaining bytes of prog
    cmp rax, 10		// check if remaining bytes are at least 10 for this instr
    jl unknown_Opcode
    
	inc rbx
    movzx r12, byte ptr[rdx+rbx]
    inc rbx		//inc for reading the imm
    and r12b,0x0F  //upper 4 bits don't care 
    cmp r12b, 0x07
    jg out_of_bound
    
    mov r11, qword ptr[rdx+rbx]	//r11= imm
    add rbx,8	//change rbx after reading 8 byte imm
    mov r10 ,[rdi + r12*8 + 16] //r10 =rX
	sub r10, r11 // r10 = rX- imm
    mov [rdi + r12*8 + 16], r10
    mov [rdi], rbx  // ip = rbx
    jmp loop
    
sub_rX_fromAC:
	inc rbx
    movzx r12, byte ptr[rdx+rbx]
    inc rbx		//inc for reading the reg
    and r12b,0x0F  //upper 4 bits don't care 
    cmp r12b, 0x07
    jg out_of_bound
    
    mov r10 ,[rdi + r12*8 + 16]  //r10 = rX
    sub [rdi + 8], r10		//ac -= rX
    mov [rdi], rbx  // ip = rbx
    jmp loop
    
sub_rX_rY:
	inc rbx
    movzx r12, byte ptr[rdx+rbx]
    inc rbx
    mov r11,r12 //make a copy byte code referring to x&y reg
    and r12b,0x0F // r12 contains Y
    cmp r12b, 0x07
    jg out_of_bound
    shr r11b,4	//r11 contains X
    cmp r11b, 0x07
    jg out_of_bound
    
	mov rcx,[rdi + r12*8 + 16] // rcx = state->rY
    sub [rdi + r11*8 + 16], rcx // rX -= rY
    mov [rdi], rbx  // ip = rbx
    jmp loop
    
mulOp:
	inc rbx
    mov r12, qword ptr[rdx+rbx] // r12=imm
    add rbx , 8	
    mov rax , [rdi + 8]  //rax = ac
    push rdx	//save rdx on the stack
    mul r12		// rdx::rax = ac* imm
    mov [rdi+8], rax	// ac *= imm
    pop rdx		// rdx retrieval
    mov [rdi], rbx  // ip = rbx
    jmp loop
    
mul_rX_imm:
	inc rbx
    movzx r12, byte ptr[rdx+rbx]
    inc rbx		//inc for reading the imm
    and r12b,0x0F  //upper 4 bits don't care 
    cmp r12b, 0x07
    jg out_of_bound
    
    mov rax, qword ptr[rdx+rbx]	//rax= imm
    add rbx,8	//change rbx after reading 8 byte imm
    mov r10 ,[rdi + r12*8 + 16] //r10 =rX
    push rdx  // save rdx
	mul r10  //	rdx::rax = rX * imm
    mov [rdi + r12*8 + 16], rax		// rX *= imm
    pop rdx 	// retrieve rdx
    mov [rdi], rbx  // ip = rbx
    jmp loop
    
mul_rX_withAC:
	inc rbx
    movzx r12, byte ptr[rdx+rbx]
    inc rbx		//inc for reading the reg
    and r12b,0x0F  //upper 4 bits don't care 
    cmp r12b, 0x07
    jg out_of_bound
    
    mov rax ,[rdi + r12*8 + 16]  //rax = rX
    push rdx 	//save rdx
    mul qword ptr [rdi + 8]	//rdx::rax = ac* rX
    mov [rdi + 8], rax 	// ac *= rX
    pop rdx // retrieve rdx
    mov [rdi], rbx  // ip = rbx
    jmp loop
    
mul_rX_rY:
	inc rbx
    movzx r12, byte ptr[rdx+rbx]
    inc rbx
    mov r11,r12 //make a copy byte code referring to x&y reg
    and r12b,0x0F // r12 contains Y
    cmp r12b, 0x07
    jg out_of_bound
    shr r11b,4	//r11 contains X
    cmp r11b, 0x07
    jg out_of_bound
    
    mov rax,[rdi + r11*8 + 16] // rax = state->rX
	mov rcx,[rdi + r12*8 + 16] // rcx = state->rY
    push rdx //save rdx before multiplying
    mul rcx // rdx::rax = rX*rY
    mov [rdi + r11*8 + 16], rax  //state->rX = rX*rY
    pop rdx
    mov [rdi], rbx  // ip = rbx
    jmp loop
    
xchg_rX:
	inc rbx
    movzx r12, byte ptr[rdx+rbx]
    inc rbx		//inc for reading the next instr
    and r12b,0x0F  //upper 4 bits don't care 
    cmp r12b, 0x07
    jg out_of_bound
    
    mov r10, [rdi+8]  	// r10 = ac
    mov r11, [rdi + 8*r12 + 16]	//r11 = rX
    mov [rdi + 8], r11  // ac= rX
    mov [rdi + 8*r12 + 16], r10 // rX = ac
    mov [rdi], rbx  // ip = rbx
    jmp loop
    
xchg_rX_rY:
	inc rbx
    movzx r12, byte ptr[rdx+rbx]
    inc rbx
    mov r11,r12 //make a copy byte code referring to x&y reg
    and r12b,0x0F // r12 contains Y
    cmp r12b, 0x07
    jg out_of_bound
    shr r11b,4	//r11 contains X
    cmp r11b, 0x07
    jg out_of_bound
    
    mov r10, [rdi + r12*8 + 16]		//r10 = rY
    mov r9, [rdi + r11*8 + 16]		// r9= rX
    mov [rdi + r12*8 + 16], r9	// rY= rX
    mov [rdi + r11*8 + 16], r10	//rX = rY
    mov [rdi], rbx  // ip = rbx
    jmp loop
    
andOp:
	inc rbx
    mov r12, qword ptr[rdx+rbx] // r12=imm
    add rbx , 8		
    and [rdi + 8], r12 	//ac &= imm
    mov [rdi], rbx	// ip = rbx
    jmp loop 
    
and_rX_imm:
	inc rbx
    movzx r12, byte ptr[rdx+rbx]
    inc rbx		//inc for reading the imm
    and r12b,0x0F  //upper 4 bits don't care 
    cmp r12b, 0x07
    jg out_of_bound
    
    mov r11, qword ptr[rdx+rbx]	//r11= imm
    add rbx,8	//change rbx after reading 8 byte imm
    and [rdi + r12*8 + 16], r11 //rX &= imm
    mov [rdi], rbx  // ip = rbx
    jmp loop
    
and_rX_withAC:
	inc rbx
    movzx r12, byte ptr[rdx+rbx]
    inc rbx		//inc for reading next instr
    and r12b,0x0F  //upper 4 bits don't care 
    cmp r12b, 0x07
    jg out_of_bound
    
    mov r10 ,[rdi + r12*8 + 16]  //r10 = rX
    and [rdi + 8], r10		//ac &= rX
    mov [rdi], rbx  // ip = rbx
    jmp loop
    
and_rX_rY:
	inc rbx
    movzx r12, byte ptr[rdx+rbx]
    inc rbx
    mov r11,r12 //make a copy byte code referring to x&y reg
    and r12b,0x0F // r12 contains Y
    cmp r12b, 0x07
    jg out_of_bound
    shr r11b,4	//r11 contains X
    cmp r11b, 0x07
    jg out_of_bound
    
	mov rcx,[rdi + r12*8 + 16] // rcx = state->rY
    and [rdi + r11*8 + 16], rcx // rX &= rY
    mov [rdi], rbx  // ip = rbx
    jmp loop
    
orOp:
	inc rbx
    mov r12, qword ptr[rdx+rbx] // r12=imm
    add rbx , 8		
    or [rdi + 8], r12 	//ac |= imm
    mov [rdi], rbx	// ip = rbx
    jmp loop 
    
or_rX_imm:
	inc rbx
    movzx r12, byte ptr[rdx+rbx]
    inc rbx		//inc for reading the imm
    and r12b,0x0F  //upper 4 bits don't care 
    cmp r12b, 0x07
    jg out_of_bound
    
    mov r11, qword ptr[rdx+rbx]	//r11= imm
    add rbx,8	//change rbx after reading 8 byte imm
    or [rdi + r12*8 + 16], r11 //rX |= imm
    mov [rdi], rbx  // ip = rbx
    jmp loop
    
or_rX_withAC:
	inc rbx
    movzx r12, byte ptr[rdx+rbx]
    inc rbx		//inc for reading next instr
    and r12b,0x0F  //upper 4 bits don't care 
    cmp r12b, 0x07
    jg out_of_bound
    
    mov r10 ,[rdi + r12*8 + 16]  //r10 = rX
    or [rdi + 8], r10		//ac |= rX
    mov [rdi], rbx  // ip = rbx
    jmp loop
    
or_rX_rY:
	inc rbx
    movzx r12, byte ptr[rdx+rbx]
    inc rbx
    mov r11,r12 //make a copy byte code referring to x&y reg
    and r12b,0x0F // r12 contains Y
    cmp r12b, 0x07
    jg out_of_bound
    shr r11b,4	//r11 contains X
    cmp r11b, 0x07
    jg out_of_bound
    
	mov rcx,[rdi + r12*8 + 16] // rcx = state->rY
    or [rdi + r11*8 + 16], rcx // rX |= rY
    mov [rdi], rbx  // ip = rbx
    jmp loop
    
xorOp:
	inc rbx
    mov r12, qword ptr[rdx+rbx] // r12=imm
    add rbx , 8		
    xor [rdi + 8], r12 	//ac ^= imm
    mov [rdi], rbx	// ip = rbx
    jmp loop 
    
xor_rX_imm:
	inc rbx
    movzx r12, byte ptr[rdx+rbx]
    inc rbx		//inc for reading the imm
    and r12b,0x0F  //upper 4 bits don't care 
    cmp r12b, 0x07
    jg out_of_bound
    
    mov r11, qword ptr[rdx+rbx]	//r11= imm
    add rbx,8	//change rbx after reading 8 byte imm
    xor [rdi + r12*8 + 16], r11 //rX ^= imm
    mov [rdi], rbx  // ip = rbx
    jmp loop
    
xor_rX_withAC:
	inc rbx
    movzx r12, byte ptr[rdx+rbx]
    inc rbx		//inc for reading next instr
    and r12b,0x0F  //upper 4 bits don't care 
    cmp r12b, 0x07
    jg out_of_bound
    
    mov r10 ,[rdi + r12*8 + 16]  //r10 = rX
    xor [rdi + 8], r10		//ac ^= rX
    mov [rdi], rbx  // ip = rbx
    jmp loop
    
xor_rX_rY:
	inc rbx
    movzx r12, byte ptr[rdx+rbx]
    inc rbx
    mov r11,r12 //make a copy byte code referring to x&y reg
    and r12b,0x0F // r12 contains Y
    cmp r12b, 0x07
    jg out_of_bound
    shr r11b,4	//r11 contains X
    cmp r11b, 0x07
    jg out_of_bound
    
	mov rcx,[rdi + r12*8 + 16] // rcx = state->rY
    xor [rdi + r11*8 + 16], rcx // rX ^= rY
    mov [rdi], rbx  // ip = rbx
    jmp loop
    
notOp:
	inc rbx
	not qword ptr[rdi + 8]	//ac ~= ac
    mov [rdi], rbx	// ip = rbx
    jmp loop 
    
not_rX_inAC:
	inc rbx
    movzx r12, byte ptr[rdx+rbx]
    inc rbx		//inc for reading next instr
    and r12b,0x0F  //upper 4 bits don't care 
    cmp r12b, 0x07
    jg out_of_bound
    
    mov r10 ,[rdi + r12*8 + 16]  //r10 = rX
    not r10			// rX = ~rX
    mov [rdi + 8], r10		//ac = ~rX
    mov [rdi], rbx  // ip = rbx
    jmp loop
    
not_rX_rY:
	inc rbx
    movzx r12, byte ptr[rdx+rbx]
    inc rbx
    mov r11,r12 //make a copy byte code referring to x&y reg
    and r12b,0x0F // r12 contains Y
    cmp r12b, 0x07
    jg out_of_bound
    shr r11b,4	//r11 contains X
    cmp r11b, 0x07
    jg out_of_bound
    
	mov rcx,[rdi + r12*8 + 16] // rcx = state->rY
    not rcx 		// rcx = ~rY
    mov [rdi + r11*8 + 16], rcx // rX = ~rY
    mov [rdi], rbx  // ip = rbx
    jmp loop
    
cmp_rX:
	inc rbx
    movzx r12, byte ptr[rdx+rbx]
    inc rbx		//inc for reading the imm
    and r12b,0x0F  //upper 4 bits don't care 
    cmp r12b, 0x07
    jg out_of_bound
    
    mov r11, [rdx+rbx]	//r11= imm
    add rbx,8	//change rbx after reading 8 byte imm
    mov r12 ,[rdi + r12*8 + 16] //r12 =rX
    sub r12, r11 // r12 = rX- imm
    mov [rdi + 8], r12  // ac= rX -imm
    mov [rdi], rbx  // ip = rbx
    jmp loop
   	
cmp_rX_rY:
	inc rbx
    movzx r12, byte ptr[rdx+rbx]
    inc rbx
    mov r11,r12 //make a copy byte code referring to x&y reg
    and r12b,0x0F // r12 contains Y
    cmp r12b, 0x07
    jg out_of_bound
    shr r11b,4	//r11 contains X
    cmp r11b, 0x07
    jg out_of_bound
    
    mov rcx,[rdi + r12*8 + 16] // rcx = state->rY
    mov rax,[rdi + r11*8 + 16]	// rax = rX
    sub rax, rcx		//rax = rX - rY
    mov [rdi + 8], rax		// ac= rX-rY
    mov [rdi], rbx  // ip = rbx
    jmp loop
    
tst_rX:
	inc rbx
    movzx r12, byte ptr[rdx+rbx]
    inc rbx		//inc for reading the imm
    and r12b,0x0F  //upper 4 bits don't care 
    cmp r12b, 0x07
    jg out_of_bound
    
    mov r11, [rdx+rbx]	//r11= imm
    add rbx,8	//change rbx after reading 8 byte imm
    mov r12 ,[rdi + r12*8 + 16] //r12 =rX
    and r12, r11 // r12 = rX & imm
    mov [rdi + 8], r12  // ac= rX & imm
    mov [rdi], rbx  // ip = rbx
    jmp loop
    
tst_rX_rY:
	inc rbx
    movzx r12, byte ptr[rdx+rbx]
    inc rbx
    mov r11,r12 //make a copy byte code referring to x&y reg
    and r12b,0x0F // r12 contains Y
    cmp r12b, 0x07
    jg out_of_bound
    shr r11b,4	//r11 contains X
    cmp r11b, 0x07
    jg out_of_bound
    
    mov rcx,[rdi + r12*8 + 16] // rcx = state->rY
    mov rax,[rdi + r11*8 + 16]	// rax = rX
    and rax, rcx		//rax = rX & rY
    mov [rdi + 8], rax		// ac= rX & rY
    mov [rdi], rbx  // ip = rbx
    jmp loop
    
shrOp:	
	inc rbx
    mov cl, [rdx + rbx]
    inc rbx		// imm was only 8 bits
    and cl, 0x3F  // shift can be maximal 63 bits(we need just lower 6 bits)
    shr qword ptr[rdi + 8], cl	// ac >>= cl
    mov [rdi], rbx  // ip = rbx
    jmp loop
    
shr_rX_imm:
	inc rbx
    movzx r12, byte ptr[rdx+rbx]
    inc rbx		//inc for reading the imm
    and r12b,0x0F  //upper 4 bits don't care 
    cmp r12b, 0x07
    jg out_of_bound
    
    mov cl, [rdx+rbx]	//cl =imm
    inc rbx		// imm was only 8 bits
    and cl, 0x3F  // shift can be maximal 63 bits(we need just lower 6 bits)
    shr qword ptr[rdi + r12*8 + 16], cl	// rX >>= cl
    mov [rdi], rbx  // ip = rbx
    jmp loop
    
shr_rX_AC:
	inc rbx
    movzx r12, byte ptr[rdx+rbx]
    inc rbx		//inc for reading the reg
    and r12b,0x0F  //upper 4 bits don't care 
    cmp r12b, 0x07
    jg out_of_bound
    
    mov rcx,[rdi + r12*8 + 16]	//rcx = rX
    and cl, 0x3F  // shift can be maximal 63 bits(we need just lower 6 bits)
    shr qword ptr [rdi + 8], cl //ac >>= rX
    mov [rdi], rbx  // ip = rbx
    jmp loop
    
shr_rX_rY:
	inc rbx
    movzx r12, byte ptr[rdx+rbx]
    inc rbx
    mov r11,r12 //make a copy byte code referring to x&y reg
    and r12b,0x0F // r12 contains Y
    cmp r12b, 0x07
    jg out_of_bound
    shr r11b,4	//r11 contains X
    cmp r11b, 0x07
    jg out_of_bound
    
    mov rcx,[rdi + r12*8 + 16] // rcx = state->rY
    and cl, 0x3F  // shift can be maximal 63 bits(we need just lower 6 bits)
    shr qword ptr[rdi + r11*8 + 16], cl  // rX >>= rY
    mov [rdi], rbx  // ip = rbx
    jmp loop
    
shlOp:
	inc rbx
    mov cl, [rdx + rbx]
    inc rbx		// imm was only 8 bits
    and cl, 0x3F  // shift can be maximal 63 bits(we need just lower 6 bits)
    shl qword ptr[rdi + 8], cl	// ac <<= cl
    mov [rdi], rbx  // ip = rbx
    jmp loop
    
shl_rX_imm:
	inc rbx
    movzx r12, byte ptr[rdx+rbx]
    inc rbx		//inc for reading the imm
    and r12b,0x0F  //upper 4 bits don't care 
    cmp r12b, 0x07
    jg out_of_bound
    
    mov cl, [rdx+rbx]	//cl =imm
    inc rbx		// imm was only 8 bits
    and cl, 0x3F  // shift can be maximal 63 bits(we need just lower 6 bits)
    shl qword ptr[rdi + r12*8 + 16], cl	// rX <<= cl
    mov [rdi], rbx  // ip = rbx
    jmp loop
    
shl_rX_AC:
	inc rbx
    movzx r12, byte ptr[rdx+rbx]
    inc rbx		//inc for reading the reg
    and r12b,0x0F  //upper 4 bits don't care 
    cmp r12b, 0x07
    jg out_of_bound
    
    mov rcx,[rdi + r12*8 + 16]	//rcx = rX
    and cl, 0x3F  // shift can be maximal 63 bits(we need just lower 6 bits)
    shl qword ptr [rdi + 8], cl //ac <<= rX
    mov [rdi], rbx  // ip = rbx
    jmp loop
    
shl_rX_rY:
	inc rbx
    movzx r12, byte ptr[rdx+rbx]
    inc rbx
    mov r11,r12 //make a copy byte code referring to x&y reg
    and r12b,0x0F // r12 contains Y
    cmp r12b, 0x07
    jg out_of_bound
    shr r11b,4	//r11 contains X
    cmp r11b, 0x07
    jg out_of_bound
    
    mov rcx,[rdi + r12*8 + 16] // rcx = state->rY
    and cl, 0x3F  // shift can be maximal 63 bits(we need just lower 6 bits)
    shl qword ptr[rdi + r11*8 + 16], cl  // rX <<= rY
    mov [rdi], rbx  // ip = rbx
    jmp loop
    
ld:
ld_rX_imm:
ld_rX_inAC:
ld_rX_rY:	
	inc rbx
    movzx r12, byte ptr[rdx+rbx]
    inc rbx
    mov r11,r12 //make a copy byte code referring to x&y reg
    and r12b,0x0F // r12 contains Y
    cmp r12b, 0x07
    jg out_of_bound
    shr r11b,4	//r11 contains X
    cmp r11b, 0x07
    jg out_of_bound
    
    mov rcx,[rdi + r12*8 + 16] // rcx = state->rY
    mov rax, [rcx]
    mov [rdi + r11*8 + 16],rax	//rX=[rY]
    mov [rdi], rbx  // ip = rbx
    jmp loop
    
stOp:
st_rX_imm:
st_rX_AC:
st_rX_rY:
go:
go_rX:

gr:
	inc rbx
    mov r12w, [rdx + rbx]		//r12=imm
    add rbx,2
    //mov [rdi], rbx  // ip = rbx
	add [rdi], r12w		// ip += imm
    jmp loop
    
jzOp:
jz_rX:

jrz:
	inc rbx
    mov r12, [rdi+8]
    cmp r12,0
    jne jrz_skip
    mov r11w, [rdx+rbx]
    add rbx,2
    add [rdi],r11w
    jmp loop
jrz_skip:
	add qword ptr[rdi], 0x03
    jmp loop
   
ecall:	
	inc rbx
    mov r12, [rdx+rbx]  // r12 =imm
    add rbx,8	// cuz imm is a pointer(64bit addr)
    mov [rdi], rbx	// ip = rbx
    
    push r13		// val of r13 shouldn't be changed in the func(callee saved)
    mov r13,rdi		//cuz rdi wanna contain a param afterwards
    push r14		// val of r14 shouldn't be changed in the func(callee saved)
    mov r14,rsi		//cuz rsi wanna contain a param afterwards
    push r15		// val of r15 shouldn't be changed in the func(callee saved)
    mov r15,rdx		//cuz rdx wanna contain a param afterwards
    
    mov rdi,[r13 + 0*8 + 16]	// rdi = r0
    mov rsi,[r13 + 1*8 + 16]	// rsi = r1
    mov rdx,[r13 + 2*8 + 16]	// rdx = r2
    mov rcx,[r13 + 3*8 + 16]	// rdx = r3
    mov r8,[r13 + 4*8 + 16]	// rdx = r4
    mov r9,[r13 + 5*8 + 16]	// rdx = r5
    
    call r12
    mov rdi, r13	//retrieve prev val before call
    mov rsi, r14	//retrieve prev val before call	
    mov rdx, r15	//retrieve prev val before call
    mov [rdi +8], rax		// ac= rax
    
    pop r15
    pop r14
    pop r13
    
    jmp loop 
    
ecall_rX:
  
unknown_Opcode:
    mov rax,-1
    //mov [rdi], rbx 
    jmp end
    
successful:
 	mov rax,0
 	mov [rdi], rbx  // ip = rbx
    add qword ptr[rdi],1
    jmp end
    
out_of_bound:
	mov rax , -2
    jmp end
    
end:	
	pop r12
    pop rbx
  ret