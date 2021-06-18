/* ALL MONSTERS SHOULD BE 1 0 0 IN COLOR */

// name =[framenum,	nexttime, nextthink] {code}
// expands to:
// name ()
// {
//		self.frame=framenum;
//		self.nextthink = time + nexttime;
//		self.think = nextthink
//		<code>
// };

void(float qt) add_monster_total = {
	total_monsters += qt;
	update_hud_totals(HUD_MONSTERS);
}

/*
================
monster_use

Using a monster makes it angry at the current activator
================
*/
void() monster_use =
{
	if (self.enemy)
		return;
	if (self.health <= 0)
		return;
	if (activator.items & IT_INVISIBILITY)
		return;
	if (activator.flags & FL_NOTARGET)
		return;
	if (activator.classname != "player")
		return;
	
// delay reaction so if the monster is teleported, its sound is still
// heard
	self.enemy = activator;
	self.nextthink = time + 0.1;
	self.think = FoundTarget;
};

/*
================
monster_death_use

When a mosnter dies, it fires all of its targets with the current
enemy as activator.
================
*/

void() monster_death_use =
{
//	local entity 	ent, otemp, stemp;

// fall to ground
	if (self.flags & FL_FLY)
		self.flags = self.flags - FL_FLY;
	if (self.flags & FL_SWIM)
		self.flags = self.flags - FL_SWIM;

	//if (!self.target)
	//	return;

	activator = self.enemy;
	SUB_UseTargets ();
};


//============================================================================

void(vector org) spawn_tfog;
void(vector org, entity death_owner) spawn_tdeath;

void(entity e) hide_spawned_monster_entity = {
	//store the important info in unused fields
	e.mdl = e.model;
	e.pos1 = e.mins;
	e.pos2 = e.maxs;
	e.walkframe = e.solid;
	e.fly_sound = e.movetype;

	//hide the model and make it non-solid
	e.model = "";
	e.solid = SOLID_NOT;
	e.movetype = MOVETYPE_NONE;
}

void(entity e) show_spawned_monster_entity = {
	e.solid = e.walkframe;
	e.movetype = e.fly_sound;
	setmodel(e, e.mdl);
	setsize (e, e.pos1, e.pos2);
}

// spawn trigger-spawned monster
void() spawn_monster = {

	show_spawned_monster_entity(self);

	if (self.trigger_field) show_spawned_monster_entity(self.trigger_field); // Double-entity monster

	//telefrag any existing entities
	spawn_tdeath (self.origin, self); 

	//sound and particle effects	
	if (!(self.spawnflags & MONSTER_SPAWNSILENT))
		spawn_tfog (self.origin);	

	self.flags = self.flags - FL_SPAWNMONSTER;

	if (self.spawnflags & MONSTER_COUNTONSPAWN) {
		add_monster_total(1);
	}

	self.think1();
}
//johnfitz

void(entity e, void() go_function) init_spawned_monster = {

	e.flags = e.flags | FL_SPAWNMONSTER;
	
	hide_spawned_monster_entity(e);

	// Double-entity Malice monsters must have both parts hidden.
	// Secondary entity is always stored in the trigger_field field so we check that
	if (e.trigger_field) hide_spawned_monster_entity(e.trigger_field);

	//set up the teleport functions

	e.use = spawn_monster;
	e.think1 = go_function;
}

void(void() go_function) monster_start = {

	if (cvar("nomonsters") != 0) {
		if(self.trigger_field) remove(self.trigger_field);
		remove(self);
		return;
	}

	if (self.spawnflags & MONSTER_SPAWNTRIGGERED) {
		init_spawned_monster(self, go_function);
		if (!(self.spawnflags & MONSTER_COUNTONSPAWN)) add_monster_total(1);
	}
	else {
		// delay drop to floor to make sure all doors have been spawned
		// spread think times so they don't all happen at same time
		self.nextthink = self.nextthink + random()*0.5;
		self.think = go_function;

		if (!(self.spawnflags & MONSTER_SPAWNER && !(self.spawnflags & MONSTER_COUNTONSPAWN))) add_monster_total(1);
	}
}

void(void() go_function) pacifist_start = {

	if (cvar("nomonsters") != 0) 
	{
		if(self.trigger_field) remove(self.trigger_field);
		remove(self);
		return;
	}
	
	if (self.spawnflags & MONSTER_SPAWNTRIGGERED) 
	{
		init_spawned_monster(self, go_function);
	}
	else 
	{
		if (self.spawnflags & MONSTER_COUNTONSPAWN) add_monster_total(1);
		// delay drop to floor to make sure all doors have been spawned
		// spread think times so they don't all happen at same time
		self.nextthink = self.nextthink + random()*0.5;
		self.think = go_function;
	}
};

//============================================================================
// go functions
//============================================================================

void() walkmonster_start_go =
{

	self.origin_z = self.origin_z + 1;	// raise off floor a bit
	droptofloor();
	
	if (!walkmove(0,0))
	{
		dprint ("walkmonster in wall at: ");
		dprint (vtos(self.origin));
		dprint ("\n");
	}
	
	self.takedamage = DAMAGE_AIM;

	self.ideal_yaw = self.angles * '0 1 0';
	if (!self.yaw_speed)
		self.yaw_speed = 20;
	self.view_ofs = '0 0 25';
	self.use = monster_use;
	
	self.flags = self.flags | FL_MONSTER;
	
	if (self.target != "")
	{
		self.goalentity = self.movetarget = find(world, targetname, self.target);
		self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
		if (!self.movetarget)
		{
			dprint ("Monster can't find target at ");
			dprint (vtos(self.origin));
			dprint ("\n");
		}
// this used to be an objerror
		if (self.movetarget.classname == "path_corner")
			self.th_walk ();
		else {
			self.pausetime = 99999999;
			self.th_stand ();
		}
	}
	else
	{
		self.pausetime = 99999999;
		self.th_stand ();
	}

	if (!(self.spawnflags & MONSTER_SPAWNTRIGGERED))
		// spread think times so they don't all happen at same time
		self.nextthink = self.nextthink + random()*0.5;

	if (self.spawnflags & MONSTER_SPAWNANGRY)
		monster_use();
};

void() flymonster_start_go =
{
	self.takedamage = DAMAGE_AIM;

	self.ideal_yaw = self.angles * '0 1 0';
	if (!self.yaw_speed)
		self.yaw_speed = 10;
	self.view_ofs = '0 0 25';
	self.use = monster_use;

	self.flags = self.flags | FL_FLY;
	self.flags = self.flags | FL_MONSTER;

	if (!walkmove(0,0))
	{
		dprint ("flymonster in wall at: ");
		dprint (vtos(self.origin));
		dprint ("\n");
	}

	if (self.target)
	{
		self.goalentity = self.movetarget = find(world, targetname, self.target);
		if (!self.movetarget)
		{
			dprint ("Monster can't find target at ");
			dprint (vtos(self.origin));
			dprint ("\n");
		}
// this used to be an objerror
		if (self.movetarget.classname == "path_corner")
			self.th_walk ();
		else {
			self.pausetime = 99999999;
			self.th_stand ();
		}
	}
	else
	{
		self.pausetime = 99999999;
		self.th_stand ();
	}

	if (!(self.spawnflags & MONSTER_SPAWNTRIGGERED))
		// spread think times so they don't all happen at same time
		self.nextthink = self.nextthink + random()*0.5;

	if(self.spawnflags & MONSTER_SPAWNANGRY) monster_use();
};

void() swimmonster_start_go =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}

	self.takedamage = DAMAGE_AIM;
	
	self.ideal_yaw = self.angles * '0 1 0';
	if (!self.yaw_speed)
		self.yaw_speed = 10;
	self.view_ofs = '0 0 10';
	self.use = monster_use;
	
	self.flags = self.flags | FL_SWIM;
	self.flags = self.flags | FL_MONSTER;

	if (self.target)
	{
		self.goalentity = self.movetarget = find(world, targetname, self.target);
		if (!self.movetarget)
		{
			dprint ("Monster can't find target at ");
			dprint (vtos(self.origin));
			dprint ("\n");
		}
		// this used to be an objerror
		self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
		self.th_walk ();
	}
	else
	{
		self.pausetime = 99999999;
		self.th_stand ();
	}

	if (!(self.spawnflags & MONSTER_SPAWNTRIGGERED))
		// spread think times so they don't all happen at same time
		self.nextthink = self.nextthink + random()*0.5;

	if(self.spawnflags & MONSTER_SPAWNANGRY) monster_use();
};

//============================================================================
// start functions
//============================================================================

void() walkmonster_start = {monster_start(walkmonster_start_go);};

void() flymonster_start = {monster_start(flymonster_start_go);};

void() swimmonster_start = {monster_start(swimmonster_start_go);};

void() walkpacifist_start = {pacifist_start(walkmonster_start_go);};




//============================================================================
// Monster spawner by bmFbr
//============================================================================


void() monster_spawned_trytostart = {
	local entity nearby;

	if (self.cnt > 15) { // tries to spawn for a few seconds, if not successful remove itself
		remove(self);
		return;
	}



	 // telefrag check from progs_dump
	nearby = findradius(self.origin, self.size_x * 2); // findradius (vector origin, float radius in Quake units)

	while (nearby)	{
		if (nearby.takedamage) {
			dprint(self.classname);dprint(" spawner: Monster waiting to spawn\n");
			self.nextthink = time + 1; //delay the spawn by 1 second and try again;
			self.cnt++;
			return;
		}
		nearby = nearby.chain;
	}

	self.cnt = 0; // reset cnt in case it's used by the spawned monster's start function

	if (self.owner) {// updates the spawner's counters

		if (self.owner.count >= self.owner.totalspawncount && self.owner.totalspawncount > 0) {
			remove(self);
			return;
		}
		self.owner.cnt++; // monsters alive count (decreased after death)
		self.owner.count++; // total monsters spawned
	}

	self.start_function(self);

	if (!(self.spawnflags & MONSTER_SPAWNSILENT)) // shows telefog by default
		spawn_tfog (self.origin);
};

void(void(entity mon) start_function_parm) monster_spawner = {
	local entity e;

	
	if (!self.spawncount) self.spawncount = 10;
	// Spawner's "cnt" field stores how many monsters spawned by this entity are alive at the moment.
	// It's increased on spawn and decreased on death (linked by the spawned entity's "owner" field)

	if (self.cnt >= self.spawncount && self.spawncount > 0){
		dprint(self.classname);dprint(" spawner: alive limit reached (");dprint(ftos(self.cnt));dprint(")\n");
		return;
	}

	if (self.count >= self.totalspawncount && self.totalspawncount > 0){
		dprint(self.classname);dprint(" spawner: total limit reached (");dprint(ftos(self.count));dprint(")\n");
		return;
	}

	e = spawn();
	e.classname = self.classname;
	e.target = self.target;
	e.target2 = self.target2;
	e.target3 = self.target3;
	e.target4 = self.target4;
	setorigin(e, self.origin);
	e.angles = self.angles;
	e.spawnflags = self.spawnflags | MONSTER_SPAWNANGRY; // always spawn angry


	if (self.totalspawncount > 0 && !(self.spawnflags & MONSTER_COUNTONSPAWN)) 
		// spawner has a total spawn count set and the "count on spawn" flag is disabled, so its total was already counted
		e.spawnflags = e.spawnflags - (e.spawnflags & MONSTER_COUNTONSPAWN);
	else 
		e.spawnflags = e.spawnflags | MONSTER_COUNTONSPAWN;

	e.owner = self;

	e.start_function = start_function_parm; // stores the start function to be called later
	setsize(e, self.mins, self.maxs); // size needs to be set now for the telefrag check

	e.think = monster_spawned_trytostart;
	e.nextthink = time + 0.02;

}

void() monster_spawner_updatecounter = {
	if (self.totalspawncount > 0 && !(self.spawnflags & MONSTER_COUNTONSPAWN)) {
		 add_monster_total(self.totalspawncount);
	}
};


//============================================================================
// unused nomonster code from Copper
//============================================================================


/*
void() nomonster_go =
{
	// a nomonster still has to be a solid so that it can be teleported out of teleboxes
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_FLY;
	setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);
	self.think = SUB_Null;
	self.view_ofs = '0 0 25';
	self.nextthink = time + 0.2 + random();
}

float() nomonster =
{
	if (cvar("nomonsters") == 0)
		return FALSE;
	
	if (self.target == string_null &&
		self.target2 == string_null &&
		self.target3 == string_null &&
		self.target4 == string_null &&
		self.killtarget == string_null)
	{
		remove(self);
		return TRUE;
	}
	
	// make teleports work:
	self.health = 1;
	self.flags += FL_MONSTER;
	
	if (self.targetname != string_null && self.spawnflags & SPAWN_TRIGGERED)
		self.use = nomonster_go;
	else
		nomonster_go();
	
	//self.classname = "nomonster";
	
	return TRUE;
}
*/