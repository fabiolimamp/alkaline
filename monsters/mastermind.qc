/*
0-13 walk
14-41 idle
42-52 pain1
53-71 pain2
72-83 leap
84-94 lightning
95-118 death
*/

/*
============================================================================

mastermind

============================================================================
*/

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9 walk10
$frame walk11 walk12 walk13 walk14

$frame idle1 idle2 idle3 idle4 idle5 idle6 idle7 idle8 idle9 idle10
$frame idle11 idle12 idle13 idle14 idle15 idle16 idle17 idle18 idle19 idle20
$frame idle21 idle22 idle23 idle24 idle25 idle26 idle27 idle28
 
$frame paina1 paina2 paina3 paina4 paina5 paina6 paina7 paina8 paina9 paina10
$frame paina11

$frame painb1 painb2 painb3 painb4 painb5 painb6 painb7 painb8 painb9 painb10
$frame painb11 painb12 painb13 painb14 painb15 painb16 painb17 painb18 painb19

$frame leap1 leap2 leap3 leap4 leap5 leap6 leap7 leap8 leap9 leap10
$frame leap11

$frame light1 light2 light3 light4 light5 light6 light7 light8 light9 light10
$frame light11 light12

$frame death1 death2 death3 death4 death5 death6 death7 death8 death9 death10
$frame death11 death12 death13 death14 death15 death16 death17 death18 death19 death20
$frame death21 death22 death23 death24



void() mmind_stand1 = [ $idle1,	mmind_stand2	] {
	/*local float r;
	if (!(self.spawnflags & MONSTER_NOIDLESOUND)) {
		r = random();
		if (r < 0.1) {
			sound(self, CHAN_VOICE, "arachnofloyd/idle1.wav", 1, ATTN_IDLE);
		}
		else if (r > 0.9) {
			sound(self, CHAN_VOICE, "arachnofloyd/idle2.wav", 1, ATTN_IDLE);
		}
	}*/
	ai_stand();
};
void()	mmind_stand2	=[	$idle2,		mmind_stand3	] {ai_stand();};
void()	mmind_stand3	=[	$idle3,		mmind_stand4	] {ai_stand();};
void()	mmind_stand4	=[	$idle4,		mmind_stand5	] {ai_stand();};
void()	mmind_stand5	=[	$idle5,		mmind_stand6	] {ai_stand();};
void()	mmind_stand6	=[	$idle6,		mmind_stand7	] {ai_stand();};
void()	mmind_stand7	=[	$idle7,		mmind_stand8	] {ai_stand();};
void()	mmind_stand8	=[	$idle8,		mmind_stand9	] {ai_stand();};
void()	mmind_stand9	=[	$idle9,		mmind_stand10	] {ai_stand();};
void()	mmind_stand10	=[	$idle10,	mmind_stand11	] {ai_stand();};
void()	mmind_stand11	=[	$idle11,	mmind_stand12	] {ai_stand();};
void()	mmind_stand12	=[	$idle12,	mmind_stand13	] {ai_stand();};
void()	mmind_stand13	=[	$idle13,	mmind_stand14	] {ai_stand();};
void()	mmind_stand14 =[	$idle14,	mmind_stand15	] {ai_stand();};
void()	mmind_stand15 =[	$idle15,	mmind_stand16	] {ai_stand();};
void()	mmind_stand16 =[	$idle16,	mmind_stand17	] {ai_stand();};
void()	mmind_stand17 =[	$idle17,	mmind_stand18	] {ai_stand();};
void()	mmind_stand18 =[	$idle18,	mmind_stand19	] {ai_stand();};
void()	mmind_stand19 =[	$idle19,	mmind_stand20	] {ai_stand();};
void()	mmind_stand20 =[	$idle20,	mmind_stand21 ] {ai_stand();};
void()	mmind_stand21 =[	$idle21,	mmind_stand22 ] {ai_stand();};
void()	mmind_stand22 =[	$idle22,	mmind_stand23 ] {ai_stand();};
void()	mmind_stand23	=[	$idle23,	mmind_stand24 ] {ai_stand();};
void()	mmind_stand24	=[	$idle24,	mmind_stand25 ] {ai_stand();};
void()	mmind_stand25	=[	$idle25,	mmind_stand26 ] {ai_stand();};
void()	mmind_stand26	=[	$idle26,	mmind_stand27 ] {ai_stand();};
void()	mmind_stand27	=[	$idle27,	mmind_stand28 ] {ai_stand();};
void()	mmind_stand28	=[	$idle28,	mmind_stand1 ] {ai_stand();};


void()	mmind_walk1	=[	$walk1,		mmind_walk2	] {sound (self, CHAN_BODY, "mastermind/mmindwalk.wav", 1, ATTN_IDLE);ai_walk(8);};
void()	mmind_walk2	=[	$walk2,		mmind_walk3	] {ai_walk(4);};
void()	mmind_walk3	=[	$walk3,		mmind_walk4	] {ai_walk(2);};
void()	mmind_walk4	=[	$walk4,		mmind_walk5	] {ai_walk(0);};
void()	mmind_walk5	=[	$walk5,		mmind_walk6	] {ai_walk(10);};
void()	mmind_walk6	=[	$walk6,		mmind_walk7	] {ai_walk(10);};
void()	mmind_walk7	=[	$walk7,		mmind_walk8	] {sound (self, CHAN_BODY, "mastermind/mmindwalk.wav", 1, ATTN_IDLE);ai_walk(3);};
void()	mmind_walk8	=[	$walk8,		mmind_walk9	] {ai_walk(0);};
void()	mmind_walk9	=[	$walk9,		mmind_walk10	] {ai_walk(10);};
void()	mmind_walk10	=[	$walk10,	mmind_walk11	] {ai_walk(7);};
void()	mmind_walk11	=[	$walk11,	mmind_walk12	] {ai_walk(3);};
void()	mmind_walk12	=[	$walk12,	mmind_walk13	] {ai_walk(0);};
void()	mmind_walk13	=[	$walk13,	mmind_walk14	] {ai_walk(10);};
void()	mmind_walk14	=[	$walk14,	mmind_walk1	] {ai_walk(10);};

/*
void() check_onground = {
	if (self.flags & FL_ONGROUND)
		self.touch = SUB_Null;
	else	
		return;
}
*/

void()	mmind_run1	=[	$walk1,		mmind_run2	] {check_onground();ai_run(16); self.nextthink = time + 0.075; };
void()	mmind_run2	=[	$walk2,		mmind_run3	] {check_onground();ai_run(8); self.nextthink = time + 0.075;};
void()	mmind_run3	=[	$walk3,		mmind_run4	] {check_onground();ai_run(4); self.nextthink = time + 0.075; sound(self, CHAN_BODY, "mastermind/mmindwalk.wav", 1, ATTN_IDLE);};
void()	mmind_run4	=[	$walk4,		mmind_run5	] {check_onground();ai_run(0); self.nextthink = time + 0.075;};
void()	mmind_run5	=[	$walk5,		mmind_run6	] {check_onground();ai_run(20); self.nextthink = time + 0.075;};
void()	mmind_run6	=[	$walk6,		mmind_run7	] {check_onground();ai_run(20); self.nextthink = time + 0.075;};
void()	mmind_run7	=[	$walk7,		mmind_run8	] {check_onground();ai_run(6); self.nextthink = time + 0.075; };
void()	mmind_run8	=[	$walk8,		mmind_run9	] {check_onground();ai_run(0); self.nextthink = time + 0.075; sound(self, CHAN_BODY, "mastermind/mmindwalk.wav", 1, ATTN_IDLE);};
void()	mmind_run9	=[	$walk9,		mmind_run10	] {check_onground();ai_run(20); self.nextthink = time + 0.075;};
void()	mmind_run10	=[	$walk10,	mmind_run11	] {check_onground();ai_run(14); self.nextthink = time + 0.075;};
void()	mmind_run11	=[	$walk11,	mmind_run12	] {check_onground();ai_run(6); self.nextthink = time + 0.075;};
void()	mmind_run12	=[	$walk12,	mmind_run13	] {check_onground();ai_run(0); self.nextthink = time + 0.075; sound(self, CHAN_BODY, "mastermind/mmindwalk.wav", 1, ATTN_IDLE);};
void()	mmind_run13	=[	$walk13,	mmind_run14	] {check_onground();ai_run(20); self.nextthink = time + 0.075;};
void()	mmind_run14	=[	$walk14,	mmind_run1	] {check_onground();ai_run(20); self.nextthink = time + 0.075;};

void() mmind_die;

void()	mmind_die1	=[	$death1,	mmind_die2	] {sound (self, CHAN_VOICE, "mastermind/mminddeath.wav", 1, ATTN_NORM);};
void()	mmind_die2	=[	$death2,	mmind_die3	] {};
void()	mmind_die3	=[	$death3,	mmind_die4	] {self.solid = SOLID_TRIGGER; setorigin(self, self.origin);};
void()	mmind_die4	=[	$death4,	mmind_die5	] {};
void()	mmind_die5	=[	$death5,	mmind_die6	] {};
void()	mmind_die6	=[	$death6,	mmind_die7	] {};
void()	mmind_die7	=[	$death7,	mmind_die8	] {};
void()	mmind_die8	=[	$death8,	mmind_die9	] {};
void()	mmind_die9	=[	$death9,	mmind_die10	] {};
void()	mmind_die10	=[	$death10,	mmind_die11	] {};
void()	mmind_die11	=[	$death11,	mmind_die12	] {};
void()	mmind_die12	=[	$death12,	mmind_die13	] {};
void()	mmind_die13	=[	$death13,	mmind_die14	] {};
void()	mmind_die14	=[	$death14,	mmind_die15	] {};
void()	mmind_die15 	=[	$death15,	mmind_die16	] {};
void()	mmind_die16 	=[	$death16,	mmind_die17	] {};
void()	mmind_die17 	=[	$death17,	mmind_die18	] {/*sound(self, CHAN_WEAPON, "demon/dland2.wav", 1, ATTN_NORM);*/};
void()	mmind_die18 	=[	$death18,	mmind_die19	] {};
void()	mmind_die19 	=[	$death19,	mmind_die20	] {};
void()	mmind_die20 	=[	$death20,	mmind_die21 	] {};
void()	mmind_die21 	=[	$death21,	mmind_die22 	] {};
void()	mmind_die22 	=[	$death22,	mmind_die23 	] {};
void()	mmind_die23 	=[	$death23,	mmind_die24 	] {};
void()	mmind_die24	=[	$death24,	mmind_die24 	] {self.think = SUB_MakeNotSolid; self.nextthink = time + 5;};

void() mmind_die = {
	self.skin = 0;
	if (self.health < -50) {
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/mastermind_gib_head.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		ThrowGib ("progs/mastermind_gib_leg.mdl", self.health);
		ThrowGib ("progs/mastermind_gib_leg.mdl", self.health);
		ThrowGib ("progs/mastermind_gib_leg.mdl", self.health);
		ThrowGib ("progs/mastermind_gib_body.mdl", self.health);
		ThrowGib ("progs/mastermind_gib_scrap.mdl", self.health);
		ThrowGib ("progs/mastermind_gib_gun.mdl", self.health);

		//BecomeExplosion ();
		TriggerExplosion();
	}
	else {
		// regular death
		//self.skin = 2;
		mmind_die1();	
	}
};





void()	mmind_paina1	=[	$paina1,		mmind_paina2	] {};
void()	mmind_paina2	=[	$paina2,		mmind_paina3	] {};
void()	mmind_paina3	=[	$paina3,		mmind_paina4	] {};
void()	mmind_paina4	=[	$paina4,		mmind_paina5	] {};
void()	mmind_paina5	=[	$paina5,		mmind_paina6	] {};
void()	mmind_paina6	=[	$paina6,		mmind_paina7	] {};
void()	mmind_paina7	=[	$paina7,		mmind_paina8	] {};
void()	mmind_paina8	=[	$paina8,		mmind_paina9	] {};
void()	mmind_paina9	=[	$paina9,		mmind_paina10	] {};
void()	mmind_paina10	=[	$paina10,		mmind_paina11	] {};
void()	mmind_paina11	=[	$paina11,		mmind_run1	] {};

void()	mmind_painb1	=[	$painb1,	mmind_painb2	] {};
void()	mmind_painb2	=[	$painb2,	mmind_painb3	] {};
void()	mmind_painb3	=[	$painb3,	mmind_painb4	] {};
void()	mmind_painb4	=[	$painb4,	mmind_painb5	] {};
void()	mmind_painb5 	=[	$painb5,	mmind_painb6	] {};
void()	mmind_painb6 	=[	$painb6,	mmind_painb7	] {};
void()	mmind_painb7 	=[	$painb7,	mmind_painb8	] {};
void()	mmind_painb8 	=[	$painb8,	mmind_painb9	] {};
void()	mmind_painb9 	=[	$painb9,	mmind_painb10	] {};
void()	mmind_painb10	=[	$painb10,	mmind_painb11	] {};
void()	mmind_painb11	=[	$painb11,	mmind_painb12	] {};
void()	mmind_painb12	=[	$painb12,	mmind_painb13	] {};
void()	mmind_painb13	=[	$painb13,	mmind_painb14	] {};
void()	mmind_painb14	=[	$painb14,	mmind_painb15	] {};
void()	mmind_painb15 	=[	$painb15,	mmind_painb16	] {};
void()	mmind_painb16 	=[	$painb16,	mmind_painb17	] {};
void()	mmind_painb17 	=[	$painb17,	mmind_painb18	] {};
void()	mmind_painb18 	=[	$painb18,	mmind_painb19	] {};
void()	mmind_painb19 	=[	$painb19,	mmind_run1	] {};

void(entity attacker, float damage)	mmind_pain = {

	local float r;
	r = random();


	if (self.health <= 0)
		return;		// allready dying, don't go into pain frame

	if (self.health > 500 || random()*200 > damage)
		return;		// didn't flinch

	if (self.pain_finished > time)
		return;
	self.pain_finished = time + 2;

	self.yaw_speed = 20;
	self.skin = 0;

	if (r < 0.5) 	
		mmind_paina1();
	else
		mmind_painb1();

	sound(self, CHAN_VOICE, "mastermind/mmindpain.wav", 1, ATTN_IDLE);
};


void() mmind_touch_jump = {
	if (other.classname == "player") {
		if (other.pain_finished > time)
			return;
	}

	if (other.takedamage) {
		T_Damage (other, self, self, 60, DMGTYPE_MELEE);
		// stop the player from taking damage every frame
		other.pain_finished = time + 1;
	}
};



void()	mmind_leap1	=[	$leap1,		mmind_leap2	] {self.yaw_speed = 30;ai_face();};
void()	mmind_leap2	=[	$leap2,		mmind_leap3	] {ai_face();};
void()	mmind_leap3	=[	$leap3,		mmind_leap4	] {ai_face();};
void()	mmind_leap4	=[	$leap4,		mmind_leap5	] {ai_face();};
void()	mmind_leap5	=[	$leap5,		mmind_leap6	] {ai_face();};
void()	mmind_leap6	=[	$leap6,		mmind_leap7	] {ai_face();

	self.yaw_speed = 20;
	sound (self, CHAN_VOICE, "mastermind/mmindleap.wav", 0.7, ATTN_NORM);
	makevectors(self.angles);
	self.flags = self.flags - FL_ONGROUND;
	self.origin_z += 16;
	self.velocity = v_forward * 550 + '0 0 300';
	self.touch = mmind_touch_jump;
};
void()	mmind_leap7	=[	$leap7,		mmind_leap8	] {check_onground();};
void()	mmind_leap8	=[	$leap8,		mmind_leap9	] {check_onground();};
void()	mmind_leap9	=[	$leap9,		mmind_leap10	] {check_onground();};
void()	mmind_leap10	=[	$leap10,	mmind_leap11	] {check_onground();};
void()	mmind_leap11 	=[	$leap11,	mmind_run1	] {self.attack_finished = time + 2; check_onground();};


void() mmindSpikeTouch =
{

	if (pointcontents(self.origin) == CONTENT_SKY){
		remove(self);
		return;
	}
	float damg = 24;

	if (other.health) {
		T_Damage(other, self, self.owner, damg, DMGTYPE_BALLISTIC);
		spawn_touchblood(damg);
	}
	else {
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_SPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);

		makevectors([-self.angles_x, self.angles_y, self.angles_z]);
		traceline(self.origin, self.origin + v_forward*32, TRUE, self);
		if (trace_fraction != 1) placebullethole(trace_endpos, trace_plane_normal, trace_ent);
		
	}
	
	remove(self);
};


void(vector org, vector dir) mmindSpike = {
	newmis = spawn();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;
	newmis.classname = "plasma";
	newmis.flags = newmis.flags | FL_PROJECTILE;
	newmis.velocity = dir * 800;
	newmis.angles = vectoangles(newmis.velocity);
	//newmis.avelocity = '300 300 300'; 

	newmis.touch = mmindSpikeTouch;

	newmis.effects = EF_DIMLIGHT;

	setmodel(newmis, "progs/s_spike.mdl");
	setsize(newmis, '0 0 0', '0 0 0');
	setorigin(newmis, org);
};

void() mmind_fire = {
	local	vector	dir;
	local	entity	en;
	
	sound (self, CHAN_WEAPON, "weapons/sng.wav", 1, ATTN_NORM);	

	en = SUB_entEnemyTarget();
	vector envel = en.velocity;
	envel_z *= 0.25;
	
	dir = en.origin + (envel * clamp(vlen(self.origin - en.origin)/800, 0, 1));
	dir = normalize (dir - self.origin);
	
	makevectors(self.angles);

	mmindSpike(self.origin + v_forward*32 + v_right*0 + v_up*16, dir);
}

void() mmind_face_ahead =
{
	entity en = SUB_entEnemyTarget();

	self.ideal_yaw = vectoyaw(en.origin + (en.velocity * clamp(vlen(self.origin - en.origin)/800, 0, 1))/2 - self.origin);
	ChangeYaw ();
};

void()	mmind_light1	=[	$light1,		mmind_light2	] {ai_face(); self.cnt = 0; sound(self, CHAN_VOICE, "mastermind/mmindcharge.wav", 0.7, ATTN_NORM);};
void()	mmind_light2	=[	$light2,		mmind_light3	] {ai_face();};
void()	mmind_light3	=[	$light3,		mmind_light4	] {ai_face();};
void()	mmind_light4	=[	$light4,		mmind_light5	] {ai_face();};
void()	mmind_light5	=[	$light5,		mmind_light6	] {mmind_face_ahead();}; 
void()	mmind_light6	=[	$light6,		mmind_light7	] {mmind_face_ahead(); nxth(0.05);}; // return here for repeated fire
void()	mmind_light7	=[	$light7,		mmind_light8	] {
	mmind_face_ahead();
	mmind_fire();
	if (self.cnt < 16) {
		self.cnt++;
		self.think = mmind_light6;
		nxth(0.05);
	}
	self.skin = 1;
};
void()	mmind_light8	=[	$light8,		mmind_light9	] {ai_face(); self.cnt = 0; self.skin = 0;};
void()	mmind_light9	=[	$light9,		mmind_light10	] {ai_face();};
void()	mmind_light10	=[	$light10,		mmind_light11	] {ai_face();};
void()	mmind_light11	=[	$light11,		mmind_light12	] {ai_face();};
void()	mmind_light12 =[	$light12,		mmind_run1	] {
	ai_face();
	self.attack_finished = time + 2 + random();
};


/*
===========
mmindCheckAttack
============
*/
float() mmindCheckAttack = {
	local vector	spot1, spot2;	
	local entity	targ;
	local float dist;

	if (time < self.attack_finished)
		return FALSE;

	targ = self.enemy;

	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;
	dist = vlen(spot1 - spot2);

	if (enemy_range == RANGE_MELEE || enemy_range == RANGE_NEAR) {
		if (CanDamage(self.enemy, self.origin)) {
			if (enemy_range == RANGE_NEAR && random() < 0.33)
				self.attack_state = AS_MELEE;
			else 
				self.attack_state = AS_MISSILE;
			
			return TRUE;
		}
	}

	if (!enemy_vis)
		return FALSE;

	if (dist > 1000)
		return FALSE;

	traceline(spot1, spot2, FALSE, self);

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
	SUB_AttackFinished(1 + 1*random());
	return TRUE;
};

void() mmind_sight = {
	sound (self, CHAN_VOICE, "mastermind/mmindsight.wav", 1, ATTN_NORM);
};


/*QUAKED monster_arachnofloyd (1 0 0) (-32 -32 -24) (32 32 48) Ambush
*/
void(entity e) monster_mastermind_start = {
	local entity oself;

	oself = self;
	self = e;

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	self.classname = "monster_mastermind";
	
	setmodel (self, "progs/mastermind.mdl");
	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 24');
	else setsize (self, self.cmins, self.cmaxs);
	self.health = 1500;
	self.bloodtype = SPAWN_BLOOD;

	self.th_stand = mmind_stand1;
	self.th_walk = mmind_walk1;
	self.th_run = mmind_run1;
	self.th_die = mmind_die;
	self.th_pain = mmind_pain;
	self.th_missile = mmind_light1;
	self.th_melee = mmind_leap1;
	self.th_sight = mmind_sight;
	self.th_checkattack = mmindCheckAttack;

	if (self.obituary == "") self.obituary = "was mowed down by the Spider Mastermind";


	self.think = walkmonster_start;
	self.nextthink = time + 0.1 + random ()*0.1;	

	self = oself;
};

void() monster_mastermind_spawner = {
	monster_spawner(monster_mastermind_start);
};


void() monster_mastermind = {
	if (deathmatch)	{
		remove(self);
		return;
	}

	precache_model("progs/mastermind.mdl");
	precache_model("progs/mastermind_gib_head.mdl");
	precache_model("progs/mastermind_gib_scrap.mdl");
	precache_model("progs/mastermind_gib_gun.mdl");
	precache_model("progs/mastermind_gib_leg.mdl");
	precache_model("progs/mastermind_gib_body.mdl");
	
	
	precache_sound("mastermind/mmindleap.wav");
	precache_sound("mastermind/mmindsight.wav");
	precache_sound("mastermind/mminddeath.wav");
	precache_sound("mastermind/mmindpain.wav");
	precache_sound("mastermind/mmindwalk.wav");
	precache_sound("mastermind/mmindplasma.wav");
	precache_sound("mastermind/mmindcharge.wav");

	self.cmins = VEC_HULL2_MIN;
	self.cmaxs = VEC_HULL2_MAX;

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 24');
	else setsize (self, self.cmins, self.cmaxs);
	
	if (self.spawnflags & MONSTER_SPAWNER) {
		self.use = monster_mastermind_spawner;
		monster_spawner_updatecounter();
	}
	else {
		monster_mastermind_start(self);
	}
};

