extends Node
class_name TerritoryManager

signal territory_changed(name: String, level: int)
signal staff_changed

var territories := {
    "Morro do Caramelo": {"level": 0, "income": 180, "risk": 1},
    "Beco da Caixa d'Água": {"level": 0, "income": 260, "risk": 2},
    "Vila Nova": {"level": 0, "income": 420, "risk": 3}
}
var staff := {"seguranca": 0, "vendedores": 0, "olheiros": 0}
var payroll_per_day := 0
var business_income_per_day := 0
var territory_income_per_day := 0
var day_tick := 0.0

func _process(delta: float) -> void:
    day_tick += delta
    if day_tick >= 180.0:
        day_tick = 0.0
        _payroll_and_income()

func recruit(role: String) -> void:
    var costs := {"seguranca": 350, "vendedores": 180, "olheiros": 220}
    if not costs.has(role):
        return
    var cost: int = costs[role]
    if GameState.money < cost:
        GameState.show_message("Dinheiro insuficiente para contratar.")
        return
    GameState.add_money(-cost)
    staff[role] += 1
    _recalculate_finances()
    staff_changed.emit()
    GameState.show_message("Funcionário contratado: " + role)

func conquer(name: String) -> bool:
    if not territories.has(name):
        return false
    var data: Dictionary = territories[name]
    if int(data.level) > 0:
        GameState.show_message("Essa área já está sob seu controle.")
        return false
    var required := 1 + int(data.risk)
    if GameState.reputation < required:
        GameState.show_message("Você precisa de mais respeito para conquistar essa área.")
        return false
    data.level = 1
    territories[name] = data
    _recalculate_finances()
    territory_changed.emit(name, 1)
    GameState.show_message("Território conquistado: " + name)
    return true

func _recalculate_finances() -> void:
    payroll_per_day = staff.seguranca * 120 + staff.vendedores * 65 + staff.olheiros * 80
    business_income_per_day = staff.vendedores * 210
    territory_income_per_day = 0
    for data in territories.values():
        if int(data.level) > 0:
            territory_income_per_day += int(data.income)
    staff_changed.emit()

func _payroll_and_income() -> void:
    var net := business_income_per_day + territory_income_per_day - payroll_per_day
    GameState.add_money(net)
    GameState.show_message("Fechamento do dia: " + ("+" if net >= 0 else "") + "R$ " + str(net))
    if GameState.money < payroll_per_day:
        GameState.show_message("Atenção: caixa insuficiente para pagar toda a equipe!")
    _recalculate_finances()

func get_summary() -> String:
    return "Áreas: " + str(_controlled_count()) + "/" + str(territories.size()) + " | Equipe: " + str(staff.seguranca + staff.vendedores + staff.olheiros) + " | Salários/dia: R$ " + str(payroll_per_day)

func _controlled_count() -> int:
    var count := 0
    for data in territories.values():
        if int(data.level) > 0:
            count += 1
    return count
