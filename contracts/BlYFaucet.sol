// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract BLYFaucet is Ownable {

    uint256 public period;
    mapping(address => uint256) lastClaim;
    address public BLY;
    
    constructor(address _bly, uint256 _period) Ownable(msg.sender) {
        BLY = _bly;
        period = _period;
    }

    function setPeriod(uint256 _period) external onlyOwner {
        period = _period;
    }

    function claim() external {
        require(lastClaim[msg.sender] < block.timestamp - period, "claim limited");
        lastClaim[msg.sender] = block.timestamp;
        IERC20(BLY).transfer(msg.sender, 10000 ether);
    }
}
