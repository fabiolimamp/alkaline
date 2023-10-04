void() bumperThink = {
	if (self.owner.nextbumper.classname != "bumper") {
		remove(self);
		return;
	}
	float wasonground = self.flags & FL_ONGROUND;
	vector neworigin;
	
	neworigin = self.owner.origin + self.view_ofs;

	if (wasonground && self.owner.flags & FL_ONGROUND) {
		neworigin_z = self.origin_z;
	}

	setorigin(self, neworigin);

	if (wasonground) {
		self.flags = self.flags | FL_ONGROUND;
		//droptofloor();
	}

	self.nextthink = time + 0.05;
}

void(vector ofs, float fly) SUB_AddBumper = {
	entity e, last;

	e = spawn();
	e.classname = "bumper";
	e.owner = self;
	e.movetype = MOVETYPE_STEP;
	//e.solid = SOLID_BBOX;
	e.flags = self.flags & (FL_FLY | FL_SWIM | FL_SWIM2);
	if (fly) e.flags = e.flags | FL_FLY;
	e.view_ofs = ofs;
	e.think = bumperThink;
	e.nextthink = time + 0.05;

	setorigin(e, self.origin + ofs);

	last = self;

	while (last.nextbumper)
		last = last.nextbumper;

	last.nextbumper = e;
};

void() SUB_ClearBumpers = {
	entity e, eprev;

	e = self.nextbumper;

	while (e) {
		eprev = e;
		e = e.nextbumper;
		remove(eprev);
	}
	self.nextbumper = world;
}


/*
======================
StepDirection

Turns to the movement direction, and walks the current distance if
facing it.

======================
*/
float(float yaw, float dist) walkmove2 = {
	float pc;

	if (!self.nextbumper) {
		self.oldorigin = self.origin;
		float ret;

		ret = walkmove(yaw, dist);

		if (ret && self.flags & FL_SWIM2) {
			//checkSelfInWaterBrush();
			//if (self.waterlevel < 3){
			pc = pointcontents2(self.origin);
			if (pc > CONTENT_WATER){
				if (pointcontents2([self.origin_x, self.origin_y, self.oldorigin_z]) <= CONTENT_WATER) {
					setorigin(self, [self.origin_x, self.origin_y, self.oldorigin_z]);
					return TRUE;
				}
				
				setorigin(self, self.oldorigin);

				//if (pointcontents2(self.origin) > CONTENT_WATER)
				//	self.flags &~= FL_FLY;

				return FALSE;
			}

			//if (self.health) self.flags |= FL_FLY;
		}
		return ret;
		
	}


	entity oself, bp;
	float movefail;

		
	bp = self;

	while (bp) {
		bp.oldorigin = bp.origin;
		
		oself = self;
		self = bp;
		movefail = movefail | !walkmove(yaw, dist);

		if (self.flags & FL_SWIM2) {
			//checkSelfInWaterBrush();
			//if (self.waterlevel < 3)
			pc = pointcontents2(self.origin);
			if (pc > CONTENT_WATER)
				movefail = TRUE;
		}

		self = oself;
		
		bp = bp.nextbumper;
	}

	if (movefail) {
		bp = self;

		while (bp) {
			setorigin(bp, bp.oldorigin);
			bp = bp.nextbumper;
		}

		return FALSE;
	}
	return TRUE;
}

float(float yaw, float dist) StepDirection = {
	float delta;

	self.ideal_yaw = yaw;
	ChangeYaw();

	delta = self.angles_y - self.ideal_yaw;

	if (delta > 45 && delta < 315) 
		// not turned far enough, so don't take the step
		return TRUE;
		
	if (walkmove2(yaw, dist)) 
		return TRUE;
	
	return FALSE;

}


float DI_NODIR = -1;

void(entity enm, float dist) NewChaseDir = {
	float		deltax,deltay;
	vector d;
	float		tdir, olddir, turnaround;

	olddir = anglemod((self.ideal_yaw/45)*45);
	turnaround = anglemod(olddir - 180);

	deltax = enm.origin_x - self.origin_x;
	deltay = enm.origin_y - self.origin_y;

	if (deltax > 10)
		d_x = 0;
	else if (deltax < -10)
		d_x = 180;
	else
		d_x = DI_NODIR;

	if (deltay < -10)
		d_y = 270;
	else if (deltay > 10)
		d_y = 90;
	else
		d_y = DI_NODIR;

	// try direct route
	if (d_x != DI_NODIR && d_y != DI_NODIR) {
		if (d_x == 0)
			tdir = d_y == 90 ? 45 : 315;
		else
			tdir = d_y == 90 ? 135 : 215;

		if (tdir != turnaround && StepDirection(tdir, dist))
			return;
	}

	// try other directions
	if (random() < 0.333 ||  fabs(deltay) > fabs(deltax)) {
		tdir = d_x;
		d_x = d_y;
		d_y = tdir;
	}

	if (d_x != DI_NODIR && d_x != turnaround && StepDirection(d_x, dist))
		return;

	if (d_y != DI_NODIR && d_y != turnaround && StepDirection(d_y, dist))
		return;

	/* there is no direct path to the player, so pick another direction */

	if (olddir != DI_NODIR && StepDirection(olddir, dist))
		return;

	if (random() < 0.5) { /*randomly determine direction of search*/
		for (tdir = 0; tdir <= 315; tdir += 45)
			if (tdir != turnaround && StepDirection(tdir, dist)) return;
	}
	else {
		for (tdir = 315 ; tdir >= 0 ; tdir -= 45)
			if (tdir != turnaround && StepDirection(tdir, dist)) return;
	}

	if (turnaround != DI_NODIR && StepDirection(turnaround, dist) )
		return;

	self.ideal_yaw = olddir;		// can't move

	// if a bridge was pulled out from underneath a monster, it may not have
	// a valid standing position at all

	if (!checkbottom(self))
		self.flags = self.flags | FL_PARTIALGROUND;

}


float(entity goal, float dist) CloseEnough = {
	float i;

	for (i = 0; i < 3; i++)
	{
		if (goal.absmin[i] > self.absmax[i] + dist)
			return FALSE;
		if (goal.absmax[i] < self.absmin[i] - dist)
			return FALSE;
	}
	return TRUE;
}

void(float dist) movetogoal2 = {
	
	if (!self.nextbumper && !(self.flags & FL_SWIM2)) {
		movetogoal(dist);
		return;
	}

	entity		goal;

	goal = self.goalentity;

	if (!(self.flags & (FL_ONGROUND|FL_FLY|FL_SWIM)))
		return;

	// if the next step hits the enemy, return immediately
	if (self.enemy && CloseEnough(goal, dist))
		return;

	// bump around...
	if ((random() < 0.333) || !StepDirection(self.ideal_yaw, dist)) {
		NewChaseDir(goal, dist);
	}
}


//=================================================================================================


float(float launch_h, float launch_v, float yaw) movejump_test = {


	makevectors([0, yaw, 0]);

	traceline(self.origin, self.origin + v_forward*64, FALSE, self);
	if (trace_fraction < 1){
		dprint("blocked\n");
		return FALSE;
	}

	vector sim_origin = self.origin + [0, 0, self.mins_z];
	vector sim_origin_prev = sim_origin;

	float counter = 20;
	
	float v_velocity = launch_v;

	float grav = cvar("sv_gravity");
	if (self.gravity) grav *= self.gravity;
	
	sim_origin += v_forward*launch_h*0.1 + [0, 0, v_velocity]*0.1;
	traceline(sim_origin_prev, sim_origin, FALSE, self);

	entity bbl;
	
	while (counter > 0 && trace_fraction == 1) {
		sim_origin_prev	= sim_origin;

		v_velocity -= grav * 0.1;
		sim_origin += v_forward*launch_h*0.1 + [0, 0, v_velocity]*0.1;

		traceline(sim_origin_prev, sim_origin, FALSE, self);

		if (developer) {
			//particle(next, '0 0 0', 250, 9);
			bbl = spawn();
			setorigin(bbl, sim_origin);
			setmodel(bbl, "progs/s_bubble.spr");
			setsize(bbl, 0, 0);
			bbl.think = SUB_Remove;
			bbl.nextthink = time + 5;
		}

		counter--;
	}

	if (counter <= 0){
		dprint("counter max\n");
		return FALSE;
	}

	if (trace_endpos_z < (self.enemy.origin_z + self.enemy.mins_z) - 16){
		dprint("too low\n");
		return FALSE;
	}
	

	if (trace_ent.solid != SOLID_BSP){
		dprint("not bsp\n");
		return FALSE;
	}

	if (trace_plane_normal_z < 0.6) {
		dprint("too steep\n");
		return FALSE;
	}

	dprint("jump ok\n");
	return TRUE;

}

void(float dist) movetogoaljump {

	if (self.autojump <= 0 || time < self.autojump_block_finished) {
		movetogoal(dist);
		return;
	}

	entity goal;

	goal = self.goalentity;

	if (!(self.flags & FL_ONGROUND))
		return;

	// if the next step hits the enemy, return immediately
	if (self.enemy && CloseEnough(goal, dist))
		return;

	// bump around...
	float prevyaw = self.angles_y;
	float trystep = StepDirection(self.ideal_yaw, dist);

	if (!trystep && self.enemy.origin_z <= self.origin_z) {
		float launch_h, launch_v;

		launch_h = 300;
		if (fabs(self.enemy.origin_z - self.origin_z) <= 16)
			launch_v = 300;
		else
			launch_v = 200;

		if (movejump_test(launch_h, launch_v, prevyaw)) {
			self.angles_y = prevyaw;
			self.flags &~= FL_ONGROUND;
			self.velocity = v_forward*launch_h + [0, 0, launch_v];

			return;
		}
	}

	if ((random() < 0.333 || !trystep) && (self.flags & FL_ONGROUND) ) {
		NewChaseDir(goal, dist);
	}

}
