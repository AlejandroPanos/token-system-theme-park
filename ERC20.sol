// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
import './SafeMath.sol';

// Interface for our ERC20 token
interface IERC20 {

    // Returns existing token quantity
    function totalSupply() external view returns(uint256);

    // Returns token qty for a specific address
    function balanceOf(address _account) external view returns(uint); 

    // Returns the amount the spender can spend for the token owner
    function allowance(address _owner, address _spender) external view returns(uint256);

    // Returns bool to check if transfer can be done
    function transfer(address _recipient, uint256 _amount) external returns(bool);

    // Returns bool to check if client can transfer to the theme park
    function transferThemePark(address _client, address _recepient, uint256 _amount) external returns(bool);

    // Returns bool value if transfer is approved or not
    function approve(address _spender, uint256 _amount) external returns(bool);

    // Returns bool value with operation result
    function transferFrom(address _sender, address _recepient, uint256 _amount) external returns(bool);

    
    
    // Event to emit when tokens go from one place to another
    event Transfer(address indexed from, address indexed to, uint256 _value);

    // Event to emit when we use the allowance method and someone spends for another person
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

// ERC20 contract
contract ERC20Basic is IERC20 {

    string public constant name = 'ERC20AZ';
    string public constant symbol = 'ERC';
    uint8 public constant decimals = 2;

    // SafeMath
    using SafeMath for uint256;

    // Create mappings
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    uint256 totalSupply_;

    // Constructor
    constructor(uint initialSupply) {
        totalSupply_ = initialSupply;
        balances[msg.sender] = totalSupply_;
    }

    // In the contract we can override the functions in the interface
    // Total Supply
    function totalSupply() public override view returns(uint256){
        return totalSupply_;
    }

    // Mining function
    function increaseTotalSupply(uint _newTokensAmount) public {
        totalSupply_ += _newTokensAmount;
        balances[msg.sender] += _newTokensAmount;
    }

    // Balance
    function balanceOf(address _tokenOwner) public override view returns(uint){
        return balances[_tokenOwner];
    }

    // Allowance
    function allowance(address _owner, address _spender) public override view returns(uint256){
        return allowed[_owner][_spender];
    }

    // Transfer
    function transfer(address _recipient, uint256 _amount) public override returns(bool){
        // Check we have enough tokens
        require(_amount <= balances[msg.sender], 'Token amount is not enough');

        // Get rid of token amount in sender account
        balances[msg.sender] = balances[msg.sender].sub(_amount);

        // Add balance to recepient
        balances[_recipient] = balances[_recipient].add(_amount);

        // Emit the event to allow users to see transaction
        emit Transfer(msg.sender, _recipient, _amount);

        // Return value
        return true;
    }

    // Transfer theme park
    function transferThemePark(address _client, address _recipient, uint256 _amount) public override returns(bool){
        // Check we have enough tokens
        require(_amount <= balances[_client], 'Token amount is not enough');

        // Get rid of token amount in sender account
        balances[_client] = balances[_client].sub(_amount);

        // Add balance to recepient
        balances[_recipient] = balances[_recipient].add(_amount);

        // Emit the event to allow users to see transaction
        emit Transfer(_client, _recipient, _amount);

        // Return value
        return true;
    }

    // Approve
    function approve(address _spender, uint256 _amount) public override returns(bool){
        // As an owner, assign the spender a certain amount of tokens that they can spend (they are NOT transfered)
        allowed[msg.sender][_spender] = _amount;

        // Emit the approval
        emit Approval(msg.sender, _spender, _amount);

        // Return the value
        return true;
    }

    // Transfer from: we act as an intermediary and it is NOT a direct transfer from owner to recepient
    function transferFrom(address _owner, address _recepient, uint256 _amount) public override returns(bool){
        // Use requires
        require(_amount <= balances[_owner], 'Not enough tokens to send');
        require(_amount <= allowed[_owner][msg.sender], 'You are not allowed to transfer that amount');

        // Create the transfers
        balances[_owner] = balances[_owner].sub(_amount);
        allowed[_owner][msg.sender] = allowed[_owner][msg.sender].sub(_amount);
        balances[_recepient] = balances[_recepient].add(_amount);

        // Emit the transfer event
        emit Transfer(_owner, _recepient, _amount);

        // Return value
        return true;
    }
}