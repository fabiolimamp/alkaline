/*
=============
ai_turn_in_place

don't move, but turn towards ideal_yaw
=============
*/
void() ai_turn_in_place =
{
   local float delta;

   self.nextthink = time + 0.1;
   enemy_yaw = vectoyaw(self.enemy.origin - self.origin);
   delta = fabs(self.angles_y - enemy_yaw);
   if (delta > MIN_ANGLE_DELTA)
      {
      self.ideal_yaw = enemy_yaw;
      ChangeYaw();
      }
   else
      {
      self.think = self.th_run;
      }
};