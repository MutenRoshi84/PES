pragma solidity ^0.4.18;

import "./commitReveal.sol";
import "./helper.sol";

contract gameMain is commitReveal, helper {

    //System variables (only to be changed by owner)
    uint256 public deposit = 1000; //wei
    uint256 public wager = 10; //wei
    
    //Players
    address[3] public players = [0,0,0];

	//Seed, Guess per player
	mapping (address => uint8) seeds; //sum of seeds % 100 gives winning number
	mapping (address => uint8) guesses; //players' guesses


    //Wrapper for commit
    function doCommit (bytes32 _in) payable public returns (bool success) {
        
        success = true;
        
        if (msg.value == deposit+wager) {
            
            //Add new player to free slot and accept his commit
            if (players[0] == 0) {
                commit(_in);
                players[0] = msg.sender;
            } else if (players[1] == 0) {
                commit(_in);
                players[1] = msg.sender;
            } else if (players[2] == 0) {
                commit(_in);
                players[2] = msg.sender;
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
                players[0] = 0;
            } else if (players[1] == msg.sender) {
                players[1] = 0;
            } else if (players[2] == msg.sender) {
                players[2] = 0;
            } else {
                success = false;
            }
            
        } else {
            success = false;
        }
        
        if(success) {
            seeds[msg.sender] = _seed;
            guesses[msg.sender] = _guess;
            msg.sender.transfer(deposit);
        }
        
	}
	
}
