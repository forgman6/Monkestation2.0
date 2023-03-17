/datum/species/simian
	// Highly intelligent, genetically modified chimps
	name = "Simian"
	id = SPECIES_SIMIAN

	bodytype = BODYTYPE_CUSTOM

	species_traits = list(
		EYECOLOR,
		LIPS,
		NO_UNDERWEAR
		)
	inherent_traits = list(
		TRAIT_VAULTING,
		TRAIT_KLEPTOMANIAC,
		TRAIT_MONKEYFRIEND
		)

	use_skintones = FALSE
	use_fur = TRUE

	inherent_biotypes = list(
		MOB_ORGANIC,
		MOB_HUMANOID
		)

	mutanttongue = /obj/item/organ/internal/tongue/monkey
	changesource_flags = MIRROR_BADMIN | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN
	meat = /obj/item/food/meat/slab/monkey
	skinned_type = /obj/item/stack/sheet/animalhide/monkey
	disliked_food = GROSS
	liked_food = FRUIT | MEAT
	//deathsound = 'monkestation/sound/voice/simian/deathsound.ogg'
	species_language_holder = /datum/language_holder/monkey
	maxhealthmod = 0.85 //small = weak
	stunmod = 1.3
	speedmod = -0.1 //lil bit faster

	custom_worn_icons = list(
		LOADOUT_ITEM_SUIT = SIMIAN_SUIT_ICON,
		LOADOUT_ITEM_UNIFORM = SIMIAN_UNIFORM_ICON,
	)
	offset_features = list(
		OFFSET_UNIFORM = list(0,0),
		OFFSET_ID = list(0,3),
		OFFSET_GLOVES = list(0,0),
		OFFSET_GLASSES = list(0,0),
		OFFSET_EARS = list(0,2),
		OFFSET_SHOES = list(0,0),
		OFFSET_S_STORE = list(0,0),
		OFFSET_FACEMASK = list(0,0),
		OFFSET_HEAD = list(0,0),
		OFFSET_FACE = list(0,0),
		OFFSET_BELT = list(0,0),
		OFFSET_BACK = list(0,0),
		OFFSET_SUIT = list(0,0),
		OFFSET_NECK = list(0,0),
		OFFSET_RIGHT_HAND = list(0,3),
		OFFSET_LEFT_HAND = list(0,3))

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/simian,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/simian,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/simian,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/simian,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/simian,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/simian,
	)

	external_organs = list(
		/obj/item/organ/external/tail/simian = "Chimp"
	)

/datum/species/simian/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	C.gain_trauma(/datum/brain_trauma/mild/kleptomania, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/species/simian/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_simian_name(gender)

	var/randname = simian_name(gender)

	if(lastname)
		randname += " [lastname]"

	return randname

/datum/species/simian/after_equip_job(datum/job/J, mob/living/carbon/human/H, visualsOnly = FALSE, client/preference_source = null)
	qdel(H.wear_neck)
	var/obj/item/clothing/mask/translator/T = new /obj/item/clothing/mask/translator
	H.equip_to_slot(T, ITEM_SLOT_NECK)

/obj/item/clothing/mask/translator
	name = "MonkeTech AutoTranslator"
	desc = "A small device that will translate speech."
	icon = 'monkestation/icons/obj/clothing/masks.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/mask.dmi'
	icon_state = "translator"
	slot_flags = ITEM_SLOT_MASK | ITEM_SLOT_NECK
	modifies_speech = TRUE
	var/current_language = /datum/language/common

/obj/item/clothing/mask/translator/proc/generate_language_names(mob/user)
	var/static/list/language_name_list
	if(!language_name_list)
		language_name_list = list()
		for(var/language in user.mind.language_holder.understood_languages)
			if(language in user.mind.language_holder.blocked_languages)
				continue
			var/atom/A = language
			language_name_list[initial(A.name)] = A
	return language_name_list

/obj/item/clothing/mask/translator/attack_self(mob/user)
	. = ..()
	if(ishuman(user))
		var/list/display_names = generate_language_names(user)
		if(!display_names.len > 1)
			return
		var/choice = input(user,"Please select a language","Select a language:") as null|anything in sort_list(display_names)
		if(!choice)
			return
		current_language = display_names[choice]

/obj/item/clothing/mask/translator/equipped(mob/M, slot)
	. = ..()
	if ((slot == ITEM_SLOT_MASK || slot == ITEM_SLOT_NECK) && modifies_speech)
		RegisterSignal(M, COMSIG_MOB_SAY, .proc/handle_speech)
	else
		UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/clothing/mask/translator/handle_speech(datum/source, list/speech_args)
	. = ..()
	if(!(clothing_flags * (VOICEBOX_DISABLED)))
		if(obj_flags & EMAGGED)
			speech_args[SPEECH_LANGUAGE] = pick(GLOB.all_languages)
		else
			speech_args[SPEECH_LANGUAGE] = current_language

/obj/item/clothing/mask/translator/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Click while in hand to select output language.</span>"

/obj/item/clothing/mask/translator/emag_act()
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	icon_state = "translator_emag"
	playsound(src, "sparks", 100, 1)
