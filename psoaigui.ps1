# Import the necessary assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Speech

# Define your OpenAI URL, API key
$openaiUrl = "https://api.openai.com/v1/chat/completions"
$openaiApiKey = "YOUR_OPENAI_API_KEY"

# Define your Azure OAI endpoint, API key
$endpoint = "https://endpointname.openai.azure.com/openai/deployments/deplyment/chat/completions?api-version=2023-03-15-preview"
$apiKey = "YOUR_AZURE_API_KEY"

# Define your system prompt
$systemPrompt = "You are an AI assistant that helps people find information."

# Define headers
$headers = @{
    "Content-Type" = "application/json"
    "api-key" = $apiKey
}

# Define body
$body = @{
    messages = @(
        @{
            role = "system"
            content = $systemPrompt
        }
    )
}

# Initialize Speech Synthesizer for voice output
$synthesizer = New-Object System.Speech.Synthesis.SpeechSynthesizer

# Function to send a request and get a response
function Send-ChatRequest {
    param (
        [string]$message
    )

    # Add user message to the body
    $body.messages += @{
        role = "user"
        content = $message
    }

    # Convert body to JSON with correct encoding
    $jsonBody = $body | ConvertTo-Json -Depth 10

    try {
        # Send the request with UTF-8 encoding
        $response = Invoke-WebRequest -Uri $endpoint `
            -Headers $headers `
            -Method Post `
            -Body $jsonBody `
            -ContentType "application/json; charset=utf-8"

        # Parse the response
        $responseContent = $response.Content | ConvertFrom-Json

        # Extract the assistant's message
        $assistantMessage = $responseContent.choices[0].message.content

        # Add assistant's message to the body
        $body.messages += @{
            role = "assistant"
            content = $assistantMessage
        }

        # Return the assistant's message
        return $assistantMessage
    }
    catch {
        Write-Host "Error sending request: $_" -ForegroundColor Red
        return "Sorry, an error occurred while processing your request."
    }
}

# Function to save the conversation
function Save-Conversation {
    # Generate a filename with timestamp
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

    # Generate a title
    $title = Generate-Title

    if ($title) {
        # Remove invalid characters from title and limit length
        $titleClean = [regex]::Replace($title, '[^\w\-. ]', '').Trim()
        $titleClean = $titleClean.Substring(0, [Math]::Min(50, $titleClean.Length))
        $filename = "$titleClean_$timestamp.txt"
    }
    else {
        $filename = "Conversation_$timestamp.txt"
    }

    # Build the conversation text
    $conversationText = ""
    foreach ($message in $body.messages) {
        $role = $message.role
        $content = $message.content
        $conversationText += "${role}:`n${content}`n`n"
    }

    # Save to file
    $conversationText | Out-File -FilePath $filename -Encoding UTF8

    [System.Windows.Forms.MessageBox]::Show("Conversation saved to $filename", "Conversation Saved", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}

# Function to generate a title for the conversation
function Generate-Title {
    # Create a copy of messages without modifying the original $body.messages
    $titleMessages = $body.messages.Clone()

    # Add the user's request for a title
    $titleMessages += @{
        role = "user"
        content = "Please provide a short, descriptive title for this conversation, no longer than 10 words, and without quotation marks."
    }

    $titleBody = @{
        messages = $titleMessages
    }

    $jsonBody = $titleBody | ConvertTo-Json -Depth 10

    try {
        # Send the request with UTF-8 encoding
        $response = Invoke-WebRequest -Uri $endpoint `
            -Headers $headers `
            -Method Post `
            -Body $jsonBody `
            -ContentType "application/json; charset=utf-8"

        # Parse the response
        $responseContent = $response.Content | ConvertFrom-Json

        # Extract the assistant's message
        $title = $responseContent.choices[0].message.content

        # Extract the first line and clean it
        $titleLines = $title -split "`n"
        $titleFirstLine = $titleLines[0]
        $titleClean = [regex]::Replace($titleFirstLine, '[^\w\-. ]', '').Trim()

        return $titleClean
    }
    catch {
        Write-Host "Error generating title: $_" -ForegroundColor Red
        return $null
    }
}

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Azure OpenAI Chat"
$form.Size = New-Object System.Drawing.Size(600, 500)
$form.StartPosition = "CenterScreen"

# Create the conversation display (RichTextBox)
$conversationBox = New-Object System.Windows.Forms.RichTextBox
$conversationBox.Size = New-Object System.Drawing.Size(570, 350)
$conversationBox.Location = New-Object System.Drawing.Point(10, 10)
$conversationBox.ReadOnly = $true
$conversationBox.BackColor = [System.Drawing.Color]::White
$conversationBox.Anchor = "Top, Left, Right, Bottom"

# Create the input textbox
$inputBox = New-Object System.Windows.Forms.TextBox
$inputBox.Size = New-Object System.Drawing.Size(480, 20)
$inputBox.Location = New-Object System.Drawing.Point(10, 370)
$inputBox.Anchor = "Left, Bottom, Right"

# Create the send button
$sendButton = New-Object System.Windows.Forms.Button
$sendButton.Text = "Send"
$sendButton.Size = New-Object System.Drawing.Size(75, 23)
$sendButton.Location = New-Object System.Drawing.Point(500, 368)
$sendButton.Anchor = "Bottom, Right"

# Create the voice input button
$voiceButton = New-Object System.Windows.Forms.Button
$voiceButton.Text = "Voice Input"
$voiceButton.Size = New-Object System.Drawing.Size(100, 23)
$voiceButton.Location = New-Object System.Drawing.Point(10, 400)
$voiceButton.Anchor = "Bottom, Left"

# Event handler for send button click
$sendButton.Add_Click({
    Send-UserMessage
})

# Function to handle sending user messages
function Send-UserMessage {
    $userMessage = $inputBox.Text.Trim()
    if ($userMessage -ne "") {
        # Display user's message
        $conversationBox.SelectionColor = [System.Drawing.Color]::Blue
        $conversationBox.AppendText("You:`n$userMessage`n`n")
        $conversationBox.ScrollToCaret()

        # Clear input box
        $inputBox.Text = ""

        # Check for special commands
        if ($userMessage -eq "exit") {
            Save-Conversation
            $form.Close()
        }
        elseif ($userMessage -eq "save") {
            Save-Conversation
        }
        elseif ($userMessage -eq "clear") {
            # Clear the conversation
            $body.messages = @(
                @{
                    role = "system"
                    content = $systemPrompt
                }
            )
            $conversationBox.Clear()
        }
        elseif ($userMessage -eq "help") {
            $helpMessage = "Available commands:`n'exit' - Exit the chat and save the conversation.`n'save' - Save the current conversation to a file.`n'clear' - Clear the conversation history.`n'help' - Display this help message."
            [System.Windows.Forms.MessageBox]::Show($helpMessage, "Help", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        }
        else {
            # Get assistant response
            $assistantResponse = Send-ChatRequest -message $userMessage

            # Display assistant's response
            $conversationBox.SelectionColor = [System.Drawing.Color]::Green
            $conversationBox.AppendText("Assistant:`n$assistantResponse`n`n")
            $conversationBox.ScrollToCaret()

            # Voice output
            $synthesizer.SpeakAsync($assistantResponse)
        }
    }
}

# Event handler for pressing Enter key in the input box
$inputBox.Add_KeyDown({
    param($sender, $eventArgs)
    if ($eventArgs.KeyCode -eq "Enter") {
        $eventArgs.SuppressKeyPress = $true
        Send-UserMessage
    }
})

# Event handler for voice input button click
$voiceButton.Add_Click({
    # Disable the button to prevent multiple clicks
    $voiceButton.Enabled = $false
    $inputBox.Text = "Listening..."
    $inputBox.Refresh()

    # Initialize Speech Recognition Engine
    $recognizer = New-Object System.Speech.Recognition.SpeechRecognitionEngine
    $recognizer.SetInputToDefaultAudioDevice()

    # Load Dictation Grammar
    $recognizer.LoadGrammar([System.Speech.Recognition.DictationGrammar]::new())

    # Recognize speech asynchronously
    $recognizer.RecognizeAsync([System.Speech.Recognition.RecognizeMode]::Single)

    # Event handler for recognized speech
    # SpeechRecognized Event Handler
    $recognizer.add_SpeechRecognized({
        param($sender, $eventArgs)
        $recognizedText = $eventArgs.Result.Text
        $inputBox.Text = $recognizedText
        $voiceButton.Enabled = $true
        $sender.Dispose()  # Use $sender instead of $recognizer
    })

    # RecognizeCompleted Event Handler
    $recognizer.add_RecognizeCompleted({
        param($sender, $eventArgs)
        if (-not $eventArgs.Result) {
            $inputBox.Text = ""
            $voiceButton.Enabled = $true
            $sender.Dispose()  # Use $sender instead of $recognizer
        }
    })

})

# Handle form closing event to save conversation
$form.Add_FormClosing({
    param($sender, $eventArgs)
    Save-Conversation
})

# Add controls to the form
$form.Controls.Add($conversationBox)
$form.Controls.Add($inputBox)
$form.Controls.Add($sendButton)
$form.Controls.Add($voiceButton)

# Show the form
[void]$form.ShowDialog()
