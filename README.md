# Blockchain Theme Park

A decentralized theme park management system built on Ethereum using ERC20 tokens. Visitors purchase tokens to access rides and meals, creating a complete token-based economy within a smart contract ecosystem.

## Overview

This project demonstrates how blockchain technology can power real-world service economies. Visitors exchange ETH for park tokens, use those tokens for attractions and food, and can convert unused tokens back to ETH when leaving.

## Features

### Token System

- **Buy Tokens**: Exchange ETH for park tokens (1:1 ratio)
- **Return Tokens**: Convert unused tokens back to ETH on exit
- **Token Tracking**: View token balance and purchase history
- **Minting**: Park owner can create additional tokens

### Ride Management

- **Add Rides**: Owner creates new attractions with custom pricing
- **Retire Rides**: Disable attractions (maintenance/closure)
- **Use Rides**: Visitors pay tokens to access attractions
- **Ride History**: Track all rides experienced

### Food Management

- **Create Meals**: Owner adds food options with token pricing
- **Retire Meals**: Remove unavailable menu items
- **Purchase Meals**: Buy food using tokens
- **Meal History**: Track dining experiences

## Tech Stack

- **Solidity** ^0.8.0
- **ERC20** Token Standard (custom implementation)
- **SafeMath** Library for secure arithmetic
- **Ethereum** Blockchain

## Project Structure

```
├── ERC20.sol          # Custom ERC20 token contract
├── SafeMath.sol       # Math library for overflow protection
└── ThemePark.sol      # Main theme park logic
```

## How It Works

### 1. Token Purchase Flow

```
Visitor sends ETH → Receives park tokens → Can now use park services
```

### 2. Service Usage Flow

```
Select ride/meal → Pay with tokens → Service recorded in history → Event emitted
```

### 3. Exit Flow

```
Return unused tokens → Receive ETH back → Leave with memories (stored on-chain!)
```

## Key Contracts

### ERC20Basic Token

- **Name**: ERC20AZ
- **Symbol**: ERC
- **Decimals**: 2
- **Special Feature**: `transferThemePark()` for seamless park transactions

### ThemePark Contract

- Manages all park operations
- Owns and distributes tokens
- Tracks visitor history
- Handles ETH ↔ Token conversions

## Smart Contract Functions

### For Visitors:

```solidity
buyTokens(uint _numTokens)           // Purchase tokens with ETH
tokensLeft()                         // Check token balance
useRide(string _name)                // Access a ride
getMeal(string _name)                // Purchase food
returnTokens(uint _numTokens)        // Convert tokens back to ETH
checkHistory()                       // View ride history
checkMealHistory()                   // View meal history
```

### For Park Owner:

```solidity
createTokens(uint _numTokens)        // Mint new tokens
addRide(string _name, uint _price)   // Create new ride
retireRide(string _name)             // Disable ride
createMeal(string _name, uint _price)// Add menu item
retireMeal(string _name)             // Remove menu item
```

## Example Usage

```solidity
// 1. Visitor buys 100 tokens
buyTokens(100) payable { value: 100 ether }

// 2. Owner adds a ride
addRide("Roller Coaster", 10)

// 3. Visitor uses the ride
useRide("Roller Coaster")  // Costs 10 tokens

// 4. Check remaining tokens
tokensLeft()  // Returns: 90

// 5. Return unused tokens on exit
returnTokens(90)  // Receives 90 ETH back
```

## Security Features

- **Access Control**: Only owner can manage park services
- **SafeMath**: Prevents arithmetic overflow/underflow
- **Balance Checks**: Ensures sufficient tokens before transactions
- **State Validation**: Verifies ride/meal availability before use
- **Proper ETH Handling**: Uses `.call()` for ETH transfers with error checking

## Events

Track all park activities through emitted events:

- `NewRide` - New attraction added
- `RetireRide` - Ride taken out of service
- `EnjoyRide` - Visitor uses a ride
- `NewMeal` - Menu item added
- `RetireMeal` - Meal removed
- `EnjoyMeal` - Food purchased

## Additional note on SafeMath

The SafeMath library validates if an arithmetic operation would result in an integer overflow/underflow. If it would, the library throws an exception, effectively reverting the transaction.

Since Solidity 0.8, the overflow/underflow check is implemented on the language level - it adds the validation to the bytecode during compilation.

You don't need the SafeMath library for Solidity 0.8+. You're still free to use it in this version, it will just perform the same validation twice (one on the language level and one in the library).

And it's strongly recommended to use it in 0.7, since the validation is not performed on the language level in this version yet.
