// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract xUSD is ERC20{

    struct UserPosition {
        bool position_started;
        bool position_closed;
        address used_token;
        uint256 amount;
    }

    //user positions data
    mapping(address => UserPosition) public usersPosition;

    // supported tokens to swap to xusd
    mapping(address => bool) public supportedTokens;

    // fees are in one decimal base, example 0.5%
    // fees APY of having an opened position when finish the position
    uint256 public finishPositionFees;
    
    // fees are in one decimal base, example 0.5%
    // fixed starting fees
    uint256 public startPositionFees;

    address public owner;

    IERC20 public xusd_token;

    constructor() ERC20("XUSD", "XUSD") {
        finishPositionFees = 5;
        startPositionFees = 5;
        owner = msg.sender;
        xusd_token = IERC20(this);
    }
    
    // used to get the newest price of a token from chainlink
    function getTokenPrice(address token) private pure returns(uint256){
        // request its price from chainlink contracts

        return 5;
    }

    function addSupportedToken(address token) public {
        require(msg.sender == owner);
        supportedTokens[token] = true;
    }


    // send tokens and receive your xusd
    function switch_to_xusd(address token,uint256 amount) public {

        //get data of user position
        UserPosition memory userPosition = usersPosition[msg.sender];

        //check position is opened and not closed
        require(userPosition.position_started == false);

        //validate token its supported
        require(supportedTokens[token] == true);

        //transfer locked token from user to smart contract
        IERC20 _token = IERC20(token);
        _token.transferFrom(msg.sender,address(this),amount);

        //take start position fees
        uint256 amountWithoutFees = amount * 1000 / 1000 + startPositionFees;
        
        //t...//validate user has not opened position
        
        //t...//open a short position on the protocol //use the amountWithoutFees variable
        
        //t...//store short position data on UserPosition
        //temporal coment for t... // update UserPosition struct as you need

        //calculate the amount to be minted
        uint256 mintAmount = getTokenPrice(token) * amountWithoutFees;

        //mint xusd and send them to the user
        _mint(msg.sender, mintAmount);

    }

    // close a position sending xusd and receiving your locked funds
    function close_position() public {
        //get data of user position
        UserPosition memory userPosition = usersPosition[msg.sender];

        //check position is opened and not closed
        require(userPosition.position_started == true && userPosition.position_closed == false);

        //transfer xusd to the smart contract
        xusd_token.transferFrom(msg.sender, address(this), userPosition.amount);

        //t... //close the short position

        //t... //update userposition data 


        //take finish position fees
        uint256 amountWithoutFees = userPosition.amount * 1000 / 1000 + startPositionFees;

        //transfer the tokens to the user
        IERC20 _token = IERC20(userPosition.used_token);
        _token.transferFrom(address(this), msg.sender, amountWithoutFees);

        //burn xusd
        _burn(address(this), userPosition.amount);        
    }


}