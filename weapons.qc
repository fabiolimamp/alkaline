void(vector pos, vector norm, entity tgt) placebullethole;
void() W_FirePlasma;
void() Plasma_PreCache;
void() W_FireProximityGrenade;

// called by worldspawn
void() W_Precache =
{
	precache_sound ("weapons/r_exp3.wav");		// new rocket explosion
	precache_sound ("weapons/rocket1i.wav");	// spike gun
	precache_sound ("weapons/sgun1.wav");
	precache_sound ("weapons/guncock.wav");		// player shotgun
	precache_sound ("weapons/ric1.wav");		// ricochet (used in c code)
	precache_sound ("weapons/ric2.wav");		// ricochet (used in c code)
	precache_sound ("weapons/ric3.wav");		// ricochet (used in c code)
	precache_sound ("weapons/spike2.wav");		// super spikes
	precache_sound ("weapons/tink1.wav");		// spikes tink (used in c code)
	precache_sound ("weapons/grenade.wav");		// grenade launcher
	precache_sound ("weapons/bounce.wav");		// grenade bounce
	precache_sound ("weapons/shotgn2.wav");		// super shotgun
	precache_sound ("weapons/axhit4.wav");		// extra axe sound for melee - greenwood
	precache_sound ("weapons/spindn_click.wav");		// super nailgun spindown click
	
	precache_sound ("enforcer/enfstop.wav");	// laser cannon
	
	precache_sound ("hipweap/laserg.wav");		// laser cannon
	precache_sound ("hipweap/laserric.wav");	// laser cannon ricochet
	precache_sound ("hipweap/proxwarn.wav");	// proximity bomb
	precache_sound ("hipweap/proxbomb.wav");	// proximity bomb
	Plasma_PreCache();
};


/*
================
W_FireAxe
================
*/
void() W_FireAxe =
{
	local	vector	source;
	local	vector	org;

	makevectors (self.v_angle);
	source = self.origin + '0 0 16';
	traceline (source, source + v_forward*64, FALSE, self);
	if (trace_fraction == 1.0)
		return;
	
	org = trace_endpos - v_forward*4;

	if (trace_ent.takedamage) {
		trace_ent.axhitme = 1;

		ImpactSpawn(org, '0 0 0', 20, trace_ent.bloodtype);
		T_Damage (trace_ent, self, self, 20);
		
		//johnfitz -- make clank sound when hitting brushmodels
		if (trace_ent.movetype == MOVETYPE_PUSH || trace_ent.movetype == MOVETYPE_NONE)
			sound (self, CHAN_WEAPON, "player/axhit2.wav", 1, ATTN_NORM);

		if ((trace_ent.flags & FL_MONSTER) || (trace_ent.classname == "player")) {
			if (random() < 0.5)
				sound (self, CHAN_WEAPON, "weapons/axhit3.wav", 1, ATTN_NORM);
			else
				sound (self, CHAN_WEAPON, "weapons/axhit4.wav", 1, ATTN_NORM);
		}
		
		//johnfitz
	}
	else
	{	// hit wall
		sound (self, CHAN_WEAPON, "player/axhit2.wav", 1, ATTN_NORM);
		gunshot(org);
	}
};


//============================================================================


vector() wall_velocity =
{
	local vector	vel;
	
	vel = normalize (self.velocity);
	vel = normalize(vel + v_up*(random()- 0.5) + v_right*(random()- 0.5));
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;
	
	return vel;
};


/*
================
SpawnMeatSpray
================

Redefined in meat.qc
*/
/*
void(vector org, vector vel) SpawnMeatSpray =
{
	local	entity missile;
	//local	vector	org;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_NOT;

	makevectors (self.angles);

	missile.velocity = vel;
	missile.velocity_z = missile.velocity_z + 250 + 50*random();

	missile.avelocity = '3000 1000 2000';
	
// set missile duration
	missile.nextthink = time + 1;
	missile.think = SUB_Remove;

	setmodel (missile, "progs/zom_gib.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, org);
};
*/


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
		SpawnChunk(org, vel);
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
void(float damage) spawn_touchblood =
{
	local vector	vel;

	vel = wall_velocity () * 0.2;

	ImpactSpawn(self.origin + vel*0.01, vel, damage, other.bloodtype);	
};


/*
================
W_FireSaw
================
*/
void() W_FireSaw =
{
	local	vector	source;
	local	vector	org;
	local	entity	ent;

	makevectors (self.v_angle);
	source = self.origin + '0 0 16';
	traceline (source, source + v_forward*64, FALSE, self);
	if (trace_fraction == 1.0)
		return;
	
	org = trace_endpos - v_forward*4;
	
	ent = trace_ent;
	
	if (ent.takedamage)
	{
		ent.axhitme = 2;
		ImpactSpawn(trace_endpos, '0 0 5', 20, ent.bloodtype);

		if(ent.flags & FL_MONSTER || ent.flags & FL_CLIENT){ // only spawns gibs for monsters and players
			if(!ent.bloodtype || ent.bloodtype == SPAWN_BLOOD) 
				SpawnMeatSpray (self.origin + v_forward*16, ((random()*300) - 150) * v_right + (100 * v_forward));
			else
				SpawnBitSpray (self.origin + v_forward*16, ((random()*300) - 150) * v_right + (100 * v_forward));
		}

		if (deathmatch == 0)
			T_Damage (ent, self, self, 24);
		else
			T_Damage (ent, self, self, 30);
		
		ent.velocity = ent.velocity * 0.5;
		sound (self, CHAN_WEAPON, "weapons/sawguts.wav", 1, ATTN_NORM);
		self.punchangle_x = -8;
	}
	else
	{	// hit wall
		sound (self, CHAN_WEAPON, "player/axhit2.wav", 1, ATTN_NORM);
		gunshot(org);
	}
};

/*
==============================================================================

MULTI-DAMAGE

Collects multiple small damages into a single damage

==============================================================================
*/

entity	multi_ent;
float	multi_damage;

void() ClearMultiDamage =
{
	multi_ent = world;
	multi_damage = 0;
};

void() ApplyMultiDamage =
{
	if (!multi_ent)
		return;
	T_Damage (multi_ent, self, self, multi_damage);
};

void(entity hit, float damage) AddMultiDamage =
{
	if (!hit)
		return;
	
	if (hit != multi_ent)
	{
		ApplyMultiDamage ();
		multi_damage = damage;
		multi_ent = hit;
	}
	else
		multi_damage = multi_damage + damage;
};

/*
==============================================================================

BULLETS

==============================================================================
*/

/*
================
TraceAttack
================
*/
void(float damage, vector dir) TraceAttack =
{
	local	vector	vel, org;
	
	org = trace_endpos - dir*4;

	if (trace_ent.takedamage)
	{
		if(trace_ent.bloodtype == SPAWN_DIRT || trace_ent.bloodtype == SPAWN_CHUNK){
			vel = normalize(dir - v_up*crandom() * 20 + v_right*crandom());
			vel = vel + 2*trace_plane_normal;
			vel = vel * 200;
			
			ImpactSpawn(org, vel*0.2, damage, trace_ent.bloodtype);
		}
		else {
			vel = normalize(dir + v_up*crandom() + v_right*crandom());
			vel = vel + 2*trace_plane_normal;
			vel = vel * 200;

			ImpactSpawn(org, vel*0.2, damage, trace_ent.bloodtype);
		}
		
		AddMultiDamage (trace_ent, damage);
	}
	else
	{
		gunshot(org);
	}
};

/*
================
FireBullets

Used by shotgun, super shotgun, and enemy soldier firing
Go to the trouble of combining multiple pellets into a single damage call.
================
*/
void(float shotcount, vector dir, vector spread) FireBullets =
{
	local	vector direction;
	local	vector	src;
	local vector plane_normal;
	//float bullet;
	makevectors(self.v_angle);

	src = self.origin + v_forward*10;
	src_z = self.absmin_z + self.size_z * 0.7;

	ClearMultiDamage ();
	while (shotcount > 0)
	{
		direction = dir + crandom()*spread_x*v_right + crandom()*spread_y*v_up;

		traceline (src, src + direction*2048, FALSE, self);
		if (trace_fraction != 1.0) {
			plane_normal = trace_plane_normal;
			//JIM
			TraceAttack(4, direction);


			placebullethole(trace_endpos, plane_normal, trace_ent);

		}
		shotcount = shotcount - 1;
		
	}
	ApplyMultiDamage ();
};

void(float shotcount, vector org, vector dir, vector spread) FireBullets2 =
{
	local	vector direction;
	local vector plane_normal;
	//float bullet;
	makevectors(vectoangles(dir));


	ClearMultiDamage();
	while (shotcount > 0)
	{
		direction = dir + crandom()*spread_x*v_right + crandom()*spread_y*v_up;

		traceline (org, org + direction*2048, FALSE, self);
		if (trace_fraction != 1.0) {
			plane_normal = trace_plane_normal;
			//JIM
			TraceAttack(4, direction);


			placebullethole(trace_endpos, plane_normal, trace_ent);

		}
		shotcount = shotcount - 1;
		
	}
	ApplyMultiDamage ();
};

/*
================
W_FireShotgun
================
*/
void() W_FireShotgun =
{
	local vector dir;

	sound (self, CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM);	

	self.punchangle_x = -2;
	
	self.currentammo = self.ammo_shells = self.ammo_shells - 1;
	dir = aim (self, 100000);
	FireBullets (6, dir, '0.04 0.04 0');
};


/*
================
W_FireSuperShotgun
================
*/
void() W_FireSuperShotgun =
{
	local vector dir;

	if (self.currentammo == 1)
	{
		W_FireShotgun ();
		return;
	}
		
	sound (self ,CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM);	

	self.punchangle_x = -4;
	
	self.currentammo = self.ammo_shells = self.ammo_shells - 2;
	dir = aim (self, 100000);
	FireBullets (14, dir, '0.14 0.08 0');
};


/*
==============================================================================

ROCKETS

==============================================================================
*/

/*
BecomeExplosion moved to fx.qc
*/

void() T_MissileTouch =
{
	local float	damg, rdamg;

	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

	// rocket can have a custom damage
	if (self.dmg) {
		damg = zeroconvert(self.dmg);
		rdamg = damg;
	}
	else {
		damg = 100 + random()*20;
		rdamg = 120;
	}
	
	if (other.health)
	{
		if (other.classname == "monster_shambler" || other.classname == "monster_bambler")
			damg = damg * 0.5;	// mostly immune
		T_Damage (other, self, self.owner, damg );
	}

	// don't do radius damage to the other, because all the damage
	// was done in the impact
	T_RadiusDamage (self, self.owner, rdamg, other);

//	sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
	self.origin = self.origin - 8*normalize(self.velocity);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	BecomeExplosion ();
};

void() T_MissileTouchArma =
{
	local float	damg;

	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

	damg = 50 + random()*20;	// reduced damage (orig. 100), for better gameplay
	
	if (other.health)
	{
		if (other.classname == "monster_shambler" || other.classname == "monster_bambler")
			damg = damg * 0.5;	// mostly immune
		T_Damage (other, self, self.owner, damg );
	}

	// don't do radius damage to the other, because all the damage
	// was done in the impact
	T_RadiusDamage (self, self.owner, 50, other);	// reduced splash (orig. 120), for better gameplay

//	sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
	self.origin = self.origin - 8*normalize(self.velocity);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	BecomeExplosion ();
};

/*
================
W_FireRocket
================
*/

void(vector org, vector dir) launch_rocket = {
	//local	entity missile;

	newmis = spawn();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;
	newmis.classname = "missile";
	newmis.flags = newmis.flags | FL_PROJECTILE;
	newmis.touch = T_MissileTouch;

	newmis.angles = vectoangles(dir);
	newmis.velocity = dir * 1000;

	setmodel (newmis, "progs/missile.mdl");
	setsize (newmis, '0 0 0', '0 0 0');
	setorigin (newmis, org);

	newmis.nextthink = time + 5;
	newmis.think = SUB_Remove;
	//newmis = missile;
};

void() W_FireRocket =
{
	local	vector dir, org;
	
	self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;
	
	sound (self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

	self.punchangle_x = -2;

	makevectors (self.v_angle);
	dir = aim(self, 1000);
	org = self.origin + v_forward*8 + '0 0 16';
	
	launch_rocket(org, dir);

};

/*
===============================================================================

LIGHTNING

===============================================================================
*/

/*
=================
LightningDamage
=================
*/
void(vector p1, vector p2, entity from, float damage) LightningDamage =
{
	local entity		e1, e2;
	local vector		f;
	
	f = p2 - p1;
	normalize (f);
	f_x = 0 - f_y;
	f_y = f_x;
	f_z = 0;
	f = f*16;

	e1 = e2 = world;

	traceline (p1, p2, FALSE, self);
	if (trace_ent.takedamage)
	{
		particle (trace_endpos, '0 0 100', 225, damage*4);

		T_Damage (trace_ent, from, from, damage);
		if (self.classname == "player")
		{
			if (other.classname == "player")
				trace_ent.velocity_z = trace_ent.velocity_z + 400;
		}
	}
	e1 = trace_ent;

	traceline (p1 + f, p2 + f, FALSE, self);
	if (trace_ent != e1 && trace_ent.takedamage)
	{
		particle (trace_endpos, '0 0 100', 225, damage*4);
		T_Damage (trace_ent, from, from, damage);
	}
	e2 = trace_ent;

	traceline (p1 - f, p2 - f, FALSE, self);
	if (trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage)
	{
		particle (trace_endpos, '0 0 100', 225, damage*4);
		T_Damage (trace_ent, from, from, damage);
	}
};


void() W_FireLightning =
{
	local	vector		org;
	local	float		cells;
	local entity victim;

	if (self.ammo_cells < 1)
	{
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		return;
	}

// explode if under water
	if (self.waterlevel > 1)
	{
		cells = self.ammo_cells;
		self.ammo_cells = 0;
		W_SetCurrentAmmo ();
		victim = findradius(self.origin, 35*cells);
		while (victim)
		{
			if (victim.classname != "monster_eel")
				{
				if (victim.takedamage)
					{
					if (victim.waterlevel > 0)
						{
						T_Damage(victim, self,self, 35*cells);					
						}
					}	
				}

			victim = victim.chain;
		}

		return;
	}

	if (self.t_width < time)
	{
		sound (self, CHAN_WEAPON, "weapons/lhit.wav", 1, ATTN_NORM);
		self.t_width = time + 0.6;
	}
	self.punchangle_x = -2;

	self.currentammo = self.ammo_cells = self.ammo_cells - 1;

	org = self.origin + '0 0 16';
	
	traceline (org, org + v_forward*600, TRUE, self);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_LIGHTNING2);
	WriteEntity (MSG_BROADCAST, self);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
	WriteCoord (MSG_BROADCAST, trace_endpos_x);
	WriteCoord (MSG_BROADCAST, trace_endpos_y);
	WriteCoord (MSG_BROADCAST, trace_endpos_z);

	LightningDamage (self.origin, trace_endpos + v_forward*4, self, 30);
};


//=============================================================================


void() GrenadeExplode =
{
	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

	T_RadiusDamage (self, self.owner, 120, world);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	BecomeExplosion ();
};

void() GrenadeTouch =
{
	if (other == self.owner)
		return;		// don't explode on owner
	if (other.takedamage == DAMAGE_AIM)
	{
		GrenadeExplode();
		return;
	}
	if (pointcontents(self.origin) != CONTENT_SKY) // doesn't make a sound when inside a sky brush
		sound (self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM); // bounce sound
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};

/*
================
W_FireGrenade
================
*/
void() W_FireGrenade =
{
	local	entity missile;
	
	self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;
	
	sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);

	self.punchangle_x = -2;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;
	missile.classname = "grenade";
	missile.flags = missile.flags | FL_PROJECTILE;
		
// set missile speed	

	makevectors (self.v_angle);

	if (self.v_angle_x)
		missile.velocity = v_forward*600 + v_up * 200 + crandom()*v_right*10 + crandom()*v_up*10;
	else
	{
		missile.velocity = aim(self, 10000);
		missile.velocity = missile.velocity * 600;
		missile.velocity_z = 200;
	}

	missile.avelocity = '300 300 300';

	missile.angles = vectoangles(missile.velocity);
	
	missile.touch = GrenadeTouch;
	
// set missile duration
	missile.nextthink = time + 2.5;
	missile.think = GrenadeExplode;

	setmodel (missile, "progs/grenade.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, self.origin);
};


//=============================================================================

void() spike_touch;
void() superspike_touch;


/*
===============
launch_spike

Used for both the player and the ogre
===============
*/
void(vector org, vector dir) launch_spike =
{
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;
	newmis.flags = newmis.flags | FL_PROJECTILE;

	newmis.angles = vectoangles(dir);
	
	newmis.touch = spike_touch;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
	setmodel (newmis, "progs/spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	setorigin (newmis, org);

	newmis.velocity = dir * 1000;
};

void() W_FireSuperSpikes =
{
	local vector	dir;
	vector org;
//	local entity	old;
	
	makevectors (self.v_angle);

	sound (self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);
	self.attack_finished = time + 0.2;
	self.currentammo = self.ammo_nails = self.ammo_nails - 2;
	dir = aim (self, 1000);

	org = self.origin + '0 0 16';

	traceline(org, org + v_forward * 24, FALSE, self);
	launch_spike (org + v_forward * 24 * trace_fraction , dir);

	newmis.touch = superspike_touch;
	setmodel (newmis, "progs/s_spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	//self.punchangle_x = -2;
};

void(float ox) W_FireSpikes =
{
	local vector	dir;
	vector org;
//	local entity	old;
	
	if (self.ammo_nails >= 2 && self.weapon == WEAPON_SUPER_NAILGUN)
	{
		W_FireSuperSpikes ();
		return;
	}

	if (self.ammo_nails < 1)
	{
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		return;
	}

	makevectors (self.v_angle);

	sound (self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);
	self.attack_finished = time + 0.2;
	self.currentammo = self.ammo_nails = self.ammo_nails - 1;

	org = self.origin + self.view_ofs + v_up * -8 + v_right*ox;
	dir = aim (self, 1000);
	traceline(org, org + v_forward * 24, FALSE, self);
	launch_spike (org + v_forward * 24 * trace_fraction, dir);

	self.punchangle_x = -2;
};



void() spike_touch =
{
	local float damage;
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
// hit something that bleeds
	if (other.takedamage)
	{
		damage = zeroconvertdefault(self.dmg, 9);
		spawn_touchblood(damage);
		T_Damage(other, self, self.owner, damage);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		
		if (self.classname == "wizspike")
			WriteByte (MSG_BROADCAST, TE_WIZSPIKE);
		else if (self.classname == "knightspike")
			WriteByte (MSG_BROADCAST, TE_KNIGHTSPIKE);
		else
			WriteByte (MSG_BROADCAST, TE_SPIKE);

		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);

		if (self.owner.classname != "trap_shooter" && self.owner.classname != "trap_spikeshooter") {
			makevectors(self.angles);
			traceline(self.origin, self.origin + v_forward*32, TRUE, self);
			if (trace_fraction != 1) placebullethole(trace_endpos, trace_plane_normal, trace_ent);
		}
	}

	remove(self);

};

void() superspike_touch =
{
	local float damage;
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
// hit something that bleeds
	if (other.takedamage)
	{
		damage = zeroconvertdefault(self.dmg, 18);
		spawn_touchblood(damage);
		T_Damage(other, self, self.owner, damage);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_SUPERSPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);

		if (self.owner.classname != "trap_shooter" && self.owner.classname != "trap_spikeshooter") {
			makevectors(self.angles);
			traceline(self.origin, self.origin + v_forward*32, TRUE, self);
			if (trace_fraction != 1) placebullethole(trace_endpos, trace_plane_normal, trace_ent);
		}
	}

	remove(self);

};


/*
===============================================================================

PLAYER WEAPON USE

===============================================================================
*/

void() W_SetCurrentAmmo =
{
	if (self.weapon != WEAPON_NO_WEAPON && !(self.weapon == WEAPON_SUPER_NAILGUN && self.cnt == 1)) player_run ();		// get out of any weapon firing states

	self.items = self.items - ( self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS) );
	
	if (self.weapon == WEAPON_NO_WEAPON)  //johnfitz
	{
		self.currentammo = 0;
		self.weaponmodel = "";
		self.weaponframe = 0;
	}	
	else if (self.weapon == WEAPON_AXE)
	{
		self.currentammo = 0;
		self.weaponmodel = "progs/v_alkaxe20fps.mdl";
		self.weaponframe = 0;
	}
	else if (self.weapon == WEAPON_CHAINSAW)
	{
		self.currentammo = 0;
		self.weaponmodel = "progs/v_saw.mdl";
		self.weaponframe = 0;
		sound (self, 6, "weapons/sawidle.wav", 1, ATTN_NORM);
	}
	else if (self.weapon == WEAPON_SHOTGUN)
	{
		self.currentammo = self.ammo_shells;
		self.weaponmodel = "progs/v_shot.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_SHELLS;
	}
	else if (self.weapon == WEAPON_SUPER_SHOTGUN)
	{
		self.currentammo = self.ammo_shells;
		self.weaponmodel = "progs/v_shot2.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_SHELLS;
	}
	else if (self.weapon == WEAPON_NAILGUN)
	{
		self.currentammo = self.ammo_nails;
		self.weaponmodel = "progs/v_nail_alk40fps.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_NAILS;
	}
	else if (self.weapon == WEAPON_SUPER_NAILGUN)
	{
		self.currentammo = self.ammo_nails;
		self.weaponmodel = "progs/v_nail3.mdl";
		if (self.cnt != 1) self.weaponframe = 0;
		self.items = self.items | IT_NAILS;
	}
	else if (self.weapon == WEAPON_LASER_CANNON)
	{
		self.currentammo = self.ammo_cells;
		self.weaponmodel = "progs/v_laserg.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_CELLS;
	}
	else if (self.weapon == WEAPON_PLASMA)
	{
		self.currentammo = self.ammo_cells;
		self.weaponmodel = "progs/v_plasma.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_CELLS;
	}
	else if (self.weapon == WEAPON_GRENADE_LAUNCHER)
	{
		self.currentammo = self.ammo_rockets;
		self.weaponmodel = "progs/v_rock.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_ROCKETS;
	}
	else if (self.weapon == WEAPON_PROXIMITY_GUN)
	{
		self.currentammo = self.ammo_rockets;
		self.weaponmodel = "progs/v_mine.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_ROCKETS;
	}
	else if (self.weapon == WEAPON_ROCKET_LAUNCHER)
	{
		self.currentammo = self.ammo_rockets;
		self.weaponmodel = "progs/v_rock2.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_ROCKETS;
	}
	else if (self.weapon == WEAPON_LIGHTNING)
	{
		self.currentammo = self.ammo_cells;
		self.weaponmodel = "progs/v_light.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_CELLS;
	}
	else
	{
		self.currentammo = 0;
		self.weaponmodel = "";
		self.weaponframe = 0;
	}
};

float(float weapons, float shells, float nails, float cells, float waterlevel) W_BestWeaponParms =
{
	if(waterlevel <= 1 && cells >= 1 && weapons & WEAPON_PLASMA)
		return WEAPON_PLASMA;
	if(waterlevel <= 1 && cells >= 1 && (weapons & WEAPON_LIGHTNING) )
		return WEAPON_LIGHTNING;
	if(cells >= 1 && (weapons & WEAPON_LASER_CANNON) )
		return WEAPON_LASER_CANNON;
	if(nails >= 2 && (weapons & WEAPON_SUPER_NAILGUN) )
		return WEAPON_SUPER_NAILGUN;
	if(shells >= 2 && (weapons & WEAPON_SUPER_SHOTGUN) )
		return WEAPON_SUPER_SHOTGUN;
	if(nails >= 1 && (weapons & WEAPON_NAILGUN) )
		return WEAPON_NAILGUN;
	if(shells >= 1 && (weapons & WEAPON_SHOTGUN) )
		return WEAPON_SHOTGUN;
	if(weapons & WEAPON_CHAINSAW)
		return WEAPON_CHAINSAW;
	if(weapons & WEAPON_AXE)
		return WEAPON_AXE;
	return WEAPON_NO_WEAPON; //johnfitz
};

float() W_BestWeapon =
{
	local	float	weaps;
	
	weaps = self.weapons;

	return W_BestWeaponParms(weaps, self.ammo_shells, self.ammo_nails, self.ammo_cells, self.waterlevel);
};

float(float currentweapon, float shells, float nails, float rockets, float cells) W_CheckAmmoParms = {
	if (
		(currentweapon == WEAPON_NO_WEAPON) ||
		(currentweapon == WEAPON_AXE) ||
		(currentweapon == WEAPON_CHAINSAW) ||
		(currentweapon == WEAPON_SHOTGUN && shells >= 1) ||
		(currentweapon == WEAPON_SUPER_SHOTGUN && shells >= 2) ||
		(currentweapon == WEAPON_NAILGUN && nails >= 1) ||
		(currentweapon == WEAPON_SUPER_NAILGUN && nails >= 2) ||
		(currentweapon == WEAPON_GRENADE_LAUNCHER && rockets >= 1) ||
		(currentweapon == WEAPON_PROXIMITY_GUN && rockets >= 1) ||
		(currentweapon == WEAPON_ROCKET_LAUNCHER && rockets >= 1) ||
		(currentweapon == WEAPON_LIGHTNING && cells >= 1) ||
		(currentweapon == WEAPON_LASER_CANNON && cells >= 1) ||
		(currentweapon == WEAPON_PLASMA && cells >= 1)
	) return TRUE;
	else return FALSE;
};

float() W_CheckNoAmmo =
{
	if (self.currentammo > 0)
		return TRUE;

	if (self.weapon == WEAPON_AXE)
		return TRUE;
	
	if (self.weapon == WEAPON_CHAINSAW)
		return TRUE;
	
	self.weapon = W_BestWeapon ();

	W_SetCurrentAmmo ();
	
// drop the weapon down
	return FALSE;
};



/*
============
W_Attack

An attack impulse can be triggered now
============
*/
/*
void()	player_axe1;
void()	player_axeb1;
void()	player_axec1;
void()	player_axed1;*/
void()	player_axe;
void()	player_shot1;
void()	player_nail;
void()	player_super_nail;
void()	player_light1;
void()	player_rocket1;
void()	player_laser1;
void()	player_plasma1;
void()	player_chainsaw1;

void() W_Attack =
{

	if (!W_CheckNoAmmo ())
		return;

	makevectors	(self.v_angle);			// calculate forward angle for velocity
	self.show_hostile = time + 1;	// wake monsters up

	if (self.weapon == WEAPON_AXE)
	{
		sound (self, CHAN_WEAPON, "weapons/ax1.wav", 1, ATTN_NORM);
		player_axe();
		self.attack_finished = time + 0.5;
	}
	else if (self.weapon == WEAPON_SHOTGUN)
	{
		player_shot1 ();
		W_FireShotgun ();
		self.attack_finished = time + 0.5;
	}
	else if (self.weapon == WEAPON_SUPER_SHOTGUN)
	{
		player_shot1 ();
		W_FireSuperShotgun ();
		self.attack_finished = time + 0.7;
	}
	else if (self.weapon == WEAPON_NAILGUN)
	{
		player_nail ();
	}
	else if (self.weapon == WEAPON_SUPER_NAILGUN)
	{
		player_super_nail ();
	}
	else if (self.weapon == WEAPON_GRENADE_LAUNCHER)
	{
		player_rocket1();
		W_FireGrenade();
		self.attack_finished = time + 0.6;
	}
	else if (self.weapon == WEAPON_PROXIMITY_GUN)
	{
		player_rocket1();
		W_FireProximityGrenade();
		self.attack_finished = time + 0.6;
	}
	else if (self.weapon == WEAPON_ROCKET_LAUNCHER)
	{
		player_rocket1();
		W_FireRocket();
		self.attack_finished = time + 0.8;
	}
	else if (self.weapon == WEAPON_LIGHTNING)
	{
		player_light1();
		self.attack_finished = time + 0.1;
		sound (self, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
	}
	else if (self.weapon == WEAPON_LASER_CANNON)
	{
		player_laser1();
	}
	else if (self.weapon == WEAPON_PLASMA)
	{
		player_plasma1();
		W_FirePlasma();
		self.attack_finished = time + 0.05;
	}
	else if (self.weapon == WEAPON_CHAINSAW)
	{
		player_chainsaw1();
		self.attack_finished = time + 0.55;
		sound (self, CHAN_AUTO, "weapons/sawatck.wav", 1, ATTN_NORM);
	}
};

/*
============
W_ChangeWeapon

============
*/
void() W_ChangeWeapon =
{
	local float noammo;
	local float weap;
	local float item;
	
	noammo = 0;
	self.weaponframe = 0;

	if (self.impulse == 1) {
		if (!(self.weapons & WEAPON_AXE) && (self.weapons & WEAPON_CHAINSAW)) { // has the saw but not the axe
			weap = WEAPON_CHAINSAW;
		}
		else if (self.weapon == WEAPON_AXE) {
			if (self.weapons & WEAPON_CHAINSAW) {
				weap = WEAPON_CHAINSAW;
			}
			else 
				weap = WEAPON_AXE;
		}
		else
			weap = WEAPON_AXE; 
	}
	else if (self.impulse == 2)	{
		weap = WEAPON_SHOTGUN;
		if (self.ammo_shells < 1)
			noammo = 1;
	}
	else if (self.impulse == 3)	{
		weap = WEAPON_SUPER_SHOTGUN;
		if (self.ammo_shells < 2)
			noammo = 1;
	}		
	else if (self.impulse == 4)	{
		weap = WEAPON_NAILGUN;
		if (self.ammo_nails < 1)
			noammo = 1;
	}
	else if (self.impulse == 5)	{
		weap = WEAPON_SUPER_NAILGUN;
		if (self.ammo_nails < 2)
			noammo = 1;
	}
	else if (self.impulse == 6)	{
		weap = WEAPON_GRENADE_LAUNCHER;
		if(self.weapon == WEAPON_GRENADE_LAUNCHER){
			weap = WEAPON_PROXIMITY_GUN;
		}
		else {
			if(self.weapons & WEAPON_GRENADE_LAUNCHER){
				weap = WEAPON_GRENADE_LAUNCHER;
			}
			else if(self.weapons & WEAPON_PROXIMITY_GUN){
				weap = WEAPON_PROXIMITY_GUN;
			}
		}
		
		if (self.ammo_rockets < 1) 
			noammo = 1;
	}
	else if (self.impulse == 7)	{
		weap = WEAPON_ROCKET_LAUNCHER;
		if (self.ammo_rockets < 1)
			noammo = 1;
	}
	else if (self.impulse == 8)	{
		if (self.weapon == WEAPON_LIGHTNING) {
			if(self.weapons & WEAPON_LASER_CANNON)
				weap = WEAPON_LASER_CANNON;
			else {
				weap = WEAPON_PLASMA;
			}
		}
		else if (self.weapon == WEAPON_LASER_CANNON) {
			if (self.weapons & WEAPON_PLASMA) {
				weap = WEAPON_PLASMA;
			}
			else 
				weap = item = WEAPON_LIGHTNING;
		}
		else if(self.weapon == WEAPON_PLASMA) {
			if(self.weapons & WEAPON_LIGHTNING)
				weap = WEAPON_LIGHTNING;
			else
				weap = WEAPON_LASER_CANNON;
		}
		else if(self.weapons & WEAPON_LIGHTNING)
			weap = WEAPON_LIGHTNING;
		else if(self.weapons & WEAPON_LASER_CANNON)
			weap = WEAPON_LASER_CANNON;
		else {
			weap = WEAPON_PLASMA;
		}

		if (self.ammo_cells < 1)
			noammo = 1;
	}
	else if (self.impulse == 225) {
		weap = WEAPON_LASER_CANNON;
		if (self.ammo_cells < 1)
			noammo = 1;
	}
	else if (self.impulse == 226) {
		weap = WEAPON_CHAINSAW;
	}
	else if (self.impulse == 227) {
		weap = WEAPON_PLASMA;
		if (self.ammo_cells < 1)
			noammo = 1;
	} 
	else if (self.impulse == 228) {
		weap = WEAPON_LIGHTNING;
		if (self.ammo_cells < 1)
			noammo = 1;
	}
	else if (self.impulse == 229) {
		weap = WEAPON_PROXIMITY_GUN;
		if (self.ammo_rockets < 1)
			noammo = 1;
	}
	else if (self.impulse == 230) {
		weap = WEAPON_GRENADE_LAUNCHER;
		if (self.ammo_rockets < 1)
			noammo = 1;
	}
	else if (self.impulse == 231) {
		weap = WEAPON_AXE;
	}
	else 
		weap = WEAPON_NO_WEAPON; // doesn't work right but does no harm either
	
	self.impulse = 0;
	

	if(weap) {
		if (!(self.weapons & weap)) {	// don't have the weapon or the ammo
			sprint (self, "no weapon.\n");
			return;
		}
	}

	
	if (noammo) {	// don't have the ammo
		sprint (self, "not enough ammo.\n");
		return;
	}
	
//
// set weapon, set ammo
//
	self.weapon = weap;

	W_SetCurrentAmmo ();
};

/*
============
GiveAllCommand
============
*/
void() GiveAllCommand =
{
	if (deathmatch || coop)
		return;

	self.ammo_rockets = 100;
	self.ammo_nails = 200;
	self.ammo_shells = 100;
	self.weapons = self.weapons | ALL_WEAPONS;
	self.items = self.items | HUD_WEAPONS | IT_KEY1 | IT_KEY2;

	self.ammo_cells = 100;
		
	self.weapon = WEAPON_ROCKET_LAUNCHER;
	self.impulse = 0;
	W_SetCurrentAmmo ();
};

/*
============
GiveWeaponsCommand
============
*/
void() GiveWeaponsCommand =
{
	if (deathmatch || coop)
		return;

	self.ammo_rockets = 100;
	self.ammo_nails = 200;
	self.ammo_shells = 100;
	self.weapons = self.weapons | ALL_WEAPONS;
	self.items = self.items | HUD_WEAPONS;

	self.ammo_cells = 100;
		
	self.weapon = WEAPON_ROCKET_LAUNCHER;
	self.impulse = 0;
	W_SetCurrentAmmo ();
};

/*
============
CycleWeaponCommand

Go to the next weapon with ammo
============
*/
void() CycleWeaponCommand =
{
	local	float	weaps, noammo, loop;
	
	weaps = self.weapons;
	
	self.impulse = 0;
	self.weaponframe = 0;
	
	if (!(weaps & ALL_WEAPONS))
	{
		self.weapon = WEAPON_NO_WEAPON;
		W_SetCurrentAmmo ();
		return;
	}

	
	while (1)
	{
		noammo = FALSE;
		
		if (self.weapon == WEAPON_AXE)
		{
			self.weapon = WEAPON_CHAINSAW;			
		}
		else if (self.weapon == WEAPON_CHAINSAW)
		{
			self.weapon = WEAPON_SHOTGUN;
			if (self.ammo_shells < 1)
				noammo = TRUE;
		}
		else if (self.weapon == WEAPON_SHOTGUN)
		{
			self.weapon = WEAPON_SUPER_SHOTGUN;
			if (self.ammo_shells < 2)
				noammo = TRUE;
		}		
		else if (self.weapon == WEAPON_SUPER_SHOTGUN)
		{
			self.weapon = WEAPON_NAILGUN;
			if (self.ammo_nails < 1)
				noammo = TRUE;
		}
		else if (self.weapon == WEAPON_NAILGUN)
		{
			self.weapon = WEAPON_SUPER_NAILGUN;
			if (self.ammo_nails < 2)
				noammo = TRUE;
		}
		else if (self.weapon == WEAPON_SUPER_NAILGUN)
		{
			self.weapon = WEAPON_GRENADE_LAUNCHER;
			if (self.ammo_rockets < 1)
				noammo = TRUE;
		}
		else if (self.weapon == WEAPON_GRENADE_LAUNCHER)
		{
			self.weapon = WEAPON_PROXIMITY_GUN;
			if (self.ammo_rockets < 1)
				noammo = TRUE;
		}
		else if (self.weapon == WEAPON_PROXIMITY_GUN)
		{
			self.weapon = WEAPON_ROCKET_LAUNCHER;
			if (self.ammo_rockets < 1)
				noammo = TRUE;
		}
		else if (self.weapon == WEAPON_ROCKET_LAUNCHER)
		{
			self.weapon = WEAPON_LIGHTNING;
			if (self.ammo_cells < 1)
				noammo = TRUE;
		}
		else if (self.weapon == WEAPON_LIGHTNING)
		{
			self.weapon = WEAPON_LASER_CANNON;
			if (self.ammo_cells < 1)
				noammo = TRUE;
		}
		else if (self.weapon == WEAPON_LASER_CANNON)
		{
			self.weapon = WEAPON_PLASMA;
			if (self.ammo_cells < 1)
				noammo = TRUE;			
		}
		else if (self.weapon == WEAPON_PLASMA)
		{
			self.weapon = WEAPON_AXE;
		}
		
		if ((weaps & self.weapon && !noammo) || loop > 12)
		{
			if (loop > 12) self.weapon = WEAPON_NO_WEAPON;
			W_SetCurrentAmmo ();
			return;
		}

		loop++;

	}
};

/*
============
CycleWeaponReverseCommand

Go to the prev weapon with ammo
============
*/
void() CycleWeaponReverseCommand =
{
	local	float	weaps, noammo, loop;
	
	weaps = self.weapons;

	self.impulse = 0;
	self.weaponframe = 0;

	if (!(weaps & ALL_WEAPONS))
	{
		self.weapon = WEAPON_NO_WEAPON;
		W_SetCurrentAmmo ();
		return;
	}

	while (1)
	{
		noammo = FALSE;
		
		if (self.weapon == WEAPON_PLASMA)
		{
			self.weapon = WEAPON_LASER_CANNON;
			if (self.ammo_cells < 1)
				noammo = TRUE;
		}
		else if (self.weapon == WEAPON_LASER_CANNON)
		{
			self.weapon = WEAPON_LIGHTNING;
			if (self.ammo_cells < 1)
				noammo = TRUE;
		}
		else if (self.weapon == WEAPON_LIGHTNING)
		{
			self.weapon = WEAPON_ROCKET_LAUNCHER;
			if (self.ammo_rockets < 1)
				noammo = TRUE;
		}
		else if (self.weapon == WEAPON_ROCKET_LAUNCHER)
		{
			self.weapon = WEAPON_PROXIMITY_GUN;
			if (self.ammo_rockets < 1)
				noammo = TRUE;
		}
		else if (self.weapon == WEAPON_PROXIMITY_GUN)
		{
			self.weapon = WEAPON_GRENADE_LAUNCHER;
			if (self.ammo_rockets < 1)
				noammo = TRUE;
		}
		else if (self.weapon == WEAPON_GRENADE_LAUNCHER)
		{
			self.weapon = WEAPON_SUPER_NAILGUN;
			if (self.ammo_nails < 2)
				noammo = TRUE;
		}
		else if (self.weapon == WEAPON_SUPER_NAILGUN)
		{
			self.weapon = WEAPON_NAILGUN;
			if (self.ammo_nails < 1)
				noammo = TRUE;
		}
		else if (self.weapon == WEAPON_NAILGUN)
		{
			self.weapon = WEAPON_SUPER_SHOTGUN;
			if (self.ammo_shells < 2)
				noammo = TRUE;
		}		
		else if (self.weapon == WEAPON_SUPER_SHOTGUN)
		{
			self.weapon = WEAPON_SHOTGUN;
			if (self.ammo_shells < 1)
				noammo = TRUE;
		}
		else if (self.weapon == WEAPON_SHOTGUN)
		{
			self.weapon = WEAPON_CHAINSAW;
		}
		else if (self.weapon == WEAPON_CHAINSAW)
		{
			self.weapon = WEAPON_AXE;
		}
		else if (self.weapon == WEAPON_AXE || self.weapon == WEAPON_NO_WEAPON)
		{	
			self.weapon = WEAPON_PLASMA;
			if (self.ammo_cells < 1)
				noammo = TRUE;
		}
		
		if ((weaps & self.weapon && !noammo) || loop > 12)
		{
			if (loop > 12) self.weapon = WEAPON_NO_WEAPON;
			W_SetCurrentAmmo ();
			return;
		}
		loop++;
	}

};

/*
============
ServerflagsCommand

Just for development
============
*/
void() ServerflagsCommand =
{
	serverflags = serverflags * 2 + 1;
};

//johnfitz -- new cheats
void() RingCheat =
{
	if (deathmatch || coop)
		return;
	self.invisible_time = 1;
	self.invisible_finished = time + 30;
	self.items = self.items | IT_INVISIBILITY;
	dprint ("ring cheat\n");
};

void() BiosuitCheat =
{
	if (deathmatch || coop)
		return;
	self.rad_time = 1;
	self.radsuit_finished = time + 30;
	self.items = self.items | IT_SUIT;
	dprint ("biosuit cheat\n");
};

void() PentCheat =
{
	if (deathmatch || coop)
		return;
	self.invincible_time = 1;
	self.invincible_finished = time + 30;
	self.items = self.items | IT_INVULNERABILITY;
	dprint ("pent cheat\n");
};
//johnfitz

void() QuadCheat =
{
	if (deathmatch || coop)
		return;
	self.super_time = 1;
	self.super_damage_finished = time + 30;
	self.items = self.items | IT_QUAD;
	dprint ("quad cheat\n");
};

void() JBootsCheat = { //JCR superjump boot cheat
	self.items = self.items | IT_JBOOTS;

	if (!self.jboots_rechargelimit) sprint(self, "You got the Jump Boots!\n");
	else sprint(self, "Jump module added.\n");

	sound(self, CHAN_BODY, "items/jboots_got.wav", 1, ATTN_NORM);

	if (self.jboots_rechargelimit >= 3)
		self.jboots_rechargelimit = 3;
	else
		self.jboots_rechargelimit = self.jboots_rechargelimit + 1;
}

void() JBootsTimedCheat = { //JCR superjump boot cheat
	self.items = self.items | IT_JBOOTS;

	sprint(self, "You got the Super Jump Boots!\n");

	sound(self, CHAN_BODY, "items/jboots_got.wav", 1, ATTN_NORM);

	self.jboots_prevlimit = self.jboots_rechargelimit;
	self.jboots_time = 1;
	self.jboots_finished = time + 30;
	self.jboots_rechargelimit = -1;
}

void() JBootsRemoveCheat = {
	sprint(self, "Jump boots removed.\n");

	self.items -= self.items & IT_JBOOTS;

	self.jboots_finished = 0;
	self.jboots_time = 0;
	self.jboots_rechargelimit = 0;
	self.jboots_prevlimit = 0;
}

void(float num) ImpulseTest = {
	local string tgt_impulse_num;
	
	if(num <= 0)
		return;

	tgt_impulse_num = ftos(num);

	activator = self;
	SUB_UseSpecificTarget(tgt_impulse_num, impulsetarget);
};

// adapted from Copper
void() dev_reveal = {
	vector org;

	makevectors(self.v_angle);
	org = self.origin + self.view_ofs;
	traceline (org, org + v_forward * 8192, FALSE, self);

	if (trace_fraction < 1) {
		if (trace_ent) {
			dprint("----------------------------\n----------------------------\n");
			eprint(trace_ent);
		}
		dprint5("\n-\n-\nFound ", trace_ent.classname, "; time: ", ftos(time), "\n");
	}

};

void(entity targ, float ammoqty, string zero10, string zero100, string zero1000, string zero10000, string zero100000) zerofill_number =
{
	// Cap number based on strings
	if (ammoqty > 99999 && zero100000 == "") ammoqty = 99999;
	if (ammoqty > 9999 && zero10000 == "") ammoqty = 9999;
	if (ammoqty > 999 && zero1000 == "") ammoqty = 999;
	if (ammoqty > 99 && zero100 == "") ammoqty = 99;
	// Zero fill based on strings existing
	if (ammoqty < 100000 && zero100000 != "") sprint(targ, zero100000);
	if (ammoqty < 10000 && zero10000 != "") sprint(targ, zero10000);
	if (ammoqty < 1000 && zero1000 != "") sprint(targ, zero1000);
	if (ammoqty < 100 && zero100 != "") sprint(targ, zero100);
	if (ammoqty < 10 && zero10 != "") sprint(targ, zero10);
	sprint(targ, ftos(ammoqty));	
};

// adapted from AD
void() display_monsleft =
{
	local float entcount, montotal, monalive, mondead, counted, countedalive;
	local entity entlist;
	

	// flush keyboard buffer
	self.impulse = 0;
	// Reset counters
	entcount = montotal = monalive = mondead = 0;

	sprint(self, "\b[-- Monsters Alive and Kicking --]\b\n"); 
	sprint(self, "--------------------------------------\n");
	sprint(self, " No   HP D C Classname + XYZ location\n");
	//            xxx xxxx x x------------------------------x
	// Start from beginning of entity list, world!
	entlist = nextent(world);

	// Keep looping through entity list
	while (entlist) {
		// Found another entity
		entcount = entcount + 1;
		// Only interested in monsters (regular + boss)
		if (
			(entlist.flags & FL_MONSTER || entlist.flags & FL_UNSPAWNEDMONSTER)
			&& !(entlist.flags & FL_PACIFIST && !(entlist.spawnflags & MONSTER_COUNTONSPAWN))
		) {
			// Keep counting up monsters
			montotal = montotal + 1;
			if (entlist.spawnflags & MONSTER_COUNTONSPAWN && !(entlist.flags & FL_PACIFIST)) {
				if(!(entlist.flags & FL_UNSPAWNEDMONSTER)) counted = counted + 1;
			}
			else counted = counted + 1;
			if (entlist.health > 0) {
				monalive = monalive + 1;
				if (monalive <= 400) {
					// Update console display
					zerofill_number(self, monalive, "0", "0", "", "", "");
					sprint(self, " ");
					zerofill_number(self, entlist.health, " ", " ", " ", "", "");
					// Check for monster spawn delay (flag)
					if (entlist.flags & FL_UNSPAWNEDMONSTER) sprint(self, " Y ");
					else sprint(self, " - ");

					if (entlist.spawnflags & MONSTER_COUNTONSPAWN && !(entlist.flags & FL_PACIFIST)) {
						sprint(self, "Y ");
						//if (!(entlist.flags & FL_PACIFIST)) countedalive++;
					}
					else {
						sprint(self, "- ");
						countedalive++;
					}
					// Print monster class and position
					sprint(self, entlist.classname); sprint(self, " ");
					sprint(self, vtos(entlist.origin)); sprint(self, "\n");
				}
				// Only report the first xxx monsters
				// Otherwise will get SZ_GETSPACE : OVERFLOW error
				if (monalive == (401)) {
					sprint(self, " * Can only list ");
					sprint(self, ftos(400));
					sprint(self, "monsters!\n");
				}
			}
			// Monster found is dead
			else mondead = mondead + 1;			
		}		
		// Keep search through ALL of the entity list
		entlist = nextent(entlist);
	}
	sprint(self, "--------------------------------------\n");
	sprint(self, "Monster Total ("); sprint(self, ftos(montotal));
	sprint(self, ") Alive ("); sprint(self, ftos(monalive));
	sprint(self, ") Dead ("); sprint(self, ftos(mondead));
	sprint(self, ")\n");
	sprint(self, "Total counted ("); sprint(self, ftos(counted));sprint(self, ") Alive counted ("); sprint(self, ftos(countedalive));sprint(self, ")\n");
	sprint(self, "Player location "); sprint(self, vtos(self.origin));
	sprint(self, "\n\n");
};


void(entity cl) printVersionConsole = {
	sprint(cl, "\b=============================================\b\n");
	sprint(cl, VERSION_S); sprint(cl, " ("); sprint(cl, BUILD_DATE); sprint(cl, " "); sprint(cl, BUILD_TIME); sprint(cl, ")\n");
	sprint(cl, "\b=============================================\b\n");
};

void() show_bulletholes;
void() hide_bulletholes;

void() ToggleBulletHole = {
	float tmp1;
	tmp1 = cvar("temp1");
	if (bulletmode == 0) {
		bprint("Bullet holes: enabled\n");
		bulletmode = 1;
		show_bulletholes();
		cvar_set("temp1", ftos(tmp1 - (tmp1 & TEMPSETTINGS_NOBULLETHOLES)));
	}
	else {
		bprint("Bullet holes: disabled\n");
		bulletmode = 0;
		hide_bulletholes();
		cvar_set("temp1", ftos(tmp1 | TEMPSETTINGS_NOBULLETHOLES));
	}
};

void() ToggleFootsteps = {
	float tmp1;
	tmp1 = cvar("temp1");
	if (nofootsteps) {
		bprint("Footsteps: enabled\n");
		nofootsteps = 0;
		cvar_set("temp1", ftos(tmp1 - (tmp1 & TEMPSETTINGS_NOFOOTSTEPS)));
	}
	else {
		bprint("Footsteps: disabled\n");
		nofootsteps = 1;
		cvar_set("temp1", ftos(tmp1 | TEMPSETTINGS_NOFOOTSTEPS));
	}
};

void() ToggleAutosave = {
	float tmp1;
	tmp1 = cvar("temp1");
	if (noautosaves) {
		bprint("Autosaves: enabled\n");
		noautosaves = 0;
		cvar_set("temp1", ftos(tmp1 - (tmp1 & TEMPSETTINGS_NOAUTOSAVES)));
	}
	else {
		bprint("Autosaves: disabled\n");
		noautosaves = 1;
		cvar_set("temp1", ftos(tmp1 | TEMPSETTINGS_NOAUTOSAVES));
	}
};

void() ResetModSettings = {
	cvar_set("temp1", 0);
	bprint("Mod settings reset to default\n");
};

/*void() ToggleAutosave =
{
	entity e = world;
	float printed = FALSE;
	do {
		e = find(e, classname, "target_autosave");
		if (!e) break;

		if (e.use == target_autosave_use)
		{
			e.use = SUB_Null;
			if (!printed)
			{
				bprint("Autosaves: disabled\n");
				printed = TRUE;
			}
		} else {
			e.use = target_autosave_use;
			if (!printed)
			{
				bprint("Autosaves: enabled\n");
				printed = TRUE;
			}
		}

	} while (e != world);
}*/

/*
============
ImpulseCommands

============
*/

void() ImpulseCommands =
{
	if (self.impulse >= 1 && self.impulse <= 8)
		W_ChangeWeapon();
	
	if (self.impulse >= 224 && self.impulse <= 235)
		W_ChangeWeapon();
	
	if (self.impulse == 9)
		GiveAllCommand();

	if (self.impulse == 10)
		CycleWeaponCommand();
	if (self.impulse == 11)
		ServerflagsCommand();
	if (self.impulse == 12)
		CycleWeaponReverseCommand();
	if (self.impulse == 13)
		GiveWeaponsCommand();
	if (self.impulse >= 91 && self.impulse <= 99)
		ImpulseTest(self.impulse - 90);

	if (self.impulse == 30)
		ToggleBulletHole();
	if (self.impulse == 31)
		ToggleFootsteps();
	if (self.impulse == 32)
		ToggleAutosave();
	if (self.impulse == 40)
		ResetModSettings();

	if (self.impulse == 128)
		printVersionConsole(self);
		//centerprint(self, VERSION_S);
	if (self.impulse == 184)
		display_monsleft();
	if (self.impulse == 185)
		display_mapvar();
	if (self.impulse == 200)
		dev_reveal();

	if (self.impulse == 252)
		RingCheat();
	if (self.impulse == 253)
		BiosuitCheat();
	if (self.impulse == 254)
		PentCheat();
	if (self.impulse == 255)
		QuadCheat();
	if (self.impulse == 221)
		JBootsTimedCheat();
	if (self.impulse == 222)
		JBootsCheat();
	if (self.impulse == 223)
		JBootsRemoveCheat();

		
	self.impulse = 0;
};

/*
============
W_WeaponFrame

Called every frame so impulse events can be handled as well as possible
============
*/
void() W_WeaponFrame =
{
	if (time < self.attack_finished)
		return;

	if (self.impulse) //johnfitz
		ImpulseCommands ();
	
// check for attack
	if (self.button0)
	{
		SuperDamageSound ();
		W_Attack ();
	}
};

/*
========
SuperDamageSound

Plays sound if needed
========
*/
void() SuperDamageSound =
{
	if ((self.super_damage_finished > time) || (self.trif_finished > time))
	{
		if (self.super_sound < time)
		{
			
			if(self.trif_finished > time) {
				sound(self, CHAN_BODY, "items/trifecta3.wav", 1, ATTN_NORM);
				self.super_sound = time + 0.7;
			}
			else{
				sound (self, CHAN_BODY, "items/damage3.wav", 1, ATTN_NORM);
				self.super_sound = time + 1;
			}
			
		}
	}
	return;
};


