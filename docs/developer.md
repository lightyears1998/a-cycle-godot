# For Developer

## Compile / Build

The project leverages some GDExtension add-ons. Those add-ons should be compiled from [source](https://github.com/lightyears1998/a-cycle-gdextension-source).

## Architecture

### Autoloads

We use a lot autoloads in this project.

If we group the autoloads in the same category into a node,
it's going to reduce the number of autoload nodes at the top level.
However, if we do so, it breaks the type hinting in GDScript
and it sounds a bit anti-pattern.
So we will stick to top level autoloads.

---

## Similar projects

- <https://github.com/Mad-Cookies-Studio/mad-productivity>

## Datetime processing

- <https://github.com/ivanskodje-godotengine/godot-plugin-calendar-button>

Related Standards:

- ISO 8601 Timestamp Format <https://en.wikipedia.org/wiki/ISO_8601>
