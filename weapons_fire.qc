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
	source = self.origin + self.view_ofs - v_up*6;
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


void(vector org, float dist, float amount) bullethell = {
	float step = 360/amount;
	float yaw;
	vector angs;

	for (yaw = 0; yaw < 360; yaw += step) {
		angs = [0, yaw, 0];
		makevectors(angs);

		newmis = spawn();
		newmis.angles = angs;
		newmis.velocity = v_forward * 600;

		newmis.owner = self;
		newmis.movetype = MOVETYPE_FLYMISSILE;
		newmis.solid = SOLID_BBOX;
		
		newmis.nextthink = time + 5;
		newmis.think = SUB_Remove;
		newmis.touch = Laser_Touch;
		
		setmodel (newmis, "progs/laser.mdl");
		setsize (newmis, '0 0 0', '0 0 0');
		setorigin (newmis, org + v_forward * dist);
	}
}

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
	source = self.origin + self.view_ofs - v_up*6;
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


entity	multi_ent_first, multi_ent_last;
//float	multi_damage;

void() ClearMultiDamage =
{
	//multi_ent = world;
	//multi_damage = 0;
};

void() ApplyMultiDamage =
{
	entity e = multi_ent_first;
	entity e_nxt;
	while (e) {
		e_nxt = e.multi_next;
		T_Damage(e, self, self, e.multi_dmg, DMGTYPE_BALLISTIC);
		e.multi_dmg = 0;
		e.multi_next = world;
		e = e_nxt;
	}
	multi_ent_first = world;
	multi_ent_last = world;
};

void(entity hit, float damage) AddMultiDamage =
{
	if (!hit)
		return;

	if (!multi_ent_first) multi_ent_first = hit;

	if (!hit.multi_dmg)
	{
		if (multi_ent_last) multi_ent_last.multi_next = hit;
		multi_ent_last = hit;
	}
	hit.multi_dmg += damage;
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
	if (notracers)
		return;

	if ((self.flags & FL_CLIENT) && !playertracers)
		return;
	float dist = vlen(org - dest);
	newmis = spawn();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLY;
	newmis.solid = SOLID_NOT;

	newmis.angles = vectoangles(direction);
	
	newmis.classname = "tracer";
	newmis.think = tracer_think;
	newmis.nextthink = time + 0.02;
	newmis.alpha = 0.5;
	
	newmis.velocity = direction * 1024;
	newmis.attack_finished = time + dist/7500;
	//newmis.attack_finished = time + dist/((dist*dist/120) + 3000);

	setmodel (newmis, "progs/pellet_tracer_short.mdl");  //Precache model in WORLD.QC
	setsize (newmis, '0 0 0', '0 0 0');
	setorigin (newmis, org);

	
};

/*
================
TraceAttack
================
*/
void(float damage, vector dir, float penetrate) TraceAttack =
{
	local	vector	vel, org;
	
	org = trace_endpos - dir*4;
	//dprint3("Trace hit: ", trace_ent.classname, "\n");
	


	if ((trace_ent.flags & (FL_MONSTER + FL_CLIENT) && trace_ent.deadflag > 0) || trace_ent.takedamage)	{
		if (trace_ent.bloodtype == SPAWN_DIRT || trace_ent.bloodtype == SPAWN_CHUNK) {
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
	}
	else
		gunshot(org);
	

	if (trace_ent.takedamage) 
		AddMultiDamage (trace_ent, damage);

	if (
		penetrate &&
		trace_ent.flags & (FL_MONSTER + FL_CLIENT) &&
		(
			( trace_ent.health - trace_ent.multi_dmg <= 0)
			|| trace_ent.deadflag > 0
		)
	){
		//dprint2(ftos(trace_ent.flags & (FL_MONSTER + FL_CLIENT)), "\n");
		traceline (trace_endpos + dir*4, trace_endpos + dir*2048, FALSE, trace_ent);
		if (trace_fraction != 1.0) {
			//dprint3("Trace penetrated hit: ", trace_ent.classname, "\n");
			TraceAttack(damage, dir, FALSE);
			placebullethole(trace_endpos, trace_plane_normal, trace_ent);
		}
		//else dprint("Trace penetrated\n");
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
	float penetrate = FALSE;
	//float bullet;
	makevectors(self.v_angle);

	vector rt = v_right;
	vector up = v_up;

	src = self.origin + v_forward*10;
	src_z = self.absmin_z + self.size_z * 0.7;

	ClearMultiDamage ();
	while (shotcount > 0)
	{
		direction = dir + crandom()*spread_x*rt + crandom()*spread_y*up;

		traceline (src, src + direction*2048, FALSE, self);

		if (!(vlen(src - trace_endpos) < 96 && trace_ent.solid == SOLID_BSP))
			drawTracer(src, direction, trace_endpos);

		if (trace_fraction != 1.0) {
			plane_normal = trace_plane_normal;
			//JIM
			TraceAttack(4, direction, penetrate);

			placebullethole(trace_endpos, plane_normal, trace_ent);

		}
		shotcount = shotcount - 1;
		
	}
	ApplyMultiDamage ();
};

void(float shotcount, float dmg, vector org, vector dir, vector spread, float centerbias, float penetrate) FireBullets2 =
{
	local	vector direction;
	local vector plane_normal;
	vector endpoint;
	entity ent_hit;

	vector angs = vectoangles(dir);
	makevectors([-angs_x, angs_y, angs_z]);

	vector rt = v_right;
	vector up = v_up;
	//ClearMultiDamage();
	while (shotcount > 0)
	{
		if (centerbias)
			direction = dir + weighted_crandom(centerbias)*spread_x*rt + weighted_crandom(centerbias)*spread_y*up;
		else
			direction = dir + crandom()*spread_x*rt + crandom()*spread_y*up;

		traceline (org, org + direction*2048, FALSE, self);
		endpoint = trace_endpos;
		ent_hit = trace_ent;

		if (!(vlen(org - trace_endpos) < 128 && ent_hit.solid == SOLID_BSP))
			drawTracer(org, direction, endpoint);
		
		if (trace_fraction != 1.0) {
			plane_normal = trace_plane_normal;
			
			TraceAttack(dmg, direction, penetrate);

			placebullethole(endpoint, plane_normal, ent_hit);

		}
		shotcount = shotcount - 1;
		
	}
	ApplyMultiDamage ();
	//dprint("Attack ended\n");
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

	//if (cvar("scratch3") == 1)
		FireBullets2 (6, 4, self.origin + self.view_ofs - '0 0 6', dir, '0.05 0.05 0', 2, TRUE);
	//else
	//	FireBullets2 (6, 4, self.origin + self.view_ofs - '0 0 6', dir, '0.04 0.04 0', 0, TRUE);
};
//void(float shotcount, float dmg, vector org, vector dir, vector spread, float centerbias, float penetrate) FireBullets2 =

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
	
	//if (cvar("scratch3") == 1)
		FireBullets2 (14, 4, self.origin + self.view_ofs - '0 0 6', dir, '0.15 0.09 0', 2, TRUE);
	//else
	//	FireBullets2 (14, 4, self.origin + self.view_ofs - '0 0 6', dir, '0.14 0.08 0', 0, TRUE);
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
	local float	damg, rdamg, dmgtype;

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
	
	// custom damage type

	dmgtype = defaultFl(self.damagetype, DMGTYPE_EXPLOSION);

	if (other.health)
		T_Damage(other, self, self.owner, damg, dmgtype);
	
	// don't do radius damage to the other, because all the damage
	// was done in the impact.
	// Radius damage type will always be EXPLOSION
	vector prev_vel = self.velocity;
	//self.velocity = '0 0 0';
	T_RadiusDamage (self, self.owner, rdamg, other, DMGTYPE_EXPLOSION);

	self.origin = self.origin - 8*normalize(prev_vel);

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

void() W_FireRocket = {
	self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;
	
	sound (self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

	self.punchangle_x = -2;

	makevectors (self.v_angle);
	
	vector dir = aim(self, 1000);
	vector org = self.origin + self.view_ofs - v_up*6;
	traceline(org, org + v_forward * 24, FALSE, self);
	launch_rocket(org + v_forward*24 * trace_fraction, dir);

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
float(vector org, vector dest, entity attacker, float damage) LightningDamage = {
	entity e1, e2;
	float damaged;
	// vector pointing left
	vector left = normalize(dest - org);
	left = [-left_y, left_x, 0] * 16; 
	
	e1 = e2 = world;

	traceline(org, dest, FALSE, self);
	if (trace_ent.takedamage) {
		ImpactSpawn(trace_endpos, '0 0 100', damage*2, trace_ent.bloodtype);
		T_Damage(trace_ent, attacker, attacker, damage, DMGTYPE_ENERGY);
		damaged = TRUE;
		if (self.classname == "player") {
			if (other.classname == "player")
				trace_ent.velocity_z = trace_ent.velocity_z + 400;
		}
	}
	e1 = trace_ent;

	traceline(org + left, dest + left, FALSE, self);
	if (attacker.flags & FL_CLIENT){
		attacker.lightningcontroller.dest1 = trace_endpos;
	}
	if (trace_ent != e1 && trace_ent.takedamage){
		ImpactSpawn(trace_endpos, '0 0 100', damage*2, trace_ent.bloodtype);
		T_Damage(trace_ent, attacker, attacker, damage, DMGTYPE_ENERGY);
		damaged = TRUE;
	}
	e2 = trace_ent;

	traceline(org - left, dest - left, FALSE, self);
	if (attacker.flags & FL_CLIENT){
		attacker.lightningcontroller.dest2 = trace_endpos;
	}
	if (trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage)	{
		ImpactSpawn(trace_endpos, '0 0 100', damage*2, trace_ent.bloodtype);
		T_Damage(trace_ent, attacker, attacker, damage, DMGTYPE_ENERGY);
		damaged = TRUE;
	}
	return damaged;
};


// Runs at every frame for every player
// self is player.lightningcontroller
void() UpdateLightning = {
	if (!self.count)
		return;

	if (self.attack_finished < time){
		ClearLightning();
		return;
	}
	
	makevectors(self.owner.v_angle);
	vector org = self.owner.origin + self.owner.view_ofs + v_forward*32 - v_up*12;

	float rnd = random();
	vector dest;
	if (rnd < 0.25)
		dest = self.dest1;
	else if (rnd < 0.5)
		dest = self.dest2;
	else
		dest = self.pos2;

	float len = vlen(dest - org);
	vector dir = normalize(dest - org);
	vector ang;

	
	float i;
	vector sgorg;
	
	entity sg = self.sibling;
	entity prevsg;
	float iterations, segments;
	while (sg) {
		// first segment has no previous, so calculate from the player's position
		if (!prevsg) {
			setorigin(sg, org);
			sgorg = bezierCurve(org, org + v_forward*len, dest, dest, i);
		}
		else {
			// divides the full bolt in 100 steps and iterates through that
			// when the distance to the last segment reaches more than 30 units, place the next one
			while (vlen(sgorg - prevsg.origin) < 30 && i <= 1) {
				sgorg = bezierCurve(org, org + v_forward*len, dest, dest, i);
				i += 0.01;
				iterations++;
			}
			setorigin(sg, sgorg);

			// in some cases the last segments pile up and have 0 distance,
			// so calculating an angle out of that gives a borked result.
			// when that happens the previous segment's angles will be reused
			if (sg.origin - prevsg.origin != '0 0 0') 
				ang = vectoangles(sg.origin - prevsg.origin);

			prevsg.angles_x = ang_x;
			prevsg.angles_y = ang_y;
		}

		prevsg = sg;
		sg = sg.sibling;

		segments++;
	}

	if (prevsg && prevsg != self.sibling) {
		prevsg.angles_x = ang_x;
		prevsg.angles_y = ang_y;
	}
	//dprint5("Segments: ", ftos(segments), ", Iterations: ", ftos(iterations), "\n");
	//self.nextthink = time + 0.01;
}

void() LightningSegmentThink = {
	self.angles_z = random()*360;
	self.nextthink = time + 0.025;
	if (self.state) self.alpha -= 0.06;
	else self.alpha -= 0.1;
}

void(entity pl, vector org, vector dest, float hit) DrawLightning = {
	if (pl.lightningcontroller.classname != "lightningcontroller") SUB_CallAsSelf(CreateLightningController, pl);
	entity ct = pl.lightningcontroller;

	if (ct.pain_finished - time > 0.01 && !hit)
		return;

	SUB_CallAsSelf(ClearLightning, ct);

	float len = vlen(dest - org);
	vector dir = normalize(dest - org);
	vector ang = vectoangles(dest - org);

	ct.count = floor(len/30);
	entity sg;
	entity prevsg = ct;
	for (float i = 0; i < ct.count; i++) {
		sg = spawn();
		prevsg.sibling = sg;

		setmodel(sg, "progs/bolt2.mdl");
		setsize(sg, VEC_ORIGIN, VEC_ORIGIN);
		setorigin(sg, org + dir * 30 * i);

		sg.flags |= FL_PROJECTILE;
		sg.classname = "lgsegment";
		sg.angles = ang;
		sg.angles_z = random()*360;
		sg.owner = pl;
		sg.think = LightningSegmentThink;
		sg.nextthink = time + 0.02;
		sg.alpha = 0.9;
		sg.state = hit;
		prevsg = sg;
	}
	if (sg) sg.effects |= EF_DIMLIGHT;

	

	if (hit){
		ct.pain_finished = time + 0.2;
		ct.attack_finished = time + 0.3;
	}
	else { 
		ct.pain_finished = time + 0.1;
		ct.attack_finished = time + 0.2;
	}
	//ct.think = UpdateLightning;
	//ct.nextthink = time + 0.01;
	ct.pos1 = org;
	ct.pos2 = dest;
}

void() ClearLightning = {
	entity ct = self;

	if (!ct.count)
		return;

	entity sg = ct.sibling;
	entity nxsg;

	while (sg.classname == "lgsegment") {
		nxsg = sg.sibling;
		remove(sg);
		sg = nxsg;
	}

	ct.sibling = world;
	ct.count = 0;
	ct.nextthink = 0;
}

void() W_FireLightning = {
	vector 	org;
	float cells;
	entity victim;

	if (self.ammo_cells < 1) {
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo(TRUE);
		return;
	}

	// explode if under water
	if (self.waterlevel > 1 && self.flags & FL_INWATER) {
		cells = self.ammo_cells;
		self.ammo_cells = 0;
		W_SetCurrentAmmo(TRUE);
		victim = findradius(self.origin, 35*cells);
		
		while (victim) {
			if (victim.takedamage && victim.waterlevel > 0 && victim.flags & FL_INWATER) {
				T_Damage(victim, self,self, 35*cells, DMGTYPE_ENERGY);					
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

	makevectors(self.v_angle);
	org = self.origin + self.view_ofs + v_forward*32 - v_up*12;
	
	traceline (org - v_forward*32, org + v_forward*600, TRUE, self);
	vector endpos = trace_endpos;
	float hit = LightningDamage(self.origin, endpos + v_forward*4, self, 30);

	if (oldlightning) {
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_LIGHTNING2);
		WriteEntity (MSG_BROADCAST, self);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
		WriteCoord (MSG_BROADCAST, endpos_x);
		WriteCoord (MSG_BROADCAST, endpos_y);
		WriteCoord (MSG_BROADCAST, endpos_z);
	}
	else {
		DrawLightning(self, org, endpos, hit);
	}
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

	if (oldgrenade) {
		setorigin (missile, self.origin);
	}
	else {
		vector org = self.origin + self.view_ofs - v_up*12;// '0 0 10';
		traceline(org, org + v_forward * 24, FALSE, self);
		setorigin(missile, org + v_forward*24 * trace_fraction);
	}
};


//==========================================================================


void() W_FireBall =
{
	local	entity missile;
	
	
	//sound (self, CHAN_WEAPON, "weapons/marioball.wav", 1, ATTN_NORM);

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;
	missile.classname = "grenade";
	missile.flags = missile.flags | FL_PROJECTILE;
		
// set missile speed	

	makevectors (self.v_angle);

	if (self.v_angle_x)
		missile.velocity = v_forward*500 + v_up * 200 + crandom()*v_right*10 + crandom()*v_up*10;
	else
	{
		missile.velocity = aim(self, 10000);
		missile.velocity = missile.velocity * 500;
		missile.velocity_z = 200;
	}
	missile.gravity = 1.5;
	missile.avelocity = '300 300 300';

	missile.angles = vectoangles(missile.velocity);
	
	missile.movedir = normalize([missile.velocity_x, missile.velocity_y, 0]);
	missile.touch = FireballTouch;
	
// set missile duration
	missile.attack_finished = time + 2.5;
	missile.nextthink = time + 0.001;
	missile.think = FireballThink;

	setmodel (missile, "progs/lavaball.mdl");
	setsize (missile, '0 0 0', '0 0 0');

	if (oldgrenade) {
		setorigin (missile, self.origin);
	}
	else {
		vector org = self.origin + self.view_ofs - v_up*12;// '0 0 10';
		traceline(org, org + v_forward * 24, FALSE, self);
		setorigin(missile, org + v_forward*24 * trace_fraction);
	}
};

void() FireballExplode =
{
	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

	T_RadiusDamage (self, self.owner, 30, world, DMGTYPE_EXPLOSION);

	BecomeExplosion ();
};

void() FireballThink = {
	if (self.jump_flag) {
		self.velocity = self.movedir * 500;
		self.velocity_z = 200;
		self.jump_flag = 0;
	}
	else if (self.origin == self.oldorigin) {
		self.velocity = self.movedir * 500;
		self.velocity_z = 200;
		self.flags &~= FL_ONGROUND;
		self.avelocity = '300 300 300';
	}
	//dprint5("Time: ", ftos(time), ", velocity: ", vtos(self.velocity), "\n");
	//dprint(self.origin == self.oldorigin ? "Not moved\n":"Moved\n");
	if (time > self.attack_finished) {
		FireballExplode();
		return;
	}
	self.oldorigin = self.origin;
	self.nextthink = time + 0.001;
}

void() FireballTouch =
{
	if (other == self.owner)
		return;		// don't explode on owner
	if (other.takedamage == DAMAGE_AIM)
	{
		FireballExplode();
		return;
	}
	
	traceline([self.origin_x, self.origin_y, self.origin_z + 4], [self.origin_x, self.origin_y, self.origin_z - 4], TRUE, self);
	if (trace_fraction < 1) {
		float dot = trace_plane_normal * '0 0 1';
		if (dot > 0.3) {
			self.jump_flag = 1;
		}
		else {
			FireballExplode();
			return;
		}
	}
	else {
		FireballExplode();
		return;
	}

};



//=============================================================================



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

	org = self.origin + self.view_ofs - v_up * 6;//'0 0 16';

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
		W_SetCurrentAmmo(TRUE);
		return;
	}

	makevectors (self.v_angle);

	sound (self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);
	self.attack_finished = time + 0.2;
	self.currentammo = self.ammo_nails = self.ammo_nails - 1;

	org = self.origin + self.view_ofs - v_up * 8 + v_right*ox;
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
				if (CanDamage (head, inflictor.origin) && head.waterlevel > 0)
					T_Damage(head, inflictor, attacker, points, DMGTYPE_ENERGY);
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

	pc = pointcontents2(self.origin);
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
		T_Damage(other, self, self.owner, damg, DMGTYPE_ENERGY);
	

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

	// last projectile was shot continuously, so increase shot count
	if (time < self.lastshot + 0.08) self.shotcount = min(self.shotcount + 1, 6);
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

	org = self.origin + self.view_ofs - v_up * 12;// '0 0 10';
	traceline(org, org + v_forward * 24, FALSE, self);
	//setorigin (missile, org + v_forward*12);
	setorigin (missile, org + v_forward*24 * trace_fraction);

	self.lastshot = time;
};
