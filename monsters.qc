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
If the activator is a monster with a valid enemy, inherit it
If isn't a player nor a monster, look for the closest player
================
*/
void() monster_use =
{
	entity e, next;

	// don't change enemy if already angry at something
	if (self.enemy)
		return;
	// don't angry when dead, not good
	if (self.health <= 0)
		return;

	// hipnotic's laser gun ricochet hack
	if (self.lastvictim) {
		e = self.lastvictim;
		self.lastvictim = world;
	}

	else e = activator;

	// activator *is* a player, but has invisibility/notarget, so do nothing
	if (e.flags & FL_CLIENT && (e.items & IT_INVISIBILITY || e.flags & FL_NOTARGET)) {
		return;
	}

	// activator is a monster, so inherit its enemies if they're alive
	if (e.flags & FL_MONSTER && e.enemy.health > 0) {
		self.oldenemy = e.oldenemy;
		e = e.enemy;
	}	
	// activator isn't a living player, nor a monster with a valid enemy, so look for the closest non-invisible player alive
	else if (!(e.flags & FL_CLIENT) || e.health <= 0) {
		float closestdist = 99999999;
		float nextdist;
		next = find(world, classname, "player");
		while (next) {
			nextdist = vlen(self.origin - next.origin);
			if (nextdist < closestdist &&
				!(next.items & IT_INVISIBILITY || next.flags & FL_NOTARGET) &&
				next.health > 0
			){
				e = next;
				closestdist = nextdist;
			}
			next = find(next, classname, "player");
		}
		// no player found that satisfies those conditions
		if (!e) return;
	}
	// otherwise simply use activator as enemy


	// delay reaction so if the monster is teleported, its sound is still
	// heard
	self.enemy = e;
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
void() spawn_monster;

void() spawn_monster_use = {
	if (self.delay) {
		self.think = spawn_monster;
		self.nextthink = time + self.delay;
	}
	else
		spawn_monster();
};

void() spawn_monster = {

	show_spawned_monster_entity(self);

	if (self.trigger_field) show_spawned_monster_entity(self.trigger_field); // Double-entity monster

	//telefrag any existing entities
	spawn_tdeath (self.origin, self); 

	//sound and particle effects	
	if (!(self.spawnflags & MONSTER_SPAWNSILENT))
		spawn_tfog (self.origin);	

	self.flags = self.flags - FL_UNSPAWNEDMONSTER;
	self.flags = self.flags | FL_SPAWNEDMONSTER;

	if (self.spawnflags & MONSTER_COUNTONSPAWN) {
		add_monster_total(1);
	}

	self.think1();
}
//johnfitz

void(entity e, void() go_function) init_spawned_monster = {

	e.flags = e.flags | FL_UNSPAWNEDMONSTER;
	
	hide_spawned_monster_entity(e);

	// Double-entity Malice monsters must have both parts hidden.
	// Secondary entity is always stored in the trigger_field field so we check that
	if (e.trigger_field) hide_spawned_monster_entity(e.trigger_field);

	//set up the teleport functions

	e.use = spawn_monster_use;
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

void() search_path_angry = {
	entity path;
	if (self.target)
		path = find(world, targetname, self.target);
	if (self.target2 && path.classname != "path_angry")
		path = find(world, targetname, self.target2);
	if (self.target3 && path.classname != "path_angry")
		path = find(world, targetname, self.target3);
	if (self.target4 && path.classname != "path_angry")
		path = find(world, targetname, self.target4);
	if (path) {
		self.startpath = path;
	}
}

//============================================================================
// go functions
//============================================================================

void() walkmonster_start_go =
{

	self.origin_z = self.origin_z + 1;	// raise off floor a bit
	if (!(self.flags & FL_SPAWNEDMONSTER)) droptofloor();
	
	if (!walkmove2(0,0))
	{
		dprint ("walkmonster in wall at: ");
		dprint (vtos(self.origin));
		dprint ("\n");
	}
	
	search_path_angry();
	
	self.takedamage = DAMAGE_AIM;

	self.max_health = self.health;

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

	self.max_health = self.health;

	self.ideal_yaw = self.angles * '0 1 0';
	if (!self.yaw_speed)
		self.yaw_speed = 10;
	self.view_ofs = '0 0 25';
	self.use = monster_use;

	self.flags = self.flags | FL_FLY;
	self.flags = self.flags | FL_MONSTER;

	if (!walkmove2(0,0))
	{
		dprint ("flymonster in wall at: ");
		dprint (vtos(self.origin));
		dprint ("\n");
	}

	// path_angry doesn't work well with flying monsters
	search_path_angry();

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
	
	self.max_health = self.health;
	
	self.ideal_yaw = self.angles * '0 1 0';
	if (!self.yaw_speed)
		self.yaw_speed = 10;
	self.view_ofs = '0 0 10';
	self.use = monster_use;

	search_path_angry();

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

	if (self.cnt > 45) { // tries to spawn for a few seconds, if not successful remove itself
		dprint2(self.classname, " spawner: Monster couldn't spawn, giving up\n");
		remove(self);
		return;
	}



	 // telefrag check from progs_dump
	nearby = findradius(self.origin, self.size_x * 2); // findradius (vector origin, float radius in Quake units)

	while (nearby)	{
		if (nearby.takedamage) {
			dprint2(self.classname, " spawner: Monster spawn blocked, will try again in 1s\n");
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

	self.flags = self.flags | FL_SPAWNEDMONSTER; // sets the monster's spawntriggered flag to check for droptofloor later
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
	e.bloodtype = self.bloodtype;
	e.above = self.above;
	e.cmins = self.cmins;
	e.cmaxs = self.cmaxs;
	e.spawnflags = self.spawnflags | MONSTER_SPAWNANGRY; // always spawn angry


	if (self.totalspawncount > 0 && !(self.spawnflags & MONSTER_COUNTONSPAWN)) 
		// spawner has a total spawn count set and the "count on spawn" flag is disabled, so its total was already counted
		e.spawnflags = e.spawnflags - (e.spawnflags & MONSTER_COUNTONSPAWN);
	else 
		e.spawnflags = e.spawnflags | MONSTER_COUNTONSPAWN;

	e.owner = self;

	e.start_function = start_function_parm; // stores the start function to be called later
	setsize(e, self.mins, self.maxs); // size needs to be set now for the telefrag check

	e.lastvictim = activator;
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