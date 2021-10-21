// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "../../interfaces/IERC721MintableBurnable.sol";

contract NftComposerBurner is Ownable {
    using SafeMath for uint;
    using Address for address;

    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;

    uint[][] public composers;
    uint[] public specialComposers;

    uint public tokenRangeFactor;
    address public token;

    event CompositionSucceed(address user, uint[] componentRanges, uint[] tokenIds, uint[] specialTokenIds, uint blockNumber);
    event ComposersUpdated(uint[][] oldComposers, uint[][] newComposers);
    event TokenRangeFactorUpdated(uint oldTokenRangeFactor, uint newTokenRangeFactor);

    constructor(address _token, uint[][] memory _composers, uint[] memory _specialComposers, uint _tokenRangeFactor) {
        token = _token;
        composers = _composers;
        specialComposers = _specialComposers;
        tokenRangeFactor = _tokenRangeFactor;
    }

    function setComposers(uint[][] memory _composers) public onlyOwner {
        uint[][] memory oldComposers = composers;
        composers = _composers;

        emit ComposersUpdated(oldComposers, composers);
    }

    function setTokenRangeFactor(uint _tokenRangeFactor) public onlyOwner {
        uint oldTokenRangeFactor = tokenRangeFactor;
        tokenRangeFactor = _tokenRangeFactor;

        emit TokenRangeFactorUpdated(oldTokenRangeFactor, tokenRangeFactor);
    } 

    function getComposers(uint _compositionIndex) public view returns (uint[] memory) {
        require(composers.length > _compositionIndex, "invalid composition index.");
        return composers[_compositionIndex];
    }

    function composition(uint _compositionIndex, uint[] memory _tokenIds, uint[] memory _specialTokenIds) public returns (bool) {
        require(composers.length > _compositionIndex, "invalid composition index.");
        require(IERC721MintableBurnable(token).isApprovedForAll(msg.sender, address(this)), "no operate permission");
        require(composers.length == _tokenIds.length, "component parts mismatch");
        
        bool componentsSucceeded = true;
        uint[] memory composerComponents = composers[_compositionIndex];
        for (uint i=0; i<composerComponents.length; i++) {
            if (!_isTokenInRange(composerComponents[i], _tokenIds[i])) {
                componentsSucceeded = false;
                break;
            }
        }
        require(componentsSucceeded, 'components mismatched.');
        
        for (uint i=0; i<_specialTokenIds.length; i++) {
            bool isValidSpecialTokenId = false;
            for (uint j=0; j<specialComposers.length; j++) {
                if (_isTokenInRange(specialComposers[j], _specialTokenIds[i])) {
                    isValidSpecialTokenId = true;
                    break;
                }
            }
            require(isValidSpecialTokenId, 'invalid special component.');
        }

        for (uint i=0; i<composerComponents.length; i++) {
            IERC721MintableBurnable(token).transferFrom(msg.sender, address(this), _tokenIds[i]);
        }

        for (uint i=0; i<_specialTokenIds.length; i++) {
            IERC721MintableBurnable(token).transferFrom(msg.sender, address(this), _specialTokenIds[i]);
        }

        emit CompositionSucceed(msg.sender, composerComponents, _tokenIds, _specialTokenIds, block.number);
        return componentsSucceeded;
    }

    function burnComponentsNFT(uint[] memory tokenIds) public onlyOwner {
        transferComponentsNFT(tokenIds, DEAD);
    }

    function transferComponentsNFT(uint[] memory tokenIds, address to) public onlyOwner {
        for (uint i; i<tokenIds.length; i++) {
            IERC721MintableBurnable(token).transferFrom(address(this), to, tokenIds[i]);
        }
    }

    function _isTokenInRange(uint _tokenRange, uint _tokenId) private view returns (bool) {
        return _tokenRange.div(tokenRangeFactor) == _tokenId.div(tokenRangeFactor);
    }
}