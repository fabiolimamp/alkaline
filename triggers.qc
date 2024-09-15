
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
void() multi_trigger = {

	if (self.nextthink > time)
		return;		// already been triggered

	if (self.estate != STATE_ACTIVE)
		return;

	if (self.mapvar && !read_mapvar(self.mapvar))
		return;

	if (self.classname == "trigger_secret")
	{
		if (self.enemy.classname != "player")
			return;
		found_secrets = found_secrets + 1;
		WriteByte (MSG_ALL, SVC_FOUNDSECRET);
	}

	if (self.noise) {
		if (self.enemy.flags & FL_CLIENT)
			sound (self.enemy, CHAN_VOICE, self.noise, 1, ATTN_NORM);
		else
			sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	}

	// don't trigger again until reset
	self.takedamage = DAMAGE_NO;

	activator = self.enemy;
	
	SUB_UseTargets();

	if (self.wait > 0) {
		self.think = multi_wait;
		self.nextthink = time + self.wait;
	}
	else {
		// we can't just remove (self) here, because this is a touch function
		// called wheil C code is looping through area links...
		self.touch = SUB_Null;
		self.nextthink = time + 0.1;
		self.think = SUB_Remove;
	}

	if (self.count > 0) {
		self.count -= 1;
		if (self.count == 0) {
			remove(self);
			return;
		}
	}
};

void() multi_killed = //dumptruck_ds
{
	if (self.estate != STATE_ACTIVE) { //restore health and do nothing if trigger is disabled
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

	if (self.mapvar && !read_mapvar(self.mapvar))
		return;

	// if the trigger has an angles field, check player's facing direction.
	// view_ofs sets the cone angle
	if (self.movedir != '0 0 0')
	{
		vector cone = self.view_ofs;

		if (cone == '0 0 0') 
			cone = '90 90 0';

		if (!isInAngle([-other.v_angle_x, other.v_angle_y, other.v_angle_z], self.mangle, cone))
			return;
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
	
	if (!SUB_InitEntity()) return;
	
	if (self.noise == "") {
		if (self.sounds == 1)
			self.noise = "misc/secret.wav";
		else if (self.sounds == 2)
			self.noise = "misc/talk.wav";
		else if (self.sounds == 3)
			self.noise = "misc/trigger1.wav";
	}

	if (self.noise != "")
		precache_sound(self.noise);

	if (!self.wait)
		self.wait = 0.2;

	self.use = multi_use;

	InitTrigger();

	if (self.health) {
		if (self.spawnflags & SPAWNFLAG_NOTOUCH)
			objerror ("health and notouch don't make sense\n");

		self.max_health = self.health;
		self.th_die = multi_killed;
		self.takedamage = DAMAGE_YES;
		self.solid = SOLID_BBOX;
		setorigin(self, self.origin);	// make sure it links into the world
	}
	else {
		if (!(self.spawnflags & SPAWNFLAG_NOTOUCH)) 
			self.touch = multi_touch;
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

	if (!SUB_InitEntity()) return;
	
	self.wait = -1;
	trigger_multiple();
};

//=============================================================================

/*QUAKED trigger_relay (.5 .5 .5) (-8 -8 -8) (8 8 8)
This fixed size trigger cannot be touched, it can only be fired by other events.  It can contain killtargets, targets, delays, and messages.
*/

float RELAY_AUTO = 1;
float RELAY_ALWAYSPLAYER = 2;
float RELAY_PLAYERONLY = 4;

void() trigger_relay_use = {

	if (self.estate != STATE_ACTIVE)
		return;

	if (time < self.attack_finished)
		return;

	if (self.mapvar && !read_mapvar(self.mapvar))
		return;

	if (self.spawnflags & RELAY_AUTO) {
		self.spawnflags &~= RELAY_AUTO;
		dprint3("trigger_relay fired on map start at ", vtos(self.origin), "\n");
	}

	if (self.spawnflags & RELAY_ALWAYSPLAYER && !(activator.flags & FL_CLIENT)) {
		entity closest;
		closest = findClosest(self.origin, classname, "player", 1);
		if (!closest) closest = findClosest(self.origin, classname, "player", 0);
		if (closest) activator = closest;
	} 

	if (self.spawnflags & RELAY_PLAYERONLY && !(activator.flags & FL_CLIENT))
		return;

	entity t;
	if (self.noise) {
		if (self.spawnflags & TRIGGER_CENTERPRINTALL) {
			t = find(world, classname, "player");
			while (t) {
				sound (t, CHAN_VOICE, self.noise, 1, ATTN_NORM);
				t = find(t, classname, "player");
			}
		}
		else if (self.enemy.flags & FL_CLIENT)
			sound (self.enemy, CHAN_VOICE, self.noise, 1, ATTN_NORM);
		else
			sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	}

	SUB_UseTargets();
	
	if (self.count > 0) {
		self.count -= 1;
		if (self.count == 0)
			remove(self);
	}

	if (self.wait) {
		self.attack_finished = time + self.wait;
	}
}

void() trigger_relay =
{
	if (!SUB_InitEntity()) return;
	
	// Spawnflag 8192: Not in Nightmare
	if (self.spawnflags & 8192 && startskill == SKILL_NIGHTMARE)
		remove(self);

	// Spawnflag 4096: Not in Hard
	// Needed a change because the engine removes it for both Hard *and* Nightmare if the original 1024 spawnflag is on
	if (self.spawnflags & 4096 && startskill == SKILL_HARD)
		remove(self);

	if (self.noise == "") {
		if (self.sounds == 1)
			self.noise = "misc/secret.wav";
		else if (self.sounds == 2)
			self.noise = "misc/talk.wav";
		else if (self.sounds == 3)
			self.noise = "misc/trigger1.wav";
	}

	if (self.noise != "") precache_sound(self.noise);

	self.use = trigger_relay_use;
	
	// Spawnflag 1: fire automatically on map start
	if (self.spawnflags & 1) {
		self.think = trigger_relay_use;
		self.nextthink = time + 0.5;
	}
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
	if (!SUB_InitEntity()) return;
	
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

float COUNTER_RESET = 2;

void() counter_use =
{
//	local string junk;

	if (self.estate != STATE_ACTIVE) return;

	if (self.mapvar && !read_mapvar(self.mapvar))
		return;
	
	if (self.count <= 0)
		return;

	self.count--;
	
	if (self.count > 0)	{
		if (activator.classname == "player"	&& (self.spawnflags & SPAWNFLAG_NOMESSAGE) == 0) {
			if (self.count >= 6)
				centerprint (activator, "There are more to go ...");
			else if (self.count == 5)
				centerprint (activator, "There are 5 more to go ...");
			else if (self.count == 4)
				centerprint (activator, "There are 4 more to go ...");
			else if (self.count == 3)
				centerprint (activator, "There are 3 more to go ...");
			else if (self.count == 2)
				centerprint (activator, "Only 2 more to go...");
			else
				centerprint (activator, "Only 1 more to go...");
		}
		return;
	}
	
	if (activator.classname == "player" && (self.spawnflags & SPAWNFLAG_NOMESSAGE) == 0)
		centerprint(activator, "Sequence completed!");

	self.enemy = activator;
	SUB_UseTargets();

	if (self.spawnflags & COUNTER_RESET)
		self.count = self.bubble_count;
};

/*QUAKED trigger_counter (.5 .5 .5) (-8 -8 -8) (8 8 8) nomessage
Acts as an intermediary for an action that takes multiple inputs.

If nomessage is not set, t will print "1 more.. " etc when triggered and "sequence complete" when finished.

After the counter has been triggered "count" times (default 2), it will fire all of it's targets and remove itself.
*/
void() trigger_counter =
{
	if (!SUB_InitEntity()) return;
	
	self.wait = -1;
	if (!self.count)
		self.count = 2;

	if (!self.bubble_count) self.bubble_count = self.count; // store the initial count amount
	self.use = counter_use;
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
	
	if (self.mapvar && !read_mapvar(self.mapvar)) return;

	if (other.classname != "player")
		return;
		
	cvar_set("skill", self.message);
	skill = cvar("skill");
};

//johnfitz -- make it targetable
void() trigger_skill_use =
{
	if (activator.classname != "player")
		return;
	
	other = activator;
	trigger_skill_touch();
};
//johnfitz

/*QUAKED trigger_setskill (.5 .5 .5) ?
sets skill level to the value of "message".
Only used on start map.
*/
void() trigger_setskill =
{
	if (!SUB_InitEntity()) return;
	
	InitTrigger ();
	self.touch = trigger_skill_touch;
	self.use = trigger_skill_use; //johnfitz -- make it targetable

	SUB_CheckWaiting();
};


void() target_setskill_use = {
	if (self.estate != STATE_ACTIVE) return;
	if (self.mapvar && !read_mapvar(self.mapvar)) return;

	cvar_set("skill", self.message);
	skill = cvar("skill");
}

void() target_setskill = {
	if (!SUB_InitEntity()) return;

	self.use = target_setskill_use;
}

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

	if (self.mapvar && !read_mapvar(self.mapvar))
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
	if (!SUB_InitEntity()) return;
	
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


void() hurt_retouch = {
	force_retouch = 2;
}

void() hurt_touch =
{
	if (self.estate != STATE_ACTIVE)
		return;
	if (self.mapvar && !read_mapvar(self.mapvar))
		return;
	if (self.spawnflags & 1 && other.flags & FL_CLIENT)
		return;
	
	if (self.spawnflags & 2 && other.flags & FL_MONSTER)
		return;

	if (time < other.hurt_started + self.wait)
		return;

	if (other.takedamage) {
		T_Damage(other, self, self, self.dmg, self.style);
		other.hurt_started = time;
	}

	// From Copper:
	// this is not ideal but all the other solutions are also not ideal: monsters
	// who stand still in a trigger hurt don't catch the trigger, so (for example)
	// enforcers who plant and open fire will be immune to the hurt as long as they
	// stay in one place
	if (other.flags & FL_MONSTER && other.health > 0) {
		// so we have to ask the engine to spam a collision test of everything vs
		// everything else to catch them
		self.think = hurt_retouch;
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
	if (!SUB_InitEntity()) return;
	
	InitTrigger();
	self.touch = hurt_touch;
	if(!self.wait) self.wait = 1;
	if (!self.dmg)
		self.dmg = 5;

	// monsters won't react to this attack
	self.flags |= FL_IGNOREDATTACK;
	SUB_CheckWaiting();
};

/*
==============================================================================

target_hurt

==============================================================================
*/

void() hurt_think = {
	if (self.owner.health <= 0 || self.attack_finished < time) {
		if (self.attack_finished < time) {
			if (self.dmg_save < self.dmg) 
				T_Damage(self.owner, self.enemy, self.enemy, self.dmg - self.dmg_save, self.style);
		}
		self.owner.hurtcontroller = world;
		remove(self);
		return;
	}

	self.dmg_take += self.dmg / self.delay / 20;
	float take;

	if (fabs(self.dmg_take) >= 1) {

		if (self.dmg_take < 0) {
			take = ceil(self.dmg_take);
			self.owner.health -= take;
		}
		else {
			take = floor(self.dmg_take);
			T_Damage(self.owner, self.enemy, self.enemy, take, self.style);
		}
		
		self.dmg_save += take;
		
		self.dmg_take = self.dmg_take % take;
	}
	self.nextthink = time + 0.05;
};

void(entity tgt, float totaldmg, float duration, float dmgtype) hurt_start = {
	entity controller;
	if (self.spawnflags & 1 && tgt.flags & FL_CLIENT)
		return;
	
	if (self.spawnflags & 2 && tgt.flags & FL_MONSTER)
		return;

	if (!tgt.takedamage || tgt.health <= 0)
		return;

	if (!tgt.hurtcontroller ||
		tgt.hurtcontroller.classname != "hurt_controller" ||
		tgt.hurtcontroller.enemy != self
	) {
		if (tgt.hurtcontroller) remove(tgt.hurtcontroller);

		controller = spawn();
		controller.owner = tgt;
		controller.enemy = self;
		controller.classname = "hurt_controller";
		tgt.hurtcontroller = controller;

		controller.attack_finished = time + duration;
		controller.dmg = totaldmg;
		controller.delay = duration;
		controller.style = dmgtype;

		controller.think = hurt_think;
		controller.nextthink = time + 0.05;
	}

};

void(string name, .string fld) hurt_find = {
	local entity t;

	t = find(world, fld, name);

	while (t) {
		hurt_start(t, self.dmg, self.speed, self.style);

		t = find(t, fld, name);
	}
}

void() hurt_use = {
	if (self.estate != STATE_ACTIVE)
		return;
	if (self.mapvar && !read_mapvar(self.mapvar))
		return;
	float has_target;

	if (self.target && self.target != "") {
		hurt_find(self.target, targetname);
		hurt_find(self.target, targetname2);
		has_target = TRUE;
	}
	if (self.target2 && self.target2 != "") {
		hurt_find(self.target2, targetname);
		hurt_find(self.target2, targetname2);
		has_target = TRUE;
	}
	if (self.target3 && self.target3 != "") {
		hurt_find(self.target3, targetname);
		hurt_find(self.target3, targetname2);
		has_target = TRUE;
	}
	if (self.target4 && self.target4 != "") {
		hurt_find(self.target4, targetname);
		hurt_find(self.target4, targetname2);
		has_target = TRUE;
	}

	if (!has_target) {
		hurt_start(activator, self.dmg, self.speed, self.style);
	}


}

void() target_hurt = {
	if (!SUB_InitEntity()) return;
	
	self.use = hurt_use;
};

/*
==============================================================================

target_heal

==============================================================================
*/
 

void() heal_think = {
	/*
	dmg_save -> amount of healing left to do
	dmg_take -> amount of healing already done
	healamount -> total heal
	*/
	if (self.owner.health <= 0 || self.attack_finished < time || self.owner.health >= self.owner.max_health) {
		// make sure target health is reached at the last tic
		if (self.attack_finished < time) {
			if (self.dmg_save < self.healamount)
				self.owner.health += self.healamount - self.dmg_save;
		}

		self.owner.hurtcontroller = world;
		remove(self);
		return;
	}

	self.dmg_take += self.healamount / self.delay / 20;
	float take;

	if (fabs(self.dmg_take) >= 1) {

		if (self.dmg_take < 0) {
			take = ceil(self.dmg_take);
			self.owner.health += take;
		}
		else {
			take = floor(self.dmg_take);
			self.owner.health += take;
		}
		
		self.dmg_save += take;
		
		self.dmg_take = self.dmg_take % take;
	}
	self.nextthink = time + 0.05;
};

void(entity tgt, float totalheal, float duration) heal_start = {
	entity controller;
	if (self.spawnflags & 1 && tgt.flags & FL_CLIENT)
		return;
	
	if (self.spawnflags & 2 && tgt.flags & FL_MONSTER)
		return;

	if (tgt.health <= 0)
		return;

	if (!tgt.hurtcontroller ||
		tgt.hurtcontroller.classname != "hurt_controller" ||
		tgt.hurtcontroller.enemy != self
	) {
		if (tgt.hurtcontroller) remove(tgt.hurtcontroller);

		controller = spawn();
		controller.owner = tgt;
		controller.enemy = self;
		controller.classname = "hurt_controller";
		tgt.hurtcontroller = controller;

		controller.attack_finished = time + duration;
		controller.healamount = totalheal;
		controller.delay = duration;

		controller.think = heal_think;
		controller.nextthink = time + 0.05;
	}

};

void(string name, .string fld) heal_find = {
	local entity t;

	t = find(world, fld, name);

	while (t) {
		heal_start(t, self.healamount, self.speed);

		t = find(t, fld, name);
	}
}

void() heal_use = {
	if (self.estate != STATE_ACTIVE)
		return;
	if (self.mapvar && !read_mapvar(self.mapvar))
		return;
	float has_target;

	if (self.target && self.target != "") {
		heal_find(self.target, targetname);
		heal_find(self.target, targetname2);
		has_target = TRUE;
	}
	if (self.target2 && self.target2 != "") {
		heal_find(self.target2, targetname);
		heal_find(self.target2, targetname2);
		has_target = TRUE;
	}
	if (self.target3 && self.target3 != "") {
		heal_find(self.target3, targetname);
		heal_find(self.target3, targetname2);
		has_target = TRUE;
	}
	if (self.target4 && self.target4 != "") {
		heal_find(self.target4, targetname);
		heal_find(self.target4, targetname2);
		has_target = TRUE;
	}

	if (!has_target) {
		heal_start(activator, self.healamount, self.speed);
	}


}

void() target_heal = {
	if (!SUB_InitEntity()) return;
	
	self.use = heal_use;
};



/*
==============================================================================

trigger_push

==============================================================================
*/

float PUSH_ONCE = 1;
float PUSH_SILENT = 2;
float PUSH_TUNNEL = 8;


void() trigger_push_touch =
{
	if (self.estate != STATE_ACTIVE)
		return;
	if (self.mapvar && !read_mapvar(self.mapvar))
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

		if (self.spawnflags & PUSH_TUNNEL)
		{
			vector suck = self.origin + (self.mins + self.maxs )/2 - other.origin;
			suck -= self.movedir * (suck * self.movedir);
			other.velocity += suck * self.speed * 0.1;
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
	if (!SUB_InitEntity()) return;
	
	if (self.angles == '0 0 0')
		self.angles = '0 360 0';

	if (!self.noise)
		self.noise = "ambience/windfly.wav";

	if (!self.delay)
		self.delay = 1.5;

	if (!(self.spawnflags & PUSH_SILENT)) precache_sound(self.noise);
	
	self.touch = trigger_push_touch;
	
	if (!self.speed)
		self.speed = 1000;

	InitTrigger ();

	SUB_CheckWaiting();
};

/*
==============================================================================

trigger_monsterjump

==============================================================================
*/
float SPAWN_MJUMP_NOLARGE = 1;
float SPAWN_MJUMP_NOSMALL = 2;
float SPAWN_MJUMP_MELEES = 8;
float SPAWN_MJUMP_ONLYFRONT = 16;
float SPAWN_MJUMP_ONLYBELOW = 32;

void() trigger_monsterjump_touch =
{
	if (self.estate != STATE_ACTIVE)
		return;
	if (self.mapvar && !read_mapvar(self.mapvar))
		return;

	//if(!self.count)
	//	return;

	// only walking monsters 
	if (other.flags & (FL_MONSTER | FL_FLY | FL_SWIM) != FL_MONSTER)
		return;
	// dead monsters can't jump
	if (other.health <= 0)
		return;

	/*
	if (self.include && other.classname != self.include)
		return;

	if (self.exclude && other.classname == self.exclude)
		return;
	*/
	if (self.include == string_null || 
		(other.classname != self.include && other.targetname != self.include))	// always allow this class/tname
	{
		if (self.spawnflags & SPAWN_MJUMP_NOLARGE && other.maxs_x >= 24) return;
		if (self.spawnflags & SPAWN_MJUMP_NOSMALL && other.maxs_x < 24) return;
		//if (self.spawnflags & SPAWN_MJUMP_MELEES && !(other.customflags & CFL_MELEEONLY)) return;
		
		if (self.exclude != string_null)
		{
			if (self.exclude == other.classname || self.exclude == other.targetname) return; // always exclude this class/tname
		}
	}

	if (self.spawnflags & SPAWN_MJUMP_ONLYBELOW) {
		if (!other.enemy) return;
		if (other.enemy.absmin_z > (other.absmin_z - 16)) return;
	}

	if (self.spawnflags & SPAWN_MJUMP_ONLYFRONT) {
		if (!other.enemy) return;
		vector dir = other.enemy.origin - other.origin;
		dir_z = 0;
		dir = normalize(dir);
		if (dir * self.movedir < self.distance)
			return;
	}

	// set XY even if not on ground, so the jump will clear lips
	other.velocity_x = self.movedir_x * self.speed;
	other.velocity_y = self.movedir_y * self.speed;
	
	if ( !(other.flags & FL_ONGROUND) )
		return;
	
	other.flags = other.flags - FL_ONGROUND;
	other.velocity_z = self.height;
	
	//if (self.count > 0) self.count--;
};

/*QUAKED trigger_monsterjump (.5 .5 .5) ?
Walking monsters that touch this will jump in the direction of the trigger's angle
"speed" default to 200, the speed thrown forward
"height" default to 200, the speed thrown upwards
*/
void() trigger_monsterjump =
{
	if (!SUB_InitEntity()) return;
	
	if (!self.speed)
		self.speed = 200;
	if (!self.height)
		self.height = 200;
	if (self.angles == '0 0 0')
		self.angles = '0 360 0';
	if(!self.count)
		self.count = -1;
	if (!self.distance)
		self.distance = 0.5;
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
	if (self.mapvar && !read_mapvar(self.mapvar))
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

		T_Damage(other, self, self, other.health + 1000, DMGTYPE_INSTANT);
		
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
	if (!SUB_InitEntity()) return;
	
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
	entity oself;
	if (plr.classname != "player")
		return;

	oself = self;
	self = plr;

	

	if (removeditems & IT_INVISIBILITY & self.items) {
		self.invisible_finished = 0;
		self.invisible_time = 0;
	}
	if (removeditems & IT_INVULNERABILITY & self.items) {
		self.invincible_time = 0;
		self.invincible_finished = 0;
	}
	if (removeditems & IT_TRIFECTA & self.items) {
		self.trif_finished = 0;
		self.trif_time = 0;
	}
	if (removeditems & IT_QUAD & self.items) {
		self.super_damage_finished = 0;
		self.super_time = 0;
	}
	if (removeditems & IT_SUIT & self.items) {
		self.rad_time = 0;
		self.radsuit_finished = 0;
	}
	if (removeditems & IT_JBOOTS & self.items) {
		self.jboots_finished = 0;
		self.jboots_time = 0;
		self.jboots_rechargelimit = 0;
		self.jboots_prevlimit = 0;
	}

	self.items -= self.items & removeditems;
	self.items -= self.items & removedweapons & HUD_WEAPONS;
	self.weapons -= self.weapons & removedweapons;
	

	if (!(self.weapons & self.weapon)) { //if player is wielding a removed weapon
		W_ChangeWeapon(W_BestWeapon());
	}

	self = oself;

};

void() trigger_removeitems_touch = {

	if(!self.count)
		return;
	if (self.estate != STATE_ACTIVE)
		return;
	if (self.mapvar && !read_mapvar(self.mapvar))
		return;
	removeitems_go (other, self.items, self.weapons);

	if(self.count > 0)
		self.count--;
};

void() trigger_removeitems = {
	if (!SUB_InitEntity()) return;
	
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
	if (self.mapvar && !read_mapvar(self.mapvar))
		return;

	if (self.spawnflags & 1) { // all players
		entity pl = find(world, classname, "player");
		while (pl) {
			removeitems_go(pl, self.items, self.weapons);
			find(pl, classname, "player");
		}
	}
	else {
		removeitems_go (activator, self.items, self.weapons);
	}

	if(self.count > 0)
		self.count--;
};

void() target_removeitems = {
	if (!SUB_InitEntity()) return;
	

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
	if (self.count > 0 && self.cnt <= 0) // has limited uses and has reached 0
		return;

	SUB_UseTargets();

	self.think = trigger_repeat_think;

	if (self.count > 0) {
		self.cnt--;
		if (self.cnt <= 0) {
			self.state = STATE_INACTIVE;
			self.think = SUB_Null;
			self.nextthink = 0;
			return;
		}
	}

	self.nextthink = time + self.wait + self.rand*random();
};

void() trigger_repeat_use = {
	if (self.state == STATE_INACTIVE) {
		if (!(self.spawnflags & 1)) self.cnt = self.count;
		
		if (self.delay) {
			self.think = trigger_repeat_think;
			self.nextthink = time + self.delay; 
		}
		else
			trigger_repeat_think();

		self.state = STATE_ACTIVE;
	}
	else {
		self.nextthink = -1;
		self.state = STATE_INACTIVE;
	}
};

void() trigger_repeat = {
	if (!SUB_InitEntity()) return;
	
	if (!self.wait) self.wait = 2;

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
	if (e.classname == "func_door") return e.owner.estate;
	else return e.estate;
};

void(entity e) entity_set_state_hide = {
	e.estate_orig_solid = e.solid;
	e.estate_orig_move = e.movetype;
	e.estate_orig_mdlindex = e.modelindex;

	e.modelindex = 0;
	e.solid = SOLID_NOT;
	if (e.movetype == SOLID_BSP) e.movetype = MOVETYPE_NONE;
	setorigin(e, e.origin); // relink
}

void(entity e) entity_set_state_unhide = {
	e.modelindex = e.estate_orig_mdlindex;
	e.solid = e.estate_orig_solid;
	e.movetype = e.estate_orig_move;
	setorigin(e, e.origin); // relink
}

void(entity e, float state, float flags) entity_set_state = {
	
	if (e.th_setstate){
		entity oself = self;
		self = e;
		self.th_setstate(state, flags);
		self = oself;
	}
	else {
		if (e.estate == STATE_INVISIBLE) {
			entity_set_state_unhide(e);
		}
		else if (state == STATE_INVISIBLE) {
			entity_set_state_hide(e);
		}
		e.estate = state;
	}

	if (e.is_waiting > 0 && state == STATE_ACTIVE) {
		SUB_CallAsSelf(SUB_EndWaiting, e);
	}

	//if (e.touch && e.touch != SUB_Null) {
	//	force_retouch = 2;
	//}
};

void(string matchstring, .string matchfield, float state, float flags) target_setstate_set_target = {
	local entity t;

	t = find(world, matchfield, matchstring);
	while (t != world) {
		if (!(t.classname == "func_door" && t.owner != t)) {
			if (state == -1){
				if (entity_get_state(t) == STATE_ACTIVE)
					entity_set_state(t, STATE_INACTIVE, flags);
				else
					entity_set_state(t, STATE_ACTIVE, flags);
			}
			else entity_set_state(t, state, flags);
		}
		t = find(t, matchfield, matchstring);
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
	else if (self.style == 3) state = STATE_INVISIBLE;
	else state = -1;

	target_setstate_set_alltargets(state);

};

void() target_setstate_startoff_think = {
	if (door_setup_finished) {
		if (self.style == 3) target_setstate_set_alltargets(STATE_INVISIBLE);
		else target_setstate_set_alltargets(STATE_INACTIVE);
	}
	else {
		// not finished yet? wait a bit longer
		self.think = target_setstate_startoff_think;
		self.nextthink = time + 0.1;
	}
};

void() target_setstate = {
	if (!SUB_InitEntity()) return;
	
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
float FILTER_FIELD_TARGETNAME2 = 14;
float FILTER_FIELD_AMMO_SHELLS = 15;
float FILTER_FIELD_AMMO_NAILS = 16;
float FILTER_FIELD_AMMO_ROCKETS = 17;
float FILTER_FIELD_AMMO_CELLS = 18;
float FILTER_FIELD_CURRENTAMMO = 19;


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



float(entity targ, entity filter) filter_entity = {
	filter.state = 0;

	if (filter.estate != STATE_ACTIVE) return FALSE;

	float targfloat;
	string targstring;

	float fieldtype, op, result;

	if (filter.include != "") {
		targ = find(world, targetname, filter.include);
		if (!targ) targ = find(world, targetname2, filter.include);
		if (!targ) return FALSE;
	}


	op = filter.weapon;

	switch (filter.style) {
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

		case FILTER_FIELD_TARGETNAME2:
			fieldtype = FILTER_FIELDTYPE_STRING;
			targstring = targ.targetname2;
			break;
			
		case FILTER_FIELD_TYPE:
			fieldtype = FILTER_FIELDTYPE_STRING;
			targstring = targ.type;
			break;

		case FILTER_FIELD_AMMO_SHELLS:
			fieldtype = FILTER_FIELDTYPE_FLOAT;
			targfloat = targ.ammo_shells;
			break;

		case FILTER_FIELD_AMMO_NAILS:
			fieldtype = FILTER_FIELDTYPE_FLOAT;
			targfloat = targ.ammo_nails;
			break;

		case FILTER_FIELD_AMMO_ROCKETS:
			fieldtype = FILTER_FIELDTYPE_FLOAT;
			targfloat = targ.ammo_rockets;
			break;

		case FILTER_FIELD_AMMO_CELLS:
			fieldtype = FILTER_FIELDTYPE_FLOAT;
			targfloat = targ.ammo_cells;
			break;

		case FILTER_FIELD_CURRENTAMMO:
			fieldtype = FILTER_FIELDTYPE_FLOAT;
			targfloat = targ.currentammo;
			break;
	}
	result = 0;

	if (fieldtype == FILTER_FIELDTYPE_FLOAT) {
		if 		(op == FILTER_OP_EQUALS) 		{if (targfloat == filter.count) result = 1;}
		else if (op == FILTER_OP_LT) 			{if (targfloat <  filter.count) result = 1;}
		else if (op == FILTER_OP_LTE) 			{if (targfloat <= filter.count) result = 1;}
		else if (op == FILTER_OP_GT) 			{if (targfloat >  filter.count) result = 1;}
		else if (op == FILTER_OP_GTE) 			{if (targfloat >= filter.count) result = 1;}
		else if (op == FILTER_OP_BITMASK_AND)	{if (targfloat &  filter.count) result = 1;}
		else if (op == FILTER_OP_BITMASK_OR)	{if (targfloat |  filter.count) result = 1;}
		else 									{if (targfloat == filter.count) result = 1;}
	}
	else if (fieldtype == FILTER_FIELDTYPE_FLAG) {
		if 		(op == FILTER_OP_EQUALS) 		{if (targfloat == filter.aflag) result = 1;}
		else if (op == FILTER_OP_BITMASK_AND)	{if (targfloat &  filter.aflag) result = 1;}
		else if (op == FILTER_OP_BITMASK_OR)	{if (targfloat |  filter.aflag) result = 1;}
		else 									{if (targfloat == filter.aflag) result = 1;}
	}
	else if (fieldtype == FILTER_FIELDTYPE_STRING) {
		if (targstring == filter.type) result = 1;
	}
	else {
		objerror ("invalid fieldtype");
		return FALSE;
	}

	if (filter.spawnflags & 1) result = 1 - result; // negate

	//dprint2(targstring, "\n");
	//dprint2(ftos(result),"\n");

	if (result) 
		return TRUE;
	else
		return FALSE;
};


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

		case FILTER_FIELD_TARGETNAME2:
			fieldtype = FILTER_FIELDTYPE_STRING;
			targstring = targ.targetname2;
			break;
			
		case FILTER_FIELD_TYPE:
			fieldtype = FILTER_FIELDTYPE_STRING;
			targstring = targ.type;
			break;

		case FILTER_FIELD_AMMO_SHELLS:
			fieldtype = FILTER_FIELDTYPE_FLOAT;
			targfloat = targ.ammo_shells;
			break;

		case FILTER_FIELD_AMMO_NAILS:
			fieldtype = FILTER_FIELDTYPE_FLOAT;
			targfloat = targ.ammo_nails;
			break;

		case FILTER_FIELD_AMMO_ROCKETS:
			fieldtype = FILTER_FIELDTYPE_FLOAT;
			targfloat = targ.ammo_rockets;
			break;

		case FILTER_FIELD_AMMO_CELLS:
			fieldtype = FILTER_FIELDTYPE_FLOAT;
			targfloat = targ.ammo_cells;
			break;

		case FILTER_FIELD_CURRENTAMMO:
			fieldtype = FILTER_FIELDTYPE_FLOAT;
			targfloat = targ.currentammo;
			break;
	}
	result = 0;

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

		if (self.spawnflags & 2 && activator.owner) activator = activator.owner; // Relay owner as activator
		else if (self.spawnflags & 4) { // relay closest player as activator
			entity closest;
			closest = findClosest(self.origin, classname, "player", 0);
			if (closest) activator = closest;
		}

		SUB_UseTargets();
		if (other.classname == "trigger_everything" && other.spawnflags & 1) {
			if (other.wait)	other.attack_finished = time + other.wait;
		}

	}
};

void() trigger_filter = {
	if (!SUB_InitEntity()) return;
	
	self.use = trigger_filter_use;

};


/*
=============================================================

trigger_everything

=============================================================
*/

void() trigger_everything_touch = {
	if (self.estate != STATE_ACTIVE) return;
	if (self.mapvar && !read_mapvar(self.mapvar))
		return;

	if (time < self.attack_finished) return;

	activator = other;
	
	SUB_UseSpecificTarget(self.target, targetname);

	if (self.wait)
		if (!(self.spawnflags & 1)) self.attack_finished = time + self.wait;

};

void() trigger_everything = {
	if (!SUB_InitEntity()) return;
	
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
		if (self.style == 1){
			t.count += self.count;
		}
		else if (self.style == 2){
			if (t.count) t.count = 0;
			else t.count = 1;
		}
		else {
			t.count = self.count;
		}

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

	if (self.spawnflags & 1) {
		if (self.style == 1)
			activator.count += activator.count;
		else
			activator.count = activator.count;
	}
};

void() target_setcount = {
	if (!SUB_InitEntity()) return;
	
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
		if (t.flags & FL_MONSTER && self.spawnflags & 2) { // restore monsters' original bbox
			if (t.mins != t.cmins || t.maxs != t.cmaxs) {
				setsize(t, t.cmins, t.cmaxs);
			}
		}
		else if (t.mins != self.cmins || t.maxs != self.cmaxs) {
			setsize(t, self.cmins, self.cmaxs);
		}

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
		if (activator.flags & FL_MONSTER && self.spawnflags & 2) { // restore monsters' original bbox
			if (activator.mins != activator.cmins || activator.maxs != activator.cmaxs) 
				setsize(activator, activator.cmins, activator.cmaxs);
		}
		else if (activator.mins != self.cmins || activator.maxs != self.cmaxs) 
			setsize(activator, self.cmins, self.cmaxs);
	}
};

void() target_setsize = {
	if (!SUB_InitEntity()) return;
	
	self.use = target_setsize_use;

};


void() target_startpath_use = {
	if (self.estate != STATE_ACTIVE) return;

	entity mon, path;

	mon = find(world, targetname, self.target);
	path = find(world, targetname, self.target2);
	
	if (!mon || !path || !(mon.flags & FL_MONSTER))
		return;

	if (path.classname == "path_angry" && mon.enemy) {
		dprint("Found path_angry, following\n");
		mon.followingpath = TRUE;
		mon.goalentity = path;
		mon.oldenemy = mon.enemy;
		mon.startpath = world;
		mon.think = mon.th_run;
		mon.nextthink = time + 0.1;
	}
	else if (path.classname == "path_corner" && !mon.enemy) {
		dprint("Found path_corner, following\n");
		mon.goalentity = mon.movetarget = path;
		mon.ideal_yaw = vectoyaw(mon.goalentity.origin - mon.origin);

		SUB_CallAsSelf(mon.th_walk, mon);
		
	}
}


void() target_startpath = {
	if (!SUB_InitEntity()) return;
	
	self.use = target_startpath_use;
};



/*
=============================================================

trigger_float

=============================================================
*/

void() trigger_float = {
	if (!SUB_InitEntity()) return;
	
	InitTrigger();

	self.touch = trigger_float_touch;

	self.speed = defaultFl(self.speed, 1600);
	self.finalspeed = zeroconvertdefault(self.finalspeed, 100);

	self.delay = defaultFl(self.delay, 1);

	if (self.noise != "") precache_sound(self.noise);

	if (self.speed <= 0 ) {
		objerror("trigger_float: speed cannot be negative");
		remove(self);
		return;
	}

	SUB_CheckWaiting();
}

void() trigger_float_touch = {
	if (self.estate != STATE_ACTIVE)
		return;

	if (other.movetype != MOVETYPE_TOSS &&
		other.movetype != MOVETYPE_BOUNCE && 
		other.movetype != MOVETYPE_BOUNCEMISSILE &&
		other.movetype != MOVETYPE_WALK &&
		other.movetype != MOVETYPE_STEP
	)
		return;

	// no players
	if (other.movetype == MOVETYPE_WALK && self.spawnflags & 1)
		return;

	// no monsters
	if (other.movetype == MOVETYPE_STEP && self.spawnflags & 2)
		return;
	

	if (other.velocity_z < self.finalspeed){
		other.flags &~= FL_ONGROUND;
		other.velocity_z += self.speed * frametime;
	}
	else
		other.velocity_z -= self.speed * frametime;

	if (self.noise != "") {
		if (other.flags & FL_CLIENT && other.health > 0 && other.fly_sound < time) {
			other.fly_sound = time + self.delay;
			sound(other, CHAN_AUTO, self.noise, 1, ATTN_NORM);
		}
	}
}


/*
=============================================================

trigger_random

=============================================================
*/

void() trigger_random = {
	if (!SUB_InitEntity()) return;

	self.use = trigger_random_use;
}

void() trigger_random_use = {
	if (self.estate != STATE_ACTIVE)
		return;

	if (self.target == "" && self.target2 == "" && self.target3 == "" && self.target3 == ""){
		dprint3("Warning: trigger_random with no targets at ", vtos(self.origin), "\n");
		return;
	}


	entity e;

	if (self.target != "") {
		e = findRandomEntity(self.target, targetname);
		if (e) SUB_CallAsSelf(e.use, e);
	}

	if (self.target2 != "") {
		e = findRandomEntity(self.target2, targetname);
		if (e) SUB_CallAsSelf(e.use, e);
	}

	if (self.target3 != "") {
		e = findRandomEntity(self.target3, targetname);
		if (e) SUB_CallAsSelf(e.use, e);
	}

	if (self.target4 != "") {
		e = findRandomEntity(self.target4, targetname);
		if (e) SUB_CallAsSelf(e.use, e);
	}
	
	if (self.killtarget != "") {
		e = findRandomEntity(self.killtarget, targetname);
		if (e) SUB_KillSpecificEntity(e);
	}
	
}


entity(string matchstring, .string matchfield) findRandomEntity = {
	entity tgt_entities[256];
	entity e;
	float i;
	
	e = find(world, matchfield, matchstring);
	while (e) {
		tgt_entities[i] = e;
		i++;
		e = find(e, matchfield, matchstring);
	}
	if (i == 0) return world;

	float j = floor(random() * (i - 0.001));
	dprint3("index: ", ftos(j), "\n");
	return tgt_entities[j];
}