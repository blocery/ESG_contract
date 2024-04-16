// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

contract ESGPassORG is ERC721Burnable, AccessControl {

    string public baseURI;
    bytes32 public MINTROLE = 0x12bca523588c492d82109e8191fb2bcd9a5806d976467d1070194c642eb59e03;
    uint256 public tokenId = 1;

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTROLE, msg.sender);
    }

    function setBaseURI(string memory _baseURI) external onlyRole(DEFAULT_ADMIN_ROLE ) {
        baseURI = _baseURI;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControl, ERC721)returns (bool) {
        return true;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function mintTo(address _org) external onlyRole(MINTROLE) {
        require(balanceOf(msg.sender) == 0, "Already minted");
        _mint(msg.sender, tokenId);
        tokenId += 1 ;
    }
}
