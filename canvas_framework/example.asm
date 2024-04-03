.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Exemplu proiect desenare",0
area_width EQU 200
area_height EQU 720
area DD 0
aux DD 0
;aux DD 0 dup(800)

counter DD 0 ; numara evenimentele de tip timer

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

symbol_width EQU 10
symbol_height EQU 20
include digits.inc
include letters.inc

area_width_ori_patru EQU 800
area_height_ori_patru EQU 2880
val EQU 2080

click DB 0

.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
loop_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
loop_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0FFFFFFh
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0
simbol_pixel_next:
	inc esi
	add edi, 4
	loop loop_simbol_coloane
	pop ecx
	loop loop_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y

shift1 macro 
local loop_1, loop_2, loop_3, loop_4

	mov ebx, 0
	mov eax, area
	mov ecx, aux
	
		loop_3:
		
			mov edx, dword ptr [eax+ebx]
			mov dword ptr [ecx + ebx], edx
		
			add ebx, 4
		
		cmp ebx, area_width_ori_patru
		jl loop_3
	
	mov eax, area
	mov ecx, 0
	loop_1:
	
		mov ebx, 0
	
		loop_2:
		
			mov edx, dword ptr [eax + area_width_ori_patru + ebx]
			mov dword ptr [eax + ebx], edx
		
			add ebx, 4
		
		cmp ebx, area_width_ori_patru
		jl loop_2
		
		add eax, area_width_ori_patru
		inc ecx
	
	cmp ecx, area_height
	jl loop_1
	
	mov ebx, 0
	mov eax, area_width_ori_patru
	mov edx, area_height
	mul edx
	
	sub eax, area_width_ori_patru
	sub eax, area_width_ori_patru
	add eax, area
	
	mov ecx, aux
	
		loop_4:
		
			mov edx, dword ptr [ecx + ebx]
			mov dword ptr [eax + ebx], edx
		
			add ebx, 4
		
		cmp ebx, area_width_ori_patru
		jl loop_4
	
	mov eax, 0

endm

shift2 macro 
local loop_1, loop_2, loop_3, loop_4

	mov ebx, 0
	mov eax, area_width_ori_patru
	mov edx, area_height
	mul edx
	
	sub eax, area_width_ori_patru
	sub eax, area_width_ori_patru
	add eax, area
	
	mov ecx, aux
	
		loop_4:
		
			mov edx, dword ptr [eax + ebx]  
			mov dword ptr [ecx + ebx], edx
		
			add ebx, 4
		
		cmp ebx, area_width_ori_patru
		jl loop_4

	
	
	mov eax, area_width_ori_patru
	mov edx, area_height
	mul edx
	sub eax, area_width_ori_patru
	add eax, area
	mov ecx, 0
	loop_1:
	
		mov ebx, 0
	
		loop_2:
		
			mov edx, dword ptr [eax - area_width_ori_patru + ebx] 
			mov dword ptr [eax + ebx], edx
		
			add ebx, 4
		
		cmp ebx, area_width_ori_patru
		jl loop_2
		
		sub eax, area_width_ori_patru
		inc ecx
	
	mov edx, area_height
	sub edx, 1
	cmp ecx, edx
	jl loop_1
	
	mov ebx, 0
	mov eax, area
	mov ecx, aux
	
		loop_3:
		
			mov edx, dword ptr [ecx + ebx]
			mov dword ptr [eax+ebx] , edx
		
			add ebx, 4
		
		cmp ebx, area_width_ori_patru
		jl loop_3
	
	mov eax, 0

endm

draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	
	jmp afisare_litere
	
evt_click:

	cmp click, 3
	jne continua1
	mov click, 0
	jmp afisare_litere
	
	continua1:
	inc click
	
	jmp afisare_litere
	
	
evt_timer:

	mov eax, 0
	
	cmp counter, eax
	jne continue
	
	mov eax, area
	mov ecx, 0
	loop_1:
	
		mov ebx, 0
	
		loop_2:
			
			mov edx, 1
			mov dword ptr [eax + ebx], edx
		
			add ebx, 4
		
		cmp ebx, area_width_ori_patru
		jl loop_2
		
		add eax, area_width_ori_patru
		inc ecx
	
	cmp ecx, area_height
	jl loop_1
	
	make_text_macro 'P', area, 100, 80 ; x,y 
	make_text_macro 'R', area, 100, 110
	make_text_macro 'O', area, 100, 140
	make_text_macro 'I', area, 100, 170
	make_text_macro 'E', area, 100, 200
	make_text_macro 'C', area, 100, 230
	make_text_macro 'T', area, 100, 260
	
	make_text_macro 'L', area, 100, 320
	make_text_macro 'A', area, 100, 350
	
	make_text_macro 'A', area, 100, 410
	make_text_macro 'S', area, 100, 440
	make_text_macro 'A', area, 100, 470
	make_text_macro 'M', area, 100, 500
	make_text_macro 'B', area, 100, 530
	make_text_macro 'L', area, 100, 560
	make_text_macro 'A', area, 100, 590
	make_text_macro 'R', area, 100, 620
	make_text_macro 'E', area, 100, 650
	
	continue:

	inc counter


	cmp click, 0
	jne continua_1
	shift1
	shift1
	shift1
	shift1
	shift1
	shift1
	shift1
	shift1
	shift1
    shift1
	shift1
	shift1
	shift1
	shift1
	shift1
	shift1
	
	jmp afisare_litere

continua_1:
	cmp click, 1
	jne continua_2
	
	jmp afisare_litere
	
continua_2:

	cmp click, 2
	jne continua_3
	shift2
	shift2
	shift2
	shift2
	shift2
	shift2
	shift2
	shift2
	shift2
    shift2
	shift2
	shift2
	shift2
	shift2
	shift2
	shift2

	jmp afisare_litere

continua_3:
	
afisare_litere:



final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:

	;aloc memorie pt vectorul auxiliar
	
	mov eax, area_width
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov aux, eax
	
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax

	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	
	
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start
