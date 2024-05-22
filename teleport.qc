/*
==============================================================================

TELEPORT TRIGGERS

==============================================================================
*/

float PLAYER_ONLY	= 1;
float SILENT = 2;
float TELE_STEALTH = 4;
float TELE_MONSTER_ONLY = 8;
float TELE_PLAYERTRIGGERED = 16;


float TELEPORT_STYLE_FIRST = 0;
float TELEPORT_STYLE_RANDOM = 1;
float TELEPORT_STYLE_CYCLE = 2;

float TELEDEST_KEEPANGLE = 1;
float TELEDEST_KEEPPITCH = 2;
float TELEDEST_STEALTH = 4;
float TELEDEST_KEEPVELOCITY = 8;
float TELEDEST_KEEPANGLE_NOOFFSET = 16;

float TELEDEST_STYLE_NORMAL = 0;
float TELEDEST_STYLE_INSTANT = 1;

void() play_teleport = {
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

void(vector org) spawn_tfog = {
	entity telesound = spawn();
	telesound.origin = org;
	telesound.nextthink = time + 0.2;
	telesound.think = play_teleport;

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_TELEPORT);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
};


void() tdeath_touch = {
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


void(vector org, entity death_owner) spawn_tdeath = {
	entity death;

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
			if (	(d.classname == "info_teleport_destination"
					|| d.classname == "trigger_teleport_instadestination"
					||  d.classname == "misc_teleporttrain"
				)
				&& d.estate == STATE_ACTIVE)
			{
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
			if (	(d.classname == "info_teleport_destination"
					|| d.classname == "trigger_teleport_instadestination"
					||  d.classname == "misc_teleporttrain"
				)
				&& d.estate == STATE_ACTIVE)
			{
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
			if (	(d.classname == "info_teleport_destination"
					|| d.classname == "trigger_teleport_instadestination"
					||  d.classname == "misc_teleporttrain"
				)
				&& d.estate == STATE_ACTIVE)
			{
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
	local vector	tAngle, pAngle;
	local float vAngleX;

	if (other.flags & FL_NEVERTELEPORT)
		return;

	if (other.solid == SOLID_BSP)
		return;

	if (self.estate != STATE_ACTIVE)
		return;

	if (self.mapvar && !read_mapvar(self.mapvar))
		return;
	
	if (self.targetname != "" && self.is_waiting != -1)	{
		if (self.nextthink < time)
			return;		// not fired yet
	}

	if (self.spawnflags & PLAYER_ONLY) {
		if (!(other.flags & FL_CLIENT))
			return;
	}
	
	if (self.spawnflags & TELE_MONSTER_ONLY) {
		if (!(other.flags & FL_MONSTER))
			return;
	}

	if (self.spawnflags & TELE_PLAYERTRIGGERED && self.nextthink < time) {
		if (other.flags & FL_CLIENT)
			teleport_use();
			
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
	if (!(self.spawnflags & TELE_STEALTH || t.spawnflags & TELEDEST_STEALTH))
		spawn_tfog (other.origin);

	// teleport destination's angle offset
	tAngle = t.mangle;

	// entity is a client, so take the angles from v_angle instead
	if (other.flags & FL_CLIENT)
		pAngle = [-other.v_angle_x, other.v_angle_y, other.v_angle_z]; // v_angle has +pitch as down instead of up
	else
		pAngle = other.angles;

	// stores the original v_angle pitch for players
	vAngleX = other.v_angle_x;

	makevectors([tAngle_x, tAngle_y, tAngle_z]);
	vector t_forward = v_forward;
	vector t_right = v_right;
	vector t_up = v_up;

	makevectors([-pAngle_x, pAngle_y, pAngle_z]);
	vector p_forward = v_forward;
	vector p_right = v_right;
	vector p_up = v_up;

	// offsets the current angle by the destination's mangle,
	// if the destination is a instant brush, or the info_destination has a
	// "keep angle" flag
	if (t.spawnflags & TELEDEST_KEEPANGLE || t.style == TELEDEST_STYLE_INSTANT) {
		other.angles = vectoangles(t_forward*p_forward_x - t_right*p_forward_y + t_up*p_forward_z);
		other.angles_y = vectoyaw2(t_forward*p_forward_x - t_right*p_forward_y + t_up*p_forward_z);
	}
	else
		other.angles = tAngle;

	if (t.spawnflags & TELEDEST_KEEPANGLE || t.style == TELEDEST_STYLE_INSTANT || t.spawnflags & TELEDEST_KEEPVELOCITY) 
		other.velocity = f_forward*other.velocity_x - t_right*other.velocity_y + t_up*other.velocity_z;

	// only players, projectiles and gibs maintain their pitch and roll angles
	// everything else gets set to what it was before
	if (!(other.flags & (FL_PROJECTILE + FL_CLIENT)) && other.classname != "gib") {
		other.angles_x = pAngle_x;
		other.angles_z = pAngle_z;
	}


	spawn_tdeath(t.origin, other);

	// move the player and lock him down for a little while
	if (!other.health && other.flags & FL_CLIENT)
	{
		other.origin = t.origin;
		other.velocity = (p_forward * other.velocity_x) + (p_forward * other.velocity_y);
		return;
	}

	vector neworg;

	// instant teleports need a little more math
	if (t.style == TELEDEST_STYLE_INSTANT) {
		vector teleMid = (self.absmin + self.absmax)/2;
		vector destMid = (t.absmin + t.absmax)/2;

		// rotates destination point around mangle
		if (tAngle) {
			vector offs = other.origin - teleMid;
			neworg = destMid + t_forward*offs_x - t_right*offs_y + t_up*offs_z;
		}
		else
			neworg = other.origin - teleMid + destMid;

		// if the entity is onground, move the origin upwards a bit and drop it to avoid getting stuck at the destination
		if (other.flags & FL_ONGROUND) {
			traceline(neworg + [0, 0, other.maxs_z], neworg + [0, 0, other.maxs_z] + '0 0 32', 0, other);
			setorigin(other, neworg + [0, 0, trace_fraction * 32]);
			entity oself = self;
			self = other;
			droptofloor();
			self = oself;
		}
		else
			setorigin(other, neworg);

		// projectiles and gibs must have their models removed for a few frames
		// otherwise effect trails may lerp when the destination is close enough
		if (other.flags & FL_PROJECTILE || other.classname == "gib") {
			// there was a controller attached already, so give it a little more time
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
	}
	// standard info_teleport_destination
	else
		setorigin (other, t.origin);
	
	// spawn a tfog flash in front of the destination
	if (!(self.spawnflags & TELE_STEALTH || t.spawnflags & TELEDEST_STEALTH))
		spawn_tfog (other.origin + 32 * t_forward);

	
	if (other.classname == "player")
	{
		fog_setFromEnt(other, t);

		if (t.spawnflags & TELEDEST_KEEPANGLE || t.style == TELEDEST_STYLE_INSTANT){
			// When a changing player's angles field on a frame with fixangle set to 1,
			// the set angles get passed to the v_angle field on the next frame.
			// That means I need to invert the X component (pitch angle), because
			// +pitch in v_angle points up, and in angles points down
			other.angles_x *= -1;

			if (t.spawnflags & TELEDEST_KEEPPITCH)
				other.angles_x = vAngleX;
			else {
				// YEAH MATH
				// Calculates the roll for the player's view angle,
				// to compensate for the destination's horizontal plane 
				// potentially being at an angle.
				// At this point angles already follow the v_angle
				// convention, so no X inversion is necessary
				makevectors(other.angles);
				other.angles_z = atan2(v_right*t_up, v_up*t_up);
			}
		}

		if (t.spawnflags & TELEDEST_KEEPANGLE_NOOFFSET)
			other.angles = other.v_angle;

		// turn this way immediately
		other.fixangle = 1;
		other.above = 1;

		// lock the player's controls for some time
		if (t.style != TELEDEST_STYLE_INSTANT) other.teleport_time = time + 0.7;

		if (other.flags & FL_ONGROUND)
			other.flags = other.flags - FL_ONGROUND;


		if (t.style != TELEDEST_STYLE_INSTANT && !(t.spawnflags & TELEDEST_KEEPANGLE)){
			if (!(t.spawnflags & TELEDEST_KEEPVELOCITY))
				other.velocity = t_forward * 300;
			else	
				other.velocity = t_forward * vlen(other.velocity);
		} 


	}
	//dprint3("After: ", vtos(other.angles),"\n");
	other.flags = other.flags - other.flags & FL_ONGROUND;
};

/*QUAKED info_teleport_destination (.5 .5 .5) (-8 -8 -8) (8 8 32)
This is the destination marker for a teleporter.  It should have a "targetname" field with the same value as a teleporter's "target" field.
*/
void() info_teleport_destination =
{
	if (!SUB_InitEntity()) return;
	
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
	if (!SUB_InitEntity()) return;
	
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
	if (!SUB_InitEntity()) return;
	
	if (!self.targetname)
		objerror ("no targetname");

	self.flags |= FL_NEVERTELEPORT;
	
	self.solid = SOLID_TRIGGER;
	setmodel(self, self.model);	// set size and link into world
	self.movetype = MOVETYPE_NONE;
	self.modelindex = 0;
	self.model = "";

	self.style = TELEDEST_STYLE_INSTANT;

	SetAngles();

	if (!self.mangle && self.angles) self.mangle = self.angles;

	// flips the stealth flag
	self.spawnflags ^= TELEDEST_STEALTH;
};
