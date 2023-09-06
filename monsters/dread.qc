/*=============================================================================
 
monster_dreadnaught
code by john fitzgibbons

==============================================================================*/

$cd id1/models/enforcer
$origin 0 -6 24
$base base		
$skin skin

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9 walk10
$frame walk11 walk12 walk13 walk14 walk15 walk16

$frame run1 run2 run3 run4 run5 run6 run7 run8

$frame attack1 attack2 attack3 attack4 attack5 attack6
$frame attack7 attack8 attack9 attack10

$frame death1 death2 death3 death4 death5 death6 death7 death8
$frame death9 death10 death11 death12 death13 death14

$frame fdeath1 fdeath2 fdeath3 fdeath4 fdeath5 fdeath6 fdeath7 fdeath8
$frame fdeath9 fdeath10 fdeath11

$frame paina1 paina2 paina3 paina4

$frame painb1 painb2 painb3 painb4 painb5

$frame painc1 painc2 painc3 painc4 painc5 painc6 painc7 painc8

//============================================================================

void() flame_touch =
{
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	self.movedir = '0 0 0';

	if (self.dmg > 0 && other.health > 0){
		//direct damage
		if (self.style == 1)
			T_Damage(other, self, self.owner, self.dmg, DMGTYPE_BURN);
		else
			T_Damage(other, self, self.owner, self.dmg, DMGTYPE_BURN_LONG);
		self.dmg = 0;
	}
};


void() flame_fly =
{
	self.frame = self.frame + 1;
	if (self.frame > 7 || pointcontents2(self.origin) != CONTENT_EMPTY)
	{
		if (self.owner.missle == self)
			self.owner.missle = world;
		remove(self);
		return;
	}
	
	self.velocity = self.velocity + '0 0 30' - (self.movedir * 0.12);
	self.nextthink = time + 0.1;
}

void(vector org, vector vec) make_flame =
{
	local vector variance;
	local float roll;
	
	//remove glow from previous flame
	if (self.missle != world)
		self.missle.effects = 0;
	
	newmis = spawn();
	newmis.owner = self;
	setmodel (newmis, "progs/s_flame.spr");
	setorigin (newmis, org);
	newmis.movetype = MOVETYPE_FLY;
	newmis.solid = SOLID_BBOX;
	newmis.flags = newmis.flags | FL_PROJECTILE;
	variance = '-10 -10 -10' + random() * '20 20 20';
	newmis.movedir = normalize(vec) * 250 + '0 0 -50' + variance;
	newmis.velocity = newmis.movedir;
	roll = 350 + random() * 20;
	newmis.angles_z = anglemod(roll);
	newmis.nextthink = time + 0.1;
	newmis.think = flame_fly;
	newmis.touch = flame_touch;
	newmis.classname = "flame";
	newmis.dmg = 5;
	newmis.frame = 0;
	setsize (newmis, '0 0 0', '0 0 0');
	
	//add glow to new flame
	self.missle = newmis;
	newmis.effects = EF_DIMLIGHT;
};

void() dread_fire =
{
	local vector org;
	makevectors (self.angles);
	org = self.origin + v_forward * 30 + v_right * 8.5 + '0 0 16';
	make_flame(org, self.enemy.origin - self.origin);
	//self.effects = self.effects | EF_MUZZLEFLASH;
};

void()	dread_atk1	=[	$attack1,	dread_atk2	] {ai_face();};
void()	dread_atk2	=[	$attack3,	dread_atk3	] {ai_face();};
void()	dread_atk3	=[	$attack5,	dread_atk4	] {
	sound (self, CHAN_WEAPON, "dread/flameon.wav", 1, ATTN_NORM);
	dread_fire();
	ai_face();
	self.attack_finished = time + 0.3; //1 + random();
};
void()	dread_atk4	=[	$attack5,	dread_atk5	] 
{
	dread_fire();
	ai_face();
	
	if (self.attack_finished > time || (range(self.enemy) == RANGE_MELEE && self.enemy.health > 0) )
		self.think = dread_atk4;
};
void()	dread_atk5	=[	$attack10,	dread_run1	] {
	sound (self, CHAN_WEAPON, "dread/flameoff.wav", 1, ATTN_NORM);
	ai_face();
	SUB_CheckRefire (dread_atk1);
};

//============================================================================

void()	dread_stand1	=[	$stand1,	dread_stand2	] {ai_stand();};
void()	dread_stand2	=[	$stand2,	dread_stand3	] {ai_stand();};
void()	dread_stand3	=[	$stand3,	dread_stand4	] {ai_stand();};
void()	dread_stand4	=[	$stand4,	dread_stand5	] {ai_stand();};
void()	dread_stand5	=[	$stand5,	dread_stand6	] {ai_stand();};
void()	dread_stand6	=[	$stand6,	dread_stand7	] {ai_stand();};
void()	dread_stand7	=[	$stand7,	dread_stand1	] {ai_stand();};

void()	dread_walk1	=[	$walk1 ,	dread_walk2	]
{
	if (random() < 0.2)
		sound (self, CHAN_VOICE, "enforcer/idle1.wav", 1, ATTN_IDLE);
	ai_walk(2);
};
void()	dread_walk2		=[	$walk2 ,	dread_walk3		] {ai_walk(4);};
void()	dread_walk3		=[	$walk3 ,	dread_walk4		] {ai_walk(4);};
void()	dread_walk4		=[	$walk4 ,	dread_walk5		] {ai_walk(3);};
void()	dread_walk5		=[	$walk5 ,	dread_walk6		] {ai_walk(1);};
void()	dread_walk6		=[	$walk6 ,	dread_walk7		] {ai_walk(2);};
void()	dread_walk7		=[	$walk7 ,	dread_walk8		] {ai_walk(2);};
void()	dread_walk8		=[	$walk8 ,	dread_walk9		] {ai_walk(1);};
void()	dread_walk9		=[	$walk9 ,	dread_walk10	] {ai_walk(2);};
void()	dread_walk10	=[	$walk10,	dread_walk11	] {ai_walk(4);};
void()	dread_walk11	=[	$walk11,	dread_walk12	] {ai_walk(4);};
void()	dread_walk12	=[	$walk12,	dread_walk13	] {ai_walk(1);};
void()	dread_walk13	=[	$walk13,	dread_walk14	] {ai_walk(2);};
void()	dread_walk14	=[	$walk14,	dread_walk15	] {ai_walk(3);};
void()	dread_walk15	=[	$walk15,	dread_walk16	] {ai_walk(4);};
void()	dread_walk16	=[	$walk16,	dread_walk1		] {ai_walk(2);};

float DREAD_RUN_SPEED = 1.5;

void()	dread_run1	=[	$run1  ,	dread_run2	] {ai_run(18 * DREAD_RUN_SPEED);
	if (random() < 0.1)
		sound (self, CHAN_VOICE, "enforcer/idle1.wav", 1, ATTN_IDLE);
};
void()	dread_run2	=[	$run2  ,	dread_run3	] {ai_run(14 * DREAD_RUN_SPEED);};
void()	dread_run3	=[	$run3  ,	dread_run4	] {ai_run(7 * DREAD_RUN_SPEED);};
void()	dread_run4	=[	$run4  ,	dread_run5	] {ai_run(12 * DREAD_RUN_SPEED);};
void()	dread_run5	=[	$run5  ,	dread_run6	] {ai_run(14 * DREAD_RUN_SPEED);};
void()	dread_run6	=[	$run6  ,	dread_run7	] {ai_run(14 * DREAD_RUN_SPEED);};
void()	dread_run7	=[	$run7  ,	dread_run8	] {ai_run(7 * DREAD_RUN_SPEED);};
void()	dread_run8	=[	$run8  ,	dread_run1	] {ai_run(11 * DREAD_RUN_SPEED);};

void()	dread_paina1	=[	$paina1,	dread_paina2	] {};
void()	dread_paina2	=[	$paina2,	dread_paina3	] {};
void()	dread_paina3	=[	$paina3,	dread_paina4	] {};
void()	dread_paina4	=[	$paina4,	dread_run1		] {};

void()	dread_painb1	=[	$painb1,	dread_painb2	] {};
void()	dread_painb2	=[	$painb2,	dread_painb3	] {};
void()	dread_painb3	=[	$painb3,	dread_painb4	] {};
void()	dread_painb4	=[	$painb4,	dread_painb5	] {};
void()	dread_painb5	=[	$painb5,	dread_run1		] {};

void()	dread_painc1	=[	$painc1,	dread_painc2	] {};
void()	dread_painc2	=[	$painc2,	dread_painc3	] {};
void()	dread_painc3	=[	$painc3,	dread_painc4	] {};
void()	dread_painc4	=[	$painc4,	dread_painc5	] {};
void()	dread_painc5	=[	$painc5,	dread_painc6	] {};
void()	dread_painc6	=[	$painc6,	dread_painc7	] {};
void()	dread_painc7	=[	$painc7,	dread_painc8	] {};
void()	dread_painc8	=[	$painc8,	dread_run1		] {};

void(entity attacker, float damage)	dread_pain =
{
	local float r;

	if (self.health < self.max_health * 0.1) 		self.skin = 3;
	else if (self.health < self.max_health * 0.5 && self.health >= self.max_health * 0.25)	self.skin = 2;
	else if (self.health < self.max_health * 0.75 && self.health >= self.max_health * 0.5)	self.skin = 1;

	r = random ();
	if (self.pain_finished > time)
		return; 	// too soon

	if (random()*150 > damage)
		return;		// didn't flinch
		
	if (r < 0.5)
		sound (self, CHAN_VOICE, "dread/dread_pain1.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_VOICE, "dread/dread_pain2.wav", 1, ATTN_NORM);

	if (r < 0.33)
	{
		self.pain_finished = time + 2;
		dread_paina1 ();
	}
	else if (r < 0.66)
	{
		self.pain_finished = time + 2;
		dread_painb1 ();
	}
	else
	{
		self.pain_finished = time + 2;
		dread_painc1 ();
	}

	if (self.attack_finished > time) //turn off flame sound
	{
		sound (self, CHAN_WEAPON, "dread/flameoff.wav", 1, ATTN_NORM);
	}
	else //play sound anyway to be sure the channel is silent
	{
		sound (self, CHAN_WEAPON, "misc/null.wav", 0, ATTN_NORM);
	}
};


// these guys have flame-proof suits
float(entity inflictor, entity attacker, float damage, float orig_damage, float dmgtype) dread_damage = {
	if (dmgtype == DMGTYPE_BURN || dmgtype == DMGTYPE_BURN_LONG)
		return 0;
	else
		return damage;
};

//============================================================================




void()	dread_die1		=[	$death1,	dread_die2	] {};
void()	dread_die2		=[	$death2,	dread_die3	] {};
void()	dread_die3		=[	$death3,	dread_die4	] {self.solid = SOLID_TRIGGER; setorigin(self, self.origin);};
void()	dread_die4		=[	$death4,	dread_die5	] {ai_forward(14);};
void()	dread_die5		=[	$death5,	dread_die6	] {ai_forward(2);};
void()	dread_die6		=[	$death6,	dread_die7	] {};
void()	dread_die7		=[	$death7,	dread_die8	] {};
void()	dread_die8		=[	$death8,	dread_die9	] {};
void()	dread_die9		=[	$death9,	dread_die10	] {ai_forward(3);};
void()	dread_die10		=[	$death10,	dread_die11	] {ai_forward(5);};
void()	dread_die11		=[	$death11,	dread_die12	] {ai_forward(5);};
void()	dread_die12		=[	$death12,	dread_die13	] {ai_forward(5);};
void()	dread_die13		=[	$death13,	dread_die14	] {};
void()	dread_die14		=[	$death14,	dread_die14	] {monster_dead_dead();};

void()	dread_fdie1		=[	$fdeath1,	dread_fdie2	] {};
void()	dread_fdie2		=[	$fdeath2,	dread_fdie3	] {};
void()	dread_fdie3		=[	$fdeath3,	dread_fdie4	] {self.solid = SOLID_TRIGGER; setorigin(self, self.origin);};
void()	dread_fdie4		=[	$fdeath4,	dread_fdie5	] {};
void()	dread_fdie5		=[	$fdeath5,	dread_fdie6	] {};
void()	dread_fdie6		=[	$fdeath6,	dread_fdie7	] {};
void()	dread_fdie7		=[	$fdeath7,	dread_fdie8	] {};
void()	dread_fdie8		=[	$fdeath8,	dread_fdie9	] {};
void()	dread_fdie9		=[	$fdeath9,	dread_fdie10	] {};
void()	dread_fdie10	=[	$fdeath10,	dread_fdie11	] {};
void()	dread_fdie11	=[	$fdeath11,	dread_fdie11	] {monster_dead_dead();};


void() dread_die =
{
	if (self.health < -35) // gib
	{
		self.skin = 0;
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_dread.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		self.deadflag = DEAD_GIBBED;
	}
	else // regular death
	{

		self.skin = 3;
		sound (self, CHAN_VOICE, "dread/dread_death.wav", 1, ATTN_NORM);
		if (random() > 0.5)
			dread_die1 ();
		else
			dread_fdie1 ();
	}

	if (self.attack_finished > time) //turn off flame sound
	{
		sound (self, CHAN_WEAPON, "dread/flameoff.wav", 1, ATTN_NORM);
	}
	else //play sound anyway to be sure the channel is silent
	{
		sound (self, CHAN_WEAPON, "misc/null.wav", 0, ATTN_NORM);
	}
};

void() dread_sight = {
	if (random() > 0.5)
		sound (self, CHAN_VOICE, "dread/dread_sight.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_VOICE, "dread/dread_sight2.wav", 1, ATTN_NORM);
}


/*QUAKED monster_dreadnaught (1 0 0) (-16 -16 -24) (16 16 40) AMBUSH
Dreadnaught, 150 health points.

AMBUSH: dreadnaught will only wake up on really seeing the player, not another monster getting angry.
*/
void(entity e) monster_dreadnaught_start =
{
	local entity oself;

	oself = self;
	self = e;

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/dread.mdl");

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize(self, self.cmins, self.cmaxs);

	self.health = 150;
	if (self.obituary == "") self.obituary = "was incinerated by a Dreadnaught";

	self.th_stand = dread_stand1;
	self.th_walk = dread_walk1;
	self.th_run = dread_run1;
	self.th_pain = dread_pain;
	self.th_die = dread_die;
	self.th_melee = dread_atk1;
	self.th_sight = dread_sight;
	self.th_damage = dread_damage;
	
	self.missle = world;
	
	if (!self.yaw_speed)
		self.yaw_speed = 40; //make him turn faster than most monsters (harder to circle-strafe)

	walkmonster_start();

	self = oself;
};

void() monster_dreadnaught_spawner = {
	monster_spawner(monster_dreadnaught_start);
};


void() monster_dreadnaught =
{
	if (!SUB_InitEntity()) return;
	
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model2 ("progs/dread.mdl");
	precache_model2 ("progs/h_dread.mdl");

	precache_sound2 ("dread/dread_death.wav");
	precache_sound2 ("enforcer/idle1.wav");
	precache_sound2 ("dread/dread_pain1.wav");
	precache_sound2 ("dread/dread_pain2.wav");
	precache_sound2 ("dread/dread_sight.wav");
	precache_sound2 ("dread/dread_sight2.wav");
	
	precache_sound ("dread/flameon.wav");
	precache_sound ("dread/flameoff.wav");
	precache_sound ("misc/null.wav");
	
	precache_model ("progs/s_flame.spr");
	
	self.cmins = '-16 -16 -24';
	self.cmaxs = '16 16 40';
	
	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize(self, self.cmins, self.cmaxs);
	
	if (self.spawnflags & MONSTER_SPAWNER) {
		self.use = monster_dreadnaught_spawner;
		monster_spawner_updatecounter();
	}
	else {
		monster_dreadnaught_start(self);
	}
};