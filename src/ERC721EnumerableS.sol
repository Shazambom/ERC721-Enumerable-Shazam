// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Enumerable.sol";


/**
 * Theory on how to implement this with less memory:
 * 
 * If we have a bitmap that represents all minted IDs we can iterate over the bit representation and the token space
 * Using this we can ensure that tokenID == index for our iteration
 * 
 * Abuse the fact that all functions in the interface are "view" functions and don't require gas to call.
 * This should significantly reduce the gas cost of this extension
 */

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {

    //Map that represents the gaps in the ID space
    uint256[] private _bitmap;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        uint256 count = 0;
        for (uint256 i = 0; i < _bitmap.length << 8; i++) {
            uint256 mask = 1 << uint8(i);
            if (mask & _bitmap[i >> 8] != 0 && ERC721.ownerOf(i) == owner) {
                count++;
                if (count == index) {
                    return i;
                }
            }
        }
        revert("ERC721EnumerableS: Unable to find token");
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < _bitmap.length; i++) {
           sum += countSetBits(_bitmap[i]);
        }
        return sum;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        uint256[] memory blocks;
        for (uint256 i = 0; i < _bitmap.length; i++) {
            blocks[i] = countSetBits(_bitmap[i]);
        }
        uint256 counter = index;
        uint256 bitmapIndex;
        for (uint256 i = 0; i < blocks.length; i++) {
            if (blocks[i] < counter) {
                counter -= blocks[i];
            } else {
                bitmapIndex = i;
                break;
            }
        }
        for (uint256 i = 0; i < 256; i++) {
            uint256 mask = 1 << uint8(i);
            if (mask & _bitmap[bitmapIndex] != 0) {
                counter--;
                if (counter == 0) {
                    return (1 << bitmapIndex ) + i;
                }
            }
        }
        revert("ERC721EnumerableS: Unable to find token by index");
    }

    /**
    * @notice Counts the number of set bits (Hamming weight).
    * @param v Bitmap.
    * @return Number of set bits.
    */
   function countSetBits(uint256 v) internal pure returns (uint256) {
        uint256 res = 0;
        uint256 acc = v;
        for (uint256 i = 0; i < 256; i++) {
            if (acc & 1 == 1) res += 1;
            acc = acc >> 1;
        }
        return res;
    }


    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } 
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        }
    }


    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        while(tokenId >> 8 > _bitmap.length) {
            _bitmap.push(0);
        }
        uint8 pos = uint8(tokenId);
        uint256 index = tokenId >> 8;
        uint256 mask = 1 << pos;
        _bitmap[index] = _bitmap[index] | mask;
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        uint8 pos = uint8(tokenId);
        uint256 index = tokenId >> 8;
        uint256 mask = 1 << pos;
        mask = mask ^ 0xffffffffffffffff;
        _bitmap[index] = _bitmap[index] & mask;
    }
}