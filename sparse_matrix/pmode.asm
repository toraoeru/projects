.686
.model flat

.code
pr_tree proc public

	extern pr_node: proc
    
	push ebp
	mov ebp, esp
	push edx
	push ebx
	push ecx
    
	mov ebx, [ebp + 8]
	cmp ebx, 0
	je endend
    
	push ebx;
	call pr_node


	mov eax, [ebp + 12]
	add eax, 1
	push eax; сохранить для рекурсии
	sub ecx, ecx
	
	mov edx, [ebx + 14]
	cmp edx, 0
	je left_nil

	push eax
	push edx
	call pr_tree
	mov ecx, eax

left_nil:
	pop eax
	mov edx, [ebx + 18]
	sub ebx, ebx
	cmp edx, 0
	je right_nil

	push eax
	push edx
	call pr_tree
	mov ebx, eax

right_nil:
	cmp ebx, ecx
	ja RA
	mov eax, ecx
	jmp endend
RA:
	mov eax, ebx


endend:
	add eax, 1
	pop ecx
	pop ebx
	pop edx
	pop ebp
	ret 8
pr_tree endp

end