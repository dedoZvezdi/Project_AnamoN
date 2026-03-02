extends Node

var db
var cards_db = {}

func _ready():
	initialize_database()
	load_all_cards_data()

func initialize_database():
	db = SQLite.new()
	db.path = "res://Data/SQLite.db"
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
	var query = """
	SELECT cl.Id, c.Slug 
	FROM CardLegality cl
	JOIN Cards c ON c.Id = cl.CardId;
	"""
	if db.query(query):
		for row in db.query_result:
			var card_slug = row["Slug"]
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
				"limit": row["LimitValue"]})
		for card_slug in cards_db:
			for legality in cards_db[card_slug]["legalities"]:
				if formats_by_legality.has(legality["legality_id"]):
					legality["formats"] = formats_by_legality[legality["legality_id"]]

func load_card_classes():
	var query = """
	SELECT c.Slug, cl.Class 
	FROM CardClasses cl
	JOIN Cards c ON c.Id = cl.CardId;
	"""
	if db.query(query):
		for row in db.query_result:
			var card_slug = row["Slug"]
			if card_slug and card_slug in cards_db:
				cards_db[card_slug]["classes"].append(row["Class"])

func load_card_types():
	var query = """
	SELECT c.Slug, ct.Type 
	FROM CardTypes ct
	JOIN Cards c ON c.Id = ct.CardId;
	"""
	if db.query(query):
		for row in db.query_result:
			var card_slug = row["Slug"]
			if card_slug and card_slug in cards_db:
				cards_db[card_slug]["types"].append(row["Type"])

func load_card_subtypes():
	var query = """
	SELECT c.Slug, cs.Subtype 
	FROM CardSubtypes cs
	JOIN Cards c ON c.Id = cs.CardId;
	"""
	if db.query(query):
		for row in db.query_result:
			var card_slug = row["Slug"]
			if card_slug and card_slug in cards_db:
				cards_db[card_slug]["subtypes"].append(row["Subtype"])

func load_card_elements():
	var query = """
	SELECT c.Slug, ce.Element 
	FROM CardElements ce
	JOIN Cards c ON c.Id = ce.CardId;
	"""
	if db.query(query):
		for row in db.query_result:
			var card_slug = row["Slug"]
			if card_slug and card_slug in cards_db:
				cards_db[card_slug]["elements"].append(row["Element"])

func load_editions():
	var query = """
	SELECT ce.Id, ce.CardEditionId, ce.Slug, ce.Effect, ce.EffectRaw, ce.Flavor, ce.Orientation, c.Slug AS CardSlug
	FROM CardEditions ce
	JOIN Cards c ON c.Id = ce.CardId;
	"""
	if db.query(query):
		for edition in db.query_result:
			var card_slug = edition["CardSlug"]
			if card_slug and card_slug in cards_db:
				var edition_data = {
					"id": edition["Id"],
					"slug": edition["Slug"],
					"edition_id": edition["CardEditionId"],
					"effect": edition["Effect"],
					"effect_raw": edition["EffectRaw"],
					"flavor": edition["Flavor"],
					"orientation": edition["Orientation"],
					"other_orientations": []}
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
				"editions": []}

func load_orientation_classes():
	var query = """
	SELECT co.Slug, coc.Class 
	FROM CardOtherOrientationClasses coc
	JOIN CardOtherOrientations co ON co.Id = coc.OtherOrientationId;
	"""
	if db.query(query):
		for row in db.query_result:
			var orientation_slug = row["Slug"]
			if orientation_slug and orientation_slug in cards_db:
				cards_db[orientation_slug]["classes"].append(row["Class"])

func load_orientation_types():
	var query = """
	SELECT co.Slug, cot.Type 
	FROM CardOtherOrientationTypes cot
	JOIN CardOtherOrientations co ON co.Id = cot.OtherOrientationId;
	"""
	if db.query(query):
		for row in db.query_result:
			var orientation_slug = row["Slug"]
			if orientation_slug and orientation_slug in cards_db:
				cards_db[orientation_slug]["types"].append(row["Type"])

func load_orientation_subtypes():
	var query = """
	SELECT co.Slug, cos.Subtype 
	FROM CardOtherOrientationSubtypes cos
	JOIN CardOtherOrientations co ON co.Id = cos.OtherOrientationId;
	"""
	if db.query(query):
		for row in db.query_result:
			var orientation_slug = row["Slug"]
			if orientation_slug and orientation_slug in cards_db:
				cards_db[orientation_slug]["subtypes"].append(row["Subtype"])

func load_orientation_elements():
	var query = """
	SELECT co.Slug, coe.Element 
	FROM CardOtherOrientationElements coe
	JOIN CardOtherOrientations co ON co.Id = coe.OtherOrientationId;
	"""
	if db.query(query):
		for row in db.query_result:
			var orientation_slug = row["Slug"]
			if orientation_slug and orientation_slug in cards_db:
				cards_db[orientation_slug]["elements"].append(row["Element"])

func load_orientation_editions():
	var query = """
	SELECT coe.Id, coe.Slug, coe.CardEditionId, coe.Effect, coe.EffectRaw, coe.Flavor, coe.Orientation, co.Slug AS OrientationSlug
	FROM CardOtherOrientationEditions coe
	JOIN CardOtherOrientations co ON co.Id = coe.OtherOrientationId;
	"""
	if db.query(query):
		for edition in db.query_result:
			var orientation_slug = edition["OrientationSlug"]
			if orientation_slug and orientation_slug in cards_db:
				var edition_data = {
					"id": edition["Id"],
					"slug": edition["Slug"],
					"edition_id": edition["CardEditionId"],
					"effect": edition["Effect"],
					"effect_raw": edition["EffectRaw"],
					"flavor": edition["Flavor"],
					"orientation": edition["Orientation"],
					"parent_orientation_slug": orientation_slug}
				cards_db[orientation_slug]["editions"].append(edition_data)
				cards_db[edition["Slug"]] = edition_data
	
	var query2 = """
	SELECT ce.Slug AS EditionSlug, co.Slug AS OrientationSlug
	FROM CardEditionOtherOrientations cee
	JOIN CardEditions ce ON ce.Id = cee.EditionId
	JOIN CardOtherOrientations co ON co.Id = cee.OtherOrientationId;
	"""
	if db.query(query2):
		for row in db.query_result:
			var edition_slug = row["EditionSlug"]
			var orientation_slug = row["OrientationSlug"]
			if edition_slug and orientation_slug and edition_slug in cards_db and orientation_slug in cards_db:
				if cards_db[edition_slug].has("other_orientations"):
					cards_db[edition_slug]["other_orientations"].append(orientation_slug)
