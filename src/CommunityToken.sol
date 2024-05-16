// SPDX-License-Identifier: MIT
// Started out as contract created through OpenZeppelins contracts wizard.

pragma solidity 0.8.24;

import {ERC721Votes} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Votes.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract CommunityToken is ERC721, EIP712, ERC721Votes {
    uint256 private _nextTokenId;

    constructor() ERC721("CommunityToken", "TID") EIP712("MyToken", "1") {}

    function awardIdentity(address member) public returns (uint256) {
        uint256 tokenId = _nextTokenId++;
        _mint(member, tokenId);

        return tokenId;
    }

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Votes)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value) internal override(ERC721, ERC721Votes) {
        super._increaseBalance(account, value);
    }
}
