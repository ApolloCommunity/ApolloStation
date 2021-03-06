/mob/living/simple_animal/spiderbot

	min_oxy = 0
	max_tox = 0
	max_co2 = 0
	minbodytemp = 0
	maxbodytemp = 500
	mob_size = 5

	var/obj/item/device/radio/borg/radio = null
	var/mob/living/silicon/ai/connected_ai = null
	var/obj/item/weapon/cell/cell = null
	var/obj/machinery/camera/camera = null
	var/obj/item/device/mmi/mmi = null
	var/list/req_access = list(access_robotics) //Access needed to pop out the brain.

	name = "Spider-bot"
	desc = "A skittering robotic friend!"
	icon = 'icons/mob/robots.dmi'
	icon_state = "spiderbot-chassis"
	icon_living = "spiderbot-chassis"
	icon_dead = "spiderbot-smashed"
	universal_speak = 1 //Temp until these are rewritten.

	wander = 0

	health = 10
	maxHealth = 10

	attacktext = "shocked"
	melee_damage_lower = 1
	melee_damage_upper = 3

	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "stomps on"

	var/emagged = 0
	var/obj/item/held_item = null //Storage for single item they can hold.
	speed = -1                    //Spiderbots gotta go fast.
	//pass_flags = PASSTABLE      //Maybe griefy?
	small = 1
	speak_emote = list("beeps","clicks","chirps")

/mob/living/simple_animal/spiderbot/attackby(var/obj/item/O as obj, var/mob/user as mob)

	if(istype(O, /obj/item/device/mmi))
		var/obj/item/device/mmi/B = O
		if(src.mmi) //There's already a brain in it.
			user << "<span class='alert'>There's already a brain in [src]!</span>"
			return
		if(!B.brainmob)
			user << "<span class='alert'>Sticking an empty MMI into the frame would sort of defeat the purpose.</span>"
			return
		if(!B.brainmob.key)
			var/ghost_can_reenter = 0
			if(B.brainmob.mind)
				for(var/mob/dead/observer/G in player_list)
					if(G.can_reenter_corpse && G.mind == B.brainmob.mind)
						ghost_can_reenter = 1
						break
			if(!ghost_can_reenter)
				user << "<span class='notice'>[O] is completely unresponsive; there's no point.</span>"
				return

		if(B.brainmob.stat == DEAD)
			user << "<span class='alert'>[O] is dead. Sticking it into the frame would sort of defeat the purpose.</span>"
			return

		if(jobban_isbanned(B.brainmob, "Cyborg"))
			user << "<span class='alert'>[O] does not seem to fit.</span>"
			return

		user << "<span class='notice'>You install [O] in [src]!</span>"

		user.drop_item()
		src.mmi = O
		src.transfer_personality(O)

		O.loc = src
		src.update_icon()
		return 1

	if (istype(O, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = O
		if (WT.remove_fuel(0))
			if(health < maxHealth)
				health += pick(1,1,1,2,2,3)
				if(health > maxHealth)
					health = maxHealth
				add_fingerprint(user)
				for(var/mob/W in viewers(user, null))
					W.show_message(text("<span class='alert'>[user] has spot-welded some of the damage to [src]!</span>"), 1)
			else
				user << "<span class='notice'>[src] is undamaged!</span>"
		else
			user << "Need more welding fuel!"
			return
	else if(istype(O, /obj/item/weapon/card/id)||istype(O, /obj/item/device/pda))
		if (!mmi)
			user << "<span class='alert'>There's no reason to swipe your ID - the spiderbot has no brain to remove.</span>"
			return 0

		var/obj/item/weapon/card/id/id_card

		if(istype(O, /obj/item/weapon/card/id))
			id_card = O
		else
			var/obj/item/device/pda/pda = O
			id_card = pda.id

		if(access_robotics in id_card.access)
			user << "<span class='notice'>You swipe your access card and pop the brain out of [src].</span>"
			eject_brain()

			if(held_item)
				held_item.loc = src.loc
				held_item = null

			return 1
		else
			user << "<span class='alert'>You swipe your card, with no effect.</span>"
			return 0
	else if (istype(O, /obj/item/weapon/card/emag))
		if (emagged)
			user << "<span class='alert'>[src] is already overloaded - better run.</span>"
			return 0
		else
			var/obj/item/weapon/card/emag/emag = O
			emag.uses--
			emagged = 1
			user << "<span class='notice'>You short out the security protocols and overload [src]'s cell, priming it to explode in a short time.</span>"
			spawn(100)	src << "<span class='alert'>Your cell seems to be outputting a lot of power...</span>"
			spawn(200)	src << "<span class='alert'>Internal heat sensors are spiking! Something is badly wrong with your cell!</span>"
			spawn(300)	src.explode()

	else
		. = ..()

/mob/living/simple_animal/spiderbot/proc/transfer_personality(var/obj/item/device/mmi/M as obj)

		src.mind = M.brainmob.mind
		src.mind.key = M.brainmob.key
		src.ckey = M.brainmob.ckey
		src.name = "Spider-bot ([M.brainmob.name])"

/mob/living/simple_animal/spiderbot/proc/explode() //When emagged.
	for(var/mob/M in viewers(src, null))
		if ((M.client && !( M.blinded )))
			M.show_message("<span class='alert'>[src] makes an odd warbling noise, fizzles, and explodes.</span>")
	explosion(get_turf(loc), -1, -1, 3, 5)
	eject_brain()
	death()

/mob/living/simple_animal/spiderbot/proc/update_icon()
	if(istype(mmi, /obj/item/device/mmi/digital/posibrain))
		icon_state = "spiderbot-chassis-posi"
		icon_living = "spiderbot-chassis-posi"
	else if(istype(mmi,/obj/item/device/mmi))
		icon_state = "spiderbot-chassis-mmi"
		icon_living = "spiderbot-chassis-mmi"
	else
		icon_state = "spiderbot-chassis"
		icon_living = "spiderbot-chassis"

/mob/living/simple_animal/spiderbot/proc/eject_brain()
	if(mmi)
		var/turf/T = get_turf(loc)
		if(T)
			mmi.loc = T
		if(mind)	mind.transfer_to(mmi.brainmob)
		mmi = null
		src.name = "Spider-bot"
		update_icon()

/mob/living/simple_animal/spiderbot/Destroy()
	eject_brain()
	..()

/mob/living/simple_animal/spiderbot/New()

	verbs += /mob/living/proc/ventcrawl
	radio = new /obj/item/device/radio/borg(src)
	camera = new /obj/machinery/camera(src)
	camera.c_tag = "Spiderbot-[real_name]"
	camera.network = list("SS13")

	..()

/mob/living/simple_animal/spiderbot/death()

	living_mob_list -= src

	new /obj/effect/gibspawner/robot(get_turf(src))
	qdel(src)
	return

//Cannibalized from the parrot mob. ~Zuhayr
/mob/living/simple_animal/spiderbot/verb/drop_held_item()
	set name = "Drop held item"
	set category = "Spiderbot"
	set desc = "Drop the item you're holding."

	if(stat)
		return

	if(!held_item)
		usr << "<span class='alert'>You have nothing to drop!</span>"
		return 0

	if(istype(held_item, /obj/item/weapon/grenade))
		visible_message("<span class='alert'>[src] launches \the [held_item]!</span>", "<span class='alert'>You launch \the [held_item]!</span>", "You hear a skittering noise and a thump!")
		var/obj/item/weapon/grenade/G = held_item
		G.loc = src.loc
		G.prime()
		held_item = null
		return 1

	visible_message("<span class='notice'>[src] drops \the [held_item]!</span>", "<span class='notice'>You drop \the [held_item]!</span>", "You hear a skittering noise and a soft thump.")

	held_item.loc = src.loc
	held_item = null
	return 1

	return

/mob/living/simple_animal/spiderbot/verb/get_item()
	set name = "Pick up item"
	set category = "Spiderbot"
	set desc = "Allows you to take a nearby small item."

	if(stat)
		return -1

	if(held_item)
		src << "<span class='alert'>You are already holding \the [held_item]</span>"
		return 1

	var/list/items = list()
	for(var/obj/item/I in view(1,src))
		if(I.loc != src && I.w_class <= 2 && I.Adjacent(src) )
			items.Add(I)

	var/obj/selection = input("Select an item.", "Pickup") in items

	if(selection)
		for(var/obj/item/I in view(1, src))
			if(selection == I)
				held_item = selection
				selection.loc = src
				visible_message("<span class='notice'>[src] scoops up \the [held_item]!</span>", "<span class='notice'>You grab \the [held_item]!</span>", "You hear a skittering noise and a clink.")
				return held_item
		src << "<span class='alert'>\The [selection] is too far away.</span>"
		return 0

	src << "<span class='alert'>There is nothing of interest to take.</span>"
	return 0

/mob/living/simple_animal/spiderbot/examine(mob/user)
	..(user)
	if(src.held_item)
		user << "It is carrying \a [src.held_item] \icon[src.held_item]."

/mob/living/simple_animal/spiderbot/can_use_vents()
	return
