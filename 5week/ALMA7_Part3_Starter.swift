// =============================================================
//  Station ALMA-7, Part III: The Repair Fleet
//  iOS Mobile Development · Module 5 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part3_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section. LegacyBeacon in
//     particular must be reached with an extension, not edited.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • The Health Rule must exist in exactly ONE place in this file.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Drone records recovered from the fleet registry.
/// One `kind` does not correspond to any drone type you will build.
let fleetData: [(kind: String, id: String, charge: Int)] = [
    (kind: "welder",  id: "W-1", charge: 80),
    (kind: "scanner", id: "S-1", charge: 45),
    (kind: "cargo",   id: "C-1", charge: 100),
    (kind: "welder",  id: "W-2", charge: 15),
    (kind: "scanner", id: "S-2", charge: 60),
    (kind: "tug",     id: "T-1", charge: 50)
]

/// Hull sensors. These are NOT drones — they never move and never work a shift.
let sensorData: [(id: String, charge: Int)] = [
    (id: "hull-cam", charge: 12),
    (id: "thermal",  charge: 77)
]

/// Hardware from the original station. You may not add anything to this
/// declaration — no methods, no protocols, no properties.
struct LegacyBeacon {
    let name: String
    let signalStrength: Int
}

let beacon = LegacyBeacon(name: "ALMA-BEACON", signalStrength: 8)

print("Fleet registry online: \(fleetData.count) drone records, \(sensorData.count) sensors, beacon \(beacon.name).")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================

// MARK: Level 1 · The Power Cell

// Why a class and not a struct here?  ->
// Класс является ссылочным типом (reference type), что гарантирует работу с единым состоянием батареи в памяти без создания независимых копий при передаче.
final class PowerCell {
    private var charge: Int
    
    init(charge: Int) {
        if charge > 100 {
            self.charge = 100
        } else if charge < 0 {
            self.charge = 0
        } else {
            self.charge = charge
        }
    }
    
    func level() -> Int {
        return charge
    }
    
    func spend(amount: Int) -> Bool {
        if amount <= 0 || charge < amount {
            return false
        }
        charge -= amount
        return true
    }
    
    func recharge(by amount: Int) {
        if amount <= 0 { return }
        charge += amount
        if charge > 100 {
            charge = 100
        }
    }
}

// Encapsulation proof (leave this commented, with the compiler error):
// let cell = PowerCell(charge: 100)
// cell.charge = 100
// error: 'charge' is inaccessible due to 'private' protection level


// MARK: Level 2 · The Fleet

// 2.1  What does `final` on runOnce() buy you?  ->
// Модификатор final предотвращает переопределение метода в подклассах, гарантируя, что строгий ритуал смены (попытка списания энергии перед выполнением работы) никогда не будет нарушен наследниками.
class Drone {
    let id: String
    let cell: PowerCell
    
    init(id: String, cell: PowerCell) {
        self.id = id
        self.cell = cell
    }
    
    var powerCost: Int { 10 }
    
    var statusLine: String {
        "\(id): \(cell.level().powerBar)"
    }
    
    func performTask() -> Int { 0 }
    
    final func runOnce() -> Int {
        if cell.spend(amount: powerCost) {
            return performTask()
        }
        return 0
    }
}

// 2.2
final class WelderDrone: Drone {
    override var powerCost: Int { 25 }
    override func performTask() -> Int { 40 }
    
    func weldSeam() -> String {
        return "welding complete"
    }
}

class ScannerDrone: Drone {
    override func performTask() -> Int { 15 }
    
    override var statusLine: String {
        return super.statusLine + " [scanner]"
    }
}

final class CargoDrone: Drone {
    override var powerCost: Int { 20 }
    override func performTask() -> Int { 25 }
}

// 2.3
func makeDrone(kind: String, id: String, charge: Int) -> Drone? {
    let cell = PowerCell(charge: charge)
    
    switch kind {
    case "welder": return WelderDrone(id: id, cell: cell)
    case "scanner": return ScannerDrone(id: id, cell: cell)
    case "cargo": return CargoDrone(id: id, cell: cell)
    default: return nil
    }
}

var fleet: [Drone] = []
for data in fleetData {
    if let drone = makeDrone(kind: data.kind, id: data.id, charge: data.charge) {
        fleet.append(drone)
    } else {
        print("Warning: Unknown drone kind '\(data.kind)' skipped.")
    }
}


// MARK: Level 3 · The Shift

func runShift(_ fleet: [Drone], rounds: Int) -> Int {
    var totalWork = 0
    for _ in 1...rounds {
        for drone in fleet {
            totalWork += drone.runOnce()
        }
    }
    return totalWork
}

let A = runShift(fleet, rounds: 3)

var B = 0
var C = 0

for drone in fleet {
    print(drone.statusLine)
    B += drone.cell.level()
    if drone.cell.level() >= drone.powerCost {
        C += 1
    }
}


// MARK: Level 4 · Diagnostics

// 4.1
protocol Diagnosable {
    var componentID: String { get }
    var statusCode: Int { get }
    func diagnose() -> String
}

// 4.2
protocol Rechargeable {
    mutating func recharge(by amount: Int)
}

// Why does Drone implement recharge(by:) without `mutating`?  ->
// Классы являются ссылочными типами (Reference Type). Изменение их свойств модифицирует данные по ссылке, а не пересоздает объект. Структуры — типы значений, для них mutating обязателен.
extension Drone: Diagnosable, Rechargeable {
    var componentID: String { return id }
    var statusCode: Int { return calculateStatusCode(for: cell.level()) }
    
    func recharge(by amount: Int) {
        cell.recharge(by: amount)
    }
}

struct SensorModule: Diagnosable, Rechargeable {
    let componentID: String
    var chargeLevel: Int
    
    var statusCode: Int { return calculateStatusCode(for: chargeLevel) }
    
    mutating func recharge(by amount: Int) {
        if amount <= 0 { return }
        chargeLevel += amount
        if chargeLevel > 100 { chargeLevel = 100 }
    }
}

// 4.3
// Why could [Drone] never have held the sensors?  ->
// SensorModule является структурой и не может наследоваться от класса Drone. Только использование протокола позволяет объединить их в единый массив.
func diagnosticsReport(_ components: [Diagnosable]) -> String {
    var report = "--- Diagnostics Report ---\n"
    for component in components {
        report += component.diagnose() + "\n"
    }
    return report
}

var allComponents: [Diagnosable] = []
for drone in fleet { allComponents.append(drone) }
for data in sensorData {
    allComponents.append(SensorModule(componentID: data.id, chargeLevel: data.charge))
}


// MARK: Level 5 · Shared Behaviour

// 5.1 · default diagnose() + the single home of the Health Rule
extension Diagnosable {
    func diagnose() -> String {
        return "\(componentID): code \(statusCode)"
    }
    
    func calculateStatusCode(for charge: Int) -> Int {
        if charge < 20 {
            return 2 // critical
        } else if charge < 50 {
            return 1 // warning
        } else {
            return 0 // nominal
        }
    }
}

// 5.2 · the beacon you cannot edit
extension LegacyBeacon: Diagnosable {
    var componentID: String { return name }
    var statusCode: Int { return calculateStatusCode(for: signalStrength) }
    
    func diagnose() -> String {
        return "LEGACY HARDWARE [\(name)] DETECTED - Status: \(statusCode)"
    }
}

allComponents.append(beacon)
print(diagnosticsReport(allComponents))

var D = 0
for component in allComponents {
    D += component.statusCode
}

// 5.3
extension Int {
    var powerBar: String {
        let clamped = self < 0 ? 0 : (self > 100 ? 100 : self)
        let hashes = clamped / 10
        let dots = 10 - hashes
        
        var bar = ""
        for _ in 0..<hashes { bar += "#" }
        for _ in 0..<dots { bar += "." }
        return bar
    }
}


// MARK: Level 6 · Incident Reports

// Report 1
// Expectation: The author expected PatchDrone to output 30 work units.
// Actual: It does not compile.
// Rule: You must use the `override` keyword when overriding a superclass method.
// Fix:
class PatchDrone: Drone {
    override func performTask() -> Int {
        return 30
    }
}

// Report 2
// Expectation: The author expected HeavyWelder to cheat the shift and return 999.
// Actual: It does not compile.
// Rule: `runOnce()` is marked `final` in the `Drone` base class, preventing overrides.
// Fix: Remove the override block entirely.
final class HeavyWelder: WelderDrone {
    // Fix: Removed `override func runOnce()` block.
}

// Report 3
// Expectation: The author expected to call a WelderDrone-specific method from an array element.
// Actual: It does not compile because the array type is `[Drone]`, and `Drone` has no `weldSeam()`.
// Rule: We must use conditional downcasting (`as?`) to access subclass-specific methods.
// Fix:
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
// Why `as?` returns an optional: The cast occurs at runtime. If the object isn't actually a WelderDrone, it safely returns nil instead of crashing.
if let welder = first as? WelderDrone {
    print(welder.weldSeam())
}

// Report 4
// Expectation: The author expected it to print "thruster T-1".
// Actual: It compiles but prints "generic component".
// Rule: The protocol `Labelled` did not list `label()` as a requirement. Due to static dispatch, the compiler invoked the protocol extension's default method based on the variable's type.
// Fix: Add `func label() -> String` to the protocol declaration.
protocol Labelled {
    var componentID: String { get }
    func label() -> String // <-- Added requirement
}

extension Labelled {
    func label() -> String { "generic component" }
}

struct Thruster: Labelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}

let parts: [Labelled] = [Thruster(componentID: "T-1")]
print(parts[0].label())


// MARK: Finale · Mission Code

let missionCode = "\(A)-\(B)-\(C)-\(D)"
print("MISSION CODE: \(missionCode)")


// MARK: Bonus

// Two ways to forbid using Drone directly:
// 1. Runtime failure: Add `fatalError("Must be subclassed")` inside `Drone.performTask()`.
// 2. Compile-time failure: Change `Drone` from a class to a `protocol`.
// Which would you pick: The protocol design is safer (compile-time). If drones had to share mutable state (e.g. shared physical resources), a base class might still be preferable, but protocols are generally better for purely abstract blueprints.


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why does a class satisfy a `mutating` protocol requirement without the
    keyword, while a struct must write it?
    Классы — это ссылочные типы (reference types), поэтому их данные меняются по ссылке без пересоздания объекта. Структуры — типы значений (value types), поэтому для изменения свойств внутри их собственных методов обязательно требуется ключевое слово mutating.

 2. One thing inheritance does that protocols cannot, and one thing
    protocols do that inheritance cannot:
    Наследование позволяет передавать общую готовую реализацию (например, хранение переменных / stored properties), что недоступно протоколу. Протокол, в свою очередь, позволяет объединять типы значений (структуры и перечисления), а также позволяет одному типу соответствовать сразу нескольким протоколам.

 3. What does `final` prevent, and what did it protect in runOnce()?
    `final` запрещает переопределение методов/свойств в подклассах и запрещает создание подклассов (если применен к классу). В runOnce() он защитил обязательный "ритуал смены" — дрон физически не может отработать смену, не попытавшись сначала списать заряд батареи.

 4. In Report 4, why did the protocol extension's method win?
    Потому что метод label() не был указан как обязательное требование внутри `protocol Labelled`. В этом случае компилятор применяет статическую диспетчеризацию, вызывая метод, основываясь исключительно на типе переменной `[Labelled]`, а не на её фактическом наполнении (структуре Thruster).
*/
