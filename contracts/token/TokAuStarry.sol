// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "./ERC721PresetMinterPauser.sol";

contract TokAuStarry is ERC721PresetMinterPauser {
    constructor() ERC721PresetMinterPauser("TokAu Starry Token", "TAST", "https://app.tokau.io/") {
    }
}