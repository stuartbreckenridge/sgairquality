#  SG Air Quality

This app uses data from [data.gov.sg](https://data.gov.sg) to display the current air quality across Singapore. 

More than that, it is designed to integrate AI agents into as many parts of the developer workflow as possible. For example, Claude Agent is used in Xcode and CodeRabbit is used for Pull Request summaries. As the app progresses through development, I'll document where agents are being used.

## Functionality

The app will:

- use SwiftUI
- download the latest air quality data from [data.gov.sg](https://data.gov.sg) (PSI, PM2.5, and more)
- display that data to the user across Singapore regions (North, East, South, West, and Central)
- keep historical data for around 60 days (probably in a SQLite database using GRDB)
    - use background tasks to download data frequently (fine for iOS, need to think about macOS)
    - historical data _may_ be presented using Swift Charts
- notify the user when air quality reaches unsafe readings
- support widgets
- support localisation

## Setup

Access to [data.gov.sg](https://data.gov.sg) APIs requires an API key. You can get one from the [data.gov.sg sign-in page](https://data.gov.sg/signin). Once you have your API key, update `API_KEY` in `configuration/Secrets.xcconfig.example` and then remove the `.example` suffix from the file name. `Secrets.xcconfig` is ignored in `.gitignore` so will not be committed to GitHub.


## Branch Workflow Configuration

As the app is open-source, there are some branch management considerations following GitFlow. 

**Base Branches** (long-lived, foundational)
- **`main`** — This is the production-ready branch. 
- **`develop`** — This is the integration branch where completed work accumulates before going to `main`.

**Topic Branches** (short-lived, prefixed)
These are created off `develop` for specific purposes and merged back when done:
- **`bugfix/*`** — for fixing non-critical bugs
- **`feature/*`** — for developing new features
- **`hotfix/*`** — for urgent production fixes (typically branched from `main` directly)
- **`release/*`** — for stabilizing a release before it merges to `main`

**The overall flow looks like:**

```
feature/* ─┐
bugfix/*  ─┼──► develop ──► main
release/* ─┘
hotfix/*  ──────────────► main
```

