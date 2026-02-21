//
//  AirQualitySummaryService.swift
//  sgairquality
//
//  Created by Stuart Breckenridge on 21/02/2026.
//

import Foundation
import FoundationModels

/// Service responsible for generating AI-powered air quality summaries
struct AirQualitySummaryService {
    
    // MARK: Properties
    
    private let languageModel: SystemLanguageModel
    
    // MARK: Initialization
    
    init(languageModel: SystemLanguageModel = .default) {
        self.languageModel = languageModel
    }
    
    // MARK: Public Methods
    
    /// Generates a summary of air quality conditions based on the provided classifications
    /// - Parameter classifications: The air quality classifications for all regions
    /// - Returns: A summary string if the language model is available, nil otherwise
    /// - Throws: Any errors from the language model session
    func generateSummary(for classifications: AirQualityClassification) async throws -> String? {
        guard case .available = languageModel.availability else {
            return nil
        }
        
        let session = LanguageModelSession()
        let prompt = buildPrompt(for: classifications)
        let response = try await session.respond(to: prompt)
        
        return response.content
    }
    
    // MARK: Private Methods
    
    /// Builds the prompt text for the language model
    /// - Parameter classifications: The air quality classifications for all regions
    /// - Returns: A formatted prompt string
    private func buildPrompt(for classifications: AirQualityClassification) -> String {
        let situationSummary = analyzeSituation(classifications)
        
        return """
            You are a Singapore haze advisory assistant. Provide a brief summary in approximately 45 words based ONLY on the classifications shown.
            
            ACTUAL CLASSIFICATIONS (use ONLY these - do not invent different values):
            
            North: PM2.5 band is "\(classifications.north.pm25Band.rawValue)", PSI band is "\(classifications.north.psiBand.rawValue)"
            South: PM2.5 band is "\(classifications.south.pm25Band.rawValue)", PSI band is "\(classifications.south.psiBand.rawValue)"
            East: PM2.5 band is "\(classifications.east.pm25Band.rawValue)", PSI band is "\(classifications.east.psiBand.rawValue)"
            West: PM2.5 band is "\(classifications.west.pm25Band.rawValue)", PSI band is "\(classifications.west.psiBand.rawValue)"
            Central: PM2.5 band is "\(classifications.central.pm25Band.rawValue)", PSI band is "\(classifications.central.psiBand.rawValue)"
            
            SITUATION: \(situationSummary)
            
            Advisories by Band:
            - "Normal" PM2.5 + "Good" or "Moderate" PSI = Everyone can do normal activities, NO advisories
            - "Elevated" PM2.5 = Reduce strenuous activity, vulnerable persons avoid strenuous activity
            - "Unhealthy" PSI = Reduce prolonged/strenuous exertion, vulnerable persons minimise outdoor activity
            
            STRICT INSTRUCTION: Your summary must match the ACTUAL CLASSIFICATIONS listed above. Do NOT say a region is "Elevated" if it shows "Normal". Do NOT recommend advisories if ALL bands are Normal/Good/Moderate. Do NOT refer to advisories as restrictions. Do NOT use the word restrictions.
            
            Write a single paragraph describing the air quality situation and recommendations.
            """
    }
    
    /// Analyzes the overall air quality situation across all regions
    /// - Parameter classifications: The air quality classifications for all regions
    /// - Returns: A summary string describing the overall situation
    private func analyzeSituation(_ classifications: AirQualityClassification) -> String {
        let allPM25Bands = [
            classifications.north.pm25Band,
            classifications.south.pm25Band,
            classifications.east.pm25Band,
            classifications.west.pm25Band,
            classifications.central.pm25Band
        ]
        
        let allPSIBands = [
            classifications.north.psiBand,
            classifications.south.psiBand,
            classifications.east.psiBand,
            classifications.west.psiBand,
            classifications.central.psiBand
        ]
        
        let allPM25Normal = allPM25Bands.allSatisfy { $0 == .normal }
        let hasElevatedOrWorsePM25 = allPM25Bands.contains(where: { $0 != .normal })
        let allPSIGoodOrModerate = allPSIBands.allSatisfy { $0 == .good || $0 == .moderate }
        
        if allPM25Normal && allPSIGoodOrModerate {
            return "ALL regions show Normal PM2.5 and Good/Moderate PSI. This means air quality is GOOD and NO outdoor activity advisories apply to anyone."
        } else if hasElevatedOrWorsePM25 || !allPSIGoodOrModerate {
            return "Some regions show elevated pollution requiring activity advisories."
        } else {
            return "Mixed air quality conditions."
        }
    }
}
