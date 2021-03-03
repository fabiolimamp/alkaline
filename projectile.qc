/*
================================================================

	PROJECTILES

================================================================
*/

entity(vector org, vector vel, string cname) toss_projectile;
//float(entity tgt, vector start, vector dir) invis_miss_check;

/*
================================================================

PENETRATION AND PASSTHRU

we "patch" the limited options for solid/nonsolid interaction in the quake physics by
overriding the results of said physics in the progs .touch() functions that are called
immediately after.

to emulate objects being nonsolid to each other when quake didn't want them to be,
we respond to their collisions by setting one as the .owner of the other, which causes
quake to ignore their collisions on subsequent frames, then restoring the physics to 
roughly the state they'd be in if SV_Move had not altered their velocities in response to 
that collision. in the case of linear projectiles, this means restoring their starting
velocity, but for TOSS/BOUNCE projectiles it means tracking their always-changing 
velocities constantly with a frequent .think(). thus all grenades, as well as gibs, 
think at 20hz until they come to rest. not ideal, but not seriously so.

this is further complicated by not being able to alter .velocity from the touch function
itself, because at that point quake is in the physics half of the game frame when such
monkeying is not allowed. thus, we have to make our corrections immediately thereafter
in a .think(), while preserving the previous .think() and .nextthink so as not to break 
the projectile's normal behavior (voreball homing, particles, etc).

on all projectiles, .touch must be some function that calls CheckProjectilePassthru() and 
halts if it returns TRUE (representing "not an actual collision"). the check handles all 
consequences behind the scenes.

on ballistic projectiles, .think and .nextthink are overridden, so they cannot be used
for projectile timeout. set .lifetime_finished to the time when projectile should expire, 
and .th_die to the function to call when it does.

================================================================
*/


/*
============
projectile_passthru_think

think function to make a projectile ignore what it just hit
the new owner has been set by this point
============
*/
void() projectile_passthru_think =
{
	self.flags = not(self.flags, FL_ONGROUND);
	self.velocity = self.oldvelocity;
	self.think = self.think1;
	self.nextthink = self.pain_finished;
	
	// nudge the projectile forward a tiny bit to be inside its new owner
	setorigin(self, self.origin + normalize(self.velocity) * 0.1);
	// if the old owner and the new owner are touching at the point that the
	// projectile crosses over, next frame it'll be coincident with both old
	// and new, the trace in sv_move will wind up being allsolid, and the
	// projectile will travel through worldspawn.
}

/*
============
projectile_toss_think

when a passthru overrides server physics for a TOSS projectile, we must 
restore a recent enough velocity that the projectile appeared not to touch.
grenades change velocity every frame, so they have to save it near-continuously
============
*/
void() projectile_toss_think =
{
	if (time > self.lifetime_finished)
	{
		self.th_die();
		return;
	}
	if (self.velocity == VEC_ORIGIN)	// stopped on the ground
	{
		self.think = self.th_die;
		self.nextthink = self.lifetime_finished;
	//	bprint3("at rest, exploding in ", ftos(self.nextthink), " seconds\n");
		self.th_die = SUB_Null;
		self.lifetime_finished = 0;
		self.solid = SOLID_NOT;
		return;
	}
		
	self.flags = not(self.flags, FL_ONGROUND);
	self.oldvelocity = self.velocity;
	self.nextthink = time + 0.05;	// 10hz is probably enough, but 20hz is surely twice as good
}

/*
============
projectile_valid_passthru

returns TRUE in cases where we pass through and should not collide
============
*/
float() projectile_valid_passthru =
{
	// SOLID_NOT entities touch SOLID_BSP by default without generating touch events.
	// gibs had to be made SOLID_BBOX in order to make selectively passing through 
	// notrace/monsterclip even possible, so they need special handling by our owner-
	// changing hackery to ensure they stay nonsolid in the other cases too
	if (self.type == "gib")
	{
		//if (other.movetype == MOVETYPE_PUSH || other.solid == SOLID_BSP)
		//	return other.notrace;
		return TRUE;
	}
	
	if (other.deadflag == DEAD_DYING || // corpses not yet on the ground
		//other.notrace  || 				// specially marked (monsterclip)
		//invis_miss_check(other,self.origin,self.velocity) || 
		other.movetype == MOVETYPE_NOCLIP //|| // ignore noclipping players
		//other == self.trueowner			// still track the original owner - there are cases when monsters 
										// or players firing fat FLYMISSILE projectiles into an adjacent 
										// monsterclip can be hit by them when the owner switches
		)
		return TRUE;
		
	return FALSE;
}

/*
============
projectile_passthru

we can't alter physics stuff to make the projectile physically penetrate during 
touch/physics, so set an immediate think to 'repair' the state of the projectile
============
*/
void() projectile_passthru =
{
	self.owner = other;
	
	// our nextthink was probably to explode or remove, so save that
	self.think1 = self.think;	
	self.pain_finished = self.nextthink;
	
	self.think = projectile_passthru_think;
	self.nextthink = time;
}

/*
============
CheckProjectilePassthru

called within every projectile touch function, returns TRUE if pierced an otherwise solid entity
============
*/
float() CheckProjectilePassthru =
{
	if (!other) return FALSE;	// always collide with world
	if (other == self.owner) return FALSE;	// this actually shouldn't have been called, but: don't touch owner
	
	if (other.classname == "func_void")
	{
		// go away at the bottoms of pits
		SUB_RemoveSoon();
		return TRUE;
	}
	
	// handle overriding the quake physics with our own desired result
	if (projectile_valid_passthru())
	{
		projectile_passthru();
		return TRUE;
	}

	return FALSE;
}

void() projectile_touch_null = { CheckProjectilePassthru(); }





/*
================================================================

	MISSILES

if you're looking for 'newmis' and 'launch_spike' this is where they went

projectile .type: for general behavior (ie any grenade type gets pulled by wind tunnels)
projectile .classname: for specific behavior (knightspike vs wizspike)

projectiles therefore require a classname at the function parameter level
to ensure it never gets left off

================================================================
*/

/*
========
launch_projectile

base linear projectile, does not set model, touch, or damage
speed expected to derive from the length of 'vel'
========
*/
entity(vector org, vector vel, string cname) launch_projectile =
{
	entity prj;
	
	prj = spawn();
	prj.owner = self;
	prj.movetype = MOVETYPE_FLYMISSILE;
	prj.solid = SOLID_BBOX;

	prj.angles = vectoangles(vel);
	
	prj.type = "spike";
	prj.touch = projectile_touch_null;
	prj.th_die = SUB_Remove;
	prj.think = SUB_Remove;
	prj.nextthink = time + 6;

	setsize (prj, VEC_ORIGIN, VEC_ORIGIN);
	setorigin (prj, org);

	prj.velocity = prj.oldvelocity = vel;
	
	prj.classname = cname;
	
	return prj;
}

/*
========
toss_projectile

base ballistic projectile, does not set model, touch, or damage
speed expected to derive from the length of 'vel'
========
*/
entity(vector org, vector vel, string cname) toss_projectile =
{
	entity g;
	g = launch_projectile(org, vel, cname);
	g.movetype = MOVETYPE_BOUNCE;
	g.type = "grenade";
	
	g.think = projectile_toss_think;
	g.nextthink = time;
	g.touch = projectile_touch_null;
	g.th_die = SUB_Remove;
	g.lifetime_finished = time + 6;
	
	return g;
}


//================================================================
