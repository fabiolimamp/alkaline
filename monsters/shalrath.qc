/*
==============================================================================

SHAL-RATH

==============================================================================
*/

// 0 - 10
$frame attack1 attack2 attack3 attack4 attack5 attack6 attack7 attack8
$frame attack9 attack10 attack11

// 11- 15
$frame pain1 pain2 pain3 pain4 pain5 

// 16 - 22
$frame death1 death2 death3 death4 death5 death6 death7

// 23
$frame stand1

// 24 - 34
$frame	walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9 walk10
$frame	walk11

/*
Mechavore has a few differences in frame numbers:
- Stand is frame 0 instead of 23
- Walk is 23-33 instead of 24-34
- There's no frame 34
That gets corrected in every frame function they're used in.
*/


const float SHAL_BALL_TURN_RATE		= 265;
const float SHAL_BALL_THINK_RATE	= 0.1;
const float SHAL_BALL_VEL			= 300;

void() shal_stand     =[      $stand1,       shal_stand    ] {
	if (!self.originalmonsters) self.frame = $attack1; // mechavore has stand as frame 0
	ai_stand();
}; // stand1 is a framegroup, animates automatically


void() shal_walk1     =[      $walk1,       shal_walk2    ] {ai_walk(4);};
void() shal_walk2     =[      $walk2,       shal_walk3    ] {ai_walk(6);
	if (random() < 0.2)	{
		if (self.originalmonsters) sound (self, CHAN_VOICE, "shalrath/idle.wav", 1, ATTN_IDLE);
		else sound (self, CHAN_VOICE, "mechavore/mv_idle_a.wav", 1, ATTN_IDLE);
	}
};
void() shal_walk3     =[      $walk3,       shal_walk4    ] {if (!self.originalmonsters) self.frame--; ai_walk(0); };
void() shal_walk4     =[      $walk4,       shal_walk5    ] {if (!self.originalmonsters) self.frame--; ai_walk(0); };
void() shal_walk5     =[      $walk5,       shal_walk6    ] {if (!self.originalmonsters) self.frame--; ai_walk(0); };
void() shal_walk6     =[      $walk6,       shal_walk7    ] {if (!self.originalmonsters) self.frame--; ai_walk(0); };
void() shal_walk7     =[      $walk7,       shal_walk8    ] {if (!self.originalmonsters) self.frame--; ai_walk(5); };
void() shal_walk8     =[      $walk8,       shal_walk9    ] {if (!self.originalmonsters) self.frame--; ai_walk(6); };
void() shal_walk9     =[      $walk9,       shal_walk10    ] {if (!self.originalmonsters) self.frame--; ai_walk(5); };
void() shal_walk10    =[      $walk10,       shal_walk11    ] {if (!self.originalmonsters) self.frame--; ai_walk(0); };
void() shal_walk11    =[      $walk11,       shal_walk1    ] {if (!self.originalmonsters) self.frame--; ai_walk(4); };



void() shal_run1     =[      $walk1,       shal_run2    ] {ai_run(6);
	if (random() < 0.2)	{
		if (self.originalmonsters) sound (self, CHAN_VOICE, "shalrath/idle.wav", 1, ATTN_IDLE);
		else sound (self, CHAN_VOICE, "mechavore/mv_idle_a.wav", 1, ATTN_IDLE);
	}
};
void() shal_run2     =[      $walk2,       shal_run3    ] {if (!self.originalmonsters) self.frame--; ai_run(4); };
void() shal_run3     =[      $walk3,       shal_run4    ] {if (!self.originalmonsters) self.frame--; ai_run(0); };
void() shal_run4     =[      $walk4,       shal_run5    ] {if (!self.originalmonsters) self.frame--; ai_run(0); };
void() shal_run5     =[      $walk5,       shal_run6    ] {if (!self.originalmonsters) self.frame--; ai_run(0); };
void() shal_run6     =[      $walk6,       shal_run7    ] {if (!self.originalmonsters) self.frame--; ai_run(0); };
void() shal_run7     =[      $walk7,       shal_run8    ] {if (!self.originalmonsters) self.frame--; ai_run(5); };
void() shal_run8     =[      $walk8,       shal_run9    ] {if (!self.originalmonsters) self.frame--; ai_run(6); };
void() shal_run9     =[      $walk9,       shal_run10    ] {if (!self.originalmonsters) self.frame--; ai_run(5); };
void() shal_run10    =[      $walk10,       shal_run11    ] {if (!self.originalmonsters) self.frame--; ai_run(0); };
void() shal_run11    =[      $walk11,       shal_run1    ] {if (!self.originalmonsters) self.frame--; ai_run(4); };


void() shal_attack1     =[      $attack1,       shal_attack2    ] {ai_face();
	if (self.originalmonsters) sound (self, CHAN_VOICE, "shalrath/attack.wav", 1, ATTN_NORM);
	else sound (self, CHAN_VOICE, "mechavore/mv_attack.wav", 1, ATTN_NORM);
};
void() shal_attack2     =[      $attack2,       shal_attack3    ] {ai_face();};
void() shal_attack3     =[      $attack3,       shal_attack4    ] {ai_face();};
void() shal_attack4     =[      $attack4,       shal_attack5    ] {ai_face();};
void() shal_attack5     =[      $attack5,       shal_attack6    ] {ai_face();};
void() shal_attack6     =[      $attack6,       shal_attack7    ] {ai_face();};
void() shal_attack7     =[      $attack7,       shal_attack8    ] {ai_face();};
void() shal_attack8     =[      $attack8,       shal_attack9    ] {ai_face();};
void() shal_attack9     =[      $attack9,       shal_attack10   ] {ShalMissile();};
void() shal_attack10    =[      $attack10,      shal_attack11   ] {ai_face();};
void() shal_attack11    =[      $attack11,      shal_run1   ] {};


//========================================================

void() shal_pain1       =[      $pain1, shal_pain2      ] {};
void() shal_pain2       =[      $pain2, shal_pain3      ] {};
void() shal_pain3       =[      $pain3, shal_pain4      ] {};
void() shal_pain4       =[      $pain4, shal_pain5      ] {};
void() shal_pain5       =[      $pain5, shal_run1      ] {};

void(entity attacker, float damage) shalrath_pain =
{
	if (self.originalmonsters) {
		if (self.health < self.max_health * 0.05)	self.skin = 3;
		else if (self.health < self.max_health * 0.4)	self.skin = 2;
		else if (self.health < self.max_health * 0.8)	self.skin = 1;
	}

	if (self.pain_finished > time)
		return;

	if (self.originalmonsters) sound (self, CHAN_VOICE, "shalrath/pain.wav", 1, ATTN_NORM);
	else {
		if (random() > 0.5) sound (self, CHAN_VOICE, "mechavore/mv_pain_a.wav", 1, ATTN_NORM);
		else sound (self, CHAN_VOICE, "mechavore/mv_pain2_a.wav", 1, ATTN_NORM);
	}

	shal_pain1();
	self.pain_finished = time + 3;
};


//========================================================


void() shal_death1      =[      $death1,        shal_death2     ] {};
void() shal_death2      =[      $death2,        shal_death3     ] {};
void() shal_death3      =[      $death3,        shal_death4     ] {};
void() shal_death4      =[      $death4,        shal_death5     ] {};
void() shal_death5      =[      $death5,        shal_death6     ] {};
void() shal_death6      =[      $death6,        shal_death7     ] {};
void() shal_death7      =[      $death7,        shal_death7    ] {monster_dead_dead();};

void() shalrath_die =
{
// check for gib
	if (self.health < -90)
	{
		self.deadflag = DEAD_GIBBED;
		if (self.originalmonsters) {
			self.skin = 0;
			sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
			ThrowHead ("progs/h_shal.mdl", self.health);
			ThrowGib ("progs/gib1.mdl", self.health);
			ThrowGib ("progs/gib1.mdl", self.health);
			ThrowGib ("progs/gib2.mdl", self.health);
			ThrowGib ("progs/gib3.mdl", self.health);
			ThrowGib ("progs/gib3.mdl", self.health);
			ThrowGib ("progs/gib3.mdl", self.health);
			return;
		}
		else {
			sound (self, CHAN_VOICE, "misc/metal_impact.wav", 1, ATTN_NORM);
			ThrowHead("progs/h_hunter.mdl", self.health);
			ThrowGib ("progs/cyberscrag_gib1.mdl", self.health);
			ThrowGib ("progs/cyberscrag_gib1.mdl", self.health);
			ThrowGib ("progs/cyberscrag_gib2.mdl", self.health);
			ThrowGib ("progs/cyberscrag_gib2.mdl", self.health);
			ThrowGib ("progs/probelasr_gib1.mdl", self.health);
			ThrowGib ("progs/hunter_gibs.mdl", self.health);
			ThrowGib ("progs/hunter_gibs.mdl", self.health);
			ThrowGib ("progs/hunter_gibs.mdl", self.health);
			return;
		}
	}

	if (self.originalmonsters) self.skin = 3;

	if (self.originalmonsters) sound (self, CHAN_VOICE, "shalrath/death.wav", 1, ATTN_NORM);
	else sound (self, CHAN_VOICE, "mechavore/mv_death_a.wav", 1, ATTN_NORM);

	shal_death1();
	self.solid = SOLID_TRIGGER; setorigin(self, self.origin);
	// insert death sounds here
};

/*
================
ShalMissile
================
*/

void() ShalMissile =
{
	local	vector	dir;
	local	float	dist, flytime;

	dir = normalize((self.enemy.origin + '0 0 10') - self.origin);
	dist = vlen (self.enemy.origin - self.origin);
	flytime = dist * 0.002;
	if (flytime < 0.1)
		flytime = 0.1;

	self.effects = self.effects | EF_MUZZLEFLASH;
	sound (self, CHAN_WEAPON, "shalrath/attack2.wav", 1, ATTN_NORM);


	newmis = spawn ();
	newmis.classname = "shalmissile";
	newmis.owner = self;

	newmis.solid = SOLID_BBOX;
	newmis.movetype = MOVETYPE_FLYMISSILE;

	if (self.originalmonsters) setmodel (newmis, "progs/v_spike.mdl");
	else setmodel (newmis, "progs/mvore_bomb.mdl");
	

	setsize (newmis, '0 0 0', '0 0 0');		
	newmis.flags = newmis.flags | FL_PROJECTILE;
	newmis.origin = self.origin + '0 0 10';
	newmis.velocity = dir * 400;
	newmis.avelocity = '300 300 300';
	newmis.nextthink = flytime + time;
	newmis.lifetime_finished = time + 30;	 // blow up after a while
	newmis.think = ShalHome2;
	newmis.enemy = self.enemy;
	newmis.touch = ShalMissileTouch;
};

void() ShalHome =
{
	local vector	dir, vtemp;
	vtemp = self.enemy.origin + '0 0 10';
	if (self.enemy.health < 1)
	{
		remove(self);
		return;
	}

	if (self.attack_finished && time > self.attack_finished) {
		//dprint("Lifetime finished\n");
		other = self.enemy;
		self.touch();
		return;
	}
	//dprint5("Voreball tracking entity: ", self.enemy.classname, " (", vtos(vtemp), ")\n");

	dir = normalize(vtemp - self.origin);

	if (startskill == SKILL_NIGHTMARE)
		self.velocity = dir * 350;
	else
		self.velocity = dir * 250;

	self.nextthink = time + 0.2;
	self.think = ShalHome;	
};



vector(vector targ, float turnrate) ShalTurnToward =
{
	vector	vel, aimdir, temp, temp2, out;

	temp = targ + '0 0 10';
	aimdir = temp - self.origin;
	aimdir = normalize(aimdir);
	vel = normalize(self.velocity);
	
	temp = cross_product(vel, aimdir);
	
	// try to flatten the rotation to the horizontal plane unless the difference is extreme
	if (fabs(temp_z) > 0.92)
	{
		temp_z *= 4;
		temp = normalize(temp);
	}
	out = rotateVectorAround(vel, temp, turnrate * SHAL_BALL_THINK_RATE);
	
	// don't turn past the desired direction
	temp2 = cross_product(out, aimdir);
	if ((temp * temp2) < 0)
		return aimdir;
	return out;
}

void() ShalHome2 =
{
	// a voreball with perfect homing causes combat to effectively stop, forcing the player
	// to run around around trying to shake it, often backpedaling through lots of empty map.
	// limiting the voreball's turn rate so they can be dodged and forgotten about makes vores
	// a more flexible enemy and more useful to the mapper
	float dist, rate, dot;
	
	if (self.lifetime_finished < time) {
		ShalMissileExplode();
		return;
	}

	if (self.enemy.health <= 0) {
		self.think = ShalMissileExplode;
		self.nextthink = self.lifetime_finished;
		//remove(self);
		return;
	}
	
	if (!self.deadflag) {
		if (self.owner.health <= 0)		// if our mama dies
		{
			self.deadflag = TRUE;
			//setmodel(self, "progs/proj_voreball2.mdl");	// stop sparkling

			//setsize(self, VEC_ORIGIN, VEC_ORIGIN);
		}
	}
	
	self.think = ShalHome2;
	self.nextthink = time + SHAL_BALL_THINK_RATE;
	rate = SHAL_BALL_TURN_RATE;
	dot = normalize(self.velocity) * normalize(self.enemy.origin - self.origin);
	
	// reset our owner regularly, or else a voreball that passes through a notrace-invisible
	// player will become owned by the player and remain nonsolid to them after the ring ends
	//self.owner = self.trueowner;
	// if the projectile is inside a notrace entity at this time, it'll touch again this frame
	// and reset anyway, so this state will pingpong until it passes out the other side
	
	// go faster at long distance to close the gap, so snipey vores have a better presence
	dist = vlen(self.enemy.origin - self.origin);
	dist = saturate( (dist-200) / 600 );
	
	if (startskill < SKILL_NIGHTMARE)
	{
		// 'poor' homing (half turn rate):
		if ( self.deadflag		// if our mama dies or falls in a hole
			//|| !visible(self.enemy)		// if we lost LOS
			// took ^^ this one out, because it made voreballs even more effective at going
			// around corners, which meant that courageous players had a nice new dodge move
			// but those who tried to fight the vore the old cautious way were punished			
			//|| has_invis(self.enemy)			// if target is invis
			|| pointcontents2(self.origin) < CONTENT_SOLID ) // if voreball is underwater
		{
			// voreballs headed straight at the player when he's hidden should maintain course, to
			// make the dodge possible without it immediately turning to hit him
			if (dot > 0)
			{
				rate *= max(1, 1.5 * (1 - dot));
			}
			self.velocity = SHAL_BALL_VEL * ShalTurnToward(self.enemy.origin, rate * 0.33);
		}
		else // good homing (full turn rate):
		{
			// voreballs headed straight away from the player don't normally seem to be able to pick a direction to 
			// turn and wobble more or less straight away - amp turn rate in these cases to force a 'decision'
			if (dot < 0)
			{
				rate *= min(1.4, 1.4 + fabs(dot));
			}
			self.velocity = SHAL_BALL_VEL * ShalTurnToward(self.enemy.origin, rate);
		}
		
		self.velocity *= 1 + dist;
		self.velocity += [crandom(),crandom(),crandom()] * 16;
	}
	else {
		// nightmare: vanilla-evil homing with corner following to force engagement rather than encourage it
		enemy_vis = visible(self.enemy);
		
		self.dest2 = self.dest;
		if (enemy_vis)	// go straight to follow player around corners
		{
			// remember last seen positions for corner hax
			self.dest = self.enemy.origin;
		}
		else if (self.dest2 == self.dest)
		{
			// player has been out of sight for two frames, don't keep changing velocity or
			// when we reach that point we'll dance around it weirdly
			self.oldvelocity = self.velocity;
			return;
		}
		
		// poor homing
		if ( self.deadflag		// if our mama dies or falls in a hole
			|| pointcontents2(self.origin) < CONTENT_SOLID )
		{
			if (dot > 0)
			{
				rate *= max(1, 1.5 * (1 - dot));
			}
			self.velocity = SHAL_BALL_VEL * ShalTurnToward(self.dest2, rate * 0.5);
		}
		else // evile homing
		{
			self.velocity = SHAL_BALL_VEL * normalize(self.dest2 + '0 0 10' - self.origin);
		}
		
		self.velocity *= 1 + dist;
		self.velocity += [crandom(),crandom(),crandom()] * 16;
	}

	self.oldvelocity = self.velocity;	
}



void() ShalMissileExplode =
{
	self.dmg = zeroconvertdefault(self.dmg, 40);

	T_RadiusDamage (self, self.owner, self.dmg, 1, world, DMGTYPE_EXPLOSION);
	//sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);

	BecomeExplosion();
}

void() ShalMissileTouch =
{
	if (other == self.owner)
		return;		// don't explode on owner

	if (other.classname == "monster_zombie")
		T_Damage(other, self, self, 110, DMGTYPE_EXPLOSION);

	ShalMissileExplode();
};

//=================================================================

void() shal_sight = {

	if (self.originalmonsters) sound (self, CHAN_VOICE, "shalrath/sight.wav", 1, ATTN_NORM);
	else sound (self, CHAN_VOICE, "mechavore/mv_sight_b.wav", 1, ATTN_NORM);
};


//=================================================================

/*QUAKED monster_shalrath (1 0 0) (-32 -32 -24) (32 32 48) Ambush
*/
void(entity e) monster_shalrath_start =
{
	local entity oself;

	oself = self;
	self = e;

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	
	if (self.originalmonsters) setmodel (self, "progs/shalrath_old.mdl");
	else setmodel (self, "progs/shalrath_newer.mdl");

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize(self, self.cmins, self.cmaxs);
	
	self.health = 400;
	if (self.obituary == "") {
		if (self.originalmonsters) self.obituary = "was exploded by a Vore";
		else self.obituary = "was exploded by a Mecha Vore";
	}

	self.th_stand = shal_stand;
	self.th_walk = shal_walk1;
	self.th_run = shal_run1;
	self.th_die = shalrath_die;
	self.th_pain = shalrath_pain;
	self.th_missile = shal_attack1;
	self.th_sight = shal_sight;

	walkmonster_start();

	self = oself;
};

void() monster_shalrath_spawner = {
	monster_spawner(monster_shalrath_start);
};

void() monster_shalrath =
{
	if (!SUB_InitEntity()) return;
	
	if (deathmatch)
	{
		remove(self);
		return;
	}

	if (
		world.originalmonsters && !(self.spawnflags & MONSTER_ALK)
		|| self.spawnflags & MONSTER_ORIGINAL
	) self.originalmonsters = 1;

	if (self.originalmonsters) {
		precache_model2 ("progs/shalrath_old.mdl");
		precache_model2 ("progs/h_shal.mdl");
		precache_model2 ("progs/v_spike.mdl");
		
		precache_sound2 ("shalrath/attack.wav");
		precache_sound2 ("shalrath/death.wav");
		precache_sound2 ("shalrath/idle.wav");
		precache_sound2 ("shalrath/pain.wav");
		precache_sound2 ("shalrath/sight.wav");
	}
	else {
		precache_model2 ("progs/shalrath_newer.mdl");
		precache_model2 ("progs/h_hunter.mdl");
		precache_model2 ("progs/hunter_gibs.mdl");
		precache_model2 ("progs/mvore_bomb.mdl");
		precache_model2 ("progs/probelasr_gib1.mdl");
		precache_model2 ("progs/cyberscrag_gib1.mdl");
		precache_model2 ("progs/cyberscrag_gib2.mdl");
		
		/*precache_sound2 ("mechavore/attack.wav");
		precache_sound2 ("mechavore/death.wav");
		precache_sound2 ("mechavore/idle.wav");
		precache_sound2 ("mechavore/pain.wav");
		precache_sound2 ("mechavore/sight.wav");*/

		precache_sound2 ("mechavore/mv_attack.wav");
		precache_sound2 ("mechavore/mv_death_a.wav");
		precache_sound2 ("mechavore/mv_idle_a.wav");
		precache_sound2 ("mechavore/mv_pain_a.wav");
		precache_sound2 ("mechavore/mv_pain2_a.wav");
		precache_sound2 ("mechavore/mv_sight_b.wav");

		precache_sound2 ("misc/metal_impact.wav");
	}

	precache_sound2 ("shalrath/attack2.wav");
	
	if (!self.bloodtype && !self.originalmonsters) {
		self.bloodtype = SPAWN_YELLOWSPARK;
	}

	self.cmins = VEC_HULL2_MIN;
	self.cmaxs = VEC_HULL2_MAX;

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize(self, self.cmins, self.cmaxs);
	
	if (self.spawnflags & MONSTER_SPAWNER) {
		self.use = monster_shalrath_spawner;
		monster_spawner_updatecounter();
	}
	else {
		monster_shalrath_start(self);
	}
};

	