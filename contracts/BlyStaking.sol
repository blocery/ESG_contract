// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";


interface IESGPass {

    function mintTo(address _holder) external ;
}


contract BLYStaking  is Ownable, ReentrancyGuard {

    address public ESGPassOrg;
    address public BLY;
    uint256 public mintThreshold;
    mapping(address => uint256) public balances;
    
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

        IESGPass(ESGPassOrg).mintTo(msg.sender);
    }
}
