	public @dtbl
	extrn mdd0,mdd1,ecdd0,ecdd1

	cseg

@dtbl	dw mdd0,mdd1,ecdd0,ecdd1,0		; temp for banked testing
		dw 0,0,0,0,0,0,0,0,0,0,0			; drives F-P non-existant

	end
