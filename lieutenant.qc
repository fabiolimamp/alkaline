/*
==============================================================================

BOSS ENFORCER (original mod from "The Lieutenant," fixed aim by khreathor)

==============================================================================
*/

$cd /raid/quake/id1/models/enforcer
$origin 0 -6 24
$base base		
$skin skin

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9 walk10
$frame walk11 walk12 walk13 walk14 walk15 walk16

$frame run1 run2 run3 run4 run5 run6 run7 run8

$frame attack1 attack2 attack3 attack4 attack5 attack6
$frame attack7 attack8

$frame fdeath1 fdeath2 fdeath3 fdeath4 fdeath5 fdeath6 fdeath7 fdeath8
$frame fdeath9 fdeath10 fdeath11

$frame paina1 paina2 paina3 paina4


void() super_enforcer_fire =
{
	vector dir, liut_ofs;

	ai_face();
	local vector org;
	makevectors (self.angles);
	
	org = self.origin + v_forward * 30 + v_right * 8.5 + '0 0 16';
if (skill == 0)
    dir = self.enemy.origin - org;
else if (skill == 1)
	{
	liut_ofs_x = (self.enemy.velocity_x * 0.1);
	liut_ofs_y = (self.enemy.velocity_y * 0.1);
	liut_ofs_z = (self.enemy.velocity_z * 0.1 * -1);
    dir = (self.enemy.origin + liut_ofs) - org;
   	}
else if (skill == 2)
	{
	liut_ofs_x = (self.enemy.velocity_x * 0.2);
	liut_ofs_y = (self.enemy.velocity_y * 0.2);
	liut_ofs_z = (self.enemy.velocity_z * 0.2 * -1);	
   dir = (self.enemy.origin + liut_ofs) - org;
   	}
else
	{
	liut_ofs_x = (self.enemy.velocity_x * 0.3);
	liut_ofs_y = (self.enemy.velocity_y * 0.3);
	liut_ofs_z = (self.enemy.velocity_z * 0.3 * -1);
   dir = (self.enemy.origin + liut_ofs) - org;
   	}
	dir = normalize(dir);
	launch_spike (org, dir);
	//launch_spike (org, self.enemy.origin - self.origin);
	// setmodel(newmis, "progs/s_spike.mdl");
	newmis.touch = superspike_touch;
	newmis.velocity = newmis.velocity * 0.8;

	sound (self, self.cnt, "weapons/spike2.wav", 1, ATTN_NORM);
	self.cnt++;
	if (self.cnt >= 7)
		self.cnt = 0;
};

//============================================================================

void()	lth_stand1	=[	$stand1,	lth_stand2	] {ai_stand();};
void()	lth_stand2	=[	$stand2,	lth_stand3	] {ai_stand();};
void()	lth_stand3	=[	$stand3,	lth_stand4	] {ai_stand();};
void()	lth_stand4	=[	$stand4,	lth_stand5	] {ai_stand();};
void()	lth_stand5	=[	$stand5,	lth_stand6	] {ai_stand();};
void()	lth_stand6	=[	$stand6,	lth_stand7	] {ai_stand();};
void()	lth_stand7	=[	$stand7,	lth_stand1	] {ai_stand();};

void()	lth_walk1	=[	$walk1 ,	lth_walk2	] {
if (random() < 0.2)
	sound (self, CHAN_VOICE, "enforcer/idle1.wav", 1, ATTN_IDLE);
ai_walk(2);};
void()	lth_walk2	=[	$walk2 ,	lth_walk3	] {ai_walk(4);};
void()	lth_walk3	=[	$walk3 ,	lth_walk4	] {ai_walk(4);};
void()	lth_walk4	=[	$walk4 ,	lth_walk5	] {ai_walk(3);};
void()	lth_walk5	=[	$walk5 ,	lth_walk6	] {ai_walk(1);};
void()	lth_walk6	=[	$walk6 ,	lth_walk7	] {ai_walk(2);};
void()	lth_walk7	=[	$walk7 ,	lth_walk8	] {ai_walk(2);};
void()	lth_walk8	=[	$walk8 ,	lth_walk9	] {ai_walk(1);};
void()	lth_walk9	=[	$walk9 ,	lth_walk10	] {ai_walk(2);};
void()	lth_walk10	=[	$walk10,	lth_walk11	] {ai_walk(4);};
void()	lth_walk11	=[	$walk11,	lth_walk12	] {ai_walk(4);};
void()	lth_walk12	=[	$walk12,	lth_walk13	] {ai_walk(1);};
void()	lth_walk13	=[	$walk13,	lth_walk14	] {ai_walk(2);};
void()	lth_walk14	=[	$walk14,	lth_walk15	] {ai_walk(3);};
void()	lth_walk15	=[	$walk15,	lth_walk16	] {ai_walk(4);};
void()	lth_walk16	=[	$walk16,	lth_walk1	] {ai_walk(2);};

void()	lth_run1	=[	$run1  ,	lth_run2	] {ai_run(18);};
void()	lth_run2	=[	$run2  ,	lth_run3	] {ai_run(14);};
void()	lth_run3	=[	$run3  ,	lth_run4	] {ai_run(7);};
void()	lth_run4	=[	$run4  ,	lth_run5	] {ai_run(12);};
void()	lth_run5	=[	$run5  ,	lth_run6	] {ai_run(14);};
void()	lth_run6	=[	$run6  ,	lth_run7	] {ai_run(14);};
void()	lth_run7	=[	$run7  ,	lth_run8	] {ai_run(7);};
void()	lth_run8	=[	$run8  ,	lth_run1	] {
if (random() < 0.2)
	sound (self, CHAN_VOICE, "enforcer/idle1.wav", 1, ATTN_IDLE);ai_run(11);};

void()	lth_atk1	=[	$attack1,	lth_atk2	] {ai_face();};
void()	lth_atk2	=[	$attack2,	lth_atk3	] {ai_face();};
void()	lth_atk3	=[	$attack3,	lth_atk4	] {ai_face();};
void()	lth_atk4	=[	$attack4,	lth_atk5	] {ai_face();};
void()	lth_atk5	=[	$attack5,	lth_atk6	] {ai_face();};
void()	lth_atk6	=[	$attack6,	lth_atk7	]
{
	super_enforcer_fire();
	self.effects = self.effects | EF_MUZZLEFLASH;
};
void()	lth_atk7	=[	$attack7,	lth_atk8	]
{
	super_enforcer_fire();
	if (random() < 0.9)
	{
		self.think = lth_atk6;
		self.nextthink = time + 0.1;
	}
};
void()	lth_atk8	=[	$attack8,	lth_atk9	] {};
void()	lth_atk9	=[	$attack3,	lth_atk10	] {};
void()	lth_atk10	=[	$attack2,	lth_atk11	] {};
void()	lth_atk11	=[	$attack1,	lth_run1	] {};

void()	lth_paina1	=[	$paina1,	lth_paina2	] {};
void()	lth_paina2	=[	$paina2,	lth_paina3	] {};
void()	lth_paina3	=[	$paina3,	lth_paina4	] {};
void()	lth_paina4	=[	$paina4,	lth_run1	] {};


void(entity attacker, float damage)	super_enforcer_pain =
{
	if (self.pain_finished > time)
		return;

	if (random() < 0.2)
	{
		self.pain_finished = time + 2 + random();
		
		if (random() < 0.5)
			sound (self, CHAN_VOICE, "enforcer/pain1.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_VOICE, "enforcer/pain2.wav", 1, ATTN_NORM);
			
		lth_paina1 ();
	}
};

//============================================================================


void()	lth_fdie1	=[	$fdeath1,	lth_fdie2	] {};
void()	lth_fdie2	=[	$fdeath2,	lth_fdie3	] {};
void()	lth_fdie3	=[	$fdeath3,	lth_fdie4	] {};
void()	lth_fdie4	=[	$fdeath4,	lth_fdie5	] {};
void()	lth_fdie5	=[	$fdeath5,	lth_fdie6	] {};
void()	lth_fdie6	=[	$fdeath6,	lth_fdie7	] {};
void()	lth_fdie7	=[	$fdeath7,	lth_fdie8	] {};
void()	lth_fdie8	=[	$fdeath8,	lth_fdie9	] {};
void()	lth_fdie9	=[	$fdeath9,	lth_fdie10	] {};
void()	lth_fdie10	=[	$fdeath10,	lth_fdie11	] {};
void()	lth_fdie11	=[	$fdeath11,	lth_fdie11	] {};


void() super_enforcer_die =
{
	

	if (self.health < -50)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_mega.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		return;
	}

	self.solid = SOLID_NOT;	

	local entity item;
	local entity oself;

	item = spawn();
	item.classname = "weapon_supernailgun";
	item.origin = self.origin - '0 0 24';
	item.spawnflags = ITEM_DONTDROP + ITEM_DONTPRECACHE; // mid-level precaches are bad
	
	oself = self; self = item;
	weapon_supernailgun();
	self = oself;
	
	item.movetype = MOVETYPE_TOSS;
	item.velocity_z = 300;
	item.velocity_x = -100 + (random() * 200);
	item.velocity_y = -100 + (random() * 200);	

// regular death
	sound (self, CHAN_VOICE, "enforcer/death1.wav", 1, ATTN_NORM);
	lth_fdie1 ();
};


/*QUAKED monster_enforcer (1 0 0) (-16 -16 -24) (16 16 40) Ambush

*/
void() monster_super_enforcer =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model2 ("progs/enforce3.mdl");
	precache_model2 ("progs/h_mega.mdl");
	precache_model2 ("progs/s_spike.mdl");
	precache_model ("progs/g_nail2.mdl");
		
	precache_sound2 ("enforcer/death1.wav");
	precache_sound2 ("enforcer/idle1.wav");
	precache_sound2 ("enforcer/pain1.wav");
	precache_sound2 ("enforcer/pain2.wav");
	precache_sound2 ("lieut/target.wav");
	precache_sound2 ("lieut/objective.wav");
	precache_sound2 ("lieut/alert.wav");
	precache_sound2 ("lieut/you.wav");
		
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/enforce3.mdl");

	setsize (self, '-16 -16 -24', '16 16 40');
	
	if (skill == 0)
		self.health = 100;
	else
		self.health = 120;
	self.armortype = 0.8;
	self.armorvalue = 1000;

	self.th_stand 	= lth_stand1;
	self.th_walk 	= lth_walk1;
	self.th_run 	= lth_run1;
	self.th_pain 	= super_enforcer_pain;
	self.th_die 	= super_enforcer_die;
	self.th_missile = lth_atk1;

	walkmonster_start();
};
