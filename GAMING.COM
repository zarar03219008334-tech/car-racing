
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Car Racing</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.3/dist/tailwind.min.css" rel="stylesheet">
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background-color: #264653; /* Primary color */
            color: #E5E7EB;
        }
        .form-container {
            margin-top: 2rem;
            padding: 1rem;
            border-radius: 0.5rem;
            background-color: #2A9D8F; /* Secondary color */
        }
        header h1 {
            color: #E9C46A; /* Tertiary color */
        }
        button {
            background-color: #E9C46A; /* Tertiary color */
        }
        button:hover {
            background-color: #ffc107; /* Slightly lighter shade for hover */
        }
    </style>
</head>
<body class="flex flex-col items-center justify-center min-h-screen">
    <header>
        <h1 class="text-3xl font-bold mb-4">Design Your Car Racing Game</h1>
    </header>

    <div class="form-container">
        <form id="gameForm" class="flex flex-col space-y-4">
            <div>
                <label for="playerName" class="block mb-1">Player Name:</label>
                <input type="text" id="playerName" class="w-full p-2 rounded" required>
            </div>
            <div>
                <label for="characterClass" class="block mb-1">Preferred Character Class:</label>
                <input type="text" id="characterClass" class="w-full p-2 rounded" required>
            </div>
            <div>
                <label for="environment" class="block mb-1">Favorite Environment to Explore:</label>
                <input type="text" id="environment" class="w-full p-2 rounded" required>
            </div>
            <button type="submit" class="p-3 rounded hover:bg-yellow-400">Craft My Adventure!</button>
        </form>
    </div>

    <section id="output" class="mt-4 w-3/4 p-4 bg-gray-700 rounded text-white"></section>

    <footer class="mt-6">
        <a href="https://www.carracing.com" class="text-blue-400">Made with 🏎️</a>
    </footer>

    <script>
        const form = document.getElementById('gameForm');
        const output = document.getElementById('output');

        form.addEventListener('submit', function (event) {
            event.preventDefault();

            const playerName = document.getElementById('playerName').value;
            const characterClass = document.getElementById('characterClass').value;
            const environment = document.getElementById('environment').value;

            const substitutedPrompt = `Design a fast-paced action-adventure game where ${playerName} controls a lone explorer in a mysterious, ever-changing world. The environment shifts every few minutes, challenging the player to survive and uncover secrets. The player's preferred character class is ${characterClass}, and they navigate through ${environment} environments. The core gameplay loop includes smooth and responsive movement, a combat system with 3 distinct abilities, and enemies with various behaviors. The progression system allows the player to collect resources, upgrade choices, and unlock new skills or characters over time. The art style is clean and pixel-art, with smooth animations and visually clear effects. The game features responsive controls, impactful feedback, increasing difficulty, a simple story, boss fights, and matching sound effects/music to create an engaging and replayable experience.`;

            const websocket = new WebSocket('wss://backend.buildpicoapps.com/ask_ai_streaming_v2');

            output.innerHTML = '';

            websocket.addEventListener("open", () => {
                websocket.send(
                    JSON.stringify({
                        appId: "risk-leader",
                        prompt: substitutedPrompt,
                    })
                );
            });

            websocket.addEventListener("message", (event) => {
                console.log(event.data);
                output.innerText = `${output.innerText}${event.data}`;
            });

            websocket.addEventListener("close", (event) => {
                console.log("Connection closed", event.code, event.reason);
                if (event.code != 1000) {
                    alert("Oops, we ran into an error. Refresh the page and try again.");
                }
            });

            websocket.addEventListener("error", (error) => {
                console.log('WebSocket error', error);
                alert("Oops, we ran into an error. Refresh the page and try again.");
            });
        });
    </script>
</body>
</html>
