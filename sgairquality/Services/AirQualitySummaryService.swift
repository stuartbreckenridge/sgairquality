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
    
    // MARK: Public Methods
    
    /// Generates a summary of air quality conditions based on the provided classifications
    /// - Parameter classifications: The air quality classifications for all regions
    /// - Returns: A summary string if the language model is available, nil otherwise
    /// - Throws: Any errors from the language model session
    static func generateSummary(for classifications: AirQualityClassification) async throws -> String? {
        guard case .available = SystemLanguageModel.default.availability else {
            return nil
        }
        
        let instructions = buildInstructions()
        let session = LanguageModelSession(instructions: instructions)
        let prompt = buildPrompt(for: classifications)
        let response = try await session.respond(to: prompt)
        
        return response.content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: Private Methods
    
    /// Builds the instructions that define the model's role and behavior
    /// - Returns: Instructions string for the language model
    private static func buildInstructions() -> String {
        return """
            You are a haze advisory assistant. Provide clear, helpful summaries of current air quality conditions based on PM2.5 and PSI classifications for Singapore's five regions (North, South, East, West, Central).
            
            Guidelines:
            - Provide summaries in approximately 45-60 words
            - Base your summary ONLY on the classifications provided in the prompt
            - Do NOT invent or assume different classification values
            - When ALL regions show Normal PM2.5 and Good/Moderate PSI: State that air quality is good and outdoor activities are safe for everyone
            - Do NOT refer to advisories as "restrictions"
            - Do NOT use the word "restrictions"
            - Spefically mention "Very High", "Very Unhealthy", or "Hazardous" ONLY when the classifications are provided in the prompt
            - Write a single paragraph describing the air quality situation and recommendations
            
            Advisory Guidelines by Band:
            - "Normal" PM2.5 + "Good" or "Moderate" PSI = Everyone can do normal activities, NO advisories needed
            - "Elevated" PM2.5 = Recommend reducing strenuous activity, vulnerable persons should avoid strenuous activity
            - "Unhealthy" PSI = Recommend reducing prolonged/strenuous exertion, vulnerable persons should minimise outdoor activity
            - "Very High" PM2.5 or "Very Unhealthy"/"Hazardous" PSI = Strong advisories to avoid outdoor activities
            """
    }
    
    /// Builds the prompt with specific classification data
    /// - Parameter classifications: The air quality classifications for all regions
    /// - Returns: A formatted prompt string
    private static func buildPrompt(for classifications: AirQualityClassification) -> String {
        let situationSummary = analyzeSituation(classifications)
        
        return """
            Provide a summary based on these ACTUAL CLASSIFICATIONS:
            
            North: PM2.5 band is "\(classifications.north.pm25Band.rawValue)", PSI band is "\(classifications.north.psiBand.rawValue)"
            South: PM2.5 band is "\(classifications.south.pm25Band.rawValue)", PSI band is "\(classifications.south.psiBand.rawValue)"
            East: PM2.5 band is "\(classifications.east.pm25Band.rawValue)", PSI band is "\(classifications.east.psiBand.rawValue)"
            West: PM2.5 band is "\(classifications.west.pm25Band.rawValue)", PSI band is "\(classifications.west.psiBand.rawValue)"
            Central: PM2.5 band is "\(classifications.central.pm25Band.rawValue)", PSI band is "\(classifications.central.psiBand.rawValue)"
            
            Overall Situation: \(situationSummary)
            """
    }
    
    /// Analyzes the overall air quality situation across all regions
    /// - Parameter classifications: The air quality classifications for all regions
    /// - Returns: A summary string describing the overall situation
    private static func analyzeSituation(_ classifications: AirQualityClassification) -> String {
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
