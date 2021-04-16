/*==============================================================================

Rubicon 2 code by john fitzgibbons

Files created for rubicon 2:

- rubicon2.qc		* func_breakable		object that can be destroyed by shooting
					* func_explobox		 	same as misc_explobox but it's a brush entity
					* func_laser			togglable laser, can be solid or pass through
					* item_circuitboard		collectible circuit board thing
					* light_fixture1		light fixture model
					* light_beacon			red flashing beacon
					* misc_flag				animated hanging banner
					* misc_sparks			spark emitter
					* misc_smoke			smoke/steam emitter
					* misc_splash			waterfall splash effect
					* trigger_ladder		invisible ladder volume
- dread.qc			* monster_dreadnaught	soldier with flame thrower
- floyd.qc			* monster_floyd			automaton enemy
- centurion.qc		* monster_centurion		air centurion
- turret.qc			* func_turret			defense turret

Files modified for rubicon 2 (search for "johnfitz" to find each modified bit):

- ai.qc				* modified pain_forward() so floyd animations look better
					* added new sight sounds: floyd, dread
					* fixed monsters attacking intermission camera
- buttons.qc		* added "movedir" key -- use it to set a button's move vector directly
- client.qc			* added new obituaries
					* removed axe and shotgun from default items in SetNewParms() but only on certain maps
					* added code for impulse 666 (resurrection cheat)
					* fixed armor absorbs drowning damage
					* added ladder movement code
					* added burning player code
- combat.qc			* modified T_Damage() so that armour won't protect you from drowning damage
- defs.qc			* added new fields and constants
					* changed IT_EXTRA_WEAPON to IT_NO_WEAPON
- doors.qc			* fixed unlock sound not being played on keyed doors
					* added "movedir" key -- use it to set a door's move vector directly
- items.qc			* weapon_axe
					* weapon_shotgun
- fish.qc			* fixed fish staying solid too long after death
- misc.qc			* fixed ambient sounds consume edicts
					* ambient_general
- monsters.qc		* fixed fish count twice towards total_monsters
- plats.qc			* added "retrigger" flag to func_train -- train will wait to be retriggered at each path_corner
					* more func_train sound options
- player.qc			* added player hurt sounds: steam(smoke), flame
- progs.src			* added lines to compile the new .qc files
- triggers.qc		* trigger_setskill is now targetable
- weapons.qc		* added code for having no weapons (IT_NO_WEAPON)
					* added code to make a clanking sound when hitting damagable brushmodels with axe
					* fixed impulsecommands() called even though impulse = 0
					* added new cheats (impulse 252, 253, 254 = ring, biosuit, pent)
- world.qc			* fixed sounds for cheats not being precached
					* added lightstyles 12 through 15
					
Files added for rubicon2:

- hiprot.qc			* info_rotate
					* func_movewall
					* func_rotate_door
					* func_rotate_entity
					* func_rotate_train
					* path_rotate
					* rotate_object
					* added sounds 4 = screechy metal for func_rotate_door

==============================================================================*/

//function to help monsters not shoot each other
float (entity targ) clean_shot =
{
	local vector	spot1, spot2;
	
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;
	traceline (spot1, spot2, FALSE, self);	// try not to shoot through other monsters
	if (trace_ent != targ)
		return FALSE;
	return TRUE;
};

/*
===============================================================================
func_breakable
===============================================================================
*/

void() make_breakable_debris =
{
	local float i;
	i = 0;
	while (i < self.cnt)
	{
		local	entity new;

		new = spawn();
		new.origin_x = (self.maxs_x - self.mins_x)*random() + self.mins_x;
		new.origin_y = (self.maxs_y - self.mins_y)*random() + self.mins_y;
		new.origin_z = (self.maxs_z - self.mins_z)*random() + self.mins_z;
		setmodel (new, "progs/debris.mdl");
		setsize (new, '0 0 0', '0 0 0');
		new.velocity = VelocityForDamage (self.health*2);
		new.movetype = MOVETYPE_BOUNCE;
		new.solid = SOLID_NOT;
		new.avelocity_x = random()*600;
		new.avelocity_y = random()*600;
		new.avelocity_z = random()*600;
		new.think = SUB_Remove;
		new.ltime = time;
		new.nextthink = time + 10 + random()*10;
		new.flags = 0;

		//randomly choose size
		if (random() > 0.333)
			new.frame = 1; //larger
		else
			new.frame = 2; //smaller

		//choose skin based on "style" key
		if (self.style == 1)
			new.skin = 1;
		if (self.style == 2)
			new.skin = 2;
		
		i = i + 1;
	}
	
};

void () func_breakable_die =
{
	sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	self.origin = ((self.absmin + self.absmax) * 0.5);
	setorigin (self, self.origin);	
	make_breakable_debris ();
	
	remove (self);
};

void () func_breakable_killed =
{
	activator = damage_attacker;
	SUB_UseTargets ();
	func_breakable_die ();
};

void () func_breakable_use =
{
	activator = other;
	SUB_UseTargets ();
	func_breakable_die ();
};

/*QUAKED func_breakable (0 .5 .8) ? NO_MONSTERS
A visible object that can be destroyed by shooting it. If it has a targetname, it will not be directly damageable.

NO_MONSTERS: object ignores damage from monsters

"health" Default 20

"cnt" number of pieces of debris to spawn. default 6.

"style" The style of the debris:
0 = green metal (default)
1 = red metal
2 = concrete
*/
void () func_breakable =
{
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	setmodel (self, self.model);
	precache_model ("progs/debris.mdl");
	precache_sound ("misc/metal_impact.wav");
	precache_sound ("misc/conc_impact.wav");	
	
	if(!self.bloodtype)
		self.bloodtype = SPAWN_DIRT;

	if (self.style == 2)
		{
		self.noise1 = "misc/conc_impact.wav";
		}
	else 
		{
		self.noise1 = "misc/metal_impact.wav";
		}
		
	if (!self.health) 
		self.health = 20;
	if (!self.cnt) 
		self.cnt = 6;
		
	if (self.targetname)
	{
		self.use = func_breakable_use;
	}
	else
	{
		self.takedamage = DAMAGE_YES;
		self.th_die = func_breakable_killed;
	}
	
};

/*
===============================================================================
func_explobox
===============================================================================
*/
void () func_explobox_explode =
{
	self.takedamage = DAMAGE_NO;
	self.origin = ((self.absmin + self.absmax) * 0.5);
	self.classname = "explo_box";

	SUB_UseTargets();

	T_RadiusDamage (self, self, self.dmg, world);
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
	BecomeExplosion ();
	sound (self, CHAN_VOICE, "weapons/r_exp3.wav", 1, ATTN_NORM);
};

void () func_explobox_die =
{
	self.nextthink = 0.2; //for some reason, time + 0.2 doesn't work
	self.think = func_explobox_explode;
};

/*QUAKED func_explobox (0 .5 .8) ? START_OFF
An exploding brush entity.  Works just like misc_explobox.

Keys: 

"health" Default 20

"dmg" default 100

*/
void () func_explobox =
{
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	setmodel (self, self.model);
	precache_sound ("weapons/r_exp3.wav");
	if (!self.health)
	{
		self.health = 20;
	}
	if (!self.dmg)
	{
		self.dmg = 100;
	}
	self.th_die = func_explobox_die;
	self.takedamage = DAMAGE_AIM;
};

/*
===============================================================================
func_laser
===============================================================================
*/

void() laser_helper_think =
{
	if (!self.owner || self.owner.classname != "func_laser") {
		remove(self);
		return;
	}
	
	if (self.owner.state)
		self.owner.alpha = self.alpha * 0.8 + self.alpha * random() * 0.4;
			
	self.nextthink = time + 0.05;
};

void() func_laser_touch = {
	if (other.takedamage && self.attack_finished < time) {
		T_Damage (other, self, self, self.dmg);
		self.attack_finished = time + 0.1;
	}

};

void () func_laser_use = {
	if (!self.state) {
		setmodel (self, self.origmodel);
		self.touch = func_laser_touch;

		if (self.spawnflags & LASER_SOLID)
			self.movetype = MOVETYPE_PUSH; //required becuase of SOLID_BSP

		sound (activator, CHAN_VOICE, "misc/laser_on.wav", 1, ATTN_NORM);

		if (activator.classname == "player" && self.message != "")
			centerprint (activator, self.message);

		self.state = 1;
	}
	else {
		setmodel (self, "");
		self.touch = SUB_Null;
		
		if (self.spawnflags & LASER_SOLID)
			self.movetype = MOVETYPE_NONE;

		sound (activator, CHAN_VOICE, "misc/laseroff.wav", 1, ATTN_NORM);
		
		if (activator.classname == "player" && self.message2 != "")
			centerprint (activator, self.message2);

		self.state = 0;
	}
};

/*QUAKED func_laser (0 .5 .8) ? START_OFF LASER_SOLID
A togglable laser, hurts to touch, can be used to block players

START_OFF: Laser starts off.

LASER_SOLID: Laser blocks movement while turned on.

Keys:

"dmg" damage to do on touch. default 1

"alpha" approximate alpha you want the laser drawn at. default 0.5. alpha will vary by 20% of this value.

"message" message to display when activated

"message2" message to display when deactivated

*/

void () func_laser =
{
	local entity helper;
	
	self.origmodel = self.model;
	
	if (self.spawnflags & LASER_SOLID)
		self.solid = SOLID_BSP; //so you can shoot between lasers in a single bmodel
	else {
		setmodel (self, self.origmodel);
		self.solid = SOLID_TRIGGER;
	}

	precache_sound ("misc/laser_on.wav");
	precache_sound ("misc/laseroff.wav");
	
	if (!self.alpha)
		self.alpha = 0.5;
		
	if (!self.dmg)
		self.dmg = 1;
	else if (self.dmg == -1)
		self.dmg = 0;
		
	self.use = func_laser_use;

	//inverted so the use function it can be run on init
	if (self.spawnflags & START_OFF)
		self.state = 1; 
	else
		self.state = 0;
	
	//spawn a second entity to handle alpha changes, since MOVETYPE_PUSH doesn't support think functions
	helper = spawn();
	helper.alpha = self.alpha;
	helper.owner = self;
	helper.nextthink = 0.05;
	helper.think = laser_helper_think;

	func_laser_use();
};

/*
===============================================================================
item_circuitboard
===============================================================================
*/

void () circuitboard_touch =
{
	if (other.classname != "player")
	{
		return;
	}
	if (other.health <= 0)
	{
		return;
	}
	stuffcmd (other, "bf\n");
	centerprint (other, self.message);
	sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	activator = other;
	SUB_UseTargets ();
	remove (self);
};

/*QUAKED item_circuitboard (0 .5 .8) (-16 -16 -24) (16 16 32)
collectible circuit board thing
*/
void () item_circuitboard =
{
	if(!self.mdl) self.mdl = "progs/fromitz.mdl";
	precache_model (self.mdl);
	setmodel (self, self.mdl);

	if(!self.message) self.message = "You got the 17-centimeter Fromitz board!";
	if(!self.noise) self.noise = "items/protect.wav";

	precache_sound (self.noise);

	self.touch = circuitboard_touch;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};

/*
===============================================================================
light_fixture1
===============================================================================
*/

/*QUAKED light_fixture1 (0 1 0) (-8 -8 -8) (8 8 24)
wall-mounted light fixture.
Default light value is 300
Default style is 0

Keys:
"angle2" is the angle the model should be facing; set it to face away from the wall
*/
void() light_fixture1 =
{
	precache_model ("progs/fixture1.mdl");
	setmodel (self, "progs/fixture1.mdl");
	self.angles_y = self.angle2;
	makestatic (self);
};


/*
===============================================================================
light_beacon
===============================================================================
*/

/*QUAKED light_beacon (0 1 0) (-8 -8 -36) (8 8 8) BLINKING
floor-mounted flashing red beacon
Default light value is 300
Default style is 0

Flags:
"Blinking" if you want the beacon to blink (Set style to "16" to match the skin animation.)

Keys:
"angle2" can be used to rotate the model
*/
void() light_beacon =
{
	precache_model ("progs/beacon.mdl");
	setmodel (self, "progs/beacon.mdl");
	if (self.spawnflags & 1)
		self.skin = 1;
	self.angles_y = self.angle2;
	makestatic (self);
};

/*
===============================================================================
misc_flag
===============================================================================
*/

/*QUAKED misc_flag (1 0 0) (-8 -8 -8) (8 8 8) NOT_ANIMATED BIG
A hanging banner, gently waving in the wind. Normal dimensions: 64 wide by 144 long.

Flags:
"Not Animated" Banner is not animated.
"Big" Banner is twice as big: 128 wide by 288 long.
*/
void () misc_flag =
{
	precache_model ("progs/flag.mdl");
	setmodel (self, "progs/flag.mdl");
	self.frame = (self.spawnflags & 3);
	makestatic (self);
};

/*
===============================================================================
misc_sparks
===============================================================================
*/

void()	sparks_fade1 = [0, sparks_fade2] {self.alpha = 0.8; self.nextthink = time + 0.05;};
void()	sparks_fade2 = [0, sparks_fade3] {self.alpha = 0.6; self.nextthink = time + 0.05;};
void()	sparks_fade3 = [0, sparks_fade4] {self.alpha = 0.4; self.nextthink = time + 0.05;};
void()	sparks_fade4 = [0, SUB_Remove]   {self.alpha = 0.2; self.nextthink = time + 0.05;};

void() sparks_use =
{
	if (self.spawnflags & START_OFF)
		self.spawnflags = self.spawnflags - START_OFF;
	else
		self.spawnflags = self.spawnflags + START_OFF;
};

void() make_sparks;

void() spark_turnofflight = 
{
	SUB_UseTargets();
	self.think = make_sparks;
	self.nextthink = time + (random() + 0.5)*self.wait - 0.15;
}

void() make_sparks =
{
	  
	if (self.spawnflags & START_OFF)
	{
		self.nextthink = time + 0.1;
		self.think = make_sparks;
	}
	else
	{
		local float i;
		i = -0.25*self.cnt + random()*0.5*self.cnt;
		while (i < self.cnt)
		{
			
			local entity spark;
			spark = spawn();
			spark.owner = self;
			setmodel (spark, "progs/spark.mdl");
			setorigin (spark, self.origin);
			spark.movetype = MOVETYPE_BOUNCE;
			spark.solid = SOLID_TRIGGER;
			spark.gravity = 0.3;
			spark.velocity_x = -40 + random() * 80;
			spark.velocity_y = -40 + random() * 80;
			spark.velocity_z = -40 + random() * 80;
			spark.avelocity = '3000 3000 3000';
			spark.nextthink = time + 0.5 + 1.5*random();
			spark.think = sparks_fade1;
			spark.classname = "spark";
			
			if (random() < 0.33)
				spark.skin = 0;
			else if (random() < 0.5)
				spark.skin = 1;
			else
				spark.skin = 2;
				
			if (self.spawnflags & SPARKS_PALE)
				spark.skin = spark.skin + 6;
			else if (self.spawnflags & SPARKS_BLUE)
				spark.skin = spark.skin + 3;
			
			setsize (spark, '0 0 0', '0 0 0');
			i = i + 1;
		}
		if (self.sounds == 1)
			sound (self, CHAN_AUTO, "misc/spark.wav", 1, ATTN_STATIC);
		SUB_UseTargets();
		self.nextthink = time + 0.1 + random() * 0.1;
		self.think = spark_turnofflight;

	}
	
};

/*QUAKED misc_sparks (0 .5 .8) (-8 -8 -8) (8 8 8) START_OFF SPARKS_BLUE SPARKS_PALE
Produces a burst of yellow sparks at random intervals. If targeted, it will toggle between on or off.  If it targets a light, that light will flash allong with each burst of sparks. Note: targeted lights should be set to START_OFF.

SPARKS_BLUE: sparks are blue in color

SPARKS_PALE: sparks are pale yellow in color

Keys:

"wait" is the average delay between bursts (variance is 1/2 wait). Default is 2. 

"cnt" is the average number of sparks in a burst (variance is 1/4 cnt). Default is 15.

"sounds"
0)	no sound
1)	sparks
*/
void() misc_sparks =
{
	precache_model ("progs/spark.mdl");
	precache_sound ("misc/spark.wav");
		
	if (!self.movedir)
		self.movedir = '0 0 -30';
	if (!self.wait)
		self.wait = 2;
	if (!self.cnt)
		self.cnt = 15;
	
	self.use = sparks_use;
	self.nextthink = time + random()*0.1;
	self.think = make_sparks;
};

/*
===============================================================================
misc_smoke
===============================================================================
*/

void() smoke_touch =
{
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (self.dmg > 0 && other.health)
	{
		T_Damage (other, self, self, self.dmg);
		self.dmg = 0;
	}	
	self.velocity = '0 0 0'; //FIXME: can't set velocity in a touch function
	self.movedir = '0 0 0';
	self.movedir2 = '0 0 15';
};

void() smoke_rise =
{
	
	self.cnt = self.cnt + 1;
	if (self.cnt > 6)
	{
		remove(self);
		return;
	}
	self.frame = self.cnt;
	self.velocity = self.velocity + self.movedir2 - (self.movedir * 0.12);
	self.nextthink = time + 0.1 + random() * 0.05;
	self.think = smoke_rise;
};

void() smoke_think =
{
	if (self.spawnflags & START_OFF)
	{
		self.think = smoke_think;
		self.nextthink = time + 0.1;
	}
	else
	{
		local entity smoke;
		smoke = spawn();
		smoke.owner = self;
		setmodel (smoke, "progs/s_smoke.spr");
		setorigin (smoke, self.origin);
		smoke.movetype = MOVETYPE_FLY; //MOVETYPE_NOCLIP or MOVETYPE_FLY ?
		smoke.solid = SOLID_BBOX; //was SOLID_TRIGGER or SOLID_BBOX?
		smoke.velocity_x = self.movedir_x - 10 + random() * 20;
		smoke.velocity_y = self.movedir_y - 10 + random() * 20;
		smoke.velocity_z = self.movedir_z - 10 + random() * 20;
		smoke.angles_z = random() * 360;
		smoke.nextthink = time + 0.1 + random() * 0.05;
		smoke.think = smoke_rise;
		smoke.touch = smoke_touch;
		smoke.classname = "smoke";
		smoke.dmg = self.dmg;
		smoke.movedir2 = self.movedir2;
		smoke.frame = 0;
		smoke.cnt = 0;
		setsize (smoke, '0 0 0', '0 0 0');
		
		self.think = smoke_think;
		self.nextthink = time + self.wait;

		if (self.sounds)
		{
			local entity e;
			local float dist;
			
			//loop through players and see if any are at the outer audible range for this emitter
			//if yes, restart the loop sound in case they were too far away when it started playing
			//if a second player is well inside the radius, they will hear somewhat degraded sound
			//but it can't be helped
			e = find(world, classname, "player");
			while(e)
			{
				dist = vlen(self.origin - e.origin);
				if (300 < dist && dist < 350)
				{
					sound (self, CHAN_VOICE, "misc/airhiss.wav", 1, ATTN_STATIC);
					return;
				}
				e = find(e, classname, "player");
			}
		}
	}
	
};

void() smoke_use =
{
	if (self.spawnflags & START_OFF)
	{
		self.spawnflags = self.spawnflags - START_OFF;
		if (self.sounds)
			sound (self, CHAN_VOICE, "misc/airhiss.wav", 1, ATTN_STATIC);
	}
	else
	{
		self.spawnflags = self.spawnflags + START_OFF;
		if (self.sounds)
			sound (self, CHAN_VOICE, "misc/airhiss2.wav", 1, ATTN_STATIC);
	}
};

void() smoke_firstthink =
{
	if (self.sounds)
		if (!(self.spawnflags & START_OFF))
			sound (self, CHAN_VOICE, "misc/airhiss.wav", 1, ATTN_STATIC);

	smoke_think();
};

/*QUAKED misc_smoke (0 .5 .8) (-8 -8 -8) (8 8 8) START_OFF
Produces a jet of smoke/steam. If targeted, it will toggle between on or off.

Keys:

"wait" is the delay between puffs. Default is 0.1

"movedir" is a vector representing the initial velocity in X Y Z values.  Default is "0 0 250" (up)

"movedir2" is a vector representing the wind in X Y Z values.  Default is "0 0 0"

"dmg" is the amount of damage each puff gives on contact. Default is 0

"sounds"
0)	no sound
1)	steam hiss
*/
void() misc_smoke =
{
	precache_model ("progs/s_smoke.spr");
	precache_sound ("misc/airhiss.wav");
	precache_sound ("misc/airhiss2.wav");
	
	if (!self.dmg)
		self.dmg = 0;
	if (!self.movedir)
		self.movedir = '0 0 250';
	if (!self.movedir2)
		self.movedir2 = '0 0 0';
	if (!self.wait)
		self.wait = 0.1;
						
	self.use = smoke_use;
	self.nextthink = time + 0.5;
	self.think = smoke_firstthink;
};


/*
===============================================================================
misc_splash
===============================================================================
*/

void() splash_think =
{
	local vector vec;
	local float variance;
	variance = vlen(self.movedir) / 2;
	vec_x = self.movedir_x - variance + random() * variance * 2;
	vec_y = self.movedir_y - variance + random() * variance * 2;
	vec_z = self.movedir_z - variance + random() * variance * 2;
	particle (self.origin, vec, self.color, self.volume);
	self.nextthink = time + self.wait;
}

/*QUAKED misc_splash (0 .5 .8) (-8 -8 -8) (8 8 8)
Produces a continuous particle splash for waterfalls

"color" color of particles.  0 through 15, corresponds to a row of the quake palette. (default 0)

"movedir" average movement vector of particles (default 0 0 4)

"wait" time between particle generation cycles.  (default 0.1)

"volume" density of particles. (default 10)
*/
void() misc_splash =
{
	if (!self.wait)
		self.wait = 0.1;
	if (!self.movedir)
		self.movedir = '0 0 4';
	if (!self.volume)
		self.volume = 10;
	self.color = self.color * 16;

	self.nextthink = time + self.wait;
	self.think = splash_think;
};



/*
===============================================================================
trigger_ladder
===============================================================================
*/

void() ladder_touch =
{
	if (other.classname != "player")
		return;

	// if the trigger has an angles field, check player's facing direction
	if (self.movedir != '0 0 0')
	{
		makevectors (other.angles);
		if (v_forward * self.movedir < 0)
			return;		// not facing the right way
	}
	other.onladder = 1;
	other.gravity = 0.0000001; //zero doesnt seem to work
}

/*QUAKED trigger_ladder (.5 .5 .5) ?
invisible ladder entity. when player is touching this entity, he can climb by pushing 'jump'

Keys:

"angle" the direction player must be facing to climb ladder
*/
void() trigger_ladder =
{
	InitTrigger ();
	self.touch = ladder_touch;
};