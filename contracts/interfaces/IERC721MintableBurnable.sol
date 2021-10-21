// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IERC721MintableBurnable is IERC721 {
    function burn(uint256 tokenId) external;

    function mint(address to) external;

    function mintWithTokenId(address to, uint tokenId) external;
}