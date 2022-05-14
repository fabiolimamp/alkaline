
/*
============
GiveAllCommand
============
*/
void() GiveAllCommand =
{
	if (deathmatch || coop)
		return;

	self.ammo_rockets = 100;
	self.ammo_nails = 200;
	self.ammo_shells = 100;
	self.weapons = self.weapons | ALL_WEAPONS;
	self.items = self.items | HUD_WEAPONS | IT_KEY1 | IT_KEY2;

	self.ammo_cells = 100;
		
	self.weapon = WEAPON_ROCKET_LAUNCHER;
	self.impulse = 0;
	W_SetCurrentAmmo ();
};

/*
============
GiveWeaponsCommand
============
*/
void() GiveWeaponsCommand =
{
	if (deathmatch || coop)
		return;

	self.ammo_rockets = 100;
	self.ammo_nails = 200;
	self.ammo_shells = 100;
	self.weapons = self.weapons | ALL_WEAPONS;
	self.items = self.items | HUD_WEAPONS;

	self.ammo_cells = 100;
		
	self.weapon = WEAPON_ROCKET_LAUNCHER;
	self.impulse = 0;
	W_SetCurrentAmmo ();
};

/*
============
ServerflagsCommand

Just for development
============
*/
void() ServerflagsCommand =
{
	serverflags = serverflags * 2 + 1;
};

//johnfitz -- new cheats
void() RingCheat =
{
	if (deathmatch || coop)
		return;
	self.invisible_time = 1;
	self.invisible_finished = time + 30;
	self.items = self.items | IT_INVISIBILITY;
	dprint ("ring cheat\n");
};

void() BiosuitCheat =
{
	if (deathmatch || coop)
		return;
	self.rad_time = 1;
	self.radsuit_finished = time + 30;
	self.items = self.items | IT_SUIT;
	dprint ("biosuit cheat\n");
};

void() PentCheat =
{
	if (deathmatch || coop)
		return;
	self.invincible_time = 1;
	self.invincible_finished = time + 30;
	self.items = self.items | IT_INVULNERABILITY;
	dprint ("pent cheat\n");
};
//johnfitz

void() QuadCheat =
{
	if (deathmatch || coop)
		return;
	self.super_time = 1;
	self.super_damage_finished = time + 30;
	self.items = self.items | IT_QUAD;
	dprint ("quad cheat\n");
};

void() JBootsCheat = { //JCR superjump boot cheat
	self.items = self.items | IT_JBOOTS;

	if (!self.jboots_rechargelimit) sprint(self, "You got the Jump Boots!\n");
	else sprint(self, "Jump module added.\n");

	sound(self, CHAN_BODY, "items/jboots_got.wav", 1, ATTN_NORM);

	if (self.jboots_rechargelimit >= 3)
		self.jboots_rechargelimit = 3;
	else
		self.jboots_rechargelimit = self.jboots_rechargelimit + 1;
}

void() JBootsTimedCheat = { //JCR superjump boot cheat
	self.items = self.items | IT_JBOOTS;

	sprint(self, "You got the Super Jump Boots!\n");

	sound(self, CHAN_BODY, "items/jboots_got.wav", 1, ATTN_NORM);

	self.jboots_prevlimit = self.jboots_rechargelimit;
	self.jboots_time = 1;
	self.jboots_finished = time + 30;
	self.jboots_rechargelimit = -1;
}

void() JBootsRemoveCheat = {
	sprint(self, "Jump boots removed.\n");

	self.items -= self.items & IT_JBOOTS;

	self.jboots_finished = 0;
	self.jboots_time = 0;
	self.jboots_rechargelimit = 0;
	self.jboots_prevlimit = 0;
}

void(float num) ImpulseTest = {
	local string tgt_impulse_num;
	
	if(num <= 0)
		return;

	tgt_impulse_num = ftos(num);

	activator = self;
	SUB_UseSpecificTarget(tgt_impulse_num, impulsetarget);
};

// adapted from Copper
void() dev_reveal = {
	vector org;

	makevectors(self.v_angle);
	org = self.origin + self.view_ofs;
	traceline (org, org + v_forward * 8192, FALSE, self);

	if (trace_fraction < 1) {
		if (trace_ent) {
			dprint("----------------------------\n----------------------------\n");
			eprint(trace_ent);
		}
		dprint5("\n-\n-\nFound ", trace_ent.classname, "; time: ", ftos(time), "\n");
	}

};

void(entity targ, float ammoqty, string zero10, string zero100, string zero1000, string zero10000, string zero100000) zerofill_number =
{
	// Cap number based on strings
	if (ammoqty > 99999 && zero100000 == "") ammoqty = 99999;
	if (ammoqty > 9999 && zero10000 == "") ammoqty = 9999;
	if (ammoqty > 999 && zero1000 == "") ammoqty = 999;
	if (ammoqty > 99 && zero100 == "") ammoqty = 99;
	// Zero fill based on strings existing
	if (ammoqty < 100000 && zero100000 != "") sprint(targ, zero100000);
	if (ammoqty < 10000 && zero10000 != "") sprint(targ, zero10000);
	if (ammoqty < 1000 && zero1000 != "") sprint(targ, zero1000);
	if (ammoqty < 100 && zero100 != "") sprint(targ, zero100);
	if (ammoqty < 10 && zero10 != "") sprint(targ, zero10);
	sprint(targ, ftos(ammoqty));	
};

// adapted from AD
void() display_monsleft =
{
	local float entcount, montotal, monalive, mondead, counted, countedalive;
	local entity entlist;
	

	// flush keyboard buffer
	self.impulse = 0;
	// Reset counters
	entcount = montotal = monalive = mondead = 0;

	sprint(self, "\b[-- Monsters Alive and Kicking --]\b\n"); 
	sprint(self, "--------------------------------------\n");
	sprint(self, " No   HP D C Classname + XYZ location\n");
	//            xxx xxxx x x------------------------------x
	// Start from beginning of entity list, world!
	entlist = nextent(world);

	// Keep looping through entity list
	while (entlist) {
		// Found another entity
		entcount = entcount + 1;
		// Only interested in monsters (regular + boss)
		if (
			(entlist.flags & FL_MONSTER || entlist.flags & FL_UNSPAWNEDMONSTER)
			&& !(entlist.flags & FL_PACIFIST && !(entlist.spawnflags & MONSTER_COUNTONSPAWN))
		) {
			// Keep counting up monsters
			montotal = montotal + 1;
			if (entlist.spawnflags & MONSTER_COUNTONSPAWN && !(entlist.flags & FL_PACIFIST)) {
				if(!(entlist.flags & FL_UNSPAWNEDMONSTER)) counted = counted + 1;
			}
			else counted = counted + 1;
			if (entlist.health > 0) {
				monalive = monalive + 1;
				if (monalive <= 400) {
					// Update console display
					zerofill_number(self, monalive, "0", "0", "", "", "");
					sprint(self, " ");
					zerofill_number(self, entlist.health, " ", " ", " ", "", "");
					// Check for monster spawn delay (flag)
					if (entlist.flags & FL_UNSPAWNEDMONSTER) sprint(self, " Y ");
					else sprint(self, " - ");

					if (entlist.spawnflags & MONSTER_COUNTONSPAWN && !(entlist.flags & FL_PACIFIST)) {
						sprint(self, "Y ");
						//if (!(entlist.flags & FL_PACIFIST)) countedalive++;
					}
					else {
						sprint(self, "- ");
						countedalive++;
					}
					// Print monster class and position
					sprint(self, entlist.classname); sprint(self, " ");
					sprint(self, vtos(entlist.origin)); sprint(self, "\n");
				}
				// Only report the first xxx monsters
				// Otherwise will get SZ_GETSPACE : OVERFLOW error
				if (monalive == (401)) {
					sprint(self, " * Can only list ");
					sprint(self, ftos(400));
					sprint(self, "monsters!\n");
				}
			}
			// Monster found is dead
			else mondead = mondead + 1;			
		}		
		// Keep search through ALL of the entity list
		entlist = nextent(entlist);
	}
	sprint(self, "--------------------------------------\n");
	sprint(self, "Monster Total ("); sprint(self, ftos(montotal));
	sprint(self, ") Alive ("); sprint(self, ftos(monalive));
	sprint(self, ") Dead ("); sprint(self, ftos(mondead));
	sprint(self, ")\n");
	sprint(self, "Total counted ("); sprint(self, ftos(counted));sprint(self, ") Alive counted ("); sprint(self, ftos(countedalive));sprint(self, ")\n");
	sprint(self, "Player location "); sprint(self, vtos(self.origin));
	sprint(self, "\n\n");
};


void(entity cl) printVersionConsole = {
	sprint(cl, "\b=============================================\b\n");
	sprint(cl, VERSION_S); sprint(cl, " ("); sprint(cl, BUILD_DATE); sprint(cl, " "); sprint(cl, BUILD_TIME); sprint(cl, ")\n");
	sprint(cl, "\b=============================================\b\n");
};

void() show_bulletholes;
void() hide_bulletholes;

void() ToggleBulletHole = {
	float tmp1;
	tmp1 = cvar("temp1");
	if (bulletmode == 0) {
		bprint("Bullet holes: enabled\n");
		bulletmode = 1;
		show_bulletholes();
		cvar_set("temp1", ftos(tmp1 - (tmp1 & TEMPSETTINGS_NOBULLETHOLES)));
	}
	else {
		bprint("Bullet holes: disabled\n");
		bulletmode = 0;
		hide_bulletholes();
		cvar_set("temp1", ftos(tmp1 | TEMPSETTINGS_NOBULLETHOLES));
	}
};

void() ToggleFootsteps = {
	float tmp1;
	tmp1 = cvar("temp1");
	if (nofootsteps) {
		bprint("Footsteps: enabled\n");
		nofootsteps = 0;
		cvar_set("temp1", ftos(tmp1 - (tmp1 & TEMPSETTINGS_NOFOOTSTEPS)));
	}
	else {
		bprint("Footsteps: disabled\n");
		nofootsteps = 1;
		cvar_set("temp1", ftos(tmp1 | TEMPSETTINGS_NOFOOTSTEPS));
	}
};

void() ToggleAutosave = {
	float tmp1;
	tmp1 = cvar("temp1");
	if (noautosaves) {
		bprint("Autosaves: enabled\n");
		noautosaves = 0;
		cvar_set("temp1", ftos(tmp1 - (tmp1 & TEMPSETTINGS_NOAUTOSAVES)));
	}
	else {
		bprint("Autosaves: disabled\n");
		noautosaves = 1;
		cvar_set("temp1", ftos(tmp1 | TEMPSETTINGS_NOAUTOSAVES));
	}
};

void() ToggleTracers = {
	float tmp1;
	tmp1 = cvar("temp1");
	if (notracers) {
		bprint("Tracers: enabled\n");
		notracers = 0;
		cvar_set("temp1", ftos(tmp1 - (tmp1 & TEMPSETTINGS_NOTRACERS)));
	}
	else {
		bprint("Tracers: disabled\n");
		notracers = 1;
		cvar_set("temp1", ftos(tmp1 | TEMPSETTINGS_NOTRACERS));
	}
};

void() TogglePlayerTracers = {
	float tmp1;
	tmp1 = cvar("temp1");
	if (playertracers) {
		bprint("Player tracers: disabled\n");
		playertracers = 0;
		cvar_set("temp1", ftos(tmp1 - (tmp1 & TEMPSETTINGS_PLAYERTRACERS)));
	}
	else {
		bprint("Player tracers: enabled\n");
		playertracers = 1;
		cvar_set("temp1", ftos(tmp1 | TEMPSETTINGS_PLAYERTRACERS));
	}
};


void() ResetModSettings = {
	cvar_set("temp1", 0);
	bprint("Mod settings reset to default\n");
};

void() ResetPlayerZ = {
	self.angles_z = 0;
	self.angles_x = self.v_angle_x;
	self.fixangle = 1;
}

/*void() ToggleAutosave =
{
	entity e = world;
	float printed = FALSE;
	do {
		e = find(e, classname, "target_autosave");
		if (!e) break;

		if (e.use == target_autosave_use)
		{
			e.use = SUB_Null;
			if (!printed)
			{
				bprint("Autosaves: disabled\n");
				printed = TRUE;
			}
		} else {
			e.use = target_autosave_use;
			if (!printed)
			{
				bprint("Autosaves: enabled\n");
				printed = TRUE;
			}
		}

	} while (e != world);
}*/

/*
============
ImpulseCommands

============
*/

void() ImpulseCommands = {
	// weapon changing must not occur until attack_finished time has passed
	if (self.impulse >= 1 && self.impulse <= 8){
		if (time < self.attack_finished) return;
		else W_ChangeWeapon();
	}
	if (self.impulse >= 224 && self.impulse <= 235) {
		if (time < self.attack_finished) return;
		else W_ChangeWeapon();
	}
	if (self.impulse == 10) {
		if (time < self.attack_finished) return;
		else CycleWeaponCommand();
	}
	if (self.impulse == 12) {
		if (time < self.attack_finished) return;
		else CycleWeaponReverseCommand();
	}

	if (self.impulse == 9)
		GiveAllCommand();
	if (self.impulse == 11)
		ServerflagsCommand();

	if (self.impulse == 13)
		GiveWeaponsCommand();
	if (self.impulse >= 91 && self.impulse <= 99)
		ImpulseTest(self.impulse - 90);

	if (self.impulse == 30)
		ToggleBulletHole();
	if (self.impulse == 31)
		ToggleFootsteps();
	if (self.impulse == 32)
		ToggleAutosave();
	if (self.impulse == 40)
		ResetModSettings();
	if (self.impulse == 41)
		csf_clear_all(self);
	if (self.impulse == 42)
		ToggleTracers();
	if (self.impulse == 43)
		TogglePlayerTracers();

	if (self.impulse == 128)
		printVersionConsole(self);
		//centerprint(self, VERSION_S);
	if (self.impulse == 184)
		display_monsleft();
	if (self.impulse == 185)
		display_mapvar();
	if (self.impulse == 200)
		dev_reveal();
	if (self.impulse == 201)
		ResetPlayerZ();

	if (self.impulse == 252)
		RingCheat();
	if (self.impulse == 253)
		BiosuitCheat();
	if (self.impulse == 254)
		PentCheat();
	if (self.impulse == 255)
		QuadCheat();
	if (self.impulse == 221)
		JBootsTimedCheat();
	if (self.impulse == 222)
		JBootsCheat();
	if (self.impulse == 223)
		JBootsRemoveCheat();

		
	self.impulse = 0;
};

/*
============
W_WeaponFrame

Called every frame so impulse events can be handled as well as possible
============
*/
void() W_WeaponFrame =
{

	if (self.impulse) //johnfitz
		ImpulseCommands();

	if (time < self.attack_finished)
		return;

// check for attack
	if (self.button0) {
		W_Attack ();
	}
};



