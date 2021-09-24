// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IEB1155Minter {
    function token() external view returns (address);

    function mint(address user, uint tokenId, uint amount) external;

    function mintFor(address _token, address user, uint tokenId, uint amount) external;

    function safeTransfer(address user, uint tokenId, uint amount) external;
}

