/obj/item/projectile/beam
	name = "laser"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 40
	damage_type = BURN
	flag = "laser"
	eyeblur = 4
	var/frequency = 1
	hitscan = 1

	muzzle_type = /obj/effect/projectile/laser/muzzle
	tracer_type = /obj/effect/projectile/laser/tracer
	impact_type = /obj/effect/projectile/laser/impact

/obj/item/projectile/beam/practice
	name = "laser"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 0
	damage_type = BURN
	flag = "laser"
	eyeblur = 2

/obj/item/projectile/beam/heavylaser
	name = "heavy laser"
	icon_state = "heavylaser"
	damage = 60

	muzzle_type = /obj/effect/projectile/laser_heavy/muzzle
	tracer_type = /obj/effect/projectile/laser_heavy/tracer
	impact_type = /obj/effect/projectile/laser_heavy/impact

/obj/item/projectile/beam/xray
	name = "xray beam"
	icon_state = "xray"
	damage = 30

	muzzle_type = /obj/effect/projectile/xray/muzzle
	tracer_type = /obj/effect/projectile/xray/tracer
	impact_type = /obj/effect/projectile/xray/impact

/obj/item/projectile/beam/pulse
	name = "pulse"
	icon_state = "u_laser"
	damage = 50

	muzzle_type = /obj/effect/projectile/laser_pulse/muzzle
	tracer_type = /obj/effect/projectile/laser_pulse/tracer
	impact_type = /obj/effect/projectile/laser_pulse/impact

/obj/item/projectile/beam/emitter
	name = "emitter beam"
	icon_state = "emitter"
	damage = 30

	muzzle_type = /obj/effect/projectile/emitter/muzzle
	tracer_type = /obj/effect/projectile/emitter/tracer
	impact_type = /obj/effect/projectile/emitter/impact

/obj/item/projectile/beam/lastertag/blue
	name = "lasertag beam"
	icon_state = "bluelaser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 0
	damage_type = BURN
	flag = "laser"

	muzzle_type = /obj/effect/projectile/laser_blue/muzzle
	tracer_type = /obj/effect/projectile/laser_blue/tracer
	impact_type = /obj/effect/projectile/laser_blue/impact

	on_hit(var/atom/target, var/blocked = 0)
		if(istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/M = target
			if(istype(M.wear_suit, /obj/item/clothing/suit/redtag))
				M.Weaken(5)
		return 1

/obj/item/projectile/beam/lastertag/red
	name = "lasertag beam"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 0
	damage_type = BURN
	flag = "laser"

	on_hit(var/atom/target, var/blocked = 0)
		if(istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/M = target
			if(istype(M.wear_suit, /obj/item/clothing/suit/bluetag))
				M.Weaken(5)
		return 1

/obj/item/projectile/beam/lastertag/omni//A laser tag bolt that stuns EVERYONE
	name = "lasertag beam"
	icon_state = "omnilaser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 0
	damage_type = BURN
	flag = "laser"

	muzzle_type = /obj/effect/projectile/laser_omni/muzzle
	tracer_type = /obj/effect/projectile/laser_omni/tracer
	impact_type = /obj/effect/projectile/laser_omni/impact

	on_hit(var/atom/target, var/blocked = 0)
		if(istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/M = target
			if((istype(M.wear_suit, /obj/item/clothing/suit/bluetag))||(istype(M.wear_suit, /obj/item/clothing/suit/redtag)))
				M.Weaken(5)
		return 1

/obj/item/projectile/beam/sniper
	name = "sniper beam"
	icon_state = "xray"
	damage = 60
	stun = 5
	weaken = 5
	stutter = 5

	muzzle_type = /obj/effect/projectile/xray/muzzle
	tracer_type = /obj/effect/projectile/xray/tracer
	impact_type = /obj/effect/projectile/xray/impact

/obj/item/projectile/beam/stun
	name = "stun beam"
	icon_state = "stun"
	nodamage = 1
	agony = 40
	damage_type = HALLOSS

	muzzle_type = /obj/effect/projectile/stun/muzzle
	tracer_type = /obj/effect/projectile/stun/tracer
	impact_type = /obj/effect/projectile/stun/impact

// continuous beams
/obj/item/projectile/beam/continuous
	name = "laser beam"
	icon = 'icons/obj/projectiles_continuous.dmi'
	icon_state = "emitter_end"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 4
	damage_type = BURN
	flag = "laser"
	eyeblur = 1

	var/icon_base = "emitter"
	var/process_delay = 2
	var/obj/item/projectile/beam/continuous/node1
	var/obj/item/projectile/beam/continuous/node2

/obj/item/projectile/beam/continuous/New(var/loc, var/parent)
	node1 = parent

	dir = node1.dir
	if(istype(node1))
		step(src, dir)
	else // beams whose node1 is not a continuous beam are considered beam spawners
		alpha = 0
		density = 0

	process()

/obj/item/projectile/beam/continuous/Destroy()
	if(node1 && istype(node1))
		node1.node2 = null
	if(node2)
		qdel(node2)

	node1 = null
	node2 = null

	..()

/obj/item/projectile/beam/continuous/Bump(var/atom/movable/A)
	if(!istype(node1))	return // spawner

	if(istype(A, /mob/living))
		var/mob/living/M = A
		M.bullet_act(src, "chest")

	if(istype(A, /turf))
		for(var/obj/O in A)
			O.bullet_act(src)
		A.bullet_act(src)

	if(istype(A, /obj))
		var/obj/O = A
		O.bullet_act(src)

	qdel(src)

/obj/item/projectile/beam/continuous/Crossed(var/atom/movable/A)
	// bit of dupe code, but it's so that your chatbox isn't spammed with the message
	if(istype(A, /mob/living))
		var/mob/living/M = A
		M << "<span class='warning'>You feel a concentrated, burning pain on your skin!</span>"
	Bump(A)
	return ..(A)

/obj/item/projectile/beam/continuous/process()
	if(!node1)
		qdel(src)
		return
	if(!loc || loc.density)
		Bump(loc)
		return
	if(node2 && node2.loc) // don't try to propagate if there's a beam segment ahead
		spawn(process_delay)
			process()
		return

 	icon_state = "[icon_base]_end"
	var/obj/item/projectile/beam/continuous/B = new type(src.loc, src)
	node2 = B
	spawn(0)
		if(B.loc)
			if(B.z != z) // pls no travel through zs
				qdel(B)
				return
			B.process()
			if(B)	icon_state = icon_base

	spawn(process_delay)
		process()

/obj/item/projectile/beam/continuous/singularity_pull()
	return

/obj/item/projectile/beam/continuous/emitter
	name = "emitter beam"

	var/power = 40

/obj/item/projectile/beam/continuous/emitter/New(var/loc, var/parent)
	node1 = parent

	var/parent_power = 0
	if(istype(node1))
		var/obj/item/projectile/beam/continuous/emitter/B = node1
		parent_power = B.power
	else if(istype(parent, /obj/machinery/power/emitter))
		var/obj/machinery/power/emitter/E = parent
		parent_power = E.active_power_usage / 1000

	update_power(parent_power)

	..()

/obj/item/projectile/beam/continuous/emitter/Destroy()
	if(istype(node1, /obj/machinery/power/emitter))
		var/obj/machinery/power/emitter/E = node1
		E.beam = null

	..()

/obj/item/projectile/beam/continuous/emitter/proc/update_power(var/new_power)
	if(new_power)
		power = new_power

	if(istype(node1))
		alpha = min(255, 255 * (power / EMITTER_POWER_MAX))
	damage = power / 10

	if(node2)
		var/obj/item/projectile/beam/continuous/emitter/E = node2
		E.update_power(power)