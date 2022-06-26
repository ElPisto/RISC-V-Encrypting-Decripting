.data

    sostK: .word 5
    blockey: .string "set"
    #mycypher: .string "ABC"
    mycypher: .string "ECD"
    #myplaintext: .string "Campo da tennis"
    myplaintext: .string "26-06-2022"
    
.text
    la s0 myplaintext
    la s1 mycypher
    lw s2 sostK
    la s3 blockey
    la s4 300009000
    li s5 0
    j Lettura_mycypher
    
    Cifrario_a_Sostituzione:
        add t0 s0 zero  
        a_loop: 
            lb t1 0(t0)
            beq t1 zero to_string
            add a2 t1 zero
            jal interval_check
            li t2 2
            beq a3 t2 advance_a_loop
            beq a3 zero convert_minuscule
            li t2 1
            beq a3 t2 convert_maiuscule
            convert_maiuscule:
                li a1 65
                jal cypher_letter
                j a_loop
            convert_minuscule:
                li a1 97
                jal cypher_letter
                j a_loop
            advance_a_loop:
                addi t0 t0 1
                j a_loop
            cypher_letter:
                sub t1 t1 a1
                add t1 t1 s2
                li t2 26
                rem t1 t1 t2
                sb ra 0(sp)
                jal adjust_module
                lb ra 0(sp)
                add t1 t1 a1
                sb t1 0(t0)
                addi t0 t0 1
                jr ra
            adjust_module:
                bge t1 zero back
                addi t1 t1 26
                jr ra
                back:
                    jr ra
    
    Cifrario_a_Blocchi:
        add t0 s0 zero
        add t1 s3 zero
        b_loop:
            lb t2 0(t0)
            beq t2 zero to_string
            lb t3 0(t1)
            beq t3 zero reset_key_head
            add t2 t2 t3
            li t4 96
            rem t2 t2 t4
            addi t2 t2 32
            sb t2 0(t0)
            addi t0 t0 1
            addi t1 t1 1
            j b_loop
        reset_key_head:
            add t1 s3 zero
            j b_loop
            
    Cifratura_Occorrenze:
        add t0 s0 zero
        add t4 s4 zero
        c_loop:
            lb a1 0(t0)
            beq a1 zero exit_cifratura_occorrenze
            li t1 27
            beq a1 t1 skip_char_write
            sb a1 0(t4)
            add a0 t0 zero
            jal write_auxstr
            c_inner_loop:
                addi a0 a0 1
                lb t5 0(a0)
                beq t5 zero advance_c_loop
                bne a1 t5 next_char
                li t1 27
                sb t1 0(a0)
                jal write_auxstr
            next_char:
                j c_inner_loop
        advance_c_loop:
            addi t4 t4 1
            li t1 32
            sb t1 0(t4)
            addi t4 t4 1
        skip_char_write:
            addi t0 t0 1
            j c_loop 
        exit_cifratura_occorrenze:
            addi t4 t4 -1
            j swap_head
    
    Dizionario:
        add t0 s0 zero
        d_loop:
            lb a2 0(t0)
            beq a2 zero to_string
            li t1 32
            blt a2 t1 exit
            li t1 127
            bgt a2 t1 exit
            jal interval_check
            beq a3 zero cypher_minuscule
            li t1 1
            beq a3 t1 cypher_maiuscule
            li t1 48
            blt a2 t1 advance_d_loop
            li t1 58
            blt a2 t1 cypher_number
            advance_d_loop: 
                addi t0 t0 1
                j d_loop
            cypher_minuscule:
                addi a2 a2 -97
                li t1 122
                sub a2 t1 a2
                addi a2 a2 -32
                sb a2 0(t0)
                addi t0 t0 1
                j d_loop
            cypher_maiuscule:
                addi a2 a2 -65
                li t1 90
                sub a2 t1 a2
                addi a2 a2 32
                sb a2 0(t0)
                addi t0 t0 1
                j d_loop
            cypher_number:
                li t1 57
                sub a2 t1 a2
                addi a2 a2 48
                sb a2 0(t0)
                addi t0 t0 1
                j d_loop
    
    Inversione:
        add t0 s0 zero
        fill_stack:
            lb t1 0(t0) 
            beq t1 zero reset_head
            addi sp sp -1
            sb t1 0(sp)
            addi t0 t0 1
            j fill_stack
        reset_head:
            add t0 s0 zero
        empty_stack:
            lb t2 0(t0)
            beq t2 zero to_string
            lb t2 0(sp)
            addi sp sp 1
            sb t2 0(t0)
            addi t0 t0 1
            j empty_stack
    
    Decifratura_a_Blocchi:
        add t0 s0 zero
        add t1 s3 zero
        db_loop:
            lb t2 0(t0)
            beq t2 zero to_string
            lb t3 0(t1)
            beq t3 zero dreset_key_head
            sub t2 t2 t3
            addi t2 t2 -32
            li t4 32
            correct_module:
                bge t2 t4 advance_db_loop
                addi t2 t2 96
                j correct_module
            advance_db_loop:
                sb t2 0(t0)
                addi t0 t0 1
                addi t1 t1 1
                j db_loop
        dreset_key_head:
            add t1 s3 zero
            j db_loop
    
    Decifratura_Occorrenze:
        li t4 0
        add t0 s0 zero
        write_char_loop:
            lb t1 0(t0)
            addi t0 t0 1
            pos_loop:
                lb t2 0(t0)
                beq t2 zero exit_decifratura_occorrenze
                li t3 45
                beq t2 t3 advance_pos_loop
                li t3 32
                beq t2 t3 advance_write_char_loop
                li a1 0
                li a3 0
                li a2 0
                j convert_to_int
                advance_pos_loop:
                    addi t0 t0 1
                    j pos_loop
                advance_write_char_loop:
                    addi t0 t0 1
                    j write_char_loop
                write_char:
                    bgt a3 t4 set_max
                    max_set:
                        addi a3 a3 -1
                        add a3 s4 a3
                        sb t1 0(a3)
                        j pos_loop
                    set_max:
                        add t4 a3 zero
                        j max_set
                    exit_decifratura_occorrenze:
                        add t4 t4 s4
                        j swap_head
    
    to_string:
        add a0 s0 zero
        li a7 4
        ecall
        li a0 10
        li a7 11
        ecall
        beq s5 zero loop
        j rev_loop
    
    interval_check:
        li t2 65
        blt a2 t2 set_special_char
        li t2 90
        bgt a2 t2 lowercase_check
        li a3 1
        jr ra
        lowercase_check:
            li t2 97
            blt a2 t2 set_special_char
            li t2 122
            bgt a2 t2 set_special_char
            li a3 0
            jr ra
        set_special_char:
            li a3 2
            jr ra
    
    write_auxstr:
        li a2 0
        li t1 45
        addi t4 t4 1
        sb t1 0(t4)
        addi t4 t4 1
        sub a3 a0 s0
        addi a3 a3 1
        dividing:
            li t1 10
            rem t2 a3 t1
            sb t2 0(sp)
            addi sp sp -1
            addi a2 a2 1
            div a3 a3 t1 
            bne a3 zero dividing
            li t6 0
        write_loop:
            addi sp sp 1
            lb t5 0(sp)
            addi t1 t5 48
            sb t1 0(t4)
            addi t4 t4 1
            addi t6 t6 1
            blt t6 a2 write_loop
            addi t4 t4 -1
            jr ra
    
    convert_to_int:
        lb t2 0(t0)
        li t3 45
        beq t2 t3 conversion
        li t3 32
        beq t2 t3 conversion
        beq t2 zero conversion
        addi sp sp -1
        sb t2 0(sp)
        addi a1 a1 1
        addi t0 t0 1
        j convert_to_int
        conversion:
            add a2 a1 zero
        multiplication:
            sub t3 a1 a2
            beq a2 zero write_char
            addi a2 a2 -1
            lb t2 0(sp)
            addi sp sp 1
            addi t2 t2 -48
            beq t3 zero skip_pow
            li t6 0
            pow:
                beq t6 t3 skip_pow
                li t5 10
                mul t2 t2 t5
                addi t6 t6 1
                j pow
            skip_pow:
                add a3 a3 t2
                j multiplication
        
    swap_head:
        sb zero 0(t4)
        add t1 s0 zero
        add s0 s4 zero
        add s4 t1 zero
        j to_string
    
    Lettura_mycypher:
        add s6 s1 zero
        loop:
            lb t1 0(s6)
            beq t1 zero adjust_values
            addi s6 s6 1
            li t2 65
            beq t1 t2 Cifrario_a_Sostituzione
            li t2 66
            beq t1 t2 Cifrario_a_Blocchi
            li t2 67
            beq t1 t2 Cifratura_Occorrenze
            li t2 68
            beq t1 t2 Dizionario
            li t2 69
            beq t1 t2 Inversione
            j loop
        adjust_values:
            sub s2 zero s2
            li s5 1
        rev_loop:
            lb t1 0(s6)
            blt s6 s1 exit
            addi s6 s6 -1
            li t2 65
            beq t1 t2 Cifrario_a_Sostituzione
            li t2 66
            beq t1 t2 Decifratura_a_Blocchi
            li t2 67
            beq t1 t2 Decifratura_Occorrenze
            li t2 68
            beq t1 t2 Dizionario
            li t2 69
            beq t1 t2 Inversione
            j rev_loop
        
    exit:
        ecall