
float TURRET_STATE_INACTIVE = 0;
float TURRET_STATE_ACTIVATING = 1;
float TURRET_STATE_ACTIVE = 2;
float TURRET_STATE_DEACTIVATING = 3;
float TURRET_STATE_IDLE = 4;

/*
===============================================================================
difficulty tuning functions
===============================================================================
*/

float() TurretMissleSpeed =
{
	return 600;
};

float() TurretRefireTime =
{
	return 0.2;
};

float() TurretTurnSpeed =
{
	return 50 + skill * 20;
};

float TURRET_MAX_PITCH = 6;
float TURRET_MIN_PITCH = -6;

/*
===============================================================================
shooting

these functions are all performed by the helper entity
===============================================================================
*/

void(vector org, vector vec) LaunchLaser;

void() turret_shoot =
{
	local vector ang;
//	local vector v_forward_flat;

	self.effects = self.effects | EF_MUZZLEFLASH;
	sound (self, CHAN_VOICE, "enforcer/enfire.wav", 1, ATTN_NORM);
	
	//calculate pitch based on the enemy's position, but clamp it to a narrow range
	ang = vectoangles(self.enemy.origin - self.origin);
	if (ang_x > 180)
		ang_x = ang_x - 360;	
	if (ang_x > TURRET_MAX_PITCH)
		ang_x = TURRET_MAX_PITCH;
	if (ang_x < TURRET_MIN_PITCH)
		ang_x = TURRET_MIN_PITCH;
	self.angles_x = 0 - ang_x; //invert it because for some reason +pitch is downwards for makevectors() but upwards for vectoangles()
		
	makevectors (self.angles);
	LaunchLaser (self.origin + '0 0 1' * self.angles_x, v_forward); //shift the origin up/down a little so the lasers appear to come out of the red band
	newmis.owner = self.owner;
	newmis.effects = newmis.effects - EF_DIMLIGHT;
};

//returns true if existing enemy is still valid or we found a new valid enemy
float() turret_findtarget =
{
	local entity	e;
	
	if (self.enemy != world)
		e = self.enemy;
	else //get a new enemy
	{
		e = checkclient ();
		if (!e)
			return FALSE;	// current check entity isn't in PVS
	}

	if (e.items & IT_INVISIBILITY)
		return FALSE;

	if (range (e) == RANGE_FAR)
		return FALSE;
		
	if (!visible (e))
		return FALSE;

	if (e.takedamage == DAMAGE_NO)
		return FALSE;	
	
//
// got one
//
	self.enemy = e;
	if (self.enemy.classname != "player")
	{
		self.enemy = self.enemy.enemy;
		if (self.enemy.classname != "player")
		{
			self.enemy = world;
			return FALSE;
		}
	}
		
	return TRUE;
};

void() turret_helper_think =
{
	self.nextthink = time + TurretRefireTime();
	
	if ( self.owner.state != TURRET_STATE_ACTIVE)
		return;
		
	//find enemy
	if (!turret_findtarget())
		return;
		
	//turn towards enemy
	self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
	self.yaw_speed = TurretTurnSpeed() * TurretRefireTime();
	ChangeYaw();
	
	//shoot if enemy is in sight (even if facing wrong way)
	turret_shoot();
};

/*
===============================================================================
movement
===============================================================================
*/

void() turret_hit_bottom =
{
	sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	self.state = TURRET_STATE_INACTIVE;
};

void() turret_go_down =
{
	sound (self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);	
	self.state = TURRET_STATE_DEACTIVATING;
	SUB_CalcMove (self.pos1, self.speed, turret_hit_bottom);
};

void() turret_hit_top =
{
	sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	self.state = TURRET_STATE_ACTIVE;
	
};

void() turret_go_up =
{	
	sound (self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);
	self.state = TURRET_STATE_ACTIVATING;
	SUB_CalcMove (self.pos2, self.speed, turret_hit_top);
};

void() turret_use =
{
	if (self.state == TURRET_STATE_INACTIVE || self.state == TURRET_STATE_DEACTIVATING)
	{
		self.frame = 0;
		turret_go_up();
		self.enemy = activator;
	}
	else if (self.state == TURRET_STATE_ACTIVATING || self.state == TURRET_STATE_ACTIVE)
	{
		self.frame = 1;
		
		//if deactivated after being previously active, use movedir2 to determine position
		self.pos1 = self.origin + self.movedir2;
		turret_go_down();
	}
};


/*
===============================================================================
spawn function
===============================================================================
*/

/*QUAKED func_turret (0 .5 .8) ? START_OFF
A rotating laser shooter that aims at the player in any horizontal direction. Has a capped rotation speed based on skill setting. When triggered, toggles between active and inactive states

START_OFF spawns in the inactive state

place in the level in the active/attacking position for proper lighting.

"movedir" 	the offset from active position to the initial START_OFF position 
"movedir2"  the offset from the active position to the deactivated position (after being previously active)
"height" 	the position that laser originates, measured up from the very bottom of the model
"angle"		determines the initial turret direction (horizontal directions only)
"speed"		speed when moving to a new position
"sounds"	sounds to use when moving to a new position
0)	no sound
1)	stone
2)	base
3)	stone chain
4)	screechy metal
*/

void() func_turret =
{
	if (!SUB_InitEntity()) return;
	
	local entity helper;
	local vector org;

	if (self.sounds == 0)
	{
		precache_sound ("misc/null.wav");
		precache_sound ("misc/null.wav");
		self.noise1 = "misc/null.wav";
		self.noise2 = "misc/null.wav";
	}
	if (self.sounds == 1)
	{
		precache_sound ("doors/drclos4.wav");
		precache_sound ("doors/doormv1.wav");
		self.noise1 = "doors/drclos4.wav";
		self.noise2 = "doors/doormv1.wav";
	}
	if (self.sounds == 2)
	{
		precache_sound ("doors/hydro1.wav");
		precache_sound ("doors/hydro2.wav");
		self.noise2 = "doors/hydro1.wav";
		self.noise1 = "doors/hydro2.wav";
	}
	if (self.sounds == 3)
	{
		precache_sound ("doors/stndr1.wav");
		precache_sound ("doors/stndr2.wav");
		self.noise2 = "doors/stndr1.wav";
		self.noise1 = "doors/stndr2.wav";
	}
	if (self.sounds == 4)
	{
		precache_sound ("doors/ddoor1.wav");
		precache_sound ("doors/ddoor2.wav");
		self.noise1 = "doors/ddoor2.wav";
		self.noise2 = "doors/ddoor1.wav";
	}
	
	precache_model ("progs/laser.mdl");
	precache_sound ("enforcer/enfire.wav");
	precache_sound ("enforcer/enfstop.wav");
		
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	setorigin (self, self.origin);	
	setmodel (self, self.model);
	self.use = turret_use;
	
	if (!self.obituary) self.obituary = "was blasted by a turret";
	
	if (!self.speed)
		self.speed = 100;

	self.pos1 = self.origin + self.movedir; //inactive position
	self.pos2 = self.origin; //active position
	
	//spawn a second entity to handle alpha changes, since MOVETYPE_PUSH doesn't support think functions
	helper = spawn();
	helper.owner = self;
	helper.nextthink = 0.1;
	helper.think = turret_helper_think;
	helper.classname = "turret";
	helper.angles = self.angles;
	org_x = (self.absmin_x + self.absmax_x) / 2;
	org_y = (self.absmin_y + self.absmax_y) / 2;
	org_z = self.absmin_z + self.height;
	setorigin (helper, org);
	
	//set actual angles to 0 now that helper has its angles
	self.angles = '0 0 0';

	//move to initial position
	if (self.spawnflags & START_OFF)
	{
		self.state = TURRET_STATE_INACTIVE;
		setorigin (self, self.pos1);
		self.frame = 1;
	}
	else
	{
		self.state = TURRET_STATE_ACTIVE;
		setorigin (self, self.pos2);
		self.frame = 0;
	}
};
