
/*
=============================================================================

				LEVEL CHANGING / INTERMISSION

=============================================================================
*/

float	intermission_running;
float	intermission_exittime;
string 	intermission_message;

/*QUAKED info_intermission (1 0.5 0.5) (-16 -16 -16) (16 16 16)
This is the camera point for the intermission.
Use mangle instead of angle, so you can set pitch or roll as well as yaw.  'pitch yaw roll'
*/
void() info_intermission = {
	if (!SUB_InitEntity()) return;
};

// engine sysdef function. Called automatically for every client on map change
void() SetChangeParms = {
	// mapvars and playerstart id for the next map are always passed down
	parm12 = playerstart_id;
	parm15 = mapvars[0];
	parm16 = mapvars[1];

	// set by changelevel_touch if trigger_changelevel has a "reset items on map change" flag
	if (reset_items_on_map_change) {
		SetNewParms ();
		return;
	}

	// jump boots persists across levels. even if player is dead on map change
	if (self.jboots_finished) parm11 = self.jboots_prevlimit;
	else parm11 = self.jboots_rechargelimit;
	
	if (!parm11) self.items = self.items - (self.items & IT_JBOOTS);
	

	// player dead, reset inventory? why?
	if (self.health <= 0) {
		SetNewParms ();
		return;
	}

// remove items
	self.items = self.items - (self.items & 
		(IT_KEY1 | IT_KEY2 | IT_INVISIBILITY | IT_INVULNERABILITY | IT_SUIT | IT_QUAD | IT_TRIFECTA)
	);
	
// cap super health
	if (self.health > 100)
		self.health = 100;
	if (self.health < 50)
		self.health = 50;
	parm1 = self.items;
	parm2 = self.health;
	parm3 = self.armorvalue;
	if (self.ammo_shells < 25)
		parm4 = 25;
	else
		parm4 = self.ammo_shells;
	parm5 = self.ammo_nails;
	parm6 = self.ammo_rockets;
	parm7 = self.ammo_cells;
	parm8 = self.weapon;
	parm9 = self.armortype * 100;
	parm10 = self.weapons;
	
};

void() SetNewParms = {
	parm1 = WEAPON_SHOTGUN; // items + HUD weapons only, axe isn't needed here
	parm2 = 100; // health
	parm3 = 0; // armor value
	parm4 = 25; // shells
	parm5 = 0; // nails
	parm6 = 0; // rockets
	parm7 = 0; // cells
	parm8 = WEAPON_SHOTGUN; // current weapon
	parm9 = 0; // armor type
	parm10 = WEAPON_SHOTGUN | WEAPON_AXE; // weapons
	parm11 = 0; // jump boot recharge limit
	
	// Are map variables live?
	if (mapvar_cvar) dprint("\b[CLIENT]\b LIVE Map Variables Detected\n");
	else {
		dprint("\b[CLIENT]\b RESETTING Map Variables\n");
		// Reset map variables ready for use
		parm15 = 0;
		parm16 = 0;
		mapvar_reset();
	}
};

void(entity cl, entity base) TakeAndGiveWeapons = {
	cl.weapons -= cl.weapons & base.take_weapons;
	cl.weapons = cl.weapons | (base.give_weapons & ALL_WEAPONS);

	cl.items -= cl.items & base.take_weapons & HUD_WEAPONS;
	cl.items = cl.items | (base.give_weapons & HUD_WEAPONS);

	if (base.ammo_shells > 0) cl.ammo_shells = base.ammo_shells;
	else if(base.ammo_shells == -1) cl.ammo_shells = 0;

	if (base.ammo_nails > 0) cl.ammo_nails = base.ammo_nails;
	else if(base.ammo_nails == -1) cl.ammo_nails = 0;

	if (base.ammo_rockets > 0) cl.ammo_rockets = base.ammo_rockets;
	else if(base.ammo_rockets == -1) cl.ammo_rockets = 0;

	if (base.ammo_cells > 0) cl.ammo_cells = base.ammo_cells;
	else if(base.ammo_cells == -1) cl.ammo_cells = 0;

	//if player is wielding a removed or ammo-less weapon
	if(!(cl.weapon & cl.weapons) || W_CheckWeapon(cl.weapon, cl) < WEAPONSTAT_AVAILABLE) {
		W_ChangeWeapon(W_BestWeaponParms(cl.weapons, cl, 0));
	}
};

void() DecodeLevelParms = {
	float prev_mapvar_cvar;
	prev_mapvar_cvar = mapvar_cvar;

	dprint("\b[CLIENT]\b Decode (Level) Parms\n");
	// Map Variables are active (do not reset)
	mapvar_cvar = TRUE;
	
	// take away all stuff on starting new episode
	// or if set in worldspawn
	if ((serverflags && world.model == "maps/start.bsp") || world.reset_items)
		SetNewParms ();
	
	self.items = parm1;
	self.weapons = parm10;
	self.health = parm2;
	self.armorvalue = parm3;
	self.ammo_shells = parm4;
	self.ammo_nails = parm5;
	self.ammo_rockets = parm6;
	self.ammo_cells = parm7;
	self.weapon = parm8;
	self.armortype = parm9 * 0.01;
	self.jboots_rechargelimit = parm11;

	playerstart_id = parm12;

	if (!prev_mapvar_cvar) {
		mapvars[0] = parm15;
		mapvars[1] = parm16;
	}

	TakeAndGiveWeapons(self, world);
};


void(entity client, string savename) autosave = {
	//autosavename = savename;
	stuffcmd(client, "echo Autosaving...; wait; save ");
	stuffcmd(client, savename);
	stuffcmd(client, "\n");
}


string nextmap;
void() GotoNextMap = {
	if (cvar("samelevel"))	// if samelevel is set, stay on same level
		changelevel (mapname);
	else
		changelevel (nextmap);
};

void() ExitIntermission =
{
// skip any text in deathmatch
	if (deathmatch)	{
		GotoNextMap ();
		return;
	}
	
	intermission_exittime = time + 1;
	intermission_running = intermission_running + 1;

	//
	// run some text if at the end of an episode, or when set as 'message' on a trigger_changelevel
	//
	if (intermission_running == 2) {
		if (intermission_message == "") {
			if (world.model == "maps/e1m7.bsp" && !cvar("registered"))
				intermission_message = "As the corpse of the monstrous entity\nChthon sinks back into the lava whence\nit rose, you grip the Rune of Earth\nMagic tightly. Now that you have\nconquered the Dimension of the Doomed,\nrealm of Earth Magic, you are ready to\ncomplete your task in the other three\nhaunted lands of Quake. Or are you? If\nyou don't register Quake, you'll never\nknow what awaits you in the Realm of\nBlack Magic, the Netherworld, and the\nElder World!";
			else if (world.model == "maps/e1m7.bsp")
				intermission_message = "As the corpse of the monstrous entity\nChthon sinks back into the lava whence\nit rose, you grip the Rune of Earth\nMagic tightly. Now that you have\nconquered the Dimension of the Doomed,\nrealm of Earth Magic, you are ready to\ncomplete your task. A Rune of magic\npower lies at the end of each haunted\nland of Quake. Go forth, seek the\ntotality of the four Runes!";
			else if (world.model == "maps/e2m6.bsp")
				intermission_message = "The Rune of Black Magic throbs evilly in\nyour hand and whispers dark thoughts\ninto your brain. You learn the inmost\nlore of the Hell-Mother; Shub-Niggurath!\nYou now know that she is behind all the\nterrible plotting which has led to so\nmuch death and horror. But she is not\ninviolate! Armed with this Rune, you\nrealize that once all four Runes are\ncombined, the gate to Shub-Niggurath's\nPit will open, and you can face the\nWitch-Goddess herself in her frightful\notherworld cathedral.";
			else if (world.model == "maps/e3m6.bsp")
				intermission_message = "The charred viscera of diabolic horrors\nbubble viscously as you seize the Rune\nof Hell Magic. Its heat scorches your\nhand, and its terrible secrets blight\nyour mind. Gathering the shreds of your\ncourage, you shake the devil's shackles\nfrom your soul, and become ever more\nhard and determined to destroy the\nhideous creatures whose mere existence\nthreatens the souls and psyches of all\nthe population of Earth.";
			else if (world.model == "maps/e4m7.bsp")
				intermission_message = "Despite the awful might of the Elder\nWorld, you have achieved the Rune of\nElder Magic, capstone of all types of\narcane wisdom. Beyond good and evil,\nbeyond life and death, the Rune\npulsates, heavy with import. Patient and\npotent, the Elder Being Shub-Niggurath\nweaves her dire plans to clear off all\nlife from the Earth, and bring her own\nfoul offspring to our world! For all the\ndwellers in these nightmare dimensions\nare her descendants! Once all Runes of\nmagic power are united, the energy\nbehind them will blast open the Gateway\nto Shub-Niggurath, and you can travel\nthere to foil the Hell-Mother's plots\nin person.";
		}

		if (intermission_message != "") {
			WriteByte (MSG_ALL, SVC_CDTRACK);
			WriteByte (MSG_ALL, 2);
			WriteByte (MSG_ALL, 3);
			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, intermission_message);
			return;
		}

		GotoNextMap();
	}
	
	if (intermission_running == 3) {
		if (!cvar("registered")) {	// shareware episode has been completed, go to sell screen
			WriteByte (MSG_ALL, SVC_SELLSCREEN);
			return;
		}
		
		if ((serverflags & 15) == 15) {// all runes are taken (serverflags 1 + 2 + 4 + 8)
			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "Now, you have all four Runes. You sense\ntremendous invisible forces moving to\nunseal ancient barriers. Shub-Niggurath\nhad hoped to use the Runes Herself to\nclear off the Earth, but now instead,\nyou will use them to enter her home and\nconfront her as an avatar of avenging\nEarth-life. If you defeat her, you will\nbe remembered forever as the savior of\nthe planet. If she conquers, it will be\nas if you had never been born.");
			return;
		}
		
	}

	GotoNextMap();
};

/*
============
IntermissionThink

When the player presses attack or jump, change to the next level
============
*/
void() IntermissionThink = {
	
	if (self.cnt > 5) {
		self.cnt = 0;
		ExitIntermission();
	}

	if (time > self.attack_finished) self.cnt = 0;

	if (!self.button0 && !self.button1 && !self.button2 && self.impulse != 10 && self.impulse != 12 ) {
		self.wait = 0;
		return;
	}

	if (self.impulse == 10 || self.impulse == 12) {
		self.impulse = 0;
		if (self.wait) return;

		if (time > self.pain_finished) {
			nextIntermission();
		}
		/*if (time <= self.attack_finished || !self.cnt){
			self.attack_finished = time + 0.25;
			self.cnt++;
		}*/
		self.wait = 1;
		return;
	}


	if (time < intermission_exittime)
		return;

	ExitIntermission ();
};

void() execute_changelevel = {

	// flip on whichever mapvar is set into the changelevel trigger
	if (self.jump_flag > 0 && self.jump_flag <= MAPV_TOTAL)
		write_mapvar(self.jump_flag, MAPV_WRITE_ON);

	intermission_running = 1;

	if (self.message && self.message != "")
		intermission_message = self.message;
	else
		intermission_message = "";
	
// enforce a wait time before allowing changelevel
	if (deathmatch)
		intermission_exittime = time + 5;
	else
		intermission_exittime = time + 2;

	WriteByte (MSG_ALL, SVC_CDTRACK);
	WriteByte (MSG_ALL, 3);
	WriteByte (MSG_ALL, 3);
	
	
	other = find (world, classname, "player");

	while (other) {
		other.takedamage = DAMAGE_NO;
		other.solid = SOLID_NOT;
		other.movetype = MOVETYPE_NONE;
		other.view_ofs = '0 0 0';

		// angry clicking control
		other.cnt = 0;
		other.attack_finished = 0;

		// don't keep firing SNG/LG during intermission (speedrunners will hate it)
		other.think = SUB_Null;

		// origins don't update without a model
		// thanks Lunaran
		setmodel(other, "progs/misc_empty.mdl");
		setsize(other, '0 0 0', '0 0 0');

		other.weaponmodel = "";

		other.items &~= IT_INVISIBILITY | IT_INVULNERABILITY | IT_SUIT | IT_QUAD | IT_TRIFECTA; 
		other.super_damage_finished = 0;
		other.radsuit_finished = 0;
		other.invisible_finished = 0;
		other.invincible_finished = 0;
		other.invincible_time = 0;
		other.trif_time = 0;
		other.trif_finished = 0;
		other.effects = 0;

		other.punchangle = '0 0 0';

		other.nextthink = time + 0.5;

		other.goalentity = world;
		SUB_CallAsSelf(nextIntermission, other);

		other = find(other, classname, "player");
	}	

	WriteByte(MSG_ALL, SVC_INTERMISSION);
};

void() nextIntermission = {
	entity pos;

	if (!self.goalentity) pos = FindIntermission(world); // first intermission is random
	else pos = FindNextIntermission(self.goalentity); // next ones are sequential

	self.goalentity = pos;

		
	self.pain_finished = time + 0.5;

	self.angles = self.v_angle = pos.mangle;
	self.fixangle = TRUE;		// turn this way immediately
	setorigin(self, pos.origin);
	fog_setFromEnt(self, pos);
}


/*
============
FindIntermission

Returns the entity to view from
============
*/
entity(entity start) FindIntermission = {
	local	entity spot;
	local	float cyc;

// look for info_intermission first
	spot = find (start, classname, "info_intermission");
	if (spot)
	{	// pick a random one
		cyc = random() * 16;
		while (cyc > 1)
		{
			spot = find(spot, classname, "info_intermission");
			if (!spot)
				spot = find(spot, classname, "info_intermission");
			cyc = cyc - 1;
		}
		return spot;
	}

// then look for the start position
	spot = find (world, classname, "info_player_start");
	if (spot)
		return spot;
	
// testinfo_player_start is only found in regioned levels
	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;
	
	objerror ("FindIntermission: no spot");
	return spot; //shut up compiler
};

entity(entity start) FindNextIntermission = {
	if (!start) return world;
	if (start.classname != "info_intermission") return start;
	
	entity spot;
	spot = find(start, classname, "info_intermission");	
	if (!spot)
		spot = find(world, classname, "info_intermission");
	return spot;
}


void() changelevel_touch = {
//	local entity	pos;
	
	if (other.classname != "player")
		return;

	if (other.flags & FL_CLIENT && other.flags & FL_NOTARGET && other.movetype == MOVETYPE_NOCLIP && !forcenocliptouch)
		return;

	if (self.estate != STATE_ACTIVE)
		return;

	if (cvar("noexit") == 1 || (cvar("noexit") == 2 && mapname != "start")) {
		T_Damage(other, self, self, 50000, DMGTYPE_INSTANT);
		return;
	}

	if (coop || deathmatch) {
		bprint (other.netname);
		bprint (" exited the level\n");
	}
	

	// "reset items on map change" flag
	if (self.spawnflags & 2) reset_items_on_map_change = TRUE;
	else reset_items_on_map_change = FALSE;
	

	playerstart_id = self.count;

	if (self.map == "")
		nextmap = mapname;
	else
		nextmap = self.map;

	//johnfitz -- add a serverflag so users spawn at info_player_start2 when returning to startmap
	if (mapname == "start")
		serverflags = serverflags | 16; //1,2,4,8 are used for runes
	//johnfitz

	SUB_UseTargets ();

	if ( (self.spawnflags & 1) && (deathmatch == 0) ) // NO_INTERMISSION
	{	
		// flip on whichever mapvar is set into the changelevel trigger
		if (self.jump_flag > 0 && self.jump_flag <= MAPV_TOTAL)
			write_mapvar(self.jump_flag, MAPV_WRITE_ON);
		
		GotoNextMap();
		return;
	}
	
	self.touch = SUB_Null;

// we can't move people right now, because touch functions are called
// in the middle of C movement code, so set a think time to do it
	self.think = execute_changelevel;
	self.nextthink = time + 0.1;
};

void() changelevel_use = {
	other = activator;
	changelevel_touch();
};


/*QUAKED trigger_changelevel (0.5 0.5 0.5) ? NO_INTERMISSION
When the player touches this, he gets sent to the map listed in the "map" variable.  Unless the NO_INTERMISSION flag is set, the view will go to the info_intermission spot and display stats.
*/
void() trigger_changelevel = {
	if (!SUB_InitEntity()) return;
	
	if (!self.map)
		dprint("changelevel trigger doesn't have map set, will return to the same map\n");
	
	InitTrigger ();
	self.flags = self.flags | FL_NOCENTERPRINT;
	self.touch = changelevel_touch;
	self.use = changelevel_use;

	SUB_CheckWaiting();
};


void() target_changelevel = {
	if (!SUB_InitEntity()) return;
	
	if (!self.map)
		dprint("changelevel trigger doesn't have map set, will return to the same map\n");

	self.flags = self.flags | FL_NOCENTERPRINT;
	self.use = changelevel_use;
};

/*
============
SelectSpawnPoint

Returns the entity to spawn at
============
*/

entity(entity start, string findclass, float id) findSpawnPoint = {
	entity spot;
	spot = find(start, classname, findclass);

	while (spot && (
			(id > 0 && spot.count != id) ||
			(id < 0 && spot.count != 0) ||
			(spot.estate != STATE_ACTIVE)
		)
	) {
		spot = find(spot, classname, findclass);
	}
	
	return spot;
};

entity() SelectSpawnPoint = {
	local	entity spot;
	local	entity thing;
	local 	entity last_testplayerstart;
	local	float  pcount;
	
// testinfo_player_start is only found in regioned levels
	spot = find (world, classname, "testplayerstart");

	if (spot)
		return spot;
	
	if (cvar("developer")) {
		spot = find(world, classname, "info_player_start_test");
		// returns the last one created in the map
		while (spot) {
			if (last_testplayerstart) remove(last_testplayerstart);
			last_testplayerstart = spot;
			spot = find(spot, classname, "info_player_start_test");
		}
		if (last_testplayerstart) return last_testplayerstart;
	}

// choose a info_player_deathmatch point
	if (coop) {
		if (playerstart_id) {
			lastspawn = findSpawnPoint(lastspawn, "info_player_coop", playerstart_id);
			
			if (lastspawn == world) {
				lastspawn = findSpawnPoint(lastspawn, "info_player_start", playerstart_id);
			}

			if (lastspawn != world)
				return lastspawn;
		}

		lastspawn = findSpawnPoint(lastspawn, "info_player_coop", 0);

		if (lastspawn == world)
			lastspawn = findSpawnPoint(lastspawn, "info_player_start", 0);

		if (lastspawn != world)
			return lastspawn;
		
	}


	else if (deathmatch) {
		spot = lastspawn;
		while (1)
		{
			spot = findSpawnPoint(spot, "info_player_deathmatch", 0);
			if (spot != world)
			{
				if (spot == lastspawn)
					return lastspawn;
				pcount = 0;
				thing = findradius(spot.origin, 32);
				while(thing)
				{
					if (thing.classname == "player")
						pcount = pcount + 1;
					thing = thing.chain;
				}
				if (pcount == 0)
				{
					lastspawn = spot;
					return spot;
				}
			}
		}
	}

	// previous map's changelevel had a playerstart id
	if (playerstart_id) {
		spot = findSpawnPoint(world, "info_player_start", playerstart_id);

		if (spot)
			return spot;
	}

	if (serverflags)
	{	// return with a rune to start
		spot = findSpawnPoint(world, "info_player_start2", 0);
		if (spot)
			return spot;
	}
	
	// tries to find a "count 0" playerstart first
	spot = findSpawnPoint(world, "info_player_start", -1);
	if (spot)
		return spot;
	

	spot = findSpawnPoint(world, "info_player_start", 0);

	if (!spot)
		error ("PutClientInServer: no info_player_start on level");
	
	return spot;
};

void() CreateLightningController = {
	self.lightningcontroller = spawn();
	self.lightningcontroller.owner = self;
	self.lightningcontroller.classname = "lightningcontroller";
}

void() CreateHealthController = {
	self.healthcontroller = spawn();
	self.healthcontroller.owner = self;
	self.healthcontroller.think = healthcontroller_think;
	self.healthcontroller.nextthink = time + 1;
	self.healthcontroller.classname = "healthcontroller";
}

void() CreateAnimController = {
	self.animcontroller = spawn();
	self.animcontroller.owner = self;
	self.animcontroller.classname = "animcontroller";
}

/*
===========
ClientConnect

called when a player connects to a server
============
*/
void() ClientConnect =
{
	bprint (self.netname);
	bprint (" entered the game\n");
	
	dprint ("intermission_running: ");
	dprint (ftos(intermission_running));
	dprint ("\n");
	
	dprint ("nextmap: ");
	dprint (nextmap);
	dprint ("\n");

	if (!client_ent) client_ent = self; //client_ent will be the first player to enter

	self.currenthud = !!(cvar("saved1") & ALKSETTIGNS_OLDSTYLEHUD);

	if (self.healthcontroller.classname != "healthcontroller") CreateHealthController();
	if (self.lightningcontroller.classname != "lightningcontroller") CreateLightningController();
	if (self.animcontroller.classname != "animcontroller") CreateAnimController();

// a client connecting during an intermission can cause problems
	if (intermission_running)
		ExitIntermission ();
};


/*
===========
PutClientInServer

called each time a player is spawned
============
*/

void() PutClientInServer = {
	local	entity spot;

	dprint5("\b[CLIENT]\b PutClientInServer at ", ftos(time), " seconds, frame ", ftos(framecount), "\n");
	
	float just_connected;

	if (self.classname == "") just_connected = TRUE;

	self.classname = "player";
	self.health = 100;
	self.takedamage = DAMAGE_AIM;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_WALK;
	self.show_hostile = 0;
	self.max_health = 100;
	self.flags = FL_CLIENT;
	self.air_finished = time + 12;
	self.dmg = 2;   		// initial water damage
	self.trif_finished = 0;
	self.super_damage_finished = 0;
	self.radsuit_finished = 0;
	self.invisible_finished = 0;
	self.gravity = 0;
	self.wantedgravity = 0;
	self.invincible_finished = 0;
	self.trif_finished = 0;	
	self.trif_time = 0;	
	self.effects = 0;
	self.invincible_time = 0;
	self.customkeys = 0;  // support for item_key_custom -- iw
	self.jboots_finished = 0;	//jcr jboots timed
	self.offground_start = 0;
	self.sky = world.sky;
	if (just_connected) self.connect_time = time;

	//if (just_connected) self.currenthud = !!(cvar("saved1") & ALKSETTIGNS_OLDSTYLEHUD);

	StopBurning(self);//johnfitz -- reset burning	

	DecodeLevelParms ();
	
	spot = SelectSpawnPoint ();
	
	if (spot.classname == "info_player_start_test") {
		TakeAndGiveWeapons(self, spot);
		if (spot.spawnflags & 1) self.flags = self.flags | FL_GODMODE;
		if (spot.spawnflags & 2) self.movetype = MOVETYPE_NOCLIP;
		if (spot.spawnflags & 4) self.flags = self.flags | FL_NOTARGET;
	}
	
	W_ChangeWeapon(self.weapon);

	self.attack_finished = time;
	self.th_pain = player_pain_generic;
	self.th_die = PlayerDie;
	
	self.deadflag = DEAD_NO;
	// paustime is set by teleporters to keep the player from moving a while
	self.pausetime = 0;
	

	self.origin = spot.origin + '0 0 1';
	self.angles = spot.angles;
	self.fixangle = TRUE;		// turn this way immediately


	if (spot.fog_density)
		fog_save(self, spot.fog_density, spot.fog_color);
	else if (world.fog_density)
		fog_save(self, world.fog_density, world.fog_color);

	if (spot.skyfog_density)
		skyfog_save(self, spot.skyfog_density);
	else if (world.skyfog_density)
		skyfog_save(self, world.skyfog_density);

	cleanUpClientStuff = 2;

	// oh, this is a hack!
	setmodel (self, "progs/eyes.mdl");
	modelindex_eyes = self.modelindex;

	setmodel (self, "progs/player.mdl");
	modelindex_player = self.modelindex;

	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
	
	self.view_ofs = '0 0 22';

	SUB_CallAsSelf(player_stand1, self.animcontroller);
	
	if (deathmatch || coop)
	{
		makevectors(self.angles);
		spawn_tfog (self.origin + v_forward*20);
	}

	spawn_tdeath (self.origin, self);

	csf_clear_all(self);
};

/*
===========
ClientDisconnect

called when a player disconnects from a server
============
*/
void() ClientDisconnect =
{
	if (gameover)
		return;
	// if the level end trigger has been activated, just return
	// since they aren't *really* leaving

	if (self.healthcontroller.classname == "healthcontroller") remove(self.healthcontroller);
	if (self.lightningcontroller.classname == "lightningcontroller") remove(self.lightningcontroller);
	if (self.animcontroller.classname == "animcontroller") remove(self.animcontroller);
	
	// let everyone else know
	bprint (self.netname);
	bprint (" left the game with ");
	bprint (ftos(self.frags));
	bprint (" frags\n");
	sound (self, CHAN_BODY, "player/tornoff2.wav", 1, ATTN_NONE);
	set_suicide_frame ();
};

/*
=============================================================================

				QUAKED FUNCTIONS

=============================================================================
*/


/*QUAKED info_player_start (1 0 0) (-16 -16 -24) (16 16 24)
The normal starting point for a level.
*/
void() info_player_start =
{
	if (!SUB_InitEntity()) return;
};


void() info_player_start_test =
{
	if (!SUB_InitEntity()) return;
	
	if (!cvar("developer")) remove(self);
};


/*QUAKED info_player_start2 (1 0 0) (-16 -16 -24) (16 16 24)
Only used on start map for the return point from an episode.
*/
void() info_player_start2 =
{
	if (!SUB_InitEntity()) return;
};


/*
saved out by quaked in region mode
*/
void() testplayerstart =
{
	if (!SUB_InitEntity()) return;
};

/*QUAKED info_player_deathmatch (1 0 1) (-16 -16 -24) (16 16 24)
potential spawning position for deathmatch games
*/
void() info_player_deathmatch =
{
	if (!SUB_InitEntity()) return;
};

/*QUAKED info_player_coop (1 0 1) (-16 -16 -24) (16 16 24)
potential spawning position for coop games
*/
void() info_player_coop =
{
	if (!SUB_InitEntity()) return;
};

/*
===============================================================================

RULES

===============================================================================
*/

/*
go to the next level for deathmatch
only called if a time or frag limit has expired
*/
void() NextLevel =
{
	local entity o;

	if (mapname == "start")
	{
		if (!cvar("registered"))
		{
			mapname = "e1m1";
		}
		else if (!(serverflags & 1))
		{
			mapname = "e1m1";
			serverflags = serverflags | 1;
		}
		else if (!(serverflags & 2))
		{
			mapname = "e2m1";
			serverflags = serverflags | 2;
		}
		else if (!(serverflags & 4))
		{
			mapname = "e3m1";
			serverflags = serverflags | 4;
		}
		else if (!(serverflags & 8))
		{
			mapname = "e4m1";
			serverflags = serverflags - 7;
		}

		o = spawn();
		o.map = mapname;
	}
	else
	{
		// find a trigger changelevel
		o = find(world, classname, "trigger_changelevel");

		// go back to start if no trigger_changelevel
		if (!o)
		{
			mapname = "start";
			o = spawn();
			o.map = mapname;
		}
	}

	nextmap = o.map;
	gameover = TRUE;
	
	if (o.nextthink < time)
	{
		o.think = execute_changelevel;
		o.nextthink = time + 0.1;
	}
};

/*
============
CheckRules

Exit deathmatch games upon conditions
============
*/
void() CheckRules =
{
	local	float		timelimit;
	local	float		fraglimit;
	
	if (gameover)	// someone else quit the game already
		return;
		
	timelimit = cvar("timelimit") * 60;
	fraglimit = cvar("fraglimit");
	
	if (timelimit && time >= timelimit)
	{
		NextLevel ();
		return;
	}
	
	if (fraglimit && self.frags >= fraglimit)
	{
		NextLevel ();
		return;
	}	
};

//============================================================================
