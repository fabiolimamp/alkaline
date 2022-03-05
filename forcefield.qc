/* 
   misc_forcefield by bmFbr

   Based on particle effects QuickC program
   By Jim Dose'  9/19/96
   Copyright (c)1996 Hipnotic Interactive, Inc.
   All rights reserved.
   Do not distribute.
*/

float FORCEFIELD_START_ON = 1;
float FORCEFIELD_PULSE = 2;
float FORCEFIELD_SOLID = 4;

float FORCEFIELD_ANGLE_XZ = 1;
float FORCEFIELD_ANGLE_YZ = 2;
float FORCEFIELD_ANGLE_XY = 3;



void(entity e) forcefield_XZ = {
	local vector pos;
   local vector start;
   local vector end;

   e.ltime = time + 0.25;

   start = e.dest1 + e.origin;
   end   = e.dest2 + e.origin;
   pos_y = start_y;
   pos_z = start_z;

   while (pos_z <= end_z) {
      pos_x = start_x;

      while (pos_x <= end_x) {
         particle(pos, '0 0 0', e.color, e.count);
         pos_x = pos_x + 16;
      }

      pos_z = pos_z + 16;
	}
};

void(entity e) forcefield_YZ = {
	local vector pos;
   local vector start;
   local vector end;

   e.ltime = time + 0.25;

   start = e.dest1 + e.origin;
   end   = e.dest2 + e.origin;
   pos_x = start_x;
   pos_z = start_z;
   while (pos_z < end_z) {
      pos_y = start_y;

      while (pos_y < end_y) {
         particle(pos, '0 0 0', e.color, e.count);
			pos_y = pos_y + 16;
		}

		pos_z = pos_z + 16;
	}
};

void(entity e) forcefield_XY = {
	local vector pos;
   local vector start;
   local vector end;

   start = e.dest1 + e.origin;
   end   = e.dest2 + e.origin;
   pos_x = start_x;
   pos_z = start_z;

   while (pos_x < end_x) {
      pos_y = start_y;

      while (pos_y < end_y) {
         particle(pos, '0 0 0', e.color, e.count);
			pos_y = pos_y + 16;
		}

		pos_x = pos_x + 16;
	}
};

void() forcefield_pulse = {

   // Only show particles if client is visible.
   // This helps to keep network traffic down to a minimum.
   if (!checkclient() )
      return;

   if(self.fixangle == FORCEFIELD_ANGLE_XZ) forcefield_XZ(self);
   else if(self.fixangle == FORCEFIELD_ANGLE_YZ) forcefield_YZ(self);
   else if(self.fixangle == FORCEFIELD_ANGLE_XY) forcefield_XY(self);
   else return;

   if (self.spawnflags & FORCEFIELD_PULSE) return;

   if (self.state && !(self.spawnflags & FORCEFIELD_PULSE)) self.nextthink = self.ltime + 0.1;
}

void() forcefield_touch =	{
   if (!self.dmg)
      return;

   if (time > self.ltime)
      return;

	if (time < self.attack_finished)
		return;

	self.attack_finished = self.ltime + 0.5;
	T_Damage(other, self, self, self.dmg);
};

void() forcefield_use = {
   if (self.noise != "") sound(self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
   dprint("forcefield used\n");
   if(self.spawnflags & FORCEFIELD_PULSE) {
      forcefield_pulse();
   }
   else {
      if (!self.state) {
         self.state = 1;
         self.nextthink = self.ltime + 0.1;
         if (self.spawnflags & FORCEFIELD_SOLID) {
            self.movetype = MOVETYPE_PUSH;
            self.solid = SOLID_BSP;
         }
      }
      else {
         self.state = 0;
         self.nextthink = -1;
         self.movetype = MOVETYPE_NONE;
         self.solid = SOLID_NOT;
      }
   }
}

/*QUAKED misc_forcefield (0 .5 .8) ? FORCEFIELD_START_ON FORCEFIELD_PULSE FORCEFIELD_SOLID X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY

Creates a force field particle effect roughly the size of the defining brush. Can be toggled on/off by targeting it.

FORCEFIELD_START_ON Force field will spawn in the active state.

FORCEFIELD_PULSE Instead of a constant effect, the entity will generate a single pulse of the field effect each time it's triggered.

FORCEFIELD_SOLID Blocks movement when the field is active.

"color" is the color of the particles.  Default is 192 (yellow).
"count" is the density of the particles.  Default is 2.
"noise" is the sound to play when triggered.  Do not use a looping sound here.
"dmg" is the amount of damage to cause when touched.
*/

/*FGD
@SolidClass base(Appearflags, Targetname) = misc_forcefield : "Creates a force field particle effect roughly the size of the defining brush. Can be toggled on/off by targeting it.

FORCEFIELD_START_ON Force field will spawn in the active state.

FORCEFIELD_PULSE Instead of a constant effect, the entity will generate a single pulse of the field effect each time it's triggered.

FORCEFIELD_SOLID Blocks movement when the field is active.

color is the color of the particles.  Default is 192 (yellow).
count is the density of the particles.  Default is 2.
noise is the sound to play when triggered.  Do not use a looping sound here.
dmg is the amount of damage to cause when touched."
[
   color(integer) : "Palette index for color" : 192
   count(integer) : "Density of particles" : 2
   dmg(integer) : "Amount of damage when touched" : 0
   spawnflags(flags) =
   [
      1 : "FORCEFIELD_START_ON" : 0
      2 : "FORCEFIELD_PULSE" : 0
      4 : "FORCEFIELD_SOLID" : 0
   ]
]
*/
void() misc_forcefield = {

   if ( !self.color )
      self.color = 192;

   if ( self.count == 0 )
      self.count = 2;
   
   self.classname = "forcefield";
   self.solid = SOLID_NOT;
   self.movetype = MOVETYPE_NONE;
   //self.solid = SOLID_BSP;
   //self.movetype = MOVETYPE_PUSH;

   self.state = 0;

   setmodel (self, self.model);
   self.model = string_null;

   //self.origin = ( self.mins + self.maxs ) * 0.5;
   setorigin (self, self.origin);
   self.dest = self.maxs - self.mins - '16 16 16';
   self.dest1 = self.mins + '8 8 8' - self.origin;
   self.dest2 = self.maxs + '7.9 7.9 7.9' - self.origin;

   setsize (self, self.mins, self.maxs);
   
   if(!(self.spawnflags & FORCEFIELD_PULSE)) self.think = forcefield_pulse;

   self.touch = forcefield_touch;
   self.use = forcefield_use;

//   dprint( vtos( self.dest ) );
//   dprint( "  " );
   if (self.dest_x > self.dest_z)	{
      if (self.dest_y > self.dest_z )	{
         self.fixangle = FORCEFIELD_ANGLE_XY;
         self.dest1_z = (self.dest1_z + self.dest2_z) / 2;
		}
		else {
         self.fixangle = FORCEFIELD_ANGLE_XZ;
         self.dest1_y = ( self.dest1_y + self.dest2_y ) / 2;
		}
	}
	else {
      if (self.dest_y > self.dest_x) {
         self.fixangle = FORCEFIELD_ANGLE_YZ;
         self.dest1_x = ( self.dest1_x + self.dest2_x ) / 2;
		}
		else {
         self.fixangle = FORCEFIELD_ANGLE_XZ;
         self.dest1_y = ( self.dest1_y + self.dest2_y ) / 2;
		}
	}

   if (self.noise != "") precache_sound( self.noise );
   
   self.ltime = time;
};
