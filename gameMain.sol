pragma solidity ^0.4.18;

import "./commitReveal.sol";
import "./helper.sol";

contract gameMain is commitReveal, helper {

    //Owner of contract
    address owner;

    //System variables (only to be changed by owner)
    uint256 public wager = 10; //wei
    uint256 public fee = 0; //wei
    uint256 public deposit = 10 * wager;
    
    //Players
    address[3] public players = [0x0000000000000000000000000000000000000000,
                                 0x0000000000000000000000000000000000000000,
                                 0x0000000000000000000000000000000000000000];

	//Seed, Guess per player
	mapping (address => uint8) seeds; //sum of seeds % 100 gives winningNumber
	mapping (address => uint8) guesses; //players' guesses
	
	//Other variables
	uint8 public numRevelations = 0;
	uint8 public winningNumber;
	
	mapping (address => bool) hasDeposit;
	mapping (address => uint8) difference;
	
	//Flags
	bool acceptRevelations = false;


    //Constructor
    function gameMain () public {
        
        owner = msg.sender;
        newRound();
        
    }

    //Wrapper for commit
    function doCommit (bytes32 _in) payable public returns (bool success) {
        
        success = true;
        
        if (msg.value == deposit+wager) {
            
            //Add new player to free slot and accept his commit
            if (players[0] == 0x0000000000000000000000000000000000000000) {
                commit(_in);
                players[0] = msg.sender;
                notifyNewPlayer(msg.sender, "Player 1 entered.");
            } else if (players[1] == 0x0000000000000000000000000000000000000000) {
                commit(_in);
                players[1] = msg.sender;
                notifyNewPlayer(msg.sender, "Player 2 entered.");
            } else if (players[2] == 0x0000000000000000000000000000000000000000) {
                commit(_in);
                players[2] = msg.sender;
                notifyNewPlayer(msg.sender, "Player 3 entered.");
                acceptRevelations = true;
            } else {
                success = false;
            }
        
        } else {
            success = false;
        }
        
        if(success) {
            hasDeposit[msg.sender] = true;
        }
        
        require(success);
        
    }

	//Wrapper for reveal
	function doReveal (string _secret, uint8 _seed, uint8 _guess) public returns (bool success) {
	    
	    success = true;
	    
        if (reveal (_secret, _seed, _guess) && acceptRevelations) {
            
            if (players[0] == msg.sender) {
                notifyRevelation(msg.sender, "Player 1 revealed his commitment.");
            } else if (players[1] == msg.sender) {
                notifyRevelation(msg.sender, "Player 2 revealed his commitment.");
            } else if (players[2] == msg.sender) {
                notifyRevelation(msg.sender, "Player 3 revealed his commitment.");
            } else {
                success = false;
            }
            
        } else {
            success = false;
        }
        
        if (success) {
            numRevelations++;
            
            seeds[msg.sender] = _seed % 100;
            guesses[msg.sender] = _guess % 100;
            hasDeposit[msg.sender] = false; //Prevent "Multiple Entry Attacks"
            msg.sender.transfer(deposit);
            
            if (numRevelations == 3) {
                determine_winner();
            }
        }
        
	}
	
	//Function to calculate winningNumber
	function calculate_winningNumber () internal {
	    
	    uint256 sumOfSeeds = 0;
	    
        for (uint8 i=0; i<3; i++) {
           sumOfSeeds = sumOfSeeds + seeds[players[i]];
        }
        
        winningNumber = uint8(sumOfSeeds % 100);
	    
	}
	
	//Function to determine winner
	function determine_winner () internal {
	    
	    uint8 i;
	    
	    uint8 multiWinners = 0;
	    address winner = players[1];
	    address[2] winner_candidates;
	    
	    calculate_winningNumber();
	    
        //Calculate difference to winningNumber for each player's guess
        for (i=0; i<3; i++) {
            difference[players[i]] = diff(winningNumber, guesses[players[i]]);
        }

        //Check for smallest difference => winner
        //If multiple players have the same difference a lot will be drawn
        for (i=1; i<3; i++) {
            
            if (difference[players[i]] < difference[winner]) {
                //Smallest distance => single winner
                winner = players[i];
				multiWinners = 0;
            } else if (difference[players[i]] == difference[winner]) {
                //Same distance => multiple winner candidates
				winner_candidates[multiWinners] = players[i];
				multiWinners++;
            }
            
        }
        
        //Draw a lot if there are multiple winner candidates
        if (multiWinners > 0) {
            
            //TODO: r = RANDOM 0..multiWinners
            uint8 r = 0;
            
            if (r > 0) {
                winner = winner_candidates[r-1];
            }
            
        }
        
        winner.transfer(3 * wager - fee);
        anounceWinner(winner, "We have a winner!");
        
        newRound();
		
    }
    
    //Function to initialize a new round
    function newRound () internal {
    
        //Clear Players
        address[3] public players = [0x0000000000000000000000000000000000000000,
                                     0x0000000000000000000000000000000000000000,
                                     0x0000000000000000000000000000000000000000];
    	
    	//Clear other variables
    	uint8 public numRevelations = 0;
    	
    	//Clear flags
    	bool acceptRevelations = false;
        
    }
	
	//Function for owner to change system variables
	function changeVariables (uint256 _wager, uint256 _fee) public onlyOwner {
	    
	    wager = _wager;
	    fee = _fee;
	    deposit = 10 * _wager;
	    
	}
	
	//Events
	//TODO: Simplify to single event?
	event notifyNewPlayer (address _player, string _msg);
	event notifyRevelation (address _player, string _msg);
	event anounceWinner(address _winner, string _msg);
	
	//Modifiers
	modifier onlyOwner {
	    
        require(msg.sender == owner);
    	_;
    	
	}
	
}
