/*
==============================================================================

SOLDIER / PLAYER

==============================================================================
*/

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

$frame paind1 paind2 paind3 paind4 paind5 paind6 paind7 paind8
$frame paind9 paind10 paind11 paind12 paind13 paind14 paind15 paind16
$frame paind17 paind18 paind19



void() enforcer_fire =
{
	local vector org;

	self.effects = self.effects | EF_MUZZLEFLASH;
	makevectors (self.angles);
	
	org = self.origin + v_forward * 30 + v_right * 8.5 + '0 0 16';

	LaunchLaser(org, self.enemy.origin - self.origin);
};

//============================================================================

void()	enf_stand1	=[	$stand1,	enf_stand2	] {ai_stand();};
void()	enf_stand2	=[	$stand2,	enf_stand3	] {ai_stand();};
void()	enf_stand3	=[	$stand3,	enf_stand4	] {ai_stand();};
void()	enf_stand4	=[	$stand4,	enf_stand5	] {ai_stand();};
void()	enf_stand5	=[	$stand5,	enf_stand6	] {ai_stand();};
void()	enf_stand6	=[	$stand6,	enf_stand7	] {ai_stand();};
void()	enf_stand7	=[	$stand7,	enf_stand1	] {ai_stand();};

void()	enf_walk1	=[	$walk1 ,	enf_walk2	] {
if (random() < 0.2)
	sound (self, CHAN_VOICE, "enforcer/idle1.wav", 1, ATTN_IDLE);
ai_walk(2);};
void()	enf_walk2	=[	$walk2 ,	enf_walk3	] {ai_walk(4);};
void()	enf_walk3	=[	$walk3 ,	enf_walk4	] {ai_walk(4);};
void()	enf_walk4	=[	$walk4 ,	enf_walk5	] {ai_walk(3);};
void()	enf_walk5	=[	$walk5 ,	enf_walk6	] {ai_walk(1);};
void()	enf_walk6	=[	$walk6 ,	enf_walk7	] {ai_walk(2);};
void()	enf_walk7	=[	$walk7 ,	enf_walk8	] {ai_walk(2);};
void()	enf_walk8	=[	$walk8 ,	enf_walk9	] {ai_walk(1);};
void()	enf_walk9	=[	$walk9 ,	enf_walk10	] {ai_walk(2);};
void()	enf_walk10	=[	$walk10,	enf_walk11	] {ai_walk(4);};
void()	enf_walk11	=[	$walk11,	enf_walk12	] {ai_walk(4);};
void()	enf_walk12	=[	$walk12,	enf_walk13	] {ai_walk(1);};
void()	enf_walk13	=[	$walk13,	enf_walk14	] {ai_walk(2);};
void()	enf_walk14	=[	$walk14,	enf_walk15	] {ai_walk(3);};
void()	enf_walk15	=[	$walk15,	enf_walk16	] {ai_walk(4);};
void()	enf_walk16	=[	$walk16,	enf_walk1	] {ai_walk(2);};

void()	enf_run1	=[	$run1  ,	enf_run2	] {
if (random() < 0.2)
	sound (self, CHAN_VOICE, "enforcer/idle1.wav", 1, ATTN_IDLE);
ai_run(18);};
void()	enf_run2	=[	$run2  ,	enf_run3	] {ai_runjump(14);};
void()	enf_run3	=[	$run3  ,	enf_run4	] {ai_runjump(7);};
void()	enf_run4	=[	$run4  ,	enf_run5	] {ai_runjump(12);};
void()	enf_run5	=[	$run5  ,	enf_run6	] {ai_runjump(14);};
void()	enf_run6	=[	$run6  ,	enf_run7	] {ai_runjump(14);};
void()	enf_run7	=[	$run7  ,	enf_run8	] {ai_runjump(7);};
void()	enf_run8	=[	$run8  ,	enf_run1	] {ai_runjump(11);};

void()	enf_atk1	=[	$attack1,	enf_atk2	] {ai_face();};
void()	enf_atk2	=[	$attack2,	enf_atk3	] {ai_face();};
void()	enf_atk3	=[	$attack3,	enf_atk4	] {ai_face();};
void()	enf_atk4	=[	$attack4,	enf_atk5	] {ai_face();};
void()	enf_atk5	=[	$attack5,	enf_atk6	] {ai_face();};
void()	enf_atk6	=[	$attack6,	enf_atk7	] {enforcer_fire();};
void()	enf_atk7	=[	$attack7,	enf_atk8	] {ai_face();};
void()	enf_atk8	=[	$attack8,	enf_atk9	] {ai_face();};
void()	enf_atk9	=[	$attack5,	enf_atk10	] {ai_face();};
void()	enf_atk10	=[	$attack6,	enf_atk11	] {enforcer_fire();};
void()	enf_atk11	=[	$attack7,	enf_atk12	] {ai_face();};
void()	enf_atk12	=[	$attack8,	enf_atk13	] {ai_face();};
void()	enf_atk13	=[	$attack9,	enf_atk14	] {ai_face();};
void()	enf_atk14	=[	$attack10,	enf_run1	] {ai_face();
SUB_CheckRefire (enf_atk1);
};

void()	enf_paina1	=[	$paina1,	enf_paina2	] {};
void()	enf_paina2	=[	$paina2,	enf_paina3	] {};
void()	enf_paina3	=[	$paina3,	enf_paina4	] {};
void()	enf_paina4	=[	$paina4,	enf_run1	] {};

void()	enf_painb1	=[	$painb1,	enf_painb2	] {};
void()	enf_painb2	=[	$painb2,	enf_painb3	] {};
void()	enf_painb3	=[	$painb3,	enf_painb4	] {};
void()	enf_painb4	=[	$painb4,	enf_painb5	] {};
void()	enf_painb5	=[	$painb5,	enf_run1	] {};

void()	enf_painc1	=[	$painc1,	enf_painc2	] {};
void()	enf_painc2	=[	$painc2,	enf_painc3	] {};
void()	enf_painc3	=[	$painc3,	enf_painc4	] {};
void()	enf_painc4	=[	$painc4,	enf_painc5	] {};
void()	enf_painc5	=[	$painc5,	enf_painc6	] {};
void()	enf_painc6	=[	$painc6,	enf_painc7	] {};
void()	enf_painc7	=[	$painc7,	enf_painc8	] {};
void()	enf_painc8	=[	$painc8,	enf_run1	] {};

void()	enf_paind1	=[	$paind1,	enf_paind2	] {};
void()	enf_paind2	=[	$paind2,	enf_paind3	] {};
void()	enf_paind3	=[	$paind3,	enf_paind4	] {};
void()	enf_paind4	=[	$paind4,	enf_paind5	] {ai_painforward(2);};
void()	enf_paind5	=[	$paind5,	enf_paind6	] {ai_painforward(1);};
void()	enf_paind6	=[	$paind6,	enf_paind7	] {};
void()	enf_paind7	=[	$paind7,	enf_paind8	] {};
void()	enf_paind8	=[	$paind8,	enf_paind9	] {};
void()	enf_paind9	=[	$paind9,	enf_paind10	] {};
void()	enf_paind10	=[	$paind10,	enf_paind11	] {};
void()	enf_paind11	=[	$paind11,	enf_paind12	] {ai_painforward(1);};
void()	enf_paind12	=[	$paind12,	enf_paind13	] {ai_painforward(1);};
void()	enf_paind13	=[	$paind13,	enf_paind14	] {ai_painforward(1);};
void()	enf_paind14	=[	$paind14,	enf_paind15	] {};
void()	enf_paind15	=[	$paind15,	enf_paind16	] {};
void()	enf_paind16	=[	$paind16,	enf_paind17	] {ai_pain(1);};
void()	enf_paind17	=[	$paind17,	enf_paind18	] {ai_pain(1);};
void()	enf_paind18	=[	$paind18,	enf_paind19	] {};
void()	enf_paind19	=[	$paind19,	enf_run1	] {};

void(entity attacker, float damage)	enf_pain =
{
	local float r;

	if (self.health < self.max_health * 0.1) 		self.skin = 3;
	else if (self.health < self.max_health * 0.5 && self.health >= self.max_health * 0.25)	self.skin = 2;
	else if (self.health < self.max_health * 0.75 && self.health >= self.max_health * 0.5)	self.skin = 1;

	r = random ();
	if (self.pain_finished > time)
		return;

	
	if (r < 0.5)
		sound (self, CHAN_VOICE, "enforcer/pain1.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_VOICE, "enforcer/pain2.wav", 1, ATTN_NORM);

	if (r < 0.2)
	{
		self.pain_finished = time + 1;
		enf_paina1 ();
	}
	else if (r < 0.4)
	{
		self.pain_finished = time + 1;
		enf_painb1 ();
	}
	else if (r < 0.7)
	{
		self.pain_finished = time + 1;
		enf_painc1 ();
	}
	else
	{
		self.pain_finished = time + 2;
		enf_paind1 ();
	}
};

//============================================================================




void()	enf_die1	=[	$death1,	enf_die2	] {};
void()	enf_die2	=[	$death2,	enf_die3	] {};
void()	enf_die3	=[	$death3,	enf_die4	]
{self.solid = SOLID_TRIGGER; setorigin(self, self.origin);self.ammo_cells = 5;DropBackpack();};
void()	enf_die4	=[	$death4,	enf_die5	] {ai_forward(14);};
void()	enf_die5	=[	$death5,	enf_die6	] {ai_forward(2);};
void()	enf_die6	=[	$death6,	enf_die7	] {};
void()	enf_die7	=[	$death7,	enf_die8	] {};
void()	enf_die8	=[	$death8,	enf_die9	] {};
void()	enf_die9	=[	$death9,	enf_die10	] {ai_forward(3);};
void()	enf_die10	=[	$death10,	enf_die11	] {ai_forward(5);};
void()	enf_die11	=[	$death11,	enf_die12	] {ai_forward(5);};
void()	enf_die12	=[	$death12,	enf_die13	] {ai_forward(5);};
void()	enf_die13	=[	$death13,	enf_die14	] {};
void()	enf_die14	=[	$death14,	enf_die14	] {monster_dead_dead();};

void()	enf_fdie1	=[	$fdeath1,	enf_fdie2	] {

};
void()	enf_fdie2	=[	$fdeath2,	enf_fdie3	] {};
void()	enf_fdie3	=[	$fdeath3,	enf_fdie4	] 
{self.solid = SOLID_TRIGGER; setorigin(self, self.origin);self.ammo_cells = 5;DropBackpack();};
void()	enf_fdie4	=[	$fdeath4,	enf_fdie5	] {};
void()	enf_fdie5	=[	$fdeath5,	enf_fdie6	] {};
void()	enf_fdie6	=[	$fdeath6,	enf_fdie7	] {};
void()	enf_fdie7	=[	$fdeath7,	enf_fdie8	] {};
void()	enf_fdie8	=[	$fdeath8,	enf_fdie9	] {};
void()	enf_fdie9	=[	$fdeath9,	enf_fdie10	] {};
void()	enf_fdie10	=[	$fdeath10,	enf_fdie11	] {};
void()	enf_fdie11	=[	$fdeath11,	enf_fdie11	] {monster_dead_dead();};


void() enf_die =
{
// check for gib
	if (self.health < -35)
	{
		self.skin = 0;
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_mega.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		if (random() < 0.2)
        	ThrowGib ("progs/enf_gun.mdl", self.health);
		self.deadflag = DEAD_GIBBED;
		return;
	}
	self.skin = 3;
// regular death
	sound (self, CHAN_VOICE, "enforcer/death1.wav", 1, ATTN_NORM);
	if (random() > 0.5)
		enf_die1 ();
	else
		enf_fdie1 ();
};

void() enf_sight = {
	local float rsnd;
	rsnd = rint(random() * 3);			
	if (rsnd == 1)
		sound (self, CHAN_VOICE, "enforcer/sight1.wav", 1, ATTN_NORM);
	else if (rsnd == 2)
		sound (self, CHAN_VOICE, "enforcer/sight2.wav", 1, ATTN_NORM);
	else if (rsnd == 0)
		sound (self, CHAN_VOICE, "enforcer/sight3.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_VOICE, "enforcer/sight4.wav", 1, ATTN_NORM);
};

//void() monster_me;

/*QUAKED monster_enforcer (1 0 0) (-16 -16 -24) (16 16 40) Ambush

*/

void(entity e) monster_enforcer_start =
{
	local entity oself;

	oself = self;
	self = e;

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/enforcer_alk.mdl");

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize(self, self.cmins, self.cmaxs);

	self.health = 80;
	if (self.obituary == "") self.obituary = "was blasted by an Enforcer";

	self.th_stand = enf_stand1;
	self.th_walk = enf_walk1;
	self.th_run = enf_run1;
	self.th_pain = enf_pain;
	self.th_die = enf_die;
	self.th_missile = enf_atk1;
	self.th_sight = enf_sight;

	walkmonster_start();

	self = oself;
};

void() monster_enforcer_spawner = {
	monster_spawner(monster_enforcer_start);
};

void() monster_enforcer =
{
	if (!SUB_InitEntity()) return;
	

//monster_me();

	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model2 ("progs/enforcer_alk.mdl");
	precache_model2 ("progs/h_mega.mdl");
	precache_model2 ("progs/laser.mdl");
        precache_model2 ("progs/enf_gun.mdl");

	precache_sound2 ("enforcer/death1.wav");
	precache_sound2 ("enforcer/enfire.wav");
	precache_sound2 ("enforcer/enfstop.wav");
	precache_sound2 ("enforcer/idle1.wav");
	precache_sound2 ("enforcer/pain1.wav");
	precache_sound2 ("enforcer/pain2.wav");
	precache_sound2 ("enforcer/sight1.wav");
	precache_sound2 ("enforcer/sight2.wav");
	precache_sound2 ("enforcer/sight3.wav");
	precache_sound2 ("enforcer/sight4.wav");

	self.cmins = '-16 -16 -24';
	self.cmaxs = '16 16 40';

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize(self, self.cmins, self.cmaxs);
	
	if (self.spawnflags & MONSTER_SPAWNER) {
		self.use = monster_enforcer_spawner;
		monster_spawner_updatecounter();
	}
	else {
		monster_enforcer_start(self);
	}
};
