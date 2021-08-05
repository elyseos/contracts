// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./Ownable.sol";

contract ElysToken is ERC20, Ownable {
    uint8 private _decimals = 0;
    
    /**
     * @dev Sets the values for {initialMintAddress}, {initialSupply} and {dec}.
     *
     */
    constructor(address initialMintAddress, uint256 initialSupply, uint8 dec) ERC20("Elyseos", "ELYS") {
        _decimals = dec;
        _mint(initialMintAddress, initialSupply);
    }
    
    /**
    * @dev Mints the {amount} of the token to {to}
    */
    function mint(address to, uint256 amount) public onlyOwner{
        _mint(to,amount);
    }
    
    /**
    * @dev returns how many decimals. 
    */
    function decimals() public override view returns (uint8){
         return _decimals;
    }
}
