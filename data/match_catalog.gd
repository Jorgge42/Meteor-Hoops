class_name MatchCatalog
extends RefCounted

const MATCHES := [
    {
        "id": "match_01", "number": 1, "title": "PRIMEIRO QUIQUE", "school": "QUARTZ ACADEMY",
        "subtitle": "A estreia oficial da Vale Fóssil.", "color": "8b5cf6", "playable": true,
        "pre_chapter": "res://data/chapter_01.tres", "post_chapter": "res://data/chapter_01_post.tres"
    },
    {
        "id": "match_02", "number": 2, "title": "RAÍZES EM MOVIMENTO", "school": "CANOPY INSTITUTE",
        "subtitle": "Uma escola da floresta que nunca para de cortar e trocar posições.", "color": "22c55e", "playable": true,
        "pre_chapter": "res://data/chapter_02.tres", "post_chapter": "res://data/chapter_02_post.tres"
    },
    {
        "id": "match_03", "number": 3, "title": "PRESSÃO VULCÂNICA", "school": "EMBER RIDGE",
        "subtitle": "Ataque agressivo, pressão alta e decisões em velocidade.", "color": "f97316", "playable": true,
        "pre_chapter": "res://data/chapter_03.tres", "post_chapter": "res://data/chapter_03_post.tres"
    },
    {
        "id": "match_04", "number": 4, "title": "MARÉ ALTA", "school": "TIDEFANG SCHOOL",
        "subtitle": "Defesa móvel, inversões rápidas e leitura do lado fraco.", "color": "06b6d4", "playable": true,
        "pre_chapter": "res://data/chapter_04.tres", "post_chapter": "res://data/chapter_04_post.tres"
    },
    {
        "id": "match_05", "number": 5, "title": "ACIMA DO ARO", "school": "SKYCREST ACADEMY",
        "subtitle": "Timing de rebote, cortes verticais e alley-oops acima da defesa.", "color": "38bdf8", "playable": true,
        "pre_chapter": "res://data/chapter_05.tres", "post_chapter": "res://data/chapter_05_post.tres"
    },
    {
        "id": "match_06", "number": 6, "title": "PAREDE DE CHIFRES", "school": "IRONHORN INSTITUTE",
        "subtitle": "Corta-luzes, box-out, jogo de costas, faltas e a partida mais física da Rota.", "color": "b6a38a", "playable": true,
        "pre_chapter": "res://data/chapter_06.tres", "post_chapter": "res://data/chapter_06_post.tres"
    },
    {
        "id": "match_07", "number": 7, "title": "LUZES APAGADAS",
        "school": "NIGHTCLAW ACADEMY",
        "subtitle": "Linhas de passe, fintas, turnovers e transição sob pressão.",
        "color": "6d5dfc", "playable": true,
        "pre_chapter": "res://data/chapter_07.tres",
        "post_chapter": "res://data/chapter_07_post.tres"
    },
    {"id": "match_08", "number": 8, "title": "O JOGO DOS DADOS", "school": "FOSSIL TECH", "subtitle": "A escola mais analítica do campeonato tenta prever cada posse.", "color": "14b8a6", "playable": false},
    {"id": "match_09", "number": 9, "title": "O RUGIDO", "school": "APEX DOMINION", "subtitle": "Semifinal. O melhor time físico antes da coroa.", "color": "eab308", "playable": false},
    {"id": "match_10", "number": 10, "title": "O METEORO", "school": "TYRANT CROWN ACADEMY", "subtitle": "Final. Drax espera no centro da quadra pelo Troféu Meteoro.", "color": "dc2626", "playable": false}
]

static func get_match(number: int) -> Dictionary:
    for item in MATCHES:
        if int(item.get("number", 0)) == number:
            return item.duplicate(true)
    return {}

static func get_match_by_id(match_id: String) -> Dictionary:
    for item in MATCHES:
        if String(item.get("id", "")) == match_id:
            return item.duplicate(true)
    return {}

static func all_matches() -> Array:
    return MATCHES.duplicate(true)

static func home_roster(progress: Dictionary = {}) -> Array:
    var roster := [
        _player("kiro", "Kiro", "Velociraptor", "Armador", 92, 70, 84, 78, 38, 1.78, "Rastro Meteoro", "Velocidade é sua arma. Em transição, Kiro acelera mais do que qualquer companheiro."),
        _player("luma", "Luma", "Parasaurolophus", "Ala", 78, 84, 76, 66, 48, 1.88, "Eco Lunar", "Especialista em espaço. Arremessos realmente livres recebem um pequeno bônus de qualidade."),
        _player("bato", "Bato", "Ankylosaurus", "Pivô", 52, 62, 60, 88, 93, 2.18, "Muralha Fóssil", "Protege a área pintada. Tem vantagem em rebotes e tentativas de toco."),
        _player("nilo", "Nilo", "Compsognathus", "Ala", 90, 76, 72, 60, 28, 1.60, "Faísca Fóssil", "Pequeno e extremamente rápido. Entra do banco para mudar o ritmo da partida."),
        _player("mako", "Mako", "Triceratops", "Pivô", 58, 68, 55, 84, 95, 2.28, "Carga Tríplice", "Força máxima do elenco. Protege a bola e termina jogadas físicas perto do aro.")
    ]
    for i in range(roster.size()):
        roster[i] = _apply_progression_bonus(roster[i], progress)
    return roster

static func _apply_progression_bonus(entry: Dictionary, progress: Dictionary) -> Dictionary:
    var result := entry.duplicate(true)
    var id := String(result.get("id", ""))
    var state: Dictionary = progress.get(id, {})
    var level := maxi(1, int(state.get("level", 1)))
    var bonus := mini(5, level - 1)
    result["level"] = level
    result["xp"] = int(state.get("xp", 0))
    result["upgrade_points"] = int(state.get("upgrade_points", 0))
    result["upgrades"] = state.get("upgrades", {}).duplicate(true)

    if bonus > 0 and id == "kiro":
        result["speed"] = mini(99, int(result["speed"]) + bonus)
        result["passing"] = mini(99, int(result["passing"]) + int(ceil(float(bonus) * 0.5)))
    elif bonus > 0 and id == "luma":
        result["shooting"] = mini(99, int(result["shooting"]) + bonus)
        result["passing"] = mini(99, int(result["passing"]) + int(floor(float(bonus) * 0.5)))
    elif bonus > 0 and id == "bato":
        result["defense"] = mini(99, int(result["defense"]) + bonus)
        result["strength"] = mini(99, int(result["strength"]) + bonus)
    elif bonus > 0 and id == "nilo":
        result["speed"] = mini(99, int(result["speed"]) + bonus)
        result["shooting"] = mini(99, int(result["shooting"]) + int(floor(float(bonus) * 0.5)))
    elif bonus > 0 and id == "mako":
        result["strength"] = mini(99, int(result["strength"]) + bonus)
        result["defense"] = mini(99, int(result["defense"]) + int(ceil(float(bonus) * 0.5)))

    var chosen: Dictionary = state.get("upgrades", {})
    for stat in ["speed", "shooting", "passing", "defense", "strength"]:
        var extra := int(chosen.get(stat, 0))
        if extra > 0:
            result[stat] = mini(99, int(result.get(stat, 0)) + extra)
    return result

static func away_roster(match_number: int) -> Array:
    if match_number == 7:
        return [
            _player("nyx", "Nyx", "Troodon", "Armador", 93, 78, 91, 95, 44, 1.74, "Visão Noturna", "Capitã da Nightclaw. Memoriza padrões e fecha a linha de passe antes de atacar a bola."),
            _player("shade", "Shade", "Dromaeosaurus", "Ala", 92, 81, 79, 93, 58, 1.86, "Garra Fantasma", "Especialista em negar recepções e transformar passes previsíveis em contra-ataques."),
            _player("onyx", "Onyx", "Megaraptor", "Pivô", 77, 70, 72, 91, 88, 2.18, "Sombra Longa", "Protege o aro sem abandonar as linhas curtas de passe."),
            _player("whisper", "Whisper", "Compsognathus", "Ala", 97, 73, 82, 86, 25, 1.58, "Passo Silencioso", "Reserva velocista que pressiona a bola e acelera toda posse recuperada."),
            _player("eclipse", "Eclipse", "Dilophosaurus", "Ala", 86, 86, 76, 88, 63, 1.90, "Dupla Sombra", "Arremessador de transição que pune a defesa quando todos correm para proteger o aro.")
        ]
    if match_number == 6:
        return [
            _player("brakk", "Brakk", "Triceratops", "Armador", 70, 74, 86, 88, 94, 2.05, "Aríete", "Capitão da Ironhorn. Usa o corpo para proteger a bola e transformar contato em vantagem."),
            _player("hornet", "Hornet", "Styracosaurus", "Ala", 76, 81, 72, 84, 89, 1.96, "Cerca de Espinhos", "Ala físico que corta depois do bloqueio e pune trocas defensivas."),
            _player("granite", "Granite", "Torosaurus", "Pivô", 55, 66, 69, 94, 98, 2.32, "Muralha de Basalto", "O maior protetor de aro enfrentado até aqui. Box-out e força são sua linguagem."),
            _player("rivet", "Rivet", "Pachyrhinosaurus", "Ala", 73, 76, 78, 82, 91, 1.92, "Ombro de Ferro", "Reserva versátil para manter a pressão física sem perder circulação de bola."),
            _player("anvil", "Anvil", "Centrosaurus", "Pivô", 50, 62, 61, 90, 99, 2.30, "Bigorna", "Reserva de força extrema. Vive no garrafão e domina posição antes do rebote.")
        ]
    if match_number == 5:
        return [
            _player("zephyr", "Zephyr", "Microraptor", "Armador", 95, 78, 90, 74, 30, 1.62, "Corrente Ascendente", "Capitão da Skycrest. Usa mudanças de velocidade para criar passes acima da defesa."),
            _player("talon", "Talon", "Deinonychus", "Ala", 91, 82, 76, 86, 68, 1.91, "Garra Aérea", "Cortador agressivo. Vive atacando o espaço atrás do último defensor."),
            _player("gale", "Gale", "Aerosteon", "Pivô", 72, 70, 72, 84, 91, 2.24, "Turbina Óssea", "Finalizador vertical da Skycrest e principal alvo de alley-oop."),
            _player("nimbus", "Nimbus", "Ornithomimus", "Ala", 96, 74, 80, 69, 36, 1.78, "Passo de Nuvem", "Reserva velocista para quebrar a primeira linha defensiva."),
            _player("aerie", "Aerie", "Oviraptor", "Ala", 86, 86, 82, 72, 45, 1.82, "Pena de Precisão", "Reserva de arremesso que pune defesas que afundam para proteger o aro.")
        ]
    if match_number == 4:
        return [
            _player("riptide", "Riptide", "Spinosaurus", "Armador", 82, 79, 92, 78, 68, 2.02, "Correnteza", "Capitão da Tidefang. Inverte o lado da quadra antes que a defesa consiga respirar."),
            _player("coral", "Coral", "Suchomimus", "Ala", 80, 84, 82, 74, 66, 1.94, "Onda Azul", "Arremessadora paciente. Vive no lado fraco esperando a bola chegar."),
            _player("reef", "Reef", "Baryonyx", "Pivô", 67, 68, 72, 87, 90, 2.25, "Recife", "Protege o aro e funciona como pivô de passes no centro da quadra."),
            _player("splash", "Splash", "Gallimimus", "Ala", 91, 74, 78, 68, 32, 1.76, "Maré Rápida", "Reserva de velocidade que transforma inversões em cortes nas costas da defesa."),
            _player("brine", "Brine", "Irritator", "Pivô", 63, 72, 70, 84, 92, 2.22, "Água Pesada", "Reserva físico para fechar o garrafão e manter a circulação de bola viva.")
        ]
    if match_number == 3:
        return [
            _player("pyra", "Pyra", "Carnotaurus", "Armador", 89, 78, 76, 82, 70, 1.90, "Arranque de Lava"),
            _player("cinder", "Cinder", "Utahraptor", "Ala", 88, 83, 72, 75, 62, 1.88, "Chama Curta"),
            _player("basalt", "Basalt", "Ceratosaurus", "Pivô", 66, 65, 60, 86, 92, 2.24, "Parede Magmática"),
            _player("scoria", "Scoria", "Ornithomimus", "Ala", 93, 72, 70, 70, 34, 1.75, "Estouro"),
            _player("magma", "Magma", "Majungasaurus", "Pivô", 60, 68, 55, 83, 95, 2.30, "Núcleo Quente")
        ]
    if match_number == 2:
        return [
            _player("fern", "Fern", "Dryosaurus", "Armador", 86, 72, 88, 70, 34, 1.72, "Passo de Cipó"),
            _player("mira", "Mira", "Oviraptor", "Ala", 84, 80, 78, 68, 40, 1.80, "Folha Cortante"),
            _player("moss", "Moss", "Iguanodon", "Pivô", 64, 66, 64, 84, 88, 2.16, "Raiz Profunda"),
            _player("pip", "Pip", "Hypsilophodon", "Ala", 91, 70, 75, 62, 26, 1.58, "Brotar"),
            _player("cedar", "Cedar", "Kentrosaurus", "Pivô", 56, 62, 58, 88, 94, 2.22, "Espinhos Verdes")
        ]
    return [
        _player("silex", "Silex", "Troodon", "Armador", 84, 73, 86, 75, 42, 1.72, "Leitura de Quartzo"),
        _player("vexa", "Vexa", "Dilophosaurus", "Ala", 81, 82, 70, 72, 55, 1.84, "Dupla Fenda"),
        _player("crag", "Crag", "Pachycephalosaurus", "Pivô", 61, 60, 58, 86, 90, 2.12, "Impacto Mineral"),
        _player("rhex", "Rhex", "Gallimimus", "Ala", 88, 71, 74, 65, 36, 1.82, "Passo Cristal"),
        _player("tarka", "Tarka", "Styracosaurus", "Pivô", 55, 64, 58, 82, 92, 2.20, "Parede de Quartzo")
    ]

static func _player(id_value: String, display_name: String, species: String, role: String, speed: int, shooting: int, passing: int, defense: int, strength: int, height: float, instinct: String, bio: String = "") -> Dictionary:
    return {
        "id": id_value, "display_name": display_name, "species": species, "role": role,
        "speed": speed, "shooting": shooting, "passing": passing, "defense": defense,
        "strength": strength, "height": height, "instinct": instinct, "bio": bio
    }
