float	enemy_vis, enemy_infront, enemy_range;
float	enemy_yaw;
/*

.enemy
Will be world if not currently angry at anyone.

.movetarget
The next path spot to walk toward.  If .enemy, ignore .movetarget.
When an enemy is killed, the monster will try to return to it's path.

.huntt_ime
Set to time + something when the player is in sight, but movement straight for
him is blocked.  This causes the monster to use wall following code for
movement direction instead of sighting on the player.

.ideal_yaw
A yaw angle of the intended direction, which will be turned towards at up
to 45 deg / state.  If the enemy is in view and hunt_time is not active,
this will be the exact line towards the enemy.

.pausetime
A monster will leave it's stand state and head towards it's .movetarget when
time > .pausetime.

walkmove(angle, speed) primitive is all or nothing
*/


//
// globals
//
// float	current_yaw;

//
// when a monster becomes angry at a player, that monster will be used
// as the sight target the next frame so that monsters near that one
// will wake up even if they wouldn't have noticed the player
//
entity	sight_entity;
float	sight_entity_time;
/*
float(float v) anglemod =
{
	while (v >= 360)
		v = v - 360;
	while (v < 0)
		v = v + 360;
	return v;
};
*/
/*
==============================================================================

MOVETARGET CODE

The angle of the movetarget effects standing and bowing direction, but has no effect on movement, which allways heads to the next target.

targetname
must be present.  The name of this movetarget.

target
the next spot to move to.  If not present, stop here for good.

pausetime
The number of seconds to spend standing or bowing for path_stand or path_bow

==============================================================================
*/


void() movetarget_f =
{
	if (!self.targetname)
		objerror ("monster_movetarget: no targetname");
		
	self.solid = SOLID_TRIGGER;
	self.touch = t_movetarget;
	setsize (self, '-8 -8 -8', '8 8 8');
	
};

/*QUAKED path_corner (0.5 0.3 0) (-8 -8 -8) (8 8 8)
Monsters will continue walking towards the next target corner.
*/
void() path_corner =
{
	if (!SUB_InitEntity()) return;
	
	movetarget_f ();
};

void() path_angry_touch = {
	if (other.goalentity != self.owner)
		return;		// not running towards this

	dprint2(other.classname, ": Touched path_angry... ");
	//eprint(self);
	entity next, first;

	if (self.owner.target) {

		first = next = find(world, targetname, self.owner.target);

		float loopcount;
		
		// loops if found path_corner isn't active
		while (next && next.estate != STATE_ACTIVE && loopcount < 3) {
			if (next == first) loopcount++;
			next = find(world, targetname, next.target);
		}

		//next = find(world, targetname, self.owner.target);
		other.goalentity = next;
		dprint("Moving to next!\n");
	}
	else if (!next) {
		other.goalentity = other.enemy;
		other.oldenemy = world;
		other.followingpath = FALSE;
		dprint("Path ended! \n");
	}

	
};

void() path_angry = {
	if (!SUB_InitEntity()) return;
	
	if (!self.targetname)
		objerror ("path_angry: no targetname");
	entity trg;


	// if monsters have their enemy field set they'll never touch their goalentity (why??)
	// so we create a trigger field around it 
	trg = spawn();

	trg.solid = SOLID_TRIGGER;
	trg.touch = path_angry_touch;
	trg.owner = self;
	trg.classname = "path_angry_trigger";
	self.owner = trg;
	setorigin(trg, self.origin);
	//setsize (self, '-8 -8 -8', '8 8 8');
	setsize (trg, '-24 -24 -24', '24 24 24');
};

/*
=============
t_movetarget

Something has bumped into a movetarget.  If it is a monster
moving towards it, change the next destination and continue.
==============
*/
void() t_movetarget = {
	entity temp, targ, first;

	if (other.movetarget != self)
		return;
	
	if (other.enemy)
		return;		// fighting, not following a path


	// fire path_corner's targets
	if (self.target2 && self.target2 != "") {
		activator = other;
		SUB_UseSpecificTarget(self.target2, targetname);
	}
	if (self.target3 && self.target3 != "") {
		activator = other;
		SUB_UseSpecificTarget(self.target3, targetname);
	}
	if (self.target4 && self.target4 != "") {
		activator = other;
		SUB_UseSpecificTarget(self.target4, targetname);
	}

	temp = self;
	self = other;
	other = temp;

	if (self.classname == "monster_ogre")
		sound (self, CHAN_VOICE, "ogre/ogdrag.wav", 1, ATTN_IDLE);// play chainsaw drag sound

	first = targ = find(world, targetname, other.target);

	float loopcount;
	
	// loops if found path_corner isn't active
	while (targ && targ.estate != STATE_ACTIVE && loopcount < 3) {
		if (targ == first) loopcount++;
		targ = find(world, targetname, targ.target);
	}

	self.goalentity = self.movetarget = targ;

	self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
	if (!self.movetarget || other.wait == -1) {
		self.pausetime = time + 999999;
		self.th_stand ();
		return;
	}
	
	//if(self.flags & FL_PACIFIST)
	{
		if (other.wait > 0) {
			self.pausetime = time + other.wait;
			self.th_stand ();
		}
		
		if (other.angles) {
			self.ideal_yaw = other.angles_y;
		}
	}
};



//============================================================================

/*
=============
range

returns the range catagorization of an entity reletive to self
0	melee range, will become hostile even if back is turned
1	visibility and infront, or visibility and show hostile
2	infront and show hostile
3	only triggered by damage
=============
*/
float(entity targ) range =
{
	vector spot1, spot2;
	float r;	
	spot1 = self.origin + self.view_ofs;

	if (targ.solid == SOLID_BSP) 
		spot2 = (targ.absmin + targ.absmax)/2;
	else
		spot2 = targ.origin + targ.view_ofs;
	
	r = vlen (spot1 - spot2);
	if (r < 120)
		return RANGE_MELEE;
	if (r < 500)
		return RANGE_NEAR;
	if (r < 1000)
		return RANGE_MID;
	return RANGE_FAR;
};

/*======================================================================
 range_distance (target entity)
 	returns the vector distance between two points
======================================================================*/
float(entity targ, float flat2d) range_distance =
{
	local vector	spot1, spot2;
	local float		r;
		
	spot1 = self.origin + self.view_ofs;

	if (targ.solid == SOLID_BSP) 
		spot2 = (targ.absmin + targ.absmax)/2;
	else
		spot2 = targ.origin + targ.view_ofs;

	if (flat2d) { spot1_z = spot2_z = 0; }
	r = vlen (spot1 - spot2);
	
	return r;
};
/*
=============
visible

returns 1 if the entity is visible to self, even if not infront ()
=============
*/
float (entity targ) visible =
{
	local vector	spot1, spot2;
	float startinliquid, endinliquid;

	spot1 = self.origin + self.view_ofs;

	if (targ.solid == SOLID_BSP) 
		spot2 = (targ.absmin + targ.absmax)/2;
	else
		spot2 = targ.origin + targ.view_ofs;

	traceline (spot1, spot2, TRUE, self);	// see through other monsters
	
	//if (trace_inopen && trace_inwater)

	if (trace_inopen && trace_inwater)
		return FALSE;			// sight line crossed contents
	
	if (pointcontents2(spot1) <= CONTENT_WATER) startinliquid = TRUE;
	if (pointcontents2(trace_endpos) <= CONTENT_WATER) endinliquid = TRUE;
	if (startinliquid != endinliquid)
		return FALSE;

	if (trace_fraction == 1 || trace_ent == targ) {	
		return TRUE;
	}
	
	return FALSE;
};

float (entity org, entity targ) visible2 =
{
	local vector	spot1, spot2;
	float startinliquid, endinliquid;
	
	spot1 = org.origin + org.view_ofs;
	if (targ.solid == SOLID_BSP) 
		spot2 = (targ.absmin + targ.absmax)/2;
	else
		spot2 = targ.origin + targ.view_ofs;
	
	traceline (spot1, spot2, TRUE, org);	// see through other monsters
	
	if (trace_inopen && trace_inwater)
		return FALSE;			// sight line crossed contents

	if (pointcontents2(spot1) <= CONTENT_WATER) startinliquid = TRUE;
	if (pointcontents2(trace_endpos) <= CONTENT_WATER) endinliquid = TRUE;
	if (startinliquid != endinliquid)
		return FALSE;

	if (trace_fraction == 1 || trace_ent == targ)
		return TRUE;

	return FALSE;
};

/*
=============
canshoot

returns 1 if there are no entities in the way of the shot
=============
*/
float (entity targ) canshoot =
{
	vector spot1, spot2;
	float startinliquid, endinliquid;

	spot1 = self.origin + self.view_ofs;

	if (targ.solid == SOLID_BSP) 
		spot2 = (targ.absmin + targ.absmax)/2;
	else
		spot2 = targ.origin + targ.view_ofs;
	
	
	traceline (spot1, spot2, FALSE, self);  // don't see through other monsters

	if (trace_ent != targ) {
		return FALSE;		// don't have a clear shot
	}
			
	if (trace_inopen && trace_inwater)
		return FALSE;			// sight line crossed contents

	if (pointcontents2(spot1) <= CONTENT_WATER) startinliquid = TRUE;
	if (pointcontents2(trace_endpos) <= CONTENT_WATER) endinliquid = TRUE;
	if (startinliquid != endinliquid)
		return FALSE;
	
	return TRUE;
};

/*
=============
infront

returns 1 if the entity is in front (in sight) of self
=============
*/
float(entity targ) infront =
{
	local vector	vec;
	local float		dot;
	
	makevectors (self.angles);
	vec = normalize (targ.origin - self.origin);
	dot = vec * v_forward;
	
	if ( dot > 0.3)
	{
		return TRUE;
	}
	return FALSE;
};

/*======================================================================
 ai_checkmelee
  Check if the monster (self) can attack enemy (target)
  and returns TRUE if the monster is within XYZ range
======================================================================*/
float(float attackdist, float attackzaxis) ai_checkmelee =
{
	local vector	spot1, spot2;
	local float 	delta, zdiff;

	// Setup default
	if (attackzaxis <= 0) attackzaxis = 48;
	
	// Calculate distance and z axis difference seperate
	spot1 = SUB_entEnemyTarget().origin;
	spot2 = self.origin;
	zdiff = fabs(spot1_z - spot2_z);
	spot1_z = spot2_z = 0;				// Flatten Z axis before vector length
	delta = vlen(spot1 - spot2);		// Calculate vector distance

	// Is the enemy too far away and the zaxis is wrong (too low/high)
	if (delta <= attackdist && zdiff <= 48) return TRUE;
	else return FALSE;
};
//============================================================================

/*
===========
ChangeYaw

Turns towards self.ideal_yaw at self.yaw_speed
Sets the global variable current_yaw
Called every 0.1 sec by monsters
============
*/
/*

void() ChangeYaw =
{
	local float		ideal, move;

//current_yaw = self.ideal_yaw;
// mod down the current angle
	current_yaw = anglemod( self.angles_y );
	ideal = self.ideal_yaw;
	
	if (current_yaw == ideal)
		return;
	
	move = ideal - current_yaw;
	if (ideal > current_yaw)
	{
		if (move > 180)
			move = move - 360;
	}
	else
	{
		if (move < -180)
			move = move + 360;
	}
		
	if (move > 0)
	{
		if (move > self.yaw_speed)
			move = self.yaw_speed;
	}
	else
	{
		if (move < 0-self.yaw_speed )
			move = 0-self.yaw_speed;
	}

	current_yaw = anglemod (current_yaw + move);

	self.angles_y = current_yaw;
};

*/


//============================================================================

void() HuntTarget =
{
	if (self.startpath && self.startpath.classname == "path_angry") {
		if (self.flags & FL_FLY & FL_SWIM) {
			// todo
			dprint4(self.classname, " (", vtos(self.origin), "): path_angry doesn't work with fly/swimmonsters\n");
			self.goalentity = self.enemy;
			self.startpath = world;
		}
		else {
			dprint("Found path_angry, following\n");
			self.followingpath = TRUE;
			self.goalentity = self.startpath;
			self.oldenemy = self.enemy;
			self.startpath = world; // started following path, so don't do this again
		}
	}
	else {
		//dprint("path_angry not found\n");
		self.goalentity = self.enemy;
	}

	self.think = self.th_run;
	self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
	self.nextthink = time + 0.1;
	//eprint(self.goalentity);
	SUB_AttackFinished (1);	// wait a while before first attack
};


void() FoundTarget =
{
	if (self.enemy.classname == "player")
	{	// let other monsters see this monster for a while
		sight_entity = self;
		sight_entity_time = time;
	}

	if (self.spawnflags & MONSTER_WAKETRIGGER) {
		if (self.target4 != "") {
			activator = self.enemy;
			SUB_UseSpecificTarget(self.target4, targetname);
			self.target4 = "";
		}
	}

	self.show_hostile = time + 1;		// wake up other monsters

	// If you're looking for the bizarre SightSound function,
	// it was removed in favor of each monster having its own
	// sight function, stored in the monster's "th_sight" field,
	// and called here.
	if (self.th_sight && !(self.spawnflags & MONSTER_NOSIGHTSOUND)) self.th_sight();

	// initial jump when angry - from Copper
	if (self.movetype == MOVETYPE_STEP && self.movedir != '0 0 0') {
		self.velocity = self.movedir;
		self.flags &~= FL_ONGROUND;
		self.movedir = '0 0 0';	// don't leap again if an infight starts
	}

	// Optional wake function, in case the monster has some "going angry" animation.
	// This function needs to call HuntTarget() by itself afterwards.
	if (self.th_wake && !self.was_angry) self.th_wake();
	else HuntTarget();
};

/*
===========
FindTarget

Self is currently not attacking anything, so try to find a target

Returns TRUE if an enemy was sighted

When a player fires a missile, the point of impact becomes a fakeplayer so
that monsters that see the impact will respond as if they had seen the
player.

To avoid spending too much time, only a single client (or fakeclient) is
checked each frame.  This means multi player games will have slightly
slower noticing monsters.
============
*/
float() FindTarget =
{
	local entity	client;
	local float		r;

	if (self.enemy) self.was_angry = 1;
	else self.was_angry = 0;

// if the first spawnflag bit is set, the monster will only wake up on
// really seeing the player, not another monster getting angry

// spawnflags & 3 is a big hack, because zombie crucified used the first
// spawn flag prior to the ambush flag, and I forgot about it, so the second
// spawn flag works as well
	if (sight_entity_time >= time - 0.1 && !(self.spawnflags & 3) )
	{
		client = sight_entity;
		if (client.enemy == SUB_entEnemyTarget())
			return FALSE; //was just return;
	}
	else
	{
		client = checkclient ();
		if (!client)
			return FALSE;	// current check entity isn't in PVS
	}

	if (client == SUB_entEnemyTarget())
		return FALSE;

	if (client.flags & FL_NOTARGET)
		return FALSE;
	if (client.items & IT_INVISIBILITY)
		return FALSE;

	r = range (client);
	if (r == RANGE_FAR)
		return FALSE;
		
	if (!visible (client))
		return FALSE;

	if (r == RANGE_NEAR)
	{
		if (client.show_hostile < time && !infront (client))
			return FALSE;
	}
	else if (r == RANGE_MID)
	{
		if ( /* client.show_hostile < time || */ !infront (client))
			return FALSE;
	}

	//johnfitz don't react to the intermission camera players
	if (client.takedamage == DAMAGE_NO)
		return FALSE;	
	
	if(self.spawnflags & MONSTER_IGNOREPLAYER)
	{
		return FALSE;
	}
	
//
// got one
//
	if (self.enemy.type == "enemytarget") SUB_switchEnemyTarget();

	self.enemy = client;
	if (self.enemy.classname != "player")
	{
		self.enemy = self.enemy.enemy;
		if (self.enemy.classname != "player")
		{
			self.enemy = world;
			return FALSE;
		}
	}
	
	FoundTarget();

	return TRUE;
};


float() FindTargetProximity = {

	local entity	client;
	local float		r;

	if (self.enemy) self.was_angry = 1;
	else self.was_angry = 0;

	if (sight_entity_time >= time - 0.1 && !(self.spawnflags & 1) )
	{
		client = sight_entity;
		if (client.enemy == SUB_entEnemyTarget())
			return FALSE;
	}
	else
	{
		client = checkclient();
		if (!client)
			return FALSE;	// current check entity isn't in PVS
	}

	if (client == SUB_entEnemyTarget())
		return FALSE;

	if (client.flags & FL_NOTARGET)
		return FALSE;
	if (client.items & IT_INVISIBILITY)
		return FALSE;

	r = vlen(self.origin - client.origin + client.view_ofs);
		
	if (!visible(client))
		return FALSE;

	if (r >= 120 && r <= 384) {
		if (client.show_hostile < time)
			return FALSE;
	}
	else if (r > 384)
		return FALSE;

	//johnfitz don't react to the intermission camera players
	if (client.takedamage == DAMAGE_NO)
		return FALSE;
	
	if (self.spawnflags & MONSTER_IGNOREPLAYER)
		return FALSE;
	
//
// got one
//	
	if (self.enemy.type == "enemytarget") SUB_switchEnemyTarget();

	self.enemy = client;
	if (self.enemy.classname != "player")
	{
		self.enemy = self.enemy.enemy;
		if (self.enemy.classname != "player")
		{
			self.enemy = world;
			return FALSE;
		}
	}
	
	FoundTarget();

	return TRUE;
};

void(float dist) ai_run_path = {

	movetogoal2 (dist);
}

//=============================================================================

void(float dist) ai_forward =
{
	walkmove2 (self.angles_y, dist);
};

void(float dist) ai_back =
{
	walkmove2 ( (self.angles_y+180), dist);
};


/*
=============
ai_pain

stagger back a bit
=============
*/
void(float dist) ai_pain =
{
	ai_back (dist);
/*
	local float	away;
	
	away = anglemod (vectoyaw (self.origin - self.enemy.origin) 
	+ 180*(random()- 0.5) );
	
	walkmove (away, dist);
*/
};

/*
=============
ai_painforward

stagger back a bit
=============
*/
void(float dist) ai_painforward =
{
	walkmove2 (self.angles_y, dist); //johnfitz changed so movement is based on current yaw, not ideal_yaw, to match animation
};

/*
=============
ai_walk

The monster is walking it's beat
=============
*/
void(float dist) ai_walk =
{
//	local vector		mtemp;
	local vector vertdiff;

	movedist = dist;
	
	// check for noticing a player
	if (FindTarget ())
		return;

	if (self.flags & FL_FLY) {
		// Allow for some Z axis tolerance
		if (fabs(self.origin_z - self.goalentity.origin_z) > 16) {
			//if (self.move_elev == 0) self.move_elev = 8;
			if (self.origin_z < self.goalentity.origin_z) 
				self.origin_z = self.origin_z + 8;
			else
				self.origin_z = self.origin_z - 8;

			vertdiff = '0 0 0';
			vertdiff_x = fabs(self.goalentity.origin_x - self.origin_x);
			vertdiff_y = fabs(self.goalentity.origin_y - self.origin_y);
			// Are the path corners stacked on top of each other?
			if (vertdiff_x < 16 && vertdiff_y < 16) dist = 0;
		}
	}
	
	movetogoal2 (dist);
};


/*
=============
ai_stand

The monster is staying in one place for a while, with slight angle turns
=============
*/
void() ai_stand =
{
	if (FindTarget ())
		return;
	
	if (time > self.pausetime)
	{
		self.th_walk ();
		return;
	}
	
	if(self.flags & FL_PACIFIST)
	{
		ChangeYaw ();
	}
	
// change angle slightly

};

/*
=============
ai_turn

don't move, but turn towards ideal_yaw
=============
*/
void() ai_turn =
{
	if (FindTarget ())
		return;
	
	ChangeYaw ();
};

/*
=============
ai_turn_in_place

don't move, but turn towards ideal_yaw
=============
*/
void() ai_turn_in_place =
{
   local float delta;

   self.nextthink = time + 0.1;
   enemy_yaw = vectoyaw(SUB_entEnemyTarget().origin - self.origin);
   delta = fabs(self.angles_y - enemy_yaw);
   if (delta > 10)
      {
      self.ideal_yaw = enemy_yaw;
      ChangeYaw();
      }
   else
      {
      self.think = self.th_run;
      }
};


//=============================================================================

/*
=============
ChooseTurn
=============
*/
void(vector dest3) ChooseTurn =
{
	local vector	dir, newdir;
	
	dir = self.origin - dest3;

	newdir_x = trace_plane_normal_y;
	newdir_y = 0 - trace_plane_normal_x;
	newdir_z = 0;
	
	if (dir * newdir > 0)
	{
		dir_x = 0 - trace_plane_normal_y;
		dir_y = trace_plane_normal_x;
	}
	else
	{
		dir_x = trace_plane_normal_y;
		dir_y = 0 - trace_plane_normal_x;
	}

	dir_z = 0;
	self.ideal_yaw = vectoyaw(dir);	
};

/*
============
FacingIdeal

============
*/
float() FacingIdeal =
{
	local	float	delta;
	
	delta = anglemod(self.angles_y - self.ideal_yaw);
	if (delta > 45 && delta < 315)
		return FALSE;
	return TRUE;
};


//=============================================================================


/*
===========
CheckAttack

Default check-attack function
The player is in view, so decide to move or launch an attack
Returns FALSE if movement should continue
============
*/
float() CheckAttack =
{
	//local vector	spot1, spot2;	
	local entity	targ;
	local float		chance;

	if (self.flags & FL_FLY && self.enemy.type != "enemytarget") {
		if (SUB_setupEnemyTarget(self.enemy, self.above, MONAI_ABOVETIMER)) {
			self.enemy = self.enemytarget;
		}
	}

	targ = SUB_entEnemyTarget();

	if (!canshoot(targ)) {
		return FALSE;
	}

	if (enemy_range == RANGE_MELEE)
	{	// melee attack
		if (self.th_melee)
		{
			if (self.classname == "monster_knight"){
				knight_attack ();
			}
			else
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
		chance = 0.9;
		self.attack_finished = 0;
	}
	else if (enemy_range == RANGE_NEAR)
	{
		if (self.th_melee)
			chance = 0.2;
		else
			chance = 0.4;
	}
	else if (enemy_range == RANGE_MID)
	{
		if (self.th_melee)
			chance = 0.05;
		else
			chance = 0.1;
	}
	else
		chance = 0;

	if (self.goalentity.classname == "path_angry") chance = chance * 0.2;
	
	if (random () < chance)
	{
		self.th_missile ();
		SUB_AttackFinished (2*random());
		return TRUE;
	}

	return FALSE;
};

// monsters can have their own custom CheckAttack implementation
// if not, runs the default one

float() CheckAnyAttack =
{
	if (!enemy_vis)
		return FALSE; //was just return;

	if (self.th_checkattack)
		return self.th_checkattack();
	else
		return CheckAttack ();
};


/*
=============
ai_run_melee

Turn and close until within an angle to launch a melee attack
=============
*/
void() ai_run_melee =
{
	self.ideal_yaw = enemy_yaw;
	ChangeYaw ();

	if (FacingIdeal())
	{
		self.th_melee ();
		self.attack_state = AS_STRAIGHT;
	}
};


/*
=============
ai_run_missile

Turn in place until within an angle to launch a missile attack
=============
*/
void() ai_run_missile =
{
	self.ideal_yaw = enemy_yaw;
	ChangeYaw ();
	if (FacingIdeal())
	{
		self.th_missile ();
		self.attack_state = AS_STRAIGHT;
	}
};


/*
=============
ai_run_slide

Strafe sideways, but stay at aproximately the same range
=============
*/
void() ai_run_slide =
{
	local float	ofs;
	
	self.ideal_yaw = enemy_yaw;
	ChangeYaw ();
	if (self.lefty)
		ofs = 90;
	else
		ofs = -90;
	
	if (walkmove2 (self.ideal_yaw + ofs, movedist))
		return;
		
	self.lefty = 1 - self.lefty;
	
	walkmove2 (self.ideal_yaw - ofs, movedist);
};


/*
=============
ai_run

The monster has an enemy it is trying to kill
=============
*/
float(float dist) ai_run_checks =
{
//	local	vector	delta;
//	local	float	axis;
//	local	float	direct, ang_rint, ang_floor, ang_ceil;
	
	movedist = dist;
	entity enem;
	enem = SUB_entEnemyTarget();
	

	/*if (self.goalentity.classname == "path_angry"){
		if (vlen(self.origin - self.goalentity.origin) < (self.size_x + 32)){
			dprint("Disabling enemy\n");
			self.enemy = world;
			ai_run_path(dist);
			return;
		}
		else
			self.enemy = self.oldenemy;

	}*/
	// see if the enemy is dead
	//johnfitz added enemy.takedamage check to ignore players once intermission starts.
	if ((enem.health <= 0 || enem.takedamage == DAMAGE_NO) && self.goalentity.classname != "path_angry") 
	{
		//dprint("Enemy is ded\n");
		if (self.enemy.type == "enemytarget") SUB_switchEnemyTarget(); // disable enemy target system while changing enemies
		self.enemy = world;
	// FIXME: look all around for other targets
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
			return FALSE;
		}
	}

	self.show_hostile = time + 1;		// wake up other monsters
	
// check knowledge of enemy
	enemy_vis = visible(enem);
	if (enemy_vis)
		self.search_time = time + 5;
	// disable enemy target for flying monsters when enemy isn't visible
	else if (self.enemy.type == "enemytarget") SUB_switchEnemyTarget();

// look for other coop players
	if (coop && self.search_time < time && enem.classname != "path_angry")
	{
		if (FindTarget ())
			return FALSE;
	}

	enemy_infront = infront(enem);
	enemy_range = range(enem);

	if (self.goalentity.classname == "path_angry") enemy_yaw = vectoyaw(self.goalentity.origin - self.origin);
	else enemy_yaw = vectoyaw(enem.origin - self.origin);

	if (self.attack_state == AS_MISSILE)
	{
//dprint ("ai_run_missile\n");
		ai_run_missile ();
		return FALSE;
	}
	if (self.attack_state == AS_MELEE)
	{
//dprint ("ai_run_melee\n");
		ai_run_melee ();
		return FALSE;
	}

	if (CheckAnyAttack ()) {
		return FALSE;					// beginning an attack
	}
	if (self.attack_state == AS_SLIDING && self.goalentity.classname != "path_angry")
	{
		ai_run_slide ();
		return FALSE;
	}
	else if (self.attack_state == AS_SLIDING) self.attack_state = 0;

	return TRUE;
	// head straight in
	//movetogoal2 (dist);
};

void(float dist) ai_run = {
	if (!ai_run_checks(dist)) return;

	//if (self.th_move)
	//	self.th_move(dist);
	//else 
		movetogoal2(dist);
}

void(float dist) ai_runjump = {
	if (!ai_run_checks(dist)) return;
	movetogoaljump(dist);
}

/*
=============
ai_run_away
=============
*/
void(float dist) ai_run_away =
{
	movedist = dist;
	entity enem;
	enem = SUB_entEnemyTarget();
	
	// see if the enemy is dead
	//johnfitz added enemy.takedamage check to ignore players once intermission starts.
	if (enem.health <= 0 || enem.takedamage == DAMAGE_NO)
	{
		if (self.enemy.type == "enemytarget") SUB_switchEnemyTarget();
		self.enemy = world;
		if (self.oldenemy.health > 0)
		{
			self.enemy = self.oldenemy;
			//HuntTarget ();
		}
		else
		{
			if (self.movetarget)
				self.th_walk ();
			else
				self.th_stand ();
			return;
		}
	}

	self.show_hostile = time + 1;		// wake up other monsters

// check knowledge of enemy
	enemy_vis = visible(enem);
	if (enemy_vis)
		self.search_time = time + 5;

// look for other coop players
	if (coop && self.search_time < time)
	{
		if (FindTarget ())
			return;
	}

	if (self.goalentity.classname == "path_angry") self.ideal_yaw = vectoyaw(self.origin - self.goalentity.origin);
	else self.ideal_yaw = vectoyaw(self.origin - enem.origin);
		
	//enemy_infront = infront(self.enemy);
	enemy_range = range(self.enemy);
	
	if(enemy_range >= RANGE_MID)
	{
		if (self.enemy.type == "enemytarget") SUB_switchEnemyTarget();
		self.enemy = world;
		self.pausetime = time + 999999;
		self.th_stand ();
		return;
	}
	else if(enemy_range <= RANGE_MELEE)
	{
		self.angles_y = self.ideal_yaw;
		walkmove2(self.ideal_yaw, dist);
		return;
	}
	
// head straight in
	movetogoal2 (dist);		// done in C code...
};


/*
=============
ai_face

Stay facing the enemy
=============
*/
void() ai_face =
{
	self.ideal_yaw = vectoyaw(SUB_entEnemyTarget().origin - self.origin);
	ChangeYaw ();
};

/*
=============
ai_charge

The monster is in a melee attack, so get as close as possible to .enemy
=============
*/
float (entity targ) visible;
float(entity targ) infront;
float(entity targ) range;

void(float d) ai_charge =
{
	ai_face ();	
	movetogoal2 (d);		// done in C code...
};

void(float d) ai_chargejump =
{
	ai_face ();	
	movetogoaljump (d);		// done in C code...
};


void() ai_charge_side =
{
	local	vector	dtemp;
	local	float	heading;
	entity enem;
	enem = SUB_entEnemyTarget();
	
// aim to the left of the enemy for a flyby

	self.ideal_yaw = vectoyaw(enem.origin - self.origin);
	ChangeYaw ();

	makevectors (self.angles);
	dtemp = enem.origin - 30*v_right;
	heading = vectoyaw(dtemp - self.origin);
	
	walkmove2(heading, 20);
};


/*
=============
ai_melee

=============
*/
void() ai_melee =
{
	local vector	delta;
	local float 	ldmg;
	entity enem;
	enem = SUB_entEnemyTarget();

	if (!enem)
		return;		// removed before stroke
		
	delta = enem.origin - self.origin;

	if (vlen(delta) > 60)
		return;
		
	ldmg = (random() + random() + random()) * 3;
	T_Damage(enem, self, self, ldmg, DMGTYPE_MELEE);
};


void() ai_melee_side =
{
	local vector	delta;
	local float 	ldmg;
	entity enem;
	enem = SUB_entEnemyTarget();

	if (!enem)
		return;		// removed before stroke
		
	ai_charge_side();
	
	delta = enem.origin - self.origin;

	if (vlen(delta) > 60)
		return;
	if (!CanDamage (enem, self.origin))
		return;
	ldmg = (random() + random() + random()) * 3;
	T_Damage(enem, self, self, ldmg, DMGTYPE_MELEE);
};
