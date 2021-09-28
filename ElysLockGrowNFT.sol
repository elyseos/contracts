// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LockedELYS is ERC721, Ownable {
    using SafeERC20 for IERC20;
    
    string private _baseUri;
    IERC20 private immutable _token;
    IERC20 private immutable _lpToken;
    
    mapping(uint256 => uint256) private _lockedAmount; //maps tokenID to amount locked for that token
    mapping(uint256 => uint256) private _reward; //maps tokenID to amount locked for that token
    mapping(uint256 => uint256) private _lockDays; //maps tokenID to num days locked
    mapping(uint256 => uint256) private _lockStart; //maps tokenID to start of lock
    
    constructor(IERC20 token, IERC20 lpToken) ERC721("Locked Elys", "LELYS"){
       _baseUri = "";
       _token = token;
       _lpToken = lpToken;
    }
    
    function _baseURI()  internal override view returns (string memory) {
        return _baseUri;
    }
    
    function mint(address to, uint256 tokenId, uint256 lockDays, uint256 amount, uint256 rwrd) public onlyOwner{
        _safeMint(to, tokenId);
        require(lockDays>0 && amount>0);
        _lockedAmount[tokenId] = amount;
        _reward[tokenId] = rwrd;
        _lockStart[tokenId] = block.timestamp;
        _lockDays[tokenId] = lockDays;
    }
    
    function lockedAmount(uint256 tokenId) public view returns (uint256){
        return _lockedAmount[tokenId];
    }
    
    function reward(uint256 tokenId) public view returns (uint256){
        return _reward[tokenId];
    }
    
    function daysLeft(uint256 tokenId) public view returns (uint256){
       uint256 lockEnd = _lockStart[tokenId] + _lockDays[tokenId]*(1 days);
       if(block.timestamp>lockEnd) return 0;
       return (lockEnd-block.timestamp)/(1 days);
    }
    
    function lockInfo(uint256 tokenId) public view returns (uint256, uint256, uint256){
        return (lockedAmount(tokenId), reward(tokenId),daysLeft(tokenId));
    }
    
    function release(uint256 tokenId) public {
        require(daysLeft(tokenId)==0 && _lockedAmount[tokenId]>0);
        uint256 balLocked = _lockedAmount[tokenId];
        uint256 balReward = _reward[tokenId];
        _lockedAmount[tokenId] = 0;
        _reward[tokenId] = 0;
        _lpToken.safeTransfer(ownerOf(tokenId), balLocked);
        _token.safeTransfer(ownerOf(tokenId), balReward);
        _burn(tokenId);
        
    }
    
}

