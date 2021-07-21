/*
==============================================================================

Hunter 

By ijed

==============================================================================
*/

$cd id1/models/hunter
$origin 0 0 24
$base base
$skin badass3

$frame	skin

$frame run1 run2 run3 run4 run5 run6 run7 run8 run9 run10 run11 run12 run13 run14 run15 run16 run17 run18 run19

$frame fire1 fire2 fire3 fire4 fire5 fire6 fire7 fire8 fire9 fire10 fire11 fire12 fire13 fire14 fire15 fire16 fire17 fire18 fire19 fire20 fire21 fire22 fire23 fire24 fire25 fire26 fire27 fire28 fire29 fire30

$frame punch1 punch2 punch3 punch4 punch5 punch6 punch7 punch8 punch9 punch10

$frame die1 die2 die3 die4 die5 die6 die7 die8 die9 die10 die11 die12

$frame idle1 idle2 idle3 idle4 idle5 idle6 idle7 idle8 idle9 idle10 idle11 idle12 idle13 idle14 idle15 idle16 idle17 idle18 idle19

$frame run_loff1 run_loff2 run_loff3 run_loff4 run_loff5 run_loff6 run_loff7 run_loff8 run_loff9 run_loff10 run_loff11 run_loff12 run_loff13 run_loff14 run_loff15 run_loff16 run_loff17 run_loff18 run_loff19

$frame run_roff1 run_roff2 run_roff3 run_roff4 run_roff5 run_roff6 run_roff7 run_roff8 run_roff9 run_roff10 run_roff11 run_roff12 run_roff13 run_roff14 run_roff15 run_roff16 run_roff17 run_roff18 run_roff19

$frame fire_loff1 fire_loff2 fire_loff3 fire_loff4 fire_loff5 fire_loff6 fire_loff7 fire_loff8 fire_loff9 fire_loff10 fire_loff11

$frame fire_roff1 fire_roff2 fire_roff3 fire_roff4 fire_roff5 fire_roff6 fire_roff7 fire_roff8 fire_roff9 fire_roff10 fire_roff11

$frame die_loff1 die_loff2 die_loff3 die_loff4 die_loff5 die_loff6 die_loff7 die_loff8 die_loff9 die_loff10 die_loff11 die_loff12

$frame die_roff1 die_roff2 die_roff3 die_roff4 die_roff5 die_roff6 die_roff7 die_roff8 die_roff9 die_roff10 die_roff11 die_roff12

$frame die_boff1 die_boff2 die_boff3 die_boff4 die_boff5 die_boff6 die_boff7 die_boff8 die_boff9 die_boff10 die_boff11 die_boff12

$frame die_hoff1 die_hoff2 die_hoff3 die_hoff4 die_hoff5 die_hoff6 die_hoff7 die_hoff8 die_hoff9 die_hoff10 die_hoff11 die_hoff12

$frame idle_loff1 idle_loff2 idle_loff3 idle_loff4 idle_loff5 idle_loff6 idle_loff7 idle_loff8 idle_loff9 idle_loff10 idle_loff11 idle_loff12 idle_loff13 idle_loff14 idle_loff15 idle_loff16 idle_loff17 idle_loff18 idle_loff19

$frame idle_roff1 idle_roff2 idle_roff3 idle_roff4 idle_roff5 idle_roff6 idle_roff7 idle_roff8 idle_roff9 idle_roff10 idle_roff11 idle_roff12 idle_roff13 idle_roff14 idle_roff15 idle_roff16 idle_roff17 idle_roff18 idle_roff19

//==========================================================

void()	hunter_shoot;
void()	hunter_check_refire;
void()	hunter_detonate;
void()	hunter_explode;
void()	ThrowExplosion;
void()  HunterIdleSound;

//==========================================================

void()	bbullet_explode1	=	[0,	bbullet_explode2]	{};
void()	bbullet_explode2	=	[1,	bbullet_explode3]	{};
void()	bbullet_explode3	=	[2,	SUB_Remove]			{};

//ijed These are for the Mr Big monster's attacks
void() become_big_bullet_explosion =
{
	self.movetype = MOVETYPE_NONE;
	self.velocity = '0 0 0';
	self.touch = SUB_Null;
	setmodel (self, "progs/big_bullet_blast.mdl");
	self.solid = SOLID_NOT;
	bbullet_explode1 ();
};

void()	hunter_step	=
{
	sound (self, CHAN_VOICE, "hunter/step.wav", 1, ATTN_NORM);
};

void() hunter_shot_touch =
{
	local vector org;
	
	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
	sound (self, CHAN_VOICE, "hunter/hit.wav", 1, ATTN_NORM);
	
	org = self.origin - 8*normalize(self.velocity);

	if (other.health)
	{
		if ((other.classname == "monster_zombie") || (other.classname == "monster_dog"))
			T_Damage (other, self, self.owner, 70);	//Instagib zombies and dogs
		else
			T_Damage (other, self, self.owner, 10);
	}
		
	T_RadiusDamage (self, self, 20, world);		//Additional radial damage 
	
	become_big_bullet_explosion();	//ball explosion effect
};

void(vector org, vector vec) launch_hunter_blast =
{
	local float shotspeed;
		
	shotspeed = ((skill * 100) + 600);
	
	vec = normalize(vec);
	
	newmis = spawn();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLY;
	newmis.solid = SOLID_BBOX;
	newmis.effects = EF_DIMLIGHT;
	newmis.classname = "huntershot";
	newmis.flags = newmis.flags | FL_PROJECTILE;
	
	setmodel (newmis, "progs/big_bullet.mdl");
	setsize (newmis, '0 0 0', '0 0 0');		

	setorigin (newmis, org);

	newmis.velocity = vec * shotspeed;
	
	newmis.angles = vectoangles(newmis.velocity);

	newmis.nextthink = time + 2;
	newmis.think = SUB_Remove;
	newmis.touch = hunter_shot_touch;
};

void() hunter_shoot =
{
	local	vector	org1, org2, vec1, vec2;

	makevectors (self.angles);	
	
	org1 = self.origin + v_forward * 20 + v_right * 36 + '0 0 24';		//right hand
	org2 = self.origin + v_forward * 20 + v_right * -36 + '0 0 24';		//left hand
	
	sound (self, CHAN_WEAPON, "hunter/fire.wav", 1, ATTN_NORM);
	self.effects = self.effects | EF_MUZZLEFLASH;
	
	vec1 = self.enemy.origin + RandomOffset(32) - org1;
	vec2 = self.enemy.origin + RandomOffset(32) - org2;
	
	//only fire with hands that haven't been blown off
	if (self.dismemberment == 1)
		launch_hunter_blast (org1, vec1);
	else if (self.dismemberment == 2)
		launch_hunter_blast (org2, vec2);	
	else
	{
		launch_hunter_blast (org1, vec1);
		launch_hunter_blast (org2, vec2);
	}
};

void() hunter_punch =
{
local vector	delta;
local float 	ldmg;

	if (!self.enemy)
		return;
	if (!CanDamage (self.enemy, self))
		return;

	ai_charge(10);

	delta = self.enemy.origin - (self.origin + '0 0 26');

	if (vlen(delta) > 100)
		return;
		
	ldmg = (random() + random() + random()) * 10;

	T_Damage (self.enemy, self, self, ldmg);
	
	sound (self, CHAN_VOICE, "hunter/smash.wav", 1, ATTN_NORM);
	
	//knock the target back
	self.enemy.velocity_z = self.enemy.velocity_z + (random() * 250);
	makevectors (self.angles);
	self.enemy.velocity = self.enemy.velocity + v_forward * 1000;
};

//==========================================================

//idle
void()	hunter_idle1	=[	$idle1,		hunter_idle2	]	{ai_stand();  HunterIdleSound();};
void()	hunter_idle2	=[	$idle2,		hunter_idle3	]	{ai_stand();};
void()	hunter_idle3	=[	$idle3,		hunter_idle4	]	{ai_stand();};
void()	hunter_idle4	=[	$idle4,		hunter_idle5	]	{ai_stand();};
void()	hunter_idle5	=[	$idle5,		hunter_idle6	]	{ai_stand();};
void()	hunter_idle6	=[	$idle6,		hunter_idle7	]	{ai_stand();};
void()	hunter_idle7	=[	$idle7,		hunter_idle8	]	{ai_stand();};
void()	hunter_idle8	=[	$idle8,		hunter_idle9	]	{ai_stand();};
void()	hunter_idle9	=[	$idle9,		hunter_idle10	]	{ai_stand();};
void()	hunter_idle10	=[	$idle10,	hunter_idle11	]	{ai_stand();};
void()	hunter_idle11	=[	$idle11,	hunter_idle12	]	{ai_stand();};
void()	hunter_idle12	=[	$idle12,	hunter_idle13	]	{ai_stand();};
void()	hunter_idle13	=[	$idle13,	hunter_idle14	]	{ai_stand();};
void()	hunter_idle14	=[	$idle14,	hunter_idle15	]	{ai_stand();};
void()	hunter_idle15	=[	$idle15,	hunter_idle16	]	{ai_stand();};
void()	hunter_idle16	=[	$idle16,	hunter_idle17	]	{ai_stand();};
void()	hunter_idle17	=[	$idle17,	hunter_idle18	]	{ai_stand();};
void()	hunter_idle18	=[	$idle18,	hunter_idle1	]	{ai_stand();};

//idle no left arm
void()	hunter_idle_loff1	=[	$idle_loff1,	hunter_idle_loff2	]	{ai_stand(); HunterIdleSound();};
void()	hunter_idle_loff2	=[	$idle_loff2,	hunter_idle_loff3	]	{ai_stand();};
void()	hunter_idle_loff3	=[	$idle_loff3,	hunter_idle_loff4	]	{ai_stand();};
void()	hunter_idle_loff4	=[	$idle_loff4,	hunter_idle_loff5	]	{ai_stand();};
void()	hunter_idle_loff5	=[	$idle_loff5,	hunter_idle_loff6	]	{ai_stand();};
void()	hunter_idle_loff6	=[	$idle_loff6,	hunter_idle_loff7	]	{ai_stand();};
void()	hunter_idle_loff7	=[	$idle_loff7,	hunter_idle_loff8	]	{ai_stand();};
void()	hunter_idle_loff8	=[	$idle_loff8,	hunter_idle_loff9	]	{ai_stand();};
void()	hunter_idle_loff9	=[	$idle_loff9,	hunter_idle_loff10	]	{ai_stand();};
void()	hunter_idle_loff10	=[	$idle_loff10,	hunter_idle_loff11	]	{ai_stand();};
void()	hunter_idle_loff11	=[	$idle_loff11,	hunter_idle_loff12	]	{ai_stand();};
void()	hunter_idle_loff12	=[	$idle_loff12,	hunter_idle_loff13	]	{ai_stand();};
void()	hunter_idle_loff13	=[	$idle_loff13,	hunter_idle_loff14	]	{ai_stand();};
void()	hunter_idle_loff14	=[	$idle_loff14,	hunter_idle_loff15	]	{ai_stand();};
void()	hunter_idle_loff15	=[	$idle_loff15,	hunter_idle_loff16	]	{ai_stand();};
void()	hunter_idle_loff16	=[	$idle_loff16,	hunter_idle_loff17	]	{ai_stand();};
void()	hunter_idle_loff17	=[	$idle_loff17,	hunter_idle_loff18	]	{ai_stand();};
void()	hunter_idle_loff18	=[	$idle_loff18,	hunter_idle_loff1	]	{ai_stand();};

//idle no right arm
void()	hunter_idle_roff1	=[	$idle_roff1,	hunter_idle_roff2	]	{ai_stand(); HunterIdleSound();};
void()	hunter_idle_roff2	=[	$idle_roff2,	hunter_idle_roff3	]	{ai_stand();};
void()	hunter_idle_roff3	=[	$idle_roff3,	hunter_idle_roff4	]	{ai_stand();};
void()	hunter_idle_roff4	=[	$idle_roff4,	hunter_idle_roff5	]	{ai_stand();};
void()	hunter_idle_roff5	=[	$idle_roff5,	hunter_idle_roff6	]	{ai_stand();};
void()	hunter_idle_roff6	=[	$idle_roff6,	hunter_idle_roff7	]	{ai_stand();};
void()	hunter_idle_roff7	=[	$idle_roff7,	hunter_idle_roff8	]	{ai_stand();};
void()	hunter_idle_roff8	=[	$idle_roff8,	hunter_idle_roff9	]	{ai_stand();};
void()	hunter_idle_roff9	=[	$idle_roff9,	hunter_idle_roff10	]	{ai_stand();};
void()	hunter_idle_roff10	=[	$idle_roff10,	hunter_idle_roff11	]	{ai_stand();};
void()	hunter_idle_roff11	=[	$idle_roff11,	hunter_idle_roff12	]	{ai_stand();};
void()	hunter_idle_roff12	=[	$idle_roff12,	hunter_idle_roff13	]	{ai_stand();};
void()	hunter_idle_roff13	=[	$idle_roff13,	hunter_idle_roff14	]	{ai_stand();};
void()	hunter_idle_roff14	=[	$idle_roff14,	hunter_idle_roff15	]	{ai_stand();};
void()	hunter_idle_roff15	=[	$idle_roff15,	hunter_idle_roff16	]	{ai_stand();};
void()	hunter_idle_roff16	=[	$idle_roff16,	hunter_idle_roff17	]	{ai_stand();};
void()	hunter_idle_roff17	=[	$idle_roff17,	hunter_idle_roff18	]	{ai_stand();};
void()	hunter_idle_roff18	=[	$idle_roff18,	hunter_idle_roff1	]	{ai_stand();};

//walk
void()	hunter_walk1	=[	$run1,	hunter_walk2	] {ai_walk(3); HunterIdleSound();};
void()	hunter_walk2	=[	$run2,	hunter_walk3	] {ai_walk(4);};
void()	hunter_walk3	=[	$run3,	hunter_walk4	] {ai_walk(5);};
void()	hunter_walk4	=[	$run4,	hunter_walk5	] {ai_walk(6);};
void()	hunter_walk5	=[	$run5,	hunter_walk6	] {ai_walk(5); hunter_step();};
void()	hunter_walk6	=[	$run6,	hunter_walk7	] {ai_walk(4);};
void()	hunter_walk7	=[	$run7,	hunter_walk8	] {ai_walk(3);};
void()	hunter_walk8	=[	$run8,	hunter_walk9	] {ai_walk(3);};
void()	hunter_walk9	=[	$run9,	hunter_walk10	] {ai_walk(4);};
void()	hunter_walk10	=[	$run10,	hunter_walk11	] {ai_walk(5);};
void()	hunter_walk11	=[	$run11, hunter_walk12	] {ai_walk(6);};
void()	hunter_walk12	=[	$run12,	hunter_walk13	] {ai_walk(5);};
void()	hunter_walk13	=[	$run13,	hunter_walk14	] {ai_walk(4);};
void()	hunter_walk14	=[	$run14,	hunter_walk15	] {ai_walk(3);};
void()	hunter_walk15	=[	$run15,	hunter_walk16	] {ai_walk(5); hunter_step();};
void()	hunter_walk16	=[	$run16, hunter_walk17	] {ai_walk(6);};
void()	hunter_walk17	=[	$run17,	hunter_walk18	] {ai_walk(5);};
void()	hunter_walk18	=[	$run18,	hunter_walk19	] {ai_walk(4);};
void()	hunter_walk19	=[	$run19,	hunter_walk1	] {ai_walk(3);};

//walk no left arm
void()	hunter_walk_loff1	=[	$run_loff1,		hunter_walk_loff2	] {ai_walk(3); HunterIdleSound();};
void()	hunter_walk_loff2	=[	$run_loff2,		hunter_walk_loff3	] {ai_walk(4);};
void()	hunter_walk_loff3	=[	$run_loff3,		hunter_walk_loff4	] {ai_walk(5);};
void()	hunter_walk_loff4	=[	$run_loff4,		hunter_walk_loff5	] {ai_walk(6);};
void()	hunter_walk_loff5	=[	$run_loff5,		hunter_walk_loff6	] {ai_walk(5); hunter_step();};
void()	hunter_walk_loff6	=[	$run_loff6,		hunter_walk_loff7	] {ai_walk(4);};
void()	hunter_walk_loff7	=[	$run_loff7,		hunter_walk_loff8	] {ai_walk(3);};
void()	hunter_walk_loff8	=[	$run_loff8,		hunter_walk_loff9	] {ai_walk(3);};
void()	hunter_walk_loff9	=[	$run_loff9,		hunter_walk_loff10	] {ai_walk(4);};
void()	hunter_walk_loff10	=[	$run_loff10,	hunter_walk_loff11	] {ai_walk(5);};
void()	hunter_walk_loff11	=[	$run_loff11, 	hunter_walk_loff12	] {ai_walk(6);};
void()	hunter_walk_loff12	=[	$run_loff12,	hunter_walk_loff13	] {ai_walk(5);};
void()	hunter_walk_loff13	=[	$run_loff13,	hunter_walk_loff14	] {ai_walk(4);};
void()	hunter_walk_loff14	=[	$run_loff14,	hunter_walk_loff15	] {ai_walk(3);};
void()	hunter_walk_loff15	=[	$run_loff15,	hunter_walk_loff16	] {ai_walk(5); hunter_step();};
void()	hunter_walk_loff16	=[	$run_loff16, 	hunter_walk_loff17	] {ai_walk(6);};
void()	hunter_walk_loff17	=[	$run_loff17,	hunter_walk_loff18	] {ai_walk(5);};
void()	hunter_walk_loff18	=[	$run_loff18,	hunter_walk_loff1	] {ai_walk(4);};

//walk no right arm
void()	hunter_walk_roff1	=[	$run_roff1,		hunter_walk_roff2	] {ai_walk(3); HunterIdleSound();};
void()	hunter_walk_roff2	=[	$run_roff2,		hunter_walk_roff3	] {ai_walk(4);};
void()	hunter_walk_roff3	=[	$run_roff3,		hunter_walk_roff4	] {ai_walk(5);};
void()	hunter_walk_roff4	=[	$run_roff4,		hunter_walk_roff5	] {ai_walk(6);};
void()	hunter_walk_roff5	=[	$run_roff5,		hunter_walk_roff6	] {ai_walk(5); hunter_step();};
void()	hunter_walk_roff6	=[	$run_roff6,		hunter_walk_roff7	] {ai_walk(4);};
void()	hunter_walk_roff7	=[	$run_roff7,		hunter_walk_roff8	] {ai_walk(3);};
void()	hunter_walk_roff8	=[	$run_roff8,		hunter_walk_roff9	] {ai_walk(3);};
void()	hunter_walk_roff9	=[	$run_roff9,		hunter_walk_roff10	] {ai_walk(4);};
void()	hunter_walk_roff10	=[	$run_roff10,	hunter_walk_roff11	] {ai_walk(5);};
void()	hunter_walk_roff11	=[	$run_roff11,	hunter_walk_roff12	] {ai_walk(6);};
void()	hunter_walk_roff12	=[	$run_roff12,	hunter_walk_roff13	] {ai_walk(5);};
void()	hunter_walk_roff13	=[	$run_roff13,	hunter_walk_roff14	] {ai_walk(4);};
void()	hunter_walk_roff14	=[	$run_roff14,	hunter_walk_roff15	] {ai_walk(3);};
void()	hunter_walk_roff15	=[	$run_roff15,	hunter_walk_roff16	] {ai_walk(5); hunter_step();};
void()	hunter_walk_roff16	=[	$run_roff16,	hunter_walk_roff17	] {ai_walk(6);};
void()	hunter_walk_roff17	=[	$run_roff17,	hunter_walk_roff18	] {ai_walk(5);};
void()	hunter_walk_roff18	=[	$run_roff18,	hunter_walk_roff1	] {ai_walk(4);};

//run
void()	hunter_run1		=[	$run1,	hunter_run2		] {ai_run(3); HunterIdleSound();};
void()	hunter_run2		=[	$run2,	hunter_run3		] {ai_run(4);};
void()	hunter_run3		=[	$run3,	hunter_run4		] {ai_run(5);};
void()	hunter_run4		=[	$run4,	hunter_run5		] {ai_run(6);};
void()	hunter_run5		=[	$run5,	hunter_run6		] {ai_run(5); hunter_step();};
void()	hunter_run6		=[	$run6,	hunter_run7		] {ai_run(4);};
void()	hunter_run7		=[	$run7,	hunter_run8		] {ai_run(3);};
void()	hunter_run8		=[	$run8,	hunter_run9		] {ai_run(3);};
void()	hunter_run9		=[	$run9,	hunter_run10	] {ai_run(4);};
void()	hunter_run10	=[	$run10,	hunter_run11	] {ai_run(5);};
void()	hunter_run11	=[	$run11, hunter_run12	] {ai_run(6);};
void()	hunter_run12	=[	$run12,	hunter_run13	] {ai_run(5);};
void()	hunter_run13	=[	$run13,	hunter_run14	] {ai_run(4);};
void()	hunter_run14	=[	$run14,	hunter_run15	] {ai_run(3);};
void()	hunter_run15	=[	$run15,	hunter_run16	] {ai_run(5); hunter_step();};
void()	hunter_run16	=[	$run16, hunter_run17	] {ai_run(6);};
void()	hunter_run17	=[	$run17,	hunter_run18	] {ai_run(5);};
void()	hunter_run18	=[	$run18,	hunter_run19	] {ai_run(4);};
void()	hunter_run19	=[	$run19,	hunter_run1		] {ai_run(3);};

//run no left arm
void()	hunter_run_loff1	=[	$run_loff1,		hunter_run_loff2	] {ai_run(3); HunterIdleSound();};
void()	hunter_run_loff2	=[	$run_loff2,		hunter_run_loff3	] {ai_run(4);};
void()	hunter_run_loff3	=[	$run_loff3,		hunter_run_loff4	] {ai_run(5);};
void()	hunter_run_loff4	=[	$run_loff4,		hunter_run_loff5	] {ai_run(6);};
void()	hunter_run_loff5	=[	$run_loff5,		hunter_run_loff6	] {ai_run(5); hunter_step();};
void()	hunter_run_loff6	=[	$run_loff6,		hunter_run_loff7	] {ai_run(4);};
void()	hunter_run_loff7	=[	$run_loff7,		hunter_run_loff8	] {ai_run(3);};
void()	hunter_run_loff8	=[	$run_loff8,		hunter_run_loff9	] {ai_run(3);};
void()	hunter_run_loff9	=[	$run_loff9,		hunter_run_loff10	] {ai_run(4);};
void()	hunter_run_loff10	=[	$run_loff10,	hunter_run_loff11	] {ai_run(5);};
void()	hunter_run_loff11	=[	$run_loff11, 	hunter_run_loff12	] {ai_run(6);};
void()	hunter_run_loff12	=[	$run_loff12,	hunter_run_loff13	] {ai_run(5);};
void()	hunter_run_loff13	=[	$run_loff13,	hunter_run_loff14	] {ai_run(4);};
void()	hunter_run_loff14	=[	$run_loff14,	hunter_run_loff15	] {ai_run(3);};
void()	hunter_run_loff15	=[	$run_loff15,	hunter_run_loff16	] {ai_run(5); hunter_step();};
void()	hunter_run_loff16	=[	$run_loff16, 	hunter_run_loff17	] {ai_run(6);};
void()	hunter_run_loff17	=[	$run_loff17,	hunter_run_loff18	] {ai_run(5);};
void()	hunter_run_loff18	=[	$run_loff18,	hunter_run_loff1	] {ai_run(4);};

//run no right arm
void()	hunter_run_roff1	=[	$run_roff1,		hunter_run_roff2	] {ai_run(3); HunterIdleSound();};
void()	hunter_run_roff2	=[	$run_roff2,		hunter_run_roff3	] {ai_run(4);};
void()	hunter_run_roff3	=[	$run_roff3,		hunter_run_roff4	] {ai_run(5);};
void()	hunter_run_roff4	=[	$run_roff4,		hunter_run_roff5	] {ai_run(6);};
void()	hunter_run_roff5	=[	$run_roff5,		hunter_run_roff6	] {ai_run(5); hunter_step();};
void()	hunter_run_roff6	=[	$run_roff6,		hunter_run_roff7	] {ai_run(4);};
void()	hunter_run_roff7	=[	$run_roff7,		hunter_run_roff8	] {ai_run(3);};
void()	hunter_run_roff8	=[	$run_roff8,		hunter_run_roff9	] {ai_run(3);};
void()	hunter_run_roff9	=[	$run_roff9,		hunter_run_roff10	] {ai_run(4);};
void()	hunter_run_roff10	=[	$run_roff10,	hunter_run_roff11	] {ai_run(5);};
void()	hunter_run_roff11	=[	$run_roff11,	hunter_run_roff12	] {ai_run(6);};
void()	hunter_run_roff12	=[	$run_roff12,	hunter_run_roff13	] {ai_run(5);};
void()	hunter_run_roff13	=[	$run_roff13,	hunter_run_roff14	] {ai_run(4);};
void()	hunter_run_roff14	=[	$run_roff14,	hunter_run_roff15	] {ai_run(3);};
void()	hunter_run_roff15	=[	$run_roff15,	hunter_run_roff16	] {ai_run(5); hunter_step();};
void()	hunter_run_roff16	=[	$run_roff16,	hunter_run_roff17	] {ai_run(6);};
void()	hunter_run_roff17	=[	$run_roff17,	hunter_run_roff18	] {ai_run(5);};
void()	hunter_run_roff18	=[	$run_roff18,	hunter_run_roff1	] {ai_run(4);};

//fire
void()	hunter_fire1	=[	$fire1,		hunter_fire2	]	{ai_face(); HunterIdleSound();};
void()	hunter_fire2	=[	$fire2,		hunter_fire3	]	{ai_face();};
void()	hunter_fire3	=[	$fire3,		hunter_fire4	]	{ai_face();};
void()	hunter_fire4	=[	$fire4,		hunter_fire5	]	{ai_face();};
void()	hunter_fire5	=[	$fire5,		hunter_fire6	]	{ai_face();};
void()	hunter_fire6	=[	$fire16,	hunter_fire7	]	{ai_face(); hunter_shoot();};
void()	hunter_fire7	=[	$fire17,	hunter_fire8	]	{ai_face();	};
void()	hunter_fire8	=[	$fire18,	hunter_fire9	]	{ai_face(); hunter_shoot();};
void()	hunter_fire9	=[	$fire19,	hunter_fire10	]	{ai_face(); };	
void()	hunter_fire10	=[	$fire20,	hunter_fire11	]	{ai_face(); hunter_shoot();};
void()	hunter_fire11	=[	$fire21,	hunter_fire1	]	{ai_face();	hunter_check_refire();};

//fire no left arm
void()	hunter_fire_loff1	=[	$fire_loff1,	hunter_fire_loff2	]	{ai_face(); HunterIdleSound();};
void()	hunter_fire_loff2	=[	$fire_loff2,	hunter_fire_loff3	]	{ai_face();};
void()	hunter_fire_loff3	=[	$fire_loff3,	hunter_fire_loff4	]	{ai_face();};
void()	hunter_fire_loff4	=[	$fire_loff4,	hunter_fire_loff5	]	{ai_face();};
void()	hunter_fire_loff5	=[	$fire_loff5,	hunter_fire_loff6	]	{ai_face();};
void()	hunter_fire_loff6	=[	$fire_loff6,	hunter_fire_loff7	]	{ai_face(); hunter_shoot();};
void()	hunter_fire_loff7	=[	$fire_loff7,	hunter_fire_loff8	]	{ai_face();	};
void()	hunter_fire_loff8	=[	$fire_loff8,	hunter_fire_loff9	]	{ai_face(); hunter_shoot();};
void()	hunter_fire_loff9	=[	$fire_loff9,	hunter_fire_loff10	]	{ai_face(); };	
void()	hunter_fire_loff10	=[	$fire_loff10,	hunter_fire_loff11	]	{ai_face(); hunter_shoot();};
void()	hunter_fire_loff11	=[	$fire_loff11,	hunter_fire_loff1	]	{ai_face();	hunter_check_refire();};

//fire no right arm
void()	hunter_fire_roff1	=[	$fire_roff1,	hunter_fire_roff2	]	{ai_face(); HunterIdleSound();};
void()	hunter_fire_roff2	=[	$fire_roff2,	hunter_fire_roff3	]	{ai_face();};
void()	hunter_fire_roff3	=[	$fire_roff3,	hunter_fire_roff4	]	{ai_face();};
void()	hunter_fire_roff4	=[	$fire_roff4,	hunter_fire_roff5	]	{ai_face();};
void()	hunter_fire_roff5	=[	$fire_roff5,	hunter_fire_roff6	]	{ai_face();};
void()	hunter_fire_roff6	=[	$fire_roff6,	hunter_fire_roff7	]	{ai_face(); hunter_shoot();};
void()	hunter_fire_roff7	=[	$fire_roff7,	hunter_fire_roff8	]	{ai_face();	};
void()	hunter_fire_roff8	=[	$fire_roff8,	hunter_fire_roff9	]	{ai_face(); hunter_shoot();};
void()	hunter_fire_roff9	=[	$fire_roff9,	hunter_fire_roff10	]	{ai_face(); };	
void()	hunter_fire_roff10	=[	$fire_roff10,	hunter_fire_roff11	]	{ai_face(); hunter_shoot();};
void()	hunter_fire_roff11	=[	$fire_roff11,	hunter_fire_roff1	]	{ai_face();	hunter_check_refire();};

//die
void()	hunter_die1		=[	$die1,	hunter_die2		]	{};
void()	hunter_die2		=[	$die2,	hunter_die3		]	{};
void()	hunter_die3		=[	$die3,	hunter_die4		]	{self.solid = SOLID_NOT;};
void()	hunter_die4		=[	$die4,	hunter_die5		]	{};
void()	hunter_die5		=[	$die5,	hunter_die6		]	{};
void()	hunter_die6		=[	$die6,	hunter_die7		]	{};
void()	hunter_die7		=[	$die7,	hunter_die8		]	{};
void()	hunter_die8		=[	$die8,	hunter_die9		]	{};
void()	hunter_die9		=[	$die9,	hunter_die10	]	{};
void()	hunter_die10	=[	$die10,	hunter_die11	]	{};
void()	hunter_die11	=[	$die11,	hunter_die11	]	{hunter_detonate();};

//die no left arm
void()	hunter_die_loff1	=[	$die_loff1,		hunter_die_loff2	]	{};
void()	hunter_die_loff2	=[	$die_loff2,		hunter_die_loff3	]	{};
void()	hunter_die_loff3	=[	$die_loff3,		hunter_die_loff4	]	{self.solid = SOLID_NOT;};
void()	hunter_die_loff4	=[	$die_loff4,		hunter_die_loff5	]	{};
void()	hunter_die_loff5	=[	$die_loff5,		hunter_die_loff6	]	{};
void()	hunter_die_loff6	=[	$die_loff6,		hunter_die_loff7	]	{};
void()	hunter_die_loff7	=[	$die_loff7,		hunter_die_loff8	]	{};
void()	hunter_die_loff8	=[	$die_loff8,		hunter_die_loff9	]	{};
void()	hunter_die_loff9	=[	$die_loff9,		hunter_die_loff10	]	{};
void()	hunter_die_loff10	=[	$die_loff10,	hunter_die_loff11	]	{};
void()	hunter_die_loff11	=[	$die_loff11,	hunter_die_loff11	]	{hunter_detonate();};

//die no right arm
void()	hunter_die_roff1	=[	$die_roff1,		hunter_die_roff2	]	{};
void()	hunter_die_roff2	=[	$die_roff2,		hunter_die_roff3	]	{};
void()	hunter_die_roff3	=[	$die_roff3,		hunter_die_roff4	]	{self.solid = SOLID_NOT;};
void()	hunter_die_roff4	=[	$die_roff4,		hunter_die_roff5	]	{};
void()	hunter_die_roff5	=[	$die_roff5,		hunter_die_roff6	]	{};
void()	hunter_die_roff6	=[	$die_roff6,		hunter_die_roff7	]	{};
void()	hunter_die_roff7	=[	$die_roff7,		hunter_die_roff8	]	{};
void()	hunter_die_roff8	=[	$die_roff8,		hunter_die_roff9	]	{};
void()	hunter_die_roff9	=[	$die_roff9,		hunter_die_roff10	]	{};
void()	hunter_die_roff10	=[	$die_roff10,	hunter_die_roff11	]	{};
void()	hunter_die_roff11	=[	$die_roff11,	hunter_die_roff11	]	{hunter_detonate();};

//die no arms
void()	hunter_die_boff1	=[	$die_boff1,		hunter_die_boff2	]	{};
void()	hunter_die_boff2	=[	$die_boff2,		hunter_die_boff3	]	{};
void()	hunter_die_boff3	=[	$die_boff3,		hunter_die_boff4	]	{self.solid = SOLID_NOT;};
void()	hunter_die_boff4	=[	$die_boff4,		hunter_die_boff5	]	{};
void()	hunter_die_boff5	=[	$die_boff5,		hunter_die_boff6	]	{};
void()	hunter_die_boff6	=[	$die_boff6,		hunter_die_boff7	]	{};
void()	hunter_die_boff7	=[	$die_boff7,		hunter_die_boff8	]	{};
void()	hunter_die_boff8	=[	$die_boff8,		hunter_die_boff9	]	{};
void()	hunter_die_boff9	=[	$die_boff9,		hunter_die_boff10	]	{};
void()	hunter_die_boff10	=[	$die_boff10,	hunter_die_boff11	]	{};
void()	hunter_die_boff11	=[	$die_boff11,	hunter_die_boff11	]	{hunter_detonate();};

//die no head
void()	hunter_die_hoff1	=[	$die_hoff1,		hunter_die_hoff2	]	{};
void()	hunter_die_hoff2	=[	$die_hoff2,		hunter_die_hoff3	]	{};
void()	hunter_die_hoff3	=[	$die_hoff3,		hunter_die_hoff4	]	{self.solid = SOLID_NOT;};
void()	hunter_die_hoff4	=[	$die_hoff4,		hunter_die_hoff5	]	{};
void()	hunter_die_hoff5	=[	$die_hoff5,		hunter_die_hoff6	]	{};
void()	hunter_die_hoff6	=[	$die_hoff6,		hunter_die_hoff7	]	{};
void()	hunter_die_hoff7	=[	$die_hoff7,		hunter_die_hoff8	]	{};
void()	hunter_die_hoff8	=[	$die_hoff8,		hunter_die_hoff9	]	{};
void()	hunter_die_hoff9	=[	$die_hoff9,		hunter_die_hoff10	]	{};
void()	hunter_die_hoff10	=[	$die_hoff10,	hunter_die_hoff11	]	{};
void()	hunter_die_hoff11	=[	$die_hoff11,	hunter_die_hoff11	]	{hunter_detonate();};

//melee
void()	hunter_punch1	=[	$punch1,		hunter_punch2	]	{ai_face(); sound (self, CHAN_VOICE, "hunter/melee.wav", 1,  ATTN_NORM);};
void()	hunter_punch2	=[	$punch2,		hunter_punch3	]	{ai_charge(15);};
void()	hunter_punch3	=[	$punch3,		hunter_punch4	]	{ai_charge(20);};
void()	hunter_punch4	=[	$punch4,		hunter_punch5	]	{ai_charge(25);};
void()	hunter_punch5	=[	$punch5,		hunter_punch6	]	{ai_charge(30);};
void()	hunter_punch6	=[	$punch6,		hunter_punch7	]	{ai_charge(30);};
void()	hunter_punch7	=[	$punch7,		hunter_punch8	]	{ai_charge(30);	hunter_punch();};
void()	hunter_punch8	=[	$punch8,		hunter_punch9	]	{ai_charge(20); ai_face();};
void()	hunter_punch9	=[	$punch9,		hunter_punch10	]	{ai_face();};	
void()	hunter_punch10	=[	$punch10,		hunter_run1		]	{ai_face();};

void()	hunter_paina1	=[	$fire3,		hunter_paina2	]	{};
void()	hunter_paina2	=[	$fire2,		hunter_paina3	]	{};
void()	hunter_paina3	=[	$fire1,		hunter_run1		]	{};

void()	hunter_painb1	=[	$fire30,	hunter_painb2	]	{};
void()	hunter_painb2	=[	$fire29,	hunter_painb3	]	{};
void()	hunter_painb3	=[	$fire28,	hunter_run1		]	{};

void()	hunter_painc1	=[	$die3,		hunter_painc2	]	{ai_pain(20);};
void()	hunter_painc2	=[	$die3,		hunter_painc3	]	{ai_pain(15);};
void()	hunter_painc3	=[	$die3,		hunter_painc4	]	{ai_pain(10);};
void()	hunter_painc4	=[	$die2,		hunter_painc5	]	{ai_pain(5);};
void()	hunter_painc5	=[	$die1,		hunter_run1		]	{};

vector() explosion_origin = 
{
	local vector org;

	org_x = self.absmin_x + (random() * 64);//self.size_x);
	org_y = self.absmin_y + (random() * 64);//self.size_y);
	org_z = self.absmin_z + (random() * 64);//self.size_z);

	return org;
};

void() ThrowExplosion =
{
	local	entity new;
	
	sound (new, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
	
	new = spawn();
	new.origin = explosion_origin();
	setsize (new, '0 0 0', '0 0 0');
	new.movetype = MOVETYPE_NONE;
	new.solid = SOLID_NOT;
	
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
	new.think = BecomeExplosion;
	new.nextthink = time + 0.1;
	new.flags = 0;
};

void() hunter_detonate =
{
	self.think = hunter_detonate;
	self.nextthink = time + random()*1 + 0.1; //0.1-1.1 seconds in the future
	
	if (self.count >= 3)
		hunter_explode();		//blow to bits
	else
	{
		ThrowExplosion();		//create an explosion
		self.count = self.count + 1;
	}
};

void() hunter_explode =
{
	local float GibCount;
	GibCount = 3;
	
	//throw the scrap
	ThrowGib ("progs/h_hunter.mdl", self.health * 2);
	
	while (GibCount > 0)
	{
		ThrowGib ("progs/hunter_gibs.mdl", self.health * 1);
		ThrowGib ("progs/hunter_gibs.mdl", self.health * 2);
		ThrowGib ("progs/hunter_gibs.mdl", self.health * 3);
		ThrowExplosion();
		GibCount = GibCount - 1;
	}
	
	//do damage
	T_RadiusDamage (self, self, 100, world);
	
	//remove hunter as an explosion sprite
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
	//BecomeExplosion ();

	fx_explode();
	SUB_Hide();

};

void() hunter_death =
{
	//bprint("HUNTER DEATH\n");
	
	// check for instant gib
	if (self.health < -80)
	{
		hunter_explode();
		return;
	}
	
	sound (self, CHAN_VOICE, "hunter/death.wav", 1, ATTN_NORM);
	
	if (self.dismemberment == 0)									//undamaged death 
	{
		if (random() >= 0.6)
		{
			ThrowGib ("progs/h_hunter.mdl", self.health * 2);
			ThrowExplosion();
			hunter_die_hoff1();										//blow head off
		}
		else
			hunter_die1 ();											//drop dead
	}
	else if (self.dismemberment == 1)								//left arm off death 
	{
		if (random() >= 0.9)
		{
			ThrowExplosion();
			ThrowGib ("progs/hunter_gibs.mdl", self.health * 2);
			ThrowGib ("progs/hunter_gibs.mdl", self.health * 2);
			hunter_die_boff1();										//both arms
		}
		else
			hunter_die_loff1 ();									//drop dead
	}
	else if (self.dismemberment == 2)								//right arm off death 
	{
		if (random() >= 0.9)
		{
			ThrowExplosion();
			ThrowGib ("progs/hunter_gibs.mdl", self.health * 2);
			ThrowGib ("progs/hunter_gibs.mdl", self.health * 2);
			hunter_die_boff1();										//both arms
		}
		else
			hunter_die_roff1();									//drop dead
	}
	else
	{
		if (random() >= 0.6)
			{
				ThrowGib ("progs/h_hunter.mdl", self.health * 2);
				ThrowExplosion();
				hunter_die_hoff1();										//blow head off
			}
			else
				hunter_die1 ();	
	}
};

void() HunterIdleSound =	//ijed, play idlesound only if not AMBUSH, can also play it while stood
{
	local float r;
	local string noise;

	noise = "hunter/idle.wav";
	r = random();
	
	if ((self.enemy == world) && (self.spawnflags & MONSTER_NOIDLESOUND))
		return;
	
	if (self.enemy == world)		//quieter if not angry at anyone
	{
		if (r < 0.1)
			sound (self, CHAN_VOICE, noise, 1, ATTN_IDLE);
	}
	else if (r < 0.2)
		sound (self, CHAN_VOICE, noise, 1, ATTN_IDLE);
};


void()	hunter_pain_sound	=
{
	if (random() < 0.5)
		sound (self, CHAN_VOICE, "hunter/pain1.wav", 1,  ATTN_NORM);
	else
		sound (self, CHAN_VOICE, "hunter/pain2.wav", 1,  ATTN_NORM);	
};

void(entity attacker, float damage)	hunter_pain	=
{
	local float HealthModifier, SkillModifier, TotalModifier;
	
	if (self.health <= 0)
		return;		// already dying, don't go into pain frame
	
	//this is to calculate the probability of blowing an arm off
	HealthModifier = self.health / 600;				//amount of damage taken; divide current by starting health values
	SkillModifier = skill / 10;						//more difficult to blow bits off on harder skills
	TotalModifier = SkillModifier + HealthModifier;	//add them together
		
	self.pain_finished = time + 2;
	
	//not damaged yet, let's see if it will be, 
	if ((self.dismemberment == 0) && (damage > 25))  //discount SG, Axe NG and SNG
	{
		if (random() > TotalModifier)	//BAM!
		{
			if (random() > 0.5)
			{
				ThrowExplosion();
				ThrowGib ("progs/hunter_gibs.mdl", self.health * 2);
				ThrowGib ("progs/hunter_gibs.mdl", self.health * 2);
				self.dismemberment = 1;
				hunter_run_loff1();	//left arm
			}
			else
			{
				ThrowExplosion();
				ThrowGib ("progs/hunter_gibs.mdl", self.health * 2);
				ThrowGib ("progs/hunter_gibs.mdl", self.health * 2);
				self.dismemberment = 2;
				hunter_run_roff1();	//right arm
			}
		}
	}
	
	if (random()*400 > damage)		//resistant to small arms fire
		return;	
	
	if (self.pain_finished > time)
		return;

	hunter_pain_sound();
		
	//regular style pain reactions, omitted if damaged
	if (self.dismemberment != 0)
		return;
	
	if (damage > 100)		//high damage hit, quad or rocket
	{
		hunter_painc1();
	}
	else					//blink and you'll miss it pain sequences
	{
		if (random() < 0.5)
			hunter_paina1();
		else
			hunter_painb2();
	}
};


void()	hunter_check_refire =
{
	if ((range(self.enemy) == RANGE_MELEE) && self.dismemberment == 0)
	{
		hunter_punch1();
		return;
	}
	else if (random() >= 0.9) 	//stop firing
	{
		if (self.dismemberment == 1)
			hunter_run_loff1();
		else if (self.dismemberment == 2)
			hunter_run_roff1();
		else
			hunter_run1();
			
		return;
	}
	
	if ((visible (self.enemy)) && (self.enemy.health > 0))	//can I see my enemy?  Are they alive?
	{
		//keep firing
		if (self.dismemberment == 1)
			hunter_fire_loff6();
		else if (self.dismemberment == 2)
			hunter_fire_roff6();
		else
			hunter_fire6();
	}
	else
	{
		if (self.dismemberment == 1)
			hunter_run_loff1();
		else if (self.dismemberment == 2)
			hunter_run_roff1();
		else
			hunter_run1();
	}
}; 

void()	hunter_check_idle	=
{
	if (self.dismemberment == 1)		//no left arm
		hunter_idle_loff1();
	else if (self.dismemberment == 2)	//no right arm
		hunter_idle_roff1();
	else								//assume it's whole
		hunter_idle1();
};

void()	hunter_check_walk	=
{
	if (self.dismemberment == 1)		//no left arm
		hunter_walk_loff1();
	else if (self.dismemberment == 2)	//no right arm
		hunter_walk_roff1();
	else								//assume it's whole
		hunter_walk1();
};

void()	hunter_check_run	=
{
	if (self.dismemberment == 1)		//no left arm
		hunter_run_loff1();
	else if (self.dismemberment == 2)	//no right arm
		hunter_run_roff1();
	else								//assume it's whole
		hunter_run1();
};

void()	hunter_check_melee	=
{
	//don't melee if damaged
	if (self.dismemberment == 1)		//no left arm
		hunter_fire_loff1();
	else if (self.dismemberment == 2)	//no right arm
		hunter_fire_roff1();
	else								//assume it's whole
		hunter_punch1();
};

void()	hunter_check_fire	=
{
	if (self.dismemberment == 1)		//no left arm
		hunter_fire_loff1();
	else if (self.dismemberment == 2)	//no right arm
		hunter_fire_roff1();
	else								//assume it's whole
		hunter_fire1();
};

void() hunter_sight = {
	sound (self, CHAN_VOICE, "hunter/sight.wav", 1, ATTN_NORM);
};

/*QUAKED monster_hunter (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/

void(entity e) monster_hunter_start =
{
	local entity oself;

	oself = self;
	self = e;

	self.count = 0; //ijed use this value as a counter when killing it
	
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/hunter.mdl");

	setsize (self,	VEC_HULL2_MIN,	VEC_HULL2_MAX);	
	self.health	=	600;
	if (self.obituary == "") self.obituary = "was hammered by a Hunter";
	if(!self.bloodtype) self.bloodtype = SPAWN_YELLOWSPARK;
	
	self.th_stand = hunter_check_idle;
	self.th_walk = hunter_check_walk;
	self.th_run = hunter_check_run;
	self.th_melee = hunter_check_melee;
	self.th_pain = hunter_pain;
	self.th_die = hunter_death;
    self.th_missile = hunter_check_fire;	
    self.th_sight = hunter_sight;
	
	self.dismemberment = 0;	//starts off whole
	
	walkmonster_start ();

	self = oself;
};

void() monster_hunter_spawner = {
	monster_spawner(monster_hunter_start);
};

void()	monster_hunter	=
{
	if (deathmatch)
	{
		remove(self);
		return;
	}

	precache_model ("progs/hunter.mdl");
	precache_model ("progs/hunter_gibs.mdl");
	precache_model ("progs/h_hunter.mdl");
	precache_model ("progs/big_bullet.mdl");
	precache_model ("progs/big_bullet_blast.mdl");

	precache_sound ("hunter/death.wav");
    precache_sound ("hunter/fire.wav");
	precache_sound ("hunter/hit.wav");
	precache_sound ("hunter/idle.wav");
	precache_sound ("hunter/melee.wav");
	precache_sound ("hunter/pain1.wav");
	precache_sound ("hunter/pain2.wav");
	precache_sound ("hunter/sight.wav");
	precache_sound ("hunter/step.wav");
	precache_sound ("hunter/smash.wav");
	precache_sound ("weapons/r_exp3.wav");

	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	
	if (self.spawnflags & MONSTER_SPAWNER) {
		self.use = monster_hunter_spawner;
		monster_spawner_updatecounter();
	}
	else {
		monster_hunter_start(self);
	}
};