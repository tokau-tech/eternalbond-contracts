// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

import "@pancakeswap/pancake-swap-lib/contracts/math/SafeMath.sol";

import "../interfaces/IEB1155Minter.sol";
import "../interfaces/IERC1155MintableBurnableUpgradeable.sol";

import { EBConstants } from "../library/EBConstants.sol";

abstract contract Base1155Minter is IEB1155Minter, Initializable, OwnableUpgradeable {
    using SafeMath for uint;
    using AddressUpgradeable for address;

    address public chef;
    address public override token;

    modifier onlyChef() {
        require(msg.sender == chef, "OreMinter: operater not chef");
        _;
    }

    function setChef(address _chef) internal onlyOwner {
        chef = _chef;
    }

    function setToken(address _token) internal onlyOwner {
        token = _token;
    }

    function mint(address user, uint tokenId, uint amount) public override onlyChef {
        IERC1155MintableBurnableUpgradeable(token).mint(user, tokenId, amount, '');
    }

    function mintFor(address _token, address user, uint tokenId, uint amount) public override onlyChef {
        IERC1155MintableBurnableUpgradeable(_token).mint(user, tokenId, amount, '');
    }

    // function mintNFT721(address user, uint tokenId) public override onlyChef {
    //     IERC721MintableBurnableUpgradeable erc721 = IERC721MintableBurnableUpgradeable(token);
    //     erc721.mintWithTokenId(user, tokenId);
    // }

    // function mintToken(address user, uint amount) public override onlyChef {
    //     IERC20MintableBurnableUpgradeable erc20 = IERC20MintableBurnableUpgradeable(token);
    //     erc20.mint(user, amount);
    // }

    function safeTransfer(address user, uint tokenId, uint amount) public override onlyChef {
        
    }
}

