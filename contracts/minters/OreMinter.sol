// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";

import "./Base1155Minter.sol";

import { EBConstants } from "../library/EBConstants.sol";

contract OreMinter is Base1155Minter {
    using AddressUpgradeable for address;

    function initialize(address _chef, address _token) public initializer {
        __OreMinter_init(_chef, _token);
    }

    function __OreMinter_init(address _chef, address _token) internal initializer {
        __Ownable_init_unchained();
        __Context_init_unchained();

        __OreMinter_init_unchained(_chef, _token);
    }

    function __OreMinter_init_unchained(address _chef, address _token) internal initializer {
        setChef(_chef);
        setToken(_token);
    }
}

