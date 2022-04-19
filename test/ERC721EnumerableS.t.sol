// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "ds-test/test.sol";
import "../src/ERC721EnumerableS.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";


contract ImplementedEnumerableS is ERC721, ERC721Burnable, ERC721EnumerableS  {
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
    ) internal virtual override(ERC721, ERC721EnumerableS) {
        super._beforeTokenTransfer(from, to, tokenId);
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721EnumerableS) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

}

contract ERC721EnumerableSTest is DSTest, IERC721Receiver {
    ImplementedEnumerableS bitBoi;

    function setUp() public {
        bitBoi = new ImplementedEnumerableS("bit", "boi");
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
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

    function testTokenOfOwnerByIndex() public {
        for (uint256 i = 0; i < 4; i++) {
            bitBoi.mint(msg.sender, i);
        }
        for (uint256 i = 0; i < 4; i++) {
            bitBoi.mint(msg.sender, i + 64);
        }
        for (uint256 i = 0; i < 4; i++) {
            bitBoi.mint(msg.sender, i + 8900);
        }
        for (uint256 i = 0; i < 4; i++) {
            bitBoi.mint(msg.sender, i + 512);
        }
        assertEq(bitBoi.totalSupply(), 16);

        assertEq(bitBoi.balanceOf(msg.sender), 16);

        assertEq(bitBoi.tokenOfOwnerByIndex(msg.sender, 0), 0);
        assertEq(bitBoi.tokenOfOwnerByIndex(msg.sender, 1), 1);
        assertEq(bitBoi.tokenOfOwnerByIndex(msg.sender, 2), 2);
        assertEq(bitBoi.tokenOfOwnerByIndex(msg.sender, 3), 3);
        assertEq(bitBoi.tokenOfOwnerByIndex(msg.sender, 4), 64);
        assertEq(bitBoi.tokenOfOwnerByIndex(msg.sender, 5), 65);
        assertEq(bitBoi.tokenOfOwnerByIndex(msg.sender, 6), 66);
        assertEq(bitBoi.tokenOfOwnerByIndex(msg.sender, 7), 67);
        assertEq(bitBoi.tokenOfOwnerByIndex(msg.sender, 8), 512);
        assertEq(bitBoi.tokenOfOwnerByIndex(msg.sender, 9), 513);
        assertEq(bitBoi.tokenOfOwnerByIndex(msg.sender, 10), 514);
        assertEq(bitBoi.tokenOfOwnerByIndex(msg.sender, 11), 515);
        assertEq(bitBoi.tokenOfOwnerByIndex(msg.sender, 12), 8900);
        assertEq(bitBoi.tokenOfOwnerByIndex(msg.sender, 13), 8901);
        assertEq(bitBoi.tokenOfOwnerByIndex(msg.sender, 14), 8902);
        assertEq(bitBoi.tokenOfOwnerByIndex(msg.sender, 15), 8903);
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

    function testTokenByIndex() public {
        for (uint256 i = 0; i < 4; i++) {
            bitBoi.mint(msg.sender, i);
        }
        for (uint256 i = 0; i < 4; i++) {
            bitBoi.mint(msg.sender, i + 64);
        }
        for (uint256 i = 0; i < 4; i++) {
            bitBoi.mint(msg.sender, i + 8900);
        }
        for (uint256 i = 0; i < 5; i++) {
            bitBoi.mint(msg.sender, i + 511);
        }
        bitBoi.mint(msg.sender, 255);
        bitBoi.mint(msg.sender, 256);
        bitBoi.mint(msg.sender, 257);
    
        assertEq(bitBoi.totalSupply(), 20);

        assertEq(bitBoi.tokenByIndex(0), 0);
        assertEq(bitBoi.tokenByIndex(1), 1);
        assertEq(bitBoi.tokenByIndex(2), 2);
        assertEq(bitBoi.tokenByIndex(3), 3);
        assertEq(bitBoi.tokenByIndex(4), 64);
        assertEq(bitBoi.tokenByIndex(5), 65);
        assertEq(bitBoi.tokenByIndex(6), 66);
        assertEq(bitBoi.tokenByIndex(7), 67);
        assertEq(bitBoi.tokenByIndex(8), 255);
        assertEq(bitBoi.tokenByIndex(9), 256);
        assertEq(bitBoi.tokenByIndex(10), 257);
        assertEq(bitBoi.tokenByIndex(11), 511);
        assertEq(bitBoi.tokenByIndex(12), 512);
        assertEq(bitBoi.tokenByIndex(13), 513);
        assertEq(bitBoi.tokenByIndex(14), 514);
        assertEq(bitBoi.tokenByIndex(15), 515);
        assertEq(bitBoi.tokenByIndex(16), 8900);
        assertEq(bitBoi.tokenByIndex(17), 8901);
        assertEq(bitBoi.tokenByIndex(18), 8902);
        assertEq(bitBoi.tokenByIndex(19), 8903);
        
    }

    function testBurning() public {
        bitBoi.mint(address(this), 0);
        bitBoi.mint(address(this), 1);
        bitBoi.mint(address(this), 2);
        assertEq(bitBoi.totalSupply(), 3);
        bitBoi.burn(1);
        assertEq(bitBoi.totalSupply(), 2);
        assertEq(bitBoi.tokenByIndex(0), 0);
        assertEq(bitBoi.tokenByIndex(1), 2);
        assertEq(bitBoi.tokenOfOwnerByIndex(address(this), 0), 0);
        assertEq(bitBoi.tokenOfOwnerByIndex(address(this), 1), 2);

    }
}

