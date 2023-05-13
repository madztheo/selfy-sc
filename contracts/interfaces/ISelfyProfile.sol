// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ISelfyProfile {
    function createSelfyProfile(address recipient) external;

    function evolve(uint256 badgeId) external;

    function getTokenId(address owner) external view returns (uint256);

    function evolve(uint256 badgeId, address recipient) external;
}
