// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./IUniswapV2Pair.sol";

contract ElysPrice{
    IUniswapV2Pair private immutable _pair;
    
    constructor(address pair){
        _pair = IUniswapV2Pair(pair);
    }
    
    /**
     * @return the current Elys price on Zoodex
     */
    function getPrice() public view returns(uint112,uint32){
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = _pair.getReserves();
        uint112 res0 = reserve0*(10**5);
        uint112 price = res0/reserve1;
        return (price,blockTimestampLast);
    }
    
}