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

	if (!self.target)
		return;

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
		total_monsters = total_monsters + 1;
		update_hud_totals(HUD_MONSTERS);
	}

	self.think1();
}
//johnfitz

void(entity e, void() go_function) init_spawned_monster = {

	//PREACH: This monster is to be teleported in
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
		if (!(self.spawnflags & MONSTER_COUNTONSPAWN)) total_monsters++;
	}
	else {
		// delay drop to floor to make sure all doors have been spawned
		// spread think times so they don't all happen at same time
		self.nextthink = self.nextthink + random()*0.5;
		self.think = go_function;
		total_monsters++;
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
		if (self.spawnflags & MONSTER_COUNTONSPAWN)
		{
			total_monsters++;
			update_hud_totals(HUD_MONSTERS);
		}	
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