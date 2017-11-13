pragma solidity ^0.4.18;

import "./commitReveal.sol";
import "./helper.sol";

contract gameMain is commitReveal, helper {

    //Owner of contract
    address owner;

    //System variables (only to be changed by owner)
    uint256 public wager = 10; //wei
    uint256 public deposit = 10 * wager;
    
    //Players
    address[3] public players = [0x0000000000000000000000000000000000000000,
                                 0x0000000000000000000000000000000000000000,
                                 0x0000000000000000000000000000000000000000];

	//Seed, Guess per player
	mapping (address => uint8) seeds; //sum of seeds % 100 gives winning number
	mapping (address => uint8) guesses; //players' guesses


    //Constructor
    function gameMain () public {
        
        owner = msg.sender;
        
    }

    //Wrapper for commit
    function doCommit (bytes32 _in) payable public returns (bool success) {
        
        success = true;
        
        if (msg.value == deposit+wager) {
            
            //Add new player to free slot and accept his commit
            if (players[0] == 0x0000000000000000000000000000000000000000) {
                commit(_in);
                players[0] = msg.sender;
                notifyNewPlayer(msg.sender, "Player 1 entered.", false);
            } else if (players[1] == 0x0000000000000000000000000000000000000000) {
                commit(_in);
                players[1] = msg.sender;
                notifyNewPlayer(msg.sender, "Player 2 entered.", false);
            } else if (players[2] == 0x0000000000000000000000000000000000000000) {
                commit(_in);
                players[2] = msg.sender;
                notifyNewPlayer(msg.sender, "Player 3 entered.", true);
            } else {
                success = false;
            }
        
        } else {
            success = false;
        }
        
        require(success);
        
    }

	//Wrapper for reveal
	function doReveal (string _secret, uint8 _seed, uint8 _guess) public returns (bool success) {
	    
	    success = true;
	    
        if (reveal (_secret, _seed, _guess)) {
            
            //Prevent "Multiple Entry Attacks"
            if (players[0] == msg.sender) {
                players[0] = 0x0000000000000000000000000000000000000000;
                notifyRevelation(msg.sender, "Player 1 revealed his commitment.");
            } else if (players[1] == msg.sender) {
                players[1] = 0x0000000000000000000000000000000000000000;
                notifyRevelation(msg.sender, "Player 2 revealed his commitment.");
            } else if (players[2] == msg.sender) {
                players[2] = 0x0000000000000000000000000000000000000000;
                notifyRevelation(msg.sender, "Player 3 revealed his commitment.");
                //Aufruf an Gewinnziehung
            } else {
                success = false;
            }
            
        } else {
            success = false;
        }
        
        if (success) {
            seeds[msg.sender] = _seed;
            guesses[msg.sender] = _guess;
            msg.sender.transfer (deposit);
        }
        
	}
	
	//Function for owner to change system variables
	function changeWager (uint256 _wager) public onlyOwner {
	    
	    wager = _wager;
	    deposit = 10 * wager;
	    
	}
	
	//Events
	event notifyNewPlayer (address _player, string _msg, bool final);
	event notifyRevelation (address _player, string _msg);
	
	//Modifiers
	modifier onlyOwner {
	    
        require(msg.sender == owner);
    	_;
    	
	}
	
}
