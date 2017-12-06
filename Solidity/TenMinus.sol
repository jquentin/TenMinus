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

    // State { 0:Inexistant, 1:Initiated, 2:Answered (Waiting for reveal) }


    struct Game
    {
        address player1;
        address player2;
        uint8 state;
        bytes32 player1CardHash;
        uint8 player1Card;
        uint8 player2Card;
    }
    
    mapping (address => address[]) playersWaitingForReveal;
    mapping (address => address[]) playersWaitingForAnswer;
    
    mapping (address => mapping(address => Game)) gamesInitiated;
    
    function InitiateGame(address opponent, bytes32 cardHash) payable sentEnoughCashToPlay()
    {
        if (gamesInitiated[msg.sender][opponent].state != 0)
            throw;
        if (gamesInitiated[opponent][msg.sender].state != 0)
            throw;
        Game newGame;
        newGame.player1 = msg.sender;
        newGame.player2 = opponent;
        newGame.state = 1;
        newGame.player1CardHash = cardHash;
        gamesInitiated[newGame.player1][newGame.player2] = newGame;
        
        // Add myself to playersWaitingForAnswer[opponent]
        playersWaitingForAnswer[opponent].push(msg.sender);
        
       GameStateChanged(newGame.player1, newGame.player2, newGame.state);
        
    }
    
    function AnswerGame(address opponent, uint8 card) payable sentEnoughCashToPlay() valueIsCard(card)
    {
        if (gamesInitiated[opponent][msg.sender].state != 1)
            throw;
        Game updatedGame = gamesInitiated[opponent][msg.sender];
        updatedGame.state = 2;
        updatedGame.player2Card = card;
        gamesInitiated[opponent][msg.sender] = updatedGame;
        
        // Remove myself from playersWaitingForAnswer[msg.sender]
        uint length = playersWaitingForAnswer[msg.sender].length;
        for (uint8 i = 0 ; i < length ; i++)
        {
            if (playersWaitingForAnswer[msg.sender][i] == opponent)
            {
                playersWaitingForAnswer[msg.sender][i] = playersWaitingForAnswer[msg.sender][length - 1];
                delete playersWaitingForAnswer[msg.sender][length - 1];
                break;
            }
        }
        playersWaitingForAnswer[msg.sender].length--;
        // Add myself to playersWaitingForReveal[opponent]
        playersWaitingForReveal[opponent].push(msg.sender);
        
        GameStateChanged(updatedGame.player1, updatedGame.player2, updatedGame.state);
    }
    
    function TestSha(string password, string card) constant returns (bytes32)
    {
        return sha3(password, card);
    }
    
    function Reveal(address opponent, uint8 card, string password) valueIsCard(card)
    {
    	
        if (gamesInitiated[msg.sender][opponent].state != 2)
            throw;
            
        Game updatedGame = gamesInitiated[msg.sender][opponent];
        if (sha3 (password, card) == updatedGame.player1CardHash)
        {
        	updatedGame.state = 0;
        	updatedGame.player2Card = card;
        	gamesInitiated[updatedGame.player1][updatedGame.player2] = updatedGame;
        	int8 result = ResolveGame (updatedGame);
        	int8 base = 4;
        	msg.sender.transfer((uint256)(base + result));
        	opponent.transfer((uint256)(base - result));
        	
            // Remove myself from playersWaitingForReveal[msg.sender]
            uint length = playersWaitingForReveal[msg.sender].length;
            for (uint8 i = 0 ; i < length ; i++)
            {
                if (playersWaitingForReveal[msg.sender][i] == opponent)
                {
                    playersWaitingForReveal[msg.sender][i] = playersWaitingForReveal[msg.sender][length - 1];
                    delete playersWaitingForReveal[msg.sender][length - 1];
                    break;
                }
            }
        	playersWaitingForReveal[msg.sender].length--;
        
            GameStateChanged(updatedGame.player1, updatedGame.player2, updatedGame.state);
        }
        else
	        throw;
    }
    
    // Returns the number of coins player 1 wins (negative if player 2 wins)
    function ResolveGame (Game game) internal returns (int8)
    {
    	int8 difference = ((int8) (game.player1Card)) - ((int8) (game.player2Card));
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
    
    function GetPlayersWaitingForReveal () constant returns (address[])
    {
        return playersWaitingForReveal[msg.sender];
    }
  
    function GetPlayersWaitingForAnswer () constant returns (address[])
    {
        return playersWaitingForAnswer[msg.sender];
    }
    
    function GetGameState (address opponent) constant returns (uint8)
    {
        if (gamesInitiated[msg.sender][opponent].state != 0)
            return gamesInitiated[msg.sender][opponent].state;
        return gamesInitiated[opponent][msg.sender].state;
    }
    
}
    