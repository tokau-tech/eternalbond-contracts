// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

import '../interfaces/pancake-swap-lib/IBEP20.sol';
import '../interfaces/pancake-swap-lib/SafeBEP20.sol';

import "./BaseVault.sol";
import "../interfaces/IEBChef.sol";

import { EBConstants } from "../library/EBConstants.sol";

/*
    lock token and mint 1155 nft rewards when they just deposited related tokens.
    using a given emission rate.
*/
contract OreLockerVault is BaseVault {
    using SafeMathUpgradeable for uint;
    using SafeBEP20 for IBEP20;

    struct UserLockerInfo {
        uint period;
        uint boostRate;
        uint balance;
        uint depositTimestamp;
    }

    uint public oreTokenId;
    uint public totalAmount;
    uint public override emissionRate;

    uint[] public periods;
    mapping(uint => uint) public lockerBoosters;
    mapping(address => UserLockerInfo[]) public balances;

    event OreLockerVaultDeposited(address user, uint period, uint amount);
    event OreLockerVaultWithdrawn(address user, uint amount);
    event OreEmissionRateChanged(uint oldEmissionRate, uint newEmissionRate);
    event OreBoostersChanged(uint[] indexed _periods, uint[] indexed _boostRates);

    function initialize(address _chef, address _token, uint _oreTokenId, uint _emissionRate) public initializer {
        __OreLockerVault_init(_chef, _token, _oreTokenId, _emissionRate);
    }

    function __OreLockerVault_init(address _chef, address _token, uint _oreTokenId, uint _emissionRate) internal initializer {
        __Ownable_init_unchained();
        __Context_init_unchained();
        __Pausable_init_unchained();
        __ReentrancyGuard_init_unchained();

        __OreLockerVault_init_unchained(_chef, _token, _oreTokenId, _emissionRate);
    }

    function __OreLockerVault_init_unchained(address _chef, address _token, uint _oreTokenId, uint _emissionRate) internal initializer {
        setChef(_chef);
        setToken(_token);
        setEmissionRate(_emissionRate);
        setOreTokenId(_oreTokenId);
    }

    function setOreTokenId(uint _oreTokenId) public onlyOwner {
        oreTokenId = _oreTokenId;
    }

    function setEmissionRate(uint _emissionRate) public onlyOwner {
        require(_emissionRate > 0, "emissionRate should greater than 0");
        uint oldEmissionRate = emissionRate;
        emissionRate = _emissionRate;
        emit OreEmissionRateChanged(oldEmissionRate, emissionRate);
    }

    function isErc1155Token() public pure override returns (bool) {
        return true;
    }

    function setLockerPeroids(uint[] memory _periods, uint[] memory _boostRates) public onlyOwner {
        require(_periods.length > 0, "invalid periods");
        require(_periods.length == _boostRates.length, "periods and boostRates should have same length");
        delete periods;
        for (uint i=0; i<_periods.length; i++) {
            lockerBoosters[_periods[i]] = _boostRates[i];
            periods.push(_periods[i]);
        }
        emit OreBoostersChanged(_periods, _boostRates);
    }

    function depositLocker(uint periodIndex, uint amount) public nonReentrant {
        _deposit(periodIndex, amount);
    }

    function deposit(uint amount) public override nonReentrant {
        _deposit(0, amount);
    }

    function withdraw(uint amount) public override nonReentrant {
        require(amount > 0 && amount <= unlockedBalance(), "invalid amount");
        _withdraw(amount);
    }

    function balance() public view override returns (uint) {
        return balanceOf(msg.sender);
    }

    function balanceOf(address _user) public view override returns (uint) {
        UserLockerInfo[] storage lockerInfos = balances[_user];
        uint _balance = 0;
        for (uint i=0; i< lockerInfos.length; i++) {
            UserLockerInfo storage lockerInfo = lockerInfos[i];
            _balance = _balance.add(lockerInfo.balance);
        }
        return _balance;
    }

    function unlockedBalance() public view returns (uint) {
        UserLockerInfo[] storage lockerInfos = balances[msg.sender];
        uint _balance = 0;
        for (uint i=0; i< lockerInfos.length; i++) {
            UserLockerInfo storage lockerInfo = lockerInfos[i];
            if (block.timestamp >= lockerInfo.depositTimestamp + lockerInfo.period) {
                _balance = _balance.add(lockerInfo.balance);
            }
        }
        return _balance;
    }

    function _deposit(uint periodIndex, uint _amount) private whenNotPaused {
        require(periods.length > periodIndex && periods[periodIndex] > 0 && _amount > 0, "invalid period given");

        IBEP20(token).safeTransferFrom(msg.sender, address(this), _amount);
        totalAmount = totalAmount.add(_amount);
        
        UserLockerInfo memory newLocker = UserLockerInfo(periods[periodIndex], lockerBoosters[periods[periodIndex]], _amount, block.timestamp);
        balances[msg.sender].push(newLocker);
        
        IEBChef(chef).vaultDeposited(msg.sender, _amount);
        IEBChef(chef).safeMint1155(msg.sender, oreTokenId, rewardOreAmount(_amount, lockerBoosters[periods[periodIndex]]));

        emit OreLockerVaultDeposited(msg.sender, periods[periodIndex], _amount);
    }

    function rewardOreAmount(uint amount, uint boostRate) public view returns (uint) {
        uint decimals = IBEP20(token).decimals();
        uint oreAmount = amount.mul(emissionRate).mul(boostRate).div(10 ** decimals).div(1e11); //calculate token amount unit: billion, and boostRate uint: hundred
        return oreAmount;
    }

    function _withdraw(uint _amount) private whenNotPaused {
        uint amountCanWithdraw = unlockedBalance();
        require(amountCanWithdraw > 0, "no token to withdraw");

        uint withdrawingAmount = _amount;
        uint withdrawingAmountMark = withdrawingAmount;
        UserLockerInfo[] storage lockerInfos = balances[msg.sender];
        for (uint i=0; i< lockerInfos.length; i++) {
            UserLockerInfo storage lockerInfo = lockerInfos[i];
            if (block.timestamp >= lockerInfo.depositTimestamp + lockerInfo.period) {
                if (withdrawingAmount > lockerInfo.balance) {
                    withdrawingAmount = withdrawingAmount.sub(lockerInfo.balance);
                    lockerInfo.balance = 0;
                } else {
                    lockerInfo.balance = lockerInfo.balance.sub(withdrawingAmount);
                    withdrawingAmount = 0;
                    break;
                }
            }
        }
        require(withdrawingAmount == 0, "withdrawing should be 0");

        totalAmount = totalAmount.sub(withdrawingAmountMark);

        IBEP20(token).safeTransfer(msg.sender, withdrawingAmountMark);
        IEBChef(chef).vaultWithdrawn(msg.sender, withdrawingAmountMark);

        emit OreLockerVaultWithdrawn(msg.sender, withdrawingAmountMark);
    }
}

