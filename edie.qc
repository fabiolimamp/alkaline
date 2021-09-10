$cd id1/models/edie_c
$origin 0 0 24
$base base		
$skin base

$frame run1 run2 run3 run4 run5 run6 run7 run8 run9 run10 run11 run12 run13 run14 run15 run16

$frame runfire1 runfire2 runfire3 runfire4 runfire5 runfire6 runfire7 runfire8 runfire9 runfire10 runfire11 runfire12 runfire13 runfire14 runfire15 runfire16

$frame firesitstart1 firesitstart2 firesitstart3 firesitstart4 firesitstart5 firesitstart6 firesitstart7 firesitstart8

$frame firesit1 firesit2 firesit3 firesit4 firesit5 firesit6 firesit7 firesit8
$frame firesit9 firesit10 firesit11 firesit12 firesit13 firesit14 firesit15 firesit16 

$frame firesitend1 firesitend2 firesitend3 firesitend4

$frame pain1 pain2 pain3 pain4 pain5 pain6 pain7
$frame pain8 pain9 pain10 pain11 pain12

$frame painb1 painb2 painb3 painb4 painb5

$frame fswing1 fswing2 fswing3 fswing4 fswing5 fswing6 fswing7 fswing8 fswing9 fswing10 fswing11

$frame fswingend1 fswingend2 fswingend3 fswingend4 fswingend5 fswingend6 fswingend7 fswingend8 fswingend9 fswingend10

$frame bswing1 bswing2 bswing3 bswing4 bswing5 bswing6 bswing7 bswing8
$frame bswing9 bswing10 bswing11 bswing12 bswing13 bswing14

$frame death1 death2 death3 death4 death5 death6 death7 death8 death9 death10
$frame death11 death12 death13 death14 death15 death16 death17 death18 death19 death20
$frame death21 death22 death23 death24 death25 death26 death27 death28 death29 death30
$frame death31 death32 death33 death34 death35

//=============================================================================

void() edie_run1;
void() edie_run2;
void() edie_run3;
void() edie_run4;
void() edie_run5;
void() edie_run6;
void() edie_run7;
void() edie_run8;
void() edie_run9;
void() edie_run10;
void() edie_run11;
void() edie_run12;
void() edie_run13;
void() edie_run14;
void() edie_run15;
void() edie_run16;

float() edieCheckLoS;



void() gug_dummy_think =
{
	self.owner.gug_slapped = 0;
	self.owner.spawnmaster = world;
	self.owner.velocity = self.velocity;
	self.nextthink = (time + 0.1);
	self.think = SUB_Remove;
};
float inside_gradius;

void(float dist, float power, float clawdmg, float stime, string hitsound) gug_hit =
{
	entity e, dummy;
	float dist_front;
	if (inside_gradius)	{
		objerror("gug_hit: recursive");
		return;
	}

	inside_gradius = 1;
	
	e = findradius(self.origin, dist);
	while (e) {
		if ((e.flags & (FL_MONSTER + FL_CLIENT)) &&	e != self && e.health > 0) {
			makevectors(self.angles);
			dist_front = vlen(self.origin + (v_forward * 100) - (self.origin + normalize(e.origin - self.origin) * 100));
			if (dist_front < 100 && visible(e)) {
				
				if (e == self.enemy) 
					T_Damage(e, self, self, clawdmg);
				else
					T_Damage(e, self, self, clawdmg * 0.25);

				if (self.gug_slapped == 0) {
					sound(self, CHAN_WEAPON, hitsound, 1, ATTN_NORM);
					self.gug_slapped = 1;
				}


				if (e.flags & FL_CLIENT) {
					e.gug_slapped = 1;
					if (e.health <= 0) {
						e.velocity = e.velocity + (normalize(e.origin - self.origin) * power);
					}
					else
					{
						dummy = spawn();

						setsize(dummy, '-16 -16 -24', '16 16 40');
						setorigin(dummy, (e.origin + '0 0 1'));
						dummy.movetype = MOVETYPE_TOSS;
						dummy.nextthink = (time + 0.1);
						dummy.think = gug_dummy_think;
						dummy.touch = gug_dummy_think;
						dummy.owner = e;
						dummy.classname = "dummy";
						e.spawnmaster = dummy;
						
						if (dummy.flags & FL_ONGROUND)
							dummy.flags = dummy.flags - FL_ONGROUND;
						e.velocity = e.velocity + '0 0 22.5' * clawdmg;
						dummy.velocity = (e.velocity * 0.5) + ((normalize(e.origin - self.origin)) * power);

						if (vlen(dummy.velocity) > 600) {
							dummy.velocity = normalize(dummy.velocity) * 600;
						}

						if (e.velocity_z > 400) {
							dummy.velocity_z = 400;
						}
					}
				}
				else {
					//if (e.classname != "monster_shambler" && e.classname != "monster_shalrath" && e.classname != "monster_edie" && e.classname != "monster_shambler" ) {
					if (e.size_z <= 56) {
						if (e.flags & FL_ONGROUND) e.flags = e.flags - FL_ONGROUND;
						
						e.velocity = (e.velocity + ('0 0 0' * 1));
					}
				}
			}	
		}
		e = e.chain;
	}
	inside_gradius = 0;
	self.gug_slapped = 0;
};


void() edie_SpikeTouch =
{
	local float	damg;

	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

	damg = 10;
	
	if (other.health)
	{
		T_Damage (other, self, self.owner, damg );
		spawn_touchblood (18);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_SUPERSPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);	
	}
	self.origin = self.origin - 8*normalize(self.velocity);


		
	SUB_Remove();
};


void(float frm) breakToNormalRun =
{
	if (frm == 1)
		self.think = edie_run2;
	if (frm == 2)
		self.think = edie_run3;
	if (frm == 3)
		self.think = edie_run4;
	if (frm == 4)
		self.think = edie_run5;
	if (frm == 5)
		self.think = edie_run6;
	if (frm == 6)
		self.think = edie_run7;
	if (frm == 7)
		self.think = edie_run8;
	if (frm == 8)
		self.think = edie_run9;
	if (frm == 9)
		self.think = edie_run10;
	if (frm == 10)
		self.think = edie_run11;
	if (frm == 11)
		self.think = edie_run12;
	if (frm == 12)
		self.think = edie_run13;
	if (frm == 13)
		self.think = edie_run14;
	if (frm == 14)
		self.think = edie_run15;
	if (frm == 15)
		self.think = edie_run16;
	if (frm == 16)
		self.think = edie_run1;

}



void(float x, float y, float z, float moving) edie_Fire =
{
	local	entity missile;
	local	vector	org;
	local	float	dist, frm, noLoS;

	//ai_shotcheck();	

	makevectors (self.angles);
	org = self.origin - v_right * x + v_forward * y + v_up * z;



	if (edieCheckLoS() > 0.6)
		noLoS = 0;
	else
		noLoS = 1;

	if (moving == 0)
	{
		if (noLoS == 1)
		{
			self.think = edie_run1;
			self.endtime = time + 2;
			return;
		}
	}

	if (moving == 1)
	{
		self.endtime = self.endtime + 1;
			
		frm = self.frame - 16;

		traceline (org, self.enemy.origin, FALSE, self);
		
		if (self.endtime > (random() * 6 + 10))
		{
			breakToNormalRun(frm); //break out of run-fire
			self.endtime = time + 2;
			return;
		}	
		else if (trace_ent != self.enemy)
		{
			
			if (self.count > 10)
			{
				breakToNormalRun(frm);  //break out of run-fire
				self.endtime = time + 2;
				return;
			}
			self.count = self.count + 1;
		}
		else if (noLoS == 1)
		{
			breakToNormalRun(frm);  //break out of run-fire
			self.endtime = time + 2;
			return;
		}
		
		
		if (visible(self.enemy) && self.count != 0)
			self.count = 0;
			
	}

	//got passed all the checks, let's actually shoot now...

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX;
	missile.classname = "edie nail";
	sound (self, CHAN_WEAPON, "weapons/spike2.wav", 0.8, 1.2);


	if (moving == 0 && random() < 0.2) //randomly make him shoot badly sometimes, even when stopped and aiming.
		moving = 1;

	if (moving == 0)  //not moving, shoot accurately
	{

		if (visible(self.enemy))
		{
			local	vector	vec, move;  //ripped off Scrag's target leading code, rawr...
			local	float	fly;
		
			
				
				
			vec = self.enemy.origin - org; // set missile speed
		
				
			fly = vlen (vec) / 800;	// calc aproximate time for missile to reach vec
			
				
			move = self.enemy.velocity; // get the entities xy velocity
			move_z = 0; //so a jumping player can't cheat and make him miss
		
				
			vec = vec + move * fly;	// project the target forward in time
			
			vec = normalize(vec);
			
			//makevectors (self.angles);
			//vec = vec + accuracy*v_up*(random()- 0.5) + accuracy*v_right*(random()- 0.5); //commented out, make it always accurate (edie's hardcore!)
			
			missile.velocity = vec * 800;
		}
	

		else
		{
			missile.velocity = (self.enemy.origin + '0 0 8');
			missile.velocity = normalize (missile.velocity - org);
			missile.velocity = missile.velocity * 800;
		}




//		missile.velocity = (self.enemy.origin - org);  //old dumb-fire nails
//		missile.velocity = normalize(missile.velocity);
//		missile.velocity = missile.velocity * 800;
		missile.angles = vectoangles(missile.velocity);
	}
	else //moving, so shoot a bit randomly
	{
		missile.velocity = (self.enemy.origin - org);
		missile.velocity = normalize(missile.velocity);
		missile.velocity = missile.velocity * 800;

		dist = 50;//vlen(self.enemy.origin - org);
		missile.velocity_x = missile.velocity_x + (((random() * dist * 2) - (dist)) * 1);
		missile.velocity_y = missile.velocity_y + (((random() * dist * 2) - (dist)) * 1);
		missile.velocity_z = missile.velocity_z + (((random() * dist * 2) - (dist)) * 0.5);

		missile.velocity = normalize(missile.velocity);
		missile.velocity = missile.velocity * 800;

		missile.angles = vectoangles(missile.velocity);	
	}
	
	missile.touch = edie_SpikeTouch;
	
// set missile duration
	missile.nextthink = time + 5;
	missile.think = SUB_Remove;

	setmodel (missile, "progs/s_spike.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	


	setorigin (missile, org);
};


void() edie_stand1	=[	149,		edie_stand2	] {ai_stand();
	if ((self.waitmin < time)) {
		if (random() < 0.15) {
			sound(self, CHAN_VOICE, "edie/idle1.wav", 1, ATTN_IDLE);
			self.waitmin = (time + 3);
		}
	}
};
void() edie_stand2	=[	150,		edie_stand3	] {ai_stand();};
void() edie_stand3	=[	151,		edie_stand4	] {ai_stand();};
void() edie_stand4	=[	152,		edie_stand5	] {ai_stand();};
void() edie_stand5	=[	153,		edie_stand6	] {ai_stand();};
void() edie_stand6	=[	154,		edie_stand7	] {ai_stand();};
void() edie_stand7	=[	155,		edie_stand8	] {ai_stand();};
void() edie_stand8	=[	156,		edie_stand1	] {ai_stand();};


void() edie_walk1	=[	$run1,		edie_walk2	] {ai_walk(20);};
void() edie_walk2	=[	$run2,		edie_walk3	] {ai_walk(16);sound (self, CHAN_BODY, "edie/step.wav", 1, ATTN_IDLE);};
void() edie_walk3	=[	$run3,		edie_walk4	] {ai_walk(1);};
void() edie_walk4	=[	$run4,		edie_walk5	] {ai_walk(2);};
void() edie_walk5	=[	$run5,		edie_walk6	] {ai_walk(4);};
void() edie_walk6	=[	$run6,		edie_walk7	] {ai_walk(8);};
void() edie_walk7	=[	$run7,		edie_walk8	] {ai_walk(4);};
void() edie_walk8	=[	$run8,		edie_walk9	] {ai_walk(16);};
void() edie_walk9	=[	$run9,		edie_walk10	] {ai_walk(20);};
void() edie_walk10	=[	$run10,		edie_walk11	] {ai_walk(16);sound (self, CHAN_BODY, "edie/step.wav", 1, ATTN_IDLE);};
void() edie_walk11	=[	$run11,		edie_walk12	] {ai_walk(1);};
void() edie_walk12	=[	$run12,		edie_walk13	] {ai_walk(2);};
void() edie_walk13	=[	$run13,		edie_walk14	] {ai_walk(4);};
void() edie_walk14	=[	$run14,		edie_walk15	] {ai_walk(8);};
void() edie_walk15	=[	$run15,		edie_walk16	] {ai_walk(4);};
void() edie_walk16	=[	$run16,		edie_walk1	] {ai_walk(16);};





void(float dist, float frm) ai_edie_run_firing =
{
	self.state = 1;
	ai_face();

	ai_forward(dist);
	//ai_run(dist);
};


void() edie_run_fire1	=[	$runfire1,		edie_run_fire2	] {ai_edie_run_firing(self.multiplier * 20,1);edie_Fire(20, 50, 32, 1);};
void() edie_run_fire2	=[	$runfire2,		edie_run_fire3	] {ai_edie_run_firing(self.multiplier * 16,2);edie_Fire(18, 43, 33, 1);sound (self, CHAN_VOICE, "edie/step.wav", 1, ATTN_IDLE);};
void() edie_run_fire3	=[	$runfire3,		edie_run_fire4	] {ai_edie_run_firing(self.multiplier * 1 ,3);edie_Fire(17, 53, 31, 1);};
void() edie_run_fire4	=[	$runfire4,		edie_run_fire5	] {ai_edie_run_firing(self.multiplier * 2 ,4);edie_Fire(19, 43, 35, 1);};
void() edie_run_fire5	=[	$runfire5,		edie_run_fire6	] {ai_edie_run_firing(self.multiplier * 4 ,5);edie_Fire(16, 53, 34, 1);};
void() edie_run_fire6	=[	$runfire6,		edie_run_fire7	] {ai_edie_run_firing(self.multiplier * 8 ,6);edie_Fire(18, 44, 40, 1);};
void() edie_run_fire7	=[	$runfire7,		edie_run_fire8	] {ai_edie_run_firing(self.multiplier * 4 ,7);edie_Fire(14, 53, 37, 1);};
void() edie_run_fire8	=[	$runfire8,		edie_run_fire9	] {ai_edie_run_firing(self.multiplier * 4 ,8);edie_Fire(15, 42, 40, 1);};
void() edie_run_fire9	=[	$runfire9,		edie_run_fire10	] {ai_edie_run_firing(self.multiplier * 20,9);edie_Fire(12, 50, 34, 1);};
void() edie_run_fire10	=[	$runfire10,		edie_run_fire11	] {ai_edie_run_firing(self.multiplier * 16,10);edie_Fire(15, 42, 37, 1);sound (self, CHAN_VOICE, "edie/step.wav", 1, ATTN_IDLE);};
void() edie_run_fire11	=[	$runfire11,		edie_run_fire12	] {ai_edie_run_firing(self.multiplier * 1 ,11);edie_Fire(13, 52, 35, 1);};
void() edie_run_fire12	=[	$runfire12,		edie_run_fire13	] {ai_edie_run_firing(self.multiplier * 2 ,12);edie_Fire(16, 44, 36, 1);};
void() edie_run_fire13	=[	$runfire13,		edie_run_fire14	] {ai_edie_run_firing(self.multiplier * 4 ,13);edie_Fire(15, 53, 35, 1);};
void() edie_run_fire14	=[	$runfire14,		edie_run_fire15	] {ai_edie_run_firing(self.multiplier * 8 ,14);edie_Fire(16, 46, 37, 1);};
void() edie_run_fire15	=[	$runfire15,		edie_run_fire16	] {ai_edie_run_firing(self.multiplier * 4 ,15);edie_Fire(16, 52, 34, 1);};
void() edie_run_fire16	=[	$runfire16,		edie_run_fire1	] {ai_edie_run_firing(self.multiplier * 4 ,16);edie_Fire(16, 44, 34, 1);};




void(float dist, float frm) ai_edie_run =
{
	self.state = 0;

	traceline (self.origin, self.enemy.origin, FALSE, self);
	

	if (trace_ent == self.enemy && edieCheckLoS() > 0.6 && random() < 0.15 && time > self.endtime)
	{
		if (frm == 1)
			self.think = edie_run_fire2;
		if (frm == 2)
			self.think = edie_run_fire3;
		if (frm == 3)
			self.think = edie_run_fire4;
		if (frm == 4)
			self.think = edie_run_fire5;
		if (frm == 5)
			self.think = edie_run_fire6;
		if (frm == 6)
			self.think = edie_run_fire7;
		if (frm == 7)
			self.think = edie_run_fire8;
		if (frm == 8)
			self.think = edie_run_fire9;
		if (frm == 9)
			self.think = edie_run_fire10;
		if (frm == 10)
			self.think = edie_run_fire11;
		if (frm == 11)
			self.think = edie_run_fire12;
		if (frm == 12)
			self.think = edie_run_fire13;
		if (frm == 13)
			self.think = edie_run_fire14;
		if (frm == 14)
			self.think = edie_run_fire15;
		if (frm == 15)
			self.think = edie_run_fire16;
		if (frm == 16)
			self.think = edie_run_fire1;
		
		self.endtime = 0;

	}
	
	ai_run(dist);
};


void() edie_run1	=[	$run1,		edie_run2	] {ai_edie_run(self.multiplier * 20,1);};
void() edie_run2	=[	$run2,		edie_run3	] {ai_edie_run(self.multiplier * 16,2);sound (self, CHAN_BODY, "edie/step.wav", 1, ATTN_IDLE);};
void() edie_run3	=[	$run3,		edie_run4	] {ai_edie_run(self.multiplier * 1 ,3);};
void() edie_run4	=[	$run4,		edie_run5	] {ai_edie_run(self.multiplier * 2 ,4);};
void() edie_run5	=[	$run5,		edie_run6	] {ai_edie_run(self.multiplier * 4 ,5);};
void() edie_run6	=[	$run6,		edie_run7	] {ai_edie_run(self.multiplier * 8 ,6);};
void() edie_run7	=[	$run7,		edie_run8	] {ai_edie_run(self.multiplier * 4 ,7);};
void() edie_run8	=[	$run8,		edie_run9	] {ai_edie_run(self.multiplier * 4 ,8);};
void() edie_run9	=[	$run9,		edie_run10	] {ai_edie_run(self.multiplier * 20,9);};
void() edie_run10	=[	$run10,		edie_run11	] {ai_edie_run(self.multiplier * 16,10);sound (self, CHAN_BODY, "edie/step.wav", 1, ATTN_IDLE);};
void() edie_run11	=[	$run11,		edie_run12	] {ai_edie_run(self.multiplier * 1 ,11);};
void() edie_run12	=[	$run12,		edie_run13	] {ai_edie_run(self.multiplier * 2 ,12);};
void() edie_run13	=[	$run13,		edie_run14	] {ai_edie_run(self.multiplier * 4 ,13);};
void() edie_run14	=[	$run14,		edie_run15	] {ai_edie_run(self.multiplier * 8 ,14);};
void() edie_run15	=[	$run15,		edie_run16	] {ai_edie_run(self.multiplier * 4 ,15);};
void() edie_run16	=[	$run16,		edie_run1	] {ai_edie_run(self.multiplier * 4 ,16);};








void() edie_firesit_start1	=[	$firesitstart1,		edie_firesit_start2	] {ai_face();sound (self, CHAN_VOICE, "edie/stfire.wav", 1, ATTN_IDLE);};
void() edie_firesit_start2	=[	$firesitstart2,		edie_firesit_start3	] {ai_face();};
void() edie_firesit_start3	=[	$firesitstart3,		edie_firesit_start4	] {ai_face();};
void() edie_firesit_start4	=[	$firesitstart4,		edie_firesit_start5	] {ai_face();};
void() edie_firesit_start5	=[	$firesitstart5,		edie_firesit_start6	] {ai_face();sound (self, CHAN_BODY, "edie/step.wav", 1, ATTN_IDLE);};
void() edie_firesit_start6	=[	$firesitstart6,		edie_firesit_start7	] {ai_face();};
void() edie_firesit_start7	=[	$firesitstart7,		edie_firesit_start8	] {ai_face();};
void() edie_firesit_start8	=[	$firesitstart8,		edie_firesit1		] {ai_face();};


void() edie_firesit_end1;

void() check_edie_fire =
{
	//ai_shotcheck();

	if (visible(self.enemy))
	{
		self.count = 0;
	}
	else
	{
		self.count = self.count + 1;
		if (self.count > 6)
		{
			self.think = edie_firesit_end1;
		}
	}
};

void() edie_firesit1	=[	$firesit1,		edie_firesit2		] {check_edie_fire();ai_face();edie_Fire(10, 50, 20, 0);};
void() edie_firesit2	=[	$firesit2,		edie_firesit3		] {check_edie_fire();ai_face();edie_Fire(10, 50, 20, 0);};
void() edie_firesit3	=[	$firesit3,		edie_firesit4		] {check_edie_fire();ai_face();edie_Fire(10, 50, 22, 0);};
void() edie_firesit4	=[	$firesit4,		edie_firesit5		] {check_edie_fire();ai_face();edie_Fire(10, 50, 22, 0);};
void() edie_firesit5	=[	$firesit5,		edie_firesit6		] {check_edie_fire();ai_face();edie_Fire(12, 47, 23, 0);};
void() edie_firesit6	=[	$firesit6,		edie_firesit7		] {check_edie_fire();ai_face();edie_Fire(12, 47, 23, 0);};
void() edie_firesit7	=[	$firesit7,		edie_firesit8		] {check_edie_fire();ai_face();edie_Fire(14, 49, 23, 0);};
void() edie_firesit8	=[	$firesit8,		edie_firesit9		] {check_edie_fire();ai_face();edie_Fire(14, 49, 23, 0);};
void() edie_firesit9	=[	$firesit9,		edie_firesit10		] {check_edie_fire();ai_face();edie_Fire(17, 42, 26, 0);};
void() edie_firesit10	=[	$firesit10,		edie_firesit11		] {check_edie_fire();ai_face();edie_Fire(17, 42, 26, 0);};
void() edie_firesit11	=[	$firesit11,		edie_firesit12		] {check_edie_fire();ai_face();edie_Fire(17, 38, 27, 0);};
void() edie_firesit12	=[	$firesit12,		edie_firesit13		] {check_edie_fire();ai_face();edie_Fire(17, 38, 27, 0);};
void() edie_firesit13	=[	$firesit13,		edie_firesit14		] {check_edie_fire();ai_face();edie_Fire(18, 32, 25, 0);};
void() edie_firesit14	=[	$firesit14,		edie_firesit15		] {check_edie_fire();ai_face();edie_Fire(18, 32, 25, 0);};
void() edie_firesit15	=[	$firesit15,		edie_firesit16		] {check_edie_fire();ai_face();edie_Fire(18, 27, 27, 0);};
void() edie_firesit16	=[	$firesit16,		edie_firesit_end1	] {check_edie_fire();ai_face();edie_Fire(18, 27, 27, 0);};


void() edie_firesit_end1	=[	$firesitend1,		edie_firesit_end2	] {};
void() edie_firesit_end2	=[	$firesitend2,		edie_firesit_end3	] {};
void() edie_firesit_end3	=[	$firesitend3,		edie_firesit_end4	] {};
void() edie_firesit_end4	=[	$firesitend4,		edie_run1		] {};

//============================================ [ START MELEE ] ==================================================
void() edie_fswing_end1;
void(float dist, float power, float clawdmg, float stime, string hitsound) gug_hit;

void() edie_fswing1	=[	$fswing1,		edie_fswing2	] {self.nextthink = time + 0.1;ai_face();ai_forward(8);sound (self, CHAN_VOICE, "edie/sawstart.wav", 1, ATTN_IDLE);};
void() edie_fswing2	=[	$fswing2,		edie_fswing3	] {self.nextthink = time + 0.1;ai_face();ai_forward(16);sound (self, CHAN_BODY, "edie/step.wav", 1, ATTN_IDLE);};
void() edie_fswing3	=[	$fswing3,		edie_fswing4	] {self.nextthink = time + 0.09;ai_face();ai_forward(10);};
void() edie_fswing4	=[	$fswing4,		edie_fswing5	] {self.nextthink = time + 0.08;ai_face();ai_forward(4);sound (self, CHAN_BODY, "edie/step.wav", 1, ATTN_IDLE);};
void() edie_fswing5	=[	$fswing5,		edie_fswing6	] {self.nextthink = time + 0.07;ai_face();ai_forward(2);};
void() edie_fswing6	=[	$fswing6,		edie_fswing7	] {self.nextthink = time + 0.07;ai_face();ai_forward(1);};
void() edie_fswing7	=[	$fswing7,		edie_fswing8	] {self.nextthink = time + 0.06;ai_face();ai_forward(1);};
void() edie_fswing8	=[	$fswing8,		edie_fswing9	] {self.nextthink = time + 0.05;ai_face();ai_forward(2);gug_hit(100, 5, 20, 0.6, "edie/mangle.wav");};
void() edie_fswing9	=[	$fswing9,		edie_fswing10	] {ai_face();ai_forward(2);};
void() edie_fswing10	=[	$fswing10,		edie_fswing11	] {ai_face();ai_forward(2);};
void() edie_fswing11	=[	$fswing11,		edie_bswing1	] 
{


	local	float	dist;	

	traceline (self.origin, self.enemy.origin, FALSE, self);
	dist = vlen(self.origin - self.enemy.origin);

	if (dist > 150 || trace_ent != self.enemy || !visible(self.enemy)) //don't have a shot, break melee chain
	{	
		self.think = edie_fswing_end1;
	}

	ai_face();
	ai_forward(2);

};

void() edie_fswing_end1		=[	$fswingend1,		edie_fswing_end2	] {ai_face();ai_forward(2);};
void() edie_fswing_end2		=[	$fswingend2,		edie_fswing_end3	] {ai_face();ai_forward(2);};
void() edie_fswing_end3		=[	$fswingend3,		edie_fswing_end4	] {ai_face();ai_forward(3);};
void() edie_fswing_end4		=[	$fswingend4,		edie_fswing_end5	] {ai_face();ai_forward(4);};
void() edie_fswing_end5		=[	$fswingend5,		edie_fswing_end6	] {ai_face();ai_forward(8);};
void() edie_fswing_end6		=[	$fswingend6,		edie_fswing_end7	] {ai_face();ai_forward(12);};
void() edie_fswing_end7		=[	$fswingend7,		edie_fswing_end8	] {ai_face();ai_forward(16);};
void() edie_fswing_end8		=[	$fswingend8,		edie_fswing_end9	] {ai_face();ai_forward(12);};
void() edie_fswing_end9		=[	$fswingend9,		edie_fswing_end10	] {ai_face();ai_forward(16);};
void() edie_fswing_end10	=[	$fswingend10,		edie_run1		] {ai_face();ai_forward(16);sound (self, CHAN_BODY, "edie/step.wav", 1, ATTN_IDLE);};

void() edie_bswing1	=[	$bswing1,		edie_bswing2	] {ai_face();ai_forward(20);sound (self, CHAN_VOICE, "edie/sawstart.wav", 1, ATTN_IDLE);};
void() edie_bswing2	=[	$bswing2,		edie_bswing3	] {ai_face();ai_forward(12);};
void() edie_bswing3	=[	$bswing3,		edie_bswing4	] {ai_face();ai_forward(4);};
void() edie_bswing4	=[	$bswing4,		edie_bswing5	] {ai_face();ai_forward(2);sound (self, CHAN_BODY, "edie/step.wav", 1, ATTN_IDLE);};
void() edie_bswing5	=[	$bswing5,		edie_bswing6	] {ai_face();ai_forward(6);gug_hit(100, 20, 20, 0.6, "edie/mangle.wav");};
void() edie_bswing6	=[	$bswing6,		edie_bswing7	] {ai_face();ai_forward(4);};
void() edie_bswing7	=[	$bswing7,		edie_bswing8	] {ai_face();ai_forward(4);};
void() edie_bswing8	=[	$bswing8,		edie_bswing9	] {ai_face();ai_forward(8);};
void() edie_bswing9	=[	$bswing9,		edie_bswing10	] {ai_face();ai_forward(8);sound (self, CHAN_BODY, "edie/step.wav", 1, ATTN_IDLE);};
void() edie_bswing10	=[	$bswing10,		edie_bswing11	] {ai_face();ai_forward(8);};
void() edie_bswing11	=[	$bswing11,		edie_bswing12	] {ai_face();ai_forward(8);};
void() edie_bswing12	=[	$bswing12,		edie_bswing13	] {ai_face();ai_forward(12);};
void() edie_bswing13	=[	$bswing13,		edie_bswing14	] {ai_face();ai_forward(10);};
void() edie_bswing14	=[	$bswing14,		edie_run1	] {ai_face();ai_forward(10);};


//=================================================== [ END MELEE ] ==================================================


void()	edie_pain1	=[	$pain1,		edie_pain2	] {};
void()	edie_pain2	=[	$pain2,		edie_pain3	] {ai_pain(10);};
void()	edie_pain3	=[	$pain3,		edie_pain4	] {ai_pain(9);};
void()	edie_pain4	=[	$pain4,		edie_pain5	] {ai_pain(4);};
void()	edie_pain5	=[	$pain5,		edie_pain6	] {};
void()	edie_pain6	=[	$pain6,		edie_pain7	] {};
void()	edie_pain7	=[	$pain7,		edie_pain8	] {};
void()	edie_pain8	=[	$pain8,		edie_pain9	] {};
void()	edie_pain9	=[	$pain9,		edie_pain10	] {};
void()	edie_pain10	=[	$pain10,	edie_pain11	] {};
void()	edie_pain11	=[	$pain11,	edie_pain12	] {};
void()	edie_pain12	=[	$pain12,	edie_run1	] {};

void()	edie_painb1	=[	$painb1,		edie_painb2	] {};
void()	edie_painb2	=[	$painb2,		edie_painb3	] {};
void()	edie_painb3	=[	$painb3,		edie_painb4	] {};
void()	edie_painb4	=[	$painb4,		edie_painb5	] {};
void()	edie_painb5	=[	$painb5,		edie_run1	] {};

void(entity attacker, float damage)	edie_pain =
{

// don't make multiple pain sounds right after each other
	if (self.pain_finished > time)
		return;

			

	if (damage > 55)
	{
		if (random() < 0.4)

		{
			sound (self, CHAN_VOICE, "edie/pain.wav", 1, ATTN_NORM);
			edie_pain1 ();
			self.pain_finished = time + 3 + random() * 2;
		}
		else
		{
			sound (self, CHAN_VOICE, "edie/painshrt.wav", 1, ATTN_NORM);
			edie_painb1 ();
			self.pain_finished = time + 1 + random() * 2;
		}
	}
	else
	{
		if (random() < 0.1)
		{
			sound (self, CHAN_VOICE, "edie/pain.wav", 1, ATTN_NORM);
			edie_pain1 ();
			self.pain_finished = time + 3 + random() * 2;
		}
		else
		{
			sound (self, CHAN_VOICE, "edie/painshrt.wav", 1, ATTN_NORM);
			edie_painb1 ();
			self.pain_finished = time + 1 + random() * 2;
		}	
	}
};

void() edie_death1	=[$death1, edie_death2		] {self.nextthink = time + 0.2;self.solid = self.solid = SOLID_TRIGGER; setorigin(self, self.origin); sound (self, CHAN_VOICE, "edie/death.wav", 1, 1);};
void() edie_death2	=[$death2, edie_death3		] {self.nextthink = time + 0.2;};
void() edie_death3	=[$death3, edie_death4		] {};
void() edie_death4	=[$death4, edie_death5		] {};
void() edie_death5	=[$death5, edie_death6		] {};
void() edie_death6	=[$death6, edie_death7		] {};
void() edie_death7	=[$death7, edie_death8		] {};
void() edie_death8	=[$death8, edie_death9		] {};
void() edie_death9	=[$death9, edie_death10		] {};
void() edie_death10	=[$death11, edie_death11	] {};
void() edie_death11	=[$death12, edie_death12	] {};
void() edie_death12	=[$death13, edie_death13	] {};
void() edie_death13	=[$death14, edie_death14	] {};
void() edie_death14	=[$death15, edie_death15	] {};
void() edie_death15	=[$death16, edie_death16	] {};
void() edie_death16	=[$death17, edie_death17	] {};
void() edie_death17	=[$death18, edie_death18	] {};
void() edie_death18	=[$death19, edie_death19	] {};
void() edie_death19	=[$death20, edie_death20	] {};
void() edie_death20	=[$death21, edie_death21	] {};
void() edie_death21	=[$death22, edie_death22	] {};
void() edie_death22	=[$death23, edie_death23	] {};
void() edie_death23	=[$death24, edie_death24	] {};
void() edie_death24	=[$death25, edie_death25	] {};
void() edie_death25	=[$death26, edie_death26	] {};
void() edie_death26	=[$death27, edie_death27	] {};
void() edie_death27	=[$death28, edie_death28	] {};
void() edie_death28	=[$death29, edie_death29	] {};
void() edie_death29	=[$death30, edie_death30	] {};
void() edie_death30	=[$death31, edie_death31	] {};
void() edie_death31	=[$death32, edie_death32	] {};
void() edie_death32	=[$death33, edie_death33	] {};
void() edie_death33	=[$death34, edie_death34	] {};
void() edie_death34	=[$death35, edie_death34	] {self.think = SUB_MakeNotSolid; self.nextthink = time + 5;};

void() edie_die =
{
// check for gib
	if (self.health < -80)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_ogre.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		return;
	}

	sound (self, CHAN_VOICE, "edie/death.wav", 1, ATTN_NORM);
	

	edie_death1 ();

};
/*
void() edie_melee =
{
	if (random() > 0.5)
		edie_smash1 ();
	else
		edie_swing1 ();
};
*/



void() edie_ranged =
{
	if (self.state == 1)

		return;
	edie_firesit_start1();
};


float() edieCheckLoS =
{
	local	vector	vec, move;
	local	float	dot, fly;
	
	makevectors (self.angles);
	
	//check if player is in a cone in front of edie
	//vec = normalize (self.enemy.origin - self.origin);
		
	vec = self.enemy.origin - self.origin;
	vec_z = 0;
				
	fly = vlen (vec) / 800;
				
	move = self.enemy.velocity;
	//move_z = 0;
				
	vec = vec + move * fly;	// project the target forward in time
	vec = normalize(vec);

	dot = vec * v_forward;
	
	return dot;
};

float() EdieCheckAttack =
{
	local vector	spot1, spot2;	
	local entity	targ;
	local float		chance;

	targ = self.enemy;
	
// see if any entities are in the way of the shot
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;

	traceline (spot1, spot2, FALSE, self);

	if (trace_ent != targ)
		return FALSE;		// don't have a clear shot
			
	if (trace_inopen && trace_inwater)
		return FALSE;			// sight line crossed contents

	if (enemy_range == RANGE_MELEE)
	{	// melee attack
		if (self.th_melee)
		{
			self.th_melee ();
			return TRUE;
		}
	}
	
// missile attack
	if (!self.th_missile)
		return FALSE;
		
	if (time < self.attack_finished)
		return FALSE;
		
	if (enemy_range == RANGE_FAR)
		return FALSE;
		
	if (enemy_range == RANGE_MELEE)
	{
		if (edieCheckLoS() <= 0.6)
			return FALSE;
		chance = 0.3;
		self.attack_finished = 0;
	}
	else if (enemy_range == RANGE_NEAR)
	{
		if (edieCheckLoS() <= 0.2)
			return FALSE;
		chance = 0.2;
	}
	else if (enemy_range == RANGE_MID)
	{
		//if (edieCheckLoS() <= 0.3)
		//	return FALSE;
		chance = 0.1;
	}
	else
		chance = 0;



	if (random () < chance)
	{
		self.th_missile ();
		SUB_AttackFinished (2*random());
		return TRUE;
	}

	return FALSE;
};

/*QUAKED monster_ogre (1 0 0) (-32 -32 -24) (32 32 64) Ambush
*/

void() edie_sight = {
	sound (self, CHAN_VOICE, "edie/sight.wav", 1, ATTN_NORM);
};

void(entity e) monster_edie_start = {
	local entity oself;

	oself = self;
	self = e;

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/edie.mdl");
	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);

	self.th_stand = edie_stand1;
	self.th_walk = edie_walk1;
	self.th_run = edie_run1;
	self.th_die = edie_die;
	self.th_melee = edie_fswing1;
	self.th_missile = edie_firesit_start1;
	self.th_pain = edie_pain;
	self.th_checkattack = EdieCheckAttack;
	self.th_sight = edie_sight;

	if (self.obituary == "") self.obituary = "was exterminated by an edie";

	self.yaw_speed = 16;
	self.health = 500;
	self.multiplier = 1.2;
	

	
	walkmonster_start();

	self = oself;
}

void() monster_edie_spawner = {
	monster_spawner(monster_edie_start);
};

void() monster_edie =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/edie.mdl");
	precache_model ("progs/h_ogre.mdl");
	//precache_model ("progs/grenade.mdl");


	precache_sound ("edie/death.wav");
	precache_sound ("edie/sight.wav");
	
	precache_sound ("edie/pain.wav");
	precache_sound ("edie/painshrt.wav");

//	precache_sound ("ogre/ogwake.wav");
	
	precache_sound ("edie/idle1.wav");
	precache_sound ("edie/step.wav");
	precache_sound ("edie/mangle.wav");
	
	precache_sound ("edie/stfire.wav");
	precache_sound ("edie/sawstart.wav");

	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);

	if (self.spawnflags & MONSTER_SPAWNER) {
		self.use = monster_edie_spawner;
		monster_spawner_updatecounter();
	}
	else {
		monster_edie_start(self);
	}

};

