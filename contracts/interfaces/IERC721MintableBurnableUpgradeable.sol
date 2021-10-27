// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";

interface IERC721MintableBurnableUpgradeable is IERC721Upgradeable {
    function burn(uint256 tokenId) external;

    function mint(address to) external;

    function mintWithTokenId(address to, uint tokenId) external;
}
