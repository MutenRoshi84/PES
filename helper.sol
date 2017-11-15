pragma solidity ^0.4.18;

contract helper {

	//Helper function for user to generate commit
	function commitHelper (string _secret, uint8 _seed, uint8 _guess) pure public returns (bytes32) {
	    
		return keccak256 (_secret, _seed, _guess);
		
	}
	
	//Helper function to calculate absolute difference
	function diff (uint8 _a, uint8 _b) pure internal returns (uint8) {
	    
	    if (_a >= _b) {
	        return _a - _b;
	    } else {
	        return _b - _a;
	    }
	    
	}

}
