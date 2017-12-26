pragma solidity ^0.4.17;

contract owned {
    function owned() { owner = msg.sender; }
    address owner;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}

contract TenMinus is owned {

    event GameStateChanged(address player1, address player2, uint8 state);

     modifier sentEnoughCashToPlay()
    {
        if (msg.value < 4 finney)
            throw;
        else
            _;
    }
    
    modifier valueIsCard(uint8 value)
    {
        if (value < 1 || value > 10)
            throw;
        else
            _;
    }
    
    function CardToString (uint8 card) internal returns (string sCard)
    {
        if (card == 1) return "1";
        else if (card == 2) return "2";
        else if (card == 3) return "3";
        else if (card == 4) return "4";
        else if (card == 5) return "5";
        else if (card == 6) return "6";
        else if (card == 7) return "7";
        else if (card == 8) return "8";
        else if (card == 9) return "9";
        else if (card == 10) return "10";
    }

    struct Game
    {
        // State: { 0:Inexistant, 1:Initiated, 2:Answered (Waiting for reveal), 3:Complete }
        uint8 state;
        bytes32 player1CardHash;
        uint8 player1Card;
        uint8 player2Card;
    }
    
    struct PastGame
    {
        uint8 player1Card;
        uint8 player2Card;
    }
    
    mapping (address => address[]) interactingPlayers;
    
    mapping (address => mapping(address => Game)) gamesInitiated;
    
    mapping (address => mapping(address => PastGame)) gamesCompleted;
    
    function InitiateGame(address opponent, bytes32 cardHash) payable sentEnoughCashToPlay()
    {
        if (msg.sender == opponent)
            throw;
        if (gamesInitiated[msg.sender][opponent].state != 0 && gamesInitiated[msg.sender][opponent].state != 3)
            throw;
        if (gamesInitiated[opponent][msg.sender].state != 0 && gamesInitiated[opponent][msg.sender].state != 3)
            throw;
            
        gamesInitiated[opponent][msg.sender].state = 0;
        
        gamesInitiated[msg.sender][opponent].state = 1;
        gamesInitiated[msg.sender][opponent].player1CardHash = cardHash;
        
        interactingPlayers[opponent].push(msg.sender);
        interactingPlayers[msg.sender].push(opponent);
        
        GameStateChanged(msg.sender, opponent, 1);
        
    }
    
    function AnswerGame(address opponent, uint8 card) payable sentEnoughCashToPlay() valueIsCard(card)
    {
        if (gamesInitiated[opponent][msg.sender].state != 1)
            throw;
        gamesInitiated[opponent][msg.sender].state = 2;
        gamesInitiated[opponent][msg.sender].player2Card = card;
        GameStateChanged(opponent, msg.sender, 2);
    }
    
    function Reveal(address opponent, uint8 card, string password) valueIsCard(card)
    {
        
        if (gamesInitiated[msg.sender][opponent].state != 2)
            throw;
        if (sha3 (password, CardToString(card)) != gamesInitiated[msg.sender][opponent].player1CardHash)
            throw;
        
        gamesInitiated[msg.sender][opponent].state = 3;
        gamesInitiated[msg.sender][opponent].player1Card = card;
        int8 result = ResolveGame (gamesInitiated[msg.sender][opponent].player1Card, gamesInitiated[msg.sender][opponent].player2Card);
        int8 base = 4;
        msg.sender.transfer((uint256)(base + result) * 1 finney);
        opponent.transfer((uint256)(base - result) * 1 finney);
        
        // Remove the opponent from interactingPlayers[msg.sender]
        uint length = interactingPlayers[msg.sender].length;
        for (uint8 i = 0 ; i < length ; i++)
        {
            if (interactingPlayers[msg.sender][i] == opponent)
            {
                interactingPlayers[msg.sender][i] = interactingPlayers[msg.sender][length - 1];
                delete interactingPlayers[msg.sender][length - 1];
                break;
            }
        }
        interactingPlayers[msg.sender].length--;
        
        // Remove myself from interactingPlayers[opponent]
        length = interactingPlayers[opponent].length;
        for (i = 0 ; i < length ; i++)
        {
            if (interactingPlayers[opponent][i] == msg.sender)
            {
                interactingPlayers[opponent][i] = interactingPlayers[opponent][length - 1];
                delete interactingPlayers[opponent][length - 1];
                break;
            }
        }
        interactingPlayers[opponent].length--;
        
        gamesCompleted[msg.sender][opponent].player1Card = card;
        gamesCompleted[msg.sender][opponent].player2Card = gamesInitiated[msg.sender][opponent].player2Card;
        
        gamesCompleted[opponent][msg.sender].player1Card = 0;
        gamesCompleted[opponent][msg.sender].player2Card = 0;
        
        GameStateChanged(msg.sender, opponent, 3);
    }
    
    // Returns the number of coins player 1 wins (negative if player 2 wins)
    function ResolveGame (uint8 player1Card, uint8 player2Card) internal returns (int8)
    {
        int8 difference = ((int8) (player1Card)) - ((int8) (player2Card));
        int8 signDif = 1;
        if (difference < 0) signDif = -1;
        int8 absDif = difference >= 0 ? difference : -difference;
        if (absDif == 0 || absDif == 5)
            return 0;
        else if (absDif > 0 && absDif < 5)
            return signDif * absDif;
        else if (absDif > 5 && absDif < 10)
            return - signDif * ((int8)(10) - absDif);
    }
    
    function GetPlayersInteracting () constant returns (address[])
    {
        return interactingPlayers[msg.sender];
    }
    
    function GetGameState (address opponent) constant returns (uint8 state, uint8 isPlayer, uint8 player1Card, uint8 player2Card)
    {
        Game game;
        uint8 playerIndex;
        if (gamesInitiated[msg.sender][opponent].state != 0)
        {
            game = gamesInitiated[msg.sender][opponent];
            playerIndex = 1;
        }
        else
        {
            game = gamesInitiated[opponent][msg.sender];
            playerIndex = 2;
        }
        return (game.state, playerIndex, game.player1Card, game.player2Card);
    }
    
    function GetLastGameState (address opponent) constant returns (uint8 isPlayer, uint8 player1Card, uint8 player2Card)
    {
        if (gamesCompleted[msg.sender][opponent].player1Card != 0)
            return(1, gamesCompleted[msg.sender][opponent].player1Card, gamesCompleted[msg.sender][opponent].player2Card);
        else
            return(2, gamesCompleted[opponent][msg.sender].player1Card, gamesCompleted[opponent][msg.sender].player2Card);
    }
    
}
    