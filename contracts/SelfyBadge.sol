// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@sismo-core/sismo-connect-solidity/contracts/libs/SismoLib.sol";
import "./interfaces/ISelfyProfile.sol";

contract SelfyBadge is Ownable, ERC1155, SismoConnect {
    using SismoConnectHelper for SismoConnectVerifiedResult;

    bytes16 public sismoAppId = 0x9b8f95f5e9e1d14857fea5bc2f8e9337;
    // Token id => commitment => has claimed
    mapping(uint256 => mapping(uint256 => bool)) public hasClaimed;
    // TokenId => URI
    mapping(uint256 => string) public tokenUris;

    ISelfyProfile public selfyProfile;

    constructor(address _selfyProfile) ERC1155("") SismoConnect(sismoAppId) {
        selfyProfile = ISelfyProfile(_selfyProfile);
    }

    function claimWithSismo(bytes memory response, bytes16 groupId) public {
        // Convert the address to bytes
        bytes memory message = bytes.concat(bytes20(msg.sender));

        // Verify the Sismo response
        SismoConnectVerifiedResult memory result = verify({
            responseBytes: response,
            auth: buildAuth({authType: AuthType.VAULT}),
            // Check the user belongs to the requested group
            claim: buildClaim({groupId: groupId}),
            // Check that the user allowed the sender to receive the badge
            signature: buildSignature({message: message})
        });

        // Compute a commitment from the result to prevent double mint
        // from the same vault
        uint256 commitment = SismoConnectHelper.getUserId(
            result,
            AuthType.VAULT
        );
        uint256 tokenId = getTokenIdFromGroupId(groupId);
        // Check that the user has not already claimed the badge
        require(!hasClaimed[tokenId][commitment], "Badge already claimed");
        // Mark the badge as claimed
        hasClaimed[tokenId][commitment] = true;
        // The tokenId is the groupId
        // Mint the badge
        _mint(msg.sender, tokenId, 1, "");

        // Evolve the profile
        uint256 profileTokenId = selfyProfile.getTokenId(msg.sender);
        selfyProfile.evolve(profileTokenId, tokenId, 100);
    }

    /*
        @notice Get the token uri
        @param tokenId : The token id
    */
    function tokenURI(
        uint256 tokenId
    ) public view virtual returns (string memory) {
        return tokenUris[tokenId];
    }

    /*
        @notice Set the token uri
        @param tokenId : The token id
        @param newuri : The new uri
    */
    function setURI(uint256 tokenId, string memory newuri) external onlyOwner {
        tokenUris[tokenId] = newuri;
    }

    function setAppId(bytes16 _appId) external onlyOwner {
        sismoAppId = _appId;
    }

    function getTokenIdFromGroupId(
        bytes16 groupId
    ) public pure returns (uint256) {
        return uint256(bytes32(groupId));
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
        require(from == address(0), "Tokens are not transferrable");
    }
}
