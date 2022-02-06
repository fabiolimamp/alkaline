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

Arachnotron

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



void() art_stand1 = [ $idle1,	art_stand2	] {
	local float r;
	if (!(self.spawnflags & MONSTER_NOIDLESOUND)) {
		r = random();
		if (r < 0.1) {
			sound(self, CHAN_VOICE, "arachnofloyd/idle1.wav", 1, ATTN_IDLE);
		}
		else if (r > 0.9) {
			sound(self, CHAN_VOICE, "arachnofloyd/idle2.wav", 1, ATTN_IDLE);
		}
	}
	ai_stand();
};
void()	art_stand2	=[	$idle2,		art_stand3	] {ai_stand();};
void()	art_stand3	=[	$idle3,		art_stand4	] {ai_stand();};
void()	art_stand4	=[	$idle4,		art_stand5	] {ai_stand();};
void()	art_stand5	=[	$idle5,		art_stand6	] {ai_stand();};
void()	art_stand6	=[	$idle6,		art_stand7	] {ai_stand();};
void()	art_stand7	=[	$idle7,		art_stand8	] {ai_stand();};
void()	art_stand8	=[	$idle8,		art_stand9	] {ai_stand();};
void()	art_stand9	=[	$idle9,		art_stand10	] {ai_stand();};
void()	art_stand10	=[	$idle10,	art_stand11	] {ai_stand();};
void()	art_stand11	=[	$idle11,	art_stand12	] {ai_stand();};
void()	art_stand12	=[	$idle12,	art_stand13	] {ai_stand();};
void()	art_stand13	=[	$idle13,	art_stand14	] {ai_stand();};
void()	art_stand14 =[	$idle14,	art_stand15	] {ai_stand();};
void()	art_stand15 =[	$idle15,	art_stand16	] {ai_stand();};
void()	art_stand16 =[	$idle16,	art_stand17	] {ai_stand();};
void()	art_stand17 =[	$idle17,	art_stand18	] {ai_stand();};
void()	art_stand18 =[	$idle18,	art_stand19	] {ai_stand();};
void()	art_stand19 =[	$idle19,	art_stand20	] {ai_stand();};
void()	art_stand20 =[	$idle20,	art_stand21 ] {ai_stand();};
void()	art_stand21 =[	$idle21,	art_stand22 ] {ai_stand();};
void()	art_stand22 =[	$idle22,	art_stand23 ] {ai_stand();};
void()	art_stand23	=[	$idle23,	art_stand24 ] {ai_stand();};
void()	art_stand24	=[	$idle24,	art_stand25 ] {ai_stand();};
void()	art_stand25	=[	$idle25,	art_stand26 ] {ai_stand();};
void()	art_stand26	=[	$idle26,	art_stand27 ] {ai_stand();};
void()	art_stand27	=[	$idle27,	art_stand28 ] {ai_stand();};
void()	art_stand28	=[	$idle28,	art_stand1 ] {ai_stand();};


void()	art_walk1	=[	$walk1,		art_walk2	] {sound (self, CHAN_VOICE, "arachnotron/artwalk.wav", 1, ATTN_IDLE);ai_walk(8);};
void()	art_walk2	=[	$walk2,		art_walk3	] {ai_walk(4);};
void()	art_walk3	=[	$walk3,		art_walk4	] {ai_walk(2);};
void()	art_walk4	=[	$walk4,		art_walk5	] {ai_walk(0);};
void()	art_walk5	=[	$walk5,		art_walk6	] {ai_walk(10);};
void()	art_walk6	=[	$walk6,		art_walk7	] {ai_walk(10);};
void()	art_walk7	=[	$walk7,		art_walk8	] {sound (self, CHAN_VOICE, "arachnotron/artwalk.wav", 1, ATTN_IDLE);ai_walk(3);};
void()	art_walk8	=[	$walk8,		art_walk9	] {ai_walk(0);};
void()	art_walk9	=[	$walk9,		art_walk10	] {ai_walk(10);};
void()	art_walk10	=[	$walk10,	art_walk11	] {ai_walk(7);};
void()	art_walk11	=[	$walk11,	art_walk12	] {ai_walk(3);};
void()	art_walk12	=[	$walk12,	art_walk13	] {ai_walk(0);};
void()	art_walk13	=[	$walk13,	art_walk14	] {ai_walk(10);};
void()	art_walk14	=[	$walk14,	art_walk1	] {ai_walk(10);};

/*
void() check_onground = {
	if (self.flags & FL_ONGROUND)
		self.touch = SUB_Null;
	else	
		return;
}
*/

void()	art_run1	=[	$walk1,		art_run2	] {check_onground();ai_run(8); self.nextthink = time + 0.075; };
void()	art_run2	=[	$walk2,		art_run3	] {check_onground();ai_run(4); self.nextthink = time + 0.075;};
void()	art_run3	=[	$walk3,		art_run4	] {check_onground();ai_run(2); self.nextthink = time + 0.075; sound(self, CHAN_VOICE, "arachnotron/artwalk.wav", 1, ATTN_IDLE);};
void()	art_run4	=[	$walk4,		art_run5	] {check_onground();ai_run(0); self.nextthink = time + 0.075;};
void()	art_run5	=[	$walk5,		art_run6	] {check_onground();ai_run(10); self.nextthink = time + 0.075;};
void()	art_run6	=[	$walk6,		art_run7	] {check_onground();ai_run(10); self.nextthink = time + 0.075;};
void()	art_run7	=[	$walk7,		art_run8	] {check_onground();ai_run(3); self.nextthink = time + 0.075; };
void()	art_run8	=[	$walk8,		art_run9	] {check_onground();ai_run(0); self.nextthink = time + 0.075; sound(self, CHAN_VOICE, "arachnotron/artwalk.wav", 1, ATTN_IDLE);};
void()	art_run9	=[	$walk9,		art_run10	] {check_onground();ai_run(10); self.nextthink = time + 0.075;};
void()	art_run10	=[	$walk10,	art_run11	] {check_onground();ai_run(7); self.nextthink = time + 0.075;};
void()	art_run11	=[	$walk11,	art_run12	] {check_onground();ai_run(3); self.nextthink = time + 0.075;};
void()	art_run12	=[	$walk12,	art_run13	] {check_onground();ai_run(0); self.nextthink = time + 0.075; sound(self, CHAN_VOICE, "arachnotron/artwalk.wav", 1, ATTN_IDLE);};
void()	art_run13	=[	$walk13,	art_run14	] {check_onground();ai_run(10); self.nextthink = time + 0.075;};
void()	art_run14	=[	$walk14,	art_run1	] {check_onground();ai_run(10); self.nextthink = time + 0.075;};

void() art_die;

void()	art_die1	=[	$death1,	art_die2	] {sound (self, CHAN_VOICE, "arachnotron/artdeath.wav", 1, ATTN_NORM);};
void()	art_die2	=[	$death2,	art_die3	] {};
void()	art_die3	=[	$death3,	art_die4	] {self.solid = SOLID_TRIGGER; setorigin(self, self.origin);};
void()	art_die4	=[	$death4,	art_die5	] {};
void()	art_die5	=[	$death5,	art_die6	] {};
void()	art_die6	=[	$death6,	art_die7	] {};
void()	art_die7	=[	$death7,	art_die8	] {};
void()	art_die8	=[	$death8,	art_die9	] {};
void()	art_die9	=[	$death9,	art_die10	] {};
void()	art_die10	=[	$death10,	art_die11	] {};
void()	art_die11	=[	$death11,	art_die12	] {};
void()	art_die12	=[	$death12,	art_die13	] {};
void()	art_die13	=[	$death13,	art_die14	] {};
void()	art_die14	=[	$death14,	art_die15	] {};
void()	art_die15 	=[	$death15,	art_die16	] {};
void()	art_die16 	=[	$death16,	art_die17	] {};
void()	art_die17 	=[	$death17,	art_die18	] {/*sound(self, CHAN_WEAPON, "demon/dland2.wav", 1, ATTN_NORM);*/};
void()	art_die18 	=[	$death18,	art_die19	] {};
void()	art_die19 	=[	$death19,	art_die20	] {};
void()	art_die20 	=[	$death20,	art_die21 	] {};
void()	art_die21 	=[	$death21,	art_die22 	] {};
void()	art_die22 	=[	$death22,	art_die23 	] {};
void()	art_die23 	=[	$death23,	art_die24 	] {};
void()	art_die24	=[	$death24,	art_die24 	] {self.think = SUB_MakeNotSolid; self.nextthink = time + 5;};

void() art_die = {
	self.skin = 0;
	if (self.health < -50) {
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/arachnotron_gib_head.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		ThrowGib ("progs/arachnotron_gib_wholeleg.mdl", self.health);
		ThrowGib ("progs/arachnotron_gib_wholeleg.mdl", self.health);
		ThrowGib ("progs/arachnotron_gib_wholeleg.mdl", self.health);
		ThrowGib ("progs/arachnotron_gib_body.mdl", self.health);
		ThrowGib ("progs/arachnotron_gib_gun.mdl", self.health);

		//BecomeExplosion ();
		TriggerExplosion();
	}
	else {
		// regular death
		//self.skin = 2;
		art_die1();	
	}
};





void()	art_paina1	=[	$paina1,		art_paina2	] {};
void()	art_paina2	=[	$paina2,		art_paina3	] {};
void()	art_paina3	=[	$paina3,		art_paina4	] {};
void()	art_paina4	=[	$paina4,		art_paina5	] {};
void()	art_paina5	=[	$paina5,		art_paina6	] {};
void()	art_paina6	=[	$paina6,		art_paina7	] {};
void()	art_paina7	=[	$paina7,		art_paina8	] {};
void()	art_paina8	=[	$paina8,		art_paina9	] {};
void()	art_paina9	=[	$paina9,		art_paina10	] {};
void()	art_paina10	=[	$paina10,		art_paina11	] {};
void()	art_paina11	=[	$paina11,		art_run1	] {};

void()	art_painb1	=[	$painb1,	art_painb2	] {};
void()	art_painb2	=[	$painb2,	art_painb3	] {};
void()	art_painb3	=[	$painb3,	art_painb4	] {};
void()	art_painb4	=[	$painb4,	art_painb5	] {};
void()	art_painb5 	=[	$painb5,	art_painb6	] {};
void()	art_painb6 	=[	$painb6,	art_painb7	] {};
void()	art_painb7 	=[	$painb7,	art_painb8	] {};
void()	art_painb8 	=[	$painb8,	art_painb9	] {};
void()	art_painb9 	=[	$painb9,	art_painb10	] {};
void()	art_painb10	=[	$painb10,	art_painb11	] {};
void()	art_painb11	=[	$painb11,	art_painb12	] {};
void()	art_painb12	=[	$painb12,	art_painb13	] {};
void()	art_painb13	=[	$painb13,	art_painb14	] {};
void()	art_painb14	=[	$painb14,	art_painb15	] {};
void()	art_painb15 	=[	$painb15,	art_painb16	] {};
void()	art_painb16 	=[	$painb16,	art_painb17	] {};
void()	art_painb17 	=[	$painb17,	art_painb18	] {};
void()	art_painb18 	=[	$painb18,	art_painb19	] {};
void()	art_painb19 	=[	$painb19,	art_run1	] {};

void(entity attacker, float damage)	art_pain = {

	local float r;
	r = random();


	if (self.health <= 0)
		return;		// allready dying, don't go into pain frame

	if (random()*200 > damage)
		return;		// didn't flinch

	if (self.pain_finished > time)
		return;
	self.pain_finished = time + 2;

	self.yaw_speed = 20;
	self.skin = 0;

	if (r < 0.5) 	
		art_paina1();
	else
		art_painb1();

	sound(self, CHAN_VOICE, "arachnotron/artpain.wav", 1, ATTN_IDLE);
};


void() art_touch_jump = {
	if (other.classname == "player") {
		if (other.pain_finished > time)
			return;
	}

	if (other.takedamage) {
		T_Damage (other, self, self, 60);
		// stop the player from taking damage every frame
		other.pain_finished = time + 1;
	}
};



void()	art_leap1	=[	$leap1,		art_leap2	] {self.yaw_speed = 30;ai_face();};
void()	art_leap2	=[	$leap2,		art_leap3	] {ai_face();};
void()	art_leap3	=[	$leap3,		art_leap4	] {ai_face();};
void()	art_leap4	=[	$leap4,		art_leap5	] {ai_face();};
void()	art_leap5	=[	$leap5,		art_leap6	] {ai_face();};
void()	art_leap6	=[	$leap6,		art_leap7	] {ai_face();

	self.yaw_speed = 20;
	sound (self, CHAN_VOICE, "arachnofloyd/leap.wav", 1, ATTN_NORM);
	makevectors(self.angles);
	self.flags = self.flags - FL_ONGROUND;
	self.origin_z = self.origin_z + 16;
	self.velocity = '0 0 0';
	self.velocity = self.velocity + v_forward * 400;
	self.velocity_z = self.velocity_z + 275;
	self.touch = art_touch_jump;
};
void()	art_leap7	=[	$leap7,		art_leap8	] {check_onground();};
void()	art_leap8	=[	$leap8,		art_leap9	] {check_onground();};
void()	art_leap9	=[	$leap9,		art_leap10	] {check_onground();};
void()	art_leap10	=[	$leap10,	art_leap11	] {check_onground();};
void()	art_leap11 	=[	$leap11,	art_run1	] {self.attack_finished = time + 2; check_onground();};


void() artPlasmaTouch =
{
	local float damg;

	if (other == self.owner)
		return;   // don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY){
		remove(self);
		return;
	}
	damg = 15;

	if (other.health)
		T_Damage(other, self, self.owner, damg );
	

	// Moves the plasma bullet backwards after hitting.. Otherwise the 
	// explosion sprite would often be inside a wall or something. 
	self.origin = self.origin - 8*normalize(self.velocity);

	sound(self, CHAN_WEAPON, "weapons/dsfirxpl.wav", 1, ATTN_NORM);
	PlasmaExplosion();
};


void(vector org, vector dir) artPlasma = {
	newmis = spawn();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;
	newmis.classname = "plasma";
	newmis.flags = newmis.flags | FL_PROJECTILE;
	newmis.velocity = dir * 600;
	newmis.angles = vectoangles(newmis.velocity);
	newmis.avelocity = '300 300 300'; 

	newmis.touch = artPlasmaTouch;

	newmis.effects = EF_DIMLIGHT;

	setmodel(newmis, "progs/pbullet.mdl");
	setsize(newmis, '0 0 0', '0 0 0');
	setorigin(newmis, org);
};

void() art_fire = {
	local	vector	dir;
	local	entity	en;
	
	sound (self, CHAN_WEAPON, "arachnotron/artplasma.wav", 1, ATTN_NORM);	

	en = self.enemy;
	
	dir = en.origin + (en.velocity * clamp(vlen(self.origin - en.origin)/600, 0, 0.6));
	dir = normalize (dir - self.origin);
	
	makevectors(self.angles);

	artPlasma(self.origin + v_forward*32 - v_right*16 + v_up*0, dir);
	artPlasma(self.origin + v_forward*32 + v_right*16 + v_up*0, dir);
}

void() art_face_ahead =
{
	entity en = SUB_entEnemyTarget();

	self.ideal_yaw = vectoyaw(en.origin + (en.velocity * clamp(vlen(self.origin - en.origin)/600, 0, 1))/2 - self.origin);
	ChangeYaw ();
};

void()	art_light1	=[	$light1,		art_light2	] {ai_face(); self.cnt = 0; sound (self, CHAN_WEAPON, "arachnotron/artcharge.wav", 0.7, ATTN_NORM);};
void()	art_light2	=[	$light2,		art_light3	] {ai_face();};
void()	art_light3	=[	$light3,		art_light4	] {ai_face();};
void()	art_light4	=[	$light4,		art_light5	] {ai_face();};
void()	art_light5	=[	$light5,		art_light6	] {art_face_ahead();}; 
void()	art_light6	=[	$light6,		art_light7	] {art_face_ahead();}; // return here for repeated fire
void()	art_light7	=[	$light7,		art_light8	] {
	art_face_ahead();
	art_fire();
	if (self.cnt < 6) {
		self.cnt++;
		self.think = art_light6;
	}
	self.skin = 1;
};
void()	art_light8	=[	$light8,		art_light9	] {ai_face(); self.cnt = 0; self.skin = 0;};
void()	art_light9	=[	$light9,		art_light10	] {ai_face();};
void()	art_light10	=[	$light10,		art_light11	] {ai_face();};
void()	art_light11	=[	$light11,		art_light12	] {ai_face();};
void()	art_light12 =[	$light12,		art_run1	] {
	ai_face();
	self.attack_finished = time + 3;
};


/*
===========
artCheckAttack
============
*/
float() artCheckAttack = {
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
		if (CanDamage(self.enemy, self)) {
			if 	(dist > 200 && dist < 500) {
				if (random() < 0.33)
					self.attack_state = AS_MELEE;
				else
					self.attack_state = AS_MISSILE;
			}
			else {
				self.attack_state = AS_MISSILE;
			}
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

void() art_sight = {
	sound (self, CHAN_VOICE, "arachnotron/artsight.wav", 1, ATTN_NORM);
};


/*QUAKED monster_arachnofloyd (1 0 0) (-32 -32 -24) (32 32 48) Ambush
*/
void(entity e) monster_arachnotron_start = {
	local entity oself;

	oself = self;
	self = e;

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	self.classname = "monster_arachnotron";
	
	setmodel (self, "progs/arachnotron.mdl");
	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 24');
	else setsize (self, self.cmins, self.cmaxs);
	self.health = 500;
	self.bloodtype = SPAWN_BLOOD;

	self.th_stand = art_stand1;
	self.th_walk = art_walk1;
	self.th_run = art_run1;
	self.th_die = art_die;
	self.th_pain = art_pain;
	self.th_missile = art_light1;
	self.th_melee = art_leap1;
	self.th_sight = art_sight;
	self.th_checkattack = artCheckAttack;

	if (self.obituary == "") self.obituary = "was disintegrated by an Arachnotron";


	self.think = walkmonster_start;
	self.nextthink = time + 0.1 + random ()*0.1;	

	self = oself;
};

void() monster_arachnotron_spawner = {
	monster_spawner(monster_arachnotron_start);
};


void() monster_arachnotron = {
	if (deathmatch)	{
		remove(self);
		return;
	}

	precache_model("progs/arachnotron.mdl");
	precache_model("progs/arachnotron_gib_head.mdl");
	precache_model("progs/arachnotron_gib_wholeleg.mdl");
	precache_model("progs/arachnotron_gib_body.mdl");
	precache_model("progs/arachnotron_gib_gun.mdl");
	
	precache_sound("arachnofloyd/leap.wav");
	precache_sound("arachnotron/artsight.wav");
	precache_sound("arachnotron/artdeath.wav");
	precache_sound("arachnotron/artpain.wav");
	precache_sound("arachnotron/artwalk.wav");
	precache_sound("arachnotron/artplasma.wav");
	precache_sound("arachnotron/artcharge.wav");

	self.cmins = VEC_HULL2_MIN;
	self.cmaxs = VEC_HULL2_MAX;

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 24');
	else setsize (self, self.cmins, self.cmaxs);
	
	if (self.spawnflags & MONSTER_SPAWNER) {
		self.use = monster_arachnotron_spawner;
		monster_spawner_updatecounter();
	}
	else {
		monster_arachnotron_start(self);
	}
};

