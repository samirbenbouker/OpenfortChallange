
async function main() {
    // Deploying the NFTDelegationExtension contract
    const NFTDelegationExtension = await ethers.getContractFactory("NFTDelegationExtension");

    console.log("Deploying NFTDelegationExtension...");
    const nftDelegationExtension = await NFTDelegationExtension.deploy(
        "https://example.com/metadata/id.json", // Replace with your URI
        "0xe889FDe1E5AACc9AAa1f3221FB90D3Ad6f442c95" // Replace with your ERC20 token address
    );

    await nftDelegationExtension.waitForDeployment();
    console.log("NFTDelegationExtension deployed to:", await nftDelegationExtension.getAddress());
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });