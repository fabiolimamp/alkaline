float	modelindex_eyes, modelindex_player;
nosave float 	gameloaded;

/*
=============================================================================

				PLAYER GAME EDGE FUNCTIONS

=============================================================================
*/

void() set_suicide_frame;

// called by ClientKill and DeadThink
void() respawn = {
	if (coop)
	{
		// make a copy of the dead body for appearances sake
		CopyToBodyQue (self);
		// get the spawn parms as they were at level start
		setspawnparms (self);
		// respawn		
		PutClientInServer ();
	}
	else if (deathmatch)
	{
		// make a copy of the dead body for appearances sake
		CopyToBodyQue (self);
		// set default spawn parms
		SetNewParms ();
		// respawn		
		PutClientInServer ();
	}
	else
	{	// restart the entire server
		localcmd ("restart\n");
	}
};


/*
============
ClientKill

Player entered the suicide command
============
*/
void() ClientKill = {
	bprint (self.netname);
	bprint (" suicides\n");
	set_suicide_frame ();
	self.modelindex = modelindex_player;
	self.frags = self.frags - 2;	// extra penalty
	respawn ();
};

float(vector v) CheckSpawnPoint = {
	return FALSE;
};

/*
===============
PlayerRessurect - johnfitz
brings player back to life on the spot
===============
*/
void() PlayerRessurect =
{
	if ((self.deadflag != DEAD_RESPAWNABLE))
		return;
		
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
	self.attack_finished = time;
	self.deadflag = DEAD_NO;
	self.pausetime = 0;
	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
	self.view_ofs = '0 0 22';
	
	//lose powerups
	self.items &~= IT_INVISIBILITY | IT_SUIT | IT_QUAD | IT_TRIFECTA; 
	self.items |= IT_INVULNERABILITY;
	self.super_damage_finished = 0;
	self.radsuit_finished = 0;
	self.invisible_finished = 0;
	self.invincible_finished = time + 5;
	self.effects = 0;
	self.invincible_time = 1;
	self.trif_time = 0;
	self.trif_finished = 0;

	
	StopBurning(self);

	W_ChangeWeapon(self.weapon);
	
	player_stand1 ();

	bprint (self.netname);
	bprint (" was ressurected\n");
	stuffcmd (self, "bf\n");
	sound (self, CHAN_VOICE, "items/protect.wav", 1, ATTN_NORM);

}

void() PlayerDeathThink =
{
//	local entity	old_self;
	local float		forward;

	if ((self.flags & FL_ONGROUND))
	{
		forward = vlen (self.velocity);
		forward = forward - 20;
		if (forward <= 0)
			self.velocity = '0 0 0';
		else	
			self.velocity = forward * normalize(self.velocity);
	}

// wait for all buttons released
	if (self.deadflag == DEAD_DEAD)
	{
		if (self.button2 || self.button1 || self.button0)
			return;
		self.deadflag = DEAD_RESPAWNABLE;
		return;
	}

// johnfitz -- ressurection cheat
	if (self.impulse == 154 && !deathmatch && !coop)
	{
		PlayerRessurect();
	}

// wait for any button down
	if (!self.button2 && !self.button1 && !self.button0)
		return;

	self.button0 = 0;
	self.button1 = 0;
	self.button2 = 0;
	respawn();
};

/*
===========
PlayerClimb
============
*/
void() PlayerClimb = //johnfitz
{
	self.velocity = '0 0 160';
}

/*
===========
PlayerJump
============
*/
void() PlayerJump =
{
//	local vector start, end;
	
	if (self.flags & FL_WATERJUMP)
		return;
	
	if (self.waterlevel >= 2)
	{
		if (self.onladder)
			self.velocity_z = 160;
		else if (self.watertype == CONTENT_WATER)
			self.velocity_z = 100;
		else if (self.watertype == CONTENT_SLIME)
			self.velocity_z = 80;
		else
			self.velocity_z = 50;

// play swiming sound
		if (self.swim_flag < time && !self.onladder && !self.wasonladder )
		{
			self.swim_flag = time + 1;
			if (random() < 0.5)
				sound (self, CHAN_BODY, "misc/water1.wav", 1, ATTN_NORM);
			else
				sound (self, CHAN_BODY, "misc/water2.wav", 1, ATTN_NORM);
		}

		return;
	}


	if (self.jboots_rechargelimit) {	//JCR jump boots equipped jump logic
		
		if (self.flags & FL_ONGROUND)	{
			if (!(self.flags & FL_JUMPRELEASED))
				return;

			self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
			self.button2 = 0;
			self.jboots_sfx = 0;
			self.flags = self.flags - (self.flags & FL_ONGROUND);
			self.jboots_onground = 0;
			self.jboots_ammo = self.jboots_rechargelimit;
			sound(self, CHAN_BODY, "items/jboots_plyrjmp0.wav", 1, ATTN_NORM);	//Regularjump with jump boots equipped.
			self.velocity_z = (self.velocity_z + 270);
		}
		else {
			if (time < self.offground_start + 0.2) return;

			if (self.jboots_rechargelimit == -1 || self.jboots_ammo >= 1 || self.jboots_onground) {	//Conditions for airjumping.
			
				if (!(self.flags & FL_JUMPRELEASED))
					return;
				
				self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
				self.button2 = 0;
				self.jboots_sfx = time + 0.4;

				if (self.jboots_onground)
					self.jboots_ammo = self.jboots_rechargelimit;	//Resets air jump limit once player contacts the ground.
				
				self.jboots_onground = 0;
				self.jboots_ammo = self.jboots_ammo - 1;
				sound(self, CHAN_BODY, "items/jboots_plyrjmp1.wav", 1, ATTN_NORM);	//Airjump fired.
				self.punchangle_x = -1;		//View shift when airjump is fired.

				if (self.velocity_z > 360)
					self.velocity_z = self.velocity_z + 360;
				else
					self.velocity_z = 360;
				
			}
			else {
				if (self.jboots_sfx < time) {
					self.jboots_sfx = (time + 0.4);
					sound(self, CHAN_BODY, "items/jboots_dry.wav", 1, ATTN_NORM);	//Out of air jumps!
				}
			}	
		}	//JCR jump boots equipped jump logic end
	}

	else {
		if (!(self.flags & FL_ONGROUND))
			return;

		if ( !(self.flags & FL_JUMPRELEASED) )
			return;		// don't pogo stick

		self.flags = self.flags - (self.flags & FL_JUMPRELEASED);

		self.flags = self.flags - FL_ONGROUND;	// don't stairwalk
		
		self.button2 = 0;
		// player jumping sound
		sound (self, CHAN_BODY, "player/plyrjmp8.wav", 1, ATTN_NORM);
		self.velocity_z = self.velocity_z + 270;
	}
};


/*
===========
WaterMove

============
*/

void() WaterMove =
{
//dprint (ftos(self.waterlevel));
	if (self.movetype == MOVETYPE_NOCLIP){
		self.air_finished = time + 12;
		self.flags &~= FL_INWATER;
		self.waterlevel = 0;
		return;
	}
	if (self.health <= 0)
		return;

	if (self.waterlevel != 3)
	{
		if (self.air_finished < time)
			sound (self, CHAN_VOICE, "player/gasp2.wav", 1, ATTN_NORM);
		else if (self.air_finished < time + 9)
			sound (self, CHAN_VOICE, "player/gasp1.wav", 1, ATTN_NORM);
		self.air_finished = time + 12;
		self.dmg = 2;
	}
	else if (self.air_finished < time)
	{	// drown!
		if (self.pain_finished < time)
		{
			self.dmg = self.dmg + 2;
			if (self.dmg > 15)
				self.dmg = 10;
			
			T_Damage(self, world, world, self.dmg, DMGTYPE_DROWN);
			self.pain_finished = time + 1;
		}
	}

	if (self.onladder) {
		self.flags &~= FL_INWATER;
	}

	if (!self.waterlevel)
	{
		if (self.flags & FL_INWATER)
		{	
			// play leave water sound
			sound (self, CHAN_BODY, "misc/outwater.wav", 1, ATTN_NORM);
			self.flags = self.flags - FL_INWATER;
		}
		return;
	}

	if (self.watertype == CONTENT_LAVA)
	{	// do damage
		if (self.dmgtime < time)
		{
			if (self.radsuit_finished > time)
				self.dmgtime = time + 1;
			else
				self.dmgtime = time + 0.2;

			T_Damage(self, world, world, 10*self.waterlevel, DMGTYPE_LAVA);
		}
	}
	else if (self.watertype == CONTENT_SLIME)
	{	// do damage
		if (self.dmgtime < time && self.radsuit_finished < time)
		{
			self.dmgtime = time + 1;
			T_Damage(self, world, world, 4*self.waterlevel, DMGTYPE_SLIME);
		}
	}
	
	if ( !(self.flags & FL_INWATER) && !self.onladder && !self.wasonladder)
	{	

// player enter water sound

		if (self.watertype == CONTENT_LAVA)
			sound (self, CHAN_BODY, "player/inlava.wav", 1, ATTN_NORM);
		if (self.watertype == CONTENT_WATER)
			sound (self, CHAN_BODY, "player/inh2o.wav", 1, ATTN_NORM);
		if (self.watertype == CONTENT_SLIME)
			sound (self, CHAN_BODY, "player/slimbrn2.wav", 1, ATTN_NORM);

		self.flags |= FL_INWATER;
		self.dmgtime = 0;
	}

	if (self.waterlevel >= 2 && self.jboots_rechargelimit) {
		self.jboots_ammo = self.jboots_rechargelimit;
	}

	if (! (self.flags & FL_WATERJUMP) )
		self.velocity = self.velocity - 0.8*self.waterlevel*frametime*self.velocity;
};

void() CheckWaterJump =
{
	local vector start, end;

// check for a jump-out-of-water
	makevectors (self.angles);
	start = self.origin;
	start_z = start_z + 8; 
	v_forward_z = 0;
	normalize(v_forward);
	end = start + v_forward*24;
	traceline (start, end, TRUE, self);
	if (trace_fraction < 1)
	{	// solid at waist
		start_z = start_z + self.maxs_z - 8;
		end = start + v_forward*24;
		self.movedir = trace_plane_normal * -50;
		traceline (start, end, TRUE, self);
		if (trace_fraction == 1)
		{	// open at eye level
			self.flags = self.flags | FL_WATERJUMP;
			self.velocity_z = 225;
			self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
			self.teleport_time = time + 2;	// safety net
			return;
		}
	}
};

/*
================
PlayerPreThink

Called every frame before physics are run
================
*/
void() PlayerPreThink =
{
//	local	float	mspeed, aspeed;
//	local	float	r;

	gameloaded = 1;
	self.light_lev = 0; // resets dimlight flags for powerups/status effects

	self.dmg_take_hud = 0;
	
	if (cleanUpClientStuff) {
		fog_setFromEnt( self, self );
		csf_apply(self);
		if (self.sky != world.sky) skybox_apply(self);
	}
	
	if (intermission_running)
	{
		IntermissionThink ();	// otherwise a button could be missed between
		return;					// the think tics
	}

	if (self.view_ofs == '0 0 0')
		return;		// intermission or finale

	if (self.groundentity)
		self.prev_groundvel = self.groundentity.velocity;
	else 
		self.prev_groundvel = '0 0 0';

	self.wasonground = (self.flags & FL_ONGROUND) ? 1 : 0;

	makevectors (self.v_angle);		// is this still used
	//dprint5("vectoyaw: ", ftos(vectoyaw(v_forward)), ", vectoyaw2: ", ftos(vectoyaw2(v_forward)), "\n");
	CheckRules ();
	WaterMove ();

	if (self.waterlevel == 2 && !self.onladder)
		CheckWaterJump ();

	if (self.deadflag >= DEAD_DEAD)
	{
		PlayerDeathThink ();
		return;
	}
	
	if (self.deadflag == DEAD_DYING)
		return;	// dying, so do nothing


	if (self.onladder) {
		
		if (fabs(self.velocity_x) < 1 && fabs(self.velocity_y) < 1 &&
			self.velocity_z < 0 && self.velocity_z > -42 &&
			!(self.flags & FL_WATERJUMP) &&
			self.v_angle_x < 90
		) {
			self.velocity_z = 0;
		}

		self.velocity_x *= 0.9;
		self.velocity_y *= 0.9;

		if (fabs(self.velocity_z) > 160) {
			if (self.velocity_z > 0) self.velocity_z = 160;
			else self.velocity_z = -160;
		}

		if (self.velocity_z == 0) {
			self.ladder_step_height = self.origin_z + 49;
		}

		if (
			(
				(self.onladder && !self.wasonladder) ||
				(self.onladder && self.wasonladder && fabs(self.origin_z - self.ladder_step_height) > 48)
			) && (self.velocity_z != 0)

		)
		{
			self.ladder_step_height = self.origin_z;

			if (random() > 0.5)
				sound (self, CHAN_AUTO, "misc/ladder.wav", 0.5, ATTN_NORM);
			else
				sound (self, CHAN_AUTO, "misc/ladder2.wav", 0.5, ATTN_NORM);
		}
	}		
	else
	{
		self.gravity = self.wantedgravity; 

	}

	if (self.button2)
		PlayerJump ();
	else
		self.flags = self.flags | FL_JUMPRELEASED;

// teleporters can force a non-moving pause time	
	if (time < self.pausetime)
		self.velocity = '0 0 0';

	if (time > self.attack_finished && W_CheckWeapon(self.weapon, self) != WEAPONSTAT_AVAILABLE) 
		W_ChangeWeapon(W_BestWeapon());
	
	
	if (self.jboots_rechargelimit && (self.flags & FL_ONGROUND))		//jcr jboots prethink for onground checking
		self.jboots_onground = TRUE;
	
	// sanity check for cshift every few frames
	if (framecount & 4) {
		if (self.csf_priority == 0 && self.csf_density > 0)
			csf_clear_all(self);
	}

	checkClientInWaterBrush();
	if (self.onladder){
		self.gravity = 0.00000001;
		self.waterlevel = 2;
	}
	self.wasonladder = self.onladder;
	self.onladder = 0;


	if (self.waterlevel < 2 && time < self.pushfinished) {
		ClientPush();// jumppad.qc
	}

};
	
/*
================
CheckPowerups

Check for turning off powerups
================
*/

float DIMLIGHT_SUPER_DAMAGE = 1;
float DIMLIGHT_TRIF = 2;
float DIMLIGHT_INVINCIBLE = 4;
float DIMLIGHT_BURNING = 8;

void() CheckPowerups =
{
	if (self.health <= 0)
		return;

// invisibility
	if (self.invisible_finished)
	{
// sound and screen flash when items starts to run out
		if (self.invisible_sound < time)
		{
			sound (self, CHAN_AUTO, "items/inv3.wav", 0.5, ATTN_IDLE);
			self.invisible_sound = time + ((random() * 3) + 1);
		}


		if (self.invisible_finished < time + 3)
		{
			if (self.invisible_time == 1)
			{
				sprint (self, "Invisibility belt is powering down\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/inv2.wav", 1, ATTN_NORM);
				self.invisible_time = time + 1;
			}
			
			if (self.invisible_time < time)
			{
				self.invisible_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.invisible_finished < time)
		{	// just stopped
			self.items = self.items - IT_INVISIBILITY;
			self.invisible_finished = 0;
			self.invisible_time = 0;
		}
		
	// use the eyes
		self.frame = 0;
		self.modelindex = modelindex_eyes;
	}
	else
		self.modelindex = modelindex_player;	// don't use eyes


// trifecta

	if (self.trif_finished)
	{
	
// sound and screen flash when items starts to run out

		if (self.trif_finished < time + 3)
		{
			if (self.trif_time == 1)
			{
				sprint (self, "Trifecta is running out\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/trifecta2.wav", 1, ATTN_NORM);
				self.trif_time = time + 1;
			}	  
			
			if (self.trif_time < time)
			{
				self.trif_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.trif_finished < time)
		{	// just stopped
			self.items = self.items - IT_TRIFECTA;
			self.trif_finished = 0;
			self.trif_time = 0;
			csf_clear(self, 100);
		}

		if (self.trif_finished > time) {
			self.light_lev = self.light_lev | DIMLIGHT_TRIF;
		}
	
	}


// invincibility
	if (self.invincible_finished)
	{
// sound and screen flash when items starts to run out
		if (self.invincible_finished < time + 3)
		{
			if (self.invincible_time == 1)
			{
				sprint (self, "Protection is almost burned out\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/protect2.wav", 1, ATTN_NORM);
				self.invincible_time = time + 1;
			}
			
			if (self.invincible_time < time)
			{
				self.invincible_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}
		
		if (self.invincible_finished < time)
		{	// just stopped
			self.items = self.items - IT_INVULNERABILITY;
			self.invincible_time = 0;
			self.invincible_finished = 0;
		}
		if (self.invincible_finished > time)
			self.light_lev = self.light_lev | DIMLIGHT_INVINCIBLE;
	}

// super damage
	if (self.super_damage_finished)
	{

// sound and screen flash when items starts to run out

		if (self.super_damage_finished < time + 3)
		{
			if (self.super_time == 1)
			{
				sprint (self, "Quad Damage is wearing off\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/damage2.wav", 1, ATTN_NORM);
				self.super_time = time + 1;
			}	  
			
			if (self.super_time < time)
			{
				self.super_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.super_damage_finished < time)
		{	// just stopped
			self.items = self.items - IT_QUAD;
			self.super_damage_finished = 0;
			self.super_time = 0;
		}
		if (self.super_damage_finished > time)
			self.light_lev = self.light_lev | DIMLIGHT_SUPER_DAMAGE;
	}	

// suit	
	if (self.radsuit_finished)
	{
		self.air_finished = time + 12;		// don't drown

// sound and screen flash when items starts to run out
		if (self.radsuit_finished < time + 3)
		{
			if (self.rad_time == 1)
			{
				sprint (self, "Air supply in Biosuit expiring\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/suit2.wav", 1, ATTN_NORM);
				self.rad_time = time + 1;
			}
			
			if (self.rad_time < time)
			{
				self.rad_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.radsuit_finished < time)
		{	// just stopped
			self.items = self.items - IT_SUIT;
			self.rad_time = 0;
			self.radsuit_finished = 0;
		}
	}

	if (self.jboots_finished)	{
		// sound and screen flash when items starts to run out
		if (self.jboots_finished < time + 3)
		{
			if (self.jboots_time == 1)
			{
				sprint (self, "Super Jump Boot's battery depleting...\n");
				sound (self, CHAN_AUTO, "items/jboots_timed.wav", 1, ATTN_NORM);
				self.jboots_time = time + 1;
			}	  
			
			if (self.jboots_time < time)
			{
				self.jboots_time = time + 1;
			}
		}

		if (self.jboots_finished < time) {	// just stopped
			self.jboots_rechargelimit = self.jboots_prevlimit; // restore previous persistent boot value if there was any
			self.jboots_prevlimit = 0;
			
			if (!self.jboots_rechargelimit) self.items = self.items - IT_JBOOTS;

			self.jboots_finished = 0;
			self.jboots_time = 0;
		}
	}	

};

/*
================
StartBurning -- johnfitz
================
*/
void(entity tgt, entity attacker, float dur) StartBurning = {
	if (tgt.classname != "player")
		return;

	if (tgt.waterlevel >= 3)
		return;

	if (tgt.radsuit_finished > time)
		return;

	if (tgt.invincible_finished > time)
		return;
		
	if (tgt.trif_finished > time)
		return;		
		
	tgt.burning_finished = time + dur;
	tgt.burning_attacker = attacker;
};

/*
================
StopBurning -- johnfitz

clean up after burning state has ended
================
*/
void(entity e) StopBurning = {
	if (e.burning_finished) {
		e.burning_finished = 0;
		e.burning_time = 0;
		e.burning_attacker = world;
		csf_clear(e, 90);
	}
};

/*
================
CheckBurning -- johnfitz

apply damage from being on fire
================
*/
void() CheckBurning = {
	local float a;
	
	if (self.burning_finished) {
		if (self.burning_finished <= time || 
			self.waterlevel >= 3 || 
			self.radsuit_finished > time || 
			self.invincible_finished > time || 
			self.trif_finished > time || 			
			self.deadflag || 
			self.view_ofs == '0 0 0'
		) {
			StopBurning(self);
		}
		else {		
			//apply damage
			if (self.burning_time < time) {
				self.deathtype = DMGTYPE_BURN;
				T_Damage(self, self.burning_attacker, self.burning_attacker, 1, DMGTYPE_BURN);
				self.burning_time = time + 1;
			}
			
			//spawn particles
			//particle (self.origin + self.view_ofs, '0 0 2', 14 * 16, 4);
			
			//update colorshift
			a = (self.burning_finished - time) * 100;
			
			while (a > 120)
				a = a - 20;
				
			if (a > 110)
				a = 220 - a;

			csf_set(self, a, '200 50 0', 90);

			self.light_lev = self.light_lev | DIMLIGHT_BURNING;
		}
	}
};


/*
================
PlayerPostThink

Called every frame after physics are run
================
*/
void() PlayerPostThink =
{
//	local	float	mspeed, aspeed;
//	local	float	r;
	checkClientInWaterBrush();

	if (self.flags & FL_ONGROUND) {
		self.pushfinished = 0;
		self.pushvelocity = '0 0 0';
	}

	if (self.wasonground && !(self.flags & FL_ONGROUND)){
		self.velocity += [self.prev_groundvel_x, self.prev_groundvel_y, 0];
		///dprint("added velocity\n");
	}
	else if (!self.wasonground && self.flags & FL_ONGROUND) {
		self.velocity -= [self.groundentity.velocity_x, self.groundentity.velocity_y, 0];
	}

	if (self.wasonladder){
		self.gravity = 0.00000001;
		self.waterlevel = 2;
	}

	if (self.flags & FL_CLIENT) {
		mapvar_cvar = TRUE;			// Map Variable are live
	}
//johnfitz -- do stuff with burning and underwater sounds before the dead/intermission check, so that we are sure to turn things off correctly
	CheckBurning (); //flamethrower burn
		
	//underwater sounds
	if (self.waterlevel >= 3 && !self.underwatersound)
	{		
		sound (self, 5, "misc/uwater.wav", 1, ATTN_NORM); //use channel 5 so it doesn't override the splash sounds on CHAN_BODY
		self.underwatersound = TRUE;
	}
	else if (self.waterlevel < 3 && self.underwatersound)
	{
		sound (self, 5, "misc/null.wav", 1, ATTN_NORM);
		self.underwatersound = FALSE;
	}
	
	//burning sounds
	if (self.burning_finished > time && !self.burningsound)
	{		
		sound (self, 6, "misc/burning.wav", 1, ATTN_NORM); //use channel 6 so it doesn't fight with any other sounds
		self.burningsound = TRUE;
	}
	else if (self.burning_finished <= time && self.burningsound)
	{
		sound (self, 6, "misc/burning2.wav", 1, ATTN_NORM);
		self.burningsound = FALSE;
	}	
//johnfitz

	if (self.view_ofs == '0 0 0')
		return;		// intermission or finale
	if (self.deadflag)
		return;
		
// do weapon stuff
	if (self.impulse)
		ImpulseCommands();

	W_WeaponFrame ();

// check to see if player landed and play landing sound	
	if ((self.jump_flag < -300) && (self.flags & FL_ONGROUND) && (self.health > 0))
	{
		if (self.jboots_rechargelimit == 1) self.jump_flag *= 0.75;
		else if (self.jboots_rechargelimit >= 2 || self.jboots_rechargelimit == -1) self.jump_flag *= 0.5;

		if (self.watertype == CONTENT_WATER)
			sound (self, CHAN_BODY, "player/h2ojump.wav", 1, ATTN_NORM);
		else if (self.jump_flag < -650)
		{
			T_Damage(self, world, world, 5, DMGTYPE_FALL); 
			sound (self, CHAN_VOICE, "player/land2.wav", 1, ATTN_NORM);
			self.punchangle_x = 3;	
		}
		else
			sound (self, CHAN_VOICE, "player/land.wav", 1, ATTN_NORM);
			self.punchangle_x = 2;	

		self.jump_flag = 0;
	}

	if (!(self.flags & FL_ONGROUND)){
		self.jump_flag = self.velocity_z;
		if (!self.offground_start) self.offground_start = time;
	}
	else
		self.offground_start = 0;

	CheckPowerups ();


	if (self.light_lev)
		self.effects = self.effects | EF_DIMLIGHT;
	else
		self.effects = self.effects - (self.effects & EF_DIMLIGHT);

	/*if (cvar("scratch3")) {
		self.angles_z = cvar("scratch3");
		self.angles_x = self.v_angle_x;
		self.fixangle = 1;
		cvar_set("scratch3", 0);
	}*/
	
	if (self.v_angle_z) {
		self.angles = normalizeAngles180(self.v_angle);

		if (fabs(self.angles_z) < 0.5) 
			self.angles_z = 0;
		else
			self.angles_z = self.angles_z - sign(self.angles_z)*(fabs(self.angles_z)/40 + 0.2);

		self.fixangle = 1;
	}

	//centerprint2(self, ftos(vlen([self.velocity_x, self.velocity_y, 0])), "\n");

	SUB_CallAsSelf(UpdateLightning, self.lightningcontroller);
	self.oldvelocity = self.velocity;
};


/*
===========
ClientObituary

called when a player dies
============
*/
void(entity targ, entity attacker) ClientObituary =
{
	local	float rnum;
	local	string deathstring, deathstring2;
	rnum = random();

	if (targ.classname == "player")
	{
		if (attacker.classname == "teledeath")
		{
			bprint (targ.netname);
			bprint (" was telefragged by ");
			bprint (attacker.owner.netname);
			bprint ("\n");

			attacker.owner.frags = attacker.owner.frags + 1;
			return;
		}

		if (attacker.classname == "teledeath2")
		{
			bprint ("Satan's power deflects ");
			bprint (targ.netname);
			bprint ("'s telefrag\n");

			targ.frags = targ.frags - 1;
			return;
		}

		if (attacker.classname == "player")
		{
			if (targ == attacker)
			{
				// killed self
				attacker.frags = attacker.frags - 1;
				bprint (targ.netname);
				
				if (targ.weapon == 64 && targ.waterlevel > 1)
				{
					bprint (" discharges into the water.\n");
					return;
				}
				if (targ.weapon == WEAPON_GRENADE_LAUNCHER)
					bprint (" tries to put the pin back in\n");
				else
					bprint (" becomes bored with life\n");
				return;
			}
			else if ( (teamplay == 2) && (targ.team > 0)&&(targ.team == attacker.team) )
			{
				if (rnum < 0.25)
					deathstring = " mows down a teammate\n";
				else if (rnum < 0.50)
					deathstring = " checks his glasses\n";
				else if (rnum < 0.75)
					deathstring = " gets a frag for the other team\n";
				else
					deathstring = " loses another friend\n";
				bprint (attacker.netname);
				bprint (deathstring);
				attacker.frags = attacker.frags - 1;
				return;
			}
			else
			{
				attacker.frags = attacker.frags + 1;

				rnum = attacker.weapon;
				if (rnum == WEAPON_AXE)
				{
					deathstring = " was ax-murdered by ";
					deathstring2 = "\n";
				}
				if (rnum == WEAPON_CHAINSAW)
				{
					deathstring = " was chewed up by ";
					deathstring2 = "'s bloody chainsaw\n";
				}
				if(rnum == WEAPON_PLASMA)
				{
					deathstring = " was burned by ";
					deathstring2 = "\n";
				}
				if (rnum == WEAPON_SHOTGUN)
				{
					deathstring = " chewed on ";
					deathstring2 = "'s boomstick\n";
				}
				if (rnum == WEAPON_SUPER_SHOTGUN)
				{
					deathstring = " ate 2 loads of ";
					deathstring2 = "'s buckshot\n";
				}
				if (rnum == WEAPON_NAILGUN)
				{
					deathstring = " was nailed by ";
					deathstring2 = "\n";
				}
				if (rnum == WEAPON_SUPER_NAILGUN)
				{
					deathstring = " was punctured by ";
					deathstring2 = "\n";
				}
				if (rnum == WEAPON_GRENADE_LAUNCHER)
				{
					deathstring = " eats ";
					deathstring2 = "'s pineapple\n";
					if (targ.health < -40)
					{
						deathstring = " was gibbed by ";
						deathstring2 = "'s grenade\n";
					}
				}
				if (rnum == WEAPON_PROXIMITY_GUN)
				{
					if (random()<0.5) {
						deathstring = " got too friendly with ";
					}
					else {
						deathstring = " did the rhumba with ";
					}
					deathstring2 = "'s bomb\n";
				}
				if (rnum == WEAPON_ROCKET_LAUNCHER)
				{
					deathstring = " rides ";
					deathstring2 = "'s rocket\n";
					if (targ.health < -40)
					{
						deathstring = " was gibbed by ";
						deathstring2 = "'s rocket\n" ;
					}
				}
				if (rnum == WEAPON_LIGHTNING)
				{
					deathstring = " accepts ";
					if (attacker.waterlevel > 1)
						deathstring2 = "'s discharge\n";
					else
						deathstring2 = "'s shaft\n";
				}
				if (rnum == WEAPON_LASER_CANNON)
				{
					if (random()<0.5)
					{
						deathstring = " was toasted by ";
					}
					else
					{
						deathstring = " was radiated by ";
					}
					deathstring2 = "'s laser\n";
				}
				
				bprint (targ.netname);
				bprint (deathstring);
				bprint (attacker.netname);
				bprint (deathstring2);
			}
			return;
		}
		else
		{
			targ.frags = targ.frags - 1;
			bprint (targ.netname);

			// attacker has an obituary message?
			if (attacker.obituary != "")
			{
				bprint(" ");
				bprint(attacker.obituary);
				bprint("\n");
				return;
			}
			

			// movers
			if (attacker.solid == SOLID_BSP && attacker != world)
			{	
				bprint (" was squished\n");
				return;
			}

			if (attacker.classname == "trigger_changelevel")
			{
				bprint (" tried to leave\n");
				return;
			}
			

			if (targ.deathtype == DMGTYPE_DROWN)
			{
				if (random() < 0.5)
					bprint (" sleeps with the fishes\n");
				else
					bprint (" sucks it down\n");
				return;
			}

			if (targ.deathtype == DMGTYPE_SLIME)
			{
				if (random() < 0.5)
					bprint (" gulped a load of slime\n");
				else
					bprint (" can't exist on slime alone\n");
				return;
			}

			if (targ.deathtype == DMGTYPE_LAVA)
			{
				if (targ.health < -15)
				{
					bprint (" burst into flames\n");
					return;
				}
				if (random() < 0.5)
					bprint (" turned into hot slag\n");
				else
					bprint (" visits the Volcano God\n");
				return;
			}

			// fell to their death?
			if (targ.deathtype == DMGTYPE_FALL)
			{
				bprint (" fell to his death\n");
				return;
			}

			// hell if I know; he's just dead!!!
			bprint (" died\n");
		}
	}
};
