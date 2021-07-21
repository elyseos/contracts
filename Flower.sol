// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FlowerToken is ERC20 {
    uint8 private _decimals = 4;
    
    constructor(address initialMintAddress, uint256 initialSupply) ERC20("Flower", "FLWR") {
        _mint(initialMintAddress, initialSupply);
    }
    
    function decimals() public override view returns (uint8){
         return _decimals;
    }
}
