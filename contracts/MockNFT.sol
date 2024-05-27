// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./NFTDelegation.sol";

contract MockNFT is ERC721, Ownable {
    // Public variable to store the address of the NFTDelegation contract.
    address public nftDelegationContract;

    // Public variable to store the instance of the NFTDelegation contract.
    NFTDelegation public nftDelegation;

    constructor(address _nftDelegationContract) ERC721("MockNFT", "MNFT") {
        // Set the address of the NFTDelegation contract.
        // Initialize the instance of the NFTDelegation contract.
        nftDelegationContract = _nftDelegationContract;
        nftDelegation = NFTDelegation(_nftDelegationContract);
    }

    // Function to mint ERC721 tokens.
    function mint(address _to, uint256 _tokenId) external onlyOwner {
        _mint(_to, _tokenId);
    }

    // Override the transferFrom function of ERC721 contract.
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public virtual override {
        // Transfer the token.
        _transfer(_from, _to, _tokenId);

        // Check if the receiver contract supports ERC721Receiver interface and handle the received token.
        require(
            IERC721Receiver(nftDelegationContract).onERC721Received(
                msg.sender,
                _from,
                _tokenId,
                ""
            ) == this.onERC721Received.selector,
            "ERC721 transfer to non ERC721Receiver implementer"
        );
    }

    // Internal function to handle token transfer.
    function _transfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal override {
        // Get the current owner of the token.
        address currentOwner = ownerOf(_tokenId);
        super._transfer(_from, _to, _tokenId);

        // If the new owner is different from the current owner, revoke the delegation.
        if (currentOwner != _to) {
            revokeDelegation(_tokenId);
        }
    }

    // Function to handle ERC721 token reception.
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external view returns (bytes4) {
        // Ensure that the sender is the NFTDelegation contract.
        // Return the ERC721Received selector.
        require(
            _msgSender() == nftDelegationContract,
            "Can only receive from NFTDelegation contract"
        );
        return IERC721Receiver.onERC721Received.selector;
    }

    // Internal function to revoke delegation of an NFT.
    function revokeDelegation(uint256 _tokenId) internal {
        // Get the delegate address for the token.
        address delegate = nftDelegation.getDelegate(_tokenId);

        // Revoke the delegation if delegate is not zero address.
        if (delegate != address(0)) {
            nftDelegation.revokeDelegation(_tokenId);
        }
    }
}
