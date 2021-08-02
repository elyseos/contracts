// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Lock.sol";
import "./Ownable.sol";
import "./SafeERC20.sol";


contract LockFactory is Ownable{
    using SafeERC20 for IERC20;
    
    struct Beneficiary {
       LockToken lock;
       uint256 exists;
    }
    
    mapping(address => Beneficiary) private _beneficiaries;

    // ERC20 basic token contract being held
    IERC20 private immutable _token;
    
    constructor(IERC20 token_){
        _token = token_;
    }
    
    function addLock(address address_, uint256 numTokens) public {
        require(_beneficiaries[address_].exists!=0);
        require(_token.balanceOf(address(this))>numTokens);
        _beneficiaries[address_].lock = new LockToken(_token,address_);
        _beneficiaries[address_].exists = 1;
        _token.safeTransfer(address(_beneficiaries[address_].lock), numTokens);
    }
    
    function getLock(address address_) public view returns (LockToken){
        require(_beneficiaries[address_].exists>0);
        return _beneficiaries[address_].lock;
    }
    
    
}