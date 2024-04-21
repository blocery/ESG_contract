// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
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
    EnumerableMap.AddressToUintMap balances;
    mapping(uint256 => uint256) public locked;
    
    constructor(address _ESGPassOrg, address _bly, uint256 _threshold) Ownable(msg.sender) {
        ESGPassOrg = _ESGPassOrg;
        BLY = _bly;
        mintThreshold = _threshold;
    }

    function balanceOf(address _holder) public view returns (uint256){
        uint256 bal;
        (, bal) = EnumerableMap.tryGet(balances, _holder);
        return bal;
    }

    function totalStakers() public view returns(uint256) {
        return EnumerableMap.length(balances);
    }

    function _setBalance(address _holder, uint256 _balances) internal {
        EnumerableMap.set(balances, _holder, _balances);
    }

    function _unsetBalance(address _holder) internal {
        EnumerableMap.remove(balances, _holder);
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

        _setBalance(msg.sender, balanceOf(msg.sender) + amount);
    }

    function unstake(uint256 amount) external nonReentrant {
        require(balanceOf(msg.sender) >= amount, "Insufficient staking BLY");
        uint256 blyBefore = IERC20(BLY).balanceOf(address(this));
        IERC20(BLY).transfer(msg.sender, amount);
        uint256 blyAfter= IERC20(BLY).balanceOf(address(this));

        require(blyBefore - blyAfter == amount, "Transfer BLY error");

        _setBalance(msg.sender, balanceOf(msg.sender) - amount);
        if (balanceOf(msg.sender) == 0 ) {
            _unsetBalance(msg.sender);
        }
    }

    function mint() external {
        require(balanceOf(msg.sender) >= mintThreshold, "Need to stake more BLY");

        _setBalance(msg.sender, balanceOf(msg.sender) - mintThreshold);

        uint256 tokenId = IESGPass(ESGPassOrg).TokenId();

        locked[tokenId] = mintThreshold;

        IESGPass(ESGPassOrg).mintTo(msg.sender);
    }

    function burn(uint256 tokenId) external {
        IESGPass(ESGPassOrg).burnFrom(msg.sender, tokenId);
        _setBalance(msg.sender, balanceOf(msg.sender) + locked[tokenId]);
        delete locked[tokenId];
    }
}
