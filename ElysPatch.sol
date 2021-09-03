// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ElysPatchNFT.sol";

interface IElysPrice{
    function getPrice() external view returns (uint256);
}


contract LockedElysFactory{
    using SafeERC20 for IERC20;
    IElysPrice private immutable _elysPrice;

    // ERC20 basic token contract being held
    IERC20 private _token;
    
    LockedELYS private immutable _lockedElys;
    address private immutable _drawWallet;
    
    constructor(IERC20 token_, address ELYSPrice, address drawWallet){
        _lockedElys = new LockedELYS(token_);
        _elysPrice = IElysPrice(ELYSPrice);
        _drawWallet = drawWallet;
    }
    
    function lockNFT() public view returns(LockedELYS){
        return _lockedElys;
    }
    
    function quote(uint256 FTM) public view returns (uint256){
        uint256 price = _elysPrice.getPrice();
        return price * FTM/(10**18);
    }
    
    function getReward(uint256 lockDays, uint256 amount) public pure returns (uint256){
        //work out reward
        uint256 perc = 0;
        if(lockDays>=3*28 && lockDays<6*28)perc=4;
        if(lockDays>=6*28 && lockDays<12*28)perc=10;
        if(lockDays>12*28)perc=24;
        return amount*perc/100;
    }
    
    function buy(uint256 lockDays, uint256 tokenId) public payable{
        uint256 amount = quote(msg.value);
        require(amount>0);
        uint256 reward = getReward(lockDays, amount);
        require(amount + reward<=_token.balanceOf(address(this)));
        _lockedElys.mint(msg.sender, tokenId, lockDays, amount + reward);
        _token.safeTransfer(address(_lockedElys),amount + reward);
    }
    
    function draw() public{
        //address(this).balance
    }
   
}