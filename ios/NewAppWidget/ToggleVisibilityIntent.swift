import AppIntents
import WidgetKit

struct ToggleVisibilityIntent: AppIntent {
    static var title: LocalizedStringResource = "Alternar Visibilidad"

    @MainActor
    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.bancolombia.homeWidgetPoc")
        let isHidden = defaults?.bool(forKey: "isHidden") ?? true
        
        if isHidden {
            print("🔄 Llamando al API para obtener el código...")

            // 🔥 Llamada real al API y parseo correcto
            if let fetchedCode = await fetchRandomCodeFromAPI() {
                print("✅ Código recibido desde API: \(fetchedCode)")
                let expiration = Date().addingTimeInterval(30)
                defaults?.set(expiration.timeIntervalSince1970, forKey: "expirationTimestamp")
                defaults?.set(fetchedCode, forKey: "widgetMessage")
            } else {
                print("⚠️ No se pudo obtener el código.")
                defaults?.set("ERROR", forKey: "widgetMessage")
            }
        } else {
            defaults?.set("******", forKey: "widgetMessage")
        }

        defaults?.set(!isHidden, forKey: "isHidden")
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }

    /// 🔥 Llama al API y parsea correctamente la lista de mapas
    private func fetchRandomCodeFromAPI() async -> String? {
        guard let url = URL(string: "https://random-data-api.com/api/number/random_number?size=6") else {
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                // Extraer los dígitos y concatenarlos
                let digits = jsonArray.compactMap { $0["digit"] as? Int }
                if digits.count == 6 {
                    let code = digits.map { String($0) }.joined()
                    return code
                }
            }
            return nil
        } catch {
            print("❌ Error en la llamada API: \(error)")
            return nil
        }
    }
}

