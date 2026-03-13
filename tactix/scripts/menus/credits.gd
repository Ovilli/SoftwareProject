extends Control

@onready var credits_layer: CanvasLayer = $CreditsLayer
@onready var label: Label = $CreditsLayer/Label
@onready var rich_text_label: RichTextLabel = $CreditsLayer/RichTextLabel

func _ready() -> void:
	label.text = "Credits"
	rich_text_label.text = """

[center][b]Tactix[/b]

[color=gray]Developer[/color]
Minko Gohl , Maxim Zlatin

[color=gray]Art[/color]
Minko Gohl , Maxim Zlatin

[color=gray]Music[/color]
Some random Lofi Website but it was Free

[color=gray]Version[/color]
See Github[/center]

"""

func _process(delta: float) -> void:
	if Windowmng.is_open(Windowmng.Screen.CREDITS):
		credits_layer.show()
	else:
		credits_layer.hide()

func _on_exit_pressed() -> void:
	Windowmng.open(Windowmng.Screen.MAIN_MENU)
