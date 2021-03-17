/****************************
Lightning trail by bmFbr
Loosely based on DoE's ltrail_* entities
*****************************/

float LT_TOGGLE =	1;
float LT_START_ON = 2;

float LT_SOUND_INHERIT	= 0;
float LT_SOUND_ON		= 1;
float LT_SOUND_OFF		= 2;


void() misc_lightning_fire =
{
	local entity t;
	local float damage;
	
	if (self.sounds == LT_SOUND_ON) {
		if (self.t_width < time) {
			sound (self, CHAN_VOICE, "weapons/lhit.wav", 1, ATTN_NORM);
			self.t_width = time + 0.6;
		}
	}

	if(self.dmg == -1) damage = 0;
	else damage = self.dmg;

	t = find(world, targetname, self.target);

	// TODO: make lightning shooter target multiple points
	// Looping doesn't work for some reason
	//while(t) {
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_LIGHTNING2);
		WriteEntity (MSG_BROADCAST, self);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
		WriteCoord (MSG_BROADCAST, t.origin_x);
		WriteCoord (MSG_BROADCAST, t.origin_y);
		WriteCoord (MSG_BROADCAST, t.origin_z);
		
		LightningDamage (self.origin, t.origin, self, damage);
		t.enemy = self;

	//	t = find(t, targetname, self.target);
	//}
	
	

	if((self.owner.spawnflags & LT_TOGGLE) && self.owner.state == 0) {
		if(self.pausetime > time + self.enemy.delay) self.pausetime = time + self.enemy.delay;
	}
	
	if(self.pausetime > time) {
		self.think = misc_lightning_fire;
		self.nextthink = time + 0.05;
	}

	
};

void() misc_lightning_use =
{

	if(!self.owner) {
		self.owner = self.enemy.owner;

		if(!self.dmg) self.dmg = self.owner.dmg;
		if(!self.count) self.count = self.owner.count;
		if(self.sounds == LT_SOUND_INHERIT) self.sounds = self.owner.sounds;
	}

	if(self.owner == self && (self.owner.spawnflags & LT_TOGGLE) && self.owner.state == 1) {
		self.owner.state = 0;
		return;
	}
	
	if(self.owner.spawnflags & LT_TOGGLE) {
		self.owner.state = 1;
		self.pausetime = 999999999999;
	}
	else self.pausetime = time + self.count;

	misc_lightning_fire();

	SUB_UseTargets();
};

void() misc_lightning_end_use =
{
	SUB_Null();
	//if(self.sounds == LT_SOUND_INHERIT) self.sounds = self.owner.sounds;
};


/*QUAKED misc_lightning_start (0 1 0) (-8 -8 -8) (8 8 8) LT_TOGGLE START_ON X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY

Starting point of a lightning trail.
Set dmg to amount of damage you want the lightning to do. Set it to -1 if you want no damage.
Default is 25.

Set 'count' to the duration of the lightning.
Default is 0.3 seconds.

Set the LT_TOGGLE checkbox if you want the lightning shooter to continuously fire until triggered again ('count' parameter will be ignored).
Set the LT_START_ON checkbox if you want the lightning to start in a fired state.

Set 'sounds' to 

*/
void() misc_lightning_start =
{
	precache_sound ("weapons/lhit.wav");

	self.owner = self;
	self.enemy = self;

	if(!self.target || self.target == "") objerror("Target point not set for lightning");
	
	self.use = misc_lightning_use;

	self.state = 0;

	if (self.dmg == 0)
		self.dmg = 25;

	if (self.count == 0)
		self.count = 0.3;

	if (!self.sounds)
		self.sounds = LT_SOUND_ON;

	if (self.spawnflags & LT_START_ON)
		misc_lightning_use();
};

/*QUAKED misc_lightning_relay (0 1 0) (-8 -8 -8) (8 8 8) X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
Relay point of a lightning trail.

Set 'dmg' to amount of damage you want the lightning to do. Set it to -1 if you want no damage.
Default is to inherit the damage value from misc_lightning_start.

Set 'count' to the duration of the lightning at this specific point.
Default is to inherit the value from misc_lightning_start.

Set 'delay' to the amount of time before the lightning is spawned from this point, relative to the previous one. Default is 0 (spawns at the same time as the previous).

*/
void() misc_lightning_relay =
{
	precache_sound ("weapons/lhit.wav");
	if(!self.target || self.target == "") objerror("Target point not set for lightning");

	self.use = misc_lightning_use;
};

/*QUAKED misc_lightning_end (0 1 0) (-8 -8 -8) (8 8 8) X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
Ending point of a lightning trail.
Does not fire any lightning.

*/
void() misc_lightning_end =
{
	precache_sound ("weapons/lhit.wav");

	self.use = misc_lightning_end_use;
};
