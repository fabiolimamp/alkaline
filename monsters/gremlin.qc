/*
==============================================================================

gremlin

==============================================================================
*/

$frame stand1.asc stand2.asc stand3.asc stand4.asc stand5.asc stand6.asc
$frame stand7.asc stand8.asc stand9.asc stand10.asc stand11.asc stand12.asc
$frame stand13.asc stand14.asc stand15.asc stand16.asc stand17.asc

$frame walk1.asc walk2.asc walk3.asc walk4.asc walk5.asc walk6.asc
$frame walk7.asc walk8.asc walk9.asc walk10.asc walk11.asc walk12.asc

$frame run1.asc run2.asc run3.asc run4.asc run5.asc run6.asc run7.asc run8.asc
$frame run9.asc run10.asc run11.asc run12.asc run13.asc run14.asc run15.asc

$frame jump1.asc jump2.asc jump3.asc jump4.asc jump5.asc jump6.asc jump7.asc
$frame jump8.asc jump9.asc jump10.asc jump11.asc jump12.asc jump13.asc jump14.asc
$frame jump15.asc jump16.asc

$frame attk1.asc attk2.asc attk3.asc attk4.asc attk5.asc attk6.asc
$frame attk7.asc attk8.asc attk9.asc attk10.asc attk11.asc

$frame maul1.asc maul2.asc maul3.asc maul4.asc maul5.asc maul6.asc
$frame maul7.asc maul8.asc maul9.asc maul10.asc maul11.asc maul12.asc maul13.asc

$frame spawn1.asc spawn2.asc spawn3.asc spawn4.asc spawn5.asc spawn6.asc

$frame look1.asc look2.asc look3.asc look4.asc look5.asc look6.asc look7.asc
$frame look8.asc look9.asc look10.asc

$frame pain1.asc pain2.asc pain3.asc pain4.asc

$frame death1.asc death2.asc death3.asc death4.asc death5.asc death6.asc death7.asc
$frame death8.asc death9.asc death10.asc death11.asc death12.asc

$frame flip1.asc flip2.asc flip3.asc flip4.asc flip5.asc flip6.asc flip7.asc
$frame flip8.asc

$frame lunge1.asc lunge2.asc lunge3.asc lunge4.asc lunge5.asc lunge6.asc lunge7.asc
$frame lunge8.asc lunge9.asc lunge10.asc lunge11.asc

$frame gfire1.asc gfire2.asc gfire3.asc gfire4.asc gfire5.asc gfire6.asc

$frame glook1.asc glook2.asc glook3.asc glook4.asc glook5.asc glook6.asc glook7.asc
$frame glook8.asc glook9.asc glook10.asc glook11.asc glook12.asc glook13.asc 
$frame glook14.asc glook15.asc glook16.asc glook17.asc glook18.asc glook19.asc glook20.asc

$frame gpain1.asc gpain2.asc gpain3.asc

$frame grun1.asc grun2.asc grun3.asc grun4.asc grun5.asc grun6.asc grun7.asc
$frame grun8.asc grun9.asc grun10.asc grun11.asc grun12.asc grun13.asc grun14.asc grun15.asc

//============================================================================


/*
=============
gremlin_run

The monster has an enemy it is trying to kill
=============
*/
void(float dist) gremlin_run = {

	if (self.watertype == CONTENT_LAVA)
		T_Damage (self, world, world, 2000, DMGTYPE_LAVA);

	movedist = dist;
	ai_run(dist);
	
};

//============================================================================


void()   gremlin_stand1  =[ $stand1.asc, gremlin_stand2  ] {ai_stand();self.nextthink = time + 0.2;};
void()   gremlin_stand2  =[ $stand2.asc, gremlin_stand3  ] {ai_stand();self.nextthink = time + 0.2;};
void()   gremlin_stand3  =[ $stand3.asc, gremlin_stand4  ] {ai_stand();self.nextthink = time + 0.2;};
void()   gremlin_stand4  =[ $stand4.asc, gremlin_stand5  ] {ai_stand();self.nextthink = time + 0.2;};
void()   gremlin_stand5  =[ $stand5.asc, gremlin_stand6  ] {ai_stand();self.nextthink = time + 0.2;};
void()   gremlin_stand6  =[ $stand6.asc, gremlin_stand7  ] {ai_stand();self.nextthink = time + 0.2;};
void()   gremlin_stand7  =[ $stand7.asc, gremlin_stand8  ] {ai_stand();self.nextthink = time + 0.2;};
void()   gremlin_stand8  =[ $stand8.asc, gremlin_stand9  ] {ai_stand();self.nextthink = time + 0.2;};
void()   gremlin_stand9  =[ $stand9.asc, gremlin_stand10 ] {ai_stand();self.nextthink = time + 0.2;};
void()   gremlin_stand10 =[ $stand10.asc,   gremlin_stand11 ] {ai_stand();self.nextthink = time + 0.2;};
void()   gremlin_stand11 =[ $stand11.asc,   gremlin_stand12 ] {ai_stand();self.nextthink = time + 0.2;};
void()   gremlin_stand12 =[ $stand12.asc,   gremlin_stand13 ] {ai_stand();self.nextthink = time + 0.2;};
void()   gremlin_stand13 =[ $stand13.asc,   gremlin_stand14 ] {ai_stand();self.nextthink = time + 0.2;};
void()   gremlin_stand14 =[ $stand14.asc,   gremlin_stand15 ] {ai_stand();self.nextthink = time + 0.2;};
void()   gremlin_stand15 =[ $stand15.asc,   gremlin_stand16 ] {ai_stand();self.nextthink = time + 0.2;};
void()   gremlin_stand16 =[ $stand16.asc,   gremlin_stand17 ] {ai_stand();self.nextthink = time + 0.2;};
void()   gremlin_stand17 =[ $stand17.asc,   gremlin_stand1  ] {ai_stand();self.nextthink = time + 0.2;};

void()   gremlin_walk1 =[ $walk1.asc,      gremlin_walk2 ] {
//if (random() < 0.1) sound (self, CHAN_VOICE, "pinklin/idle.wav", 1, ATTN_IDLE);
ai_walk(8);};
void()   gremlin_walk2 =[ $walk2.asc,      gremlin_walk3 ] {ai_walk(8);};
void()   gremlin_walk3 =[ $walk3.asc,      gremlin_walk4 ] {ai_walk(8);};
void()   gremlin_walk4 =[ $walk4.asc,      gremlin_walk5 ] {ai_walk(8);};
void()   gremlin_walk5 =[ $walk5.asc,      gremlin_walk6 ] {ai_walk(8);};
void()   gremlin_walk6 =[ $walk6.asc,      gremlin_walk7 ] {ai_walk(8);};
void()   gremlin_walk7 =[ $walk7.asc,      gremlin_walk8 ] {ai_walk(8);};
void()   gremlin_walk8 =[ $walk8.asc,      gremlin_walk9 ] {ai_walk(8);};
void()   gremlin_walk9 =[ $walk9.asc,      gremlin_walk10 ] {ai_walk(8);};
void()   gremlin_walk10 =[ $walk10.asc,      gremlin_walk11 ] {ai_walk(8);};
void()   gremlin_walk11 =[ $walk11.asc,      gremlin_walk12 ] {ai_walk(8);};
void()   gremlin_walk12 =[ $walk12.asc,      gremlin_walk1 ] {ai_walk(8);};


float gremlinrunframe = 0.05;
void()   gremlin_run1 =[ $run1.asc,      gremlin_run2 ] {nxth(gremlinrunframe); gremlin_run(0);
//if (random() < 0.1) sound (self, CHAN_VOICE, "pinklin/idle.wav", 1, ATTN_IDLE);
};
void()   gremlin_run2 =[ $run2.asc,      gremlin_run3 ] {nxth(gremlinrunframe); gremlin_run(8);};
void()   gremlin_run3 =[ $run3.asc,      gremlin_run4 ] {nxth(gremlinrunframe); gremlin_run(13);};
void()   gremlin_run4 =[ $run4.asc,      gremlin_run5 ] {nxth(gremlinrunframe); gremlin_run(18);};
void()   gremlin_run5 =[ $run5.asc,      gremlin_run6 ] {nxth(gremlinrunframe); gremlin_run(18);};
void()   gremlin_run6 =[ $run6.asc,      gremlin_run7 ] {nxth(gremlinrunframe); gremlin_run(13);};
void()   gremlin_run7 =[ $run7.asc,      gremlin_run8 ] {nxth(gremlinrunframe); gremlin_run(8);};
void()   gremlin_run8 =[ $run8.asc,      gremlin_run9 ] {nxth(gremlinrunframe); gremlin_run(0);};
void()   gremlin_run9 =[ $run9.asc,      gremlin_run10 ] {nxth(gremlinrunframe); gremlin_run(8);};
void()   gremlin_run10 =[ $run10.asc,      gremlin_run11 ] {nxth(gremlinrunframe); gremlin_run(13);};
void()   gremlin_run11 =[ $run11.asc,      gremlin_run12 ] {nxth(gremlinrunframe); gremlin_run(18);};
void()   gremlin_run12 =[ $run12.asc,      gremlin_run13 ] {nxth(gremlinrunframe); gremlin_run(18);};
void()   gremlin_run13 =[ $run13.asc,      gremlin_run14 ] {nxth(gremlinrunframe); gremlin_run(13);};
void()   gremlin_run14 =[ $run14.asc,      gremlin_run15 ] {nxth(gremlinrunframe); gremlin_run(8);};
void()   gremlin_run15 =[ $run15.asc,      gremlin_run1 ] {nxth(gremlinrunframe); gremlin_run(0);};

void()   gremlin_jump1   =[ $jump1.asc,     gremlin_jump2   ] {ai_face();};
void()   gremlin_jump2   =[ $jump2.asc,     gremlin_jump3   ] {ai_face();};
void()   gremlin_jump3   =[ $jump3.asc,     gremlin_jump4   ] {ai_face();};
void()   gremlin_jump4   =[ $jump4.asc,     gremlin_jump5   ] {ai_face();};
void()   gremlin_jump5   =[ $jump5.asc,     gremlin_jump6   ] {
	ai_face();

	if (self.flags & FL_ONGROUND) {
		self.touch = Gremlin_JumpTouch;
		makevectors (self.angles);
		self.origin_z = self.origin_z + 1;
		self.velocity = v_forward * 300 + '0 0 300';
		self.flags = self.flags - FL_ONGROUND;
	}
	else {
		gremlin_run1();
	}
};
void()   gremlin_jump6   =[ $jump6.asc,     gremlin_jump7   ] {};
void()   gremlin_jump7   =[ $jump7.asc,     gremlin_jump8   ] {};
void()   gremlin_jump8   =[ $jump8.asc,     gremlin_jump9   ] {};
void()   gremlin_jump9   =[ $jump9.asc,     gremlin_jump10   ] {};
void()   gremlin_jump10   =[ $jump10.asc,     gremlin_jump11   ] {};
void()   gremlin_jump11   =[ $jump11.asc,     gremlin_jump1   ]
	{
	self.nextthink = time + 3;
	// if three seconds pass, assume gremlin is stuck and jump again
	};

void()   gremlin_jump12   =[ $jump12.asc,    gremlin_jump13  ] {};
void()   gremlin_jump13   =[ $jump13.asc,    gremlin_jump14  ] {};
void()   gremlin_jump14   =[ $jump14.asc,    gremlin_jump15  ] {};
void()   gremlin_jump15   =[ $jump15.asc,    gremlin_jump16  ] {};
void()   gremlin_jump16   =[ $jump16.asc,    gremlin_run1 ] {};

void()   gremlin_shot1 = [$gfire1.asc, gremlin_shot2   ] {self.effects = self.effects | EF_MUZZLEFLASH;};
void()   gremlin_shot2 = [$gfire2.asc, gremlin_shot3   ] {};
void()   gremlin_shot3 = [$gfire3.asc, gremlin_shot4   ] {};
void()   gremlin_shot4 = [$gfire4.asc, gremlin_shot5   ] {};
void()   gremlin_shot5 = [$gfire5.asc, gremlin_shot6   ] {};
void()   gremlin_shot6 = [$gfire6.asc, gremlin_run1   ] {};


//============================================================================


//============================================================================


float gremlinglungeframe = 0.1;
void()   gremlin_lunge1   =[ $lunge1.asc,     gremlin_lunge2   ] {nxth(gremlinglungeframe); ai_charge(0);};
void()   gremlin_lunge2   =[ $lunge2.asc,     gremlin_lunge3   ] {nxth(gremlinglungeframe); ai_charge(0);};
void()   gremlin_lunge3   =[ $lunge3.asc,     gremlin_lunge4   ] {nxth(gremlinglungeframe); ai_charge(0);};
void()   gremlin_lunge4   =[ $lunge4.asc,     gremlin_lunge5   ] {nxth(gremlinglungeframe); ai_charge(0);};
void()   gremlin_lunge5   =[ $lunge5.asc,     gremlin_lunge6   ] {nxth(gremlinglungeframe); ai_charge(0);};
void()   gremlin_lunge6   =[ $lunge6.asc,     gremlin_lunge7   ] {nxth(gremlinglungeframe); ai_charge(0);};
void()   gremlin_lunge7   =[ $lunge7.asc,     gremlin_lunge8   ] {nxth(gremlinglungeframe); ai_charge(15);};
void()   gremlin_lunge8   =[ $lunge8.asc,     gremlin_lunge9   ] {nxth(gremlinglungeframe); ai_charge(0);Gremlin_Melee(0);};
void()   gremlin_lunge9   =[ $lunge9.asc,     gremlin_lunge10] {ai_charge(0);};
void()   gremlin_lunge10  =[ $lunge10.asc,    gremlin_lunge11] {ai_charge(0);};
void()   gremlin_lunge11  =[ $lunge11.asc,    gremlin_run1] {ai_charge(0);};

float gremlingclawframe = 0.08;
void()   gremlin_claw1   =[ $attk1.asc,     gremlin_claw2   ] {nxth(gremlingclawframe); ai_charge(0);};
void()   gremlin_claw2   =[ $attk2.asc,     gremlin_claw3   ] {nxth(gremlingclawframe); ai_charge(0);};
void()   gremlin_claw3   =[ $attk3.asc,     gremlin_claw4   ] {nxth(gremlingclawframe); ai_charge(0);};
void()   gremlin_claw4   =[ $attk4.asc,     gremlin_claw5   ] {nxth(gremlingclawframe); ai_charge(0);};
void()   gremlin_claw5   =[ $attk5.asc,     gremlin_claw6   ] {nxth(gremlingclawframe); ai_charge(0);};
void()   gremlin_claw6   =[ $attk6.asc,     gremlin_claw7   ] {ai_charge(0);Gremlin_Melee(200);};
void()   gremlin_claw7   =[ $attk7.asc,     gremlin_claw8   ] {ai_charge(15);};
void()   gremlin_claw8   =[ $attk8.asc,     gremlin_claw9   ] {ai_charge(0);};
void()   gremlin_claw9   =[ $attk9.asc,     gremlin_claw10] {ai_charge(0);};
void()   gremlin_claw10  =[ $attk10.asc,    gremlin_claw11] {ai_charge(0);};
void()   gremlin_claw11  =[ $attk11.asc,    gremlin_run1] {ai_charge(0);};



void()   gremlin_look1   =[ $look1.asc,     gremlin_look2] {self.nextthink = time + 0.2;};
void()   gremlin_look2   =[ $look2.asc,     gremlin_look3] {self.nextthink = time + 0.2;};
void()   gremlin_look3   =[ $look3.asc,     gremlin_look4] {self.nextthink = time + 0.2;};
void()   gremlin_look4   =[ $look4.asc,     gremlin_look5] {self.nextthink = time + 0.2;};
void()   gremlin_look5   =[ $look5.asc,     gremlin_look6] {self.nextthink = time + 0.2;};
void()   gremlin_look6   =[ $look6.asc,     gremlin_look7] {self.nextthink = time + 0.2;};
void()   gremlin_look7   =[ $look7.asc,     gremlin_look8] {self.nextthink = time + 0.2;};
void()   gremlin_look8   =[ $look8.asc,     gremlin_look9] {self.nextthink = time + 0.2;};
void()   gremlin_look9   =[ $look9.asc,     gremlin_run1]
	{
	if (self.oldenemy.health > 0)
		{
		self.enemy = self.oldenemy;
		HuntTarget ();
		}
	else
		{
		if (self.movetarget)
			self.th_walk ();
		else
			self.th_stand ();
		}
	};


void()   gremlin_glook1   =[ $glook1.asc,     gremlin_glook2] {};
void()   gremlin_glook2   =[ $glook2.asc,     gremlin_glook3] {};
void()   gremlin_glook3   =[ $glook3.asc,     gremlin_glook4] {};
void()   gremlin_glook4   =[ $glook4.asc,     gremlin_glook5] {};
void()   gremlin_glook5   =[ $glook5.asc,     gremlin_glook6] {};
void()   gremlin_glook6   =[ $glook6.asc,     gremlin_glook7] {};
void()   gremlin_glook7   =[ $glook7.asc,     gremlin_glook8] {};
void()   gremlin_glook8   =[ $glook8.asc,     gremlin_glook9] {};
void()   gremlin_glook9   =[ $glook9.asc,     gremlin_glook10] {};
void()   gremlin_glook10   =[ $glook10.asc,     gremlin_glook11] {};
void()   gremlin_glook11   =[ $glook11.asc,     gremlin_glook12] {};
void()   gremlin_glook12   =[ $glook12.asc,     gremlin_glook13] {};
void()   gremlin_glook13   =[ $glook13.asc,     gremlin_glook14] {};
void()   gremlin_glook14   =[ $glook14.asc,     gremlin_glook15] {};
void()   gremlin_glook15   =[ $glook15.asc,     gremlin_glook16] {};
void()   gremlin_glook16   =[ $glook16.asc,     gremlin_glook17] {};
void()   gremlin_glook17   =[ $glook17.asc,     gremlin_glook18] {};
void()   gremlin_glook18   =[ $glook18.asc,     gremlin_glook19] {};
void()   gremlin_glook19   =[ $glook19.asc,     gremlin_glook20] {};
void()   gremlin_glook20   =[ $glook20.asc,     gremlin_glook20]
	{
	self.stoleweapon = FALSE;
	if (self.oldenemy.health > 0)
		{
		self.enemy = self.oldenemy;
		HuntTarget ();
		}
	else
		{
		if (self.movetarget)
			self.th_walk ();
		else
			self.th_stand ();
		}
	};

void()   gremlin_pain1   =[ $pain1.asc,     gremlin_pain2   ] {ai_back(4);};
void()   gremlin_pain2   =[ $pain2.asc,     gremlin_pain3   ] {ai_back(4);};
void()   gremlin_pain3   =[ $pain3.asc,     gremlin_pain4   ] {ai_back(2);};
void()   gremlin_pain4   =[ $pain4.asc,     gremlin_run1 ] {};

void()   gremlin_gunpain1   =[ $gpain1.asc,     gremlin_gunpain2   ] {ai_back(4);};
void()   gremlin_gunpain2   =[ $gpain2.asc,     gremlin_gunpain3   ] {ai_back(2);};
void()   gremlin_gunpain3   =[ $gpain3.asc,     gremlin_run1 ] {};

void(entity attacker, float damage) gremlin_pain =
{
	local float r;

	if (random()<0.8)
		{
		self.gorging = FALSE;
		self.enemy = attacker;
		FoundTarget();
		}
	if (self.touch == Gremlin_JumpTouch)
		return;

	if (self.pain_finished > time)
		return;

	self.pain_finished = time + 1;
//   if (random()<0.5)
//      sound (self, CHAN_VOICE, "pinklin/pain2.wav", 1, ATTN_NORM);
//   else
	r = random();
	
	sound (self, CHAN_VOICE, "pinklin/pinkpain.wav", 1, ATTN_NORM);
	
	if (self.stoleweapon)
		{
		gremlin_gunpain1 ();
		}
	else
		{
		gremlin_pain1 ();
		}
};


void()   gremlin_die1    =[ $death1.asc,    gremlin_die2 ] {
sound (self, CHAN_VOICE, "pinklin/pinkdeath.wav", 1, ATTN_NORM);};
void()   gremlin_die2    =[ $death2.asc,    gremlin_die3 ] {ai_forward(2);	self.solid = SOLID_TRIGGER;	setorigin(self, self.origin);};
void()   gremlin_die3    =[ $death3.asc,    gremlin_die4 ] {ai_forward(1);};
void()   gremlin_die4    =[ $death4.asc,    gremlin_die5 ] {ai_forward(2);};
void()   gremlin_die5    =[ $death5.asc,    gremlin_die6 ] {ai_forward(1);};
void()   gremlin_die6    =[ $death6.asc,    gremlin_die7 ] {};
void()   gremlin_die7    =[ $death7.asc,    gremlin_die8 ] {ai_forward(2);};
void()   gremlin_die8    =[ $death8.asc,    gremlin_die9 ] {ai_forward(1);};
void()   gremlin_die9    =[ $death9.asc,    gremlin_die10 ] {ai_forward(2);};
void()   gremlin_die10    =[ $death10.asc,    gremlin_die11 ] {ai_forward(1);};
void()   gremlin_die11    =[ $death11.asc,    gremlin_die12 ] {ai_forward(2);};
void()   gremlin_die12    =[ $death12.asc,    gremlin_die12 ] {monster_dead_dead();};

void() gremlin_gib =	{
	sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
	ThrowHead ("progs/h_pinklin.mdl", -35);
	ThrowGib ("progs/gib1.mdl", -35);
	ThrowGib ("progs/gib1.mdl", -35);
	ThrowGib ("progs/gib1.mdl", -35);
	self.deadflag = DEAD_GIBBED;
};


void()   gremlin_flip1    =[ $flip1.asc,    gremlin_flip2 ]	{
	ai_face();
	makevectors (self.angles);
	self.origin_z = self.origin_z + 1;
	self.velocity = '0 0 350' - (v_forward * 200);
	
	if (self.flags & FL_ONGROUND)
		self.flags = self.flags - FL_ONGROUND;

	sound (self, CHAN_VOICE, "pinklin/pinkdeath.wav", 1, ATTN_NORM);
};
void()   gremlin_flip2    =[ $flip2.asc,    gremlin_flip3 ] {ai_face();};
void()   gremlin_flip3    =[ $flip3.asc,    gremlin_flip4 ] {};
void()   gremlin_flip4    =[ $flip4.asc,    gremlin_flip5 ] {};
void()   gremlin_flip5    =[ $flip5.asc,    gremlin_flip6 ] {};
void()   gremlin_flip6    =[ $flip6.asc,    gremlin_flip7 ] {self.touch = Gremlin_FlipTouch;};
void()   gremlin_flip7    =[ $flip7.asc,    gremlin_gib ] {self.nextthink = time + 3;};
void()   gremlin_flip8    =[ $flip8.asc,    gremlin_flip8 ]	{self.solid = SOLID_TRIGGER; setorigin(self, self.origin);};

void()   Gremlin_FlipTouch = {

	if (!checkbottom(self))	{
		if (self.flags & FL_ONGROUND) {
			self.touch = SUB_Null;
			self.think = gremlin_flip1;
			self.nextthink = time + 0.1;
		}
		return;	// not on ground yet
	}

	self.touch = SUB_Null;
	self.think = gremlin_flip8;
	self.nextthink = time + 0.1;
};



void() gremlin_die =
{
	local vector   vec;
	local float		dot;

	makevectors (self.angles);
	vec = normalize (damage_attacker.origin - self.origin);
	dot = vec * v_forward;

	// check for gib
	if (self.health < -35) {
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_grem.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		self.deadflag = DEAD_GIBBED;
		return;
	}
	else if (dot>0.7 && (random()<0.5) && (self.flags & FL_ONGROUND)) {
		gremlin_flip1();
		return;
	}
// regular death
	gremlin_die1 ();
};



void() Gremlin_MeleeAttack = {
	local float num;
	
	num = random();
	if (num<0.3)
		gremlin_claw1 ();
		
	else if (num < 0.6)
		gremlin_lunge1 ();
		
	else
		gremlin_claw1 ();
			

};


/*
============
gremlin_recoil
============
*/
/*
void() gremlin_recoil =
	{
	self.nextthink = time + 0.1;
	self.flags = self.flags - FL_ONGROUND;
	if (vlen(self.velocity)<2)
		{
		self.movetype = self.spawnsolidtype;
		self.think = self.spawnthink;
		}
	};
*/
/*
============
GremlinRecoil
============
*/
/*
void(vector dir, float mag) GremlinRecoil =
	{
	self.spawnsolidtype = self.movetype;
	self.movetype = MOVETYPE_BOUNCE;
	self.spawnthink = self.think;
	self.think = gremlin_recoil;
	self.nextthink = time;
	self.velocity = mag * dir;
	self.velocity_z = self.velocity_z + 100;
	self.flags = self.flags - FL_ONGROUND;
	};
*/


/*
============
GremlinWeaponAttack

attack with a weapon
============
*/

void() Gremlin_MissileAttack =	{
	if (self.flags & FL_ONGROUND && random() < 0.2)
		gremlin_jump1();
};

//========================================================================================

void() gremlin_sight = {
	sound (self, CHAN_VOICE, "pinklin/pinksight.wav", 1, ATTN_NORM); //lunaran
};


void(entity e) monster_gremlin_start = {
	local entity oself;

	oself = self;
	self = e;
	
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/pinklin.mdl");

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize(self, self.cmins, self.cmaxs);
	
	self.health = 150;
	self.max_health = 150;
	self.yaw_speed = 40;

	if (self.obituary == "") self.obituary = "was outsmarted by a Gremlin";

	self.th_stand = gremlin_stand1;
	self.th_walk = gremlin_walk1;
	self.th_run = gremlin_run1;
	self.th_die = gremlin_die;
	self.th_melee = Gremlin_MeleeAttack;     // one of two attacks
	//self.th_missile = Gremlin_MissileAttack; // check for random jump or firing of weapon
	self.th_pain = gremlin_pain;
	self.th_sight = gremlin_sight;

	walkmonster_start();

	self = oself;
}

void() monster_gremlin_spawner = {
	monster_spawner(monster_gremlin_start);
};


/*QUAKED monster_gremlin (1 0 0) (-32 -32 -24) (32 32 64) Ambush

*/
void() monster_gremlin = {
	if (!SUB_InitEntity()) return;

	if (deathmatch) {
		remove(self);
		return;
	}
	
	precache_model ("progs/pinklin.mdl");
	precache_model ("progs/h_pinklin.mdl");

	precache_sound ("pinklin/pinkdeath.wav");
	precache_sound ("pinklin/pinkattack.wav");
	precache_sound ("demon/djump.wav");
	precache_sound ("demon/dhit2.wav");
	precache_sound ("pinklin/pinkpain.wav");
	precache_sound ("pinklin/pinksight.wav");

	self.cmins = VEC_HULL_MIN;
	self.cmaxs = VEC_HULL_MAX;

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize(self, self.cmins, self.cmaxs);
	
	if (self.spawnflags & MONSTER_SPAWNER) {
		self.use = monster_gremlin_spawner;
		monster_spawner_updatecounter();
	}
	else {
		monster_gremlin_start(self);
	}

};

float()  GremlinCheckAttack = {
	local vector	spot1, spot2;
	local entity	targ;
	

	targ = self.enemy;

	if (time < self.attack_finished)
		return FALSE;

// see if any entities are in the way of the shot
	spot1 = self.origin;// + self.view_ofs;
	spot2 = targ.origin;// + targ.view_ofs;

	if (vlen(spot2 - spot1) <= 90) {
		self.attack_state = AS_MELEE;
		return TRUE;
	}

// missile attack
	/*chance = 0.03 + self.stoleweapon;
	if (random() < chance) {
		self.attack_state = AS_MISSILE;
		return TRUE;
	}
*/
	return FALSE;
};


//===========================================================================

void(float side)  Gremlin_Melee =
{
	local	float	ldmg;
	local vector	delta;

	ai_face ();

//   walkmove (self.ideal_yaw, 12);   // allow a little closing


	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 100)
		return;
	if (!CanDamage (self.enemy, self.origin))
		return;

	 sound (self, CHAN_WEAPON, "pinklin/pinkattack.wav", 1, ATTN_NORM);
	ldmg = 10 + 5*random();
	T_Damage (self.enemy, self, self, ldmg, DMGTYPE_MELEE);

	makevectors (self.angles);
	SpawnMeatSpray (self.origin + v_forward*16, side * v_right);
};

//===========================================================================


void()   Gremlin_JumpTouch = {
	//local	float	ldmg;

	if (self.health <= 0)
		return;

/*
	if (other.takedamage)
	{
		if ( vlen(self.velocity) > 400 )
		{
			ldmg = 40 + 10*random();
			T_Damage (other, self, self, ldmg);
		}
	}
*/
	if (!checkbottom(self))
		{
		if (self.flags & FL_ONGROUND)
			{
			self.touch = SUB_Null;
			self.think = gremlin_jump1;
			self.nextthink = time + 0.1;
			}
		return;	// not on ground yet
		}

	self.touch = SUB_Null;
	self.think = gremlin_jump12;
	self.nextthink = time + 0.1;
};
