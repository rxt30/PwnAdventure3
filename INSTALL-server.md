Install Pwn Adventure 3 server
==============================

Initial setup
-------------

According to the requirement listed on the official page, you need an [Ubuntu 14.04](http://www.ubuntu.com/download/server) 64-bit with at least 2Go of RAM. I recommend the desktop version since at some point you will have to run the client version in order to get the data (map, texture, game engine, etc) files locally.


> __note:__ Ubuntu 16.04 Server/Desktop works as well

In my case, I installed Ubuntu Desktop VM with 5.5Go of RAM on [VirtualBox](https://www.virtualbox.org/).

You first need to create the user _pwn3_. Once the installation done, you should install the latest updates:

```
sudo apt-get update
sudo apt-get upgrade
```

Then you will need to download both the [server](http://pwnadventure.com/PwnAdventure3Server.tar.gz) and the [Linux client](http://pwnadventure.com/PwnAdventure3_Launcher_Linux.zip) archives and extract them in a new folder `~/PwnAdventure3`:

```
mkdir ~/PwnAdventure3
cd ~/PwnAdventure3

wget http://pwnadventure.com/PwnAdventure3Server.tar.gz
tar zxvf PwnAdventure3Server.tar.gz
mv PwnAdventure3Servers servers

wget http://pwnadventure.com/PwnAdventure3_Launcher_Linux.zip
unzip PwnAdventure3_Launcher_Linux.zip -d client

rm PwnAdventure3Server.tar.gz
rm PwnAdventure3_Launcher_Linux.zip
```

I renamed the folders `servers` and `client` to make things easier for this tutorial.

The downloaded client `~/PwnAdventure3/client/PwnAdventure3` is a actually a launcher to download the data files. If you are in Ubuntu Desktop, you simply need to execute the launcher and wait for the data to download (around 2Go).

```
chmod +x ~/PwnAdventure3/client/PwnAdventure3
~/PwnAdventure3/client/PwnAdventure3
```

If you are using Ubuntu Server and don't have a graphical interface, you will have to run the game in another Linux VM then transfer (e.g. `scp`) the folder to the server. Or you can download the prepared ZIP file [here](https://mega.nz/#!F6gD3Q7T!62twFUeWI123gRf9NpPn0WSxLoRzNppzq8s2ouereCQ) (08/10/2017).


Initialise the database
-----------------------

Now let's install [PostgreSQL](https://www.postgresql.org). By default `psql` is is not installed on Ubuntu 14.04 Desktop.

```
sudo apt-get install postgresql
```

PostgreSQL is used to store the team, the players, items, etc. According to the official Pwn Adventure 3 install README, the servers requires the following setup:

* postgresql installed
* A Unix user account on the postgres database, password accounts are not supported
* A database called "master" on which the Unix user account has access for creating and modifying tables</li>

In order to create the user and the table, we first need to switch to the `postgres` user:

```
su -
su postgres

# template1 is the default source database name for CREATE DATABASE
psql template1

# We create user "pwn3" without password
# Note: You just need to type "CREATE USER pwn3;"
template1=# CREATE USER pwn3;

# We create the database "master"
template1=# CREATE DATABASE master;

# We grant all privileges on "master" to "pwn3"
template1=# GRANT ALL PRIVILEGES ON DATABASE master TO pwn3;

# Quit the psql interface
template1=# \q
```

You are still authenticated as `postgres`, so now you need to get back to your pwn3 user:

```
# Get back to root
exit

# Get back to pwn3
exit
```

Just to make sure everything went as expected, you can try to access the database "master" with the user "pwn3":

```
psql -d master -U pwn3
```

If this works, you can leave the psql console (`\q`). Now let's initialise the master database. A SQL script is available in the server folder:

```
psql master -f ~/PwnAdventure3/servers/MasterServer/initdb.sql
```

This will create all tables and populate the database. If you want to change the greetings message when you start the game, you can either change the two last line of `initdb.sql`, or you can run the following comment:

```
psql -d master -U pwn3

master=# UPDATE info SET contents='My custom server' WHERE name='login_title';
master=# UPDATE info SET contents='Hello everyone and welcome to my customer server!' WHERE name='login_text';
```


Configure the Master Server
---------------------------

The first thing to do is to create a server account so that the _game servers_ can be authenticate on the master servers:

```
cd ~/PwnAdventure3/servers/MasterServer/
./MasterServer --create-server-account
```

A username and a password will be generated for you. Those credentials will be used to configure the _game server_ later on so keep these values somewhere. In our case, the credentials are:

```
Username: server_5451700dc668731a
Password: a29eb785c128a76ef45e1543
```

The next step is to create the admin team. As an admin, you will be able to teleport to regions and give items using an in-game console command. The command to create an admin team is:

```
# Change "WeAreRoot" with the name you want for the admin team
cd ~/PwnAdventure3/servers/MasterServer/
./MasterServer --create-admin-team WeAreRoot
```

This command will give you the team hash. Whenever you create a new player account in the game, you will asked to enter a team hash. If you want to create a new team, leave the field empty. At the end of the registration, you will receive a new team hash to share with your friends so that they can join your new team. If you want to be admin, you will have to enter the team hash generated in this last command.

You should now be all set to start your _master server_:

```
cd ~/PwnAdventure3/servers/MasterServer/
./MasterServer
```

You shouldn't see any error message or debug message. You can also run `netstat` to make sure the master server is listening on port 3333 on all interface:

```
$ netstat -plnt

Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
...      
tcp        0      0 0.0.0.0:3333            0.0.0.0:*               LISTEN      2853/MasterServer
...
```

Once done, you can stop the _master server_ by pressing `Ctrl + C`.


Configure the Game Server
-------------------------

The _master server_ is ready, now let's configure the _game servers_. First, move the PwnAdventureServer in the Linux binary folder:

```
mv ~/PwnAdventure3/servers/GameServer/PwnAdventure3Server
~/PwnAdventure3/client/PwnAdventure3_Data/PwnAdventure3/PwnAdventure3/Binaries/Linux/
```

Now a little bit a cleanup:

```
mv ~/PwnAdventure3/client/* ~/PwnAdventure3/servers/GameServer/
rmdir ~/PwnAdventure3/client/
```

Then you will need to change the _game servers_ config file to point to your _master server_:


```
vi ~/PwnAdventure3/servers/GameServer/PwnAdventure3_Data/PwnAdventure3/PwnAdventure3/Content/Server/server.ini
```

> __note:__ Use nano or your favourite text editor if you don't feel comfortable with `vi`

Since my _game servers_ will run on the same machine as my _master server_, I can configure the master servers's hostname to localhost. However, the hostname of the game server will be forwarded to the client, therefore, we will set a custom hostname the we will later add on the client's `/etc/hosts` file.

For the game server username and password, use the credentials generated earlier (`./MasterServer --create-server-account`).

Based on the recommendation from the official README, I decided to limit the amount of instances to 5. Here is the final content of my `server.ini` file:

```
[MasterServer]
Hostname=localhost
Port=3333

[GameServer]
Hostname=pwn3.server
Port=3000
Username=server_5451700dc668731a
Password=a29eb785c128a76ef45e1543
Instances=5
```


Start your server
-----------------

That's it, now you can run your freshly configured server. You will need to run the MasterServer from its folder otherwise you will have an issue with the certificate:

```
cd ~/PwnAdventure3/server/MasterServer/
./MasterServer

# Open a new terminal
cd ~/PwnAdventure3/servers/GameServer/PwnAdventure3_Data/PwnAdventure3/PwnAdventure3/Binaries/Linux/
./PwnAdventure3Server
```

Instead of running the master and game server separately, you can use the following script:

```
(cd ~/PwnAdventure3/server/MasterServer/ &amp;&amp; ./MasterServer) & (cd ~/PwnAdventure3/client/PwnAdventure3_Data/PwnAdventure3/Binaries/Linux/ && ./PwnAdventure3Server)
```


Configure your client
---------------------

On your client (i.e. the computer you will use to play the game) download the [client archive](http://pwnadventure.com/#downloads), extract the archive and run the executable. Here again, it will download the data file (about 2Go). Once done, you can close launcher and edit the `server.ini` file available here:

* Linux: `PwnAdventure3_Data/PwnAdventure3/PwnAdventure3/Content/Server/server.ini`
* macOS: `Pwn\ Adventure\ 3.app/Contents/PwnAdventure3/PwnAdventure3.app/Contents/UE4/PwnAdventure3/Content/Server/server.ini`
* Windows: `PwnAdventure3_Data/PwnAdventure3/PwnAdventure3/Content/Server/server.ini`

Here we want to point the master server to our server instead of the official one. For this, we will replace the `Hostname` value of the `[MasterServer]` to `pwn3.server`:

```
[MasterServer]
Hostname=pwn3.server
Port=3333
```

> __note:__ You can remove the `[GameServer]` part

Almost done, now we need to add a line in our client's `hosts` file to redirect the hostname `pwn3.server` to our master/game server.

* Linux: `/etc/hosts`
* macOS: `/etc/hosts`
* Windows: `C:/Windows/System32/Drivers/etc/hosts`

> __note:__ You need to be sudo/administrator to edit this file

For instance, if you server has the IP `192.168.1.11`, you can add the following line:

```
192.168.1.11    pwn3.server
```

Now you should be good to play!
