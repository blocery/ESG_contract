// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "hardhat/console.sol";


interface IESGPass {

    function TokenId() external view returns(uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
    function mintTo(address _holder) external ;
    function burnFrom(address _from, uint256 _tokenId) external ;
}

contract BLYDelegation is OwnableUpgradeable, ReentrancyGuardUpgradeable{

    address public ESGPassOrg;
    address public BLY;
    EnumerableMap.AddressToUintMap balances;
    mapping(address => uint256) public userPower;
    mapping(uint256 => uint256) public esgPower;
    mapping(address=> mapping(uint256 => uint256)) public delegatedPower;
    
    event Staked(address indexed holder, uint256 value, uint256 total);
    event Unstaked(address indexed holder, uint256 value, uint256 total);

    event Delegated(address indexed holder, uint256 indexed orgId, uint256 value);
    event Undelegated(address indexed holder, uint256 indexed orgId, uint256 value);

   function initialize(address _ESGPassOrg, address _bly) public initializer {
        __Ownable_init(msg.sender);
        __ReentrancyGuard_init();
        ESGPassOrg = _ESGPassOrg;
        BLY = _bly;
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

    function _stake(uint256 amount, address holder) private {
        require(IERC20(BLY).balanceOf(holder) >= amount, "Insufficient BLY balance");

        uint256 blyBefore = IERC20(BLY).balanceOf(address(this));
        IERC20(BLY).transferFrom(holder, address(this), amount);
        uint256 blyAfter = IERC20(BLY).balanceOf(address(this));

        require(blyAfter - blyBefore == amount, "Transfer BLY error");

        _setBalance(holder, balanceOf(holder) + amount);
        userPower[holder] += amount;
        emit Staked(holder, amount, balanceOf(holder));
    }


    function _unstake(uint256 amount, address holder) private {
        require(balanceOf(holder) >= amount, "Insufficient staking BLY");
        uint256 blyBefore = IERC20(BLY).balanceOf(address(this));
        IERC20(BLY).transfer(holder, amount);
        uint256 blyAfter= IERC20(BLY).balanceOf(address(this));

        require(blyBefore - blyAfter == amount, "Transfer BLY error");

        _setBalance(holder, balanceOf(holder) - amount);
        if (balanceOf(holder) == 0 ) {
            _unsetBalance(holder);
        }
        require(userPower[holder] >= amount, "Revoke delegated BLY first");
        emit Unstaked(holder, amount, balanceOf(holder));
    }

    function delegate(uint256 amount, uint256 orgId) external nonReentrant {
        require(IESGPass(ESGPassOrg).ownerOf(orgId) != address(0), "Invalid ESG OrgPass");
        _stake(amount, msg.sender);
        userPower[msg.sender] -= amount;
        esgPower[orgId] += amount;
        delegatedPower[msg.sender][orgId] += amount;
        emit Delegated(msg.sender, orgId, amount);
    }

    function undelegate(uint256 amount, uint256 orgId) external nonReentrant {
        require(IESGPass(ESGPassOrg).ownerOf(orgId) != address(0), "Invalid ESG OrgPass");
        console.log("t", delegatedPower[msg.sender][orgId]);
        require(delegatedPower[msg.sender][orgId] >= amount, "Insufficient BLY to undelegate");
        esgPower[orgId] -= amount;
        userPower[msg.sender] += amount;
        delegatedPower[msg.sender][orgId] -= amount;
        _unstake(amount, msg.sender);
        emit Undelegated(msg.sender, orgId, amount);
    }

}
