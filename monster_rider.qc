void() Rider_Missile_Touch;
void() rider_stand_attack;
void() rider_pppain1;
void(float ofs, float turn) rider_launch_missile = 
{
	local vector src;
	local vector vec;
	local vector targ;
	local vector ang;
	local entity missile;
	local float dist;
	ang = self.angles;
	ang_y = ang_y + self.fixangle;
	if (turn == 1)
	{
		ang_y = ang_y + 165;
	}
	else
	{
		if (turn == 2)
		{
			ang_y = ang_y - 165;
		}
	}
	makevectors(ang);
	src = self.origin + '0 0 28' + v_right * ofs + v_forward * 2;
	targ = self.enemy.origin + self.enemy.view_ofs;
	if (skill != 0)
	{
		dist = vlen(targ - src);
		targ = targ + self.enemy.velocity * (dist / 1000);
	}
	vec = targ - src;
	vec = normalize(vec);
	dist = vec * v_forward;
	if (dist < self.worldtype)
	{
		vec = v_forward;
	}
	self.effects = self.effects | EF_MUZZLEFLASH;
	sound(self, CHAN_WEAPON, "rider/shoot.wav", 1, ATTN_NORM);
	self.punchangle_x = CONTENT_SOLID;
	missile = spawn();
	missile.owner = self;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX;
	missile.classname = "missile";
	missile.nextthink = time + 2;
	missile.think = SUB_Remove;
	missile.velocity = vec * 800;
	missile.angles = vectoangles(vec);
	missile.touch = Rider_Missile_Touch;
	setmodel(missile, "progs/laser.mdl");
	setsize(missile, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(missile, src);
};

void() Rider_Missile_Touch = 
{
	local vector org;
	if (other == self.owner)
	{
		return;
	}
	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	org = self.origin - 8 * normalize(self.velocity);
	
	if(other.health) {
		SpawnBlood(org, self.velocity * 0.2, 15);
		T_Damage(other, self, self.owner, 10);
	}
	sound(self, CHAN_WEAPON, "enforcer/enfstop.wav", 1, ATTN_NORM);
	self.origin = self.origin - 8 * normalize(self.velocity);
	WriteByte(0, SVC_TEMPENTITY);
	WriteByte(0, TE_GUNSHOT);
	WriteCoord(0, self.origin_x);
	WriteCoord(0, self.origin_y);
	WriteCoord(0, self.origin_z);
	remove(self);
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

void() rider_walkthink = 
{
	local float delta;
	local float angdelta;
	local entity client;
	setorigin(self.trigger_field, self.origin);
	self.trigger_field.angles = self.angles;
	self.trigger_field.frame = self.frame;
	self.trigger_field.angles_y = self.trigger_field.angles_y + self.fixangle;
	ChangeYaw();
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
	client = checkclient();
	if (!client)
	{
		return;
	}
	if (visible(client))
	{
		self.enemy = client;
		FoundTarget();
	}
};

void() idlesnd = 
{
	if (random() < 0.2)
	{
		if (random() < SERVO_VOLUME)
		{
			sound(self, CHAN_WEAPON, "rider/idle.wav", 1, ATTN_NORM);
		}
		else
		{
			sound(self, CHAN_WEAPON, "rider/idle2.wav", 1, ATTN_NORM);
		}
	}
};

void() rider_stand1 = [0, rider_stand2]
{
	ai_stand();
	rider_think();
	self.nextthink = time + 0.2;
	idlesnd();
};

void() rider_stand2 = [1, rider_stand3]
{
	rider_think();
	self.nextthink = time + 0.2;
};

void() rider_stand3 = [2, rider_stand4]
{
	rider_think();
	self.nextthink = time + 0.2;
};

void() rider_stand4 = [3, rider_stand5]
{
	rider_think();
	self.nextthink = time + 0.2;
};

void() rider_stand5 = [4, rider_stand6]
{
	ai_stand();
	rider_think();
	self.nextthink = time + 0.2;
};

void() rider_stand6 = [5, rider_stand7]
{
	rider_think();
	self.nextthink = time + 0.2;
};

void() rider_stand7 = [6, rider_stand8]
{
	rider_think();
	self.nextthink = time + 0.2;
};

void() rider_stand8 = [7, rider_stand9]
{
	rider_think();
	self.nextthink = time + 0.2;
};

void() rider_stand9 = [8, rider_stand10]
{
	rider_think();
	self.nextthink = time + 0.2;
};

void() rider_stand10 = [9, rider_stand11]
{
	ai_stand();
	rider_think();
	self.nextthink = time + 0.2;
};

void() rider_stand11 = [10, rider_stand12]
{
	rider_think();
	self.nextthink = time + 0.2;
};

void() rider_stand12 = [11, rider_stand13]
{
	rider_think();
	self.nextthink = time + 0.2;
};

void() rider_stand13 = [12, rider_stand14]
{
	rider_think();
	self.nextthink = time + 0.2;
};

void() rider_stand14 = [13, rider_stand15]
{
	rider_think();
	self.nextthink = time + 0.2;
};

void() rider_stand15 = [14, rider_stand1]
{
	ai_stand();
	rider_think();
	self.nextthink = time + 0.2;
};

void() rider_walk1 = [24, rider_walk2]
{
	movetogoal(20);
	rider_walkthink();
};

void() rider_walk2 = [25, rider_walk3]
{
	movetogoal(20);
	rider_walkthink();
};

void() rider_walk3 = [26, rider_walk4]
{
	movetogoal(20);
	rider_walkthink();
};

void() rider_walk4 = [27, rider_walk5]
{
	movetogoal(20);
	rider_walkthink();
};

void() rider_walk5 = [28, rider_walk6]
{
	movetogoal(20);
	rider_walkthink();
};

void() rider_walk6 = [29, rider_walk7]
{
	movetogoal(20);
	rider_walkthink();
};

void() rider_walk7 = [30, rider_walk8]
{
	movetogoal(20);
	rider_walkthink();
};

void() rider_walk8 = [31, rider_walk9]
{
	movetogoal(20);
	rider_walkthink();
};

void() rider_walk9 = [32, rider_walk10]
{
	movetogoal(20);
	rider_walkthink();
};

void() rider_walk10 = [33, rider_walk11]
{
	movetogoal(20);
	rider_walkthink();
};

void() rider_walk11 = [34, rider_walk12]
{
	movetogoal(20);
	rider_walkthink();
};

void() rider_walk12 = [35, rider_walk1]
{
	movetogoal(20);
	rider_walkthink();
};

void() rider_run1 = [24, rider_run2]
{
	ChangeYaw();
	RUN_STRAIGHT = 1;
	ai_run(20);
	rider_think();
};

void() rider_run2 = [25, rider_run3]
{
	ChangeYaw();
	RUN_STRAIGHT = 1;
	ai_run(20);
	rider_think();
};

void() rider_run3 = [26, rider_run4]
{
	ChangeYaw();
	RUN_STRAIGHT = 1;
	ai_run(20);
	rider_think();
};

void() rider_run4 = [27, rider_run5]
{
	sound(self, TE_WIZSPIKE, "rider/down2.wav", SERV_VOL, ATTN_NORM);
	ChangeYaw();
	RUN_STRAIGHT = 1;
	ai_run(20);
	rider_think();
};

void() rider_run5 = [28, rider_run6]
{
	sound(self, TE_WIZSPIKE, "rider/down2.wav", SERV_VOL, ATTN_NORM);
	ChangeYaw();
	RUN_STRAIGHT = 1;
	ai_run(20);
	rider_think();
};

void() rider_run6 = [29, rider_run7]
{
	ChangeYaw();
	RUN_STRAIGHT = 1;
	ai_run(20);
	rider_think();
};

void() rider_run7 = [30, rider_run8]
{
	ChangeYaw();
	RUN_STRAIGHT = 1;
	ai_run(20);
	rider_think();
};

void() rider_run8 = [31, rider_run9]
{
	ChangeYaw();
	RUN_STRAIGHT = 1;
	ai_run(20);
	rider_think();
};

void() rider_run9 = [32, rider_run10]
{
	sound(self, TE_WIZSPIKE, "rider/down2.wav", SERV_VOL, ATTN_NORM);
	ChangeYaw();
	RUN_STRAIGHT = 1;
	ai_run(20);
	rider_think();
};

void() rider_run10 = [33, rider_run11]
{
	ChangeYaw();
	RUN_STRAIGHT = 1;
	ai_run(20);
	rider_think();
};

void() rider_run11 = [34, rider_run12]
{
	ChangeYaw();
	RUN_STRAIGHT = 1;
	ai_run(20);
	rider_think();
};

void() rider_run12 = [35, rider_run1]
{
	ChangeYaw();
	RUN_STRAIGHT = 1;
	ai_run(20);
	rider_think();
	if (self.lefty == 1)
	{
		self.lefty = 0;
		self.think = self.th_missile;
	}
};

void() rider_watk1 = [55, rider_watk2]
{
	ChangeYaw();
	walkmove(self.angles_y, 14);
	rider_think();
};

void() rider_watk2 = [56, rider_watk3]
{
	ChangeYaw();
	walkmove(self.angles_y, 14);
	rider_think();
	rider_launch_missile(10, 0);
};

void() rider_watk3 = [57, rider_watk4]
{
	ChangeYaw();
	walkmove(self.angles_y, 14);
	rider_think();
};

void() rider_watk4 = [58, rider_watk5]
{
	ChangeYaw();
	walkmove(self.angles_y, 14);
	rider_think();
	sound(self, TE_WIZSPIKE, "rider/down2.wav", SERV_VOL, ATTN_NORM);
};

void() rider_watk5 = [59, rider_watk6]
{
	ChangeYaw();
	walkmove(self.angles_y, 14);
	rider_think();
	sound(self, TE_WIZSPIKE, "rider/down2.wav", SERV_VOL, ATTN_NORM);
};

void() rider_watk6 = [60, rider_watk7]
{
	ChangeYaw();
	walkmove(self.angles_y, 14);
	rider_think();
};

void() rider_watk7 = [61, rider_watk8]
{
	ChangeYaw();
	walkmove(self.angles_y, 14);
	rider_think();
};

void() rider_watk8 = [62, rider_watk9]
{
	ChangeYaw();
	walkmove(self.angles_y, 14);
	rider_think();
};

void() rider_watk9 = [63, rider_watk10]
{
	ChangeYaw();
	walkmove(self.angles_y, 14);
	rider_think();
	rider_launch_missile(10, 0);
	sound(self, TE_WIZSPIKE, "rider/down2.wav", SERV_VOL, ATTN_NORM);
};

void() rider_watk10 = [64, rider_watk11]
{
	ChangeYaw();
	walkmove(self.angles_y, 14);
	rider_think();
};

void() rider_watk11 = [65, rider_watk12]
{
	ChangeYaw();
	walkmove(self.angles_y, 14);
	rider_think();
};

void() rider_watk12 = [66, rider_run1]
{
	ChangeYaw();
	walkmove(self.angles_y, 14);
	rider_think();
	SUB_AttackFinished(1);
};

void() rider_plant1 = [41, rider_plant1]
{
	rider_stand_attack();
	rider_think();
};

void() rider_stop1 = [40, rider_stop2]
{
	rider_think();
};

void() rider_stop2 = [41, rider_plant1]
{
	rider_think();
};

void() rider_satk1 = [36, rider_satk2]
{
	rider_think();
};

void() rider_satk2 = [37, rider_satk3]
{
	rider_think();
};

void() rider_satk3 = [38, rider_satk4]
{
	rider_think();
	rider_launch_missile(10, 0);
};

void() rider_satk4 = [37, rider_satk5]
{
	rider_think();
};

void() rider_satk5 = [38, rider_satk6]
{
	rider_think();
	rider_launch_missile(10, 0);
};

void() rider_satk6 = [37, rider_satk7]
{
	rider_think();
};

void() rider_satk7 = [38, rider_satk8]
{
	rider_think();
	rider_launch_missile(10, 0);
};

void() rider_satk8 = [37, rider_satk9]
{
	rider_think();
};

void() rider_satk9 = [38, rider_satk10]
{
	rider_think();
	rider_launch_missile(10, 0);
};

void() rider_satk10 = [39, rider_satk11]
{
	rider_think();
};

void() rider_satk11 = [40, rider_satk12]
{
	rider_think();
};

void() rider_satk12 = [41, rider_plant1]
{
	rider_think();
	SUB_AttackFinished(0.3);
};

void() rider_die1 = [67, rider_die2]
{
	rider_think();
	FuelTankExplode();
};

void() rider_die2 = [68, rider_die3]
{
	rider_think();
	self.solid = SOLID_NOT;
};

void() rider_die3 = [69, rider_die4]
{
	rider_think();
};

void() rider_die4 = [70, rider_die5]
{
	rider_think();
};

void() rider_die5 = [71, rider_die6]
{
	rider_think();
	sound(self, CHAN_WEAPON, "rider/death.wav", 1, ATTN_NORM);
};

void() rider_die6 = [72, rider_die7]
{
	rider_think();
};

void() rider_die7 = [73, rider_die8]
{
	rider_think();
};

void() rider_die8 = [74, rider_die9]
{
	rider_think();
};

void() rider_die9 = [75, rider_die10]
{
	rider_think();
};

void() rider_die10 = [76, rider_die11]
{
	rider_think();
};

void() rider_die11 = [76, SUB_Null]
{
};

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
	self.pain_finished = time + SECRET_1ST_DOWN;
	sound(self, CHAN_VOICE, "rider/pain1.wav", 1, ATTN_NORM);
	rider_pppain1();
};

void() rider_pppain1 = [15, rider_pppain2]
{
	rider_think();
};

void() rider_pppain2 = [16, rider_pppain3]
{
	rider_think();
};

void() rider_pppain3 = [17, rider_pppain4]
{
	rider_think();
};

void() rider_pppain4 = [18, rider_pppain5]
{
	rider_think();
};

void() rider_pppain5 = [19, rider_pppain6]
{
	rider_think();
};

void() rider_pppain6 = [20, rider_pppain7]
{
	rider_think();
};

void() rider_pppain7 = [21, rider_pppain8]
{
	rider_think();
};

void() rider_pppain8 = [22, rider_pppain9]
{
	rider_think();
};

void() rider_pppain9 = [23, rider_run1]
{
	rider_think();
};

void() rider_jump01 = [42, rider_jump02]
{
	rider_think();
};

void() rider_jump02 = [43, rider_jump03]
{
	rider_think();
};

void() rider_jump03 = [44, rider_jump04]
{
	rider_think();
	ChangeYaw();
	ChangeYaw();
};

void() rider_jump04 = [45, rider_jump05]
{
	rider_think();
	ChangeYaw();
	ChangeYaw();
	ChangeYaw();
};

void() rider_jump05 = [46, rider_jump06]
{
	rider_think();
	ChangeYaw();
	ChangeYaw();
	ChangeYaw();
};

void() rider_jump06 = [47, rider_jump07]
{
	rider_think();
	ChangeYaw();
	ChangeYaw();
	ChangeYaw();
};

void() rider_jump07 = [48, rider_jump08]
{
	rider_think();
	ChangeYaw();
	ChangeYaw();
	ChangeYaw();
};

void() rider_jump08 = [49, rider_jump09]
{
	rider_think();
	ChangeYaw();
	ChangeYaw();
	ChangeYaw();
	sound(self, CHAN_VOICE, "rider/down.wav", 1, ATTN_NORM);
};

void() rider_jump09 = [50, rider_jump10]
{
	rider_think();
	ChangeYaw();
	ChangeYaw();
};

void() rider_jump10 = [51, rider_jump11]
{
	rider_think();
};

void() rider_jump11 = [52, rider_jump12]
{
	rider_think();
};

void() rider_jump12 = [53, rider_jump13]
{
	rider_think();
};

void() rider_jump13 = [54, rider_satk1]
{
	rider_think();
	if (self.lefty == 1)
	{
		self.lefty = 0;
		self.think = self.th_missile;
	}
};

void() rider_missile_attack = 
{
	if (random() < 0.8)
	{
		rider_watk1();
	}
	else
	{
		rider_satk1();
	}
};

void() rider_stand_attack = 
{
	local vector spot1;
	local vector spot2;
	spot1 = self.origin + self.view_ofs;
	spot2 = self.enemy.origin + self.enemy.view_ofs;
	traceline(spot1, spot2, 0, self);
	if (trace_ent != self.enemy)
	{
		rider_run1();
		return;
	}
	if (trace_inopen && trace_inwater)
	{
		rider_run1();
		return;
	}
	if (time < self.attack_finished)
	{
		return;
	}
	if (vlen(spot2 - spot1) < 200 && self.enemy.classname == "player")
	{
		rider_jump01();
		return;
	}
	self.state = 0;
	if (vlen(spot2 - spot1) > 450)
	{
		rider_run1();
		return;
	}
	rider_satk1();
	if (self.cnt == 1)
	{
		rider_run1();
		return;
	}
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
	if (fabs(delta) > 10 && dist > 200 || self.enemy.classname != "player")
	{
		return 0;
	}
	if (dist < 400)
	{
		self.th_melee();
		return 1;
	}
	self.lefty = 1;
	return 0;
};

void() monster_rider = 
{
	local entity body;
	local float sk;
	if (!deathmatch)
	{
		self.lefty = 0;
		sk = cvar("skill");
		precache_model("progs/ridbody.mdl");
		precache_model("progs/ridlegs.mdl");
		precache_sound("rider/down2.wav");
		precache_sound("weapons/fuelexp.wav");
		precache_model("progs/laser.mdl");
		precache_sound("rider/sight.wav");
		precache_sound("rider/shoot.wav");
		precache_sound("rider/pain1.wav");
		precache_sound("rider/down.wav");
		precache_sound("rider/death.wav");
		precache_sound("rider/idle.wav");
		precache_sound("rider/idle2.wav");
		precache_sound("enforcer/enfstop.wav");
		body = spawn();
		body.origin = self.origin;
		body.origin = body.origin - '0 0 64';
		self.solid = SOLID_SLIDEBOX;
		self.fixangle = 0;
		self.movetype = MOVETYPE_STEP;
		body.solid = SOLID_NOT;
		body.movetype = MOVETYPE_STEP;
		self.trigger_field = body;
		body.trigger_field = self;
		setmodel(body, "progs/ridbody.mdl");
		setmodel(self, "progs/ridlegs.mdl");
		setsize(self, VEC_HULL2_MIN, VEC_HULL2_MAX);
		setorigin(self, self.origin);
		setorigin(body, body.origin);
		if (sk == 0)
		{
			self.yaw_speed = 8;
			self.health = 600;
			self.worldtype = 0.9;
		}
		else
		{
			if (sk == 1)
			{
				self.yaw_speed = 8;
				self.health = 600;
				self.worldtype = 0.85;
			}
			else
			{
				self.yaw_speed = 8;
				self.health = 600;
				self.worldtype = 0.75;
			}
		}
		//dealwithskill();
		self.state = 0;
		self.super_time = 0;
		self.ltime = 0;
		self.th_stand = rider_stand1;
		self.th_walk = rider_walk1;
		self.th_run = rider_run1;
		self.th_die = rider_die1;
		self.th_missile = rider_missile_attack;
		self.th_melee = rider_jump01;
		self.th_pain = rider_pain;
		walkmonster_start();
	}
	else
	{
		remove(self);
	}
};

