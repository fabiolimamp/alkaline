
/*
==============================================================================

			SOURCE FOR GLOBALVARS_T C STRUCTURE

==============================================================================
*/

//
// system globals
//
entity		self;
entity		other;
entity		world;
float		time;
float		frametime;

float		force_retouch;		// force all entities to touch triggers
								// next frame.  this is needed because
								// non-moving things don't normally scan
								// for triggers, and when a trigger is
								// created (like a teleport trigger), it
								// needs to catch everything.
								// decremented each frame, so set to 2
								// to guarantee everything is touched
string		mapname;

float		deathmatch;
float		coop;
float		teamplay;

float		serverflags;		// propagated from level to level, used to
								// keep track of completed episodes

float		total_secrets;
float		total_monsters;

float		found_secrets;		// number of secrets found
float		killed_monsters;	// number of monsters killed


// spawnparms are used to encode information about clients across server
// level changes
float		parm1, parm2, parm3, parm4, parm5, parm6, parm7, parm8, parm9, parm10, parm11, parm12, parm13, parm14, parm15, parm16;

//
// global variables set by built in functions
//	
vector		v_forward, v_up, v_right;	// set by makevectors()
	
// set by traceline / tracebox
float		trace_allsolid;
float		trace_startsolid;
float		trace_fraction;
vector		trace_endpos;
vector		trace_plane_normal;
float		trace_plane_dist;
entity		trace_ent;
float		trace_inopen;
float		trace_inwater;

entity		msg_entity;				// destination of single entity writes

//
// required prog functions
//
void() 		main;						// only for testing

void()		StartFrame;

void() 		PlayerPreThink;
void() 		PlayerPostThink;

void()		ClientKill;
void()		ClientConnect;
void() 		PutClientInServer;		// call after setting the parm1... parms
void()		ClientDisconnect;

void()		SetNewParms;			// called when a client first connects to
									// a server. sets parms so they can be
									// saved off for restarts

void()		SetChangeParms;			// call to set parms for self so they can
									// be saved for a level transition


//================================================
void		end_sys_globals;		// flag for structure dumping
//================================================

/*
==============================================================================

			SOURCE FOR ENTVARS_T C STRUCTURE

==============================================================================
*/

//
// system fields (*** = do not set in prog code, maintained by C code)
//
.float		modelindex;		// *** model index in the precached list
.vector		absmin, absmax;	// *** origin + mins / maxs

.float		ltime;			// local time for entity
.float		movetype;
.float		solid;

.vector		origin;			// ***
.vector		oldorigin;		// ***
.vector		velocity;
.vector		angles;
.vector		avelocity;

.vector		punchangle;		// temp angle adjust from damage or recoil

.string		classname;		// spawn function
.string		model;
.float		frame;
.float		skin;
.float		effects;

.vector		mins, maxs;		// bounding box extents reletive to origin
.vector		size;			// maxs - mins

.void()		touch;
.void()		use;
.void()		think;
.void()		blocked;		// for doors or plats, called when can't push other

.float		nextthink;
.entity		groundentity;

// stats
.float		health;
.float		frags;
.float		weapon;			// one of the WEAPON_SHOTGUN, etc flags
.string		weaponmodel;
.float		weaponframe;
.float		currentammo;
.float		ammo_shells, ammo_nails, ammo_rockets, ammo_cells;

.float		items;			// bit flags

.float		takedamage;
.entity		chain;
.float		deadflag;

.vector		view_ofs;			// add to origin to get eye point


.float		button0;		// fire
.float		button1;		// use
.float		button2;		// jump

.float		impulse;		// weapon changes

.float		fixangle;
.vector		v_angle;		// view / targeting angle for players
.float		idealpitch;		// calculated pitch angle for lookup up slopes


.string		netname;

.entity 	enemy;

.float		flags;

.float		colormap;
.float		team;

.float		max_health;		// players maximum health is stored here

.float		teleport_time;	// don't back up

.float		armortype;		// save this fraction of incoming damage
.float		armorvalue;

.float		waterlevel;		// 0 = not in, 1 = feet, 2 = waist, 3 = eyes
.float		watertype;		// a contents value

.float		ideal_yaw;
.float		yaw_speed;

.entity		aiment;

.entity 	goalentity;		// a movetarget or an enemy

.float		spawnflags;

.string		target;
.string		targetname;

// damage is accumulated through a frame. and sent as one single
// message, so the super shotgun doesn't generate huge messages
.float		dmg_take;
.float		dmg_save;
.entity		dmg_inflictor;

.entity		owner;		// who launched a missile
.vector		movedir;	// mostly for doors, but also used for waterjump

.string		message;		// trigger messages

.float		sounds;		// either a cd track number or sound number

.string		noise, noise1, noise2, noise3;	// contains names of wavs to play

//================================================
void		end_sys_fields;			// flag for structure dumping
//================================================

/*
==============================================================================

				VARS NOT REFERENCED BY C CODE

==============================================================================
*/


//
// constants
//

float	FALSE					= 0;
float 	TRUE					= 1;

// edict.flags
float	FL_FLY					= 1;
float	FL_SWIM					= 2;
float	FL_CLIENT				= 8;	// set for all client edicts
float	FL_INWATER				= 16;	// for enter / leave water splash
float	FL_MONSTER				= 32;
float	FL_GODMODE				= 64;	// player cheat
float	FL_NOTARGET				= 128;	// player cheat
float	FL_ITEM					= 256;	// extra wide size for bonus items
float	FL_ONGROUND				= 512;	// standing on something
float	FL_PARTIALGROUND		= 1024;	// not all corners are valid
float	FL_WATERJUMP			= 2048;	// player jumping out of water
float	FL_JUMPRELEASED			= 4096;	// for jump debouncing
float 	FL_SPAWNMONSTER			= 8192; // triggered spawn monsters
float 	FL_PACIFIST				= 16384;// monsters that don't fight (usually run away)

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

float   ALL_WEAPONS 				= WEAPON_AXE + WEAPON_CHAINSAW + WEAPON_SHOTGUN +
										WEAPON_SUPER_SHOTGUN + WEAPON_NAILGUN + WEAPON_SUPER_NAILGUN +
										WEAPON_GRENADE_LAUNCHER + WEAPON_ROCKET_LAUNCHER +
										WEAPON_LIGHTNING + WEAPON_LASER_CANNON + WEAPON_PLASMA;

// only the weapons shown in the vanilla HUD
float 	HUD_WEAPONS					= WEAPON_SHOTGUN + WEAPON_SUPER_SHOTGUN +
										WEAPON_NAILGUN + WEAPON_SUPER_NAILGUN +
										WEAPON_GRENADE_LAUNCHER + WEAPON_ROCKET_LAUNCHER +
										WEAPON_LIGHTNING;
// items
// item flags below 128 are reserved for the HUD weapons, don't use them

float	IT_SHELLS				= 256;
float	IT_NAILS				= 512;
float	IT_ROCKETS				= 1024;
float	IT_CELLS				= 2048;

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
float	WORLDTYPE_MEDIEVAL		= 0;
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
float MONSTER_SPAWNANGRY = 32;
float MONSTER_SPAWNTRIGGERED = 64;
float MONSTER_SPAWNSILENT = 128;
float MONSTER_NOINFIGHT = 16384;
float MONSTER_COUNTONSPAWN = 32768;
float MONSTER_NOIDLESOUND = 65536;
float MONSTER_IGNOREPLAYER	=	131072;
float MONSTER_SPAWNER = 262144;

//================================================



//
// globals
//
float	movedist;
float	gameover;		// set when a rule exits

string	string_null;	// null string, nothing should be held here
// float	empty_float;

nosave float	clients;

entity 	client_ent;
entity	newmis;			// launch_spike sets this after spawning it

entity	activator;		// the entity that activated a trigger or brush

entity	damage_attacker;	// set by T_Damage
float	framecount;

float		skill;

nosave float cleanUpClientStuff;
nosave float gamestarted;

//================================================

//
// world fields (FIXME: make globals)
//
.string		wad;
.string 	map;
.float		worldtype;	// 0=medieval 1=metal 2=base

//================================================

.string		killtarget;

//
// quakeed fields
//
.float		light_lev;		// not used by game, but parsed by light util
.float		style;


.float		weapons;		// extra weapons
.string 	impulsetarget;
//
// monster ai
//
.void()		th_stand;
.void()		th_walk;
.void()		th_run;
.void()		th_missile;
.void()		th_melee;
.void(entity attacker, float damage)		th_pain;
.void()		th_die;

.void(entity mon)	start_function;

.entity		oldenemy;		// mad at this player before taking damage

.float		speed;
.float 		speed2;

.float	lefty;

.float	search_time;
.float	attack_state;

float	AS_STRAIGHT		= 1;
float	AS_SLIDING		= 2;
float	AS_MELEE		= 3;
float	AS_MISSILE		= 4;

.float      bloodtype;

//
// player only fields
//
.float		walkframe;

.float 		attack_finished;
.float		pain_finished;

.float		invincible_finished;
.float		invisible_finished;
.float		super_damage_finished;
.float		trif_finished;
.float		radsuit_finished;

.float		invincible_time, invincible_sound;
.float		invisible_time, invisible_sound;
.float		super_time, super_sound;
.float		trif_time;
.float		rad_time;
.float		fly_sound;
.float 		cshift_set, cshift_cleared;

.float		axhitme;

.float		show_hostile;	// set to time+0.2 whenever a client fires a
							// weapon or takes damage.  Used to alert
							// monsters that otherwise would let the player go
.float		jump_flag;		// player jump flag
.float		swim_flag;		// player swimming sound flag
.float		air_finished;	// when time > air_finished, start drowning
.float		bubble_count;	// keeps track of the number of bubbles
.string		deathtype;		// keeps track of how the player died

.float 		wantedgravity; // thanks Spike!

.float	healamount, healtype;

//
// object stuff
//
.string		mdl;
.vector		mangle;			// angle at start

.vector		oldorigin;		// only used by secret door

.float		length, width, height;
.float		t_length, t_width;
.float		strength;

//
// doors, etc
//
.vector		dest, dest1, dest2;
.float		wait;			// time from firing to restarting
.float		delay, delay2;			// time from activation to firing
.entity		trigger_field;	// door's trigger entity
.string		noise4;

//
// monsters
//
.float 		pausetime;
.entity 	movetarget;
.entity		sibling;

//
// doors
//
.float		aflag;
.float		dmg;			// damage done by door when hit
	
//
// misc
//
.float		cnt; 			// misc flag
.vector 	centeroffset;	// misc_model
.vector 	mdlsz;			// misc_model
.float 		first_frame, last_frame; // misc_model

//
// subs
//
.void()		think1;
.vector		finaldest, finalangle;
.string 	target2, target3, target4, targetname2;

//
// triggers
//
.float		count;			// for counting triggers
.float 		is_waiting;		// delayed spawn triggerz

.string	include = wad;		// for monsterjump filters
.string exclude = map;

//
// plats / doors / buttons
//
.float		lip;
.float		state;
.vector		pos1, pos2;		// top and bottom positions
.float		height;

//
// sounds
//
.float		waitmin, waitmax;
.float		distance;
.float		volume;


// OVERLOADS:

.float rand = healamount;	// for trigger_timer


.string		origmodel; // addition by bmFbr for switchable brushes

//
// switchable shadow
// 
.float		switchshadstyle;
.float		shadowoff;
.entity shadowcontroller;
.float speed2;
.string targetname2;
//===========================================================================
	

//
// builtin functions
//

void(vector ang)	makevectors		= #1;		// sets v_forward, etc globals
void(entity e, vector o) setorigin	= #2;
void(entity e, string m) setmodel	= #3;		// set movetype and solid first
void(entity e, vector min, vector max) setsize = #4;
void() runerror                     = #5; //johnfitz -- use this to generate a stack dump
void() break						= #6;
float() random						= #7;		// returns 0 - 1
void(entity e, float chan, string samp, float vol, float atten) sound = #8;
vector(vector v) normalize			= #9;
void(string e) error				= #10;
void(string e) objerror				= #11;
float(vector v) vlen				= #12;
float(vector v) vectoyaw			= #13;
entity() spawn						= #14;
void(entity e) remove				= #15;

// sets trace_* globals
// nomonsters can be:
// An entity will also be ignored for testing if forent == test,
// forent->owner == test, or test->owner == forent
// a forent of world is ignored
void(vector v1, vector v2, float nomonsters, entity forent) traceline = #16;	

entity() checkclient				= #17;	// returns a client to look for
entity(entity start, .string fld, string match) find = #18;
string(string s) precache_sound		= #19;
string(string s) precache_model		= #20;
void(entity client, string s)stuffcmd = #21;
entity(vector org, float rad) findradius = #22;
void(string s) bprint				= #23;
void(entity client, string s) sprint = #24;
void(string s) dprint				= #25;
string(float f) ftos				= #26;
string(vector v) vtos				= #27;
void() coredump						= #28;		// prints all edicts
void() traceon						= #29;		// turns statment trace on
void() traceoff						= #30;
void(entity e) eprint				= #31;		// prints an entire edict
float(float yaw, float dist) walkmove	= #32;	// returns TRUE or FALSE
// #33 was removed
float() droptofloor= #34;	// TRUE if landed on floor
void(float style, string value) lightstyle = #35;
float(float v) rint					= #36;		// round to nearest int
float(float v) floor				= #37;		// largest integer <= v
float(float v) ceil					= #38;		// smallest integer >= v
// #39 was removed
float(entity e) checkbottom			= #40;		// true if self is on ground
float(vector v) pointcontents		= #41;		// returns a CONTENT_*
// #42 was removed
float(float f) fabs = #43;
vector(entity e, float speed) aim = #44;		// returns the shooting vector
float(string s) cvar = #45;						// return cvar.value
void(string s) localcmd = #46;					// put string into local que
entity(entity e) nextent = #47;					// for looping through all ents
void(vector o, vector d, float color, float count) particle = #48;// start a particle effect
void() ChangeYaw = #49;						// turn towards self.ideal_yaw
											// at self.yaw_speed
// #50 was removed
vector(vector v) vectoangles			= #51;

//
// direct client message generation
//
void(float to, float f) WriteByte		= #52;
void(float to, float f) WriteChar		= #53;
void(float to, float f) WriteShort		= #54;
void(float to, float f) WriteLong		= #55;
void(float to, float f) WriteCoord		= #56;
void(float to, float f) WriteAngle		= #57;
void(float to, string s) WriteString	= #58;
void(float to, entity s) WriteEntity	= #59;

//
// broadcast client message generation
//

// void(float f) bWriteByte		= #59;
// void(float f) bWriteChar		= #60;
// void(float f) bWriteShort		= #61;
// void(float f) bWriteLong		= #62;
// void(float f) bWriteCoord		= #63;
// void(float f) bWriteAngle		= #64;
// void(string s) bWriteString	= #65;
// void(entity e) bWriteEntity = #66;

void(float step) movetogoal				= #67;

string(string s) precache_file		= #68;	// no effect except for -copy
void(entity e) makestatic		= #69;
void(string s) changelevel = #70;

//#71 was removed

void(string var, string val) cvar_set = #72;	// sets cvar.value

void(entity client, string s) centerprint = #73;	// sprint, but in middle

// The following function definitions allow the engine's builtin
// centerprint function (builtin #73) to be called with different
// numbers of string arguments.  The string that will be printed is the
// concatenation of the string arguments.
//
// These definitions work because builtin #73 is implemented in such
// a way that it can accept multiple string arguments in this manner,
// even though the original QuakeC code didn't take advantage of this
// fact.  A maximum of seven string arguments can be passed because
// a function is limited to a total of eight arguments (and the first
// argument is the client).  Note that in the original engine, all of
// the strings for a centerprint message are concatenated into a single
// 256-char buffer, therefore excessively long messages should be
// avoided.  -- iw
//

void(entity client, string s1, string s2) centerprint2 = #73;
void(entity client, string s1, string s2, string s3) centerprint3 = #73;
void(entity client, string s1, string s2, string s3, string s4) centerprint4 = #73;
void(entity client, string s1, string s2, string s3, string s4, string s5) centerprint5 = #73;
void(entity client, string s1, string s2, string s3, string s4, string s5, string s6) centerprint6 = #73;
void(entity client, string s1, string s2, string s3, string s4, string s5, string s6, string s7) centerprint7 = #73;

void(vector pos, string samp, float vol, float atten) ambientsound = #74;

string(string s) precache_model2	= #75;		// registered version only
string(string s) precache_sound2	= #76;		// registered version only
string(string s) precache_file2		= #77;		// registered version only

void(entity e) setspawnparms		= #78;		// set parm1... to the
												// values at level start
												// for coop respawn

//============================================================================

//
// subs.qc
//
void(vector tdest, float tspeed, void() func) SUB_CalcMove;
void(entity ent, vector tdest, float tspeed, void() func) SUB_CalcMoveEnt;
void(vector destangle, float tspeed, void() func) SUB_CalcAngleMove;
void()  SUB_CalcMoveDone;
void() SUB_CalcAngleMoveDone;
void() SUB_Null;
void() SUB_UseTargets;
void() SUB_Remove;

//
//	combat.qc
//
void(entity targ, entity inflictor, entity attacker, float damage) T_Damage;


float (entity e, float healamount, float ignore) T_Heal; // health function

float(entity targ, entity inflictor) CanDamage;

void() StartItem;

entity(vector org, float damg, entity parent, float multi) kaboom;
void() BecomeExplosion;


//
//  weapons.qc
//

void(vector org, vector vel, float damage, float bloodtype) ImpactSpawn;
void(vector org, vector vel, float damage) SpawnBlood;
void (entity targ, entity inflictor, entity attacker, float damage) T_Damage;
void () player_run;
void(entity bomb, entity attacker, float rad, entity ignore) T_RadiusDamage;
void() SuperDamageSound;
void() flame_touch;
void() flame_fly;


/*============================================================================
johnfitz new defs
============================================================================*/

float FLOYD_ROLLING = 2;
float FLOYD_ASLEEP = 4;
float SPARKS_BLUE = 2;
float SPARKS_PALE = 4;
float BREAKABLE_NO_MONSTERS = 1;

.float		angle2;		
.vector		movedir2;
.string		message2;
.float		onladder;	
.float		ladder_step_finished;
.float		underwatersound;
.float		burningsound;
.float		gravity;
.float		color;
.float		alpha;
.entity		missle;

.float		burning_finished;
.float		burning_time;

void(entity e, float dur) 	StartBurning;
void(entity e) 				StopBurning;



/*****************************************************
Malice defs
******************************************************/
float SPAWNFLAG_SUPERSPIKE = 1;
float SPAWNFLAG_LASER = 2;
float SPAWNFLAG_NOMESSAGE = 1;
float SPAWNFLAG_NOTOUCH = 1;
float SVC_SETVIEWPORT = 5;
float SVC_SETVIEWANGLES = 10;
float PROBE_VOLUME = 0.5;
float SERVO_VOLUME = 0.5;
float ATTN_BANSHEE = 0.5;
float MAX_DROPS = 12;
float SERV_VOL = 0.5;
float ATTN_PROBE = 0.5;
.vector old_angles;


void() FuelTankExplode;
void(vector org, vector dir) Fire_bomb;

/*****************************************************
End Malice defs
******************************************************/

.vector oldvelocity;
.float lifetime_finished;
.string type;

void(string gibname, float dm) ThrowGib; //meat.qc
void(string gibname, float dm) ThrowHead; //meat.qc
void(vector org, vector vel) SpawnMeatSpray; //meat.qc
void(vector org, vector vel) SpawnBitSpray;



//
// fog
//
.vector		fog_color, fog_color2;
.float		fog_density, fog_density2;
.float 		skyfog_density, skyfog_density2;

void( entity client, float density, vector color ) fog_save;
void( entity client, entity fogger ) fog_setFromEnt;
void( entity client, float density, vector color ) fog_set;
void( entity client, float density) skyfog_set;


float() CheckValidTouch;



//
// support for item_key_custom -- iw
//
.string keyname;
.float customkeys;

.float style2; //c0burn's switchable lights

.float itemstyle = style;

string(float num) lightstyle_fade_lookup; //addition by bmFbr for switchable shadows
void(float speed) misc_shadowcontroller_setsteps;
void() misc_shadowcontroller;
void() misc_shadowcontroller_use;
void() shadow_fade_in;
void() shadow_fade_out;

void() setup_lightstyles; //lights.qc

//
// elevator fields
//

.float 		elevatorLastUse;
.float		elevatorOnFloor;
.float		elevatorToFloor;
.vector		elevatorDestination;

//
// plat2 fields
//
.float		plat2Called;
.float		plat2LastMove;
.float		plat2GoTime;
.float		plat2GoTo;

.string		targetname2;

//
// for worldspawn
//
.float 		give_weapons;
.float 		take_weapons;
.float 		reset_items;

//
// new door features
//
#define _MAX_ENTITY_QUEUE 256

entity doorq[_MAX_ENTITY_QUEUE];
float lastdq;
float currentdq;
float door_setup_finished;

.float 		maxdelay, mindelay, lastclose, lastopen, movingback;
.vector		cmins, cmaxs;
.float 		groupstate;
.float 		prevgroupstate = burning_time;
.string 	groupname;
.entity 	lastenemy = oldenemy;
.float  	doorlooped = count;
.float 		dqplace = currentammo;
.float 		activated = strength;
.string 	doortowait = wad;


.entity ld_currentdoor = enemy;
.entity ld_lastfound = oldenemy;
.entity ld_nextdoor = owner;
void() LinkDoors2;

.float estate; // entity state