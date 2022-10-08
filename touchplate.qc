void() trigger_touchplate = {
	InitTrigger();

	self.touch = trigger_touchplate_touch;

	// spawnflag 1: fire target3/target4 upon leaving trigger
	// store them into other fields so they wont fire on UseTargets
	if (self.spawnflags & 1) {
		self.group = self.target3;
		self.event = self.target4;
		self.target3 = "";
		self.target4 = "";
	}

	SUB_CheckWaiting();
}

void() trigger_touchplate_touch = {
	if (self.estate != STATE_ACTIVE)
		return;
	if (self.mapvar && !read_mapvar(self.mapvar))
		return;

	if (!(other.flags & FL_CLIENT))
		return;

	self.think = trigger_touchplate_think;
	self.nextthink = time + 0.1 + self.wait;
	self.enemy = other;

	if (self.state)
		return;

	self.state = 1;
	activator = self.enemy;
	SUB_UseTargets();
}

void() trigger_touchplate_think = {
	self.state = 0;

	if (self.spawnflags & 1) {
		activator = self.enemy;
		if (self.group != "") SUB_UseSpecificTarget(self.group, targetname); //target3
		if (self.event != "") SUB_UseSpecificTarget(self.event, targetname); //target4
	}
}


//=============================================================================

void() func_touchplate = {
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	setmodel(self, self.model);

	self.touch = func_touchplate_touch;

	self.distance = zeroconvertdefault(self.distance, 4);
	self.speed = zeroconvertdefault(self.speed, 40);

	if (!self.movedir) self.movedir = '0 0 -1' * self.distance;
	else self.movedir = normalize(self.movedir) * self.distance;
	
	string preset_noise = "";

	if (self.sounds == 1)
		preset_noise = "buttons/airbut1.wav";
	else if (self.sounds == 2)
		preset_noise = "buttons/switch21.wav";
	else if (self.sounds == 3)
		preset_noise = "buttons/switch02.wav";
	else if (self.sounds == 4)
		preset_noise = "buttons/switch04.wav";
	else if (self.sounds == 5)
		preset_noise = "weapons/spindn_click.wav";
	if (self.noise == "" && preset_noise != "") self.noise = preset_noise;
	
	preset_noise = "";
	if (self.sounds2 == 1)
		preset_noise = "buttons/airbut1.wav";
	else if (self.sounds2 == 2)
		preset_noise = "buttons/switch21.wav";
	else if (self.sounds2 == 3)
		preset_noise = "buttons/switch02.wav";
	else if (self.sounds2 == 4)
		preset_noise = "buttons/switch04.wav";
	else if (self.sounds2 == 5)
		preset_noise = "weapons/spindn_click.wav";
	
	if (self.noise2 == "" && preset_noise != "") self.noise2 = preset_noise;

	if (self.noise != "") precache_sound(self.noise);
	if (self.noise2 != "") precache_sound(self.noise2);

	/*self.trigger_field = spawn();
	entity tf = self.trigger_field;
	tf.solid = SOLID_TRIGGER;
	tf.movetype = MOVETYPE_NONE;
	setsize(tf, [self.mins_x, self.mins_y, self.maxs_z], [self.maxs_x, self.maxs_y, self.maxs_z + 16]);
	tf.touch = func_touchplate_tf_touch;
	*/
	// spawnflag 1: fire target3/target4 upon leaving trigger
	// store them into other fields so they wont fire on UseTargets
	if (self.spawnflags & 1) {
		self.group = self.target3;
		self.event = self.target4;
		self.target3 = "";
		self.target4 = "";
	}
}
/*
void() func_touchplate_tf_touch = {
	if (!(other.flags & FL_MONSTER) )
		return;
	dprint("TF touched, Retouching;");
	droptofloor();
	force_retouch = 2;
}
*/
void() func_touchplate_press_finished = {
	//dprint("Running func_touchplate_press_finished\n");
	self.state = 2;
	self.think = func_touchplate_think;
	self.nextthink = getLocalTime() + 0.12 + self.wait;
	activator = self.enemy;
	SUB_UseTargets();
}

void() func_touchplate_touch = {
	if (self.estate != STATE_ACTIVE)
		return;
	if (self.mapvar && !read_mapvar(self.mapvar))
		return;

	if (!(other.flags & FL_CLIENT) )
		return;

	if (self.state == 1) //already moving
		return;
	//dprint("Running func_touchplate_touch\n");

	self.enemy = other;

	if (self.state == 2) {
		self.think = func_touchplate_think;
		self.nextthink = getLocalTime() + 0.1 + self.wait;
		return;
	}

	self.state = 1;

	if (self.noise != "") sound(self, CHAN_VOICE, self.noise, 1, ATTN_NORM);

	SUB_CalcMove(self.origin + self.movedir, self.speed, func_touchplate_press_finished);
}

void() func_touchplate_think = {

	//dprint("Running func_touchplate_think\n");
	self.nextthink = getLocalTime() + 0.02;
	self.think = func_touchplate_return_start;
	force_retouch = 2; // gives standing monsters another chance to touch it
}

void() func_touchplate_return_start = {

	//dprint("Running func_touchplate_return_start\n");
	self.state = 1;
	if (self.noise2 != "") sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);
	SUB_CalcMove(self.origin - self.movedir, self.speed, func_touchplate_return_finished);
}

void() func_touchplate_return_finished = {

	//dprint("Running func_touchplate_return_finished\n");
	self.state = 0;

	if (self.spawnflags & 1) {
		activator = self.enemy;
		if (self.group != "") SUB_UseSpecificTarget(self.group, targetname); //target3
		if (self.event != "") SUB_UseSpecificTarget(self.event, targetname); //target4
	}
}