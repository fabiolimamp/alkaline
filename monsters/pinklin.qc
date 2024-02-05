/*
==============================================================================

pinklin

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
pinklin_run

The monster has an enemy it is trying to kill
=============
*/
void(float dist) pinklin_run = {

	if (self.watertype == CONTENT_LAVA)
		T_Damage (self, world, world, 2000, DMGTYPE_LAVA);

	ai_run(dist);
	
};

//============================================================================


void()   pinklin_stand1  =[ $stand1.asc, pinklin_stand2  ] {ai_stand();self.nextthink = time + 0.2;};
void()   pinklin_stand2  =[ $stand2.asc, pinklin_stand3  ] {ai_stand();self.nextthink = time + 0.2;};
void()   pinklin_stand3  =[ $stand3.asc, pinklin_stand4  ] {ai_stand();self.nextthink = time + 0.2;};
void()   pinklin_stand4  =[ $stand4.asc, pinklin_stand5  ] {ai_stand();self.nextthink = time + 0.2;};
void()   pinklin_stand5  =[ $stand5.asc, pinklin_stand6  ] {ai_stand();self.nextthink = time + 0.2;};
void()   pinklin_stand6  =[ $stand6.asc, pinklin_stand7  ] {ai_stand();self.nextthink = time + 0.2;};
void()   pinklin_stand7  =[ $stand7.asc, pinklin_stand8  ] {ai_stand();self.nextthink = time + 0.2;};
void()   pinklin_stand8  =[ $stand8.asc, pinklin_stand9  ] {ai_stand();self.nextthink = time + 0.2;};
void()   pinklin_stand9  =[ $stand9.asc, pinklin_stand10 ] {ai_stand();self.nextthink = time + 0.2;};
void()   pinklin_stand10 =[ $stand10.asc,   pinklin_stand11 ] {ai_stand();self.nextthink = time + 0.2;};
void()   pinklin_stand11 =[ $stand11.asc,   pinklin_stand12 ] {ai_stand();self.nextthink = time + 0.2;};
void()   pinklin_stand12 =[ $stand12.asc,   pinklin_stand13 ] {ai_stand();self.nextthink = time + 0.2;};
void()   pinklin_stand13 =[ $stand13.asc,   pinklin_stand14 ] {ai_stand();self.nextthink = time + 0.2;};
void()   pinklin_stand14 =[ $stand14.asc,   pinklin_stand15 ] {ai_stand();self.nextthink = time + 0.2;};
void()   pinklin_stand15 =[ $stand15.asc,   pinklin_stand16 ] {ai_stand();self.nextthink = time + 0.2;};
void()   pinklin_stand16 =[ $stand16.asc,   pinklin_stand17 ] {ai_stand();self.nextthink = time + 0.2;};
void()   pinklin_stand17 =[ $stand17.asc,   pinklin_stand1  ] {ai_stand();self.nextthink = time + 0.2;};

void(float chance) pinklin_idlesound = {
	if (time < self.air_finished)
		return;

	if (random() < chance) 
		return;

	sound (self, CHAN_VOICE, "pinklin/pinkidle1.wav", 1, ATTN_IDLE);
	self.air_finished = time + 2 + random();
}

void()   pinklin_walk1 =[ $walk1.asc,      pinklin_walk2 ] {
	pinklin_idlesound(0.05);
	ai_walk(8);
};
void()   pinklin_walk2 =[ $walk2.asc,      pinklin_walk3 ] {ai_walk(8);};
void()   pinklin_walk3 =[ $walk3.asc,      pinklin_walk4 ] {ai_walk(8);};
void()   pinklin_walk4 =[ $walk4.asc,      pinklin_walk5 ] {ai_walk(8);};
void()   pinklin_walk5 =[ $walk5.asc,      pinklin_walk6 ] {ai_walk(8);};
void()   pinklin_walk6 =[ $walk6.asc,      pinklin_walk7 ] {ai_walk(8);};
void()   pinklin_walk7 =[ $walk7.asc,      pinklin_walk8 ] {ai_walk(8);};
void()   pinklin_walk8 =[ $walk8.asc,      pinklin_walk9 ] {ai_walk(8);};
void()   pinklin_walk9 =[ $walk9.asc,      pinklin_walk10 ] {ai_walk(8);};
void()   pinklin_walk10 =[ $walk10.asc,      pinklin_walk11 ] {ai_walk(8);};
void()   pinklin_walk11 =[ $walk11.asc,      pinklin_walk12 ] {ai_walk(8);};
void()   pinklin_walk12 =[ $walk12.asc,      pinklin_walk1 ] {ai_walk(8);};



float pinklinrunframe = 0.05;
void()   pinklin_run1 =[ $run1.asc,      pinklin_run2 ] {
	nxth(pinklinrunframe);
	pinklin_idlesound(0.1);
	pinklin_run(0);
};
void()   pinklin_run2 =[ $run2.asc,      pinklin_run3 ] {nxth(pinklinrunframe); pinklin_run(8);};
void()   pinklin_run3 =[ $run3.asc,      pinklin_run4 ] {nxth(pinklinrunframe); pinklin_run(13);};
void()   pinklin_run4 =[ $run4.asc,      pinklin_run5 ] {nxth(pinklinrunframe); pinklin_run(18);};
void()   pinklin_run5 =[ $run5.asc,      pinklin_run6 ] {nxth(pinklinrunframe); pinklin_run(18);};
void()   pinklin_run6 =[ $run6.asc,      pinklin_run7 ] {nxth(pinklinrunframe); pinklin_run(13);};
void()   pinklin_run7 =[ $run7.asc,      pinklin_run8 ] {nxth(pinklinrunframe); pinklin_run(8);};
void()   pinklin_run8 =[ $run8.asc,      pinklin_run9 ] {nxth(pinklinrunframe); pinklin_run(0);};
void()   pinklin_run9 =[ $run9.asc,      pinklin_run10 ] {nxth(pinklinrunframe); pinklin_run(8);};
void()   pinklin_run10 =[ $run10.asc,      pinklin_run11 ] {nxth(pinklinrunframe); pinklin_run(13);};
void()   pinklin_run11 =[ $run11.asc,      pinklin_run12 ] {nxth(pinklinrunframe); pinklin_run(18);};
void()   pinklin_run12 =[ $run12.asc,      pinklin_run13 ] {nxth(pinklinrunframe); pinklin_run(18);};
void()   pinklin_run13 =[ $run13.asc,      pinklin_run14 ] {nxth(pinklinrunframe); pinklin_run(13);};
void()   pinklin_run14 =[ $run14.asc,      pinklin_run15 ] {nxth(pinklinrunframe); pinklin_run(8);};
void()   pinklin_run15 =[ $run15.asc,      pinklin_run1 ] {nxth(pinklinrunframe); pinklin_run(0);};

void()   pinklin_jump1   =[ $jump1.asc,     pinklin_jump2   ] {ai_face();};
void()   pinklin_jump2   =[ $jump2.asc,     pinklin_jump3   ] {ai_face();};
void()   pinklin_jump3   =[ $jump3.asc,     pinklin_jump4   ] {ai_face();};
void()   pinklin_jump4   =[ $jump4.asc,     pinklin_jump5   ] {ai_face();};
void()   pinklin_jump5   =[ $jump5.asc,     pinklin_jump6   ] {
	ai_face();

	if (self.flags & FL_ONGROUND) {
		self.touch = Pinklin_JumpTouch;
		makevectors (self.angles);
		self.origin_z = self.origin_z + 1;
		self.velocity = v_forward * 300 + '0 0 300';
		self.flags = self.flags - FL_ONGROUND;
	}
	else {
		pinklin_run1();
	}
};
void()   pinklin_jump6   =[ $jump6.asc,     pinklin_jump7   ] {};
void()   pinklin_jump7   =[ $jump7.asc,     pinklin_jump8   ] {};
void()   pinklin_jump8   =[ $jump8.asc,     pinklin_jump9   ] {};
void()   pinklin_jump9   =[ $jump9.asc,     pinklin_jump10   ] {};
void()   pinklin_jump10   =[ $jump10.asc,     pinklin_jump11   ] {};
void()   pinklin_jump11   =[ $jump11.asc,     pinklin_jump1   ]
	{
	self.nextthink = time + 3;
	// if three seconds pass, assume pinklin is stuck and jump again
	};

void()   pinklin_jump12   =[ $jump12.asc,    pinklin_jump13  ] {};
void()   pinklin_jump13   =[ $jump13.asc,    pinklin_jump14  ] {};
void()   pinklin_jump14   =[ $jump14.asc,    pinklin_jump15  ] {};
void()   pinklin_jump15   =[ $jump15.asc,    pinklin_jump16  ] {};
void()   pinklin_jump16   =[ $jump16.asc,    pinklin_run1 ] {};

void()   pinklin_shot1 = [$gfire1.asc, pinklin_shot2   ] {self.effects = self.effects | EF_MUZZLEFLASH;};
void()   pinklin_shot2 = [$gfire2.asc, pinklin_shot3   ] {};
void()   pinklin_shot3 = [$gfire3.asc, pinklin_shot4   ] {};
void()   pinklin_shot4 = [$gfire4.asc, pinklin_shot5   ] {};
void()   pinklin_shot5 = [$gfire5.asc, pinklin_shot6   ] {};
void()   pinklin_shot6 = [$gfire6.asc, pinklin_run1   ] {};


//============================================================================


//============================================================================


float pinklinglungeframe = 0.1;
void()   pinklin_lunge1   =[ $lunge1.asc,     pinklin_lunge2   ] {nxth(pinklinglungeframe); ai_charge(0);};
void()   pinklin_lunge2   =[ $lunge2.asc,     pinklin_lunge3   ] {nxth(pinklinglungeframe); ai_charge(0);};
void()   pinklin_lunge3   =[ $lunge3.asc,     pinklin_lunge4   ] {nxth(pinklinglungeframe); ai_charge(0);};
void()   pinklin_lunge4   =[ $lunge4.asc,     pinklin_lunge5   ] {nxth(pinklinglungeframe); ai_charge(0);};
void()   pinklin_lunge5   =[ $lunge5.asc,     pinklin_lunge6   ] {nxth(pinklinglungeframe); ai_charge(0);};
void()   pinklin_lunge6   =[ $lunge6.asc,     pinklin_lunge7   ] {nxth(pinklinglungeframe); ai_charge(0);};
void()   pinklin_lunge7   =[ $lunge7.asc,     pinklin_lunge8   ] {nxth(pinklinglungeframe); ai_charge(15);};
void()   pinklin_lunge8   =[ $lunge8.asc,     pinklin_lunge9   ] {nxth(pinklinglungeframe); ai_charge(0);Pinklin_Melee(0);};
void()   pinklin_lunge9   =[ $lunge9.asc,     pinklin_lunge10] {ai_charge(0);};
void()   pinklin_lunge10  =[ $lunge10.asc,    pinklin_lunge11] {ai_charge(0);};
void()   pinklin_lunge11  =[ $lunge11.asc,    pinklin_run1] {ai_charge(0);};

float pinklingclawframe = 0.08;
void()   pinklin_claw1   =[ $attk1.asc,     pinklin_claw2   ] {nxth(pinklingclawframe); ai_charge(0);};
void()   pinklin_claw2   =[ $attk2.asc,     pinklin_claw3   ] {nxth(pinklingclawframe); ai_charge(0);};
void()   pinklin_claw3   =[ $attk3.asc,     pinklin_claw4   ] {nxth(pinklingclawframe); ai_charge(0);};
void()   pinklin_claw4   =[ $attk4.asc,     pinklin_claw5   ] {nxth(pinklingclawframe); ai_charge(0);};
void()   pinklin_claw5   =[ $attk5.asc,     pinklin_claw6   ] {nxth(pinklingclawframe); ai_charge(0);};
void()   pinklin_claw6   =[ $attk6.asc,     pinklin_claw7   ] {ai_charge(0);Pinklin_Melee(200);};
void()   pinklin_claw7   =[ $attk7.asc,     pinklin_claw8   ] {ai_charge(15);};
void()   pinklin_claw8   =[ $attk8.asc,     pinklin_claw9   ] {ai_charge(0);};
void()   pinklin_claw9   =[ $attk9.asc,     pinklin_claw10] {ai_charge(0);};
void()   pinklin_claw10  =[ $attk10.asc,    pinklin_claw11] {ai_charge(0);};
void()   pinklin_claw11  =[ $attk11.asc,    pinklin_run1] {ai_charge(0);};



void()   pinklin_look1   =[ $look1.asc,     pinklin_look2] {self.nextthink = time + 0.2;};
void()   pinklin_look2   =[ $look2.asc,     pinklin_look3] {self.nextthink = time + 0.2;};
void()   pinklin_look3   =[ $look3.asc,     pinklin_look4] {self.nextthink = time + 0.2;};
void()   pinklin_look4   =[ $look4.asc,     pinklin_look5] {self.nextthink = time + 0.2;};
void()   pinklin_look5   =[ $look5.asc,     pinklin_look6] {self.nextthink = time + 0.2;};
void()   pinklin_look6   =[ $look6.asc,     pinklin_look7] {self.nextthink = time + 0.2;};
void()   pinklin_look7   =[ $look7.asc,     pinklin_look8] {self.nextthink = time + 0.2;};
void()   pinklin_look8   =[ $look8.asc,     pinklin_look9] {self.nextthink = time + 0.2;};
void()   pinklin_look9   =[ $look9.asc,     pinklin_run1]
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


void()   pinklin_glook1   =[ $glook1.asc,     pinklin_glook2] {};
void()   pinklin_glook2   =[ $glook2.asc,     pinklin_glook3] {};
void()   pinklin_glook3   =[ $glook3.asc,     pinklin_glook4] {};
void()   pinklin_glook4   =[ $glook4.asc,     pinklin_glook5] {};
void()   pinklin_glook5   =[ $glook5.asc,     pinklin_glook6] {};
void()   pinklin_glook6   =[ $glook6.asc,     pinklin_glook7] {};
void()   pinklin_glook7   =[ $glook7.asc,     pinklin_glook8] {};
void()   pinklin_glook8   =[ $glook8.asc,     pinklin_glook9] {};
void()   pinklin_glook9   =[ $glook9.asc,     pinklin_glook10] {};
void()   pinklin_glook10   =[ $glook10.asc,     pinklin_glook11] {};
void()   pinklin_glook11   =[ $glook11.asc,     pinklin_glook12] {};
void()   pinklin_glook12   =[ $glook12.asc,     pinklin_glook13] {};
void()   pinklin_glook13   =[ $glook13.asc,     pinklin_glook14] {};
void()   pinklin_glook14   =[ $glook14.asc,     pinklin_glook15] {};
void()   pinklin_glook15   =[ $glook15.asc,     pinklin_glook16] {};
void()   pinklin_glook16   =[ $glook16.asc,     pinklin_glook17] {};
void()   pinklin_glook17   =[ $glook17.asc,     pinklin_glook18] {};
void()   pinklin_glook18   =[ $glook18.asc,     pinklin_glook19] {};
void()   pinklin_glook19   =[ $glook19.asc,     pinklin_glook20] {};
void()   pinklin_glook20   =[ $glook20.asc,     pinklin_glook20]
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

void()   pinklin_pain1   =[ $pain1.asc,     pinklin_pain2   ] {ai_back(4);};
void()   pinklin_pain2   =[ $pain2.asc,     pinklin_pain3   ] {ai_back(4);};
void()   pinklin_pain3   =[ $pain3.asc,     pinklin_pain4   ] {ai_back(2);};
void()   pinklin_pain4   =[ $pain4.asc,     pinklin_run1 ] {};

void()   pinklin_gunpain1   =[ $gpain1.asc,     pinklin_gunpain2   ] {ai_back(4);};
void()   pinklin_gunpain2   =[ $gpain2.asc,     pinklin_gunpain3   ] {ai_back(2);};
void()   pinklin_gunpain3   =[ $gpain3.asc,     pinklin_run1 ] {};

void(entity attacker, float damage) pinklin_pain =
{
	if (self.touch == Pinklin_JumpTouch)
		return;

	if (self.pain_finished > time)
		return;

	self.pain_finished = time + 1;

	sound (self, CHAN_VOICE, "pinklin/pinkpain.wav", 1, ATTN_NORM);
	
	pinklin_pain1 ();
		
};


void()   pinklin_die1    =[ $death1.asc,    pinklin_die2 ] {
sound (self, CHAN_VOICE, "pinklin/pinkdeath.wav", 1, ATTN_NORM);};
void()   pinklin_die2    =[ $death2.asc,    pinklin_die3 ] {ai_forward(2);	self.solid = SOLID_TRIGGER;	setorigin(self, self.origin);};
void()   pinklin_die3    =[ $death3.asc,    pinklin_die4 ] {ai_forward(1);};
void()   pinklin_die4    =[ $death4.asc,    pinklin_die5 ] {ai_forward(2);};
void()   pinklin_die5    =[ $death5.asc,    pinklin_die6 ] {ai_forward(1);};
void()   pinklin_die6    =[ $death6.asc,    pinklin_die7 ] {};
void()   pinklin_die7    =[ $death7.asc,    pinklin_die8 ] {ai_forward(2);};
void()   pinklin_die8    =[ $death8.asc,    pinklin_die9 ] {ai_forward(1);};
void()   pinklin_die9    =[ $death9.asc,    pinklin_die10 ] {ai_forward(2);};
void()   pinklin_die10    =[ $death10.asc,    pinklin_die11 ] {ai_forward(1);};
void()   pinklin_die11    =[ $death11.asc,    pinklin_die12 ] {ai_forward(2);};
void()   pinklin_die12    =[ $death12.asc,    pinklin_die12 ] {monster_dead_dead();};

void() pinklin_gib =	{
	sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
	ThrowHead ("progs/h_pinklin.mdl", -35);
	ThrowGib ("progs/gib1.mdl", -35);
	ThrowGib ("progs/gib1.mdl", -35);
	ThrowGib ("progs/gib1.mdl", -35);
	self.deadflag = DEAD_GIBBED;
};


void()   pinklin_flip1    =[ $flip1.asc,    pinklin_flip2 ]	{
	ai_face();
	makevectors (self.angles);
	self.origin_z = self.origin_z + 1;
	self.velocity = '0 0 350' - (v_forward * 200);
	
	if (self.flags & FL_ONGROUND)
		self.flags = self.flags - FL_ONGROUND;

	sound (self, CHAN_VOICE, "pinklin/pinkdeath.wav", 1, ATTN_NORM);
};
void()   pinklin_flip2    =[ $flip2.asc,    pinklin_flip3 ] {ai_face();};
void()   pinklin_flip3    =[ $flip3.asc,    pinklin_flip4 ] {};
void()   pinklin_flip4    =[ $flip4.asc,    pinklin_flip5 ] {};
void()   pinklin_flip5    =[ $flip5.asc,    pinklin_flip6 ] {};
void()   pinklin_flip6    =[ $flip6.asc,    pinklin_flip7 ] {self.touch = Pinklin_FlipTouch;};
void()   pinklin_flip7    =[ $flip7.asc,    pinklin_gib ] {self.nextthink = time + 3;}; // if 3 seconds pass assume it's stuck and BLOW IT TO PIECES
void()   pinklin_flip8    =[ $flip8.asc,    pinklin_flip8 ]	{self.solid = SOLID_TRIGGER; setorigin(self, self.origin);};

void()   Pinklin_FlipTouch = {

	if (!checkbottom(self))	{
		if (self.flags & FL_ONGROUND) {
			self.touch = SUB_Null;
			self.think = pinklin_flip1;
			self.nextthink = time + 0.1;
		}
		return;	// not on ground yet
	}

	self.touch = SUB_Null;
	self.think = pinklin_flip8;
	self.nextthink = time + 0.1;
};



void() pinklin_die =
{
	local vector   vec;
	local float		dot;

	makevectors (self.angles);
	vec = normalize (damage_attacker.origin - self.origin);
	dot = vec * v_forward;

	// check for gib
	if (self.health < -35) {
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_pinklin.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		self.deadflag = DEAD_GIBBED;
		return;
	}
	else if (dot>0.7 && (random()<0.5) && (self.flags & FL_ONGROUND)) {
		pinklin_flip1();
		return;
	}
// regular death
	pinklin_die1 ();
};



void() Pinklin_MeleeAttack = {
	local float num;
	
	num = random();
	if (num<0.3)
		pinklin_claw1 ();
		
	else if (num < 0.6)
		pinklin_lunge1 ();
		
	else
		pinklin_claw1 ();
			

};

float()  PinklinCheckAttack = {
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

void(float side)  Pinklin_Melee =
{
	local	float	ldmg;
	local vector	delta;

	ai_face ();

//   walkmove (self.ideal_yaw, 12);   // allow a little closing


	delta = self.enemy.origin - self.origin;

	sound (self, CHAN_WEAPON, "pinklin/pinkattack.wav", 1, ATTN_NORM);

	if (vlen(delta) > 100)
		return;
	if (!CanDamage (self.enemy, self.origin))
		return;

	sound (self, CHAN_AUTO, "demon/dhit2.wav", 1, ATTN_NORM);
	ldmg = 15 + 5*random();
	T_Damage (self.enemy, self, self, ldmg, DMGTYPE_MELEE);

	makevectors (self.angles);
	SpawnMeatSpray (self.origin + v_forward*16, side * v_right);
};

//===========================================================================


void()   Pinklin_JumpTouch = {
	//local	float	ldmg;

	if (self.health <= 0)
		return;

	if (!checkbottom(self))
		{
		if (self.flags & FL_ONGROUND)
			{
			self.touch = SUB_Null;
			self.think = pinklin_jump1;
			self.nextthink = time + 0.1;
			}
		return;	// not on ground yet
		}

	self.touch = SUB_Null;
	self.think = pinklin_jump12;
	self.nextthink = time + 0.1;
};



/*
============
PinklinWeaponAttack

attack with a weapon
============
*/

void() Pinklin_MissileAttack =	{
	if (self.flags & FL_ONGROUND && random() < 0.2)
		pinklin_jump1();
};

//========================================================================================

void() pinklin_sight = {
	sound (self, CHAN_VOICE, "pinklin/pinksight.wav", 1, ATTN_NORM);
	self.air_finished = time + 3;
};


void(entity e) monster_pinklin_start = {
	local entity oself;

	oself = self;
	self = e;
	
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/pinklin_large.mdl");

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize(self, self.cmins, self.cmaxs);
	
	self.health = 150;
	self.max_health = 150;
	self.yaw_speed = 40;

	if (self.obituary == "") self.obituary = "was sliced by a Pinklin";

	self.th_stand = pinklin_stand1;
	self.th_walk = pinklin_walk1;
	self.th_run = pinklin_run1;
	self.th_die = pinklin_die;
	self.th_melee = Pinklin_MeleeAttack;
	//self.th_missile = Pinklin_MissileAttack; // no jumpy
	self.th_pain = pinklin_pain;
	self.th_sight = pinklin_sight;

	walkmonster_start();

	self = oself;
}

void() monster_pinklin_spawner = {
	monster_spawner(monster_pinklin_start);
};


/*QUAKED monster_pinklin (1 0 0) (-32 -32 -24) (32 32 64) Ambush

*/
void() monster_pinklin = {
	if (!SUB_InitEntity()) return;

	if (deathmatch) {
		remove(self);
		return;
	}
	
	precache_model ("progs/pinklin_large.mdl");
	precache_model ("progs/h_pinklin.mdl");

	precache_sound ("pinklin/pinkdeath.wav");
	precache_sound ("pinklin/pinkattack.wav");
	precache_sound ("pinklin/pinkidle1.wav");
	precache_sound ("demon/djump.wav");
	precache_sound ("demon/dhit2.wav");
	precache_sound ("pinklin/pinkpain.wav");
	precache_sound ("pinklin/pinksight.wav");

	self.cmins = VEC_HULL_MIN;
	self.cmaxs = VEC_HULL_MAX;

	if (self.spawnflags & MONSTER_ZEROBBOX) setsize(self, '0 0 -24', '0 0 -24');
	else setsize(self, self.cmins, self.cmaxs);
	
	if (self.spawnflags & MONSTER_SPAWNER) {
		self.use = monster_pinklin_spawner;
		monster_spawner_updatecounter();
	}
	else {
		monster_pinklin_start(self);
	}

};
