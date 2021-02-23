//ijed Additional monster capabilities
.float		spawned;			// If you want to spawn things in game other than tarbabies then you'll need this
.entity		real_owner;	// Was for piercing attacks...

//Prototypes for tar-family (tarbaby.qc)
float	CHILD = 4;
float	PARENT = 8;
float	ANCIENT = 16;

float	LIGHT_ZERO          = 0;    // Lightstyle 0.
float	LIGHTZERO_NORMAL    = 12;   // Use for light "m".
float	LIGHTZERO_MIN       = 4;    // Minimum light when storming.
float	LIGHTZERO_MAX       = 25;   // Maximum light allowed.

float	SEEABLE		=	8;	//ijed for togglewall, stupid name because hipnotic didn't follow the entity convention


.float		wait2;			// ijed Extended functionality from extras r4
.float		dismemberment;	//used by hunter.qc
.float		bloodtype;		//custom blood colours depending on target hit, based on nobleed patch by P0X