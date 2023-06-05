
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

	stuffcmd (self, "bf\n");
	sprint(self, "You got everything\n");
	sound (self, CHAN_ITEM, "weapons/pkup.wav", 1, ATTN_NORM);
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


	stuffcmd (self, "bf\n");
	sprint(self, "You got all weapons and ammo\n");
	sound (self, CHAN_ITEM, "weapons/pkup.wav", 1, ATTN_NORM);
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

	stuffcmd (self, "bf\n");
	sprint(self, "You got the Invisibility belt\n");
	sound(self, CHAN_ITEM, "items/inv1.wav", 1, ATTN_NORM);
};

void() BiosuitCheat =
{
	if (deathmatch || coop)
		return;
	self.rad_time = 1;
	self.radsuit_finished = time + 30;
	self.items = self.items | IT_SUIT;

	stuffcmd (self, "bf\n");
	sprint(self, "You got the Biosuit\n");
	sound(self, CHAN_ITEM, "items/suit.wav", 1, ATTN_NORM);
};

void() PentCheat =
{
	if (deathmatch || coop)
		return;
	self.invincible_time = 1;
	self.invincible_finished = time + 30;
	self.items = self.items | IT_INVULNERABILITY;

	stuffcmd (self, "bf\n");
	sprint(self, "You got the Pentagram of Protection\n");
	sound(self, CHAN_ITEM, "items/protect.wav", 1, ATTN_NORM);
};
//johnfitz

void() QuadCheat =
{
	if (deathmatch || coop)
		return;
	self.super_time = 1;
	self.super_damage_finished = time + 30;
	self.items = self.items | IT_QUAD;

	stuffcmd (self, "bf\n");
	sprint(self, "You got the Quad Damage\n");
	sound(self, CHAN_ITEM, "items/damage.wav", 1, ATTN_NORM);
};

void() JBootsCheat = { //JCR superjump boot cheat
	self.items = self.items | IT_JBOOTS;

	if (!self.jboots_rechargelimit) sprint(self, "You got the Jump Boots!\n");
	else sprint(self, "Jump module added.\n");
	stuffcmd (self, "bf\n");
	sound(self, CHAN_BODY, "items/jboots_got.wav", 1, ATTN_NORM);

	if (self.jboots_rechargelimit >= 3)
		self.jboots_rechargelimit = 3;
	else
		self.jboots_rechargelimit = self.jboots_rechargelimit + 1;
}

void() JBootsTimedCheat = { //JCR superjump boot cheat
	self.items = self.items | IT_JBOOTS;

	sprint(self, "You got the Super Jump Boots!\n");
	stuffcmd (self, "bf\n");
	sound(self, CHAN_BODY, "items/jboots_got.wav", 1, ATTN_NORM);

	self.jboots_prevlimit = self.jboots_rechargelimit;
	self.jboots_time = 1;
	self.jboots_finished = time + 30;
	self.jboots_rechargelimit = -1;
}

void() JBootsRemoveCheat = {
	sprint(self, "Jump boots removed.\n");
	stuffcmd (self, "bf\n");
	sound(self, CHAN_BODY, "items/jboots_dry.wav", 1, ATTN_NORM);

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


void() dev_reveal_touch = {
	if (other == self.owner) return;
	if (other) {
		dprint("----------------------------\n----------------------------\n");
		eprint(other);
	}
	dprint5("\n-\n-\nFound ", other.classname, "; time: ", ftos(time), "\n");
	remove(self);
}

void() dev_reveal_think = {
	if (time > self.lifetime_finished) {
		remove(self);
		return;
	}

	entity e = nextent(world);
	while (e) {
		if (e != self && e != self.owner && e.model != "" && e.solid != SOLID_BSP && getTouch(self.origin, e)) {
			dprint("----------------------------\n----------------------------\n");
			eprint(e);
			
			dprint5("\n-\n-\nFound ", e.classname, "; time: ", ftos(time), "\n");
			remove(self);
			return;
		}
		e = nextent(e);
	}
	if (vlen(self.velocity) < 1500) self.velocity *= 1.03;
	self.nextthink = time + 0.015;

}

// original idea from Copper
void() dev_reveal = {
	vector org;

	org = self.origin + self.view_ofs;
	entity e = spawn();
	e.owner = self;
	e.movetype = MOVETYPE_FLY;
	e.solid = SOLID_TRIGGER;
	setorigin(e, org);
	setmodel(e, "progs/s_bubble.spr");
	setsize(e, '0 0 0', '0 0 0');
	e.oldorigin = e.origin;
	e.touch = dev_reveal_touch;
	e.think = dev_reveal_think;
	e.nextthink = time + 0.015;
	makevectors(self.v_angle);
	e.velocity = v_forward * 600;

	e.lifetime_finished = time + 5;

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
	sound(self, CHAN_BODY, "misc/menu3.wav", 1, ATTN_NORM);
	tmp1 = cvar("temp1");
	if (bulletmode == 0) {
		bprint("Bullet holes: enabled\n");
		bulletmode = 1;
		show_bulletholes();
		cvar_set("saved1", ftos(tmp1 - (tmp1 & ALKSETTINGS_NOBULLETHOLES)));
	}
	else {
		bprint("Bullet holes: disabled\n");
		bulletmode = 0;
		hide_bulletholes();
		cvar_set("saved1", ftos(tmp1 | ALKSETTINGS_NOBULLETHOLES));
	}
};

void() ToggleFootsteps = {
	float tmp1;
	sound(self, CHAN_BODY, "misc/menu3.wav", 1, ATTN_NORM);
	tmp1 = cvar("temp1");
	if (nofootsteps) {
		bprint("Footsteps: enabled\n");
		nofootsteps = 0;
		cvar_set("saved1", ftos(tmp1 - (tmp1 & ALKSETTINGS_NOFOOTSTEPS)));
	}
	else {
		bprint("Footsteps: disabled\n");
		nofootsteps = 1;
		cvar_set("saved1", ftos(tmp1 | ALKSETTINGS_NOFOOTSTEPS));
	}
};

void() ToggleAutosave = {
	float tmp1;
	sound(self, CHAN_BODY, "misc/menu3.wav", 1, ATTN_NORM);
	tmp1 = cvar("saved1");
	if (noautosaves) {
		bprint("Autosaves: enabled\n");
		noautosaves = 0;
		cvar_set("saved1", ftos(tmp1 - (tmp1 & ALKSETTINGS_NOAUTOSAVES)));
	}
	else {
		bprint("Autosaves: disabled\n");
		noautosaves = 1;
		cvar_set("saved1", ftos(tmp1 | ALKSETTINGS_NOAUTOSAVES));
	}
};

void() ToggleTracers = {
	float tmp1;
	sound(self, CHAN_BODY, "misc/menu3.wav", 1, ATTN_NORM);
	tmp1 = cvar("saved1");
	if (notracers) {
		bprint("Tracers: enabled\n");
		notracers = 0;
		cvar_set("saved1", ftos(tmp1 - (tmp1 & ALKSETTINGS_NOTRACERS)));
	}
	else {
		bprint("Tracers: disabled\n");
		notracers = 1;
		cvar_set("saved1", ftos(tmp1 | ALKSETTINGS_NOTRACERS));
	}
};

void() TogglePlayerTracers = {
	float tmp1;
	sound(self, CHAN_BODY, "misc/menu3.wav", 1, ATTN_NORM);
	tmp1 = cvar("saved1");
	if (playertracers) {
		bprint("Player tracers: disabled\n");
		playertracers = 0;
		cvar_set("saved1", ftos(tmp1 - (tmp1 & ALKSETTINGS_PLAYERTRACERS)));
	}
	else {
		bprint("Player tracers: enabled\n");
		playertracers = 1;
		cvar_set("saved1", ftos(tmp1 | ALKSETTINGS_PLAYERTRACERS));
	}
};

void() ToggleOldGrenade = {
	float tmp1;
	sound(self, CHAN_BODY, "misc/menu3.wav", 1, ATTN_NORM);
	tmp1 = cvar("saved1");
	if (oldgrenade) {
		bprint("Old grenade style: disabled\n");
		oldgrenade = 0;
		cvar_set("saved1", ftos(tmp1 - (tmp1 & ALKSETTINGS_OLDGRENADE)));
	}
	else {
		bprint("Old grenade style: enabled\n");
		oldgrenade = 1;
		cvar_set("saved1", ftos(tmp1 | ALKSETTINGS_OLDGRENADE));
		cvar_set("saved1", ftos(tmp1 | ALKSETTINGS_OLDGRENADE));
	}
}

void() ToggleOldLightning = {
	float tmp1;
	sound(self, CHAN_BODY, "misc/menu3.wav", 1, ATTN_NORM);
	tmp1 = cvar("saved1");
	if (oldlightning) {
		bprint("Old lightning style: disabled\n");
		oldlightning = 0;
		cvar_set("saved1", ftos(tmp1 - (tmp1 & ALKSETTINGS_OLDLIGHTNING)));
	}
	else {
		bprint("Old lightning style: enabled\n");
		oldlightning = 1;
		cvar_set("saved1", ftos(tmp1 | ALKSETTINGS_OLDLIGHTNING));
	}
}

void() ResetModSettings = {
	cvar_set("saved1", 0);
	bprint("Mod settings reset to default\n");
};

void() ResetPlayerZ = {
	self.angles_z = 0;
	self.angles_x = self.v_angle_x;
	self.fixangle = 1;
}

void() CycleHUD = {
	sound(self, CHAN_BODY, "misc/menu3.wav", 1, ATTN_NORM);
	float current = self.currenthud;

	if (current) {
		cvar_set("scratch1", 0);
		self.currenthud = 0;
	}
	else {
		cvar_set("scratch1", "1");
		self.currenthud = 1;
	}
}


void() DumpParms = {
	bprint3("parm1: ", ftos(parm1), "\n");
	bprint3("parm2: ", ftos(parm2), "\n");
	bprint3("parm3: ", ftos(parm3), "\n");
	bprint3("parm4: ", ftos(parm4), "\n");
	bprint3("parm5: ", ftos(parm5), "\n");
	bprint3("parm6: ", ftos(parm6), "\n");
	bprint3("parm7: ", ftos(parm7), "\n");
	bprint3("parm8: ", ftos(parm8), "\n");
	bprint3("parm9: ", ftos(parm9), "\n");
	bprint3("parm10: ", ftos(parm10), "\n");
	bprint3("parm11: ", ftos(parm11), "\n");
	bprint3("parm12: ", ftos(parm12), "\n");
	bprint3("parm13: ", ftos(parm13), "\n");
	bprint3("parm14: ", ftos(parm14), "\n");
	bprint3("parm15: ", ftos(parm15), "\n");
	bprint3("parm16: ", ftos(parm16), "\n");
}
/*
============
ImpulseCommands

============
*/

void() ImpulseCommands = {
	// weapon changing must not occur until attack_finished time has passed
	if (self.impulse >= 1 && self.impulse <= 8) {
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
	if (self.impulse == 44)
		ToggleOldGrenade();
	if (self.impulse == 45)
		ToggleOldLightning();

	if (self.impulse == 50)
		CycleHUD();

	if (self.impulse == 128)
		printVersionConsole(self);
		//centerprint(self, VERSION_S);
	if (self.impulse == 184)
		display_monsleft();
	if (self.impulse == 185)
		display_mapvar();
	if (self.impulse == 186)
		DumpParms();
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
	if (self.button0 && time > self.connect_time + 0.2) {
		W_Attack ();
	}
};



