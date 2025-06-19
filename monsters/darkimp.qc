/*
==============================================================================

IMP

==============================================================================
*/

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

$frame paind1 paind2 paind3 paind4 paind5 paind6 paind7 paind8
$frame paind9 paind10 paind11 paind12 paind13 paind14 paind15 paind16
$frame paind17 paind18 paind19


void() darkimpball_Touch =
{
	local vector org;
	local float damage;
	
	damage = zeroconvertdefault(self.dmg, 20);

	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
	sound (self, CHAN_WEAPON, "imp/imp_fireball_hit.wav", 1, ATTN_STATIC);
	org = self.origin - 8*normalize(self.velocity);

	if (other.health)
	{
		ImpactSpawn(org, self.velocity*0.2, 15, other.bloodtype);
		T_Damage(other, self, self.owner, damage, DMGTYPE_ENERGY);
	}
	else
	{
		gunshot(org);
	}
	
	remove(self);	
};

void(vector org, vector vec) LaunchDarkImpFireball =
{
	//local	vector	vec;
		
	sound (self, CHAN_WEAPON, "imp/imp_fire.wav", 1, ATTN_NORM);

	vec = normalize(vec);
	
	newmis = spawn();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLY;
	newmis.solid = SOLID_BBOX;
	newmis.effects = EF_DIMLIGHT;
	newmis.flags = newmis.flags | FL_PROJECTILE;

	setmodel (newmis, "progs/fireball_dark.mdl");
	setsize (newmis, '0 0 0', '0 0 0');		

	setorigin (newmis, org);

	newmis.velocity = vec * 600;
	newmis.angles = vectoangles(newmis.velocity);

	newmis.nextthink = time + 5;
	newmis.think = SUB_Remove;
	newmis.touch = darkimpball_Touch;
};



void() darkimp_fire =
{
	local vector org;

	self.effects = self.effects | EF_MUZZLEFLASH;
	makevectors (self.angles);
	
	org = self.origin + v_forward * 30 + v_right * 8.5 + '0 0 16';

	LaunchDarkImpFireball(org, self.enemy.origin - self.origin);
};

//============================================================================

void()	darkimp_stand1	=[	$stand1,	darkimp_stand2	] {ai_stand();};
void()	darkimp_stand2	=[	$stand2,	darkimp_stand3	] {ai_stand();};
void()	darkimp_stand3	=[	$stand3,	darkimp_stand4	] {ai_stand();};
void()	darkimp_stand4	=[	$stand4,	darkimp_stand5	] {ai_stand();};
void()	darkimp_stand5	=[	$stand5,	darkimp_stand6	] {ai_stand();};
void()	darkimp_stand6	=[	$stand6,	darkimp_stand7	] {ai_stand();};
void()	darkimp_stand7	=[	$stand7,	darkimp_stand1	] {ai_stand();};

void()	darkimp_walk1	=[	$walk1 ,	darkimp_walk2	] {
if (random() < 0.2)
	sound (self, CHAN_VOICE, "imp/imp_idle.wav", 1, ATTN_IDLE);
ai_walk(2);};
void()	darkimp_walk2	=[	$walk2 ,	darkimp_walk3	] {ai_walk(4);};
void()	darkimp_walk3	=[	$walk3 ,	darkimp_walk4	] {ai_walk(4);};
void()	darkimp_walk4	=[	$walk4 ,	darkimp_walk5	] {ai_walk(3);};
void()	darkimp_walk5	=[	$walk5 ,	darkimp_walk6	] {ai_walk(1);};
void()	darkimp_walk6	=[	$walk6 ,	darkimp_walk7	] {ai_walk(2);};
void()	darkimp_walk7	=[	$walk7 ,	darkimp_walk8	] {ai_walk(2);};
void()	darkimp_walk8	=[	$walk8 ,	darkimp_walk9	] {ai_walk(1);};
void()	darkimp_walk9	=[	$walk9 ,	darkimp_walk10	] {ai_walk(2);};
void()	darkimp_walk10	=[	$walk10,	darkimp_walk11	] {ai_walk(4);};
void()	darkimp_walk11	=[	$walk11,	darkimp_walk12	] {ai_walk(4);};
void()	darkimp_walk12	=[	$walk12,	darkimp_walk13	] {ai_walk(1);};
void()	darkimp_walk13	=[	$walk13,	darkimp_walk14	] {ai_walk(2);};
void()	darkimp_walk14	=[	$walk14,	darkimp_walk15	] {ai_walk(3);};
void()	darkimp_walk15	=[	$walk15,	darkimp_walk16	] {ai_walk(4);};
void()	darkimp_walk16	=[	$walk16,	darkimp_walk1	] {ai_walk(2);};


float darkimp_speed = 1.5;

void()	darkimp_run1	=[	$run1  ,	darkimp_run2	] {
	if (random() < 0.2)
		sound (self, CHAN_VOICE, "imp/imp_idle.wav", 1, ATTN_IDLE);
	ai_run(18*darkimp_speed);
};
void()	darkimp_run2	=[	$run2  ,	darkimp_run3	] {ai_runjump(14*darkimp_speed);};
void()	darkimp_run3	=[	$run3  ,	darkimp_run4	] {ai_runjump(7*darkimp_speed);};
void()	darkimp_run4	=[	$run4  ,	darkimp_run5	] {ai_runjump(12*darkimp_speed);};
void()	darkimp_run5	=[	$run5  ,	darkimp_run6	] {ai_runjump(14*darkimp_speed);};
void()	darkimp_run6	=[	$run6  ,	darkimp_run7	] {ai_runjump(14*darkimp_speed);};
void()	darkimp_run7	=[	$run7  ,	darkimp_run8	] {ai_runjump(7*darkimp_speed);};
void()	darkimp_run8	=[	$run8  ,	darkimp_run1	] {ai_runjump(11*darkimp_speed);};

void()	darkimp_atk1	=[	$attack1,	darkimp_atk2	] {ai_face();};
void()	darkimp_atk2	=[	$attack2,	darkimp_atk3	] {ai_face();};
void()	darkimp_atk3	=[	$attack3,	darkimp_atk4	] {ai_face();};
void()	darkimp_atk4	=[	$attack4,	darkimp_atk5	] {ai_face();};
void()	darkimp_atk5	=[	$attack5,	darkimp_atk6	] {ai_face();};
void()	darkimp_atk6	=[	$attack6,	darkimp_atk7	] {darkimp_fire();};
void()	darkimp_atk7	=[	$attack7,	darkimp_atk8	] {ai_face();};
void()	darkimp_atk8	=[	$attack8,	darkimp_atk9	] {ai_face();};
void()	darkimp_atk9	=[	$attack5,	darkimp_atk10	] {ai_face();};
void()	darkimp_atk10	=[	$attack6,	darkimp_atk11	] {darkimp_fire();};
void()	darkimp_atk11	=[	$attack7,	darkimp_atk12	] {ai_face();};
void()	darkimp_atk12	=[	$attack8,	darkimp_atk13	] {ai_face();};
void()	darkimp_atk13	=[	$attack9,	darkimp_atk14	] {ai_face();};
void()	darkimp_atk14	=[	$attack10,	darkimp_run1	] {ai_face();
SUB_CheckRefire (darkimp_atk1);
};

void()	darkimp_paina1	=[	$paina1,	darkimp_paina2	] {};
void()	darkimp_paina2	=[	$paina2,	darkimp_paina3	] {};
void()	darkimp_paina3	=[	$paina3,	darkimp_paina4	] {};
void()	darkimp_paina4	=[	$paina4,	darkimp_run1	] {};

void()	darkimp_painb1	=[	$painb1,	darkimp_painb2	] {};
void()	darkimp_painb2	=[	$painb2,	darkimp_painb3	] {};
void()	darkimp_painb3	=[	$painb3,	darkimp_painb4	] {};
void()	darkimp_painb4	=[	$painb4,	darkimp_painb5	] {};
void()	darkimp_painb5	=[	$painb5,	darkimp_run1	] {};

void()	darkimp_painc1	=[	$painc1,	darkimp_painc2	] {};
void()	darkimp_painc2	=[	$painc2,	darkimp_painc3	] {};
void()	darkimp_painc3	=[	$painc3,	darkimp_painc4	] {};
void()	darkimp_painc4	=[	$painc4,	darkimp_painc5	] {};
void()	darkimp_painc5	=[	$painc5,	darkimp_painc6	] {};
void()	darkimp_painc6	=[	$painc6,	darkimp_painc7	] {};
void()	darkimp_painc7	=[	$painc7,	darkimp_painc8	] {};
void()	darkimp_painc8	=[	$painc8,	darkimp_run1	] {};

void()	darkimp_paind1	=[	$paind1,	darkimp_paind2	] {};
void()	darkimp_paind2	=[	$paind2,	darkimp_paind3	] {};
void()	darkimp_paind3	=[	$paind3,	darkimp_paind4	] {};
void()	darkimp_paind4	=[	$paind4,	darkimp_paind5	] {ai_painforward(2);};
void()	darkimp_paind5	=[	$paind5,	darkimp_paind6	] {ai_painforward(1);};
void()	darkimp_paind6	=[	$paind6,	darkimp_paind7	] {};
void()	darkimp_paind7	=[	$paind7,	darkimp_paind8	] {};
void()	darkimp_paind8	=[	$paind8,	darkimp_paind9	] {};
void()	darkimp_paind9	=[	$paind9,	darkimp_paind10	] {};
void()	darkimp_paind10	=[	$paind10,	darkimp_paind11	] {};
void()	darkimp_paind11	=[	$paind11,	darkimp_paind12	] {ai_painforward(1);};
void()	darkimp_paind12	=[	$paind12,	darkimp_paind13	] {ai_painforward(1);};
void()	darkimp_paind13	=[	$paind13,	darkimp_paind14	] {ai_painforward(1);};
void()	darkimp_paind14	=[	$paind14,	darkimp_paind15	] {};
void()	darkimp_paind15	=[	$paind15,	darkimp_paind16	] {};
void()	darkimp_paind16	=[	$paind16,	darkimp_paind17	] {ai_pain(1);};
void()	darkimp_paind17	=[	$paind17,	darkimp_paind18	] {ai_pain(1);};
void()	darkimp_paind18	=[	$paind18,	darkimp_paind19	] {};
void()	darkimp_paind19	=[	$paind19,	darkimp_run1	] {};

void(entity attacker, float damage)	darkimp_pain =
{
	local float r;


	r = random ();
	if (self.pain_finished > time)
		return;

	

	sound (self, CHAN_VOICE, "imp/imp_hurt.wav", 1, ATTN_NORM);


	if (r < 0.2)
	{
		self.pain_finished = time + 1;
		darkimp_paina1 ();
	}
	else if (r < 0.4)
	{
		self.pain_finished = time + 1;
		darkimp_painb1 ();
	}
	else if (r < 0.7)
	{
		self.pain_finished = time + 1;
		darkimp_painc1 ();
	}
	else
	{
		self.pain_finished = time + 2;
		darkimp_paind1 ();
	}
};

//============================================================================




void()	darkimp_die1	=[	$death1,	darkimp_die2	] {};
void()	darkimp_die2	=[	$death2,	darkimp_die3	] {};
void()	darkimp_die3	=[	$death3,	darkimp_die4	]
{self.solid = SOLID_TRIGGER; setorigin(self, self.origin);self.ammo_cells = 5;};
void()	darkimp_die4	=[	$death4,	darkimp_die5	] {ai_forward(14);};
void()	darkimp_die5	=[	$death5,	darkimp_die6	] {ai_forward(2);};
void()	darkimp_die6	=[	$death6,	darkimp_die7	] {};
void()	darkimp_die7	=[	$death7,	darkimp_die8	] {};
void()	darkimp_die8	=[	$death8,	darkimp_die9	] {};
void()	darkimp_die9	=[	$death9,	darkimp_die10	] {ai_forward(3);};
void()	darkimp_die10	=[	$death10,	darkimp_die11	] {ai_forward(5);};
void()	darkimp_die11	=[	$death11,	darkimp_die12	] {ai_forward(5);};
void()	darkimp_die12	=[	$death12,	darkimp_die13	] {ai_forward(5);};
void()	darkimp_die13	=[	$death13,	darkimp_die14	] {};
void()	darkimp_die14	=[	$death14,	darkimp_die14	] {monster_dead_dead();};

void()	darkimp_fdie1	=[	$fdeath1,	darkimp_fdie2	] {

};
void()	darkimp_fdie2	=[	$fdeath2,	darkimp_fdie3	] {};
void()	darkimp_fdie3	=[	$fdeath3,	darkimp_fdie4	] 
{self.solid = SOLID_TRIGGER; setorigin(self, self.origin);self.ammo_cells = 5;};
void()	darkimp_fdie4	=[	$fdeath4,	darkimp_fdie5	] {};
void()	darkimp_fdie5	=[	$fdeath5,	darkimp_fdie6	] {};
void()	darkimp_fdie6	=[	$fdeath6,	darkimp_fdie7	] {};
void()	darkimp_fdie7	=[	$fdeath7,	darkimp_fdie8	] {};
void()	darkimp_fdie8	=[	$fdeath8,	darkimp_fdie9	] {};
void()	darkimp_fdie9	=[	$fdeath9,	darkimp_fdie10	] {};
void()	darkimp_fdie10	=[	$fdeath10,	darkimp_fdie11	] {};
void()	darkimp_fdie11	=[	$fdeath11,	darkimp_fdie11	] {monster_dead_dead();};


void() darkimp_die =
{
// check for gib
	if (self.health < -35)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_imp_dark.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);

		self.deadflag = DEAD_GIBBED;
		return;
	}
// regular death
	sound (self, CHAN_VOICE, "imp/imp_die.wav", 1, ATTN_NORM);
	if (random() > 0.5)
		darkimp_die1 ();
	else
		darkimp_fdie1 ();
};

void() darkimp_sight = {
	local float rsnd;
	rsnd = rint(random() * 3);			

	sound (self, CHAN_VOICE, "imp/imp_sight1.wav", 1, ATTN_NORM);

};


/*QUAKED monster_imp (1 0 0) (-16 -16 -24) (16 16 40) Ambush

*/

void(entity e) monster_darkimp_start =
{
	local entity oself;

	oself = self;
	self = e;

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/imp_dark.mdl");
	if (!self.alpha) self.alpha = 0.5;

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize(self, self.cmins, self.cmaxs);

	self.health = 200;
	if (self.obituary == "") self.obituary = "was blasted by an imp";

	self.th_stand = imp_stand1;
	self.th_walk = imp_walk1;
	self.th_run = imp_run1;
	self.th_pain = imp_pain;
	self.th_die = imp_die;
	self.th_missile = imp_atk1;
	self.th_sight = imp_sight;

	walkmonster_start();

	self = oself;
};

void() monster_darkimp_spawner = {
	monster_spawner(monster_imp_start);
};

void() monster_darkimp =
{
	if (!SUB_InitEntity()) return;
	

//monster_me();

	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model2 ("progs/imp_dark.mdl");
	precache_model2 ("progs/h_imp_dark.mdl");
	precache_model2 ("progs/fireball_dark.mdl");

	precache_sound2 ("imp/imp_die.wav");
	precache_sound2 ("imp/imp_fire.wav");
	precache_sound2 ("imp/imp_fireball_hit.wav");
	precache_sound2 ("imp/imp_hurt.wav");
	precache_sound2 ("imp/imp_idle.wav");
	precache_sound2 ("imp/imp_sight1.wav");


	self.cmins = '-16 -16 -24';
	self.cmaxs = '16 16 40';

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize(self, self.cmins, self.cmaxs);
	
	if (self.spawnflags & MONSTER_SPAWNER) {
		self.use = monster_darkimp_spawner;
		monster_spawner_updatecounter();
	}
	else {
		monster_darkimp_start(self);
	}
};
