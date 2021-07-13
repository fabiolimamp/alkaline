/*
Version 1.3, currently only available in the IKGUNS package.

PLASMA.QC contains main functions for my plasma gun. 
It needed some modifications in following files:
 
(progs.src of course)
WEAPONS.QC   : weapon selections, firing, precache
DEFS.QC      : variables
ITEMS.QC     : raised max cells to 200, changed weapon_touch and backpacks.
CLIENT.QC    : parm10 and parm11 used for new guns

Don't forget these if you combine this stuff with other patches.

I have made all the new models from scratch. I think the plasma gun
goes pretty well with the style of other Quake guns... Though it has
more different colors than a typical Quake weapon. To use the weapon,
create an entity called "weapon_plasmagun" in your level.

Asking what editors I used? Hehe, how the ms-dos EDIT sounds to you?-)
Ok, I did use meddle 1.7 to convert my handwritten .asc files to mdl...
Lotsa thanks to Brian.
*/

void() Plasma_PreCache =
{
	precache_sound2 ("enforcer/enfstop.wav");   // electric zap (for water hit)
	precache_sound ("weapons/dsfirxpl.wav");   // for plasma hit
	precache_sound ("weapons/dsplasma.wav");    // plasma firing
  precache_model ("progs/pbullet.mdl");      // Plasma bullet model
  precache_model ("progs/g_plasma.mdl");     // Plasma gun item
  precache_model ("progs/v_plasma.mdl");     // Plasma being used
  precache_model ("progs/s_plasma.spr");     // Plasma explosion sprite
};

void()  s_pexplode1  = [1,   s_pexplode2] {};
void()  s_pexplode2  = [2,   s_pexplode3] {};
void()  s_pexplode3  = [3,   s_pexplode4] {};
void()  s_pexplode4  = [4,   s_pexplode5] {};
void()  s_pexplode5  = [5,   SUB_Remove] {};

void(entity inflictor, entity attacker, float damage, entity ignore) WaterRadiusDamage =
{
	local	float 	points;
	local	entity	head;
	local	vector	org;

	head = findradius(inflictor.origin, damage+40);
	
	while (head)
	{
		if (head != ignore)
		{
			if (head.takedamage)
			{
				org = head.origin + (head.mins + head.maxs)*0.5;
				points = 0.5*vlen (inflictor.origin - org);
				if (points < 0)
					points = 0;
				points = damage - points;
				if (head == attacker)
					points = points * 0.5;
				if (points > 0)
				{
          if (CanDamage (head, inflictor) && head.waterlevel>0)
					{	// shambler takes half damage from all explosions
						if (head.classname == "monster_shambler")						
							T_Damage (head, inflictor, attacker, points*0.5);
						else
							T_Damage (head, inflictor, attacker, points);
					}
				}
			}
		}
		head = head.chain;
	}
};


void() PlasmaExplosion =
{
	self.movetype = MOVETYPE_NONE;
	self.velocity = '0 0 0';
	self.touch = SUB_Null;
  setmodel (self, "progs/s_plasma.spr");
	self.solid = SOLID_NOT;
  s_pexplode1 ();
};

void() Plasma_Watercheck =
{
  // The routine modified from BLAZE.QC included in the killer87 package.
  // Basically, plasma bullets explode when hitting liquids.
  // In this explosion, the electic charge of the plasma bullet is spread
  // into the said liquid...
  
  local float  pc;

  pc = pointcontents (self.origin);
  if ((pc == CONTENT_WATER) || (pc == CONTENT_SLIME) || (pc == CONTENT_LAVA))
  {
    sound (self, CHAN_WEAPON, "enforcer/enfstop.wav", 1, ATTN_NORM);

    WaterRadiusDamage (self, self.owner, 60, world);   // Damage
    PlasmaExplosion();                         // Explosion sprite
    return;
  }

  self.think = Plasma_Watercheck;
  self.nextthink = time;
};

void() T_PlasmaTouch =
{
  local float damg;

  if (other == self.owner)
    return;   // don't explode on owner

  if (pointcontents(self.origin) == CONTENT_SKY)
  {
    remove(self);
    return;
  }
  damg = 13;
  
  if (other.health)
  {
    T_Damage (other, self, self.owner, damg );
  }

  // Moves the plasma bullet backwards after hitting.. Otherwise the 
  // explosion sprite would often be inside a wall or something. 
  self.origin = self.origin - 8*normalize(self.velocity);

  // Sound from Doom...
  sound (self, CHAN_WEAPON, "weapons/dsfirxpl.wav", 1, ATTN_NORM);
  PlasmaExplosion ();
};

/*
================
W_FirePlasma
================
*/
void() W_FirePlasma =
{
  local entity missile;
  
  // Now it only shoots once per cell... Just to make it not so overpowered
  self.currentammo = self.ammo_cells = self.ammo_cells - 1;

  // Taken from Doom...
  sound (self, CHAN_WEAPON, "weapons/dsplasma.wav", 1, ATTN_NORM);

  self.punchangle_x = -2;

  missile = spawn ();
  missile.owner = self;
  missile.movetype = MOVETYPE_FLYMISSILE;    // Like a rocket
  missile.solid = SOLID_BBOX;
  missile.classname = "plasma";
  missile.flags = missile.flags | FL_PROJECTILE;
    
  // set plasma bullet speed. (Basically AIM with some random)  

  makevectors (self.v_angle);
  missile.velocity = aim(self, 1000);
  missile.velocity = missile.velocity * 1000;
  missile.velocity = missile.velocity + ( crandom() * 50 * v_right );
  missile.velocity = missile.velocity + ( crandom() * 50 * v_up );
  missile.angles = vectoangles(missile.velocity);
  missile.avelocity = '300 300 300';  

  missile.nextthink = time;
  missile.think = Plasma_Watercheck;        // If shot underwater -> razzp!
  missile.touch = T_PlasmaTouch;
  
  missile.effects = 8;           // Plasma bullets emit light...

  setmodel (missile, "progs/pbullet.mdl");   // Plasma bullet model
  setsize (missile, '0 0 0', '0 0 0');
  //setorigin (missile, self.origin + v_forward*8 + '0 0 10' + v_right*10);
  setorigin (missile, self.origin + v_forward*12 + '0 0 10');
};

// Added the plasma gun... Drop it in like any other guns.

void() weapon_touch;
void() StartItem;

void() weapon_plasmagun =
{
	precache_model ("progs/g_plasma.mdl");
	setmodel (self, "progs/g_plasma.mdl");
	self.weapon = WEAPON_PLASMA;
	self.classname = "weapon_plasmagun";
	self.netname = "Plasma Rifle";
	self.touch = weapon_touch;
  if(!self.ammo_cells) self.ammo_cells = 15;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

