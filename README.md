# electric-mock
## Apple II Electric Duet player for the Mockingboard and the Cricket!

*Electric Duet* is probably the most popular music format in the Apple II world.
Unfortunately the sound quality of the internal speaker of the Apple II does not do much justice to the songs written with ED. On certain Apple II models like the //c the sound circuitry does not cut off the modulation frequency very well producing a high pitched background noise.

This motivated me to write my own routines to play ED songs using a sound card to produce pure tones with much higher quality. I chose the Cricket! because I own one and there is not much software compatible with it. A Mockingboard ED Player is also included for the expandable Apple IIs with a Mockingboard Sound, A or C on Slot 4. 

I wanted to keep the player as small as the original one so that it could be handled the same way. This limited a bit the amount of code that I could use, so even though the Cricket! version is able to play in stereo, the Mockingboard version is not.

A compromise was done for the frequency calculation where only a simple factor is used. A frequency table would have provided more accurate notes, but it would have made the player way bigger, so that it could not be used as a direct replacement.

The src directory includes the original assembly code as made available by [Paul Lutus](https://arachnoid.com/electric_duet/index.html), as well as the commented source in french written by [Deckard](http://boutillon.free.fr). Also a clean crack of the Electric Duet disk including tools for composing original scores is in the dsk directory.

The CRICKETDUET.S and MOCKINGDUET.S sources were assembled with Merlin. The binaries are available in *The Music Disk* image which also includes some classical pieces put together with a nice menu system written by Walt Marcinko Jr.





