<br />

[English](README.md) | 日本語

<br />

# 🧩 XDUT Task

[![1.5.0-pre](https://badgen.net/github/release/ydipeepo/xdut-task)](https://github.com/ydipeepo/xdut-task/releases/tag/1.5.0-pre1) [![MIT](https://badgen.net/github/license/ydipeepo/xdut-task)](https://github.com/ydipeepo/xdut-task/LICENSE)

将来決まる値を共通のインターフェイスを通して扱うためのクラスセットを含む、非同期的スクリプティングを補助するためのアドオンです。

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

## 目的

以下の目的のために作りました:

* コールバック地獄のスクリプトを直感的なフローで表現できるよう変形する。
* スクリプト (とシーン) の依存関係をシーンに対する一方向にまとめる。
* 共通のインターフェイスを通して安全で統一された待機を行う。

<br />

## インストール

#### デモを確認する

1. `git clone https://github.com/ydipeepo/xdut-task.git` もしくは、[ダウンロード](https://github.com/ydipeepo/xdut-task/releases)し、
2. プロジェクトを開いて実行します。

#### アドオンを追加する

1. `git clone https://github.com/ydipeepo/xdut-task.git` もしくは、[ダウンロード](https://github.com/ydipeepo/xdut-task/releases)し、
2. `addons/xdut-task` をプロジェクトにコピーし、
3. プロジェクト設定から XDUT Task を有効にします。

> [!TIP]
> このアドオンは Godot Engine 及び Redot Engine に対応しています。
>
> * Godot Engine 4.5 ~ (1.5.0 ~)
> * Redot Engine 4.3 ~ (1.3.0)

<br />

## リファレンス

📖 [Wiki](https://github.com/ydipeepo/xdut-task/wiki) にまとめてあります。

<br />

## ライセンス

🔗 [MIT](https://github.com/ydipeepo/xdut-task/blob/main/LICENSE) ライセンスです。

#### 表記

ライセンスの表記は必須ではありませんが、歓迎いたします。クレジットする場合は、"Ydi" に帰属させてください。

<br />
