; Вариант 16
; Массив B из значения которых больше среднего арифметического
; Коновалов Е. А. БПИ 195
;Разработать программу, которая вводит одномерный массив A[N],
;формирует из элементов массива A новый массив B по правилам,
;указанным в таблице, и выводит его. Память под массивы может
;выделяться как статически, так и динамически по выбору разработчика.
;
;Разбить решение задачи на функции следующим образом:
;
;Ввод и вывод массивов оформить как подпрограммы.
;Выполнение задания по варианту оформить как процедуру
;Организовать вывод как исходного, так и сформированного массивов
;
;Указанные процедуры могут использовать данные напрямую
;(имитация процедур без параметров). Имитация работы с
;параметрами также допустима.

format PE console
entry start

include 'win32a.inc'

;--------------------------------------------------------------------------
section '.data' data readable writable

        strVecSize   db 'size of vector? ', 0
        strIncorSize db 'Incorrect size of vector = %d', 10, 0
        strVecElemI  db '[%d]? ', 0
        strScanInt   db '%d', 0
        strNotBigger db 'Not bigger', 0
        strSumValue  db 'Sum = %d', 10, 0
        strAveValue  db 'Ave = %d', 10, 0
        strVecElemOut  db '[%d] = %d', 10, 0

        vec_size     dd 0
        vecout_size  dd 0
        sum          dd 0
        ave          dd 0
        i            dd ?
        tmp          dd ?
        tmp2         dd ?
        tmpStack     dd ?
        vec          rd 100
        vecout       rd 100

;--------------------------------------------------------------------------
section '.code' code readable executable
start:
; 1) vector input
        call VectorInput
; 2) get vector sum
        call VectorSum
; 3) get vector average
        call VectorAve
; 4) out of sum
        push [sum]
        push strSumValue
        call [printf]
; 5) print average
        push [ave]
        push strAveValue
        call [printf]
; 6) vector out
        call getOutVector
        call VectorOut
finish:
        call [getch]

        push 0
        call [ExitProcess]

;--------------------------------------------------------------------------
VectorInput:
        push strVecSize
        call [printf]
        add esp, 4

        push vec_size
        push strScanInt
        call [scanf]
        add esp, 8

        mov eax, [vec_size]
        cmp eax, 0
        jg  getVector
; fail size
        push vec_size
        push strIncorSize
        call [printf]
        push 0
        call [ExitProcess]
; else continue...
getVector:
        xor ecx, ecx            ; ecx = 0
        mov ebx, vec            ; ebx = &vec
getVecLoop:
        mov [tmp], ebx
        cmp ecx, [vec_size]
        jge endInputVector       ; to end of loop

        ; input element
        mov [i], ecx
        push ecx
        push strVecElemI
        call [printf]
        add esp, 8

        push ebx
        push strScanInt
        call [scanf]
        add esp, 8

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp getVecLoop
endInputVector:
        ret
;--------------------------------------------------------------------------
VectorSum:
        xor ecx, ecx            ; ecx = 0
        mov ebx, vec            ; ebx = &vec
sumVecLoop:
        ;mov [tmp], ebx
        cmp ecx, [vec_size]
        je endSumVector      ; to end of loop
        mov eax, [sum]
        add eax, [ebx]
        mov [sum], eax
        ;mov [i], ecx

        ;mov ecx, [i]
        inc ecx
        ;mov ebx, [tmp]
        add ebx, 4
        jmp sumVecLoop
endSumVector:
        ret
;--------------------------------------------------------------------------
VectorAve:
        xor eax, eax
        xor edx, edx
        mov eax, [sum]
        mov ebx, [vec_size]
        div ebx

        mov [ave], eax

        ret
;--------------------------------------------------------------------------
getOutVector:
        xor ecx, ecx            ; ecx = 0
        mov ebx, vec            ; ebx = &vec
        mov eax, vecout         ; eax = &vecout
getOutVecLoop:
        mov [tmp], ebx
        mov [tmp2], eax
        cmp ecx, [vec_size]
        jge endOutVector       ; to end of loop
        mov [i], ecx

        mov esi, [ave]

        cmp esi, [ebx]
        jge  ifNotGreater

        ; move to new array
        mov esi, dword [ebx]
        mov [eax], esi
        add eax, 4

        xor esi, esi
        mov esi, [vecout_size]
        inc esi
        mov [vecout_size], esi

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp getOutVecLoop
ifNotGreater:

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp getOutVecLoop

endOutVector:
        ret

;--------------------------------------------------------------------------
VectorOut:
        mov [tmpStack], esp
        xor ecx, ecx            ; ecx = 0
        mov ebx, vecout            ; ebx = &vecout
putVecLoop:
        mov [tmp], ebx
        cmp ecx, [vecout_size]
        je endOutputVector      ; to end of loop
        mov [i], ecx

        ; output element
        push dword [ebx]
        push ecx
        push strVecElemOut
        call [printf]

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp putVecLoop
endOutputVector:
        mov esp, [tmpStack]
        ret
;-------------------------------third act - including HeapApi--------------------------
                                                 
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'

include 'api\user32.inc'
include 'api\kernel32.inc'
    import kernel,\
           ExitProcess, 'ExitProcess',\
           HeapCreate,'HeapCreate',\
           HeapAlloc,'HeapAlloc'
  include 'api\kernel32.inc'
    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'