float LIQUID_WATER = 0;
float LIQUID_SLIME = 1;
float LIQUID_LAVA = 2;

void() startupWaterBrushes = {
	entity e;

	e = find(world, liquidbrush, "1");
	while (e) {
		e.solid = SOLID_NOT;
		e.movetype = MOVETYPE_NOCLIP;
		setorigin(e, e.origin);

		e = find(e, liquidbrush, "1");
	}
};


void() checkSelfInWaterBrush = {
	entity e;
	float lvl;

	e = find(world, liquidbrush, "1");

	while (e) {
		lvl = getWaterLevel(self, e);
		if (lvl) {
			self.waterlevel = lvl;

			if (e.liquidtype == LIQUID_LAVA) self.watertype = CONTENT_LAVA;
			else if (e.liquidtype == LIQUID_SLIME) self.watertype = CONTENT_SLIME;
			else self.watertype = CONTENT_WATER;

			self.flags = self.flags | FL_INWATER;

			if (self.flags & FL_CLIENT) {
				float dens;
				vector cl;

				if (self.watertype == CONTENT_SLIME) {cl = '0 25 5'; dens = 150;}
				else if (self.watertype == CONTENT_LAVA) {cl = '255 80 0'; dens = 150;}
				else {cl = '130 80 50'; dens = 128;}

				if (e.liquidcolor) cl = e.liquidcolor;
				if (e.liquiddensity) dens = e.liquiddensity;

				if (lvl >= 2) self.gravity = 0.000001;
				else self.gravity = 1;

				if (lvl >= 3){
					csf_set(self, dens, cl, 70);
				}
				else {
					csf_clear(self, 70);
				}
			}
			return;
		}
		else if (self.flags & FL_CLIENT) {
			self.gravity = 1;
			csf_clear(self, 70);
			//self.watertype = CONTENT_EMPTY;
			//self.waterlevel = 0;
		}

		e = find(e, liquidbrush, "1");
	}
}

float(vector org) pointcontents2 = {
	float pc = pointcontents(org);

	if (pc != CONTENT_EMPTY) return pc;

	entity e;
	float touched;

	e = find(world, liquidbrush, "1");

	while (e) {
		touched = getWaterTouch(org, e);
		if (touched) {
			if (e.liquidtype == LIQUID_LAVA) return CONTENT_LAVA;
			else if (e.liquidtype == LIQUID_SLIME) return CONTENT_SLIME;
			else return CONTENT_WATER;
		}

		e = find(e, liquidbrush, "1");
	}
	return CONTENT_EMPTY;
}


float (entity e, entity brush) getWaterLevel = {
	// horizontal axes checked against entity's origin
	// vertical axis checked against entity's bottom limit and view_ofs 
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

float (vector org, entity brush) getWaterTouch = {
	if (org_x > brush.absmax_x) 
		return 0;
	if (org_x < brush.absmin_x)
		return 0;
	if (org_y > brush.absmax_y)
		return 0;
	if (org_y < brush.absmin_y)
		return 0;
	if (org_z > brush.absmax_z)
		return 0;
	if (org_z < brush.absmin_z)
		return 0;

	return 1;
}