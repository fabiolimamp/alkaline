/*=============================================================================
 
monster_chaingunner
code by bmFbr
based on Dreadnaught by john fitzgibbons

==============================================================================*/

// stand - 0 to 7
$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7

// walking - 8 to 22
$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9 walk10
$frame walk11 walk12 walk13 walk14 walk15 walk16

// running - 23 to 30
$frame run1 run2 run3 run4 run5 run6 run7 run8

// firing - 31 to 40
$frame attack1 attack2 attack3 attack4 attack5 attack6
$frame attack7 attack8 attack9 attack10

// death kneeling - 41 to 54
$frame death1 death2 death3 death4 death5 death6 death7 death8
$frame death9 death10 death11 death12 death13 death14

// death flying - 55 to 65
$frame fdeath1 fdeath2 fdeath3 fdeath4 fdeath5 fdeath6 fdeath7 fdeath8
$frame fdeath9 fdeath10 fdeath11

// pain light (A) - 66 to 69
$frame paina1 paina2 paina3 paina4

// pain medium (B) - 70 to 74
$frame painb1 painb2 painb3 painb4 painb5

// pain side (C) - 75 to 82
$frame painc1 painc2 painc3 painc4 painc5 painc6 painc7 painc8

// pain kneeling (D) - 83 to 101
$frame paind1 paind2 paind3 paind4 paind5 paind6 paind7 paind8 paind9 paind10
$frame paind11 paind12 paind13 paind14 paind15 paind16 paind17 paind18 paind19

//============================================================================

float() ChaingunnerCheckAttack =
{
	//local vector	spot1, spot2;	
	local entity	targ;
	local float		chance;


	targ = SUB_entEnemyTarget();

	if (!canshoot(targ))
		return FALSE;

	//if (enemy_range == RANGE_MELEE)
	//	return FALSE;
		
	if (time < self.attack_finished)
		return FALSE;
		
	if (enemy_range == RANGE_FAR)
		return FALSE;
		
	if (enemy_range == RANGE_MELEE)
	{
		chance = 0.9;
		self.attack_finished = 0;
	}
	else if (enemy_range == RANGE_NEAR)
	{
		if (self.th_melee)
			chance = 0.2;
		else
			chance = 0.4;
	}
	else if (enemy_range == RANGE_MID)
	{
		if (self.th_melee)
			chance = 0.05;
		else
			chance = 0.1;
	}
	else
		chance = 0;

	if (self.goalentity.classname == "path_angry") chance = chance * 0.2;
	
	if (random () < chance)
	{
		self.th_missile ();
		SUB_AttackFinished(2*random());
		return TRUE;
	}

	return FALSE;
};


void() chain_fire = {
	self.effects = self.effects | EF_MUZZLEFLASH;
	vector ang, angtoenemy;
	angtoenemy = vectoangles(self.origin - SUB_entEnemyTarget().origin);
	ang = self.angles;
	ang_x = angtoenemy_x;
	makevectors(ang);
	FireBullets2(1, self.origin + v_forward*16 + v_up*16 + v_right*10, v_forward, '0.07 0.02 0');
};

void() chain_change_yaw = {
	entity enem;

	enem = SUB_entEnemyTarget();

	self.ideal_yaw = vectoyaw(enem.origin + (enem.velocity*0.1) - self.origin);
	ChangeYaw();
}

void()	chain_atk1	=[	$attack1,	chain_atk2	] {
	self.rad_time = time + 2 + random()*2;
	chain_change_yaw();};
void()	chain_atk2	=[	$attack2,	chain_atk3	] {chain_change_yaw();};
void()	chain_atk3	=[	$attack3,	chain_atk4	] {chain_change_yaw();};
void()	chain_atk4	=[	$attack4,	chain_atk5	] {chain_change_yaw();};
void()	chain_atk5	=[	$attack5,	chain_atk6	] {chain_change_yaw();};
void()	chain_atk6	=[	$attack6,	chain_atk7	] {
	
	if (startskill == SKILL_EASY) self.yaw_speed = 4;
	else if (startskill == SKILL_NORMAL) self.yaw_speed = 5;
	else if (startskill == SKILL_HARD) self.yaw_speed = 8;
	else self.yaw_speed = 10;

	sound (self, CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM);
	chain_fire();
	chain_change_yaw();
	
	
	if (self.rad_time > time &&
		self.enemy.health > 0 &&
		fabs(self.angles_y - self.ideal_yaw) < 30
	)
		self.think = chain_atk5;

};
void()	chain_atk7	=[	$attack7,	chain_atk8	] {};
void()	chain_atk8	=[	$attack8,	chain_atk9	] {};
void()	chain_atk9	=[	$attack9,	chain_atk10	] {ai_face();};
void()	chain_atk10	=[	$attack10,	chain_run1	] {
	self.yaw_speed = 20;
	ai_face();
	SUB_CheckRefire (chain_atk1);
};


//============================================================================

void()	chain_stand1	=[	$stand1,	chain_stand2	] {ai_stand();};
void()	chain_stand2	=[	$stand2,	chain_stand3	] {ai_stand();};
void()	chain_stand3	=[	$stand3,	chain_stand4	] {ai_stand();};
void()	chain_stand4	=[	$stand4,	chain_stand5	] {ai_stand();};
void()	chain_stand5	=[	$stand5,	chain_stand6	] {ai_stand();};
void()	chain_stand6	=[	$stand6,	chain_stand7	] {ai_stand();};
void()	chain_stand7	=[	$stand7,	chain_stand1	] {ai_stand();};

void()	chain_walk1	=[	$walk1 ,	chain_walk2	]
{
	if (random() < 0.2)
		sound (self, CHAN_VOICE, "chaingunner/chain_idle.wav", 1, ATTN_IDLE);
	ai_walk(2);
};
void()	chain_walk2		=[	$walk2 ,	chain_walk3		] {ai_walk(4);};
void()	chain_walk3		=[	$walk3 ,	chain_walk4		] {ai_walk(4);};
void()	chain_walk4		=[	$walk4 ,	chain_walk5		] {ai_walk(3);};
void()	chain_walk5		=[	$walk5 ,	chain_walk6		] {ai_walk(1);};
void()	chain_walk6		=[	$walk6 ,	chain_walk7		] {ai_walk(2);};
void()	chain_walk7		=[	$walk7 ,	chain_walk8		] {ai_walk(2);};
void()	chain_walk8		=[	$walk8 ,	chain_walk9		] {ai_walk(1);};
void()	chain_walk9		=[	$walk9 ,	chain_walk10	] {ai_walk(2);};
void()	chain_walk10	=[	$walk10,	chain_walk11	] {ai_walk(4);};
void()	chain_walk11	=[	$walk11,	chain_walk12	] {ai_walk(4);};
void()	chain_walk12	=[	$walk12,	chain_walk13	] {ai_walk(1);};
void()	chain_walk13	=[	$walk13,	chain_walk14	] {ai_walk(2);};
void()	chain_walk14	=[	$walk14,	chain_walk15	] {ai_walk(3);};
void()	chain_walk15	=[	$walk15,	chain_walk16	] {ai_walk(4);};
void()	chain_walk16	=[	$walk16,	chain_walk1		] {ai_walk(2);};

float chain_RUN_SPEED = 1.5;

void()	chain_run1	=[	$run1  ,	chain_run2	] {
	self.yaw_speed = 20;
	ai_run(18 * chain_RUN_SPEED);
	if (random() < 0.1)
		sound (self, CHAN_VOICE, "chaingunner/chain_idle.wav", 1, ATTN_IDLE);
};
void()	chain_run2	=[	$run2  ,	chain_run3	] {ai_run(14 * chain_RUN_SPEED);};
void()	chain_run3	=[	$run3  ,	chain_run4	] {ai_run(7 * chain_RUN_SPEED);};
void()	chain_run4	=[	$run4  ,	chain_run5	] {ai_run(12 * chain_RUN_SPEED);};
void()	chain_run5	=[	$run5  ,	chain_run6	] {ai_run(14 * chain_RUN_SPEED);};
void()	chain_run6	=[	$run6  ,	chain_run7	] {ai_run(14 * chain_RUN_SPEED);};
void()	chain_run7	=[	$run7  ,	chain_run8	] {ai_run(7 * chain_RUN_SPEED);};
void()	chain_run8	=[	$run8  ,	chain_run1	] {ai_run(11 * chain_RUN_SPEED);};

void()	chain_paina1	=[	$paina1,	chain_paina2	] {};
void()	chain_paina2	=[	$paina2,	chain_paina3	] {};
void()	chain_paina3	=[	$paina3,	chain_paina4	] {};
void()	chain_paina4	=[	$paina4,	chain_run1		] {};

void()	chain_painb1	=[	$painb1,	chain_painb2	] {};
void()	chain_painb2	=[	$painb2,	chain_painb3	] {};
void()	chain_painb3	=[	$painb3,	chain_painb4	] {};
void()	chain_painb4	=[	$painb4,	chain_painb5	] {};
void()	chain_painb5	=[	$painb5,	chain_run1		] {};

void()	chain_painc1	=[	$painc1,	chain_painc2	] {};
void()	chain_painc2	=[	$painc2,	chain_painc3	] {};
void()	chain_painc3	=[	$painc3,	chain_painc4	] {};
void()	chain_painc4	=[	$painc4,	chain_painc5	] {};
void()	chain_painc5	=[	$painc5,	chain_painc6	] {};
void()	chain_painc6	=[	$painc6,	chain_painc7	] {};
void()	chain_painc7	=[	$painc7,	chain_painc8	] {};
void()	chain_painc8	=[	$painc8,	chain_run1		] {};

void()	chain_paind1	=[	$paind1,	chain_paind2	] {};
void()	chain_paind2	=[	$paind2,	chain_paind3	] {};
void()	chain_paind3	=[	$paind3,	chain_paind4	] {};
void()	chain_paind4	=[	$paind4,	chain_paind5	] {ai_painforward(2);};
void()	chain_paind5	=[	$paind5,	chain_paind6	] {ai_painforward(1);};
void()	chain_paind6	=[	$paind6,	chain_paind7	] {};
void()	chain_paind7	=[	$paind7,	chain_paind8	] {};
void()	chain_paind8	=[	$paind8,	chain_paind9	] {};
void()	chain_paind9	=[	$paind9,	chain_paind10	] {};
void()	chain_paind10	=[	$paind10,	chain_paind11	] {};
void()	chain_paind11	=[	$paind11,	chain_paind12	] {ai_painforward(1);};
void()	chain_paind12	=[	$paind12,	chain_paind13	] {ai_painforward(1);};
void()	chain_paind13	=[	$paind13,	chain_paind14	] {ai_painforward(1);};
void()	chain_paind14	=[	$paind14,	chain_paind15	] {};
void()	chain_paind15	=[	$paind15,	chain_paind16	] {};
void()	chain_paind16	=[	$paind16,	chain_paind17	] {ai_pain(1);};
void()	chain_paind17	=[	$paind17,	chain_paind18	] {ai_pain(1);};
void()	chain_paind18	=[	$paind18,	chain_paind19	] {};
void()	chain_paind19	=[	$paind19,	chain_run1	] {};

void(entity attacker, float damage)	chain_pain =
{
	local float r;

	/*if (self.health < self.max_health * 0.1) 		self.skin = 3;
	else if (self.health < self.max_health * 0.5 && self.health >= self.max_health * 0.25)	self.skin = 2;
	else if (self.health < self.max_health * 0.75 && self.health >= self.max_health * 0.5)	self.skin = 1;
	*/

	r = random ();
	if (self.pain_finished > time)
		return; 	// too soon

	if (random()*150 > damage)
		return;		// didn't flinch
		
	
	sound (self, CHAN_VOICE, "chaingunner/chain_pain.wav", 1, ATTN_NORM);
	

	if ((damage > 50 && r > 0.2) || damage > 80)
	{
		self.pain_finished = time + 3;
		chain_paind1 ();
	}
	else if (r < 0.33)
	{
		self.pain_finished = time + 2;
		chain_paina1 ();
	}
	else if (r < 0.66)
	{
		self.pain_finished = time + 2;
		chain_painb1 ();
	}
	else
	{
		self.pain_finished = time + 2;
		chain_painc1 ();
	}
};

//============================================================================




void()	chain_die1		=[	$death1,	chain_die2	] {};
void()	chain_die2		=[	$death2,	chain_die3	] {};
void()	chain_die3		=[	$death3,	chain_die4	] {self.solid = SOLID_TRIGGER; setorigin(self, self.origin);};
void()	chain_die4		=[	$death4,	chain_die5	] {ai_forward(14);};
void()	chain_die5		=[	$death5,	chain_die6	] {ai_forward(2);};
void()	chain_die6		=[	$death6,	chain_die7	] {};
void()	chain_die7		=[	$death7,	chain_die8	] {};
void()	chain_die8		=[	$death8,	chain_die9	] {};
void()	chain_die9		=[	$death9,	chain_die10	] {ai_forward(3);};
void()	chain_die10		=[	$death10,	chain_die11	] {ai_forward(5);};
void()	chain_die11		=[	$death11,	chain_die12	] {ai_forward(5);};
void()	chain_die12		=[	$death12,	chain_die13	] {ai_forward(5);};
void()	chain_die13		=[	$death13,	chain_die14	] {};
void()	chain_die14		=[	$death14,	chain_die14	] {self.think = SUB_MakeNotSolid; self.nextthink = time + 5;};

void()	chain_fdie1		=[	$fdeath1,	chain_fdie2	] {/*ai_back(12);*/
	self.nextthink = time + 0.08;
	self.movetype = MOVETYPE_TOSS;
	setorigin(self, self.origin);
	makevectors([-30, self.angles_y + 180, 0]);
	self.velocity = v_forward * 250;

	self.flags = self.flags - (self.flags & FL_ONGROUND);
};
void()	chain_fdie2		=[	$fdeath2,	chain_fdie3	] {/*ai_back(12);*/ self.nextthink = time + 0.08;};
void()	chain_fdie3		=[	$fdeath3,	chain_fdie4	] {/*ai_back(16);*/ self.solid = SOLID_TRIGGER; setorigin(self, self.origin);};
void()	chain_fdie4		=[	$fdeath4,	chain_fdie5	] {/*ai_back(12);*/};
void()	chain_fdie5		=[	$fdeath5,	chain_fdie6	] {/*ai_back(10);*/};
void()	chain_fdie6		=[	$fdeath6,	chain_fdie7	] {/*ai_back(8);*/};
void()	chain_fdie7		=[	$fdeath7,	chain_fdie8	] {/*ai_back(4);*/};
void()	chain_fdie8		=[	$fdeath8,	chain_fdie9	] {};
void()	chain_fdie9		=[	$fdeath9,	chain_fdie10	] {};
void()	chain_fdie10	=[	$fdeath10,	chain_fdie11	] {};
void()	chain_fdie11	=[	$fdeath11,	chain_fdie11	] {self.think = SUB_MakeNotSolid; self.nextthink = time + 5;};


void() chain_die =
{
	if (self.health < -80) // gib
	{
		self.skin = 0;
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_chaingunner.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
	}
	else // regular death
	{
		float rnd;
		rnd = random();

		if (rnd < 0.33)
			sound (self, CHAN_VOICE, "chaingunner/chain_death1.wav", 1, ATTN_NORM);
		else if (rnd < 0.66)
			sound (self, CHAN_VOICE, "chaingunner/chain_death2.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_VOICE, "chaingunner/chain_death3.wav", 1, ATTN_NORM);
		if (self.health < 30 && random() > 0.2)
			chain_fdie1 ();
		else
			chain_die1 ();
	}

};

void() chain_sight = {
	float rnd;
	rnd = random();
	if (rnd < 0.33)
		sound (self, CHAN_VOICE, "chaingunner/chain_sight1.wav", 1, ATTN_NORM);
	else if (rnd < 0.66)
		sound (self, CHAN_VOICE, "chaingunner/chain_sight2.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_VOICE, "chaingunner/chain_sight3.wav", 1, ATTN_NORM);
}

/*QUAKED monster_dreadnaught (1 0 0) (-16 -16 -24) (16 16 40) AMBUSH
Dreadnaught, 150 health points.

AMBUSH: dreadnaught will only wake up on really seeing the player, not another monster getting angry.
*/
void(entity e) monster_chaingunner_start =
{
	local entity oself;

	oself = self;
	self = e;

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/chaingunner.mdl");

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize(self, self.cmins, self.cmaxs);

	self.health = 250;
	if (self.obituary == "") self.obituary = "was assaulted by a Chaingunner";

	self.th_stand = chain_stand1;
	self.th_walk = chain_walk1;
	self.th_run = chain_run1;
	self.th_pain = chain_pain;
	self.th_die = chain_die;
	self.th_missile = chain_atk1;
	self.th_sight = chain_sight;
	self.th_checkattack = ChaingunnerCheckAttack;
	
	
	if (!self.yaw_speed)
		self.yaw_speed = 20; //make him turn faster than most monsters (harder to circle-strafe)

	walkmonster_start();

	self = oself;
};

void() monster_chaingunner_spawner = {
	monster_spawner(monster_chaingunner_start);
};


void() monster_chaingunner =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model2 ("progs/chaingunner.mdl");
	precache_model2 ("progs/h_chaingunner.mdl");

	precache_sound2 ("chaingunner/chain_death1.wav");
	precache_sound2 ("chaingunner/chain_death2.wav");
	precache_sound2 ("chaingunner/chain_death3.wav");
	precache_sound2 ("chaingunner/chain_idle.wav");
	precache_sound2 ("chaingunner/chain_pain.wav");
	precache_sound2 ("chaingunner/chain_sight1.wav");
	precache_sound2 ("chaingunner/chain_sight2.wav");
	precache_sound2 ("chaingunner/chain_sight3.wav");
		
	self.cmins = '-16 -16 -24';
	self.cmaxs = '16 16 40';
	
	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize(self, self.cmins, self.cmaxs);
	
	if (self.spawnflags & MONSTER_SPAWNER) {
		self.use = monster_chaingunner_spawner;
		monster_spawner_updatecounter();
	}
	else {
		monster_chaingunner_start(self);
	}
};