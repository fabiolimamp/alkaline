// button and multiple button

void() button_wait;
void() button_return;

void() button_wait =
{
	self.state = STATE_TOP;
	self.nextthink = self.ltime + self.wait;
	self.think = button_return;
	activator = self.enemy;
	self.frame = 1;			// use alternate textures
	if (self.estate != STATE_ACTIVE)
		return;

	SUB_UseTargets();
};

void() button_done =
{
	self.state = STATE_BOTTOM;
};

void() button_return =
{
	if (self.estate != STATE_ACTIVE) return;

	self.state = STATE_DOWN;
	SUB_CalcMove (self.pos1, self.speed, button_done);
	self.frame = 0;			// use normal textures
	if (self.health)
		self.takedamage = DAMAGE_YES;	// can be shot again
};

void() button_group_release = {
	entity e = find(world, groupname, self.groupname);

	while (e) {
		if (e != self && e.classname == "func_button" && e.state != STATE_BOTTOM) {

			e.state = STATE_DOWN;

			SUB_CalcMoveEnt(e, e.pos1, e.speed, button_done);

			e.frame = 0;			// use normal textures
			if (e.health)
				e.takedamage = DAMAGE_YES;	// can be shot again
		}

		e = find(e, groupname, self.groupname);
		
	}
};

void() button_blocked =
{	// do nothing, just don't ome all the way back out
};


void() button_fire =
{
	if (self.estate != STATE_ACTIVE) return;

	if (self.state == STATE_UP || self.state == STATE_TOP)
		return;

	if (self.spawnflags & (1+2+4)){
		if (!(self.enemy.flags & FL_CLIENT))
			return;

		if (!keylock_try_to_unlock(self.enemy, "", SUB_Null))
			return;
	}

	if (self.groupname)
		button_group_release();

	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);

	self.state = STATE_UP;
	SUB_CalcMove (self.pos2, self.speed, button_wait);
};

void(float newstate, float stateflags) button_setstate = {
	if (self.estate == STATE_INVISIBLE) {
		entity_set_state_unhide(self);
	}

	if (newstate == STATE_ACTIVE) button_unlock(self, stateflags & SETSTATE_DONTRESETBUTTON);
	else if (newstate == STATE_INVISIBLE) {
		entity_set_state_hide(self);
		self.estate = newstate;
	}
	else button_lock(self);
}

void() button_use =
{
	self.enemy = activator;
	button_fire ();
};

void() button_touch =
{
	if (self.estate != STATE_ACTIVE) return;

	if (other.classname != "player")
		return;
	self.enemy = other;
	button_fire ();
};

void() button_killed =
{
	if (self.estate != STATE_ACTIVE) return;

	self.enemy = damage_attacker;
	self.health = self.max_health;
	self.takedamage = DAMAGE_NO;	// wil be reset upon return
	button_fire ();
};


// adapted from Copper, thanks Lunaran
void(entity b) button_lock =
{
	entity oself;

	if (b.estate == STATE_INACTIVE)
		return;

	oself = self;
	self = b;

	if (self.state == STATE_UP || self.state == STATE_TOP)
		self.prevgroupstate = STATE_TOP;
	else 
		self.prevgroupstate = STATE_BOTTOM;

	if (self.max_health)
		self.takedamage = DAMAGE_NO;
	self.state = STATE_UP;
	SUB_CalcMove (self.pos2, self.speed, button_wait);
	self.estate = STATE_INACTIVE;

	self = oself;
}

void(entity b, float dontresetstate) button_unlock =
{
	entity oself;

	if (b.estate == STATE_ACTIVE)
		return;

	oself = self;
	self = b;

	if (!dontresetstate || self.wait != -1 || self.prevgroupstate == STATE_BOTTOM) {
		if (self.max_health)
		{
			self.takedamage = DAMAGE_YES;
			self.health = self.max_health;
		}
		self.frame = 0;			// use normal textures
		self.state = STATE_DOWN;
		SUB_CalcMove (self.pos1, self.speed, button_done);
	}

	self.estate = STATE_ACTIVE;

	self = oself;
}

/*QUAKED func_button (0 .5 .8) ?
When a button is touched, it moves some distance in the direction of it's angle, triggers all of it's targets, waits some time, then returns to it's original position where it can be triggered again.

"angle"		determines the opening direction
"target"	all entities with a matching targetname will be used
"speed"		override the default 40 speed
"wait"		override the default 1 second wait (-1 = never return)
"lip"		override the default 4 pixel lip remaining at end of move
"health"	if set, the button must be killed instead of touched
"sounds"
0) steam metal
1) wooden clunk
2) metallic click
3) in-out
*/
void() func_button =
{
	if (!SUB_InitEntity()) return;
	
	//local float		gtemp, ftemp;
	string default_noise;


	if (self.sounds == 0)
		default_noise = "buttons/airbut1.wav";
	else if (self.sounds == 1)
		default_noise = "buttons/switch21.wav";
	else if (self.sounds == 2)
		default_noise = "buttons/switch02.wav";
	else if (self.sounds == 3)
		default_noise = "buttons/switch04.wav";

	if (self.noise == "") self.noise = default_noise;
	precache_sound(self.noise);

	self.movetype = MOVETYPE_PUSH;
	self.solid = SOLID_BSP;
	setmodel (self, self.model);

	self.blocked = button_blocked;
	self.use = button_use;
	self.th_setstate = button_setstate;

	if (self.health)
	{
		self.max_health = self.health;
		self.th_die = button_killed;
		self.takedamage = DAMAGE_YES;
	}
	else
		self.touch = button_touch;

	if (!self.speed)
		self.speed = 40;
	if (!self.wait)
		self.wait = 1;

	if (self.spawnflags & (1+2+4)){
		self.wait = -1;
		keylock_init();
	}

	if (self.spawnflags & 1)
		keylock_set_silver_key ();
	if (self.spawnflags & 2)
		keylock_set_gold_key ();
	if (self.spawnflags & 4)
		keylock_set_plat_key ();

	self.state = STATE_BOTTOM;

	self.pos1 = self.origin;
	
// johnfitz -- alternate button settings (movedir instead of lip/angle)
	if (!self.movedir)
	{
		SetMovedir ();
		if (self.distance) {
			self.pos2 = self.pos1 + self.movedir*self.distance;
		}
		else {
			if (!self.lip)
				self.lip = 4;
			self.pos2 = self.pos1 + self.movedir*(fabs(self.movedir*self.size) - self.lip);
		}
	}
	else
		self.pos2 = self.pos1 + self.movedir;
// johnfitz
	
	
};

