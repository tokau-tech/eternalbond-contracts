// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "../interfaces/IEBVault.sol";

import { EBConstants } from "../library/EBConstants.sol";

abstract contract BaseVault is IEBVault, Initializable, OwnableUpgradeable, PausableUpgradeable, ReentrancyGuardUpgradeable {
    using AddressUpgradeable for address;

    address public chef;
    address public override token;

    modifier onlyChef() {
        require(msg.sender == chef, "Base Vault: operater not chef");
        _;
    }

    function setChef(address _chef) internal onlyOwner {
        chef = _chef;
    }

    function setToken(address _token) internal onlyOwner {
        token = _token;
    }
}

