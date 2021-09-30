// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

import './interfaces/pancake-swap-lib/IBEP20.sol';
import './interfaces/pancake-swap-lib/SafeBEP20.sol';
import "./interfaces/pancake-swap-lib/SafeMath.sol";

import "./interfaces/IEBChef.sol";
import "./interfaces/IEB1155Minter.sol";
import "./interfaces/IEBVault.sol";

import { EBConstants } from "./library/EBConstants.sol";

contract EBChef is IEBChef, Initializable, OwnableUpgradeable {
    using SafeMathUpgradeable for uint;
    using AddressUpgradeable for address;
    using SafeBEP20 for IBEP20;

    uint public totalEmission;
    address public minter;

    mapping(address => EBConstants.VaultInfo) vaults;
    mapping(address => mapping(address => EBConstants.UserInfo)) vaultUsers;
    
    modifier onlyVaults {
        require(vaults[msg.sender].token != address(0), "Chef: caller is not on the vault");
        _;
    }
    
    event NFT1155Minted(address indexed vault, address indexed user, uint tokenId, uint amount);

    function initialize(uint _totalEmission) public initializer {
        __EBChef_init(_totalEmission);
    }

    function __EBChef_init(uint _totalEmission) internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();

        __EBChef_init_unchained(_totalEmission);
    }

    function __EBChef_init_unchained(uint _totalEmission) internal initializer {
        totalEmission = _totalEmission;
    }

    function vaultInfo(address vault) public override view returns (EBConstants.VaultInfo memory) {
        return vaults[vault];
    }

    function vaultUserInfo(address vault, address user) public override view returns (EBConstants.UserInfo memory) {
        return vaultUsers[vault][user];
    }

    function setMinter(address _minter) public onlyOwner {
        minter = _minter;
    }

    function addVault(address vault) public onlyOwner {
        require(vaults[vault].token == address(0), "Chef: vault exists");
        require(IEBVault(vault).token() != address(0), "invalid vault");
        
        totalEmission = totalEmission.add(IEBVault(vault).emissionRate());
        vaults[vault] = EBConstants.VaultInfo(IEBVault(vault).token(), 0, IEBVault(vault).emissionRate(), block.number);
    }

    function updateVault(address vault, address _token, uint emission) public onlyOwner {
        require(vaults[vault].token == address(0), "Chef: vault doesn't exists");
        
        uint _emission = vaults[vault].emission;
        if (_emission != emission) {
            totalEmission = totalEmission.sub(_emission).add(emission);
        }
        vaults[vault].emission = emission;
        vaults[vault].token = _token;
    } 

    function vaultDeposited(address user, uint amount) external override onlyVaults {
        EBConstants.UserInfo storage _userInfo = vaultUsers[msg.sender][user];
        EBConstants.VaultInfo storage _vaultInfo = vaults[msg.sender];

        _vaultInfo.lastDepositBlock = block.number;
        _vaultInfo.totalAmount = _vaultInfo.totalAmount.add(amount);

        _userInfo.balance = _userInfo.balance.add(amount);

        emit VaultDeposited(msg.sender, user, amount);
    }

    function vaultWithdrawn(address user, uint amount) external override onlyVaults {
        EBConstants.UserInfo storage _userInfo = vaultUsers[msg.sender][user];
        EBConstants.VaultInfo storage _vaultInfo = vaults[msg.sender];

        _vaultInfo.totalAmount = _vaultInfo.totalAmount.sub(amount);

        _userInfo.balance = _userInfo.balance.sub(amount);

        emit VaultWithdrawn(msg.sender, user, amount);
    }

    function safeMint1155(address user, uint tokenId, uint amount) public override onlyVaults {
        // use IERC165
        require(IEBVault(msg.sender).isErc1155Token(), "vault doesn't support 1155 token");
        IEB1155Minter(minter).mint(user, tokenId, amount);
    }
}