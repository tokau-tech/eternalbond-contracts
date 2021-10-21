// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "../token/TokAuStarry.sol";

 contract StarryBatchMintTransferHelper is Ownable {
    using Address for address;

    address public tokenAddress;
    
    event TokenAddressUpdated(address oldTokenAddress, address newTokenAddress);

    constructor(address _tokenAddress) {
        setTokenAddress(_tokenAddress);
    }

    function batchMint(address[] memory users, uint[] memory tokenIds) public onlyOwner returns (bool) {
        require(users.length > 0, "length should larger than 0");
        require(users.length == tokenIds.length, "length mismatch");
        for (uint i=0; i<users.length; i++) {
            TokAuStarry(tokenAddress).mint(users[i], tokenIds[i]);
        }
        return true;
    }

    function batchTransfer(address from, address[] memory users, uint[] memory tokenIds) public onlyOwner returns (bool) {
        require(users.length > 0, "length should larger than 0");
        require(users.length == tokenIds.length, "length mismatch");
        for (uint i=0; i<users.length; i++) {
            TokAuStarry(tokenAddress).transferFrom(from, users[i], tokenIds[i]);
        }
        return true;
    }

    function setTokenAddress(address _newTokenAddress) public onlyOwner {
        require(_newTokenAddress.isContract(), "token error");

        address _oldTokenAddress = tokenAddress;
        tokenAddress = _newTokenAddress;
        emit TokenAddressUpdated(_oldTokenAddress, _newTokenAddress);
    }
 }