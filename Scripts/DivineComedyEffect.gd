class_name DivineComedyEffect

const BASE_SLUG := "divine-comedy-prd"
const PAGE_SUFFIX := "-p"
const MAX_PAGE := 4
const MAINFIELD_ONLY := true

const COVER_EFFECT := "[Dante Bonus] (4): Activate this ability only once per turn, and only at slow speed. This ability costs (4) less to activate the first time you activate it. This ability’s activation can’t be negated. Cascade— (Each page represents one effect of the cascade ability.)"
const PAGE_EFFECTS := {
	1: "• 1 — Until the beginning of your next turn, your opponents can’t activate cards with an even reserve cost. (Zero is considered even.)",
	2: "• 2 — As a Spell, destroy target non-champion object. When that object is destroyed this way, recover 4.",
	3: "• 3 — Until the beginning of your next turn, your opponents can’t activate cards with an even reserve cost. (Zero is considered even.)",
	4: "• 4 — Remove all damage counters from your champion, then deal 20+X unpreventable damage to each champion your opponents control, where X is ten times the amount of damage counters removed this way.",
}

static var is_executing_effect := false

static func is_multitransform_slug(slug: String) -> bool:
	return Gimmicks.condition_multitransform_slug(slug, BASE_SLUG, PAGE_SUFFIX, MAX_PAGE)

static func get_cover_slug(slug: String) -> String:
	return Gimmicks.find_multitransform_cover_slug(slug, BASE_SLUG, PAGE_SUFFIX, MAX_PAGE)

static func get_multitransform_target(slug: String) -> String:
	return Gimmicks.find_multitransform_target_slug(slug, BASE_SLUG, PAGE_SUFFIX, MAX_PAGE)

static func get_hardcoded_effect(slug: String) -> String:
	var page := Gimmicks.find_multitransform_page(slug, BASE_SLUG, PAGE_SUFFIX, MAX_PAGE)
	if page <= 0:
		return COVER_EFFECT
	return str(PAGE_EFFECTS.get(page, COVER_EFFECT))

static func can_multitransform(card) -> bool:
	if is_executing_effect:
		return false
	return Gimmicks.condition_multitransform_can_apply(card, BASE_SLUG, PAGE_SUFFIX, MAX_PAGE, MAINFIELD_ONLY)

static func apply_multitransform(card) -> void:
	if is_executing_effect:
		return
	if not Gimmicks.condition_multitransform_can_apply(card, BASE_SLUG, PAGE_SUFFIX, MAX_PAGE, MAINFIELD_ONLY):
		return
	var old_slug := str(card.get_meta("slug")) if card.has_meta("slug") else ""
	var new_slug := get_multitransform_target(old_slug)
	if new_slug == "":
		return
	is_executing_effect = true
	Gimmicks.gimmick_apply_multitransform(card, old_slug, new_slug)
	is_executing_effect = false
