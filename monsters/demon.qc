/*
==============================================================================

DEMON

==============================================================================
*/

$cd id1/models/demon3
$scale	0.8
$origin 0 0 24
$base base
$skin base

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9
$frame stand10 stand11 stand12 stand13

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8

$frame run1 run2 run3 run4 run5 run6

$frame leap1 leap2 leap3 leap4 leap5 leap6 leap7 leap8 leap9 leap10
$frame leap11 leap12

$frame pain1 pain2 pain3 pain4 pain5 pain6

$frame death1 death2 death3 death4 death5 death6 death7 death8 death9

$frame attacka1 attacka2 attacka3 attacka4 attacka5 attacka6 attacka7 attacka8
$frame attacka9 attacka10 attacka11 attacka12 attacka13 attacka14 attacka15

//============================================================================

void()	Demon_JumpTouch;
void(float side)	Demon_Melee;
void(float side)	Mutant_Melee;
float()	DemonCheckAttack;

void()	demon1_stand1	=[	$stand1,	demon1_stand2	] {ai_stand();};
void()	demon1_stand2	=[	$stand2,	demon1_stand3	] {ai_stand();};
void()	demon1_stand3	=[	$stand3,	demon1_stand4	] {ai_stand();};
void()	demon1_stand4	=[	$stand4,	demon1_stand5	] {ai_stand();};
void()	demon1_stand5	=[	$stand5,	demon1_stand6	] {ai_stand();};
void()	demon1_stand6	=[	$stand6,	demon1_stand7	] {ai_stand();};
void()	demon1_stand7	=[	$stand7,	demon1_stand8	] {ai_stand();};
void()	demon1_stand8	=[	$stand8,	demon1_stand9	] {ai_stand();};
void()	demon1_stand9	=[	$stand9,	demon1_stand10	] {ai_stand();};
void()	demon1_stand10	=[	$stand10,	demon1_stand11	] {ai_stand();};
void()	demon1_stand11	=[	$stand11,	demon1_stand12	] {ai_stand();};
void()	demon1_stand12	=[	$stand12,	demon1_stand13	] {ai_stand();};
void()	demon1_stand13	=[	$stand13,	demon1_stand1	] {ai_stand();};

void()	demon1_walk1	=[	$walk1,		demon1_walk2	] {
if (random() < 0.2)
	if (self.classname == "monster_mutant") sound(self, CHAN_VOICE, "mutant/mutidle1.wav", 1, ATTN_IDLE);
    else sound (self, CHAN_VOICE, "demon/idle1.wav", 1, ATTN_IDLE);
ai_walk(8);
};
void()	demon1_walk2	=[	$walk2,		demon1_walk3	] {ai_walk(6);};
void()	demon1_walk3	=[	$walk3,		demon1_walk4	] {ai_walk(6);};
void()	demon1_walk4	=[	$walk4,		demon1_walk5	] {ai_walk(7);};
void()	demon1_walk5	=[	$walk5,		demon1_walk6	] {ai_walk(4);};
void()	demon1_walk6	=[	$walk6,		demon1_walk7	] {ai_walk(6);};
void()	demon1_walk7	=[	$walk7,		demon1_walk8	] {ai_walk(10);};
void()	demon1_walk8	=[	$walk8,		demon1_walk1	] {ai_walk(10);};

void()	demon1_run1	=[	$run1,		demon1_run2	] {
if (random() < 0.2) {
	if (self.classname == "monster_mutant") sound(self, CHAN_VOICE, "mutant/mutidle1.wav", 1, ATTN_IDLE);
    else sound(self, CHAN_VOICE, "demon/idle1.wav", 1, ATTN_IDLE);
}
ai_runjump(20);};
void()	demon1_run2	=[	$run2,		demon1_run3	] {ai_runjump(15); if (self.classname == "monster_mutant") sound(self, 6, "mutant/step1.wav", 1, ATTN_IDLE);};
void()	demon1_run3	=[	$run3,		demon1_run4	] {ai_runjump(36);};
void()	demon1_run4	=[	$run4,		demon1_run5	] {ai_runjump(20);};
void()	demon1_run5	=[	$run5,		demon1_run6	] {ai_runjump(15); if (self.classname == "monster_mutant") sound(self, 7, "mutant/step3.wav", 1, ATTN_IDLE);};
void()	demon1_run6	=[	$run6,		demon1_run1	] {ai_runjump(36);};



/*
===================================================================================================
CheckDemonJump

===================================================================================================
*/
float()	CheckDemonJump =
{
	local	vector	dist;
	local	float	d;

	if (self.origin_z + self.mins_z > self.enemy.origin_z + self.enemy.mins_z
	+ 0.75 * self.enemy.size_z)
		return FALSE;
		
	if (self.origin_z + self.maxs_z < self.enemy.origin_z + self.enemy.mins_z
	+ 0.25 * self.enemy.size_z)
		return FALSE;
		
	dist = self.enemy.origin - self.origin;
	dist_z = 0;
	
	d = vlen(dist);
	
	if (d < 100)
		return FALSE;
		
	if (d > 200)
	{
		if (random() < 0.9)
			return FALSE;
	}
		
	return TRUE;
};

void()	Demon_JumpTouch =
{
	local	float	ldmg;

	if (self.health <= 0)
		return;
		
	if (other.takedamage)
	{
		if ( vlen(self.velocity) > 400 )
		{
			if (self.classname == "monster_mutant") ldmg = 25 + 10*random();
			else ldmg = 40 + 10*random();
			T_Damage(other, self, self, ldmg, DMGTYPE_MELEE);
			self.touch = SUB_Null;
		}
	}

	if (!checkbottom(self))
	{
		if (self.flags & FL_ONGROUND)
		{	// jump randomly to not get hung up
			//dprint ("popjump\n");
			self.touch = SUB_Null;
			self.think = demon1_jump1;
			self.nextthink = time + 0.1;

//			self.velocity_x = (random() - 0.5) * 600;
//			self.velocity_y = (random() - 0.5) * 600;
//			self.velocity_z = 200;
//			self.flags = self.flags - FL_ONGROUND;
		}
		return;	// not on ground yet
	}

	self.touch = SUB_Null;
	self.think = demon1_jump11;
	self.nextthink = time + 0.1;
};


void()	demon1_jump1	=[	$leap1,		demon1_jump2	] {ai_face();};
void()	demon1_jump2	=[	$leap2,		demon1_jump3	] {ai_face();};
void()	demon1_jump3	=[	$leap3,		demon1_jump4	] {ai_face();};
void()	demon1_jump4	=[	$leap4,		demon1_jump5	]
{
	ai_face();
	
	self.touch = Demon_JumpTouch;
	makevectors (self.angles);
	self.origin_z = self.origin_z + 1;
	self.velocity = v_forward * 600 + '0 0 250';
	if (self.flags & FL_ONGROUND)
		self.flags = self.flags - FL_ONGROUND;
};
void()	demon1_jump5	=[	$leap5,		demon1_jump6	] {};
void()	demon1_jump6	=[	$leap6,		demon1_jump7	] {};
void()	demon1_jump7	=[	$leap7,		demon1_jump8	] {};
void()	demon1_jump8	=[ 	$leap8,		demon1_jump9	] {};
void()	demon1_jump9	=[ 	$leap9,		demon1_jump10	] {};
void()	demon1_jump10	=[ 	$leap10,	demon1_jump1	] {
self.nextthink = time + 3;
// if three seconds pass, assume demon is stuck and jump again
};

void()	demon1_jump11	=[ 	$leap11,	demon1_jump12	] {};
void()	demon1_jump12	=[ 	$leap12,	demon1_run1	] {};


//=================================================================================================

void()	demon1_atta1	=[	$attacka1,		demon1_atta2	] {ai_charge(4);};
void()	demon1_atta2	=[	$attacka2,		demon1_atta3	] {ai_charge(0);};
void()	demon1_atta3	=[	$attacka3,		demon1_atta4	] {ai_charge(0);};
void()	demon1_atta4	=[	$attacka4,		demon1_atta5	] {ai_charge(1);};
void()	demon1_atta5	=[	$attacka5,		demon1_atta6	] {
	ai_charge(2); Demon_Melee(200);
};
void()	demon1_atta6	=[	$attacka6,		demon1_atta7	] {ai_charge(1);};
void()	demon1_atta7	=[	$attacka7,		demon1_atta8	] {ai_charge(6);};
void()	demon1_atta8	=[	$attacka8,		demon1_atta9	] {ai_charge(8);};
void()	demon1_atta9	=[	$attacka9,		demon1_atta10] {ai_charge(4);};
void()	demon1_atta10	=[	$attacka10,		demon1_atta11] {ai_charge(2);};
void()	demon1_atta11	=[	$attacka11,		demon1_atta12] {
	Demon_Melee(-200);};
void()	demon1_atta12	=[	$attacka12,		demon1_atta13] {ai_charge(5);};
void()	demon1_atta13	=[	$attacka13,		demon1_atta14] {ai_charge(8);};
void()	demon1_atta14	=[	$attacka14,		demon1_atta15] {ai_charge(4);};
void()	demon1_atta15	=[	$attacka15,		demon1_run1] {ai_charge(4);};



void()	mutant_atta1	=[	$attacka1,		mutant_atta2	] {ai_charge(4);};
void()	mutant_atta2	=[	$attacka2,		mutant_atta3	] {ai_charge(1);};
void()	mutant_atta3	=[	$attacka3,		mutant_atta4	] {ai_charge(5); Mutant_Melee(200);};
void()	mutant_atta4	=[	$attacka4,		mutant_atta5	] {ai_charge(2);};
void()	mutant_atta5	=[	$attacka5,		mutant_atta6	] {ai_charge(4); Mutant_Melee(-200);};
void()	mutant_atta6	=[	$attacka6,		mutant_atta7	] {ai_charge(4);};
void()	mutant_atta7	=[	$attacka7,		mutant_atta8	] {ai_charge(4);};
void()	mutant_atta8	=[	$attacka8,		mutant_atta9	] {ai_charge(2);};
void()	mutant_atta9	=[	$attacka9,		mutant_atta10] {ai_charge(1);};
void()	mutant_atta10	=[	$attacka10,		mutant_atta11] {ai_charge(5);Mutant_Melee(200);};
void()	mutant_atta11	=[	$attacka11,		mutant_atta12] {ai_charge(2);};
void()	mutant_atta12	=[	$attacka12,		mutant_atta13] {ai_charge(4);Mutant_Melee(-200);};
void()	mutant_atta13	=[	$attacka13,		mutant_atta14] {ai_charge(4);};
void()	mutant_atta14	=[	$attacka14,		mutant_atta15] {ai_charge(4);};
void()	mutant_atta15	=[	$attacka15,		demon1_run1] {ai_charge(2);};

void()	demon1_pain1	=[	$pain1,		demon1_pain2	] {};
void()	demon1_pain2	=[	$pain2,		demon1_pain3	] {};
void()	demon1_pain3	=[	$pain3,		demon1_pain4	] {};
void()	demon1_pain4	=[	$pain4,		demon1_pain5	] {};
void()	demon1_pain5	=[	$pain5,		demon1_pain6	] {};
void()	demon1_pain6	=[	$pain6,		demon1_run1	] {};

void(entity attacker, float damage)	demon1_pain =
{
	if (self.classname == "monster_mutant") {
		if (self.health < self.max_health * 0.6) self.skin = 1;
	}
	
	if (self.classname == "monster_demon1" && self.originalmonsters) {
		if (self.health < self.max_health * 0.05)	self.skin = 3;
		else if (self.health < self.max_health * 0.4)	self.skin = 2;
		else if (self.health < self.max_health * 0.8)	self.skin = 1;
	}

	if (self.touch == Demon_JumpTouch)
		return;

	if (self.pain_finished > time)
		return;

	self.pain_finished = time + 1;
	if (self.classname == "monster_mutant") {
		if (random() > 0.5) sound (self, CHAN_VOICE, "mutant/mutpain1.wav", 1, ATTN_NORM);
		else sound (self, CHAN_VOICE, "mutant/mutpain2.wav", 1, ATTN_NORM);
	}
    else sound (self, CHAN_VOICE, "demon/dpain1.wav", 1, ATTN_NORM);

	if (random()*200 > damage)
		return;		// didn't flinch
		
	demon1_pain1 ();
};

void()	demon1_die1		=[	$death1,		demon1_die2	] {
	if (self.classname == "monster_mutant") sound (self, CHAN_VOICE, "mutant/mutdeth1.wav", 1, ATTN_NORM);
	else sound (self, CHAN_VOICE, "demon/ddeath.wav", 1, ATTN_NORM);
};
void()	demon1_die2		=[	$death2,		demon1_die3	] {};
void()	demon1_die3		=[	$death3,		demon1_die4	] {};
void()	demon1_die4		=[	$death4,		demon1_die5	] {};
void()	demon1_die5		=[	$death5,		demon1_die6	] {};
void()	demon1_die6		=[	$death6,		demon1_die7	]
{self.solid = SOLID_TRIGGER; setorigin(self, self.origin);};
void()	demon1_die7		=[	$death7,		demon1_die8	] {};
void()	demon1_die8		=[	$death8,		demon1_die9	] {};
void()	demon1_die9		=[	$death9,		demon1_die9 ] {monster_dead_dead();};

void() demon_die =
{
// check for gib
	if (self.health < -80)
	{
		self.skin = 0;
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		if (self.classname == "monster_mutant") ThrowHead ("progs/h_mutant.mdl", self.health);
		else if (self.originalmonsters) ThrowHead ("progs/h_demon.mdl", self.health);
		else  ThrowHead ("progs/h_demon_alk.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		self.deadflag = DEAD_GIBBED;
		return;
	}

	if (self.classname == "monster_mutant") self.skin = 1;
	else if (self.classname == "monster_demon1" && self.originalmonsters) self.skin = 3;

// regular death
	demon1_die1 ();
};


void() Demon_MeleeAttack =
{
	if (self.classname == "monster_mutant") mutant_atta1();
	else demon1_atta1 ();
};


/*
==============
CheckDemonMelee

Returns TRUE if a melee attack would hit right now
==============
*/
float()	CheckDemonMelee =
{
	if (enemy_range == RANGE_MELEE)
	{	// FIXME: check canreach
		self.attack_state = AS_MELEE;
		return TRUE;
	}
	return FALSE;
};

float()	DemonCheckAttack =
{
//	local	vector	vec;
	
// if close enough for slashing, go for it
	if (CheckDemonMelee ())
	{
		self.attack_state = AS_MELEE;
		return TRUE;
	}
	
	if (CheckDemonJump () && self.goalentity.classname != "path_angry")
	{
		self.attack_state = AS_MISSILE;
        if (self.classname == "monster_mutant") sound(self, CHAN_VOICE, "mutant/mutsght1.wav", 1, ATTN_NORM);
        else sound (self, CHAN_VOICE, "demon/djump.wav", 1, ATTN_NORM);
		return TRUE;
	}
	
	return FALSE;
};


//===========================================================================

void(float side)	Demon_Melee =
{
	local	float	ldmg;
	local vector	delta;
	
	ai_face ();
	walkmove2 (self.ideal_yaw, 12);	// allow a little closing

	delta = self.enemy.origin - self.origin;
	
	
	if (vlen(delta) > 100)
		return;
	if (!CanDamage (self.enemy, self.origin))
		return;

	sound (self, CHAN_WEAPON, "demon/dhit2.wav", 1, ATTN_NORM);
	
	ldmg = 10 + 5*random();
	T_Damage(self.enemy, self, self, ldmg, DMGTYPE_MELEE);	

	makevectors (self.angles);
	SpawnMeatSpray (self.origin + v_forward*16, side * v_right);
};

void(float side)	Mutant_Melee =
{
	local	float	ldmg;
	local vector	delta;
	
	ai_face ();
	walkmove2 (self.ideal_yaw, 12);	// allow a little closing

	delta = self.enemy.origin - self.origin;
	
	sound (self, CHAN_WEAPON, "mutant/mutatck1.wav", 1, ATTN_NORM);
	
	if (vlen(delta) > 100)
		return;
	if (!CanDamage (self.enemy, self.origin))
		return;

	sound (self, CHAN_WEAPON, "mutant/mutatck2.wav", 1, ATTN_NORM);
    	
	ldmg = 5 + 2*random();
	T_Damage(self.enemy, self, self, ldmg, DMGTYPE_MELEE);	

	makevectors (self.angles);
	SpawnMeatSpray (self.origin + v_forward*16, side * v_right);
};


void() demon1_sight = {
	if (self.classname == "monster_mutant") sound (self, CHAN_VOICE, "mutant/mutsrch1.wav", 1, ATTN_NORM);
	else sound (self, CHAN_VOICE, "demon/sight2.wav", 1, ATTN_NORM);
};
/*QUAKED monster_demon1 (1 0 0) (-32 -32 -24) (32 32 64) Ambush

*/
void(entity e) monster_demon1_start =
{
	local entity oself;

	oself = self;
	self = e;

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	if (self.originalmonsters)
		setmodel (self, "progs/demon_old.mdl");
	else
		setmodel (self, "progs/demon_alk.mdl");

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize (self, self.cmins, self.cmaxs);

	self.health = 300;
	if (self.obituary == "") self.obituary = "was eviscerated by a Fiend";

	self.th_stand = demon1_stand1;
	self.th_walk = demon1_walk1;
	self.th_run = demon1_run1;
	self.th_die = demon_die;
	self.th_melee = Demon_MeleeAttack;		// one of two attacks
	self.th_missile = demon1_jump1;			// jump attack
	self.th_pain = demon1_pain;
	self.th_sight = demon1_sight;
	self.th_checkattack = DemonCheckAttack;
	
	self.autojump = defaultFl(self.autojump, 1);
	
	walkmonster_start();

	self = oself;
};

void(entity e) monster_mutant_start =
{
	local entity oself;

	oself = self;
	self = e;

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/mutant.mdl");

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize (self, self.cmins, self.cmaxs);
	
	self.health = 220;
	if (self.obituary == "") self.obituary = "was mutilated by a Mutant";

	self.th_stand = demon1_stand1;
	self.th_walk = demon1_walk1;
	self.th_run = demon1_run1;
	self.th_die = demon_die;
	self.th_melee = Demon_MeleeAttack;		// one of two attacks
	self.th_missile = demon1_jump1;			// jump attack
	self.th_pain = demon1_pain;
	self.th_sight = demon1_sight;
	self.th_checkattack = DemonCheckAttack;
		
	self.autojump = defaultFl(self.autojump, 1);

	walkmonster_start();

	self = oself;
};

void() monster_demon1_spawner = {
	monster_spawner(monster_demon1_start);
};

void() monster_demon1 =
{
	if (!SUB_InitEntity()) return;
	
	if (deathmatch)
	{
		remove(self);
		return;
	}

	if (
		world.originalmonsters && !(self.spawnflags & MONSTER_ALK)
		|| self.spawnflags & MONSTER_ORIGINAL
	) self.originalmonsters = 1;
	
	if (self.originalmonsters) {
		precache_model ("progs/demon_old.mdl");
		precache_model ("progs/h_demon.mdl");
	}
	else {
		precache_model ("progs/demon_alk.mdl");
		precache_model ("progs/h_demon_alk.mdl");
	}

	

	precache_sound ("demon/ddeath.wav");
	precache_sound ("demon/dhit2.wav");
	precache_sound ("demon/djump.wav");
	precache_sound ("demon/dpain1.wav");
	precache_sound ("demon/idle1.wav");
	precache_sound ("demon/sight2.wav");

	self.cmins = VEC_HULL2_MIN;
	self.cmaxs = VEC_HULL2_MAX;

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize (self, self.cmins, self.cmaxs);

	if (self.spawnflags & MONSTER_SPAWNER) {
		self.use = monster_demon1_spawner;
		monster_spawner_updatecounter();
	}
	else {
		monster_demon1_start(self);
	}
};

void() monster_mutant_spawner = {
	monster_spawner(monster_mutant_start);
};

void() monster_mutant =
{
	if (!SUB_InitEntity()) return;
	
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/mutant.mdl");
	precache_model ("progs/h_mutant.mdl");

	
	precache_sound ("mutant/mutidle1.wav");
	precache_sound ("mutant/mutatck1.wav");
	precache_sound ("mutant/mutatck2.wav");
	precache_sound ("mutant/mutatck3.wav");
	//precache_sound ("mutant/mutjump.wav"); // jump
	precache_sound ("mutant/step1.wav"); 
	precache_sound ("mutant/step3.wav");
	precache_sound ("mutant/mutdeth1.wav");
	precache_sound ("mutant/mutpain1.wav");
	precache_sound ("mutant/mutpain2.wav");
	precache_sound ("mutant/mutsght1.wav");
	precache_sound ("mutant/mutsrch1.wav");

	self.cmins = VEC_HULL2_MIN;
	self.cmaxs = VEC_HULL2_MAX;

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize (self, self.cmins, self.cmaxs);

	if (self.spawnflags & MONSTER_SPAWNER) {
		self.use = monster_mutant_spawner;
		monster_spawner_updatecounter();
	}
	else {
		monster_mutant_start(self);
	}
};
