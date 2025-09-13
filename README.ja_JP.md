<br />

[English](README.md) | 日本語

<br />

# ![XDUT Task](assets/texture/icon.png) XDUT Task

[![Release](https://badgen.net/github/release/ydipeepo/xdut-task)](https://github.com/ydipeepo/xdut-task/releases) [![MIT](https://badgen.net/github/license/ydipeepo/xdut-task)](https://github.com/ydipeepo/xdut-task/LICENSE)

将来決まる値を共通のインターフェイスを通して扱うためのクラスセットを含む、GDScript 非同期的スクリプティングを補助するためのアドオンです。

```gdscript
var result = await Task.wait_all(
	my_method,
	my_signal,
	Task.any(
		my_another_method,
		my_another_signal))
```

<br />

## 目的

以下の目的のために作りました:

* コールバック地獄のスクリプトを直感的なフローで表現できるよう変形する。
* スクリプト (とシーン) の依存関係をシーンに対する一方向にまとめる。
* 共通の `Task` インターフェイスを通して安全で統一された待機を行う。

<br />

## 使い方

#### アドオンの追加

1. `git clone https://github.com/ydipeepo/xdut-task.git` もしくは、[ダウンロード](https://github.com/ydipeepo/xdut-task/releases)し、
2. `addons/xdut-task` をプロジェクトにコピーし、
3. プロジェクト設定から XDUT Task を有効にします。

#### リファレンス

📖 [Wiki](https://github.com/ydipeepo/xdut-task/wiki) にまとめてあります。

<br />

## ライセンス

🔗 [MIT](https://github.com/ydipeepo/xdut-task/blob/main/LICENSE) ライセンスです。

#### 表記

ライセンスの表記は必須ではありませんが、歓迎いたします。クレジットする場合は、"Ydi" に帰属させてください。

<br />
