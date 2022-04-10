
void() InitBodyQue;
//JIM
void() InitBulletHoles;

void() main =
{
	dprint ("main function\n");

// sounds loaded by C code
	precache_sound ("misc/menu1.wav");
	precache_sound ("misc/menu2.wav");
	precache_sound ("misc/menu3.wav");

	precache_sound ("ambience/water1.wav");
	precache_sound ("ambience/wind2.wav");
// mainly added to quell a warning	
	precache_sound ("vomitus/v_sight1.wav");

};


//=================================================
// EndFrame code from Preach
//=================================================
entity backstop;
float prevframe;

entity() spawn = {
	entity e;
	e = spawn_builtin();
	if (nextent(e) != world)
		return e;
	// e is now the last entity on the list
	// so we need to swap it with the backstop
	entity f;
	f = backstop;
	f.think = e.think;
	f.nextthink = e.nextthink;
	f.classname = e.classname;
	 
	e.think = EndFrame;
	e.nextthink = time;
	e.classname = "backstop";
	backstop = e;
	
	return f;
}

void() CreateBackstop = {
	entity e, f, head;
	//begin our list with the temp backstop
	e = f = head = backstop;
	// spawn() already contains the code to make a backstop
	// so we just burn off enough entities that one appears
	// at the back
	do {
		f = spawn();
		e.chain = f;
		e = e.chain;
	} while (nextent(backstop) != world);

	while (head != f) {
		e = head;
		head = e.chain;
		remove(e);
	}
}

//=======================
/*QUAKED worldspawn (0 0 0) ?
Only used for the world entity.
Set message to the level name.
Set sounds to the cd track to play.

World Types:
0: medieval
1: metal
2: base
*/
//=======================
void() worldspawn =
{
	local entity linkdoor_e;

	backstop = spawn_builtin();

	lastspawn = world;
	
	if (cvar("pr_checkextension")){
		if (checkextension("QUAKE_EX"))
			isKex = TRUE;

		clientstat(STAT_LEVELNAME, EV_STRING, levelname);
		clientstat(STAT_WEAPONS, EV_FLOAT, weapons);
		clientstat(STAT_BOOTS, EV_FLOAT, jboots_rechargelimit);
		clientstat(STAT_BOOTS_FINISHED, EV_FLOAT, jboots_finished);
		clientstat(STAT_IT, EV_FLOAT, items);
	}

	InitBodyQue ();

	InitBulletHoles();
   
// custom map attributes
	if (self.model == "maps/e1m8.bsp")
		cvar_set ("sv_gravity", "100");
	else
		cvar_set ("sv_gravity", "800");

	float tmp1;
	tmp1 = cvar("temp1");
	if (tmp1 & TEMPSETTINGS_NOFOOTSTEPS) nofootsteps = 1;
	if (tmp1 & TEMPSETTINGS_NOAUTOSAVES) noautosaves = 1;

	startskill = cvar("skill");
	developer = cvar("developer");

	world_sounds = &world.sounds;
// the area based ambient sounds MUST be the first precache_sounds

// player precaches	
	precache_sound ("weapons/r_exp3.wav");		// new rocket explosion
	precache_sound ("weapons/rocket1i.wav");	// spike gun
	precache_sound ("weapons/sgun1.wav");
	precache_sound ("weapons/guncock.wav");		// player shotgun
	precache_sound ("weapons/ric1.wav");		// ricochet (used in c code)
	precache_sound ("weapons/ric2.wav");		// ricochet (used in c code)
	precache_sound ("weapons/ric3.wav");		// ricochet (used in c code)
	precache_sound ("weapons/spike2.wav");		// super spikes
	precache_sound ("weapons/tink1.wav");		// spikes tink (used in c code)
	precache_sound ("weapons/grenade.wav");		// grenade launcher
	precache_sound ("weapons/bounce.wav");		// grenade bounce
	precache_sound ("weapons/shotgn2.wav");		// super shotgun
	precache_sound ("weapons/axhit4.wav");		// extra axe sound for melee - greenwood
	precache_sound ("weapons/spindn_click.wav");		// super nailgun spindown click
	
	precache_sound ("enforcer/enfstop.wav");	// laser cannon
	
	precache_sound ("hipweap/laserg.wav");		// laser cannon
	precache_sound ("hipweap/laserric.wav");	// laser cannon ricochet
	precache_sound ("hipweap/proxwarn.wav");	// proximity bomb
	precache_sound ("hipweap/proxbomb.wav");	// proximity bomb
	
	precache_sound ("weapons/dsfirxpl.wav");   // for plasma hit
	precache_sound ("weapons/dsplasma.wav");    // plasma firing

// sounds used from C physics code
	precache_sound ("demon/dland2.wav");		// landing thud
	precache_sound ("misc/h2ohit1.wav");		// landing splash

// setup precaches allways needed
	precache_sound ("items/itembk2.wav");		// item respawn sound
	precache_sound ("player/plyrjmp8.wav");		// player jump
	precache_sound ("player/land.wav");			// player landing
	precache_sound ("player/land2.wav");		// player hurt landing
	precache_sound ("player/drown1.wav");		// drowning pain
	precache_sound ("player/drown2.wav");		// drowning pain
	precache_sound ("player/gasp1.wav");		// gasping for air
	precache_sound ("player/gasp2.wav");		// taking breath
	precache_sound ("player/h2odeath.wav");		// drowning death

	precache_sound ("misc/talk.wav");			// talk
	precache_sound ("player/teledth1.wav");		// telefrag
	precache_sound ("misc/r_tele1.wav");		// teleport sounds
	precache_sound ("misc/r_tele2.wav");
	precache_sound ("misc/r_tele3.wav");
	precache_sound ("misc/r_tele4.wav");
	precache_sound ("misc/r_tele5.wav");
	precache_sound ("weapons/lock4.wav");		// ammo pick up
	precache_sound ("weapons/pkup.wav");		// weapon up
	precache_sound ("items/armor1.wav");		// armor up
	precache_sound ("weapons/lhit.wav");		//lightning
	precache_sound ("weapons/lstart.wav");		//lightning start
	precache_sound ("items/damage3.wav");
	precache_sound ("misc/null.wav");
	precache_sound ("doors/alka_doorlocked.wav");

	precache_sound ("weapons/sawidle.wav");		//chainsaw idle
	precache_sound ("weapons/sawridle.wav");	//chainsaw idle
	precache_sound ("weapons/sawatck.wav");		//chainsaw attack
	precache_sound ("weapons/sawguts.wav");		//chainsaw hit guts
	
	precache_sound ("misc/power.wav");			//lightning for boss
	
// johnfitz -- precache sounds for ladder
	//precache_sound ("ladder/metal1.wav");
	//precache_sound ("ladder/metal2.wav");
	//precache_sound ("ladder/metal3.wav");
	
// johnfitz -- precache underwater sound & burning sound
	precache_sound ("misc/uwater.wav");
	precache_sound ("misc/burning.wav");
	precache_sound ("misc/burning2.wav");
	
// johnfitz -- precache sounds for cheats
	precache_sound ("items/protect.wav");
	precache_sound ("items/damage.wav");
	precache_sound ("items/damage2.wav");
	precache_sound ("items/damage3.wav");

// player gib sounds
	precache_sound ("player/gib.wav");			// player gib sound
	precache_sound ("player/udeath.wav");		// player gib sound
	precache_sound ("player/tornoff2.wav");		// gib sound

// player pain sounds

	precache_sound ("player/pain1.wav");
	precache_sound ("player/pain2.wav");
	precache_sound ("player/pain3.wav");
	precache_sound ("player/pain4.wav");
	precache_sound ("player/pain5.wav");
	precache_sound ("player/pain6.wav");

// player death sounds
	precache_sound ("player/death1.wav");
	precache_sound ("player/death2.wav");
	precache_sound ("player/death3.wav");
	precache_sound ("player/death4.wav");
	precache_sound ("player/death5.wav");

// ax sounds	
	precache_sound ("weapons/ax1.wav");			// ax swoosh
	precache_sound ("player/axhit1.wav");		// ax hit meat
	precache_sound ("player/axhit2.wav");		// ax hit world
	precache_sound ("weapons/axhit3.wav");		// new player meat

	precache_sound ("player/h2ojump.wav");		// player jumping into water
	precache_sound ("player/slimbrn2.wav");		// player enter slime
	precache_sound ("player/inh2o.wav");		// player enter water
	precache_sound ("player/inlava.wav");		// player enter lava
	precache_sound ("misc/outwater.wav");		// leaving water sound

	precache_sound ("player/lburn1.wav");		// lava burn
	precache_sound ("player/lburn2.wav");		// lava burn

	precache_sound ("misc/water1.wav");			// swimming
	precache_sound ("misc/water2.wav");			// swimming

	precache_sound ("player/foot1.wav");
	precache_sound ("player/foot2.wav");
	precache_sound ("player/foot3.wav");
	precache_sound ("player/foot4.wav");
	precache_sound ("player/foot5.wav");
	precache_sound ("player/foot6.wav");
	precache_sound ("player/foot7.wav");

	precache_sound ("items/jboots_plyrjmp1.wav");		//player airjump with jboots jcr
	precache_sound ("items/jboots_plyrjmp0.wav");		//player jump with jboots 
	precache_sound ("items/jboots_got.wav");			// got the jump boots
	precache_sound ("items/jboots_got_timed.wav");		// got the timed jump boots
	precache_sound ("items/jboots_dry.wav");			// empty jump boots
	precache_sound ("items/jboots_timed.wav");			// timed jump boot powerup

	precache_model ("progs/player.mdl");
	precache_model ("progs/eyes.mdl");
	precache_model ("progs/h_player.mdl");
	precache_model ("progs/gib1.mdl");
	precache_model ("progs/gib2.mdl");
	precache_model ("progs/gib3.mdl");

	precache_model ("progs/s_bubble.spr");	// drowning bubbles
	precache_model ("progs/s_explod.spr");	// sprite explosion
	precache_model ("progs/s_explo2.spr");	// sprite explosion
	precache_model ("progs/s_light.spr");	// light bulb

	precache_model ("progs/v_alkaxe20fps.mdl");
	precache_model ("progs/v_shot40fps.mdl");
	precache_model ("progs/v_nail_alk40fps.mdl");
	precache_model ("progs/v_nail3.mdl");
	precache_model ("progs/v_rock_40fps.mdl");
	precache_model ("progs/v_shot2_40fps.mdl");
	precache_model ("progs/v_nail2.mdl");
	precache_model ("progs/v_rock2_40fps.mdl");
	precache_model ("progs/v_laserg40fps.mdl");
	precache_model ("progs/v_saw.mdl");		//dhm - Chainsaw
	precache_model ("progs/v_mine.mdl");
	
	precache_model ("progs/bolt.mdl");		// for lightning gun
	precache_model ("progs/bolt2.mdl");		// for lightning gun
	precache_model ("progs/bolt3.mdl");		// for boss shock
	precache_model ("progs/lavaball.mdl");	// for testing
	precache_model ("progs/lasrspik.mdl");
	
	precache_model ("progs/missile.mdl");
	precache_model ("progs/grenade.mdl");
	precache_model ("progs/proxbomb.mdl");
	precache_model ("progs/spike.mdl");
	precache_model ("progs/s_spike.mdl");

	precache_model ("progs/backpack.mdl");

	precache_model ("progs/zom_gib.mdl");
	precache_model ("progs/bit.mdl");

	precache_model ("progs/v_light.mdl");
	precache_model ("progs/misc_empty.mdl");
	
	precache_model ("progs/d_explod.spr");

	precache_model ("progs/jumpblue.mdl");
	precache_model ("progs/jumpgold.mdl");

	precache_model ("progs/spark.mdl");

	precache_model ("progs/pbullet.mdl");      // Plasma bullet model
	precache_model ("progs/g_plasma.mdl");     // Plasma gun item
	precache_model ("progs/v_plasma.mdl");     // Plasma being used
	precache_model ("progs/s_plasma_new.spr");     // Plasma explosion sprite

	precache_model ("progs/pellet_tracer_short.mdl");

	//
	// Setup light animation tables. 'a' is total darkness, 'z' is maxbright.
	// Moved to lights.qc -- bmFbr
	//
	setup_lightstyles();
	
	// setup mapvar bit array
	mapvar_setuparray();

	if(!self.itemstyle) self.itemstyle = ITEMSTYLE_BSP;

	// defaults to base theme, because of course it does
	if (!self.worldtype) self.worldtype = WORLDTYPE_BASE;

	lastdq = -1;
	currentdq = -1;

	linkdoor_e = spawn();
	linkdoor_e.think = LinkDoors2;
	linkdoor_e.nextthink = time + 0.03;

	flickercontroller = spawn();
	flickercontroller.think = flickercontroller_think;
	flickercontroller.nextthink = time + 0.1;

};

//johnfitz -- need to wait a bit before resetting burning/underwater sounds so client will be fully connected when we do
//this is needed when you save and load the game while underwater or burning, the booleans were saved as "true" but the client needs to start the sound still
void() ResetPlayerLoopingSounds =
{
	local entity e;

	e = find(world, classname, "player");
	while(e)
	{		
		e.burningsound = FALSE;
		e.underwatersound = FALSE;
		e = find(e, classname, "player");
	}

	remove(self);
}

//johnfitz -- new stuff for loadsavegame callback function
nosave float loadsavegamecallback_done;

void() RestartLoopSounds_think = {
	sound(self, self.impulse, self.noise, self.volume, self.speed);
};

void() RestartLoopSounds = {
	dprint("Restarting sound loops...\n");
	entity e;
	e = find(world, classname, "play_sound_triggered");
	while (e) {

		if (e.spawnflags & 3 == 3) {
			if (e.state == 1) {
				e.nextthink = time + 0.2;
				e.think = RestartLoopSounds_think;
			}
		}

		e = find(e, classname, "play_sound_triggered");
	}
};

void() LoadSaveGameCallback =
{
	local entity e;
	
	//misc_smoke sounds need to be restarted
	e = find(world, classname, "misc_smoke");
	while(e)
	{
		e.think = smoke_firstthink;
		e.nextthink = time + 0.1;
		e = find(e, classname, "misc_smoke");
	}
	
	//underwater/burning sounds need to be restarted
	//clients not connected yet, need to wait a bit
	e = spawn();
	e.think = ResetPlayerLoopingSounds;
	e.nextthink = time + 0.1;
	
	FindAndReadGlobalGravity();
	RestartLoopSounds();
	loadsavegamecallback_done = 1;
} 
//johnfitz

void() StartFrame =
{
	teamplay = cvar("teamplay");
	skill = cvar("skill");
	framecount = framecount + 1;

	// todo: unify all this logic -bmFbr

	if (cleanUpClientStuff)
		cleanUpClientStuff -= 1;

	else if (!gamestarted && framecount > 2)
	{
		if (framecount != 3)
			cleanUpClientStuff += 2;
		
		gamestarted = TRUE;
	}


	//johnfitz -- new stuff for LoadSaveGameCallback function
	if (framecount == 3)
		loadsavegamecallback_done = 1; //if this variable ever gets to zero again that means a savegame was loaded

	if(!loadsavegamecallback_done && framecount > 3)
		LoadSaveGameCallback();
	//johnfitz

	if(framecount == 1) {
		startupWaterBrushes();
		CreateBackstop();
	}

};

void() EndFrame = {
	//dprint("---------------EndFrame Start--------------------\n");
	//dprint3("Frame: ", ftos(framecount),"\n");
	if (prevframe == framecount) {
	//	dprint("Frame already ran, falling back\n");
	//	dprint("---------------EndFrame End--------------------\n");
		return;
	}

	//eprint(backstop);
	//if(!nextent(backstop)) dprint("Backstop is last\n");
	//else dprint("\bWARNING!!\b Backstop is not last\n");

	prevframe = framecount;
	// set ourselves up to think again next frame
	backstop.nextthink = time;// + 0.05;
	// prevent accidental modification of the backstop
	self = world;
	
	if (framecount <= 2) {
		//dprint("First frames\n");
		//dprint("---------------EndFrame End--------------------\n");
		return;
	}

	update_bulletholes();
	//checkWaterBrush();
	//dprint("---------------EndFrame End Success----------------\n");
}
/*
==============================================================================

BODY QUE

==============================================================================
*/

entity	bodyque_head;

void() bodyque =
{	// just here so spawn functions don't complain after the world
	// creates bodyques
};

void() InitBodyQue =
{
//	local entity	e;
	
    local entity    e;
    e = spawn();
    bodyque_head = e;
    bodyque_head.classname = "bodyque";
    e = spawn();
    bodyque_head.owner = e;
    bodyque_head.owner.classname = "bodyque";
    e = spawn();
    bodyque_head.owner.owner = e;
    bodyque_head.owner.owner.classname = "bodyque";
    e = spawn();
    bodyque_head.owner.owner.owner = e;
    bodyque_head.owner.owner.owner.classname = "bodyque";
    bodyque_head.owner.owner.owner.owner = bodyque_head;
};


// make a body que entry for the given ent so the ent can be
// respawned elsewhere
void(entity ent) CopyToBodyQue =
{
	bodyque_head.angles = ent.angles;
	bodyque_head.model = ent.model;
	bodyque_head.modelindex = ent.modelindex;
	bodyque_head.frame = ent.frame;
	bodyque_head.colormap = ent.colormap;
	bodyque_head.movetype = ent.movetype;
	bodyque_head.velocity = ent.velocity;
	bodyque_head.flags = 0;
	setorigin (bodyque_head, ent.origin);
	setsize (bodyque_head, ent.mins, ent.maxs);
	bodyque_head = bodyque_head.owner;
};


