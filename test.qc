void() test_move = {
	self.think = test_move;
	self.nextthink = time + 0.1;
	//dprint("moving\n");
	movetogoal(8);
}


void() test_think = {
	entity tgt;
	tgt = find(world, targetname, self.target);
	self.goalentity = tgt;
	//self.enemy = find(world, classname, "player");

	tgt.solid = SOLID_TRIGGER;
	setorigin(tgt, tgt.origin);
	setmodel(tgt, "progs/s_light.spr");
	setsize(tgt, '-16 -16 -16', '16 16 16');


	self.think = test_move;
	self.nextthink = time + 1;
}

void() misc_test = {


	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	setorigin(self, self.origin);
	setmodel(self, "progs/s_light.spr");
	setsize(self, '-16 -16 -16', '16 16 40');
	self.think = test_think;
	self.nextthink = time + 1;
}