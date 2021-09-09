// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ElysLockGrowNFT.sol";
import "./IUniswapV2Pair.sol";


contract GrowFactory{
    using SafeERC20 for IERC20;

    // ERC20 basic token contract being held
    IERC20 private immutable _elys;
    IERC20 private immutable _lptoken;
    IUniswapV2Pair private immutable _pair;
    LockedELYS private immutable _lockedElys;
    
        
    constructor(IERC20 elys, IERC20 lptoken){
        _elys = elys;
        _lptoken = lptoken;
        _lockedElys = new LockedELYS(elys,lptoken);
        _pair = IUniswapV2Pair(address(lptoken));
    }
    
    function lockNFT() public view returns(LockedELYS){
        return _lockedElys;
    }
    
    function _addDec(uint256 amount) public pure returns (uint256){
        return amount * (10**5);
    }
    
    function _getPrice(uint112 reserve0, uint112 reserve1) private pure returns(uint112){
        //ie how many elys is ftm(reserve1) worth
        uint112 res1 = reserve1*(10**18);
        uint112 price = res1/reserve0;
        return price;
    }
    

    //returns pool value in Elys
    function getPoolValue() public view returns (uint112){
        //get total LP balance of _pair
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = _pair.getReserves();
        require(blockTimestampLast>0);
       
        uint112 price = _getPrice(reserve0,reserve1); //elysPriceInFtm
        require(price>0);
        //price is price of reserve0 elys in ftm
        //total in ftm= price +  reserve1
        
        return reserve1 + (reserve0*price)/(10**18);
    }
    
    function getLPTokenValue(uint256 lpBalance) public view returns (uint256){
        uint256 lpTotal = _lptoken.totalSupply();
        require(lpTotal>0 && lpBalance<=lpTotal);
        uint112 poolValue = getPoolValue();
        return lpBalance*poolValue/lpTotal;
        
    }
    
    function getReward(uint256 lpBalance, uint256 lockMonths) public view returns (uint256){
        require(lpBalance>0 && (lockMonths==3 || lockMonths==6 || lockMonths==12));
        uint256 apr = (lockMonths==3)?16:(lockMonths==6)?20:24;
        uint256 tokenValue = getLPTokenValue(lpBalance);
        uint256 rwrd = tokenValue * apr/100;
        if(lockMonths==6) rwrd/=2;
        if(lockMonths==3) rwrd/=4;
        if(_elys.balanceOf(address(this))>=rwrd) return rwrd;
        return 0;
    }
    
    function lock(uint256 lpBalance, uint256 lockMonths, uint256 tokenId) public {
        require(_lptoken.allowance(msg.sender, address(this))>=lpBalance);
        uint256 rwrd = getReward(lpBalance,lockMonths);
        require(rwrd>0);
        _lptoken.safeTransferFrom(msg.sender,address(_lockedElys),lpBalance);
        _elys.safeTransfer(address(_lockedElys),rwrd);
        uint256 lockDays = (lockMonths==12)?365:(lockMonths==6)?364/2:364/4;
        _lockedElys.mint(msg.sender, tokenId, lockDays, lpBalance, rwrd);
    }
    
    //function lock(uint256 amount, uint256 lockDays, uint256 tokenId) public {
        /*
        uint256 reward = getReward(lockDays, amount);
        require(_token.allowance(msg.sender, address(this))>=amount);
        _token.safeTransferFrom(msg.sender,address(_lockedElys),amount);
        if(reward>0)_token.safeTransferFrom(address(this),address(_lockedElys),reward);
        _lockedElys.mint(msg.sender, tokenId, lockDays, amount + reward);
        */
    //}
    
   
}