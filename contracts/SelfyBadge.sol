// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {SismoConnect, SismoConnectHelper, SismoConnectVerifiedResult, AuthType} from "@sismo-core/sismo-connect-solidity/contracts/libs/SismoLib.sol";
import {ISelfyProfile} from "./interfaces/ISelfyProfile.sol";

// TODO : Optimize because error of Contract too large
contract SelfyBadge is ERC1155, SismoConnect {
    using SismoConnectHelper for SismoConnectVerifiedResult;

    bytes16 internal sismoAppId = 0x9b8f95f5e9e1d14857fea5bc2f8e9337;
    // TokenId => Has claimed
    mapping(uint256 => bool) internal hasClaimed;
    // TokenId => URI
    mapping(uint256 => string) internal tokenUris;

    ISelfyProfile internal selfyProfile;

    address private _owner;

    // Error
    error BadgeAlreadyClaimed();
    error TokenNotTransferable();
    error NotOwner();

    // Event
    event BadgeBurn(address indexed _user, uint256 _tokenId);
    event OwnershipTransferred(address indexed newOwner);

    // Modifier
    modifier onlyOwner() {
        if (_owner != _msgSender()) revert NotOwner();
        _;
    }

    /*
     * @notice Transfer the ownership of the contract
     * @param newOwner The new owner
     */
    constructor(address _selfyProfile) ERC1155("") SismoConnect(sismoAppId) {
        selfyProfile = ISelfyProfile(_selfyProfile);
        _owner = msg.sender;
    }

    /**
     * @notice Claim your badge with Sismo
     * @param response The response from Sismo
     * @param groupId The group id of the badge
     */
    function claimWithSismo(bytes memory response, bytes16 groupId) external {
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
        // Check that the user has not already claimed the badge
        if (hasClaimed[commitment]) revert BadgeAlreadyClaimed();
        // Mark the badge as claimed
        hasClaimed[commitment] = true;
        // The tokenId is the groupId
        uint256 _tokenId = uint256(bytes32(groupId));
        // Mint the badge
        _mint(msg.sender, _tokenId, 1, "");

        // Evolve the profile
        selfyProfile.evolve(_tokenId, 100);
    }

    /**
      * @notice Get the token uri
      * @param tokenId : The token id
      */
    function tokenURI(uint256 tokenId) external view virtual returns (string memory) {
        return tokenUris[tokenId];
    }

    /**
      * @notice Set the token uri
      * @param tokenId : The token id
      * @param newuri : The new uri
      */
    function setURI(uint256 tokenId, string memory newuri) external onlyOwner {
        tokenUris[tokenId] = newuri;
    }

    function setAppId(bytes16 _appId) external onlyOwner {
        sismoAppId = _appId;
    }

    /**
      * @notice Hook before token transfer
      * @param operator : The operator
      * @param from : The sender
      * @param to : The receiver
      * @param ids : The token ids
      * @param amounts : The token amounts
      * @param data : The data
      */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
        // Prevent transfer but let user burn its badge
        if (to != address(0)) revert TokenNotTransferable();
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        _owner = newOwner;
        emit OwnershipTransferred(newOwner);
    }
}
