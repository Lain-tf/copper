/*
==============================================================================

Ep. 2 Boss

CODE STRUCTURE

This is a huge fucking complex thing. The boss entity itself (which we'll refer as the main entity)
doesn't have any collision, instead it has 94 small bboxes that follow the overall model shape and
translate/rotate with it.

I've abandoned the idea of making it an actual monster, because we won't be using any AI function
in it, so everything must be handled here - like kill counter, firing targets on death, turning to
non-solid etc.

The main entity has 2 controllers attached:

- Thinker (stored on the .buddy field): General think loop. Since the main entity's think functions
  are reserved to movement, every other logic is handled here. It decides when it'll fire a volley
  at the player, when it'll go to the center to fire a bullet hell, and also keeps the entity
  turned to the player on phase 2.
  The collision bboxes are attached to the thinker's .buddy field in a linked list (each one's
  .buddy points to the next), and this entity also updates their origin relative to the main
  entity's origin/angles through some sick maths.

- Pain controller (stored on the .trigger_field field): Controls the damage received on the
  individual bboxes and applies them to the main entity. Necessary because it has to manage
  multi-damage from T_RadiusDamage explosions.

All of the attached entities, including each bbox segment, point back to the main entity through
their .owner field.

All the functions whose names don't with "think" assume that "self" points to the main entity.

HOW TO USE IT

The boss entity moves on path_corners. The .target field must point to the first path_corner in the
room, from which it'll begin its loop. .target2 points to another path_corner at the center of the
room, where it'll move to initiate the bullet hell sequence.

At every few seconds, the boss will fire a project volley at the player. Randomly, it may instead
initiate the bullet hell sequence: it moves to the central path_corner at the center of the room
(pointed by its .target2 field), and that central path_corner will fire its targets. Here, you must
set up relays to manage the whole sequence - show up beams, shake the screen, etc - as well as fire
the target_bullethell entity. While all this happens, the boss entity will sit there waiting, and
will only resume its path after triggered again, so you must include that into the relay sequence
as well.

At the first phase, the boss will have the initial "closed" model, and will always be facing down.
When given enough damage, it'll fire .target3 and turn to phase 2. Then, its model will be changed
to the eye one, and will be constantly facing the player.

When it dies completely, .target4 gets fired.

==============================================================================
*/

float D2BOSS_BALL_VEL = 750;

.float	track_finished;


void() d2bossMissileExplode =
{
	local float skill_damage;
	
	if ( skill > 1 || coop )
		skill_damage = 55;
	else if ( skill == 1)
		skill_damage = 35;
	else 
		skill_damage = 25;
	
	T_RadiusDamage (self, self.trueowner, skill_damage, world);
	sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);

	BecomeExplosion();
};


void() d2bossMissileTouch =
{
	if ( CheckProjectilePassthru() ) 
		return;
	
	if ( other == self.owner || other.owner == self.owner)
		return;		// don't explode on owner

	if (other.type == "zombie")
		T_Damage (other, self, self.trueowner, other.health + 25);
	
	d2bossMissileExplode();
};


void() d2bossMissileHome =
{
	float rate, dot;
	
	if ( self.lifetime_finished < time )
	{
		d2bossMissileExplode();
		return;
	}
	
	if ( !enemy_alive() )
	{
		remove(self);
		return;
	}
	
	if ( self.track_finished < time )
		return;
		
	self.nextthink = time + SHAL_BALL_THINK_RATE;
	rate = SHAL_BALL_TURN_RATE;
	dot = normalize( self.velocity ) * normalize( self.enemy.origin - self.origin );
	self.owner = self.trueowner;

	if ( dot > 0 )
		rate *= max(1, 1.3 * (1 - dot));
	
	self.velocity = D2BOSS_BALL_VEL * ShalTurnToward( self.enemy, rate * 0.7 ); // 0.7
	self.think = d2bossMissileHome;
	self.oldvelocity = self.velocity;
};


vector(vector source, entity tgt, float misvel, float degree) d2boss_leadtarget =
{
	local vector vel, lead_offset, evel;
	
	vel = tgt.origin - source;
	// don't lead if you can't see the target
	if (has_invis(tgt))
		return vel;
	
	evel = tgt.velocity;
	if( !(tgt.flags & FL_ONGROUND) && fabs(evel_z) < 275 )
		evel_z = 0;	// ignore if the player is jumping around
	
	lead_offset = (vlen(vel) / misvel) * evel * degree;
	return vel + lead_offset;
}

void() d2bossMissile =
{
	entity missile;
	vector dir;
	vector bossorg,playerorg;
	float distcheck;
	
	entity tgt = checkclient();

	
	//self.effects = self.effects | EF_MUZZLEFLASH;
	makevectors([-self.angles_x, self.angles_y, self.angles_z]);
	
	dir = d2boss_leadtarget( self.origin, tgt, D2BOSS_BALL_VEL, random() );
	dir = normalize( dir );
	 
	bossorg = self.origin;
	bossorg_z = 0;
	playerorg = self.enemy.origin;
	playerorg_z = 0;
	distcheck = vlen(bossorg - playerorg);
	
	
	missile = launch_projectile( self.origin + (v_forward * 128), dir * D2BOSS_BALL_VEL, "voreball" );
	//missile = launch_projectile( self.origin + v_forward * 16 + v_up * crandom()*10 + v_right * crandom()*8 + '0 0 72', dir * D2BOSS_BALL_VEL, "voreball" );
	
	SUB_ChangeModel (missile, "progs/proj_d1boss.mdl");

	missile.avelocity = '300 300 300';
	missile.nextthink = time + distcheck;//0.35; // 0.2
	missile.think = d2bossMissileHome;
	missile.enemy = tgt;
	missile.touch = d2bossMissileTouch;
	missile.lifetime_finished = time + 5;	 // blow up after a while
	missile.track_finished = time + 1.25; // 1.25
	sound (self, CHAN_WEAPON, "d1boss/proj.wav", 1, ATTN_NORM);
};


void() d2boss_idlesound =
{
	if (self.show_hostile > time) 
		return;

	local float wr;
	
	wr = random() * 5;

	if ( self.wait < time )
	{
	 	self.wait = time + 2;
		
	 	if ( wr > 4.5 ) 
	 		sound (self, CHAN_VOICE, "d1boss/idle.wav", 1,  ATTN_IDLE);
	}
	
	return;
};


// leftover code from d1boss, change it to something better
void() d2boss_death22 =[ 7, d2boss_death23 ] { ThrowGibBoss ("progs/gib1.mdl", 100 + random() * 50); }
void() d2boss_death23 =[ 7, d2boss_death24 ] { ThrowGibBoss ("progs/gib2.mdl", 100 + random() * 50); }
void() d2boss_death24 =[ 7, d2boss_death25 ] { ThrowGibBoss ("progs/gib3.mdl", 100 + random() * 50);	ThrowGibBoss ("progs/gib2.mdl", 100 + random() * 50); }
void() d2boss_death25 =[ 7, d2boss_death26 ] { ThrowGibBoss ("progs/gib2.mdl", 100 + random() * 50);	ThrowGibBoss ("progs/gib3.mdl", 100 + random() * 50); }
void() d2boss_death26 =[ 7, d2boss_death27 ] { ThrowGibBoss ("progs/gib2.mdl", 100 + random() * 50);	ThrowGibBoss ("progs/gib2.mdl", 100 + random() * 50); }
void() d2boss_death27 =[ 7, d2boss_death28 ] { ThrowGibBoss ("progs/gib3.mdl", 100 + random() * 50);	ThrowGibBoss ("progs/gib3.mdl", 100 + random() * 50); }
void() d2boss_death28 =[ 7, d2boss_death29 ] { ThrowGibBoss ("progs/gib1.mdl", -300); }
void() d2boss_death29 =[ 7, d2boss_death30 ] { ThrowGibBoss ("progs/gib1.mdl", 100 + random() * 50);	ThrowGibBoss ("progs/gib2.mdl", 100 + random() * 50); }
void() d2boss_death30 =[ 7, d2boss_death31 ] { ThrowGibBoss ("progs/gib3.mdl", 100 + random() * 50);	ThrowGibBoss ("progs/gib2.mdl", 100 + random() * 50); }
void() d2boss_death31 =[ 7, d2boss_death32 ] { }
void() d2boss_death32 =[ 7, d2boss_death33 ] { }
void() d2boss_death33 =[ 7, d2boss_death34 ] { }
void() d2boss_death34 =[ 7, d2boss_death35 ] { }
void() d2boss_death35 =[ 7, d2boss_death22 ] {
	activator = self.enemy;
	SUB_UseTargetsByField(target4);
	remove(self);
}


void() d2boss_die =
{
	d2boss_cleanup();
	d2boss_death22();
};

void() d2boss_cleanup = {
	if (self.trigger_field) remove(self.trigger_field);
	if (self.buddy) {
		entity next, e;
		e = self.buddy;
		while (e){
			next = e.buddy;
			remove(e);
			e = next;
		}
		//remove(self.buddy);
	}
	if (self.eChildA) remove(self.eChildA);
}

void(entity attacker, float damage) d2boss_Pain =
{
	//dprint("Pain!\n");
	if ( self.health <= 0 ) 
		return;	

	
	if ( random() > 0.5 )
		sound (self, CHAN_AUTO, "d1boss/pain1.wav", 1, ATTN_NORM);
	else if ( random() > 0.75 )
		sound (self, CHAN_AUTO, "d1boss/pain2.wav", 1, ATTN_NORM);		
};

void() d2boss_reachpath = {
	entity corner = find(world, targetname, self.goalentity.target);
	self.goalentity = corner;
	SUB_CalcMove(corner.origin, self.speed, d2boss_reachpath);
}

void() d2boss_wake =
{
	//spawnDirector();

	d2boss_bbox_setfield(takedamage, DAMAGE_AIM); // damageable
	
	self.state = 1;// phase one
	dprint("Initiating phase one\n");
	entity corner = find(world, targetname, self.target);
	self.goalentity = corner;
	SUB_CalcMove(corner.origin, self.speed, d2boss_reachpath);
}

//=============================================================================

void() d2boss_createentities =
{
	// pain controller, to add up hits on simultaneous bbox entities at the same frame
	entity pc = spawn();
	self.trigger_field = pc;
	pc.owner = self;
	pc.classname = "d2boss_paincontroller";
	pc.think = d2boss_paincontroller_think;

	// 94 bbox entities
	vector coords[] = {
		'0 96 -96',
		'0 -96 -96',
		'0 96 96',
		'0 -96 96',
		'112 0 0',
		'-112 0 0',
		'16 0 96',
		'-16 0 -96',
		'16 32 96',
		'16 -32 96',
		'-16 32 -96',
		'-16 -32 -96',
		'16 64 96',
		'16 -64 96',
		'-16 64 -96',
		'-16 -64 -96',
		'16 96 64',
		'16 -96 64',
		'-16 96 -64',
		'-16 -96 -64',
		'16 96 32',
		'16 -96 32',
		'-16 96 -32',
		'-16 -96 -32',
		'16 96 0',
		'16 -96 0',
		'-16 96 0',
		'-16 -96 0',
		'16 96 -32',
		'16 -96 -32',
		'-16 96 32',
		'-16 -96 32',
		'16 96 -64',
		'16 -96 -64',
		'-16 96 64',
		'-16 -96 64',
		'16 0 -96',
		'-16 0 96',
		'16 32 -96',
		'16 -32 -96',
		'-16 32 96',
		'-16 -32 96',
		'16 64 -96',
		'16 -64 -96',
		'-16 64 96',
		'-16 -64 96',
		'48 0 64',
		'-48 0 -64',
		'48 32 64',
		'48 -32 64',
		'-48 32 -64',
		'-48 -32 -64',
		'48 64 64',
		'48 -64 64',
		'-48 64 -64',
		'-48 -64 -64',
		'48 64 0',
		'48 -64 0',
		'-48 64 0',
		'-48 -64 0',
		'48 64 -32',
		'48 -64 -32',
		'-48 64 32',
		'-48 -64 32',
		'48 64 32',
		'48 -64 32',
		'-48 64 -32',
		'-48 -64 -32',
		'48 0 -64',
		'-48 0 64',
		'48 32 -64',
		'48 -32 -64',
		'-48 32 64',
		'-48 -32 64',
		'48 64 -64',
		'48 -64 -64',
		'-48 64 64',
		'-48 -64 64',
		'80 0 -32',
		'-80 0 32',
		'80 0 32',
		'-80 0 -32',
		'80 32 0',
		'80 -32 0',
		'-80 32 0',
		'-80 -32 0',
		'80 32 -32',
		'80 -32 -32',
		'-80 32 32',
		'-80 -32 32',
		'80 32 32',
		'80 -32 32',
		'-80 32 -32',
		'-80 -32 -32'
	};
	vector ofs, org;

	entity e, next;
	e = spawn();
	self.buddy = e;
	e.owner = self;
	e.classname = "d2boss_thinker";
	e.think = d2boss_thinker_think;
	e.nextthink = time + 0.025;

	//makevectors([-self.angles_x, self.angles_y, self.angles_z]);
	makevectors (self.angles);

	for (float i = 0; i < 94; i++) {
		next = spawn();
		next.classname = "d2boss_bbox";
		next.movetype = MOVETYPE_FLY;
		next.solid = SOLID_BBOX;
		next.th_pain = d2boss_bbox_pain;
		next.takedamage = DAMAGE_AIM;
		next.health = 10000000000;
		
		ofs = coords[i];
		next.view_ofs = ofs;

		org = self.origin + v_forward * ofs_x + v_right * ofs_y + v_up * ofs_z;
		setorigin(next, org);

		setsize(next, '-24 -24 -24', '24 24 24');
		
		next.owner = self;

		e.buddy = next;
		e = next;
	}

}

// sets the specified float field on all bbox entities
void(.float fld, float value) d2boss_bbox_setfield = {
	entity e = self.buddy.buddy; // first bbox

	while (e) {
		if (e.classname == "d2boss_bbox") {
			e.fld = value;
			e = e.buddy;
		}
	}
}

void(entity attacker, float damage) d2boss_bbox_pain = {
	entity pc = self.owner.trigger_field;

	// "state" field set in T_RadiusDamageCheck() function if it was a radius damage
	// In this case, don't add up damage from multiple bbox entities or else the damage would be multiplied
	if (self.state){
		if (damage > pc.multi_dmg) pc.multi_dmg = damage;
	}
	else
		pc.dmg += damage;

	self.state = 0;
	pc.enemy = attacker;
	pc.nextthink = time + 0.01;
}


void() d2boss_beginphase2 = {
	self.state = 2;
	self.health = self.max_health;
	setmodel(self, "progs/mon_d2bossb_rot.mdl");
	
	activator = self.enemy;
	SUB_UseTargetsByField(target3);
}

void(entity tgt, entity attacker, float dmg) d2boss_damage = {
	tgt.health -= dmg;

	if (attacker.flags & FL_CLIENT) tgt.enemy = attacker;

	if (tgt.health <= 0) {
		if (tgt.state == 1){
			SUB_CallAsSelf(d2boss_beginphase2, tgt);
			return;	
		} 

		Killed (tgt, attacker, attacker);
	}
}

void() d2boss_paincontroller_think = {
	float totaldmg = max(self.dmg, self.multi_dmg);

	//eprint(self.owner);
	//T_Damage(self.owner, self.enemy, self.enemy, totaldmg);
	d2boss_damage(self.owner,self.enemy, totaldmg);

	dprint4("Damage: ", ftos(self.dmg), ", multi-damage: ", ftos(self.multi_dmg));
	dprint2(", total dmg: ", ftos(totaldmg));
	dprint3(", health: ", ftos(self.owner.health), "\n");
	self.dmg = self.multi_dmg = 0;
	self.enemy = world;
}


/*
attack state
0: moving around on path_corners
1: moving shoot

2: moving to room center
3: arrived at room center, initiating lighting
4: bullet hell fired, finishing lightning

*/

/*
void() d2boss_bullethell_loop = {
	self.angles = '-90 0 0';
	entity ct = find(world, targetname, self.include);
	fx_beam(self.origin, ct.origin, self);

	if (self.attack_state == 2) {
		dprint("\n----------------------\nInitiating stage 3\n\n");
		self.attack_finished = time;
		self.attack_state = 3;
	}

	if (self.attack_state == 3 && time > self.attack_finished + 1) {
		dprint("\n----------------------\nFiring bullet hell\n\n");
		SUB_CallAsSelf(chooseRandomTask, self.eChildA);
		self.attack_state = 4;
	}

	if (self.attack_state == 4 && time > self.attack_finished + 2) {
		dprint("\n----------------------\nEnding\n\n");
		self.attack_state = 0;
		self.buddy.think = d2boss_thinker_think;
		self.buddy.nextthink = time + 0.01;

		//dprint(self.goalentity);
		SUB_CalcMove(self.goalentity.origin, self.speed, d2boss_reachpath);
		return;
	}

	self.think = d2boss_bullethell_loop;
	self.nextthink = time + 0.1;
}
*/
void() d2boss_bullethell_resume = {
	self.attack_state = 0;
	self.buddy.think = d2boss_thinker_think;
	self.buddy.nextthink = time + 0.01;

	//dprint(self.goalentity);
	SUB_CalcMove(self.goalentity.origin, self.speed, d2boss_reachpath);
	self.use = SUB_Null;
}

void() d2boss_bullethell_wait = {
	self.use = d2boss_bullethell_resume;
	self.attack_state = 3;

	entity ct = find(world, targetname, self.target2);
	activator = self.enemy;
	SUB_UseEntTargets(ct);
}

void() d2boss_movetocenter = {
	self.pain_finished = time;
	entity ct = find(world, targetname, self.target2);

	//SUB_CalcMove(ct.origin, self.speed*2, d2boss_bullethell_loop);
	SUB_CalcMove(ct.origin, self.speed*2, d2boss_bullethell_wait);
	
}

void() d2boss_thinker_smoothrotate = {
	entity boss = self.owner;
	entity thinker = self;
	
	self = boss;
	
	if (boss.attack_state == 3)
		return;


	thinker.think = d2boss_thinker_smoothrotate;
	thinker.nextthink = time + 0.01;


	boss.avelocity = 0;
	boss.angles = lerpVector(boss.v_angle, '-90 0 0', (time - boss.pain_finished)/(boss.nextthink - boss.pain_finished));

	d2boss_updatebboxes(thinker, boss);

}

void(entity thinker, entity boss) d2boss_updatebboxes = {
	makevectors([-boss.angles_x, boss.angles_y, boss.angles_z]);

	entity e = thinker.buddy;
	vector org, ofs;

	while (e) {
		ofs = e.view_ofs;

		org = boss.origin + v_forward * ofs_x + v_right * ofs_y + v_up * ofs_z;
		setorigin(e, org);
		
		e = e.buddy;
	}
}

void() d2boss_thinker_think = {
	entity boss = self.owner;
	entity thinker = self;

	thinker.think = d2boss_thinker_think;
	thinker.nextthink = time + 0.01;

	self = boss;

	entity targ = checkclient();

	if (boss.state && targ && boss.attack_state <= 2) {
		
		// only faces player on phase 2
		if (boss.state == 2 && boss.attack_state < 2) {
			vector ang = vectoangles(targ.origin - boss.origin);
			boss.angles_x = ang_x;
			boss.angles_y = ang_y;
		}
		
		if (boss.attack_state == 2) {
			boss.v_angle = normalizeAngles180(boss.angles);
			boss.pain_finished = time;
			thinker.think = d2boss_thinker_smoothrotate;
			thinker.nextthink = time + 0.01;
		}

		if (time > boss.pausetime) {
			boss.pausetime = time + boss.wait + random()*boss.wait;
			boss.attack_finished = time + 2;
			boss.avelocity_z = boss.fixangle;
		}

		if (time < boss.attack_finished) {
			if (time > boss.attack_finished - 1.5 && !boss.attack_state) {
				if (random() < boss.lip){
					dprint("\n----------------------\nInitiating stage 2\n\n");
					d2boss_movetocenter();
					boss.attack_state = 2;
				}
				else {
					d2bossMissile();
					boss.attack_state = 1;
				}
			}
		} 
		else {
			boss.avelocity = 0;
			boss.attack_state = 0;
		}

	}
	
	// update bboxes position

	d2boss_updatebboxes(thinker, boss);
}


/*QUAKED monster_d2boss (1 0 0) (-16 -16 -24) (16 16 40) AMBUSH ? ? ? TRIGGERED NOTFOG NOTELEFRAG INSTAWAKE
Scrag (the SCULPTOR), ??? health points.

Keys:
"target" entity to trigger when killed
"targetname" entity name
*/
/*FGD
@PointClass base(Angle, Appearflags, Target, Targetname) color(220 0 0) size(32 32 32) model({ "path": ":progs/mon_d2boss_rot.mdl" }) = monster_d2boss : "The Sculptor"
[
	strength(integer) : "Phase 1 health" : 300
	max_health(integer) : "Phase 2 health" : 300
	speed(integer) : "Movement speed" : 300
	wait(integer) : "Time between firings" : 3
	lip(float) : "Chance of initiating bullethell sequence (0 to 1)" : "0.3"
	fixangle(integer) : "Spin velocity (-1 for no spin)" : 180
]
*/

void() monster_d2boss =
{
	if ( !SUB_ShouldSpawn() ) 
		return;
	
	if ( nomonster() ) 
		return;
	
	if ( deathmatch )
	{
		remove( self );
		return;
	}
	
	precache_model ("progs/mon_d2boss_rot.mdl");
	precache_model ("progs/mon_d2bossb_rot.mdl");
	precache_model ("progs/h_shams.mdl");
	precache_model ("progs/proj_d1boss.mdl");
	
	precache_sound ("d1boss/dash.wav");
	precache_sound ("d1boss/atk.wav");
	precache_sound ("d1boss/death.wav");
	precache_sound ("d1boss/bigattack.wav");
	precache_sound ("d1boss/pain1.wav");
	precache_sound ("d1boss/pain2.wav");
	precache_sound ("d1boss/phasechange.wav");
	precache_sound ("d1boss/aggro.wav");
	precache_sound ("d1boss/return.wav");
	precache_sound ("d1boss/idle.wav");
	precache_sound ("d1boss/proj.wav");

	// phase 1 health
	if (!self.strength) self.strength = 300;

	// phase 2 health
	if (!self.max_health) self.max_health = 300;

	self.health = self.strength;

	// movement speed
	if (!self.speed) self.speed = 300;

	// time between attacks
	if (!self.wait) self.wait = 3;

	// bullet hell chance
	if (!self.lip) self.lip = 0.3;

	// spin velocity
	self.fixangle = zeroconvertdefault(self.fixangle, 180);
	
	addmonster(1);
		
	self.solid = SOLID_NOT;
	self.takedamage = DAMAGE_NO;
	self.movetype = MOVETYPE_FLY;
	setmodel (self, "progs/mon_d2boss_rot.mdl");
	setsize (self, '0 0 0', '0 0 0');
	
	self.angles_x = -90;
	self.frame = 7;

	self.state = 0;
	self.type = "boss";
	self.th_die = d2boss_die;
	self.use = d2boss_wake;
	self.yaw_speed = 30;
	
	if ( self.deathtype == string_null )
		self.deathtype = " was killed by the Sculptor";

	d2boss_createentities();
};