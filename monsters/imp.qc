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


void() impball_Touch =
{
	local vector org;
	local float damage;
	
	damage = zeroconvertdefault(self.dmg, 15);

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

void(vector org, vector vec) LaunchImpFireball =
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

	setmodel (newmis, "progs/fireball.mdl");
	setsize (newmis, '0 0 0', '0 0 0');		

	setorigin (newmis, org);

	newmis.velocity = vec * 600;
	newmis.angles = vectoangles(newmis.velocity);

	newmis.nextthink = time + 5;
	newmis.think = SUB_Remove;
	newmis.touch = impball_Touch;
};



void() imp_fire =
{
	local vector org;

	self.effects = self.effects | EF_MUZZLEFLASH;
	makevectors (self.angles);
	
	org = self.origin + v_forward * 30 + v_right * 8.5 + '0 0 16';

	LaunchImpFireball(org, self.enemy.origin - self.origin);
};

//============================================================================

void()	imp_stand1	=[	$stand1,	imp_stand2	] {ai_stand();};
void()	imp_stand2	=[	$stand2,	imp_stand3	] {ai_stand();};
void()	imp_stand3	=[	$stand3,	imp_stand4	] {ai_stand();};
void()	imp_stand4	=[	$stand4,	imp_stand5	] {ai_stand();};
void()	imp_stand5	=[	$stand5,	imp_stand6	] {ai_stand();};
void()	imp_stand6	=[	$stand6,	imp_stand7	] {ai_stand();};
void()	imp_stand7	=[	$stand7,	imp_stand1	] {ai_stand();};

void()	imp_walk1	=[	$walk1 ,	imp_walk2	] {
if (random() < 0.2)
	sound (self, CHAN_VOICE, "imp/imp_idle.wav", 1, ATTN_IDLE);
ai_walk(2);};
void()	imp_walk2	=[	$walk2 ,	imp_walk3	] {ai_walk(4);};
void()	imp_walk3	=[	$walk3 ,	imp_walk4	] {ai_walk(4);};
void()	imp_walk4	=[	$walk4 ,	imp_walk5	] {ai_walk(3);};
void()	imp_walk5	=[	$walk5 ,	imp_walk6	] {ai_walk(1);};
void()	imp_walk6	=[	$walk6 ,	imp_walk7	] {ai_walk(2);};
void()	imp_walk7	=[	$walk7 ,	imp_walk8	] {ai_walk(2);};
void()	imp_walk8	=[	$walk8 ,	imp_walk9	] {ai_walk(1);};
void()	imp_walk9	=[	$walk9 ,	imp_walk10	] {ai_walk(2);};
void()	imp_walk10	=[	$walk10,	imp_walk11	] {ai_walk(4);};
void()	imp_walk11	=[	$walk11,	imp_walk12	] {ai_walk(4);};
void()	imp_walk12	=[	$walk12,	imp_walk13	] {ai_walk(1);};
void()	imp_walk13	=[	$walk13,	imp_walk14	] {ai_walk(2);};
void()	imp_walk14	=[	$walk14,	imp_walk15	] {ai_walk(3);};
void()	imp_walk15	=[	$walk15,	imp_walk16	] {ai_walk(4);};
void()	imp_walk16	=[	$walk16,	imp_walk1	] {ai_walk(2);};

void()	imp_run1	=[	$run1  ,	imp_run2	] {
if (random() < 0.2)
	sound (self, CHAN_VOICE, "imp/imp_idle.wav", 1, ATTN_IDLE);
ai_run(18);};
void()	imp_run2	=[	$run2  ,	imp_run3	] {ai_runjump(14);};
void()	imp_run3	=[	$run3  ,	imp_run4	] {ai_runjump(7);};
void()	imp_run4	=[	$run4  ,	imp_run5	] {ai_runjump(12);};
void()	imp_run5	=[	$run5  ,	imp_run6	] {ai_runjump(14);};
void()	imp_run6	=[	$run6  ,	imp_run7	] {ai_runjump(14);};
void()	imp_run7	=[	$run7  ,	imp_run8	] {ai_runjump(7);};
void()	imp_run8	=[	$run8  ,	imp_run1	] {ai_runjump(11);};

void()	imp_atk1	=[	$attack1,	imp_atk2	] {ai_face();};
void()	imp_atk2	=[	$attack2,	imp_atk3	] {ai_face();};
void()	imp_atk3	=[	$attack3,	imp_atk4	] {ai_face();};
void()	imp_atk4	=[	$attack4,	imp_atk5	] {ai_face();};
void()	imp_atk5	=[	$attack5,	imp_atk6	] {ai_face();};
void()	imp_atk6	=[	$attack6,	imp_atk7	] {imp_fire();};
void()	imp_atk7	=[	$attack7,	imp_atk8	] {ai_face();};
void()	imp_atk8	=[	$attack8,	imp_atk9	] {ai_face();};
void()	imp_atk9	=[	$attack5,	imp_atk10	] {ai_face();};
void()	imp_atk10	=[	$attack6,	imp_atk11	] {imp_fire();};
void()	imp_atk11	=[	$attack7,	imp_atk12	] {ai_face();};
void()	imp_atk12	=[	$attack8,	imp_atk13	] {ai_face();};
void()	imp_atk13	=[	$attack9,	imp_atk14	] {ai_face();};
void()	imp_atk14	=[	$attack10,	imp_run1	] {ai_face();
SUB_CheckRefire (imp_atk1);
};

void()	imp_paina1	=[	$paina1,	imp_paina2	] {};
void()	imp_paina2	=[	$paina2,	imp_paina3	] {};
void()	imp_paina3	=[	$paina3,	imp_paina4	] {};
void()	imp_paina4	=[	$paina4,	imp_run1	] {};

void()	imp_painb1	=[	$painb1,	imp_painb2	] {};
void()	imp_painb2	=[	$painb2,	imp_painb3	] {};
void()	imp_painb3	=[	$painb3,	imp_painb4	] {};
void()	imp_painb4	=[	$painb4,	imp_painb5	] {};
void()	imp_painb5	=[	$painb5,	imp_run1	] {};

void()	imp_painc1	=[	$painc1,	imp_painc2	] {};
void()	imp_painc2	=[	$painc2,	imp_painc3	] {};
void()	imp_painc3	=[	$painc3,	imp_painc4	] {};
void()	imp_painc4	=[	$painc4,	imp_painc5	] {};
void()	imp_painc5	=[	$painc5,	imp_painc6	] {};
void()	imp_painc6	=[	$painc6,	imp_painc7	] {};
void()	imp_painc7	=[	$painc7,	imp_painc8	] {};
void()	imp_painc8	=[	$painc8,	imp_run1	] {};

void()	imp_paind1	=[	$paind1,	imp_paind2	] {};
void()	imp_paind2	=[	$paind2,	imp_paind3	] {};
void()	imp_paind3	=[	$paind3,	imp_paind4	] {};
void()	imp_paind4	=[	$paind4,	imp_paind5	] {ai_painforward(2);};
void()	imp_paind5	=[	$paind5,	imp_paind6	] {ai_painforward(1);};
void()	imp_paind6	=[	$paind6,	imp_paind7	] {};
void()	imp_paind7	=[	$paind7,	imp_paind8	] {};
void()	imp_paind8	=[	$paind8,	imp_paind9	] {};
void()	imp_paind9	=[	$paind9,	imp_paind10	] {};
void()	imp_paind10	=[	$paind10,	imp_paind11	] {};
void()	imp_paind11	=[	$paind11,	imp_paind12	] {ai_painforward(1);};
void()	imp_paind12	=[	$paind12,	imp_paind13	] {ai_painforward(1);};
void()	imp_paind13	=[	$paind13,	imp_paind14	] {ai_painforward(1);};
void()	imp_paind14	=[	$paind14,	imp_paind15	] {};
void()	imp_paind15	=[	$paind15,	imp_paind16	] {};
void()	imp_paind16	=[	$paind16,	imp_paind17	] {ai_pain(1);};
void()	imp_paind17	=[	$paind17,	imp_paind18	] {ai_pain(1);};
void()	imp_paind18	=[	$paind18,	imp_paind19	] {};
void()	imp_paind19	=[	$paind19,	imp_run1	] {};

void(entity attacker, float damage)	imp_pain =
{
	local float r;


	r = random ();
	if (self.pain_finished > time)
		return;

	

	sound (self, CHAN_VOICE, "imp/imp_hurt.wav", 1, ATTN_NORM);


	if (r < 0.2)
	{
		self.pain_finished = time + 1;
		imp_paina1 ();
	}
	else if (r < 0.4)
	{
		self.pain_finished = time + 1;
		imp_painb1 ();
	}
	else if (r < 0.7)
	{
		self.pain_finished = time + 1;
		imp_painc1 ();
	}
	else
	{
		self.pain_finished = time + 2;
		imp_paind1 ();
	}
};

//============================================================================




void()	imp_die1	=[	$death1,	imp_die2	] {};
void()	imp_die2	=[	$death2,	imp_die3	] {};
void()	imp_die3	=[	$death3,	imp_die4	]
{self.solid = SOLID_TRIGGER; setorigin(self, self.origin);self.ammo_cells = 5;};
void()	imp_die4	=[	$death4,	imp_die5	] {ai_forward(14);};
void()	imp_die5	=[	$death5,	imp_die6	] {ai_forward(2);};
void()	imp_die6	=[	$death6,	imp_die7	] {};
void()	imp_die7	=[	$death7,	imp_die8	] {};
void()	imp_die8	=[	$death8,	imp_die9	] {};
void()	imp_die9	=[	$death9,	imp_die10	] {ai_forward(3);};
void()	imp_die10	=[	$death10,	imp_die11	] {ai_forward(5);};
void()	imp_die11	=[	$death11,	imp_die12	] {ai_forward(5);};
void()	imp_die12	=[	$death12,	imp_die13	] {ai_forward(5);};
void()	imp_die13	=[	$death13,	imp_die14	] {};
void()	imp_die14	=[	$death14,	imp_die14	] {monster_dead_dead();};

void()	imp_fdie1	=[	$fdeath1,	imp_fdie2	] {

};
void()	imp_fdie2	=[	$fdeath2,	imp_fdie3	] {};
void()	imp_fdie3	=[	$fdeath3,	imp_fdie4	] 
{self.solid = SOLID_TRIGGER; setorigin(self, self.origin);self.ammo_cells = 5;};
void()	imp_fdie4	=[	$fdeath4,	imp_fdie5	] {};
void()	imp_fdie5	=[	$fdeath5,	imp_fdie6	] {};
void()	imp_fdie6	=[	$fdeath6,	imp_fdie7	] {};
void()	imp_fdie7	=[	$fdeath7,	imp_fdie8	] {};
void()	imp_fdie8	=[	$fdeath8,	imp_fdie9	] {};
void()	imp_fdie9	=[	$fdeath9,	imp_fdie10	] {};
void()	imp_fdie10	=[	$fdeath10,	imp_fdie11	] {};
void()	imp_fdie11	=[	$fdeath11,	imp_fdie11	] {monster_dead_dead();};


void() imp_die =
{
// check for gib
	if (self.health < -35)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_imp.mdl", self.health);
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
		imp_die1 ();
	else
		imp_fdie1 ();
};

void() imp_sight = {
	local float rsnd;
	rsnd = rint(random() * 3);			

	sound (self, CHAN_VOICE, "imp/imp_sight1.wav", 1, ATTN_NORM);

};


/*QUAKED monster_imp (1 0 0) (-16 -16 -24) (16 16 40) Ambush

*/

void(entity e) monster_imp_start =
{
	local entity oself;

	oself = self;
	self = e;

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/imp.mdl");

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize(self, self.cmins, self.cmaxs);

	self.health = 120;
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

void() monster_imp_spawner = {
	monster_spawner(monster_imp_start);
};

void() monster_imp =
{
	if (!SUB_InitEntity()) return;
	

//monster_me();

	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model2 ("progs/imp.mdl");
	precache_model2 ("progs/h_imp.mdl");
	precache_model2 ("progs/fireball.mdl");

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
		self.use = monster_imp_spawner;
		monster_spawner_updatecounter();
	}
	else {
		monster_imp_start(self);
	}
};

void() monster_enforcer = {monster_imp();}