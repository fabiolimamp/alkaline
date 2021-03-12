/*
QUAKED weapon_laser_gun (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_laser_gun =
{
	precache_model ("progs/g_laserg.mdl");
	setmodel (self, "progs/g_laserg.mdl");
	self.weapon = 3;
	self.netname = "Laser Cannon";
	self.items = IT_LASER_CANNON;
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};