# PSOAIGUI

PSOAIGUI (PowerShell OpenAI GUI) is a simple PowerShell-based graphical user interface for interacting with OpenAI's language models. It supports both Azure OpenAI and OpenAI API endpoints, allowing users to have conversations with AI models in a user-friendly interface.

## Features

- Graphical user interface for easy interaction
- Support for both Azure OpenAI and OpenAI API endpoints
- Conversation history with automatic titling
- Ability to save conversations as text files
- Easy configuration for API keys and endpoints

## Prerequisites

- Windows operating system
- PowerShell 5.1 or later
- Azure OpenAI account or OpenAI API account

## Setup

1. Clone this repository or download the `psoaigui.ps1` file.
2. Open the `psoaigui.ps1` file in a text editor.
3. Configure the following variables at the top of the script:
   - For OpenAI API:
     ```powershell
     $openaiUrl = "https://api.openai.com/v1/chat/completions"
     $openaiApiKey = "YOUR_OPENAI_API_KEY"
     $openaiModel = "gpt-3.5-turbo"  # or "gpt-4", depending on your subscription
     ```
   - For Azure OpenAI:
     ```powershell
     $azureEndpoint = "https://your-resource-name.openai.azure.com/openai/deployments/your-deployment-name/chat/completions?api-version=2023-03-15-preview"
     $azureApiKey = "YOUR_AZURE_API_KEY"
     ```
4. Set the `$apiChoice` variable to either "OpenAI" or "Azure" depending on which service you want to use.

## Usage

1. Run the `psoaigui.ps1` script in PowerShell:
   ```
   .\psoaigui.ps1
   ```
2. The GUI window will appear, allowing you to interact with the AI model.
3. Type your message in the input box and click "Send" or press Enter to send your message.
4. The AI's response will appear in the conversation history.
5. To start a new conversation, click the "New Conversation" button.
6. To save the current conversation, click the "Save Conversation" button.

## Customization

You can customize the system prompt by modifying the `$systemPrompt` variable in the script. This allows you to set the initial context or instructions for the AI model.

## Troubleshooting

If you encounter any issues:
1. Ensure your API keys are correct and have the necessary permissions.
2. Check that you've selected the correct API choice ("OpenAI" or "Azure").
3. Verify that your Azure OpenAI endpoint URL is correct if using Azure.
4. Make sure you have an active internet connection.

## Contributing

Contributions to improve PSOAIGUI are welcome. Please feel free to submit issues or pull requests on the project's GitHub repository.

## License

This project is open-source and available under the MIT License.
