// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;

interface IEBVault {
    function token() external view returns (address);

    function emissionRate() external view returns (uint);

    function isErc1155Token() external pure returns (bool);

    function balance() external view returns (uint);

    function balanceOf(address user) external view returns (uint);

    function deposit(uint amount) external;

    function withdraw(uint amount) external;
}

