/*
==============================================================================

WIZARD

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


float() Boss2CheckAttack = {
	//----------------------------------------------------------------------
	// Check Melee range and constantly fire
	//----------------------------------------------------------------------
	if (enemy_range < RANGE_MELEE) {
		self.attack_state = AS_MISSILE; //AS_MELEE;
		return TRUE;
	}
	
	//----------------------------------------------------------------------
	// Range attacks (Spit and Bomb)
	// Attack_chance override (percentage 0-1 chance)
	//----------------------------------------------------------------------
	// Only range attack if cooldown has finished
	if (time > self.attack_finished) {
		// Fast/intense nail/spit attack
		if (enemy_range < RANGE_NEAR) { // || self.attack_chance > random()) {
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
void()	Boss2AttackFinished =
{
	if (enemy_range >= RANGE_MID || !enemy_vis)
	{
		self.attack_state = AS_STRAIGHT;
		self.think = boss2_run1;
	}
	else
	{
		self.attack_state = AS_SLIDING;
		self.think = boss2_side1;
	}
}

/*
==============================================================================

FAST ATTACKS

==============================================================================
*/

void() Boss2MissileHome =
{
	// a voreball with perfect homing causes combat to effectively stop, forcing the player
	// to run around around trying to shake it, often backpedaling through lots of empty map.
	// limiting the voreball's turn rate so they can be dodged and forgotten about makes vores
	// a more flexible enemy and more useful to the mapper
	float dist, rate, dot;
	
	if (self.lifetime_finished < time)
	{
		ShalMissileExplode();
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
		rate *= max(1, 1.5 * (1 - dot));
	}
	self.velocity = SHAL_BALL_VEL * ShalTurnToward(self.enemy, rate * 0.7);
	
	
	// go faster at long distance to close the gap, so snipey vores have a better presence
	dist = vlen(self.enemy.origin - self.origin);
	dist = saturate( (dist-120) / 512 );
	self.velocity *= 1 + dist;
	
	self.think = Boss2MissileHome;
	self.oldvelocity = self.velocity;
}



void() Boss2Missile =
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
	
	missile = launch_projectile(self.origin + v_forward * 16 + v_up * crandom()*10 + v_right * crandom()*8, dir * SHAL_BALL_VEL, "voreball");

	SUB_ChangeModel (missile, "progs/v_spike.mdl");

	missile.avelocity = '300 300 300';
	missile.nextthink = time + 0.1;
	missile.think = Boss2MissileHome;
	missile.enemy = self.enemy;
	missile.touch = ShalMissileTouch;
	missile.lifetime_finished = time + 30;	 // blow up after a while

}



void() boss2_idlesound =
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

void(float instant) boss2_changeheight =
{
	if (self.air_finished < time || instant) {
		self.height = (self.distance * 0.25) + (self.distance * 0.75 * random());
		self.air_finished = time + 3;
	}
}

void()	boss2_stand1	=[	$stand1,		boss2_stand2	] {ai_stand();}
void()	boss2_stand2	=[	$stand2,		boss2_stand3	] {ai_stand();}
void()	boss2_stand3	=[	$stand3,		boss2_stand4	] {ai_stand();}
void()	boss2_stand4	=[	$stand4,		boss2_stand5	] {ai_stand();}
void()	boss2_stand5	=[	$stand5,		boss2_stand6	] {ai_stand();}
void()	boss2_stand6	=[	$stand6,		boss2_stand7	] {ai_stand();}
void()	boss2_stand7	=[	$stand7,		boss2_stand8	] {ai_stand();}
void()	boss2_stand8	=[	$stand8,		boss2_stand9	] {ai_stand();}
void()	boss2_stand9	=[	$stand9,		boss2_stand10	] {ai_stand();}
void()	boss2_stand10	=[	$stand10,		boss2_stand11	] {ai_stand();}
void()	boss2_stand11	=[	$stand11,		boss2_stand12	] {ai_stand();}
void()	boss2_stand12	=[	$stand12,		boss2_stand13	] {ai_stand();}
void()	boss2_stand13	=[	$stand13,		boss2_stand14	] {ai_stand();}
void()	boss2_stand14	=[	$stand14,		boss2_stand15	] {ai_stand();}
void()	boss2_stand15	=[	$stand15,		boss2_stand16	] {ai_stand();}
void()	boss2_stand16	=[	$stand16,		boss2_stand17	] {ai_stand();}
void()	boss2_stand17	=[	$stand17,		boss2_stand1	] {ai_stand();}


void()	boss2_walk1	=[	$stand1,		boss2_walk2	] {ai_walk(8);boss2_idlesound();}
void()	boss2_walk2	=[	$stand2,		boss2_walk3	] {ai_walk(8);}
void()	boss2_walk3	=[	$stand3,		boss2_walk4	] {ai_walk(8);}
void()	boss2_walk4	=[	$stand4,		boss2_walk5	] {ai_walk(8);}
void()	boss2_walk5	=[	$stand5,		boss2_walk6	] {ai_walk(8);}
void()	boss2_walk6	=[	$stand6,		boss2_walk7	] {ai_walk(8);}
void()	boss2_walk7	=[	$stand7,		boss2_walk8	] {ai_walk(8);}
void()	boss2_walk8	=[	$stand8,		boss2_walk9	] {ai_walk(8);}
void()	boss2_walk9	=[	$stand9,		boss2_walk10	] {ai_walk(8);}
void()	boss2_walk10	=[	$stand10,		boss2_walk11	] {ai_walk(8);}
void()	boss2_walk11	=[	$stand11,		boss2_walk12	] {ai_walk(8);}
void()	boss2_walk12	=[	$stand12,		boss2_walk13	] {ai_walk(8);}
void()	boss2_walk13	=[	$stand13,		boss2_walk14	] {ai_walk(8);}
void()	boss2_walk14	=[	$stand14,		boss2_walk15	] {ai_walk(8);}
void()	boss2_walk15	=[	$stand15,		boss2_walk16	] {ai_walk(8);}
void()	boss2_walk16	=[	$stand16,		boss2_walk17	] {ai_walk(8);}
void()	boss2_walk17	=[	$stand17,		boss2_walk1	] {ai_walk(8);}

void()	boss2_side1	=[	$stand1,		boss2_side2	] {boss2_changeheight(FALSE); ai_run(8);boss2_idlesound();}
void()	boss2_side2	=[	$stand2,		boss2_side3	] {boss2_changeheight(FALSE); ai_run(8);}
void()	boss2_side3	=[	$stand3,		boss2_side4	] {boss2_changeheight(FALSE); ai_run(8);}
void()	boss2_side4	=[	$stand4,		boss2_side5	] {boss2_changeheight(FALSE); ai_run(8);}
void()	boss2_side5	=[	$stand5,		boss2_side6	] {boss2_changeheight(FALSE); ai_run(8);}
void()	boss2_side6	=[	$stand6,		boss2_side7	] {boss2_changeheight(FALSE); ai_run(8);}
void()	boss2_side7	=[	$stand7,		boss2_side8	] {boss2_changeheight(FALSE); ai_run(8);}
void()	boss2_side8	=[	$stand8,		boss2_side9	] {boss2_changeheight(FALSE); ai_run(8);}
void()	boss2_side9	=[	$stand9,		boss2_side10	] {boss2_changeheight(FALSE); ai_run(8);}
void()	boss2_side10	=[	$stand10,		boss2_side11	] {boss2_changeheight(FALSE); ai_run(8);}
void()	boss2_side11	=[	$stand11,		boss2_side12	] {boss2_changeheight(FALSE); ai_run(8);}
void()	boss2_side12	=[	$stand12,		boss2_side13	] {boss2_changeheight(FALSE); ai_run(8);}
void()	boss2_side13	=[	$stand13,		boss2_side14	] {boss2_changeheight(FALSE); ai_run(8);}
void()	boss2_side14	=[	$stand14,		boss2_side15	] {boss2_changeheight(FALSE); ai_run(8);}
void()	boss2_side15	=[	$stand15,		boss2_side16	] {boss2_changeheight(FALSE); ai_run(8);}
void()	boss2_side16	=[	$stand16,		boss2_side17	] {boss2_changeheight(FALSE); ai_run(8);}
void()	boss2_side17	=[	$stand17,		boss2_side1	] {boss2_changeheight(FALSE); ai_run(8);}

void()	boss2_run1	=[	$stand1,		boss2_run2	] {boss2_changeheight(FALSE); ai_run(16);boss2_idlesound();}
void()	boss2_run2	=[	$stand2,		boss2_run3	] {boss2_changeheight(FALSE); ai_run(16);}
void()	boss2_run3	=[	$stand3,		boss2_run4	] {boss2_changeheight(FALSE); ai_run(16);}
void()	boss2_run4	=[	$stand4,		boss2_run5	] {boss2_changeheight(FALSE); ai_run(16);}
void()	boss2_run5	=[	$stand5,		boss2_run6	] {boss2_changeheight(FALSE); ai_run(16);}
void()	boss2_run6	=[	$stand6,		boss2_run7	] {boss2_changeheight(FALSE); ai_run(16);}
void()	boss2_run7	=[	$stand7,		boss2_run8	] {boss2_changeheight(FALSE); ai_run(16);}
void()	boss2_run8	=[	$stand8,		boss2_run9	] {boss2_changeheight(FALSE); ai_run(16);}
void()	boss2_run9	=[	$stand9,		boss2_run10	] {boss2_changeheight(FALSE); ai_run(16);}
void()	boss2_run10	=[	$stand10,		boss2_run11	] {boss2_changeheight(FALSE); ai_run(16);}
void()	boss2_run11	=[	$stand11,		boss2_run12	] {boss2_changeheight(FALSE); ai_run(16);}
void()	boss2_run12	=[	$stand12,		boss2_run13	] {boss2_changeheight(FALSE); ai_run(16);}
void()	boss2_run13	=[	$stand13,		boss2_run14	] {boss2_changeheight(FALSE); ai_run(16);}
void()	boss2_run14	=[	$stand14,		boss2_run15	] {boss2_changeheight(FALSE); ai_run(16);}
void()	boss2_run15	=[	$stand15,		boss2_run16	] {boss2_changeheight(FALSE); ai_run(16);}
void()	boss2_run16	=[	$stand16,		boss2_run17	] {boss2_changeheight(FALSE); ai_run(16);}
void()	boss2_run17	=[	$stand17,		boss2_run1	] {boss2_changeheight(FALSE); ai_run(16);}

void()	boss2_fast1	=[	$smash1,		boss2_fast2	] {boss2_changeheight(TRUE);ai_run_slide(10);sound (self, CHAN_VOICE, "shambler/melee1.wav", 1, ATTN_NORM);}
void()	boss2_fast2	=[	$smash2,		boss2_fast3	] {ai_run_slide(6);}
void()	boss2_fast3	=[	$smash3,		boss2_fast4	] {ai_run_slide(6);}
void()	boss2_fast4	=[	$smash4,		boss2_fast5	] {ai_run_slide(6);}
void()	boss2_fast5	=[	$smash5,		boss2_fast6	] {ai_run_slide(5);}
void()	boss2_fast6	=[	$smash6,		boss2_fast7	] {ai_run_slide(5);}
void()	boss2_fast7	=[	$smash7,		boss2_fast8	] {ai_run_slide(4);}
void()	boss2_fast8	=[	$smash8,		boss2_fast9	] {ai_run_slide(3);}
void()	boss2_fast9	=[	$smash9,		boss2_fast10	] {ai_run_slide(12);}
void()	boss2_fast10	=[	$smash10,		boss2_fast11	] {ai_run_slide(20);Boss2Missile();}
void()	boss2_fast11	=[	$smash10,		boss2_fast12	] {ai_run_slide(20);}
void()	boss2_fast12	=[	$smash10,		boss2_fast13	] {ai_run_slide(20);Boss2Missile();}
void()	boss2_fast13	=[	$smash10,		boss2_fast14	] {ai_run_slide(20);}
void()	boss2_fast14	=[	$smash10,		boss2_fast15	] {ai_run_slide(20);Boss2Missile();}
void()	boss2_fast15	=[	$smash10,		boss2_fast16	] {ai_run_slide(20);}
void()	boss2_fast16	=[	$smash10,		boss2_fast17	] {ai_run_slide(20);Boss2Missile();}
void()	boss2_fast17	=[	$smash11,		boss2_fast18	] {ai_run_slide(20);}
void()	boss2_fast18	=[	$smash12,		boss2_run1	] {ai_run_slide(20); ai_attack_finished(6);}

void()	boss2_pain1	=[	$pain1,		boss2_pain2	] {ai_nop();PainFinished(4);}
void()	boss2_pain2	=[	$pain2,		boss2_pain3	] {ai_nop();}
void()	boss2_pain3	=[	$pain3,		boss2_pain4	] {ai_nop();}
void()	boss2_pain4	=[	$pain4,		boss2_run1	] {ai_nop();}

void()	boss2_death1	=[	$death1,		boss2_death2	] {
	self.velocity_x = -200 + 400*random();
	self.velocity_y = -200 + 400*random();
	self.velocity_z = 100 + 100*random();
	self.flags = not(self.flags, FL_ONGROUND);
	sound (self, CHAN_VOICE, "shambler/sdeath.wav", 1, ATTN_NORM);
}
void()	boss2_death2	=[	$death2,		boss2_death3	] {}
void()	boss2_death3	=[	$death3,		boss2_death4	] {}
void()	boss2_death4	=[	$death4,		boss2_death5	] {}
void()	boss2_death5	=[	$death5,		boss2_death6	] {self.solid = SOLID_NOT; self.flags = not(self.flags, FL_ONGROUND);}
void()	boss2_death6	=[	$death6,		boss2_death7	] {}
void()	boss2_death7	=[	$death7,		boss2_death8	] {}
void()	boss2_death8	=[	$death8,		boss2_death9	] {}
void()	boss2_death9	=[	$death9,		boss2_death10	] {}
void()	boss2_death10	=[	$death10,		boss2_death11	] {}
void()	boss2_death11	=[	$death11,		boss2_death11	] {PostDeathLogic();}

void() boss2_die =
{
// check for gib
	if (self.health < -60)
	{
		Gib ("progs/h_shams.mdl", self.health);
		return;
	}

	boss2_death1 ();
}


void(entity attacker, float damage) boss2_Pain =
{
	sound (self, CHAN_VOICE, "shambler/shurt2.wav", 1, ATTN_NORM);

	if (self.health <= 0) return;	
	if (self.pain_finished > time) return;
	if (random()*400 > damage) return;		// didn't flinch

	PainFinished(2);
	boss2_pain1 ();
}


void() monster_boss2_spawn =
{
	self.classname = "monster_boss2";
		
	self.solid = SOLID_SLIDEBOX;
	//self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/shambler.mdl");

	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	self.health = 600;
	self.distance = self.height = 192;

	self.th_stand = boss2_stand1;
	self.th_walk = boss2_walk1;
	self.th_run = boss2_run1;
	self.th_missile = boss2_fast1;
	self.th_pain = boss2_Pain;
	self.th_die = boss2_die;
	self.th_checkattack = Boss2CheckAttack;

	if (self.deathtype == string_null)
		self.deathtype = "was scragged by a Scrag";

	flymonster_start ();
}

void() monster_boss2_spawner = {mon_spawner_use(monster_boss2_spawn);}

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
void() monster_boss2 =
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
	precache_model ("progs/v_spike.mdl");

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

	self.health = 80;
	//setsize (self, '-16 -16 -24', '16 16 40');
	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	if ( monster_spawnsetup( monster_boss2_spawner ) ) return;
	
	addmonster(1);
	monster_boss2_spawn();
}




