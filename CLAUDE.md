# CLAUDE.md - AI Assistant Guide for Singapore Air Quality App

This document provides context and guidance for AI assistants (like Claude) working on this project.

## Project Overview

**Singapore Air Quality** is a native macOS/iOS/visionOS app built with SwiftUI that displays real-time air quality data for Singapore's five regions (North, South, East, West, Central). The app fetches PM2.5 and PSI readings from Singapore's government API and uses Apple's on-device language model (FoundationModels) to generate AI-powered summaries of air quality conditions.

### Key Features
- Real-time air quality data visualization on an interactive map
- PM2.5 and PSI readings for five Singapore regions
- AI-generated summaries using Apple Intelligence (FoundationModels framework)
- Local data persistence using GRDB
- Historical data charts with interactive scrubbing (last 12 hours, 24 hours, or 3 days)
- Support for macOS, iOS, and visionOS platforms

## Architecture

### Directory Structure

```
sgairquality/
├── sgairquality/               # Main app target
│   ├── API/                    # Network layer
│   │   ├── Models/            # API response models
│   │   └── API.swift          # API client
│   ├── Database/              # Local persistence (GRDB)
│   │   ├── Factory/           # Database factory
│   │   ├── Migrations/        # Schema migrations
│   │   ├── Records/           # Database record models
│   │   └── Database.swift     # Database manager
│   ├── Extensions/            # Swift extensions
│   ├── Observables/           # Observable models (@Observable)
│   ├── Services/              # Business logic services
│   │   ├── AirQualityClassification.swift  # Classification types
│   │   └── AirQualitySummaryService.swift  # LLM service
│   ├── Views/                 # SwiftUI views
│   └── SgAirQualityApp.swift  # App entry point
├── configuration/             # API keys and secrets
├── sgairqualityTests/         # Unit tests
└── sgairqualityUITests/       # UI tests
```

### Key Components

#### 1. API Layer (`API/`)
- **API.swift**: Handles HTTP requests to Singapore's government API
- **Models/**: Codable structs for API responses
- Fetches PM2.5 and PSI readings
- Error handling with custom `AirQualityResponseError`

#### 2. Database Layer (`Database/`)
- **Technology**: GRDB (SQLite wrapper)
- **Purpose**: Local persistence of air quality readings
- **Records**: `PM25Record`, `PSIRecord`
- **Migrations**: Version-controlled schema changes

#### 3. Services Layer (`Services/`)
- **AirQualitySummaryService**: Encapsulates LLM logic for generating summaries
  - Uses FoundationModels framework (Apple Intelligence)
  - Separates instructions (model behavior) from prompts (specific data)
  - Static methods for stateless operation
- **AirQualityClassification**: Type definitions for air quality bands and regions
  - Uses `@Generable` macro for structured LLM generation

#### 4. Observables (`Observables/`)
- **DataDownloaderModel**: Main data coordinator
  - Downloads latest readings from API
  - Backfills historical data for up to 3 days via `backfillHistoricalDataIfNeeded()`
  - Generates AI summaries via `AirQualitySummaryService.generateSummary(for:)`
  - Contains `classifyPM25(_:)` and `classifyPSI(_:)` classification logic
  - Uses Swift's `@Observable` macro
- **SingaporeMapViewModel**: Manages map state and sheet presentation flags

#### 5. Views (`Views/`)
- **SingaporeMapView**: Main map view with annotations
  - Platform-conditional toolbar items (iOS vs macOS/visionOS)
  - Displays AI-generated haze summary overlay using Liquid Glass effect
- **HistoricalDataView**: Interactive PM2.5/PSI charts with time range selection and scrubbing tooltip
- **LatestDataView**: Detailed latest readings view
- **ExplanationView**: Air quality guide and PSI computation explainer
- **ReadingsAnnotationView**: Map annotation UI
- **RegionalDataRow**: Regional data display component

## Important Patterns & Conventions

### 1. Air Quality Classification

**PM2.5 Bands** (µg/m³):
- Normal: 0-55
- Elevated: 56-150
- High: 151-250
- Very High: 251+

**PSI Bands**:
- Good: 0-50
- Moderate: 51-100
- Unhealthy: 101-200
- Very Unhealthy: 201-300
- Hazardous: 301+

### 2. LLM Integration (FoundationModels)

The app uses Apple's on-device language model via the FoundationModels framework:

**Proper Usage Pattern**:
```swift
// 1. Create instructions (define model behavior)
let instructions = "You are a Singapore haze advisory assistant..."

// 2. Initialize session with instructions
let session = LanguageModelSession(instructions: instructions)

// 3. Send prompts with specific data
let prompt = "Provide a summary based on these classifications..."
let response = try await session.respond(to: prompt)
```

**Important Notes**:
- Instructions define the model's role and guidelines
- Prompts contain specific data for each request
- Always check `SystemLanguageModel.default.availability` before use
- Handle cases where language model is unavailable

### 3. Testing Strategy

**Unit Tests** (`sgairqualityTests/`):
- Classification logic tests (PM2.5/PSI band boundaries)
- LLM output validation tests
- API response decoding tests
- Real-world scenario tests

**Key Test Suites** (all in `sgairqualityTests.swift`):
- `SgAirQualityTests`: API integration and database reads
- `AirQualityClassificationTests`: PM2.5/PSI classification logic and boundary tests
- `AirQualityClassificationIntegrityTests`: End-to-end classification data integrity

**LLM Test Approach**:
- Test for appropriate content (not exact text)
- Check for presence/absence of key terms
- Validate output length and format
- Use `Issue.record()` when language model unavailable

### 4. Platform Differences (iOS vs macOS)

**Toolbar Placements**:
```swift
#if os(iOS)
ToolbarItem(placement: .topBarLeading) { ... }
#else
ToolbarItem(placement: .navigation) { ... }
#endif
```

**Important**: `.topBarLeading` and `.topBarTrailing` are iOS-only. Use `.navigation` or `.automatic` for macOS.

## Code Style Guidelines

### SwiftUI & Swift Conventions
- **Naming**: PascalCase for types, camelCase for properties/methods
- **Properties**: Use `@State private var` for SwiftUI state, `let` for constants
- **Indentation**: 4 spaces
- **Imports**: Keep simple (SwiftUI, Foundation)
- **Architecture**: Prefer Swift's async/await over Combine
- **Testing**: Use the Testing framework (not XCTest)

### File Organization
Each file uses this comment structure:
```swift
// MARK: Environment
// MARK: App Storage
// MARK: State Objects
// MARK: State
// MARK: Bindings
// MARK: Constants
// MARK: Variables
// MARK: Public Methods
// MARK: Private Methods 
```

**Important**: In SwiftUI `View`s, Public and Private methods are included _after_ the view body.

### Comments
- Add descriptive comments for complex logic
- Document public APIs with `///` doc comments
- Avoid obvious comments
- Prefer self-documenting code

## Common Tasks

### Adding a New View
1. Create file in `Views/` directory
2. Follow SwiftUI view structure with proper MARK comments
3. Use `@State` for local state, inject observable models
4. Add accessibility identifiers for UI testing

### Modifying Air Quality Logic
1. Update classification logic in `DataDownloaderModel`
2. Update tests in `AirQualityClassificationTests`
3. If changing LLM behavior, update `AirQualitySummaryService`
4. Run tests to verify changes

### Working with the LLM
1. **Instructions**: Define in `buildInstructions()` - model's role/behavior
2. **Prompts**: Build in `buildPrompt(for:)` - specific classification data
3. **Test**: Add tests in `AirQualityClassificationIntegrityTests` or a new suite in `sgairqualityTests.swift`
4. **Validate**: Check for content appropriateness, not exact matches

### Database Changes
1. Add migration in `Database+Migrations.swift`
2. Update record models in `Database/Records/`
3. Test migration with existing data

## API & Secrets

### Configuration
- API keys stored in `configuration/Secrets.xcconfig`
- Use `Secrets.xcconfig.example` as template
- Never commit actual secrets to repository
- Access via `Configuration.apiKey`

### API Endpoints
The app uses Singapore government APIs:
- PM2.5 readings endpoint
- PSI readings endpoint
- Both return timestamped regional data

## Testing Guidelines

### Running Tests
```bash
# All tests
xcodebuild test -scheme sgairquality

# Specific test suite
xcodebuild test -scheme sgairquality -only-testing:sgairqualityTests/AirQualityClassificationTests
```

### Writing LLM Tests
- Use flexible validation (check for key terms, not exact text)
- Allow reasonable variation in word counts
- Skip tests when language model unavailable
- Test both good and bad air quality scenarios
- Validate that output doesn't contain restricted terms

### Example LLM Test Pattern
```swift
@Test func summaryValidation() async throws {
    let classifications = createScenario()

    guard let summary = try await service.generateSummary(for: classifications) else {
        Issue.record("Language model unavailable, skipping test")
        return
    }

    let lowercased = summary.lowercased()

    // Positive validation
    #expect(lowercased.contains("expected term"))

    // Negative validation
    #expect(!lowercased.contains("unwanted term"))
}
```

## Troubleshooting

### Common Issues

**LLM not working**:
- Check `SystemLanguageModel.default.availability`
- Ensure device supports Apple Intelligence
- Verify FoundationModels framework is imported

**Build errors on macOS**:
- Check for iOS-only APIs (e.g., `.topBarLeading`)
- Use platform conditionals `#if os(iOS)` / `#else`

**Tests failing**:
- LLM tests may fail if model unavailable
- Check for overly strict assertions
- Ensure test data matches current classification ranges

## Resources

### Documentation
- `Air Quality Information.md`: Air quality classification details
- `README.md`: User-facing documentation
- `Contributing.md`: Contribution guidelines
- `Agents.md`: AI agent information
- `PSI Computation`: is included for developer reference only, it is not bundled with the app

### External APIs
- Singapore Government API documentation
- Apple FoundationModels documentation
- GRDB documentation

## Best Practices for AI Assistants

1. **Read Before Writing**: Always read files before modifying
2. **Maintain Structure**: Follow existing MARK comment patterns
3. **Test Changes**: Run relevant tests after modifications
4. **Platform Awareness**: Consider iOS/macOS/visionOS differences
5. **LLM Considerations**: Separate instructions from prompts
6. **Documentation**: Update this file when adding major features
7. **Accessibility**: Add identifiers to UI elements for testing
8. **Type Safety**: Leverage Swift's strong type system

## Version Information

- **Swift**: 6.0+
- **iOS**: 26.0+
- **macOS**: 26.0+
- **visionOS**: 26.0+
- **Xcode**: 26.3+
- **Frameworks**: SwiftUI, FoundationModels, GRDB, Charts, MapKit

## Contact & Support

For questions about the codebase:
1. Check this CLAUDE.md file
2. Review relevant documentation files
3. Examine existing tests for usage patterns
4. Refer to inline code comments

---

*This document is maintained to help AI assistants understand and work effectively with this codebase. Update it when making significant architectural changes.*
