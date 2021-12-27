/*
==============================================================================

Ep. 1 Boss

==============================================================================
*/


$cd id1/models/shams
$origin 0 0 24
$base base		
$skin base

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9
$frame stand10 stand11 stand12 stand13 stand14 stand15 stand16 stand17

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 
$frame walk8 walk9 walk10 walk11 walk12

$frame run1 run2 run3 run4 run5 run6

$frame smash1 smash2 smash3 smash4 smash5 smash6 smash7 
$frame smash8 smash9 smash10 smash11 smash12

$frame swingr1 swingr2 swingr3 swingr4 swingr5 
$frame swingr6 swingr7 swingr8 swingr9

$frame swingl1 swingl2 swingl3 swingl4 swingl5 
$frame swingl6 swingl7 swingl8 swingl9

$frame magic1 magic2 magic3 magic4 magic5 
$frame magic6 magic7 magic8 magic9 magic10 magic11 magic12

$frame pain1 pain2 pain3 pain4 pain5 pain6

$frame death1 death2 death3 death4 death5 death6 
$frame death7 death8 death9 death10 death11


float D1BOSS_BALL_VEL = 600;
float D1BOSS_HEALTH = 2000; 

float() D1BossCheckAttack = {
	//----------------------------------------------------------------------
	// Check Melee range and constantly fire
	//----------------------------------------------------------------------
	if (enemy_range < RANGE_MELEE) {
		self.attack_state = AS_MELEE;
		dprint("Melee\n");
		return TRUE;
	}
	
	
	//----------------------------------------------------------------------
	// Check Melee range without respect to height
	//----------------------------------------------------------------------
	local vector enemy_org, self_org;
	
	enemy_org = self.enemy.origin;
	self_org = self.origin;
	enemy_org_z = self_org_z;
	if (vlen(self_org - enemy_org) < 120 && (self.origin_z >= self.enemy.origin_z))
		{
		self.attack_state = AS_MELEE;
		return TRUE;		
		}
	
	
	//----------------------------------------------------------------------
	// Range attacks (Spit and Bomb)
	// Attack_chance override (percentage 0-1 chance)
	//----------------------------------------------------------------------
	// Only range attack if cooldown has finished
	if (time > self.attack_finished) {
		// Fast/intense nail/spit attack
		if (enemy_range < RANGE_NEAR) { 
			// Skill 0=3s, 1=2.25s, 2=1.5s, 3=0.75s
			//self.attack_speed = (4 - skill) * 0.75;
			//self.attack_finished = time + self.attack_speed + random();
			//self.attack_finished = time + 2 + random();
			self.attack_state = AS_MISSILE; //AS_MELEE;
			return TRUE;
		}
		// Large rocket bomb attack with floor damage
		else {
			// Skill 0=4s, 1=3s, 2=2s, 3=1s
			//self.attack_speed = (4 - skill) * 1;
			//self.attack_finished = time + self.attack_speed + random();
			//self.attack_finished = time + 3 + random();
			self.attack_state = AS_MISSILE;
			return TRUE;
		}
	}

	//----------------------------------------------------------------------
	// Maintain distance (strafe)
	//----------------------------------------------------------------------
	if (enemy_range >= RANGE_MID || !enemy_vis) {
		if (self.attack_state != AS_STRAIGHT) self.attack_state = AS_STRAIGHT;
	}
	else self.attack_state = AS_SLIDING;
	return FALSE;
};

/*
=================
WizardAttackFinished
=================
*/
void()	D1BossAttackFinished =
{
	if (enemy_range >= RANGE_MID || !enemy_vis)
	{
		self.attack_state = AS_STRAIGHT;
		self.think = d1boss_run1;
	}
	else
	{
		self.attack_state = AS_SLIDING;
		self.think = d1boss_side1;
	}
}

/*
==============================================================================

FAST ATTACKS

==============================================================================
*/
void() D1BossMissileExplode =
{
	T_RadiusDamage (self, self.trueowner, 40, world);
	sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);

	BecomeExplosion();
}

void() D1BossMissileTouch =
{
	if (CheckProjectilePassthru()) return;
	if (other == self.owner)
		return;		// don't explode on owner

	if (other.type == "zombie")
		T_Damage (other, self, self.trueowner, other.health + 25);
	
	D1BossMissileExplode();
}

void() D1BossMissileHome =
{
	// a voreball with perfect homing causes combat to effectively stop, forcing the player
	// to run around around trying to shake it, often backpedaling through lots of empty map.
	// limiting the voreball's turn rate so they can be dodged and forgotten about makes vores
	// a more flexible enemy and more useful to the mapper
	float rate, dot;
	
	if (self.lifetime_finished < time)
	{
		D1BossMissileExplode();
		return;
	}		
	if (!enemy_alive())
	{
		remove(self);
		return;
	}
	
	self.nextthink = time + SHAL_BALL_THINK_RATE;
	rate = SHAL_BALL_TURN_RATE;
	dot = normalize(self.velocity) * normalize(self.enemy.origin - self.origin);
	
	// reset our owner regularly, or else a voreball that passes through a notrace-invisible
	// player will become owned by the player and remain nonsolid to them after the ring ends
	self.owner = self.trueowner;
	// if the projectile is inside a notrace entity at this time, it'll touch again this frame
	// and reset anyway, so this state will pingpong until it passes out the other side
	
	// 'poor' homing (half turn rate):
	
	if (dot > 0)
	{
		rate *= max(1, 1.3 * (1 - dot));
	}
	self.velocity = D1BOSS_BALL_VEL * ShalTurnToward(self.enemy, rate * 0.7);
	
	
	// go faster at long distance to close the gap, so snipey vores have a better presence
	//dist = vlen(self.enemy.origin - self.origin);
	//dist = saturate( (dist-120) / 512 );
	//self.velocity *= 1 + dist;
	
	self.think = D1BossMissileHome;
	self.oldvelocity = self.velocity;
}

void() D1BossMissile =
{
	entity 	missile;
	vector	dir;

	self.effects = self.effects | EF_MUZZLEFLASH;
	makevectors(self.angles);
	
	dir = (enemy_vispos() + '0 0 10') - self.origin + enemy_aim_vertical();
	dir = normalize(dir);
	
	// if player has strafed around behind, don't lob the missile out of our ass
	if (angledif(self.ideal_yaw, self.angles_y) > 80)
	{
		dir_x = v_forward_x;
		dir_y = v_forward_y;
		dir = normalize(dir);
	}
	
	missile = launch_projectile(self.origin + v_forward * 16 + v_up * crandom()*10 + v_right * crandom()*8, dir * D1BOSS_BALL_VEL, "voreball");

	SUB_ChangeModel (missile, "progs/proj_d1boss.mdl");

	missile.avelocity = '300 300 300';
	missile.nextthink = time + 0.2;
	missile.think = D1BossMissileHome;
	missile.enemy = self.enemy;
	missile.touch = D1BossMissileTouch;
	missile.lifetime_finished = time + 30;	 // blow up after a while

}



//============================================================================================



void() D1BossGrenade =
{
	entity 	missile;

	self.effects = self.effects | EF_MUZZLEFLASH;
	makevectors([70, random() * 360, 0]);
		
	missile = toss_projectile(self.origin + '0 0 80', v_forward * 400 + v_up * 100, "bossgrenade");
	SUB_ChangeModel (missile, "progs/proj_d1boss.mdl");

	missile.avelocity = '300 300 300';
	missile.nextthink = time + 0.2;
	missile.touch = D1BossMissileTouch;
	missile.lifetime_finished = time + 5;	 // blow up after a while

}


void() d1boss_idlesound =
{
	if (self.show_hostile > time) return;

	local float wr;
	wr = random() * 5;

	if (self.wait < time)
	{
	 	self.wait = time + 2;
	 	if (wr > 4.5) 
	 		sound (self, CHAN_VOICE, "shambler/sidle.wav", 1,  ATTN_IDLE);
	}
	return;
}

void(float instant) d1boss_changeheight =
{
	if (self.air_finished < time || instant) {
		self.height = (self.distance * 0.25) + (self.distance * 0.75 * random());
		self.air_finished = time + 3;
	}
}

void()	d1boss_stand1	=[	$stand1,		d1boss_stand2	] {ai_stand();}
void()	d1boss_stand2	=[	$stand2,		d1boss_stand3	] {ai_stand();}
void()	d1boss_stand3	=[	$stand3,		d1boss_stand4	] {ai_stand();}
void()	d1boss_stand4	=[	$stand4,		d1boss_stand5	] {ai_stand();}
void()	d1boss_stand5	=[	$stand5,		d1boss_stand6	] {ai_stand();}
void()	d1boss_stand6	=[	$stand6,		d1boss_stand7	] {ai_stand();}
void()	d1boss_stand7	=[	$stand7,		d1boss_stand8	] {ai_stand();}
void()	d1boss_stand8	=[	$stand8,		d1boss_stand9	] {ai_stand();}
void()	d1boss_stand9	=[	$stand9,		d1boss_stand10	] {ai_stand();}
void()	d1boss_stand10	=[	$stand10,		d1boss_stand11	] {ai_stand();}
void()	d1boss_stand11	=[	$stand11,		d1boss_stand12	] {ai_stand();}
void()	d1boss_stand12	=[	$stand12,		d1boss_stand13	] {ai_stand();}
void()	d1boss_stand13	=[	$stand13,		d1boss_stand14	] {ai_stand();}
void()	d1boss_stand14	=[	$stand14,		d1boss_stand15	] {ai_stand();}
void()	d1boss_stand15	=[	$stand15,		d1boss_stand16	] {ai_stand();}
void()	d1boss_stand16	=[	$stand16,		d1boss_stand17	] {ai_stand();}
void()	d1boss_stand17	=[	$stand17,		d1boss_stand1	] {ai_stand();}


void()	d1boss_walk1	=[	$stand1,		d1boss_walk2	] {ai_walk(8);d1boss_idlesound();}
void()	d1boss_walk2	=[	$stand2,		d1boss_walk3	] {ai_walk(8);}
void()	d1boss_walk3	=[	$stand3,		d1boss_walk4	] {ai_walk(8);}
void()	d1boss_walk4	=[	$stand4,		d1boss_walk5	] {ai_walk(8);}
void()	d1boss_walk5	=[	$stand5,		d1boss_walk6	] {ai_walk(8);}
void()	d1boss_walk6	=[	$stand6,		d1boss_walk7	] {ai_walk(8);}
void()	d1boss_walk7	=[	$stand7,		d1boss_walk8	] {ai_walk(8);}
void()	d1boss_walk8	=[	$stand8,		d1boss_walk9	] {ai_walk(8);}
void()	d1boss_walk9	=[	$stand9,		d1boss_walk10	] {ai_walk(8);}
void()	d1boss_walk10	=[	$stand10,		d1boss_walk11	] {ai_walk(8);}
void()	d1boss_walk11	=[	$stand11,		d1boss_walk12	] {ai_walk(8);}
void()	d1boss_walk12	=[	$stand12,		d1boss_walk13	] {ai_walk(8);}
void()	d1boss_walk13	=[	$stand13,		d1boss_walk14	] {ai_walk(8);}
void()	d1boss_walk14	=[	$stand14,		d1boss_walk15	] {ai_walk(8);}
void()	d1boss_walk15	=[	$stand15,		d1boss_walk16	] {ai_walk(8);}
void()	d1boss_walk16	=[	$stand16,		d1boss_walk17	] {ai_walk(8);}
void()	d1boss_walk17	=[	$stand17,		d1boss_walk1	] {ai_walk(8);}

void()	d1boss_side1	=[	$stand1,		d1boss_side2	] {d1boss_changeheight(FALSE); ai_run(8);d1boss_idlesound();}
void()	d1boss_side2	=[	$stand2,		d1boss_side3	] {d1boss_changeheight(FALSE); ai_run(8);}
void()	d1boss_side3	=[	$stand3,		d1boss_side4	] {d1boss_changeheight(FALSE); ai_run(8);}
void()	d1boss_side4	=[	$stand4,		d1boss_side5	] {d1boss_changeheight(FALSE); ai_run(8);}
void()	d1boss_side5	=[	$stand5,		d1boss_side6	] {d1boss_changeheight(FALSE); ai_run(8);}
void()	d1boss_side6	=[	$stand6,		d1boss_side7	] {d1boss_changeheight(FALSE); ai_run(8);}
void()	d1boss_side7	=[	$stand7,		d1boss_side8	] {d1boss_changeheight(FALSE); ai_run(8);}
void()	d1boss_side8	=[	$stand8,		d1boss_side9	] {d1boss_changeheight(FALSE); ai_run(8);}
void()	d1boss_side9	=[	$stand9,		d1boss_side10	] {d1boss_changeheight(FALSE); ai_run(8);}
void()	d1boss_side10	=[	$stand10,		d1boss_side11	] {d1boss_changeheight(FALSE); ai_run(8);}
void()	d1boss_side11	=[	$stand11,		d1boss_side12	] {d1boss_changeheight(FALSE); ai_run(8);}
void()	d1boss_side12	=[	$stand12,		d1boss_side13	] {d1boss_changeheight(FALSE); ai_run(8);}
void()	d1boss_side13	=[	$stand13,		d1boss_side14	] {d1boss_changeheight(FALSE); ai_run(8);}
void()	d1boss_side14	=[	$stand14,		d1boss_side15	] {d1boss_changeheight(FALSE); ai_run(8);}
void()	d1boss_side15	=[	$stand15,		d1boss_side16	] {d1boss_changeheight(FALSE); ai_run(8);}
void()	d1boss_side16	=[	$stand16,		d1boss_side17	] {d1boss_changeheight(FALSE); ai_run(8);}
void()	d1boss_side17	=[	$stand17,		d1boss_side1	] {d1boss_changeheight(FALSE); ai_run(8);}

void()	d1boss_run1	=[	$stand1,		d1boss_run2	] {self.takedamage = DAMAGE_AIM; d1boss_changeheight(FALSE); ai_run(16);d1boss_idlesound();}
void()	d1boss_run2	=[	$stand2,		d1boss_run3	] {d1boss_changeheight(FALSE); ai_run(16);}
void()	d1boss_run3	=[	$stand3,		d1boss_run4	] {d1boss_changeheight(FALSE); ai_run(16);}
void()	d1boss_run4	=[	$stand4,		d1boss_run5	] {d1boss_changeheight(FALSE); ai_run(16);}
void()	d1boss_run5	=[	$stand5,		d1boss_run6	] {d1boss_changeheight(FALSE); ai_run(16);}
void()	d1boss_run6	=[	$stand6,		d1boss_run7	] {d1boss_changeheight(FALSE); ai_run(16);}
void()	d1boss_run7	=[	$stand7,		d1boss_run8	] {d1boss_changeheight(FALSE); ai_run(16);}
void()	d1boss_run8	=[	$stand8,		d1boss_run9	] {d1boss_changeheight(FALSE); ai_run(16);}
void()	d1boss_run9	=[	$stand9,		d1boss_run10	] {d1boss_changeheight(FALSE); ai_run(16);}
void()	d1boss_run10	=[	$stand10,		d1boss_run11	] {d1boss_changeheight(FALSE); ai_run(16);}
void()	d1boss_run11	=[	$stand11,		d1boss_run12	] {d1boss_changeheight(FALSE); ai_run(16);}
void()	d1boss_run12	=[	$stand12,		d1boss_run13	] {d1boss_changeheight(FALSE); ai_run(16);}
void()	d1boss_run13	=[	$stand13,		d1boss_run14	] {d1boss_changeheight(FALSE); ai_run(16);}
void()	d1boss_run14	=[	$stand14,		d1boss_run15	] {d1boss_changeheight(FALSE); ai_run(16);}
void()	d1boss_run15	=[	$stand15,		d1boss_run16	] {d1boss_changeheight(FALSE); ai_run(16);}
void()	d1boss_run16	=[	$stand16,		d1boss_run17	] {d1boss_changeheight(FALSE); ai_run(16);}
void()	d1boss_run17	=[	$stand17,		d1boss_run1	] {d1boss_changeheight(FALSE); ai_run(16);}

void()	d1boss_fast1	=[	$smash1,		d1boss_fast2	] {d1boss_changeheight(TRUE); ai_run_slide(10);sound (self, CHAN_VOICE, "shambler/melee1.wav", 1, ATTN_NORM);}
void()	d1boss_fast2	=[	$smash2,		d1boss_fast3	] {ai_run_slide(6);}
void()	d1boss_fast3	=[	$smash3,		d1boss_fast4	] {ai_run_slide(6);}
void()	d1boss_fast4	=[	$smash4,		d1boss_fast5	] {ai_run_slide(6);}
void()	d1boss_fast5	=[	$smash5,		d1boss_fast6	] {ai_run_slide(5);}
void()	d1boss_fast6	=[	$smash6,		d1boss_fast7	] {ai_run_slide(5);}
void()	d1boss_fast7	=[	$smash7,		d1boss_fast8	] {ai_run_slide(4);}
void()	d1boss_fast8	=[	$smash8,		d1boss_fast9	] {ai_run_slide(3);}
void()	d1boss_fast9	=[	$smash9,		d1boss_fast10	] {ai_run_slide(12);}
void()	d1boss_fast10	=[	$smash10,		d1boss_fast11	] {ai_run_slide(20);D1BossMissile();}
void()	d1boss_fast11	=[	$smash10,		d1boss_fast12	] {ai_run_slide(20);D1BossMissile();}
void()	d1boss_fast12	=[	$smash10,		d1boss_fast13	] {ai_run_slide(20);D1BossMissile();}
void()	d1boss_fast13	=[	$smash10,		d1boss_fast14	] {ai_run_slide(20);D1BossMissile();}
void()	d1boss_fast14	=[	$smash10,		d1boss_fast15	] {ai_run_slide(20);D1BossMissile();}
void()	d1boss_fast15	=[	$smash10,		d1boss_fast16	] {ai_run_slide(20);D1BossMissile();}
void()	d1boss_fast16	=[	$smash10,		d1boss_fast17	] {ai_run_slide(20);D1BossMissile();}
void()	d1boss_fast17	=[	$smash11,		d1boss_fast18	] {ai_run_slide(20);D1BossMissile();}
void()	d1boss_fast18	=[	$smash12,		d1boss_run1	] {ai_run_slide(20); ai_attack_finished(6);}

void()	d1boss_hands1	=[	$smash1,		d1boss_hands2	] {d1boss_changeheight(TRUE);ai_run_slide(10);sound (self, CHAN_VOICE, "shambler/melee1.wav", 1, ATTN_NORM);}
void()	d1boss_hands2	=[	$smash2,		d1boss_hands3	] {ai_run_slide(6);}
void()	d1boss_hands3	=[	$smash3,		d1boss_hands4	] {ai_run_slide(6);}
void()	d1boss_hands4	=[	$smash4,		d1boss_hands5	] {ai_run_slide(6);}
void()	d1boss_hands5	=[	$smash5,		d1boss_hands6	] {ai_run_slide(5);}
void()	d1boss_hands6	=[	$smash6,		d1boss_hands7	] {ai_run_slide(5);}
void()	d1boss_hands7	=[	$smash7,		d1boss_hands8	] {ai_run_slide(4);}
void()	d1boss_hands8	=[	$smash8,		d1boss_hands9	] {ai_run_slide(3);}
void()	d1boss_hands9	=[	$smash9,		d1boss_hands10	] {ai_run_slide(12);}
void()	d1boss_hands10	=[	$smash10,		d1boss_hands11	] {ai_run_slide(20);D1BossMissile();}
void()	d1boss_hands11	=[	$smash10,		d1boss_hands12	] {ai_run_slide(20);D1BossMissile();}
void()	d1boss_hands12	=[	$smash10,		d1boss_hands13	] {ai_run_slide(20);D1BossMissile();}
void()	d1boss_hands13	=[	$smash10,		d1boss_hands14	] {ai_run_slide(20);D1BossMissile();}
void()	d1boss_hands14	=[	$smash10,		d1boss_hands15	] {ai_run_slide(20);D1BossMissile();}
void()	d1boss_hands15	=[	$smash10,		d1boss_hands16	] {ai_run_slide(20);D1BossMissile();}
void()	d1boss_hands16	=[	$smash10,		d1boss_hands17	] {ai_run_slide(20);D1BossMissile();}
void()	d1boss_hands17	=[	$smash11,		d1boss_hands18	] {ai_run_slide(20);D1BossMissile();}
void()	d1boss_hands18	=[	$smash12,		d1boss_run1	] {ai_run_slide(20); ai_attack_finished(6);}

void()	d1boss_melee1	=[	$smash1,		d1boss_melee2	] {sound (self, CHAN_VOICE, "shambler/melee1.wav", 1, ATTN_NORM);}
void()	d1boss_melee2	=[	$smash2,		d1boss_melee3	] {D1BossGrenade();}
void()	d1boss_melee3	=[	$smash3,		d1boss_melee4	] {}
void()	d1boss_melee4	=[	$smash4,		d1boss_melee5	] {D1BossGrenade();}
void()	d1boss_melee5	=[	$smash5,		d1boss_melee6	] {}
void()	d1boss_melee6	=[	$smash6,		d1boss_melee7	] {D1BossGrenade();}
void()	d1boss_melee7	=[	$smash7,		d1boss_melee8	] {}
void()	d1boss_melee8	=[	$smash8,		d1boss_melee9	] {D1BossGrenade();}
void()	d1boss_melee9	=[	$smash9,		d1boss_melee10	] {}
void()	d1boss_melee10	=[	$smash10,		d1boss_melee11	] {D1BossGrenade();}
void()	d1boss_melee11	=[	$smash10,		d1boss_melee12	] {}
void()	d1boss_melee12	=[	$smash10,		d1boss_melee13	] {D1BossGrenade();}
void()	d1boss_melee13	=[	$smash10,		d1boss_melee14	] {}
void()	d1boss_melee14	=[	$smash10,		d1boss_melee15	] {D1BossGrenade();}
void()	d1boss_melee15	=[	$smash10,		d1boss_melee16	] {}
void()	d1boss_melee16	=[	$smash10,		d1boss_melee17	] {D1BossGrenade();}
void()	d1boss_melee17	=[	$smash11,		d1boss_melee18	] {}
void()	d1boss_melee18	=[	$smash12,		d1boss_run1	] {ai_attack_finished(6);}


void()	d1boss_pain1	=[	$pain1,		d1boss_pain2	] {ai_nop();PainFinished(4);}
void()	d1boss_pain2	=[	$pain2,		d1boss_pain3	] {ai_nop();}
void()	d1boss_pain3	=[	$pain3,		d1boss_pain4	] {ai_nop();}
void()	d1boss_pain4	=[	$pain4,		d1boss_run1	] {ai_nop();}


void() d1boss_swingl1	=[      $swingl1,      d1boss_swingl2   ] {
	sound (self, CHAN_VOICE, "shambler/melee2.wav", 1, ATTN_NORM);
	ai_nop();
}
void() d1boss_swingl2 =[      $swingl2,      d1boss_swingl3   ] {ai_nop();}
void() d1boss_swingl3 =[      $swingl3,      d1boss_swingl4   ] {ai_nop();}
void() d1boss_swingl4 =[      $swingl4,      d1boss_swingl5   ] {ai_nop();}
void() d1boss_swingl5 =[      $swingl5,      d1boss_swingl6   ] {ai_face();}
void() d1boss_swingl6 =[      $swingl6,      d1boss_swingl7   ] {ai_face();}
void() d1boss_swingl7 =[      $swingl7,      d1boss_swingl8   ] {ai_face(); D1BossMissile();}
void() d1boss_swingl8 =[      $swingl8,      d1boss_swingl9   ] {ai_nop();}
void() d1boss_swingl9 =[      $swingl9,      d1boss_run1  ] {ai_nop();d1boss_swingr1();}

void() d1boss_swingr1	=[      $swingr1,      d1boss_swingr2   ] {
	sound (self, CHAN_VOICE, "shambler/melee1.wav", 1, ATTN_NORM);
	ai_nop();
}
void() d1boss_swingr2 =[      $swingr2,      d1boss_swingr3   ] {ai_nop();}
void() d1boss_swingr3 =[      $swingr3,      d1boss_swingr4   ] {ai_nop();}
void() d1boss_swingr4 =[      $swingr4,      d1boss_swingr5   ] {ai_nop();}
void() d1boss_swingr5 =[      $swingr5,      d1boss_swingr6   ] {ai_face();}
void() d1boss_swingr6 =[      $swingr6,      d1boss_swingr7   ] {ai_face();}
void() d1boss_swingr7 =[      $swingr7,      d1boss_swingr8   ] {ai_face(); D1BossMissile();}
void() d1boss_swingr8 =[      $swingr8,      d1boss_swingr9   ] {ai_nop();}
void() d1boss_swingr9 =[      $swingr9,      d1boss_run1  ] {ai_nop();}


void() d1boss_sleep_frame =
{
	self.frame = $stand1;

	if (self.attack_finished < time) {
		self.velocity = '0 0 0';
		self.avelocity = '0 0 0';
	}

	self.think = d1boss_sleep_frame;
	self.nextthink = time + 0.1;
};

void() d1boss_startsleep =
{
	entity dest;
	vector vdestdelta;
	float traveltime, len;
	float yawdelta;

	self.takedamage = DAMAGE_NO;
	self.health = D1BOSS_HEALTH;
	self.enemy = self.goalentity = world;
	dest = find(world, targetname, self.include);
	

	vdestdelta = dest.origin - self.origin;
	len = vlen (vdestdelta);
	traveltime = len / 150;
	self.velocity = vdestdelta * (1/traveltime);
	self.attack_finished = time + traveltime;

	yawdelta = dest.angles_y - self.angles_y;
	self.avelocity_y = yawdelta/traveltime;


	d1boss_sleep_frame();
}

float() d1boss_checkdeath =
{
	if (self.state) {
		d1boss_startsleep();
		
		if (self.state == 3) {
			SUB_UseTargetsByField(target);
			self.target = "";
		}
		else if (self.state == 2) {
			SUB_UseTargetsByField(target2);
			self.target2 = "";
		}
		else if (self.state == 1) {
			SUB_UseTargetsByField(target3);
			self.target3 = "";
		}
		self.state--;
		return TRUE;
	}
	else {
		SUB_UseTargetsByField(target4);
		self.target4 = "";
		return FALSE;
	}

}

void()	d1boss_death1	=[	$death1,		d1boss_death2	] {
	self.velocity_x = -200 + 400*random();
	self.velocity_y = -200 + 400*random();
	self.velocity_z = 100 + 100*random();
	self.flags = not(self.flags, FL_ONGROUND);
	sound (self, CHAN_VOICE, "shambler/sdeath.wav", 1, ATTN_NORM);
}
void()	d1boss_death2	=[	$death2,		d1boss_death3	] {}
void()	d1boss_death3	=[	$death3,		d1boss_death4	] {}
void()	d1boss_death4	=[	$death4,		d1boss_death5	] {}
void()	d1boss_death5	=[	$death5,		d1boss_death6	] {self.solid = SOLID_NOT; self.flags = not(self.flags, FL_ONGROUND);}
void()	d1boss_death6	=[	$death6,		d1boss_death7	] {}
void()	d1boss_death7	=[	$death7,		d1boss_death8	] {}
void()	d1boss_death8	=[	$death8,		d1boss_death9	] {}
void()	d1boss_death9	=[	$death9,		d1boss_death10	] {}
void()	d1boss_death10	=[	$death10,		d1boss_death11	] {}
void()	d1boss_death11	=[	$death11,		d1boss_death11	] {PostDeathLogic();}

void() d1boss_die =
{
// check for gib
	if (self.health < -60)
	{
		Gib ("progs/h_shams.mdl", self.health);
		return;
	}

	d1boss_death1 ();
}


void(entity attacker, float damage) d1boss_Pain =
{
	sound (self, CHAN_VOICE, "shambler/shurt2.wav", 1, ATTN_NORM);

	if (self.health <= 0) return;	
	if (self.pain_finished > time) return;
	if (random()*400 > damage) return;		// didn't flinch

	PainFinished(2);
	d1boss_pain1 ();
}

void() d1boss_chooseattack =
{

	if (random() > 0.5)
		d1boss_fast1();
	else
		d1boss_swingl1();

}



void() monster_d1boss_spawn =
{
	self.classname = "monster_d1boss";
		
	self.solid = SOLID_SLIDEBOX;
	//self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/shambler.mdl");

	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);

	self.health = D1BOSS_HEALTH;
	self.distance = self.height = 192;
	//self.customflags = self.customflags | CFL_CHECKDEATH;

	self.state = 3;
	
	self.th_stand = d1boss_stand1;
	self.th_walk = d1boss_walk1;
	self.th_run = d1boss_run1;
	self.th_missile = d1boss_chooseattack;
	self.th_melee = d1boss_melee1;
	self.th_pain = d1boss_Pain;
	self.th_die = d1boss_die;
	self.th_checkattack = D1BossCheckAttack;
	self.th_checkdeath = d1boss_checkdeath;

	if (self.deathtype == string_null)
		self.deathtype = "was scragged by a Scrag";

	flymonster_start ();
}

void() monster_d1boss_spawner = {mon_spawner_use(monster_d1boss_spawn);}

/*QUAKED monster_wizard (1 0 0) (-16 -16 -24) (16 16 40) AMBUSH ? ? ? TRIGGERED NOTFOG NOTELEFRAG INSTAWAKE
Scrag (the WIZARD), 80 health points.

Flags:
"ambush" only wake up on seeing the player, not another monster getting angry

"Triggered"	will not spawn until triggered - triggering again will wake him up. Set 'count' to make this a multi-use spawner.
"NoTfog" 	supress teleport glitter when spawned with 'triggered'
"NoTelefrag" will silently fail to spawn if doing so would telefrag an existing monster. will try again automatically 2x/second until it succeeds.
"Instawake" spawn angry at activator

Keys:
"target" entity to trigger when killed
"targetname" entity name
*/
/*FGD
@PointClass base(Monster) size(-16 -16 -24, 16 16 40) model({ "path": ":progs/wizard.mdl" }) = monster_wizard : "Scrag" []
*/
void() monster_d1boss =
{
	if (!SUB_ShouldSpawn()) return;
	if (nomonster()) return;
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/shambler.mdl");
	precache_model ("progs/h_shams.mdl");
	precache_model ("progs/proj_d1boss.mdl");

	precache_sound ("wizard/hit.wav");		// used by c code
	precache_sound ("wizard/wattack.wav");
	precache_sound ("wizard/wdeath.wav");
	precache_sound ("wizard/widle1.wav");
	precache_sound ("wizard/widle2.wav");
	precache_sound ("wizard/wpain.wav");
	precache_sound ("wizard/wsight.wav");


	precache_sound ("shambler/sattck1.wav");
	precache_sound ("shambler/sboom.wav");
	precache_sound ("shambler/sdeath.wav");
	precache_sound ("shambler/shurt2.wav");
	precache_sound ("shambler/sidle.wav");
	precache_sound ("shambler/ssight.wav");
	precache_sound ("shambler/melee1.wav");
	precache_sound ("shambler/melee2.wav");
	precache_sound ("shambler/smack.wav");


	self.health = D1BOSS_HEALTH;
	//setsize (self, '-16 -16 -24', '16 16 40');
	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	if ( monster_spawnsetup( monster_d1boss_spawner ) ) return;
	
	addmonster(1);
	monster_d1boss_spawn();
}




