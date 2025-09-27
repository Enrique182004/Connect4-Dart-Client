A sample command-line application with an entrypoint in `bin/`, library code
in `lib/`, and example unit test in `test/`.
# Connect4-Dart-Client

A command-line Connect 4 game client built in Dart that communicates with a PHP-based game server. This project demonstrates client-server architecture, asynchronous programming, and functional programming concepts using Dart's higher-order functions.

## Features

### Core Functionality
- **Console-Based Interface**: Clean command-line UI for game interaction
- **Server Communication**: HTTP client for connecting to Connect 4 game servers
- **Strategy Selection**: Choose from multiple AI difficulty levels (Smart, Random)
- **Real-Time Gameplay**: Asynchronous game loop with immediate response
- **Input Validation**: Robust handling of user input with fallback defaults
- **Game State Management**: Complete board state tracking and win detection

### Technical Features
- **Higher-Order Functions**: Extensive use of Dart's functional programming features
  - `map()` for data transformation
  - `forEach()` for iteration
  - `every()` for validation
  - `generate()` for list creation
  - `where()` for filtering
- **Asynchronous Programming**: Full async/await implementation for HTTP requests
- **Object-Oriented Design**: Clean class architecture with separation of concerns
- **Error Handling**: Comprehensive exception handling with graceful fallbacks
- **Documentation**: Extensive dartdoc comments for all classes and methods

## Technologies Used

### Language & Runtime
- **Dart 3.7.2+**: Modern Dart with null safety and enhanced type system
- **HTTP Client**: Built-in `dart:io` HttpClient for server communication
- **JSON Processing**: Native `dart:convert` for data serialization

### Programming Paradigms
- **Object-Oriented Programming**: Class-based architecture with encapsulation
- **Functional Programming**: Higher-order functions and immutable data patterns
- **Asynchronous Programming**: Future-based concurrent operations
- **MVC Pattern**: Separation of UI, controller, and model logic

## Project Structure

```
connect4-dart-client/
├── bin/
│   └── main.dart              # Entry point executable
├── lib/
│   └── main.dart              # Library code (if extracted)
├── test/
│   └── main_test.dart         # Unit tests
├── analysis_options.yaml     # Dart linting configuration
├── pubspec.yaml              # Dependencies and metadata
├── pubspec.lock              # Dependency lock file
├── CHANGELOG.md              # Version history
└── README.md                 # Project documentation
```

## Getting Started

### Prerequisites
- **Dart SDK 3.7.2 or higher**
- **Connect 4 PHP Server** (running locally or remotely)
- Internet connection for server communication

### Installation

1. **Clone the repository:**
```bash
git clone https://github.com/YOUR_USERNAME/Connect4-Dart-Client.git
cd Connect4-Dart-Client
```

2. **Install dependencies:**
```bash
dart pub get
```

3. **Run the game:**
```bash
dart run bin/main.dart
```

### Alternative Installation
```bash
# Install Dart SDK if not already installed
# macOS with Homebrew:
brew tap dart-lang/dart
brew install dart

# Windows with Chocolatey:
choco install dart-sdk

# Linux:
sudo apt-get update
sudo apt-get install dart
```

## Usage

### Starting the Game
```bash
$ dart run bin/main.dart
**** Welcome to Connect Four Game ****
Enter the server URL [press Enter for default: https://www.cs.utep.edu/cheon/cs3360/project/c4/]:
URL selected: https://www.cs.utep.edu/cheon/cs3360/project/c4/
Getting game information...
Available strategies: Random, Smart
Available strategies:
1. Random
2. Smart
Enter the number of your choice [press Enter for 1]: 2
Strategy chosen: Smart
```

### Gameplay Example
```
. . . . . . .
. . . . . . .
. . . . . . .
. . . . . . .
. . . . . . .
. . . . . . .
1 2 3 4 5 6 7
-------------

Select a slot [1-7]: 4
You chose column: 4

. . . . . . .
. . . . . . .
. . . . . . .
. . . . . . .
. . . . . . .
. . . X . . .
1 2 3 4 5 6 7
-------------

Computer chose column: 3

. . . . . . .
. . . . . . .
. . . . . . .
. . . . . . .
. . . . . . .
. . O X . . .
1 2 3 4 5 6 7
-------------
```

## Architecture Overview

### Class Structure

#### ConsoleUI
- **Purpose**: Handles all user interface interactions
- **Methods**: 
  - `showMessage()`: Display information to user
  - `promptServer()`: Get server URL from user
  - `promptStrategy()`: Strategy selection interface
  - `promptMove()`: Get user's column choice
  - `showBoard()`: Render game board using higher-order functions

#### WebClient
- **Purpose**: HTTP communication with game server
- **Methods**:
  - `getInfo()`: Retrieve available strategies from server
  - `makeMove()`: Send player move to server
  - `play()`: Start new game session

#### Controller
- **Purpose**: Game flow management and coordination
- **Methods**:
  - `start()`: Initialize game and server connection
  - `gameLoop()`: Main game execution loop
  - `_makeComputerMove()`: AI move generation

#### Board
- **Purpose**: Game state representation and logic
- **Methods**:
  - `makeMove()`: Place token in column
  - `checkWin()`: Detect winning conditions
  - `isFull()`: Check for draw conditions
  - `isSlotFull()`: Validate move legality

### Higher-Order Functions Implementation

The project extensively demonstrates Dart's functional programming capabilities:

```dart
// Transform board rows to display strings
List<String> displayRows = board.grid.map((row) {
  return row.map((player) => player.isEmpty ? '.' : player.token).join(' ');
}).toList();

// Check if board is full using every()
bool isFull() {
  return grid[0].every((player) => player.token.isNotEmpty);
}

// Generate column indices
String columnIndices = List<int>.generate(board.width, (i) => i + 1).join(' ');
```

## API Integration

### Server Endpoints
```dart
// Get game information
GET /info
Response: {"width": 7, "height": 6, "strategies": ["Smart", "Random"]}

// Make a move
GET /play?pid={gameId}&move={column}
Response: {
  "response": true,
  "ack_move": {...},
  "move": {...}
}
```

### Error Handling
```dart
try {
  gameInfo = await _webClient.getInfo(url);
} catch (e) {
  _consoleUI.showMessage('Failed to fetch game info. Using default strategies.');
  gameInfo = {'strategies': ['Random', 'Smart', 'Smarter']};
}
```

## Development

### Running Tests
```bash
dart test
```

### Code Analysis
```bash
dart analyze
```

### Formatting Code
```bash
dart format .
```

## Key Programming Concepts Demonstrated

### Functional Programming
- **Higher-order functions**: map, forEach, every, generate, where
- **Immutable data patterns**: Final variables and const constructors
- **Function composition**: Chaining operations for data transformation

### Asynchronous Programming
- **Future-based operations**: HTTP requests and user input
- **Async/await syntax**: Clean asynchronous code flow
- **Error propagation**: Proper exception handling in async contexts

### Object-Oriented Design
- **Encapsulation**: Private methods and controlled access
- **Single Responsibility**: Each class has a focused purpose
- **Dependency Injection**: Constructor-based dependency management

## Future Enhancements

- **GUI Client**: Flutter-based mobile/desktop interface
- **Local AI**: Implement minimax algorithm for offline play
- **Game Recording**: Save and replay game sessions
- **Network Configuration**: Support for custom server endpoints
- **Tournament Mode**: Multi-game session management
- **Statistics Tracking**: Win/loss ratio and performance metrics

## Dependencies

```yaml
dependencies:
  http: ^0.13.5  # HTTP client functionality

dev_dependencies:
  lints: ^5.0.0  # Dart linting rules
  test: ^1.24.0  # Testing framework
```

## License

This project was developed by [Your Name]. All rights reserved.
