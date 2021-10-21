// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

import '../interfaces/pancake-swap-lib/IBEP20.sol';
import '../interfaces/pancake-swap-lib/SafeBEP20.sol';

import "./BaseVault.sol";
import "../interfaces/IEBChef.sol";

contract OreNftStakeVaultV1 is BaseVault {

    modifier updateReward(address user) {
        _;
    }

    function initialize() public initializer {
        
    }

    function emissionRate() public view override returns (uint) {
        
    }

    function isErc1155Token() public pure override returns (bool) {
        return true;
    }

    function balanceOf() public view override returns (uint) {
        
    }

    function deposit(uint amount) public override {

    }

    function withdraw(uint amount) public override {
        
    }

    function withdrawAll() public override {
        
    }
}