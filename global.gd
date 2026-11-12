# global.gd
extends Node

var ver: String = "ver1t1"


var turns: int = 0
var health: int = 100
var maxCards: int = 0
var guideWatched: bool = true
var deck: Array = []
var parasitedLandlords: int = 0

var nColony: int = 0
var headColony: int = 0
var bodyColony: int = 0
var legsColony: int = 0

enum Place { HEAD = 1, BODY, LEGS }
var currentLandlordIndex: int = 0

var defaultCards: Array = [
	{"name": "Кордицепс", "desc": "Дёргает за ниточки твоего сознания.", "texture": "res://sprites/cards/cordiceps_card_1.png", "bestPlace": Place.HEAD},
	{"name": "Глазной червь", "desc": "Прогуливается по глазному яблоку.", "texture": "res://sprites/cards/eye_parasite_card_1.png", "bestPlace": Place.HEAD},
	{"name": "Язычная вошь", "desc": "Заменяет язык. Без шуток.", "texture": "res://sprites/cards/tongue_parasite_card_1.png", "bestPlace": Place.HEAD},
	{"name": "Демодекс", "desc": "Живёт у корня ресницы. Ты её даже не заметишь.", "texture": "res://sprites/cards/demodex_card_1.png", "bestPlace": Place.HEAD},
	
	{"name": "Ленточный червь", "desc": "Много ест. Очень.", "texture": "res://sprites/cards/tapeworm_card_1.png", "bestPlace": Place.BODY},
	{"name": "Личинка осы", "desc": "Прячется, потом вылупляется в организме.", "texture": "res://sprites/cards/wasp_larva_card_1.png", "bestPlace": Place.BODY},
	{"name": "Сердечный червь", "desc": "Поселяется в сердце.", "texture": "res://sprites/cards/heart_parasite_card_1.png", "bestPlace": Place.BODY},
	{"name": "Малярия", "desc": "Приезжает на комаре, живёт в крови.", "texture": "res://sprites/cards/malaria_card_1.png", "bestPlace": Place.BODY},
	
	{"name": "Ришта", "desc": "Выходит через ногу. Медленно.", "texture": "res://sprites/cards/rista_card_1.png", "bestPlace": Place.LEGS},
	{"name": "Песчаная блоха", "desc": "Вгрызается в пальцы ног.", "texture": "res://sprites/cards/sand_parasite_card_1.png", "bestPlace": Place.LEGS},
	{"name": "Пиявка", "desc": "Обожает грязную щиколотку.", "texture": "res://sprites/cards/leech_card_1.png", "bestPlace": Place.LEGS},
	{"name": "Анкилостома", "desc": "Заходит через босую пятку. Остаётся жить внутри.", "texture": "res://sprites/cards/hookworm_card_1.png", "bestPlace": Place.LEGS},
]

var seals: Dictionary = {
	"exile": {
		"name": "Ссыльная",
		"desc": "Не в ту зону? Не гибнет, а ползёт домой. Половина прироста уходит в родную зону.",
		"texture": "res://sprites/seals/exile_seal1.png"
	},
	"pack": {
		"name": "Стая",
		"desc": "Вместе веселее. В своей зоне +3 за каждую другую сыгранную карту с той же любимой зоной.",
		"texture": "res://sprites/seals/pack_seal2.png"
	},
	"clingy": {
		"name": "Цепкая",
		"desc": "Вцепилась намертво. Попала в свою зону: на следующем ходу снова в руке.",
		"texture": "res://sprites/seals/clingy_seal1.png"
	},
	"sleepy": {
		"name": "Сонная",
		"desc": "Хозяин клюёт носом. Попала в свою зону: его мысль в этот ход не сработает.",
		"texture": "res://sprites/seals/sleepy_seal1.png"
	},
	"scavenger": {
		"name": "Падальщица",
		"desc": "Любит, когда хозяину плохо. Пока он напуган, в своей зоне +6.",
		"texture": "res://sprites/seals/scavenger_seal1.png"
	},
	"greedy": {
		"name": "Жадная",
		"desc": "Всё или ничего. В своей зоне +3, в чужой ещё -6.",
		"texture": "res://sprites/seals/greedy_seal1.png"
	},
	"randomity": {
		"name": "???",
		"desc": "Случайным образом увеличивает/уменьшает колонию. Лудоманы будут в восторге от этой печати!",
		"texture": "res://sprites/seals/randomity_seal1.png"
	},
	"replacement": {
		"name": "Тасовка",
		"desc": "Попались неподходящие паразиты? Перетасует все карты в вашей руке.",
		"texture": "res://sprites/seals/replacement_seal1.png"
	}
#	"megacool": {"name": "МЕГАКРУТО", "desc": "МГНОВЕННОЕ ПОПОЛНЕНИЕ КОЛОНИИ ДО НУЖНОГО УРОВНЯ!"},
}

func reset_deck():
	deck.clear()
	for i in defaultCards.size():
		deck.append({"base": i, "seal": ""})
#		deck.append({"base": i, "seal": seals.keys().pick_random()})



var landlords: Array = [
	# animals
	
	{
		"name": "Мышь", "desc": "Крошечная и шустрая.",
		"texture": "res://sprites/landlords/mouse_1.png",
		"lowhealth_texture": "res://sprites/landlords/lowhealth_mouse_1.png",
		"health_mod": 1.0, "need_mod": 0.9,
		"activities": {"snack": 3, "nap": 3, "groom": 3, "hide": 3, "zoomies": 1},
	},
	{
		"name": "Кот", "desc": "Спит, охотится, осуждает.",
		"texture": "res://sprites/landlords/cat_1.png",
		"lowhealth_texture": "res://sprites/landlords/lowhealth_cat_1.png",
		"health_mod": 1.0, "need_mod": 1.0,
		"activities": {"nap": 6, "groom": 4, "hunt": 3, "snack": 3, "zoomies": 2, "hide": 2, "vet": 1},
	},
	{
		"name": "Дворняга", "desc": "Ничья. Живёт у баков.",
		"texture": "res://sprites/landlords/test_body_1.png",
		"lowhealth_texture": "res://sprites/landlords/test_body_1.png",
		"health_mod": 1.0, "need_mod": 1.0,
		"activities": {"scavenge": 5, "hide": 4, "nap": 3, "hunt": 2, "zoomies": 1},
	},
	{
		"name": "Пёс", "desc": "Шумный, преданный, вечно в движении.",
		"texture": "res://sprites/landlords/dog_1.png",
		"lowhealth_texture": "res://sprites/landlords/lowhealth_dog_1.png",
		"health_mod": 1.0, "need_mod": 1.0,
		"activities": {"zoomies": 4, "snack": 4, "hunt": 3, "nap": 3, "vet": 2, "groom": 1, "hide": 1},
	},
#	{
#		"name": "Медсестра", "desc": "Лечит других. Свои руки красные.",
#		"texture": "res://sprites/landlords/test_body_1.png",
#		"lowhealth_texture": "res://sprites/landlords/test_body_1.png",
#		"health_mod": 1.0, "need_mod": 1.0,
#		"activities": {"wash": 6, "sleep": 4, "eat": 3, "doctor": 2, "nothing": 2},
#	},
	
	
	
	
	
	# humans
	
	{
		"name": "Студент", "desc": "Не спит. Не ест. Сдаёт.",
		"texture": "res://sprites/landlords/test_body_1.png",
		"lowhealth_texture": "res://sprites/landlords/test_body_1.png",
		"health_mod": 1.0, "need_mod": 1.0,
		"activities": {"exam": 6, "eat": 3, "sleep": 3, "nothing": 2, "drink": 2, "scratch": 1},
	},
	{
		"name": "Бездомный", "desc": "Спит где придётся. Никто не заметит.",
		"texture": "res://sprites/landlords/test_body_1.png",
		"lowhealth_texture": "res://sprites/landlords/test_body_1.png",
		"health_mod": 1.1, "need_mod": 1.0,
		"activities": {"sleep": 6, "nothing": 4, "scratch": 3, "drink": 3, "eat": 2},
	},
	{
		"name": "Вдова", "desc": "Ходит на кладбище. Говорит с мужем.",
		"texture": "res://sprites/landlords/test_body_1.png",
		"lowhealth_texture": "res://sprites/landlords/test_body_1.png",
		"health_mod": 1.0, "need_mod": 1.0,
		"activities": {"grave": 5, "nothing": 5, "doctor": 4, "sleep": 3, "eat": 2, "bath": 1},
	},
	{
		"name": "Сонный сторож", "desc": "Спит. Много. Работа? Не слышал такого.",
		"texture": "res://sprites/landlords/security_man_1.png",
		"lowhealth_texture": "res://sprites/landlords/lowhealth_security_man_1.png",
		"health_mod": 1.0, "need_mod": 1.0,
		"activities": {"sleep": 10, "nothing": 4, "bath": 2, "eat": 2, "jog": 1, "doctor": 1},
	},
	{
		"name": "Старик", "desc": "Хилый. Любит врачей.",
		"texture": "res://sprites/landlords/ded_1.png",
		"lowhealth_texture": "res://sprites/landlords/lowhealth_ded_1.png",
		"health_mod": 0.7, "need_mod": 1.1,
		"activities": {"doctor": 12, "sleep": 3, "nothing": 3, "ponos": 1, "scratch": 2, "eat": 2, "bath": 1},
	},
	{
		"name": "Обжора", "desc": "Ест. Потом жалеет.",
		"texture": "res://sprites/landlords/test_body_1.png",
		"lowhealth_texture": "res://sprites/landlords/test_body_1.png",
		"health_mod": 1.3, "need_mod": 1.2,
		"activities": {"eat": 12, "ponos": 7, "sleep": 3, "drink": 2, "nothing": 1, "doctor": 1},
	},
	{
		"name": "Домовладелец", "desc": "Берёт плату за всё. Даже за воздух.",
		"texture": "res://sprites/landlords/test_body_1.png",
		"lowhealth_texture": "res://sprites/landlords/test_body_1.png",
		"health_mod": 0.8, "need_mod": 1.2,
		"activities": {"rent": 8, "eat": 5, "drink": 1, "sleep": 3, "nothing": 2, "doctor": 2},
	},
]

var activities: Dictionary = {
	"sleep": {
		"default_text": ["Хочу спать.", "Хочу спать. З-з-з...", "Глаза слипаются. Прилягу на минутку."],
		"effect": {"health": +8},
		"danger": {
			"head": {"texts": ["Не хочу спать. Чёрт, чёрт, чёрт...", "Почему я не могу выключить мозг?"], "effect": {"health": -8}},
			"body": {"texts": ["Не могу устроиться. Внутри будто что-то шевелится.", "В животе урчит. Как тут уснуть?"], "effect": {"health": -6, "colony": -6}},
		},
	},
	"eat": {
		"default_text": ["Так хочется есть. Пора перекусить.", "В холодильнике что-нибудь осталось?", "Коня бы съел. Или двух."],
		"zone": "body",
		"effect": {"health": +4, "colony": +4},
		"danger": {
			"body": {"texts": ["Живот чем-то набит... Совсем не голоден.", "Только поел, а от еды уже тошнит."], "effect": {"health": -8, "colony": -10}},
			"legs": {"texts": ["Пошёл бы на кухню, да ноги не идут.", "Холодильник так далеко. какой уже день без еды."], "effect": {"health": -8}},
		},
	},
	"doctor": {
		"default_text": ["Надо бы наконец сходить к врачу.", "Всё. Записываюсь на приём.", "Этот кашель не проходит. Пора к врачу."],
		"zone": "biggest",
		"effect": {"health": +15, "colony": -10},
		"danger": {
			"head": {"texts": ["К врачу... что я хотел сделать? Забыл.", "У меня на сегодня был план. Какой?"], "effect": {"health": -12}},
			"legs": {"texts": ["Господи, нет сил идти к врачу. Надо отдохнуть.", "Позвоню врачу завтра. Ноги слишком тяжелы."], "effect": {"health": -10}},
		},
	},
	"nothing": {
		"default_text": ["Просто тихий день.", "Постою и посмотрю в стену.", "Делать нечего. Чувствовать нечего."],
		"effect": {},
		"danger": {
			"head": {"texts": ["Почему я смотрю в стену? Сколько это уже длится?", "Кто-то шепчет. Или это холодильник?"], "effect": {"health": -6}},
		},
	},
	"ponos": {
		"default_text": ["Ой нет. Живот...", "Мне нужно в туалет. Срочно.", "Эта шаурма была неудачной."],
		"zone": "body",
		"effect": {"health": -12, "colony": -8},
		"danger": {
			"body": {"texts": ["Живот взбунтовался. Будет плохо.", "Что-то прогрызает мне кишки."], "effect": {"health": -20, "colony": -15}},
			"legs": {"texts": ["Я не добегу до туалета. Ой. Ой-ой-ой.", "Ноги не бегут. Это катастрофа."], "effect": {"health": -15, "colony": -8}},
		},
	},
	"scratch": {
		"default_text": ["Как же чешется. Надо почесаться.", "Почему кожа сегодня так чешется?", "Блохи? Комары? Кто знает."],
		"zone": "head",
		"effect": {"colony": -3},
		"danger": {
			"head": {"texts": ["Голова чешется, но руки не слушаются.", "Что-то ползает под волосами."], "effect": {"health": -10}},
			"legs": {"texts": ["Ноги слишком опухли, не почесаться. Ааа.", "Не могу дотянуться. Почему я не могу дотянуться?"], "effect": {"health": -10}},
		},
	},
	"fight": {
		"default_text": ["Кто-то косо посмотрел. Погнали!", "Хочется кому-нибудь врезать.", "Иду в бар. Сейчас начну."],
		"zone": "head",
		"effect": {"health": -20, "colony": -8},
		"danger": {
			"head": {"texts": ["Хочу драться... а с кем?", "Мне сказали бить стену. Ну я и бью."], "effect": {"health": -30, "colony": -10}},
			"legs": {"texts": ["Я даже стоять нормально не могу. Не сегодня.", "Ноги трясутся. Не до драки."], "effect": {"health": -15}},
		},
	},
	"bath": {
		"default_text": ["Горячая ванна была бы кстати.", "Пора помыться. Может, зуд пройдёт.", "Время ванны. Пена и тишина."],
		"zone": "body",
		"effect": {"health": +3, "colony": -5},
		"danger": {
			"legs": {"texts": ["Не могу залезть в ванну с такими ногами.", "Ванна такая высокая. Посижу на краю."], "effect": {"health": -10}},
		},
	},
	"jog": {
		"default_text": ["Пойду побегаю. Свежий воздух!", "Пора, наверное, форму поддерживать.", "Десять километров. Ну или пять."],
		"zone": "legs",
		"effect": {"health": +3, "colony": -2},
		"danger": {
			"legs": {"texts": ["Ноги как свинец. Никаких шансов.", "Дошёл до двери. Это и была пробежка."], "effect": {"health": -10}},
			"body": {"texts": ["Не могу отдышаться. Сегодня без бега.", "Колет в боку. Там что-то застряло."], "effect": {"health": -12, "colony": -8}},
		},
	},
	"drink": {
		"default_text": ["Мне нужно выпить. Одну рюмку.", "Немного алкоголя никому не вредило.", "Одно пиво. Два пива. Кто считает?"],
		"zone": "body",
		"effect": {"health": -12, "colony": -10},
		"danger": {
			"head": {"texts": ["Так кружится голова. Больше ни глотка.", "Почему бутылка спиртного со мной разговаривает?"], "effect": {"health": -15}},
			"body": {"texts": ["Желудок горит, но я наливаю ещё.", "Пузо в огне, а хочется добавки."], "effect": {"health": -18, "colony": -15}},
		},
	},
	"nap": {
		"default_text": ["Тёплое местечко. Время подремать.", "Глаза закрываются. Всего пять минуточек."],
		"effect": {"health": +5},
		"danger": {
			"head": {"texts": ["Почему в голове что-то пищит?"], "effect": {"health": -12}},
			"body": {"texts": ["Живот шевелится. Не уснуть."], "effect": {"health": -10, "colony": -8}},
		},
	},
	"snack": {
		"default_text": ["Еда. Еда. ЕДА.", "Кажется, пахнет едой?"],
		"zone": "body",
		"effect": {"health": +2, "colony": +2},
		"danger": {
			"body": {"texts": ["Внутри что-то есть. Есть не хочется."], "effect": {"health": -8, "colony": -12}},
			"legs": {"texts": ["Миска так далеко. Лапы не идут."], "effect": {"health": -8}},
		},
	},
	"groom": {
		"default_text": ["Зудит. Пора вылизаться.", "Всё должно блестеть. Лизь, лизь, лизь."],
		"zone": "legs",
		"effect": {"colony": -3},
		"danger": {
			"head": {"texts": ["Не достаю до собственной головы. Почему она чешется?"], "effect": {"health": -10}},
			"legs": {"texts": ["Лапы слишком болят, чтобы вылизываться."], "effect": {"health": -10}},
		},
	},
	"hunt": {
		"default_text": ["Что-то шевельнулось. ОХОТА.", "Я хищник. Бойтесь меня."],
		"zone": "legs",
		"effect": {"health": +2, "colony": +2},
		"danger": {
			"head": {"texts": ["За кем я гнался? Забыл."], "effect": {"health": -10}},
			"legs": {"texts": ["Не могу прыгнуть. Добыча уходит."], "effect": {"health": -10}},
		},
	},
	"zoomies": {
		"default_text": ["Мне вдруг НАДО бежать.", "Дикий забег! Меня не остановить."],
		"zone": "legs",
		"effect": {"health": -5, "colony": -5},
		"danger": {
			"body": {"texts": ["Не могу дышать. Забег отменяется."], "effect": {"health": -15, "colony": -12}},
			"legs": {"texts": ["Лапы сдаются посреди забега."], "effect": {"health": -15}},
		},
	},
	"hide": {
		"default_text": ["Под диван. Здесь меня никто не найдёт.", "Посижу в этой коробке."],
		"effect": {},
		"danger": {
			"head": {"texts": ["Что-то внутри моей головы. Прячусь."], "effect": {"health": -6}},
		},
	},
	"vet": {
		"default_text": ["У человека переноска. ТОЛЬКО НЕ ПЕРЕНОСКА.", "Почему здесь пахнет страхом?"],
		"zone": "biggest",
		"effect": {"health": +15, "colony": -10},
		"danger": {
			"head": {"texts": ["Переноска? Какая переноска? Кто я?"], "effect": {"health": -12}},
			"legs": {"texts": ["Падаю на пол. Меня никто никуда не понесёт."], "effect": {"health": -10}},
		},
	},
	"rent": {
		"default_text": ["Так-так-так, когда Михаилу платить за аренду..?", "Тааааак, когда Ольге платить за аренду..?"],
		"zone": "head",
		"effect": {"health": +4},
		"danger": {
			"head": {"texts": ["Таак, когда Ми... *КАШЕЛЬ*, к-кому платить?"], "effect": {"health": -15}},
			"legs": {"texts": ["А Виктория когда в последний раз платила за аренду..?"], "effect": {"health": -12}},
		},
	},
	"scavenge": {
		"default_text": ["За баком пахнет. Проверю.", "Выброшенное не значит несъедобное."],
		"zone": "body",
		"effect": {"health": -6, "colony": +4},
		"danger": {
			"body": {"texts": ["Съел что-то из бака. Теперь оно ворочается."], "effect": {"health": -15, "colony": -15}},
			"legs": {"texts": ["Лапы не несут к баку. Живот пустой."], "effect": {"health": -8}},
		},
	},
	"grave": {
		"default_text": ["Пора проведать Колю. Куплю цветы.", "Сегодня на кладбище. Поговорю с ним."],
		"zone": "legs",
		"effect": {"health": -8, "colony": -4},
		"danger": {
			"head": {"texts": ["К кому я шла? Имя не помню."], "effect": {"health": -12}},
			"legs": {"texts": ["Не дойду. Коля подождёт."], "effect": {"health": -8}},
		},
	},
	"deliver": {
		"default_text": ["Заказ остывает. Бегом.", "Ещё три адреса. Потом ещё три."],
		"zone": "legs",
		"effect": {"health": -10, "colony": -6},
		"danger": {
			"legs": {"texts": ["Ноги не бегут. Заказ опоздает."], "effect": {"health": -12}},
			"body": {"texts": ["Колет в боку. Рейтинг важнее."], "effect": {"health": -16, "colony": -8}},
		},
	},
	"energy": {
		"default_text": ["Третий энергетик за день. Сердце частит.", "Не сплю. Не хочу спать."],
		"zone": "body",
		"effect": {"health": -10, "colony": +3},
		"danger": {
			"body": {"texts": ["Сердце колотится. Что-то колотится вместе с ним."], "effect": {"health": -18, "colony": -12}},
			"head": {"texts": ["В висках стучит. Банку в мусорку не помню."], "effect": {"health": -12}},
		},
	},
	"wash": {
		"default_text": ["Руки грязные. Мою ещё раз.", "Мыло, вода, мыло. Руки чистые? Нет."],
		"zone": "biggest",
		"effect": {"health": -5, "colony": -10},
		"danger": {
			"head": {"texts": ["Руки красные. Голову не отмыть."], "effect": {"health": -12}},
			"legs": {"texts": ["Стою у раковины. Сесть бы. Нельзя."], "effect": {"health": -10}},
		},
	},
	"exam": {
		"default_text": ["Экзамен завтра. Я ничего не знаю.", "Ещё одна ночь с конспектом."],
		"zone": "head",
		"effect": {"health": -8, "colony": +3},
		"danger": {
			"head": {"texts": ["Читаю одну строчку. Букв не вижу."], "effect": {"health": -15, "colony": -10}},
			"body": {"texts": ["Кофе натощак. Живот сводит."], "effect": {"health": -12, "colony": -12}},
		},
	},
	
	
	
	
	
	"event_rain_weather": {
		"default_text": ["Опять дождь. Когда он уже кончится..?", "Ненавижу дождливую погоду, скукота."],
		"zone": "biggest",
		"effect": {"health": +15, "colony": -10},
		"danger": {
			"head": {"texts": ["Я уже не МОГУ ТЕРПЕТЬ ЭТОТ ДОЖДЬ!!!"], "effect": {"health": -25}},
			"legs": {"texts": ["Я не выйду из под крыши в такую погоду."], "effect": {"health": -25, "colony": -18}},
		},
	},
	"event_powerful_rain_weather": {
		"default_text": ["Какой сильный ливень. Когда он уже кончится..?", "Ненавижу такую погоду, всё гремит вокруг!."],
		"zone": "biggest",
		"effect": {"health": +10, "colony": -15},
		"danger": {
			"head": {"texts": ["Чёртов ливень, я даже заснуть не могу!"], "effect": {"health": -30}},
			"legs": {"texts": ["Я не выйду из под крыши в такую погоду."], "effect": {"health": -30, "colony": -18}},
		},
	},
	"event_heat": {
		"default_text": ["Так жарко... В горле пересохло.", "Голова раскалывается от жары."],
		"zone": "body",
		"effect": {"health": -10, "colony": -5},
		"danger": {
			"head": {"texts": ["Мозг плавится. Я не соображаю."], "effect": {"health": -10}},
			"body": {"texts": ["Походу обезвоживание. Внутри всё горит."], "effect": {"health": -15, "colony": -10}},
		},
	},
	"event_paranoia": {
		"default_text": ["Кто здесь? Я слышал шаги.", "Они следят за мной из розетки."],
		"zone": "head",
		"effect": {"health": -5},
		"danger": {
			"head": {"texts": ["Они внутри меня! Надо выцарапать!"], "effect": {"health": -20}},
			"legs": {"texts": ["Бежать... куда? Они везде."], "effect": {"health": -15, "colony": -10}},
		},
	},
	"event_medicine": {
		"default_text": ["Пора выпить эти таблетки.", "Эта горечь во рту..."],
		"zone": "biggest",
		"effect": {"health": +10, "colony": -15},
		"danger": {
			"head": {"texts": ["Таблетки... они жгут меня изнутри."], "effect": {"health": -20, "colony": -15}},
			"legs": {"texts": ["Передозировка. Мир плывет."], "effect": {"health": -15, "colony": -15}},
		},
	},
	"event_fever": {
		"default_text": ["Меня знобит. Бросает в жар.", "Температура поднимается."],
		"zone": "biggest",
		"effect": {"health": -5, "colony": -10},
		"danger": {
			"body": {"texts": ["Иммунитет атакует. Белые клетки повсюду."], "effect": {"health": -20, "colony": -25}},
			"head": {"texts": ["Горит голова. Иммунитет душит колонию."], "effect": {"health": -20, "colony": -15}},
		},
	},
	"event_cold_weather": {
		"default_text": ["Зубы стучат от холода.", "Холод пробирает до костей."],
		"zone": "legs",
		"effect": {"health": -5, "colony": -4},
		"danger": {
			"head": {"texts": ["В голове ломит от холода. Мысли замерзают."], "effect": {"health": -12}},
			"legs": {"texts": ["Ноги окоченели. Я не чувствую пальцев."], "effect": {"health": -10, "colony": -10}},
		},
	},
}

onready var musicPlayer: AudioStreamPlayer

var musicVolume: float = -20.0   # db
var soundVolume: float = -10.0   # db
var moveByMouse: bool = true
var fullscreen: bool = false
var expandWindow: bool = false

func _ready():
	if OS.get_locale_language() in ["ru", "en"]:
		TranslationServer.set_locale(OS.get_locale_language())
	else:
		TranslationServer.set_locale("en")
	
	musicPlayer = AudioStreamPlayer.new()
	musicPlayer.pause_mode = Node.PAUSE_MODE_PROCESS
	add_child(musicPlayer)
	
	play_music("res://music/default_music_1.mp3")

func _input(event):
	if event.is_action_released("RESTART"):
		get_tree().change_scene("res://scenes/intro.tscn")
	elif event.is_action_released("QUIT"):
		get_tree().quit()

func toggle_fullscreen(toggle: bool):
	fullscreen = toggle
	OS.window_fullscreen = fullscreen

func update_music_volume(volume: float):
	if volume <= -50:
		musicVolume = -99999.0
	else:
		musicVolume = volume
	
	musicPlayer.volume_db = musicVolume

func update_sound_volume(volume: float):
	if volume <= -50:
		soundVolume = -99999.0
	else:
		soundVolume = volume

func play_music(newStream: String):
	musicPlayer.volume_db = musicVolume
	
	if musicPlayer.stream:
		if musicPlayer.stream.resource_path == newStream:
			return
	
	musicPlayer.stop()
	if newStream == "":
		musicPlayer.stream = null
		return
	
	musicPlayer.stream = load(newStream)
	musicPlayer.stream.loop = true
	musicPlayer.play()

func reset():
	Global.currentLandlordIndex = 0
	Global.health = 100
	Global.headColony = 0
	Global.bodyColony = 0
	Global.legsColony = 0
	Global.turns = 0
	Global.parasitedLandlords = 0
	Global.nColony = 0
	Global.reset_deck()
