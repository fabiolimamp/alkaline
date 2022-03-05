/*
1-14 walk
15-41 idle
42-51 pain1
52-71 pain2
72-83 leap
84-95 lightning
96-119 death
*/

/*
============================================================================

Arachnofloyd - the bestest boi

============================================================================
*/

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9 walk10
$frame walk11 walk12 walk13 walk14

$frame idle1 idle2 idle3 idle4 idle5 idle6 idle7 idle8 idle9 idle10
$frame idle11 idle12 idle13 idle14 idle15 idle16 idle17 idle18 idle19 idle20
$frame idle21 idle22 idle23 idle24 idle25 idle26 idle27
 
$frame paina1 paina2 paina3 paina4 paina5 paina6 paina7 paina8 paina9

$frame painb1 painb2 painb3 painb4 painb5 painb6 painb7 painb8 painb9 painb10
$frame painb11 painb12 painb13 painb14 painb15 painb16 painb17 painb18 painb19

$frame leap1 leap2 leap3 leap4 leap5 leap6 leap7 leap8 leap9 leap10 
$frame leap11

$frame light1 light2 light3 light4 light5 light6 light7 light8 light9 light10
$frame light11

$frame death1 death2 death3 death4 death5 death6 death7 death8 death9 death10
$frame death11 death12 death13 death14 death15 death16 death17 death18 death19 death20
$frame death21 death22 death23

void(float num) arf_step = {
	if (num == 1)
		sound (self, 5, "arachnofloyd/step1.wav", 1, 1.5);
	else
		sound (self, 5, "arachnofloyd/step2.wav", 1, 1.5);
}

void() arf_whirr = {
	sound (self, CHAN_BODY, "arachnofloyd/whirr1.wav", 1, ATTN_IDLE);
}

//-----------------------------------------------------------------------------

void()	arf_stand1	=[	$idle1,	arf_stand2	] {
	if(!(self.spawnflags & MONSTER_NOIDLESOUND)) {
		if (random() < 0.1) 	
			sound (self, CHAN_VOICE, "arachnofloyd/idle1.wav", 1, ATTN_IDLE);
		else
			sound (self, CHAN_VOICE, "arachnofloyd/idle2.wav", 1, ATTN_IDLE);
	}
	ai_stand();	
};
void()	arf_stand2	=[	$idle2,		arf_stand3	] {ai_stand();};
void()	arf_stand3	=[	$idle3,		arf_stand4	] {ai_stand();};
void()	arf_stand4	=[	$idle4,		arf_stand5	] {ai_stand();};
void()	arf_stand5	=[	$idle5,		arf_stand6	] {ai_stand();};
void()	arf_stand6	=[	$idle6,		arf_stand7	] {ai_stand();};
void()	arf_stand7	=[	$idle7,		arf_stand8	] {ai_stand();};
void()	arf_stand8	=[	$idle8,		arf_stand9	] {ai_stand();};
void()	arf_stand9	=[	$idle9,		arf_stand10	] {ai_stand();};
void()	arf_stand10	=[	$idle10,	arf_stand11	] {ai_stand();};
void()	arf_stand11	=[	$idle11,	arf_stand12	] {ai_stand();};
void()	arf_stand12	=[	$idle12,	arf_stand13	] {ai_stand();};
void()	arf_stand13	=[	$idle13,	arf_stand14	] {ai_stand();};
void()	arf_stand14 =[	$idle14,	arf_stand15	] {ai_stand();};
void()	arf_stand15 =[	$idle15,	arf_stand16	] {ai_stand();};
void()	arf_stand16 =[	$idle16,	arf_stand17	] {ai_stand();};
void()	arf_stand17 =[	$idle17,	arf_stand18	] {ai_stand();};
void()	arf_stand18 =[	$idle18,	arf_stand19	] {ai_stand();};
void()	arf_stand19 =[	$idle19,	arf_stand20	] {ai_stand();};
void()	arf_stand20 =[	$idle20,	arf_stand21 ] {ai_stand();};
void()	arf_stand21 =[	$idle21,	arf_stand22 ] {ai_stand();};
void()	arf_stand22 =[	$idle22,	arf_stand23 ] {ai_stand();};
void()	arf_stand23	=[	$idle23,	arf_stand24 ] {ai_stand();};
void()	arf_stand24	=[	$idle24,	arf_stand25 ] {ai_stand();};
void()	arf_stand25	=[	$idle25,	arf_stand26 ] {ai_stand();};
void()	arf_stand26	=[	$idle26,	arf_stand27 ] {ai_stand();};
void()	arf_stand27	=[	$idle27,	arf_stand1 ] {ai_stand();};



void()	arf_walk1	=[	$walk1,		arf_walk2	] {ai_walk(10);};
void()	arf_walk2	=[	$walk2,		arf_walk3	] {ai_walk(4); arf_whirr();};
void()	arf_walk3	=[	$walk3,		arf_walk4	] {ai_walk(2);};
void()	arf_walk4	=[	$walk4,		arf_walk5	] {ai_walk(0); arf_step(1);};
void()	arf_walk5	=[	$walk5,		arf_walk6	] {ai_walk(4);};
void()	arf_walk6	=[	$walk6,		arf_walk7	] {ai_walk(8);};
void()	arf_walk7	=[	$walk7,		arf_walk8	] {ai_walk(8);};
void()	arf_walk8	=[	$walk8,		arf_walk9	] {ai_walk(8);};
void()	arf_walk9	=[	$walk9,		arf_walk10	] {ai_walk(8);};
void()	arf_walk10	=[	$walk10,	arf_walk11	] {ai_walk(8); arf_whirr();};
void()	arf_walk11	=[	$walk11,	arf_walk12	] {ai_walk(4);};
void()	arf_walk12	=[	$walk12,	arf_walk13	] {ai_walk(2); arf_step(2);};
void()	arf_walk13	=[	$walk13,	arf_walk14	] {ai_walk(0);};
void()	arf_walk14	=[	$walk14,	arf_walk1	] {ai_walk(4);};


void() check_onground = {
	if (self.flags & FL_ONGROUND) self.touch = SUB_Null;
}

void(float dist) arf_run_fr = {
	check_onground();
	ai_run(dist);
	self.nextthink = time + 0.075; 
};

void()	arf_run1	=[	$walk1,		arf_run2	] {arf_run_fr(12); arf_whirr();};
void()	arf_run2	=[	$walk2,		arf_run3	] {arf_run_fr(8);};
void()	arf_run3	=[	$walk3,		arf_run4	] {arf_run_fr(4);};
void()	arf_run4	=[	$walk4,		arf_run5	] {arf_run_fr(0); arf_step(1);};
void()	arf_run5	=[	$walk5,		arf_run6	] {arf_run_fr(0);};
void()	arf_run6	=[	$walk6,		arf_run7	] {arf_run_fr(4);};
void()	arf_run7	=[	$walk7,		arf_run8	] {arf_run_fr(12);};
void()	arf_run8	=[	$walk8,		arf_run9	] {arf_run_fr(12);};
void()	arf_run9	=[	$walk9,		arf_run10	] {arf_run_fr(12); arf_whirr();};
void()	arf_run10	=[	$walk10,	arf_run11	] {arf_run_fr(12);};
void()	arf_run11	=[	$walk11,	arf_run12	] {arf_run_fr(6);};
void()	arf_run12	=[	$walk12,	arf_run13	] {arf_run_fr(2); arf_step(2);};
void()	arf_run13	=[	$walk13,	arf_run14	] {arf_run_fr(0);};
void()	arf_run14	=[	$walk14,	arf_run1	] {arf_run_fr(6);};




//-----------------------------------------------------------------------------

void()	arf_paina1	=[	$paina1,		arf_paina2	] {};
void()	arf_paina2	=[	$paina2,		arf_paina3	] {};
void()	arf_paina3	=[	$paina3,		arf_paina4	] {};
void()	arf_paina4	=[	$paina4,		arf_paina5	] {};
void()	arf_paina5	=[	$paina5,		arf_paina6	] {};
void()	arf_paina6	=[	$paina6,		arf_paina7	] {};
void()	arf_paina7	=[	$paina7,		arf_paina8	] {};
void()	arf_paina8	=[	$paina8,		arf_paina9	] {};
void()	arf_paina9	=[	$paina9,		arf_run1	] {};

void()	arf_painb1	=[	$painb1,	arf_painb2	] {};
void()	arf_painb2	=[	$painb2,	arf_painb3	] {};
void()	arf_painb3	=[	$painb3,	arf_painb4	] {};
void()	arf_painb4	=[	$painb4,	arf_painb5	] {};
void()	arf_painb5 	=[	$painb5,	arf_painb6	] {};
void()	arf_painb6 	=[	$painb6,	arf_painb7	] {};
void()	arf_painb7 	=[	$painb7,	arf_painb8	] {};
void()	arf_painb8 	=[	$painb8,	arf_painb9	] {};
void()	arf_painb9 	=[	$painb9,	arf_painb10	] {};
void()	arf_painb10	=[	$painb10,	arf_painb11	] {};
void()	arf_painb11	=[	$painb11,	arf_painb12	] {};
void()	arf_painb12	=[	$painb12,	arf_painb13	] {};
void()	arf_painb13	=[	$painb13,	arf_painb14	] {};
void()	arf_painb14	=[	$painb14,	arf_painb15	] {};
void()	arf_painb15 	=[	$painb15,	arf_painb16	] {};
void()	arf_painb16 	=[	$painb16,	arf_painb17	] {};
void()	arf_painb17 	=[	$painb17,	arf_painb18	] {};
void()	arf_painb18 	=[	$painb18,	arf_painb19	] {};
void()	arf_painb19 	=[	$painb19,	arf_run1	] {};

void(entity attacker, float damage)	arf_pain = {

	local float r;
	r = random();

	if (self.health <= 0)
		return;		// already dying, don't go into pain frame

	if (random()*200 > damage)
		return;		// didn't flinch

	if (self.pain_finished > time)
		return;

	self.pain_finished = time + 2;
		
	if (r < 0.5) {	
		arf_paina1();
		sound (self, CHAN_VOICE, "arachnofloyd/pain1.wav", 1, ATTN_NORM);
	}
	else {
		arf_painb1();
		sound (self, CHAN_VOICE, "arachnofloyd/pain2.wav", 1, ATTN_NORM);
	}
	
};


//-----------------------------------------------------------------------------

void() arf_explode = {
	sound (self, CHAN_VOICE, "arachnofloyd/death1.wav", 1, ATTN_NORM);
	ThrowHead ("progs/h_arach.mdl", self.health);
	ThrowGib ("progs/fgib1.mdl", self.health);
	ThrowGib ("progs/fgib1.mdl", self.health);
	ThrowGib ("progs/fgib1.mdl", self.health);
	ThrowGib ("progs/fgib1.mdl", self.health);
	ThrowGib ("progs/fgib1.mdl", self.health);

	TriggerExplosion();
}

void() arf_die = {
	// gib
	if (self.health < -60) {
		arf_explode();
		return;
	}

	// regular death
	sound (self, CHAN_VOICE, "arachnofloyd/death2.wav", 1, ATTN_NORM);
	arf_die1();
}



void()	arf_die1	=[	$death1,	arf_die2	] {};
void()	arf_die2	=[	$death2,	arf_die3	] {};
void()	arf_die3	=[	$death3,	arf_die4	] {self.solid = SOLID_NOT;};
void()	arf_die4	=[	$death4,	arf_die5	] {};
void()	arf_die5	=[	$death5,	arf_die6	] {};
void()	arf_die6	=[	$death6,	arf_die7	] {};
void()	arf_die7	=[	$death7,	arf_die8	] {};
void()	arf_die8	=[	$death8,	arf_die9	] {};
void()	arf_die9	=[	$death9,	arf_die10	] {};
void()	arf_die10	=[	$death10,	arf_die11	] {};
void()	arf_die11	=[	$death11,	arf_die12	] {};
void()	arf_die12	=[	$death12,	arf_die13	] {};
void()	arf_die13	=[	$death13,	arf_die14	] {};
void()	arf_die14	=[	$death14,	arf_die15	] {};
void()	arf_die15 	=[	$death15,	arf_die16	] {};
void()	arf_die16 	=[	$death16,	arf_die17	] {};
void()	arf_die17 	=[	$death17,	arf_die18	] {};
void()	arf_die18 	=[	$death18,	arf_die19	] {};
void()	arf_die19 	=[	$death19,	arf_die20	] {};
void()	arf_die20 	=[	$death20,	arf_die21 	] {};
void()	arf_die21 	=[	$death21,	arf_die22 	] {};
void()	arf_die22 	=[	$death22,	arf_die23 	] {};
void()	arf_die23	=[	$death23,	arf_die23 	] {arf_explode();};



//-----------------------------------------------------------------------------

void() arf_touch_jump = {
	if (other.classname == "player") {
		if (other.pain_finished > time) return;
	}

	if (other.takedamage) {
		T_Damage (other, self, self, 60);
		// stop the player from taking damage every frame
		other.pain_finished = time + 1;
	}
};

void()	arf_leap1	=[	$leap1,		arf_leap2	] {self.yaw_speed = 30;ai_face();};
void()	arf_leap2	=[	$leap2,		arf_leap3	] {ai_face();};
void()	arf_leap3	=[	$leap3,		arf_leap4	] {ai_face();};
void()	arf_leap4	=[	$leap4,		arf_leap5	] {ai_face();};
void()	arf_leap5	=[	$leap5,		arf_leap6	] {ai_face();};
void()	arf_leap6	=[	$leap6,		arf_leap7	] {ai_face();
	self.yaw_speed = 20;
	sound (self, CHAN_VOICE, "arachnofloyd/leap.wav", 0.7, ATTN_NORM);
	makevectors(self.angles);
	self.flags = self.flags - FL_ONGROUND;
	self.origin_z = self.origin_z + 16;
	self.velocity = '0 0 0';
	self.velocity = self.velocity + v_forward * 400;
	self.velocity_z = self.velocity_z + 275;
	self.touch = arf_touch_jump;
};
void()	arf_leap7	=[	$leap7,		arf_leap8	] {check_onground();};
void()	arf_leap8	=[	$leap8,		arf_leap9	] {check_onground();};
void()	arf_leap9	=[	$leap9,		arf_leap10	] {check_onground();};
void()	arf_leap10	=[	$leap10,	arf_leap11	] {check_onground();};
void()	arf_leap11 	=[	$leap11,	arf_run1	] {self.attack_finished = time + 2; check_onground();};



//-----------------------------------------------------------------------------



void(float offs) arf_fire_lightning =
{
	local	vector	org, org2, dir;
	
	self.effects = self.effects | EF_MUZZLEFLASH;
	makevectors(self.angles);
	org = self.origin + v_right * offs * 32 + v_forward * 24 + '0 0 24';
	org2 = self.origin + v_right * offs * 32 + v_forward * 24 + '0 0 24';
	dir = self.enemy.origin + '0 0 16' - org;
	dir = normalize (dir);
	
	traceline (org, org + dir*600, TRUE, self);
	
	fx_beam(org2, trace_endpos, self);

	LightningDamage (org, trace_endpos, self, 8);
};

void(float fr) arf_charge_lightning = {
	self.effects = self.effects | EF_MUZZLEFLASH;
	makevectors(self.sibling.angles);
	self.sibling.origin = self.origin + v_forward * 48 + v_up * -56 + v_right * -12;
	setorigin (self.sibling, self.sibling.origin);
	self.sibling.angles = self.angles;
	if (fr == 1) sound (self, CHAN_VOICE, "misc/power.wav", 1, ATTN_NORM);
}

void() arf_lightning_think = {
	if (time > self.attack_finished) {
		arf_lightning_remove(self);
		return;
	}

	if (self.frame >= 2) self.frame = 0;
	else self.frame++;

	self.nextthink = time + 0.05;
}

void(entity lt) arf_lightning_remove = {
	if (lt.owner.sibling == self) lt.owner.sibling = world;
	remove(lt);
}

void()	arf_light1	=[$light1, arf_light2] {
	ai_face();
	
	self.sibling = spawn();
	self.sibling.owner = self;
	self.sibling.nextthink = time + 0.05;
	self.sibling.think = arf_lightning_think;
	self.sibling.attack_finished = time + 0.7;
	setmodel (self.sibling, "progs/s_light.mdl");

	arf_charge_lightning(1);
};
void()	arf_light2	=[	$light2,		arf_light3	] {ai_face(); arf_charge_lightning(2);};
void()	arf_light3	=[	$light3,		arf_light4	] {ai_face(); arf_charge_lightning(1);};
void()	arf_light4	=[	$light4,		arf_light5	] {ai_face(); arf_charge_lightning(2);};
void()	arf_light5	=[	$light5,		arf_light6	] {ai_face(); arf_charge_lightning(1);};
void()	arf_light6	=[	$light6,		arf_light7	] {ai_face(); arf_charge_lightning(2);};
void()	arf_light7	=[	$light7,		arf_light8	] {
	ai_face();
	//remove(self.sibling);
	sound (self, CHAN_WEAPON, "shambler/sboom.wav", 1, ATTN_NORM);
	arf_fire_lightning(1);
};
void()	arf_light8	=[	$light8,		arf_light9	] {ai_face(); arf_fire_lightning(-1);};
void()	arf_light9	=[	$light9,		arf_light10	] {ai_face(); arf_fire_lightning(1);};
void()	arf_light10	=[	$light10,		arf_light11	] {ai_face(); arf_fire_lightning(-1);};
void()	arf_light11 =[	$light11,		arf_run1	] {
	ai_face();
	arf_fire_lightning(1);
	self.attack_finished = time + 3.25;
};


/*
===========
arfCheckAttack

based off ShamCheckAttack
============
*/
float() arfCheckAttack =
{
	local vector	spot1, spot2;	
	local entity	targ;

	if (time < self.attack_finished)
		return FALSE;

	targ = self.enemy;
// see if any entities are in the way of the shot
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;	

	if ((enemy_range == RANGE_MELEE) || (enemy_range == RANGE_NEAR))
	{
		if (CanDamage (self.enemy, self))
		{
			if 	((vlen(spot1 - spot2) > 200) && (vlen(spot1 - spot2) < 500))
				{
				
					if (random() > 0.33)
					{
						self.attack_state = AS_MELEE;
					}
					else
					{
						self.attack_state = AS_MISSILE;
					}
				}
			else
				{
				self.attack_state = AS_MISSILE;
				}
			return TRUE;
		}
	}

	if (!enemy_vis)
		return FALSE;

	if (vlen(spot1 - spot2) > 600)
		return FALSE;

	traceline (spot1, spot2, FALSE, self);

	if (trace_inopen && trace_inwater)
		return FALSE;			// sight line crossed contents

	if (trace_ent != targ)
	{
		return FALSE;	// don't have a clear shot
	}
			
// missile attack
	if (enemy_range == RANGE_FAR)
		return FALSE;
		
	self.attack_state = AS_MISSILE;
	SUB_AttackFinished (2 + 2*random());
	return TRUE;
};

void() arf_sight = {
	sound (self, CHAN_VOICE, "arachnofloyd/sight.wav", 1, ATTN_NORM);
};


/*QUAKED monster_arachnofloyd (1 0 0) (-32 -32 -24) (32 32 48) Ambush
*/
void(entity e) monster_arachnofloyd_start =
{
	local entity oself;

	oself = self;
	self = e;

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	self.classname = "monster_arachnofloyd";
	
	setmodel (self, "progs/arachnofloyd.mdl");
	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 24');
	else setsize (self, self.cmins, self.cmaxs);
	self.health = 600;
	self.bloodtype = SPAWN_YELLOWSPARK;

	self.th_stand = arf_stand1;
	self.th_walk = arf_walk1;
	self.th_run = arf_run1;
	self.th_die = arf_die;
	self.th_pain = arf_pain;
	self.th_missile = arf_light1;
	self.th_melee = arf_leap1;
	self.th_sight = arf_sight;
	self.th_checkattack = arfCheckAttack;

	if (self.obituary == "") self.obituary = "was disintegrated by an Arachnofloyd";


	self.think = walkmonster_start;
	self.nextthink = time + 0.1 + random ()*0.1;	

	self = oself;
};

void() monster_arachnofloyd_spawner = {
	monster_spawner(monster_arachnofloyd_start);
};


void() monster_arachnofloyd =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model2 ("progs/arachnofloyd.mdl");
	precache_model2 ("progs/h_arach.mdl");
	precache_model2 ("progs/fgib1.mdl");


	precache_model2 ("progs/s_light.mdl");
	precache_sound2 ("misc/power.wav");
	precache_sound2 ("shambler/sboom.wav");
	precache_sound2 ("arachnofloyd/whirr1.wav");
	precache_sound2 ("arachnofloyd/step2.wav");
	precache_sound2 ("arachnofloyd/step1.wav");
	precache_sound2 ("arachnofloyd/leap.wav");
//	precache_sound2 ("arachnofloyd/attack.wav");
	precache_sound2 ("arachnofloyd/death1.wav");
	precache_sound2 ("arachnofloyd/death2.wav");	
	precache_sound2 ("arachnofloyd/idle1.wav");
	precache_sound2 ("arachnofloyd/idle2.wav");	
	precache_sound2 ("arachnofloyd/pain1.wav");
	precache_sound2 ("arachnofloyd/pain2.wav");	
	precache_sound2 ("arachnofloyd/sight.wav");

	self.cmins = VEC_HULL2_MIN;
	self.cmaxs = VEC_HULL2_MAX;

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 24');
	else setsize (self, self.cmins, self.cmaxs);
	
	if (self.spawnflags & MONSTER_SPAWNER) {
		self.use = monster_arachnofloyd_spawner;
		monster_spawner_updatecounter();
	}
	else {
		monster_arachnofloyd_start(self);
	}
};

