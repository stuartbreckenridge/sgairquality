//
//  AirQualitySummaryService.swift
//  sgairquality
//
//  Created by Stuart Breckenridge on 21/02/2026.
//

import Foundation
import FoundationModels

/// Service responsible for generating air quality summaries.
struct AirQualitySummaryService {

    // MARK: Public Methods

    /// Generates a summary of air quality conditions based on the provided classifications.
    /// - Parameter classifications: The air quality classifications for all regions.
    /// - Returns: A summary string if the language model is available, nil otherwise.
    static func generateSummary(for classifications: AirQualityClassification) async throws -> String? {
        let fallbackSummary = deterministicSummary(for: classifications)

        guard case .available = SystemLanguageModel.default.availability else {
            return nil
        }

        let instructions = buildInstructions()
        let generationOptions = GenerationOptions(temperature: 0.0)
        let session = LanguageModelSession(instructions: instructions)
        let prompt = buildPrompt(for: classifications, fallbackSummary: fallbackSummary)

        let maxAttempts = 2
        for _ in 1...maxAttempts {
            let trimmedContent: String
            do {
                let response = try await session.respond(to: prompt, options: generationOptions)
                trimmedContent = response.content.trimmingCharacters(in: .whitespacesAndNewlines)
            } catch {
                return fallbackSummary
            }

            if isValidGeneratedSummary(trimmedContent, fallbackSummary: fallbackSummary) {
                return trimmedContent
            }
        }

        return fallbackSummary
    }

    /// Builds a deterministic summary that is safe to show without model rewriting.
    /// - Parameter classifications: The air quality classifications for all regions.
    /// - Returns: A single-paragraph advisory summary.
    static func deterministicSummary(for classifications: AirQualityClassification) -> String {
        let assessment = AirQualityAssessment(classifications: classifications)
        return assessment.summary
    }

    // MARK: Private Methods

    /// Builds the instructions that define the model's role and behavior.
    /// - Returns: Instructions string for the language model.
    private static func buildInstructions() -> String {
        return """
            Rewrite the provided air quality summary only if you can keep the exact meaning. Use one paragraph under 50 words.

            Rules:
            - Preserve every classification, region, and advisory meaning from the provided baseline summary.
            - Do not introduce trends such as improving, worsening, deteriorated, or elevated unless the baseline uses them.
            - Do not say "Air quality is elevated".
            - Do not refer to advisories as restrictions.
            - Do not use Markdown.
            - Do not offer additional help.
            """
    }

    /// Builds the prompt with specific classification data.
    /// - Parameters:
    ///   - classifications: The air quality classifications for all regions.
    ///   - fallbackSummary: The deterministic summary to preserve.
    /// - Returns: A formatted prompt string.
    private static func buildPrompt(for classifications: AirQualityClassification, fallbackSummary: String) -> String {
        return """
            Baseline summary, which is factually correct and safe to return exactly:
            \(fallbackSummary)

            Source classifications:
            North: PM2.5 \(classifications.north.pm25Value) (\(classifications.north.pm25Band.rawValue)), PSI \(classifications.north.psiValue) (\(classifications.north.psiBand.rawValue))
            South: PM2.5 \(classifications.south.pm25Value) (\(classifications.south.pm25Band.rawValue)), PSI \(classifications.south.psiValue) (\(classifications.south.psiBand.rawValue))
            East: PM2.5 \(classifications.east.pm25Value) (\(classifications.east.pm25Band.rawValue)), PSI \(classifications.east.psiValue) (\(classifications.east.psiBand.rawValue))
            West: PM2.5 \(classifications.west.pm25Value) (\(classifications.west.pm25Band.rawValue)), PSI \(classifications.west.psiValue) (\(classifications.west.psiBand.rawValue))
            Central: PM2.5 \(classifications.central.pm25Value) (\(classifications.central.pm25Band.rawValue)), PSI \(classifications.central.psiValue) (\(classifications.central.psiBand.rawValue))
            """
    }

    /// Validates generated text before allowing it to replace the deterministic summary.
    /// - Parameters:
    ///   - summary: The generated summary.
    ///   - fallbackSummary: The deterministic summary used as the factual source.
    /// - Returns: Whether the generated summary satisfies basic safety and semantic checks.
    private static func isValidGeneratedSummary(_ summary: String, fallbackSummary: String) -> Bool {
        guard !summary.isEmpty else { return false }
        guard !summary.contains("#") else { return false }
        guard !summary.contains("\n") else { return false }
        guard wordCount(summary) <= 50 else { return false }

        let lowercasedSummary = summary.lowercased()
        guard !lowercasedSummary.contains("air quality is elevated") else { return false }
        guard !lowercasedSummary.contains("restriction") else { return false }
        guard !lowercasedSummary.contains("deteriorated") else { return false }
        guard !lowercasedSummary.contains("worsening") else { return false }
        guard !lowercasedSummary.contains("improving") else { return false }

        let requiredTerms = requiredTerms(from: fallbackSummary)
        return requiredTerms.allSatisfy { lowercasedSummary.contains($0) }
    }

    /// Counts words in a summary.
    /// - Parameter text: The summary text.
    /// - Returns: The number of non-empty whitespace-separated words.
    private static func wordCount(_ text: String) -> Int {
        text.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .count
    }

    /// Extracts terms that generated text must preserve from the deterministic summary.
    /// - Parameter summary: The deterministic summary.
    /// - Returns: A lowercased list of required terms.
    private static func requiredTerms(from summary: String) -> [String] {
        let lowercasedSummary = summary.lowercased()
        let candidateTerms = [
            "good",
            "acceptable",
            "moderate",
            "elevated",
            "high",
            "very high",
            "unhealthy",
            "very unhealthy",
            "hazardous",
            "normal activities",
            "reduce",
            "avoid",
            "vulnerable persons"
        ]

        return candidateTerms.filter { lowercasedSummary.contains($0) }
    }
}

private struct AirQualityAssessment {
    let summary: String

    init(classifications: AirQualityClassification) {
        let readings = [
            classifications.north,
            classifications.south,
            classifications.east,
            classifications.west,
            classifications.central
        ]

        let worstPM25Band = readings.map(\.pm25Band).max { $0.severity < $1.severity } ?? .normal
        let worstPSIBand = readings.map(\.psiBand).max { $0.severity < $1.severity } ?? .good
        let affectedRegions = Self.affectedRegions(readings: readings, worstPM25Band: worstPM25Band, worstPSIBand: worstPSIBand)
        let regionDescription = Self.regionDescription(for: affectedRegions)

        if worstPM25Band == .normal && worstPSIBand == .good {
            summary = "Air quality is good across all regions. PM2.5 is Normal and PSI is Good, so everyone can continue normal outdoor activities."
        } else if worstPM25Band == .normal && worstPSIBand == .moderate {
            summary = "Air quality is acceptable across Singapore. PM2.5 is Normal and PSI is Good to Moderate, so everyone can continue normal outdoor activities."
        } else if worstPM25Band.severity >= PM25Band.veryHigh.severity || worstPSIBand.severity >= PSIBand.veryUnhealthy.severity {
            summary = "Air quality is \(Self.overallBand(pm25Band: worstPM25Band, psiBand: worstPSIBand)) in \(regionDescription). Avoid outdoor activities, especially for vulnerable persons."
        } else if worstPM25Band.severity >= PM25Band.high.severity || worstPSIBand.severity >= PSIBand.unhealthy.severity {
            summary = "Air quality is \(Self.overallBand(pm25Band: worstPM25Band, psiBand: worstPSIBand)) in \(regionDescription). Reduce prolonged or strenuous outdoor activity; vulnerable persons should minimise outdoor activity."
        } else {
            summary = "PM2.5 is Elevated in \(regionDescription). Reduce strenuous outdoor activity; vulnerable persons should avoid strenuous activity."
        }
    }

    private static func affectedRegions(readings: [RegionalReading], worstPM25Band: PM25Band, worstPSIBand: PSIBand) -> [String] {
        readings.compactMap { reading in
            let matchesWorstPM25 = worstPM25Band != .normal && reading.pm25Band == worstPM25Band
            let matchesWorstPSI = worstPSIBand.severity >= PSIBand.unhealthy.severity && reading.psiBand == worstPSIBand
            return matchesWorstPM25 || matchesWorstPSI ? reading.region : nil
        }
    }

    private static func regionDescription(for regions: [String]) -> String {
        guard !regions.isEmpty else { return "Singapore" }
        guard regions.count < 5 else { return "all regions" }
        guard regions.count > 1 else { return regions[0] }

        return "\(regions.dropLast().joined(separator: ", ")) and \(regions.last ?? "")"
    }

    private static func overallBand(pm25Band: PM25Band, psiBand: PSIBand) -> String {
        if psiBand.severity >= PSIBand.unhealthy.severity {
            return psiBand.rawValue
        }

        return pm25Band.rawValue
    }
}
