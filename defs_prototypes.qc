
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

//
//  player.qc
//
void(float deathbyvoid) PlayerDieGo;


// trigger.qc
void() SUB_CheckWaiting;



//
//   rubicon2 stuff
//
void(entity e, float dur) 	StartBurning;
void(entity e) 				StopBurning;


//
// Malice monsters
//
void() FuelTankExplode;
void(vector org, vector dir) Fire_bomb;


//
// meat.qc
//
void(string gibname, float dm) ThrowGib; 
void(string gibname, float dm) ThrowHead;
void() ThrowHeadVoid;
void(vector org, vector vel) SpawnMeatSpray;
void(vector org, vector vel) SpawnBitSpray;


//
// fog
//
void( entity client, float density, vector color ) fog_save;
void( entity client, entity fogger ) fog_setFromEnt;
void( entity client, float density, vector color ) fog_set;
void( entity client, float density) skyfog_set;



float() CheckValidTouch;


//
// lights and shadows
//
string(float num) lightstyle_fade_lookup;
void(float speed) misc_shadowcontroller_setsteps;
void() misc_shadowcontroller;
void() misc_shadowcontroller_use;
void() shadow_fade_in;
void() shadow_fade_out;
void() setup_lightstyles; //lights.qc

// new door features
void() LinkDoors2;