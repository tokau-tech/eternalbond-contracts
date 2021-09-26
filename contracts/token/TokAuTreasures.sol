// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/presets/ERC1155PresetMinterPauserUpgradeable.sol";

contract TokAuTreasures is ERC1155PresetMinterPauserUpgradeable {
    function initialize(string memory baseUri) public override initializer {
        ERC1155PresetMinterPauserUpgradeable.initialize(baseUri);
    }
}