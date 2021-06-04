void() rider_pppain1;
.float torsoframe;
.vector heightofs;
.float takedam;

void() Rider_Push =
{
	local	vector	dir;
	local	entity	pushtarg;
	
	pushtarg = findradius(self.origin, 128);
	
	while (pushtarg)
	{
		if ((pushtarg.classname == "player") || (pushtarg == self.enemy))
			{
			dir = normalize (pushtarg.origin - self.origin);
			pushtarg.flags = pushtarg.flags - FL_ONGROUND;
			pushtarg.velocity = dir*400;
			pushtarg.velocity_z = 0;
			pushtarg.velocity_z = 200;		
			}
	
	pushtarg = pushtarg.chain;
	}
	
	
};


void(float angdelta, float delta) rider_turn = 
{
	if (fabs(angdelta) < 10)
	{
		self.fixangle = delta;
	}
	else
	{
		if (angdelta > 5)
		{
			self.fixangle = self.fixangle + 9;
		}
		else
		{
			if (angdelta < CONTENT_LAVA)
			{
				self.fixangle = self.fixangle - 9;
			}
			else
			{
				self.fixangle = delta;
			}
		}
	}
};

void() rider_think = 
{
	local float delta;
	local float angdelta;
	setorigin(self.trigger_field, self.origin);
	self.trigger_field.angles = self.angles;
	self.trigger_field.frame = self.frame;
	self.trigger_field.angles_y = self.trigger_field.angles_y + self.fixangle;
	enemy_yaw = vectoyaw(self.enemy.origin - self.origin);
	self.ideal_yaw = enemy_yaw;
	delta = self.ideal_yaw - self.angles_y;
	self.cnt = 0;
	if (delta > 180)
	{
		delta = delta - 360;
	}
	if (delta < -180)
	{
		delta = delta + 360;
	}
	if (fabs(delta) > 90)
	{
		delta = 0;
		self.cnt = 1;
	}
	angdelta = delta - self.fixangle;
	rider_turn(angdelta, delta);
	if (self.health < 0)
	{
		return;
	}
};

void() rider_think_rail = 
{
	local float delta;
	local float angdelta;

	setorigin(self.trigger_field, self.origin + self.heightofs);
	self.trigger_field.angles = self.angles;
	self.trigger_field.frame = self.torsoframe;
	self.trigger_field.angles_y = self.trigger_field.angles_y + self.fixangle;

	enemy_yaw = vectoyaw(self.enemy.origin - self.origin);
	self.ideal_yaw = enemy_yaw;
	delta = self.ideal_yaw - self.angles_y;
	self.cnt = 0;
	if (delta > 180)
	{
		delta = delta - 360;
	}
	if (delta < -180)
	{
		delta = delta + 360;
	}
	if (fabs(delta) > 90)
	{
		delta = 0;
		self.cnt = 1;
	}
	angdelta = delta - self.fixangle;
	rider_turn(angdelta, delta);

	if (self.health < 0)
	{
		return;
	}
	
};



void() rider_walkthink = 
{
	local float delta;
	local float angdelta;

	setorigin(self.trigger_field, self.origin);
	self.trigger_field.angles = self.angles;
	self.trigger_field.frame = self.frame;
	self.trigger_field.angles_y = self.trigger_field.angles_y + self.fixangle;
	//ChangeYaw();
	delta = 0;
	self.cnt = 0;
	if (delta > 180)
	{
		delta = delta - 360;
	}
	if (delta < -180)
	{
		delta = delta + 360;
	}
	if (fabs(delta) > 90)
	{
		delta = 0;
		self.cnt = 1;
	}
	angdelta = delta - self.fixangle;
	rider_turn(angdelta, delta);
	if (self.health < 0)
	{
		return;
	}
};

void() rider_sound_idle = 
{
	if(!(self.spawnflags & MONSTER_NOIDLESOUND && !self.enemy))
		return;
	
	if (random() < 0.2)
	{
		if (random() < 0.5)
			sound(self, CHAN_WEAPON, "rider/idle.wav", 1, ATTN_NORM);
		else
			sound(self, CHAN_WEAPON, "rider/idle2.wav", 1, ATTN_NORM);
	}
};

void() rider_sound = {
	sound(self, 7, "rider/down2.wav", SERV_VOL, ATTN_NORM);
}

void() rider_stand1 = [0, rider_stand2]		{ai_stand(); rider_think(); self.nextthink = time + 0.2; rider_sound_idle();};
void() rider_stand2 = [1, rider_stand3]		{ai_stand(); rider_think(); self.nextthink = time + 0.2;};
void() rider_stand3 = [2, rider_stand4]		{ai_stand(); rider_think(); self.nextthink = time + 0.2;};
void() rider_stand4 = [3, rider_stand5]		{ai_stand(); rider_think(); self.nextthink = time + 0.2;};
void() rider_stand5 = [4, rider_stand6]		{ai_stand(); rider_think(); self.nextthink = time + 0.2;};
void() rider_stand6 = [5, rider_stand7]		{ai_stand(); rider_think(); self.nextthink = time + 0.2;};
void() rider_stand7 = [6, rider_stand8]		{ai_stand(); rider_think(); self.nextthink = time + 0.2;};
void() rider_stand8 = [7, rider_stand9]		{ai_stand(); rider_think(); self.nextthink = time + 0.2;};
void() rider_stand9 = [8, rider_stand10]	{ai_stand(); rider_think(); self.nextthink = time + 0.2;};
void() rider_stand10 = [9, rider_stand11]	{ai_stand(); rider_think(); self.nextthink = time + 0.2;};
void() rider_stand11 = [10, rider_stand12]	{ai_stand(); rider_think(); self.nextthink = time + 0.2;};
void() rider_stand12 = [11, rider_stand13]	{ai_stand(); rider_think(); self.nextthink = time + 0.2;};
void() rider_stand13 = [12, rider_stand14]	{ai_stand(); rider_think(); self.nextthink = time + 0.2;};
void() rider_stand14 = [13, rider_stand15]	{ai_stand(); rider_think(); self.nextthink = time + 0.2;};
void() rider_stand15 = [14, rider_stand1]	{ai_stand(); rider_think(); self.nextthink = time + 0.2;};

void() rider_walk1 = [24, rider_walk2]		{ai_walk(20); rider_walkthink(); self.yaw_speed = 15;};
void() rider_walk2 = [25, rider_walk3]		{ai_walk(20); rider_walkthink();};
void() rider_walk3 = [26, rider_walk4]		{ai_walk(20); rider_walkthink();};
void() rider_walk4 = [27, rider_walk5]		{ai_walk(20); rider_walkthink(); rider_sound();};
void() rider_walk5 = [28, rider_walk6]		{ai_walk(20); rider_walkthink(); rider_sound();};
void() rider_walk6 = [29, rider_walk7]		{ai_walk(20); rider_walkthink();};
void() rider_walk7 = [30, rider_walk8]		{ai_walk(20); rider_walkthink();};
void() rider_walk8 = [31, rider_walk9]		{ai_walk(20); rider_walkthink();};
void() rider_walk9 = [32, rider_walk10]		{ai_walk(20); rider_walkthink(); rider_sound();};
void() rider_walk10 = [33, rider_walk11]	{ai_walk(20); rider_walkthink();};
void() rider_walk11 = [34, rider_walk12]	{ai_walk(20); rider_walkthink();};
void() rider_walk12 = [35, rider_walk1]		{ai_walk(20); rider_walkthink();};

void() rider_run1 = [24, rider_run2]{
	self.yaw_speed = 8;
	ChangeYaw();
	ai_run(20);
	rider_think();
};

void() rider_run2 = [25, rider_run3]{
	ChangeYaw();
	ai_run(20);
	rider_think();
};

void() rider_run3 = [26, rider_run4]{
	ChangeYaw();
	ai_run(20);
	rider_think();
};

void() rider_run4 = [27, rider_run5]{
	rider_sound();
	ChangeYaw();
	ai_run(20);
	rider_think();
	self.trigger_field.origin = self.trigger_field.origin + '0 0 -4';	
};

void() rider_run5 = [28, rider_run6]{
	rider_sound();
	ChangeYaw();
	
	ai_run(20);
	rider_think();
	self.trigger_field.origin = self.trigger_field.origin + '0 0 -4';	
};

void() rider_run6 = [29, rider_run7]{ChangeYaw();
	
	ai_run(20);
	rider_think();
};

void() rider_run7 = [30, rider_run8]{ChangeYaw();
	
	ai_run(20);
	rider_think();
};

void() rider_run8 = [31, rider_run9]{ChangeYaw();
	
	ai_run(20);
	rider_think();
};

void() rider_run9 = [32, rider_run10]{
	rider_sound();
	ChangeYaw();
	ai_run(20);
	rider_think();
};

void() rider_run10 = [33, rider_run11]{ChangeYaw();
	
	ai_run(20);
	rider_think();
};

void() rider_run11 = [34, rider_run12]{ChangeYaw();
	
	ai_run(20);
	rider_think();
};

void() rider_run12 = [35, rider_run1]{ChangeYaw();
	
	ai_run(20);
	rider_think();
	if (self.lefty == 1)
	{
		self.lefty = 0;
		self.think = self.th_missile;
	}
};

void() rider_die1 = [67, rider_die2]{rider_think();FuelTankExplode();};
void() rider_die2 = [68, rider_die3]{rider_think();self.solid = SOLID_NOT;};
void() rider_die3 = [69, rider_die4]{rider_think();};
void() rider_die4 = [70, rider_die5]{rider_think();};
void() rider_die5 = [71, rider_die6]{rider_think();sound(self, CHAN_WEAPON, "rider/death.wav", 1, ATTN_NORM);};
void() rider_die6 = [72, rider_die7]{rider_think();};
void() rider_die7 = [73, rider_die8]{rider_think();};
void() rider_die8 = [74, rider_die9]{rider_think();};
void() rider_die9 = [75, rider_die10]{rider_think();};
void() rider_die10 = [76, rider_die11]{rider_think();};
void() rider_die11 = [76, SUB_Null]{};

void(entity attacker, float damage) rider_pain = 
{
	if (self.health <= 0)
	{
		return;
	}
	if (self.pain_finished > time)
	{
		return;
	}
	self.pain_finished = time + 4;
	sound(self, CHAN_VOICE, "rider/pain1.wav", 1, ATTN_NORM);
	rider_pppain1();
};

void() rider_pppain1 = [15, rider_pppain2]{rider_think();};
void() rider_pppain2 = [16, rider_pppain3]{rider_think();};
void() rider_pppain3 = [17, rider_pppain4]{rider_think();};
void() rider_pppain4 = [18, rider_pppain5]{rider_think();};
void() rider_pppain5 = [19, rider_pppain6]{rider_think();};
void() rider_pppain6 = [20, rider_pppain7]{rider_think();};
void() rider_pppain7 = [21, rider_pppain8]{rider_think();};
void() rider_pppain8 = [22, rider_pppain9]{rider_think();};
void() rider_pppain9 = [23, rider_run1]{rider_think();};

void() rider_charge =
{
makevectors(self.trigger_field.angles);
sound (self, CHAN_VOICE, "misc/power.wav", 1, ATTN_NORM);

particle (self.trigger_field.origin + '0 0 28' + v_forward * 28 + v_right *28  ,  self.trigger_field.origin + '0 0 28' - (self.trigger_field.origin + '0 0 28' + v_forward * 28 + v_right *28 * -5), 111, 30);
particle (self.trigger_field.origin + '0 0 28' + v_forward * -28 + v_right *28 ,  self.trigger_field.origin + '0 0 28' - (self.trigger_field.origin + '0 0 28' + v_forward * -28 + v_right *28 * -5), 111, 30);
particle (self.trigger_field.origin + '0 0 28' + v_forward * 28 + v_right *-28 ,  self.trigger_field.origin + '0 0 28' - (self.trigger_field.origin + '0 0 28' + v_forward * 28 + v_right *-28 * -5), 111, 30);
particle (self.trigger_field.origin + '0 0 28' + v_forward * -28 + v_right *-28,  self.trigger_field.origin + '0 0 28' - (self.trigger_field.origin + '0 0 28' + v_forward * -28 + v_right *-28 * -5), 111, 30);

}


void() rail_fade = {
	self.think = rail_fade;
	self.nextthink = time + 0.1;

	if (self.cnt == 6)
		self.alpha = 0.7;
	else if (self.cnt == 5)
		self.alpha = 0.4;
	else if (self.cnt == 4)
		self.alpha = 0.2;
	else if (self.cnt == 3)
		self.alpha = 0.15;
	else if (self.cnt == 2)
		self.alpha = 0.10;
	else if (self.cnt == 1) {
		self.alpha = 0.05;
		self.think = SUB_Remove;
		self.nextthink = time + 0.1;
	}	

	self.cnt = self.cnt - 1;
};


void() rider_rail_shoot =
{
	local vector src, vec;
	local float disttoenemy, segments;
	
	if !(visible(self.enemy))
		return;
		
	T_Damage(self.enemy, self, self, 50);

	makevectors(self.angles);
	src = self.origin + '0 0 28' + v_right * 10 + v_forward * 2;
	
	traceline(src, self.enemy.origin, TRUE, self);
	
	disttoenemy = vlen(src - trace_endpos);
//	how many railbeam models do we need to draw
//	where 32 = the length of our beam model
	segments = floor(disttoenemy / 32);
	
	while (segments){
		
		vec = normalize(trace_endpos - src);
		launch_spike (src, vec);
		newmis.owner = self.owner;
		newmis.classname = "railbeam";
		setmodel (newmis, "progs/rail.mdl");
		setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);	
		setorigin(newmis, src + vec * 32 * segments);
		newmis.solid = SOLID_NOT;
		newmis.touch = SUB_Null;
		newmis.think = rail_fade;
		newmis.movetype = MOVETYPE_NONE;
		newmis.nextthink = time + 0.6;
		newmis.velocity = 0;
		segments = segments - 1;
		newmis.frame = 2;
		newmis.cnt = 5;	
	}

};


void() rider_rail1 = [42, rider_rail2]{ai_face();rider_think();self.yaw_speed = 40;rider_charge();};
void() rider_rail2 = [43, rider_rail3]{ai_face();rider_think();};
void() rider_rail3 = [44, rider_rail4]{ai_face();rider_think();rider_charge();};
void() rider_rail4 = [45, rider_rail5]{ai_face();rider_think();};
void() rider_rail5 = [46, rider_rail6]{ai_face();rider_think();rider_charge();};
void() rider_rail6 = [47, rider_rail7]{ai_face();rider_think();};
void() rider_rail7 = [48, rider_rail8]{ai_face();rider_think();sound (self, CHAN_VOICE, "rider/step.wav", 1, ATTN_NORM);rider_charge();};
void() rider_rail8 = [49, rider_rail9]{ai_face();rider_think();rider_charge();};
void() rider_rail9 = [50, rider_rail10]{ai_face();rider_think();};
void() rider_rail10 = [51, rider_rail11]{ai_face();rider_think();Rider_Push();rider_charge();};
void() rider_rail11 = [52, rider_rail12]{self.torsoframe = 36;self.heightofs = '0 0 -12';ai_face();rider_think_rail();};
void() rider_rail12 = [52, rider_rail13]{self.torsoframe = 37;self.heightofs = '0 0 -12';ai_face();rider_think_rail();};
void() rider_rail13 = [52, rider_rail14]{self.torsoframe = 38;self.heightofs = '0 0 -12';ai_face();rider_think_rail();};
void() rider_rail14 = [52, rider_rail15]{self.torsoframe = 38;self.heightofs = '0 0 -12';ai_face();rider_think_rail();sound(self, CHAN_VOICE, "rider/rail.wav", 1, ATTN_NORM);};
void() rider_rail15 = [52, rider_rail16]{self.torsoframe = 38;self.heightofs = '0 0 -12';ai_face();rider_think_rail();};
void() rider_rail16 = [52, rider_rail17]{self.torsoframe = 38;self.heightofs = '0 0 -12';ai_face();rider_think_rail();};
void() rider_rail17 = [52, rider_rail18]{self.torsoframe = 38;self.heightofs = '0 0 -12';ai_face();rider_think_rail();rider_rail_shoot();self.attack_finished = time + 2;};
void() rider_rail18 = [52, rider_rail19]{self.torsoframe = 39;self.heightofs = '0 0 -12';ai_face();rider_think_rail();};
void() rider_rail19 = [52, rider_rail20]{self.torsoframe = 40;self.heightofs = '0 0 -12';ai_face();rider_think_rail();};
void() rider_rail20 = [53, rider_rail21]{self.torsoframe = 41;self.heightofs = '0 0 -8';ai_face();rider_think_rail();};
void() rider_rail21 = [54, rider_run1]{self.torsoframe = 0;self.heightofs = '0 0 -4'; ai_face();rider_think_rail();self.yaw_speed = 8;};



void() rider_missile_attack = 
{

	rider_rail1();

};


float() RiderCheckAttack = 
{
	local vector spot1;
	local vector spot2;
	local entity targ;
	local float ang;
	local float delta;
	local float dist;
	self.lefty = 0;
	targ = self.enemy;
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;
	traceline(spot1, spot2, 0, self);
	if (trace_inopen && trace_inwater)
	{
		return 0;
	}
	if (time < self.attack_finished)
	{
		return 0;
	}
	ang = self.angles_y + self.fixangle;
	delta = self.ideal_yaw - ang;
	dist = vlen(spot2 - spot1);
	
	if (self.enemy.classname != "player")
	{
	return FALSE;
	}
	
	if (self.attack_finished < time)
		return TRUE;

	self.lefty = 1;
	return FALSE;
};


void() rider_sight = {
	sound (self, CHAN_VOICE, "rider/sight.wav", 1, ATTN_NORM);
};

void(entity e) monster_rider_start = 
{
	local entity oself;
	local entity body;
	local float sk;

	oself = self;
	self = e;

	self.lefty = 0;
	sk = cvar("skill");
	
	
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	setmodel(self, "progs/ridlegs.mdl");
	setsize(self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	setorigin(self, self.origin);

	body = spawn();
	body.solid = SOLID_NOT;
	body.movetype = MOVETYPE_STEP;
	setmodel(body, "progs/ridbody.mdl");
	setorigin(body, self.origin - '0 0 64');

	self.trigger_field = body;
	body.trigger_field = self;

	if (sk == 0) {
		self.health = 600;
		self.worldtype = 0.9;
	}
	else if (sk == 1) {
		self.health = 777;
		self.worldtype = 0.85;
	}
	else {
		self.health = 777;
		self.worldtype = 0.75;
	}
	
	if(!self.bloodtype) self.bloodtype = SPAWN_YELLOWSPARK;

	self.yaw_speed = 8;
	self.fixangle = 0;
	self.state = 0;
	self.super_time = 0;
	self.ltime = 0;
	self.th_stand = rider_stand1;
	self.th_walk = rider_walk1;
	self.th_run = rider_run1;
	self.th_die = rider_die1;
	self.th_missile = rider_missile_attack;
	self.th_pain = rider_pain;
	self.th_sight = rider_sight;
	walkmonster_start();

	self = oself;
};

void() monster_rider_spawner = {
	monster_spawner(monster_rider_start);
};

void() monster_rider = 
{
	if (deathmatch)	{
		remove(self);
		return;
	}
	
	precache_model ("progs/rail.mdl");
	precache_model("progs/ridbody.mdl");
	precache_model("progs/ridlegs.mdl");
	precache_model("progs/laser.mdl");

	// temp charge sound
	precache_sound ("misc/power.wav");		
	precache_sound("rider/down2.wav");
	precache_sound("rider/step.wav");
	precache_sound("rider/rail.wav");	
	precache_sound("rider/step.wav");
	precache_sound("rider/sight.wav");
	precache_sound("rider/shoot.wav");
	precache_sound("rider/pain1.wav");
	precache_sound("rider/down.wav");
	precache_sound("rider/death.wav");
	precache_sound("rider/idle.wav");
	precache_sound("rider/idle2.wav");
	precache_sound("enforcer/enfstop.wav");
	precache_sound("weapons/fuelexp.wav");

	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	
	if (self.spawnflags & MONSTER_SPAWNER) {
		self.use = monster_rider_spawner;
	}
	else {
		monster_rider_start(self);
	}
};
