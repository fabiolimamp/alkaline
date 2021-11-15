string	VERSION_S				= "Alkaline v1.1";
string	BUILD_DATE				= __DATE__;
string	BUILD_TIME				= __TIME__;

float	FALSE					= 0;
float 	TRUE					= 1;

// edict.flags
float	FL_FLY					= 1;
float	FL_SWIM					= 2;
float	FL_CLIENT				= 8;		// set for all client edicts
float	FL_INWATER				= 16;		// for enter / leave water splash
float	FL_MONSTER				= 32;
float	FL_GODMODE				= 64;		// player cheat
float	FL_NOTARGET				= 128;		// player cheat
float	FL_ITEM					= 256;		// extra wide size for bonus items
float	FL_ONGROUND				= 512;		// standing on something
float	FL_PARTIALGROUND		= 1024;		// not all corners are valid
float	FL_WATERJUMP			= 2048;		// player jumping out of water
float	FL_JUMPRELEASED			= 4096;		// for jump debouncing
float 	FL_SPAWNMONSTER			= 8192; 	// triggered spawn monsters
float 	FL_PACIFIST				= 16384;	// monsters that don't fight (usually run away)
float 	FL_PROJECTILE			= 32768;	// projectile entities, like lasers, plasma, rockets, spikes, etc
float 	FL_NOCENTERPRINT		= 65536;	// don't centerprint entity's message field when its targets are used
float 	FL_IGNOREDATTACK		= 131072; 	// monsters won't get angry at this entity when attacked by it

// edict.movetype values
float	MOVETYPE_NONE			= 0;	// never moves
//float	MOVETYPE_ANGLENOCLIP	= 1;
//float	MOVETYPE_ANGLECLIP		= 2;
float	MOVETYPE_WALK			= 3;	// players only
float	MOVETYPE_STEP			= 4;	// discrete, not real time unless fall
float	MOVETYPE_FLY			= 5;
float	MOVETYPE_TOSS			= 6;	// gravity
float	MOVETYPE_PUSH			= 7;	// no clip to world, push and crush
float	MOVETYPE_NOCLIP			= 8;
float	MOVETYPE_FLYMISSILE		= 9;	// fly with extra size against monsters
float	MOVETYPE_BOUNCE			= 10;
float	MOVETYPE_BOUNCEMISSILE	= 11;	// bounce with extra size

// edict.solid values
float	SOLID_NOT				= 0;	// no interaction with other objects
float	SOLID_TRIGGER			= 1;	// touch on edge, but not blocking
float	SOLID_BBOX				= 2;	// touch on edge, block
float	SOLID_SLIDEBOX			= 3;	// touch on edge, but not an onground
float	SOLID_BSP				= 4;	// bsp clip, touch on edge, block

// range values
float	RANGE_MELEE				= 0;
float	RANGE_NEAR				= 1;
float	RANGE_MID				= 2;
float	RANGE_FAR				= 3;

// deadflag values

float	DEAD_NO					= 0;
float	DEAD_DYING				= 1;
float	DEAD_DEAD				= 2;
float	DEAD_RESPAWNABLE		= 3;

// takedamage values

float	DAMAGE_NO				= 0;
float	DAMAGE_YES				= 1;
float	DAMAGE_AIM				= 2;

// weapons

float	WEAPON_SHOTGUN				= 1;
float	WEAPON_SUPER_SHOTGUN		= 2;
float	WEAPON_NAILGUN				= 4;
float	WEAPON_SUPER_NAILGUN		= 8;
float	WEAPON_GRENADE_LAUNCHER		= 16;
float	WEAPON_ROCKET_LAUNCHER		= 32;
float	WEAPON_LIGHTNING			= 64;

float	WEAPON_NO_WEAPON			= 128;
float	WEAPON_CHAINSAW				= 256;
float	WEAPON_PLASMA				= 512;
float	WEAPON_LASER_CANNON			= 1024;
float	WEAPON_AXE					= 4096;

float	WEAPON_PROXIMITY_GUN		= 8192;

float   ALL_WEAPONS 				= WEAPON_AXE + WEAPON_CHAINSAW + WEAPON_SHOTGUN +
										WEAPON_SUPER_SHOTGUN + WEAPON_NAILGUN + WEAPON_SUPER_NAILGUN +
										WEAPON_GRENADE_LAUNCHER + WEAPON_PROXIMITY_GUN + WEAPON_ROCKET_LAUNCHER +
										WEAPON_LIGHTNING + WEAPON_LASER_CANNON + WEAPON_PLASMA;

// only the weapons shown in the vanilla HUD
float 	HUD_WEAPONS					= WEAPON_SHOTGUN + WEAPON_SUPER_SHOTGUN +
										WEAPON_NAILGUN + WEAPON_SUPER_NAILGUN +
										WEAPON_GRENADE_LAUNCHER + WEAPON_ROCKET_LAUNCHER +
										WEAPON_LIGHTNING;
// items
// item flags 1-64 are reserved for the HUD weapons, don't use them

float   IT_JBOOTS				= 128;

float	IT_SHELLS				= 256;
float	IT_NAILS				= 512;
float	IT_ROCKETS				= 1024;
float	IT_CELLS				= 2048;

//								= 4096

float	IT_ARMOR1				= 8192;
float	IT_ARMOR2				= 16384;
float	IT_ARMOR3				= 32768;
float	IT_SUPERHEALTH			= 65536;

float	IT_KEY1					= 131072;
float	IT_KEY2					= 262144;

float	IT_INVISIBILITY			= 524288;
float	IT_INVULNERABILITY		= 1048576;
float	IT_SUIT					= 2097152;
float	IT_QUAD					= 4194304;
float	IT_TRIFECTA				= 8388608;



// point content values

float	CONTENT_EMPTY			= -1;
float	CONTENT_SOLID			= -2;
float	CONTENT_WATER			= -3;
float	CONTENT_SLIME			= -4;
float	CONTENT_LAVA			= -5;
float	CONTENT_SKY				= -6;


float	STATE_TOP		= 0;
float	STATE_BOTTOM	= 1;
float	STATE_UP		= 2;
float	STATE_DOWN		= 3;


// general states
// extends rotate entities states
float STATE_ACTIVE      = 0;
float STATE_INACTIVE    = 1;
float STATE_SPEEDINGUP  = 2;
float STATE_SLOWINGDOWN = 3;

float STATE_CLOSED   = 4;
float STATE_OPEN     = 5;
float STATE_OPENING  = 6;
float STATE_CLOSING  = 7;

float STATE_INVISIBLE = 8;


float STATE_WAIT = 0;
float STATE_MOVE = 1;
float STATE_STOP = 2;
float STATE_FIND = 3;
float STATE_NEXT = 4;
// end rotate states

float STATE_ON = 1;
float STATE_OFF = 2;

vector	VEC_ORIGIN = '0 0 0';
vector	VEC_HULL_MIN = '-16 -16 -24';
vector	VEC_HULL_MAX = '16 16 32';

vector	VEC_HULL2_MIN = '-32 -32 -24';
vector	VEC_HULL2_MAX = '32 32 64';

vector	VEC_ONE			= '1 1 1';
vector	VEC_UP			= '0 0 1';
vector	VEC_DOWN 		= '0 0 -1';

// protocol bytes
// god bless sock for this updated list --bmFbr
float	SVC_DISCONNECT		= 2;	// Mainly used in client.qc
float	SVC_UPDATESTAT		= 3;	// [byte] [long] - Force update of stats
float	SVC_VERSION			= 4;	// [long] - Server version
float	SVC_SETVIEW			= 5;	// [short] [entity] Set camera viewpoint 
float	SVC_SOUND			= 6;	// 
float	SVC_TIME			= 7;	// [long] server time
float	SVC_PRINT			= 8;	// [string] null terminated string
float	SVC_STUFFTXT		= 9;	// [string] stuffed into client's console buffer 
float	SVC_SETANGLE		= 10;	// [vector] set view angle
float	STAT_TOTALSECRETS 	= 11;	// [byte] [long] total secrets message
float	STAT_TOTALMONSTERS 	= 12;
float	SVC_UPDATENAME		= 13;
float	SVC_TEMPENTITY		= 23;
float	SVC_SETPAUSE		= 24;
float	SVC_CENTERPRINT		= 26;
float	SVC_KILLEDMONSTER	= 27;
float	SVC_FOUNDSECRET		= 28;
float	SVC_SPAWNSTATICSOUND= 29;
float	SVC_INTERMISSION	= 30;
float	SVC_FINALE			= 31;
float	SVC_CDTRACK			= 32;
float	SVC_SELLSCREEN		= 33;
float	SVC_CUTSCENE		= 34;



float	TE_SPIKE		= 0;
float	TE_SUPERSPIKE	= 1;
float	TE_GUNSHOT		= 2;
float	TE_EXPLOSION	= 3;
float	TE_TAREXPLOSION	= 4;
float	TE_LIGHTNING1	= 5;
float	TE_LIGHTNING2	= 6;
float	TE_WIZSPIKE		= 7;
float	TE_KNIGHTSPIKE	= 8;
float	TE_LIGHTNING3	= 9;
float	TE_LAVASPLASH	= 10;
float	TE_TELEPORT		= 11;

// sound channels
// channel 0 never willingly overrides
// other channels (1-7) allways override a playing sound on that channel
float	CHAN_AUTO		= 0;
float	CHAN_WEAPON		= 1;
float	CHAN_VOICE		= 2;
float	CHAN_ITEM		= 3;
float	CHAN_BODY		= 4;

float	ATTN_NONE		= 0;
float	ATTN_NORM		= 1;
float	ATTN_IDLE		= 2;
float	ATTN_STATIC		= 3;

// update types

float	UPDATE_GENERAL	= 0;
float	UPDATE_STATIC	= 1;
float	UPDATE_BINARY	= 2;
float	UPDATE_TEMP		= 3;

// entity effects

float	EF_BRIGHTFIELD	= 1; // spherical field of yellow particles
float	EF_MUZZLEFLASH 	= 2; // muzzleflash, turns off automatically.
float	EF_BRIGHTLIGHT 	= 4; // brighter light?
float	EF_DIMLIGHT 	= 8; // like enforcer lazers


// messages
float	MSG_BROADCAST	= 0;		// unreliable to all
float	MSG_ONE			= 1;		// reliable to one (msg_entity)
float	MSG_ALL			= 2;		// reliable to all
float	MSG_INIT		= 3;		// write to the init string

// skill levels
float   SKILL_EASY      = 0;
float   SKILL_NORMAL    = 1;
float   SKILL_HARD      = 2;
float   SKILL_NIGHTMARE = 3;

// worldtype values
float	WORLDTYPE_MEDIEVAL		= 3; // was 0
float	WORLDTYPE_METAL			= 1;
float	WORLDTYPE_BASE			= 2;


// "blood" types
float   SPAWN_BLOOD			= 1;
float   SPAWN_CHUNK			= 2;
float   SPAWN_DIRT			= 3;
float   SPAWN_YELLOWSPARK	= 4;
float   SPAWN_WHITESPARK	= 5;

float START_OFF = 1;

// item style
float ITEMSTYLE_BSP = 1;
float ITEMSTYLE_MDL = 2;

// monsters
float MONSTER_ORIGINAL = 8;
float MONSTER_NOSIGHTSOUND = 16;
float MONSTER_SPAWNANGRY = 32;
float MONSTER_SPAWNTRIGGERED = 64;
float MONSTER_SPAWNSILENT = 128;
float MONSTER_NOINFIGHT = 16384;
float MONSTER_COUNTONSPAWN = 32768;
float MONSTER_NOIDLESOUND = 65536;
float MONSTER_IGNOREPLAYER	= 131072;
float MONSTER_SPAWNER = 262144;
float MONSTER_ZEROBBOX = 524288;
float MONSTER_HEALTHTRIGGER = 1048576;

float MONAI_ABOVEMELEE = 120;		// Always be high above enemies inside this distance
float MONAI_ABOVEDIST = 128;		// Distance to maintain above enemytarget
float MONAI_ABOVETIMER = 2;			// Amount of time before changing Z


float TRIGGER_CENTERPRINTALL = 1048576;


//
// monster ai
//

float	AS_STRAIGHT		= 1;
float	AS_SLIDING		= 2;
float	AS_MELEE		= 3;
float	AS_MISSILE		= 4;
float 	AS_DODGING     = 5; // hipnotic's centroid



float FLOYD_ROLLING = 2;
float FLOYD_ASLEEP = 4;
float SPARKS_BLUE = 2;
float SPARKS_PALE = 4;
float BREAKABLE_NO_MONSTERS = 1;


//
// mapvar
//

float MAPV_BITS = 22;			// Bits used in each parm block
float MAPV_BLCK = 2;			// Blocks used (total parm's)
float MAPV_TOTAL = 44;			// Maximum amount of variables

float MAPV_WRITE_OFF = 1;
float MAPV_WRITE_ON = 2;
float MAPV_WRITE_TOGGLE = 3;

float MAPV_READ_OFF = 1;
float MAPV_READ_ON = 2;


// Footstep types (slow, drag, light, medium, heavy, large, giant)
// todo: add sounds to monsters, find proper sound files
float FS_TYPESLOW = 1;		// Demon, Dogs, Ogres, Zombies
float FS_TYPEDRAG = 2;		// Alt Zombie foot
float FS_TYPELIGHT = 3;
float FS_TYPEMEDIUM = 4;
float FS_TYPEHEAVY = 5;		// Death/Hell Knight, Drole, Player, Enforcer
float FS_TYPELARGE = 6;		// Minotaur, Shambler
float FS_TYPEGIANT = 7;		// Golem
float FS_TYPECUSTOM = 9;	// Defined/precached by monster
float FS_FLYING = 10;		// Exclusion, no happy feet!


//
// CSQC
//

const float EV_VOID = 0;
const float EV_STRING = 1;
const float EV_FLOAT = 2;
const float EV_VECTOR = 3;
const float EV_ENTITY = 4;
const float EV_FIELD = 5;
const float EV_FUNCTION = 6;
const float EV_POINTER = 7;
const float EV_INTEGER = 8;

float STAT_LEVELNAME = 32;
float STAT_WEAPONS = 33;
float STAT_BOOTS = 34;
float STAT_BOOTS_FINISHED = 35;
float STAT_IT = 36;