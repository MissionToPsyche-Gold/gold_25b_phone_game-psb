class_name Callsigns
extends RefCounted
## Ready-made player names (sponsor request, Nov 2026). Players pick one of
## these instead of typing a nickname, so nobody can enter something
## inappropriate. Every name comes from the Psyche mission or space science
## and is suitable for middle and high school students.
## Rules (checked by test TC-002): unique, 1-20 characters, letters/spaces/hyphens.

const NAMES: Array[String] = [
	"Metal Core",        # Psyche may be part of a planet's metal core
	"Solar Array",       # the spacecraft's cross-shaped solar arrays
	"Xenon Thruster",    # Hall-effect thrusters push out xenon gas
	"Blue Glow",         # the thrusters leave a blue glow
	"Asteroid Belt",     # Psyche orbits in the main asteroid belt
	"Mars Flyby",        # the 2026 gravity assist from Mars
	"Gravity Assist",
	"Falcon Heavy",      # the rocket that launched Psyche
	"Mission Control",
	"Deep Space",
	"Laser Link",        # DSOC laser communications test
	"Magnetometer",      # science instruments on board
	"Spectrometer",
	"Star Tracker",
	"Planetesimal",      # an early building block of planets
	"Iron-Nickel",       # metals expected on Psyche
	"Metal World",       # "A Journey to a Metal World"
	"Space Pioneer",
	"Orbit Explorer",
	"Comet Chaser",
	"Nova Navigator",
	"Galaxy Guide",
	"Rocket Ranger",
	"Cosmic Scout",
]


## The names not in `taken`, in list order.
static func available(taken: Array) -> Array[String]:
	var out: Array[String] = []
	for n in NAMES:
		if not taken.has(n):
			out.append(n)
	return out


## `count` different names chosen at random.
static func random_distinct(count: int) -> Array[String]:
	var pool: Array[String] = NAMES.duplicate()
	pool.shuffle()
	return pool.slice(0, mini(count, pool.size()))
