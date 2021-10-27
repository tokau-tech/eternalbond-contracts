// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;

library EBConstants {
    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address public constant TOKAU = 0xC409eC8a33f31437Ed753C82EEd3c5F16d6D7e22;

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
