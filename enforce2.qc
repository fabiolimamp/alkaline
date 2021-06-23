/*
============================================================================

Mega Enforcer

============================================================================
*/

$cd id1/models/enforcer
$origin 0 -6 24
$base base		
$skin skin

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9 walk10
$frame walk11 walk12 walk13 walk14 walk15 walk16

$frame run1 run2 run3 run4 run5 run6 run7 run8

$frame attack1 attack2 attack3 attack4 attack5 attack6
$frame attack7 attack8 attack9 attack10
$frame attack11 attack12 attack13 attack14 attack15 attack16
$frame attack17 attack18 attack19 attack20

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

$frame attackp1 attackp2 attackp3 attackp4 attackp5 attackp6 attackp7

$frame fieldon1 fieldon2 fieldon3 fieldon4 fieldon5 fieldon6 fieldon7

//dhm - prototype needed for new attack sequence
void() menf_atk13;
void() menf_atk1;
void() menf_satck1;
//where does sf64_teledeath function exist in the zer source code??
//void() sf64_teledeath;

.entity sibling;

//--------------------------------------------------------------------
void() DrunkExplode =
{
	T_RadiusDamage (self, self.owner, 30, world);
	sound (self, CHAN_VOICE, "weapons/r_exp3.wav", 1, ATTN_NORM);

	/*WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);*/

	self.velocity = '0 0 0';
	self.touch = SUB_Null;
	setmodel (self, "progs/s_explod.spr");

//DHM - fix for trigger_gravity movement
	self.movetype = MOVETYPE_FLYMISSILE;

	remove(self.sibling);
	self.solid = SOLID_NOT;
	s_explode1 ();
};


void() spiralthink = {
//	if (!infront(self.enemy))
//		return;

	local entity pointer;
	local vector vel;

	pointer = self.sibling;

	if (time > self.attack_finished) {
		DrunkExplode();
		remove(pointer);
		return;
	}
	
	if (vlen(self.enemy.origin - self.origin) < 256) {
		vel = normalize(self.enemy.origin - self.origin);
		self.velocity = vel * 250;
		self.angles = vectoangles(self.velocity);
		self.nextthink = time + 0.1;
		return;		
	}

	local float voffs, hoffs;

	if (self.cnt == 0) {
		voffs = 24;
		hoffs = 0;		
	}
	else if (self.cnt == 1) {
		voffs = 16;
		hoffs = 16;		
	}
	else if (self.cnt == 2) {
		voffs = 0;
		hoffs = 24;			
	}
	else if (self.cnt == 3) {
		voffs = -16;
		hoffs = 16;	
	} 			
	else if (self.cnt == 4) {
		voffs = -24;
		hoffs = 0;	
	} 
	else if (self.cnt == 5) {
		voffs = -16;
		hoffs = -16;	
	} 			
	else if (self.cnt == 6)	{
		voffs = 0;
		hoffs = -24;	
	} 
	else {
		voffs = 16;
		hoffs = -16;		
	} 
		
	if (vlen(self.origin - pointer.origin) < 16) {
//		dprint(ftos(vlen(self.origin - pointer.origin)));
//		dprint("\n");
		self.nextthink = time + 0.1;
		return;
	}
	else {
		self.cnt = self.cnt + 1;
	}
	

	if (self.cnt > 7)
		self.cnt = 0;

	self.velocity = '0 0 0';
	makevectors(pointer.velocity);
	vel = normalize((pointer.origin + v_right * hoffs + v_up * voffs) - self.origin);
	self.velocity = vel * 250;

	self.angles = vectoangles(self.velocity);
	self.think = spiralthink;
	self.nextthink = time + 0.1;

};



void() changemovetype = {
	self.movetype = MOVETYPE_FLYMISSILE;
	self.think = ShalHome;
	self.nextthink = time + 0.1;
}



//--------------------------------------------------------------------
// Missile will launch then spiral around an invisible point toward
// the player. The missile will track slowly and have a TTL
//--------------------------------------------------------------------



void() FireMissileSpiral = {
	local	entity missile, pointer;
	local	vector org, vel, vel2;
	
	self.effects = self.effects | EF_MUZZLEFLASH;

	sound (self, CHAN_WEAPON, "me/me_fire2.wav", 1, ATTN_NORM);
	
	makevectors(self.angles);	
	org = self.origin + '0 0 28' + (v_right * 6);
	
	pointer = spawn();
	pointer.owner = self;
	pointer.sibling = missile;
	pointer.enemy = self.enemy;
	pointer.movetype = MOVETYPE_BOUNCE;
	pointer.solid = SOLID_NOT;
//	setmodel(pointer, "progs/s_light.spr");	
	setorigin (pointer, org);	
	pointer.think = changemovetype;
	pointer.nextthink = time + 0.2;
	
	
	// set intial pointer velocity	
	vel = normalize(self.enemy.origin - self.origin);
	pointer.velocity = vel * 200;
	pointer.velocity_z = pointer.velocity_z + 250;
	// set v_right, etc
	makevectors(pointer.velocity);	
	pointer.angles = vectoangles(pointer.velocity);	
	
	missile = spawn();
	missile.owner = self;
	missile.sibling = pointer;
	missile.enemy = self.enemy;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX;
	missile.effects = EF_DIMLIGHT;
	missile.flags = missile.flags | FL_PROJECTILE;

	setorigin (missile, org);

	// set intial missile velocity	
	vel2 = normalize(pointer.origin + v_forward * 64 + v_up * 64 - missile.origin);
	missile.velocity = vel2 * 100;
	// set v_right, etc
	makevectors(missile.velocity);	
	missile.angles = vectoangles(missile.velocity);		
	
	// no harm in keeping this, but remember to delete the pointer on touch
	missile.touch = DrunkExplode;	
	
// set missile duration
	missile.nextthink = time + 0.05;
	missile.think = spiralthink;

	setmodel (missile, "progs/memissil.mdl");
	setsize (missile, '0 0 0', '0 0 0');		

	missile.attack_finished = time + 6;

}


void() particlethink = {
	particle (self.origin, self.oldorigin, 10, 30);
	particle (self.origin, self.oldorigin, 40, 30);
	self.nextthink = time + 0.05;
};

void() FireParticleBeam = {
	local vector org,mep;
	local	entity missile;
	local vector lead, spot;
	local float go;

	self.effects = self.effects | EF_MUZZLEFLASH;
	makevectors (self.angles);
	
	org = self.origin + v_forward * 30 + v_right * 8.5 + '0 0 16';

	sound (self, CHAN_WEAPON, "me/me_fire1.wav", 1, ATTN_NORM);
		
	missile = spawn ();
	missile.owner = self;
	missile.enemy = self.enemy;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX;
	missile.effects = EF_DIMLIGHT;     // it works now! - greenwood
	missile.angles = self.angles;     // new projectile code 
	missile.flags = missile.flags | FL_PROJECTILE;

	setmodel (missile, "progs/flaser.mdl");
	setorigin (missile, org);
	setsize (missile, '0 0 0', '0 0 0');  // end of new projectile code
		
// set missile speed	

	go = vlen(self.enemy.origin - org) / 500;
	mep = self.enemy.velocity;
	mep_z = 0;
	spot = self.enemy.origin + mep * go;

	traceline(org, spot, FALSE, world);
	if (trace_fraction < 0.8)
	{
		//dprint("Not a clear lead shot, shoot at player.\n");
		spot = self.enemy.origin;
	}

	lead = normalize(spot - org);

	missile.oldorigin = lead*5;	//particle direction?	

	missile.velocity = lead * 620;
	missile.angles = '0 0 0';			// more new projectile code
	missile.angles = vectoangles(missile.velocity); // end of more new projectile code
	missile.touch = Laser_Touch;
	missile.cnt = 1;
	
// set missile duration
	missile.nextthink = time + 0.05;
	missile.think = particlethink;

	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, org);
};

void() megaenforcer_fire = {
	local float edist;

	edist = vlen(self.enemy.origin - self.origin);
	if (edist < 200) menf_atk1();
	else {
		if (random() < 0.65 || edist > 700)	{
			if (time > self.attack_finished) menf_satck1();
			else menf_atk1();
		}
		else menf_atk1();
	}
};

void(float play_sound) menf_shield_on = {
	if (play_sound && self.takedamage != DAMAGE_NO) sound (self, 5, "me/me_son.wav", 1, ATTN_NORM); 
	self.takedamage = DAMAGE_NO;
};

void(float play_sound) menf_shield_off = {
	if (play_sound && self.takedamage != DAMAGE_AIM) sound (self, 6, "me/me_soff.wav", 1, ATTN_NORM);
	self.takedamage = DAMAGE_AIM;
};

//============================================================================

void()	menf_stand1	=[	$stand1,	menf_stand2	] {ai_stand();};
void()	menf_stand2	=[	$stand2,	menf_stand3	] {ai_stand();};
void()	menf_stand3	=[	$stand3,	menf_stand4	] {ai_stand();};
void()	menf_stand4	=[	$stand4,	menf_stand5	] {ai_stand();};
void()	menf_stand5	=[	$stand5,	menf_stand6	] {ai_stand();};
void()	menf_stand6	=[	$stand6,	menf_stand7	] {ai_stand();};
void()	menf_stand7	=[	$stand7,	menf_stand1	] {ai_stand();};

void()	menf_walk1	=[	$walk1 ,	menf_walk2	] {ai_walk(2);
	if (random() < 0.2) sound (self, CHAN_VOICE, "me/meidle.wav", 1, ATTN_IDLE);
};
void()	menf_walk2	=[	$walk2 ,	menf_walk3	] {ai_walk(4);};
void()	menf_walk3	=[	$walk3 ,	menf_walk4	] {ai_walk(4);};
void()	menf_walk4	=[	$walk4 ,	menf_walk5	] {ai_walk(3);};
void()	menf_walk5	=[	$walk5 ,	menf_walk6	] {ai_walk(1);};
void()	menf_walk6	=[	$walk6 ,	menf_walk7	] {ai_walk(2);};
void()	menf_walk7	=[	$walk7 ,	menf_walk8	] {ai_walk(2);};
void()	menf_walk8	=[	$walk8 ,	menf_walk9	] {ai_walk(1);};
void()	menf_walk9	=[	$walk9 ,	menf_walk10	] {ai_walk(2);};
void()	menf_walk10	=[	$walk10,	menf_walk11	] {ai_walk(4);};
void()	menf_walk11	=[	$walk11,	menf_walk12	] {ai_walk(4);};
void()	menf_walk12	=[	$walk12,	menf_walk13	] {ai_walk(1);};
void()	menf_walk13	=[	$walk13,	menf_walk14	] {ai_walk(2);};
void()	menf_walk14	=[	$walk14,	menf_walk15	] {ai_walk(3);};
void()	menf_walk15	=[	$walk15,	menf_walk16	] {ai_walk(4);};
void()	menf_walk16	=[	$walk16,	menf_walk1	] {ai_walk(2);};

void()	menf_shld1	=[	$fieldon1 ,	menf_shld2	] {};
void()	menf_shld2	=[	$fieldon2 ,	menf_shld3	] {};
void()	menf_shld3	=[	$fieldon3 ,	menf_shld4  ] {menf_shield_on(TRUE);};
void()	menf_shld4	=[	$fieldon4 ,	menf_shld5	] {};
void()	menf_shld5	=[	$fieldon5 ,	menf_shld6	] {};
void()	menf_shld6	=[	$fieldon6 ,	menf_shld7	] {};
void()	menf_shld7	=[	$fieldon7 ,	menf_run1	] {};



void()	menf_run1	=[	$run1  ,	menf_run2	] {ai_run(18);
	if (random() < 0.2)	sound (self, CHAN_VOICE, "me/meidle.wav", 1, ATTN_IDLE);
	menf_shield_on(TRUE);
};
void()	menf_run2	=[	$run2  ,	menf_run3	] {ai_run(14); menf_shield_on(FALSE);};
void()	menf_run3	=[	$run3  ,	menf_run4	] {ai_run(7);  menf_shield_on(FALSE);};
void()	menf_run4	=[	$run4  ,	menf_run5	] {ai_run(12); menf_shield_on(FALSE);};
void()	menf_run5	=[	$run5  ,	menf_run6	] {ai_run(14); menf_shield_on(FALSE);};
void()	menf_run6	=[	$run6  ,	menf_run7	] {ai_run(14); menf_shield_on(FALSE);};
void()	menf_run7	=[	$run7  ,	menf_run8	] {ai_run(7);  menf_shield_on(FALSE);};
void()	menf_run8	=[	$run8  ,	menf_run1	] {ai_run(11); menf_shield_on(FALSE);};



void()	menf_atk1	=[	$attack1,	menf_atk2	] {ai_face();
	
	if (random() < 0.3)	{
		self.think = menf_run1;
		self.movingback = 1;
		return;
	}

	//self.lastclose = 1;
	menf_shield_off(TRUE);
};
void()	menf_atk2	=[	$attack2,	menf_atk3	] {ai_face(); menf_shield_off(FALSE);};
void()	menf_atk3	=[	$attack3,	menf_atk4	] {ai_face(); menf_shield_off(FALSE);};
void()	menf_atk4	=[	$attack4,	menf_atk7	] {ai_face(); menf_shield_off(FALSE);};
/*
void()	menf_atk5	=[	$attack5,	menf_atk6	] {ai_face();};
void()	menf_atk6	=[	$attack6,	menf_atk7	] { skip};
*/
void()	menf_atk7	=[	$attack7,	menf_atk8	] {ai_face(); menf_shield_off(FALSE);};
void()	menf_atk8	=[	$attack8,	menf_atk9	] {ai_face(); menf_shield_off(FALSE);};
void()	menf_atk9	=[	$attack5,	menf_atk10	] {ai_face(); self.oldorigin = self.enemy.origin; menf_shield_off(FALSE);};
void()	menf_atk10	=[	$attack6,	menf_atk11	] {FireParticleBeam(); menf_shield_off(FALSE);};
void()	menf_atk11	=[	$attack7,	menf_atk12	] {ai_face(); menf_shield_off(FALSE);};
void()	menf_atk12	=[	$attack8,	menf_atk13	] {ai_face(); menf_shield_off(FALSE); sound (self, 5, "me/me_son.wav", 1, ATTN_NORM); };
void()	menf_atk13	=[	$attack9,	menf_atk14	] {ai_face(); menf_shield_off(FALSE);};
void()	menf_atk14	=[	$attack10,	menf_run1	] {ai_face(); SUB_CheckRefire (menf_atk1); menf_shield_on(FALSE);};



void()	menf_satck1 =[	$attackp1,  menf_satck2 ] {ai_face(); menf_shield_off(TRUE);};
void()	menf_satck2 =[	$attackp2,  menf_satck3 ] {ai_face(); menf_shield_off(FALSE);};
void()	menf_satck3 =[	$attackp2,  menf_satck4 ] {ai_face(); menf_shield_off(FALSE);};
void()	menf_satck4 =[	$attackp3,  menf_satck5 ] {ai_face(); menf_shield_off(FALSE);};
void()	menf_satck5 =[	$attackp4,  menf_satck6 ] {ai_face(); menf_shield_off(FALSE);};
void()	menf_satck6 =[	$attackp4,  menf_satck7 ] {ai_face(); menf_shield_off(FALSE);};
void()	menf_satck7 =[	$attackp5,  menf_satck8 ] {ai_face(); FireMissileSpiral (); self.attack_finished = time + 1.5; menf_shield_off(FALSE);};
void()	menf_satck8 =[	$attackp6,  menf_satck9 ] {ai_face(); menf_shield_off(FALSE); sound (self, 5, "me/me_son.wav", 1, ATTN_NORM); };
void()	menf_satck9 =[	$attackp7,  menf_run1   ] {ai_face(); menf_shield_on(FALSE);};



void()	menf_paina1	=[	$paina1,	menf_paina2	] {};
void()	menf_paina2	=[	$paina2,	menf_paina3	] {};
void()	menf_paina3	=[	$paina3,	menf_paina4	] {};
void()	menf_paina4	=[	$paina4,	menf_run1	] {};

void()	menf_painb1	=[	$painb1,	menf_painb2	] {};
void()	menf_painb2	=[	$painb2,	menf_painb3	] {};
void()	menf_painb3	=[	$painb3,	menf_painb4	] {};
void()	menf_painb4	=[	$painb4,	menf_painb5	] {};
void()	menf_painb5	=[	$painb5,	menf_run1	] {};

void()	menf_painc1	=[	$painc1,	menf_painc2	] {};
void()	menf_painc2	=[	$painc2,	menf_painc3	] {};
void()	menf_painc3	=[	$painc3,	menf_painc4	] {};
void()	menf_painc4	=[	$painc4,	menf_painc5	] {};
void()	menf_painc5	=[	$painc5,	menf_painc6	] {};
void()	menf_painc6	=[	$painc6,	menf_painc7	] {};
void()	menf_painc7	=[	$painc7,	menf_painc8	] {};
void()	menf_painc8	=[	$painc8,	menf_run1	] {};

void()	menf_paind1	=[	$paind1,	menf_paind2	] {};
void()	menf_paind2	=[	$paind2,	menf_paind3	] {};
void()	menf_paind3	=[	$paind3,	menf_paind4	] {};
void()	menf_paind4	=[	$paind4,	menf_paind5	] {ai_painforward(2);};
void()	menf_paind5	=[	$paind5,	menf_paind6	] {ai_painforward(1);};
void()	menf_paind6	=[	$paind6,	menf_paind7	] {};
void()	menf_paind7	=[	$paind7,	menf_paind8	] {};
void()	menf_paind8	=[	$paind8,	menf_paind9	] {};
void()	menf_paind9	=[	$paind9,	menf_paind10	] {};
void()	menf_paind10	=[	$paind10,	menf_paind11	] {};
void()	menf_paind11	=[	$paind11,	menf_paind12	] {ai_painforward(1);};
void()	menf_paind12	=[	$paind12,	menf_paind13	] {ai_painforward(1);};
void()	menf_paind13	=[	$paind13,	menf_paind14	] {ai_painforward(1);};
void()	menf_paind14	=[	$paind14,	menf_paind15	] {};
void()	menf_paind15	=[	$paind15,	menf_paind16	] {};
void()	menf_paind16	=[	$paind16,	menf_paind17	] {ai_pain(1);};
void()	menf_paind17	=[	$paind17,	menf_paind18	] {ai_pain(1);};
void()	menf_paind18	=[	$paind18,	menf_paind19	] {};
void()	menf_paind19	=[	$paind19,	menf_run1	] {};

void(entity attacker, float damage)	menf_pain =
{
	local float r;


	if (self.pain_finished > time || self.health > 120)
		return;

	r = random ();
	
	if (r < 0.3)
		sound (self, CHAN_VOICE, "me/mepain1.wav", 1, ATTN_NORM);
	else if (r < 0.6)
		sound (self, CHAN_VOICE, "me/mepain2.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_VOICE, "me/mepain3.wav", 1, ATTN_NORM);

	r = random ();

	if (r < 0.2)
	{
		self.pain_finished = time + 1;
		menf_paina1 ();
	}
	else if (r < 0.4)
	{
		self.pain_finished = time + 1;
		menf_painb1 ();
	}
	else if (r < 0.6)
	{
		self.pain_finished = time + 1;
		menf_painc1 ();
	}
	else if (r < 0.85 && self.health < 75)
	{
		self.pain_finished = time + 2;
		menf_paind1 ();
	}
};

//============================================================================




void()	menf_die1	=[	$death1,	menf_die2	] {};
void()	menf_die2	=[	$death2,	menf_die3	] {};
void()	menf_die3	=[	$death3,	menf_die4	] {self.solid = SOLID_TRIGGER; setorigin(self, self.origin);self.ammo_cells = 5;DropBackpack();};
void()	menf_die4	=[	$death4,	menf_die5	] {ai_forward(14);};
void()	menf_die5	=[	$death5,	menf_die6	] {ai_forward(2);};
void()	menf_die6	=[	$death6,	menf_die7	] {};
void()	menf_die7	=[	$death7,	menf_die8	] {};
void()	menf_die8	=[	$death8,	menf_die9	] {};
void()	menf_die9	=[	$death9,	menf_die10	] {ai_forward(3);};
void()	menf_die10	=[	$death10,	menf_die11	] {ai_forward(5);};
void()	menf_die11	=[	$death11,	menf_die12	] {ai_forward(5);};
void()	menf_die12	=[	$death12,	menf_die13	] {ai_forward(5);};
void()	menf_die13	=[	$death13,	menf_die14	] {};
void()	menf_die14	=[	$death14,	menf_die14	] {self.think = SUB_MakeNotSolid; self.nextthink = time + 5;};

void()	menf_fdie1	=[	$fdeath1,	menf_fdie2	] {};
void()	menf_fdie2	=[	$fdeath2,	menf_fdie3	] {};
void()	menf_fdie3	=[	$fdeath3,	menf_fdie4	] {self.solid = SOLID_TRIGGER; setorigin(self, self.origin);self.ammo_cells = 5;DropBackpack();};
void()	menf_fdie4	=[	$fdeath4,	menf_fdie5	] {};
void()	menf_fdie5	=[	$fdeath5,	menf_fdie6	] {};
void()	menf_fdie6	=[	$fdeath6,	menf_fdie7	] {};
void()	menf_fdie7	=[	$fdeath7,	menf_fdie8	] {};
void()	menf_fdie8	=[	$fdeath8,	menf_fdie9	] {};
void()	menf_fdie9	=[	$fdeath9,	menf_fdie10	] {};
void()	menf_fdie10	=[	$fdeath10,	menf_fdie11	] {};
void()	menf_fdie11	=[	$fdeath11,	menf_fdie11	] {self.think = SUB_MakeNotSolid; self.nextthink = time + 5;};


void() menf_die =
{
// check for gib
	if (self.health < -35)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_me.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		return;
	}

// regular death
	if (random() > 0.5)
	{
		sound (self, CHAN_VOICE, "me/medeath2.wav", 1, ATTN_NORM);
		menf_die1 ();
	}
	else
	{
		sound (self, CHAN_VOICE, "me/medeath1.wav", 1, ATTN_NORM);
		menf_fdie1 ();
	}
};

void() menf_sight = {
	local float rsnd;
	rsnd = rint(random() * 2);			
	if (rsnd == 1)
		sound (self, CHAN_VOICE, "me/mesight1.wav", 1, ATTN_NORM);
	else if (rsnd == 2)
		sound (self, CHAN_VOICE, "me/mesight2.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_VOICE, "me/mesight3.wav", 1, ATTN_NORM);
};

/*QUAKED monster_me (1 0 0) (-16 -16 -24) (16 16 40) Ambush

*/
void(entity e) monster_me_start =
{
	local entity oself;

	oself = self;
	self = e;

	self.th_stand = menf_stand1;
	self.th_walk = menf_walk1;
	self.th_run = menf_shld1;
	self.th_pain = menf_pain;
	self.th_die = menf_die;
	self.th_missile = megaenforcer_fire;
	self.th_sight = menf_sight;


	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/enforce2.mdl");

	setsize (self, '-16 -16 -24', '16 16 40');
	self.health = 150;

	walkmonster_start();
	self.takedamage = DAMAGE_NO;
	dprint("shield on\n");

	self = oself;
};

void() monster_me_spawner = {
	monster_spawner(monster_me_start);
};


void() monster_me =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model2 ("progs/enforce2.mdl");
	// for debugging
	precache_model2 ("progs/s_light.spr");
	precache_model2 ("progs/h_me.mdl");
	precache_model2 ("progs/memissil.mdl");
	precache_model2 ("progs/flaser.mdl");	   // borrowed Floyd's projectile - greenwood

	precache_sound2 ("me/medeath1.wav");
	precache_sound2 ("me/medeath2.wav");
	precache_sound2 ("me/me_fire1.wav");
	precache_sound2 ("me/me_fire2.wav");
	precache_sound2 ("me/meidle.wav");
	precache_sound2 ("enforcer/enfstop.wav");
	precache_sound2 ("me/mepain1.wav");
	precache_sound2 ("me/mepain2.wav");
	precache_sound2 ("me/mepain3.wav");
	precache_sound2 ("me/mesight1.wav");
	precache_sound2 ("me/mesight2.wav");
	precache_sound2 ("me/mesight3.wav");
	precache_sound2 ("me/me_son.wav");
	precache_sound2 ("me/me_soff.wav");

	setsize (self, '-16 -16 -24', '16 16 40');
	
	if (self.spawnflags & MONSTER_SPAWNER) {
		self.use = monster_me_spawner;
		monster_spawner_updatecounter();
	}
	else {
		monster_me_start(self);
	}
};
