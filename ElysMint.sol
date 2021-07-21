// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./Elys.sol";

contract ElysMint is Ownable {
    
    /*
        Keeping the following amounts at their value without the extra decimals. 
        Decimals get added with _dec function
    */
    uint256 constant private _initialSupply = 350000000; 
    uint256 constant private _initialEpochSupply = 90000000; //Starts with this and then decreases depending on epoch
    uint256 constant private _epochDecr = 10000000; //amount to decrease the mint amount by every epoch (with the exception of epoch 8)
    
    uint256 constant private _epochMin = 24 weeks; //6 28 day cycles
    uint256 constant private _epochMax = 72 weeks; //after this we mint regardless of vote
    
    
    uint256 private _currentEpoch = 0;
    uint256 private _currentEpochStart = 0;
    uint256 private _numVotes = 0; //num votes in this epoch - also keeps track of number of 4 weeks cycles passed since last vote

    uint8 private _decimals = 4;
    address private _tokenAddress; //Elys token address that gets created in constructor
    
    
    /**
     * @dev Sets the values for {initialMintAddress}.
     *
     */
     /*
    constructor(address initialMintAddress) {
        _currentEpochStart = block.timestamp;
         ElysToken _token = new ElysToken(initialMintAddress, _initialSupply*_dec(),_decimals);
        _tokenAddress = address(_token);
    }
    */
    constructor(address token){
        _currentEpochStart = block.timestamp;
        _tokenAddress = token;
        ElysToken _token = ElysToken(_tokenAddress);
        _decimals = _token.decimals();
    }
    
     /**
     * @dev Returns amount to multiply values by so that decimals are included
     *
     */
    function _dec() private pure returns(uint256){
        return 10**_decimals;
    }
    
    /**
    * @dev Returns the amount to mint based on the current epoch
    *
    */
    function _mintAmount() private view returns(uint256){
        uint256 amountToSubtract = 0;
        /*
            During voting cycle decrease mint amount by {_epochDecr} 
            except for epoch 8 where it's half of {_epochDecr}
        */
        if(_currentEpoch<8)  amountToSubtract = _epochDecr*_currentEpoch;
        if(_currentEpoch==8) amountToSubtract = _epochDecr*_currentEpoch - _epochDecr/2;
        
        if(_currentEpoch<=8) return  _initialEpochSupply-amountToSubtract;
        
        /*
            After voting cycle (9 epochs) minting abount is 3% of total supply
        */
        ElysToken _token = ElysToken(_tokenAddress);
        uint256 totalSupply = _token.totalSupply();
        
        return  (3 * totalSupply/100)/_dec();
    }
    
    /**
    * @dev Returns whether it's time to vote yet 
    */
    function _timePassed() private view returns (bool){
        /*
        If it's a new epoch and no votes have been taken - _numVotes will be 0,
        and cancel out the 3 * 4 weeks between votes. If a vote was taken, and was false (voted no) 
        _numVotes will increase and another 3 * 4 week period will need to pass
        */
        return (_currentEpochStart + _epochMin + _numVotes*(3*(4 weeks))<block.timestamp);
    }
    
    /**
    * @dev Mint and vote function rolled into one so when the vote is true, it automatically mints. 
    * If false - it sets things up to vote again in 3 * 4 weeks.
    * This will be called by the DAO which will ultimately be the owner of this contract.
    *
    */
    function mint(bool votesuccess, address to) public onlyOwner{
        
        if(_currentEpoch<9){
            if(!votesuccess){
                if(_currentEpochStart + _epochMax>block.timestamp){
                    require(_timePassed());
                    _numVotes++;
                    return;
                }
            } else {
                require(_timePassed());
            }
        }
        else{
             require(_currentEpochStart + 9*(4 weeks)<block.timestamp);
        }
        
        if(_numVotes>0)_numVotes = 0;
        uint256 mintAmount = _mintAmount()*_dec();
        _currentEpoch ++;
        _currentEpochStart = block.timestamp;
        ElysToken _token = ElysToken(_tokenAddress);
        _token.mint(to, mintAmount);
    }
    
    /**
    * @dev Returns the Elys token address
    */
    function tokenAddress() public view returns (address){
        return _tokenAddress;
    }
    
}