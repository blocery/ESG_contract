// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "hardhat/console.sol";


interface IESGPass {

    function TokenId() external view returns(uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
    function mintTo(address _holder) external ;
    function burnFrom(address _from, uint256 _tokenId) external ;
}

contract BLYStaking  is Ownable, ReentrancyGuard {

    address public ESGPassOrg;
    address public BLY;
    uint256 public mintThreshold;
    mapping(address => uint256) public balances;
    mapping(uint256 => uint256) public locked;
    
    constructor(address _ESGPassOrg, address _bly, uint256 _threshold) Ownable(msg.sender) {
        ESGPassOrg = _ESGPassOrg;
        BLY = _bly;
        mintThreshold = _threshold;
    }

    function setMintThreshold(uint256 _threshold) external onlyOwner {
        mintThreshold = _threshold;
    }

    function stake(uint256 amount) external nonReentrant {
        require(IERC20(BLY).balanceOf(msg.sender) >= amount, "Insufficient BLY balance");
        uint256 blyBefore = IERC20(BLY).balanceOf(address(this));
        IERC20(BLY).transferFrom(msg.sender, address(this), amount);
        uint256 blyAfter = IERC20(BLY).balanceOf(address(this));

        require(blyAfter - blyBefore == amount, "Transfer BLY error");

        balances[msg.sender] += amount;
    }

    function unstake(uint256 amount) external nonReentrant {
        require(balances[msg.sender] >= amount, "Insufficient staking BLY");
        uint256 blyBefore = IERC20(BLY).balanceOf(address(this));
        IERC20(BLY).transfer(msg.sender, amount);
        uint256 blyAfter= IERC20(BLY).balanceOf(address(this));

        require(blyBefore - blyAfter == amount, "Transfer BLY error");

        balances[msg.sender] -= amount;
    }

    function mint() external {
        require(balances[msg.sender] >= mintThreshold, "Need to stake more BLY");

        balances[msg.sender] -= mintThreshold;

        uint256 tokenId = IESGPass(ESGPassOrg).TokenId();

        locked[tokenId] = mintThreshold;

        IESGPass(ESGPassOrg).mintTo(msg.sender);
    }

    function burn(uint256 tokenId) external {
        IESGPass(ESGPassOrg).burnFrom(msg.sender, tokenId);
        balances[msg.sender] += locked[tokenId];
        delete locked[tokenId];
    }
}
