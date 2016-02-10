var/datum/announcement/minor/captain_announcement = new(do_newscast = 1)

/datum/job/captain
	title = "Captain"
	flag = CAPTAIN
	department_id = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "Nanotrasen officials and Corporate Regulations"
	selection_color = "#ccccff"
	idtype = /obj/item/weapon/card/id/gold
	req_admin_notify = 1
	access = list() 			//See get_access()
	minimal_access = list() 	//See get_access()
	minimal_player_age = 14

	rank_succesion_level = 11

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_to_slot_or_qdel(new /obj/item/device/radio/headset/heads/captain(H), slot_l_ear)
		switch(H.character.backpack)
			if(2) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/captain(H), slot_back)
			if(3) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel_cap(H), slot_back)
			if(4) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		var/obj/item/clothing/under/U = new /obj/item/clothing/under/rank/captain(H)
		if(H.character.age>49)
			U.hastie = new /obj/item/clothing/tie/medal/gold/captain(U)
		H.equip_to_slot_or_qdel(U, slot_w_uniform)
		H.equip_to_slot_or_qdel(new /obj/item/device/pda/captain(H), slot_belt)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/brown(H), slot_shoes)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/head/caphat(H), slot_head)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/glasses/sunglasses(H), slot_glasses)
		if(H.character.backpack == 1)
			H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/ids(H), slot_r_hand)
		else
			H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/ids(H.back), slot_in_backpack)

		var/sound/announce_sound = (ticker.current_state <= GAME_STATE_SETTING_UP)? null : sound('sound/misc/boatswain.ogg', volume=20)
		captain_announcement.Announce("All hands, Captain [H.real_name] on deck!", new_sound=announce_sound)

		H.implant_loyalty(src)

		return 1

	get_access()
		return get_all_accesses()

/datum/job/captain/make_preview_icon( var/backpack )
	var/icon/clothes_s = null

	clothes_s = new /icon('icons/mob/uniform.dmi', "captain_s")
	clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
	if(prob(1))
		clothes_s.Blend(new /icon('icons/mob/head.dmi', "centcomcaptain"), ICON_OVERLAY)
	else
		clothes_s.Blend(new /icon('icons/mob/head.dmi', "captain"), ICON_OVERLAY)
	switch(backpack)
		if(2)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
		if(3)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-cap"), ICON_OVERLAY)
		if(4)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

	return clothes_s

/datum/job/hop
	title = "Head of Personnel"
	flag = HOP
	department_id = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ddddff"
	idtype = /obj/item/weapon/card/id/silver
	req_admin_notify = 1
	minimal_player_age = 10

	rank_succesion_level = 10

	access = list(access_security, access_sec_doors, access_brig, access_court, access_forensics_lockers,
			            access_medical, access_engine, access_change_ids, access_ai_upload, access_eva, access_heads,
			            access_all_personal_lockers, access_maint_tunnels, access_bar, access_janitor, access_construction, access_morgue,
			            access_crematorium, access_kitchen, access_cargo, access_cargo_bot, access_mailsorting, access_qm, access_hydroponics, access_lawyer,
			            access_theatre, access_chapel_office, access_library, access_research, access_mining, access_heads_vault, access_mining_station,
			            access_clown, access_mime, access_hop, access_RC_announce, access_keycard_auth, access_gateway)
	minimal_access = list(access_security, access_sec_doors, access_brig, access_court, access_forensics_lockers,
			            access_medical, access_engine, access_change_ids, access_ai_upload, access_eva, access_heads,
			            access_all_personal_lockers, access_maint_tunnels, access_bar, access_janitor, access_construction, access_morgue,
			            access_crematorium, access_kitchen, access_cargo, access_cargo_bot, access_mailsorting, access_qm, access_hydroponics, access_lawyer,
			            access_theatre, access_chapel_office, access_library, access_research, access_mining, access_heads_vault, access_mining_station,
			            access_clown, access_mime, access_hop, access_RC_announce, access_keycard_auth, access_gateway)


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_to_slot_or_qdel(new /obj/item/device/radio/headset/heads/hop(H), slot_l_ear)
		switch(H.character.backpack)
			if(2) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack(H), slot_back)
			if(3) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
			if(4) H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/under/rank/head_of_personnel(H), slot_w_uniform)
		H.equip_to_slot_or_qdel(new /obj/item/clothing/shoes/brown(H), slot_shoes)
		H.equip_to_slot_or_qdel(new /obj/item/device/pda/heads/hop(H), slot_belt)
		if(H.character.backpack == 1)
			H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/ids(H), slot_r_hand)
		else
			H.equip_to_slot_or_qdel(new /obj/item/weapon/storage/box/ids(H.back), slot_in_backpack)
		return 1

/datum/job/hop/make_preview_icon( var/backpack )
	var/icon/clothes_s = null

	clothes_s = new /icon('icons/mob/uniform.dmi', "hop_s")
	clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
	if(prob(1))
		clothes_s.Blend(new /icon('icons/mob/suit.dmi', "ianshirt"), ICON_OVERLAY)
	switch(backpack)
		if(2)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
		if(3)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
		if(4)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

	return clothes_s
