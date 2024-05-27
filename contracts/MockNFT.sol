// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./NFTDelegation.sol";

contract MockNFT is ERC721, Ownable {
    address public nftDelegationContract;
    NFTDelegation public nftDelegation;

    constructor(address _nftDelegationContract) ERC721("MockNFT", "MNFT") {
        nftDelegationContract = _nftDelegationContract;
        nftDelegation = NFTDelegation(_nftDelegationContract);
    }

    function mint(address _to, uint256 _tokenId) external onlyOwner {
        _mint(_to, _tokenId);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public virtual override {
        _transfer(_from, _to, _tokenId);
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

    function _transfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal override {
        address currentOwner = ownerOf(_tokenId);
        super._transfer(_from, _to, _tokenId);
        if (currentOwner != _to) {
            revokeDelegation(_tokenId);
        }
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external view returns (bytes4) {
        require(
            _msgSender() == nftDelegationContract,
            "Can only receive from NFTDelegation contract"
        );
        return IERC721Receiver.onERC721Received.selector;
    }

    function revokeDelegation(uint256 _tokenId) internal {
        address delegate = nftDelegation.getDelegate(_tokenId);
        if (delegate != address(0)) {
            nftDelegation._revokeDelegation(_tokenId);
        }
    }
}
