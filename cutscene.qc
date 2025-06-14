
void() target_camera = {
	if (!SUB_InitEntity()) return;
	

	if (!self.speed)
		self.speed = 100;
	if (!self.target)
		objerror ("func_train without a target");
	if (!self.dmg)
		self.dmg = 2;

	if(self.spawnflags & CAMERA_STOPONTRIGGER && self.spawnflags & CAMERA_MOVEONTRIGGER)
		objerror("func_train: Stop and move on trigger set at the same time");



	self.cnt = CAMERA_NEXT_WAIT;
	
	
	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_NONE;
	setsize (self, '-16 -16 -16' , '16 16 16');

	self.use = camera_use;
	

	self.speed2 = self.speed;
}

void() camera_use = {
	if (!(activator.flags & FL_CLIENT))
		return;

	camera_go(self, activator, -1);

};


void(entity camera, entity cl, float spd) camera_go = {
	if (cl.rotatecontroller.classname != "rotatecontroller") {
		entity rot = spawn();
		cl.rotatecontroller = rot;
		rot.classname = "rotatecontroller";
		rot.owner = cl;
	}

	

	vector destang = vectoangles(cl.origin - camera.origin);
	if (self.spawnflags & CAMERA_ROTATEY) {
		destang_x = self.angles_x;
		destang_z = self.angles_z;
	}

	if (camera.multiplier > 0) SUB_CalcAngleMoveController_ent(cl, destang, camera.speed2*camera.multiplier, SUB_Null, cl.rotatecontroller);
	else cl.angles = destang;
}


//=====================================================================================================================






float CAMERA_RETRIGGER = 1;
float CAMERA_MOVEONTRIGGER = 2; 
float CAMERA_STOPONTRIGGER = 4;
float CAMERA_NONSOLID = 8;
float CAMERA_NOROTATE = 16;
float CAMERA_ROTATEY = 32;

float CAMERA_NEXT_WAIT = 0; //normal movement
float CAMERA_NEXT_STOP = 1; // force a stop on the next path_corner
float CAMERA_NEXT_CONTINUE = 2; // force continue on the next path_corner (ignores wait time)

float CAMERA_STYLE_SINGLEANIM = 1;

float CAMERA_ANIMTYPE_FORWARD = 1;
float CAMERA_ANIMTYPE_BACKFORTH = 2;


/*
// Use function for when the train is stopped.
// Makes the train continue on path_corners with wait -1,
// or forces a continue if the "move on trigger" spawnflag is set.
void() camera_use = {

	if (self.spawnflags & CAMERA_MOVEONTRIGGER || self.wait < 0) {
		camera_next();
		return;
	}
	
	// Train has already moved after startup, and has no "stop on trigger" flag,
	// so ignore activation.
	if (self.think != func_train_find && self.cnt != CAMERA_NEXT_STOP)
		return;

	camera_next();
};
*/x
// Use function for when the train is moving.
// Forces a stop or an instant continue on the next path_corner depending on the spawnflag set
void() camera_moving_use = {
	if (self.spawnflags & CAMERA_MOVEONTRIGGER || self.wait < 0)
		self.cnt = CAMERA_NEXT_CONTINUE;
	else if (self.spawnflags & CAMERA_STOPONTRIGGER)
		self.cnt = CAMERA_NEXT_STOP;
}

// path_corner has been reached, so decide what to do next
void() camera_wait = {

	self.use = camera_use; //ready to be re-triggered

	// from Copper
	// Trains now fire their path_corners' targets on arrival.
	// If a player is riding the train, treat them as activator.
	activator = nextent(world);
	while (!SolidsTouching(self,activator) && activator.classname == "player")
		activator = nextent(activator);
	if (activator.classname != "player")
		activator = nextent(world);	// default to player1 wherever they are
	SUB_UseEntTargets(self.enemy);

	if (self.enemy.speed) self.speed2 = self.enemy.speed; // sets the speed from the current path_corner

	// copies the modeltrain animation parameters set in the path_corner, if any
	if (self.classname == "misc_modeltrain") {
		if (self.enemy.first_frame) self.first_frame = self.enemy.first_frame;
		if (self.enemy.last_frame) self.last_frame = self.enemy.last_frame;
		if (self.enemy.first_frame2) self.first_frame2 = self.enemy.first_frame2;
		if (self.enemy.last_frame2) self.last_frame2 = self.enemy.last_frame2;
		if (self.enemy.frtime) self.frtime = self.enemy.frtime;
		if (self.enemy.frtime2) self.frtime2 = self.enemy.frtime2;
		if (self.enemy.animtype) self.animtype = self.enemy.animtype;
		if (self.enemy.animtype2) self.animtype2 = self.enemy.animtype2;
		if (self.enemy.multiplier) self.multiplier = self.enemy.multiplier;
	}

	self.think = camera_next;

	// train is moving normally and path_corner has a wait set, so pause for that time.
	if (self.wait > 0 && self.cnt == CAMERA_NEXT_WAIT) {
		// state: stopped
		self.state = 0;
		if (self.classname == "misc_modeltrain") SUB_CallAsSelf(self.animcontroller.think, self.animcontroller);
		self.nextthink = getLocalTime() + self.wait;


	}
	// train is moving normally and path_corner has no wait time,
	// or has been forced to move instantly through a triggering.
	else if (self.cnt != CAMERA_NEXT_STOP && !self.wait) {


		
		self.nextthink = -1; // move instantly
		camera_next();
	}
	// path_corner has wait -1, or train has been forced to stop through a triggering.
	else {


		// state: stopped
		self.state = 0;

		if (self.classname == "misc_modeltrain") SUB_CallAsSelf(self.animcontroller.think, self.animcontroller);
		self.nextthink = -1;
	}

	
};

// returns the first active path corner,
// or the first inactive one if no active path was found,
// or world if no path was found at all
entity(string name) getNextCamera = {
	entity targ, first;

	first = targ = find(world, targetname, name);

	// first path is ok
	// most common case, so return early
	if (targ && targ.estate == STATE_ACTIVE)
		return first;

	// found path isn't active, so search for others with the same targetname
	while (targ && targ.estate != STATE_ACTIVE) {
		targ = find(targ, targetname, name);
	}

	// found an active path
	if (targ && targ.estate == STATE_ACTIVE)
		return targ;

	// no active path was found with the same targetname,
	// so return the first non-active one
	// will return world if no path was found at all
	return first;
}

// searches for the next path_corner and sends the train on its way
void() camera_next = {
	entity targ, first;
	vector destang, displ;
	float prevspeed, nextspeed, curspeed;

	if (self.think == func_train_find) prevspeed = 0;
	else if (self.cnt != CAMERA_NEXT_STOP && !self.wait) prevspeed = self.speed2;
	else prevspeed = 0;
	//if (self.cnt == CAMERA_NEXT_STOP || (self.cnt == CAMERA_NEXT_WAIT && self.wait)) prevspeed = 0;
	//else prevspeed = self.speed2;

	if (self.target == "") {
		dprint("train_next: next target not set\n");
		targ = self.enemy;
	}
	else {
		first = targ = getNextCamera(self.target);
		
		// returned path isn't active, so keep iterating until we find one
		while (targ && targ.estate != STATE_ACTIVE) {
			targ = getNextCamera(targ.target);
		}

		if (!targ && !first) {
			dprint("train_next: next target not found\n");
			targ = self.enemy;
		}

		if (!targ && first) {
			dprint("train_next: no active path found\n");
			targ = self.enemy;
		}
	}

	
	self.target = targ.target;
	
	// gets the wait time from the upcoming path_corner if set
	if (targ.wait){
		// wait -2 on the path_corner forces it to continue moving (no wait),
		// even if the train has a default wait time
		if (targ.wait == -2) self.wait = 0;
		else self.wait = targ.wait;
	}
	// uses train's current wait time otherwise
	else
		self.wait = self.pausetime;

	self.enemy = targ;
	
	
	if (!(!self.wait && self.cnt == CAMERA_NEXT_CONTINUE)) self.cnt = CAMERA_NEXT_WAIT;

	//store up any premature triggerings until current movement is finished
	self.use = camera_moving_use; 

	if (self.classname == "misc_modeltrain") {
		if (!(self.spawnflags & CAMERA_NOROTATE)) {
			destang = vectoangles(targ.origin - self.origin);
			if (self.spawnflags & CAMERA_ROTATEY) {
				destang_x = self.angles_x;
				destang_z = self.angles_z;
			}
			if (self.multiplier > 0) SUB_CalcAngleMoveController(destang, self.speed2*self.multiplier, SUB_Null, self.rotatecontroller);
			else self.angles = destang;
		}
	}

	if (!self.state) {
		self.state = 1;
		if (self.classname == "misc_modeltrain" && self.style != CAMERA_STYLE_SINGLEANIM)
			SUB_CallAsSelf(self.animcontroller.think, self.animcontroller);
	}
	
	if (self.classname != "misc_modeltrain") displ = self.mins;

	float smdist = defaultFl(targ.smoothdist, self.smoothdist);
	if (smdist) {
		
		if (self.wait) nextspeed = 0;
		else nextspeed = defaultFl(targ.speed, self.speed2);
 		
 		curspeed = self.speed2;
		//void(vector tdest, float smdist, float tspeed, float stspeed, float fnspeed, void() func) SUB_CalcMoveSmooth
		SUB_CalcMoveSmooth(targ.origin - displ, smdist, curspeed, prevspeed, nextspeed, camera_wait);
	}
	else {
		//void(vector tdest, float tspeed, void() func) SUB_CalcMove
		SUB_CalcMove(targ.origin - displ, self.speed2, camera_wait);
	}
};

// searches for the first path_corner after the train entity is initialized
void() camera_find = {
	local entity	targ;
	vector displ;

	targ = find(world, targetname, self.target);
	self.target = targ.target;

	displ = self.mins;
	self.enemy = targ;
	setorigin(self, targ.origin - displ);
	if (targ.speed) self.speed2 = targ.speed; // uses speed from the 1st path corner if set

	if (!self.targetname)
	{	// not triggered, so start immediately
		self.nextthink = getLocalTime() + 0.1;
		self.think = camera_next;
	}
};