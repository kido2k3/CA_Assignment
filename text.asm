    addi	$8, $0, 2
	addi	$16, $0, 1
	addi	$10, $0, 1
	lw	$9, input
	for:	
	beq 	$8, $9, exit
	mul 	$16, $16, $8
	add	$8, $8, $10
	j for
	exit:		
	mul 	$16, $16, $9
	sub	$16, $16, $0
	j main
