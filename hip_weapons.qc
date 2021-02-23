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
		T_Damage (other, self, self.lastvictim, self.dmg);
    }
	else if ((self.cnt == 3) || (random()<0.15))
    {
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
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