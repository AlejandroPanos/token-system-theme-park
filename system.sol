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



    // ========= THEME PARK RIDE MANAGEMENT =========

    // Events
    event EnjoyRide(string);
    event NewRide(string, uint);
    event RetireRide(string);

    // Ride struct
    struct Ride {
        string name;
        uint price;
        bool state;
    }

    // Mapping to relate name of ride with ride
    mapping(string => Ride) public rides;

    // Save rides in array
    string[] listOfRides;

    // Mapping to relate client with history at the theme park
    mapping(address => string[]) clientHistory; 

    // Function to create new rides
    function addRide(string memory _name, uint _price) public OnlyOwner(msg.sender){

        // Create new ride 
        rides[_name] = Ride(_name, _price, true);

        // Save ride to list
        listOfRides.push(_name);

        // Emit event
        emit NewRide(_name, _price);
    }

    // Function to retire rides
    function retireRide(string memory _name) public OnlyOwner(msg.sender) returns(bool){

        // Check the ride exists
        bool exists = false;

        for(uint i = 0; i < listOfRides.length; i++){
            if (keccak256(abi.encodePacked(_name)) == keccak256(abi.encodePacked(listOfRides[i]))) {
                exists = true;
                break;
            } 
        }

        // Require ride exists
        require(exists, 'Ride does not exist yet');

        // Change the state of the ride
        rides[_name].state = false;

        // Emit event
        emit RetireRide(_name);

        // Return the value
        return true;
    }

    // Function to see rides
    function checkRides() public view returns(string[] memory) {
        
        // Check that there are rides
        require(listOfRides.length > 0, 'No rides added yet');

        // Return the array of rides
        return listOfRides;
    }

    // Function to hop on a ride and pay in tokens
    function useRide(string memory _name) public {

        // Check the ride exists
        bool exists = false;

        for(uint i = 0; i < listOfRides.length; i++){
            if (keccak256(abi.encodePacked(_name)) == keccak256(abi.encodePacked(listOfRides[i]))) {
                exists = true;
                break;
            } 
        }

        // Require ride exists
        require(exists, 'Ride does not exist yet');

        // Check price ride
        uint price = rides[_name].price;

        // Check status of ride
        require(rides[_name].state == true, 'Ride is out of service');

        // Check person has the tokens
        require(price < tokensLeft(), 'Not enough tokens for this ride');

        // Tranfer tokens to the theme park
        token.transferThemePark(msg.sender, address(this), price);

        // Save client history
        clientHistory[msg.sender].push(_name);

        // Emit event
        emit EnjoyRide(_name);
    }

    // Check client history
    function checkHistory() public view returns(string[] memory) {

        // Return the history
        return clientHistory[msg.sender];
    }

    // Function to allow client to return tokens when leaving the theme park
    function returnTokens(uint _numTokens) public payable {

        // Check number of tokens is greater than 0
        require(_numTokens > 0, 'Cannot return tokens');

        // User must posses the number of tokens to return
        require(_numTokens <= tokensLeft(), 'You do not have the tokens you wish to return');

        // Client returns tokens
        token.transferThemePark(msg.sender, address(this), _numTokens);

        // Theme park returns ether to client
        uint returnValue = assignPrice(_numTokens);
        (bool success, ) = payable(msg.sender).call{value: returnValue}('');
        require(success, 'ETH transfer failed');
    }

}