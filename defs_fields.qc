/*
==============================================================================

			SOURCE FOR ENTVARS_T C STRUCTURE
			DO NOT ADD ANYTHING TO THIS BLOCK OR BEFORE IT

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

	OTHER NON-ENGINE-REFERENCED STUFF START FROM HERE

==============================================================================
*/


/*
GLOBALS
==============================================================================
*/

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
float 		startskill;

nosave float *world_sounds;  //via Spike fun times! nosave=noclobber

nosave float cleanUpClientStuff;
nosave float gamestarted;


// new door features
#define _MAX_ENTITY_QUEUE 256
entity doorq[_MAX_ENTITY_QUEUE];
float lastdq;
float currentdq;
float door_setup_finished;


// gravity
entity current_gravity_ent;

/*
FIELDS
==============================================================================
*/



//
// world fields
//
.string		wad;
.string 	map;
.float		worldtype;	// 0=medieval 1=metal 2=base

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
.void()		th_sight;
.void()		th_wake;
.float()	th_checkattack;
.float(entity inflictor, entity attacker, float damage, float orig_damage) th_damage;

.void(entity mon)	start_function;

.entity		oldenemy;		// mad at this player before taking damage
.float		speed;
.float 		speed2;
.float		lefty;
.float		search_time;
.float		attack_state;
.float      bloodtype;
.float		show_hostile;	// set to time+0.2 whenever a client fires a
							// weapon or takes damage.  Used to alert
							// monsters that otherwise would let the player go

.float attack_elevation; // ogre
.float inpain;		// zombie

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

.float		dmgtime;

.float		jump_flag;		// player jump flag
.float		swim_flag;		// player swimming sound flag
.float		air_finished;	// when time > air_finished, start drowning
.float		bubble_count;	// keeps track of the number of bubbles
.string		deathtype;		// keeps track of how the player died

.float 		wantedgravity; // thanks Spike!

.float	healamount, healtype;


//.float hit_z;

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
.float		delay;	// time from activation to firing
.entity		trigger_field;	// door's trigger entity
.string		noise4;




//
// monsters
//

.float 		pausetime;
.entity 	movetarget;
.entity		sibling;
.string 	obituary;

.float spawncount; // spawner's maximum monsters alive at the same time allowed
.float totalspawncount; // total spawn count limit

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

.void()		dormant_use;

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


//
// items
//
.float itemstyle = style;
.float	ritem, respawndelay, respawncount; // item respawning
.vector particles_offset; //keylock.qc


// trigger_timer
.float rand = healamount;	


// switchable brushes
.string		origmodel;


//
// hipnotic stuff
//
.entity     lastvictim;
.vector     old_velocity;
.float      spawnsilent;
.float      spawnmulti;
.float      duration;
.float      gorging;
.float      charmed;
.float		endtime;

// rotate
.vector neworigin;
.vector rotate;
.float  endtime;
.float  rotate_type;
.string path;
.string group;
.string event;
.float  duration;


//
//   rubicon2 stuff
//
.float		angle2;		
.vector		movedir2;
.string		message2;
.float		onladder;	
.float		ladder_step_finished;
.float		underwatersound;
.float		burningsound;
.float		gravity;
.float		color;
.float		alpha, alpha2;
.entity		missle;

.float		burning_finished;
.float		burning_time;

.float		dismemberment;	//used by hunter.qc


// frogman
.vector old_angles;


// projectiles
.vector oldvelocity;
.float lifetime_finished;
.string type;



//
// fog
//
.vector		fog_color, fog_color2;
.float		fog_density, fog_density2;
.float 		skyfog_density, skyfog_density2;
.entity 	fogblend_entity;



//
// support for item_key_custom -- iw
//
.string keyname;
.float customkeys;


//
// lights and shadows
//
.float		switchshadstyle;
.float		shadowoff;
.entity 	shadowcontroller;
.string 	targetname2;
.float style2; //c0burn's switchable lights



//
// elevator fields (func_new_plat)
//

.float 		elevatorLastUse;
.float		elevatorOnFloor;
.float		elevatorToFloor;
.vector		elevatorDestination;

//
// plat2 fields (func_new_plat)
//
.float		plat2Called;
.float		plat2LastMove;
.float		plat2GoTime;
.float		plat2GoTo;



//
// for worldspawn
//
.float 		give_weapons;
.float 		take_weapons;
.float 		reset_items;


//
// new door features
//
.float 		maxdelay, mindelay, lastclose, lastopen, movingback;
.vector		cmins, cmaxs;
.float 		groupstate;
.float 		prevgroupstate = burning_time;
.string 	groupname;
.entity 	lastenemy = oldenemy;
.float  	doorlooped = count;
.float 		dqplace = currentammo;
.float 		activated = strength;
//.string 	doortowait = wad;
.float 		speed2;
.float 		delay2;

.entity ld_currentdoor = enemy;
.entity ld_lastfound = oldenemy;
.entity ld_nextdoor = owner;



// entity state
.float estate;


// func_bob
.float attack_timer;
.float bsporigin;			// All bmodel origins are 0,0,0 check this first
.float distance;
.float waitmin2;

// gravity
.float return_gravity;


//JCR super jump defs
.float jboots_got;		
.float jboots_rechargelimit;
.float jboots_sfx;
.float jboots_ammo;
.float jboots_onground;
.float jboots_finished;
.float jboots_time; 