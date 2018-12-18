# Objective C Demo

This project started life as one of Ray Wenderlichs's tutorials: [https://www.raywenderlich.com/2956-how-to-create-a-simple-2d-iphone-game-with-opengl-es-2-0-and-glkit-part-1](https://www.raywenderlich.com/2956-how-to-create-a-simple-2d-iphone-game-with-opengl-es-2-0-and-glkit-part-1)

I'm reimplementing it with WinObjC.

## Style

#### Prefer PascalCase method & property names
Pascal case is easier to read. It also ensure that I don't have name collisions
with the numerous built in method names - for example, a method setPlayer
causes an abend, but SetPlayer is acceptable. It is easy to tell when I'm looking at 
the code where the property/method is defined. PascalCase is mine, camelCase are defined
by the framework.
