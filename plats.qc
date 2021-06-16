

void() plat_center_touch;
void() plat_outside_touch;
void() plat_trigger_use;
void() plat_go_up;
void() plat_go_down;
void() plat_crush;
float PLAT_LOW_TRIGGER = 1;

void() plat_spawn_inside_trigger =
{
	local entity	trigger;
	local vector	tmin, tmax;

//
// middle trigger
//	
	trigger = spawn();
	trigger.touch = plat_center_touch;
	trigger.movetype = MOVETYPE_NONE;
	trigger.solid = SOLID_TRIGGER;
	trigger.enemy = self;
	
	tmin = self.mins + '25 25 0';
	tmax = self.maxs - '25 25 -8';
	if (self.spawnflags & PLAT_LOW_TRIGGER) {
		tmin_z = tmax_z - (self.pos1_z - self.pos2_z + 8); //maintain original behaviour for low trigger
		tmax_z = tmin_z + 8;
	}
	else tmin_z = tmin_z - (self.pos1_z - self.pos2_z - 8); // now the trigger field goes all the way to the bottom of the lower position --bmFbr

	if (self.size_x <= 50)
	{
		tmin_x = (self.mins_x + self.maxs_x) / 2;
		tmax_x = tmin_x + 1;
	}
	if (self.size_y <= 50)
	{
		tmin_y = (self.mins_y + self.maxs_y) / 2;
		tmax_y = tmin_y + 1;
	}
	
	setsize (trigger, tmin, tmax);
};

void() plat_hit_top =
{
	sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	self.state = STATE_TOP;
	self.think = plat_go_down;
	self.nextthink = self.ltime + 3;
};

void() plat_hit_bottom =
{
	sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	self.state = STATE_BOTTOM;
};

void() plat_go_down =
{
	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	self.state = STATE_DOWN;
	SUB_CalcMove (self.pos2, self.speed, plat_hit_bottom);
};

void() plat_go_up =
{
	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	self.state = STATE_UP;
	SUB_CalcMove (self.pos1, self.speed, plat_hit_top);
};

void() plat_center_touch =
{
	if (other.classname != "player")
		return;
		
	if (other.health <= 0)
		return;

	self = self.enemy;
	if (self.state == STATE_BOTTOM)
		plat_go_up ();
	else if (self.state == STATE_TOP)
		self.nextthink = self.ltime + 1;	// delay going down
};

void() plat_outside_touch =
{
	if (other.classname != "player")
		return;

	if (other.health <= 0)
		return;
		
//dprint ("plat_outside_touch\n");
	self = self.enemy;
	if (self.state == STATE_TOP)
		plat_go_down ();
};

void() plat_trigger_use =
{
	if (self.think)
		return;		// allready activated
	plat_go_down();
};


void() plat_crush =
{
//dprint ("plat_crush\n");

	T_Damage (other, self, self, 1);
	
	if (self.state == STATE_UP)
		plat_go_down ();
	else if (self.state == STATE_DOWN)
		plat_go_up ();
	else
		objerror ("plat_crush: bad self.state\n");
};

void() plat_use =
{
	self.use = SUB_Null;
	if (self.state != STATE_UP)
		objerror ("plat_use: not in up state");
	plat_go_down();
};


/*QUAKED func_plat (0 .5 .8) ? PLAT_LOW_TRIGGER
speed	default 150

Plats are always drawn in the extended position, so they will light correctly.

If the plat is the target of another trigger or button, it will start out disabled in the extended position until it is trigger, when it will lower and become a normal plat.

If the "height" key is set, that will determine the amount the plat moves, instead of being implicitly determined by the model's height.
Set "sounds" to one of the following:
1) base fast
2) chain slow
*/


void() func_plat =

{
//local entity t;

	if (!self.t_length)
		self.t_length = 80;
	if (!self.t_width)
		self.t_width = 10;

	if (self.sounds == 0)
		self.sounds = 2;

	if (self.sounds == 1) {
		if (!self.noise || self.noise == "") self.noise = "plats/plat1.wav";
		if (!self.noise1 || self.noise1 == "") self.noise1 = "plats/plat2.wav";
	}
	else if (self.sounds == 2) {
		if (!self.noise || self.noise == "") self.noise = "plats/medplat1.wav";
		if (!self.noise1 || self.noise1 == "") self.noise1 = "plats/medplat2.wav";
	}
	else if (self.sounds == 3) { // base door sound
		if (!self.noise || self.noise == "") self.noise = "doors/hydro1.wav";
		if (!self.noise1 || self.noise1 == "") self.noise1 = "doors/hydro2.wav";
	}
	else {
		if (!self.noise || self.noise == "") self.noise = "misc/null.wav";
		if (!self.noise1 || self.noise1 == "") self.noise1 = "misc/null.wav";
	}

	precache_sound(self.noise);
	precache_sound(self.noise1);

	self.mangle = self.angles;
	self.angles = '0 0 0';

	self.classname = "plat";
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	setorigin (self, self.origin);	
	setmodel (self, self.model);
	setsize (self, self.mins , self.maxs);

	self.blocked = plat_crush;
	if (!self.speed)
		self.speed = 150;

// pos1 is the top position, pos2 is the bottom
	self.pos1 = self.origin;
	self.pos2 = self.origin;
	if (self.height)
		self.pos2_z = self.origin_z - self.height;
	else
		self.pos2_z = self.origin_z - self.size_z + 8;

	self.use = plat_trigger_use;

	plat_spawn_inside_trigger ();	// the "start moving" trigger	

	if (self.targetname)
	{
		self.state = STATE_UP;
		self.use = plat_use;
	}
	else
	{
		setorigin (self, self.pos2);
		self.state = STATE_BOTTOM;
	}
};

//============================================================================
// TRAINS
//============================================================================

void() train_next;
void() func_train_find;

float TRAIN_MOVEONTRIGGER = 2; 
float TRAIN_STOPONTRIGGER = 4;

float TRAIN_NEXT_WAIT = 0; //normal movement
float TRAIN_NEXT_STOP = 1; // force a stop on the next path_corner
float TRAIN_NEXT_CONTINUE = 2; // force continue on the next path_corner (ignores wait time)

void() train_blocked = {
	if (time < self.attack_finished) return;

	self.attack_finished = time + 0.5;
	T_Damage (other, self, self, self.dmg);
};

void() train_use = {
	if (self.spawnflags & TRAIN_MOVEONTRIGGER || self.wait < 0) {
		train_next();
		return;
	}
	
	if (self.think != func_train_find && self.cnt != TRAIN_NEXT_STOP)
		return;		// already activated

	train_next();
};

void() train_moving_use = {
	if (self.spawnflags & TRAIN_MOVEONTRIGGER || self.wait < 0)
		self.cnt = TRAIN_NEXT_CONTINUE;
	else if (self.spawnflags & TRAIN_STOPONTRIGGER)
		self.cnt = TRAIN_NEXT_STOP;
}

void() train_wait = {
	self.use = train_use; //ready to be re-triggered

	// from Copper
	// trains now fire their pathcorners' targets on arrival
	// if a player is riding the train, treat them as activator
	activator = nextent(world);
	while (!EntitiesTouching(self,activator) && activator.classname == "player")
		activator = nextent(activator);
	if (activator.classname != "player")
		activator = nextent(world);	// default to player1 wherever they are
	SUB_UseEntTargets(self.enemy);

	self.think = train_next;
	if (self.wait && self.cnt == TRAIN_NEXT_WAIT) {
		self.nextthink = self.ltime + self.wait;
		sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM); //play stopping sound
	}
	else if (self.cnt != TRAIN_NEXT_STOP) {
		//self.nextthink = self.ltime + 0.1;
		//dprint("move instantly\n");
		self.nextthink = -1; // move instantly
		train_next();
	}
	else
		self.nextthink = -1;

	
};

void() train_next = {
	local entity	targ;

	targ = find(world, targetname, self.target);
	self.target = targ.target;
	
	if (!self.target)
		objerror("train_next: no next target");

	if (targ.wait){
		if (targ.wait == -2) self.wait = 0;
		else self.wait = targ.wait;
	}
	else
		self.wait = self.pausetime;

	self.enemy = targ;
	
	sound(self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	
	if(!(!self.wait && self.cnt == TRAIN_NEXT_CONTINUE)) self.cnt = TRAIN_NEXT_WAIT;

	if(targ.speed) self.speed2 = targ.speed;

	self.use = train_moving_use; //store up any premature triggerings until current movement is finished

	SUB_CalcMove(targ.origin - self.mins, self.speed2, train_wait);
};

void() func_train_find = {
	local entity	targ;

	targ = find(world, targetname, self.target);
	self.target = targ.target;

	self.enemy = targ;
	setorigin(self, targ.origin - self.mins);
	if (!self.targetname)
	{	// not triggered, so start immediately
		self.nextthink = self.ltime + 0.1;
		self.think = train_next;
	}
};

/*QUAKED func_train (0 .5 .8) ? RETRIGGER
Trains are moving platforms that players can ride.
The targets origin specifies the min point of the train at each corner.
The train spawns at the first target it is pointing at.
If the train is the target of a button or trigger, it will not begin moving until activated.

RETRIGGER: stop at each path_corner and don't resume until triggered again (ignores wait time)

speed	default 100
dmg		default	2
sounds
1) ratchet metal
2) base

*/
void() func_train =
{	
	if (!self.speed)
		self.speed = 100;
	if (!self.target)
		objerror ("func_train without a target");
	if (!self.dmg)
		self.dmg = 2;

	if(self.spawnflags & TRAIN_STOPONTRIGGER && self.spawnflags & TRAIN_MOVEONTRIGGER)
		objerror("func_train: Stop and move on trigger set at the same time");



	if (self.sounds == 1) {
		if (!self.noise || self.noise == "") self.noise = ("plats/train2.wav");
		if (!self.noise1 || self.noise1 == "") self.noise1 = ("plats/train1.wav");
	}
	else if (self.sounds == 2) { // base door sound
		if (!self.noise || self.noise == "") self.noise = "doors/hydro2.wav";
		if (!self.noise1 || self.noise1 == "") self.noise1 = "doors/hydro1.wav";
	}
	else {
		if (!self.noise || self.noise == "") self.noise = ("misc/null.wav");
		if (!self.noise1 || self.noise1 == "") self.noise1 = ("misc/null.wav");
	}

	precache_sound(self.noise);
	precache_sound(self.noise1);


	self.cnt = TRAIN_NEXT_WAIT;
	
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	self.blocked = train_blocked;
	self.use = train_use;
	self.classname = "train";

	setmodel (self, self.model);
	setsize (self, self.mins , self.maxs);
	setorigin (self, self.origin);

// start trains on the second frame, to make sure their targets have had
// a chance to spawn
	self.nextthink = self.ltime + 0.1;
	self.think = func_train_find;

	self.speed2 = self.speed;
};

/*QUAKED misc_teleporttrain (0 .5 .8) (-8 -8 -8) (8 8 8)
This is used for the final bos
*/
void() misc_teleporttrain =
{	
	if (!self.speed)
		self.speed = 100;
	if (!self.target)
		objerror ("func_train without a target");

	self.cnt = 1;
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_PUSH;
	self.blocked = train_blocked;
	self.use = train_use;
	self.avelocity = '100 200 300';

	self.noise = ("misc/null.wav");
	precache_sound ("misc/null.wav");
	self.noise1 = ("misc/null.wav");
	precache_sound ("misc/null.wav");

	precache_model2 ("progs/teleport.mdl");
	setmodel (self, "progs/teleport.mdl");
	setsize (self, self.mins , self.maxs);
	setorigin (self, self.origin);

// start trains on the second frame, to make sure their targets have had
// a chance to spawn
	self.nextthink = self.ltime + 0.1;
	self.think = func_train_find;
};

