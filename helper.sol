pragma solidity ^0.4.18;

contract helper {

	//Helper function for user to generate commit
	function commitHelper (string _secret, uint8 _seed, uint8 _guess) pure public returns (bytes32) {
		return keccak256 (_secret, _seed, _guess);
	}

}
