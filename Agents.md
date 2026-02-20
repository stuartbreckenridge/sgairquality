#  Agents

### Where have agents been used?

1. Pull Requests: these are being reviewed by [CodeRabbit](https://coderabbit.ai) 🐇
2. Claude Agent: this is being used in Xcode 26.3 and has been used for the following:
    - The data models for API responses and the generic error model
    - The initial UI tests
    - Code commentary
    - It pulled data out of Air Quality Information to apply to LatestDataView section footers



### Where have agents failed?

1. Claude Agent (and, as an experiment, Codex) couldn't work out what was wrong with the `.codecov.yml` file. There are about 40 commits in `develop` where they were trying and failing to sort things. 
