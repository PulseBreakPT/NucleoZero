extends RefCounted
class_name GameData

const SAVE_PATH := "user://nucleo_zero_save.json"
const ITEMS := [
    "Faísca Primal", "Engrenagem Solar", "Cristal de Néon", "Núcleo de Bruma", "Fragmento Azul",
    "Circuito Lunar", "Lâmina de Plasma", "Éter Condensado", "Olho Orbital", "Moeda Quântica",
    "Relógio de Antimatéria", "Coração de Titânio", "Flor de Carbono", "Fóssil Estelar", "Amuleto Polar",
    "Prisma Violeta", "Matriz Fantasma", "Fragmento Infinito", "Anel Galáctico", "Orbe do Eclipse",
    "Coroa do Vácuo", "Semente Cósmica", "Chama Perpétua", "Código Ancestral", "Singularidade",
    "Coração do Cosmos", "Luz de Órion", "Ecos do Infinito", "Matéria Primordial", "NÚCLEO ZERO"
]
const RARITIES := ["Comum", "Incomum", "Raro", "Épico", "Lendário", "Mítico"]
const RARITY_COLORS := ["#8eabbc", "#70dcae", "#58baf6", "#b18bff", "#ffca6e", "#ff7098"]
const BASE_PRICES := {"tap": 30, "auto": 100, "charge": 120, "luck": 180, "critical": 240}
const UPGRADE_NAMES := {"tap": "Força do toque", "auto": "Reator automático", "charge": "Circuito eficiente", "luck": "Sorte quântica", "critical": "Golpe crítico"}
const PERK_NAMES := {"power": "Potência permanente", "wealth": "Mercado universal", "luck": "Destino favorável"}

var coins: int = 0
var capsules: int = 0
var opened: int = 0
var lifetime_opened: int = 0
var total_taps: int = 0
var cores: int = 0
var resets: int = 0
var charge: float = 0.0
var level: int = 1
var exp: int = 0
var upgrades: Dictionary = {"tap":0,"auto":0,"charge":0,"luck":0,"critical":0}
var perks: Dictionary = {"power":0,"wealth":0,"luck":0}
var inventory: Dictionary = {}
var discovered: Dictionary = {}
var offline_capsules: int = 0

func target() -> float:
    return maxf(5.0, 18.0 - 1.4 * float(upgrades["charge"]))

func tap_power() -> float:
    return 1.0 + float(upgrades["tap"]) + float(perks["power"]) * 2.0

func auto_power() -> float:
    return float(upgrades["auto"]) * (0.6 + 0.15 * float(upgrades["auto"])) * (1.0 + float(perks["power"]) * 0.1)

func _add_energy(power: float) -> int:
    charge += power
    var earned: int = 0
    var requirement: float = target()
    while charge >= requirement and earned < 10000:
        charge -= requirement
        capsules += 1
        earned += 1
    return earned

func tap() -> int:
    total_taps += 1
    var multiplier: float = 3.0 if randf() < 0.02 + float(upgrades["critical"]) * 0.025 else 1.0
    return _add_energy(tap_power() * multiplier)

func passive(delta: float) -> int:
    return _add_energy(auto_power() * maxf(0.0,delta))

func upgrade_cost(key: String) -> int:
    if not BASE_PRICES.has(key):
        return 999999999
    return int(ceil(float(BASE_PRICES[key]) * pow(1.65, float(upgrades[key]))))

func buy_upgrade(key: String) -> bool:
    if not BASE_PRICES.has(key):
        return false
    var price: int = upgrade_cost(key)
    if coins < price:
        return false
    coins -= price
    upgrades[key] = int(upgrades[key]) + 1
    save_game()
    return true

func perk_cost(key: String) -> int:
    if not PERK_NAMES.has(key):
        return 999999999
    return 1 + int(perks[key]) * 2

func buy_perk(key: String) -> bool:
    if not PERK_NAMES.has(key) or cores < perk_cost(key):
        return false
    cores -= perk_cost(key)
    perks[key] = int(perks[key]) + 1
    save_game()
    return true

func _choose_rarity() -> int:
    var roll: float = randf() * 100.0
    var boost: float = float(upgrades["luck"]) * 0.8 + float(perks["luck"]) * 1.8
    if roll < 0.08 + boost * 0.06:
        return 5
    if roll < 0.75 + boost * 0.2:
        return 4
    if roll < 5.0 + boost * 0.45:
        return 3
    if roll < 19.0 + boost * 0.75:
        return 2
    if roll < 48.0 + boost:
        return 1
    return 0

func open_capsule() -> Dictionary:
    if capsules <= 0:
        return {}
    capsules -= 1
    var rarity: int = _choose_rarity()
    var item_id: int = rarity * 5 + randi_range(0,4)
    var key: String = str(item_id)
    var price: int = item_price(item_id)
    var reward: int = int(round(float(price) * 0.25 * (1.0 + 0.1 * float(perks["wealth"]))))
    coins += reward
    opened += 1
    lifetime_opened += 1
    exp += 2 + rarity * 3
    if exp >= level * 25:
        exp -= level * 25
        level += 1
    inventory[key] = int(inventory.get(key,0)) + 1
    discovered[key] = true
    save_game()
    return {"id":item_id,"name":ITEMS[item_id],"rarity":rarity,"coins":reward}

func item_price(item_id: int) -> int:
    var rarity: int = clampi(item_id / 5,0,5)
    return int(round(10.0 * pow(3.8,rarity) * (1 + (item_id % 5) * 0.17)))

func sell_item(item_id: int) -> int:
    var key: String = str(item_id)
    if int(inventory.get(key,0)) <= 0:
        return 0
    inventory[key] = int(inventory[key]) - 1
    var income: int = int(round(float(item_price(item_id)) * (1.0 + 0.1 * float(perks["wealth"]))))
    coins += income
    save_game()
    return income

func discovery_count() -> int:
    return discovered.size()

func can_ascend() -> bool:
    return opened >= 30

func ascend() -> int:
    if not can_ascend():
        return 0
    var reward: int = maxi(1,opened / 30)
    cores += reward
    resets += 1
    coins = 0
    capsules = 0
    opened = 0
    charge = 0.0
    upgrades = {"tap":0,"auto":0,"charge":0,"luck":0,"critical":0}
    inventory = {}
    save_game()
    return reward

func save_game() -> void:
    var snapshot: Dictionary = {
        "coins":coins,"capsules":capsules,"opened":opened,"lifetime_opened":lifetime_opened,
        "total_taps":total_taps,"cores":cores,"resets":resets,"charge":charge,"level":level,
        "exp":exp,"upgrades":upgrades,"perks":perks,"inventory":inventory,
        "discovered":discovered,"saved_at":int(Time.get_unix_time_from_system())
    }
    var file: FileAccess = FileAccess.open(SAVE_PATH,FileAccess.WRITE)
    if file != null:
        file.store_string(JSON.stringify(snapshot))
        file.close()

func load_save() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        return
    var file: FileAccess = FileAccess.open(SAVE_PATH,FileAccess.READ)
    if file == null:
        return
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    file.close()
    if typeof(parsed) != TYPE_DICTIONARY:
        return
    var d: Dictionary = parsed
    coins = maxi(0,int(d.get("coins",0)))
    capsules = maxi(0,int(d.get("capsules",0)))
    opened = maxi(0,int(d.get("opened",0)))
    lifetime_opened = maxi(0,int(d.get("lifetime_opened",0)))
    total_taps = maxi(0,int(d.get("total_taps",0)))
    cores = maxi(0,int(d.get("cores",0)))
    resets = maxi(0,int(d.get("resets",0)))
    charge = maxf(0.0,float(d.get("charge",0)))
    level = maxi(1,int(d.get("level",1)))
    exp = maxi(0,int(d.get("exp",0)))
    for key in upgrades.keys():
        upgrades[key] = maxi(0,int(d.get("upgrades",{}).get(key,0)))
    for key in perks.keys():
        perks[key] = maxi(0,int(d.get("perks",{}).get(key,0)))
    inventory = d.get("inventory",{})
    discovered = d.get("discovered",{})
    var seconds: float = clampf(float(Time.get_unix_time_from_system() - int(d.get("saved_at",int(Time.get_unix_time_from_system())))),0.0,28800.0)
    offline_capsules = passive(seconds)
