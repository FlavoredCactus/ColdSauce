
/mob/living/carbon/human/restrained()
	if (handcuffed)
		return 1
	if (istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
		return 1
	return 0

/mob/living/carbon/human/canBeHandcuffed()
	return 1

//gets assignment from ID or ID inside tablet or tablet itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_assignment(var/if_no_id = "No id", var/if_no_job = "No job")
	var/obj/item/weapon/card/id/id = get_idcard()
	if(id)
		. = id.assignment
	else
		var/obj/item/device/tablet/tablet = wear_id
		var/obj/item/device/tablet_core/core = tablet.core
		if(istype(tablet) && core)
			. = core.ownjob
		else
			return if_no_id
	if(!.)
		return if_no_job

//gets name from ID or ID inside tablet or tablet itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_authentification_name(var/if_no_id = "Unknown")
	var/obj/item/weapon/card/id/id = get_idcard()
	if(id)
		return id.registered_name
	var/obj/item/device/tablet/tablet = wear_id
	var/obj/item/device/tablet_core/core = tablet.core
	if(istype(tablet) && core)
		return core.owner
	return if_no_id

//repurposed proc. Now it combines get_id_name() and get_face_name() to determine a mob's name variable. Made into a seperate proc as it'll be useful elsewhere
/mob/living/carbon/human/get_visible_name()
	var/face_name = get_face_name("")
	var/id_name = get_id_name("")
	if(face_name)
		if(id_name && (id_name != face_name))
			return "[face_name] (as [id_name])"
		return face_name
	if(id_name)
		return id_name
	return "Unknown"

//Returns "Unknown" if facially disfigured and real_name if not. Useful for setting name when polyacided or when utabletting a human's name variable
/mob/living/carbon/human/proc/get_face_name(if_no_face="Unknown")
	if( wear_mask && (wear_mask.flags_inv&HIDEFACE) )	//Wearing a mask which hides our face, use id-name if possible
		return if_no_face
	if( head && (head.flags_inv&HIDEFACE) )
		return if_no_face		//Likewise for hats
	var/obj/item/organ/limb/O = get_organ("head")
	if( (status_flags&DISFIGURED) || (O.brutestate+O.burnstate)>2 || cloneloss>50 || !real_name )	//disfigured. use id-name if possible
		return if_no_face
	return real_name

//gets name from ID or tablet itself, ID inside tablet doesn't matter
//Useful when player is being seen by other mobs
/mob/living/carbon/human/proc/get_id_name(var/if_no_id = "Unknown")
	var/obj/item/weapon/storage/wallet/wallet = wear_id
	var/obj/item/device/tablet/tablet = wear_id
	var/obj/item/weapon/card/id/id = wear_id
	if(istype(wallet))		id = wallet.front_id
	if(istype(id))			. = id.registered_name
	else if(istype(tablet))	. = tablet.owner
	if(!.) 					. = if_no_id	//to prevent null-names making the mob unclickable
	return

//gets ID card object from special clothes slot or null.
/mob/living/carbon/human/proc/get_idcard()
	if(wear_id)
		return wear_id.GetID()

///eyecheck()
///Returns a number between -1 to 2
/mob/living/carbon/human/eyecheck()
	var/number = 0
	if(istype(src.head, /obj/item/clothing/head))			//are they wearing something on their head
		var/obj/item/clothing/head/HFP = src.head			//if yes gets the flash protection value from that item
		number += HFP.flash_protect
	if(istype(src.glasses, /obj/item/clothing/glasses))		//glasses
		var/obj/item/clothing/glasses/GFP = src.glasses
		number += GFP.flash_protect
	if(istype(src.wear_mask, /obj/item/clothing/mask))		//mask
		var/obj/item/clothing/mask/MFP = src.wear_mask
		number += MFP.flash_protect
	return number

///tintcheck()
///Checks eye covering items for visually impairing tinting, such as welding masks
///Checked in life.dm. 0 & 1 = no impairment, 2 = welding mask overlay, 3 = You can see jack, but you can't see shit.
/mob/living/carbon/human/tintcheck()
	var/tinted = 0
	if(istype(src.head, /obj/item/clothing/head))
		var/obj/item/clothing/head/HT = src.head
		tinted += HT.tint
	if(istype(src.glasses, /obj/item/clothing/glasses))
		var/obj/item/clothing/glasses/GT = src.glasses
		tinted += GT.tint
	if(istype(src.wear_mask, /obj/item/clothing/mask))
		var/obj/item/clothing/mask/MT = src.wear_mask
		tinted += MT.tint
	return tinted

/mob/living/carbon/human/abiotic(var/full_body = 0)
	if(full_body && ((src.l_hand && !( src.l_hand.flags&ABSTRACT )) || (src.r_hand && !( src.r_hand.flags&ABSTRACT )) || (src.back || src.wear_mask || src.head || src.shoes || src.w_uniform || src.wear_suit || src.glasses || src.ears || src.gloves)))
		return 1

	if( (src.l_hand && !(src.l_hand.flags&ABSTRACT)) || (src.r_hand && !(src.r_hand.flags&ABSTRACT)) )
		return 1

	return 0

/mob/living/carbon/human/IsAdvancedToolUser()
	return 1//Humans can use guns and such

/mob/living/carbon/human/proc/bleed_on_floor(var/bleed_max)
	if (buckled)
		return
	var/turf/location = loc
	if (istype(location, /turf/simulated))
		if(bleed_max == 1)
			if(prob(25))
				location.add_blooddrips_floor(src)
		if(bleed_max >= 2)
			if( (prob(40) && bleed_max == 2) || (prob(50) && bleed_max == 3) )
				var/blood_exists = 0
				var/trail_type = getTrail()
				for(var/obj/effect/decal/cleanable/trail_holder/C in loc) //checks for blood splatter already on the floor
					blood_exists = 1
				if (trail_type != null)
					var/newdir = get_dir(location, loc)
					if(newdir != dir)
						newdir = newdir | dir
						if(newdir == 3) //N + S
							newdir = NORTH
						else if(newdir == 12) //E + W
							newdir = EAST
					//if((newdir in list(1, 2, 4, 8)) && (prob(50)))
					//	newdir = turn(get_dir(location, loc), 180)
					if(!blood_exists)
						new /obj/effect/decal/cleanable/trail_holder(loc)
					for(var/obj/effect/decal/cleanable/trail_holder/H in loc)
						if((!(newdir in H.existing_dirs) || trail_type == "trails_1" || trail_type == "trails_2") && H.existing_dirs.len <= 16) //maximum amount of overlays is 16 (all light & heavy directions filled)
							H.existing_dirs += newdir
							H.overlays.Add(image('icons/effects/blood.dmi',trail_type,dir = newdir))
							if(check_dna_integrity(src)) //blood DNA
								H.blood_DNA[src.dna.unique_enzymes] = src.dna.blood_type

/mob/living/carbon/human/getTrail()
	var/bleed_max = isbleeding()
	switch(bleed_max)
		if(2)
			if(prob(50))
				return "ltrails_1"
			return "ltrails_2"
		if(3)
			if(prob(50))
				return "trails_1"
			return "trails_2"

/mob/living/carbon/human/can_use_hands()
	if(!..())
		return 0
	if(!has_active_hand())
		return 0
	return 1