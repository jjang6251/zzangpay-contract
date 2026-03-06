const ethers = require("ethers");
const hre = require("hardhat");

async function main() {
    const artifact = await hre.artifacts.readArtifact("Zusdc");
    const abi = artifact.abi;
    const bytecode = artifact.bytecode;

    const provider = new ethers.JsonRpcProvider(process.env.SEPOLIA_RPC_URL);
    const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
    const deployer = wallet.address;

    console.log("deployer address...", deployer);

    const factory = new ethers.ContractFactory(abi, bytecode, wallet);
    const zusdc = await factory.deploy(deployer);
    
    console.log("deploying...", zusdc.target);
}

main().then(() => process.exit(0).catch(error => {
    console.log(error);
    process.exit(1);
}))