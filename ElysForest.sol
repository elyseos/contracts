// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ElysLockNFT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract ForestFactory is Ownable{
    using SafeERC20 for IERC20;

    // ERC20 basic token contract being held
    IERC20 private _token;
    
    LockedELYS private immutable _lockedElys;
    
    uint256 private _tokenIdCounter = 0;
    
    address private _donationAddress;
    

    constructor(IERC20 token_,address donationAddress){
        _token = token_;
        _lockedElys = new LockedELYS(token_);
        _donationAddress = donationAddress;
    }
    
    function changeDonation(address donationAddress) public onlyOwner{
        _donationAddress = donationAddress;
    }
    
    function lockNFT() public view returns(LockedELYS){
        return _lockedElys;
    }
    
    function _addDec(uint256 amount) public pure returns (uint256){
        return amount * (10**5);
    }
    
    function getReward(uint256 lockDays, uint256 amount) public view returns (uint256){
        
        //work out reward
        uint256 perc = 0;

        if(lockDays>=7 && lockDays<14)perc = 4;
        if(lockDays>=14 && lockDays<28)perc = 5;
        if(lockDays>=28 && lockDays<3*28)perc = 6;
        if(lockDays>=3*28 && lockDays<6*28)perc=9;
        if(lockDays>=6*28 && lockDays<9*28)perc=12;
        if(lockDays>=9*28 && lockDays<365)perc=15;
        if(lockDays>=365 && lockDays<2*365)perc=20;
        if(lockDays>=2*365 && lockDays<3*365)perc=23;
        if(lockDays>=3*365)perc=26;
        
        uint256 rewardAmount = amount*perc*lockDays/36500;
        if(_token.balanceOf(address(this))>rewardAmount) return rewardAmount;
        return 0;
    }
    
    function lock(uint256 amount, uint256 lockDays, uint256 donation, uint256 tokenId) public {
        uint256 reward = getReward(lockDays, amount);
        uint256 donationAmount;
        if(donation>0){
            donationAmount = donation * reward/100;
            reward -= donationAmount;
        }
        require(_token.allowance(msg.sender, address(this))>=amount,"Insufficient allowance");
        _token.safeTransferFrom(msg.sender,address(_lockedElys),amount);
        if(reward>0)_token.safeTransfer(address(_lockedElys),reward);
        if(donationAmount>0)_token.safeTransfer(_donationAddress,donationAmount);
        _lockedElys.mint(msg.sender, tokenId, lockDays, amount, reward);
        _tokenIdCounter++;
    }
    
    function tokenIdCounter() public view returns (uint256) {
        return _tokenIdCounter;
    }
    

   
}