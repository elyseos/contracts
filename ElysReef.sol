// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ElysLockNFT.sol";


contract ReefFactory{
    using SafeERC20 for IERC20;

    // ERC20 basic token contract being held
    IERC20 private _token;
    
    LockedELYS private immutable _lockedElys;
    address payable private immutable _drawWallet;
    
    mapping(uint256 => bool) private _slots;
    
    constructor(IERC20 token_, address payable drawWallet){
        _token = token_;
        _lockedElys = new LockedELYS(token_);
        _drawWallet = drawWallet;
    }
    
    function lockNFT() public view returns(LockedELYS){
        return _lockedElys;
    }
    
    function _addDec(uint256 amount) public pure returns (uint256){
        return amount * (10**5);
    }
    
    function getSlot(uint256 lockMonths, uint256 amount) public pure returns (uint256){
        uint256 slot = 0;
        if(amount==_addDec(50000)){
            slot = (lockMonths==6)?0:1;
        } else if(amount==_addDec(75000)){
            slot = 3;
        } else if(amount==_addDec(150000)){
            slot = (lockMonths==6)?4:5;
        } else if(amount==_addDec(200000)){
            slot = 6;
        } else if(amount==_addDec(300000)){
            slot = (lockMonths==6)?7:8;
        } else { //if(amount==_addDec(500000)){
            slot = 9;
        } 
        return slot;
    }
    
    function getReward(uint256 slot) public pure returns (uint256){
        uint256 reward = 0;
        if(slot==0) reward = 7500;
        if(slot==1) reward = 16500;
        if(slot==2) reward = 24750;
        if(slot==3) reward = 24750;
        if(slot==4) reward = 54000;
        if(slot==5) reward = 72000;
        if(slot==6) reward = 54000;
        if(slot==7) reward = 132000;
        if(slot==8) reward = 220000;
        
        return _addDec(reward);
    }
    
    function lock(uint256 amount, uint256 lockMonths, uint256 tokenId) public {
        uint256 slot = getSlot(lockMonths, amount);
        require(!_slots[slot]);
        require(_token.allowance(msg.sender, address(this))>=amount);
        uint256 reward = getReward(slot);
        require(_token.balanceOf(address(this))>=reward);
        _token.safeTransferFrom(msg.sender,address(_lockedElys),amount);
        _token.safeTransferFrom(address(this),address(_lockedElys),reward);
        _slots[slot] = true;
        _lockedElys.mint(msg.sender, tokenId, lockMonths * 28, amount, reward);
    }
    
   
}