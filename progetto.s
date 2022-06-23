.data


    mycypher: .string "ABCDEEDCBA"
    sostK: .word 5 
    blocKey: .string "MY7*!hm3rwFW%"
    myplaintext: .string "jDs5b8h9e&j7HYwgH$UxWSac&VMZji@CUbrREYLXK*bzw^Y8%nCw25KEy2U*h4RPHvnkYCz3oNoKkXfyFwsZ8%ovqEdPmad"
    
.text
    la s0 myplaintext
    la s1 mycypher
    lw s2 sostK
    la s3 blocKey
    la s4 300009000 # indirizzo stringa ausiliaria molto lontano
    j MY_CYPHER_READ
    
    Cifrario_Cesare:
        add t0 s0 zero # testa stringa  
        a_loop: 
            lb t1 0(t0) # carattere della stringa corrente
            beq t1 zero to_string
            add a2 t1 zero # manda il carattere corrente al check dell'intervallo
            jal check_intervallo
            li t4 26 # numero lettere
            add t1 t1 s2 # somma sostK al valore corrente
            li t2 0
            beq a3 t2 lowercase
            li t2 1
            beq a3 t2 uppercase
            # se carattere speciale
            addi t0 t0 1
            j a_loop
            lowercase:
                li t5 97 # a
                blt t1 t5 underflow
                li t5 122 # z
                bgt t1 t5 overflow
                sb t1 0(t0)
                addi t0 t0 1
                j a_loop
            uppercase:
                li t5 65 # A
                blt t1 t5 underflow
                li t5 90 # Z
                bgt t1 t5 overflow
                sb t1 0(t0)
                addi t0 t0 1
                j a_loop
             underflow:
                    add t1 t1 t4
                    sb t1 0(t0)
                    addi t0 t0 1
                    j a_loop
             overflow:
                    sub t1 t1 t4
                    sb t1 0(t0)
                    addi t0 t0 1
                    j a_loop
    
    Cifrario_a_Blocchi:
        add t0 s0 zero # copia testa stringa in t0
        add t1 s3 zero # copia testa stringa key in t1
        b_loop:
            lb t2 0(t0) # carattere corrente
            beq t2 zero to_string
            lb t3 0(t1)
            beq t3 zero reset_key_head
            add t2 t2 t3 # somma chiave a carattere corrente
            li t4 96
            rem t2 t2 t4 # mod(96)
            addi t2 t2 32
            sb t2 0(t0)
            addi t0 t0 1
            addi t1 t1 1
            j b_loop
        reset_key_head:
            add t1 s3 zero # resetta testa chiave quando finisce di scorrere la stringa di codifica
            j b_loop
            
    Cifrario_Occorrenze:
        add t0 s0 zero # copia testa string input
        add t4 s4 zero # copia testa string aux
        c_loop:
            lb a1 0(t0) # val da inserire nella nuova stringa
            beq a1 zero scambia_testa # printa quando scorre tutta la str con il primo counter
            li t1 27 # val fittizio
            beq a1 t1 skip
            sb a1 0(t4) # salva il carattere nella stringa aux
            add a0 t0 zero # puntatore alle occorrenze
            jal inserimento_auxstr
            c_inner_loop:
                addi a0 a0 1
                lb t5 0(a0) # val da confrontare con a1
                beq t5 zero c_loop_forward
                bne a1 t5 next_char
                li t1 27 # val fittizio
                sb t1 0(a0)
                jal inserimento_auxstr
                j c_inner_loop
            next_char:
                j c_inner_loop
        c_loop_forward:
            addi t4 t4 1
            li t1 32 # space
            sb t1 0(t4)
            addi t4 t4 1
        skip: # skippa
            addi t0 t0 1
            j c_loop 
        scambia_testa:
            addi t4 t4 -1
            sb zero 0(t4) # scrive il fine stringa
            add t1 s0 zero
            add s0 s4 zero
            add s4 t1 zero
            j to_string
        
    Dizionario:
        add t0 s0 zero # testa str
        d_loop:
            lb a2 0(t0) # carattere da cifrare
            beq a2 zero to_string
            li t1 32 # lowerbound
            blt a2 t1 exit
            li t1 127 # upperbound
            bgt a2 t1 exit
            jal check_intervallo # ritorna a3
            beq a3 zero cifratura_min
            li t1 1
            beq a3 t1 cifratura_mai
            li t1 48 # 0
            blt a2 t1 advance_d_loop
            li t1 58 # 9
            blt a2 t1 cifratura_num
            advance_d_loop: 
                addi t0 t0 1
                j d_loop
            cifratura_min:
                addi t1 a2 -97 # sottrae al char da cifrare 96
                li t2 122 # z
                sub a2 t2 t1 # a2 viene invertito nelle minuscole
                addi a2 a2 -32 # converte a2 in maiuscola
                sb a2 0(t0)
                addi t0 t0 1
                j d_loop
            cifratura_mai:
                addi t1 a2 -65
                li t2 90 # Z
                sub a2 t2 t1
                addi a2 a2 32
                sb a2 0(t0)
                addi t0 t0 1
                j d_loop
            cifratura_num:
                li t1 57 # 9
                sub a2 t1 a2
                addi a2 a2 48
                sb a2 0(t0)
                addi t0 t0 1
                j d_loop
                        
    Inversione:
        add t0 s0 zero # testa str
        fill_stack:
            lb t1 0(t0)
            beq t1 zero reset_head
            addi sp sp -1
            sb t1 0(sp)
            addi t0 t0 1
            j fill_stack
        reset_head:
            add t0 s0 zero
            reverse_copy:
                lb t2 0(t0)
                beq t2 zero to_string
                lb t2 0(sp)
                addi sp sp 1
                sb t2 0(t0)
                addi t0 t0 1
                j reverse_copy
    
    Decifratura_a_Blocchi:
        add t0 s0 zero # copia testa stringa in t0
        add t1 s3 zero # copia testa stringa key in t1
        db_loop:
            lb t2 0(t0) # carattere corrente
            beq t2 zero to_string
            lb t3 0(t1) # char corrente della key
            beq t3 zero dreset_key_head
            sub t2 t2 t3 # sottrazione chiave a carattere corrente
            li t4 48
            blt t3 t4 skip_mod
            # li t4 96
            # add t2 t2 t4 # mod(96)
            skip_mod:
                addi t2 t2 -32
            li t4 32
            mod:
            bge t2 t4 skip_add
            addi t2 t2 96
            j mod
            skip_add:
                sb t2 0(t0)
                addi t0 t0 1
                addi t1 t1 1
                j db_loop
        dreset_key_head:
            add t1 s3 zero # resetta testa chiave quando finisce di scorrere la stringa 
            j db_loop
            
        Decifratura_Occorrenze:
            li a5 0 # max lenght str
            add t0 s0 zero # testa str
            write_char_loop:
                lb t1 0(t0) # carattere da inserire e decifrare
                addi t0 t0 1
                pos_loop:
                    lb t2 0(t0)
                    beq t2 zero scambia_testa2
                    li t3 45 # -
                    beq t2 t3 advance2
                    li t3 32 # space
                    beq t2 t3 advance
                    li a1 0 # contatore numeri nello stack
                    li a3 0 # risultato conversione da mandare indietro
                    li a2 0
                    j convert_to_integer # converte i numeri dopo i - contenuti in t2 e li ritorna in a3
                    write:
                        bgt a3 a5 max
                        after_max:
                        addi a3 a3 -1 # corregge offset
                        add a3 s4 a3
                        sb t1 0(a3) # E' VERO HA SEMPRE RAGIONE COCSX
                        j pos_loop
                    advance:
                        addi t0 t0 1
                        j write_char_loop
                    advance2:
                        addi t0 t0 1
                        j pos_loop
                    max:
                        add a5 a3 zero
                        j after_max
                    scambia_testa2:
                        add a5 a5 s4
                        sb zero 0(a5) # scrive il fine stringa
                        add t1 s0 zero
                        add s0 s4 zero
                        add s4 t1 zero
                        j to_string
    
    convert_to_integer:
        lb t2 0(t0)
        li t3 45 # -
        beq t2 t3 intermedio
        li t3 32 # space
        beq t2 t3 intermedio
        beq t2 zero intermedio
        addi sp sp -1
        sb t2 0(sp)
        addi a1 a1 1 # segnala il numero di elementi nello stack
        addi t0 t0 1
        j convert_to_integer
        intermedio:
            add a2 a1 zero
        moltiplicazione:
            sub t3 a1 a2 # e-10
            beq a2 zero write
            addi a2 a2 -1
            lb t2 0(sp)
            addi sp sp 1
            addi t2 t2 -48
            beq t3 zero out
            li t6 0 # contatore per pow
            pow:
                beq t6 t3 out
                li t5 10
                mul t2 t2 t5
                addi t6 t6 1
                j pow
            out:
                add a3 a3 t2 # offset
                j moltiplicazione
    
    inserimento_auxstr:
        li t1 45 # -
        addi t4 t4 1
        sb t1 0(t4) # inserisce "-"
        addi t4 t4 1
        li a2 0 # contatore lungh stackpointer
        sub a3 a0 s0 # pos dell'occorrenza (IL COGLIONE DI COSIMO E' SALVO DIO BOIA STRAMALEDETTO INFAME)
        addi a3 a3 1
        j divisione
        back_insert:
        li t6 0 # counter
        write_loop:
            addi sp sp 1
            lb t5 0(sp)
            addi t1 t5 48  # converte int in ascii
            sb t1 0(t4)
            addi t4 t4 1
            addi t6 t6 1
            blt t6 a2 write_loop
            addi t4 t4 -1
            jr ra
    
    divisione:
        li t1 10
        rem t2 a3 t1 # a3mod10
        sb t2 0(sp) # salva il resto in sp
        addi sp sp -1 # allunga sp
        addi a2 a2 1
        div a3 a3 t1 
        bne a3 zero divisione
        j back_insert
    
    check_intervallo:
        li t2 65
        blt a2 t2 set_special_char
        li t2 90
        bgt a2 t2 check_lowercase
        li a3 1 # intervallo del carattere corrente (maiuscola)
        jr ra
        check_lowercase:
            li t2 97
            blt a2 t2 set_special_char
            li t2 122
            bgt a2 t2 set_special_char
            li a3 0 # intervallo del carattere corrente (minuscola)
            jr ra
        set_special_char:
            li a3 2 # intervallo del carattere corrente (speciale)
            jr ra
    
    to_string:
        add a0 s0 zero
        li a7 4
        ecall
        li a0 10
        li a7 11
        ecall
        beq s5 zero loop
        j rev_loop
    
    MY_CYPHER_READ:
        add a4 s1 zero # testa mycypher in t0
        loop:
            lb t1 0(a4) # carattere da esaminare della stringa mycypher
            beq t1 zero adjust_values
            addi a4 a4 1
            li t2 65 # A
            beq t1 t2 Cifrario_Cesare # se carattere A chiama cif di cesare
            li t2 66 # B
            beq t1 t2 Cifrario_a_Blocchi # se char B chiama cif a blocchi
            li t2 67 # C
            beq t1 t2 Cifrario_Occorrenze # se char C chiama cif occ
            li t2 68 # D
            beq t1 t2 Dizionario
            li t2 69 # E
            beq t1 t2 Inversione
            j loop
        adjust_values:
            sub s2 zero s2 # inverte sostK
            li s5 1
        rev_loop:
            lb t1 0(a4)
            blt a4 s1 exit
            addi a4 a4 -1
            li t2 65 # A
            beq t1 t2 Cifrario_Cesare
            li t2 66 # B
            beq t1 t2 Decifratura_a_Blocchi
            li t2 67 # C
            beq t1 t2 Decifratura_Occorrenze
            li t2 68 # D
            beq t1 t2 Dizionario
            li t2 69 # E
            beq t1 t2 Inversione
            j rev_loop
        
    exit:
        ecall