void() rider_pppain1;
void() rider_run1;


void() Rider_Push = {
	local	vector	dir;
	local	entity	pushtarg;
	
	pushtarg = findradius(self.origin, 128);
	
	while (pushtarg) {
		if ((pushtarg.classname == "player") || (pushtarg == self.enemy)) {
			dir = normalize (pushtarg.origin - self.origin);
			pushtarg.flags = pushtarg.flags - FL_ONGROUND;
			pushtarg.velocity = dir*400;
			pushtarg.velocity_z = 0;
			pushtarg.velocity_z = 200;		
		}
	
		pushtarg = pushtarg.chain;
	}
};

void(float angdelta, float delta) rider_turn = {
	if (fabs(angdelta) < 10)	self.fixangle = delta;
	else if (angdelta > 5)		self.fixangle = self.fixangle + 9;
	else if (angdelta < -5)		self.fixangle = self.fixangle - 9;
	else 						self.fixangle = delta;
};


void() rider_think = {
	local float delta; // delta Y angle between the enemy and the legs
	local float angdelta; // wiggle room at the middle or something

	setorigin(self.trigger_field, self.origin);
	self.trigger_field.frame = self.frame;

	SUB_Copyonground();
	
	self.effects = 0;

	enemy_yaw = vectoyaw(self.goalentity.origin - self.origin);
	self.ideal_yaw = enemy_yaw;
	delta = self.ideal_yaw - self.angles_y;

	//keeps delta within -/+180deg
	if (delta > 180) delta = delta - 360;
	if (delta < -180) delta = delta + 360;

	if (fabs(delta) > 90) {
		delta = 0;
		//self.think = rider_run1;
		//return;
	}

	angdelta = delta - self.fixangle;
	rider_turn(angdelta, delta);

	self.trigger_field.angles = self.angles;
	if (self.enemy) // avoids weird torso angle when standing
		self.trigger_field.angles_y = self.trigger_field.angles_y + self.fixangle; // makes torso always track the enemy
};

void(float torsoframe, float heightoffset) rider_think_rail = {
	local float delta;
	local float angdelta;

	setorigin(self.trigger_field, self.origin);
	SUB_Copyonground();
	self.trigger_field.origin += [0, 0, heightoffset];
	self.trigger_field.frame = torsoframe;

	//rider_copyonground();

	enemy_yaw = vectoyaw(self.enemy.origin - self.origin);
	self.ideal_yaw = enemy_yaw;
	delta = self.ideal_yaw - self.angles_y;

	if (delta > 180) delta = delta - 360;
	if (delta < -180) delta = delta + 360;

	if (fabs(delta) > 100) {
		self.think = rider_run1;
		return;
	}

	angdelta = delta - self.fixangle;
	rider_turn(angdelta, delta);
	
	self.trigger_field.angles = self.angles;
	// +10deg angle offset correction so the model's weapon points straight to the enemy
	self.trigger_field.angles_y = self.trigger_field.angles_y + delta + 10; 
};


void() rider_walkthink = {
	local float delta;
	local float angdelta;

	setorigin(self.trigger_field, self.origin);
	self.trigger_field.angles = self.angles;
	self.trigger_field.frame = self.frame;
	self.trigger_field.angles_y = self.trigger_field.angles_y + self.fixangle;

	SUB_Copyonground();

	//ChangeYaw();
	delta = 0;
	self.cnt = 0;
	if (delta > 180) delta = delta - 360;
	if (delta < -180) delta = delta + 360;

	if (fabs(delta) > 90) {
		delta = 0;
		self.cnt = 1;
	}

	angdelta = delta - self.fixangle;
	rider_turn(angdelta, delta);
};

void() rider_sound_idle = 
{
	if(!(self.spawnflags & MONSTER_NOIDLESOUND && !self.enemy))
		return;
	
	if (random() < 0.2)
	{
		if (random() < 0.5)
			sound(self, CHAN_WEAPON, "rider/idle.wav", 1, ATTN_IDLE);
		else
			sound(self, CHAN_WEAPON, "rider/idle2.wav", 1, ATTN_IDLE);
	}
};

void() rider_sound = {
	sound(self, 7, "rider/down2.wav", 0.5, ATTN_NORM);
}

void() rider_stand1 = [0, rider_stand2]		{ai_stand(); rider_think(); rider_sound_idle();};
void() rider_stand2 = [0, rider_stand3]		{ai_stand(); rider_think(); };
void() rider_stand3 = [1, rider_stand4]		{ai_stand(); rider_think(); };
void() rider_stand4 = [1, rider_stand5]		{ai_stand(); rider_think(); };
void() rider_stand5 = [2, rider_stand6]		{ai_stand(); rider_think(); };
void() rider_stand6 = [2, rider_stand7]		{ai_stand(); rider_think(); };
void() rider_stand7 = [3, rider_stand8]		{ai_stand(); rider_think(); };
void() rider_stand8 = [3, rider_stand9]		{ai_stand(); rider_think(); };
void() rider_stand9 = [4, rider_stand10]	{ai_stand(); rider_think(); };
void() rider_stand10 = [4, rider_stand11]	{ai_stand(); rider_think(); };
void() rider_stand11 = [5, rider_stand12]	{ai_stand(); rider_think(); };
void() rider_stand12 = [5, rider_stand13]	{ai_stand(); rider_think(); };
void() rider_stand13 = [6, rider_stand14]	{ai_stand(); rider_think(); };
void() rider_stand14 = [6, rider_stand15]	{ai_stand(); rider_think(); };
void() rider_stand15 = [7, rider_stand16]	{ai_stand(); rider_think(); };
void() rider_stand16 = [7, rider_stand17]	{ai_stand(); rider_think(); };
void() rider_stand17 = [8, rider_stand18]	{ai_stand(); rider_think(); };
void() rider_stand18 = [8, rider_stand19]	{ai_stand(); rider_think(); };
void() rider_stand19 = [9, rider_stand20]	{ai_stand(); rider_think(); };
void() rider_stand20 = [9, rider_stand21]	{ai_stand(); rider_think(); };
void() rider_stand21 = [10, rider_stand22]	{ai_stand(); rider_think(); };
void() rider_stand22 = [10, rider_stand23]	{ai_stand(); rider_think(); };
void() rider_stand23 = [11, rider_stand24]	{ai_stand(); rider_think(); };
void() rider_stand24 = [11, rider_stand25]	{ai_stand(); rider_think(); };
void() rider_stand25 = [12, rider_stand26]	{ai_stand(); rider_think(); };
void() rider_stand26 = [12, rider_stand27]	{ai_stand(); rider_think(); };
void() rider_stand27 = [13, rider_stand28]	{ai_stand(); rider_think(); };
void() rider_stand28 = [13, rider_stand29]	{ai_stand(); rider_think(); };
void() rider_stand29 = [14, rider_stand30]	{ai_stand(); rider_think(); };
void() rider_stand30 = [14, rider_stand1]	{ai_stand(); rider_think(); };

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
void() rider_die2 = [68, rider_die3]{rider_think();self.solid = SOLID_TRIGGER; setorigin(self, self.origin);};
void() rider_die3 = [69, rider_die4]{rider_think();};
void() rider_die4 = [70, rider_die5]{rider_think();};
void() rider_die5 = [71, rider_die6]{rider_think();sound(self, CHAN_WEAPON, "rider/death.wav", 1, ATTN_NORM);};
void() rider_die6 = [72, rider_die7]{rider_think();};
void() rider_die7 = [73, rider_die8]{rider_think();};
void() rider_die8 = [74, rider_die9]{rider_think();};
void() rider_die9 = [75, rider_die10]{rider_think();};
void() rider_die10 = [76, rider_die11]{rider_think();};
void() rider_die11 = [76, SUB_Null]{monster_dead_dead();};

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

void() rider_charge = {
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

void(float aheadframes) rider_aim = {
	vector vel;

	vel = self.enemy.velocity;
	vel_z = 0;
	self.dest1 = self.enemy.origin + vel*(aheadframes/10);
};

void() rider_rail_shoot =
{
	local vector src, vec, shotdest;
	local float shotdistance, segments, enemydistance, endsegment;
	
	//if !(visible(self.enemy))
	//	return;
		
	//T_Damage(self.enemy, self, self, 50, DMGTYPE_BALLISTIC);

	makevectors(self.angles);
	src = self.origin + '0 0 16' + v_right * 10 + v_forward * 2;
	
	enemydistance = vlen(src - self.enemy.origin);

	if (enemydistance < 128) // too close, aim directly at enemy
		shotdest = normalize(self.enemy.origin - src)*1000 + self.enemy.origin;
	else
		shotdest = normalize(self.dest1 - src)*1000 + self.dest1;

	
	traceline(src, shotdest, FALSE, self);
	
	if (trace_fraction < 1) {
		if (trace_ent.health > 0) T_Damage(trace_ent, self, self, 50, DMGTYPE_BALLISTIC);
	}

	shotdistance = vlen(src - trace_endpos);

	//	how many railbeam models do we need to draw
	//	where 32 = the length of our beam model
	segments = floor(shotdistance / 32);
	endsegment = TRUE;

	vec = normalize(trace_endpos - src);
	vector ang = vectoangles2(vec);
	while (segments) {

		newmis = spawn();
		newmis.classname = "railbeam";

		setmodel(newmis, "progs/rail.mdl");
		setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);	
		setorigin(newmis, src + vec * 32 * segments);

		newmis.frame = 2;
		newmis.angles = ang;
		newmis.owner = self;
		newmis.flags = newmis.flags | FL_PROJECTILE;

		newmis.think = rail_fade;
		newmis.nextthink = time + 0.6;

		newmis.cnt = 5;

		segments = segments - 1;

		// Plays impact sound where the shot hits (at the last segment).
		// Segments are drawn in an inverse order, so the last one is the first to spawn.
		if (endsegment) {
			endsegment = FALSE;
			sound(newmis, CHAN_AUTO, "rider/thump.wav", 1, ATTN_STATIC);
		}
	}
	

};


void() rider_rail1 = 	[42, rider_rail2]	{ai_face(); rider_think(); self.yaw_speed = 40; rider_charge(); };
void() rider_rail2 = 	[43, rider_rail3]	{ai_face(); rider_think(); };
void() rider_rail3 = 	[44, rider_rail4]	{ai_face(); rider_think(); rider_charge(); self.effects = EF_DIMLIGHT;};
void() rider_rail4 = 	[45, rider_rail5]	{ai_face(); rider_think(); self.attack_finished = time + 3.4;  self.effects = EF_DIMLIGHT;};
void() rider_rail5 = 	[46, rider_rail6]	{ai_face(); rider_think(); rider_charge();  self.effects = EF_DIMLIGHT;};
void() rider_rail6 = 	[47, rider_rail7]	{ai_face(); rider_think();  self.effects = EF_DIMLIGHT;};
void() rider_rail7 = 	[48, rider_rail8]	{ai_face(); rider_think(); rider_charge(); sound (self, CHAN_VOICE, "rider/step.wav", 1, ATTN_NORM);  self.effects = EF_DIMLIGHT;};
void() rider_rail8 = 	[49, rider_rail9]	{ai_face(); rider_think(); rider_charge();  self.effects = EF_DIMLIGHT;};
void() rider_rail9 = 	[50, rider_rail10]	{ai_face(); rider_think(); self.effects = EF_DIMLIGHT;};
void() rider_rail10 = 	[51, rider_rail11]	{ai_face(); rider_think(); Rider_Push(); rider_charge(); self.effects = EF_DIMLIGHT;};
void() rider_rail11 = 	[52, rider_rail12]	{rider_think_rail(36, -12); };
void() rider_rail12 = 	[52, rider_rail13]	{rider_think_rail(37, -12); };
void() rider_rail13 = 	[52, rider_rail14]	{rider_think_rail(38, -12); sound(self, CHAN_VOICE, "rider/rail.wav", 1, ATTN_NORM); };
void() rider_rail14 = 	[52, rider_rail15]	{rider_think_rail(38, -12); if(startskill == SKILL_EASY) rider_aim(3); self.effects = 0;};
void() rider_rail15 = 	[52, rider_rail16]	{rider_think_rail(38, -12); if(startskill != SKILL_NORMAL) rider_aim(2);};
void() rider_rail16 = 	[52, rider_rail17]	{rider_think_rail(38, -12); };
void() rider_rail17 = 	[52, rider_rail18]	{rider_think_rail(38, -12); rider_rail_shoot();self.effects = EF_MUZZLEFLASH;};
void() rider_rail18 = 	[52, rider_rail19]	{rider_think_rail(39, -12); };
void() rider_rail19 = 	[52, rider_rail20]	{rider_think_rail(40, -12); };
void() rider_rail20 = 	[53, rider_rail21]	{rider_think_rail(41, -8); };
void() rider_rail21 = 	[54, rider_run1]	{rider_think_rail(0, -4); self.yaw_speed = 8; };



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
		return 0;
	if (time < self.attack_finished)
		return 0;
	
	ang = self.angles_y + self.fixangle;
	delta = self.ideal_yaw - ang;
	dist = vlen(spot2 - spot1);
	
	if (self.enemy.classname != "player")
		return FALSE;
	
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

	oself = self;
	self = e;

	self.lefty = 0;
	
	
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	setmodel(self, "progs/ridlegs.mdl");
	setsize(self, VEC_HULL2_MIN, VEC_HULL2_MAX);

	body = spawn();
	body.solid = SOLID_NOT;
	body.movetype = MOVETYPE_STEP;

	setmodel(body, "progs/ridbody.mdl");
	setsize(body, VEC_HULL2_MIN, VEC_HULL2_MAX);
	setorigin(body, self.origin);

	self.trigger_field = body;
	body.trigger_field = self;

	SUB_Copyonground();

	if (startskill == SKILL_EASY) {
		self.health = 600;
		self.worldtype = 0.9;
	}
	else if (startskill == SKILL_NORMAL) {
		self.health = 777;
		self.worldtype = 0.85;
	}
	else {
		self.health = 777;
		self.worldtype = 0.75;
	}
	if (self.obituary == "") self.obituary = "was picked off by a Prowler";
	
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
	self.th_missile = rider_rail1;
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
	if (!SUB_InitEntity()) return;
	
	if (deathmatch)	{
		remove(self);
		return;
	}
	
	precache_model ("progs/rail.mdl");
	precache_model("progs/ridbody.mdl");
	precache_model("progs/ridlegs.mdl");
	precache_model("progs/laser.mdl");
	precache_model("progs/d_explod.spr");
	
	precache_sound ("misc/power.wav");		
	precache_sound("rider/down2.wav");
	precache_sound("rider/step.wav");
	precache_sound("rider/rail.wav");
	precache_sound("rider/sight.wav");
	precache_sound("rider/thump.wav");
	precache_sound("rider/pain1.wav");
	precache_sound("rider/death.wav");
	precache_sound("rider/idle.wav");
	precache_sound("rider/idle2.wav");
	precache_sound("enforcer/enfstop.wav");
	precache_sound("weapons/fuelexp.wav");

	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	
	if (self.spawnflags & MONSTER_SPAWNER) {
		self.use = monster_rider_spawner;
		monster_spawner_updatecounter();
	}
	else {
		monster_rider_start(self);
	}
};
