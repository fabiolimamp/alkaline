

void() test_think = {

	//test_ran = 1;
	dprint3("info_test: ", ftos(time), "\n");
	self.nextthink = time + 0.5;
}

void() info_test = {


	self.solid = SOLID_BBOX;
	//self.movetype = MOVETYPE_STEP;
	setorigin(self, self.origin);
	setmodel(self, "progs/s_light.spr");
	setsize(self, '-16 -16 -16', '16 16 16');
	//self.think = test_think;
	//self.nextthink = time + 1;
	
}