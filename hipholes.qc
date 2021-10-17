/* Bullet holes QuickC program
	By Jim Dose'  11/20/96
	Copyright (c)1996 Hipnotic Interactive, Inc.
	All rights reserved.
	Distributed (unsupported) on 3.12.97
*/

/*QUAKED wallsprite (0 1 0) (-8 -8 -8) (8 8 8)
Places a sprite on a wall.  Angles should be opposite of face.

"model" sprite to place on wall.  Default is "progs/s_blood1.spr".
*/
void() wallsprite = {
	if (!self.model) {
		self.model = "progs/s_blood1.spr";
	}

	precache_model(self.model);
	setmodel(self, self.model);

	// QuakeEd doesn't save up and down angles properly.
	if (self.angles == '0 -1 0')
		self.angles = '-90 0 0';
	else if (self.angles == '0 -2 0')
		self.angles = '90 0 0';

	// Pull the sprite away from the wall slightly to
	// get rid of z sort errors.
	makevectors(self.angles);
	setorigin( self, self.origin - ( v_forward * 0.2 ) );
	makestatic (self);
};

void() InitBulletHoles = {
	precache_model("progs/s_bullet.spr");

	bulletholes = world;
	lastbullet = world;
	numbulletholes = 0;
};

void() remove_bullethole = {
	local entity ent;

	// There is a possibility that this is not the first bullet
	// in the list, but it doesn't really matter.  All that
	// matters is there is one less bullet.  Just make sure
	// we don't remove the world!
	if (bulletholes == nullentity) {
		objerror("remove_bullethole: bulletholes == nullentity! " );
	}

	ent = bulletholes;
	if (ent.classname != "bullethole") {
		objerror("remove_bullethole: Tried to remove non-bullethole!" );
	}

	bulletholes = bulletholes.lastvictim;
	remove(ent);

	if (lastbullet == ent) {
		lastbullet = nullentity;
	}
	numbulletholes = numbulletholes - 1;
};

void() update_bulletholes = {
	numbulletsframe = 0;
	entity e, prev, next;
	e = bulletholes;
	while (e) {
		// hole is in a valid non-world brush, so check if the brush moved
		if (e.owner && e.owner.solid == SOLID_BSP) {
			if (e.owner.absmin != e.oldorigin) {
				setorigin(e, e.origin - e.oldorigin + e.owner.absmin);
				e.oldorigin = e.owner.absmin;
			}
			
			prev = e;
			e = e.lastvictim;
		}
		// hole was originally in a non-world brush, but brush was removed or changed to non-solid
		else if (e.state) { 
			if (e == bulletholes) { // first in list
				bulletholes = e.lastvictim;
			}
			else {
				prev.lastvictim = e.lastvictim;
			}

			if (e == lastbullet) lastbullet = world;
			next = e.lastvictim;
			remove(e);
			numbulletholes = numbulletholes - 1;
			e = next;

		}
		// hole is in a world brush, do nothing
		else {
			prev = e;
			e = e.lastvictim;
		}
	}
};

void(vector pos, vector norm, entity tgt) placebullethole = {
	
	if (tgt.solid != SOLID_BSP)
		return;

	if (numbulletsframe > 10)
		return;

	local entity new;

	new = spawn();
	new.movetype = MOVETYPE_NONE;
	new.solid = SOLID_NOT;
	new.classname = "bullethole";
	setmodel( new, "progs/s_bullet.spr" );
	setsize (new, '0 0 0', '0 0 0');

	new.owner = tgt;
	new.oldorigin = tgt.absmin;
	if (tgt != world) new.state = 1;

	norm_x = 0 - norm_x;
	norm_y = 0 - norm_y;
	new.angles = vectoangles(norm);
	makevectors(self.angles);
	setorigin(new, pos - (v_forward * 0.2));

	new.think = remove_bullethole;
	new.nextthink = time + 300;

	numbulletholes++;
	numbulletsframe++;

	if ( numbulletholes > 40 ){
		remove_bullethole();
	}

	if (lastbullet) {
		lastbullet.lastvictim = new;
	}
	else {
		bulletholes = new;
	}
	new.lastvictim = world;
	lastbullet = new;
};
