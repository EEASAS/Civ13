/obj/structure/branch
	name = "branch"
	desc = "A tree branch still with leaves attached."
	icon = 'icons/obj/old_weapons.dmi'
	icon_state = "leaved_stick"
	density = FALSE
	anchored = FALSE
	not_movable = FALSE
	not_disassemblable = TRUE
	flammable = TRUE
	var/leaves = TRUE
	var/branched = TRUE
/obj/structure/branch/cleared
	name = "cleared branch"
	desc = "A tree branch with all the leaves picked out."
	icon_state = "cleared_stick"
	leaves = FALSE
/obj/structure/branch/attack_hand(mob/living/human/H)
	if (H.a_intent == I_GRAB && leaves)
		H << "You start picking the leaves from the branch..."
		if (do_after(H, 60, src))
			if (src && leaves)
				var /obj/item/stack/material/leaf/dropleaves = new /obj/item/stack/material/leaf(get_turf(src))
				dropleaves.amount = 3
				dropleaves.update_strings()
				H << "You pick up some leaves from the branch."
				name = "cleared branch"
				desc = "A tree branch with all the leaves picked out."
				icon_state = "cleared_stick"
				leaves = FALSE
				return
		return
	else if (H.a_intent == I_HARM && !leaves && branched)
		H << "You start removing the small twigs..."
		if (do_after(H, 60, src))
			if (src && branched)
				new /obj/item/weapon/material/primitive_handle(get_turf(src))
				H << "You finish clearing the stick."
				branched = FALSE
				qdel(src)
				return
		return
	else
		..()
/obj/item/weapon/branch
	name = "stick"
	desc = "A tree branch with all the leaves and small branches picked out."
	icon_state = "debranched_stick"
	item_state = "debranched_stick"
	icon = 'icons/obj/old_weapons.dmi'
	force = 7
	attack_verb = list("hit","bashed","poked")
	sharp = FALSE
	edge = FALSE
	slot_flags = SLOT_BELT
	throw_speed = 7
	throw_range = 7
	allow_spin = FALSE
	value = 1
	cooldownw = 6
	flammable = TRUE
	fuel_value = 80
	var/sharpened = FALSE

	var/ants = FALSE
/obj/item/weapon/branch/sharpened
	name = "sharpened stick"
	desc = "A sharpened stick, to be used against bad apes."
	icon_state = "sharpened_stick"
	item_state = "sharpened_stick"
	sharp = TRUE
	force = 14
	sharpened = TRUE
/obj/item/weapon/branch/attack_self(mob/living/human/user as mob)
	if (ants)
		to_chat(user, SPAN_NOTICE("You start licking some ants off the stick..."))
		if (do_after(user, 50, src))
			if (src && ants)
				to_chat(user, SPAN_NOTICE("You finish eating some ants."))
				icon_state = "sharpened_stick"
				ants = FALSE
				if (user.gorillaman)
					user.mood += 10
				else if (user.ant)
					user.mood -= 20
				else if (!user.orc && !user.crab)
					user.mood -= 10
				user.nutrition += 80
				return
	else
		..()

/obj/item/weapon/branch/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (W.edge && !sharpened)
		user << "You start sharpening the stick..."
		if (do_after(user, 80, src))
			if (src && !sharpened)
				user << "You finish sharpening the stick."
				name = "sharpened stick"
				desc = "A sharpened stick, to be used against bad apes."
				icon_state = "sharpened_stick"
				sharp = TRUE
				force = 14
				sharpened = TRUE
				return
		return
	else if (sharpened && istype(W, /obj/item/weapon/flint))
		var/obj/item/weapon/flint/F = W
		if (F.sharpened)
			user << "You start attaching the flint to the stick..."
			if (do_after(user, 100, src))
				if (src && F && F.sharpened)
					user << "You finish making the flint axe."
					new/obj/item/weapon/material/hatchet/tribal/flint(user.loc)
					qdel(F)
					qdel(src)
					return

/obj/item/weapon/material/primitive_handle/attackby(obj/item/weapon/W as obj, mob/user as mob) // Handle to Twined Handle
	if (istype(W, /obj/item/stack/material/twine))
		var/obj/item/stack/material/twine/R = W
		user << "You start attaching some twine"
		if (do_after(user, 20, src))
			user << "You finish making the twined handle."
			new /obj/item/weapon/material/handle/primitive/twined(user.loc)
			if (R.amount > 1) // Reduce the stack size by 1 (consume one twine from the stack)
				R.amount -= 1
			else
				qdel(R)  // If only one twine is left, delete the stack
			qdel(src)  // Remove the original object (handle or something else)
			return
	..()

/obj/item/weapon/material/handle/primitive/twined/attackby(obj/item/weapon/W as obj, mob/user as mob) // Hatchet & Knife Final Craft
	var/item_type
	var/message_start
	var/message_finish
	if (istype(W, /obj/item/weapon/material/primitive_axehead_1))
		item_type = /obj/item/weapon/material/hatchet/primitive
		message_start = "You start attaching the axehead to the handle..."
		message_finish = "You finish making the stone axe."
	else if (istype(W, /obj/item/weapon/material/primitive_knifehead_1))
		item_type = /obj/item/weapon/material/kitchen/utensil/knife/primitive_knife_1
		message_start = "You start attaching the knifehead to the handle..."
		message_finish = "You finish making the stone knife."
	else if (istype(W, /obj/item/weapon/material/primitive_handle))
		item_type = /obj/item/heatable/forged/tongs/wooden
		message_start = "You start attaching \the [W] to \the [src]..."
		message_finish = "You finish making the tongs."


	if (item_type)
		var/obj/item/R = W
		user << message_start
		if (do_after(user, 20, src))
			user << message_finish
			var/obj/item/new_item = new item_type()
			if (!user.put_in_hands(new_item))
				new_item.loc = user.loc // Fallback to placing it on the ground if the hands are full
			qdel(R)
			qdel(src)
			return
	..()