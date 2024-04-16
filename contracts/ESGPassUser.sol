// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

contract ESGPassUser is ERC721Burnable, Ownable {

    string public baseURI;
    uint256 public tokenId = 1;

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) Ownable(msg.sender){
    }

    function setBaseURI(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function mint() external {
        _mint(msg.sender, tokenId);
        tokenId += 1;
    }
}
