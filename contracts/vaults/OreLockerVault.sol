// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

import '@pancakeswap/pancake-swap-lib/contracts/token/BEP20/IBEP20.sol';
import '@pancakeswap/pancake-swap-lib/contracts/token/BEP20/SafeBEP20.sol';
import "@pancakeswap/pancake-swap-lib/contracts/math/SafeMath.sol";

import "./BaseVault.sol";
import "../interfaces/IEBChef.sol";

import { EBConstants } from "../library/EBConstants.sol";

/*
    lock token but claim rewards when they just deposited related tokens.
    using a fixed emission rate.
*/
contract OreLockerVault is BaseVault {
    using SafeMath for uint;
    using SafeBEP20 for IBEP20;

    struct UserLockerInfo {
        uint period;
        uint boostRate;
        uint depositedAmount;
        uint withdrawnAmount;
        uint depositTimestamp;
    }

    uint public oreTokenId;
    uint public totalAmount;
    uint public emissionRate;

    uint[] public periods;
    mapping(uint => uint) lockerBoosters;
    mapping(address => UserLockerInfo[]) balances;

    function initialize(address _chef, address _token, uint _oreTokenId, uint _emissionRate) public initializer {
        setChef(_chef);
        setToken(_token);
        setEmissionRate(_emissionRate);
        setOreTokenId(_oreTokenId);
    }

    function setOreTokenId(uint _oreTokenId) public onlyOwner {
        oreTokenId = _oreTokenId;
    }

    function setEmissionRate(uint _emissionRate) public onlyOwner  {
        emissionRate = _emissionRate;
    }

    function setEmissionRate(uint _emissionRate) public onlyOwner {
        require(_emissionRate > 0, "error parameters");
        emissionRate = _emissionRate;
    }

    function isErc1155Token() public pure override returns (bool) {
        return true;
    }

    function setLockerPeroids(uint[] memory _periods, uint[] memory _boostRates) public onlyOwner {
        require(_periods.length == _boostRates.length, "error parameters");
        delete periods;
        for (uint i=0; i<_periods.length; i++) {
            lockerBoosters[_periods[i]] = _boostRates[i];
            periods.push(_periods[i]);
        }
    }

    function depositLocker(uint periodIndex, uint amount) public nonReentrant {
        _deposit(periodIndex, amount);
    }

    function deposit(uint amount) public override nonReentrant {
        //use default period as default
        _deposit(0, amount);
    }

    function withdraw(uint amount) public override notPaused nonReentrant {
        require(amount > 0, "invalid amount");
        _withdraw(amount);
    }

    function withdrawAll() public override notPaused nonReentrant {
        _withdraw(-1);
    }

    function balanceOf() public view override returns (uint) {
        UserLockerInfo[] storage lockerInfos = balances[msg.sender];
        uint balance = 0;
        if (lockerInfos.length > 0) {
            for (uint i=0; i< lockerInfos.length; i++) {
                UserLockerInfo storage lockerInfo = lockerInfos[i];
                balance = balance.add(lockerInfo.depositedAmount).sub(lockerInfo.withdrawnAmount);
            }
        }
        return balance;
    }

    function unlockedBalance() public view returns (uint) {
        UserLockerInfo[] storage lockerInfos = balances[msg.sender];
        uint balance = 0;
        if (lockerInfos.length > 0) {
            for (uint i=0; i< lockerInfos.length; i++) {
                UserLockerInfo storage lockerInfo = lockerInfos[i];
                if (block.timestamp >= lockerInfo.depositTimestamp + lockerInfo.period) {
                    balance = balance.add(lockerInfo.depositedAmount).sub(lockerInfo.withdrawnAmount);
                }
            }
        }
        return balance;
    }

    function _deposit(uint periodIndex, uint _amount) private notPaused nonReentrant {
        require(periods[periodIndex] > 0, "invalid period given");

        IBEP20(token).safeTransferFrom(msg.sender, address(this), _amount);
        totalAmount = totalAmount.add(_amount);
        
        UserLockerInfo storage newLocker = UserLockerInfo(periods[periodIndex], lockerBoosters[periods[periodIndex]], _amount, 0, block.timestamp);
        UserLockerInfo[] storage lockerInfos = balances[msg.sender];
        if (lockerInfos.length > 0) {
            lockerInfos.push(newLocker);
        } else {
            balances[msg.sender] = new uint[]();
            balances[msg.sender].push(newLocker);
        }

        IEBChef(chef).vaultDeposited(msg.sender, _amount);
        IEBChef(chef).safeMint1155(msg.sender, oreTokenId, rewardOreAmount(_amount, periods[periodIndex]));
    }

    function rewardOreAmount(uint amount, uint boostRate) public view returns (uint) {
        uint decimals = IBEP20(token).decimals();
        uint oreAmount = amount.mul(emissionRate).mul(boostRate).div(decimals).div(1e9); //calculate token amount as billion
        return oreAmount;
    }

    function _withdraw(uint _amount) private notPaused nonReentrant {
        bool isWithdrawAll = _amount < 0 ? true : false;
        uint amountCanWithdraw = unlockedBalance();
        require(amountCanWithdraw > 0, "no token to withdraw");

        uint withdrawingAmount = _amount;
        if (isWithdrawAll) {
            withdrawingAmount = amountCanWithdraw;
        }
        uint withdrawingAmountMark = withdrawingAmount;
        UserLockerInfo[] storage lockerInfos = balances[msg.sender];
        if (lockerInfos.length > 0) {
            for (uint i=0; i< lockerInfos.length; i++) {
                UserLockerInfo storage lockerInfo = lockerInfos[i];
                if (block.timestamp >= lockerInfo.depositTimestamp + lockerInfo.period) {
                    if (!isWithdrawAll) {
                        if (withdrawingAmount > lockerInfo.depositedAmount) {
                            lockerInfo.withdrawnAmount = lockerInfo.depositedAmount;
                            withdrawingAmount = withdrawingAmount.sub(lockerInfo.depositedAmount);
                        } else {
                            lockerInfo.withdrawnAmount = withdrawingAmount;
                            withdrawingAmount = 0;
                            break;
                        }
                    } else {
                        lockerInfo.withdrawnAmount = lockerInfo.depositedAmount;
                        withdrawingAmount = withdrawingAmount.sub(lockerInfo.depositedAmount);
                    }
                }
            }
        }
        require(withdrawingAmount == 0, "withdrawing should be 0");

        totalAmount = totalAmount.sub(withdrawingAmountMark);

        IBEP20(token).safeTransfer(msg.sender, withdrawingAmountMark);
        IEBChef(chef).vaultWithdrawn(msg.sender, withdrawingAmountMark);
    }
}

