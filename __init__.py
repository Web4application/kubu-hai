// script.js

// Wait for the DOM to fully load before executing
document.addEventListener("DOMContentLoaded", () => {
    const app = document.getElementById("app");

    if (!app) {
        console.error("Error: App container (#app) not found.");
        return;
    }

    // Initialize RODA AI
    initApp(app);
});

/**
 * Initializes the app.
 * @param {HTMLElement} app - The main app container.
 */
function initApp(app) {
    // Create a welcome message
    const welcomeMessage = document.createElement("div");
    welcomeMessage.id = "welcome-message";
    welcomeMessage.textContent = "Welcome to RODA AI!";

    // Add styles to the welcome message
    welcomeMessage.style.fontSize = "24px";
    welcomeMessage.style.fontWeight = "bold";
    welcomeMessage.style.marginBottom = "20px";

    // Append welcome message to the app container
    app.appendChild(welcomeMessage);

    // Create an input field for user interaction
    const userInput = document.createElement("input");
    userInput.type = "text";
    userInput.id = "user-input";
    userInput.placeholder = "Type your question here...";
    userInput.style.width = "80%";
    userInput.style.padding = "10px";
    userInput.style.marginBottom = "10px";

    // Append the input field to the app container
    app.appendChild(userInput);

    // Create a button for submitting queries
    const submitButton = document.createElement("button");
    submitButton.id = "submit-button";
    submitButton.textContent = "Submit";
    submitButton.style.padding = "10px 20px";
    submitButton.style.marginLeft = "10px";
    submitButton.style.cursor = "pointer";

    // Append the button to the app container
    app.appendChild(submitButton);

    // Create a container for displaying responses
    const responseContainer = document.createElement("div");
    responseContainer.id = "response-container";
    responseContainer.style.marginTop = "20px";

    // Append the response container to the app
    app.appendChild(responseContainer);

    // Attach an event listener to the submit button
    submitButton.addEventListener("click", () => {
        const userInputValue = userInput.value.trim();
        if (userInputValue) {
            handleUserInput(userInputValue, responseContainer);
        }
    });
}

/**
 * Handles user input and generates a response.
 * @param {string} input - The user's input text.
 * @param {HTMLElement} responseContainer - The container to display responses.
 */
function handleUserInput(input, responseContainer) {
    // Clear the input field
    const userInput = document.getElementById("user-input");
    userInput.value = "";

    // Display the user's input
    const userMessage = document.createElement("div");
    userMessage.textContent = `You: ${input}`;
    userMessage.style.marginBottom = "10px";
    userMessage.style.color = "blue";

    responseContainer.appendChild(userMessage);

    // Simulate AI response
    const aiResponse = document.createElement("div");
    aiResponse.textContent = "RODA AI is thinking...";
    aiResponse.style.marginBottom = "10px";
    aiResponse.style.color = "green";

    responseContainer.appendChild(aiResponse);

 // Call FastAPI for actual prediction
fetch("http://localhost:8000/predict", {
    method: "POST",
    headers: {
        "Content-Type": "application/json"
    },
    body: JSON.stringify({ features: input.split(" ") })  // Adjust this depending on your model input
})
.then(response => response.json())
.then(data => {
    if (data.prediction !== undefined) {
        aiResponse.textContent = `RODA AI: ${data.prediction}`;
    } else {
        aiResponse.textContent = `Error: ${data.error}`;
    }
})
.catch(error => {
    aiResponse.textContent = "An error occurred: " + error;
});
