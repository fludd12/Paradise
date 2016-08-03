/*
* Returns a byond list that can be passed to the "deserialize" proc
* to bring a new instance of this atom to its original state
*
* If we want to store this info, we can pass it to `json_encode` or some other
* interface that suits our fancy, to make it into an easily-handled string
*/
/datum/proc/serialize()
	var/data = list("type" = "[type]")
	return data

/*
* This is given the byond list from above, to bring this atom to the state
* described in the list.
* This will be called after `New` but before `initialize`, so linking and stuff
* would probably be handled in `initialize`
*
* Also, this should only be called by `json_to_object` in persistence.dm - at least
* with current plans - that way it can actually initialize the type from the list
*/
/datum/proc/deserialize(var/list/data)
	return


/atom
	// This is so specific atoms can override these, and ignore certain ones
	var/list/vars_to_save = list("dir","name","color","icon","icon_state")
/atom/serialize()
	var/list/data = ..()
	for(var/thing in vars_to_save)
		if(vars[thing] != initial(vars[thing]))
			data[thing] = vars[thing]
	return data


/atom/deserialize(var/list/data)
	for(var/thing in vars_to_save)
		if(thing in data)
			vars[thing] = data[thing]
	..()


/proc/json_to_object(var/json_data, var/loc)
	var/data = json_decode(json_data)
	return list_to_object(data, loc)

/proc/list_to_object(var/list/data, var/loc)
	if(!islist(data))
		throw EXCEPTION("You didn't give me a list, bucko")
	if(!("type" in data))
		throw EXCEPTION("No 'type' field in the data")
	var/path = text2path(data["type"])
	if(!path)
		throw EXCEPTION("Path not found: [path]")

	var/atom/movable/thing = new path(loc)
	thing.deserialize(data)
	return thing
