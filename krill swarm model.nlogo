turtles-own [
 oxygen ;; krill have oxygen variable
 flockmates ;; agentset of nearby krill
 nearest-neighbor ] ;; closest one of flockmates

patches-own [ water-oxygen ] ;; water has oxygen variable

to setup
  clear-all
  create-turtles population ;; create krill by adjusting population slider, initialize variables
  [ set shape "krill"  ;; krill have shrimp-like shape
    set color orange + 4  ;; krill are reddish orange
    set size 12  ;; easier to see
    set label-color black ;; label is black for visibility, can be turned on or off with switch
    set oxygen random-float 300  ;; give krill random initial level of oxygen,
    ;; greater than or equal to 0 and less than 300 units
    setxy random-xcor random-ycor ;; give krill random initial location
    set flockmates no-turtles ]
  display-labels ;; display label showing initial level of oxygen for krill
  ask patches ;; create patches representing aquatic environment
  [ ifelse random-float 100.0 < percent-low-water-oxygen ;; throw "dice" to see if patches will have low oxygen level
    [ set pcolor blue - 20 ] ;; lighter blue patches have lower initial levels of oxygen
    [ set pcolor blue - 10 ] ] ;; darker blue patches have higher initial levels of oxygen
  ask patches with [ pcolor = blue - 20 ]
  [ set water-oxygen 50  ] ;; lighter blue patches have 50 initial units of oxygen
  ask patches with [ pcolor = blue - 10 ]
  [ set water-oxygen 500 ]  ;; darker blue patches have 500 initial units of oxygen
  reset-ticks
end

  to go
  if not any? turtles [ stop ] ;; simulation will stop when all turtles are dead
  ask turtles
  [ flock ]  ;; krill will flock (swarm)
  repeat 5 [ ask turtles [ fd 0.1 ] display ];; make the turtles animate more smoothly
  ask turtles
  [ set oxygen oxygen - 1  ;; take away a unit of oxygen from flocking movement
    reproduce-krill ;; krill reproduce
    get-oxygen ;; krill add oxygen to initial amount
    check-if-dead  ;; krill checks if dead due to insufficient oxygen
    check-if-water-dead ] ;; patch checks if dead due to insufficient oxygen
  tick ;; a time interval
  display-labels ;; after a time interval update krill oxygen level
end

to reproduce-krill ;; turtle procedure
  if oxygen > reproduction-threshold ;; give birth to a krill if oxygen level greater than birth threshold
  [ set oxygen ( oxygen / 2 ) ;; divide oxygen between parent and offspring
    hatch 1 [ rt random-float 360 fd 1 ] ;; produce an offspring which turns right by random degree and moves forward
]
end
to get-oxygen ;; turtle procedure
  let choice random 2
 (ifelse
   choice = 0 [
    set oxygen oxygen + oxygen-gain  ;; increase krill's oxygen by slider value
    set water-oxygen water-oxygen - oxygen-gain ]  ;; decrease water oxygen on patch by slider value
    choice = 1 [
    set oxygen oxygen + ( oxygen-gain / 2 ) ;; increase krill's oxygen by half slider value
    set water-oxygen water-oxygen - oxygen-gain / 2 ]
  ;; elsecommands
  [ set oxygen oxygen + 0
    set water-oxygen water-oxygen + 0 ])
end

to check-if-dead
  if oxygen < 1 [ die ] ;; krill dies if has less than 2 units of oxygen
end

to check-if-water-dead
  if water-oxygen < 10
  [ die ]
end

to display-labels ;; displays krill energy levels
  ask turtles [ set label "" ]
  if show-oxygen? [
    ask turtles [ set label round oxygen ] ;; if show-oxygen label is on, display labels
  ]
end

;; due to length of full flocking procedure, this code presented after all other procedures above
to flock  ;; turtle procedure
  find-flockmates ;; defined as other turtles within a radius of 5 patches
  if any? flockmates
    [ find-nearest-neighbor
      ifelse distance nearest-neighbor < 1 ;; minimum separation
        [ separate ]
        [ align
        cohere ] ]
end

to find-flockmates  ;; turtle procedure
  set flockmates other turtles in-radius 5 ;; krill has vision of 5 patches
end

to find-nearest-neighbor ;; turtle procedure
  set nearest-neighbor min-one-of flockmates [distance myself] ;; reports a random flockmate with closest distance
end

to separate  ;; turtle procedure
  turn-away ([heading] of nearest-neighbor) 1 ;;max-separate-turn
end

to align  ;; turtle procedure
  turn-towards average-flockmate-heading 5 ;; max-align-turn
end

to-report average-flockmate-heading  ;; turtle procedure
  let x-component sum [dx] of flockmates
  let y-component sum [dy] of flockmates
  ifelse x-component = 0 and y-component = 0
    [ report heading ]
    [ report atan x-component y-component ]
end

to cohere  ;; turtle procedure
  turn-towards average-heading-towards-flockmates  3 ;; max-cohere-turn
end

to-report average-heading-towards-flockmates  ;; turtle procedure
  let x-component mean [sin (towards myself + 180)] of flockmates
  let y-component mean [cos (towards myself + 180)] of flockmates
  ifelse x-component = 0 and y-component = 0
    [ report heading ]
    [ report atan x-component y-component ]
end

;;; HELPER PROCEDURES
to turn-towards [new-heading max-turn]  ;; turtle procedure
  turn-at-most (subtract-headings new-heading heading) max-turn
end
to turn-away [new-heading max-turn]  ;; turtle procedure
  turn-at-most (subtract-headings heading new-heading) max-turn
end
;; turn right by "turn" degrees (or left if "turn" is negative),
;; but never turn more than "max-turn" degrees
to turn-at-most [turn max-turn]  ;; turtle procedure
  ifelse abs turn > max-turn
    [ ifelse turn > 0
        [ rt max-turn ]
        [ lt max-turn ] ]
    [ rt turn ]
end
@#$#@#$#@
GRAPHICS-WINDOW
235
10
740
516
-1
-1
7.0
1
10
1
1
1
0
1
1
1
-35
35
-35
35
1
1
1
ticks
30.0

BUTTON
15
60
78
93
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
97
61
160
94
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
15
18
187
51
population
population
1
1000
26.0
1
1
NIL
HORIZONTAL

PLOT
15
270
215
420
Population over Time
Time
Population
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"default" 1.0 0 -16777216 false "" "plot count turtles"

SLIDER
15
100
212
133
percent-low-water-oxygen
percent-low-water-oxygen
0
100
44.0
1
1
NIL
HORIZONTAL

SWITCH
15
225
147
258
show-oxygen?
show-oxygen?
1
1
-1000

MONITOR
105
440
217
485
count krill
count turtles
17
1
11

SLIDER
15
180
192
213
reproduction-threshold
reproduction-threshold
150
300
150.0
1
1
NIL
HORIZONTAL

SLIDER
15
140
232
173
oxygen-gain
oxygen-gain
0
10
2.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

My model explores the effect of varying oxygen levels in an aquatic environment and other related biological parameters on a population of Antarctic krill.  A krill is a small swimming crustacean that lives in large schools or swarms. Krill are an important part of the marine food chain as a key food source for baleen whales, fish, birds and other marine life. 

My model is inspired by a 2010 paper by Brierley and Cox. The authors state, "Group behavior can be complex, but we have shown here that a simple mechanism, in which individuals within shoals juggle only their access to oxygen-rich water and exposure to predation, can explain observed shoal shape. Decreasing oxygen availability in a warming world ocean may impact shoal structure: because structure affects catchability by predators and fishers, understanding the response will be necessary for ecological and commercial reasons." (p. 1758) My model simulates an interrelationship between oxygen in an aquatic environment and a krill population, a key biological entity in our oceans.

## HOW IT WORKS
The model simulates an aquatic environment with varying levels of oxygen set by a slider. The aquatic environment is composed of patches (a type of agent). The other agents in the model are krill. Krill have their own oxygen level for metabolism and movement. Krill swarm, similar to how birds flock or fish school. This model uses Wilensky's Flocking model code to simulate swarming patterns. Krill use oxygen when they move, which is similar to how wolves and sheep use energy when they move in the Wolf-Sheep Predation model. Krill reproduce if they have a threshold oxygen level because reproduction typically requires more physical capacity. 

After the model starts, krill access additional oxygen based on a slider, which also includes some randomness. In addition, when krill access more oxygen from the water, this procedure decreases the oxygen levels in water patches. Krill die when they have an oxygen level of less than 1 unit. The water or patches die when they have an oxygen level of less than 10 units. The model stops when there are no more living krill. Note that in this model, krill describes both individuals and the swarm, or aggregation of individuals. 

The Interface Tab
When you open the model, you see the Interface tab where you adjust parameters for the model.

Adjust the size of the krill population by using the population slider. You adjust the population size between 1 and 1000 krill. Each krill starts the simulation with a random level of oxygen between 0 and 299 units.

Adjust the PERCENT-LOW-WATER-OXYGEN slider. You adjust the percentage or proportion of low oxygen patches in the water environment from 0 to 100 percent. The model defines a low oxygen environment as 1/10th the level of oxygen in the rest of the environment. If you adjust the PERCENT-LOW-WATER-OXYGEN slider to 5%, then approximately 5% of the total patches consists of low oxygen patches. If you adjust this slider to 100%, all patches have a low oxygen level. 

Adjust the OXYGEN-GAIN. This is a slider that allows krill to add more oxygen to their initial level. To include randomness, the code executes a random choice between adding the oxygen-gain value from the slider, adding only half the oxygen-gain, or if neither of these two choices is executed adding nothing. In addition, when a krill obtains an oxygen increase, it decreases the oxygen level of the water (WATER-OXYGEN).

Adjust the REPRODUCTION-THRESHOLD. This is a slider based on the Wolf-Sheep Predation model. The value is 150 to 300 units, and represents the minimum oxygen level required to reproduce. If the slider is set to 150, then a krill with an oxygen level of 150 or above reproduces. When it reproduces, it will give half of its oxygen to its offspring.

Turn on or off the SHOW-OXYGEN switch. This switch will display a label for each krill with its initial oxygen level. As the model runs, the label will update. You may also wish to run the model with the switch off, as it is easier to see krill movement without labels.

Press the SETUP button.
The world initializes with water and krill. If the slider is set to include low oxygen patches, these patches appear as lighter blue. The rest of the world appears as darker blue patches. The low oxygen patches are dispersed randomly in the world. Krill populate the world in random locations and have an initial random level of oxygen.

Press the GO button to start the model.
Krill FLOCK (swarm). As mentioned previously, the model uses code from Wilensky's Flocking model. The three principle commands for flocking are SEPARATE, ALIGN AND COHERE. Because this model is not primarily concerned with the flocking phenomenon, the code sets values for flocking in the Code tab. Krill use 1 unit of oxygen when they FLOCK.

Krill reproduce if they have a threshold level of oxygen, which is set by the slider between 150 and 300 units of oxygen. A krill needs a relatively high level of oxygen to reproduce. When a krill parent reproduces, it will use half of its oxygen and give it to the krill offspring. 

Krill access oxygen through the GET-OXYGEN procedure. This procedure allows for some oxygen replenishment as krill flock. This procedure is designed with an element of randomness. The model randomly selects one of two choices: 1.) krill will gain an oxygen value by using the slider, or 2.) krill will gain oxygen from the slider value divided by half. If one of the two choices is not selected, krill will not gain any oxygen.

At each time step, krill check if they are dead. Death is defined as an oxygen level less than 1 unit. The model will stop running when all krill are dead. In addition, the water patches will check if they are dead. Death for the water patch is defined as an water-oxygen level less than 10 units.

## THINGS TO NOTICE

As the model runs, observe the aggregate patterns to see krill swarming (Suggest turning OFF the Show-Oxygen switch to see the swarming).  With the Show-Oxygen switch turned on, you see the changing levels of oxygen for each individual krill. Do you notice how the oxygen levels in the environment change over time? You can inspect patches and see how the water-oxygen levels of patches change.

Look at the Population Over Time plot to see how the population size changes. Watch the Count Krill monitor box on the Interface tab to see how the krill population changes. What happens when you change the reproduction threshold to either lower or higher? 

## THINGS TO TRY

Adjust the parameters and see what the outcomes are. Run the model several times to see if and how the outcomes change, even with the same parameters. Remember that this model is stochastic and includes elements of randomness. The model initializes with some random parameters such as location of low oxygen water patches, oxygen levels for krill, and how much oxygen krill can gain. You should run the model many times to see aggregate patterns emerge.


## EXTENDING THE MODEL
To keep this model simple, the model does not include predators such as fish or whales which will eat krill. This predation will affect population size and possibly swarm shape. A potential extension is to include predators and to add predation avoidance behaviors, such as krill moving away from predators and swarming in larger groups or swarms. 

The model does not address herd behaviors in biological literature such as positions within a swarm as protective measures against predators. A potential extension could utilize some type of evolutionary adaption for krill exhibiting certain protective behaviors.

Another possibility for an extension is to create low oxygen areas within specific spatial parameters. The current model will randomly distribute low oxygen areas. In addition, for simplicity krill do not eat but rather depend on oxygen for metabolism and movement. 

This model is a 2-D model. Could you create a 3-D model that models both oxygen levels and some predators in the environment? What patterns or shapes of swarms might result from a 3-D model?


## NETLOGO FEATURES

In Netlogo, the world is comprised of agents. Agents are turtles, patches, links and the observer. This model includes two main types of agents: krill and water. Krill are turtles or mobile agents moving through the world. Water is a patch, which does not move and represents the world, in this case an aquatic environment. This world is a two dimensional toroidal grid with 5,041 patches. The model includes an observer which acts like an invisible overseer for the world.

The model uses a built-in Netlogo feature or primitive called hatch. The hatch command creates new turtles or krill. The krill offspring inherits its variables from its parent, including location. In this model, the offspring obtains half of its parent's oxygen.

Netlogo has a built-in library for turtle shapes such as arrows, bugs, cars, animals, etc. To make a realistic krill shape, this model creator drew a krill shape and included it in the turtle shape library.


## RELATED MODELS

The krill swarm model uses code from Wilensky's Flocking and Wolf-Sheep Predation models referenced below.


## CREDITS AND REFERENCES

This model uses code from Wilensky's Flocking model and Wolf-Sheep Predation models cited below. The model is inspired by the Brierley and Cox paper cited below.

Wilensky, U. (1998). NetLogo Flocking model. http://ccl.northwestern.edu/netlogo/models/Flocking. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Wilensky, U. (1997).  NetLogo Wolf Sheep Predation model.  http://ccl.northwestern.edu/netlogo/models/WolfSheepPredation.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Brierley, A and Cox, M. "Shapes of Krill Swarms and Fish Schools Emerge as Aggregation Members Avoid Predators and Access Oxygen," Current Biology (2010); 20: 1758-1762.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

krill
true
0
Line -2674135 false 195 135 150 105
Line -2674135 false 160 115 225 195
Line -2674135 false 222 188 195 135
Line -2674135 false 170 134 150 135
Line -2674135 false 203 187 197 195
Line -2674135 false 209 181 206 192
Line -2674135 false 195 165 180 180
Line -2674135 false 182 152 174 161
Line -2674135 false 184 151 180 156
Line -2674135 false 173 128 150 135
Line -2674135 false 195 165 195 180
Polygon -2674135 true false 240 135 225 150
Polygon -2674135 true false 240 90 225 120
Line -2674135 false 225 195 240 210
Line -2674135 false 180 150 165 150
Circle -16777216 true false 162 113 2
Circle -16777216 true false 165 120 0
Circle -16777216 true false 165 120 0
Circle -16777216 true false 165 120 0
Circle -16777216 true false 165 120 0

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
