# CopyCoords Resource

CopyCoords is a simple FiveM resource that allows you to display the co-ordinates of your player, or copy them to your clipboard in a variety of ways. This is a very useful resource designed to save time when developing new FiveM Resources.

# PassionRP Community
[Discord Invite Link](https://discord.gg/passionrp) 

## Usage

| Command | Arguments | Description |
| :----------: | :-----------: | :------------: |
| copycoords | decimal-places (optional) | Copies the coords in their default structure, rounded to the given number of decimal places. The format this outputs is: `x, y, z, h`. |
| copycoords-prefixed | decimal-places (optional) | Copies the coords in a prefixed structure, rounded to the given number of decimal places. The format this outputs is: `x = x, y = y, z = z, h = h`. |
| copycoords-xyz | decimal-places (optional) | Copies the coords in the structure required for the `/tp` command. The format this outputs is: `x y z`. |
| copycoords-custom | decimal-places (required), template (required, replaces instances of `:x`, `:y`, `:z`, `:h`) | Copies the coords in the given template, example: `/copycoords 2 'x is :x and the heading is :h` returns `'x is 1.11 and the heading is 1.11`. |
| showcoords | none | Displays my current coords at the top of the screen |

## copycoords-custom command and its usefulness

This is by far the most useful command for developers. Here are some examples.

> I'm creating a config file for one of my resources, which needs a table of x/y/z/h coords.

```lua
_Config = {
    coords = {
        {x = 1000.1234, y = 2000.2345, z = 3000.3456, h = 180},
    }
}
```

> I want to go to several locations in the map, in-game and get the co-ordinates of said locations for my Config file.

> I run to a location and run this command:

```
/copycoords-custom 3 "{x = :x, y = :y, z = :z, h = :h},"
```

> Assuming my x/y/z/h coords are 1.11111, 2.222222, 3.333333, 4.444444, this will copy the following to my clipboard:
```
{x = 1.111, y = 2.222, z = 3.333, h = 4.444},
```

> With this, I just paste it into the config file, go to my next location and tab up to the same command again, paste it, move on etc.
