// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SelfySnapshotGHO is ERC1155, AccessControl, ERC1155Burnable, ERC1155Supply {
    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    IERC20 public  ghoToken;

    uint256 public constant mintPrice = 100 ether;
    constructor(address _ghoTokenAddress) ERC1155("ipfs://") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(URI_SETTER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        ghoToken = IERC20(_ghoTokenAddress);
    }

    function setURI(string memory newuri) public onlyRole(URI_SETTER_ROLE) {
        _setURI(newuri);
    }

    function mint(uint256 id, uint256 amount, bytes memory data, uint256 _amountOfGHO)
    payable public
    {
        require(_amountOfGHO >= (amount * mintPrice), "Not enough ether sent");
        ghoToken.transferFrom(msg.sender, address(this), _amountOfGHO);
        _mint(msg.sender, id, amount, data);
    }

    function mintBatch(uint256[] memory ids, uint256[] memory amounts, bytes memory data, uint256 _amountOfGHO)
    payable public
    {
        require(ids.length == amounts.length, "Invalid input arrays");
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < amounts.length; i+=1) {
            totalAmount += amounts[i];
        }
        require(_amountOfGHO >= (totalAmount * mintPrice), "Not enough ether sent");
        ghoToken.transferFrom(msg.sender, address(this), _amountOfGHO);
        _mintBatch(msg.sender, ids, amounts, data);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
    internal
    override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC1155, AccessControl)
    returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}