/*==============================================================================
LOST SOUL
Ported from AD
==============================================================================*/

// moving jaw up and down (talking)
$frame idle1 idle2 idle3 idle4 idle5 idle6

// Tilt head backwards to look up
$frame idleB1 idleB2 idleB3 idleB4 idleB5 idleB6

// Tilt head downwards to look below
$frame idleF1 idleF2 idleF3 idleF4 idleF5 idleF6

// Keep looking left or right
$frame idleleft1 idleleft2 idleleft3 idleleft4 idleleft5 idleleft6
$frame idleright1 idleright2 idleright3 idleright4 idleright5 idleright6

// Turn head left or right 30 degrees
$frame idleturnl1 idleturnl2 idleturnl3 idleturnl4 idleturnl5 idleturnl6
$frame idleturnr1 idleturnr2 idleturnr3 idleturnr4 idleturnr5 idleturnr6

// mouth wide open and head tilted back
$frame charge1 charge2 charge3 charge4 charge5 charge6

// obvious chewing motion
$frame chew1 chew2 chew3 chew4 chew5 chew6

// mouth open and rotated Backward or Forward
$frame pain1 pain2 pain3 pain4 pain5 pain6
$frame pain7 pain8 pain9 pain10 pain11 pain12

// Spawning from nothing
$frame grow1 grow2 grow3 grow4 grow5 grow6 grow7 grow8 grow9 grow10

float LOST_IDLE = 0;		// Default state
float LOST_IDLEB = 1;		// Looking UP
float LOST_IDLEF = 2;		// Looking DOWN
float LOST_IDLELEFT = 3;	// Looking left
float LOST_IDLERIGHT = 4;	// Looking right
float LOST_TURNLEFT = 5;	// Turning left (not looped)
float LOST_TURNRIGHT = 6;	// Turning right (not looped)
float LOST_CHARGE = 7;		// Mouth wide open and charging
float LOST_MELEE = 8;		// Mouth chomping open/close
float LOST_PAINB = 9;		// Roll backwards
float LOST_PAINF = 10;		// Roll forward

// Size of each animation block
float LOST_ANIMBLOCK = 6;

// Different states and fire particle quantity
float LOST_STATE_STAND = 2;
float LOST_STATE_WALK = 4;
float LOST_STATE_GUARD = 3;
float LOST_STATE_RUN = 5;
float LOST_STATE_PAIN = 6;

void() lost_guard1;
void() lost_charge2;

float() LostCheckAttack = {
	//----------------------------------------------------------------------
	// setup enemytarget if one is not active
	//----------------------------------------------------------------------
	if (self.enemy.type != "enemytarget" && self.above > 0) {
		if (SUB_setupEnemyTarget(self.enemy, self.above, 2)) {
			self.enemy = self.enemytarget;
		}
	}

	//----------------------------------------------------------------------
	// Melee attack (bite)
	//----------------------------------------------------------------------
	if (ai_checkmelee(60,FALSE)) {
		self.attack_state = AS_MELEE;
		return FALSE;
	}

	//----------------------------------------------------------------------
	// If too close, move sideways until can ram again
	// If too far, move closer
	self.enemydist = range_distance(SUB_entEnemyTarget(), FALSE);
	//----------------------------------------------------------------------
	if (self.enemydist < 200) {
		self.attack_state = AS_SLIDING;
		return FALSE;
	}
	else if (self.enemydist > 400) {
		self.attack_state = AS_STRAIGHT;
		return FALSE;
	}

	//----------------------------------------------------------------------
	// Cannot see enemy? go into guard mode
	//----------------------------------------------------------------------
	if (!enemy_vis && self.lostsearch == FALSE) {
		SUB_switchEnemyTarget();
		self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
		self.lostsearch = TRUE;
		self.lostenemy = self.enemy;
		self.losttimer = time + 15 + random()*5;
		self.enemy = self.goalentity = self.movetarget = world;
		lost_guard1();
		return FALSE;
	}
	
	//----------------------------------------------------------------------
	// Range attack (Ramming Speed)
	//----------------------------------------------------------------------
	// Only range attack if cooldown has finished
	if (time > self.attack_finished) {
		//if (!visblocked_wide(SUB_entEnemyTarget(), self.view_ofs, '0 0 24')) {
		if (canshoot(SUB_entEnemyTarget())) {
			SUB_AttackFinished(2 + random());
			self.attack_state = AS_MISSILE;
		}
		// No space for raming speed, strafe side to side
		else self.attack_state = AS_SLIDING;
	}
	// Wait for attack timer, better to face the player
	else self.attack_state = AS_SLIDING;
	return FALSE;
};

//======================================================================
// Update Lost Souls every frame with velocity movements and glow eyes!
// fstate (see above for animation block details)
//======================================================================
void(float fstate) lost_update = 
{
	// If Lost is dead, no more updates
	if (self.health < 1) return;

	// Time for an idle sound? (run only)
	//if (self.idletimer < time && self.state == LOST_STATE_RUN) 
	//	monster_idle_sound();

	// Update glowing eyes! (skin types = 0,1,2,3,2,1)
	if (self.t_length < time) {
		// fire particle quantity linked to AI state
		//particle_explode(self.origin+'0 0 12', self.state, 1, PARTICLE_BURST_YELLOW, PARTICLE_BURST_LOSTUP);
		self.t_length = time + 0.2;
		self.skin = self.skin + 1;
		if (self.skin > 5) self.skin = 0;
		//self.skin = self.exactskin;
	}

	// While standing still or guarding, gently float up and down
	if (self.state == LOST_STATE_STAND || self.state == LOST_STATE_GUARD) {
		// While standing around idle, gently move up and down
		// using velocity, forced origin movement is really jerky!
		if (self.velocity_x == 0 && self.velocity_y == 0) {
			if (self.attack_timer < time) {
				self.attack_timer = time + 1;
				if (self.lip < 1) self.lip = 1;
				else self.lip = -1;
				self.velocity_z = 2 * self.lip;
			}
		}
		else {
			// Slowdown the velocity (movement = no friction)
			self.velocity = self.velocity * (0.8 + (random() * 0.1));
			if (self.velocity_x > -5 && self.velocity_x < 5) self.velocity_x = 0;
			if (self.velocity_y > -5 && self.velocity_y < 5) self.velocity_y = 0;
			if (self.velocity_z > -5 && self.velocity_z < 5) self.velocity_z = 0;
		}
	}

	// Lost sight of enemy during combat, wait and look around
	if (self.state == LOST_STATE_GUARD) {
		if (self.meleeattack < time) {
			self.meleeattack = time + 4 + (random() + random() + random() * 4);
			if (random() < 0.5) self.lefty = 1;
			else self.lefty = -1;
			self.avelocity = '0 0 0';
			self.avelocity_y = self.lefty*50;
			self.attack_sidestep = 0;
			self.attack_sidedeny = rint(4 + random()*4);
		}
		
		// Keep increasing rotation angle velocity
		self.attack_sidestep = self.attack_sidestep + 1;
		if (self.attack_sidestep > self.attack_sidedeny) self.avelocity = '0 0 0';
		else self.avelocity_y = self.avelocity_y * 1.25;
		
		// Check lost idle timer after combat
		if (self.lostenemy && self.losttimer < time) {
			self.losttimer = 999999;
			if (self.lostenemy.health < 0) self.lostenemy = world;
			else {
				// Restore previous enemy and start hunting
				self.enemy = self.lostenemy;
				self.think = self.th_run;
				self.state = LOST_STATE_RUN;
				// Setup goals and DO NOT warn other monsters
				FoundTarget();
			}
		}
	}
		
	// Work through all the different AI states
	if (self.state == LOST_STATE_STAND || self.state == LOST_STATE_WALK) {
		// At beginning of frame block and reversing?
		if (self.count == 0 && self.idlereverse) {
			if (self.idlebusy == LOST_TURNLEFT || self.idlebusy == LOST_TURNRIGHT) {
				self.idlebusy = LOST_IDLE;
				self.idlereverse = FALSE;
				self.waitmin = time + 2 + random() * 4;
			}
		}
		// At end of frame block and going forward?
		else if (self.count == LOST_ANIMBLOCK-1 && !self.idlereverse) {
			// Always reset turn left/right animation while walking
			if (self.state == LOST_STATE_WALK) {
				if (self.idlebusy == LOST_IDLELEFT) {
					self.idlebusy = LOST_TURNLEFT;
					self.idlereverse = TRUE;
				}
				else if (self.idlebusy == LOST_IDLERIGHT) {
					self.idlebusy = LOST_TURNRIGHT;
					self.idlereverse = TRUE;
				}
				// Return from all other idle animations
				else {
					self.idlebusy = LOST_IDLE;
					self.waitmin = time + 2 + random() * 4;
				}
			}
			// Idle animation designed for standing around
			else {
				if (self.idlebusy == LOST_IDLE && self.waitmin < time) {
					// Randonly pick an idle animation (difference stand/walk)
					self.lip = random();
					if (self.lip < 0.4) self.idlebusy = LOST_TURNLEFT;
					else if (self.lip < 0.6) self.idlebusy = LOST_TURNRIGHT;
					else if (self.lip < 0.8) self.idlebusy = LOST_IDLEB;
					else self.idlebusy = LOST_IDLEF;
				}
				// Return from opening/closing mouth idle animations
				else if (self.idlebusy == LOST_IDLEB || self.idlebusy == LOST_IDLEF) {
					self.idlebusy = LOST_IDLE;
					self.waitmin = time + 2 + random() * 4;
				}
				// Turning head left direction
				else if (self.idlebusy == LOST_TURNLEFT) {
					self.idlebusy = LOST_IDLELEFT;
					self.waitmin = time + 2 + random() * 4;
				}
				// Turning head right direction
				else if (self.idlebusy == LOST_TURNRIGHT) {
					self.idlebusy = LOST_IDLERIGHT;
					self.waitmin = time + 2 + random() * 4;
				}
				// Looking left and randomly think about returning
				else if (self.idlebusy == LOST_IDLELEFT) {
					if (self.waitmin < time && random() < 0.5) {
						self.idlebusy = LOST_TURNLEFT;
						self.idlereverse = TRUE;
					}
				}
				// Looking right and randomly think about returning
				else if (self.idlebusy == LOST_IDLERIGHT) {
					if (self.waitmin < time && random() < 0.5) {
						self.idlebusy = LOST_TURNRIGHT;
						self.idlereverse = TRUE;
					}
				}
			}
		}
	}
	else {
		// All other states (RUN, PAIN, GUARD)
		// Reset any previous idle animations
		self.idlereverse = FALSE;
		self.idlebusy = FALSE;
	}
	
	// Check frame direction and update counter
	if (self.idlereverse) self.count = self.count - 1;
	else self.count = self.count + 1;
	if (self.count >= LOST_ANIMBLOCK) self.count = 0;
	if (self.count < 0) self.count = LOST_ANIMBLOCK-1;
	
	// Busy with an idle animation?
	if (self.idlebusy > 0) fstate = self.idlebusy;
	// Update frame animation block with frame counter
	self.frame = fstate * LOST_ANIMBLOCK + self.count;
	// Store current origin position
	self.oldorigin = self.origin;
};	

//----------------------------------------------------------------------------
void() lost_flymode =
{
	self.solid = SOLID_SLIDEBOX;	// Reset just in case
	self.movetype = MOVETYPE_FLY;	// Turn body into projectile
	// make sure onground is not set, cannot use velocity otherwise
	self.flags = self.flags - (self.flags & FL_ONGROUND);
};

//----------------------------------------------------------------------------
void() lost_stepmode =
{
	self.velocity = '0 0 0';			// Back to regular movement
	self.avelocity = '0 0 0';			// Cancel any rotation velocity
	self.angles_x = self.angles_z = 0;	// Reset any X/Y angles
	self.solid = SOLID_SLIDEBOX;		// Always reset
	self.movetype = MOVETYPE_STEP;		// Back to discreet movement
};

//======================================================================
// All stand, walk and run functions are condensed down to one entry
// so that the lost souls can move dynamic and have skin updates
//
void()	lost_stand1 = [ $idle1, lost_stand1 ] {
	if (self.state != LOST_STATE_GUARD) self.state = LOST_STATE_STAND;	
	lost_flymode();				// allow velocity updates
	lost_update(LOST_IDLE);		// Update skin + velocity
	ai_stand();
};
void()	lost_guard1 = { self.state = LOST_STATE_GUARD; lost_stand1(); };

void()	lost_walk1 = [ $idle1, lost_walk1 ] {
	self.state = LOST_STATE_WALK;
	lost_stepmode();			// back to discreet step mode
	lost_update(LOST_IDLE); 	// Update skin
	ai_walk(8);
};
void()	lost_run1 = [ $idle1, lost_run1 ] {
	self.state = LOST_STATE_RUN;
	lost_stepmode();			// back to discreet step mode
	lost_update(LOST_IDLE);		// Update skin
	ai_run(8);
};

//============================================================================
// Range Charge attack
//============================================================================
void() lost_charge_touch =
{
	// Stop anymore touching
	self.touch = SUB_Null;
	self.think = self.th_run;
	
	// Do not damage other souls with charge attacks
	// Prevents packs from killing themselves
	if (self.classname != other.classname && other.takedamage) {
		T_Damage(other, self, self, 10, DMGTYPE_MELEE);
		spawn_touchblood(10*3);

		// If touched a player, nudge them backwards
		if (other.flags & FL_CLIENT) {
			self.lostsearch = FALSE;
			makevectors(self.angles);
			other.velocity = other.velocity + (v_forward * 200 + '0 0 50');
		}
	}
};

//----------------------------------------------------------------------------
void()	lost_charge1 = {
	// Play hiss sound, sighted enemy, charging
	sound (self, CHAN_WEAPON, "lostsoul/charge.wav", 1, ATTN_NORM);	
	
	self.count = 0;				// reset start of animation block
	lost_flymode();				// allow velocity updates
	lost_update(LOST_CHARGE);	// Update skin
	// Stop tracking if easy/normal skill 
	if (skill < SKILL_HARD) self.lostsearch = FALSE;

	self.cnt = 0;									// reset speed updates
	self.attack_speed = 400;						// Initial speed
	self.pos1 = SUB_orgEnemyTarget() + '0 0 12';	// Aim towards head
	self.pos2 = normalize(self.pos1 - self.origin);	// Vector direction
	self.touch = lost_charge_touch;					// Damage/end function
	self.velocity = self.pos2 * self.attack_speed;	// Launch body missile!
	self.angles = vectoangles(self.velocity);		// Turn straight away
	
	self.think = lost_charge2;
	self.nextthink = time + 0.1;
};

//----------------------------------------------------------------------------
void() lost_charge2 = {
	if (self.health < 1) return;
	lost_update(LOST_CHARGE);
	self.nextthink = time + 0.1;
	
	self.cnt = self.cnt + 1;						// speed updates
	if (self.cnt > 12) self.think = self.th_run;	// End of charge attack
	// Keep travelling forward regardless of enemy
	else {
		// Keep increasing speed every 0.1s (check for max speed)
		if (self.attack_speed < 800)
			self.attack_speed = self.attack_speed + 10;
		self.velocity = self.pos2 * self.attack_speed;
		self.think = lost_charge2;
	}
};

//======================================================================
// MELEE ATTACK - Biting
//======================================================================
void() lost_bite = {
	local float ldmg;
	local entity enemy_targ;
	
	enemy_targ = SUB_entEnemyTarget();

	if (!enemy_targ) return;
	if (self.health < 1) return;
		
	ai_charge(10);							// Get closer for extra bite
	if (!ai_checkmelee(60,FALSE)) return;	// Too far away

	// Can the target bleed?
	if (enemy_targ.takedamage < 1) return;

	sound(self, CHAN_WEAPON, "lostsoul/bite.wav", 1, ATTN_NORM);

	// Lost Soul bite is very weak
	ldmg = (random() + random() + random()) * 3;
	T_Damage(enemy_targ, self, self, ldmg, DMGTYPE_MELEE);

	// Spawn blood at mouth of Lost Soul
	spawn_touchblood(ldmg*3);
};

//----------------------------------------------------------------------------
void() lost_melee2 = {
	if (self.health < 1) return;
	lost_update(LOST_MELEE);	// Update skin
	self.cnt = self.cnt + 1;	// Next frame
	
	// Check for bite attack
	if (self.cnt == 3) lost_bite();

	// End of melee attack?
	if (self.cnt >= 5) {
		// One chop of the jaws and then fly away time
		self.think = self.th_run;
		
		// Check if enemy is still within range for another chop!
//		if (ai_checkmelee(MONAI_MELEELOSTSOUL,FALSE) && SUB_healthEnemyTarget() > 0)
//			self.think = self.th_melee;
//		else self.think = self.th_run;
	}
	else self.think = lost_melee2;
	self.nextthink = time + 0.1;
};

//----------------------------------------------------------------------------
void() lost_melee1 = {
	self.count = 0;				// reset start of animation block
	self.cnt = 0;				// Reset bite frame counter
	lost_flymode();				// stay in flymode just in case collison probs
	lost_update(LOST_MELEE);	// Update skin

	self.think = lost_melee2;
	self.nextthink = time + 0.1;
};



//============================================================================
// PAIN in the head!
//============================================================================
void() lost_inpain = {
	// Update pain frame
	lost_update(self.attack_rage);
	
	// Next pain animation
	self.inpain = self.inpain + 1;
	if (self.inpain >= 5) self.think = self.th_run;
	else self.think = lost_inpain;
	self.nextthink = time + 0.1;
};

//----------------------------------------------------------------------
void(entity attacker, float damage) lost_pain = {
	// Check all pain conditions and set up what to do next

	if (self.state != LOST_STATE_PAIN) {
		// Stop all velocity and reset movetype
		lost_stepmode();
		sound(self, CHAN_VOICE, "lostsoul/pain1.wav", 1, ATTN_NORM);
	}

	// Work out which direction the damage came from (enemy)
	if (infront(attacker)) self.attack_rage = LOST_PAINB;	// Hit from infront
	else self.attack_rage = LOST_PAINF;						// Hit from behind
	
	self.state = LOST_STATE_PAIN;
	// Reset pain and current frame counter
	self.inpain = self.count = 0;
	// Always do pain, no flinch
	lost_inpain();
};

//============================================================================

void() lost_explosion_frame = {
	self.frame = self.frame + 1;
	if (self.frame > self.count) SUB_Hide();
	else self.nextthink = time + self.speed;
};

void() lost_die1 = [ $pain1, lost_die2 ] {};
void() lost_die2 = [ $pain2, lost_die2 ] {
	// Lost souls explode when they die
	T_RadiusDamage (self, self, 40, world, DMGTYPE_EXPLOSION);

	if (random() > 0.5) {
		self.speed = 0.05;
		self.count = 13;
		setmodel(self, "progs/s_exp_med.spr");
	}
	else {
		self.speed = 0.1;
		self.count = 5;
		setmodel(self, "progs/s_exp_small.spr");
	}
	setsize(self, '0 0 0', '0 0 0');
	self.frame = 0;
	
	sound (self, CHAN_VOICE, "lostsoul/death.wav", 1, ATTN_NORM);

	self.think = lost_explosion_frame;
	self.nextthink = time + self.speed;
};

//----------------------------------------------------------------------
void() lost_die = {
	// Make sure body does not drop to the ground
	self.flags = self.flags | FL_FLY;
	self.takedamage = DAMAGE_NO;
	lost_die1();
};

void() lost_sight = {
	sound (self, CHAN_VOICE, "lostsoul/idle1.wav", 1, ATTN_NORM);
};

/*======================================================================
QUAKED monster_lostsoul (1 0.2 0) (-16 -16 -24) (16 16 24)
======================================================================*/

void(entity e) monster_lostsoul_start = {
	local entity oself;

	oself = self;
	self = e;

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

    setmodel (self, "progs/mon_lostsoul.mdl");

    if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize (self, '-16 -16 -24', '16 16 16');
	
	self.health = 30;
	self.yaw_speed = 35;
	self.above = 128;

	if (self.obituary == "") self.obituary = "was found by a Lost Soul";
	
	
	self.th_stand = lost_stand1;
	//self.th_altstand = lost_guard1;
	self.th_walk = lost_walk1;
	self.th_run = lost_run1;
	self.th_melee = lost_melee1;
	self.th_missile = lost_charge1;
	self.th_sight = lost_sight;
	self.th_pain = lost_pain;
	self.th_die = lost_die;
	self.th_checkattack = LostCheckAttack;

	//self.th_charge = lost_charge2;

		
	flymonster_start ();

	self = oself;
};

void() monster_lostsoul_spawner = {
	monster_spawner(monster_lostsoul_start);
};


void() monster_lostsoul = {
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/mon_lostsoul.mdl");
	precache_model ("progs/s_exp_small.spr");
	precache_model ("progs/s_exp_med.spr");

	precache_sound ("lostsoul/idle1.wav");
	precache_sound ("lostsoul/idle2.wav");
	
	precache_sound ("lostsoul/charge.wav");		// charge hiss/scream
	precache_sound ("lostsoul/bite.wav");		// chomp with teeth

	precache_sound ("lostsoul/pain1.wav");
	precache_sound ("lostsoul/death.wav");
	
	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize (self, '-16 -16 -24', '16 16 16');

	if (self.spawnflags & MONSTER_SPAWNER) {
		self.use = monster_drone_spawner;
		monster_spawner_updatecounter();
	}
	else {
		monster_lostsoul_start(self);
	}
};



//----------------------------------------------------------------------------
/*void() setup_lostsoul =
{
	self.solid = SOLID_NOT;			// No interaction with world
	self.movetype = MOVETYPE_NONE;	// Static item, no movement
	if (self.bboxtype < 1) self.bboxtype = BBOX_TINY;
	if (self.health < 1) self.health = 30;
	self.yaw_speed = 35;			// Really fast at turning
	self.gibhealth = MON_NEVERGIB;	// Cannot be gibbed by weapons
	self.gibbed = FALSE;			// Still in one piece
	self.pain_flinch = 10;			// Always go into pain
	self.blockudeath = TRUE;		// no humanoid death sound
	self.steptype = FS_FLYING;		// Silent feet
	self.pain_longanim = FALSE;		// No long pain animation
	if (self.height < 1) self.height = MONAI_ABOVEDIST; // Custom height
	self.meleeattack = time + 4;	// no rotation at spawn
	self.mangle = self.angles;		// idle rotate left/right
	self.idlebusy = 0;				// Tilt/turn head animations
	self.idlereverse = FALSE;		// Reverse direction for idle
	if (self.velocityfriction <= 0) self.velocityfriction = 0.8 + (random() * 0.1);
	self.exactskin = rint(random()*5);	// Randomize eye glow
	self.lostenemy = world;				// Setup old enemy
	self.losttimer = LARGE_TIMER;		// Stop lost timer
	self.lostsearch = FALSE;			// Not searching for an enemy
	self.deathstring = " was found by a Lost Soul\n";
	
	// I can understand lost souls being the perfect candidate for
	// poison attacks, but they are tricky already! default = disabled.
	self.poisonous = FALSE;

	// Always reset Ammo Resistance to be consistent
	self.resist_shells = self.resist_nails = 0;
	self.resist_rockets = self.resist_cells = 0;

	self.th_checkattack = LostCheckAttack;
	self.th_pain = lost_pain;
	self.th_die = lost_die;
	
	//----------------------------------------------------------------------
	// Special spawning minion need to start spinning
	if (self.classtype == CT_MINIONLOSTSOUL) {
		self.th_stand = self.th_walk = self.th_run = lost_grow;
		self.th_missile = SUB_Null;
	}
	//----------------------------------------------------------------------
	// Default lost soul setup
	else {
		self.th_stand = lost_stand1;
		self.th_altstand = lost_guard1;
		self.th_walk = lost_walk1;
		self.th_run = lost_run1;
		self.th_melee = lost_melee1;
		self.th_missile = lost_charge1;
		self.th_charge = lost_charge2;
	}
		
	self.classtype = CT_MONLOSTSOUL;
	self.classgroup = CG_WIZARD;
	self.classmove = MON_MOVEFLY;

	monster_start();
};
*/