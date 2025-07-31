extends Node

var db
var cards_db = {}

func _ready():
	initialize_database()
	load_all_cards_data()

func initialize_database():
	db = SQLite.new()
	db.path = "res://SQLite.db"
	if not db.open_db():
		push_error("Failed to open database")
		return false
	return true

func load_all_cards_data():
	load_base_cards()
	load_legalities()
	load_legality_formats()
	load_card_classes()
	load_card_types()
	load_card_subtypes()
	load_card_elements()
	load_editions()
	load_other_orientations()
	load_orientation_classes()
	load_orientation_types()
	load_orientation_subtypes()
	load_orientation_elements()
	load_orientation_editions()

func load_base_cards():
	var query = """
	SELECT Id, Slug, Name, Effect, EffectRaw, Element, Flavor, 
		   Power, Life, Speed, Level, CostMemory, CostReserve, Durability
	FROM Cards;
	"""
	if db.query(query):
		for card in db.query_result:
			var slug = card["Slug"]
			cards_db[slug] = {
				"id": card["Id"],
				"name": card["Name"],
				"effect": card["Effect"],
				"effect_raw": card["EffectRaw"],
				"element": card["Element"],
				"flavor": card["Flavor"],
				"power": card["Power"],
				"life": card["Life"],
				"speed": card["Speed"],
				"level": card["Level"],
				"cost_memory": card["CostMemory"],
				"cost_reserve": card["CostReserve"],
				"durability": card["Durability"],
				"classes": [],
				"types": [],
				"subtypes": [],
				"elements": [],
				"editions": [],
				"legalities": []
			}

func load_legalities():
	var query = "SELECT Id, CardId FROM CardLegality;"
	if db.query(query):
		for row in db.query_result:
			var card_slug = get_card_slug_by_id(row["CardId"])
			if card_slug in cards_db:
				cards_db[card_slug]["legalities"].append({
					"legality_id": row["Id"],
					"formats": []
				})

func load_legality_formats():
	var query = """
	SELECT lf.CardLegalityId, lf.Format, lf.[Limit] AS LimitValue
	FROM LegalityFormat lf
	JOIN CardLegality cl ON lf.CardLegalityId = cl.Id
	JOIN Cards c ON cl.CardId = c.Id;
	"""
	
	if db.query(query):
		var formats_by_legality = {}
		for row in db.query_result:
			var legality_id = row["CardLegalityId"]
			if not formats_by_legality.has(legality_id):
				formats_by_legality[legality_id] = []
			formats_by_legality[legality_id].append({
				"format": row["Format"],
				"limit": row["LimitValue"]
			})
		for card_slug in cards_db:
			for legality in cards_db[card_slug]["legalities"]:
				if formats_by_legality.has(legality["legality_id"]):
					legality["formats"] = formats_by_legality[legality["legality_id"]]

func load_card_classes():
	var query = "SELECT CardId, Class FROM CardClasses;"
	if db.query(query):
		for row in db.query_result:
			var card_slug = get_card_slug_by_id(row["CardId"])
			if card_slug and card_slug in cards_db:
				cards_db[card_slug]["classes"].append(row["Class"])

func load_card_types():
	var query = "SELECT CardId, Type FROM CardTypes;"
	if db.query(query):
		for row in db.query_result:
			var card_slug = get_card_slug_by_id(row["CardId"])
			if card_slug and card_slug in cards_db:
				cards_db[card_slug]["types"].append(row["Type"])

func load_card_subtypes():
	var query = "SELECT CardId, Subtype FROM CardSubtypes;"
	if db.query(query):
		for row in db.query_result:
			var card_slug = get_card_slug_by_id(row["CardId"])
			if card_slug and card_slug in cards_db:
				cards_db[card_slug]["subtypes"].append(row["Subtype"])

func load_card_elements():
	var query = "SELECT CardId, Element FROM CardElements;"
	if db.query(query):
		for row in db.query_result:
			var card_slug = get_card_slug_by_id(row["CardId"])
			if card_slug and card_slug in cards_db:
				cards_db[card_slug]["elements"].append(row["Element"])

func load_editions():
	var query = """
	SELECT Id, CardId, Slug, CardEditionId, Effect, EffectRaw, Flavor, Orientation
	FROM CardEditions;
	"""
	if db.query(query):
		for edition in db.query_result:
			var card_slug = get_card_slug_by_id(edition["CardId"])
			if card_slug and card_slug in cards_db:
				var edition_data = {
					"id": edition["Id"],
					"slug": edition["Slug"],
					"edition_id": edition["CardEditionId"],
					"effect": edition["Effect"],
					"effect_raw": edition["EffectRaw"],
					"flavor": edition["Flavor"],
					"orientation": edition["Orientation"]
				}
				cards_db[card_slug]["editions"].append(edition_data)
				cards_db[edition["Slug"]] = edition_data

func load_other_orientations():
	var query = """
	SELECT Id, Name, Slug, Effect, EffectRaw, Element, Flavor, 
		   Power, Life, Speed, Level, CostMemory, CostReserve, Durability
	FROM CardOtherOrientations;
	"""
	if db.query(query):
		for orientation in db.query_result:
			var slug = orientation["Slug"]
			cards_db[slug] = {
				"id": orientation["Id"],
				"name": orientation["Name"],
				"effect": orientation["Effect"],
				"effect_raw": orientation["EffectRaw"],
				"element": orientation["Element"],
				"flavor": orientation["Flavor"],
				"power": orientation["Power"],
				"life": orientation["Life"],
				"speed": orientation["Speed"],
				"level": orientation["Level"],
				"cost_memory": orientation["CostMemory"],
				"cost_reserve": orientation["CostReserve"],
				"durability": orientation["Durability"],
				"classes": [],
				"types": [],
				"subtypes": [],
				"elements": [],
				"editions": []
			}

func load_orientation_classes():
	var query = "SELECT OtherOrientationId, Class FROM CardOtherOrientationClasses;"
	if db.query(query):
		for row in db.query_result:
			var orientation_slug = get_orientation_slug_by_id(row["OtherOrientationId"])
			if orientation_slug and orientation_slug in cards_db:
				cards_db[orientation_slug]["classes"].append(row["Class"])

func load_orientation_types():
	var query = "SELECT OtherOrientationId, Type FROM CardOtherOrientationTypes;"
	if db.query(query):
		for row in db.query_result:
			var orientation_slug = get_orientation_slug_by_id(row["OtherOrientationId"])
			if orientation_slug and orientation_slug in cards_db:
				cards_db[orientation_slug]["types"].append(row["Type"])

func load_orientation_subtypes():
	var query = "SELECT OtherOrientationId, Subtype FROM CardOtherOrientationSubtypes;"
	if db.query(query):
		for row in db.query_result:
			var orientation_slug = get_orientation_slug_by_id(row["OtherOrientationId"])
			if orientation_slug and orientation_slug in cards_db:
				cards_db[orientation_slug]["subtypes"].append(row["Subtype"])

func load_orientation_elements():
	var query = "SELECT OtherOrientationId, Element FROM CardOtherOrientationElements;"
	if db.query(query):
		for row in db.query_result:
			var orientation_slug = get_orientation_slug_by_id(row["OtherOrientationId"])
			if orientation_slug and orientation_slug in cards_db:
				cards_db[orientation_slug]["elements"].append(row["Element"])

func load_orientation_editions():
	var query = """
	SELECT Id, OtherOrientationId, Slug, CardEditionId, Effect, EffectRaw, Flavor, Orientation
	FROM CardOtherOrientationEditions;
	"""
	
	if db.query(query):
		for edition in db.query_result:
			var orientation_slug = get_orientation_slug_by_id(edition["OtherOrientationId"])
			if orientation_slug and orientation_slug in cards_db:
				var edition_data = {
					"id": edition["Id"],
					"slug": edition["Slug"],
					"edition_id": edition["CardEditionId"],
					"effect": edition["Effect"],
					"effect_raw": edition["EffectRaw"],
					"flavor": edition["Flavor"],
					"orientation": edition["Orientation"],
					"parent_orientation_slug": orientation_slug
				}
				cards_db[orientation_slug]["editions"].append(edition_data)
				cards_db[edition["Slug"]] = edition_data
	
	var query2 = """
	SELECT EditionId, OtherOrientationId
	FROM CardEditionOtherOrientations;
	"""
	if db.query(query2):
		for row in db.query_result:
			var edition_slug = get_edition_slug_by_id(row["EditionId"])
			var orientation_slug = get_orientation_slug_by_id(row["OtherOrientationId"])
			if edition_slug and orientation_slug and edition_slug in cards_db and orientation_slug in cards_db:
				pass

func get_orientation_slug_by_id(orientation_id):
	var query = "SELECT Slug FROM CardOtherOrientations WHERE Id = " + str(orientation_id) + ";"
	if db.query(query):
		if db.query_result.size() > 0:
			return db.query_result[0]["Slug"]
	return null

func get_edition_slug_by_id(edition_id):
	for slug in cards_db:
		if cards_db[slug].has("id") and cards_db[slug]["id"] == edition_id:
			return slug
	return null

func get_card_slug_by_id(card_id):
	for slug in cards_db:
		if cards_db[slug].has("id") and cards_db[slug]["id"] == card_id:
			return slug
	return null
