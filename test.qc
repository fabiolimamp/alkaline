
void() water_touch = {
	
}

void() trigger_water = {
	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_NONE;
	setmodel (self, self.model);	// set size and link into world
	setorigin(self, self.origin);
	//self.touch = water_touch;
}

void() checkWaterBrush = {
	entity e, pl;
	e = find(world, classname, "trigger_water");
	while (e) {
		pl = find(world, classname, "player");
		while (pl) {
			if (getWaterLevel(e, pl)) {
				//dprint("touched endframe\n");
				pl.waterlevel = 3;
				pl.watertype = CONTENT_WATER;
				pl.flags = pl.flags | FL_INWATER;
				pl.gravity = 0.000001;
				return;
			}
			else {
				pl.gravity = 1;
				//pl.watertype = CONTENT_EMPTY;
				//pl.waterlevel = 0;
			}

			pl = find(pl, classname, "player");
		}

		e = find(e, classname, "trigger_water");
	}
}

void() checkSelfInWaterBrush = {
	entity e;
	e = find(world, classname, "trigger_water");
	while (e) {

		if (getWaterLevel(self, e)) {
			//dprint("touched self\n");
			self.waterlevel = 3;
			self.watertype = CONTENT_WATER;
			self.flags = self.flags | FL_INWATER;
			self.gravity = 0.000001;
			return;
		}
		else {
			self.gravity = 1;
			//self.watertype = CONTENT_EMPTY;
			//self.waterlevel = 0;
		}

		e = find(e, classname, "trigger_water");
	}
}


float (entity e, entity brush) getWaterLevel =
{
	if (e.absmin_x > brush.absmax_x) {
		return FALSE;
	}
	if (e.absmin_y > brush.absmax_y){
		return FALSE;
	}
	if (e.absmin_z > brush.absmax_z){
		return FALSE;
	}
	if (e.absmax_x < brush.absmin_x){
		return FALSE;
	}
	if (e.absmax_y < brush.absmin_y){
		return FALSE;
	}
	if (e.absmax_z < brush.absmin_z){
		return FALSE;
	}

	return TRUE;
};