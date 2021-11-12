// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// import "../utils/StringUtils.sol";

contract EBNftStakeRateHelper is Ownable {
    using SafeMath for uint;
    using Address for address;
    using Strings for uint;
    // using StringUtils for string;

    struct NftInfo {
        uint tokenPrefix;
        uint boostRate;
    }

    address constant public STARRY = 0x4E64198C1E13248BfC0e63D53E03460dbB383a94;

    mapping(address => NftInfo[]) private tokens;

    event NftStakeRateUpdated(address token, uint[] indexed tokenPrefixes, uint[] indexed boostRates);

    constructor(address _token, uint[] memory _tokenProfixes, uint[] memory _boostRates) {
        addToken(_token, _tokenProfixes, _boostRates);
    }

    function addToken(address _token, uint[] memory _tokenProfixes, uint[] memory _boostRates) public onlyOwner {
        require(tokens[_token].length == 0, "add existed token");
        require(_tokenProfixes.length > 0, "invalid input");
        require(_tokenProfixes.length == _boostRates.length, "should be same size");
        for (uint i = 0; i < _tokenProfixes.length; i++) {
            NftInfo memory newNftInfo = NftInfo(_tokenProfixes[i], _boostRates[i]);
            tokens[_token].push(newNftInfo);
        }
        emit NftStakeRateUpdated(_token, _tokenProfixes, _boostRates);
    }

    function updateToken(address _token, uint[] memory _tokenProfixes, uint[] memory _boostRates) public onlyOwner {
        require(tokens[_token].length > 0, "update unexisted token");
        delete tokens[_token];
        addToken(_token, _tokenProfixes, _boostRates);
    }

    function isStarryStakeableNft(uint _tokenId) public view returns (bool) {
        return isStakeableNft(STARRY, _tokenId);
    }

    function isStakeableNft(address _token, uint _tokenId) public view returns (bool) {
        return boostRate(_token, _tokenId) > 0;
    }

    function boostRate(address _token, uint _tokenId) public view returns (uint) {
        if (tokens[_token].length == 0) {
            return 0;
        }
        string memory tokenIdStr = _tokenId.toString();
        for (uint i = 0; i < tokens[_token].length; i++) {
            string memory tokenPrefix = tokens[_token][i].tokenPrefix.toString();
            if (startsWith(tokenIdStr, tokenPrefix)) {
            // if (tokenIdStr.startsWith(tokenPrefix)) {
                return tokens[_token][i].boostRate;
            }
        }
        return 0;
    }

    function startsWith(string memory _self, string memory _needle) public pure returns (bool) {
        bytes memory self = bytes(_self);
        bytes memory needle = bytes(_needle);
        bool isStartsWithNeedle = true;
        for (uint i = 0; i < needle.length; i++) {
            if (self[i] != needle[i]) {
                isStartsWithNeedle = false;
                break;
            }
        }
        return isStartsWithNeedle;
    }

    function equals(string memory _self, string memory _needle) public pure returns (bool) {
        bytes memory self = bytes(_self);
        bytes memory needle = bytes(_needle);
        if (self.length == 0 || needle.length == 0 || self.length != needle.length) {
            return false;
        }
        bool isEqual = true;
        for (uint i = 0; i < self.length; i++) {
            if (self[i] != needle[i]) {
                isEqual = false;
                break;
            }
        }
        return isEqual;
    }
}