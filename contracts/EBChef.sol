// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

import '@pancakeswap/pancake-swap-lib/contracts/token/BEP20/IBEP20.sol';
import '@pancakeswap/pancake-swap-lib/contracts/token/BEP20/SafeBEP20.sol';
import "@pancakeswap/pancake-swap-lib/contracts/math/SafeMath.sol";

import "./interfaces/IEBChef.sol";
import "./interfaces/IEB1155Minter.sol";
import "./interfaces/IEBVault.sol";

import { EBConstants } from "./library/EBConstants.sol";

contract EBChef is IEBChef, Initializable, OwnableUpgradeable {
    using SafeMath for uint;
    using AddressUpgradeable for address;
    using SafeBEP20 for IBEP20;

    uint public totalEmission;
    address public minter;

    mapping(address => VaultInfo) vaults;
    mapping(address => mapping(address => UserInfo)) vaultUsers;
    
    modifier onlyVaults {
        require(vaults[msg.sender].token != address(0), "OreChef: caller is not on the vault");
        _;
    }
    
    event NFT1155Minted(address indexed vault, address indexed user, uint tokenId, uint amount);

    function initialize(uint _totalEmission) public initializer {
        totalEmission = _totalEmission;
    }

    function vaultInfo(address vault) public override view returns (VaultInfo memory) {
        return vaults[vault];
    }

    function vaultUserInfo(address vault, address user) public override view returns (UserInfo memory) {
        return vaultUsers[vault][user];
    }

    function setMinter(address _minter) public onlyOwner {
        minter = _minter;
    }

    function addVault(address vault, address token, uint emission) public onlyOwner {
        require(vaults[vault].token == address(0), "OreChef: vault exists");
        
        uint lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        
        totalEmission = totalEmission.add(emission);
        vaults[vault] = VaultInfo(token, emission, lastRewardBlock);
    }

    function updateVault(address vault, uint emission) public onlyOwner {
        require(vaults[vault].token == address(0), "OreChef: vault doesn't exists");
        
        uint _emission = vaults[vault].emission;
        if (_emission != emission) {
            totalEmission = totalEmission.sub(_emission).add(emission);
        }
        vaults[vault].emission = emission;
    } 

    function vaultDeposited(address user, uint amount) external override onlyVaults {
        UserInfo memory userInfo = vaultUsers[msg.sender][user];
        VaultInfo memory vaultInfo = vaults[msg.sender];

        vaultInfo.lastDepositBlock = block.number;
        vaultInfo.totalAmount = vaultInfo.totalAmount.add(amount);

        userInfo.balance = userInfo.balance.add(amount);

        emit VaultDeposited(msg.sender, user, amount);
    }

    function vaultWithdrawn(address user, uint amount) external override onlyVaults {
        UserInfo memory userInfo = vaultUsers[msg.sender][user];
        VaultInfo memory vaultInfo = vaults[msg.sender];

        vaultInfo.totalAmount = vaultInfo.totalAmount.sub(amount);

        userInfo.balance = userInfo.balance.sub(amount);

        emit VaultWithdrawn(msg.sender, user, amount);
    }

    function safeMint1155(address user, uint tokenId, uint amount) public override onlyVaults {
        // use IERC165
        require(IEBVault(msg.sender).isErc1155Token(), "vault doesn't support 1155 token");
        IEB1155Minter(minter).mint(user, tokenId, amount);
    }
}