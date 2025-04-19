# gosTanya.ps1 - AI Question Answering Script

**Author:** Mas Gendon

## Description

`gosTanya.ps1` is a PowerShell script designed to interact with AI language models to answer questions provided by the user. It primarily targets models configured for Indonesian language responses and includes a fallback mechanism for robustness.

## Features

*   **AI Interaction:** Sends user questions to a configured AI API endpoint.
*   **Fallback Mechanism:** If the primary AI service (configured via `GosAPI*` variables) fails, it automatically attempts to use a secondary service (configured via `GroqAPI*` variables).
*   **Indonesian Language Focus:** The system prompt instructs the AI to respond in Indonesian.
*   **Command-Line Interface:** Accepts the user's question as a command-line argument.
*   **Input Validation:** Checks if a question argument is provided before proceeding.
*   **Error Handling:** Includes try-catch blocks to manage potential errors during API calls and script execution.
*   **Modular Design:** Imports functionality from `GosModule.psm1` (presumably for response formatting via `Format-Response`).

## Dependencies

*   `GosModule.psm1`: Required for core module functions, including `Format-Response`. This file must be located in the same directory as `gosTanya.ps1`.

## Configuration

The script relies on several global PowerShell variables for API configuration. These must be defined in the session before running the script:

**Primary API (e.g., OpenAI):**

*   `$Global:GosAPIKey`: API key for the primary service.
*   `$Global:GosAPIModel`: Model identifier (e.g., `gpt-4o`).
*   `$Global:GosAPIEndpoint`: The API endpoint URL.
*   `$Global:GosAPIMaxTokens`: Maximum tokens for the response.
*   `$Global:GosAPITemperature`: Sampling temperature for the response.

**Fallback API (e.g., Groq):**

*   `$Global:GroqAPIKey`: API key for the fallback service.
*   `$Global:GroqAPIModel`: Model identifier for the fallback service.
*   `$Global:GroqAPIEndpoint`: The fallback API endpoint URL.
*   `$Global:GroqAPIMaxTokens`: Maximum tokens for the fallback response.
*   `$Global:GroqAPITemperature`: Sampling temperature for the fallback response.

## Usage

Run the script from the PowerShell command line, providing the question as an argument:

```powershell
.\gosTanya.ps1 "Siapa presiden Indonesia saat ini?"
```

The script will then contact the configured AI service and display the formatted response.

## Error Handling

*   If no question is provided as an argument, an error message is displayed, and the script exits.
*   If the primary API call fails, a warning is shown, and the script attempts the fallback API.
*   If both API calls fail, an error message detailing the failure is displayed.
*   General script execution errors are caught and displayed. 