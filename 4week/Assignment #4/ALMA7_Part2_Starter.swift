// =============================================================
//  Station ALMA-7, Part II: The Teleporter Incident
//  iOS Mobile Development · Module 4 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part2_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Default to struct. Use class only where the task says so.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Splits a line into fields.
/// fields("crate:101:120")            -> ["crate", "101", "120"]
/// fields("livestock:lab mice:12:2")  -> ["livestock", "lab mice", "12", "2"]
/// fields("junk")                     -> ["junk"]
func fields(_ line: String, separatedBy separator: Character = ":") -> [String] {
    var result: [String] = []
    var current = ""
    for character in line {
        if character == separator {
            result.append(current)
            current = ""
        } else {
            current.append(character)
        }
    }
    result.append(current)
    return result
}

/// Cargo manifest as recovered from the damaged recorder.
let rawManifest = [
    "crate:101:120",
    "container:KZ-ALM-7:340",
    "livestock:lab mice:12:2",
    "???-corrupted-line",
    "crate:102:75",
    "container:KZ-ALM-9:410",
    "livestock:ficus:3:5",
    "crate:103:260",
    "crate:104:abc",
    ""
]

/// Oxygen readings. One of these deck names is not a real deck.
let deckReadings: [(deck: String, oxygen: Int)] = [
    (deck: "bridge",     oxygen: 78),
    (deck: "lab",        oxygen: 64),
    (deck: "greenhouse", oxygen: 55),
    (deck: "cargo",      oxygen: 12),
    (deck: "medbay",     oxygen: 90),
    (deck: "engine",     oxygen: 41)
]

/// Crew records, straight from the personnel file.
let crewData: [(name: String, deck: String, oxygen: Int)] = [
    (name: "Timur",   deck: "engine", oxygen: 62),
    (name: "Dana",    deck: "lab",    oxygen: 48),
    (name: "Aigerim", deck: "bridge", oxygen: 91),
    (name: "Nurlan",  deck: "cargo",  oxygen: 17)
]

print("ALMA-7 recorder online: \(rawManifest.count) manifest lines, \(deckReadings.count) readings, \(crewData.count) crew records.")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================
// Uncomment each declaration when you start working on it.


// MARK: Level 1 · The Deck Register

// 1.1
enum Deck: String, CaseIterable {
    case bridge
    case lab
    case cargo
    case medbay
    case engine
    
    var evacuationPriority: Int {
        switch self {
        case .bridge: return 1
        case .medbay: return 2
        case .lab: return 3
        case .engine: return 4
        case .cargo: return 5
        }
    }
}

print("--- Level 1.1: Decks ---")
for deck in Deck.allCases {
    print("\(deck.rawValue): priority \(deck.evacuationPriority)")
}

// 1.2
enum AlarmLevel: Int {
    case green = 0
    case yellow
    case orange
    case red
    
    static func level(forTotalMass mass: Int) -> AlarmLevel {
        var steps = mass / 500
        if steps > 3 { steps = 3 } // Максимум это уровень red (3)
        return AlarmLevel(rawValue: steps) ?? .red // Безопасное извлечение
    }
}

print("--- Level 1.2: Alarms ---")
print("Mass 0: \(AlarmLevel.level(forTotalMass: 0))")
print("Mass 940: \(AlarmLevel.level(forTotalMass: 940))")
print("Mass 4000: \(AlarmLevel.level(forTotalMass: 4000))")


// MARK: Level 2 · The Manifest

// 2.1
enum ManifestEntry {
    case crate(id: Int, massKg: Int)
    case container(code: String, massKg: Int)
    case livestock(species: String, count: Int, massPerUnitKg: Int)
    case unknown(raw: String)
}

// 2.2
func parseEntry(line: String) -> ManifestEntry {
    let parts = fields(line, separatedBy: ":")
    
    if parts.count == 3 && parts[0] == "crate",
       let id = Int(parts[1]), let mass = Int(parts[2]) {
        return .crate(id: id, massKg: mass)
    }
    
    if parts.count == 3 && parts[0] == "container",
       let mass = Int(parts[2]) {
        return .container(code: parts[1], massKg: mass)
    }
    
    if parts.count == 4 && parts[0] == "livestock",
       let count = Int(parts[2]), let massPerUnit = Int(parts[3]) {
        return .livestock(species: parts[1], count: count, massPerUnitKg: massPerUnit)
    }
    
    return .unknown(raw: line)
}

// 2.3
func mass(of entry: ManifestEntry) -> Int {
    switch entry {
    case let .crate(_, massKg):
        return massKg
    case let .container(_, massKg):
        return massKg
    case let .livestock(_, count, massPerUnitKg):
        return count * massPerUnitKg
    case .unknown:
        return 0
    }
}

print("--- Level 2: Manifest ---")
var totalManifestMass = 0
var unknownCount = 0

for line in rawManifest {
    let entry = parseEntry(line: line)
    let entryMass = mass(of: entry)
    totalManifestMass += entryMass
    
    // Проверяем, является ли запись неизвестной
    switch entry {
    case .unknown:
        unknownCount += 1
    default:
        break
    }
}

print("Total mass: \(totalManifestMass) kg")
print("Unknown lines: \(unknownCount)")

let A = totalManifestMass


// MARK: Level 3 · Crew Snapshots

// 3.1
struct CrewSnapshot {
    let name: String
    var deck: Deck
    var oxygen: Int
    
    mutating func breathe(amount: Int) {
        oxygen -= amount
        if oxygen < 0 { oxygen = 0 }
    }
    
    mutating func move(to deck: Deck) {
        self.deck = deck
    }
    
    mutating func reviveInMedbay() {
        self = CrewSnapshot(name: name, deck: .medbay, oxygen: 100)
    }
    
    static func rookie(named name: String) -> CrewSnapshot {
        return CrewSnapshot(name: name, deck: .bridge, oxygen: 100)
    }
}

// 3.2
print("--- Level 3: Roster ---")
var crewRoster: [CrewSnapshot] = []
for data in crewData {
    if let realDeck = Deck(rawValue: data.deck) {
        let snapshot = CrewSnapshot(name: data.name, deck: realDeck, oxygen: data.oxygen)
        crewRoster.append(snapshot)
    } else {
        print("Warning: Unknown deck '\(data.deck)' for \(data.name)")
    }
}

// 3.3
print("--- Level 3.3: Value Semantics Demo ---")
// 1. Copy
var originalCopy = crewRoster[0]
var modifiedCopy = originalCopy
modifiedCopy.oxygen = 10
print("Copy Demo - Original: \(originalCopy.oxygen), Copied/Modified: \(modifiedCopy.oxygen)")

// 2. Plain Parameter
func tryToModify(snapshot: CrewSnapshot) {
    var localSnapshot = snapshot
    localSnapshot.oxygen = 20
}
tryToModify(snapshot: originalCopy)
print("Plain Func Demo - Original is still: \(originalCopy.oxygen)")

// 3. Inout Parameter
func actuallyModify(snapshot: inout CrewSnapshot) {
    snapshot.oxygen = 30
}
actuallyModify(snapshot: &originalCopy)
print("Inout Func Demo - Original changed to: \(originalCopy.oxygen)")


// MARK: Level 4 · The Teleport Pod

// 4.1
final class TeleportPod {
    let id: String
    var chargeLevel: Int
    var occupant: CrewSnapshot?
    
    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = chargeLevel
        // Инициализируем явно. Это необходимо, так как у классов нет дефолтного
        // инициализатора, и мы должны прописать начальное состояние.
        self.occupant = nil
    }
    
    func load(crew: CrewSnapshot) -> Bool {
        if occupant != nil || chargeLevel < 20 { return false }
        occupant = crew
        return true
    }
    
    func fire() -> CrewSnapshot? {
        if let crew = occupant, chargeLevel >= 20 {
            chargeLevel -= 20
            occupant = nil
            return crew
        }
        return nil
    }
}

// 4.2
print("--- Level 4: Charge Ledger ---")
let pod = TeleportPod(id: "P-1", chargeLevel: 100)
print("Start: \(pod.chargeLevel)")

_ = pod.load(crew: crewRoster[0]) // Timur
_ = pod.fire()
print("After Timur: \(pod.chargeLevel)")

_ = pod.load(crew: crewRoster[1]) // Dana
_ = pod.fire()
print("After Dana: \(pod.chargeLevel)")

_ = pod.load(crew: crewRoster[2]) // Aigerim
_ = pod.fire()
print("After Aigerim (was Nurlan in instructions, using index 2): \(pod.chargeLevel)")

_ = pod.fire() // Empty pod
print("After Empty Fire: \(pod.chargeLevel)")

let C = pod.chargeLevel

// 4.3
print("--- Level 4.3: Reference Semantics Demo ---")
let pod1 = TeleportPod(id: "Demo", chargeLevel: 50)
let pod2 = pod1
pod2.chargeLevel = 10
print("Pod1 charge: \(pod1.chargeLevel), Pod2 charge: \(pod2.chargeLevel)")
// Правило: Классы передаются по ссылке. Изменяя pod2, мы меняем тот же объект в памяти, что и pod1.


// MARK: Level 5 · Station Systems

// 5.1
final class Station {
    let callSign: String
    
    var hullIntegrity: Int {
        willSet {
            print("Hull transitioning: \(hullIntegrity) -> \(newValue)")
        }
        didSet {
            if hullIntegrity > 100 { hullIntegrity = 100 }
            if hullIntegrity < 0 { hullIntegrity = 0 }
        }
    }
    
    lazy var fullDiagnostics: String = {
        print("Running full scan...")
        return "Scan complete. All systems stable."
    }()
    
    var oxygenByDeck: [Deck: Int] = [:]
    
    var totalOxygen: Int {
        var sum = 0
        for value in oxygenByDeck.values { sum += value }
        return sum
    }
    
    var averageOxygen: Int {
        get {
            if oxygenByDeck.isEmpty { return 0 }
            return totalOxygen / oxygenByDeck.count
        }
        set {
            for key in oxygenByDeck.keys {
                oxygenByDeck[key] = newValue
            }
        }
    }
    
    init(callSign: String, hullIntegrity: Int, deckReadings: [(deck: String, oxygen: Int)]) {
        self.callSign = callSign
        self.hullIntegrity = hullIntegrity
        
        for reading in deckReadings {
            if let d = Deck(rawValue: reading.deck) {
                self.oxygenByDeck[d] = reading.oxygen
            }
        }
    }
}

print("--- Level 5: Station ---")
let station = Station(callSign: "ALMA-7", hullIntegrity: 100, deckReadings: deckReadings)
let B = station.averageOxygen
print("Starting Average Oxygen (B): \(B)")

print("Diagnostics Access 1: \(station.fullDiagnostics)")
print("Diagnostics Access 2: \(station.fullDiagnostics)") // Не выведет "Running full scan..."

// 5.2
print("--- Level 5.2: Clamp Trap ---")
station.hullIntegrity = 130
print("Hull after 130: \(station.hullIntegrity)")
station.hullIntegrity = -40
print("Hull after -40: \(station.hullIntegrity)")
station.hullIntegrity = 55
print("Hull after 55: \(station.hullIntegrity)")
// Почему не уходит в бесконечный цикл: Swift предотвращает рекурсивный вызов наблюдателей.
// Присвоение внутри собственного didSet не вызывает этот же наблюдатель снова.


// MARK: Level 6 · Incident Reports

/*
// Report 1
// Expected: Уменьшение кислорода у экипажа.
// Actual: Уменьшается у ВРЕМЕННОЙ КОПИИ внутри цикла, оригинал не меняется.
// Rule: Структуры - Value type. Цикл `for var` создает копию.
// Fix:
for i in 0..<crewRoster.count {
    crewRoster[i].oxygen -= 10
}

// Report 2
// Expected: Уменьшение заряда только у podB.
// Actual: Уменьшился у обоих, так как оба указывают на один объект в памяти.
// Rule: Классы - Reference type.
// Fix:
let podA = TeleportPod(id: "A", chargeLevel: 100)
let podB = TeleportPod(id: "B", chargeLevel: 100) // Создаем НОВЫЙ экземпляр

// Report 3
// Expected: Добавление строки в массив.
// Actual: Не компилируется.
// Rule: Метод структуры, изменяющий её свойства, должен быть помечен словом `mutating`.
// Fix:
struct Logbook {
    var entries: [String] = []
    mutating func add(_ entry: String) {
        entries.append(entry)
    }
}

// Report 4
// Expected: Не компилируются оба присваивания.
// Actual: Ошибка только на `snapshot.oxygen`. `pod.chargeLevel` компилируется.
// Rule: `let` для структуры (Value Type) полностью "замораживает" объект и все его свойства.
//       `let` для класса (Reference Type) "замораживает" только саму ссылку,
//       но внутренние изменяемые (var) свойства объекта менять можно.
// Fix: Сделать snapshot переменной (var snapshot = ...).
*/


// MARK: Level 7 · Sealing the Black Box

final class FlightRecorder {
    // private запрещает чтение и запись переменной за пределами фигурных скобок этого класса.
    private var _entries: [String] = []
    
    // private(set) позволяет всем читать значение снаружи, но изменять его можно только внутри класса.
    private(set) var isSealed = false
    
    var count: Int { _entries.count }
    
    var transcript: String {
        var result = ""
        for e in _entries { result += e + "\n" }
        return result
    }
    
    func add(entry: String) {
        if !isSealed { _entries.append(entry) }
    }
    
    func seal() { isSealed = true }
    
    // fileprivate запрещает доступ из других файлов программы, но разрешает доступ из любого места внутри этого файла (например, свободной функции ниже).
    fileprivate func getRawEntries() -> [String] {
        return _entries
    }
}

func auditTranscript(of recorder: FlightRecorder) -> String {
    let raw = recorder.getRawEntries()
    return "Audited \(raw.count) entries."
}

/*
Попытка сломать Black Box:
let box = FlightRecorder()
box._entries.append("Hack") // Compiler Error: '_entries' is inaccessible due to 'private' protection level
box.isSealed = false        // Compiler Error: Cannot assign to property: 'isSealed' setter is inaccessible
*/


// MARK: Finale · Integrity Code

let D = AlarmLevel.level(forTotalMass: A).rawValue
let integrityCode = "\(A)-\(B)-\(C)-\(D)"
print("\nINTEGRITY CODE: \(integrityCode)")


// MARK: Bonus
// (Комментарий: deinit срабатывает при потере последней сильной ссылки на объект (reference counting)).
// === используется для проверки, указывают ли две переменные на одну и ту же область памяти (для классов).
// Для структур (CrewSnapshot) === не работает, так как у них нет уникального адреса, они просто копируются.


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why did CrewSnapshot get an initializer for free and TeleportPod did not?
 У структур (struct) в Swift есть встроенная фича — "почленный инициализатор" (memberwise initializer), который создается компилятором автоматически. Классы (class) этой фичи лишены, для них `init` нужно писать вручную.

 2. What does `mutating` do to self, and why do classes never need it?
 В структурах метод `mutating` говорит компилятору, что неявный параметр `self` передается как `inout`, позволяя перезаписать свойства самой структуры. Классам это не нужно, потому что `self` в классе — это всегда ссылка, мы меняем данные по адресу в памяти, а не пытаемся перезаписать саму ссылку.

 3. In Report 4 both values are `let`. What exactly does `let` freeze for a struct, and what does it freeze for a class?
 Для Struct `let` замораживает ВСЁ значение целиком, включая все внутренние `var` свойства.
 Для Class `let` замораживает ТОЛЬКО саму ссылку (указатель в памяти). Менять внутренние `var` свойства по этому указателю разрешено.

 4. Why must a lazy property be var? When does lazy change behaviour, not just performance?
 `lazy` обязан быть `var`, потому что его начальное значение отсутствует при инициализации (пока не произойдет первое обращение) — объект структурно "меняется" уже после своего создания. Поведение меняется (не только скорость), когда `lazy` зависит от внешних факторов (например, текущей даты, сети, или других свойств объекта `self`), которые могут измениться между созданием объекта и первым вызовом свойства.

 5. private vs fileprivate: where in your FlightRecorder would private be too strict?
 В `FlightRecorder` метод `getRawEntries()` должен отдавать массив для свободной функции `auditTranscript()`, которая лежит в том же файле, но за пределами класса. Если бы метод был `private`, функция `auditTranscript()` не смогла бы его вызвать. А `fileprivate` разрешает это.
*/
