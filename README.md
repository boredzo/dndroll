# dndroll
## Dice simulator for the command line

I needed (actually still need, as I write this) to roll up stats for a D&D character, so I wrote this program to help me do it.

Arguments are any combination of:

- a single number, such as “8”
- a dice descriptor, such as “2d6”
- a dice descriptor followed immediately by “-lowest” (read as “minus lowest”), such as “4d6-lowest”, which will exclude one die with the lowest rolled value
- a dice descriptor followed immediately by “-highest” (read as “minus highest”), such as “4d6-highest”, which will exclude one die with the lowest rolled value
- the above, joined by +, such as “1d10+4”
- the above, prefixed by +, such as “+7+1d4”
- the word “selftest”, for examining how good the randomness is
