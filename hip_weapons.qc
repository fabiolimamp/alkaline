void() HIP_LaserTouch =
{
	local vector org;
	local vector spot1,spot2;
	local vector oldvel;
	local float r;

	self.owner = world;
	self.cnt = self.cnt + 1;
	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	oldvel = normalize(self.old_velocity);
	spot1 = self.origin - (16*oldvel);
	spot2 = self.origin + (16*oldvel);
	traceline (spot1, spot2, FALSE, self);  // see through other monsters
	self.origin = trace_endpos;

	org = self.origin;

	if (other.health)
    {
		if (self.lastvictim == other)
		{
			self.dmg = self.dmg / 2;
        }
		spawn_touchblood (self.dmg);
		T_Damage(other, self, self.lastvictim, self.dmg);
    }
	else if ((self.cnt == 3) || (random()<0.15))
    {
		gunshot(org);
    }
	else
    {
//		self.dmg = 0.66 * self.dmg;
		self.dmg = 0.9 * self.dmg;
//		self.speed = 0.95 * self.speed;
		self.velocity = oldvel+(2*trace_plane_normal);
		self.velocity = normalize(self.velocity);
		self.velocity = self.speed * self.velocity;
		self.old_velocity = self.velocity;
		if (self.flags & FL_ONGROUND)
			self.flags = self.flags - FL_ONGROUND;
		r = random();
		sound (self, CHAN_WEAPON, "hipweap/laserric.wav", 1, ATTN_STATIC);
/*
		if (r<0.33)
			sound (self, CHAN_WEAPON, "weapons/ric1.wav", 1, ATTN_STATIC);
		else if (r<0.66)
			sound (self, CHAN_WEAPON, "weapons/ric2.wav", 1, ATTN_STATIC);
		else
			sound (self, CHAN_WEAPON, "weapons/ric3.wav", 1, ATTN_STATIC);
*/
		return;
    }
	sound (self, CHAN_WEAPON, "enforcer/enfstop.wav", 1, ATTN_STATIC);
	remove(self);
};

void() HIP_LaserThink =
{
	if (time>self.attack_finished)
	{
		remove(self);
		return;
    }
	if (self.flags & FL_ONGROUND)
		self.flags = self.flags - FL_ONGROUND;
	self.velocity = self.old_velocity;
	self.angles = vectoangles(self.velocity);
	self.nextthink = time+0.1;
};

void(vector org, vector vec, float light) HIP_LaunchLaser =
{
//	sound (self ,CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM);
	sound (self ,CHAN_WEAPON, "hipweap/laserg.wav", 1, ATTN_NORM);

	vec = normalize(vec);

	newmis = spawn();
	newmis.owner = self;
	newmis.classname = "hiplaser";
	newmis.lastvictim = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;
	newmis.flags = newmis.flags | FL_PROJECTILE;
	
	if (light)
		newmis.effects = EF_DIMLIGHT;

	setmodel (newmis, "progs/lasrspik.mdl");
	setsize (newmis, '0 0 0', '0 0 0');

	setorigin (newmis, org);

	newmis.speed = 1000;
	newmis.dmg = 18;
	newmis.velocity = vec * newmis.speed;
	newmis.old_velocity = newmis.velocity;
	newmis.angles = vectoangles(newmis.velocity);
	newmis.avelocity = '0 0 400';

	newmis.nextthink = time;
	newmis.attack_finished = time + 5;
	newmis.think = HIP_LaserThink;
	newmis.touch = HIP_LaserTouch;
	newmis.count = 0;
};

/*
=================
HIP_FireLaser
=================
*/
void(float stat) HIP_FireLaser =
{
	local vector org;
	local vector dir;
	local vector out;
	local float ofs;
	local float aofs;

	if (!self.button0)
    {
		player_run ();
		return;
    }
	if (self.ammo_cells < 1)
	{
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		return;
    }
	SuperDamageSound();
	self.effects = self.effects | EF_MUZZLEFLASH;
	makevectors (self.v_angle);

	ofs = 6;
	out = v_forward;
	out_z = 0;
	out = normalize(out);
	org = self.origin + ((12-ofs) * v_up) + (12*out);
//	org = self.origin + (1*v_forward);
	dir = aim (self, 1000);
	aofs = ofs * 0.707;
	if (stat == 0)
    {
		self.currentammo = self.ammo_cells = self.ammo_cells - 1;
		org = org + (aofs*v_right);
		org = org - (aofs*v_up);
		HIP_LaunchLaser(org, dir, 0);
		org = org - (2*aofs*v_right);
		HIP_LaunchLaser(org, dir, 0);
    }
	else if (stat == 1)
    {
		self.currentammo = self.ammo_cells = self.ammo_cells - 1;
		org = org + (ofs*v_up);
		if (random()<0.1)
        {
			HIP_LaunchLaser(org, dir, 1);
			newmis.dmg = 25;
        }
		else
			HIP_LaunchLaser(org, dir, 0);
    }
	self.punchangle_x = -1;
};

float	NumProximityGrenades;
.entity	spawnmaster;

void() ProximityExplode =
{
	T_RadiusDamage (self, self.owner, 95, world);

	BecomeExplosion ();
};

/*
================
ProximityGrenadeExplode
================
*/
void() ProximityGrenadeExplode =
   {
   self.takedamage = DAMAGE_NO;
   NumProximityGrenades = NumProximityGrenades - 1;
   self.deathtype = "exploding";
   self.nextthink = time + 0.1;
   self.owner = self.lastvictim;
   self.think = ProximityExplode;
   };

/*
================
ProximityGrenadeTouch
================
*/
void() ProximityGrenadeTouch =
   {
   if (other == self)
      return;
   if (other.classname == self.classname)
      return;
   self.movetype = MOVETYPE_TOSS;
   if (self.state == 1)
      return;
   if (vlen(other.velocity) > 0)
      {
      ProximityGrenadeExplode();
      self.think();
      return;
      }
   if (other.takedamage == DAMAGE_AIM)
      {
      ProximityGrenadeExplode();
      self.think();
      return;
      }
   sound (self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM); // bounce sound
   self.movetype = MOVETYPE_NONE;
   setsize (self, '-8 -8 -8', '8 8 8');
   self.state = 1;
   self.spawnmaster = other;
};

/*
================
ProximityBomb
================
*/
void() ProximityBomb =
   {
   local entity   head;
   local float    blowup;

   if ((time > self.delay) || (NumProximityGrenades > 15) || (vlen(self.spawnmaster.velocity)>0) )
      {
      ProximityGrenadeExplode();
      self.think();
      return;
      }
   self.owner = world;
   self.takedamage = DAMAGE_YES;
   head = findradius(self.origin, 140);
   blowup = 0;

   while (head)
      {
      if ((head != self) && (head.health > 0) && (head.flags & (FL_CLIENT|FL_MONSTER)) && (head.classname!=self.classname))
         blowup = 1;
      if ((head.classname == self.classname) && (head.state==0))
         blowup = 1;
      traceline(self.origin,head.origin,TRUE,self);
      if (trace_fraction != 1.0)
         blowup = 0;
      if (blowup==1)
         {
         sound (self, CHAN_WEAPON, "hipweap/proxwarn.wav", 1, ATTN_NORM);
         ProximityGrenadeExplode();
         self.nextthink = time + 0.5;
         return;
         }
      head = head.chain;
      }
   self.nextthink = time + 0.25;
   };

/*
================
W_FireProximityGrenade
================
*/
void() W_FireProximityGrenade = {

	NumProximityGrenades = NumProximityGrenades + 1;
	self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;

	sound (self, CHAN_WEAPON, "hipweap/proxbomb.wav", 1, ATTN_NORM);

	self.punchangle_x = -2;

	newmis = spawn ();
	newmis.owner = self;
	newmis.lastvictim = self;
	newmis.movetype = MOVETYPE_TOSS;
	newmis.solid = SOLID_BBOX;
	newmis.classname = "proximity_grenade";
	newmis.flags = newmis.flags | FL_PROJECTILE;
	newmis.takedamage = DAMAGE_NO;
	newmis.health = 5;
	newmis.state = 0;

	// set newmis speed

	makevectors (self.v_angle);

	if (self.v_angle_x)
		newmis.velocity = v_forward*600 + v_up * 200 + crandom()*v_right*10 + crandom()*v_up*10;
	else {
		newmis.velocity = aim(self, 10000);
		newmis.velocity = newmis.velocity * 600;
		newmis.velocity_z = 200;
	}

	newmis.avelocity = '100 600 100';

	newmis.angles = vectoangles(newmis.velocity);

	newmis.touch = ProximityGrenadeTouch;

	// set duration
	newmis.nextthink = time + 2;
	newmis.delay = time + 15 + (10*random());
	newmis.think = ProximityBomb;
	newmis.th_die = ProximityGrenadeExplode;

	setmodel (newmis, "progs/proxbomb.mdl");
	setorigin (newmis, self.origin);
	setsize (newmis, '-1 -1 -1', '1 1 1');
};