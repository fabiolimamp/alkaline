/*
==============================================================================

BAMBLER - by Greenwood & Markie Music (concept)

Bambler is a Bald shAMBLER. He's 20% smaller, a tad weaker, and melee only.
He's sort of like Doom's Pinky demon for Alkaline (and he's pink too!).
P.S. Markie hates the name Bambler :)

==============================================================================
*/

$cd id1/models/bams
$origin 0 0 24
$base base		
$skin base

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9
$frame stand10 stand11 stand12 stand13 stand14 stand15 stand16 stand17

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 
$frame walk8 walk9 walk10 walk11 walk12

$frame	run1 run2 run3 run4 run5 run6

$frame smash1 smash2 smash3 smash4 smash5 smash6 smash7 
$frame smash8 smash9 smash10 smash11 smash12

$frame swingr1 swingr2 swingr3 swingr4 swingr5 
$frame swingr6 swingr7 swingr8 swingr9

$frame swingl1 swingl2 swingl3 swingl4 swingl5 
$frame swingl6 swingl7 swingl8 swingl9

$frame magic1 magic2 magic3 magic4 magic5 
$frame magic6 magic7 magic8 magic9 magic10 magic11 magic12

$frame pain1 pain2 pain3 pain4 pain5 pain6

$frame death1 death2 death3 death4 death5 death6 
$frame death7 death8 death9 death10 death11

void() bam_stand1	=[	$stand1,	bam_stand2	] {ai_stand();};
void() bam_stand2	=[	$stand2,	bam_stand3	] {ai_stand();};
void() bam_stand3	=[	$stand3,	bam_stand4	] {ai_stand();};
void() bam_stand4	=[	$stand4,	bam_stand5	] {ai_stand();};
void() bam_stand5	=[	$stand5,	bam_stand6	] {ai_stand();};
void() bam_stand6	=[	$stand6,	bam_stand7	] {ai_stand();};
void() bam_stand7	=[	$stand7,	bam_stand8	] {ai_stand();};
void() bam_stand8	=[	$stand8,	bam_stand9	] {ai_stand();};
void() bam_stand9	=[	$stand9,	bam_stand10] {ai_stand();};
void() bam_stand10	=[	$stand10,	bam_stand11] {ai_stand();};
void() bam_stand11	=[	$stand11,	bam_stand12] {ai_stand();};
void() bam_stand12	=[	$stand12,	bam_stand13] {ai_stand();};
void() bam_stand13	=[	$stand13,	bam_stand14] {ai_stand();};
void() bam_stand14	=[	$stand14,	bam_stand15] {ai_stand();};
void() bam_stand15	=[	$stand15,	bam_stand16] {ai_stand();};
void() bam_stand16	=[	$stand16,	bam_stand17] {ai_stand();};
void() bam_stand17	=[	$stand17,	bam_stand1	] {ai_stand();};

void() bam_walk1		=[      $walk1,        bam_walk2 ] {ai_walk(10);};
void() bam_walk2       =[      $walk2,        bam_walk3 ] {ai_walk(9);};
void() bam_walk3       =[      $walk3,        bam_walk4 ] {ai_walk(9);};
void() bam_walk4       =[      $walk4,        bam_walk5 ] {ai_walk(5);};
void() bam_walk5       =[      $walk5,        bam_walk6 ] {ai_walk(6);};
void() bam_walk6       =[      $walk6,        bam_walk7 ] {ai_walk(12);};
void() bam_walk7       =[      $walk7,        bam_walk8 ] {ai_walk(8);};
void() bam_walk8       =[      $walk8,        bam_walk9 ] {ai_walk(3);};
void() bam_walk9       =[      $walk9,        bam_walk10] {ai_walk(13);};
void() bam_walk10      =[      $walk10,       bam_walk11] {ai_walk(9);};
void() bam_walk11      =[      $walk11,       bam_walk12] {ai_walk(7);};
void() bam_walk12      =[      $walk12,       bam_walk1 ] {ai_walk(7);
if (random() > 0.8)
	sound (self, CHAN_VOICE, "bambler/sidle.wav", 1, ATTN_IDLE);};

void() bam_run1       =[      $run1,        bam_run2      ] {ai_run(20);};
void() bam_run2       =[      $run2,        bam_run3      ] {ai_run(24);};
void() bam_run3       =[      $run3,        bam_run4      ] {ai_run(20);};
void() bam_run4       =[      $run4,        bam_run5      ] {ai_run(20);};
void() bam_run5       =[      $run5,        bam_run6      ] {ai_run(24);};
void() bam_run6       =[      $run6,        bam_run1      ] {ai_run(20);
if (random() > 0.8)
	sound (self, CHAN_VOICE, "bambler/sidle.wav", 1, ATTN_IDLE);
};

void() bam_smash1     =[      $smash1,       bam_smash2    ] {
sound (self, CHAN_VOICE, "bambler/melee1.wav", 1, ATTN_NORM);
ai_charge(2);};
void() bam_smash2     =[      $smash2,       bam_smash3    ] {ai_charge(6);};
void() bam_smash3     =[      $smash3,       bam_smash4    ] {ai_charge(6);};
void() bam_smash4     =[      $smash4,       bam_smash5    ] {ai_charge(5);};
void() bam_smash5     =[      $smash5,       bam_smash6    ] {ai_charge(4);};
void() bam_smash6     =[      $smash6,       bam_smash7    ] {ai_charge(1);};
void() bam_smash7     =[      $smash7,       bam_smash8    ] {ai_charge(0);};
void() bam_smash8     =[      $smash8,       bam_smash9    ] {ai_charge(0);};
void() bam_smash9     =[      $smash9,       bam_smash10   ] {ai_charge(0);};
void() bam_smash10    =[      $smash10,      bam_smash11   ] {
local vector	delta;
local float 	ldmg;

	if (!self.enemy)
		return;
	ai_charge(0);

	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 100)
		return;
	if (!CanDamage (self.enemy, self))
		return;
		
	ldmg = (random() + random() + random()) * 40;
	T_Damage (self.enemy, self, self, ldmg);
	sound (self, CHAN_VOICE, "bambler/smack.wav", 1, ATTN_NORM);

	SpawnMeatSpray (self.origin + v_forward*16, crandom() * 100 * v_right);
	SpawnMeatSpray (self.origin + v_forward*16, crandom() * 100 * v_right);
};
void() bam_smash11    =[      $smash11,      bam_smash12   ] {ai_charge(5);};
void() bam_smash12    =[      $smash12,      bam_run1	   ] {ai_charge(4);};

void() bam_swingr1;

void(float side) bamClaw =
{
local vector	delta;
local float 	ldmg;

	if (!self.enemy)
		return;
	ai_charge(10);

	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 100)
		return;
		
	ldmg = (random() + random() + random()) * 20;
	T_Damage (self.enemy, self, self, ldmg);
	sound (self, CHAN_VOICE, "bambler/smack.wav", 1, ATTN_NORM);

	if (side)
	{
		makevectors (self.angles);
		SpawnMeatSpray (self.origin + v_forward*16, side * v_right);
	}
};

void() bam_swingl1	=[      $swingl1,      bam_swingl2   ] {
sound (self, CHAN_VOICE, "bambler/melee2.wav", 1, ATTN_NORM);
ai_charge(5);};
void() bam_swingl2 =[      $swingl2,      bam_swingl3   ] {ai_charge(3);};
void() bam_swingl3 =[      $swingl3,      bam_swingl4   ] {ai_charge(7);};
void() bam_swingl4 =[      $swingl4,      bam_swingl5   ] {ai_charge(3);};
void() bam_swingl5 =[      $swingl5,      bam_swingl6   ] {ai_charge(7);};
void() bam_swingl6 =[      $swingl6,      bam_swingl7   ] {ai_charge(9);};
void() bam_swingl7 =[      $swingl7,      bam_swingl8   ] {ai_charge(5); bamClaw(250);};
void() bam_swingl8 =[      $swingl8,      bam_swingl9   ] {ai_charge(4);};
void() bam_swingl9 =[      $swingl9,      bam_run1  ] {
ai_charge(8);
//if (random()<0.5)			Removed to avoid useless swinging attacks
//	self.think = bam_swingr1;
};

void() bam_swingr1	=[      $swingr1,      bam_swingr2   ] {
sound (self, CHAN_VOICE, "bambler/melee1.wav", 1, ATTN_NORM);
ai_charge(1);};
void() bam_swingr2	=[      $swingr2,      bam_swingr3   ] {ai_charge(8);};
void() bam_swingr3 =[      $swingr3,      bam_swingr4   ] {ai_charge(14);};
void() bam_swingr4 =[      $swingr4,      bam_swingr5   ] {ai_charge(7);};
void() bam_swingr5 =[      $swingr5,      bam_swingr6   ] {ai_charge(3);};
void() bam_swingr6 =[      $swingr6,      bam_swingr7   ] {ai_charge(6);};
void() bam_swingr7 =[      $swingr7,      bam_swingr8   ] {ai_charge(6); bamClaw(-250);};
void() bam_swingr8 =[      $swingr8,      bam_swingr9   ] {ai_charge(3);};
void() bam_swingr9 =[      $swingr9,      bam_run1  ] {ai_charge(1);
ai_charge(10);
//if (random()<0.5)			Removed to avoid useless swinging attacks
//	self.think = bam_swingl1;
};

void() bam_melee =
{
	local float chance;
	
	chance = random();
	if (chance > 0.6 || self.health == 600)
		bam_smash1 ();
	else if (chance > 0.3)
		bam_swingr1 ();
	else
		bam_swingl1 ();
};


//============================================================================


void() bam_pain1       =[      $pain1, bam_pain2      ] {};
void() bam_pain2       =[      $pain2, bam_pain3      ] {};
void() bam_pain3       =[      $pain3, bam_pain4      ] {};
void() bam_pain4       =[      $pain4, bam_pain5      ] {};
void() bam_pain5       =[      $pain5, bam_pain6      ] {};
void() bam_pain6       =[      $pain6, bam_run1      ] {};

void(entity attacker, float damage)	bam_pain =
{
	sound (self, CHAN_VOICE, "bambler/shurt2.wav", 1, ATTN_NORM);

	if (self.health <= 0)
		return;		// allready dying, don't go into pain frame

	if (random()*400 > damage)
		return;		// didn't flinch

	if (self.pain_finished > time)
		return;
	self.pain_finished = time + 2;
		
	bam_pain1 ();
};


//============================================================================

void() bam_death1      =[      $death1,       bam_death2     ] {};
void() bam_death2      =[      $death2,       bam_death3     ] {};
void() bam_death3      =[      $death3,       bam_death4     ] {self.solid = SOLID_TRIGGER; setorigin(self, self.origin);};
void() bam_death4      =[      $death4,       bam_death5     ] {};
void() bam_death5      =[      $death5,       bam_death6     ] {};
void() bam_death6      =[      $death6,       bam_death7     ] {};
void() bam_death7      =[      $death7,       bam_death8     ] {};
void() bam_death8      =[      $death8,       bam_death9     ] {};
void() bam_death9      =[      $death9,       bam_death10    ] {};
void() bam_death10     =[      $death10,      bam_death11    ] {};
void() bam_death11     =[      $death11,      bam_death11    ] {self.think = SUB_MakeNotSolid; self.nextthink = time + 5;};

void() bam_die =
{
// check for gib
	if (self.health < -60)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_bams.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		return;
	}

// regular death
	sound (self, CHAN_VOICE, "bambler/sdeath.wav", 1, ATTN_NORM);
	bam_death1 ();
};

//============================================================================

void() bam_sight = {
	sound (self, CHAN_VOICE, "bambler/ssight.wav", 1, ATTN_NORM);
};

/*QUAKED monster_bambler (1 0 0) (-32 -32 -24) (32 32 64) Ambush
*/
void(entity e) monster_bambler_start =
{
	local entity oself;

	oself = self;
	self = e;

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	setmodel (self, "progs/bambler.mdl");

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize(self, self.cmins, self.cmaxs);

	self.health = 500;
	if (self.obituary == "") self.obituary = "was bashed by a Bambler";

	self.th_stand = bam_stand1;
	self.th_walk = bam_walk1;
	self.th_run = bam_run1;
	self.th_die = bam_die;
	self.th_melee = bam_melee;
	self.th_pain = bam_pain;
	self.th_sight = bam_sight;
	
	walkmonster_start();

	self = oself;
};

void() monster_bambler_spawner = {
	monster_spawner(monster_bambler_start);
};

void() monster_bambler =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/bambler.mdl");
	precache_model ("progs/s_light.mdl");
	precache_model ("progs/h_bams.mdl");
	precache_model ("progs/bolt.mdl");
	
	precache_sound ("bambler/sdeath.wav");
	precache_sound ("bambler/shurt2.wav");
	precache_sound ("bambler/sidle.wav");
	precache_sound ("bambler/ssight.wav");
	precache_sound ("bambler/melee1.wav");
	precache_sound ("bambler/melee2.wav");
	precache_sound ("bambler/smack.wav");
	
	self.cmins = VEC_HULL2_MIN;
	self.cmaxs = VEC_HULL2_MAX;

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize(self, self.cmins, self.cmaxs);
	
	if (self.spawnflags & MONSTER_SPAWNER) {
		self.use = monster_bambler_spawner;
		monster_spawner_updatecounter();
	}
	else {
		monster_bambler_start(self);
	}
};