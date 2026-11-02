# guide.gd
extends Control

var pages: Array = [
	"Ты паразит. Ты живёшь внутри хозяина и растёшь за его счёт.\n\nДорасти колонию до нужного размера, и ты перейдёшь к следующему. Колония остаётся с тобой.",
	"Каждый ход выбери карты паразитов (сначала две) и нажми «ЗАКОНЧИТЬ ХОД».\n\nПотом выбери, куда их поселить: в голову, тело или ноги.",
	"Колония в голове растёт быстрее всего, но сильнее всего вредит хозяину. Ноги почти безопасны, но растут медленно. Тело что-то среднее между ними.\n\nУ каждого паразита есть любимая зона. В ней он плодится лучше. Подсказка спрятана в описании карты.",
	"Если здоровье хозяина упадёт до нуля, ты умрёшь вместе с ним.\n\nСледи за его мыслями. Он чувствует тебя. Он медленно умирает извнутри.",
	"И помни: до конца развитии колонии хозяин обязан остаться в живых.\n\nесли он умрёт под конец развития колонии, то это уже его проблемы. Чем больше паразитов, тем быстрее он умирает."
]
onready var texture_rect = $vbox/TextureRect
onready var label = $vbox/Label
onready var button = $vbox/Button
onready var guidebutton = $"../guidebutton"

var currentPageIndex: int = 0


func _ready():
	guidebutton.connect("pressed", self, "_on_guidebutton_pressed")
	button.connect("pressed", self, "_on_button_pressed")
	
	if Global.currentLandlordIndex != 0:
		hide()
		return
	
	show()
	label.text = pages[0]

func _on_button_pressed():
	currentPageIndex += 1
	
	if pages.size() < currentPageIndex+1:
		currentPageIndex = 0
		label.text = pages[0]
		hide()
	
	label.text = pages[currentPageIndex]

func _on_guidebutton_pressed():
	show()
