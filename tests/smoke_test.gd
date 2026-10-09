extends SceneTree
const Data = preload("res://scripts/GameData.gd")
func _initialize() -> void:
    call_deferred("_test")
func _test() -> void:
    var g: GameData = Data.new()
    assert(g.target() == 18.0)
    assert(g.tap_power() == 1.0)
    for i in range(18):
        g.tap()
    assert(g.capsules >= 1)
    var item: Dictionary = g.open_capsule()
    assert(not item.is_empty())
    assert(g.discovered.size() == 1)
    assert(g.lifetime_opened == 1)
    assert(g.sell_item(int(item["id"])) > 0)
    g.coins = 10000
    assert(g.buy_upgrade("tap"))
    assert(g.buy_upgrade("auto"))
    assert(g.auto_power() > 0)
    var before: int = g.capsules
    g.passive(120.0)
    assert(g.capsules > before)
    g.opened = 30
    assert(g.ascend() >= 1)
    assert(g.resets == 1)
    assert(g.cores > 0)
    print("PASS: clicks, loot, inventory, sale, upgrades, idle generation, ascension")
    quit(0)
