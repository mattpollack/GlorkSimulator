# Glork Simulator

https://mattpollack.itch.io/glork-simulator

Glork simulator is an alien invasion style game where the player is a "glork", a species of planet devouring tentacle beasts, whose main profession is the takeover and selling of planets. The game loop involves landing on unsuspecting planets then 	devouring its inhabitants, infrastructure, and military, all while growing in size until the player is large enough to consume the planet entirely. Mass represents health, upgrade costs, reach, as well as the main winning condition, which is accumulated proportionally to what the player devours. When a planet is consumed, its value is scored and added to the players total. For each planet consumed, subsequent planets are alerted, making each consumption harder. 

### Mass 

The primary game resource which affects: health, upgrades, reach, and triggers the main winning condition once at a certain amount. Reaching 0 mass triggers a loss. The players size naturally increases with mass. Being hit my bullets, bombs, lasers, etc causes mass to be lost.

### Upgrades

There are 3 upgrades: number of tentacles, speed of movement and tentacles, and durability. These upgrades cost mass, so spending mass reduces the players size. The costs of these upgrades get exponentially bigger as the player buys them. 

### Planets

Planets are procedurally generated with cities and buildings, which act as easy to destroy and consume targets.  

### Military

As the players mass grows, so does the planets military strength. Here are units in escalating difficulty:
	
- Innocent bystander, does no damage just runs away, slow
- Tank, follows the player at a range, medium range, does low damage, slow
- Jet, orbits the planet, does medium damage, medium range, very fast
- Laser Satellite, orbits the planet, does high damage, has a high range, medium speed
- Nuclear bomb, launches from random points on the planet, does enormous damage, has infinite range, slow speed 

### TODOs

```

Planet coloring 

Head clipping 

Going under buildings, body collision

"wanted level"

FIX THE LASER | DON'T MAKE IT A PROJECTILE

cranes 

```
