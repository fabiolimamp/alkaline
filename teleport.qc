/*
==============================================================================

TELEPORT TRIGGERS

==============================================================================
*/

float	PLAYER_ONLY	= 1;
float	SILENT = 2;
float TELE_STEALTH = 4;
float TELE_MONSTER_ONLY = 8;
float TELE_INSTANT = 16;


float TELEPORT_STYLE_FIRST = 0;
float TELEPORT_STYLE_RANDOM = 1;
float TELEPORT_STYLE_CYCLE = 2;

float TELEDEST_KEEPANGLE = 1;
float TELEDEST_STEALTH = 4;

float TELEDEST_STYLE_NORMAL = 0;
float TELEDEST_STYLE_INSTANT = 1;

void() play_teleport =
{
	local	float v;
	local	string tmpstr;

	v = random() * 5;
	if (v < 1)
		tmpstr = "misc/r_tele1.wav";
	else if (v < 2)
		tmpstr = "misc/r_tele2.wav";
	else if (v < 3)
		tmpstr = "misc/r_tele3.wav";
	else if (v < 4)
		tmpstr = "misc/r_tele4.wav";
	else
		tmpstr = "misc/r_tele5.wav";

	sound (self, CHAN_VOICE, tmpstr, 1, ATTN_NORM);
	remove (self);
};

void(vector org) spawn_tfog =
{
	s = spawn ();
	s.origin = org;
	s.nextthink = time + 0.2;
	s.think = play_teleport;

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_TELEPORT);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
};


void() tdeath_touch =
{
	if (other == self.owner)
		return;

// frag anyone who teleports in on top of an invincible player
	if (other.classname == "player")
	{
		if ((other.invincible_finished > time) || (other.trif_finished > time))
			self.classname = "teledeath2";
		if (self.owner.classname != "player")
		{	// other monsters explode themselves
			T_Damage(self.owner, self, self, 50000, DMGTYPE_INSTANT);
			return;
		}
		
	}

	if (other.health)
	{
		T_Damage(other, self, self, 50000, DMGTYPE_INSTANT);
	}
};


void(vector org, entity death_owner) spawn_tdeath =
{
local entity	death;

	death = spawn();
	death.classname = "teledeath";
	death.movetype = MOVETYPE_NONE;
	death.solid = SOLID_TRIGGER;
	death.angles = '0 0 0';
	setsize (death, death_owner.mins - '1 1 1', death_owner.maxs + '1 1 1');
	setorigin (death, org);
	death.touch = tdeath_touch;
	death.nextthink = time + 0.2;
	death.think = SUB_Remove;
	death.owner = death_owner;
	
	force_retouch = 2;		// make sure even still objects get hit
};

entity() teleport_getdestination = {
	entity dests[256];
	entity d;
	float totaldests, i, nextdest;
	float maxdest, mindest;

	if (self.style == TELEPORT_STYLE_RANDOM) {

		d = find(world, targetname, self.target);
		while (d) {
			if ((d.classname == "info_teleport_destination" || d.classname == "trigger_teleport_instadestination") && d.estate == STATE_ACTIVE) {
				dests[i] = d;
				i++;
				totaldests++;
			}
			d = find(d, targetname, self.target);
		}

		if (!totaldests) return world;

		i = floor(random() * (totaldests - 0.01));
		//dprint5("Found ", ftos(totaldests), " dests, returning ", ftos(i), "\n");
		return dests[i];
	}
	else if (self.style == TELEPORT_STYLE_CYCLE) {
		nextdest = 255;
		mindest = 255;
		
		d = find(world, targetname, self.target);
		while (d) {
			if ((d.classname == "info_teleport_destination" || d.classname == "trigger_teleport_instadestination") && d.estate == STATE_ACTIVE) {
				if (dests[d.count]) {
					dprint3("trigger_teleport (", vtos((self.mins + self.maxs)*0.5), "): destinations with the same count order at:\n");
					dprint4(vtos(d.origin), " and ", vtos(dests[d.count].origin), "\n");
				}

				dests[d.count] = d;

				if (d.count > self.count && d.count < nextdest) nextdest = d.count;
				if (d.count < mindest) mindest = d.count;
				if (d.count > maxdest) maxdest = d.count;

				totaldests++;
			}
			d = find(d, targetname, self.target);
		}

		if (!totaldests) return world;

		if (self.count >= maxdest) nextdest = mindest;
		self.count = nextdest;
		return dests[nextdest];

	}
	else { // TELEPORT_STYLE_FIRST, default
		nextdest = 255;
		
		d = find(world, targetname, self.target);
		while (d) {
			if ((d.classname == "info_teleport_destination" || d.classname == "trigger_teleport_instadestination") && d.estate == STATE_ACTIVE) {
				if (dests[d.count]) {
					dprint3("trigger_teleport (", vtos((self.mins + self.maxs)*0.5), "): destinations with the same count order at:\n");
					dprint4(vtos(d.origin), " and ", vtos(dests[d.count].origin), "\n");
				}

				dests[d.count] = d;

				if (d.count < nextdest) nextdest = d.count;
				totaldests++;
			}
			d = find(d, targetname, self.target);
		}

		if (!totaldests) return world;
		else return dests[nextdest];
	}
};

void() restoreModel = {
	setmodel(self.owner, self.mdl);
	setsize(self.owner, self.cmins, self.cmaxs);
	self.owner.skin = self.armortype;
	self.owner.frame = self.armorvalue;
	self.owner.aiment = world;
	remove(self);
}

void() teleport_touch =
{
	local entity	t;
	local vector	org;
	local vector	tAngle, pAngle, outAngle;
	local float vAngleX;

	if (self.estate != STATE_ACTIVE)
		return;

	if (self.mapvar && !read_mapvar(self.mapvar))
		return;
	
	if (self.targetname != "" && self.is_waiting != -1)	{
		if (self.nextthink < time)
			return;		// not fired yet
	}

	if (self.spawnflags & PLAYER_ONLY)
	{
		if (other.classname != "player")
			return;
	}
	
	if (self.spawnflags & TELE_MONSTER_ONLY)
	{
		if (!(other.flags & FL_MONSTER))
			return;
	}

	// only teleport living creatures
	//if (other.health <= 0 || other.solid != SOLID_SLIDEBOX)
	//	return;

	
	t = teleport_getdestination();
	if (!t) {
		dprint5("trigger_teleport (", vtos((self.mins + self.maxs)*0.5), ": couldn't find target \"", self.target, "\"\n");
		return;
	}


	if (t.style == TELEDEST_STYLE_NORMAL) {
		if (other.health <= 0 || other.solid != SOLID_SLIDEBOX)
			return;
	}

	SUB_UseTargets();

	// put a tfog where the player was
	if(!(self.spawnflags & TELE_STEALTH || t.style == TELEDEST_STYLE_INSTANT)) spawn_tfog (other.origin);

	// spawn a tfog flash in front of the destination
	
	tAngle = [t.mangle_x, t.mangle_y, 0];
	pAngle = [other.angles_x, other.angles_y, 0];

	if (t.spawnflags & TELEDEST_KEEPANGLE || t.style == TELEDEST_STYLE_INSTANT){
		outAngle = tAngle + pAngle;
		vAngleX = other.v_angle_x;
		
		if (tAngle != '0 0 0') {
			makevectors(vectoangles(other.velocity) + tAngle);
			other.velocity = v_forward * vlen(other.velocity);
			other.velocity_z *= -1;
		}


	}
	else outAngle = tAngle;

	makevectors (outAngle);
	vector outAngleForward = v_forward;
	org = t.origin + 32 * outAngleForward;

	if(!(t.spawnflags & TELEDEST_STEALTH || t.style == TELEDEST_STYLE_INSTANT)) spawn_tfog (org);
	spawn_tdeath(t.origin, other);

// move the player and lock him down for a little while
	if (!other.health && other.flags & FL_CLIENT)
	{
		other.origin = t.origin;
		other.velocity = (outAngleForward * other.velocity_x) + (outAngleForward * other.velocity_y);
		return;
	}

	vector neworg;
	if (t.style == TELEDEST_STYLE_INSTANT) {
		vector teleMid = (self.absmin + self.absmax)/2;
		vector destMid = (t.absmin + t.absmax)/2;

		// rotates destination point around mangle
		if (t.mangle) {
			vector offs = other.origin - teleMid;
			makevectors(vectoangles(offs) + t.mangle);
			offs = v_forward * vlen(offs);
			offs_z *= -1;

			neworg = destMid + offs;
		}
		else
			neworg = other.origin - teleMid + destMid;

		// projectiles and gibs must have their models removed for a few frames
		// otherwise effect trails may lerp when the destination is close enough
		if (other.flags & FL_PROJECTILE || other.classname == "gib") {
			// there was a controller attached already, give a little more time
			if (other.aiment.classname == "mdlcontroller") {
				other.aiment.nextthink = time + 0.05;
			}
			else {
				entity mdlctrl = spawn();
				other.aiment = mdlctrl;
				mdlctrl.classname = "mdlcontroller";
				mdlctrl.nextthink = time + 0.05;
				mdlctrl.think = restoreModel;
				mdlctrl.owner = other;
				mdlctrl.cmins = other.mins;
				mdlctrl.cmaxs = other.maxs;
				mdlctrl.mdl = other.model;
				mdlctrl.armortype = other.skin;
				mdlctrl.armorvalue = other.frame;
				other.frame = 0;
				other.skin = 0;

				setmodel(other, "progs/misc_empty.mdl");
				setsize(other, mdlctrl.cmins, mdlctrl.cmaxs);
			}
		}
		setorigin (other, neworg);

	}
	else
		setorigin (other, t.origin);
	
	

	other.angles = outAngle;
	if (other.classname == "player")
	{
		fog_setFromEnt(other, t);
		if (t.spawnflags & TELEDEST_KEEPANGLE || t.style == TELEDEST_STYLE_INSTANT)
			other.angles_x = vAngleX; // reset vertical view angle, engine bug?

		other.fixangle = 1;		// turn this way immediately
		if (t.style != TELEDEST_STYLE_INSTANT) other.teleport_time = time + 0.7;

		if (other.flags & FL_ONGROUND)
			other.flags = other.flags - FL_ONGROUND;

		if (t.style != TELEDEST_STYLE_INSTANT)
			other.velocity = outAngleForward * 300;


	}
	other.flags = other.flags - other.flags & FL_ONGROUND;
};

/*QUAKED info_teleport_destination (.5 .5 .5) (-8 -8 -8) (8 8 32)
This is the destination marker for a teleporter.  It should have a "targetname" field with the same value as a teleporter's "target" field.
*/
void() info_teleport_destination =
{
// this does nothing, just serves as a target spot
	self.mangle = self.angles;
	self.angles = '0 0 0';
	self.model = "";
	self.origin = self.origin + '0 0 27';
	if (!self.targetname)
		objerror ("no targetname");
};

void() teleport_use =
{
	self.nextthink = time + 0.2;
	force_retouch = 2;		// make sure even still objects get hit
	self.think = SUB_Null;
};

/*QUAKED trigger_teleport (.5 .5 .5) ? PLAYER_ONLY SILENT
Any object touching this will be transported to the corresponding info_teleport_destination entity. You must set the "target" field, and create an object with a "targetname" field that matches.

If the trigger_teleport has a targetname, it will only teleport entities when it has been fired.
*/
void() trigger_teleport =
{
	local vector o;

	InitTrigger ();
	self.touch = teleport_touch;
	// find the destination 
	if (!self.target)
		objerror ("no target");
	self.use = teleport_use;

	self.count = -1;
	if (!(self.spawnflags & SILENT))
	{
		precache_sound ("ambience/hum1.wav");
		o = (self.mins + self.maxs)*0.5;
		ambientsound (o, "ambience/hum1.wav",0.5 , ATTN_STATIC);
	}

	SUB_CheckWaiting();
};


void() trigger_teleport_instadestination = {
	InitTrigger();
	self.style = TELEDEST_STYLE_INSTANT;
};
