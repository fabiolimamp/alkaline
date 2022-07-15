/*
================================================================

FX

================================================================
*/

void(vector org) gunshot =
{
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_GUNSHOT);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
}

void(vector a, vector b, entity who) fx_beam =
{
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_LIGHTNING1);
	WriteEntity (MSG_BROADCAST, who);
	WriteCoord (MSG_BROADCAST, a_x);
	WriteCoord (MSG_BROADCAST, a_y);
	WriteCoord (MSG_BROADCAST, a_z);
	WriteCoord (MSG_BROADCAST, b_x);
	WriteCoord (MSG_BROADCAST, b_y);
	WriteCoord (MSG_BROADCAST, b_z);
}

// explosion particle effect. Also fires up explosion sound automatically as well as a dlight
void(vector org) fx_explosion_particle = {
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
}

// only the isolated particle effect
void(vector org) fx_explosion_particle2 = {
	particle(org, '0 0 0', 0, 255);
}

void()	s_explode1	=	[0,		s_explode2] {nxth(self.wait);}
void()	s_explode2	=	[1,		s_explode3] {nxth(self.wait);}
void()	s_explode3	=	[2,		s_explode4] {nxth(self.wait);}
void()	s_explode4	=	[3,		s_explode5] {nxth(self.wait);}
void()	s_explode5	=	[4,		s_explode6] {nxth(self.wait);}
void()	s_explode6	=	[5,		SUB_Remove] {nxth(self.wait);}

void()	s_explodelg1	=	[0,		s_explodelg2] {nxth(self.wait);}
void()	s_explodelg2	=	[1,		s_explodelg3] {nxth(self.wait);}
void()	s_explodelg3	=	[2,		s_explodelg4] {nxth(self.wait);}
void()	s_explodelg4	=	[3,		s_explodelg5] {nxth(self.wait);}
void()	s_explodelg5	=	[4,		s_explodelg6] {nxth(self.wait);}
void()	s_explodelg6	=	[5,		s_explodelg7] {nxth(self.wait);}
void()	s_explodelg7	=	[6,		s_explodelg8] {nxth(self.wait);}
void()	s_explodelg8	=	[7,		s_explodelg9] {nxth(self.wait);}
void()	s_explodelg9	=	[8,		s_explodelg10] {nxth(self.wait);}
void()	s_explodelg10	=	[9,		s_explodelg11] {nxth(self.wait);}
void()	s_explodelg11	=	[10,		s_explodelg12] {nxth(self.wait);}
void()	s_explodelg12	=	[11,		s_explodelg13] {nxth(self.wait);}
void()	s_explodelg13	=	[12,		SUB_Remove] {nxth(self.wait);}

/*
========
BecomeBlast

Turns self into the animating blast sprite only (no sounds/particles).
========
*/
void() BecomeBlast = 
{
	self.movetype = MOVETYPE_FLY;
	self.solid = SOLID_TRIGGER;
	self.flags -= self.flags & FL_ONGROUND;
	
	self.velocity = '0 0 0';
	self.touch = SUB_Null;

	if (other.classname == "monster_shambler"){
		setmodel (self, "progs/s_explo2.spr");
		self.wait = 0.05;
	}
	else if (self.classname == "grenade"){
		setmodel (self, "progs/s_explod.spr");
		self.wait = 0.05;
	}
	else {
		setmodel (self, "progs/s_exp_small.spr");
		self.wait = 0.1;
	}

	self.classname = "explosion";
	setsize(self, '-8 -8 -8', '8 8 8');

	// Correction for explosions happening on horizontal surfaces
	// not getting detected by trigger_everything (why??)
	traceline(self.origin, self.origin - '0 0 17', TRUE, world);
	//dprint2(ftos(trace_fraction), "\n");
	if (trace_fraction < 0.5)
		force_retouch = 2;

	// moves explosion a bit off the ground
	if (self.model == "progs/s_explod.spr") setorigin(self, self.origin + [0, 0, 17 - (trace_fraction * 17)]);

	self.nextthink = time + 0.5;
	self.think = SUB_Remove;
	if (self.model == "progs/s_explod.spr") s_explodelg1();
	else s_explode1();
}


/*
========
BecomeExplosion

Turns self into a complete explosion - with blast sprite, particles and sound effect.
Entity gets removed at the end.
Damage must be applied separately.
========
*/
void() BecomeExplosion =
{
	fx_explosion_particle(self.origin);
	BecomeBlast();
}


/*
========
TriggerExplosion

Spawns a complete, damage-less explosion at self's origin.
Doesn't affect triggering entity.
========
*/
inline void() TriggerExplosion =
{
	SpawnExplosion(self.origin, 0, self, 0);
}


/*
========
SpawnExplosion

Spawns and returns a complete explosion entity at the specified origin.
Can have radius damage.
========
*/
entity(vector org, float damg, entity parent, float multi) SpawnExplosion =
{
	local entity boom;
	
	boom = spawn();
	setorigin(boom, org);
	boom.nextthink = time;
	boom.think = BecomeExplosion;
	
	if (damg > 0) T_RadiusDamage (boom, parent, damg, boom, DMGTYPE_EXPLOSION);
	
	return boom;
}

void()	shockwave1	=[	0,	shockwave2	] {self.skin = 0; self.nextthink = time + 0.05;}
void()	shockwave2	=[	1,	shockwave3	] {self.skin = 1; self.nextthink = time + 0.05;}
void()	shockwave3	=[	2,	shockwave4	] {self.skin = 2; self.nextthink = time + 0.05;}
void()	shockwave4	=[	3,	shockwave5	] {self.skin = 3; self.nextthink = time + 0.05;}
void()	shockwave5	=[	4,	SUB_Remove	] {self.alpha = 0.6; self.nextthink = time + 0.05;}

void()	shockwave6	=[	5,	shockwave7	] {self.skin = 0; self.nextthink = time + 0.05;}
void()	shockwave7	=[	6,	shockwave8	] {self.skin = 0; self.nextthink = time + 0.05;}
void()	shockwave8	=[	7,	shockwave9	] {self.skin = 1; self.nextthink = time + 0.05;}
void()	shockwave9	=[	8,	shockwave10	] {self.skin = 2; self.nextthink = time + 0.05;}
void()	shockwave10	=[	9,	shockwave11	] {self.skin = 3; self.nextthink = time + 0.05;}
void()	shockwave11	=[	10,	SUB_Remove	] {self.alpha = 0.6; self.nextthink = time + 0.05;}

// mostly for Malice monsters

static float DEXPLODE_FRAMETIME = 0.03;

void() d_explode1 = [0, d_explode2]{self.nextthink = time + DEXPLODE_FRAMETIME;};
void() d_explode2 = [1, d_explode3]{self.nextthink = time + DEXPLODE_FRAMETIME;};
void() d_explode3 = [2, d_explode4]{self.nextthink = time + DEXPLODE_FRAMETIME;};
void() d_explode4 = [3, d_explode5]{self.nextthink = time + DEXPLODE_FRAMETIME;};
void() d_explode5 = [4, d_explode6]{self.nextthink = time + DEXPLODE_FRAMETIME;};
void() d_explode6 = [5, d_explode7]{self.nextthink = time + DEXPLODE_FRAMETIME;};
void() d_explode7 = [6, d_explode8]{self.nextthink = time + DEXPLODE_FRAMETIME;};
void() d_explode8 = [7, d_explode9]{self.nextthink = time + DEXPLODE_FRAMETIME;};
void() d_explode9 = [8, d_explode10]{self.nextthink = time + DEXPLODE_FRAMETIME;};
void() d_explode10 = [9, d_explode11]{self.nextthink = time + DEXPLODE_FRAMETIME;};
void() d_explode11 = [10, d_explode12]{self.nextthink = time + DEXPLODE_FRAMETIME;};
void() d_explode12 = [11, d_explode13]{self.nextthink = time + DEXPLODE_FRAMETIME;};
void() d_explode13 = [12, SUB_Remove]{};


void() FuelTankExplode = 
{
	local vector dir;
	self.effects = self.effects | EF_MUZZLEFLASH;
	sound(self, CHAN_AUTO, "weapons/fuelexp.wav", 1, ATTN_NORM);

	fx_explosion_particle(self.origin);

	Fire_bomb(self.origin, dir);
	Fire_bomb(self.origin, dir);
	Fire_bomb(self.origin, dir);
	Fire_bomb(self.origin, dir);
	Fire_bomb(self.origin, dir);
};

void(vector org, vector dir) Fire_bomb = 
{
	//local float x;
	newmis = spawn();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_NOCLIP;
	newmis.solid = SOLID_BBOX;
	newmis.touch = SUB_Remove;
	newmis.flags = newmis.flags | FL_PROJECTILE;

	setorigin(newmis, org);
	setmodel(newmis, "progs/d_explod.spr");
	setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);

	newmis.nextthink = time;
	newmis.think = d_explode1;
	newmis.velocity_x = crandom() * 400;
	newmis.velocity_y = crandom() * 400;
	newmis.velocity_z = random() * 200;
};


/*
================
Impact spawn functions
================
*/

// SpawnBlood and SpawnChunk kept intact only for plug-in compatibility with eventual ported code from other mods
// All new code should implement ImpactSpawn instead
// --bmFbr

void(vector org, vector vel, float damage) SpawnBlood = {
	particle (org, vel*0.1, 73, damage*2);
};

void(vector org, vector vel) SpawnChunk = {
	particle (org, vel*0.02, 0, 10);
};

void(vector org, vector vel, float damage, float bloodtype) ImpactSpawn = {
	if(bloodtype == SPAWN_CHUNK)
		//SpawnChunk(org, vel);
		gunshot(org);
	else if(bloodtype == SPAWN_DIRT)
		particle (org, vel*0.05, 25, damage*2);
	else if(bloodtype == SPAWN_YELLOWSPARK)
		particle (org, vel*0.1, 105, damage);
	else if(bloodtype == SPAWN_WHITESPARK)
		particle (org, vel*0.1, 9, damage);
	else // blood should always be default, so it works either with .bloodtype = 1 (explicit) or 0 (unset)
		SpawnBlood(org, vel, damage);
};


/*
================
spawn_touchblood
================
*/


vector() wall_velocity =
{
	local vector	vel;
	
	vel = normalize (self.velocity);
	vel = normalize(vel + v_up*(random()- 0.5) + v_right*(random()- 0.5));
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;
	
	return vel;
};


void(float damage) spawn_touchblood =
{
	local vector	vel;

	vel = wall_velocity () * 0.2;

	ImpactSpawn(self.origin + vel*0.01, vel, damage, other.bloodtype);	
};



//=============================================================================

//flagrant abuse of particle()


void(vector a, vector b, float color) fx_trail =
{
	local float i, maxd;
	local vector dir;
	maxd = floor(vlen(b-a));
	dir = normalize(b-a);
	
	for (i=0; i<maxd; i+=8)
		particle(a + dir * i, dir, color, 2);
}

void(vector c, float r, float color) fx_ring =
{
	local float segments, ang, i;
	local vector a, b;
	segments = ceil(sqrt(2 * r));
	
	for (i=0; i<segments; i++)
	{
		ang = (360.0/segments) * i;
		makevectors('0 1 0' * ang);
		a = v_forward * r + c;
		ang = (360.0/segments) * (i + 1);
		makevectors('0 1 0' * ang);
		b = v_forward * r + c;
		fx_trail(a,b,color);
	}
}

//============================================================================


float PFIELD_START_ON = 1; 
float PFIELD_INWARD = 2; 
float PFIELD_OUTWARD = 4; 
float PFIELD_BURST = 8;

vector(vector org) particlefield_dir =
{
	vector dir;
	dir = self.movedir;
	if (self.spawnflags & PFIELD_INWARD)	// in
	{
		dir -= org * vlen(self.movedir);
	}
	else if (self.spawnflags & PFIELD_OUTWARD)	// out
	{
		dir += org * vlen(self.movedir);
	}
	return dir;
}

void(float num) particlefield_sweep =
{
	/*
	call x and y the two axes perpendicular to the sweep, z the direction of the sweep
	random x and y are chosen
	z determined by projecting x and y down z axis onto wherever the plane should be
		ie solving plane equation for z by plugging in x and y
		ax + by + cz = d
		cz = d - ax - by
		z = (d-ax-by)/c
	*/
	float d, t, z, frac;
	vector plane, porg;
	
	// self.dest = transformed bounds
	// self.pos1 = transformed velocity
	
	plane = normalize(self.pos1);
	d = vabs(plane) * self.dest * 2;	// total distance
	
	// determine position in the cycle
	t = time - self.attack_finished;
	frac = t / (d / vlen(self.pos1));
	if (frac > 1)
	{
		if (self.spawnflags & PFIELD_BURST)
		{
			self.state = 0;
			return;	// done with a loop
		}
		frac = 0;
		self.attack_finished = time;
	}
	z = d * (frac - 0.5);
	
	while (num > 0)
	{
		num -= 1;
		// choose x and y randomly within field bounds
		porg_x = crandom() * self.dest_x;
		porg_y = crandom() * self.dest_y;
		// solve plane equation to derive z (if sweep vel is non-axial)
		porg_z = (z - plane_x * porg_x - plane_y * porg_y) / plane_z;
		if (fabs(porg_z) > self.dest_z)
			continue;	// reject outside bounds

		// transform result back
		if (self.worldtype == 0)	// sweeping down x
		{
			porg = Vector(porg_z, porg_x, porg_y);
		}
		else if (self.worldtype == 1)	// sweeping down y
		{
			porg = Vector(porg_x, porg_z, porg_y);
		}

		// add self.origin and go
		particle (porg + self.origin, particlefield_dir(porg), self.health, self.speed2);
	}
}

void(float num) particlefield_burst =
{
	vector org, org2;
	while (num > 0)
	{
		num -= 1;
		org = Vector(crandom(), crandom(), crandom());
		org2 = vec_scale(org, self.mangle);
		
		particle (org2 + self.origin, particlefield_dir(org), self.health, self.speed2);
	}
}

void() particlefield_think =
{
	if (self.finaldest == VEC_ORIGIN)
		particlefield_burst(floor(0.5 + self.speed / 10));
	else
		particlefield_sweep(self.speed);
	
	if (self.state)
		self.nextthink = time + self.wait;
}

void() particlefield_use =
{
	if (self.spawnflags & PFIELD_BURST)
	{
		if (self.finaldest == VEC_ORIGIN)
		{
			particlefield_burst(self.speed);
		}
		else
		{
			self.attack_finished = time;
			self.state = 1;
			self.nextthink = time + self.wait;
			particlefield_sweep(self.speed);
		}
		return;
	}
	
	self.state = !self.state;
	if (self.state)
		self.nextthink = time + self.wait;
}


/*FGD
@baseclass = Particlefield [
	spawnflags(flags) = [
		1 : "Start on" : 0
		2 : "Particles are sucked inward" : 0
		4 : "Particles are blown outward" : 0
		8 : "Oneshot burst when triggered" : 0
	]
	speed(integer) : "Clumps per second" : 10
	speed2(integer) : "Dots per clump" : 16
	health(integer) : "Color index (0-255)" : 0
	movedir(string) : "Velocity of particles (x y z)"
	wait(string) : "Interval" : 0.1
	velocity(string) : "Direction of optional sweep effect (x y z)"
]

@Pointclass base(Targetname, Appearflags, Bounds, Particlefield) color(0 160 255) size(16 16 16) = misc_particlefield_box : 
"Makes dots appear continuously within its bounds. Trigger to toggle on/off.

Color Reference:
0-15 grey (higher = lighter)
16-31 dirt brown (higher = lighter)
32-47 sky blue (higher = lighter)
48-63 grass green (higher = lighter)
64-79 red (higher = lighter)
80-95 green/orange (higher = lighter)
96-111 copper/gold (higher = lighter)
112-127 flesh tone (higher = lighter)
128-143 pale purple (higher = darker)
144-159 reddish purple (higher = darker)
160-175 pale beige (higher = darker)
176-191 turquoise (higher = darker)
192-207 yellow (higher = darker)
208-223 deep blue (higher = darker)
224-239 fire/lava (higher = lighter)
240-255 fullbright mess" []

@Solidclass base(Targetname, Appearflags, Particlefield) = misc_particlefield : 
"Makes dots appear continuously within its bounds. Trigger to toggle on/off.

Color Reference:
0-15 grey (higher = lighter)
16-31 dirt brown (higher = lighter)
32-47 sky blue (higher = lighter)
48-63 grass green (higher = lighter)
64-79 red (higher = lighter)
80-95 green/orange (higher = lighter)
96-111 copper/gold (higher = lighter)
112-127 flesh tone (higher = lighter)
128-143 pale purple (higher = darker)
144-159 reddish purple (higher = darker)
160-175 pale beige (higher = darker)
176-191 turquoise (higher = darker)
192-207 yellow (higher = darker)
208-223 deep blue (higher = darker)
224-239 fire/lava (higher = lighter)
240-255 fullbright mess" []

*/
/*QUAKED misc_particlefield_box (0 .6 1) (-8 -8 -8) (8 8 8) START_ON INWARD OUTWARD BURST
Makes dots appear continuously within its bounds. Trigger to toggle on or off. 

"mangle" dimensions of sparkly zone
"speed" number of clumps per second, default 10
"speed2" number of dots per clump, default 16
"health" color index (0-255). quake will use every color in the row (each row is 16 colors)
"movedir" give particles a velocity
"velocity" add a sweep effect - vector specifies direction and speed
"wait" dot interval, default 0.1

Flags:
INWARD		particles are sucked toward origin. additive with movedir.
OUTWARD		particles are blown out from origin. additive with movedir.
BURST		spew one second's worth of particles in one shot when triggered rather than toggling on/off

Color Reference:
0-15 grey (higher = lighter)
16-31 dirt brown (higher = lighter)
32-47 sky blue (higher = lighter)
48-63 grass green (higher = lighter)
64-79 red (higher = lighter)
80-95 green/orange (higher = lighter)
96-111 copper/gold (higher = lighter)
112-127 flesh tone (higher = lighter)
128-143 pale purple (higher = darker)
144-159 reddish purple (higher = darker)
160-175 pale beige (higher = darker)
176-191 turquoise (higher = darker)
192-207 yellow (higher = darker)
208-223 deep blue (higher = darker)
224-239 fire/lava (higher = lighter)
240-255 fullbright mess
*/
void() misc_particlefield_box =
{
	//if (!SUB_ShouldSpawn()) return;
	self.think = particlefield_think;
	self.use = particlefield_use;
	
	if (!self.speed)
		self.speed = 10;
	if (!self.speed2)
		self.speed2 = 16;
	if (!self.wait)
		self.wait = 0.1;
	
	self.mangle = self.mangle * 0.5;
	
	self.finaldest = self.velocity;
	if (self.finaldest != VEC_ORIGIN)
	{
		self.velocity = VEC_ORIGIN;
		// transform so that the sweep axis is locally z to simplify later math
		float x, y, z;
		x = fabs(self.finaldest_x);
		y = fabs(self.finaldest_y);
		z = fabs(self.finaldest_z);
		
		if (z < y || z < x)
		{
			if (y < x)
			{	// sweeping down x
				self.worldtype = 0;
				self.dest = [self.mangle_y, self.mangle_z, self.mangle_x];
				self.pos1 = [self.finaldest_y, self.finaldest_z, self.finaldest_x];
			}
			else
			{	// sweeping down y
				self.worldtype = 1;
				self.dest = [self.mangle_x, self.mangle_z, self.mangle_y];
				self.pos1 = [self.finaldest_x, self.finaldest_z, self.finaldest_y];
			}
		}
		else
		{	// already z
			self.worldtype = 2;	
			self.dest = self.mangle;
			self.pos1 = self.finaldest;
		}
	}

	self.state = self.spawnflags & PFIELD_START_ON;
	if (self.state)
		self.nextthink = time + self.wait;
	
	// innie and outie cancel
	if (self.spawnflags & (PFIELD_INWARD | PFIELD_OUTWARD) == (PFIELD_INWARD | PFIELD_OUTWARD))
		self.spawnflags -= 6;
}

/*QUAKED misc_particlefield (0 .6 1) ? START_ON INWARD OUTWARD BURST
Makes dots appear continuously within its bounds. Trigger to toggle on or off. 

"speed" number of clumps per second
"speed2" number of dots per clump
"health" color index (0-255). quake will use every color in the row (each row is 16 colors)
"movedir" give particles a velocity

Flags:
INWARD		particles are sucked toward origin. additive with movedir.
OUTWARD		particles are blown out from origin. additive with movedir.
BURST		spew one second's worth of particles in one shot when triggered rather than toggling on/off

Color Reference:
0-15 grey (higher = lighter)
16-31 dirt brown (higher = lighter)
32-47 sky blue (higher = lighter)
48-63 grass green (higher = lighter)
64-79 red (higher = lighter)
80-95 green/orange (higher = lighter)
96-111 copper/gold (higher = lighter)
112-127 flesh tone (higher = lighter)
128-143 pale purple (higher = darker)
144-159 reddish purple (higher = darker)
160-175 pale beige (higher = darker)
176-191 turquoise (higher = darker)
192-207 yellow (higher = darker)
208-223 deep blue (higher = darker)
224-239 fire/lava (higher = lighter)
240-255 fullbright mess
*/
void() misc_particlefield =
{
	setmodel(self,self.model);
	self.mangle = self.size;
	setorigin(self,(self.absmin + self.absmax) * 0.5);
	self.modelindex = 0;
	self.model = string_null;
	self.mins = self.maxs = self.size = VEC_ORIGIN;
	misc_particlefield_box();
}

//=============================================================================


void(entity targ, float mag) screenshake_go =
{
	mag = mag + 1;
	
	// punchangle doesn't work when we're in an intermission camera, so do
	// this with actual angle offsets when intermission_running > 0
	if (intermission_running)
	{
		local vector kick;
		kick_x = (random()- 0.5) * mag;
		kick_y = (random()- 0.5) * mag;
		kick_z = (random()- 0.5) * mag * 2;
		targ.angles = kick;
		targ.angles_z = kick_z;
		targ.fixangle = 1;
		return;
	}	
	
/*	local vector kick;
	kick_x = (-0.5 + random()) * mag;
	kick_y = (-0.5 + random()) * mag;
	kick_z = (-0.5 + random()) * mag;
	targ.angles = targ.v_angle + kick;
	targ.angles_z = kick_z;
	targ.fixangle = 1;		// turn this way immediately*/

	targ.punchangle_x = random() * mag * 2 - mag;
	targ.punchangle_y = random() * mag * 2 - mag;
	
	// punchangle seems to get integerized, so we need some kind of
	// activity when the magnitude is low so it feels like a faint 
	// rumble instead of just a dying fish kicking occasionally
	mag = mag * 2;	// the rolls feel a lot less violent, so bump them up a little
	
	targ.punchangle_z = random() * mag * 2 - mag;
}

void() screenshake_think =
{
	entity t;
	float mag, dmag;
	
	if (time > self.pain_finished)
	{
		t = nextent(world);
		while (t.classname == "player")
		{
			t.v_angle_z = 0;	// unroll
			t = nextent(t);
		}
		self.state = 0;
		return;
	}
	
	if (time < self.super_time + self.delay)
	{
		self.state = 1;
		mag = 1 - ((self.super_time + self.delay) - time) / self.delay;
	}
	else if (time < self.super_time + self.delay + self.length)
	{
		self.state = 2;
		mag = 1;
	}
	else if (time < self.pain_finished)
	{
		mag = (self.pain_finished - time) / self.wait;
		self.state = 3;
	}
	else mag = 0;
	
	mag *= mag;	// power of 2 falloff seems smoother than linear
	
	t = nextent(world);
	while (t.classname == "player")
	{
		dmag = 1;
		if (self.distance)
			dmag = max(0, 1 - (vlen(self.origin - t.origin) / self.distance));
		if (dmag > 0)
			screenshake_go(t, self.strength * mag * dmag * dmag);
		t = nextent(t);
	}

	self.nextthink = time + 0.05;
}

void() screenshake_use =
{
	self.pain_finished = time + self.wait + self.delay + self.length;
	self.super_time = time;
	self.nextthink = time + 0.05;
	self.think = screenshake_think;
}


/*QUAKED target_screenshake (0 .5 .8) (-8 -8 -8) (8 8 8)
Shakes the screen. Jostles the view of all clients, but doesn't physically move their bounding boxes or apply velocities.
Keys
"length" Duration of full intensity quake. -1 will last literally forever.
"delay" Time to ramp up quake intensity from 0
"wait" Time to ramp down quake intensity to 0. Total quake duration is length + delay + wait.
"strength" Intensity of quake. 1 is a hearty rumble, 10 is spasmodic bordering on hilarious.
"distance" Fade the intensity to 0 at this distance from the entity. Default is 0 (global).
*/
/*FGD
@Pointclass base(Targetname, Appearflags) color(0 128 224) size(16 16 16) = target_screenshake : 
"Shakes the screen. Jostles the view of all clients, but doesn't physically move their bounding boxes or apply velocities.
Total shake duration is length + delay + wait." 
[
	length(string) : "Duration of full intensity (sustain)"
	delay(string) : "Time to ramp up from 0 (attack)"
	wait(string) : "Time to ramp down quake intensity to 0."
	strength(string) : "Intensity of quake. 1 is a hearty rumble, 10 is spasmodic bordering on hilarious." : "1.0"
	distance(integer) : "Attenuation distance; 0 is global" : 0
]
*/
void() target_screenshake =
{
	//if (!SUB_ShouldSpawn()) return;
	self.wait = max(0, self.wait);
	self.delay = max(0, self.delay);
	self.length = max(0, self.length);
	self.distance = max(0, self.distance);
	
	if (!self.delay && !self.length && !self.wait)
		dprint("misc_screenshake will last 0 seconds\n");

	if (!self.strength)
	{
		if (self.volume)
			objerror("convert target_screenshake to .strength please");
		
		self.strength = 10;	// set your own value goddamnit
	}
	self.use = screenshake_use;
}


void(float attack, float sustain, float release, float str) screenshake_oneshot =
{
	entity shake, oself;
	
	shake = spawn();
	
	shake.delay = attack;
	shake.length = sustain;
	shake.wait = release;
	shake.strength = str;
	
	oself = self;
	self = shake;
	
	target_screenshake();
	screenshake_use();
	
	self = oself;
}

//============================================================================

void() target_explosion_go =
{
	//if (self.dmg) T_RadiusMultiDamage (self, self, self.dmg, self, 0);
	if (self.dmg) T_RadiusDamage (self, self, self.dmg, self, DMGTYPE_EXPLOSION);
	BecomeExplosion();
}

void() target_explosion_use =
{
	float i, tnext;
	entity bewm;
	
	playercount_convert(count);
	if (self.count == 1 && self.delay == 0)
	{
		SpawnExplosion(self.origin, self.dmg, self, 0);
		return;
	}
	
	tnext = self.delay + self.rand * random();
	for (i = 0; i < self.count; i++)
	{
		bewm = spawn();
		setorigin(bewm, self.origin);
		bewm.think = target_explosion_go;
		bewm.nextthink = time + tnext;
		bewm.dmg = self.dmg;
		tnext += self.wait + random() * self.rand;
	}
}

/*QUAKED target_explosion (0 .5 .8) (-8 -8 -8) (8 8 8) 
Causes explosions, same appearance as a rocket/grenade blast.

Keys
"count" number of times to explode after triggering, default 1
"delay" Time to wait before first explode
"wait" Static time to wait between explosions
"rand" Random time to wait before explosions (will sum both)
"dmg" Do splash damage, default 0
*/
/*FGD
@Pointclass base(Targetname, Appearflags, Deathtype) color(0 128 224) size(16 16 16) = target_explosion : 
"Causes explosions, same appearance as a rocket/grenade blast." 
[
	count(integer) : "Repeat count" : 1
	delay(string) : "Delay before first blast" : "0"
	wait(string) : "Wait between blasts" : "1"
	rand(string) : "Random extra wait before blasts" : "0"
	dmg(integer) : "Splash damage" : 0
]
*/
void() target_explosion = {
	self.count = zeroconvertdefault(self.count, 1);
	self.use = target_explosion_use;
	if (!self.wait)
		self.wait = 1;
	if (self.obituary == string_null)
		self.obituary = "joins the smithereens";
}

//============================================================================

void() teleport_flasher =
{
	spawn_tfog(self.origin);
	remove(self);
}

void() target_telefog_use =
{
	float i, tnext;
	entity tfog;
	
	playercount_convert(count);
	if (self.count == 1 && self.delay == 0)
	{
		//teleport_flash();
		spawn_tfog(self.origin);
		return;
	}
	
	tnext = self.delay + self.rand * random();
	for (i = 0; i < self.count; i++)
	{
		tfog = spawn();
		setorigin(tfog, self.origin);
		tfog.think = teleport_flasher;
		tfog.nextthink = time + tnext;
		tnext += self.wait + self.rand * random();
	}
}

/*QUAKED target_telefog (0 .5 .8) (-8 -8 -8) (8 8 8) 
Causes a flash of teleport fog.

Keys
"count" number of times to flash after triggering, default 1
"delay" Time to wait before first flash
"wait" Static ime to wait between flashes
"rand" Random time to wait before flashes (will sum both)
*/
/*FGD
@Pointclass base(Targetname, Appearflags) color(0 128 224) size(16 16 16) = target_telefog : 
"Causes a flash of teleport fog." 
[
	count(integer) : "Repeat count" : 1
	delay(string) : "Delay before first flash" : "0"
	wait(string) : "Wait between flashes" : "1"
	rand(string) : "Random extra before flashes" : "0"
]
*/
void() target_telefog =
{
	//if (!SUB_ShouldSpawn()) return;
	self.count = zeroconvertdefault(self.count, 1);
	self.use = target_telefog_use;
	if (!self.wait)
		self.wait = 1;
}




//============================================================================

//	bubbas

void() make_bubbles;
void() bubble_remove;
void() bubble_bob;

entity(vector org) bubble_spawn =
{
	entity	bubble;

	bubble = spawn();
	setmodel (bubble, "progs/s_bubble.spr");
	setorigin (bubble, org);
	bubble.movetype = MOVETYPE_NOCLIP;
	bubble.solid = SOLID_NOT;
	setsize (bubble, '-8 -8 -8', '8 8 8');
	bubble.velocity = '0 0 18';
	
	bubble.nextthink = time + 0.25;
	bubble.think = bubble_bob;
	bubble.touch = SUB_RemoveSoon;
	bubble.classname = "bubble";
	if (random() < 0.2)
	{
		bubble.frame = 1;
		bubble.cnt = 11;
	}
	else
	{
		bubble.frame = 0;
		bubble.cnt = 0;
	}
	return bubble;
}

void() air_bubbles_use =
{
	self.state = !(self.state);
	self.think = make_bubbles;
	if (self.state)
	{
		self.nextthink = 0;
		return;
	}
	self.nextthink = time + random() * self.rand + self.wait;
}

/*QUAKED air_bubbles (0 .5 .8) (-8 -8 -8) (8 8 8) START_OFF
air bubble emitter. always bubbles.
"wait" bubble interval, default 1
"rand" random extra interval, default 0
*/
/*FGD
@PointClass base(Appearflags, Targetname) color(0 150 220) = air_bubbles : "Air bubbles" 
[
	spawnflags(flags) = [
		1 : "Start off" : 0
	]
	wait(string) : "Bubble interval" : "0.5"
	rand(string) : "Random extra interval" : "1"
]
*/
void() air_bubbles =
{
	//if (!SUB_ShouldSpawn()) return;
	if (deathmatch)
	{
		remove (self);
		return;
	}
	precache_model ("progs/s_bubble.spr");
	self.wait = zeroconvertdefault(self.wait, 1);
	self.rand = zeroconvertdefault(self.rand, 1);
	
	self.think = make_bubbles;
	if (self.targetname != string_null)
	{
		self.use = air_bubbles_use;
		self.state = self.spawnflags & 1;
		if (self.state)
			return;
	}
	self.nextthink = time + self.wait;
}

void() make_bubbles =
{
	if (self.state)
		return;
	
	// fix for 1000cuts using info_nulls with this as a think instead of just
	// placing an air_bubbles, skipping the init and causing every one of the
	// dozens of them to vomit bubbles per frame until the edict limit is hit
	// and the game crashes:
	if (!self.wait && !self.rand)
	{
		self.wait = zeroconvertdefault(self.wait, 1);
		self.rand = zeroconvertdefault(self.rand, 1);
	}
	
	bubble_spawn(self.origin);
	self.nextthink = time + random() * self.rand + self.wait;
	self.think = make_bubbles;
}

void() bubble_split =
{
	if (pointcontents2(self.origin + '0 0 8') != pointcontents2(self.origin))
		return;
		
	entity	bubble;
	bubble = bubble_spawn(self.origin);
	bubble.frame = 1;
	bubble.cnt = floor(9 + random()*4);
	bubble.velocity = self.velocity + '0 0 2';
	self.frame = 1;
	self.cnt = 10;
}

void() bubble_remove =
{
	remove(self);
}

void() bubble_bob =
{
	float		rnd1, rnd2, rnd3;

	if (pointcontents2(self.origin + '0 0 8') != pointcontents2(self.origin))
	{
		SUB_Remove();
		return;
	}
	
	self.cnt = self.cnt + 1;
	if (self.cnt == 10)
		bubble_split();
	if (self.cnt >= 20 + random()*5)
		remove(self);

	rnd1 = self.velocity_x + crandom() * 20;
	rnd2 = self.velocity_y + crandom() * 20;
	rnd3 = self.velocity_z + crandom() * 15;

	if (rnd1 > 10)
		rnd1 = 5;
	if (rnd1 < -10)
		rnd1 = -5;
		
	if (rnd2 > 10)
		rnd2 = 5;
	if (rnd2 < -10)
		rnd2 = -5;
		
	if (rnd3 < 20)
		rnd3 = 25;
	if (rnd3 > 40)
		rnd3 = 35;
	
	self.velocity_x = rnd1;
	self.velocity_y = rnd2;
	self.velocity_z = rnd3;
		
	self.nextthink = time + 0.25;
	self.think = bubble_bob;
}