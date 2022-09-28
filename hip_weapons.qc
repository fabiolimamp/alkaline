void() HIP_LaserTouch = {
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

	if (other.health) {
		if (self.lastvictim == other)
			self.dmg = self.dmg / 2;
		
		spawn_touchblood (self.dmg);
		T_Damage(other, self, self.lastvictim, self.dmg, DMGTYPE_ENERGY);
	}
	else if (self.cnt >= 3 || random() < 0.15) {
		gunshot(org);
	}
	else {
		self.dmg = 0.9 * self.dmg;

		/*
		Vector reflection around normal
		r = d − 2(d*n)n
		r => reflected vector, d => entrance vector, n => surface normal, d*n => dot product
		*/

		self.velocity = oldvel - (2 * (oldvel * trace_plane_normal)) * trace_plane_normal;
		
		self.velocity = self.speed * self.velocity;
		self.old_velocity = self.velocity;

		self.flags &~= FL_ONGROUND;

		r = random();
		sound (self, CHAN_WEAPON, "hipweap/laserric.wav", 1, ATTN_STATIC);

		return;
	}
	sound (self, CHAN_WEAPON, "enforcer/enfstop.wav", 1, ATTN_STATIC);
	remove(self);
};

void() HIP_LaserThink = {
	if (time > self.attack_finished) {
		remove(self);
		return;
	}

	self.flags &~= FL_ONGROUND;

	self.velocity = self.old_velocity;
	self.angles = vectoangles(self.velocity);
	self.nextthink = time + 0.05;
};

void(vector org, vector vec, float light) HIP_LaunchLaser = {
	
	sound(self, CHAN_WEAPON, "hipweap/laserg.wav", 1, ATTN_NORM);

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

	setmodel(newmis, "progs/lasrspik.mdl");
	setsize(newmis, '0 0 0', '0 0 0');

	setorigin(newmis, org);

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
void(float stat) HIP_FireLaser = {
	
	float ofs;
	float aofs;

	if (!self.button0) {
		player_run ();
		return;
	}

	if (self.ammo_cells < 1) {
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		return;
	}

	SuperDamageSound();
	self.effects = self.effects | EF_MUZZLEFLASH;
	
	makevectors (self.v_angle);
	vector dir = aim(self, 1000);

	float ofs = 6;
	float aofs = ofs * 0.7071;

	// central point between the 3 barrels
	vector org = self.origin + self.view_ofs - 16*v_up;

	if (stat == 0) {

		vector org1 = org + aofs*v_right - aofs*v_up;
		vector org2 = org - aofs*v_right - aofs*v_up;

		traceline(org1, org1 + 32*v_forward, FALSE, self);
		HIP_LaunchLaser(org1 + trace_fraction*32*v_forward, dir, 0);

		traceline(org2, org2 + 32*v_forward, FALSE, self);
		HIP_LaunchLaser(org2 + trace_fraction*32*v_forward, dir, 0);

	}
	else if (stat == 1) {
		vector org3 = org + ofs*v_up;
		traceline(org3, org3 + 32*v_forward, FALSE, self);
		
		if (random() < 0.1) {
			HIP_LaunchLaser(org3 + trace_fraction*32*v_forward, dir, 1);
			newmis.dmg = 25;
		}
		else {
			HIP_LaunchLaser(org3 + trace_fraction*32*v_forward, dir, 0);
		}
	}

	self.currentammo = self.ammo_cells = self.ammo_cells - 1;
	self.punchangle_x = -1;
};


/*
================
Proximity/Multi-grenade hybrid
- Uses up to 4 rockets per shot. If < 4, will spawn less mini-grenades
- Direct hits on DAMAGE_AIM entities will trigger an additional explosion
- Each explosion (including the direct one) deals 60 damage
- If don't hit anything, sticks to the surface and wait for proximity, or a 15-25s timeout
================
*/


void() W_FireProximityGrenade = {

	NumProximityGrenades = NumProximityGrenades + 1;
	
	sound(self, CHAN_WEAPON, "hipweap/proxbomb.wav", 1, ATTN_NORM);

	self.punchangle_x = -2;

	newmis = spawn();
	newmis.owner = self;
	newmis.lastvictim = self;
	newmis.movetype = MOVETYPE_TOSS;
	newmis.solid = SOLID_BBOX;
	newmis.classname = "proximity_grenade";
	newmis.flags = newmis.flags | FL_PROJECTILE;
	newmis.takedamage = DAMAGE_NO;
	newmis.health = 5;
	newmis.state = 0;

	if (self.ammo_rockets == 1) {
		newmis.count = 2;
		self.currentammo = self.ammo_rockets = 0;
	}
	else {
		newmis.count = 4;
		self.currentammo = self.ammo_rockets = self.ammo_rockets - 2;
	}

	/*if (self.ammo_rockets < 4) {
		newmis.count = self.ammo_rockets;
		self.currentammo = self.ammo_rockets = 0;
	}
	else {
		newmis.count = 4;
		self.currentammo = self.ammo_rockets = self.ammo_rockets - 4;
	}*/


	// set newmis speed

	makevectors(self.v_angle);

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
	newmis.th_die = ProximityGrenadeExplode;
	
	//newmis.think = ProximityGrenadeFly;
	//newmis.nextthink = time + 2;

	// set duration
	newmis.delay = time + 15 + 10*random();
	

	setmodel(newmis, "progs/proxbomb.mdl");
	setsize(newmis, '-1 -1 -1', '1 1 1');

	if (oldgrenade) {
		setorigin (newmis, self.origin);
	}
	else {
		vector org = self.origin + self.view_ofs - v_up*12;// '0 0 10';
		traceline(org, org + v_forward * 24, FALSE, self);
		setorigin(newmis, org + v_forward*24 * trace_fraction);
	}
};


void() ProximityGrenadeExplode = {
	sound(self, CHAN_WEAPON, "hipweap/proxwarn.wav", 1, ATTN_NORM);
	self.takedamage = DAMAGE_NO;
	//self.owner = self.lastvictim;
	self.think = MultiGrenadeSpawn;	//self.think = ProximityExplode;
	self.nextthink = time + 0.05;
	self.touch = SUB_Null;
	NumProximityGrenades--;
};

void() ProximityGrenadeTouch = {
	if (other == self)
		return;

	if (other.classname == self.classname)
		return;


	if (other.takedamage == DAMAGE_AIM) {
		SpawnExplosion(self.origin, 60, self, 0);

		ProximityGrenadeExplode();
		return;
	}

	if (vlen(other.velocity) > 0) {
		ProximityGrenadeExplode();
		return;
	}
	
	if (self.state == 1)
		return;
	
	sound(self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM); // bounce sound
	self.think = ProximityGrenadeCheck;
	self.nextthink = time + 0.5;
	self.movetype = MOVETYPE_NONE;
	setsize(self, '-8 -8 -8', '8 8 8');

	setorigin(self, self.origin - (normalize(self.velocity) * 6));

	self.state = 1;
	//self.spawnmaster = other;
};

void() ProximityGrenadeCheck = {
	local entity   head;
	local float    blowup;

	if (time > self.delay || NumProximityGrenades > 15) {
		ProximityGrenadeExplode();
		//self.think();
		//self.nextthink = time + 0.05;
		return;
	}

	self.owner = world;
	self.takedamage = DAMAGE_YES;
	head = findradius(self.origin, 140);
	blowup = 0;

	while (head) {
		if (head != self && head.health > 0
					&& (head.flags & (FL_CLIENT|FL_MONSTER))
					&& head.classname != self.classname)
			blowup = 1;

		if (head.classname == self.classname && head.state == 0)
			blowup = 1;

		traceline(self.origin, head.origin, TRUE, self);

		if (trace_fraction != 1.0)
			blowup = 0;

		if (blowup) {
	 		ProximityGrenadeExplode();
			self.nextthink = time + 0.2;
			return;
		}
	  	head = head.chain;
  	}
	self.nextthink = time + 0.2;
};

void() MultiGrenadeSpawn = {
	float ang = 360/self.count;
	
	while (self.count) {
		MiniGrenadeLaunch((self.count-1) * ang);
		self.count--;
	}
	
	remove(self);
};


//--------------------------------------------ROUGE CODE

void(float offsetAngle) MiniGrenadeLaunch = {
	local	entity missile;//, mpuff;
	local	float	tempRand;
	
	missile = spawn();
	missile.owner = self.owner;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;
	missile.classname = "MiniGrenade";
		
// set missile speed	
	missile.v_angle = self.v_angle;
	missile.v_angle_y = missile.v_angle_y + offsetAngle;
	makevectors (missile.v_angle);
		
	missile.velocity = v_forward*100 + v_up*400;
	tempRand = (crandom()*60) - 30;
	missile.velocity = missile.velocity + tempRand * v_forward;
	tempRand = (crandom()*40) - 20;
	missile.velocity = missile.velocity + tempRand * v_right;
	tempRand = (crandom()*60) - 30;
	missile.velocity = missile.velocity + tempRand * v_up;

	missile.avelocity = '300 300 300';
	missile.angles = vectoangles(missile.velocity);
	missile.touch = MiniGrenadeTouch;
	missile.attack_finished = time + 0.25;
	
	setmodel(missile, "progs/mervup.mdl");
	setsize(missile, '0 0 0', '0 0 0');		
	setorigin(missile, self.origin);

// set missile duration
	missile.nextthink = time + 1 + (crandom() * 0.5);
	missile.think = MiniGrenadeExplode;
};

void() MiniGrenadeTouch = {
	if (time < self.attack_finished)
		return;

	if (other == self.owner)
		return;		// don't explode on owner

	if (other.takedamage == DAMAGE_AIM) {
		if (self.classname == "MiniGrenade")
			MiniGrenadeExplode();
		else {
			if (self.owner.classname == "player")
				GrenadeExplode();
			else
				MiniGrenadeExplode();
		}
		return;
	}
	// bounce sound
	sound(self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);	
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};

void() MiniGrenadeExplode = {
	if (pointcontents(self.origin) == CONTENT_SKY) {
		remove(self);
		return;
	}
	
	if (self.owner.classname == "player")
		T_RadiusDamage(self, self.owner, 80, world, DMGTYPE_EXPLOSION);
	else
		T_RadiusDamage(self, self.owner, 80, world, DMGTYPE_EXPLOSION);
		
	BecomeExplosion();
};
