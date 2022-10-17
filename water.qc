float LIQUID_WATER = 0;
float LIQUID_SLIME = 1;
float LIQUID_LAVA = 2;

float touchedliquidbrush;

void() startupWaterBrushes = {
	entity e, prev;

	e = find(world, liquidbrush, "1");
	if (e) liquidbrushfirst = e;
	while (e) {
		e.solid = SOLID_NOT;
		e.movetype = MOVETYPE_NOCLIP;
		setorigin(e, e.origin);

		prev = e;
		e = find(e, liquidbrush, "1");
		if (e) {
			prev.nextliquidbrush = e;
			e.prevliquidbrush = prev;
		}

	}
};

void() entity_watercheck = {
	//if (!(self.flags & FL_MONSTER) || self.health <= 0) 
	if (self.movetype == MOVETYPE_NOCLIP ||
		self.movetype == MOVETYPE_PUSH ||
		self.movetype == MOVETYPE_NONE ||
		self.movetype == MOVETYPE_WALK // clients are handled in pre/postthink
	)
		return;

	float ct = pointcontents2(self.origin);

	if (ct <= CONTENT_WATER){
		if (self.flags & FL_SWIM2 && self.health > 0) self.flags |= FL_FLY;

		/*if (!(self.flags & FL_INWATER) && touchedliquidbrush){
			sound (self, CHAN_AUTO, "misc/h2ohit1.wav", 1, ATTN_NORM);
		}*/
		
		if ((self.flags & FL_MONSTER && self.health <= 0) || self.classname == "gib") {
			if (!self.prevgravity) self.prevgravity = self.gravity;
			if (!self.gravity) self.gravity = 1;
			if (self.gravity > 0.05) {
				self.velocity *= 0.05/self.gravity; // reduces velocity when hitting water
			}
			self.gravity = 0.05;
			//if (self.classname == "monster_wizard") {eprint(self);}
		}

		self.flags |= FL_INWATER;

		self.waterlevel = 1;

		// Setting watertype here for standard liquid volumes
		// conflicts with the engine content check later on the same frame,
		// causing a spam of splash sounds
		if (!touchedliquidbrush)
			self.watertype = ct;
	}
	else {
		if (self.flags & FL_SWIM2) self.flags &~= FL_FLY;

		if (self.flags & (FL_INWATER | FL_INLIQUIDBRUSH) == FL_INWATER | FL_INLIQUIDBRUSH){
			sound (self, CHAN_AUTO, "misc/h2ohit1.wav", 1, ATTN_NORM);
		}

		if (self.flags & FL_MONSTER && self.health <= 0) {
			if (self.flags & FL_INWATER) {
				self.gravity = self.prevgravity;
				self.prevgravity = 0;
			}
		}

		self.flags &~= FL_INWATER;

		// same logic as the engine code. It's weird but that's how it is
		self.waterlevel = ct;

		self.watertype = CONTENT_EMPTY;
	}

	if (touchedliquidbrush) self.flags |= FL_INLIQUIDBRUSH;
	else self.flags &~= FL_INLIQUIDBRUSH;
	
}

void() checkClientInWaterBrush = {
	entity e;
	float lvl;
	float prevlvl = self.waterlevel;
	
	e = liquidbrushfirst;

	while (e) {
		lvl = getWaterLevelFromBrush(self, e);
		if (lvl) {
			if (self.movetype != MOVETYPE_NOCLIP) {
				self.waterlevel = lvl;

				if (e.liquidtype == LIQUID_LAVA) self.watertype = CONTENT_LAVA;
				else if (e.liquidtype == LIQUID_SLIME) self.watertype = CONTENT_SLIME;
				else self.watertype = CONTENT_WATER;
			}
			//self.flags |= FL_INWATER;

			float dens;
			vector cl;

			if !(self.flags & FL_INLIQUIDBRUSH)
				self.prevgravity = self.gravity;

			if (e.liquidtype == LIQUID_SLIME) {cl = '0 25 5'; dens = 150;}
			else if (e.liquidtype == LIQUID_LAVA) {cl = '255 80 0'; dens = 150;}
			else {cl = '130 80 50'; dens = 128;}

			if (e.liquidcolor) cl = e.liquidcolor;
			if (e.liquiddensity) dens = e.liquiddensity;

			if (lvl >= 2) self.gravity = 0.000001;
			else self.gravity = self.prevgravity;

			if (lvl >= 3){
				csf_set(self, dens, cl, 70);
			}
			else {
				csf_clear(self, 70);
			}

			self.flags |= FL_INLIQUIDBRUSH;

			return;
		}

		e = e.nextliquidbrush;
	}

	// if the code came up to here, it means no liquid brush was touched in this frame,
	// so turn off everything if the entity was in one at the previous frame
	if (self.flags & FL_INLIQUIDBRUSH) {
		csf_clear(self, 70);
		self.gravity = self.prevgravity;
		//self.watertype = CONTENT_EMPTY;
		//self.waterlevel = 0;

		self.flags &~= FL_INLIQUIDBRUSH;
	}
}

float(vector org) pointcontents2 = {
	touchedliquidbrush = FALSE;

	float pc = pointcontents(org);

	if (pc != CONTENT_EMPTY) return pc;

	entity e;
	float touched;

	e = liquidbrushfirst;
	while (e) {
		touched = getTouch(org, e);
		if (touched) {
			touchedliquidbrush = TRUE;

			if (e.liquidtype == LIQUID_LAVA) return CONTENT_LAVA;
			else if (e.liquidtype == LIQUID_SLIME) return CONTENT_SLIME;
			else return CONTENT_WATER;
		}

		e = e.nextliquidbrush;
	}
	return CONTENT_EMPTY;
}

// tests an entity against a water brush
float (entity e, entity brush) getWaterLevelFromBrush = {
	// same method as the engine's internal function:
	// - horizontal axes checked against entity's origin
	// - vertical axis checked against entity's bottom limit and view_ofs 
	if (e.origin_x > brush.absmax_x) 
		return 0;
	if (e.origin_x < brush.absmin_x)
		return 0;
	if (e.origin_y > brush.absmax_y)
		return 0;
	if (e.origin_y < brush.absmin_y)
		return 0;
	if (e.absmin_z > brush.absmax_z)
		return 0;
	if (e.absmax_z - e.view_ofs_z < brush.absmin_z)
		return 0;
	
	
	float lvl;
	float depth = brush.absmax_z - e.absmin_z;

	if (depth > (e.view_ofs_z - e.mins_z))
		lvl = 3;
	else if (depth > (e.absmax_z - e.absmin_z)/2) {
		lvl = 2;
	}
	else lvl = 1;
	//dprint3("Applied waterlevel: ", ftos(lvl), "\n");
	return lvl;
};

// tests a point coordinate against an entity bbox
float (vector org, entity e) getTouch = {
	if (org_x > e.absmax_x) 
		return 0;
	if (org_x < e.absmin_x)
		return 0;
	if (org_y > e.absmax_y)
		return 0;
	if (org_y < e.absmin_y)
		return 0;
	if (org_z > e.absmax_z)
		return 0;
	if (org_z < e.absmin_z)
		return 0;

	return 1;
}