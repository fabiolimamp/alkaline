
entity s;


void() trigger_reactivate =
{
	self.solid = SOLID_TRIGGER;
};

//=============================================================================

float	SPAWNFLAG_NOMESSAGE = 1;
float	SPAWNFLAG_NOTOUCH = 1;
float	TRIGGER_MONSTERTRIGGERABLE = 128;

void() SUB_EndWaiting = {
	self.is_waiting = 0;
	self.estate = STATE_ACTIVE;
	if (self.use == SUB_EndWaiting) self.use = self.dormant_use;

	// special case for teleports, makes it ignore the fact that it has a targetname when touched
	if (self.classname == "trigger_teleport") {
		self.is_waiting = -1;
	}
};

void() SUB_CheckWaiting = {
	if (self.is_waiting > 0) {
		self.dormant_use = self.use;
		self.use = SUB_EndWaiting;
		self.estate = STATE_INACTIVE;

		dprint("Spawned a waiting ");
		dprint(self.classname);
		dprint(" with targetname ");
		dprint(self.targetname);
		dprint(" and target ");
		dprint(self.target);
		dprint("\n");
	}
};

// the wait time has passed, so set back up for another activation
void() multi_wait =
{
	if (self.max_health)
	{
		self.health = self.max_health;
		self.takedamage = DAMAGE_YES;
		self.solid = SOLID_BBOX;
	}
};


// the trigger was just touched/killed/used
// self.enemy should be set to the activator so it can be held through a delay
// so wait for the delay time before firing
void() multi_trigger =
{
	if (self.nextthink > time)
	{
		return;		// already been triggered
	}

	if (self.estate != STATE_ACTIVE)
		return;

	if (self.classname == "trigger_secret")
	{
		if (self.enemy.classname != "player")
			return;
		found_secrets = found_secrets + 1;
		WriteByte (MSG_ALL, SVC_FOUNDSECRET);
	}

	if (self.noise)
		sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);

// don't trigger again until reset
	self.takedamage = DAMAGE_NO;

	activator = self.enemy;
	
	SUB_UseTargets();

	if (self.wait > 0)	
	{
		self.think = multi_wait;
		self.nextthink = time + self.wait;
	}
	else
	{	// we can't just remove (self) here, because this is a touch function
		// called wheil C code is looping through area links...
		self.touch = SUB_Null;
		self.nextthink = time + 0.1;
		self.think = SUB_Remove;
	}
};

void() multi_killed = //dumptruck_ds
{
	if (self.estate != STATE_ACTIVE)	//restore health and do nothing if trigger is disabled
	{
		self.health		= self.max_health;	// nyah nyah~!
		self.takedamage	= DAMAGE_YES;
		self.solid		= SOLID_BBOX;

		return;
	}

	self.enemy = damage_attacker;
	multi_trigger();
};

void() multi_use = //dumptruck_ds
{
	self.enemy = activator;
	multi_trigger();
};

void() multi_touch =
{
	if (other.classname != "player" && !(other.flags & FL_MONSTER && self.spawnflags & TRIGGER_MONSTERTRIGGERABLE))
		return;

	if (self.estate != STATE_ACTIVE)
		return;

// if the trigger has an angles field, check player's facing direction
	if (self.movedir != '0 0 0')
	{
		makevectors (other.angles);
		if (v_forward * self.movedir < 0)
			return;		// not facing the right way
	}
	
	self.enemy = other;
	multi_trigger ();
};

/*QUAKED trigger_multiple (.5 .5 .5) ? notouch
Variable sized repeatable trigger.  Must be targeted at one or more entities.  If "health" is set, the trigger must be killed to activate each time.
If "delay" is set, the trigger waits some time after activating before firing.
"wait" : Seconds between triggerings. (.2 default)
If notouch is set, the trigger is only fired by other entities, not by touching.
NOTOUCH has been obsoleted by trigger_relay!
sounds
1)	secret
2)	beep beep
3)	large switch
4)
set "message" to text string
*/
void() trigger_multiple =
{
	

	if (self.sounds == 1)
	{
		precache_sound ("misc/secret.wav");
		self.noise = "misc/secret.wav";
	}
	else if (self.sounds == 2)
	{
		precache_sound ("misc/talk.wav");
		self.noise = "misc/talk.wav";
	}
	else if (self.sounds == 3)
	{
		precache_sound ("misc/trigger1.wav");
		self.noise = "misc/trigger1.wav";
	}
	
	if (!self.wait)
		self.wait = 0.2;
	self.use = multi_use;

	InitTrigger ();

	if (self.health)
	{
		if (self.spawnflags & SPAWNFLAG_NOTOUCH)
			objerror ("health and notouch don't make sense\n");
		self.max_health = self.health;
		self.th_die = multi_killed;
		self.takedamage = DAMAGE_YES;
		self.solid = SOLID_BBOX;
		setorigin (self, self.origin);	// make sure it links into the world
	}
	else
	{
		if ( !(self.spawnflags & SPAWNFLAG_NOTOUCH) )
		{
			self.touch = multi_touch;
		}
	}

	SUB_CheckWaiting();
};


/*QUAKED trigger_once (.5 .5 .5) ? notouch
Variable sized trigger. Triggers once, then removes itself.  You must set the key "target" to the name of another object in the level that has a matching
"targetname".  If "health" is set, the trigger must be killed to activate.
If notouch is set, the trigger is only fired by other entities, not by touching.
if "killtarget" is set, any objects that have a matching "target" will be removed when the trigger is fired.
if "angle" is set, the trigger will only fire when someone is facing the direction of the angle.  Use "360" for an angle of 0.
sounds
1)	secret
2)	beep beep
3)	large switch
4)
set "message" to text string
*/
void() trigger_once =
{
	self.wait = -1;
	trigger_multiple();
};

//=============================================================================

/*QUAKED trigger_relay (.5 .5 .5) (-8 -8 -8) (8 8 8)
This fixed size trigger cannot be touched, it can only be fired by other events.  It can contain killtargets, targets, delays, and messages.
*/
void() trigger_relay =
{
	self.use = SUB_UseTargets;
};


//=============================================================================

/*QUAKED trigger_secret (.5 .5 .5) ?
secret counter trigger
sounds
1)	secret
2)	beep beep
3)
4)
set "message" to text string
*/
void() trigger_secret =
{
	total_secrets = total_secrets + 1;
	self.wait = -1;
	if (!self.message)
		self.message = "You found a secret area!";
	if (!self.sounds)
		self.sounds = 1;
	
	if (self.sounds == 1)
	{
		precache_sound ("misc/secret.wav");
		self.noise = "misc/secret.wav";
	}
	else if (self.sounds == 2)
	{
		precache_sound ("misc/talk.wav");
		self.noise = "misc/talk.wav";
	}

	trigger_multiple ();
};

//=============================================================================


void() counter_use =
{
//	local string junk;

	if (self.estate != STATE_ACTIVE) return;

	self.count = self.count - 1;
	if (self.count < 0)
		return;
	
	if (self.count != 0)
	{
		if (activator.classname == "player"
		&& (self.spawnflags & SPAWNFLAG_NOMESSAGE) == 0)
		{
			if (self.count >= 4)
				centerprint (activator, "There are more to go...");
			else if (self.count == 3)
				centerprint (activator, "Only 3 more to go...");
			else if (self.count == 2)
				centerprint (activator, "Only 2 more to go...");
			else
				centerprint (activator, "Only 1 more to go...");
		}
		return;
	}
	
	if (activator.classname == "player"
	&& (self.spawnflags & SPAWNFLAG_NOMESSAGE) == 0)
		centerprint(activator, "Sequence completed!");
	self.enemy = activator;
	multi_trigger ();
};

/*QUAKED trigger_counter (.5 .5 .5) (-8 -8 -8) (8 8 8) nomessage
Acts as an intermediary for an action that takes multiple inputs.

If nomessage is not set, t will print "1 more.. " etc when triggered and "sequence complete" when finished.

After the counter has been triggered "count" times (default 2), it will fire all of it's targets and remove itself.
*/
void() trigger_counter =
{
	self.wait = -1;
	if (!self.count)
		self.count = 2;

	self.use = counter_use;
};


/*
==============================================================================

TELEPORT TRIGGERS

==============================================================================
*/

float	PLAYER_ONLY	= 1;
float	SILENT = 2;
float TELE_STEALTH = 4;
/*float RANDOM = 4;
float MONSTER_ONLY = 16;
float TELE_DD = 32;*/

float TELEPORT_STYLE_FIRST = 0;
float TELEPORT_STYLE_RANDOM = 1;
float TELEPORT_STYLE_CYCLE = 2;

void() play_teleport =
{
	local	float v;
	local	string tmpstr;

	v = random() * 5;
	if (v < 1)
		tmpstr = "misc/r_tele1.wav";
	else if (v < 2)
		tmpstr = "misc/r_tele2.wav";
	else if (v < 3)
		tmpstr = "misc/r_tele3.wav";
	else if (v < 4)
		tmpstr = "misc/r_tele4.wav";
	else
		tmpstr = "misc/r_tele5.wav";

	sound (self, CHAN_VOICE, tmpstr, 1, ATTN_NORM);
	remove (self);
};

void(vector org) spawn_tfog =
{
	s = spawn ();
	s.origin = org;
	s.nextthink = time + 0.2;
	s.think = play_teleport;

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_TELEPORT);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
};


void() tdeath_touch =
{
	if (other == self.owner)
		return;

// frag anyone who teleports in on top of an invincible player
	if (other.classname == "player")
	{
		if ((other.invincible_finished > time) || (other.trif_finished > time))
			self.classname = "teledeath2";
		if (self.owner.classname != "player")
		{	// other monsters explode themselves
			T_Damage (self.owner, self, self, 50000);
			return;
		}
		
	}

	if (other.health)
	{
		T_Damage (other, self, self, 50000);
	}
};


void(vector org, entity death_owner) spawn_tdeath =
{
local entity	death;

	death = spawn();
	death.classname = "teledeath";
	death.movetype = MOVETYPE_NONE;
	death.solid = SOLID_TRIGGER;
	death.angles = '0 0 0';
	setsize (death, death_owner.mins - '1 1 1', death_owner.maxs + '1 1 1');
	setorigin (death, org);
	death.touch = tdeath_touch;
	death.nextthink = time + 0.2;
	death.think = SUB_Remove;
	death.owner = death_owner;
	
	force_retouch = 2;		// make sure even still objects get hit
};

entity() teleport_getdestination = {
	entity dests[256];
	entity d;
	float totaldests, i, nextdest;
	float maxdest, mindest;

	if (self.style == TELEPORT_STYLE_RANDOM) {

		d = find(world, targetname, self.target);
		while (d) {
			if (d.classname == "info_teleport_destination" && d.estate == STATE_ACTIVE) {
				dests[i] = d;
				i++;
				totaldests++;
			}
			d = find(d, targetname, self.target);
		}

		if (!totaldests) return world;

		i = floor(random() * (totaldests - 0.01));
		//dprint5("Found ", ftos(totaldests), " dests, returning ", ftos(i), "\n");
		return dests[i];
	}
	else if (self.style == TELEPORT_STYLE_CYCLE) {
		nextdest = 255;
		mindest = 255;
		
		d = find(world, targetname, self.target);
		while (d) {
			if (d.classname == "info_teleport_destination" && d.estate == STATE_ACTIVE) {
				if (dests[d.count]) {
					dprint3("trigger_teleport (", vtos((self.mins + self.maxs)*0.5), "): destinations with the same count order at:\n");
					dprint4(vtos(d.origin), " and ", vtos(dests[d.count].origin), "\n");
				}

				dests[d.count] = d;

				if (d.count > self.count && d.count < nextdest) nextdest = d.count;
				if (d.count < mindest) mindest = d.count;
				if (d.count > maxdest) maxdest = d.count;

				totaldests++;
			}
			d = find(d, targetname, self.target);
		}

		if (!totaldests) return world;

		if (self.count >= maxdest) nextdest = mindest;
		self.count = nextdest;
		return dests[nextdest];

	}
	else { // TELEPORT_STYLE_FIRST, default
		nextdest = 255;
		
		d = find(world, targetname, self.target);
		while (d) {
			if (d.classname == "info_teleport_destination" && d.estate == STATE_ACTIVE) {
				if (dests[d.count]) {
					dprint3("trigger_teleport (", vtos((self.mins + self.maxs)*0.5), "): destinations with the same count order at:\n");
					dprint4(vtos(d.origin), " and ", vtos(dests[d.count].origin), "\n");
				}

				dests[d.count] = d;

				if (d.count < nextdest) nextdest = d.count;
				totaldests++;
			}
			d = find(d, targetname, self.target);
		}

		if (!totaldests) return world;
		else return dests[nextdest];
	}
};

void() teleport_touch =
{
	local entity	t;
	local vector	org;
	local vector	tAngle, pAngle, outAngle;
	local float vAngleX;

	if (self.estate != STATE_ACTIVE)
		return;

	if (self.targetname)
	{
		if (self.nextthink < time)
		{
			return;		// not fired yet
		}
	}

	if (self.spawnflags & PLAYER_ONLY)
	{
		if (other.classname != "player")
			return;
	}

	if (self.targetname != "" && self.is_waiting != -1)	{
		if (self.nextthink < time)
			return;		// not fired yet
	}

	// only teleport living creatures
	if (other.health <= 0 || other.solid != SOLID_SLIDEBOX)
		return;

	SUB_UseTargets ();
	
	t = teleport_getdestination();
	if (!t) {
		dprint5("trigger_teleport (", vtos((self.mins + self.maxs)*0.5), ": couldn't find target \"", self.target, "\"\n");
		return;
	}
	// put a tfog where the player was
	if(!(self.spawnflags & TELE_STEALTH)) spawn_tfog (other.origin);

	// spawn a tfog flash in front of the destination
	
	tAngle = [t.mangle_x, t.mangle_y, 0];
	pAngle = [other.angles_x, other.angles_y, 0];

	if (t.spawnflags & 1){
		outAngle = tAngle + pAngle;
		vAngleX = other.v_angle_x;
	}
	else outAngle = tAngle;

	makevectors (outAngle);
	org = t.origin + 32 * v_forward;

	if(!(t.spawnflags & TELE_STEALTH)) spawn_tfog (org);
	spawn_tdeath(t.origin, other);

// move the player and lock him down for a little while
	if (!other.health)
	{
		other.origin = t.origin;
		other.velocity = (v_forward * other.velocity_x) + (v_forward * other.velocity_y);
		return;
	}

	setorigin (other, t.origin);
	
	other.angles = outAngle;

	if (other.classname == "player")
	{
		fog_setFromEnt(other, t);
		if (t.spawnflags & 1) other.angles_x = vAngleX; // reset vertical view angle, engine bug?

		other.fixangle = 1;		// turn this way immediately
		other.teleport_time = time + 0.7;
		if (other.flags & FL_ONGROUND)
			other.flags = other.flags - FL_ONGROUND;
		other.velocity = v_forward * 300;


	}
	other.flags = other.flags - other.flags & FL_ONGROUND;
};

/*QUAKED info_teleport_destination (.5 .5 .5) (-8 -8 -8) (8 8 32)
This is the destination marker for a teleporter.  It should have a "targetname" field with the same value as a teleporter's "target" field.
*/
void() info_teleport_destination =
{
// this does nothing, just serves as a target spot
	self.mangle = self.angles;
	self.angles = '0 0 0';
	self.model = "";
	self.origin = self.origin + '0 0 27';
	if (!self.targetname)
		objerror ("no targetname");
};

void() teleport_use =
{
	self.nextthink = time + 0.2;
	force_retouch = 2;		// make sure even still objects get hit
	self.think = SUB_Null;
};

/*QUAKED trigger_teleport (.5 .5 .5) ? PLAYER_ONLY SILENT
Any object touching this will be transported to the corresponding info_teleport_destination entity. You must set the "target" field, and create an object with a "targetname" field that matches.

If the trigger_teleport has a targetname, it will only teleport entities when it has been fired.
*/
void() trigger_teleport =
{
	local vector o;

	InitTrigger ();
	self.touch = teleport_touch;
	// find the destination 
	if (!self.target)
		objerror ("no target");
	self.use = teleport_use;

	self.count = -1;
	if (!(self.spawnflags & SILENT))
	{
		precache_sound ("ambience/hum1.wav");
		o = (self.mins + self.maxs)*0.5;
		ambientsound (o, "ambience/hum1.wav",0.5 , ATTN_STATIC);
	}

	SUB_CheckWaiting();
};


void() trigger_test_touch = {
	if (other.classname == "player"){
		other.fixangle = 1;
		other.angles_x = 45;

	}
}

void() trigger_test = {
	InitTrigger();
	self.touch = trigger_test_touch;
}
/*
==============================================================================

trigger_setskill

==============================================================================
*/

void() trigger_skill_touch =
{
	if (self.estate != STATE_ACTIVE) return;

	if (other.classname != "player")
		return;
		
	cvar_set ("skill", self.message);
};

//johnfitz -- make it targetable
void() trigger_skill_use =
{
	if (activator.classname != "player")
		return;
		
	trigger_skill_touch();
};
//johnfitz

/*QUAKED trigger_setskill (.5 .5 .5) ?
sets skill level to the value of "message".
Only used on start map.
*/
void() trigger_setskill =
{
	InitTrigger ();
	self.touch = trigger_skill_touch;
	self.use = trigger_skill_use; //johnfitz -- make it targetable

	SUB_CheckWaiting();
};


/*
==============================================================================

ONLY REGISTERED TRIGGERS

==============================================================================
*/

void() trigger_onlyregistered_touch =
{
	if (other.classname != "player")
		return;
	if (self.attack_finished > time)
		return;

	if (self.estate != STATE_ACTIVE)
		return;

	self.attack_finished = time + 2;
	if (cvar("registered"))
	{
		self.message = "";
		SUB_UseTargets ();
		remove (self);
	}
	else
	{
		if (self.message != "")
		{
			centerprint (other, self.message);
			sound (other, CHAN_BODY, "misc/talk.wav", 1, ATTN_NORM);
		}
	}
};

/*QUAKED trigger_onlyregistered (.5 .5 .5) ?
Only fires if playing the registered version, otherwise prints the message
*/
void() trigger_onlyregistered =
{
	precache_sound ("misc/talk.wav");
	InitTrigger ();
	self.touch = trigger_onlyregistered_touch;

	SUB_CheckWaiting();
};

/*
==============================================================================

trigger_hurt

==============================================================================
*/

void() hurt_on =
{
	self.solid = SOLID_TRIGGER;
	self.nextthink = -1;
};

void() hurt_touch =
{
	if (self.estate != STATE_ACTIVE)
		return;

	if (other.takedamage)
	{
		self.solid = SOLID_NOT;
		T_Damage (other, self, self, self.dmg);
		self.think = hurt_on;
		self.nextthink = time + self.wait;
	}

};

/*QUAKED trigger_hurt (.5 .5 .5) ?
Any object touching this will be hurt
set dmg to damage amount
defalt dmg = 5
*/
void() trigger_hurt =
{
	InitTrigger ();
	self.touch = hurt_touch;
	if(!self.wait) self.wait = 1;
	if (!self.dmg)
		self.dmg = 5;

	SUB_CheckWaiting();
};

/*
==============================================================================

trigger_push

==============================================================================
*/

float PUSH_ONCE = 1;
float PUSH_SILENT = 2;

void() trigger_push_touch =
{
	if (self.estate != STATE_ACTIVE)
		return;

	if (other.classname == "grenade")
		other.velocity = self.speed * self.movedir * 10;
	else if (other.health > 0)
	{
		other.velocity = self.speed * self.movedir * 10;
		if (other.classname == "player" && !(self.spawnflags & PUSH_SILENT))
		{
			if (other.fly_sound < time)
			{
				other.fly_sound = time + self.delay;
				sound (other, CHAN_AUTO, self.noise, 1, ATTN_NORM);
			}
		}
	}
	if (self.spawnflags & PUSH_ONCE)
		remove(self);
};


/*QUAKED trigger_push (.5 .5 .5) ? PUSH_ONCE PUSH_SILENT
Pushes the player
*/
void() trigger_push =
{
	InitTrigger ();
	
	if(!self.noise)
		self.noise = "ambience/windfly.wav";

	if(!self.delay)
		self.delay = 1.5;

	if(!(self.spawnflags & PUSH_SILENT)) precache_sound (self.noise);
	
	self.touch = trigger_push_touch;
	
	if (!self.speed)
		self.speed = 1000;

	SUB_CheckWaiting();
};

/*
==============================================================================

trigger_monsterjump

==============================================================================
*/

void() trigger_monsterjump_touch =
{
	if (self.estate != STATE_ACTIVE)
		return;

	if(!self.count)
		return;

	if ( other.flags & (FL_MONSTER | FL_FLY | FL_SWIM) != FL_MONSTER )
		return;

	if (self.include && other.classname != self.include)
		return;

	if (self.exclude && other.classname == self.exclude)
		return;

	// set XY even if not on ground, so the jump will clear lips
	other.velocity_x = self.movedir_x * self.speed;
	other.velocity_y = self.movedir_y * self.speed;
	
	if ( !(other.flags & FL_ONGROUND) )
		return;
	
	other.flags = other.flags - FL_ONGROUND;
	other.velocity_z = self.height;
	
	if(self.count > 0) self.count--;
};

/*QUAKED trigger_monsterjump (.5 .5 .5) ?
Walking monsters that touch this will jump in the direction of the trigger's angle
"speed" default to 200, the speed thrown forward
"height" default to 200, the speed thrown upwards
*/
void() trigger_monsterjump =
{
	if (!self.speed)
		self.speed = 200;
	if (!self.height)
		self.height = 200;
	if (self.angles == '0 0 0')
		self.angles = '0 360 0';
	if(!self.count)
		self.count = -1;
	InitTrigger ();
	self.touch = trigger_monsterjump_touch;

	SUB_CheckWaiting();
};


/*
==============================================================================

trigger_void

==============================================================================
*/

float 	MONSTER_SAFE = 1;
float 	PLAYER_SAFE = 2;

void() trigger_void_touch =
{	
	// back out if trigger is inactive
	if (self.estate != STATE_ACTIVE)
		return;

	// ignore monsters if spawnflag is set
	if (self.spawnflags & MONSTER_SAFE && other.flags & FL_MONSTER && other.health > 0)
		return;

	// ignore players if spawnflag is set
	if (self.spawnflags & PLAYER_SAFE && other.flags & FL_CLIENT)
		return; 
	
	// ignore noclipping player
	if (other.movetype == MOVETYPE_NOCLIP)
		return;

	// swallows weapon projectiles and general gibs
	if (
		other.classname == "gib" ||
		other.classname == "grenade" ||
		other.classname == "spike" ||
		other.classname == "missile" ||
		(other.flags & FL_PROJECTILE)
	) {
		remove(other);
		return;
	}

	// swallows items
	if (other.flags & FL_ITEM){
		remove(other);
		return;
	}

	if (other.flags & FL_MONSTER && other.health <= 0){
		entity_hide(other);
		return;
	}
	// tries to kills anything that can be killed
	if (other.takedamage) {
		// don't try to damage shootable bmodels like doors, buttons or breakables
		if (other.solid == SOLID_BSP)
			return;

		if (other.flags & FL_CLIENT) {
			other.invincible_finished = 0; // kills even with Pentagram, this took forever to figure out!! -- dumptruck_ds
			other.trif_finished = 0;
		}

		T_Damage (other, self, self, other.health + 1000);
		
		// moved the following check to the Killed function
		//if (other.flags & FL_MONSTER)
		//	remove(other);
	}

};

/*QUAKED trigger_void (.5 .5 .5) ? X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
Use this for a 'void' area.  removes monsters, gibs, ammo, etc...  also kills player.
*/
void() trigger_void =
{
	InitTrigger ();
	self.touch = trigger_void_touch;

	SUB_CheckWaiting();
};





/*
=============================================================

trigger_removeitems / target_removeitems

=============================================================
*/

void(entity plr, float removeditems, float removedweapons) removeitems_go = {
	local entity oself;

	if(plr.classname != "player")
		return;

	oself = self;
	self = plr;

	self.items -= self.items & removeditems;
	self.items -= self.items & removedweapons & HUD_WEAPONS;
	self.weapons -= self.weapons & removedweapons;

	if(!(self.weapons & self.weapon)) { //if player is wielding a removed weapon
		self.weapon = W_BestWeapon();
	}

	W_SetCurrentAmmo();

	self = oself;

};

void() trigger_removeitems_touch = {

	if(!self.count)
		return;
	if (self.estate != STATE_ACTIVE)
		return;

	removeitems_go (other, self.items, self.weapons);

	if(self.count > 0)
		self.count--;
};

void() trigger_removeitems = {
	InitTrigger();

	self.touch = trigger_removeitems_touch;
	
	if(!self.count)
		self.count = 1;

	SUB_CheckWaiting();
};


void() target_removeitems_use = {

	if(!self.count)
		return;

	if (self.estate != STATE_ACTIVE)
		return;

	removeitems_go (activator, self.items, self.weapons);

	if(self.count > 0)
		self.count--;
};

void() target_removeitems = {

	self.use = target_removeitems_use;
	
	if(!self.count)
		self.count = -1;
};


/*
=============================================================

trigger_repeat

=============================================================
*/

void() trigger_repeat_think = {
	if(self.count > 0 && self.cnt <= 0) // has limited uses and has reached 0
		return;

	SUB_UseTargets();

	self.think = trigger_repeat_think;

	if(self.count > 0) {
		self.cnt--;
		if(self.cnt <= 0) {
			self.state = STATE_INACTIVE;
			self.nextthink = -1;
		}
		else self.nextthink = time + self.wait;
	}
	else self.nextthink = time + self.wait;
};

void() trigger_repeat_use = {
	if(self.state == STATE_INACTIVE) {
		if(!(self.spawnflags & 1)) self.cnt = self.count;
		trigger_repeat_think();
		self.state = STATE_ACTIVE;
	}
	else {
		self.nextthink = -1;
		self.state = STATE_INACTIVE;
	}
};

void() trigger_repeat = {
	if(!self.wait) self.wait = 2;

	self.cnt = self.count; //.cnt is the internal counter
	self.state = STATE_INACTIVE;
	self.use = trigger_repeat_use;
};


/*
=============================================================

target_setstate

=============================================================
*/
float SETSTATE_CLOSEALLDOORS = 2;
float SETSTATE_DONTRESETBUTTON = 4;

float(entity e) entity_get_state = {
	if(e.classname == "func_door") return e.owner.estate;
	else return e.estate;
};

void(entity e, float state, float flags) entity_set_state = {
	float closealldoors;

	if(e.classname == "func_button") {
		if (state == STATE_ACTIVE) button_unlock(e, flags & SETSTATE_DONTRESETBUTTON);
		else button_lock(e);
	}
	else if(e.classname == "func_door") {
		if (flags & SETSTATE_CLOSEALLDOORS) closealldoors = 1;

		if (state == STATE_ACTIVE) door_estate_unlock(e, closealldoors);
		else door_estate_lock(e, closealldoors);
	}
	else e.estate = state;

	if (e.is_waiting > 0 && state == STATE_ACTIVE) {
		SUB_CallAsSelf(SUB_EndWaiting, e);
	}

	//if (e.touch && e.touch != SUB_Null) {
	//	force_retouch = 2;
	//}
};

void(string matchstring, .string matchfield, float state, float flags) target_setstate_set_target = {
	local entity t;

	t = find (world, matchfield, matchstring);
	while (t != world) {
		if(state == -1){
			if(entity_get_state(t) == STATE_ACTIVE) entity_set_state(t, STATE_INACTIVE, flags);
			else entity_set_state(t, STATE_ACTIVE, flags);
		}
		else entity_set_state(t, state, flags);

		t = find (t, matchfield, matchstring);
	}
};

void(float state) target_setstate_set_alltargets = {
	if (self.target && self.target != "") {
		target_setstate_set_target(self.target, targetname, state, self.spawnflags);
		target_setstate_set_target(self.target, targetname2, state, self.spawnflags);
	}
	if (self.target2 && self.target2 != "") {
		target_setstate_set_target(self.target2, targetname, state, self.spawnflags);
		target_setstate_set_target(self.target2, targetname2, state, self.spawnflags);
	}
	if (self.target3 && self.target3 != "") {
		target_setstate_set_target(self.target3, targetname, state, self.spawnflags);
		target_setstate_set_target(self.target3, targetname2, state, self.spawnflags);
	}
	if (self.target4 && self.target4 != "") {
		target_setstate_set_target(self.target4, targetname, state, self.spawnflags);
		target_setstate_set_target(self.target4, targetname2, state, self.spawnflags);
	}
};

void() target_setstate_use = {
	local float state;

	if (self.style == 1) state = STATE_ACTIVE;
	else if (self.style == 2) state = STATE_INACTIVE;
	else state = -1;

	target_setstate_set_alltargets(state);

};

void() target_setstate_startoff_think = {
	if (door_setup_finished) target_setstate_set_alltargets(STATE_INACTIVE);
	else {
		// not finished yet? wait a bit longer
		self.think = target_setstate_startoff_think;
		self.nextthink = time + 0.1;
	}
};

void() target_setstate = {
	self.use = target_setstate_use;

	if(self.spawnflags & START_OFF) {
		// wait a bit while doors finish being set up
		self.think = target_setstate_startoff_think;
		self.nextthink = time + 0.5;
	}
};

/*
=============================================================

trigger_filter

=============================================================
*/


float FILTER_FIELD_STATE = 0;
float FILTER_FIELD_HEALTH = 1;
float FILTER_FIELD_WEAPON = 2;
float FILTER_FIELD_FLAGS = 3;
float FILTER_FIELD_SPAWNFLAGS = 4;
float FILTER_FIELD_CLASSNAME = 5;
float FILTER_FIELD_ESTATE = 6;
float FILTER_FIELD_DOOR_GROUPSTATE = 7;
float FILTER_FIELD_TARGETNAME = 8;
float FILTER_FIELD_WEAPONS = 9;
float FILTER_FIELD_ITEMS = 10;
float FILTER_FIELD_COUNT = 11;
float FILTER_FIELD_CNT = 12;
float FILTER_FIELD_TYPE = 13;


float FILTER_FIELDTYPE_FLOAT = 0;
float FILTER_FIELDTYPE_STRING = 1;
float FILTER_FIELDTYPE_FLAG = 2;

float FILTER_OP_EQUALS = 0;
float FILTER_OP_LT = 1;
float FILTER_OP_LTE = 2;
float FILTER_OP_GT = 3;
float FILTER_OP_GTE = 4;
float FILTER_OP_BITMASK_AND = 5;
float FILTER_OP_BITMASK_OR = 6;

void() trigger_filter_use = {
	self.state = 0;

	if (self.estate != STATE_ACTIVE) return;

	entity targ;
	float targfloat;
	string targstring;

	float fieldtype, op, result;

	if (self.include != "") {
		targ = find(world, targetname, self.include);
		if (!targ) targ = find(world, targetname2, self.include);
		if (!targ) return;
	}
	else
		targ = activator;

	op = self.weapon;

	switch (self.style) {
		case FILTER_FIELD_STATE:
			fieldtype = FILTER_FIELDTYPE_FLOAT;
			targfloat = targ.state;
			break;

		case FILTER_FIELD_ESTATE:
			fieldtype = FILTER_FIELDTYPE_FLOAT;
			targfloat = targ.estate;
			break;

		case FILTER_FIELD_HEALTH:
			fieldtype = FILTER_FIELDTYPE_FLOAT;
			targfloat = targ.health;
			break;

		case FILTER_FIELD_COUNT:
			fieldtype = FILTER_FIELDTYPE_FLOAT;
			targfloat = targ.count;
			break;

		case FILTER_FIELD_CNT:
			fieldtype = FILTER_FIELDTYPE_FLOAT;
			targfloat = targ.cnt;
			break;

		case FILTER_FIELD_WEAPON:
			fieldtype = FILTER_FIELDTYPE_FLOAT;
			targfloat = targ.weapon;
			break;

		case FILTER_FIELD_FLAGS:
			fieldtype = FILTER_FIELDTYPE_FLAG;
			targfloat = targ.flags;
			break;

		case FILTER_FIELD_SPAWNFLAGS: 
			fieldtype = FILTER_FIELDTYPE_FLAG;
			targfloat = targ.spawnflags;
			break;

		case FILTER_FIELD_ITEMS:
			fieldtype = FILTER_FIELDTYPE_FLAG;
			targfloat = targ.items;
			break;

		case FILTER_FIELD_WEAPONS:
			fieldtype = FILTER_FIELDTYPE_FLAG;
			targfloat = targ.weapons;
			break;

		case FILTER_FIELD_CLASSNAME:
			fieldtype = FILTER_FIELDTYPE_STRING;
			targstring = targ.classname;
			break;

		case FILTER_FIELD_DOOR_GROUPSTATE:
			fieldtype = FILTER_FIELDTYPE_FLOAT;
			targfloat = targ.owner.groupstate;
			break;

		case FILTER_FIELD_TARGETNAME:
			fieldtype = FILTER_FIELDTYPE_STRING;
			targstring = targ.targetname;
			break;

		case FILTER_FIELD_TYPE:
			fieldtype = FILTER_FIELDTYPE_STRING;
			targstring = targ.type;
			break;
	}

	if (fieldtype == FILTER_FIELDTYPE_FLOAT) {
		if 		(op == FILTER_OP_EQUALS) 		{if (targfloat == self.count) result = 1;}
		else if (op == FILTER_OP_LT) 			{if (targfloat <  self.count) result = 1;}
		else if (op == FILTER_OP_LTE) 			{if (targfloat <= self.count) result = 1;}
		else if (op == FILTER_OP_GT) 			{if (targfloat >  self.count) result = 1;}
		else if (op == FILTER_OP_GTE) 			{if (targfloat >= self.count) result = 1;}
		else if (op == FILTER_OP_BITMASK_AND)	{if (targfloat &  self.count) result = 1;}
		else if (op == FILTER_OP_BITMASK_OR)	{if (targfloat |  self.count) result = 1;}
		else 									{if (targfloat == self.count) result = 1;}
	}
	else if (fieldtype == FILTER_FIELDTYPE_FLAG) {
		if 		(op == FILTER_OP_EQUALS) 		{if (targfloat == self.aflag) result = 1;}
		else if (op == FILTER_OP_BITMASK_AND)	{if (targfloat &  self.aflag) result = 1;}
		else if (op == FILTER_OP_BITMASK_OR)	{if (targfloat |  self.aflag) result = 1;}
		else 									{if (targfloat == self.aflag) result = 1;}
	}
	else if (fieldtype == FILTER_FIELDTYPE_STRING) {

		if (targstring == self.type) result = 1;
	}
	else {
		objerror ("invalid fieldtype");
		return;
	}

	if (self.spawnflags & 1) result = 1 - result; // negate

	if (result) {
		self.state = 1;

		if (self.spawnflags & 2 && activator.owner) activator = activator.owner; // relay activator as owner

		SUB_UseTargets();
		if (other.classname == "trigger_everything" && other.spawnflags & 1) {
			if (other.wait)	other.attack_finished = time + other.wait;
		}

	}
};

void() trigger_filter = {
	self.use = trigger_filter_use;

};


/*
=============================================================

trigger_everything

=============================================================
*/

void() trigger_everything_touch = {
	if (self.estate != STATE_ACTIVE) return;

	if (time < self.attack_finished) return;

	activator = other;
	
	SUB_UseSpecificTarget(self.target, targetname);

	if (self.wait)
		if (!(self.spawnflags & 1)) self.attack_finished = time + self.wait;

};

void() trigger_everything = {
	InitTrigger();

	self.touch = trigger_everything_touch;
	SUB_CheckWaiting();
};


/*
=============================================================

target_setcount

=============================================================
*/

void(string name, .string fld) target_setcount_set = {
	local entity t;

	t = find(world, fld, name);

	while (t) {
		if (self.style == 1)
			t.count += self.count;
		else
			t.count = self.count;

		t = find(t, fld, name);
	}
};

void() target_setcount_use = {
	if (self.target && self.target != "") {
		target_setcount_set(self.target, targetname);
		target_setcount_set(self.target, targetname2);
	}
	if (self.target2 && self.target2 != "") {
		target_setcount_set(self.target2, targetname);
		target_setcount_set(self.target2, targetname2);
	}
	if (self.target3 && self.target3 != "") {
		target_setcount_set(self.target3, targetname);
		target_setcount_set(self.target3, targetname2);
	}
	if (self.target4 && self.target4 != "") {
		target_setcount_set(self.target4, targetname);
		target_setcount_set(self.target4, targetname2);
	}
};

void() target_setcount = {
	self.use = target_setcount_use;

};


/*
=============================================================

target_setsize

=============================================================
*/

void(string name, .string fld) target_setsize_set = {
	local entity t;

	t = find(world, fld, name);

	while (t) {
		if (t.mins != self.cmins || t.maxs != self.cmaxs)
			setsize(t, self.cmins, self.cmaxs);

		t = find(t, fld, name);
	}
};

void() target_setsize_use = {
	if (self.target && self.target != "") {
		target_setsize_set(self.target, targetname);
		target_setsize_set(self.target, targetname2);
	}
	if (self.target2 && self.target2 != "") {
		target_setsize_set(self.target2, targetname);
		target_setsize_set(self.target2, targetname2);
	}
	if (self.target3 && self.target3 != "") {
		target_setsize_set(self.target3, targetname);
		target_setsize_set(self.target3, targetname2);
	}
	if (self.target4 && self.target4 != "") {
		target_setsize_set(self.target4, targetname);
		target_setsize_set(self.target4, targetname2);
	}

	if (self.spawnflags & 1) {
		if (activator.mins != self.cmins || activator.maxs != self.cmaxs)
			setsize(activator, self.cmins, self.cmaxs);
	}
};

void() target_setsize = {
	self.use = target_setsize_use;

};