// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LockedELYS is ERC721Enumerable, Ownable {
    using SafeERC20 for IERC20;
    
    string private _baseUri;
    IERC20 private immutable _token;
    address private immutable _factory;
    
    mapping(uint256 => uint256) private _lockedAmount; //maps tokenID to amount locked for that token
    mapping(uint256 => uint256) private _reward;
    mapping(uint256 => uint256) private _lockDays; //maps tokenID to num days locked
    mapping(uint256 => uint256) private _lockStart; //maps tokenID to start of lock
    
    uint256 private _timestamp;
    
    constructor(IERC20 token) ERC721("Locked Elys", "LELYS"){
       _baseUri = "";
       _token = token;
       _factory = msg.sender;
       _timestamp = block.timestamp;
    }
    
    function _baseURI()  internal override view returns (string memory) {
        return _baseUri;
    }
    
    function mint(address to, uint256 tokenId, uint256 lockDays, uint256 amount, uint256 reward) public onlyOwner{
        _safeMint(to, tokenId);
        require(lockDays>0 && amount>0);
        _lockedAmount[tokenId] = amount;
        _reward[tokenId] = reward;
        _lockStart[tokenId] = _blockTime();
        _lockDays[tokenId] = lockDays;
    }
    
    function lockedAmount(uint256 tokenId) public view returns (uint256){
        return _lockedAmount[tokenId];
    }
    
    function getReward(uint256 tokenId) public view returns (uint256){
        return _reward[tokenId];
    }
    
    function daysLeft(uint256 tokenId) public view returns (uint256){
       uint256 lockEnd = _lockStart[tokenId] + _lockDays[tokenId]*(1 days);
       if(_blockTime()>lockEnd) return 0;
       return (lockEnd-_blockTime())/(1 days);
    }
    
    function lockInfo(uint256 tokenId) public view returns (uint256, uint256, uint256){
        return (lockedAmount(tokenId), getReward(tokenId), daysLeft(tokenId));
    }
    
    function release(uint256 tokenId) public {
        require(daysLeft(tokenId)==0 && _lockedAmount[tokenId]>0);
        uint256 bal = _lockedAmount[tokenId];
        _lockedAmount[tokenId] = 0;
        uint256 rwrd = _reward[tokenId];
        _reward[tokenId] = 0;
        _token.safeTransfer(ownerOf(tokenId), bal + rwrd);
        _burn(tokenId);
    }
    
    function emergencyRelease(uint256 tokenId) public {
        require(ownerOf(tokenId)==msg.sender);
        require(_lockedAmount[tokenId]>0);
        uint256 bal = _lockedAmount[tokenId];
        _lockedAmount[tokenId] = 0;
        uint256 rwrd = _reward[tokenId];
        _reward[tokenId] = 0;
        _token.safeTransfer(ownerOf(tokenId), bal);
        _token.safeTransfer(_factory, rwrd);
        _burn(tokenId);
    }
    
    function _blockTime() private view returns (uint256){
        //return block.timestamp;
        return _timestamp;
    }
    
    function _inc(uint256 numDays) public {
        _timestamp += numDays * (1 days);
    }
    
}

