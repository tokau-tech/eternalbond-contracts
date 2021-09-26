// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokAu is ERC20 {
    constructor() ERC20("Tokyo AU Token", "TOKAU") {
        _mint(_msgSender(), 1 * 10 ** 33);
    }

    // function decimals() public view override returns (uint8) {
    //     return 18;
    // }
}