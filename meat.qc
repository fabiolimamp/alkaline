/*
==============================================================================

MEAT FIREWORKS

moved from player.qc

the rule: gibs pass through .notrace monsterclip but heads do not, because heads
are kind of the trophies for gibbing something and should hang around rather
than fall through grates (also they look too big)

==============================================================================
*/

void() GibThink = {
	self.alpha -= 0.015;
	if (self.alpha <= 0) {
		SUB_Remove();
		return;
	}
	self.think = GibThink;
	self.nextthink = getLocalTime() + 0.05;
}

vector(float dm) GibVelocityForHealth =
{
	local vector v;
	local float	voom;

	v_x = 100 * crandom();
	v_y = 100 * crandom();
	v_z = 100 + 100 * random();

	voom = max(1, min(10, dm * dm / 5000));
	
	return v * voom;
}

void(entity gib, string gibname) MakeGib =
{
	gib.lifetime_finished = time + 8 + random() * 8;
	gib.th_die = GibThink;
	gib.alpha = 1;
	
	SUB_ChangeModel(gib, gibname);
	gib.type = "gib";
	gib.avelocity = [random(),random(),random()] * 600;
	float frm;

	if (gibname == "progs/gib1.mdl" ||
		gibname == "progs/gib2.mdl" ||
		gibname == "progs/gib3.mdl" 
	) frm = floor(random() * 9.99);
	else frm = 0;

	gib.frame = frm;
	gib.flags = 0;
}

void(string gibname, float dm) ThrowGibArmagon =
{
	local entity gib;

	// gibs have to be thinking ballistic projectiles to pass through monsterclip/notrace :(
	gib = toss_projectile(self.origin + '0 0 96', GibVelocityForHealth(dm), "gib");
	MakeGib(gib, gibname);
	
}

vector(entity emitter, float dm) GibVelocityFromInflictor = {
	if (!emitter.dmg_inflictor || emitter.dmg_inflictor == emitter)
		return '0 0 0'; 

	float pwr = clamp(dm * dm / 22, 10, 800);
	
	vector addvel = normalize(emitter.origin - emitter.inflictor_origin) * pwr;


	addvel_z *= 0.7;

	// explosions get a little more speed
	if (emitter.deathtype == DMGTYPE_EXPLOSION) {
		addvel_x *= 3;
		addvel_y *= 3;
	}
	else {
		addvel_x *= 2.2;
		addvel_y *= 2.2;
	}

	// Add a bit of velocity from the projectile itself.
	// For a more dramatic effect with high-speed and relatively
	// low damage projectiles that still may gib under quad,
	// like the SNG and the Plasma Gun.
	if (emitter.inflictor_movetype == MOVETYPE_FLYMISSILE && emitter.inflictor_vel != '0 0 0') {
		float projlinvel = vlen(emitter.inflictor_vel);
		addvel += emitter.inflictor_vel * min(projlinvel, 180)/projlinvel;
	}

	return addvel;
}

void(entity gib) capGibVelocity = {
	float linvel = vlen(gib.velocity);

	// limit linear speed
	if (linvel > 550) {
		gib.velocity *= 550 / linvel;
	}

	// cap Z speed so gibs won't go flying too crazily up in the air
	gib.velocity_z = min(500, gib.velocity_z);

}

entity(string gibname, float dm) ThrowGib =
{
	local entity gib;
	vector org;

	org = self.origin;
	
	//org_x = self.origin_x + crandom()*self.size_x/3;
	//org_y = self.origin_y + crandom()*self.size_y/3;
	//org_z = self.origin_z + crandom()*self.size_z/3;
	
	// gibs have to be thinking ballistic projectiles to pass through monsterclip/notrace :(
	
	//gib = toss_projectile(org, GibVelocityForHealth(max(dm, -99)), "gib");
	gib = toss_projectile(org, GibVelocityForHealth(dm), "gib");
	gib.velocity += GibVelocityFromInflictor(self, dm);
	capGibVelocity(gib);

	MakeGib(gib, gibname);
	return gib;

}

void(string gibname, float dm) ThrowHead =
{	setmodel (self, gibname);
	self.frame = 0;
	self.movetype = MOVETYPE_BOUNCE;
	self.takedamage = DAMAGE_NO;
	self.solid = SOLID_TRIGGER; //make them SOLID_TRIGGER so they can be caught by a trigger_void
	setorigin(self, self.origin);
	self.touch = SUB_Null;
	self.view_ofs = '0 0 8';
	setsize (self, '-16 -16 0', '16 16 56');
	//setsize (self, '0 0 0', '0 0 0');
	
	//self.velocity += GibVelocityForHealth(max(dm, -99));
	self.velocity += GibVelocityForHealth(dm);

	self.velocity += GibVelocityFromInflictor(self, dm);
	capGibVelocity(self);
	
	self.origin_z = self.absmax_z - 24;
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	self.type = "head";
	self.avelocity = crandom() * '0 600 0';
	self.nextthink = time + 5;
	self.think = SUB_MakeNotSolid;
}

// for player heads that fall into a trigger_void
void() ThrowHeadVoid =
{	
	setmodel (self, "progs/misc_empty.mdl"); // so you don't see dead heads at the bottom of the pit
	self.frame = 0;
	self.nextthink = -1;
	self.takedamage = DAMAGE_NO;
	self.solid = SOLID_NOT;
	self.view_ofs = '0 0 8';
	setsize (self, '-16 -16 0', '16 16 56');
	self.origin_z = self.absmax_z - 24;
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	self.type = "head";
}

// Gib & GibSpray are split up since some monsters play special gib sounds (zombies/players) and
// I want all monsters going through GibSpray for trigger_void tests
void(string headmdl, float dm) GibSpray =
{
	ThrowGib ("progs/gib1.mdl", dm);
	ThrowGib ("progs/gib2.mdl", dm);
	ThrowGib ("progs/gib3.mdl", dm);
	
	if (self.classname != "player")
		if (damage_attacker.classname == "trigger_void" || damage_attacker.classname == "func_void" )
		{
			SUB_Remove();
			return;
		}

		
	ThrowHead (headmdl, dm);
}

void(string headmdl, float dm) Gib =
{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
	
	GibSpray(headmdl, dm);
}


/*
================
SpawnMeatSpray
================
*/
void(vector org, vector vel) SpawnMeatSpray =
{
	entity meat;
	vector mvel;
	
	mvel = vel;
	mvel_z += 250 + 50 * random();

	
	meat = toss_projectile(org, mvel, "gib");
	//meat.solid = SOLID_NOT;
	meat.type = "gib";
	meat.avelocity = '3000 1000 2000';
	meat.lifetime_finished = time + 1;

	SUB_ChangeModel(meat, "progs/zom_gib.mdl");
	
}

/*
================
SpawnBitSpray
================
*/
void(vector org, vector vel) SpawnBitSpray =
{
	entity bit;
	vector mvel;
	
	mvel = vel;
	mvel_z += 250 + 50 * random();

	bit = toss_projectile(org, mvel, "gib");

	bit.type = "gib";
	bit.avelocity = '500 300 300';
	bit.lifetime_finished = time + 1;

	SUB_ChangeModel(bit, "progs/bit.mdl");
}

//============================================================================

// meat noise
// meat noise
// play that funky meat noise
void() meat_noise =
{
	float r = random();
	if (r < 0.25)
		sound (self, CHAN_BODY, "player/teledth1.wav", 1, ATTN_NORM);
	else if (r < 0.5)
		sound (self, CHAN_BODY, "player/tornoff2.wav", 1, ATTN_NORM);
	else if (r < 0.75)
		sound (self, CHAN_BODY, "player/udeath.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_BODY, "player/gib.wav", 1, ATTN_NORM);
}

void(string gibname) target_meat_fireworks_do =
{
	vector spray;
	entity gib;
	spray = '1 1 1' - self.mangle;
	spray_x = spray_x * crandom() + self.mangle_x * 4;
	spray_y = spray_y * crandom() + self.mangle_y * 4;
	spray_z = spray_z * crandom() + self.mangle_z * 4;
	spray *= self.speed * 2;
	
	gib = toss_projectile(self.origin, spray, "gib");
	MakeGib(gib, gibname);
}

void() target_meat_fireworks_go =
{
	vector spray;
	float i;
	meat_noise();
	
	for (i = 0; i < 3; i++)
	{
		spray = '1 1 1' - self.mangle;
		spray_x *= crandom();
		spray_y *= crandom();
		spray_z *= crandom();
		spray += self.mangle * 0.5;
		SpawnMeatSpray(self.origin, spray * self.speed);
	}
	
	target_meat_fireworks_do("progs/gib1.mdl");
	target_meat_fireworks_do("progs/gib2.mdl");
	target_meat_fireworks_do("progs/gib3.mdl");
}

void() target_meat_fireworks_use =
{
	float i, tnext;
	entity meats;
	
	playercount_convert(count);
	if (self.count == 1 && self.delay == 0)
	{
		target_meat_fireworks_go();
		return;
	}
	
	tnext = self.delay + self.rand * random();
	for (i = 0; i < self.count; i++)
	{
		meats = spawn();
		setorigin(meats, self.origin);
		meats.think = target_meat_fireworks_go;
		meats.mangle = self.mangle;
		meats.speed = self.speed;
		meats.nextthink = time + tnext;
		tnext += self.wait + self.rand * random();
	}
}

/*QUAKED target_meat_fireworks (0.7 .0 .2) (-16 -16 -16) (16 16 16)
trigger for meat

Keys
"count" number of times of meat after triggering, default 1
"delay" time to wait before first meat
"wait" time to wait between meat
"rand" max random additional to wait before meat
"speed" speed of meat
"mangle" override meat direction, defaults to up
*/
/*FGD
@PointClass base(Appearflags, Targetname) size(32 32 32) color(180 0 50) = target_meat_fireworks : "trigger for meat"
[
	count(integer) : "Repeat meat" : 1
	delay(string) : "Delay before first meat" : "0"
	wait(string) : "Wait between meat" : "1"
	rand(string) : "Random extra wait before meat" : "0"
	speed(integer) : "Speed of meat" : 128
	mangle(string) : "Override meat vector" : "0 0 1"
]
*/
void() target_meat_fireworks =
{
	if (!SUB_InitEntity()) return;
	
	//if (!SUB_ShouldSpawn()) return;
	self.speed = zeroconvertdefault(self.speed, 128);
	self.count = zeroconvertdefault(self.count, 1);
	self.use = target_meat_fireworks_use;
	if (!self.wait)
		self.wait = 1;
	
	if (self.mangle == VEC_ORIGIN)
	{
		self.mangle = VEC_UP;
	}
	else
	{
		self.mangle = normalize(self.mangle);
	}
}

void() misc_meat_fireworks = {target_meat_fireworks();}