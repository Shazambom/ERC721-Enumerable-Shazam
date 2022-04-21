// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "ds-test/test.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";


contract ImplementedEnumerable is ERC721, ERC721Burnable, ERC721Enumerable {
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

contract ERC721EnumerableSTest is DSTest, IERC721Receiver {
    ImplementedEnumerable bitBoi;

    function setUp() public {
        bitBoi = new ImplementedEnumerable("bit", "boi");
        for (uint256 i = 0; i < 256; i++) {
            bitBoi.mint(address(this), i);
        }
        for (uint256 i = 0; i < 256; i++) {
            bitBoi.mint(address(this), i + 512);
        }
        for (uint256 i = 0; i < 256; i += 2) {
            bitBoi.mint(address(this), i + 768);
        }
        for (uint256 i = 1; i < 256; i += 2) {
            bitBoi.mint(address(this), i + 1024);
        }
        for (uint256 i = 0; i < 256; i++) {
            bitBoi.mint(address(this), i + 1280);
            i += i % 8;
        }
        for (uint256 i = 0; i < 8464; i++) {
            bitBoi.mint(address(this), i + 1536);
        }

    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function testTotalSupply() public {
        assertEq(bitBoi.totalSupply(), 9267);
    }

    function testBalanceOf() public {
        assertEq(bitBoi.balanceOf(address(this)), 9267);
    }

    function testTokenOfOwnerByIndexMin() public {
        assertEq(bitBoi.tokenOfOwnerByIndex(address(this), 0), 0);
    }

    function testTokenOfOwnerByIndexMax() public {
        assertEq(bitBoi.tokenOfOwnerByIndex(address(this), 9266), 9999);
    }

    function testTokenByIndexMin() public {
        assertEq(bitBoi.tokenByIndex(0), 0);
    }

    function testTokenByIndexMax() public {
        assertEq(bitBoi.tokenByIndex(9266), 9999);
    }

}

