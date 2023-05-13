// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ISelfyProfile {
    function createSelfyProfile() external;

    function evolve(uint256 badgeId) external;

    function getTokenId(address owner) external view returns (uint256);

    function evolve(
        uint256 tokenId,
        uint256 badgeId,
        uint256 _nbTokenPayement
    ) external;
}
