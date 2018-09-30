

/*
 * API exported by SYSBIOS, defined in c_bios.z80
 *
 */

struct HDGEO_proto {
	unsigned int cylinders;
	unsigned char heads;
	unsigned char sectors;
};

typedef	struct HDGEO_proto 	HDGEO;



extern	void cls_();
extern	int getHDgeo_(HDGEO *);
extern	int hdRead_(unsigned char *, unsigned int, unsigned int);
extern	int hdWrite_(unsigned char *, unsigned int, unsigned int);


/* EOF */
