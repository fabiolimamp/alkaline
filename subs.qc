

void() SUB_Null = {};
void(entity attacker, float damage) SUB_NullPain = {};

float() SUB_InitEntity = {
	if (self.classname == "trigger_relay") {
		if (self.spawnflags & 16384 && coop){
			remove(self);
			return FALSE;
		}
		if (self.spawnflags & 32768 && !coop){
			remove(self);
			return FALSE;
		}
	}
	else {
		if (self.spawnflags & SPAWNFLAG_NOCOOP && coop){
			remove(self);
			return FALSE;
		}
		if (self.spawnflags & SPAWNFLAG_ONLYCOOP && !coop){
			remove(self);
			return FALSE;
		}
	}
	return TRUE;
}


/*
=============
SUB_Remove/SUB_RemoveSoon

RemoveSoon is to be used during touch functions to avoid touchlinks errors
===============
*/
void() SUB_Remove = { remove(self); }
void() SUB_RemoveSoon = 
{
	// ensure no shenanigans take place in the next hundredth of a second
	// otherwise we get weirdness like items being picked up twice at high framerates
	self.model = string_null;
	self.solid = SOLID_NOT;
	self.touch = SUB_Null;
	self.use = SUB_Null;
	
	self.think = SUB_Remove;
	self.nextthink = time;
}


void() SUB_MakeNotSolid = {
	//self.solid = SOLID_NOT;
};

/*
=============
SUB_CallAsSelf

wrap the self/oself shuffle for code cleanliness elsewhere
===============
*/
void(void() fun, entity newself) SUB_CallAsSelf =
{
	local entity oself;
	
	oself = self;
	self = newself;
	fun();
	self = oself;	
}


/*
================
QuakeEd only writes a single float for angles (bad idea), so up and down are
just constant angles.
================
*/
void() SetMovedir =
{
	if (self.angles == '0 -1 0')
		self.movedir = '0 0 1';
	else if (self.angles == '0 -2 0')
		self.movedir = '0 0 -1';
	else
	{
		makevectors (self.angles);
		self.movedir = v_forward;
	}
	
	self.angles = '0 0 0';
};

void() SetAngles = {
	if (self.angles == '0 -1 0')
		self.angles = '90 0 0';
	else if (self.angles == '0 -2 0')
		self.angles = '-90 0 0';
}

/*
================
InitTrigger
================
*/
void() InitTrigger =
{
// trigger angles are used for one-way touches.  An angle of 0 is assumed
// to mean no restrictions, so use a yaw of 360 instead.
	if (self.angles != '0 0 0')
		SetMovedir ();
	self.solid = SOLID_TRIGGER;
	setmodel (self, self.model);	// set size and link into world
	self.movetype = MOVETYPE_NONE;
	self.modelindex = 0;
	self.model = "";
	self.flags |= FL_NEVERTELEPORT;
};

/*
=============
SUB_CalcMove

calculate self.velocity and self.nextthink to reach dest from
self.origin traveling at speed
===============
*/
void(entity ent, vector tdest, float tspeed, void() func) SUB_CalcMoveEnt =
{
	local entity	stemp;
	stemp = self;
	self = ent;

	SUB_CalcMove (tdest, tspeed, func);
	self = stemp;
};

void(vector tdest, float tspeed, void() func) SUB_CalcMove =
{
	local vector	vdestdelta;
	local float		len, traveltime, localtime;


	if (!tspeed)
		objerror("No speed is defined!");

	localtime = getLocalTime();

	self.think1 = func;
	self.finaldest = tdest;
	self.think = SUB_CalcMoveDone;

	if (tdest == self.origin)
	{
		self.velocity = '0 0 0';
		self.nextthink = localtime + 0.025;
		return;
	}
		
// set destdelta to the vector needed to move
	vdestdelta = tdest - self.origin;
	
// calculate length of vector
	len = vlen (vdestdelta);
	
// divide by speed to get time to reach dest
	traveltime = len / tspeed;

	// changed from the 0.1 default
	if (traveltime < 0.025)
	{
		self.velocity = '0 0 0';
		self.nextthink = localtime + 0.025;
		return;
	}
	
// set nextthink to trigger a think when dest is reached
	self.nextthink = localtime + traveltime;

// scale the destdelta vector by the time spent traveling to get velocity
	self.velocity = vdestdelta * (1/traveltime);	// qcc won't take vec/float	
};



/*
=============
SUB_CalcMoveSmooth

tdest -> destination coordinates
smdist -> smoothing distance
tspeed -> travel speed
stspeed -> starting speed
fnspeed -> final speed
===============
*/

void(vector tdest, float smdist, float tspeed, float stspeed, float fnspeed, void() func) SUB_CalcMoveSmooth =
{
	local vector	vdestdelta;
	local float		len, traveltime, localtime;

	
	//dprint3("tspeed: ", ftos(tspeed), "\n");
	//dprint3("stspeed: ", ftos(stspeed), "\n");
	//dprint3("fnspeed: ", ftos(fnspeed), "\n");
	


	if (!tspeed)
		objerror("No speed is defined!");

	localtime = getLocalTime();

	self.think1 = func;
	self.think = CalcMoveSmooth_Think;
	self.finaldest = tdest;
	self.calcmoveorigin = self.origin;
	
		
	vdestdelta = tdest - self.origin;
	len = vlen(vdestdelta);

	if (len/2 < smdist) {
		self.travelspeed = tspeed*len/2/smdist;
		self.realsmdist = len/2;
	}

	else {
		self.travelspeed = tspeed;
		self.realsmdist = smdist;
	}

	self.startspeed = max(stspeed, self.travelspeed/50);
	self.finalspeed = max(fnspeed, self.travelspeed/50);
	if (tdest == self.origin)
	{
		self.velocity = '0 0 0';
		self.nextthink = localtime + 0.1;
		return;
	}
		
	// set destdelta to the vector needed to move
	
	//accelerating
	//t = ((v - v0)*2d)/(v² - v0²)
	// WRONG!
	if (self.travelspeed != self.startspeed)
		traveltime += ((self.travelspeed - self.startspeed)*2*self.realsmdist)/(self.travelspeed*self.travelspeed - self.startspeed*self.startspeed);
	else
		traveltime += self.realsmdist/self.startspeed;

	// cruising
	traveltime += (len - self.realsmdist*2)/self.travelspeed;

	//stopping
	//t = ((v - v0)*2d)/(v² - v0²)
	if (self.finalspeed != self.travelspeed)
		traveltime += ((self.finalspeed - self.travelspeed)*2*self.realsmdist)/(self.finalspeed*self.finalspeed - self.travelspeed*self.travelspeed);
	else 
		traveltime += self.realsmdist/self.finalspeed;

	// changed from the 0.1 default
	if (traveltime < 0.025)
	{
		self.velocity = '0 0 0';
		self.nextthink = localtime + 0.025;
		return;
	}
	self.idletimer = localtime;
	dprint("Smooth move started\n");

	self.nextthink = localtime + 0.025;

// scale the destdelta vector by the time spent traveling to get velocity
	self.velocity = normalize(vdestdelta) * self.startspeed;
};


void() CalcMoveSmooth_Think = {
	float localtime = getLocalTime();

	float disttofinish = vlen(self.origin - self.finaldest);
	float disttostart = vlen(self.origin - self.calcmoveorigin);

	float perctostart = clamp(disttostart/self.realsmdist, 0, 1);
	float perctofinish = clamp(disttofinish/self.realsmdist, 0, 1);
	float spd;
	vector dir = normalize(self.finaldest - self.origin);

	// accelerating
	if (perctostart < perctofinish) {
		float lg2 = (log2(perctostart) + 7)/7;
		lg2 *= lg2;
		
		if (!self.smoothcurve) spd = lerp(self.startspeed, self.travelspeed, lg2);
		else spd = lerp(self.startspeed, self.travelspeed, perctostart);
	}
	//stopping
	else if (perctostart > perctofinish) {
		spd = lerp(self.travelspeed, self.finalspeed, 1 - perctofinish);
	}
	else {
		spd = self.travelspeed;
	}

	spd = max(spd, self.travelspeed/50);
	vector newvel = spd * dir;

	//dprint3("Speed difference: ", ftos(vlen(newvel) - vlen(self.velocity)), "\n");
	//dprint4("perctostart: ", ftos(perctostart), ", perctofinish: ", ftos(perctofinish));
	//dprint3(", speed: ", ftos(spd), "\n");
	self.velocity = newvel;

	if (vlen((self.origin + self.velocity * 0.025) - self.calcmoveorigin) > vlen(self.finaldest - self.calcmoveorigin)) {
		self.think = SUB_CalcMoveDone;
	}

	self.nextthink = localtime + 0.025;
}

/*
============
After moving, set origin to exact final destination
============
*/
void()  SUB_CalcMoveDone =
{
	setorigin(self, self.finaldest);
	if (self.travelspeed) {
		
		dprint3("Smooth move ended. Move time: ", ftos(getLocalTime() - self.idletimer), "\n");
	}
	self.idletimer = 0;
	self.calcmoveorigin = '0 0 0';
	self.travelspeed = 0;
	self.startspeed = 0;
	self.finalspeed = 0;
	self.realsmdist = 0;

	//dprint3("End time: ", ftos(getLocalTime()), "\n");
	self.velocity = '0 0 0';
	self.nextthink = -1;
	if (self.think1)
		self.think1();
};


/*
=============
SUB_CalcAngleMove

calculate self.avelocity and self.nextthink to reach destangle from
self.angles rotating 

The calling function should make sure self.think is valid
===============
*/
void(entity ent, vector destangle, float tspeed, void() func) SUB_CalcAngleMoveEnt =
{
local entity		stemp;
	stemp = self;
	self = ent;
	SUB_CalcAngleMove (destangle, tspeed, func);
	self = stemp;
};

void(vector destangle, float tspeed, void() func) SUB_CalcAngleMove =
{
local vector	destdelta;
local float		len, traveltime;

	if (!tspeed)
		objerror("No speed is defined!");
		
// set destdelta to the vector needed to move
	destdelta = destangle - self.angles;
	
// calculate length of vector
	len = vlen (destdelta);
	
// divide by speed to get time to reach dest
	traveltime = len / tspeed;

// set nextthink to trigger a think when dest is reached
	self.nextthink = self.ltime + traveltime;

// scale the destdelta vector by the time spent traveling to get velocity
	self.avelocity = destdelta * (1 / traveltime);
	
	self.think1 = func;
	self.finalangle = destangle;
	self.think = SUB_CalcAngleMoveDone;
};

/*
============
After rotating, set angle to exact final angle
============
*/
void() SUB_CalcAngleMoveDone =
{
	self.angles = self.finalangle;
	self.avelocity = '0 0 0';
	self.nextthink = -1;
	if (self.think1)
		self.think1();
};


/*
=============
SUB_CalcAngleMoveController

Same as SUB_CalcAngleMove, but using a separate controller entity
to not lose track of current think functions.

===============
*/

inline void(vector destangle, float tspeed, void() func, entity controller) SUB_CalcAngleMoveController = {
	SUB_CalcAngleMoveController_ent(self, destangle, tspeed, func, controller);
};

void(entity ent, vector destangle, float tspeed, void() func, entity controller) SUB_CalcAngleMoveController_ent =
{
	local vector	destdelta;
	local float		len, traveltime;

	if (!tspeed)
		objerror("No speed is defined!");
		
	// set destdelta to the vector needed to move

	destdelta = normalizeAngles180(destangle - ent.angles);
	/*dprint3("destangle:   ", vtos(destangle), "\n");
	dprint3("self.angles: ", vtos( self.angles), "\n");
	dprint3("destdelta:   ", vtos(destdelta), "\n");
	*/

	// calculate length of vector
	len = vlen (destdelta);
	
	// divide by speed to get time to reach dest
	traveltime = len / tspeed;

	// set nextthink to trigger a think when dest is reached
	controller.nextthink = time + traveltime;

	// scale the destdelta vector by the time spent traveling to get velocity
	ent.avelocity = destdelta * (1 / traveltime);
	
	// Makes sure controller.owner points to self so it can be referenced later in the think function
	controller.owner = ent;  
	controller.think1 = func;
	controller.finalangle = destangle;
	controller.think = SUB_CalcAngleMoveDoneController;
};

/*
============
After rotating, set angle to exact final angle
============
*/
void() SUB_CalcAngleMoveDoneController =
{
	self.owner.angles = self.finalangle;
	self.owner.avelocity = '0 0 0';
	self.nextthink = -1;
	if (self.think1)
		SUB_CallAsSelf(self.think1, self.owner);
};


//=============================================================================

void() DelayThink =
{
	// only fires if the original entity still exists and is active
	if (self.owner && self.owner.estate == STATE_ACTIVE){
		activator = self.enemy;
		SUB_UseTargets ();
	}
	remove(self);
};

/*
==============================
SUB_UseTargets

the global "activator" should be set to the entity that initiated the firing.

If self.delay is set, a DelayedUse entity will be created that will actually
do the SUB_UseTargets after that many seconds have passed.

Centerprints any self.message to the activator.

Removes all entities with a targetname that match self.killtarget,
and removes them, so some events can remove other triggers.

Search for (string)targetname in all entities that
match (string)self.target and call their .use function

==============================
*/
void(string matchstring, .string matchfield) SUB_UseSpecificTarget =
{
	local entity t, stemp, otemp, act;

	act = activator;
	t = find (world, matchfield, matchstring);
	while ( t != world )
	{
		stemp = self;
		otemp = other;
		self = t;
		other = stemp;
		if (self.use && self.use != SUB_Null)
		{
			/*
			// correction for door triggers happening before they're setup
			// maybe not necessary
			if (!door_setup_finished && self.classname == "func_door") {
				dprint("Door didn't finish setup yet, delaying\n");
				entity dl;
				dl = spawn();
				dl.classname = "DelayedUse";
				dl.think = DelayThink;
				dl.nextthink = time + 0.12;
				dl.enemy = act;
				dl.target = matchstring;
				dl.owner = stemp;
			}
			else*/
				self.use();
				if (self.dev_announce && developer) {
					dprint6(self.classname, " with targetname '", matchstring, "'' fired by ", act.classname, "\n");
					eprint(self);
				}
		}
		self = stemp;
		other = otemp;
		activator = act;
		t = find (t, matchfield, matchstring);
	}
};

void(string matchstring, .string matchfield) SUB_KillSpecificTarget = 
{
	entity t;
	t = find (world, matchfield, matchstring);
	while (t)
	{
		if (t.switchshadstyle) lightstyle(t.switchshadstyle, "m"); // kills the entity switchable shadow if it has one

		if (t.animcontroller) remove(t.animcontroller);
		if (t.rotatecontroller) remove(t.rotatecontroller);

		if (t.flags & FL_MONSTER || t.flags & FL_UNSPAWNEDMONSTER) { // increase the kill counter if it's a monster
			if (
				t.health > 0
				&& !(t.flags & FL_UNSPAWNEDMONSTER && t.spawnflags & MONSTER_COUNTONSPAWN) // ignores unspawned count-on-spawn monster
				&& !(t.flags & FL_PACIFIST && !(t.spawnflags & MONSTER_COUNTONSPAWN)) // ignores non-countable pacifist (scientists)
			){
				killed_monsters = killed_monsters + 1;
				WriteByte (MSG_ALL, SVC_KILLEDMONSTER);
			}
		}

		if (t.classname == "monster_oldone") {
			killed_monsters = killed_monsters + 1;
			WriteByte (MSG_ALL, SVC_KILLEDMONSTER);
		}

		if (t.classname == "trigger_secret" && !(t.nextthink > time)) {
			dprint3("Killed untouched trigger_secret at ", vtos((t.mins + t.maxs)/2), ", marking as found\n");
			found_secrets = found_secrets + 1;
			WriteByte (MSG_ALL, SVC_FOUNDSECRET);
		}

		// liquid brush list handling
		if (t.prevliquidbrush) t.prevliquidbrush.nextliquidbrush = t.nextliquidbrush;
		if (t.nextliquidbrush) t.nextliquidbrush.prevliquidbrush = t.prevliquidbrush;

		remove (t);
		t = find (t, matchfield, matchstring);
	}
}

void() SUB_UseTargets =
{
	local entity t;

	if(self.estate != STATE_ACTIVE) return;

//
// check for a delay
//
	if (self.delay)
	{
		// Delay on doors is for opening, not for firing targets
		// Monsters use the key for delaying trigger-spawning
		// trigger_repeat uses delay for the initial firing
		if (self.classname != "func_door" && !(self.flags & FL_MONSTER) && self.classname != "trigger_repeat"){
			// create a temp object to fire at a later time
			t = spawn();
			t.classname = "DelayedUse";
			t.nextthink = time + self.delay;
			t.think = DelayThink;
			t.enemy = activator;
			t.message = self.message;
			t.killtarget = self.killtarget;
			t.target = self.target;
			t.target2 = self.target2;
			t.target3 = self.target3;
			t.target4 = self.target4;
			t.owner = self;
			return;
		}
	}
	
	
//
// print the message
//
	if (self.message != "" && !(self.flags & FL_NOCENTERPRINT)) {
		if (self.spawnflags & TRIGGER_CENTERPRINTALL) {
			t = find(world, classname, "player");
			while (t) {
				centerprint (t, self.message);
				if (!self.noise)
					sound (t, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NORM);
				t = find(t, classname, "player");
			}
		}
		
		else if (activator.classname == "player") {
			centerprint (activator, self.message);
			if (!self.noise)
				sound (activator, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NORM);
		}	
	}

//
// kill the killtagets
//
	if (self.killtarget != "")
	{
		SUB_KillSpecificTarget(self.killtarget, targetname);
		SUB_KillSpecificTarget(self.killtarget, targetname2);
	}

//
// fire targets
//
	if (self.target && self.target != "") SUB_UseSpecificTarget(self.target, targetname);
	if (self.target2 && self.target2 != "") SUB_UseSpecificTarget(self.target2, targetname);
	if (self.target3 && self.target3 != "") SUB_UseSpecificTarget(self.target3, targetname);
	if (self.target4 && self.target4 != "") SUB_UseSpecificTarget(self.target4, targetname);

};

/*
===============
entity_stop/entity_hide from AD
===============
*/
void(entity targ) entity_stop =
{
	if (targ == world) return;			// Targ is wrong
	targ.use = targ.touch = SUB_Null;	// No more touchy
	targ.think = SUB_Null;				// No more thinking/animation
	targ.nextthink = -1;				// Never fire think
	targ.takedamage = DAMAGE_NO;		// No pain/death triggers
	targ.movetype = MOVETYPE_NONE;		// Stationary
	targ.solid = SOLID_NOT;				// no world interaction
	setsize (targ, VEC_ORIGIN, VEC_ORIGIN);		// No size, no impact
	targ.velocity = targ.avelocity = '0 0 0';	// Frozen velocity
	targ.effects = 0;					// reset effects
	targ.attack_finished = time + 9999999;	// Block all functions
};

void(entity targ) entity_hide =
{
	if (targ == world) return;			// Targ is wrong
	entity_stop(targ);					// No world interaction
	targ.modelindex = 0;				// Make sure no model
	setmodel (targ, "");				// invisible
};

void() SUB_Hide = {
	entity_hide(self);
};
/*
=============
SUB_UseEntTargets
===============
*/
void(entity t) SUB_UseEntTargets =
{
	if (t == world) return;
	activator = self;
	entity oself = self;
	self = t;
	SUB_UseTargets();
	self = oself;
}

/*

in nightmare mode, all attack_finished times become 0
some monsters refire twice automatically

*/

void(float normal) SUB_AttackFinished =
{
	self.cnt = 0;		// refire count for nightmare
	if (startskill != 3)
		self.attack_finished = time + normal;
};

float (entity targ) visible;

void (void() thinkst) SUB_CheckRefire =
{
	if (startskill != 3)
		return;
	if (self.cnt == 1)
		return;
	if (!visible (self.enemy))
		return;
	self.cnt = 1;
	self.think = thinkst;
};

/*
=============
SUB_ChangeModel

size changes after a model change, use this to preserve it
===============
*/
void(entity ent, string mdl) SUB_ChangeModel =
{
	local vector sz,smin,smax;
	sz = ent.size;
	smin = ent.mins;
	smax = ent.maxs;
	
	setmodel(ent, mdl);
	
	if (sz == VEC_ORIGIN)
		setsize(ent, VEC_ORIGIN, VEC_ORIGIN);
	else
		setsize(ent, smin, smax);
}

/*
=============
SUB_CopyTargets
===============
*/
void(entity to) SUB_CopyTargets =
{
	if (to == world) return;
	to.target = self.target;
	to.target2 = self.target2;
	to.target3 = self.target3;
	to.target4 = self.target4;
	to.killtarget = self.killtarget;
}


/*
=============
SUB_ChangeModel
For double-entity monsters, copies the onground flag from the main entity to the secondary 
===============
*/
void() SUB_Copyonground = {
	if (self.flags & FL_ONGROUND) self.trigger_field.flags = self.trigger_field.flags | FL_ONGROUND;
	else self.trigger_field.flags = self.trigger_field.flags - (self.trigger_field.flags & FL_ONGROUND);
};



//======================================================================
// Updates totals on the HUD (checks for client to exist)
// - Specify which total to update using constant
// - Uses MSG_ONE because it is more reliable across many clients
// - Other client updates (SVC_KILLEDMONSTER, SVC_FOUNDSECRET)
// 
// Code by sock, shamelessly stolen from AD
//----------------------------------------------------------------------
float HUD_SECRETS = 2;		// Update secrets screen counter
float HUD_MONSTERS = 4;		// Update monster screen counter

void(float hud_item) update_hud_totals =
{
	// Has the client player been setup yet?
	if (client_ent && client_ent.flags & FL_CLIENT) {

		// Update total secrets
		if (hud_item & HUD_SECRETS) {
			msg_entity = client_ent;
			WriteByte (MSG_ONE, SVC_UPDATESTAT);
			WriteByte (MSG_ONE, STAT_TOTALSECRETS);
			WriteLong (MSG_ONE, total_secrets); 
		}
		// Update total monsters
		if (hud_item & HUD_MONSTERS) {
			msg_entity = client_ent;
			WriteByte (MSG_ONE, SVC_UPDATESTAT);
			WriteByte (MSG_ONE, STAT_TOTALMONSTERS);
			WriteLong (MSG_ONE, total_monsters); 
		}
	}
};


void(float altfoot, float vol_multiplier) play_footstep = {
	local float footstep, footstepnext, footvol;
	local string footstepwav;
	
	if (nofootsteps) return;
	if (self.health < 1) return;
	if (self.movetype == MOVETYPE_NOCLIP) return;
	if (self.watertype < CONTENT_EMPTY) return;
	if (self.steptype == FS_FLYING) return;
	
	// Wide volume range for player
	if (self.flags & FL_CLIENT) footvol = 0.15 + random()*0.1;
	// feetsteps need to be louder during combat
	else if (self.enemy) footvol = 1;
	// Dogs have too many legs making noise, reduce volume	
	//else if (self.classtype == CT_MONDOG) footvol = 0.2 + random()*0.6;
	// Slight random volume level out of combat
	else footvol = 0.7 + random()*0.3;

	footvol = footvol * vol_multiplier;
	
	// Decide which foot sound to play, long live clubfoot!
	if (altfoot) {
		// Switch to ALTernative foot sound
		footstep = self.altsteptype;
		if (self.altsteplast < 1) self.altsteplast = rint(1 + random()*6);

		// Increase footstep sound index by one 
		footstepnext = rint(self.altsteplast + 1);
		// Every loop around, randomly reset
		if (footstepnext > 7) footstepnext = rint(1 + random()*6);
		self.altsteplast = footstepnext;
	}
	else {
		// Setup last footstep sound
		footstep = self.steptype;
		if (self.steplast < 1) self.steplast = rint(1 + random()*6);

		// Player is randomly selected footsteps
		if (self.flags & FL_CLIENT) {
			// Quake random function is not really super random
			// Probably a bad seed starting point for function
			// Use 3 randoms to create something more random!
			footstepnext = rint(self.steplast + random() + random() + random());
			if (footstepnext > 7) footstepnext = footstepnext - 7;
		}
		else {
			// Increase footstep sound index by one 
			footstepnext = rint(self.steplast + 1);
			// Every loop around, randomly reset
			if (footstepnext > 7) footstepnext = rint(1 + random()*6);
		}

		// update last footstep index
		self.steplast = footstepnext;
	}
	
	// Cycle through all footstep types and work out correct sound file
	// All footstep types reduced down to 5 possible choices (speed things up)
	// Could store sound files with entity and cycle round quicker, req more memory
	// re-checking the sound file every footstep is costly on time
	// Luckly most footstep sounds are several frames apart (too noisy as well)
	/*if (footstep == FS_TYPELIGHT) {
		// Light heal/ paw sound
		if (footstepnext < 2) footstepwav = SOUND_FS_LIGHT1;
		else if (footstepnext < 3) footstepwav = SOUND_FS_LIGHT2;
		else if (footstepnext < 4) footstepwav = SOUND_FS_LIGHT3;
		else if (footstepnext < 5) footstepwav = SOUND_FS_LIGHT4;
		else footstepwav = SOUND_FS_LIGHT5;
	}
	else if (footstep == FS_TYPEMEDIUM) {
		// Average foot/boot sound
		if (footstepnext < 2) footstepwav = SOUND_FS_MEDIUM1;
		else if (footstepnext < 3) footstepwav = SOUND_FS_MEDIUM2;
		else if (footstepnext < 4) footstepwav = SOUND_FS_MEDIUM3;
		else if (footstepnext < 5) footstepwav = SOUND_FS_MEDIUM4;
		else footstepwav = SOUND_FS_MEDIUM5;
	}
	else if (footstep == FS_TYPEHEAVY) {
		// Heavy foot with slight echo
		if (footstepnext < 2) footstepwav = SOUND_FS_HEAVY1;
		else if (footstepnext < 3) footstepwav = SOUND_FS_HEAVY2;
		else if (footstepnext < 4) footstepwav = SOUND_FS_HEAVY3;
		else if (footstepnext < 5) footstepwav = SOUND_FS_HEAVY4;
		else footstepwav = SOUND_FS_HEAVY5;
	}
	else if (footstep == FS_TYPELARGE) {
		// Large foot with large echo
		if (footstepnext < 2) footstepwav = SOUND_FS_LARGE1;
		else if (footstepnext < 3) footstepwav = SOUND_FS_LARGE2;
		else if (footstepnext < 4) footstepwav = SOUND_FS_LARGE3;
		else if (footstepnext < 5) footstepwav = SOUND_FS_LARGE4;
		else footstepwav = SOUND_FS_LARGE5;
	}
	else if (footstep == FS_TYPEGIANT) {
		// Giant foot with long echo
		if (footstepnext < 2) footstepwav = SOUND_FS_GIANT1;
		else if (footstepnext < 3) footstepwav = SOUND_FS_GIANT2;
		else if (footstepnext < 4) footstepwav = SOUND_FS_GIANT3;
		else if (footstepnext < 5) footstepwav = SOUND_FS_GIANT4;
		else footstepwav = SOUND_FS_GIANT5;
	}
	else if (footstep == FS_TYPECUSTOM) {
		// Custom feet sounds (usually boss type creatures)
		if (footstepnext < 2) footstepwav = self.stepc1;
		else if (footstepnext < 3) footstepwav = self.stepc2;
		else if (footstepnext < 4) footstepwav = self.stepc3;
		else if (footstepnext < 5) footstepwav = self.stepc4;
		else footstepwav = self.stepc5;
	}
	else if (footstep == FS_TYPEDRAG) {
		// Small scraping foot on ground
		if (footstepnext < 2) footstepwav = SOUND_FS_DRAG1;
		else if (footstepnext < 3) footstepwav = SOUND_FS_DRAG2;
		else if (footstepnext < 4) footstepwav = SOUND_FS_DRAG3;
		else if (footstepnext < 5) footstepwav = SOUND_FS_DRAG4;
		else footstepwav = SOUND_FS_DRAG5;
	}
	// FS_TYPESLOW (default)
	else {
		// Souless shoe foot sound
		if (footstepnext < 2) footstepwav = SOUND_FS_SLOW1;
		else if (footstepnext < 3) footstepwav = SOUND_FS_SLOW2;
		else if (footstepnext < 4) footstepwav = SOUND_FS_SLOW3;
		else if (footstepnext < 5) footstepwav = SOUND_FS_SLOW4;
		else footstepwav = SOUND_FS_SLOW5;
	}*/

	if (footstepnext < 2) footstepwav = "player/foot1.wav";
	else if (footstepnext < 3) footstepwav = "player/foot2.wav";
	else if (footstepnext < 4) footstepwav = "player/foot3.wav";
	else if (footstepnext < 5) footstepwav = "player/foot4.wav";
	else if (footstepnext < 6) footstepwav = "player/foot5.wav";
	else if (footstepnext < 7) footstepwav = "player/foot6.wav";
	else footstepwav = "player/foot7.wav";

	// Play the sound (large feet need to be heard further away)
	if (footstep == FS_TYPELARGE) sound (self, 5, footstepwav, footvol, 1.5);
	else sound (self, 5, footstepwav, footvol, ATTN_IDLE);
};