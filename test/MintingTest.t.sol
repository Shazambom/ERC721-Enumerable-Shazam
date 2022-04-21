// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "ds-test/test.sol";
import "../src/ERC721EnumerableS.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
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
    ImplementedEnumerableS enumerableS;
    ImplementedEnumerable enumerable;

    function setUp() public {
        enumerableS = new ImplementedEnumerableS("bit", "boi");
        enumerable = new ImplementedEnumerable("bit", "boi");
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }    

    function testGasMintingOneS() public {
        enumerableS.mint(msg.sender, 0);
    }
    function testGasMintingFiveS() public {
        for (uint256 i = 0; i < 5; i++) {
            enumerableS.mint(msg.sender, i);
        }
    }
    function testGasMinting5kS() public {
        for (uint256 i = 0; i < 5000; i++) {
            enumerableS.mint(msg.sender, i);
        }
    }
    function testGasMinting10kS() public {
        for (uint256 i = 0; i < 10000; i++) {
            enumerableS.mint(msg.sender, i);
        }
    }
    function testGasMintingOne_HighIndexS() public {
        enumerableS.mint(msg.sender, 10000);
    }

    function testGasMintingFive_HighIndexS() public {
        for (uint256 i = 0; i < 5; i++) {
            enumerableS.mint(msg.sender, i + 10000);
        }
    }


    function testGasMintingOne() public {
        enumerable.mint(msg.sender, 0);
    }
    function testGasMintingFive() public {
        for (uint256 i = 0; i < 5; i++) {
            enumerable.mint(msg.sender, i);
        }
    }
    function testGasMinting5k() public {
        for (uint256 i = 0; i < 5000; i++) {
            enumerable.mint(msg.sender, i);
        }
    }
    function testGasMinting10k() public {
        for (uint256 i = 0; i < 10000; i++) {
            enumerable.mint(msg.sender, i);
        }
    }
    function testGasMintingOne_HighIndex() public {
        enumerable.mint(msg.sender, 10000);
    }
    function testGasMintingFive_HighIndex() public {
        for (uint256 i = 0; i < 5; i++) {
            enumerable.mint(msg.sender, i + 10000);
        }
    }
}

