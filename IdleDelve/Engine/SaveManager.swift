import Foundation

final class SaveManager {
    private let fileURL: URL

    /// `directory` is overridable so tests can point saves at an isolated
    /// temporary location instead of the real Documents directory.
    init(directory: URL? = nil, filename: String = "idledelve_save.json") {
        let baseDirectory = directory ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileURL = baseDirectory.appendingPathComponent(filename)
    }

    func save(_ state: GameState) {
        do {
            let data = try JSONEncoder().encode(state)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("IdleDelve save failed: \(error)")
        }
    }

    func load() -> GameState? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(GameState.self, from: data)
    }
}
