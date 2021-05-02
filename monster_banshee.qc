void() Projectile_Hit;
void() ban_fire_still;


void() Projectile_Hit = 
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
		ImpactSpawn(org, self.velocity * 0.2, 15, other.bloodtype);
		T_Damage(other, self, self.owner, 10);
	}
	T_RadiusDamage(self, self, 20, self);
	self.origin = self.origin - 8 * normalize(self.velocity);
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord(MSG_BROADCAST, self.origin_x);
	WriteCoord(MSG_BROADCAST, self.origin_y);
	WriteCoord(MSG_BROADCAST, self.origin_z);
	if (!(other.health))
	{
		BecomeExplosion();
	}
	else
	{
		remove(self);
	}
};


void(float ofs, float turn) b_fire_rocket = 
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
	src = self.origin + '0 0 66' + v_right * ofs + v_forward * 84;
	targ = self.enemy.origin + self.enemy.view_ofs;
	if (skill != SKILL_EASY)
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
	//self.effects = self.effects | EF_MUZZLEFLASH; //b_fire_rocket is a ported, more general-purpose function, so this wasn't needed for the banshee
	sound(self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);
	missile = spawn();
	missile.owner = self;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX;
	missile.classname = "missile";
	missile.velocity = vec * 800;
	missile.angles = vectoangles(vec);
	missile.touch = Projectile_Hit;
	missile.nextthink = time + 5;
	missile.think = SUB_Remove;
	setmodel(missile, "progs/missile.mdl");
	setsize(missile, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(missile, src);
};





void(float angdelta, float delta) ban_rotate = 
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
			if (angdelta < -5)
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

void() banshee_think = 
{
	local float delta;
	local float angdelta;
	local float r;
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
	ban_rotate(angdelta, delta);
	if (self.health < 0)
	{
		return;
	}
	if (time > self.super_time && !(self.spawnflags & MONSTER_NOIDLESOUND && !self.enemy))
	{
		self.super_time = time + 3;
		if (random() < 0.5)
		{
			r = random();
			if (r < 0.25)
			{
				sound(self, CHAN_VOICE, "banshee/idle1.wav", 1, ATTN_NORM);
			}
			else
			{
				if (r < PROBE_VOLUME)
				{
					sound(self, CHAN_VOICE, "banshee/idle2.wav", 1, ATTN_NORM);
				}
				else
				{
					if (r < 0.75)
					{
						sound(self, CHAN_VOICE, "banshee/idle3.wav", 1, ATTN_NORM);
					}
					else
					{
						sound(self, CHAN_VOICE, "banshee/idle4.wav", 1, ATTN_NORM);
					}
				}
			}
		}
	}
};

void() ban_thinkwalk = 
{
	local float delta;
	local float angdelta;
	local entity client;
	local float r;
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
	ban_rotate(angdelta, delta);
	if (self.health < 0)
	{
		return;
	}
	if (time > self.super_time)
	{
		self.super_time = time + 3;
		if (random() < PROBE_VOLUME)
		{
			r = random();
			if (r < 0.25)
			{
				sound(self, CHAN_VOICE, "banshee/idle1.wav", 1, ATTN_BANSHEE);
			}
			else
			{
				if (r < PROBE_VOLUME)
				{
					sound(self, CHAN_VOICE, "banshee/idle2.wav", 1, ATTN_BANSHEE);
				}
				else
				{
					if (r < 0.75)
					{
						sound(self, CHAN_VOICE, "banshee/idle3.wav", 1, ATTN_BANSHEE);
					}
					else
					{
						sound(self, CHAN_VOICE, "banshee/idle4.wav", 1, ATTN_BANSHEE);
					}
				}
			}
		}
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

void() banshee_stand1 = [0, banshee_stand2]
{
	ai_stand();
	banshee_think();
	self.nextthink = time + 0.1;
};

void() banshee_stand2 = [1, banshee_stand3]
{
	banshee_think();
	self.nextthink = time + 0.2;
};

void() banshee_stand3 = [2, banshee_stand4]
{
	banshee_think();
	self.nextthink = time + 0.3;
};

void() banshee_stand4 = [3, banshee_stand5]
{
	banshee_think();
	self.nextthink = time + 0.3;
};

void() banshee_stand5 = [4, banshee_stand6]
{
	banshee_think();
	self.nextthink = time + 0.3;
};

void() banshee_stand6 = [5, banshee_stand7]
{
	banshee_think();
	self.nextthink = time + 0.2;
};

void() banshee_stand7 = [6, banshee_stand8]
{
	banshee_think();
	self.nextthink = time + 0.2;
};

void() banshee_stand8 = [7, banshee_stand9]
{
	banshee_think();
	self.nextthink = time + 0.2;
};

void() banshee_stand9 = [8, banshee_stand10]
{
	banshee_think();
	self.nextthink = time + 0.2;
};

void() banshee_stand10 = [9, banshee_stand11]
{
	ai_stand();
	banshee_think();
	self.nextthink = time + 0.2;
};

void() banshee_stand11 = [10, banshee_stand12]
{
	banshee_think();
	self.nextthink = time + 0.2;
};

void() banshee_stand12 = [11, banshee_stand13]
{
	banshee_think();
	self.nextthink = time + 0.2;
};

void() banshee_stand13 = [12, banshee_stand14]
{
	banshee_think();
	self.nextthink = time + 0.2;
};

void() banshee_stand14 = [13, banshee_stand15]
{
	banshee_think();
	self.nextthink = time + 0.2;
};

void() banshee_stand15 = [14, banshee_stand16]
{
	banshee_think();
	self.nextthink = time + 0.2;
};

void() banshee_stand16 = [15, banshee_stand17]
{
	banshee_think();
	self.nextthink = time + 0.2;
};

void() banshee_stand17 = [16, banshee_stand18]
{
	banshee_think();
	self.nextthink = time + 0.2;
};

void() banshee_stand18 = [17, banshee_stand19]
{
	banshee_think();
	self.nextthink = time + 0.2;
};

void() banshee_stand19 = [18, banshee_stand20]
{
	banshee_think();
	self.nextthink = time + 0.2;
};

void() banshee_stand20 = [19, banshee_stand1]
{
	ai_stand();
	banshee_think();
	self.nextthink = time + 0.2;
};

void() banshee_walk1 = [20, banshee_walk2]
{
	movetogoal(14);
	ban_thinkwalk();
};

void() banshee_walk2 = [21, banshee_walk3]
{
	movetogoal(14);
	ban_thinkwalk();
};

void() banshee_walk3 = [22, banshee_walk4]
{
	sound(self, TE_WIZSPIKE, "banshee/servo.wav", SERVO_VOLUME, ATTN_BANSHEE);
	movetogoal(14);
	ban_thinkwalk();
};

void() banshee_walk4 = [23, banshee_walk5]
{
	movetogoal(14);
	ban_thinkwalk();
};

void() banshee_walk5 = [24, banshee_walk6]
{
	sound(self, 6, "banshee/footfall.wav", 1, ATTN_BANSHEE);
	movetogoal(14);
	ban_thinkwalk();
};

void() banshee_walk6 = [25, banshee_walk7]
{
	movetogoal(14);
	ban_thinkwalk();
};

void() banshee_walk7 = [26, banshee_walk8]
{
	movetogoal(14);
	ban_thinkwalk();
};

void() banshee_walk8 = [27, banshee_walk9]
{
	movetogoal(14);
	ban_thinkwalk();
};

void() banshee_walk9 = [28, banshee_walk10]
{
	sound(self, 7, "banshee/servo.wav", SERVO_VOLUME, ATTN_BANSHEE);
	movetogoal(14);
	ban_thinkwalk();
};

void() banshee_walk10 = [29, banshee_walk11]
{
	movetogoal(14);
	ban_thinkwalk();
};

void() banshee_walk11 = [30, banshee_walk12]
{
	sound(self, 6, "banshee/footfall.wav", 1, ATTN_BANSHEE);
	movetogoal(14);
	ban_thinkwalk();
};

void() banshee_walk12 = [31, banshee_walk1]
{
	movetogoal(14);
	ban_thinkwalk();
};

void() banshee_run1 = [20, banshee_run2]
{
	ChangeYaw();
	
	ai_run(14);
	banshee_think();
};

void() banshee_run2 = [21, banshee_run3]
{
	ChangeYaw();
	
	ai_run(14);
	banshee_think();
};

void() banshee_run3 = [22, banshee_run4]
{
	sound(self, 7, "banshee/servo.wav", SERVO_VOLUME, ATTN_BANSHEE);
	ChangeYaw();
	
	ai_run(14);
	banshee_think();
};

void() banshee_run4 = [23, banshee_run5]
{
	ChangeYaw();
	
	ai_run(14);
	banshee_think();
};

void() banshee_run5 = [24, banshee_run6]
{
	sound(self, 6, "banshee/footfall.wav", 1, ATTN_BANSHEE);
	ChangeYaw();
	
	ai_run(14);
	banshee_think();
};

void() banshee_run6 = [25, banshee_run7]
{
	ChangeYaw();
	
	ai_run(14);
	banshee_think();
};

void() banshee_run7 = [26, banshee_run8]
{
	ChangeYaw();
	
	ai_run(14);
	banshee_think();
};

void() banshee_run8 = [27, banshee_run9]
{
	ChangeYaw();
	
	ai_run(14);
	banshee_think();
};

void() banshee_run9 = [28, banshee_run10]
{
	sound(self, TE_WIZSPIKE, "banshee/servo.wav", SERVO_VOLUME, ATTN_BANSHEE);
	ChangeYaw();
	
	ai_run(14);
	banshee_think();
};

void() banshee_run10 = [29, banshee_run11]
{
	ChangeYaw();
	
	ai_run(14);
	banshee_think();
};

void() banshee_run11 = [30, banshee_run12]
{
	sound(self, 6, "banshee/footfall.wav", 1, ATTN_BANSHEE);
	ChangeYaw();
	
	ai_run(14);
	banshee_think();
};

void() banshee_run12 = [31, banshee_run1]
{
	ChangeYaw();
	
	ai_run(14);
	banshee_think();
	if (self.lefty == 1)
	{
		self.lefty = 0;
		self.think = self.th_missile;
	}
};

void() ban_fire_walk1 = [44, ban_fire_walk2]
{
	ChangeYaw();
	walkmove(self.angles_y, 14);
	banshee_think();
};

void() ban_fire_walk2 = [45, ban_fire_walk3]
{
	sound(self, 7, "banshee/servo.wav", SERVO_VOLUME, ATTN_BANSHEE);
	ChangeYaw();
	walkmove(self.angles_y, 14);
	banshee_think();
};

void() ban_fire_walk3 = [46, ban_fire_walk4]
{
	ChangeYaw();
	walkmove(self.angles_y, 14);
	banshee_think();
};

void() ban_fire_walk4 = [47, ban_fire_walk5]
{
	sound(self, 6, "banshee/footfall.wav", 1, ATTN_BANSHEE);
	ChangeYaw();
	walkmove(self.angles_y, 14);
	banshee_think();
};

void() ban_fire_walk5 = [48, ban_fire_walk6]
{
	ChangeYaw();
	walkmove(self.angles_y, 14);
	banshee_think();
};

void() ban_fire_walk6 = [49, ban_fire_walk7]
{
	ChangeYaw();
	walkmove(self.angles_y, 14);
	banshee_think();
	b_fire_rocket(40, 0);
};

void() ban_fire_walk7 = [50, ban_fire_walk8]
{
	ChangeYaw();
	walkmove(self.angles_y, 14);
	banshee_think();
};

void() ban_fire_walk8 = [51, ban_fire_walk9]
{
	sound(self, TE_WIZSPIKE, "banshee/servo.wav", SERVO_VOLUME, ATTN_BANSHEE);
	ChangeYaw();
	walkmove(self.angles_y, 14);
	banshee_think();
};

void() ban_fire_walk9 = [52, ban_fire_walk10]
{
	ChangeYaw();
	walkmove(self.angles_y, 14);
	banshee_think();
};

void() ban_fire_walk10 = [53, ban_fire_walk11]
{
	sound(self, 6, "banshee/footfall.wav", 1, ATTN_BANSHEE);
	ChangeYaw();
	walkmove(self.angles_y, 14);
	banshee_think();
};

void() ban_fire_walk11 = [54, ban_fire_walk13]
{
	ChangeYaw();
	walkmove(self.angles_y, 14);
	banshee_think();
	b_fire_rocket(-40, 0);
};

void() ban_fire_walk13 = [55, banshee_run1]
{
	ChangeYaw();
	walkmove(self.angles_y, 14);
	banshee_think();
	SUB_AttackFinished(1);
};

void() ban_stomp1 = [75, ban_stomp2]
{
	ChangeYaw();
	walkmove(self.angles_y, 14);
	banshee_think();
};

void() ban_stomp2 = [76, ban_stomp3]
{
	sound(self, 7, "banshee/servo.wav", SERVO_VOLUME, ATTN_BANSHEE);
	ChangeYaw();
	walkmove(self.angles_y, 14);
	banshee_think();
};

void() ban_stomp3 = [77, ban_stomp4]
{
	ChangeYaw();
	walkmove(self.angles_y, 10);
	banshee_think();
};

void() ban_stomp4 = [78, ban_stomp5]
{
	banshee_think();
	ChangeYaw();
};

void() ban_stomp5 = [79, ban_stomp6]
{
	banshee_think();
};

void() ban_stomp6 = [80, ban_stomp7]
{
	ChangeYaw();
	ChangeYaw();
	sound(self, 6, "banshee/footfall.wav", 1, ATTN_BANSHEE);
	banshee_think();
	FuelTankExplode();
	T_RadiusDamage(self, self, 100, self);
};

void() ban_stomp7 = [81, ban_stomp8]
{
	banshee_think();
};

void() ban_stomp8 = [82, ban_stomp9]
{
	banshee_think();
};

void() ban_stomp9 = [83, ban_stomp10]
{
	banshee_think();
};

void() ban_stomp10 = [84, ban_stomp11]
{
	sound(self, 7, "banshee/servo.wav", SERVO_VOLUME, ATTN_BANSHEE);
	ChangeYaw();
	walkmove(self.angles_y, 14);
	banshee_think();
};

void() ban_stomp11 = [85, ban_stomp12]
{
	ChangeYaw();
	walkmove(self.angles_y, 14);
	banshee_think();
};

void() ban_stomp12 = [86, ban_stomp13]
{
	sound(self, 6, "banshee/footfall.wav", 1, ATTN_BANSHEE);
	ChangeYaw();
	walkmove(self.angles_y, 14);
	banshee_think();
};

void() ban_stomp13 = [87, ban_stomp14]
{
	ChangeYaw();
	walkmove(self.angles_y, 14);
	banshee_think();
};

void() ban_stomp14 = [88, ban_stomp15]
{
	ChangeYaw();
	walkmove(self.angles_y, 14);
	banshee_think();
};

void() ban_stomp15 = [89, banshee_run1]
{
	ChangeYaw();
	walkmove(self.angles_y, 14);
	banshee_think();
};

void() banshee_plant1 = [0, banshee_plant1]
{
	ban_fire_still();
	banshee_think();
};

void() banshee_stop1 = [57, banshee_stop2]
{
	banshee_think();
};

void() banshee_stop2 = [58, banshee_plant1]
{
	sound(self, 6, "banshee/footfall.wav", 1, ATTN_BANSHEE);
	banshee_think();
};

void() ban_launch_field1 = [32, ban_launch_field2]
{
	banshee_think();
};

void() ban_launch_field2 = [33, ban_launch_field3]
{
	banshee_think();
};

void() ban_launch_field3 = [34, ban_launch_field4]
{
	banshee_think();
};

void() ban_launch_field4 = [35, ban_launch_field5]
{
	banshee_think();
};

void() ban_launch_field5 = [36, ban_launch_field6]
{
	banshee_think();
};

void() ban_launch_field6 = [37, ban_launch_field7]
{
	sound(self, 6, "banshee/footfall.wav", 1, ATTN_BANSHEE);
	banshee_think();
};

void() ban_launch_field7 = [38, ban_launch_field8]
{
	banshee_think();
};

void() ban_launch_field8 = [39, ban_launch_field9]
{
	banshee_think();
};

void() ban_launch_field9 = [40, ban_launch_field10]
{
	banshee_think();
	b_fire_rocket(40, 0);
	b_fire_rocket(-40, 0);
};

void() ban_launch_field10 = [41, ban_launch_field11]
{
	banshee_think();
};

void() ban_launch_field11 = [42, ban_launch_field12]
{
	banshee_think();
};

void() ban_launch_field12 = [43, banshee_plant1]
{
	banshee_think();
	SUB_AttackFinished(0.3);
};

void() banshee_die1 = [57, banshee_die2]
{
	banshee_think();
	self.nextthink = time + 0.2;
	sound(self, CHAN_AUTO, "banshee/death.wav", 1, ATTN_NORM);
};

void() banshee_die2 = [58, banshee_die3]
{
	banshee_think();
	self.nextthink = time + 0.2;
};

void() banshee_die3 = [59, banshee_die4]
{
	banshee_think();
	self.nextthink = time + 0.2;
};

void() banshee_die4 = [60, banshee_die5]
{
	banshee_think();
	self.nextthink = time + 0.2;
};

void() banshee_die5 = [61, banshee_die6]
{
	banshee_think();
	self.nextthink = time + 0.2;
};

void() banshee_die6 = [62, banshee_die7]
{
	banshee_think();
	self.nextthink = time + 0.2;
};

void() banshee_die7 = [63, banshee_die8]
{
	banshee_think();
	self.nextthink = time + 0.2;
};

void() banshee_die8 = [64, banshee_die9]
{
	banshee_think();
	self.nextthink = time + 0.2;
};

void() banshee_die9 = [65, banshee_die10]
{
	banshee_think();
	self.nextthink = time + 0.2;
};

void() banshee_die10 = [66, banshee_die11]
{
	banshee_think();
	self.nextthink = time + 0.2;
};

void() banshee_die11 = [67, banshee_die12]
{
	banshee_think();
	self.nextthink = time + 0.2;
};

void() banshee_die12 = [68, banshee_die13]
{
	banshee_think();
	self.nextthink = time + 0.2;
};

void() banshee_die13 = [69, banshee_die14]
{
	banshee_think();
	self.nextthink = time + 0.2;
};

void() banshee_die14 = [70, banshee_die15]
{
	banshee_think();
	self.nextthink = time + 0.2;
};

void() banshee_die15 = [71, banshee_die16]
{
	banshee_think();
	self.nextthink = time + 0.1;
	sound(self, CHAN_WEAPON, "doors/airdoor2.wav", 1, ATTN_NORM);
	sound(self, CHAN_VOICE, "doors/drclos4.wav", 1, ATTN_NONE);
};

void() banshee_die16 = [72, banshee_die17]
{
	banshee_think();
	self.nextthink = time + 0.1;
};

void() banshee_die17 = [73, banshee_die18]
{
	banshee_think();
	self.nextthink = time + 0.1;
};

void() banshee_die18 = [74, banshee_die19]
{
	sound(self, CHAN_VOICE, "doors/drclos4.wav", 1, ATTN_NONE);
	banshee_think();
	self.nextthink = time + 0.1;
};

void() banshee_die19 = [74, banshee_die19]
{
self.solid = SOLID_NOT;
};

void(entity attacker, float damage) banshee_pain = 
{
	if (self.health <= 0)
	{
		return;
	}
	if (damage < 25)
	{
		return;
	}
	if (self.pain_finished > time)
	{
		return;
	}
	self.pain_finished = time + 2;
	sound(self, CHAN_VOICE, "banshee/pain.wav", 1, ATTN_NORM);
};

void() banshee_missile_attack = 
{
	local float n;
	n = random();
	if (n < 0.8)
	{
		ban_fire_walk1();
	}
	else
	{
		if (n < 1)
		{
			ban_launch_field1();
		}
		else
		{
			banshee_stop1();
		}
	}
};

void() banshee_repulse_attack = 
{
	local entity head;
	local vector dir;
	banshee_think();
	if (self.state == STATE_TOP) {
		SUB_AttackFinished(SERVO_VOLUME);
		sound(self, CHAN_BODY, "armagon/repel.wav", 1, ATTN_NORM);
		self.state = 1;
		return;
	}
	else if (self.state == STATE_BOTTOM) {
		head = findradius(self.origin, 300);
		while (head) {
			if (!(head.flags & FL_NOTARGET) && (head.flags & FL_CLIENT)) {
				if (visible(head) && head.health > 0) {
					dir = head.origin - (self.origin - '0 0 24');
					dir = normalize(dir);
					head.velocity = head.velocity + dir * 1500;
				}
			}
			head = head.chain;
		}
		T_RadiusDamage(self, self, 60, self);
		self.state = STATE_TOP;
		SUB_AttackFinished(0.1);
	}
	
};

void() ban_fire_still = 
{
	local vector spot1;
	local vector spot2;
	spot1 = self.origin + self.view_ofs;
	spot2 = self.enemy.origin + self.enemy.view_ofs;
	traceline(spot1, spot2, 0, self);
	if (trace_ent != self.enemy)
	{
		banshee_run1();
		return;
	}
	if (trace_inopen && trace_inwater)
	{
		banshee_run1();
		return;
	}
	if (time < self.attack_finished)
	{
		return;
	}
	if (vlen(spot2 - spot1) < 200 && self.enemy.classname == "player")
	{
		ban_stomp1();
		return;
	}
	self.state = STATE_TOP;
	if (vlen(spot2 - spot1) > 450)
	{
		banshee_run1();
		return;
	}
	ban_launch_field1();
	if (self.cnt == 1)
	{
		banshee_run1();
		return;
	}
	return;
};

float() BansheeCheckAttack = 
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
	if (trace_inopen && trace_inwater) {
		return 0;
	}
	if (time < self.attack_finished) {
		return 0;
	}
	ang = self.angles_y + self.fixangle;
	delta = self.ideal_yaw - ang;
	dist = vlen(spot2 - spot1);
	if (fabs(delta) > 10 && dist > 200 || self.enemy.classname != "player") {
		return 0;
	}
	if (dist < 400)	{
		self.th_melee();
		return 1;
	}
	self.lefty = 1;
	return 0;
};

void() monster_banshee = 
{
	local entity body;
	local float sk;
	if (!deathmatch) {
		self.lefty = 0;
		sk = cvar("skill");
		precache_model("progs/banbody.mdl");
		precache_model("progs/banlegs.mdl");
		precache_model("progs/d_explod.spr");
		precache_sound("banshee/footfall.wav");
		precache_sound("banshee/servo.wav");
		precache_sound("banshee/death.wav");
		precache_sound("banshee/pain.wav");
		precache_sound("banshee/sight.wav");
		precache_sound("banshee/sight2.wav");
		precache_sound("banshee/idle1.wav");
		precache_sound("banshee/idle2.wav");
		precache_sound("banshee/idle3.wav");
		precache_sound("banshee/idle4.wav");
		precache_sound("doors/airdoor2.wav");
		precache_sound("doors/drclos4.wav");
		precache_sound("weapons/fuelexp.wav");
		precache_sound("armagon/repel.wav");

		body = spawn();
		body.origin = self.origin;
		body.origin = body.origin - '0 0 64';
		body.solid = SOLID_NOT;
		body.movetype = MOVETYPE_STEP;
		body.trigger_field = self;
		if(!self.bloodtype) body.bloodtype = SPAWN_YELLOWSPARK;
		setmodel(body, "progs/banbody.mdl");
		setorigin(body, body.origin);

		self.classname = "monster_banshee";
		self.solid = SOLID_SLIDEBOX;
		self.fixangle = 0;
		self.movetype = MOVETYPE_STEP;
		self.trigger_field = body;
		if(!self.bloodtype) self.bloodtype = SPAWN_YELLOWSPARK;
		setmodel(self, "progs/banlegs.mdl");
		setsize(self, VEC_HULL2_MIN, VEC_HULL2_MAX);
		setorigin(self, self.origin);

		if (sk == SKILL_EASY) {
			self.yaw_speed = 5; //5
			self.health = 1300;
			self.worldtype = 0.9;
		}
		else if (sk == SKILL_NORMAL) {
			self.yaw_speed = 9; // 9
			self.health = 1300;
			self.worldtype = 0.85;
		}
		else {
			self.yaw_speed = 12; //12
			self.health = 1300;
			self.worldtype = 0.75;
		}
		
		//dealwithskill(); // Malice stuff, changes monster health depending on skill
		self.state = 0;
		self.super_time = 0;
		self.ltime = 0;
		self.th_stand = banshee_stand1;
		self.th_walk = banshee_walk1;
		self.th_run = banshee_run1;
		self.th_die = banshee_die1;
		self.th_missile = banshee_missile_attack;
		self.th_melee = ban_stomp1;
		self.th_pain = banshee_pain;
		walkmonster_start();
	}
	else {
		remove(self);
	}
};

