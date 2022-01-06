float M_TURRET_MAX_PITCH = 10;
float M_TURRET_MIN_PITCH = -30;

void() monster_turret_think;

void(vector ang) monster_turret_shoot = {
	self.trigger_field.effects = self.trigger_field.effects | EF_MUZZLEFLASH;
	//sound(self, CHAN_VOICE, "enforcer/enfire.wav", 1, ATTN_NORM);
	sound(self, CHAN_VOICE, "weapons/shotgn2.wav", 1, ATTN_NORM);
	
	makevectors(ang);
	//LaunchLaser(self.origin - v_up*14 + v_forward*56, v_forward); 
	//newmis.effects = newmis.effects - EF_DIMLIGHT;
	FireBullets2(1, self.origin - v_up*14 + v_forward*56, v_forward, '0.06 0.02 0');
};

void() monster_turret_fire = {
	self.nextthink = time + 0.1;
	self.think = monster_turret_fire;


	if (self.frame < 90) self.frame = 90;
	else if (self.frame >= 97) {
		if (self.cnt <= 0) {
			monster_turret_think();
			return;
		}
		else {
			self.frame = 90;
			self.cnt--;
		}
	}
	else self.frame++;

	//shoot if enemy is in sight (even if facing wrong way)
	//invert it because for some reason +pitch is downwards for makevectors() but upwards for vectoangles()
	if (self.frame % 2 == 1)
		monster_turret_shoot([0 - self.angles_x, self.angles_y, self.angles_z]);
};

void() monster_turret_think = {
	self.nextthink = time + 0.1;
	self.think = monster_turret_think;

	self.frame = 13;

	if (turret_findtarget() && time > self.attack_finished) {
	

		self.state = TURRET_STATE_ACTIVE;

		self.attack_finished = time + 3 + random()*1;
		self.cnt = 3;
		monster_turret_fire();
	}
};

void() monster_turret_helper_think = {
	self.nextthink = time + 0.04;

	entity oself;
	oself = self;
	self = self.owner;

	if (self.state != TURRET_STATE_ACTIVE)
		return;
		
	//turn towards enemy
	vector ang;
	ang = vectoangles(self.enemy.origin + self.enemy.view_ofs - self.origin);

	//calculate pitch based on the enemy's position, but clamp it to a narrow range
	if (ang_x > 180)
		ang_x = ang_x - 360;	
	if (ang_x > M_TURRET_MAX_PITCH)
		ang_x = M_TURRET_MAX_PITCH;
	if (ang_x < M_TURRET_MIN_PITCH)
		ang_x = M_TURRET_MIN_PITCH;
	
	self.ideal_yaw = ang_y;
	self.yaw_speed = 2;
	ChangeYaw();

	self.angles_x = ang_x;

};

void() monster_turret_die_think = {
	self.touch = BecomeExplosion;
};

void() monster_turret_die = {
	
	remove(self.trigger_field);

	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_TOSS;
	
	self.think = monster_turret_die_think;
	self.nextthink = time + 0.3;
	self.velocity = '0 0 -40';

	setorigin(self, self.origin);
};


void() monster_turret = {

	precache_model("progs/alkturret_main20f.mdl");
	precache_model("progs/alkturret_base.mdl");
	precache_model("progs/laser.mdl");
	precache_sound("enforcer/enfire.wav");

	self.health = 50;

	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_NONE;
	setorigin(self, self.origin + '0 0 14');
	setmodel(self, "progs/alkturret_main20f.mdl");
	setsize(self, '-16 -16 -16', '16 16 2');
	self.frame = 13;
	self.think = monster_turret_think;
	self.nextthink = time + 0.1;

	self.sibling = spawn();
	setmodel(self.sibling, "progs/alkturret_base.mdl");
	setorigin(self.sibling, self.origin - '0 0 12');
	setsize(self.sibling, VEC_ORIGIN, VEC_ORIGIN);


	self.trigger_field = spawn();
	self.trigger_field.owner = self;
	self.trigger_field.nextthink = 0.1;
	self.trigger_field.think = monster_turret_helper_think;
	self.trigger_field.classname = "turret";
	self.trigger_field.angles = self.angles;
	setmodel(self.trigger_field, "progs/misc_empty.mdl");
	setsize(self.sibling, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(self.trigger_field, self.origin);

	self.th_die = monster_turret_die;
	self.takedamage = DAMAGE_AIM;
	self.bloodtype = SPAWN_YELLOWSPARK;

	//self.state = TURRET_STATE_ACTIVE;
};