pragma solidity ^0.8.3;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract BatchTransferUtil is Ownable {
    using Address for address;
    using SafeMath for uint;

    address private tokenAddress;
    address private tokenSender;

    event TokenAddressChanged(address newToken);
    event TokenSenderChanged(address newSender);

    constructor(address _tokenAddr, address _tokenSender) {
        tokenAddress = _tokenAddr;
        tokenSender = _tokenSender;
    }

    function batchTransfer(address[] memory _addresses, uint[] memory _balances) public onlyOwner returns (bool success) {
        require(_addresses.length > 0, "no record");
        require(_addresses.length == _balances.length, "mismatch");
        require(tokenAddress.isContract(), "token error");
        IERC20 token = IERC20(tokenAddress);
        for (uint i=0; i<_addresses.length; i++) {
            require(token.transferFrom(tokenSender, _addresses[i], _balances[i]), "error during transfer");
        }
        return true;
    }

    function setToken(address _tokenAddr) public onlyOwner {
        tokenAddress = _tokenAddr;
        emit TokenAddressChanged(_tokenAddr);
    }

    function setSender(address _tokenSender) public onlyOwner {
        tokenSender = _tokenSender;
        emit TokenSenderChanged(tokenSender);
    }
}
