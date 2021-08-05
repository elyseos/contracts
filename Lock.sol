// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SafeERC20.sol";

contract LockToken{
    using SafeERC20 for IERC20;
    
   
    // ERC20 basic token contract being held
    IERC20 private immutable _token;
    
     uint256 private immutable _numReleaseDays;
    //records the start of the contract 
    uint256 private immutable _start;
    
    //records amount already released
    uint256 private _released;

    

    // beneficiary of tokens after they are released
    address private immutable _beneficiary;
    
    constructor(IERC20 token_, address beneficiary_, uint256 numReleaseDays_) {
        _token = token_;
        _beneficiary = beneficiary_;
        _start = block.timestamp;
        _numReleaseDays = numReleaseDays_;
        
        
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
    
    /**
     * @return number of tokens still locked up
     */
    function locked() public view returns(uint256){
        return token().balanceOf(address(this)) - amountCanRelease();
    }
    
    /**
     * @return the tokens that have been released already
     */
    function released() public view returns(uint256){
        return _released;
    }
    
    /**
     * @return block.timestamp (used for testing).
     */
    function _blocktime() private view returns (uint256){
        return block.timestamp;
    }
    
    /**
     * @return number of days since contract deployed
     */
    function _daysSinceStart() private view returns (uint256){
        return (_blocktime() - _start)/(1 days);
    }
    
     /**
     * @return the amount that can be released to the beneficiary at this time
     */
    function amountCanRelease() public view returns (uint256){
        uint256 amount = token().balanceOf(address(this));
        if(amount==0) return 0;
        uint256 daysSinceStart = _daysSinceStart();
        if(daysSinceStart>_numReleaseDays) return amount;
        uint256 total = _released + amount;
        uint256 amountPerDay = total/_numReleaseDays;
        uint256 daysUntilLastRelease = _released/amountPerDay;
        uint256 daysSinceLastRelease = daysSinceStart-daysUntilLastRelease;
        if(daysSinceLastRelease==0) return 0;
        return daysSinceLastRelease * amountPerDay;
    }
    
    function release() public {
        uint256 amountToRelease = amountCanRelease();
        require(amountToRelease>0);
        _released += amountToRelease;
        token().safeTransfer(beneficiary(), amountToRelease);
    }

}
