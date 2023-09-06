//Decompiled code. Please respect the original copyright.

void(entity e, float a, float b) genHeal = {};

void() zombieFast_stand1 = [ 0, zombieFast_stand2 ]{ai_stand();	genHeal(self, 1, 0);};
void() zombieFast_stand2 = [ 1, zombieFast_stand3 ]{ai_stand();};
void() zombieFast_stand3 = [ 2, zombieFast_stand4 ]{ai_stand();};
void() zombieFast_stand4 = [ 3, zombieFast_stand5 ]{ai_stand();};
void() zombieFast_stand5 = [ 4, zombieFast_stand6 ]{ai_stand();};
void() zombieFast_stand6 = [ 5, zombieFast_stand7 ]{ai_stand();};
void() zombieFast_stand7 = [ 6, zombieFast_stand8 ]{ai_stand();};
void() zombieFast_stand8 = [ 7, zombieFast_stand9 ]{ai_stand();	genHeal(self, 1, 0);};
void() zombieFast_stand9 = [ 8, zombieFast_stand10 ]{ai_stand();};
void() zombieFast_stand10 = [ 9, zombieFast_stand11 ]{ai_stand();};
void() zombieFast_stand11 = [ 10, zombieFast_stand12 ]{ai_stand();};
void() zombieFast_stand12 = [ 11, zombieFast_stand13 ]{ai_stand();};
void() zombieFast_stand13 = [ 12, zombieFast_stand14 ]{ai_stand();};
void() zombieFast_stand14 = [ 13, zombieFast_stand15 ]{ai_stand();};
void() zombieFast_stand15 = [ 14, zombieFast_stand1 ]{ai_stand();};

void() zombieFast_footStep = {
	local float rSnd;

	rSnd = random();
	if (rSnd < (1 / 5))	{
		sound(self, 5, "zombie2/footstep1.wav", 1, ATTN_NORM);
	}
	else if (rSnd < (2 / 5)) {
		sound(self, 5, "zombie2/footstep2.wav", 1, ATTN_NORM);
	}
	else if (rSnd < (3 / 5)) {
		sound(self, 5, "zombie2/footstep3.wav", 1, ATTN_NORM);
	}
	else if ((rSnd < (4 / 5))) {
		sound(self, 5, "zombie2/footstep4.wav", 1, ATTN_NORM);
	}
	else {
		sound(self, 5, "zombie2/footstep5.wav", 1, ATTN_NORM);
	}
};


void() zombieFast_walk1 = [ 15, zombieFast_walk2 ]{ai_walk(1);genHeal(self, 1, 0);};
void() zombieFast_walk2 = [ 16, zombieFast_walk3 ]{ai_walk(1);};
void() zombieFast_walk3 = [ 17, zombieFast_walk4 ]{ai_walk(0);};
void() zombieFast_walk4 = [ 18, zombieFast_walk5 ]{ai_walk(1);};
void() zombieFast_walk5 = [ 19, zombieFast_walk6 ]{ai_walk(2);};
void() zombieFast_walk6 = [ 20, zombieFast_walk7 ]{ai_walk(3);};
void() zombieFast_walk7 = [ 21, zombieFast_walk8 ]{ai_walk(4);};
void() zombieFast_walk8 = [ 22, zombieFast_walk9 ]{ai_walk(4);genHeal(self, 1, 0);};
void() zombieFast_walk9 = [ 23, zombieFast_walk10 ]{ai_walk(2);};
void() zombieFast_walk10 = [ 24, zombieFast_walk11 ]{ai_walk(0);};
void() zombieFast_walk11 = [ 25, zombieFast_walk12 ]{ai_walk(0);};
void() zombieFast_walk12 = [ 26, zombieFast_walk13 ]{ai_walk(0);};
void() zombieFast_walk13 = [ 27, zombieFast_walk14 ]{ai_walk(2);};
void() zombieFast_walk14 = [ 28, zombieFast_walk15 ]{ai_walk(4);};
void() zombieFast_walk15 = [ 29, zombieFast_walk16 ]{ai_walk(6);genHeal(self, 1, 0);};
void() zombieFast_walk16 = [ 30, zombieFast_walk17 ]{ai_walk(7);};
void() zombieFast_walk17 = [ 31, zombieFast_walk18 ]{ai_walk(3);};
void() zombieFast_walk18 = [ 32, zombieFast_walk1 ]{
	local float rSnd;

	ai_walk(8);
	rSnd = random();

	if ((rSnd < (1 / 4))) 
		sound(self, CHAN_VOICE, "zombie2/idle1.wav", 0.4, 3.5);
	else if ((rSnd < (2 / 4)))
		sound(self, CHAN_VOICE, "zombie2/idle2.wav", 0.4, 3.5);
	else if ((rSnd < (3 / 4)))
		sound(self, CHAN_VOICE, "zombie2/idle3.wav", 0.4, 3.5);
	else
		sound(self, CHAN_VOICE, "zombie2/idle4.wav", 0.4, 3.5);
};

void(float step) ai_fZom_run = {
	vector _origin;
	float _count;
	//float dist;
	float eYaw;
	float loopStep;
	float enemy_range2D;
	vector vec;

	if (!ai_run_checks(step))
		return;

	_origin = self.origin;
	eYaw = vectoyaw(self.enemy.origin - self.origin);
	enemy_range2D = vlen([self.origin_x, self.origin_y, 0] - [self.enemy.origin_x, self.enemy.origin_y, 0]);

	if (enemy_vis) {
		if (enemy_range2D < 512) {
			if (enemy_range2D < 192)
				self.frame = (self.frame + 8);
			
			loopStep = 12;
			_count = floor(128 / loopStep);

			while (_count > 0) {
				_count = _count - 1;

				if (!walkmove(eYaw, loopStep))
					_count = -666;
				
			}

			setorigin(self, _origin);
			if (_count != -666) {
				self.ideal_yaw = eYaw + crandom();
				ChangeYaw();
				walkmove(eYaw, step);
				return;
			}
		}
	}

	movetogoal(1);
	walkmove2(self.angles_y, step - 1);
	vec_y = self.ideal_yaw;
	makevectors(vec);
	vec = (self.origin + (v_forward * 32));
	self.ideal_yaw = self.ideal_yaw + crandom();

	if (self.origin == _origin) {
		if (enemy_range == RANGE_MELEE) {
			self.ideal_yaw = eYaw;
			ChangeYaw();
		}
		else {
			self.ideal_yaw = (random() * 360);
			ChangeYaw();
		}
	}
	
};

void() zombieFast_run1 = [ 33, zombieFast_run2 ]{ai_fZom_run(24);/*genHeal(self, 1, 0);*/};
void() zombieFast_run2 = [ 34, zombieFast_run3 ]{ai_fZom_run(24);zombieFast_footStep();};
void() zombieFast_run3 = [ 35, zombieFast_run4 ]{ai_fZom_run(24);};
void() zombieFast_run4 = [ 36, zombieFast_run5 ]{ai_fZom_run(24);};
void() zombieFast_run5 = [ 37, zombieFast_run6 ]{ai_fZom_run(24);};
void() zombieFast_run6 = [ 38, zombieFast_run7 ]{ai_fZom_run(24);zombieFast_footStep();};
void() zombieFast_run7 = [ 39, zombieFast_run8 ]{ai_fZom_run(24);};
void() zombieFast_run8 = [ 40, zombieFast_run1 ]{
	local float rSnd;
	ai_fZom_run(24);
	if (time > self.air_finished) {
		rSnd = random();
		if (rSnd < (1 / 4))
			sound(self, CHAN_VOICE, "zombie2/idle5.wav", 0.4, 3.5);
		else if (rSnd < (2 / 4))
			sound(self, CHAN_VOICE, "zombie2/idle6.wav", 0.4, 3.5);
		else if (rSnd < (3 / 4))
			sound(self, CHAN_VOICE, "zombie2/idle7.wav", 0.4, 3.5);
		else
			sound(self, CHAN_VOICE, "zombie2/idle8.wav", 0.4, 3.5);

		self.air_finished = (time + 6) + (random() * 2);
	}
};

void() zombieFast_meleeAttack =
{
	vector delta;
	float ldmg;
	float dist;
	float rSnd;

	if (!self.enemy) 
		return;
	
	delta = self.enemy.origin - self.origin;
	dist = vlen(delta);
	dist = (dist - self.enemy.maxs_x) - self.maxs_x;
	if (dist > 16)
		return;
	
	rSnd = random();

	if (rSnd < (1 / 4))
		sound(self, CHAN_WEAPON, "zombie2/punch1.wav", 1, ATTN_NORM);
	else if (rSnd < (2 / 4))
		sound(self, CHAN_WEAPON, "zombie2/punch2.wav", 1, ATTN_NORM);
	else if (rSnd < (3 / 4))
		sound(self, CHAN_WEAPON, "zombie2/punch3.wav", 1, ATTN_NORM);
	else
		sound(self, CHAN_WEAPON, "zombie2/punch4.wav", 1, ATTN_NORM);
			
	
	ldmg = startskill;

	if ((ldmg < 0))
		ldmg = 1;
	else if ((ldmg > 3))
		ldmg = 3;
	
	ldmg = (ldmg + 2);

	T_Damage(self.enemy, self, self, ldmg, DMGTYPE_MELEE);
};

//-----------------------------------------------------------------------------------------------------

void(float step) ai_zCharge =
{
	ai_face();
	//walkmove_robust(self.angles_y, step, 10);
	walkmove2(self.angles_y, step);
};

void() zombieFast_atkl1 = [ 49, zombieFast_atkl2 ]{ai_zCharge(24);};
void() zombieFast_atkl2 = [ 50, zombieFast_atkl3 ]{ai_zCharge(24);};
void() zombieFast_atkl3 = [ 51, zombieFast_atkl4 ]{ai_zCharge(24);};
void() zombieFast_atkl4 = [ 52, zombieFast_atkl5 ]{ai_zCharge(24);zombieFast_meleeAttack();};
void() zombieFast_atkl5 = [ 53, zombieFast_atkl6 ]{ai_zCharge(24);};
void() zombieFast_atkl6 = [ 54, zombieFast_atkl7 ]{ai_zCharge(24);};
void() zombieFast_atkl7 = [ 55, zombieFast_atkl8 ]{ai_zCharge(24);};
void() zombieFast_atkl8 = [ 56, zombieFast_run1 ]{ai_zCharge(24);};

void() zombieFast_atkr1 = [ 57, zombieFast_atkr2 ]{ai_zCharge(24);};
void() zombieFast_atkr2 = [ 58, zombieFast_atkr3 ]{ai_zCharge(24);};
void() zombieFast_atkr3 = [ 59, zombieFast_atkr4 ]{ai_zCharge(24);};
void() zombieFast_atkr4 = [ 60, zombieFast_atkr5 ]{ai_zCharge(24);zombieFast_meleeAttack();};
void() zombieFast_atkr5 = [ 61, zombieFast_atkr6 ]{ai_zCharge(24);};
void() zombieFast_atkr6 = [ 62, zombieFast_atkr7 ]{ai_zCharge(24);};
void() zombieFast_atkr7 = [ 63, zombieFast_atkr8 ]{ai_zCharge(24);};
void() zombieFast_atkr8 = [ 64, zombieFast_run1 ]{ai_zCharge(24);};

void() zombieFast_atkm1 = [ 65, zombieFast_atkm2 ]{ai_zCharge(24);};
void() zombieFast_atkm2 = [ 66, zombieFast_atkm3 ]{ai_zCharge(24);};
void() zombieFast_atkm3 = [ 67, zombieFast_atkm4 ]{ai_zCharge(24);};
void() zombieFast_atkm4 = [ 68, zombieFast_atkm5 ]{ai_zCharge(24);zombieFast_meleeAttack();};
void() zombieFast_atkm5 = [ 69, zombieFast_atkm6 ]{ai_zCharge(24);};
void() zombieFast_atkm6 = [ 70, zombieFast_atkm7 ]{ai_zCharge(24);};
void() zombieFast_atkm7 = [ 71, zombieFast_atkm8 ]{ai_zCharge(24);};
void() zombieFast_atkm8 = [ 72, zombieFast_run1 ]{ai_zCharge(24);};

void() zombieFast_melee =
{
	local float r;

	r = random();

	if (r < (1 / 7)) 
		sound(self, CHAN_VOICE, "zombie2/attack1.wav", 1, ATTN_NORM);
	else if (r < (2 / 7))
		sound(self, CHAN_VOICE, "zombie2/attack2.wav", 1, ATTN_NORM);
	else if (r < (3 / 7))
		sound(self, CHAN_VOICE, "zombie2/attack3.wav", 1, ATTN_NORM);
	else if (r < (4 / 7))
		sound(self, CHAN_VOICE, "zombie2/attack4.wav", 1, ATTN_NORM);
	else if (r < (5 / 7))
		sound(self, CHAN_VOICE, "zombie2/attack5.wav", 1, ATTN_NORM);
	else if (r < (6 / 7))
		sound(self, CHAN_VOICE, "zombie2/attack6.wav", 1, ATTN_NORM);
	else
		sound(self, CHAN_VOICE, "zombie2/attack7.wav", 1, ATTN_NORM);
		
	if (random() < 0.75) {
		if (self.state) zombieFast_atkl1();
		else zombieFast_atkr1();

		self.state = (1 - self.state);
	}
	else {
		zombieFast_atkm1();
	}
};

void() zombieFast_deathA1 = [ 73, zombieFast_deathA2 ]{};
void() zombieFast_deathA2 = [ 74, zombieFast_deathA3 ]{ai_pain(8);};
void() zombieFast_deathA3 = [ 75, zombieFast_deathA4 ]{ai_pain(5);};
void() zombieFast_deathA4 = [ 76, zombieFast_deathA5 ]{ai_pain(3);};
void() zombieFast_deathA5 = [ 77, zombieFast_deathA6 ]{ai_pain(1);};
void() zombieFast_deathA6 = [ 78, zombieFast_deathA7 ]{ai_pain(2);};
void() zombieFast_deathA7 = [ 79, zombieFast_deathA8 ]{ai_pain(1);};
void() zombieFast_deathA8 = [ 80, zombieFast_deathA9 ]{ai_pain(1);};
void() zombieFast_deathA9 = [ 81, zombieFast_deathA10 ]{ai_pain(2);};
void() zombieFast_deathA10 = [ 82, zombieFast_deathA11 ]{};
void() zombieFast_deathA11 = [ 83, zombieFast_deathA11 ]{self.think = SUB_MakeNotSolid; self.nextthink = time + 5;};

void() zombieFast_deathB1 = [ 84, zombieFast_deathB2 ]{ai_pain(16 + random()*8);};
void() zombieFast_deathB2 = [ 85, zombieFast_deathB3 ]{ai_pain(16 + random()*8);};
void() zombieFast_deathB3 = [ 86, zombieFast_deathB4 ]{ai_pain(16 + random() * 8);};
void() zombieFast_deathB4 = [ 87, zombieFast_deathB5 ]{ai_pain(8);};
void() zombieFast_deathB5 = [ 88, zombieFast_deathB6 ]{ai_pain(4);};
void() zombieFast_deathB6 = [ 89, zombieFast_deathB7 ]{};
void() zombieFast_deathB7 = [ 90, zombieFast_deathB8 ]{};
void() zombieFast_deathB8 = [ 91, zombieFast_deathB9 ]{};
void() zombieFast_deathB9 = [ 92, zombieFast_deathB9 ]{self.think = SUB_MakeNotSolid; self.nextthink = time + 5;};

void() zombieFast_deathC1 = [ 93, zombieFast_deathC2 ]{};
void() zombieFast_deathC2 = [ 94, zombieFast_deathC3 ]{};
void() zombieFast_deathC3 = [ 95, zombieFast_deathC4 ]{};
void() zombieFast_deathC4 = [ 96, zombieFast_deathC5 ]{};
void() zombieFast_deathC5 = [ 97, zombieFast_deathC6 ]{};
void() zombieFast_deathC6 = [ 98, zombieFast_deathC7 ]{};
void() zombieFast_deathC7 = [ 99, zombieFast_deathC8 ]{};
void() zombieFast_deathC8 = [ 100, zombieFast_deathC9 ]{};
void() zombieFast_deathC9 = [ 101, zombieFast_deathC10 ]{ai_right(2);};
void() zombieFast_deathC10 = [ 102, zombieFast_deathC11 ]{ai_right(6);};
void() zombieFast_deathC11 = [ 103, zombieFast_deathC11 ]{self.think = SUB_MakeNotSolid; self.nextthink = time + 5;};

void() zombieFast_deathD1 = [ 104, zombieFast_deathD2 ]{ai_zCharge(24);};
void() zombieFast_deathD2 = [ 105, zombieFast_deathD3 ]{ai_zCharge(20);};
void() zombieFast_deathD3 = [ 106, zombieFast_deathD4 ]{ai_zCharge(16);};
void() zombieFast_deathD4 = [ 107, zombieFast_deathD5 ]{ai_forward(14);};
void() zombieFast_deathD5 = [ 108, zombieFast_deathD6 ]{ai_forward(8);};
void() zombieFast_deathD6 = [ 109, zombieFast_deathD7 ]{ai_forward(4);};
void() zombieFast_deathD7 = [ 110, zombieFast_deathD8 ]{};
void() zombieFast_deathD8 = [ 111, zombieFast_deathD9 ]{};
void() zombieFast_deathD9 = [ 112, zombieFast_deathD10 ]{};
void() zombieFast_deathD10 = [ 113, zombieFast_deathD10 ]{self.think = SUB_MakeNotSolid; self.nextthink = time + 5;};

void() zombieFast_die =
{
	local float r;

	if (self.health < -40) {
		sound(self, CHAN_VOICE, "zombie/z_gib.wav", 1, ATTN_NORM);
		ThrowHead("progs/h_zombie.mdl", self.health);
		ThrowGib("progs/gib1.mdl", self.health);
		ThrowGib("progs/gib2.mdl", self.health);
		ThrowGib("progs/gib3.mdl", self.health);
		return;
	}

	r = random();
	if (r < (1 / 3))
		sound(self, CHAN_VOICE, "zombie2/death1.wav", 1, ATTN_NORM);
	else if ((r < (2 / 3)))
		sound(self, CHAN_VOICE, "zombie2/death2.wav", 1, ATTN_NORM);
	else
		sound(self, CHAN_VOICE, "zombie2/death3.wav", 1, ATTN_NORM);

	r = random();
	
	self.solid = SOLID_TRIGGER;
	setorigin(self, self.origin);
	
	if (r < (1 / 4))
		zombieFast_deathA1();
	else if (r < (2 / 4))
		zombieFast_deathB1();
	else if (r < (3 / 4))
		zombieFast_deathC1();
	else
		zombieFast_deathD1();
};

void(entity attacker, float take) zombieFast_pain = {
	return;
};

void() monster_zombie2_precaches =
{
	precache_model("progs/zombie2.mdl");
	precache_model("progs/h_zombie.mdl");
	precache_model("progs/zom_gib.mdl");
	precache_sound("zombie2/sight1.wav");
	precache_sound("zombie2/sight2.wav");
	precache_sound("zombie2/sight3.wav");
	precache_sound("zombie2/idle1.wav");
	precache_sound("zombie2/idle2.wav");
	precache_sound("zombie2/idle3.wav");
	precache_sound("zombie2/idle4.wav");
	precache_sound("zombie2/idle5.wav");
	precache_sound("zombie2/idle6.wav");
	precache_sound("zombie2/idle7.wav");
	precache_sound("zombie2/idle8.wav");
	precache_sound("zombie2/footstep1.wav");
	precache_sound("zombie2/footstep2.wav");
	precache_sound("zombie2/footstep3.wav");
	precache_sound("zombie2/footstep4.wav");
	precache_sound("zombie2/footstep5.wav");
	precache_sound("zombie2/attack1.wav");
	precache_sound("zombie2/attack2.wav");
	precache_sound("zombie2/attack3.wav");
	precache_sound("zombie2/attack4.wav");
	precache_sound("zombie2/attack5.wav");
	precache_sound("zombie2/attack6.wav");
	precache_sound("zombie2/attack7.wav");
	precache_sound("zombie2/punch1.wav");
	precache_sound("zombie2/punch2.wav");
	precache_sound("zombie2/punch3.wav");
	precache_sound("zombie2/punch4.wav");
	precache_sound("zombie2/death1.wav");
	precache_sound("zombie2/death2.wav");
	precache_sound("zombie2/death3.wav");
	precache_sound("zombie/z_gib.wav");
};
/*
void() monster_zombie2 =
{
	local float ambush;

	self.netname = "Fresh Zombie";
	if (deathmatch)
	{
		remove(self);
		return;
	}
	monster_zombie2_precaches();
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	setmodel(self, "progs/zombie2.mdl");
	setsize(self, '-6 -6 -24', '6 6 32');
	self.health = 5;
	self.flagsDmg = ((self.flagsDmg | FLD_ALLOWBULLETPENETRATION) | FLD_ALLOWNAILPENETRATION);
	self.th_stand = zombieFast_stand1;
	self.th_walk = zombieFast_walk1;
	self.th_jog = zombieFast_jog1;
	self.th_run = zombieFast_run1;
	self.th_pain = zombieFast_pain;
	self.th_die = zombieFast_die;
	self.th_melee = zombieFast_melee;
	self.yaw_speed = 35;
	monster_start();
};
*/



void(entity e) monster_zombie2_start =
{
	local entity oself;

	oself = self;
	self = e;

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel(self, "progs/zombie2.mdl");

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize(self, self.cmins, self.cmaxs);
	
	self.health = 10;
	if (self.obituary == "") self.obituary = "was swarmed by a Fast Zombie";

	
	self.th_stand = zombieFast_stand1;
	self.th_walk = zombieFast_walk1;
	self.th_run = zombieFast_run1;
	self.th_pain = zombieFast_pain;
	self.th_die = zombieFast_die;
	self.th_melee = zombieFast_melee;
	self.yaw_speed = 35;

	walkmonster_start ();

	self = oself;
};

void() monster_zombie2_spawner = {
	monster_spawner(monster_knight_start);
};

void() monster_zombie2 =
{
	if (!SUB_InitEntity()) return;
	
	if (deathmatch)
	{
		remove(self);
		return;
	}
	
	monster_zombie2_precaches();
	self.cmins = '-6 -6 -24';
	self.cmaxs = '6 6 32';

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize(self, self.cmins, self.cmaxs);
	
	if (self.spawnflags & MONSTER_SPAWNER) {
		self.use = monster_zombie2_spawner;
		monster_spawner_updatecounter();
	}
	else {
		monster_zombie2_start(self);
	}
};
