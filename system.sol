// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
import {ERC20Basic} from './ERC20.sol';

contract ThemePark {

    // ========= INITIAL DECLARATIONS =========

    // Instance to token contract
    ERC20Basic private token;

    // Contract owner
    address payable public owner;

    // Constructor
    constructor() {
        token = new ERC20Basic(10000);
        owner = payable(msg.sender);
    }

    // Client struct
    struct Client {
        uint tokensBought;
        string[] rides;
    }

    // Mapping to register clients
    mapping(address => Client) public registry;



    // ========= MODIFIERS =========

    modifier OnlyOwner(address _address) {
        require(_address == owner, 'Cannot execute this function');
        _;
    }



    // ========= TOKEN MANAGEMENT =========

    // Assign price to token
    function assignPrice(uint _numTokens) internal pure returns(uint) {

        // Assign value to token
        uint price = _numTokens * (1 ether);
        
        // Return conversion from ETH to token: 1-1 relation
        return price;
    }

    // Function to check balance of contract
    function balanceOf() public view returns(uint) {
        return token.balanceOf(address(this));
    }

    // Function to buy tokens in theme park
    function buyTokens(uint _numTokens) public payable {

        // Calculate token price to be bought
        uint price = assignPrice(_numTokens);

        // Check buyer has the required amount
        require(msg.value >= price, 'Cannot perform that operation');

        // Check the remainder
        uint returnValue = msg.value - price;

        // Theme park returns the remainder – Transfer is deprecated (must use call{value: <amount>})
        (bool success, ) = payable(msg.sender).call{value: returnValue}('');
        require(success, 'ETH transfer failed');

        // Check ERC20 contract balance
        uint balance = balanceOf();
        require(_numTokens <= balance, 'Not enough tokens available');

        // Send tokens to buyer
        token.transfer(msg.sender, _numTokens);

        // Save bought tokens
        registry[msg.sender].tokensBought += _numTokens;
    }

    // Function to allow someone to check their number of tokens left
    function tokensLeft() public view returns(uint) {
        return token.balanceOf(msg.sender);
    }

    // Function to allow the theme park to create more tokens
    function createTokens(uint _numTokens) public OnlyOwner(msg.sender){
        token.increaseTotalSupply(_numTokens);
    }

}