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
	
	self.show_hostile = time + 1; // hit something, so alert monsters

	org = trace_endpos - v_forward*4;

	if (trace_ent.takedamage) {
		trace_ent.axhitme = 1;

		ImpactSpawn(org, '0 0 0', 20, trace_ent.bloodtype);
		T_Damage(trace_ent, self, self, 20, DMGTYPE_MELEE);
		
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
			T_Damage(ent, self, self, 24, DMGTYPE_MELEE);
		else
			T_Damage(ent, self, self, 30, DMGTYPE_MELEE);
		
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
	T_Damage(multi_ent, self, self, multi_damage, DMGTYPE_BALLISTIC);
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

void() tracer_think = {
	if (time > self.attack_finished || self.frame >= 4) {
		remove(self);
		return;
	}

	self.frame++;
	self.nextthink = time + 0.02;
};


void(vector org, vector direction, vector dest) drawTracer = {

	newmis = spawn();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLY;
	newmis.solid = SOLID_NOT;

	newmis.angles = vectoangles(direction);
	
	newmis.classname = "tracer";
	newmis.think = tracer_think;
	newmis.nextthink = time + 0.02;
	newmis.alpha = 0.8;
	newmis.attack_finished = time + vlen(org - dest)/2200;
		
	setmodel (newmis, "progs/pellet_tracer_short.mdl");  //Precache model in WORLD.QC
	setsize (newmis, '0 0 0', '0 0 0');
	setorigin (newmis, org);

	newmis.velocity = direction * 2000;
};

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

		drawTracer(src, direction, trace_endpos);

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

		drawTracer(org, direction, trace_endpos);
		
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

	if (pointcontents(self.origin) == CONTENT_SKY)	{
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
		T_Damage(other, self, self.owner, damg, DMGTYPE_EXPLOSION);

	// don't do radius damage to the other, because all the damage
	// was done in the impact
	T_RadiusDamage (self, self.owner, rdamg, other, DMGTYPE_EXPLOSION);

	self.origin = self.origin - 8*normalize(self.velocity);

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

		T_Damage(trace_ent, from, from, damage, DMGTYPE_ELECTRIC);
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
		T_Damage(trace_ent, from, from, damage, DMGTYPE_ELECTRIC);
	}
	e2 = trace_ent;

	traceline (p1 - f, p2 - f, FALSE, self);
	if (trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage)
	{
		particle (trace_endpos, '0 0 100', 225, damage*4);
		T_Damage(trace_ent, from, from, damage, DMGTYPE_ELECTRIC);
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
						T_Damage(victim, self,self, 35*cells, DMGTYPE_ELECTRIC);					
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

	T_RadiusDamage (self, self.owner, 120, world, DMGTYPE_EXPLOSION);

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
		T_Damage(other, self, self.owner, damage, DMGTYPE_BALLISTIC);
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
		T_Damage(other, self, self.owner, damage, DMGTYPE_BALLISTIC);
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

//=============================================================================


void()  s_pexplode1  = [0,   s_pexplode2] {self.nextthink = time + 0.05;};
void()  s_pexplode2  = [1,   s_pexplode3] {self.nextthink = time + 0.05;};
void()  s_pexplode3  = [2,   s_pexplode4] {self.nextthink = time + 0.05;};
void()  s_pexplode4  = [3,   s_pexplode5] {self.nextthink = time + 0.05;};
void()  s_pexplode5  = [4,   s_pexplode6] {self.nextthink = time + 0.05;self.effects -= EF_DIMLIGHT;};
void()  s_pexplode6  = [5,   SUB_Remove] {self.nextthink = time + 0.05;};

void(entity inflictor, entity attacker, float damage, entity ignore) WaterRadiusDamage = {
	float points;
	entity head;
	vector org;

	head = findradius(inflictor.origin, damage+40);
	
	while (head) {
		if (head != ignore && head.takedamage) {
			org = head.origin + (head.mins + head.maxs)*0.5;
			points = 0.5 * vlen(inflictor.origin - org);
			
			if (points < 0)
				points = 0;

			points = damage - points;

			if (head == attacker)
				points = points * 0.5;

			if (points > 0) {
				if (CanDamage (head, inflictor) && head.waterlevel > 0)
					T_Damage(head, inflictor, attacker, points, DMGTYPE_ELECTRIC);
			}
		}

		head = head.chain;
	}
};


void() PlasmaExplosion = {
	self.movetype = MOVETYPE_NONE;
	self.velocity = '0 0 0';
	self.touch = SUB_Null;
  	setmodel (self, "progs/s_plasma_new.spr");
  	setsize(self, 0, 0);
	self.solid = SOLID_NOT;
  	s_pexplode1();
};

void() Plasma_Watercheck = {
  // The routine modified from BLAZE.QC included in the killer87 package.
  // Basically, plasma bullets explode when hitting liquids.
  // In this explosion, the electic charge of the plasma bullet is spread
  // into the said liquid...
  
	float pc;

	pc = pointcontents(self.origin);
	if (pc == CONTENT_WATER || pc == CONTENT_SLIME || pc == CONTENT_LAVA) {
		sound(self, CHAN_WEAPON, "enforcer/enfstop.wav", 1, ATTN_NORM);

		WaterRadiusDamage(self, self.owner, 60, world);   // Damage
		PlasmaExplosion();                         // Explosion sprite
		return;
	}

	self.think = Plasma_Watercheck;
	self.nextthink = time;
};

void() T_PlasmaTouch = {
	local float damg;

	if (other == self.owner)
		return;   // don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY) {
		remove(self);
		return;
	}
	damg = 17;

	if (other.health)
		T_Damage(other, self, self.owner, damg, DMGTYPE_ELECTRIC);
	

	// Moves the plasma bullet backwards after hitting.. Otherwise the 
	// explosion sprite would often be inside a wall or something. 
	self.origin = self.origin - 8*normalize(self.velocity);

	// Sound from Doom...
	sound (self, CHAN_WEAPON, "weapons/dsfirxpl.wav", 1, ATTN_NORM);
	PlasmaExplosion();
};

/*
================
W_FirePlasma
================
*/
void() W_FirePlasma =
{
	local entity missile;
	vector org;

	self.currentammo = self.ammo_cells = self.ammo_cells - 1;

	// Taken from Doom...
	sound (self, CHAN_WEAPON, "weapons/dsplasma.wav", 1, ATTN_NORM);

	self.punchangle_x = -2;

	missile = spawn();
	missile.owner = self;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX;
	missile.classname = "plasma";
	missile.flags = missile.flags | FL_PROJECTILE;

	// shot spread increases the longer you hold the trigger,
	// and slowly recovers after that -bmFbr
	if (time < self.lastshot + 0.065) self.shotcount = min(self.shotcount + 1, 6);
	else self.shotcount = max(2, self.shotcount - rint((time - self.lastshot - 0.15)/0.15));
	
	makevectors (self.v_angle);
	missile.velocity = aim(self, 1000) * 1000;
	missile.velocity = missile.velocity + (crandom() * 50 * (self.shotcount*self.shotcount/36) * v_right );
	missile.velocity = missile.velocity + (crandom() * 50 * (self.shotcount*self.shotcount/36) * v_up );
	missile.angles = vectoangles(missile.velocity);
	missile.avelocity = '300 300 300';  

	missile.nextthink = time;
	missile.think = Plasma_Watercheck;        // If shot underwater -> razzp!
	missile.touch = T_PlasmaTouch;

	missile.effects = EF_DIMLIGHT;           // Plasma bullets emit light...

	setmodel (missile, "progs/pbullet.mdl");   // Plasma bullet model
	setsize (missile, '0 0 0', '0 0 0');
	//setorigin (missile, self.origin + v_forward*8 + '0 0 10' + v_right*10);

	org = self.origin + '0 0 10';
	traceline(org, org + v_forward * 24, FALSE, self);
	//setorigin (missile, org + v_forward*12);
	setorigin (missile, org + v_forward*24 * trace_fraction);

	self.lastshot = time;
};
