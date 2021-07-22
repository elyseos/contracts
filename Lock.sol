// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract LockToken{
    using SafeERC20 for IERC20;
    
    // ERC20 basic token contract being held
    IERC20 private immutable _token;
    
    //records the start of the contract 
    uint256 private immutable _start;
    //Keeps track of the last release
    uint256 private _lastDraw;
    
    

    // beneficiary of tokens after they are released
    address private immutable _beneficiary;
    
    constructor(IERC20 token_, address beneficiary_) {
        _token = token_;
        _beneficiary = beneficiary_;
        _start = block.timestamp;
        _lastDraw = block.timestamp;
    }
    
    /**
     * @return the beneficiary of the tokens.
     */
    function beneficiary() public view virtual returns (address) {
        return _beneficiary;
    }
    
    /**
     * @return the token being held.
     */
    function token() public view returns (IERC20) {
        return _token;
    }
    
    function _blocktime() private view returns (uint256){
        return block.timestamp;
    }
    
    function daysPassedSinceStart() public view returns (uint256){
        return (_blocktime() - _start)/(1 days);
    }
    
    function daysPassedSinceLastDraw() public view returns (uint256){
        return (_blocktime() - _lastDraw)/(1 days);
    }
    
    function draw() public {
        uint256 amount = token().balanceOf(address(this));
        require(amount > 0, "TokenTimelock: no tokens to release");
        if(daysPassedSinceStart()>=100){
            token().safeTransfer(beneficiary(), amount);
            return;
        }
        uint256 oneDayAmount = (amount*100/daysPassedSinceStart())/100;
        uint256 amountToDraw = daysPassedSinceLastDraw()*oneDayAmount;
        _lastDraw = _blocktime();
        token().safeTransfer(beneficiary(), amountToDraw);
    }

}
