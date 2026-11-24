class_name AboutInfo
extends RefCounted
## Text for the About page: the team, what the game is, and the Psyche
## mission. Mission facts come from the NASA Psyche Press Kit (September 2023).

const TEAM: Array[String] = [
	"Ella Mariani",
	"Sanjith Varathan",
	"Savannah Wilhelm",
	"Gerardo Saca",
]
const TEAM_NOTE := "Software Engineering students, Penn State World Campus"

const PROJECT := "Cosmic Quest: Psyche is a pass-and-play trivia game for 2 to 4 players sharing one phone. Take turns answering questions about NASA's Psyche mission, protect your lives, and win bonus challenges along the way. We made it as our capstone project with the Psyche Student Collaborations program to help middle and high school students learn about space science."

const MISSION := "Psyche is a metal-rich asteroid in the main asteroid belt between Mars and Jupiter. Scientists think it may be part of the metal core of a planetesimal, an early building block of planets. NASA's Psyche spacecraft launched in October 2023, flies past Mars in 2026 for a gravity boost, and is expected to reach the asteroid in 2029. Studying Psyche may help us learn how planets like Earth formed."

const REFERENCE := "Jet Propulsion Laboratory. (n.d). Psyche press kit. Retrieved November 24, 2026, from https://www.jpl.nasa.gov/press-kits/psyche/ \n
					Jet Propulsion Laboratory. (n.d). Quick facts. Retrieved November 24, 2026, from https://www.jpl.nasa.gov/press-kits/psyche/quick-facts/ \n
					Jet Propulsion Laboratory. (n.d). Mission. Retrieved November 24, 2026, from https://www.jpl.nasa.gov/press-kits/psyche/mission/ \n
					Jet Propulsion Laboratory. (n.d). Science. Retrieved November 24, 2026, from https://www.jpl.nasa.gov/press-kits/psyche/mission/science/ \n
					Jet Propulsion Laboratory. (n.d). Spacecraft. Retrieved November 24, 2026, from https://www.jpl.nasa.gov/press-kits/psyche/mission/spacecraft/ \n
					Jet Propulsion Laboratory. (n.d). Planetary protection. Retrieved November 24, 2026, from https://www.jpl.nasa.gov/press-kits/psyche/mission/planetary-protection/ \n
					Jet Propulsion Laboratory. (n.d). Deep space optical communications (DSOC). Retrieved November 24, 2026, from https://www.jpl.nasa.gov/press-kits/psyche/dsoc/"

const DISCLAIMER := "This work was created in partial fulfillment of Penn State University Capstone Course \"SWENG 480\\481\". The work is a result of the Psyche Student Collaborations component of NASA’s Psyche Mission (https://psyche.ssl.berkeley.edu). “Psyche: A Journey to a Metal World” [Contract number NNM16AA09C] is part of the NASA Discovery Program mission to solar system targets. Trade names and trademarks of ASU and NASA are used in this work for identification only. Their usage does not constitute an official endorsement, either expressed or implied, by Arizona State University or National Aeronautics and Space Administration. The content is solely the responsibility of the authors and does not necessarily represent the official views of ASU or NASA."
