<br />

# Godot Task

[![Release](https://badgen.net/github/release/ydipeepo/godot-task)](https://github.com/ydipeepo/godot-task/releases) [![MIT](https://badgen.net/github/license/ydipeepo/godot-task)](https://github.com/ydipeepo/godot-task/LICENSE)

This add-on helps GDScript pseudo-asynchronous scripting, including a set of classes to handle future-determined values through a shared interface.

```gdscript
var result = await Task.wait_all(
	my_method,
	my_signal,
	Task.any(
		my_another_method,
		my_another_signal))
```

<br />

## Objective

It was created for the following purposes:

* Transform scripts in callback hell into intuitive flows.
* Make script (with scene) dependencies unidirectional toward the scene.
* Perform safe and unified **await**-ing through a shared `Task` interface.

<br />

## License

All contents of this project are licensed under the attached 🔗 [MIT](https://github.com/ydipeepo/godot-task/blob/main/LICENSE) license.

#### Attribution

Attribution is not required, but appreciated. If you would like to credit, please attribute to "Ydi".

<br />
