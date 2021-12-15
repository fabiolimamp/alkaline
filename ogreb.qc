/*
==============================================================================

BERSERK OGRE

By ijed

A dual chainsaw wielding creature with higher health than a normal ogre and
dash attack.  Hi attacks knock victims about the place, making him an 
additional danger when near environmental hazards.

==============================================================================
*/

$cd id1/models/ogreb
$origin 0 0 24
$base base		
$skin base

$frame	stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7
$frame walk8 walk9 walk10 walk11 walk12 walk13 walk14 walk15 walk16

$frame run1 run2 run3 run4 run5 run6 run7 run8

$frame swing1 swing2 swing3 swing4 swing5 swing6 swing7
$frame swing8 swing9 swing10 swing11 swing12 swing13 swing14

$frame smash1 smash2 smash3 smash4 smash5 smash6 smash7
$frame smash8 smash9 smash10 smash11 smash12 smash13 smash14

$frame taunt1 taunt2 taunt3 

$frame pain1 pain2 pain3 pain4 pain5

$frame death1 death2 death3 death4 death5 death6 death7 death8 death9 death10 death11 
$frame death12 death13 death14 death15 death16 death17 death18 death19 death20 death21

$frame bdeath1 bdeath2 bdeath3 bdeath4 bdeath5 bdeath6
$frame bdeath7 bdeath8 bdeath9 bdeath10

$frame cdeath1 cdeath2 cdeath3 cdeath4 cdeath5 cdeath6
$frame cdeath7 cdeath8 cdeath9 cdeath10 cdeath11 cdeath12
$frame cdeath13 cdeath14

//=============================================================================

void() ogreb_smash1;
void() ogreb_run1;
void() ogreb_taunt1;
float()	CheckOgreBMelee;
void() OgreBIdleSound;

//=============================================================================

/*
================
Berserk Smash - Knocks Victim Back
================
*/

void()	OgreB_SmashTouch =
{
	local	float	ldmg;
	
	if (self.health < 1)
		return;
		
	if (other.takedamage)
	{
		if ( vlen(self.velocity) > 300 )
		{
			ldmg = (random() + random() + random()) * 4;
			T_Damage (other, self, self, ldmg);	
			
			//knock em back
			self.enemy.velocity_z = self.enemy.velocity_z + 25 + (random() * 250);
			makevectors (self.angles);
			self.enemy.velocity = self.enemy.velocity + v_forward * 500;
		}
	}

	if (!checkbottom(self))
	{
		if (self.flags & FL_ONGROUND)
		{	
			self.touch = SUB_Null;
			self.think = ogreb_smash1;
			self.nextthink = time + 0.1;
		}
		return;	// not on ground yet
	}
	
	//cheer if we killed em
	if (self.enemy.health < 1)
		self.think = ogreb_taunt1;
	else
		self.think = ogreb_run1;
	
	self.touch = SUB_Null;
	self.nextthink = time + 0.1;
};

/*
================
Berserk Chainsaw - knocks the victim about the place
================
*/
void(float side) berserk_chainsaw =
{
local vector	delta;
local float 	ldmg;

	if (!self.enemy)
		return;
	if (!CanDamage (self.enemy, self))
		return;

	ai_charge(10);

	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 100)
		return;
		
	ldmg = (random() + random() + random()) * 4;
	T_Damage (self.enemy, self, self, ldmg);
	
	if (side)
	{
		makevectors (self.angles);
		if (side == 1)
			SpawnMeatSpray (self.origin + v_forward*16, crandom() * 100 * v_right);
		else
		{
			SpawnMeatSpray (self.origin + v_forward*16, side * v_right);
			self.enemy.velocity = self.enemy.velocity + side * v_right * 2.5;	//here's what smacks them about, last number tweaks distance
			self.enemy.velocity_z = self.enemy.velocity_z + (random() * 150);	//give them some height as well
		}
	}
	
	//cheer if we killed em
	if (self.enemy.health < 1)
		self.think = ogreb_taunt1;
	
};

void() ogreb_stand1	=[	$stand1,	ogreb_stand2	] {ai_stand();};
void() ogreb_stand2	=[	$stand2,	ogreb_stand3	] {ai_stand();};
void() ogreb_stand3	=[	$stand3,	ogreb_stand4	] {ai_stand();};
void() ogreb_stand4	=[	$stand4,	ogreb_stand5	] {ai_stand();};
void() ogreb_stand5	=[	$stand5,	ogreb_stand6	] {ai_stand(); OgreBIdleSound();};
void() ogreb_stand6	=[	$stand6,	ogreb_stand7	] {ai_stand();};
void() ogreb_stand7	=[	$stand7,	ogreb_stand8	] {ai_stand();};
void() ogreb_stand8	=[	$stand8,	ogreb_stand9	] {ai_stand();};
void() ogreb_stand9	=[	$stand9,	ogreb_stand1	] {ai_stand();};

void() ogreb_walk1	=[	$walk1,		ogreb_walk2	] {ai_walk(3);};
void() ogreb_walk2	=[	$walk2,		ogreb_walk3	] {ai_walk(2);};
void() ogreb_walk3	=[	$walk3,		ogreb_walk4	] {ai_walk(2); OgreBIdleSound();};
void() ogreb_walk4	=[	$walk4,		ogreb_walk5	] {ai_walk(2);};
void() ogreb_walk5	=[	$walk5,		ogreb_walk6	] {ai_walk(2);};
void() ogreb_walk6	=[	$walk6,		ogreb_walk7	] {
ai_walk(5);
if (random() < 0.1)
	sound (self, CHAN_VOICE, "ogre/ogdrag.wav", 1, ATTN_IDLE);
};
void() ogreb_walk7	=[	$walk7,		ogreb_walk8		] {ai_walk(3);};
void() ogreb_walk8	=[	$walk8,		ogreb_walk9		] {ai_walk(2);};
void() ogreb_walk9	=[	$walk9,		ogreb_walk10	] {ai_walk(3);};
void() ogreb_walk10	=[	$walk10,	ogreb_walk11	] {ai_walk(1);};
void() ogreb_walk11	=[	$walk11,	ogreb_walk12	] {ai_walk(2);};
void() ogreb_walk12	=[	$walk12,	ogreb_walk13	] {ai_walk(3);};
void() ogreb_walk13	=[	$walk13,	ogreb_walk14	] {ai_walk(3);};
void() ogreb_walk14	=[	$walk14,	ogreb_walk15	] {ai_walk(3);};
void() ogreb_walk15	=[	$walk15,	ogreb_walk16	] {ai_walk(3);};
void() ogreb_walk16	=[	$walk16,	ogreb_walk1		] {ai_walk(4);};

void() ogreb_run1	=[	$run1,		ogreb_run2	] {ai_run(10);
if (random() < 0.2)
	sound (self, CHAN_VOICE, "ogre/ogidle2.wav", 1, ATTN_IDLE);
};
void() ogreb_run2	=[	$run2,		ogreb_run3	] {ai_run(15);};	//ijed +2 for each...
void() ogreb_run3	=[	$run3,		ogreb_run4	] {ai_run(11);};
void() ogreb_run4	=[	$run4,		ogreb_run5	] {ai_run(25);};
void() ogreb_run5	=[	$run5,		ogreb_run6	] {ai_run(19);};
void() ogreb_run6	=[	$run6,		ogreb_run7	] {ai_run(7);};
void() ogreb_run7	=[	$run7,		ogreb_run8	] {ai_run(16);};
void() ogreb_run8	=[	$run8,		ogreb_run1	] {ai_run(27);};

void() ogreb_swing1		=[	$swing1,		ogreb_swing2	] {ai_charge(12); sound (self, CHAN_WEAPON, "ogre/ogsawatk.wav", 1, ATTN_NORM); berserk_chainsaw(-50);};
void() ogreb_swing2		=[	$swing2,		ogreb_swing3	] {ai_charge(2); berserk_chainsaw(-25);};
void() ogreb_swing3		=[	$swing3,		ogreb_swing4	] {ai_charge(5); berserk_chainsaw(-5);};
void() ogreb_swing4		=[	$swing4,		ogreb_swing5	] {ai_charge(14);};
void() ogreb_swing5		=[	$swing5,		ogreb_swing6	] {ai_charge(10); berserk_chainsaw(0);self.angles_y = self.angles_y + random()*25;};
void() ogreb_swing6		=[	$swing6,		ogreb_swing7	] {berserk_chainsaw(200);self.angles_y = self.angles_y + random()* 25;};
void() ogreb_swing7		=[	$swing7,		ogreb_swing8	] {berserk_chainsaw(0);self.angles_y = self.angles_y + random()* 25;};
void() ogreb_swing8		=[	$swing8,		ogreb_swing9	] {berserk_chainsaw(0);self.angles_y = self.angles_y + random()* 25;};
void() ogreb_swing9		=[	$swing9,		ogreb_swing10 ] {berserk_chainsaw(0);self.angles_y = self.angles_y + random()* 25;};
void() ogreb_swing10	=[	$swing10,		ogreb_swing11 ] {berserk_chainsaw(-200);self.angles_y = self.angles_y + random()* 25;};
void() ogreb_swing11	=[	$swing11,		ogreb_swing12 ] {berserk_chainsaw(0);self.angles_y = self.angles_y + random()* 25;};
void() ogreb_swing12	=[	$swing12,		ogreb_swing13 ] {ai_charge(4);};
void() ogreb_swing13	=[	$swing13,		ogreb_swing14 ] {ai_charge(9);};
void() ogreb_swing14	=[	$swing14,		ogreb_run1	] {ai_charge(10);};

void() ogreb_smash1		=[	$smash1,		ogreb_smash2	] {ai_charge(6); sound (self, CHAN_WEAPON, "ogre/ogsawatk.wav", 1, ATTN_NORM);};
void() ogreb_smash2		=[	$smash2,		ogreb_smash3	] {ai_face();};
void() ogreb_smash3		=[	$smash3,		ogreb_smash4	] {ai_face();};
void() ogreb_smash4		=[	$smash4,		ogreb_smash5	] {ai_face();};
void() ogreb_smash5		=[	$smash5,		ogreb_smash6	] 
{
	ai_face();
	self.touch = OgreB_SmashTouch;
	makevectors (self.angles);
	self.origin_z = self.origin_z + 1;
	self.velocity = v_forward * 500 + '0 0 200';
	//self.velocity = v_forward * 600 + '0 0 250'; Fiend values for comparison
	
	if (self.flags & FL_ONGROUND)
		self.flags = self.flags - FL_ONGROUND;
};
void() ogreb_smash6		=[	$smash6,		ogreb_smash7	] {};
void() ogreb_smash7		=[	$smash7,		ogreb_smash8	] {};
void() ogreb_smash8		=[	$smash8,		ogreb_smash9	] {};
void() ogreb_smash9		=[	$smash9,		ogreb_smash10	] {};
void() ogreb_smash10	=[	$smash10,		ogreb_smash11	] {};
void() ogreb_smash11	=[	$smash11,		ogreb_smash12	] {};
void() ogreb_smash12	=[	$smash12,		ogreb_smash13	] {};
void() ogreb_smash13	=[	$smash13,		ogreb_smash14	] {};
void() ogreb_smash14	=[	$smash14,		ogreb_run1		] {

	if ((enemy_range == RANGE_MELEE) && (self.enemy.health > 0))
		ogreb_swing1 ();	//if still in melee range, and enemy is alive, just start hacking away
};

void() ogreb_taunt1	=[	$taunt1,	ogreb_taunt2	]	{ai_face(); sound (self, CHAN_VOICE, "ogre/ogidle2.wav", 1, ATTN_NORM);};
void() ogreb_taunt2	=[	$taunt2,	ogreb_taunt3	]	{};
void() ogreb_taunt3	=[	$taunt3,	ogreb_taunt4	]	{};
void() ogreb_taunt4	=[	$taunt2,	ogreb_taunt5	]	{};
void() ogreb_taunt5	=[	$taunt1,	ogreb_taunt6	]	{};
void() ogreb_taunt6	=[	$taunt2,	ogreb_taunt7	]	{};
void() ogreb_taunt7	=[	$taunt3,	ogreb_stand1	]	{};

void()	ogreb_pain1	=[	$pain1,		ogreb_pain2	] {};
void()	ogreb_pain2	=[	$pain2,		ogreb_pain3	] {};
void()	ogreb_pain3	=[	$pain3,		ogreb_pain4	] {};
void()	ogreb_pain4	=[	$pain4,		ogreb_pain5	] {};
void()	ogreb_pain5	=[	$pain5,		ogreb_run1	] {};

void(entity attacker, float damage)	ogreb_pain =	//ijed Only has a single short pain sequence
{
	
	local float resistance;
	
	if (self.health < self.max_health * 0.4)	self.skin = 2;
	else if (self.health < self.max_health * 0.8)	self.skin = 1;
	
	resistance = skill * 100;	// 0/100/200/300 pain resitance on E/M/H/NM
	
	if (self.touch == OgreB_SmashTouch)
		return;
	
	if (random()*resistance > damage)
		return;		// Shambler style pain resistance
	
	if (self.pain_finished > time)	//no pain if recently pain'ed
		return;

	sound (self, CHAN_VOICE, "ogre/ogpain1.wav", 1, ATTN_NORM);	//ok; bring the pain	
	ogreb_pain1 ();
	self.pain_finished = time + 1;
};

// Death 

void()	ogreb_die1	=[	$death1,	ogreb_die2	] {};
void()	ogreb_die2	=[	$death2,	ogreb_die3	] {};
void()	ogreb_die3	=[	$death3,	ogreb_die4	] {self.solid = SOLID_TRIGGER; setorigin(self, self.origin);};
void()	ogreb_die4	=[	$death4,	ogreb_die5	] {};
void()	ogreb_die5	=[	$death5,	ogreb_die6	] {};
void()	ogreb_die6	=[	$death6,	ogreb_die7	] {};
void()	ogreb_die7	=[	$death7,	ogreb_die8	] {};
void()	ogreb_die8	=[	$death8,	ogreb_die9	] {};
void()	ogreb_die9	=[	$death9,	ogreb_die10	] {};
void()	ogreb_die10	=[	$death10,	ogreb_die11	] {};
void()	ogreb_die11	=[	$death11,	ogreb_die12	] {};
void()	ogreb_die12	=[	$death12,	ogreb_die13	] {};
void()	ogreb_die13	=[	$death13,	ogreb_die14	] {};
void()	ogreb_die14	=[	$death14,	ogreb_die15	] {};
void()	ogreb_die15	=[	$death15,	ogreb_die16	] {};
void()	ogreb_die16	=[	$death16,	ogreb_die17	] {sound (self, CHAN_WEAPON, "ogre/ogsawatk.wav", 1, ATTN_NORM); SpawnMeatSpray (self.origin + v_forward*16, crandom() * 100 * v_right);};
void()	ogreb_die17	=[	$death17,	ogreb_die18	] {SpawnMeatSpray (self.origin + v_forward*16, crandom() * 100 * v_right);};
void()	ogreb_die18	=[	$death18,	ogreb_die19	] {SpawnMeatSpray (self.origin + v_forward*16, crandom() * 100 * v_right);};
void()	ogreb_die19	=[	$death19,	ogreb_die20	] {SpawnMeatSpray (self.origin + v_forward*16, crandom() * 100 * v_right);};
void()	ogreb_die20	=[	$death20,	ogreb_die21	] {};
void()	ogreb_die21	=[	$death21,	ogreb_die21	] {self.think = SUB_MakeNotSolid; self.nextthink = time + 5;};

// Death B

void()	ogreb_bdie1	=[	$bdeath1,	ogreb_bdie2	] {};
void()	ogreb_bdie2	=[	$bdeath2,	ogreb_bdie3	] {};
void()	ogreb_bdie3	=[	$bdeath3,	ogreb_bdie4	] {self.solid = SOLID_TRIGGER; setorigin(self, self.origin);};
void()	ogreb_bdie4	=[	$bdeath4,	ogreb_bdie5	] {};
void()	ogreb_bdie5	=[	$bdeath5,	ogreb_bdie6	] {};
void()	ogreb_bdie6	=[	$bdeath6,	ogreb_bdie7	] {};
void()	ogreb_bdie7	=[	$bdeath7,	ogreb_bdie8	] {};
void()	ogreb_bdie8	=[	$bdeath8,	ogreb_bdie9	] {};
void()	ogreb_bdie9	=[	$bdeath9,	ogreb_bdie10	] {};
void()	ogreb_bdie10	=[	$bdeath10,	ogreb_bdie10	] {self.think = SUB_MakeNotSolid; self.nextthink = time + 5;};

// Death C

void()	ogreb_cdie1		=[	$cdeath1,	ogreb_cdie2		] {};
void()	ogreb_cdie2		=[	$cdeath2,	ogreb_cdie3		] {};
void()	ogreb_cdie3		=[	$cdeath3,	ogreb_cdie4		] {self.solid = SOLID_TRIGGER; setorigin(self, self.origin);};
void()	ogreb_cdie4		=[	$cdeath4,	ogreb_cdie5		] {};
void()	ogreb_cdie5		=[	$cdeath5,	ogreb_cdie6		] {};
void()	ogreb_cdie6		=[	$cdeath6,	ogreb_cdie7		] {};
void()	ogreb_cdie7		=[	$cdeath7,	ogreb_cdie8		] {};
void()	ogreb_cdie8		=[	$cdeath8,	ogreb_cdie9		] {};
void()	ogreb_cdie9		=[	$cdeath9,	ogreb_cdie10	] {};
void()	ogreb_cdie10	=[	$cdeath10,	ogreb_cdie11	] {};
void()	ogreb_cdie11	=[	$cdeath11,	ogreb_cdie12	] {};
void()	ogreb_cdie12	=[	$cdeath12,	ogreb_cdie13	] {};
void()	ogreb_cdie13	=[	$cdeath13,	ogreb_cdie14	] {};
void()	ogreb_cdie14	=[	$cdeath14,	ogreb_cdie14	] {self.think = SUB_MakeNotSolid; self.nextthink = time + 5;};

void() ogreb_die =
{
	local float r;
	r = random();

	// check for gib
	if (self.health < -80)
	{
		self.skin = 0;
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_ogreb.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);

		if (random() < 0.2) ThrowGib ("progs/brz_saw.mdl", self.health);

		return;
	}
	self.skin = 3;

	sound (self, CHAN_VOICE, "ogre/ogdth.wav", 1, ATTN_NORM);
	
	if (r < 0.33)
		ogreb_die1 ();
	else if (r < 0.66)
		ogreb_bdie1 ();
	else
		ogreb_cdie1 ();
};

//============================================================================

/*
==============
CheckOgreBMelee

Returns TRUE if a melee attack would hit right now
==============
*/
float()	CheckOgreBMelee =
{
	if (enemy_range == RANGE_MELEE)
	{	// FIXME: check canreach
		self.attack_state = AS_MELEE;
		return TRUE;
	}
	return FALSE;
};

/*
==============
CheckOgreBJump
==============
*/
float()	CheckOgreBJump =
{
	local	vector	dist;
	local	float	d;

	/*if (self.origin_z + self.mins_z > self.enemy.origin_z + self.enemy.mins_z
	+ 0.75 * self.enemy.size_z)
		return FALSE;*/
		
	if (self.origin_z + self.maxs_z < self.enemy.origin_z + self.enemy.mins_z
	+ 0.5 * self.enemy.size_z)		//was 0.25
		return FALSE;
		
	dist = self.enemy.origin - self.origin;
	dist_z = 0;
	
	d = vlen(dist);
	
	if (d < 80)
		return FALSE;
		
	if (d > 200)		//was 150
		return FALSE;
		
	return TRUE;
};

float()	OgreBCheckAttack =
{
		
	// if close enough for slashing, go for it
	if (CheckOgreBMelee ())
	{
		self.attack_state = AS_MELEE;
		return TRUE;
	}
	
	if (CheckOgreBJump ())
	{
		sound (self, CHAN_VOICE, "ogre/ogleap.wav", 1, ATTN_NORM);
		self.attack_state = AS_MISSILE;
		return TRUE;
	}
	
	return FALSE;
};


void() OgreBIdleSound =	//ijed, play idlesound only if not AMBUSH, can also play it while stood
{
	local float r;
	local string noise;

	noise = "ogre/ogidle.wav";
	r = random();
	
	if ((self.enemy == world) && (self.spawnflags & MONSTER_NOIDLESOUND))
		return;
	
	if (self.enemy == world)		//quieter if not angry at anyone
	{
		if (r < 0.1)
			sound (self, CHAN_VOICE, noise, 1, ATTN_IDLE);
	}
	else if (r < 0.2)
		sound (self, CHAN_VOICE, noise, 1, ATTN_IDLE);
};


void() ogreb_sight = {
	sound (self, CHAN_VOICE, "ogre/ogwake.wav", 1, ATTN_NORM);
};

/*QUAKED monster_ogreb (1 0 0) (-32 -32 -24) (32 32 64) Ambush

*/

void(entity e) monster_ogreb_start =
{
	local entity oself;

	oself = self;
	self = e;

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/ogreb.mdl");

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize(self, self.cmins, self.cmaxs);
	
	self.health = 250;	//ogre is 200
	if (self.obituary == "") self.obituary = "was sawn by a Berserker";

	self.th_stand = ogreb_stand1;
	self.th_walk = ogreb_walk1;
	self.th_run = ogreb_run1;
	self.th_die = ogreb_die;
	self.th_melee = ogreb_swing1;
	self.th_missile = ogreb_smash1; 
	self.th_pain = ogreb_pain;
	self.th_sight = ogreb_sight;
	self.th_checkattack = OgreBCheckAttack;
	
	walkmonster_start();

	self = oself;
};

void() monster_ogreb_spawner = {
	monster_spawner(monster_ogreb_start);
};

void() monster_ogreb =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/ogreb.mdl");
	precache_model ("progs/h_ogreb.mdl");
	precache_model ("progs/gib.mdl");
    precache_model ("progs/brz_saw.mdl");

	precache_sound ("ogre/ogdrag.wav");
	precache_sound ("ogre/ogdth.wav");
	precache_sound ("ogre/ogidle.wav");
	precache_sound ("ogre/ogidle2.wav");
	precache_sound ("ogre/ogpain1.wav");
	precache_sound ("ogre/ogsawatk.wav");
	precache_sound ("ogre/ogwake.wav");
	precache_sound ("ogre/ogleap.wav");

	self.cmins = VEC_HULL2_MIN;
	self.cmaxs = VEC_HULL2_MAX;

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize(self, self.cmins, self.cmaxs);
	
	if (self.spawnflags & MONSTER_SPAWNER) {
		self.use = monster_ogreb_spawner;
		monster_spawner_updatecounter();
	}
	else {
		monster_ogreb_start(self);
	}
};

