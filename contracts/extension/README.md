# NFTDelegationExtension Smart Contract

## Overview
The NFTDelegationExtension smart contract extends the functionality of ERC1155 tokens by allowing for the delegation of ownership rights for ERC721 tokens. It enables token owners to delegate their tokens to other addresses, facilitating the transfer of ownership rights temporarily. This contract also supports the delegation of ERC20 tokens and provides functions for depositing, withdrawing, delegating, and revoking delegation of both ERC721 and ERC20 tokens.

## Functions

| Function                   | Description                                              | Parameters                                                   | Emits                                                             | Returns      | Requires                                                 |
|----------------------------|----------------------------------------------------------|--------------------------------------------------------------|-------------------------------------------------------------------|--------------|----------------------------------------------------------|
| `depositERC721`            | Deposits ERC721 tokens into the contract.               | `_nftContract`: Address of the ERC721 contract.              | `ERC721Deposited` event with details of the deposit.              | -            | -                                                        |
|                            |                                                          | `_tokenId`: ID of the ERC721 token to deposit.                |                                                                   |              |                                                          |
|                            |                                                          | `_id`: ID of the corresponding ERC1155 token.                 |                                                                   |              |                                                          |
| `withDrawERC721`           | Withdraws ERC721 tokens from the contract.              | `_id`: ID of the ERC1155 token.                              | `ERC721Withdraw` event with details of the withdrawal.            | -            | Sender must own the deposited ERC721 token.             |
|                            |                                                          | `_tokenId`: ID of the ERC721 token to withdraw.              |                                                                   |              |                                                          |
| `delegateERC271`           | Delegates ownership of ERC721 tokens to another address. | `_to`: Address to delegate the token to.                     | `ERC721Delegated` event with details of the delegation.            | -            | Sender must own the deposited ERC721 token.             |
|                            |                                                          | `_id`: ID of the ERC1155 token corresponding to the token.   |                                                                   |              |                                                          |
|                            |                                                          | `_tokenId`: ID of the ERC721 token.                          |                                                                   |              |                                                          |
| `revokeERC721Delegation`   | Revokes delegation of ERC721 tokens.                     | `_id`: ID of the ERC1155 token.                              | `ERC721DelegationRevoked` event with details of the revocation.    | -            | Sender must own the deposited ERC721 token.             |
|                            |                                                          | `_tokenId`: ID of the ERC721 token.                          |                                                                   |              |                                                          |
| `getERC721Delegate`        | Retrieves the delegate address for an ERC721 token.      | `_id`: ID of the ERC1155 token.                              | -                                                                 | Delegate     | -                                                        |
|                            |                                                          | `_token`: ID of the ERC721 token.                            |                                                                   | address      |                                                          |
| `depositERC20`             | Deposits ERC20 tokens into the contract.                | `_amount`: Amount of ERC20 tokens to deposit.                | `ERC20Deposited` event with details of the deposit.                | -            | -                                                        |
| `delegateERC20`            | Delegates ERC20 tokens to another address.              | `_to`: Address to delegate the tokens to.                    | `ERC20Delegated` event with details of the delegation.             | -            | Sender must have sufficient ERC20 token balance.        |
|                            |                                                          | `_amount`: Amount of ERC20 tokens to delegate.              |                                                                   |              |                                                          |
| `revokeERC20Delegation`    | Revokes delegation of ERC20 tokens.                      | -                                                            | `ERC20DelegationRevoked` event with details of the revocation.     | -            | Sender must have delegated ERC20 tokens.               |
| `getERC20Delegate`         | Retrieves the delegate address for ERC20 tokens.        | `_owner`: Address of the token owner.                        | -                                                                 | Delegate     | -                                                        |
| `getERCBalance`            | Retrieves the ERC20 token balance of an address.        | `_owner`: Address to retrieve the balance for.               | -                                                                 | Balance      | -                                                        |

## Deployment and Testing
   - Ensure you have Hardhat installed and configured.
   - Use the provided deploy script to deploy the contract.
   - Run the deploy script using:
     ```bash
     npx hardhat run NFTDelegation.extension.deploy.js --network localhost
     ```
   - Replace `<your_network>` with the desired network (e.g., `rinkeby`, `mainnet`, etc.).

4. **Testing**
   - Write test cases using Hardhat's testing framework.
   - Create a test file with relevant test cases for each function.
   - Ensure your tests cover various scenarios including delegation, revocation, and error cases.
   - Run your test file using:
     ``` bash
     npx hardhat test
     ```
