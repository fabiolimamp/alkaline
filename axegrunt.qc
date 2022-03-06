/*
==============================================================================

AXE GRUNT
Suitable replacement for knight in base maps.  Grunts a lot.

==============================================================================
*/


//
// running axe
//0-5
$frame axrun1 axrun2 axrun3 axrun4 axrun5 axrun6


//
// running no axe
//6-11
$frame rockrun1 rockrun2 rockrun3 rockrun4 rockrun5 rockrun6

// walking is just slowed down running - Greenwood's "mall walker" fix

//
// standing
//12-16

$frame stand1 stand2 stand3 stand4 stand5 //unused

//17-28
$frame axstnd1 axstnd2 axstnd3 axstnd4 axstnd5 axstnd6
$frame axstnd7 axstnd8 axstnd9 axstnd10 axstnd11 axstnd12


//
// pain
//29-34
$frame axpain1 axpain2 axpain3 axpain4 axpain5 axpain6

//35-40
$frame pain1 pain2 pain3 pain4 pain5 pain6 //unused


//
// death
//
//41-49
$frame axdeth1 axdeth2 axdeth3 axdeth4 axdeth5 axdeth6
$frame axdeth7 axdeth8 axdeth9
//50-60
$frame deatha1 deatha2 deatha3 deatha4 deatha5 deatha6 deatha7 deatha8
$frame deatha9 deatha10 deatha11
//61-69 -- dont use
$frame deathb1 deathb2 deathb3 deathb4 deathb5 deathb6 deathb7 deathb8
$frame deathb9
//70-84 -- high damage
$frame deathc1 deathc2 deathc3 deathc4 deathc5 deathc6 deathc7 deathc8
$frame deathc9 deathc10 deathc11 deathc12 deathc13 deathc14 deathc15
//85-93
$frame deathd1 deathd2 deathd3 deathd4 deathd5 deathd6 deathd7
$frame deathd8 deathd9
//94-102
$frame deathe1 deathe2 deathe3 deathe4 deathe5 deathe6 deathe7
$frame deathe8 deathe9

//
// attacks
//
//103-104
$frame nailatt1 nailatt2
//105-106
$frame light1 light2
//107-112
$frame rockatt1 rockatt2 rockatt3 rockatt4 rockatt5 rockatt6
//113-118
$frame shotatt1 shotatt2 shotatt3 shotatt4 shotatt5 shotatt6
//119-124
$frame axatt1 axatt2 axatt3 axatt4 axatt5 axatt6
//125-130
$frame axattb1 axattb2 axattb3 axattb4 axattb5 axattb6
//131-136
$frame axattc1 axattc2 axattc3 axattc4 axattc5 axattc6
//137-142
$frame axattd1 axattd2 axattd3 axattd4 axattd5 axattd6


void()	axe_stand1	=[	$axstnd1,	axe_stand2	] {ai_stand();};
void()	axe_stand2	=[	$axstnd2,	axe_stand3	] {ai_stand();};
void()	axe_stand3	=[	$axstnd3,	axe_stand4	] {ai_stand();};
void()	axe_stand4	=[	$axstnd4,	axe_stand5	] {ai_stand();};
void()	axe_stand5	=[	$axstnd5,	axe_stand6	] {ai_stand();};
void()	axe_stand6	=[	$axstnd6,	axe_stand7	] {ai_stand();};
void()	axe_stand7	=[	$axstnd7,	axe_stand8	] {ai_stand();};
void()	axe_stand8	=[	$axstnd8,	axe_stand9	] {ai_stand();};
void()	axe_stand9	=[	$axstnd9,	axe_stand10	] {ai_stand();};
void()	axe_stand10	=[	$axstnd10,	axe_stand11	] {ai_stand();};
void()	axe_stand11	=[	$axstnd11,	axe_stand12	] {ai_stand();};
void()	axe_stand12	=[	$axstnd12,	axe_stand1	] {ai_stand();};

void()	axe_run1	=[	$axrun1,		axe_run2	] {
	self.state = 1; // running
if (random() < 0.2)
	sound (self, CHAN_VOICE, "knight/idle.wav", 1,  ATTN_IDLE);
ai_run(25);};
void()	axe_run2	=[	$axrun2,		axe_run3	] {ai_run(18);};
void()	axe_run3	=[	$axrun3,		axe_run4	] {ai_run(12);};
void()	axe_run4	=[	$axrun4,		axe_run5	] {ai_run(25);};
void()	axe_run5	=[	$axrun5,		axe_run6	] {ai_run(18);};
void()	axe_run6	=[	$axrun6,		axe_run1	] {ai_run(12);};


void()    axe_walk1    =[    $rockrun1,        axe_walk2    ] {self.nextthink = time + 0.15;
if (random() < 0.2)
    sound (self, CHAN_VOICE, "soldier/idle.wav", 1,  ATTN_IDLE);
ai_walk(12);};
void()    axe_walk2    =[    $rockrun2,        axe_walk3    ] {self.nextthink = time + 0.15;ai_walk(9);};
void()    axe_walk3    =[    $rockrun3,        axe_walk4    ] {self.nextthink = time + 0.15;ai_walk(4);};
void()    axe_walk4    =[    $rockrun4,        axe_walk5    ] {self.nextthink = time + 0.15;ai_walk(12);};
void()    axe_walk5    =[    $rockrun5,        axe_walk6    ] {self.nextthink = time + 0.15;ai_walk(9);};
void()    axe_walk6    =[    $rockrun6,        axe_walk1    ] {self.nextthink = time + 0.15;ai_walk(4);};

//===========================================================================

void( vector dir ) axe_chop =
{
	local vector	delta, toss;
	local float 	ldmg;

	if (!self.enemy)
		return;		// removed before stroke
		
	ai_charge_side();
	
	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 60)
		return;
	if (!CanDamage (self.enemy, self))
		return;
	ldmg = (random() + random() + random()) * 2;
	T_Damage(self.enemy, self, self, ldmg, DMGTYPE_MELEE);

	toss = v_forward * dir_x + v_right * dir_y + v_up * dir_z;
	self.enemy.velocity = self.enemy.velocity + toss;
}


void()	axe_runatka1	=[	$axatt1,		axe_runatka2	] {
if (random() > 0.5)
	sound (self, CHAN_WEAPON, "knight/sword2.wav", 1, ATTN_NORM);
else
	sound (self, CHAN_WEAPON, "knight/sword1.wav", 1, ATTN_NORM);
ai_charge(30);
};
void()	axe_runatka2	=[	$axatt2,		axe_runatka3	] {ai_charge(20);};
void()	axe_runatka3	=[	$axatt3,		axe_runatka4	] {ai_charge(10); axe_chop('0 0 0');};
void()	axe_runatka4	=[	$axatt4,		axe_runatka5	] {axe_chop('50 -20 10');};
void()	axe_runatka5	=[	$axatt5,		axe_runatka6	] {axe_chop('100 -40 10');};
void()	axe_runatka6	=[	$axatt6,		axe_run1	] {ai_charge_side();};

void()	axe_runatkb1	=[	$axattb1,		axe_runatkb2	] {
if (random() > 0.5)
	sound (self, CHAN_WEAPON, "knight/sword2.wav", 1, ATTN_NORM);
else
	sound (self, CHAN_WEAPON, "knight/sword1.wav", 1, ATTN_NORM);
ai_charge(30);
};
void()	axe_runatkb2	=[	$axattb2,		axe_runatkb3	] {ai_charge(20);};
void()	axe_runatkb3	=[	$axattb3,		axe_runatkb4	] {ai_charge(10); axe_chop('0 0 0');};
void()	axe_runatkb4	=[	$axattb4,		axe_runatkb5	] {axe_chop('40 75 10');};
void()	axe_runatkb5	=[	$axattb5,		axe_runatkb6	] {axe_chop('80 150 20');};
void()	axe_runatkb6	=[	$axattb6,		axe_run1	] {ai_charge_side();};

void()	axe_runatkc1	=[	$axattc1,		axe_runatkc2	] {
if (random() > 0.5)
	sound (self, CHAN_WEAPON, "knight/sword2.wav", 1, ATTN_NORM);
else
	sound (self, CHAN_WEAPON, "knight/sword1.wav", 1, ATTN_NORM);
ai_charge(30);
};
void()	axe_runatkc2	=[	$axattc2,		axe_runatkc3	] {ai_charge(20);};
void()	axe_runatkc3	=[	$axattc3,		axe_runatkc4	] {ai_charge(10); axe_chop('0 0 0');};
void()	axe_runatkc4	=[	$axattc4,		axe_runatkc5	] {axe_chop('60 0 10');};
void()	axe_runatkc5	=[	$axattc5,		axe_runatkc6	] {axe_chop('120 0 20');};
void()	axe_runatkc6	=[	$axattc6,		axe_run1	] {ai_charge_side();};

void()	axe_runatkd1	=[	$axattd1,		axe_runatkd2	] {
if (random() > 0.5)
	sound (self, CHAN_WEAPON, "knight/sword2.wav", 1, ATTN_NORM);
else
	sound (self, CHAN_WEAPON, "knight/sword1.wav", 1, ATTN_NORM);
ai_charge(30);
};
void()	axe_runatkd2	=[	$axattd2,		axe_runatkd3	] {ai_charge(20);};
void()	axe_runatkd3	=[	$axattd3,		axe_runatkd4	] {ai_charge(10); axe_chop('0 0 0');};
void()	axe_runatkd4	=[	$axattd4,		axe_runatkd5	] {axe_chop('30 -75 100');};
void()	axe_runatkd5	=[	$axattd5,		axe_runatkd6	] {axe_chop('60 -150 200');};
void()	axe_runatkd6	=[	$axattd6,		axe_run1	] {ai_charge_side();};

void()	axe_atk =
{
	local float r;
	if (self.pain_finished > time)
		return;
	self.state = 2; //attacking
	r = random();
	
	if (r < 0.25)
		axe_runatka1();
	else	if (r < 0.5)
		axe_runatkb1();
	else	if (r < 0.75)
		axe_runatkc1();
	else
		axe_runatkd1();
};


//===========================================================================


void()	axe_pain1	=[	$axpain1,	axe_pain2	] {};
void()	axe_pain2	=[	$axpain2,	axe_pain3	] {ai_painforward(-1);};
void()	axe_pain3	=[	$axpain3,	axe_pain4	] {ai_painforward(-2);};
void()	axe_pain4	=[	$axpain4,	axe_pain5	] {};
void()	axe_pain5	=[	$axpain5,	axe_pain6	] {};
void()	axe_pain6	=[	$axpain6,	axe_run1	] {};

void(entity attacker, float damage)	axe_pain =
{
	if (self.health < self.max_health * 0.05)	self.skin = 3;
	else if (self.health < self.max_health * 0.4)	self.skin = 2;
	else if (self.health < self.max_health * 0.8)	self.skin = 1;

	if (self.pain_finished > time)
		return;

	sound (self, CHAN_VOICE, "knight/khurt.wav", 1, ATTN_NORM);
	self.state = 3; // pain state
	axe_pain1 ();
	self.pain_finished = time + 0.75;
};

//===========================================================================



void()	axe_die1	=[	$axdeth1,	axe_die2	] {};
void()	axe_die2	=[	$axdeth2,	axe_die3	] {};
void()	axe_die3	=[	$axdeth3,	axe_die4	] 
{self.solid = SOLID_TRIGGER; setorigin(self, self.origin);};
void()	axe_die4	=[	$axdeth4,	axe_die5	] {};
void()	axe_die5	=[	$axdeth5,	axe_die6	] {};
void()	axe_die6	=[	$axdeth6,	axe_die7	] {};
void()	axe_die7	=[	$axdeth7,	axe_die8	] {};
void()	axe_die8	=[	$axdeth8,	axe_die9	] {};
void()	axe_die9	=[	$axdeth9,	axe_die9] {self.think = SUB_MakeNotSolid; self.nextthink = time + 5;};


void()	axe_diea1	=[	$deatha1,	axe_diea2	] {};
void()	axe_diea2	=[	$deatha2,	axe_diea3	] {};
void()	axe_diea3	=[	$deatha3,	axe_diea4	] 
{self.solid = SOLID_TRIGGER; setorigin(self, self.origin);};
void()	axe_diea4	=[	$deatha4,	axe_diea5	] {};
void()	axe_diea5	=[	$deatha5,	axe_diea6	] {};
void()	axe_diea6	=[	$deatha6,	axe_diea7	] {};
void()	axe_diea7	=[	$deatha7,	axe_diea8	] {};
void()	axe_diea8	=[	$deatha8,	axe_diea9	] {};
void()	axe_diea9	=[	$deatha9,	axe_diea10	] {};
void()	axe_diea10	=[	$deatha10,	axe_diea11	] {};
void()	axe_diea11	=[	$deatha11,	axe_diea11] {self.think = SUB_MakeNotSolid; self.nextthink = time + 5;};

void()	axe_diec1	=[	$deathc1,	axe_diec2	] {self.nextthink = time + 0.075; ai_painforward(12);};
void()	axe_diec2	=[	$deathc2,	axe_diec3	] {self.nextthink = time + 0.075; ai_painforward(12);};
void()	axe_diec3	=[	$deathc3,	axe_diec4	] {self.nextthink = time + 0.075; ai_painforward(9); self.solid = SOLID_TRIGGER; setorigin(self, self.origin);};
void()	axe_diec4	=[	$deathc4,	axe_diec5	] {self.nextthink = time + 0.075; ai_painforward(9);};
void()	axe_diec5	=[	$deathc5,	axe_diec6	] {self.nextthink = time + 0.075; ai_painforward(8);};
void()	axe_diec6	=[	$deathc6,	axe_diec7	] {self.nextthink = time + 0.1; ai_painforward(8);};
void()	axe_diec7	=[	$deathc7,	axe_diec8	] {self.nextthink = time + 0.1; ai_painforward(6);};
void()	axe_diec8	=[	$deathc8,	axe_diec9	] {self.nextthink = time + 0.1; ai_painforward(6);};
void()	axe_diec9	=[	$deathc9,	axe_diec10	] {self.nextthink = time + 0.1; ai_painforward(5);};
void()	axe_diec10	=[	$deathc10,	axe_diec11	] {self.nextthink = time + 0.075; };
void()	axe_diec11	=[	$deathc11,	axe_diec12	] {self.nextthink = time + 0.075; };
void()	axe_diec12	=[	$deathc12,	axe_diec13	] {self.nextthink = time + 0.075; };
void()	axe_diec13	=[	$deathc13,	axe_diec14	] {self.nextthink = time + 0.075; };
void()	axe_diec14	=[	$deathc14,	axe_diec15	] {self.nextthink = time + 0.075; };
void()	axe_diec15	=[	$deathc15,	axe_diec15] {self.nextthink = time + 0.075; self.think = SUB_MakeNotSolid; self.nextthink = time + 5;};


void()	axe_died1	=[	$deathd1,	axe_died2	] {};
void()	axe_died2	=[	$deathd2,	axe_died3	] {};
void()	axe_died3	=[	$deathd3,	axe_died4	] 
{self.solid = SOLID_TRIGGER; setorigin(self, self.origin);};
void()	axe_died4	=[	$deathd4,	axe_died5	] {};
void()	axe_died5	=[	$deathd5,	axe_died6	] {};
void()	axe_died6	=[	$deathd6,	axe_died7	] {};
void()	axe_died7	=[	$deathd7,	axe_died8	] {};
void()	axe_died8	=[	$deathd8,	axe_died9	] {};
void()	axe_died9	=[	$deathd9,	axe_died9] {self.think = SUB_MakeNotSolid; self.nextthink = time + 5;};


void()	axe_diee1	=[	$deathe1,	axe_diee2	] {};
void()	axe_diee2	=[	$deathe2,	axe_diee3	] {};
void()	axe_diee3	=[	$deathe3,	axe_diee4	] 
{self.solid = SOLID_TRIGGER; setorigin(self, self.origin);};
void()	axe_diee4	=[	$deathe4,	axe_diee5	] {};
void()	axe_diee5	=[	$deathe5,	axe_diee6	] {};
void()	axe_diee6	=[	$deathe6,	axe_diee7	] {};
void()	axe_diee7	=[	$deathe7,	axe_diee8	] {};
void()	axe_diee8	=[	$deathe8,	axe_diee9	] {};
void()	axe_diee9	=[	$deathe9,	axe_diee9] {self.think = SUB_MakeNotSolid; self.nextthink = time + 5;};


void() axe_die =
{
	//axe_diec1();
	//return;

	if (self.health < -30)
	{
		self.skin = 0;
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_guard.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		return;
	}

	self.skin = 3;
	float rnd = random();

	sound (self, CHAN_VOICE, "knight/kdeath.wav", 1, ATTN_NORM);
	
	if ((self.state == 2) && self.health < -15)
		axe_diec1();
	else if (rnd < 0.25)
		axe_die1 ();
	else if (rnd < 0.50)
		axe_diea1 ();
	else if (rnd < 0.75)
		axe_died1 ();
	else
		axe_diee1 ();
};

void() axe_sight = {
	sound (self, CHAN_VOICE, "knight/ksight.wav", 1, ATTN_NORM);
};

/*QUAKED monster_axegrunt (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
void(entity e) monster_axegrunt_start =
{
	local entity oself;

	oself = self;
	self = e;

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/axegrunt.mdl");

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize(self, self.cmins, self.cmaxs);

	self.health = 75;
	if (self.obituary == "") self.obituary = "got the chop from an Axe Grunt";

	self.th_stand = axe_stand1;
	self.th_walk = axe_walk1;
	self.th_run = axe_run1;
	self.th_melee = axe_atk;
	self.th_pain = axe_pain;
	self.th_die = axe_die;
	self.th_sight = axe_sight;
	
	walkmonster_start ();

	self = oself;
};

void() monster_axegrunt_spawner = {
	monster_spawner(monster_axegrunt_start);
};

void() monster_axegrunt =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/axegrunt.mdl");
	precache_model ("progs/h_guard.mdl");

	precache_sound ("knight/kdeath.wav");
	precache_sound ("knight/khurt.wav");
	precache_sound ("knight/ksight.wav");
	precache_sound ("knight/sword1.wav");
	precache_sound ("knight/sword2.wav");
	precache_sound ("knight/idle.wav");
	precache_sound ("soldier/idle.wav");

	self.cmins = '-16 -16 -24';
	self.cmaxs = '16 16 40';
	
	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize(self, self.cmins, self.cmaxs);
	
	if (self.spawnflags & MONSTER_SPAWNER) {
		self.use = monster_axegrunt_spawner;
		monster_spawner_updatecounter();
	}
	else {
		monster_axegrunt_start(self);
	}
}