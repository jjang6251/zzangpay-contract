const ethers = require("ethers");
require("dotenv").config();

async function main() {
  const provider = new ethers.JsonRpcProvider(process.env.SEPOLIA_RPC_URL);
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

  const artifact = require("../artifacts/contracts/zusdc.sol/Zusdc.json");
  const abi = artifact.abi;

  const zusdc = new ethers.Contract(
    "0x6fe89141175341e5C27B7a4C458d28781c52208a",
    abi,
    wallet
  );

  const beforeTotalBalace = await zusdc.totalSupply();
  console.log("Before Additional Mint", beforeTotalBalace.toString());

  const amount = ethers.parseUnits("1000", 6); // 1000 ZUSDC (6 decimals)
  const tx = await zusdc.mint(wallet.address, amount);
  const receipt = await tx.wait();
  console.log("mint tx receipt:", receipt);

  const afterTotalBalance = await zusdc.totalSupply();
  console.log("After Minted", afterTotalBalance.toString());

  console.log("Additional Minted Volume", afterTotalBalance.toString() - beforeTotalBalace.toString());

  const balance = await zusdc.balanceOf(wallet.address);
  console.log("initial address balance", balance.toString());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });