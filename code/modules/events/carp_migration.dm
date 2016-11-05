/datum/event/carp_migration
	announceWhen	= 50
	endWhen 		= 900

	var/list/spawned_carp = list()

/datum/event/carp_migration/setup()
	announceWhen = rand(40, 60)
	endWhen = rand(600,1200)

/datum/event/carp_migration/announce()
	var/announcement = ""
	if(severity == EVENT_LEVEL_MAJOR)
		announcement = "Massive migration of unknown biological entities has been detected near [station_name()], all EVA activities must be suspended until further notice."
	else
		announcement = "Unknown biological [spawned_carp.len == 1 ? "entity has" : "entities have"] been detected near [station_name()], all EVA activities discouraged until further notice."
	command_announcement.Announce(announcement, "AUTOMATED ALERT: Unidentified Lifesigns")

/datum/event/carp_migration/start()
	if(severity == EVENT_LEVEL_MAJOR)
		spawn_fish(landmarks_list.len)
	else if(severity == EVENT_LEVEL_MODERATE)
		spawn_fish(rand(4, 6)) 			//12 to 30 carp, in small groups
	else
		spawn_fish(rand(1, 3), 1, 2)	//1 to 6 carp, alone or in pairs

/datum/event/carp_migration/proc/spawn_fish(var/num_groups, var/group_size_min=3, var/group_size_max=5)
	var/list/spawn_locations = list()

	for(var/obj/effect/landmark/C in landmarks_list)
		if(C.name == "carpspawn")
			spawn_locations.Add(C.loc)
	spawn_locations = shuffle(spawn_locations)
	num_groups = min(num_groups, spawn_locations.len)

	var/i = 1
	while (i <= num_groups)
		var/group_size = rand(group_size_min, group_size_max)
		for (var/j = 1, j <= group_size, j++)
			if(prob(95)) //5% chance of SHERK
				spawned_carp.Add(new /mob/living/simple_animal/hostile/carp(spawn_locations[i]))
			else
				spawned_carp.Add(new /mob/living/simple_animal/hostile/carp/pike(spawn_locations[i]))
		i++

/datum/event/carp_migration/end()
	for(var/mob/living/simple_animal/hostile/C in spawned_carp)
		if(!C.stat)
			var/turf/T = get_turf(C)
			if(istype(T, /turf/space))
				qdel(C)
