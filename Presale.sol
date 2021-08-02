// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Elys.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Presale is Ownable {
    address private _tokenAddress;
    mapping (address => bool) private _whitelist;
    
    modifier onlyWhitelisted() {
        require(_whitelist[_msgSender()], "Caller is not whitelisted");
        _;
    }
    
    constructor(uint256 initialSupply, uint256 ftmPrice, uint256 minPurchase, uint256 maxPurchase) {
        ElysToken _token = new ElysToken(initialSupply);
        _tokenAddress = address(_token);
    }
    
    function tokenAddress() public view returns (address){
        return _tokenAddress;
    }
    
    function whitelist(address[] calldata addresses) public onlyOwner{
        for(uint i=0;i<addresses.length;i++){
            _whitelist[addresses[i]] = true;
        }
        
    }
    
    function unWhitelist(address _address) public onlyOwner{
        _whitelist[_address] = false;
    }
    
    function buy() public payable onlyWhitelisted{
        
    }
    
    fallback() external payable {}
}
