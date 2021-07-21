// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./Elys.sol";

contract Test is Ownable {
    uint256 constant private _initialSupply = 35000000; //35 000 000
    uint256 constant private _initialEpochSupply = 90000000; //90 000 000
    uint256 constant private _epochDecr = 10000000; //amount to decrease the mint amount by every epoch
    uint256 constant private _epochMin = 24 weeks; //6 28 day cycles
    uint256 constant private _epochMax = 72 weeks;
    
    uint256 private _currentEpoch = 0;
    uint256 private _currentEpochStart = 0;
    uint256 private _numVotes = 0; //num votes in this epoch

    address private _tokenAddress;
    uint8 private _decimals = 4;
    
    uint256 _blocktime = 0;
    
    /*
    constructor(address initialMintAddress) {
        _blocktime = block.timestamp;
        _currentEpochStart = _blocktime;
        _voteIntervalLength = 3 * 4 weeks;
         ElysToken _token = new ElysToken(initialMintAddress,_initialSupply*_dec(),_decimals);
        _tokenAddress = address(_token);
    }
    */
    
    constructor(address token){
        _blocktime = block.timestamp;
        _currentEpochStart = _blocktime;
        _tokenAddress = token;
        ElysToken _token = ElysToken(_tokenAddress);
        _decimals = _token.decimals();
    }
    
    
    function inc3() public{
        _blocktime = _blocktime + 3*(4 weeks) + 1;
    }
    
    function inc6() public{
        _blocktime = _blocktime + 6*(4 weeks) + 1;
    }
    
    function inc9() public{
        _blocktime = _blocktime + 9*(4 weeks) + 1;
    }
    
    function _dec() public view returns(uint256){
        return 10**_decimals;
    }
    
    
    
    function _mintAmount() private view returns(uint256){
        uint256 amountToSubtract = 0;
        if(_currentEpoch<8)  amountToSubtract = _epochDecr*_currentEpoch;
        if(_currentEpoch>=8) amountToSubtract = _epochDecr*_currentEpoch - _epochDecr/2;
        
        if(_currentEpoch<=8) return  _initialEpochSupply-amountToSubtract;
        
        //amountToSubtract = amountToSubtract + (3 * (_initialEpochSupply-amountToSubtract))/100;
        ElysToken _token = ElysToken(_tokenAddress);
        uint256 totalSupply = _token.totalSupply();
        
        return  (3 * totalSupply/100)/_dec();
    }
    
   
    function numVotes() public view returns(uint256){
        return _numVotes;
    }
    
    function _timePassed() private view returns (bool){
       return (_currentEpochStart + _epochMin + _numVotes*(3*(4 weeks))<_blocktime);
    }
    
    function currentEpoch() public view returns (uint256){
        return _currentEpoch;
    }
    
    function mint(bool votesuccess, address to) public onlyOwner{
        //if(_currentEpoch>0){
            if(_currentEpoch<9){
                if(!votesuccess){
                    if(_currentEpochStart + _epochMax>_blocktime){
                        require(_timePassed());
                        _numVotes++;
                        return;
                    }
                } else {
                    require(_timePassed());
                }
            }
            else{
                 require(_currentEpochStart + 9*(4 weeks)<_blocktime);
            }
        //}
        if(_numVotes>0)_numVotes = 0;
        uint256 mintAmount = _mintAmount()*_dec();
        _currentEpoch ++;
        _currentEpochStart = _blocktime;
        ElysToken _token = ElysToken(_tokenAddress);
        _token.mint(to, mintAmount);
    }
    
    function tokenAddress() public view returns (address){
        return _tokenAddress;
    }
    
}