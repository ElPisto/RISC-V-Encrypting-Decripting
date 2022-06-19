.data

    myplaintext: .string "LAUREATO"
    mycypher: .string "CAB"
    sostK: .word -5 
    blocKey: .string "OLE"
    auxstring: .string ""
    
.text
    
    la s0 myplaintext
    la s1 mycypher
    lw s2 sostK
    la s3 blocKey
    la s4 auxstring
    j MY_CYPHER_READ
    
    Cifrario_Cesare:
        add t0 s0 zero # testa stringa  
        a_loop: 
            lb t1 0(t0) # carattere della stringa corrente
            beq t1 zero Print
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
            beq t2 zero Print
            lb t3 0(t1)
            add t2 t2 t3 # somma chiave a carattere corrente
            li t4 96
            rem t2 t2 t4 # mod(96)
            addi t2 t2 32
            sb t2 0(t0)
            addi t0 t0 1
            addi t1 t1 1
            lb t3 0(t1)
            beq t3 zero reset_key_head
            j b_loop
        reset_key_head:
            add t1 s3 zero # resetta testa chiave quando finisce di scorrere la stringa 
            j b_loop
            
    Cifrario_Occorrenze:
        add t0 s0 zero # copia testa string input
        add t4 s4 zero # copia testa string aux
        c_loop:
            lb a1 0(t0) # val da inserire nella nuova stringa
            beq a1 zero aggiorna_testa # printa quando scorre tutta la str con il primo counter
            li t1 27 # val fittizio
            beq a1 t1 tag
            sb a1 0(t4)
            add a0 t0 zero # puntatore alle occorrenze
            jal inserimento_auxstr
        c_inner_loop:
            addi a0 a0 1
            lb t5 0(a0) # val da confrontare con a1
            beq t5 zero c_loop_forward
            bne a1 t5 skip
            li t1 27 # val fittizio
            sb t1 0(a0)
            jal inserimento_auxstr
            j c_inner_loop
            skip:
                j c_inner_loop
        c_loop_forward:
            addi t4 t4 1
            li t1 32 # space
            sb t1 0(t4)
            addi t4 t4 1
            tag: # skippa
            addi t0 t0 1
            j c_loop 
        aggiorna_testa:
            add s0 s4 zero
            j Print
        
    Dizionario:
        
    Inversione:
    
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
        insert_loop:
            addi sp sp 1
            lb t5 0(sp)
            addi t1 t5 48  # converte int in ascii
            sb t1 0(t4)
            addi t4 t4 1
            addi t6 t6 1
            blt t6 a2 insert_loop
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
    
    DECODING_PLAIN:
    
    Print:
        add a0 s0 zero
        li a7 4
        ecall
        li a0 10
        li a7 11
        ecall
        j loop
    
    MY_CYPHER_READ:
        add a4 s1 zero # testa mycypher in t0
        loop:
            lb t1 0(a4) # carattere da esaminare della stringa mycypher
            addi a4 a4 1
            beq t1 zero exit
            li t2 65 # A
            beq t1 t2 Cifrario_Cesare # se carattere A chiama cif di cesare
            li t2 66 # B
            beq t1 t2 Cifrario_a_Blocchi # se char B chiama cif a blocchi
            li t2 67 # C
            beq t1 t2 Cifrario_Occorrenze # se char C chiama cif occ
            j loop
    
    exit:
        ecall