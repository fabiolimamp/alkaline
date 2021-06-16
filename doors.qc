/*
Advanced doors by bmFbr
*/


float DOOR_START_OPEN = 1;
float DOOR_CRUSHING = 2;
float DOOR_DONT_LINK = 4;
float DOOR_GOLD_KEY = 8;
float DOOR_SILVER_KEY = 16;
float DOOR_TOGGLE = 32;
float DOOR_DOOM_STYLE_UNLOCK = 64;
float DOOR_SOUND_DURING_DELAY = 128;
float DOOR_EXPANDED_TRIGGER_X = 65536;
float DOOR_EXPANDED_TRIGGER_Y = 131072;
float DOOR_REDUCED_TRIGGER_X = 262144;
float DOOR_REDUCED_TRIGGER_Y = 524288;

float DOOR_MIN_THINK_TIME = 0.013;

/*

Doors are similar to buttons, but can spawn a fat trigger field around them
to open without a touch, and they link together to form simultanious
double/quad doors.
 
Door.owner is the master door. If there is only one door, it points to itself.
If multiple doors, all will point to a single one.
The master door also controls movement for the whole linked group.

You can force link doors with the new 'groupname' key. Doors with this key set
will disregard all touching tests for linking, and do that based only on the 
groupname.

Fixed the bug with toggled linked doors firing between themselves, so now you
don't need to set "don't link" on toggling doors anymore.

Door.enemy chains from the master door through all doors linked in the chain.

*/


/*
=============================================================================

THINK FUNCTIONS

=============================================================================
*/

void() door_go_down;
void() door_go_up;
void() door_group_go_up;
void() door_group_go_down;

void() door_blocked = {
	T_Damage (other, self, self, self.dmg);
	
	// if a door has a negative wait, it would never come back if blocked,
	// so let it just squash the object to death real fast
	if (self.wait >= 0 && !(self.spawnflags & DOOR_CRUSHING))
	{
		if (self.owner.groupstate == STATE_DOWN)
			door_group_go_up ();
		else
			door_group_go_down ();
	}
};

void() door_start_sound = {
	sound (self, CHAN_VOICE, self.noise2, self.volume, ATTN_NORM);
};

void() door_stop_sound = {
	sound (self, CHAN_VOICE, self.noise1, self.volume, ATTN_NORM);
};

void() door_move_top = {
	self.velocity = '0 0 0';
	setorigin(self, self.pos2);
	self.nextthink = -1;
	
	if (!(self.spawnflags & DOOR_SOUND_DURING_DELAY)) door_stop_sound();

	self.lastopen = time;
	self.state = STATE_TOP;
}

void() door_hit_top = {
	local entity starte, oself;

	door_move_top();
	
	if (self.delay >= self.owner.maxdelay) { // this is the last door to open


		oself = self;
		starte = self;
		do {
			if (self.spawnflags & DOOR_SOUND_DURING_DELAY) door_stop_sound();

			// Force all doors to stop at their final top position and clear calcmove stuff.
			// This should be a problem only with the master door, since its think function
			// will be redefined now, but do it on every door in the group just to be sure.
			if(self.state != STATE_TOP)
				door_move_top();

			self = self.enemy;
		} while ( (self != starte) && (self != world) );
		self = oself;

		self.owner.groupstate = STATE_TOP;

		if (self.spawnflags & DOOR_TOGGLE)
			return;		// don't come down automatically
		
		
		self.owner.think = door_group_go_down;
		self.owner.nextthink = self.owner.ltime + self.owner.wait;
	}
};

void() door_hit_bottom = {
	if (self.spawnflags & DOOR_SOUND_DURING_DELAY) {
		self.think = door_stop_sound;
		self.nextthink = self.ltime + DOOR_MIN_THINK_TIME + (self.delay - self.owner.mindelay);
	}
	else door_stop_sound();

	self.lastclose = time;
	self.state = STATE_BOTTOM;

	if (self.delay <= self.owner.mindelay) { //this is the last door to close
		self.owner.groupstate = STATE_BOTTOM; 
	}
	
};


void() door_move_up = {
	entity shadow;
	entity oldself;

	if (!(self.spawnflags & DOOR_SOUND_DURING_DELAY)) door_start_sound();

	if (self.max_health) self.takedamage = DAMAGE_NO;

	self.state = STATE_UP;
	self.owner.groupstate = STATE_UP;
	SUB_CalcMove (self.pos2, self.speed, door_hit_top);
	self.owner.activated = FALSE;

	SUB_UseTargets();

	if (self.switchshadstyle) {
		shadow = self.shadowcontroller;
		oldself = self;
		self = shadow;

		misc_shadowcontroller_setsteps(self.speed);
		if (oldself.spawnflags & DOOR_START_OPEN) {
			shadow_fade_in();
			shadow.shadowoff = 0;
		} else {
			
			shadow_fade_out();
			shadow.shadowoff = 1;
		}
		
		self = oldself;
	}
};


void() door_move_down = {
	entity shadow;
	entity oldself;

	if (!(self.spawnflags & DOOR_SOUND_DURING_DELAY)) door_start_sound();

	if (self.max_health && self.owner.estate == STATE_ACTIVE) {
		self.takedamage = DAMAGE_YES;
		self.health = self.max_health;
	}
		
	self.state = STATE_DOWN;
	self.owner.groupstate = STATE_DOWN;
	self.owner.activated = FALSE;
	
	SUB_CalcMove (self.pos1, self.speed2, door_hit_bottom);

	if (self.switchshadstyle) {
		shadow = self.shadowcontroller;
		oldself = self;
		self = shadow;
		
		misc_shadowcontroller_setsteps(self.speed2);
		if (oldself.spawnflags & DOOR_START_OPEN) {
			shadow_fade_out();
			shadow.shadowoff = 1;
		} else {			
			shadow_fade_in();
			shadow.shadowoff = 0;
		}
		
		self = oldself;
		
	}
};

void() door_go_down = {
	local float extradelay;
	local entity otherdoor;

	if (self.spawnflags & DOOR_SOUND_DURING_DELAY) door_start_sound();


	// Door group is still moving the other way
	if (self.owner.movingback) {  
		// If this door has already stopped opening, wait the same time passed since then before closing again
		if (self.state == STATE_TOP) { 
			self.think = door_move_down;
			self.nextthink = self.ltime + DOOR_MIN_THINK_TIME + (time - self.lastopen);
		}
		else { // If door is still moving, move the other way immediately
			self.think = door_move_down;
			self.nextthink = self.ltime + DOOR_MIN_THINK_TIME;
		}
	} else {
		// extra delay time for closing.
		// using "doortowait" is deprecated, use delay2 to set an extra time directly
		if (self.doortowait) {
			otherdoor = find (world, targetname2, self.doortowait);

			if (otherdoor && otherdoor.classname == "func_door") {
				extradelay = vlen(otherdoor.pos1 - otherdoor.pos2) / otherdoor.speed2;
			}
		} else extradelay = self.delay2;

		// Normal movement.
		// All doors should pass through think for consistency,
		// otherwise some flags are set when they're not supposed to
		self.think = door_move_down;
		self.nextthink = self.ltime + DOOR_MIN_THINK_TIME + (self.owner.maxdelay + self.owner.mindelay - self.delay) + extradelay;
	}

};

void() door_go_up = {
	if (self.owner.groupstate == STATE_UP)
		return;		// already going up

	if (self.spawnflags & DOOR_SOUND_DURING_DELAY) door_start_sound();
 	
 	// door group is still moving the other way
	if (self.owner.movingback) {

		// if this door has already stopped closing, wait the same time passed since that before opening 
		if (self.state == STATE_BOTTOM){
			self.think = door_move_up;
			self.nextthink = self.ltime + DOOR_MIN_THINK_TIME + (time - self.lastclose);

		}
		else { // if door is still moving, move the other way immediately
			self.think = door_move_up;
			self.nextthink = self.ltime + DOOR_MIN_THINK_TIME;
		}
	} else {
		// Normal movement.
		// All doors should pass through think for consistency,
		// otherwise some stuff's set when not supposed to
		self.think = door_move_up;
		self.nextthink = self.ltime + DOOR_MIN_THINK_TIME + self.delay;
	}
			
};

void() door_group_go_up = {
	local entity starte, oself;

	if (self.owner.groupstate == STATE_TOP) {	// reset top wait time
		self.owner.nextthink = self.owner.ltime + self.owner.wait;
		return;
	}
	
	// Door group is still moving the other way
	if (self.owner.groupstate == STATE_DOWN) {
		self.owner.movingback = TRUE;
	}

	oself = self;
	starte = self;
	do {
		door_go_up ();
		self = self.enemy;
	} while ((self != starte) && (self != world));

	self = oself;
	self.owner.movingback = FALSE;
};

void() door_group_go_down = {
	local entity starte, oself;

	if (self.owner.groupstate == STATE_BOTTOM)
		return;

	// Door group is still moving the other way
	if (self.owner.groupstate == STATE_UP) {
		self.owner.movingback = TRUE;
	}

	oself = self;
	starte = self;
	do {
		door_go_down ();
		self = self.enemy;
	} while ( (self != starte) && (self != world) );

	self = oself;
};

/*
=============================================================================

ACTIVATION FUNCTIONS

=============================================================================
*/

void() door_fire = {
	local entity oself;

	if (self.owner != self)
		objerror("door_fire: self.owner != self");

	if (self.estate != STATE_ACTIVE) 
		return;

	// self.noise4 is now played in keylock_try_to_unlock -- iw

	self.message = string_null;		// no more message
	oself = self;

	if (self.spawnflags & DOOR_TOGGLE) {
		if (self.owner.groupstate == STATE_UP || self.owner.groupstate == STATE_TOP) {
			door_group_go_down();
			return;
		}
	}
	
	// trigger all paired doors
	door_group_go_up();
};


void() door_use = {
	local entity oself;

	self.message = "";			// door message is for touch only
	self.owner.message = "";	
	self.enemy.message = "";
	oself = self;
	self = self.owner;

	// Prevents the group from being fired again on the same frame by other doors in the group.
	// Can be more performant, but introduces a bug on reset top wait time.
	// Might rethink this later --bmFbr
	//if(!self.activated) {
	//	self.activated = TRUE;
		door_fire ();
	//}
	self = oself;
};


void() door_trigger_touch = {
	// dead things won't open doors
	if (other.health <= 0) return; 
 	
 	// ignore shootable brushes standing in it, like buttons or breakables
	if (other.solid == SOLID_BSP) return;

	// silly fix for sleeping monsters standing behind doors inside their touch fields causing them to open
	// thanks Lunaran
	if (other.flags & FL_MONSTER && other.enemy == world && other.goalentity == world) return;

	// wait a bit before trying to open again
	if (time < self.attack_finished) return;
	self.attack_finished = time + 1;

	activator = other;
	self = self.owner;
	door_use ();
};


void() door_killed = {
	local entity oself;
	
	oself = self;
	self = self.owner;
	self.health = self.max_health;
	self.takedamage = DAMAGE_NO;	// will be reset upon return
	door_use();
	self = oself;
};

void(entity e, float closealldoors) door_estate_lock = {
	local entity oself, next;

	if (e.owner.estate == STATE_INACTIVE) return;

	oself = self;
	self = e.owner;

	self.estate = STATE_INACTIVE;

	self.prevgroupstate = self.groupstate;

	if (self.groupstate == STATE_UP || self.groupstate == STATE_TOP) {
		if (
			!(self.wait == -1 || (self.spawnflags & DOOR_TOGGLE))
			|| closealldoors
		) door_group_go_down();
	}

	if (self.max_health) {
		next = self;
		do {
			//e.health = 0;
			next.takedamage = DAMAGE_NO;
			next = next.enemy;
		} while ( (next != self) && (next != world) );
	}

	self = oself;

}

void(entity e, float openalldoors) door_estate_unlock = {
	local entity oself, next;
	
	if (e.owner.estate == STATE_ACTIVE) return;

	oself = self;
	self = e.owner;

	if (self.prevgroupstate == STATE_UP || self.prevgroupstate == STATE_TOP) {
		if (
			(self.wait == -1 || (self.spawnflags & DOOR_TOGGLE))
			&& openalldoors
		) door_group_go_up();
	}

	if (self.max_health) {
		next = self;
		do {
			next.health = next.max_health;
			next.takedamage = DAMAGE_YES;
			next = next.enemy;
		} while ( (next != self) && (next != world) );
	}

	self.estate = STATE_ACTIVE;

	self = oself;
}

/*
================
door_unlock

Perform the actions which should be performed when self is successfully
unlocked with a key.

This function exists so that it can be passed as an argument to the new
keylock_try_to_unlock function.  This code was previously part of the
door_touch function.  -- iw
================
*/
void() door_unlock = {
	if (!(self.spawnflags & DOOR_DOOM_STYLE_UNLOCK)) {
		self.touch = SUB_Null;
		if (self.enemy)
			self.enemy.touch = SUB_Null;	// get paired door
	}
	door_use ();
};

/*
================
door_touch

Prints messages and opens key doors
================
*/
void() door_touch =
{
	if (other.classname != "player")
		return;

	if (self.owner.attack_finished > time)
		return;

	self.owner.attack_finished = time + 2;

	if (self.owner.message != "")
	{
		centerprint (other, self.owner.message);
		sound (other, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NORM);
	}


	if (self.owner.estate != STATE_ACTIVE)
		return;
// key door stuff
	if (!keylock_has_key_set ())
		return;

	keylock_try_to_unlock (other, "", door_unlock);
};

/*
=============================================================================

SPAWNING FUNCTIONS

=============================================================================
*/



entity(vector fmins, vector fmaxs) spawn_field =
{
	local entity	trigger;
	local	vector	t1, t2, expfield;

	trigger = spawn();
	trigger.movetype = MOVETYPE_NONE;
	trigger.solid = SOLID_TRIGGER;
	trigger.owner = self;
	trigger.touch = door_trigger_touch;

	t1 = fmins;
	t2 = fmaxs;

	expfield = '60 60 8';
	if (self.spawnflags & DOOR_EXPANDED_TRIGGER_X) expfield_x += 24;
	if (self.spawnflags & DOOR_EXPANDED_TRIGGER_Y) expfield_y += 24;

	if (self.spawnflags & DOOR_REDUCED_TRIGGER_X) expfield_x -= 52;
	if (self.spawnflags & DOOR_REDUCED_TRIGGER_Y) expfield_y -= 52;

	setsize (trigger, t1 - expfield, t2 + expfield);
	return (trigger);
};

void() spawn_field_think =
{
	self.trigger_field = spawn_field(self.cmins, self.cmaxs);
};


void(entity door, float ldcount) setupTriggerField = {
	local entity oself, tfield;

	oself = self;
	self = door;

	// Shootable, fired, or key doors just needed the owner/enemy links,
	// they don't spawn a field

	if (self.owner == self && !keylock_has_key_set() && !self.health) {
		
		if (self.targetname != "") { 
			// search for a trigger_doortriggerfield targeting it
			// if not found, don't create a triggerfield as usual
			do {
				tfield = find(tfield, classname, "trigger_doortriggerfield");
			}
			while (tfield && tfield.target != self.targetname);
			
			if (tfield) {
				self.trigger_field = tfield;
				tfield.owner = self;
				tfield.touch = door_trigger_touch;
			}

		}

		else if (self.targetname == "" && !self.trigger_field) {
			self.think = spawn_field_think;
			self.nextthink = self.ltime + 1 - clamp(ldcount / 20, 0, 0.95);
		}
	}

	self = oself;
}

float (entity e1, entity e2) EntitiesTouching =
{
	if (e1.mins_x > e2.maxs_x) {
		return FALSE;
	}
	if (e1.mins_y > e2.maxs_y){
		return FALSE;
	}
	if (e1.mins_z > e2.maxs_z){
		return FALSE;
	}
	if (e1.maxs_x < e2.mins_x){
		return FALSE;
	}
	if (e1.maxs_y < e2.mins_y){
		return FALSE;
	}
	if (e1.maxs_z < e2.mins_z){
		return FALSE;
	}

	return TRUE;
};


/*
=============
LinkDoors
New version by bmFbr
=============
*/
float doorloopcount;
void() clearDoorQ;
void(entity e) addDoorQ;
entity() getNextDoorQ;

void(entity d1, float ldcount) LinkDoorsEntity;

// Runs from a temporary entity created on worldspawn
void() LinkDoors2 = {
	local entity d1, next, lastfound;
	local entity nextld;

	if (self.count) { // not the first LinkDoors entity to run, so resume from the values passed by the previous one
		d1 = self.ld_currentdoor;
		next = self.ld_nextdoor;
		lastfound = self.ld_lastfound;
	} else {
		d1 = find(world, classname, "func_door");
	 	lastfound = d1;
 	}

 	//dprint("Linkdoors count: ");dprint(ftos(self.count));dprint("\n");
	
	while (d1) {
		if (!d1.doorlooped) {
			LinkDoorsEntity(d1, self.count);
		}

		next = getNextDoorQ();

		if (next) d1 = next;
		else {
			d1 = find(lastfound, classname, "func_door");
			lastfound = d1;
		}

		// Arbitrary max loop count found by trial and error (sue me)
		// before the engine thinks you've got a runaway loop.
		// If that limit is reached, spawn a new entity and
		// resume the loop from it in the next frames
		if (doorloopcount > 1800) {
			nextld = spawn();

			nextld.ld_currentdoor = d1;
			nextld.ld_nextdoor = next;
			nextld.ld_lastfound = lastfound;
			nextld.count = self.count + 1; // sequential number for each LinkDoor entity

			nextld.think = LinkDoors2;
			nextld.nextthink = time + 0.02;
			doorloopcount = 0;
			break;
		}

	}
	if(!nextld) door_setup_finished = 1;
	remove(self);
};

void(entity d1, float ldcount) LinkDoorsEntity = {
	local entity d2, groupdoor, newdoor;
	
	if (d1.spawnflags & DOOR_DONT_LINK) {
		d1.owner = d1;
		d1.enemy = d1;
		d1.lastenemy = d1;
		d1.doorlooped = TRUE;
		setupTriggerField(d1, ldcount);
		return;
	}
	
	d2 = find(world, classname, d1.classname);
	
	while (d2) {
		if (!(d1.owner && d2.owner) && !(d2.spawnflags & DOOR_DONT_LINK) && d2 != d1) {
			if ((EntitiesTouching(d1,d2) && !d1.groupname && !d2.groupname) || (d1.groupname && d2.groupname == d1.groupname)) {
				
				if(!d1.owner && !d2.owner) { // if neither door has an owner then start a new group with d1 as master
					d1.owner = d1;
					d1.enemy = d1;
					d1.lastenemy = d1;
				}

				if (d1.owner) { // d1 belongs to a group, d2 doesn't, so add d2 to d1's group
					groupdoor = d1;
					newdoor = d2;
				}
				else { // d2 belongs to a group, d1 doesn't, so add d1 to d2's group
					groupdoor = d2;
					newdoor = d1;
				}

				newdoor.owner = groupdoor.owner; // newdoor will have the same owner as the previous one
				newdoor.enemy = groupdoor.owner; // newdoor will be the last in the chain, so it should point to the beginning (master door)
				groupdoor.owner.lastenemy.enemy = newdoor; // lastenemy will probably be groupdoor by this time, but not necessarily, so I reference the previous lastenemy
				groupdoor.owner.lastenemy = newdoor; // newdoor is the last in the chain
				
				// min and max group delay for open/close timings calculation
				if (newdoor.delay > groupdoor.owner.maxdelay) groupdoor.owner.maxdelay = newdoor.delay;
				if (newdoor.delay < groupdoor.owner.mindelay) groupdoor.owner.mindelay = newdoor.delay;

				// expand trigger field if necessary
				if (newdoor.mins_x < groupdoor.owner.cmins_x)
					groupdoor.owner.cmins_x = newdoor.mins_x;
				if (newdoor.mins_y < groupdoor.owner.cmins_y)
					groupdoor.owner.cmins_y = newdoor.mins_y;
				if (newdoor.mins_z < groupdoor.owner.cmins_z)
					groupdoor.owner.cmins_z = newdoor.mins_z;
				if (newdoor.maxs_x > groupdoor.owner.cmaxs_x)
					groupdoor.owner.cmaxs_x = newdoor.maxs_x;
				if (newdoor.maxs_y > groupdoor.owner.cmaxs_y)
					groupdoor.owner.cmaxs_y = newdoor.maxs_y;
				if (newdoor.maxs_z > groupdoor.owner.cmaxs_z)
					groupdoor.owner.cmaxs_z = newdoor.maxs_z;

				
				// Copy some important fields over to the master door if set.
				// Every door in the group should have the same values for all of these fields
				// or only one door with them set, otherwise things will get unpredictable.
				if (newdoor.health)
					groupdoor.owner.health = newdoor.health;
				if (newdoor.targetname != "")
					groupdoor.owner.targetname = newdoor.targetname;
				if (newdoor.message != "")
					groupdoor.owner.message = newdoor.message;
				if (newdoor.spawnflags & DOOR_EXPANDED_TRIGGER_X)
					groupdoor.owner.spawnflags = groupdoor.owner.spawnflags | DOOR_EXPANDED_TRIGGER_X;
				if (newdoor.spawnflags & DOOR_EXPANDED_TRIGGER_Y)
					groupdoor.owner.spawnflags = groupdoor.owner.spawnflags | DOOR_EXPANDED_TRIGGER_Y;
				if (newdoor.spawnflags & DOOR_REDUCED_TRIGGER_X)
					groupdoor.owner.spawnflags = groupdoor.owner.spawnflags | DOOR_REDUCED_TRIGGER_X;
				if (newdoor.spawnflags & DOOR_REDUCED_TRIGGER_Y)
					groupdoor.owner.spawnflags = groupdoor.owner.spawnflags | DOOR_REDUCED_TRIGGER_Y;


				// Add newly linked door to the queue.
				// Door queue creates a "path" between potentially linking doors from the group to prevent
				// isolated ones (due to entity creation order) from starting a new group.
				if(!newdoor.doorlooped && newdoor.dqplace == -1)
					addDoorQ(newdoor);

			}
		}
		doorloopcount++;
		d2 = find(d2, classname, d1.classname);
	}

	// if no other connecting door has been found, then create a group with itself
	if (!d1.owner) {
		d1.owner = d1;
		d1.enemy = d1;
		d1.lastenemy = d1;
	}
	
	// set up triggerfield valididy checks & creation to happen afterwards
	setupTriggerField(d1, ldcount);

	// Mark door as looped so it will never loop again.
	d1.doorlooped = TRUE;
};


/*QUAKED func_door (0 .5 .8) ? START_OPEN x DOOR_DONT_LINK GOLD_KEY SILVER_KEY TOGGLE
if two doors touch, they are assumed to be connected and operate as a unit.

TOGGLE causes the door to wait in both the start and end states for a trigger event.

START_OPEN causes the door to move to its destination when spawned, and operate in reverse.  It is used to temporarily or permanently close off an area when triggered (not usefull for touch or takedamage doors).

Key doors are allways wait -1.

"message"	is printed when the door is touched if it is a trigger door and it hasn't been fired yet
"angle"		determines the opening direction
"targetname" if set, no touch field will be spawned and a remote button or trigger field activates the door.
"health"	if set, door must be shot open
"speed"		movement speed (100 default)
"wait"		wait before returning (3 default, -1 = never return)
"lip"		lip remaining at end of move (8 default)
"dmg"		damage to inflict when blocked (2 default)
"sounds"
0)	no sound
1)	stone
2)	base
3)	stone chain
4)	screechy metal
*/

void() func_door = {
	local string default_noise1;
	local string default_noise2;

	local entity shadow;
	local entity oldself;

// self.noise3 and self.noise4 can now be overridden by the mapper, but
// will be set to default values in keylock_init if necessary -- iw
	keylock_init ();

	// self.noise1 and self.noise2 can now be overridden by the mapper -- iw

	if (self.sounds == 1) {
		default_noise1 = "doors/drclos4.wav";
		default_noise2 = "doors/doormv1.wav";
	}
	else if (self.sounds == 2) {
		default_noise1 = "doors/hydro2.wav";
		default_noise2 = "doors/hydro1.wav";
	}
	else if (self.sounds == 3) {
		default_noise1 = "doors/stndr2.wav";
		default_noise2 = "doors/stndr1.wav";
	}
	else if (self.sounds == 4) {
		default_noise1 = "doors/ddoor2.wav";
		default_noise2 = "doors/ddoor1.wav";
	}
	else if (self.sounds == 6) {
		default_noise1 = "doors/q2door2.wav";
		default_noise2 = "doors/q2door1.wav";
	}
	else {
		default_noise1 = "misc/null.wav";
		default_noise2 = "misc/null.wav";
	}

	if (self.noise1 == "")
		self.noise1 = default_noise1;
	if (self.noise2 == "")
		self.noise2 = default_noise2;

	precache_sound (self.noise1);
	precache_sound (self.noise2);

	if (!self.volume)
		self.volume = 1;

	self.max_health = self.health;
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	setorigin (self, self.origin);	
	setmodel (self, self.model);

	

	// why is this needed?
	//self.classname = "door";

	self.blocked = door_blocked;
	self.use = door_use;
	
	if (self.spawnflags & DOOR_SILVER_KEY)
		keylock_set_silver_key ();
	if (self.spawnflags & DOOR_GOLD_KEY)
		keylock_set_gold_key ();

	// support for item_key_custom -- iw
	if (self.keyname != "") {
		keylock_set_custom_key (self.keyname);
		self.keyname = "";  // this should not be referenced again
	}


	if (!self.wait)
		self.wait = 3;
	if (!self.dmg)
		self.dmg = 2;
	if (!self.speed)
		self.speed = 100;
	if (!self.speed2)
		self.speed2 = self.speed;

	self.pos1 = self.origin;


	if (self.movedir) { // direct movedir
		self.pos2 = self.pos1 + self.movedir;
		self.angles = '0 0 0';
	}
	else if (self.mangle != '0 0 0') { // mangle + distance
		if(!self.distance) self.distance = 64;

		makevectors (self.mangle);
		self.movedir = v_forward;

		self.pos2 = self.pos1 + self.movedir * self.distance;
	}
	else {
		SetMovedir ();
		if (self.distance) { // angle + distance
			self.pos2 = self.pos1 + self.movedir * self.distance;
		}
		else { // angle + lip
			if (!self.lip) self.lip = 8;
			self.pos2 = self.pos1 + self.movedir*(fabs(self.movedir*self.size) - self.lip);
		}
	}



	// DOOR_START_OPEN is to allow an entity to be lighted in the closed position
	// but spawn in the open position
	if (self.spawnflags & DOOR_START_OPEN) {
		setorigin (self, self.pos2);
		self.pos2 = self.pos1;
		self.pos1 = self.origin;
	}

	self.maxdelay = self.delay;
	self.mindelay = self.delay;

	self.state = STATE_BOTTOM;
	self.groupstate = STATE_BOTTOM;

	if (self.health) {
		self.takedamage = DAMAGE_YES;
		self.th_die = door_killed;
	}
	
	if (self.spawnflags & DOOR_DOOM_STYLE_UNLOCK)
		self.cnt = 1;

	if (keylock_has_key_set ())	{
		if (!(self.spawnflags & DOOR_DOOM_STYLE_UNLOCK))
			self.wait = -1;
	}	
	self.touch = door_touch;

	self.cmaxs = self.maxs;
	self.cmins = self.mins;

// LinkDoors can't be done until all of the doors have been spawned, so
// the sizes can be detected properly.
	// LinkDoors is now run on worldspawn
	//self.think = LinkDoors;
	//self.nextthink = self.ltime + 0.1;

	self.dqplace = -1;

		// creates a shadow controller entity for the door if it has switchable shadows
	if(self.switchshadstyle) {
		
		shadow = spawn();
		
		self.shadowcontroller = shadow;
		
		shadow.classname = "misc_shadowcontroller";
		shadow.switchshadstyle = self.switchshadstyle;
		shadow.speed = vlen(self.pos2 - self.pos1) / self.speed;
		shadow.speed2 = vlen(self.pos2 - self.pos1) / self.speed2;
		
		if(self.spawnflags & DOOR_START_OPEN) shadow.spawnflags = 1;
		else shadow.spawnflags = 0;
		
		
		oldself = self;
		
		self = shadow;
		misc_shadowcontroller();
		
		self = oldself;
	}
};

/*
=============================================================================

SECRET DOORS

=============================================================================
*/

void() fd_secret_move1;
void() fd_secret_move2;
void() fd_secret_move3;
void() fd_secret_move4;
void() fd_secret_move5;
void() fd_secret_move6;
void() fd_secret_done;

float SECRET_OPEN_ONCE = 1;		// stays open
float SECRET_1ST_LEFT = 2;		// 1st move is left of arrow
float SECRET_1ST_DOWN = 4;		// 1st move is down from arrow
float SECRET_NO_SHOOT = 8;		// only opened by trigger
float SECRET_YES_SHOOT = 16;	// shootable even if targeted


void () fd_secret_use =
{
	local float temp;

	self.health = 10000;

	// exit if still moving around...
	if (self.origin != self.oldorigin)
		return;
	
	self.message = string_null;		// no more message

	SUB_UseTargets();				// fire all targets / killtargets
	
	if (!(self.spawnflags & SECRET_NO_SHOOT))
	{
		self.th_pain = SUB_NullPain;
		self.takedamage = DAMAGE_NO;
	}
	self.velocity = '0 0 0';

	// Make a sound, wait a little...
	
	sound(self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	self.nextthink = self.ltime + 0.1;

	temp = 1 - (self.spawnflags & SECRET_1ST_LEFT);	// 1 or -1
	makevectors(self.mangle);
	
	if (!self.t_width)
	{
		if (self.spawnflags & SECRET_1ST_DOWN)
			self. t_width = fabs(v_up * self.size);
		else
			self. t_width = fabs(v_right * self.size);
	}
		
	if (!self.t_length)
		self. t_length = fabs(v_forward * self.size);

	if (self.spawnflags & SECRET_1ST_DOWN)
		self.dest1 = self.origin - v_up * self.t_width;
	else
		self.dest1 = self.origin + v_right * (self.t_width * temp);
		
	self.dest2 = self.dest1 + v_forward * self.t_length;
	SUB_CalcMove(self.dest1, self.speed, fd_secret_move1);
	sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);
};

void(entity attacker, float damage) fd_secret_pain = { fd_secret_use(); };

// Wait after first movement...
void () fd_secret_move1 = 
{
	self.nextthink = self.ltime + 1.0;
	self.think = fd_secret_move2;
	sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
};

// Start moving sideways w/sound...
void () fd_secret_move2 =
{
	sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);
	SUB_CalcMove(self.dest2, self.speed, fd_secret_move3);
};

// Wait here until time to go back...
void () fd_secret_move3 =
{
	sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
	if (!(self.spawnflags & SECRET_OPEN_ONCE))
	{
		self.nextthink = self.ltime + self.wait;
		self.think = fd_secret_move4;
	}
};

// Move backward...
void () fd_secret_move4 =
{
	sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);
	SUB_CalcMove(self.dest1, self.speed, fd_secret_move5);		
};

// Wait 1 second...
void () fd_secret_move5 = 
{
	self.nextthink = self.ltime + 1.0;
	self.think = fd_secret_move6;
	sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
};

void () fd_secret_move6 =
{
	sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);
	SUB_CalcMove(self.oldorigin, self.speed, fd_secret_done);
};

void () fd_secret_done =
{
	if (!self.targetname || self.spawnflags&SECRET_YES_SHOOT)
	{
		self.health = 10000;
		self.takedamage = DAMAGE_YES;
		self.th_pain = fd_secret_pain;	
	}
	sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
};

void () secret_blocked =
{
	if (time < self.attack_finished)
		return;
	self.attack_finished = time + 0.5;
	T_Damage (other, self, self, self.dmg);
};

/*
================
secret_touch

Prints messages
================
*/
void() secret_touch =
{
	if (other.classname != "player")
		return;
	if (self.attack_finished > time)
		return;

	self.attack_finished = time + 2;
	
	if (self.message)
	{
		centerprint (other, self.message);
		sound (other, CHAN_BODY, "misc/talk.wav", 1, ATTN_NORM);
	}
};


/*QUAKED func_door_secret (0 .5 .8) ? open_once 1st_left 1st_down no_shoot always_shoot
Basic secret door. Slides back, then to the side. Angle determines direction.
wait  = # of seconds before coming back
1st_left = 1st move is left of arrow
1st_down = 1st move is down from arrow
always_shoot = even if targeted, keep shootable
t_width = override WIDTH to move back (or height if going down)
t_length = override LENGTH to move sideways
"dmg"		damage to inflict when blocked (2 default)

If a secret door has a targetname, it will only be opened by it's botton or trigger, not by damage.
"sounds"
1) medieval
2) metal
3) base
*/

void () func_door_secret =
{
	if (self.sounds == 0)
		self.sounds = 3;
	if (self.sounds == 1)
	{
		precache_sound ("doors/latch2.wav");
		precache_sound ("doors/winch2.wav");
		precache_sound ("doors/drclos4.wav");
		self.noise1 = "doors/latch2.wav";
		self.noise2 = "doors/winch2.wav";
		self.noise3 = "doors/drclos4.wav";
	}
	if (self.sounds == 2)
	{
		precache_sound ("doors/airdoor1.wav");
		precache_sound ("doors/airdoor2.wav");
		self.noise2 = "doors/airdoor1.wav";
		self.noise1 = "doors/airdoor2.wav";
		self.noise3 = "doors/airdoor2.wav";
	}
	if (self.sounds == 3)
	{
		precache_sound ("doors/basesec1.wav");
		precache_sound ("doors/basesec2.wav");
		self.noise2 = "doors/basesec1.wav";
		self.noise1 = "doors/basesec2.wav";
		self.noise3 = "doors/basesec2.wav";
	}

	if (!self.dmg)
		self.dmg = 2;
		
	// Magic formula...
	self.mangle = self.angles;
	self.angles = '0 0 0';
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	//self.classname = "door";
	setmodel (self, self.model);
	setorigin (self, self.origin);	
	
	self.touch = secret_touch;
	self.blocked = secret_blocked;
	self.speed = 50;
	self.use = fd_secret_use;
	if ( !self.targetname || self.spawnflags&SECRET_YES_SHOOT)
	{
		self.health = 10000;
		self.takedamage = DAMAGE_YES;
		self.th_pain = fd_secret_pain;
		self.th_die = fd_secret_use;
	}
	self.oldorigin = self.origin;
	if (!self.wait)
		self.wait = 5;		// 5 seconds before closing
};


/*
=============
Door queue for linking
===============
*/

void() clearDoorQ = {
	while(currentdq <= lastdq) {
		if(doorq[currentdq]) doorq[currentdq].dqplace = -1;
		currentdq++;
	}
	currentdq = -1;
	lastdq = -1;
};

void(entity e) addDoorQ = {
	if(lastdq < _MAX_ENTITY_QUEUE - 1) {
		lastdq++;
		doorq[lastdq] = e;
		e.dqplace = lastdq;
	}
	else {
		error("doorq _MAX_ENTITY_QUEUE exceeded when adding\n");
	}
};

entity() getNextDoorQ = {
	local entity e;

	if (currentdq < lastdq && lastdq >= 0 && currentdq < _MAX_ENTITY_QUEUE - 1) {
		currentdq++;

		e = doorq[currentdq];
		
		if(e)
			e.dqplace = -1;

		if (currentdq >= lastdq) clearDoorQ();
	}
	else if (currentdq >= _MAX_ENTITY_QUEUE - 1) {
		error("doorq _MAX_ENTITY_QUEUE exceeded when getting\n");
		break();
	}
	else e = world;


	return e;
};


/*
=============
target_setdoor
===============
*/

void(.string fld, string tgt) target_setdoor_set = {
	local entity e, oself;

	e = find(world, fld, tgt);
	while (e) {
		if (e.classname == "func_door") {
			oself = self;
			self = e.owner;
			
			if (oself.style == 0) door_group_go_up();
			else door_group_go_down();
			
			self = oself;
		}
		e = find(e, fld, tgt);
	}
};
void() target_setdoor_usetargets = {
	if (self.target != "") {
		target_setdoor_set(targetname, self.target);
		target_setdoor_set(targetname2, self.target);
	}
	if (self.target2 != "") {
		target_setdoor_set(targetname, self.target2);
		target_setdoor_set(targetname2, self.target2);
	}
	if (self.target3 != "") {
		target_setdoor_set(targetname, self.target3);
		target_setdoor_set(targetname2, self.target3);
	}
	if (self.target4 != "") {
		target_setdoor_set(targetname, self.target4);
		target_setdoor_set(targetname2, self.target4);
	}
}

void() target_setdoor_use = {
	if (self.delay) {
		if (time < self.nextthink) return;
		else {
			self.think = target_setdoor_usetargets;
			self.nextthink = time + self.delay;
		}
	}
	else target_setdoor_usetargets();
};

void() target_setdoor = {
	self.use = target_setdoor_use;
};


/*
=============
trigger_doortriggerfield

Sets a user-defined door's trigger field.
===============
*/

void() trigger_doortriggerfield = {

	if (!self.target || self.target == "") {
		objerror("No target set");
		return;
	}

	InitTrigger();

	// self.touch and self.owner are defined on the setupTriggerField func,
	// so it only happens after the door groups are set
};
