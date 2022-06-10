/************************************************
Color shift controller

Priority-based. If the color being set has a lower priority than the current one, the color won't change.
It also stores the immediately lower priority if set. 

Remarks:
- Backgroud fade from textstory is 110, from the trifecta is 100, burning status is 90, and dynamic liquids is 70
- Priority 0 should *always* reset colors

*************************************************/


void(entity client, float density, vector color, float pr) csf_save = {
	client.csf_priority = pr;
	client.csf_color = color;
	client.csf_density = density;
}

void(entity client, float density, vector color, float pr) csf_save_prev = {
	client.csf_priority_prev = pr;
	client.csf_color_prev = color;
	client.csf_density_prev = density;
}

// pushes the current cshift values to the previous slot
void(entity client) csf_push = {
	client.csf_priority_prev = client.csf_priority;
	client.csf_color_prev = client.csf_color;
	client.csf_density_prev = client.csf_density;
}

// pops back the previous cshift values to current, and clear the previous ones
void(entity client) csf_pop = {
	client.csf_priority = client.csf_priority_prev;
	client.csf_color = client.csf_color_prev;
	client.csf_density = client.csf_density_prev;

	client.csf_priority_prev = 0;
	client.csf_color_prev = '0 0 0';
	client.csf_density_prev = 0;
}

// reads the client's current cshift values and applies them to the screen
void(entity client) csf_apply = {
	stuffcmd(client, "\nv_cshift ");
	stuffcmd(client, ftos(client.csf_color_x));
	stuffcmd(client, " ");
	stuffcmd(client, ftos(client.csf_color_y));
	stuffcmd(client, " ");
	stuffcmd(client, ftos(client.csf_color_z));
	stuffcmd(client, " ");
	stuffcmd(client, ftos(client.csf_density));
	stuffcmd(client, "\n");
}

// sets the current cshift if the current one has same or lower priority
void(entity client, float density, vector color, float pr) csf_set = {
	if (client.csf_priority > pr) {
		if (client.csf_priority_prev <= pr) csf_save_prev(client, density, color, pr);
		return;
	}

	if (client.csf_priority < pr)
		csf_push(client);

	if (client.csf_density == density && client.csf_color == color)
		csf_save(client, density, color, pr);
	else {
		csf_save(client, density, color, pr);
		csf_apply(client);
	}
}

// overrides the current applied cshift without saving anything to previous
void(entity client, float density, vector color, float pr) csf_override = {
	if (pr == 0) csf_save(client, 0, '0 0 0', 0);
	else csf_save(client, density, color, pr);

	csf_apply(client);
}


// clears current cshift and restores the previous one if set
void(entity client, float pr) csf_clear = {

	// current cshift has a higher priority than the one being cleared
	if (client.csf_priority > pr) {
		// if the previous, lower-priority cshift is the same or lower than the one trying to be set,
		// override that in background
		if (client.csf_priority_prev <= pr) csf_save_prev(client, 0, '0 0 0', pr);
		// bail out without changing the current cshift
		return;
	}

	// restores previous cshift values
	csf_pop(client);
	
	// if previous cshift was priority 0, force clear all colors
	if (client.csf_priority == 0) csf_save(client, 0, '0 0 0', 0);
	
	csf_apply(client);
}


// clears all cshifts and fades
void(entity client) csf_clear_all = {
	if (client.csfcontroller.classname == "csfcontroller") remove(client.csfcontroller);
	client.csfcontroller = world;
	csf_save(client, 0, '0 0 0', 0);
	csf_save_prev(client, 0, '0 0 0', 0);
	csf_apply(client);
}


void() csfcontroller_think = {
	
	entity e = self.owner;
	float dest_density;
	vector dest_color;

	// when fading out, destination color will always be the previous one
	if (self.style == 1) {
		dest_density = e.csf_density_prev;
		dest_color = e.csf_color_prev;
	}
	else {
		dest_density = self.csf_density;
		dest_color = self.csf_color;
	}

	// fade still happening
	if (self.pain_finished > time && (e.csf_density != dest_density || e.csf_color != dest_color)) {
		
		float density;
		vector color;
		
		// calculate the fade % that's happened
		float fraction = 1 - (self.pain_finished - time) / self.speed; 

		// calculate the color and density intermediate values based on the fade %
		density = lerpHermite(e.csf_density, dest_density, fraction);
		color = lerpVectorHermite(e.csf_color, dest_color, fraction);

		// priority will still be the same while fade is going on,
		// regardless if it's in/out
		csf_override(e, density, color, self.csf_priority);

		self.nextthink = time + 0.04;
	}
	// fade ended
	else {
		if (self.style == 1) {
			// if fading out, set back everything to previous when fade ends
			csf_pop(e);
			csf_apply(e);
			return;
		}
		
		// if fading in, the priority will be the same as at the start
		csf_override(e, dest_density, dest_color, self.csf_priority);
	}

}


void(entity client) csfcontroller_start = {
	if (client.csfcontroller.classname == "csfcontroller" && client.csfcontroller.owner == client)
		return;

	entity e = spawn();
	client.csfcontroller = e;
	e.owner = client;
	e.classname = "csfcontroller";
	e.think = csfcontroller_think;
}


// starts a fade from the immediate current cshift color
void(entity client, float density, vector color, float spd, float pr) csf_fade = {
	csfcontroller_start(client);

	if (client.csf_priority > pr) {
		if (client.csf_priority_prev <= pr) csf_save_prev(client, density, color, pr);
		return;
	}

	if (client.csf_priority < pr)
		csf_push(client);

	entity ct = client.csfcontroller;

	ct.speed = spd;
	ct.pain_finished = time + spd;
	ct.csf_color = color;
	ct.csf_density = density;
	ct.csf_priority = pr;
	ct.style = 0; //fade in
	ct.nextthink = time + 0.04;
}


void(entity client, float spd, float pr) csf_fade_clear = {
	csfcontroller_start(client);

	if (client.csf_priority > pr) {
		if (client.csf_priority_prev <= pr) csf_save_prev(client, 0, '0 0 0', pr);
		return;
	}

	if (client.csf_priority < pr)
		csf_push(client);

	entity ct = client.csfcontroller;


	ct.speed = spd;
	ct.pain_finished = time + spd;

	// priority 0 should always clear cshift
	/*if (client.csf_priority_prev == 0) {
		ct.csf_color = '0 0 0';
		ct.csf_density = 0;
	}
	else {
		ct.csf_color = client.csf_color_prev;
		ct.csf_density = client.csf_density_prev;	
	}*/
	
	ct.csf_priority = pr;
	ct.style = 1; //fade out
	ct.nextthink = time + 0.04;
}

