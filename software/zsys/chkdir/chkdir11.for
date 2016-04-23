CHKDIR is based on CLEANDIR 1.8, but contains only diagnostic 
code.  It does no writing, so it poses no danger to your 
directory or to !!!TIME&.DAT files.  It calls error handler on 
error so ZEX or SUB can be aborted.  It checks for duplicate 
entries, extents and users greater than 31, records greater than 
128, illegal filename characters, duplicate allocation groups 
assignments.  Version 1.1 now works on P2D date-stamped disks.
