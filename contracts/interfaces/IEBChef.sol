// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import { EBConstants } from "../library/EBConstants.sol";

interface IEBChef {

    // function totalEmission() external view returns (uint);

    // function updateRewards(address vault) external;

    function vaultInfo(address vault) external view returns (EBConstants.VaultInfo memory);

    function vaultUserInfo(address vault, address user) external view returns (EBConstants.UserInfo memory);

    function vaultDeposited(address user, uint amount) external;

    function vaultWithdrawn(address user, uint amount) external;

    function safeMint1155(address user, uint tokenId, uint amount) external;

    event VaultDeposited(address indexed vault, address indexed user, uint amount);
    event VaultWithdrawn(address indexed vault, address indexed user, uint amount);
}
