/*==============================================================================
GARGOYLE / IMP (Hexen2 Model)
Ported from AD
==============================================================================*/

float MON_GARGOYLE_PERCH = 4;

// Fall on back to ground
$frame death1 death2 death3 death4 death5 death6 death7 death8
$frame death9 death10 death11 death12 death13 death14

// Single attack routine, fling fireball
$frame attack1 attack2 attack3 attack4 attack5 attack6 attack7 attack8
$frame attack9 attack10 attack11 attack12 attack13 attack14 attack15 attack16
$frame attack17 attack18 attack19 attack20 attack21

// Classic idle
$frame fly1 fly2 fly3 fly4 fly5 fly6 fly7 fly8
$frame fly9 fly10 fly11 fly12 fly13 fly14 fly15 fly16
$frame fly17 fly18 fly19 fly20

// Special minion grow animation
// Removed excessive frames (0.05 timing)
$frame grow1 grow2 grow3 grow4 grow5 grow6 grow7 grow8 grow9 grow10

// Move from perch to flying (can be reversed)
$frame flyup1 flyup2 flyup3 flyup4 flyup5 flyup6 flyup7 flyup8
$frame flyup9 flyup10 flyup11 flyup12 flyup13 flyup14 flyup15 flyup16
$frame flyup17 flyup18 flyup19 flyup20 flyup21 flyup22 flyup23

// Idle animation for perching (sitting down)
$frame perch1 perch2 perch3 perch4 perch5 perch6 perch7 perch8
$frame perch9 perch10 perch11 perch12 perch13 perch14 perch15 perch16
$frame perch17 perch18 perch19 perch20 perch21 perch22 perch23 perch24

// Going into a nosedive
$frame swoop1 swoop2 swoop3 swoop4 swoop5 swoop6 swoop7 swoop8
$frame swoop9 swoop10 swoop11 swoop12 swoop13 swoop14 swoop15 swoop16
$frame swoop17 swoop18 swoop19 swoop20

// Swooshing through the air!
$frame swooploop1 swooploop2 swooploop3 swooploop4

// Nose up, back to fly idling
$frame swoopend1 swoopend2 swoopend3 swoopend4 swoopend5 swoopend6 swoopend7 swoopend8
$frame swoopend9 swoopend10 swoopend11 swoopend12 swoopend13 swoopend14 swoopend15

// Alternative to stop swooping
$frame swoopout1 swoopout2 swoopout3 swoopout4 swoopout5 swoopout6 swoopout7 swoopout8
$frame swoopout9 swoopout10 swoopout11 swoopout12 swoopout13 swoopout14 swoopout15

//======================================================================

void() gargoylewings = {
	sound(self, CHAN_ITEM, "gargoyle/wings1.wav", 1, ATTN_IDLE);
};


void() garg_idlesound = {
	if (self.idletimer > time)
		return;

	if (!(self.flags & FL_FLY)) {
		if (random() < 0.5) sound(self, CHAN_VOICE, "gargoyle/perch1.wav", 1, ATTN_NORM);
		else sound(self, CHAN_VOICE, "gargoyle/perch2.wav", 1, ATTN_NORM);
	}
	else {
		sound(self, CHAN_VOICE, "gargoyle/idle1.wav", 1, ATTN_NORM);
	}

	self.idletimer = time + 5 + (random() * 3);
	
}

//======================================================================

float() GargoyleCheckAttack =
{
	// Cannot see enemy? stop chasing enemytarget
	if (!enemy_vis) {
		SUB_switchEnemyTarget();
		return FALSE;
	}
	//----------------------------------------------------------------------
	// setup enemytarget if one is not active
	//----------------------------------------------------------------------
	if (self.enemy.type != "enemytarget") {
		if (SUB_setupEnemyTarget(self.enemy, self.above, MONAI_ABOVETIMER)) {
			self.enemy = self.enemytarget;
		}
	}
	//----------------------------------------------------------------------
	// Range attack (Fireball)
	//----------------------------------------------------------------------
	// Only range attack if cooldown has finished
	if (time > self.attack_finished) {
		if (enemy_range == RANGE_MELEE) self.attack_chance = 0.9;		// range < 120 map units
		else if (enemy_range == RANGE_NEAR) self.attack_chance = 0.6;	// range < 500 map units
		else if (enemy_range == RANGE_MID) self.attack_chance = 0.2;	// range < 1000 map units
		else self.attack_chance = 0;
		if (random () < self.attack_chance) {
			//if (!visblocked_wide(SUB_entEnemyTarget(), self.attack_offset, '0 0 0')) {
			if (canshoot(SUB_entEnemyTarget())) {
				if (enemy_range != RANGE_MELEE)	SUB_AttackFinished(2 + random());
				self.attack_state = AS_MISSILE;
				return TRUE;
			}
		}
	}
	
	//----------------------------------------------------------------------
	// Make sure the gargoyle maintains its distance (strafe)
	//----------------------------------------------------------------------
	if (enemy_range >= RANGE_MID) {
		if (self.attack_state != AS_STRAIGHT) self.attack_state = AS_STRAIGHT;
	}
	else self.attack_state = AS_SLIDING;
	return FALSE;
};



void() garg_fbfinish;
//======================================================================
void()	garg_idle1	=[	$fly2,	garg_idle2	] {garg_idlesound();ai_stand();};
void()	garg_idle2	=[	$fly4,	garg_idle3	] {ai_stand();};
void()	garg_idle3	=[	$fly6,	garg_idle4	] {gargoylewings();ai_stand();};
void()	garg_idle4	=[	$fly8,	garg_idle5	] {ai_stand();};
void()	garg_idle5	=[	$fly10,	garg_idle6	] {ai_stand();};
void()	garg_idle6	=[	$fly12,	garg_idle7	] {ai_stand();};
void()	garg_idle7	=[	$fly14,	garg_idle8	] {ai_stand();};
void()	garg_idle8	=[	$fly16,	garg_idle9	] {ai_stand();};
void()	garg_idle9	=[	$fly18,	garg_idle10	] {ai_stand();};
void()	garg_idle10	=[	$fly20,	garg_idle1	] {ai_stand();};

//======================================================================
void()	garg_walk1	=[	$fly1,	garg_walk2	] {garg_idlesound();ai_walk(8);};
void()	garg_walk2	=[	$fly3,	garg_walk3	] {ai_walk(8);};
void()	garg_walk3	=[	$fly5,	garg_walk4	] {gargoylewings();ai_walk(8);};
void()	garg_walk4	=[	$fly7,	garg_walk5	] {ai_walk(8);};
void()	garg_walk5	=[	$fly9,	garg_walk6	] {ai_walk(8);};
void()	garg_walk6	=[	$fly11,	garg_walk7	] {ai_walk(8);};
void()	garg_walk7	=[	$fly13,	garg_walk8	] {ai_walk(8);};
void()	garg_walk8	=[	$fly15,	garg_walk9	] {ai_walk(8);};
void()	garg_walk9	=[	$fly17,	garg_walk10	] {ai_walk(8);};
void()	garg_walk10	=[	$fly19,	garg_walk1	] {ai_walk(8);};

//======================================================================
void()	garg_run1	=[	$fly1,	garg_run2	] {garg_idlesound();
	if (self.sibling && self.sibling.state == STATE_ON) garg_fbfinish();
	// Switch direction of strafing (random duration)
	if (self.meleeattack < time) {
		self.meleeattack = time + 4 + (random() + random() + random() * 4);
		self.lefty = rint(1 - self.lefty);
	}
	ai_run(4);
};
void()	garg_run2	=[	$fly3,	garg_run3	] {ai_run(5);};
void()	garg_run3	=[	$fly5,	garg_run4	] {gargoylewings(); ai_run(6);};
void()	garg_run4	=[	$fly7,	garg_run5	] {ai_run(7);};
void()	garg_run5	=[	$fly9,	garg_run6	] {ai_run(8);};
void()	garg_run6	=[	$fly11,	garg_run7	] {ai_run(4);};
void()	garg_run7	=[	$fly13,	garg_run8	] {ai_run(5);};
void()	garg_run8	=[	$fly15,	garg_run9	] {ai_run(6);};
void()	garg_run9	=[	$fly17,	garg_run10	] {ai_run(7);};
void()	garg_run10	=[	$fly19,	garg_run1	] {ai_run(8);};

//============================================================================
// Range attack
//============================================================================

//======================================================================
// Most of the monsters have an attack_offset setup to spawn their
// proejctiles in the right location relative to their gun model
// This function expects the makevectors has been done already
// makevectors (self.angles); <--- if missing, vector will be rubbish!
//----------------------------------------------------------------------
vector(vector attack_dir) attack_vector =
{
	local vector retvec;
	retvec = v_forward * attack_dir_x;
	retvec = retvec + (v_right * attack_dir_y);
	retvec = retvec + (v_up * attack_dir_z);
	return retvec;
};

void() garg_fbthrow =
{
	local vector org, dir;
	local float spd;
	
	makevectors (self.angles);
	org = self.origin + attack_vector('16 28 22');
	dir = normalize(SUB_orgEnemyTarget() - org);
	spd = 500 + (startskill * 150);
	
	//Launch_Missile (org, dir, '0 0 0', CT_PROJ_GARG, self.attack_speed);

	launch_rocket(org, dir);

	newmis.damagetype = DMGTYPE_BURN_LONG;
	newmis.velocity = dir * spd;
	setmodel(newmis, "progs/proj_gargball.mdl");
	setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);
	newmis.dmg = 10 + random()*10;
};

//----------------------------------------------------------------------
void() garg_fbfinish =
{
	setmodel(self.sibling, "");
	self.sibling.state = STATE_OFF;
};

//----------------------------------------------------------------------
void(float fbframe, vector fbofs) garg_fbupdate =
{
	if (self.health < 1) return;
	if (!self.sibling) {
		self.sibling = spawn();
		self.sibling.owner = self;
		self.sibling.classname = "fireball";
		self.sibling.mdl = "progs/proj_gargball.mdl";
		self.sibling.alpha = 0.85;
	}
	
	if (fbframe == 0) {
		self.sibling.state = STATE_ON;
		self.pain_finished = time + 1.5;		//don't go into pain whilst firing
		setorigin(self.sibling, self.origin);
		setmodel(self.sibling, self.sibling.mdl);
		setsize (self.sibling, VEC_ORIGIN, VEC_ORIGIN);
		self.sibling.movetype = MOVETYPE_NONE;
		self.sibling.solid = SOLID_NOT;
		sound (self, CHAN_WEAPON, "gargoyle/attack1.wav", 1, ATTN_NORM);
	}

	ai_face();					// Turn towards enemy
	makevectors(self.angles);
	self.sibling.origin = self.origin + v_forward*fbofs_x + v_right*fbofs_y;
	self.sibling.origin_z = self.sibling.origin_z + fbofs_z;
	setorigin(self.sibling, self.sibling.origin);
	self.sibling.angles = self.angles;
	self.sibling.frame = fbframe;
};



//----------------------------------------------------------------------
// Original offset position for gargoyle fireball (designed for a sprite)
// 10 16 0, 4 24 2, -7 28 15, -25 26 28, -38 12 45, -38 9 45, -17 36 30, 24 16 10
// Changed the offset to match the new model instead
// Positioned the fireball to match the hand orientation
//----------------------------------------------------------------------
void() garg_fire1	=[ $attack2, garg_fire2 ] {garg_fbupdate(0,'10 16 -2');};
void() garg_fire2	=[ $attack4, garg_fire3 ] {garg_fbupdate(2,'0 20 -2');};
void() garg_fire3	=[ $attack6, garg_fire4 ] {garg_fbupdate(3,'-6 23 6');gargoylewings();};
void() garg_fire4	=[ $attack8, garg_fire5 ] {garg_fbupdate(4,'-16 26 18');};
void() garg_fire5	=[ $attack10, garg_fire6 ] {garg_fbupdate(5,'-29 18 38');};
void() garg_fire6	=[ $attack12, garg_fire7 ] {garg_fbupdate(4,'-34 9 45');};
void() garg_fire7	=[ $attack14, garg_fire8 ] {garg_fbupdate(3,'-32 22 38');};
void() garg_fire8	=[ $attack16, garg_fire9 ] {garg_fbfinish();garg_fbthrow();};
void() garg_fire9	=[ $attack18, garg_fire10 ] {ai_face();garg_idlesound();};
void() garg_fire10	=[ $attack20, garg_run1 ] {ai_face();
	// If enemy really close, goto into a frenzy of fireball attacks
	self.enemydist = range_distance(SUB_entEnemyTarget(), FALSE);
	if (SUB_healthEnemyTarget() > 0 && self.enemydist < 192) self.think = garg_fire1;
	else self.attack_state = AS_STRAIGHT;
};

//============================================================================
// PERCH + WAKEUP
//============================================================================
void()	garg_perch1	=[	$perch2,	garg_perch2	] {garg_idlesound(); ai_stand();};
void()	garg_perch2	=[	$perch4,	garg_perch3	] {ai_stand();};
void()	garg_perch3	=[	$perch6,	garg_perch4	] {ai_stand();};
void()	garg_perch4	=[	$perch8,	garg_perch5	] {ai_stand();};
void()	garg_perch5	=[	$perch10,	garg_perch6	] {ai_stand();};
void()	garg_perch6	=[	$perch12,	garg_perch7	] {ai_stand();};
void()	garg_perch7	=[	$perch14,	garg_perch8	] {ai_stand();};
void()	garg_perch8	=[	$perch16,	garg_perch9	] {ai_stand();};
void()	garg_perch9	=[	$perch18,	garg_perch10	] {ai_stand();};
void()	garg_perch10=[	$perch20,	garg_perch11	] {ai_stand();};
void()	garg_perch11=[	$perch22,	garg_perch12	] {ai_stand();};
void()	garg_perch12=[	$perch24,	garg_perch1	] {ai_stand();};

//----------------------------------------------------------------------
// Sightsound and very quick animation while moving forward
void()	garg_wakeup1	=[	$flyup2,	garg_wakeup2	] {ai_forward(1);};
void()	garg_wakeup2	=[	$flyup4,	garg_wakeup3	] {ai_forward(4);};
void()	garg_wakeup3	=[	$flyup6,	garg_wakeup4	] {ai_forward(8);};
void()	garg_wakeup4	=[	$flyup14,	garg_wakeup5	] {ai_forward(8);gargoylewings();};
void()	garg_wakeup5	=[	$flyup16,	garg_wakeup6	] {ai_forward(4);};
void()	garg_wakeup6	=[	$flyup20,	garg_run1	] {HuntTarget();};

//----------------------------------------------------------------------
void() gargoyle_wakeup =
{
	//dprint("wake up!\n");
	// Dead already?
	if (self.health <= 0) return;

	// No longer perched on the ground
	self.spawnflags = self.spawnflags - (self.spawnflags & MON_GARGOYLE_PERCH);
	
	//self.takedamage = DAMAGE_AIM;		// Can receive damage
	//self.use = SUB_Null;				// no re-trigger
	
	// Restore all think state functions
	self.th_stand = garg_idle1;
	self.th_walk = garg_walk1;
	self.th_run = garg_run1;
	self.th_missile = garg_fire1;


	// Allow gargoyle to fly up, no more ground checks
	self.flags = self.flags | FL_FLY;
	self.movetype = MOVETYPE_STEP;
	self.pain_finished = time + 1.5;		// No pain
	self.attack_finished = 1.5 + random();	// No skill adjustment
	garg_wakeup1();
};



//============================================================================
// The gargoyle does not have a specific pain animation
// - Kinn created one from the death animation (Marcher progs)
void()	garg_pain1	=[	$death3,	garg_pain2	] {};
void()	garg_pain2	=[	$death4,	garg_pain3	] {};
void()	garg_pain3	=[	$death3,	garg_pain4	] {};
void()	garg_pain4	=[	$death2,	garg_pain5	] {};
void()	garg_pain5	=[	$death1,	garg_run1	] {};

//----------------------------------------------------------------------
void(entity attacker, float damage) garg_pain =
{
	// Check for perching gargoyles, need special wakeup
	/*if (self.spawnflags & MON_GARGOYLE_PERCH) {
		gargoyle_wakeup();
		return;
	}*/

	// make sure any fireball is hidden
	if (self.sibling) garg_fbfinish();

	if (random() < 0.5) sound (self, CHAN_VOICE, "gargoyle/pain75.wav", 1, ATTN_NORM);
	else sound (self, CHAN_VOICE, "gargoyle/pain100.wav", 1, ATTN_NORM);

	if (random()*70 > damage)
		return;		// didn't flinch
	
	garg_pain1 ();
};

//============================================================================
void()	garg_death1	=[	$death1,	garg_death2	] {};
void()	garg_death2	=[	$death3,	garg_death3	] {};
void()	garg_death3	=[	$death5,	garg_death4	] {self.solid = SOLID_TRIGGER; setorigin(self, self.origin);};
void()	garg_death4	=[	$death7,	garg_death5	] {};
void()	garg_death5	=[	$death9,	garg_death6	] {};
void()	garg_death6	=[	$death11,	garg_death7	] {};
void()	garg_death7	=[	$death13,	garg_death8	] {};
void()	garg_death8	=[	$death14,	garg_death8	] {self.think = SUB_MakeNotSolid; self.nextthink = time + 5;};

//----------------------------------------------------------------------
void() garg_die =
{	
	// Make sure any wings sound is silenced
	sound (self, CHAN_ITEM, "misc/null.wav", 1, ATTN_NORM);

	// If creating a Fireball, make it explode!
	if (self.sibling) {
		if (self.sibling.state == STATE_ON) {
			/*self.gibondeath = TRUE;
			SpawnProjectileSmoke(self.origin, 200, 50, 150);
			SpawnProjectileSmoke(self.origin, 200, 50, 150);
			self.lip = PARTICLE_BURST_FIRE;
			particle_explode(self.origin-'0 0 16', 50+random()*50, 2, self.lip, PARTICLE_BURST_UPWARD);
			makevectors(self.angles);
			self.oldorigin = self.origin + v_forward*8;
			self.lip = EXPLODE_BIG;
			SpawnExplosion(self.lip, self.oldorigin, SOUND_REXP3);*/
		}
		// make sure any fireball is hidden
		garg_fbfinish();
	}

	// Perching gargoyles need to blow up in gibs
	// In an awkward pose that does not go well into death animations
	if (self.health < -70 || self.spawnflags & MON_GARGOYLE_PERCH) {

		ThrowHead("progs/h_gargoyle.mdl", self.health);
		ThrowGib ("progs/gib_gargwing1.mdl", self.health);
		ThrowGib ("progs/gib_gargwing2.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		return;
	}
	
	sound (self, CHAN_VOICE, "gargoyle/death1.wav", 1, ATTN_NORM);

	self.flags = self.flags - (self.flags & FL_ONGROUND);
	self.velocity_x = -200 + 400*random();
	self.velocity_y = -200 + 400*random();
	self.velocity_z = 100 + 100*random();
	garg_death1 ();
};


void() garg_sight = {
	sound (self, CHAN_VOICE, "gargoyle/sight1.wav", 1, ATTN_NORM);
};

/*======================================================================
QUAKED monster_gargoyle (0.8 0 0.2) (-16 -16 -24) (16 16 40) AMBUSH STATUE PERCH NOSIGHT NOIDLE NOGFX STARTOFF ANGRY Not_Easy Not_Normal Not_Hard Not_DM
{ model(":progs/mon_gargoyle.mdl"); }
Gargoyle, 120 health points.
-------- KEYS --------
-------- SPAWNFLAGS --------
STATUE : Stone statue until triggered (always starts in a perched position)
PERCH : Start in a sitting down, place 44 units out from perching edge, 4 units higher

======================================================================*/

void(entity e) monster_gargoyle_start =
{
	local entity oself;

	oself = self;
	self = e;

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;


	self.health = 120;

	self.above = zeroconvertdefault(self.above, 128); // Custom height
	if (self.obituary == "") self.obituary = "was burned by a Gargoyle";

	setmodel (self, "progs/mon_gargoyle.mdl");

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize(self, self.cmins, self.cmaxs);

	self.bloodtype = SPAWN_BLOOD;
	

	self.th_checkattack = GargoyleCheckAttack;
	self.th_pain = garg_pain; 
	self.th_die = garg_die;
	self.th_sight = garg_sight;
	self.th_run = garg_run1;
	self.th_missile = garg_fire1;

	//----------------------------------------------------------------------
	// Perched Gargoyles have special idle animation + idle sounds
	// The AI needs to be setup 40 units forward and 24 units up
	// to be positioned feet flat on perch surface
	if (self.spawnflags & MON_GARGOYLE_PERCH) {
		self.th_stand = garg_perch1;
		self.th_walk = garg_perch1;
		self.th_wake = gargoyle_wakeup;
	}
	else {
		self.th_stand = garg_idle1;
		self.th_walk = garg_walk1;
	}
	
	flymonster_start ();

	//if (self.spawnflags & MON_GARGOYLE_PERCH) self.flags -= FL_FLY;
	
	self = oself;
};



void() monster_gargoyle_spawner = {
	monster_spawner(monster_gargoyle_start);
};

void() monster_gargoyle =
{

	precache_model ("progs/mon_gargoyle.mdl");
	precache_model ("progs/h_gargoyle.mdl");
	precache_model ("progs/proj_gargball.mdl");		// FB growing 8 frames
	//precache_model ("progs/proj_gargoyle.mdl");		// red/smoke wiz projectile
	precache_model ("progs/gib_gargwing1.mdl");// Left wing
	precache_model ("progs/gib_gargwing2.mdl");// Right wing


	precache_sound ("gargoyle/idle1.wav");
	precache_sound ("gargoyle/perch1.wav");
	precache_sound ("gargoyle/perch2.wav");

	precache_sound ("gargoyle/attack1.wav");	// Doom imp fireball!
	precache_sound ("gargoyle/swoop1.wav");
	precache_sound ("gargoyle/swoop2.wav");
	precache_sound ("gargoyle/swoop1hit.wav");
	precache_sound ("gargoyle/wings1.wav");
	
	precache_sound ("gargoyle/pain75.wav");
	precache_sound ("gargoyle/pain100.wav");
	precache_sound ("gargoyle/death1.wav");

	precache_sound ("gargoyle/sight1.wav");


	self.cmins = '-16 -16 -24';
	self.cmaxs = '16 16 40';

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize(self, self.cmins, self.cmaxs);
	
	if (self.spawnflags & MONSTER_SPAWNER) {
		self.use = monster_gargoyle_spawner;
		monster_spawner_updatecounter();
	}
	else {
		monster_gargoyle_start(self);
	}
};
