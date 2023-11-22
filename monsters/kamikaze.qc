/*
==============================================================================

Kamikaze Grunt

==============================================================================
*/
//0-7
$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8

//8-17
$frame death1 death2 death3 death4 death5 death6 death7 death8
$frame death9 death10

//18-28
$frame deathc1 deathc2 deathc3 deathc4 deathc5 deathc6 deathc7 deathc8
$frame deathc9 deathc10 deathc11

//29-39
$frame load1 load2 load3 load4 load5 load6 load7 load8 load9 load10 load11

//40-45
$frame pain1 pain2 pain3 pain4 pain5 pain6

//46-59
$frame painb1 painb2 painb3 painb4 painb5 painb6 painb7 painb8 painb9 painb10
$frame painb11 painb12 painb13 painb14

//60-72
$frame painc1 painc2 painc3 painc4 painc5 painc6 painc7 painc8 painc9 painc10
$frame painc11 painc12 painc13

//73-80
$frame run1 run2 run3 run4 run5 run6 run7 run8

//81-89
$frame shoot1 shoot2 shoot3 shoot4 shoot5 shoot6 shoot7 shoot8 shoot9

//90-113
$frame prowl_1 prowl_2 prowl_3 prowl_4 prowl_5 prowl_6 prowl_7 prowl_8
$frame prowl_9 prowl_10 prowl_11 prowl_12 prowl_13 prowl_14 prowl_15 prowl_16
$frame prowl_17 prowl_18 prowl_19 prowl_20 prowl_21 prowl_22 prowl_23 prowl_24




//0-7
void()	kami_stand1	=[	$stand1,	kami_stand2	] {self.pos1 = '8 2 32';ai_stand();};
void()	kami_stand2	=[	$stand2,	kami_stand3	] {self.pos1 = '8 2 32';ai_stand();};
void()	kami_stand3	=[	$stand3,	kami_stand4	] {self.pos1 = '8 2 32';ai_stand();};
void()	kami_stand4	=[	$stand4,	kami_stand5	] {self.pos1 = '8 2 32';ai_stand();};
void()	kami_stand5	=[	$stand5,	kami_stand6	] {self.pos1 = '8 2 32';ai_stand();};
void()	kami_stand6	=[	$stand6,	kami_stand7	] {self.pos1 = '8 2 32';ai_stand();};
void()	kami_stand7	=[	$stand7,	kami_stand8	] {self.pos1 = '8 2 32';ai_stand();};
void()	kami_stand8	=[	$stand8,	kami_stand1	] {self.pos1 = '8 2 32';ai_stand();};

//90-113
void()	kami_walk1	=[	$prowl_1,	kami_walk2	] {
	self.pos1 = '6 -2 36';
    if(!(self.spawnflags & MONSTER_NOIDLESOUND)) {
		if (random() < 0.2 )
			sound (self, CHAN_VOICE, "soldier/idle.wav", 1, ATTN_IDLE);
	}
	ai_walk(1);
};
void()	kami_walk2	=[	$prowl_2,	kami_walk3	] {self.pos1 = '6 -2 34';ai_walk(1);};
void()	kami_walk3	=[	$prowl_3,	kami_walk4	] {self.pos1 = '8 -2 32';ai_walk(1);};
void()	kami_walk4	=[	$prowl_4,	kami_walk5	] {self.pos1 = '10 -2 32';ai_walk(1);};
void()	kami_walk5	=[	$prowl_5,	kami_walk6	] {self.pos1 = '10 -4 32';ai_walk(2);};
void()	kami_walk6	=[	$prowl_6,	kami_walk7	] {self.pos1 = '12 -4 34';ai_walk(3);}; //95
void()	kami_walk7	=[	$prowl_7,	kami_walk8	] {self.pos1 = '12 -4 34';ai_walk(4);};
void()	kami_walk8	=[	$prowl_8,	kami_walk9	] {self.pos1 = '10 -4 34';ai_walk(4);};
void()	kami_walk9	=[	$prowl_9,	kami_walk10	] {self.pos1 = '10 -4 34';ai_walk(2);};
void()	kami_walk10	=[	$prowl_10,	kami_walk11	] {self.pos1 = '8 -4 34';ai_walk(2);};
void()	kami_walk11	=[	$prowl_11,	kami_walk12	] {self.pos1 = '8 -4 34';ai_walk(2);}; //100
void()	kami_walk12	=[	$prowl_12,	kami_walk13	] {self.pos1 = '6 -4 34';ai_walk(1);};
void()	kami_walk13	=[	$prowl_13,	kami_walk14	] {self.pos1 = '6 -2 34';ai_walk(0);};
void()	kami_walk14	=[	$prowl_14,	kami_walk15	] {self.pos1 = '6 -2 34';ai_walk(1);};
void()	kami_walk15	=[	$prowl_15,	kami_walk16	] {self.pos1 = '6 -2 34';ai_walk(1);};
void()	kami_walk16	=[	$prowl_16,	kami_walk17	] {self.pos1 = '6 0 34';ai_walk(1);}; //105
void()	kami_walk17	=[	$prowl_17,	kami_walk18	] {self.pos1 = '8 0 34';ai_walk(3);};
void()	kami_walk18	=[	$prowl_18,	kami_walk19	] {self.pos1 = '8 0 36';ai_walk(3);};
void()	kami_walk19	=[	$prowl_19,	kami_walk20	] {self.pos1 = '8 0 38';ai_walk(3);};
void()	kami_walk20	=[	$prowl_20,	kami_walk21	] {self.pos1 = '8 0 38';ai_walk(3);};
void()	kami_walk21	=[	$prowl_21,	kami_walk22	] {self.pos1 = '6 0 38';ai_walk(2);}; //110
void()	kami_walk22	=[	$prowl_22,	kami_walk23	] {self.pos1 = '4 0 38';ai_walk(1);};
void()	kami_walk23	=[	$prowl_23,	kami_walk24	] {self.pos1 = '2 0 36';ai_walk(1);};
void()	kami_walk24	=[	$prowl_24,	kami_walk1	] {self.pos1 = '4 -2 36';ai_walk(1);};

float kamispd = 0.08;

void(float dist) kami_run = {
	if (visible(self.enemy) && infront(self.enemy) && vlen(self.origin - self.enemy.origin) < 100) {
		kami_load1();
		return;
	}
	ai_runjump(dist);
}

//73-80
void()	kami_run1	=[	$run1,		kami_run2	] {
	self.pos1 = '0 0 34';
	nxth(kamispd);
	if (random() < 0.2)
		sound (self, CHAN_VOICE, "soldier/idle.wav", 1, ATTN_IDLE);
	kami_run(14);
};
void()	kami_run2	=[	$run2,		kami_run3	] {self.pos1 = '0 0 34';nxth(kamispd); kami_run(25);};
void()	kami_run3	=[	$run3,		kami_run4	] {self.pos1 = '0 4 34';nxth(kamispd); kami_run(18);};
void()	kami_run4	=[	$run4,		kami_run5	] {self.pos1 = '0 6 34';nxth(kamispd); kami_run(18);};
void()	kami_run5	=[	$run5,		kami_run6	] {self.pos1 = '0 6 34';nxth(kamispd); kami_run(12);};
void()	kami_run6	=[	$run6,		kami_run7	] {self.pos1 = '0 4 34';nxth(kamispd); kami_run(25);};
void()	kami_run7	=[	$run7,		kami_run8	] {self.pos1 = '0 2 34';nxth(kamispd); kami_run(18);};
void()	kami_run8	=[	$run8,		kami_run1	] {self.pos1 = '0 0 34';nxth(kamispd); kami_run(12);};


//=================================================================================================

//40-45
void()	kami_pain1	=[	$pain1,		kami_pain2	] {self.pos1 = '4 4 30';}; //40
void()	kami_pain2	=[	$pain2,		kami_pain3	] {self.pos1 = '-6 10 34';};
void()	kami_pain3	=[	$pain3,		kami_pain4	] {self.pos1 = '-8 14 32';};
void()	kami_pain4	=[	$pain4,		kami_pain5	] {self.pos1 = '0 10 32';};
void()	kami_pain5	=[	$pain5,		kami_pain6	] {self.pos1 = '6 8 34';};
void()	kami_pain6	=[	$pain6,		kami_run1	] {self.pos1 = '2 2 34';ai_pain(1);};

//46-59
void()	kami_painb1	=[	$painb1,	kami_painb2	] {self.pos1 = '4 8 32';};
void()	kami_painb2	=[	$painb2,	kami_painb3	] {self.pos1 = '2 8 28'; ai_painforward(13);};
void()	kami_painb3	=[	$painb3,	kami_painb4	] {self.pos1 = '-2 8 22'; ai_painforward(9);};
void()	kami_painb4	=[	$painb4,	kami_painb5	] {self.pos1 = '6 8 20';};
void()	kami_painb5	=[	$painb5,	kami_painb6	] {self.pos1 = '22 12 4';}; //50
void()	kami_painb6	=[	$painb6,	kami_painb7	] {self.pos1 = '18 14 -8';};
void()	kami_painb7	=[	$painb7,	kami_painb8	] {self.pos1 = '16 16 -6';};
void()	kami_painb8	=[	$painb8,	kami_painb9	] {self.pos1 = '16 16 -6';};
void()	kami_painb9	=[	$painb9,	kami_painb10] {self.pos1 = '16 14 -6';};
void()	kami_painb10=[	$painb10,	kami_painb11] {self.pos1 = '20 10 -4';}; //55
void()	kami_painb11=[	$painb11,	kami_painb12] {self.pos1 = '20 10 2';};
void()	kami_painb12=[	$painb12,	kami_painb13] {self.pos1 = '22 6 12';ai_pain(2);};
void()	kami_painb13=[	$painb13,	kami_painb14] {self.pos1 = '14 8 24';};
void()	kami_painb14=[	$painb14,	kami_run1	] {self.pos1 = '8 6 30';};

//60-72
void()	kami_painc1	=[	$painc1,	kami_painc2	] {self.pos1 = '0 2 34';};
void()	kami_painc2	=[	$painc2,	kami_painc3	] {self.pos1 = '-4 -4 36';ai_pain(1);};
void()	kami_painc3	=[	$painc3,	kami_painc4	] {self.pos1 = '0 -2 34';};
void()	kami_painc4	=[	$painc4,	kami_painc5	] {self.pos1 = '12 2 28';};
void()	kami_painc5	=[	$painc5,	kami_painc6	] {self.pos1 = '22 6 16';ai_painforward(1);};
void()	kami_painc6	=[	$painc6,	kami_painc7	] {self.pos1 = '22 6 20';ai_painforward(1);}; //65
void()	kami_painc7	=[	$painc7,	kami_painc8	] {self.pos1 = '24 6 16';};
void()	kami_painc8	=[	$painc8,	kami_painc9	] {self.pos1 = '24 6 20';ai_pain(1);};
void()	kami_painc9	=[	$painc9,	kami_painc10] {self.pos1 = '24 0 20';ai_painforward(4);};
void()	kami_painc10=[	$painc10,	kami_painc11] {self.pos1 = '22 0 24';ai_painforward(3);};
void()	kami_painc11=[	$painc11,	kami_painc12] {self.pos1 = '20 0 24';ai_painforward(6);}; //70
void()	kami_painc12=[	$painc12,	kami_painc13] {self.pos1 = '14 2 30';ai_painforward(8);};
void()	kami_painc13=[	$painc13,	kami_run1] {self.pos1 = '12 2 30';};

void(entity attacker, float damage)	kami_pain =
{
	local float r;
	
	if (self.pain_finished > time)
		return;

	r = random();

	if (r < 0.2)
	{
		self.pain_finished = time + 0.6;
		kami_pain1 ();
		sound (self, CHAN_VOICE, "soldier/pain1.wav", 1, ATTN_NORM);
	}
	else if (r < 0.6)
	{
		self.pain_finished = time + 1.1;
		kami_painb1 ();
		sound (self, CHAN_VOICE, "soldier/pain2.wav", 1, ATTN_NORM);
	}
	else
	{
		self.pain_finished = time + 1.1;
		kami_painc1 ();
		sound (self, CHAN_VOICE, "soldier/pain2.wav", 1, ATTN_NORM);
	}

};


//8-17
void()	kami_die1	=[	$death1,	kami_die2	] {self.pos1 = '-6 4 40';};
void()	kami_die2	=[	$death2,	kami_die3	] {self.pos1 = '-14 4 40';};
void()	kami_die3	=[	$death3,	kami_die4	]
{self.solid = SOLID_TRIGGER; setorigin(self, self.origin);
self.pos1 = '-20 4 38';}; //10
void()	kami_die4	=[	$death4,	kami_die5	] {self.pos1 = '-28 6 32';};
void()	kami_die5	=[	$death5,	kami_die6	] {self.pos1 = '-36 4 20';};
void()	kami_die6	=[	$death6,	kami_die7	] {self.pos1 = '-42 4 4';};
void()	kami_die7	=[	$death7,	kami_die8	] {self.pos1 = '-46 4 -10';};
void()	kami_die8	=[	$death8,	kami_die9	] {self.pos1 = '-48 -6 -16';}; //15
void()	kami_die9	=[	$death9,	kami_die10	] {self.pos1 = '-48 -4 -16';};
void()	kami_die10	=[	$death10,	kami_die10	] {self.pos1 = '-48 -6 -16'; monster_dead_dead();};

//18-28
void()	kami_cdie1	=[	$deathc1,	kami_cdie2	] {self.pos1 = '-26 -4 32';};
void()	kami_cdie2	=[	$deathc2,	kami_cdie3	] {self.pos1 = '-34 -2 26'; ai_back(5);};
void()	kami_cdie3	=[	$deathc3,	kami_cdie4	]
{self.pos1 = '-36 -6 22';self.solid = SOLID_TRIGGER; setorigin(self, self.origin);ai_back(4);}; //20
void()	kami_cdie4	=[	$deathc4,	kami_cdie5	] {self.pos1 = '-34 -10 18';ai_back(13);};
void()	kami_cdie5	=[	$deathc5,	kami_cdie6	] {self.pos1 = '-32 -12 16';ai_back(3);};
void()	kami_cdie6	=[	$deathc6,	kami_cdie7	] {self.pos1 = '-26 -8 14';ai_back(4);};
void()	kami_cdie7	=[	$deathc7,	kami_cdie8	] {self.pos1 = '-30 0 6';};
void()	kami_cdie8	=[	$deathc8,	kami_cdie9	] {self.pos1 = '-40 6 -4';}; //25
void()	kami_cdie9	=[	$deathc9,	kami_cdie10	] {self.pos1 = '-50 8 -16';};
void()	kami_cdie10	=[	$deathc10,	kami_cdie11	] {self.pos1 = '-50 8 -16';};
void()	kami_cdie11	=[	$deathc11,	kami_cdie11	] {self.pos1 = '-50 8 -16'; monster_dead_dead();};


void() kami_gib = {
	sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
	ThrowHead ("progs/h_guard.mdl", self.health);
	ThrowGib ("progs/gib1.mdl", self.health);
	ThrowGib ("progs/gib2.mdl", self.health);
	ThrowGib ("progs/gib3.mdl", self.health);
	ThrowGib ("progs/gib3.mdl", self.health);
	if (random() < 0.2)
    	ThrowGib ("progs/arm_foot.mdl", self.health);
	self.deadflag = DEAD_GIBBED;
}

void() kami_die =
{

	if (self.health < -35)
	{
		kami_gib();
		SUB_CallAsSelf(kamikaze_explosiveboom, self.trigger_field);
		return;
	}

	//self.skin = 3;

// regular death
	sound (self, CHAN_VOICE, "soldier/death1.wav", 1, ATTN_NORM);
	if (random() < 0.5)
		kami_die1 ();
	else
		kami_cdie1 ();
};


float(entity inflictor, entity attacker, float damage, float orig_damage, float dmgtype) kami_damage = {
	
	// no need to check hitscan or explosive attacks
	if (inflictor == attacker || dmgtype == DMGTYPE_EXPLOSION){
		//dprint("hitscan or explosion\n");
		return damage;
	}

	//vector dir = normalize(inflictor.velocity);
	
	// tracelines also ignore hits if forent == trace_ent.owner
	// so set the box's owner to world before testing
	self.trigger_field.owner = world;
	// enlarge box bbox a bit
	setsize(self.trigger_field, '-12 -12 -12', '12 12 12');

	traceline(inflictor.origin, inflictor.origin + normalize(inflictor.velocity)*64, FALSE, self);
	
	self.trigger_field.owner = self;
	setsize(self.trigger_field, '-8 -8 -8', '8 8 8');

	/*
	dprint3("box origin", vtos(self.trigger_field.origin), "\n");
	dprint3("trace origin", vtos(inflictor.origin), "\n");
	dprint3("trace dest", vtos(inflictor.origin + dir*64), "\n");
	dprint3("trace_ent class: ", trace_ent.classname, "\n");
	dprint3("trace distance: ", ftos(trace_fraction * 64), "\n");
	*/

	if (trace_ent.classname != "kamikaze_explosive" || trace_ent.owner != self){
		//dprint("didn't hit box\n");
		return damage;
	}
	
	T_Damage(trace_ent, inflictor, attacker, damage, dmgtype);

	ImpactSpawn(inflictor.origin, inflictor.velocity, damage, trace_ent.bloodtype);

	if (self.health <= 0)
		//dprint("died from blast\n");
		return 0;
	else {
		//dprint("hit\n");
		return damage * 0.2;
	}

}


//=================================================================================================

void() kamikaze_explosivethink = {
	makevectors([-self.owner.angles_x, self.owner.angles_y, self.owner.angles_z]);
	setorigin(self, self.owner.origin + v_forward*self.owner.pos1_x - v_right*self.owner.pos1_y + v_up*self.owner.pos1_z);
	self.nextthink = time + 0.05;
}

void() kamikaze_explosiveboom = {
	if (self.state == 1) // already exploding
		return;
	
	self.state = 1; // exploding

	self.solid = SOLID_NOT;

	if (self.owner.health <= 0 && self.owner.health > -35) {
		//dprint("Dead!\n");
		self.owner.health = -50;
		self.owner.inflictor_origin = self.origin;
		SUB_CallAsSelf(kami_gib, self.owner);
	}
	else if (self.owner.health > 0){
		//dprint("Alive!\n");
		T_Damage(self.owner, self, self.enemy, self.owner.health + 50, DMGTYPE_EXPLOSION);
		//eprint(self.owner);
	}

	T_RadiusDamage(self, self.enemy, 60, 2, self.owner, DMGTYPE_EXPLOSION);
	//dprint("Kaboom\n");

	
	BecomeExplosion();
}


void() kami_load1 = [$load1, kami_load2] {self.state = 0;};
void() kami_load2 = [$load2, kami_load3] {};
void() kami_load3 = [$load3, kami_load4] {};
void() kami_load4 = [$load4, kami_load5] {};
void() kami_load5 = [$load5, kami_load5] {SUB_CallAsSelf(kamikaze_explosiveboom, self.trigger_field);};
void() kami_load6 = [$load6, kami_load7] {};
void() kami_load7 = [$load7, kami_load8] {};
void() kami_load8 = [$load8, kami_load8] {SUB_CallAsSelf(kamikaze_explosiveboom, self.trigger_field);};

//=================================================================================================

void() kami_sight = {
	sound (self, CHAN_VOICE, "soldier/sight1.wav", 1, ATTN_NORM);
}

void() kami_spawn = {
	dprint("oi\n");
    self.trigger_field = spawn();
    self.trigger_field.classname = "kamikaze_explosive";
    self.trigger_field.solid = SOLID_BBOX;
    self.trigger_field.movetype = MOVETYPE_NOCLIP;
	setsize(self.trigger_field, '-8 -8 -8', '8 8 8');
	self.trigger_field.bloodtype = SPAWN_YELLOWSPARK;
	self.trigger_field.owner = self;
	self.trigger_field.health = 25;
	self.trigger_field.takedamage = DAMAGE_YES;
	self.trigger_field.think = kamikaze_explosivethink;
	self.trigger_field.nextthink = time + 0.05;
	self.trigger_field.th_die = kamikaze_explosiveboom;
	
	//SUB_CallAsSelf(kamikaze_explosivethink, self.trigger_field);
}

/*QUAKED monster_army (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
void(entity e) monster_kamikaze_start =
{	
	local entity oself;

	oself = self;
	self = e;

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/kamikaze_grunt_small.mdl");

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize(self, self.cmins, self.cmaxs);
	
	self.health = self.max_health = 40;
	if (self.obituary == "") self.obituary = "was shot by a Grunt";
	
	self.th_stand = kami_stand1;
	self.th_walk = kami_walk1;
	self.th_run = kami_run1;
	self.th_damage = kami_damage;
	//self.th_missile = kami_atk1;
	self.th_pain = kami_pain;
	self.th_die = kami_die;
	self.th_spawn = kami_spawn;
    self.ammo_shells = 5;
    self.th_sight = kami_sight;
    
	self.autojump = defaultFl(self.autojump, 1);
    //self.th_checkattack = KamikazeCheckAttack;

    self.pos1 = '8 0 32';
	/*
	self.trigger_field = spawn();
    self.trigger_field.classname = "kamikaze_explosive";
    self.trigger_field.solid = SOLID_BBOX;
    self.trigger_field.movetype = MOVETYPE_NOCLIP;
	setsize(self.trigger_field, '-8 -8 -8', '8 8 8');
	self.trigger_field.bloodtype = SPAWN_YELLOWSPARK;
	self.trigger_field.owner = self;
	self.trigger_field.health = 25;
	self.trigger_field.takedamage = DAMAGE_YES;
	self.trigger_field.think = kamikaze_explosivethink;
	self.trigger_field.nextthink = time + 0.05;
	self.trigger_field.th_die = kamikaze_explosiveboom;

	SUB_CallAsSelf(kamikaze_explosivethink, self.trigger_field);
	*/
	walkmonster_start();

	self = oself;
};

void() monster_kamikaze_spawner = {
	monster_spawner(monster_kamikaze_start);
};


void() monster_kamikaze = {
	if (!SUB_InitEntity()) return;
	
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/kamikaze_grunt_small.mdl");
	precache_model ("progs/h_guard.mdl");
	precache_model ("progs/gib1.mdl");
	precache_model ("progs/gib2.mdl");
	precache_model ("progs/gib3.mdl");
    precache_model ("progs/arm_foot.mdl");
	precache_model ("progs/shelcase.mdl");

	precache_sound ("soldier/death1.wav");
	precache_sound ("soldier/idle.wav");
	precache_sound ("soldier/pain1.wav");
	precache_sound ("soldier/pain2.wav");
	precache_sound ("soldier/sattck1.wav");
	precache_sound ("soldier/sight1.wav");

	precache_sound ("player/udeath.wav");		// gib death

	self.cmins = '-16 -16 -24';
	self.cmaxs = '16 16 24';

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize(self, self.cmins, self.cmaxs);
	
	if (self.spawnflags & MONSTER_SPAWNER) {
		self.use = monster_kamikaze_spawner;
		monster_spawner_updatecounter();
	}
	else {
		monster_kamikaze_start(self);
	}
};
