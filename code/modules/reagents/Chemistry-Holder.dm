//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

var/const/TOUCH = 1
var/const/INGEST = 2

///////////////////////////////////////////////////////////////////////////////////

datum
	reagents
		var/list/datum/reagent/reagent_list = list()
		var/total_volume = 0
		var/maximum_volume = 100
		var/atom/my_atom = null
		var/reacting = 0 // Reacting right now

		New(maximum=100)
			maximum_volume = maximum


			//I dislike having these here but map-objects are initialised before world/New() is called. >_>
			if(!chemical_reagents_list)
				//Chemical Reagents - Initialises all /datum/reagent into a list indexed by reagent id
				var/paths = typesof(/datum/reagent) - /datum/reagent
				chemical_reagents_list = list()
				for(var/path in paths)
					var/datum/reagent/D = new path()
					if(!D.name)
						continue
					chemical_reagents_list[D.id] = D
			if(!chemical_reactions_list)
				//Chemical Reactions - Initialises all /datum/chemical_reaction into a list
				// It is filtered into multiple lists within a list.
				// For example:
				// chemical_reaction_list["phoron"] is a list of all reactions relating to phoron

				var/paths = typesof(/datum/chemical_reaction) - /datum/chemical_reaction
				chemical_reactions_list = list()

				for(var/path in paths)

					var/datum/chemical_reaction/D = new path()
					var/list/reaction_ids = list()

					if(D.required_reagents && D.required_reagents.len)
						for(var/reaction in D.required_reagents)
							reaction_ids += reaction

					// Create filters based on each reagent id in the required reagents list
					for(var/id in reaction_ids)
						if(!chemical_reactions_list[id])
							chemical_reactions_list[id] = list()
						chemical_reactions_list[id] += D
						break // Don't bother adding ourselves to other reagent ids, it is redundant.

		proc

			get_free_space() // Returns free space.
				return maximum_volume - total_volume

			get_master_reagent() // Returns reference to the reagent with the biggest volume.
				var/the_reagent = null
				var/the_volume = 0
				for(var/datum/reagent/A in reagent_list)
					if(A.volume > the_volume)
						the_volume = A.volume
						the_reagent = A

				return the_reagent

			get_master_reagent_name() // Returns the name of the reagent with the biggest volume.
				var/the_name = null
				var/the_volume = 0
				for(var/datum/reagent/A in reagent_list)
					if(A.volume > the_volume)
						the_volume = A.volume
						the_name = A.name

				return the_name

			get_master_reagent_id() // Returns the id of the reagent with the biggest volume.
				var/the_id = null
				var/the_volume = 0
				for(var/datum/reagent/A in reagent_list)
					if(A.volume > the_volume)
						the_volume = A.volume
						the_id = A.id

				return the_id

			/datum/reagents/proc/update_total() // Updates volume.
				total_volume = 0
				for (var/datum/reagent/R in src.reagent_list)
					del_reagent(R.id)
				else
					total_volume += R.volume
				return

			trans_to_holder(var/datum/reagents/target, var/amount = 1, var/multiplier = 1, var/copy = 0) // Transfers [amount] reagents from [src] to [target], multiplying them by [multiplier]. Returns actual amount removed from [src] (not amount transferred to [target]).
				if(!target || !istype(target))
					return

				amount = max(0, min(amount, total_volume, target.get_free_space() / multiplier))

				if(!amount)
					return

				var/part = amount / total_volume

				for(var/datum/reagent/current in reagent_list)
					var/amount_to_transfer = current.volume * part
					target.add_reagent(current.id, amount_to_transfer * multiplier, current.get_data(), safety = 1) // We don't react until everything is in place
					if(!copy)
						remove_reagent(current.id, amount_to_transfer, 1)

				if(!copy)
					handle_reactions()
				target.handle_reactions()
				return amount

			trans_to_ingest(var/obj/target, var/amount=1, var/multiplier=1, var/preserve_data=1)//For items ingested. A delay is added between ingestion and addition of the reagents
				if (!target )
					return
				if (!target.reagents || src.total_volume<=0)
					return

				/*var/datum/reagents/R = target.reagents

				var/obj/item/weapon/reagent_containers/glass/beaker/noreact/B = new /obj/item/weapon/reagent_containers/glass/beaker/noreact //temporary holder

				amount = min(min(amount, src.total_volume), R.maximum_volume-R.total_volume)
				var/part = amount / src.total_volume
				var/trans_data = null
				for (var/datum/reagent/current_reagent in src.reagent_list)
					if (!current_reagent)
						continue
					//if (current_reagent.id == "blood" && ishuman(target))
					//	var/mob/living/carbon/human/H = target
					//	H.inject_blood(my_atom, amount)
					//	continue
					var/current_reagent_transfer = current_reagent.volume * part
					if(preserve_data)
						trans_data = current_reagent.data

					B.add_reagent(current_reagent.id, (current_reagent_transfer * multiplier), trans_data, safety = 1)	//safety checks on these so all chemicals are transferred
					src.remove_reagent(current_reagent.id, current_reagent_transfer, safety = 1)							// to the target container before handling reactions

				src.update_total()
				B.update_total()
				B.handle_reactions()
				src.handle_reactions()*/

				var/obj/item/weapon/reagent_containers/glass/beaker/noreact/B = new /obj/item/weapon/reagent_containers/glass/beaker/noreact //temporary holder
				B.volume = 1000

				var/datum/reagents/BR = B.reagents
				var/datum/reagents/R = target.reagents

				amount = min(min(amount, src.total_volume), R.maximum_volume-R.total_volume)

				src.trans_to(B, amount)

				//spawn(95)
				BR.reaction(target, INGEST)
					//spawn(5)
				BR.trans_to(target, BR.total_volume)
				qdel(B)

				return amount

			copy_to(var/obj/target, var/amount=1, var/multiplier=1, var/preserve_data=1, var/safety = 0)
				if(!target)
					return
				if(!target.reagents || src.total_volume<=0)
					return
				var/datum/reagents/R = target.reagents
				amount = min(min(amount, src.total_volume), R.maximum_volume-R.total_volume)
				var/part = amount / src.total_volume
				var/trans_data = null
				for (var/datum/reagent/current_reagent in src.reagent_list)
					var/current_reagent_transfer = current_reagent.volume * part
					if(preserve_data)
						trans_data = copy_data(current_reagent)
					R.add_reagent(current_reagent.id, (current_reagent_transfer * multiplier), trans_data, safety = 1)	//safety check so all chemicals are transferred before reacting

				src.update_total()
				R.update_total()
				if(!safety)
					R.handle_reactions()
					src.handle_reactions()
				return amount

			trans_id_to(var/obj/target, var/reagent, var/amount=1, var/preserve_data=1)//Not sure why this proc didn't exist before. It does now! /N
				if (!target)
					return
				if (!target.reagents || src.total_volume<=0 || !src.get_reagent_amount(reagent))
					return

				var/datum/reagents/R = target.reagents
				if(src.get_reagent_amount(reagent)<amount)
					amount = src.get_reagent_amount(reagent)
				amount = min(amount, R.maximum_volume-R.total_volume)
				var/trans_data = null
				for (var/datum/reagent/current_reagent in src.reagent_list)
					if(current_reagent.id == reagent)
						if(preserve_data)
							trans_data = copy_data(current_reagent)
						R.add_reagent(current_reagent.id, amount, trans_data)
						src.remove_reagent(current_reagent.id, amount, 1)
						break

				src.update_total()
				R.update_total()
				R.handle_reactions()
				//src.handle_reactions() Don't need to handle reactions on the source since you're (presumably isolating and) transferring a specific reagent.
				return amount

/*
				if (!target) return
				var/total_transfered = 0
				var/current_list_element = 1
				var/datum/reagents/R = target.reagents
				var/trans_data = null
				//if(R.total_volume + amount > R.maximum_volume) return 0

				current_list_element = rand(1,reagent_list.len) //Eh, bandaid fix.

				while(total_transfered != amount)
					if(total_transfered >= amount) break //Better safe than sorry.
					if(total_volume <= 0 || !reagent_list.len) break
					if(R.total_volume >= R.maximum_volume) break

					if(current_list_element > reagent_list.len) current_list_element = 1
					var/datum/reagent/current_reagent = reagent_list[current_list_element]
					if(preserve_data)
						trans_data = current_reagent.data
					R.add_reagent(current_reagent.id, (1 * multiplier), trans_data)
					src.remove_reagent(current_reagent.id, 1)

					current_list_element++
					total_transfered++
					src.update_total()
					R.update_total()
				R.handle_reactions()
				handle_reactions()

				return total_transfered
*/

			metabolize(var/mob/M,var/alien)

				for(var/A in reagent_list)
					var/datum/reagent/R = A
					if(M && R)
						R.on_mob_life(M,alien)
				update_total()

			conditional_update_move(var/atom/A, var/Running = 0)
				for(var/datum/reagent/R in reagent_list)
					R.on_move (A, Running)
				update_total()

			delete()
				for(var/datum/reagent/R in reagent_list)
					R.holder = null
				if(my_atom)
					my_atom.reagents = null

			handle_reactions()
				if(!my_atom) // No reactions in temporary holders
					return
				if(my_atom.flags & NOREACT)
					return //Yup, no reactions here. No siree.

				var/reaction_occured = 0
				do
					reaction_occured = 0
					for(var/datum/reagent/R in reagent_list)
						for(var/datum/chemical_reaction/C in chemical_reactions_list[R.id])
						var/reagents_suitable = 1
						for(var/B in C.required_reagents)
							if(!has_reagent(B, C.required_reagents[B]))
								reagents_suitable = 0
						for(var/B in C.catalysts)
							if(!has_reagent(B, C.catalysts[B]))
								reagents_suitable = 0
						for(var/B in C.inhibitors)
							if(has_reagent(B, C.inhibitors[B]))
								reagents_suitable = 0
						if(!reagents_suitable || !C.can_happen(src))
							continue

							var/use = -1
							for(var/B in C.required_reagents)
								if(use == -1)
									use = get_reagent_amount(B) / C.required_reagents[B]
								else
									use = min(use, get_reagent_amount(B) / C.required_reagents[B])

							var/newdata = C.send_data(src) // We need to get it before reagents are removed. See blood paint.

							for(var/B in C.required_reagents)
								remove_reagent(B, use * C.required_reagents[B], safety = 1)
							if(C.result)
								add_reagent(C.result, C.result_amount * use, newdata)

							if(!ismob(my_atom) && C.mix_message)
								var/list/seen = viewers(4, get_turf(my_atom))
								for(var/mob/M in seen)
									M << "<span class='notice'>\icon[my_atom] [C.mix_message]</span>"
									playsound(get_turf(my_atom), 'sound/effects/bubbles.ogg', 80, 1)

								C.on_reaction(src, created_volume)
								reaction_occured = 1

				while(reaction_occured)
				update_total()
				return

			/* Holder-to-chemical */
			add_reagent(var/id, var/amount, var/data = null, var/safety = 0)
				if(!isnum(amount) || amount <= 0)
					return 0

				update_total()
				amount = min(amount, get_free_space())

				for(var/datum/reagent/current in reagent_list)
					if(current.id == id)
						current.volume += amount
						if(!isnull(data)) // For all we know, it could be zero or empty string and meaningful
							current.mix_data(data, amount)
						update_total()
						if(!safety)
							handle_reactions()
						if(my_atom)
							my_atom.on_reagent_change()
						return 1
				var/datum/reagent/D = chemical_reagents_list[id]
				if(D)
					var/datum/reagent/R = new D.type()
					reagent_list += R
					R.holder = src
					R.volume = amount
					R.initialize_data(data)
					update_total()
					if(!safety)
						handle_reactions()
					if(my_atom)
						my_atom.on_reagent_change()
					return 1
				else
					warning("[my_atom] attempted to add a reagent called '[id]' which doesn't exist. ([usr])")
				return 0

			remove_reagent(var/id, var/amount, var/safety = 0)
				if(!isnum(amount))
					return 0
				for(var/datum/reagent/current in reagent_list)
					if(current.id == id)
						current.volume -= amount // It can go negative, but it doesn't matter
						update_total() // Because this proc will delete it then
						if(!safety)
							handle_reactions()
						if(my_atom)
							my_atom.on_reagent_change()
						return 1
				return 0

			del_reagent(var/id)
				for(var/datum/reagent/current in reagent_list)
					if (current.id == id)
						reagent_list -= current
						qdel(current)
						update_total()
						if(my_atom)
							my_atom.on_reagent_change()
						return 0

			has_reagent(var/id, var/amount = null)
				for(var/datum/reagent/current in reagent_list)
					if(current.id == id)
						if((isnull(amount) && current.volume > 0) || current.volume >= amount)
							return 1
						else
							return 0
				return 0

			clear_reagents()
				for(var/datum/reagent/R in reagent_list)
					del_reagent(R.id)
				return 0

			get_data(var/id)
				for(var/datum/reagent/current in reagent_list)
					if(current.id == id)
						return current.get_data()
				return 0

			get_reagents()
				. = list()
				for(var/datum/reagent/current in reagent_list)
					. += "[current.id] ([current.volume])"
				return english_list(., "EMPTY", "", ", ", ", ")

			/* Holder-to-holder and similar procs */

			remove_any(var/amount = 1) // Removes up to [amount] of reagents from [src]. Returns actual amount removed.
				amount = min(amount, total_volume)

				if(!amount)
					return

				var/part = amount / total_volume

				for(var/datum/reagent/current in reagent_list)
					var/amount_to_remove = current.volume * part
					remove_reagent(current.id, amount_to_remove, 1)

				update_total()
				handle_reactions()
				return amount

			trans_to_holder(var/datum/reagents/target, var/amount = 1, var/multiplier = 1, var/copy = 0) // Transfers [amount] reagents from [src] to [target], multiplying them by [multiplier]. Returns actual amount removed from [src] (not amount transferred to [target]).
				if(!target || !istype(target))
					return

					amount = max(0, min(amount, total_volume, target.get_free_space() / multiplier))

				if(!amount)
					return

				var/part = amount / total_volume

				for(var/datum/reagent/current in reagent_list)
					var/amount_to_transfer = current.volume * part
					target.add_reagent(current.id, amount_to_transfer * multiplier, current.get_data(), safety = 1) // We don't react until everything is in place
					if(!copy)
						remove_reagent(current.id, amount_to_transfer, 1)

				if(!copy)
					handle_reactions()
				target.handle_reactions()
				return amount

			remove_reagent(var/reagent, var/amount, var/safety = 0)//Added a safety check for the trans_id_to
				if(!isnum(amount)) return 1

				for(var/A in reagent_list)
					var/datum/reagent/R = A
					if (R.id == reagent)
						R.volume -= amount
						update_total()
						if(!safety)//So it does not handle reactions when it need not to
							handle_reactions()
						my_atom.on_reagent_change()
						return 0

				return 1

			has_reagent(var/reagent, var/amount = -1)

				for(var/A in reagent_list)
					var/datum/reagent/R = A
					if (R.id == reagent)
						if(!amount) return R
						else
							if(R.volume >= amount) return R
							else return 0

				return 0

			get_reagent_amount(var/reagent)
				for(var/A in reagent_list)
					var/datum/reagent/R = A
					if (R.id == reagent)
						return R.volume

				return 0

			get_reagents()
				var/res = ""
				for(var/datum/reagent/A in reagent_list)
					if (res != "") res += ","
					res += A.name

				return res

			remove_all_type(var/reagent_type, var/amount, var/strict = 0, var/safety = 1) // Removes all reagent of X type. @strict set to 1 determines whether the childs of the type are included.
				if(!isnum(amount)) return 1

				var/has_removed_reagent = 0

				for(var/datum/reagent/R in reagent_list)
					var/matches = 0
					// Switch between how we check the reagent type
					if(strict)
						if(R.type == reagent_type)
							matches = 1
					else
						if(istype(R, reagent_type))
							matches = 1
					// We found a match, proceed to remove the reagent.	Keep looping, we might find other reagents of the same type.
					if(matches)
						// Have our other proc handle removement
						has_removed_reagent = remove_reagent(R.id, amount, safety)

				return has_removed_reagent

			/* Holder-to-atom and similar procs */

			//The general proc for applying reagents to things. This proc assumes the reagents are being applied externally,
			//not directly injected into the contents. It first calls touch, then the appropriate trans_to_*() or splash_mob().
			//If for some reason touch effects are bypassed (e.g. injecting stuff directly into a reagent container or person),
			//call the appropriate trans_to_*() proc.
			trans_to(var/atom/target, var/amount = 1, var/multiplier = 1, var/copy = 0)
				touch(target) //First, handle mere touch effects

				if(ismob(target))
					return splash_mob(target, amount, copy)
				if(isturf(target))
					return trans_to_turf(target, amount, multiplier, copy)
				if(isobj(target) && target.is_open_container())
					return trans_to_obj(target, amount, multiplier, copy)
				return 0

			trans_id_to(var/atom/target, var/id, var/amount = 1)
				if (!target || !target.reagents || !target.simulated)
					return

				amount = min(amount, get_reagent_amount(id))

				if(!amount)
					return

				var/datum/reagents/F = new /datum/reagents(amount)
				var/tmpdata = get_data(id)
				F.add_reagent(id, amount, tmpdata)
				remove_reagent(id, amount)

				return F.trans_to(target, amount) // Let this proc check the atom's type

			// Attempts to place a reagent on the mob's skin.
			// Reagents are not guaranteed to transfer to the target.
			// Do not call this directly, call trans_to() instead.
			splash_mob(var/mob/target, var/amount = 1, var/copy = 0)
				var/perm = 1
				if(isliving(target)) //will we ever even need to tranfer reagents to non-living mobs?
					var/mob/living/L = target
					perm = L.reagent_permeability()
				return trans_to_mob(target, amount, CHEM_TOUCH, perm, copy)

			trans_to_mob(var/mob/target, var/amount = 1, var/type = CHEM_BLOOD, var/multiplier = 1, var/copy = 0) // Transfer after checking into which holder...
				if(!target || !istype(target) || !target.simulated)
					return
				if(iscarbon(target))
					var/mob/living/carbon/C = target
					if(type == CHEM_BLOOD)
						var/datum/reagents/R = C.reagents
						return trans_to_holder(R, amount, multiplier, copy)
					if(type == CHEM_INGEST)
						var/datum/reagents/R = C.ingested
						return C.ingest(src,R, amount, multiplier, copy) //perhaps this is a bit of a hack, but currently there's no common proc for eating reagents
					if(type == CHEM_TOUCH)
						var/datum/reagents/R = C.touching
						return trans_to_holder(R, amount, multiplier, copy)
				else
					var/datum/reagents/R = new /datum/reagents(amount)
					. = trans_to_holder(R, amount, multiplier, copy)
					R.touch_mob(target)

			trans_to_turf(var/turf/target, var/amount = 1, var/multiplier = 1, var/copy = 0) // Turfs don't have any reagents (at least, for now). Just touch it.
				if(!target || !target.simulated)
					return

				var/datum/reagents/R = new /datum/reagents(amount * multiplier)
				. = trans_to_holder(R, amount, multiplier, copy)
				R.touch_turf(target)
				return

			trans_to_obj(var/obj/target, var/amount = 1, var/multiplier = 1, var/copy = 0) // Objects may or may not; if they do, it's probably a beaker or something and we need to transfer properly; otherwise, just touch.
				if(!target || !target.simulated)
					return

				if(!target.reagents)
					var/datum/reagents/R = new /datum/reagents(amount * multiplier)
					. = trans_to_holder(R, amount, multiplier, copy)
					R.touch_obj(target)
					return

				return trans_to_holder(target.reagents, amount, multiplier, copy)


			// When applying reagents to an atom externally, touch() is called to trigger any on-touch effects of the reagent.
			// This does not handle transferring reagents to things.
			// For example, splashing someone with water will get them wet and extinguish them if they are on fire,
			// even if they are wearing an impermeable suit that prevents the reagents from contacting the skin.
			touch(var/atom/target)
				if(ismob(target))
					touch_mob(target)
				if(isturf(target))
					touch_turf(target)
				if(isobj(target))
					touch_obj(target)
				return

			touch_mob(var/mob/target)
				if(!target || !istype(target) || !target.simulated)
					return

				for(var/datum/reagent/current in reagent_list)
					current.touch_mob(target, current.volume)

				update_total()

			touch_turf(var/turf/target)
				if(!target || !istype(target) || !target.simulated)
					return

				for(var/datum/reagent/current in reagent_list)
					current.touch_turf(target, current.volume)

				update_total()

			touch_obj(var/obj/target)
				if(!target || !istype(target) || !target.simulated)
					return

				for(var/datum/reagent/current in reagent_list)
					current.touch_obj(target, current.volume)

				update_total()


			//two helper functions to preserve data across reactions (needed for xenoarch)
			get_data(var/reagent_id)
				for(var/datum/reagent/D in reagent_list)
					if(D.id == reagent_id)
						//world << "proffering a data-carrying reagent ([reagent_id])"
						return D.data

			set_data(var/reagent_id, var/new_data)
				for(var/datum/reagent/D in reagent_list)
					if(D.id == reagent_id)
						//world << "reagent data set ([reagent_id])"
						D.data = new_data

			delete()
				for(var/datum/reagent/R in reagent_list)
					R.holder = null
				if(my_atom)
					my_atom.reagents = null

			copy_data(var/datum/reagent/current_reagent)
				if (!current_reagent || !current_reagent.data) return null
				if (!istype(current_reagent.data, /list)) return current_reagent.data

				var/list/trans_data = current_reagent.data.Copy()

				// We do this so that introducing a virus to a blood sample
				// doesn't automagically infect all other blood samples from
				// the same donor.
				//
				// Technically we should probably copy all data lists, but
				// that could possibly eat up a lot of memory needlessly
				// if most data lists are read-only.
				if (trans_data["virus2"])
					var/list/v = trans_data["virus2"]
					trans_data["virus2"] = v.Copy()

				return trans_data

///////////////////////////////////////////////////////////////////////////////////


// Convenience proc to create a reagents holder for an atom
// Max vol is maximum volume of holder
atom/proc/create_reagents(var/max_vol)
	reagents = new/datum/reagents(max_vol)
	reagents.my_atom = src
