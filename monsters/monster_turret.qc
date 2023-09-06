float M_TURRET_MAX_PITCH = 30;
float M_TURRET_MIN_PITCH = -50;


float TURRET_IDLE_TIME = 3;
float TURRET_DEACTIVATE_TIME = 24;

float TURRET_DONTSLEEP = 1;

void(vector ang) monster_turret_shoot = {
	self.trigger_field.effects = self.trigger_field.effects | EF_MUZZLEFLASH;
	//sound(self, CHAN_VOICE, "enforcer/enfire.wav", 1, ATTN_NORM);
	sound(self, CHAN_VOICE, "weapons/shotgn2.wav", 1, ATTN_NORM);
	
	makevectors(ang);
	//LaunchLaser(self.origin - v_up*14 + v_forward*56, v_forward); 
	//newmis.effects = newmis.effects - EF_DIMLIGHT;
	FireBullets2(1, self.origin - v_up*14 + v_forward*56, v_forward, '0.1 0.04 0');
};


//returns true if existing enemy is still valid or we found a new valid enemy
float() monster_turret_findtarget =
{
	local entity	e;
	
	if (self.enemy != world)
		e = self.enemy;
	else //get a new enemy
	{
		e = checkclient ();
		if (!e)
			return FALSE;	// current check entity isn't in PVS
	}

	if (e.items & IT_INVISIBILITY)
		return FALSE;

	if (e.flags & FL_NOTARGET)
		return FALSE;

	if (range(e) == RANGE_FAR)
		return FALSE;
		
	if (!visible(e))
		return FALSE;

	if (e.takedamage == DAMAGE_NO)
		return FALSE;	
	
//
// got one
//
	self.enemy = e;
	if (self.enemy.classname != "player")
	{
		self.enemy = self.enemy.enemy;
		if (self.enemy.classname != "player")
		{
			self.enemy = world;
			return FALSE;
		}
	}
		
	return TRUE;
};

void() monster_turret_shoot_think = {
	self.nextthink = time + 0.1;
	self.think = monster_turret_shoot_think;

	// time since last attack
	self.air_finished = time;

	if (self.frame < 14) self.frame = 14;
	else if (self.frame >= 21) {
		if (self.cnt <= 0) {
			monster_turret_active_think();
			return;
		}
		else {
			self.frame = 14;
			self.cnt--;
		}
	}
	else self.frame++;

	//shoot if enemy is in sight (even if facing wrong way)
	//invert it because for some reason +pitch is downwards for makevectors() but upwards for vectoangles()
	if (self.frame % 2 == 0)
		monster_turret_shoot([0 - self.angles_x, self.angles_y, self.angles_z]);
};

/*void() monster_turret_idle = {
	if (self.frame < 14 || self.frame > 88) self.frame = 14;
	else self.frame++;
};*/

void() monster_turret_deploy_think = {
	self.nextthink = time + 0.1;
	self.think = monster_turret_deploy_think;

	if (self.frame < 2 || self.frame > 12) {
		self.frame = 2;
		sound(self, CHAN_VOICE, "turret/deploy2.wav", 1, ATTN_NORM);
	}
	else self.frame++;

	self.sibling.frame = self.frame;

	if (self.frame == 12) {
		self.state = TURRET_STATE_IDLE;
		self.think = monster_turret_active_think;
	}
};

void() monster_turret_disable_think = {
	self.nextthink = time + 0.1;
	self.think = monster_turret_disable_think;

	if (self.angles_x) return;

	if (self.frame > 12) {
		self.frame = 12;
		sound(self, CHAN_VOICE, "turret/disable.wav", 1, ATTN_NORM);
	}
	else self.frame--;

	self.sibling.frame = self.frame;

	if (self.frame == 0) {
		self.state = TURRET_STATE_INACTIVE;
		self.think = monster_turret_inactive_think;
	}
};

void() monster_turret_inactive_think = {
	if (self.targetname != "")
		return;

	self.nextthink = time + 0.1;
	self.think = monster_turret_inactive_think;
	


	if (monster_turret_findtarget()) {
		if (vlen(self.enemy.origin - self.origin) < 512){
			setsize(self, '-16 -16 -16', '16 16 2');
			monster_turret_deploy_think();
		}
	}
};

void() monster_turret_active_think = {
	self.nextthink = time + 0.1;
	self.think = monster_turret_active_think;
	self.frame = 13;

	if (monster_turret_findtarget() && time > self.attack_finished) {

		self.state = TURRET_STATE_ACTIVE;

		self.attack_finished = time + 3 + random()*1;
		self.cnt = 3;
		monster_turret_shoot_think();
		return;
	}

	if (time > self.air_finished + TURRET_IDLE_TIME && self.state != TURRET_STATE_IDLE) {
		self.old_angles = self.angles;
		self.state = TURRET_STATE_IDLE;
		sound(self, CHAN_VOICE, "turret/idle.wav", 1, ATTN_NORM);
		self.pain_finished = time + 3;
		//monster_turret_idle();
		return;
	}

	if (time > self.air_finished + TURRET_DEACTIVATE_TIME && !(self.spawnflags & TURRET_DONTSLEEP)) {
		self.state = TURRET_STATE_DEACTIVATING;
		setsize(self, '-16 -16 -8', '16 16 2');
		monster_turret_disable_think();
		return;
	}

	if (self.state == TURRET_STATE_IDLE) {
		if (time > self.pain_finished) {
			sound(self, CHAN_VOICE, "turret/beep.wav", 0.7, ATTN_NORM);
			self.pain_finished = time + 2;
		}
		return;
	}
};

//---------------------------------------------------------------------------------------------------------

void() monster_turret_helper_think = {

	if (self.owner.trigger_field != self) {
		remove(self);
		return;
	}

	self.nextthink = time + 0.025;

	entity oself;
	oself = self;
	self = self.owner;

	vector ang;

	if (self.state == TURRET_STATE_IDLE) {
		float addang;
		ang = self.angles;
		addang = cos((time - self.air_finished + TURRET_IDLE_TIME) * 15)*45;
		ang_y = self.old_angles_y + addang;
		ang_x = 0;
	}
	else if (self.state == TURRET_STATE_ACTIVE) {
		//turn towards enemy
		ang = vectoangles(self.enemy.origin + self.enemy.view_ofs - self.origin);

	}
	/*else if (self.state == TURRET_STATE_DEACTIVATING){
		ang = self.angles;
		ang_x = 0;
	}*/
	else
		return;
		
	ang_x = anglemod180(ang_x);

	// clamp pitch to a narrow range
	if (ang_x > M_TURRET_MAX_PITCH)
		ang_x = M_TURRET_MAX_PITCH;
	if (ang_x < M_TURRET_MIN_PITCH)
		ang_x = M_TURRET_MIN_PITCH;
	
	self.ideal_yaw = ang_y;
	self.yaw_speed = 1.5;
	ChangeYaw();

	self.angles_x = self.angles_x + clamp(ang_x - self.angles_x, -1.5, 1.5);

};

//---------------------------------------------------------------------------------------------------------



void() monster_turret_die_explode = {
	self.cnt = 4;

	self.touch = SUB_Null;
	float i, r;
	i = 0;
	
	entity new;
	
	for (i = 0; i < 6; i++) {
		new = spawn();
		setorigin(new, self.origin);
		setmodel(new, "progs/debris.mdl");
		setsize(new, '0 0 0', '0 0 0');
		new.movetype = MOVETYPE_BOUNCE;
		new.solid = SOLID_NOT;

		new.velocity_x = 200*crandom();
		new.velocity_y = 200*crandom();
		new.velocity_z = 200*random() + 100;
		
		new.avelocity_x = random()*600;
		new.avelocity_y = random()*600;
		new.avelocity_z = random()*600;
		
		new.think = SUB_Remove;
		new.nextthink = time + 10 + random()*10;

		r = random();
		if (r > 0.5)
			new.frame = 0; //small 1
		else
			new.frame = 2; //small 2
	}

	BecomeExplosion();
}

void() monster_turret_die_think = {
	// in case it has already fallen on something, the touch function won't run properly
	if (self.velocity == '0 0 0')
		monster_turret_die_explode();
	else
		self.touch = monster_turret_die_explode;
};

void() monster_turret_die = {
	
	remove(self.trigger_field);

	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_TOSS;

	self.sibling.frame = 0;
	if (self.frame > 13) self.frame = 13;
	
	self.think = monster_turret_die_think;
	self.nextthink = time + 0.3;
	self.velocity = '0 0 -40';

	setsize(self, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(self, self.origin);
	

	activator = self.enemy;
	SUB_UseTargets();

};

//---------------------------------------------------------------------------------------------------------

void() monster_turret_use = {
	//dprint3("Used turret. State: ", ftos(self.state), "\n");
	if (self.state == TURRET_STATE_INACTIVE) {
		setsize(self, '-16 -16 -16', '16 16 2');
		self.old_angles = self.angles;
		monster_turret_deploy_think();
	}
};

//---------------------------------------------------------------------------------------------------------


void() monster_turret = {

	if (!SUB_InitEntity()) return;
	
	precache_model("progs/alkturret_main_v2.mdl");
	precache_model("progs/alkturret_base_v2.mdl");
	precache_model("progs/laser.mdl");
	precache_model("progs/debris.mdl");
	precache_sound("enforcer/enfire.wav");
	precache_sound("turret/deploy2.wav");
	precache_sound("turret/disable.wav");
	precache_sound("turret/idle.wav");
	precache_sound("turret/beep.wav");

	self.health = 50;

	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_NONE;

	setorigin(self, self.origin);
	setmodel(self, "progs/alkturret_main_v2.mdl");
	setsize(self, '-16 -16 -8', '16 16 2');
	
	self.frame = 0;
	self.think = monster_turret_inactive_think;
	self.nextthink = time + 0.1;

	self.sibling = spawn();

	setorigin(self.sibling, self.origin);
	setmodel(self.sibling, "progs/alkturret_base_v2.mdl");
	setsize(self.sibling, VEC_ORIGIN, VEC_ORIGIN);


	self.trigger_field = spawn();
	self.trigger_field.owner = self;
	self.trigger_field.nextthink = 0.025;
	self.trigger_field.think = monster_turret_helper_think;
	self.trigger_field.classname = "turret";
	self.trigger_field.angles = self.angles;

	setorigin(self.trigger_field, self.origin);
	setmodel(self.trigger_field, "progs/misc_empty.mdl");
	setsize(self.trigger_field, VEC_ORIGIN, VEC_ORIGIN);
	
	self.use = monster_turret_use;
	self.th_die = monster_turret_die;
	self.takedamage = DAMAGE_AIM;
	self.bloodtype = SPAWN_YELLOWSPARK;

	if (self.spawnflags & TURRET_DONTSLEEP && self.targetname == "") {
		setsize(self, '-16 -16 -16', '16 16 2');
		self.frame = 13;
		self.sibling.frame = 13;
		self.state = TURRET_STATE_IDLE;
		self.old_angles = self.angles;
		self.think = monster_turret_active_think;
	}

	//self.state = TURRET_STATE_ACTIVE;
};