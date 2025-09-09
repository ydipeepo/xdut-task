<br />

English | [日本語](README.ja_JP.md)

<br />

# 🧩 XDUT Task

[![1.5.0-pre](https://badgen.net/github/release/ydipeepo/xdut-task)](https://github.com/ydipeepo/xdut-task/releases/tag/1.5.0-pre1) [![MIT](https://badgen.net/github/license/ydipeepo/xdut-task)](https://github.com/ydipeepo/xdut-task/LICENSE)

This add-on helps pseudo-asynchronous scripting, including a set of classes to handle future-determined values through a shared interface.

```gdscript
func meow() -> void:
	await $MeowButton.pressed
	$MeowButton.disabled = true
	var meow_task := Task.from_conditional_signal(
		$AnimationPlayer.animation_finished,
		["MEOW"])
	$AnimationPlayer.play("MEOW")
	await meow_task.wait()

func woof() -> void:
	await $WoofButton.pressed
	$WoofButton.disabled = true
	var woof_task := Task.from_conditional_signal(
		$AnimationPlayer.animation_finished,
		["WOOF"])
	$AnimationPlayer.play("WOOF")
	await woof_task.wait()

func play_around() -> void:
	var play_around_task := Task.from_conditional_signal(
		$AnimationPlayer.animation_finished,
		["PLAY_AROUND"])
	$AnimationPlayer.play("PLAY_AROUND")
	await play_around_task.wait()
	$MeowButton.disabled = false
	$WoofButton.disabled = false

func _ready() -> void:
	var cancel := Cancel.from_signal($QuitButton.pressed)
	while not cancel.is_requested:
		await Task \
			.all(meow, woof) \
			.then(play_around) \
			.wait(cancel)
```

<br />

## Objective

It was created for the following purposes:

* Transform scripts in callback hell into intuitive flows.
* Make script (with scene) dependencies unidirectional toward the scene.
* Perform safe and unified **await**-ing through a shared interface.

<br />

## Quick start

#### Installation

1. `git clone https://github.com/ydipeepo/xdut-task.git` or [download release](https://github.com/ydipeepo/xdut-task/releases).
2. Then copy `addons/xdut-task` directory into your project.
3. And enable XDUT Task from your project settings.

> [!TIP]
> This add-on is compat with Godot Engine and Redot Engine.
>
> * Godot Engine 4.5 ~ (1.5.0 ~)
> * Redot Engine 4.3 ~ (1.3.0)

<br />

## Reference

📖 [Wiki](https://github-com.translate.goog/ydipeepo/xdut-task/wiki?_x_tr_sl=ja&_x_tr_tl=en) (Google Translated)

<br />

## License

All contents of this project are licensed under the attached 🔗 [MIT](https://github.com/ydipeepo/xdut-task/blob/main/LICENSE) license.

#### Attribution

Attribution is not required, but appreciated. If you would like to credit, please attribute to "Ydi".

<br />
