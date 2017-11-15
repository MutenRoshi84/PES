pragma solidity ^0.4.0;

contract gameMain {

    //System variables (only to be changed by owner)
    uint256 public deposit = 10; //Pfand, in wei
    uint256 public wager = 1; //wetteinsatz, in wei
    
    //Players
    address[3] players = [0,0,0];

	//Seed, Guess per player
	mapping(address => uint8) seeds; //Werte zur Ermittlung der Gewinnzahl
	mapping(address => uint8) guesses; //Tipp der Benutzer
    
}

contract game is gameMain{
    
    event anounceWinner(string win_msg, address winner, uint amount);

    address winner;
	uint256 winners; 								// big number of winners shouldnt fail, max number should be 2^256, chance of so much winners -> 0 
	
    uint256 player_amount = 3;
	address[3] tmp_winners;

    uint256 win_amount;
    
    uint256 fee = 0;            
    string win_msg = " is the winner";
    int256 win_number = 0;
    
    uint16 i;
    uint16 r;                                       // chosed winner of multiple possible winners
    
    mapping(address => int256) difference; 			// difference to calc win number


    event announce(address winner, string win_msg); // first 3 parameter can be listend to

    function calc_win_amount() {                     // calculates the winAmount
        win_amount = (player_amount * wager) - fee;
    }
    
    function retire_deposit() {                     // retires deposit
        for (i=0; i < player_amount; i++)
        {
            players[i].transfer(deposit);			// transfer can revert transaction if fails, can throw exception, send doesnt
			//players[i].send(deposit);
        }   
    }
    
    function calculate_winner() {                   // chooses the winner
    // calc win number
        for (i=0; i < player_amount; i++)       
        {
           win_number = win_number + seeds[players[i]];
        }   
        win_number = win_number % 100;
        

    // calc difference to win number    
        for (i=0; i < player_amount; i++)
        {
            difference[players[i]] = win_number - int256(guesses[players[i]]);
        }


    // check for smallest difference = winner
		tmp_winners[0] = players[i];

        for (i=1; i < player_amount; i++)
        {
            if (difference[players[i]] < 0)
            {
                difference[players[i]] = difference[players[i]] * (-1);
            }
            
            if (difference[tmp_winners[0]] > difference[players[i]])
            {
                tmp_winners[0] = players[i];
				winners = 0;								// reset multiple winners if there was a closer gues
            } 
            else if (difference[tmp_winners[0]] == difference[players[i]])
            {
				tmp_winners[winners+1] = players[i];		// save a "new" winner
				winners++;									// same gues = multiple winners
            }
        }


    // choose 1 of multiple winners, first winner wins
		for (i=0; i < winners; i++)
		{
			//r = rand(winners);					// <------------- todo
			r = 0;
			winner = tmp_winners[r];
		}
    }
    
    function pay_winner() payable{            // pays the win amount to the winner
        winner.transfer(win_amount);
    }
    
    function resetGame() {                           // open the game and let players participate
        // <--------------- todo: reset variables?!
    }
    
    function playGame() {							// close the game and pays win amount and deposit back					
        
        calc_win_amount();
        calculate_winner();
        retire_deposit();
        pay_winner();
        announce(winner, win_msg);

        resetGame();
    }

 
    

}

