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

    function testMintOne() public {
        bitBoi.mint(msg.sender, 0);
        assertEq(bitBoi.totalSupply(), 1);
    }
    function testMintTree() public {
        bitBoi.mint(msg.sender, 0);
        bitBoi.mint(msg.sender, 1);
        bitBoi.mint(msg.sender, 2);
        assertEq(bitBoi.totalSupply(), 3);
    }

    function testMint512() public {
        for (uint256 i = 0; i < 512; i++) {
            bitBoi.mint(msg.sender, i);
        }
        assertEq(bitBoi.totalSupply(), 512);
    }

    function testMint16Skipping() public {
        for (uint256 i = 0; i < 8; i++) {
            bitBoi.mint(msg.sender, i);
        }
        for (uint256 i = 0; i < 8; i++) {
            bitBoi.mint(msg.sender, i + 512);
        }
        assertEq(bitBoi.totalSupply(), 16);
    }

}

