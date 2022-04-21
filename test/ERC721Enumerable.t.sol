// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "ds-test/test.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";


contract ImplementedEnumerable is ERC721, ERC721Burnable, ERC721Enumerable  {
    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {}

    function mint(address recipient, uint256 tokenId) public {
        _safeMint(recipient, tokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

}

contract ERC721EnumerableTest is DSTest {
    ImplementedEnumerable bitBoi;

    function setUp() public {
        bitBoi = new ImplementedEnumerable("bit", "boi");
    }

    function testGasTotalSupply() public {
        bitBoi.mint(msg.sender, 0);
        bitBoi.totalSupply();
    }
    function testGasTokenByIndex() public {
        bitBoi.mint(msg.sender, 0);
        bitBoi.tokenByIndex(0);
    }
    function testGasTokenByIndex_HighIndex() public {
        bitBoi.mint(msg.sender, 10000);
        bitBoi.tokenByIndex(0);
    }
    function testGasTokenOfOwnerByIndex() public {
        bitBoi.mint(msg.sender, 0);
        bitBoi.tokenOfOwnerByIndex(msg.sender, 0);
    }
    function testGasTokenOfOwnerByIndex_HighIndex() public {
        bitBoi.mint(msg.sender, 10000);
        bitBoi.tokenOfOwnerByIndex(msg.sender, 0);
    }

}

