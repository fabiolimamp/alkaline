static string SPIDER_SOUND_WALK = "spiderbot/swalk.wav";
static string SPIDER_SOUND_ACTIVE = "spiderbot/sactiv.wav";
static string SPIDER_SOUND_CHARGE = "spiderbot/scharge.wav";

static string SPIDER_MODEL_BODY = "progs/spiderbot.mdl";
static string SPIDER_MODEL_GIB = "progs/spiderbot_gib.mdl";

void() spider_sactiv = {sound(self, CHAN_AUTO, SPIDER_SOUND_ACTIVE, 1, ATTN_NORM);};

void() spider_swalk = {sound(self, CHAN_BODY, SPIDER_SOUND_WALK, 1, ATTN_NORM);};

void() spider_scharge = {sound(self, CHAN_AUTO, SPIDER_SOUND_CHARGE, 1, ATTN_NORM);};

void() spider_sleep1 =	[21, spider_sleep2]		{FindTargetProximity();};
void() spider_sleep2 =	[20, spider_sleep3]		{FindTargetProximity();};
void() spider_sleep3 =	[19, spider_sleep4]		{FindTargetProximity();};
void() spider_sleep4 =	[18, spider_sleep5]		{FindTargetProximity();};
void() spider_sleep5 =	[18, spider_sleep1]		{FindTargetProximity();};

void() spider_stand1 =	[10, spider_stand1]		{
	FindTargetProximity();
	
	if (time > self.pausetime) {
		self.th_walk();
		return;
	}
};


void() spider_stand = {
	if (self.state) spider_sleep1();
	else spider_stand1();
};

void() spider_wake1 =	[0, spider_wake2]		{self.state = 0; };
void() spider_wake2 =	[1, spider_wake3]		{};
void() spider_wake3 =	[2, spider_wake4]		{};
void() spider_wake4 =	[3, spider_wake5]		{};
void() spider_wake5 =	[4, spider_wake6]		{};
void() spider_wake6 =	[5, spider_wake7]		{};
void() spider_wake7 =	[6, spider_wake8]		{};
void() spider_wake8 =	[7, spider_wake9]		{};
void() spider_wake9 =	[8, spider_wake10]		{};
void() spider_wake10 =	[9, spider_run1]		{HuntTarget();};

void() spider_walk1 =	[10, spider_walk2]		{self.state = 0; ai_walk(9); FindTargetProximity();};
void() spider_walk2 =	[11, spider_walk3]		{ai_walk(6); FindTargetProximity();};
void() spider_walk3 =	[12, spider_walk4]		{ai_walk(9); FindTargetProximity();};
void() spider_walk4 =	[13, spider_walk5]		{ai_walk(12); FindTargetProximity();};
void() spider_walk5 =	[14, spider_walk6]		{ai_walk(9); spider_swalk(); FindTargetProximity();};
void() spider_walk6 =	[15, spider_walk7]		{ai_walk(9); FindTargetProximity();};
void() spider_walk7 =	[16, spider_walk8]		{ai_walk(9); FindTargetProximity();};
void() spider_walk8 =	[17, spider_walk1]		{ai_walk(12); FindTargetProximity();};

void() spider_run1 =	[10, spider_run2]		{self.state = 0; ai_run(16*self.speed); spider_swalk();};
void() spider_run2 =	[11, spider_run3]		{ai_run(20*self.speed);};
void() spider_run3 =	[12, spider_run4]		{ai_run(16*self.speed);};
void() spider_run4 =	[13, spider_run5]		{ai_run(18*self.speed); spider_swalk();};
void() spider_run5 =	[14, spider_run6]		{ai_run(16*self.speed);};
void() spider_run6 =	[15, spider_run7]		{ai_run(20*self.speed);};
void() spider_run7 =	[16, spider_run8]		{ai_run(14*self.speed); spider_swalk();};
void() spider_run8 =	[17, spider_run1]		{ai_run(15*self.speed);};

void() spider_die2 = {
	T_RadiusDamage(self, self, 80, self, DMGTYPE_EXPLOSION);

	ThrowGib(SPIDER_MODEL_GIB, self.health - 40 - random() * 40);
	ThrowGib(SPIDER_MODEL_GIB, self.health - 40 - random() * 40);
	ThrowHead(SPIDER_MODEL_GIB, self.health - 40 - random() * 40);

	TriggerExplosion();
};

void() spider_die = {
	self.think = spider_die2;
	self.nextthink = time;
};

void() spider_blowup = {
	T_Damage(self, self, self, self.health, DMGTYPE_EXPLOSION);
};

void() spider_melee = {
	spider_scharge();
	self.nextthink = time + 0.6;
	self.think = spider_blowup;
};

void() spider_wake = {
	if (self.state) spider_wake1();
	else {
		HuntTarget();
		spider_run1();
	}
};

void() spider_sight = {
	spider_sactiv();
};

void(entity e) monster_spiderbot_start = {
	local entity oself;

	oself = self;
	self = e;

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	setmodel(self, SPIDER_MODEL_BODY);

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 0', '0 0 0');
	else setsize(self, self.cmins, self.cmaxs);

	if (!self.health) self.health = 40;
	if (!self.speed) self.speed = 1.2;
	if (self.obituary == "") self.obituary = "was blitzed by a Spiderbot";
	self.th_stand = spider_stand;
	self.th_walk = spider_walk1;
	self.th_run = spider_run1;
	self.th_melee = spider_melee;
	self.th_die = spider_die;

	if (!(self.spawnflags & 4)) self.state = 1; // sleeping

	self.th_sight = spider_sight;
	self.th_wake = spider_wake;
	walkmonster_start();

	self = oself;
};

void() monster_spiderbot_spawner = {
	monster_spawner(monster_spiderbot_start);
};

void() monster_spiderbot = {
	if (!SUB_InitEntity()) return;

	if (deathmatch)
	{
		remove(self);
		return;
	}

	precache_model(SPIDER_MODEL_GIB);
	precache_model(SPIDER_MODEL_BODY);
	precache_sound(SPIDER_SOUND_WALK);
	precache_sound(SPIDER_SOUND_ACTIVE);
	precache_sound(SPIDER_SOUND_CHARGE);

	self.cmins = '-16 -16 0';
	self.cmaxs = '16 16 24';

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 0', '0 0 0');
	else setsize(self, self.cmins, self.cmaxs);

	if (self.spawnflags & MONSTER_SPAWNER) {
		self.use = monster_spiderbot_spawner;
		monster_spawner_updatecounter();
	}
	else {
		monster_spiderbot_start(self);
	}
};
