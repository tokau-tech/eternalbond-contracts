// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;

library StringUtils {
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