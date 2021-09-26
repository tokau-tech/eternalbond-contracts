// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IEBVault {
    function token() external view returns (address);

    function isErc1155Token() external pure returns (bool);

    function balanceOf() external view returns (uint);

    function deposit(uint amount) external;

    function withdraw(uint amount) external;

    function withdrawAll() external;
}

