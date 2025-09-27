import 'dart:io';
import 'dart:convert';

// In Dart, collection methods that take a function as an argument include:
// - map: Transforms each element using the provided function
// - where: Filters elements based on a predicate function
// - forEach: Executes the provided function on each element
// - reduce: Combines elements using the provided function
// - fold: Similar to reduce but with an initial value
// - any/every: Tests if any/all elements satisfy a condition
// - firstWhere/lastWhere: Finds first/last element satisfying a condition
// - generate: Creates a list using a generator function
// - expand: Maps each element to multiple elements and flattens the result
// - sort: Sorts elements using a comparison function

/// A console-based user interface for the Connect Four game.
///
/// Handles displaying game information to the user and collecting user input.
class ConsoleUI {
  /// Displays a message to the console.
  ///
  /// [message] The text message to display.
  void showMessage(String message) {
    print(message);
  }

  /// Prompts the user to enter a server URL.
  ///
  /// [defaultUrl] The default URL to use if the user doesn't provide one.
  /// Returns the server URL chosen by the user or the default URL.
  String promptServer(String defaultUrl) {
    print('Enter the server URL [press Enter for default: $defaultUrl]:');
    String? input = stdin.readLineSync();

    if (input == null || input.isEmpty) {
      return defaultUrl;
    }
    return input;
  }

  /// Prompts the user to select a game strategy from a list of available strategies.
  ///
  /// [strategies] The list of available strategy names.
  /// [defaultStrategy] Optional default strategy to use if not specified by user.
  /// Returns the selected strategy name.
  String promptStrategy(List<dynamic> strategies, {String? defaultStrategy}) {
    print('Available strategies:');
    for (int i = 0; i < strategies.length; i++) {
      print('${i + 1}. ${strategies[i]}');
    }

    print('Enter the number of your choice [press Enter for 1]:');
    String? input = stdin.readLineSync();

    int choice = 1;

    if (input != null && input.isNotEmpty) {
      try {
        choice = int.parse(input);

        if (choice < 1 || choice > strategies.length) {
          print('Invalid number. Using default (1).');
          choice = 1;
        }
      } catch (e) {
        print('Not a number. Using default (1).');
        choice = 1;
      }
    }

    return strategies[choice - 1] as String;
  }

  /// Prompts the user to select a column for their next move.
  ///
  /// [board] The current game board.
  /// Returns the column index (0-based) where the user wants to place their piece.
  int promptMove(Board board) {
    stdout.write('Select a slot [1-7]: ');
    String? input = stdin.readLineSync();
    
    try {
      int slot = int.parse(input ?? "1");
      int adjustedSlot = slot - 1;
      stdout.writeln('You chose column: $slot');
      return adjustedSlot;
    } catch (e) {
      stdout.writeln('Invalid input, using default: 1');
      return 0;
    }
  }

  /// Displays the current state of the game board.
  ///
  /// Uses higher-order functions to transform and display the board data.
  /// [board] The board to display.
  void showBoard(Board board) {
    // Use map to transform each row in the grid to a display string
    List<String> displayRows = board.grid.map((row) {
      // Use map again to transform each cell in the row to its display character
      return row.map((player) => player.isEmpty ? '.' : player.token).join(' ');
    }).toList();
    
    // Display each row using forEach
    displayRows.forEach((rowString) {
      stdout.writeln(rowString);
    });
    
    // Generate and display column indices using generate higher-order function
    String columnIndices = List<int>.generate(board.width, (i) => i + 1).join(' ');
    stdout.writeln(columnIndices);
    
    // Create a separator line using generate and join
    String separator = List.generate(board.width * 2 - 1, (i) => '-').join('');
    stdout.writeln(separator);
  }
}

/// Client for communicating with the Connect Four game server.
///
/// Handles HTTP requests to retrieve game information and make game moves.
class WebClient {
  /// Retrieves game information from the server.
  ///
  /// [baseUrl] The base URL of the game server.
  /// Returns a [Future] that completes with the game information as a [Map].
  Future<Map<String, dynamic>> getInfo(String baseUrl) async {
    final client = HttpClient();
    final infoUrl = '$baseUrl/info';

    try {
      print('Connecting to $infoUrl...');
      final request = await client.getUrl(Uri.parse(infoUrl));
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseText = await response.transform(utf8.decoder).join();

        final info = json.decode(responseText);
        return info;
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } finally {
      client.close();
    }
  }
  
  /// Makes a move in the game.
  ///
  /// [baseUrl] The base URL of the game server.
  /// [pid] The player ID for the current game.
  /// [column] The column where the move should be made (0-based).
  /// Returns a [Future] that completes with the game state after the move.
  Future<Map<String, dynamic>> makeMove(String baseUrl, String pid, int column) async {
    final client = HttpClient();
    final moveUrl = '$baseUrl/play?pid=$pid&move=$column';

    try {
      final request = await client.getUrl(Uri.parse(moveUrl));
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseText = await response.transform(utf8.decoder).join();
        return json.decode(responseText);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } finally {
      client.close();
    }
  }
  
  /// Starts a new game with the specified strategy.
  ///
  /// [baseUrl] The base URL of the game server.
  /// [strategy] The strategy to use for the computer opponent.
  /// Returns a [Future] that completes with the initial game state.
  Future<Map<String, dynamic>> play(String baseUrl, String strategy) async {
    final client = HttpClient();
    final playUrl = '$baseUrl/play?strategy=$strategy';

    try {
      final request = await client.getUrl(Uri.parse(playUrl));
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseText = await response.transform(utf8.decoder).join();
        return json.decode(responseText);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } finally {
      client.close();
    }
  }
}

/// Utility class for parsing server responses into game objects.
class ResponseParser {
  /// Parses a board object from a server response.
  ///
  /// [response] The JSON response from the server.
  /// Returns a [Board] object representing the current game state.
  static Board parseBoardFromResponse(Map<String, dynamic> response) {
    final boardData = response['board'];
    final int width = boardData['width'] as int;
    final int height = boardData['height'] as int;
    final board = Board(width, height);
    
    // Parse the board state from the response
    final List<dynamic> slots = boardData['slots'];
    for (int i = 0; i < slots.length; i++) {
      int row = i ~/ width;
      int col = i % width;
      String cell = slots[i].toString();
      
      if (cell == "X") {
        board.grid[row][col] = Player('X');
      } else if (cell == "O") {
        board.grid[row][col] = Player('O');
      }
    }
    
    return board;
  }
}

/// Main controller for the Connect Four game.
///
/// Manages the game flow, coordinates between the UI and the web client,
/// and handles game state updates.
class Controller {
  final ConsoleUI _consoleUI;
  final WebClient _webClient;
  final ResponseParser _responseParser = ResponseParser();

  /// Default server URL to use if the user doesn't specify one.
  static const String defaultUrl = 'https://www.cs.utep.edu/cheon/cs3360/project/c4/';
  
  late Board _board;
  late String _pid;
  late String _strategy;

  /// Creates a new game controller.
  ///
  /// [_consoleUI] The UI for interacting with the user.
  /// [_webClient] The client for communicating with the game server.
  Controller(this._consoleUI, this._webClient);

  /// Starts the game by initializing the connection to the server and
  /// setting up the game parameters.
  ///
  /// Returns a [Future] that completes when the game ends.
  Future<void> start() async {
    _consoleUI.showMessage('**** Welcome to Connect Four Game ****');

    // Prompt for server URL
    final url = _consoleUI.promptServer(defaultUrl);
    _consoleUI.showMessage('URL selected: $url');

    _consoleUI.showMessage('Getting game information...');

    Map<String, dynamic> gameInfo;
    try {
      gameInfo = await _webClient.getInfo(url);
    } catch (e) {
      _consoleUI.showMessage('Failed to fetch game info. Using default strategies.');
      gameInfo = {'strategies': ['Random', 'Smart', 'Smarter']};
    }

    // Get available strategies
    final strategies = gameInfo['strategies'] as List<dynamic>;
    _consoleUI.showMessage('Available strategies: ${strategies.join(", ")}');

    // Prompt for strategy selection
    _strategy = _consoleUI.promptStrategy(strategies.cast<String>());
    _consoleUI.showMessage('Strategy chosen: $_strategy');

    // Initialize an empty board
    _board = Board(7, 6);
    
    _consoleUI.showMessage('');
    _consoleUI.showBoard(_board);
    
    // Start the game loop
    await gameLoop(url);
  }

  /// Runs the main game loop, alternating between the player's turn and the computer's turn.
  ///
  /// [url] The URL of the game server.
  /// Returns a [Future] that completes when the game ends.
  Future<void> gameLoop(String url) async {
    bool gameOver = false;
    
    while (!gameOver) {
      // Prompt user for a move
      int column = _consoleUI.promptMove(_board);
      
      // Make the move on the board
      _board.makeMove(column, 'X');  // Human player uses 'X'
      
      // Display the updated board after the move
      _consoleUI.showBoard(_board);
      
      // Check for win or full board
      if (_board.checkWin('X')) {
        _consoleUI.showMessage('You win!');
        gameOver = true;
        break;
      }
      
      if (_board.isFull()) {
        _consoleUI.showMessage('Board is full! Game over.');
        gameOver = true;
        break;
      }
      
      // Computer's turn (simple random move for demonstration)
      int computerColumn = _makeComputerMove();
      _consoleUI.showMessage('Computer chose column: ${computerColumn + 1}');
      
      // Make the computer's move
      _board.makeMove(computerColumn, 'O');  // Computer uses 'O'
      
      // Display the updated board after computer's move
      _consoleUI.showBoard(_board);
      
      // Check for win or full board
      if (_board.checkWin('O')) {
        _consoleUI.showMessage('Computer wins!');
        gameOver = true;
      }
      
      if (_board.isFull()) {
        _consoleUI.showMessage('Board is full! Game over.');
        gameOver = true;
      }
    }
    
    _consoleUI.showMessage('Game over! Thanks for playing.');
  }
  
  /// Determines the computer's next move.
  ///
  /// Returns the column index (0-based) for the computer's move.
  int _makeComputerMove() {
    List<int> availableColumns = [];
    
    // Find all available columns
    for (int col = 0; col < _board.width; col++) {
      if (!_board.isSlotFull(col)) {
        availableColumns.add(col);
      }
    }
    
    // Pick a random column from available options
    if (availableColumns.isNotEmpty) {
      return availableColumns[DateTime.now().millisecondsSinceEpoch % availableColumns.length];
    }
    
    // Fallback (should not happen if we check for full board)
    return 0;
  }
}

/// Represents the Connect Four game board.
///
/// Manages the grid of players' tokens and provides methods to check game state.
class Board {
  /// The width of the board (number of columns).
  final int width;
  
  /// The height of the board (number of rows).
  final int height;
  
  /// The grid representing the board.
  ///
  /// A 2D list where each element is a [Player] object. Empty cells contain
  /// players with empty tokens.
  List<List<Player>> grid;

  /// Creates a new empty board with the specified dimensions.
  ///
  /// [width] The width of the board.
  /// [height] The height of the board.
  Board(this.width, this.height) 
    : grid = List.generate(
        height, 
        (_) => List.generate(width, (_) => Player(''))
      );

  /// Checks if a column is full.
  ///
  /// [column] The index of the column to check.
  /// Returns true if the column is full, false otherwise.
  bool isSlotFull(int column) {
    return grid[0][column].token.isNotEmpty;
  }

  /// Checks if the board is completely full.
  ///
  /// Returns true if all cells are occupied, false otherwise.
  bool isFull() {
    // Using higher-order function to check if the board is full
    return grid[0].every((player) => player.token.isNotEmpty);
  }
  
  /// Makes a move by placing a token in the specified column.
  ///
  /// The token will fall to the lowest available position in the column.
  /// [column] The index of the column to place the token in.
  /// [token] The token to place ('X' for human, 'O' for computer).
  void makeMove(int column, String token) {
    for (int row = height - 1; row >= 0; row--) {
      if (grid[row][column].isEmpty) {
        grid[row][column] = Player(token);
        break;
      }
    }
  }
  
  /// Checks if a player has won the game.
  ///
  /// Looks for four tokens of the same type in a row, column, or diagonal.
  /// [token] The token to check for a win.
  /// Returns true if the player has won, false otherwise.
  bool checkWin(String token) {
    // Check horizontal win
    for (int row = 0; row < height; row++) {
      for (int col = 0; col <= width - 4; col++) {
        if (grid[row][col].token == token &&
            grid[row][col + 1].token == token &&
            grid[row][col + 2].token == token &&
            grid[row][col + 3].token == token) {
          return true;
        }
      }
    }
    
    // Check vertical win
    for (int row = 0; row <= height - 4; row++) {
      for (int col = 0; col < width; col++) {
        if (grid[row][col].token == token &&
            grid[row + 1][col].token == token &&
            grid[row + 2][col].token == token &&
            grid[row + 3][col].token == token) {
          return true;
        }
      }
    }
    
    // Check diagonal win (down-right)
    for (int row = 0; row <= height - 4; row++) {
      for (int col = 0; col <= width - 4; col++) {
        if (grid[row][col].token == token &&
            grid[row + 1][col + 1].token == token &&
            grid[row + 2][col + 2].token == token &&
            grid[row + 3][col + 3].token == token) {
          return true;
        }
      }
    }
    
    // Check diagonal win (down-left)
    for (int row = 0; row <= height - 4; row++) {
      for (int col = 3; col < width; col++) {
        if (grid[row][col].token == token &&
            grid[row + 1][col - 1].token == token &&
            grid[row + 2][col - 2].token == token &&
            grid[row + 3][col - 3].token == token) {
          return true;
        }
      }
    }
    
    return false;
  }
  
  /// Returns the rows of the board.
  ///
  /// Returns a list of lists of [Player] objects representing the board.
  List<List<Player>> getRows() {
    return grid;
  }
}

/// Represents a player in the Connect Four game.
///
/// Stores the player's token ('X' for human, 'O' for computer, or empty).
class Player {
  /// The token representing the player on the board.
  ///
  /// 'X' for human player, 'O' for computer player, or empty string for empty cells.
  final String token;
  
  /// Creates a new player with the specified token.
  ///
  /// [token] The token representing the player.
  Player(this.token);
  
  /// Checks if this is an empty cell (no player).
  ///
  /// Returns true if the token is empty, false otherwise.
  bool get isEmpty => token.isEmpty;
  
  @override
  String toString() => token;
}

/// Represents the game information retrieved from the server.
class Info {
  /// The list of available AI strategies.
  final List<String> strategies;
  
  /// Creates a new info object with the specified strategies.
  ///
  /// [strategies] The list of available AI strategies.
  Info(this.strategies);
}

/// Represents the state of the game after a play.
class Play {
  /// The player ID for the current game.
  final String pid;
  
  /// The current state of the board.
  final Board board;
  
  /// The winner of the game, or null if the game is not over.
  final String? winner;
  
  /// Creates a new play state.
  ///
  /// [pid] The player ID.
  /// [board] The current board state.
  /// [winner] The winner of the game, or null if the game is not over.
  Play(this.pid, this.board, this.winner);
}

/// Represents a move in the game.
class Move {
  /// The column where the move is made.
  final int column;
  
  /// Creates a new move.
  ///
  /// [column] The column where the move is made.
  Move(this.column);
}

/// The entry point of the application.
///
/// Creates the UI and controller objects and starts the game.
void main() async {
  final consoleUI = ConsoleUI();
  final webClient = WebClient();
  final controller = Controller(consoleUI, webClient);

  await controller.start();
}