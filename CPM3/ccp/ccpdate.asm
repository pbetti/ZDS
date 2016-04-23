

@BDATE	MACRO
	db	'101198'
	ENDM

@LCOPY	MACRO
	db	'Copyright 1998, '
	db	'Caldera, Inc.   '
	ENDM

@SCOPY	MACRO
	db	'(c) 98 Caldera'
	ENDM

	ORG	368H

	DB	' '
	@BDATE		;[JCE] Copyright & build date now in MAKEDATE.LIB
	DB	' '
	@SCOPY


