/*
=============================================================

trigger_jumppad

Loosely based on Devil's code by ZungryWare, from modjam2

=============================================================
*/
vector JUMPPAD_SIM_COMPENSATE = '0 0 32';
float JUMPPAD_SIM_STEP = 0.08;

float JUMPPAD_SILENT = 4;
float JUMPPAD_DONTIGNOREMOVERS = 8;
float JUMPPAD_DONTHOLDPLAYER = 16;
float JUMPPAD_FIXEDPUSH = 32;

void() trigger_jumppad = {
	if (!SUB_InitEntity()) return;
	
	InitTrigger();

	self.touch = JumpPadTouch;

	if (self.noise == "") self.noise = "misc/jumppad.wav";

	if (self.spawnflags & 4) self.noise = "";
	if (self.noise != "") precache_sound(self.noise);

	if (!self.delay) self.delay = 1;

	self.wait = zeroconvertdefault(0.2, self.wait);

	if (self.spawnflags & JUMPPAD_FIXEDPUSH) {
		self.think = JumpPadCalculateFixedJump;
		self.nextthink = time + 0.5;
	}

	SUB_CheckWaiting();
}

void() JumpPadCalculateFixedJump = {
	entity origin_tgt;
	
	entity e = spawn();
	e.classname = "jumppadtester";
	e.solid = SOLID_TRIGGER;
	e.movetype = MOVETYPE_TOSS;
	setsize(e, VEC_HULL_MIN, VEC_HULL_MAX);

	if (self.target2 != "") origin_tgt = find(world, targetname, self.target2);

	if (origin_tgt){
		setorigin(e, origin_tgt.origin);
		dprint("found origin\n");
	}
	else {
		vector org = (self.absmin + self.absmax)/2;
		org_z += self.size_z;

		setorigin(e, org);
		entity oself = self;
		self = e;
		droptofloor();
		self = oself;
	}
	
	entity tgt = find(world, targetname, self.target);
	if (!JumpPadLaunch(e, tgt.origin)) self.state = 1;

	self.movedir = e.velocity;
	self.invincible_time = e.pushfinished - time;
	remove(e);
}


void() JumpPadTouch = {
	if (self.estate != STATE_ACTIVE)
		return;

	if (other.movetype != MOVETYPE_TOSS &&
		other.movetype != MOVETYPE_BOUNCE && 
		other.movetype != MOVETYPE_BOUNCEMISSILE &&
		other.movetype != MOVETYPE_WALK &&
		other.movetype != MOVETYPE_STEP
	)
		return;

	// no players
	if (other.movetype == MOVETYPE_WALK && self.spawnflags & 1)
		return;

	// no monsters
	if (other.movetype == MOVETYPE_STEP && self.spawnflags & 2)
		return;
	
	if (time < self.attack_finished) return;

	if (self.spawnflags & JUMPPAD_FIXEDPUSH){
		if (!JumpPadLaunchFixed(other)){
			dprint("Warning: no valid throw\n");
			return;
		}
	}
	else {
		entity tgt = find(world, targetname, self.target);

		if (!tgt){
			dprint("trigger_jummpad: no target\n");
			return;
		}
		JumpPadLaunch(other, tgt.origin);
	}

	dprint3("Push velocity: ", vtos(other.velocity), "\n");

	if (self.noise != "") {
		if (other.flags & FL_CLIENT && other.health > 0 && other.fly_sound < time) {
			other.fly_sound = time + self.delay;
			sound(other, CHAN_AUTO, self.noise, 1, ATTN_NORM);
		}
	}
	self.attack_finished = time + self.wait;
}

float(entity e) JumpPadLaunchFixed = {
	if (self.state == 1)
		return FALSE;

	e.velocity = self.movedir;
	e.flags &~= FL_ONGROUND;

	if (e.flags & FL_CLIENT && e.health > 0 && !(self.spawnflags & JUMPPAD_DONTHOLDPLAYER)) {
		e.pushvelocity = self.movedir;
		e.oldvelocity = self.movedir;
		e.pushfinished = time + self.invincible_time;
	}
	return TRUE;
};

float(entity e, vector target_spot) JumpPadLaunch = {
	vector throw_spot = e.origin;
	
	entity goal = spawn();
	goal.solid = SOLID_BBOX;
	goal.nextthink = time + 1;
	goal.think = SUB_Remove;

	setorigin(goal, target_spot);
	setsize(goal, '-16 -16 -16', '16 16 16');

	self.enemy = e;
	self.goalentity = goal;

	float v_vertical = JumpPadSimulateThrow();
	
	self.goalentity = world;
	remove(goal);
	
	// If there's no valid throw, exit
	if (v_vertical == -1) {
		dprint("No valid throw\n");
		self.enemy = world;
		return FALSE;
	}
	
	v_vertical += self.height + 64;
	// Calculate horizontal velocity
	float v_horizontal = JumpPadCalculateHorizontal(throw_spot, target_spot, v_vertical);
	
	e.flags &~= FL_ONGROUND;
	e.velocity = JumpPadConvertVelocity(throw_spot, target_spot, v_vertical, v_horizontal);

	if ((e.flags & FL_CLIENT && e.health > 0 && !(self.spawnflags & JUMPPAD_DONTHOLDPLAYER)) || e.classname == "jumppadtester") {
		e.pushvelocity = e.velocity;
		e.oldvelocity = e.velocity;
		e.pushfinished = time + vlen([throw_spot_x, throw_spot_y, 0] - [target_spot_x, target_spot_y, 0])/v_horizontal;
	}


	self.enemy = world;

	return TRUE;
};

// called from PlayerPreThink
void() ClientPush = {

	float verticalFactor = clamp(self.velocity_z, 0, 600);
	float horizontalFactor = min(vlen([self.velocity_x, self.velocity_y, 0]), 600);

	float pushFactor = vlen(self.pushvelocity);
	float steer = 1 - (0.5 + min((verticalFactor + horizontalFactor), 600)/600*0.5);

	//dprint3("----------\nSteer: ", ftos(steer*1000), "\n");
	//dprint5("Vertical factor: ", ftos(verticalFactor), ", Horizontal factor: ", ftos(horizontalFactor), "\n");
	//dprint7("pushvel: ", vtos(self.pushvelocity), ", oldvel: ", vtos(self.oldvelocity), ", vel: ", vtos(self.velocity), "\n");

	self.velocity_x = (self.velocity_x*steer + self.oldvelocity_x*(1-steer));
	self.velocity_y = (self.velocity_y*steer + self.oldvelocity_y*(1-steer));

}


// Calculates the vertical velocity based on height difference
float(vector throw_spot, vector target_spot) JumpPadCalculateVertical {
	local float dv;
	
	float grav = cvar("sv_gravity");
	//if (self.enemy.gravity) grav *= self.enemy.gravity;
	
	dv = throw_spot_z - target_spot_z;
	return 400 - (1.6*dv);
}

// Calculates horizontal velocity based on vertical velocity
float(vector throw_spot, vector target_spot, float v_vertical) JumpPadCalculateHorizontal {
	local vector delta;
	local float dh;
	local float dv;
	
	makevectors (self.angles);
	float grav = cvar("sv_gravity");
	if (self.enemy && self.enemy.gravity) grav *= self.enemy.gravity;
	dv = throw_spot_z - target_spot_z;
	delta = target_spot - throw_spot;
	delta_z = 0;
	
	dh = vlen(delta);
	return dh/((v_vertical + sqrt((v_vertical*v_vertical) + (2*dv*grav)))/grav);
}

// Converts from horizontal and vertical velocity into an actual vector
vector(vector throw_spot, vector target_spot, float v_vertical, float v_horizontal) JumpPadConvertVelocity {
	local vector delta;
	local vector result;
	
	delta = target_spot - throw_spot;
	delta_z = 0;
	delta = normalize(delta);
	
	result = v_horizontal * delta;
	result_z = v_vertical;
	return result;
}



// Simulates a throw for the entity to make sure it won't hit geo or some other blocker
// Returns the resulting vertical velocity on target hit
// Returns -1 on target miss
float(float v_extra) JumpPadSimulateRun = {
	//dprint3("---------------\n---------------\nSimulating run: ", ftos(v_extra), "\n");

	
	// Determine where the throw source and destination
	// JUMPPAD_SIM_COMPENSATE Helps throw clear tall walls
	// The sim may clip corners, so this makes the sim test a bit lower
	vector throw_spot = self.enemy.origin + [0, 0, self.enemy.mins_z];// - JUMPPAD_SIM_COMPENSATE;
	vector target_spot = self.goalentity.origin - JUMPPAD_SIM_COMPENSATE;
	
	// Get world gravity value
	float grav = cvar("sv_gravity");
	//if (self.enemy.gravity) grav *= self.enemy.gravity;

	// Calculate the velocity we're testing here
	float v_vertical = v_extra + JumpPadCalculateVertical(throw_spot, target_spot);
	float v_horizontal = JumpPadCalculateHorizontal(throw_spot, target_spot, v_vertical);
	
	// Calculate starting velocity vector
	vector sim_velocity = JumpPadConvertVelocity(throw_spot, target_spot, v_vertical, v_horizontal);
	
	// Make sure the vertical velocity didn't end up negative
	if (sim_velocity_z <= 10) {
		//dprint("Vertical velocity not enough\n");
		return -1;
	}
	
	// This guy can only throw so far
	if (vlen(sim_velocity) > 1500) {
		//dprint("Target too far\n");
		return -1;
	}
	
	// Step through the simulation
	vector cur = throw_spot;
	float counter = 30;
	vector next;
	float checked_ceiling;
	entity bbl;
	float passthru;

	float dont_ignore_movers = !!(self.spawnflags & JUMPPAD_DONTIGNOREMOVERS);
	while (counter > 0) {
		// Step
		next = cur + (sim_velocity * JUMPPAD_SIM_STEP);
		
		// Debug
		if (developer) {
			//particle(next, '0 0 0', 250, 9);
			bbl = spawn();
			setorigin(bbl, next);
			setmodel(bbl, "progs/s_bubble.spr");
			setsize(bbl, 0, 0);
			bbl.think = SUB_Remove;
			bbl.nextthink = time + 5;
		}
		
		// Do the trace
		//dprint3("---------------\nStep ", ftos(counter), "\n");
		//dprint3("Trace length: ", ftos(vlen(cur - next)), "\n");
		//dprint3("Ent to ignore: ", self.enemy.classname, "\n");
		traceline (cur, next, FALSE, self.enemy);
		
		//dprint3("All solid: ", ftos(trace_allsolid), "\n");
		//dprint3("Start solid: ", ftos(trace_startsolid), "\n");
		//dprint3("Trace fraction: ", ftos(trace_fraction*1000), "\n");
		//dprint3("Trace ent: ", trace_ent.classname, "\n");

		//if (trace_fraction < 1 || trace_startsolid) dprint3("Hit entity: ", trace_ent.classname, "\n");

		
	
		passthru = 0;
		while ((trace_fraction < 1 || trace_startsolid) && trace_ent != self.goalentity && trace_ent != world && passthru < 10
			&& ((trace_ent.solid != SOLID_BSP && dont_ignore_movers) || !dont_ignore_movers)
		){
			//dprint("Retracing\n");

			//dprint3("Ent to ignore: ", trace_ent.classname, "\n");
			//dprint3("Trace length: ", ftos(vlen(trace_endpos - normalize(next - trace_endpos) - next)), "\n");

			//traceline (trace_endpos - normalize(next - trace_endpos), next, FALSE, trace_ent);
			traceline (trace_endpos - normalize(next - trace_endpos), next, FALSE, trace_ent);

			//dprint3("All solid: ", ftos(trace_allsolid), "\n");
			//dprint3("Start solid: ", ftos(trace_startsolid), "\n");
			//dprint3("Trace fraction: ", ftos(trace_fraction*1000), "\n");
			//dprint3("Trace ent: ", trace_ent.classname, "\n");
			//bbl.frame = 1;
			//if (trace_fraction < 1 || trace_startsolid) dprint3("Retrace hit entity: ", trace_ent.classname, "\n");

			passthru++; // sanity check to not get to infinite loops
		}

		// Check if it hit the target

		if (trace_ent == self.goalentity) {
			//dprint("Found target\n");
			return v_vertical;
		}
		
		//Check for collision with something else
		if ((trace_fraction < 1 || trace_startsolid) && trace_ent != self.goalentity) {
			//dprint("Collided with something\n");
			return -1;
		}
		
		// At the apex of the throw, also check up a little bit
		// Prevents slamming into ceilings
		if (!checked_ceiling && sim_velocity_z < 200) {
			checked_ceiling = TRUE;
			traceline (cur, cur + (JUMPPAD_SIM_COMPENSATE * 1.5), FALSE, self.enemy);
			if (trace_fraction < 1 && trace_ent != self.goalentity) {
				//dprint("Bumped into ceiling\n");
				return -1;
			}
		}
		
		// Acceleration due to gravity
		sim_velocity_z -= grav * JUMPPAD_SIM_STEP;
		
		// Increment
		cur = next;
		counter = counter - 1;
	}
	//dprint("Didn't hit anything\n");
	// Didn't hit anything
	return v_vertical;
}

// Figures out what angle (if any) the entity will pushed towards
// Returns the resulting vertical velocity of the successful throw on target hit
// Returns -1 if it did not find any angle with a target hit
float() JumpPadSimulateThrow = {
	float sim_result;
	float angles_try[12] = {-192, -128, -64, 0, 64, 128, 192, 256, 384, 512, 768, 1024};
	for (float i = 0; i < 10; i ++) {
		sim_result = JumpPadSimulateRun(angles_try[i]);
		
		if (sim_result != -1) {
			dprint5("Got velocity adjust ", ftos(angles_try[i]), ", result ", ftos(sim_result), "\n");
			return sim_result;
		}
	}
	
	return -1;
}

