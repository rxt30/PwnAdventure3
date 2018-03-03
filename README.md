Pwn Adventure 3
===============

Pwn Adventure 3: Pwnie Island is a game developed by [Vector35](https://vector35.com/) ([Binary Ninja](https://binary.ninja)'s devs) for the [Ghost in the Shellcode](http://ghostintheshellcode.com/) 2015 CTF. The game is a first-person, true open-world MMORPG where the player is expected to exploit vulnerabilities in order to finish the quests (and achievements) scattered all over the beautiful island (and beyond). For this, the _hacker_ will have to reverse engineer the network protocol as well as the game logic.

As of now (March 2018), Vector35 still runs a game server so that anyone can play the game online out of the box. Nevertheless, should you want to run your own server (e.g. if the official server is down or you want to run your own local server with you friends), you will find the install guide [here](INSTALL-server.md).

Vector35 offers a [training](https://vector35.com/training.html) based on Pwn Adventure including new challenges. There is also a workshop [[slides](https://www.slideshare.net/AntoninBeaujeant/reverse-engineering-a-mmorpg)] available that covers most of the quests (5/7).


Client installation
-------------------

Make sure your host has the minimum [requirements](http://pwnadventure.com/#downloads).

[Download](http://pwnadventure.com/#downloads) the appropriate client according to your OS. The client is actually a launcher that will download the data files. Once downloaded, you can click "Play" and enjoy the game.

> __note:__ I experience some issues with the macOS version where the screen is completely white unless I press ESC.



Game structure
--------------

The game is structured in 3 parts:

* Client
* Master server
* Game server

> __note:__ The following information is purely build on assumptions and not from the official documentation.


### Client

The client is the game you are running on your computer. It's basically the application responsible render the 3D environment, capturing your mouse and keyboard to move your character, establish the connection to the server, etc.


### Master server

Whenever the user click on "Play game" (online), the client will first establish a connection with the master server. The master server is responsible to store and manage your account:

* Your credentials
* Your characters (name, colour, face, etc)
* Your inventory
* Your team
* Your quests progression
* Your achievement
* The locations you've already visited

So whenever you first authenticate, the master server will verify your credentials then show your characters. Once you decide to join the world of Pwnie Island, the master server will send your inventory, quests, achievement, etc; and redirect you to the game server.


### Game server

The game server is responsible for the instances. In order to avoid having too many players and enemies all together on the same map (instance) - which would not only overload the network traffic and CPU usage of the server but the client as well - the game server will dispatch the players on different game instances. Each instance is managed by one game server. The game server is responsible for keeping track of the players and enemies location on the map. It is also responsible to keep track of the states of the elements (e.g. the dropped loots, switches, enemies and player health/mana, etc).



Reverse network
---------------

### Client <> Game server

The network protocol used between the _client_ and _game server_ has been partially reversed [here](Network/pwn3-gs.md). A Wireshark dissector has been built and is available [here](Network/pwn3-gs.lua). You will also find a Python proxy to intercept and manipulate the communication.


### Client <> Master server

I'm currently working on the reverse of the protocol used between the _client_ and the _master server_. The communication is over SSL, therefore, you first need to load the master key in `Preferences...` > `Protocols` > `SSL` > `RSA keys list` > `Edit`. The key is available:

* Linux: `PwnAdventure3_Data/PwnAdventure3/PwnAdventure3/Content/Server/server.key`
* macOS: `Pwn Adventure 3.app/Contents/PwnAdventure3/PwnAdventure3.app/Contents/UE4/PwnAdventure3/Content/Server/server.key`
* Windows: `PwnAdventure3_Data/PwnAdventure3/PwnAdventure3/Content/Server/server.key`



Reverse binary
--------------

The important file to reverse is the game logic library. This is where all the logic happen, e.g. AI, health/mana management, movement, etc. The library is available:

* Linux: `PwnAdventure3_Data/PwnAdventure3/PwnAdventure3/Binary/Linux/libGameLogic.so`
* macOS: `Pwn Adventure 3.app/Contents/PwnAdventure3/PwnAdventure3.app/Contents/MacOS/GameLogic.dylib`
* Windows: `PwnAdventure3_Data/PwnAdventure3/PwnAdventure3/Binaries/Win32/GameLogic.dll (together with the PDB)`

A binary patcher is available [here](Binary/binpatcher.py) as well as the source code for a hook (Linux - `LD_PRELOAD`) [here](Binary/hook-linux.cc).
