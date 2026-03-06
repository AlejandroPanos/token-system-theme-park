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

}