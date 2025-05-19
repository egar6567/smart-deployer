// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "/smart-deployer/IUtilityContract.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC1155Airdroper is IUtilityContract, Ownable {

    constructor() Ownable(msg.sender) {} 

    IERC1155 public token;
    address public treasury;

    error AlreadyInitialized();

    modifier notInitialized() {
        require(!initialized, AlreadyInitialized());
        _;
    }

    bool private initialized;

    function airdrop(address[] calldata receivers, uint256[] calldata amounts, uint256[] calldata tokenId) external onlyOwner {
        require(receivers.length == amounts.length && receivers.length == tokenId.length, "arrays length mismatch");
        require(token.isApprovedForAll(treasury, address(this)), "not enought approved tokens");

        for (uint256 i = 0; i < receivers.length; i++) {
            token.safeTransferFrom(treasury, receivers[i], tokenId[i], amounts[i],"");
        }

    }

    function initialize(bytes memory _initData) external notInitialized returns (bool) {

        (address _token, address _treasury, address _owner)=abi.decode(_initData,(address,address,address));
        
        token = IERC1155(_token);
        treasury = _treasury;
        Ownable.transferOwnership(_owner);

        initialized = true;
        return true;    
    }

    function getInitData(address _token, address _treasury, address _owner) external pure returns (bytes memory){
        return abi.encode(_token,_treasury,_owner);

    }
}

//["0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2","0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db","0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB","0x617F2E2fD72FD9D5503197092aC168c91465E7f2"]
//[2500000000000000000000,3100000000000000000000,1900000000000000000000,2500000000000000000000]