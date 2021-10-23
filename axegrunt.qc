/*
==============================================================================

AXE GRUNT
Suitable replacement for knight in base maps.  Grunts a lot.

==============================================================================
*/

$cd id1/models/player_4
$origin 0 -6 24
$base base		
$skin skin

//
// running
//
$frame axrun1 axrun2 axrun3 axrun4 axrun5 axrun6

$frame rockrun1 rockrun2 rockrun3 rockrun4 rockrun5 rockrun6

// walking is just slowed down running - Greenwood's "mall walker" fix

//
// standing
//
$frame stand1 stand2 stand3 stand4 stand5

$frame axstnd1 axstnd2 axstnd3 axstnd4 axstnd5 axstnd6
$frame axstnd7 axstnd8 axstnd9 axstnd10 axstnd11 axstnd12


//
// pain
//
$frame axpain1 axpain2 axpain3 axpain4 axpain5 axpain6

$frame pain1 pain2 pain3 pain4 pain5 pain6


//
// death
//

$frame axdeth1 axdeth2 axdeth3 axdeth4 axdeth5 axdeth6
$frame axdeth7 axdeth8 axdeth9

$frame deatha1 deatha2 deatha3 deatha4 deatha5 deatha6 deatha7 deatha8
$frame deatha9 deatha10 deatha11

$frame deathb1 deathb2 deathb3 deathb4 deathb5 deathb6 deathb7 deathb8
$frame deathb9

$frame deathc1 deathc2 deathc3 deathc4 deathc5 deathc6 deathc7 deathc8
$frame deathc9 deathc10 deathc11 deathc12 deathc13 deathc14 deathc15

$frame deathd1 deathd2 deathd3 deathd4 deathd5 deathd6 deathd7
$frame deathd8 deathd9

$frame deathe1 deathe2 deathe3 deathe4 deathe5 deathe6 deathe7
$frame deathe8 deathe9

//
// attacks
//
$frame nailatt1 nailatt2

$frame light1 light2

$frame rockatt1 rockatt2 rockatt3 rockatt4 rockatt5 rockatt6

$frame shotatt1 shotatt2 shotatt3 shotatt4 shotatt5 shotatt6

$frame axatt1 axatt2 axatt3 axatt4 axatt5 axatt6

$frame axattb1 axattb2 axattb3 axattb4 axattb5 axattb6

$frame axattc1 axattc2 axattc3 axattc4 axattc5 axattc6

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
if (random() < 0.2)
	sound (self, CHAN_VOICE, "knight/idle.wav", 1,  ATTN_IDLE);
ai_run(25);};
void()	axe_run2	=[	$axrun2,		axe_run3	] {ai_run(18);};
void()	axe_run3	=[	$axrun3,		axe_run4	] {ai_run(12);};
void()	axe_run4	=[	$axrun4,		axe_run5	] {ai_run(25);};
void()	axe_run5	=[	$axrun5,		axe_run6	] {ai_run(18);};
void()	axe_run6	=[	$axrun6,		axe_run1	] {ai_run(12);};

void()    axe_walk1    =[    $axrun1,        axe_walk2    ] {
if (random() < 0.2)
    sound (self, CHAN_VOICE, "soldier/idle.wav", 1,  ATTN_IDLE);
ai_walk(8);};
void()    axe_walk2    =[    $axrun2,        axe_walk3    ] {ai_walk(6);};
void()    axe_walk3    =[    $axrun3,        axe_walk4    ] {ai_walk(3);};
void()    axe_walk4    =[    $axrun4,        axe_walk5    ] {ai_walk(8);};
void()    axe_walk5    =[    $axrun5,        axe_walk6    ] {ai_walk(6);};
void()    axe_walk6    =[    $axrun6,        axe_walk1    ] {ai_walk(3);};

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
	T_Damage (self.enemy, self, self, ldmg);

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


void()	axe_pain1	=[	$axpain1,	axe_pain2	] {ai_painforward(0);};
void()	axe_pain2	=[	$axpain2,	axe_pain3	] {ai_painforward(-1);};
void()	axe_pain3	=[	$axpain3,	axe_pain4	] {ai_painforward(-2);};
void()	axe_pain4	=[	$axpain4,	axe_pain5	] {};
void()	axe_pain5	=[	$axpain5,	axe_pain6	] {};
void()	axe_pain6	=[	$axpain6,	axe_run1	] {};

void(entity attacker, float damage)	axe_pain =
{
	if (self.pain_finished > time)
		return;

	sound (self, CHAN_VOICE, "knight/khurt.wav", 1, ATTN_NORM);

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




void() axe_die =
{
// check for gib
	if (self.health < -30)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_guard.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		return;
	}
// regular death
	sound (self, CHAN_VOICE, "knight/kdeath.wav", 1, ATTN_NORM);
	axe_die1 ();
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
	else setsize (self, '-16 -16 -24', '16 16 40');

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
	
	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize (self, '-16 -16 -24', '16 16 40');
	
	if (self.spawnflags & MONSTER_SPAWNER) {
		self.use = monster_axegrunt_spawner;
		monster_spawner_updatecounter();
	}
	else {
		monster_axegrunt_start(self);
	}
}