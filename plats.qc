

void() plat_center_touch;
void() plat_outside_touch;
void() plat_trigger_use;
void() plat_go_up;
void() plat_go_down;
void() plat_crush;
float PLAT_LOW_TRIGGER = 1;
float PLAT_DEEP_TRIGGER = 2;

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
	if (self.spawnflags & 4) {
		tmin_z += self.pos1_z - self.pos2_z;
		tmax_z += self.pos1_z - self.pos2_z;
	}

	if (self.spawnflags & PLAT_DEEP_TRIGGER) {
		// makes the trigger field go all the way to the bottom of the lower position
		tmin_z = tmin_z - (self.pos1_z - self.pos2_z - 8);

		if (self.spawnflags & PLAT_LOW_TRIGGER) {
			tmax_z = tmin_z + self.size_z + 8;
		}
	}
	else {
		tmin_z = tmax_z - (self.pos1_z - self.pos2_z + 8);

		if (self.spawnflags & PLAT_LOW_TRIGGER)
		tmax_z = tmin_z + 8;
	}

	if (self.size_x <= 50) {
		tmin_x = (self.mins_x + self.maxs_x) / 2;
		tmax_x = tmin_x + 1;
	}
	if (self.size_y <= 50) {
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

	if (self.smoothdist)
		SUB_CalcMoveSmooth(self.pos2, self.smoothdist, self.speed, 0, 0, plat_hit_bottom);
	else
		SUB_CalcMove (self.pos2, self.speed, plat_hit_bottom);
};

void() plat_go_up =
{
	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	self.state = STATE_UP;
		if (self.smoothdist)
		SUB_CalcMoveSmooth(self.pos1, self.smoothdist, self.speed, 0, 0, plat_hit_top);
	else
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

	T_Damage(other, self, self, 1, DMGTYPE_CRUSH);
	
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
	if (self.spawnflags & 4) {
		self.pos2 = self.origin;
		self.pos1 = self.origin;
		if (self.height)
			self.pos1_z = self.origin_z + self.height;
		else
			self.pos1_z = self.origin_z + self.size_z - 8;
	}
	else {
		self.pos1 = self.origin;
		self.pos2 = self.origin;
		if (self.height)
			self.pos2_z = self.origin_z - self.height;
		else
			self.pos2_z = self.origin_z - self.size_z + 8;
	}

	self.use = plat_trigger_use;

	plat_spawn_inside_trigger ();	// the "start moving" trigger	

	if (self.targetname)
	{
		setorigin (self, self.pos1);
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

float TRAIN_RETRIGGER = 1;
float TRAIN_MOVEONTRIGGER = 2; 
float TRAIN_STOPONTRIGGER = 4;
float TRAIN_NONSOLID = 8;
float TRAIN_NOROTATE = 16;
float TRAIN_ROTATEY = 32;

float TRAIN_NEXT_WAIT = 0; //normal movement
float TRAIN_NEXT_STOP = 1; // force a stop on the next path_corner
float TRAIN_NEXT_CONTINUE = 2; // force continue on the next path_corner (ignores wait time)

float TRAIN_STYLE_SINGLEANIM = 1;

float TRAIN_ANIMTYPE_FORWARD = 1;
float TRAIN_ANIMTYPE_BACKFORTH = 2;

void() train_blocked = {
	if (time < self.attack_finished) return;

	self.attack_finished = time + 0.5;
	T_Damage(other, self, self, self.dmg, DMGTYPE_CRUSH);
};


// Use function for when the train is stopped.
// Makes the train continue on path_corners with wait -1,
// or forces a continue if the "move on trigger" spawnflag is set.
void() train_use = {

	if (self.spawnflags & TRAIN_MOVEONTRIGGER || self.wait < 0) {
		train_next();
		return;
	}
	
	// Train has already moved after startup, and has no "stop on trigger" flag,
	// so ignore activation.
	if (self.think != func_train_find && self.cnt != TRAIN_NEXT_STOP)
		return;

	train_next();
};

// Use function for when the train is moving.
// Forces a stop or an instant continue on the next path_corner depending on the spawnflag set
void() train_moving_use = {
	if (self.spawnflags & TRAIN_MOVEONTRIGGER || self.wait < 0)
		self.cnt = TRAIN_NEXT_CONTINUE;
	else if (self.spawnflags & TRAIN_STOPONTRIGGER)
		self.cnt = TRAIN_NEXT_STOP;
}

// path_corner has been reached, so decide what to do next
void() train_wait = {

	self.use = train_use; //ready to be re-triggered

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

	self.think = train_next;

	// train is moving normally and path_corner has a wait set, so pause for that time.
	if (self.wait > 0 && self.cnt == TRAIN_NEXT_WAIT) {
		// state: stopped
		self.state = 0;
		if (self.classname == "misc_modeltrain") SUB_CallAsSelf(self.animcontroller.think, self.animcontroller);
		self.nextthink = getLocalTime() + self.wait;

		//play stopping sound. If path_corner has a custom sound, play that instead
		if (self.enemy.noise != "") sound(self, CHAN_WEAPON, self.enemy.noise, 1, ATTN_NORM);
		else sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM); 
	}
	// train is moving normally and path_corner has no wait time,
	// or has been forced to move instantly through a triggering.
	else if (self.cnt != TRAIN_NEXT_STOP && !self.wait) {

		//play "passing by" sound, if any. If path_corner has a custom one, play that instead
		if (self.enemy.noise2 != "") sound(self, CHAN_WEAPON, self.enemy.noise2, 1, ATTN_NORM);
		else if (self.noise2 != "") sound(self, CHAN_WEAPON, self.noise2, 1, ATTN_NORM);
		
		self.nextthink = -1; // move instantly
		train_next();
	}
	// path_corner has wait -1, or train has been forced to stop through a triggering.
	else {
		//play stopping sound. If path_corner has a custom sound, play that instead
		if (self.enemy.noise != "") sound(self, CHAN_WEAPON, self.enemy.noise, 1, ATTN_NORM);
		else sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM); 

		// state: stopped
		self.state = 0;

		if (self.classname == "misc_modeltrain") SUB_CallAsSelf(self.animcontroller.think, self.animcontroller);
		self.nextthink = -1;
	}

	
};

// returns the first active path corner,
// or the first inactive one if no active path was found,
// or world if no path was found at all
entity(string name) getNextPath = {
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
void() train_next = {
	entity targ, first;
	vector destang, displ;
	float prevspeed, nextspeed, curspeed;

	if (self.think == func_train_find) prevspeed = 0;
	else if (self.cnt != TRAIN_NEXT_STOP && !self.wait) prevspeed = self.speed2;
	else prevspeed = 0;
	//if (self.cnt == TRAIN_NEXT_STOP || (self.cnt == TRAIN_NEXT_WAIT && self.wait)) prevspeed = 0;
	//else prevspeed = self.speed2;

	if (self.target == "") {
		dprint("train_next: next target not set\n");
		targ = self.enemy;
	}
	else {
		first = targ = getNextPath(self.target);
		
		// returned path isn't active, so keep iterating until we find one
		while (targ && targ.estate != STATE_ACTIVE) {
			targ = getNextPath(targ.target);
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
	
	sound(self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	
	if (!(!self.wait && self.cnt == TRAIN_NEXT_CONTINUE)) self.cnt = TRAIN_NEXT_WAIT;

	//store up any premature triggerings until current movement is finished
	self.use = train_moving_use; 

	if (self.classname == "misc_modeltrain") {
		if (!(self.spawnflags & TRAIN_NOROTATE)) {
			destang = vectoangles(targ.origin - self.origin);
			if (self.spawnflags & TRAIN_ROTATEY) {
				destang_x = self.angles_x;
				destang_z = self.angles_z;
			}
			if (self.multiplier > 0) SUB_CalcAngleMoveController(destang, self.speed2*self.multiplier, SUB_Null, self.rotatecontroller);
			else self.angles = destang;
		}
	}

	if (!self.state) {
		self.state = 1;
		if (self.classname == "misc_modeltrain" && self.style != TRAIN_STYLE_SINGLEANIM)
			SUB_CallAsSelf(self.animcontroller.think, self.animcontroller);
	}
	
	if (self.classname != "misc_modeltrain") displ = self.mins;

	float smdist = defaultFl(targ.smoothdist, self.smoothdist);
	if (smdist) {
		
		if (self.wait) nextspeed = 0;
		else nextspeed = defaultFl(targ.speed, self.speed2);
 		
 		curspeed = self.speed2;
		//void(vector tdest, float smdist, float tspeed, float stspeed, float fnspeed, void() func) SUB_CalcMoveSmooth
		SUB_CalcMoveSmooth(targ.origin - displ, smdist, curspeed, prevspeed, nextspeed, train_wait);
	}
	else {
		//void(vector tdest, float tspeed, void() func) SUB_CalcMove
		SUB_CalcMove(targ.origin - displ, self.speed2, train_wait);
	}
};

// searches for the first path_corner after the train entity is initialized
void() func_train_find = {
	local entity	targ;
	vector displ;

	targ = find(world, targetname, self.target);
	self.target = targ.target;

	if (self.classname != "misc_modeltrain") displ = self.mins;
	self.enemy = targ;
	setorigin(self, targ.origin - displ);
	if (targ.speed) self.speed2 = targ.speed; // uses speed from the 1st path corner if set

	if (!self.targetname)
	{	// not triggered, so start immediately
		self.nextthink = getLocalTime() + 0.1;
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
		if (self.noise == "") self.noise = ("plats/train2.wav");
		if (self.noise1 == "") self.noise1 = ("plats/train1.wav");
	}
	else if (self.sounds == 2) { // base door sound
		if (self.noise == "") self.noise = "doors/hydro2.wav";
		if (self.noise1 == "") self.noise1 = "doors/hydro1.wav";
	}
	else {
		if (self.noise == "") self.noise = ("misc/null.wav");
		if (self.noise1 == "") self.noise1 = ("misc/null.wav");
	}

	precache_sound(self.noise);
	precache_sound(self.noise1);
	if (self.noise2 != "") precache_sound(self.noise2);


	self.cnt = TRAIN_NEXT_WAIT;
	
	if (self.spawnflags & TRAIN_NONSOLID) {
		self.solid = SOLID_NOT;
		self.movetype = MOVETYPE_NOCLIP;
	}
	else {
		self.solid = SOLID_BSP;
		self.movetype = MOVETYPE_PUSH;
	}

	self.blocked = train_blocked;
	self.use = train_use;
	//self.classname = "train";

	setmodel (self, self.model);
	setsize (self, self.mins , self.maxs);
	setorigin (self, self.origin);

	// start trains on the second frame, to make sure their targets have had
	// a chance to spawn

	if (self.movetype == MOVETYPE_PUSH) self.nextthink = self.ltime + 0.1;
	else self.nextthink = time + 0.1;

	self.think = func_train_find;

	self.speed2 = self.speed;
};


//===================================================


void() animcontroller_think = {
	entity tr;
	tr = self.owner;
	
	float first, last, step, atype, dir, nextframe;

	// train just went from stopped to moving or vice-versa,
	// and have both animations set
	if (self.state != tr.state && tr.style != TRAIN_STYLE_SINGLEANIM) {
		if (tr.state) { // just started moving
			tr.frame = zeroconvert(tr.first_frame2);
		}
		else { // just stopped
			tr.frame = zeroconvert(tr.first_frame);
		}
		tr.distance = 1; // reset back/forth status
		self.state = tr.state;
	}
	
	else {
		if (self.state && tr.style != TRAIN_STYLE_SINGLEANIM) { // moving train animation, if set
			first = zeroconvert(tr.first_frame2);
			last = zeroconvert(tr.last_frame2);
			atype = tr.animtype2;
		}
		else { // stopped/default train animation
			first = zeroconvert(tr.first_frame);
			last = zeroconvert(tr.last_frame);
			atype = tr.animtype;
		}

		if (first > last) step = dir = -1; // reverse direction
		else step = dir = 1;

		// back-and-forth is going the other way, so invert the step's signal
		if (tr.distance < 0) step = step * (-1);
		
		nextframe = tr.frame + step;

		if (atype == TRAIN_ANIMTYPE_BACKFORTH){
			if (dir > 0 && (nextframe > last || nextframe < first) ||
				dir < 0 && (nextframe > first || nextframe < last)
			) {
				nextframe = tr.frame - step;
				tr.distance = tr.distance * (-1);
			}
		}

		if (dir > 0) nextframe = wrap(nextframe, first, last);
		else nextframe = wrap(nextframe, last, first);
		
		tr.frame = nextframe;

	}

	self.think = animcontroller_think;
	if (self.state || tr.style == TRAIN_STYLE_SINGLEANIM) self.nextthink = time + tr.frtime;
	else self.nextthink = time + tr.frtime2;
};

void() misc_modeltrain = {

	precache_model(self.mdl);

	func_train();

	if (self.spawnflags & TRAIN_NONSOLID)
		self.solid = SOLID_NOT;
	else { 
		self.solid = SOLID_BBOX;
		if (self.cmins == VEC_ORIGIN) self.cmins = '-8 -8 -8';
		if (self.cmaxs == VEC_ORIGIN) self.cmaxs = '8 8 8';
	}

	self.movetype = MOVETYPE_NOCLIP;
	setmodel (self, self.mdl);
	setsize (self, self.cmins , self.cmaxs);
	setorigin (self, self.origin);

	entity rot, anim;
	
	rot = spawn();
	self.rotatecontroller = rot;
	rot.classname = "rotatecontroller";
	rot.owner = self;

	anim = spawn();
	self.animcontroller = anim;
	anim.classname = "animcontroller";
	anim.owner = self;

	anim.think = animcontroller_think;
	anim.nextthink = time + 0.2;

	self.distance = 1;

	if (!self.frtime) self.frtime = 0.1;
	if (!self.frtime2) self.frtime2 = self.frtime;
	if (!self.multiplier) self.multiplier = 1;


	// make sure all first and last frame fields are filled
	if (self.first_frame && !self.last_frame) self.last_frame = self.first_frame;
	else if (!self.first_frame && self.last_frame) self.first_frame = self.last_frame;
	
	if (self.first_frame2 && !self.last_frame2) self.last_frame2 = self.first_frame2;
	else if (!self.first_frame2 && self.last_frame2) self.first_frame2 = self.last_frame2;

	if (!self.first_frame2) self.style = TRAIN_STYLE_SINGLEANIM;

	if (!self.animtype) self.animtype = TRAIN_ANIMTYPE_FORWARD;
	if (!self.animtype2) self.animtype2 = self.animtype;

	self.frame = self.first_frame;

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
	
	self.speed2 = self.speed;
	self.cnt = 1;
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_NOCLIP;
	self.use = train_use;
	self.avelocity = '100 200 300';

	self.noise = ("misc/null.wav");
	precache_sound ("misc/null.wav");
	self.noise1 = ("misc/null.wav");
	precache_sound ("misc/null.wav");

	precache_model2 ("progs/teleport.mdl");
	setmodel (self, "progs/teleport.mdl");
	setsize (self, '0 0 0' , '0 0 0');
	setorigin (self, self.origin);

// start trains on the second frame, to make sure their targets have had
// a chance to spawn
	self.nextthink = self.ltime + 0.1;
	self.think = func_train_find;
};

