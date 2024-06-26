# NFTDelegation Smart Contract

## Overview
The NFTDelegation smart contract facilitates the delegation of ownership rights for ERC721 tokens. It allows token owners to delegate their tokens to other addresses, effectively transferring ownership rights temporarily. This contract provides functions to delegate NFTs, revoke delegation, get the delegate address for a token, and handle ERC721 token reception.

## Functions

| Function           | Description                                              | Parameters                                                | Emits                                                    | Returns      | Requires                                                 |
|--------------------|----------------------------------------------------------|-----------------------------------------------------------|----------------------------------------------------------|--------------|----------------------------------------------------------|
| `delegateNFT`      | Allows the owner of an NFT to delegate the ownership    | `_delegate`: Address to delegate the token to.            | `Delegated` event with details of the delegation.        | -            | Caller must be the owner of the token.                  |
|                    | rights of the NFT to another address.                   | `_tokenId`: ID of the token to be delegated.              |                                                          |              | Delegate address must be valid.                         |
| `revokeDelegation` | Allows the owner of an NFT to revoke the delegation of ownership rights of the NFT. | `_tokenId`: ID of the token for which delegation is to be revoked. | `Revoked` event indicating the revocation of delegation. | -            | Caller must be the owner of the token.                  |
|                    |                             |                                                  |                                                          |              | -                                                        |
| `getDelegate`      | Returns the address of the delegate for a given token  ID.   | `_tokenId`: ID of the token to get the delegate for.      | -                                                        | Delegate(address)     | -                                                        |
|                    |                                                     |                                                           |                                                          | address      | -                                                        |
| `onERC721Received` | Handles the reception of ERC721 tokens.                 | -                                                         | -                                                        | bytes4       | Sender must be the NFT contract.                        |
| `setNFTContract`   | Sets the address of the ERC721 contract.                | `_nftContractAddress`: Address of the ERC721 contract.    | -                                                        | -            | -                                                        |
                                                

## Deployment and Testing
To deploy and test the NFTDelegation contract, follow these steps:

1. **Clone the Project**
   - Clone the project repository from GitHub using the following command:
     ```bash
     git clone https://github.com/samirbenbouker/OpenfortChallange/tree/main
     ```

2. **Setup**
   - Install project dependencies:
     ```bash
     npm install
     ```

3. **Deployment**
   - Ensure you have Hardhat installed and configured.
   - Use the provided deploy script to deploy the contract.
   - Run the deploy script using:
     ```bash
     npx hardhat run scripts/NFTDelegation.deploy.js --network localhost
     ```
   - Replace `<your_network>` with the desired network (e.g., `rinkeby`, `mainnet`, etc.).

4. **Testing**
   - Write test cases using Hardhat's testing framework.
   - Create a test file with relevant test cases for each function.
   - Ensure your tests cover various scenarios including delegation, revocation, and error cases.
   - Run your test file using:
     ```bash
     npx hardhat test
     ```
