
void() water_touch = {
	
}

void() trigger_water = {
	InitTrigger();
	setmodel(self, self.model);
	self.touch = water_touch;
}