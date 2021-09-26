// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "./ERC721PresetMinterPauser.sol";

contract TokAuTreasurePeriphery is ERC721PresetMinterPauser {
    constructor() ERC721PresetMinterPauser("Tokau Treasure Periphery", "TTP", "https://app.tokau.io/tp/") {
    }

    function batchMint(address[] memory addresses_, uint256[] memory tokenIds_) public onlyRole(MINTER_ROLE) {
        require(addresses_.length > 0, "supply some addresses to mint");
        require(addresses_.length == tokenIds_.length, "length mismatch");
        for (uint i = 0; i < addresses_.length; i++) {
            mint(addresses_[i], tokenIds_[i]);
        }
    }
}


