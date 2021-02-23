 /*=============================================================================
 
monster_centurion
code by john fitzgibbons

==============================================================================*/

$cd id1/models/enforcer
$origin 0 -6 24
$base base		
$skin skin

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8

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

//============================================================================

float CENT_DAMAGE = 9;

void() centurion_missle_touch =
{
//	local float rand;
	
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchblood (CENT_DAMAGE);
		T_Damage (other, self, self.owner, CENT_DAMAGE);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_SUPERSPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}

	remove(self);
};


void(vector org, vector vec) centurion_launch_missle =
{
	sound (self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);

	vec = normalize(vec);
	
	newmis = spawn();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	setmodel (newmis, "progs/c_spike.mdl");
	setsize (newmis, '0 0 0', '0 0 0');		

	setorigin (newmis, org);

	newmis.velocity = vec * 1000;
	newmis.angles = vectoangles(newmis.velocity);

	newmis.nextthink = time + 5;
	newmis.think = SUB_Remove;
	newmis.touch = centurion_missle_touch;
	
	newmis.classname = "spike";
};


void() centurion_fire =
{
	local vector org;

	self.effects = self.effects | EF_MUZZLEFLASH;
	makevectors (self.angles);
	
	org = self.origin + v_forward * 34 + v_right * 8.5 + '0 0 24'; //16 for enforcer, added 8 more for platform

	centurion_launch_missle(org, self.enemy.origin - self.origin);
};

//============================================================================

void() cent_ai_stand = {
	ai_stand();
};

void()	cent_stand1	=[	$stand1,	cent_stand2	] {cent_ai_stand();};
void()	cent_stand2	=[	$stand2,	cent_stand3	] {cent_ai_stand();};
void()	cent_stand3	=[	$stand3,	cent_stand4	] {cent_ai_stand();};
void()	cent_stand4	=[	$stand4,	cent_stand5	] {cent_ai_stand();};
void()	cent_stand5	=[	$stand5,	cent_stand6	] {cent_ai_stand();};
void()	cent_stand6	=[	$stand6,	cent_stand7	] {cent_ai_stand();};
void()	cent_stand7	=[	$stand7,	cent_stand8	] {cent_ai_stand();};
void()	cent_stand8	=[	$stand8,	cent_stand1	] {cent_ai_stand();};

//randomly choose a start frame so multiple guys don't bob in sync
void() cent_stand_random = {
	local float r;
	r = random();
	if (r < 0.125) {cent_stand1(); return;}
	if (r < 0.250) {cent_stand2(); return;}
	if (r < 0.375) {cent_stand3(); return;}
	if (r < 0.500) {cent_stand4(); return;}
	if (r < 0.625) {cent_stand5(); return;}
	if (r < 0.750) {cent_stand6(); return;}
	if (r < 0.875) {cent_stand7(); return;}
	cent_stand8();
};

//============================================================================

void() cent_ai_walk = {
	ai_walk(4);
};

void()	cent_walk1	=[	$stand1 ,	cent_walk2	] {cent_ai_walk();
if (random() < 0.1)
	sound (self, CHAN_VOICE, "enforcer/idle1.wav", 1, ATTN_IDLE);
};
void()	cent_walk2	=[	$stand2 ,	cent_walk3	] {cent_ai_walk();};
void()	cent_walk3	=[	$stand3 ,	cent_walk4	] {cent_ai_walk();};
void()	cent_walk4	=[	$stand4 ,	cent_walk5	] {cent_ai_walk();};
void()	cent_walk5	=[	$stand5 ,	cent_walk6	] {cent_ai_walk();};
void()	cent_walk6	=[	$stand6 ,	cent_walk7	] {cent_ai_walk();};
void()	cent_walk7	=[	$stand7 ,	cent_walk8	] {cent_ai_walk();};
void()	cent_walk8	=[	$stand8 ,	cent_walk1	] {cent_ai_walk();};

//============================================================================

float CENT_RUNSPEED = 8;
float CENT_RANGEMIN = 200; //minimum ideal range from enemy
float CENT_RANGEMAX = 300; //maximum ideal range from enemy
float CENT_HEIGHTMIN = -100; //minimum ideal altitude, relative to enemy
float CENT_HEIGHTMAX = 100; //maximum ideal altitude, relative to enemy
float CENT_FLOORHEIGHTMIN = 50; //minimum height to stay above ground directly below

//
// Centurion combat movement -- since the platform can move regardless of 
// the guy's animation frame, this is called when running, attacking, and
// even when in pain
//
void() cent_combatmove = {

	local vector	spot1, spot2, spot3;
	local float		r, a, dir, v;
	
	if (self.enemy == world)
		return;
	
	//check relative enemy position
	spot1 = self.origin + self.view_ofs;
	spot2 = self.enemy.origin + self.enemy.view_ofs;
	r = vlen (spot1 - spot2);
	a = spot1_z - spot2_z;
	
	//check ground clearance
	spot3 = self.origin;
	spot3_z = spot3_z - CENT_FLOORHEIGHTMIN;
	traceline (self.origin, spot3, TRUE, self);
	
	// Determine vertical direction to move -- but don't change too often
	if (a < CENT_HEIGHTMIN || trace_fraction < 1.0)
	{
		//too low, stop moving down
		if (self.height < 0)
			self.height = 0;
		else if (self.height < 1)
			if (random()<0.2)
				self.height = 1;
	}
	else if (a > CENT_HEIGHTMAX)
	{
		//too high, stop moving up
		if (self.height > 0)
			self.height = 0;
		else if (self.height > -1)
			if (random()<0.2)
				self.height = -1;
	}
	else
	{
		//in the sweet spot, occasionally change z-direction
		v = random();
		
		if (v<0.05 && self.height > -1)
			self.height = self.height - 1;
			
		if (v>0.95 && self.height < 1)
			self.height = self.height + 1;
	}
	
	// Temporarily change enemy's origin to control vertical movement
	self.enemy.origin_z = self.enemy.origin_z + 1000 * self.height;
	
	//TODO: try not to get too close to other centurions
	// using findradius, then what?
	
	// Determine horizontal direction to move
	if (r > CENT_RANGEMAX)
	{ 
		// too far, get closer
		dir = self.ideal_yaw;
		
		//pitch forwards
		self.angles_x = -5;
		self.angles_z = 0;
	}
	else if (r < CENT_RANGEMIN)
	{ 
		// too close, back away
		dir = (self.ideal_yaw - 180);
		
		//pitch back
		self.angles_x = 5;
		self.angles_z = 0;
	}
	else
	{
		// range is good, strafe around enemy
		if (self.lefty)
		{
			dir = (self.ideal_yaw - 90);
			
			//roll left
			self.angles_x = 0;
			self.angles_z = 5;
		}
		else
		{
			dir = (self.ideal_yaw + 90);
			
			//roll right
			self.angles_x = 0;
			self.angles_z = -5;
		}
	}
	
	// Use movetogoal when walkmove fails, because it is the only way to get around obstacles
	if (!walkmove (dir, CENT_RUNSPEED))
		movetogoal(CENT_RUNSPEED);
		
	// Restore enemy's correct origin
	self.enemy.origin_z = self.enemy.origin_z - 1000 * self.height;
};

void() cent_ai_run = {
	ai_run(0);
	cent_combatmove();
};

void()	cent_run1	=[	$stand1  ,	cent_run2	] {cent_ai_run();
	if (random() < 0.2)
		sound (self, CHAN_VOICE, "enforcer/idle1.wav", 1, ATTN_IDLE);
	if (random()<0.6)
		self.lefty = !self.lefty;
};
void()	cent_run2	=[	$stand2  ,	cent_run3	] {cent_ai_run();};
void()	cent_run3	=[	$stand3  ,	cent_run4	] {cent_ai_run();};
void()	cent_run4	=[	$stand4  ,	cent_run5	] {cent_ai_run();};
void()	cent_run5	=[	$stand5  ,	cent_run6	] {cent_ai_run();};
void()	cent_run6	=[	$stand6  ,	cent_run7	] {cent_ai_run();};
void()	cent_run7	=[	$stand7  ,	cent_run1	] {cent_ai_run();};

void() cent_atk11;
void() abort_if_blocked = {
	if (!clean_shot (self.enemy)) self.think = cent_atk11; //abort if shot is blocked by monster or wall
};

void() cent_ai_face = {
	ai_face();
	cent_combatmove();
}

void()	cent_atk1	=[	$attack1,	cent_atk2	] {cent_ai_face();};
void()	cent_atk2	=[	$attack2,	cent_atk3	] {cent_ai_face();};
void()	cent_atk3	=[	$attack3,	cent_atk4	] {cent_ai_face();};
void()	cent_atk4	=[	$attack4,	cent_atk5	] {cent_ai_face();};
void()	cent_atk5	=[	$attack5,	cent_atk6	] {cent_ai_face();abort_if_blocked();};
void()	cent_atk6	=[	$attack6,	cent_atk7	] {cent_ai_face();centurion_fire();};
void()	cent_atk7	=[	$attack6,	cent_atk8	] {cent_ai_face();centurion_fire();abort_if_blocked();};
void()	cent_atk8	=[	$attack6,	cent_atk9	] {cent_ai_face();centurion_fire();};
void()	cent_atk9	=[	$attack6,	cent_atk10	] {cent_ai_face();centurion_fire();abort_if_blocked();};
void()	cent_atk10	=[	$attack6,	cent_atk11	] {cent_ai_face();centurion_fire();};
void()	cent_atk11	=[	$attack7,	cent_atk12	] {cent_ai_face();};
void()	cent_atk12	=[	$attack8,	cent_atk13	] {cent_ai_face();};
void()	cent_atk13	=[	$attack9,	cent_atk14	] {cent_ai_face();};
void()	cent_atk14	=[	$attack10,	cent_run1	] {cent_ai_face();SUB_CheckRefire (cent_atk1);};

//============================================================================

void() cent_ai_pain = {
	cent_combatmove();
}

void()	cent_paina1	=[	$paina1,	cent_paina2	] {cent_ai_pain();};
void()	cent_paina2	=[	$paina2,	cent_paina3	] {cent_ai_pain();};
void()	cent_paina3	=[	$paina3,	cent_paina4	] {cent_ai_pain();};
void()	cent_paina4	=[	$paina4,	cent_run1	] {cent_ai_pain();};

void()	cent_painb1	=[	$painb1,	cent_painb2	] {cent_ai_pain();};
void()	cent_painb2	=[	$painb2,	cent_painb3	] {cent_ai_pain();};
void()	cent_painb3	=[	$painb3,	cent_painb4	] {cent_ai_pain();};
void()	cent_painb4	=[	$painb4,	cent_painb5	] {cent_ai_pain();};
void()	cent_painb5	=[	$painb5,	cent_run1	] {cent_ai_pain();};

void()	cent_painc1	=[	$painc1,	cent_painc2	] {cent_ai_pain();};
void()	cent_painc2	=[	$painc2,	cent_painc3	] {cent_ai_pain();};
void()	cent_painc3	=[	$painc3,	cent_painc4	] {cent_ai_pain();};
void()	cent_painc4	=[	$painc4,	cent_painc5	] {cent_ai_pain();};
void()	cent_painc5	=[	$painc5,	cent_painc6	] {cent_ai_pain();};
void()	cent_painc6	=[	$painc6,	cent_painc7	] {cent_ai_pain();};
void()	cent_painc7	=[	$painc7,	cent_painc8	] {cent_ai_pain();};
void()	cent_painc8	=[	$painc8,	cent_run1	] {cent_ai_pain();};

void(entity attacker, float damage)	cent_pain =
{
	local float r;

	if (self.pain_finished > time)
		return;
		
	if (random()*150 > damage)
		return;		// didn't flinch

	r = random ();
	
	if (r < 0.5)
		sound (self, CHAN_VOICE, "enforcer/pain1.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_VOICE, "enforcer/pain2.wav", 1, ATTN_NORM);

	if (r < 0.3)
	{
		self.pain_finished = time + 1;
		cent_paina1 ();
	}
	else if (r < 0.6)
	{
		self.pain_finished = time + 1;
		cent_painb1 ();
	}
	else
	{
		self.pain_finished = time + 1;
		cent_painc1 ();
	}
};

//============================================================================

void() cent_death = {
	self.angles_x = 0;
	self.angles_z = 0;
	
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	self.solid = SOLID_NOT;
	
	self.ammo_nails = 5;
	DropBackpack();
};

void()	cent_die1	=[	$death1,	cent_die2	] {cent_death();};
void()	cent_die2	=[	$death2,	cent_die3	] {};
void()	cent_die3	=[	$death3,	cent_die4	] {};
void()	cent_die4	=[	$death4,	cent_die5	] {};
void()	cent_die5	=[	$death5,	cent_die6	] {};
void()	cent_die6	=[	$death6,	cent_die7	] {};
void()	cent_die7	=[	$death7,	cent_die8	] {};
void()	cent_die8	=[	$death8,	cent_die9	] {};
void()	cent_die9	=[	$death9,	cent_die10	] {};
void()	cent_die10	=[	$death10,	cent_die11	] {};
void()	cent_die11	=[	$death11,	cent_die12	] {};
void()	cent_die12	=[	$death12,	cent_die13	] {};
void()	cent_die13	=[	$death13,	cent_die14	] {};
void()	cent_die14	=[	$death14,	cent_die14	] {};

void()	cent_fdie1	=[	$fdeath1,	cent_fdie2	] {cent_death();};
void()	cent_fdie2	=[	$fdeath2,	cent_fdie3	] {};
void()	cent_fdie3	=[	$fdeath3,	cent_fdie4	] {};
void()	cent_fdie4	=[	$fdeath4,	cent_fdie5	] {};
void()	cent_fdie5	=[	$fdeath5,	cent_fdie6	] {};
void()	cent_fdie6	=[	$fdeath6,	cent_fdie7	] {};
void()	cent_fdie7	=[	$fdeath7,	cent_fdie8	] {};
void()	cent_fdie8	=[	$fdeath8,	cent_fdie9	] {};
void()	cent_fdie9	=[	$fdeath9,	cent_fdie10	] {};
void()	cent_fdie10	=[	$fdeath10,	cent_fdie11	] {};
void()	cent_fdie11	=[	$fdeath11,	cent_fdie11	] {};


void() cent_die =
{
// check for gib
	if (self.health < -35)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_cent.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		return;
	}

// regular death
	sound (self, CHAN_VOICE, "enforcer/death1.wav", 1, ATTN_NORM);
	if (random() > 0.5)
		cent_die1 ();
	else
		cent_fdie1 ();
};


/*QUAKED monster_centurion (1 0 0) (-32 -32 -24) (32 32 64) AMBUSH
Centurion, 150 health points.

AMBUSH: monster will only wake up on really seeing the player, not another monster getting angry.
*/

void() monster_centurion =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	
	//character assets
	precache_model2 ("progs/cent.mdl");
	precache_model2 ("progs/h_cent.mdl");
	
	precache_sound2 ("enforcer/death1.wav");
	precache_sound2 ("enforcer/idle1.wav");
	precache_sound2 ("enforcer/pain1.wav");
	precache_sound2 ("enforcer/pain2.wav");
	precache_sound2 ("enforcer/sight1.wav");
	precache_sound2 ("enforcer/sight2.wav");
	precache_sound2 ("enforcer/sight3.wav");
	precache_sound2 ("enforcer/sight4.wav");
	
	//attack assets
	precache_model2 ("progs/c_spike.mdl");
	precache_sound2 ("weapons/rocket1i.wav");
	
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/cent.mdl");

	setsize (self, '-22 -22 -24', '22 22 48');
	self.health = 150;

	self.th_stand = cent_stand_random;
	self.th_walk = cent_walk1;
	self.th_run = cent_run1;
	self.th_pain = cent_pain;
	self.th_die = cent_die;
	self.th_missile = cent_atk1;
	
	if (!self.yaw_speed)
		self.yaw_speed = 20; //for some reason flymonsters default to 10 instead of 20

	flymonster_start ();
};