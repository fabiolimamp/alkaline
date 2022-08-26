/* Bullet holes QuickC program
	By Jim Dose'  11/20/96
	Copyright (c)1996 Hipnotic Interactive, Inc.
	All rights reserved.
	Distributed (unsupported) on 3.12.97

	Modified by bmFbr
*/

// maximum bulletholes on the map
float BULLETHOLES_MAX = 50;
// maximum bulletholes spawned per frame
float BULLETHOLES_MAXFRAME = 10;

float BULLETHOLES_LIFETIME = 60;


void() InitBulletHoles = {
	precache_model("progs/s_bullet_new.spr");

	bulletholes = world;
	lastbullet = world;
	numbulletholes = 0;

	if (cvar("saved1") & ALKSETTINGS_NOBULLETHOLES) bulletmode = 0;
	else bulletmode = 1;
};

void() remove_bullethole = {
	local entity e;

	e = self;
	
	if (e.classname != "bullethole") {
		dprint("bulletholes: Tried to remove non-bullethole\n");
		return;
	}

	if (e == bulletholes) { // first in list
		bulletholes = e.lastvictim;

		if (e.lastvictim ) // there's a next one
			e.lastvictim.prevvictim = world; 
		else // there's no next one
			lastbullet = world;
	}
	else if (e == lastbullet) { // last in list (if this condition is reached then we're sure there's at least one before it)
		if (e.prevvictim) // checks just to be sure if prevvictim isn't world, but it should never happen
			e.prevvictim.lastvictim = world; 
		lastbullet = e.prevvictim;
	}
	else { // somewhere between
		e.prevvictim.lastvictim = e.lastvictim;
		e.lastvictim.prevvictim = e.prevvictim;
	}

	remove(e);
	numbulletholes = numbulletholes - 1;
};

void() show_bulletholes = {
	entity e;
	e = bulletholes;
	while (e) {
		setmodel(e, "progs/s_bullet_new.spr");
		e.frame = floor(random()*6.99);
		setsize (e, '0 0 0', '0 0 0');
		e = e.lastvictim;
	}
};

void() hide_bulletholes = {
	entity e;
	e = bulletholes;
	while (e) {
		setmodel(e, "");
		setsize (e, '0 0 0', '0 0 0');
		e = e.lastvictim;
	}
};

void() update_bulletholes = {
	numbulletsframe = 0;
	entity e, next;
	e = bulletholes;
	while (e) {
		// hole is in a valid non-world solid entity
		if (e.owner && e.owner.solid == SOLID_BSP) {
			// check if the entity moved
			if (e.owner.absmin != e.oldorigin) {
				setorigin(e, e.origin - e.oldorigin + e.owner.absmin);
				e.oldorigin = e.owner.absmin;
			}

			e = e.lastvictim;
		}
		// hole was originally in a non-world entity, but it was removed or changed to non-solid
		else if (e.state) { 
			next = e.lastvictim;
			SUB_CallAsSelf(remove_bullethole, e);
			e = next;
		}
		// hole is in a world face, do nothing
		else {
			e = e.lastvictim;
		}
	}
};

void(vector pos, vector norm, entity tgt) placebullethole = {
	
	if (tgt.solid != SOLID_BSP)
		return;

	if (numbulletsframe > BULLETHOLES_MAXFRAME)
		return;

	if (!bulletmode)
		return;

	if (tgt.nobullets)
		return;

	local entity new;

	new = spawn();
	new.movetype = MOVETYPE_NONE;
	new.solid = SOLID_NOT;
	new.classname = "bullethole";

	
	setmodel(new, "progs/s_bullet_new.spr");
	new.frame = floor(random()*6.99);
	setsize (new, '0 0 0', '0 0 0');
	

	new.owner = tgt; // entity whose this bullethole is attached to, world or otherwise
	new.oldorigin = tgt.absmin;
	// set state 1 to holes attached to non-world entities (for movement and validity checks)
	if (tgt != world) new.state = 1;

	norm_x = 0 - norm_x;
	norm_y = 0 - norm_y;

	new.angles = vectoangles(norm);
	new.angles_z = floor(random()*3.99) * 90;
	makevectors(self.angles);
	setorigin(new, pos - (v_forward * (0.2 + random()*0.1)));

	new.think = remove_bullethole;
	new.nextthink = time + BULLETHOLES_LIFETIME;

	if (numbulletholes > BULLETHOLES_MAX) {
		SUB_CallAsSelf(remove_bullethole, bulletholes);
	}

	numbulletholes++;
	numbulletsframe++;

	if (lastbullet) {
		lastbullet.lastvictim = new;
		new.prevvictim = lastbullet;
	}
	else {
		bulletholes = new;
	}
	new.lastvictim = world;
	lastbullet = new;
};
