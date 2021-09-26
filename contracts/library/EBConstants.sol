// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

library EBConstants {
    enum VaultType {
        FixedRate
    }

    struct VaultInfo {
        address token;
        uint totalAmount;
        uint emission;
        uint lastDepositBlock;
    }

    struct UserInfo {
        uint balance;
    }
}
